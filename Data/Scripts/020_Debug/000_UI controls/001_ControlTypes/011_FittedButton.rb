#===============================================================================
# A text button, but its width changes to fit the text on it. The height is a
# constant.
# TODO: Changing the text won't change the size of the bitmap.
#===============================================================================
class UIControls::FittedButton < UIControls::Button
  BUTTON_PADDING = 10
  BUTTON_HEIGHT  = 28

  def set_text(val)
    super(val)
    set_interactive_rects
  end

  #-----------------------------------------------------------------------------

  def set_interactive_rects
    @interactions&.clear
    button_width = self.bitmap.text_size(@text).width + (BUTTON_PADDING * 2)
    button_height = BUTTON_HEIGHT
    button_height = [button_height, height - (2 * BUTTON_Y)].min
    @button_rect = Rect.new(BUTTON_X, (height - button_height) / 2, button_width, button_height)
    @interactions = {
      :button => @button_rect
    }
  end
end
