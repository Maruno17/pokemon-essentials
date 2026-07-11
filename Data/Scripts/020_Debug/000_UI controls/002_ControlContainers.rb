#===============================================================================
# Is an area of the screen, and contains a list of controls. Basically a wrapper
# for a set of controls.
# Often built upon by containers that need more complex layouts, e.g. multiple
# viewports.
# TODO: Make this include the border and background sprite? It will be larger to
#       contain the border; save that total size as @full_width/@full_height and
#       make width/height return the size of the usable area inside. x/y too?
#       Maybe? Or have a child class which is this plus a background/border.
#===============================================================================
class UIControls::BaseContainer
  attr_reader   :x, :y, :z, :width, :height
  attr_reader   :visible
  attr_reader   :viewport
  attr_reader   :controls
  attr_reader   :changed_controls

  include UIControls::StyleMixin

  def initialize(x, y, width, height, viewport = nil)
    @x = x || 0
    @y = y || 0
    @z = 0
    @width = width
    @height = height
    @viewport = viewport
    @visible = true
    @captured = nil
    @bitmaps = {}
    @sprites = {}
    @controls = {}
    self.color_scheme = DEFAULT_SCHEME
    initialize_viewport
    initialize_bitmaps
    initialize_background
    initialize_sprites
    initialize_controls
  end

  def initialize_viewport
    return if @viewport
    @viewport = Viewport.new(@x, @y, @width, @height)
    @viewport.z = 99999
  end

  def initialize_bitmaps
  end

  def initialize_background
  end

  def initialize_sprites
  end

  def initialize_controls
  end

  def dispose
    @controls.each_value { |c| c.dispose if c && !c.disposed? }
    @controls.clear
    @sprites.each_value { |s| s.dispose if s && !s.disposed? }
    @sprites.clear
    @bitmaps.each_value { |b| b.dispose if b && !b.disposed? }
    @bitmaps.clear
    @viewport&.dispose
    @disposed = true
  end

  def disposed?
    return !!@disposed
  end

  #-----------------------------------------------------------------------------

  def z=(value)
    return if @z == value
    diff = value - @z
    @z = value
    @sprites.each_value { |s| s.z += diff }
    @controls.each_value { |c| c.z += diff }
  end

  def visible=(value)
    @visible = value
    @sprites.each_value { |s| s.visible = value }
    @controls.each_value { |c| c.visible = value }
    repaint if @visible
  end

  def color_scheme=(value)
    return if @color_scheme == value
    @color_scheme = value
    if @controls
      @controls.each_value { |c| c.color_scheme = value }
      repaint
    end
  end

  #-----------------------------------------------------------------------------

  def add_control_at(id, x, y, control)
    control.x = x
    control.y = y
    control.color_scheme = @color_scheme
    control.set_interactive_rects
    @controls[id] = control
    repaint
  end

  def mouse_pos
    mouse_coords = Mouse.getMousePos
    return nil, nil if !mouse_coords
    ret_x = mouse_coords[0] - (self.viewport&.rect.x || 0) + (self.viewport&.ox || 0) - self.x
    ret_y = mouse_coords[1] - (self.viewport&.rect.y || 0) + (self.viewport&.oy || 0) - self.y
    return ret_x, ret_y
  end

  def mouse_in_container?
    mouse_x, mouse_y = mouse_pos
    return false if !mouse_x || !mouse_y
    return mouse_x >= 0 && mouse_x < self.width &&
           mouse_y >= 0 && mouse_y < self.height
  end

  #-----------------------------------------------------------------------------

  def busy?
    return !@captured.nil?
  end

  def changed?
    return !@changed_controls.nil?
  end

  def clear_changed
    @changed_controls = nil
  end

  def get_control(id)
    return @controls[id] if @controls
    return nil
  end

  #-----------------------------------------------------------------------------

  def draw_text(this_bitmap, text_x, text_y, this_text)
    this_bitmap.font.color = get_color_of(:text)
    text_size = this_bitmap.text_size(this_text.to_s)
    this_bitmap.draw_text(text_x, text_y, text_size.width, text_size.height, this_text.to_s, 0)
  end

  def repaint
    return if disposed?
    @controls.each_value { |c| c.repaint }
  end

  def refresh; end

  #-----------------------------------------------------------------------------

  def update
    return if disposed? || !@visible
    # Update controls
    if @captured
      @captured.update
      @captured = nil if !@captured.busy?
    else
      @controls.each_value do |c|
        c.update
        @captured = c if c.busy?
      end
    end
    # Check for updated controls
    @controls.each_pair do |id, c|
      next if !c.changed?
      @changed_controls ||= {}
      @changed_controls[id] = c.value
      c.clear_changed
    end
    # Redraw controls if needed
    repaint
  end
end

