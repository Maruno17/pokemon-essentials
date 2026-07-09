using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for multi-hit move effects, handling moves that strike multiple times or across multiple turns.
    /// Provides functionality for moves like Twineedle, Triple Kick, Beat Up, Hyper Beam, Solar Beam, and Bide.
    /// </summary>
    public interface IBattleMoveEffectsMultiHit : IBattleMove
    {
    }

    /// <summary>
    /// Interface for moves that hit twice in succession.
    /// </summary>
    public interface IHitTwoTimes
    {
        /// <summary>
        /// Checks if this is a multi-hit move.
        /// </summary>
        /// <returns>True for two-hit moves</returns>
        bool multiHitMove();

        /// <summary>
        /// Gets the number of hits for this move.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <returns>Number of hits (2)</returns>
        int NumHits(IBattler user, IList<IBattler> targets);
    }

    /// <summary>
    /// Interface for moves that hit twice and may poison on each hit.
    /// Examples: Twineedle
    /// </summary>
    public interface IHitTwoTimesPoisonTarget : IHitTwoTimes
    {
        // Inherits multi-hit functionality and adds poison effect
    }

    /// <summary>
    /// Interface for moves that hit twice and cause flinching.
    /// Examples: Double Iron Bash
    /// </summary>
    public interface IHitTwoTimesFlinchTarget : IHitTwoTimes
    {
        // Inherits multi-hit functionality and adds flinch effect
    }

    /// <summary>
    /// Interface for moves that hit in 2 volleys with special targeting logic.
    /// Examples: Dragon Darts
    /// </summary>
    public interface IHitTwoTimesTargetThenTargetAlly
    {
        /// <summary>
        /// Gets the number of hits per volley.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <returns>Number of hits per volley</returns>
        int NumHits(IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Checks if this move repeats hits.
        /// </summary>
        /// <returns>True if the move repeats</returns>
        bool RepeatHit();

        /// <summary>
        /// Modifies the target list to include ally targeting.
        /// </summary>
        /// <param name="targets">Current target list</param>
        /// <param name="user">The Pokemon using the move</param>
        void ModifyTargets(IList<IBattler> targets, IBattler user);

        /// <summary>
        /// Determines whether to show failure messages for multi-target scenarios.
        /// </summary>
        /// <param name="targets">The target Pokemon</param>
        /// <returns>True if failure messages should be shown</returns>
        bool ShowFailMessages(IList<IBattler> targets);

        /// <summary>
        /// Designates which targets to hit for a specific hit number.
        /// </summary>
        /// <param name="targets">Available targets</param>
        /// <param name="hitNum">The hit number</param>
        /// <returns>Targets for this hit</returns>
        object DesignateTargetsForHit(IList<IBattler> targets, int hitNum);
    }

    /// <summary>
    /// Interface for moves that hit three times with increasing power.
    /// Examples: Triple Kick
    /// </summary>
    public interface IHitThreeTimesPowersUpWithEachHit
    {
        /// <summary>
        /// Checks if this is a multi-hit move.
        /// </summary>
        /// <returns>True for three-hit moves</returns>
        bool multiHitMove();

        /// <summary>
        /// Gets the number of hits for this move.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <returns>Number of hits (3)</returns>
        int NumHits(IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Determines if accuracy should be checked per hit.
        /// </summary>
        /// <returns>True if accuracy is checked per hit</returns>
        bool successCheckPerHit();

        /// <summary>
        /// Initializes variables when the move starts.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        void OnStartUse(IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Calculates base damage with power increase per hit.
        /// </summary>
        /// <param name="baseDmg">The base damage</param>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <returns>Modified damage value</returns>
        int BaseDamage(int baseDmg, IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for moves that hit three times and always land critical hits.
    /// Examples: Surging Strikes
    /// </summary>
    public interface IHitThreeTimesAlwaysCriticalHit
    {
        /// <summary>
        /// Checks if this is a multi-hit move.
        /// </summary>
        /// <returns>True for three-hit moves</returns>
        bool multiHitMove();

        /// <summary>
        /// Gets the number of hits for this move.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <returns>Number of hits (3)</returns>
        int NumHits(IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Overrides critical hit calculation to guarantee crits.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <returns>Critical hit override value</returns>
        int CritialOverride(IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for moves that hit 2-5 times with random distribution.
    /// Examples: Fury Attack, Pin Missile, Rock Blast
    /// </summary>
    public interface IHitTwoToFiveTimes
    {
        /// <summary>
        /// Checks if this is a multi-hit move.
        /// </summary>
        /// <returns>True for multi-hit moves</returns>
        bool multiHitMove();

        /// <summary>
        /// Gets the random number of hits for this move.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <returns>Number of hits (2-5)</returns>
        int NumHits(IBattler user, IList<IBattler> targets);
    }

    /// <summary>
    /// Interface for moves that hit 2-5 times or 3 times for Ash Greninja.
    /// Examples: Water Shuriken
    /// </summary>
    public interface IHitTwoToFiveTimesOrThreeForAshGreninja : IHitTwoToFiveTimes
    {
        /// <summary>
        /// Calculates base damage with special power for Ash Greninja.
        /// </summary>
        /// <param name="baseDmg">The base damage</param>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <returns>Modified damage value</returns>
        int BaseDamage(int baseDmg, IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for moves that hit 2-5 times and modify user stats after.
    /// Examples: Scale Shot
    /// </summary>
    public interface IHitTwoToFiveTimesRaiseUserSpd1LowerUserDef1 : IHitTwoToFiveTimes
    {
        /// <summary>
        /// Applies stat changes after all hits connect.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectAfterAllHits(IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for moves that hit once per party member.
    /// Examples: Beat Up
    /// </summary>
    public interface IHitOncePerUserTeamMember
    {
        /// <summary>
        /// Checks if this is a multi-hit move.
        /// </summary>
        /// <returns>True for team-based multi-hit moves</returns>
        bool multiHitMove();

        /// <summary>
        /// Checks if the move fails due to no valid party members.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <returns>True if the move fails</returns>
        bool MoveFailed(IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Gets the number of hits based on party members.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <returns>Number of party members that can participate</returns>
        int NumHits(IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Calculates damage based on each party member's Attack stat.
        /// </summary>
        /// <param name="baseDmg">The base damage</param>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <returns>Damage based on party member stats</returns>
        int BaseDamage(int baseDmg, IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for moves that attack and skip the next turn.
    /// Examples: Hyper Beam, Giga Impact
    /// </summary>
    public interface IAttackAndSkipNextTurn
    {
        /// <summary>
        /// Applies the effect that forces the user to skip next turn.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        void EffectGeneral(IBattler user);
    }

    /// <summary>
    /// Interface for two-turn attacks with charging phase.
    /// Examples: Razor Wind, Solar Beam, Sky Attack
    /// </summary>
    public interface ITwoTurnAttack
    {
        /// <summary>
        /// Displays the message for the charging turn.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        void ChargingTurnMessage(IBattler user, IList<IBattler> targets);
    }

    /// <summary>
    /// Interface for Solar Beam-type moves that benefit from sun.
    /// Examples: Solar Beam, Solar Blade
    /// </summary>
    public interface ITwoTurnAttackOneTurnInSun : ITwoTurnAttack
    {
        /// <summary>
        /// Determines if this is the charging turn, accounting for sun.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <returns>True if this is a charging turn</returns>
        bool IsChargingTurn(IBattler user);

        /// <summary>
        /// Modifies base damage based on weather conditions.
        /// </summary>
        /// <param name="damageMult">The damage multiplier</param>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <returns>Modified damage multiplier</returns>
        float BaseDamageMultiplier(float damageMult, IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for moves that make the user semi-invulnerable.
    /// Examples: Fly, Dig, Dive
    /// </summary>
    public interface ITwoTurnAttackInvulnerable : ITwoTurnAttack
    {
        /// <summary>
        /// Checks if the move is unusable in Gravity.
        /// </summary>
        /// <returns>True if unusable in Gravity</returns>
        bool unusableInGravity();
    }

    /// <summary>
    /// Interface for multi-turn attacks that prevent sleeping.
    /// Examples: Uproar
    /// </summary>
    public interface IMultiTurnAttackPreventSleeping
    {
        /// <summary>
        /// Applies the general effect of preventing sleep and waking up sleeping Pokemon.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        void EffectGeneral(IBattler user);
    }

    /// <summary>
    /// Interface for multi-turn attacks that confuse the user at the end.
    /// Examples: Outrage, Petal Dance, Thrash
    /// </summary>
    public interface IMultiTurnAttackConfuseUserAtEnd
    {
        /// <summary>
        /// Handles the confusion effect after all hits are completed.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectAfterAllHits(IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for moves that power up each turn and benefit from Defense Curl.
    /// Examples: Rollout, Ice Ball
    /// </summary>
    public interface IMultiTurnAttackPowersUpEachTurn
    {
        /// <summary>
        /// Gets the number of hits per turn.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <returns>Number of hits (1)</returns>
        int NumHits(IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Calculates damage with exponential power increase.
        /// </summary>
        /// <param name="baseDmg">The base damage</param>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <returns>Modified damage with power scaling</returns>
        int BaseDamage(int baseDmg, IBattler user, IBattler target);

        /// <summary>
        /// Manages the rollout counter after each hit.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        void EffectAfterAllHits(IBattler user, IBattler target);
    }

    /// <summary>
    /// Interface for Bide, which stores damage and returns double.
    /// </summary>
    public interface IMultiTurnAttackBideThenReturnDoubleDamage
    {
        /// <summary>
        /// Adds the target for Bide's attack turn.
        /// </summary>
        /// <param name="targets">Current target list</param>
        /// <param name="user">The Pokemon using the move</param>
        void AddTarget(IList<IBattler> targets, IBattler user);

        /// <summary>
        /// Checks if Bide fails due to no stored damage.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <returns>True if the move fails</returns>
        bool MoveFailed(IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Initializes move state for charging or attacking turn.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        void OnStartUse(IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Displays appropriate message for charging or attacking phase.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        void DisplayUseMessage(IBattler user);

        /// <summary>
        /// Determines if this is a damaging turn.
        /// </summary>
        /// <returns>True if this turn deals damage</returns>
        bool DamagingMove();

        /// <summary>
        /// Calculates fixed damage based on stored damage.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="target">The target Pokemon</param>
        /// <returns>Double the stored damage</returns>
        int FixedDamage(IBattler user, IBattler target);

        /// <summary>
        /// Manages Bide's counter and initialization.
        /// </summary>
        /// <param name="user">The Pokemon using the move</param>
        void EffectGeneral(IBattler user);

        /// <summary>
        /// Shows appropriate animation for charging or attacking phase.
        /// </summary>
        /// <param name="id">Animation ID</param>
        /// <param name="user">The Pokemon using the move</param>
        /// <param name="targets">The target Pokemon</param>
        /// <param name="hitNum">Hit number</param>
        /// <param name="showAnimation">Whether to show animation</param>
        void ShowAnimation(object id, IBattler user, IList<IBattler> targets, int hitNum = 0, bool showAnimation = true);
    }
}