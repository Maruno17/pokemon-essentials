using System;
using System.Collections;
using System.Collections.Generic;
using PokemonEssentials.RPGMaker.Kernel;

namespace PokemonEssentials
{
	/// <summary>
	/// Represents an event on the game map, handling event triggers, conditions, and execution.
	/// </summary>
	public interface IGameEvent : IGameCharacter, IHaveUpdate, IHaveRefresh
	{
		#region Properties
		/// <summary>
		/// Gets the ID of the map this event belongs to.
		/// </summary>
		int map_id { get; }

		/// <summary>
		/// Gets the trigger type of the event.
		/// </summary>
		int trigger { get; }

		/// <summary>
		/// Gets the list of event commands.
		/// </summary>
		IList<PokemonEssentials.RPGMaker.IEventCommand> list { get; }

		/// <summary>
		/// Gets whether the event is starting.
		/// </summary>
		bool starting { get; }

		/// <summary>
		/// Gets the temporary switches for this event.
		/// </summary>
		/// <remarks>
		/// Temporary self-switches
		/// </remarks>
		IDictionary<string, bool> tempSwitches { get; }

		/// <summary>
		/// Gets or sets whether the event needs to be refreshed.
		/// </summary>
		bool need_refresh { get; set; }

		/// <summary>
		/// Gets the id of the event.
		/// </summary>
		string id { get; }

		/// <summary>
		/// Gets the name of the event.
		/// </summary>
		string name { get; }
		#endregion

		IGameEvent initialize(int mapId, IGameCharacter @event, ITempMetadata map = null);

		#region Methods
		/// <summary>
		/// Sets the event as starting.
		/// </summary>
		void set_starting();

		/// <summary>
		/// Clears the starting state of the event.
		/// </summary>
		void clear_starting();

		/// <summary>
		/// Starts the event if it has commands.
		/// </summary>
		void start();

		/// <summary>
		/// Erases the event.
		/// </summary>
		void erase();

		/// <summary>
		/// Erases the event's move route.
		/// </summary>
		void erase_route();

		/// <summary>
		/// Checks if a temporary switch is on.
		/// </summary>
		/// <param name="switchId">The ID of the switch to check.</param>
		/// <returns>True if the switch is on; otherwise, false.</returns>
		//bool IsTempSwitchOn(string switchId);
		bool tsOn(string switchId);

		/// <summary>
		/// Checks if a temporary switch is off.
		/// </summary>
		/// <param name="switchId">The ID of the switch to check.</param>
		/// <returns>True if the switch is off; otherwise, false.</returns>
		//bool IsTempSwitchOff(string switchId);
		bool tsOff(string switchId);

		/// <summary>
		/// Sets a temporary switch on.
		/// </summary>
		/// <param name="switchId">The ID of the switch to set.</param>
		void setTempSwitchOn(string switchId);

		/// <summary>
		/// Sets a temporary switch off.
		/// </summary>
		/// <param name="switchId">The ID of the switch to set.</param>
		void setTempSwitchOff(string switchId);

		/// <summary>
		/// Checks if a self-switch is off.
		/// </summary>
		/// <param name="switchId">The ID of the switch to check.</param>
		/// <returns>True if the switch is off; otherwise, false.</returns>
		//bool IsSelfSwitchOff(string switchId);
		bool isOff(string switchId);

		/// <summary>
		/// Checks if a switch is on.
		/// </summary>
		/// <param name="switchId">The ID of the switch to check.</param>
		/// <returns>True if the switch is on; otherwise, false.</returns>
		//bool IsSwitchOn(int switchId);
		bool switchIsOn(int switchId);

		/// <summary>
		/// Gets the variable associated with this event.
		/// </summary>
		/// <returns>The event variable.</returns>
		//object GetVariable();
		object variable();

		/// <summary>
		/// Sets the variable associated with this event.
		/// </summary>
		/// <param name="value">The value to set.</param>
		void setVariable(object value);

		/// <summary>
		/// Gets the event variable as an integer.
		/// </summary>
		/// <returns>The event variable as an integer.</returns>
		//int GetVariableAsInt();
		int varAsInt();

		/// <summary>
		/// Checks if the event has expired.
		/// </summary>
		/// <param name="seconds">The number of seconds to check against.</param>
		/// <returns>True if the event has expired; otherwise, false.</returns>
		//bool IsExpired(int seconds = 86_400);
		bool expired(int secs = 86_400);

		/// <summary>
		/// Checks if the event has expired in days.
		/// </summary>
		/// <param name="days">The number of days to check against.</param>
		/// <returns>True if the event has expired; otherwise, false.</returns>
		//bool IsExpiredDays(int days = 1);
		bool expiredDays(int days = 1);

		/// <summary>
		/// Checks if the event has cooled down.
		/// </summary>
		/// <param name="seconds">The number of seconds to check against.</param>
		/// <returns>True if the event has cooled down; otherwise, false.</returns>
		//bool IsCooledDown(int seconds);
		bool cooledDown(int seconds);

		/// <summary>
		/// Checks if the event has cooled down in days.
		/// </summary>
		/// <param name="days">The number of days to check against.</param>
		/// <returns>True if the event has cooled down; otherwise, false.</returns>
		//bool IsCooledDownDays(int days);
		bool cooledDownDays(int days);

		/// <summary>
		/// Checks if the player is on this event.
		/// </summary>
		/// <returns>True if the player is on this event; otherwise, false.</returns>
		//bool IsPlayerOnEvent();
		bool onEvent();

		/// <summary>
		/// Checks if the event is over a trigger.
		/// </summary>
		/// <returns>True if the event is over a trigger; otherwise, false.</returns>
		//bool IsOverTrigger();
		bool over_trigger();

		/// <summary>
		/// Checks for event trigger on touch.
		/// </summary>
		/// <param name="direction">The direction of the touch.</param>
		void check_event_trigger_touch(int direction);

		/// <summary>
		/// Checks for event trigger after turning.
		/// </summary>
		void check_event_trigger_after_turning();

		/// <summary>
		/// Checks for event trigger after moving.
		/// </summary>
		void check_event_trigger_after_moving();

		/// <summary>
		/// Checks for automatic event trigger.
		/// </summary>
		void check_event_trigger_auto();

		/// <summary>
		/// Refreshes the event.
		/// </summary>
		void refresh();

		/// <summary>
		/// Checks if the event should be updated.
		/// </summary>
		/// <param name="recalculate">Whether to recalculate the update status.</param>
		/// <returns>True if the event should be updated; otherwise, false.</returns>
		bool should_update(bool recalculate = false);

		/// <summary>
		/// Updates the event.
		/// </summary>
		void update();

		/// <summary>
		/// Updates the event's movement.
		/// </summary>
		void update_move();
		#endregion
	}
}