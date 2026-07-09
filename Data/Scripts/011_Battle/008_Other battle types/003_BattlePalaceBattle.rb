#===============================================================================
#
#===============================================================================
class BattlePalaceBattle < Battle
  # Percentage chances of choosing attack, defense, support moves
  @@BattlePalaceUsualTable = {
    :HARDY   => [61,  7, 32],
    :LONELY  => [20, 25, 55],
    :BRAVE   => [70, 15, 15],
    :ADAMANT => [38, 31, 31],
    :NAUGHTY => [20, 70, 10],
    :BOLD    => [30, 20, 50],
    :DOCILE  => [56, 22, 22],
    :RELAXED => [25, 15, 60],
    :IMPISH  => [69,  6, 25],
    :LAX     => [35, 10, 55],
    :TIMID   => [62, 10, 28],
    :HASTY   => [58, 37,  5],
    :SERIOUS => [34, 11, 55],
    :JOLLY   => [35,  5, 60],
    :NAIVE   => [56, 22, 22],
    :MODEST  => [35, 45, 20],
    :MILD    => [44, 50,  6],
    :QUIET   => [56, 22, 22],
    :BASHFUL => [30, 58, 12],
    :RASH    => [30, 13, 57],
    :CALM    => [40, 50, 10],
    :GENTLE  => [18, 70, 12],
    :SASSY   => [88,  6,  6],
    :CAREFUL => [42, 50,  8],
    :QUIRKY  => [56, 22, 22]
  }
  @@BattlePalacePinchTable = {
    :HARDY   => [61,  7, 32],
    :LONELY  => [84,  8,  8],
    :BRAVE   => [32, 60,  8],
    :ADAMANT => [70, 15, 15],
    :NAUGHTY => [70, 22,  8],
    :BOLD    => [32, 58, 10],
    :DOCILE  => [56, 22, 22],
    :RELAXED => [75, 15, 10],
    :IMPISH  => [28, 55, 17],
    :LAX     => [29,  6, 65],
    :TIMID   => [30, 20, 50],
    :HASTY   => [88,  6,  6],
    :SERIOUS => [29, 11, 60],
    :JOLLY   => [35, 60,  5],
    :NAIVE   => [56, 22, 22],
    :MODEST  => [34, 60,  6],
    :MILD    => [34,  6, 60],
    :QUIET   => [56, 22, 22],
    :BASHFUL => [30, 58, 12],
    :RASH    => [27,  6, 67],
    :CALM    => [25, 62, 13],
    :GENTLE  => [90,  5,  5],
    :SASSY   => [22, 20, 58],
    :CAREFUL => [42,  5, 53],
    :QUIRKY  => [56, 22, 22]
  }

  def initialize(*arg)
    super
    @justswitched          = [false, false, false, false]
    @battleAI.battlePalace = true
  end

  def pbMoveCategory(move)
    if move.target == :User || move.function_code == "MultiTurnAttackBideThenReturnDoubleDamage"
      return 1
    elsif move.statusMove? ||
          move.function_code == "CounterPhysicalDamage" || move.function_code == "CounterSpecialDamage"
      return 2
    else
      return 0
    end
  end

  # Different implementation of pbCanChooseMove, ignores Imprison/Torment/Taunt/Disable/Encore
  def pbCanChooseMovePartial?(idxPokemon, idxMove)
    thispkmn = @battlers[idxPokemon]
    thismove = thispkmn.moves[idxMove]
    return false if !thismove
    return false if thismove.pp <= 0
    if thispkmn.effects[PBEffects::ChoiceBand] &&
       thismove.id != thispkmn.effects[PBEffects::ChoiceBand] &&
       thispkmn.hasActiveItem?(:CHOICEBAND)
      return false
    end
    # though incorrect, just for convenience (actually checks Torment later)
    if thispkmn.effects[PBEffects::Torment] &&
       thispkmn.lastMoveUsed && thismove.id == thispkmn.lastMoveUsed
      return false
    end
    return true
  end

  def pbRegisterMove(idxBattler, idxMove, _showMessages = true)
    this_battler = @battlers[idxBattler]
    @choices[idxBattler][0] = :UseMove
    @choices[idxBattler][1] = idxMove   # Index of move to be used (-2="Incapable of using its power...")
    @choices[idxBattler][2] = (idxMove == -2) ? @struggle : this_battler.moves[idxMove]   # Battle::Move object
    @choices[idxBattler][3] = -1   # No target chosen yet
  end

  def pbAutoFightMenu(idxBattler)
    this_battler = @battlers[idxBattler]
    nature = this_battler.nature.id
    randnum = @battleAI.pbAIRandom(100)
    category = 0
    atkpercent = 0
    defpercent = 0
    if this_battler.effects[PBEffects::Pinch]
      atkpercent = @@BattlePalacePinchTable[nature][0]
      defpercent = atkpercent + @@BattlePalacePinchTable[nature][1]
    else
      atkpercent = @@BattlePalaceUsualTable[nature][0]
      defpercent = atkpercent + @@BattlePalaceUsualTable[nature][1]
    end
    if randnum < atkpercent
      category = 0
    elsif randnum < atkpercent + defpercent
      category = 1
    else
      category = 2
    end
    moves = []
    this_battler.moves.length.times do |i|
      next if !pbCanChooseMovePartial?(idxBattler, i)
      next if pbMoveCategory(this_battler.moves[i]) != category
      moves[moves.length] = i
    end
    if moves.length == 0
      # No moves of selected category
      pbRegisterMove(idxBattler, -2)
    else
      chosenmove = moves[@battleAI.pbAIRandom(moves.length)]
      pbRegisterMove(idxBattler, chosenmove)
    end
    return true
  end

  def pbPinchChange(battler)
    return if !battler || battler.fainted?
    return if battler.effects[PBEffects::Pinch] || battler.status == :SLEEP
    return if battler.hp > battler.totalhp / 2
    nature = battler.nature.id
    battler.effects[PBEffects::Pinch] = true
    case nature
    when :QUIET, :BASHFUL, :NAIVE, :QUIRKY, :HARDY, :DOCILE, :SERIOUS
      pbDisplay(_INTL("{1} is eager for more!", battler.pbThis))
    when :CAREFUL, :RASH, :LAX, :SASSY, :MILD, :TIMID
      pbDisplay(_INTL("{1} began growling deeply!", battler.pbThis))
    when :GENTLE, :ADAMANT, :HASTY, :LONELY, :RELAXED, :NAUGHTY
      pbDisplay(_INTL("A glint appears in {1}'s eyes!", battler.pbThis(true)))
    when :JOLLY, :BOLD, :BRAVE, :CALM, :IMPISH, :MODEST
      pbDisplay(_INTL("{1} is getting into position!", battler.pbThis))
    end
  end

  def pbEndOfRoundPhase
    super
    return if decided?
    allBattlers.each { |b| pbPinchChange(b) }
  end
