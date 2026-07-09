using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Represents a utility class for expanding autotile bitmaps.
    /// </summary>
    /// <remarks>
    /// This interface defines the functionality for expanding autotile bitmaps into a format
    /// that can be easily used for rendering, including:
    /// - Converting autotile patterns into individual tiles
    /// - Handling different autotile layouts
    /// - Managing bitmap transformations
    /// </remarks>
    public interface IAutotileExpander
    {
        /// <summary>
        /// Expands an autotile bitmap into individual tiles.
        /// </summary>
        /// <param name="bitmap">The autotile bitmap to expand.</param>
        /// <returns>An expanded bitmap containing all possible autotile combinations.</returns>
        /// <remarks>
        /// Converts an autotile bitmap into a format where each possible combination
        /// of the autotile is represented as a separate tile. This makes it easier to
        /// render autotiles in the game.
        /// </remarks>
        //static IBitmap expand(IBitmap bitmap);

        /// <summary>
        /// Gets the number of tiles per autotile.
        /// </summary>
        /// <remarks>
        /// The number of different tile combinations that can be created from a single autotile.
        /// </remarks>
        int TILES_PER_AUTOTILE { get; }

        /// <summary>
        /// Gets the width of a source tile.
        /// </summary>
        /// <remarks>
        /// The width of a single tile in the source bitmap.
        /// </remarks>
        int SOURCE_TILE_WIDTH { get; }

        /// <summary>
        /// Gets the height of a source tile.
        /// </summary>
        /// <remarks>
        /// The height of a single tile in the source bitmap.
        /// </remarks>
        int SOURCE_TILE_HEIGHT { get; }
    }
}