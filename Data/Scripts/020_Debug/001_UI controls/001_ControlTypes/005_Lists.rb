#===============================================================================
# TODO: TEXT_OFFSET_Y was replaced with ((@row_height - 16) / 2) here. Can it be
#       replaced with something similar elsewhere too?
#===============================================================================
class UIControls::List < UIControls::BaseControl
  attr_reader :options
  attr_reader :selected

  LIST_FRAME_THICKNESS = 2
  ROW_HEIGHT           = 24
  TEXT_PADDING_X       = 4

  def initialize(width, height, viewport, options = [], row_height = ROW_HEIGHT)
    super(width, height, viewport)
    @scrollbar = UIControls::Scrollbar.new(height - (LIST_FRAME_THICKNESS * 2), viewport)
    @scrollbar.x = width - UIControls::Scrollbar::SLIDER_WIDTH - LIST_FRAME_THICKNESS
    @scrollbar.y = LIST_FRAME_THICKNESS
    @scrollbar.color_scheme = @color_scheme
    @scrollbar.set_interactive_rects
    @scrollbar.range = row_height
    @scrollbar.z = self.z + 1
    @row_height = row_height
    @rows_count = (height / @row_height).floor   # Number of rows visible at once
    @top_row  = 0
    @selected = -1
    self.options = options
  end

  def dispose
    @scrollbar.dispose
    @scrollbar = nil
    super
  end

  #-----------------------------------------------------------------------------

  def x=(new_val)
    super(new_val)
    @scrollbar.x = new_val + width - UIControls::Scrollbar::SLIDER_WIDTH - LIST_FRAME_THICKNESS
  end

  def y=(new_val)
    super(new_val)
    @scrollbar.y = new_val + LIST_FRAME_THICKNESS
  end

  def z=(new_val)
    super(new_val)
    @scrollbar.z = new_val + 1
  end

  def visible=(new_val)
    super
    @scrollbar.visible = new_val
  end

  def color_scheme=(value)
    return if @color_scheme == value
    @color_scheme = value
    self.bitmap.font.color = get_color_of(:text)
    self.bitmap.font.size = text_size
    @scrollbar&.color_scheme = value
    invalidate if self.respond_to?(:invalidate)
  end

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
    self.selected = -1 if @selected >= @options.length
    invalidate
  end

  # Returns the ID of the selected row.
  def value
    return nil if @selected < 0
    if @options.is_a?(Array)
      return (@options[@selected].is_a?(Array)) ? @options[@selected][0] : @selected
    elsif @options.is_a?(Hash)
      return @options.keys[@selected]
    end
    return nil
  end

  def top_row=(val)
    old_val = @top_row
    @top_row = val
    if @scrollbar.visible
      @top_row = @top_row.clamp(0, @options.length - @rows_count)
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

  def show_selection
    return if !@options || @options.length == 0 || @selected < 0
    new_top_row = @selected - (@rows_count / 2)
    proportion = new_top_row.to_f / (@options.length - @rows_count - 1)
    @scrollbar.slider_top = proportion * (@scrollbar.tray_size - @scrollbar.slider_size - 1)
  end

  #-----------------------------------------------------------------------------

  def mouse_in_control?
    mouse_x, mouse_y = mouse_pos
    return false if !mouse_x || !mouse_y
    return true if Rect.new(0, 0, width, height).contains?(mouse_x, mouse_y)
    return true if @scrollbar.mouse_in_control?
    return false
  end

  def busy?
    return !@captured_area.nil?
  end

  #-----------------------------------------------------------------------------

  def set_interactive_rects
    @interactions = {}
    @options.length.times do |i|
      @interactions[i] = Rect.new(
        LIST_FRAME_THICKNESS, LIST_FRAME_THICKNESS + (@row_height * i),
        width - (LIST_FRAME_THICKNESS * 2), @row_height
      )
    end
  end

  #-----------------------------------------------------------------------------

  def draw_background
    self.bitmap.fill_rect(0, 0, width, height, get_color_of(:control_background))
  end

  def draw_area_highlight
    # If a row is captured, it will automatically be selected and the selection
    # color will be drawn over the highlight. There's no point drawing a
    # highlight at all if anything is captured.
    return if @captured_area
    # Draw mouse hover over row highlight
    rect = @interactions[@hover_area]
    if rect
      rect_y = rect.y
      rect_y -= @top_row * @row_height if @hover_area.is_a?(Integer)
      self.bitmap.fill_rect(rect.x, rect_y, rect.width, rect.height, get_color_of(:hover))
    end
  end

  def repaint
    @scrollbar.repaint if @scrollbar.invalid?
    super if invalid?
  end

  def refresh
    super
    # Draw control outline
    self.bitmap.outline_rect(0, 0, width, height, get_color_of(:line))
    # Draw text options
    @options.each_with_index do |val, i|
      next if i < @top_row || i >= @top_row + @rows_count
      if @selected == i
        self.bitmap.fill_rect(
           @interactions[i].x,
           @interactions[i].y - (@top_row * @row_height),
           @interactions[i].width, @interactions[i].height,
           get_color_of(:highlight)
         )
      end
      txt = (val.is_a?(Array)) ? val[1] : val.to_s
      old_text_color = self.bitmap.font.color.clone
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
                @interactions[i].x + TEXT_PADDING_X,
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
    if @scrollbar.visible && (@scrollbar.busy? || mouse_x >= @scrollbar.x - self.x)
      invalidate if @hover_area
      @hover_area = nil
      return
    end
    # Check each interactive area for whether the mouse is hovering over it, and
    # set @hover_area accordingly
    in_area = false
    mouse_y += @top_row * @row_height
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
    @scrollbar.update
    super
    # Refresh the list's position if changed by moving the scrollbar
    self.top_row = (@scrollbar.position.to_f / @row_height).round
    # Set the selected row to the row the mouse is over, if clicked on
    if @captured_area
      @selected = @hover_area if @hover_area.is_a?(Integer)
    elsif @hover_area
      wheel_v = Input.scroll_v
      scroll_dist = @scrollbar.wheel_scroll_distance
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
      scroll_dist = @scrollbar.wheel_scroll_distance
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

