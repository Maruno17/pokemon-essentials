using System;
using System.Collections.Generic;
using PokemonEssentials.Data;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the Battler move targeting logic (user, targets, redirection, etc.).
    /// </summary>
    public interface IBattlerUseMoveTargeting : IBattler
    {
        /// <summary>
        /// Gets the user of a move for the given choice and move.
        /// </summary>
        /// <param name="choice">The action choice.</param>
        /// <param name="move">The move being used.</param>
        /// <returns>The user battler.</returns>
        IBattler FindUser(IBattleChoice choice, IMove move);

        /// <summary>
        /// Changes the user of a move, handling Snatch and related effects.
        /// </summary>
        /// <param name="choice">The action choice.</param>
        /// <param name="move">The move being used.</param>
        /// <param name="user">The current user battler.</param>
        /// <returns>The new user battler.</returns>
        IBattler ChangeUser(IBattleChoice choice, IMove move, IBattler user);

        /// <summary>
        /// Finds the default targets for a move, based on targeting rules.
        /// </summary>
        /// <param name="choice">The action choice.</param>
        /// <param name="move">The move being used.</param>
        /// <param name="user">The user battler.</param>
        /// <returns>A list of target battlers.</returns>
        IList<IBattler> FindTargets(IBattleChoice choice, IMove move, IBattler user);

        /// <summary>
        /// Changes the targets of a move, handling redirection effects.
        /// </summary>
        /// <param name="move">The move being used.</param>
        /// <param name="user">The user battler.</param>
        /// <param name="targets">The current targets.</param>
        /// <returns>The new list of targets.</returns>
        IList<IBattler> ChangeTargets(IMove move, IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Changes the target of a move based on an ability (e.g., Lightning Rod, Storm Drain).
        /// </summary>
        /// <param name="drawingAbility">The ability that draws the move.</param>
        /// <param name="drawnType">The type of move being drawn.</param>
        /// <param name="move">The move being used.</param>
        /// <param name="user">The user battler.</param>
        /// <param name="targets">The current targets.</param>
        /// <param name="priority">The priority order of battlers.</param>
        /// <param name="nearOnly">Whether to only consider near targets.</param>
        /// <returns>The new list of targets.</returns>
        IList<IBattler> ChangeTargetByAbility(int drawingAbility, int drawnType, IMove move, IBattler user, IList<IBattler> targets, IList<IBattler> priority, bool nearOnly);

        /// <summary>
        /// Adds a target to the list of targets for a move.
        /// </summary>
        /// <param name="targets">The current list of targets.</param>
        /// <param name="user">The user battler.</param>
        /// <param name="target">The target battler.</param>
        /// <param name="move">The move being used.</param>
        /// <param name="nearOnly">Whether to only consider near targets.</param>
        /// <param name="allowUser">Whether to allow the user as a target.</param>
        /// <returns>True if the target was added, otherwise false.</returns>
        bool AddTarget(IList<IBattler> targets, IBattler user, IBattler target, IMove move, bool nearOnly = true, bool allowUser = false);

        /// <summary>
        /// Adds a random ally as a target for a move.
        /// </summary>
        /// <param name="targets">The current list of targets.</param>
        /// <param name="user">The user battler.</param>
        /// <param name="move">The move being used.</param>
        /// <param name="nearOnly">Whether to only consider near targets.</param>
        void AddTargetRandomAlly(IList<IBattler> targets, IBattler user, IMove move, bool nearOnly = true);

        /// <summary>
        /// Adds a random foe as a target for a move.
        /// </summary>
        /// <param name="targets">The current list of targets.</param>
        /// <param name="user">The user battler.</param>
        /// <param name="move">The move being used.</param>
        /// <param name="nearOnly">Whether to only consider near targets.</param>
        void AddTargetRandomFoe(IList<IBattler> targets, IBattler user, IMove move, bool nearOnly = true);
    }
}