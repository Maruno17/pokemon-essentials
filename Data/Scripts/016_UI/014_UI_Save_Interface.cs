using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the save game scene that manages game saving functionality.
    /// Handles save file creation, overwriting, and save process management.
    /// </summary>
    public interface IPokemonSave_Scene : IUIScene, IHaveUpdate
    {
        /// <summary>
        /// Updates all sprites in the save game scene.
        /// Called during the main loop to refresh sprite states and animations.
        /// </summary>
        void Update();

        /// <summary>
        /// Starts the save game scene with current game state.
        /// Initializes save interface, preview information, and confirmation dialogs.
        /// </summary>
        void StartScene();

        /// <summary>
        /// Handles the main scene interaction loop for save confirmation.
        /// Processes save confirmation and handles save operation execution.
        /// </summary>
        /// <returns>Result code indicating save action or cancellation.</returns>
        int Scene();

        /// <summary>
        /// Ends the save game scene and cleans up resources.
        /// Handles fade out transition and disposes of sprites and viewports.
        /// </summary>
        void EndScene();

        /// <summary>
        /// Displays the save confirmation interface with current game information.
        /// Shows player details, location, playtime, and save preview data.
        /// </summary>
        void ShowSaveConfirmation();

        /// <summary>
        /// Executes the game save operation with progress indication.
        /// Handles actual save file writing and displays save progress.
        /// </summary>
        /// <returns>True if save operation completed successfully.</returns>
        bool ExecuteSave();

        /// <summary>
        /// Displays save progress information during the save operation.
        /// Shows progress bar or status messages during save file writing.
        /// </summary>
        /// <param name="progress">Current save progress percentage.</param>
        void ShowSaveProgress(float progress);

        /// <summary>
        /// Handles save operation completion with success or failure notification.
        /// Displays appropriate message based on save operation result.
        /// </summary>
        /// <param name="success">Whether the save operation was successful.</param>
        void HandleSaveCompletion(bool success);

        /// <summary>
        /// Formats current game information for save preview display.
        /// Converts current game state into readable format for save confirmation.
        /// </summary>
        /// <returns>Formatted game information for save preview.</returns>
        string formatGameInfo();

        /// <summary>
        /// Validates save operation prerequisites and conditions.
        /// Checks if saving is allowed and conditions are met for safe saving.
        /// </summary>
        /// <returns>True if saving is allowed and safe to proceed.</returns>
        bool validateSaveConditions();
    }

    /// <summary>
    /// Interface for the save game screen that orchestrates game saving functionality.
    /// Coordinates between scenes and manages overall game saving experience.
    /// </summary>
    public interface IPokemonSaveScreen
    {
        /// <summary>
        /// Initializes the save game screen with the specified scene.
        /// Sets up the scene instance for managing the save interface.
        /// </summary>
        /// <param name="scene">The save game scene to use.</param>
        IPokemonSaveScreen initialize(IPokemonSave_Scene scene);

        /// <summary>
        /// Starts the save game screen for saving current game progress.
        /// Displays save confirmation and manages saving functionality.
        /// </summary>
        /// <returns>True if game was saved successfully.</returns>
        bool StartSaveScreen();
    }
}