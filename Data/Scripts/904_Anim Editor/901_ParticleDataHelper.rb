#===============================================================================
#
#===============================================================================
module AnimationEditor::ParticleDataHelper
  module_function

  def get_duration(particles)
    ret = 0
    particles.each do |p|
      p.each_pair do |cmd, val|
        next if !val.is_a?(Array) || val.length == 0
        max = val.last[0] + val.last[1]   # Keyframe + duration
        ret = max if ret < max
      end
    end
    return ret
  end

  def get_keyframe_particle_value(particle, frame, property)
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
        ret[0] = lerp(ret[0], cmd[2], cmd[1], cmd[0], frame).to_i
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
        next if !value.is_a?(Array) || value.length == 0
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
      ret[prop] = get_keyframe_particle_value(particle, frame, prop)
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

  # TODO: Generalise this to any property?
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
    value = GameData::Animation::PARTICLE_KEYFRAME_DEFAULT_VALUES[:visible]
    value = true if ["User", "Target", "SE"].include?(particle[:name])
    ret = []
    if !["User", "Target", "SE"].include?(particle[:name])
      earliest = duration
      particle.each_pair do |prop, value|
        next if !value.is_a?(Array) || value.length == 0
        earliest = value[0][0] if earliest > value[0][0]
      end
      ret[earliest] = true
    end
    if particle[:visible]
      particle[:visible].each { |cmd| ret[cmd[0]] = cmd[2] }
    end
    duration.times do |i|
      value = ret[i] if !ret[i].nil?
      ret[i] = value
    end
    return ret
  end

  #-----------------------------------------------------------------------------

  # Returns an array indicating where command diamonds and duration lines should
  # be drawn in the AnimationEditor::ParticleList.
  def get_particle_commands_timeline(particle)
    ret = []
    durations = []
    particle.each_pair do |prop, val|
      next if !val.is_a?(Array)
      val.each do |cmd|
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
  def get_particle_property_commands_timeline(particle, commands, property)
    return nil if !commands || commands.length == 0
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

  def add_command(particle, property, frame, value)
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
    # Add new command to points (may replace an existing command)
    interp = :none
    (frame + 1).times do |i|
      interp = :none if set_points[i] || end_points[i]
      interp = interps[i] if interps[i]
    end
    interps[frame] = interp if interp != :none
    set_points[frame] = value
    # Convert points and interps back into particle[property]
    ret = []
    if !GameData::Animation::PARTICLE_KEYFRAME_DEFAULT_VALUES.include?(property)
      raise _INTL("Couldn't get default value for property {1}.", property)
    end
    val = GameData::Animation::PARTICLE_KEYFRAME_DEFAULT_VALUES[property]
    val = true if property == :visible && ["User", "Target", "SE"].include?(particle[:name])
    length = [set_points.length, end_points.length].max
    length.times do |i|
      if !set_points[i].nil? && set_points[i] != val
        ret.push([i, 0, set_points[i]])
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
end
