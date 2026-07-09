using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the Pokédex regional dexes list window.
    /// Displays available Pokédex regions with seen/owned counts and completion indicators.
    /// </summary>
    /// <remarks>
    /// Pokédex Regional Dexes list menu screen
    /// * For choosing which region list to view. Only appears when there is more
    ///   than one accessible region list to choose from, and if
    ///   <see cref="ISettings.USE_CURRENT_REGION_DEX"/> is false.
    /// </remarks>
    public interface IWindow_DexesList : IWindow_CommandPokemon
    {
        /// <summary>
        /// Initializes the dexes list window with commands and statistics.
        /// Sets up the window appearance and selection arrow graphics.
        /// </summary>
        /// <param name="commands">List of regional Pokédex names to display.</param>
        /// <param name="commands2">List of statistics arrays for each region.</param>
        /// <param name="width">Width of the window.</param>
        IWindow_DexesList initialize(IList<string> commands, IList<int[]> commands2, int width);

        /// <summary>
        /// Draws a single item in the dexes list with seen/owned counts and completion icons.
        /// Renders the region name, statistics, and visual indicators for completion status.
        /// </summary>
        /// <param name="index">The index of the item to draw.</param>
        /// <param name="count">The total number of items.</param>
        /// <param name="rect">The rectangle area to draw within.</param>
        void drawItem(int index, int count, IRect rect);
    }

    /// <summary>
    /// Interface for the Pokédex menu scene that handles region selection.
    /// Manages the display and interaction for choosing which regional Pokédex to view.
    /// </summary>
    public interface IScenePokemonPokedexMenu : IScene, IUIScene, IHaveUpdate
    {
        /// <summary>
        /// Updates all sprites in the Pokédex menu scene.
        /// Called during the main loop to refresh sprite states and animations.
        /// </summary>
        void Update();

        /// <summary>
        /// Starts the Pokédex menu scene with available regions and their statistics.
        /// Initializes background, headings, and command window with regional data.
        /// </summary>
        /// <param name="commands">List of regional Pokédex names to display.</param>
        /// <param name="commands2">List of statistics arrays for each region.</param>
        void StartScene(IList<string> commands, IList<int[]> commands2);

        /// <summary>
        /// Handles the main scene interaction loop for region selection.
        /// Processes user input and returns the selected region index.
        /// </summary>
        /// <returns>Index of selected region, or -1 if cancelled.</returns>
        int Scene();

        /// <summary>
        /// Ends the Pokédex menu scene and cleans up resources.
        /// Handles fade out transition and disposes of sprites and viewports.
        /// </summary>
        void EndScene();
    }

    /// <summary>
    /// Interface for the Pokédex menu screen that orchestrates region selection.
    /// Coordinates between the scene and manages navigation to specific regional Pokédexes.
    /// </summary>
    public interface IPokemonPokedexMenuScreen
    {
        /// <summary>
        /// Initializes the Pokédex menu screen with the specified scene.
        /// Sets up the scene instance for managing the menu interface.
        /// </summary>
        /// <param name="scene">The Pokédex menu scene to use.</param>
        IPokemonPokedexMenuScreen initialize(IScenePokemonPokedexMenu scene);

        /// <summary>
        /// Starts the Pokédex menu screen and handles region selection flow.
        /// Builds the list of accessible regions and manages navigation to selected Pokédex.
        /// </summary>
        void StartScreen();
    }
}