using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the item storage scene that manages PC item storage functionality.
    /// Handles item storage, withdrawal, organization, and inventory management.
    /// </summary>
    public interface IPokemonItemStorage_Scene : IStorageUIScene, IHaveUpdate
    {
        /// <summary>
        /// Updates all sprites in the item storage scene.
        /// Called during the main loop to refresh sprite states and animations.
        /// </summary>
        void Update();

        /// <summary>
        /// Starts the item storage scene with access to PC item storage.
        /// Initializes storage display, item list, and inventory interface.
        /// </summary>
        /// <param name="storage">Item storage system instance.</param>
        /// <param name="bag">Player's current item bag.</param>
        void StartScene(object storage, object bag);

        /// <summary>
        /// Handles the main scene interaction loop for item management.
        /// Processes navigation, selection, and item organization commands.
        /// </summary>
        /// <returns>Result code indicating action taken or exit condition.</returns>
        int Scene();

        /// <summary>
        /// Ends the item storage scene and cleans up resources.
        /// Handles fade out transition and disposes of sprites and viewports.
        /// </summary>
        void EndScene();

        /// <summary>
        /// Refreshes the storage display with current item data.
        /// Updates item lists, quantities, and interface elements.
        /// </summary>
        void RefreshStorage();

        /// <summary>
        /// Updates the information display for the currently selected item.
        /// Shows item details, description, and quantity information.
        /// </summary>
        void UpdateItemInfo();

        /// <summary>
        /// Handles navigation between storage categories and items.
        /// Updates selection cursor and changes active display area.
        /// </summary>
        /// <param name="direction">Direction of navigation input.</param>
        void NavigateStorage(int direction);

        /// <summary>
        /// Deposits items from the bag to PC storage.
        /// Transfers specified quantity of items to storage system.
        /// </summary>
        /// <param name="item">Item type to deposit.</param>
        /// <param name="quantity">Number of items to deposit.</param>
        void DepositItem(object item, int quantity);

        /// <summary>
        /// Withdraws items from PC storage to the bag.
        /// Transfers specified quantity of items from storage to inventory.
        /// </summary>
        /// <param name="item">Item type to withdraw.</param>
        /// <param name="quantity">Number of items to withdraw.</param>
        void WithdrawItem(object item, int quantity);

        /// <summary>
        /// Handles item quantity selection for deposit/withdrawal operations.
        /// Provides interface for specifying how many items to transfer.
        /// </summary>
        /// <param name="max_quantity">Maximum quantity available for transfer.</param>
        /// <returns>Selected quantity for transfer operation.</returns>
        int SelectQuantity(int max_quantity);

        /// <summary>
        /// Changes the currently active item category for viewing.
        /// Switches between different item types and updates display.
        /// </summary>
        /// <param name="category">Category index to switch to.</param>
        void ChangeCategory(int category);

        /// <summary>
        /// Sorts items in the storage system by specified criteria.
        /// Organizes items by name, type, quantity, or other attributes.
        /// </summary>
        /// <param name="sort_type">Type of sorting to apply.</param>
        void SortItems(int sort_type);

        /// <summary>
        /// Searches for specific items in the storage system.
        /// Provides interface for finding items by name or attributes.
        /// </summary>
        /// <param name="search_term">Search criteria for finding items.</param>
        void SearchItems(string search_term);

        /// <summary>
        /// Validates item transfer operations for legality and capacity.
        /// Checks if items can be transferred based on space and restrictions.
        /// </summary>
        /// <param name="item">Item to transfer.</param>
        /// <param name="quantity">Quantity to transfer.</param>
        /// <param name="to_storage">Whether transferring to storage (true) or bag (false).</param>
        /// <returns>True if transfer operation is valid and allowed.</returns>
        bool ValidateTransfer(object item, int quantity, bool to_storage);

        /// <summary>
        /// Gets the available space for items in the specified storage location.
        /// Calculates remaining capacity for item storage operations.
        /// </summary>
        /// <param name="location">Storage location to check (bag or PC).</param>
        /// <returns>Available space for item storage.</returns>
        int getAvailableSpace(string location);
    }

    /// <summary>
    /// Interface for the item storage screen that orchestrates PC item management.
    /// Coordinates between scenes and manages overall item storage experience.
    /// </summary>
    public interface IPokemonItemStorageScreen
    {
        /// <summary>
        /// Initializes the item storage screen with the specified scene.
        /// Sets up the scene instance for managing the storage interface.
        /// </summary>
        /// <param name="scene">The item storage scene to use.</param>
        IPokemonItemStorageScreen initialize(IPokemonItemStorage_Scene scene);

        /// <summary>
        /// Starts the item storage screen for PC item management.
        /// Displays item storage system with organization functionality.
        /// </summary>
        void StartScreen();
    }
}