using System;
using System.Collections.Generic;

namespace PokemonEssentials.Data
{
    /// <summary>
    /// Interface for MapMetadata data, representing map-specific metadata and settings.
    /// Provides read-only access to map configuration including environment, audio, visual effects, and special behaviors.
    /// </summary>
    public interface IMapMetadata
    {
        /// <summary>
        /// Gets the unique identifier for this map metadata entry.
        /// </summary>
        int id { get; }

        /// <summary>
        /// Gets the real name of the map as stored in the data files.
        /// </summary>
        string real_name { get; }

        /// <summary>
        /// Gets whether this map is an outdoor map.
        /// Outdoor maps are tinted according to time of day.
        /// </summary>
        bool outdoor_map { get; }

        /// <summary>
        /// Gets whether the game will display the map's name upon entry.
        /// </summary>
        bool announce_location { get; }

        /// <summary>
        /// Gets whether the bicycle can be used on this map.
        /// </summary>
        bool can_bicycle { get; }

        /// <summary>
        /// Gets whether the bicycle will be mounted automatically on this map and cannot be dismounted.
        /// </summary>
        bool always_bicycle { get; }

        /// <summary>
        /// Gets the teleport destination for this Pokemon Center.
        /// Contains map ID and X/Y coordinates of the healing spot entrance.
        /// </summary>
        int[] teleport_destination { get; }

        /// <summary>
        /// Gets the weather conditions in effect for this map.
        /// </summary>
        object weather { get; }

        /// <summary>
        /// Gets the town map position coordinates.
        /// Identifies the point on the regional map for this map.
        /// </summary>
        int[] town_map_position { get; }

        /// <summary>
        /// Gets the underwater layer map ID for this map.
        /// Used only if this map has deep water for diving.
        /// </summary>
        int? dive_map_id { get; }

        /// <summary>
        /// Gets whether this map is dark.
        /// Dark maps show a circle of light around the player, expandable with Flash.
        /// </summary>
        bool dark_map { get; }

        /// <summary>
        /// Gets whether this map is part of the Safari Zone.
        /// </summary>
        bool safari_map { get; }

        /// <summary>
        /// Gets whether to snap to edges.
        /// When true, the game doesn't center the player as usual near map edges.
        /// </summary>
        bool snap_edges { get; }

        /// <summary>
        /// Gets whether reflections remain still.
        /// When true, reflections of events and the player will not ripple horizontally.
        /// </summary>
        bool still_reflections { get; }

        /// <summary>
        /// Gets whether this map has a randomly generated layout.
        /// </summary>
        bool random_dungeon { get; }

        /// <summary>
        /// Gets the battle background identifier for this map.
        /// References PNG files in the Battlebacks folder.
        /// </summary>
        string battle_background { get; }

        /// <summary>
        /// Gets the default BGM for wild Pokemon battles on this map.
        /// </summary>
        string wild_battle_BGM { get; }

        /// <summary>
        /// Gets the default BGM for trainer battles on this map.
        /// </summary>
        string trainer_battle_BGM { get; }

        /// <summary>
        /// Gets the default BGM played after winning a wild Pokemon battle on this map.
        /// </summary>
        string wild_victory_BGM { get; }

        /// <summary>
        /// Gets the default BGM played after winning a trainer battle on this map.
        /// </summary>
        string trainer_victory_BGM { get; }

        /// <summary>
        /// Gets the default ME played after catching a wild Pokemon on this map.
        /// </summary>
        string wild_capture_ME { get; }

        /// <summary>
        /// Gets the town map size information.
        /// Contains width and layout data for the Town Map squares.
        /// </summary>
        object town_map_size { get; }

        /// <summary>
        /// Gets the default battle environment for battles on this map.
        /// </summary>
        object battle_environment { get; }

        /// <summary>
        /// Gets the collection of flags associated with this map.
        /// Flags distinguish this map from others with special behaviors.
        /// </summary>
        IList<string> flags { get; }

        /// <summary>
        /// Gets the PBS file suffix for this map metadata entry.
        /// Used for organizing and loading related data files.
        /// </summary>
        string pbs_file_suffix { get; }

        /// <summary>
        /// Gets the translated name of the map for display to players.
        /// This method retrieves the localized name from the message system.
        /// </summary>
        /// <returns>The translated map name</returns>
        string name { get; }

        /// <summary>
        /// Checks if this map has a specific flag.
        /// </summary>
        /// <param name="flag">The flag to check for (case-insensitive)</param>
        /// <returns>True if the map has the specified flag, false otherwise</returns>
        bool has_flag(string flag);
    }
}