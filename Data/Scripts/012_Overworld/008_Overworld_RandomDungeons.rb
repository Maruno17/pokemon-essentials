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
      WALL     => "-",
      CORRIDOR => "."
    }

    module_function

    def to_tile_id(value)
      return TILE_IDS[value] || TILE_IDS[VOID]
    end

    def to_text(value)
      return TEXT_SYMBOLS[value] || TEXT_SYMBOLS[VOID]
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
    None      = 0
    TurnLeft  = 1
    TurnRight = 2
    Turn180   = 3
    @@corridor_layouts = nil

    module_function

    # Generates sets of tiles depicting corridors coming out of a room, for all
    # combinations of the sides that they can come out of.
    def generate_corridor_patterns
      if !@@corridor_layouts
        tiles = []
        x_offset = (CELL_WIDTH - CORRIDOR_WIDTH) / 2
        y_offset = (CELL_HEIGHT - CORRIDOR_WIDTH) / 2
        for combo in 0...16
          tiles[combo] = []
          for i in 0...CELL_WIDTH * CELL_HEIGHT
            tiles[combo][i] = DungeonTile::VOID
          end
          if (combo & EdgeMasks::North) == 0
            paint_corridor(tiles[combo], x_offset, 0, CORRIDOR_WIDTH, y_offset + CORRIDOR_WIDTH)
          end
          if (combo & EdgeMasks::South) == 0
            paint_corridor(tiles[combo], x_offset, y_offset, CORRIDOR_WIDTH, CELL_HEIGHT - y_offset)
          end
          if (combo & EdgeMasks::East) == 0
            paint_corridor(tiles[combo], x_offset, y_offset, CELL_WIDTH - x_offset, CORRIDOR_WIDTH)
          end
          if (combo & EdgeMasks::West) == 0
            paint_corridor(tiles[combo], 0, y_offset, x_offset + CORRIDOR_WIDTH, CORRIDOR_WIDTH)
          end
        end
        @@corridor_layouts = tiles
      end
      return @@corridor_layouts
    end

    # Makes all tiles in a particular area corridor tiles.
    def paint_corridor(tile, x, y, width, height)
      for j in 0...height
        for i in 0...width
          tile[(y + j) * CELL_WIDTH + (x + i)] = DungeonTile::CORRIDOR
        end
      end
    end

    # Used to draw tiles from the given tile_layout and rotation (for corridors).
    def paint_tile_layout(dungeon, dstX, dstY, tile_layout, rotation)
      case rotation
      when None
        for y in 0...CELL_HEIGHT
          for x in 0...CELL_WIDTH
            dungeon[x + dstX, y + dstY] = tile_layout[y * CELL_WIDTH + x]
          end
        end
      when TurnLeft
        for y in 0...CELL_HEIGHT
          for x in 0...CELL_WIDTH
            dungeon[y + dstX , CELL_WIDTH - 1 - x + dstY] = tile_layout[y * CELL_WIDTH + x]
          end
        end
      when TurnRight
        for y in 0...CELL_HEIGHT
          for x in 0...CELL_WIDTH
            dungeon[CELL_HEIGHT - 1 - y + dstX, x + dstY] = tile_layout[y * CELL_WIDTH + x]
          end
        end
      when Turn180
        for y in 0...CELL_HEIGHT
          for x in 0...CELL_WIDTH
            dungeon[CELL_WIDTH - 1 - x + dstX, CELL_HEIGHT - 1 - y + dstY] = tile_layout[y * CELL_WIDTH + x]
          end
        end
      end
    end

    # Draws a cell's contents, which is an underlying pattern based on tile
    #_layout and a rotation (the corridors), and possibly a room on top of that.
    def paint_cell_contents(dungeon, xDst, yDst, tile_layout, rotation)
      return false if !tile_layout
      # Draw the corridors
      paint_tile_layout(dungeon, xDst, yDst, tile_layout, rotation)
      return false if rand(100) < 30
      # Generate a randomly placed room
      width = rand(ROOM_MIN_WIDTH..ROOM_MAX_WIDTH)
      height = rand(ROOM_MIN_HEIGHT..ROOM_MAX_HEIGHT)
      return false if width <= 0 || height <= 0
      centerX = CELL_WIDTH / 2 + rand(5) - 2
      centerY = CELL_HEIGHT / 2 + rand(5) - 2
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
    North   = 1
    West    = 2
    East    = 4
    South   = 8
    Visited = 16
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
    DIRECTIONS = [EdgeMasks::North, EdgeMasks::South, EdgeMasks::East, EdgeMasks::West]

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
      return (@cells[y * cellWidth + x] & EdgeMasks::Visited) != 0
    end

    def setVisited(x, y)
      return if x < 0 || y < 0 || x >= cellWidth || x >= cellHeight
      @cells[y * cellWidth + x] |= EdgeMasks::Visited
    end

    def clearVisited(x, y)
      return if x < 0 || y < 0 || x >= cellWidth || x >= cellHeight
      @cells[y * cellWidth + x] &=~EdgeMasks::Visited
    end

    def clearAllCells
      for c in 0...cellWidth * cellHeight
        @cells[c] = 0
      end
    end

    def getEdgeNode(x, y, edge)
      return false if x < 0 || y < 0 || x >= nodeWidth || y >= nodeHeight
      return @nodes[y * nodeWidth + x].getEdge(edge)
    end

    def setEdgeNode(x, y, edge)
      return if x < 0 || x >= nodeWidth || y < 0 || y >= nodeHeight
      @nodes[y * nodeWidth + x].setEdge(edge)
      e = 0
      nx = x
      ny = y
      case edge
      when EdgeMasks::North
        e = EdgeMasks::South
        ny = y - 1
      when EdgeMasks::South
        e = EdgeMasks::North
        ny = y + 1
      when EdgeMasks::East
        e = EdgeMasks::West
        nx = x + 1
      when EdgeMasks::West
        e = EdgeMasks::East
        nx = x - 1
      else
        return
      end
      return if nx < 0 || ny < 0 || nx >= nodeWidth || ny >= nodeHeight
      @nodes[ny * nodeWidth + nx].setEdge(e)
    end

    def setAllEdges
      for c in 0...nodeWidth * nodeHeight
        @nodes[c].set
      end
    end

    def clearEdgeNode(x, y, edge)
      return if x < 0 || x >= nodeWidth || y < 0 || y >= nodeHeight
      @nodes[y * nodeWidth + x].clearEdge(edge)
      e = 0
      nx = x
      ny = y
      case edge
      when EdgeMasks::North
        e = EdgeMasks::South
        ny -= 1
      when EdgeMasks::South
        e = EdgeMasks::North
        ny += 1
      when EdgeMasks::East
        e = EdgeMasks::West
        nx += 1
      when EdgeMasks::West
        e = EdgeMasks::East
        nx -= 1
      else
        raise ArgumentError.new
      end
      return if nx < 0 || ny < 0 || nx >= nodeWidth || ny >= nodeHeight
      @nodes[ny * nodeWidth + nx].clearEdge(e)
    end

    def clearAllEdges
      for c in 0...nodeWidth * nodeHeight
        @nodes[c].clear
      end
    end

    def isBlockedNode?(x, y)
      return false if x < 0 || y < 0 || x >= nodeWidth || y >= nodeHeight
      return @nodes[y * nodeWidth + x].isBlocked?
    end

    def getEdgePattern(x, y)
      pattern = 0
      pattern |= EdgeMasks::North if getEdgeNode(x, y, EdgeMasks::North)
      pattern |= EdgeMasks::South if getEdgeNode(x, y, EdgeMasks::South)
      pattern |= EdgeMasks::East if getEdgeNode(x, y, EdgeMasks::East)
      pattern |= EdgeMasks::West if getEdgeNode(x, y, EdgeMasks::West)
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
        when EdgeMasks::North
          wy -= 1
        when EdgeMasks::West
          wx -= 1
        when EdgeMasks::East
          wx += 1
        when EdgeMasks::South
          wy += 1
        end
        if isBlockedNode?(wx, wy)
          setEdgeNode(ox, oy, dir)
          return
        end
        setEdgeNode(ox,oy,dir)
      end
    end

    def buildNodeList
      list = []
      for x in 0...nodeWidth
        for y in 0...nodeHeight
          list.push(NodeListElement.new(x, y))
        end
      end
      list.shuffle!
      return list
    end

    def generateWallGrowthMaze(minWall = 0, maxWall = nil)
      maxWall = cellWidth if !maxWall
      nlist = buildNodeList()
      return if nlist.length == 0
      for c in 0...nlist.length
        d = randomDir()
        len = rand(maxWall + 1)
        x = nlist[c].x
        y = nlist[c].y
        buildMazeWall(x, y, d, len)
      end
    end

    def recurseDepthFirst(x, y, depth)
      setVisited(x, y)
      dirs = DIRECTIONS.shuffle
      for c in 0...4
        d = dirs[c]
        cx = x
        cy = y
        case d
        when EdgeMasks::North
          cy -= 1
        when EdgeMasks::South
          cy += 1
        when EdgeMasks::East
          cx += 1
        when EdgeMasks::West
          cx -= 1
        end
        if cx >= 0 && cy >= 0 && cx < cellWidth && cy < cellHeight
          if !getVisited(cx, cy)
            clearEdgeNode(x, y, d)
            recurseDepthFirst(cx, cy, depth + 1)
          end
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
      for i in 0...width * height
        @array[i] = DungeonTile::VOID
      end
    end

    def write
      ret = ""
      i = 0
      for y in 0...@height
        for x in 0...@width
          ret += DungeonTile.to_text(value(x, y))
          i += 1
        end
        ret += "\r\n"
      end
      return ret
    end

    def [](x, y)
      return @array[y * @width + x]
    end

    def []=(x, y, value)
      @array[y * @width + x] = value
    end

    def value(x, y)
      return DungeonTile::VOID if x < 0 || y < 0 || x >= @width || y >= @height
      return @array[y * @width + x]
    end

    # Unused
    def get(x, y)
      return false if x < 0 || y < 0 || x >= @width || y >= @height
      return @array[y * @width + x] != DungeonTile::VOID
    end

    # Unused
    def intersects?(r1, r2)
    	return !(((r2[0] + r2[2] <= r1[0]) ||
  	   	 (r2[0] >= r1[0] + r1[2]) ||
  		   (r2[1] + r2[3] <= r1[1]) ||
  		   (r2[1] >= r1[1] + r1[3])) &&
  		   ((r1[0] <= r2[0] + r2[2])||
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
        return true if v1 == DungeonTile::ROOM || v1 == DungeonTile::CORRIDOR
        if v1 == DungeonTile::VOID   # The tile below is void
          v1 = value(x, y + 2)
          return true if v1 == DungeonTile::ROOM || v1 == DungeonTile::CORRIDOR
        end
      end
      return false
    end

    def paint_room(rect,offsetX,offsetY)
      for y in (rect[1] + offsetY)...(rect[1] + offsetY + rect[3])
        for x in (rect[0] + offsetX)...(rect[0] + offsetX + rect[2])
          self[x, y] = DungeonTile::ROOM
        end
      end
    end

    def generate
      self.clear
      maxWidth = @width - BUFFER_X * 2
      maxHeight = @height - BUFFER_Y * 2
      cellWidth = DungeonMaze::CELL_WIDTH
      cellHeight = DungeonMaze::CELL_HEIGHT
      return if maxWidth < 0 || maxHeight < 0
      if maxWidth < cellWidth || maxHeight < cellHeight   # Map is too small
        for x in 0...maxWidth
          for y in 0...maxHeight
            self[x + BUFFER_X, y + BUFFER_Y] = DungeonTile::ROOM
          end
        end
        return
      end
      # Generate connections between cells
      maze = Maze.new(maxWidth / cellWidth, maxHeight / cellHeight)
      maze.generateDepthFirstMaze()
      # Draw each cell's contents in turn (room and corridors)
      corridor_patterns = DungeonMaze.generate_corridor_patterns
      roomcount = 0
      for y in 0...maxHeight / cellHeight
        for x in 0...maxWidth / cellWidth
          pattern = maze.getEdgePattern(x, y)
          if DungeonMaze.paint_cell_contents(
             self, BUFFER_X + x * cellWidth, BUFFER_Y + y * cellHeight,
             corridor_patterns[pattern], DungeonMaze::None)
            roomcount += 1
          end
        end
      end
      # If no rooms were generated, make the whole map a room
      if roomcount == 0
        for x in 0...maxWidth
          for y in 0...maxHeight
            self[x + BUFFER_X, y + BUFFER_Y] = DungeonTile::ROOM
          end
        end
      end
      # Generate walls
      for y in 0...@height
        for x in 0...@width
          self[x, y] = DungeonTile::WALL if isWall?(x, y)   # Make appropriate tiles wall tiles
        end
      end
    end

    # Convert dungeon layout into proper map tiles
    def generateMapInPlace(map)
      tbl = DungeonTable.new(self)
      for i in 0...map.width
        for j in 0...map.height
          nb = TileDrawingHelper.tableNeighbors(tbl, i, j)
          tile = TileDrawingHelper::NEIGHBORS_TO_AUTOTILE_INDEX[nb]
          map.data[i, j, 0] = tile + 48 * (tbl[i, j])
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
      x = ar1.get()
      y = ar2.get()
      if dungeon.isRoom?(x, y) &&
         !tiles.any? { |item| (item[0] - x).abs < 2 && (item[1] - y).abs < 2 }
        ret = [x, y]
        tiles.push(ret)
        return ret
      end
    end
    return nil
  end

  # Test method that generates a dungeon map and prints it to the console.
  # @param x_cells [Integer] the number of cells wide the dungeon will be
  # @param y_cells [Intenger] the number of cells tall the dungeon will be
  def self.generate_test_dungeon(x_cells = 4, y_cells = 4)
    dungeon = Dungeon.new(Dungeon::BUFFER_X * 2 + DungeonMaze::CELL_WIDTH * x_cells,
                          Dungeon::BUFFER_Y * 2 + DungeonMaze::CELL_HEIGHT * y_cells)
    dungeon.generate
    echoln dungeon.write
  end
end

Events.onMapCreate += proc { |_sender, e|
  mapID = e[0]
  map   = e[1]
  next if !GameData::MapMetadata.try_get(mapID)&.random_dungeon
  # this map is a randomly generated dungeon
  dungeon = RandomDungeonGenerator::Dungeon.new(map.width, map.height)
  dungeon.generate
  dungeon.generateMapInPlace(map)
  roomtiles = []
  # Reposition events
  for event in map.events.values
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
