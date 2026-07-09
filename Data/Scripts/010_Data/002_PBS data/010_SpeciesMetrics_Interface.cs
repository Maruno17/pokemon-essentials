using System;
using System.Collections.Generic;

namespace PokemonEssentials.Data
{
    /// <summary>
    /// Interface for SpeciesMetrics data, representing sprite positioning and shadow metrics for Pokemon species.
    /// Provides access to sprite positioning information for proper display in battle and other screens.
    /// </summary>
    public interface ISpeciesMetrics
    {
        /// <summary>
        /// Gets the unique identifier for this species metrics entry.
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
        /// Gets or sets the back sprite positioning offset.
        /// Contains X and Y offset values for the back sprite.
        /// </summary>
        int[] back_sprite { get; set; }

        /// <summary>
        /// Gets or sets the front sprite positioning offset.
        /// Contains X and Y offset values for the front sprite.
        /// </summary>
        int[] front_sprite { get; set; }

        /// <summary>
        /// Gets or sets the front sprite altitude.
        /// Used for flying or floating Pokemon to adjust their vertical position.
        /// </summary>
        int front_sprite_altitude { get; set; }

        /// <summary>
        /// Gets or sets the shadow X offset.
        /// Horizontal positioning adjustment for the shadow sprite.
        /// </summary>
        int shadow_x { get; set; }

        /// <summary>
        /// Gets or sets the shadow size.
        /// Determines which shadow graphic to use based on the Pokemon's size.
        /// </summary>
        int shadow_size { get; set; }

        /// <summary>
        /// Gets the PBS file suffix for this species metrics entry.
        /// Used for organizing and loading related data files.
        /// </summary>
        string pbs_file_suffix { get; }

        /// <summary>
        /// Applies positioning metrics to a sprite for proper display.
        /// </summary>
        /// <param name="sprite">The sprite to apply metrics to</param>
        /// <param name="index">The sprite index (determines if player or foe sprite)</param>
        /// <param name="shadow">Whether this is for a shadow sprite</param>
        void apply_metrics_to_sprite(ISprite sprite, int index, bool shadow = false);

        /// <summary>
        /// Checks if this species should show a shadow.
        /// </summary>
        /// <returns>True if the species should show a shadow, false otherwise</returns>
        bool shows_shadow();

        /// <summary>
        /// Gets a property value for PBS data export.
        /// </summary>
        /// <param name="key">The property key to retrieve</param>
        /// <returns>The property value, or null if the value should be omitted</returns>
        object get_property_for_PBS(string key);
    }
}