#===============================================================================
# Controls are arranged in a list in self's bitmap. Each control is given an
# area of size "self's bitmap's width" x LINE_SPACING to draw itself in. A line
# can either contain just a control or a label with a control.
#===============================================================================
class UIControls::ListedContainer < UIControls::BaseContainer
  attr_accessor :label_offset_x, :label_offset_y

  LINE_SPACING        = 24
  BUTTON_HEIGHT       = 20
  OFFSET_FROM_LABEL_X = 65
  OFFSET_FROM_LABEL_Y = 0

  def initialize(x, y, width, height, viewport = nil)
    super
    @label_offset_x = OFFSET_FROM_LABEL_X
    @label_offset_y = OFFSET_FROM_LABEL_Y
    @row_count      = 0
    @pixel_offset   = 0
  end

  #-----------------------------------------------------------------------------

  def add_label(id, label, has_label = false)
    id = (id.to_s + "_label").to_sym if !has_label
    add_control(id, UIControls::Label.new(*control_size(has_label), @viewport, label), has_label)
  end

  def add_labelled_label(id, label, text)
    add_label(id, label)
    add_label(id, text, true)
  end

  def add_underlined_label(id, label)
    ctrl = UIControls::Label.new(*control_size, @viewport, label)
    ctrl.underlined = true
    add_control(id, ctrl)
  end

  def add_header_label(id, label)
    ctrl = UIControls::Label.new(*control_size, @viewport, label)
    ctrl.header = true
    add_control(id, ctrl)
  end

  def add_checkbox(id, value, has_label = false)
    add_control(id, UIControls::Checkbox.new(*control_size(has_label), @viewport, value), has_label)
  end

  def add_labelled_checkbox(id, label, value)
    add_label(id, label)
    add_checkbox(id, value, true)
  end

  def add_text_box(id, value, has_label = false)
    add_control(id, UIControls::TextBox.new(*control_size(has_label), @viewport, value), has_label)
  end

  def add_labelled_text_box(id, label, value)
    add_label(id, label)
    add_text_box(id, value, true)
  end

  def add_number_slider(id, min_value, max_value, value, has_label = false)
    add_control(id, UIControls::NumberSlider.new(*control_size(has_label), @viewport, min_value, max_value, value), has_label)
  end

  def add_labelled_number_slider(id, label, min_value, max_value, value)
    add_label(id, label)
    add_number_slider(id, min_value, max_value, value, true)
  end

  def add_number_text_box(id, min_value, max_value, value, has_label = false)
    add_control(id, UIControls::NumberTextBox.new(*control_size(has_label), @viewport, min_value, max_value, value), has_label)
  end

  def add_labelled_number_text_box(id, label, min_value, max_value, value)
    add_label(id, label)
    add_number_text_box(id, min_value, max_value, value, true)
  end

  def add_fitted_number_text_box(id, min_value, max_value, value, has_label = false)
    add_control(id, UIControls::FittedNumberTextBox.new(*control_size(has_label), @viewport, min_value, max_value, value), has_label)
  end

  def add_labelled_fitted_number_text_box(id, label, min_value, max_value, value)
    add_label(id, label)
    add_number_text_box(id, min_value, max_value, value, true)
  end

  def add_button(id, button_text, has_label = false)
    add_control(id, UIControls::Button.new(*control_size(has_label, true), @viewport, button_text), has_label)
  end

  def add_labelled_button(id, label, button_text)
    add_label(id, label)
    add_button(id, button_text, true)
  end

  def add_fitted_button(id, button_text, has_label = false)
    add_control(id, UIControls::FittedButton.new(*control_size(has_label, true), @viewport, button_text), has_label)
  end

  def add_labelled_fitted_button(id, label, button_text)
    add_label(id, label)
    add_fitted_button(id, button_text, true)
  end

  def add_list(id, rows, options, has_label = false)
    size = control_size(has_label)
    size[0] -= 8
    size[1] = rows * UIControls::List::ROW_HEIGHT
    add_control(id, UIControls::List.new(*size, @viewport, options), has_label, rows)
  end

  def add_labelled_list(id, label, rows, options)
    add_label(id, label)
    add_list(id, rows, options, true)
  end

  def add_dropdown_list(id, options, value, has_label = false)
    add_control(id, UIControls::DropdownList.new(*control_size(has_label), @viewport, options, value), has_label)
  end

  def add_labelled_dropdown_list(id, label, options, value)
    add_label(id, label)
    add_dropdown_list(id, options, value, true)
  end

  def add_text_box_dropdown_list(id, options, value, has_label = false)
    add_control(id, UIControls::TextBoxDropdownList.new(*control_size(has_label), @viewport, options, value), has_label)
  end

  def add_labelled_text_box_dropdown_list(id, label, options, value)
    add_label(id, label)
    add_text_box_dropdown_list(id, options, value, true)
  end

  #-----------------------------------------------------------------------------

  def control_size(has_label = false, is_button = false)
    ctrl_height = (is_button) ? BUTTON_HEIGHT : LINE_SPACING
    if has_label
      return @width - @label_offset_x, ctrl_height - @label_offset_y
    end
    return @width, ctrl_height
  end

  def next_control_position(add_offset = false)
    row_x = self.x - @viewport.rect.x
    row_x += @label_offset_x if add_offset
    row_y = self.y - @viewport.rect.y + (@row_count * LINE_SPACING)
    row_y += @label_offset_y - LINE_SPACING if add_offset
    row_y += @pixel_offset
    return row_x, row_y
  end

  def add_control(id, control, add_offset = false, rows = 1)
    ctrl_x, ctrl_y = next_control_position(add_offset)
    case control
    when UIControls::List
      ctrl_x += 4
    when UIControls::Button, UIControls::FittedButton
      ctrl_y += (LINE_SPACING - BUTTON_HEIGHT) / 2
    end
    add_control_at(id, ctrl_x, ctrl_y, control)
    increment_row_count(rows) if !add_offset
    @pixel_offset -= (LINE_SPACING - UIControls::List::ROW_HEIGHT) * (rows - 1) if control.is_a?(UIControls::List)
  end

  def increment_row_count(count = 1)
    @row_count += count
  end
end
