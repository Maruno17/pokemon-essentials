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

# Makes the background graphics grayscale during the animation.
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

#===============================================================================

# Make ParticleSprites spawned by emitters called "Feather echo emitter #"
# inherit their original angle from the ParticleSprite called "Feather #".
AnimationPlayer::UPDATE_ANIMATION_SCRIPTS.add("roost") { |player, time|
  player.emitters.each do |emitter|
    emitter.particle_sprites.each do |emit_particle|
      next if emit_particle.emitter_params[:angle_set]
      if emit_particle.name[/Feather echo emitter (\d)/]
        number = $~[1]
        player.particle_sprites.each do |particle|
          next if particle.name != "Feather " + number
          emit_particle.sprite[0].angle = particle.sprite[0].angle
          emit_particle.emitter_params[:angle_set] = true
        end
      end
    end
  end
}

#===============================================================================

# Makes all battlers on the side opposite to the user glow purple temporarily.
# The coloring starts at start_time, fades in, remains colored briefly then
# fades away.
AnimationPlayer::UPDATE_ANIMATION_SCRIPTS.add("toxicspikes") { |player, time|
  next if !player.user   # Just in case; there should be a user
  start_time = 34 / 20.0
  next if time < start_time
  fade_time = 7 / 20.0
  linger_time = 1 / 20.0   # Time spent fully colored purple
  mod_time = time - start_time
  side = player.user.idxOwnSide
  # Calculate the color
  if mod_time < fade_time + linger_time   # Fading in
    poison_color = Color.new(168, 0, 248, lerp(0, 160, fade_time, mod_time))
  else   # Fading out
    poison_color = Color.new(168, 0, 248, lerp(160, 0, fade_time, mod_time - fade_time - linger_time))
  end
  # Apply the color to all battlers on the other side
  player.scene.sprites.each_pair do |id, sprite|
    next if !sprite.is_a?(Battle::Scene::BattlerSprite) || (sprite.index & 1) == side
    sprite.color.set(poison_color.red, poison_color.green, poison_color.blue, poison_color.alpha)
  end
}
AnimationPlayer::END_ANIMATION_SCRIPTS.add("toxicspikes") { |player|
  next if !player.user   # Just in case; there should be a user
  side = player.user.idxOwnSide
  player.scene.sprites.each_pair do |id, sprite|
    next if !sprite.is_a?(Battle::Scene::BattlerSprite) || (sprite.index & 1) == side
    sprite.color.set(0, 0, 0, 0)   # Back to normal
  end
}
