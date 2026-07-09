using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Represents the map scene in the game, handling the display and interaction of the game world.
	/// This interface manages the rendering of maps, sprites, and player interactions.
	/// </summary>
	public interface ISceneMap : IHaveUpdate, IDisposable
	{
		/// <summary>
		/// Gets the global spriteset containing shared sprites across the map.
		/// </summary>
		ISpritesetGlobal spritesetGlobal { get; }

		/// <summary>
		/// Gets the tilemap renderer responsible for drawing the map tiles.
		/// </summary>
		ITilemapRenderer map_renderer { get; }

		/// <summary>
		/// Gets the dictionary of map-specific spritesets, keyed by map ID.
		/// </summary>
		IDictionary<int, ISpritesetMap> spritesets { get; }
		//ISpritesetMap spritesets(int map_id = -1);

		/// <summary>
		/// Gets the spriteset for the specified map.
		/// </summary>
		/// <param name="map_id">The map ID to get the spriteset for. Defaults to -1 for current map.</param>
		/// <returns>The spriteset for the specified map.</returns>
		ISpritesetMap spriteset(int map_id = -1);

		/// <summary>
		/// Creates all necessary spritesets for the current map.
		/// </summary>
		void createSpritesets();

		/// <summary>
		/// Creates a single spriteset for the specified map.
		/// </summary>
		/// <param name="map">The map ID to create the spriteset for.</param>
		void createSingleSpriteset(int map);

		/// <summary>
		/// Disposes of all spritesets and their resources.
		/// </summary>
		void disposeSpritesets();

		/// <summary>
		/// Disposes of all resources used by the scene.
		/// </summary>
		void dispose();

		/// <summary>
		/// Initiates an automatic fade transition to the specified map.
		/// </summary>
		/// <param name="mapid">The ID of the map to transition to.</param>
		void autofade(int mapid);

		/// <summary>
		/// Transfers the player to a new location, optionally canceling swimming state.
		/// </summary>
		/// <param name="cancel_swimming">Whether to cancel the swimming state during transfer.</param>
		void transfer_player(bool cancel_swimming = true);

		/// <summary>
		/// Opens the main menu interface.
		/// </summary>
		void call_menu();

		/// <summary>
		/// Opens the debug menu interface.
		/// </summary>
		void call_debug();

		/// <summary>
		/// Performs a mini-update for quick state changes.
		/// </summary>
		void miniupdate();

		/// <summary>
		/// Updates all maps in the scene.
		/// </summary>
		void updateMaps();

		/// <summary>
		/// Updates all spritesets, optionally refreshing their state.
		/// </summary>
		/// <param name="refresh">Whether to force a complete refresh of the spritesets.</param>
		void updateSpritesets(bool refresh = false);

		/// <summary>
		/// Updates the scene state, including all sprites and interactions.
		/// </summary>
		void update();

		/// <summary>
		/// Main update loop for the map scene.
		/// </summary>
		void main();
	}
}