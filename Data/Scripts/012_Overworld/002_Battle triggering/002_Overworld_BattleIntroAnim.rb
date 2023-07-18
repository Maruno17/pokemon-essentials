#===============================================================================
# Registers special battle transition animations which may be used instead of
# the default ones. There are examples below of how to register them.
#
# The register call has 4 arguments:
#    1) The name of the animation. Typically unused, but helps to identify the
#       registration code for a particular animation if necessary.
#    2) The animation's priority. If multiple special animations could trigger
#       for the same battle, the one with the highest priority number is used.
#    3) A condition proc which decides whether the animation should trigger.
#    4) The animation itself. Could be a bunch of code, or a call to, say,
#       pbCommonEvent(20) or something else. By the end of the animation, the
#       screen should be black.
# Note that you can get an image of the current game screen with
# Graphics.snap_to_bitmap.
#===============================================================================
module SpecialBattleIntroAnimations
  # [name, priority number, "trigger if" proc, animation proc]
  @@anims = []

  def self.register(name, priority, condition, hash)
    @@anims.push([name, priority, condition, hash])
  end

  def self.remove(name)
    @@anims.delete_if { |anim| anim[0] == name }
  end

  def self.each
    ret = @@anims.sort { |a, b| b[1] <=> a[1] }
    ret.each { |anim| yield anim[0], anim[1], anim[2], anim[3] }
  end

  def self.has?(name)
    return @@anims.any? { |anim| anim[0] == name }
  end

  def self.get(name)
    @@anims.each { |anim| return anim if anim[0] == name }
    return nil
  end
end

#===============================================================================
# Battle intro animation
#===============================================================================
class Game_Temp
  attr_accessor :transition_animation_data
end

def pbSceneStandby
  $scene.disposeSpritesets if $scene.is_a?(Scene_Map)
  RPG::Cache.clear
  Graphics.frame_reset
  yield
  $scene.createSpritesets if $scene.is_a?(Scene_Map)
end

def pbBattleAnimation(bgm = nil, battletype = 0, foe = nil)
  $game_temp.in_battle = true
  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 99999
  # Set up audio
  playingBGS = nil
  playingBGM = nil
  if $game_system.is_a?(Game_System)
    playingBGS = $game_system.getPlayingBGS
    playingBGM = $game_system.getPlayingBGM
    $game_system.bgm_pause
    $game_system.bgs_pause
    if $game_temp.memorized_bgm
      playingBGM = $game_temp.memorized_bgm
      $game_system.bgm_position = $game_temp.memorized_bgm_position
    end
  end
  # Play battle music
  bgm = pbGetWildBattleBGM([]) if !bgm
  pbBGMPlay(bgm)
  # Determine location of battle
  location = 0   # 0=outside, 1=inside, 2=cave, 3=water
  if $PokemonGlobal.surfing || $PokemonGlobal.diving
    location = 3
  elsif $game_temp.encounter_type &&
        GameData::EncounterType.get($game_temp.encounter_type).type == :fishing
    location = 3
  elsif $PokemonEncounters.has_cave_encounters?
    location = 2
  elsif !$game_map.metadata&.outdoor_map
    location = 1
  end
  # Check for custom battle intro animations
  handled = false
  SpecialBattleIntroAnimations.each do |name, priority, condition, animation|
    next if !condition.call(battletype, foe, location)
    animation.call(viewport, battletype, foe, location)
    handled = true
    break
  end
  # Default battle intro animation
  if !handled
    # Determine which animation is played
    anim = ""
    if PBDayNight.isDay?
      case battletype
      when 0, 2   # Wild, double wild
        anim = ["SnakeSquares", "DiagonalBubbleTL", "DiagonalBubbleBR", "RisingSplash"][location]
      when 1      # Trainer
        anim = ["TwoBallPass", "ThreeBallDown", "BallDown", "WavyThreeBallUp"][location]
      when 3      # Double trainer
        anim = "FourBallBurst"
      end
    else
      case battletype
      when 0, 2   # Wild, double wild
        anim = ["SnakeSquares", "DiagonalBubbleBR", "DiagonalBubbleBR", "RisingSplash"][location]
      when 1      # Trainer
        anim = ["SpinBallSplit", "BallDown", "BallDown", "WavySpinBall"][location]
      when 3      # Double trainer
        anim = "FourBallBurst"
      end
    end
    pbBattleAnimationCore(anim, viewport, location)
  end
  pbPushFade
  # Yield to the battle scene
  yield if block_given?
  # After the battle
  pbPopFade
  if $game_system.is_a?(Game_System)
    $game_system.bgm_resume(playingBGM)
    $game_system.bgs_resume(playingBGS)
  end
  $game_temp.memorized_bgm            = nil
  $game_temp.memorized_bgm_position   = 0
  $PokemonGlobal.nextBattleBGM        = nil
  $PokemonGlobal.nextBattleVictoryBGM = nil
  $PokemonGlobal.nextBattleCaptureME  = nil
  $PokemonGlobal.nextBattleBack       = nil
  $PokemonEncounters.reset_step_count
  # Fade back to the overworld in 0.4 seconds
  viewport.color = Color.black
  timer_start = System.uptime
  loop do
    Graphics.update
    Input.update
    pbUpdateSceneMap
    viewport.color.alpha = 255 * (1 - ((System.uptime - timer_start) / 0.4))
    break if viewport.color.alpha <= 0
  end
  viewport.dispose
  $game_temp.in_battle = false
