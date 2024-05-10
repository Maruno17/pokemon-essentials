#===============================================================================
#
#===============================================================================
module AnimationEditor::SidePanes
  @@panes = {}
  @@properties = {}

  def self.is_side_pane?(pane)
    return @@panes.keys.include?(pane)
  end

  def self.add_pane(symbol, hash)
    @@panes[symbol] = hash
  end

  def self.add_property(pane, symbol, hash)
    @@properties[pane] ||= {}
    @@properties[pane][symbol] = hash
  end

  def self.each_pane
    @@panes.each_pair { |pane, hash| yield pane, hash }
  end

  def self.each_property(pane)
    return if !@@properties[pane]
    @@properties[pane].each_pair do |property, hash|
      yield property, hash
    end
  end

  def self.get_pane(pane)
    return @@panes[pane]
  end

  def self.get_property(pane, property)
    return nil if !@@properties[pane] || !@@properties[pane][property]
    return @@properties[pane][property]
  end

  def self.remove_pane(pane)
    @@panes.remove(pane)
    @@properties.remove(pane)
  end

  def self.remove_property(pane, property)
    @@properties[pane]&.remove(property)
  end
end

#===============================================================================
#
#===============================================================================
AnimationEditor::SidePanes.add_pane(:commands_pane, {
  :deletable_properties => AnimationEditor::DELETABLE_COMMAND_PANE_PROPERTIES,
  :set_visible => proc { |editor, anim, keyframe, particle_index|
    next keyframe >= 0 && particle_index >= 0 &&
         anim[:particles][particle_index] &&
         anim[:particles][particle_index][:name] != "SE" &&
         editor.property_pane == :commands_pane
  },
  :apply_value => proc { |property, value, editor|
    particle = editor.anim[:particles][editor.particle_index]
    prop = property
    if property.to_s[/_delete$/]
      prop = property.to_s.sub(/_delete$/, "").to_sym
      new_cmds = AnimationEditor::ParticleDataHelper.delete_command(particle, prop, editor.keyframe)
    else
      new_cmds = AnimationEditor::ParticleDataHelper.add_command(particle, property, editor.keyframe, value)
    end
    if new_cmds
      particle[prop] = new_cmds
    else
      particle.delete(prop)
    end
    editor.components[:particle_list].change_particle_commands(editor.particle_index)
    editor.components[:play_controls].duration = editor.components[:particle_list].duration
    editor.refresh_component(:commands_pane)
    editor.refresh_component(:canvas)
  }
})

AnimationEditor::SidePanes.add_pane(:color_tone_pane, {
  :deletable_properties => AnimationEditor::DELETABLE_COLOR_TONE_PANE_PROPERTIES,
  :set_visible => proc { |editor, anim, keyframe, particle_index|
    next keyframe >= 0 && particle_index >= 0 &&
         anim[:particles][particle_index] &&
         anim[:particles][particle_index][:name] != "SE" &&
         editor.property_pane == :color_tone_pane
  },
  :apply_value => proc { |property, value, editor|
    particle = editor.anim[:particles][editor.particle_index]
    prop = property
    if property.to_s[/_delete$/]
      prop = property.to_s.sub(/_delete$/, "").to_sym
      new_cmds = AnimationEditor::ParticleDataHelper.delete_command(particle, prop, editor.keyframe)
    else
      new_cmds = AnimationEditor::ParticleDataHelper.add_command(particle, property, editor.keyframe, value)
    end
    if new_cmds
      particle[prop] = new_cmds
    else
      particle.delete(prop)
    end
    editor.components[:particle_list].change_particle_commands(editor.particle_index)
    editor.components[:play_controls].duration = editor.components[:particle_list].duration
    editor.refresh_component(:color_tone_pane)
    editor.refresh_component(:canvas)
  }
})

# NOTE: Doesn't need an :apply_value proc.
AnimationEditor::SidePanes.add_pane(:se_pane, {
  :set_visible => proc { |editor, anim, keyframe, particle_index|
    next keyframe >= 0 && particle_index >= 0 &&
         anim[:particles][particle_index] &&
         anim[:particles][particle_index][:name] == "SE"
  }
})

