#===============================================================================
# AI skill levels:
#     0:     Wild Pokémon
#     1-31:  Basic trainer (young/inexperienced)
#     32-47: Medium skill
#     48-99: High skill
#     100+:  Best skill (Gym Leaders, Elite Four, Champion)
# NOTE: A trainer's skill value can range from 0-255, but by default only four
#       distinct skill levels exist. The skill value is typically the same as
#       the trainer's base money value.
#
# Skill flags:
#   PredictMoveFailure
#   ScoreMoves
#   PreferMultiTargetMoves
#===============================================================================
class Battle::AI::AITrainer
  attr_reader :side, :trainer_index
  attr_reader :skill

  def initialize(ai, side, index, trainer)
    @ai            = ai
    @side          = side
    @trainer_index = index
    @trainer       = trainer
    @skill         = 0
    @skill_flags   = []
    set_up_skill
  end

  def set_up_skill
    @skill = @trainer.skill_level if @trainer
    # TODO: Add skill flags depending on @skill.
    if @skill > 0
      @skill_flags.push("PredictMoveFailure")
      @skill_flags.push("ScoreMoves")
      @skill_flags.push("PreferMultiTargetMoves")
    end
  end

  def has_skill_flag?(flag)
    return @skill_flags.include?(flag)
  end

  # TODO: This will eventually be replaced by something else, maybe skill flags.
  def medium_skill?
    return @skill >= 32
  end

  # TODO: This will eventually be replaced by something else, maybe skill flags.
  def high_skill?
    return @skill >= 48
  end

  # TODO: This will eventually be replaced by something else, maybe skill flags.
  def best_skill?
    return @skill >= 100
  end
end
