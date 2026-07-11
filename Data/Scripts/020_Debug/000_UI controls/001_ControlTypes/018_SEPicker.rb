#===============================================================================
#
#===============================================================================
class UIControls::SEPicker < UIControls::BaseControl
  BUTTON_WIDTH  = 20
  BUTTON_HEIGHT = 20

  PICKER_BOX_SPACING       = 4
  PICKER_BOX_BUTTON_WIDTH  = 64
  PICKER_BOX_BUTTON_HEIGHT = 20
  PICKER_BOX_LIST_X        = PICKER_BOX_SPACING + 1
  PICKER_BOX_LIST_Y        = PICKER_BOX_SPACING + 1
  PICKER_BOX_LIST_WIDTH    = (3 * PICKER_BOX_BUTTON_WIDTH) + (2 * PICKER_BOX_SPACING)   # 200
  PICKER_BOX_LIST_HEIGHT   = 88
  PICKER_BOX_LIST_ROW_HEIGHT = 20

  PICKER_BOX_WIDTH  = (2 * PICKER_BOX_LIST_X) + PICKER_BOX_LIST_WIDTH   # 210
  PICKER_BOX_HEIGHT = (2 * PICKER_BOX_LIST_Y) + PICKER_BOX_LIST_HEIGHT + PICKER_BOX_SPACING + PICKER_BOX_BUTTON_HEIGHT   # 126

  # NOTE: @options are the contents of the list. @value is temporary and used
  #       only when a button is pressed (it contains the ID of that button and
  #       the list's index at that time).
  def initialize(width, height, viewport, options)
    super(width, height, viewport)
    @options             = options
    @toggling_picker_box = false
  end

  def dispose
    remove_picker_box
    super
  end

  #-----------------------------------------------------------------------------

  def value=(new_options)
    return if @options == new_options
    @options = new_options
    invalidate
  end

  #-----------------------------------------------------------------------------

  def busy?
    return true if @picker_box_bg || @toggling_picker_box
    return super
  end

  def clear_changed
    @value = nil
    super
  end

  #-----------------------------------------------------------------------------

  def set_interactive_rects
    @button_rect = Rect.new(0, (height - BUTTON_HEIGHT) / 2, BUTTON_WIDTH, BUTTON_HEIGHT)
    @interactions = {
      :button => @button_rect
    }
  end

  def make_picker_box
    return if @picker_box_bg
    # Viewport
    view_x = self.x + @button_rect.x + self.viewport.rect.x - self.viewport.ox
    view_y = self.y + @button_rect.y + @button_rect.height + self.viewport.rect.y - self.viewport.oy
    if view_x + PICKER_BOX_WIDTH >= Graphics.width
      view_x = self.x + @button_rect.x + @button_rect.width - PICKER_BOX_WIDTH + self.viewport.rect.x - self.viewport.ox
    end
    if view_y + PICKER_BOX_HEIGHT >= Graphics.height
      view_y = self.y + @button_rect.y - PICKER_BOX_HEIGHT + self.viewport.rect.y - self.viewport.oy
    end
    @picker_box_viewport = Viewport.new(view_x, view_y, PICKER_BOX_WIDTH, PICKER_BOX_HEIGHT)
    @picker_box_viewport.z = self.viewport.z + 100
    # Picker box's background (white box with outline)
    @picker_box_bg = BitmapSprite.new(PICKER_BOX_WIDTH, PICKER_BOX_HEIGHT, @picker_box_viewport)
    @picker_box_bg.z = -100
    @picker_box_bg.bitmap.fill_rect(0, 0, @picker_box_bg.width, @picker_box_bg.height,
                                    get_color_of(:background))
    @picker_box_bg.bitmap.outline_rect(0, 0, @picker_box_bg.width, @picker_box_bg.height,
                                       get_color_of(:line))
    # Controls
    make_picker_box_controls
    refresh_picker_box
  end

  def make_picker_box_controls
    @picker_controls = {}
    # List box
    ctrl = UIControls::List.new(PICKER_BOX_LIST_WIDTH, PICKER_BOX_LIST_HEIGHT, @picker_box_viewport, [], PICKER_BOX_LIST_ROW_HEIGHT)
    ctrl.x = PICKER_BOX_LIST_X
    ctrl.y = PICKER_BOX_LIST_Y
    ctrl.set_interactive_rects
    ctrl.color_scheme = @color_scheme
    @picker_controls[:list] = ctrl
    # Buttons
    button_x = PICKER_BOX_LIST_X
    [[:add, _INTL("Add")],
     [:edit, _INTL("Edit")],
     [:delete, _INTL("Delete")]].each do |ct|
      ctrl = UIControls::Button.new(PICKER_BOX_BUTTON_WIDTH, PICKER_BOX_BUTTON_HEIGHT, @picker_box_viewport, ct[1])
      ctrl.x = button_x
      ctrl.y = PICKER_BOX_LIST_Y + PICKER_BOX_LIST_HEIGHT + PICKER_BOX_SPACING
      ctrl.color_scheme = @color_scheme
      ctrl.set_interactive_rects
      @picker_controls[ct[0]] = ctrl
      button_x += PICKER_BOX_BUTTON_WIDTH + PICKER_BOX_SPACING
    end
  end

  def remove_picker_box
    @picker_controls&.each_value { |ctrl| ctrl&.dispose }
    @picker_controls = nil
    @picker_box_bg&.dispose
    @picker_box_bg = nil
    @picker_box_viewport&.dispose
    @picker_box_viewport = nil
    @picker_captured = nil
    @captured_area = nil
  end

  #-----------------------------------------------------------------------------

  def draw_area_highlight
    return if @captured_area == :button
    super
  end

  def refresh_picker_box
    return if !@picker_box_bg
    @picker_controls[:list].options = @options
    if @picker_controls[:list].value
      @picker_controls[:edit].enable
      @picker_controls[:delete].enable
    else
      @picker_controls[:edit].disable
      @picker_controls[:delete].disable
    end
    @picker_controls.each_value { |ctrl| ctrl.repaint }
  end

  def refresh
    refresh_picker_box
    return if @picker_box_bg
    super
    # Draw disabled color
    if disabled?
      self.bitmap.fill_rect(@button_rect.x, @button_rect.y,
                            @button_rect.width, @button_rect.height,
                            get_color_of(:disabled_fill))
    end
    # Draw button outline
    self.bitmap.outline_rect(@button_rect.x, @button_rect.y,
                             @button_rect.width, @button_rect.height,
                             get_color_of(:line))
    # Draw button graphic
    btmp_graphic = %w(
      . . . . . . . . . . . . . . . .
      . . . . . . . . . . . . X . . .
      . . . . . . X . . . . . . X . .
      . . . . . X X . . . X . . . X .
      . . . . X . X . . . . X . . X .
      X X X X . . X . X . . X . . . X
      X . . . . . X . . X . . X . . X
      X . . . . . X . . X . . X . . X
    )
    icon_color = get_color_of(:text)
    btmp_width = BUTTON_WIDTH - 4
    btmp_graphic.length.times do |i|
      next if btmp_graphic[i] == "."
      pixel_x = i % btmp_width
      pixel_y = i / btmp_width
      self.bitmap.fill_rect(@button_rect.x + 2 + pixel_x, @button_rect.y + 2 + pixel_y, 1, 1, icon_color)
      self.bitmap.fill_rect(@button_rect.x + 2 + pixel_x, @button_rect.y + @button_rect.height - 3 - pixel_y, 1, 1, icon_color)
    end
  end

  #-----------------------------------------------------------------------------

  def on_mouse_press
    if @picker_box_bg
      mouse_coords = Mouse.getMousePos
      if mouse_coords && !@picker_box_viewport.rect.contains?(*mouse_coords)
        remove_picker_box
        @toggling_picker_box = true
      end
    else
      @captured_area = nil
      super
      if @captured_area == :button
        make_picker_box
        @toggling_picker_box = true
      end
    end
  end

  def on_mouse_release
    return if !@captured_area && !@picker_box_bg && !@toggling_picker_box
    refresh
    if @toggling_picker_box
      @toggling_picker_box = false
      return
    end
    super
  end

  def update
    # Update picker controls
    if @picker_captured
      @picker_captured.update
      @picker_captured = nil if !@picker_captured.busy?
    elsif @picker_controls
      @picker_controls.each_pair do |id, ctrl|
        ctrl.update
        next if !ctrl.busy?
        @picker_captured = ctrl
      end
    end
    # Check for updated controls
    @picker_controls&.each_pair do |id, ctrl|
      next if !ctrl.changed?
      if id == :list
        refresh
      else
        if id == :add || @picker_controls[:list].value
          @value = [id, @picker_controls[:list].value]
          set_changed
        end
      end
      ctrl.clear_changed
    end
    @picker_controls&.each_value { |ctrl| ctrl.repaint }
    super
  end
end
