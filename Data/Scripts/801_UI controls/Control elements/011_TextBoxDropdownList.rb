#===============================================================================
# Also known as a Combo Box.
# NOTE: This control lets you type in whatever text you want. The dropdown list
#       only offers autocomplete-like suggestions, but you don't need to match
#       any of them.
#===============================================================================
class UIControls::TextBoxDropdownList < UIControls::TextBox
  attr_accessor :max_rows

  TEXT_BOX_WIDTH = 200 - TEXT_BOX_HEIGHT
  BUTTON_X       = TEXT_BOX_X + TEXT_BOX_WIDTH
  BUTTON_WIDTH   = TEXT_BOX_HEIGHT
  BUTTON_HEIGHT  = TEXT_BOX_HEIGHT
  MAX_LIST_ROWS  = 8

  def initialize(width, height, viewport, options, value = "")
    super(width, height, viewport, value)
    @box_width              = TEXT_BOX_WIDTH
    @options                = options
    @toggling_dropdown_list = false
    @max_rows               = MAX_LIST_ROWS
  end

  def dispose
    remove_dropdown_menu
    super
  end

  #-----------------------------------------------------------------------------

  def values=(new_vals)
    @options = new_vals
    @dropdown_menu.values = @options if @dropdown_menu
  end

  #-----------------------------------------------------------------------------

  def busy?
    return true if @dropdown_menu || @toggling_dropdown_list
    return super
  end

  #-----------------------------------------------------------------------------

  def set_interactive_rects
    @text_box_rect = Rect.new(TEXT_BOX_X, (height - TEXT_BOX_HEIGHT) / 2,
                              [@box_width, width - (TEXT_BOX_X * 2) - BUTTON_WIDTH].min, TEXT_BOX_HEIGHT)
    @button_rect = Rect.new(BUTTON_X, @text_box_rect.y, BUTTON_WIDTH, BUTTON_HEIGHT)
    @interactions = {
      :text_box => @text_box_rect,
      :button => @button_rect
    }
  end

  def make_dropdown_menu
    menu_height = (UIControls::List::ROW_HEIGHT * [@options.length, @max_rows].min) + (UIControls::List::BORDER_THICKNESS * 2)
    # Draw menu's background
    @dropdown_menu_bg = BitmapSprite.new(@text_box_rect.width + @button_rect.width, menu_height, self.viewport)
    @dropdown_menu_bg.x = self.x + @text_box_rect.x
    @dropdown_menu_bg.y = self.y + @text_box_rect.y + @text_box_rect.height
    @dropdown_menu_bg.z = self.z + 1
    @dropdown_menu_bg.bitmap.fill_rect(0, 0, @dropdown_menu_bg.width, @dropdown_menu_bg.height, background_color)
    # Create menu
    @dropdown_menu = UIControls::List.new(@text_box_rect.width + @button_rect.width, menu_height, self.viewport, @options)
    @dropdown_menu.x = @dropdown_menu_bg.x
    @dropdown_menu.y = @dropdown_menu_bg.y
    @dropdown_menu.z = self.z + 2
    @dropdown_menu.color_scheme = @color_scheme
    @dropdown_menu.set_interactive_rects
    @dropdown_menu.repaint
  end

  def remove_dropdown_menu
    @dropdown_menu_bg&.dispose
    @dropdown_menu_bg = nil
    @dropdown_menu&.dispose
    @dropdown_menu = nil
    @captured_area = nil
    @applied_filter = false
  end

  #-----------------------------------------------------------------------------

  def draw_area_highlight
    highlight_color = nil
    if @captured_area == :text_box && !@hover_area && Input.press?(Input::MOUSELEFT)
      highlight_color = capture_color
    elsif !@captured_area && [:text_box, :button].include?(@hover_area)
      # Draw mouse hover over area highlight
      highlight_color = hover_color
    end
    return if !highlight_color
    [:text_box, :button].each do |area|
      rect = @interactions[area]
      self.bitmap.fill_rect(rect.x, rect.y, rect.width, rect.height, highlight_color) if rect
    end
  end

  def refresh
    @dropdown_menu&.refresh
    super
    # Draw disabled colour in button
    if disabled?
      self.bitmap.fill_rect(@button_rect.x, @button_rect.y,
                            @button_rect.width, @button_rect.height,
                            disabled_fill_color)
    end
    # Draw button outline
    self.bitmap.outline_rect(@button_rect.x, @button_rect.y,
                             @button_rect.width, @button_rect.height,
                             line_color)
    # Draw down arrow
    arrow_area_x = @button_rect.x + @button_rect.width - @button_rect.height + 1
    arrow_area_width = @button_rect.height - 2
    arrow_color = (disabled?) ? disabled_text_color : text_color
    # self.bitmap.fill_rect(arrow_area_x, @button_rect.y + 1, arrow_area_width, arrow_area_width,
    #                       (@hover_area && @captured_area != :button) ? hover_color : background_color)
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
        new_val = @options[new_val] if new_val.is_a?(Integer)
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
    if @dropdown_menu && @initial_value && (@applied_filter || @value != @initial_value)
      filtered_options = @options.select do |key, val|
        key.downcase.include?(@value.downcase) || val.downcase.include?(@value.downcase)
      end
      @dropdown_menu.values = filtered_options
      @applied_filter = true
    end
  end
end