end

def pbBattleAnimationCore(anim, viewport, location, num_flashes = 2)
  # Initial screen flashing
  if num_flashes > 0
    c = (location == 2 || PBDayNight.isNight?) ? 0 : 255   # Dark=black, light=white
    viewport.color = Color.new(c, c, c)   # Fade to black/white a few times
    half_flash_time = 0.2   # seconds
    num_flashes.times do   # 2 flashes
      fade_out = false
      timer_start = System.uptime
      loop do
        if fade_out
          viewport.color.alpha = lerp(255, 0, half_flash_time, timer_start, System.uptime)
        else
          viewport.color.alpha = lerp(0, 255, half_flash_time, timer_start, System.uptime)
        end
        Graphics.update
        pbUpdateSceneMap
        break if fade_out && viewport.color.alpha <= 0
        if !fade_out && viewport.color.alpha >= 255
          fade_out = true
          timer_start = System.uptime
        end
      end
    end
  end
  # Take screenshot of game, for use in some animations
  $game_temp.background_bitmap&.dispose
  $game_temp.background_bitmap = Graphics.snap_to_bitmap
  # Play main animation
  Graphics.freeze
  viewport.color = Color.black   # Ensure screen is black
  Graphics.transition(25, "Graphics/Transitions/" + anim)
  # Slight pause after animation before starting up the battle scene
  pbWait(0.1)
end

#===============================================================================
# Play the HGSS "VSTrainer" battle transition animation for any single trainer
# battle where the following graphics exist in the Graphics/Transitions/
# folder for the opponent:
#   * "hgss_vs_TRAINERTYPE.png" and "hgss_vsBar_TRAINERTYPE.png"
# This animation makes use of $game_temp.transition_animation_data, and expects
# it to be an array like so: [:TRAINERTYPE, "display name"]
#===============================================================================
SpecialBattleIntroAnimations.register("vs_trainer_animation", 60,   # Priority 60
  proc { |battle_type, foe, location|   # Condition
    next false if battle_type.even? || foe.length != 1   # Trainer battle against 1 trainer
    tr_type = foe[0].trainer_type
    next pbResolveBitmap("Graphics/Transitions/hgss_vs_#{tr_type}") &&
         pbResolveBitmap("Graphics/Transitions/hgss_vsBar_#{tr_type}")
  },
  proc { |viewport, battle_type, foe, location|   # Animation
    $game_temp.transition_animation_data = [foe[0].trainer_type, foe[0].name]
    pbBattleAnimationCore("VSTrainer", viewport, location, 1)
    $game_temp.transition_animation_data = nil
  }
)

#===============================================================================
# Play the "VSEliteFour" battle transition animation for any single trainer
# battle where the following graphics exist in the Graphics/Transitions/
# folder for the opponent:
#   * "vsE4_TRAINERTYPE.png" and "vsE4Bar_TRAINERTYPE.png"
# This animation makes use of $game_temp.transition_animation_data, and expects
# it to be an array like so:
#   [:TRAINERTYPE, "display name", "player sprite name minus 'vsE4_'"]
#===============================================================================
SpecialBattleIntroAnimations.register("vs_elite_four_animation", 60,   # Priority 60
  proc { |battle_type, foe, location|   # Condition
    next false if battle_type.even? || foe.length != 1   # Trainer battle against 1 trainer
    tr_type = foe[0].trainer_type
    next pbResolveBitmap("Graphics/Transitions/vsE4_#{tr_type}") &&
         pbResolveBitmap("Graphics/Transitions/vsE4Bar_#{tr_type}")
  },
  proc { |viewport, battle_type, foe, location|   # Animation
    tr_sprite_name = $player.trainer_type.to_s
    if pbResolveBitmap("Graphics/Transitions/vsE4_#{tr_sprite_name}_#{$player.outfit}")
      tr_sprite_name += "_#{$player.outfit}"
    end
    $game_temp.transition_animation_data = [foe[0].trainer_type, foe[0].name, tr_sprite_name]
    pbBattleAnimationCore("VSEliteFour", viewport, location, 0)
    $game_temp.transition_animation_data = nil
  }
)

