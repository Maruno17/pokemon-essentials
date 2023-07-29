#===============================================================================
# Shows the battle scene fading in while elements slide around into place
#===============================================================================
class Battle::Scene::Animation::Intro < Battle::Scene::Animation
  def initialize(sprites, viewport, battle)
    @battle = battle
    super(sprites, viewport)
  end

  def createProcesses
    appearTime = 20   # This is in 1/20 seconds
    # Background
    if @sprites["battle_bg2"]
      makeSlideSprite("battle_bg", 0.5, appearTime)
      makeSlideSprite("battle_bg2", 0.5, appearTime)
    end
    # Bases
    makeSlideSprite("base_0", 1, appearTime, PictureOrigin::BOTTOM)
    makeSlideSprite("base_1", -1, appearTime, PictureOrigin::CENTER)
    # Player sprite, partner trainer sprite
    @battle.player.each_with_index do |_p, i|
      makeSlideSprite("player_#{i + 1}", 1, appearTime, PictureOrigin::BOTTOM)
    end
    # Opposing trainer sprite(s) or wild Pokémon sprite(s)
    if @battle.trainerBattle?
      @battle.opponent.each_with_index do |_p, i|
        makeSlideSprite("trainer_#{i + 1}", -1, appearTime, PictureOrigin::BOTTOM)
      end
    else   # Wild battle
      @battle.pbParty(1).each_with_index do |_pkmn, i|
        idxBattler = (2 * i) + 1
        makeSlideSprite("pokemon_#{idxBattler}", -1, appearTime, PictureOrigin::BOTTOM)
      end
    end
    # Shadows
    @battle.battlers.length.times do |i|
      makeSlideSprite("shadow_#{i}", (i.even?) ? 1 : -1, appearTime, PictureOrigin::CENTER)
    end
    # Fading blackness over whole screen
    blackScreen = addNewSprite(0, 0, "Graphics/Battle animations/black_screen")
    blackScreen.setZ(0, 999)
    blackScreen.moveOpacity(0, 8, 0)
    # Fading blackness over command bar
    blackBar = addNewSprite(@sprites["cmdBar_bg"].x, @sprites["cmdBar_bg"].y,
                            "Graphics/Battle animations/black_bar")
    blackBar.setZ(0, 998)
    blackBar.moveOpacity(appearTime * 3 / 4, appearTime / 4, 0)
  end

  def makeSlideSprite(spriteName, deltaMult, appearTime, origin = nil)
    # If deltaMult is positive, the sprite starts off to the right and moves
    # left (for sprites on the player's side and the background).
    return if !@sprites[spriteName]
    s = addSprite(@sprites[spriteName], origin)
    s.setDelta(0, (Graphics.width * deltaMult).floor, 0)
    s.moveDelta(0, appearTime, (-Graphics.width * deltaMult).floor, 0)
  end
end

#===============================================================================
# Shows wild Pokémon fading back to their normal color, and triggers their intro
# animations
#===============================================================================
class Battle::Scene::Animation::Intro2 < Battle::Scene::Animation
  def initialize(sprites, viewport, sideSize)
    @sideSize = sideSize
    super(sprites, viewport)
  end

  def createProcesses
    @sideSize.times do |i|
      idxBattler = (2 * i) + 1
      next if !@sprites["pokemon_#{idxBattler}"]
      battler = addSprite(@sprites["pokemon_#{idxBattler}"], PictureOrigin::BOTTOM)
      battler.moveTone(0, 4, Tone.new(0, 0, 0, 0))
      battler.setCallback(10 * i, [@sprites["pokemon_#{idxBattler}"], :pbPlayIntroAnimation])
    end
  end
end

