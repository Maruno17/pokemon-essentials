using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the main Pokédex window that displays the species list.
    /// Shows Pokemon entries with numbers, names, and seen/owned status indicators.
    /// </summary>
    public interface IWindow_Pokedex : IWindow_DrawableCommand, IHaveUpdate, IHaveRefresh, IDisposable
    {
        /// <summary>
        /// Initializes the Pokédex window with position and size parameters.
        /// Sets up graphics for selection cursor and ownership status icons.
        /// </summary>
        /// <param name="x">X coordinate of the window.</param>
        /// <param name="y">Y coordinate of the window.</param>
        /// <param name="width">Width of the window.</param>
        /// <param name="height">Height of the window.</param>
        /// <param name="viewport">Viewport to display the window in.</param>
        IWindow_Pokedex initialize(int x, int y, int width, int height, IViewport viewport);

        /// <summary>
        /// Sets the command list for the Pokédex entries.
        /// Updates the window display with new Pokemon data and refreshes the list.
        /// </summary>
        /// <value>List of Pokemon command data including species and numbers.</value>
        IList<string> commands { get; set; }

        /// <summary>
        /// Disposes of bitmap resources used by the window.
        /// Cleans up ownership and seen status icon bitmaps.
        /// </summary>
        void dispose();

        /// <summary>
        /// Gets the species of the currently selected Pokemon entry.
        /// Returns the species identifier for the highlighted list item.
        /// </summary>
        /// <returns>Species identifier of selected Pokemon, or 0 if none selected.</returns>
        int species { get; }

        /// <summary>
        /// Gets the total number of items in the Pokédex list.
        /// Returns the count of Pokemon entries available for display.
        /// </summary>
        /// <returns>Total number of Pokemon entries in the list.</returns>
        int itemCount { get; }

        /// <summary>
        /// Draws a single Pokemon entry in the list with number, name, and status icon.
        /// Renders the entry based on whether the Pokemon has been seen or owned.
        /// </summary>
        /// <param name="index">Index of the entry to draw.</param>
        /// <param name="_count">Total count of entries (unused).</param>
        /// <param name="rect">Rectangle area to draw the entry within.</param>
        void drawItem(int index, int _count, IRect rect);

        /// <summary>
        /// Refreshes the entire Pokédex window display.
        /// Redraws all visible entries and updates the selection cursor.
        /// </summary>
        void refresh();

        /// <summary>
        /// Updates the window state and hides scroll arrows.
        /// Called each frame to update window appearance and behavior.
        /// </summary>
        void update();
    }

    /// <summary>
    /// Interface for the main Pokédex scene that manages the species list display.
    /// Handles navigation, search functionality, and transitions to detailed views.
    /// </summary>
    public interface IScenePokemonPokedex : IScene, IUIScene, IHaveUpdate, IHaveRefresh
    {
        /// <summary>
        /// Updates all sprites in the main Pokédex scene.
        /// Called during the main loop to refresh sprite states and animations.
        /// </summary>
        void Update();

        /// <summary>
        /// Starts the main Pokédex scene for the specified regional dex.
        /// Initializes background, Pokemon list, info displays, and navigation controls.
        /// </summary>
        /// <param name="dex_index">The index of the regional Pokédex to display.</param>
        void StartScene(int dex_index = -1);

        /// <summary>
        /// Handles the main scene interaction loop for Pokemon selection.
        /// Processes navigation, search, and entry selection with appropriate transitions.
        /// </summary>
        /// <returns>Result code indicating the action taken or selection made.</returns>
        int Scene();

        /// <summary>
        /// Ends the main Pokédex scene and cleans up resources.
        /// Handles fade out transition and disposes of sprites and viewports.
        /// </summary>
        void EndScene();

        /// <summary>
        /// Refreshes the Pokemon list display based on current filtering criteria.
        /// Updates the list window with filtered entries and resets selection.
        /// </summary>
        void Refresh();

        /// <summary>
        /// Updates the information display for the currently selected Pokemon.
        /// Shows species details, description, and other relevant information.
        /// </summary>
        void UpdateInfo();

        /// <summary>
        /// Handles search functionality for finding specific Pokemon.
        /// Provides text input interface for filtering the Pokemon list.
        /// </summary>
        void Search();

        /// <summary>
        /// Sorts the Pokemon list according to the specified criteria.
        /// Reorders entries by number, name, type, or other sorting options.
        /// </summary>
        /// <param name="sort_type">The type of sorting to apply to the list.</param>
        void Sort(int sort_type);
    }

    /// <summary>
    /// Interface for the main Pokédex screen that orchestrates the viewing experience.
    /// Coordinates between scenes and manages overall Pokédex navigation flow.
    /// </summary>
    public interface IScreenPokemonPokedex : IScreen
    {
        /// <summary>
        /// Initializes the main Pokédex screen with the specified scene.
        /// Sets up the scene instance for managing the Pokédex interface.
        /// </summary>
        /// <param name="scene">The main Pokédex scene to use.</param>
        IScreenPokemonPokedex initialize(IScenePokemonPokedex scene);

        /// <summary>
        /// Starts the main Pokédex screen and handles navigation flow.
        /// Manages the complete Pokédex viewing experience with scene transitions.
        /// </summary>
        void StartScreen();
    }
}