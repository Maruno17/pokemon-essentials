using System;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for battle peer which manages Pokemon storage and form changes during battle.
    /// Handles Pokemon storage operations, box management, and form changes that occur
    /// when Pokemon enter or leave battle situations.
    /// </summary>
    public interface IPeer
    {
        /// <summary>
        /// Stores a Pokemon in the player's party or PC storage system.
        /// If the party is full, the Pokemon is sent to PC storage with optional healing.
        /// </summary>
        /// <param name="player">The player who caught the Pokemon</param>
        /// <param name="pkmn">The Pokemon to store</param>
        /// <returns>Box number where Pokemon was stored, or -1 if added to party</returns>
        int StorePokemon(IPlayer player, IPokemon pkmn);

        /// <summary>
        /// Gets the storage creator's name if the player has seen the storage creator.
        /// Used for displaying PC storage system creator information.
        /// </summary>
        /// <returns>Storage creator name if seen, null otherwise</returns>
        string GetStorageCreatorName();

        /// <summary>
        /// Gets the current active box number in the PC storage system.
        /// Used for determining which box new Pokemon will be stored in.
        /// </summary>
        /// <returns>Current box number</returns>
        int CurrentBox();

        /// <summary>
        /// Gets the name of a specific storage box.
        /// Returns empty string for invalid box numbers.
        /// </summary>
        /// <param name="box">Box number to get name for</param>
        /// <returns>Name of the box, or empty string if invalid</returns>
        string BoxName(int box);

        /// <summary>
        /// Handles Pokemon form changes when starting a battle.
        /// Called before the battle begins to set appropriate forms.
        /// </summary>
        /// <param name="battle">The battle being started</param>
        /// <param name="pkmn">The Pokemon entering battle</param>
        /// <param name="wild">Whether this is a wild Pokemon battle</param>
        void OnStartingBattle(IBattle battle, IPokemon pkmn, bool wild = false);

        /// <summary>
        /// Handles Pokemon form changes and battler synchronization when entering battle.
        /// Called when a Pokemon is sent out to battle to ensure proper form display.
        /// </summary>
        /// <param name="battle">The active battle</param>
        /// <param name="battler">The battler representation of the Pokemon</param>
        /// <param name="pkmn">The Pokemon data</param>
        /// <param name="wild">Whether this is a wild Pokemon battle</param>
        void OnEnteringBattle(IBattle battle, IBattler battler, IPokemon pkmn, bool wild = false);

        /// <summary>
        /// Handles Pokemon form changes and cleanup when leaving battle.
        /// Called when a Pokemon is recalled, faints, or when battle ends.
        /// Ensures HP doesn't exceed maximum and applies appropriate form changes.
        /// </summary>
        /// <param name="battle">The active battle</param>
        /// <param name="pkmn">The Pokemon leaving battle</param>
        /// <param name="usedInBattle">Whether the Pokemon participated in battle</param>
        /// <param name="endBattle">Whether the entire battle is ending</param>
        void OnLeavingBattle(IBattle battle, IPokemon pkmn, bool usedInBattle, bool endBattle = false);
    }

    /// <summary>
    /// Interface for null peer implementation that provides minimal functionality.
    /// Used as a placeholder when full peer functionality is not needed.
    /// Provides basic storage operations without advanced features like healing or form changes.
    /// </summary>
    public interface INullPeer
    {
        /// <summary>
        /// Handles Pokemon entering battle with no special processing.
        /// Minimal implementation that performs no form changes or special handling.
        /// </summary>
        /// <param name="battle">The active battle</param>
        /// <param name="battler">The battler representation</param>
        /// <param name="pkmn">The Pokemon data</param>
        /// <param name="wild">Whether this is a wild Pokemon battle</param>
        void OnEnteringBattle(IBattle battle, IBattler battler, IPokemon pkmn, bool wild = false);

        /// <summary>
        /// Handles Pokemon leaving battle with no special processing.
        /// Minimal implementation that performs no cleanup or form changes.
        /// </summary>
        /// <param name="battle">The active battle</param>
        /// <param name="pkmn">The Pokemon leaving battle</param>
        /// <param name="usedInBattle">Whether the Pokemon participated in battle</param>
        /// <param name="endBattle">Whether the entire battle is ending</param>
        void OnLeavingBattle(IBattle battle, IPokemon pkmn, bool usedInBattle, bool endBattle = false);

        /// <summary>
        /// Basic Pokemon storage that only adds to party if not full.
        /// Does not handle PC storage or healing like the full peer implementation.
        /// </summary>
        /// <param name="player">The player who caught the Pokemon</param>
        /// <param name="pkmn">The Pokemon to store</param>
        /// <returns>Always returns -1 indicating party storage</returns>
        int StorePokemon(IPlayer player, IPokemon pkmn);

        /// <summary>
        /// Returns null for storage creator name.
        /// Minimal implementation with no storage creator tracking.
        /// </summary>
        /// <returns>Always returns null</returns>
        string GetStorageCreatorName();

        /// <summary>
        /// Returns invalid box number.
        /// Minimal implementation with no box management.
        /// </summary>
        /// <returns>Always returns -1</returns>
        int CurrentBox();

        /// <summary>
        /// Returns empty string for any box name request.
        /// Minimal implementation with no box naming.
        /// </summary>
        /// <param name="box">Box number (ignored)</param>
        /// <returns>Always returns empty string</returns>
        string BoxName(int box);
    }
}