using System;
using System.Linq;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Basic trainer class (use a child class rather than this one)
	/// </summary>
	public interface ITrainer {
		int trainer_type		{ get; set; }
		string name				{ get; set; }
		int id					{ get; set; }
		int language			{ get; set; }
		IList<IPokemon> party	{ get; set; }

		//override string ToString() {
		//	string str = base.ToString();
		//	string party_str = _party.map(p => p.species_data.species).inspect();
		//	str += string.Format(" {0} _party={0}>", full_name(), party_str);
		//	return str;
		//}

		string inspect();

		string full_name();

		//-----------------------------------------------------------------------------

		/// <summary>
		/// Portion of the ID which is visible on the Trainer Card
		/// </summary>
		/// <param name="id"></param>
		/// <returns></returns>
		int public_ID(int? id = null);

		/// <summary>
		/// Other portion of the ID
		/// </summary>
		/// <param name="id"></param>
		/// <returns></returns>
		int secret_ID(int? id = null);

		/// <summary>
		/// Random ID other than this Trainer's ID
		/// </summary>
		/// <returns></returns>
		int make_foreign_ID();

		//-----------------------------------------------------------------------------

		string trainer_type_name { get; }
		int base_money        { get; }
		int gender            { get; }
		bool male();
		bool female();
		int skill_level       { get; }
		int default_poke_ball { get; }
		IList<int> flags             { get; }
		bool has_flag(string flag);

		//-----------------------------------------------------------------------------

		#region
		IEnumerable<IPokemon> pokemon_party { get; }

		IEnumerable<IPokemon> able_party();

		int party_count();

		int pokemon_count();

		int able_pokemon_count();

		bool party_full();

		/// <summary>
		/// Returns true if there are no usable Pokémon in the player's party.
		/// </summary>
		/// <returns></returns>
		bool all_fainted();

		IPokemon first_party();

		IPokemon first_pokemon();

		IPokemon first_able_pokemon();

		IPokemon last_party();

		IPokemon last_pokemon();

		IPokemon last_able_pokemon();

		bool remove_pokemon_at_index(int index);

		/// <summary>
		/// Checks whether the trainer would still have an unfainted Pokémon if the
		/// Pokémon given by _index_ were removed from the party.
		/// </summary>
		/// <param name="index"></param>
		/// <returns></returns>
		bool has_other_able_pokemon(int index);

		/// <summary>
		/// Returns true if there is a Pokémon of the given species in the trainer's party.
		/// You may also specify a particular form it should be.
		/// </summary>
		/// <param name="species"></param>
		/// <param name="form"></param>
		/// <returns></returns>
		bool has_species(int species, int form = -1);

		/// <summary>
		/// Returns whether there is a fatefully met Pokémon of the given species in the
		/// trainer's party.
		/// </summary>
		/// <param name="species"></param>
		/// <returns></returns>
		bool has_fateful_species(int species);

		/// <summary>
		/// Returns whether there is a Pokémon with the given type in the trainer's party.
		/// </summary>
		/// <param name="type"></param>
		/// <returns></returns>
		bool has_pokemon_of_type(int type);

		/// <summary>
		/// Checks whether any Pokémon in the party knows the given move, and returns
		/// the first Pokémon it finds with that move, or null if no Pokémon has that move.
		/// </summary>
		/// <param name="move"></param>
		/// <returns></returns>
		IPokemon get_pokemon_with_move(int move);

		/// <summary>
		/// Fully heal all Pokémon in the party.
		/// </summary>
		void heal_party();
		#endregion

		//-----------------------------------------------------------------------------

		//public Trainer(string name, int trainer_type) { initialize(name, trainer_type); }

		ITrainer initialize(string name, int trainer_type);
	}

	/// <summary>
	///  Trainer class for NPC trainers
	/// </summary>
	public interface INPCTrainer : ITrainer {
		int version		{ get; set; }
		IList<string> items		{ get; set; }
		string lose_text	{ get; set; }
		string win_text	{ get; set; }

		//public NPCTrainer(string name, int trainer_type, int version = 0)
		//	: base(name, trainer_type) { initialize(name, trainer_type, version); }

		INPCTrainer initialize(string name, int trainer_type, int version = 0);
	}
}