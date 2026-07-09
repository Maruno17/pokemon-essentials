using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Possible actions a battler can take in a round
	/// </summary>
	public enum BattleActions
	{
		None = 0,
		/// <summary>
		/// UseMove
		/// </summary>
		/// <remarks>Fight command - using a move.</remarks>
		Fight = 1,
		/// <summary>
		/// UseItem
		/// </summary>
		/// <remarks>Bag command - using an item.</remarks>
		Bag = 2,
		/// <summary>
		/// SwitchOut
		/// </summary>
		/// <remarks>Pokemon command - switching Pokemon.</remarks>
		Pokemon = 3,
		/// <summary>
		/// Run/Flee
		/// </summary>
		/// <remarks>Run command - attempting to flee.</remarks>
		Run = 4,
		/// <summary>
		/// Call
		/// </summary>
		CallPokemon = 5,
		Shift
	}

	public interface IBattleChoice
	{
		int Action { get; }
		/// <summary>
		/// Index of Action being used
		/// </summary>
		int Index { get; }
		IBattleMove Move { get; } //ToDo: Rename to Value?
		int Target { get; }
	}

	/// <summary>
	/// Options made on a given turn, per pokemon.
	/// </summary>
	public struct Choice : PokemonEssentials.IBattleChoice
	{
		public int Action { get; private set; }
		/// <summary>
		/// Index of Action being used
		/// </summary>
		public int Index { get; private set; }
		public PokemonEssentials.IBattleMove Move { get; private set; }
		public int Target { get; private set; }

		/// <summary>
		/// If action you're choosing to take is to Attack with a Move
		/// </summary>
		/// <param name="action"></param>
		/// <param name="move"></param>
		/// <param name="target"></param>
		public Choice(int action, int moveIndex, PokemonEssentials.IBattleMove move, int target = -1)
		{
			Action = action;
			Index = moveIndex;
			Move = move;
			Target = target;
		}

		/// <summary>
		/// If action you're choosing to take is to Switch Pkmns
		/// </summary>
		/// <param name="action"></param>
		/// <param name="pkmnIndex"></param>
		public Choice(int action, int pkmnIndex)
		{
			Action = action;
			Index = pkmnIndex;
			Target = -1;
			Move = null;
		}

		/// <summary>
		/// If action you're choosing to take is to Use an Item on a Pkmn
		/// </summary>
		/// <param name="action"></param>
		/// <param name="itemIndex"></param>
		/// <param name="pkmnTarget"></param>
		public Choice(int action, int itemIndex, int pkmnTarget)
		{
			Action = action;
			Index = (int)itemIndex;
			Target = pkmnTarget;
			Move = null;
		}

		/// <summary>
		/// If action you're choosing to take is to Flee, Call Pokemon, or Nothing
		/// </summary>
		public Choice(int action = 0)
		{
			Action = action;
			Move = null;
			Target = -1;
			Index = 0;
		}
	}
}