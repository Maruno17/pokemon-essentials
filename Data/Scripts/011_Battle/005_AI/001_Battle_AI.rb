#===============================================================================
#
#===============================================================================
class Battle::AI
  attr_reader :battle
  attr_reader :trainer
  attr_reader :user, :target, :move

  def initialize(battle)
    @battle = battle

    # TODO: Move this elsewhere?
    @roles   = [Array.new(@battle.pbParty(0).length) { |i| determine_roles(0, i) },
                Array.new(@battle.pbParty(1).length) { |i| determine_roles(1, i) }]
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
    @user.refresh_battler
  end

  # Choose an action.
  def pbDefaultChooseEnemyCommand(idxBattler)
    set_up(idxBattler)
    return if pbEnemyShouldWithdraw?
    return if pbEnemyShouldUseItem?
    return if @battle.pbAutoFightMenu(idxBattler)
    @battle.pbRegisterMegaEvolution(idxBattler) if pbEnemyShouldMegaEvolve?
    choices = pbGetMoveScores
    pbChooseMove(choices)
  end
end

#===============================================================================
#
#===============================================================================
module Battle::AI::Handlers
  MoveEffectScore  = HandlerHash.new
  MoveBasePower    = HandlerHash.new
  MoveFailureCheck = HandlerHash.new
  GeneralMoveScore = HandlerHash.new
  # Move type
  # Move accuracy
  # Move target
  # Move additional effect chance
  # Move unselectable check
  # Move failure check

  def self.move_will_fail?(function_code, *args)
    return MoveFailureCheck.trigger(function_code, *args) || false
  end

  def self.apply_move_effect_score(function_code, score, *args)
    ret = MoveEffectScore.trigger(function_code, score, *args)
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
end
