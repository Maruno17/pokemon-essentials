using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials.Data
{
    /// <summary>
    /// Represents an evolution method that defines how Pokemon can evolve.
    /// </summary>
    /// <remarks>
    /// Evolution methods define the conditions under which a Pokemon can evolve
    /// into another species. This includes various triggers such as leveling up,
    /// using items, trading, happiness thresholds, and many other conditions.
    /// Each evolution method contains procedures that check specific conditions
    /// and handle the evolution process.
    /// </remarks>
    public interface IEvolution
    {
        /// <summary>
        /// Gets the unique identifier for this evolution method.
        /// </summary>
        object id { get; }

        /// <summary>
        /// Gets the untranslated name of this evolution method.
        /// </summary>
        string real_name { get; }

        /// <summary>
        /// Gets the parameter type or value required for this evolution method.
        /// </summary>
        object parameter { get; }

        /// <summary>
        /// Gets whether this evolution can trigger on any level up, not just specific levels.
        /// </summary>
        /// <remarks>
        /// When false, the parameter is treated as the minimum level required.
        /// When true, the evolution can occur at any level up if other conditions are met.
        /// </remarks>
        bool any_level_up { get; }

        /// <summary>
        /// Gets the procedure that checks if evolution conditions are met during level up.
        /// </summary>
        object level_up_proc { get; }

        /// <summary>
        /// Gets the procedure that checks if evolution conditions are met during battle level up.
        /// </summary>
        object battle_level_up_proc { get; }

        /// <summary>
        /// Gets the procedure that checks if evolution conditions are met when using an item.
        /// </summary>
        object use_item_proc { get; }

        /// <summary>
        /// Gets the procedure that checks if evolution conditions are met during trading.
        /// </summary>
        object on_trade_proc { get; }

        /// <summary>
        /// Gets the procedure that checks if evolution conditions are met after battle.
        /// </summary>
        object after_battle_proc { get; }

        /// <summary>
        /// Gets the procedure that checks if evolution conditions are met during events.
        /// </summary>
        object event_proc { get; }

        /// <summary>
        /// Gets the procedure that executes after evolution occurs.
        /// </summary>
        object after_evolution_proc { get; }

        /// <summary>
        /// Gets the data collection for all registered evolution methods.
        /// </summary>
        IDictionary DATA { get; }

        /// <summary>
        /// Loads evolution data from storage.
        /// </summary>
        void load();

        /// <summary>
        /// Saves evolution data to storage.
        /// </summary>
        void save();

        /// <summary>
        /// Gets the name of this evolution method (alias for real_name).
        /// </summary>
        /// <returns>The name of the evolution method.</returns>
        string name();

        /// <summary>
        /// Calls the level up procedure to check evolution conditions.
        /// </summary>
        /// <param name="args">Arguments to pass to the level up procedure.</param>
        /// <returns>True if evolution conditions are met, false otherwise.</returns>
        object call_level_up(params object[] args);

        /// <summary>
        /// Calls the battle level up procedure to check evolution conditions.
        /// Falls back to level_up_proc if battle_level_up_proc is not defined.
        /// </summary>
        /// <param name="args">Arguments to pass to the battle level up procedure.</param>
        /// <returns>True if evolution conditions are met, false otherwise.</returns>
        object call_battle_level_up(params object[] args);

        /// <summary>
        /// Calls the use item procedure to check evolution conditions.
        /// </summary>
        /// <param name="args">Arguments to pass to the use item procedure.</param>
        /// <returns>True if evolution conditions are met, false otherwise.</returns>
        object call_use_item(params object[] args);

        /// <summary>
        /// Calls the on trade procedure to check evolution conditions.
        /// </summary>
        /// <param name="args">Arguments to pass to the on trade procedure.</param>
        /// <returns>True if evolution conditions are met, false otherwise.</returns>
        object call_on_trade(params object[] args);

        /// <summary>
        /// Calls the after battle procedure to check evolution conditions.
        /// </summary>
        /// <param name="args">Arguments to pass to the after battle procedure.</param>
        /// <returns>True if evolution conditions are met, false otherwise.</returns>
        object call_after_battle(params object[] args);

        /// <summary>
        /// Calls the event procedure to check evolution conditions.
        /// </summary>
        /// <param name="args">Arguments to pass to the event procedure.</param>
        /// <returns>True if evolution conditions are met, false otherwise.</returns>
        object call_event(params object[] args);

        /// <summary>
        /// Calls the after evolution procedure to handle post-evolution logic.
        /// </summary>
        /// <param name="args">Arguments to pass to the after evolution procedure.</param>
        void call_after_evolution(params object[] args);
    }
}