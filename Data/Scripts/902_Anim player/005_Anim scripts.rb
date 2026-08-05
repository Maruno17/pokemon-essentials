#===============================================================================
#
#===============================================================================
class AnimationPlayer
  UPDATE_ANIMATION_SCRIPTS = HandlerHash.new   # Called each frame while playing
  END_ANIMATION_SCRIPTS    = HandlerHash.new   # Called when animation ends
end

#===============================================================================
# These are scripts run by AnimationPlayer at the end of each update loop while
# an animation is playing. The animation needs to have the name of the script
# written in its "Scripts" property, which is a comma-separated set of script
# names.
#
# Note that player.total_duration is the actual duration multiplied by
# player.slowdown (1=normal speed, 2=half speed, etc.), and is the duration in
# real time rather than as the animation is defined. Slowdown is only a factor
# when playing animations in the Animation Editor. "time" is as the animation is
# defined (e.g. for an animation lasting 30 frames at 20 FPS, "time" will always
# go from 0.0 to 1.5 no matter the slowdown factor).
#===============================================================================

AnimationPlayer::UPDATE_ANIMATION_SCRIPTS.add("darkpulse") { |player, time|
  ["battle_bg", "battle_bg2", "base_0", "base_1"].each do |sprite|
    next if !player.sprites[sprite]
    player.sprites[sprite].tone.set(0, 0, 0, 255)   # Grayscale
  end
}
AnimationPlayer::END_ANIMATION_SCRIPTS.add("darkpulse") { |player|
  ["battle_bg", "battle_bg2", "base_0", "base_1"].each do |sprite|
    next if !player.sprites[sprite]
    player.sprites[sprite].tone.set(0, 0, 0, 0)   # Back to normal
  end
}
