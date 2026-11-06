#===============================================================================
#
#===============================================================================
class UIControls::Label < UIControls::BaseControl
  attr_reader :text

  LEFT_PADDING = 4   # Blank space to left of text

  def initialize(width, height, viewport, text)
    super(width, height, viewport)
    @text = text
    @underlined = false
    @header = false
    @disabled = true   # No interactivity
  end

  #-----------------------------------------------------------------------------

  def text=(value)
    @text = value
    refresh
  end

  def underlined=(val)
    @underlined = val
    refresh
  end

  def header=(val)
    @header = val
    refresh
  end

  def text_width
    return self.bitmap.text_size(@text).width
  end

  #-----------------------------------------------------------------------------

  def refresh
    super
    if @header
      draw_text_centered(self.bitmap, 0, TEXT_OFFSET_Y, width, @text)
      # Draw underline
      text_size = self.bitmap.text_size(@text)
      self.bitmap.fill_rect((width - text_size.width) / 2, TEXT_OFFSET_Y + text_size.height,
                            text_size.width, 1, get_color_of(:text))
    else
      draw_text(self.bitmap, LEFT_PADDING, TEXT_OFFSET_Y, @text)
      if @underlined
        text_size = self.bitmap.text_size(@text)
        self.bitmap.fill_rect(LEFT_PADDING, TEXT_OFFSET_Y + text_size.height,
                              text_size.width, 1, get_color_of(:text))
      end
    end
  end
end

#===============================================================================
# NOTE: Strictly speaking, this is a toggle switch and not a checkbox.
#===============================================================================
class UIControls::Checkbox < UIControls::BaseControl
  CHECKBOX_X         = 0
  CHECKBOX_WIDTH     = 35   # Actual width of the drawn checkbox
  CHECKBOX_HEIGHT    = 20   # Actual height of the drawn checkbox
  CHECKBOX_FILL_SIZE = CHECKBOX_HEIGHT - 4

  # width does nothing.
  # height is the height of the line this control is being drawn in.
  def initialize(width, height, viewport, value = false)
    super(width, height, viewport)
    @value = value
  end

  #-----------------------------------------------------------------------------

  def value=(new_value)
    return if @value == new_value
    @value = new_value
    invalidate
  end

  #-----------------------------------------------------------------------------

  def set_interactive_rects
    @checkbox_rect = Rect.new(CHECKBOX_X, (height - CHECKBOX_HEIGHT) / 2,
                              CHECKBOX_WIDTH, CHECKBOX_HEIGHT)
    @interactions = {
      :checkbox => @checkbox_rect
    }
  end

  #-----------------------------------------------------------------------------

  def draw_background
    bg_color = (disabled?) ? :disabled_fill : :control_background
    self.bitmap.fill_rect(@checkbox_rect.x, @checkbox_rect.y,
                          @checkbox_rect.width, @checkbox_rect.height,
                          get_color_of(bg_color))
  end

  def refresh
    super
    # Draw checkbox outline
    self.bitmap.outline_rect(@checkbox_rect.x, @checkbox_rect.y,
                             @checkbox_rect.width, @checkbox_rect.height,
                             get_color_of(:line))
    # Draw checkbox fill
    box_x = (@value) ? @checkbox_rect.width - CHECKBOX_FILL_SIZE - 2 : 2
    if disabled?
      box_color = get_color_of(:disabled_text)
    else
      box_color = (@value) ? get_color_of(:checked) : get_color_of(:unchecked)
    end
    self.bitmap.fill_rect(@checkbox_rect.x + box_x, @checkbox_rect.y + 2,
                          CHECKBOX_FILL_SIZE, CHECKBOX_FILL_SIZE, box_color)
    self.bitmap.outline_rect(@checkbox_rect.x + box_x, @checkbox_rect.y + 2,
                             CHECKBOX_FILL_SIZE, CHECKBOX_FILL_SIZE, get_color_of(:line))
  end

  #-----------------------------------------------------------------------------

  def on_mouse_release
    return if !@captured_area   # Wasn't captured to begin with
    # Change this control's value
    if @captured_area == :checkbox
      mouse_x, mouse_y = mouse_pos
      if mouse_x && mouse_y && @interactions[@captured_area].contains?(mouse_x, mouse_y)
        @value = !@value   # The actual change of this control's value
        set_changed
      end
    end
    super   # Make this control not busy again
  end
end

