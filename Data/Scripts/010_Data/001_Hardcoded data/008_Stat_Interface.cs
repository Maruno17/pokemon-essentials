using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials.Data
{
    /// <summary>
    /// Represents a stat that defines Pokemon attributes and battle mechanics.
    /// </summary>
    /// <remarks>
    /// Stats define the numerical attributes of Pokemon, including both permanent stats
    /// like HP and Attack, as well as battle-only stats like Accuracy and Evasion.
    /// The pbs_order determines the sequence in which stats are written in PBS files
    /// for base stats, IVs, EVs, and EV yields. Only stats yielded by each_main
    /// can have stat numbers defined in PBS files.
    /// </remarks>
    public interface IStat
    {
        /// <summary>
        /// Gets the unique identifier for this stat.
        /// </summary>
        object id { get; }

        /// <summary>
        /// Gets the untranslated full name of this stat.
        /// </summary>
        string real_name { get; }

        /// <summary>
        /// Gets the untranslated brief name of this stat.
        /// </summary>
        string real_name_brief { get; }

        /// <summary>
        /// Gets the type category of this stat.
        /// </summary>
        /// <remarks>
        /// Stat types include:
        /// - :main - Core permanent stats (HP)
        /// - :main_battle - Core stats that have battle stages (Attack, Defense, etc.)
        /// - :battle - Battle-only stats (Accuracy, Evasion)
        /// </remarks>
        object type { get; }

        /// <summary>
        /// Gets the order position for PBS file serialization.
        /// </summary>
        /// <remarks>
        /// This value determines the order in which stats are written in PBS files.
        /// Values should start with 0 and increase without gaps. Only applies to
        /// stats that are yielded by the each_main method.
        /// </remarks>
        int pbs_order { get; }

        /// <summary>
        /// Gets the data collection for all registered stats.
        /// </summary>
        IDictionary DATA { get; }

        /// <summary>
        /// Loads stat data from storage.
        /// </summary>
        void load();

        /// <summary>
        /// Saves stat data to storage.
        /// </summary>
        void save();

        /// <summary>
        /// Iterates through main stats that are defined in PBS files.
        /// </summary>
        /// <remarks>
        /// Yields stats of type :main and :main_battle which have pbs_order property.
        /// These stats appear in base stats, IVs, EVs, and EV yield definitions.
        /// </remarks>
        void each_main();

        /// <summary>
        /// Iterates through main battle stats only.
        /// </summary>
        /// <remarks>
        /// Yields only stats of type :main_battle which have both PBS representation
        /// and associated battle stage mechanics.
        /// </remarks>
        void each_main_battle();

        /// <summary>
        /// Iterates through stats that have associated battle stages.
        /// </summary>
        /// <remarks>
        /// Yields stats of type :main_battle and :battle which can be modified
        /// by stat stage changes during battle.
        /// </remarks>
        void each_battle();

        /// <summary>
        /// Gets the translated full name of this stat.
        /// </summary>
        /// <returns>The localized full name of the stat.</returns>
        string name();

        /// <summary>
        /// Gets the translated brief name of this stat.
        /// </summary>
        /// <returns>The localized brief name of the stat.</returns>
        string name_brief();
    }
}