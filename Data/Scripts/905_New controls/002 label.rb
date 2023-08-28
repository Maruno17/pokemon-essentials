#===============================================================================
#
#===============================================================================
class UIControls::Label < UIControls::BaseControl
  attr_reader :label

  LABEL_END_X   = 80
  TEXT_OFFSET_Y = 7

  def initialize(width, height, viewport, label)
    super(width, height, viewport)
    @label = label
  end

  def label=(value)
    @label = value
    refresh
  end

  def refresh
    super
    draw_text(self.bitmap, 4, TEXT_OFFSET_Y, @label)
  end
end
