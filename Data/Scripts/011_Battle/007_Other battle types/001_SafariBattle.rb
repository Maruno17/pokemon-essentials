#===============================================================================
# Simple battler class for the wild Pokémon in a Safari Zone battle
#===============================================================================
class Battle::FakeBattler
  attr_reader :battle
  attr_reader :index
  attr_reader :pokemon
  attr_reader :owned

  def initialize(battle, index)
    @battle  = battle
    @pokemon = battle.party2[0]
    @index   = index
  end

  def pokemonIndex;   return 0;                     end
  def species;        return @pokemon.species;      end
  def gender;         return @pokemon.gender;       end
  def status;         return @pokemon.status;       end
  def hp;             return @pokemon.hp;           end
  def level;          return @pokemon.level;        end
  def name;           return @pokemon.name;         end
  def totalhp;        return @pokemon.totalhp;      end
  def displayGender;  return @pokemon.gender;       end
  def shiny?;         return @pokemon.shiny?;       end
  def super_shiny?;   return @pokemon.super_shiny?; end

  def isSpecies?(check_species)
    return @pokemon&.isSpecies?(check_species)
  end

  def fainted?;       return false; end
  def shadowPokemon?; return false; end
  def hasMega?;       return false; end
  def mega?;          return false; end
  def hasPrimal?;     return false; end
  def primal?;        return false; end
  def captured;       return false; end
  def captured=(value); end

  def owned?
    return $player.owned?(pokemon.species)
  end

  def pbThis(lowerCase = false)
    return (lowerCase) ? _INTL("the wild {1}", name) : _INTL("The wild {1}", name)
  end

  def opposes?(i)
    i = i.index if i.is_a?(Battle::FakeBattler)
    return (@index & 1) != (i & 1)
  end

  def pbReset; end
end



#===============================================================================
# Data box for safari battles
#===============================================================================
class Battle::Scene::SafariDataBox < Sprite
  attr_accessor :selected

  def initialize(battle, viewport = nil)
    super(viewport)
    @selected    = 0
    @battle      = battle
    @databox     = AnimatedBitmap.new("Graphics/Pictures/Battle/databox_safari")
    self.x       = Graphics.width - 232
    self.y       = Graphics.height - 184
    @contents    = BitmapWrapper.new(@databox.width, @databox.height)
    self.bitmap  = @contents
    self.visible = false
    self.z       = 50
    pbSetSystemFont(self.bitmap)
    refresh
  end

  def refresh
    self.bitmap.clear
    self.bitmap.blt(0, 0, @databox.bitmap, Rect.new(0, 0, @databox.width, @databox.height))
    base   = Color.new(72, 72, 72)
    shadow = Color.new(184, 184, 184)
    textpos = []
    textpos.push([_INTL("Safari Balls"), 30, 14, false, base, shadow])
    textpos.push([_INTL("Left: {1}", @battle.ballCount), 30, 44, false, base, shadow])
    pbDrawTextPositions(self.bitmap, textpos)
  end

  def update(frameCounter = 0)
    super()
  end
end



#===============================================================================
# Shows the player throwing bait at a wild Pokémon in a Safari battle.
#===============================================================================
class Battle::Scene::Animation::ThrowBait < Battle::Scene::Animation
  include Battle::Scene::Animation::BallAnimationMixin

  def initialize(sprites, viewport, battler)
    @battler = battler
    @trainer = battler.battle.pbGetOwnerFromBattlerIndex(battler.index)
    super(sprites, viewport)
  end

  def createProcesses
    # Calculate start and end coordinates for battler sprite movement
    batSprite = @sprites["pokemon_#{@battler.index}"]
    traSprite = @sprites["player_1"]
    ballPos = Battle::Scene.pbBattlerPosition(@battler.index, batSprite.sideSize)
    ballStartX = traSprite.x
    ballStartY = traSprite.y - (traSprite.bitmap.height / 2)
    ballMidX   = 0   # Unused in arc calculation
    ballMidY   = 122
    ballEndX   = ballPos[0] - 40
    ballEndY   = ballPos[1] - 4
    # Set up trainer sprite
    trainer = addSprite(traSprite, PictureOrigin::BOTTOM)
    # Set up bait sprite
    ball = addNewSprite(ballStartX, ballStartY,
                        "Graphics/Battle animations/safari_bait", PictureOrigin::CENTER)
    ball.setZ(0, batSprite.z + 1)
    # Trainer animation
    if traSprite.bitmap.width >= traSprite.bitmap.height * 2
      ballStartX, ballStartY = trainerThrowingFrames(ball, trainer, traSprite)
    end
    delay = ball.totalDuration   # 0 or 7
    # Bait arc animation
    ball.setSE(delay, "Battle throw")
    createBallTrajectory(ball, delay, 12,
                         ballStartX, ballStartY, ballMidX, ballMidY, ballEndX, ballEndY)
    ball.setZ(9, batSprite.z + 1)
    delay = ball.totalDuration
    ball.moveOpacity(delay + 8, 2, 0)
    ball.setVisible(delay + 10, false)
    # Set up battler sprite
    battler = addSprite(batSprite, PictureOrigin::BOTTOM)
    # Show Pokémon jumping before eating the bait
    delay = ball.totalDuration + 3
    2.times do
      battler.setSE(delay, "player jump")
      battler.moveDelta(delay, 3, 0, -16)
      battler.moveDelta(delay + 4, 3, 0, 16)
      delay = battler.totalDuration + 1
    end
    # Show Pokémon eating the bait
    delay = battler.totalDuration + 3
    2.times do
      battler.moveAngle(delay, 7, 5)
      battler.moveDelta(delay, 7, 0, 6)
      battler.moveAngle(delay + 7, 7, 0)
      battler.moveDelta(delay + 7, 7, 0, -6)
      delay = battler.totalDuration
    end
  end