#===============================================================================
# Play the "VSRocketAdmin" battle transition animation for any trainer battle
# where the following graphic exists in the Graphics/Transitions/ folder for any
# of the opponents:
#   * "rocket_TRAINERTYPE.png"
# This animation makes use of $game_temp.transition_animation_data, and expects
# it to be an array like so: [:TRAINERTYPE, "display name"]
#===============================================================================
SpecialBattleIntroAnimations.register("vs_admin_animation", 60,   # Priority 60
  proc { |battle_type, foe, location|   # Condition
    next false if ![1, 3].include?(battle_type)   # Trainer battles only
    found = false
    foe.each do |f|
      found = pbResolveBitmap("Graphics/Transitions/rocket_#{f.trainer_type}")
      break if found
    end
    next found
  },
  proc { |viewport, battle_type, foe, location|   # Animation
    foe.each do |f|
      tr_type = f.trainer_type
      next if !pbResolveBitmap("Graphics/Transitions/rocket_#{tr_type}")
      $game_temp.transition_animation_data = [tr_type, f.name]
      break
    end
    pbBattleAnimationCore("VSRocketAdmin", viewport, location, 0)
    $game_temp.transition_animation_data = nil
  }
)

#===============================================================================
# Play the original Vs. Trainer battle transition animation for any single
# trainer battle where the following graphics exist in the Graphics/Transitions/
# folder for the opponent:
#   * "vsTrainer_TRAINERTYPE.png" and "vsBar_TRAINERTYPE.png"
#===============================================================================
##### VS. animation, by Luka S.J. #####
##### Tweaked by Maruno           #####
SpecialBattleIntroAnimations.register("alternate_vs_trainer_animation", 50,   # Priority 50
  proc { |battle_type, foe, location|   # Condition
    next false if battle_type.even? || foe.length != 1   # Trainer battle against 1 trainer
    tr_type = foe[0].trainer_type
    next pbResolveBitmap("Graphics/Transitions/vsTrainer_#{tr_type}") &&
         pbResolveBitmap("Graphics/Transitions/vsBar_#{tr_type}")
  },
  proc { |viewport, battle_type, foe, location|   # Animation
    # Determine filenames of graphics to be used
    tr_type = foe[0].trainer_type
    trainer_bar_graphic = sprintf("vsBar_%s", tr_type.to_s) rescue nil
    trainer_graphic     = sprintf("vsTrainer_%s", tr_type.to_s) rescue nil
    player_tr_type = $player.trainer_type
    outfit = $player.outfit
    player_bar_graphic = sprintf("vsBar_%s_%d", player_tr_type.to_s, outfit) rescue nil
    if !pbResolveBitmap("Graphics/Transitions/" + player_bar_graphic)
      player_bar_graphic = sprintf("vsBar_%s", player_tr_type.to_s) rescue nil
    end
    player_graphic = sprintf("vsTrainer_%s_%d", player_tr_type.to_s, outfit) rescue nil
    if !pbResolveBitmap("Graphics/Transitions/" + player_graphic)
      player_graphic = sprintf("vsTrainer_%s", player_tr_type.to_s) rescue nil
    end
    # Set up viewports
    viewplayer = Viewport.new(0, Graphics.height / 3, Graphics.width / 2, 128)
    viewplayer.z = viewport.z
    viewopp = Viewport.new(Graphics.width / 2, Graphics.height / 3, Graphics.width / 2, 128)
    viewopp.z = viewport.z
    viewvs = Viewport.new(0, 0, Graphics.width, Graphics.height)
    viewvs.z = viewport.z
    # Set up sprites
    fade = Sprite.new(viewport)
    fade.bitmap  = RPG::Cache.transition("vsFlash")
    fade.tone    = Tone.new(-255, -255, -255)
    fade.opacity = 100
    overlay = Sprite.new(viewport)
    overlay.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    pbSetSystemFont(overlay.bitmap)
    xoffset = ((Graphics.width / 2) / 10) * 10
    bar1 = Sprite.new(viewplayer)
    bar1.bitmap = RPG::Cache.transition(player_bar_graphic)
    bar1.x      = -xoffset
    bar2 = Sprite.new(viewopp)
    bar2.bitmap = RPG::Cache.transition(trainer_bar_graphic)
    bar2.x      = xoffset
    vs_x = Graphics.width / 2
    vs_y = Graphics.height / 1.5
    vs = Sprite.new(viewvs)
    vs.bitmap  = RPG::Cache.transition("vs")
    vs.ox      = vs.bitmap.width / 2
    vs.oy      = vs.bitmap.height / 2
    vs.x       = vs_x
    vs.y       = vs_y
    vs.visible = false
    flash = Sprite.new(viewvs)
    flash.bitmap  = RPG::Cache.transition("vsFlash")
    flash.opacity = 0
    # Animate bars sliding in from either side
    pbWait(0.25) do |delta_t|
      bar1.x = lerp(-xoffset, 0, 0.25, delta_t)
      bar2.x = lerp(xoffset, 0, 0.25, delta_t)
    end
    bar1.dispose
    bar2.dispose
    # Make whole screen flash white
    pbSEPlay("Vs flash")
    pbSEPlay("Vs sword")
    flash.opacity = 255
    # Replace bar sprites with AnimatedPlanes, set up trainer sprites
    bar1 = AnimatedPlane.new(viewplayer)
    bar1.bitmap = RPG::Cache.transition(player_bar_graphic)
    bar2 = AnimatedPlane.new(viewopp)
    bar2.bitmap = RPG::Cache.transition(trainer_bar_graphic)
    player = Sprite.new(viewplayer)
    player.bitmap = RPG::Cache.transition(player_graphic)
    player.x      = -xoffset
    trainer = Sprite.new(viewopp)
    trainer.bitmap = RPG::Cache.transition(trainer_graphic)
    trainer.x      = xoffset
    trainer.tone   = Tone.new(-255, -255, -255)
    # Dim the flash and make the trainer sprites appear, while animating bars
    pbWait(1.2) do |delta_t|
      flash.opacity = lerp(255, 0, 0.25, delta_t)
      bar1.ox = lerp(0, -bar1.bitmap.width * 3, 1.2, delta_t)
      bar2.ox = lerp(0, bar2.bitmap.width * 3, 1.2, delta_t)
      player.x = lerp(-xoffset, 0, 0.25, delta_t - 0.6)
      trainer.x = lerp(xoffset, 0, 0.25, delta_t - 0.6)
    end
    player.x = 0
    trainer.x = 0
    # Make whole screen flash white again
    flash.opacity = 255
    pbSEPlay("Vs sword")
    # Make the Vs logo and trainer names appear, and reset trainer's tone
    vs.visible = true
    trainer.tone = Tone.new(0, 0, 0)
    trainername = foe[0].name
    textpos = [
      [$player.name, Graphics.width / 4, (Graphics.height / 1.5) + 16, :center,
       Color.new(248, 248, 248), Color.new(72, 72, 72)],
      [trainername, (Graphics.width / 4) + (Graphics.width / 2), (Graphics.height / 1.5) + 16, :center,
       Color.new(248, 248, 248), Color.new(72, 72, 72)]
    ]
    pbDrawTextPositions(overlay.bitmap, textpos)
    # Fade out flash, shudder Vs logo and expand it, and then fade to black
    shudder_time = 1.75
    zoom_time = 2.5
    pbWait(2.8) do |delta_t|
      if delta_t <= shudder_time
        flash.opacity = lerp(255, 0, 0.25, delta_t)   # Fade out the white flash
      elsif delta_t >= zoom_time
        flash.tone = Tone.new(-255, -255, -255)   # Make the flash black
        flash.opacity = lerp(0, 255, 0.25, delta_t - zoom_time)   # Fade to black
      end
      bar1.ox = lerp(0, -bar1.bitmap.width * 7, 2.8, delta_t)
      bar2.ox = lerp(0, bar2.bitmap.width * 7, 2.8, delta_t)
      if delta_t <= shudder_time
        # +2, -2, -2, +2, repeat
        period = (delta_t / 0.025).to_i % 4
        shudder_delta = [2, 0, -2, 0][period]
        vs.x = vs_x + shudder_delta
        vs.y = vs_y - shudder_delta
      elsif delta_t <= zoom_time
        vs.zoom_x = lerp(1.0, 7.0, zoom_time - shudder_time, delta_t - shudder_time)
        vs.zoom_y = vs.zoom_x
      end
    end
    # End of animation
    player.dispose
    trainer.dispose
    flash.dispose
    vs.dispose
    bar1.dispose
    bar2.dispose
    overlay.dispose
    fade.dispose
    viewvs.dispose
    viewopp.dispose
    viewplayer.dispose
    viewport.color = Color.black   # Ensure screen is black
  }
)

#===============================================================================
# Play the "RocketGrunt" battle transition animation for any trainer battle
# involving a Team Rocket Grunt. Is lower priority than the Vs. animation above.
#===============================================================================
SpecialBattleIntroAnimations.register("rocket_grunt_animation", 40,   # Priority 40
  proc { |battle_type, foe, location|   # Condition
    next false unless [1, 3].include?(battle_type)   # Only if a trainer battle
    trainer_types = [:TEAMROCKET_M, :TEAMROCKET_F]
    next foe.any? { |f| trainer_types.include?(f.trainer_type) }
  },
  proc { |viewport, battle_type, foe, location|   # Animation
    pbBattleAnimationCore("RocketGrunt", viewport, location)
  }
)
