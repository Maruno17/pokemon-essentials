using System;
using System.Collections.Generic;

namespace PokemonEssentials.Data
{
    /// <summary>
    /// Interface for Ability data, representing Pokemon abilities and their properties.
    /// Provides read-only access to ability information including names, descriptions, and flags.
    /// </summary>
    public interface IAbility
    {
        /// <summary>
        /// Gets the unique identifier for this ability.
        /// </summary>
        int id { get; }

        /// <summary>
        /// Gets the real name of the ability as stored in the data files.
        /// </summary>
        string real_name { get; }

        /// <summary>
        /// Gets the real description of the ability as stored in the data files.
        /// </summary>
        string real_description { get; }

        /// <summary>
        /// Gets the collection of flags associated with this ability.
        /// Flags provide additional metadata and special behaviors for the ability.
        /// </summary>
        IList<string> flags { get; }

        /// <summary>
        /// Gets the PBS file suffix for this ability entry.
        /// Used for organizing and loading related data files.
        /// </summary>
        string pbs_file_suffix { get; }

        /// <summary>
        /// Gets the translated name of this ability for display to players.
        /// This method retrieves the localized name from the message system.
        /// </summary>
        /// <returns>The translated ability name</returns>
        string name { get; }

        /// <summary>
        /// Gets the translated description of this ability for display to players.
        /// This method retrieves the localized description from the message system.
        /// </summary>
        /// <returns>The translated ability description</returns>
        string description { get; }

        /// <summary>
        /// Checks if this ability has a specific flag.
        /// </summary>
        /// <param name="flag">The flag to check for (case-insensitive)</param>
        /// <returns>True if the ability has the specified flag, false otherwise</returns>
        bool has_flag(string flag);
    }
}