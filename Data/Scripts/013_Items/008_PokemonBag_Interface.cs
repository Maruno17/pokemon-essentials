using System;
using System.Collections.Generic;
using PokemonEssentials.Data;

namespace PokemonEssentials
{
	/// <summary>
	/// Interface for the Bag object that contains all player items.
	/// </summary>
	/// <remarks>
	/// The Bag object, which actually contains all the items.
	/// </remarks>
	//public interface IPokemonBag
	public interface IGameBag
	{
		/// <summary>
		/// Gets the bag pockets array containing items.
		/// </summary>
		IList<IList<int[]>> pockets { get; }
		//Items[][] pockets { get; }

		/// <summary>
		/// Gets or sets the last viewed pocket index.
		/// </summary>
		int last_viewed_pocket { get; set; }

		/// <summary>
		/// Gets or sets the last selection index for each pocket.
		/// </summary>
		IList<int> last_pocket_selections { get; set; }

		/// <summary>
		/// Gets the array of registered items for quick access.
		/// </summary>
		IList<int> registered_items { get; }

		/// <summary>
		/// Gets the Ready Menu cursor position data.
		/// </summary>
		int[] ready_menu_selection { get; }

		/// <summary>
		/// Gets the names of all bag pockets.
		/// </summary>
		/// <returns>Array of pocket names</returns>
		string[] pocket_names { get; }

		/// <summary>
		/// Gets the number of pockets in the bag.
		/// </summary>
		/// <returns>Number of pockets</returns>
		int pocket_count { get; }

		IGameBag initialize();

		/// <summary>
		/// Resets the last selection indices for all pockets.
		/// </summary>
		void reset_last_selections();

		/// <summary>
		/// Clears all items from the bag.
		/// </summary>
		void clear();

		/// <summary>
		/// Gets the last viewed item index in a specific pocket.
		/// </summary>
		/// <param name="pocket">The pocket index</param>
		/// <returns>Last viewed index</returns>
		int last_viewed_index(int pocket);

		/// <summary>
		/// Sets the last viewed item index in a specific pocket.
		/// </summary>
		/// <param name="pocket">The pocket index</param>
		/// <param name="value">The index value</param>
		void set_last_viewed_index(int pocket, int value);

		/// <summary>
		/// Gets the quantity of a specific item in the bag.
		/// </summary>
		/// <param name="item">The item to check</param>
		/// <returns>Quantity of the item</returns>
		int quantity(int item);

		/// <summary>
		/// Checks if the bag contains at least the specified quantity of an item.
		/// </summary>
		/// <param name="item">The item to check</param>
		/// <param name="qty">Quantity to check for</param>
		/// <returns>True if the bag has enough of the item</returns>
		bool has(int item, int qty = 1);

		/// <summary>
		/// Alias for has() - checks if items can be removed.
		/// </summary>
		/// <param name="item">The item to check</param>
		/// <param name="qty">Quantity to check for</param>
		/// <returns>True if the items can be removed</returns>
		bool can_remove(int item, int qty = 1);

		/// <summary>
		/// Checks if the specified quantity of an item can be added to the bag.
		/// </summary>
		/// <param name="item">The item to check</param>
		/// <param name="qty">Quantity to add</param>
		/// <returns>True if the item can be added</returns>
		bool can_add(int item, int qty = 1);

		/// <summary>
		/// Adds an item to the bag.
		/// </summary>
		/// <param name="item">The item to add</param>
		/// <param name="qty">Quantity to add</param>
		/// <returns>True if the item was added successfully</returns>
		bool add(int item, int qty = 1);

		/// <summary>
		/// Adds all of the specified quantity or none at all.
		/// </summary>
		/// <remarks>
		/// Adds qty number of item. Doesn't add anything if it can't add all of them.
		/// </remarks>
		/// <param name="item">The item to add</param>
		/// <param name="qty">Quantity to add</param>
		/// <returns>True if all items were added</returns>
		bool add_all(int item, int qty = 1);

		/// <summary>
		/// Removes items from the bag (up to the specified quantity).
		/// </summary>
		/// <remarks>
		/// Deletes as many of item as possible (up to qty), and returns whether it
		/// managed to delete qty of them.
		/// </remarks>
		/// <param name="item">The item to remove</param>
		/// <param name="qty">Quantity to remove</param>
		/// <returns>True if any items were removed</returns>
		bool remove(int item, int qty = 1);

		/// <summary>
		/// Removes exactly the specified quantity or none at all.
		/// </summary>
		/// <remarks>
		/// Deletes qty number of item. Doesn't delete anything if there are less than
		/// qty of the item in the Bag.
		/// </remarks>
		/// <param name="item">The item to remove</param>
		/// <param name="qty">Quantity to remove</param>
		/// <returns>True if the exact quantity was removed</returns>
		bool remove_all(int item, int qty = 1);

		/// <summary>
		/// Replaces all instances of one item with another in the same pocket.
		/// </summary>
		/// <remarks>
		/// This only works if the old and new items are in the same pocket. Used for
		/// switching on/off certain Key Items. Replaces all old_item in its pocket with
		/// new_item.
		/// </remarks>
		/// <param name="old_item">The item to replace</param>
		/// <param name="new_item">The replacement item</param>
		/// <returns>True if any items were replaced</returns>
		bool replace_item(int old_item, int new_item);

