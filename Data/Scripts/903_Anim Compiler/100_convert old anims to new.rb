module AnimationConverter
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
      folder = "Converted/"
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
        :name      => filename,
        :particles => [],
        :pbs_path  => pbs_path
      }

      add_frames_to_new_anim_hash(anim, new_anim)
      add_se_commands_to_new_anim_hash(anim, new_anim)

      new_anim[:particles].compact!
      GameData::Animation.register(new_anim)
      Compiler.write_battle_animation_file(new_anim[:pbs_path])
    end

  end

  def add_frames_to_new_anim_hash(anim, hash)
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

    default_frame[AnimFrame::VISIBLE]    = 1   # Boolean
    default_frame[AnimFrame::MIRROR]     = 0   # Boolean

    default_frame[AnimFrame::FOCUS]      = 4   # 1=target, 2=user, 3=user and target, 4=screen

    last_frame_values = []
    # Go through each frame
    anim.length.times do |frame_num|
      frame = anim[frame_num]
      frame.each_with_index do |cel, i|
        next if !cel
        # i=0 for "User", i=1 for "Target"
        hash[:particles][i] ||= {
          :name => "Particle #{i}"
        }
        particle = hash[:particles][i]
        if i == 0
          particle[:name] = "User"
        elsif i == 1
          particle[:name] = "Target"
        end

        last_frame = last_frame_values[i] || default_frame.clone
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
          [AnimFrame::VISIBLE, :visible],   # Boolean
          [AnimFrame::MIRROR, :flip],   # Boolean
        ].each do |property|
          next if cel[property[0]] == last_frame[property[0]]
          particle[property[1]] ||= []
          val = cel[property[0]].to_i
          val = (val == 1) if [:visible, :flip].include?(property[1])
          particle[property[1]].push([frame_num, 0, val])
          last_frame[property[0]] = cel[property[0]]
        end
        # Set graphic
        particle[:graphic] = anim.graphic
        # Set focus for non-User/non-Target
        if i > 1
          particle[:focus] = [:screen, :target, :user, :user_and_target, :screen][cel[AnimFrame::FOCUS]]
        end
        # Remember this cel's values at this frame
        last_frame_values[i] = last_frame
      end
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