#===============================================================================
#
#===============================================================================
class UIControls::NumberSlider < UIControls::BaseControl
  attr_reader :min_value
  attr_reader :max_value

  PLUS_MINUS_SIZE = 16
  SLIDER_PADDING  = 6   # Gap between sides of interactive area for slider and drawn slider bar
  MINUS_X         = 0
  SLIDER_X        = MINUS_X + PLUS_MINUS_SIZE + SLIDER_PADDING
  SLIDER_LENGTH   = 128
  PLUS_X          = SLIDER_X + SLIDER_LENGTH + SLIDER_PADDING
  VALUE_X         = PLUS_X + PLUS_MINUS_SIZE + 5

  def initialize(width, height, viewport, min_value, max_value, value)
    super(width, height, viewport)
    @min_value = min_value
    @max_value = max_value
    self.value = value
  end

  #-----------------------------------------------------------------------------

  def value=(new_value)
    old_val = @value
    @value = new_value.to_i.clamp(self.min_value, self.max_value)
    self.invalidate if @value != old_val
  end

  def min_value=(new_min)
    return if new_min == @min_value
    @min_value = new_min
    @value = @value.clamp(self.min_value, self.max_value)
    self.invalidate
  end

  def max_value=(new_max)
    return if new_max == @max_value
    @max_value = new_max
    @value = @value.clamp(self.min_value, self.max_value)
    self.invalidate
  end

  #-----------------------------------------------------------------------------

  def set_interactive_rects
    @slider_rect = Rect.new(SLIDER_X - SLIDER_PADDING, (self.height - PLUS_MINUS_SIZE) / 2, SLIDER_LENGTH + (SLIDER_PADDING * 2), PLUS_MINUS_SIZE)
    @minus_rect = Rect.new(MINUS_X, (self.height - PLUS_MINUS_SIZE) / 2, PLUS_MINUS_SIZE, PLUS_MINUS_SIZE)
    @plus_rect = Rect.new(PLUS_X, (self.height - PLUS_MINUS_SIZE) / 2, PLUS_MINUS_SIZE, PLUS_MINUS_SIZE)
    @interactions = {
      :slider => @slider_rect,
      :minus  => @minus_rect,
      :plus   => @plus_rect
    }
  end

  #-----------------------------------------------------------------------------

  def draw_area_highlight
    # Don't want to ever highlight the slider with the capture color, because
    # the mouse doesn't need to be on the slider to change this control's value
    if @captured_area == :slider
      rect = @interactions[@captured_area]
      self.bitmap.fill_rect(rect.x, rect.y, rect.width, rect.height, get_color_of(:hover)) if rect
    else
      super
    end
  end

  def refresh
    super
    button_color = (disabled?) ? get_color_of(:disabled_text) : get_color_of(:text)
    # Draw minus button
    self.bitmap.fill_rect(@minus_rect.x + 2, @minus_rect.y + (@minus_rect.height / 2) - 2, @minus_rect.width - 4, 4, button_color)
    # Draw slider bar
    self.bitmap.fill_rect(SLIDER_X, (self.height / 2) - 1, SLIDER_LENGTH, 2, get_color_of(:text))
    # Draw notches on slider bar
    5.times do |i|
      self.bitmap.fill_rect(SLIDER_X - 1 + (i * SLIDER_LENGTH / 4), (self.height / 2) - 2, 2, 4, get_color_of(:text))
    end
    # Draw slider knob
    fraction = (self.value - self.min_value) / (self.max_value.to_f - self.min_value)
    knob_x = (SLIDER_LENGTH * fraction).to_i
    self.bitmap.fill_rect(SLIDER_X + knob_x - 4, (self.height / 2) - 6, 8, 12, button_color)
    # Draw plus button
    self.bitmap.fill_rect(@plus_rect.x + 2, @plus_rect.y + (@plus_rect.height / 2) - 2, @plus_rect.width - 4, 4, button_color)
    self.bitmap.fill_rect(@plus_rect.x + (@plus_rect.width / 2) - 2, @plus_rect.y + 2, 4, @plus_rect.height - 4, button_color)
    # Draw value text
    draw_text(self.bitmap, VALUE_X, TEXT_OFFSET_Y, self.value.to_s)
  end

  #-----------------------------------------------------------------------------

  def on_mouse_press
    super
    @initial_value = @value if @captured_area
  end

  def on_mouse_release
    return if !@captured_area   # Wasn't captured to begin with
    set_changed if @initial_value && @value != @initial_value
    @initial_value = nil
    super
  end

  def update
    return if !self.visible
    super
    case @captured_area
    when :minus
      # Constant decrement of value while pressing the minus button
      if @hover_area == @captured_area && Input.repeat?(Input::MOUSELEFT)
        increment = (Input.pressex?(:LCTRL) || Input.pressex?(:RCTRL)) ? 10 : 1
        self.value -= increment
      end
    when :plus
      # Constant incrementing of value while pressing the plus button
      if @hover_area == @captured_area && Input.repeat?(Input::MOUSELEFT)
        increment = (Input.pressex?(:LCTRL) || Input.pressex?(:RCTRL)) ? 10 : 1
        self.value += increment
      end
    when :slider
      # Constant updating of value depending on mouse's x position
      mouse_x, mouse_y = mouse_pos
      return if !mouse_x || !mouse_y
      self.value = lerp(self.min_value, self.max_value + (self.max_value & 1), SLIDER_LENGTH, mouse_x - SLIDER_X)
    end
  end
end

