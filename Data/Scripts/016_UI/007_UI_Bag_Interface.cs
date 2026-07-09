using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the bag screen scene that displays and manages the player's items.
    /// Allows browsing, using, and organizing items in different pockets.
    /// </summary>
    public interface IBagScene : IUIScene, IListUIScene
    {
        /// <summary>
        /// Sets the bag object to display.
        /// </summary>
        /// <param name="bag">The player's bag containing items.</param>
        void setBag(object bag);

        /// <summary>
        /// Gets the currently displayed bag.
        /// </summary>
        /// <returns>The bag object.</returns>
        object getBag();

        /// <summary>
        /// Gets the currently selected pocket index.
        /// </summary>
        /// <returns>The selected pocket index.</returns>
        int getCurrentPocket();

        /// <summary>
        /// Sets the current pocket to display.
        /// </summary>
        /// <param name="pocketIndex">The pocket index to select.</param>
        void setCurrentPocket(int pocketIndex);

        /// <summary>
        /// Gets the number of pockets in the bag.
        /// </summary>
        /// <returns>The total number of pockets.</returns>
        int getPocketCount();

        /// <summary>
        /// Shows the bag interface and handles item selection.
        /// </summary>
        /// <param name="filterProc">Optional function to filter which items can be selected.</param>
        /// <returns>The selected item, or null if cancelled.</returns>
        object ChooseItem(Func<object, bool> filterProc = null);

        /// <summary>
        /// Shows the bag in giving mode (for giving items to Pokemon).
        /// </summary>
        /// <returns>The selected item to give, or null if cancelled.</returns>
        object ChooseItemToGive();

        /// <summary>
        /// Refreshes the display of items in the current pocket.
        /// </summary>
        void refreshPocket();

        /// <summary>
        /// Shows details about the selected item.
        /// </summary>
        /// <param name="item">The item to show details for.</param>
        void showItemDetails(object item);

        /// <summary>
        /// Shows the item options menu (Use, Give, Toss, etc.).
        /// </summary>
        /// <param name="item">The item to show options for.</param>
        /// <returns>The selected option index.</returns>
        int showItemOptions(object item);
    }

    /// <summary>
    /// Interface for the bag screen that manages the bag scene and item interactions.
    /// </summary>
    public interface IBagScreen : IUIScreen
    {
        /// <summary>
        /// Starts the bag screen for item selection.
        /// </summary>
        /// <param name="bag">The player's bag.</param>
        /// <param name="filterProc">Optional function to filter selectable items.</param>
        /// <returns>The selected item, or null if cancelled.</returns>
        object StartScreen(object bag, Func<object, bool> filterProc = null);

        /// <summary>
        /// Shows the bag screen for giving an item to a Pokemon.
        /// </summary>
        /// <param name="bag">The player's bag.</param>
        /// <param name="pokemon">The Pokemon to give an item to.</param>
        /// <returns>The selected item to give, or null if cancelled.</returns>
        object GiveItemScreen(object bag, object pokemon);

        /// <summary>
        /// Shows the bag screen for using an item on a Pokemon.
        /// </summary>
        /// <param name="bag">The player's bag.</param>
        /// <param name="pokemon">The Pokemon to use an item on.</param>
        /// <returns>The result of the item use.</returns>
        bool UseItemScreen(object bag, object pokemon);
    }

    /// <summary>
    /// Interface for bag utilities and item management functions.
    /// </summary>
    public interface IBagUtilities
    {
        /// <summary>
        /// Opens the bag screen for item selection.
        /// </summary>
        /// <param name="variableNumber">The variable to store the selected item in.</param>
        /// <param name="nameVarNumber">The variable to store the item name in.</param>
        /// <param name="filterProc">Optional function to filter selectable items.</param>
        /// <returns>True if an item was selected, false if cancelled.</returns>
        bool ChooseItem(int variableNumber, int nameVarNumber = 0, Func<object, bool> filterProc = null);

        /// <summary>
        /// Uses an item from the bag.
        /// </summary>
        /// <param name="item">The item to use.</param>
        /// <param name="pokemon">The Pokemon to use the item on (if applicable).</param>
        /// <returns>True if the item was used successfully, false otherwise.</returns>
        bool UseItem(object item, object pokemon = null);

        /// <summary>
        /// Gives an item to a Pokemon.
        /// </summary>
        /// <param name="pokemon">The Pokemon to give the item to.</param>
        /// <param name="item">The item to give.</param>
        /// <returns>True if the item was given successfully, false otherwise.</returns>
        bool GiveItem(object pokemon, object item);

        /// <summary>
        /// Tosses (discards) items from the bag.
        /// </summary>
        /// <param name="item">The item to toss.</param>
        /// <param name="quantity">The number of items to toss.</param>
        /// <returns>True if items were tossed, false if cancelled.</returns>
        bool TossItem(object item, int quantity);

        /// <summary>
        /// Gets the quantity of a specific item in the bag.
        /// </summary>
        /// <param name="item">The item to check quantity for.</param>
        /// <returns>The quantity of the item.</returns>
        int getItemQuantity(object item);

        /// <summary>
        /// Checks if the bag has a specific item.
        /// </summary>
        /// <param name="item">The item to check for.</param>
        /// <returns>True if the bag contains the item, false otherwise.</returns>
        bool hasItem(object item);
    }

    /// <summary>
    /// Interface for bag pocket management and organization.
    /// </summary>
    public interface IBagPocketManager
    {
        /// <summary>
        /// Gets the name of a specific pocket.
        /// </summary>
        /// <param name="pocketIndex">The pocket index.</param>
        /// <returns>The name of the pocket.</returns>
        string getPocketName(int pocketIndex);

        /// <summary>
        /// Gets all items in a specific pocket.
        /// </summary>
        /// <param name="pocketIndex">The pocket index.</param>
        /// <returns>List of items in the pocket.</returns>
        IList<object> getPocketItems(int pocketIndex);

        /// <summary>
        /// Determines which pocket an item belongs to.
        /// </summary>
        /// <param name="item">The item to check.</param>
        /// <returns>The pocket index the item belongs to.</returns>
        int getItemPocket(object item);

        /// <summary>
        /// Sorts items in a specific pocket.
        /// </summary>
        /// <param name="pocketIndex">The pocket to sort.</param>
        void sortPocket(int pocketIndex);

        /// <summary>
        /// Gets the maximum capacity of a specific pocket.
        /// </summary>
        /// <param name="pocketIndex">The pocket index.</param>
        /// <returns>The maximum number of different items the pocket can hold.</returns>
        int getPocketCapacity(int pocketIndex);

        /// <summary>
        /// Checks if a pocket is full.
        /// </summary>
        /// <param name="pocketIndex">The pocket index.</param>
        /// <returns>True if the pocket is full, false otherwise.</returns>
        bool isPocketFull(int pocketIndex);
    }

    /// <summary>
    /// Interface for item filtering and search functionality in the bag.
    /// </summary>
    public interface IBagItemFilter
    {
        /// <summary>
        /// Filters items based on usability criteria.
        /// </summary>
        /// <param name="items">The items to filter.</param>
        /// <param name="context">The context for item use (e.g., "field", "battle").</param>
        /// <returns>List of usable items.</returns>
        IList<object> filterUsableItems(IList<object> items, string context);

        /// <summary>
        /// Filters items that can be given to Pokemon.
        /// </summary>
        /// <param name="items">The items to filter.</param>
        /// <param name="pokemon">The Pokemon to potentially give items to.</param>
        /// <returns>List of items that can be given.</returns>
        IList<object> filterGivableItems(IList<object> items, object pokemon = null);

        /// <summary>
        /// Filters items based on type or category.
        /// </summary>
        /// <param name="items">The items to filter.</param>
        /// <param name="itemType">The type/category to filter by.</param>
        /// <returns>List of items matching the type.</returns>
        IList<object> filterItemsByType(IList<object> items, string itemType);

        /// <summary>
        /// Searches for items by name.
        /// </summary>
        /// <param name="items">The items to search through.</param>
        /// <param name="searchTerm">The name or partial name to search for.</param>
        /// <returns>List of items matching the search term.</returns>
        IList<object> searchItemsByName(IList<object> items, string searchTerm);
    }
}