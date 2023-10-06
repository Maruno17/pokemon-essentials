#===============================================================================
# TODO: Do I need to split self's bitmap into two (one for highlights and one
#       for text)? This would be to reduce lag caused by redrawing text even if
#       you're just waving the mouse over the control. There doesn't seem to be
#       any lag at the moment with a tall list.
# TODO: Make a viewport for the list, and allow scrolling positions halfway
#       through a line? Nah.
#===============================================================================
class UIControls::List < UIControls::BaseControl
  LIST_X = 0
  LIST_Y = 0
  ROW_HEIGHT = 24
  TEXT_PADDING_X = 4
  TEXT_OFFSET_Y  = 3

  SELECTED_ROW_COLOR = Color.green

  def initialize(width, height, viewport, values = [])
    super(width, height, viewport)
    @slider = UIControls::Scrollbar.new(LIST_X + width - UIControls::Scrollbar::SLIDER_WIDTH, LIST_Y, height, viewport)
    @slider.set_interactive_rects
    @slider.range = ROW_HEIGHT
    @slider.z = self.z + 1
    @rows_count = (height / ROW_HEIGHT).floor   # Number of rows visible at once
    @top_row  = 0
    @selected = -1
    self.values = values
  end

  def dispose
    @slider.dispose
    @slider = nil
    super
  end

  def x=(new_val)
    super(new_val)
    @slider.x = new_val + LIST_X + width - UIControls::Scrollbar::SLIDER_WIDTH
  end

  def y=(new_val)
    super(new_val)
    @slider.y = new_val + LIST_Y
  end

  # Each value in @values is an array: [id, text].
  def values=(new_vals)
    @values = new_vals
    set_interactive_rects
    @slider.range = @values.length * ROW_HEIGHT
    if @slider.visible
      self.top_row = (@slider.position.to_f / ROW_HEIGHT).round
    else
      self.top_row = 0
    end
    self.selected = -1 if @selected >= @values.length
    invalidate
  end

  def top_row=(val)
    old_val = @top_row
    @top_row = val
    if @slider.visible
      @top_row = @top_row.clamp(0, @values.length - @rows_count)
    else
      @top_row = 0
    end
    invalidate if @top_row != old_val
  end

  def selected=(val)
    return if @selected == val
    @selected = val
    invalidate
  end

  # Returns the ID of the selected row.
  def value
    return nil if @selected < 0
    return @values[@selected][0]
  end

  def set_interactive_rects
    @interactions = {}
    @values.length.times do |i|
      @interactions[i] = Rect.new(LIST_X, LIST_Y + (ROW_HEIGHT * i), width - LIST_X, ROW_HEIGHT)
    end
  end

  #-----------------------------------------------------------------------------

  def busy?
    return !@captured_area.nil?
  end

  #-----------------------------------------------------------------------------

  def draw_area_highlight
    # If a row is captured, it will automatically be selected and the selection
    # colour will be drawn over the highlight. There's no point drawing a
    # highlight at all if anything is captured.
    return if @captured_area
    # Draw mouse hover over row highlight
    rect = @interactions[@hover_area]
    if rect
      rect_y = rect.y
      rect_y -= @top_row * ROW_HEIGHT if @hover_area.is_a?(Integer)
      self.bitmap.fill_rect(rect.x, rect_y, rect.width, rect.height, HOVER_COLOR)
    end
  end

  def repaint
    @slider.repaint if @slider.invalid?
    super if invalid?
  end

  def refresh
    super
    # Draw text options
    @values.each_with_index do |val, i|
      next if i < @top_row || i >= @top_row + @rows_count
      if @selected == i
        self.bitmap.fill_rect(
           @interactions[i].x,
           @interactions[i].y - (@top_row * ROW_HEIGHT),
           @interactions[i].width, @interactions[i].height,
           SELECTED_ROW_COLOR
         )
      end
      draw_text(self.bitmap,
                @interactions[i].x + TEXT_PADDING_X,
                @interactions[i].y + TEXT_OFFSET_Y - (@top_row * ROW_HEIGHT),
                val[1])
    end
  end

  #-----------------------------------------------------------------------------

  def on_mouse_press
    @captured_area = nil
    mouse_x, mouse_y = mouse_pos
    return if !mouse_x || !mouse_y
    return if @slider.visible && (@slider.busy? || mouse_x >= @slider.x - self.x)
    # Check for mouse presses on rows
    mouse_y += @top_row * ROW_HEIGHT
    @interactions.each_pair do |area, rect|
      next if !area.is_a?(Integer) || area < @top_row || area >= @top_row + @rows_count
      next if !rect.contains?(mouse_x, mouse_y)
      @captured_area = area
      invalidate
      break
    end
  end

  def on_mouse_release
    return if !@captured_area   # Wasn't captured to begin with
    set_changed
    super
  end

  def update_hover_highlight
    # Remove the hover highlight if there are no interactions for this control
    # or if the mouse is off-screen
    mouse_x, mouse_y = mouse_pos
    if !@interactions || @interactions.empty? || !mouse_x || !mouse_y
      invalidate if @hover_area
      @hover_area = nil
      return
    end
    # Don't update the highlight if the mouse is using the scrollbar
    if @slider.visible && (@slider.busy? || mouse_x >= @slider.x - self.x)
      invalidate if @hover_area
      @hover_area = nil
      return
    end
    # Check each interactive area for whether the mouse is hovering over it, and
    # set @hover_area accordingly
    in_area = false
    mouse_y += @top_row * ROW_HEIGHT
    @interactions.each_pair do |area, rect|
      next if !area.is_a?(Integer) || area < @top_row || area >= @top_row + @rows_count
      next if !rect.contains?(mouse_x, mouse_y)
      invalidate if @hover_area != area
      @hover_area = area
      in_area = true
      break
    end
    if !in_area
      invalidate if @hover_area
      @hover_area = nil
    end
  end

  def update
    return if !self.visible
    @slider.update
    super
    # TODO: Disabled control stuff.
#    return if self.disabled
    # Refresh the list's position if changed by moving the slider
    self.top_row = (@slider.position.to_f / ROW_HEIGHT).round
    # Set the selected row to the row the mouse is over, if clicked on
    if @captured_area
      @selected = @hover_area if @hover_area.is_a?(Integer)
    end
  end
end