#===============================================================================
#
#===============================================================================
class UIControls::Scrollbar < UIControls::BaseControl
  attr_reader :tray_size, :range, :slider_top, :slider_size

  SLIDER_WIDTH    = 16
  WIDTH_PADDING   = 0
  SCROLL_DISTANCE = 32

  def initialize(size, viewport, direction = :vertical, always_visible = false)
    if direction == :horizontal
      super(size, SLIDER_WIDTH, viewport)
    else
      super(SLIDER_WIDTH, size, viewport)
    end
    @direction      = direction   # Is :vertical or :horizontal
    @tray_size      = size   # Number of pixels the scrollbar can move around in
    @slider_size    = size
    @range          = size   # Total distance of the area this scrollbar is for
    @slider_top     = 0      # Top pixel within @size of the scrollbar
    @always_visible = always_visible
    self.visible    = @always_visible
  end

  #-----------------------------------------------------------------------------

  # Range is the total size of the large area that the scrollbar is able to
  # show part of.
  def range=(new_val)
    raise "Can't set a scrollbar's range to 0!" if new_val == 0
    @range = new_val
    @slider_size = (@tray_size * [@tray_size.to_f / @range, 1].min).round
    if @direction == :horizontal
      @slider.width = @slider_size
    else   # Vertical
      @slider.height = @slider_size
    end
    self.slider_top = @slider_top
    self.visible = (@always_visible || can_scroll?)
    invalidate
  end

  def slider_top=(new_val)
    old_val = @slider_top
    @slider_top = new_val.clamp(0, @tray_size - @slider_size)
    if @direction == :horizontal
      @slider.x = @slider_top
    else   # Vertical
      @slider.y = @slider_top
    end
    invalidate if @slider_top != old_val
  end

  def position
    return 0 if @range <= @tray_size
    return (@range - @tray_size) * @slider_top / (@tray_size - @slider_size)
  end

  def minimum?
    return @slider_top <= 0
  end

  def maximum?
    return @slider_top >= @tray_size - @slider_size
  end

  def can_scroll?
    return @range > @tray_size
  end

  def wheel_scroll_distance
    # 2 is generally a couple of row heights if used in a list
    return [SCROLL_DISTANCE, @tray_size / 4, [@slider_size - 2, 1].max].min
  end

  #-----------------------------------------------------------------------------

  def set_interactive_rects
    @interactions = {}
    if @direction == :horizontal
      @slider = Rect.new(@slider_top, WIDTH_PADDING, @slider_size, height - (WIDTH_PADDING * 2))
    else   # Vertical
      @slider = Rect.new(WIDTH_PADDING, @slider_top, width - (WIDTH_PADDING * 2), @slider_size)
    end
    @interactions[:slider] = @slider
    @slider_tray = Rect.new(0, 0, width, height)
    @interactions[:slider_tray] = @slider_tray
  end

  #-----------------------------------------------------------------------------

  def draw_background
    self.bitmap.fill_rect(@slider_tray.x, @slider_tray.y,
                          @slider_tray.width, @slider_tray.height,
                          get_color_of(:control_background))
  end

  def refresh
    super
    return if !self.visible
    # Draw the slider
    if @slider_size < @tray_size && !disabled?
      bar_color = get_color_of(:text)
      if @captured_area == :slider || (!@captured_area && @hover_area == :slider)
        bar_color = get_color_of(:hover)
      end
      self.bitmap.fill_rect(@slider.x, @slider.y, @slider.width, @slider.height, bar_color)
    end
  end

  #-----------------------------------------------------------------------------

  def on_mouse_press
    @captured_area = nil
    mouse_x, mouse_y = mouse_pos
    return if !mouse_x || !mouse_y
    # Check for mouse presses on slider/slider tray
    @interactions.each_pair do |area, rect|
      next if !rect.contains?(mouse_x, mouse_y)
      @captured_area = area
      if area == :slider
        if @direction == :horizontal
          @slider_mouse_offset = mouse_x - rect.x
        else
          @slider_mouse_offset = mouse_y - rect.y
        end
      end
      invalidate
      break
    end
  end

  def on_mouse_release
    super if @captured_area
  end

  def update
    return if !self.visible
    super
    if @captured_area == :slider
      mouse_x, mouse_y = mouse_pos
      return if !mouse_x || !mouse_y
      long_coord = (@direction == :horizontal) ? mouse_x : mouse_y
      self.slider_top = long_coord - @slider_mouse_offset
    elsif @captured_area == :slider_tray
      if Input.repeat?(Input::MOUSELEFT) && @hover_area == :slider_tray
        mouse_x, mouse_y = mouse_pos
        return if !mouse_x || !mouse_y
        long_coord = (@direction == :horizontal) ? mouse_x : mouse_y
        if long_coord < @slider_top
          self.slider_top = @slider_top - ((@tray_size - @slider_size) / 4.0).ceil
        else
          self.slider_top = @slider_top + ((@tray_size - @slider_size) / 4.0).ceil
        end
      end
    elsif !disabled?
      mouse_x, mouse_y = mouse_pos
      if mouse_x && mouse_y && @interactions[:slider_tray].contains?(mouse_x, mouse_y)
        wheel_v = Input.scroll_v
        if wheel_v != 0
          dist = wheel_scroll_distance
          if wheel_v > 0   # Scroll up
            self.slider_top -= dist
          elsif wheel_v < 0   # Scroll down
            self.slider_top += dist
          end
        end
      end
    end
  end
end
