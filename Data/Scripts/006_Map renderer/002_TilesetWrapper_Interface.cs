using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Represents a wrapper for tileset bitmaps that handles large textures.
    /// </summary>
    /// <remarks>
    /// This interface defines the functionality for managing tileset bitmaps that are too large
    /// to fit in a single texture, including:
    /// - Splitting large textures into manageable chunks
    /// - Managing texture coordinates
    /// - Handling texture wrapping
    /// </remarks>
    public interface ITilesetWrapper : IDisposable
    {
        /// <summary>
        /// Gets the width of the tileset.
        /// </summary>
        int width { get; }

        /// <summary>
        /// Gets the height of the tileset.
        /// </summary>
        int height { get; }

        /// <summary>
        /// Gets whether the tileset has been disposed.
        /// </summary>
        /// <returns>True if the tileset has been disposed; otherwise, false.</returns>
        //bool disposed();

        /// <summary>
        /// Gets a specific tile from the tileset.
        /// </summary>
        /// <param name="x">The x-coordinate of the tile.</param>
        /// <param name="y">The y-coordinate of the tile.</param>
        /// <returns>The tile bitmap at the specified coordinates.</returns>
        IBitmap get_tile(int x, int y);

        /// <summary>
        /// Wraps a tileset bitmap for large textures.
        /// </summary>
        /// <param name="bitmap">The bitmap to wrap.</param>
        /// <returns>A wrapped tileset that can handle large textures.</returns>
        /// <remarks>
        /// Creates a wrapper for a tileset bitmap that is too large to fit in a single texture.
        /// The wrapper splits the bitmap into manageable chunks and handles texture coordinates.
        /// </remarks>
        //static ITilesetWrapper wrapTileset(IBitmap bitmap);
    }
}