#===============================================================================
# Makes a side's party bar and balls appear
#===============================================================================
class Battle::Scene::Animation::LineupAppear < Battle::Scene::Animation
  BAR_DISPLAY_WIDTH = 248

  def initialize(sprites, viewport, side, party, partyStarts, fullAnim)
    @side        = side
    @party       = party
    @partyStarts = partyStarts
    @fullAnim    = fullAnim   # True at start of battle, false when switching
    resetGraphics(sprites)
    super(sprites, viewport)
  end

  def resetGraphics(sprites)
    bar = sprites["partyBar_#{@side}"]
    case @side
    when 0   # Player's lineup
      barX  = Graphics.width - BAR_DISPLAY_WIDTH
      barY  = Graphics.height - 142
      ballX = barX + 44
      ballY = barY - 30
    when 1   # Opposing lineup
      barX  = BAR_DISPLAY_WIDTH
      barY  = 114
      ballX = barX - 44 - 30   # 30 is width of ball icon
      ballY = barY - 30
      barX -= bar.bitmap.width
    end
    ballXdiff = 32 * (1 - (2 * @side))
    bar.x       = barX
    bar.y       = barY
    bar.opacity = 255
    bar.visible = false
    Battle::Scene::NUM_BALLS.times do |i|
      ball = sprites["partyBall_#{@side}_#{i}"]
      ball.x       = ballX
      ball.y       = ballY
      ball.opacity = 255
      ball.visible = false
      ballX += ballXdiff
    end
  end

  def getPartyIndexFromBallIndex(idxBall)
    # Player's lineup (just show balls for player's party)
    if @side == 0
      return idxBall if @partyStarts.length < 2
      return idxBall if idxBall < @partyStarts[1]
      return -1
    end
    # Opposing lineup
    # NOTE: This doesn't work well for 4+ opposing trainers.
    ballsPerTrainer = Battle::Scene::NUM_BALLS / @partyStarts.length   # 6/3/2
    startsIndex = idxBall / ballsPerTrainer
    teamIndex = idxBall % ballsPerTrainer
    ret = @partyStarts[startsIndex] + teamIndex
    if startsIndex < @partyStarts.length - 1 && ret >= @partyStarts[startsIndex + 1]
      # There is a later trainer, don't spill over into its team
      return -1
    end
    return ret
  end

  def createProcesses
    bar = addSprite(@sprites["partyBar_#{@side}"])
    bar.setVisible(0, true)
    dir = (@side == 0) ? 1 : -1
    bar.setDelta(0, dir * Graphics.width / 2, 0)
    bar.moveDelta(0, 8, -dir * Graphics.width / 2, 0)
    delay = bar.totalDuration
    Battle::Scene::NUM_BALLS.times do |i|
      createBall(i, (@fullAnim) ? delay + (i * 2) : 0, dir)
    end
  end

  def createBall(idxBall, delay, dir)
    # Choose ball's graphic
    idxParty = getPartyIndexFromBallIndex(idxBall)
    graphicFilename = "Graphics/UI/Battle/icon_ball_empty"
    if idxParty >= 0 && idxParty < @party.length && @party[idxParty]
      if !@party[idxParty].able?
        graphicFilename = "Graphics/UI/Battle/icon_ball_faint"
      elsif @party[idxParty].status != :NONE
        graphicFilename = "Graphics/UI/Battle/icon_ball_status"
      else
        graphicFilename = "Graphics/UI/Battle/icon_ball"
      end
    end
    # Set up ball sprite
    ball = addSprite(@sprites["partyBall_#{@side}_#{idxBall}"])
    ball.setVisible(delay, true)
    ball.setName(delay, graphicFilename)
    ball.setDelta(delay, dir * Graphics.width / 2, 0)
    ball.moveDelta(delay, 8, -dir * Graphics.width / 2, 0)
  end
end

#===============================================================================
# Makes a Pokémon's data box appear
#===============================================================================
class Battle::Scene::Animation::DataBoxAppear < Battle::Scene::Animation
  def initialize(sprites, viewport, idxBox)
    @idxBox = idxBox
    super(sprites, viewport)
  end

  def createProcesses
    return if !@sprites["dataBox_#{@idxBox}"]
    box = addSprite(@sprites["dataBox_#{@idxBox}"])
    box.setVisible(0, true)
    dir = (@idxBox.even?) ? 1 : -1
    box.setDelta(0, dir * Graphics.width / 2, 0)
    box.moveDelta(0, 8, -dir * Graphics.width / 2, 0)
  end
end

#===============================================================================
# Makes a Pokémon's data box disappear
#===============================================================================
class Battle::Scene::Animation::DataBoxDisappear < Battle::Scene::Animation
  def initialize(sprites, viewport, idxBox)
    @idxBox = idxBox
    super(sprites, viewport)
  end

  def createProcesses
    return if !@sprites["dataBox_#{@idxBox}"] || !@sprites["dataBox_#{@idxBox}"].visible
    box = addSprite(@sprites["dataBox_#{@idxBox}"])
    dir = (@idxBox.even?) ? 1 : -1
    box.moveDelta(0, 8, dir * Graphics.width / 2, 0)
    box.setVisible(8, false)
  end
end

#===============================================================================
# Makes a Pokémon's ability bar appear
#===============================================================================
class Battle::Scene::Animation::AbilitySplashAppear < Battle::Scene::Animation
  def initialize(sprites, viewport, side)
    @side = side
    super(sprites, viewport)
  end

  def createProcesses
    return if !@sprites["abilityBar_#{@side}"]
    bar = addSprite(@sprites["abilityBar_#{@side}"])
    bar.setVisible(0, true)
    bar.setSE(0, "Battle ability")
    dir = (@side == 0) ? 1 : -1
    bar.moveDelta(0, 8, dir * Graphics.width / 2, 0)
  end
