#===============================================================================
#
#===============================================================================
class UIControls::DropdownList < UIControls::BaseControl
  TEXT_BOX_X       = 2
  TEXT_BOX_WIDTH   = 172
  TEXT_BOX_HEIGHT  = 24
  TEXT_BOX_PADDING = 4   # Gap between sides of text box and text
  TEXT_OFFSET_Y    = 5
  MAX_LIST_ROWS    = 8

  def initialize(width, height, viewport, options, value)
    # NOTE: options is a hash: keys are symbols, values are display names.
    super(width, height, viewport)
    @options = options
    @value = value
    @toggling_dropdown_list = false
  end

  def dispose
    remove_dropdown_menu
    super
  end

  def value=(new_value)
    return if @value == new_value
    @value = new_value
    invalidate
  end

  def set_interactive_rects
    @button_rect = Rect.new(TEXT_BOX_X, (height - TEXT_BOX_HEIGHT) / 2,
                              [TEXT_BOX_WIDTH, width].min, TEXT_BOX_HEIGHT)
    @interactions = {
      :button => @button_rect
    }
  end

  #-----------------------------------------------------------------------------

  def busy?
    return true if @dropdown_menu || @toggling_dropdown_list
    return super
  end

  #-----------------------------------------------------------------------------

  def make_dropdown_menu
    menu_height = UIControls::List::ROW_HEIGHT * [@options.length, MAX_LIST_ROWS].min
    # Draw menu's background
    @dropdown_menu_bg = BitmapSprite.new(@button_rect.width, menu_height + 4, self.viewport)
    @dropdown_menu_bg.x = self.x + @button_rect.x
    @dropdown_menu_bg.y = self.y + @button_rect.y + @button_rect.height
    @dropdown_menu_bg.z = self.z + 1
    @dropdown_menu_bg.bitmap.outline_rect(0, 0, @dropdown_menu_bg.width, @dropdown_menu_bg.height, Color.black)
    @dropdown_menu_bg.bitmap.fill_rect(1, 1, @dropdown_menu_bg.width - 2, @dropdown_menu_bg.height - 2, Color.white)
    # Create menu
    @dropdown_menu = UIControls::List.new(@button_rect.width - 4, menu_height, self.viewport, @options)
    @dropdown_menu.x = @dropdown_menu_bg.x + 2
    @dropdown_menu.y = @dropdown_menu_bg.y + 2
    @dropdown_menu.z = self.z + 2
    @dropdown_menu.set_interactive_rects
    @dropdown_menu.repaint
  end

  def remove_dropdown_menu
    @dropdown_menu_bg&.dispose
    @dropdown_menu_bg = nil
    @dropdown_menu&.dispose
    @dropdown_menu = nil
    @captured_area = nil
  end

  #-----------------------------------------------------------------------------

  def draw_area_highlight
    return if @captured_area == :button
    super
  end

  def refresh
    @dropdown_menu&.refresh
    super
    # Draw button outline
    self.bitmap.outline_rect(@button_rect.x, @button_rect.y,
                             @button_rect.width, @button_rect.height,
                             Color.black)
    # Draw value
    draw_text(self.bitmap, @button_rect.x + TEXT_BOX_PADDING, TEXT_OFFSET_Y, @options[@value] || "???")
    # Draw down arrow
    arrow_area_x = @button_rect.x + @button_rect.width - @button_rect.height + 1
    arrow_area_width = @button_rect.height - 2
    self.bitmap.fill_rect(arrow_area_x, @button_rect.y + 1, arrow_area_width, arrow_area_width,
                          (@hover_area && @captured_area != :button) ? HOVER_COLOR : Color.white)
    6.times do |i|
      self.bitmap.fill_rect(arrow_area_x + (arrow_area_width / 2) - 5 + i,
                            @button_rect.y + (arrow_area_width / 2) - 1 + i,
                            11 - (2 * i), 1, Color.black)
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
