#===============================================================================
#
#===============================================================================
class AnimationEditor
  attr_reader :property_pane
  attr_reader :components
  attr_reader :anim

  BORDER_THICKNESS = 4
  WINDOW_WIDTH     = Settings::SCREEN_WIDTH + 352 + (BORDER_THICKNESS * 4)
  WINDOW_HEIGHT    = Settings::SCREEN_HEIGHT + 352 + (BORDER_THICKNESS * 4)

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
    "Attract", "BanefulBunker", "BeakBlast", "Bind", "Burn",
    "Clamp", "Confusion", "CraftyShield", "EatBerry", "ElectricTerrain",
    "FireSpin", "FocusPunch", "Frozen", "GrassyTerrain", "Hail",
    "HarshSun", "HealingWish", "HealthDown", "HealthUp", "HeavyRain",
    "Infestation", "KingsShield", "LeechSeed", "LevelUp", "LunarDance",
    "MagmaStorm", "MegaEvolution", "MegaEvolution2", "MistyTerrain", "Obstruct",
    "Octolock", "Paralysis", "ParentalBond", "Poison", "Powder",
    "PrimalGroudon", "PrimalGroudon2", "PrimalKyogre", "PrimalKyogre2", "Protect",
    "PsychicTerrain", "QuickGuard", "Rain", "Rainbow", "RainbowOpp",
    "Sandstorm", "SandTomb", "SeaOfFire", "SeaOfFireOpp", "Shadow",
    "ShadowSky", "ShellTrap", "Shiny", "Sleep", "SpikyShield",
    "StatDown", "StatUp", "StrongWinds", "Sun", "SuperShiny",
    "Swamp", "SwampOpp", "Toxic", "UseItem", "WideGuard",
    "Wrap"
  ]
  DELETABLE_COMMAND_PANE_PROPERTIES = [
    :x, :y, :z, :frame, :visible, :opacity, :zoom_x, :zoom_y, :angle, :flip, :blending
  ]
  DELETABLE_COLOR_TONE_PANE_PROPERTIES = [
    :color_red, :color_green, :color_blue, :color_alpha,
    :tone_red, :tone_green, :tone_blue, :tone_gray
  ]

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
      @delete_bitmap.fill_rect([i - 1, 1].max, i + 1, wid, 1, Color.red)
      @delete_bitmap.fill_rect([i - 1, 1].max, 14 - i, wid, 1, Color.red)
      @delete_disabled_bitmap.fill_rect([i - 1, 1].max, i + 1, wid, 1, Color.new(160, 160, 160))
      @delete_disabled_bitmap.fill_rect([i - 1, 1].max, 14 - i, wid, 1, Color.new(160, 160, 160))
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
    # TODO: Load these from a saved file.
    @settings = {
      :side_sizes         => [1, 1],
      :user_index         => 0,
      :target_indices     => [1],
      :user_opposes       => false,
      # TODO: Ideally be able to independently choose base graphics, which will
      #       be a separate setting here.
      :canvas_bg          => "indoor1",
      # NOTE: These sprite names are also used in Pokemon.play_cry and so should
      #       be a species ID (being a string is fine).
      :user_sprite_name   => "ARCANINE",
      :target_sprite_name => "CHARIZARD"
    }
  end

  def save
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
    @components[:menu_bar].add_name_button(:name, get_animation_display_name)
  end

  def set_canvas_contents
  end

  def add_side_pane_tab_buttons(component, pane)
    next_pos_x, next_pos_y = pane.next_control_position
    # TODO: Add masking tab and properties.
    [
      [:commands_pane, :general_tab, _INTL("General")],
      [:color_tone_pane, :color_tone_tab, _INTL("Color/Tone")],
#      [:masking_pane, :masking_tab, _INTL("Masking")]
    ].each_with_index do |tab, i|
      btn = UIControls::Button.new(100, 28, pane.viewport, tab[2])
      btn.set_fixed_size
      btn.disable if tab[0] == component
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
    move_ctrl.max_rows = 16
    anim_properties.add_labelled_number_text_box(:version, _INTL("Version"), 0, 99, 0)
    anim_properties.add_labelled_text_box(:name, _INTL("Name"), "")
    # TODO: Have two TextBoxes, one for folder and one for filename?
    anim_properties.add_labelled_text_box(:pbs_path, _INTL("PBS filepath"), "")
    anim_properties.add_labelled_checkbox(:has_user, _INTL("Involves a user?"), true)
    anim_properties.add_labelled_checkbox(:has_target, _INTL("Involves a target?"), true)
    # TODO: Flags control. Includes a List, TextBox and some add/delete Buttons.
    anim_properties.add_button(:close, _INTL("Close"))
    anim_properties.visible = false
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

  def refresh_component_visibility(component_sym)
    # Panes are all mutually exclusive
    side_pane = AnimationEditor::SidePanes.get_pane(component_sym)
    if side_pane && side_pane[:set_visible]
      @components[component_sym].visible = side_pane[:set_visible].call(self, @anim, keyframe, particle_index)
    end
  end

  def refresh_move_property_options
    ctrl = @components[:animation_properties].get_control(:move)
    case @anim[:type]
    when :move, :opp_move
      # TODO: Cache this list?
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
      if cur_index < 0 || cur_index >= @anim[:particles].length - 2
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
      # TODO: Maybe other things as well?
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
            # TODO: new_vals[ctrl[0]][1] is whether the value is being interpolated,
            #       which should be indicated somehow in ctrl[1].
          end
        end
        # Additional refreshing of controls
        AnimationEditor::SidePanes.each_property(component_sym) do |property, hash|
          next if !hash[:refresh_value]
          hash[:refresh_value].call(component.get_control(property), self)
        end
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
        # TODO: May need to refresh other things.
        refresh_component(:particle_list)
      end
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
      # TODO: Will the play controls ever signal themselves as changed? I don't
      #       think so.
    when :particle_list
      case property
      when :add_particle
        new_idx = particle_index
        if new_idx >= 0
          new_idx += 1
          new_idx = @anim[:particles].length - 1 if new_idx == 0 || new_idx >= @anim[:particles].length
        end
        AnimationEditor::ParticleDataHelper.add_particle(@anim[:particles], new_idx)
        @components[:particle_list].add_particle(new_idx)
        @components[:particle_list].set_particles(@anim[:particles])
        @components[:particle_list].particle_index = (new_idx >= 0) ? new_idx : @anim[:particles].length - 2
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
      # TODO: Will changes here need to refresh any other components (e.g. side
      #       panes)? Probably.
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
          @components[:particle_list].delete_particle(0)
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
          @components[:particle_list].delete_particle(@anim[:no_user] ? 0 : 1)
        elsif @anim[:particles].none? { |particle| particle[:name] == "Target" }
          @anim[:particles].insert((@anim[:no_user] ? 0 : 1), {
            :name => "Target", :focus => :target, :graphic => "TARGET"
          })
          @components[:particle_list].add_particle((@anim[:no_user] ? 0 : 1))
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
          # TODO: Make undo/redo snapshot.
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
  end

  #-----------------------------------------------------------------------------

  def run
    Input.text_input = false
    loop do
      Graphics.update
      Input.update
      update
      if @captured.nil? && @quit
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
