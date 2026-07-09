using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the PokeMart scene that manages shop transactions and inventory.
    /// Handles item purchasing, selling, and mart interface functionality.
    /// </summary>
    public interface IPokemonMart_Scene : IUIScene, IHaveUpdate
    {
        /// <summary>
        /// Updates all sprites in the PokeMart scene.
        /// Called during the main loop to refresh sprite states and animations.
        /// </summary>
        void Update();

        /// <summary>
        /// Starts the PokeMart scene with available shop inventory.
        /// Initializes shop interface, item list, and transaction system.
        /// </summary>
        /// <param name="stock">List of items available for purchase in the mart.</param>
        /// <param name="adapter">Mart adapter for handling shop-specific behavior.</param>
        void StartScene(IList<object> stock, object adapter);

        /// <summary>
        /// Handles the main scene interaction loop for shop operations.
        /// Processes navigation, item selection, and transaction commands.
        /// </summary>
        /// <returns>Result code indicating action taken or exit condition.</returns>
        int Scene();

        /// <summary>
        /// Ends the PokeMart scene and cleans up resources.
        /// Handles fade out transition and disposes of sprites and viewports.
        /// </summary>
        void EndScene();

        /// <summary>
        /// Refreshes the mart display with current inventory and player data.
        /// Updates item list, prices, money display, and interface elements.
        /// </summary>
        void RefreshMart();

        /// <summary>
        /// Updates the information display for the currently selected item.
        /// Shows item details, price, description, and purchase information.
        /// </summary>
        void UpdateItemInfo();

        /// <summary>
        /// Handles navigation between items in the mart inventory.
        /// Updates selection and refreshes item information display.
        /// </summary>
        /// <param name="direction">Direction of navigation (up/down).</param>
        void NavigateItems(int direction);

        /// <summary>
        /// Handles item purchasing with quantity selection and payment.
        /// Processes buy transaction including payment and inventory updates.
        /// </summary>
        /// <param name="item">Item to purchase from the mart.</param>
        /// <param name="quantity">Number of items to buy.</param>
        /// <returns>True if purchase was completed successfully.</returns>
        bool BuyItem(object item, int quantity);

        /// <summary>
        /// Handles item selling with quantity selection and payment.
        /// Processes sell transaction including payment and inventory updates.
        /// </summary>
        /// <param name="item">Item to sell to the mart.</param>
        /// <param name="quantity">Number of items to sell.</param>
        /// <returns>True if sale was completed successfully.</returns>
        bool SellItem(object item, int quantity);

        /// <summary>
        /// Provides interface for selecting item quantity for transactions.
        /// Handles quantity input with validation for available stock/money.
        /// </summary>
        /// <param name="item">Item being transacted.</param>
        /// <param name="max_quantity">Maximum quantity available for transaction.</param>
        /// <param name="is_buying">Whether this is a buying (true) or selling (false) transaction.</param>
        /// <returns>Selected quantity for the transaction.</returns>
        int SelectQuantity(object item, int max_quantity, bool is_buying);

        /// <summary>
        /// Confirms transaction details with the player before processing.
        /// Shows transaction summary and requests final confirmation.
        /// </summary>
        /// <param name="item">Item being transacted.</param>
        /// <param name="quantity">Quantity being transacted.</param>
        /// <param name="total_cost">Total cost of the transaction.</param>
        /// <param name="is_buying">Whether this is a buying or selling transaction.</param>
        /// <returns>True if transaction is confirmed by player.</returns>
        bool ConfirmTransaction(object item, int quantity, int total_cost, bool is_buying);

        /// <summary>
        /// Processes payment for buy transactions with money validation.
        /// Handles money deduction and purchase completion.
        /// </summary>
        /// <param name="amount">Amount of money to deduct for purchase.</param>
        /// <returns>True if payment was processed successfully.</returns>
        bool ProcessPayment(int amount);

        /// <summary>
        /// Processes payment for sell transactions with money addition.
        /// Handles money addition and sale completion.
        /// </summary>
        /// <param name="amount">Amount of money to add from sale.</param>
        void ReceivePayment(int amount);

        /// <summary>
        /// Validates transaction requirements including money and inventory space.
        /// Checks if transaction can be completed based on current conditions.
        /// </summary>
        /// <param name="item">Item being transacted.</param>
        /// <param name="quantity">Quantity being transacted.</param>
        /// <param name="is_buying">Whether this is a buying or selling transaction.</param>
        /// <returns>True if transaction is valid and can be completed.</returns>
        bool ValidateTransaction(object item, int quantity, bool is_buying);

        /// <summary>
        /// Gets the current price for the specified item in this mart.
        /// Calculates item price based on mart type and any applicable modifiers.
        /// </summary>
        /// <param name="item">Item to get price for.</param>
        /// <param name="is_buying">Whether getting buy price (true) or sell price (false).</param>
        /// <returns>Price of the item for the specified transaction type.</returns>
        int getItemPrice(object item, bool is_buying);
    }

    /// <summary>
    /// Interface for the PokeMart screen that orchestrates shop functionality.
    /// Coordinates between scenes and manages overall shopping experience.
    /// </summary>
    public interface IPokemonMartScreen
    {
        /// <summary>
        /// Initializes the PokeMart screen with the specified scene.
        /// Sets up the scene instance for managing the mart interface.
        /// </summary>
        /// <param name="scene">The PokeMart scene to use.</param>
        IPokemonMartScreen initialize(IPokemonMart_Scene scene);

        /// <summary>
        /// Starts the PokeMart screen for shopping functionality.
        /// Displays mart inventory and manages shopping transactions.
        /// </summary>
        /// <param name="stock">Items available for purchase in this mart.</param>
        void StartScreen(IList<object> stock);
    }
}