AnimationEditor::SidePanes.add_pane(:particle_pane, {
  :unchanging_properties => true,
  :set_visible => proc { |editor, anim, keyframe, particle_index|
    next keyframe < 0 && particle_index >= 0
  },
  :apply_value => proc { |property, value, editor|
    particle = editor.anim[:particles][editor.particle_index]
    new_cmds = AnimationEditor::ParticleDataHelper.set_property(particle, property, value)
    editor.components[:particle_list].change_particle(editor.particle_index)
    editor.refresh_component(:particle_pane)
    editor.refresh_component(:canvas)
  }
})

#===============================================================================
#
#===============================================================================
AnimationEditor::SidePanes.add_property(:commands_pane, :header, {
  :new => proc { |pane, editor|
    pane.add_header_label(:header, _INTL("Edit particle at keyframe"))
  }
})

AnimationEditor::SidePanes.add_property(:commands_pane, :tab_buttons, {
  :new => proc { |pane, editor|
    editor.add_side_pane_tab_buttons(:commands_pane, pane)
  }
})

AnimationEditor::SidePanes.add_property(:commands_pane, :x, {
  :new => proc { |pane, editor|
    pane.add_labelled_number_text_box(:x, _INTL("X"), -999, 999, 0)
  }
})

AnimationEditor::SidePanes.add_property(:commands_pane, :y, {
  :new => proc { |pane, editor|
    pane.add_labelled_number_text_box(:y, _INTL("Y"), -999, 999, 0)
  }
})

AnimationEditor::SidePanes.add_property(:commands_pane, :z, {
  :new => proc { |pane, editor|
    pane.add_labelled_number_slider(:z, _INTL("Priority"), -50, 50, 0)
  },
  :refresh_value => proc { |control, editor|
    # Set an appropriate range for the priority (z) property depending on the
    # particle's focus
    case editor.anim[:particles][editor.particle_index][:focus]
    when :user_and_target
      control.min_value = GameData::Animation::USER_AND_TARGET_SEPARATION[2] - 50
      control.max_value = 50
    else
      control.min_value = -50
      control.max_value = 50
    end
  }
})

AnimationEditor::SidePanes.add_property(:commands_pane, :frame, {
  :new => proc { |pane, editor|
    pane.add_labelled_number_text_box(:frame, _INTL("Frame"), 0, 99, 0)
  },
  :refresh_value => proc { |control, editor|
    # Disable the "Frame" control if the particle's graphic is predefined to be
    # the user's or target's sprite
    graphic = editor.anim[:particles][editor.particle_index][:graphic]
    if ["USER", "USER_OPP", "USER_FRONT", "USER_BACK",
        "TARGET", "TARGET_OPP", "TARGET_FRONT", "TARGET_BACK"].include?(graphic)
      control.disable
    else
      control.enable
    end
  }
})

AnimationEditor::SidePanes.add_property(:commands_pane, :visible, {
  :new => proc { |pane, editor|
    pane.add_labelled_checkbox(:visible, _INTL("Visible"), true)
  }
})

AnimationEditor::SidePanes.add_property(:commands_pane, :opacity, {
  :new => proc { |pane, editor|
    pane.add_labelled_number_slider(:opacity, _INTL("Opacity"), 0, 255, 255)
  }
})

AnimationEditor::SidePanes.add_property(:commands_pane, :zoom_x, {
  :new => proc { |pane, editor|
    pane.add_labelled_number_text_box(:zoom_x, _INTL("Zoom X"), 0, 1000, 100)
  }
})

AnimationEditor::SidePanes.add_property(:commands_pane, :zoom_y, {
  :new => proc { |pane, editor|
    pane.add_labelled_number_text_box(:zoom_y, _INTL("Zoom Y"), 0, 1000, 100)
  }
})

AnimationEditor::SidePanes.add_property(:commands_pane, :angle, {
  :new => proc { |pane, editor|
    pane.add_labelled_number_text_box(:angle, _INTL("Angle"), -1080, 1080, 0)
  }
})

AnimationEditor::SidePanes.add_property(:commands_pane, :flip, {
  :new => proc { |pane, editor|
    pane.add_labelled_checkbox(:flip, _INTL("Flip"), false)
  }
})

AnimationEditor::SidePanes.add_property(:commands_pane, :blending, {
  :new => proc { |pane, editor|
    pane.add_labelled_dropdown_list(:blending, _INTL("Blending"), {
      0 => _INTL("None"),
      1 => _INTL("Additive"),
      2 => _INTL("Subtractive")
    }, 0)
  }
})

