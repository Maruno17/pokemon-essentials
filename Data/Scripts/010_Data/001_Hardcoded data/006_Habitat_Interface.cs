using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials.Data
{
    /// <summary>
    /// Represents a habitat that describes the natural environment where Pokemon are found.
    /// </summary>
    /// <remarks>
    /// Habitats categorize Pokemon by their preferred living environments,
    /// such as forests, grasslands, or urban areas. This information can be
    /// used for Pokedex entries, search functionality, and environmental
    /// context for Pokemon encounters and behaviors.
    /// </remarks>
    public interface IHabitat
    {
        /// <summary>
        /// Gets the unique identifier for this habitat.
        /// </summary>
        object id { get; }

        /// <summary>
        /// Gets the untranslated name of this habitat.
        /// </summary>
        string real_name { get; }

        /// <summary>
        /// Gets the data collection for all registered habitats.
        /// </summary>
        IDictionary DATA { get; }

        /// <summary>
        /// Loads habitat data from storage.
        /// </summary>
        void load();

        /// <summary>
        /// Saves habitat data to storage.
        /// </summary>
        void save();

        /// <summary>
        /// Gets the translated name of this habitat.
        /// </summary>
        /// <returns>The localized name of the habitat.</returns>
        string name();
    }
}