using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// This interpreter runs event commands. This class is used within the
	/// <see cref="IGameSystem"/> class and the <see cref="IGameEvent"/> class.
	/// </summary>
	public interface IInterpreter : IHaveUpdate
	{
		IInterpreter initialize(int depth = 0, bool main = false);

		string inspect();

		void clear();

		/// <summary>
		/// Sets up the interpreter with a list of event commands.
		/// </summary>
		/// <param name="list">List of event commands.</param>
		/// <param name="event_id">Event ID.</param>
		/// <param name="map_id">Map ID.</param>
		void setup(IList<PokemonEssentials.RPGMaker.IEventCommand> list, int event_id, int? map_id = null);

		/// <summary>
		/// Sets up the starting event.
		/// </summary>
		void setup_starting_event();

		/// <summary>
		/// Gets whether the interpreter is currently running.
		/// </summary>
		bool running();

		/// <summary>
		/// Updates the interpreter state and executes commands.
		/// </summary>
		void update();

		/// <summary>
		/// Executes a script and returns its result.
		/// </summary>
		/// <param name="script">Script to execute.</param>
		/// <returns>Result of the script execution.</returns>
		void execute_script(string script);

		/// <summary>
		/// Gets a character based on the parameter.
		/// </summary>
		/// <param name="parameter">Character parameter (-1 for player, 0 for this event, >0 for specific event).</param>
		/// <returns>The requested character.</returns>
		IGameCharacter get_character(int parameter = 0);

		/// <summary>
		/// Gets the player character.
		/// </summary>
		/// <returns>The player character.</returns>
		IGamePlayer get_player();

		/// <summary>
		/// Gets the current event.
		/// </summary>
		/// <returns>The current event.</returns>
		IGameCharacter get_self();

		/// <summary>
		/// Gets an event by ID.
		/// </summary>
		/// <param name="parameter">Event ID.</param>
		/// <returns>The requested event.</returns>
		IGameEvent get_event(int parameter);

		/// <summary>
		/// Locks all events on the map.
		/// </summary>
		void GlobalLock();

		/// <summary>
		/// Unlocks all events on the map.
		/// </summary>
		void GlobalUnlock();

		/// <summary>
		/// Gets the next command index.
		/// </summary>
		/// <param name="index">Current index.</param>
		/// <returns>Next command index.</returns>
		int NextIndex(int index);

		/// <summary>
		/// Repeats the commands above the current index.
		/// </summary>
		/// <param name="index">Current index.</param>
		int RepeatAbove(int index);

		/// <summary>
		/// Breaks out of a loop.
		/// </summary>
		/// <param name="index">Current index.</param>
		int BreakLoop(int index);

		/// <summary>
		/// Jumps to a label in the event commands.
		/// </summary>
		/// <param name="index">Current index.</param>
		/// <param name="label_name">Name of the label to jump to.</param>
		int JumpToLabel(int index, string label_name);

		/// <summary>
		/// Sets up a move route for followers.
		/// </summary>
		/// <param name="id">Follower ID.</param>
		void follower_move_route(int? id = null);

		/// <summary>
		/// Sets up an animation for followers.
		/// </summary>
		/// <param name="id">Follower ID.</param>
		void follower_animation(int? id = null);

		/// <summary>
		/// Ends follower overrides.
		/// </summary>
		void end_follower_overrides();

		/// <summary>
		/// Shows a picture on the screen.
		/// </summary>
		void ShowPicture(int number, string name, int origin, float x, float y, int zoomX = 100, int zoomY = 100, int opacity = 255, int blendType = 0);

		/// <summary>
		/// Erases the current event.
		/// </summary>
		bool EraseThisEvent();

		/// <summary>
		/// Calls a common event.
		/// </summary>
		/// <param name="id">Common event ID.</param>
		void CommonEvent(int id);

		/// <summary>
		/// Sets a self switch for an event.
		/// </summary>
		/// <param name="eventid">Event ID.</param>
		/// <param name="switch_name">Switch name.</param>
		/// <param name="value">Switch value.</param>
		/// <param name="mapid">Map ID.</param>
		void SetSelfSwitch(int eventid, string switch_name, bool value, int mapid = -1);

		/// <summary>
		/// Checks if a temporary switch is off.
		/// </summary>
		/// <param name="c">Switch character.</param>
		/// <returns>True if the switch is off.</returns>
		bool tsOff(char c);

		/// <summary>
		/// Checks if a temporary switch is on.
		/// </summary>
		/// <param name="c">Switch character.</param>
		/// <returns>True if the switch is on.</returns>
		bool tsOn(char c);

		/// <summary>
		/// Sets a temporary switch on.
		/// </summary>
		/// <param name="c">Switch character.</param>
		void setTempSwitchOn(char c);

		/// <summary>
		/// Sets a temporary switch off.
		/// </summary>
		/// <param name="c">Switch character.</param>
		void setTempSwitchOff(char c);

		/// <summary>
		/// Gets a variable value.
		/// </summary>
		/// <param name="args">Variable arguments.</param>
		/// <returns>Variable value.</returns>
		long? getVariable(params int[] args);

		/// <summary>
		/// Sets a variable value.
		/// </summary>
		/// <param name="args">Variable arguments.</param>
		void setVariable(params int[] args);

		/// <summary>
		/// Gets a Pokemon from the player's party.
		/// </summary>
		/// <param name="id">Pokemon ID.</param>
		/// <returns>The requested Pokemon.</returns>
		IPokemon GetPokemon(int id);

		/// <summary>
		/// Sets the event time.
		/// </summary>
		/// <param name="args">Time arguments.</param>
		void SetEventTime(params int[] args);

		/// <summary>
		/// Pushes the current event.
		/// </summary>
		/// <param name="strength">Whether to use strength.</param>
		void PushThisEvent(bool strength = false);

		/// <summary>
		/// Pushes the current boulder.
		/// </summary>
		bool PushThisBoulder();

		/// <summary>
		/// Smashes the current event.
		/// </summary>
		bool SmashThisEvent();

		/// <summary>
		/// Plays the trainer intro.
		/// </summary>
		/// <param name="symbol">Trainer symbol.</param>
		/// <returns>True if successful.</returns>
		bool TrainerIntro(int symbol);

		/// <summary>
		/// Ends the trainer battle.
		/// </summary>
		void TrainerEnd();

		/// <summary>
		/// Sets the price of an item.
		/// </summary>
		/// <param name="item">Item to set price for.</param>
		/// <param name="buy_price">Buy price.</param>
		/// <param name="sell_price">Sell price.</param>
		void setPrice(int item, int buy_price = -1, int sell_price = -1);

		/// <summary>
		/// Sets the sell price of an item.
		/// </summary>
		/// <param name="item">Item to set sell price for.</param>
		/// <param name="sell_price">Sell price.</param>
		void setSellPrice(int item, int sell_price);
	}
}