#===============================================================================
#
#===============================================================================
AnimationEditor::SidePanes.add_property(:color_tone_pane, :header, {
  :new => proc { |pane, editor|
    pane.add_header_label(:header, _INTL("Edit particle at keyframe"))
  }
})

AnimationEditor::SidePanes.add_property(:color_tone_pane, :tab_buttons, {
  :new => proc { |pane, editor|
    editor.add_side_pane_tab_buttons(:color_tone_pane, pane)
  }
})

AnimationEditor::SidePanes.add_property(:color_tone_pane, :color_red, {
  :new => proc { |pane, editor|
    pane.add_labelled_number_slider(:color_red, _INTL("Color Red"), 0, 255, 0)
  }
})

AnimationEditor::SidePanes.add_property(:color_tone_pane, :color_green, {
  :new => proc { |pane, editor|
    pane.add_labelled_number_slider(:color_green, _INTL("Color Green"), 0, 255, 0)
  }
})

AnimationEditor::SidePanes.add_property(:color_tone_pane, :color_blue, {
  :new => proc { |pane, editor|
    pane.add_labelled_number_slider(:color_blue, _INTL("Color Blue"), 0, 255, 0)
  }
})

AnimationEditor::SidePanes.add_property(:color_tone_pane, :color_alpha, {
  :new => proc { |pane, editor|
    pane.add_labelled_number_slider(:color_alpha, _INTL("Color Alpha"), 0, 255, 0)
  }
})

AnimationEditor::SidePanes.add_property(:color_tone_pane, :tone_red, {
  :new => proc { |pane, editor|
    pane.add_labelled_number_slider(:tone_red, _INTL("Tone Red"), -255, 255, 0)
  }
})

AnimationEditor::SidePanes.add_property(:color_tone_pane, :tone_green, {
  :new => proc { |pane, editor|
    pane.add_labelled_number_slider(:tone_green, _INTL("Tone Green"), -255, 255, 0)
  }
})

AnimationEditor::SidePanes.add_property(:color_tone_pane, :tone_blue, {
  :new => proc { |pane, editor|
    pane.add_labelled_number_slider(:tone_blue, _INTL("Tone Blue"), -255, 255, 0)
  }
})

AnimationEditor::SidePanes.add_property(:color_tone_pane, :tone_gray, {
  :new => proc { |pane, editor|
    pane.add_labelled_number_slider(:tone_gray, _INTL("Tone Gray"), 0, 255, 0)
  }
})

#===============================================================================
#
#===============================================================================
AnimationEditor::SidePanes.add_property(:se_pane, :header, {
  :new => proc { |pane, editor|
    pane.add_header_label(:header, _INTL("Edit sound effects at keyframe"))
  }
})

AnimationEditor::SidePanes.add_property(:se_pane, :list, {
  :new => proc { |pane, editor|
    size = pane.control_size
    size[0] -= 6
    size[1] = (UIControls::List::ROW_HEIGHT * 5) + (UIControls::List::BORDER_THICKNESS * 2)   # 5 rows
    list = UIControls::List.new(*size, pane.viewport, [])
    pane.add_control_at(:list, list, 3, 28)
  },
  :refresh_value => proc { |control, editor|
    se_particle = editor.anim[:particles].select { |particle| particle[:name] == "SE" }[0]
    keyframe = editor.keyframe
    # Populate list of files
    list = []
    se_particle.each_pair do |property, values|
      next if !values.is_a?(Array)
      values.each do |val|
        next if val[0] != keyframe
        text = AnimationEditor::ParticleDataHelper.get_se_display_text(property, val)
        case property
        when :user_cry   then list.push(["USER", text])
        when :target_cry then list.push(["TARGET", text])
        when :se         then list.push([val[2], text])
        end
      end
    end
    list.sort! { |a, b| a[1].downcase <=> b[1].downcase }
    control.values = list
  },
  :apply_value => proc { |value, editor|
    editor.refresh_component(:se_pane)
  }
})

