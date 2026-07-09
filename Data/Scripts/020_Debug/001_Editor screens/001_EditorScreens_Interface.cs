using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Provides comprehensive editing interfaces for various game data types including wild encounters,
    /// trainer types, individual trainers, metadata, items, Pokémon species, regional dexes, and battle animations.
    /// These editor screens serve as the primary development tools for creating and modifying game content.
    /// </summary>
    public interface IMainEditorScreens : IMain
    {
        /// <summary>
        /// Opens the wild encounters editor interface.
        /// Lists all defined encounter sets and provides options to add, edit, copy, or delete them.
        /// </summary>
        void EncountersEditor();

        /// <summary>
        /// Edits encounter data for a specific map and version combination.
        /// Allows modification of map ID, version number, and all encounter types for the specified encounter set.
        /// </summary>
        /// <param name="enc_data">The encounter data instance to edit.</param>
        void EncounterMapVersionEditor(object enc_data);

        /// <summary>
        /// Edits the step chance and encounter slots for a specific encounter type.
        /// Provides detailed editing of individual encounter slots within an encounter type.
        /// </summary>
        /// <param name="enc_data">The encounter data instance containing the encounter type.</param>
        /// <param name="enc_type">The specific encounter type to edit.</param>
        void EncounterTypeEditor(object enc_data, object enc_type);

        /// <summary>
        /// Opens the trainer type editor interface.
        /// Allows viewing, editing, and managing all trainer types in the game.
        /// </summary>
        void TrainerTypeEditor();

        /// <summary>
        /// Creates a new trainer type with the specified default name.
        /// Guides the user through setting up a new trainer type including name, gender, and base money values.
        /// </summary>
        /// <param name="default_name">Optional default name for the new trainer type.</param>
        /// <returns>Symbol representing the ID of the newly created trainer type, or null if creation failed.</returns>
        object TrainerTypeEditorNew(string default_name);

        /// <summary>
        /// Opens the individual trainer battle editor interface.
        /// Allows editing of specific trainer battles including their Pokémon teams and battle items.
        /// </summary>
        void TrainerBattleEditor();

        /// <summary>
        /// Opens the metadata editor interface.
        /// Provides access to global metadata and player character metadata editing.
        /// </summary>
        void MetadataScreen();

        /// <summary>
        /// Edits global game metadata settings.
        /// Allows modification of core game configuration parameters.
        /// </summary>
        void EditMetadata();

        /// <summary>
        /// Edits metadata for a specific player character.
        /// Manages player-specific configuration data and settings.
        /// </summary>
        /// <param name="player_id">The ID of the player character to edit metadata for.</param>
        void EditPlayerMetadata(int player_id = 1);

        /// <summary>
        /// Opens the map metadata editor interface.
        /// Allows selection and editing of metadata for specific maps.
        /// </summary>
        /// <param name="map_id">The initial map ID to display in the editor.</param>
        void MapMetadataScreen(int map_id = 0);

        /// <summary>
        /// Edits metadata for a specific map.
        /// Provides comprehensive editing of map-specific configuration and properties.
        /// </summary>
        /// <param name="map_id">The ID of the map to edit metadata for.</param>
        void EditMapMetadata(int map_id);

        /// <summary>
        /// Opens the item editor interface.
        /// Allows viewing, editing, creating, and deleting items in the game.
        /// </summary>
        void ItemEditor();

        /// <summary>
        /// Creates a new item with the specified default name.
        /// Guides the user through the item creation process including naming, categorization, and pricing.
        /// </summary>
        /// <param name="default_name">Optional default name for the new item.</param>
        void ItemEditorNew(string default_name);

        /// <summary>
        /// Opens the Pokémon species editor interface.
        /// Provides comprehensive editing of species data including stats, abilities, and other properties.
        /// </summary>
        void PokemonEditor();

        /// <summary>
        /// Edits a specific regional Pokédex.
        /// Allows rearrangement, addition, and removal of species entries within a regional dex.
        /// </summary>
        /// <param name="dex">The regional dex data to edit.</param>
        /// <returns>The modified regional dex data.</returns>
        IList<object> RegionalDexEditor(IList<object> dex);

        /// <summary>
        /// Opens the main regional dexes editor interface.
        /// Manages all regional dexes including creation, editing, and organization.
        /// </summary>
        void RegionalDexEditorMain();

        /// <summary>
        /// Recursively appends evolution family members to an array for regional dex organization.
        /// Used internally for organizing species by evolutionary relationships.
        /// </summary>
        /// <param name="species">The species to process.</param>
        /// <param name="array">The array to append to.</param>
        /// <param name="seenarray">Array tracking which species have been processed.</param>
        void AppendEvoToFamilyArray(object species, IList<object> array, IList<object> seenarray);

        /// <summary>
        /// Gets all evolution families in the game.
        /// Returns grouped arrays of species organized by evolutionary relationships.
        /// </summary>
        /// <returns>Array of evolution families, each containing related species.</returns>
        IList<IList<object>> GetEvoFamilies();

        /// <summary>
        /// Converts evolution family data into human-readable string representations.
        /// Used for displaying evolution families in editor interfaces.
        /// </summary>
        /// <returns>Array of formatted strings representing evolution families.</returns>
        IList<string> EvoFamiliesToStrings();

        /// <summary>
        /// Opens the battle animations organizer interface.
        /// Allows rearrangement, deletion, and insertion of battle animation entries.
        /// </summary>
        void AnimationsOrganiser();
    }

    /// <summary>
    /// Provides property editing functionality for trainer battle data.
    /// Handles the complex data structure of trainer battles including Pokémon teams and items.
    /// </summary>
    public interface ITrainerBattleProperty
    {
        /// <summary>
        /// Maximum number of items a trainer can carry in battle.
        /// </summary>
        int NUM_ITEMS { get; }

        /// <summary>
        /// Sets trainer battle properties through an interactive property editor.
        /// Provides a comprehensive interface for editing all aspects of a trainer battle.
        /// </summary>
        /// <param name="settingname">Name of the setting being configured.</param>
        /// <param name="oldsetting">Current trainer battle data to edit.</param>
        /// <returns>Modified trainer battle data, or null if editing was cancelled.</returns>
        object set(string settingname, object oldsetting);

        /// <summary>
        /// Formats trainer battle data for display in editor lists.
        /// Provides a readable representation of trainer battle information.
        /// </summary>
        /// <param name="value">The trainer battle data to format.</param>
        /// <returns>Formatted string representation of the trainer battle data.</returns>
        string format(object value);
    }

    /// <summary>
    /// Provides property editing functionality for trainer Pokémon data.
    /// Handles the complex data structure of individual Pokémon owned by trainers.
    /// </summary>
    public interface ITrainerPokemonProperty
    {
        /// <summary>
        /// Sets trainer Pokémon properties through an interactive property editor.
        /// Provides comprehensive editing of all Pokémon attributes including stats, moves, and items.
        /// </summary>
        /// <param name="settingname">Name of the setting being configured.</param>
        /// <param name="initsetting">Initial Pokémon data to edit.</param>
        /// <returns>Modified Pokémon data, or null if editing was cancelled.</returns>
        object set(string settingname, object initsetting);

        /// <summary>
        /// Formats trainer Pokémon data for display in editor lists.
        /// Provides a concise representation showing species and level information.
        /// </summary>
        /// <param name="value">The trainer Pokémon data to format.</param>
        /// <returns>Formatted string representation of the Pokémon data.</returns>
        string format(object value);
    }
}