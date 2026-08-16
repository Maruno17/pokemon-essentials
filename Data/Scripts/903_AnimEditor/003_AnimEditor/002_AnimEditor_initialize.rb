#===============================================================================
#
#===============================================================================
class AnimationEditor
  attr_reader :components
  attr_reader :anim

  include AnimationEditor::SettingsMixin
  include UIControls::StyleMixin

  #-----------------------------------------------------------------------------

  def initialize(anim_id, anim)
    load_settings
    @anim_id  = anim_id
    @anim     = anim
    @pbs_path = anim[:pbs_path]
    @quit     = false
    initialize_viewports
    initialize_bitmaps
    initialize_components
    @captured = nil
    @undo_history = []
    @redo_history = []
    set_components_contents
    self.color_scheme = @settings[:color_scheme]
    add_to_change_history
    refresh
  end

  def initialize_viewports
    @viewport = Viewport.new(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
    @viewport.z = 99999
    # TODO: It'd be nice if the Canvas component made this viewport instead.
    @canvas_viewport = Viewport.new(CANVAS_X, CANVAS_Y, CANVAS_WIDTH, CANVAS_HEIGHT)
    @canvas_viewport.z = @viewport.z
    @pop_up_viewport = Viewport.new(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
    @pop_up_viewport.z = @viewport.z + 200
  end

  def initialize_bitmaps
    # Background for main editor
    if !@screen_bitmap
      @screen_bitmap = BitmapSprite.new(WINDOW_WIDTH, WINDOW_HEIGHT, @viewport)
      @screen_bitmap.z = -100
    end
    # Semi-transparent black overlay to dim the screen while a pop-up window is open
    if !@pop_up_bg_bitmap
      @pop_up_bg_bitmap = BitmapSprite.new(WINDOW_WIDTH, WINDOW_HEIGHT, @pop_up_viewport)
      @pop_up_bg_bitmap.z = -100
      @pop_up_bg_bitmap.visible = false
    end
    # Draw in these bitmaps
    draw_editor_background
  end

  def initialize_components
    @components = {}
    # Menu bar
    @components[:menu_bar] = AnimationEditor::MenuBar.new(
      MENU_BAR_X, MENU_BAR_Y, MENU_BAR_WIDTH, MENU_BAR_HEIGHT, @viewport
    )
    @components[:menu_bar].anim_name = get_animation_display_name
    # Battlers layout
    @components[:battlers_layout] = AnimationEditor::BattlersLayout.new(
      BATTLERS_LAYOUT_X, BATTLERS_LAYOUT_Y, BATTLERS_LAYOUT_WIDTH, BATTLERS_LAYOUT_HEIGHT
    )
    # Play controls
    @components[:play_controls] = AnimationEditor::PlayControls.new(
      PLAY_CONTROLS_X, PLAY_CONTROLS_Y, PLAY_CONTROLS_WIDTH, PLAY_CONTROLS_HEIGHT, @viewport, @anim
    )
    # Canvas
    @components[:canvas] = AnimationEditor::Canvas.new(@canvas_viewport, @anim, @settings)
    # Timeline/particle list
    @components[:timeline] = AnimationEditor::Timeline.new(
      PARTICLE_LIST_X, PARTICLE_LIST_Y, PARTICLE_LIST_WIDTH, PARTICLE_LIST_HEIGHT,
      @viewport, @anim[:particles]
    )
    # Batch edits
    @components[:batch_edits] = AnimationEditor::BatchEdits.new(
      BATCH_EDITS_X, BATCH_EDITS_Y, BATCH_EDITS_WIDTH, BATCH_EDITS_HEIGHT
    )
    # Pop-up windows
    @components[:help] = UIControls::ListedContainer.new(
      HELP_X, HELP_Y, HELP_WIDTH, HELP_HEIGHT, @pop_up_viewport
    )
    @components[:help].label_offset_x = AnimationEditor::HELP_LABEL_WIDTH
    [:editor_settings, :animation_properties, :particle_properties].each do |pop_up|
      size = {
        :editor_settings      => [EDITOR_SETTINGS_X, EDITOR_SETTINGS_Y, EDITOR_SETTINGS_WIDTH, EDITOR_SETTINGS_HEIGHT],
        :animation_properties => [ANIM_PROPERTIES_X, ANIM_PROPERTIES_Y, ANIM_PROPERTIES_WIDTH, ANIM_PROPERTIES_HEIGHT],
        :particle_properties  => [PARTICLE_PROPERTIES_X, PARTICLE_PROPERTIES_Y, PARTICLE_PROPERTIES_WIDTH, PARTICLE_PROPERTIES_HEIGHT],
      }[pop_up]
      @components[pop_up] = UIControls::ListedContainer.new(
        size[0] + 4, size[1], size[2] - 8, size[3], @pop_up_viewport
      )
      @components[pop_up].label_offset_x = AnimationEditor::PROPERTIES_POPUP_LABEL_WIDTH
    end
    # Command batch editor
    @components[:command_batch_editor] = UIControls::BaseContainer.new(
      BATCH_EDITOR_X, BATCH_EDITOR_Y, BATCH_EDITOR_WINDOW_WIDTH, BATCH_EDITOR_WINDOW_HEIGHT, @pop_up_viewport
    )
    # Graphic chooser pop-up window
    @components[:graphic_chooser] = UIControls::ListedContainer.new(
      GRAPHIC_CHOOSER_X, GRAPHIC_CHOOSER_Y, GRAPHIC_CHOOSER_WINDOW_WIDTH, GRAPHIC_CHOOSER_WINDOW_HEIGHT, @pop_up_viewport
    )
    # Audio chooser pop-up window
    @components[:audio_chooser] = UIControls::ListedContainer.new(
      AUDIO_CHOOSER_X, AUDIO_CHOOSER_Y, AUDIO_CHOOSER_WINDOW_WIDTH, AUDIO_CHOOSER_WINDOW_HEIGHT, @pop_up_viewport
    )
  end

  def dispose
    @screen_bitmap.dispose
    @pop_up_bg_bitmap.dispose
    @components.each_value { |c| c.dispose }
    @components.clear
    @viewport.dispose
    @canvas_viewport.dispose
    @pop_up_viewport.dispose
  end

  #-----------------------------------------------------------------------------

  def keyframe
    return @components[:timeline].selected_keyframe
  end

  def particle_index
    return @components[:timeline].particle_index
  end

  def color_scheme=(value)
    return if @color_scheme == value
    @color_scheme = value
    return if !@components
    initialize_bitmaps
    @components.each do |component|
      component[1].color_scheme = value if component[1].respond_to?("color_scheme=")
    end
    refresh
  end

  #-----------------------------------------------------------------------------

  # Returns the animation's name for display in the menu bar and elsewhere.
  def get_animation_display_name
    ret = ""
    case @anim[:type]
    when :move       then ret += _INTL("[Move]")
    when :opp_move   then ret += _INTL("[Foe Move]")
    when :common     then ret += _INTL("[Common]")
    when :opp_common then ret += _INTL("[Foe Common]")
    else
      raise _INTL("Unknown animation type.")
    end
    case @anim[:type]
    when :move, :opp_move
      move_data = GameData::Move.try_get(@anim[:move])
      move_name = (move_data) ? move_data.name : @anim[:move]
      ret += " " + move_name
    when :common, :opp_common
      ret += " " + @anim[:move]
    end
    if @anim[:version] > 0 || @anim[:name]
      ret += "\n"
      if @anim[:version] > 0
        ret += "[" + @anim[:version].to_s + "]"
        ret += " " if @anim[:name]
      end
      ret += @anim[:name] if @anim[:name]
    end
    return ret
  end

  #-----------------------------------------------------------------------------

  def set_help_window_contents
    help_window = @components[:help]
    help_window.add_header_label(:header, _INTL("Help"))
    # Mouse controls
    help_window.add_underlined_label(:section_mouse, _INTL("Mouse controls"))
    help_window.add_labelled_label(:text_left_click, _INTL("Left click"), _INTL("Select/change something."))
    help_window.add_labelled_label(:text_left_drag, _INTL("Left click and drag"), _INTL("Move a command in the timeline, move a particle in the canvas, move through keyframes in the time bar."))
    help_window.add_labelled_label(:text_right_click, _INTL("Right click"), _INTL("Change the type of interpolation between two commands."))
    help_window.add_labelled_label(:text_right_drag, _INTL("Right click and drag"), _INTL("Rotate the selected particle in the canvas."))
    help_window.add_labelled_label(:text_scroll_wheel, _INTL("Scroll wheel"), _INTL("Scroll up/down in places where there is a scrollbar, change a particle's size in the canvas."))
    # Keyboard controls
    help_window.add_underlined_label(:section_keyboard, _INTL("Keyboard controls"))
    help_window.add_labelled_label(:text_esc, _INTL("Esc"), _INTL("Close any pop-up window (such as this one)."))
    help_window.add_labelled_label(:text_space, _INTL("Space"), _INTL("Play the animation, or stop it if it's playing."))
    help_window.add_labelled_label(:text_arrows, _INTL("Up/Down/Left/Right"), _INTL("Change which keyframe and row is selected. Hold Ctrl to move faster."))
    help_window.add_labelled_label(:text_tab, _INTL("Tab"), _INTL("Select the next particle. Hold Shift to select the previous particle instead."))
    help_window.add_labelled_label(:text_wasd, _INTL("W/A/S/D"), _INTL("Move the selected particle in the canvas. Hold Ctrl to move faster."))
    help_window.add_labelled_label(:text_delete, _INTL("Delete"), _INTL("Remove the command selected in the timeline."))
    help_window.add_labelled_label(:text_insert, _INTL("Insert"), _INTL("Add a command at the selected point in the timeline."))
    help_window.add_labelled_label(:text_undo, _INTL("Ctrl + Z"), _INTL("Undo."))
    help_window.add_labelled_label(:text_redo, _INTL("Ctrl + Y"), _INTL("Redo."))
    # Close button
    help_window.increment_row_count
    help_window.add_fitted_button(:close, _INTL("Close"))
    help_window.get_control(:close).x = help_window.x + ((help_window.width - help_window.get_control(:close).real_width) / 2)
    help_window.visible = false
  end

  def set_editor_settings_contents
    editor_settings = @components[:editor_settings]
    editor_settings.add_header_label(:header, _INTL("Editor settings"))
    # Misc settings
    editor_settings.add_labelled_dropdown_list(:color_scheme, _INTL("Color scheme"), color_scheme_options, :light)
    interps = {}
    GameData::Animation::INTERPOLATION_TYPES.each_pair { |name, id| interps[id] = name }
    editor_settings.add_labelled_dropdown_list(:default_interpolation, _INTL("Default interpolation"), interps, :linear)
    # Canvas graphics
    editor_settings.add_underlined_label(:canvas_header, _INTL("Canvas graphics"))
    editor_settings.add_labelled_dropdown_list(:canvas_bg, _INTL("Background graphic"), {}, "")
    editor_settings.add_labelled_dropdown_list(:user_sprite_name, _INTL("User graphic"), {}, "")
    ctrl = editor_settings.get_control(:user_sprite_name)
    ctrl.max_rows = 20
    editor_settings.add_labelled_dropdown_list(:target_sprite_name, _INTL("Target graphic"), {}, "")
    ctrl = editor_settings.get_control(:target_sprite_name)
    ctrl.max_rows = 20
    # Close button
    editor_settings.increment_row_count
    editor_settings.add_fitted_button(:close, _INTL("Close"))
    editor_settings.get_control(:close).x = editor_settings.x + ((editor_settings.width - editor_settings.get_control(:close).real_width) / 2)
    editor_settings.visible = false
  end

  def set_animation_properties_contents
    anim_properties = @components[:animation_properties]
    anim_properties.add_header_label(:header, _INTL("Animation properties"))
    # Identity
    anim_properties.add_underlined_label(:identity_label, _INTL("Identity"))
    anim_properties.add_labelled_dropdown_list(:type, _INTL("Animation type"), {
      :move   => _INTL("Move"),
      :common => _INTL("Common")
    }, :move)
    anim_properties.add_labelled_text_box_dropdown_list(:move, "", [], "")
    move_ctrl = anim_properties.get_control(:move)
    move_ctrl.max_rows = 20
    anim_properties.add_labelled_number_text_box(:version, _INTL("Version"), 0, 99, 0)
    anim_properties.add_labelled_text_box(:name, _INTL("Name"), "")
    anim_properties.add_labelled_text_box(:pbs_path, _INTL("PBS filepath"), "")
    # User and target locations
    anim_properties.add_underlined_label(:user_and_target_label, _INTL("User and target"))
    anim_properties.add_labelled_checkbox(:has_user, _INTL("Involves a user?"), true)
    anim_properties.add_labelled_checkbox(:opp_variant, _INTL("User is on far side?"), false)
    anim_properties.add_labelled_checkbox(:has_target, _INTL("Involves a target?"), true)
    # Playing
    anim_properties.add_underlined_label(:playing_label, _INTL("Playing"))
    anim_properties.add_labelled_number_text_box(:fps, _INTL("FPS"), 1, 100, 20)
    anim_properties.add_labelled_checkbox(:hides_data_boxes, _INTL("Hides data boxes?"), false)
    anim_properties.add_labelled_text_box(:scripts, _INTL("Scripts"), "")
    # Animation completion status
    anim_properties.add_underlined_label(:completion_label, _INTL("Completion"))
    anim_properties.add_labelled_checkbox(:usable, _INTL("Can be used in battle?"), true)
    # Other
    anim_properties.add_underlined_label(:other_label, _INTL("Other"))
    anim_properties.add_labelled_text_box(:credit, _INTL("Credit"), "")
    # Close button
    anim_properties.increment_row_count
    anim_properties.add_fitted_button(:close, _INTL("Close"))
    anim_properties.get_control(:close).x = anim_properties.x + ((anim_properties.width - anim_properties.get_control(:close).real_width) / 2)
    anim_properties.visible = false
  end

  def set_particle_properties_contents
    defaults = GameData::Animation::PARTICLE_DEFAULT_VALUES
    part_properties = @components[:particle_properties]
    part_properties.add_header_label(:header, _INTL("Particle properties"))
    # Misc
    part_properties.add_labelled_text_box(:name, _INTL("Name"), defaults[:name])
    part_properties.get_control(:name).set_blacklist("", "User", "Target", "SE")
    part_properties.add_labelled_dropdown_list(:focus, _INTL("Focus"), {}, defaults[:focus])
    part_properties.add_labelled_checkbox(:polar_coordinates, _INTL("Use polar coordinates?"), defaults[:polar_coordinates])
    # Graphic
    part_properties.add_underlined_label(:graphics_label, _INTL("Graphics"))
    part_properties.add_labelled_label(:graphic_name, _INTL("Graphic filename"), defaults[:graphic])
    part_properties.add_labelled_fitted_button(:graphic, "", _INTL("Change"))
    part_properties.add_labelled_label(:mask_graphic_name, _INTL("Mask graphic filename"), defaults[:mask_graphic])
    part_properties.add_labelled_fitted_button(:mask_graphic, "", _INTL("Change"))
    part_properties.add_labelled_checkbox(:tiled_graphic, _INTL("Tiled graphic?"), defaults[:tiled_graphic])
    part_properties.add_labelled_checkbox(:second_layer, _INTL("Has second layer?"), defaults[:second_layer])
    # OppMove replacements
    part_properties.add_underlined_label(:opposing_label, _INTL("If on opposing side..."))
    part_properties.add_labelled_checkbox(:foe_invert_x, _INTL("Invert X?"), defaults[:foe_invert_x])
    part_properties.add_labelled_checkbox(:foe_invert_y, _INTL("Invert Y?"), defaults[:foe_invert_y])
    part_properties.add_labelled_checkbox(:foe_invert_z, _INTL("Invert Z?"), defaults[:foe_invert_z])
    part_properties.add_labelled_checkbox(:foe_flip, _INTL("Flip sprite?"), defaults[:foe_flip])
    # Property overrides
    part_properties.add_underlined_label(:property_override_label, _INTL("Property base values"))
    initial_angles = {}
    GameData::Animation::PARTICLE_INITIAL_ANGLES.each_pair { |name, key| initial_angles[key] = name }
    part_properties.add_labelled_dropdown_list(:initial_angle, _INTL("Initial angle"), initial_angles, defaults[:initial_angle])
    # Randomization
    part_properties.add_underlined_label(:property_randomize_label, _INTL("Property randomization"))
    part_properties.add_labelled_number_text_box(:random_angle_range, _INTL("Random angle offset"), 0, 180, defaults[:random_angle_range])
    part_properties.add_labelled_checkbox(:random_invert_angle, _INTL("Randomly invert angle?"), defaults[:random_invert_angle])
    part_properties.add_labelled_checkbox(:random_invert_flip, _INTL("Randomly invert flip?"), defaults[:random_invert_flip])
    part_properties.add_labelled_number_text_box(:random_frame_max, _INTL("Random frame (max)"), 0, 99, defaults[:random_frame_max])
    # Emitter
    part_properties.add_underlined_label(:emitter_label, _INTL("Emitter properties"))
    emitter_types = {}
    # TODO: Is this okay using the in-PBS name of the emitter type?
    GameData::Animation::EMITTER_TYPES.each_pair { |name, key| emitter_types[key] = name }
    part_properties.add_labelled_dropdown_list(:emitter_type, _INTL("Emitter type"), emitter_types, defaults[:emitter_type])
    part_properties.add_labelled_number_text_box(:emitter_rate, _INTL("Emissions/second"), 1, 500, defaults[:emitter_rate])
    part_properties.add_labelled_number_text_box(:emitter_intensity, _INTL("Sprites/emission"), 1, 20, defaults[:emitter_intensity])
    part_properties.add_labelled_checkbox(:emitter_position_polar_coordinates, _INTL("Polar coords (position)?"), defaults[:emitter_position_polar_coordinates])
    part_properties.add_labelled_checkbox(:emitter_spawn_polar_coordinates, _INTL("Polar coords (spawn area)?"), defaults[:emitter_spawn_polar_coordinates])
    # Particle existence
    part_properties.add_fitted_button(:duplicate, _INTL("Duplicate this particle"))
    part_properties.add_fitted_button(:delete, _INTL("Delete this particle"))
    # Close button
    part_properties.increment_row_count
    part_properties.add_fitted_button(:close, _INTL("Close"))
    part_properties.get_control(:close).x = part_properties.x + ((part_properties.width - part_properties.get_control(:close).real_width) / 2)
    part_properties.visible = false
  end

  def set_command_batch_editor_contents
    editor = @components[:command_batch_editor]
    # Title
    editor.add_control_at(:title,
      editor.x + BATCH_EDITOR_PARTICLE_LIST_X,
      editor.y,
      UIControls::Label.new(editor.width, BATCH_EDITOR_ROW_HEIGHT, editor.viewport, _INTL("Apply offset to particle commands"))
    )
    editor.get_control(:title).header = true
    # Particle list
    editor.add_control_at(:particles_label,
      editor.x + BATCH_EDITOR_PARTICLE_LIST_X,
      editor.y + BATCH_EDITOR_PARTICLE_LIST_Y,
      UIControls::Label.new(BATCH_EDITOR_PARTICLE_LIST_WIDTH, BATCH_EDITOR_ROW_HEIGHT, editor.viewport, _INTL("Particles:"))
    )
    editor.add_control_at(:particles,
      editor.x + BATCH_EDITOR_PARTICLE_LIST_X,
      editor.y + BATCH_EDITOR_PARTICLE_LIST_Y + BATCH_EDITOR_ROW_HEIGHT,
      UIControls::CheckboxList.new(
        BATCH_EDITOR_PARTICLE_LIST_WIDTH, BATCH_EDITOR_PARTICLE_LIST_HEIGHT,
        editor.viewport, [], BATCH_EDITOR_PARTICLE_LIST_ROW_HEIGHT
      )
    )
    # Buttons beneath particle list
    list = editor.get_control(:particles)
    button_width = (list.width - BATCH_EDITOR_SPACING) / 2
    [[:select_all_particles, _INTL("Select all")],
     [:select_no_particles, _INTL("Select none")]].each_with_index do |btn, i|
      editor.add_control_at(btn[0],
        list.x + i * (button_width + BATCH_EDITOR_SPACING),
        list.y + list.height + BATCH_EDITOR_SPACING,
        UIControls::Button.new(button_width, BATCH_EDITOR_BUTTON_HEIGHT, editor.viewport, btn[1])
      )
    end
    # Keyframe range
    label_x = list.x + list.width + (BATCH_EDITOR_SPACING * 2)
    label_y = editor.y + BATCH_EDITOR_PARTICLE_LIST_Y
    keyframe_boxes_spacing = 32
    to_label_x_offset = 8   # Distance after the first NumberTextBox to draw the "~"
    editor.add_control_at(:keyframes_label,
      label_x,
      label_y,
      UIControls::Label.new(BATCH_EDITOR_LABEL_WIDTH, BATCH_EDITOR_ROW_HEIGHT, editor.viewport, _INTL("Keyframes:"))
    )
    editor.add_control_at(:keyframes_to_label,
      label_x + BATCH_EDITOR_LABEL_WIDTH + BATCH_EDITOR_NUMBER_BOX_WIDTH + to_label_x_offset,
      label_y,
      UIControls::Label.new(BATCH_EDITOR_LABEL_WIDTH, BATCH_EDITOR_ROW_HEIGHT, editor.viewport, "~")
    )
    [:start_keyframe, :end_keyframe].each_with_index do |ctrl, i|
      editor.add_control_at(ctrl,
        label_x + BATCH_EDITOR_LABEL_WIDTH + (i * (BATCH_EDITOR_NUMBER_BOX_WIDTH + keyframe_boxes_spacing)),
        label_y,
        UIControls::NumberTextBox.new(BATCH_EDITOR_NUMBER_BOX_WIDTH, BATCH_EDITOR_ROW_HEIGHT, editor.viewport, 0, 999, 0)
      )
    end
    # Each interpolable value
    label_y += BATCH_EDITOR_ROW_HEIGHT * 2
    plus_label_x_offset = 15   # Distance before a NumberTextBox to draw the "+"
    properties = []
    AnimationEditor::ListedParticle::PROPERTY_GROUPS.each_pair do |key, props|
      next if [:mask_group, :second_layer_group].include?(key)
      props.each do |prop|
        next if [:color, :tone].include?(prop)
        properties.push(prop) if GameData::Animation.property_can_interpolate?(prop)
      end
    end
    properties.each do |property|
      editor.add_control_at((property.to_s + "_label").to_sym,
        label_x,
        label_y,
        UIControls::Label.new(
          BATCH_EDITOR_LABEL_WIDTH, BATCH_EDITOR_ROW_HEIGHT,
          editor.viewport, GameData::Animation.property_display_name(property) + ":"
        )
      )
      editor.add_control_at((property.to_s + "_plus_label").to_sym,
        label_x + BATCH_EDITOR_LABEL_WIDTH - plus_label_x_offset,
        label_y,
        UIControls::Label.new(BATCH_EDITOR_LABEL_WIDTH, BATCH_EDITOR_ROW_HEIGHT, editor.viewport, "+")
      )
      editor.add_control_at(property,
        label_x + BATCH_EDITOR_LABEL_WIDTH,
        label_y,
        UIControls::NumberTextBox.new(BATCH_EDITOR_NUMBER_BOX_WIDTH, BATCH_EDITOR_ROW_HEIGHT, editor.viewport, -9999, 9999, 0)
      )
      label_y += BATCH_EDITOR_ROW_HEIGHT
    end
    # Close button
    editor.add_control_at(:close,
      editor.x + editor.width - BATCH_EDITOR_PARTICLE_LIST_X - BATCH_EDITOR_APPLY_BUTTON_WIDTH,
      editor.y + editor.height - (BATCH_EDITOR_SPACING - 1) - BATCH_EDITOR_BUTTON_HEIGHT,
      UIControls::Button.new(BATCH_EDITOR_APPLY_BUTTON_WIDTH, BATCH_EDITOR_BUTTON_HEIGHT, editor.viewport, _INTL("Close"))
    )
    # Apply button
    editor.add_control_at(:apply,
      editor.get_control(:close).x - BATCH_EDITOR_SPACING - BATCH_EDITOR_APPLY_BUTTON_WIDTH,
      editor.get_control(:close).y,
      UIControls::Button.new(BATCH_EDITOR_APPLY_BUTTON_WIDTH, BATCH_EDITOR_BUTTON_HEIGHT, editor.viewport, _INTL("Apply"))
    )
    editor.visible = false
  end

  def set_graphic_chooser_contents
    graphic_chooser = @components[:graphic_chooser]
    graphic_chooser.add_header_label(:header, _INTL("Choose a file"))
    # List of files
    list = UIControls::List.new(CHOOSER_FILE_LIST_WIDTH, CHOOSER_FILE_LIST_HEIGHT, graphic_chooser.viewport, [])
    graphic_chooser.add_control_at(:list,
                                   graphic_chooser.x + CHOOSER_FILE_LIST_X,
                                   graphic_chooser.y + CHOOSER_FILE_LIST_Y,
                                   list)
    # Filter
    filter_y = graphic_chooser.y + CHOOSER_FILE_LIST_Y + CHOOSER_FILE_LIST_HEIGHT + 2
    graphic_chooser.add_control_at(:filter_label,
      graphic_chooser.x + CHOOSER_FILE_LIST_X,
      filter_y,
      UIControls::Label.new(CHOOSER_FILE_LIST_WIDTH, CHOOSER_ROW_HEIGHT, graphic_chooser.viewport, _INTL("Filter:"))
    )
    graphic_chooser.add_control_at(:filter,
      graphic_chooser.x + CHOOSER_FILE_LIST_X + 60,
      filter_y,
      UIControls::TextBox.new(CHOOSER_FILE_LIST_WIDTH - 60 - 60 - 4, CHOOSER_ROW_HEIGHT, graphic_chooser.viewport, "")
    )
    graphic_chooser.add_control_at(:filter_clear,
      graphic_chooser.x + CHOOSER_FILE_LIST_X + CHOOSER_FILE_LIST_WIDTH - 60,
      filter_y + 2,
      UIControls::Button.new(60, 20, graphic_chooser.viewport, _INTL("Clear"))
    )
    # Buttons
    [[:ok, _INTL("OK")], [:cancel, _INTL("Cancel")]].each_with_index do |option, i|
      btn = UIControls::Button.new(CHOOSER_BUTTON_WIDTH, MESSAGE_BOX_BUTTON_HEIGHT, graphic_chooser.viewport, option[1])
      graphic_chooser.add_control_at(option[0],
                                     graphic_chooser.x + graphic_chooser.width - (CHOOSER_BUTTON_WIDTH * 2) - 4 - 3 + ((CHOOSER_BUTTON_WIDTH + 4) * i),
                                     list.y + list.height + CHOOSER_ROW_HEIGHT - MESSAGE_BOX_BUTTON_HEIGHT,
                                     btn)
    end
    graphic_chooser.visible = false
    graphic_chooser.z = 100
  end

  def set_audio_chooser_contents
    audio_chooser = @components[:audio_chooser]
    audio_chooser.add_header_label(:header, _INTL("Choose a file"))
    # List of files
    list = UIControls::List.new(CHOOSER_FILE_LIST_WIDTH, CHOOSER_FILE_LIST_HEIGHT, audio_chooser.viewport, [])
    audio_chooser.add_control_at(:list,
                                 audio_chooser.x + CHOOSER_FILE_LIST_X,
                                 audio_chooser.y + CHOOSER_FILE_LIST_Y,
                                 list)
    # Volume and pitch sliders
    [[:volume, _INTL("Volume"), 0, 100], [:pitch, _INTL("Pitch"), 0, 200]].each_with_index do |option, i|
      label = UIControls::Label.new(AUDIO_CHOOSER_LABEL_WIDTH, 28, audio_chooser.viewport, option[1])
      audio_chooser.add_control_at((option[0].to_s + "_label").to_sym,
                                   list.x + list.width + 6, list.y + (28 * i), label)
      slider = UIControls::NumberSlider.new(AUDIO_CHOOSER_SLIDER_WIDTH, 28, audio_chooser.viewport, option[2], option[3], 100)
      audio_chooser.add_control_at(option[0], label.x + label.width + 9, label.y, slider)
    end
    # Playback buttons
    [[:play, _INTL("Play")], [:stop, _INTL("Stop")]].each_with_index do |option, i|
      btn = UIControls::Button.new(CHOOSER_BUTTON_WIDTH, MESSAGE_BOX_BUTTON_HEIGHT, audio_chooser.viewport, option[1])
      audio_chooser.add_control_at(option[0],
                                   list.x + list.width + 4 + ((CHOOSER_BUTTON_WIDTH + 4) * i),
                                   list.y + (28 * 2),
                                   btn)
    end
    # Filter
    filter_y = audio_chooser.y + CHOOSER_FILE_LIST_Y + CHOOSER_FILE_LIST_HEIGHT + 2
    audio_chooser.add_control_at(:filter_label,
      audio_chooser.x + CHOOSER_FILE_LIST_X,
      filter_y,
      UIControls::Label.new(CHOOSER_FILE_LIST_WIDTH, CHOOSER_ROW_HEIGHT, audio_chooser.viewport, _INTL("Filter:"))
    )
    audio_chooser.add_control_at(:filter,
      audio_chooser.x + CHOOSER_FILE_LIST_X + 60,
      filter_y,
      UIControls::TextBox.new(CHOOSER_FILE_LIST_WIDTH - 60 - 60 - 4, CHOOSER_ROW_HEIGHT, audio_chooser.viewport, "")
    )
    audio_chooser.add_control_at(:filter_clear,
      audio_chooser.x + CHOOSER_FILE_LIST_X + CHOOSER_FILE_LIST_WIDTH - 60,
      filter_y + 2,
      UIControls::Button.new(60, 20, audio_chooser.viewport, _INTL("Clear"))
    )
    # Buttons
    [[:ok, _INTL("OK")], [:cancel, _INTL("Cancel")]].each_with_index do |option, i|
      btn = UIControls::Button.new(CHOOSER_BUTTON_WIDTH, MESSAGE_BOX_BUTTON_HEIGHT, audio_chooser.viewport, option[1])
      audio_chooser.add_control_at(option[0],
                                   audio_chooser.x + audio_chooser.width - (CHOOSER_BUTTON_WIDTH * 2) - 4 - 3 + ((CHOOSER_BUTTON_WIDTH + 4) * i),
                                   list.y + list.height + CHOOSER_ROW_HEIGHT - MESSAGE_BOX_BUTTON_HEIGHT,
                                   btn)
    end
    audio_chooser.visible = false
    audio_chooser.z = 100
  end

  def set_components_contents
    # Pop-up windows
    set_help_window_contents
    set_editor_settings_contents
    set_animation_properties_contents
    set_particle_properties_contents
    set_command_batch_editor_contents
    set_graphic_chooser_contents
    set_audio_chooser_contents
  end

  #-----------------------------------------------------------------------------

  def draw_editor_background
    bg_color = get_color_of(:background)
    contrast_color = get_color_of(:line)
    middle_color = get_color_of(:gray_background)
    # Fill the whole screen with white
    @screen_bitmap.bitmap.fill_rect(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, bg_color)
    # Outline around elements
    [
      [MENU_BAR_X, MENU_BAR_Y, MENU_BAR_WIDTH, MENU_BAR_HEIGHT],
      [CANVAS_X, CANVAS_Y, CANVAS_WIDTH, CANVAS_HEIGHT],
      [PLAY_CONTROLS_X, PLAY_CONTROLS_Y, PLAY_CONTROLS_WIDTH, PLAY_CONTROLS_HEIGHT],
      [BATTLERS_LAYOUT_X, BATTLERS_LAYOUT_Y, BATTLERS_LAYOUT_WIDTH, BATTLERS_LAYOUT_HEIGHT],
      [BATCH_EDITS_X, BATCH_EDITS_Y, BATCH_EDITS_WIDTH, BATCH_EDITS_HEIGHT],
      [PARTICLE_LIST_X, PARTICLE_LIST_Y, PARTICLE_LIST_WIDTH, PARTICLE_LIST_HEIGHT]
    ].each do |rect|
      @screen_bitmap.bitmap.border_rect(*rect, CONTAINER_BORDER, bg_color, contrast_color, middle_color)
    end
    # Make the pop-up background semi-transparent
    @pop_up_bg_bitmap.bitmap.fill_rect(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, get_color_of(:semi_transparent))
  end
end
