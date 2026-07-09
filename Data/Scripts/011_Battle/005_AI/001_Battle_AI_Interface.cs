using System;
using System.Collections.Generic;
using PokemonEssentials.Data;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the main battle AI logic and handler methods.
    /// </summary>
    public interface IBattleAI
    {
        /// <summary>Gets the battle instance.</summary>
        IBattle Battle { get; }
        /// <summary>Gets the current AI trainer.</summary>
        ITrainer Trainer { get; }
        /// <summary>Gets the list of AI battlers.</summary>
        IList<IBattler> Battlers { get; }
        /// <summary>Gets the current user battler.</summary>
        IBattler User { get; }
        /// <summary>Gets the current target battler.</summary>
        IBattler Target { get; }
        /// <summary>Gets the current move being considered.</summary>
        IBattleMove Move { get; }
		/// <summary>Initializes the AI for a battle.</summary>
		IBattleAI Initialize(IBattle battle);
        /// <summary>Creates AI objects for trainers, battlers, and moves.</summary>
        void create_ai_objects();
        //void CreateAIObjects();
        /// <summary>
        /// Set some class variables for the Pokémon whose action is being chosen
        /// </summary>
        /// <remarks>
        /// Sets up the AI for the given battler index.
        /// </remarks>
        void set_up(int idxBattler);
        //void SetUp(int idxBattler);
        /// <summary>
        /// Choose an action.
        /// </summary>
        /// <remarks>
        /// Chooses an action for the enemy battler.
        /// </remarks>
        void DefaultChooseEnemyCommand(int idxBattler);
        /// <summary>Chooses a replacement Pokémon for the enemy battler.</summary>
        /// <remarks>
        /// Choose a replacement Pokémon (called directly from @battle, not part of
        /// action choosing). Must return the party index of a replacement Pokémon if
        /// possible.
        /// </remarks>
        int DefaultChooseNewEnemy(int idxBattler);
    }

    /// <summary>
    /// Interface for AI handler methods (move failure, scoring, switching, etc.).
    /// </summary>
    public interface IBattleAIHandlers
    {
        event EventHandler MoveFailureCheck;
        event EventHandler MoveFailureAgainstTargetCheck;
        event EventHandler MoveEffectScore;
        event EventHandler MoveEffectAgainstTargetScore;
        event EventHandler MoveBasePower;
        event EventHandler GeneralMoveScore;
        event EventHandler GeneralMoveAgainstTargetScore;
        event EventHandler ShouldSwitch;
        event EventHandler ShouldNotSwitch;
        event EventHandler AbilityRanking;
        event EventHandler ItemRanking;

        /// <summary>
        /// Determines if a move will fail based on its function code and arguments.
        /// </summary>
        /// <param name="functionCode">The function code of the move.</param>
        /// <param name="args">Additional arguments for the handler.</param>
        /// <returns>True if the move will fail, otherwise false.</returns>
        bool move_will_fail(string functionCode, params object[] args);
        //bool MoveWillFail(string functionCode, params object[] args);

        /// <summary>
        /// Determines if a move will fail against a specific target based on its function code and arguments.
        /// </summary>
        /// <param name="functionCode">The function code of the move.</param>
        /// <param name="args">Additional arguments for the handler.</param>
        /// <returns>True if the move will fail against the target, otherwise false.</returns>
        bool move_will_fail_against_target(string functionCode, params object[] args);
        //bool MoveWillFailAgainstTarget(string functionCode, params object[] args);

        /// <summary>
        /// Applies a move effect score modifier based on the function code and arguments.
        /// </summary>
        /// <param name="functionCode">The function code of the move.</param>
        /// <param name="score">The current score.</param>
        /// <param name="args">Additional arguments for the handler.</param>
        /// <returns>The modified score.</returns>
        int apply_move_effect_score(string functionCode, int score, params object[] args);
        //int ApplyMoveEffectScore(string functionCode, int score, params object[] args);

        /// <summary>
        /// Applies a move effect against target score modifier based on the function code and arguments.
        /// </summary>
        /// <param name="functionCode">The function code of the move.</param>
        /// <param name="score">The current score.</param>
        /// <param name="args">Additional arguments for the handler.</param>
        /// <returns>The modified score.</returns>
        int apply_move_effect_against_target_score(string functionCode, int score, params object[] args);
        //int ApplyMoveEffectAgainstTargetScore(string functionCode, int score, params object[] args);

        /// <summary>
        /// Gets the base power for a move based on its function code and arguments.
        /// </summary>
        /// <param name="functionCode">The function code of the move.</param>
        /// <param name="power">The base power.</param>
        /// <param name="args">Additional arguments for the handler.</param>
        /// <returns>The modified base power.</returns>
        int get_base_power(string functionCode, int power, params object[] args);
        //int GetBasePower(string functionCode, int power, params object[] args);

        /// <summary>
        /// Applies general move score modifiers based on arguments.
        /// </summary>
        /// <param name="score">The current score.</param>
        /// <param name="args">Additional arguments for the handler.</param>
        /// <returns>The modified score.</returns>
        int apply_general_move_score_modifiers(int score, params object[] args);
        //int ApplyGeneralMoveScoreModifiers(int score, params object[] args);

        /// <summary>
        /// Applies general move against target score modifiers based on arguments.
        /// </summary>
        /// <param name="score">The current score.</param>
        /// <param name="args">Additional arguments for the handler.</param>
        /// <returns>The modified score.</returns>
        int apply_general_move_against_target_score_modifiers(int score, params object[] args);
        //int ApplyGeneralMoveAgainstTargetScoreModifiers(int score, params object[] args);

        /// <summary>
        /// Determines if the AI should switch based on arguments.
        /// </summary>
        /// <param name="args">Arguments for the handler.</param>
        /// <returns>True if the AI should switch, otherwise false.</returns>
        bool should_switch(params object[] args);
        //bool ShouldSwitch(params object[] args);

        /// <summary>
        /// Determines if the AI should not switch based on arguments.
        /// </summary>
        /// <param name="args">Arguments for the handler.</param>
        /// <returns>True if the AI should not switch, otherwise false.</returns>
        bool should_not_switch(params object[] args);
        //bool ShouldNotSwitch(params object[] args);

        /// <summary>
        /// Modifies the ability ranking based on the ability, score, and arguments.
        /// </summary>
        /// <param name="ability">The ability to rank.</param>
        /// <param name="score">The current score.</param>
        /// <param name="args">Additional arguments for the handler.</param>
        /// <returns>The modified ability ranking score.</returns>
        int modify_ability_ranking(int ability, int score, params object[] args);
        //int ModifyAbilityRanking(int ability, int score, params object[] args);

        /// <summary>
        /// Modifies the item ranking based on the item, score, and arguments.
        /// </summary>
        /// <param name="item">The item to rank.</param>
        /// <param name="score">The current score.</param>
        /// <param name="args">Additional arguments for the handler.</param>
        /// <returns>The modified item ranking score.</returns>
        int modify_item_ranking(int item, int score, params object[] args);
        //int ModifyItemRanking(int item, int score, params object[] args);
    }
}