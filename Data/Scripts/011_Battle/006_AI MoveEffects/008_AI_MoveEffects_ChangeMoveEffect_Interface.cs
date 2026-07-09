using System;
using System.Collections.Generic;

namespace PokemonEssentials.Framework
{
    /// <summary>
    /// Interface for AI handlers related to moves that change their effects or redirect attacks.
    /// Manages scoring and evaluation for moves with variable effects, redirection, and move copying abilities.
    /// </summary>
    public interface IAIMoveEffectsChangeMoveEffect
    {
        /// <summary>
        /// Scores moves that redirect all attacks to the user.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the attack redirection move.</returns>
        int scoreRedirectAllMovesToUserEffect(int score, object move, object user, object ai, object battle);

        /// <summary>
        /// Scores moves that redirect all attacks to a target.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the target spotlighting move.</returns>
        int scoreRedirectAllMovesToTargetEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Calculates power for moves that randomly damage or heal the target.
        /// </summary>
        /// <param name="power">The original power of the move.</param>
        /// <param name="move">The move being used.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target of the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The average power for the random effect move.</returns>
        int calculateRandomlyDamageOrHealTargetPower(int power, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that randomly damage or heal the target.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the random effect move.</returns>
        int scoreRandomlyDamageOrHealTargetEffect(int score, object move, object user, object ai, object battle);

        /// <summary>
        /// Checks if moves that heal allies or damage foes will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being checked against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkHealAllyOrDamageFoeFailure(object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that heal allies or damage foes.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the dual-purpose move.</returns>
        int scoreHealAllyOrDamageFoeEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Checks if Curse (Ghost-type version) or stat-changing version will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkCurseTargetOrLowerUserSpd1RaiseUserAtkDef1Failure(object move, object user, object ai, object battle);

        /// <summary>
        /// Checks if Curse will fail when used against a specific target.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being checked against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail against the target, false otherwise.</returns>
        bool checkCurseTargetOrLowerUserSpd1RaiseUserAtkDef1TargetFailure(object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores the stat-changing version of Curse (non-Ghost type).
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the stat-changing Curse.</returns>
        int scoreCurseTargetOrLowerUserSpd1RaiseUserAtkDef1Effect(int score, object move, object user, object ai, object battle);

        /// <summary>
        /// Scores the Ghost-type version of Curse that damages the target.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the damaging Curse.</returns>
        int scoreCurseTargetOrLowerUserSpd1RaiseUserAtkDef1TargetEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves whose effects depend on the battlefield environment.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score based on the move's current environment-based effect.</returns>
        int scoreEffectDependsOnEnvironmentEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Calculates power for moves that hit all foes and power up in Psychic Terrain.
        /// </summary>
        /// <param name="power">The original power of the move.</param>
        /// <param name="move">The move being used.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target of the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The calculated power based on terrain effects.</returns>
        int calculateHitsAllFoesAndPowersUpInPsychicTerrainPower(int power, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Checks if moves that make Fire moves damage the target will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being checked against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkTargetNextFireMoveDamagesTargetFailure(object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that make the target's Fire moves damage themselves.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the Fire move redirection effect.</returns>
        int scoreTargetNextFireMoveDamagesTargetEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores Fusion Flare based on ally's knowledge of Fusion Bolt.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for Fusion Flare synergy.</returns>
        int scoreDoublePowerAfterFusionFlareEffect(int score, object move, object user, object ai, object battle);

        /// <summary>
        /// Scores Fusion Bolt based on ally's knowledge of Fusion Flare.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for Fusion Bolt synergy.</returns>
        int scoreDoublePowerAfterFusionBoltEffect(int score, object move, object user, object ai, object battle);

        /// <summary>
        /// Checks if moves that power up ally moves will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being checked against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkPowerUpAllyMoveFailure(object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that power up an ally's next move.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the ally support move.</returns>
        int scorePowerUpAllyMoveEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Calculates representative power for Counter (physical damage counter).
        /// </summary>
        /// <param name="power">The original power of the move.</param>
        /// <param name="move">The move being used.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target of the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>A representative power value for Counter.</returns>
        int calculateCounterPhysicalDamagePower(int power, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores Counter based on opponents' physical attack patterns.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for Counter.</returns>
        int scoreCounterPhysicalDamageEffect(int score, object move, object user, object ai, object battle);

        /// <summary>
        /// Calculates representative power for Mirror Coat (special damage counter).
        /// </summary>
        /// <param name="power">The original power of the move.</param>
        /// <param name="move">The move being used.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target of the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>A representative power value for Mirror Coat.</returns>
        int calculateCounterSpecialDamagePower(int power, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores Mirror Coat based on opponents' special attack patterns.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for Mirror Coat.</returns>
        int scoreCounterSpecialDamageEffect(int score, object move, object user, object ai, object battle);

        /// <summary>
        /// Calculates representative power for Metal Burst (damage plus half counter).
        /// </summary>
        /// <param name="power">The original power of the move.</param>
        /// <param name="move">The move being used.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target of the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>A representative power value for Metal Burst.</returns>
        int calculateCounterDamagePlusHalfPower(int power, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores Metal Burst based on damage taken and opponent patterns.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for Metal Burst.</returns>
        int scoreCounterDamagePlusHalfEffect(int score, object move, object user, object ai, object battle);

        /// <summary>
        /// Checks if Stockpile will fail (already at max stacks).
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkUserAddStockpileRaiseDefSpDef1Failure(object move, object user, object ai, object battle);

        /// <summary>
        /// Scores Stockpile based on stat boosts and synergy with other moves.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for Stockpile.</returns>
        int scoreUserAddStockpileRaiseDefSpDef1Effect(int score, object move, object user, object ai, object battle);

        /// <summary>
        /// Checks if Spit Up will fail (no stockpile stacks).
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkPowerDependsOnUserStockpileFailure(object move, object user, object ai, object battle);

        /// <summary>
        /// Calculates power for moves that depend on Stockpile stacks.
        /// </summary>
        /// <param name="power">The original power of the move.</param>
        /// <param name="move">The move being used.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target of the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The calculated power based on Stockpile stacks.</returns>
        int calculatePowerDependsOnUserStockpilePower(int power, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores Spit Up based on current Stockpile stacks.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for Spit Up.</returns>
        int scorePowerDependsOnUserStockpileEffect(int score, object move, object user, object ai, object battle);

        /// <summary>
        /// Checks if Swallow will fail (no stockpile or can't heal).
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkHealUserDependingOnUserStockpileFailure(object move, object user, object ai, object battle);

        /// <summary>
        /// Scores Swallow based on healing potential and Stockpile stacks.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for Swallow.</returns>
        int scoreHealUserDependingOnUserStockpileEffect(int score, object move, object user, object ai, object battle);

        /// <summary>
        /// Scores Grass Pledge based on ally Pledge move synergy.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for Grass Pledge.</returns>
        int scoreGrassPledgeEffect(int score, object move, object user, object ai, object battle);

        /// <summary>
        /// Scores Fire Pledge based on ally Pledge move synergy.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for Fire Pledge.</returns>
        int scoreFirePledgeEffect(int score, object move, object user, object ai, object battle);

        /// <summary>
        /// Scores Water Pledge based on ally Pledge move synergy.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for Water Pledge.</returns>
        int scoreWaterPledgeEffect(int score, object move, object user, object ai, object battle);

        /// <summary>
        /// Checks if moves that copy the last move used will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkUseLastMoveUsedFailure(object move, object user, object ai, object battle);

        /// <summary>
        /// Checks if moves that copy the target's last move will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being checked against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkUseLastMoveUsedByTargetFailure(object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Checks if moves that copy the target's next move will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being checked against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkUseMoveTargetIsAboutToUseFailure(object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that copy the target's next move.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the move copying effect.</returns>
        int scoreUseMoveTargetIsAboutToUseEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Checks if moves that use random moves from the user's party will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkUseRandomMoveFromUserPartyFailure(object move, object user, object ai, object battle);

        /// <summary>
        /// Checks if moves that use random user moves while asleep will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkUseRandomUserMoveIfAsleepFailure(object move, object user, object ai, object battle);

        /// <summary>
        /// Scores moves that bounce back status moves.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the status move reflection.</returns>
        int scoreBounceBackProblemCausingStatusMovesEffect(int score, object move, object user, object ai, object battle);

        /// <summary>
        /// Scores moves that steal and use beneficial status moves.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the move stealing effect.</returns>
        int scoreStealAndUseBeneficialStatusMoveEffect(int score, object move, object user, object ai, object battle);

        /// <summary>
        /// Checks if moves that replace themselves with the target's last move will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkReplaceMoveThisBattleWithTargetLastMoveUsedFailure(object move, object user, object ai, object battle);

        /// <summary>
        /// Checks if move replacement against a specific target will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being checked against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkReplaceMoveThisBattleWithTargetLastMoveUsedTargetFailure(object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that replace themselves with the target's last move.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the move replacement effect.</returns>
        int scoreReplaceMoveThisBattleWithTargetLastMoveUsedEffect(int score, object move, object user, object target, object ai, object battle);
    }

    /// <summary>
    /// Interface for AI handlers that deal with move redirection and targeting manipulation.
    /// Provides specialized evaluation for moves that change attack targets or redirect damage.
    /// </summary>
    public interface IAIMoveRedirection
    {
        /// <summary>
        /// Evaluates the strategic value of redirecting attacks to a specific target.
        /// </summary>
        /// <param name="redirector">The Pokemon performing the redirection.</param>
        /// <param name="originalTarget">The original target of redirected attacks.</param>
        /// <param name="newTarget">The new target for redirected attacks.</param>
        /// <param name="battleContext">The current battle state.</param>
        /// <returns>A value score for the redirection strategy.</returns>
        float evaluateRedirectionValue(object redirector, object originalTarget, object newTarget, object battleContext);

        /// <summary>
        /// Determines if a Pokemon should use a move to redirect attacks to itself.
        /// </summary>
        /// <param name="user">The Pokemon considering self-redirection.</param>
        /// <param name="allies">The allies that would benefit from redirection.</param>
        /// <param name="opponents">The opponents that would have their attacks redirected.</param>
        /// <returns>True if self-redirection is recommended, false otherwise.</returns>
        bool shouldRedirectToSelf(object user, IList<object> allies, IList<object> opponents);

        /// <summary>
        /// Calculates the optimal target for spotlight-type moves.
        /// </summary>
        /// <param name="user">The Pokemon using the spotlight move.</param>
        /// <param name="potentialTargets">The potential targets for the spotlight.</param>
        /// <param name="battleState">The current battle state.</param>
        /// <returns>The optimal target for the spotlight move, or null if none suitable.</returns>
        object calculateOptimalSpotlightTarget(object user, IList<object> potentialTargets, object battleState);

        /// <summary>
        /// Assesses the risk of becoming a redirect target.
        /// </summary>
        /// <param name="target">The Pokemon that would become the redirect target.</param>
        /// <param name="incomingAttacks">The attacks that would be redirected to the target.</param>
        /// <param name="defensiveCapabilities">The target's defensive capabilities.</param>
        /// <returns>A risk score where higher values indicate greater danger.</returns>
        float assessRedirectionRisk(object target, IList<object> incomingAttacks, object defensiveCapabilities);
    }

    /// <summary>
    /// Interface for AI evaluation of counter and reactive moves.
    /// Handles moves that respond to or depend on opponent actions.
    /// </summary>
    public interface IAICounterMoves
    {
        /// <summary>
        /// Evaluates the likelihood that an opponent will use a specific type of attack.
        /// </summary>
        /// <param name="opponent">The opponent being analyzed.</param>
        /// <param name="attackType">The type of attack (physical, special, status).</param>
        /// <param name="battleHistory">Recent battle history and patterns.</param>
        /// <returns>A probability score for the opponent using that attack type.</returns>
        float predictOpponentAttackType(object opponent, string attackType, object battleHistory);

        /// <summary>
        /// Calculates the optimal timing for using counter moves.
        /// </summary>
        /// <param name="user">The Pokemon considering the counter move.</param>
        /// <param name="counterMove">The counter move being considered.</param>
        /// <param name="opponentPatterns">The opponent's attack patterns.</param>
        /// <returns>A timing score where higher values indicate better timing.</returns>
        int calculateCounterMoveTiming(object user, object counterMove, object opponentPatterns);

        /// <summary>
        /// Determines if a Pokemon should prioritize reactive moves over proactive ones.
        /// </summary>
        /// <param name="user">The Pokemon making the decision.</param>
        /// <param name="reactiveMoves">Available reactive moves.</param>
        /// <param name="proactiveMoves">Available proactive moves.</param>
        /// <param name="battleState">The current battle state.</param>
        /// <returns>True if reactive moves should be prioritized, false otherwise.</returns>
        bool shouldPrioritizeReactiveMoves(object user, IList<object> reactiveMoves, IList<object> proactiveMoves, object battleState);

        /// <summary>
        /// Evaluates the risk-reward ratio of using counter moves at low HP.
        /// </summary>
        /// <param name="user">The Pokemon considering the counter move.</param>
        /// <param name="currentHP">The user's current HP percentage.</param>
        /// <param name="expectedCounterDamage">The expected damage from a successful counter.</param>
        /// <returns>A risk-reward assessment score.</returns>
        float assessLowHPCounterStrategy(object user, float currentHP, int expectedCounterDamage);
    }
}