#===============================================================================
#
#===============================================================================
class UIControls::DropdownList < UIControls::BaseControl
  attr_accessor :max_rows

  TEXT_BOX_X       = 0
  TEXT_BOX_HEIGHT  = 20
  TEXT_BOX_PADDING = 4   # Gap between sides of text box and text
  MAX_LIST_ROWS    = 10

  # NOTE: options is a hash: keys are symbols, values are display names.
  def initialize(width, height, viewport, options, value)
    super(width, height, viewport)
    @options                = options
    @value                  = value
    @toggling_dropdown_list = false
    @max_rows               = MAX_LIST_ROWS
  end

  def dispose
    remove_dropdown_menu
    super
  end

  #-----------------------------------------------------------------------------

  def options=(new_vals)
    @options = new_vals
    @dropdown_menu.options = @options if @dropdown_menu
  end

  def value=(new_value)
    return if @value == new_value
    @value = new_value
    invalidate
  end

  #-----------------------------------------------------------------------------

  def mouse_in_control?
    return @dropdown_menu&.mouse_in_control?
    return super
  end

  def busy?
    return true if @dropdown_menu || @toggling_dropdown_list
    return super
  end

  #-----------------------------------------------------------------------------

  def set_interactive_rects
    @button_rect = Rect.new(TEXT_BOX_X, (height - TEXT_BOX_HEIGHT) / 2,
                            width - (TEXT_BOX_X * 2), TEXT_BOX_HEIGHT)
    @interactions = {
      :button => @button_rect
    }
  end

  def make_dropdown_menu
    menu_height = (TEXT_BOX_HEIGHT * [@options.length, @max_rows].min) + (UIControls::List::LIST_FRAME_THICKNESS * 2)
    # Viewport
    view_x = self.x + @button_rect.x + self.viewport.rect.x - self.viewport.ox
    view_y = self.y + @button_rect.y + @button_rect.height + self.viewport.rect.y - self.viewport.oy
    if view_y + menu_height >= Graphics.height
      view_y = self.y + @button_rect.y - menu_height + self.viewport.rect.y - self.viewport.oy
    end
    @dropdown_menu_viewport = Viewport.new(view_x, view_y, @button_rect.width, menu_height)
    @dropdown_menu_viewport.z = self.viewport.z + 100
    # Create menu
    @dropdown_menu = UIControls::List.new(@button_rect.width, menu_height,
                                          @dropdown_menu_viewport, @options, TEXT_BOX_HEIGHT)
    @dropdown_menu.color_scheme = @color_scheme
    @dropdown_menu.set_interactive_rects
    @dropdown_menu.repaint
  end

  def remove_dropdown_menu
    @dropdown_menu&.dispose
    @dropdown_menu = nil
    @dropdown_menu_viewport&.dispose
    @dropdown_menu_viewport = nil
    @captured_area = nil
  end

  #-----------------------------------------------------------------------------

  def draw_background
    bg_color = (disabled?) ? :disabled_fill : :control_background
    self.bitmap.fill_rect(@button_rect.x, @button_rect.y,
                          @button_rect.width, @button_rect.height,
                          get_color_of(bg_color))
    bg_color = :hover if @hover_area && @captured_area != :button
    arrow_area_x = @button_rect.x + @button_rect.width - @button_rect.height + 1
    arrow_area_width = @button_rect.height - 2
    self.bitmap.fill_rect(arrow_area_x, @button_rect.y + 1,
                          arrow_area_width, arrow_area_width,
                          get_color_of(bg_color))
  end

  def draw_area_highlight
    return if @captured_area == :button
    super
  end

  def refresh_dropdown_menu
    @dropdown_menu&.refresh
  end

  def refresh
    refresh_dropdown_menu
    super
    # Draw button outline
    self.bitmap.outline_rect(@button_rect.x, @button_rect.y,
                             @button_rect.width, @button_rect.height,
                             get_color_of(:line))
    # Draw value
    draw_text(self.bitmap, @button_rect.x + TEXT_BOX_PADDING, TEXT_OFFSET_Y, @options[@value] || "???")
    # Draw down arrow
    arrow_area_x = @button_rect.x + @button_rect.width - @button_rect.height + 1
    arrow_area_width = @button_rect.height - 2
    arrow_color = (disabled?) ? get_color_of(:disabled_text) : get_color_of(:text)
    6.times do |i|
      self.bitmap.fill_rect(arrow_area_x + (arrow_area_width / 2) - 5 + i,
                            @button_rect.y + (arrow_area_width / 2) - 1 + i,
                            11 - (2 * i), 1, arrow_color)
    end
  end

  #-----------------------------------------------------------------------------

  def on_mouse_press
    if @dropdown_menu
      if !@dropdown_menu.mouse_in_control?
        remove_dropdown_menu
        @toggling_dropdown_list = true
      end
    else
      @captured_area = nil
      super
      if @captured_area == :button
        make_dropdown_menu
        @toggling_dropdown_list = true
      end
    end
  end

  def on_mouse_release
    return if !@captured_area && !@dropdown_menu && !@toggling_dropdown_list
    refresh
    if @toggling_dropdown_list
      @toggling_dropdown_list = false
      return
    end
    if @dropdown_menu
      if @dropdown_menu.changed?
        new_val = @dropdown_menu.value
        if new_val && new_val != @value
          @value = new_val
          set_changed
        end
        remove_dropdown_menu
        super   # Make this control not busy again
      elsif !@dropdown_menu.mouse_in_control?
        remove_dropdown_menu
        super   # Make this control not busy again
      end
    end
  end

  def update
    @dropdown_menu&.update
    @dropdown_menu&.repaint
    super
  end