AnimationEditor::SidePanes.add_property(:se_pane, :add, {
  :new => proc { |pane, editor|
    button_height = UIControls::ControlsContainer::LINE_SPACING
    button = UIControls::Button.new(101, button_height, pane.viewport, _INTL("Add"))
    button.set_fixed_size
    pane.add_control_at(:add, button, 1, 154)
  },
  :apply_value => proc { |value, editor|
    new_file, new_volume, new_pitch = editor.choose_audio_file("", 100, 100)
    if new_file != ""
      particle = editor.anim[:particles][editor.particle_index]
      AnimationEditor::ParticleDataHelper.add_se_command(particle, editor.keyframe, new_file, new_volume, new_pitch)
      editor.components[:particle_list].change_particle_commands(editor.particle_index)
      editor.components[:play_controls].duration = editor.components[:particle_list].duration
      editor.refresh_component(:se_pane)
    end
  }
})

AnimationEditor::SidePanes.add_property(:se_pane, :edit, {
  :new => proc { |pane, editor|
    button_height = UIControls::ControlsContainer::LINE_SPACING
    button = UIControls::Button.new(100, button_height, pane.viewport, _INTL("Edit"))
    button.set_fixed_size
    pane.add_control_at(:edit, button, 102, 154)
  },
  :refresh_value => proc { |control, editor|
    has_se = AnimationEditor::ParticleDataHelper.has_se_command_at?(editor.anim[:particles], editor.keyframe)
    list = editor.components[:se_pane].get_control(:list)
    if has_se && list.value
      control.enable
    else
      control.disable
    end
  },
  :apply_value => proc { |value, editor|
    particle = editor.anim[:particles][editor.particle_index]
    list = editor.components[:se_pane].get_control(:list)
    old_file = list.value
    old_volume, old_pitch = AnimationEditor::ParticleDataHelper.get_se_values_from_filename_and_frame(particle, editor.keyframe, old_file)
    if old_file
      new_file, new_volume, new_pitch = editor.choose_audio_file(old_file, old_volume, old_pitch)
      if new_file != old_file || new_volume != old_volume || new_pitch != old_pitch
        AnimationEditor::ParticleDataHelper.delete_se_command(particle, editor.keyframe, old_file)
        AnimationEditor::ParticleDataHelper.add_se_command(particle, editor.keyframe, new_file, new_volume, new_pitch)
        editor.components[:particle_list].change_particle_commands(editor.particle_index)
        editor.components[:play_controls].duration = editor.components[:particle_list].duration
        editor.refresh_component(:se_pane)
      end
    end
  }
})

AnimationEditor::SidePanes.add_property(:se_pane, :delete, {
  :new => proc { |pane, editor|
    button_height = UIControls::ControlsContainer::LINE_SPACING
    button = UIControls::Button.new(101, button_height, pane.viewport, _INTL("Delete"))
    button.set_fixed_size
    pane.add_control_at(:delete, button, 202, 154)
  },
  :refresh_value => proc { |control, editor|
    has_se = AnimationEditor::ParticleDataHelper.has_se_command_at?(editor.anim[:particles], editor.keyframe)
    list = editor.components[:se_pane].get_control(:list)
    if has_se && list.value
      control.enable
    else
      control.disable
    end
  },
  :apply_value => proc { |value, editor|
    particle = editor.anim[:particles][editor.particle_index]
    list = editor.components[:se_pane].get_control(:list)
    old_file = list.value
    if old_file
      AnimationEditor::ParticleDataHelper.delete_se_command(particle, editor.keyframe, old_file)
      editor.components[:particle_list].change_particle_commands(editor.particle_index)
      editor.components[:play_controls].duration = editor.components[:particle_list].duration
      editor.refresh_component(:se_pane)
    end
  }
})

#===============================================================================
#
#===============================================================================
AnimationEditor::SidePanes.add_property(:particle_pane, :header, {
  :new => proc { |pane, editor|
    pane.add_header_label(:header, _INTL("Edit particle properties"))
  }
})

AnimationEditor::SidePanes.add_property(:particle_pane, :name, {
  :new => proc { |pane, editor|
    pane.add_labelled_text_box(:name, _INTL("Name"), "")
    pane.get_control(:name).set_blacklist("", "User", "Target", "SE")
  }
})

AnimationEditor::SidePanes.add_property(:particle_pane, :graphic_name, {
  :new => proc { |pane, editor|
    pane.add_labelled_label(:graphic_name, _INTL("Graphic"), "")
  },
  :refresh_value => proc { |control, editor|
    graphic_name = editor.anim[:particles][editor.particle_index][:graphic]
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
    graphic_name = graphic_override_names[graphic_name] if graphic_override_names[graphic_name]
    control.text = graphic_name
  }
})

