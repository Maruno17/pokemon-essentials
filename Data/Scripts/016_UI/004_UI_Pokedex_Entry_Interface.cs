using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the Pokédex entry information scene that displays detailed Pokemon data.
    /// Shows comprehensive information including stats, area data, forms, and descriptions.
    /// </summary>
    public interface IScenePokemonPokedexInfo : IScene, IUIScene, IHaveUpdate
    {
        /// <summary>
        /// Starts the Pokédex entry scene with specified Pokemon list and selection.
        /// Initializes all display elements including sprites, maps, and information panels.
        /// </summary>
        /// <param name="dexlist">List of Pokemon entries in the current Pokédex.</param>
        /// <param name="index">Index of the currently selected Pokemon.</param>
        /// <param name="region">Region identifier for map and location data.</param>
        void StartScene(IList<object> dexlist, int index, int region);

        /// <summary>
        /// Handles the main scene interaction loop for viewing Pokemon information.
        /// Processes navigation between Pokemon entries and information pages.
        /// </summary>
        /// <returns>Result code indicating navigation action or exit condition.</returns>
        int Scene();

        /// <summary>
        /// Ends the Pokédex entry scene and cleans up resources.
        /// Handles fade out transition and disposes of sprites and viewports.
        /// </summary>
        void EndScene();

        /// <summary>
        /// Updates all sprites in the Pokédex entry scene.
        /// Called during the main loop to refresh sprite states and animations.
        /// </summary>
        void Update();

        /// <summary>
        /// Refreshes the Pokemon information display for the currently selected entry.
        /// Updates sprites, text, and data based on the current Pokemon and page.
        /// </summary>
        void drawPage();

        /// <summary>
        /// Draws the main information page with basic Pokemon data.
        /// Shows sprite, stats, type, description, and basic characteristics.
        /// </summary>
        /// <param name="species">The Pokemon species to display information for.</param>
        void drawPageInfo(int species);

        /// <summary>
        /// Draws the area distribution page showing where Pokemon can be found.
        /// Displays location map with highlighted areas and encounter details.
        /// </summary>
        /// <param name="species">The Pokemon species to show area data for.</param>
        void drawPageArea(int species);

        /// <summary>
        /// Draws the forms page showing different forms of the Pokemon.
        /// Displays form variations with sprites and form-specific information.
        /// </summary>
        /// <param name="species">The Pokemon species to show form data for.</param>
        void drawPageForms(int species);

        /// <summary>
        /// Updates the area map highlighting based on Pokemon distribution data.
        /// Shows highlighted regions where the Pokemon can be encountered.
        /// </summary>
        void UpdateAreaMap();

        /// <summary>
        /// Draws area highlights on the region map for Pokemon locations.
        /// Renders colored overlays indicating where the Pokemon appears.
        /// </summary>
        /// <param name="encounter_data">Data about where Pokemon can be found.</param>
        void drawAreaHighlights(IList<object> encounter_data);

        /// <summary>
        /// Updates the form selection display with navigation arrows.
        /// Shows available forms and indicates current selection with visual cues.
        /// </summary>
        void UpdateFormData();

        /// <summary>
        /// Handles navigation between different Pokemon in the dex list.
        /// Updates the current selection and refreshes the display accordingly.
        /// </summary>
        /// <param name="direction">Direction of navigation (next/previous).</param>
        void ChangePokemon(int direction);

        /// <summary>
        /// Handles navigation between different information pages.
        /// Switches between info, area, and forms pages as available.
        /// </summary>
        /// <param name="direction">Direction of page navigation.</param>
        void ChangePage(int direction);
    }

    /// <summary>
    /// Interface for the Pokédex entry screen that orchestrates detailed Pokemon viewing.
    /// Coordinates between scenes and manages the detailed information display flow.
    /// </summary>
    public interface IScreenPokemonPokedexInfo : IScreen
    {
        /// <summary>
        /// Initializes the Pokédex entry screen with the specified scene.
        /// Sets up the scene instance for managing the detailed information interface.
        /// </summary>
        /// <param name="scene">The Pokédex entry scene to use.</param>
        IScreenPokemonPokedexInfo initialize(IScenePokemonPokedexInfo scene);

        /// <summary>
        /// Starts the Pokédex entry screen for the specified Pokemon.
        /// Displays detailed information for a specific Pokemon species.
        /// </summary>
        /// <param name="species">The Pokemon species to show detailed information for.</param>
        void DexEntry(int species);

        /// <summary>
        /// Starts the Pokédex entry screen with navigation through a Pokemon list.
        /// Allows browsing detailed information for multiple Pokemon with navigation.
        /// </summary>
        /// <param name="dexlist">List of Pokemon entries available for viewing.</param>
        /// <param name="index">Starting index in the Pokemon list.</param>
        /// <param name="region">Region identifier for location and map data.</param>
        void StartScreen(IList<int> dexlist, int index, int region);
    }
}