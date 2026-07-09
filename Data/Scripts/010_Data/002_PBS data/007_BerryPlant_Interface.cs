using System;
using System.Collections.Generic;

namespace PokemonEssentials.Data
{
    /// <summary>
    /// Interface for BerryPlant data, representing berry plants and their growth properties.
    /// Provides read-only access to berry plant information including growth timing, drying rates, and yield.
    /// </summary>
    public interface IBerryPlant
    {
        /// <summary>
        /// Gets the unique identifier for this berry plant.
        /// </summary>
        int id { get; }

        /// <summary>
        /// Gets the number of hours required for each growth stage.
        /// This determines how long it takes for the berry plant to progress through growth phases.
        /// </summary>
        int hours_per_stage { get; }

        /// <summary>
        /// Gets the amount of moisture lost per hour.
        /// This determines how quickly the plant dries out without watering.
        /// </summary>
        int drying_per_hour { get; }

        /// <summary>
        /// Gets the yield range for this berry plant.
        /// Contains minimum and maximum number of berries that can be harvested.
        /// </summary>
        int[] yield { get; }

        /// <summary>
        /// Gets the PBS file suffix for this berry plant entry.
        /// Used for organizing and loading related data files.
        /// </summary>
        string pbs_file_suffix { get; }

        /// <summary>
        /// Gets the minimum number of berries that can be yielded from this plant.
        /// </summary>
        /// <returns>The minimum yield amount</returns>
        int minimum_yield();

        /// <summary>
        /// Gets the maximum number of berries that can be yielded from this plant.
        /// </summary>
        /// <returns>The maximum yield amount</returns>
        int maximum_yield();
    }
}