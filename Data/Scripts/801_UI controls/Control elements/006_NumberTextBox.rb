#===============================================================================
#
#===============================================================================
class UIControls::NumberTextBox < UIControls::TextBox
  attr_reader :min_value
  attr_reader :max_value

  PLUS_MINUS_SIZE = 16
  CONTROL_PADDING = 2   # Gap between buttons and text box

  MINUS_X         = 0
  TEXT_BOX_X      = MINUS_X + PLUS_MINUS_SIZE + CONTROL_PADDING
  TEXT_BOX_WIDTH  = 64
  TEXT_BOX_HEIGHT = 24
  PLUS_X          = TEXT_BOX_X + TEXT_BOX_WIDTH + CONTROL_PADDING

  def initialize(width, height, viewport, min_value, max_value, value)
    super(width, height, viewport, value)
    @min_value = min_value
    @max_value = max_value
    self.value = value
  end

  def value=(new_value)
    old_val = @value
    @value = new_value.to_i.clamp(self.min_value, self.max_value)
    self.invalidate if @value != old_val
  end

  def min_value=(new_min)
    return if new_min == @min_value
    @min_value = new_min
    @value = @value.clamp(self.min_value, self.max_value)
    self.invalidate
  end

  def max_value=(new_max)
    return if new_max == @max_value
    @max_value = new_max
    @value = @value.clamp(self.min_value, self.max_value)
    self.invalidate
  end

  # TODO: If current value is 0, replace it with ch instead of inserting ch?
  def insert_char(ch)
    self.value = @value.to_s.insert(@cursor_pos, ch).to_i
    @cursor_pos += 1
    @cursor_pos = @cursor_pos.clamp(0, @value.to_s.length)
    @cursor_timer = System.uptime
    @cursor_shown = true
    invalidate
  end

  def delete_at(index)
    new_val = @value.to_s
    new_val.slice!(index)
    self.value = new_val.to_i
    @cursor_pos -= 1 if @cursor_pos > index
    @cursor_pos = @cursor_pos.clamp(0, @value.to_s.length)
    @cursor_timer = System.uptime
    @cursor_shown = true
    invalidate
  end

  def set_interactive_rects
    @text_box_rect = Rect.new(TEXT_BOX_X, (height - TEXT_BOX_HEIGHT) / 2,
                              TEXT_BOX_WIDTH, TEXT_BOX_HEIGHT)
    @minus_rect = Rect.new(MINUS_X, (self.height - PLUS_MINUS_SIZE) / 2, PLUS_MINUS_SIZE, PLUS_MINUS_SIZE)
    @plus_rect = Rect.new(PLUS_X, (self.height - PLUS_MINUS_SIZE) / 2, PLUS_MINUS_SIZE, PLUS_MINUS_SIZE)
    @interactions = {
      :text_box => @text_box_rect,
      :minus    => @minus_rect,
      :plus     => @plus_rect
    }
  end

  #-----------------------------------------------------------------------------

  def refresh
    super
    button_color = (disabled?) ? DISABLED_COLOR : self.bitmap.font.color
    # Draw minus button
    self.bitmap.fill_rect(@minus_rect.x + 2, @minus_rect.y + (@minus_rect.height / 2) - 2, @minus_rect.width - 4, 4, button_color)
    # Draw plus button
    self.bitmap.fill_rect(@plus_rect.x + 2, @plus_rect.y + (@plus_rect.height / 2) - 2, @plus_rect.width - 4, 4, button_color)
    self.bitmap.fill_rect(@plus_rect.x + (@plus_rect.width / 2) - 2, @plus_rect.y + 2, 4, @plus_rect.height - 4, button_color)
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
    elsif @captured_area
      @initial_value = @value
    else
      set_changed if @initial_value && @value != @initial_value
      reset_interaction
    end
  end

  def update_text_entry
    ret = false
    Input.gets.each_char do |ch|
      next if !["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "-"].include?(ch)
      if ch == "-"
        next if @min_value >= 0 || @cursor_pos > 1 || (@cursor_pos > 0 && @value >= 0)
        if @value < 0
          delete_at(0)   # Remove the negative sign
          ret = true
          next
        end
      end
      insert_char(ch)
      ret = true
    end
    return ret
  end

  def update
    return if !self.visible
    super
    case @captured_area
    when :minus
      # Constant decrement of value while pressing the minus button
      if @hover_area == @captured_area && Input.repeat?(Input::MOUSELEFT)
        self.value -= 1
      end
    when :plus
      # Constant incrementing of value while pressing the plus button
      if @hover_area == @captured_area && Input.repeat?(Input::MOUSELEFT)
        self.value += 1
      end
    end
  end
end
