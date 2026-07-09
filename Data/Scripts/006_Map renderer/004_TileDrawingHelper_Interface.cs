using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Represents a utility class for drawing tiles in the game.
    /// </summary>
    /// <remarks>
    /// This interface defines the functionality for drawing tiles in the game, including:
    /// - Drawing individual tiles
    /// - Handling tile layers
    /// - Managing tile coordinates
    /// - Supporting special tile effects
    /// </remarks>
    public interface ITileDrawingHelper
    {
        /// <summary>
        /// Gets the width of a tile.
        /// </summary>
        /// <remarks>
        /// The width of a single tile in pixels.
        /// </remarks>
        int TILE_WIDTH { get; }

        /// <summary>
        /// Gets the height of a tile.
        /// </summary>
        /// <remarks>
        /// The height of a single tile in pixels.
        /// </remarks>
        int TILE_HEIGHT { get; }

        /// <summary>
        /// Draws a tile at the specified coordinates.
        /// </summary>
        /// <param name="bitmap">The bitmap to draw on.</param>
        /// <param name="tile_id">The ID of the tile to draw.</param>
        /// <param name="x">The x-coordinate to draw at.</param>
        /// <param name="y">The y-coordinate to draw at.</param>
        /// <param name="tileset">The tileset to use.</param>
        /// <param name="autotiles">The autotiles to use.</param>
        /// <remarks>
        /// Draws a tile from either the tileset or autotiles at the specified coordinates.
        /// Handles both regular tiles and autotiles, including their different layouts.
        /// </remarks>
        void draw_tile(IBitmap bitmap, int tile_id, int x, int y, ITilesetBitmaps tileset, IAutotileBitmaps autotiles);

        /// <summary>
        /// Gets the source rectangle for a tile.
        /// </summary>
        /// <param name="tile_id">The ID of the tile.</param>
        /// <param name="tileset">The tileset to use.</param>
        /// <param name="autotiles">The autotiles to use.</param>
        /// <returns>The source rectangle for the tile.</returns>
        /// <remarks>
        /// Calculates the source rectangle for a tile based on its ID and whether it's
        /// from the tileset or autotiles.
        /// </remarks>
        IRect get_tile_rect(int tile_id, ITilesetBitmaps tileset, IAutotileBitmaps autotiles);

        /// <summary>
        /// Checks if a tile ID is an autotile.
        /// </summary>
        /// <param name="tile_id">The ID of the tile to check.</param>
        /// <returns>True if the tile is an autotile; otherwise, false.</returns>
        /// <remarks>
        /// Determines if a tile ID corresponds to an autotile based on its value.
        /// </remarks>
        bool is_autotile(int tile_id);

        /// <summary>
        /// Gets the autotile index for a tile ID.
        /// </summary>
        /// <param name="tile_id">The ID of the tile.</param>
        /// <returns>The index of the autotile.</returns>
        /// <remarks>
        /// Calculates which autotile a tile ID corresponds to.
        /// </remarks>
        int get_autotile_index(int tile_id);

        /// <summary>
        /// Gets the pattern index for an autotile.
        /// </summary>
        /// <param name="tile_id">The ID of the tile.</param>
        /// <returns>The pattern index for the autotile.</returns>
        /// <remarks>
        /// Calculates which pattern within an autotile a tile ID corresponds to.
        /// </remarks>
        int get_autotile_pattern(int tile_id);
    }

    public interface IMainTileDrawingHelper : IMain
    {
        void createMinimap(int mapid);
        //void bltMinimapAutotile(dstBitmap, x, y, srcBitmap, id);
        //bool passable(passage, int tile_id_);
        IBitmap getPassabilityMinimap(int mapid);
    }
}