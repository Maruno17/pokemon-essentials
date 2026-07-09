using System;
using System.Collections.Generic;

namespace PokemonEssentials.Data
{
    /// <summary>
    /// Interface for TownMap data, representing regions in the game's map system.
    /// Provides read-only access to town map data including identification, names, file references, points, and flags.
    /// </summary>
    public interface ITownMap
    {
        /// <summary>
        /// Gets the unique identifier for this town map.
        /// </summary>
        int id { get; }

        /// <summary>
        /// Gets the real name of the region as stored in the data files.
        /// </summary>
        string real_name { get; }

        /// <summary>
        /// Gets the filename associated with this town map.
        /// </summary>
        string filename { get; }

        /// <summary>
        /// Gets the collection of point data for this town map.
        /// Contains coordinates and related point information.
        /// </summary>
        IList<int> point { get; }

        /// <summary>
        /// Gets the collection of flags associated with this town map.
        /// Flags provide additional metadata and configuration options.
        /// </summary>
        IList<string> flags { get; }

        /// <summary>
        /// Gets the PBS file suffix for this town map entry.
        /// Used for organizing and loading related data files.
        /// </summary>
        string pbs_file_suffix { get; }

        /// <summary>
        /// Gets the translated name of this region for display to players.
        /// This method retrieves the localized name from the message system.
        /// </summary>
        /// <returns>The translated region name</returns>
        string name { get; }

        /// <summary>
        /// Checks if this town map has a specific flag.
        /// </summary>
        /// <param name="flag">The flag to check for (case-insensitive)</param>
        /// <returns>True if the town map has the specified flag, false otherwise</returns>
        bool has_flag(string flag);
    }
}