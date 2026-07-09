using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Provides the main debug menu system for Pokemon Essentials development.
    /// Contains the command management system and primary debug menu interface for accessing all debug functions.
    /// </summary>
    public interface IDebugMenus
    {
        /// <summary>
        /// Displays and manages the main debug menu interface.
        /// Provides the primary entry point for all debug functionality in Pokemon Essentials.
        /// </summary>
        /// <param name="show_all">Whether to show all debug options or only essential ones.</param>
        void DebugMenu(bool show_all = true);
    }

    /// <summary>
    /// Manages a hierarchical list of debug commands and submenus.
    /// Provides organization and navigation for the extensive debug functionality.
    /// </summary>
    public interface ICommandMenuList
    {
        /// <summary>
        /// The currently active menu level.
        /// </summary>
        object currentList { get; set; }

        /// <summary>
        /// Initializes the command menu list.
        /// </summary>
        void initialize();

        /// <summary>
        /// Adds a command to the menu system.
        /// </summary>
        /// <param name="option">The command option identifier.</param>
        /// <param name="hash">Hash containing command properties.</param>
        /// <param name="name">Optional display name for the command.</param>
        /// <param name="description">Optional description for the command.</param>
        void add(object option, IDictionary<string, object> hash, string name = null, string description = null);

        /// <summary>
        /// Gets the list of commands for the current menu level.
        /// </summary>
        /// <returns>Array of command names for display.</returns>
        IList<string> list();

        /// <summary>
        /// Gets the command object at the specified index.
        /// </summary>
        /// <param name="index">Index of the command to retrieve.</param>
        /// <returns>The command object, or null if not found.</returns>
        object getCommand(int index);

        /// <summary>
        /// Gets the description for the command at the specified index.
        /// </summary>
        /// <param name="index">Index of the command to get description for.</param>
        /// <returns>Description string for the command.</returns>
        string getDesc(int index);

        /// <summary>
        /// Checks if the specified command has a submenu.
        /// </summary>
        /// <param name="check_cmd">Command to check for submenu.</param>
        /// <returns>True if the command has a submenu, false otherwise.</returns>
        bool hasSubMenu(object check_cmd);

        /// <summary>
        /// Gets the parent menu and index for navigation.
        /// </summary>
        /// <returns>Array containing parent menu and index, or null if at root.</returns>
        object[] getParent();
    }
}