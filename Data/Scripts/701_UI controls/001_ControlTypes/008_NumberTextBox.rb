#===============================================================================
#
#===============================================================================
class UIControls::NumberTextBox < UIControls::TextBox
  attr_reader :min_value
  attr_reader :max_value

  TEXT_BOX_X     = 0
  TEXT_BOX_WIDTH = 65
  ARROW_WIDTH    = 12
  ARROW_GRAPHIC  = %w(
    . . . . . . . . . . . .
    . . . . . . . . . . . .
    . . . . . X X . . . . .
    . . . . X X X X . . . .
    . . . X X X X X X . . .
    . . X X X X X X X X . .
    . X X X X X X X X X X .
    . X X X X X X X X X X .
    . X X X X X X X X X X .
    . . . . . . . . . . . .
  )

  def initialize(width, height, viewport, min_value, max_value, value)
    super(width, height, viewport, value)
    @min_value = min_value
    @max_value = max_value
    self.value = value
  end

  #-----------------------------------------------------------------------------

  def value=(new_value)
    old_val = @value.to_i
    @value = new_value.to_i.clamp(self.min_value, self.max_value)
    invalidate if @value != old_val
  end

  def min_value=(new_min)
    return if new_min == @min_value
    @min_value = new_min
    @value = @value.to_i.clamp(self.min_value, self.max_value)
    invalidate
  end

  def max_value=(new_max)
    return if new_max == @max_value
    @max_value = new_max
    @value = @value.to_i.clamp(self.min_value, self.max_value)
    invalidate
  end

  def insert_char(ch, index = -1)
    @value = @value.to_s.insert((index >= 0) ? index : @cursor_pos, ch)
    @cursor_pos += 1
    @cursor_timer = System.uptime
    @cursor_shown = true
    invalidate
  end

  #-----------------------------------------------------------------------------

  def set_interactive_rects
    @text_box_rect = Rect.new(TEXT_BOX_X, (height - TEXT_BOX_HEIGHT) / 2,
                              TEXT_BOX_WIDTH, TEXT_BOX_HEIGHT)
    @plus_rect = Rect.new(TEXT_BOX_WIDTH, @text_box_rect.y, ARROW_WIDTH, TEXT_BOX_HEIGHT / 2)
    @minus_rect = Rect.new(TEXT_BOX_WIDTH, @text_box_rect.y + (TEXT_BOX_HEIGHT / 2), ARROW_WIDTH, TEXT_BOX_HEIGHT / 2)
    @interactions = {
      :text_box => @text_box_rect,
      :plus => @plus_rect,
      :minus => @minus_rect
    }
  end

  def reset_interaction
    super
    self.value = @value   # Turn value back into a number and clamp it
  end

  #-----------------------------------------------------------------------------

  def refresh
    super
    # Draw plus/minus buttons
    button_color = (disabled?) ? get_color_of(:disabled_text) : get_color_of(:text)
    ARROW_GRAPHIC.length.times do |i|
      next if ARROW_GRAPHIC[i] == "."
      # Plus button
      self.bitmap.fill_rect(@plus_rect.x + (i % ARROW_WIDTH),
                            @plus_rect.y + (i / ARROW_WIDTH),
                            1, 1, button_color)
      # Minus button
      self.bitmap.fill_rect(@minus_rect.x + (i % ARROW_WIDTH),
                            @minus_rect.y + @minus_rect.height - 1 - (i / ARROW_WIDTH),
                            1, 1, button_color)
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
    elsif @captured_area
      @initial_value = @value
    else
      reset_interaction
      set_changed if @initial_value && @value != @initial_value
    end
  end

  def update_text_entry
    ret = false
    Input.gets.each_char do |ch|
      case ch
      when "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
        if (@value.to_s == "-0" && @cursor_pos > 1) ||
           (@value.to_s == "0" && @cursor_pos > 0)
          @value = @value.to_s.chop
          @cursor_pos -= 1
        end
        insert_char(ch)
        ret = true
      when "-", "+"
        @value = @value.to_s
        if @value[0] == "-"
          delete_at(0)   # Remove the negative sign
          ret = true
        elsif ch == "-"
          insert_char(ch, 0)   # Add a negative sign at the start
          ret = true
        end
        next
      end
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
        increment = (Input.pressex?(:LCTRL) || Input.pressex?(:RCTRL)) ? 10 : 1
        self.value -= increment
      end
    when :plus
      # Constant incrementing of value while pressing the plus button
      if @hover_area == @captured_area && Input.repeat?(Input::MOUSELEFT)
        increment = (Input.pressex?(:LCTRL) || Input.pressex?(:RCTRL)) ? 10 : 1
        self.value += increment
      end
    end
  end
end
