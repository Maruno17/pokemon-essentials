using System;
using System.Collections;
using System.Collections.Generic;
using PokemonEssentials.Data;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for a collection of event handlers that can be used to customize the AI's decision-making process for special-case move scoring handlers.
    /// </summary>
    /// Interface for AI logic related to special-case move scoring handlers.
    // Actual handler registration and invocation is typically done via delegates or events in C#.
    //public interface IAIMoveOtherScores
    public interface IBattleAIMoveScoreHandler
    {
        /// <summary>
        /// Don't prefer hitting a wild shiny Pokémon.
        /// </summary>
        bool GeneralMoveAgainstTargetScore_shiny_target(int score, IBattleMove move, IBattler user, IBattler target, IBattleAI ai, IBattle battle);
        /// <summary>
        /// Prefer Shadow moves (for flavour).
        /// </summary>
        bool GeneralMoveScore_shadow_moves(int score, IBattleMove move, IBattler user, IBattleAI ai, IBattle battle);
        /// <summary>
        /// If user is frozen, prefer a move that can thaw the user.
        /// </summary>
        bool GeneralMoveScore_thawing_move_when_frozen(int score, IBattleMove move, IBattler user, IBattleAI ai, IBattle battle);
        /// <summary>
        /// Prefer using a priority move if the user is slower than the target and...
        /// - the user is at low HP, or
        /// - the target is predicted to be knocked out by the move.
        /// </summary>
        bool GeneralMoveAgainstTargetScore_priority_move_against_faster_target(int score, IBattleMove move, IBattler user, IBattleAI ai, IBattle battle);
        /// <summary>
        /// Don't prefer a move that can be Magic Coated if the target (or any foe if the
        /// move doesn't have a target) knows Magic Coat/has Magic Bounce.
        /// </summary>
        bool GeneralMoveAgainstTargetScore_target_can_Magic_Coat_or_Bounce_move(int score, IBattleMove move, IBattler user, IBattleAI ai, IBattle battle);
        /// <summary>
        ///
        /// </summary>
        bool GeneralMoveScore_any_foe_can_Magic_Coat_or_Bounce_move(int score, IBattleMove move, IBattler user, IBattleAI ai, IBattle battle);
        /// <summary>
        /// Don't prefer a move that can be Snatched if any other battler knows Snatch.
        /// </summary>
        bool GeneralMoveScore_any_battler_can_Snatch_move(int score, IBattleMove move, IBattler user, IBattleAI ai, IBattle battle);
        /// <summary>
        /// Pick a good move for the Choice items.
        /// </summary>
        bool GeneralMoveScore_good_move_for_choice_item(int score, IBattleMove move, IBattler user, IBattleAI ai, IBattle battle);
        /// <summary>
        /// Prefer damaging moves if the foe is down to their last Pokémon (opportunistic).
        /// Prefer damaging moves if the AI is down to its last Pokémon but the foe has
        /// more (desperate).
        /// </summary>
        bool GeneralMoveScore_damaging_move_and_either_side_no_reserves(int score, IBattleMove move, IBattler user, IBattleAI ai, IBattle battle);
        /// <summary>
        /// Don't prefer Fire-type moves if target knows Powder and is faster than the
        /// user.
        /// </summary>
        bool GeneralMoveScore_target_can_powder_fire_moves(int score, IBattleMove move, IBattler user, IBattleAI ai, IBattle battle);
        /// <summary>
        /// Don't prefer moves if target knows a move that can make them Electric-type,
        /// and if target is unaffected by Electric moves.
        /// </summary>
        bool GeneralMoveAgainstTargetScore_target_can_make_moves_Electric_and_be_immune(int score, IBattleMove move, IBattler user, IBattleAI ai, IBattle battle);
        /// <summary>
        ///
        /// </summary>
        //bool GeneralMoveAgainstTargetScore_(int score, IBattleMove move, IBattler user, IBattleAI ai, IBattle battle);
        /// <summary>
        ///
        /// </summary>
        //bool GeneralMoveAgainstTargetScore_(int score, IBattleMove move, IBattler user, IBattleAI ai, IBattle battle);
    }
}