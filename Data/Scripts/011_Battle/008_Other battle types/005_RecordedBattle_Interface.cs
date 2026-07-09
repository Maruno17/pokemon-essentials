using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for recorded battle functionality that captures battle data for replay.
    /// Records all player actions, random number generation, and battle state changes
    /// to enable accurate battle playback and analysis.
    /// </summary>
    public interface IRecordedBattleModule
    {
        /// <summary>Array of recorded random numbers generated during battle.</summary>
        int[] randomnums { get; }

        /// <summary>Array of recorded battle rounds with player actions.</summary>
        //object[][] rounds { get; }
        IList<KeyValuePair<int, int>?[]> rounds { get; }

        /// <summary>Battle command constants for recording actions.</summary>
        IBattleCommands Commands { get; }

        /// <summary>
        /// Initializes recorded battle with tracking arrays.
        /// Sets up storage for random numbers, rounds, switches, and properties.
        /// </summary>
        /// <param name="args">Standard battle initialization arguments</param>
        IRecordedBattleModule initialize(params object[] args);

        /// <summary>
        /// Gets the battle type identifier for recorded battles.
        /// Used to distinguish between different battle formats during playback.
        /// </summary>
        /// <returns>Battle type code (0=Battle Tower, 1=Palace, 2=Arena)</returns>
        int GetBattleType();

        /// <summary>
        /// Extracts trainer information for recording.
        /// Serializes trainer data including name, type, ID, and special properties
        /// for accurate reconstruction during playback.
        /// </summary>
        /// <param name="trainer">Trainer object or array to extract info from</param>
        /// <returns>Serializable trainer information array</returns>
        ITrainer GetTrainerInfo(ITrainer trainer);

        /// <summary>
        /// Starts recorded battle and captures initial state.
        /// Records all battle properties, party data, weather, rules, and settings
        /// needed for accurate playback reconstruction.
        /// </summary>
        void StartBattle();

        /// <summary>
        /// Dumps the complete recorded battle data.
        /// Serializes all recorded data including battle type, properties, rounds,
        /// random numbers, and switches for storage or transmission.
        /// </summary>
        /// <returns>Serialized battle record data</returns>
        byte[] DumpRecord();

        /// <summary>
        /// Records switching decisions during battle.
        /// Captures forced and voluntary switching actions for playback accuracy.
        /// </summary>
        /// <param name="idxBattler">Battler making switch decision</param>
        /// <param name="checkLaxOnly">Whether to check lax rules only</param>
        /// <param name="canCancel">Whether switching can be cancelled</param>
        /// <returns>Switch decision result</returns>
        bool SwitchInBetween(int idxBattler, bool checkLaxOnly = false, bool canCancel = false);

        /// <summary>
        /// Records move registration for playback.
        /// Captures move selection and registers it in the current round data.
        /// </summary>
        /// <param name="idxBattler">Battler registering move</param>
        /// <param name="idxMove">Move index being registered</param>
        /// <param name="showMessages">Whether to show messages</param>
        /// <returns>True if move was successfully registered</returns>
        bool RegisterMove(int idxBattler, int idxMove, bool showMessages = true);

        /// <summary>
        /// Records target selection for moves.
        /// Captures targeting decisions for multi-target or choice-target moves.
        /// </summary>
        /// <param name="idxBattler">Battler selecting target</param>
        /// <param name="idxTarget">Target index being selected</param>
        void RegisterTarget(int idxBattler, int idxTarget);

        /// <summary>
        /// Records run attempts during battle.
        /// Captures escape attempts and their outcomes for playback.
        /// </summary>
        /// <param name="idxBattler">Battler attempting to run</param>
        /// <param name="duringBattle">Whether run occurs during active battle</param>
        /// <returns>Run attempt result</returns>
        bool Run(int idxBattler, bool duringBattle = false);

        /// <summary>
        /// Records automatic move selection.
        /// Captures AI or forced move choices when player doesn't manually select.
        /// </summary>
        /// <param name="idxBattler">Battler having move auto-chosen</param>
        /// <param name="showMessages">Whether to show messages</param>
        /// <returns>True if move was successfully chosen</returns>
        bool AutoChooseMove(int idxBattler, bool showMessages = true);

        /// <summary>
        /// Records Pokemon switching registration.
        /// Captures switching decisions and target party member selection.
        /// </summary>
        /// <param name="idxBattler">Battler performing switch</param>
        /// <param name="idxParty">Party member index being switched to</param>
        /// <returns>True if switch was successfully registered</returns>
        bool RegisterSwitch(int idxBattler, int idxParty);

        /// <summary>
        /// Records item usage registration.
        /// Captures item selection, target, and context for accurate playback.
        /// </summary>
        /// <param name="idxBattler">Battler using item</param>
        /// <param name="item">Item being used</param>
        /// <param name="idxTarget">Target for item use</param>
        /// <param name="idxMove">Move context for item use</param>
        /// <returns>True if item was successfully registered</returns>
        bool RegisterItem(int idxBattler, int item, int? idxTarget = null, int? idxMove = null);

        /// <summary>
        /// Records command phase initialization.
        /// Sets up new round recording and increments round tracking.
        /// </summary>
        void CommandPhase();

        /// <summary>
        /// Prevents Pokemon storage during recorded battles.
        /// Recorded battles don't modify permanent trainer state.
        /// </summary>
        /// <param name="pkmn">Pokemon that would be stored (ignored)</param>
        void StorePokemon(IPokemon pkmn);

        /// <summary>
        /// Records random number generation for deterministic playback.
        /// Captures all RNG calls to ensure identical battle outcomes during replay.
        /// </summary>
        /// <param name="num">Maximum random value</param>
        /// <returns>Generated random number</returns>
        int Random(int num);
    }

    /// <summary>
    /// Interface for recorded battle playback functionality.
    /// Reconstructs and replays previously recorded battles using captured data
    /// to recreate the exact same battle sequence and outcome.
    /// </summary>
    public interface IRecordedBattlePlaybackModule
    {
        /// <summary>Battle command constants for playback interpretation.</summary>
        IBattleCommands Commands { get; }

        /// <summary>
        /// Initializes playback battle from recorded data.
        /// Reconstructs battle state from serialized battle record including
        /// parties, trainers, and all battle configuration data.
        /// </summary>
        /// <param name="scene">Battle scene for playback display</param>
        /// <param name="battle">Recorded battle data array</param>
        IRecordedBattlePlaybackModule initialize(IBattleScene scene, object[] battle);

        /// <summary>
        /// Starts playback battle with recorded properties.
        /// Restores all battle settings, weather, rules, and initial state
        /// from recorded data to match original battle conditions.
        /// </summary>
        void StartBattle();

        /// <summary>
        /// Replays recorded switching decisions.
        /// Returns predetermined switch results from recorded data
        /// instead of prompting for new decisions.
        /// </summary>
        /// <param name="_idxBattler">Battler index (unused in playback)</param>
        /// <param name="_checkLaxOnly">Lax rules check (unused in playback)</param>
        /// <param name="_canCancel">Cancel option (unused in playback)</param>
        /// <returns>Recorded switch decision</returns>
        bool SwitchInBetween(int _idxBattler, bool _checkLaxOnly = false, bool _canCancel = false);

        /// <summary>
        /// Replays recorded random number generation.
        /// Returns predetermined random values from recorded sequence
        /// to ensure identical battle outcomes.
        /// </summary>
        /// <param name="_num">Random range (unused in playback)</param>
        /// <returns>Recorded random number</returns>
        int Random(int _num);

        /// <summary>
        /// Displays messages without pausing during playback.
        /// Converts paused displays to immediate displays for smoother replay.
        /// </summary>
        /// <param name="str">Message string to display</param>
        void DisplayPaused(string str);

        /// <summary>
        /// Replays recorded command phase decisions.
        /// Executes predetermined player actions from recorded data
        /// including moves, items, switches, and run attempts.
        /// </summary>
        /// <param name="isPlayer">Whether processing player or AI actions</param>
        void CommandPhaseLoop(bool isPlayer);
    }

    /// <summary>
    /// Interface for battle command constants used in recording.
    /// Defines the numeric codes used to identify different types of battle actions
    /// in recorded battle data.
    /// </summary>
    public interface IBattleCommands
    {
        /// <summary>Fight command - using a move.</summary>
        int FIGHT { get; }

        /// <summary>Bag command - using an item.</summary>
        int BAG { get; }

        /// <summary>Pokemon command - switching Pokemon.</summary>
        int POKEMON { get; }

        /// <summary>Run command - attempting to flee.</summary>
        int RUN { get; }
    }

    /// <summary>
    /// Interface for basic recorded battle class.
    /// Implements standard battle recording with Battle Tower type identification.
    /// </summary>
    public interface IRecordedBattle : IBattle, IRecordedBattleModule
    {
        /// <summary>
        /// Gets battle type for standard recorded battles.
        /// </summary>
        /// <returns>Always returns 0 (Battle Tower)</returns>
        int GetBattleType();
    }

    /// <summary>
    /// Interface for recorded Battle Palace battles.
    /// Extends Palace battle functionality with recording capabilities.
    /// </summary>
    public interface IRecordedBattlePalaceBattle : IBattlePalaceBattle, IRecordedBattleModule
    {
        /// <summary>
        /// Gets battle type for recorded Palace battles.
        /// </summary>
        /// <returns>Always returns 1 (Battle Palace)</returns>
        int GetBattleType();
    }

    /// <summary>
    /// Interface for recorded Battle Arena battles.
    /// Extends Arena battle functionality with recording capabilities.
    /// </summary>
    public interface IRecordedBattleArenaBattle : IBattleArenaBattle, IRecordedBattleModule
    {
        /// <summary>
        /// Gets battle type for recorded Arena battles.
        /// </summary>
        /// <returns>Always returns 2 (Battle Arena)</returns>
        int GetBattleType();
    }

    /// <summary>
    /// Interface for standard battle playback.
    /// Replays recorded battles using standard battle rules.
    /// </summary>
    public interface IRecordedBattlePlayback : IBattle, IRecordedBattlePlaybackModule
    {
    }

    /// <summary>
    /// Interface for Battle Palace playback.
    /// Replays recorded Battle Palace battles with nature-based AI behavior.
    /// </summary>
    public interface IRecordedBattlePalacePlayback : IBattlePalaceBattle, IRecordedBattlePlaybackModule
    {
    }

    /// <summary>
    /// Interface for Battle Arena playback.
    /// Replays recorded Battle Arena battles with 3-category judgment system.
    /// </summary>
    public interface IRecordedBattleArenaPlayback : IBattleArenaBattle, IRecordedBattlePlaybackModule
    {
    }

    /// <summary>
    /// Interface for recorded battle helper utilities.
    /// Provides utility functions for extracting information from recorded battle data
    /// and reconstructing trainer objects for playback.
    /// </summary>
    public interface IRecordedBattlePlaybackHelper
    {
        /// <summary>
        /// Extracts opponent information from recorded battle data.
        /// Retrieves trainer data for display and battle configuration purposes.
        /// </summary>
        /// <param name="battle">Recorded battle data array</param>
        /// <returns>Opponent trainer information</returns>
        object GetOpponent(IRecordedBattleModule battle);

        /// <summary>
        /// Determines appropriate battle BGM from recorded data.
        /// Selects music based on opponent trainer type and battle format.
        /// </summary>
        /// <param name="battle">Recorded battle data array</param>
        /// <returns>Battle background music identifier</returns>
        IAudioBGM GetBattleBGM(IRecordedBattleModule battle);

        /// <summary>
        /// Reconstructs trainer objects from recorded data.
        /// Creates Player or NPCTrainer objects from serialized trainer information
        /// for accurate battle playback with correct trainer properties.
        /// </summary>
        /// <param name="trainer">Serialized trainer information array</param>
        /// <returns>Reconstructed trainer object array</returns>
        ITrainer CreateTrainerInfo(ITrainer trainer);
    }
    /*
    /// <summary>
    /// Interface for recorded battle data storage and retrieval.
    /// Manages the serialization and deserialization of battle records
    /// for storage in files or databases.
    /// </summary>
    public interface IRecordedBattleStorage
    {
        /// <summary>
        /// Saves a recorded battle to storage.
        /// Serializes and stores battle data with appropriate metadata.
        /// </summary>
        /// <param name="battleData">Serialized battle record</param>
        /// <param name="filename">Storage filename or identifier</param>
        /// <returns>True if save was successful</returns>
        bool saveBattleRecord(byte[] battleData, string filename);

        /// <summary>
        /// Loads a recorded battle from storage.
        /// Retrieves and deserializes battle data for playback.
        /// </summary>
        /// <param name="filename">Storage filename or identifier</param>
        /// <returns>Deserialized battle record data</returns>
        IRecordedBattlePlaybackModule loadBattleRecord(string filename);

        /// <summary>
        /// Lists available recorded battles.
        /// Provides metadata about stored battle records.
        /// </summary>
        /// <returns>Array of battle record metadata</returns>
        IBattleRecordMetadata[] listBattleRecords();

        /// <summary>
        /// Deletes a recorded battle from storage.
        /// Removes battle data and associated metadata.
        /// </summary>
        /// <param name="filename">Storage filename or identifier</param>
        /// <returns>True if deletion was successful</returns>
        bool deleteBattleRecord(string filename);
    }

    /// <summary>
    /// Interface for battle record metadata.
    /// Provides information about stored battle records without loading full data.
    /// </summary>
    public interface IBattleRecordMetadata
    {
        /// <summary>Battle record filename or identifier.</summary>
        string filename { get; }

        /// <summary>Battle type (Tower, Palace, Arena, etc.).</summary>
        int battleType { get; }

        /// <summary>Date and time the battle was recorded.</summary>
        System.DateTime recordedDate { get; }

        /// <summary>Player trainer name from the battle.</summary>
        string playerName { get; }

        /// <summary>Opponent trainer name from the battle.</summary>
        string opponentName { get; }

        /// <summary>Battle outcome (win, loss, draw).</summary>
        int outcome { get; }

        /// <summary>Number of turns the battle lasted.</summary>
        int turnCount { get; }

        /// <summary>Battle format description.</summary>
        string formatDescription { get; }
    }
    */
}