using System;
using System.Linq;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Handles the map data, including scrolling and passability determination.
	/// </summary>
	/// <remarks>
	/// This class handles the map. It includes scrolling and passable determining
	/// functions. Refer to "Game.GameData.game_map" for the instance of this class.
	/// </remarks>
	public interface IGameMap : IHaveUpdate, IHaveRefresh {
		#region Constants
		/// <summary>
		/// Width of a tile in pixels.
		/// </summary>
		//const int TILE_WIDTH = 32;
		int TILE_WIDTH { get; }

		/// <summary>
		/// Height of a tile in pixels.
		/// </summary>
		//const int TILE_HEIGHT = 32;
		int TILE_HEIGHT  { get; }

		/// <summary>
		/// Number of subpixels in the X direction.
		/// </summary>
		//const int X_SUBPIXELS = 4;
		int X_SUBPIXELS  { get; }

		/// <summary>
		/// Number of subpixels in the Y direction.
		/// </summary>
		//const int Y_SUBPIXELS = 4;
		int Y_SUBPIXELS  { get; }

		/// <summary>
		/// Real resolution in the X direction.
		/// </summary>
		//const int REAL_RES_X = TILE_WIDTH * X_SUBPIXELS;
		int REAL_RES_X  { get; }

		/// <summary>
		/// Real resolution in the Y direction.
		/// </summary>
		//const int REAL_RES_Y = TILE_HEIGHT * Y_SUBPIXELS;
		int REAL_RES_Y  { get; }
		#endregion

		#region Properties
		/// <summary>
		/// Gets or sets the map ID.
		/// </summary>
		int map_id { get; set; }

		/// <summary>
		/// Gets or sets the tileset file name.
		/// </summary>
		string tileset_name 	{ get; set; }

		/// <summary>
		/// Gets or sets the autotile file names.
		/// </summary>
		IList<string> autotile_names { get; set; }

		/// <summary>
		/// Gets the passage table.
		/// </summary>
		IList<int> passages { get; }

		/// <summary>
		/// Gets the priority table.
		/// </summary>
		IList<int> priorities { get; }

		/// <summary>
		/// Gets the terrain tag table.
		/// </summary>
		int terrain_tags { get; }

		/// <summary>
		/// Gets the events on the map.
		/// </summary>
		IDictionary<int, IGameEvent> events { get; }

		/// <summary>
		/// Gets or sets the panorama file name.
		/// </summary>
		string panorama_name { get; set; }

		/// <summary>
		/// Gets or sets the panorama hue.
		/// </summary>
		int panorama_hue { get; set; }

		/// <summary>
		/// Gets or sets the fog file name.
		/// </summary>
		string fog_name { get; set; }

		/// <summary>
		/// Gets or sets the fog hue.
		/// </summary>
		int fog_hue { get; set; }

		/// <summary>
		/// Gets or sets the fog opacity level.
		/// </summary>
		float fog_opacity { get; set; }

		/// <summary>
		/// Gets or sets the fog blending method.
		/// </summary>
		int fog_blend_type { get; set; }

		/// <summary>
		/// Gets or sets the fog zoom rate.
		/// </summary>
		int fog_zoom { get; set; }

		/// <summary>
		/// Gets or sets the fog sx.
		/// </summary>
		float fog_sx { get; set; }

		/// <summary>
		/// Gets or sets the fog sy.
		/// </summary>
		float fog_sy { get; set; }

		/// <summary>
		/// Gets the fog x-coordinate starting point.
		/// </summary>
		float fog_ox { get; }

		/// <summary>
		/// Gets the fog y-coordinate starting point.
		/// </summary>
		float fog_oy { get; }

		/// <summary>
		/// Gets the fog color tone.
		/// </summary>
		ITone fog_tone { get; }

		/// <summary>
		/// Gets or sets the battleback file name.
		/// </summary>
		string battleback_name { get; set; }

		/// <summary>
		/// Gets the display x-coordinate * 128.
		/// </summary>
		float display_x { get; }

		/// <summary>
		/// Gets the display y-coordinate * 128.
		/// </summary>
		float display_y { get; }

		/// <summary>
		/// Gets or sets whether the map needs to be refreshed.
		/// </summary>
		bool need_refresh { get; set; }

		/// <summary>
		/// Gets the width of the map in tiles.
		/// </summary>
		int width { get; }

		/// <summary>
		/// Gets the height of the map in tiles.
		/// </summary>
		int height { get; }

		/// <summary>
		/// Gets the encounter list for the map.
		/// </summary>
		IList<IEncounterPokemonData> encounter_list { get; }

		/// <summary>
		/// Gets the encounter step count for the map.
		/// </summary>
		int encounter_step { get; }

		/// <summary>
		/// Gets the map data.
		/// </summary>
		int?[,,] data { get; }

		/// <summary>
		/// Gets the tileset ID.
		/// </summary>
		int tileset_id { get; }

		/// <summary>
		/// Gets the background music for the map.
		/// </summary>
		IAudioBGM bgm { get; }

		/// <summary>
		/// Gets the name of the map.
		/// </summary>
		string name { get; }

		/// <summary>
		/// Gets the metadata for the map.
		/// </summary>
		IMapMetadata metadata { get; }
		#endregion

		#region Methods
		/// <summary>
		/// Initializes the map.
		/// </summary>
		IGameMap initialize();

		/// <summary>
		/// Sets up the map with the specified ID.
		/// </summary>
		/// <param name="mapId">The ID of the map to set up.</param>
		void setup(int mapId);

		/// <summary>
		/// Updates the tileset information.
		/// </summary>
		void updateTileset();

		/// <summary>
		/// Gets the name of the background music, considering time of day.
		/// </summary>
		/// <returns>The name of the background music.</returns>
		//string GetBGMName();
		string bgm_name { get; }

		/// <summary>
		/// Autoplays background music as a cue.
		/// </summary>
		void autoplayAsCue();

		/// <summary>
		/// Autoplays background music.
		/// </summary>
		void autoplay();

		/// <summary>
		/// Checks if the specified coordinates are valid on the map.
		/// </summary>
		/// <param name="x">The x-coordinate to check.</param>
		/// <param name="y">The y-coordinate to check.</param>
		/// <returns>True if the coordinates are valid; otherwise, false.</returns>
		bool valid(int x, int y);

		/// <summary>
		/// Checks if the specified coordinates are valid on the map, with a more lenient boundary.
		/// </summary>
		/// <param name="x">The x-coordinate to check.</param>
		/// <param name="y">The y-coordinate to check.</param>
		/// <returns>True if the coordinates are valid; otherwise, false.</returns>
		bool validLax(int x, int y);

		/// <summary>
		/// Checks if the specified coordinates are passable in the given direction.
		/// </summary>
		/// <param name="x">The x-coordinate to check.</param>
		/// <param name="y">The y-coordinate to check.</param>
		/// <param name="dir">The direction to check.</param>
		/// <param name="selfEvent">The event to exclude from the check.</param>
		/// <returns>True if the coordinates are passable; otherwise, false.</returns>
		bool passable(int x, int y, int dir, IGameCharacter selfEvent = null);

		/// <summary>
		/// Checks if the specified coordinates are passable for the player.
		/// </summary>
		/// <param name="x">The x-coordinate to check.</param>
		/// <param name="y">The y-coordinate to check.</param>
		/// <param name="dir">The direction to check.</param>
		/// <param name="selfEvent">The event to exclude from the check.</param>
		/// <returns>True if the coordinates are passable; otherwise, false.</returns>
		bool playerPassable(int x, int y, int dir, IGameCharacter selfEvent = null);

		// Returns whether the position x,y is fully passable (there is no blocking
		// event there, and the tile is fully passable in all directions).
		bool passableStrict(int x, int y, int d, IGameCharacter self_event = null);

		/// <summary>
		/// Checks if the specified coordinates contain a bush.
		/// </summary>
		/// <param name="x">The x-coordinate to check.</param>
		/// <param name="y">The y-coordinate to check.</param>
		/// <returns>True if the coordinates contain a bush; otherwise, false.</returns>
		bool bush(int x, int y);

		/// <summary>
		/// Checks if the specified coordinates contain a deep bush.
		/// </summary>
		/// <param name="x">The x-coordinate to check.</param>
		/// <param name="y">The y-coordinate to check.</param>
		/// <returns>True if the coordinates contain a deep bush; otherwise, false.</returns>
		bool deepBush(int x, int y);

		/// <summary>
		/// Checks if the specified coordinates contain a counter.
		/// </summary>
		/// <param name="x">The x-coordinate to check.</param>
		/// <param name="y">The y-coordinate to check.</param>
		/// <returns>True if the coordinates contain a counter; otherwise, false.</returns>
		bool counter(int x, int y);

		/// <summary>
		/// Gets the terrain tag at the specified coordinates.
		/// </summary>
		/// <param name="x">The x-coordinate to check.</param>
		/// <param name="y">The y-coordinate to check.</param>
		/// <param name="countBridge">Whether to count bridge tiles.</param>
		/// <returns>The terrain tag at the specified coordinates.</returns>
		int terrain_tag(int x, int y, bool countBridge = false);

		/// <summary>
		/// Checks for events at the specified coordinates.
		/// </summary>
		/// <param name="x">The x-coordinate to check.</param>
		/// <param name="y">The y-coordinate to check.</param>
		[System.Obsolete("Unused.")]
		void check_event(int x, int y);

		/// <summary>
		/// Scrolls the map up by the specified distance.
		/// </summary>
		/// <param name="distance">The distance to scroll.</param>
		void scroll_up(float distance);

		/// <summary>
		/// Scrolls the map down by the specified distance.
		/// </summary>
		/// <param name="distance">The distance to scroll.</param>
		void scroll_down(float distance);

		/// <summary>
		/// Scrolls the map left by the specified distance.
		/// </summary>
		/// <param name="distance">The distance to scroll.</param>
		void scroll_left(float distance);

		/// <summary>
		/// Scrolls the map right by the specified distance.
		/// </summary>
		/// <param name="distance">The distance to scroll.</param>
		void scroll_right(float distance);

		// speed is:
		//   1: moves 1 tile in 1.6 seconds
		//   2: moves 1 tile in 0.8 seconds
		//   3: moves 1 tile in 0.4 seconds
		//   4: moves 1 tile in 0.2 seconds
		//   5: moves 1 tile in 0.1 seconds
		//   6: moves 1 tile in 0.05 seconds

		/// <summary>
		/// Starts scrolling the map in the specified direction.
		/// </summary>
		/// <param name="direction">The direction to scroll.</param>
		/// <param name="distance">The distance to scroll.</param>
		/// <param name="speed">The speed of the scroll.</param>
		/// <remarks>
		/// <code>
		/// speed is:
		///   1: moves 1 tile in 1.6 seconds
		///   2: moves 1 tile in 0.8 seconds
		///   3: moves 1 tile in 0.4 seconds
		///   4: moves 1 tile in 0.2 seconds
		///   5: moves 1 tile in 0.1 seconds
		///   6: moves 1 tile in 0.05 seconds
		/// </code>
		/// </remarks>
		void start_scroll(int direction, float distance, int speed = 4);

		/// <summary>
		/// Starts scrolling the map with custom distances.
		/// </summary>
		/// <param name="distanceX">The distance to scroll horizontally.</param>
		/// <param name="distanceY">The distance to scroll vertically.</param>
		/// <param name="speed">The speed of the scroll.</param>
		void start_scroll_custom(float distanceX, float distanceY, int speed = 4);

		/// <summary>
		/// Checks if the map is currently scrolling.
		/// </summary>
		/// <returns>True if the map is scrolling; otherwise, false.</returns>
		bool scrolling();

		/// <summary>
		/// Starts changing the fog tone.
		/// </summary>
		/// <param name="tone">The target tone.</param>
		/// <param name="duration">The duration of the change.</param>
		void start_fog_tone_change(ITone tone, float duration);

		/// <summary>
		/// Starts changing the fog opacity.
		/// </summary>
		/// <param name="opacity">The target opacity.</param>
		/// <param name="duration">The duration of the change.</param>
		void start_fog_opacity_change(int opacity, float duration);

		/// <summary>
		/// Sets a tile at the specified coordinates.
		/// </summary>
		/// <param name="x">The x-coordinate.</param>
		/// <param name="y">The y-coordinate.</param>
		/// <param name="layer">The layer to set.</param>
		/// <param name="id">The tile ID to set.</param>
		void set_tile(int x, int y, int layer, int id = 0);

		/// <summary>
		/// Erases a tile at the specified coordinates.
		/// </summary>
		/// <param name="x">The x-coordinate.</param>
		/// <param name="y">The y-coordinate.</param>
		/// <param name="layer">The layer to erase.</param>
		void erase_tile(int x, int y, int layer);

		/// <summary>
		/// Refreshes the map.
		/// </summary>
		void refresh();

		/// <summary>
		/// Updates the map.
		/// </summary>
		void update();
		#endregion
	}

	public interface IMainGameMap : IMain
	{
		//===============================================================================
		//
		//===============================================================================
		// Scroll the map in the given direction by the given distance at the (optional)
		// given speed.
		void ScrollMap(int direction, int distance, int speed = 4);

		// Scroll the map to center on the given coordinates at the (optional) given
		// speed. The scroll can happen in up to two parts, depending on where the target
		// is relative to the current location: an initial diagonal movement and a
		// following cardinal (vertical/horizontal) movement.
		void ScrollMapTo(int x, int y, int speed = 4);

		// Scroll the map to center on the player at the (optional) given speed.
		void ScrollMapToPlayer(int speed = 4);
	}
}