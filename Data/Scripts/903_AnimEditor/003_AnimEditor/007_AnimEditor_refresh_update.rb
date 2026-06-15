#===============================================================================
#
#===============================================================================
class AnimationEditor
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
    ctrls.get_control(:canvas_bg).value = @settings[:canvas_bg]
    # User and target sprite graphics
    files = get_all_files_in_folder("Graphics/Pokemon/Front", [".png", ".jpg", ".jpeg"])
    files.delete_if { |file| !GameData::Species.exists?(file[0]) }
    files.map! { |file| [file[0], file[0]] }
    ctrls.get_control(:user_sprite_name).options = files.to_h
    ctrls.get_control(:user_sprite_name).value = @settings[:user_sprite_name]
    ctrls.get_control(:target_sprite_name).options = files.to_h
    ctrls.get_control(:target_sprite_name).value = @settings[:target_sprite_name]
    # Default interpolation
    ctrls.get_control(:default_interpolation).value = @settings[:default_interpolation] || :linear
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
      :target_side_foreground            => _INTL("In front of target's side"),
      :target_side_background            => _INTL("Behind target's side")
    }
    if @anim[:no_user]
      GameData::Animation::FOCUS_TYPES_WITH_USER.each { |f| focus_values.delete(f) }
    end
    if @anim[:no_target]
      GameData::Animation::FOCUS_TYPES_WITH_TARGET.each { |f| focus_values.delete(f) }
    end
    ctrls.get_control(:focus).options = focus_values
    # "If on opposing side..." properties
    if GameData::Animation::FOCUS_TYPES_WITH_USER.include?(this_particle[:focus]) == GameData::Animation::FOCUS_TYPES_WITH_TARGET.include?(this_particle[:focus])
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
    # Angle override
    if GameData::Animation::FOCUS_TYPES_WITH_USER.include?(this_particle[:focus]) ||
       GameData::Animation::FOCUS_TYPES_WITH_TARGET.include?(this_particle[:focus])
      ctrls.get_control(:angle_override).enable
    else
      this_particle[:angle_override] = :none
      ctrls.get_control(:angle_override).disable
    end
    # Emitter quantity
    if (this_particle[:emitter_type] || :none) == :none
      ctrls.get_control(:emitter_rate).disable
      ctrls.get_control(:emitter_intensity).disable
    else
      ctrls.get_control(:emitter_rate).enable
      ctrls.get_control(:emitter_intensity).enable
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
      component.get_control(:side_size_1).value = @settings[:side_sizes][0]
      component.get_control(:side_size_2).value = @settings[:side_sizes][1]
      user_indices = { 0 => "0" }
      user_indices[2] = "2" if @settings[:side_sizes][0] >= 2
      user_indices[4] = "4" if @settings[:side_sizes][0] >= 3
      component.get_control(:user_index).options = user_indices
      component.get_control(:user_index).value = @settings[:user_index]
      component.get_control(:target_indices).value = @settings[:target_indices].join(",")
      component.get_control(:user_opposes).value = @settings[:user_opposes]
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
            # NOTE: Intentionally not adding @settings[:default_interpolation]
            #       here, because the inserted command will have the same value as
            #       the one before it and won't need interpolating anyway.
          else
            particle.delete(property)
          end
          refresh
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
    @components.each_pair do |sym, component|
      next if @captured && @captured != sym
      next if !component.visible
      component.update
      @captured = sym if component.busy?
      if component.changed?
        if component.respond_to?("changed_controls")
          changed_ctrls = component.changed_controls
          if changed_ctrls
            changed_ctrls.each_pair do |property, value|
              apply_changed_value(sym, property, value)
            end
          end
        end
        component.clear_changed
      end
      component.repaint if [:timeline, :menu_bar].include?(sym)
      if @captured
        @captured = nil if !component.busy?
        break
      end
    end
    update_input if !@captured
    refresh if keyframe != old_keyframe || particle_index != old_particle_index
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
