using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for Pokemon data analysis and generation utilities
    /// </summary>
    public interface IMainChallengeGeneratorPokemon :  IMain
    {
        /// <summary>
        /// Calculates the base stat total for a Pokemon species
        /// </summary>
        /// <param name="species">Species ID</param>
        /// <returns>Total of all base stats</returns>
        int pbBaseStatTotal(int species);

        /// <summary>
        /// Gets cached base stat total for a species
        /// </summary>
        /// <param name="species">Species ID</param>
        /// <returns>Cached base stat total</returns>
        int baseStatTotal(int species);

        /// <summary>
        /// Gets the baby form of a species
        /// </summary>
        /// <param name="species">Species ID</param>
        /// <returns>Baby species ID</returns>
        int babySpecies(int species);

        /// <summary>
        /// Gets the minimum level a species can be encountered at
        /// </summary>
        /// <param name="species">Species ID</param>
        /// <returns>Minimum level</returns>
        int minimumLevel(int species);

        /// <summary>
        /// Gets all evolution possibilities for a species
        /// </summary>
        /// <param name="species">Species ID</param>
        /// <returns>List of evolution data</returns>
        IList<object> evolutions(int species);

        /// <summary>
        /// Generates a random move (used to replace Sketch)
        /// </summary>
        /// <returns>Random move ID</returns>
        int pbRandomMove();

        /// <summary>
        /// Gets all legal moves for a species up to specified level
        /// </summary>
        /// <param name="species">Species ID</param>
        /// <param name="maxlevel">Maximum level to consider</param>
        /// <returns>List of legal move IDs</returns>
        IList<int> pbGetLegalMoves2(int species, int maxlevel);

        /// <summary>
        /// Adds a move to the moves list with specified priority
        /// </summary>
        /// <param name="moves">List of moves to add to</param>
        /// <param name="move">Move to add</param>
        /// <param name="priority">Priority level</param>
        void addMove(IList<int> moves, int move, int priority);

        /// <summary>
        /// Gets legal moves for a species at specific level
        /// </summary>
        /// <param name="species">Species ID</param>
        /// <param name="level">Level to check moves for</param>
        /// <returns>List of legal move IDs</returns>
        IList<int> pbGetLegalMoves(int species, int level);

        /// <summary>
        /// Creates a random Pokemon based on challenge rules
        /// </summary>
        /// <param name="rule">Challenge rules to follow</param>
        /// <param name="trainer">Owner trainer (optional)</param>
        /// <returns>Generated Pokemon</returns>
        IPokemon pbRandomPokemonFromRule(IPokemonChallengeRules rule, ITrainer trainer);

        /// <summary>
        /// Creates a specific Pokemon with optimal moves and stats
        /// </summary>
        /// <param name="species">Species to create</param>
        /// <param name="level">Level of Pokemon</param>
        /// <param name="trainer">Owner trainer</param>
        /// <param name="movepool">Available moves</param>
        /// <param name="banned">Banned moves list</param>
        /// <param name="item">Held item (optional)</param>
        /// <param name="nature">Nature (optional)</param>
        /// <param name="ivs">IV values (optional)</param>
        /// <param name="happiness">Happiness value (optional)</param>
        /// <param name="nickname">Pokemon nickname (optional)</param>
        /// <param name="shadow">Whether Pokemon is shadow (optional)</param>
        /// <returns>Created Pokemon</returns>
        IPokemon pbMakePokemon(int species, int level, ITrainer trainer, IList<int> movepool,
                               IList<int> banned = null, int? item = null, int? nature = null,
                               IDictionary<string, int> ivs = null, int happiness = 255,
                               string nickname = null, bool shadow = false);

        /// <summary>
        /// Gets all valid moves for a Pokemon excluding banned moves
        /// </summary>
        /// <param name="pkmn">Pokemon to get moves for</param>
        /// <param name="movepool">Available move pool</param>
        /// <param name="banned">Banned moves list</param>
        /// <returns>List of valid moves</returns>
        IList<int> pbGetValidMoves(IPokemon pkmn, IList<int> movepool, IList<int> banned);

        /// <summary>
        /// Chooses optimal moves for a Pokemon based on strategy
        /// </summary>
        /// <param name="pkmn">Pokemon to choose moves for</param>
        /// <param name="moves">Available moves</param>
        /// <param name="count">Number of moves to choose</param>
        /// <returns>List of chosen moves</returns>
        IList<int> pbChooseMoves(IPokemon pkmn, IList<int> moves, int count);

        /// <summary>
        /// Assigns optimal nature based on Pokemon's stats and moves
        /// </summary>
        /// <param name="pkmn">Pokemon to assign nature to</param>
        void pbOptimalNature(IPokemon pkmn);

        /// <summary>
        /// Assigns optimal ability for a Pokemon
        /// </summary>
        /// <param name="pkmn">Pokemon to assign ability to</param>
        void pbOptimalAbility(IPokemon pkmn);

        /// <summary>
        /// Assigns optimal held item for a Pokemon
        /// </summary>
        /// <param name="pkmn">Pokemon to assign item to</param>
        void pbOptimalItem(IPokemon pkmn);

        /// <summary>
        /// Distributes EVs optimally based on Pokemon's role
        /// </summary>
        /// <param name="pkmn">Pokemon to distribute EVs for</param>
        void pbOptimalEVs(IPokemon pkmn);
    }

    /// <summary>
    /// Interface for move rating and selection
    /// </summary>
    public interface IMoveRater
    {
        /// <summary>
        /// Rates a move's effectiveness for a Pokemon
        /// </summary>
        /// <param name="move">Move to rate</param>
        /// <param name="pkmn">Pokemon using the move</param>
        /// <param name="movepool">Available move pool</param>
        /// <returns>Rating score for the move</returns>
        int rateMoveForPokemon(int move, IPokemon pkmn, IList<int> movepool);

        /// <summary>
        /// Gets the category of a move (physical, special, status)
        /// </summary>
        /// <param name="move">Move to categorize</param>
        /// <returns>Move category</returns>
        int getMoveCategory(int move);

        /// <summary>
        /// Checks if a move provides type coverage
        /// </summary>
        /// <param name="move">Move to check</param>
        /// <param name="existingMoves">Moves already selected</param>
        /// <returns>True if provides new coverage, false otherwise</returns>
        bool providesTypeCoverage(int move, IList<int> existingMoves);

        /// <summary>
        /// Rates how well a move synergizes with Pokemon's stats
        /// </summary>
        /// <param name="move">Move to rate</param>
        /// <param name="pkmn">Pokemon using the move</param>
        /// <returns>Synergy rating</returns>
        int rateMoveSynergy(int move, IPokemon pkmn);
    }

    /// <summary>
    /// Interface for Pokemon nature optimization
    /// </summary>
    public interface INatureOptimizer
    {
        /// <summary>
        /// Determines the best nature for a Pokemon based on its moves and role
        /// </summary>
        /// <param name="pkmn">Pokemon to optimize nature for</param>
        /// <returns>Optimal nature ID</returns>
        int getBestNature(IPokemon pkmn);

        /// <summary>
        /// Analyzes Pokemon's moves to determine its role
        /// </summary>
        /// <param name="pkmn">Pokemon to analyze</param>
        /// <returns>Pokemon's primary role</returns>
        string determinePokemonRole(IPokemon pkmn);

        /// <summary>
        /// Gets nature recommendations based on role
        /// </summary>
        /// <param name="role">Pokemon's role</param>
        /// <returns>List of recommended natures</returns>
        IList<int> getNaturesForRole(string role);
    }
}