namespace PokemonEssentials
{
    /// <summary>
    /// Base interface for different battle types in challenges
    /// </summary>
    public interface IBattleType
    {
        /// <summary>
        /// Creates a battle instance between two trainers
        /// </summary>
        /// <param name="scene">Battle scene for visual representation</param>
        /// <param name="trainer1">First trainer (usually the player)</param>
        /// <param name="trainer2">Second trainer (opponent)</param>
        /// <returns>Battle instance</returns>
        IBattle pbCreateBattle(IBattleScene scene, ITrainer trainer1, ITrainer trainer2);
    }

    /// <summary>
    /// Interface for Battle Tower type battles with recording functionality
    /// </summary>
    public interface IBattleTypeBattleTower : IBattleType
    {
        /// <summary>
        /// Creates a recorded battle instance for Battle Tower
        /// </summary>
        /// <param name="scene">Battle scene for visual representation</param>
        /// <param name="trainer1">First trainer (usually the player)</param>
        /// <param name="trainer2">Second trainer (opponent)</param>
        /// <returns>Recorded battle instance</returns>
        new IRecordedBattle pbCreateBattle(IBattleScene scene, ITrainer trainer1, ITrainer trainer2);
    }

    /// <summary>
    /// Interface for Battle Palace type battles where Pokemon act autonomously
    /// </summary>
    public interface IBattleTypeBattlePalace : IBattleType
    {
        /// <summary>
        /// Creates a Battle Palace battle instance with autonomous Pokemon behavior
        /// </summary>
        /// <param name="scene">Battle scene for visual representation</param>
        /// <param name="trainer1">First trainer (usually the player)</param>
        /// <param name="trainer2">Second trainer (opponent)</param>
        /// <returns>Battle Palace battle instance</returns>
        new IBattlePalaceBattle pbCreateBattle(IBattleScene scene, ITrainer trainer1, ITrainer trainer2);
    }

    /// <summary>
    /// Interface for Battle Arena type battles with judgment system
    /// </summary>
    public interface IBattleTypeBattleArena : IBattleType
    {
        /// <summary>
        /// Creates a Battle Arena battle instance with judgment mechanics
        /// </summary>
        /// <param name="scene">Battle scene for visual representation</param>
        /// <param name="trainer1">First trainer (usually the player)</param>
        /// <param name="trainer2">Second trainer (opponent)</param>
        /// <returns>Battle Arena battle instance</returns>
        new IBattleArenaBattle pbCreateBattle(IBattleScene scene, ITrainer trainer1, ITrainer trainer2);
    }

    /// <summary>
    /// Interface for managing organized battles with challenge rules
    /// </summary>
    public interface IMainOrganizedBattleManager : IMain
    {
        /// <summary>
        /// Conducts an organized battle with specified rules and level adjustments
        /// </summary>
        /// <param name="opponent">Opponent trainer</param>
        /// <param name="challengedata">Challenge rules and configuration</param>
        /// <returns>True if player won, false otherwise</returns>
        bool pbOrganizedBattleEx(ITrainer opponent, IPokemonChallengeRules challengedata);
    //}

    /// <summary>
    /// Interface for battle recording and playback functionality
    /// </summary>
    //public interface IBattleRecordManager
    //{
        /// <summary>
        /// Records the last battle for later playback
        /// </summary>
        void pbRecordLastBattle();

        /// <summary>
        /// Plays back the last recorded battle
        /// </summary>
        void pbPlayLastBattle();

        /// <summary>
        /// Plays back a battle from battle data
        /// </summary>
        /// <param name="battledata">Battle data to playback</param>
        void pbPlayBattle(byte[] battledata);

        /// <summary>
        /// Debug method to choose and play a specific battle
        /// </summary>
        void pbDebugPlayBattle();

        /// <summary>
        /// Plays back a battle from a file
        /// </summary>
        /// <param name="filename">Path to battle file</param>
        void pbPlayBattleFromFile(string filename);
    }
    /*
    /// <summary>
    /// Interface for recorded battle instances
    /// </summary>
    public interface IRecordedBattle : IBattle
    {
        /// <summary>
        /// Dumps the battle record for later playback
        /// </summary>
        /// <returns>Battle record data</returns>
        byte[] pbDumpRecord();
    }

    /// <summary>
    /// Interface for Battle Palace specific battles
    /// </summary>
    public interface IBattlePalaceBattle : IRecordedBattle
    {
    }

    /// <summary>
    /// Interface for Battle Arena specific battles
    /// </summary>
    public interface IBattleArenaBattle : IRecordedBattle
    {
    }

    /// <summary>
    /// Interface for playback battle instances
    /// </summary>
    public interface IPlaybackBattle
    {
        /// <summary>
        /// Starts the playback battle
        /// </summary>
        /// <returns>Battle outcome</returns>
        int pbStartBattle();
    }

    /// <summary>
    /// Interface for Battle Palace playback battles
    /// </summary>
    public interface IBattlePalacePlaybackBattle : IPlaybackBattle
    {
    }

    /// <summary>
    /// Interface for Battle Arena playback battles
    /// </summary>
    public interface IBattleArenaPlaybackBattle : IPlaybackBattle
    {
    }
    */
}