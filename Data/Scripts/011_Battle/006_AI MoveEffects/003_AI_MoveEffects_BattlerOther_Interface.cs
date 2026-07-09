using System;
using PokemonEssentials.Framework;

namespace PokemonEssentials.Framework
{
    /// <summary>
    /// AI Move Effects BattlerOther handlers interface for status effects, type changes, ability manipulation,
    /// and other miscellaneous battler effects. Contains comprehensive scoring and failure check methods
    /// for sleep, poison, paralysis, burn, freeze, confusion, attraction, type modifications, and ability changes.
    /// </summary>
    public interface IAiMoveEffectsBattlerOther
    {
        // Sleep Effects
        /// <summary>
        /// Failure check for moves that put the target to sleep.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool SleepTarget(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that put the target to sleep.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int SleepTargetScore(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that put target to sleep if user is Darkrai.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool SleepTargetIfUserDarkrai(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for target sleep condition for Darkrai-specific moves.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool SleepTargetIfUserDarkraiAgainstTarget(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that change Meloetta's form and put target to sleep.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int SleepTargetChangeUserMeloettaForm(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that put target to sleep next turn (Yawn).
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool SleepTargetNextTurn(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that put target to sleep next turn (Yawn).
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int SleepTargetNextTurnScore(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        // Poison Effects
        /// <summary>
        /// Failure check for moves that poison the target.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool PoisonTarget(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that poison the target.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int PoisonTargetScore(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that poison target and lower target's Speed.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool PoisonTargetLowerTargetSpeed1(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that poison target and lower target's Speed.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int PoisonTargetLowerTargetSpeed1Score(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that badly poison the target.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool BadPoisonTarget(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that badly poison the target.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int BadPoisonTargetScore(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        // Paralysis Effects
        /// <summary>
        /// Failure check for moves that paralyze the target.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool ParalyzeTarget(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that paralyze the target.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int ParalyzeTargetScore(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that paralyze target if not type immune.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool ParalyzeTargetIfNotTypeImmune(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that paralyze target if not type immune.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int ParalyzeTargetIfNotTypeImmuneScore(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that always hit in rain and hit targets in sky, and paralyze.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int ParalyzeTargetAlwaysHitsInRainHitsTargetInSky(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that paralyze and flinch the target.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int ParalyzeFlinchTarget(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        // Burn Effects
        /// <summary>
        /// Failure check for moves that burn the target.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool BurnTarget(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that burn the target.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int BurnTargetScore(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that burn and flinch the target.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int BurnFlinchTarget(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        // Freeze Effects
        /// <summary>
        /// Failure check for moves that freeze the target.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool FreezeTarget(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that freeze the target.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int FreezeTargetScore(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that freeze target and are super effective against Water.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int FreezeTargetSuperEffectiveAgainstWater(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that freeze target and always hit in hail.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int FreezeTargetAlwaysHitsInHail(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that freeze and flinch the target.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int FreezeFlinchTarget(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that can paralyze, burn, or freeze the target.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int ParalyzeBurnOrFreezeTarget(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        // Status Transfer/Healing
        /// <summary>
        /// Failure check for moves that give user's status to target.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool GiveUserStatusToTarget(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for target receiving status from user.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool GiveUserStatusToTargetAgainstTarget(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that give user's status to target.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int GiveUserStatusToTargetScore(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that cure user's burn, poison, or paralysis.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool CureUserBurnPoisonParalysis(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that cure user's burn, poison, or paralysis.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int CureUserBurnPoisonParalysisScore(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that cure user's party status problems.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool CureUserPartyStatus(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that cure user's party status problems.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int CureUserPartyStatusScore(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that cure target's burn.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int CureTargetBurn(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that start user side immunity to status.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool StartUserSideImmunityToInflictedStatus(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that start user side immunity to status.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int StartUserSideImmunityToInflictedStatusScore(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        // Flinch Effects
        /// <summary>
        /// Score handler for moves that flinch the target.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int FlinchTarget(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that flinch target if user not asleep.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int FlinchTargetFailsIfUserNotAsleep(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that flinch target but fail if not user's first turn.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool FlinchTargetFailsIfNotUserFirstTurn(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that flinch target but fail if not user's first turn.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int FlinchTargetFailsIfNotUserFirstTurnScore(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Base power handler for moves that flinch target and double power if target in sky.
        /// </summary>
        /// <param name="power">Base power of the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified base power for the move</returns>
        int FlinchTargetDoublePowerIfTargetInSkyBasePower(int power, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that flinch target and double power if target in sky.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int FlinchTargetDoublePowerIfTargetInSky(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        // Confusion Effects
        /// <summary>
        /// Failure check for moves that confuse the target.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool ConfuseTarget(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that confuse the target.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int ConfuseTargetScore(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that confuse target, always hit in rain, and hit targets in sky.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int ConfuseTargetAlwaysHitsInRainHitsTargetInSky(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        // Attraction Effects
        /// <summary>
        /// Failure check for moves that attract the target.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool AttractTarget(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that attract the target.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int AttractTargetScore(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        // Type Change Effects
        /// <summary>
        /// Failure check for moves that set user types based on environment.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool SetUserTypesBasedOnEnvironment(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that set user types based on environment.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int SetUserTypesBasedOnEnvironmentScore(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that set user types to resist last attack.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool SetUserTypesToResistLastAttack(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that set user types to resist last attack.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int SetUserTypesToResistLastAttackScore(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that set user types to target types.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool SetUserTypesToTargetTypes(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that set user types to user move type.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool SetUserTypesToUserMoveType(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that set user types to user move type.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int SetUserTypesToUserMoveTypeScore(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that set target types to Psychic.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool SetTargetTypesToPsychic(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that set target types to Psychic.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int SetTargetTypesToPsychicScore(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that set target types to Water.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool SetTargetTypesToWater(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that set target types to Water.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int SetTargetTypesToWaterScore(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that add Ghost type to target.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool AddGhostTypeToTarget(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that add Ghost type to target.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int AddGhostTypeToTargetScore(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that add Grass type to target.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool AddGrassTypeToTarget(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that add Grass type to target.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int AddGrassTypeToTargetScore(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that make user lose Fire type.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool UserLosesFireType(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        // Ability Change Effects
        /// <summary>
        /// Failure check for moves that set target ability to Simple.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool SetTargetAbilityToSimple(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that set target ability to Simple.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int SetTargetAbilityToSimpleScore(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that set target ability to Insomnia.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool SetTargetAbilityToInsomnia(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that set target ability to Insomnia.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int SetTargetAbilityToInsomniaScore(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that set user ability to target ability.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool SetUserAbilityToTargetAbility(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that set user ability to target ability.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int SetUserAbilityToTargetAbilityScore(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that set target ability to user ability.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool SetTargetAbilityToUserAbility(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that set target ability to user ability.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int SetTargetAbilityToUserAbilityScore(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that swap user and target abilities.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool UserTargetSwapAbilities(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that swap user and target abilities.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int UserTargetSwapAbilitiesScore(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that negate target ability.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool NegateTargetAbility(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that negate target ability.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int NegateTargetAbilityScore(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that negate target ability if target acted.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int NegateTargetAbilityIfTargetActed(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        // Position/Movement Effects
        /// <summary>
        /// Failure check for moves that start user airborne.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool StartUserAirborne(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that start user airborne.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int StartUserAirborneScore(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that start target airborne and always hit by moves.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool StartTargetAirborneAndAlwaysHitByMoves(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that start target airborne and always hit by moves.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int StartTargetAirborneAndAlwaysHitByMovesScore(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that hit target in sky and ground the target.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int HitsTargetInSkyGroundsTarget(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for moves that start gravity.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool StartGravity(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that start gravity.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int StartGravityScore(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        // Transform Effect
        /// <summary>
        /// Failure check for moves that transform user into target.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool TransformUserIntoTarget(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that transform user into target.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int TransformUserIntoTargetScore(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);
    }
}