end



#===============================================================================
# Shows the player throwing a rock at a wild Pokémon in a Safari battle.
#===============================================================================
class Battle::Scene::Animation::ThrowRock < Battle::Scene::Animation
  include Battle::Scene::Animation::BallAnimationMixin

  def initialize(sprites, viewport, battler)
    @battler = battler
    @trainer = battler.battle.pbGetOwnerFromBattlerIndex(battler.index)
    super(sprites, viewport)
  end

  def createProcesses
    # Calculate start and end coordinates for battler sprite movement
    batSprite = @sprites["pokemon_#{@battler.index}"]
    traSprite = @sprites["player_1"]
    ballStartX = traSprite.x
    ballStartY = traSprite.y - (traSprite.bitmap.height / 2)
    ballMidX   = 0   # Unused in arc calculation
    ballMidY   = 122
    ballEndX   = batSprite.x
    ballEndY   = batSprite.y - (batSprite.bitmap.height / 2)
    # Set up trainer sprite
    trainer = addSprite(traSprite, PictureOrigin::BOTTOM)
    # Set up bait sprite
    ball = addNewSprite(ballStartX, ballStartY,
                        "Graphics/Battle animations/safari_rock", PictureOrigin::CENTER)
    ball.setZ(0, batSprite.z + 1)
    # Trainer animation
    if traSprite.bitmap.width >= traSprite.bitmap.height * 2
      ballStartX, ballStartY = trainerThrowingFrames(ball, trainer, traSprite)
    end
    delay = ball.totalDuration   # 0 or 7
    # Bait arc animation
    ball.setSE(delay, "Battle throw")
    createBallTrajectory(ball, delay, 12,
                         ballStartX, ballStartY, ballMidX, ballMidY, ballEndX, ballEndY)
    ball.setZ(9, batSprite.z + 1)
    delay = ball.totalDuration
    ball.setSE(delay, "Battle damage weak")
    ball.moveOpacity(delay + 2, 2, 0)
    ball.setVisible(delay + 4, false)
    # Set up anger sprite
    anger = addNewSprite(ballEndX - 42, ballEndY - 36,
                         "Graphics/Battle animations/safari_anger", PictureOrigin::CENTER)
    anger.setVisible(0, false)
    anger.setZ(0, batSprite.z + 1)
    # Show anger appearing
    delay = ball.totalDuration + 5
    2.times do
      anger.setSE(delay, "Player jump")
      anger.setVisible(delay, true)
      anger.moveZoom(delay, 3, 130)
      anger.moveZoom(delay + 3, 3, 100)
      anger.setVisible(delay + 6, false)
      anger.setDelta(delay + 6, 96, -16)
      delay = anger.totalDuration + 3
    end
  end
end



