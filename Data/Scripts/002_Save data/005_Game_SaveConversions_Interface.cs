using System;
using System.Collections.Generic;

//===============================================================================
// Conversions required to support backwards compatibility with old save files
// (within reason).
//===============================================================================
namespace PokemonEssentials
{
	/*
	// Update existing interfaces with new properties/fields
	public interface IPokemonGlobalMetadata
	{
		IPhone phone { get; set; }
		object phoneTime { get; set; }
		List<object[]> phoneNumbers { get; set; }
	}

	public interface IPokemonMapMetadata
	{
		object blackFluteUsed { get; set; }
		object whiteFluteUsed { get; set; }
		bool higher_level_wild_pokemon { get; set; }
		bool lower_encounter_rate { get; set; }
		bool lower_level_wild_pokemon { get; set; }
		bool higher_encounter_rate { get; set; }
	}

	public interface IGameSaveGameStats : IGameStats
	{
		int bump_count { get; set; }
		int primal_reversion_count { get; set; }
	}
	*/

	public interface IGameSaveConversions
	{
		/// <summary>
		/// Conversions required to support backwards compatibility with old save files
		/// (within reason).
		/// </summary>
		void RegisterGameSaveConversions();
	}
}