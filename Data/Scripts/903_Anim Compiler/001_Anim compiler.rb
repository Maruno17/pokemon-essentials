module Compiler
  module_function

  def compile_battle_animations(*paths)
    GameData::Animation::DATA.clear
    schema = GameData::Animation.schema
    sub_schema = GameData::Animation.sub_schema
    idx = 0
    # Read from PBS file(s)
    Console.echo_li(_INTL("Compiling animation PBS files..."))
    paths.each do |path|
      file_name = path.gsub(/^PBS\/Animations\//, "").gsub(/.txt$/, "")
      data_hash = nil
      current_particle = nil
      section_name = nil
      section_line = nil
      # Read each line of the animation PBS file at a time and compile it as an
      # animation property
      pbCompilerEachPreppedLine(path) do |line, line_no|
        echo "." if idx % 100 == 0
        idx += 1
        Graphics.update if idx % 500 == 0
        FileLineData.setSection(section_name, nil, section_line)
        if line[/^\s*\[\s*(.+)\s*\]\s*$/]
          # New section [anim_type, name]
          section_name = $~[1]
          section_line = line
          if data_hash
            validate_compiled_animation(data_hash)
            GameData::Animation.register(data_hash)
          end
          FileLineData.setSection(section_name, nil, section_line)
          # Construct data hash
          data_hash = {
            :pbs_path => file_name
          }
          data_hash[schema["SectionName"][0]] = get_csv_record(section_name.clone, schema["SectionName"])
          data_hash[schema["Particle"][0]] = []
          current_particle = nil
        elsif line[/^\s*<\s*(.+)\s*>\s*$/]
          # New subsection [particle_name]
          value = get_csv_record($~[1], schema["Particle"])
          current_particle = {
            :name => value
          }
          data_hash[schema["Particle"][0]].push(current_particle)
        elsif line[/^\s*(\w+)\s*=\s*(.*)$/]
          # XXX=YYY lines
          if !data_hash
            raise _INTL("Expected a section at the beginning of the file.") + "\n" + FileLineData.linereport
          end
          key = $~[1]
          if schema[key]   # Property of the animation
            value = get_csv_record($~[2], schema[key])
            if schema[key][1][0] == "^"
              value = nil if value.is_a?(Array) && value.empty?
              data_hash[schema[key][0]] ||= []
              data_hash[schema[key][0]].push(value) if value
            else
              value = nil if value.is_a?(Array) && value.empty?
              data_hash[schema[key][0]] = value
            end
          elsif sub_schema[key]   # Property of a particle
            if !current_particle
              raise _INTL("Particle hasn't been defined yet!") + "\n" + FileLineData.linereport
            end
            value = get_csv_record($~[2], sub_schema[key])
            if sub_schema[key][1][0] == "^"
              value = nil if value.is_a?(Array) && value.empty?
              current_particle[sub_schema[key][0]] ||= []
              current_particle[sub_schema[key][0]].push(value) if value
            else
              value = nil if value.is_a?(Array) && value.empty?
              current_particle[sub_schema[key][0]] = value
            end
          end
        end
      end
      # Add last animation's data to records
      if data_hash
        FileLineData.setSection(section_name, nil, section_line)
        validate_compiled_animation(data_hash)
        GameData::Animation.register(data_hash)
      end
    end
    validate_all_compiled_animations
    process_pbs_file_message_end
    # Save all data
    GameData::Animation.save
  end

  def validate_compiled_animation(hash)
    # Split anim_type, move/common_name, version into their own values
    hash[:type] = hash[:id][0]
    hash[:move] = hash[:id][1]
    hash[:version] = hash[:id][2] || 0
    # Ensure there is at most one each of "User", "Target" and "SE" particles
    ["User", "Target", "SE"].each do |type|
      next if hash[:particles].count { |particle| particle[:name] == type } <= 1
      raise _INTL("Animation has more than 1 \"{1}\" particle, which isn't allowed.", type) + "\n" + FileLineData.linereport
    end
    # Ensure there is no "User" particle if "NoUser" is set
    if hash[:particles].any? { |particle| particle[:name] == "User" } && hash[:no_user]
      raise _INTL("Can't define a \"User\" particle and also set property \"NoUser\" to true.") + "\n" + FileLineData.linereport
    end
    # Ensure there is no "Target" particle if "NoTarget" is set
    if hash[:particles].any? { |particle| particle[:name] == "Target" } && hash[:no_target]
      raise _INTL("Can't define a \"Target\" particle and also set property \"NoTarget\" to true.") + "\n" + FileLineData.linereport
    end
    # Create "User", "Target" and "SE" particles if they don't exist but should
    if hash[:particles].none? { |particle| particle[:name] == "User" } && !hash[:no_user]
      hash[:particles].push({:name => "User"})
    end
    if hash[:particles].none? { |particle| particle[:name] == "Target" } && !hash[:no_target]
      hash[:particles].push({:name => "Target"})
    end
    if hash[:particles].none? { |particle| particle[:name] == "SE" }
      hash[:particles].push({:name => "SE"})
    end
    # Go through each particle in turn
    hash[:particles].each do |particle|
      # Ensure the "Play"-type commands are exclusive to the "SE" particle, and
      # that the "SE" particle has no other commands
      if particle[:name] == "SE"
        particle.keys.each do |property|
          next if [:name, :se, :user_cry, :target_cry].include?(property)
          raise _INTL("Particle \"{1}\" has a command that isn't a \"Play\"-type command.",
             particle[:name]) + "\n" + FileLineData.linereport
        end
      else
        if particle[:se]
          raise _INTL("Particle \"{1}\" has a \"Play\" command but shouldn't.",
                      particle[:name]) + "\n" + FileLineData.linereport
        elsif particle[:user_cry]
          raise _INTL("Particle \"{1}\" has a \"PlayUserCry\" command but shouldn't.",
                      particle[:name]) + "\n" + FileLineData.linereport
        elsif particle[:target_cry]
          raise _INTL("Particle \"{1}\" has a \"PlayTargetCry\" command but shouldn't.",
                      particle[:name]) + "\n" + FileLineData.linereport
        end
      end
      # Ensure all particles have a default focus if not given
      if !particle[:focus] && particle[:name] != "SE"
        case particle[:name]
        when "User"   then particle[:focus] = :user
        when "Target" then particle[:focus] = :target
        else               particle[:focus] = GameData::Animation::PARTICLE_DEFAULT_VALUES[:focus]
        end
      end
      # Ensure user/target particles have a default graphic if not given
      if !particle[:graphic] && particle[:name] != "SE"
        case particle[:name]
        when "User"   then particle[:graphic] = "USER"
        when "Target" then particle[:graphic] = "TARGET"
        end
      end
      # If the animation doesn't involve a user, ensure that particles don't
      # have a focus/graphic that involves a user, and that the animation
      # doesn't play a user's cry
      if hash[:no_user]
        if GameData::Animation::FOCUS_TYPES_WITH_USER.include?(particle[:focus])
          raise _INTL("Particle \"{1}\" can't have a \"Focus\" that involves a user if property \"NoUser\" is set to true.",
                      particle[:name]) + "\n" + FileLineData.linereport
        end
        if ["USER", "USER_OPP", "USER_FRONT", "USER_BACK"].include?(particle[:graphic])
          raise _INTL("Particle \"{1}\" can't have a \"Graphic\" that involves a user if property \"NoUser\" is set to true.",
                      particle[:name]) + "\n" + FileLineData.linereport
        end
        if particle[:name] == "SE" && particle[:user_cry] && !particle[:user_cry].empty?
          raise _INTL("Animation can't play the user's cry if property \"NoUser\" is set to true.") + "\n" + FileLineData.linereport
        end
      end
      # If the animation doesn't involve a target, ensure that particles don't
      # have a focus/graphic that involves a target, and that the animation
      # doesn't play a target's cry
      if hash[:no_target]
        if GameData::Animation::FOCUS_TYPES_WITH_TARGET.include?(particle[:focus])
          raise _INTL("Particle \"{1}\" can't have a \"Focus\" that involves a target if property \"NoTarget\" is set to true.",
                      particle[:name]) + "\n" + FileLineData.linereport
        end
        if ["TARGET", "TARGET_OPP", "TARGET_FRONT", "TARGET_BACK"].include?(particle[:graphic])
          raise _INTL("Particle \"{1}\" can't have a \"Graphic\" that involves a target if property \"NoTarget\" is set to true.",
                      particle[:name]) + "\n" + FileLineData.linereport
        end
        if particle[:name] == "SE" && particle[:target_cry] && !particle[:target_cry].empty?
          raise _INTL("Animation can't play the target's cry if property \"NoTarget\" is set to true.") + "\n" + FileLineData.linereport
        end
      end
      # Ensure that none of the particle's "alter something if focus is a
      # battler on the foe's side" properties are set if the particle doesn't
      # have such a focus
      if GameData::Animation::FOCUS_TYPES_WITH_USER.include?(particle[:focus]) == GameData::Animation::FOCUS_TYPES_WITH_TARGET.include?(particle[:focus])
        if particle[:foe_invert_x]
          raise _INTL("Particle \"{1}\" can't set \"FoeInvertX\" if its focus isn't exactly 1 thing.",
                      particle[:name]) + "\n" + FileLineData.linereport
        end
        if particle[:foe_invert_y]
          raise _INTL("Particle \"{1}\" can't set \"FoeInvertY\" if its focus isn't exactly 1 thing.",
                      particle[:name]) + "\n" + FileLineData.linereport
        end
        if particle[:foe_flip]
          raise _INTL("Particle \"{1}\" can't set \"FoeFlip\" if its focus isn't exactly 1 thing.",
                      particle[:name]) + "\n" + FileLineData.linereport
        end
      end
      # Ensure that only particles that have an entity as a focus can have a
      # smart angle
      if (particle[:angle_override] || :none) != :none &&
         !GameData::Animation::FOCUS_TYPES_WITH_USER.include?(particle[:focus]) &&
         !GameData::Animation::FOCUS_TYPES_WITH_TARGET.include?(particle[:focus])
        raise _INTL("Particle \"{1}\" can't set \"AngleOverride\" if its focus isn't a specific thing(s).",
                    particle[:name]) + "\n" + FileLineData.linereport
      end
      # Ensure that a particle with a user's/target's graphic doesn't have any
      # :frame commands
      if !["User", "Target", "SE"].include?(particle[:name]) &&
         ["USER", "USER_OPP", "USER_FRONT", "USER_BACK",
          "TARGET", "TARGET_OPP", "TARGET_FRONT", "TARGET_BACK"].include?(particle[:graphic]) &&
         particle[:frame] && !particle[:frame].empty?
        raise _INTL("Particle \"{1}\" can't have any \"Frame\" commands if its graphic is a Pokémon's sprite.",
                    particle[:name]) + "\n" + FileLineData.linereport
      end
      # Ensure that the same SE isn't played twice in the same frame
      if particle[:name] == "SE"
        [:se, :user_cry, :target_cry].each do |property|
          next if !particle[property]
          files_played = []
          particle[property].each do |play|
            files_played[play[0]] ||= []
            if files_played[play[0]].include?(play[1])
              case property
              when :se
                raise _INTL("SE \"{1}\" should not play twice in the same frame ({2}).", play[1], play[0]) + "\n" + FileLineData.linereport
              when :user_cry
                raise _INTL("User's cry should not play twice in the same frame ({1}).", play[0]) + "\n" + FileLineData.linereport
              when :target_cry
                raise _INTL("Target's cry should not play twice in the same frame ({1}).", play[0]) + "\n" + FileLineData.linereport
              end
            end
            files_played[play[0]].push(play[1])
          end
        end
      end
      # Convert all "SetXYZ" particle commands to "MoveXYZ" by giving them a
      # duration of 0 (even ones that can't have a "MoveXYZ" command)
      GameData::Animation::PARTICLE_KEYFRAME_DEFAULT_VALUES.keys.each do |prop|
        next if !particle[prop]
        particle[prop].each do |cmd|
          cmd.insert(1, 0) if cmd.length == 2 || particle[:name] == "SE"
          # Give default interpolation value of :linear to any "MoveXYZ" command
          # that doesn't have one already
          cmd.push(:linear) if cmd[1] > 0 && cmd.length < 4
        end
      end
      # Sort each particle's commands by their keyframe and duration
      particle.keys.each do |key|
        next if !particle[key].is_a?(Array)
        particle[key].sort! { |a, b| a[0] == b[0] ? a[1] == b[1] ? 0 : a[1] <=> b[1] : a[0] <=> b[0] }
        next if particle[:name] == "SE"
        # Check for any overlapping particle commands
        last_frame = -1
        last_set_frame = -1
        particle[key].each do |cmd|
          if last_frame > cmd[0]
            raise _INTL("Animation has overlapping commands for the {1} property.",
                        key.to_s.capitalize) + "\n" + FileLineData.linereport
          end
          if cmd[1] == 0 && last_set_frame >= cmd[0]
            raise _INTL("Animation has multiple \"Set\" commands in the same keyframe for the {1} property.",
                        key.to_s.capitalize) + "\n" + FileLineData.linereport
          end
          last_frame = cmd[0] + cmd[1]
          last_set_frame = cmd[0] if cmd[1] == 0
        end
      end
      # Ensure valid values for "SetBlending" commands
      if particle[:blending]
        particle[:blending].each do |blend|
          next if blend[2] <= 2
          raise _INTL("Invalid blend value: {1} (must be 0, 1 or 2).\n{2}",
                      blend[2], FileLineData.linereport)
        end
      end

    end
  end

  def validate_all_compiled_animations; end
end

#===============================================================================
# Hook into the regular Compiler to also compile animation PBS files.
# This is a separate Compiler that runs after the regular one.
#===============================================================================
module Compiler
  module_function

  def get_animation_pbs_files_to_compile
    ret = []
    if FileTest.directory?("PBS/Animations")
      Dir.all("PBS/Animations", "**/**.txt").each { |file| ret.push(file) }
    end
    return ret
  end

  class << self
    if !method_defined?(:__new_anims_main)
      alias_method :__new_anims_main, :main
    end
  end

  def main
    __new_anims_main
    return if !$DEBUG
    begin
      Console.echo_h1(_INTL("Checking new animations data"))
      must_compile = false
      data_file = "animations.dat"
      text_files = get_animation_pbs_files_to_compile
      latest_data_time = 0
      latest_text_time = 0
      # Check data file for its latest modify time
      if FileTest.exist?("Data/" + data_file)
        begin
          File.open("Data/#{data_file}") do |file|
            latest_data_time = [latest_data_time, file.mtime.to_i].max
          end
        rescue SystemCallError
          must_compile = true
        end
      else
        must_compile = true if text_files.length > 0
      end
      # Check PBS files for their latest modify time
      text_files.each do |filepath|
        begin
          File.open(filepath) do |file|
            latest_text_time = [latest_text_time, file.mtime.to_i].max
          end
        rescue SystemCallError
        end
      end
      # Decide to compile if a PBS file was edited more recently than the .dat file
      must_compile |= (latest_text_time >= latest_data_time)
      # Should recompile if holding Ctrl
      Input.update
      must_compile = true if $full_compile || Input.press?(Input::CTRL)
      # Delete old data file in preparation for recompiling
      if must_compile
        begin
          File.delete("Data/#{data_file}") if FileTest.exist?("Data/#{data_file}")
        rescue SystemCallError
        end
        # Recompile all data
        compile_battle_animations(*text_files)
      else
        Console.echoln_li(_INTL("New animations data were not compiled"))
      end
      echoln ""
    rescue Exception
      e = $!
      raise e if e.class.to_s == "Reset" || e.is_a?(Reset) || e.is_a?(SystemExit)
      pbPrintException(e)
      begin
        File.delete("Data/#{data_file}") if FileTest.exist?("Data/#{data_file}")
      rescue SystemCallError
      end
      raise Reset.new if e.is_a?(Hangup)
      raise SystemExit.new if e.is_a?(RuntimeError)
      raise "Unknown exception when compiling animations."
    end
  end
end