#===============================================================================
# Safari Zone battle scene (the visuals of the battle)
#===============================================================================
class Battle::Scene
  def pbSafariStart
    @briefMessage = false
    @sprites["dataBox_0"] = SafariDataBox.new(@battle, @viewport)
    dataBoxAnim = Animation::DataBoxAppear.new(@sprites, @viewport, 0)
    loop do
      dataBoxAnim.update
      pbUpdate
      break if dataBoxAnim.animDone?
    end
    dataBoxAnim.dispose
    pbRefresh
  end

  def pbSafariCommandMenu(index)
    pbCommandMenuEx(index,
                    [_INTL("What will\n{1} throw?", @battle.pbPlayer.name),
                     _INTL("Ball"),
                     _INTL("Bait"),
                     _INTL("Rock"),
                     _INTL("Run")], 3)
  end

  def pbThrowBait
    @briefMessage = false
    baitAnim = Animation::ThrowBait.new(@sprites, @viewport, @battle.battlers[1])
    loop do
      baitAnim.update
      pbUpdate
      break if baitAnim.animDone?
    end
    baitAnim.dispose
  end

  def pbThrowRock
    @briefMessage = false
    rockAnim = Animation::ThrowRock.new(@sprites, @viewport, @battle.battlers[1])
    loop do
      rockAnim.update
      pbUpdate
      break if rockAnim.animDone?
    end
    rockAnim.dispose
  end

  alias __safari__pbThrowSuccess pbThrowSuccess unless method_defined?(:__safari__pbThrowSuccess)

  def pbThrowSuccess
    __safari__pbThrowSuccess
    pbWildBattleSuccess if @battle.is_a?(SafariBattle)
  end
end



