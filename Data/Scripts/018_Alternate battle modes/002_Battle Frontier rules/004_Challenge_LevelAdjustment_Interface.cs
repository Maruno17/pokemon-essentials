using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for level adjustment systems in battle challenges
    /// </summary>
    public interface ILevelAdjustment
    {
        /// <summary>
        /// Gets the adjustment type (which teams are affected)
        /// </summary>
        int type { get; }

        /// <summary>
        /// Initializes the level adjustment with specified type
        /// </summary>
        /// <param name="adjustment">Adjustment type constant</param>
        ILevelAdjustment initialize(int adjustment);

        /// <summary>
        /// Gets null adjustment (original levels) for a team
        /// </summary>
        /// <param name="thisTeam">Team to get levels for</param>
        /// <param name="otherTeam">Other team (for context)</param>
        /// <returns>Array of original levels</returns>
        //static IList<int> getNullAdjustment(IList<IPokemon> thisTeam, IList<IPokemon> otherTeam);

        /// <summary>
        /// Gets the level adjustment for a team
        /// </summary>
        /// <param name="thisTeam">Team to adjust</param>
        /// <param name="otherTeam">Other team (for context)</param>
        /// <returns>Array of adjusted levels</returns>
        IList<int> getAdjustment(IList<IPokemon> thisTeam, IList<IPokemon> otherTeam);

        /// <summary>
        /// Gets original experience values before adjustment
        /// </summary>
        /// <param name="team1">First team</param>
        /// <param name="team2">Second team</param>
        /// <returns>Array of original experience values</returns>
        IList<int?> getOldExp(IList<IPokemon> team1, IList<IPokemon> team2);

        /// <summary>
        /// Restores teams to their original levels after battle
        /// </summary>
        /// <param name="team1">First team</param>
        /// <param name="team2">Second team</param>
        /// <param name="adjustments">Original experience data</param>
        void unadjustLevels(IList<IPokemon> team1, IList<IPokemon> team2, object adjustments);

        /// <summary>
        /// Adjusts levels of both teams before battle
        /// </summary>
        /// <param name="team1">First team</param>
        /// <param name="team2">Second team</param>
        /// <returns>Original experience data for restoration</returns>
        int?[][] adjustLevels(IList<IPokemon> team1, IList<IPokemon> team2);
    }

    /// <summary>
    /// Interface for fixed level adjustment (sets all Pokemon to specific level)
    /// </summary>
    public interface IFixedLevelAdjustment : ILevelAdjustment
    {
        /// <summary>
        /// Initializes with fixed level
        /// </summary>
        /// <param name="level">Level to set all Pokemon to</param>
        IFixedLevelAdjustment initialize(int level);

        /// <summary>
        /// Gets adjustment that sets all Pokemon to the fixed level
        /// </summary>
        /// <param name="thisTeam">Team to adjust</param>
        /// <param name="otherTeam">Other team (unused)</param>
        /// <returns>Array of fixed levels</returns>
        IList<int> getAdjustment(IList<IPokemon> thisTeam, IList<IPokemon> otherTeam);
    }

    /// <summary>
    /// Interface for total level adjustment (distributes total level across team)
    /// </summary>
    public interface ITotalLevelAdjustment : ILevelAdjustment
    {
        /// <summary>
        /// Initializes with level constraints
        /// </summary>
        /// <param name="minLevel">Minimum level per Pokemon</param>
        /// <param name="maxLevel">Maximum level per Pokemon</param>
        /// <param name="totalLevel">Total level budget for team</param>
        ITotalLevelAdjustment initialize(int minLevel, int maxLevel, int totalLevel);

        /// <summary>
        /// Gets adjustment that distributes total level budget
        /// </summary>
        /// <param name="thisTeam">Team to adjust</param>
        /// <param name="otherTeam">Other team (unused)</param>
        /// <returns>Array of adjusted levels</returns>
        IList<int> getAdjustment(IList<IPokemon> thisTeam, IList<IPokemon> otherTeam);
    }

    /// <summary>
    /// Interface for combined level adjustment (different adjustments for each team)
    /// </summary>
    public interface ICombinedLevelAdjustment : ILevelAdjustment
    {
        /// <summary>
        /// Initializes with separate adjustments for each team
        /// </summary>
        /// <param name="my">Adjustment for player's team</param>
        /// <param name="their">Adjustment for opponent's team</param>
        ICombinedLevelAdjustment initialize(ILevelAdjustment my, ILevelAdjustment their);

        /// <summary>
        /// Gets adjustment for player's team
        /// </summary>
        /// <param name="myTeam">Player's team</param>
        /// <param name="theirTeam">Opponent's team</param>
        /// <returns>Array of adjusted levels</returns>
        IList<int> getMyAdjustment(IList<IPokemon> myTeam, IList<IPokemon> theirTeam);

        /// <summary>
        /// Gets adjustment for opponent's team
        /// </summary>
        /// <param name="theirTeam">Opponent's team</param>
        /// <param name="myTeam">Player's team</param>
        /// <returns>Array of adjusted levels</returns>
        IList<int> getTheirAdjustment(IList<IPokemon> theirTeam, IList<IPokemon> myTeam);
    }

    /// <summary>
    /// Interface for single player capped level adjustment
    /// </summary>
    public interface ISinglePlayerCappedLevelAdjustment : ICombinedLevelAdjustment
    {
        /// <summary>
        /// Initializes with level cap
        /// </summary>
        /// <param name="level">Level cap</param>
        ISinglePlayerCappedLevelAdjustment initialize(int level);
    }

    /// <summary>
    /// Interface for capped level adjustment (caps levels at maximum)
    /// </summary>
    public interface ICappedLevelAdjustment : ILevelAdjustment
    {
        /// <summary>
        /// Initializes with level cap
        /// </summary>
        /// <param name="level">Maximum level allowed</param>
        ICappedLevelAdjustment initialize(int level);

        /// <summary>
        /// Gets adjustment that caps levels at maximum
        /// </summary>
        /// <param name="thisTeam">Team to adjust</param>
        /// <param name="otherTeam">Other team (unused)</param>
        /// <returns>Array of capped levels</returns>
        IList<int> getAdjustment(IList<IPokemon> thisTeam, IList<IPokemon> otherTeam);
    }

    /// <summary>
    /// Interface for level balance adjustment based on base stats
    /// </summary>
    public interface ILevelBalanceAdjustment : ILevelAdjustment
    {
        /// <summary>
        /// Initializes with minimum level
        /// </summary>
        /// <param name="minLevel">Minimum level allowed</param>
        ILevelBalanceAdjustment initialize(int minLevel);

        /// <summary>
        /// Gets adjustment based on base stat totals
        /// </summary>
        /// <param name="thisTeam">Team to adjust</param>
        /// <param name="otherTeam">Other team (unused)</param>
        /// <returns>Array of balanced levels</returns>
        IList<int> getAdjustment(IList<IPokemon> thisTeam, IList<IPokemon> otherTeam);
    }

    /// <summary>
    /// Interface for enemy team level adjustment
    /// </summary>
    public interface IEnemyLevelAdjustment : ILevelAdjustment
    {
        /// <summary>
        /// Initializes with fixed level for enemies
        /// </summary>
        /// <param name="level">Level to set enemy Pokemon to</param>
        IEnemyLevelAdjustment initialize(int level);

        /// <summary>
        /// Gets adjustment that sets enemy team to fixed level
        /// </summary>
        /// <param name="thisTeam">Enemy team to adjust</param>
        /// <param name="otherTeam">Player team (unused)</param>
        /// <returns>Array of fixed levels</returns>
        IList<int> getAdjustment(IList<IPokemon> thisTeam, IList<IPokemon> otherTeam);
    }

    /// <summary>
    /// Interface for open level adjustment (matches highest level)
    /// </summary>
    public interface IOpenLevelAdjustment : ILevelAdjustment
    {
        /// <summary>
        /// Initializes with minimum level threshold
        /// </summary>
        /// <param name="minLevel">Minimum level to use (optional, defaults to 1)</param>
        IOpenLevelAdjustment initialize(int minLevel = 1);

        /// <summary>
        /// Gets adjustment that matches the highest level in opposing team
        /// </summary>
        /// <param name="thisTeam">Team to adjust</param>
        /// <param name="otherTeam">Team to match against</param>
        /// <returns>Array of adjusted levels</returns>
        IList<int> getAdjustment(IList<IPokemon> thisTeam, IList<IPokemon> otherTeam);
    }
}