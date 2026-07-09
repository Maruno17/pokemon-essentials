using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the load game scene that manages save file selection and loading.
    /// Handles save file display, selection, and game loading functionality.
    /// </summary>
    public interface IPokemonLoad_Scene : IUIScene, IHaveUpdate
    {
        /// <summary>
        /// Updates all sprites in the load game scene.
        /// Called during the main loop to refresh sprite states and animations.
        /// </summary>
        void Update();

        /// <summary>
        /// Starts the load game scene with available save files.
        /// Initializes save file list, preview information, and selection interface.
        /// </summary>
        void StartScene();

        /// <summary>
        /// Handles the main scene interaction loop for save file selection.
        /// Processes navigation through save files and handles loading commands.
        /// </summary>
        /// <returns>Index of selected save file, or -1 if cancelled.</returns>
        int Scene();

        /// <summary>
        /// Ends the load game scene and cleans up resources.
        /// Handles fade out transition and disposes of sprites and viewports.
        /// </summary>
        void EndScene();

        /// <summary>
        /// Refreshes the save file list display with current file information.
        /// Updates file names, dates, playtime, and preview data.
        /// </summary>
        void RefreshSaveList();

        /// <summary>
        /// Updates the preview information for the currently selected save file.
        /// Shows trainer details, location, playtime, and other save data.
        /// </summary>
        void UpdateSavePreview();

        /// <summary>
        /// Handles navigation between save files in the load list.
        /// Updates selection and refreshes preview information display.
        /// </summary>
        /// <param name="direction">Direction of navigation (up/down).</param>
        void NavigateSaves(int direction);

        /// <summary>
        /// Loads the selected save file and starts the game.
        /// Handles save file loading process and transitions to gameplay.
        /// </summary>
        /// <param name="save_index">Index of the save file to load.</param>
        void LoadGame(int save_index);

        /// <summary>
        /// Confirms save file deletion with user verification.
        /// Provides confirmation dialog before permanently deleting save data.
        /// </summary>
        /// <param name="save_index">Index of the save file to delete.</param>
        /// <returns>True if deletion was confirmed and completed.</returns>
        bool DeleteSave(int save_index);

        /// <summary>
        /// Formats save file information for display in the list.
        /// Converts save data into readable format for preview display.
        /// </summary>
        /// <param name="save_data">Save file data to format.</param>
        /// <returns>Formatted save information.</returns>
        string formatSaveInfo(object save_data);
    }

    /// <summary>
    /// Interface for the load game screen that orchestrates save file management.
    /// Coordinates between scenes and manages overall game loading experience.
    /// </summary>
    public interface IPokemonLoadScreen
    {
        /// <summary>
        /// Initializes the load game screen with the specified scene.
        /// Sets up the scene instance for managing the load interface.
        /// </summary>
        /// <param name="scene">The load game scene to use.</param>
        IPokemonLoadScreen initialize(IPokemonLoad_Scene scene);

        /// <summary>
        /// Starts the load game screen for file selection and loading.
        /// Displays available save files and manages loading functionality.
        /// </summary>
        void StartLoadScreen();

        /// <summary>
        /// Starts the delete save screen for save file management.
        /// Provides interface for deleting unwanted save files.
        /// </summary>
        void StartDeleteScreen();
    }
}