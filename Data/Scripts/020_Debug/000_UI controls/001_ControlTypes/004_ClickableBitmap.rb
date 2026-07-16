#===============================================================================
# An area that can be clicked on. It uses a bitmap as a graphic, and has a
# number of states equal to the number of bitmaps given to it. Its state (value)
# cycles through each of them in order. Assumes all bitmaps are the same size.
# Whether the bitmap highlights itself when hovered over/clicked on can be set
# by the "highlight" variable.
#===============================================================================
class UIControls::ClickableBitmap < UIControls::BaseControl
  attr_accessor :highlight

  def initialize(viewport, *bitmaps)
    @bitmaps = bitmaps
    @highlight = true
    @value = 0
    super(@bitmaps.first.width, @bitmaps.first.height, viewport)
  end

  #-----------------------------------------------------------------------------

  def value=(new_value)
    return if @value == new_value
    @value = new_value
    invalidate
  end

  #-----------------------------------------------------------------------------

  def set_interactive_rects
    @area_rect = Rect.new(0, 0, width, height)
    @interactions = {
      :area => @area_rect
    }
  end

  #-----------------------------------------------------------------------------

  def draw_area_highlight
    return if !@highlight
    super
  end

  def refresh
    super
    # Draw bitmap
    this_bitmap = @bitmaps[@value % @bitmaps.length]
    if this_bitmap
      self.bitmap.blt(0, 0, this_bitmap,
                      Rect.new(0, 0, this_bitmap.width, this_bitmap.height))
    end
  end

  #-----------------------------------------------------------------------------

  def on_mouse_release
    return if !@captured_area   # Wasn't captured to begin with
    # Change this control's value
    if @captured_area == :area && @bitmaps.length > 1
      mouse_x, mouse_y = mouse_pos
      if mouse_x && mouse_y && @interactions[@captured_area].contains?(mouse_x, mouse_y)
        @value = (@value + 1) % @bitmaps.length   # The actual change of this control's value
        set_changed
      end
    end
    super   # Make this control not busy again
  end
end
