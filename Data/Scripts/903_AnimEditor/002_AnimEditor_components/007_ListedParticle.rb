#===============================================================================
# Contains the sprites and interactivity for all rows belonging to a single
# particle. Includes the particle list and its property controls, and the
# command diamonds/visibility boxes.
# Also remembers which particle groups are expanded for that particle.
#===============================================================================
class AnimationEditor::ListedParticle < UIControls::BaseContainer
  attr_reader   :particle
  attr_accessor :groups_expanded

  PROPERTY_GROUPS = {
    :position_group       => [:x, :y, :r, :theta, :z],
    :transformation_group => [:zoom_x, :zoom_y, :angle, :flip],
    :appearance_group     => [:visible, :opacity, :color, :tone, :invert_color, :frame, :blending],
    :mask_group           => [:mask_opacity, :mask_x, :mask_y, :mask_zoom_x, :mask_zoom_y, :mask_blending],
    :second_layer_group   => [:x2, :y2, :z2,
                              :zoom_x2, :zoom_y2, :angle2, :flip2,
                              :opacity2, :color2, :tone2, :invert_color2, :frame2, :blending2]
  }
  # NOTE: Any property in here that is also in PROPERTY_GROUPS above should be
  #       in the same group.
  EMITTER_PROPERTY_GROUPS = {
    :emitter_group                => [:emit_x, :emit_y, :emit_r, :emit_theta, :emitting],
    :emitted_spawn_location_group => [:emit_x_range, :emit_y_range, :emit_r_range, :emit_theta_range],
    :emitted_auto_movement_group  => [:emit_speed, :emit_speed_range,
                                      :emit_direction, :emit_direction_range,
                                      :emit_gravity, :emit_gravity_range,
                                      :emit_period_x, :emit_period_x_range,
                                      :emit_period_y, :emit_period_y_range,
                                      :emit_period_z, :emit_period_z_range,
                                      :emit_clockwise],
    :emitted_modifiers_group      => [:emit_x_multiplier, :emit_y_multiplier,
                                      :emit_radius_x_range, :emit_radius_y_range, :emit_radius_z_range,
                                      :emit_zoom_range, :emit_zoom_multiplier,
                                      :emit_zoom_x_range, :emit_zoom_y_range,
                                      :emit_opacity_multiplier],
    :position_group               => [:x, :y, :r, :theta, :z, :radius_x, :radius_y, :radius_z],
    :transformation_group         => [:zoom_x, :zoom_y, :angle, :flip],
    :appearance_group             => [:visible, :opacity, :color, :tone, :invert_color, :frame, :blending],
    :mask_group                   => [:mask_opacity, :mask_x, :mask_y, :mask_zoom_x, :mask_zoom_y, :mask_blending],
    :second_layer_group           => [:x2, :y2, :z2,
                                      :zoom_x2, :zoom_y2, :angle2, :flip2,
                                      :opacity2, :color2, :tone2, :invert_color2, :frame2, :blending2]
  }
  # These groups and their properties are used by all emitter types.
  EMITTER_GROUPS_ALWAYS_USED = [:emitter_group, :emitted_spawn_location_group]
  # The parameters in EMITTER_PROPERTY_GROUPS that aren't in PROPERTY_GROUPS
  # or in a group in EMITTER_GROUPS_ALWAYS_USED that are used for each emitter
  # type.
  USED_EMITTER_PARAMETERS = {
    :no_movement => [:emit_x_multiplier, :emit_y_multiplier,
                     :emit_zoom_range, :emit_zoom_multiplier,
                     :emit_zoom_x_range, :emit_zoom_y_range,
                     :emit_opacity_multiplier],
    :straight    => [:emit_speed, :emit_speed_range,
                     :emit_direction, :emit_direction_range,
                     :emit_x_multiplier, :emit_y_multiplier,
                     :emit_zoom_range, :emit_zoom_multiplier,
                     :emit_zoom_x_range, :emit_zoom_y_range,
                     :emit_opacity_multiplier],
    :projectile  => [:emit_speed, :emit_speed_range,
                     :emit_direction, :emit_direction_range,
                     :emit_gravity, :emit_gravity_range,
                     :emit_x_multiplier, :emit_y_multiplier,
                     :emit_zoom_range, :emit_zoom_multiplier,
                     :emit_zoom_x_range, :emit_zoom_y_range,
                     :emit_opacity_multiplier],
    :helix       => [:emit_speed, :emit_speed_range,   # Vertical speed
                     :emit_direction, :emit_direction_range,
                     :emit_period_x, :emit_period_x_range,
                     :emit_period_z, :emit_period_z_range,
                     :emit_clockwise,
                     :emit_x_multiplier, :emit_y_multiplier,
                     :emit_radius_x_range, :emit_radius_z_range,
                     :emit_zoom_range, :emit_zoom_multiplier,
                     :emit_zoom_x_range, :emit_zoom_y_range,
                     :emit_opacity_multiplier,
                     :radius_x, :radius_z],
    :polar       => [:emit_direction, :emit_direction_range,
                     :emit_period_x, :emit_period_x_range,
                     :emit_period_y, :emit_period_y_range,
                     :emit_clockwise,
                     :emit_x_multiplier, :emit_y_multiplier,
                     :emit_radius_x_range, :emit_radius_y_range,
                     :emit_zoom_range, :emit_zoom_multiplier,
                     :emit_zoom_x_range, :emit_zoom_y_range,
                     :emit_opacity_multiplier,
                     :radius_x, :radius_y]
  }

  ROW_HEIGHT      = 24
  ROW_SPACING     = 1
  FULL_ROW_HEIGHT = ROW_HEIGHT + ROW_SPACING
  LIST_ARROW_SIZE        = 20   # Size of bitmap showing the expanding arrow in group rows
  LIST_BOX_TOP_LEVEL_X   = 20
  LIST_BOX_INDENT_X      = 12   # Number of pixels per indent level
  CONTROL_X              = 128
  PROPERTIES_BUTTON_SIZE = 20   # Full size of button; bitmap in the button is 12

  DIAMOND_SIZE          = 3   # Actual overall size is double this + 1 = 7
  TIMELINE_LEFT_SPACING = AnimationEditor::Timeline::TIME_BAR_LEFT_BUFFER
  INTERP_LINE_HEIGHT    = AnimationEditor::Timeline::KEYFRAME_SPACING - ((DIAMOND_SIZE * 2) + 3)
  INTERP_LINE_Y         = (ROW_HEIGHT / 2) - (INTERP_LINE_HEIGHT / 2)

  INTERP_PICKER_SPACING     = 2
  INTERP_PICKER_BUTTON_SIZE = 20   # Full size of button; bitmap in the button is 12
  INTERP_PICKER_WIDTH       = ((INTERP_PICKER_BUTTON_SIZE + INTERP_PICKER_SPACING) * GameData::Animation::INTERPOLATION_TYPES.length) + INTERP_PICKER_SPACING + 2
  INTERP_PICKER_HEIGHT      = INTERP_PICKER_BUTTON_SIZE + (INTERP_PICKER_SPACING * 2) + 2

  # NOTE: @rows[row] is an array of things (sprites, controls) with specific
  #       indices. These are the indices.
  LIST_SPRITE       = 0
  LIST_ARROW        = 1
  LIST_CONTROL      = 2
  COMMAND_BG_SPRITE = 3
  COMMAND_SPRITE    = 4

  def initialize(particle, main_viewport, list_viewport, timeline_viewport, timeline_bg_viewport)
    @particle             = particle
    @main_viewport        = main_viewport
    @list_viewport        = list_viewport
    @timeline_viewport    = timeline_viewport
    @timeline_bg_viewport = timeline_bg_viewport
    # Key is a symbol from PROPERTY_GROUPS or EMITTER_PROPERTY_GROUPS or :main
    # Value is an array of sprites and controls
    @groups_expanded = {:main => false}
    @rows = {:main => []}
    @commands = {}
    @group_commands = {}
    [PROPERTY_GROUPS, EMITTER_PROPERTY_GROUPS].each do |part_type|
      part_type.each_pair do |key, properties|
        @groups_expanded[key] = false
        @rows[key] = []
        properties.each { |prop| @rows[prop] = [] }
      end
    end
    @timeline_ox = 0
    @timeline_oy = 0
    @duration = 0
    @selected_keyframe = 0
    super(0, 0, 0, 0)
    ensure_rows
    refresh_values
  end

  # Intentionally blank, prevents making an unnecessary viewport.
  def initialize_viewport; end

  # NOTE: This method is also called when changing the color scheme.
  def initialize_bitmaps
    icon_color = get_color_of(:text)
    # Expandable arrow to left of listed particle
    arrow_graphic = %w(
      . . . . . . . . . . . . . . . . . . . .
      . . . . . . . . . . . . . . . . . . . .
      . . . . . . . . . . . . . . . . . . . .
      . . . . . . . . . . . . . . . . . . . .
      . . . . . . . . X X . . . . . . . . . .
      . . . . . . . X X X X . . . . . . . . .
      . . . . . . . X X X X X . . . . . . . .
      . . . . . . . X X X X X X . . . . . . .
      . . . . . . . X X X X X X X . . . . . .
      . . . . . . . X X X X X X X X . . . . .
      . . . . . . . X X X X X X X . . . . . .
      . . . . . . . X X X X X X . . . . . . .
      . . . . . . . X X X X X . . . . . . . .
      . . . . . . . X X X X . . . . . . . . .
      . . . . . . . . X X . . . . . . . . . .
      . . . . . . . . . . . . . . . . . . . .
      . . . . . . . . . . . . . . . . . . . .
      . . . . . . . . . . . . . . . . . . . .
      . . . . . . . . . . . . . . . . . . . .
      . . . . . . . . . . . . . . . . . . . .
    )
    @bitmaps[:collapsed_arrow] = Bitmap.new(LIST_ARROW_SIZE, LIST_ARROW_SIZE) if !@bitmaps[:collapsed_arrow]
    @bitmaps[:collapsed_arrow].clear
    @bitmaps[:expanded_arrow] = Bitmap.new(LIST_ARROW_SIZE, LIST_ARROW_SIZE) if !@bitmaps[:expanded_arrow]
    @bitmaps[:expanded_arrow].clear
    arrow_graphic.length.times do |i|
      next if arrow_graphic[i] == "."
      @bitmaps[:collapsed_arrow].fill_rect(i % LIST_ARROW_SIZE, i / LIST_ARROW_SIZE, 1, 1, icon_color)
      @bitmaps[:expanded_arrow].fill_rect(i / LIST_ARROW_SIZE, i % LIST_ARROW_SIZE, 1, 1, icon_color)
    end
    # Particle properties button graphic
    properties_graphic = %w(
      . . . . . . . . . . . .
      . X X X X X . . . X X .
      . . . . . . . . . . . .
      . X X X . . . . X X X .
      . . . . . . . . . . . .
      . X X X X . . . X X X .
      . . . . . . . . . . . .
      . X X X X . . . . . X .
      . . . . . . . . . . . .
      . X X X X X . . X X X .
      . . . . . . . . . . . .
      . . . . . . . . . . . .
    )
    properties_bitmap_size = PROPERTIES_BUTTON_SIZE - (UIControls::Button::BUTTON_FRAME_THICKNESS * 2)   # 12
    @bitmaps[:properties] = Bitmap.new(properties_bitmap_size, properties_bitmap_size) if !@bitmaps[:properties]
    @bitmaps[:properties].clear
    properties_graphic.length.times do |i|
      next if properties_graphic[i] == "."
      @bitmaps[:properties].fill_rect(i % properties_bitmap_size, i / properties_bitmap_size, 1, 1, icon_color)
    end
    initialize_interpolation_bitmaps
  end

  # These are for BitmapButtons that appear when right-clicking between two
  # commands.
  def initialize_interpolation_bitmaps
    interp_bitmap_size = INTERP_PICKER_BUTTON_SIZE - (UIControls::Button::BUTTON_FRAME_THICKNESS * 2)   # 12
    GameData::Animation::INTERPOLATION_TYPES.each_pair do |name, id|
      @bitmaps[id] = Bitmap.new(interp_bitmap_size, interp_bitmap_size) if !@bitmaps[id]
      @bitmaps[id].clear
      next if id == :none
      @bitmaps[id].draw_interpolation_line(0, 0, interp_bitmap_size, interp_bitmap_size,
                                           true, id, get_color_of(:line))
    end
  end

  def initialize_controls
    @clickable_area = UIControls::ClickableArea.new(
      @timeline_viewport.rect.width, @timeline_viewport.rect.height,
      @main_viewport, false, true
    )
    @clickable_area.x = @timeline_viewport.rect.x
    @clickable_area.y = @timeline_viewport.rect.y
    @clickable_area.set_interactive_rects
  end

  def dispose
    remove_interpolation_picker
    @rows.each_value do |objs|
      objs.each { |obj| obj&.dispose }
      objs.clear
    end
    @clickable_area.dispose
    @clickable_area = nil
    super
  end

  #-----------------------------------------------------------------------------

  def group_name(group)
    return {
      :position_group               => _INTL("Position"),
      :transformation_group         => _INTL("Transformation"),
      :appearance_group             => _INTL("Appearance"),
      :mask_group                   => _INTL("Bitmap mask"),
      :second_layer_group           => _INTL("Second layer"),
      :emitter_group                => _INTL("Emitter"),
      :emitted_spawn_location_group => _INTL("Emitted spawn location"),
	    :emitted_auto_movement_group  => _INTL("Emitted auto-movement"),
	    :emitted_modifiers_group      => _INTL("Emitted modifiers"),
    }[group] || group.to_s.capitalize
  end

  def color_scheme=(value)
    return if @color_scheme == value
    @color_scheme = value
    return if @bitmaps.empty?   # Nothing has been initialized yet
    initialize_bitmaps
    @rows.each_value do |objs|
      objs[LIST_ARROW]&.color_scheme = value
      objs[LIST_CONTROL]&.color_scheme = value
    end
    refresh
  end

  #-----------------------------------------------------------------------------

  def is_emitter?
    return @particle[:emitter_type] && @particle[:emitter_type] != :none
  end

  def duration=(value)
    return if @duration == value
    @duration = value
    calculate_all_commands
    refresh_timeline
  end

  def selected_keyframe=(value)
    return if @selected_keyframe == value
    @selected_keyframe = value
    refresh_values
  end

  def timeline_ox=(value)
    return if @timeline_ox == value
    @timeline_ox = value
    refresh_timeline
  end

  def get_control(id)
    return @rows[id][LIST_CONTROL]
  end

  def row_and_keyframe_for_coords(mouse_x, mouse_y, nearest_command = true, ignore_duration = false)
    mouse_x += AnimationEditor::Timeline::KEYFRAME_SPACING / 2 if nearest_command
    this_keyframe = (mouse_x - AnimationEditor::Timeline::TIME_BAR_LEFT_BUFFER) / AnimationEditor::Timeline::KEYFRAME_SPACING
    return nil, nil if this_keyframe < 0 || (!ignore_duration && this_keyframe > @duration)
    this_row = nil
    each_row_in_order do |key, row_visible|
      next if !row_visible || !@rows[key] || !@rows[key][LIST_SPRITE]
      next if @rows[key][LIST_SPRITE].y > mouse_y
      next if @rows[key][LIST_SPRITE].y + ROW_HEIGHT <= mouse_y
      this_row = key
      break
    end
    return nil, nil if !this_row
    return this_row, this_keyframe
  end

  def emitter_only_row?(row)
    return false if row == :main
    group = group_for_row(row)
    return !PROPERTY_GROUPS.has_key?(row) if group == :main
    return !PROPERTY_GROUPS[group]&.include?(row)
  end

  # TODO: Hide rows for properties that are disabled? e.g. :focus if the graphic
  #       isn't a spritesheet (determined elsewhere). I don't think any other
  #       properties would need this.
  def row_always_hidden?(row)
    # Cartesian or polar coordinates - hide the unused ones
    if @particle[:polar_coordinates]
      return true if [:x, :y].include?(row)
    else
      return true if [:r, :theta].include?(row)
    end
    # Cartesian or polar coordinates - hide the unused ones for emitters
    if @particle[:emitter_polar_coordinates]
      return true if [:emit_x, :emit_y, :emit_x_range, :emit_y_range].include?(row)
    else
      return true if [:emit_r, :emit_theta, :emit_r_range, :emit_theta_range].include?(row)
    end
    # Mask group
    if (@particle[:mask_graphic] || "") == "" &&
       (row == :mask_group || PROPERTY_GROUPS[:mask_group].include?(row))
      return true
    end
    # Second layer group
    if !@particle[:second_layer] &&
       (row == :second_layer_group || GameData::Animation::SECOND_LAYER_PROPERTIES.include?(row))
      return true
    end
    # Emitter-only groups for non-emitter particles
    if !is_emitter? && EMITTER_PROPERTY_GROUPS.has_key?(row) &&
       !PROPERTY_GROUPS.has_key?(row)
      return true
    end
    # Emitter-only rows/groups for emitter particles
    if is_emitter? && emitter_only_row?(row)
      group = group_for_row(row)
      # Emitter rows that are unused by the emitter type
      return true if group != :main && !EMITTER_GROUPS_ALWAYS_USED.include?(group) &&
                     USED_EMITTER_PARAMETERS[@particle[:emitter_type]] &&
                     !USED_EMITTER_PARAMETERS[@particle[:emitter_type]].include?(row)
      # Emitter groups that are empty
      return true if EMITTER_PROPERTY_GROUPS.has_key?(row) &&
                     !EMITTER_GROUPS_ALWAYS_USED.include?(row) &&
                     USED_EMITTER_PARAMETERS[@particle[:emitter_type]] &&
                     (EMITTER_PROPERTY_GROUPS[row] & USED_EMITTER_PARAMETERS[@particle[:emitter_type]]).empty?
    end
    return false
  end

  # This method yields every possible group/row, to ensure that changing the
  # emitter type doesn't result in certain groups/rows lingering without being
  # hidden.
  def each_row_in_order
    yield :main, true
    groups_visible = @groups_expanded[:main]
    to_yield = (is_emitter?) ? EMITTER_PROPERTY_GROUPS : PROPERTY_GROUPS
    other_to_yield = (is_emitter?) ? PROPERTY_GROUPS : EMITTER_PROPERTY_GROUPS
    yielded = []
    to_yield.each_pair do |key, properties|
      if key != :main
        yield key, !row_always_hidden?(key) && groups_visible
        yielded.push(key)
      end
      group_visible = @groups_expanded[key]
      properties.each do |property|
        yield property, !row_always_hidden?(property) && groups_visible && group_visible
        yielded.push(property)
      end
    end
    other_to_yield.each_pair do |key, properties|
      yield key, false if key != :main && !yielded.include?(key)
      properties.each { |property| yield property, false if !yielded.include?(property) }
    end
  end

  # Given a row number, returns the property that row is for. Counts displayed
  # rows only, and returns nil if that row is :main or a group.
  def property_of_row(row_index)
    ret = nil
    row_count = 0
    each_row_in_order do |row, row_visible|
      next if !row_visible
      ret = row
      row_count += 1
      break if row_count > row_index
    end
    return nil if ret == :main || PROPERTY_GROUPS.has_key?(ret) || EMITTER_PROPERTY_GROUPS.has_key?(ret)
    return ret
  end

  def row_is_property?(row)
    return PROPERTY_GROUPS.any? { |key, properties| properties.include?(row) } ||
           EMITTER_PROPERTY_GROUPS.any? { |key, properties| properties.include?(row) }
  end

  # Returns the group that row sits under. This may be a key from
  # PROPERTY_GROUPS or EMITTER_PROPERTY_GROUPS, or :main, or nil (if row is
  # :main).
  def group_for_row(row)
    return nil if row == :main
    groups = (is_emitter?) ? EMITTER_PROPERTY_GROUPS : PROPERTY_GROUPS
    return :main if groups.has_key?(row)
    ret = nil
    groups.each_pair { |key, properties| ret = key if properties.include?(row) }
    return ret
  end

  def visible_rows_count
    ret = 0
    each_row_in_order { |row, row_visible| ret += 1 if row_visible }
    return ret
  end

  # NOTE: Changing the visibility of sprites/controls and their y positions is
  #       done in def refresh_all_row_positions_and_visibilities, which should
  #       be called immediately after this method.
  def toggle_group_visibility(row)
    @groups_expanded[row] = !@groups_expanded[row]
    draw_list_sprite(row)
    refresh_values
  end

  def each_visible_keyframe
    full_width = @timeline_viewport.rect.width
    start_keyframe = ((@timeline_ox - TIMELINE_LEFT_SPACING) / AnimationEditor::Timeline::KEYFRAME_SPACING)
    start_keyframe = 0 if start_keyframe < 0
    end_keyframe = ((@timeline_ox + full_width) / AnimationEditor::Timeline::KEYFRAME_SPACING)
    (start_keyframe..end_keyframe).each { |i| yield i }
  end

  #-----------------------------------------------------------------------------

  def calculate_all_commands
    @commands.clear
    @group_commands.clear
    @particle.each_pair do |property, value|
      next if !value.is_a?(Array)
      group = group_for_row(property)
      cmds = AnimationEditor::ParticleDataHelper.get_particle_property_commands_timeline(@particle, property, value)
      @commands[property] = cmds
      cmds.each_with_index do |cmd, i|
        next if !cmd
        @group_commands[group] ||= []
        @group_commands[group][i] = [0, :none]
        @group_commands[:main] ||= []
        @group_commands[:main][i] = [0, :none]
      end
    end
    # Calculate visibilities for every keyframe
    @visibilities = AnimationEditor::ParticleDataHelper.get_timeline_particle_visibilities(
      @particle, @duration
    )
    @emitter_visibilities = AnimationEditor::ParticleDataHelper.get_timeline_particle_visibilities(
      @particle, @duration, AnimationPlayer::Emitter::PARTICLE_PROPERTIES
    )
  end

  def commands_for_row(row)
    ret = @group_commands[row] || @commands[row]
    if @command_move_current && row == @command_move_start[0] &&
       @command_move_current != @command_move_start[1]
      ret = AnimationEditor::ParticleDataHelper.move_command_in_commands_timeline(
        ret, @command_move_start[1], @command_move_current
      )
    end
    return ret
  end

  #-----------------------------------------------------------------------------

  # Creates the sprites and controls for the given row.
  def create_row_contents(row)
    return if !@rows[row].empty?
    refresh_row(row)
    create_list_expand_arrow(row)
    create_list_control(row)
  end

  # Goes through all rows and ensures sprites/controls exist for visible ones.
  def ensure_rows
    create_row_contents(:main)
    if @groups_expanded[:main]
      groups = (is_emitter?) ? EMITTER_PROPERTY_GROUPS : PROPERTY_GROUPS
      groups.keys.each { |key| create_row_contents(key) }
      groups.each_pair do |key, properties|
        next if !@groups_expanded[key]
        properties.each { |prop| create_row_contents(prop) }
      end
    end
    refresh_values
  end

  def set_row_position_and_visibility(row, vis, y_pos)
    create_row_contents(row) if vis
    @rows[row].each_with_index do |obj, i|
      next if !obj
      obj.visible = vis
      obj.y = y_pos + ((FULL_ROW_HEIGHT - obj.height) / 2) if vis
    end
    if @rows[row][LIST_ARROW] && @groups_expanded.has_key?(row)
      @rows[row][LIST_ARROW].value = (@groups_expanded[row] ? 1 : 0)
    end
    refresh_values
  end

  #-----------------------------------------------------------------------------

  # TODO: Somehow highlight the area of the row that this is choosing an
  #       interpolation for?
  def make_interpolation_picker
    return if @picker_box
    # Viewport
    mouse_coords = Mouse.getMousePos
    view_x = mouse_coords[0] - (INTERP_PICKER_WIDTH / 2)
    view_y = @rows[@interpolation_target[0]][COMMAND_SPRITE].y + ROW_HEIGHT + self.y + @timeline_viewport.rect.y - @timeline_viewport.oy
    if view_x + (INTERP_PICKER_WIDTH / 2) > Graphics.width
      view_x = Graphics.width - INTERP_PICKER_WIDTH
    end
    if view_y + INTERP_PICKER_HEIGHT >= Graphics.height
      view_y -= ROW_HEIGHT + INTERP_PICKER_HEIGHT
    end
    @picker_box_viewport = Viewport.new(view_x, view_y, INTERP_PICKER_WIDTH, INTERP_PICKER_HEIGHT)
    @picker_box_viewport.z = @timeline_viewport.z + 100
    # Picker box's background (white box with outline)
    @picker_box = BitmapSprite.new(INTERP_PICKER_WIDTH, INTERP_PICKER_HEIGHT, @picker_box_viewport)
    @picker_box.z = -100
    @picker_box.bitmap.fill_rect(0, 0, @picker_box.width, @picker_box.height,
                                 get_color_of(:background))
    @picker_box.bitmap.outline_rect(0, 0, @picker_box.width, @picker_box.height,
                                    get_color_of(:line))
    # Picker controls
    @picker_controls ||= {}
    control_x = INTERP_PICKER_SPACING + 1
    GameData::Animation::INTERPOLATION_TYPES.each_pair do |name, id|
      @picker_controls[id] = UIControls::BitmapButton.new(@picker_box_viewport, @bitmaps[id])
      @picker_controls[id].x = control_x
      @picker_controls[id].y = INTERP_PICKER_SPACING + 1
      @picker_controls[id].color_scheme = @color_scheme
      @picker_controls[id].set_interactive_rects
      control_x += INTERP_PICKER_BUTTON_SIZE + INTERP_PICKER_SPACING
    end
  end

  def remove_interpolation_picker
    @picker_controls&.each_value { |ctrl| ctrl&.dispose }
    @picker_controls = nil
    @picker_box&.dispose
    @picker_box = nil
    @picker_box_viewport&.dispose
    @picker_box_viewport = nil
    @picker_captured = nil
    @interpolation_target = nil
  end

  def choosing_interpolation?
    return !@picker_box.nil? || @toggling_picker_box
  end

  #-----------------------------------------------------------------------------

  # Refreshes any controls that have changed.
  def repaint
    return if disposed?
    super
    @rows.each_pair do |row, objs|
      objs[LIST_ARROW]&.repaint if objs[LIST_ARROW]&.visible
      objs[LIST_CONTROL]&.repaint if objs[LIST_CONTROL]&.visible
    end
  end

  def refresh
    calculate_all_commands
    @rows.each_pair do |row, objs|
      refresh_row(row) if !@rows[row].empty?
    end
    refresh_values
    repaint
  end

  def refresh_row(row)
    draw_list_sprite(row)
    draw_timeline_sprite(row)
    draw_timeline_bg_sprite(row)
  end

  def refresh_values
    if @particle[:name] == "SE"
      vals = AnimationEditor::ParticleDataHelper.get_all_particle_se_at_frame(@particle, @selected_keyframe)
      new_vals = []
      vals.each do |val|
        text = AnimationEditor::ParticleDataHelper.get_se_display_text(val[0], val)
        new_vals.push(text)
      end
      @rows[:main][LIST_CONTROL].value = new_vals
      @rows[:main][LIST_CONTROL].repaint
      return
    end
    new_vals = AnimationEditor::ParticleDataHelper.get_all_keyframe_particle_values(@particle, @selected_keyframe)
    @rows.each_pair do |row, objs|
      next if !objs[LIST_CONTROL] || !row_is_property?(row)
      if row == :z
        objs[LIST_CONTROL].min_value = AnimationEditor::PROPERTY_RANGES[:z][0]
        if GameData::Animation::FOCUS_TYPES_WITH_USER_AND_TARGET.include?(@particle[:focus])
          objs[LIST_CONTROL].min_value += GameData::Animation::USER_AND_TARGET_SEPARATION[2]
        end
      end
      objs[LIST_CONTROL].value = new_vals[row][0]
      objs[LIST_CONTROL].repaint if objs[LIST_CONTROL].visible
    end
  end

  def refresh_timeline
    @rows.each_pair do |row, objs|
      next if !objs || !objs[COMMAND_SPRITE] || !objs[COMMAND_SPRITE].visible
      draw_timeline_sprite(row)
      draw_timeline_bg_sprite(row)
    end
  end

  # Called from above. Used in conjunction with visible_rows_count to reposition
  # the rows for all particles.
  def refresh_all_row_positions_and_visibilities(row_index)
    y_pos = ROW_SPACING + (row_index * (ROW_HEIGHT + ROW_SPACING))
    each_row_in_order do |row, row_visible|
      set_row_position_and_visibility(row, row_visible, y_pos)
      y_pos += ROW_HEIGHT + ROW_SPACING if row_visible
    end
  end

  #-----------------------------------------------------------------------------

  # NOTE: If @command_move_current = nil, the command hasn't been moved at all,
  #       so its command diamond won't look any different. That's why it isn't
  #       initially set - just clicking on a command without intending to drag
  #       it elsewhere shouldn't make it look different.
  def update_command_moving
    # Command is dropped; record it as moved if it has been moved
    if Input.release?(Input::MOUSELEFT)
      if @command_move_current && @command_move_current != @command_move_start[1]
        @changed_controls ||= {}   # [property, start keyframe, end keyframe]
        @changed_controls[:move_command] = [nil, [*@command_move_start, @command_move_current]]
      end
      this_row = @command_move_start[0]
      @command_move_start = nil
      @command_move_current = nil
      @command_move_limits = nil
      draw_timeline_sprite(this_row)   # Refresh row
      return
    end
    # Check for mouse movement
    mouse_x, mouse_y = @clickable_area.mouse_pos
    return if !mouse_x || !mouse_y
    mouse_x += @timeline_ox
    mouse_y += @timeline_viewport.oy
    _this_row, this_keyframe = row_and_keyframe_for_coords(mouse_x, mouse_y, true, true)
    return if !this_keyframe
    this_keyframe = @command_move_limits[0] if @command_move_limits[0] && this_keyframe < @command_move_limits[0]
    this_keyframe = @command_move_limits[1] if @command_move_limits[1] && this_keyframe > @command_move_limits[1]
    if (@command_move_current && this_keyframe != @command_move_current) ||
       (@command_move_current.nil? && this_keyframe != @command_move_start[1])
      @command_move_current = this_keyframe
      draw_timeline_sprite(@command_move_start[0])   # Refresh row
    end
  end

  def update_interpolation_picker
    close_picker = false
    # Update controls
    if @captured
      @captured.update
      @captured = nil if !@captured.busy?
    else
      @picker_controls.each_value do |ctrl|
        ctrl&.update
        @captured = ctrl if ctrl&.busy?
      end
      if !@captured && Input.trigger?(Input::MOUSELEFT)
        mouse_coords = Mouse.getMousePos
        if mouse_coords && !@picker_box_viewport.rect.contains?(*mouse_coords)
          close_picker = true
        end
      end
    end
    # Check for updated controls
    @picker_controls&.each_pair do |id, ctrl|
      next if !ctrl.changed?
      @changed_controls ||= {}
      @changed_controls[id] = [LIST_CONTROL, @interpolation_target]
      ctrl.clear_changed
      close_picker = true
    end
    if close_picker
      remove_interpolation_picker
      @toggling_picker_box = true
      refresh
    end
    # Redraw controls if needed
    @picker_controls&.each_value { |ctrl| ctrl.repaint }
  end

  # Area was newly clicked; decide what to do based on where and how it was
  # clicked
  def update_clickable_area
    mouse_x, mouse_y = @clickable_area.mouse_pos
    return if !mouse_x || !mouse_y
    mouse_x += @timeline_ox
    mouse_y += @timeline_viewport.oy
    if @clickable_area.left_clicked?
      this_row, this_keyframe = row_and_keyframe_for_coords(mouse_x, mouse_y, true)
      # TODO: Maybe allow dragging commands in group rows/:main?
      if this_row && (row_is_property?(this_row) || (@particle[:name] == "SE"))
        cmds = commands_for_row(this_row)
        if cmds && cmds[this_keyframe]
          lower_limit = nil
          upper_limit = nil
          cmds.each_with_index do |cmd, i|
            next if !cmd
            lower_limit = i if i < this_keyframe
            upper_limit = i if i > this_keyframe && upper_limit.nil?
          end
          lower_limit += 1 if lower_limit
          upper_limit -= 1 if upper_limit
          if lower_limit.nil? || upper_limit.nil? || lower_limit != upper_limit
            @command_move_start = [this_row, this_keyframe]
            @command_move_limits = [lower_limit, upper_limit]
          end
        end
      end
      @clickable_area.make_not_busy
      @clickable_area.clear_changed
    elsif @clickable_area.right_clicked?
      this_row, this_keyframe = row_and_keyframe_for_coords(mouse_x, mouse_y, false)
      if this_row && row_is_property?(this_row) && GameData::Animation.property_can_interpolate?(this_row)
        cmds = commands_for_row(this_row)
        if cmds
          has_earlier = false
          (0..this_keyframe).each do |keyfr|
            next if !cmds[keyfr]
            has_earlier = true
            break
          end
          if has_earlier && cmds.length > this_keyframe + 1
            @interpolation_target = [this_row, this_keyframe]
            make_interpolation_picker
          end
        end
      end
      @clickable_area.make_not_busy
      @clickable_area.clear_changed
    end
  end

  def update
    return if disposed? || !@visible
    @toggling_picker_box = false
    # Update controls
    if @command_move_start
      update_command_moving
      return
    elsif @picker_box
      update_interpolation_picker
      return
    elsif @captured
      @captured.update
      @captured = nil if !@captured.busy?
    else
      @rows.each_value do |objs|
        [LIST_ARROW, LIST_CONTROL].each do |obj|
          objs[obj]&.update
          @captured = objs[obj] if objs[obj]&.busy?
        end
      end
      if !@captured
        @clickable_area.update
        update_clickable_area if @clickable_area.busy?
      end
    end
    # Check for updated controls
    @rows.each_pair do |id, objs|
      [LIST_ARROW, LIST_CONTROL].each do |obj|
        next if !objs[obj]&.changed?
        @changed_controls ||= {}
        @changed_controls[id] = [obj, objs[obj].value]
        objs[obj].clear_changed
      end
    end
    repaint
  end
end
