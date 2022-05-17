#===============================================================================
#
#===============================================================================
class BattleChallenge
  attr_reader :currentChallenge

  BattleTowerID   = 0
  BattlePalaceID  = 1
  BattleArenaID   = 2
  BattleFactoryID = 3

  def initialize
    @bc = BattleChallengeData.new
    @currentChallenge = -1
    @types = {}
  end

  def set(id, numrounds, rules)
    @id = id
    @numRounds = numrounds
    @rules = rules
    register(id, id[/double/], 3,
             id[/^factory/] ? BattleFactoryID : BattleTowerID,
             id[/open$/] ? 1 : 0)
    pbWriteCup(id, rules)
  end

  def register(id, doublebattle, numPokemon, battletype, mode = 1)
    ensureType(id)
    if battletype == BattleFactoryID
      @bc.setExtraData(BattleFactoryData.new(@bc))
      numPokemon = 3
      battletype = BattleTowerID
    end
    @rules = modeToRules(doublebattle, numPokemon, battletype, mode) if !@rules
  end

  def rules
    if !@rules
      @rules = modeToRules(self.data.doublebattle, self.data.numPokemon,
                           self.data.battletype, self.data.mode)
    end
    return @rules
  end

  def modeToRules(doublebattle, numPokemon, battletype, mode)
    rules = PokemonChallengeRules.new
    # Set the battle type
    case battletype
    when BattlePalaceID
      rules.setBattleType(BattlePalace.new)
    when BattleArenaID
      rules.setBattleType(BattleArena.new)
      doublebattle = false
    else   # Factory works the same as Tower
      rules.setBattleType(BattleTower.new)
    end
    # Set standard rules and maximum level
    case mode
    when 1      # Open Level
      rules.setRuleset(StandardRules.new(numPokemon, GameData::GrowthRate.max_level))
      rules.setLevelAdjustment(OpenLevelAdjustment.new(30))
    when 2   # Battle Tent
      rules.setRuleset(StandardRules.new(numPokemon, GameData::GrowthRate.max_level))
      rules.setLevelAdjustment(OpenLevelAdjustment.new(60))
    else
      rules.setRuleset(StandardRules.new(numPokemon, 50))
      rules.setLevelAdjustment(OpenLevelAdjustment.new(50))
    end
    # Set whether battles are single or double
    if doublebattle
      rules.addBattleRule(DoubleBattle.new)
    else
      rules.addBattleRule(SingleBattle.new)
    end
    return rules
  end

  def start(*args)
    t = ensureType(@id)
    @currentChallenge = @id   # must appear before pbStart
    @bc.pbStart(t, @numRounds)
  end

  def pbStart(challenge)
  end

  def pbEnd
    if @currentChallenge != -1
      ensureType(@currentChallenge).saveWins(@bc)
      @currentChallenge = -1
    end
    @bc.pbEnd
  end

  def pbBattle
    return @bc.extraData.pbBattle(self) if @bc.extraData   # Battle Factory
    opponent = pbGenerateBattleTrainer(self.nextTrainer, self.rules)
    bttrainers = pbGetBTTrainers(@id)
    trainerdata = bttrainers[self.nextTrainer]
    opponent.lose_text = pbGetMessageFromHash(MessageTypes::EndSpeechLose, trainerdata[4])
    opponent.win_text = pbGetMessageFromHash(MessageTypes::EndSpeechWin, trainerdata[3])
    ret = pbOrganizedBattleEx(opponent, self.rules)
    return ret
  end

  def pbInChallenge?
    return pbInProgress?
  end

  def pbInProgress?
    return @bc.inProgress
  end

  def pbResting?
    return @bc.resting
  end

  def extra;        @bc.extraData;    end
  def decision;     @bc.decision;     end
  def wins;         @bc.wins;         end
  def swaps;        @bc.swaps;        end
  def battleNumber; @bc.battleNumber; end
  def nextTrainer;  @bc.nextTrainer;  end
  def pbGoOn;       @bc.pbGoOn;       end
  def pbAddWin;     @bc.pbAddWin;     end
  def pbCancel;     @bc.pbCancel;     end
  def pbRest;       @bc.pbRest;       end
  def pbMatchOver?; @bc.pbMatchOver?; end
  def pbGoToStart;  @bc.pbGoToStart;  end

  def setDecision(value)
    @bc.decision = value
  end

  def setParty(value)
    @bc.setParty(value)
  end

  def data
    return nil if !pbInProgress? || @currentChallenge < 0
    return ensureType(@currentChallenge).clone
  end

  def getCurrentWins(challenge)
    return ensureType(challenge).currentWins
  end

  def getPreviousWins(challenge)
    return ensureType(challenge).previousWins
  end

  def getMaxWins(challenge)
    return ensureType(challenge).maxWins
  end

  def getCurrentSwaps(challenge)
    return ensureType(challenge).currentSwaps
  end

  def getPreviousSwaps(challenge)
    return ensureType(challenge).previousSwaps
  end

  def getMaxSwaps(challenge)
    return ensureType(challenge).maxSwaps
  end

  private

  def ensureType(id)
    @types[id] = BattleChallengeType.new if !@types[id]
    return @types[id]
  end
