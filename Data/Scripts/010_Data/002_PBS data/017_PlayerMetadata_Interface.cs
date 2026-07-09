using System;
using System.Collections.Generic;

namespace PokemonEssentials.Data
{
    /// <summary>
    /// Interface for PlayerMetadata data, representing player-specific metadata and visual settings.
    /// Provides read-only access to player configuration including trainer type, charsets, and home location.
    /// </summary>
    public interface IPlayerMetadata
    {
        /// <summary>
        /// Gets the unique identifier for this player metadata entry.
        /// </summary>
        int id { get; }

        /// <summary>
        /// Gets the trainer type for this player.
        /// </summary>
        ITrainerType trainer_type { get; }

        /// <summary>
        /// Gets the charset used while the player is still or walking.
        /// </summary>
        string walk_charset { get; }

        /// <summary>
        /// Gets the charset used while the player is running.
        /// Uses walk_charset if undefined.
        /// </summary>
        string run_charset { get; }

        /// <summary>
        /// Gets the charset used while the player is cycling.
        /// Uses run_charset if undefined.
        /// </summary>
        string cycle_charset { get; }

        /// <summary>
        /// Gets the charset used while the player is surfing.
        /// Uses cycle_charset if undefined.
        /// </summary>
        string surf_charset { get; }

        /// <summary>
        /// Gets the charset used while the player is diving.
        /// Uses surf_charset if undefined.
        /// </summary>
        string dive_charset { get; }

        /// <summary>
        /// Gets the charset used while the player is fishing.
        /// Uses walk_charset if undefined.
        /// </summary>
        string fish_charset { get; }

        /// <summary>
        /// Gets the charset used while the player is fishing while surfing.
        /// Uses fish_charset if undefined.
        /// </summary>
        string surf_fish_charset { get; }

        /// <summary>
        /// Gets the home location coordinates for this player.
        /// Contains map ID and X/Y coordinates where the player goes after a loss if no Pokemon Center was visited.
        /// </summary>
        int[] home { get; }

        /// <summary>
        /// Gets the PBS file suffix for this player metadata entry.
        /// Used for organizing and loading related data files.
        /// </summary>
        string pbs_file_suffix { get; }
    }
}