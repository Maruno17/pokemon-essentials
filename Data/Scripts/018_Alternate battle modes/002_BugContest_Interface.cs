using System;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for managing Bug-Catching Contest state and game mechanics
    /// </summary>
    public interface IBugContestState
    {
        /// <summary>
        /// Gets or sets the number of competition balls remaining
        /// </summary>
        int ballcount { get; set; }

        /// <summary>
        /// Gets or sets the decision status for ending the contest
        /// </summary>
        int decision { get; set; }

        /// <summary>
        /// Gets or sets the last Pokemon caught in the contest
        /// </summary>
        IPokemon lastPokemon { get; set; }

        /// <summary>
        /// Gets or sets the contest timer start time
        /// </summary>
        double timer_start { get; set; }

        /// <summary>
        /// Initializes the Bug Contest state with default values
        /// </summary>
        IBugContestState initialize();

        /// <summary>
        /// Checks if a contest was held within the last 24 hours
        /// </summary>
        /// <returns>True if contest was recently held, false otherwise</returns>
        bool ContestHeld();

        /// <summary>
        /// Checks if the contest time has expired
        /// </summary>
        /// <returns>True if time has expired, false otherwise</returns>
        bool expired();

        /// <summary>
        /// Clears all contest state data
        /// </summary>
        void clear();

        /// <summary>
        /// Checks if a Bug Contest is currently in progress
        /// </summary>
        /// <returns>True if contest is active, false otherwise</returns>
        bool inProgress();

        /// <summary>
        /// Checks if the contest is in progress but not yet decided
        /// </summary>
        /// <returns>True if contest is undecided, false otherwise</returns>
        bool undecided();

        /// <summary>
        /// Checks if the contest has been decided or ended
        /// </summary>
        /// <returns>True if contest is decided, false otherwise</returns>
        bool decided();

        /// <summary>
        /// Sets the Pokemon chosen for the contest
        /// </summary>
        /// <param name="chosenpoke">Index of the chosen Pokemon</param>
        void SetPokemon(int chosenpoke);

        /// <summary>
        /// Sets the maps where the contest takes place
        /// </summary>
        /// <param name="maps">Variable number of map IDs or metadata flags</param>
        void SetContestMap(params object[] maps);

        /// <summary>
        /// Sets the reception maps for the contest
        /// </summary>
        /// <param name="maps">Variable number of map IDs or metadata flags</param>
        void SetReception(params object[] maps);

        /// <summary>
        /// Checks if a map is off-limits during the contest
        /// </summary>
        /// <param name="map">Map ID to check</param>
        /// <returns>True if map is off-limits, false otherwise</returns>
        bool OffLimits(int map);

        /// <summary>
        /// Sets the judging point location
        /// </summary>
        /// <param name="startMap">Map ID for judging</param>
        /// <param name="startX">X coordinate</param>
        /// <param name="startY">Y coordinate</param>
        /// <param name="dir">Direction (optional, defaults to 8)</param>
        void SetJudgingPoint(int startMap, int startX, int startY, int dir = 8);

        /// <summary>
        /// Performs the judging process and determines contest results
        /// </summary>
        void Judge();

        /// <summary>
        /// Gets information about a specific place in the contest results
        /// </summary>
        /// <param name="place">Place to get info for (0=1st, 1=2nd, 2=3rd)</param>
        void GetPlaceInfo(int place);

        /// <summary>
        /// Clears contest data if the contest has ended
        /// </summary>
        void ClearIfEnded();

        /// <summary>
        /// Starts the judging process and transfers player to judging location
        /// </summary>
        void StartJudging();

        /// <summary>
        /// Checks if a given index is a contestant
        /// </summary>
        /// <param name="i">Index to check</param>
        /// <returns>True if index is a contestant, false otherwise</returns>
        bool IsContestant(int i);

        /// <summary>
        /// Starts a new Bug Contest with the specified number of balls
        /// </summary>
        /// <param name="ballcount">Number of competition balls to start with</param>
        void Start(int ballcount);

        /// <summary>
        /// Gets the player's place in the contest (0=1st, 1=2nd, 2=3rd, 3=not placed)
        /// </summary>
        /// <returns>Contest placement</returns>
        int place();

        /// <summary>
        /// Ends the current Bug Contest
        /// </summary>
        /// <param name="interrupted">Whether the contest was interrupted (optional, defaults to false)</param>
        void End(bool interrupted = false);
    }

    /// <summary>
    /// Interface for timer display functionality during Bug Contest
    /// </summary>
    public interface ITimerDisplay : IHaveUpdate, IDisposable
    {
        /// <summary>
        /// Gets or sets the contest start time
        /// </summary>
        double start_time { get; set; }

        /// <summary>
        /// Initializes the timer display
        /// </summary>
        /// <param name="start_time">Contest start time</param>
        /// <param name="max_time">Maximum contest duration</param>
        ITimerDisplay initialize(double start_time, int max_time);

        /// <summary>
        /// Disposes of the timer display resources
        /// </summary>
        void dispose();

        /// <summary>
        /// Checks if the timer display has been disposed
        /// </summary>
        /// <returns>True if disposed, false otherwise</returns>
        bool disposed();

        /// <summary>
        /// Updates the timer display with current time remaining
        /// </summary>
        void update();
    }

    /// <summary>
    /// Interface for extended pause menu functionality in Bug Contest
    /// </summary>
    public interface IPokemonPauseMenuBugContestExtensions
    {
        /// <summary>
        /// Shows Bug Contest specific information (caught Pokemon and balls remaining)
        /// </summary>
        void ShowInfo();
    }
}