#===============================================================================
#
#===============================================================================
class AnimationEditor
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
    when :x, :y, :r, :theta, :emit_x, :emit_y, :emit_r, :emit_theta, :angle
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
    else
      @anim[property] = value
    end
  end

  # TODO: If :emitter_type is changed from :none to an emitter type, and the
  #       ListedParticle for this particle needs to create new group rows for
  #       the emitter properties, those rows will not have their expand arrow
  #       until the particle properties pop-up window is closed.
  def apply_changed_particle_properties_value(property, value)
    idx_particle = (value.is_a?(Array)) ? value[0] : particle_index
    value = value[1] if value.is_a?(Array)
    case property
    when :graphic
      this_particle = @anim[:particles][idx_particle]
      new_file = choose_graphic_file(this_particle[:graphic])
      if this_particle[:graphic] != new_file
        this_particle[:graphic] = new_file
        # TODO: Ideally enable/disable the :frame row's control for this
        #       particle depending on whether the graphic is a spritesheet (i.e.
        #       isn't one of the below special names and is wide enough compared
        #       to its height), or hide/show that row entirely. Also
        #       this_particle.delete(:frame) if the graphic isn't a spritesheet.
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
end
