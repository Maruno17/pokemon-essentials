using System.Collections.Generic;
using PokemonEssentials.Data;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for AI battler logic and properties.
    /// </summary>
    public interface IAIBattler
    {
        /// <summary>Gets the battler's index.</summary>
        int index { get; }
        /// <summary>Gets the battler's side (0=player, 1=opponent).</summary>
        int side { get; }
        /// <summary>Gets the party index of the battler.</summary>
        int party_index { get; }
        /// <summary>Gets the underlying IBattler object.</summary>
        IBattler battler { get; }
        /// <summary>Gets the Pokémon associated with this battler.</summary>
        IPokemon pokemon { get; }
        /// <summary>Gets the battler's level.</summary>
        int level { get; }
        /// <summary>Gets the battler's current HP.</summary>
        int hp { get; }
        /// <summary>Gets the battler's total HP.</summary>
        int totalhp { get; }
        /// <summary>Returns true if the battler has fainted.</summary>
        bool fainted { get; }
        /// <summary>Gets the battler's status condition.</summary>
        string status { get; }
        /// <summary>Gets the status count (e.g., turns asleep).</summary>
        int statusCount { get; }
        /// <summary>Gets the battler's gender.</summary>
        int gender { get; }
        /// <summary>Gets the number of turns the battler has been active.</summary>
        int turnCount { get; }
        /// <summary>Gets the effects dictionary for the battler.</summary>
        IDictionary<string, IActivePosition> effects { get; }
        /// <summary>Gets the stat stages dictionary for the battler.</summary>
        IDictionary<int, int> stages { get; }
        bool statStageAtMax(int stat);
        bool statStageAtMin(int stat);
        /// <summary>Gets the list of moves known by the battler.</summary>
        IList<IMove> moves { get; }
        /// <summary>Returns true if the battler is wild.</summary>
        bool wild { get; }
        /// <summary>Gets the battler's display name.</summary>
        string name { get; }
        /// <summary>Returns true if this battler opposes the given battler or side.</summary>
        /// <param name="other">Optional: the other battler or side to compare.</param>
        bool opposes(int? other = null);
        /// <summary>Gets the own side index for the battler.</summary>
        int idxOwnSide { get; }
        /// <summary>Gets the own side object for the battler.</summary>
        IActiveSide OwnSide { get; }
        /// <summary>Gets the opposing side index for the battler.</summary>
        int idxOpposingSide { get; }
        /// <summary>Gets the opposing side object for the battler.</summary>
        IActiveSide OpposingSide { get; }
        /// <summary>Calculates the rough end-of-round damage for the battler.</summary>
        /// <remarks>
        /// Returns how much damage this battler will take at the end of this round.
        /// </remarks>
        int rough_end_of_round_damage();
        /// <summary>Gets the base stat value for the given stat symbol.</summary>
        /// <param name="stat">The stat symbol (e.g., :ATTACK).</param>
        int base_stat(int stat);
        /// <summary>Gets the rough stat value for the given stat symbol.</summary>
        /// <param name="stat">The stat symbol (e.g., :SPEED).</param>
        int rough_stat(int stat);
        /// <summary>Returns true if this battler is faster than the other battler.</summary>
        /// <param name="other">The other battler to compare speed with.</param>
        bool faster_than(IAIBattler other);
        /// <summary>Gets the list of type symbols for the battler.</summary>
        IList<int> types { get; }
        /// <summary>Gets the list of type symbols for the battler, optionally including extra types.</summary>
        /// <param name="withExtraType">Whether to include extra types.</param>
        IList<string> Types(bool withExtraType = false);
        /// <summary>Returns true if the battler has the given type.</summary>
        /// <param name="type">The type symbol.</param>
        bool has_type(int type);
        /// <summary>Calculates the effectiveness of a type against this battler.</summary>
        /// <param name="type">The attacking type symbol.</param>
        /// <param name="user">Optional: the user battler.</param>
        /// <param name="move">Optional: the move being used.</param>
        double effectiveness_of_type_against_battler(int type, IAIBattler user = null, IMove move = null);
        /// <summary>Gets the ability ID of the battler.</summary>
        int ability_id { get; }
        /// <summary>Gets the ability object of the battler.</summary>
        IAbility ability { get; }
        /// <summary>Returns true if the battler's ability is active.</summary>
        bool ability_active();
        /// <summary>Returns true if the battler has the given active ability.</summary>
        /// <param name="ability">The ability symbol.</param>
        /// <param name="ignore_fainted">Whether to ignore fainted status.</param>
        bool has_active_ability(int ability, bool ignore_fainted = false);
        /// <summary>Returns true if the battler has Mold Breaker.</summary>
        bool has_mold_breaker();
        /// <summary>Returns true if the battler is being Mold Broken.</summary>
        bool being_mold_broken();
        /// <summary>Gets the item ID of the battler.</summary>
        int item_id { get; }
        /// <summary>Gets the item object of the battler.</summary>
        IItem item { get; }
        /// <summary>Returns true if the battler's item is active.</summary>
        bool item_active();
        /// <summary>Returns true if the battler has the given active item.</summary>
        /// <param name="item">The item symbol.</param>
        bool has_active_item(string item);
        /// <summary>Checks for a move matching the given predicate.</summary>
        /// <param name="predicate">The predicate to match moves.</param>
        bool check_for_move(System.Func<IMove, bool> predicate);
        /// <summary>Returns true if the battler has a damaging move of any of the given types.</summary>
        /// <param name="types">The type symbols.</param>
        bool has_damaging_move_of_type(params int[] types);
        /// <summary>Returns true if the battler has a move with any of the given function codes.</summary>
        /// <param name="functions">The function code symbols.</param>
        bool has_move_with_function(params string[] functions);
        /// <summary>Returns true if the battler can attack this turn.</summary>
        bool can_attack();
        /// <summary>Returns true if the battler can switch out (lax conditions).</summary>
        bool can_switch_lax();
        /// <summary>Returns true if the battler can become trapped.</summary>
        /// <remarks>
        /// NOTE: This specifically means "is not currently trapped but can become
        ///       trapped by an effect". Similar to def pbCanSwitchOut? but this returns
        ///       false if any certain switching OR certain trapping applies.
        /// </remarks>
        bool can_become_trapped();
        /// <summary>Returns true if the battler wants the given status problem.</summary>
        /// <param name="new_status">The status symbol.</param>
        bool wants_status_problem(int new_status);
        /// <summary>Returns a score for how much the battler wants the given ability.</summary>
        /// <remarks>
        /// Returns a value indicating how beneficial the given ability will be to this
        /// battler if it has it.
        /// NOTE: This method assumes the ability isn't being negated. The calculations
        ///       that call this method separately check for it being negated, because
        ///       they need to do something special in that case.
        /// </remarks>
        /// <param name="ability">The ability symbol.</param>
        /// <returns>
        /// Return values are typically between -10 and +10. 0 is indifferent, positive
        /// values mean this battler benefits, negative values mean this battler suffers.
        /// </returns>
        int wants_ability(int? ability = null);
        /// <summary>Returns a score for how much the battler wants the given item.</summary>
        /// <remarks>
        /// Returns a value indicating how beneficial the given item will be to this
        /// battler if it is holding it.
        /// NOTE: This method assumes the item isn't being negated. The calculations
        ///       that call this method separately check for it being negated, because
        ///       they need to do something special in that case.
        /// </remarks>
        /// <param name="item">The item symbol.</param>
        /// <returns>
        /// Return values are typically between -10 and +10. 0 is indifferent, positive
        /// values mean this battler benefits, negative values mean this battler suffers.
        /// </returns>
        int wants_item(int? item = null);
        /// <summary>Gets the score change for consuming the given item.</summary>
        /// <remarks>
        /// Items can be consumed by Stuff Cheeks, Teatime, Bug Bite/Pluck and Fling.
        /// </remarks>
        /// <param name="item">The item symbol.</param>
        /// <param name="tryPreservingItem">Whether to try preserving the item.</param>
        int get_score_change_for_consuming_item(int item, bool tryPreservingItem = false);
    }
}