using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for ruled team management and rating system
    /// </summary>
    public interface IRuledTeam
    {
        /// <summary>
        /// Gets or sets the team array
        /// </summary>
        IList<IPokemon> team { get; set; }

        /// <summary>
        /// Initializes a ruled team from a party following specific rules
        /// </summary>
        /// <param name="party">Pokemon party to select from</param>
        /// <param name="rule">Rules to follow for team selection</param>
        IRuledTeam initialize(IList<IPokemon> party, IPokemonChallengeRules rule);

        /// <summary>
        /// Gets Pokemon at specified index
        /// </summary>
        /// <param name="i">Index</param>
        /// <returns>Pokemon at index</returns>
        IPokemon this[int i] { get; }

        /// <summary>
        /// Gets the length of the team
        /// </summary>
        /// <returns>Number of Pokemon in team</returns>
        int length { get; }

        /// <summary>
        /// Gets the team's current win chance percentage rating
        /// </summary>
        /// <returns>Win chance percentage</returns>
        double rating();

        /// <summary>
        /// Gets the team's rating data object
        /// </summary>
        /// <returns>Player rating object</returns>
        IPlayerRating ratingData();

        /// <summary>
        /// Gets raw rating data as array
        /// </summary>
        /// <returns>Array containing rating, deviation, volatility, and win chance</returns>
        double[] ratingRaw();

        /// <summary>
        /// Compares this team's rating with another team
        /// </summary>
        /// <param name="other">Other team to compare against</param>
        /// <returns>Comparison result</returns>
        double compare(IRuledTeam other);

        /// <summary>
        /// Gets total number of games played (including historical)
        /// </summary>
        /// <returns>Total games count</returns>
        int totalGames();

        /// <summary>
        /// Adds a match result to the team's history
        /// </summary>
        /// <param name="other">Opponent team</param>
        /// <param name="score">Match score (1.0 = win, 0.5 = draw, 0.0 = loss)</param>
        void addMatch(IRuledTeam other, double score);

        /// <summary>
        /// Gets current number of games in history
        /// </summary>
        /// <returns>Games count</returns>
        int games();

        /// <summary>
        /// Updates the team's rating based on match history and clears history
        /// </summary>
        void updateRating();

        /// <summary>
        /// Converts team rating to string representation
        /// </summary>
        /// <returns>String representation of rating and games</returns>
        string toStr();

        /// <summary>
        /// Loads actual Pokemon instances from party based on team indices
        /// </summary>
        /// <param name="party">Full Pokemon party</param>
        /// <returns>List of Pokemon corresponding to this team</returns>
        IList<IPokemon> load(IList<IPokemon> party);
    }

    public interface ISingleMatch {
        float  opponentRating				{ get; }
        float  opponentDeviation				{ get; }
        int score				{ get; }
        int kValue				{ get; }

        ISingleMatch initialize(float opponentRating, float opponentDev, int score, int kValue = 16);
    }

    /// <summary>
    /// Interface for match history tracking
    /// </summary>
    public interface IMatchHistory : IEnumerable<ISingleMatch>
    {
        IEnumerable<ISingleMatch> each();

        /// <summary>
        /// Gets the number of matches in history
        /// </summary>
        int length { get; }

        ISingleMatch this[int i] { get; }

        /// <summary>
        /// Initializes match history with player rating
        /// </summary>
        /// <param name="playerRating">Player's rating object</param>
        IMatchHistory initialize(IPlayerRating playerRating);

        /// <summary>
        /// Adds a match result to the history
        /// </summary>
        /// <param name="opponentRating">Opponent's rating</param>
        /// <param name="score">Match score</param>
        void addMatch(IPlayerRating opponentRating, double score);

        /// <summary>
        /// Updates player rating based on history and clears the history
        /// </summary>
        void updateAndClear();

        /// <summary>
        /// Clears all match history
        /// </summary>
        //void clear();

        /// <summary>
        /// Gets all opponent ratings from history
        /// </summary>
        /// <returns>List of opponent ratings</returns>
        //IList<IPlayerRating> getOpponents();

        /// <summary>
        /// Gets all match scores from history
        /// </summary>
        /// <returns>List of match scores</returns>
        //IList<double> getScores();
    }

    public interface IPlayerRatingElo : IPlayerRating
    {
        //float rating				{ get; }
        //K_VALUE = 16;

        new IPlayerRatingElo initialize();

        //float winChancePercent { get; }

        void update(IList<ISingleMatch> matches);
    }

    /// <summary>
    /// Interface for player rating system (likely ELO-based)
    /// </summary>
    public interface IPlayerRating
    {
        /// <summary>
        /// Gets the rating volatility
        /// </summary>
        double volatility { get; }

        /// <summary>
        /// Gets the rating deviation (uncertainty)
        /// </summary>
        double deviation { get; }

        /// <summary>
        /// Gets the base rating value
        /// </summary>
        double rating { get; }

        /// <summary>
        /// Initializes a new player rating
        /// </summary>
        IPlayerRating initialize();

        /// <summary>
        /// Gets the win chance percentage against average opponent
        /// </summary>
        double winChancePercent { get; }

        /// <summary>
        /// Compares this rating with another player's rating
        /// </summary>
        /// <param name="other">Other player's rating</param>
        /// <returns>Expected score against other player</returns>
        //double compare(IPlayerRating other);

        /// <summary>
        /// Updates rating based on match results
        /// </summary>
        /// <param name="opponents">List of opponent ratings</param>
        /// <param name="system"></param>
        // <param name="scores">List of match scores</param>
        //void update(IList<IPlayerRating> opponents, IList<double> scores);
        void update(IList<ISingleMatch> matches, float system = 1.2f);

        /// <summary>
        /// Converts rating to integer representation
        /// </summary>
        /// <returns>Integer rating value</returns>
        //int to_i();
    }

    /// <summary>
    /// </summary>
    /// <seealso cref="IMain"/>
    public interface IMainChallengeGeneratorBattleGenerator : IMain
    {
        int DecideWinnerEffectiveness(int move, int otype1, int otype2, int ability, int[] scores);

        double DecideWinnerScore(IList<IPokemon> party0, IList<IPokemon> party1, double rating);

        int DecideWinner(IList<IPokemon> party0, IList<IPokemon> party1, double rating0, double rating1);

        void RuledBattle(IRuledTeam team1, IRuledTeam team2, IPokemonChallengeRules rule);
    }
    /*
    /// <summary>
    /// Interface for battle simulation system
    /// </summary>
    public interface IBattleSimulator
    {
        /// <summary>
        /// Simulates a battle between two teams
        /// </summary>
        /// <param name="team1">First team</param>
        /// <param name="team2">Second team</param>
        /// <param name="rules">Battle rules to apply</param>
        /// <returns>Battle result (1.0 = team1 wins, 0.5 = draw, 0.0 = team2 wins)</returns>
        double simulateBattle(IRuledTeam team1, IRuledTeam team2, IPokemonChallengeRules rules);

        /// <summary>
        /// Runs multiple battle simulations for statistical accuracy
        /// </summary>
        /// <param name="team1">First team</param>
        /// <param name="team2">Second team</param>
        /// <param name="rules">Battle rules to apply</param>
        /// <param name="iterations">Number of simulations to run</param>
        /// <returns>Average result across all simulations</returns>
        double runMultipleBattles(IRuledTeam team1, IRuledTeam team2, IPokemonChallengeRules rules, int iterations);

        /// <summary>
        /// Estimates team strength based on Pokemon stats and movesets
        /// </summary>
        /// <param name="team">Team to evaluate</param>
        /// <returns>Estimated strength rating</returns>
        double estimateTeamStrength(IRuledTeam team);

        /// <summary>
        /// Calculates type effectiveness advantage between teams
        /// </summary>
        /// <param name="team1">First team</param>
        /// <param name="team2">Second team</param>
        /// <returns>Type advantage factor for team1</returns>
        double calculateTypeAdvantage(IRuledTeam team1, IRuledTeam team2);

        /// <summary>
        /// Simulates AI decision making for automated battles
        /// </summary>
        /// <param name="activePokemon">Currently active Pokemon</param>
        /// <param name="opponentPokemon">Opponent's active Pokemon</param>
        /// <param name="availableMoves">Available moves</param>
        /// <returns>Selected move index</returns>
        int simulateAIDecision(IPokemon activePokemon, IPokemon opponentPokemon, IList<string> availableMoves);
    }

    /// <summary>
    /// Interface for tournament and rating management
    /// </summary>
    public interface ITournamentManager
    {
        /// <summary>
        /// Creates a tournament bracket from multiple teams
        /// </summary>
        /// <param name="teams">List of teams to include</param>
        /// <param name="rules">Tournament rules</param>
        /// <returns>Tournament bracket structure</returns>
        ITournamentBracket createTournament(IList<IRuledTeam> teams, IPokemonChallengeRules rules);

        /// <summary>
        /// Runs a complete tournament simulation
        /// </summary>
        /// <param name="bracket">Tournament bracket</param>
        /// <param name="simulator">Battle simulator to use</param>
        /// <returns>Tournament results</returns>
        ITournamentResults runTournament(ITournamentBracket bracket, IBattleSimulator simulator);

        /// <summary>
        /// Updates all team ratings based on tournament results
        /// </summary>
        /// <param name="teams">Teams that participated</param>
        /// <param name="results">Tournament results</param>
        void updateRatingsFromTournament(IList<IRuledTeam> teams, ITournamentResults results);

        /// <summary>
        /// Generates seeding for tournament based on team ratings
        /// </summary>
        /// <param name="teams">Teams to seed</param>
        /// <returns>Seeded team list</returns>
        IList<IRuledTeam> generateSeeding(IList<IRuledTeam> teams);
    }

    /// <summary>
    /// Interface for tournament bracket structure
    /// </summary>
    public interface ITournamentBracket
    {
        /// <summary>
        /// Gets the teams in this bracket
        /// </summary>
        IList<IRuledTeam> teams { get; }

        /// <summary>
        /// Gets the tournament rules
        /// </summary>
        IPokemonChallengeRules rules { get; }

        /// <summary>
        /// Gets the bracket structure (rounds and matchups)
        /// </summary>
        IList<IList<ITournamentMatch>> rounds { get; }
    }

    /// <summary>
    /// Interface for tournament match information
    /// </summary>
    public interface ITournamentMatch
    {
        /// <summary>
        /// Gets the first team in this match
        /// </summary>
        IRuledTeam team1 { get; }

        /// <summary>
        /// Gets the second team in this match
        /// </summary>
        IRuledTeam team2 { get; }

        /// <summary>
        /// Gets the match result
        /// </summary>
        double result { get; set; }

        /// <summary>
        /// Gets the winning team
        /// </summary>
        IRuledTeam winner { get; }
    }

    /// <summary>
    /// Interface for tournament results
    /// </summary>
    public interface ITournamentResults
    {
        /// <summary>
        /// Gets the tournament winner
        /// </summary>
        IRuledTeam winner { get; }

        /// <summary>
        /// Gets the final standings
        /// </summary>
        IList<IRuledTeam> standings { get; }

        /// <summary>
        /// Gets all match results
        /// </summary>
        IList<ITournamentMatch> matches { get; }

        /// <summary>
        /// Gets statistics for the tournament
        /// </summary>
        ITournamentStatistics statistics { get; }
    }

    /// <summary>
    /// Interface for tournament statistics
    /// </summary>
    public interface ITournamentStatistics
    {
        /// <summary>
        /// Gets the total number of matches played
        /// </summary>
        int totalMatches { get; }

        /// <summary>
        /// Gets the average match score
        /// </summary>
        double averageMatchScore { get; }

        /// <summary>
        /// Gets upset count (lower rated team beating higher rated)
        /// </summary>
        int upsetCount { get; }

        /// <summary>
        /// Gets the most improved team rating-wise
        /// </summary>
        IRuledTeam mostImprovedTeam { get; }
    }
    */
}