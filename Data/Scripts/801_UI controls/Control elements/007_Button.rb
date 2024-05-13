#===============================================================================
#
#===============================================================================
class UIControls::Button < UIControls::BaseControl
  BUTTON_X           = 2
  BUTTON_Y           = 2
  BUTTON_PADDING     = 10   # Used when @fixed_size is false
  BUTTON_HEIGHT      = 28   # Used when @fixed_size is false
  TEXT_BASE_OFFSET_Y = 18   # Text is centred vertically in the button

  def initialize(width, height, viewport, text = "")
    super(width, height, viewport)
    @text = text
    @fixed_size = false
    @highlight = false
  end

  #-----------------------------------------------------------------------------

  def set_fixed_size
    @fixed_size = true
  end

  def set_text(val)
    return if @text == val
    @text = val
    set_interactive_rects if !@fixed_size
    invalidate
  end

  #-----------------------------------------------------------------------------

  def disabled?
    return highlighted? || super
  end

  def set_changed
    @value = true
    super
  end

  def clear_changed
    @value = false
    super
  end

  def highlighted?
    return @highlight
  end

  def set_highlighted
    return if highlighted?
    @highlight = true
    invalidate
  end

  def set_not_highlighted
    return if !highlighted?
    @highlight = false
    invalidate
  end

  #-----------------------------------------------------------------------------

  def set_interactive_rects
    @interactions&.clear
    button_width = (@fixed_size) ? width - (BUTTON_X * 2) : self.bitmap.text_size(@text).width + (BUTTON_PADDING * 2)
    button_height = (@fixed_size) ? height - (2 * BUTTON_Y) : BUTTON_HEIGHT
    button_height = [button_height, height - (2 * BUTTON_Y)].min
    @button_rect = Rect.new(BUTTON_X, (height - button_height) / 2, button_width, button_height)
    @interactions = {
      :button => @button_rect
    }
  end

  #-----------------------------------------------------------------------------

  def refresh
    super
    if highlighted?
      # Draw highligted colour
      self.bitmap.fill_rect(@button_rect.x, @button_rect.y,
                            @button_rect.width, @button_rect.height,
                            highlight_color)
    elsif disabled?
      # Draw disabled colour
      self.bitmap.fill_rect(@button_rect.x, @button_rect.y,
                            @button_rect.width, @button_rect.height,
                            disabled_fill_color)
    end
    # Draw button outline
    self.bitmap.outline_rect(@button_rect.x, @button_rect.y,
                             @button_rect.width, @button_rect.height,
                             line_color)
    # Draw inner grey ring that shows this is a button rather than a text box
    if !disabled?
      shade = line_color.clone
      shade.alpha = (shade.red > 128) ? 160 : 64
      self.bitmap.outline_rect(@button_rect.x + 2, @button_rect.y + 2,
                               @button_rect.width - 4, @button_rect.height - 4,
                               shade, 1)
    end
    # Draw button text
    draw_text_centered(self.bitmap, @button_rect.x,
                       @button_rect.y + (@button_rect.height - TEXT_BASE_OFFSET_Y) / 2,
                       @button_rect.width, @text)
  end

  #-----------------------------------------------------------------------------

  def on_mouse_release
    return if !@captured_area   # Wasn't captured to begin with
    # Change this control's value
    if @captured_area == :button
      mouse_x, mouse_y = mouse_pos
      if mouse_x && mouse_y && @interactions[@captured_area].contains?(mouse_x, mouse_y)
        set_changed
      end
    end
    super   # Make this control not busy again
  end
end
