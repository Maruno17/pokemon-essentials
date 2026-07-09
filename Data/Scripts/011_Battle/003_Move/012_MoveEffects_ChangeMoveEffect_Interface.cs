using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for move effects that change behavior based on conditions, redirect moves, or call other moves.
    /// Provides functionality for moves like Follow Me, Secret Power, Curse, Copycat, and Pledge moves.
    /// </summary>
    public interface IBattleMoveEffectsChangeMoveEffect : IBattleMove
    {
    }

    /// <summary>
    /// Interface for moves that redirect all single-target moves to the user.
    /// Examples: Follow Me, Rage Powder
    /// </summary>
    public interface IRedirectAllMovesToUser
    {
        /// <summary>
        /// Makes the user become the center of attention for all single-target moves.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        void EffectGeneral(IBattler user);
    }

    /// <summary>
    /// Interface for moves that redirect all single-target moves to the target.
    /// Examples: Spotlight
    /// </summary>
    public interface IRedirectAllMovesToTarget
    {
        /// <summary>
        /// Checks if the move can be reflected by Magic Coat.
        /// </summary>
        /// <returns>True if reflectable</returns>
        bool canMagicCoat();

        /// <summary>
        /// Makes the target become the center of attention for all single-target moves.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectAgainstTarget(IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for moves that cannot be redirected by abilities or moves.
    /// Examples: Snipe Shot
    /// </summary>
    public interface ICannotBeRedirected
    {
        /// <summary>
        /// Checks if this move can be redirected.
        /// </summary>
        /// <returns>False for moves that cannot be redirected</returns>
        bool cannotRedirect();
    }

    /// <summary>
    /// Interface for moves that randomly damage or heal the target.
    /// Examples: Present
    /// </summary>
    public interface IRandomlyDamageOrHealTarget
    {
        /// <summary>
        /// Determines randomly whether the move will damage or heal.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        void OnStartUse(IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Checks if the move fails when it would heal.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <param name="show_message">Whether to show failure message</param>
        /// <returns>True if the move fails against the target</returns>
        bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);

        /// <summary>
        /// Determines if this is a damaging turn or healing turn.
        /// </summary>
        /// <returns>True if this turn deals damage</returns>
        bool DamagingMove();

        /// <summary>
        /// Calculates the base damage for the randomly determined power.
        /// </summary>
        /// <param name="baseDmg">The base damage</param>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <returns>The randomly determined damage</returns>
        int BaseDamage(int baseDmg, IBattler user, IBattler target);

        /// <summary>
        /// Applies healing effect when the move heals instead of damages.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectAgainstTarget(IBattler user, IBattler target);

        /// <summary>
        /// Shows appropriate animation for damage or healing.
        /// </summary>
        /// <param name="id">Animation ID</param>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <param name="hitNum">Hit number</param>
        /// <param name="showAnimation">Whether to show animation</param>
        void ShowAnimation(object id, IBattler user, IList<IBattler> targets, int hitNum = 0, bool showAnimation = true);
    }

    /// <summary>
    /// Interface for moves that heal allies or damage foes.
    /// Examples: Pollen Puff
    /// </summary>
    public interface IHealAllyOrDamageFoe
    {
        /// <summary>
        /// Modifies targeting based on Heal Block status.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <returns>The appropriate target type</returns>
        object Target(IBattler user);

        /// <summary>
        /// Determines whether this use will heal or damage based on target relationship.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        void OnStartUse(IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Checks if the move fails when healing is intended.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <param name="show_message">Whether to show failure message</param>
        /// <returns>True if the move fails against the target</returns>
        bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);

        /// <summary>
        /// Determines if this is a damaging move based on target relationship.
        /// </summary>
        /// <returns>True if this turn deals damage</returns>
        bool DamagingMove();

        /// <summary>
        /// Applies healing effect to allied targets.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectAgainstTarget(IBattler user, IBattler target);

        /// <summary>
        /// Shows appropriate animation for damage or healing.
        /// </summary>
        /// <param name="id">Animation ID</param>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <param name="hitNum">Hit number</param>
        /// <param name="showAnimation">Whether to show animation</param>
        void ShowAnimation(object id, IBattler user, IList<IBattler> targets, int hitNum = 0, bool showAnimation = true);
    }

    /// <summary>
    /// Interface for the Curse move with type-dependent effects.
    /// Examples: Curse
    /// </summary>
    public interface ICurseTargetOrLowerUserSpd1RaiseUserAtkDef1
    {
        /// <summary>
        /// Gets the stats that will be raised for non-Ghost types.
        /// </summary>
        object statUp { get; }

        /// <summary>
        /// Gets the stats that will be lowered for non-Ghost types.
        /// </summary>
        object statDown { get; }

        /// <summary>
        /// Checks if this move ignores substitutes.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <returns>True if move ignores substitutes</returns>
        bool ignoresSubstitute(IBattler user);

        /// <summary>
        /// Modifies targeting based on user's Ghost typing.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <returns>The appropriate target type</returns>
        object Target(IBattler user);

        /// <summary>
        /// Checks if the move fails for non-Ghost types due to stat limits.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <returns>True if the move fails</returns>
        bool MoveFailed(IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Checks if the Ghost-type effect fails due to target already being cursed.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <param name="show_message">Whether to show failure message</param>
        /// <returns>True if the move fails against the target</returns>
        bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);

        /// <summary>
        /// Applies stat changes for non-Ghost types.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        void EffectGeneral(IBattler user);

        /// <summary>
        /// Applies curse effect for Ghost types.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectAgainstTarget(IBattler user, IBattler target);

        /// <summary>
        /// Shows appropriate animation based on user's typing.
        /// </summary>
        /// <param name="id">Animation ID</param>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <param name="hitNum">Hit number</param>
        /// <param name="showAnimation">Whether to show animation</param>
        void ShowAnimation(object id, IBattler user, IList<IBattler> targets, int hitNum = 0, bool showAnimation = true);
    }

    /// <summary>
    /// Interface for Secret Power with environment-dependent effects.
    /// Examples: Secret Power
    /// </summary>
    public interface IEffectDependsOnEnvironment
    {
        /// <summary>
        /// Gets the determined Secret Power variant.
        /// </summary>
        object secretPower { get; }

        /// <summary>
        /// Checks if this variant causes flinching.
        /// </summary>
        /// <returns>True if this variant causes flinching</returns>
        bool flinchingMove();

        /// <summary>
        /// Determines the Secret Power variant based on environment.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        void OnStartUse(IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Applies the environment-specific additional effect.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectAfterAllHits(IBattler user, IBattler target);

        /// <summary>
        /// Shows animation appropriate for the determined environment effect.
        /// </summary>
        /// <param name="id">Animation ID</param>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <param name="hitNum">Hit number</param>
        /// <param name="showAnimation">Whether to show animation</param>
        void ShowAnimation(object id, IBattler user, IList<IBattler> targets, int hitNum = 0, bool showAnimation = true);
    }

    /// <summary>
    /// Interface for moves that hit all foes and power up in Psychic Terrain.
    /// Examples: Expanding Force
    /// </summary>
    public interface IHitsAllFoesAndPowersUpInPsychicTerrain
    {
        /// <summary>
        /// Modifies targeting to hit all foes in Psychic Terrain.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <returns>The appropriate target type</returns>
        object Target(IBattler user);

        /// <summary>
        /// Increases base damage in Psychic Terrain.
        /// </summary>
        /// <param name="baseDmg">The base damage</param>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <returns>Modified damage value</returns>
        int BaseDamage(int baseDmg, IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for moves that cause damage on next Fire move use.
    /// Examples: Powder
    /// </summary>
    public interface ITargetNextFireMoveDamagesTarget
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
        /// Checks if the move fails due to target already being powdered.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <param name="show_message">Whether to show failure message</param>
        /// <returns>True if the move fails against the target</returns>
        bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);

        /// <summary>
        /// Applies the powder effect to the target.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectAgainstTarget(IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for Fusion Bolt powering up after Fusion Flare.
    /// Examples: Fusion Bolt
    /// </summary>
    public interface IDoublePowerAfterFusionFlare
    {
        /// <summary>
        /// Checks if power should be doubled based on Fusion Flare usage.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="specialUsage">Special usage parameter</param>
        void ChangeUsageCounters(IBattler user, object specialUsage);

        /// <summary>
        /// Doubles base damage if Fusion Flare was used this turn.
        /// </summary>
        /// <param name="damageMult">The damage multiplier</param>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <returns>Modified damage multiplier</returns>
        float BaseDamageMultiplier(float damageMult, IBattler user, IBattler target);

        /// <summary>
        /// Sets the Fusion Bolt flag for the field.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        void EffectGeneral(IBattler user);

        /// <summary>
        /// Shows charged animation if powered up or critical hit.
        /// </summary>
        /// <param name="id">Animation ID</param>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <param name="hitNum">Hit number</param>
        /// <param name="showAnimation">Whether to show animation</param>
        void ShowAnimation(object id, IBattler user, IList<IBattler> targets, int hitNum = 0, bool showAnimation = true);
    }

    /// <summary>
    /// Interface for Fusion Flare powering up after Fusion Bolt.
    /// Examples: Fusion Flare
    /// </summary>
    public interface IDoublePowerAfterFusionBolt : IDoublePowerAfterFusionFlare
    {
        // Inherits same functionality as Fusion Bolt but with reversed conditions
    }

    /// <summary>
    /// Interface for moves that power up ally's next move.
    /// Examples: Helping Hand
    /// </summary>
    public interface IPowerUpAllyMove
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
        /// Applies Helping Hand effect to the target ally.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectAgainstTarget(IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for counter moves that respond to physical attacks.
    /// Examples: Counter
    /// </summary>
    public interface ICounterPhysicalDamage
    {
        /// <summary>
        /// Adds the appropriate target for the counter attack.
        /// </summary>
        /// <param name="targets">Current target list</param>
        /// <param name="user">The Pokemon using the move</param>
        void AddTarget(IList<IBattler> targets, IBattler user);

        /// <summary>
        /// Checks if the move fails due to no valid target.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <returns>True if the move fails</returns>
        bool MoveFailed(IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Calculates fixed damage based on stored counter damage.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <returns>Double the physical damage received</returns>
        int FixedDamage(IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for counter moves that respond to special attacks.
    /// Examples: Mirror Coat
    /// </summary>
    public interface ICounterSpecialDamage : ICounterPhysicalDamage
    {
        // Same structure as Counter but targets special attack damage
    }

    /// <summary>
    /// Interface for Metal Burst that counters with 1.5x damage.
    /// Examples: Metal Burst
    /// </summary>
    public interface ICounterDamagePlusHalf : ICounterPhysicalDamage
    {
        // Same structure as Counter but with 1.5x multiplier instead of 2x
    }

    /// <summary>
    /// Interface for Stockpile increasing stats and stockpile count.
    /// Examples: Stockpile
    /// </summary>
    public interface IUserAddStockpileRaiseDefSpDef1
    {
        /// <summary>
        /// Checks if the move can be snatched.
        /// </summary>
        /// <returns>True if snatchable</returns>
        bool canSnatch();

        /// <summary>
        /// Checks if the move fails due to maximum stockpile reached.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <returns>True if the move fails</returns>
        bool MoveFailed(IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Increases stockpile count and raises Defense and Special Defense.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        void EffectGeneral(IBattler user);
    }

    /// <summary>
    /// Interface for Spit Up dealing damage based on stockpile.
    /// Examples: Spit Up
    /// </summary>
    public interface IPowerDependsOnUserStockpile
    {
        /// <summary>
        /// Checks if the move fails due to no stockpile.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <returns>True if the move fails</returns>
        bool MoveFailed(IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Calculates damage based on stockpile count.
        /// </summary>
        /// <param name="baseDmg">The base damage</param>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <returns>100 times the stockpile count</returns>
        int BaseDamage(int baseDmg, IBattler user, IBattler target);

        /// <summary>
        /// Resets stockpile and lowers stats after successful hit.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectAfterAllHits(IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for Swallow healing based on stockpile.
    /// Examples: Swallow
    /// </summary>
    public interface IHealUserDependingOnUserStockpile
    {
        /// <summary>
        /// Checks if this is a healing move.
        /// </summary>
        /// <returns>True for healing moves</returns>
        bool healingMove();

        /// <summary>
        /// Checks if the move can be snatched.
        /// </summary>
        /// <returns>True if snatchable</returns>
        bool canSnatch();

        /// <summary>
        /// Checks if the move fails due to no stockpile or healing.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <returns>True if the move fails</returns>
        bool MoveFailed(IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Heals based on stockpile count and resets stockpile effects.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        void EffectGeneral(IBattler user);
    }

    /// <summary>
    /// Interface for Pledge moves that combo with other Pledge moves.
    /// Examples: Grass Pledge, Fire Pledge, Water Pledge
    /// </summary>
    //public interface IPledgeMove
    //{
    //	/// <summary>
    //	/// Gets the combo configurations for this Pledge move.
    //	/// </summary>
    //	object combos { get; }
    //}

    /// <summary>
    /// Interface for moves that call other moves like the last one used globally.
    /// Examples: Copycat
    /// </summary>
    public interface IUseLastMoveUsed
    {
        /// <summary>
        /// Gets the list of moves that cannot be copied.
        /// </summary>
        object moveBlacklist { get; }

        /// <summary>
        /// Indicates this move calls another move.
        /// </summary>
        /// <returns>True for move-calling moves</returns>
        bool callsAnotherMove();

        /// <summary>
        /// Stores the move to be copied based on last move used.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="specialUsage">Special usage parameter</param>
        void ChangeUsageCounters(IBattler user, object specialUsage);

        /// <summary>
        /// Checks if the move fails due to no valid move to copy.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <returns>True if the move fails</returns>
        bool MoveFailed(IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Uses the copied move.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        void EffectGeneral(IBattler user);
    }

    /// <summary>
    /// Interface for moves that use the target's last move.
    /// Examples: Mirror Move
    /// </summary>
    public interface IUseLastMoveUsedByTarget
    {
        /// <summary>
        /// Checks if this move ignores substitutes.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <returns>True if move ignores substitutes</returns>
        bool ignoresSubstitute(IBattler user);

        /// <summary>
        /// Indicates this move calls another move.
        /// </summary>
        /// <returns>True for move-calling moves</returns>
        bool callsAnotherMove();

        /// <summary>
        /// Checks if the move fails due to target's last move being unusable.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <param name="show_message">Whether to show failure message</param>
        /// <returns>True if the move fails against the target</returns>
        bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);

        /// <summary>
        /// Uses the target's last used move.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectAgainstTarget(IBattler user, IBattler target);

        /// <summary>
        /// Shows no animation for Mirror Move.
        /// </summary>
        /// <param name="id">Animation ID</param>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <param name="hitNum">Hit number</param>
        /// <param name="showAnimation">Whether to show animation</param>
        void ShowAnimation(object id, IBattler user, IList<IBattler> targets, int hitNum = 0, bool showAnimation = true);
    }

    /// <summary>
    /// Interface for moves that use the target's intended move with boosted power.
    /// Examples: Me First
    /// </summary>
    public interface IUseMoveTargetIsAboutToUse
    {
        /// <summary>
        /// Gets the list of moves that cannot be used by Me First.
        /// </summary>
        object moveBlacklist { get; }

        /// <summary>
        /// Checks if this move ignores substitutes.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <returns>True if move ignores substitutes</returns>
        bool ignoresSubstitute(IBattler user);

        /// <summary>
        /// Indicates this move calls another move.
        /// </summary>
        /// <returns>True for move-calling moves</returns>
        bool callsAnotherMove();

        /// <summary>
        /// Checks if the move fails due to target's intended move being invalid.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <param name="show_message">Whether to show failure message</param>
        /// <returns>True if the move fails against the target</returns>
        bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);

        /// <summary>
        /// Uses the target's intended move with Me First boost.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectAgainstTarget(IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for moves that change based on environment.
    /// Examples: Nature Power
    /// </summary>
    public interface IUseMoveDependingOnEnvironment
    {
        /// <summary>
        /// Gets the move that Nature Power will become.
        /// </summary>
        object npMove { get; }

        /// <summary>
        /// Indicates this move calls another move.
        /// </summary>
        /// <returns>True for move-calling moves</returns>
        bool callsAnotherMove();

        /// <summary>
        /// Determines which move to use based on environment.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        void OnStartUse(IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Uses the environment-determined move.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectAgainstTarget(IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for moves that use random moves.
    /// Examples: Metronome
    /// </summary>
    public interface IUseRandomMove
    {
        /// <summary>
        /// Gets the list of moves that cannot be selected by Metronome.
        /// </summary>
        object moveBlacklist { get; }

        /// <summary>
        /// Indicates this move calls another move.
        /// </summary>
        /// <returns>True for move-calling moves</returns>
        bool callsAnotherMove();

        /// <summary>
        /// Selects a random valid move to use.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <returns>True if no valid move could be selected</returns>
        bool MoveFailed(IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Uses the randomly selected move.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        void EffectGeneral(IBattler user);
    }

    /// <summary>
    /// Interface for moves that use random moves from the user's party.
    /// Examples: Assist
    /// </summary>
    public interface IUseRandomMoveFromUserParty : IUseRandomMove
    {
        // Inherits structure from UseRandomMove but with party move selection
    }

    /// <summary>
    /// Interface for moves that use random user moves while asleep.
    /// Examples: Sleep Talk
    /// </summary>
    public interface IUseRandomUserMoveIfAsleep
    {
        /// <summary>
        /// Gets the list of moves that cannot be used by Sleep Talk.
        /// </summary>
        object moveBlacklist { get; }

        /// <summary>
        /// Indicates this move can be used while asleep.
        /// </summary>
        /// <returns>True for moves usable while asleep</returns>
        bool usableWhenAsleep();

        /// <summary>
        /// Indicates this move calls another move.
        /// </summary>
        /// <returns>True for move-calling moves</returns>
        bool callsAnotherMove();

        /// <summary>
        /// Checks if move fails due to not being asleep or no valid moves.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <returns>True if the move fails</returns>
        bool MoveFailed(IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Uses a random move from the user's moveset.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        void EffectGeneral(IBattler user);
    }

    /// <summary>
    /// Interface for moves that reflect status moves back to their user.
    /// Examples: Magic Coat
    /// </summary>
    public interface IBounceBackProblemCausingStatusMoves
    {
        /// <summary>
        /// Sets up Magic Coat effect to reflect moves back.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        void EffectGeneral(IBattler user);
    }

    /// <summary>
    /// Interface for moves that steal beneficial moves.
    /// Examples: Snatch
    /// </summary>
    public interface IStealAndUseBeneficialStatusMove
    {
        /// <summary>
        /// Sets up Snatch effect with priority over other Snatch users.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        void EffectGeneral(IBattler user);
    }

    /// <summary>
    /// Interface for moves that replace themselves with target's last move temporarily.
    /// Examples: Mimic
    /// </summary>
    public interface IReplaceMoveThisBattleWithTargetLastMoveUsed
    {
        /// <summary>
        /// Gets the list of moves that cannot be mimicked.
        /// </summary>
        object moveBlacklist { get; }

        /// <summary>
        /// Checks if this move ignores substitutes.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <returns>True if move ignores substitutes</returns>
        bool ignoresSubstitute(IBattler user);

        /// <summary>
        /// Checks if move fails due to user conditions.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <returns>True if the move fails</returns>
        bool MoveFailed(IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Checks if the move fails due to target's last move being invalid.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <param name="show_message">Whether to show failure message</param>
        /// <returns>True if the move fails against the target</returns>
        bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);

        /// <summary>
        /// Replaces Mimic with the target's last used move for this battle.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectAgainstTarget(IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for moves that permanently replace themselves with target's last move.
    /// Examples: Sketch
    /// </summary>
    public interface IReplaceMoveWithTargetLastMoveUsed
    {
        /// <summary>
        /// Gets the list of moves that cannot be sketched.
        /// </summary>
        object moveBlacklist { get; }

        /// <summary>
        /// Checks if this move ignores substitutes.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <returns>True if move ignores substitutes</returns>
        bool ignoresSubstitute(IBattler user);

        /// <summary>
        /// Checks if move fails due to user conditions.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <returns>True if the move fails</returns>
        bool MoveFailed(IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Checks if the move fails due to target's last move being invalid.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <param name="show_message">Whether to show failure message</param>
        /// <returns>True if the move fails against the target</returns>
        bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);

        /// <summary>
        /// Permanently replaces Sketch with the target's last used move.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectAgainstTarget(IBattler user, IBattler target);
    }
}