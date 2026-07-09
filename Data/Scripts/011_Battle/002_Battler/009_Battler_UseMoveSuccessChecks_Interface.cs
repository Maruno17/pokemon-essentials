using System;
using System.Collections.Generic;
using PokemonEssentials.Data;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the Battler move success checks (can choose, obedience, try use, etc.).
    /// <para>Handles all logic for determining whether a move can be chosen, whether a battler will obey, and whether a move will succeed or fail due to status, effects, or protections. Also manages failure messaging and per-hit/per-target checks.</para>
    /// </summary>
    public interface IBattlerUseMoveSuccessChecks : IBattler
    {
        /// <summary>
        /// Checks if the battler can choose the given move, considering disables, Heal Block, Gravity, Taunt, Torment, Imprison, Assault Vest, and other effects.
        /// </summary>
        /// <remarks>
        /// Decide whether the trainer is allowed to tell the Pokémon to use the given
        /// move. Called when choosing a command for the round.
        /// Also called when processing the Pokémon's action, because these effects also
        /// prevent Pokémon action. Relevant because these effects can become active
        /// earlier in the same round (after choosing the command but before using the
        /// move) or an unusable move may be called by another move such as Metronome.
        /// </remarks>
        /// <param name="move">The move to check.</param>
        /// <param name="commandPhase">Whether this is the command phase.</param>
        /// <param name="showMessages">Whether to show messages for failure.</param>
        /// <param name="specialUsage">Whether this is a special usage context (e.g., called by another move).</param>
        /// <returns>True if the move can be chosen, otherwise false.</returns>
        bool CanChooseMove(IMove move, bool commandPhase, bool showMessages = true, bool specialUsage = false);

        /// <summary>
        /// Checks obedience for the battler's action choice, including badge level, foreign Pokémon, and Hyper Mode.
        /// Returns true if the Pokémon will continue attacking, or false if it will disobey.
        /// </summary>
        /// <param name="choice">The action choice.</param>
        /// <returns>True if the battler obeys, otherwise false.</returns>
        bool ObedienceCheck(IBattleChoice choice);

        /// <summary>
        /// Handles disobedience logic for the battler, including ignoring orders, falling asleep, hurting itself, or doing nothing.
        /// </summary>
        /// <param name="choice">The action choice.</param>
        /// <param name="badge_level">The badge level for obedience.</param>
        /// <returns>True if the battler does something else, otherwise false.</returns>
        bool Disobey(IBattleChoice choice, int badge_level);

        /// <summary>
        /// Checks if the battler can try to use the given move, considering all status effects, Truant, flinching, confusion, paralysis, infatuation, and obedience.
        /// Returns true if the move can be used, otherwise false.
        /// </summary>
        /// <remarks>
        /// Check whether the user (self) is able to take action at all.
        /// If this returns true, and if PP isn't a problem, the move will be considered
        /// to have been used (even if it then fails for whatever reason).
        /// </remarks>
        /// <param name="choice">The action choice.</param>
        /// <param name="move">The move to use.</param>
        /// <param name="specialUsage">Whether this is a special usage context.</param>
        /// <param name="skipAccuracyCheck">Whether to skip the accuracy check (e.g., for certain move calls).</param>
        /// <returns>True if the move can be used, otherwise false.</returns>
        bool TryUseMove(IBattleChoice choice, IMove move, bool specialUsage, bool skipAccuracyCheck);

        /// <summary>
        /// Performs the initial success check against a target, including move-specific failure conditions, protections, type immunities, and field effects.
        /// </summary>
        /// <remarks>
        /// Initial success check against the target. Done once before the first hit.
        /// Includes move-specific failure conditions, protections and type immunities.
        /// </remarks>
        /// <param name="move">The move being used.</param>
        /// <param name="user">The user of the move.</param>
        /// <param name="target">The target of the move.</param>
        /// <param name="targets">The list of all targets.</param>
        /// <returns>True if the move can affect the target, otherwise false.</returns>
        bool SuccessCheckAgainstTarget(IMove move, IBattler user, IBattler target, IList<IBattler> targets);

        /// <summary>
        /// Checks whether the user can hit a semi-invulnerable target (e.g., Dig, Fly, Dive), considering Lock-On, No Guard, and other effects.
        /// </summary>
        /// <param name="move">The move being used.</param>
        /// <param name="user">The user of the move.</param>
        /// <param name="target">The target of the move.</param>
        /// <returns>True if the target can be hit, otherwise false.</returns>
        bool SuccessCheckSemiInvulnerable(IMove move, IBattler user, IBattler target);

        /// <summary>
        /// Performs the per-hit success check against a target, including semi-invulnerable state and accuracy calculation.
        /// </summary>
        /// <remarks>
        /// Per-hit success check against the target.
        /// Includes semi-invulnerable move use and accuracy calculation.
        /// </remarks>
        /// <param name="move">The move being used.</param>
        /// <param name="user">The user of the move.</param>
        /// <param name="target">The target of the move.</param>
        /// <param name="skipAccuracyCheck">Whether to skip the accuracy check.</param>
        /// <returns>True if the hit succeeds, otherwise false.</returns>
        bool SuccessCheckPerHit(IMove move, IBattler user, IBattler target, bool skipAccuracyCheck);

        /// <summary>
        /// Displays the appropriate message when a move fails to hit a target, including affection, multi-target, and standard miss messages.
        /// </summary>
        /// <remarks>
        /// Message shown when a move fails the per-hit success check above.
        /// </remarks>
        /// <param name="move">The move being used.</param>
        /// <param name="user">The user of the move.</param>
        /// <param name="target">The target of the move.</param>
        void MissMessage(IMove move, IBattler user, IBattler target);
    }
}