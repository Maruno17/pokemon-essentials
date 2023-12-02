#===============================================================================
#
#===============================================================================
class UIControls::Label < UIControls::BaseControl
  attr_reader :text

  LABEL_END_X   = 80
  TEXT_OFFSET_Y = 5

  def initialize(width, height, viewport, text)
    super(width, height, viewport)
    @text = text
    @header = false
  end

  def text=(value)
    @text = value
    refresh
  end

  def header=(val)
    @header = val
    refresh
  end

  def refresh
    super
    if @header
      draw_text_centered(self.bitmap, 0, TEXT_OFFSET_Y, width, @text)
      text_size = self.bitmap.text_size(@text)
      self.bitmap.fill_rect((width - text_size.width) / 2, TEXT_OFFSET_Y + text_size.height, text_size.width, 1, TEXT_COLOR)
    else
      draw_text(self.bitmap, 4, TEXT_OFFSET_Y, @text)
    end
  end
end
