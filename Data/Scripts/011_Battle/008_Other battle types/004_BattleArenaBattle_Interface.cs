using System;
using PokemonEssentials.Data;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for Battle Arena success state tracking.
    /// Manages the skill rating system used in Battle Arena judgment,
    /// tracking move effectiveness and usage patterns for scoring battles.
    /// </summary>
    public interface ISuccessState
    {
        /// <summary>Type effectiveness multiplier for the last move used.</summary>
        double typeMod { get; set; }

        /// <summary>Usage state: 0 = not used, 1 = failed, 2 = succeeded.</summary>
        int useState { get; set; }

        /// <summary>Whether the Pokemon was protected from the move.</summary>
        bool @protected { get; set; }

        /// <summary>Current skill rating for Battle Arena judgment.</summary>
        int skill { get; set; }

        /// <summary>
        /// Initializes the success state with default values.
        /// Resets all tracking values to neutral state.
        /// </summary>
        ISuccessState initialize();

        /// <summary>
        /// Clears the success state tracking values.
        /// Resets type modifier and usage state, optionally resets skill rating.
        /// </summary>
        /// <param name="full">Whether to reset skill rating as well</param>
        void clear(bool full = true);

        /// <summary>
        /// Updates the skill rating based on move usage outcome.
        /// Calculates skill points from type effectiveness and success/failure.
        /// Super effective hits give +2, normal hits +1, not very effective -1, failed moves -2.
        /// </summary>
        void updateSkill();
    }

    /// <summary>
    /// Interface for Battle Arena battle class that implements competitive judging system.
    /// Extends normal battles with Mind, Skill, and Body rating categories,
    /// automatic switching after 3 turns with referee judgment, and Arena-specific rules.
    /// Scoring based on move aggression (Mind), effectiveness (Skill), and HP retention (Body).
    /// </summary>
    public interface IBattleArenaBattle : IBattle
    {
        /// <summary>Whether battlers have changed since last display update.</summary>
        bool battlersChanged { get; set; }

        /// <summary>Mind ratings for each battler (aggression/offensive moves).</summary>
        int[] mind { get; set; }

        /// <summary>Skill ratings for each battler (move effectiveness).</summary>
        int[] skill { get; set; }

        /// <summary>Starting HP values for each battler for Body rating calculation.</summary>
        int[] starthp { get; set; }

        /// <summary>Current turn counter for 3-turn limit.</summary>
        int count { get; set; }

        /// <summary>Party indexes for automatic progression through Pokemon.</summary>
        int[] partyindexes { get; set; }

        /// <summary>
        /// Initializes a Battle Arena battle with scoring systems.
        /// Sets up Mind, Skill, Body tracking and configures Arena-specific AI behavior.
        /// </summary>
        /// <param name="args">Standard battle initialization arguments</param>
        IBattleArenaBattle initialize(params object[] args);

        /// <summary>
        /// Prevents Pokemon from being manually switched out in Battle Arena.
        /// Arena rules require Pokemon to battle for the full 3-turn duration.
        /// </summary>
        /// <param name="idxBattler">Battler attempting to switch</param>
        /// <param name="_idxParty">Party Pokemon index (unused)</param>
        /// <param name="partyScene">Party scene for displaying message</param>
        /// <returns>Always false - no manual switching allowed</returns>
        bool CanSwitchIn(int idxBattler, int _idxParty, IPartyDisplayScene partyScene = null);

        /// <summary>
        /// Handles end-of-round Pokemon switching in Battle Arena.
        /// Automatically progresses to next Pokemon in party when current one faints.
        /// Respects favorDraws parameter for tie-breaking behavior.
        /// </summary>
        /// <param name="favorDraws">Whether to favor draw outcomes</param>
        void EORSwitch(bool favorDraws = false);

        /// <summary>
        /// Resets Battle Arena scoring when all battlers enter battle.
        /// Initializes Mind, Skill, Body tracking and sets starting HP values.
        /// Called at start of each 3-turn Arena match segment.
        /// </summary>
        void OnAllBattlersEnteringBattle();

        /// <summary>
        /// Records battler as active and resets Arena scoring.
        /// Resets all tracking values when a new Pokemon becomes active.
        /// Ensures clean slate for 3-turn judgment period.
        /// </summary>
        /// <param name="battler">Battler becoming active</param>
        void RecordBattlerAsActive(IBattler battler);

        /// <summary>
        /// Calculates Mind score for a move in Battle Arena system.
        /// Rates move aggression: defensive moves (-1), counters (0), attacks (+1).
        /// Mind category judges Pokemon showing the most offensive spirit.
        /// </summary>
        /// <param name="move">Move to evaluate for Mind rating</param>
        /// <returns>Mind score contribution (-1 to +1)</returns>
        int MindScore(IMove move);

        /// <summary>
        /// Extends command phase with Battle Arena display and Mind rating updates.
        /// Shows battler matchup display and updates Mind scores based on move selection.
        /// Mind rating reflects aggressive vs defensive move choices.
        /// </summary>
        void CommandPhase();

        /// <summary>
        /// Handles end-of-round processing with Battle Arena judgment system.
        /// After 3 turns, calculates Mind, Skill, and Body ratings to determine winner.
        /// Shows detailed referee judgment display and applies battle outcome.
        /// Automatically switches to next Pokemon if available.
        /// </summary>
        void EndOfRoundPhase();
    }

    /// <summary>
    /// Interface for Battle Arena AI extensions that disable switching.
    /// Modifies AI behavior to never attempt switching in Arena battles
    /// since manual switching is prohibited under Arena rules.
    /// </summary>
    public interface IBattleAIBattleArena : IBattleAI
    {
        /// <summary>Whether this AI is operating under Battle Arena rules.</summary>
        bool battleArena { get; set; }

        /// <summary>
        /// Prevents AI from choosing to switch out in Battle Arena.
        /// Arena rules require Pokemon to stay in battle for full 3-turn duration.
        /// </summary>
        /// <param name="force_switch">Whether switch is mandatory (unused)</param>
        /// <returns>Always false - no switching allowed in Arena</returns>
        bool ChooseToSwitchOut(bool force_switch = false);
    }

    /// <summary>
    /// Interface for Battle Arena scene extensions.
    /// Provides Arena-specific visual displays including battler announcements
    /// and the detailed 3-category judgment system with referee commentary.
    /// </summary>
    public interface IBattleSceneBattleArena : IBattleScene
    {
        /// <summary>
        /// Updates graphics for Battle Arena display.
        /// Maintains consistent visual updates during Arena-specific sequences.
        /// </summary>
        void BattleArenaUpdate();

        /// <summary>
        /// Updates the judgment window display during Arena scoring.
        /// Shows progressive revelation of Mind, Skill, and Body category results
        /// with visual indicators for wins, losses, and ties in each category.
        /// </summary>
        /// <param name="window">Display window for judgment information</param>
        /// <param name="phase">Current judgment phase (0-3 categories)</param>
        /// <param name="battler1">First battler being judged</param>
        /// <param name="battler2">Second battler being judged</param>
        /// <param name="ratings1">First battler's category ratings</param>
        /// <param name="ratings2">Second battler's category ratings</param>
        void updateJudgment(IWindow window, int phase, IBattler battler1, IBattler battler2, int[] ratings1, int[] ratings2);

        /// <summary>
        /// Displays Battle Arena battler announcement.
        /// Shows referee introduction of the two Pokemon facing off
        /// at the start of each 3-turn Arena segment.
        /// </summary>
        /// <param name="battler1">First battler in the matchup</param>
        /// <param name="battler2">Second battler in the matchup</param>
        void BattleArenaBattlers(IBattler battler1, IBattler battler2);

        /// <summary>
        /// Displays the complete Battle Arena judgment sequence.
        /// Shows dramatic referee judgment with progressive category scoring,
        /// visual judgment display, and final winner determination.
        /// Includes dimming effects and detailed score breakdowns for all three categories.
        /// </summary>
        /// <param name="battler1">First battler being judged</param>
        /// <param name="battler2">Second battler being judged</param>
        /// <param name="ratings1">First battler's category ratings [Mind, Skill, Body]</param>
        /// <param name="ratings2">Second battler's category ratings [Mind, Skill, Body]</param>
        void BattleArenaJudgment(IBattler battler1, IBattler battler2, int[] ratings1, int[] ratings2);
    }
    /*
    /// <summary>
    /// Interface for Battle Arena rating calculation system.
    /// Manages the three-category scoring system used to determine winners
    /// when battles reach the 3-turn time limit without a knockout.
    /// </summary>
    public interface IBattleArenaRatings
    {
        /// <summary>Mind category rating - measures offensive aggression.</summary>
        int mindRating { get; }

        /// <summary>Skill category rating - measures move effectiveness.</summary>
        int skillRating { get; }

        /// <summary>Body category rating - measures HP retention.</summary>
        int bodyRating { get; }

        /// <summary>
        /// Calculates Mind rating based on move choices.
        /// Rewards aggressive, offensive moves over defensive tactics.
        /// </summary>
        /// <param name="moves">Array of moves used during the match</param>
        /// <returns>Final Mind category score</returns>
        int calculateMindRating(IMove[] moves);

        /// <summary>
        /// Calculates Skill rating based on move effectiveness.
        /// Rewards successful hits and super effective moves.
        /// </summary>
        /// <param name="successStates">Array of move success states</param>
        /// <returns>Final Skill category score</returns>
        int calculateSkillRating(ISuccessState[] successStates);

        /// <summary>
        /// Calculates Body rating based on HP retention.
        /// Compares current HP percentage to starting HP.
        /// </summary>
        /// <param name="currentHP">Current HP value</param>
        /// <param name="startingHP">Starting HP value</param>
        /// <returns>Final Body category score</returns>
        int calculateBodyRating(int currentHP, int startingHP);

        /// <summary>
        /// Determines overall winner based on category totals.
        /// Sums all three category scores to determine victor.
        /// </summary>
        /// <param name="ratings1">First battler's category scores</param>
        /// <param name="ratings2">Second battler's category scores</param>
        /// <returns>Winner index (0, 1, or -1 for tie)</returns>
        int determineWinner(int[] ratings1, int[] ratings2);
    }

    /// <summary>
    /// Interface for Battle Arena judgment display components.
    /// Handles the visual presentation of scoring categories and results
    /// during the dramatic referee judgment sequence.
    /// </summary>
    public interface IBattleArenaJudgmentDisplay
    {
        /// <summary>Category names for display purposes.</summary>
        string[] categoryNames { get; }

        /// <summary>Visual indicators for category results.</summary>
        ISprite[] categoryIndicators { get; }

        /// <summary>
        /// Creates the judgment display window.
        /// Sets up visual elements for showing category scores.
        /// </summary>
        /// <returns>Configured judgment window</returns>
        IWindow createJudgmentWindow();

        /// <summary>
        /// Displays a specific category result.
        /// Shows win/loss indicators for Mind, Skill, or Body category.
        /// </summary>
        /// <param name="category">Category index (0=Mind, 1=Skill, 2=Body)</param>
        /// <param name="result1">First battler's result (0=lose, 1=tie, 2=win)</param>
        /// <param name="result2">Second battler's result (0=lose, 1=tie, 2=win)</param>
        void displayCategoryResult(int category, int result1, int result2);

        /// <summary>
        /// Shows final judgment totals and winner.
        /// Displays combined scores and declares the victor.
        /// </summary>
        /// <param name="total1">First battler's total score</param>
        /// <param name="total2">Second battler's total score</param>
        /// <param name="winner">Winner index (-1=tie, 0=battler1, 1=battler2)</param>
        void displayFinalJudgment(int total1, int total2, int winner);

        /// <summary>
        /// Cleans up judgment display resources.
        /// Disposes of windows and graphics used in judgment sequence.
        /// </summary>
        void cleanup();
    }
    */
}