#===============================================================================
# Safari Zone battle class
#===============================================================================
class SafariBattle
  attr_reader   :battlers         # Array of fake battler objects
  attr_accessor :sideSizes        # Array of number of battlers per side
  attr_accessor :backdrop         # Filename fragment used for background graphics
  attr_accessor :backdropBase     # Filename fragment used for base graphics
  attr_accessor :time             # Time of day (0=day, 1=eve, 2=night)
  attr_accessor :environment      # Battle surroundings (for mechanics purposes)
  attr_reader   :weather
  attr_reader   :player
  attr_accessor :party2
  attr_accessor :canRun           # True if player can run from battle
  attr_accessor :canLose          # True if player won't black out if they lose
  attr_accessor :switchStyle      # Switch/Set "battle style" option
  attr_accessor :showAnims        # "Battle scene" option (show anims)
  attr_accessor :expGain          # Whether Pokémon can gain Exp/EVs
  attr_accessor :moneyGain        # Whether the player can gain/lose money
  attr_accessor :rules
  attr_accessor :ballCount

  include Battle::CatchAndStoreMixin

  def pbRandom(x); return rand(x); end

  #=============================================================================
  # Initialize the battle class
  #=============================================================================
  def initialize(scene, player, party2)
    @scene         = scene
    @peer          = Battle::Peer.new
    @backdrop      = ""
    @backdropBase  = nil
    @time          = 0
    @environment   = :None   # e.g. Tall grass, cave, still water
    @weather       = :None
    @decision      = 0
    @caughtPokemon = []
    @player        = [player]
    @party2        = party2
    @sideSizes     = [1, 1]
    @battlers      = [Battle::FakeBattler.new(self, 0),
                      Battle::FakeBattler.new(self, 1)]
    @rules         = {}
    @ballCount     = 0
  end

  def disablePokeBalls=(value); end
  def sendToBoxes=(value); end
  def defaultWeather=(value); @weather = value; end
  def defaultTerrain=(value); end

  #=============================================================================
  # Information about the type and size of the battle
  #=============================================================================
  def wildBattle?;    return true;  end
  def trainerBattle?; return false; end

  def setBattleMode(mode); end

  def pbSideSize(index)
    return @sideSizes[index % 2]
  end

  #=============================================================================
  # Trainers and owner-related
  #=============================================================================
  def pbPlayer; return @player[0]; end
  def opponent; return nil;        end

  def pbGetOwnerFromBattlerIndex(idxBattler); return pbPlayer; end

  def pbSetSeen(battler)
    return if !battler || !@internalBattle
    if battler.is_a?(Battle::Battler)
      pbPlayer.pokedex.register(battler.displaySpecies, battler.displayGender,
                                battler.displayForm, battler.shiny?)
    else
      pbPlayer.pokedex.register(battler)
    end
  end

  def pbSetCaught(battler)
    return if !battler || !@internalBattle
    if battler.is_a?(Battle::Battler)
      pbPlayer.pokedex.register_caught(battler.displaySpecies)
    else
      pbPlayer.pokedex.register_caught(battler.species)
    end
  end

  #=============================================================================
  # Get party info (counts all teams on the same side)
  #=============================================================================
  def pbParty(idxBattler)
    return (opposes?(idxBattler)) ? @party2 : nil
  end

  def pbAllFainted?(idxBattler = 0); return false; end

  #=============================================================================
  # Battler-related
  #=============================================================================
  def opposes?(idxBattler1, idxBattler2 = 0)
    idxBattler1 = idxBattler1.index if idxBattler1.respond_to?("index")
    idxBattler2 = idxBattler2.index if idxBattler2.respond_to?("index")
    return (idxBattler1 & 1) != (idxBattler2 & 1)
  end

  def pbRemoveFromParty(idxBattler, idxParty); end
  def pbGainExp; end

  #=============================================================================
  # Messages and animations
  #=============================================================================
  def pbDisplay(msg, &block)
    @scene.pbDisplayMessage(msg, &block)
  end

  def pbDisplayPaused(msg, &block)
    @scene.pbDisplayPausedMessage(msg, &block)
  end

  def pbDisplayBrief(msg)
    @scene.pbDisplayMessage(msg, true)
  end

  def pbDisplayConfirm(msg)
    return @scene.pbDisplayConfirmMessage(msg)
  end



  class BattleAbortedException < Exception; end

  def pbAbort
    raise BattleAbortedException.new("Battle aborted")
  end

  #=============================================================================
  # Safari battle-specific methods
  #=============================================================================
  def pbEscapeRate(catch_rate)
    return 125 if catch_rate <= 45   # Escape factor 9 (45%)
    return 100 if catch_rate <= 60   # Escape factor 7 (35%)
    return 75 if catch_rate <= 120   # Escape factor 5 (25%)
    return 50 if catch_rate <= 250   # Escape factor 3 (15%)
    return 25                        # Escape factor 2 (10%)
  end

  def pbStartBattle
    begin
      pkmn = @party2[0]
      pbSetSeen(pkmn)
      @scene.pbStartBattle(self)
      pbDisplayPaused(_INTL("Wild {1} appeared!", pkmn.name))
      @scene.pbSafariStart
      weather_data = GameData::BattleWeather.try_get(@weather)
      @scene.pbCommonAnimation(weather_data.animation) if weather_data
      safariBall = GameData::Item.get(:SAFARIBALL).id
      catch_rate = pkmn.species_data.catch_rate
      catchFactor  = (catch_rate * 100) / 1275
      catchFactor  = [[catchFactor, 3].max, 20].min
      escapeFactor = (pbEscapeRate(catch_rate) * 100) / 1275
      escapeFactor = [[escapeFactor, 2].max, 20].min
      loop do
        cmd = @scene.pbSafariCommandMenu(0)
        case cmd
        when 0   # Ball
          if pbBoxesFull?
            pbDisplay(_INTL("The boxes are full! You can't catch any more Pokémon!"))
            next
          end
          @ballCount -= 1
          @scene.pbRefresh
          rare = (catchFactor * 1275) / 100
          if safariBall
            pbThrowPokeBall(1, safariBall, rare, true)
            if @caughtPokemon.length > 0
              pbRecordAndStoreCaughtPokemon
              @decision = 4
            end
          end
        when 1   # Bait
          pbDisplayBrief(_INTL("{1} threw some bait at the {2}!", self.pbPlayer.name, pkmn.name))
          @scene.pbThrowBait
          catchFactor  /= 2 if pbRandom(100) < 90   # Harder to catch
          escapeFactor /= 2                       # Less likely to escape
        when 2   # Rock
          pbDisplayBrief(_INTL("{1} threw a rock at the {2}!", self.pbPlayer.name, pkmn.name))
          @scene.pbThrowRock
          catchFactor  *= 2                       # Easier to catch
          escapeFactor *= 2 if pbRandom(100) < 90   # More likely to escape
        when 3   # Run
          pbSEPlay("Battle flee")
          pbDisplayPaused(_INTL("You got away safely!"))
          @decision = 3
        else
          next
        end
        catchFactor  = [[catchFactor, 3].max, 20].min
        escapeFactor = [[escapeFactor, 2].max, 20].min
        # End of round
        if @decision == 0
          if @ballCount <= 0
            pbDisplay(_INTL("PA: You have no Safari Balls left! Game over!"))
            @decision = 2
          elsif pbRandom(100) < 5 * escapeFactor
            pbSEPlay("Battle flee")
            pbDisplay(_INTL("{1} fled!", pkmn.name))
            @decision = 3
          elsif cmd == 1   # Bait
            pbDisplay(_INTL("{1} is eating!", pkmn.name))
          elsif cmd == 2   # Rock
            pbDisplay(_INTL("{1} is angry!", pkmn.name))
          else
            pbDisplay(_INTL("{1} is watching carefully!", pkmn.name))
          end
          # Weather continues
          weather_data = GameData::BattleWeather.try_get(@weather)
          @scene.pbCommonAnimation(weather_data.animation) if weather_data
        end
        break if @decision > 0
      end
      @scene.pbEndBattle(@decision)
    rescue BattleAbortedException
      @decision = 0
      @scene.pbEndBattle(@decision)
    end
    return @decision
  end
end