end

#===============================================================================
# Makes a Pokémon's ability bar disappear
#===============================================================================
class Battle::Scene::Animation::AbilitySplashDisappear < Battle::Scene::Animation
  def initialize(sprites, viewport, side)
    @side = side
    super(sprites, viewport)
  end

  def createProcesses
    return if !@sprites["abilityBar_#{@side}"]
    bar = addSprite(@sprites["abilityBar_#{@side}"])
    dir = (@side == 0) ? -1 : 1
    bar.moveDelta(0, 8, dir * Graphics.width / 2, 0)
    bar.setVisible(8, false)
  end
end

#===============================================================================
# Make an enemy trainer slide on-screen from the right. Makes the previous
# trainer slide off to the right first if it is on-screen.
# Used at the end of battle.
#===============================================================================
class Battle::Scene::Animation::TrainerAppear < Battle::Scene::Animation
  def initialize(sprites, viewport, idxTrainer)
    @idxTrainer = idxTrainer
    super(sprites, viewport)
  end

  def createProcesses
    delay = 0
    # Make old trainer sprite move off-screen first if necessary
    if @idxTrainer > 0 && @sprites["trainer_#{@idxTrainer}"].visible
      oldTrainer = addSprite(@sprites["trainer_#{@idxTrainer}"], PictureOrigin::BOTTOM)
      oldTrainer.moveDelta(delay, 8, Graphics.width / 4, 0)
      oldTrainer.setVisible(delay + 8, false)
      delay = oldTrainer.totalDuration
    end
    # Make new trainer sprite move on-screen
    if @sprites["trainer_#{@idxTrainer + 1}"]
      trainerX, trainerY = Battle::Scene.pbTrainerPosition(1)
      trainerX += 64 + (Graphics.width / 4)
      newTrainer = addSprite(@sprites["trainer_#{@idxTrainer + 1}"], PictureOrigin::BOTTOM)
      newTrainer.setVisible(delay, true)
      newTrainer.setXY(delay, trainerX, trainerY)
      newTrainer.moveDelta(delay, 8, -Graphics.width / 4, 0)
    end
  end
end

#===============================================================================
# Shows the player (and partner) and the player party lineup sliding off screen.
# Shows the player's/partner's throwing animation (if they have one).
# Doesn't show the ball thrown or the Pokémon.
#===============================================================================
class Battle::Scene::Animation::PlayerFade < Battle::Scene::Animation
  def initialize(sprites, viewport, fullAnim = false)
    @fullAnim = fullAnim   # True at start of battle, false when switching
    super(sprites, viewport)
  end

  def createProcesses
    # NOTE: The movement speeds of trainers/bar/balls are all different.
    # Move trainer sprite(s) off-screen
    spriteNameBase = "player"
    i = 1
    while @sprites[spriteNameBase + "_#{i}"]
      pl = @sprites[spriteNameBase + "_#{i}"]
      i += 1
      next if !pl.visible || pl.x < 0
      trainer = addSprite(pl, PictureOrigin::BOTTOM)
      trainer.moveDelta(0, 16, -Graphics.width / 2, 0)
      # Animate trainer sprite(s) if they have multiple frames
      if pl.bitmap && !pl.bitmap.disposed? && pl.bitmap.width >= pl.bitmap.height * 2
        size = pl.src_rect.width   # Width per frame
        trainer.setSrc(0, size, 0)
        trainer.setSrc(5, size * 2, 0)
        trainer.setSrc(7, size * 3, 0)
        trainer.setSrc(9, size * 4, 0)
      end
      trainer.setVisible(16, false)
    end
    # Move and fade party bar/balls
    delay = 3
    if @sprites["partyBar_0"]&.visible
      partyBar = addSprite(@sprites["partyBar_0"])
      partyBar.moveDelta(delay, 16, -Graphics.width / 4, 0) if @fullAnim
      partyBar.moveOpacity(delay, 12, 0)
      partyBar.setVisible(delay + 12, false)
      partyBar.setOpacity(delay + 12, 255)
    end
    Battle::Scene::NUM_BALLS.times do |j|
      next if !@sprites["partyBall_0_#{j}"] || !@sprites["partyBall_0_#{j}"].visible
      partyBall = addSprite(@sprites["partyBall_0_#{j}"])
      partyBall.moveDelta(delay + (2 * j), 16, -Graphics.width, 0) if @fullAnim
      partyBall.moveOpacity(delay, 12, 0)
      partyBall.setVisible(delay + 12, false)
      partyBall.setOpacity(delay + 12, 255)
    end
  end
end

