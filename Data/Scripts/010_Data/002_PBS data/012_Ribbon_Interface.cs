using System;
using System.Collections.Generic;

namespace PokemonEssentials.Data
{
    /// <summary>
    /// Interface for Ribbon data, representing Pokemon ribbons and their properties.
    /// Provides read-only access to ribbon information including names, descriptions, icons, and flags.
    /// </summary>
    public interface IRibbon
    {
        /// <summary>
        /// Gets the unique identifier for this ribbon.
        /// </summary>
        int id { get; }

        /// <summary>
        /// Gets the real name of the ribbon as stored in the data files.
        /// </summary>
        string real_name { get; }

        /// <summary>
        /// Gets the icon position within the ribbons.png file.
        /// Specifies where this ribbon's graphic is located in the ribbon icon sheet.
        /// </summary>
        int icon_position { get; }

        /// <summary>
        /// Gets the real description of the ribbon as stored in the data files.
        /// </summary>
        string real_description { get; }

        /// <summary>
        /// Gets the collection of flags associated with this ribbon.
        /// Flags provide additional metadata and special properties.
        /// </summary>
        IList<string> flags { get; }

        /// <summary>
        /// Gets the PBS file suffix for this ribbon entry.
        /// Used for organizing and loading related data files.
        /// </summary>
        string pbs_file_suffix { get; }

        /// <summary>
        /// Gets the translated name of this ribbon for display to players.
        /// This method retrieves the localized name from the message system.
        /// </summary>
        /// <returns>The translated ribbon name</returns>
        string name { get; }

        /// <summary>
        /// Gets the translated description of this ribbon for display to players.
        /// This method retrieves the localized description from the message system.
        /// </summary>
        /// <returns>The translated ribbon description</returns>
        string description { get; }

        /// <summary>
        /// Checks if this ribbon has a specific flag.
        /// </summary>
        /// <param name="flag">The flag to check for (case-insensitive)</param>
        /// <returns>True if the ribbon has the specified flag, false otherwise</returns>
        bool has_flag(string flag);
    }
}