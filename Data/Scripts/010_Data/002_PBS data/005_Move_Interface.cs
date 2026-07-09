using System;
using System.Collections.Generic;

namespace PokemonEssentials.Data
{
	/// <summary>
	/// Interface for Move data, representing Pokemon moves and their properties.
	/// Provides read-only access to move information including power, accuracy, type, and effects.
	/// </summary>
	public interface IMove
	{
		/// <summary>
		/// Gets the unique identifier for this move.
		/// </summary>
		int id { get; }

		/// <summary>
		/// Gets the real name of the move as stored in the data files.
		/// </summary>
		string real_name { get; }

		/// <summary>
		/// Gets the type of this move.
		/// </summary>
		int type { get; }

		/// <summary>
		/// Gets the category of this move.
		/// 0 = Physical, 1 = Special, 2 = Status
		/// </summary>
		int category { get; }

		/// <summary>
		/// Gets the base power of this move.
		/// 0 indicates a move with no fixed power or a status move.
		/// </summary>
		int power { get; }

		/// <summary>
		/// Gets the accuracy of this move as a percentage.
		/// </summary>
		int accuracy { get; }

		/// <summary>
		/// Gets the total PP (Power Points) of this move.
		/// </summary>
		int total_pp { get; }

		/// <summary>
		/// Gets the target specification for this move.
		/// Determines which Pokemon the move can target.
		/// </summary>
		int target { get; }

		/// <summary>
		/// Gets the priority of this move.
		/// Higher priority moves execute first in battle.
		/// </summary>
		int priority { get; }

		/// <summary>
		/// Gets the function code that defines the move's special effects.
		/// </summary>
		string function_code { get; }

		/// <summary>
		/// Gets the collection of flags associated with this move.
		/// Flags define special properties and interactions.
		/// </summary>
		IList<string> flags { get; }

		/// <summary>
		/// Gets the chance of the move's secondary effect occurring.
		/// 0 means no secondary effect or guaranteed effect.
		/// </summary>
		int effect_chance { get; }

		/// <summary>
		/// Gets the real description of the move as stored in the data files.
		/// </summary>
		string real_description { get; }

		/// <summary>
		/// Gets the PBS file suffix for this move entry.
		/// Used for organizing and loading related data files.
		/// </summary>
		string pbs_file_suffix { get; }

		/// <summary>
		/// Gets the translated name of this move for display to players.
		/// This method retrieves the localized name from the message system.
		/// </summary>
		/// <returns>The translated move name</returns>
		string name { get; }

		/// <summary>
		/// Gets the translated description of this move for display to players.
		/// This method retrieves the localized description from the message system.
		/// </summary>
		/// <returns>The translated move description</returns>
		string description();

		/// <summary>
		/// Checks if this move has a specific flag.
		/// </summary>
		/// <param name="flag">The flag to check for (case-insensitive)</param>
		/// <returns>True if the move has the specified flag, false otherwise</returns>
		bool has_flag(string flag);

		/// <summary>
		/// Checks if this move is physical.
		/// Physical moves use the Attack and Defense stats.
		/// </summary>
		/// <returns>True if this is a physical move, false otherwise</returns>
		bool physical();

		/// <summary>
		/// Checks if this move is special.
		/// Special moves use the Special Attack and Special Defense stats.
		/// </summary>
		/// <returns>True if this is a special move, false otherwise</returns>
		bool special();

		/// <summary>
		/// Checks if this move deals damage.
		/// </summary>
		/// <returns>True if this move can deal damage, false otherwise</returns>
		bool damaging();

		/// <summary>
		/// Checks if this move is a status move.
		/// Status moves don't deal direct damage but apply effects.
		/// </summary>
		/// <returns>True if this is a status move, false otherwise</returns>
		bool status();

		/// <summary>
		/// Checks if this move is a hidden move (HM).
		/// Hidden moves can be used in the overworld for navigation.
		/// </summary>
		/// <returns>True if this is a hidden move, false otherwise</returns>
		bool hidden_move();

		/// <summary>
		/// Gets the display type of this move for a specific Pokemon.
		/// Some moves change type based on the user's properties.
		/// </summary>
		/// <param name="pkmn">The Pokemon using the move</param>
		/// <param name="move">The move instance (optional)</param>
		/// <returns>The type to display for this move</returns>
		int display_type(IPokemon pkmn, IMove move = null);

		/// <summary>
		/// Gets the display damage of this move for a specific Pokemon.
		/// Some moves have variable power based on the user's properties.
		/// </summary>
		/// <param name="pkmn">The Pokemon using the move</param>
		/// <param name="move">The move instance (optional)</param>
		/// <returns>The damage value to display for this move</returns>
		int display_damage(IPokemon pkmn, IMove move = null);

		/// <summary>
		/// Gets the display category of this move for a specific Pokemon.
		/// </summary>
		/// <param name="pkmn">The Pokemon using the move</param>
		/// <param name="move">The move instance (optional)</param>
		/// <returns>The category to display for this move</returns>
		int display_category(IPokemon pkmn, IMove move = null);

		/// <summary>
		/// Gets the display accuracy of this move for a specific Pokemon.
		/// </summary>
		/// <param name="pkmn">The Pokemon using the move</param>
		/// <param name="move">The move instance (optional)</param>
		/// <returns>The accuracy to display for this move</returns>
		int display_accuracy(IPokemon pkmn, IMove move = null);

		/// <summary>
		/// Gets a property value for PBS data export.
		/// </summary>
		/// <param name="key">The property key to retrieve</param>
		/// <returns>The property value, or null if the value should be omitted</returns>
		int? get_property_for_PBS(string key);
	}
}