#===============================================================================
# Shows the enemy trainer(s) and the enemy party lineup sliding off screen.
# Doesn't show the ball thrown or the Pokémon.
#===============================================================================
class Battle::Scene::Animation::TrainerFade < Battle::Scene::Animation
  def initialize(sprites, viewport, fullAnim = false)
    @fullAnim = fullAnim   # True at start of battle, false when switching
    super(sprites, viewport)
  end

  def createProcesses
    # NOTE: The movement speeds of trainers/bar/balls are all different.
    # Move trainer sprite(s) off-screen
    spriteNameBase = "trainer"
    i = 1
    while @sprites[spriteNameBase + "_#{i}"]
      trSprite = @sprites[spriteNameBase + "_#{i}"]
      i += 1
      next if !trSprite.visible || trSprite.x > Graphics.width
      trainer = addSprite(trSprite, PictureOrigin::BOTTOM)
      trainer.moveDelta(0, 16, Graphics.width / 2, 0)
      trainer.setVisible(16, false)
    end
    # Move and fade party bar/balls
    delay = 3
    if @sprites["partyBar_1"]&.visible
      partyBar = addSprite(@sprites["partyBar_1"])
      partyBar.moveDelta(delay, 16, Graphics.width / 4, 0) if @fullAnim
      partyBar.moveOpacity(delay, 12, 0)
      partyBar.setVisible(delay + 12, false)
      partyBar.setOpacity(delay + 12, 255)
    end
    Battle::Scene::NUM_BALLS.times do |j|
      next if !@sprites["partyBall_1_#{j}"] || !@sprites["partyBall_1_#{j}"].visible
      partyBall = addSprite(@sprites["partyBall_1_#{j}"])
      partyBall.moveDelta(delay + (2 * j), 16, Graphics.width, 0) if @fullAnim
      partyBall.moveOpacity(delay, 12, 0)
      partyBall.setVisible(delay + 12, false)
      partyBall.setOpacity(delay + 12, 255)
    end
  end
end

#===============================================================================
# Shows a Pokémon being sent out on the player's side (including by a partner).
# Includes the Poké Ball being thrown.
#===============================================================================
class Battle::Scene::Animation::PokeballPlayerSendOut < Battle::Scene::Animation
  include Battle::Scene::Animation::BallAnimationMixin

  def initialize(sprites, viewport, idxTrainer, battler, startBattle, idxOrder = 0)
    @idxTrainer     = idxTrainer
    @battler        = battler
    @showingTrainer = startBattle
    @idxOrder       = idxOrder
    @trainer        = @battler.battle.pbGetOwnerFromBattlerIndex(@battler.index)
    sprites["pokemon_#{battler.index}"].visible = false
    @shadowVisible = sprites["shadow_#{battler.index}"].visible
    sprites["shadow_#{battler.index}"].visible = false
    super(sprites, viewport)
  end

  def createProcesses
    batSprite = @sprites["pokemon_#{@battler.index}"]
    shaSprite = @sprites["shadow_#{@battler.index}"]
    traSprite = @sprites["player_#{@idxTrainer}"]
    # Calculate the Poké Ball graphic to use
    poke_ball = (batSprite.pkmn) ? batSprite.pkmn.poke_ball : nil
    # Calculate the color to turn the battler sprite
    col = getBattlerColorFromPokeBall(poke_ball)
    col.alpha = 255
    # Calculate start and end coordinates for battler sprite movement
    ballPos = Battle::Scene.pbBattlerPosition(@battler.index, batSprite.sideSize)
    battlerStartX = ballPos[0]   # Is also where the Ball needs to end
    battlerStartY = ballPos[1]   # Is also where the Ball needs to end + 18
    battlerEndX = batSprite.x
    battlerEndY = batSprite.y
    # Calculate start and end coordinates for Poké Ball sprite movement
    ballStartX = -6
    ballStartY = 202
    ballMidX = 0   # Unused in trajectory calculation
    ballMidY = battlerStartY - 144
    # Set up Poké Ball sprite
    ball = addBallSprite(ballStartX, ballStartY, poke_ball)
    ball.setZ(0, 25)
    ball.setVisible(0, false)
    # Poké Ball tracking the player's hand animation (if trainer is visible)
    if @showingTrainer && traSprite && traSprite.x > 0
      ball.setZ(0, traSprite.z - 1)
      ballStartX, ballStartY = ballTracksHand(ball, traSprite)
    end
    delay = ball.totalDuration   # 0 or 7
    # Poké Ball trajectory animation
    createBallTrajectory(ball, delay, 12,
                         ballStartX, ballStartY, ballMidX, ballMidY, battlerStartX, battlerStartY - 18)
    ball.setZ(9, batSprite.z - 1)
    delay = ball.totalDuration + 4
    delay += 10 * @idxOrder   # Stagger appearances if multiple Pokémon are sent out at once
    ballOpenUp(ball, delay - 2, poke_ball)
    ballBurst(delay, ball, battlerStartX, battlerStartY - 18, poke_ball)
    ball.moveOpacity(delay + 2, 2, 0)
    # Set up battler sprite
    battler = addSprite(batSprite, PictureOrigin::BOTTOM)
    battler.setXY(0, battlerStartX, battlerStartY)
    battler.setZoom(0, 0)
    battler.setColor(0, col)
    # Battler animation
    battlerAppear(battler, delay, battlerEndX, battlerEndY, batSprite, col)
    if @shadowVisible
      # Set up shadow sprite
      shadow = addSprite(shaSprite, PictureOrigin::CENTER)
      shadow.setOpacity(0, 0)
      # Shadow animation
      shadow.setVisible(delay, @shadowVisible)
      shadow.moveOpacity(delay + 5, 10, 255)
    end
  end
