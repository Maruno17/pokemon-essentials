using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials.Data
{
    /// <summary>
    /// Represents a status condition that can affect Pokemon in battle.
    /// </summary>
    /// <remarks>
    /// Status conditions are persistent effects that can alter Pokemon behavior,
    /// stats, or abilities during battle. Each status has an associated animation
    /// and icon position for visual representation. The graphics files automatically
    /// handle varying numbers of status conditions, with special icons for fainted
    /// and Pokérus states at the bottom of the graphics.
    /// </remarks>
    public interface IStatus
    {
        /// <summary>
        /// Gets the unique identifier for this status condition.
        /// </summary>
        object id { get; }

        /// <summary>
        /// Gets the untranslated name of this status condition.
        /// </summary>
        string real_name { get; }

        /// <summary>
        /// Gets the animation name associated with this status condition.
        /// </summary>
        /// <remarks>
        /// This refers to the animation that plays when the status condition
        /// is applied or is active during battle.
        /// </remarks>
        string animation { get; }

        /// <summary>
        /// Gets the position of this status's icon within the statuses.png file.
        /// </summary>
        /// <remarks>
        /// This value corresponds to the position in the Graphics/UI/statuses.png
        /// and Graphics/UI/Battle/icon_statuses.png files where the icon for this
        /// status condition is located.
        /// </remarks>
        int icon_position { get; }

        /// <summary>
        /// Gets the data collection for all registered status conditions.
        /// </summary>
        IDictionary DATA { get; }

        /// <summary>
        /// Gets the standard icon size for status condition graphics.
        /// </summary>
        /// <remarks>
        /// Returns the dimensions [width, height] used for status icons in pixels.
        /// </remarks>
        int[] ICON_SIZE { get; }

        /// <summary>
        /// Loads status condition data from storage.
        /// </summary>
        void load();

        /// <summary>
        /// Saves status condition data to storage.
        /// </summary>
        void save();

        /// <summary>
        /// Gets the translated name of this status condition.
        /// </summary>
        /// <returns>The localized name of the status condition.</returns>
        string name();
    }
}