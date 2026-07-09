using System;
using System.Collections;
using System.Collections.Generic;
using PokemonEssentials.RPGMaker;
using PokemonEssentials.RPGMaker.Kernel;

namespace PokemonEssentials
{
	/// <summary>
	/// This class handles common events. It includes execution of parallel process
	/// event. This class is used within the <see cref="IGameMap"/> class (<seealso cref="IGameManager.game_map"/>).
	/// </summary>
	public interface IGameCommonEvent : PokemonEssentials.RPGMaker.ICommonEvent, IHaveUpdate, IHaveRefresh
	{
		/// <summary>
		/// Object Initialization
		/// </summary>
		/// <param name="common_event_id">common event ID</param>
		IGameCommonEvent initialize(int common_event_id);
		//void initialize(int common_event_id);
		/// <summary>
		/// Get Name
		/// </summary>
		string name { get; }
		/// <summary>
		/// Get Trigger
		/// </summary>
		int trigger { get; }
		/// <summary>
		/// Get Condition Switch ID
		/// </summary>
		int switch_id { get; }
		/// <summary>
		/// Get List of Event Commands
		/// </summary>
		IList<IEventCommand> list { get; }
		/// <summary>
		/// Checks if switch is on
		/// </summary>
		/// <param name="id"></param>
		/// <returns></returns>
		bool switchIsOn(int id);
		/// <summary>
		/// Refresh
		/// </summary>
		void refresh();
		/// <summary>
		/// Frame Update
		/// </summary>
		void update();
	}
}