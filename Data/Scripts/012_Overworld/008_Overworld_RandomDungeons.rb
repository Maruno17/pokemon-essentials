#===============================================================================
# Code that generates a random dungeon layout, and implements it in a given map.
#===============================================================================
module RandomDungeonGenerator
  #=============================================================================
  # This class is designed to favor different values more than a uniform
  # random generator does.
  #=============================================================================
  class AntiRandom
    def initialize(size)
      @old = []
      @new = Array.new(size) { |i| i }
    end

    def get
      if @new.length == 0   # No new values
        @new = @old.clone
        @old.clear
      end
      if @old.length > 0 && rand(7) == 0   # Get old value
        return @old[rand(@old.length)]
      end
      if @new.length > 0   # Get new value
        ret = @new.delete_at(rand(@new.length))
        @old.push(ret)
        return ret
      end
      return @old[rand(@old.length)]   # Get old value
    end
  end

  #=============================================================================
  # Contains constants that define what types of tiles a random dungeon map can
  # consist of, and helper methods that translate those tiles into data usable
  # by a map/printable to the console (for debug purposes).
  #=============================================================================
  module DungeonTile
    VOID     = 0
    ROOM     = 1
    WALL     = 2
    CORRIDOR = 3
    # Which autotile each type of tile uses (1-7)
    TILE_IDS = {
      VOID     => 1,
      ROOM     => 2,
      WALL     => 3,
      CORRIDOR => 2
    }
    # Used for debugging when printing out an ASCII image of the dungeon
    TEXT_SYMBOLS = {
      VOID     => "#",
      ROOM     => " ",
      WALL     => "=",
      CORRIDOR => "."
    }

    module_function

    def to_tile_id(value)
      return TILE_IDS[value] || TILE_IDS[VOID]
    end

    def to_text(value)
      return TEXT_SYMBOLS[value] || "\e[30m\e[41m?\e[0m"
    end
  end

  #=============================================================================
  # Helper functions that set tiles in the map to a particular type.
  #=============================================================================
  module DungeonMaze
    CELL_WIDTH      = 13                # Should be at least 7
    CELL_HEIGHT     = 13                # Should be at least 7
    ROOM_MIN_WIDTH  = 5
    ROOM_MAX_WIDTH  = CELL_WIDTH - 2    # Should be at most CELL_WIDTH - 2
    ROOM_MIN_HEIGHT = 4
    ROOM_MAX_HEIGHT = CELL_HEIGHT - 3   # Should be at most CELL_HEIGHT - 3
    CORRIDOR_WIDTH  = 3
    TURN_NONE  = 0
    TURN_LEFT  = 1
    TURN_RIGHT = 2
    TURN_BACK  = 3
    @@corridor_layouts = nil

    module_function

    # Generates sets of tiles depicting corridors coming out of a room, for all
    # combinations of the sides that they can come out of.
    def generate_corridor_patterns
      if !@@corridor_layouts
        tiles = []
        x_offset = (CELL_WIDTH - CORRIDOR_WIDTH) / 2
        y_offset = (CELL_HEIGHT - CORRIDOR_WIDTH) / 2
        16.times do |combo|
          tiles[combo] = []
          (CELL_WIDTH * CELL_HEIGHT).times do |i|
            tiles[combo][i] = DungeonTile::VOID
          end
          if (combo & EdgeMasks::NORTH) == 0
            paint_corridor(tiles[combo], x_offset, 0, CORRIDOR_WIDTH, y_offset + CORRIDOR_WIDTH)
          end
          if (combo & EdgeMasks::SOUTH) == 0
            paint_corridor(tiles[combo], x_offset, y_offset, CORRIDOR_WIDTH, CELL_HEIGHT - y_offset)
          end
          if (combo & EdgeMasks::EAST) == 0
            paint_corridor(tiles[combo], x_offset, y_offset, CELL_WIDTH - x_offset, CORRIDOR_WIDTH)
          end
          if (combo & EdgeMasks::WEST) == 0
            paint_corridor(tiles[combo], 0, y_offset, x_offset + CORRIDOR_WIDTH, CORRIDOR_WIDTH)
          end
        end
        @@corridor_layouts = tiles
      end
      return @@corridor_layouts
    end

    # Makes all tiles in a particular area corridor tiles.
    def paint_corridor(tile, x, y, width, height)
      height.times do |j|
        width.times do |i|
          tile[((y + j) * CELL_WIDTH) + (x + i)] = DungeonTile::CORRIDOR
        end
      end
    end

    # Used to draw tiles from the given tile_layout and rotation (for corridors).
    def paint_tile_layout(dungeon, dstX, dstY, tile_layout, rotation)
      case rotation
      when TURN_NONE
        CELL_HEIGHT.times do |y|
          CELL_WIDTH.times do |x|
            dungeon[x + dstX, y + dstY] = tile_layout[(y * CELL_WIDTH) + x]
          end
        end
      when TURN_LEFT
        CELL_HEIGHT.times do |y|
          CELL_WIDTH.times do |x|
            dungeon[y + dstX, CELL_WIDTH - 1 - x + dstY] = tile_layout[(y * CELL_WIDTH) + x]
          end
        end
      when TURN_RIGHT
        CELL_HEIGHT.times do |y|
          CELL_WIDTH.times do |x|
            dungeon[CELL_HEIGHT - 1 - y + dstX, x + dstY] = tile_layout[(y * CELL_WIDTH) + x]
          end
        end
      when TURN_BACK
        CELL_HEIGHT.times do |y|
          CELL_WIDTH.times do |x|
            dungeon[CELL_WIDTH - 1 - x + dstX, CELL_HEIGHT - 1 - y + dstY] = tile_layout[(y * CELL_WIDTH) + x]
          end
        end
      end
    end

    # Draws a cell's contents, which is an underlying pattern based on tile
    # _layout and a rotation (the corridors), and possibly a room on top of that.
    def paint_cell_contents(dungeon, xDst, yDst, tile_layout, rotation)
      return false if !tile_layout
      # Draw the corridors
      paint_tile_layout(dungeon, xDst, yDst, tile_layout, rotation)
      return false if rand(100) < 30
      # Generate a randomly placed room
      width = rand(ROOM_MIN_WIDTH..ROOM_MAX_WIDTH)
      height = rand(ROOM_MIN_HEIGHT..ROOM_MAX_HEIGHT)
      return false if width <= 0 || height <= 0
      centerX = (CELL_WIDTH / 2) + rand(5) - 2
      centerY = (CELL_HEIGHT / 2) + rand(5) - 2
      x = centerX - (width / 2)
      y = centerY - (height / 2)
      rect = [x, y, width, height]
      rect[0] = rect[0].clamp(1, CELL_WIDTH - 1 - width)
      rect[1] = rect[1].clamp(2, CELL_HEIGHT - 1 - height)   # 2 because walls are 2 tiles tall
      dungeon.paint_room(rect, xDst, yDst)
      return true
    end
  end

  #=============================================================================
  # Bitwise values used to keep track of the generation of node connections.
  #=============================================================================
  module EdgeMasks
    NORTH   = 1
    WEST    = 2
    EAST    = 4
    SOUTH   = 8
    VISITED = 16
  end

  #=============================================================================
  # A node in a randomly generated dungeon. There is one node per cell, and
  # nodes are connected to each other.
  #=============================================================================
  class MazeNode
    def initialize
      @edges = 0
    end

    def setEdge(e);   @edges |= e;              end
    def clearEdge(e); @edges &= ~e;             end
    def clear;        @edges = 0;               end
    def set;          @edges = 15;              end
    def getEdge(e);   return (@edges & e) != 0; end
    def isBlocked?;   return @edges != 0;       end
  end

  #=============================================================================
  # Vector class representing the location of a node.
  #=============================================================================
  class NodeListElement
    attr_accessor :x, :y

    def initialize(x, y)
      @x = x
      @y = y
    end
  end

  #=============================================================================
  # Maze generator. Given the number of cells horizontally and vertically in a
  # map, connects all the cells together.
  # A node is the boundary between two adjacent cells, which may or may not be a
  # connection.
  #=============================================================================
  class Maze
    attr_accessor :cellWidth, :cellHeight, :nodeWidth, :nodeHeight

    DIRECTIONS = [EdgeMasks::NORTH, EdgeMasks::SOUTH, EdgeMasks::EAST, EdgeMasks::WEST]

    def initialize(cw, ch)
      raise ArgumentError.new if cw == 0 || ch == 0
      @cellWidth  = cw
      @cellHeight = ch
      @nodeWidth  = cw + 1
      @nodeHeight = ch + 1
      @cells = []
      clearAllCells
      @nodes = Array.new(@nodeWidth * @nodeHeight) { MazeNode.new }
    end

    def randomDir
      return DIRECTIONS[rand(4)]
    end

    def getVisited(x, y)
      return false if x < 0 || y < 0 || x >= cellWidth || x >= cellHeight
      return (@cells[(y * cellWidth) + x] & EdgeMasks::VISITED) != 0
    end

    def setVisited(x, y)
      return if x < 0 || y < 0 || x >= cellWidth || x >= cellHeight
      @cells[(y * cellWidth) + x] |= EdgeMasks::VISITED
    end

    def clearVisited(x, y)
      return if x < 0 || y < 0 || x >= cellWidth || x >= cellHeight
      @cells[(y * cellWidth) + x] &= ~EdgeMasks::VISITED
    end

    def clearAllCells
      (cellWidth * cellHeight).times do |c|
        @cells[c] = 0
      end
    end

    def getEdgeNode(x, y, edge)
      return false if x < 0 || y < 0 || x >= nodeWidth || y >= nodeHeight
      return @nodes[(y * nodeWidth) + x].getEdge(edge)
    end

    def setEdgeNode(x, y, edge)
      return if x < 0 || x >= nodeWidth || y < 0 || y >= nodeHeight
      @nodes[(y * nodeWidth) + x].setEdge(edge)
      e = 0
      nx = x
      ny = y
      case edge
      when EdgeMasks::NORTH
        e = EdgeMasks::SOUTH
        ny = y - 1
      when EdgeMasks::SOUTH
        e = EdgeMasks::NORTH
        ny = y + 1
      when EdgeMasks::EAST
        e = EdgeMasks::WEST
        nx = x + 1
      when EdgeMasks::WEST
        e = EdgeMasks::EAST
        nx = x - 1
      else
        return
      end
      return if nx < 0 || ny < 0 || nx >= nodeWidth || ny >= nodeHeight
      @nodes[(ny * nodeWidth) + nx].setEdge(e)
    end

    def setAllEdges
      (nodeWidth * nodeHeight).times do |c|
        @nodes[c].set
      end
    end

    def clearEdgeNode(x, y, edge)
      return if x < 0 || x >= nodeWidth || y < 0 || y >= nodeHeight
      @nodes[(y * nodeWidth) + x].clearEdge(edge)
      e = 0
      nx = x
      ny = y
      case edge
      when EdgeMasks::NORTH
        e = EdgeMasks::SOUTH
        ny -= 1
      when EdgeMasks::SOUTH
        e = EdgeMasks::NORTH
        ny += 1
      when EdgeMasks::EAST
        e = EdgeMasks::WEST
        nx += 1
      when EdgeMasks::WEST
        e = EdgeMasks::EAST
        nx -= 1
      else
        raise ArgumentError.new
      end
      return if nx < 0 || ny < 0 || nx >= nodeWidth || ny >= nodeHeight
      @nodes[(ny * nodeWidth) + nx].clearEdge(e)
    end

    def clearAllEdges
      (nodeWidth * nodeHeight).times do |c|
        @nodes[c].clear
      end
    end

    def isBlockedNode?(x, y)
      return false if x < 0 || y < 0 || x >= nodeWidth || y >= nodeHeight
      return @nodes[(y * nodeWidth) + x].isBlocked?
    end

    def getEdgePattern(x, y)
      pattern = 0
      pattern |= EdgeMasks::NORTH if getEdgeNode(x, y, EdgeMasks::NORTH)
      pattern |= EdgeMasks::SOUTH if getEdgeNode(x, y, EdgeMasks::SOUTH)
      pattern |= EdgeMasks::EAST if getEdgeNode(x, y, EdgeMasks::EAST)
      pattern |= EdgeMasks::WEST if getEdgeNode(x, y, EdgeMasks::WEST)
      return pattern
    end

    def buildMazeWall(x, y, dir, len)
      return if isBlockedNode?(x, y)
      wx = x
      wy = y
      len.times do
        ox = wx
        oy = wy
        case dir
        when EdgeMasks::NORTH
          wy -= 1
        when EdgeMasks::WEST
          wx -= 1
        when EdgeMasks::EAST
          wx += 1
        when EdgeMasks::SOUTH
          wy += 1
        end
        if isBlockedNode?(wx, wy)
          setEdgeNode(ox, oy, dir)
          return
        end
        setEdgeNode(ox, oy, dir)
      end
    end

    def buildNodeList
      list = []
      nodeWidth.times do |x|
        nodeHeight.times do |y|
          list.push(NodeListElement.new(x, y))
        end
      end
      list.shuffle!
      return list
    end

    def generateWallGrowthMaze(minWall = 0, maxWall = nil)
      maxWall = cellWidth if !maxWall
      nlist = buildNodeList
      return if nlist.length == 0
      nlist.length.times do |c|
        d = randomDir
        len = rand(maxWall + 1)
        x = nlist[c].x
        y = nlist[c].y
        buildMazeWall(x, y, d, len)
      end
    end

    def recurseDepthFirst(x, y, depth)
      setVisited(x, y)
      dirs = DIRECTIONS.shuffle
      4.times do |c|
        d = dirs[c]
        cx = x
        cy = y
        case d
        when EdgeMasks::NORTH
          cy -= 1
        when EdgeMasks::SOUTH
          cy += 1
        when EdgeMasks::EAST
          cx += 1
        when EdgeMasks::WEST
          cx -= 1
        end
        if cx >= 0 && cy >= 0 && cx < cellWidth && cy < cellHeight && !getVisited(cx, cy)
          clearEdgeNode(x, y, d)
          recurseDepthFirst(cx, cy, depth + 1)
        end
      end
    end

    def generateDepthFirstMaze
      # Pick a cell to start in
      sx = rand(cellWidth)
      sy = rand(cellHeight)
      # Set up all nodes
      setAllEdges
      # Generate a maze
      recurseDepthFirst(sx, sy, 0)
    end
  end

  #=============================================================================
  # Random dungeon generator class. Calls class Maze to generate the abstract
  # layout of the dungeon, and turns that into usable map data.
  #=============================================================================
  class Dungeon
    class DungeonTable
      def initialize(dungeon)
        @dungeon = dungeon
      end

      def xsize; @dungeon.width;  end
      def ysize; @dungeon.height; end

      # Returns which tile in the tileset corresponds to the type of tile is at
      # the given coordinates
      def [](x, y)
        return DungeonTile.to_tile_id(@dungeon[x, y])
      end
    end

    attr_accessor :width, :height

    BUFFER_X = 8
    BUFFER_Y = 6

    def initialize(width, height)
      @width  = width
      @height = height
      @array  = []
    end

    def clear
      (width * height).times do |i|
        @array[i] = DungeonTile::VOID
      end
    end

    def write
      ret = ""
      i = 0
      @height.times do |y|
        @width.times do |x|
          ret += DungeonTile.to_text(value(x, y))
          i += 1
        end
        ret += "\r\n"
      end
      return ret
    end

    def [](x, y)
      return @array[(y * @width) + x]
    end

    def []=(x, y, value)
      @array[(y * @width) + x] = value
    end

    def value(x, y)
      return DungeonTile::VOID if x < 0 || y < 0 || x >= @width || y >= @height
      return @array[(y * @width) + x]
    end

    # Unused
    def get(x, y)
      return false if x < 0 || y < 0 || x >= @width || y >= @height
      return @array[(y * @width) + x] != DungeonTile::VOID
    end

    # Unused
    def intersects?(r1, r2)
      return !(((r2[0] + r2[2] <= r1[0]) ||
                (r2[0] >= r1[0] + r1[2]) ||
                (r2[1] + r2[3] <= r1[1]) ||
                (r2[1] >= r1[1] + r1[3])) &&
               ((r1[0] <= r2[0] + r2[2]) ||
                (r1[0] >= r2[0] + r2[2]) ||
                (r1[1] + r1[3] <= r2[1]) ||
                (r1[1] >= r2[1] + r2[3]))
              )
    end

    # Returns whether the given coordinates are a room floor that isn't too close
    # to a corridor
    def isRoom?(x, y)
      if value(x, y) == DungeonTile::ROOM
        return false if value(x - 1, y - 1) == DungeonTile::CORRIDOR
        return false if value(    x, y - 1) == DungeonTile::CORRIDOR
        return false if value(x + 1, y - 1) == DungeonTile::CORRIDOR
        return false if value(x - 1,     y) == DungeonTile::CORRIDOR
        return false if value(x + 1,     y) == DungeonTile::CORRIDOR
        return false if value(x - 1, y + 1) == DungeonTile::CORRIDOR
        return false if value(    x, y + 1) == DungeonTile::CORRIDOR
        return false if value(x + 1, y + 1) == DungeonTile::CORRIDOR
        return true   # No surrounding tiles are corridor floor
      end
      return false
    end

    def isWall?(x, y)
      if value(x, y) == DungeonTile::VOID
        v1 = value(x, y + 1)
        return true if [DungeonTile::ROOM, DungeonTile::CORRIDOR].include?(v1)
        if v1 == DungeonTile::VOID   # The tile below is void
          v1 = value(x, y + 2)
          return true if [DungeonTile::ROOM, DungeonTile::CORRIDOR].include?(v1)
        end
      end
      return false
    end

    def paint_room(rect, offsetX, offsetY)
      ((rect[1] + offsetY)...(rect[1] + offsetY + rect[3])).each do |y|
        ((rect[0] + offsetX)...(rect[0] + offsetX + rect[2])).each do |x|
          self[x, y] = DungeonTile::ROOM
        end
      end
    end

    def generate
      self.clear
      maxWidth = @width - (BUFFER_X * 2)
      maxHeight = @height - (BUFFER_Y * 2)
      cellWidth = DungeonMaze::CELL_WIDTH
      cellHeight = DungeonMaze::CELL_HEIGHT
      return if maxWidth < 0 || maxHeight < 0
      if maxWidth < cellWidth || maxHeight < cellHeight   # Map is too small
        maxWidth.times do |x|
          maxHeight.times do |y|
            self[x + BUFFER_X, y + BUFFER_Y] = DungeonTile::ROOM
          end
        end
        return
      end
      # Generate connections between cells
      maze = Maze.new(maxWidth / cellWidth, maxHeight / cellHeight)
      maze.generateDepthFirstMaze
      # Draw each cell's contents in turn (room and corridors)
      corridor_patterns = DungeonMaze.generate_corridor_patterns
      roomcount = 0
      (maxHeight / cellHeight).times do |y|
        (maxWidth / cellWidth).times do |x|
          pattern = maze.getEdgePattern(x, y)
          next if !DungeonMaze.paint_cell_contents(
            self, BUFFER_X + (x * cellWidth), BUFFER_Y + (y * cellHeight),
            corridor_patterns[pattern], DungeonMaze::TURN_NONE
          )
          roomcount += 1
        end
      end
      # If no rooms were generated, make the whole map a room
      if roomcount == 0
        maxWidth.times do |x|
          maxHeight.times do |y|
            self[x + BUFFER_X, y + BUFFER_Y] = DungeonTile::ROOM
          end
        end
      end
      # Generate walls
      @height.times do |y|
        @width.times do |x|
          self[x, y] = DungeonTile::WALL if isWall?(x, y)   # Make appropriate tiles wall tiles
        end
      end
    end

    # Convert dungeon layout into proper map tiles
    def generateMapInPlace(map)
      tbl = DungeonTable.new(self)
      map.width.times do |i|
        map.height.times do |j|
          nb = TileDrawingHelper.tableNeighbors(tbl, i, j)
          tile = TileDrawingHelper::NEIGHBORS_TO_AUTOTILE_INDEX[nb]
          map.data[i, j, 0] = tile + (48 * (tbl[i, j]))
          map.data[i, j, 1] = 0
          map.data[i, j, 2] = 0
        end
      end
    end
  end

  #=============================================================================
  #
  #=============================================================================
  # Get a random room tile that isn't too close to a corridor (to avoid blocking
  # a room's entrance).
  def self.pbRandomRoomTile(dungeon, tiles)
    ar1 = AntiRandom.new(dungeon.width)
    ar2 = AntiRandom.new(dungeon.height)
    ((tiles.length + 1) * 1000).times do
      x = ar1.get
      y = ar2.get
      next if !dungeon.isRoom?(x, y) ||
              tiles.any? { |item| (item[0] - x).abs < 2 && (item[1] - y).abs < 2 }
      ret = [x, y]
      tiles.push(ret)
      return ret
    end
    return nil
  end

  # Test method that generates a dungeon map and prints it to the console.
  # @param x_cells [Integer] the number of cells wide the dungeon will be
  # @param y_cells [Intenger] the number of cells tall the dungeon will be
  def self.generate_test_dungeon(x_cells = 4, y_cells = 4)
    dungeon = Dungeon.new((Dungeon::BUFFER_X * 2) + (DungeonMaze::CELL_WIDTH * x_cells),
                          (Dungeon::BUFFER_Y * 2) + (DungeonMaze::CELL_HEIGHT * y_cells))
    dungeon.generate
    echoln dungeon.write
  end
end

EventHandlers.add(:on_game_map_setup, :random_dungeon,
  proc { |map_id, map, _tileset_data|
    next if !GameData::MapMetadata.try_get(map_id)&.random_dungeon
    # this map is a randomly generated dungeon
    dungeon = RandomDungeonGenerator::Dungeon.new(map.width, map.height)
    dungeon.generate
    dungeon.generateMapInPlace(map)
    roomtiles = []
    # Reposition events
    map.events.each_value do |event|
      tile = RandomDungeonGenerator.pbRandomRoomTile(dungeon, roomtiles)
      if tile
        event.x = tile[0]
        event.y = tile[1]
      end
    end
    # Override transfer X and Y
    tile = RandomDungeonGenerator.pbRandomRoomTile(dungeon, roomtiles)
    if tile
      $game_temp.player_new_x = tile[0]
      $game_temp.player_new_y = tile[1]
    end
  }
)
