using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	public interface IMainUtilitiesPokemon : IMain
	{
		//===============================================================================
		// Nicknaming and storing Pokémon.
		//===============================================================================
		bool BoxesFull();

		void Nickname(IPokemon pkmn);

		void StorePokemon(IPokemon pkmn);

		void NicknameAndStore(IPokemon pkmn);

		//===============================================================================
		// Giving Pokémon to the player (will send to storage if party is full).
		//===============================================================================
		bool AddPokemon(IPokemon pkmn, int level = 1, bool see_form = true);

		bool AddPokemonSilent(IPokemon pkmn, int level = 1, bool see_form = true);

		//===============================================================================
		// Giving Pokémon/eggs to the player (can only add to party).
		//===============================================================================
		bool AddToParty(IPokemon pkmn, int level = 1, bool see_form = true);

		bool AddToPartySilent(IPokemon pkmn, int? level = null, bool see_form = true);

		bool AddForeignPokemon(IPokemon pkmn, int level = 1, string owner_name = null, string nickname = null, int owner_gender = 0, bool see_form = true);

		bool GenerateEgg(IPokemon pkmn, string text = "");
		//alias AddEgg GenerateEgg;
		//alias GenEgg GenerateEgg;

		//===============================================================================
		// Analyse Pokémon in the party.
		//===============================================================================
		/// <summary>
		/// Returns the first unfainted, non-egg Pokémon in the player's party.
		/// </summary>
		/// <param name="variable_ID"></param>
		/// <returns></returns>
		IPokemon FirstAblePokemon(int variable_ID);

		/// <summary>
		/// Return a level value based on Pokémon in a party.
		/// </summary>
		/// <param name="party"></param>
		/// <returns></returns>
		int BalancedLevel(IList<IPokemon> party);

		/// <summary>
		/// Calculates a Pokémon's size (in millimeters).
		/// </summary>
		/// <param name="pkmn"></param>
		/// <returns></returns>
		int Size(IPokemon pkmn);

		/// <summary>
		/// Returns true if the given species can be legitimately obtained as an egg.
		/// </summary>
		/// <param name="species"></param>
		/// <returns></returns>
		bool HasEgg(int species);
	}
}