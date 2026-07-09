using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Provides a miniature sprite representation of a game map for visual editing.
    /// Used in the map connections editor to display small versions of maps.
    /// </summary>
    public interface IMapSprite : IDisposable
    {
        /// <summary>
        /// Initializes the map sprite with the specified map and optional viewport.
        /// </summary>
        /// <param name="map">The map to create a sprite for.</param>
        /// <param name="viewport">Optional viewport for the sprite.</param>
        IMapSprite initialize(object map, IViewport viewport = null);

        /// <summary>
        /// Disposes of the sprite and its resources.
        /// </summary>
        void dispose();

        /// <summary>
        /// Sets the Z-order of the sprite for layering.
        /// </summary>
        int z { set; }

        /// <summary>
        /// Gets the screen coordinates of a mouse click within the sprite bounds.
        /// Returns coordinates adjusted for the map scale.
        /// </summary>
        /// <returns>Array containing [x, y] coordinates, or null if no valid click.</returns>
        int[] getXY();
    }

    /// <summary>
    /// Provides a selection overlay sprite for highlighting selected elements.
    /// Used to visually indicate which map or element is currently selected.
    /// </summary>
    public interface ISelectionSprite : ISprite, IHaveUpdate, IDisposable
    {
        /// <summary>
        /// Initializes the selection sprite with an optional viewport.
        /// </summary>
        /// <param name="viewport">Optional viewport for the sprite.</param>
        ISelectionSprite initialize(IViewport viewport = null);

        /// <summary>
        /// Gets whether the sprite has been disposed.
        /// </summary>
        /// <returns>True if disposed, false otherwise.</returns>
        //bool disposed { get; }

        /// <summary>
        /// Disposes of the sprite and its resources.
        /// </summary>
        //void dispose();

        /// <summary>
        /// Sets the sprite to overlay and track the position of another sprite.
        /// </summary>
        object othersprite { set; }

        /// <summary>
        /// Updates the selection sprite position to match its target sprite.
        /// </summary>
        void update();
    }

    /// <summary>
    /// Provides a region map sprite for displaying town map graphics.
    /// Used for showing the regional layout in editors.
    /// </summary>
    public interface IRegionMapSprite : IDisposable
    {
        /// <summary>
        /// Initializes the region map sprite with the specified map and optional viewport.
        /// </summary>
        /// <param name="map">The town map to display.</param>
        /// <param name="viewport">Optional viewport for the sprite.</param>
        IRegionMapSprite initialize(object map, IViewport viewport = null);

        /// <summary>
        /// Disposes of the sprite and its resources.
        /// </summary>
        void dispose();

        /// <summary>
        /// Sets the Z-order of the sprite for layering.
        /// </summary>
        int z { set; }

        /// <summary>
        /// Creates a scaled region map bitmap from the town map data.
        /// </summary>
        /// <param name="map">The town map to create a bitmap for.</param>
        /// <returns>The created bitmap.</returns>
        object createRegionMap(object map);

        /// <summary>
        /// Gets the screen coordinates of a mouse click within the region map bounds.
        /// Returns coordinates adjusted for the region map scale.
        /// </summary>
        /// <returns>Array containing [x, y] coordinates, or null if no valid click.</returns>
        int[] getXY();
    }

    /// <summary>
    /// Provides the main scene for visually editing map connections.
    /// Allows developers to arrange maps spatially and define how they connect to each other.
    /// </summary>
    public interface IMapScreenScene : IScene, IHaveUpdate
    {
        /// <summary>
        /// Gets a map sprite for the specified map ID, creating it if necessary.
        /// </summary>
        /// <param name="id">The map ID to get a sprite for.</param>
        /// <returns>The map sprite for the specified ID.</returns>
        object getMapSprite(int id);

        /// <summary>
        /// Closes the scene and disposes of all resources.
        /// </summary>
        void close();

        /// <summary>
        /// Sets the position of a map sprite and makes it visible.
        /// </summary>
        /// <param name="id">The map ID whose sprite to position.</param>
        /// <param name="x">The X coordinate to place the sprite.</param>
        /// <param name="y">The Y coordinate to place the sprite.</param>
        void setMapSpritePos(int id, int x, int y);

        /// <summary>
        /// Recursively places neighboring maps based on connection data.
        /// Automatically arranges connected maps in their proper relative positions.
        /// </summary>
        /// <param name="id">The map ID to find neighbors for.</param>
        /// <param name="sprites">Array of map IDs already placed to avoid infinite recursion.</param>
        void putNeighbors(int id, IList<int> sprites);

        /// <summary>
        /// Checks if a map has any connections defined.
        /// </summary>
        /// <param name="conns">The connections data to check.</param>
        /// <param name="id">The map ID to check for connections.</param>
        /// <returns>True if the map has connections, false otherwise.</returns>
        bool hasConnections(IList<object> conns, int id);

        /// <summary>
        /// Checks if two connection entries are symmetric (represent the same connection).
        /// </summary>
        /// <param name="conn1">The first connection to compare.</param>
        /// <param name="conn2">The second connection to compare.</param>
        /// <returns>True if the connections are symmetric, false otherwise.</returns>
        bool connectionsSymmetric(object conn1, object conn2);

        /// <summary>
        /// Removes all connection entries involving the specified map ID.
        /// </summary>
        /// <param name="ret">The connection list to modify.</param>
        /// <param name="mapid">The map ID whose connections to remove.</param>
        void removeOldConnections(IList<object> ret, int mapid);

        /// <summary>
        /// Gets all maps that are directly connected to the specified map.
        /// Analyzes sprite positions to determine which maps should be connected.
        /// </summary>
        /// <param name="keys">The list of map IDs to consider.</param>
        /// <param name="map">The map to find connections for.</param>
        /// <returns>List of map IDs that are directly connected.</returns>
        IList<int> getDirectConnections(IList<int> keys, int map);

        /// <summary>
        /// Generates connection data based on current sprite positions.
        /// Creates connection entries that reflect the visual arrangement of maps.
        /// </summary>
        /// <returns>The generated connection data.</returns>
        IList<object> generateConnectionData();

        /// <summary>
        /// Serializes connection data to file and updates the game's connection data.
        /// Saves the visual map arrangement as actual game connection data.
        /// </summary>
        void serializeConnectionData();

        /// <summary>
        /// Places a map sprite and all its connected neighbors.
        /// </summary>
        /// <param name="id">The map ID to place.</param>
        void putSprite(int id);

        /// <summary>
        /// Adds a single map sprite at the center of the screen.
        /// </summary>
        /// <param name="id">The map ID to add.</param>
        void addSprite(int id);

        /// <summary>
        /// Saves the current positions of all map sprites.
        /// Used for implementing canvas dragging functionality.
        /// </summary>
        void saveMapSpritePos();

        /// <summary>
        /// Initializes the map screen scene with all necessary sprites and data.
        /// Sets up the visual interface for map connection editing.
        /// </summary>
        void mapScreen();

        /// <summary>
        /// Sets which map sprite should be displayed on top.
        /// Used to bring selected maps to the front for better visibility.
        /// </summary>
        /// <param name="id">The map ID to bring to the top.</param>
        void setTopSprite(int id);

        /// <summary>
        /// Displays a help window with control instructions.
        /// Shows users how to interact with the map connection editor.
        /// </summary>
        void helpWindow();

        /// <summary>
        /// Gets the screen rectangle occupied by a map sprite.
        /// </summary>
        /// <param name="mapid">The map ID to get the rectangle for.</param>
        /// <returns>Array containing [left, top, right, bottom] coordinates.</returns>
        int[] getMapRect(int mapid);

        /// <summary>
        /// Handles double-click events on map sprites.
        /// Opens the map metadata editor for the double-clicked map.
        /// </summary>
        /// <param name="map_id">The ID of the map that was double-clicked.</param>
        void onDoubleClick(int map_id);

        /// <summary>
        /// Handles single-click events on map sprites or canvas.
        /// Initiates dragging operations and sprite selection.
        /// </summary>
        /// <param name="mapid">The ID of the clicked map, or -1 for canvas.</param>
        /// <param name="x">The X coordinate of the click.</param>
        /// <param name="y">The Y coordinate of the click.</param>
        void onClick(int mapid, int x, int y);

        /// <summary>
        /// Handles right-click events on map sprites.
        /// Reserved for future context menu functionality.
        /// </summary>
        /// <param name="mapid">The ID of the right-clicked map.</param>
        /// <param name="x">The X coordinate of the click.</param>
        /// <param name="y">The Y coordinate of the click.</param>
        void onRightClick(int mapid, int x, int y);

        /// <summary>
        /// Handles mouse release events.
        /// Ends dragging operations when the mouse button is released.
        /// </summary>
        /// <param name="mapid">The ID of the map where the mouse was released.</param>
        void onMouseUp(int mapid);

        /// <summary>
        /// Handles right mouse button release events.
        /// Reserved for future context menu functionality.
        /// </summary>
        /// <param name="mapid">The ID of the map where the right mouse was released.</param>
        void onRightMouseUp(int mapid);

        /// <summary>
        /// Handles mouse hover events over map sprites.
        /// Reserved for future tooltip or hover functionality.
        /// </summary>
        /// <param name="mapid">The ID of the map being hovered over.</param>
        /// <param name="x">The X coordinate of the mouse.</param>
        /// <param name="y">The Y coordinate of the mouse.</param>
        void onMouseOver(int mapid, int x, int y);

        /// <summary>
        /// Handles mouse movement events.
        /// Updates sprite positions during dragging operations and updates status display.
        /// </summary>
        /// <param name="mapid">The ID of the map under the mouse cursor.</param>
        /// <param name="x">The X coordinate of the mouse.</param>
        /// <param name="y">The Y coordinate of the mouse.</param>
        void onMouseMove(int mapid, int x, int y);

        /// <summary>
        /// Performs hit testing to determine which map sprite is under the cursor.
        /// </summary>
        /// <param name="x">The X coordinate to test.</param>
        /// <param name="y">The Y coordinate to test.</param>
        /// <returns>The ID of the map under the cursor, or -1 if none.</returns>
        int hittest(int x, int y);

        /// <summary>
        /// Displays a map selection screen with the specified title.
        /// </summary>
        /// <param name="title">The title to display for the selection screen.</param>
        /// <param name="currentmap">The currently selected map ID.</param>
        /// <returns>The ID of the selected map, or -1 if cancelled.</returns>
        int chooseMapScreen(string title, int currentmap);

        /// <summary>
        /// Updates the scene, processing input and mouse interactions.
        /// Called every frame to handle user interactions with the editor.
        /// </summary>
        void update();

        /// <summary>
        /// Main loop for the map screen scene.
        /// Handles the complete editing session until the user exits.
        /// </summary>
        void MapScreenLoop();
    }

    /// <summary>
    /// Global function interface for launching the map connections editor.
    /// </summary>
    //public interface IMainConnectionsEditor : IMain
    public interface IMainEditorMapConnections : IMain
    {
        /// <summary>
        /// Opens the map connections editor interface.
        /// Allows visual editing of how maps connect to each other in the game world.
        /// </summary>
        void ConnectionsEditor();
    }
}