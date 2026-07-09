using System;
using System.Collections;
using System.Collections.Generic;
using PokemonEssentials.Data;

namespace PokemonEssentials//.Overworld.WildEncounters
{
	//===============================================================================
	//
	//===============================================================================
	public interface IPokemonEncounters {
		int step_count		{ get; }

		void initialize();

		void setup(int map_ID);

		void reset_step_count();

		//-----------------------------------------------------------------------------

		/// <summary>
		/// Returns whether encounters for the given encounter type have been defined
		/// for the current map.
		/// </summary>
		/// <param name="enc_type"></param>
		/// <returns></returns>
		bool has_encounter_type(int enc_type); //IEncounterType

		/// <summary>
		/// Returns whether encounters for the given encounter type have been defined
		/// for the given map. Only called by Bug-Catching Contest to see if it can use
		/// the map's BugContest encounter type to generate caught Pokémon for the other
		/// contestants.
		/// </summary>
		/// <param name="map_ID"></param>
		/// <param name="enc_type"></param>
		/// <returns></returns>
		bool map_has_encounter_type(int map_ID, int enc_type);

		/// <summary>
		/// Returns whether land-like encounters have been defined for the current map.
		/// Applies only to encounters triggered by moving around.
		/// </summary>
		/// <returns></returns>
		bool has_land_encounters();

		/// <summary>
		/// Returns whether land-like encounters have been defined for the current map
		/// (ignoring the Bug-Catching Contest one).
		/// Applies only to encounters triggered by moving around.
		/// </summary>
		/// <returns></returns>
		bool has_normal_land_encounters();

		/// <summary>
		/// Returns whether cave-like encounters have been defined for the current map.
		/// Applies only to encounters triggered by moving around.
		/// </summary>
		/// <returns></returns>
		bool has_cave_encounters();

		/// <summary>
		/// Returns whether water-like encounters have been defined for the current map.
		/// Applies only to encounters triggered by moving around (i.e. not fishing).
		/// </summary>
		/// <returns></returns>
		bool has_water_encounters();

		//-----------------------------------------------------------------------------

		/// <summary>
		/// Returns whether the player's current location allows wild encounters to
		/// trigger upon taking a step.
		/// </summary>
		/// <returns></returns>
		bool encounter_possible_here();

		/// <summary>
		/// Returns whether a wild encounter should happen, based on its encounter
		/// chance. Called when taking a step and by Rock Smash.
		/// </summary>
		/// <param name="enc_type"></param>
		/// <param name="repel_active"></param>
		/// <param name="triggered_by_step"></param>
		/// <returns></returns>
		bool encounter_triggered(int enc_type, bool repel_active = false, bool triggered_by_step = true);

		/// <summary>
		/// Returns whether an encounter with the given Pokémon should be allowed after
		/// taking into account Repels and ability effects.
		/// </summary>
		/// <param name="enc_data"></param>
		/// <param name="repel_active"></param>
		/// <returns></returns>
		bool allow_encounter(IEncounterPokemonData enc_data, bool repel_active = false);

		/// <summary>
		/// Returns whether a wild encounter should be turned into a double wild
		/// encounter.
		/// </summary>
		/// <returns></returns>
		bool have_double_wild_battle();

		/// <summary>
		/// Checks the defined encounters for the current map and returns the encounter
		/// type that the given time should produce. Only returns an encounter type if
		/// it has been defined for the current map.
		/// </summary>
		/// <param name="base_type"></param>
		/// <param name="time"></param>
		void find_valid_encounter_type_for_time(int base_type, float time);

		/// <summary>
		/// Returns the encounter method that the current encounter should be generated
		/// from, depending on the player's current location.
		/// </summary>
		void encounter_type();

		//-----------------------------------------------------------------------------

		/// <summary>
		/// For the current map, randomly chooses a species and level from the encounter
		/// list for the given encounter type. Returns null if there are none defined.
		/// A higher chance_rolls makes this method prefer rarer encounter slots.
		/// </summary>
		/// <param name="enc_type"></param>
		/// <param name="chance_rolls"></param>
		void choose_wild_pokemon(IEncounterType enc_type, int chance_rolls = 1);

		/// <summary>
		/// For the given map, randomly chooses a species and level from the encounter
		/// list for the given encounter type. Returns null if there are none defined.
		/// Used by the Bug-Catching Contest to choose what the other participants
		/// caught.
		/// </summary>
		/// <param name="map_ID"></param>
		/// <param name="enc_type"></param>
		void choose_wild_pokemon_for_map(int map_ID, int enc_type);
	}

	public interface IEncounterPokemonData
	{
		int Pokemon			{ get; }
		int MinLevel		{ get; }
		int MaxLevel		{ get; }
	}

	public interface IMainOverworldWildEncounters : IMain
	{
		//===============================================================================
		//
		//===============================================================================
		/// <summary>
		/// Creates and returns a Pokémon based on the given species and level.
		/// Applies wild Pokémon modifiers (wild held item, shiny chance modifiers,
		/// Pokérus, gender/nature forcing because of player's lead Pokémon).
		/// </summary>
		/// <param name="species"></param>
		/// <param name="level"></param>
		/// <param name="isRoamer"></param>
		void GenerateWildPokemon(int species, int level, bool isRoamer = false);

		/// <summary>
		/// Used by fishing rods and Headbutt/Rock Smash/Sweet Scent to generate a wild
		/// Pokémon (or two if it's Sweet Scent) for a triggered wild encounter.
		/// </summary>
		/// <param name="enc_type"></param>
		/// <param name="only_single"></param>
		/// <returns></returns>
		bool Encounter(int enc_type, bool only_single = true);
	}
}