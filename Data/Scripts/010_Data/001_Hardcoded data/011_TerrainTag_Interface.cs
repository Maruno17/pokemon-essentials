using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials.Data
{
    /// <summary>
    /// Represents a terrain tag that defines tile properties and behaviors in the game world.
    /// </summary>
    /// <remarks>
    /// Terrain tags define the properties and behaviors of map tiles, including movement
    /// restrictions, encounter types, visual effects, and environmental interactions.
    /// These tags control fundamental game mechanics such as surfing, fishing, wild
    /// encounters, battle environments, and special movement behaviors like ledges and ice.
    /// </remarks>
    public interface ITerrainTag
    {
        /// <summary>
        /// Gets the unique symbol identifier for this terrain tag.
        /// </summary>
        object id { get; }

        /// <summary>
        /// Gets the numeric identifier for this terrain tag used in map data.
        /// </summary>
        int id_number { get; }

        /// <summary>
        /// Gets the untranslated name of this terrain tag.
        /// </summary>
        string real_name { get; }

        /// <summary>
        /// Gets whether Pokemon can surf on this terrain.
        /// </summary>
        bool can_surf { get; }

        /// <summary>
        /// Gets whether this terrain represents the main part of a waterfall.
        /// </summary>
        /// <remarks>
        /// This excludes the waterfall crest area.
        /// </remarks>
        bool waterfall { get; }

        /// <summary>
        /// Gets whether this terrain represents a waterfall crest.
        /// </summary>
        bool waterfall_crest { get; }

        /// <summary>
        /// Gets whether Pokemon can fish in this terrain.
        /// </summary>
        bool can_fish { get; }

        /// <summary>
        /// Gets whether Pokemon can dive in this terrain.
        /// </summary>
        bool can_dive { get; }

        /// <summary>
        /// Gets whether this terrain represents deep bush/tall grass.
        /// </summary>
        bool deep_bush { get; }

        /// <summary>
        /// Gets whether this terrain shows grass rustle effects.
        /// </summary>
        bool shows_grass_rustle { get; }

        /// <summary>
        /// Gets whether this terrain shows water ripple effects.
        /// </summary>
        bool shows_water_ripple { get; }

        /// <summary>
        /// Gets whether this terrain can trigger land-based wild encounters.
        /// </summary>
        bool land_wild_encounters { get; }

        /// <summary>
        /// Gets whether this terrain can trigger double wild encounters.
        /// </summary>
        bool double_wild_encounters { get; }

        /// <summary>
        /// Gets the battle environment associated with this terrain.
        /// </summary>
        /// <remarks>
        /// Determines the background and environmental effects used in battles
        /// that occur on this terrain type.
        /// </remarks>
        IEnvironment battle_environment { get; }

        /// <summary>
        /// Gets whether this terrain represents a ledge that can be jumped down.
        /// </summary>
        bool ledge { get; }

        /// <summary>
        /// Gets whether this terrain is ice that affects movement.
        /// </summary>
        bool ice { get; }

        /// <summary>
        /// Gets whether this terrain represents a bridge.
        /// </summary>
        bool bridge { get; }

        /// <summary>
        /// Gets whether this terrain shows reflection effects.
        /// </summary>
        bool shows_reflections { get; }

        /// <summary>
        /// Gets whether the player must walk (not run) on this terrain.
        /// </summary>
        bool must_walk { get; }

        /// <summary>
        /// Gets whether the player must walk or run (no other movement) on this terrain.
        /// </summary>
        bool must_walk_or_run { get; }

        /// <summary>
        /// Gets whether this terrain ignores normal passability rules.
        /// </summary>
        bool ignore_passability { get; }

        /// <summary>
        /// Gets the data collection for all registered terrain tags.
        /// </summary>
        IDictionary DATA { get; }

        /// <summary>
        /// Attempts to get a terrain tag, returning a default if not found.
        /// </summary>
        /// <param name="other">The terrain tag identifier to look up.</param>
        /// <returns>The found terrain tag or the None terrain tag if not found.</returns>
        ITerrainTag try_get(object other);

        /// <summary>
        /// Loads terrain tag data from storage.
        /// </summary>
        void load();

        /// <summary>
        /// Saves terrain tag data to storage.
        /// </summary>
        void save();

        /// <summary>
        /// Gets the name of this terrain tag (alias for real_name).
        /// </summary>
        /// <returns>The name of the terrain tag.</returns>
        string name();

        /// <summary>
        /// Gets whether Pokemon can surf freely on this terrain.
        /// </summary>
        /// <remarks>
        /// Returns true if can_surf is true and the terrain is not a waterfall
        /// or waterfall crest, allowing unrestricted surfing movement.
        /// </remarks>
        /// <returns>True if free surfing is allowed, false otherwise.</returns>
        bool can_surf_freely();
    }
}