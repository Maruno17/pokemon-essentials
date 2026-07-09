using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for item-related move effects, including stealing, swapping, consuming, and manipulating held items.
    /// Provides functionality for moves like Thief, Trick, Recycle, Knock Off, and Fling.
    /// </summary>
    public interface IBattleMoveEffectsItems : IBattleMove
    {
    }

    /// <summary>
    /// Interface for moves that steal the target's item.
    /// Examples: Covet, Thief
    /// </summary>
    public interface IUserTakesTargetItem
    {
        /// <summary>
        /// Attempts to steal the target's item after all hits.
        /// Items stolen from wild Pokemon are kept permanently.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectAfterAllHits(IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for moves that give user's item to the target.
    /// Examples: Bestow
    /// </summary>
    public interface ITargetTakesUserItem
    {
        /// <summary>
        /// Checks if this move ignores substitutes.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <returns>True if move ignores substitutes in Gen 6+</returns>
        bool ignoresSubstitute(IBattler user);

        /// <summary>
        /// Checks if the move fails due to user not having a valid item.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <returns>True if the move fails</returns>
        bool MoveFailed(IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Checks if the move fails against a specific target.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <param name="show_message">Whether to show failure message</param>
        /// <returns>True if the move fails against the target</returns>
        bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);

        /// <summary>
        /// Transfers the user's item to the target.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectAgainstTarget(IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for moves that swap items between user and target.
    /// Examples: Switcheroo, Trick
    /// </summary>
    public interface IUserTargetSwapItems
    {
        /// <summary>
        /// Checks if the move fails due to user restrictions.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <returns>True if the move fails</returns>
        bool MoveFailed(IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Checks if the move fails against a specific target.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <param name="show_message">Whether to show failure message</param>
        /// <returns>True if the move fails against the target</returns>
        bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);

        /// <summary>
        /// Swaps the items between user and target, handling all side effects.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectAgainstTarget(IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for moves that restore the user's previously consumed item.
    /// Examples: Recycle
    /// </summary>
    public interface IRestoreUserConsumedItem
    {
        /// <summary>
        /// Checks if the move can be snatched.
        /// </summary>
        /// <returns>True if snatchable</returns>
        bool canSnatch();

        /// <summary>
        /// Checks if the move fails due to no recyclable item or already having an item.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <returns>True if the move fails</returns>
        bool MoveFailed(IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Restores the user's previously consumed item.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        void EffectGeneral(IBattler user);
    }

    /// <summary>
    /// Interface for moves that remove the target's item.
    /// Examples: Knock Off
    /// </summary>
    public interface IRemoveTargetItem
    {
        /// <summary>
        /// Increases base damage if target has a losable item.
        /// </summary>
        /// <param name="baseDmg">The base damage</param>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <returns>Modified damage value</returns>
        int BaseDamage(int baseDmg, IBattler user, IBattler target);

        /// <summary>
        /// Removes the target's item after all hits.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectAfterAllHits(IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for moves that destroy berries or gems.
    /// Examples: Incinerate
    /// </summary>
    public interface IDestroyTargetBerryOrGem
    {
        /// <summary>
        /// Destroys target's berry or gem when dealing damage.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectWhenDealingDamage(IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for moves that permanently corrode the target's item.
    /// Examples: Corrosive Gas
    /// </summary>
    public interface ICorrodeTargetItem
    {
        /// <summary>
        /// Checks if the move can be reflected by Magic Coat.
        /// </summary>
        /// <returns>True if reflectable</returns>
        bool canMagicCoat();

        /// <summary>
        /// Checks if the move fails against a specific target.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <param name="show_message">Whether to show failure message</param>
        /// <returns>True if the move fails against the target</returns>
        bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);

        /// <summary>
        /// Corrodes the target's item, making it unusable for the rest of battle.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectAgainstTarget(IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for moves that prevent target from using items.
    /// Examples: Embargo
    /// </summary>
    public interface IStartTargetCannotUseItem
    {
        /// <summary>
        /// Checks if the move can be reflected by Magic Coat.
        /// </summary>
        /// <returns>True if reflectable</returns>
        bool canMagicCoat();

        /// <summary>
        /// Checks if the move fails against a specific target.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <param name="show_message">Whether to show failure message</param>
        /// <returns>True if the move fails against the target</returns>
        bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);

        /// <summary>
        /// Applies embargo effect to prevent target from using items.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectAgainstTarget(IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for moves that negate all held items in battle.
    /// Examples: Magic Room
    /// </summary>
    public interface IStartNegateHeldItems
    {
        /// <summary>
        /// Toggles Magic Room effect on or off.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        void EffectGeneral(IBattler user);

        /// <summary>
        /// Shows animation only when Magic Room is not already active.
        /// </summary>
        /// <param name="id">Animation ID</param>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <param name="hitNum">Hit number</param>
        /// <param name="showAnimation">Whether to show animation</param>
        void ShowAnimation(object id, IBattler user, IList<IBattler> targets, int hitNum = 0, bool showAnimation = true);
    }

    /// <summary>
    /// Interface for moves that consume user's berry and raise Defense.
    /// Examples: Stuff Cheeks
    /// </summary>
    public interface IUserConsumeBerryRaiseDefense2
    {
        /// <summary>
        /// Gets the stat that will be raised.
        /// </summary>
        object statUp { get; }

        /// <summary>
        /// Checks if the move can be chosen based on user having a berry.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="commandPhase">Whether this is during command phase</param>
        /// <param name="showMessages">Whether to show failure messages</param>
        /// <returns>True if the move can be chosen</returns>
        bool CanChooseMove(IBattler user, bool commandPhase, bool showMessages);

        /// <summary>
        /// Checks if the move fails due to not having a valid berry.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <returns>True if the move fails</returns>
        bool MoveFailed(IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Consumes the user's berry and raises Defense, then applies berry effects.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        void EffectGeneral(IBattler user);
    }

    /// <summary>
    /// Interface for moves that make all battlers consume their berries.
    /// Examples: Teatime
    /// </summary>
    public interface IAllBattlersConsumeBerry
    {
        /// <summary>
        /// Checks if the move fails due to no battlers having berries.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <returns>True if the move fails</returns>
        bool MoveFailed(IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Displays the teatime message when the move starts.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        void OnStartUse(IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Checks if the move fails against a specific target.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <param name="show_message">Whether to show failure message</param>
        /// <returns>True if the move fails against the target</returns>
        bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);

        /// <summary>
        /// Makes the target consume their berry and gain its effects.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectAgainstTarget(IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for moves that steal and consume target's berry.
    /// Examples: Bug Bite, Pluck
    /// </summary>
    public interface IUserConsumeTargetBerry
    {
        /// <summary>
        /// Prevents battler from consuming healing berries if they are targeted by this move.
        /// </summary>
        /// <param name="battler">The Pokemon that might consume a berry</param>
        /// <param name="targets">The targets of this move</param>
        /// <returns>True if berry consumption should be prevented</returns>
        bool preventsBattlerConsumingHealingBerry(object battler, IList<IBattler> targets);

        /// <summary>
        /// Steals and consumes the target's berry after all hits.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectAfterAllHits(IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for moves that throw the user's item at the target.
    /// Examples: Fling
    /// </summary>
    public interface IThrowUserItemAtTarget
    {
        /// <summary>
        /// Checks if the fling will succeed based on item validity.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        void CheckFlingSuccess(IBattler user);

        /// <summary>
        /// Checks if the move fails due to invalid item for flinging.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <returns>True if the move fails</returns>
        bool MoveFailed(IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Displays use message and checks fling validity.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        void DisplayUseMessage(IBattler user);

        /// <summary>
        /// Gets the number of hits for this move.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <returns>Number of hits (1)</returns>
        int NumHits(IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Calculates base damage based on the flung item's power.
        /// </summary>
        /// <param name="baseDmg">The base damage</param>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <returns>Damage based on flung item</returns>
        int BaseDamage(int baseDmg, IBattler user, IBattler target);

        /// <summary>
        /// Applies additional effects based on the flung item type.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectAgainstTarget(IBattler user, IBattler target);

        /// <summary>
        /// Consumes the user's item at the end of move usage.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <param name="numHits">Number of hits that occurred</param>
        /// <param name="switchedBattlers">Battlers that were switched out</param>
        void EndOfMoveUsageEffect(IBattler user, IList<IBattler> targets, int numHits, object switchedBattlers);
    }
}