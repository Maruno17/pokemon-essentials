#===============================================================================
#
#===============================================================================
class PokeBattle_BattlePalace < PokeBattle_Battle
  @@BattlePalaceUsualTable = [
    61,  7, 32,
    20, 25, 55,
    70, 15, 15,
    38, 31, 31,
    20, 70, 10,
    30, 20, 50,
    56, 22, 22,
    25, 15, 60,
    69,  6, 25,
    35, 10, 55,
    62, 10, 28,
    58, 37,  5,
    34, 11, 55,
    35,  5, 60,
    56, 22, 22,
    35, 45, 20,
    44, 50,  6,
    56, 22, 22,
    30, 58, 12,
    30, 13, 57,
    40, 50, 10,
    18, 70, 12,
    88,  6,  6,
    42, 50,  8,
    56, 22, 22
  ]
  @@BattlePalacePinchTable = [
    61,  7, 32,
    84,  8,  8,
    32, 60,  8,
    70, 15, 15,
    70, 22,  8,
    32, 58, 10,
    56, 22, 22,
    75, 15, 10,
    28, 55, 17,
    29,  6, 65,
    30, 20, 50,
    88,  6,  6,
    29, 11, 60,
    35, 60,  5,
    56, 22, 22,
    34, 60,  6,
    34,  6, 60,
    56, 22, 22,
    30, 58, 12,
    27,  6, 67,
    25, 62, 13,
    90,  5,  5,
    22, 20, 58,
    42,  5, 53,
    56, 22, 22
  ]

  def initialize(*arg)
    super
    @justswitched          = [false,false,false,false]
    @battleAI.battlePalace = true
  end

  def pbMoveCategory(move)
    if move.target == :User || move.function == "0D4"   # Bide
      return 1
    elsif move.statusMove? ||
       move.function == "071" || move.function == "072"   # Counter, Mirror Coat
      return 2
    else
      return 0
    end
  end

  # Different implementation of pbCanChooseMove, ignores Imprison/Torment/Taunt/Disable/Encore
  def pbCanChooseMovePartial?(idxPokemon,idxMove)
    thispkmn = @battlers[idxPokemon]
    thismove = thispkmn.moves[idxMove]
    return false if !thismove
    return false if thismove.pp<=0
    if thispkmn.effects[PBEffects::ChoiceBand] &&
       thismove.id!=thispkmn.effects[PBEffects::ChoiceBand] &&
       thispkmn.hasActiveItem?(:CHOICEBAND)
      return false
    end
    # though incorrect, just for convenience (actually checks Torment later)
    if thispkmn.effects[PBEffects::Torment] && thispkmn.lastMoveUsed
      return false if thismove.id==thispkmn.lastMoveUsed
    end
    return true
  end

  def pbPinchChange(idxPokemon)
    thispkmn = @battlers[idxPokemon]
    if !thispkmn.effects[PBEffects::Pinch] && thispkmn.status != :SLEEP &&
       thispkmn.hp<=thispkmn.totalhp/2
      nature = thispkmn.nature
      thispkmn.effects[PBEffects::Pinch] = true
      case nature
      when :QUIET, :BASHFUL, :NAIVE, :QUIRKY, :HARDY, :DOCILE, :SERIOUS
        pbDisplay(_INTL("{1} is eager for more!",thispkmn.pbThis))
      when :CAREFUL, :RASH, :LAX, :SASSY, :MILD, :TIMID
        pbDisplay(_INTL("{1} began growling deeply!",thispkmn.pbThis))
      when :GENTLE, :ADAMANT, :HASTY, :LONELY, :RELAXED, :NAUGHTY
        pbDisplay(_INTL("A glint appears in {1}'s eyes!",thispkmn.pbThis(true)))
      when :JOLLY, :BOLD, :BRAVE, :CALM, :IMPISH, :MODEST
        pbDisplay(_INTL("{1} is getting into position!",thispkmn.pbThis))
      end
    end
  end

  def pbRegisterMove(idxBattler,idxMove,_showMessages=true)
    this_battler = @battlers[idxBattler]
    if idxMove==-2
      @choices[idxBattler][0] = :UseMove   # Move
      @choices[idxBattler][1] = -2         # "Incapable of using its power..."
      @choices[idxBattler][2] = @struggle
      @choices[idxBattler][3] = -1
    else
      @choices[idxBattler][0] = :UseMove                      # Move
      @choices[idxBattler][1] = idxMove                       # Index of move
      @choices[idxBattler][2] = this_battler.moves[idxMove]   # Move object
      @choices[idxBattler][3] = -1                            # No target chosen
    end
  end

  def pbAutoFightMenu(idxBattler)
    this_battler = @battlers[idxBattler]
    nature = this_battler.nature
    randnum = @battleAI.pbAIRandom(100)
    category = 0
    atkpercent = 0
    defpercent = 0
    if this_battler.effects[PBEffects::Pinch]
      atkpercent = @@BattlePalacePinchTable[nature*3]
      defpercent = atkpercent+@@BattlePalacePinchTable[nature*3+1]
    else
      atkpercent = @@BattlePalaceUsualTable[nature*3]
      defpercent = atkpercent+@@BattlePalaceUsualTable[nature*3+1]
    end
    if randnum<atkpercent
      category = 0
    elsif randnum<defpercent
      category = 1
    else
      category = 2
    end
    moves = []
    for i in 0...this_battler.moves.length
      next if !pbCanChooseMovePartial?(idxBattler,i)
      next if pbMoveCategory(this_battler.moves[i])!=category
      moves[moves.length] = i
    end
    if moves.length==0
      # No moves of selected category
      pbRegisterMove(idxBattler,-2)
    else
      chosenmove = moves[@battleAI.pbAIRandom(moves.length)]
      pbRegisterMove(idxBattler,chosenmove)
    end
    return true
  end

  def pbEndOfRoundPhase
    super
    return if @decision!=0
    for i in 0...4
      pbPinchChange(i) if !@battlers[i].fainted?
    end
  end