end

#===============================================================================
# Also known as a Combo Box.
# NOTE: This control lets you type in whatever text you want. The dropdown list
#       only offers autocomplete-like suggestions, but you don't need to match
#       any of them.
#===============================================================================
class UIControls::TextBoxDropdownList < UIControls::TextBox
  attr_accessor :max_rows

  BUTTON_WIDTH   = TEXT_BOX_HEIGHT
  BUTTON_HEIGHT  = TEXT_BOX_HEIGHT
  MAX_LIST_ROWS  = 8

  def initialize(width, height, viewport, options, value = "")
    super(width, height, viewport, value)
    @options                = options
    @toggling_dropdown_list = false
    @max_rows               = MAX_LIST_ROWS
  end

  def dispose
    remove_dropdown_menu
    super
  end

  #-----------------------------------------------------------------------------

  def options=(new_vals)
    @options = new_vals
    @dropdown_menu.options = @options if @dropdown_menu
  end

  #-----------------------------------------------------------------------------

  def mouse_in_control?
    return @dropdown_menu&.mouse_in_control?
    return super
  end

  def busy?
    return true if @dropdown_menu || @toggling_dropdown_list
    return super
  end

  #-----------------------------------------------------------------------------

  def set_interactive_rects
    @text_box_rect = Rect.new(TEXT_BOX_X, (height - TEXT_BOX_HEIGHT) / 2,
                              width - BUTTON_WIDTH - (TEXT_BOX_X * 2), TEXT_BOX_HEIGHT)
    @button_rect = Rect.new(width - BUTTON_WIDTH, @text_box_rect.y,
                            BUTTON_WIDTH, BUTTON_HEIGHT)
    @interactions = {
      :text_box => @text_box_rect,
      :button => @button_rect
    }
  end

  def make_dropdown_menu
    menu_height = (TEXT_BOX_HEIGHT * [@options.length, @max_rows].min) + (UIControls::List::LIST_FRAME_THICKNESS * 2)
    # Viewport
    view_x = self.x + @text_box_rect.x + self.viewport.rect.x - self.viewport.ox
    view_y = self.y + @text_box_rect.y + @text_box_rect.height + self.viewport.rect.y - self.viewport.oy
    if view_y + menu_height >= Graphics.height
      view_y = self.y + @text_box_rect.y - menu_height + self.viewport.rect.y - self.viewport.oy
    end
    @dropdown_menu_viewport = Viewport.new(view_x, view_y, @button_rect.x + @button_rect.width - @text_box_rect.x, menu_height)
    @dropdown_menu_viewport.z = self.viewport.z + 100
    # Create menu
    shown_options = @options
    if @value && @value != ""
      shown_options = @options.select { |val| val.downcase.include?(@value.downcase) }
    end
    @dropdown_menu = UIControls::List.new(@text_box_rect.width + @button_rect.width, menu_height,
                                          @dropdown_menu_viewport, shown_options, TEXT_BOX_HEIGHT)
    @dropdown_menu.color_scheme = @color_scheme
    @dropdown_menu.set_interactive_rects
    @dropdown_menu.repaint
  end

  def remove_dropdown_menu
    @dropdown_menu&.dispose
    @dropdown_menu = nil
    @dropdown_menu_viewport&.dispose
    @dropdown_menu_viewport = nil
    @captured_area = nil
  end

  #-----------------------------------------------------------------------------

  def draw_background
    super
    bg_color = (disabled?) ? :disabled_fill : :control_background
    bg_color = :hover if @hover_area && @captured_area != :button
    self.bitmap.fill_rect(@button_rect.x, @button_rect.y,
                          @button_rect.width, @button_rect.height,
                          get_color_of(bg_color))
  end

  def draw_area_highlight
    highlight_color = nil
    if @captured_area == :text_box && !@hover_area && Input.press?(Input::MOUSELEFT)
      highlight_color = get_color_of(:capture)
    elsif !@captured_area && [:text_box, :button].include?(@hover_area)
      # Draw mouse hover over area highlight
      highlight_color = get_color_of(:hover)
    end
    return if !highlight_color
    [:text_box, :button].each do |area|
      rect = @interactions[area]
      self.bitmap.fill_rect(rect.x, rect.y, rect.width, rect.height, highlight_color) if rect
    end
  end

  def refresh_dropdown_menu
    @dropdown_menu&.refresh
  end

  def refresh
    refresh_dropdown_menu
    super
    # Draw button outline
    self.bitmap.outline_rect(@button_rect.x, @button_rect.y,
                             @button_rect.width, @button_rect.height,
                             get_color_of(:line))
    # Draw down arrow
    arrow_area_x = @button_rect.x + @button_rect.width - @button_rect.height + 1
    arrow_area_width = @button_rect.height - 2
    arrow_color = (disabled?) ? get_color_of(:disabled_text) : get_color_of(:text)
    6.times do |i|
      self.bitmap.fill_rect(arrow_area_x + (arrow_area_width / 2) - 5 + i,
                            @button_rect.y + (arrow_area_width / 2) - 1 + i,
                            11 - (2 * i), 1, arrow_color)
    end
  end

  #-----------------------------------------------------------------------------

  def on_mouse_press
    mouse_x, mouse_y = mouse_pos
    return if !mouse_x || !mouse_y
    if @dropdown_menu
      if @text_box_rect.contains?(mouse_x, mouse_y)
        # Clicked into the text box; put the text cursor in there
        @captured_area = :text_box
        @cursor_pos = get_cursor_index_from_mouse_position
        @cursor_timer = System.uptime
        invalidate
      elsif !@dropdown_menu.mouse_in_control?
        @value.strip! if @value.respond_to?("strip!")
        @value = @initial_value.dup if disabled?
        set_changed if @initial_value && @value != @initial_value
        reset_interaction
        remove_dropdown_menu
        @toggling_dropdown_list = true
      end
    else
      @captured_area = nil
      super
      if @captured_area
        make_dropdown_menu
        @toggling_dropdown_list = true
      end
    end
  end

  def on_mouse_release
    return if !@captured_area && !@dropdown_menu && !@toggling_dropdown_list
    if @toggling_dropdown_list
      @toggling_dropdown_list = false
      mouse_x, mouse_y = mouse_pos
      if mouse_x && mouse_y && @interactions[:text_box].contains?(mouse_x, mouse_y)
        @initial_value = @value.dup
        Input.text_input = true
        invalidate
      end
      return
    end
    if @dropdown_menu
      if @dropdown_menu.changed?
        new_val = @dropdown_menu.value
        new_val = @dropdown_menu.options[new_val] if new_val.is_a?(Integer)
        if new_val && new_val != @value
          self.value = new_val
          set_changed
        end
        @value.strip! if @value.respond_to?("strip!")
        reset_interaction
        remove_dropdown_menu
        @captured_area = nil
      elsif @captured_area
        mouse_x, mouse_y = mouse_pos
        if mouse_x && mouse_y && @interactions[:text_box].contains?(mouse_x, mouse_y)
          @captured_area = :text_box
          @initial_value = @value.dup
          Input.text_input = true
        end
      elsif !mouse_in_control? && !@dropdown_menu.mouse_in_control?
        @value.strip! if @value.respond_to?("strip!")
        self.value = @initial_value if disabled?
        set_changed if @initial_value && @value != @initial_value
        reset_interaction
        remove_dropdown_menu
        @captured_area = nil
      end
    else
      super
    end
    invalidate
  end

  def update
    @dropdown_menu&.update
    @dropdown_menu&.repaint
    super
    # Filter the dropdown menu options based on @value if it changes
    if @dropdown_menu && @initial_value && @value != @initial_value
      @dropdown_menu.options = @options.select do |key, val|
        key.to_s.downcase.include?(@value.downcase) || val&.downcase&.include?(@value.downcase)
      end
    end
  end
end
