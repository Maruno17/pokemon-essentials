using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// // Move objects known by Pokémon.
	/// </summary>
	public interface IPokemonMove { //: IMove
		/// <summary>
		/// Creates a new Move object.
		/// </summary>
		/// <param name="move_id">move ID | Symbol, String, GameData.Move</param>
		IPokemonMove initialize(int move_id);

		/// <summary>
		/// This move's ID.
		/// </summary>
		/// <value>the new move ID</value>
		/// <remarks>
		/// Sets this move's ID, and caps the PP amount if it is now greater than this
		/// move's total PP.
		/// </remarks>
		int id		{ get; set; }

		/// <summary>
		/// The amount of PP remaining for this move.
		/// </summary>
		/// <value>the new PP amount</value>
		/// <remarks>
		/// Sets this move's PP, capping it at this move's total PP.
		/// </remarks>
		int pp		{ get; set; }

		/// <summary>
		/// Sets this move's PP Up count, and caps the PP if necessary.
		/// </summary>
		/// <value>the new PP Up value</value>
		/// <remarks>
		/// The number of PP Ups used on this move (each one adds 20% to the total PP).
		/// </remarks>
		int ppup		{ get; set; }

		/// <summary>
		/// Returns the total PP of this move, taking PP Ups into account.
		/// </summary>
		/// <value>total PP</value>
		int total_pp	{ get; }
		//alias totalpp total_pp;

		string function_code	{ get; }
		int power				{ get; }
		int type				{ get; }
		int category			{ get; }
		bool physical_move		{ get; }
		bool special_move		{ get; }
		bool status_move		{ get; }
		int accuracy			{ get; }
		int effect_chance		{ get; }
		int target				{ get; }
		int priority			{ get; }
		IList<string> flags		{ get; }
		string name				{ get; }
		string description		{ get; }
		bool hidden_move		{ get; }

		int display_type(IPokemon pkmn);
		int display_category(IPokemon pkmn);
		int display_damage(IPokemon pkmn);
		int display_accuracy(IPokemon pkmn);
	}
}