end

#===============================================================================
# Shows a Pokémon being sent out on the opposing side.
# Includes the Poké Ball being "thrown" (although here the Poké Ball just
# appears in the spot where it opens up rather than being thrown to there).
#===============================================================================
class Battle::Scene::Animation::PokeballTrainerSendOut < Battle::Scene::Animation
  include Battle::Scene::Animation::BallAnimationMixin

  def initialize(sprites, viewport, idxTrainer, battler, startBattle, idxOrder)
    @idxTrainer     = idxTrainer
    @battler        = battler
    @showingTrainer = startBattle
    @idxOrder       = idxOrder
    sprites["pokemon_#{battler.index}"].visible = false
    @shadowVisible = sprites["shadow_#{battler.index}"].visible
    sprites["shadow_#{battler.index}"].visible = false
    super(sprites, viewport)
  end

  def createProcesses
    batSprite = @sprites["pokemon_#{@battler.index}"]
    shaSprite = @sprites["shadow_#{@battler.index}"]
    # Calculate the Poké Ball graphic to use
    poke_ball = (batSprite.pkmn) ? batSprite.pkmn.poke_ball : nil
    # Calculate the color to turn the battler sprite
    col = getBattlerColorFromPokeBall(poke_ball)
    col.alpha = 255
    # Calculate start and end coordinates for battler sprite movement
    ballPos = Battle::Scene.pbBattlerPosition(@battler.index, batSprite.sideSize)
    battlerStartX = ballPos[0]
    battlerStartY = ballPos[1]
    battlerEndX = batSprite.x
    battlerEndY = batSprite.y
    # Set up Poké Ball sprite
    ball = addBallSprite(0, 0, poke_ball)
    ball.setZ(0, batSprite.z - 1)
    # Poké Ball animation
    createBallTrajectory(ball, battlerStartX, battlerStartY)
    delay = ball.totalDuration + 6
    delay += 10 if @showingTrainer   # Give time for trainer to slide off screen
    delay += 10 * @idxOrder   # Stagger appearances if multiple Pokémon are sent out at once
    ballOpenUp(ball, delay - 2, poke_ball)
    ballBurst(delay, ball, battlerStartX, battlerStartY - 18, poke_ball)
    ball.moveOpacity(delay + 2, 2, 0)
    # Set up battler sprite
    battler = addSprite(batSprite, PictureOrigin::BOTTOM)
    battler.setXY(0, battlerStartX, battlerStartY)
    battler.setZoom(0, 0)
    battler.setColor(0, col)
    # Battler animation
    battlerAppear(battler, delay, battlerEndX, battlerEndY, batSprite, col)
    if @shadowVisible
      # Set up shadow sprite
      shadow = addSprite(shaSprite, PictureOrigin::CENTER)
      shadow.setOpacity(0, 0)
      # Shadow animation
      shadow.setVisible(delay, @shadowVisible)
      shadow.moveOpacity(delay + 5, 10, 255)
    end
  end

  def createBallTrajectory(ball, destX, destY)
    # NOTE: In HGSS, there isn't a Poké Ball arc under any circumstance (neither
    #       when throwing out the first Pokémon nor when switching/replacing a
    #       fainted Pokémon). You may choose to change this.
    ball.setXY(0, destX, destY - 4)
  end
end

