using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials.Data
{
    /// <summary>
    /// Represents a body color that categorizes Pokemon by their predominant color.
    /// </summary>
    /// <remarks>
    /// Body colors are used in the Pokedex search functionality to filter Pokemon
    /// by their primary color scheme. This provides an additional search criterion
    /// for players looking for Pokemon with specific visual characteristics.
    /// The order of registration determines the display order in the search screen.
    /// </remarks>
    public interface IBodyColor
    {
        /// <summary>
        /// Gets the unique identifier for this body color.
        /// </summary>
        object id { get; }

        /// <summary>
        /// Gets the untranslated name of this body color.
        /// </summary>
        string real_name { get; }

        /// <summary>
        /// Gets the data collection for all registered body colors.
        /// </summary>
        IDictionary DATA { get; }

        /// <summary>
        /// Loads body color data from storage.
        /// </summary>
        void load();

        /// <summary>
        /// Saves body color data to storage.
        /// </summary>
        void save();

        /// <summary>
        /// Gets the translated name of this body color.
        /// </summary>
        /// <returns>The localized name of the body color.</returns>
        string name();
    }
}