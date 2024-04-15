module AnimationConverter
  NO_USER_COMMON_ANIMATIONS = [
    "Hail", "HarshSun", "HeavyRain", "Rain", "Sandstorm", "Sun", "ShadowSky",
    "Rainbow", "RainbowOpp", "SeaOfFire", "SeaOfFireOpp", "Swamp", "SwampOpp"
  ]
  HAS_TARGET_COMMON_ANIMATIONS = ["LeechSeed", "ParentalBond"]

  module_function

  def convert_old_animations_to_new
    list = pbLoadBattleAnimations
    raise "No animations found." if !list || list.length == 0

    last_move = nil   # For filename purposes
    last_version = 0
    last_type = :move

    list.each do |anim|
      next if !anim.name || anim.name == "" || anim.length <= 1

      # Get folder and filename for new PBS file
      folder = "Example anims/"
      folder += (anim.name[/^Common:/]) ? "Common/" :  "Move/"
      filename = anim.name.gsub(/^Common:/, "")
      filename.gsub!(/^Move:/, "")
      filename.gsub!(/^OppMove:/, "")
      # Update record of move and version
      type = :move
      if anim.name[/^Common:/]
        type = :common
      elsif anim.name[/^OppMove:/]
        type = :opp_move
      elsif anim.name[/^Move:/]
        type = :move
      end
      if filename == anim.name
        last_version += 1
        type = last_type
        pbs_path = folder + last_move
      else
        last_move = filename
        last_version = 0
        last_type = type
        pbs_path = folder + filename
      end
      last_move = filename if !last_move
      # Generate basic animaiton properties

      new_anim = {
        :type      => type,
        :move      => last_move,
        :version   => last_version,
        :name      => "Example anim",
        :particles => [],
        :pbs_path  => pbs_path
      }

      # Decide whether the animation involves a user or target
      has_user = true
      has_target = true
      if new_anim[:type] == :common
        if NO_USER_COMMON_ANIMATIONS.include?(new_anim[:move])
          has_user = false
          has_target = false
        elsif !HAS_TARGET_COMMON_ANIMATIONS.include?(new_anim[:move])
          has_target = false
        end
      else
        move_data = GameData::Move.try_get(new_anim[:move])
        if move_data
          target_data = GameData::Target.get(move_data.target)
          has_target = false if target_data.num_targets == 0 && target_data.id != :None
        end
      end
      new_anim[:no_user] = true if !has_user
      new_anim[:no_target] = true if !has_target

      add_frames_to_new_anim_hash(anim, new_anim)
      add_bg_fg_commands_to_new_anim_hash(anim, new_anim)
      add_se_commands_to_new_anim_hash(anim, new_anim)

      new_anim[:particles].compact!
      GameData::Animation.register(new_anim)
      Compiler.write_battle_animation_file(new_anim[:pbs_path])
    end

  end

  #-----------------------------------------------------------------------------

  def add_frames_to_new_anim_hash(anim, hash)
    # Lookup array for particle index using cel index
    index_lookup = []
    max_index = -1
    # Set up previous frame's values
    default_frame = []
    default_frame[AnimFrame::X]          = -999
    default_frame[AnimFrame::Y]          = -999
    default_frame[AnimFrame::ZOOMX]      = 100
    default_frame[AnimFrame::ZOOMY]      = 100
    default_frame[AnimFrame::BLENDTYPE]  = 0
    default_frame[AnimFrame::ANGLE]      = 0
    default_frame[AnimFrame::OPACITY]    = 255
    default_frame[AnimFrame::COLORRED]   = 0
    default_frame[AnimFrame::COLORGREEN] = 0
    default_frame[AnimFrame::COLORBLUE]  = 0
    default_frame[AnimFrame::COLORALPHA] = 0
    default_frame[AnimFrame::TONERED]    = 0
    default_frame[AnimFrame::TONEGREEN]  = 0
    default_frame[AnimFrame::TONEBLUE]   = 0
    default_frame[AnimFrame::TONEGRAY]   = 0
    default_frame[AnimFrame::PATTERN]    = 0
    default_frame[AnimFrame::PRIORITY]   = 0   # 0=back, 1=front, 2=behind focus, 3=before focus

    default_frame[AnimFrame::VISIBLE]    = 1   # Boolean
    default_frame[AnimFrame::MIRROR]     = 0   # Boolean

    default_frame[AnimFrame::FOCUS]      = 4   # 1=target, 2=user, 3=user and target, 4=screen

    default_frame[99]                    = "Examples/" + anim.graphic

    last_frame_values = []

    anim_graphic = anim.graphic
    anim_graphic.gsub!(".", " ")
    anim_graphic.gsub!("  ", " ")
    # Go through each frame
    anim.length.times do |frame_num|
      frame = anim[frame_num]
      had_particles = []
      changed_particles = []
      frame.each_with_index do |cel, i|
        next if !cel
        next if i == 0 && hash[:no_user]
        next if i == 1 && hash[:no_target]
        # If the particle from the previous frame for this cel had a different
        # focus, start a new particle.
        if i > 1 && frame_num > 0 && index_lookup[i] && index_lookup[i] >= 0 &&
           last_frame_values[index_lookup[i]]
          this_graphic = (cel[AnimFrame::PATTERN] == -1) ? "USER" : (cel[AnimFrame::PATTERN] == -2) ? "TARGET" : "Examples/" + anim_graphic
          this_graphic.gsub!(".", " ")
          this_graphic.gsub!("  ", "")
          focus = cel[AnimFrame::FOCUS]
          focus = 2 if (focus == 1 || focus == 3) && hash[:no_target]
          focus = 0 if (focus == 2 || focus == 3) && hash[:no_user]
          if last_frame_values[index_lookup[i]][AnimFrame::FOCUS] != focus ||
             last_frame_values[index_lookup[i]][99] != this_graphic   # Graphic
            index_lookup[i] = -1
          end
        end
        # Get the particle index for this cel
        if !index_lookup[i] || index_lookup[i] < 0
          max_index += 1
          index_lookup[i] = max_index
        end
        idx = index_lookup[i]
        had_particles.push(idx)
        # i=0 for "User", i=1 for "Target"
        hash[:particles][idx] ||= { :name => "Particle #{idx}" }
        particle = hash[:particles][idx]
        last_frame = last_frame_values[idx] || default_frame.clone
        # User and target particles have specific names
        if i == 0
          particle[:name] = "User"
        elsif i == 1
          particle[:name] = "Target"
        else
          # Set graphic
          case cel[AnimFrame::PATTERN]
          when -1   # User's sprite
            particle[:graphic] = "USER"
            last_frame[99] = "USER"
          when -2   # Target's sprite
            particle[:graphic] = "TARGET"
            last_frame[99] = "TARGET"
          else
            particle[:graphic] = "Examples/" + anim_graphic
            last_frame[99] = "Examples/" + anim_graphic
          end
        end
        # Set focus for non-User/non-Target
        if i > 1
          focus = cel[AnimFrame::FOCUS]
          focus = 2 if (focus == 1 || focus == 3) && hash[:no_target]
          focus = 0 if (focus == 2 || focus == 3) && hash[:no_user]
          particle[:focus] = [:foreground, :target, :user, :user_and_target, :foreground][focus]
          last_frame[AnimFrame::FOCUS] = focus
        end

        # Copy commands across
        [
          [AnimFrame::X, :x],
          [AnimFrame::Y, :y],
          [AnimFrame::ZOOMX, :zoom_x],
          [AnimFrame::ZOOMY, :zoom_y],
          [AnimFrame::BLENDTYPE, :blending],
          [AnimFrame::ANGLE, :angle],
          [AnimFrame::OPACITY, :opacity],
          [AnimFrame::COLORRED, :color_red],
          [AnimFrame::COLORGREEN, :color_green],
          [AnimFrame::COLORBLUE, :color_blue],
          [AnimFrame::COLORALPHA, :color_alpha],
          [AnimFrame::TONERED, :tone_red],
          [AnimFrame::TONEGREEN, :tone_green],
          [AnimFrame::TONEBLUE, :tone_blue],
          [AnimFrame::TONEGRAY, :tone_gray],
          [AnimFrame::PATTERN, :frame],
          [AnimFrame::PRIORITY, :z],
          [AnimFrame::VISIBLE, :visible],   # Boolean
          [AnimFrame::MIRROR, :flip],   # Boolean
        ].each do |property|
          next if cel[property[0]] == last_frame[property[0]]
          particle[property[1]] ||= []
          val = cel[property[0]].to_i
          case property[1]
          when :x
            case cel[AnimFrame::FOCUS]
            when 1   # :target
              val -= Battle::Scene::FOCUSTARGET_X
            when 2   # :user
              val -= Battle::Scene::FOCUSUSER_X
            when 3   # :user_and_target
              user_x = Battle::Scene::FOCUSUSER_X
              target_x = Battle::Scene::FOCUSTARGET_X
              if hash[:type] == :opp_move
                user_x = Battle::Scene::FOCUSTARGET_X
                target_x = Battle::Scene::FOCUSUSER_X
              end
              fraction = (val - user_x).to_f / (target_x - user_x)
              val = (fraction * GameData::Animation::USER_AND_TARGET_SEPARATION[0]).to_i
            end
            if cel[AnimFrame::FOCUS] != particle[:focus]
              pseudo_focus = cel[AnimFrame::FOCUS]
              # Was focused on target, now focused on user
              pseudo_focus = 2 if [1, 3].include?(pseudo_focus) && hash[:no_target]
              # Was focused on user, now focused on screen
              val += Battle::Scene::FOCUSUSER_X if [2, 3].include?(pseudo_focus) && hash[:no_user]
            end
          when :y
            case cel[AnimFrame::FOCUS]
            when 1   # :target
              val -= Battle::Scene::FOCUSTARGET_Y
            when 2   # :user
              val -= Battle::Scene::FOCUSUSER_Y
            when 3   # :user_and_target
              user_y = Battle::Scene::FOCUSUSER_Y
              target_y = Battle::Scene::FOCUSTARGET_Y
              if hash[:type] == :opp_move
                user_y = Battle::Scene::FOCUSTARGET_Y
                target_y = Battle::Scene::FOCUSUSER_Y
              end
              fraction = (val - user_y).to_f / (target_y - user_y)
              val = (fraction * GameData::Animation::USER_AND_TARGET_SEPARATION[1]).to_i
            end
            if cel[AnimFrame::FOCUS] != particle[:focus]
              pseudo_focus = cel[AnimFrame::FOCUS]
              # Was focused on target, now focused on user
              pseudo_focus = 2 if [1, 3].include?(pseudo_focus) && hash[:no_target]
              # Was focused on user, now focused on screen
              val += Battle::Scene::FOCUSUSER_Y if [2, 3].include?(pseudo_focus) && hash[:no_user]
            end
          when :visible, :flip
            val = (val == 1)   # Boolean
          when :z
            next if i <= 1   # User or target
            case val
            when 0 then val = -50 + i   # Back
            when 1 then val = 25 + i    # Front
            when 2 then val = -25 + i   # Behind focus
            when 3 then val = i         # Before focus
            end
          when :frame
            next if val < 0   # -1 is user, -2 is target
          end
          particle[property[1]].push([frame_num, 0, val])
          last_frame[property[0]] = cel[property[0]]
          changed_particles.push(idx) if !changed_particles.include?(idx)
        end
        # Remember this cel's values at this frame
        last_frame_values[idx] = last_frame
      end
      # End every particle lifetime that didn't have a corresponding cel this
      # frame
      hash[:particles].each_with_index do |particle, idx|
        next if !particle || had_particles.include?(idx)
        next if ["User", "Target"].include?(particle[:name])
        if last_frame_values[idx][AnimFrame::VISIBLE] == 1
          particle[:visible] ||= []
          particle[:visible].push([frame_num, 0, false])
          changed_particles.push(idx) if !changed_particles.include?(idx)
        end
        last_frame_values[idx][AnimFrame::VISIBLE] = 0
        next if !index_lookup.include?(idx)
        lookup_idx = index_lookup.index(idx)
        index_lookup[lookup_idx] = -1
      end
      # Add a dummy command in the last frame if that frame doesn't have any
      # commands (this makes all visible particles invisible)
      if frame_num == anim.length - 1 && changed_particles.empty?
        hash[:particles].each_with_index do |particle, idx|
          next if !particle || ["User", "Target"].include?(particle[:name])
          next if last_frame_values[idx][AnimFrame::VISIBLE] == 0
          particle[:visible] ||= []
          particle[:visible].push([frame_num + 1, 0, false])
        end
      end
    end

    if hash[:particles].any? { |particle| particle[:name] == "User" }
      user_particle = hash[:particles].select { |particle| particle[:name] == "User" }[0]
      user_particle[:focus] = :user
    end
    if hash[:particles].any? { |particle| particle[:name] == "Target" }
      target_particle = hash[:particles].select { |particle| particle[:name] == "Target" }[0]
      target_particle[:focus] = :target
    end
  end

  #-----------------------------------------------------------------------------

  def add_bg_fg_commands_to_new_anim_hash(anim, new_anim)
    bg_particle = { :name => "Background", :focus => :background }
    fg_particle = { :name => "Foreground", :focus => :foreground }
    first_bg_frame = 999
    first_fg_frame = 999
    anim.timing.each do |cmd|
      case cmd.timingType
      when 1, 2, 3, 4   # BG graphic (set, move/recolour), FG graphic (set, move/recolour)
        is_bg = (cmd.timingType <= 2)
        particle = (is_bg) ? bg_particle : fg_particle
        duration = (cmd.timingType == 2) ? cmd.duration : 0
        added = false
        if cmd.name && cmd.name != ""
          particle[:graphic] ||= []
          particle[:graphic].push([cmd.frame, duration, cmd.name])
          added = true
        end
        if cmd.colorRed
          particle[:color_red] ||= []
          particle[:color_red].push([cmd.frame, duration, cmd.colorRed])
          added = true
        end
        if cmd.colorGreen
          particle[:color_green] ||= []
          particle[:color_green].push([cmd.frame, duration, cmd.colorGreen])
          added = true
        end
        if cmd.colorBlue
          particle[:color_blue] ||= []
          particle[:color_blue].push([cmd.frame, duration, cmd.colorBlue])
          added = true
        end
        if cmd.colorAlpha
          particle[:color_alpha] ||= []
          particle[:color_alpha].push([cmd.frame, duration, cmd.colorAlpha])
          added = true
        end
        if cmd.opacity
          particle[:opacity] ||= []
          particle[:opacity].push([cmd.frame, duration, cmd.opacity])
          added = true
        end
        if cmd.bgX
          particle[:x] ||= []
          particle[:x].push([cmd.frame, duration, cmd.bgX])
          added = true
        end
        if cmd.bgY
          particle[:y] ||= []
          particle[:y].push([cmd.frame, duration, cmd.bgY])
          added = true
        end
        if added
          if is_bg
            first_bg_frame = [first_bg_frame, cmd.frame].min
          else
            first_fg_frame = [first_fg_frame, cmd.frame].min
          end
        end
      end
    end
    if bg_particle.keys.length > 2
      if !bg_particle[:graphic]
        particle[:graphic] ||= []
        particle[:graphic].push([first_bg_frame, 0, "black_screen"])
      end
      new_anim[:particles].push(bg_particle)
    end
    if fg_particle.keys.length > 2
      if !fg_particle[:graphic]
        particle[:graphic] ||= []
        particle[:graphic].push([first_fg_frame, 0, "black_screen"])
      end
      new_anim[:particles].push(fg_particle)
    end
  end

  def add_se_commands_to_new_anim_hash(anim, new_anim)
    anim.timing.each do |cmd|
      next if cmd.timingType != 0   # Play SE
      particle = new_anim[:particles].last
      if particle[:name] != "SE"
        particle = { :name => "SE" }
        new_anim[:particles].push(particle)
      end
      # Add command
      if cmd.name && cmd.name != ""
        particle[:se] ||= []
        particle[:se].push([cmd.frame, 0, cmd.name, cmd.volume, cmd.pitch])
      else   # Play user's cry
        particle[:user_cry] ||= []
        particle[:user_cry].push([cmd.frame, 0, cmd.volume, cmd.pitch])
      end
    end
  end
end

#===============================================================================
# Add to Debug menu.
#===============================================================================
# MenuHandlers.add(:debug_menu, :convert_anims, {
#   "name"        => "Convert old animation to PBS files",
#   "parent"      => :main,
#   "description" => "This is just for the sake of having lots of example animation PBS files.",
#   "effect"      => proc {
#     AnimationConverter.convert_old_animations_to_new
#   }
# })