#===============================================================================
# Shows a Pokémon being recalled into its Poké Ball
#===============================================================================
class Battle::Scene::Animation::BattlerRecall < Battle::Scene::Animation
  include Battle::Scene::Animation::BallAnimationMixin

  def initialize(sprites, viewport, battler)
    @battler = battler
    @idxBattler = battler.index
    super(sprites, viewport)
  end

  def createProcesses
    batSprite = @sprites["pokemon_#{@idxBattler}"]
    shaSprite = @sprites["shadow_#{@idxBattler}"]
    # Calculate the Poké Ball graphic to use
    poke_ball = (batSprite.pkmn) ? batSprite.pkmn.poke_ball : nil
    # Calculate the color to turn the battler sprite
    col = getBattlerColorFromPokeBall(poke_ball)
    col.alpha = 0
    # Calculate end coordinates for battler sprite movement
    ballPos = Battle::Scene.pbBattlerPosition(@idxBattler, batSprite.sideSize)
    battlerEndX = ballPos[0]
    battlerEndY = ballPos[1]
    # Set up battler sprite
    battler = addSprite(batSprite, PictureOrigin::BOTTOM)
    battler.setVisible(0, true)
    battler.setColor(0, col)
    # Set up Poké Ball sprite
    ball = addBallSprite(battlerEndX, battlerEndY, poke_ball)
    ball.setZ(0, batSprite.z + 1)
    # Poké Ball animation
    ballOpenUp(ball, 0, poke_ball)
    delay = ball.totalDuration
    ballBurstRecall(delay, ball, battlerEndX, battlerEndY, poke_ball)
    ball.moveOpacity(10, 2, 0)
    # Battler animation
    battlerAbsorb(battler, delay, battlerEndX, battlerEndY, col)
    if shaSprite.visible
      # Set up shadow sprite
      shadow = addSprite(shaSprite, PictureOrigin::CENTER)
      # Shadow animation
      shadow.moveOpacity(0, 10, 0)
      shadow.setVisible(delay, false)
    end
  end
end

#===============================================================================
# Shows a Pokémon flashing after taking damage
#===============================================================================
class Battle::Scene::Animation::BattlerDamage < Battle::Scene::Animation
  def initialize(sprites, viewport, idxBattler, effectiveness)
    @idxBattler    = idxBattler
    @effectiveness = effectiveness
    super(sprites, viewport)
  end

  def createProcesses
    batSprite = @sprites["pokemon_#{@idxBattler}"]
    shaSprite = @sprites["shadow_#{@idxBattler}"]
    # Set up battler/shadow sprite
    battler = addSprite(batSprite, PictureOrigin::BOTTOM)
    shadow  = addSprite(shaSprite, PictureOrigin::CENTER)
    # Animation
    delay = 0
    case @effectiveness
    when 0 then battler.setSE(delay, "Battle damage normal")
    when 1 then battler.setSE(delay, "Battle damage weak")
    when 2 then battler.setSE(delay, "Battle damage super")
    end
    4.times do   # 4 flashes, each lasting 0.2 (4/20) seconds
      battler.setVisible(delay, false)
      shadow.setVisible(delay, false)
      battler.setVisible(delay + 2, true) if batSprite.visible
      shadow.setVisible(delay + 2, true) if shaSprite.visible
      delay += 4
    end
    # Restore original battler/shadow sprites visibilities
    battler.setVisible(delay, batSprite.visible)
    shadow.setVisible(delay, shaSprite.visible)
  end
end

#===============================================================================
# Shows a Pokémon fainting
#===============================================================================
class Battle::Scene::Animation::BattlerFaint < Battle::Scene::Animation
  def initialize(sprites, viewport, idxBattler, battle)
    @idxBattler = idxBattler
    @battle     = battle
    super(sprites, viewport)
  end

  def createProcesses
    batSprite = @sprites["pokemon_#{@idxBattler}"]
    shaSprite = @sprites["shadow_#{@idxBattler}"]
    # Set up battler/shadow sprite
    battler = addSprite(batSprite, PictureOrigin::BOTTOM)
    shadow  = addSprite(shaSprite, PictureOrigin::CENTER)
    # Get approx duration depending on sprite's position/size. Min 20 frames.
    battlerTop = batSprite.y - batSprite.height
    cropY = Battle::Scene.pbBattlerPosition(@idxBattler, @battle.pbSideSize(@idxBattler))[1]
    cropY += 8
    duration = (cropY - battlerTop) / 8
    duration = 10 if duration < 10   # Min 0.5 seconds
    # Animation
    # Play cry
    delay = 10
    cry = GameData::Species.cry_filename_from_pokemon(batSprite.pkmn, "_faint")
    if cry   # Play a specific faint cry
      battler.setSE(0, cry)
      delay = (GameData::Species.cry_length(batSprite.pkmn, nil, nil, "_faint") * 20).ceil
    else
      cry = GameData::Species.cry_filename_from_pokemon(batSprite.pkmn)
      if cry   # Play the regular cry at a lower pitch (75)
        battler.setSE(0, cry, nil, 75)
        delay = (GameData::Species.cry_length(batSprite.pkmn, nil, 75) * 20).ceil
      end
    end
    delay += 2
    # Sprite drops down
    shadow.setVisible(delay, false)
    battler.setSE(delay, "Pkmn faint")
    battler.moveOpacity(delay, duration, 0)
    battler.moveDelta(delay, duration, 0, cropY - battlerTop)
    battler.setCropBottom(delay, cropY)
    battler.setVisible(delay + duration, false)
    battler.setOpacity(delay + duration, 255)
  end
