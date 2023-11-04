#===============================================================================
#
#===============================================================================
class UIControls::Label < UIControls::BaseControl
  attr_reader :label

  LABEL_END_X   = 80
  TEXT_OFFSET_Y = 5

  def initialize(width, height, viewport, label)
    super(width, height, viewport)
    @label = label
    @header = false
  end

  def label=(value)
    @label = value
    refresh
  end

  def header=(val)
    @header = val
    refresh
  end

  def refresh
    super
    if @header
      draw_text_centered(self.bitmap, 0, TEXT_OFFSET_Y, width, @label)
      text_size = self.bitmap.text_size(@label)
      self.bitmap.fill_rect((width - text_size.width) / 2, TEXT_OFFSET_Y + text_size.height, text_size.width, 1, TEXT_COLOR)
    else
      draw_text(self.bitmap, 4, TEXT_OFFSET_Y, @label)
    end
  end
end
