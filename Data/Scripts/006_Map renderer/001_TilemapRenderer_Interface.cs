using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Represents a renderer for tilemaps in the game.
    /// </summary>
    /// <remarks>
    /// This interface defines the functionality for managing and rendering tilemaps, including:
    /// - Tileset management
    /// - Autotile handling
    /// - Tile rendering and animation
    /// - Viewport and coordinate management
    /// </remarks>
    public interface ITilemapRenderer : IHaveUpdate, IDisposable
    {
        /// <summary>
        /// Gets the tilesets used by this renderer.
        /// </summary>
        int tilesets { get; }

        /// <summary>
        /// Gets the autotiles used by this renderer.
        /// </summary>
        int autotiles { get; }

        /// <summary>
        /// Gets or sets the tone applied to the tilemap.
        /// </summary>
        ITone tone { get; set; }

        /// <summary>
        /// Gets or sets the color applied to the tilemap.
        /// </summary>
        IColor color { get; set; }

        /// <summary>
        /// Gets the viewport used for rendering.
        /// </summary>
        IViewport viewport { get; }

        /// <summary>
        /// Gets or sets the x-coordinate offset.
        /// </summary>
        int ox { get; set; }

        /// <summary>
        /// Gets or sets the y-coordinate offset.
        /// </summary>
        int oy { get; set; }

        /// <summary>
        /// Gets or sets the visibility of the tilemap.
        /// </summary>
        int visible { get; set; }

        /// <summary>
        /// Initializes the tilemap renderer with a viewport.
        /// </summary>
        /// <param name="viewport">The viewport to render in.</param>
        /// <remarks>
        /// Sets up the tilemap renderer with the specified viewport and initializes
        /// all necessary components for rendering.
        /// </remarks>
        ITilemapRenderer initialize(IViewport viewport);

        /// <summary>
        /// Updates the tilemap renderer's state.
        /// </summary>
        /// <remarks>
        /// This method is called each frame to update the renderer's state, including:
        /// - Updating autotile animations
        /// - Refreshing tileset bitmaps
        /// - Managing viewport changes
        /// - Handling tile updates
        /// </remarks>
        void update();

        /// <summary>
        /// Disposes of the tilemap renderer and its resources.
        /// </summary>
        /// <remarks>
        /// Cleans up all resources used by the tilemap renderer, including:
        /// - Tileset bitmaps
        /// - Autotile bitmaps
        /// - Viewport references
        /// </remarks>
        void dispose();
    }

    /// <summary>
    /// Represents a collection of tileset bitmaps.
    /// </summary>
    /// <remarks>
    /// This interface defines the functionality for managing tileset bitmaps, including:
    /// - Loading and unloading tilesets
    /// - Managing bitmap references
    /// - Handling source rectangles for tiles
    /// </remarks>
    public interface ITilesetBitmaps : IHaveUpdate
    {
        /// <summary>
        /// Gets or sets whether the bitmaps have changed.
        /// </summary>
        int changed { get; set; }

        /// <summary>
        /// Gets or sets the collection of bitmaps.
        /// </summary>
        int bitmaps { get; set; }

        /// <summary>
        /// Initializes the tileset bitmaps collection.
        /// </summary>
        /// <remarks>
        /// Sets up the initial state of the bitmaps collection, including:
        /// - Creating empty collections
        /// - Initializing load counts
        /// - Setting up bridge references
        /// </remarks>
        ITilesetBitmaps initialize();

        /// <summary>
        /// Adds a tileset bitmap to the collection.
        /// </summary>
        /// <param name="filename">The filename of the tileset to add.</param>
        /// <remarks>
        /// Loads and manages a tileset bitmap, handling:
        /// - Duplicate loading
        /// - Mega texture wrapping
        /// - Load count tracking
        /// </remarks>
        void add(string filename);

        /// <summary>
        /// Removes a tileset bitmap from the collection.
        /// </summary>
        /// <param name="filename">The filename of the tileset to remove.</param>
        /// <remarks>
        /// Unloads a tileset bitmap, handling:
        /// - Load count decrementing
        /// - Resource disposal
        /// - Collection cleanup
        /// </remarks>
        void remove(string filename);

        /// <summary>
        /// Sets the source rectangle for a tile.
        /// </summary>
        /// <param name="tile">The tile to set the source rectangle for.</param>
        /// <param name="tile_id">The ID of the tile.</param>
        /// <remarks>
        /// Calculates and sets the source rectangle for a tile based on its ID and
        /// the tileset's layout.
        /// </remarks>
        void set_src_rect(IBitmap tile, int tile_id);

        /// <summary>
        /// Updates the tileset bitmaps collection.
        /// </summary>
        /// <remarks>
        /// This method is called each frame to update the state of the bitmaps collection.
        /// </remarks>
        void update();
    }

    /// <summary>
    /// Represents a collection of autotile bitmaps.
    /// </summary>
    /// <remarks>
    /// This interface extends the tileset bitmaps functionality to include autotile-specific
    /// features like animation and frame management.
    /// </remarks>
    public interface IAutotileBitmaps : ITilesetBitmaps
    {
        //IAutotileBitmaps initialize();
        /// <summary>
        /// Gets the current frames for each autotile.
        /// </summary>
        int current_frames { get; }

        /// <summary>
        /// Gets the frame count for an autotile.
        /// </summary>
        /// <param name="filename">The filename of the autotile.</param>
        /// <param name="force_recalc">Whether to force recalculation of the frame count.</param>
        /// <returns>The number of frames in the autotile.</returns>
        int frame_count(string filename, bool force_recalc = false);

        /// <summary>
        /// Checks if an autotile is animated.
        /// </summary>
        /// <param name="filename">The filename of the autotile.</param>
        /// <returns>True if the autotile is animated; otherwise, false.</returns>
        bool animated(string filename);

        /// <summary>
        /// Gets the current frame for an autotile.
        /// </summary>
        /// <param name="filename">The filename of the autotile.</param>
        /// <returns>The current frame index.</returns>
        int current_frame(string filename);

        /// <summary>
        /// Sets the current frame for an autotile.
        /// </summary>
        /// <param name="filename">The filename of the autotile.</param>
        /// <remarks>
        /// Updates the current frame based on the animation timing and frame count.
        /// </remarks>
        void set_current_frame(string filename);
    }

    //public interface ITileSprite : ISprite, IDisposable
    //{
    //    int filename { get; }
    //    int tile_id { get; }
    //    int is_autotile { get; }
    //    int animated { get; }
    //    int priority { get; }
    //    int shows_reflection { get; }
    //    int bridge { get; }
    //    int need_refresh { get; }
    //
    //    void set_bitmap(string filename, int tile_id, autotile, animated, int priority, IBitmap bitmap);
    //    ITileSprite initialize(IViewport viewport);
    //    void add_tileset(string filename);
    //    void remove_tileset(string filename);
    //    void add_autotile(string filename);
    //    void remove_autotile(string filename);
    //    void add__extra_autotiles(int tileset_id);
    //    void remove_extra_autotiles(int tileset_id);
    //    void refresh();
    //    void refresh_tile_bitmap(tile, map, int tile_id);
    //    void refresh_tile_src_rect(tile, int tile_id);
    //    void refresh_tile_frame(tile, int tile_id);
    //    void refresh_tile_coordinates(tile, int tile_id);
    //    void refresh_tile_z(tile, map, float y, layer, int tile_id);
    //    void refresh_tile(tile, float x, float y, map, layer, int tile_id);
    //    void check_if_screen_moved();
    //    void update();
    //}
}