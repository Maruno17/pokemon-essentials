#===============================================================================
#
#===============================================================================
class AnimationEditor
  MENU_BAR_X      = CONTAINER_BORDER
  MENU_BAR_Y      = CONTAINER_BORDER
  MENU_BAR_WIDTH  = AnimationEditor::MenuBar::TOTAL_WIDTH   # 258
  MENU_BAR_HEIGHT = AnimationEditor::MenuBar::TOTAL_HEIGHT   # 74

  CANVAS_X      = MENU_BAR_X + MENU_BAR_WIDTH + (CONTAINER_BORDER * 2)
  CANVAS_Y      = CONTAINER_BORDER
  CANVAS_WIDTH  = Settings::SCREEN_WIDTH
  CANVAS_HEIGHT = Settings::SCREEN_HEIGHT

  PLAY_CONTROLS_WIDTH  = MENU_BAR_WIDTH   # 256
  PLAY_CONTROLS_HEIGHT = 72
  PLAY_CONTROLS_X      = MENU_BAR_X
  PLAY_CONTROLS_Y      = CANVAS_Y + CANVAS_HEIGHT - PLAY_CONTROLS_HEIGHT

  BATTLERS_LAYOUT_X      = MENU_BAR_X
  BATTLERS_LAYOUT_Y      = MENU_BAR_Y + MENU_BAR_HEIGHT + (CONTAINER_BORDER * 2)
  BATTLERS_LAYOUT_WIDTH  = MENU_BAR_WIDTH
  BATTLERS_LAYOUT_HEIGHT = PLAY_CONTROLS_Y - (MENU_BAR_Y + MENU_BAR_HEIGHT) - (CONTAINER_BORDER * 4)

  BATCH_EDITS_X      = CANVAS_X + CANVAS_WIDTH + (CONTAINER_BORDER * 2)
  BATCH_EDITS_Y      = MENU_BAR_Y
  BATCH_EDITS_WIDTH  = MENU_BAR_WIDTH
  BATCH_EDITS_HEIGHT = CANVAS_HEIGHT

  PARTICLE_LIST_X      = CONTAINER_BORDER
  PARTICLE_LIST_Y      = CANVAS_Y + CANVAS_HEIGHT + (CONTAINER_BORDER * 2)
  PARTICLE_LIST_WIDTH  = BATCH_EDITS_X + BATCH_EDITS_WIDTH - MENU_BAR_X
  PARTICLE_LIST_HEIGHT = WINDOW_HEIGHT - PARTICLE_LIST_Y - CONTAINER_BORDER

  # Pop-up windows
  MESSAGE_BOX_WIDTH         = WINDOW_WIDTH * 3 / 4
  MESSAGE_BOX_HEIGHT        = 160
  MESSAGE_BOX_BUTTON_WIDTH  = 150
  MESSAGE_BOX_BUTTON_HEIGHT = 32
  MESSAGE_BOX_SPACING       = 16

  HELP_WIDTH       = 850
  HELP_HEIGHT      = 500
  HELP_X           = (WINDOW_WIDTH - HELP_WIDTH) / 2
  HELP_Y           = (WINDOW_HEIGHT - HELP_HEIGHT) / 2
  HELP_LABEL_WIDTH = 140

  PROPERTIES_POPUP_ROW_HEIGHT  = 24
  PROPERTIES_POPUP_LABEL_WIDTH = 190   # Editor settings, anim properties, particle properties

  EDITOR_SETTINGS_WIDTH  = 390
  EDITOR_SETTINGS_HEIGHT = (9 * PROPERTIES_POPUP_ROW_HEIGHT) + 2
  EDITOR_SETTINGS_X      = (WINDOW_WIDTH - EDITOR_SETTINGS_WIDTH) / 2
  EDITOR_SETTINGS_Y      = (WINDOW_HEIGHT - EDITOR_SETTINGS_HEIGHT) / 2

  ANIM_PROPERTIES_WIDTH  = 390
  ANIM_PROPERTIES_HEIGHT = (21 * PROPERTIES_POPUP_ROW_HEIGHT) + 2
  ANIM_PROPERTIES_X      = (WINDOW_WIDTH - ANIM_PROPERTIES_WIDTH) / 2
  ANIM_PROPERTIES_Y      = (WINDOW_HEIGHT - ANIM_PROPERTIES_HEIGHT) / 2

  PARTICLE_PROPERTIES_WIDTH  = 390
  PARTICLE_PROPERTIES_HEIGHT = (33 * PROPERTIES_POPUP_ROW_HEIGHT) + 2
  PARTICLE_PROPERTIES_X      = (WINDOW_WIDTH - PARTICLE_PROPERTIES_WIDTH) / 2
  PARTICLE_PROPERTIES_Y      = (WINDOW_HEIGHT - PARTICLE_PROPERTIES_HEIGHT) / 2

  BATCH_EDITOR_SPACING                  = 4
  BATCH_EDITOR_ROW_HEIGHT               = 24
  BATCH_EDITOR_BUTTON_HEIGHT            = 24
  BATCH_EDITOR_PARTICLE_LIST_ROWS       = 13
  BATCH_EDITOR_PARTICLE_LIST_ROW_HEIGHT = 20
  BATCH_EDITOR_PARTICLE_LIST_X          = BATCH_EDITOR_SPACING - 1
  BATCH_EDITOR_PARTICLE_LIST_Y          = BATCH_EDITOR_ROW_HEIGHT   # Actually where the label is
  BATCH_EDITOR_PARTICLE_LIST_WIDTH      = 200 + (UIControls::List::LIST_FRAME_THICKNESS * 2)
  BATCH_EDITOR_PARTICLE_LIST_HEIGHT     = (BATCH_EDITOR_PARTICLE_LIST_ROWS * BATCH_EDITOR_PARTICLE_LIST_ROW_HEIGHT) + (UIControls::List::LIST_FRAME_THICKNESS * 2)
  BATCH_EDITOR_LABEL_WIDTH              = 100
  BATCH_EDITOR_NUMBER_BOX_WIDTH         = UIControls::NumberTextBox::TEXT_BOX_WIDTH + UIControls::NumberTextBox::ARROW_WIDTH
  BATCH_EDITOR_APPLY_BUTTON_WIDTH       = 64
  BATCH_EDITOR_WINDOW_WIDTH             = 504
  BATCH_EDITOR_WINDOW_HEIGHT            = BATCH_EDITOR_PARTICLE_LIST_Y + BATCH_EDITOR_ROW_HEIGHT + BATCH_EDITOR_PARTICLE_LIST_HEIGHT + BATCH_EDITOR_SPACING + BATCH_EDITOR_BUTTON_HEIGHT + BATCH_EDITOR_SPACING - 1
  BATCH_EDITOR_X                        = (WINDOW_WIDTH - BATCH_EDITOR_WINDOW_WIDTH) / 2
  BATCH_EDITOR_Y                        = (WINDOW_HEIGHT - BATCH_EDITOR_WINDOW_HEIGHT) / 2

  CHOOSER_BUTTON_WIDTH     = 150
  CHOOSER_BUTTON_HEIGHT    = MESSAGE_BOX_BUTTON_HEIGHT
  CHOOSER_FILE_LIST_X      = CONTAINER_BORDER
  CHOOSER_FILE_LIST_Y      = 30
  CHOOSER_FILE_LIST_WIDTH  = (CHOOSER_BUTTON_WIDTH * 2) + (UIControls::List::LIST_FRAME_THICKNESS * 2)
  CHOOSER_FILE_LIST_HEIGHT = (UIControls::List::ROW_HEIGHT * 15) + (UIControls::List::LIST_FRAME_THICKNESS * 2)
  CHOOSER_ROW_HEIGHT       = 24

  GRAPHIC_CHOOSER_PREVIEW_SIZE   = 320   # Square
  GRAPHIC_CHOOSER_PREVIEW_BORDER = 2
  GRAPHIC_CHOOSER_WINDOW_WIDTH   = CHOOSER_FILE_LIST_X + CHOOSER_FILE_LIST_WIDTH + 4 + GRAPHIC_CHOOSER_PREVIEW_SIZE + (GRAPHIC_CHOOSER_PREVIEW_BORDER * 2) + CONTAINER_BORDER
  GRAPHIC_CHOOSER_WINDOW_HEIGHT  = CHOOSER_FILE_LIST_Y + CHOOSER_FILE_LIST_HEIGHT + CHOOSER_ROW_HEIGHT + CONTAINER_BORDER
  GRAPHIC_CHOOSER_X              = (WINDOW_WIDTH - GRAPHIC_CHOOSER_WINDOW_WIDTH) / 2
  GRAPHIC_CHOOSER_Y              = (WINDOW_HEIGHT - GRAPHIC_CHOOSER_WINDOW_HEIGHT) / 2

  AUDIO_CHOOSER_LABEL_WIDTH   = UIControls::ListedContainer::OFFSET_FROM_LABEL_X - 10
  AUDIO_CHOOSER_SLIDER_WIDTH  = (CHOOSER_BUTTON_WIDTH * 2) - AUDIO_CHOOSER_LABEL_WIDTH
  AUDIO_CHOOSER_WINDOW_WIDTH  = CHOOSER_FILE_LIST_X + CHOOSER_FILE_LIST_WIDTH + ((4 + CHOOSER_BUTTON_WIDTH) * 2) + CONTAINER_BORDER
  AUDIO_CHOOSER_WINDOW_HEIGHT = CHOOSER_FILE_LIST_Y + CHOOSER_FILE_LIST_HEIGHT + CHOOSER_ROW_HEIGHT + CONTAINER_BORDER
  AUDIO_CHOOSER_X             = (WINDOW_WIDTH - AUDIO_CHOOSER_WINDOW_WIDTH) / 2
  AUDIO_CHOOSER_Y             = (WINDOW_HEIGHT - AUDIO_CHOOSER_WINDOW_HEIGHT) / 2

  #-----------------------------------------------------------------------------

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

  #-----------------------------------------------------------------------------

  def save