end

#===============================================================================
#
#===============================================================================
class BattleChallengeData
  attr_reader   :battleNumber
  attr_reader   :numRounds
  attr_reader   :party
  attr_reader   :inProgress
  attr_reader   :resting
  attr_reader   :wins
  attr_reader   :swaps
  attr_accessor :decision
  attr_reader   :extraData

  def initialize
    reset
  end

  def setExtraData(value)
    @extraData = value
  end

  def setParty(value)
    $player.party = value if @inProgress
    @party = value
  end

  def pbStart(t, numRounds)
    @inProgress   = true
    @resting      = false
    @decision     = 0
    @swaps        = t.currentSwaps
    @wins         = t.currentWins
    @battleNumber = 1
    @trainers     = []
    raise _INTL("Number of rounds is 0 or less.") if numRounds <= 0
    @numRounds = numRounds
    # Get all the trainers for the next set of battles
    btTrainers = pbGetBTTrainers(pbBattleChallenge.currentChallenge)
    while @trainers.length < @numRounds
      newtrainer = pbBattleChallengeTrainer(@wins + @trainers.length, btTrainers)
      found = false
      @trainers.each do |tr|
        found = true if tr == newtrainer
      end
      @trainers.push(newtrainer) if !found
    end
    @start = [$game_map.map_id, $game_player.x, $game_player.y]
    @oldParty = $player.party
    $player.party = @party if @party
    Game.save(safe: true)
  end

  def pbGoToStart
    if $scene.is_a?(Scene_Map)
      $game_temp.player_transferring  = true
      $game_temp.player_new_map_id    = @start[0]
      $game_temp.player_new_x         = @start[1]
      $game_temp.player_new_y         = @start[2]
      $game_temp.player_new_direction = 8
      $scene.transfer_player
    end
  end

  def pbAddWin
    return if !@inProgress
    @battleNumber += 1
    @wins += 1
  end

  def pbAddSwap
    @swaps += 1 if @inProgress
  end

  def pbMatchOver?
    return true if !@inProgress || @decision != 0
    return @battleNumber > @numRounds
  end

  def pbRest
    return if !@inProgress
    @resting = true
    pbSaveInProgress
  end

  def pbGoOn
    return if !@inProgress
    @resting = false
    pbSaveInProgress
  end

  def pbCancel
    $player.party = @oldParty if @oldParty
    reset
  end

  def pbEnd
    $player.party = @oldParty
    return if !@inProgress
    save = (@decision != 0)
    reset
    $game_map.need_refresh = true
    Game.save(safe: true) if save
  end

  def nextTrainer
    return @trainers[@battleNumber - 1]
  end

  private

  def reset
    @inProgress   = false
    @resting      = false
    @start        = nil
    @decision     = 0
    @wins         = 0
    @swaps        = 0
    @battleNumber = 0
    @trainers     = []
    @oldParty     = nil
    @party        = nil
    @extraData    = nil
  end

  def pbSaveInProgress
    oldmapid     = $game_map.map_id
    oldx         = $game_player.x
    oldy         = $game_player.y
    olddirection = $game_player.direction
    $game_map.map_id = @start[0]
    $game_player.moveto2(@start[1], @start[2])
    $game_player.direction = 8   # facing up
    Game.save(safe: true)
    $game_map.map_id = oldmapid
    $game_player.moveto2(oldx, oldy)
    $game_player.direction = olddirection
  end
