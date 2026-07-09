using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the ready menu scene that provides quick access to registered items and field moves.
    /// Manages the display and use of frequently accessed items and Pokemon abilities.
    /// </summary>
    public interface IPokemonReadyMenu_Scene : IUIScene, IHaveUpdate
    {
        /// <summary>
        /// Updates all sprites in the ready menu scene.
        /// Called during the main loop to refresh sprite states and animations.
        /// </summary>
        void Update();

        /// <summary>
        /// Starts the ready menu scene with registered items and available field moves.
        /// Initializes menu display, item icons, and Pokemon field move options.
        /// </summary>
        void StartScene();

        /// <summary>
        /// Handles the main scene interaction loop for item and move selection.
        /// Processes navigation through items/moves and handles usage commands.
        /// </summary>
        /// <returns>Result code indicating action taken or exit condition.</returns>
        int Scene();

        /// <summary>
        /// Ends the ready menu scene and cleans up resources.
        /// Handles fade out transition and disposes of sprites and viewports.
        /// </summary>
        void EndScene();

        /// <summary>
        /// Refreshes the ready menu display with current registered items and field moves.
        /// Updates item availability, move usability, and menu state.
        /// </summary>
        void RefreshMenu();

        /// <summary>
        /// Updates the information display for the currently selected item or move.
        /// Shows item/move description, usage requirements, and availability status.
        /// </summary>
        void UpdateItemInfo();

        /// <summary>
        /// Handles navigation between items and field moves in the ready menu.
        /// Updates selection and refreshes information display accordingly.
        /// </summary>
        /// <param name="direction">Direction of navigation input.</param>
        void NavigateMenu(int direction);

        /// <summary>
        /// Uses the currently selected registered item from the ready menu.
        /// Executes item usage and handles any resulting effects or dialogs.
        /// </summary>
        /// <param name="item_index">Index of the registered item to use.</param>
        void UseRegisteredItem(int item_index);

        /// <summary>
        /// Uses the currently selected field move from the ready menu.
        /// Executes Pokemon field move and handles any resulting effects.
        /// </summary>
        /// <param name="move_index">Index of the field move to use.</param>
        void UseFieldMove(int move_index);

        /// <summary>
        /// Manages the registration of new items to the ready menu.
        /// Provides interface for adding items to quick access slots.
        /// </summary>
        void ManageRegisteredItems();

        /// <summary>
        /// Checks if the currently selected item or move can be used.
        /// Validates usage requirements and environmental conditions.
        /// </summary>
        /// <returns>True if the selected item/move can be used.</returns>
        bool CanUseSelected();

        /// <summary>
        /// Gets the list of Pokemon in the party that have usable field moves.
        /// Returns Pokemon with field moves available in the current context.
        /// </summary>
        /// <returns>List of Pokemon with available field moves.</returns>
        IList<object> getFieldMovePokemon();

        /// <summary>
        /// Updates the display of registered item slots and their contents.
        /// Refreshes item icons, quantities, and availability status.
        /// </summary>
        void UpdateRegisteredItems();

        /// <summary>
        /// Updates the display of available field moves and their Pokemon.
        /// Refreshes move names, Pokemon sprites, and usability status.
        /// </summary>
        void UpdateFieldMoves();
    }

    /// <summary>
    /// Interface for the ready menu screen that orchestrates quick access functionality.
    /// Coordinates between scenes and manages overall ready menu experience.
    /// </summary>
    public interface IPokemonReadyMenuScreen
    {
        /// <summary>
        /// Initializes the ready menu screen with the specified scene.
        /// Sets up the scene instance for managing the ready menu interface.
        /// </summary>
        /// <param name="scene">The ready menu scene to use.</param>
        IPokemonReadyMenuScreen initialize(IPokemonReadyMenu_Scene scene);

        /// <summary>
        /// Starts the ready menu screen for quick item and move access.
        /// Displays registered items and field moves for immediate use.
        /// </summary>
        void StartScreen();
    }
}