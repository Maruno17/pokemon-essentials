using System;
using System.Collections.Generic;

namespace PokemonEssentials.Framework
{
    /// <summary>
    /// Interface for AI handlers related to multi-hit moves and special attack patterns.
    /// Manages scoring and evaluation for moves that hit multiple times or have complex turn sequences.
    /// </summary>
    public interface IAIMoveEffectsMultiHit
    {
        /// <summary>
        /// Calculates the base power for moves that hit exactly two times.
        /// </summary>
        /// <param name="power">The original power of the move.</param>
        /// <param name="move">The move being used.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target of the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The calculated base power for the multi-hit move.</returns>
        int calculateHitTwoTimesPower(int power, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores the effectiveness of moves that hit two times against a target.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the two-hit move.</returns>
        int scoreHitTwoTimesEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that hit two times and also poison the target.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score combining multi-hit and poison effects.</returns>
        int scoreHitTwoTimesPoisonTargetEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that hit two times and can flinch the target.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score combining multi-hit and flinch effects.</returns>
        int scoreHitTwoTimesFlinchTargetEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Calculates power for moves that hit the target and then the target's ally.
        /// </summary>
        /// <param name="power">The original power of the move.</param>
        /// <param name="move">The move being used.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The primary target of the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The calculated base power for the dual-target move.</returns>
        int calculateHitTwoTimesTargetThenTargetAllyPower(int power, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Calculates power for moves that hit three times with increasing power each hit.
        /// </summary>
        /// <param name="power">The original power of the move.</param>
        /// <param name="move">The move being used.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target of the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The calculated cumulative power for the escalating multi-hit move.</returns>
        int calculateHitThreeTimesPowersUpPower(int power, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that hit three times with increasing power.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the escalating multi-hit move.</returns>
        int scoreHitThreeTimesPowersUpEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Calculates power for moves that hit 2-5 times randomly.
        /// </summary>
        /// <param name="power">The original power of the move.</param>
        /// <param name="move">The move being used.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target of the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The calculated average power for the variable multi-hit move.</returns>
        int calculateHitTwoToFiveTimesPower(int power, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that hit 2-5 times randomly.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the variable multi-hit move.</returns>
        int scoreHitTwoToFiveTimesEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Calculates power for moves that hit 2-5 times or 3 times for Ash-Greninja.
        /// </summary>
        /// <param name="power">The original power of the move.</param>
        /// <param name="move">The move being used.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target of the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The calculated power based on user form and ability.</returns>
        int calculateHitTwoToFiveTimesOrThreeForAshGreninjaPower(int power, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that hit 2-5 times and affect user's stats.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score combining multi-hit and stat change effects.</returns>
        int scoreHitTwoToFiveTimesRaiseUserSpdLowerUserDefEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Checks if moves that hit once per team member will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkHitOncePerUserTeamMemberFailure(object move, object user, object ai, object battle);

        /// <summary>
        /// Calculates power for moves that hit once per healthy team member.
        /// </summary>
        /// <param name="power">The original power of the move.</param>
        /// <param name="move">The move being used.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target of the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The calculated total power based on team member count.</returns>
        int calculateHitOncePerUserTeamMemberPower(int power, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that hit once per team member.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the team-based multi-hit move.</returns>
        int scoreHitOncePerUserTeamMemberEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that attack and cause the user to skip the next turn.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score considering the recharge turn.</returns>
        int scoreAttackAndSkipNextTurnEffect(int score, object move, object user, object ai, object battle);

        /// <summary>
        /// Scores moves that require two turns to execute.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the two-turn attack.</returns>
        int scoreTwoTurnAttackEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Calculates power for two-turn attacks that become one-turn in sun.
        /// </summary>
        /// <param name="power">The original power of the move.</param>
        /// <param name="move">The move being used.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target of the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The calculated power based on weather conditions.</returns>
        int calculateTwoTurnAttackOneTurnInSunPower(int power, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores two-turn attacks that become one-turn in sun.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score based on weather conditions.</returns>
        int scoreTwoTurnAttackOneTurnInSunEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores two-turn attacks that can paralyze the target.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score combining two-turn and paralysis effects.</returns>
        int scoreTwoTurnAttackParalyzeTargetEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores two-turn attacks that can burn the target.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score combining two-turn and burn effects.</returns>
        int scoreTwoTurnAttackBurnTargetEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores two-turn attacks that can flinch the target.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score combining two-turn and flinch effects.</returns>
        int scoreTwoTurnAttackFlinchTargetEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores two-turn attacks that raise user's Special Attack, Special Defense, and Speed by 2.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score combining two-turn and stat boost effects.</returns>
        int scoreTwoTurnAttackRaiseUserSpAtkSpDefSpd2Effect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores two-turn attacks that raise user's Defense during charge turn.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the defensive charging move.</returns>
        int scoreTwoTurnAttackChargeRaiseUserDefense1Effect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores two-turn attacks that raise user's Special Attack during charge turn.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the special attack charging move.</returns>
        int scoreTwoTurnAttackChargeRaiseUserSpAtk1Effect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores two-turn attacks that make user invulnerable underground (like Dig).
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the underground semi-invulnerable move.</returns>
        int scoreTwoTurnAttackInvulnerableUndergroundEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores two-turn attacks that make user invulnerable underwater (like Dive).
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the underwater semi-invulnerable move.</returns>
        int scoreTwoTurnAttackInvulnerableUnderwaterEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores two-turn attacks that make user invulnerable in the sky (like Fly).
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the flying semi-invulnerable move.</returns>
        int scoreTwoTurnAttackInvulnerableInSkyEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores two-turn attacks that fly in the sky and can paralyze the target.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score combining flying and paralysis effects.</returns>
        int scoreTwoTurnAttackInvulnerableInSkyParalyzeTargetEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Checks if Sky Drop will fail against the target.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being checked against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail against the target, false otherwise.</returns>
        bool checkTwoTurnAttackInvulnerableInSkyTargetCannotActFailure(object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores two-turn attacks that remove protections while being invulnerable.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the protection-removing invulnerable move.</returns>
        int scoreTwoTurnAttackInvulnerableRemoveProtectionsEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Calculates power for multi-turn attacks that power up each turn (like Rollout).
        /// </summary>
        /// <param name="power">The original power of the move.</param>
        /// <param name="move">The move being used.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target of the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The estimated average power over multiple turns.</returns>
        int calculateMultiTurnAttackPowersUpEachTurnPower(int power, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Calculates power for Bide, which stores damage and returns it doubled.
        /// </summary>
        /// <param name="power">The original power of the move.</param>
        /// <param name="move">The move being used.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target of the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>A representative power value for Bide.</returns>
        int calculateMultiTurnAttackBideThenReturnDoubleDamagePower(int power, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores Bide based on battle conditions and user HP.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for Bide.</returns>
        int scoreMultiTurnAttackBideThenReturnDoubleDamageEffect(int score, object move, object user, object ai, object battle);
    }

    /// <summary>
    /// Interface for AI handlers that deal with complex timing and turn-based move mechanics.
    /// Provides specialized evaluation for moves with unusual execution patterns.
    /// </summary>
    public interface IAIMultiTurnMoveHandlers
    {
        /// <summary>
        /// Evaluates whether a multi-turn move is worth using based on battle state.
        /// </summary>
        /// <param name="move">The multi-turn move being considered.</param>
        /// <param name="user">The Pokemon that would use the move.</param>
        /// <param name="targets">The potential targets of the move.</param>
        /// <param name="battle">The current battle state.</param>
        /// <returns>True if the multi-turn move is recommended, false otherwise.</returns>
        bool shouldUseMultiTurnMove(object move, object user, IList<object> targets, object battle);

        /// <summary>
        /// Calculates the expected effectiveness of multi-hit moves against Substitute.
        /// </summary>
        /// <param name="move">The multi-hit move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target with a Substitute.</param>
        /// <returns>The effectiveness multiplier against Substitute.</returns>
        float calculateMultiHitSubstituteBreaking(object move, object user, object target);

        /// <summary>
        /// Evaluates the risk-reward ratio of two-turn attacks.
        /// </summary>
        /// <param name="move">The two-turn attack being evaluated.</param>
        /// <param name="user">The Pokemon that would use the move.</param>
        /// <param name="opponent">The opposing Pokemon.</param>
        /// <returns>A risk assessment score.</returns>
        int assessTwoTurnAttackRisk(object move, object user, object opponent);

        /// <summary>
        /// Determines if a Pokemon should commit to a multi-turn sequence.
        /// </summary>
        /// <param name="user">The Pokemon considering the multi-turn move.</param>
        /// <param name="moveDuration">The number of turns the move will take.</param>
        /// <param name="expectedDamage">The expected damage per turn.</param>
        /// <param name="battleContext">The current battle context.</param>
        /// <returns>True if the commitment is worthwhile, false otherwise.</returns>
        bool shouldCommitToMultiTurnSequence(object user, int moveDuration, int expectedDamage, object battleContext);
    }
}