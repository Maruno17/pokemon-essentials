#===============================================================================
#
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
def pbSceneStandby
  $scene.disposeSpritesets if $scene && $scene.is_a?(Scene_Map)
  RPG::Cache.clear
  Graphics.frame_reset
  yield
  $scene.createSpritesets if $scene && $scene.is_a?(Scene_Map)
end

def pbBattleAnimation(bgm=nil,battletype=0,foe=nil)
  $game_temp.in_battle = true
  viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z = 99999
  # Set up audio
  playingBGS = nil
  playingBGM = nil
  if $game_system && $game_system.is_a?(Game_System)
    playingBGS = $game_system.getPlayingBGS
    playingBGM = $game_system.getPlayingBGM
    $game_system.bgm_pause
    $game_system.bgs_pause
  end
  pbMEFade(0.25)
  pbWait(Graphics.frame_rate/4)
  pbMEStop
  # Play battle music
  bgm = pbGetWildBattleBGM([]) if !bgm
  pbBGMPlay(bgm)
  # Check for custom battle intro animations
  handled = false
  SpecialBattleIntroAnimations.each do |name, priority, condition, animation|
    next if !condition.call(battletype, foe)
    animation.call(viewport, battletype, foe)
    handled = true
  end
  # Default battle intro animation
  if !handled
    # Determine which animation is played
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
    anim = ""
    if PBDayNight.isDay?
      case battletype
      when 0, 2   # Wild, double wild
        anim = ["SnakeSquares","DiagonalBubbleTL","DiagonalBubbleBR","RisingSplash"][location]
      when 1      # Trainer
        anim = ["TwoBallPass","ThreeBallDown","BallDown","WavyThreeBallUp"][location]
      when 3      # Double trainer
        anim = "FourBallBurst"
      end
    else
      case battletype
      when 0, 2   # Wild, double wild
        anim = ["SnakeSquares","DiagonalBubbleBR","DiagonalBubbleBR","RisingSplash"][location]
      when 1      # Trainer
        anim = ["SpinBallSplit","BallDown","BallDown","WavySpinBall"][location]
      when 3      # Double trainer
        anim = "FourBallBurst"
      end
    end
    # Initial screen flashing
    if location==2 || PBDayNight.isNight?
      viewport.color = Color.new(0,0,0)         # Fade to black a few times
    else
      viewport.color = Color.new(255,255,255)   # Fade to white a few times
    end
    halfFlashTime = Graphics.frame_rate*2/10   # 0.2 seconds, 8 frames
    alphaDiff = (255.0/halfFlashTime).ceil
    2.times do
      viewport.color.alpha = 0
      for i in 0...halfFlashTime*2
        if i<halfFlashTime
          viewport.color.alpha += alphaDiff
        else
          viewport.color.alpha -= alphaDiff
        end
        Graphics.update
        pbUpdateSceneMap
      end
    end
    # Take screenshot of game, for use in some animations
    $game_temp.background_bitmap.dispose if $game_temp.background_bitmap
    $game_temp.background_bitmap = Graphics.snap_to_bitmap
    # Play main animation
    Graphics.freeze
    viewport.color = Color.new(0,0,0,255)   # Ensure screen is black
    Graphics.transition(25, "Graphics/Transitions/" + anim)
    # Slight pause after animation before starting up the battle scene
    (Graphics.frame_rate/10).times do
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
  end
  pbPushFade
  # Yield to the battle scene
  yield if block_given?
  # After the battle
  pbPopFade
  if $game_system && $game_system.is_a?(Game_System)
    $game_system.bgm_resume(playingBGM)
    $game_system.bgs_resume(playingBGS)
  end
  $PokemonGlobal.nextBattleBGM       = nil
  $PokemonGlobal.nextBattleME        = nil
  $PokemonGlobal.nextBattleCaptureME = nil
  $PokemonGlobal.nextBattleBack      = nil
  $PokemonEncounters.reset_step_count
  # Fade back to the overworld in 0.4 seconds
  viewport.color = Color.new(0,0,0,255)
  timer = 0.0
  loop do
    Graphics.update
    Input.update
    pbUpdateSceneMap
    timer += Graphics.delta_s
    viewport.color.alpha = 255 * (1 - timer / 0.4)
    break if viewport.color.alpha <= 0
  end
  viewport.dispose
  $game_temp.in_battle = false
end

