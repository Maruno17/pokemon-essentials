using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Base interface for alternate battle modes that modify standard battle rules.
    /// Provides common functionality for special battle types like Safari Zone, Bug Contest, etc.
    /// </summary>
    public interface IAlternateBattleMode
    {
        /// <summary>
        /// Gets the name of this battle mode.
        /// </summary>
        /// <returns>The battle mode name.</returns>
        string getBattleModeName();

        /// <summary>
        /// Initializes the alternate battle mode with specific parameters.
        /// </summary>
        /// <param name="parameters">Configuration parameters for the battle mode.</param>
        IAlternateBattleMode initialize(object parameters);

        /// <summary>
        /// Checks if this battle mode is currently active.
        /// </summary>
        /// <returns>True if the battle mode is active, false otherwise.</returns>
        bool isActive();

        /// <summary>
        /// Starts the alternate battle mode.
        /// </summary>
        void startBattleMode();

        /// <summary>
        /// Ends the alternate battle mode and cleans up.
        /// </summary>
        void endBattleMode();

        /// <summary>
        /// Gets the special rules that apply to this battle mode.
        /// </summary>
        /// <returns>List of rule descriptions or identifiers.</returns>
        IList<string> getBattleRules();

        /// <summary>
        /// Modifies battle behavior based on this mode's rules.
        /// </summary>
        /// <param name="battle">The battle object to modify.</param>
        void applyBattleModifications(object battle);
    }

    /// <summary>
    /// Interface for Safari Zone battle mode where Pokemon cannot be captured through normal battle.
    /// Players use special items and tactics to catch Pokemon.
    /// </summary>
    public interface ISafariZoneBattle : IAlternateBattleMode
    {
        /// <summary>
        /// Gets the number of Safari Balls remaining.
        /// </summary>
        /// <returns>The number of Safari Balls left.</returns>
        int getSafariBallsRemaining();

        /// <summary>
        /// Uses a Safari Ball to attempt to catch the wild Pokemon.
        /// </summary>
        /// <returns>True if the Pokemon was caught, false otherwise.</returns>
        bool throwSafariBall();

        /// <summary>
        /// Throws bait to make the Pokemon less likely to flee but harder to catch.
        /// </summary>
        void throwBait();

        /// <summary>
        /// Throws a rock to make the Pokemon easier to catch but more likely to flee.
        /// </summary>
        void throwRock();

        /// <summary>
        /// Attempts to run away from the Safari encounter.
        /// </summary>
        /// <returns>True if successfully ran away, false otherwise.</returns>
        bool runAway();

        /// <summary>
        /// Gets the current catch rate modifier for the Pokemon.
        /// </summary>
        /// <returns>The catch rate multiplier.</returns>
        float getCatchRateModifier();

        /// <summary>
        /// Gets the current flee rate for the Pokemon.
        /// </summary>
        /// <returns>The probability that the Pokemon will flee.</returns>
        float getFleeRate();

        /// <summary>
        /// Gets the remaining steps allowed in the Safari Zone.
        /// </summary>
        /// <returns>The number of steps remaining.</returns>
        int getStepsRemaining();
    }

    /// <summary>
    /// Interface for Bug Contest battle mode where players compete to catch the best Bug-type Pokemon.
    /// </summary>
    public interface IBugContestBattle : IAlternateBattleMode
    {
        /// <summary>
        /// Gets the time remaining in the Bug Contest.
        /// </summary>
        /// <returns>The time remaining in seconds.</returns>
        int getTimeRemaining();

        /// <summary>
        /// Gets the current contest Pokemon (the best one caught so far).
        /// </summary>
        /// <returns>The Pokemon entered in the contest, or null if none.</returns>
        object getContestPokemon();

        /// <summary>
        /// Sets the Pokemon to enter in the contest.
        /// </summary>
        /// <param name="pokemon">The Pokemon to enter.</param>
        /// <returns>True if the Pokemon was accepted, false otherwise.</returns>
        bool setContestPokemon(object pokemon);

        /// <summary>
        /// Calculates the contest score for a Pokemon.
        /// </summary>
        /// <param name="pokemon">The Pokemon to score.</param>
        /// <returns>The contest score for the Pokemon.</returns>
        int calculateContestScore(object pokemon);

        /// <summary>
        /// Checks if a Pokemon is eligible for the Bug Contest.
        /// </summary>
        /// <param name="pokemon">The Pokemon to check.</param>
        /// <returns>True if the Pokemon can be entered, false otherwise.</returns>
        bool isPokemonEligible(object pokemon);

        /// <summary>
        /// Gets the current ranking in the contest.
        /// </summary>
        /// <returns>The player's current rank (1st, 2nd, 3rd, etc.).</returns>
        int getCurrentRanking();

        /// <summary>
        /// Ends the Bug Contest and determines the final results.
        /// </summary>
        /// <returns>The final contest results.</returns>
        object endContest();
    }

    /// <summary>
    /// Interface for Battle Frontier challenge modes with special rules and restrictions.
    /// </summary>
    public interface IBattleFrontierChallenge : IAlternateBattleMode
    {
        /// <summary>
        /// Gets the current facility being challenged.
        /// </summary>
        /// <returns>The Battle Frontier facility identifier.</returns>
        string getCurrentFacility();

        /// <summary>
        /// Gets the current challenge level or streak.
        /// </summary>
        /// <returns>The current battle streak or level.</returns>
        int getChallengeLevel();

        /// <summary>
        /// Gets the Battle Points (BP) earned in this challenge.
        /// </summary>
        /// <returns>The number of Battle Points earned.</returns>
        int getBattlePoints();

        /// <summary>
        /// Awards Battle Points to the player.
        /// </summary>
        /// <param name="points">The number of points to award.</param>
        void awardBattlePoints(int points);

        /// <summary>
        /// Gets the rental Pokemon available for this facility.
        /// </summary>
        /// <returns>List of Pokemon available for rent.</returns>
        IList<object> getRentalPokemon();

        /// <summary>
        /// Selects rental Pokemon for the challenge.
        /// </summary>
        /// <param name="selectedPokemon">The Pokemon chosen for the team.</param>
        /// <returns>True if the selection was valid, false otherwise.</returns>
        bool selectRentalTeam(IList<object> selectedPokemon);

        /// <summary>
        /// Generates the next opponent for the challenge.
        /// </summary>
        /// <returns>The next trainer to battle.</returns>
        object generateNextOpponent();

        /// <summary>
        /// Checks if the challenge is complete.
        /// </summary>
        /// <returns>True if the challenge is finished, false otherwise.</returns>
        bool isChallengeComplete();

        /// <summary>
        /// Gets the reward for completing the challenge.
        /// </summary>
        /// <returns>The completion reward.</returns>
        object getCompletionReward();
    }

    /// <summary>
    /// Interface for Battle Palace mode where Pokemon act according to their nature.
    /// </summary>
    public interface IBattlePalaceBattle : IBattleFrontierChallenge
    {
        /// <summary>
        /// Determines the action a Pokemon will take based on its nature and status.
        /// </summary>
        /// <param name="pokemon">The Pokemon choosing an action.</param>
        /// <param name="availableActions">The actions available to the Pokemon.</param>
        /// <returns>The action the Pokemon will take.</returns>
        string determineNatureAction(object pokemon, IList<string> availableActions);

        /// <summary>
        /// Gets the mood of a Pokemon based on its HP and status.
        /// </summary>
        /// <param name="pokemon">The Pokemon to check the mood of.</param>
        /// <returns>The Pokemon's current mood.</returns>
        string getPokemonMood(object pokemon);

        /// <summary>
        /// Calculates the probability of a Pokemon using a specific type of move.
        /// </summary>
        /// <param name="pokemon">The Pokemon making the decision.</param>
        /// <param name="moveType">The type of move (attack, status, etc.).</param>
        /// <returns>The probability percentage.</returns>
        float getMoveTypeProbability(object pokemon, string moveType);
    }

    /// <summary>
    /// Interface for Battle Arena mode with special KO rules and time limits.
    /// </summary>
    public interface IBattleArenaBattle : IBattleFrontierChallenge
    {
        /// <summary>
        /// Gets the remaining turns before judgment.
        /// </summary>
        /// <returns>The number of turns left.</returns>
        int getTurnsRemaining();

        /// <summary>
        /// Performs arena judgment to determine the winner when turns run out.
        /// </summary>
        /// <param name="playerPokemon">The player's Pokemon.</param>
        /// <param name="opponentPokemon">The opponent's Pokemon.</param>
        /// <returns>The winner of the judgment.</returns>
        object performArenaJudgment(object playerPokemon, object opponentPokemon);

        /// <summary>
        /// Gets the Mind score for a Pokemon (aggressive actions taken).
        /// </summary>
        /// <param name="pokemon">The Pokemon to get the Mind score for.</param>
        /// <returns>The Mind score.</returns>
        int getMindScore(object pokemon);

        /// <summary>
        /// Gets the Skill score for a Pokemon (successful hits and critical hits).
        /// </summary>
        /// <param name="pokemon">The Pokemon to get the Skill score for.</param>
        /// <returns>The Skill score.</returns>
        int getSkillScore(object pokemon);

        /// <summary>
        /// Gets the Body score for a Pokemon (remaining HP percentage).
        /// </summary>
        /// <param name="pokemon">The Pokemon to get the Body score for.</param>
        /// <returns>The Body score.</returns>
        int getBodyScore(object pokemon);

        /// <summary>
        /// Updates the arena scores based on an action taken.
        /// </summary>
        /// <param name="pokemon">The Pokemon that took the action.</param>
        /// <param name="action">The action that was taken.</param>
        /// <param name="success">Whether the action was successful.</param>
        void updateArenaScores(object pokemon, string action, bool success);
    }

    /// <summary>
    /// Interface for recorded battle playback functionality.
    /// </summary>
    public interface IRecordedBattle : IAlternateBattleMode
    {
        /// <summary>
        /// Records a battle for later playback.
        /// </summary>
        /// <param name="battle">The battle to record.</param>
        /// <param name="filename">The filename to save the recording to.</param>
        void recordBattle(object battle, string filename);

        /// <summary>
        /// Loads a recorded battle from file.
        /// </summary>
        /// <param name="filename">The filename of the recorded battle.</param>
        /// <returns>The loaded battle data.</returns>
        object loadRecordedBattle(string filename);

        /// <summary>
        /// Plays back a recorded battle.
        /// </summary>
        /// <param name="battleData">The recorded battle data.</param>
        void playbackBattle(object battleData);

        /// <summary>
        /// Pauses or resumes battle playback.
        /// </summary>
        /// <param name="paused">Whether to pause the playback.</param>
        void setPaused(bool paused);

        /// <summary>
        /// Gets the current playback position.
        /// </summary>
        /// <returns>The current turn or frame being played.</returns>
        int getPlaybackPosition();

        /// <summary>
        /// Seeks to a specific position in the battle recording.
        /// </summary>
        /// <param name="position">The position to seek to.</param>
        void seekToPosition(int position);

        /// <summary>
        /// Gets the total length of the recorded battle.
        /// </summary>
        /// <returns>The total number of turns or frames in the recording.</returns>
        int getRecordingLength();

        /// <summary>
        /// Exports the battle recording to a shareable format.
        /// </summary>
        /// <param name="battleData">The battle data to export.</param>
        /// <param name="format">The export format.</param>
        /// <returns>The exported battle data.</returns>
        object exportBattle(object battleData, string format);
    }

    /// <summary>
    /// Interface for challenge rules and restrictions that can be applied to battles.
    /// </summary>
    public interface IChallengeRules
    {
        /// <summary>
        /// Gets the name of this rule set.
        /// </summary>
        /// <returns>The name of the rule set.</returns>
        string getRuleName();

        /// <summary>
        /// Validates that a Pokemon team meets the rule requirements.
        /// </summary>
        /// <param name="team">The team to validate.</param>
        /// <returns>True if the team is valid, false otherwise.</returns>
        bool validateTeam(IList<object> team);

        /// <summary>
        /// Gets a list of validation errors for a team.
        /// </summary>
        /// <param name="team">The team to validate.</param>
        /// <returns>List of error messages.</returns>
        IList<string> getValidationErrors(IList<object> team);

        /// <summary>
        /// Applies level restrictions to Pokemon.
        /// </summary>
        /// <param name="pokemon">The Pokemon to apply restrictions to.</param>
        /// <returns>The modified Pokemon.</returns>
        object applyLevelRestrictions(object pokemon);

        /// <summary>
        /// Checks if a specific Pokemon is banned under these rules.
        /// </summary>
        /// <param name="pokemon">The Pokemon to check.</param>
        /// <returns>True if the Pokemon is banned, false otherwise.</returns>
        bool isPokemonBanned(object pokemon);

        /// <summary>
        /// Checks if a specific move is banned under these rules.
        /// </summary>
        /// <param name="move">The move to check.</param>
        /// <returns>True if the move is banned, false otherwise.</returns>
        bool isMoveBanned(object move);

        /// <summary>
        /// Checks if a specific item is banned under these rules.
        /// </summary>
        /// <param name="item">The item to check.</param>
        /// <returns>True if the item is banned, false otherwise.</returns>
        bool isItemBanned(object item);

        /// <summary>
        /// Gets the maximum allowed level for Pokemon under these rules.
        /// </summary>
        /// <returns>The maximum level, or -1 if no limit.</returns>
        int getMaxLevel();

        /// <summary>
        /// Gets the minimum allowed level for Pokemon under these rules.
        /// </summary>
        /// <returns>The minimum level, or -1 if no limit.</returns>
        int getMinLevel();
    }

    /// <summary>
    /// Interface for Battle Frontier utilities and management functions.
    /// </summary>
    public interface IBattleFrontierUtilities
    {
        /// <summary>
        /// Starts a Battle Frontier challenge.
        /// </summary>
        /// <param name="facility">The facility to challenge.</param>
        /// <param name="rules">The rules to apply.</param>
        /// <returns>The result of the challenge.</returns>
        object startChallenge(string facility, IChallengeRules rules);

        /// <summary>
        /// Gets the player's current Battle Frontier record.
        /// </summary>
        /// <param name="facility">The facility to get records for.</param>
        /// <returns>The player's record for that facility.</returns>
        object getFrontierRecord(string facility);

        /// <summary>
        /// Awards a Battle Frontier symbol or trophy.
        /// </summary>
        /// <param name="facility">The facility awarding the symbol.</param>
        /// <param name="symbolType">The type of symbol (silver, gold, etc.).</param>
        void awardSymbol(string facility, string symbolType);

        /// <summary>
        /// Checks if the player has earned a specific symbol.
        /// </summary>
        /// <param name="facility">The facility to check.</param>
        /// <param name="symbolType">The symbol type to check for.</param>
        /// <returns>True if the player has the symbol, false otherwise.</returns>
        bool hasSymbol(string facility, string symbolType);

        /// <summary>
        /// Gets the current Battle Point total for the player.
        /// </summary>
        /// <returns>The number of Battle Points the player has.</returns>
        int getBattlePoints();

        /// <summary>
        /// Spends Battle Points on items or services.
        /// </summary>
        /// <param name="amount">The number of points to spend.</param>
        /// <param name="item">The item or service being purchased.</param>
        /// <returns>True if the purchase was successful, false otherwise.</returns>
        bool spendBattlePoints(int amount, object item);
    }
}