end

#===============================================================================
# Shows the player's Poké Ball being thrown to capture a Pokémon
#===============================================================================
class Battle::Scene::Animation::PokeballThrowCapture < Battle::Scene::Animation
  include Battle::Scene::Animation::BallAnimationMixin

  def initialize(sprites, viewport,
                 poke_ball, numShakes, critCapture, battler, showingTrainer)
    @poke_ball      = poke_ball
    @success        = numShakes >= 4
    @numShakes      = (critCapture && numShakes > 0) ? 1 : numShakes
    @critCapture    = critCapture
    @battler        = battler
    @showingTrainer = showingTrainer    # Only true if a Safari Zone battle
    @shadowVisible  = sprites["shadow_#{battler.index}"].visible
    @trainer        = battler.battle.pbPlayer
    super(sprites, viewport)
  end

  def createProcesses
    # Calculate start and end coordinates for battler sprite movement
    batSprite = @sprites["pokemon_#{@battler.index}"]
    shaSprite = @sprites["shadow_#{@battler.index}"]
    traSprite = @sprites["player_1"]
    ballPos = Battle::Scene.pbBattlerPosition(@battler.index, batSprite.sideSize)
    battlerStartX = batSprite.x
    battlerStartY = batSprite.y
    ballStartX = -6
    ballStartY = 246
    ballMidX   = 0   # Unused in arc calculation
    ballMidY   = 78
    ballEndX   = ballPos[0]
    ballEndY   = 112
    ballGroundY = ballPos[1] - 4
    # Set up Poké Ball sprite
    ball = addBallSprite(ballStartX, ballStartY, @poke_ball)
    ball.setZ(0, batSprite.z + 1)
    @ballSpriteIndex = (@success) ? @tempSprites.length - 1 : -1
    # Set up trainer sprite (only visible in Safari Zone battles)
    if @showingTrainer && traSprite && traSprite.bitmap.width >= traSprite.bitmap.height * 2
      trainer = addSprite(traSprite, PictureOrigin::BOTTOM)
      # Trainer animation
      ballStartX, ballStartY = trainerThrowingFrames(ball, trainer, traSprite)
    end
    delay = ball.totalDuration   # 0 or 7
    # Poké Ball arc animation
    if @critCapture
      ball.setSE(delay, "Battle critical catch throw")
    else
      ball.setSE(delay, "Battle throw")
    end
    createBallTrajectory(ball, delay, 16,
                         ballStartX, ballStartY, ballMidX, ballMidY, ballEndX, ballEndY)
    ball.setZ(9, batSprite.z + 1)
    ball.setSE(delay + 16, "Battle ball hit")
    # Poké Ball opens up
    delay = ball.totalDuration + 6
    ballOpenUp(ball, delay, @poke_ball, true, false)
    # Set up battler sprite
    battler = addSprite(batSprite, PictureOrigin::BOTTOM)
    # Poké Ball absorbs battler
    delay = ball.totalDuration
    ballBurstCapture(delay, ball, ballEndX, ballEndY, @poke_ball)
    # NOTE: The Pokémon does not change color while being absorbed into a Poké
    #       Ball during a capture attempt. This may be an oversight in HGSS.
    #       It's hard to spot due to the ball burst animation being played on
    #       top of it.
    battler.setSE(delay, "Battle jump to ball")
    battler.moveXY(delay, 5, ballEndX, ballEndY)
    battler.moveZoom(delay, 5, 0)
    battler.setVisible(delay + 5, false)
    if @shadowVisible
      # Set up shadow sprite
      shadow = addSprite(shaSprite, PictureOrigin::CENTER)
      # Shadow animation
      shadow.moveOpacity(delay, 5, 0)
      shadow.moveZoom(delay, 5, 0)
      shadow.setVisible(delay + 5, false)
    end
    # Poké Ball closes
    delay = ball.totalDuration
    ballSetClosed(ball, delay, @poke_ball)
    ball.moveTone(delay, 3, Tone.new(96, 64, -160, 160))
    ball.moveTone(delay + 5, 3, Tone.new(0, 0, 0, 0))
    # Poké Ball critical capture animation
    delay = ball.totalDuration + 3
    if @critCapture
      ball.setSE(delay, "Battle ball shake")
      ball.moveXY(delay, 1, ballEndX + 4, ballEndY)
      ball.moveXY(delay + 1, 2, ballEndX - 4, ballEndY)
      ball.moveXY(delay + 3, 2, ballEndX + 4, ballEndY)
      ball.setSE(delay + 4, "Battle ball shake")
      ball.moveXY(delay + 5, 2, ballEndX - 4, ballEndY)
      ball.moveXY(delay + 7, 1, ballEndX, ballEndY)
      delay = ball.totalDuration + 3
    end
    # Poké Ball drops to the ground
    4.times do |i|
      t = [4, 4, 3, 2][i]   # Time taken to rise or fall for each bounce
      d = [1, 2, 4, 8][i]   # Fraction of the starting height each bounce rises to
      delay -= t if i == 0
      if i > 0
        ball.setZoomXY(delay, 100 + (5 * (5 - i)), 100 - (5 * (5 - i)))   # Squish
        ball.moveZoom(delay, 2, 100)                      # Unsquish
        ball.moveXY(delay, t, ballEndX, ballGroundY - ((ballGroundY - ballEndY) / d))
      end
      ball.moveXY(delay + t, t, ballEndX, ballGroundY)
      ball.setSE(delay + (2 * t), "Battle ball drop", 100 - (i * 7))
      delay = ball.totalDuration
    end
    battler.setXY(ball.totalDuration, ballEndX, ballGroundY)
    # Poké Ball shakes
    delay = ball.totalDuration + 12
    [@numShakes, 3].min.times do |i|
      ball.setSE(delay, "Battle ball shake")
      ball.moveXY(delay, 2, ballEndX - (2 * (4 - i)), ballGroundY)
      ball.moveAngle(delay, 2, 5 * (4 - i))   # positive means counterclockwise
      ball.moveXY(delay + 2, 4, ballEndX + (2 * (4 - i)), ballGroundY)
      ball.moveAngle(delay + 2, 4, -5 * (4 - i))   # negative means clockwise
      ball.moveXY(delay + 6, 2, ballEndX, ballGroundY)
      ball.moveAngle(delay + 6, 2, 0)
      delay = ball.totalDuration + 8
    end
    if @success
      # Pokémon was caught
      ballCaptureSuccess(ball, delay, ballEndX, ballGroundY)
    else
      # Poké Ball opens
      ball.setZ(delay, batSprite.z - 1)
      ballOpenUp(ball, delay, @poke_ball, false)
      ballBurst(delay, ball, ballEndX, ballGroundY, @poke_ball)
      ball.moveOpacity(delay + 2, 2, 0)
      # Battler emerges
      col = getBattlerColorFromPokeBall(@poke_ball)
      col.alpha = 255
      battler.setColor(delay, col)
      battlerAppear(battler, delay, battlerStartX, battlerStartY, batSprite, col)
      if @shadowVisible
        shadow.setVisible(delay + 5, true)
        shadow.setZoom(delay + 5, 100)
        shadow.moveOpacity(delay + 5, 10, 255)
      end
    end
  end

  def dispose
    if @ballSpriteIndex >= 0
      # Capture was successful, the Poké Ball sprite should stay around after
      # this animation has finished.
      @sprites["captureBall"] = @tempSprites[@ballSpriteIndex]
      @tempSprites[@ballSpriteIndex] = nil
    end
    super
  end