end

#===============================================================================
#
#===============================================================================
class BattleChallengeType
  attr_accessor :currentWins
  attr_accessor :previousWins
  attr_accessor :maxWins
  attr_accessor :currentSwaps
  attr_accessor :previousSwaps
  attr_accessor :maxSwaps
  attr_reader   :doublebattle
  attr_reader   :numPokemon
  attr_reader   :battletype
  attr_reader   :mode

  def initialize
    @previousWins  = 0
    @maxWins       = 0
    @currentWins   = 0
    @currentSwaps  = 0
    @previousSwaps = 0
    @maxSwaps      = 0
  end

  def saveWins(challenge)
    if challenge.decision == 0     # if undecided
      @currentWins  = 0
      @currentSwaps = 0
    else
      if challenge.decision == 1   # if won
        @currentWins  = challenge.wins
        @currentSwaps = challenge.swaps
      else                       # if lost
        @currentWins  = 0
        @currentSwaps = 0
      end
      @maxWins       = [@maxWins, challenge.wins].max
      @previousWins  = challenge.wins
      @maxSwaps      = [@maxSwaps, challenge.swaps].max
      @previousSwaps = challenge.swaps
    end
  end
end

#===============================================================================
# Battle Factory data
#===============================================================================
class BattleFactoryData
  def initialize(bcdata)
    @bcdata = bcdata
  end

  def pbPrepareRentals
    @rentals = pbBattleFactoryPokemon(pbBattleChallenge.rules, @bcdata.wins, @bcdata.swaps, [])
    @trainerid = @bcdata.nextTrainer
    bttrainers = pbGetBTTrainers(pbBattleChallenge.currentChallenge)
    trainerdata = bttrainers[@trainerid]
    @opponent = NPCTrainer.new(
      pbGetMessageFromHash(MessageTypes::TrainerNames, trainerdata[1]),
      trainerdata[0]
    )
    @opponent.lose_text = pbGetMessageFromHash(MessageTypes::EndSpeechLose, trainerdata[4])
    @opponent.win_text = pbGetMessageFromHash(MessageTypes::EndSpeechWin, trainerdata[3])
    opponentPkmn = pbBattleFactoryPokemon(pbBattleChallenge.rules, @bcdata.wins, @bcdata.swaps, @rentals)
    @opponent.party = opponentPkmn.sample(3)
  end

  def pbChooseRentals
    pbFadeOutIn {
      scene = BattleSwapScene.new
      screen = BattleSwapScreen.new(scene)
      @rentals = screen.pbStartRent(@rentals)
      @bcdata.pbAddSwap
      @bcdata.setParty(@rentals)
    }
  end

  def pbPrepareSwaps
    @oldopponent = @opponent.party
    trainerid = @bcdata.nextTrainer
    bttrainers = pbGetBTTrainers(pbBattleChallenge.currentChallenge)
    trainerdata = bttrainers[trainerid]
    @opponent = NPCTrainer.new(
      pbGetMessageFromHash(MessageTypes::TrainerNames, trainerdata[1]),
      trainerdata[0]
    )
    @opponent.lose_text = pbGetMessageFromHash(MessageTypes::EndSpeechLose, trainerdata[4])
    @opponent.win_text = pbGetMessageFromHash(MessageTypes::EndSpeechWin, trainerdata[3])
    opponentPkmn = pbBattleFactoryPokemon(pbBattleChallenge.rules, @bcdata.wins, @bcdata.swaps,
                                          [].concat(@rentals).concat(@oldopponent))
    @opponent.party = opponentPkmn.sample(3)
  end

  def pbChooseSwaps
    swapMade = true
    pbFadeOutIn {
      scene = BattleSwapScene.new
      screen = BattleSwapScreen.new(scene)
      swapMade = screen.pbStartSwap(@rentals, @oldopponent)
      @bcdata.pbAddSwap if swapMade
      @bcdata.setParty(@rentals)
    }
    return swapMade
  end

  def pbBattle(challenge)
    bttrainers = pbGetBTTrainers(pbBattleChallenge.currentChallenge)
    trainerdata = bttrainers[@trainerid]
    return pbOrganizedBattleEx(@opponent, challenge.rules)
  end
end
