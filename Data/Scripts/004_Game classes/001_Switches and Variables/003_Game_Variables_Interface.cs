using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// This class handles variables. It's a wrapper for the built-in class "Array."
	/// </summary>
	/// <remarks>
	/// Refer to "<see cref="Game.game_variables"/>" for the instance of this class.
	/// Variables are integer values used to store game state and progression data. They are saved with the game
	/// and can be used to track various game conditions, choices, and numerical values.
	///
	/// The following is a list of predefined variables and their purposes:
	/// <code>
	/// 1     Temp Pokemon Choice             Used to temporarily store information. The name is just a guide as to what kind of information that is. Is also the default place where the outcome of a battle is stored.
	/// 2     Temp Move Choice                Used to temporarily store information. The name is just a guide as to what kind of information that is.
	/// 3     Temp Pokemon Name               Used to temporarily store information. The name is just a guide as to what kind of information that is.
	/// 4     Temp Move Name                  Used to temporarily store information. The name is just a guide as to what kind of information that is.
	/// 5     Temp Text Entry                 Used to temporarily store information. The name is just a guide as to what kind of information that is.
	/// 6     Poké Center healing ball count  Used while healing in the Poké Center. Is the number of balls to display on the healing machine (i.e. the number of Pokémon in the player's party).
	/// 7     Starter choice                  Used for remembering which starter Pokémon the player chose. Typically 1=Grass starter, 2=Fire starter, 3=Water starter.
	/// 8     Apricorn being converted        Used by the Apricorn Converter. Is the item ID of the Apricorn given to convert, or the item ID of the resulting Poké Ball.
	/// 9     Fossil being revived            Used by the Fossil Reviver. Is the item ID of the fossil item being revived, or the species ID of the resulting Pokémon.
	/// 10    Elevator current floor          Used by elevator maps. Is the current floor the elevator is at. It should be set as part of any door event which leads into the elevator.
	/// 11    Elevator new floor              Used by elevator maps. Is the floor the player wants to go to. It should be set by the event representing the elevator's controls.
	/// 12    Rival name                      Stores the rival's name.
	/// 13    E4 defeated count               The number of times the Elite Four have been beaten. This number is added to each time the Hall of Fame is entered.
	/// 14-25 -----RESERVED-----              These variables are not currently used, but are marked as reserved in case they need to be used by Essentials in future.
	/// </code>
	/// </remarks>
	public interface IGameVariable
	{
		/// <summary>
		/// Gets or sets the value of a game variable.
		/// </summary>
		/// <param name="variable_id">The ID of the variable to get or set.</param>
		/// <value>The value to assign to the variable.</value>
		/// <returns>The current value of the variable.</returns>
		/// <remarks>
		/// This indexer provides access to individual variables in the game. Each variable is an integer value
		/// that can be used to store game state, track progression, or hold temporary data. The variable_id
		/// parameter must be a valid variable ID (1 or greater).
		///
		/// See the class remarks for a complete list of predefined variables and their purposes.
		/// </remarks>
		/// <exception cref="System.ArgumentOutOfRangeException">Thrown when variable_id is less than 1.</exception>
		int this[int variable_id] { get; set; }
	}
}