using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the Battle Point Shop scene that manages BP-based transactions.
    /// Handles special item purchasing using Battle Points as currency.
    /// </summary>
    public interface IPokemonBattlePointShop_Scene : IUIScene, IHaveUpdate
    {
        /// <summary>
        /// Updates all sprites in the Battle Point Shop scene.
        /// Called during the main loop to refresh sprite states and animations.
        /// </summary>
        void Update();

        /// <summary>
        /// Starts the Battle Point Shop scene with available BP items.
        /// Initializes shop interface, item list, and BP transaction system.
        /// </summary>
        /// <param name="stock">List of items available for purchase with Battle Points.</param>
        void StartScene(IList<object> stock);

        /// <summary>
        /// Handles the main scene interaction loop for BP shop operations.
        /// Processes navigation, item selection, and BP transaction commands.
        /// </summary>
        /// <returns>Result code indicating action taken or exit condition.</returns>
        int Scene();

        /// <summary>
        /// Ends the Battle Point Shop scene and cleans up resources.
        /// Handles fade out transition and disposes of sprites and viewports.
        /// </summary>
        void EndScene();

        /// <summary>
        /// Refreshes the shop display with current inventory and player BP data.
        /// Updates item list, BP costs, current BP total, and interface elements.
        /// </summary>
        void RefreshShop();

        /// <summary>
        /// Updates the information display for the currently selected item.
        /// Shows item details, BP cost, description, and purchase information.
        /// </summary>
        void UpdateItemInfo();

        /// <summary>
        /// Handles navigation between items in the BP shop inventory.
        /// Updates selection and refreshes item information display.
        /// </summary>
        /// <param name="direction">Direction of navigation (up/down).</param>
        void NavigateItems(int direction);

        /// <summary>
        /// Handles item purchasing with Battle Points currency.
        /// Processes BP transaction including payment and inventory updates.
        /// </summary>
        /// <param name="item">Item to purchase from the BP shop.</param>
        /// <returns>True if purchase was completed successfully.</returns>
        bool BuyItem(object item);

        /// <summary>
        /// Confirms BP transaction details with the player before processing.
        /// Shows transaction summary and requests final confirmation.
        /// </summary>
        /// <param name="item">Item being purchased.</param>
        /// <param name="bp_cost">Battle Points cost of the item.</param>
        /// <returns>True if transaction is confirmed by player.</returns>
        bool ConfirmBPTransaction(object item, int bp_cost);

        /// <summary>
        /// Processes Battle Point payment for purchases with BP validation.
        /// Handles BP deduction and purchase completion.
        /// </summary>
        /// <param name="bp_amount">Amount of Battle Points to deduct for purchase.</param>
        /// <returns>True if BP payment was processed successfully.</returns>
        bool ProcessBPPayment(int bp_amount);

        /// <summary>
        /// Validates BP transaction requirements including BP balance and inventory space.
        /// Checks if transaction can be completed based on current conditions.
        /// </summary>
        /// <param name="item">Item being purchased.</param>
        /// <returns>True if transaction is valid and can be completed.</returns>
        bool ValidateBPTransaction(object item);

        /// <summary>
        /// Gets the Battle Point cost for the specified item.
        /// Returns the BP price for items in the Battle Point Shop.
        /// </summary>
        /// <param name="item">Item to get BP cost for.</param>
        /// <returns>Battle Points required to purchase the item.</returns>
        int getItemBPCost(object item);

        /// <summary>
        /// Displays the player's current Battle Points balance.
        /// Shows available BP for spending in the shop interface.
        /// </summary>
        void DisplayBPBalance();

        /// <summary>
        /// Handles special BP shop features like item previews or demonstrations.
        /// Provides additional functionality specific to Battle Point items.
        /// </summary>
        /// <param name="item">Item to show special features for.</param>
        void ShowItemFeatures(object item);
    }

    /// <summary>
    /// Interface for the Battle Point Shop screen that orchestrates BP shopping functionality.
    /// Coordinates between scenes and manages overall BP shopping experience.
    /// </summary>
    public interface IPokemonBattlePointShopScreen
    {
        /// <summary>
        /// Initializes the Battle Point Shop screen with the specified scene.
        /// Sets up the scene instance for managing the BP shop interface.
        /// </summary>
        /// <param name="scene">The Battle Point Shop scene to use.</param>
        IPokemonBattlePointShopScreen initialize(IPokemonBattlePointShop_Scene scene);

        /// <summary>
        /// Starts the Battle Point Shop screen for BP-based shopping.
        /// Displays BP shop inventory and manages Battle Point transactions.
        /// </summary>
        /// <param name="stock">Items available for purchase with Battle Points.</param>
        void StartScreen(IList<object> stock);
    }
}