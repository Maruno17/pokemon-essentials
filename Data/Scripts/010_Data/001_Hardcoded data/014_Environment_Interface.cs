using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials.Data
{
	/// <summary>
	/// </summary>
	public interface IEnvironment
	{
		/// <summary>
		/// Gets the unique identifier for this environment.
		/// </summary>
		int id { get; }

		/// <summary>
		/// Gets the untranslated name of this environment.
		/// </summary>
		string real_name { get; }

		string battle_base { get; }

		/// <summary>
		/// Gets the data collection for all registered egg groups.
		/// </summary>
		IDictionary DATA { get; }

		IEnvironment initialize(int id, string name, string battle_base);

		/// <summary>
		/// Loads environment data from storage.
		/// </summary>
		void load();

		/// <summary>
		/// Saves environment data to storage.
		/// </summary>
		void save();

		/// <summary>
		/// Gets the translated name of this environment.
		/// </summary>
		/// <returns>The localized name of the environment.</returns>
		//string name();
		string name { get; }
	}
}