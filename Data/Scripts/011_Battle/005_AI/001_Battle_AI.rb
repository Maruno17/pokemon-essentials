#===============================================================================
#
#===============================================================================
class Battle::AI
  attr_reader :battle
  attr_reader :trainer
  attr_reader :battlers
  attr_reader :user, :target, :move

  def initialize(battle)
    @battle = battle
  end

  def create_ai_objects
    # Initialize AI trainers
    @trainers = [[], []]
    @battle.player.each_with_index do |trainer, i|
      @trainers[0][i] = AITrainer.new(self, 0, i, trainer)
    end
    if @battle.wildBattle?
      @trainers[1][0] = AITrainer.new(self, 1, 0, nil)
    else
      @battle.opponent.each_with_index do |trainer, i|
        @trainers[1][i] = AITrainer.new(self, 1, i, trainer)
      end
    end
    # Initialize AI battlers
    @battlers = []
    @battle.battlers.each_with_index do |battler, i|
      @battlers[i] = AIBattler.new(self, i) if battler
    end
    # Initialize AI move object
    @move = AIMove.new(self)
  end

  # Set some class variables for the Pokémon whose action is being chosen
  def set_up(idxBattler)
    # Find the AI trainer choosing the action
    opposes = @battle.opposes?(idxBattler)
    trainer_index = @battle.pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @trainer = @trainers[(opposes) ? 1 : 0][trainer_index]
    # Find the AI battler for which the action is being chosen
    @user = @battlers[idxBattler]
    @battlers.each { |b| b.refresh_battler if b }
  end

  # Choose an action.
  def pbDefaultChooseEnemyCommand(idxBattler)
    set_up(idxBattler)
    ret = false
    PBDebug.logonerr { ret = pbChooseToSwitchOut }
    if ret
      PBDebug.log("")
      return
    end
    ret = false
    PBDebug.logonerr { ret = pbChooseToUseItem }
    if ret
      PBDebug.log("")
      return
    end
    if @battle.pbAutoFightMenu(idxBattler)
      PBDebug.log("")
      return
    end
    @battle.pbRegisterMegaEvolution(idxBattler) if pbEnemyShouldMegaEvolve?
    choices = pbGetMoveScores
    pbChooseMove(choices)
    PBDebug.log("")
  end

  # Choose a replacement Pokémon (called directly from @battle, not part of
  # action choosing). Must return the party index of a replacement Pokémon if
  # possible.
  def pbDefaultChooseNewEnemy(idxBattler)
    set_up(idxBattler)
    return choose_best_replacement_pokemon(idxBattler, true)
  end
end

#===============================================================================
#
#===============================================================================
module Battle::AI::Handlers
  MoveFailureCheck              = HandlerHash.new
  MoveFailureAgainstTargetCheck = HandlerHash.new
  MoveEffectScore               = HandlerHash.new
  MoveEffectAgainstTargetScore  = HandlerHash.new
  MoveBasePower                 = HandlerHash.new
  GeneralMoveScore              = HandlerHash.new
  GeneralMoveAgainstTargetScore = HandlerHash.new
  ShouldSwitch                  = HandlerHash.new
  ShouldNotSwitch               = HandlerHash.new
  AbilityRanking                = AbilityHandlerHash.new
  ItemRanking                   = ItemHandlerHash.new

  def self.move_will_fail?(function_code, *args)
    return MoveFailureCheck.trigger(function_code, *args) || false
  end

  def self.move_will_fail_against_target?(function_code, *args)
    return MoveFailureAgainstTargetCheck.trigger(function_code, *args) || false
  end

  def self.apply_move_effect_score(function_code, score, *args)
    ret = MoveEffectScore.trigger(function_code, score, *args)
    return (ret.nil?) ? score : ret
  end

  def self.apply_move_effect_against_target_score(function_code, score, *args)
    ret = MoveEffectAgainstTargetScore.trigger(function_code, score, *args)
    return (ret.nil?) ? score : ret
  end

  def self.get_base_power(function_code, power, *args)
    ret = MoveBasePower.trigger(function_code, power, *args)
    return (ret.nil?) ? power : ret
  end

  def self.apply_general_move_score_modifiers(score, *args)
    GeneralMoveScore.each do |id, score_proc|
      new_score = score_proc.call(score, *args)
      score = new_score if new_score
    end
    return score
  end

  def self.apply_general_move_against_target_score_modifiers(score, *args)
    GeneralMoveAgainstTargetScore.each do |id, score_proc|
      new_score = score_proc.call(score, *args)
      score = new_score if new_score
    end
    return score
  end

  def self.should_switch?(*args)
    ret = false
    ShouldSwitch.each do |id, switch_proc|
      ret ||= switch_proc.call(*args)
      break if ret
    end
    return ret
  end

  def self.should_not_switch?(*args)
    ret = false
    ShouldNotSwitch.each do |id, switch_proc|
      ret ||= switch_proc.call(*args)
      break if ret
    end
    return ret
  end

  def self.modify_ability_ranking(ability, score, *args)
    ret = AbilityRanking.trigger(ability, score, *args)
    return (ret.nil?) ? score : ret
  end

  def self.modify_item_ranking(item, score, *args)
    ret = ItemRanking.trigger(item, score, *args)
    return (ret.nil?) ? score : ret
  end
end
