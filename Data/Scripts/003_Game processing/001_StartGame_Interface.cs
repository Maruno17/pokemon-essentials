using System;
using System.Collections;
using System.Collections.Generic;
using PokemonEssentials;
using PokemonEssentials.Framework;
using PokemonEssentials.RPGMaker;
using PokemonEssentials.RPGMaker.Kernel;

namespace PokemonEssentials
{
	/// <summary>
	/// The Game module contains methods for saving and loading the game.
	/// </summary>
	public interface IGameStart : IGame {
		/// <summary>
		/// Initializes various global variables and loads the game data.
		/// </summary>
		IGameStart initialize();
		//void Initialize();

		/// <summary>
		/// Loads bootup data from save file (if it exists) or creates bootup data (if it doesn't).
		/// </summary>
		void set_up_system();
		//void SetUpSystem();

		/// <summary>
		/// Called when starting a new game. Initializes global variables
		/// and transfers the player into the map scene.
		/// </summary>
		void start_new();
		//void StartNewGame();

		/// <summary>
		/// Loads the game from the given save data and starts the map scene.
		/// </summary>
		/// <param name="save_data">hash containing the save data</param>
		/// <exception cref="SaveData.InvalidValueError">if an invalid value is being loaded</exception>
		void load(ISaveData save_data);
		//void LoadGame(IDictionary<string, object> saveData);

		/// <summary>
		/// Loads and validates the map. Called when loading a saved game.
		/// </summary>
		/// <exception cref="System.IO.IOException">Thrown when map file cannot be loaded</exception>
		/// <exception cref="System.ArgumentException">Thrown when map data is invalid</exception>
		void load_map();
		//void LoadMap();

		/// <summary>
		/// Saves the game. Returns whether the operation was successful.
		/// </summary>
		/// <param name="save_file">The save file path. Must not be null or empty.</param>
		/// <param name="safe">Whether PokemonGlobal.safesave should be set to true</param>
		/// <returns>Whether the operation was successful</returns>
		/// <exception cref="ArgumentNullException">Thrown when save_file is null</exception>
		/// <exception cref="ArgumentException">Thrown when save_file is empty</exception>
		/// <exception cref="SaveData.InvalidValueError">if an invalid value is being saved</exception>
		bool save(string save_file = null, bool safe = false);
		//bool SaveGame(string saveFile = null, bool safe = false);
	}
}