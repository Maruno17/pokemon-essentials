using System;
using System.Collections.Generic;

namespace PokemonEssentials.Data
{
    /// <summary>
    /// Interface for DungeonTileset data, representing tileset configuration for randomly generated dungeons.
    /// Provides read-only access to tileset properties including tile behavior, grid settings, and visual options.
    /// </summary>
    public interface IDungeonTileset
    {
        /// <summary>
        /// Gets the unique identifier for this dungeon tileset.
        /// </summary>
        int id { get; }

        /// <summary>
        /// Gets the tile type IDs for this tileset.
        /// Maps tile types to their corresponding tileset entries.
        /// </summary>
        IDictionary<string, int> tile_type_ids { get; }

        /// <summary>
        /// Gets whether to snap to large grid.
        /// Large grid means 2x2 tiles for alignment.
        /// </summary>
        bool snap_to_large_grid { get; }

        /// <summary>
        /// Gets whether void tiles use large size.
        /// Large void tiles are 2x2 tiles.
        /// </summary>
        bool large_void_tiles { get; }

        /// <summary>
        /// Gets whether wall tiles use large size.
        /// Large wall tiles are 1x2 or 2x1 tiles depending on side.
        /// </summary>
        bool large_wall_tiles { get; }

        /// <summary>
        /// Gets whether floor tiles use large size.
        /// Large floor tiles are 2x2 tiles.
        /// </summary>
        bool large_floor_tiles { get; }

        /// <summary>
        /// Gets whether to use double walls.
        /// Affects wall thickness in dungeon generation.
        /// </summary>
        bool double_walls { get; }

        /// <summary>
        /// Gets whether to place floor patches under walls.
        /// Affects visual appearance of wall-floor transitions.
        /// </summary>
        bool floor_patch_under_walls { get; }

        /// <summary>
        /// Gets the offset for thin north walls.
        /// Adjusts positioning of north-facing wall tiles.
        /// </summary>
        int thin_north_wall_offset { get; }

        /// <summary>
        /// Gets the collection of flags associated with this dungeon tileset.
        /// Flags provide additional metadata and special behaviors.
        /// </summary>
        IList<string> flags { get; }

        /// <summary>
        /// Gets the PBS file suffix for this dungeon tileset entry.
        /// Used for organizing and loading related data files.
        /// </summary>
        string pbs_file_suffix { get; }

        /// <summary>
        /// Checks if this dungeon tileset has a specific flag.
        /// </summary>
        /// <param name="flag">The flag to check for (case-insensitive)</param>
        /// <returns>True if the tileset has the specified flag, false otherwise</returns>
        bool has_flag(string flag);
    }
}