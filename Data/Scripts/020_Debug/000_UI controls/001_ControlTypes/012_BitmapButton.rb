#===============================================================================
#
#===============================================================================
class UIControls::BitmapButton < UIControls::Button
  def initialize(viewport, button_bitmap, disabled_bitmap = nil)
    super(button_bitmap.width + (BUTTON_FRAME_THICKNESS * 2),
          button_bitmap.height + (BUTTON_FRAME_THICKNESS * 2), viewport)
    @button_bitmap = button_bitmap
    @disabled_bitmap = disabled_bitmap
  end

  #-----------------------------------------------------------------------------

  def set_interactive_rects
    @interactions&.clear
    @button_rect = Rect.new(0, 0, width, height)
    @interactions = {
      :button => @button_rect
    }
  end

  #-----------------------------------------------------------------------------

  def refresh
    super
    # Draw button bitmap
    if @disabled_bitmap && disabled?
      self.bitmap.blt(BUTTON_FRAME_THICKNESS, BUTTON_FRAME_THICKNESS, @disabled_bitmap,
                      Rect.new(0, 0, @disabled_bitmap.width, @disabled_bitmap.height))
    else
      self.bitmap.blt(BUTTON_FRAME_THICKNESS, BUTTON_FRAME_THICKNESS, @button_bitmap,
                      Rect.new(0, 0, @button_bitmap.width, @button_bitmap.height))
    end
  end
end
