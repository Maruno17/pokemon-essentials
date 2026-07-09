using System;
using System.Collections.Generic;

namespace PokemonEssentials.Data
{
    /// <summary>
    /// Interface for ShadowPokemon data, representing Shadow Pokemon and their properties.
    /// Provides read-only access to Shadow Pokemon information including gauge size, moves, and flags.
    /// </summary>
    public interface IShadowPokemon
    {
        /// <summary>
        /// Gets the unique identifier for this Shadow Pokemon entry.
        /// </summary>
        int id { get; }

        /// <summary>
        /// Gets the base species identifier.
        /// </summary>
        int species { get; }

        /// <summary>
        /// Gets the form number for this species.
        /// </summary>
        int form { get; }

        /// <summary>
        /// Gets the collection of moves this Shadow Pokemon knows.
        /// These are typically special Shadow moves.
        /// </summary>
        IList<IMove> moves { get; }

        /// <summary>
        /// Gets the heart gauge size for this Shadow Pokemon.
        /// Determines how much purification is needed to return to normal.
        /// </summary>
        int gauge_size { get; }

        /// <summary>
        /// Gets the collection of flags associated with this Shadow Pokemon.
        /// Flags provide additional metadata and special properties.
        /// </summary>
        IList<string> flags { get; }

        /// <summary>
        /// Gets the PBS file suffix for this Shadow Pokemon entry.
        /// Used for organizing and loading related data files.
        /// </summary>
        string pbs_file_suffix { get; }

        /// <summary>
        /// Checks if this Shadow Pokemon has a specific flag.
        /// </summary>
        /// <param name="flag">The flag to check for (case-insensitive)</param>
        /// <returns>True if the Shadow Pokemon has the specified flag, false otherwise</returns>
        bool has_flag(string flag);

        /// <summary>
        /// Gets a property value for PBS data export.
        /// </summary>
        /// <param name="key">The property key to retrieve</param>
        /// <returns>The property value, or null if the value should be omitted</returns>
        object get_property_for_PBS(string key);
    }
}