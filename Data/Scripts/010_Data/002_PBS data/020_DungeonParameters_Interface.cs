using System;
using System.Collections.Generic;

namespace PokemonEssentials.Data
{
    /// <summary>
    /// Interface for DungeonParameters data, representing parameters for randomly generated dungeon layouts.
    /// Provides read-only access to dungeon generation settings including size, room configuration, and decoration options.
    /// </summary>
    public interface IDungeonParameters
    {
        /// <summary>
        /// Gets the unique identifier for this dungeon parameters set.
        /// </summary>
        int id { get; }

        /// <summary>
        /// Gets the area identifier for this dungeon.
        /// </summary>
        int area { get; }

        /// <summary>
        /// Gets the version number for this dungeon parameters set.
        /// </summary>
        int version { get; }

        /// <summary>
        /// Gets the number of cells in the X direction.
        /// </summary>
        int cell_count_x { get; }

        /// <summary>
        /// Gets the number of cells in the Y direction.
        /// </summary>
        int cell_count_y { get; }

        /// <summary>
        /// Gets the width of each cell in tiles.
        /// </summary>
        int cell_width { get; }

        /// <summary>
        /// Gets the height of each cell in tiles.
        /// </summary>
        int cell_height { get; }

        /// <summary>
        /// Gets the minimum width for rooms.
        /// </summary>
        int room_min_width { get; }

        /// <summary>
        /// Gets the minimum height for rooms.
        /// </summary>
        int room_min_height { get; }

        /// <summary>
        /// Gets the maximum width for rooms.
        /// </summary>
        int room_max_width { get; }

        /// <summary>
        /// Gets the maximum height for rooms.
        /// </summary>
        int room_max_height { get; }

        /// <summary>
        /// Gets the width of corridors connecting rooms.
        /// </summary>
        int corridor_width { get; }

        /// <summary>
        /// Gets whether corridors should have random shifts.
        /// Adds variation to corridor paths.
        /// </summary>
        bool random_corridor_shift { get; }

        /// <summary>
        /// Gets the node layout pattern for dungeon generation.
        /// Determines which nodes are active in the dungeon grid.
        /// Possible values: :full, :no_corners, :ring, :antiring, :plus, :diagonal_up, :diagonal_down, :cross, :quadrants
        /// </summary>
        object node_layout { get; }

        /// <summary>
        /// Gets the room layout pattern for dungeon generation.
        /// Determines how rooms are arranged within the active nodes.
        /// </summary>
        object room_layout { get; }

        /// <summary>
        /// Gets the percentage chance that an active roomable node will become a room.
        /// </summary>
        int room_chance { get; }

        /// <summary>
        /// Gets the number of extra connections to add between rooms.
        /// Creates additional paths beyond the minimum required connectivity.
        /// </summary>
        int extra_connections_count { get; }

        /// <summary>
        /// Gets the radius for floor patches.
        /// </summary>
        int floor_patch_radius { get; }

        /// <summary>
        /// Gets the chance for floor patches to appear.
        /// </summary>
        int floor_patch_chance { get; }

        /// <summary>
        /// Gets the smoothing rate for floor patches.
        /// </summary>
        int floor_patch_smooth_rate { get; }

        /// <summary>
        /// Gets the density of regular floor decorations.
        /// </summary>
        int floor_decoration_density { get; }

        /// <summary>
        /// Gets the density of large floor decorations.
        /// </summary>
        int floor_decoration_large_density { get; }

        /// <summary>
        /// Gets the density of regular void decorations.
        /// </summary>
        int void_decoration_density { get; }

        /// <summary>
        /// Gets the density of large void decorations.
        /// </summary>
        int void_decoration_large_density { get; }

        /// <summary>
        /// Gets the random number generator seed for reproducible dungeon generation.
        /// </summary>
        int rng_seed { get; }

        /// <summary>
        /// Gets the collection of flags associated with this dungeon parameters set.
        /// Flags provide additional metadata and special behaviors.
        /// </summary>
        IList<string> flags { get; }

        /// <summary>
        /// Gets the PBS file suffix for this dungeon parameters entry.
        /// Used for organizing and loading related data files.
        /// </summary>
        string pbs_file_suffix { get; }

        /// <summary>
        /// Checks if this dungeon parameters set has a specific flag.
        /// </summary>
        /// <param name="flag">The flag to check for (case-insensitive)</param>
        /// <returns>True if the parameters have the specified flag, false otherwise</returns>
        bool has_flag(string flag);
    }
}