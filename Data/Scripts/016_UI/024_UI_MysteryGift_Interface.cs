using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the Mystery Gift scene that manages downloadable content and gifts.
    /// Handles gift code entry, gift downloading, and received gift management.
    /// </summary>
    public interface IPokemonMysteryGift_Scene : IUIScene, IHaveUpdate
    {
        /// <summary>
        /// Updates all sprites in the Mystery Gift scene.
        /// Called during the main loop to refresh sprite states and animations.
        /// </summary>
        void Update();

        /// <summary>
        /// Starts the Mystery Gift scene with available gift options.
        /// Initializes gift interface, code entry system, and download functionality.
        /// </summary>
        void StartScene();

        /// <summary>
        /// Handles the main scene interaction loop for gift management.
        /// Processes navigation, code entry, and gift download commands.
        /// </summary>
        /// <returns>Result code indicating action taken or exit condition.</returns>
        int Scene();

        /// <summary>
        /// Ends the Mystery Gift scene and cleans up resources.
        /// Handles fade out transition and disposes of sprites and viewports.
        /// </summary>
        void EndScene();

        /// <summary>
        /// Refreshes the gift display with current available and received gifts.
        /// Updates gift lists, status information, and interface elements.
        /// </summary>
        void RefreshGifts();

        /// <summary>
        /// Updates the information display for the currently selected gift option.
        /// Shows gift details, requirements, and availability information.
        /// </summary>
        void UpdateGiftInfo();

        /// <summary>
        /// Handles navigation between gift options and management functions.
        /// Updates selection and refreshes gift information display.
        /// </summary>
        /// <param name="direction">Direction of navigation (up/down).</param>
        void NavigateGifts(int direction);

        /// <summary>
        /// Provides interface for entering Mystery Gift codes or passwords.
        /// Handles text input for gift code redemption.
        /// </summary>
        /// <returns>Entered gift code string, or null if cancelled.</returns>
        string EnterGiftCode();

        /// <summary>
        /// Validates and processes the entered Mystery Gift code.
        /// Checks code validity and initiates gift download if valid.
        /// </summary>
        /// <param name="gift_code">Gift code to validate and process.</param>
        /// <returns>True if code was valid and gift was received.</returns>
        bool ProcessGiftCode(string gift_code);

        /// <summary>
        /// Downloads and receives the specified Mystery Gift.
        /// Handles gift download, validation, and delivery to player.
        /// </summary>
        /// <param name="gift_data">Gift data to download and process.</param>
        /// <returns>True if gift was successfully received.</returns>
        bool ReceiveGift(object gift_data);

        /// <summary>
        /// Displays the list of previously received Mystery Gifts.
        /// Shows gift history and received items/Pokemon information.
        /// </summary>
        void ShowReceivedGifts();

        /// <summary>
        /// Manages Mystery Gift settings and download preferences.
        /// Provides configuration options for gift downloading and notifications.
        /// </summary>
        void ManageGiftSettings();

        /// <summary>
        /// Validates gift reception requirements including inventory space.
        /// Checks if gift can be received based on current conditions.
        /// </summary>
        /// <param name="gift_data">Gift data to validate for reception.</param>
        /// <returns>True if gift can be received successfully.</returns>
        bool ValidateGiftReception(object gift_data);

        /// <summary>
        /// Formats gift information for display in the interface.
        /// Converts gift data into readable format for user display.
        /// </summary>
        /// <param name="gift_data">Gift data to format for display.</param>
        /// <returns>Formatted gift information string.</returns>
        string formatGiftInfo(object gift_data);

        /// <summary>
        /// Handles network communication for Mystery Gift downloading.
        /// Manages connection to gift servers and download processes.
        /// </summary>
        /// <param name="gift_url">URL or identifier for gift download.</param>
        /// <returns>Downloaded gift data, or null if download failed.</returns>
        object DownloadGiftData(string gift_url);

        /// <summary>
        /// Displays download progress during Mystery Gift reception.
        /// Shows progress indicators during gift download and processing.
        /// </summary>
        /// <param name="progress">Current download progress percentage.</param>
        void ShowDownloadProgress(float progress);

        /// <summary>
        /// Handles gift delivery confirmation and success notification.
        /// Displays confirmation message when gift is successfully received.
        /// </summary>
        /// <param name="gift_data">Gift that was successfully received.</param>
        void ConfirmGiftDelivery(object gift_data);

        /// <summary>
        /// Manages gift expiration and availability checking.
        /// Validates gift availability based on time and distribution limits.
        /// </summary>
        /// <param name="gift_data">Gift data to check availability for.</param>
        /// <returns>True if gift is still available for download.</returns>
        bool CheckGiftAvailability(object gift_data);
    }

    /// <summary>
    /// Interface for the Mystery Gift screen that orchestrates downloadable content management.
    /// Coordinates between scenes and manages overall Mystery Gift experience.
    /// </summary>
    public interface IPokemonMysteryGiftScreen
    {
        /// <summary>
        /// Initializes the Mystery Gift screen with the specified scene.
        /// Sets up the scene instance for managing the Mystery Gift interface.
        /// </summary>
        /// <param name="scene">The Mystery Gift scene to use.</param>
        IPokemonMysteryGiftScreen initialize(IPokemonMysteryGift_Scene scene);

        /// <summary>
        /// Starts the Mystery Gift screen for downloadable content management.
        /// Displays Mystery Gift options and manages gift downloading functionality.
        /// </summary>
        void StartScreen();
    }
}