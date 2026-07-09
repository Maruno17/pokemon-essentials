using System;
using PokemonEssentials.Framework;

namespace PokemonEssentials.Framework
{
    /*
    /// <summary>
    /// AI Move Effects BattlerStats handlers interface for stat-raising, stat-lowering, and stat manipulation moves.
    /// Contains handler methods for various stat modification effects including raises, drops, swaps, and resets.
    /// </summary>
    public interface IAiMoveEffectsBattlerStats
    {
        /// <summary>
        /// Failure check for moves that raise user's Attack by 1 stage.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool RaiseUserAttack1(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that raise user's Attack by 1 stage.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int RaiseUserAttack1Score(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that raise user's Attack by 2 stages if target faints.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int RaiseUserAttack2IfTargetFaints(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that maximize user's Attack and lose half of total HP.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool MaxUserAttackLoseHalfOfTotalHP(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that maximize user's Attack and lose half of total HP.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int MaxUserAttackLoseHalfOfTotalHPScore(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that raise user's Defense by 1 stage and curl up the user.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int RaiseUserDefense1CurlUpUser(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that raise user's Special Defense by 1 stage and power up Electric moves.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int RaiseUserSpDef1PowerUpElectricMove(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that raise user's Speed by 2 stages and lower user's weight.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int RaiseUserSpeed2LowerUserWeight(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that raise user's critical hit rate by 2 stages.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool RaiseUserCriticalHitRate2(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that raise user's critical hit rate by 2 stages.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int RaiseUserCriticalHitRate2Score(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that raise user's Evasion by 2 stages and minimize the user.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int RaiseUserEvasion2MinimizeUser(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that raise user's Attack and Defense by 1 stage.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool RaiseUserAtkDef1(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that raise user's Attack and Special Attack by 1 or 2 stages in Sun.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int RaiseUserAtkSpAtk1Or2InSun(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that lower user's Defense and Special Defense by 1 stage and raise Attack, Special Attack, and Speed by 2 stages.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool LowerUserDefSpDef1RaiseUserAtkSpAtkSpd2(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that lower user's Defense and Special Defense by 1 stage and raise Attack, Special Attack, and Speed by 2 stages.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int LowerUserDefSpDef1RaiseUserAtkSpAtkSpd2Score(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that raise user's main stats by 1 stage and lose a third of total HP.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool RaiseUserMainStats1LoseThirdOfTotalHP(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that raise user's main stats by 1 stage and lose a third of total HP.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int RaiseUserMainStats1LoseThirdOfTotalHPScore(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that raise user's main stats by 1 stage and trap the user in battle.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool RaiseUserMainStats1TrapUserInBattle(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that raise user's main stats by 1 stage and trap the user in battle.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int RaiseUserMainStats1TrapUserInBattleScore(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that start raising user's Attack by 1 stage when damaged.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int StartRaiseUserAtk1WhenDamaged(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that lower user's Attack by 1 stage.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int LowerUserAttack1(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that raise target's Attack by 1 stage.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool RaiseTargetAttack1(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that raise target's Attack by 1 stage.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int RaiseTargetAttack1Score(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that raise target's Attack by 2 stages and confuse the target.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool RaiseTargetAttack2ConfuseTarget(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that raise target's Attack by 2 stages and confuse the target.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int RaiseTargetAttack2ConfuseTargetScore(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that raise target's Special Attack by 1 stage and confuse the target.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool RaiseTargetSpAtk1ConfuseTarget(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that raise target's Special Attack by 1 stage and confuse the target.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int RaiseTargetSpAtk1ConfuseTargetScore(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that raise target's Special Defense by 1 stage.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool RaiseTargetSpDef1(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that raise target's Special Defense by 1 stage.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int RaiseTargetSpDef1Score(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that raise target's random stat by 2 stages.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool RaiseTargetRandomStat2(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that raise target's random stat by 2 stages.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int RaiseTargetRandomStat2Score(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that raise target's Attack and Special Attack by 2 stages.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool RaiseTargetAtkSpAtk2(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that raise target's Attack and Special Attack by 2 stages.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int RaiseTargetAtkSpAtk2Score(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that lower target's Attack by 1 stage.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool LowerTargetAttack1(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that lower target's Attack by 1 stage.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int LowerTargetAttack1Score(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Base power handler for moves that lower target's Defense by 1 stage and power up in gravity.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int LowerTargetDefense1PowersUpInGravityBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that lower target's Special Attack by 2 stages if can attract.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool LowerTargetSpAtk2IfCanAttract(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that lower target's Speed by 1 stage and make target weaker to Fire.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool LowerTargetSpeed1MakeTargetWeakerToFire(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that lower target's Speed by 1 stage and make target weaker to Fire.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int LowerTargetSpeed1MakeTargetWeakerToFireScore(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Base power handler for moves that lower target's Speed by 1 stage and are weaker in grassy terrain.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int LowerTargetSpeed1WeakerInGrassyTerrainBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that lower target's Evasion by 1 stage and remove side effects.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool LowerTargetEvasion1RemoveSideEffects(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that lower target's Evasion by 1 stage and remove side effects.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int LowerTargetEvasion1RemoveSideEffectsScore(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that lower target's Attack and Defense by 1 stage.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool LowerTargetAtkDef1(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that lower poisoned target's Attack, Special Attack, and Speed by 1 stage.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool LowerPoisonedTargetAtkSpAtkSpd1(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that raise allies' Attack and Defense by 1 stage.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool RaiseAlliesAtkDef1(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that raise allies' Attack and Defense by 1 stage.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int RaiseAlliesAtkDef1Score(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that raise Plus/Minus user and allies' Attack and Special Attack by 1 stage.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool RaisePlusMinusUserAndAlliesAtkSpAtk1(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that raise Plus/Minus user and allies' Attack and Special Attack by 1 stage.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int RaisePlusMinusUserAndAlliesAtkSpAtk1Score(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that raise Plus/Minus user and allies' Defense and Special Defense by 1 stage.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool RaisePlusMinusUserAndAlliesDefSpDef1(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that raise Plus/Minus user and allies' Defense and Special Defense by 1 stage.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int RaisePlusMinusUserAndAlliesDefSpDef1Score(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that raise grounded Grass battlers' Attack and Special Attack by 1 stage.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool RaiseGroundedGrassBattlersAtkSpAtk1(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that raise grounded Grass battlers' Attack and Special Attack by 1 stage.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int RaiseGroundedGrassBattlersAtkSpAtk1Score(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that raise Grass battlers' Defense by 1 stage.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool RaiseGrassBattlersDef1(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that raise Grass battlers' Defense by 1 stage.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int RaiseGrassBattlersDef1Score(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that swap user and target's Attack and Special Attack stat stages.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int UserTargetSwapAtkSpAtkStages(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that swap user and target's Defense and Special Defense stat stages.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int UserTargetSwapDefSpDefStages(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that swap user and target's all stat stages.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int UserTargetSwapStatStages(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that copy target's stat stages to the user.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int UserCopyTargetStatStages(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that steal target's positive stat stages.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int UserStealTargetPositiveStatStages(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that invert target's stat stages.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool InvertTargetStatStages(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that invert target's stat stages.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int InvertTargetStatStagesScore(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that reset target's stat stages.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int ResetTargetStatStages(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that reset all battlers' stat stages.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool ResetAllBattlersStatStages(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that reset all battlers' stat stages.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int ResetAllBattlersStatStagesScore(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that start user side immunity to stat stage lowering.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool StartUserSideImmunityToStatStageLowering(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that start user side immunity to stat stage lowering.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int StartUserSideImmunityToStatStageLoweringScore(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that swap user's base Attack and Defense stats.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int UserSwapBaseAtkDef(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that swap user and target's base Speed stats.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int UserTargetSwapBaseSpeed(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that average user and target's base Attack and Special Attack stats.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int UserTargetAverageBaseAtkSpAtk(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that average user and target's base Defense and Special Defense stats.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int UserTargetAverageBaseDefSpDef(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that average user and target's HP.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int UserTargetAverageHP(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that start user side double speed effect.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool StartUserSideDoubleSpeed(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that start user side double speed effect.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int StartUserSideDoubleSpeedScore(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that start swapping all battlers' base defensive stats.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int StartSwapAllBattlersBaseDefensiveStats(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);
        */
    }
}