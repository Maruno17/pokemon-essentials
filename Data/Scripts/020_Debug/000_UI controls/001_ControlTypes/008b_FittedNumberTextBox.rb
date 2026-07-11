#===============================================================================
#
#===============================================================================
class UIControls::FittedNumberTextBox < UIControls::NumberTextBox
  def set_interactive_rects
    @text_box_rect = Rect.new(TEXT_BOX_X, (height - TEXT_BOX_HEIGHT) / 2,
                              width - (TEXT_BOX_X * 2) - ARROW_WIDTH, TEXT_BOX_HEIGHT)
    @plus_rect = Rect.new(width - ARROW_WIDTH, @text_box_rect.y, ARROW_WIDTH, TEXT_BOX_HEIGHT / 2)
    @minus_rect = Rect.new(width - ARROW_WIDTH, @text_box_rect.y + (TEXT_BOX_HEIGHT / 2), ARROW_WIDTH, TEXT_BOX_HEIGHT / 2)
    @interactions = {
      :text_box => @text_box_rect,
      :plus => @plus_rect,
      :minus => @minus_rect
    }
  end
end
