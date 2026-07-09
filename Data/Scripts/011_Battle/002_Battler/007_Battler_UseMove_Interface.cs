using System;
using System.Collections.Generic;
using PokemonEssentials.Data;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the Battler move usage logic (turn processing, move execution, etc.).
    /// </summary>
    public interface IBattlerUseMove : IBattler
    {
        /// <summary>
        /// Processes the battler's turn, handling all possible actions.
        /// </summary>
        /// <param name="choice">The action choice for the turn.</param>
        /// <param name="tryFlee">Whether to attempt fleeing if possible.</param>
        /// <returns>True if the turn was processed, otherwise false.</returns>
        bool ProcessTurn(IBattleChoice choice, bool tryFlee = true);

        /// <summary>
        /// Begins the battler's turn, resetting temporary effects.
        /// </summary>
        /// <param name="choice">The action choice for the turn.</param>
        void BeginTurn(IBattleChoice choice);

        /// <summary>
        /// Cancels the use of multi-turn moves and related effects.
        /// </summary>
        /// <param name="full_cancel">Whether to fully cancel all effects.</param>
        void CancelMoves(bool full_cancel = false);

        /// <summary>
        /// Ends the battler's turn, updating state and triggering end-of-turn effects.
        /// </summary>
        /// <param name="choice">The action choice for the turn.</param>
        void EndTurn(IBattleChoice choice);

        /// <summary>
        /// Deals confusion damage to the battler and triggers related effects.
        /// </summary>
        /// <param name="msg">The message to display.</param>
        void ConfusionDamage(string msg);

        /// <summary>
        /// Uses a move in a simple context (e.g., called by another move or Future Sight).
        /// </summary>
        /// <param name="moveID">The ID of the move to use.</param>
        /// <param name="target">The target index.</param>
        /// <param name="idxMove">The index of the move in the moveset.</param>
        /// <param name="specialUsage">Whether this is a special usage context.</param>
        void UseMoveSimple(string moveID, int target = -1, int idxMove = -1, bool specialUsage = true);

        /// <summary>
        /// Master method for using a move, handling all move logic and effects.
        /// </summary>
        /// <param name="choice">The action choice for the move.</param>
        /// <param name="specialUsage">Whether this is a special usage context.</param>
        void UseMove(IBattleChoice choice, bool specialUsage = false);

        /// <summary>
        /// Processes a move hit, checking accuracy and applying effects.
        /// </summary>
        /// <param name="move">The move to process.</param>
        /// <param name="user">The user of the move.</param>
        /// <param name="targets">The targets of the move.</param>
        /// <param name="hitNum">The hit number of the move.</param>
        /// <param name="skipAccuracyCheck">Whether to skip accuracy checks.</param>
        /// <returns>True if the move hit, otherwise false.</returns>
        bool ProcessMoveHit(IMove move, IBattler user, IList<IBattler> targets, int hitNum, bool skipAccuracyCheck);
    }
}