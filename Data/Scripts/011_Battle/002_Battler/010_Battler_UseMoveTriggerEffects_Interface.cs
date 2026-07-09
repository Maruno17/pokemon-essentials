using System;
using System.Collections.Generic;
using PokemonEssentials.Data;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the Battler move trigger effects (on hit, after move, etc.).
    /// </summary>
    public interface IBattlerUseMoveTriggerEffects : IBattler
    {
        /// <summary>
        /// Triggers effects when making a hit with a move.
        /// </summary>
        /// <param name="move">The move being used.</param>
        /// <param name="user">The user battler.</param>
        /// <param name="target">The target battler.</param>
        void EffectsOnMakingHit(IMove move, IBattler user, IBattler target);

        /// <summary>
        /// Triggers effects after a move is used, for all targets and the user.
        /// </summary>
        /// <param name="user">The user battler.</param>
        /// <param name="targets">The list of target battlers.</param>
        /// <param name="move">The move being used.</param>
        /// <param name="numHits">The number of hits the move made.</param>
        void EffectsAfterMove(IBattler user, IList<IBattler> targets, IMove move, int numHits);

        /// <summary>
        /// Triggers additional effects after a move is used, negated by Sheer Force.
        /// </summary>
        /// <param name="user">The user battler.</param>
        /// <param name="targets">The list of target battlers.</param>
        /// <param name="move">The move being used.</param>
        /// <param name="numHits">The number of hits the move made.</param>
        /// <param name="switched_battlers">Indices of battlers that were switched out.</param>
        void EffectsAfterMove2(IBattler user, IList<IBattler> targets, IMove move, int numHits, IList<int> switched_battlers);

        /// <summary>
        /// Triggers further effects after a move is used, for user's held item that switches it out.
        /// </summary>
        /// <param name="user">The user battler.</param>
        /// <param name="targets">The list of target battlers.</param>
        /// <param name="move">The move being used.</param>
        /// <param name="numHits">The number of hits the move made.</param>
        /// <param name="switched_battlers">Indices of battlers that were switched out.</param>
        void EffectsAfterMove3(IBattler user, IList<IBattler> targets, IMove move, int numHits, IList<int> switched_battlers);
    }
}