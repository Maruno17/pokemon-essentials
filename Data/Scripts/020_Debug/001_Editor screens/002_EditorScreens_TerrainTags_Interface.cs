using System;

namespace PokemonEssentials
{
    /// <summary>
    /// Provides a comprehensive interface for editing terrain tags of tiles in tilesets.
    /// This editor allows developers to visually modify terrain properties that affect gameplay mechanics
    /// such as surfing, footstep sounds, encounter rates, and movement restrictions.
    /// </summary>
    //public interface IPokemonTilesetScene
    public interface ISceneTilesetEditor : IScene
    {
        /// <summary>
        /// Size of individual tiles in pixels.
        /// </summary>
        int TILE_SIZE { get; }

        /// <summary>
        /// Number of tiles displayed per row in the tileset editor.
        /// </summary>
        int TILES_PER_ROW { get; }

        /// <summary>
        /// Total width of the tileset display area in pixels.
        /// </summary>
        int TILESET_WIDTH { get; }

        /// <summary>
        /// Number of tiles per autotile set.
        /// </summary>
        int TILES_PER_AUTOTILE { get; }

        /// <summary>
        /// Starting ID for regular tileset tiles (after autotiles).
        /// </summary>
        int TILESET_START_ID { get; }

        /// <summary>
        /// Background color used for empty tile areas.
        /// </summary>
        IColor TILE_BACKGROUND { get; }

        /// <summary>
        /// Color used for the selection cursor.
        /// </summary>
        IColor CURSOR_COLOR { get; }

        /// <summary>
        /// Color used for cursor outline for better visibility.
        /// </summary>
        IColor CURSOR_OUTLINE_COLOR { get; }

        /// <summary>
        /// Color used for terrain tag text overlays.
        /// </summary>
        IColor TEXT_COLOR { get; }

        /// <summary>
        /// Color used for text shadows to improve readability.
        /// </summary>
        IColor TEXT_SHADOW_COLOR { get; }

		/// <summary>
		/// Initializes the tileset editor scene with default settings.
		/// Loads tileset data and sets up the visual interface components.
		/// </summary>
		ISceneTilesetEditor initialize();

        /// <summary>
        /// Opens the editor screen with proper fade-in effects.
        /// Displays all interface elements and begins interactive editing.
        /// </summary>
        void open_screen();

        /// <summary>
        /// Closes the editor screen with fade-out effects and cleanup.
        /// Disposes of all resources and refreshes the game map if necessary.
        /// </summary>
        void close_screen();

        /// <summary>
        /// Loads and displays a specific tileset for editing.
        /// Updates all visual elements to reflect the selected tileset's data.
        /// </summary>
        /// <param name="id">The ID of the tileset to load.</param>
        void load_tileset(int id);

        /// <summary>
        /// Displays a selection menu for choosing which tileset to edit.
        /// Shows all available tilesets with their names and IDs.
        /// </summary>
        void choose_tileset();

        /// <summary>
        /// Renders all visible tiles in the current tileset view.
        /// Updates the tile display based on current scroll position and selected tileset.
        /// </summary>
        void draw_tiles();

        /// <summary>
        /// Draws overlay elements including terrain tag numbers, cursor, and tile details.
        /// Provides visual feedback for terrain tag values and current selection.
        /// </summary>
        void draw_overlay();

        /// <summary>
        /// Draws the selection cursor at the current position.
        /// Provides clear visual indication of which tile is currently selected.
        /// </summary>
        void draw_cursor();

        /// <summary>
        /// Draws detailed information about the currently selected tile.
        /// Shows enlarged tile preview and terrain tag information in the side panel.
        /// </summary>
        void draw_tile_details();

        /// <summary>
        /// Converts screen coordinates to a tile ID.
        /// Handles both autotile and regular tile coordinate conversion.
        /// </summary>
        /// <param name="x">X coordinate in the tile grid.</param>
        /// <param name="y">Y coordinate in the tile grid.</param>
        /// <returns>The tile ID corresponding to the given coordinates.</returns>
        int tile_ID_from_coordinates(int x, int y);

        /// <summary>
        /// Sets the terrain tag value for a specific tile ID.
        /// Handles autotile groups and individual tiles appropriately.
        /// </summary>
        /// <param name="i">The tile ID to modify.</param>
        /// <param name="value">The new terrain tag value to assign.</param>
        void set_terrain_tag_for_tile_ID(int i, int value);

        /// <summary>
        /// Updates the cursor position and handles scrolling.
        /// Ensures cursor stays within valid bounds and updates display as needed.
        /// </summary>
        /// <param name="x_offset">Horizontal movement offset.</param>
        /// <param name="y_offset">Vertical movement offset.</param>
        void update_cursor_position(int x_offset, int y_offset);

        /// <summary>
        /// Main scene loop that handles user input and updates.
        /// Processes cursor movement, terrain tag selection, and menu commands.
        /// </summary>
        void StartScene();
    }

    /// <summary>
    /// Global function interface for launching the tileset editor.
    /// Provides the main entry point for terrain tag editing functionality.
    /// </summary>
    //public interface IMainTilesetEditor : IMain
    public interface IMainEditorTileset : IMain
    {
        /// <summary>
        /// Opens the tileset terrain tag editor screen.
        /// Handles screen resizing, scene management, and proper cleanup.
        /// </summary>
        void TilesetScreen();
    }
}