using System;
using System.Collections.Generic;

namespace PokemonEssentials.Framework
{
    /// <summary>
    /// Interface for AI handlers related to healing moves and HP manipulation effects.
    /// Manages scoring and evaluation for moves that restore HP, cause self-damage, or manipulate health states.
    /// </summary>
    public interface IAIMoveEffectsHealing
    {
        /// <summary>
        /// Checks if moves that heal fully and cause sleep will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkHealUserFullyAndFallAsleepFailure(object move, object user, object ai, object battle);

        /// <summary>
        /// Scores moves that heal the user fully but cause sleep.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the full heal and sleep move.</returns>
        int scoreHealUserFullyAndFallAsleepEffect(int score, object move, object user, object ai, object battle);

        /// <summary>
        /// Checks if moves that heal half of total HP will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkHealUserHalfOfTotalHPFailure(object move, object user, object ai, object battle);

        /// <summary>
        /// Scores moves that heal the user for half of their total HP.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the half HP heal move.</returns>
        int scoreHealUserHalfOfTotalHPEffect(int score, object move, object user, object ai, object battle);

        /// <summary>
        /// Scores moves that heal the user based on weather conditions.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score considering weather effects.</returns>
        int scoreHealUserDependingOnWeatherEffect(int score, object move, object user, object ai, object battle);

        /// <summary>
        /// Scores moves that heal the user more effectively in Sandstorm.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score considering Sandstorm effects.</returns>
        int scoreHealUserDependingOnSandstormEffect(int score, object move, object user, object ai, object battle);

        /// <summary>
        /// Scores moves that heal half HP and remove Flying type temporarily.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the heal and type change move.</returns>
        int scoreHealUserHalfOfTotalHPLoseFlyingTypeThisTurnEffect(int score, object move, object user, object ai, object battle);

