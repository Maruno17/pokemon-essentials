using System;
using PokemonEssentials.Data;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for battle clause implementations that modify battle rules and move behaviors.
    /// Manages competitive battle rules including sleep clause, freeze clause, evasion clause,
    /// OHKO clause, and various other restrictions used in tournament play.
    /// </summary>
    public interface IBattleClauses : IBattle
    {
        /// <summary>
        /// Determines battle outcome when a draw occurs under self-KO clause rules.
        /// Under self-KO clause, the player who caused mutual KO loses the battle.
        /// Checks the last move user to determine the appropriate outcome.
        /// </summary>
        /// <returns>Battle outcome based on who caused the mutual KO</returns>
        int DecisionOnDraw();

        /// <summary>
        /// Checks for special win conditions at battle checkpoints.
        /// Handles draw clause, modified self-destruct clause, and other special
        /// conditions that can determine battle outcome when both sides faint.
        /// </summary>
        /// <param name="user">The battler who used the move</param>
        /// <param name="move">The move that was used, if applicable</param>
        void JudgeCheckpoint(IBattler user, IMove move = null);

        /// <summary>
        /// Handles end-of-round special rule checks including sudden death.
        /// Under sudden death rules, the battle ends immediately when one side
        /// has more able Pokemon than the other at the end of a round.
        /// </summary>
        void EndOfRoundPhase();
    }

    /// <summary>
    /// Interface for battler clause extensions that add rule-based restrictions to battler actions.
    /// Implements status condition limitations and move restrictions based on active battle rules.
    /// </summary>
    public interface IBattlerClauses : IBattler
    {
        /// <summary>
        /// Checks if the battler can be put to sleep under current battle rules.
        /// Sleep clause prevents multiple Pokemon on the same team from being asleep,
        /// modified sleep clause prevents any sleep including self-induced sleep.
        /// </summary>
        /// <param name="user">The battler attempting to cause sleep</param>
        /// <param name="showMessages">Whether to display failure messages</param>
        /// <param name="move">The move attempting to cause sleep</param>
        /// <param name="ignoreStatus">Whether to ignore current status for the check</param>
        /// <returns>True if sleep is allowed, false if blocked by clause</returns>
        bool CanSleep(IBattler user, bool showMessages, IMove move = null, bool ignoreStatus = false);

        /// <summary>
        /// Checks if the battler can be put to sleep by Yawn under current battle rules.
        /// Applies sleep clause restrictions to delayed sleep effects like Yawn.
        /// </summary>
        /// <returns>True if Yawn-induced sleep is allowed, false if blocked</returns>
        bool CanSleepYawn();

        /// <summary>
        /// Checks if the battler can be frozen under freeze clause rules.
        /// Freeze clause prevents multiple Pokemon on the same team from being frozen.
        /// </summary>
        /// <returns>True if freezing is allowed, false if blocked by clause</returns>
        bool CanFreeze();

        /// <summary>
        /// Checks if any Pokemon in the battler's party has a specific status condition.
        /// Used by clause implementations to enforce status condition limits per team.
        /// </summary>
        /// <param name="status">The status condition to check for</param>
        /// <returns>True if any team member has the status, false otherwise</returns>
        bool HasStatusPokemon(int status);
    }

    /// <summary>
    /// Interface for evasion-raising move clauses including Double Team and Minimize.
    /// Evasion clause prevents the use of evasion-boosting moves in competitive play.
    /// </summary>
    public interface IEvasionMoveClause
    //public interface IRaiseUserEvasion1
    {
        /// <summary>
        /// Checks if the evasion-boosting move fails under evasion clause rules.
        /// Evasion clause blocks all non-damaging moves that raise evasion stats.
        /// </summary>
        /// <param name="user">The battler using the move</param>
        /// <param name="targets">The targets of the move</param>
        /// <returns>True if the move is blocked by evasion clause, false otherwise</returns>
        bool MoveFailed(IBattler user, IBattler[] targets);
    }

    /// <summary>
    /// Interface for ability-swapping move clauses including Skill Swap.
    /// Skill Swap clause prevents ability manipulation in competitive formats.
    /// </summary>
    public interface ISkillSwapMoveClause
    {
        /// <summary>
        /// Checks if the ability-swapping move fails against the target under skill swap clause.
        /// Skill Swap clause blocks moves that exchange or manipulate abilities.
        /// </summary>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target of the move</param>
        /// <param name="show_message">Whether to display failure message</param>
        /// <returns>True if blocked by skill swap clause, false otherwise</returns>
        bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);
    }

    /// <summary>
    /// Interface for fixed-damage move clauses including Sonic Boom and Dragon Rage.
    /// Sonic Boom clause prevents the use of fixed-damage moves in certain formats.
    /// </summary>
    public interface IFixedDamageMoveClause
    {
        /// <summary>
        /// Checks if the fixed-damage move fails against the target under sonic boom clause.
        /// Sonic Boom clause blocks moves that deal fixed damage regardless of stats.
        /// </summary>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target of the move</param>
        /// <param name="show_message">Whether to display failure message</param>
        /// <returns>True if blocked by sonic boom clause, false otherwise</returns>
        bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);
    }

    /// <summary>
    /// Interface for OHKO move clauses preventing instant knockout moves.
    /// OHKO clause blocks all one-hit knockout moves in competitive play.
    /// </summary>
    public interface IOHKOMoveClause
    {
        /// <summary>
        /// Checks if the OHKO move fails against the target under OHKO clause.
        /// OHKO clause prevents all moves that can cause instant knockouts.
        /// </summary>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target of the move</param>
        /// <param name="show_message">Whether to display failure message</param>
        /// <returns>True if blocked by OHKO clause, false otherwise</returns>
        bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);
    }

    /// <summary>
    /// Interface for self-destructing move clauses including Self-Destruct and Explosion.
    /// Self-KO clause and self-destruct clause handle moves that cause the user to faint.
    /// </summary>
    public interface ISelfDestructMoveClause
    {
        /// <summary>
        /// Checks if the self-destructing move fails under self-destruct clause rules.
        /// Self-KO clause affects win conditions, self-destruct clause can cause disqualification.
        /// Evaluates remaining Pokemon count to determine if the move should be blocked.
        /// </summary>
        /// <param name="user">The battler using the move</param>
        /// <param name="targets">The targets of the move</param>
        /// <returns>True if the move fails due to clause restrictions</returns>
        bool MoveFailed(IBattler user, IBattler[] targets);
    }

    /// <summary>
    /// Interface for game-ending move clauses including Perish Song and Destiny Bond.
    /// Perish Song clause prevents these moves when they would guarantee mutual elimination.
    /// </summary>
    public interface IPerishMoveClause
    {
        /// <summary>
        /// Checks if the perish-type move fails against the target under perish song clause.
        /// Perish Song clause blocks moves that cause mutual fainting when no reserves remain.
        /// </summary>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target of the move</param>
        /// <param name="show_message">Whether to display failure message</param>
        /// <returns>True if blocked by perish song clause, false otherwise</returns>
        bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);
    }
}