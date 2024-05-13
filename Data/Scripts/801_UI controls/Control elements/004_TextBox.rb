#===============================================================================
#
#===============================================================================
class UIControls::TextBox < UIControls::BaseControl
  attr_accessor :box_width

  TEXT_BOX_X       = 2
  TEXT_BOX_WIDTH   = 200
  TEXT_BOX_HEIGHT  = 24
  TEXT_BOX_PADDING = 4   # Gap between sides of text box and text

  def initialize(width, height, viewport, value = "")
    super(width, height, viewport)
    @value        = value
    @box_width    = TEXT_BOX_WIDTH
    @cursor_pos   = -1
    @display_pos  = 0
    @cursor_timer = nil
    @cursor_shown = false
    @blacklist    = []
  end

  #-----------------------------------------------------------------------------

  def value
    return @value.dup
  end

  def value=(new_value)
    return if @value.to_s == new_value.to_s
    @value = new_value.to_s.dup
    invalidate
  end

  def insert_char(ch)
    @value.insert(@cursor_pos, ch)
    @cursor_pos += 1
    @cursor_timer = System.uptime
    @cursor_shown = true
    invalidate
  end

  def delete_at(index)
    @value = @value.to_s
    @value.slice!(index)
    @cursor_pos -= 1 if @cursor_pos > index
    @cursor_timer = System.uptime
    @cursor_shown = true
    invalidate
  end

  def cursor_pos=(val)
    @cursor_pos = val
    reset_display_pos
    @cursor_timer = System.uptime
    @cursor_shown = true
    invalidate
  end

  def set_blacklist(*list)
    @blacklist = list
    invalidate
  end

  #-----------------------------------------------------------------------------

  def get_cursor_index_from_mouse_position
    char_widths = []
    @value.to_s.length.times { |i| char_widths[i] = self.bitmap.text_size(@value.to_s[i]).width }
    mouse_x, mouse_y = mouse_pos
    mouse_x -= @text_box_rect.x + TEXT_BOX_PADDING
    return 0 if mouse_x < 0
    (@display_pos...char_widths.length).each do |i|
      mouse_x -= char_widths[i]
      if mouse_x <= 0
        return (mouse_x.abs >= char_widths[i] / 2) ? i : i + 1
      end
    end
    return @value.to_s.length
  end

  def disabled?
    val = (@value.respond_to?("strip!")) ? @value.strip : @value
    return true if @blacklist.include?(val)
    return super
  end

  def busy?
    return @cursor_pos >= 0 if @captured_area == :text_box
    return super
  end

  #-----------------------------------------------------------------------------

  def set_interactive_rects
    @text_box_rect = Rect.new(TEXT_BOX_X, (height - TEXT_BOX_HEIGHT) / 2,
                              [@box_width, width - (TEXT_BOX_X * 2)].min, TEXT_BOX_HEIGHT)
    @interactions = {
      :text_box => @text_box_rect
    }
  end

  def reset_interaction
    @cursor_pos = -1
    @display_pos = 0
    @cursor_timer = nil
    @initial_value = nil
    Input.text_input = false
    invalidate
  end

  def reset_display_pos
    box_width = @text_box_rect.width - (TEXT_BOX_PADDING * 2)
    char_widths = []
    @value.to_s.length.times { |i| char_widths[i] = self.bitmap.text_size(@value.to_s[i]).width }
    # Text isn't wider than the box
    if char_widths.sum <= box_width
      return false if @display_pos == 0
      @display_pos = 0
      return true
    end
    display_pos_changed = false
    # Ensure the cursor hasn't gone off the left side of the text box
    if @cursor_pos < @display_pos
      @display_pos = @cursor_pos
      display_pos_changed = true
    end
    # Ensure the cursor hasn't gone off the right side of the text box
    if @cursor_pos > @display_pos
      loop do
        cursor_x = 0
        (@display_pos...@cursor_pos).each do |i|
          cursor_x += char_widths[i] if char_widths[i]
        end
        break if cursor_x < box_width
        @display_pos += 1
        display_pos_changed = true
        break if @display_pos == @cursor_pos
      end
    end
    # Ensure there isn't empty space on the right if the text can be moved to
    # the right to fill it
    if @display_pos > 0
      cursor_x = 0
      (@display_pos...char_widths.length).each do |i|
        cursor_x += char_widths[i] if char_widths[i]
      end
      loop do
        cursor_x += char_widths[@display_pos - 1]
        break if cursor_x >= box_width
        @display_pos -= 1
        display_pos_changed = true
        break if @display_pos == 0
      end
    end
    return display_pos_changed
  end

  #-----------------------------------------------------------------------------

  def draw_area_highlight
    return if @captured_area == :text_box && (@hover_area == @captured_area || !Input.press?(Input::MOUSELEFT))
    super
  end

  def draw_cursor(cursor_x)
    return if !@cursor_shown || @cursor_pos < 0
    cursor_y_offset = ((height - TEXT_BOX_HEIGHT) / 2) + 2
    cursor_height = height - (cursor_y_offset * 2)
    bitmap.fill_rect(cursor_x, cursor_y_offset, 2, cursor_height, text_color)
  end

  def refresh
    super
    # Draw disabled colour
    if disabled?
      self.bitmap.fill_rect(@text_box_rect.x, @text_box_rect.y,
                            @text_box_rect.width, @text_box_rect.height,
                            disabled_fill_color)
    end
    # Draw text box outline
    self.bitmap.outline_rect(@text_box_rect.x, @text_box_rect.y,
                             @text_box_rect.width, @text_box_rect.height,
                             line_color)
    # Draw value
    char_x = @text_box_rect.x + TEXT_BOX_PADDING
    last_char_index = @display_pos
    (@value.to_s.length - @display_pos).times do |i|
      char = @value.to_s[@display_pos + i]
      char_width = self.bitmap.text_size(char).width
      cannot_display_next_char = char_x + char_width > @text_box_rect.x + @text_box_rect.width - TEXT_BOX_PADDING
      draw_text(self.bitmap, char_x, TEXT_OFFSET_Y, char) if !cannot_display_next_char
      # Draw cursor
      draw_cursor(char_x - 1) if @display_pos + i == @cursor_pos
      break if cannot_display_next_char
      last_char_index = @display_pos + i
      char_x += char_width
    end
    # Draw cursor at end
    draw_cursor(char_x - 1) if @cursor_pos == @value.to_s.length
    # Draw left/right arrows to indicate more text beyond the text box sides
    arrow_color = (disabled?) ? disabled_text_color : text_color
    if @display_pos > 0
      bitmap.fill_rect(@text_box_rect.x, (height / 2) - 4, 1, 8, background_color)
      5.times do |i|
        bitmap.fill_rect(@text_box_rect.x - 2 + i, (height / 2) - (i + 1), 1, 2 * (i + 1), arrow_color)
      end
    end
    if last_char_index < @value.to_s.length - 1
      bitmap.fill_rect(@text_box_rect.x + @text_box_rect.width - 1, (height / 2) - 4, 1, 8, background_color)
      5.times do |i|
        bitmap.fill_rect(@text_box_rect.x + @text_box_rect.width + 1 - i, (height / 2) - (i + 1), 1, 2 * (i + 1), arrow_color)
      end
    end
  end

  #-----------------------------------------------------------------------------

  def on_mouse_press
    @captured_area = nil
    super
    if @captured_area == :text_box
      # Clicked into the text box; put the text cursor in there
      @cursor_pos = get_cursor_index_from_mouse_position
      @cursor_timer = System.uptime
      invalidate
    else
      @value.strip! if @value.respond_to?("strip!")
      @value = @initial_value if disabled?
      set_changed if @initial_value && @value != @initial_value
      reset_interaction
    end
  end

  def on_mouse_release
    return if !@captured_area   # Wasn't captured to begin with
    # Start text entry if clicked and released mouse button in the text box
    if @captured_area == :text_box
      mouse_x, mouse_y = mouse_pos
      if mouse_x && mouse_y && @interactions[@captured_area].contains?(mouse_x, mouse_y)
        @initial_value = @value.clone
        Input.text_input = true
        invalidate
        return   # This control is still captured
      end
    end
    # Released mouse button outside of text box, or initially clicked outside of
    # text box; end interaction with this control
    @value.strip! if @value.respond_to?("strip!")
    @value = @initial_value if disabled?
    set_changed if @initial_value && @value != @initial_value
    reset_interaction
    super   # Make this control not busy again
  end

  def update_special_inputs
    # Left/right to move cursor
    if Input.triggerex?(:LEFT) || Input.repeatex?(:LEFT)
      self.cursor_pos = @cursor_pos - 1 if @cursor_pos > 0
    elsif Input.triggerex?(:RIGHT) || Input.repeatex?(:RIGHT)
      self.cursor_pos = @cursor_pos + 1 if @cursor_pos < @value.to_s.length
    end
    # Home/End to jump to start/end of the text
    if Input.triggerex?(:HOME) || Input.repeatex?(:HOME)
      self.cursor_pos = 0
    elsif Input.triggerex?(:END) || Input.repeatex?(:END)
      self.cursor_pos = @value.to_s.length
    end
    # Backspace/Delete to remove text
    if Input.triggerex?(:BACKSPACE) || Input.repeatex?(:BACKSPACE)
      delete_at(@cursor_pos - 1) if @cursor_pos > 0
    elsif Input.triggerex?(:DELETE) || Input.repeatex?(:DELETE)
      delete_at(@cursor_pos) if @cursor_pos < @value.to_s.length
    end
    # Return/Escape to end text input (Escape undoes the change)
    if Input.triggerex?(:RETURN) || Input.repeatex?(:RETURN) ||
       Input.triggerex?(:KP_ENTER) || Input.repeatex?(:KP_ENTER)
      @value.strip! if @value.respond_to?("strip!")
      @value = @initial_value if disabled?
      set_changed if @initial_value && @value != @initial_value
      reset_interaction
      @captured_area = nil
    elsif Input.triggerex?(:ESCAPE) || Input.repeatex?(:ESCAPE)
      @value = @initial_value if @initial_value
      reset_interaction
      @captured_area = nil
    end
  end

  def update_text_entry
    ret = false
    Input.gets.each_char do |ch|
      insert_char(ch)
      ret = true
    end
    return ret
  end

  def update
    return if !self.visible
    super
    # Make the cursor flash
    if @captured_area == :text_box
      cursor_to_show = ((System.uptime - @cursor_timer) / 0.35).to_i.even?
      if cursor_to_show != @cursor_shown
        @cursor_shown = cursor_to_show
        invalidate
      end
      old_cursor_pos = @cursor_pos
      # Update cursor movement, deletions and ending text input
      update_special_inputs
      return if @cursor_pos != old_cursor_pos || !busy?
      # Detect character input and add them to @value
      char_inserted = update_text_entry
      invalidate if reset_display_pos || char_inserted
    end
  end
end
