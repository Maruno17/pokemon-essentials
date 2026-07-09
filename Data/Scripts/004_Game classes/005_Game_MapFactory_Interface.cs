using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Map Factory (allows multiple maps to be loaded at once and connected).
    /// </summary>
    /// <remarks>Renamed from "PokemonMapFactory"</remarks>
    //public interface IPokemonMapFactory
    public interface IMapFactory
    {
        #region Properties
        /// <summary>
        /// Gets the list of maps.
        /// </summary>
        IList<IGameMap> maps { get; }
        #endregion

        #region Methods
        /// <summary>
        /// Initializes the map factory with the specified map ID.
        /// </summary>
        /// <param name="id">The map ID to initialize with.</param>
        //IPokemonMapFactory initialize(int id);
        IMapFactory initialize(int id);

        /// <summary>
        /// Clears all maps and sets up the current map with id. This function also sets
        /// the positions of neighboring maps and notifies the game system of a map change.
        /// </summary>
        /// <param name="id">The map ID to set up.</param>
        void setup(int id);

        /// <summary>
        /// Gets the current map.
        /// </summary>
        /// <returns>The current map.</returns>
        //IGameMap map();
        IGameMap map { get; }

        /// <summary>
        /// Checks if a map with the specified ID exists.
        /// </summary>
        /// <param name="id">The map ID to check.</param>
        /// <returns>True if the map exists; otherwise, false.</returns>
        bool hasMap(int id);

        /// <summary>
        /// Gets the index of a map with the specified ID.
        /// </summary>
        /// <param name="id">The map ID to get the index for.</param>
        /// <returns>The index of the map, or -1 if not found.</returns>
        int getMapIndex(int id);

        /// <summary>
        /// Gets a map with the specified ID.
        /// </summary>
        /// <param name="id">The map ID to get.</param>
        /// <param name="add">Whether to add the map if it doesn't exist.</param>
        /// <returns>The map with the specified ID.</returns>
        IGameMap getMap(int id, bool add = true);

        /// <summary>
        /// Gets a map with the specified ID without adding it if it doesn't exist.
        /// </summary>
        /// <param name="id">The map ID to get.</param>
        /// <returns>The map with the specified ID, or null if not found.</returns>
        IGameMap getMapNoAdd(int id);

        /// <summary>
        /// Gets a new map based on the player's position.
        /// </summary>
        /// <param name="playerX">The player's X coordinate.</param>
        /// <param name="playerY">The player's Y coordinate.</param>
        /// <param name="map_id">The map ID to get, or null to use the current map.</param>
        /// <returns>An array containing the new map and the player's new coordinates.</returns>
        ITilePosition getNewMap(int playerX, int playerY, int? map_id = null);

        /// <summary>
        /// Detects whether the player has moved onto a connected map, and if so, causes
        /// their transfer to that map.
        /// </summary>
        void setCurrentMap();

        /// <summary>
        /// Sets up the maps in range.
        /// </summary>
        void setMapsInRange();

        /// <summary>
        /// Sets the map as changing.
        /// </summary>
        /// <param name="newID">The new map ID.</param>
        /// <param name="newMap">The new map.</param>
        void setMapChanging(int newID, IGameMap newMap);

        /// <summary>
        /// Sets the map as changed.
        /// </summary>
        /// <param name="prevMap">The previous map ID.</param>
        void setMapChanged(int prevMap);

        /// <summary>
        /// Sets the scene as started.
        /// </summary>
        /// <param name="scene">The scene that started.</param>
        void setSceneStarted(ISceneMap scene);

        /// <summary>
        /// Checks if a position is passable from the edge.
        /// </summary>
        /// <remarks>
        /// Similar to <see cref="IGamePlayer.passable"/>, but supports map connections
        /// </remarks>
        /// <param name="x">The X coordinate to check.</param>
        /// <param name="y">The Y coordinate to check.</param>
        /// <param name="dir">The direction to check.</param>
        /// <returns>True if the position is passable; otherwise, false.</returns>
        bool isPassableFromEdge(int x, int y, int dir = 0);

        /// <summary>
        /// Checks if a position is passable.
        /// </summary>
        /// <param name="mapID">The map ID to check.</param>
        /// <param name="x">The X coordinate to check.</param>
        /// <param name="y">The Y coordinate to check.</param>
        /// <param name="dir">The direction to check.</param>
        /// <param name="thisEvent">The event to check for.</param>
        /// <returns>True if the position is passable; otherwise, false.</returns>
        bool isPassable(int mapID, int x, int y, int dir = 0, IGameCharacter thisEvent = null);

        /// <summary>
        /// Checks if a position is strictly passable.
        /// </summary>
        /// <remarks>
        /// Only used by follower events
        /// </remarks>
        /// <param name="mapID">The map ID to check.</param>
        /// <param name="x">The X coordinate to check.</param>
        /// <param name="y">The Y coordinate to check.</param>
        /// <param name="thisEvent">The event to check for.</param>
        /// <returns>True if the position is strictly passable; otherwise, false.</returns>
        bool isPassableStrict(int mapID, int x, int y, IGameCharacter thisEvent = null);

        /// <summary>
        /// Gets the terrain tag at a position.
        /// </summary>
        /// <remarks>
        /// Assumes the event is 1x1 tile in size. Only returns one terrain tag.
        /// </remarks>
        /// <param name="mapid">The map ID to check.</param>
        /// <param name="x">The X coordinate to check.</param>
        /// <param name="y">The Y coordinate to check.</param>
        /// <param name="countBridge">Whether to count bridge tiles.</param>
        /// <returns>The terrain tag at the position.</returns>
        int getTerrainTag(int mapid, int x, int y, bool countBridge = false);

        /// <summary>
        /// Gets the terrain tag the player is facing.
        /// </summary>
        /// <param name="dir">The direction to check.</param>
        /// <param name="event">The event to check for.</param>
        /// <returns>The terrain tag the player is facing.</returns>
        int getFacingTerrainTag(int? dir = null, IGameCharacter @event = null);

        /// <summary>
        /// Gets the terrain tag from coordinates.
        /// </summary>
        /// <param name="mapid">The map ID to check.</param>
        /// <param name="x">The X coordinate to check.</param>
        /// <param name="y">The Y coordinate to check.</param>
        /// <param name="countBridge">Whether to count bridge tiles.</param>
        /// <returns>The terrain tag at the coordinates.</returns>
        int getTerrainTagFromCoords(int mapid, int x, int y, bool countBridge = false);

        /// <summary>
        /// Checks if two maps are connected.
        /// </summary>
        /// <param name="mapID1">The first map ID.</param>
        /// <param name="mapID2">The second map ID.</param>
        /// <returns>True if the maps are connected; otherwise, false.</returns>
        bool areConnected(int mapID1, int mapID2);

        /// <summary>
        /// Gets the relative position between two positions.
        /// </summary>
        /// <remarks>
        /// Returns the coordinate change to go from this position to other position
        /// </remarks>
        /// <param name="thisMapID">The first map ID.</param>
        /// <param name="thisX">The first X coordinate.</param>
        /// <param name="thisY">The first Y coordinate.</param>
        /// <param name="otherMapID">The second map ID.</param>
        /// <param name="otherX">The second X coordinate.</param>
        /// <param name="otherY">The second Y coordinate.</param>
        /// <returns>The relative position between the two positions.</returns>
        int[] getRelativePos(int thisMapID, int thisX, int thisY, int otherMapID, int otherX, int otherY);

        /// <summary>
        /// Gets the relative position between two events.
        /// </summary>
        /// <remarks>
        /// Gets the distance from this event to another event.  Example: If this event's
        /// coordinates are (2,5) and the other event's coordinates are (5,1), returns
        /// the array (3,-4), because (5-2=3) and (1-5=-4).
        /// </remarks>
        /// <param name="thisEvent">The first event.</param>
        /// <param name="otherEvent">The second event.</param>
        /// <returns>The relative position between the two events.</returns>
        int[] getThisAndOtherEventRelativePos(IGameCharacter thisEvent, IGameCharacter otherEvent);

        /// <summary>
        /// Gets the relative position between an event and a position.
        /// </summary>
        /// <param name="thisEvent">The event.</param>
        /// <param name="otherMapID">The other map ID.</param>
        /// <param name="otherX">The other X coordinate.</param>
        /// <param name="otherY">The other Y coordinate.</param>
        /// <returns>The relative position between the event and the position.</returns>
        int[] getThisAndOtherPosRelativePos(IGameCharacter thisEvent, int otherMapID, int otherX, int otherY);

        /// <summary>
        /// Gets the offset position of an event.
        /// </summary>
        /// <param name="event">The event to get the offset position for.</param>
        /// <param name="xOffset">The X offset.</param>
        /// <param name="yOffset">The Y offset.</param>
        /// <returns>The offset position of the event.</returns>
        [System.Obsolete("Unused")]
        int[] getOffsetEventPos(IGameCharacter @event, int xOffset, int yOffset);

		/// <summary>
		/// Gets the tile the player is facing.
		/// </summary>
		/// <remarks>
		/// Assumes the event is 1x1 tile in size. Only returns one tile.
		/// </remarks>
		/// <param name="direction">The direction to check.</param>
		/// <param name="event">The event to check for.</param>
		/// <param name="steps">The number of steps to check.</param>
		/// <returns>The tile the player is facing.</returns>
		ITilePosition getFacingTile(int? direction = null, IGameCharacter @event = null, int steps = 1);

        /// <summary>
        /// Gets the tile the player is facing from a position.
        /// </summary>
        /// <param name="mapID">The map ID to check.</param>
        /// <param name="x">The X coordinate to check.</param>
        /// <param name="y">The Y coordinate to check.</param>
        /// <param name="direction">The direction to check.</param>
        /// <param name="steps">The number of steps to check.</param>
        /// <returns>The tile the player is facing.</returns>
        int[] getFacingTileFromPos(int mapID, int x, int y, int direction = 0, int steps = 1);

        /// <summary>
        /// Gets the real tile position.
        /// </summary>
        /// <param name="mapID">The map ID to check.</param>
        /// <param name="x">The X coordinate to check.</param>
        /// <param name="y">The Y coordinate to check.</param>
        /// <returns>The real tile position.</returns>
        int[] getRealTilePos(int mapID, int x, int y);

        /// <summary>
        /// Gets the coordinates the player is facing.
        /// </summary>
        /// <param name="x">The X coordinate to check.</param>
        /// <param name="y">The Y coordinate to check.</param>
        /// <param name="direction">The direction to check.</param>
        /// <param name="steps">The number of steps to check.</param>
        /// <returns>The coordinates the player is facing.</returns>
        int[] getFacingCoords(int x, int y, int direction = 0, int steps = 1);

        /// <summary>
        /// Updates the maps.
        /// </summary>
        /// <param name="scene">The scene to update for.</param>
        void updateMaps(ISceneMap scene);

        /// <summary>
        /// Updates the maps internally.
        /// </summary>
        void updateMapsInternal();
        #endregion
    }

    /// <summary>
    /// Helper class for map factory operations.
    /// </summary>
    /// <remarks>
    /// Map Factory Helper (stores map connection and size data and calculations
    /// involving them)
    /// </remarks>
    public interface IMapFactoryHelper
    {
        /// <summary>
        /// Clears the map connections.
        /// </summary>
        void clear();

        /// <summary>
        /// Gets the map connections.
        /// </summary>
        /// <returns>The map connections.</returns>
        IList<int[]> getMapConnections();

        /// <summary>
        /// Checks if a map has connections.
        /// </summary>
        /// <param name="id">The map ID to check.</param>
        /// <returns>True if the map has connections; otherwise, false.</returns>
        bool hasConnections(int id);

        /// <summary>
        /// Checks if two maps are connected.
        /// </summary>
        /// <param name="id1">The first map ID.</param>
        /// <param name="id2">The second map ID.</param>
        /// <returns>True if the maps are connected; otherwise, false.</returns>
        bool mapsConnected(int id1, int id2);

        /// <summary>
        /// Iterates through each connection for a map.
        /// </summary>
        /// <param name="id">The map ID to check.</param>
        /// <param name="action">The action to perform for each connection.</param>
        void eachConnectionForMap(int id, Action<int[]> action);

        /// <summary>
        /// Gets the dimensions of a map.
        /// </summary>
        /// <remarks>
        /// Gets the height and width of the map with id.
        /// </remarks>
        /// <param name="id">The map ID to get the dimensions for.</param>
        /// <returns>The dimensions of the map.</returns>
        int[] getMapDims(int id);

        /// <summary>
        /// Gets the edge of a map.
        /// </summary>
        /// <remarks>
        /// Returns the X or Y coordinate of an edge on the map with id.
        /// Considers the special strings "N","W","E","S"
        /// </remarks>
        /// <param name="id">The map ID to get the edge for.</param>
        /// <param name="edge">The edge to get.</param>
        /// <returns>The edge of the map.</returns>
        int getMapEdge(int id, string edge);

        /// <summary>
        /// Checks if a map is in range.
        /// </summary>
        /// <param name="map">The map to check.</param>
        /// <returns>True if the map is in range; otherwise, false.</returns>
        bool mapInRange(IGameMap map);

        /// <summary>
        /// Checks if a map is in range by ID.
        /// </summary>
        /// <param name="id">The map ID to check.</param>
        /// <param name="dispx">The display X coordinate.</param>
        /// <param name="dispy">The display Y coordinate.</param>
        /// <returns>True if the map is in range; otherwise, false.</returns>
        bool mapInRangeById(int id, float dispx, float dispy);
    }
}