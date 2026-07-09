namespace PokemonEssentials
{
    /// <summary>
    /// Interface for AI trainer skill and flag logic.
    /// </summary>
    /// <remarks>
    /// AI skill levels:
    ///     0:     Wild Pokémon
    ///     1-31:  Basic trainer (young/inexperienced)
    ///     32-47: Medium skill
    ///     48-99: High skill
    ///     100+:  Best skill (Gym Leaders, Elite Four, Champion)
    /// NOTE: A trainer's skill value can range from 0-255, but by default only four
    ///       distinct skill levels exist. The skill value is typically the same as
    ///       the trainer's base money value.
    ///
    /// Skill flags:
    ///   PredictMoveFailure
    ///   ScoreMoves
    ///   PreferMultiTargetMoves
    ///   HPAware (considers HP values of user/target for "worth it?" score changes)
    ///   ConsiderSwitching (can choose to switch out Pokémon)
    ///   ReserveLastPokemon (don't switch it in if possible)
    ///   UsePokemonInOrder (uses earliest-listed Pokémon possible)
    ///
    /// Anti-skill flags are skill flags with "Anti" at the beginning. An "AntiXYZ"
    /// flag will negate the corresponding "XYZ" flag.
    /// </remarks>
    public interface IAITrainer
    {
        /// <summary>Gets the side index (0=player, 1=opponent).</summary>
        int Side { get; }
        /// <summary>Gets the trainer index.</summary>
        int TrainerIndex { get; }
        /// <summary>Gets the skill level of the trainer.</summary>
        int Skill { get; }
        IAITrainer initialize(IBattleAI ai, int side, int index, ITrainer trainer);
        void set_up_skill();
        void set_up_skill_flags();
        /// <summary>Checks if the trainer has a specific skill flag.</summary>
        bool HasSkillFlag(string flag);
        /// <summary>Returns true if the trainer is at least medium skill.</summary>
        bool MediumSkill();
        /// <summary>Returns true if the trainer is at least high skill.</summary>
        bool HighSkill();
        /// <summary>Returns true if the trainer is at best skill.</summary>
        bool BestSkill();
        //bool BestSkill { get; }
    }
}