class AnimationEditor; end

#===============================================================================
#
#===============================================================================
module AnimationEditor::ParticleDataHelper
  module_function

  # Return value is [value, is_interpolating?].
  def get_keyframe_particle_value(particle, property, frame)
    if !GameData::Animation::PARTICLE_KEYFRAME_DEFAULT_VALUES.include?(property)
      raise _INTL("Couldn't get default value for property {1} for particle {2}.",
                  property, particle[:name])
    end
    ret = [GameData::Animation::PARTICLE_KEYFRAME_DEFAULT_VALUES[property], false]
    if particle[property]
      # NOTE: The commands are already in keyframe order, so we can just run
      #       through them in order, applying their changes until we reach
      #       frame.
      particle[property].each do |cmd|
        break if cmd[0] > frame   # Command is in the future; no more is needed
        break if cmd[0] == frame && cmd[1] > 0   # Start of a "MoveXYZ" command; won't have changed yet
        if cmd[0] + cmd[1] <= frame   # Command has finished; use its end value
          ret[0] = cmd[2]
          next
        end
        # In a "MoveXYZ" command; need to interpolate
        if [:color, :color2].include?(property)
          new_val = []
          4.times do |i|   # R, G, B, A
            start_val = ret[0][2 * i, 2].to_i(16)
            end_val = cmd[2][2 * i, 2].to_i(16)
            val = AnimationPlayer::Helper.interpolate(
              (cmd[3] || :linear), start_val, end_val, cmd[1], cmd[0], frame
            )
            new_val.push(sprintf("%02X", val))
          end
          ret[0] = new_val.join
        elsif [:tone, :tone2].include?(property)
          new_val = []
          4.times do |i|   # R, G, B, G
            start_val = ret[0][3 * i, 3].to_i(16)
            end_val = cmd[2][3 * i, 3].to_i(16)
            val = AnimationPlayer::Helper.interpolate(
              (cmd[3] || :linear), start_val, end_val, cmd[1], cmd[0], frame
            )
            new_val.push((val >= 0 ? "+" : "-") + sprintf("%02X", val.abs))
          end
          ret[0] = new_val.join
        else
          ret[0] = AnimationPlayer::Helper.interpolate(
            (cmd[3] || :linear), ret[0], cmd[2], cmd[1], cmd[0], frame
          )
        end
        ret[1] = true   # Interpolating
        break
      end
    end
    # NOTE: Particles are assumed to be not visible at the start of the
    #       animation, and automatically become visible when the particle has
    #       its first command. This does not apply to the "User" and "Target"
    #       particles, which start the animation visible.
    if property == :visible
      first_cmd = (["User", "Target"].include?(particle[:name])) ? 0 : -1
      first_visible_cmd = -1
      particle.each_pair do |prop, value|
        next if !value.is_a?(Array) || value.empty?
        first_cmd = value[0][0] if first_cmd < 0 || first_cmd > value[0][0]
        first_visible_cmd = value[0][0] if prop == :visible && (first_visible_cmd < 0 || first_visible_cmd > value[0][0])
      end
      ret[0] = true if first_cmd >= 0 && first_cmd <= frame &&
                       (first_visible_cmd < 0 || frame < first_visible_cmd)
    end
    return ret
  end

  def get_all_keyframe_particle_values(particle, frame)
    ret = {}
    GameData::Animation::PARTICLE_KEYFRAME_DEFAULT_VALUES.each_pair do |prop, default|
      ret[prop] = get_keyframe_particle_value(particle, prop, frame)
    end
    return ret
  end

  def get_all_particle_values(particle)
    ret = {}
    GameData::Animation::PARTICLE_DEFAULT_VALUES.each_pair do |prop, default|
      ret[prop] = particle[prop] || default
    end
    return ret
  end

  # Used to determine which keyframes the particle is visible in, which is
  # indicated in the timeline by a colored bar. 0=not visible, 1=visible,
  # 2=visible because of emitter delay.
  # NOTE: Particles are assumed to be not visible at the start of the
  #       animation, and automatically become visible when the particle has
  #       its first command. This does not apply to the "User" and "Target"
  #       particles, which start the animation visible. They do NOT become
  #       invisible automatically after their last command.
  def get_timeline_particle_visibilities(particle, duration, whitelist_properties = nil)
    if !GameData::Animation::PARTICLE_KEYFRAME_DEFAULT_VALUES.include?(:visible)
      raise _INTL("Couldn't get default value for property {1} for particle {2}.",
                  property, particle[:name])
    end
    value = GameData::Animation::PARTICLE_KEYFRAME_DEFAULT_VALUES[:visible] ? 1 : 0
    value = 1 if ["User", "Target", "SE"].include?(particle[:name])
    ret = []
    if (particle[:emitter_type] || :none) == :none || whitelist_properties
      if !["User", "Target", "SE"].include?(particle[:name])
        earliest = duration
        particle.each_pair do |prop, value|
          next if whitelist_properties && !whitelist_properties.include?(prop)
          next if !value.is_a?(Array) || value.empty?
          earliest = value[0][0] if value[0][0] < earliest
        end
        ret[earliest] = 1
      end
      if particle[:visible]
        particle[:visible].each { |cmd| ret[cmd[0]] = (cmd[2]) ? 1 : 0 }
      end
      duration.times do |i|
        value = ret[i] if !ret[i].nil?
        ret[i] = value
      end
    else   # Emitter
      earliest = duration
      if particle[:emitting]
        particle[:emitting].each { |cmd| ret[cmd[0]] = (cmd[2]) ? 1 : 0 }
      end
      particle_start = AnimationPlayer::Helper.get_first_command_frame(particle, AnimationPlayer::Emitter::PARTICLE_PROPERTIES)
      particle_end = AnimationPlayer::Helper.get_last_command_frame(particle, AnimationPlayer::Emitter::PARTICLE_PROPERTIES)
      particle_dur = particle_end - particle_start
      end_emit = -1
      duration.times do |i|
        end_emit = i if value == 1 && ret[i] == 0
        value = ret[i] if !ret[i].nil?
        if end_emit >= 0 && i < end_emit + particle_dur
          value = 2 if value == 0
        else
          value = 0 if value == 2
        end
        ret[i] = value
      end
    end
    return ret
  end

  #-----------------------------------------------------------------------------

  # Returns an array, whose indexes are keyframes, where the values in the array
  # are commands. A keyframe's value is either nil or an array:
  #   [+/- duration, interpolation type]
  # The duration can be 0 (SetXYZ) or non-0 (MoveXYZ). The duration's sign is
  # whether it makes the value higher or lower.
  def get_particle_property_commands_timeline(particle, property, commands)
    return nil if !commands || commands.empty?
    ret = []
    if particle[:name] == "SE"
      commands.each { |cmd| ret[cmd[0]] = [0, :none] }
      return ret
    end
    if !GameData::Animation::PARTICLE_KEYFRAME_DEFAULT_VALUES.include?(property)
      raise _INTL("No default value for property {1} in PARTICLE_KEYFRAME_DEFAULT_VALUES.", property)
    end
    val = GameData::Animation::PARTICLE_KEYFRAME_DEFAULT_VALUES[property]
    commands.each do |cmd|
      if cmd[1] > 0   # MoveXYZ
        dur = cmd[1]
        dur *= -1 if ![:color, :tone].include?(property) && cmd[2] < val
        ret[cmd[0]] = [dur, cmd[3] || :linear]
        ret[cmd[0] + cmd[1]] = [0, :none]
      else   # SetXYZ
        ret[cmd[0]] = [0, :none]
      end
      val = cmd[2]   # New actual value
    end
    return ret
  end

  #-----------------------------------------------------------------------------

  def set_property(particle, property, value)
    particle[property] = value
  end

  def has_command_at?(particle, property, frame)
    return particle[property]&.any? { |cmd| (cmd[0] == frame) || (cmd[0] + cmd[1] == frame) }
  end

  def has_se_command_at?(particles, frame)
    ret = false
    se_particle = particles.select { |particle| particle[:name] == "SE" }[0]
    if se_particle
      se_particle.each_pair do |property, values|
        next if !values.is_a?(Array) || values.empty?
        ret = values.any? { |value| value[0] == frame }
        break if ret
      end
    end
    return ret
  end

  def add_command(particle, property, frame, value)
    # Return a new set of commands if there isn't one
    if !particle[property] || particle[property].empty?
      return [[frame, 0, value]]
    end
    # Find all relevant commands
    set_now = nil
    move_ending_now = nil
    move_overlapping_now = nil
    particle[property].each do |cmd|
      if cmd[1] == 0
        set_now = cmd if cmd[0] == frame
      else
        move_ending_now = cmd if cmd[0] + cmd[1] == frame
        move_overlapping_now = cmd if cmd[0] < frame && cmd[0] + cmd[1] > frame
      end
    end
    new_command_needed = true
    # Replace existing command at frame if it has a duration of 0
    if set_now
      set_now[2] = value
      new_command_needed = false
    end
    # If a command has a duration >0 and ends at frame, replace its value
    if move_ending_now
      move_ending_now[2] = value
      new_command_needed = false
    end
    return particle[property] if !new_command_needed
    # Add a new command
    new_cmd = [frame, 0, value]
    particle[property].push(new_cmd)
    # If the new command interrupts an interpolation, split that interpolation
    if move_overlapping_now
      end_frame = move_overlapping_now[0] + move_overlapping_now[1]
      new_cmd[1] = end_frame - frame         # Duration
      new_cmd[2] = move_overlapping_now[2]   # Value
      new_cmd[3] = move_overlapping_now[3]   # Interpolation type
      move_overlapping_now[1] = frame - move_overlapping_now[0]   # Duration
      move_overlapping_now[2] = value                             # Value
    end
    # Sort and return the commands
    particle[property].sort! { |a, b| a[0] == b[0] ? a[1] == b[1] ? 0 : a[1] <=> b[1] : a[0] <=> b[0] }
    return particle[property]
  end

  # Cases:
  # * SetXYZ - delete it
  # * MoveXYZ start - turn into a SetXYZ at the end point
  # * MoveXYZ end - delete it (this may happen to remove the start diamond too)
  # * MoveXYZ end and start - merge both together (use first's type)
  # * SetXYZ and MoveXYZ start - delete SetXYZ (leave MoveXYZ alone)
  # * SetXYZ and MoveXYZ end - (unlikely) delete both
  # * SetXYZ and MoveXYZ start and end - (unlikely) delete SetXYZ, merge Moves together
  def delete_command(particle, property, frame, full_delete = false)
    return nil if !particle[property] || particle[property].empty?
    # Find all relevant commands
    set_now = nil
    move_ending_now = nil
    move_starting_now = nil
    set_at_end_of_move_starting_now = nil
    particle[property].each do |cmd|
      if cmd[1] == 0
        set_now = cmd if cmd[0] == frame
      else
        move_starting_now = cmd if cmd[0] == frame
        move_ending_now = cmd if cmd[0] + cmd[1] == frame
      end
    end
    if move_starting_now
      particle[property].each do |cmd|
        set_at_end_of_move_starting_now = cmd if cmd[1] == 0 && cmd[0] == move_starting_now[0] + move_starting_now[1]
      end
    end
    # Delete SetXYZ if it is at frame
    particle[property].delete(set_now) if set_now
    # Edit/delete MoveXYZ commands starting/ending at frame
    if move_ending_now && move_starting_now   # Merge both MoveXYZ commands
      move_ending_now[1] += move_starting_now[1]   # Duration
      move_ending_now[2] = move_starting_now[2]    # Value
      particle[property].delete(move_starting_now)
    elsif move_ending_now   # Delete MoveXYZ ending now
      particle[property].delete(move_ending_now)
    elsif move_starting_now && (full_delete || !set_now)   # Turn into SetXYZ at its end point
      if set_at_end_of_move_starting_now
        particle[property].delete(move_starting_now)
      else
        move_starting_now[0] += move_starting_now[1]
        move_starting_now[1] = 0
        move_starting_now[3] = nil
        move_starting_now.compact!
      end
    end
    return (particle[property].empty?) ? nil : particle[property]
  end

  # NOTE: This only allows movement of a command to a frame without a command
  #       that is between the two commands already surrounding it.
  def move_command(particle, property, src_frame, dst_frame)
    return particle[property] if particle[property].nil?
    # Find the commands that need changing
    cmd_prior = nil
    cmd_this_set = nil
    cmd_this_move = nil
    particle[property].each do |cmd|
      cmd_prior = cmd if cmd[1] > 0 && cmd[0] + cmd[1] == src_frame
      cmd_this_set = cmd if cmd[0] == src_frame && cmd[1] == 0
      cmd_this_move = cmd if cmd[0] == src_frame && cmd[1] > 0
    end
    # Change the commands
    cmd_prior[1] += dst_frame - src_frame if cmd_prior
    cmd_this_set[0] = dst_frame if cmd_this_set
    if cmd_this_move
      cmd_this_move[0] = dst_frame
      cmd_this_move[1] += src_frame - dst_frame
    end
    # NOTE: No need to sort the commands because they're still in chronological
    #       order.
    return particle[property]
  end

  # NOTE: This doesn't change the commands parameter, but instead returns a copy
  #       of it with the move applied.
  def move_command_in_commands_timeline(commands, src_frame, dst_frame)
    return nil if !commands
    ret = []
    cmd_prior_src = nil
    cmd_next_src = nil
    cmd_prior_dst = nil
    cmd_next_dst = nil
    commands.each_with_index do |cmd, i|
      next if !cmd
      ret[i] = cmd.clone
      next if i == src_frame
      cmd_prior_src = i if i < src_frame
      cmd_next_src = i if i > src_frame && cmd_next_src.nil?
      cmd_prior_dst = i if i < dst_frame
      cmd_next_dst = i if i > dst_frame && cmd_next_dst.nil?
    end
    return ret if src_frame == dst_frame
    # If command remains between the same two other commands, we want to
    # preserve both interpolations between them; otherwise, just delete the
    # command from src_frame and add it at dst_frame
    # TODO: If dst_frame == cmd_prior_src, should we make the entire region use
    #       src_frame's interpolation? Currently it uses cmd_prior_src's.
    if cmd_prior_src == cmd_prior_dst && cmd_next_src == cmd_next_dst
      # Move command
      ret[dst_frame] = ret[src_frame]
      ret[src_frame] = nil
      # Fix duration of interpolation coming into dst_frame
      if cmd_prior_src && ret[cmd_prior_src][1] != :none
        ret[cmd_prior_src][0] = (ret[cmd_prior_src][0] > 0) ? dst_frame - cmd_prior_src : cmd_prior_src - dst_frame
      end
      # Fix duration of interpolation coming out of dst_frame
      if ret[dst_frame][1] != :none
        ret[dst_frame][0] = (ret[dst_frame][0] > 0) ? cmd_next_src - dst_frame : dst_frame - cmd_next_src
      end
    else
      # Delete src_frame
      ret[src_frame] = nil
      # Fix duration of interpolation coming into src_frame
      if cmd_prior_src && ret[cmd_prior_src][1] != :none
        if cmd_next_src
          # TODO: This doesn't figure out whether the value becomes higher or
          #       lower over its new interpolation, so the line's slope may be
          #       inaccurate. I don't think it matters.
          ret[cmd_prior_src][0] = (ret[cmd_prior_src][0] > 0) ? cmd_next_src - cmd_prior_src : cmd_prior_src - cmd_next_src
        else
          # No command to interpolate to
          ret[cmd_prior_src] = [0, :none]
        end
      end
      # Add dst_frame
      if ret[dst_frame].nil?
        if cmd_prior_dst.nil? || ret[cmd_prior_dst][1] == :none
          # dst_frame isn't splitting an interpolation line
          ret[dst_frame] = [0, :none]
        else
          # dst_frame is splitting an interpolation line
          ret[dst_frame] = [0, ret[cmd_prior_dst][1]]
          # Fix duration of interpolation coming into dst_frame
          # TODO: This doesn't figure out whether the value becomes higher or
          #       lower over its new interpolation, so the line's slope may be
          #       inaccurate. I don't think it matters.
          ret[cmd_prior_dst][0] = (ret[cmd_prior_dst][0] > 0) ? dst_frame - cmd_prior_dst : cmd_prior_dst - dst_frame
          # Fix duration of interpolation coming out of dst_frame
          if cmd_next_dst
            # TODO: This doesn't figure out whether the value becomes higher or
            #       lower over its new interpolation, so the line's slope may be
            #       inaccurate. I don't think it matters.
            ret[dst_frame][0] = (ret[cmd_prior_dst][0] > 0) ? cmd_next_dst - dst_frame : dst_frame - cmd_next_dst
          end
        end
      end
    end
    return ret
  end

  def optimize_all_particles(particles)
    particles.each do |particle|
      next if particle[:name] == "SE"
      particle.each_pair do |key, cmds|
        next if !cmds.is_a?(Array) || cmds.empty?
        particle[key] = optimize_commands(particle, key)
      end
    end
  end

  # Removes commands for the particle's given property if they don't make a
  # difference. Returns the resulting set of commands.
  def optimize_commands(particle, property)
    # Split particle[property] into values and interpolation arrays
    set_points = []   # All SetXYZ commands (the values thereof)
    end_points = []   # End points of MoveXYZ commands (the values thereof)
    interps = []      # Interpolation type from a keyframe to the next point
    if particle && particle[property]
      particle[property].each do |cmd|
        if cmd[1] == 0   # SetXYZ
          set_points[cmd[0]] = cmd[2]
        else
          interps[cmd[0]] = cmd[3] || :linear
          end_points[cmd[0] + cmd[1]] = cmd[2]
        end
      end
    end
    # For visibility only, set the keyframe with the first command (of any kind)
    # to be visible, unless the command being added overwrites it. Also figure
    # out the first keyframe that has a command, and the first keyframe that has
    # a non-visibility command (used below).
    if property == :visible
      first_cmd = (["User", "Target", "SE"].include?(particle[:name])) ? 0 : -1
      first_non_visible_cmd = -1
      particle.each_pair do |prop, value|
        next if !value.is_a?(Array) || value.empty?
        first_cmd = value[0][0] if first_cmd < 0 || first_cmd > value[0][0]
        next if prop == :visible
        first_non_visible_cmd = value[0][0] if first_non_visible_cmd < 0 || first_non_visible_cmd > value[0][0]
      end
      set_points[first_cmd] = true if first_cmd >= 0 && set_points[first_cmd].nil?
    end
    # Convert points and interps back into particle[property]
    ret = []
    if !GameData::Animation::PARTICLE_KEYFRAME_DEFAULT_VALUES.include?(property)
      raise _INTL("Couldn't get default value for property {1}.", property)
    end
    val = GameData::Animation::PARTICLE_KEYFRAME_DEFAULT_VALUES[property]
    length = [set_points.length, end_points.length].max
    length.times do |i|
      if !set_points[i].nil?
        if property == :visible && first_cmd >= 0 && i == first_cmd &&
           first_non_visible_cmd >= 0 && i == first_non_visible_cmd
          ret.push([i, 0, set_points[i]]) if !set_points[i]
        elsif set_points[i] != val
          ret.push([i, 0, set_points[i]])
        end
        val = set_points[i]
      end
      if interps[i] && interps[i] != :none
        ((i + 1)..length).each do |j|
          next if set_points[j].nil? && end_points[j].nil?
          if set_points[j].nil?
            break if end_points[j] == val
            ret.push([i, j - i, end_points[j], interps[i]])
            val = end_points[j]
            end_points[j] = nil
          else
            break if set_points[j] == val
            ret.push([i, j - i, set_points[j], interps[i]])
            val = set_points[j]
            set_points[j] = nil
          end
          break
        end
      end
    end
    return (ret.empty?) ? nil : ret
  end

  # If SetXYZ at frame:
  #   - none: Do nothing.
  #   - interp: Add MoveXYZ (calc duration/value at end).
  # If MoveXYZ at frame:
  #   - none: Turn into two SetXYZ (MoveXYZ's value for end point, calc value
  #           for start point).
  #   - interp: Change type.
  # If SetXYZ and MoveXYZ at frame:
  #   - none: Turn MoveXYZ into SetXYZ at the end point.
  #   - interp: Change MoveXYZ's type.
  # If end of earlier MoveXYZ (or nothing) at frame:
  #   - none: Do nothing.
  #   - interp: Add MoveXYZ (calc duration/value at end).
  def set_interpolation(particle, property, frame, type)
    # Ensure frame has a command (or the end of a MoveXYZ command) to
    # interpolate from
    orig_frame = frame
    particle[property].each do |cmd|
      break if cmd[0] > orig_frame
      frame = cmd[0]
      frame = cmd[0] + cmd[1] if cmd[0] + cmd[1] <= orig_frame
    end
    # Find relevant command
    set_now = nil
    move_starting_now = nil
    particle[property].each do |cmd|
      next if cmd[0] != frame
      set_now = cmd if cmd[1] == 0
      move_starting_now = cmd if cmd[1] != 0
    end
    if move_starting_now
      # If a MoveXYZ command exists at frame, amend it
      if type == :none
        old_end_point = move_starting_now[0] + move_starting_now[1]
        old_value = move_starting_now[2]
        # Turn the MoveXYZ command into a SetXYZ at its end point (or just
        # delete it if a SetXYZ already exists at frame or if a MoveXYZ ends at
        # frame)
        if set_now
          particle[property].delete(move_starting_now)
        elsif particle[property].any? { |cmd| cmd[1] > 0 && cmd[0] + cmd[1] == frame }
          particle[property].delete(move_starting_now)
        else
          # Just for the sake of keeping a command diamond at frame
          move_starting_now[2] = get_keyframe_particle_value(particle, property, frame)[0]
          move_starting_now[1] = 0   # Intentionally after setting move_starting_now[2]
          move_starting_now[3] = nil
          move_starting_now.compact!
        end
        # Add a new SetXYZ at the end of the (former) interpolation
        add_command(particle, property, old_end_point, old_value)
      else
        # Simply change the type
        move_starting_now[3] = type
      end
    elsif type != :none
      # If no MoveXYZ command exists at frame, make one (if type isn't :none)
      particle[property].each_with_index do |cmd, i|   # Assumes commands are sorted by keyframe
        next if cmd[0] <= frame
        val_at_end = get_keyframe_particle_value(particle, property, cmd[0])[0]
        particle[property].push([frame, cmd[0] - frame, val_at_end, type])
        break if cmd[1] > 0
        particle[property][i] = nil
        particle[property].compact!
        break
      end
      particle[property].sort! { |a, b| a[0] == b[0] ? a[1] == b[1] ? 0 : a[1] <=> b[1] : a[0] <=> b[0] }
    end
    return particle[property]
  end

  #-----------------------------------------------------------------------------

  def get_all_particle_se_at_frame(particle, frame)
    raise _INTL("Querying SEs for a non-SE particle.") if particle[:name] != "SE"
    ret = []
    [:user_cry, :target_cry, :se].each do |id|
      next if !particle[id]
      particle[id].each { |data| ret.push([id] + data) if data[0] == frame }
    end
    return ret
  end

  # value is one of the array entries from the above method.
  def get_se_display_text(property, value)
    ret = ""
    case property
    when :user_cry
      ret += _INTL("[[User's cry]]")
    when :target_cry
      ret += _INTL("[[Target's cry]]")
    when :se
      ret += value[3]
    else
      raise _INTL("Unhandled property {1} for SE particle found.", property)
    end
    volume = (property == :se) ? value[4] : value[3]
    ret += " " + _INTL("(volume: {1})", volume) if volume && volume != 100
    pitch = (property == :se) ? value[5] : value[4]
    ret += " " + _INTL("(pitch: {1})", pitch) if pitch && pitch != 100
    return ret
  end

  # Deletes an existing command that plays the same filename at the same frame,
  # and adds the new one.
  def add_se_command(particle, frame, filename, volume, pitch)
    delete_se_command(particle, frame, filename)
    case filename
    when "USER", "TARGET"
      property = (filename == "USER") ? :user_cry : :target_cry
      particle[property] ||= []
      particle[property].push([frame, 0, (volume == 100) ? nil : volume, (pitch == 100) ? nil : pitch])
      particle[property].sort! { |a, b| a[0] <=> b[0] }
    else
      particle[:se] ||= []
      particle[:se].push([frame, 0, filename, (volume == 100) ? nil : volume, (pitch == 100) ? nil : pitch])
      particle[:se].sort! { |a, b| a[0] <=> b[0] }
      particle[:se].sort! { |a, b| (a[0] == b[0]) ? a[2].downcase <=> b[2].downcase : a[0] <=> b[0] }
    end
  end

  # Deletes an existing SE-playing command at the given frame of the given
  # filename.
  def delete_se_command(particle, frame, filename)
    case filename
    when "USER", "TARGET"
      property = (filename == "USER") ? :user_cry : :target_cry
      return if !particle[property] || particle[property].empty?
      particle[property].delete_if { |s| s[0] == frame }
      particle.delete(property) if particle[property].empty?
    else
      return if !particle[:se] || particle[:se].empty?
      particle[:se].delete_if { |s| s[0] == frame && s[2] == filename }
      particle.delete(:se) if particle[:se].empty?
    end
  end

  #-----------------------------------------------------------------------------

  # Inserts an empty frame at the given frame. Delays all commands at or after
  # the given frame by 1, and increases the duration of all commands that
  # overlap the given frame.
  def insert_frame(particle, frame, property = nil)
    particle.each_pair do |prop, values|
      next if !values.is_a?(Array) || values.empty?
      next if !property.nil? && prop != property
      values.each do |cmd|
        if cmd[0] >= frame
          cmd[0] += 1
        elsif cmd[0] < frame && cmd[0] + cmd[1] > frame
          cmd[1] += 1
        end
      end
    end
  end

  # Removes a frame at the given frame. Deletes all commands in that frame, then
  # brings all commands after the given frame earlier by 1, and reduces the
  # duration of all commands that overlap the given frame.
  def remove_frame(particle, frame, property = nil)
    particle.keys.each do |prop|
      next if !particle[prop].is_a?(Array) || particle[prop].empty?
      next if !property.nil? && prop != property
      delete_command(particle, prop, frame, true)
    end
    particle.delete_if { |_prop, values| values.is_a?(Array) && values.empty? }
    particle.each_pair do |prop, values|
      next if !values.is_a?(Array) || values.empty?
      next if !property.nil? && prop != property
      values.each do |cmd|
        if cmd[0] > frame
          cmd[0] -= 1
        elsif cmd[0] < frame && cmd[0] + cmd[1] > frame
          cmd[1] -= 1
        end
      end
    end
  end

  #-----------------------------------------------------------------------------

  # Creates a new particle and inserts it at index. If there is a particle above
  # the new one, the new particle will inherit its focus; otherwise it gets a
  # default focus of :foreground.
  def add_particle(particles, index)
    new_particle = GameData::Animation::PARTICLE_DEFAULT_VALUES.clone
    new_particle[:name] = _INTL("New particle")
    if index > 0 && index <= particles.length && particles[index - 1][:name] != "SE"
      new_particle[:focus] = particles[index - 1][:focus]
    end
    index = particles.length if index < 0
    particles.insert(index, new_particle)
  end

  # Copies the particle at index and inserts the copy immediately after that
  # index. This assumes the original particle can be copied, i.e. isn't "SE".
  def duplicate_particle(particles, index)
    new_particle = {}
    particles[index].each_pair do |key, value|
      if value.is_a?(Array)
        new_particle[key] = []
        value.each { |cmd| new_particle[key].push(cmd.clone) }
      else
        new_particle[key] = value.clone
      end
    end
    new_particle[:name] += " (copy)"
    particles.insert(index + 1, new_particle)
  end

  def swap_particles(particles, index1, index2)
    particles[index1], particles[index2] = particles[index2], particles[index1]
  end

  # Deletes the particle at the given index. This assumes the particle can be
  # deleted, i.e. isn't "User"/"Target"/"SE".
  def delete_particle(particles, index)
    particles[index] = nil
    particles.compact!
  end
end