end

#===============================================================================
#
#===============================================================================
class Battle::AI
  attr_accessor :battlePalace

  alias _battlePalace_initialize initialize unless private_method_defined?(:_battlePalace_initialize)

  def initialize(*arg)
    _battlePalace_initialize(*arg)
    @justswitched = [false, false, false, false]
  end

  unless method_defined?(:_battlePalace_pbChooseToSwitchOut)
    alias _battlePalace_pbChooseToSwitchOut pbChooseToSwitchOut
  end

  def pbChooseToSwitchOut(force_switch = false)
    return _battlePalace_pbChooseToSwitchOut(force_switch) if !@battlePalace
    thispkmn = @user
    idxBattler = @user.index
    shouldswitch = false
    if thispkmn.effects[PBEffects::PerishSong] == 1
      shouldswitch = true
    elsif !@battle.pbCanChooseAnyMove?(idxBattler) &&
          thispkmn.turnCount && thispkmn.turnCount > 5
      shouldswitch = true
    else
      hppercent = thispkmn.hp * 100 / thispkmn.totalhp
      percents = []
      maxindex = -1
      maxpercent = 0
      factor = 0
      @battle.pbParty(idxBattler).each_with_index do |pkmn, i|
        if @battle.pbCanSwitch?(idxBattler, i)
          percents[i] = 100 * pkmn.hp / pkmn.totalhp
          if percents[i] > maxpercent
            maxindex = i
            maxpercent = percents[i]
          end
        else
          percents[i] = 0
        end
      end
      if hppercent < 50
        factor = (maxpercent < hppercent) ? 20 : 40
      end
      if hppercent < 25
        factor = (maxpercent < hppercent) ? 30 : 50
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
        factor = 0 if factor < 0
      end
      shouldswitch = (pbAIRandom(100) < factor)
      if shouldswitch && maxindex >= 0
        @battle.pbRegisterSwitch(idxBattler, maxindex)
        return true
      end
    end
    @justswitched[idxBattler] = shouldswitch
    if shouldswitch
      @battle.pbParty(idxBattler).each_with_index do |_pkmn, i|
        next if !@battle.pbCanSwitch?(idxBattler, i)
        @battle.pbRegisterSwitch(idxBattler, i)
        return true
      end
    end
    return false
  end
end