AnimationEditor::SidePanes.add_property(:particle_pane, :graphic, {
  :new => proc { |pane, editor|
    pane.add_labelled_button(:graphic, "", _INTL("Change"))
  },
  :refresh_value => proc { |control, editor|
    if ["User", "Target"].include?(editor.anim[:particles][editor.particle_index][:name])
      control.disable
    else
      control.enable
    end
  },
  :apply_value => proc { |value, editor|
    p_index = editor.particle_index
    new_file = editor.choose_graphic_file(editor.anim[:particles][p_index][:graphic])
    if editor.anim[:particles][p_index][:graphic] != new_file
      editor.anim[:particles][p_index][:graphic] = new_file
      if ["USER", "USER_BACK", "USER_FRONT", "USER_OPP",
          "TARGET", "TARGET_FRONT", "TARGET_BACK", "TARGET_OPP"].include?(new_file)
        editor.anim[:particles][p_index].delete(:frame)
        editor.components[:particle_list].set_particles(editor.anim[:particles])
        editor.refresh_component(:particle_list)
      end
      editor.refresh_component(:particle_pane)
      editor.refresh_component(:canvas)
    end
  }
})

AnimationEditor::SidePanes.add_property(:particle_pane, :focus, {
  :new => proc { |pane, editor|
    pane.add_labelled_dropdown_list(:focus, _INTL("Focus"), {}, :undefined)
  },
  :refresh_value => proc { |control, editor|
    if ["User", "Target"].include?(editor.anim[:particles][editor.particle_index][:name])
      control.disable
    else
      control.enable
    end
    focus_values = {
      :foreground             => _INTL("Foreground"),
      :midground              => _INTL("Midground"),
      :background             => _INTL("Background"),
      :user                   => _INTL("User"),
      :target                 => _INTL("Target"),
      :user_and_target        => _INTL("User and target"),
      :user_side_foreground   => _INTL("In front of user's side"),
      :user_side_background   => _INTL("Behind user's side"),
      :target_side_foreground => _INTL("In front of target's side"),
      :target_side_background => _INTL("Behind target's side")
    }
    if editor.anim[:no_user]
      GameData::Animation::FOCUS_TYPES_WITH_USER.each { |f| focus_values.delete(f) }
    end
    if editor.anim[:no_target]
      GameData::Animation::FOCUS_TYPES_WITH_TARGET.each { |f| focus_values.delete(f) }
    end
    control.values = focus_values
  }
})

AnimationEditor::SidePanes.add_property(:particle_pane, :random_frame_max, {
  :new => proc { |pane, editor|
    pane.add_labelled_number_text_box(:random_frame_max, _INTL("Rand. frame"), 0, 99, 0)
  }
})

AnimationEditor::SidePanes.add_property(:particle_pane, :spawner, {
  :new => proc { |pane, editor|
    values = {
      :none                        => _INTL("None"),
      :random_direction            => _INTL("Random direction"),
      :random_direction_gravity    => _INTL("Random dir. with gravity"),
      :random_up_direction_gravity => _INTL("Random up dir. gravity")
    }
    pane.add_labelled_dropdown_list(:spawner, _INTL("Spawner"), values, :none)
  }
})

AnimationEditor::SidePanes.add_property(:particle_pane, :spawn_quantity, {
  :new => proc { |pane, editor|
    pane.add_labelled_number_text_box(:spawn_quantity, _INTL("Spawn qty"), 1, 99, 1)
  },
  :refresh_value => proc { |control, editor|
    spawner = editor.anim[:particles][editor.particle_index][:spawner]
    if !spawner || spawner == :none
      control.disable
    else
      control.enable
    end
  },
  :apply_value => proc { |value, editor|
    AnimationEditor::SidePanes.get_pane(:particle_pane)[:apply_value].call(:spawn_quantity, value, editor)
    editor.components[:particle_list].change_particle_commands(editor.particle_index)
    editor.components[:play_controls].duration = editor.components[:particle_list].duration
    editor.refresh
  }
})

