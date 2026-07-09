using System;
using System.Linq;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Represents the player's Pokédex.
	/// </summary>
	public interface IPokedex {
		/// <summary>
		/// an array of accessible Dexes
		/// <see cref="refresh_accessible_dexes"/>
		/// </summary>
		IList<int> accessible_dexes		{ get; }
		//IList<bool> unlocked_dexes		{ get; }

		//public override string ToString() {
		//	return base.ToString() + string.Format(" seen: {0}, owned: {1}>", this.seen_count(), this.owned_count());
		//}

		string inspect();

		/// <summary>
		/// Creates an empty Pokédex.
		/// </summary>
		//public Pokedex() { initialize(); }
		IPokedex initialize();

		/// <summary>
		/// Clears the Pokédex.
		/// </summary>
		void clear();

		//---------------------------------------------------------------------------

		/// <summary>
		/// Sets the given species as seen in the Pokédex.
		/// </summary>
		/// <param name="species">species to set as seen</param>
		/// <param name="should_refresh_dexes">whether Dex accessibility should be recalculated</param>
		void set_seen(int species, bool should_refresh_dexes = true);

		/// <summary>
		/// </summary>
		/// <param name="species">species to check</param>
		/// <returns>whether the species is seen</returns>
		bool seen(int species);

		/// <summary>
		/// </summary>
		/// <param name="species">species to check</param>
		/// <param name="gender">gender to check</param>
		/// <param name="form">form to check</param>
		/// <param name="shiny">shininess to check (checks both if null)</param>
		/// <returns>whether the species of the given gender/form/shininess is seen</returns>
		bool seen_form(int species, int gender, int form, bool? shiny = null);

		/// <summary>
		/// Sets the egg for the given species as seen.
		/// </summary>
		/// <param name="species">species to set as seen</param>
		void set_seen_egg(int species);

		/// <summary>
		/// </summary>
		/// <param name="species">species to check</param>
		/// <returns>whether the egg for the given species is seen</returns>
		bool seen_egg(int species);

		/// <summary>
		/// If a region ID is given, returns the amount of seen Pokémon
		/// in that region.
		/// </summary>
		/// <param name="dex">region ID</param>
		/// <returns>
		/// Returns the amount of seen Pokémon.
		/// </returns>
		int seen_count(int dex = -1);

		/// <summary>
		/// If a region is given, returns whether there are seen Pokémon
		/// in that region.
		/// </summary>
		/// <param name="dex">region ID</param>
		/// <returns>whether there are any seen Pokémon</returns>
		bool seen_any(int dex = -1);

		/// <summary>
		/// Returns the amount of seen forms for the given species.
		/// </summary>
		/// <param name="species">Pokémon species</param>
		/// <returns>amount of seen forms</returns>
		int seen_forms_count(int species);

		/// <summary>
		/// </summary>
		/// <param name="species">Pokémon species</param>
		int last_form_seen(int species);

		/// <summary>
		/// </summary>
		/// <param name="species">Pokémon species</param>
		/// <param name="gender">gender (0=male, 1=female, 2=genderless)</param>
		/// <param name="form">form number</param>
		/// <param name="shiny">shininess</param>
		void set_last_form_seen(int species, int gender = 0, int form = 0, bool shiny = false);

		//---------------------------------------------------------------------------

		/// <summary>
		/// Sets the given species as owned in the Pokédex.
		/// </summary>
		/// <param name="species">species to set as owned</param>
		/// <param name="should_refresh_dexes">whether Dex accessibility should be recalculated</param>
		void set_owned(int species, bool should_refresh_dexes = true);

		/// <summary>
		/// Sets the given species as owned in the Pokédex.
		/// </summary>
		/// <param name="species">species to set as owned</param>
		void set_shadow_pokemon_owned(int species);

		/// <summary>
		/// </summary>
		/// <param name="species">species to check</param>
		/// <returns>whether the species is owned</returns>
		bool owned(int species);

		/// <summary>
		/// </summary>
		/// <param name="species">species to check</param>
		/// <returns>
		/// whether a Shadow Pokémon of the species is owned
		/// </returns>
		bool owned_shadow_pokemon(int species);

		/// <summary>
		/// If a region ID is given, returns the amount of owned Pokémon
		/// in that region.
		/// </summary>
		/// <param name="dex">region ID</param>
		/// <returns>
		/// Returns the amount of owned Pokémon.
		/// </returns>
		int owned_count(int dex = -1);

		//---------------------------------------------------------------------------

		/// <summary>
		/// </summary>
		/// <param name="species">Pokemon to register as seen</param>
		/// <param name="gender">gender to register (0=male, 1=female, 2=genderless)</param>
		/// <param name="form">form to register</param>
		/// <param name="shiny">shininess to register</param>
		/// <param name="should_refresh_dexes">whether to recalculate accessible Dex lists</param>
		void register(int species, int gender = 0, int form = 0, bool shiny = false, bool should_refresh_dexes = true);

		/// <summary>
		/// </summary>
		/// <param name="pkmn">Pokemon to register as most recently seen</param>
		void register_last_seen(IPokemon pkmn);

		//---------------------------------------------------------------------------

		/// <summary>
		/// </summary>
		/// <param name="species">species to check</param>
		/// <returns>
		/// the number of Pokémon of the given species that have
		/// been caught by the player
		/// </returns>
		int caught_count(int species);

		/// <summary>
		/// </summary>
		/// <param name="species">species to check</param>
		/// <returns>
		/// the number of Pokémon of the given species that have
		/// been defeated by the player
		/// </returns>
		int defeated_count(int species);

		/// <summary>
		/// </summary>
		/// <param name="species">species to check</param>
		/// <returns>
		/// the number of Pokémon of the given species that have
		/// been defeated or caught by the player
		/// </returns>
		int battled_count(int species);

		/// <summary>
		/// </summary>
		/// <param name="species">species to count as caught</param>
		void register_caught(int species);

		/// <summary>
		/// </summary>
		/// <param name="species">species to count as defeated</param>
		void register_defeated(int species);

		//---------------------------------------------------------------------------

		/// <summary>
		/// Unlocks the given Dex, -1 being the National Dex.
		/// </summary>
		/// <param name="dex">Dex ID (-1 is the National Dex)</param>
		void unlock(int dex);

		/// <summary>
		/// Locks the given Dex, -1 being the National Dex.
		/// </summary>
		/// <param name="dex">Dex ID (-1 is the National Dex)</param>
		void Lock(int dex);

		/// <summary>
		/// </summary>
		/// <param name="dex">Dex ID (-1 is the National Dex)</param>
		/// <returns>
		/// whether the given Dex is unlocked
		/// </returns>
		bool unlocked(int dex);

		/// <summary>
		/// </summary>
		/// <returns>
		/// the number of defined Dexes (including the National Dex)
		/// </returns>
		int dexes_count();

		/// <summary>
		/// Decides which Dex lists are able to be viewed (i.e. they are unlocked and
		/// have at least 1 seen species in them), and saves all accessible Dex region
		/// numbers into {#accessible_dexes}. National Dex comes after all regional
		/// Dexes.
		/// If the Dex list shown depends on the player's location, this just decides
		/// if (a species in the current region has been seen - doesn't look at other) {
		/// regions.
		/// </summary>
		void refresh_accessible_dexes();

		bool species_in_unlocked_dex(int species);

		//---------------------------------------------------------------------------
		//private;

		/// <summary>
		/// </summary>
		/// <param name="hash"></param>
		/// <param name="region"></param>
		//private int count_species(IDictionary<int,bool> hash, int region = -1) {
		//	int ret = 0;
		//	if (region == -1) {
		//		//GameData.Species.each_species(s => { if (hash[s.species]) ret += 1; });
		//		foreach(Pokemon s in Species) { if (hash[s.species]) ret += 1; }
		//	} else {
		//		AllRegionalSpecies(region).each(s => { if (s && hash[s]) ret += 1; });
		//	}
		//	return ret;
		//}
	}
}