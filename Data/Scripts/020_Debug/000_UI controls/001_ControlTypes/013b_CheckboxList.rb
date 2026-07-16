#===============================================================================
#
#===============================================================================
class UIControls::CheckboxList < UIControls::List
  CHECKBOX_X = 4
  CHECKBOX_SIZE = 16

  def initialize(width, height, viewport, options = [], row_height = ROW_HEIGHT)
    super
    @selected = []   # A Boolean for each value in @options
  end

  #-----------------------------------------------------------------------------

  # Each value in @options is an array: [id, text].
  def options=(new_vals)
    @options = new_vals
    set_interactive_rects
    @scrollbar.range = [@options.length, 1].max * @row_height
    if @scrollbar.visible
      self.top_row = (@scrollbar.position.to_f / @row_height).round
    else
      self.top_row = 0
    end
    @selected = @selected[0...@options.length]
    invalidate
  end

  # Returns an array of Booleans.
  def value
    return nil if @selected.none? { |val| val == true }
    ret = []
    @options.each_with_index { |option, i| ret[option[0]] = !!@selected[i] }
    return ret
  end

  def select_all
    @options.length.times { |i| @selected[i] = true }
    invalidate
  end

  def deselect_all
    @options.length.times { |i| @selected[i] = false }
    invalidate
  end

  #-----------------------------------------------------------------------------

  def draw_background
    self.bitmap.fill_rect(0, 0, width, height, get_color_of(:control_background))
  end

  def draw_area_highlight
    return if !@interactions || @interactions.empty?
    if !@captured_area || @hover_area == @captured_area
      # Draw mouse hover over area highlight
      rect = @interactions[@hover_area]
      if rect
        self.bitmap.fill_rect(
          rect.x + CHECKBOX_X,
          rect.y + ((@row_height - CHECKBOX_SIZE) / 2),
          CHECKBOX_SIZE, CHECKBOX_SIZE, get_color_of(:hover)
        )
      end
    elsif @captured_area
      # Draw captured area highlight
      rect = @interactions[@captured_area]
      if rect
        self.bitmap.fill_rect(
          rect.x + CHECKBOX_X,
          rect.y + ((@row_height - CHECKBOX_SIZE) / 2),
          CHECKBOX_SIZE, CHECKBOX_SIZE, get_color_of(:capture)
        )
      end
    end
    # Draw mouse hover over row highlight
    rect = @interactions[@hover_area]
    if rect
      rect_y = rect.y
      rect_y -= @top_row * @row_height if @hover_area.is_a?(Integer)
      self.bitmap.fill_rect(
        rect.x + CHECKBOX_X,
        rect_y + ((@row_height - CHECKBOX_SIZE) / 2),
        CHECKBOX_SIZE, CHECKBOX_SIZE, get_color_of(:hover)
      )
    end
  end

  def refresh
    self.bitmap.clear
    draw_background
    draw_area_highlight
    # Draw control outline
    self.bitmap.outline_rect(0, 0, width, height, get_color_of(:line))
    # Draw text options
    @options.each_with_index do |val, i|
      next if i < @top_row || i >= @top_row + @rows_count
      # Draw checkbox
      self.bitmap.outline_rect(
        @interactions[i].x + CHECKBOX_X,
        @interactions[i].y + ((@row_height - CHECKBOX_SIZE) / 2) - (@top_row * @row_height),
        CHECKBOX_SIZE, CHECKBOX_SIZE, get_color_of(:line)
      )
      # Draw checkbox tick
      if @selected[i]
        self.bitmap.fill_rect(
          @interactions[i].x + CHECKBOX_X + 2,
          @interactions[i].y + ((@row_height - CHECKBOX_SIZE) / 2) - (@top_row * @row_height) + 2,
          CHECKBOX_SIZE - 4, CHECKBOX_SIZE - 4, get_color_of(:checked)
        )
      end
      # Draw text
      txt = (val.is_a?(Array)) ? val[1] : val.to_s
      old_text_color = self.bitmap.font.color
      if txt[/^\\c\[([0-9]+)\]/i]
        text_colors = [
          [  0, 112, 248], [120, 184, 232],   # 1  Blue
          [232,  32,  16], [248, 168, 184],   # 2  Red
          [ 96, 176,  72], [174, 208, 144],   # 3  Green
          [ 72, 216, 216], [168, 224, 224],   # 4  Cyan
          [208,  56, 184], [232, 160, 224],   # 5  Magenta
          [232, 208,  32], [248, 232, 136],   # 6  Yellow
          [160, 160, 168], [208, 208, 216],   # 7  Gray
          [240, 240, 248], [200, 200, 208],   # 8  White
          [114,  64, 232], [184, 168, 224],   # 9  Purple
          [248, 152,  24], [248, 200, 152],   # 10 Orange
          MessageConfig::DARK_TEXT_MAIN_COLOR,
          MessageConfig::DARK_TEXT_SHADOW_COLOR,   # 11 Dark default
          MessageConfig::LIGHT_TEXT_MAIN_COLOR,
          MessageConfig::LIGHT_TEXT_SHADOW_COLOR   # 12 Light default
        ]
        self.bitmap.font.color = Color.new(*text_colors[2 * ($1.to_i - 1)])
        txt = txt.gsub(/^\\c\[[0-9]+\]/i, "")
      end
      draw_text(self.bitmap,
                @interactions[i].x + CHECKBOX_X + CHECKBOX_SIZE + TEXT_PADDING_X,
                @interactions[i].y + ((@row_height - 16) / 2) - (@top_row * @row_height),
                txt)
      self.bitmap.font.color = old_text_color
    end
  end

  #-----------------------------------------------------------------------------

  def on_mouse_press
    @captured_area = nil
    mouse_x, mouse_y = mouse_pos
    return if !mouse_x || !mouse_y
    return if @scrollbar.visible && (@scrollbar.busy? || mouse_x >= @scrollbar.x - self.x)
    # Check for mouse presses on rows
    mouse_y += @top_row * @row_height
    @interactions.each_pair do |area, rect|
      next if !area.is_a?(Integer) || area < @top_row || area >= @top_row + @rows_count
      next if !rect.contains?(mouse_x, mouse_y)
      @captured_area = area
      @selected[@captured_area] = !@selected[@captured_area] if @captured_area.is_a?(Integer)
      invalidate
      break
    end
  end

  # This is copied straight from UIControls::BaseControl#update.
  def base_update
    return if !self.visible
    return if disabled? && !busy?   # This control still works if it becomes disabled while using it
    update_hover_highlight
    # Detect a mouse press/release
    if @interactions && !@interactions.empty?
      if Input.trigger?(Input::MOUSELEFT)
        on_mouse_press
      elsif busy? && Input.release?(Input::MOUSELEFT)
        on_mouse_release
      end
    end
  end

  def update
    return if !self.visible
    @scrollbar.update
    base_update
    # Refresh the list's position if changed by moving the scrollbar
    self.top_row = (@scrollbar.position.to_f / @row_height).round
    # Scroll via the mouse scroll wheel
    if @hover_area
      wheel_v = Input.scroll_v
      scroll_dist = UIControls::Scrollbar::SCROLL_DISTANCE
      scroll_dist /= 2 if @options.length / @rows_count > 20   # Arbitrary 20
      if wheel_v > 0   # Scroll up
        @scrollbar.slider_top -= scroll_dist
      elsif wheel_v < 0   # Scroll down
        @scrollbar.slider_top += scroll_dist
      end
      if wheel_v != 0
        self.top_row = (@scrollbar.position.to_f / @row_height).round
        update_hover_highlight
      end
    end
  end
end