AnimationEditor::SidePanes.add_property(:particle_pane, :angle_override, {
  :new => proc { |pane, editor|
    values = {
      :none                   => _INTL("None"),
      :initial_angle_to_focus => _INTL("Initial angle to focus"),
      :always_point_at_focus  => _INTL("Always point at focus")
    }
    pane.add_labelled_dropdown_list(:angle_override, _INTL("Smart angle"), values, :none)
  },
  :refresh_value => proc { |control, editor|
    focus = editor.anim[:particles][editor.particle_index][:focus]
    if !GameData::Animation::FOCUS_TYPES_WITH_USER.include?(focus) &&
       !GameData::Animation::FOCUS_TYPES_WITH_TARGET.include?(focus)
      editor.anim[:particles][editor.particle_index][:angle_override] = :none
      control.value = :none
      control.disable
    else
      control.enable
    end
  }
})

AnimationEditor::SidePanes.add_property(:particle_pane, :opposing_label, {
  :new => proc { |pane, editor|
    pane.add_label(:opposing_label, _INTL("If on opposing side..."))
  }
})

AnimationEditor::SidePanes.add_property(:particle_pane, :foe_invert_x, {
  :new => proc { |pane, editor|
    pane.add_labelled_checkbox(:foe_invert_x, _INTL("Invert X"), false)
  },
  :refresh_value => proc { |control, editor|
    focus = editor.anim[:particles][editor.particle_index][:focus]
    if GameData::Animation::FOCUS_TYPES_WITH_USER.include?(focus) == GameData::Animation::FOCUS_TYPES_WITH_TARGET.include?(focus)
      control.disable
    else
      control.enable
    end
  }
})

AnimationEditor::SidePanes.add_property(:particle_pane, :foe_invert_y, {
  :new => proc { |pane, editor|
    pane.add_labelled_checkbox(:foe_invert_y, _INTL("Invert Y"), false)
  },
  :refresh_value => proc { |control, editor|
    focus = editor.anim[:particles][editor.particle_index][:focus]
    if GameData::Animation::FOCUS_TYPES_WITH_USER.include?(focus) == GameData::Animation::FOCUS_TYPES_WITH_TARGET.include?(focus)
      control.disable
    else
      control.enable
    end
  }
})

AnimationEditor::SidePanes.add_property(:particle_pane, :foe_flip, {
  :new => proc { |pane, editor|
    pane.add_labelled_checkbox(:foe_flip, _INTL("Flip sprite"), false)
  },
  :refresh_value => proc { |control, editor|
    focus = editor.anim[:particles][editor.particle_index][:focus]
    if GameData::Animation::FOCUS_TYPES_WITH_USER.include?(focus) == GameData::Animation::FOCUS_TYPES_WITH_TARGET.include?(focus)
      control.disable
    else
      control.enable
    end
  }
})

AnimationEditor::SidePanes.add_property(:particle_pane, :duplicate, {
  :new => proc { |pane, editor|
    pane.add_button(:duplicate, _INTL("Duplicate this particle"))
  },
  :refresh_value => proc { |control, editor|
    if editor.anim[:particles][editor.particle_index][:name] == "SE"
      control.disable
    else
      control.enable
    end
  },
  :apply_value => proc { |value, editor|
    p_index = editor.particle_index
    AnimationEditor::ParticleDataHelper.duplicate_particle(editor.anim[:particles], p_index)
    editor.components[:particle_list].add_particle(p_index + 1)
    editor.components[:particle_list].set_particles(editor.anim[:particles])
    editor.components[:particle_list].particle_index = p_index + 1
    editor.refresh
  }
})

AnimationEditor::SidePanes.add_property(:particle_pane, :delete, {
  :new => proc { |pane, editor|
    pane.add_button(:delete, _INTL("Delete this particle"))
  },
  :refresh_value => proc { |control, editor|
    if ["User", "Target", "SE"].include?(editor.anim[:particles][editor.particle_index][:name])
      control.disable
    else
      control.enable
    end
  },
  :apply_value => proc { |value, editor|
    if editor.confirm_message(_INTL("Are you sure you want to delete this particle?"))
      p_index = editor.particle_index
      AnimationEditor::ParticleDataHelper.delete_particle(editor.anim[:particles], p_index)
      editor.components[:particle_list].delete_particle(p_index)
      editor.components[:particle_list].set_particles(editor.anim[:particles])
      p_index = editor.particle_index
      editor.components[:particle_list].keyframe = 0 if editor.anim[:particles][p_index][:name] == "SE"
      editor.refresh
    end
  }
})
