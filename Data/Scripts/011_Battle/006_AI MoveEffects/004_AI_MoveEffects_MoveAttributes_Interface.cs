using System;
using PokemonEssentials.Framework;

namespace PokemonEssentials.Framework
{
    /// <summary>
    /// AI Move Effects MoveAttributes handlers interface for power calculations, damage modifiers,
    /// protection mechanics, and various move attribute evaluations. Contains base power calculations,
    /// failure checks, and scoring methods for moves with special damage formulas, protection effects,
    /// and conditional power modifications.
    /// </summary>
    public interface IAiMoveEffectsMoveAttributes
    {
        // Fixed Damage Handlers
        /// <summary>
        /// Base power handler for moves that deal fixed 20 damage.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int FixedDamage20BasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Base power handler for moves that deal fixed 40 damage.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int FixedDamage40BasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Base power handler for moves that deal fixed damage equal to half target's HP.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int FixedDamageHalfTargetHPBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Base power handler for moves that deal fixed damage equal to user's level.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int FixedDamageUserLevelBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Base power handler for moves that deal random damage based on user's level.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int FixedDamageUserLevelRandomBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        // Level-dependent Moves
        /// <summary>
        /// Failure check for moves that lower target's HP to user's HP.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool LowerTargetHPToUserHP(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Base power handler for moves that lower target's HP to user's HP.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int LowerTargetHPToUserHPBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        // OHKO Moves
        /// <summary>
        /// Failure check for One-Hit KO moves.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool OHKO(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Base power handler for One-Hit KO moves.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int OHKOBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for One-Hit KO moves.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int OHKOScore(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for Ice-type One-Hit KO moves.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool OHKOIce(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Base power handler for Ice-type One-Hit KO moves.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int OHKOIceBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for Ice-type One-Hit KO moves.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int OHKOIceScore(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for One-Hit KO moves that hit underground targets.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool OHKOHitsUndergroundTarget(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Base power handler for One-Hit KO moves that hit underground targets.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int OHKOHitsUndergroundTargetBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for One-Hit KO moves that hit underground targets.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int OHKOHitsUndergroundTargetScore(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        // Damage Target and Ally
        /// <summary>
        /// Score handler for moves that damage both target and ally.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int DamageTargetAlly(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        // Variable Power Moves
        /// <summary>
        /// Base power handler for moves with power higher with user's HP.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int PowerHigherWithUserHPBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Base power handler for moves with power lower with user's HP.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int PowerLowerWithUserHPBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Base power handler for moves with power higher with target's HP (100 base).
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int PowerHigherWithTargetHP100BasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Base power handler for moves with power higher with target's HP (120 base).
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int PowerHigherWithTargetHP120BasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Base power handler for moves with power higher with user's happiness.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int PowerHigherWithUserHappinessBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Base power handler for moves with power lower with user's happiness.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int PowerLowerWithUserHappinessBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Base power handler for moves with power higher with user's positive stat stages.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int PowerHigherWithUserPositiveStatStagesBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Base power handler for moves with power higher with target's positive stat stages.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int PowerHigherWithTargetPositiveStatStagesBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Base power handler for moves with power higher when user faster than target.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int PowerHigherWithUserFasterThanTargetBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Base power handler for moves with power higher when target faster than user.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int PowerHigherWithTargetFasterThanUserBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Base power handler for moves with power higher with less PP.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int PowerHigherWithLessPPBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Base power handler for moves with power higher with target's weight.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int PowerHigherWithTargetWeightBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Base power handler for moves with power higher when user heavier than target.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int PowerHigherWithUserHeavierThanTargetBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        // Consecutive Use Moves
        /// <summary>
        /// Base power handler for moves with power higher with consecutive use.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int PowerHigherWithConsecutiveUseBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves with power higher with consecutive use.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int PowerHigherWithConsecutiveUseScore(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Base power handler for moves with power higher with consecutive use on user side.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int PowerHigherWithConsecutiveUseOnUserSideBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        // Random Power Moves
        /// <summary>
        /// Base power handler for moves with random power that double if target underground.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int RandomPowerDoublePowerIfTargetUndergroundBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        // Conditional Power Moves
        /// <summary>
        /// Base power handler for moves that double power if target HP less than half.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int DoublePowerIfTargetHPLessThanHalfBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Base power handler for moves that double power if user poisoned, burned, or paralyzed.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int DoublePowerIfUserPoisonedBurnedParalyzedBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Base power handler for moves that double power if target asleep and cure target.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int DoublePowerIfTargetAsleepCureTargetBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that double power if target asleep and cure target.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int DoublePowerIfTargetAsleepCureTargetScore(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Base power handler for moves that double power if target poisoned.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int DoublePowerIfTargetPoisonedBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Base power handler for moves that double power if target paralyzed and cure target.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int DoublePowerIfTargetParalyzedCureTargetBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that double power if target paralyzed and cure target.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int DoublePowerIfTargetParalyzedCureTargetScore(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Base power handler for moves that double power if target has status problem.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int DoublePowerIfTargetStatusProblemBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Base power handler for moves that double power if user has no item.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int DoublePowerIfUserHasNoItemBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Base power handler for moves that double power if target underwater.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int DoublePowerIfTargetUnderwaterBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Base power handler for moves that double power if target underground.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int DoublePowerIfTargetUndergroundBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Base power handler for moves that double power if target in sky.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int DoublePowerIfTargetInSkyBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Base power handler for moves that double power in Electric Terrain.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int DoublePowerInElectricTerrainBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Base power handler for moves that double power if user's last move failed.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int DoublePowerIfUserLastMoveFailedBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Base power handler for moves that double power if ally fainted last turn.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int DoublePowerIfAllyFaintedLastTurnBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        // Turn-based Power Moves
        /// <summary>
        /// Score handler for moves that double power if user lost HP this turn.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int DoublePowerIfUserLostHPThisTurn(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that double power if target lost HP this turn.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int DoublePowerIfTargetLostHPThisTurn(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that double power if target acted.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int DoublePowerIfTargetActed(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that double power if target not acted.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int DoublePowerIfTargetNotActed(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        // Critical Hit Effects
        /// <summary>
        /// Score handler for moves that ensure next critical hit.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int EnsureNextCriticalHit(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that prevent critical hits against user side.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool StartPreventCriticalHitsAgainstUserSide(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that prevent critical hits against user side.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int StartPreventCriticalHitsAgainstUserSideScore(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        // Faint Prevention
        /// <summary>
        /// Failure check for moves that cannot make target faint.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool CannotMakeTargetFaint(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that make user endure fainting this turn.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int UserEnduresFaintingThisTurn(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        // Type Weakening Effects
        /// <summary>
        /// Failure check for moves that weaken Electric moves.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool StartWeakenElectricMoves(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that weaken Electric moves.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int StartWeakenElectricMovesScore(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that weaken Fire moves.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool StartWeakenFireMoves(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that weaken Fire moves.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int StartWeakenFireMovesScore(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        // Defense Screens
        /// <summary>
        /// Failure check for moves that weaken physical damage against user side.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool StartWeakenPhysicalDamageAgainstUserSide(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that weaken physical damage against user side.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int StartWeakenPhysicalDamageAgainstUserSideScore(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that weaken special damage against user side.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool StartWeakenSpecialDamageAgainstUserSide(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that weaken special damage against user side.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int StartWeakenSpecialDamageAgainstUserSideScore(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that weaken damage against user side if hail.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool StartWeakenDamageAgainstUserSideIfHail(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that weaken damage against user side if hail.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int StartWeakenDamageAgainstUserSideIfHailScore(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that remove screens.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int RemoveScreens(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        // Protection Effects
        /// <summary>
        /// Score handler for moves that protect user.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int ProtectUser(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that protect user with Baneful Bunker effects.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int ProtectUserBanefulBunker(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that protect user from damaging moves with King's Shield effects.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int ProtectUserFromDamagingMovesKingsShield(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that protect user from damaging moves with Obstruct effects.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int ProtectUserFromDamagingMovesObstruct(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that protect user from targeting moves with Spiky Shield effects.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int ProtectUserFromTargetingMovesSpikyShield(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that protect user side from damaging moves if user first turn.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool ProtectUserSideFromDamagingMovesIfUserFirstTurn(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that protect user side from damaging moves if user first turn.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int ProtectUserSideFromDamagingMovesIfUserFirstTurnScore(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that protect user side from status moves.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool ProtectUserSideFromStatusMoves(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that protect user side from status moves.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int ProtectUserSideFromStatusMovesScore(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that protect user side from priority moves.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool ProtectUserSideFromPriorityMoves(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that protect user side from priority moves.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int ProtectUserSideFromPriorityMovesScore(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that protect user side from multi-target damaging moves.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool ProtectUserSideFromMultiTargetDamagingMoves(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that protect user side from multi-target damaging moves.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int ProtectUserSideFromMultiTargetDamagingMovesScore(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        // Protection Removal
        /// <summary>
        /// Score handler for moves that remove protections.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int RemoveProtections(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that remove protections and bypass substitute.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int RemoveProtectionsBypassSubstitute(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for Hoopa moves that remove protections, bypass substitute, and lower user Defense.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool HoopaRemoveProtectionsBypassSubstituteLowerUserDef1(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for Hoopa moves that remove protections, bypass substitute, and lower user Defense.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int HoopaRemoveProtectionsBypassSubstituteLowerUserDef1Score(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        // Recoil Moves
        /// <summary>
        /// Score handler for moves with recoil quarter of damage dealt.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int RecoilQuarterOfDamageDealt(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves with recoil third of damage dealt and paralyze target.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int RecoilThirdOfDamageDealtParalyzeTarget(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves with recoil third of damage dealt and burn target.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int RecoilThirdOfDamageDealtBurnTarget(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves with recoil half of damage dealt.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int RecoilHalfOfDamageDealt(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        // Special Type Effects
        /// <summary>
        /// Base power handler for moves with effectiveness that includes Flying type.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int EffectivenessIncludesFlyingTypeBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves with category depending on higher damage and poison target.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int CategoryDependsOnHigherDamagePoisonTarget(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        // Accuracy and Hit Effects
        /// <summary>
        /// Failure check for moves that ensure next move always hits.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool EnsureNextMoveAlwaysHits(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that ensure next move always hits.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int EnsureNextMoveAlwaysHitsScore(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that negate target evasion stat stage and Ghost immunity.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int StartNegateTargetEvasionStatStageAndGhostImmunity(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that negate target evasion stat stage and Dark immunity.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int StartNegateTargetEvasionStatStageAndDarkImmunity(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        // Type Dependent Moves
        /// <summary>
        /// Base power handler for moves with type depending on user IVs.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int TypeDependsOnUserIVsBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves with type and power depending on user berry.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool TypeAndPowerDependOnUserBerry(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Base power handler for moves with type and power depending on user berry.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int TypeAndPowerDependOnUserBerryBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves with type depending on user Morpeko form and raise user Speed.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool TypeDependsOnUserMorpekoFormRaiseUserSpeed1(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves with type depending on user Morpeko form and raise user Speed.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int TypeDependsOnUserMorpekoFormRaiseUserSpeed1Score(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Base power handler for moves with type and power depending on weather.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int TypeAndPowerDependOnWeatherBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Base power handler for moves with type and power depending on terrain.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int TypeAndPowerDependOnTerrainBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        // Type Conversion Effects
        /// <summary>
        /// Failure check for moves that make target moves become Electric.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool TargetMovesBecomeElectric(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that make target moves become Electric.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int TargetMovesBecomeElectricScore(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that make Normal moves become Electric.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int NormalMovesBecomeElectric(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);
    }
}