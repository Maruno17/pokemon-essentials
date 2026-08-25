#===============================================================================
#
#===============================================================================
class AnimationEditor
  def play_animation
    play_controls = @components[:play_controls]
    # Set up canvas as a pseudo-battle screen
    @components[:canvas].prepare_to_play_animation
    play_controls.prepare_to_play_animation
    # Set up fake battlers for the animation player
    user_battler = nil
    if !@anim[:no_user]
      idx_user = @settings[:anim_editor][:user_index]
      if @settings[:anim_editor][:user_opposes] || [:opp_move, :opp_common].include?(@anim[:type])
        idx_user += 1
      end
      user_battler = AnimationPlayer::FakeBattler.new(idx_user, @settings[:anim_editor][:user_sprite_name])
    end
    target_battlers = nil
    if !@anim[:no_target]
      target_battlers = []
      @settings[:anim_editor][:target_indices].each do |idx|
        idx_target = idx
        if @settings[:anim_editor][:user_opposes] || [:opp_move, :opp_common].include?(@anim[:type])
          idx_target += (idx_target.even?) ? 1 : -1
        end
        target_battlers.push(AnimationPlayer::FakeBattler.new(idx_target, @settings[:anim_editor][:target_sprite_name]))
      end
    end
    # Create animation player
    PBDebug.logonerr {
      anim_player = AnimationPlayer.new(@anim, user_battler, target_battlers, @components[:canvas])
      anim_player.looping = @components[:play_controls].looping
      anim_player.slowdown = @components[:play_controls].slowdown
      anim_player.set_up
      # Play animation
      anim_player.start
      loop do
        Graphics.update
        Input.update
        anim_player.update
        play_controls.update
        if play_controls.changed?
          if play_controls.changed_controls.keys.include?(:stop)
            anim_player.finish
            play_controls.clear_changed
            pbSEStop
            break
          end
        end
        if Input.triggerex?(:SPACE)
          pbSEStop
          break
        end
        break if anim_player.finished?
      end
      anim_player.dispose
    }
    @components[:canvas].end_playing_animation
    play_controls.end_playing_animation
  end
end
