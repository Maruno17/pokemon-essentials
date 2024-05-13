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
      self.bitmap.fill_rect(rect.x, rect.y, rect.width, rect.height, hover_color) if rect
    else
      super
    end
  end

  def refresh
    super
    button_color = (disabled?) ? disabled_text_color : text_color
    # Draw minus button
    self.bitmap.fill_rect(@minus_rect.x + 2, @minus_rect.y + (@minus_rect.height / 2) - 2, @minus_rect.width - 4, 4, button_color)
    # Draw slider bar
    self.bitmap.fill_rect(SLIDER_X, (self.height / 2) - 1, SLIDER_LENGTH, 2, text_color)
    # Draw notches on slider bar
    5.times do |i|
      self.bitmap.fill_rect(SLIDER_X - 1 + (i * SLIDER_LENGTH / 4), (self.height / 2) - 2, 2, 4, text_color)
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
        self.value -= 1
      end
    when :plus
      # Constant incrementing of value while pressing the plus button
      if @hover_area == @captured_area && Input.repeat?(Input::MOUSELEFT)
        self.value += 1
      end
    when :slider
      # Constant updating of value depending on mouse's x position
      mouse_x, mouse_y = mouse_pos
      return if !mouse_x || !mouse_y
      self.value = lerp(self.min_value, self.max_value + (self.max_value & 1), SLIDER_LENGTH, mouse_x - SLIDER_X)
    end
  end
end
