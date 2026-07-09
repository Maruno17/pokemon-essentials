using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials.Data
{
    /// <summary>
    /// Represents a nature that affects Pokemon stat growth and personality.
    /// </summary>
    /// <remarks>
    /// Natures provide stat modifications to Pokemon, typically increasing one
    /// stat by 10% while decreasing another by 10%. Some natures are neutral
    /// and provide no stat changes. Each nature also influences Pokemon
    /// personality and behavior characteristics in various game mechanics.
    /// </remarks>
    public interface INature
    {
        /// <summary>
        /// Gets the unique identifier for this nature.
        /// </summary>
        object id { get; }

        /// <summary>
        /// Gets the untranslated name of this nature.
        /// </summary>
        string real_name { get; }

        /// <summary>
        /// Gets the stat changes applied by this nature.
        /// </summary>
        /// <remarks>
        /// Contains an array of stat modifications where each entry is a pair
        /// consisting of a stat identifier and a percentage change value.
        /// For example: [[:ATTACK, 10], [:DEFENSE, -10]] increases Attack by 10%
        /// and decreases Defense by 10%.
        /// </remarks>
        IList stat_changes { get; }

        /// <summary>
        /// Gets the data collection for all registered natures.
        /// </summary>
        IDictionary DATA { get; }

        /// <summary>
        /// Loads nature data from storage.
        /// </summary>
        void load();

        /// <summary>
        /// Saves nature data to storage.
        /// </summary>
        void save();

        /// <summary>
        /// Gets the translated name of this nature.
        /// </summary>
        /// <returns>The localized name of the nature.</returns>
        string name();
    }
}