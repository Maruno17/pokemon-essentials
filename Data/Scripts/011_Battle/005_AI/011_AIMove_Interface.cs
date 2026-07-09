using System.Collections.Generic;
using PokemonEssentials.Data;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for AI move logic and properties.
    /// </summary>
    public interface IAIBattleMove
    {
        /// <summary>Gets the underlying move object.</summary>
        IBattleMove move { get; }
        /// <summary>Sets up the move for AI evaluation.</summary>
        /// <param name="move">The move to set up.</param>
        void set_up(IMove move);
        /// <summary>Gets the move's ID.</summary>
        int id { get; }
        /// <summary>Gets the move's name.</summary>
        string name { get; }
        /// <summary>Returns true if the move is physical (optionally for a given type).</summary>
        /// <param name="thisType">Optional: the type to check.</param>
        bool physicalMove(int? thisType = null);
        /// <summary>Returns true if the move is special (optionally for a given type).</summary>
        /// <param name="thisType">Optional: the type to check.</param>
        bool specialMove(int? thisType = null);
        /// <summary>Returns true if the move is damaging.</summary>
        bool damagingMove();
        /// <summary>Returns true if the move is a status move.</summary>
        bool statusMove();
        /// <summary>Gets the move's function code.</summary>
        string function_code { get; }
        /// <summary>Gets the move's type.</summary>
        int type { get; }
        /// <summary>Gets the rough type of the move for AI evaluation.</summary>
        int rough_type();
        /// <summary>Gets the move's target data for a given user.</summary>
        /// <param name="user">The user battler.</param>
        ITarget Target(IAIBattler user);
        /// <summary>
        /// Returns whether this move targets multiple battlers.
        /// </summary>
        /// <returns>
        /// Returns true if the move targets multiple battlers.
        /// </returns>
        bool targets_multiple_battlers();
        /// <summary>Gets the rough priority of the move for a given user.</summary>
        /// <param name="user">The user battler.</param>
        int rough_priority(IAIBattler user);
        /// <summary>
        /// Returns this move's base power, taking into account various effects that
        /// modify it.
        /// </summary>
        /// <remarks>
        /// Gets the base power of the move.
        /// </remarks>
        int base_power();
        /// <summary>
        /// Full damage calculation.
        /// </summary>
        /// <remarks>
        /// Gets the rough damage estimate for the move.
        /// </remarks>
        int rough_damage();
        /// <summary>Gets the move's accuracy.</summary>
        int accuracy();
        /// <summary>
        /// Full accuracy calculation.
        /// </summary>
        /// <remarks>
        /// Gets the rough accuracy estimate for the move.
        /// </remarks>
        int rough_accuracy();
        /// <summary>Gets the rough critical hit stage for the move.</summary>
        /// <remarks>
        /// Full critical hit chance calculation (returns the determined critical hit
        /// stage).
        /// </remarks>
        int rough_critical_hit_stage();
        /// <summary>Gets the score change for an additional effect, for a given user and optional target.</summary>
        /// <returns>
        /// Return values:
        ///   0: Isn't an additional effect or always triggers
        ///   -999: Additional effect will be negated
        ///   Other: Amount to add to a move's score
        /// </returns>
        /// <param name="user">The user battler.</param>
        /// <param name="target">Optional: the target battler.</param>
        /// TODO: This value just gets added to the score, but it should only modify the
        ///       score for the additional effect and shouldn't reduce that to less than
        ///       0.
        int get_score_change_for_additional_effect(IAIBattler user, IAIBattler target = null);
    }
}