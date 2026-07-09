using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Interface for a Pokemon storage box that can hold a fixed number of Pokemon.
	/// Provides methods for managing Pokemon within a single box.
	/// </summary>
	//public interface IPokemonBox
	public interface IGameStorageBox : IPokemonStorageConstants, IList<IPokemon>, ICollection<IPokemon>, IEnumerable<IPokemon>
	{
		/// <summary>
		/// Gets the array of Pokemon in this box.
		/// </summary>
		IList<IPokemon> pokemon { get; }

		/// <summary>
		/// Gets or sets the name of this box.
		/// </summary>
		string name { get; set; }

		/// <summary>
		/// Gets or sets the background wallpaper index for this box.
		/// </summary>
		int background { get; set; }

		/// <summary>
		/// Gets the total number of slots in this box.
		/// </summary>
		int length { get; }

		/// <summary>
		/// Gets the number of Pokemon currently in this box.
		/// </summary>
		int nitems();

		/// <summary>
		/// Determines if this box is completely full.
		/// </summary>
		/// <returns>True if all slots are occupied, false otherwise.</returns>
		bool full();

		/// <summary>
		/// Determines if this box is completely empty.
		/// </summary>
		/// <returns>True if no slots are occupied, false otherwise.</returns>
		bool empty();

		/// <summary>
		/// Gets the Pokemon at the specified index.
		/// </summary>
		/// <param name="i">The index to get the Pokemon from.</param>
		/// <returns>The Pokemon at the index, or null if empty.</returns>
		IPokemon this[int i] { get; set; }

		/// <summary>
		/// Iterates through each Pokemon in the box.
		/// </summary>
		/// <param name="action">The action to perform on each Pokemon.</param>
		void each(Action<object> action);

		/// <summary>
		/// Clears all Pokemon from this box.
		/// </summary>
		void clear();
	}

	/// <summary>
	/// Interface for the main Pokemon storage system managing multiple boxes.
	/// Provides methods for storing, moving, and organizing Pokemon across boxes.
	/// </summary>
	//public interface IPokemonStorage
	public interface IGameStorage
	{
		/// <summary>
		/// Gets the array of storage boxes.
		/// </summary>
		IList<IGameStorageBox> boxes { get; }

		/// <summary>
		/// Gets or sets the index of the currently selected box.
		/// </summary>
		int currentBox { get; set; }

		/// <summary>
		/// Sets the array of unlocked wallpapers.
		/// </summary>
		//IList<bool> unlockedWallpapers { set; }

		/// <summary>
		/// the array of unlocked wallpapers.
		/// </summary>
		/// Gets the unlocked wallpapers array.
		/// <returns>Array of boolean values indicating which wallpapers are unlocked.</returns>
		IList<bool> unlockedWallpapers { get; set; }

		/// <summary>
		/// Gets all available wallpaper names.
		/// </summary>
		/// <returns>Array of wallpaper names.</returns>
		//IList<string> allWallpapers();
		IList<KeyValuePair<int,string>> allWallpapers();

		/// <summary>
		/// Checks if a specific wallpaper is available for use.
		/// </summary>
		/// <param name="i">The wallpaper index to check.</param>
		/// <returns>True if the wallpaper is available, false otherwise.</returns>
		bool isAvailableWallpaper(int i);

		/// <summary>
		/// Gets arrays of available wallpaper names and their corresponding IDs.
		/// </summary>
		/// <returns>Tuple containing names array and IDs array.</returns>
		//(IList<string> names, IList<int> ids) availableWallpapers();
		IDictionary<int,string> availableWallpapers();

		/// <summary>
		/// Gets the player's party Pokemon.
		/// </summary>
		IList<IPokemon> party { get; }

		/// <summary>
		/// Determines if the player's party is full.
		/// </summary>
		/// <returns>True if the party is full, false otherwise.</returns>
		bool party_full();

		/// <summary>
		/// Gets the maximum number of boxes in storage.
		/// </summary>
		/// <returns>The total number of boxes.</returns>
		int maxBoxes();

		/// <summary>
		/// Gets the maximum number of Pokemon that can be stored in a specific box.
		/// </summary>
		/// <param name="box">The box index (-1 for party).</param>
		/// <returns>The maximum number of Pokemon for the box.</returns>
		int maxPokemon(int box);

		/// <summary>
		/// Determines if all storage boxes are completely full.
		/// </summary>
		/// <returns>True if all boxes are full, false otherwise.</returns>
		bool full();

		/// <summary>
		/// Finds the first free position in the specified box.
		/// </summary>
		/// <param name="box">The box to search (-1 for party).</param>
		/// <returns>The index of the first free slot, or -1 if full.</returns>
		int FirstFreePos(int box);

		/// <summary>
		/// Gets a box or Pokemon at specified coordinates.
		/// </summary>
		/// <param name="x">The box index (-1 for party).</param>
		/// <param name="y">The slot index (optional).</param>
		/// <returns>The box or Pokemon at the specified location.</returns>
		IPokemon this[int x, int? y = null] { get; set; }

		/// <summary>
		/// Copies a Pokemon from one location to another.
		/// </summary>
		/// <param name="boxDst">The destination box index.</param>
		/// <param name="indexDst">The destination slot index.</param>
		/// <param name="boxSrc">The source box index.</param>
		/// <param name="indexSrc">The source slot index.</param>
		/// <returns>True if the copy was successful, false otherwise.</returns>
		bool Copy(int boxDst, int indexDst, int boxSrc, int indexSrc);

		/// <summary>
		/// Moves a Pokemon from one location to another.
		/// </summary>
		/// <param name="boxDst">The destination box index.</param>
		/// <param name="indexDst">The destination slot index.</param>
		/// <param name="boxSrc">The source box index.</param>
		/// <param name="indexSrc">The source slot index.</param>
		/// <returns>True if the move was successful, false otherwise.</returns>
		bool Move(int boxDst, int indexDst, int boxSrc, int indexSrc);

		/// <summary>
		/// Moves a newly caught Pokemon to the party.
		/// </summary>
		/// <param name="pkmn">The Pokemon to move to the party.</param>
		/// <returns>True if successful, false if party is full.</returns>
		bool MoveCaughtToParty(IPokemon pkmn);

		/// <summary>
		/// Moves a newly caught Pokemon to a specific box.
		/// </summary>
		/// <param name="pkmn">The Pokemon to move to the box.</param>
		/// <param name="box">The box index to move to.</param>
		/// <returns>True if successful, false if box is full.</returns>
		bool MoveCaughtToBox(IPokemon pkmn, int box);

		/// <summary>
		/// Stores a newly caught Pokemon in the next available slot.
		/// </summary>
		/// <param name="pkmn">The Pokemon to store.</param>
		/// <returns>The box index where the Pokemon was stored, or -1 if storage is full.</returns>
		int StoreCaught(IPokemon pkmn);

		/// <summary>
		/// Deletes a Pokemon from the specified location.
		/// </summary>
		/// <param name="box">The box index (-1 for party).</param>
		/// <param name="index">The slot index.</param>
		void Delete(int box, int index);

		/// <summary>
		/// Clears all Pokemon from all storage boxes.
		/// </summary>
		void clear();
	}

	/// <summary>
	/// Regional Storage scripts.
	/// </summary>
	/// <remarks>
	/// Interface for regional Pokemon storage that manages different storage systems per region.
	/// Automatically switches storage based on the current map region.
	/// </remarks>
	public interface IRegionalStorage
	{
		IRegionalStorage initialize();

		/// <summary>
		/// Gets the storage system for the current region.
		/// </summary>
		/// <returns>The Pokemon storage for the current region.</returns>
		IGameStorage getCurrentStorage();

		/// <summary>
		/// Gets all available wallpaper names from the current storage.
		/// </summary>
		/// <returns>Array of wallpaper names.</returns>
		//IList<string> allWallpapers();
		IList<KeyValuePair<int,string>> allWallpapers();

		/// <summary>
		/// Gets available wallpapers from the current storage.
		/// </summary>
		/// <returns>Tuple containing names array and IDs array.</returns>
		//(IList<string> names, IList<int> ids) availableWallpapers();
		IDictionary<int,string> availableWallpapers();

		/// <summary>
		/// Unlocks a wallpaper in the current storage.
		/// </summary>
		/// <param name="index">The wallpaper index to unlock.</param>
		void unlockWallpaper(int index);

		/// <summary>
		/// Gets the boxes from the current storage.
		/// </summary>
		IList<IGameStorageBox> boxes { get; }

		/// <summary>
		/// Gets the party from the current storage.
		/// </summary>
		IList<IPokemon> party { get; }

		/// <summary>
		/// Determines if the party is full in the current storage.
		/// </summary>
		/// <returns>True if the party is full, false otherwise.</returns>
		bool party_full();

		/// <summary>
		/// Gets the maximum number of boxes in the current storage.
		/// </summary>
		/// <returns>The total number of boxes.</returns>
		int maxBoxes();

		/// <summary>
		/// Gets the maximum number of Pokemon for a box in the current storage.
		/// </summary>
		/// <param name="box">The box index to check.</param>
		/// <returns>The maximum number of Pokemon for the box.</returns>
		int maxPokemon(int box);

		/// <summary>
		/// Determines if the current storage is completely full.
		/// </summary>
		/// <returns>True if all boxes are full, false otherwise.</returns>
		bool full();

		/// <summary>
		/// Gets or sets the current box index in the current storage.
		/// </summary>
		int currentBox { get; set; }

		/// <summary>
		/// Gets a box or Pokemon at specified coordinates in the current storage.
		/// </summary>
		/// <param name="x">The box index (-1 for party).</param>
		/// <param name="y">The slot index (optional).</param>
		/// <returns>The box or Pokemon at the specified location.</returns>
		IPokemon this[int x, int? y = null] { get; set; }

		/// <summary>
		/// Finds the first free position in the specified box of the current storage.
		/// </summary>
		/// <param name="box">The box to search (-1 for party).</param>
		/// <returns>The index of the first free slot, or -1 if full.</returns>
		int FirstFreePos(int box);

		/// <summary>
		/// Copies a Pokemon from one location to another in the current storage.
		/// </summary>
		/// <param name="boxDst">The destination box index.</param>
		/// <param name="indexDst">The destination slot index.</param>
		/// <param name="boxSrc">The source box index.</param>
		/// <param name="indexSrc">The source slot index.</param>
		/// <returns>True if the copy was successful, false otherwise.</returns>
		bool Copy(int boxDst, int indexDst, int boxSrc, int indexSrc);

		/// <summary>
		/// Moves a Pokemon from one location to another in the current storage.
		/// </summary>
		/// <param name="boxDst">The destination box index.</param>
		/// <param name="indexDst">The destination slot index.</param>
		/// <param name="boxSrc">The source box index.</param>
		/// <param name="indexSrc">The source slot index.</param>
		/// <returns>True if the move was successful, false otherwise.</returns>
		bool Move(int boxDst, int indexDst, int boxSrc, int indexSrc);

		/// <summary>
		/// Moves a newly caught Pokemon to the party in the current storage.
		/// </summary>
		/// <param name="pkmn">The Pokemon to move to the party.</param>
		/// <returns>True if successful, false if party is full.</returns>
		bool MoveCaughtToParty(IPokemon pkmn);

		/// <summary>
		/// Moves a newly caught Pokemon to a specific box in the current storage.
		/// </summary>
		/// <param name="pkmn">The Pokemon to move to the box.</param>
		/// <param name="box">The box index to move to.</param>
		/// <returns>True if successful, false if box is full.</returns>
		bool MoveCaughtToBox(IPokemon pkmn, int box);

		/// <summary>
		/// Stores a newly caught Pokemon in the next available slot of the current storage.
		/// </summary>
		/// <param name="pkmn">The Pokemon to store.</param>
		/// <returns>The box index where the Pokemon was stored, or -1 if storage is full.</returns>
		int StoreCaught(IPokemon pkmn);

		/// <summary>
		/// Deletes a Pokemon from the specified location in the current storage.
		/// </summary>
		/// <param name="box">The box index (-1 for party).</param>
		/// <param name="index">The slot index.</param>
		void Delete(int box, int index);
	}

	/// <summary>
	/// Interface for global Pokemon storage utility functions.
	/// Provides convenience methods for working with wallpapers and iterating through storage.
	/// </summary>
	public interface IMainPokemonStorageUtilities : IMain
	{
		/// <summary>
		/// Unlocks a wallpaper in the global storage system.
		/// </summary>
		/// <param name="index">The wallpaper index to unlock.</param>
		void UnlockWallpaper(int index);

		/// <summary>
		/// Locks a wallpaper in the global storage system.
		/// </summary>
		/// <remarks>
		/// NOTE: I don't know why you'd want to do this, but here you go.
		/// </remarks>
		/// <param name="index">The wallpaper index to lock.</param>
		void LockWallpaper(int index);

		/// <summary>
		/// Iterates through every Pokemon (including eggs) in storage and party.
		/// </summary>
		/// <remarks>
		/// Yields every Pokémon/egg in storage in turn.
		/// </remarks>
		/// <param name="action">The action to perform on each Pokemon and its box index.</param>
		void EachPokemon(Action<IPokemon, int> action);

		/// <summary>
		/// Iterates through every non-egg Pokemon in storage and party.
		/// </summary>
		/// <remarks>
		/// Yields every Pokémon in storage in turn.
		/// </remarks>
		/// <param name="action">The action to perform on each Pokemon and its box index.</param>
		void EachNonEggPokemon(Action<IPokemon, int> action);
	}

	/// <summary>
	/// Interface for Pokemon storage constants and configuration.
	/// Defines box dimensions and storage system limits.
	/// </summary>
	public interface IPokemonStorageConstants
	{
		/// <summary>
		/// The width of a storage box (number of columns).
		/// </summary>
		int BOX_WIDTH { get; }

		/// <summary>
		/// The height of a storage box (number of rows).
		/// </summary>
		int BOX_HEIGHT { get; }

		/// <summary>
		/// The total number of slots in a storage box (width × height).
		/// </summary>
		int BOX_SIZE { get; }

		/// <summary>
		/// The number of basic wallpapers available by default.
		/// </summary>
		int BASICWALLPAPERQTY { get; }
	}
}