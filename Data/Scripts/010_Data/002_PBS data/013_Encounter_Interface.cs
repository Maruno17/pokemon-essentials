using System;
using System.Collections.Generic;

namespace PokemonEssentials.Data
{
    /// <summary>
    /// Interface for Encounter data, representing wild Pokemon encounter tables for maps.
    /// Provides access to encounter information including step chances, encounter types, and map versions.
    /// </summary>
    public interface IEncounter
    {
        /// <summary>
        /// Gets or sets the unique identifier for this encounter table.
        /// </summary>
        int id { get; set; }

        /// <summary>
        /// Gets or sets the map ID this encounter table belongs to.
        /// </summary>
        int map { get; set; }

        /// <summary>
        /// Gets or sets the version number for this encounter table.
        /// Allows different encounter tables for the same map.
        /// </summary>
        int version { get; set; }

        /// <summary>
        /// Gets the step chances for encounters.
        /// Determines the likelihood of encounters based on movement.
        /// </summary>
        object step_chances { get; }

        /// <summary>
        /// Gets the encounter types and their associated Pokemon data.
        /// Contains different encounter methods (grass, water, etc.) and their Pokemon lists.
        /// </summary>
        IDictionary<string, object> types { get; }

        /// <summary>
        /// Gets the PBS file suffix for this encounter entry.
        /// Used for organizing and loading related data files.
        /// </summary>
        string pbs_file_suffix { get; }
    }
}