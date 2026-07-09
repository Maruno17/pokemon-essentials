using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Interface for the Battler initialization and state logic.
	/// </summary>
	public interface IBattlerInitialize : IBattler, IHaveUpdate
	{
		/// <summary>
		/// Initializes a new battler with the given battle and index.
		/// </summary>
		/// <param name="btl">The battle instance.</param>
		/// <param name="idxBattler">The battler's index.</param>
		IBattler initialize(IBattle btl, int idxBattler);

		/// <summary>
		/// Initializes blank/default values for the battler's properties.
		/// </summary>
		void InitBlank();

		/// <summary>
		/// Initializes a dummy Pokémon for Future Sight, when the user is no longer in battle.
		/// </summary>
		/// <param name="pkmn">The Pokémon instance.</param>
		/// <param name="idxParty">The party index.</param>
		void InitDummyPokemon(IPokemon pkmn, int idxParty);

		/// <summary>
		/// Initializes the battler with a Pokémon, party index, and optional baton pass state.
		/// </summary>
		/// <param name="pkmn">The Pokémon instance.</param>
		/// <param name="idxParty">The party index.</param>
		/// <param name="batonPass">Whether baton pass effects should be applied.</param>
		IBattler Initialize(IPokemon pkmn, int idxParty, bool batonPass = false);

		/// <summary>
		/// Initializes the battler's Pokémon and moves.
		/// </summary>
		/// <param name="pkmn">The Pokémon instance.</param>
		/// <param name="idxParty">The party index.</param>
		void InitPokemon(IPokemon pkmn, int idxParty);

		/// <summary>
		/// Initializes or resets effects for the battler, optionally applying baton pass logic.
		/// </summary>
		/// <param name="batonPass">Whether baton pass effects should be applied.</param>
		void InitEffects(bool batonPass);

		/// <summary>
		/// Updates the battler's properties from the underlying Pokémon, optionally applying a full change.
		/// </summary>
		/// <param name="fullChange">Whether to update all properties (types, ability, etc.).</param>
		void Update(bool fullChange = false);

		/// <summary>
		/// Resets the battler after being caught, clearing Pokémon, HP, and effects.
		/// </summary>
		void Reset();

		/// <summary>
		/// Updates which Pokémon will gain Exp if this battler is defeated.
		/// </summary>
		void UpdateParticipants();
	}
}