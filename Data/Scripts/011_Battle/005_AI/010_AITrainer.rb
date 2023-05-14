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
#   HPAware (considers HP values of user/target for "worth it?" score changes)
#   ConsiderSwitching (can choose to switch out Pokémon)
#   ReserveLastPokemon (don't switch it in if possible)
#   UsePokemonInOrder (uses earliest-listed Pokémon possible)
#
# Anti-skill flags are skill flags with "Anti" at the beginning. An "AntiXYZ"
# flag will negate the corresponding "XYZ" flag.
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
    set_up_skill_flags
    sanitize_skill_flags
  end

  def set_up_skill
    if @trainer
      @skill = @trainer.skill_level
    elsif Settings::SMARTER_WILD_LEGENDARY_POKEMON
      # Give wild legendary/mythical Pokémon a higher skill
      wild_battler = @ai.battle.battlers[@side]
      sp_data = wild_battler.pokemon.species_data
      if sp_data.has_flag?("Legendary") ||
         sp_data.has_flag?("Mythical") ||
         sp_data.has_flag?("UltraBeast")
        @skill = 32   # Medium skill
      end
    end
  end

  def set_up_skill_flags
    if @trainer
      @trainer.flags.each { |flag| @skill_flags.push(flag) }
    end
    if @skill > 0
      @skill_flags.push("PredictMoveFailure")
      @skill_flags.push("ScoreMoves")
      @skill_flags.push("PreferMultiTargetMoves")
    end
    if medium_skill?
      @skill_flags.push("ConsiderSwitching")
      @skill_flags.push("HPAware")
    end
    if !medium_skill?
      @skill_flags.push("UsePokemonInOrder")
    elsif best_skill?
      @skill_flags.push("ReserveLastPokemon")
    end
  end

  def sanitize_skill_flags
    # NOTE: Any skill flag which is shorthand for multiple other skill flags
    #       should be "unpacked" here.
    # Remove any skill flag "XYZ" if there is also an "AntiXYZ" skill flag
    @skill_flags.each_with_index do |flag, i|
      @skill_flags[i] = nil if @skill_flags.include?("Anti" + flag)
    end
    @skill_flags.compact!
  end

  def has_skill_flag?(flag)
    return @skill_flags.include?(flag)
  end

  def medium_skill?
    return @skill >= 32
  end

  def high_skill?
    return @skill >= 48
  end

  def best_skill?
    return @skill >= 100
  end
end
