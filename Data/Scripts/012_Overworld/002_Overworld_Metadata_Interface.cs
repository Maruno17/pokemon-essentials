using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Interface for global metadata not specific to a map. This interface holds field state data that spans multiple maps.
	/// </summary>
	//public interface IPokemonGlobalMetadata
	public interface IGlobalMetadata
	{
		// Movement
		/// <summary>
		/// Gets or sets whether the player is currently using a bicycle.
		/// </summary>
		bool bicycle { get; set; }

		/// <summary>
		/// Gets or sets whether the player is currently surfing on water.
		/// </summary>
		bool surfing { get; set; }

		/// <summary>
		/// Gets or sets whether the player is currently diving underwater.
		/// </summary>
		bool diving { get; set; }

		/// <summary>
		/// Gets or sets whether the player is currently sliding on ice.
		/// </summary>
		bool ice_sliding { get; set; }

		/// <summary>
		/// Gets or sets whether the player is currently descending a waterfall.
		/// </summary>
		bool descending_waterfall { get; set; }

		/// <summary>
		/// Gets or sets whether the player is currently ascending a waterfall.
		/// </summary>
		bool ascending_waterfall { get; set; }

		/// <summary>
		/// Gets or sets whether the player is currently fishing.
		/// </summary>
		bool fishing { get; set; }

		// Player data
		/// <summary>
		/// Gets or sets the time when the game was started.
		/// </summary>
		DateTime startTime { get; set; }

		/// <summary>
		/// Gets or sets the total number of steps taken by the player.
		/// </summary>
		int stepcount { get; set; }

		/// <summary>
		/// Gets or sets the PC item storage container.
		/// </summary>
		IPCItemStorage pcItemStorage { get; set; }

		/// <summary>
		/// Gets or sets the player's mailbox.
		/// </summary>
		IList<IMail> mailbox { get; set; }

		/// <summary>
		/// Gets or sets the player's phone.
		/// </summary>
		IPhone phone { get; set; }

		/// <summary>
		/// Gets or sets the player's current partner.
		/// </summary>
		ITrainer partner { get; set; }

		/// <summary>
		/// Gets or sets whether the credits have been played.
		/// </summary>
		bool creditsPlayed { get; set; }

		// Pokédex
		/// <summary>
		/// Gets or sets the Dex currently being viewed (-1 is National Dex).
		/// </summary>
		int pokedexDex { get; set; }

		/// <summary>
		/// Gets or sets the last species viewed per Dex.
		/// </summary>
		IList<int> pokedexIndex { get; set; }

		/// <summary>
		/// Gets or sets the Pokédex search mode.
		/// </summary>
		int pokedexMode { get; set; }

		// Day Care
		/// <summary>
		/// Gets or sets the Day Care facility.
		/// </summary>
		IDayCare day_care { get; set; }

		// Special battle modes
		/// <summary>
		/// Gets or sets the current Safari Zone state.
		/// </summary>
		ISafariState safariState { get; set; }

		/// <summary>
		/// Gets or sets the current Bug Contest state.
		/// </summary>
		IBugContestState bugContestState { get; set; }

		/// <summary>
		/// Gets or sets the current challenge state.
		/// </summary>
		IBattleChallenge challenge { get; set; }

		/// <summary>
		/// Gets or sets the last recorded battle.
		/// </summary>
		IRecordedBattleModule lastbattle { get; set; }

		// Events
		/// <summary>
		/// Gets or sets the event variables dictionary.
		/// </summary>
		//IDictionary<object, object> eventvars { get; set; }
		IDictionary<KeyValuePair<int, int>, long> eventvars { get; set; }

		// Affecting the map
		/// <summary>
		/// Gets or sets the bridge state.
		/// </summary>
		int bridge { get; set; }

		/// <summary>
		/// Gets or sets the repel effect remaining.
		/// </summary>
		int repel { get; set; }

		/// <summary>
		/// Gets or sets whether Flash has been used.
		/// </summary>
		bool flashUsed { get; set; }

		/// <summary>
		/// Gets the encounter version.
		/// </summary>
		int encounter_version { get; }

		// Map transfers
		/// <summary>
		/// Gets or sets the healing spot location.
		/// </summary>
		ITilePosition healingSpot { get; set; }

		/// <summary>
		/// Gets or sets the escape point coordinates.
		/// </summary>
		//IList<object> escapePoint { get; set; }
		ITilePosition escapePoint { get; set; }

		/// <summary>
		/// Gets or sets the Pokémon Center map ID.
		/// </summary>
		int pokecenterMapId { get; set; }

		/// <summary>
		/// Gets or sets the Pokémon Center X coordinate.
		/// </summary>
		int pokecenterX { get; set; }

		/// <summary>
		/// Gets or sets the Pokémon Center Y coordinate.
		/// </summary>
		int pokecenterY { get; set; }

		/// <summary>
		/// Gets or sets the Pokémon Center direction.
		/// </summary>
		int pokecenterDirection { get; set; }

		// Movement history
		/// <summary>
		/// Gets or sets the list of visited maps.
		/// </summary>
		//IList<object> visitedMaps { get; set; }
		IDictionary<int, bool> visitedMaps { get; set; }

		/// <summary>
		/// Gets or sets the map trail history.
		/// </summary>
		IList<int> mapTrail { get; set; }

		// Counters
		/// <summary>
		/// Gets or sets the happiness steps counter.
		/// </summary>
		int happinessSteps { get; set; }

		/// <summary>
		/// Gets or sets the Pokérus time.
		/// </summary>
		DateTime? pokerusTime { get; set; }

		// Save file
		/// <summary>
		/// Gets or sets whether safe save is enabled.
		/// </summary>
		bool safesave { get; set; }

		IGlobalMetadata initialize();

		/// <summary>
		/// Sets the encounter version and updates encounter data if necessary.
		/// </summary>
		/// <param name="value">The new encounter version</param>
		void encounter_version_set(int value);

		/// <summary>
		/// Determines whether the player is in a forced movement state.
		/// </summary>
		/// <returns>True if the player is ice sliding or using waterfalls</returns>
		bool forced_movement();
	}

	/// <summary>
	/// Interface for keeping track of erased and moved events so their position can remain after a game is saved and loaded.
	/// This interface also includes variables that should remain valid only for the current map.
	/// </summary>
	//public interface IPokemonMapMetadata
	public interface IMapMetadata
	{
		/// <summary>
		/// Gets the dictionary of erased events.
		/// </summary>
		IDictionary<int, bool> erasedEvents { get; }

		/// <summary>
		/// Gets the dictionary of moved events.
		/// </summary>
		IDictionary<int, IList<object>> movedEvents { get; }

		/// <summary>
		/// Gets or sets whether Strength has been used on this map.
		/// </summary>
		bool strengthUsed { get; set; }

		/// <summary>
		/// Gets or sets whether the encounter rate is lowered (Black Flute's old effect).
		/// </summary>
		bool lower_encounter_rate { get; set; }

		/// <summary>
		/// Gets or sets whether the encounter rate is higher (White Flute's old effect).
		/// </summary>
		bool higher_encounter_rate { get; set; }

		/// <summary>
		/// Gets or sets whether wild Pokémon levels are lowered (White Flute's new effect).
		/// </summary>
		bool lower_level_wild_pokemon { get; set; }

		/// <summary>
		/// Gets or sets whether wild Pokémon levels are higher (Black Flute's new effect).
		/// </summary>
		bool higher_level_wild_pokemon { get; set; }

		IMapMetadata initialize();

		/// <summary>
		/// Clears all map metadata.
		/// </summary>
		void clear();

		/// <summary>
		/// Adds an event to the erased events list.
		/// </summary>
		/// <param name="eventID">The ID of the event to erase</param>
		void addErasedEvent(int eventID);

		/// <summary>
		/// Adds an event to the moved events list.
		/// </summary>
		/// <param name="eventID">The ID of the event to track as moved</param>
		void addMovedEvent(int eventID);

		/// <summary>
		/// Updates the current map based on stored event changes.
		/// </summary>
		void updateMap();
	}
}