end



#===============================================================================
#
#===============================================================================
class PokeBattle_AI
  attr_accessor :battlePalace

  alias _battlePalace_initialize initialize

  def initialize(*arg)
    _battlePalace_initialize(*arg)
    @justswitched = [false,false,false,false]
  end

  alias _battlePalace_pbEnemyShouldWithdraw? pbEnemyShouldWithdraw?

  def pbEnemyShouldWithdraw?(idxBattler)
    return _battlePalace_pbEnemyShouldWithdraw?(idxBattler) if !@battlePalace
    thispkmn = @battle.battlers[idxBattler]
    shouldswitch = false
    if thispkmn.effects[PBEffects::PerishSong]==1
      shouldswitch = true
    elsif !@battle.pbCanChooseAnyMove?(idxBattler) &&
       thispkmn.turnCount && thispkmn.turnCount>5
      shouldswitch = true
    else
      hppercent = thispkmn.hp*100/thispkmn.totalhp
      percents = []
      maxindex = -1
      maxpercent = 0
      factor = 0
      @battle.pbParty(idxBattler).each_with_index do |pkmn,i|
        if @battle.pbCanSwitch?(idxBattler,i)
          percents[i] = 100*pkmn.hp/pkmn.totalhp
          if percents[i]>maxpercent
            maxindex = i
            maxpercent = percents[i]
          end
        else
          percents[i] = 0
        end
      end
      if hppercent<50
        factor = (maxpercent<hppercent) ? 20 : 40
      end
      if hppercent<25
        factor = (maxpercent<hppercent) ? 30 : 50
      end
      case thispkmn.status
      when :SLEEP, :FROZEN
        factor += 20
      when :POISON, :BURN
        factor += 10
      when :PARALYSIS
        factor += 15
      end
      if @justswitched[idxBattler]
        factor -= 60
        factor = 0 if factor<0
      end
      shouldswitch = (pbAIRandom(100)<factor)
      if shouldswitch && maxindex>=0
        @battle.pbRegisterSwitch(idxBattler,maxindex)
        return true
      end
    end
    @justswitched[idxBattler] = shouldswitch
    if shouldswitch
      @battle.pbParty(idxBattler).each_with_index do |_pkmn,i|
        next if !@battle.pbCanSwitch?(idxBattler,i)
        @battle.pbRegisterSwitch(idxBattler,i)
        return true
      end
    end
    return false
  end
end
