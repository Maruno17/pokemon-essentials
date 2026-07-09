using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Represents a cache system for managing game resources.
    /// </summary>
    /// <remarks>
    /// This interface defines the functionality for caching and managing game resources, including:
    /// - Bitmap caching
    /// - Resource loading
    /// - Reference counting
    /// - Resource disposal
    /// </remarks>
    public interface IRPGCache
    {
        /// <summary>
        /// Generates a debug report of the cache contents.
        /// </summary>
        /// <remarks>
        /// Creates a text file containing information about all cached resources,
        /// including their reference counts and dimensions.
        /// </remarks>
        void debug();

        /// <summary>
        /// Sets a key-value pair in the cache.
        /// </summary>
        /// <param name="key">The key to store the object under.</param>
        /// <param name="obj">The object to cache.</param>
        void setKey(object key, object obj);

        /// <summary>
        /// Retrieves an object from the cache.
        /// </summary>
        /// <param name="key">The key to look up.</param>
        /// <returns>The cached object, or null if not found or disposed.</returns>
        object fromCache(object key);

        /// <summary>
        /// Loads a bitmap from a file or creates a new one.
        /// </summary>
        /// <param name="folder_name">The folder containing the bitmap.</param>
        /// <param name="filename">The filename of the bitmap.</param>
        /// <param name="hue">The hue adjustment to apply (0 for none).</param>
        /// <returns>The loaded or created bitmap.</returns>
        /// <remarks>
        /// Loads a bitmap from the specified path, creating a new one if necessary.
        /// Applies hue adjustment if specified and caches the result.
        /// </remarks>
        IBitmap load_bitmap(string folder_name, string filename, int hue = 0);

        /// <summary>
        /// Creates a tile bitmap from a tileset.
        /// </summary>
        /// <param name="filename">The tileset filename.</param>
        /// <param name="tile_id">The ID of the tile to extract.</param>
        /// <param name="hue">The hue adjustment to apply.</param>
        /// <param name="width">The width of the tile in tiles.</param>
        /// <param name="height">The height of the tile in tiles.</param>
        /// <returns>The created tile bitmap.</returns>
        /// <remarks>
        /// Creates a bitmap containing a specific tile from a tileset, with optional
        /// hue adjustment and size specification.
        /// </remarks>
        IBitmap tileEx(string filename, int tile_id, int hue, int width = 1, int height = 1);

        /// <summary>
        /// Creates a single tile bitmap from a tileset.
        /// </summary>
        /// <param name="filename">The tileset filename.</param>
        /// <param name="tile_id">The ID of the tile to extract.</param>
        /// <param name="hue">The hue adjustment to apply.</param>
        /// <returns>The created tile bitmap.</returns>
        IBitmap tile(string filename, int tile_id, int hue);

        /// <summary>
        /// Loads a transition bitmap.
        /// </summary>
        /// <param name="filename">The filename of the transition.</param>
        /// <returns>The loaded transition bitmap.</returns>
        IBitmap transition(string filename);

        /// <summary>
        /// Loads a UI bitmap.
        /// </summary>
        /// <param name="filename">The filename of the UI element.</param>
        /// <returns>The loaded UI bitmap.</returns>
        IBitmap ui(string filename);

        /// <summary>
        /// Marks a resource to never be disposed.
        /// </summary>
        /// <param name="folder_name">The folder containing the resource.</param>
        /// <param name="filename">The filename of the resource.</param>
        /// <param name="hue">The hue adjustment applied to the resource.</param>
        /// <remarks>
        /// Marks a cached resource to never be automatically disposed, even when
        /// its reference count reaches zero.
        /// </remarks>
        void retain(string folder_name, string filename = "", int hue = 0);
    }

    /// <summary>
    /// Represents a bitmap with reference counting.
    /// </summary>
    /// <remarks>
    /// This interface extends the basic bitmap functionality to include reference counting
    /// and disposal control.
    /// </remarks>
    public interface IBitmapWrapper : IBitmap
    {
        /// <summary>
        /// Gets the current reference count.
        /// </summary>
        int refcount { get; }

        /// <summary>
        /// Gets or sets whether the bitmap should never be disposed.
        /// </summary>
        bool never_dispose { get; set; }

        /// <summary>
        /// Resets the reference count to 1.
        /// </summary>
        void resetRef();

        /// <summary>
        /// Creates a copy of the bitmap.
        /// </summary>
        /// <returns>A new bitmap with the same contents.</returns>
        IBitmap copy();

        /// <summary>
        /// Increments the reference count.
        /// </summary>
        void addRef();
    }
} 