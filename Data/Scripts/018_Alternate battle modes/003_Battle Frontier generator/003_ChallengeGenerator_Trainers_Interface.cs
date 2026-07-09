using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for trainer generation and management in challenges
    /// </summary>
    public interface IMainChallengeGeneratorTrainers : IMain
    {
        /// <summary>
        /// Gets the types of a Pokemon species
        /// </summary>
        /// <param name="species">Species ID</param>
        /// <returns>List of type IDs</returns>
        IList<int> getTypes(int species);

        /// <summary>
        /// Generates trainer information and assigns Pokemon from provided list
        /// </summary>
        /// <param name="pokemonlist">List of Pokemon to assign to trainers</param>
        /// <param name="trfile">Trainer file identifier</param>
        /// <param name="rules">Challenge rules to follow</param>
        void pbTrainerInfo(IList<IPokemon> pokemonlist, string trfile, IPokemonChallengeRules rules);
        /*
        /// <summary>
        /// Creates a random trainer with specified parameters
        /// </summary>
        /// <param name="trainerType">Type of trainer</param>
        /// <param name="name">Trainer name</param>
        /// <param name="introText">Introduction speech</param>
        /// <param name="winText">Victory speech</param>
        /// <param name="loseText">Defeat speech</param>
        /// <param name="pokemonIndices">Indices of Pokemon assigned to trainer</param>
        /// <returns>Trainer data array</returns>
        IList<object> createTrainerData(string trainerType, string name, string introText,
                                       string winText, string loseText, IList<int> pokemonIndices);

        /// <summary>
        /// Generates a random name for a trainer based on gender
        /// </summary>
        /// <param name="gender">Trainer gender</param>
        /// <param name="language">Language for name generation (optional)</param>
        /// <param name="minLength">Minimum name length</param>
        /// <param name="maxLength">Maximum name length</param>
        /// <returns>Generated random name</returns>
        string getRandomNameEx(int gender, string language, int minLength, int maxLength);

        /// <summary>
        /// Sorts trainers by their base money value
        /// </summary>
        /// <param name="trainers">List of trainer data to sort</param>
        /// <returns>Sorted trainer list</returns>
        IList<IList<object>> sortTrainersByMoney(IList<IList<object>> trainers);

        /// <summary>
        /// Assigns Pokemon to trainers based on type preferences and balance
        /// </summary>
        /// <param name="trainers">List of trainers</param>
        /// <param name="pokemonlist">Available Pokemon</param>
        /// <param name="rules">Challenge rules</param>
        void assignPokemonToTrainers(IList<IList<object>> trainers, IList<IPokemon> pokemonlist,
                                   IPokemonChallengeRules rules);

        /// <summary>
        /// Calculates type distribution for a trainer's Pokemon
        /// </summary>
        /// <param name="pokemonIndices">Indices of trainer's Pokemon</param>
        /// <param name="pokemonlist">Full Pokemon list</param>
        /// <returns>Dictionary of type counts</returns>
        IDictionary<string, int> calculateTypeDistribution(IList<int> pokemonIndices, IList<IPokemon> pokemonlist);

        /// <summary>
        /// Selects optimal Pokemon for a trainer based on type balance
        /// </summary>
        /// <param name="availablePokemon">Pokemon available for selection</param>
        /// <param name="targetCount">Number of Pokemon to select</param>
        /// <param name="typePreferences">Preferred types for this trainer</param>
        /// <returns>Selected Pokemon indices</returns>
        IList<int> selectOptimalPokemon(IList<int> availablePokemon, int targetCount,
                                       IDictionary<string, double> typePreferences);

        /// <summary>
        /// Validates that a trainer's team follows challenge rules
        /// </summary>
        /// <param name="pokemonIndices">Trainer's Pokemon indices</param>
        /// <param name="pokemonlist">Full Pokemon list</param>
        /// <param name="rules">Challenge rules</param>
        /// <returns>True if team is valid, false otherwise</returns>
        bool validateTrainerTeam(IList<int> pokemonIndices, IList<IPokemon> pokemonlist,
                               IPokemonChallengeRules rules);

        /// <summary>
        /// Creates type preferences for different trainer types
        /// </summary>
        /// <param name="trainerType">Type of trainer</param>
        /// <returns>Dictionary of type preferences (0.0 to 1.0)</returns>
        IDictionary<string, double> getTypePreferencesForTrainer(string trainerType);

        /// <summary>
        /// Balances trainer difficulties across the challenge
        /// </summary>
        /// <param name="trainers">List of all trainers</param>
        /// <param name="pokemonlist">Available Pokemon</param>
        void balanceTrainerDifficulty(IList<IList<object>> trainers, IList<IPokemon> pokemonlist);

        /// <summary>
        /// Estimates the difficulty rating of a trainer's team
        /// </summary>
        /// <param name="pokemonIndices">Trainer's Pokemon indices</param>
        /// <param name="pokemonlist">Full Pokemon list</param>
        /// <returns>Difficulty rating (higher = more difficult)</returns>
        double calculateTeamDifficulty(IList<int> pokemonIndices, IList<IPokemon> pokemonlist);

        /// <summary>
        /// Saves trainer data to appropriate files
        /// </summary>
        /// <param name="trainers">Trainer data to save</param>
        /// <param name="pokemonlist">Pokemon data to save</param>
        /// <param name="filename">Target filename</param>
        void saveTrainerData(IList<IList<object>> trainers, IList<IPokemon> pokemonlist, string filename);
    }

    /// <summary>
    /// Interface for trainer type analysis and categorization
    /// </summary>
    public interface ITrainerTypeAnalyzer
    {
        /// <summary>
        /// Analyzes trainer type characteristics
        /// </summary>
        /// <param name="trainerType">Trainer type to analyze</param>
        /// <returns>Analysis data including preferred types, difficulty, etc.</returns>
        ITrainerTypeAnalysis analyzeTrainerType(string trainerType);

        /// <summary>
        /// Gets all available trainer types suitable for challenges
        /// </summary>
        /// <param name="maxBaseMoney">Maximum base money for filtering</param>
        /// <returns>List of suitable trainer type IDs</returns>
        IList<string> getSuitableTrainerTypes(int maxBaseMoney);

        /// <summary>
        /// Determines if a trainer type has type specialization
        /// </summary>
        /// <param name="trainerType">Trainer type to check</param>
        /// <returns>Primary specialized type, or null if none</returns>
        string getTrainerTypeSpecialization(string trainerType);
    }

    /// <summary>
    /// Interface for trainer type analysis results
    /// </summary>
    public interface ITrainerTypeAnalysis
    {
        /// <summary>
        /// Gets the preferred Pokemon types for this trainer type
        /// </summary>
        IList<string> preferredTypes { get; }

        /// <summary>
        /// Gets the base difficulty level of this trainer type
        /// </summary>
        double baseDifficulty { get; }

        /// <summary>
        /// Gets the gender of this trainer type
        /// </summary>
        int gender { get; }

        /// <summary>
        /// Gets the base money value for this trainer type
        /// </summary>
        int baseMoney { get; }

        /// <summary>
        /// Gets whether this trainer type typically uses items
        /// </summary>
        bool usesItems { get; }

        /// <summary>
        /// Gets the typical team size for this trainer type
        /// </summary>
        int typicalTeamSize { get; }
    */
    }
}