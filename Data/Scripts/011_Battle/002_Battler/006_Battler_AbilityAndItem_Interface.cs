using System;
using System.Collections.Generic;
using PokemonEssentials.Data;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the Battler ability and item logic (triggers, checks, effects, etc.).
    /// <para>Handles all ability and held item triggers, checks, and effects for a battler, including switching, fainting, item consumption, and special ability/item interactions.</para>
    /// </summary>
    public interface IBattlerAbilityAndItem : IBattler
    {
        /// <summary>
        /// Triggers all ability effects that occur when the battler switches out, including Neutralizing Gas and Unnerve.
        /// </summary>
        void AbilitiesOnSwitchOut();

        /// <summary>
        /// Triggers all ability effects that occur when the battler faints, including global ability triggers on other battlers.
        /// </summary>
        void AbilitiesOnFainting();

        /// <summary>
        /// Checks and triggers ability effects when the battler takes damage and drops below half HP (e.g., Emergency Exit/Wimp Out).
        /// </summary>
        /// <param name="move_user">The user of the move that caused the damage.</param>
        /// <returns>True if the ability triggered, otherwise false.</returns>
        bool AbilitiesOnDamageTaken(IBattler move_user = null);

        /// <summary>
        /// Triggers ability effects when the terrain changes, such as abilities that respond to terrain shifts.
        /// </summary>
        /// <param name="ability_changed">Whether the ability has changed.</param>
        void AbilityOnTerrainChange(bool ability_changed = false);

        /// <summary>
        /// Triggers ability effects when the battler is targeted by Intimidate or similar effects.
        /// </summary>
        void AbilitiesOnIntimidated();

        /// <summary>
        /// Handles the end of Neutralizing Gas, re-enabling suppressed abilities and triggering their effects.
        /// </summary>
        void AbilitiesOnNeutralizingGasEnding();

        /// <summary>
        /// Performs continual ability checks, such as Trace and end-of-round ability triggers.
        /// </summary>
        /// <param name="onSwitchIn">Whether this is on switch-in.</param>
        void ContinualAbilityChecks(bool onSwitchIn = false);

        /// <summary>
        /// Triggers ability effects that cure status conditions, confusion, and infatuation.
        /// </summary>
        void AbilityStatusCureCheck();

        /// <summary>
        /// Handles abilities that grant immunity to certain move types and raise a stat instead (e.g., Lightning Rod).
        /// </summary>
        /// <param name="user">The user of the move.</param>
        /// <param name="move">The move used.</param>
        /// <param name="moveType">The type of the move.</param>
        /// <param name="immuneType">The type the ability grants immunity to.</param>
        /// <param name="stat">The stat to raise.</param>
        /// <param name="increment">The amount to raise the stat by.</param>
        /// <param name="show_message">Whether to show a message.</param>
        /// <returns>True if the ability triggered, otherwise false.</returns>
        bool MoveImmunityStatRaisingAbility(IBattler user, IMove move, int moveType, int immuneType, string stat, int increment, bool show_message);

        /// <summary>
        /// Handles abilities that grant immunity to certain move types and heal the battler instead (e.g., Water Absorb).
        /// </summary>
        /// <param name="user">The user of the move.</param>
        /// <param name="move">The move used.</param>
        /// <param name="moveType">The type of the move.</param>
        /// <param name="immuneType">The type the ability grants immunity to.</param>
        /// <param name="show_message">Whether to show a message.</param>
        /// <returns>True if the ability triggered, otherwise false.</returns>
        bool MoveImmunityHealingAbility(IBattler user, IMove move, int moveType, int immuneType, bool show_message);

        /// <summary>
        /// Handles logic for when the battler loses an ability, including form changes and end-of-effect triggers.
        /// </summary>
        /// <param name="oldAbil">The old ability ID.</param>
        /// <param name="suppressed">Whether the ability was suppressed.</param>
        void OnLosingAbility(int oldAbil, bool suppressed = false);

        /// <summary>
        /// Triggers all effects that occur when the battler gains a new ability, including Trace and status curing.
        /// </summary>
        void TriggerAbilityOnGainingIt();

        /// <summary>
        /// Checks if the battler can consume a held Berry, considering Unnerve and similar effects.
        /// </summary>
        /// <returns>True if the Berry can be consumed, otherwise false.</returns>
        bool canConsumeBerry();

        /// <summary>
        /// Checks if the battler can consume a "pinch" Berry (HP-based), considering Gluttony and HP thresholds.
        /// </summary>
        /// <param name="check_gluttony">Whether to check for the Gluttony ability.</param>
        /// <returns>True if the Berry can be consumed, otherwise false.</returns>
        bool canConsumePinchBerry(bool check_gluttony = true);

        /// <summary>
        /// Removes the battler's held item, with an option for permanent removal (e.g., Knock Off).
        /// </summary>
        /// <param name="permanent">Whether the item is lost permanently.</param>
        void RemoveItem(bool permanent = true);

        /// <summary>
        /// Handles the consumption of a held item, including Symbiosis and Belch triggers.
        /// </summary>
        /// <param name="recoverable">Whether the item can be recovered (e.g., via Recycle).</param>
        /// <param name="symbiosis">Whether Symbiosis should trigger.</param>
        /// <param name="belch">Whether Belch should be enabled.</param>
        void ConsumeItem(bool recoverable = true, bool symbiosis = true, bool belch = true);

        /// <summary>
        /// Handles the Symbiosis ability, transferring a held item from an ally if possible.
        /// </summary>
        void Symbiosis();

        /// <summary>
        /// Handles the effects of a held item being triggered, including Cheek Pouch and Symbiosis.
        /// </summary>
        /// <param name="item_to_use">The item being used or consumed.</param>
        /// <param name="own_item">Whether the item is held by self.</param>
        /// <param name="fling">Whether the item is being used via Fling.</param>
        void HeldItemTriggered(int item_to_use, bool own_item = true, bool fling = false);

        /// <summary>
        /// Checks and triggers all held item effects that may activate (healing, status cure, end-of-move, etc.).
        /// </summary>
        /// <param name="item_to_use">The item being used or consumed.</param>
        /// <param name="fling">Whether the item is being used via Fling.</param>
        void HeldItemTriggerCheck(int? item_to_use = null, bool fling = false);

        /// <summary>
        /// Checks and triggers held item healing effects (e.g., Sitrus Berry, Leftovers).
        /// </summary>
        /// <param name="item_to_use">The item being used or consumed.</param>
        /// <param name="fling">Whether the item is being used via Fling.</param>
        void ItemHPHealCheck(int? item_to_use = null, bool fling = false);

        /// <summary>
        /// Checks and triggers held item status cure effects (e.g., Lum Berry, Mental Herb).
        /// </summary>
        /// <param name="item_to_use">The item being used or consumed.</param>
        /// <param name="fling">Whether the item is being used via Fling.</param>
        void ItemStatusCureCheck(int? item_to_use = null, bool fling = false);

        /// <summary>
        /// Checks and triggers held item effects that activate at the end of using a move (e.g., White Herb).
        /// </summary>
        /// <param name="item_to_use">The item being used or consumed.</param>
        /// <param name="fling">Whether the item is being used via Fling.</param>
        void ItemEndOfMoveCheck(int? item_to_use = null, bool fling = false);

        /// <summary>
        /// Checks and triggers held item effects that restore stats (e.g., White Herb from Moody/Sticky Web).
        /// </summary>
        /// <param name="item_to_use">The item being used or consumed.</param>
        /// <param name="fling">Whether the item is being used via Fling.</param>
        void ItemStatRestoreCheck(int? item_to_use = null, bool fling = false);

        /// <summary>
        /// Checks and triggers held item effects that boost stats due to terrain (e.g., Electric Seed).
        /// </summary>
        void ItemTerrainStatBoostCheck();

        /// <summary>
        /// Checks and triggers held item effects when the battler is intimidated (e.g., Adrenaline Orb).
        /// </summary>
        void ItemOnIntimidatedCheck();

        /// <summary>
        /// Checks and triggers held item effects when the battler's stats are dropped (e.g., Eject Pack).
        /// </summary>
        /// <param name="move_user">The user of the move that caused the stat drop.</param>
        /// <returns>True if the item triggered a switch, otherwise false.</returns>
        bool ItemOnStatDropped(IBattler move_user = null);

        /// <summary>
        /// Triggers all held item effects that occur when Unnerve/As One ends (e.g., berries become usable again).
        /// </summary>
        void ItemsOnUnnerveEnding();

        /// <summary>
        /// Handles the effect of confusion-healing berries, including healing and possible confusion infliction.
        /// </summary>
        /// <param name="item_to_use">The berry being used.</param>
        /// <param name="forced">Whether the berry is being forced to be consumed.</param>
        /// <param name="confuse_stat">The stat that may cause confusion if negative.</param>
        /// <param name="confuse_msg">The message to display if confusion is inflicted.</param>
        /// <returns>True if the berry was consumed, otherwise false.</returns>
        bool ConfusionBerry(int item_to_use, bool forced, string confuse_stat, string confuse_msg);

        /// <summary>
        /// Handles the effect of stat-increasing berries, including incrementing the stat and triggering Ripen.
        /// </summary>
        /// <param name="item_to_use">The berry being used.</param>
        /// <param name="forced">Whether the berry is being forced to be consumed.</param>
        /// <param name="stat">The stat to increase.</param>
        /// <param name="increment">The amount to increase the stat by.</param>
        /// <returns>True if the berry was consumed, otherwise false.</returns>
        bool StatIncreasingBerry(int item_to_use, bool forced, string stat, int increment = 1);

        /// <summary>
        /// Handles the effect of type-weakening berries, reducing damage from super-effective moves.
        /// </summary>
        /// <param name="berry_type">The type the berry weakens.</param>
        /// <param name="move_type">The type of the incoming move.</param>
        /// <param name="mults">The multipliers to apply to damage.</param>
        void MoveTypeWeakeningBerry(int berry_type, int move_type, object mults);

        /// <summary>
        /// Handles the effect of Gems, boosting the power of moves of a specific type.
        /// </summary>
        /// <param name="gem_type">The type the Gem boosts.</param>
        /// <param name="move">The move being used.</param>
        /// <param name="move_type">The type of the move.</param>
        /// <param name="mults">The multipliers to apply to damage.</param>
        void MoveTypePoweringUpGem(int gem_type, IMove move, int move_type, object mults);
    }
}