#    AnimationEditor::ParticleDataHelper.optimize_all_particles(@anim[:particles])
    GameData::Animation.register(@anim, @anim_id)
    Compiler.write_battle_animation_file(@anim[:pbs_path])
    if @anim[:pbs_path] != @pbs_path
      if GameData::Animation::DATA.any? { |_key, anim| anim.pbs_path == @pbs_path }
        Compiler.write_battle_animation_file(@pbs_path)
      elsif FileTest.exist?("PBS/Animations/" + @pbs_path + ".txt")
        File.delete("PBS/Animations/" + @pbs_path + ".txt")
      end
      @pbs_path = @anim[:pbs_path]
    end
    save_settings
  end

  #-----------------------------------------------------------------------------

  def play_animation
    play_controls = @components[:play_controls]
    # Set up canvas as a pseudo-battle screen
    @components[:canvas].prepare_to_play_animation
    play_controls.prepare_to_play_animation
    # Set up fake battlers for the animation player
    user_battler = nil
    if !@anim[:no_user]
      idx_user = @settings[:anim_editor][:user_index]
      if @settings[:anim_editor][:user_opposes] || [:opp_move, :opp_common].include?(@anim[:type])
        idx_user += 1
      end
      user_battler = AnimationPlayer::FakeBattler.new(idx_user, @settings[:anim_editor][:user_sprite_name])
    end
    target_battlers = nil
    if !@anim[:no_target]
      target_battlers = []
      @settings[:anim_editor][:target_indices].each do |idx|
        idx_target = idx
        if @settings[:anim_editor][:user_opposes] || [:opp_move, :opp_common].include?(@anim[:type])
          idx_target += (idx_target.even?) ? 1 : -1
        end
        target_battlers.push(AnimationPlayer::FakeBattler.new(idx_target, @settings[:anim_editor][:target_sprite_name]))
      end
    end
    # Create animation player
    PBDebug.logonerr {
      anim_player = AnimationPlayer.new(@anim, user_battler, target_battlers, @components[:canvas])
      anim_player.looping = @components[:play_controls].looping
      anim_player.slowdown = @components[:play_controls].slowdown
      anim_player.set_up
      # Play animation
      anim_player.start
      loop do
        Graphics.update
        Input.update
        anim_player.update
        play_controls.update
        if play_controls.changed?
          if play_controls.changed_controls.keys.include?(:stop)
            anim_player.finish
            play_controls.clear_changed
            pbSEStop
            break
          end
        end
        if Input.triggerex?(:SPACE)
          pbSEStop
          break
        end
        break if anim_player.finished?
      end
      anim_player.dispose
    }
    @components[:canvas].end_playing_animation
    play_controls.end_playing_animation
  end

  #-----------------------------------------------------------------------------

  def create_pop_up_window(width, height, ret = nil)
    if !ret
      ret = BitmapSprite.new(width + (CONTAINER_BORDER * 2),
                            height + (CONTAINER_BORDER * 2), @pop_up_viewport)
      ret.x = (WINDOW_WIDTH - ret.width) / 2
      ret.y = (WINDOW_HEIGHT - ret.height) / 2
      ret.z = -1
    end
    ret.bitmap.clear
    ret.bitmap.font.color = get_color_of(:text)
    ret.bitmap.font.size = text_size
    # Draw pop-up box border
    ret.bitmap.border_rect(CONTAINER_BORDER, CONTAINER_BORDER, width, height,
                          CONTAINER_BORDER, get_color_of(:background), get_color_of(:line))
    # Fill pop-up box with white
    ret.bitmap.fill_rect(CONTAINER_BORDER, CONTAINER_BORDER, width, height, get_color_of(:background))
    return ret
  end

  #-----------------------------------------------------------------------------

  def message(text, *options)
    @pop_up_bg_bitmap.visible = true
    msg_bitmap = create_pop_up_window(MESSAGE_BOX_WIDTH, MESSAGE_BOX_HEIGHT)
    # Draw text
    text_size = msg_bitmap.bitmap.text_size(text)
    msg_bitmap.bitmap.draw_text(0, (msg_bitmap.height / 2) - MESSAGE_BOX_BUTTON_HEIGHT,
                                msg_bitmap.width, text_size.height, text, 1)
    # Create buttons
    button_spacing = 2
    buttons = []
    options.each_with_index do |option, i|
      btn = UIControls::Button.new(MESSAGE_BOX_BUTTON_WIDTH, MESSAGE_BOX_BUTTON_HEIGHT, @pop_up_viewport, option[1])
      btn.x = msg_bitmap.x + ((msg_bitmap.width - ((MESSAGE_BOX_BUTTON_WIDTH + button_spacing) * options.length)) / 2) + (button_spacing / 2)
      btn.x += (MESSAGE_BOX_BUTTON_WIDTH + button_spacing) * i
      btn.y = msg_bitmap.y + msg_bitmap.height - MESSAGE_BOX_BUTTON_HEIGHT - MESSAGE_BOX_SPACING
      btn.color_scheme = @color_scheme
      btn.set_interactive_rects
      buttons.push([option[0], btn])
    end
    # Interaction loop
    ret = nil
    captured = nil
    loop do
      Graphics.update
      Input.update
      if captured
        captured.update
        captured = nil if !captured.busy?
      end
      if !captured || !captured.respond_to?("mouse_in_control?") ||
        !captured.mouse_in_control?
        buttons.each do |btn|
          next if captured && btn[1] == captured
          btn[1].update
          captured = btn[1] if btn[1].busy?
        end
      end
      buttons.each do |btn|
        next if !btn[1].changed?
        ret = btn[0]
        break
      end
      ret = :cancel if Input.triggerex?(:ESCAPE)
      break if ret
      buttons.each { |btn| btn[1].repaint }
    end
    # Dispose and return
    buttons.each { |btn| btn[1].dispose }
    buttons.clear
    msg_bitmap.dispose
    @pop_up_bg_bitmap.visible = false
    return ret
  end

  def confirm_message(text)
    return message(text, [:yes, _INTL("Yes")], [:no, _INTL("No")]) == :yes
  end

  #-----------------------------------------------------------------------------

  def help_window
    # Show pop-up window
    help_window = @components[:help]
    help_window.visible = true
    @pop_up_bg_bitmap.visible = true
    bg_bitmap = create_pop_up_window(HELP_WIDTH, HELP_HEIGHT)
    # Interaction loop
    ret = nil
    loop do
      Graphics.update
      Input.update
      help_window.update
      break if help_window.changed? && help_window.changed_controls.has_key?(:close)
      help_window.clear_changed
      break if !help_window.busy? && Input.triggerex?(:ESCAPE)
      help_window.repaint
    end
    # Dispose and return
    bg_bitmap.dispose
    @pop_up_bg_bitmap.visible = false
    help_window.clear_changed
    help_window.visible = false
  end

  #-----------------------------------------------------------------------------

  def edit_editor_settings
    # Show pop-up window
    editor_settings = @components[:editor_settings]
    editor_settings.visible = true
    @pop_up_bg_bitmap.visible = true
    bg_bitmap = create_pop_up_window(EDITOR_SETTINGS_WIDTH, EDITOR_SETTINGS_HEIGHT)
    # Set control values
    refresh_component(:editor_settings)
    # Interaction loop
    loop do
      Graphics.update
      Input.update
      editor_settings.update
      if editor_settings.changed?
        break if editor_settings.changed_controls.has_key?(:close)
        editor_settings.changed_controls.each_pair do |property, value|
          apply_changed_value(:editor_settings, property, value)
          create_pop_up_window(EDITOR_SETTINGS_WIDTH, EDITOR_SETTINGS_HEIGHT, bg_bitmap)
          @pop_up_bg_bitmap.visible = true
        end
        editor_settings.clear_changed
      end
      break if !editor_settings.busy? && Input.triggerex?(:ESCAPE)
      editor_settings.repaint
    end
    # Dispose and return
    bg_bitmap.dispose
    @pop_up_bg_bitmap.visible = false
    editor_settings.clear_changed
    editor_settings.visible = false
    add_to_change_history
  end

  #-----------------------------------------------------------------------------

  def edit_animation_properties
    # Show pop-up window
    anim_properties = @components[:animation_properties]
    anim_properties.visible = true
    @pop_up_bg_bitmap.visible = true
    bg_bitmap = create_pop_up_window(ANIM_PROPERTIES_WIDTH, ANIM_PROPERTIES_HEIGHT)
    # Set control values
    refresh_component(:animation_properties)
    # Interaction loop
    loop do
      Graphics.update
      Input.update
      anim_properties.update
      if anim_properties.changed?
        break if anim_properties.changed_controls.has_key?(:close)
        anim_properties.changed_controls.each_pair do |property, value|
          apply_changed_value(:animation_properties, property, value)
          @pop_up_bg_bitmap.visible = true
        end
        anim_properties.clear_changed
      end
      break if !anim_properties.busy? && Input.triggerex?(:ESCAPE)
      anim_properties.repaint
    end
    # Dispose and return
    bg_bitmap.dispose
    @pop_up_bg_bitmap.visible = false
    anim_properties.clear_changed
    anim_properties.visible = false
    add_to_change_history
  end

  #-----------------------------------------------------------------------------

  def edit_particle_properties(idx_particle = -1)
    idx_particle = particle_index if idx_particle < 0
    this_particle = @anim[:particles][idx_particle]
    # Show pop-up window
    part_properties = @components[:particle_properties]
    part_properties.visible = true
    @pop_up_bg_bitmap.visible = true
    bg_bitmap = create_pop_up_window(PARTICLE_PROPERTIES_WIDTH, PARTICLE_PROPERTIES_HEIGHT)
    # Set control values
    refresh_component(:particle_properties, idx_particle)
    # Interaction loop
    loop do
      Graphics.update
      Input.update
      part_properties.update
      if part_properties.changed?
        break if part_properties.changed_controls.has_key?(:close)
        break if part_properties.changed_controls.has_key?(:delete)
        part_properties.changed_controls.each_pair do |property, value|
          apply_changed_value(:particle_properties, property, [idx_particle, value])
          idx_particle += 1 if property == :duplicate
          @pop_up_bg_bitmap.visible = true
        end
        part_properties.clear_changed
      end
      break if !part_properties.busy? && Input.triggerex?(:ESCAPE)
      part_properties.repaint
    end
    # Dispose
    bg_bitmap.dispose
    @pop_up_bg_bitmap.visible = false
    part_properties.visible = false
    # Delete particle
    if part_properties.changed_controls&.has_key?(:delete)
      apply_changed_value(:particle_properties, :delete, [idx_particle, true])
    end
    part_properties.clear_changed
    add_to_change_history
  end

  #-----------------------------------------------------------------------------

  def batch_edit_commands
    # Show pop-up window
    batch_editor = @components[:command_batch_editor]
    batch_editor.visible = true
    @pop_up_bg_bitmap.visible = true
    bg_bitmap = create_pop_up_window(BATCH_EDITOR_WINDOW_WIDTH, BATCH_EDITOR_WINDOW_HEIGHT)
    # Set control values
    refresh_component(:command_batch_editor)
    # Interaction loop
    loop do
      Graphics.update
      Input.update
      batch_editor.update
      if batch_editor.changed?
        break if batch_editor.changed_controls.has_key?(:close)
        break if batch_editor.changed_controls.has_key?(:apply)
        batch_editor.changed_controls.each_pair do |property, value|
          apply_changed_value(:command_batch_editor, property, value)
          @pop_up_bg_bitmap.visible = true
        end
        batch_editor.clear_changed
      end
      break if !batch_editor.busy? && Input.triggerex?(:ESCAPE)
      batch_editor.repaint
    end
    # Dispose and return
    bg_bitmap.dispose
    @pop_up_bg_bitmap.visible = false
    batch_editor.visible = false
    # Apply changes
    if batch_editor.changed_controls&.has_key?(:apply)
      apply_changed_value(:command_batch_editor, :apply, true)
    end
    batch_editor.clear_changed
    add_to_change_history
  end

  #-----------------------------------------------------------------------------

  def choose_graphic_file(selected, choosing_mask = false)
    selected ||= ""
    sprite_folder = "Graphics/Battle animations"
    # Show pop-up window
    graphic_chooser = @components[:graphic_chooser]
    graphic_chooser.visible = true
    @pop_up_bg_bitmap.visible = true
    bg_bitmap = create_pop_up_window(GRAPHIC_CHOOSER_WINDOW_WIDTH, GRAPHIC_CHOOSER_WINDOW_HEIGHT)
    bg_bitmap.z += graphic_chooser.z
    # Get a list of files
    list = graphic_chooser.get_control(:list)
    all_files = get_all_files_in_folder(
      sprite_folder, [".png", ".jpg", ".jpeg"],
      ["USER", "USER_OPP", "USER_FRONT", "USER_BACK", "TARGET", "TARGET_OPP", "TARGET_FRONT", "TARGET_BACK"]
    )
    if choosing_mask
      all_files.prepend(["", _INTL("[[None]]")])
    else
      if !@anim[:no_target]
        all_files.prepend(
          ["TARGET",       _INTL("[[Target's sprite]]")],
          ["TARGET_OPP",   _INTL("[[Target's other side sprite]]")],
          ["TARGET_FRONT", _INTL("[[Target's front sprite]]")],
          ["TARGET_BACK",  _INTL("[[Target's back sprite]]")]
        )
      end
      if !@anim[:no_user]
        all_files.prepend(
          ["USER",         _INTL("[[User's sprite]]")],
          ["USER_OPP",     _INTL("[[User's other side sprite]]")],
          ["USER_FRONT",   _INTL("[[User's front sprite]]")],
          ["USER_BACK",    _INTL("[[User's back sprite]]")]
        )
      end
    end
    idx = 0
    all_files.each_with_index do |f, i|
      next if f[0] != selected
      idx = i
      break
    end
    # Set control values
    list.options = all_files
    list.selected = idx
    graphic_chooser.get_control(:filter).value = ""
    graphic_chooser.get_control(:ok).enable
    # Create sprite preview
    bg_bitmap.bitmap.outline_rect(CONTAINER_BORDER - graphic_chooser.x + list.x + list.width + 4,
                                  CONTAINER_BORDER - graphic_chooser.y + list.y,
                                  GRAPHIC_CHOOSER_PREVIEW_SIZE + (GRAPHIC_CHOOSER_PREVIEW_BORDER * 2),
                                  GRAPHIC_CHOOSER_PREVIEW_SIZE + (GRAPHIC_CHOOSER_PREVIEW_BORDER * 2),
                                  get_color_of(:line))
    preview_sprite = Sprite.new(@pop_up_viewport)
    preview_sprite.x = list.x + list.width + 4 + GRAPHIC_CHOOSER_PREVIEW_BORDER + (GRAPHIC_CHOOSER_PREVIEW_SIZE / 2)
    preview_sprite.y = list.y + GRAPHIC_CHOOSER_PREVIEW_BORDER + (GRAPHIC_CHOOSER_PREVIEW_SIZE / 2)
    preview_sprite.z = graphic_chooser.z
    preview_bitmap = nil
    set_preview_graphic = lambda do |sprite, filename|
      preview_bitmap&.dispose
      sprite.visible = false
      bg_bitmap.bitmap.fill_rect(CONTAINER_BORDER - graphic_chooser.x + list.x + list.width + 4 + GRAPHIC_CHOOSER_PREVIEW_BORDER,
                                CONTAINER_BORDER - graphic_chooser.y + list.y + GRAPHIC_CHOOSER_PREVIEW_BORDER,
                                GRAPHIC_CHOOSER_PREVIEW_SIZE, GRAPHIC_CHOOSER_PREVIEW_SIZE,
                                get_color_of(:background))
      next if filename.nil? || filename == ""
      folder = sprite_folder + "/"
      fname = filename
      if ["USER", "USER_BACK", "USER_FRONT", "USER_OPP",
          "TARGET", "TARGET_FRONT", "TARGET_BACK", "TARGET_OPP"].include?(filename)
        chunks = filename.split("_")
        fname = (chunks[0] == "USER") ? @settings[:anim_editor][:user_sprite_name].to_s : @settings[:anim_editor][:target_sprite_name].to_s
        case chunks[1] || ""
        when "", "OPP"
          if (chunks[0] == "USER") ^ (chunks[1] == "OPP")   # xor
            folder = (@settings[:anim_editor][:user_opposes]) ? "Graphics/Pokemon/Front/" : "Graphics/Pokemon/Back/"
          else
            folder = (@settings[:anim_editor][:user_opposes]) ? "Graphics/Pokemon/Back/" : "Graphics/Pokemon/Front/"
          end
        when "FRONT"
          folder = "Graphics/Pokemon/Front/"
        when "BACK"
          folder = "Graphics/Pokemon/Back/"
        end
      end
      preview_bitmap = AnimatedBitmap.new(folder + fname)
      next if !preview_bitmap
      sprite.visible = true
      sprite.bitmap = preview_bitmap.bitmap
      zoom = [[GRAPHIC_CHOOSER_PREVIEW_SIZE.to_f / preview_bitmap.width,
              GRAPHIC_CHOOSER_PREVIEW_SIZE.to_f / preview_bitmap.height].min, 1.0].min
      sprite.zoom_x = sprite.zoom_y = zoom
      sprite.ox = sprite.width / 2
      sprite.oy = sprite.height / 2
      bg_bitmap.bitmap.fill_rect(CONTAINER_BORDER + sprite.x - graphic_chooser.x - (sprite.width * sprite.zoom_x / 2).round,
                                CONTAINER_BORDER + sprite.y - graphic_chooser.y - (sprite.height * sprite.zoom_y / 2).round,
                                sprite.width * sprite.zoom_x, sprite.height * sprite.zoom_y,
                                Color.magenta)
    end
    set_preview_graphic.call(preview_sprite, list.value)
    # Interaction loop
    filter_text = ""
    ret = nil
    loop do
      Graphics.update
      Input.update
      graphic_chooser.update
      if graphic_chooser.get_control(:filter).value != filter_text
        filter_text = graphic_chooser.get_control(:filter).value
        old_val = list.value
        if filter_text == ""
          list.options = all_files
        else
          files = all_files.filter { |val| val[0].downcase.include?(filter_text.downcase) }
          list.options = files
        end
        list.selected = list.options.index { |val| val && val[0] == old_val } || -1
        set_preview_graphic.call(preview_sprite, list.value)
      end
      if graphic_chooser.changed?
        graphic_chooser.changed_controls.each_pair do |ctrl, value|
          case ctrl
          when :ok
            ret = list.value
          when :cancel
            ret = selected
          when :list
            set_preview_graphic.call(preview_sprite, list.value)
          when :filter_clear
            old_val = list.value
            filter_text = ""
            graphic_chooser.get_control(:filter).value = ""
            list.options = all_files
            list.selected = list.options.index { |val| val && val[0] == old_val } || -1
            set_preview_graphic.call(preview_sprite, list.value)
          end
          graphic_chooser.clear_changed
        end
        break if ret
        graphic_chooser.repaint
      end
      graphic_chooser.get_control(:ok).enabled = !list.value.nil?
      if !graphic_chooser.busy? && Input.triggerex?(:ESCAPE)
        ret = selected
        break
      end
    end
    # Dispose and return
    bg_bitmap.dispose
    preview_sprite.dispose
    preview_bitmap&.dispose
    @pop_up_bg_bitmap.visible = false
    graphic_chooser.clear_changed
    graphic_chooser.visible = false
    return ret
  end

  #-----------------------------------------------------------------------------

  def choose_audio_file(selected, volume = 100, pitch = 100)
    selected ||= ""
    audio_folder = "Audio/SE/Anim"
    # Show pop-up window
    audio_chooser = @components[:audio_chooser]
    audio_chooser.visible = true
    @pop_up_bg_bitmap.visible = true
    bg_bitmap = create_pop_up_window(AUDIO_CHOOSER_WINDOW_WIDTH, AUDIO_CHOOSER_WINDOW_HEIGHT)
    bg_bitmap.z += audio_chooser.z
    # Get a list of files
    list = audio_chooser.get_control(:list)
    all_files = get_all_files_in_folder(audio_folder, [".wav", ".ogg", ".mp3", ".wma"], ["USER", "TARGET"])
    all_files.prepend(["TARGET", _INTL("[[Target's cry]]")]) if !@anim[:no_target]
    all_files.prepend(["USER",  _INTL("[[User's cry]]")]) if !@anim[:no_user]
    idx = 0
    all_files.each_with_index do |f, i|
      next if f[0] != selected
      idx = i
      break
    end
    # Set control values
    list.options = all_files
    list.selected = idx
    audio_chooser.get_control(:filter).value = ""
    audio_chooser.get_control(:volume).value = volume
    audio_chooser.get_control(:pitch).value = pitch
    audio_chooser.get_control(:play).enable
    audio_chooser.get_control(:ok).enable
    # Interaction loop
    filter_text = ""
    ret = nil
    cancel = false
    loop do
      Graphics.update
      Input.update
      audio_chooser.update
      if audio_chooser.get_control(:filter).value != filter_text
        filter_text = audio_chooser.get_control(:filter).value
        old_val = list.value
        if filter_text == ""
          list.options = all_files
        else
          files = all_files.filter { |val| val[0].downcase.include?(filter_text.downcase) }
          list.options = files
        end
        list.selected = list.options.index { |val| val && val[0] == old_val } || -1
      end
      if audio_chooser.changed?
        audio_chooser.changed_controls.each_pair do |ctrl, value|
          case ctrl
          when :ok
            ret = list.value
          when :cancel
            ret = selected
            cancel = true
          when :filter_clear
            old_val = list.value
            filter_text = ""
            audio_chooser.get_control(:filter).value = ""
            list.options = all_files
            list.selected = list.options.index { |val| val && val[0] == old_val } || -1
          when :play
            vol = audio_chooser.get_control(:volume).value
            ptch = audio_chooser.get_control(:pitch).value
            case list.value
            when "USER"
              Pokemon.play_cry(@settings[:anim_editor][:user_sprite_name])
            when "TARGET"
              Pokemon.play_cry(@settings[:anim_editor][:target_sprite_name])
            else
              pbSEPlay(RPG::AudioFile.new("Anim/" + list.value, vol, ptch)) if list.value
            end
          when :stop
            pbSEStop
          end
          audio_chooser.clear_changed
        end
        break if ret
        audio_chooser.repaint
      end
      [:play, :ok].each { |ctrl| audio_chooser.get_control(ctrl).enabled = !list.value.nil? }
      if !audio_chooser.busy? && Input.triggerex?(:ESCAPE)
        ret = selected
        cancel = true
        break
      end
    end
    vol = (cancel) ? volume : audio_chooser.get_control(:volume).value
    ptch = (cancel) ? pitch : audio_chooser.get_control(:pitch).value
    # Dispose and return
    bg_bitmap.dispose
    @pop_up_bg_bitmap.visible = false
    audio_chooser.clear_changed
    audio_chooser.visible = false
    return [ret, vol, ptch]
  end

  #-----------------------------------------------------------------------------

  def apply_changed_menu_bar_value(property, value)
    case property
    when :quit
      @quit = true
    when :save
      save
    when :help
      help_window
    when :name
      edit_animation_properties
      @components[:menu_bar].anim_name = get_animation_display_name
      @components[:play_controls].duration = @components[:timeline].duration   # In case FPS changed
      refresh_component(:timeline)
    when :settings
      edit_editor_settings
    end
  end

  def apply_changed_battlers_layout_value(property, value)
    case property
    when :side_size_1
      old_val = @settings[:anim_editor][:side_sizes][0]
      @settings[:anim_editor][:side_sizes][0] = value
      if @settings[:anim_editor][:user_index] >= value * 2
        @settings[:anim_editor][:user_index] = (value - 1) * 2
        @components[:battlers_layout].get_control(:user_index).value = @settings[:anim_editor][:user_index]
        @settings[:anim_editor][:target_indices].delete_if { |val| val == @settings[:anim_editor][:user_index] }
      end
      @settings[:anim_editor][:target_indices].delete_if { |val| val.even? && val >= value * 2 }
      @settings[:anim_editor][:target_indices].push(1) if @settings[:anim_editor][:target_indices].empty?
      @components[:battlers_layout].get_control(:target_indices).value = @settings[:anim_editor][:target_indices].join(",")
    when :side_size_2
      old_val = @settings[:anim_editor][:side_sizes][1]
      @settings[:anim_editor][:side_sizes][1] = value
      @settings[:anim_editor][:target_indices].delete_if { |val| val == @settings[:anim_editor][:user_index] }
      @settings[:anim_editor][:target_indices].delete_if { |val| val.odd? && val >= value * 2 }
      @settings[:anim_editor][:target_indices].push(1) if @settings[:anim_editor][:target_indices].empty?
      @components[:battlers_layout].get_control(:target_indices).value = @settings[:anim_editor][:target_indices].join(",")
    when :user_index
      @settings[:anim_editor][:user_index] = value
      @settings[:anim_editor][:target_indices].delete_if { |val| val == @settings[:anim_editor][:user_index] }
      @settings[:anim_editor][:target_indices].push(1) if @settings[:anim_editor][:target_indices].empty?
      @components[:battlers_layout].get_control(:target_indices).value = @settings[:anim_editor][:target_indices].join(",")
    when :target_indices
      @settings[:anim_editor][:target_indices] = value.split(",")
      @settings[:anim_editor][:target_indices].map! { |val| val.to_i }
      @settings[:anim_editor][:target_indices].sort!
      @settings[:anim_editor][:target_indices].uniq!
      @settings[:anim_editor][:target_indices].delete_if { |val| val == @settings[:anim_editor][:user_index] }
      @settings[:anim_editor][:target_indices].delete_if { |val| val.even? && val >= @settings[:anim_editor][:side_sizes][0] * 2 }
      @settings[:anim_editor][:target_indices].delete_if { |val| val.odd? && val >= @settings[:anim_editor][:side_sizes][1] * 2 }
      @settings[:anim_editor][:target_indices].push(1) if @settings[:anim_editor][:target_indices].empty?
      @components[:battlers_layout].get_control(:target_indices).value = @settings[:anim_editor][:target_indices].join(",")
    when :color_scheme
      @settings[property] = value
    else
      @settings[:anim_editor][property] = value
    end
    save_settings
    refresh_component(:battlers_layout)
    refresh_component(:canvas)
  end

  def apply_changed_play_controls_value(property, value)
    case property
    when :play
      @ready_to_play = true
    end
  end

  def apply_changed_canvas_value(property, value)
    case property
    when :particle_index
      @components[:timeline].particle_index = value
      refresh
    when :x, :y, :r, :theta, :emitter_x, :emitter_y, :emitter_r, :emitter_theta, :angle
      particle = @anim[:particles][particle_index]
      before_all = particle[property] && particle[property].none? { |cmd| cmd[0] <= keyframe }
      after_all = particle[property] && particle[property].none? { |cmd| cmd[0] + cmd[1] >= keyframe }
      new_cmds = AnimationEditor::ParticleDataHelper.add_command(particle, property, keyframe, value)
      if new_cmds
        particle[property] = new_cmds
        if GameData::Animation.property_can_interpolate?(property)
          if before_all
            AnimationEditor::ParticleDataHelper.set_interpolation(
              particle, property, keyframe, @settings[:anim_editor][:default_interpolation] || :linear
            )
          elsif after_all
            AnimationEditor::ParticleDataHelper.set_interpolation(
              particle, property, keyframe - 1, @settings[:anim_editor][:default_interpolation] || :linear
            )
          end
        end
      else
        particle.delete(property)
      end
      @components[:timeline].change_particle_commands(particle_index)
      refresh_component(:timeline)
      refresh_component(:canvas)
    when :zoom
      particle = @anim[:particles][particle_index]
      [:zoom_x, :zoom_y].each do |prop|
        before_all = particle[prop] && particle[prop].none? { |cmd| cmd[0] <= keyframe }
        after_all = particle[prop] && particle[prop].none? { |cmd| cmd[0] + cmd[1] >= keyframe }
        val = AnimationEditor::ParticleDataHelper.get_keyframe_particle_value(particle, prop, keyframe)[0]
        # NOTE: I'm aware that simply adding value to val for each of :zoom_x
        #       and :zoom_y won't keep their ratio constant, but I can't figure
        #       out how to do it a smarter way without running into rounding
        #       errors causing the ratio to deviate anyway.
        new_cmds = AnimationEditor::ParticleDataHelper.add_command(particle, prop, keyframe, val + value)
        if new_cmds
          particle[prop] = new_cmds
          if GameData::Animation.property_can_interpolate?(prop)
            if before_all
              AnimationEditor::ParticleDataHelper.set_interpolation(
                particle, prop, keyframe, @settings[:anim_editor][:default_interpolation] || :linear
              )
            elsif after_all
              AnimationEditor::ParticleDataHelper.set_interpolation(
                particle, prop, keyframe - 1, @settings[:anim_editor][:default_interpolation] || :linear
              )
            end
          end
        else
          particle.delete(prop)
        end
      end
      @components[:timeline].change_particle_commands(particle_index)
      refresh_component(:timeline)
      refresh_component(:canvas)
    when :on_mouse_release, :on_dir_keys_release, :on_mouse_wheel_stopped
      add_to_change_history
    end
  end

  def apply_changed_batch_edits_value(property, value)
    case property
    when :undo
      undo_change
      @components[:play_controls].duration = @components[:timeline].duration
      return
    when :redo
      redo_change
      @components[:play_controls].duration = @components[:timeline].duration
      return
    when :shift_all_left, :shift_all_after_left
      frame = (property == :shift_all_left) ? 0 : keyframe
      @anim[:particles].each do |particle|
        AnimationEditor::ParticleDataHelper.remove_frame(particle, frame)
      end
      refresh_component(:timeline)
    when :shift_all_right, :shift_all_after_right
      frame = (property == :shift_all_right) ? 0 : keyframe
      @anim[:particles].each do |particle|
        AnimationEditor::ParticleDataHelper.insert_frame(particle, frame)
      end
      refresh_component(:timeline)
    when :shift_one_left, :shift_one_after_left
      frame = (property == :shift_one_left) ? 0 : keyframe
      AnimationEditor::ParticleDataHelper.remove_frame(@anim[:particles][particle_index], frame)
      @components[:timeline].change_particle_commands(particle_index)
    when :shift_one_right, :shift_one_after_right
      frame = (property == :shift_one_right) ? 0 : keyframe
      AnimationEditor::ParticleDataHelper.insert_frame(@anim[:particles][particle_index], frame)
      @components[:timeline].change_particle_commands(particle_index)
    when :shift_row_left, :shift_row_after_left
      part_idx, row = @components[:timeline].particle_index_and_property
      return if !row
      frame = (property == :shift_row_left) ? 0 : keyframe
      AnimationEditor::ParticleDataHelper.remove_frame(@anim[:particles][part_idx], frame, row)
      @components[:timeline].change_particle_commands(particle_index)
    when :shift_row_right, :shift_row_after_right
      part_idx, row = @components[:timeline].particle_index_and_property
      return if !row
      frame = (property == :shift_row_right) ? 0 : keyframe
      AnimationEditor::ParticleDataHelper.insert_frame(@anim[:particles][part_idx], frame, row)
      @components[:timeline].change_particle_commands(particle_index)
    when :offset_commands
      batch_edit_commands
      return
    when :clear_selected_row
      part_idx, row = @components[:timeline].particle_index_and_property
      return if !row
      AnimationEditor::ParticleDataHelper.clear_property(@anim[:particles][part_idx], row)
      @components[:timeline].change_particle_commands(part_idx)
    else
      return
    end
    add_to_change_history
    refresh_component(:canvas)
    @components[:play_controls].duration = @components[:timeline].duration
  end

  def apply_changed_timeline_value(property, value)
    case property
    when :add_particle
      new_idx = particle_index + 1
      new_idx -= 1 if new_idx >= @anim[:particles].length   # Ensure it's before SE particle
      AnimationEditor::ParticleDataHelper.add_particle(@anim[:particles], new_idx)
      new_cmds = AnimationEditor::ParticleDataHelper.add_command(@anim[:particles][new_idx], :visible, keyframe, true)
      if new_cmds
        @anim[:particles][new_idx][:visible] = new_cmds
      else
        @anim[:particles][new_idx].delete(:visible)
      end
      add_to_change_history
      @components[:timeline].add_particle(new_idx)
      @components[:timeline].particle_index = new_idx
      refresh
    when :move_particle_up
      idx1 = particle_index
      idx2 = idx1 - 1
      AnimationEditor::ParticleDataHelper.swap_particles(@anim[:particles], idx1, idx2)
      add_to_change_history
      @components[:timeline].swap_particles(idx1, idx2)
      @components[:timeline].particle_index = idx2
      refresh
    when :move_particle_down
      idx1 = particle_index
      idx2 = idx1 + 1
      AnimationEditor::ParticleDataHelper.swap_particles(@anim[:particles], idx1, idx2)
      add_to_change_history
      @components[:timeline].swap_particles(idx1, idx2)
      @components[:timeline].particle_index = idx2
      refresh
    when :main   # Particle properties/SE
      if @anim[:particles][value[0]][:name] == "SE"
        # NOTE: value is actually [particle index, [button ID, index of SE]].
        #       Keyframe is the currently selected keyframe.
        case value[1][0]
        when :add
          new_filename, new_volume, new_pitch = choose_audio_file("", 100, 100)
          if new_filename != ""
            particle = @anim[:particles][value[0]]
            AnimationEditor::ParticleDataHelper.add_se_command(particle, keyframe, new_filename, new_volume, new_pitch)
            add_to_change_history
            @components[:timeline].change_particle_commands(value[0])
            @components[:play_controls].duration = @components[:timeline].duration
          end
        when :edit
          particle = @anim[:particles][value[0]]
          list = AnimationEditor::ParticleDataHelper.get_all_particle_se_at_frame(particle, keyframe)
          old_file = list[value[1][1]]
          if old_file
            case old_file[0]
            when :user_cry, :target_cry
              old_filename = (old_file[0] == :user_cry) ? "USER" : "TARGET"
              old_volume = old_file[3] || 100
              old_pitch = old_file[4] || 100
            when :se
              old_filename = old_file[3]
              old_volume = old_file[4] || 100
              old_pitch = old_file[5] || 100
            end
            new_filename, new_volume, new_pitch = choose_audio_file(old_filename, old_volume, old_pitch)
            if new_filename != old_filename || new_volume != old_volume || new_pitch != old_pitch
              AnimationEditor::ParticleDataHelper.delete_se_command(particle, keyframe, old_filename)
              AnimationEditor::ParticleDataHelper.add_se_command(particle, keyframe, new_filename, new_volume, new_pitch)
              add_to_change_history
              @components[:timeline].change_particle_commands(value[0])
            end
          end
        when :delete
          particle = @anim[:particles][value[0]]
          list = AnimationEditor::ParticleDataHelper.get_all_particle_se_at_frame(particle, keyframe)
          old_file = list[value[1][1]]
          if old_file
            case old_file[0]
            when :user_cry, :target_cry
              old_filename = (old_file[0] == :user_cry) ? "USER" : "TARGET"
            when :se
              old_filename = old_file[3]
            end
            AnimationEditor::ParticleDataHelper.delete_se_command(particle, keyframe, old_filename)
            add_to_change_history
            @components[:timeline].change_particle_commands(value[0])
            @components[:play_controls].duration = @components[:timeline].duration
          end
        end
      else
        # NOTE: value is actually [particle_index, value].
        edit_particle_properties(value[0])
      end
    when :move_command
      # NOTE: value is actually [particle_index, [property, src_keyframe, dst_keyframe]].
      part_idx = value[0]
      prop = value[1][0]
      src_keyframe = value[1][1]
      dst_keyframe = value[1][2]
      if prop == :main   # SE
        [:se, :user_cry, :target_cry].each do |se_prop|
          AnimationEditor::ParticleDataHelper.move_command(
            @anim[:particles][part_idx], se_prop, src_keyframe, dst_keyframe
          )
        end
      else
        AnimationEditor::ParticleDataHelper.move_command(
          @anim[:particles][part_idx], prop, src_keyframe, dst_keyframe
        )
      end
      add_to_change_history
      @components[:timeline].change_particle_commands(part_idx)
      refresh_component(:canvas)
      @components[:play_controls].duration = @components[:timeline].duration
    else
      if GameData::Animation::INTERPOLATION_TYPES.any? { |name, id| id == property }
        # Change interpolation
        # NOTE: value is actually [particle index, [property, keyframe]].
        part_idx = value[0]
        prop = value[1][0]
        clicked_keyframe = value[1][1]
        interp_type = property
        # Set the new interpolation type
        AnimationEditor::ParticleDataHelper.set_interpolation(
          @anim[:particles][part_idx], prop, clicked_keyframe, interp_type
        )
        add_to_change_history
        @components[:timeline].change_particle_commands(part_idx)
        refresh_component(:canvas)
      else
        # Change property value
        # NOTE: value is actually [particle_index, value].
        particle = @anim[:particles][value[0]]
        before_all = particle[property] && particle[property].none? { |cmd| cmd[0] <= keyframe }
        after_all = particle[property] && particle[property].none? { |cmd| cmd[0] + cmd[1] >= keyframe }
        new_cmds = AnimationEditor::ParticleDataHelper.add_command(particle, property, keyframe, value[1])
        if new_cmds
          particle[property] = new_cmds
          if GameData::Animation.property_can_interpolate?(property)
            if before_all
              AnimationEditor::ParticleDataHelper.set_interpolation(
                particle, property, keyframe, @settings[:anim_editor][:default_interpolation] || :linear
              )
            elsif after_all
              AnimationEditor::ParticleDataHelper.set_interpolation(
                particle, property, keyframe - 1, @settings[:anim_editor][:default_interpolation] || :linear
              )
            end
          end
        else
          particle.delete(property)
        end
        add_to_change_history
        @components[:timeline].change_particle_commands(value[0])
        refresh_component(:canvas)
        @components[:play_controls].duration = @components[:timeline].duration
      end
    end
  end

  def apply_changed_editor_settings_value(property, value)
    case property
    when :color_scheme
      @settings[:color_scheme] = value
      self.color_scheme = value
    else
      @settings[:anim_editor][property] = value
    end
    save_settings
    refresh_component(:canvas)
  end

  def apply_changed_animation_properties_value(property, value)
    case property
    when :type, :opp_variant
      type = @components[:animation_properties].get_control(:type).value
      opp = @components[:animation_properties].get_control(:opp_variant).value
      case type
      when :move
        @anim[:type] = (opp) ? :opp_move : :move
      when :common
        @anim[:type] = (opp) ? :opp_common : :common
      end
      refresh_component(:animation_properties)
      refresh_component(:canvas)
    when :pbs_path
      @anim[property] = value.gsub!(/\.txt$/, "")
    when :has_user
      @anim[:no_user] = !value
      if @anim[:no_user]
        user_idx = @anim[:particles].index { |particle| particle[:name] == "User" }
        @anim[:particles].delete_if { |particle| particle[:name] == "User" }
        @anim[:particles].each do |particle|
          if ["USER", "USER_OPP", "USER_FRONT", "USER_BACK"].include?(particle[:graphic])
            particle[:graphic] = GameData::Animation::PARTICLE_DEFAULT_VALUES[:graphic]
          end
          if GameData::Animation::FOCUS_TYPES_WITH_USER.include?(particle[:focus])
            particle[:focus] = GameData::Animation::PARTICLE_DEFAULT_VALUES[:focus]
          end
          particle[:user_cry] = nil if particle[:name] == "SE"
        end
        @components[:timeline].delete_particle(user_idx)
      elsif @anim[:particles].none? { |particle| particle[:name] == "User" }
        @anim[:particles].insert(0, {
          :name => "User", :focus => :user, :graphic => "USER"
        })
        @components[:timeline].add_particle(0)
      end
      refresh
    when :has_target
      @anim[:no_target] = !value
      if @anim[:no_target]
        target_idx = @anim[:particles].index { |particle| particle[:name] == "Target" }
        @anim[:particles].delete_if { |particle| particle[:name] == "Target" }
        @anim[:particles].each do |particle|
          if ["TARGET", "TARGET_OPP", "TARGET_FRONT", "TARGET_BACK"].include?(particle[:graphic])
            particle[:graphic] = GameData::Animation::PARTICLE_DEFAULT_VALUES[:graphic]
          end
          if GameData::Animation::FOCUS_TYPES_WITH_TARGET.include?(particle[:focus])
            particle[:focus] = GameData::Animation::PARTICLE_DEFAULT_VALUES[:focus]
          end
          particle[:target_cry] = nil if particle[:name] == "SE"
        end
        @components[:timeline].delete_particle(target_idx)
      elsif @anim[:particles].none? { |particle| particle[:name] == "Target" }
        @anim[:particles].insert(0, {
          :name => "Target", :focus => :target, :graphic => "TARGET"
        })
        @components[:timeline].add_particle(0)
      end
      refresh
    when :usable
      @anim[:ignore] = !value
    when :scripts
      text = @components[:animation_properties].get_control(:scripts).value
      texts = text.split(",")
      texts.select! { |txt| txt && txt != "" }
      @anim[property] = texts
      @components[:animation_properties].get_control(:scripts).value = texts.join(",")
    when :fps
      @anim[property] = value
      @components[:play_controls].duration = @components[:timeline].duration
    else
      @anim[property] = value
    end
  end

  def apply_changed_particle_properties_value(property, value)
    idx_particle = (value.is_a?(Array)) ? value[0] : particle_index
    value = value[1] if value.is_a?(Array)
    case property
    when :graphic
      this_particle = @anim[:particles][idx_particle]
      new_file = choose_graphic_file(this_particle[:graphic])
      if this_particle[:graphic] != new_file
        this_particle[:graphic] = new_file
        if ["USER", "USER_OPP", "USER_BACK", "USER_FRONT",
            "TARGET", "TARGET_OPP" "TARGET_FRONT", "TARGET_BACK",].include?(new_file)
          this_particle.delete(:frame)
          @components[:timeline].set_particles(@anim[:particles])
          refresh_component(:timeline)
        end
        refresh_component(:particle_properties, idx_particle)
        refresh_component(:canvas)
      end
    when :mask_graphic
      this_particle = @anim[:particles][idx_particle]
      new_file = choose_graphic_file(this_particle[:mask_graphic], true)
      if this_particle[:mask_graphic] != new_file
        this_particle[:mask_graphic] = new_file
        if (new_file || "") == ""
          this_particle.delete(:mask_blending)
          this_particle.delete(:mask_opacity)
          this_particle.delete(:mask_x)
          this_particle.delete(:mask_y)
          this_particle.delete(:mask_zoom_x)
          this_particle.delete(:mask_zoom_y)
        end
        @components[:timeline].set_particles(@anim[:particles])
        refresh_component(:particle_properties, idx_particle)
        refresh_component(:canvas)
        refresh_component(:timeline)
      end
    when :duplicate
      p_index = idx_particle
      AnimationEditor::ParticleDataHelper.duplicate_particle(@anim[:particles], p_index)
      @components[:timeline].add_particle(p_index + 1)
      @components[:timeline].particle_index = p_index + 1
      refresh
    when :delete
      if confirm_message(_INTL("Are you sure you want to delete this particle?"))
        p_index = idx_particle
        AnimationEditor::ParticleDataHelper.delete_particle(@anim[:particles], p_index)
        @components[:timeline].delete_particle(p_index)
        refresh
      end
    else
      if @anim[:particles][idx_particle][property] != value
        @anim[:particles][idx_particle][property] = value
        add_to_change_history
        @components[:timeline].set_particles(@anim[:particles]) if [:second_layer, :emitter_type].include?(property)
        refresh_component(:particle_properties, idx_particle)
        refresh_component(:canvas)
        refresh_component(:timeline)   # If focus changes
      end
    end
  end

  def apply_changed_command_batch_editor_value(property, value)
    editor = @components[:command_batch_editor]
    case property
    when :select_all_particles
      editor.get_control(:particles).select_all
    when :select_no_particles
      editor.get_control(:particles).deselect_all
    when :apply
      target_particles = editor.get_control(:particles).value
      return if !target_particles || target_particles.empty?
      start_frame = editor.get_control(:start_keyframe).value
      end_frame = editor.get_control(:end_keyframe).value
      if end_frame < start_frame
        start_frame, end_frame = end_frame, start_frame
      end
      properties = []
      AnimationEditor::ListedParticle::PROPERTY_GROUPS.each_pair do |key, props|
        next if [:mask_group, :second_layer_group].include?(key)
        props.each do |prop|
          next if [:color, :tone].include?(prop)
          properties.push(prop) if GameData::Animation.property_can_interpolate?(prop)
        end
      end
      # Make the changes
      properties.each do |property|
        ctrl = editor.get_control(property)
        next if ctrl.value == 0
        vals = AnimationEditor::PROPERTY_RANGES[property] || [0, 0]
        @anim[:particles].each_with_index do |particle, i|
          next if !target_particles[i] || !particle[property]
          particle[property].each do |cmd|
            next if cmd[0] + cmd[1] < start_frame || cmd[0] + cmd[1] > end_frame
            cmd[2] += ctrl.value
            cmd[2] = cmd[2].clamp(*vals)
          end
        end
      end
      refresh
    end
  end

  def apply_changed_value(component_sym, property, value)
    case component_sym
    when :menu_bar             then apply_changed_menu_bar_value(property, value)
    when :battlers_layout      then apply_changed_battlers_layout_value(property, value)
    when :play_controls        then apply_changed_play_controls_value(property, value)
    when :canvas               then apply_changed_canvas_value(property, value)
    when :batch_edits          then apply_changed_batch_edits_value(property, value)
    when :timeline             then apply_changed_timeline_value(property, value)
    when :editor_settings      then apply_changed_editor_settings_value(property, value)
    when :animation_properties then apply_changed_animation_properties_value(property, value)
    when :particle_properties  then apply_changed_particle_properties_value(property, value)
    when :command_batch_editor then apply_changed_command_batch_editor_value(property, value)
    end
  end

  #-----------------------------------------------------------------------------

  def add_to_change_history
    @redo_history.clear
    new_snapshot = Marshal.load(Marshal.dump(@anim))
    if @undo_history.last != new_snapshot
      @undo_history.push(new_snapshot)
      refresh_component_values(:batch_edits)
    end
  end

  def undo_change
    return if @undo_history.length <= 1
    @redo_history.push(@undo_history.pop)
    reapply_particles
  end

  def redo_change
    return if @redo_history.empty?
    @undo_history.push(@redo_history.pop)
    reapply_particles
  end

  def reapply_particles
    @anim = Marshal.load(Marshal.dump(@undo_history.last))
    @components[:canvas].anim = @anim
    @components[:timeline].set_particles(@anim[:particles])
    @components[:play_controls].anim = @anim
    @components[:play_controls].duration = @components[:timeline].duration
    refresh
  end

  #-----------------------------------------------------------------------------

  def refresh_editor_settings_options
    ctrls = @components[:editor_settings]
    # Color scheme
    ctrls.get_control(:color_scheme).value = @settings[:color_scheme] || :light
    # Canvas background graphic
    files = get_all_files_in_folder("Graphics/Battlebacks", [".png", ".jpg", ".jpeg"])
    files.delete_if { |file| !file[0][/_bg$/] }
    files.map! { |file| file[0].gsub(/_bg$/, "") }
    files.delete_if { |file| !pbResolveBitmap("Graphics/Battlebacks/" + file.sub(/_eve$/, "").sub(/_night$/, "") + "_message") }
    files.map! { |file| [file, file] }
    ctrls.get_control(:canvas_bg).options = files.to_h
    ctrls.get_control(:canvas_bg).value = @settings[:anim_editor][:canvas_bg]
    # User and target sprite graphics
    files = get_all_files_in_folder("Graphics/Pokemon/Front", [".png", ".jpg", ".jpeg"])
    files.delete_if { |file| !GameData::Species.exists?(file[0]) }
    files.map! { |file| [file[0], file[0]] }
    ctrls.get_control(:user_sprite_name).options = files.to_h
    ctrls.get_control(:user_sprite_name).value = @settings[:anim_editor][:user_sprite_name]
    ctrls.get_control(:target_sprite_name).options = files.to_h
    ctrls.get_control(:target_sprite_name).value = @settings[:anim_editor][:target_sprite_name]
    # Default interpolation
    ctrls.get_control(:default_interpolation).value = @settings[:anim_editor][:default_interpolation] || :linear
  end

  def refresh_animation_property_options
    ctrls = @components[:animation_properties]
    case @anim[:type]
    when :move, :opp_move
      move_list = []
      GameData::Move.each { |m| move_list.push([m.id.to_s, m.name]) }
      move_list.push(["STRUGGLE", _INTL("Struggle")]) if move_list.none? { |val| val[0] == "STRUGGLE" }
      move_list.sort! { |a, b| a[1] <=> b[1] }
      ctrls.get_control(:move_label).text = _INTL("Move")
      ctrls.get_control(:move).options = move_list.to_h
      ctrls.get_control(:move).value = @anim[:move]
      ctrls.get_control(:type).value = :move
    when :common, :opp_common
      ctrls.get_control(:move_label).text = _INTL("Common animation")
      ctrls.get_control(:move).options = COMMON_ANIMATIONS.sort
      ctrls.get_control(:move).value = @anim[:move]
      ctrls.get_control(:type).value = :common
    end
    ctrls.get_control(:version).value = @anim[:version] || 0
    ctrls.get_control(:name).value = @anim[:name] || ""
    ctrls.get_control(:pbs_path).value = (@anim[:pbs_path] || "unsorted") + ".txt"
    ctrls.get_control(:has_user).value = !@anim[:no_user]
    ctrls.get_control(:opp_variant).value = ([:opp_move, :opp_common].include?(@anim[:type]))
    ctrls.get_control(:has_target).value = !@anim[:no_target]
    ctrls.get_control(:fps).value = @anim[:fps] || 20
    ctrls.get_control(:hides_data_boxes).value = @anim[:hides_data_boxes] || false
    ctrls.get_control(:usable).value = !(@anim[:ignore] || false)
    ctrls.get_control(:scripts).value = @anim[:scripts].join(",") || ""
    ctrls.get_control(:credit).value = @anim[:credit] || "Anon"
  end

  def refresh_particle_property_options(idx_particle = nil)
    idx_particle ||= particle_index
    ctrls = @components[:particle_properties]
    this_particle = @anim[:particles][idx_particle]
    # Graphic name
    graphic_override_names = {
      "USER"         => _INTL("[[User's sprite]]"),
      "USER_OPP"     => _INTL("[[User's other side sprite]]"),
      "USER_FRONT"   => _INTL("[[User's front sprite]]"),
      "USER_BACK"    => _INTL("[[User's back sprite]]"),
      "TARGET"       => _INTL("[[Target's sprite]]"),
      "TARGET_OPP"   => _INTL("[[Target's other side sprite]]"),
      "TARGET_FRONT" => _INTL("[[Target's front sprite]]"),
      "TARGET_BACK"  => _INTL("[[Target's back sprite]]"),
    }
    graphic_name = this_particle[:graphic]
    graphic_name = graphic_override_names[graphic_name] if graphic_override_names.has_key?(graphic_name)
    ctrls.get_control(:graphic_name).text = graphic_name
    mask_graphic_name = this_particle[:mask_graphic]
    mask_graphic_name = graphic_override_names[mask_graphic_name] if graphic_override_names.has_key?(mask_graphic_name)
    ctrls.get_control(:mask_graphic_name).text = mask_graphic_name
    # Graphic button, focus, second layer
    if ["User", "Target"].include?(this_particle[:name])
      ctrls.get_control(:graphic).disable
      ctrls.get_control(:focus).disable
      this_particle[:second_layer] = false
      ctrls.get_control(:second_layer).disable
    else
      ctrls.get_control(:graphic).enable
      ctrls.get_control(:focus).enable
      ctrls.get_control(:second_layer).enable
    end
    focus_values = {
      :foreground                        => _INTL("Foreground"),
      :midground                         => _INTL("Midground"),
      :background                        => _INTL("Background"),
      :user                              => _INTL("User"),
      :user_position                     => _INTL("User's position"),
      :target                            => _INTL("Target"),
      :target_position                   => _INTL("Target's position"),
      :user_and_target                   => _INTL("User and target"),
      :user_position_and_target          => _INTL("User pos and target"),
      :user_and_target_position          => _INTL("User and target pos"),
      :user_position_and_target_position => _INTL("User pos and target pos"),
      :user_side_foreground              => _INTL("In front of user's side"),
      :user_side_background              => _INTL("Behind user's side"),
      :non_user_side_foreground          => _INTL("In front of non-user's side"),
      :non_user_side_background          => _INTL("Behind non-user's side"),
      :target_side_foreground            => _INTL("In front of target's side"),
      :target_side_background            => _INTL("Behind target's side"),
      :user_and_other_side               => _INTL("User and other side")
    }
    if @anim[:no_user]
      GameData::Animation::FOCUS_TYPES_WITH_USER.each { |f| focus_values.delete(f) }
    end
    if @anim[:no_target]
      GameData::Animation::FOCUS_TYPES_WITH_TARGET.each { |f| focus_values.delete(f) }
    end
    ctrls.get_control(:focus).options = focus_values
    # "If on opposing side..." properties
    if GameData::Animation::FOCUS_TYPES_WITH_USER_AND_TARGET.include?(this_particle[:focus]) ||
      (GameData::Animation::FOCUS_TYPES_OF_SCREEN.include?(this_particle[:focus]) && @anim[:no_user])
      ctrls.get_control(:foe_invert_x).disable
      ctrls.get_control(:foe_invert_y).disable
      ctrls.get_control(:foe_flip).disable
    else
      ctrls.get_control(:foe_invert_x).enable
      ctrls.get_control(:foe_invert_y).enable
      ctrls.get_control(:foe_flip).enable
    end
    # Tiled graphic
    if !this_particle[:second_layer] &&
      (this_particle[:emitter_type] || :none) == :none &&
      !GameData::Animation::FOCUS_TYPES_WITH_USER.include?(this_particle[:focus]) &&
      !GameData::Animation::FOCUS_TYPES_WITH_TARGET.include?(this_particle[:focus])
      ctrls.get_control(:tiled_graphic).enable
    else
      this_particle[:tiled_graphic] = false
      ctrls.get_control(:tiled_graphic).value = this_particle[:tiled_graphic]
      ctrls.get_control(:tiled_graphic).disable
    end
    # Emitter quantity
    if (this_particle[:emitter_type] || :none) == :none
      ctrls.get_control(:emitter_rate).disable
      ctrls.get_control(:emitter_intensity).disable
      ctrls.get_control(:emitter_position_polar_coordinates).disable
      ctrls.get_control(:emitter_spawn_polar_coordinates).disable
    else
      ctrls.get_control(:emitter_rate).enable
      ctrls.get_control(:emitter_intensity).enable
      ctrls.get_control(:emitter_position_polar_coordinates).enable
      ctrls.get_control(:emitter_spawn_polar_coordinates).enable
    end
    # Duplicate button
    ctrls.get_control(:duplicate).enabled = (@anim[:particles][idx_particle][:name] != "SE")
    # Delete button
    ctrls.get_control(:delete).enabled = (!["User", "Target", "SE"].include?(this_particle[:name]))
    # Refresh each control's value
    new_vals = AnimationEditor::ParticleDataHelper.get_all_particle_values(this_particle)
    ctrls.controls.each_pair do |key, ctrl|
      ctrl.value = new_vals[key] if new_vals.include?(key) && ctrl.respond_to?("value=")
    end
    ctrls.refresh
  end

  def refresh_command_batch_editor_options
    editor = @components[:command_batch_editor]
    # Set list of particles and deselect them all
    particle_names = []
    @anim[:particles].each_with_index do |particle, i|
      particle_names.push([i, particle[:name]]) if particle[:name] != "SE"
    end
    editor.get_control(:particles).options = particle_names
    editor.get_control(:particles).deselect_all
    # Set keyframe range to cover entire animation
    editor.get_control(:start_keyframe).value = 0
    editor.get_control(:end_keyframe).value = @components[:timeline].duration
    # Set all value boxes to 0
    properties = []
    AnimationEditor::ListedParticle::PROPERTY_GROUPS.each_pair do |key, props|
      next if [:mask_group, :second_layer_group].include?(key)
      props.each do |prop|
        next if [:color, :tone].include?(prop)
        properties.push(prop) if GameData::Animation.property_can_interpolate?(prop)
      end
    end
    properties.each { |property| editor.get_control(property)&.value = 0 }
  end

  def refresh_component_values(component_sym, extra_value = nil)
    component = @components[component_sym]
    case component_sym
    when :battlers_layout
      component.get_control(:side_size_1).value = @settings[:anim_editor][:side_sizes][0]
      component.get_control(:side_size_2).value = @settings[:anim_editor][:side_sizes][1]
      user_indices = { 0 => "0" }
      user_indices[2] = "2" if @settings[:anim_editor][:side_sizes][0] >= 2
      user_indices[4] = "4" if @settings[:anim_editor][:side_sizes][0] >= 3
      component.get_control(:user_index).options = user_indices
      component.get_control(:user_index).value = @settings[:anim_editor][:user_index]
      component.get_control(:target_indices).value = @settings[:anim_editor][:target_indices].join(",")
      component.get_control(:user_opposes).value = @settings[:anim_editor][:user_opposes]
    when :play_controls
      component.duration = @components[:timeline].duration
    when :canvas
      component.keyframe = keyframe
      component.selected_particle = particle_index
    when :batch_edits
      if @undo_history.length > 1
        component.get_control(:undo).enable
      else
        component.get_control(:undo).disable
      end
      if @redo_history.length > 0
        component.get_control(:redo).enable
      else
        component.get_control(:redo).disable
      end
      property = @components[:timeline].property
      if property && @anim[:particles][particle_index][property]
        component.get_control(:clear_selected_row).enable
      else
        component.get_control(:clear_selected_row).disable
      end
    when :timeline
      # Disable the "move particle up/down" buttons if the selected particle
      # can't move that way (or there is no selected particle)
      cur_index = particle_index
      if cur_index < 1 || cur_index >= @anim[:particles].length || @anim[:particles][cur_index][:name] == "SE"
        component.get_control(:move_particle_up).disable
      else
        component.get_control(:move_particle_up).enable
      end
      if cur_index < 0 || cur_index >= @anim[:particles].length - 2 || @anim[:particles][cur_index][:name] == "SE"
        component.get_control(:move_particle_down).disable
      else
        component.get_control(:move_particle_down).enable
      end
    when :editor_settings
      refresh_editor_settings_options
    when :animation_properties
      refresh_animation_property_options
    when :particle_properties
      refresh_particle_property_options(extra_value)
    when :command_batch_editor
      refresh_command_batch_editor_options
    end
  end

  def refresh_component(component_sym, extra_value = nil)
    return if !@components[component_sym].visible
    refresh_component_values(component_sym, extra_value)
    @components[component_sym].refresh
  end

  def refresh
    @components.each_key { |sym| refresh_component(sym) }
  end

  #-----------------------------------------------------------------------------

  def update_input
    if Input.triggerex?(:SPACE)
      # Play animation
      @ready_to_play = true
    elsif Input.triggerex?(:INSERT)
      idx_particle, property = @components[:timeline].particle_index_and_property
      if property
        particle = @anim[:particles][idx_particle]
        if !AnimationEditor::ParticleDataHelper.has_command_at?(particle, property, keyframe)
          value = AnimationEditor::ParticleDataHelper.get_keyframe_particle_value(particle, property, keyframe)[0]
          new_cmds = AnimationEditor::ParticleDataHelper.add_command(particle, property, keyframe, value)
          if new_cmds
            particle[property] = new_cmds
            # NOTE: Intentionally not adding @settings[:anim_editor][:default_interpolation]
            #       here, because the inserted command will have the same value as
            #       the one before it and won't need interpolating anyway.
          else
            particle.delete(property)
          end
          refresh
          add_to_change_history
        end
      end
    elsif Input.triggerex?(:DELETE)
      idx_particle, property = @components[:timeline].particle_index_and_property
      if property
        particle = @anim[:particles][idx_particle]
        new_cmds = AnimationEditor::ParticleDataHelper.delete_command(particle, property, keyframe, true)
        if new_cmds
          particle[property] = new_cmds
        else
          particle.delete(property)
        end
        refresh
        add_to_change_history
      end
    elsif Input.pressex?(:LCTRL) || Input.pressex?(:RCTRL)
      if Input.triggerex?(:Z) || Input.repeatex?(:Z)
        undo_change
      elsif Input.triggerex?(:Y) || Input.repeatex?(:Y)
        redo_change
      end
    end
  end

  def update
    old_keyframe = keyframe
    old_particle_index = particle_index
    old_property = @components[:timeline].property
    old_captured = @captured
    # Update captured control (if there is one)
    if @captured
      @captured.update
      @captured = nil if !@captured.busy?
    end
    # Update controls (except the captured control)
    if !@captured || !@captured.respond_to?("mouse_in_control?") ||
      !@captured.mouse_in_control?
      @components.each_value do |c|
        next if old_captured && c == old_captured
        c.update
        @captured = c if c.busy?
      end
    end
    # Check for updated controls
    @components.each_pair do |sym, component|
      next if !component.changed?
      if component.respond_to?("changed_controls")
        changed_ctrls = component.changed_controls
        if changed_ctrls
          changed_ctrls.each_pair do |property, value|
            apply_changed_value(sym, property, value)
          end
        end
      end
      component.clear_changed
      component.repaint if [:timeline, :menu_bar].include?(sym)
    end
    update_input if !@captured
    refresh if keyframe != old_keyframe || particle_index != old_particle_index ||
               @components[:timeline].property != old_property
  end

  #-----------------------------------------------------------------------------

  def run
    Input.text_input = false
    loop do
      Graphics.update
      Input.update
      update
      if @ready_to_play
        play_animation
        @ready_to_play = false
      elsif @captured.nil? && @quit
        case message(_INTL("Do you want to save changes to the animation?"),
                    [:yes, _INTL("Yes")], [:no, _INTL("No")], [:cancel, _INTL("Cancel")])
        when :yes
          save
        when :cancel
          @quit = false
        end
        break if @quit
      end
    end
    dispose
  end
end
