using System;
using System.Collections.Generic;
using PokemonEssentials.Data;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for Bug-Catching Contest battle scene extensions.
    /// Provides additional UI functionality specific to Bug Contest battles including
    /// help windows for comparing caught Pokemon and contest-specific display elements.
    /// </summary>
    /// <remarks>
    /// Bug-Catching Contest battle scene (the visuals of the battle).
    /// </remarks>
    public interface IBattleSceneBugContest : IScene
    {
        /// <summary>
        /// Initializes sprite elements for Bug Contest battles.
        /// Sets up help window for Pokemon comparison display during contest.
        /// </summary>
        void InitSprites();

        /// <summary>
        /// Shows a help window with specified text.
        /// Used to display Pokemon comparison information when deciding whether to replace
        /// the currently caught Pokemon with a newly caught one.
        /// </summary>
        /// <param name="text">Text content to display in help window</param>
        void ShowHelp(string text);

        /// <summary>
        /// Hides the help window.
        /// Removes the Pokemon comparison display from view.
        /// </summary>
        void HideHelp();
    }

    /// <summary>
    /// Interface for Bug-Catching Contest battle class that extends normal battles.
    /// Manages Bug Contest specific mechanics including Sport Ball usage limitations,
    /// single Pokemon storage with replacement options, and contest time constraints.
    /// Inherits from standard battle but adds contest-specific item and storage handling.
    /// </summary>
    /// <remarks>
    /// Bug-Catching Contest battle class.
    /// </remarks>
    public interface IBattleBugContest : IBattle
    {
        /// <summary>Number of Sport Balls remaining in the contest.</summary>
        int ballCount { get; set; }

        /// <summary>Sport Ball item constant used in contest.</summary>
        int ballConst { get; }

        /// <summary>
        /// Initializes a Bug Contest battle with Sport Ball limitations.
        /// Sets up contest-specific parameters including ball count and Sport Ball type.
        /// </summary>
        /// <param name="args">Standard battle initialization arguments</param>
        IBattleBugContest initialize(IScene scene, IList<IPokemon> p1, IList<IPokemon> p2, IList<ITrainer> player, IList<ITrainer> opponent);

        /// <summary>
        /// Handles item menu for Bug Contest battles.
        /// Automatically registers Sport Ball usage instead of showing full item menu.
        /// Contest rules only allow Sport Ball usage for capturing Pokemon.
        /// </summary>
        /// <param name="idxBattler">Battler index using item</param>
        /// <param name="_firstAction">Whether this is first action (unused)</param>
        /// <returns>Item usage result</returns>
        bool ItemMenu(int idxBattler, bool _firstAction);

        /// <summary>
        /// Shows the Bug Contest command menu.
        /// Displays Sport Ball count and limited contest action options.
        /// Menu shows current Sport Ball count and standard battle commands.
        /// </summary>
        /// <param name="idxBattler">Battler index selecting command</param>
        /// <param name="_firstAction">Whether this is first action (unused)</param>
        /// <returns>Selected command index</returns>
        int CommandMenu(int idxBattler, bool _firstAction);

        /// <summary>
        /// Consumes items from the contest inventory.
        /// Decrements Sport Ball count when balls are used in contest.
        /// Only Sport Balls are consumable during Bug Contest battles.
        /// </summary>
        /// <param name="_item">Item being consumed (unused)</param>
        /// <param name="_idxBattler">Battler using item (unused)</param>
        void ConsumeItemInBag(int _item, int _idxBattler);

        /// <summary>
        /// Stores caught Pokemon in Bug Contest with replacement option.
        /// Handles the contest rule of only keeping one Pokemon at a time.
        /// If a Pokemon is already caught, provides comparison and replacement choice.
        /// Shows detailed comparison including level and HP stats.
        /// </summary>
        /// <param name="pkmn">Pokemon that was just caught</param>
        void StorePokemon(IPokemon pkmn);

        /// <summary>
        /// Handles end of round effects for Bug Contest battles.
        /// Extends base end-of-round processing with contest-specific conditions.
        /// Automatically ends contest when no Sport Balls remain.
        /// </summary>
        void EndOfRoundPhase();
    }

    /// <summary>
    /// Interface for Bug Contest state management.
    /// Handles the persistent state information for Bug Catching Contest including
    /// currently caught Pokemon and contest progress tracking.
    /// </summary>
    public interface IBattleBugContestState
    {
        /// <summary>The Pokemon currently being held by the contestant.</summary>
        IPokemon lastPokemon { get; set; }

        /// <summary>Contest start time for duration tracking.</summary>
        System.DateTime startTime { get; set; }

        /// <summary>Contest duration limit in minutes.</summary>
        int timeLimit { get; set; }

        /// <summary>Number of Pokemon encountered during contest.</summary>
        int encounterCount { get; set; }

        /// <summary>Contest area or zone identifier.</summary>
        int contestArea { get; set; }

        /// <summary>
        /// Checks if the contest time has expired.
        /// </summary>
        /// <returns>True if contest time limit has been reached</returns>
        bool timeExpired();

        /// <summary>
        /// Gets remaining time in the contest.
        /// </summary>
        /// <returns>Remaining time in minutes</returns>
        int remainingTime();

        /// <summary>
        /// Calculates the contest score for the caught Pokemon.
        /// Score is based on Pokemon level, HP, species rarity, and other factors.
        /// </summary>
        /// <returns>Contest score for judging</returns>
        int calculateScore();

        /// <summary>
        /// Resets the contest state for a new contest.
        /// Clears caught Pokemon and resets all tracking variables.
        /// </summary>
        void reset();
    }

    /// <summary>
    /// Interface for Bug Contest judging and results.
    /// Handles the evaluation of caught Pokemon and contest ranking system.
    /// </summary>
    public interface IBattleBugContestJudging
    {
        /// <summary>
        /// Judges the contest based on caught Pokemon.
        /// Evaluates Pokemon stats, species rarity, and contest conditions.
        /// </summary>
        /// <param name="caughtPokemon">Pokemon submitted for judging</param>
        /// <returns>Contest score and ranking</returns>
        //(int score, int rank) judgeContest(IPokemon caughtPokemon);
        KeyValuePair<int, int> judgeContest(IPokemon caughtPokemon);

        /// <summary>
        /// Gets the contest prize based on ranking.
        /// Determines reward items based on final contest placement.
        /// </summary>
        /// <param name="rank">Contest ranking achieved</param>
        /// <returns>Prize item and quantity</returns>
        //(IItem item, int quantity) getContestPrize(int rank);
        KeyValuePair<IItem, int> getContestPrize(int rank);

        /// <summary>
        /// Displays contest results and awards prizes.
        /// Shows final ranking, score, and distributes appropriate rewards.
        /// </summary>
        /// <param name="playerScore">Player's final contest score</param>
        /// <param name="playerRank">Player's final ranking</param>
        void showContestResults(int playerScore, int playerRank);

        /// <summary>
        /// Gets contest ranking descriptions.
        /// Provides text descriptions for different contest placements.
        /// </summary>
        /// <param name="rank">Contest rank number</param>
        /// <returns>Rank description text</returns>
        string getRankDescription(int rank);
    }
}