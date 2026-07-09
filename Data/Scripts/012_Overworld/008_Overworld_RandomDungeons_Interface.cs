using PokemonEssentials.Data;
using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for edge mask constants used in random dungeon generation.
    /// </summary>
    /// <remarks>
    /// Bitwise values used to keep track of the generation of node connections.
    /// </remarks>
    public interface IRandomDungeonEdgeMasks
    {
        /// <summary>
        /// North edge mask value.
        /// </summary>
        int NORTH { get; }

        /// <summary>
        /// East edge mask value.
        /// </summary>
        int EAST { get; }

        /// <summary>
        /// South edge mask value.
        /// </summary>
        int SOUTH { get; }

        /// <summary>
        /// West edge mask value.
        /// </summary>
        int WEST { get; }
    }

    /// <summary>
    /// Interface for a node in a randomly generated dungeon maze.
    /// </summary>
    /// <remarks>
    /// A node in a randomly generated dungeon. There is one node per cell, and
    /// nodes are connected to each other.
    /// </remarks>
    public interface IRandomDungeonMazeNode
    {
        IRandomDungeonMazeNode initialize();

        /// <summary>
        /// Gets the edge pattern for this node.
        /// </summary>
        /// <returns>The edge pattern as a bitmask</returns>
        int edge_pattern();

        /// <summary>
        /// Blocks an edge from connecting to adjacent nodes.
        /// </summary>
        /// <param name="e">The edge to block</param>
        void block_edge(int e);

        /// <summary>
        /// Connects an edge to adjacent nodes.
        /// </summary>
        /// <param name="e">The edge to connect</param>
        void connect_edge(int e);

        /// <summary>
        /// Blocks all edges.
        /// </summary>
        void block_all_edges();

        /// <summary>
        /// Connects all edges.
        /// </summary>
        void connect_all_edges();

        /// <summary>
        /// Checks if an edge is blocked.
        /// </summary>
        /// <param name="e">The edge to check</param>
        /// <returns>True if the edge is blocked</returns>
        bool edge_blocked(int e);

        /// <summary>
        /// Checks if all edges are blocked.
        /// </summary>
        /// <returns>True if all edges are blocked</returns>
        bool all_edges_blocked();

        /// <summary>
        /// Checks if this node is visitable.
        /// </summary>
        /// <returns>True if visitable</returns>
        bool visitable();

        /// <summary>
        /// Sets this node as visitable.
        /// </summary>
        void set_visitable();

        /// <summary>
        /// Checks if this node has been visited.
        /// </summary>
        /// <returns>True if visited</returns>
        bool visited();

        /// <summary>
        /// Sets this node as visited.
        /// </summary>
        void set_visited();

        /// <summary>
        /// Checks if this node contains a room.
        /// </summary>
        /// <returns>True if this is a room node</returns>
        bool room();

        /// <summary>
        /// Sets this node as a room.
        /// </summary>
        void set_room();
    }

    /// <summary>
    /// Interface for the maze generator that connects nodes together.
    /// </summary>
    /// <remarks>
    /// Maze generator. Given the number of nodes horizontally and vertically in a
    /// map, connects all the nodes together.
    /// </remarks>
    public interface IRandomDungeonMaze
    {
        /// <summary>
        /// Gets or sets the number of nodes horizontally.
        /// </summary>
        int node_count_x { get; set; }

        /// <summary>
        /// Gets or sets the number of nodes vertically.
        /// </summary>
        int node_count_y { get; set; }

        /// <summary>
        /// Array of direction constants.
        /// </summary>
        int[] DIRECTIONS { get; }

        IRandomDungeonMaze initialize(IWindow cw, object ch, params object[] parameters);

        /// <summary>
        /// Checks if the given coordinates are valid for a node.
        /// </summary>
        /// <param name="x">X coordinate</param>
        /// <param name="y">Y coordinate</param>
        /// <returns>True if valid</returns>
        bool valid_node(int x, int y);

        /// <summary>
        /// Gets the node at the specified coordinates.
        /// </summary>
        /// <param name="x">X coordinate</param>
        /// <param name="y">Y coordinate</param>
        /// <returns>The maze node or null if invalid</returns>
        IRandomDungeonMazeNode get_node(int x, int y);

        /// <summary>
        /// Checks if a node has been visited.
        /// </summary>
        /// <param name="x">X coordinate</param>
        /// <param name="y">Y coordinate</param>
        /// <returns>True if visited or invalid</returns>
        bool node_visited(int x, int y);

        /// <summary>
        /// Sets a node as visited.
        /// </summary>
        /// <param name="x">X coordinate</param>
        /// <param name="y">Y coordinate</param>
        void set_node_visited(int x, int y);

        /// <summary>
        /// Checks if a node's edge is blocked.
        /// </summary>
        /// <param name="x">X coordinate</param>
        /// <param name="y">Y coordinate</param>
        /// <param name="edge">The edge to check</param>
        /// <returns>True if blocked</returns>
        bool node_edge_blocked(int x, int y, int edge);

        /// <summary>
        /// Connects node edges bidirectionally.
        /// </summary>
        /// <param name="x">X coordinate</param>
        /// <param name="y">Y coordinate</param>
        /// <param name="edge">The edge to connect</param>
        void connect_node_edges(int x, int y, int edge);

        /// <summary>
        /// Gets the number of room nodes in the maze.
        /// </summary>
        /// <returns>Room count</returns>
        int room_count();

        /// <summary>
        /// Gets coordinates in a direction from the given position.
        /// </summary>
        /// <param name="x">Starting X coordinate</param>
        /// <param name="y">Starting Y coordinate</param>
        /// <param name="dir">Direction to move</param>
        /// <param name="include_direction">Whether to include the opposite direction</param>
        /// <returns>New coordinates and optionally the opposite direction</returns>
        IPoint get_coords_in_direction(int x, int y, int dir, bool include_direction = false);

        /// <summary>
        /// Generates the layout of the maze.
        /// </summary>
        void generate_layout();

        /// <summary>
        /// Checks if a node is active in the given layout pattern.
        /// </summary>
        /// <param name="x">X coordinate</param>
        /// <param name="y">Y coordinate</param>
        /// <param name="layout">Layout pattern</param>
        /// <returns>True if active</returns>
        bool check_active_node(int x, int y, object layout);

        /// <summary>
        /// Sets which nodes are visitable based on the layout.
        /// </summary>
        /// <returns>List of visitable node coordinates</returns>
        IList<int[]> set_visitable_nodes();

        /// <summary>
        /// Generates a depth-first maze from visitable nodes.
        /// </summary>
        /// <param name="visitable_nodes">List of visitable node coordinates</param>
        void generate_depth_first_maze(IList<int[]> visitable_nodes);

        /// <summary>
        /// Adds additional connections beyond the basic maze structure.
        /// </summary>
        void add_more_connections();

        /// <summary>
        /// Spawns rooms in some of the nodes.
        /// </summary>
        /// <param name="visitable_nodes">List of visitable node coordinates</param>
        void spawn_rooms(IList<int[]> visitable_nodes);
    }

    /// <summary>
    /// Interface for the dungeon layout that stores tile types.
    /// </summary>
    /// <remarks>
    /// Arrays of tile types in the dungeon map.
    /// </remarks>
    public interface IRandomDungeonLayout
    {
        /// <summary>
        /// Gets or sets the width of the layout.
        /// </summary>
        int width { get; set; }

        /// <summary>
        /// Gets or sets the height of the layout.
        /// </summary>
        int height { get; set; }

        /// <summary>
        /// Dictionary of text symbols for debugging output.
        /// </summary>
        /// <remarks>
        /// Used for debugging when printing out an ASCII image of the dungeon
        /// </remarks>
        IDictionary<int, string> TEXT_SYMBOLS { get; }

        /// <summary>
        /// Gets or sets a tile value at the specified coordinates and layer.
        /// </summary>
        /// <param name="x">X coordinate</param>
        /// <param name="y">Y coordinate</param>
        /// <param name="layer">Layer index</param>
        /// <returns>The tile value</returns>
        object this[int x, int y, int layer] { get; set; }

        IRandomDungeonLayout initialize(int width, int height);

        /// <summary>
        /// Gets the effective tile value at coordinates, considering layer priority.
        /// </summary>
        /// <param name="x">X coordinate</param>
        /// <param name="y">Y coordinate</param>
        /// <returns>The effective tile value</returns>
        int value(int x, int y);

        /// <summary>
        /// Clears the layout to default values.
        /// </summary>
        void clear();

        /// <summary>
        /// Sets a wall tile at the specified coordinates.
        /// </summary>
        /// <param name="x">X coordinate</param>
        /// <param name="y">Y coordinate</param>
        /// <param name="value">Wall tile value</param>
        void set_wall(int x, int y, object value);

        /// <summary>
        /// Sets a ground tile at the specified coordinates.
        /// </summary>
        /// <param name="x">X coordinate</param>
        /// <param name="y">Y coordinate</param>
        /// <param name="value">Ground tile value</param>
        void set_ground(int x, int y, object value);

        /// <summary>
        /// Writes the layout as a text representation for debugging.
        /// </summary>
        /// <returns>Text representation of the layout</returns>
        string write();
    }

    /// <summary>
    /// Interface for the main dungeon generator.
    /// </summary>
    public interface IDungeon
    {
        /// <summary>
        /// Gets or sets the width of the dungeon.
        /// </summary>
        int width { get; set; }

        /// <summary>
        /// Gets or sets the height of the dungeon.
        /// </summary>
        int height { get; set; }

        /// <summary>
        /// Gets or sets the dungeon parameters.
        /// </summary>
        object parameters { get; set; }

        /// <summary>
        /// Gets or sets the RNG seed used for generation.
        /// </summary>
        int rng_seed { get; set; }

        /// <summary>
        /// Gets or sets the tileset used for the dungeon.
        /// </summary>
        object tileset { get; set; }

        /// <summary>
        /// Array for mapping floor neighbors to wall types.
        /// </summary>
        /// <remarks>
        /// 0 is none (index 0 only) or corridor/floor
        /// -1 are tile combinations that need special attention
        /// Other numbers correspond to tile types (see def get_wall_tile_for_coord)
        /// </remarks>
        int[] FLOOR_NEIGHBOURS_TO_WALL { get; }

        /// <summary>
        /// Gets or sets a tile value at the specified coordinates.
        /// </summary>
        /// <param name="x">X coordinate</param>
        /// <param name="y">Y coordinate</param>
        /// <param name="layer">Optional layer index</param>
        /// <returns>The tile value</returns>
        object this[int x, int y, int? layer = null] { get; set; }

        IDungeon initialize(int width, int height, IDungeonTileset tileset, object parameters = null);

        /// <summary>
        /// Writes the dungeon layout as text for debugging.
        /// </summary>
        /// <returns>Text representation</returns>
        string write();

        /// <summary>
        /// Checks if the given coordinates are a room floor suitable for events.
        /// </summary>
        /// <remarks>
        /// Returns whether the given coordinates are a room floor that isn't too
        /// close to a corridor. For positioning events/the player upon entering.
        /// </remarks>
        /// <param name="x">X coordinate</param>
        /// <param name="y">Y coordinate</param>
        /// <returns>True if suitable for room placement</returns>
        bool isRoom(int x, int y);

        /// <summary>
        /// Checks if a tile value represents ground.
        /// </summary>
        /// <param name="value">Tile value</param>
        /// <returns>True if ground tile</returns>
        bool tile_is_ground(object value);

        /// <summary>
        /// Checks if a tile value represents a wall.
        /// </summary>
        /// <remarks>
        /// Lower wall tiles only.
        /// </remarks>
        /// <param name="value">Tile value</param>
        /// <returns>True if wall tile</returns>
        bool tile_is_wall(object value);

        /// <summary>
        /// Checks if coordinates represent ground.
        /// </summary>
        /// <param name="x">X coordinate</param>
        /// <param name="y">Y coordinate</param>
        /// <returns>True if ground coordinates</returns>
        bool coord_is_ground(int x, int y);

        /// <summary>
        /// Generates the complete dungeon layout and tiles.
        /// </summary>
        void generate();

        void generate_layout(int maxWidth, int maxHeight);

        void generate_walls(int maxWidth, int maxHeight);

        /// <summary>
        /// Determines whether all floor tiles are contiguous. Sets @need_redraw if
        /// there are 2+ floor regions that are isolated from each other.
        /// </summary>
        void check_for_isolated_rooms();

        /// <summary>
        /// Fixes (most) situations where it isn't immediately obvious how to draw a
        /// wall around a floor area.
        /// </summary>
        void resolve_wall_error(int x, int y, int layer = 0);

        /// <summary>
        /// Draws a cell's contents, which is an underlying pattern based on
        /// tile_layout (the corridors), and possibly a room on top of that.
        /// </summary>
        /// <param name="cell_x"></param>
        /// <param name="cell_y"></param>
        /// <param name="node"></param>
        void paint_node_contents(int cell_x, int cell_y, int node);

        void paint_ground_rect(int x, int y, int width, int height, int tile);

        /// <summary>
        /// Draws corridors leading from the node at (cell_x, cell_y).
        /// </summary>
        /// <param name="cell_x"></param>
        /// <param name="cell_y"></param>
        /// <param name="pattern"></param>
        void paint_connections(int cell_x, int cell_y, int pattern);

        /// <summary>
        /// Draws a room at (cell_x, cell_y).
        /// </summary>
        /// <param name="cell_x"></param>
        /// <param name="cell_y"></param>
        void paint_room(int cell_x, int cell_y);

        void paint_walls_around_ground(int x, int y, int layer, int errors);

        void get_wall_tile_for_coord(int x, int y, int layer = 0);

        void paint_decorations(int maxWidth, int maxHeight);

        void paint_wall_top_tiles(int maxWidth, int maxHeight);

        /// <summary>
        /// Converts the dungeon layout into map tiles and applies to the given map.
        /// </summary>
        /// <remarks>
        /// Convert dungeon layout into proper map tiles from a tileset, and modifies
        /// the given map's data accordingly.
        /// </remarks>
        /// <param name="map">The map to modify</param>
        void generateMapInPlace(object map);

        /// <summary>
        /// Gets a random room tile where an event can be placed.
        /// </summary>
        /// <remarks>
        /// Returns a random room tile a random room where an event of the given size
        /// can be placed. Events cannot be placed adjacent to or overlapping each
        /// other, and can't be placed right next to the wall of a room (to prevent
        /// them blocking a corridor).
        /// </remarks>
        /// <param name="occupied_tiles">List of already occupied tile coordinates</param>
        /// <param name="event_width">Width of the event</param>
        /// <param name="event_height">Height of the event</param>
        /// <returns>Coordinates for event placement or null if no space</returns>
        int[] get_random_room_tile(IList<int[]> occupied_tiles, int event_width = 1, int event_height = 1);
    }

    /// <summary>
    /// Interface for global metadata related to random dungeons.
    /// </summary>
    /// <remarks>
    /// Variables that determine which dungeon parameters to use to generate a random
    /// dungeon.
    /// </remarks>
    public interface IGlobalMetadataRandomDungeon : IGlobalMetadata
    {
        /// <summary>
        /// Gets or sets the current dungeon area.
        /// </summary>
        object dungeon_area { get; set; }

        /// <summary>
        /// Gets or sets the current dungeon version.
        /// </summary>
        int dungeon_version { get; set; }

        /// <summary>
        /// Gets or sets the RNG seed for dungeon generation.
        /// </summary>
        int? dungeon_rng_seed { get; set; }
    }

    public interface IMainOverworldRandomDungeon : IMain
    {
        /// <summary>
        /// Code that generates a random dungeon layout, and implements it in a given map.
        /// </summary>
        /// <seealso cref="IEvents.OnMapCreate"/>
        /// <seealso cref="EventArg.IOnMapCreateEventArgs"/>
        /// <param name="map_id"></param>
        /// <param name="map"></param>
        /// <param name="_tileset_data"></param>
        void OnGameMapSetup_random_dungeon(int map_id, IGameMap map, IDungeonTileset _tileset_data);
    }
}