using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials.Data
{
	/// <summary>
	/// Represents the target system for Pokémon battles.
	/// </summary>
	/// <remarks>
	/// This interface defines the functionality for managing battle targets,
	/// including target selection, validation, and state management.
	/// </remarks>
	public interface ITarget
	{
		/// <summary>
		/// Gets the unique identifier for this target.
		/// </summary>
		int id { get; }

		/// <summary>
		/// Gets the untranslated name of this target.
		/// </summary>
		string real_name { get; }

		/// <summary>
		/// Gets the data collection for all registered egg groups.
		/// </summary>
		IDictionary DATA { get; }

		/// <summary>
		/// Initializes the target system.
		/// </summary>
		ITarget Initialize(int id, string name, int num_targets = 0, bool targets_foe = false, bool targets_all = false, bool affects_foe_side = false, bool long_range = false);

		/// <summary>
		/// Loads target data from storage.
		/// </summary>
		void load();

		/// <summary>
		/// Saves target data to storage.
		/// </summary>
		void save();

		/// <summary>
		/// Gets the translated name of this target.
		/// </summary>
		/// <returns>The localized name of the target.</returns>
		//string name();
		string name { get; }

		bool can_choose_distant_target { get; }

		bool can_target_one_foe { get; }
	}
}