		/// <summary>
		/// Checks if an item is registered for quick access.
		/// </summary>
		/// <remarks>
		/// Returns whether item has been registered for quick access in the Ready Menu.
		/// </remarks>
		/// <param name="item">The item to check</param>
		/// <returns>True if the item is registered</returns>
		bool registered(int item);

		/// <summary>
		/// Registers an item for quick access in the Ready Menu.
		/// </summary>
		/// <param name="item">The item to register</param>
		void register(int item);

		/// <summary>
		/// Unregisters an item from quick access.
		/// </summary>
		/// <param name="item">The item to unregister</param>
		void unregister(int item);
	}

	/// <summary>
	/// Interface for the PC item storage system.
	/// </summary>
	/// <remarks>
	/// The PC item storage object, which actually contains all the items.
	/// </remarks>
	public interface IPCItemStorage
	{
		/// <summary>
		/// Gets the items array containing stored items.
		/// </summary>
		IList<int[]> items { get; }

		/// <summary>
		/// Maximum number of different slots in storage.
		/// </summary>
		int MAX_SIZE { get; }

		/// <summary>
		/// Maximum number of items per slot.
		/// </summary>
		int MAX_PER_SLOT { get; }

		/// <summary>
		/// Gets an item at the specified index.
		/// </summary>
		/// <param name="i">The index</param>
		/// <returns>The item data</returns>
		int[] this[int i] { get; }

		/// <summary>
		/// Gets the number of different item types stored.
		/// </summary>
		/// <returns>Number of item types</returns>
		int length { get; }

		/// <summary>
		/// Checks if the storage is empty.
		/// </summary>
		/// <returns>True if empty</returns>
		bool empty { get; }

		IPCItemStorage initialize();

		/// <summary>
		/// Clears all items from storage.
		/// </summary>
		void clear();

		/// <summary>
		/// </summary>
		/// <param name="index"></param>
		/// <returns></returns>
		[System.Obsolete("Unused")]
		int get_item(int index);

		/// <summary>
		/// Number of the item in the given index
		/// </summary>
		/// <param name="index"></param>
		/// <returns></returns>
		[System.Obsolete("Unused")]
		int get_item_count(int index);

		/// <summary>
		/// Gets the quantity of a specific item in storage.
		/// </summary>
		/// <param name="item">The item to check</param>
		/// <returns>Quantity of the item</returns>
		int quantity(int item);

		/// <summary>
		/// Checks if storage contains at least the specified quantity of an item.
		/// </summary>
		/// <param name="item">The item to check</param>
		/// <param name="qty">Quantity to check for</param>
		/// <returns>True if storage has enough of the item</returns>
		//bool has(int item, int qty = 1);

		/// <summary>
		/// Checks if the specified quantity of an item can be added to storage.
		/// </summary>
		/// <param name="item">The item to check</param>
		/// <param name="qty">Quantity to add</param>
		/// <returns>True if the item can be added</returns>
		bool can_add(int item, int qty = 1);

		/// <summary>
		/// Adds an item to storage.
		/// </summary>
		/// <param name="item">The item to add</param>
		/// <param name="qty">Quantity to add</param>
		/// <returns>True if the item was added successfully</returns>
		bool add(int item, int qty = 1);

		/// <summary>
		/// Removes items from storage.
		/// </summary>
		/// <param name="item">The item to remove</param>
		/// <param name="qty">Quantity to remove</param>
		/// <returns>True if any items were removed</returns>
		bool remove(int item, int qty = 1);
	}

	/// <summary>
	/// Implements methods that act on arrays of items. Each element in an item array
	/// is itself an array of [itemID, itemCount].
	/// </summary>
	/// <remarks>
	/// Used by the Bag, PC item storage, and Triple Triad.
	/// </remarks>
	public interface IItemStorageHelper
	{
		/// <summary>
		/// Gets the quantity of a specific item in <paramref name="item"/>.
		/// </summary>
		/// <param name="item">The item to check</param>
		/// <returns>Quantity of the item</returns>
		int quantity(IList<int> items, int item);

		/// <summary>
		/// Checks if the specified quantity of an item can be added to storage.
		/// </summary>
		/// <param name="item">The item to check</param>
		/// <param name="qty">Quantity to add</param>
		/// <returns>True if the item can be added</returns>
		bool can_add(IList<int> items, int max_slots, int max_per_slot, int item, int qty);

		/// <summary>
		/// Adds an item to storage.
		/// </summary>
		/// <param name="item">The item to add</param>
		/// <param name="qty">Quantity to add</param>
		/// <returns>True if the item was added successfully</returns>
		bool add(IList<int> items, int max_slots, int max_per_slot, int item, int qty);

		/// <summary>
		/// Removes items from storage.
		/// </summary>
		/// <remarks>
		/// Deletes an item (items array, max. size per slot, item, no. of items to delete).
		/// </remarks>
		/// <param name="item">The item to remove</param>
		/// <param name="qty">Quantity to remove</param>
		/// <returns>True if any items were removed</returns>
		bool remove(IList<int> items, int item, int qty = 1);
	}
}