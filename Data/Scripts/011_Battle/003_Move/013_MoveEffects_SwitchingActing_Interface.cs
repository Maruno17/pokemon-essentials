using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for move effects related to switching, trapping, action manipulation, and move restrictions.
    /// Provides functionality for moves like U-turn, Roar, Pursuit, Taunt, and Trick Room.
    /// </summary>
    public interface IBattleMoveEffectsSwitchingActing : IBattleMove
    {
    }

    /// <summary>
    /// Interface for moves that make the user flee from battle.
    /// Examples: Teleport (Gen 7-)
    /// </summary>
    public interface IFleeFromBattle
    {
        /// <summary>
        /// Checks if the move fails due to inability to run.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <returns>True if the move fails</returns>
        bool MoveFailed(IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Makes the user flee from battle.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        void EffectGeneral(IBattler user);
    }

    /// <summary>
    /// Interface for moves that switch out the user as a status move.
    /// Examples: Teleport (Gen 8+)
    /// </summary>
    public interface ISwitchOutUserStatusMove
    {
        /// <summary>
        /// Checks if the move fails due to switching restrictions.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <returns>True if the move fails</returns>
        bool MoveFailed(IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Handles the switching out process at the end of move usage.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <param name="numHits">Number of hits that occurred</param>
        /// <param name="switchedBattlers">List of battlers that switched</param>
        void EndOfMoveUsageEffect(IBattler user, IList<IBattler> targets, int numHits, object switchedBattlers);

        /// <summary>
        /// Makes wild Pokemon flee from battle.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        void EffectGeneral(IBattler user);
    }

    /// <summary>
    /// Interface for damaging moves that switch out the user after dealing damage.
    /// Examples: U-turn, Volt Switch, Flip Turn
    /// </summary>
    public interface ISwitchOutUserDamagingMove
    {
        /// <summary>
        /// Handles the switching out process after dealing damage.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <param name="numHits">Number of hits that occurred</param>
        /// <param name="switchedBattlers">List of battlers that switched</param>
        void EndOfMoveUsageEffect(IBattler user, IList<IBattler> targets, int numHits, object switchedBattlers);
    }

    /// <summary>
    /// Interface for moves that lower stats and then switch out the user.
    /// Examples: Parting Shot
    /// </summary>
    public interface ILowerTargetAtkSpAtk1SwitchOutUser
    {
        /// <summary>
        /// Gets the stats that will be lowered.
        /// </summary>
        object statDown { get; }

        /// <summary>
        /// Handles switching out, accounting for Magic Coat redirection.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <param name="numHits">Number of hits that occurred</param>
        /// <param name="switchedBattlers">List of battlers that switched</param>
        void EndOfMoveUsageEffect(IBattler user, IList<IBattler> targets, int numHits, object switchedBattlers);
    }

    /// <summary>
    /// Interface for moves that switch out user and pass on effects.
    /// Examples: Baton Pass
    /// </summary>
    public interface ISwitchOutUserPassOnEffects
    {
        /// <summary>
        /// Checks if the move fails due to no replacement available.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <returns>True if the move fails</returns>
        bool MoveFailed(IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Switches out user while passing on battle effects to replacement.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <param name="numHits">Number of hits that occurred</param>
        /// <param name="switchedBattlers">List of battlers that switched</param>
        void EndOfMoveUsageEffect(IBattler user, IList<IBattler> targets, int numHits, object switchedBattlers);
    }

    /// <summary>
    /// Interface for status moves that force target to switch out.
    /// Examples: Roar, Whirlwind
    /// </summary>
    public interface ISwitchOutTargetStatusMove
    {
        /// <summary>
        /// Checks if this move ignores substitutes.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <returns>True if move ignores substitutes</returns>
        bool ignoresSubstitute(IBattler user);

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
        /// Makes wild target flee from battle.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectAgainstTarget(IBattler user, IBattler target);

        /// <summary>
        /// Handles the actual switching out of trainer Pokemon targets.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <param name="numHits">Number of hits that occurred</param>
        /// <param name="switched_battlers">List of battlers that switched</param>
        void SwitchOutTargetEffect(IBattler user, IList<IBattler> targets, int numHits, object switched_battlers);
    }

    /// <summary>
    /// Interface for damaging moves that force target to switch out.
    /// Examples: Circle Throw, Dragon Tail
    /// </summary>
    public interface ISwitchOutTargetDamagingMove
    {
        /// <summary>
        /// Makes wild target flee if conditions are met.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectAgainstTarget(IBattler user, IBattler target);

        /// <summary>
        /// Handles the actual switching out of trainer Pokemon targets after damage.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <param name="numHits">Number of hits that occurred</param>
        /// <param name="switched_battlers">List of battlers that switched</param>
        void SwitchOutTargetEffect(IBattler user, IList<IBattler> targets, int numHits, object switched_battlers);
    }

    /// <summary>
    /// Interface for binding moves that trap the target.
    /// Examples: Bind, Wrap, Fire Spin
    /// </summary>
    public interface IBindTarget
    {
        /// <summary>
        /// Applies the binding/trapping effect to the target.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectAgainstTarget(IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for binding moves with underwater targeting bonus.
    /// Examples: Whirlpool
    /// </summary>
    public interface IBindTargetDoublePowerIfTargetUnderwater : IBindTarget
    {
        /// <summary>
        /// Checks if this move hits diving targets.
        /// </summary>
        /// <returns>True if move hits diving targets</returns>
        bool hitsDivingTargets();

        /// <summary>
        /// Modifies damage if target is underwater (using Dive).
        /// </summary>
        /// <param name="damageMult">The damage multiplier</param>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <returns>Modified damage multiplier</returns>
        float ModifyDamage(float damageMult, IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for moves that prevent target from switching out.
    /// Examples: Block, Mean Look, Spider Web, Anchor Shot, Spirit Shackle
    /// </summary>
    public interface ITrapTargetInBattle
    {
        /// <summary>
        /// Checks if the move can be reflected by Magic Coat.
        /// </summary>
        /// <returns>True if reflectable</returns>
        bool canMagicCoat();

        /// <summary>
        /// Checks if the move fails against a specific target (for status moves).
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <param name="show_message">Whether to show failure message</param>
        /// <returns>True if the move fails against the target</returns>
        bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);

        /// <summary>
        /// Applies the trapping effect for status moves.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectAgainstTarget(IBattler user, IBattler target);

        /// <summary>
        /// Applies the trapping effect as additional effect for damaging moves.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void AdditionalEffect(IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for moves that trap target as main effect (not additional).
    /// Examples: Thousand Waves
    /// </summary>
    public interface ITrapTargetInBattleMainEffect
    {
        /// <summary>
        /// Checks if the move can be reflected by Magic Coat.
        /// </summary>
        /// <returns>True if reflectable</returns>
        bool canMagicCoat();

        /// <summary>
        /// Applies the trapping effect as the main effect.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectAgainstTarget(IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for moves that trap target and lower stats each turn.
    /// Examples: Octolock
    /// </summary>
    public interface ITrapTargetInBattleLowerTargetDefSpDef1EachTurn
    {
        /// <summary>
        /// Checks if the move fails due to target already being trapped by Octolock.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <param name="show_message">Whether to show failure message</param>
        /// <returns>True if the move fails against the target</returns>
        bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);

        /// <summary>
        /// Applies the Octolock trapping effect.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectAgainstTarget(IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for moves that trap both user and target.
    /// Examples: Jaw Lock
    /// </summary>
    public interface ITrapUserAndTargetInBattle
    {
        /// <summary>
        /// Applies mutual trapping effect if conditions are met.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectAgainstTarget(IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for moves that prevent all battlers from switching for one turn.
    /// Examples: Fairy Lock
    /// </summary>
    public interface ITrapAllBattlersInBattleForOneTurn
    {
        /// <summary>
        /// Checks if the move fails due to Fairy Lock already being active.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <returns>True if the move fails</returns>
        bool MoveFailed(IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Sets up Fairy Lock effect for the next turn.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        void EffectGeneral(IBattler user);
    }

    /// <summary>
    /// Interface for moves that interrupt and power up against switching foes.
    /// Examples: Pursuit
    /// </summary>
    public interface IPursueSwitchingFoe
    {
        /// <summary>
        /// Always hits when target is switching.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <returns>True if attack hits</returns>
        bool AccuracyCheck(IBattler user, IBattler target);

        /// <summary>
        /// Doubles base damage when target is switching.
        /// </summary>
        /// <param name="baseDmg">The base damage</param>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <returns>Modified damage value</returns>
        int BaseDamage(int baseDmg, IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for moves that require physical damage to be taken first.
    /// Examples: Shell Trap
    /// </summary>
    public interface IUsedAfterUserTakesPhysicalDamage
    {
        /// <summary>
        /// Displays the charging message and sets Shell Trap flag.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        void DisplayChargeMessage(IBattler user);

        /// <summary>
        /// Shows use message only if user took physical damage.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        void DisplayUseMessage(IBattler user);

        /// <summary>
        /// Checks if the move fails due to conditions not being met.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <returns>True if the move fails</returns>
        bool MoveFailed(IBattler user, IList<IBattler> targets);
    }

    /// <summary>
    /// Interface for moves that get powered up when allies use the same move.
    /// Examples: Round
    /// </summary>
    public interface IUsedAfterAllyRoundWithDoublePower
    {
        /// <summary>
        /// Doubles base damage if ally already used Round this turn.
        /// </summary>
        /// <param name="baseDmg">The base damage</param>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <returns>Modified damage value</returns>
        int BaseDamage(int baseDmg, IBattler user, IBattler target);

        /// <summary>
        /// Sets Round flag and makes allies using Round go next.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        void EffectGeneral(IBattler user);
    }

    /// <summary>
    /// Interface for moves that make target act next.
    /// Examples: After You
    /// </summary>
    public interface ITargetActsNext
    {
        /// <summary>
        /// Checks if this move ignores substitutes.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <returns>True if move ignores substitutes</returns>
        bool ignoresSubstitute(IBattler user);

        /// <summary>
        /// Checks if the move fails due to target conditions.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <param name="show_message">Whether to show failure message</param>
        /// <returns>True if the move fails against the target</returns>
        bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);

        /// <summary>
        /// Makes the target move next in turn order.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectAgainstTarget(IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for moves that make target act last.
    /// Examples: Quash
    /// </summary>
    public interface ITargetActsLast
    {
        /// <summary>
        /// Checks if the move fails due to target conditions or priority order.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <param name="show_message">Whether to show failure message</param>
        /// <returns>True if the move fails against the target</returns>
        bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);

        /// <summary>
        /// Makes the target move last in turn order.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectAgainstTarget(IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for moves that make target use their last move again.
    /// Examples: Instruct
    /// </summary>
    public interface ITargetUsesItsLastUsedMoveAgain
    {
        /// <summary>
        /// Gets the list of moves that cannot be instructed.
        /// </summary>
        object moveBlacklist { get; }

        /// <summary>
        /// Checks if this move ignores substitutes.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <returns>True if move ignores substitutes</returns>
        bool ignoresSubstitute(IBattler user);

        /// <summary>
        /// Checks if the move fails due to target's last move being invalid.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <param name="show_message">Whether to show failure message</param>
        /// <returns>True if the move fails against the target</returns>
        bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);

        /// <summary>
        /// Sets the Instruct flag on the target.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectAgainstTarget(IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for moves that reverse speed priority.
    /// Examples: Trick Room
    /// </summary>
    public interface IStartSlowerBattlersActFirst
    {
        /// <summary>
        /// Toggles Trick Room effect on or off.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        void EffectGeneral(IBattler user);

        /// <summary>
        /// Shows animation only when Trick Room is not already active.
        /// </summary>
        /// <param name="id">Animation ID</param>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <param name="hitNum">Hit number</param>
        /// <param name="showAnimation">Whether to show animation</param>
        void ShowAnimation(object id, IBattler user, IList<IBattler> targets, int hitNum = 0, bool showAnimation = true);
    }

    /// <summary>
    /// Interface for moves that gain priority in specific terrain.
    /// Examples: Grassy Glide
    /// </summary>
    public interface IHigherPriorityInGrassyTerrain
    {
        /// <summary>
        /// Calculates priority, adding +1 in Grassy Terrain.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <returns>The move's priority value</returns>
        int Priority(IBattler user);
    }

    /// <summary>
    /// Interface for moves that reduce PP of target's last move (damaging).
    /// Examples: Eerie Spell
    /// </summary>
    public interface ILowerPPOfTargetLastMoveBy3
    {
        /// <summary>
        /// Reduces PP of target's last move by 3 as additional effect.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void AdditionalEffect(IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for moves that reduce PP of target's last move (status).
    /// Examples: Spite
    /// </summary>
    public interface ILowerPPOfTargetLastMoveBy4
    {
        /// <summary>
        /// Checks if this move ignores substitutes.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <returns>True if move ignores substitutes</returns>
        bool ignoresSubstitute(IBattler user);

        /// <summary>
        /// Checks if the move can be reflected by Magic Coat.
        /// </summary>
        /// <returns>True if reflectable</returns>
        bool canMagicCoat();

        /// <summary>
        /// Checks if the move fails due to target's last move being invalid.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <param name="show_message">Whether to show failure message</param>
        /// <returns>True if the move fails against the target</returns>
        bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);

        /// <summary>
        /// Reduces PP of target's last move by 4.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectAgainstTarget(IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for moves that disable target's last move.
    /// Examples: Disable
    /// </summary>
    public interface IDisableTargetLastMoveUsed
    {
        /// <summary>
        /// Checks if this move ignores substitutes.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <returns>True if move ignores substitutes</returns>
        bool ignoresSubstitute(IBattler user);

        /// <summary>
        /// Checks if the move can be reflected by Magic Coat.
        /// </summary>
        /// <returns>True if reflectable</returns>
        bool canMagicCoat();

        /// <summary>
        /// Checks if the move fails due to conditions.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <param name="show_message">Whether to show failure message</param>
        /// <returns>True if the move fails against the target</returns>
        bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);

        /// <summary>
        /// Disables the target's last used move for 5 turns.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectAgainstTarget(IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for moves that prevent using same move consecutively.
    /// Examples: Torment
    /// </summary>
    public interface IDisableTargetUsingSameMoveConsecutively
    {
        /// <summary>
        /// Checks if this move ignores substitutes.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <returns>True if move ignores substitutes</returns>
        bool ignoresSubstitute(IBattler user);

        /// <summary>
        /// Checks if the move can be reflected by Magic Coat.
        /// </summary>
        /// <returns>True if reflectable</returns>
        bool canMagicCoat();

        /// <summary>
        /// Checks if the move fails due to target already being tormented.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <param name="show_message">Whether to show failure message</param>
        /// <returns>True if the move fails against the target</returns>
        bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);

        /// <summary>
        /// Applies the Torment effect to the target.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectAgainstTarget(IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for moves that force target to use same move repeatedly.
    /// Examples: Encore
    /// </summary>
    public interface IDisableTargetUsingDifferentMove
    {
        /// <summary>
        /// Gets the list of moves that cannot be encored.
        /// </summary>
        object moveBlacklist { get; }

        /// <summary>
        /// Checks if this move ignores substitutes.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <returns>True if move ignores substitutes</returns>
        bool ignoresSubstitute(IBattler user);

        /// <summary>
        /// Checks if the move can be reflected by Magic Coat.
        /// </summary>
        /// <returns>True if reflectable</returns>
        bool canMagicCoat();

        /// <summary>
        /// Checks if the move fails due to various conditions.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <param name="show_message">Whether to show failure message</param>
        /// <returns>True if the move fails against the target</returns>
        bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);

        /// <summary>
        /// Applies the Encore effect to the target for 4 turns.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectAgainstTarget(IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for moves that prevent target from using status moves.
    /// Examples: Taunt
    /// </summary>
    public interface IDisableTargetStatusMoves
    {
        /// <summary>
        /// Checks if this move ignores substitutes.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <returns>True if move ignores substitutes</returns>
        bool ignoresSubstitute(IBattler user);

        /// <summary>
        /// Checks if the move can be reflected by Magic Coat.
        /// </summary>
        /// <returns>True if reflectable</returns>
        bool canMagicCoat();

        /// <summary>
        /// Checks if the move fails due to target conditions.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <param name="show_message">Whether to show failure message</param>
        /// <returns>True if the move fails against the target</returns>
        bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);

        /// <summary>
        /// Applies the Taunt effect to the target for 4 turns.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectAgainstTarget(IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for moves that prevent target from using healing moves.
    /// Examples: Heal Block
    /// </summary>
    public interface IDisableTargetHealingMoves
    {
        /// <summary>
        /// Checks if the move can be reflected by Magic Coat.
        /// </summary>
        /// <returns>True if reflectable</returns>
        bool canMagicCoat();

        /// <summary>
        /// Checks if the move fails due to target already being heal blocked.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <param name="show_message">Whether to show failure message</param>
        /// <returns>True if the move fails against the target</returns>
        bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);

        /// <summary>
        /// Applies the Heal Block effect to the target for 5 turns.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectAgainstTarget(IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for moves that prevent target from using sound moves.
    /// Examples: Throat Chop
    /// </summary>
    public interface IDisableTargetSoundMoves
    {
        /// <summary>
        /// Applies sound move restriction as additional effect for 3 turns.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void AdditionalEffect(IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for moves that disable target's moves known by the user.
    /// Examples: Imprison
    /// </summary>
    public interface IDisableTargetMovesKnownByUser
    {
        /// <summary>
        /// Checks if the move can be snatched.
        /// </summary>
        /// <returns>True if snatchable</returns>
        bool canSnatch();

        /// <summary>
        /// Checks if the move fails due to user already having Imprison active.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <returns>True if the move fails</returns>
        bool MoveFailed(IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Sets up Imprison effect to seal shared moves.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        void EffectGeneral(IBattler user);
    }
}