using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for managing Battle Challenge system including Battle Tower, Palace, Arena, and Factory
    /// </summary>
    public interface IBattleChallenge
    {
        /// <summary>
        /// Gets the current challenge ID being played
        /// </summary>
        string currentChallenge { get; }

        /// <summary>
        /// Initializes the Battle Challenge system
        /// </summary>
        IBattleChallenge initialize();

        /// <summary>
        /// Sets up a challenge with specified parameters
        /// </summary>
        /// <param name="id">Challenge identifier</param>
        /// <param name="numrounds">Number of rounds in the challenge</param>
        /// <param name="rules">Challenge rules</param>
        void set(string id, int numrounds, IPokemonChallengeRules rules);

        /// <summary>
        /// Registers a challenge type with battle configuration
        /// </summary>
        /// <param name="id">Challenge identifier</param>
        /// <param name="doublebattle">Whether battles are double battles</param>
        /// <param name="numPokemon">Number of Pokemon per team</param>
        /// <param name="battletype">Type of battle facility</param>
        /// <param name="mode">Challenge mode (optional, defaults to 1)</param>
        void register(string id, bool doublebattle, int numPokemon, int battletype, int mode = 1);

        /// <summary>
        /// Gets the rules for the current challenge
        /// </summary>
        /// <returns>Challenge rules</returns>
        IPokemonChallengeRules rules();

        /// <summary>
        /// Converts challenge parameters to specific rules
        /// </summary>
        /// <param name="doublebattle">Whether battles are double battles</param>
        /// <param name="numPokemon">Number of Pokemon per team</param>
        /// <param name="battletype">Type of battle facility</param>
        /// <param name="mode">Challenge mode</param>
        /// <returns>Generated challenge rules</returns>
        IPokemonChallengeRules modeToRules(bool doublebattle, int numPokemon, int battletype, int mode);

        /// <summary>
        /// Starts a challenge with optional arguments
        /// </summary>
        /// <param name="args">Variable arguments for challenge start</param>
        void start(params object[] args);

        /// <summary>
        /// Starts a specific challenge
        /// </summary>
        /// <param name="challenge">Challenge to start</param>
        void Start(object challenge);

        /// <summary>
        /// Ends the current challenge and saves results
        /// </summary>
        void End();

        /// <summary>
        /// Conducts a battle in the current challenge
        /// </summary>
        /// <returns>Battle outcome</returns>
        int Battle();

        /// <summary>
        /// Checks if a challenge is currently active (alias for InProgress)
        /// </summary>
        /// <returns>True if challenge is active, false otherwise</returns>
        bool InChallenge();

        /// <summary>
        /// Checks if a challenge is currently in progress
        /// </summary>
        /// <returns>True if challenge is in progress, false otherwise</returns>
        bool InProgress();

        /// <summary>
        /// Checks if the player is currently resting between battles
        /// </summary>
        /// <returns>True if resting, false otherwise</returns>
        bool Resting();

        /// <summary>
        /// Gets extra data for the challenge (e.g., Battle Factory data)
        /// </summary>
        /// <returns>Extra challenge data</returns>
        IBattleFactoryData extra { get; }

        /// <summary>
        /// Gets the current challenge decision/outcome
        /// </summary>
        /// <returns>Challenge decision</returns>
        int decision { get; }

        /// <summary>
        /// Gets the current number of wins
        /// </summary>
        /// <returns>Number of wins</returns>
        int wins { get; }

        /// <summary>
        /// Gets the current number of swaps (Battle Factory)
        /// </summary>
        /// <returns>Number of swaps</returns>
        int swaps { get; }

        /// <summary>
        /// Gets the current battle number
        /// </summary>
        /// <returns>Battle number</returns>
        int battleNumber { get; }

        /// <summary>
        /// Gets the next trainer to battle
        /// </summary>
        /// <returns>Trainer ID</returns>
        int nextTrainer { get; }

        /// <summary>
        /// Continues the challenge after resting
        /// </summary>
        void GoOn();

        /// <summary>
        /// Adds a win to the current challenge
        /// </summary>
        void AddWin();

        /// <summary>
        /// Cancels the current challenge
        /// </summary>
        void Cancel();

        /// <summary>
        /// Sets the challenge to rest state
        /// </summary>
        void Rest();

        /// <summary>
        /// Checks if the current match/round is over
        /// </summary>
        /// <returns>True if match is over, false otherwise</returns>
        bool MatchOver();

        /// <summary>
        /// Transfers player to the challenge start location
        /// </summary>
        void GoToStart();

        /// <summary>
        /// Sets the challenge decision/outcome
        /// </summary>
        /// <param name="value">Decision value</param>
        void setDecision(int value);

        /// <summary>
        /// Sets the player's party for the challenge
        /// </summary>
        /// <param name="value">Pokemon party</param>
        void setParty(IList<IPokemon> value);

        /// <summary>
        /// Gets data for the current challenge
        /// </summary>
        /// <returns>Challenge type data</returns>
        IBattleChallengeType data();

        /// <summary>
        /// Gets current wins for a specific challenge
        /// </summary>
        /// <param name="challenge">Challenge identifier</param>
        /// <returns>Current wins</returns>
        int getCurrentWins(int challenge);

        /// <summary>
        /// Gets previous wins for a specific challenge
        /// </summary>
        /// <param name="challenge">Challenge identifier</param>
        /// <returns>Previous wins</returns>
        int getPreviousWins(int challenge);

        /// <summary>
        /// Gets maximum wins for a specific challenge
        /// </summary>
        /// <param name="challenge">Challenge identifier</param>
        /// <returns>Maximum wins</returns>
        int getMaxWins(int challenge);

        /// <summary>
        /// Gets current swaps for a specific challenge
        /// </summary>
        /// <param name="challenge">Challenge identifier</param>
        /// <returns>Current swaps</returns>
        int getCurrentSwaps(int challenge);

        /// <summary>
        /// Gets previous swaps for a specific challenge
        /// </summary>
        /// <param name="challenge">Challenge identifier</param>
        /// <returns>Previous swaps</returns>
        int getPreviousSwaps(int challenge);

        /// <summary>
        /// Gets maximum swaps for a specific challenge
        /// </summary>
        /// <param name="challenge">Challenge identifier</param>
        /// <returns>Maximum swaps</returns>
        int getMaxSwaps(int challenge);
    }

    /// <summary>
    /// Interface for Battle Challenge data management
    /// </summary>
    public interface IBattleChallengeData
    {
        /// <summary>
        /// Gets the current battle number
        /// </summary>
        int battleNumber { get; }

        /// <summary>
        /// Gets the number of rounds in this challenge
        /// </summary>
        int numRounds { get; }

        /// <summary>
        /// Gets the player's party for this challenge
        /// </summary>
        IList<IPokemon> party { get; }

        /// <summary>
        /// Gets whether the challenge is in progress
        /// </summary>
        bool inProgress { get; }

        /// <summary>
        /// Gets whether the player is resting
        /// </summary>
        bool resting { get; }

        /// <summary>
        /// Gets the current number of wins
        /// </summary>
        int wins { get; }

        /// <summary>
        /// Gets the current number of swaps
        /// </summary>
        int swaps { get; }

        /// <summary>
        /// Gets or sets the challenge decision/outcome
        /// </summary>
        int decision { get; set; }

        /// <summary>
        /// Gets the extra data for special challenges
        /// </summary>
        IBattleFactoryData extraData { get; }

        /// <summary>
        /// Initializes the challenge data
        /// </summary>
        IBattleChallengeData initialize();

        /// <summary>
        /// Sets extra data for the challenge
        /// </summary>
        /// <param name="value">Extra data object</param>
        void setExtraData(IBattleFactoryData value);

        /// <summary>
        /// Sets the player's party
        /// </summary>
        /// <param name="value">Pokemon party</param>
        void setParty(IList<IPokemon> value);

        /// <summary>
        /// Starts a challenge
        /// </summary>
        /// <param name="t">Challenge type</param>
        /// <param name="numRounds">Number of rounds</param>
        void Start(IBattleChallengeType t, int numRounds);

        /// <summary>
        /// Transfers player to challenge start location
        /// </summary>
        void GoToStart();

        /// <summary>
        /// Adds a win to the challenge
        /// </summary>
        void AddWin();

        /// <summary>
        /// Adds a swap to the challenge count
        /// </summary>
        void AddSwap();

        /// <summary>
        /// Checks if the match is over
        /// </summary>
        /// <returns>True if match is over, false otherwise</returns>
        bool MatchOver();

        /// <summary>
        /// Sets the challenge to rest state
        /// </summary>
        void Rest();

        /// <summary>
        /// Continues the challenge after resting
        /// </summary>
        void GoOn();

        /// <summary>
        /// Cancels the current challenge
        /// </summary>
        void Cancel();

        /// <summary>
        /// Ends the current challenge
        /// </summary>
        void End();

        /// <summary>
        /// Gets the next trainer to battle
        /// </summary>
        /// <returns>Trainer ID</returns>
        int nextTrainer();
    }

    /// <summary>
    /// Interface for Battle Challenge type configuration
    /// </summary>
    public interface IBattleChallengeType
    {
        /// <summary>
        /// Gets or sets the current wins for this challenge type
        /// </summary>
        int currentWins { get; set; }

        /// <summary>
        /// Gets or sets the previous wins for this challenge type
        /// </summary>
        int previousWins { get; set; }

        /// <summary>
        /// Gets or sets the maximum wins achieved for this challenge type
        /// </summary>
        int maxWins { get; set; }

        /// <summary>
        /// Gets or sets the current swaps for this challenge type
        /// </summary>
        int currentSwaps { get; set; }

        /// <summary>
        /// Gets or sets the previous swaps for this challenge type
        /// </summary>
        int previousSwaps { get; set; }

        /// <summary>
        /// Gets or sets the maximum swaps for this challenge type
        /// </summary>
        int maxSwaps { get; set; }

        /// <summary>
        /// Gets whether this challenge uses double battles
        /// </summary>
        bool doublebattle { get; }

        /// <summary>
        /// Gets the number of Pokemon per team
        /// </summary>
        int numPokemon { get; }

        /// <summary>
        /// Gets the battle type (Tower, Palace, Arena, Factory)
        /// </summary>
        int battletype { get; }

        /// <summary>
        /// Gets the challenge mode
        /// </summary>
        int mode { get; }

        /// <summary>
        /// Initializes the challenge type
        /// </summary>
        IBattleChallengeType initialize();

        /// <summary>
        /// Saves wins and swaps data after a challenge
        /// </summary>
        /// <param name="challenge">Challenge data to save from</param>
        void saveWins(IBattleChallengeData challenge);

        /// <summary>
        /// Creates a copy of this challenge type
        /// </summary>
        /// <returns>Cloned challenge type</returns>
        IBattleChallengeType clone();
    }

    /// <summary>
    /// Interface for Battle Factory specific data and operations
    /// </summary>
    public interface IBattleFactoryData
    {
        /// <summary>
        /// Initializes Battle Factory data
        /// </summary>
        /// <param name="bcdata">Battle challenge data</param>
        IBattleFactoryData initialize(IBattleChallengeData bcdata);

        /// <summary>
        /// Prepares rental Pokemon for the player to choose from
        /// </summary>
        void PrepareRentals();

        /// <summary>
        /// Handles the rental Pokemon selection process
        /// </summary>
        void ChooseRentals();

        /// <summary>
        /// Prepares Pokemon swapping options
        /// </summary>
        void PrepareSwaps();

        /// <summary>
        /// Handles the Pokemon swapping process
        /// </summary>
        /// <returns>True if a swap was made, false otherwise</returns>
        bool ChooseSwaps();

        /// <summary>
        /// Conducts a Battle Factory battle
        /// </summary>
        /// <param name="challenge">Current challenge</param>
        /// <returns>Battle outcome</returns>
        int Battle(IBattleChallenge challenge);
    }
}