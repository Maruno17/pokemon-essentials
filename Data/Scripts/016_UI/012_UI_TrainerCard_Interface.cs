using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the trainer card scene that displays player information and achievements.
    /// Shows trainer details, badges, statistics, and other player accomplishments.
    /// </summary>
    public interface IPokemonTrainerCard_Scene : IUIScene, IHaveUpdate
    {
        /// <summary>
        /// Updates all sprites in the trainer card scene.
        /// Called during the main loop to refresh sprite states and animations.
        /// </summary>
        void Update();

        /// <summary>
        /// Starts the trainer card scene with player information.
        /// Initializes card display, trainer sprite, badges, and statistics.
        /// </summary>
        void StartScene();

        /// <summary>
        /// Handles the main scene interaction loop for card viewing.
        /// Processes navigation between card pages and handles exit input.
        /// </summary>
        /// <returns>Result code indicating navigation action or exit condition.</returns>
        int Scene();

        /// <summary>
        /// Ends the trainer card scene and cleans up resources.
        /// Handles fade out transition and disposes of sprites and viewports.
        /// </summary>
        void EndScene();

        /// <summary>
        /// Refreshes the trainer card display with current player data.
        /// Updates all information fields, badges, and statistics on the card.
        /// </summary>
        void RefreshCard();

        /// <summary>
        /// Draws the main trainer information page with basic details.
        /// Shows trainer name, ID, money, playtime, and basic stats.
        /// </summary>
        void drawPageMain();

        /// <summary>
        /// Draws the badges page showing collected gym badges.
        /// Displays earned badges with their visual representations and names.
        /// </summary>
        void drawPageBadges();

        /// <summary>
        /// Draws the statistics page with detailed game statistics.
        /// Shows various gameplay metrics, records, and achievements.
        /// </summary>
        void drawPageStats();

        /// <summary>
        /// Updates the trainer sprite display based on player character.
        /// Refreshes sprite graphics to match current player appearance.
        /// </summary>
        void UpdateTrainerSprite();

        /// <summary>
        /// Updates the badge display with current collection status.
        /// Refreshes badge graphics and highlights newly earned badges.
        /// </summary>
        void UpdateBadges();

        /// <summary>
        /// Updates the statistics display with current player metrics.
        /// Refreshes all statistical information and gameplay records.
        /// </summary>
        void UpdateStatistics();

        /// <summary>
        /// Handles navigation between different trainer card pages.
        /// Switches between main info, badges, and statistics pages.
        /// </summary>
        /// <param name="direction">Direction of page navigation.</param>
        void ChangePage(int direction);

        /// <summary>
        /// Formats and displays playtime information.
        /// Converts playtime data into readable format for display.
        /// </summary>
        /// <returns>Formatted playtime string.</returns>
        string formatPlaytime();

        /// <summary>
        /// Formats and displays money amount with proper currency formatting.
        /// Converts money value into display format with currency symbols.
        /// </summary>
        /// <returns>Formatted money string.</returns>
        string formatMoney();
    }

    /// <summary>
    /// Interface for the trainer card screen that orchestrates player information display.
    /// Coordinates between scenes and manages overall trainer card viewing experience.
    /// </summary>
    public interface IPokemonTrainerCardScreen
    {
		/// <summary>
		/// Initializes the trainer card screen with the specified scene.
		/// Sets up the scene instance for managing the trainer card interface.
		/// </summary>
		/// <param name="scene">The trainer card scene to use.</param>
		IPokemonTrainerCardScreen initialize(IPokemonTrainerCard_Scene scene);

        /// <summary>
        /// Starts the trainer card screen for viewing player information.
        /// Displays the trainer card with comprehensive player data and achievements.
        /// </summary>
        void StartScreen();
    }
}