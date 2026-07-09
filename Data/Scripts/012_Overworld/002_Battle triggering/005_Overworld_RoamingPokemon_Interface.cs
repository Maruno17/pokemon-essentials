using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Interface for global metadata related to roaming Pokémon.
	/// </summary>
	//public interface IPokemonGlobalMetadataRoaming //: IPokemonGlobalMetadata
	public interface IGlobalMetadataRoaming : IGlobalMetadata
	{
		/// <summary>
		/// Gets or sets the current position of all roaming Pokémon.
		/// Dictionary mapping roamer index to map ID.
		/// </summary>
		IDictionary<int, int> roamPosition { get; set; }

		/// <summary>
		/// Gets or sets whether a roamer has been encountered on the current map.
		/// </summary>
		bool roamedAlready { get; set; }

		/// <summary>
		/// Gets or sets the current roaming encounter data.
		/// </summary>
		IRoamingSpeciesData[] roamEncounter { get; set; }

		/// <summary>
		/// Gets or sets the array of roaming Pokémon instances.
		/// </summary>
		IRoamingSpeciesData[] roamPokemon { get; set; }

		/// <summary>
		/// Gets the array indicating which roaming Pokémon have been caught.
		/// Initializes to empty array if not set.
		/// </summary>
		bool[] roamPokemonCaught { get; }
	}

	/// <summary>
	/// Interface for Game_Temp roaming Pokémon data.
	/// </summary>
	//public interface IGameTempRoaming : IGameTemp
	public interface ITempMetadataRoaming : ITempMetadata
	{
		/// <summary>
		/// Gets or sets the index of the roaming Pokémon to encounter next.
		/// </summary>
		int? roamer_index_for_encounter { get; set; }
	}

	/// <summary>
	/// Making roaming Pokémon roam around.
	/// </summary>
	public interface IMainOverworldRoamingPokemon : IMain
	{
		#region Interface for roaming Pokémon management functions.
		/// <summary>
		/// Resets all roaming Pokémon that were defeated without having been caught.
		/// </summary>
		void ResetAllRoamers();

		/// <summary>
		/// Gets the roaming areas for a particular Pokémon.
		/// </summary>
		/// <param name="idxRoamer">Index of the roaming Pokémon</param>
		/// <returns>Dictionary of roaming areas or default areas</returns>
		IDictionary<int, IList<int>> RoamingAreas(int idxRoamer);

		/// <summary>
		/// Puts a roamer in a completely random map available to it.
		/// </summary>
		/// <param name="index">Index of the roaming Pokémon</param>
		void RandomRoam(int index);

		/// <summary>
		/// Makes all roaming Pokémon roam to another map.
		/// </summary>
		void RoamPokemon();

		/// <summary>
		/// Makes a single roaming Pokémon roam to another map.
		/// Doesn't roam if it isn't currently possible to encounter it (i.e. its Game Switch is off).
		/// </summary>
		/// <seealso cref="ISettings.ROAMING_SPECIES"/>
		/// <param name="idxRoamer">Index of the roaming Pokémon</param>
		void RoamPokemonOne(int idxRoamer);

		/// <summary>
		/// When the player moves to a new map (with a different name), make all roaming
		/// Pokémon roam.
		/// </summary>
		/// <example>
		/// <code>
		/// EventHandlers.add(:on_enter_map, :move_roaming_pokemon,
		///   proc { |old_map_id|
		///     # Get and compare map names
		///     mapInfos = pbLoadMapInfos
		///     next if mapInfos && old_map_id > 0 && mapInfos[old_map_id] &&
		///             mapInfos[old_map_id].name && $game_map.name == mapInfos[old_map_id].name
		///     # Make roaming Pokémon roam
		///     pbRoamPokemon
		///     $PokemonGlobal.roamedAlready = false
		///   }
		/// )
		/// </code>
		/// </example>
		/// <param name="map_id"></param>
		/// <seealso cref="IEvents.OnEnterMap"/>
		/// <seealso cref="IEvents.OnMapChange"/>
		/// <seealso cref="EventArg.IOnMapChangeEventArgs"/>
		void OnEnterMapTrigger_move_roaming_pokemon(int map_id);
		#endregion

		#region Interface for roaming encounter method checking.
		/// <summary>
		/// Returns whether the given roaming method is allowed for the current encounter type.
		/// </summary>
		/// <param name="roamer_method">The roamer method to check (0=any step, 1=walking, 2=surfing, 3=fishing, 4=water-based)</param>
		/// <returns>True if the roaming method is allowed</returns>
		bool RoamingMethodAllowed(int roamer_method);

		/// <summary>
		/// </summary>
		/// <param name="encounter"></param>
		/// <seealso cref="IEvents.OnWildSpeciesChosen"/>
		/// <seealso cref="EventArg.IOnWildPokemonCreateEventArgs"/>
		//void OnWildSpeciesChosenTrigger_roaming_pokemon(int species, int level);
		void OnWildSpeciesChosenTrigger_roaming_pokemon(IEncounterPokemonData encounter);
		#endregion

		#region Interface for roaming Pokémon battle functionality.
		/// <summary>
		/// </summary>
		/// <example>
		/// <code>
		/// EventHandlers.add(:on_calling_wild_battle, :roaming_pokemon,
		///   proc { |pkmn, handled|
		///     # handled is an array: [nil]. If [true] or [false], the battle has already
		///     # been overridden (the boolean is its outcome), so don't do anything that
		///     # would override it again
		///     next if !handled[0].nil?
		///     next if !$PokemonGlobal.roamEncounter || $game_temp.roamer_index_for_encounter.nil?
		///     handled[0] = pbRoamingPokemonBattle(pkmn)
		///   }
		/// )
		/// </code>
		/// </example>
		/// <param name="pkmn"></param>
		/// <param name="handled">
		/// If [true] or [false], the battle has already been overridden
		/// (the boolean is its outcome), so don't do anything that
		/// would override it again
		/// </param>
		/// <seealso cref="IEvents.OnCallingWildBattle"/>
		/// <seealso cref="EventArg.IOnWildBattleOverrideEventArgs"/>
		//void OnCallingWildBattleTrigger_roaming_pokemon(IEncounterPokemonData encounter, ref bool can_battle);
		void OnCallingWildBattleTrigger_roaming_pokemon(IEncounterPokemonData pkmn, ref bool? handled);

		/// <summary>
		/// Conducts a battle with a roaming Pokémon.
		/// </summary>
		/// <param name="pkmn">The Pokémon or species to battle</param>
		/// <param name="level">The level of the Pokémon (if pkmn is not a Pokémon instance)</param>
		/// <returns>True if the player won or caught the Pokémon, false otherwise</returns>
		bool RoamingPokemonBattle(IPokemon pkmn, int level = 1);
		#endregion
	}

	/// <summary>
	/// Interface for roaming species data structure.
	/// </summary>
	public interface IRoamingSpeciesData
	{
		/// <summary>
		/// Gets the species ID of the roaming Pokémon.
		/// </summary>
		int species_id { get; }

		/// <summary>
		/// Gets the level of the roaming Pokémon.
		/// </summary>
		int level { get; }

		/// <summary>
		/// Gets the game switch that controls whether this Pokémon is roaming.
		/// </summary>
		int game_switch { get; }

		/// <summary>
		/// Gets the encounter method for this roaming Pokémon.
		/// 0=any step, 1=walking, 2=surfing, 3=fishing, 4=water-based
		/// </summary>
		int roamer_method { get; }

		/// <summary>
		/// Gets the battle BGM for encounters with this Pokémon.
		/// </summary>
		string battle_bgm { get; }

		/// <summary>
		/// Gets the area maps hash for this roaming Pokémon.
		/// If null, uses the default roaming areas.
		/// </summary>
		IDictionary<int, IList<int>> area_maps { get; }
	}

	/// <summary>
	/// Represents a roaming Pokémon encounter configuration.
	/// </summary>
	public interface IRoamingEncounterData
	{
		/// <summary>
		/// The species of the roaming Pokémon.
		/// </summary>
		string Species { get; }

		/// <summary>
		/// The level of the roaming Pokémon.
		/// </summary>
		int Level { get; }

		/// <summary>
		/// The Game Switch ID; the Pokémon roams while this is ON.
		/// </summary>
		int Switch { get; }

		/// <summary>
		/// The encounter type:
		/// 0 = grass, walking in cave, surfing
		/// 1 = grass, walking in cave
		/// 2 = surfing
		/// 3 = fishing
		/// 4 = surfing, fishing
		/// </summary>
		int EncounterType { get; }

		/// <summary>
		/// Optional name of BGM to play for the encounter.
		/// </summary>
		string BgmName { get; }

		/// <summary>
		/// Optional roaming areas specifically for this Pokémon.
		/// Used instead of the global ROAMING_AREAS if specified.
		/// </summary>
		IDictionary<int, int[]> CustomRoamingAreas { get; }
	}
}