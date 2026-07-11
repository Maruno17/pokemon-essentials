#===============================================================================
# A simple control that designates a rectangular area and detects when it has
# been clicked in. The highlight parameter determines whether the area
# highlights when hovered over or clicked on.
#===============================================================================
class UIControls::ClickableArea < UIControls::BaseControl
  attr_accessor :changed_upon_click

  def initialize(width, height, viewport, highlight = true, can_right_click = false)
    super(width, height, viewport)
    @highlight = highlight
    @can_right_click = can_right_click
    @changed_upon_click = false
  end

  #-----------------------------------------------------------------------------

  def left_clicked?
    return @input == Input::MOUSELEFT
  end

  def right_clicked?
    return @input == Input::MOUSERIGHT
  end

  def make_not_busy
    @input = nil
    @captured_area = nil
  end

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

  #-----------------------------------------------------------------------------

  def on_mouse_press
    was_captured = busy?
    super
    if !was_captured && busy? && @changed_upon_click
      set_changed
    end
  end

  def on_mouse_release
    return if !@captured_area   # Wasn't captured to begin with
    # Change this control's value
    if @captured_area == :area && !@changed_upon_click
      mouse_x, mouse_y = mouse_pos
      if mouse_x && mouse_y && @interactions[@captured_area].contains?(mouse_x, mouse_y)
        set_changed
      end
    end
    super   # Make this control not busy again
  end

  def on_mouse_right_press
    on_mouse_press
  end

  def on_mouse_right_release
    on_mouse_release
  end

  # Updates the logic on the control, invalidating it if necessary.
  def update
    return if !self.visible
    return if disabled? && !busy?   # This control still works if it becomes disabled while using it
    update_hover_highlight
    # Detect a mouse press/release
    if @interactions && !@interactions.empty?
      if Input.trigger?(Input::MOUSELEFT)
        @input = Input::MOUSELEFT
        on_mouse_press
      elsif busy? && Input.release?(Input::MOUSELEFT)
        on_mouse_release
        @input = nil
      elsif Input.trigger?(Input::MOUSERIGHT) && @can_right_click
        @input = Input::MOUSERIGHT
        on_mouse_right_press
      elsif busy? && Input.release?(Input::MOUSERIGHT) && @can_right_click
        on_mouse_right_release
        @input = nil
      end
    end
  end
end
