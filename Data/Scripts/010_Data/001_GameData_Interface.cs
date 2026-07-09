using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials.Data
{
	/// <summary>
	/// A mixin module for data classes which provides common class methods (called
	/// by GameData.Thing.method) that provide access to data held within.
	/// Assumes the data class's data is stored in a class constant hash called DATA.
	/// For data that is known by a symbol or an ID number.
	/// </summary>
	[System.Obsolete("Used as abstract class `Enumeration`")]
	public interface IClassMethods {
	//	public void schema();
	//
	//	public void register(hash);
	//
	//	/// <param name="other"> | Symbol, this, String, Integer</param>
	//	// @return [Boolean] whether the given other is defined as a this
	//	public bool exists(Symbol other);
	//
	//	/// <param name="other"> | Symbol, this, String, Integer</param>
	//	// @return [this]
	//	public void get(Symbol other);
	//
	//	/// <param name="other"> | Symbol, this, String, Integer</param>
	//	// @return [this, null]
	//	public void try_get(Symbol other);
	//
	//	// Returns the array of keys for the data.
	//	// @return [Array]
	//	public void keys();
	//
	//	// Yields all data in order of their id_number.
	//	public void each();
	//
	//	public void count();
	//
	//	public void load();
	//
	//	public void save();
	}

	/// <summary>
	/// A mixin module for data classes which provides common class methods (called
	/// by GameData.Thing.method) that provide access to data held within.
	/// Assumes the data class's data is stored in a class constant hash called DATA.
	/// For data that is only known by a symbol.
	/// </summary>
	[System.Obsolete("Used as abstract class `Enumeration`")]
	public interface IClassMethodsSymbols {
	//	public void schema();
	//
	//	public void register(hash);
	//
	//	/// <param name="other"> | Symbol, this, String</param>
	//	// @return [Boolean] whether the given other is defined as a this
	//	public bool exists(Symbol other);
	//
	//	/// <param name="other"> | Symbol, this, String</param>
	//	// @return [this]
	//	public void get(Symbol other);
	//
	//	/// <param name="other"> | Symbol, this, String</param>
	//	// @return [this, null]
	//	public void try_get(Symbol other);
	//
	//	// Returns the array of keys for the data.
	//	// @return [Array]
	//	public void keys();
	//
	//	// Yields all data in the order they were defined.
	//	public void each();
	//
	//	// Yields all data in alphabetical order.
	//	public void each_alphabetically();
	//
	//	public void count();
	//
	//	public void load();
	//
	//	public void save();
	}

	/// <summary>
	/// A mixin module for data classes which provides common class methods (called
	/// by GameData.Thing.method) that provide access to data held within.
	/// Assumes the data class's data is stored in a class constant hash called DATA.
	/// For data that is only known by an ID number.
	/// </summary>
	[System.Obsolete("Used as abstract class `Enumeration`")]
	public interface IClassMethodsIDNumbers {
	//	public void schema();
	//
	//	public void register(hash);
	//
	//	/// <param name="other"> | this, Integer</param>
	//	// @return [Boolean] whether the given other is defined as a this
	//	public bool exists(this other);
	//
	//	/// <param name="other"> | this, Integer</param>
	//	// @return [this]
	//	public void get(this other);
	//
	//	public void try_get(other);
	//
	//	// Returns the array of keys for the data.
	//	// @return [Array]
	//	public void keys();
	//
	//	// Yields all data in numerical order.
	//	public void each();
	//
	//	public void count();
	//
	//	public void load();
	//
	//	public void save();
	}

	/// <summary>
	/// A mixin module for data classes which provides common instance methods
	/// (called by thing.method) that analyse the data of a particular thing which
	/// the instance represents.
	/// </summary>
	[System.Obsolete]
	public interface IInstanceMethods {
		// <param name="other"> | Symbol, this.class, String, Integer</param>
		// @return [Boolean] whether other represents the same thing as this thing
		//public void ==(Symbol other();

		string get_property_for_PBS(string key);
	}

	/// <summary>
	/// Represents the game data system.
	/// </summary>
	/// <remarks>
	/// This interface defines the functionality for managing game data,
	/// including data loading, saving, and manipulation.
	/// </remarks>
	public interface IGameData
	{
		/// <summary>
		/// A bulk loader method for all data stored in .dat files in the Data folder.
		/// </summary>
		void load_all();

		object get_all_data_filenames();

		object get_all_pbs_base_filenames();
		/*
		/// <summary>
		/// Gets or sets the game data.
		/// </summary>
		IDictionary<string, object> Data { get; }

		/// <summary>
		/// Gets or sets the game data version.
		/// </summary>
		string Version { get; set; }

		/// <summary>
		/// Gets or sets whether the game data is loaded.
		/// </summary>
		bool IsLoaded { get; set; }

		/// <summary>
		/// Gets or sets whether the game data is saved.
		/// </summary>
		bool IsSaved { get; set; }

		/// <summary>
		/// Initializes the game data system.
		/// </summary>
		void Initialize();

		/// <summary>
		/// Disposes of the game data system and its resources.
		/// </summary>
		void Dispose();

		/// <summary>
		/// Checks if the game data system has been disposed.
		/// </summary>
		/// <returns>True if the game data system has been disposed, false otherwise.</returns>
		bool IsDisposed();

		/// <summary>
		/// Updates the game data system's state.
		/// </summary>
		void Update();

		/// <summary>
		/// Refreshes the game data system's state.
		/// </summary>
		/// <param name="force_refresh">Whether to force a complete refresh.</param>
		void Refresh(bool force_refresh = false);

		/// <summary>
		/// Loads the game data.
		/// </summary>
		void Load();

		/// <summary>
		/// Saves the game data.
		/// </summary>
		void Save();

		/// <summary>
		/// Gets a value from the game data.
		/// </summary>
		/// <param name="key">The key of the value to get.</param>
		/// <returns>The value associated with the key.</returns>
		object GetValue(string key);

		/// <summary>
		/// Sets a value in the game data.
		/// </summary>
		/// <param name="key">The key of the value to set.</param>
		/// <param name="value">The value to set.</param>
		void SetValue(string key, object value);

		/// <summary>
		/// Gets whether a key exists in the game data.
		/// </summary>
		/// <param name="key">The key to check.</param>
		/// <returns>True if the key exists, false otherwise.</returns>
		bool HasKey(string key);

		/// <summary>
		/// Removes a key from the game data.
		/// </summary>
		/// <param name="key">The key to remove.</param>
		void RemoveKey(string key);

		/// <summary>
		/// Clears the game data.
		/// </summary>
		void Clear();

		/// <summary>
		/// Gets the game data version.
		/// </summary>
		/// <returns>The game data version.</returns>
		string GetVersion();

		/// <summary>
		/// Sets the game data version.
		/// </summary>
		/// <param name="version">The version to set.</param>
		void SetVersion(string version);

		/// <summary>
		/// Gets whether the game data is loaded.
		/// </summary>
		/// <returns>True if the game data is loaded, false otherwise.</returns>
		bool IsLoadedNow();

		/// <summary>
		/// Gets whether the game data is saved.
		/// </summary>
		/// <returns>True if the game data is saved, false otherwise.</returns>
		bool IsSavedNow();

		/// <summary>
		/// Gets the game data as a dictionary.
		/// </summary>
		/// <returns>The game data dictionary.</returns>
		IDictionary<string, object> GetData();

		/// <summary>
		/// Sets the game data from a dictionary.
		/// </summary>
		/// <param name="data">The game data dictionary to set.</param>
		void SetData(IDictionary<string, object> data);

		/// <summary>
		/// Gets the game data as a JSON string.
		/// </summary>
		/// <returns>The game data as a JSON string.</returns>
		string GetDataAsJson();

		/// <summary>
		/// Sets the game data from a JSON string.
		/// </summary>
		/// <param name="json">The game data as a JSON string.</param>
		void SetDataFromJson(string json);

		/// <summary>
		/// Gets the game data as a binary string.
		/// </summary>
		/// <returns>The game data as a binary string.</returns>
		byte[] GetDataAsBinary();

		/// <summary>
		/// Sets the game data from a binary string.
		/// </summary>
		/// <param name="binary">The game data as a binary string.</param>
		void SetDataFromBinary(byte[] binary);

		/// <summary>
		/// Gets the game data as a string.
		/// </summary>
		/// <returns>The game data as a string.</returns>
		string GetDataAsString();

		/// <summary>
		/// Sets the game data from a string.
		/// </summary>
		/// <param name="str">The game data as a string.</param>
		void SetDataFromString(string str);

		/// <summary>
		/// Gets the game data as a file.
		/// </summary>
		/// <param name="path">The path to save the file to.</param>
		void GetDataAsFile(string path);

		/// <summary>
		/// Sets the game data from a file.
		/// </summary>
		/// <param name="path">The path to load the file from.</param>
		void SetDataFromFile(string path);

		/// <summary>
		/// Gets the game data as a stream.
		/// </summary>
		/// <returns>The game data as a stream.</returns>
		System.IO.Stream GetDataAsStream();

		/// <summary>
		/// Sets the game data from a stream.
		/// </summary>
		/// <param name="stream">The game data as a stream.</param>
		void SetDataFromStream(System.IO.Stream stream);

		/// <summary>
		/// Gets the game data as a memory stream.
		/// </summary>
		/// <returns>The game data as a memory stream.</returns>
		System.IO.MemoryStream GetDataAsMemoryStream();

		/// <summary>
		/// Sets the game data from a memory stream.
		/// </summary>
		/// <param name="stream">The game data as a memory stream.</param>
		void SetDataFromMemoryStream(System.IO.MemoryStream stream);

		/// <summary>
		/// Gets the game data as a byte array.
		/// </summary>
		/// <returns>The game data as a byte array.</returns>
		byte[] GetDataAsByteArray();

		/// <summary>
		/// Sets the game data from a byte array.
		/// </summary>
		/// <param name="bytes">The game data as a byte array.</param>
		void SetDataFromByteArray(byte[] bytes);

		/// <summary>
		/// Gets the game data as a string array.
		/// </summary>
		/// <returns>The game data as a string array.</returns>
		string[] GetDataAsStringArray();

		/// <summary>
		/// Sets the game data from a string array.
		/// </summary>
		/// <param name="strings">The game data as a string array.</param>
		void SetDataFromStringArray(string[] strings);

		/// <summary>
		/// Gets the game data as an object array.
		/// </summary>
		/// <returns>The game data as an object array.</returns>
		object[] GetDataAsObjectArray();

		/// <summary>
		/// Sets the game data from an object array.
		/// </summary>
		/// <param name="objects">The game data as an object array.</param>
		void SetDataFromObjectArray(object[] objects);

		/// <summary>
		/// Gets the game data as a list.
		/// </summary>
		/// <returns>The game data as a list.</returns>
		IList GetDataAsList();

		/// <summary>
		/// Sets the game data from a list.
		/// </summary>
		/// <param name="list">The game data as a list.</param>
		void SetDataFromList(IList list);

		/// <summary>
		/// Gets the game data as a collection.
		/// </summary>
		/// <returns>The game data as a collection.</returns>
		ICollection GetDataAsCollection();

		/// <summary>
		/// Sets the game data from a collection.
		/// </summary>
		/// <param name="collection">The game data as a collection.</param>
		void SetDataFromCollection(ICollection collection);

		/// <summary>
		/// Gets the game data as an enumerable.
		/// </summary>
		/// <returns>The game data as an enumerable.</returns>
		IEnumerable GetDataAsEnumerable();

		/// <summary>
		/// Sets the game data from an enumerable.
		/// </summary>
		/// <param name="enumerable">The game data as an enumerable.</param>
		void SetDataFromEnumerable(IEnumerable enumerable);

		/// <summary>
		/// Gets the game data as an enumerator.
		/// </summary>
		/// <returns>The game data as an enumerator.</returns>
		IEnumerator GetDataAsEnumerator();

		/// <summary>
		/// Sets the game data from an enumerator.
		/// </summary>
		/// <param name="enumerator">The game data as an enumerator.</param>
		void SetDataFromEnumerator(IEnumerator enumerator);*/
	}
}