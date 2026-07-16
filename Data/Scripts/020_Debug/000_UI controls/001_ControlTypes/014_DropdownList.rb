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
