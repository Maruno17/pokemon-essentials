#===============================================================================
#
#===============================================================================
class UIControls::Button < UIControls::BaseControl
  BUTTON_X           = 2
  BUTTON_Y           = 2
  BUTTON_PADDING     = 10
  BUTTON_HEIGHT      = 28
  # TODO: This will also depend on the font size.
  TEXT_BASE_OFFSET_Y = 18   # Text is centred vertically in the button

  def initialize(width, height, viewport, text = "")
    super(width, height, viewport)
    @text = text
    @fixed_size = false
  end

  def set_fixed_size
    @fixed_size = true
  end

  def set_interactive_rects
    button_width = (@fixed_size) ? width - (BUTTON_X * 2) : self.bitmap.text_size(@text).width + (BUTTON_PADDING * 2)
    button_height = (@fixed_size) ? height - (2 * BUTTON_Y) : BUTTON_HEIGHT
    button_height = [button_height, height - (2 * BUTTON_Y)].min
    @button_rect = Rect.new(BUTTON_X, (height - button_height) / 2, button_width, button_height)
    @interactions = {
      :button => @button_rect
    }
  end

  # TODO: This won't change the button's size. This is probably okay.
  def set_text(val)
    return if @text == val
    @text = val
    invalidate
  end

  def set_changed
    @value = true
    super
  end

  def clear_changed
    @value = false
    super
  end

  #-----------------------------------------------------------------------------

  def refresh
    super
    # Draw button outline
    self.bitmap.outline_rect(@button_rect.x, @button_rect.y,
                             @button_rect.width, @button_rect.height,
                             self.bitmap.font.color)
    # TODO: Make buttons look more different to text boxes?
    # shade = self.bitmap.font.color.clone
    # shade.alpha = 96
    # self.bitmap.outline_rect(@button_rect.x + 1, @button_rect.y + 1,
    #                          @button_rect.width - 2, @button_rect.height - 2,
    #                          shade, 3)
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
