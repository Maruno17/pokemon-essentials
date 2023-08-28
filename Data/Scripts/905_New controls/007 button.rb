#===============================================================================
#
#===============================================================================
class UIControls::Button < UIControls::BaseControl
  BUTTON_X       = 2
  BUTTON_PADDING = 10
  BUTTON_HEIGHT  = 28
  TEXT_OFFSET_Y  = 7

  def initialize(width, height, viewport, text = "")
    super(width, height, viewport)
    @text = text
  end

  def set_interactive_rects
    text_width = self.bitmap.text_size(@text).width
    @button_rect = Rect.new(BUTTON_X, (height - BUTTON_HEIGHT) / 2,
                            text_width + (BUTTON_PADDING * 2), BUTTON_HEIGHT)
    @interactions = {
      :button => @button_rect
    }
  end

  #-----------------------------------------------------------------------------

  # TODO: Make buttons look more different to text boxes?
  def refresh
    super
    # Draw button outline
    self.bitmap.outline_rect(@button_rect.x, @button_rect.y,
                             @button_rect.width, @button_rect.height,
                             self.bitmap.font.color)
    # Draw button text
    draw_text(self.bitmap, BUTTON_X + BUTTON_PADDING, TEXT_OFFSET_Y, @text)
  end

  #-----------------------------------------------------------------------------

  def on_mouse_release
    return if !@captured_area   # Wasn't captured to begin with
    # Change this control's value
    if @captured_area == :button
      mouse_x, mouse_y = mouse_pos
      if mouse_x && mouse_y &&  @interactions[@captured_area].contains?(mouse_x, mouse_y)
        set_changed
      end
    end
    super   # Make this control not busy again
  end
end
