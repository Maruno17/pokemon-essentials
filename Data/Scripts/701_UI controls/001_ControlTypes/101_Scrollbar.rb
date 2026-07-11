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
          dist = [SCROLL_DISTANCE, @tray_size / 4].min
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
