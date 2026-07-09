using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials.Data
{
    /// <summary>
    /// Represents an egg group that determines Pokemon breeding compatibility.
    /// </summary>
    /// <remarks>
    /// Egg groups are used to determine which Pokemon can breed with each other.
    /// Pokemon in the same egg group can produce offspring when bred together.
    /// This interface defines the core properties and behavior of egg groups.
    /// </remarks>
    public interface IEggGroup
    {
        /// <summary>
        /// Gets the unique identifier for this egg group.
        /// </summary>
        int id { get; }

        /// <summary>
        /// Gets the untranslated name of this egg group.
        /// </summary>
        string real_name { get; }

        /// <summary>
        /// Gets the data collection for all registered egg groups.
        /// </summary>
        IDictionary DATA { get; }

        /// <summary>
        /// Loads egg group data from storage.
        /// </summary>
        void load();

        /// <summary>
        /// Saves egg group data to storage.
        /// </summary>
        void save();

        /// <summary>
        /// Gets the translated name of this egg group.
        /// </summary>
        /// <returns>The localized name of the egg group.</returns>
        //string name();
        string name { get; }
    }
}