end

#===============================================================================
# Shows the player throwing a Poké Ball and it being deflected
#===============================================================================
class Battle::Scene::Animation::PokeballThrowDeflect < Battle::Scene::Animation
  include Battle::Scene::Animation::BallAnimationMixin

  def initialize(sprites, viewport, poke_ball, battler)
    @poke_ball = poke_ball
    @battler   = battler
    super(sprites, viewport)
  end

  def createProcesses
    # Calculate start and end coordinates for battler sprite movement
    batSprite = @sprites["pokemon_#{@battler.index}"]
    ballPos = Battle::Scene.pbBattlerPosition(@battler.index, batSprite.sideSize)
    ballStartX = -6
    ballStartY = 246
    ballMidX   = 190   # Unused in arc calculation
    ballMidY   = 78
    ballEndX   = ballPos[0]
    ballEndY   = 112
    # Set up Poké Ball sprite
    ball = addBallSprite(ballStartX, ballStartY, @poke_ball)
    ball.setZ(0, 90)
    # Poké Ball arc animation
    ball.setSE(0, "Battle throw")
    createBallTrajectory(ball, 0, 16,
                         ballStartX, ballStartY, ballMidX, ballMidY, ballEndX, ballEndY)
    # Poké Ball knocked back
    delay = ball.totalDuration
    ball.setSE(delay, "Battle ball drop")
    ball.moveXY(delay, 8, -32, Graphics.height - 96 + 32)   # Back to player's corner
    createBallTumbling(ball, delay, 8)
  end
end
