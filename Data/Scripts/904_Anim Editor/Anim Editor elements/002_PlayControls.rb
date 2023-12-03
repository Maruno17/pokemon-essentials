#===============================================================================
# TODO
#===============================================================================
class AnimationEditor::PlayControls < UIControls::BaseControl
  def initialize(x, y, width, height, viewport)
    super(width, height, viewport)
    self.x = x
    self.y = y
    @duration = 0
  end

  def duration=(new_val)
    return if @duration == new_val
    @duration = new_val
    refresh
  end

  #-----------------------------------------------------------------------------

  def refresh
    super
    draw_text(self.bitmap, 12, TEXT_OFFSET_Y + 14, _INTL("Play controls not added yet!"))
    draw_text(self.bitmap, width - 134, TEXT_OFFSET_Y, _INTL("Total length: {1}s", @duration / 20.0))
  end
end