        /// <summary>
        /// Checks if moves that cure target status and heal user will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being checked against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkCureTargetStatusHealUserHalfOfTotalHPFailure(object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that cure target's status and heal user.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the cure and heal move.</returns>
        int scoreCureTargetStatusHealUserHalfOfTotalHPEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Checks if moves that heal based on target's Attack stat will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being checked against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkHealUserByTargetAttackLowerTargetAttack1Failure(object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that heal user based on target's Attack and lower target's Attack.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the Attack-draining move.</returns>
        int scoreHealUserByTargetAttackLowerTargetAttack1Effect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that heal user by half of damage done.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the damage-draining move.</returns>
        int scoreHealUserByHalfOfDamageDoneEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Checks if moves that heal by damage done only work on sleeping targets.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being checked against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkHealUserByHalfOfDamageDoneIfTargetAsleepFailure(object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that heal user by three quarters of damage done.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the high-drain move.</returns>
        int scoreHealUserByThreeQuartersOfDamageDoneEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Checks if moves that heal user and allies by quarter HP will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being checked against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkHealUserAndAlliesQuarterOfTotalHPFailure(object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that heal user and allies by quarter of total HP.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the group healing move.</returns>
        int scoreHealUserAndAlliesQuarterOfTotalHPEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Checks if moves that heal and cure status for user and allies will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being checked against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkHealUserAndAlliesQuarterOfTotalHPCureStatusFailure(object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that heal user and allies and cure their status conditions.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the group heal and cure move.</returns>
        int scoreHealUserAndAlliesQuarterOfTotalHPCureStatusEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Checks if moves that heal target for half HP will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being checked against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkHealTargetHalfOfTotalHPFailure(object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that heal the target for half of their total HP.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the ally healing move.</returns>
        int scoreHealTargetHalfOfTotalHPEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that heal target based on Grassy Terrain.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score considering terrain effects.</returns>
        int scoreHealTargetDependingOnGrassyTerrainEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Checks if moves that set up delayed healing will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkHealUserPositionNextTurnFailure(object move, object user, object ai, object battle);

        /// <summary>
        /// Scores moves that heal the user's position next turn (like Wish).
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the delayed healing move.</returns>
        int scoreHealUserPositionNextTurnEffect(int score, object move, object user, object ai, object battle);

        /// <summary>
        /// Checks if moves that start continuous healing will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkStartHealUserEachTurnFailure(object move, object user, object ai, object battle);

        /// <summary>
        /// Scores moves that heal the user each turn (like Aqua Ring).
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the continuous healing move.</returns>
        int scoreStartHealUserEachTurnEffect(int score, object move, object user, object ai, object battle);

        /// <summary>
        /// Checks if moves that heal user and trap them will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkStartHealUserEachTurnTrapUserInBattleFailure(object move, object user, object ai, object battle);

        /// <summary>
        /// Scores moves that heal user each turn but trap them (like Ingrain).
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the trapping heal move.</returns>
        int scoreStartHealUserEachTurnTrapUserInBattleEffect(int score, object move, object user, object ai, object battle);

        /// <summary>
        /// Checks if moves that damage sleeping targets each turn will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being checked against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkStartDamageTargetEachTurnIfTargetAsleepFailure(object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that damage sleeping targets each turn (like Nightmare).
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the sleep damage move.</returns>
        int scoreStartDamageTargetEachTurnIfTargetAsleepEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Checks if Leech Seed will fail against the target.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being checked against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkStartLeechSeedTargetFailure(object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores Leech Seed effectiveness against a target.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for Leech Seed.</returns>
        int scoreStartLeechSeedTargetEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that cause user to lose half of their total HP.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the self-damaging move.</returns>
        int scoreUserLosesHalfOfTotalHPEffect(int score, object move, object user, object ai, object battle);

        /// <summary>
        /// Checks if explosive moves that cost half HP will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkUserLosesHalfOfTotalHPExplosiveFailure(object move, object user, object ai, object battle);

        /// <summary>
        /// Checks if explosive moves that cause fainting will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkUserFaintsExplosiveFailure(object move, object user, object ai, object battle);

        /// <summary>
        /// Scores moves that cause the user to faint in an explosion.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the explosive fainting move.</returns>
        int scoreUserFaintsExplosiveEffect(int score, object move, object user, object ai, object battle);

        /// <summary>
        /// Calculates power for explosive moves that power up in Misty Terrain.
        /// </summary>
        /// <param name="power">The original power of the move.</param>
        /// <param name="move">The move being used.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target of the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted power based on terrain.</returns>
        int calculateUserFaintsPowersUpInMistyTerrainExplosivePower(int power, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Calculates power for moves that deal damage equal to user's HP.
        /// </summary>
        /// <param name="power">The original power of the move.</param>
        /// <param name="move">The move being used.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target of the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The user's current HP as power.</returns>
        int calculateUserFaintsFixedDamageUserHPPower(int power, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that cause user to faint and lower target's Attack and Special Attack.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the sacrificial stat-lowering move.</returns>
        int scoreUserFaintsLowerTargetAtkSpAtk2Effect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Checks if moves that faint user and heal replacement will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkUserFaintsHealAndCureReplacementFailure(object move, object user, object ai, object battle);

        /// <summary>
        /// Scores moves that cause user to faint and heal the replacement Pokemon.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the sacrificial healing move.</returns>
        int scoreUserFaintsHealAndCureReplacementEffect(int score, object move, object user, object ai, object battle);

        /// <summary>
        /// Checks if Perish Song will fail against a target.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being checked against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail against the target, false otherwise.</returns>
        bool checkStartPerishCountsForAllBattlersFailure(object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores Perish Song based on battle conditions and team states.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for Perish Song.</returns>
        int scoreStartPerishCountsForAllBattlersEffect(int score, object move, object user, object ai, object battle);

        /// <summary>
        /// Checks if Destiny Bond will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkAttackerFaintsIfUserFaintsFailure(object move, object user, object ai, object battle);

        /// <summary>
        /// Scores Destiny Bond based on user's condition and opponent speed.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for Destiny Bond.</returns>
        int scoreAttackerFaintsIfUserFaintsEffect(int score, object move, object user, object ai, object battle);

        /// <summary>
        /// Scores moves that set attacker's move PP to 0 if user faints.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the PP-draining revenge move.</returns>
        int scoreSetAttackerMovePPTo0IfUserFaintsEffect(int score, object move, object user, object ai, object battle);
    }

    /// <summary>
    /// Interface for AI handlers that evaluate healing strategies and HP management.
    /// Provides specialized evaluation for HP-based decision making in battle.
    /// </summary>
    public interface IAIHealingStrategies
    {
        /// <summary>
        /// Evaluates the value of healing based on current HP and battle situation.
        /// </summary>
        /// <param name="user">The Pokemon considering healing.</param>
        /// <param name="healAmount">The amount of HP that would be restored.</param>
        /// <param name="battleContext">The current battle state.</param>
        /// <returns>A value rating for the healing action.</returns>
        float evaluateHealingValue(object user, int healAmount, object battleContext);

        /// <summary>
        /// Determines if a Pokemon should prioritize healing over attacking.
        /// </summary>
        /// <param name="user">The Pokemon making the decision.</param>
        /// <param name="potentialDamage">The damage the user might take this turn.</param>
        /// <param name="healingMoves">Available healing moves.</param>
        /// <returns>True if healing should be prioritized, false otherwise.</returns>
        bool shouldPrioritizeHealing(object user, int potentialDamage, IList<object> healingMoves);

        /// <summary>
        /// Calculates the risk assessment for self-damaging moves.
        /// </summary>
        /// <param name="user">The Pokemon considering the self-damaging move.</param>
        /// <param name="selfDamage">The amount of self-damage the move would cause.</param>
        /// <param name="expectedBenefit">The expected benefit from using the move.</param>
        /// <returns>A risk score where higher values indicate higher risk.</returns>
        float assessSelfDamageRisk(object user, int selfDamage, int expectedBenefit);

        /// <summary>
        /// Evaluates whether to use a draining move based on target and user conditions.
        /// </summary>
        /// <param name="user">The Pokemon considering the draining move.</param>
        /// <param name="target">The target of the draining move.</param>
        /// <param name="drainPercentage">The percentage of damage that will be restored as HP.</param>
        /// <param name="expectedDamage">The expected damage the move will deal.</param>
        /// <returns>True if the draining move is worthwhile, false otherwise.</returns>
        bool shouldUseDrainingMove(object user, object target, float drainPercentage, int expectedDamage);

        /// <summary>
        /// Calculates the optimal timing for using delayed healing moves like Wish.
        /// </summary>
        /// <param name="user">The Pokemon considering the delayed healing move.</param>
        /// <param name="healAmount">The amount that will be healed next turn.</param>
        /// <param name="currentHP">The user's current HP.</param>
        /// <param name="switchProbability">The probability the user will switch out.</param>
        /// <returns>A timing score where higher values indicate better timing.</returns>
        int calculateDelayedHealingTiming(object user, int healAmount, int currentHP, float switchProbability);
    }
}