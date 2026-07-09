using System;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for game-specific save value registrations.
    /// Defines the standard save values used by Pokemon Essentials.
    /// </summary>
    public interface IGameSaveValues
    {
        /// <summary>
        /// Registers the player save value.
        /// Contains the player character data including name, trainer type, and progress.
        /// </summary>
        void RegisterPlayer();

        /// <summary>
        /// Registers the game system save value.
        /// Contains system-level game state like timers, frame count, and system settings.
        /// Loaded during bootup and reset on new game.
        /// </summary>
        void RegisterGameSystem();

        /// <summary>
        /// Registers the Pokemon system save value.
        /// Contains Pokemon-specific system settings and configurations.
        /// Loaded during bootup.
        /// </summary>
        void RegisterPokemonSystem();

        /// <summary>
        /// Registers the game switches save value.
        /// Contains all game switches (boolean flags) used for event scripting.
        /// </summary>
        void RegisterSwitches();

        /// <summary>
        /// Registers the game variables save value.
        /// Contains all game variables (numeric values) used for event scripting.
        /// </summary>
        void RegisterVariables();

        /// <summary>
        /// Registers the self switches save value.
        /// Contains event-specific switches that are tied to individual map events.
        /// </summary>
        void RegisterSelfSwitches();

        /// <summary>
        /// Registers the game screen save value.
        /// Contains screen effect states like weather, tinting, and transitions.
        /// </summary>
        void RegisterGameScreen();

        /// <summary>
        /// Registers the game map save value.
        /// Contains the current map state and player position information.
        /// </summary>
        void RegisterGameMap();

        /// <summary>
        /// Registers the game temp save value.
        /// Contains temporary game state that persists during gameplay sessions.
        /// </summary>
        void RegisterGameTemp();

        /// <summary>
        /// Registers the Pokedex save value.
        /// Contains all Pokedex data including seen/owned Pokemon and form data.
        /// </summary>
        void RegisterPokedex();

        /// <summary>
        /// Registers the bag save value.
        /// Contains the player's item inventory including items, key items, and quantities.
        /// </summary>
        void RegisterBag();

        /// <summary>
        /// Registers the PC storage save value.
        /// Contains all Pokemon stored in the PC box system.
        /// </summary>
        void RegisterPCStorage();

        /// <summary>
        /// Registers the storage creator save value.
        /// Contains information about who created the PC storage system.
        /// </summary>
        void RegisterStorageCreator();

        /// <summary>
        /// Registers the global metadata save value.
        /// Contains metadata about maps, events, and other global game data.
        /// </summary>
        void RegisterGlobalMetadata();

        /// <summary>
        /// Registers the map factory save value.
        /// Contains factory for creating and managing map instances.
        /// </summary>
        void RegisterMapFactory();

        /// <summary>
        /// Registers the stats save value.
        /// Contains player statistics like play time, steps taken, battles won, etc.
        /// </summary>
        void RegisterStats();

        /// <summary>
        /// Registers all standard game save values.
        /// Calls all individual registration methods to set up the complete save system.
        /// </summary>
        void RegisterAllSaveValues();

        void RegisterGameSaveValues();
    }

    /// <summary>
    /// Interface for save value validation and defaults.
    /// Provides validation and default value creation for game save values.
    /// </summary>
    public interface IGameSaveValueDefaults
    {
        /// <summary>
        /// Creates a new default player instance.
        /// </summary>
        /// <returns>A new player with default name and trainer type.</returns>
        IPlayer CreateDefaultPlayer();

        /// <summary>
        /// Creates a new default game system instance.
        /// </summary>
        /// <returns>A new game system with default settings.</returns>
        IGameSystem CreateDefaultGameSystem();

        /// <summary>
        /// Creates a new default Pokemon system instance.
        /// </summary>
        /// <returns>A new Pokemon system with default configurations.</returns>
        IGameSystemOption CreateDefaultPokemonSystem();

        /// <summary>
        /// Creates a new default switches collection.
        /// </summary>
        /// <returns>A new game switches collection.</returns>
        IGameSwitches CreateDefaultSwitches();

        /// <summary>
        /// Creates a new default variables collection.
        /// </summary>
        /// <returns>A new game variables collection.</returns>
        IGameVariable CreateDefaultVariables();

        /// <summary>
        /// Creates a new default self switches collection.
        /// </summary>
        /// <returns>A new self switches collection.</returns>
        IGameSelfSwitches CreateDefaultSelfSwitches();

        /// <summary>
        /// Creates a new default game screen instance.
        /// </summary>
        /// <returns>A new game screen with default settings.</returns>
        IGameScreen CreateDefaultGameScreen();

        /// <summary>
        /// Creates a new default Pokedex instance.
        /// </summary>
        /// <returns>A new Pokedex with no entries.</returns>
        IPokedex CreateDefaultPokedex();

        /// <summary>
        /// Creates a new default bag instance.
        /// </summary>
        /// <returns>A new bag with starting items.</returns>
        IGameBag CreateDefaultBag();

        /// <summary>
        /// Creates a new default PC storage instance.
        /// </summary>
        /// <returns>A new PC storage system.</returns>
        IGameStorage CreateDefaultPCStorage(); //IPCStorage

        /// <summary>
        /// Creates a new default global metadata instance.
        /// </summary>
        /// <returns>A new global metadata with default settings.</returns>
        IGlobalMetadata CreateDefaultGlobalMetadata();

        /// <summary>
        /// Creates a new default stats instance.
        /// </summary>
        /// <returns>A new stats tracker with zero values.</returns>
        IGameStats CreateDefaultStats();
    }
}