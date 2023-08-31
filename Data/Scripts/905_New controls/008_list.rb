#===============================================================================
# TODO: Do I need to split self's bitmap into two (one for highlights and one
#       for text/slider)? This would be to reduce lag caused by redrawing text
#       and the slider even if you're just waving the mouse over the control.
#       There doesn't seem to be any lag at the moment with a tall list.
#===============================================================================
class UIControls::List < UIControls::BaseControl
  LIST_X = 0
  LIST_Y = 0
  ROW_HEIGHT = 24
  TEXT_PADDING_X = 4
  TEXT_OFFSET_Y  = 3
  SLIDER_WIDTH = 16

  SELECTED_ROW_COLOR = Color.green

  def initialize(width, height, viewport, values = [])
    super(width, height, viewport)
    @rows_count = (height / ROW_HEIGHT).floor   # Number of rows visible at once
    @top_row  = 0
    @selected = -1
    @show_slider = false
    self.values = values
  end

  # Each value in @values is an array: [id, text].
  def values=(new_vals)
    @values = new_vals
    @show_slider = (@values.length > @rows_count)
    set_interactive_rects
    if @show_slider
      self.top_row = @top_row
    else
      self.top_row = 0
    end
    invalidate
  end

  def top_row=(val)
    old_val = @top_row
    @top_row = val
    if @show_slider
      @top_row = @top_row.clamp(0, @values.length - @rows_count)
      @slider.y = lerp(0, height - @slider.height, @values.length - @rows_count, 0, @top_row).round
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
    @slider = nil
    if @show_slider
      @slider = Rect.new(LIST_X + width - SLIDER_WIDTH, LIST_Y,
                         SLIDER_WIDTH, height * @rows_count / @values.length)
      @interactions[:slider] = @slider
      @slider_tray = Rect.new(LIST_X + width - SLIDER_WIDTH, LIST_Y, SLIDER_WIDTH, height)
      @interactions[:slider_tray] = @slider_tray
    end
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
    # colour will be drawn over the highlight. The slider tray background
    # (white) is drawn over the slider/slider tray's highlight. Either way,
    # there's no point drawing a highlight at all if anything is captured.
    return if @captured_area
    # The slider tray background (white) is drawn over the slider/slider tray's
    # highlight. There's no point drawing any highlight for the slider now; this
    # is done in def refresh instead.
    return if [:slider, :slider_tray].include?(@hover_area)
    # Draw mouse hover over row highlight
    rect = @interactions[@hover_area]
    if rect
      rect_y = rect.y
      rect_y -= @top_row * ROW_HEIGHT if @hover_area.is_a?(Integer)
      self.bitmap.fill_rect(rect.x, rect_y, rect.width, rect.height, HOVER_COLOR)
    end
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
    # Draw vertical slider
    if @show_slider
      self.bitmap.fill_rect(@slider_tray.x, @slider_tray.y, @slider_tray.width, @slider_tray.height, Color.white)
      bar_color = self.bitmap.font.color
      if @captured_area == :slider || (!@captured_area && @hover_area == :slider)
        bar_color = HOVER_COLOR
      end
      self.bitmap.fill_rect(@slider.x + 1, @slider.y, @slider.width - 1, @slider.height, bar_color)
    end
  end

  #-----------------------------------------------------------------------------

  def on_mouse_press
    @captured_area = nil
    mouse_x, mouse_y = mouse_pos
    return if !mouse_x || !mouse_y
    # Check for mouse presses on slider/slider tray
    @interactions.each_pair do |area, rect|
      next if area.is_a?(Integer)
      next if !rect.contains?(mouse_x, mouse_y)
      @captured_area = area
      @slider_mouse_offset = mouse_y - rect.y if area == :slider
      invalidate
      break
    end
    return if @captured_area
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
    set_changed if @captured_area != :slider
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
    # Check each interactive area for whether the mouse is hovering over it, and
    # set @hover_area accordingly
    in_area = false
    @interactions.each_pair do |area, rect|
      next if area.is_a?(Integer)
      next if !rect.contains?(mouse_x, mouse_y)
      invalidate if @hover_area != area
      @hover_area = area
      in_area = true
      break
    end
    if !in_area
      mouse_y += @top_row * ROW_HEIGHT
      @interactions.each_pair do |area, rect|
        next if !area.is_a?(Integer) || area < @top_row || area >= @top_row + @rows_count
        next if !rect.contains?(mouse_x, mouse_y)
        invalidate if @hover_area != area
        @hover_area = area
        in_area = true
        break
      end
    end
    if !in_area
      invalidate if @hover_area
      @hover_area = nil
    end
  end

  def update
    super
    # TODO: Disabled control stuff.
#    return if self.disabled
    if @captured_area == :slider
      # TODO: Have a display y position for the slider bar which is in pixels,
      #       and round it to the nearest row when setting @top_row? This is
      #       just to make the slider bar movement smoother.
      mouse_x, mouse_y = mouse_pos
      return if !mouse_x || !mouse_y
      self.top_row = lerp(0, @values.length - @rows_count, height - @slider.height, 0, mouse_y - @slider_mouse_offset).round
    elsif @captured_area == :slider_tray
      if Input.repeat?(Input::MOUSELEFT) && @hover_area == :slider_tray
        if mouse_y < @slider.y
          self.top_row = @top_row - (@rows_count / 2)
        else
          self.top_row = @top_row + (@rows_count / 2)
        end
      end
    elsif @captured_area
      # Have clicked on a row; set the selected row to the row themouse is over
      @selected = @hover_area if @hover_area.is_a?(Integer)
    end
  end
end
