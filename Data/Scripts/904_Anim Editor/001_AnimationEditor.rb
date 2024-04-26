#===============================================================================
#
#===============================================================================
class AnimationEditor
  attr_reader :property_pane
  attr_reader :components
  attr_reader :anim

  BORDER_THICKNESS = 4
  WINDOW_WIDTH     = Settings::SCREEN_WIDTH + 352 + (BORDER_THICKNESS * 4)
  WINDOW_HEIGHT    = Settings::SCREEN_HEIGHT + 424 + (BORDER_THICKNESS * 4)

  # Components
  MENU_BAR_WIDTH  = WINDOW_WIDTH
  MENU_BAR_HEIGHT = 30

  CANVAS_X      = BORDER_THICKNESS
  CANVAS_Y      = MENU_BAR_HEIGHT + BORDER_THICKNESS
  CANVAS_WIDTH  = Settings::SCREEN_WIDTH
  CANVAS_HEIGHT = Settings::SCREEN_HEIGHT

  PLAY_CONTROLS_X      = CANVAS_X
  PLAY_CONTROLS_Y      = CANVAS_Y + CANVAS_HEIGHT + (BORDER_THICKNESS * 2)
  PLAY_CONTROLS_WIDTH  = CANVAS_WIDTH
  PLAY_CONTROLS_HEIGHT = 64 - (BORDER_THICKNESS * 2)

  SIDE_PANE_X             = CANVAS_X + CANVAS_WIDTH + (BORDER_THICKNESS * 2)
  SIDE_PANE_Y             = CANVAS_Y
  SIDE_PANE_WIDTH         = WINDOW_WIDTH - SIDE_PANE_X - BORDER_THICKNESS
  SIDE_PANE_HEIGHT        = CANVAS_HEIGHT + PLAY_CONTROLS_HEIGHT + (BORDER_THICKNESS * 2)
  SIDE_PANE_DELETE_MARGIN = 32

  PARTICLE_LIST_X      = BORDER_THICKNESS
  PARTICLE_LIST_Y      = SIDE_PANE_Y + SIDE_PANE_HEIGHT + (BORDER_THICKNESS * 2)
  PARTICLE_LIST_WIDTH  = WINDOW_WIDTH - (BORDER_THICKNESS * 2)
  PARTICLE_LIST_HEIGHT = WINDOW_HEIGHT - PARTICLE_LIST_Y - BORDER_THICKNESS

  # Pop-up windows
  MESSAGE_BOX_WIDTH         = WINDOW_WIDTH * 3 / 4
  MESSAGE_BOX_HEIGHT        = 160
  MESSAGE_BOX_BUTTON_WIDTH  = 150
  MESSAGE_BOX_BUTTON_HEIGHT = 32
  MESSAGE_BOX_SPACING       = 16

  ANIM_PROPERTIES_LABEL_WIDTH = UIControls::ControlsContainer::OFFSET_FROM_LABEL_X + 80
  ANIM_PROPERTIES_WIDTH       = SIDE_PANE_WIDTH + 80
  ANIM_PROPERTIES_HEIGHT      = WINDOW_HEIGHT * 3 / 4
  ANIM_PROPERTIES_X           = (WINDOW_WIDTH - ANIM_PROPERTIES_WIDTH) / 2
  ANIM_PROPERTIES_Y           = (WINDOW_HEIGHT - ANIM_PROPERTIES_HEIGHT) / 2

  CHOOSER_BUTTON_WIDTH     = 150
  CHOOSER_BUTTON_HEIGHT    = MESSAGE_BOX_BUTTON_HEIGHT
  CHOOSER_FILE_LIST_X      = 6
  CHOOSER_FILE_LIST_Y      = 30
  CHOOSER_FILE_LIST_WIDTH  = (CHOOSER_BUTTON_WIDTH * 2) + (UIControls::List::BORDER_THICKNESS * 2)
  CHOOSER_FILE_LIST_HEIGHT = (UIControls::List::ROW_HEIGHT * 15) + (UIControls::List::BORDER_THICKNESS * 2)

  GRAPHIC_CHOOSER_PREVIEW_SIZE  = 320   # Square
  GRAPHIC_CHOOSER_WINDOW_WIDTH  = CHOOSER_FILE_LIST_X + CHOOSER_FILE_LIST_WIDTH + 8 + GRAPHIC_CHOOSER_PREVIEW_SIZE + 8
  GRAPHIC_CHOOSER_WINDOW_HEIGHT = CHOOSER_FILE_LIST_Y + CHOOSER_FILE_LIST_HEIGHT + 8 + CHOOSER_BUTTON_HEIGHT + 8
  GRAPHIC_CHOOSER_X             = ((WINDOW_WIDTH - GRAPHIC_CHOOSER_WINDOW_WIDTH) / 2)
  GRAPHIC_CHOOSER_Y             = ((WINDOW_HEIGHT - GRAPHIC_CHOOSER_WINDOW_HEIGHT) / 2)

  AUDIO_CHOOSER_LABEL_WIDTH   = UIControls::ControlsContainer::OFFSET_FROM_LABEL_X - 10
  AUDIO_CHOOSER_SLIDER_WIDTH  = (CHOOSER_BUTTON_WIDTH * 2) - AUDIO_CHOOSER_LABEL_WIDTH
  AUDIO_CHOOSER_WINDOW_WIDTH  = CHOOSER_FILE_LIST_X + CHOOSER_FILE_LIST_WIDTH + 8 + (CHOOSER_BUTTON_WIDTH * 2) + 4
  AUDIO_CHOOSER_WINDOW_HEIGHT = CHOOSER_FILE_LIST_Y + CHOOSER_FILE_LIST_HEIGHT + 8 + CHOOSER_BUTTON_HEIGHT + 8
  AUDIO_CHOOSER_X             = ((WINDOW_WIDTH - AUDIO_CHOOSER_WINDOW_WIDTH) / 2)
  AUDIO_CHOOSER_Y             = ((WINDOW_HEIGHT - AUDIO_CHOOSER_WINDOW_HEIGHT) / 2)

  # This list of animations was gathered manually by looking at all instances of
  # pbCommonAnimation.
  COMMON_ANIMATIONS = [
    "AquaRing", "Attract", "BanefulBunker", "BeakBlast", "Bind",
    "Burn", "Clamp", "Confusion", "CraftyShield", "Curse",
    "EatBerry", "ElectricTerrain", "FireSpin", "FocusPunch", "Frozen",
    "GrassyTerrain", "Hail", "HarshSun", "HealingWish", "HealthDown",
    "HealthUp", "HeavyRain", "Infestation", "Ingrain", "KingsShield",
    "LeechSeed", "LevelUp", "LunarDance", "MagmaStorm", "MegaEvolution",
    "MegaEvolution2", "MistyTerrain", "Nightmare", "Obstruct", "Octolock",
    "Paralysis", "ParentalBond", "Poison", "Powder", "PrimalGroudon",
    "PrimalGroudon2", "PrimalKyogre", "PrimalKyogre2", "Protect", "PsychicTerrain",
    "QuickGuard", "Rain", "Rainbow", "RainbowOpp", "Sandstorm",
    "SandTomb", "SeaOfFire", "SeaOfFireOpp", "Shadow", "ShadowSky",
    "ShellTrap", "Shiny", "Sleep", "SpikyShield", "StatDown",
    "StatUp", "StrongWinds", "Sun", "SuperShiny", "Swamp",
    "SwampOpp", "Toxic", "UseItem", "WideGuard", "Wrap"
  ]
  DELETABLE_COMMAND_PANE_PROPERTIES = [
    :x, :y, :z, :frame, :visible, :opacity, :zoom_x, :zoom_y, :angle, :flip, :blending
  ]
  DELETABLE_COLOR_TONE_PANE_PROPERTIES = [
    :color_red, :color_green, :color_blue, :color_alpha,
    :tone_red, :tone_green, :tone_blue, :tone_gray
  ]

  DEBUG_SETTINGS_FILE_PATH = if File.directory?(System.data_directory)
                               System.data_directory + "debug_settings.rxdata"
                             else
                               "./debug_settings.rxdata"
                             end

  #-----------------------------------------------------------------------------

  def initialize(anim_id, anim)
    load_settings
    @anim_id = anim_id
    @anim = anim
    @pbs_path = anim[:pbs_path]
    @property_pane = :commands_pane
    @quit = false
    initialize_viewports
    initialize_bitmaps
    initialize_components
    @captured = nil
    set_components_contents
    refresh
  end

  def initialize_viewports
    @viewport = Viewport.new(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
    @viewport.z = 99999
    @canvas_viewport = Viewport.new(CANVAS_X, CANVAS_Y, CANVAS_WIDTH, CANVAS_HEIGHT)
    @canvas_viewport.z = @viewport.z
    @pop_up_viewport = Viewport.new(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
    @pop_up_viewport.z = @viewport.z + 50
  end

  def initialize_bitmaps
    # Background for main editor
    @screen_bitmap = BitmapSprite.new(WINDOW_WIDTH, WINDOW_HEIGHT, @viewport)
    @screen_bitmap.z = -100
    # Semi-transparent black overlay to dim the screen while a pop-up window is open
    @pop_up_bg_bitmap = BitmapSprite.new(WINDOW_WIDTH, WINDOW_HEIGHT, @pop_up_viewport)
    @pop_up_bg_bitmap.z = -100
    @pop_up_bg_bitmap.visible = false
    # Bitmaps for "delete this property change" buttons in the side pane
    @delete_bitmap = Bitmap.new(16, 16)
    @delete_disabled_bitmap = Bitmap.new(16, 16)
    14.times do |i|
      case i
      when 0, 13 then wid = 3
      when 1, 12 then wid = 4
      else            wid = 5
      end
      @delete_bitmap.fill_rect([i - 1, 1].max, i + 1, wid, 1, Color.new(248, 96, 96))
      @delete_bitmap.fill_rect([i - 1, 1].max, 14 - i, wid, 1, Color.new(248, 96, 96))
      @delete_disabled_bitmap.fill_rect([i - 1, 1].max, i + 1, wid, 1, Color.new(160, 160, 160))
      @delete_disabled_bitmap.fill_rect([i - 1, 1].max, 14 - i, wid, 1, Color.new(160, 160, 160))
    end
    # Editor settings button bitmap
    @editor_settings_bitmap = Bitmap.new(18, 18)
    settings_array = [
      0, 0, 0, 0, 0, 0, 0, 0, 1,
      0, 0, 0, 0, 0, 0, 0, 1, 1,
      0, 0, 1, 1, 1, 0, 0, 1, 1,
      0, 0, 1, 1, 1, 1, 0, 1, 1,
      0, 0, 1, 1, 1, 1, 1, 1, 1,
      0, 0, 0, 1, 1, 1, 1, 1, 1,
      0, 0, 0, 0, 1, 1, 1, 1, 0,
      0, 1, 1, 1, 1, 1, 1, 0, 0,
      1, 1, 1, 1, 1, 1, 0, 0, 0
    ]
    settings_array.length.times do |i|
      next if settings_array[i] == 0
      @editor_settings_bitmap.fill_rect(i % 9, i / 9, 1, 1, Color.black)
      @editor_settings_bitmap.fill_rect(17 - (i % 9), i / 9, 1, 1, Color.black)
      @editor_settings_bitmap.fill_rect(i % 9, 17 - (i / 9), 1, 1, Color.black)
      @editor_settings_bitmap.fill_rect(17 - (i % 9), 17 - (i / 9), 1, 1, Color.black)
    end
    # Draw in these bitmaps
    draw_editor_background
  end

  def initialize_components
    @components = {}
    # Menu bar
    @components[:menu_bar] = AnimationEditor::MenuBar.new(0, 0, MENU_BAR_WIDTH, MENU_BAR_HEIGHT, @viewport)
    # Canvas
    @components[:canvas] = AnimationEditor::Canvas.new(@canvas_viewport, @anim, @settings)
    # Side panes
    AnimationEditor::SidePanes.each_pane do |pane, hash|
      @components[pane] = UIControls::ControlsContainer.new(
        SIDE_PANE_X, SIDE_PANE_Y, SIDE_PANE_WIDTH, SIDE_PANE_HEIGHT,
        hash[:deletable_properties].nil? ? 0 : SIDE_PANE_DELETE_MARGIN
      )
    end
    # Timeline/particle list
    @components[:particle_list] = AnimationEditor::ParticleList.new(
      PARTICLE_LIST_X, PARTICLE_LIST_Y, PARTICLE_LIST_WIDTH, PARTICLE_LIST_HEIGHT, @viewport
    )
    @components[:particle_list].set_interactive_rects
    # Play controls
    @components[:play_controls] = AnimationEditor::PlayControls.new(
      PLAY_CONTROLS_X, PLAY_CONTROLS_Y, PLAY_CONTROLS_WIDTH, PLAY_CONTROLS_HEIGHT, @viewport
    )
    # Animation properties pop-up window
    @components[:animation_properties] = UIControls::ControlsContainer.new(
      ANIM_PROPERTIES_X + 4, ANIM_PROPERTIES_Y, ANIM_PROPERTIES_WIDTH - 8, ANIM_PROPERTIES_HEIGHT
    )
    @components[:animation_properties].viewport.z = @pop_up_viewport.z + 1
    @components[:animation_properties].label_offset_x = 170
    # Editor settings pop-up window
    @components[:editor_settings] = UIControls::ControlsContainer.new(
      ANIM_PROPERTIES_X + 4, ANIM_PROPERTIES_Y, ANIM_PROPERTIES_WIDTH - 8, ANIM_PROPERTIES_HEIGHT
    )
    @components[:editor_settings].viewport.z = @pop_up_viewport.z + 1
    @components[:editor_settings].label_offset_x = 170
    # Graphic chooser pop-up window
    @components[:graphic_chooser] = UIControls::ControlsContainer.new(
      GRAPHIC_CHOOSER_X, GRAPHIC_CHOOSER_Y, GRAPHIC_CHOOSER_WINDOW_WIDTH, GRAPHIC_CHOOSER_WINDOW_HEIGHT
    )
    @components[:graphic_chooser].viewport.z = @pop_up_viewport.z + 1
    # Audio chooser pop-up window
    @components[:audio_chooser] = UIControls::ControlsContainer.new(
      AUDIO_CHOOSER_X, AUDIO_CHOOSER_Y, AUDIO_CHOOSER_WINDOW_WIDTH, AUDIO_CHOOSER_WINDOW_HEIGHT
    )
    @components[:audio_chooser].viewport.z = @pop_up_viewport.z + 1
  end

  def dispose
    @screen_bitmap.dispose
    @pop_up_bg_bitmap.dispose
    @delete_bitmap.dispose
    @delete_disabled_bitmap.dispose
    @editor_settings_bitmap.dispose
    @components.each_value { |c| c.dispose }
    @components.clear
    @viewport.dispose
    @canvas_viewport.dispose
    @pop_up_viewport.dispose
  end

  #-----------------------------------------------------------------------------

  def keyframe
    return @components[:particle_list].keyframe
  end

  def particle_index
    return @components[:particle_list].particle_index
  end

  def load_settings
    if File.file?(DEBUG_SETTINGS_FILE_PATH)
      @settings = SaveData.get_data_from_file(DEBUG_SETTINGS_FILE_PATH)[:anim_editor]
    else
      @settings = {
        :side_sizes         => [1, 1],   # Player's side, opposing side
        :user_index         => 0,        # 0, 2, 4
        :target_indices     => [1],      # There must be at least one valid target
        :user_opposes       => false,
        :canvas_bg          => "indoor1",
        # NOTE: These sprite names are also used in Pokemon.play_cry and so
        #       should be a species ID (being a string is fine).
        :user_sprite_name   => "DRAGONITE",
        :target_sprite_name => "CHARIZARD"
      }
    end
  end

  def save_settings
    data = { :anim_editor => @settings }
    File.open(DEBUG_SETTINGS_FILE_PATH, "wb") { |file| Marshal.dump(data, file) }
  end

  def save
    AnimationEditor::ParticleDataHelper.optimize_all_particles(@anim[:particles])
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
    ret += " (" + @anim[:version].to_s + ")" if @anim[:version] > 0
    ret += " - " + @anim[:name] if @anim[:name]
    return ret
  end

  #-----------------------------------------------------------------------------

  def set_menu_bar_contents
    @components[:menu_bar].add_button(:quit, _INTL("Quit"))
    @components[:menu_bar].add_button(:save, _INTL("Save"))
    @components[:menu_bar].add_settings_button(:settings, @editor_settings_bitmap)
    @components[:menu_bar].add_name_button(:name, get_animation_display_name)
  end

  def set_canvas_contents
  end

  def add_side_pane_tab_buttons(component, pane)
    next_pos_x, next_pos_y = pane.next_control_position
    [
      [:commands_pane, :general_tab, _INTL("General")],
      [:color_tone_pane, :color_tone_tab, _INTL("Color/Tone")]
    ].each_with_index do |tab, i|
      btn = UIControls::Button.new(100, 28, pane.viewport, tab[2])
      btn.set_fixed_size
      btn.set_highlighted if tab[0] == component
      pane.add_control_at(tab[1], btn, next_pos_x, next_pos_y)
      next_pos_x += btn.width
    end
    pane.increment_row_count(1)
  end

  def set_side_panes_contents
    AnimationEditor::SidePanes.each_pane do |pane, hash|
      deletable_properties = hash[:deletable_properties]
      AnimationEditor::SidePanes.each_property(pane) do |property, hash|
        hash[:new].call(@components[pane], self) if hash[:new]
        if deletable_properties&.include?(property)
          parent = @components[pane].get_control(property)
          btn = UIControls::BitmapButton.new(parent.x + parent.width + 6, parent.y + 2,
                                             @components[pane].viewport, @delete_bitmap, @delete_disabled_bitmap)
          btn.set_interactive_rects
          @components[pane].controls.push([(property.to_s + "_delete").to_sym, btn])
        end
      end
    end
  end

  def set_particle_list_contents
    @components[:particle_list].set_particles(@anim[:particles])
  end

  def set_play_controls_contents
    @components[:play_controls].add_play_controls
    @components[:play_controls].duration = @components[:particle_list].duration
  end

  def set_animation_properties_contents
    anim_properties = @components[:animation_properties]
    anim_properties.add_header_label(:header, _INTL("Animation properties"))
    anim_properties.add_labelled_checkbox(:usable, _INTL("Can be used in battle?"), true)
    anim_properties.add_labelled_dropdown_list(:type, _INTL("Animation type"), {
      :move   => _INTL("Move"),
      :common => _INTL("Common")
    }, :move)
    anim_properties.add_labelled_checkbox(:opp_variant, _INTL("User is opposing?"), false)
    anim_properties.add_labelled_text_box_dropdown_list(:move, "", [], "")
    move_ctrl = anim_properties.get_control(:move)
    move_ctrl.max_rows = 18
    anim_properties.add_labelled_number_text_box(:version, _INTL("Version"), 0, 99, 0)
    anim_properties.add_labelled_text_box(:name, _INTL("Name"), "")
    anim_properties.add_labelled_text_box(:pbs_path, _INTL("PBS filepath"), "")
    anim_properties.add_labelled_checkbox(:has_user, _INTL("Involves a user?"), true)
    anim_properties.add_labelled_checkbox(:has_target, _INTL("Involves a target?"), true)
    anim_properties.add_button(:close, _INTL("Close"))
    anim_properties.visible = false
  end

  def set_editor_settings_contents
    editor_settings = @components[:editor_settings]
    editor_settings.add_header_label(:header, _INTL("Editor settings"))
    editor_settings.add_labelled_dropdown_list(:side_size_1, _INTL("Side sizes"), {
      1 => "1",
      2 => "2",
      3 => "3"
    }, 1)
    size_ctrl = editor_settings.get_control(:side_size_1)
    size_ctrl.box_width = 50
    size_ctrl.set_interactive_rects
    size_ctrl.invalidate
    ctrl = UIControls::Label.new(50, UIControls::ControlsContainer::LINE_SPACING, editor_settings.viewport, _INTL("vs."))
    editor_settings.add_control_at(:side_size_vs_label, ctrl, size_ctrl.x + 60, size_ctrl.y)
    ctrl = UIControls::DropdownList.new(54, UIControls::ControlsContainer::LINE_SPACING, editor_settings.viewport, {
      1 => "1",
      2 => "2",
      3 => "3"
    }, 1)
    ctrl.box_width = 50
    ctrl.invalidate
    editor_settings.add_control_at(:side_size_2, ctrl, size_ctrl.x + 93, size_ctrl.y)
    editor_settings.add_labelled_dropdown_list(:user_index, _INTL("User index"), {
      0 => "0",
      2 => "2",
      4 => "4"
    }, 0)
    ctrl = editor_settings.get_control(:user_index)
    ctrl.box_width = 50
    ctrl.set_interactive_rects
    ctrl.invalidate
    # TODO: I want a better control than this for choosing the target indices.
    editor_settings.add_labelled_text_box(:target_indices, _INTL("Target indices"), "")
    editor_settings.add_labelled_checkbox(:user_opposes, _INTL("User is opposing?"), false)
    editor_settings.add_labelled_dropdown_list(:canvas_bg, _INTL("Background graphic"), {}, "")
    editor_settings.add_labelled_dropdown_list(:user_sprite_name, _INTL("User graphic"), {}, "")
    ctrl = editor_settings.get_control(:user_sprite_name)
    ctrl.max_rows = 16
    editor_settings.add_labelled_dropdown_list(:target_sprite_name, _INTL("Target graphic"), {}, "")
    ctrl = editor_settings.get_control(:target_sprite_name)
    ctrl.max_rows = 16
    editor_settings.add_button(:close, _INTL("Close"))
    editor_settings.visible = false
  end

  def set_graphic_chooser_contents
    graphic_chooser = @components[:graphic_chooser]
    graphic_chooser.add_header_label(:header, _INTL("Choose a file"))
    # List of files
    list = UIControls::List.new(CHOOSER_FILE_LIST_WIDTH, CHOOSER_FILE_LIST_HEIGHT, graphic_chooser.viewport, [])
    graphic_chooser.add_control_at(:list, list, CHOOSER_FILE_LIST_X, CHOOSER_FILE_LIST_Y)
    # Buttons
    [[:ok, _INTL("OK")], [:cancel, _INTL("Cancel")]].each_with_index do |option, i|
      btn = UIControls::Button.new(CHOOSER_BUTTON_WIDTH, MESSAGE_BOX_BUTTON_HEIGHT, graphic_chooser.viewport, option[1])
      btn.set_fixed_size
      graphic_chooser.add_control_at(option[0], btn,
                                     CHOOSER_FILE_LIST_X + (CHOOSER_BUTTON_WIDTH * i),
                                     CHOOSER_FILE_LIST_Y + CHOOSER_FILE_LIST_HEIGHT + 2)
    end
    graphic_chooser.visible = false
  end

  def set_audio_chooser_contents
    audio_chooser = @components[:audio_chooser]
    audio_chooser.add_header_label(:header, _INTL("Choose a file"))
    # List of files
    list = UIControls::List.new(CHOOSER_FILE_LIST_WIDTH, CHOOSER_FILE_LIST_HEIGHT, audio_chooser.viewport, [])
    audio_chooser.add_control_at(:list, list, CHOOSER_FILE_LIST_X, CHOOSER_FILE_LIST_Y)
    # Buttons
    [[:ok, _INTL("OK")], [:cancel, _INTL("Cancel")]].each_with_index do |option, i|
      btn = UIControls::Button.new(CHOOSER_BUTTON_WIDTH, MESSAGE_BOX_BUTTON_HEIGHT, audio_chooser.viewport, option[1])
      btn.set_fixed_size
      audio_chooser.add_control_at(option[0], btn,
                                   CHOOSER_FILE_LIST_X + (CHOOSER_BUTTON_WIDTH * i) + 2,
                                   CHOOSER_FILE_LIST_Y + CHOOSER_FILE_LIST_HEIGHT + 2)
    end
    # Volume and pitch sliders
    [[:volume, _INTL("Volume"), 0, 100], [:pitch, _INTL("Pitch"), 0, 200]].each_with_index do |option, i|
      label = UIControls::Label.new(AUDIO_CHOOSER_LABEL_WIDTH, 28, audio_chooser.viewport, option[1])
      audio_chooser.add_control_at((option[0].to_s + "_label").to_sym, label,
                                   list.x + list.width + 6, list.y + (28 * i))
      slider = UIControls::NumberSlider.new(AUDIO_CHOOSER_SLIDER_WIDTH, 28, audio_chooser.viewport, option[2], option[3], 100)
      audio_chooser.add_control_at(option[0], slider, label.x + label.width, label.y)
    end
    # Playback buttons
    [[:play, _INTL("Play")], [:stop, _INTL("Stop")]].each_with_index do |option, i|
      btn = UIControls::Button.new(CHOOSER_BUTTON_WIDTH, MESSAGE_BOX_BUTTON_HEIGHT, audio_chooser.viewport, option[1])
      btn.set_fixed_size
      audio_chooser.add_control_at(option[0], btn,
                                   list.x + list.width + 6 + (CHOOSER_BUTTON_WIDTH * i),
                                   list.y + (28 * 2))
    end
    audio_chooser.visible = false
  end

  def set_components_contents
    set_menu_bar_contents
    set_canvas_contents
    set_side_panes_contents
    set_particle_list_contents
    set_play_controls_contents   # Intentionally after set_particle_list_contents
    set_animation_properties_contents
    set_editor_settings_contents
    set_graphic_chooser_contents
    set_audio_chooser_contents
  end

  #-----------------------------------------------------------------------------

  def draw_editor_background
    # Fill the whole screen with white
    @screen_bitmap.bitmap.fill_rect(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, Color.white)
    # Outline around elements
    @screen_bitmap.bitmap.border_rect(CANVAS_X, CANVAS_Y, CANVAS_WIDTH, CANVAS_HEIGHT,
                                      BORDER_THICKNESS, Color.white, Color.black)
    @screen_bitmap.bitmap.border_rect(PLAY_CONTROLS_X, PLAY_CONTROLS_Y, PLAY_CONTROLS_WIDTH, PLAY_CONTROLS_HEIGHT,
                                      BORDER_THICKNESS, Color.white, Color.black)
    @screen_bitmap.bitmap.border_rect(SIDE_PANE_X, SIDE_PANE_Y, SIDE_PANE_WIDTH, SIDE_PANE_HEIGHT,
                                      BORDER_THICKNESS, Color.white, Color.black)
    @screen_bitmap.bitmap.border_rect(PARTICLE_LIST_X, PARTICLE_LIST_Y, PARTICLE_LIST_WIDTH, PARTICLE_LIST_HEIGHT,
                                      BORDER_THICKNESS, Color.white, Color.black)
    # Make the pop-up background semi-transparent
    @pop_up_bg_bitmap.bitmap.fill_rect(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, Color.new(0, 0, 0, 128))
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
      idx_user = @settings[:user_index]
      if @settings[:user_opposes] || [:opp_move, :opp_common].include?(@anim[:type])
        idx_user += 1
      end
      user_battler = AnimationPlayer::FakeBattler.new(idx_user, @settings[:user_sprite_name])
    end
    target_battlers = nil
    if !@anim[:no_target]
      target_battlers = []
      @settings[:target_indices].each do |idx|
        idx_target = idx
        if @settings[:user_opposes] || [:opp_move, :opp_common].include?(@anim[:type])
          idx_target += (idx_target.even?) ? 1 : -1
        end
        target_battlers.push(AnimationPlayer::FakeBattler.new(idx_target, @settings[:target_sprite_name]))
      end
    end
    # Create animation player
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
        if play_controls.values.keys.include?(:stop)
          play_controls.clear_changed
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
    @components[:canvas].end_playing_animation
    play_controls.end_playing_animation
  end

  #-----------------------------------------------------------------------------

  def refresh_component_visibility(component_sym)
    # Panes are all mutually exclusive
    side_pane = AnimationEditor::SidePanes.get_pane(component_sym)
    if side_pane && side_pane[:set_visible]
      @components[component_sym].visible = side_pane[:set_visible].call(self, @anim, keyframe, particle_index)
    end
  end

  def refresh_editor_settings_options
    user_indices = { 0 => "0" }
    user_indices[2] = "2" if @settings[:side_sizes][0] >= 2
    user_indices[4] = "4" if @settings[:side_sizes][0] >= 3
    @components[:editor_settings].get_control(:user_index).values = user_indices
    # Canvas background graphic
    files = get_all_files_in_folder("Graphics/Battlebacks", [".png", ".jpg", ".jpeg"])
    files.map! { |file| file[0] }
    files.delete_if { |file| !file[/_bg$/] }
    files.map! { |file| file.gsub(/_bg$/, "") }
    files.delete_if { |file| !pbResolveBitmap("Graphics/Battlebacks/" + file.sub(/_eve$/, "").sub(/_night$/, "") + "_message") }
    files.map! { |file| [file, file] }
    @components[:editor_settings].get_control(:canvas_bg).values = files.to_h
    # User and target sprite graphics
    files = get_all_files_in_folder("Graphics/Pokemon/Front", [".png", ".jpg", ".jpeg"])
    files.map! { |file| file[0] }
    files.delete_if { |file| !GameData::Species.exists?(file) }
    files.map! { |file| [file, file] }
    @components[:editor_settings].get_control(:user_sprite_name).values = files.to_h
    @components[:editor_settings].get_control(:target_sprite_name).values = files.to_h
  end

  def refresh_move_property_options
    ctrl = @components[:animation_properties].get_control(:move)
    case @anim[:type]
    when :move, :opp_move
      move_list = []
      GameData::Move.each { |m| move_list.push([m.id.to_s, m.name]) }
      move_list.push(["STRUGGLE", _INTL("Struggle")]) if move_list.none? { |val| val[0] == "STRUGGLE" }
      move_list.sort! { |a, b| a[1] <=> b[1] }
      ctrl.values = move_list.to_h
    when :common, :opp_common
      ctrl.values = COMMON_ANIMATIONS
    end
  end

  def refresh_component_values(component_sym)
    component = @components[component_sym]
    case component_sym
    when :editor_settings
      refresh_editor_settings_options
    when :canvas
      component.keyframe = keyframe
      component.selected_particle = particle_index
    when :particle_list
      # Disable the "move particle up/down" buttons if the selected particle
      # can't move that way (or there is no selected particle)
      cur_index = particle_index
      if cur_index < 1 || @anim[:particles][cur_index][:name] == "SE"
        component.get_control(:move_particle_up).disable
      else
        component.get_control(:move_particle_up).enable
      end
      if cur_index < 0 || cur_index >= @anim[:particles].length - 1 || @anim[:particles][cur_index][:name] == "SE"
        component.get_control(:move_particle_down).disable
      else
        component.get_control(:move_particle_down).enable
      end
    when :animation_properties
      refresh_move_property_options
      case @anim[:type]
      when :move, :opp_move
        component.get_control(:move_label).text = _INTL("Move")
        component.get_control(:move).value = @anim[:move]
      when :common, :opp_common
        component.get_control(:move_label).text = _INTL("Common animation")
      end
    else
      # Side panes
      if AnimationEditor::SidePanes.is_side_pane?(component_sym)
        # Refresh each control's value
        if AnimationEditor::SidePanes.get_pane(component_sym)[:unchanging_properties]
          new_vals = AnimationEditor::ParticleDataHelper.get_all_particle_values(@anim[:particles][particle_index])
          component.controls.each do |ctrl|
            next if !new_vals.include?(ctrl[0])
            ctrl[1].value = new_vals[ctrl[0]] if ctrl[1].respond_to?("value=")
          end
        else
          new_vals = AnimationEditor::ParticleDataHelper.get_all_keyframe_particle_values(@anim[:particles][particle_index], keyframe)
          component.controls.each do |ctrl|
            next if !new_vals.include?(ctrl[0])
            ctrl[1].value = new_vals[ctrl[0]][0] if ctrl[1].respond_to?("value=")
          end
        end
        # Additional refreshing of controls
        AnimationEditor::SidePanes.each_property(component_sym) do |property, hash|
          next if !hash[:refresh_value]
          hash[:refresh_value].call(component.get_control(property), self)
        end
        component.repaint
        # Enable/disable property delete buttons
        deletable_properties = AnimationEditor::SidePanes.get_pane(component_sym)[:deletable_properties]
        if deletable_properties
          deletable_properties.each do |property|
            if AnimationEditor::ParticleDataHelper.has_command_at?(@anim[:particles][particle_index], property, keyframe)
              component.get_control((property.to_s + "_delete").to_sym).enable
            else
              component.get_control((property.to_s + "_delete").to_sym).disable
            end
          end
        end
      end
    end
  end

  def refresh_component(component_sym)
    refresh_component_visibility(component_sym)
    return if !@components[component_sym].visible
    refresh_component_values(component_sym)
    @components[component_sym].refresh
  end

  def refresh
    @components.each_key { |sym| refresh_component(sym) }
  end

  #-----------------------------------------------------------------------------

  def apply_changed_value(component_sym, property, value)
    case component_sym
    when :menu_bar
      case property
      when :quit
        @quit = true
      when :save
        save
      when :name
        edit_animation_properties
        @components[:menu_bar].anim_name = get_animation_display_name
        refresh_component(:particle_list)
      when :settings
        edit_editor_settings
      end
    when :editor_settings
      case property
      when :side_size_1
        old_val = @settings[:side_sizes][0]
        @settings[:side_sizes][0] = value
        if @settings[:user_index] >= value * 2
          @settings[:user_index] = (value - 1) * 2
          @components[:editor_settings].get_control(:user_index).value = @settings[:user_index]
          @settings[:target_indices].delete_if { |val| val == @settings[:user_index] }
        end
        @settings[:target_indices].delete_if { |val| val.even? && val >= value * 2 }
        @settings[:target_indices].push(1) if @settings[:target_indices].empty?
        @components[:editor_settings].get_control(:target_indices).value = @settings[:target_indices].join(",")
        refresh_editor_settings_options if value != old_val
      when :side_size_2
        old_val = @settings[:side_sizes][1]
        @settings[:side_sizes][1] = value
        @settings[:target_indices].delete_if { |val| val == @settings[:user_index] }
        @settings[:target_indices].delete_if { |val| val.odd? && val >= value * 2 }
        @settings[:target_indices].push(1) if @settings[:target_indices].empty?
        @components[:editor_settings].get_control(:target_indices).value = @settings[:target_indices].join(",")
        refresh_editor_settings_options if value != old_val
      when :user_index
        @settings[:user_index] = value
        @settings[:target_indices].delete_if { |val| val == @settings[:user_index] }
        @settings[:target_indices].push(1) if @settings[:target_indices].empty?
        @components[:editor_settings].get_control(:target_indices).value = @settings[:target_indices].join(",")
      when :target_indices
        @settings[:target_indices] = value.split(",")
        @settings[:target_indices].map! { |val| val.to_i }
        @settings[:target_indices].sort!
        @settings[:target_indices].uniq!
        @settings[:target_indices].delete_if { |val| val == @settings[:user_index] }
        @settings[:target_indices].delete_if { |val| val.even? && val >= @settings[:side_sizes][0] * 2 }
        @settings[:target_indices].delete_if { |val| val.odd? && val >= @settings[:side_sizes][1] * 2 }
        @settings[:target_indices].push(1) if @settings[:target_indices].empty?
        @components[:editor_settings].get_control(:target_indices).value = @settings[:target_indices].join(",")
      else
        @settings[property] = value
      end
      save_settings
      refresh_component(:canvas)
    when :canvas
      case property
      when :particle_index
        @components[:particle_list].particle_index = value
        refresh
      when :x, :y
        particle = @anim[:particles][particle_index]
        prop = property
        new_cmds = AnimationEditor::ParticleDataHelper.add_command(particle, property, keyframe, value)
        if new_cmds
          particle[prop] = new_cmds
        else
          particle.delete(prop)
        end
        @components[:particle_list].change_particle_commands(particle_index)
        @components[:play_controls].duration = @components[:particle_list].duration
        refresh
      end
    when :play_controls
      case property
      when :play
        @ready_to_play = true
      end
    when :particle_list
      case property
      when :add_particle
        new_idx = particle_index + 1
        AnimationEditor::ParticleDataHelper.add_particle(@anim[:particles], new_idx)
        @components[:particle_list].add_particle(new_idx)
        @components[:particle_list].set_particles(@anim[:particles])
        @components[:particle_list].particle_index = new_idx
        @components[:particle_list].keyframe = -1
        refresh
      when :move_particle_up
        idx1 = particle_index
        idx2 = idx1 - 1
        AnimationEditor::ParticleDataHelper.swap_particles(@anim[:particles], idx1, idx2)
        @components[:particle_list].swap_particles(idx1, idx2)
        @components[:particle_list].set_particles(@anim[:particles])
        @components[:particle_list].particle_index = idx2
        refresh
      when :move_particle_down
        idx1 = particle_index
        idx2 = idx1 + 1
        AnimationEditor::ParticleDataHelper.swap_particles(@anim[:particles], idx1, idx2)
        @components[:particle_list].swap_particles(idx1, idx2)
        @components[:particle_list].set_particles(@anim[:particles])
        @components[:particle_list].particle_index = idx2
        refresh
      when :cycle_interpolation
        # value is [particle index, property, keyframe]
        # Get current interpolation type
        interp_type = nil
        @anim[:particles][value[0]][value[1]].each do |cmd|
          next if cmd[0] != value[2]
          interp_type = cmd[3] if !interp_type
        end
        interp_type ||= :none
        # Get the interpolation type to change to
        interps = GameData::Animation::INTERPOLATION_TYPES.values
        idx = (interps.index(interp_type) + 1) % interps.length
        interp_type = interps[idx]
        # Set the new interpolation type
        AnimationEditor::ParticleDataHelper.set_interpolation(@anim[:particles][value[0]], value[1], value[2], interp_type)
        @components[:particle_list].change_particle_commands(value[0])
        refresh_component(:commands_pane)
        refresh_component(:canvas)
      end
    when :animation_properties
      case property
      when :type, :opp_variant
        type = @components[component_sym].get_control(:type).value
        opp = @components[component_sym].get_control(:opp_variant).value
        case type
        when :move
          @anim[:type] = (opp) ? :opp_move : :move
        when :common
          @anim[:type] = (opp) ? :opp_common : :common
        end
        refresh_component(component_sym)
        refresh_component(:canvas)
      when :pbs_path
        txt = value.gsub!(/\.txt$/, "")
        @anim[property] = txt
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
          @components[:particle_list].delete_particle(user_idx)
        elsif @anim[:particles].none? { |particle| particle[:name] == "User" }
          @anim[:particles].insert(0, {
            :name => "User", :focus => :user, :graphic => "USER"
          })
          @components[:particle_list].add_particle(0)
        end
        @components[:particle_list].set_particles(@anim[:particles])
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
          @components[:particle_list].delete_particle(target_idx)
        elsif @anim[:particles].none? { |particle| particle[:name] == "Target" }
          @anim[:particles].insert(0, {
            :name => "Target", :focus => :target, :graphic => "TARGET"
          })
          @components[:particle_list].add_particle(0)
        end
        @components[:particle_list].set_particles(@anim[:particles])
        refresh
      when :usable
        @anim[:ignore] = !value
      else
        @anim[property] = value
      end
    else
      # Side panes
      if AnimationEditor::SidePanes.is_side_pane?(component_sym)
        if [:commands_pane, :color_tone_pane].include?(component_sym) &&
           [:general_tab, :color_tone_tab].include?(property)
          @property_pane = {
            :general_tab    => :commands_pane,
            :color_tone_tab => :color_tone_pane
          }[property]
          refresh_component(component_sym)
          refresh_component(@property_pane)
        else
          hash = AnimationEditor::SidePanes.get_property(component_sym, property)
          if hash && hash[:apply_value]
            hash[:apply_value].call(value, self)
          else
            hash = AnimationEditor::SidePanes.get_pane(component_sym)
            if hash && hash[:apply_value]
              hash[:apply_value].call(property, value, self)
            end
          end
        end
      end
    end
  end

  def update_input
    if Input.triggerex?(:S)
      # Swap battler sides
      @settings[:user_opposes] = !@settings[:user_opposes]
      refresh
    elsif Input.triggerex?(:SPACE)
      # Play animation
      @ready_to_play = true
    elsif Input.triggerex?(:INSERT)
      # Insert empty keyframe for selected particle or all particles
      this_frame = keyframe
      if this_frame >= 0 && this_frame < @components[:particle_list].duration
        if Input.pressex?(:LSHIFT) || Input.pressex?(:RSHIFT)
          @anim[:particles].each do |particle|
            AnimationEditor::ParticleDataHelper.insert_frame(particle, this_frame)
          end
        else
          AnimationEditor::ParticleDataHelper.insert_frame(@anim[:particles][particle_index], this_frame)
        end
        @components[:particle_list].set_particles(@anim[:particles])
        refresh
      end
    elsif Input.triggerex?(:DELETE)
      # Delete keyframe for selected particle or all particles
      this_frame = keyframe
      if this_frame >= 0 && this_frame < @components[:particle_list].duration
        if Input.pressex?(:LSHIFT) || Input.pressex?(:RSHIFT)
          @anim[:particles].each do |particle|
            AnimationEditor::ParticleDataHelper.remove_frame(particle, this_frame)
          end
        else
          AnimationEditor::ParticleDataHelper.remove_frame(@anim[:particles][particle_index], this_frame)
        end
        @components[:particle_list].set_particles(@anim[:particles])
        refresh
      end
    end
  end

  def update
    old_keyframe = keyframe
    old_particle_index = particle_index
    @components.each_pair do |sym, component|
      next if @captured && @captured != sym
      next if !component.visible
      component.update
      @captured = sym if component.busy?
      if component.changed?
        if sym == :particle_list
          refresh if keyframe != old_keyframe || particle_index != old_particle_index
        end
        if component.respond_to?("values")
          values = component.values
          if values
            values.each_pair do |property, value|
              apply_changed_value(sym, property, value)
            end
          end
        end
        component.clear_changed
      end
      component.repaint if [:particle_list, :menu_bar].include?(sym)
      if @captured
        @captured = nil if !component.busy?
        break
      end
    end
    update_input if !@captured
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
