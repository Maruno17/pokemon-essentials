#===============================================================================
#
#===============================================================================
module AnimationEditor::ParticleDataHelper
  module_function

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
        ret[0] = AnimationPlayer::Helper.interpolate(
          (cmd[3] || :linear), ret[0], cmd[2], cmd[1], cmd[0], frame
        )
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
  # indicated in the timeline by a coloured bar. 0=not visible, 1=visible,
  # 2=visible because of spawner delay.
  # NOTE: Particles are assumed to be not visible at the start of the
  #       animation, and automatically become visible when the particle has
  #       its first command. This does not apply to the "User" and "Target"
  #       particles, which start the animation visible. They do NOT become
  #       invisible automatically after their last command.
  def get_timeline_particle_visibilities(particle, duration)
    if !GameData::Animation::PARTICLE_KEYFRAME_DEFAULT_VALUES.include?(:visible)
      raise _INTL("Couldn't get default value for property {1} for particle {2}.",
                  property, particle[:name])
    end
    value = GameData::Animation::PARTICLE_KEYFRAME_DEFAULT_VALUES[:visible] ? 1 : 0
    value = 1 if ["User", "Target", "SE"].include?(particle[:name])
    ret = []
    if !["User", "Target", "SE"].include?(particle[:name])
      earliest = duration
      particle.each_pair do |prop, value|
        next if !value.is_a?(Array) || value.empty?
        earliest = value[0][0] if earliest > value[0][0]
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
    qty = particle[:spawn_quantity] || 1 if particle[:spawner] && particle[:spawner] != :none
    if (particle[:spawner] || :none) != :none
      qty = particle[:spawn_quantity] || 1
      delay = AnimationPlayer::Helper.get_particle_delay(particle, qty - 1)
      if delay > 0
        count = -1
        duration.times do |i|
          if ret[i] == 1   # Visible
            count = 0
          elsif ret[i] == 0 && count >= 0 && count < delay   # Not visible and within delay
            ret[i] = 2
            count += 1
          end
        end
      end
    end
    return ret
  end

  #-----------------------------------------------------------------------------

  # Returns an array indicating where command diamonds and duration lines should
  # be drawn in the AnimationEditor::ParticleList.
  def get_particle_commands_timeline(particle)
    ret = []
    durations = []
    particle.each_pair do |property, values|
      next if !values.is_a?(Array) || values.empty?
      values.each do |cmd|
        ret[cmd[0]] = true
        if cmd[1] > 0
          ret[cmd[0] + cmd[1]] = true
          durations.push([cmd[0], cmd[1]])
        end
      end
    end
    return ret, durations
  end

  # Returns an array, whose indexes are keyframes, where the values in the array
  # are commands. A keyframe's value can be one of these:
  #   0   - SetXYZ
  #   [+/- duration, interpolation type] --- MoveXYZ (duration's sign is whether
  #                                          it makes the value higher or lower)
  def get_particle_property_commands_timeline(particle, property, commands)
    return nil if !commands || commands.empty?
    if particle[:name] == "SE"
      ret = []
      commands.each { |cmd| ret[cmd[0]] = 0 }
      return ret
    end
    if !GameData::Animation::PARTICLE_KEYFRAME_DEFAULT_VALUES.include?(property)
      raise _INTL("No default value for property {1} in PARTICLE_KEYFRAME_DEFAULT_VALUES.", property)
    end
    ret = []
    val = GameData::Animation::PARTICLE_KEYFRAME_DEFAULT_VALUES[property]
    commands.each do |cmd|
      if cmd[1] > 0   # MoveXYZ
        dur = cmd[1]
        dur *= -1 if cmd[2] < val
        ret[cmd[0]] = [dur, cmd[3] || :linear]
        ret[cmd[0] + cmd[1]] = 0
      else   # SetXYZ
        ret[cmd[0]] = 0
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

  # SetXYZ at frame
  #   - none: Do nothing.
  #   - interp: Add MoveXYZ (calc duration/value at end).
  # MoveXYZ at frame
  #   - none: Turn into two SetXYZ (MoveXYZ's value for end point, calc value
  #           for start point).
  #   - interp: Change type.
  # SetXYZ and MoveXYZ at frame
  #   - none: Turn MoveXYZ into SetXYZ at the end point.
  #   - interp: Change MoveXYZ's type.
  # End of earlier MoveXYZ (or nothing) at frame
  #   - none: Do nothing.
  #   - interp: Add MoveXYZ (calc duration/value at end).
  def set_interpolation(particle, property, frame, type)
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
        # Turn the MoveXYZ command into a SetXYZ (or just delete it if a SetXYZ
        # already exists at frame)
        if set_now
          particle[property].delete(move_starting_now)
        else
          move_starting_now[1] = 0
          move_starting_now[2] = get_keyframe_particle_value(particle, property, frame)[0]
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
      particle[property].each do |cmd|   # Assumes commands are sorted by keyframe
        next if cmd[0] <= frame
        val_at_end = get_keyframe_particle_value(particle, property, cmd[0])[0]
        particle[property].push([frame, cmd[0] - frame, val_at_end, type])
        particle[property].sort! { |a, b| a[0] == b[0] ? a[1] == b[1] ? 0 : a[1] <=> b[1] : a[0] <=> b[0] }
        break
      end
    end
    return particle[property]
  end

  #-----------------------------------------------------------------------------

  def get_se_display_text(property, value)
    ret = ""
    case property
    when :user_cry
      ret += _INTL("[[User's cry]]")
    when :target_cry
      ret += _INTL("[[Target's cry]]")
    when :se
      ret += value[2]
    else
      raise _INTL("Unhandled property {1} for SE particle found.", property)
    end
    volume = (property == :se) ? value[3] : value[2]
    ret += " " + _INTL("(volume: {1})", volume) if volume && volume != 100
    pitch = (property == :se) ? value[4] : value[3]
    ret += " " + _INTL("(pitch: {1})", pitch) if pitch && pitch != 100
    return ret
  end

  # Returns the volume and pitch of the SE to be played at the given frame
  # of the given filename.
  def get_se_values_from_filename_and_frame(particle, frame, filename)
    return nil if !filename
    case filename
    when "USER", "TARGET"
      property = (filename == "USER") ? :user_cry : :target_cry
      slot = particle[property].select { |s| s[0] == frame }[0]
      return nil if !slot
      return slot[2] || 100, slot[3] || 100
    else
      slot = particle[:se].select { |s| s[0] == frame && s[2] == filename }[0]
      return nil if !slot
      return slot[3] || 100, slot[4] || 100
    end
    return nil
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
  def insert_frame(particle, frame)
    particle.each_pair do |property, values|
      next if !values.is_a?(Array) || values.empty?
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
  def remove_frame(particle, frame)
    particle.keys.each do |property|
      next if !particle[property].is_a?(Array) || particle[property].empty?
      delete_command(particle, property, frame, true)
    end
    particle.delete_if { |property, values| values.is_a?(Array) && values.empty? }
    particle.each_pair do |key, values|
      next if !values.is_a?(Array) || values.empty?
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
