using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// This class handles this switches. It's a wrapper for the built-in class "Hash."
	/// </summary>
	/// <remarks>
	/// Refer to "<see cref="Game.game_self_switches"/>" for the instance of this class.
	/// Self switches are boolean flags that are specific to individual events on maps. They are used to
	/// track the state of events and can be used to control event flow and progression. Each self switch
	/// is associated with a specific event on a specific map.
	/// </remarks>
	public interface IGameSelfSwitches
	{
		/// <summary>
		/// Gets or sets the state of a self switch.
		/// </summary>
		/// <param name="key">The self switch key containing map ID, event ID, and switch name.</param>
		/// <value>True if the switch is ON, false if it is OFF.</value>
		/// <returns>The current state of the self switch.</returns>
		/// <remarks>
		/// This indexer provides access to individual self switches in the game. Each self switch is a boolean
		/// value that is specific to a particular event on a map. The key parameter must contain valid map ID,
		/// event ID, and switch name values.
		/// </remarks>
		/// <exception cref="System.ArgumentNullException">Thrown when key is null.</exception>
		bool this[ISelfSwitchVariable key] { get; set; }
	}

	/// <summary>
	/// Interface for self switch variables.
	/// </summary>
	/// <remarks>
	/// This interface defines the properties required for a self switch variable.
	/// It is implemented by the SelfSwitchVariable struct to ensure proper type safety
	/// and interface compatibility.
	/// </remarks>
	public interface ISelfSwitchVariable
	{
		/// <summary>
		/// Gets the map ID associated with this self switch.
		/// </summary>
		/// <remarks>
		/// The ID of the map where the event containing this self switch is located.
		/// </remarks>
		int MapId { get; }

		/// <summary>
		/// Gets the event ID associated with this self switch.
		/// </summary>
		/// <remarks>
		/// The ID of the event that contains this self switch.
		/// </remarks>
		int EventId { get; }

		/// <summary>
		/// Gets the name of this self switch.
		/// </summary>
		/// <remarks>
		/// The name of the switch (typically "A", "B", "C", or "D").
		/// </remarks>
		string Name { get; }
	}
}