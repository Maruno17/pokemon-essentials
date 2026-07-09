using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials.Data
{
    /// <summary>
    /// Represents a body shape that categorizes Pokemon by their physical form.
    /// </summary>
    /// <remarks>
    /// Body shapes are used in the Pokedex search functionality to filter Pokemon
    /// by their general physical appearance. Each shape has an associated icon
    /// in the graphics files for visual representation in the search interface.
    /// The order of registration determines the display order in the search screen.
    /// </remarks>
    public interface IBodyShape
    {
        /// <summary>
        /// Gets the unique identifier for this body shape.
        /// </summary>
        object id { get; }

        /// <summary>
        /// Gets the untranslated name of this body shape.
        /// </summary>
        string real_name { get; }

        /// <summary>
        /// Gets the position of this shape's icon within the icon_shapes.png file.
        /// </summary>
        /// <remarks>
        /// This value corresponds to the position in the Graphics/UI/Pokedex/icon_shapes.png
        /// file where the icon for this body shape is located.
        /// </remarks>
        int icon_position { get; }

        /// <summary>
        /// Gets the data collection for all registered body shapes.
        /// </summary>
        IDictionary DATA { get; }

        /// <summary>
        /// Loads body shape data from storage.
        /// </summary>
        void load();

        /// <summary>
        /// Saves body shape data to storage.
        /// </summary>
        void save();

        /// <summary>
        /// Gets the translated name of this body shape.
        /// </summary>
        /// <returns>The localized name of the body shape.</returns>
        string name();
    }
}