#===============================================================================
# Vs. battle intro animation
# If you want to add a custom battle intro animation, copy the code below for
# the Vs. animation and adapt it to your own. The register call has 4 arguments:
#    1) The name of the animation. Typically unused, but helps to identify an
#       animation.
#    2) The animation's priority. If multiple special animations could trigger
#       for the same battle, the one with the highest priority number is used.
#    3) A condition proc which decides whether the animation should trigger.
#    4) The animation itself. Could be a bunch of code, or a call to, say,
#       pbCommonEvent(20) or something else. By the end of the animation, the
#       screen should be black.
# Note that you can get an image of the current game screen with
# Graphics.snap_to_bitmap.
#===============================================================================
##### VS. animation, by Luka S.J. #####
##### Tweaked by Maruno           #####
SpecialBattleIntroAnimations.register("vs_animation", 50,   # Priority 50
  Proc.new { |battle_type, foe|   # Condition
    next false unless [1, 3].include?(battle_type) && foe.length == 1   # Only if a single trainer
    tr_type = foe[0].trainer_type
    next false if !tr_type
    trainer_bar_graphic = sprintf("vsBar_%s", tr_type.to_s) rescue nil
    trainer_graphic     = sprintf("vsTrainer_%s", tr_type.to_s) rescue nil
    next pbResolveBitmap("Graphics/Transitions/" + trainer_bar_graphic) &&
         pbResolveBitmap("Graphics/Transitions/" + trainer_graphic)
  },
  Proc.new { |viewport, battle_type, foe|   # Animation
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
    vs = Sprite.new(viewvs)
    vs.bitmap  = RPG::Cache.transition("vs")
    vs.ox      = vs.bitmap.width / 2
    vs.oy      = vs.bitmap.height / 2
    vs.x       = Graphics.width / 2
    vs.y       = Graphics.height / 1.5
    vs.visible = false
    flash = Sprite.new(viewvs)
    flash.bitmap  = RPG::Cache.transition("vsFlash")
    flash.opacity = 0
    # Animate bars sliding in from either side
    slideInTime = (Graphics.frame_rate * 0.25).floor
    for i in 0...slideInTime
      bar1.x = xoffset * (i + 1 - slideInTime) / slideInTime
      bar2.x = xoffset * (slideInTime - i - 1) / slideInTime
      pbWait(1)
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
    animTime = (Graphics.frame_rate * 1.2).floor
    for i in 0...animTime
      flash.opacity -= 52 * 20 / Graphics.frame_rate if flash.opacity > 0
      bar1.ox -= 32 * 20 / Graphics.frame_rate
      bar2.ox += 32 * 20 / Graphics.frame_rate
      if i >= animTime / 2 && i < slideInTime + animTime / 2
        player.x = xoffset * (i + 1 - slideInTime - animTime / 2) / slideInTime
        trainer.x = xoffset * (slideInTime - i - 1 + animTime / 2) / slideInTime
      end
      pbWait(1)
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
       [$player.name, Graphics.width / 4, (Graphics.height / 1.5) + 4, 2,
          Color.new(248, 248, 248), Color.new(72, 72, 72)],
       [trainername, (Graphics.width / 4) + (Graphics.width / 2), (Graphics.height / 1.5) + 4, 2,
          Color.new(248, 248, 248), Color.new(72, 72, 72)]
    ]
    pbDrawTextPositions(overlay.bitmap, textpos)
    # Fade out flash, shudder Vs logo and expand it, and then fade to black
    animTime = (Graphics.frame_rate * 2.75).floor
    shudderTime = (Graphics.frame_rate * 1.75).floor
    zoomTime = (Graphics.frame_rate * 2.5).floor
    shudderDelta = [4 * 20 / Graphics.frame_rate, 1].max
    for i in 0...animTime
      if i < shudderTime   # Fade out the white flash
        flash.opacity -= 52 * 20 / Graphics.frame_rate if flash.opacity > 0
      elsif i == shudderTime   # Make the flash black
        flash.tone = Tone.new(-255, -255, -255)
      elsif i >= zoomTime   # Fade to black
        flash.opacity += 52 * 20 / Graphics.frame_rate if flash.opacity < 255
      end
      bar1.ox -= 32 * 20 / Graphics.frame_rate
      bar2.ox += 32 * 20 / Graphics.frame_rate
      if i < shudderTime
        j = i % (2 * Graphics.frame_rate / 20)
        if j >= 0.5 * Graphics.frame_rate / 20 && j < 1.5 * Graphics.frame_rate / 20
          vs.x += shudderDelta
          vs.y -= shudderDelta
        else
          vs.x -= shudderDelta
          vs.y += shudderDelta
        end
      elsif i < zoomTime
        vs.zoom_x += 0.4 * 20 / Graphics.frame_rate
        vs.zoom_y += 0.4 * 20 / Graphics.frame_rate
      end
      pbWait(1)
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
    viewport.color = Color.new(0, 0, 0, 255)
  }
)
