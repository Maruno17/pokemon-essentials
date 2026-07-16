#===============================================================================
#
#===============================================================================
class UIControls::FittedHexNumberTextBox < UIControls::HexNumberTextBox
  def set_interactive_rects
    @text_box_rect = Rect.new(TEXT_BOX_X, (height - TEXT_BOX_HEIGHT) / 2,
                              width - (TEXT_BOX_X * 2), TEXT_BOX_HEIGHT)
    @interactions = {
      :text_box => @text_box_rect
    }
  end
end
