using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Provides utility functions for editor operations and data manipulation.
    /// Contains helper methods for move validation, file operations, animation management, and data selection.
    /// </summary>
    public interface IMainEditorUtilities : IMain
    {
        /// <summary>
        /// Gets all legal moves for a specific Pokémon species.
        /// Includes level-up moves, tutor moves, and egg moves from the baby form.
        /// </summary>
        /// <param name="species">The species to get legal moves for.</param>
        /// <returns>Array of move IDs that the species can legally learn.</returns>
        IList<object> GetLegalMoves(object species);

        /// <summary>
        /// Safely copies a file with user confirmation for overwrites.
        /// Compares file content to avoid unnecessary copies and prompts for overwrite confirmation.
        /// </summary>
        /// <param name="x">Source file path.</param>
        /// <param name="y">Destination file path.</param>
        /// <param name="z">Optional alternate destination path.</param>
        void SafeCopyFile(string x, string y, string z = null);

        /// <summary>
        /// Allocates a slot in the animations array for a new animation.
        /// Finds an empty or reusable slot in the battle animations data.
        /// </summary>
        /// <param name="animations">The animations array to allocate from.</param>
        /// <param name="name">Optional name for the new animation.</param>
        /// <returns>The index of the allocated animation slot.</returns>
        int AllocateAnimation(IList<object> animations, string name);

        /// <summary>
        /// Creates a hierarchical tree structure of all maps.
        /// Organizes maps by their parent-child relationships for display in editors.
        /// </summary>
        /// <returns>Array of map data organized in tree structure with [id, name, level].</returns>
        IList<object[]> MapTree();

        /// <summary>
        /// Displays a generic selection list from game data modules.
        /// Provides a standardized interface for selecting from various game data types.
        /// </summary>
        /// <param name="game_data">The game data module to select from (e.g., "Species", "Item").</param>
        /// <param name="default_value">The default selection to highlight.</param>
        /// <returns>The ID of the selected item, or null if cancelled.</returns>
        object ChooseFromGameDataList(object game_data, object default_value = null);

        /// <summary>
        /// Displays a list of all Pokémon species for selection.
        /// Shows base forms only, excludes alternate forms from the list.
        /// </summary>
        /// <param name="default_value">The species ID to initially select.</param>
        /// <returns>The selected species ID, or null if cancelled.</returns>
        object ChooseSpeciesList(object default_value = null);

        /// <summary>
        /// Displays a list of all Pokémon species including forms.
        /// Shows all species and their alternate forms as separate entries.
        /// </summary>
        /// <param name="default_value">The species/form to initially select.</param>
        /// <returns>The selected species/form, or null if cancelled.</returns>
        object ChooseSpeciesFormList(object default_value = null);

        /// <summary>
        /// Displays a list of all types for selection.
        /// Excludes pseudo-types that are used internally but not for actual typing.
        /// </summary>
        /// <param name="default_value">The type ID to initially select.</param>
        /// <returns>The selected type ID, or null if cancelled.</returns>
        object ChooseTypeList(object default_value = null);

        /// <summary>
        /// Displays a list of all items for selection.
        /// Includes all items registered in the game data.
        /// </summary>
        /// <param name="default_value">The item ID to initially select.</param>
        /// <returns>The selected item ID, or null if cancelled.</returns>
        object ChooseItemList(object default_value = null);

        /// <summary>
        /// Displays a list of all abilities for selection.
        /// Shows all abilities available in the game.
        /// </summary>
        /// <param name="default_value">The ability ID to initially select.</param>
        /// <returns>The selected ability ID, or null if cancelled.</returns>
        object ChooseAbilityList(object default_value = null);

        /// <summary>
        /// Displays a list of all moves for selection.
        /// Shows all moves registered in the game data.
        /// </summary>
        /// <param name="default_value">The move ID to initially select.</param>
        /// <returns>The selected move ID, or null if cancelled.</returns>
        object ChooseMoveList(object default_value = null);

        /// <summary>
        /// Displays a list of moves that a specific species can learn.
        /// Shows legal moves first, followed by all moves for broader selection.
        /// </summary>
        /// <param name="species">The species to filter moves for.</param>
        /// <param name="defaultMoveID">The move ID to initially select.</param>
        /// <returns>The selected move ID, or null if cancelled.</returns>
        object ChooseMoveListForSpecies(object species, object defaultMoveID = null);

        /// <summary>
        /// Displays a list of all Poké Ball items for selection.
        /// Filters items to show only those that are usable as Poké Balls.
        /// </summary>
        /// <param name="defaultMoveID">The ball item ID to initially select.</param>
        /// <returns>The selected ball item ID, or the default if cancelled.</returns>
        object ChooseBallList(object defaultMoveID = null);

        /// <summary>
        /// Enhanced command window interface with standard behavior.
        /// Provides basic selection functionality with customizable options.
        /// </summary>
        /// <param name="cmdwindow">The command window to use.</param>
        /// <param name="commands">Array of command strings to display.</param>
        /// <param name="cmdIfCancel">Command index to return if cancelled.</param>
        /// <param name="defaultindex">Initial selection index.</param>
        /// <param name="noresize">Whether to prevent window resizing.</param>
        /// <returns>The index of the selected command.</returns>
        int Commands2(object cmdwindow, IList<string> commands, int cmdIfCancel, int defaultindex = -1, bool noresize = false);

        /// <summary>
        /// Advanced command window interface with extended input handling.
        /// Supports additional input modes for complex editor operations.
        /// </summary>
        /// <param name="cmdwindow">The command window to use.</param>
        /// <param name="commands">Array of command strings to display.</param>
        /// <param name="cmdIfCancel">Command index to return if cancelled.</param>
        /// <param name="defaultindex">Initial selection index.</param>
        /// <param name="noresize">Whether to prevent window resizing.</param>
        /// <returns>Array containing [action, index] for the user's input.</returns>
        int[] Commands3(object cmdwindow, IList<string> commands, int cmdIfCancel, int defaultindex = -1, bool noresize = false);

        /// <summary>
        /// Generic list selection interface with sorting capabilities.
        /// Provides flexible selection from arrays of formatted data.
        /// </summary>
        /// <param name="commands">Array of command data [id, name, value].</param>
        /// <param name="default_value">The default selection.</param>
        /// <param name="cancelValue">Value to return if cancelled.</param>
        /// <param name="sortType">Sorting mode: 0=by ID, 1=alphabetical, -1=no sort toggle.</param>
        /// <returns>The selected value, or cancelValue if cancelled.</returns>
        object ChooseList(IList<object[]> commands, object default_value = null, object cancelValue = null, int sortType = 1);

        /// <summary>
        /// Command window with optional sorting toggle functionality.
        /// Allows users to toggle between different sorting modes during selection.
        /// </summary>
        /// <param name="cmdwindow">The command window to use.</param>
        /// <param name="commands">Array of command strings to display.</param>
        /// <param name="cmdIfCancel">Command index to return if cancelled.</param>
        /// <param name="defaultindex">Initial selection index.</param>
        /// <param name="sortable">Whether sorting toggle is enabled.</param>
        /// <returns>Array containing [action, index] for the user's input.</returns>
        int[] CommandsSortable(object cmdwindow, IList<string> commands, int cmdIfCancel, int defaultindex = -1, bool sortable = false);
    }
}