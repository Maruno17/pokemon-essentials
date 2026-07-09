using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	public interface IBattleRestriction
	{
		/// <summary>
		/// Validates a Pokemon according to restrictions
		/// </summary>
		/// <param name="pkmn">Pokemon to validate</param>
		/// <returns>True if valid, false otherwise</returns>
		//string errorMessage { get; }
		bool isValid(IPokemon pokemon);
	}

	public interface IBattleTeamRestriction
	{
		/// <summary>
		/// Gets error message for this rule
		/// </summary>
		/// <returns>Error message</returns>
		string errorMessage { get; }

		/// <summary>
		/// Validates a team according to restrictions
		/// </summary>
		/// <param name="team">Team to validate</param>
		/// <returns>True if valid, false otherwise</returns>
		bool isValid(IList<IPokemon> team);
	}

	/// <summary>
	/// Interface for standard species restriction based on base stats and abilities
	/// </summary>
	public interface IStandardRestriction : IBattleRestriction
	{
		/// <summary>
		/// Validates a Pokemon according to standard restrictions
		/// </summary>
		/// <param name="pkmn">Pokemon to validate</param>
		/// <returns>True if valid, false otherwise</returns>
		bool isValid(IPokemon pkmn);
	}

	/// <summary>
	/// Interface for height-based restrictions
	/// </summary>
	public interface IHeightRestriction : IBattleRestriction
	{
		/// <summary>
		/// Initializes height restriction
		/// </summary>
		/// <param name="maxHeightInMeters">Maximum height in meters</param>
		void initialize(double maxHeightInMeters);

		/// <summary>
		/// Validates Pokemon height
		/// </summary>
		/// <param name="pkmn">Pokemon to validate</param>
		/// <returns>True if within height limit, false otherwise</returns>
		bool isValid(IPokemon pkmn);
	}

	/// <summary>
	/// Interface for weight-based restrictions
	/// </summary>
	public interface IWeightRestriction : IBattleRestriction
	{
		/// <summary>
		/// Initializes weight restriction
		/// </summary>
		/// <param name="maxWeightInKg">Maximum weight in kilograms</param>
		void initialize(double maxWeightInKg);

		/// <summary>
		/// Validates Pokemon weight
		/// </summary>
		/// <param name="pkmn">Pokemon to validate</param>
		/// <returns>True if within weight limit, false otherwise</returns>
		bool isValid(IPokemon pkmn);
	}

	/// <summary>
	/// Interface for baby Pokemon restriction (only allows baby forms)
	/// </summary>
	public interface IBabyRestriction : IBattleRestriction
	{
		/// <summary>
		/// Validates that Pokemon is in its baby form
		/// </summary>
		/// <param name="pkmn">Pokemon to validate</param>
		/// <returns>True if Pokemon is baby form, false otherwise</returns>
		bool isValid(IPokemon pkmn);
	}

	/// <summary>
	/// Interface for unevolved form restriction
	/// </summary>
	public interface IUnevolvedFormRestriction : IBattleRestriction
	{
		/// <summary>
		/// Validates that Pokemon is unevolved but can evolve
		/// </summary>
		/// <param name="pkmn">Pokemon to validate</param>
		/// <returns>True if Pokemon is unevolved but can evolve, false otherwise</returns>
		bool isValid(IPokemon pkmn);
	}

	/// <summary>
	/// Interface for nickname checking utilities
	/// </summary>
	public interface INicknameChecker
	{
		/// <summary>
		/// Gets the species name for nickname checking
		/// </summary>
		/// <param name="species">Species ID</param>
		/// <returns>Species name</returns>
		string getName(int species);

		/// <summary>
		/// Checks if a nickname is valid for a species
		/// </summary>
		/// <param name="name">Nickname to check</param>
		/// <param name="species">Species ID</param>
		/// <returns>True if nickname is valid, false otherwise</returns>
		bool check(string name, int species);
	}

	/// <summary>
	/// Interface for nickname clause (no duplicate nicknames)
	/// </summary>
	public interface INicknameClause : IBattleTeamRestriction
	{
		/// <summary>
		/// Validates that no Pokemon have duplicate nicknames
		/// </summary>
		/// <param name="team">Team to validate</param>
		/// <returns>True if no duplicate nicknames, false otherwise</returns>
		bool isValid(IList<IPokemon> team);

		/// <summary>
		/// Gets error message for this rule
		/// </summary>
		/// <returns>Error message</returns>
		string errorMessage { get; }
	}

	/// <summary>
	/// Interface for non-egg restriction
	/// </summary>
	public interface INonEggRestriction : IBattleRestriction
	{
		/// <summary>
		/// Validates that Pokemon is not an egg
		/// </summary>
		/// <param name="pkmn">Pokemon to validate</param>
		/// <returns>True if not an egg, false otherwise</returns>
		bool isValid(IPokemon pkmn);
	}

	/// <summary>
	/// Interface for able Pokemon restriction (can battle)
	/// </summary>
	public interface IAblePokemonRestriction : IBattleRestriction
	{
		/// <summary>
		/// Validates that Pokemon is able to battle
		/// </summary>
		/// <param name="pkmn">Pokemon to validate</param>
		/// <returns>True if able to battle, false otherwise</returns>
		bool isValid(IPokemon pkmn);
	}

	/// <summary>
	/// Interface for species-specific restrictions (allow only certain species)
	/// </summary>
	public interface ISpeciesRestriction : IBattleRestriction
	{
		/// <summary>
		/// Initializes with allowed species list
		/// </summary>
		/// <param name="specieslist">Variable number of allowed species</param>
		void initialize(params int[] specieslist);

		/// <summary>
		/// Checks if species is in the allowed list
		/// </summary>
		/// <param name="species">Species to check</param>
		/// <param name="specieslist">List of allowed species</param>
		/// <returns>True if species is allowed, false otherwise</returns>
		bool isSpecies(int species, IList<int> specieslist);

		/// <summary>
		/// Validates Pokemon species
		/// </summary>
		/// <param name="pkmn">Pokemon to validate</param>
		/// <returns>True if species is allowed, false otherwise</returns>
		bool isValid(IPokemon pkmn);
	}

	/// <summary>
	/// Interface for banned species restriction (disallow certain species)
	/// </summary>
	public interface IBannedSpeciesRestriction : IBattleRestriction
	{
		/// <summary>
		/// Initializes with banned species list
		/// </summary>
		/// <param name="specieslist">Variable number of banned species</param>
		void initialize(params int[] specieslist);

		/// <summary>
		/// Checks if species is in the banned list
		/// </summary>
		/// <param name="species">Species to check</param>
		/// <param name="specieslist">List of banned species</param>
		/// <returns>True if species is banned, false otherwise</returns>
		bool isSpecies(int species, IList<int> specieslist);

		/// <summary>
		/// Validates Pokemon species
		/// </summary>
		/// <param name="pkmn">Pokemon to validate</param>
		/// <returns>True if species is not banned, false otherwise</returns>
		bool isValid(IPokemon pkmn);
	}

	/// <summary>
	/// Interface for restricted species limitation (limit number of certain species)
	/// </summary>
	public interface IRestrictedSpeciesRestriction : IBattleTeamRestriction
	{
		/// <summary>
		/// Initializes with maximum count and species list
		/// </summary>
		/// <param name="maxValue">Maximum number of restricted species allowed</param>
		/// <param name="specieslist">Variable number of restricted species</param>
		void initialize(int maxValue, params int[] specieslist);

		/// <summary>
		/// Checks if species is in the restricted list
		/// </summary>
		/// <param name="species">Species to check</param>
		/// <param name="specieslist">List of restricted species</param>
		/// <returns>True if species is restricted, false otherwise</returns>
		bool isSpecies(int species, IList<int> specieslist);

		/// <summary>
		/// Validates team for restricted species count
		/// </summary>
		/// <param name="team">Team to validate</param>
		/// <returns>True if within limits, false otherwise</returns>
		bool isValid(IList<IPokemon> team);
	}

	/// <summary>
	/// Interface for same species clause (all must be same species)
	/// </summary>
	public interface ISameSpeciesClause : IBattleTeamRestriction
	{
		/// <summary>
		/// Validates that all Pokemon are the same species
		/// </summary>
		/// <param name="team">Team to validate</param>
		/// <returns>True if all same species, false otherwise</returns>
		bool isValid(IList<IPokemon> team);

		/// <summary>
		/// Gets error message for this rule
		/// </summary>
		/// <returns>Error message</returns>
		string errorMessage { get; }
	}

	/// <summary>
	/// Interface for species clause (no duplicate species)
	/// </summary>
	public interface ISpeciesClause : IBattleTeamRestriction
	{
		/// <summary>
		/// Validates that no Pokemon have duplicate species
		/// </summary>
		/// <param name="team">Team to validate</param>
		/// <returns>True if no duplicate species, false otherwise</returns>
		bool isValid(IList<IPokemon> team);

		/// <summary>
		/// Gets error message for this rule
		/// </summary>
		/// <returns>Error message</returns>
		string errorMessage { get; }
	}

	/// <summary>
	/// Interface for minimum level restriction
	/// </summary>
	public interface IMinimumLevelRestriction : IBattleRestriction
	{
		/// <summary>
		/// Gets the minimum level requirement
		/// </summary>
		int level { get; }

		/// <summary>
		/// Initializes with minimum level
		/// </summary>
		/// <param name="minLevel">Minimum level required</param>
		IMinimumLevelRestriction initialize(int minLevel);

		/// <summary>
		/// Validates Pokemon level
		/// </summary>
		/// <param name="pkmn">Pokemon to validate</param>
		/// <returns>True if at or above minimum level, false otherwise</returns>
		bool isValid(IPokemon pkmn);
	}

	/// <summary>
	/// Interface for maximum level restriction
	/// </summary>
	public interface IMaximumLevelRestriction : IBattleRestriction
	{
		/// <summary>
		/// Gets the maximum level allowed
		/// </summary>
		int level { get; }

		/// <summary>
		/// Initializes with maximum level
		/// </summary>
		/// <param name="maxLevel">Maximum level allowed</param>
		IMaximumLevelRestriction initialize(int maxLevel);

		/// <summary>
		/// Validates Pokemon level
		/// </summary>
		/// <param name="pkmn">Pokemon to validate</param>
		/// <returns>True if at or below maximum level, false otherwise</returns>
		bool isValid(IPokemon pkmn);
	}

	/// <summary>
	/// Interface for total level restriction
	/// </summary>
	public interface ITotalLevelRestriction : IBattleTeamRestriction
	{
		/// <summary>
		/// Gets the total level limit
		/// </summary>
		int level { get; }

		/// <summary>
		/// Initializes with total level limit
		/// </summary>
		/// <param name="level">Total level limit</param>
		ITotalLevelRestriction initialize(int level);

		/// <summary>
		/// Validates team total level
		/// </summary>
		/// <param name="team">Team to validate</param>
		/// <returns>True if within total level limit, false otherwise</returns>
		bool isValid(IList<IPokemon> team);

		/// <summary>
		/// Gets error message for this rule
		/// </summary>
		/// <returns>Error message</returns>
		string errorMessage { get; }
	}

	/// <summary>
	/// Interface for banned item restriction
	/// </summary>
	public interface IBannedItemRestriction : IBattleRestriction
	{
		/// <summary>
		/// Initializes with banned items list
		/// </summary>
		/// <param name="itemlist">Variable number of banned items</param>
		IBannedItemRestriction initialize(params int[] itemlist);

		/// <summary>
		/// Checks if item is in the banned list
		/// </summary>
		/// <param name="item">Item to check</param>
		/// <param name="itemlist">List of banned items</param>
		/// <returns>True if item is banned, false otherwise</returns>
		bool isSpecies(int item, IList<int> itemlist);

		/// <summary>
		/// Validates Pokemon held item
		/// </summary>
		/// <param name="pkmn">Pokemon to validate</param>
		/// <returns>True if item is not banned, false otherwise</returns>
		bool isValid(IPokemon pkmn);
	}

	/// <summary>
	/// Interface for no items clause
	/// </summary>
	public interface IItemsDisallowedClause : IBattleRestriction
	{
		/// <summary>
		/// Validates that Pokemon has no held item
		/// </summary>
		/// <param name="pkmn">Pokemon to validate</param>
		/// <returns>True if no held item, false otherwise</returns>
		bool isValid(IPokemon pkmn);
	}

	/// <summary>
	/// Interface for Soul Dew clause
	/// </summary>
	public interface ISoulDewClause : IBattleRestriction
	{
		/// <summary>
		/// Validates that Pokemon is not holding Soul Dew
		/// </summary>
		/// <param name="pkmn">Pokemon to validate</param>
		/// <returns>True if not holding Soul Dew, false otherwise</returns>
		bool isValid(IPokemon pkmn);
	}

	/// <summary>
	/// Interface for item clause (no duplicate held items)
	/// </summary>
	public interface IItemClause : IBattleTeamRestriction
	{
		/// <summary>
		/// Validates that no Pokemon have duplicate held items
		/// </summary>
		/// <param name="team">Team to validate</param>
		/// <returns>True if no duplicate items, false otherwise</returns>
		bool isValid(IList<IPokemon> team);

		/// <summary>
		/// Gets error message for this rule
		/// </summary>
		/// <returns>Error message</returns>
		string errorMessage { get; }
	}

	/// <summary>
	/// Interface for Little Cup specific restrictions
	/// </summary>
	public interface ILittleCupRestriction : IBattleRestriction
	{
		/// <summary>
		/// Validates Pokemon for Little Cup specific bans
		/// </summary>
		/// <param name="pkmn">Pokemon to validate</param>
		/// <returns>True if valid for Little Cup, false otherwise</returns>
		bool isValid(IPokemon pkmn);
	}
}