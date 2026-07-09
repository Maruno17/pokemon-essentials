using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the region map scene that displays the world map with locations.
    /// Manages map display, location highlighting, player position, and point of interest markers.
    /// </summary>
    public interface IPokemonRegionMap_Scene : IUIScene, IHaveUpdate
    {
        /// <summary>
        /// Updates all sprites in the region map scene.
        /// Called during the main loop to refresh sprite states and animations.
        /// </summary>
        void Update();

        /// <summary>
        /// Starts the region map scene for the specified region.
        /// Initializes map graphics, location markers, and player position indicator.
        /// </summary>
        /// <param name="region">Region identifier to display the map for.</param>
        /// <param name="wallmap">Whether to show wall map style or standard map.</param>
        void StartScene(int region = -1, bool wallmap = true);

        /// <summary>
        /// Handles the main scene interaction loop for map navigation.
        /// Processes navigation input and location selection functionality.
        /// </summary>
        /// <returns>Result code indicating navigation action or exit condition.</returns>
        int Scene();

        /// <summary>
        /// Ends the region map scene and cleans up resources.
        /// Handles fade out transition and disposes of sprites and viewports.
        /// </summary>
        void EndScene();

        /// <summary>
        /// Updates the map display with current player position and visited locations.
        /// Refreshes location markers and highlights based on player progress.
        /// </summary>
        void RefreshMap();

        /// <summary>
        /// Updates location information display for the currently highlighted area.
        /// Shows location name, description, and available points of interest.
        /// </summary>
        void UpdateLocationInfo();

        /// <summary>
        /// Handles navigation to adjacent map locations using directional input.
        /// Updates cursor position and highlighted location based on movement.
        /// </summary>
        /// <param name="direction">Direction of movement input.</param>
        void NavigateMap(int direction);

        /// <summary>
        /// Toggles between different map viewing modes or overlays.
        /// Switches between standard view and special information displays.
        /// </summary>
        void ToggleMapMode();

        /// <summary>
        /// Shows detailed information for the currently selected location.
        /// Displays location description, available services, and other details.
        /// </summary>
        void ShowLocationDetails();
    }

    /// <summary>
    /// Interface for the region map screen that orchestrates map viewing functionality.
    /// Coordinates between scenes and manages overall map navigation experience.
    /// </summary>
    public interface IPokemonRegionMapScreen
    {
		/// <summary>
		/// Initializes the region map screen with the specified scene.
		/// Sets up the scene instance for managing the map interface.
		/// </summary>
		/// <param name="scene">The region map scene to use.</param>
		IPokemonRegionMapScreen initialize(IPokemonRegionMap_Scene scene);

        /// <summary>
        /// Starts the region map screen for viewing and navigation.
        /// Displays the regional map with interactive location browsing.
        /// </summary>
        void StartScreen();
    }
}