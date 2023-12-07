#===============================================================================
# Code that generates a random dungeon layout, and implements it in a given map.
#===============================================================================
module RandomDungeon
  #=============================================================================
  # Bitwise values used to keep track of the generation of node connections.
  #=============================================================================
  module EdgeMasks
    NORTH = 1
    EAST  = 2
    SOUTH = 4
    WEST  = 8
  end

  #=============================================================================
  # A node in a randomly generated dungeon. There is one node per cell, and
  # nodes are connected to each other.
  #=============================================================================
  class MazeNode
    def initialize
      @visitable = false
      @visited   = false
      @room      = false
      block_all_edges   # A bit being 1 means its edge is NOT connected to the adjacent node
    end

    def edge_pattern;       return @edges;            end
    def block_edge(e);      @edges |= e;              end
    def connect_edge(e);    @edges &= ~e;             end
    def block_all_edges;    @edges = 15;              end
    def connect_all_edges;  @edges = 0;               end
    def edge_blocked?(e);   return (@edges & e) != 0; end
    def all_edges_blocked?; return @edges != 0;       end
    def visitable?;         return @visitable;        end
    def set_visitable;      @visitable = true;        end
    def visited?;           return @visited;          end
    def set_visited;        @visited = true;          end
    def room?;              return @room;             end
    def set_room;           @room = true;             end
  end

  #=============================================================================
  # Maze generator. Given the number of nodes horizontally and vertically in a
  # map, connects all the nodes together.
  #=============================================================================
  class Maze
    attr_accessor :node_count_x, :node_count_y

    DIRECTIONS = [EdgeMasks::NORTH, EdgeMasks::SOUTH, EdgeMasks::EAST, EdgeMasks::WEST]

    def initialize(cw, ch, parameters)
      raise ArgumentError.new if cw == 0 || ch == 0
      @node_count_x = cw
      @node_count_y = ch
      @parameters = parameters
      @nodes = Array.new(@node_count_x * @node_count_y) { MazeNode.new }
    end

    def valid_node?(x, y)
      return x >= 0 && x < @node_count_x && y >= 0 && y < @node_count_y
    end

    def get_node(x, y)
      return @nodes[(y * @node_count_x) + x] if valid_node?(x, y)
      return nil
    end

    def node_visited?(x, y)
      return true if !valid_node?(x, y) || !@nodes[(y * @node_count_x) + x].visitable?
      return @nodes[(y * @node_count_x) + x].visited?
    end

    def set_node_visited(x, y)
      @nodes[(y * @node_count_x) + x].set_visited if valid_node?(x, y)
    end

    def node_edge_blocked?(x, y, edge)
      return false if !valid_node?(x, y)
      return @nodes[(y * @node_count_x) + x].edge_blocked?(edge)
    end

    def connect_node_edges(x, y, edge)
      return if !valid_node?(x, y)
      @nodes[(y * @node_count_x) + x].connect_edge(edge)
      new_x, new_y, new_edge = get_coords_in_direction(x, y, edge, true)
      raise ArgumentError.new if new_edge == 0
      @nodes[(new_y * @node_count_x) + new_x].connect_edge(new_edge) if valid_node?(new_x, new_y)
    end

    def room_count
      ret = 0
      @nodes.each { |node| ret += 1 if node.room? }
      return ret
    end

    def get_coords_in_direction(x, y, dir, include_direction = false)
      new_x = x
      new_y = y
      new_dir = 0
      case dir
      when EdgeMasks::NORTH
        new_dir = EdgeMasks::SOUTH
        new_y -= 1
      when EdgeMasks::SOUTH
        new_dir = EdgeMasks::NORTH
        new_y += 1
      when EdgeMasks::WEST
        new_dir = EdgeMasks::EAST
        new_x -= 1
      when EdgeMasks::EAST
        new_dir = EdgeMasks::WEST
        new_x += 1
      end
      return new_x, new_y, new_dir if include_direction
      return new_x, new_y
    end

    #===========================================================================

    def generate_layout
      # Set visitable nodes
      visitable_nodes = set_visitable_nodes
      # Generate connections between all nodes
      generate_depth_first_maze(visitable_nodes)
      add_more_connections
      # Spawn rooms in some nodes
      spawn_rooms(visitable_nodes)
    end

    # Returns whether the node at (x, y) is active in the given layout.
    def check_active_node(x, y, layout)
      case layout
      when :no_corners
        return false if [0, @node_count_x - 1].include?(x) && [0, @node_count_y - 1].include?(y)
      when :ring
        return false if x > 0 && x < @node_count_x - 1 && y > 0 && y < @node_count_y - 1
      when :antiring
        return false if x == 0 || x == @node_count_x - 1 || y == 0 || y == @node_count_y - 1
      when :plus
        return false if x != @node_count_x / 2 && y != @node_count_y / 2
      when :diagonal_up
        return false if (x + y - @node_count_y + 1).abs >= 2
      when :diagonal_down
        return false if (x - y).abs >= 2
      when :cross
        return false if (x - y).abs >= 2 && (x + y - @node_count_y + 1).abs >= 2
      when :quadrants
        return false if (x == 0 || x == @node_count_x - 1) && y >= 2 && y < @node_count_y - 2
        return false if (y == 0 || y == @node_count_y - 1) && x >= 2 && x < @node_count_x - 2
      end
      return true
    end

    def set_visitable_nodes
      visitable_nodes = []
      @node_count_y.times do |y|
        @node_count_x.times do |x|
          next if !check_active_node(x, y, @parameters.node_layout)
          @nodes[(y * @node_count_x) + x].set_visitable
          visitable_nodes.push([x, y])
        end
      end
      return visitable_nodes
    end

    def generate_depth_first_maze(visitable_nodes)
      # Pick a cell to start in
      start = visitable_nodes.sample
      sx = start[0]
      sy = start[1]
      # Generate a maze
      connect_nodes_and_recurse_depth_first(sx, sy, 0)
    end

    def connect_nodes_and_recurse_depth_first(x, y, depth)
      set_node_visited(x, y)
      dirs = DIRECTIONS.shuffle
      4.times do |c|
        dir = dirs[c]
        cx, cy = get_coords_in_direction(x, y, dir)
        next if node_visited?(cx, cy)
        connect_node_edges(x, y, dir)
        connect_nodes_and_recurse_depth_first(cx, cy, depth + 1)
      end
    end

    def add_more_connections
      return if @parameters.extra_connections_count == 0
      possible_conns = []
      @node_count_x.times do |x|
        @node_count_y.times do |y|
          node = @nodes[(y * @node_count_x) + x]
          next if !node.visitable?
          DIRECTIONS.each do |dir|
            next if !node.edge_blocked?(dir)
            cx, cy, cdir = get_coords_in_direction(x, y, dir, true)
            new_node = get_node(cx, cy)
            next if !new_node || !new_node.visitable? || !new_node.edge_blocked?(cdir)
            possible_conns.push([x, y, dir])
          end
        end
      end
      possible_conns.sample(@parameters.extra_connections_count).each do |conn|
        connect_node_edges(*conn)
      end
    end

    def spawn_rooms(visitable_nodes)
      roomable_nodes = []
      visitable_nodes.each { |coord| roomable_nodes.push(coord) if check_active_node(*coord, @parameters.room_layout) }
      room_count = [roomable_nodes.length * @parameters.room_chance / 100, 1].max
      return if room_count == 0
      rooms = roomable_nodes.sample(room_count)
      rooms.each { |coords| @nodes[(coords[1] * @node_count_x) + coords[0]].set_room }
    end
  end

  #=============================================================================
  # Arrays of tile types in the dungeon map.
  #=============================================================================
  class DungeonLayout
    attr_accessor :width, :height
    alias xsize width
    alias ysize height

    # Used for debugging when printing out an ASCII image of the dungeon
    TEXT_SYMBOLS = {
      :void                   => "#",
      :room                   => " ",
      :corridor               => " ",
      :void_decoration        => "#",
      :void_decoration_large  => "#",
      :floor_decoration       => " ",
      :floor_decoration_large => " ",
      :floor_patch            => " ",
      :wall_top               => " ",
      :wall_1                 => Console.markup_style("=", bg: :brown),
      :wall_2                 => Console.markup_style("=", bg: :brown),
      :wall_3                 => Console.markup_style("=", bg: :brown),
      :wall_4                 => Console.markup_style("=", bg: :brown),
      :wall_6                 => Console.markup_style("=", bg: :brown),
      :wall_7                 => Console.markup_style("=", bg: :brown),
      :wall_8                 => Console.markup_style("=", bg: :brown),
      :wall_9                 => Console.markup_style("=", bg: :brown),
      :wall_in_1              => Console.markup_style("=", bg: :brown),
      :wall_in_3              => Console.markup_style("=", bg: :brown),
      :wall_in_7              => Console.markup_style("=", bg: :brown),
      :wall_in_9              => Console.markup_style("=", bg: :brown),
      :upper_wall_1           => Console.markup_style("~", bg: :gray),
      :upper_wall_2           => Console.markup_style("~", bg: :gray),
      :upper_wall_3           => Console.markup_style("~", bg: :gray),
      :upper_wall_4           => Console.markup_style("~", bg: :gray),
      :upper_wall_6           => Console.markup_style("~", bg: :gray),
      :upper_wall_7           => Console.markup_style("~", bg: :gray),
      :upper_wall_8           => Console.markup_style("~", bg: :gray),
      :upper_wall_9           => Console.markup_style("~", bg: :gray),
      :upper_wall_in_1        => Console.markup_style("~", bg: :gray),
      :upper_wall_in_3        => Console.markup_style("~", bg: :gray),
      :upper_wall_in_7        => Console.markup_style("~", bg: :gray),
      :upper_wall_in_9        => Console.markup_style("~", bg: :gray)
    }

    def initialize(width, height)
      @width  = width
      @height = height
      @array  = [[], [], []]
      clear
    end

    def [](x, y, layer)
      return @array[layer][(y * @width) + x]
    end

    def []=(x, y, layer, value)
      @array[layer][(y * @width) + x] = value
    end

    def value(x, y)
      return :void if x < 0 || x >= @width || y < 0 || y >= @height
      ret = :void
      [2, 1, 0].each do |layer|
        return @array[layer][(y * @width) + x] if @array[layer][(y * @width) + x] != :none
      end
      return ret
    end

    def clear
      @array.each_with_index do |arr, layer|
        (@width * @height).times { |i| arr[i] = (layer == 0) ? :void : :none }
      end
    end

    def set_wall(x, y, value)
      @array[0][(y * @width) + x] = :room
      @array[1][(y * @width) + x] = value
    end

    def set_ground(x, y, value)
      @array[0][(y * @width) + x] = value
      @array[1][(y * @width) + x] = :none
    end

    def write
      ret = ""
      @height.times do |y|
        @width.times do |x|
          ret += TEXT_SYMBOLS[value(x, y)] || "\e[30m\e[41m?\e[0m"
        end
        ret += "\n"
      end
      return ret
    end
  end

  #=============================================================================
  # The main dungeon generator class.
  #=============================================================================
  class Dungeon
    attr_accessor :width, :height
    alias xsize width
    alias ysize height
    attr_accessor :parameters, :rng_seed
    attr_accessor :tileset

    # 0 is none (index 0 only) or corridor/floor
    # -1 are tile combinations that need special attention
    # Other numbers correspond to tile types (see def get_wall_tile_for_coord)
    FLOOR_NEIGHBOURS_TO_WALL = [
      0, 2, 1, 2, 4, 11, 4, 11, 7, 9, 4, 11, 4, 11, 4, 11,
      8, 0, 17, 0, 17, 0, 17, 0, 8, 0, 17, 0, 17, 0, 17, 0,
      9, 13, -1, 13, 17, 0, 17, 0, 8, 0, 17, 0, 17, 0, 17, 0,
      8, 0, 17, 0, 17, 0, 17, 0, 8, 0, 17, 0, 17, 0, 17, 0,
      6, 13, 13, 13, 0, 0, 0, 0, 19, 0, 0, 0, 0, 0, 0, 0,
      19, 0, 0, 0, 0, 0, 0, 0, 19, 0, 0, 0, 0, 0, 0, 0,
      6, 13, 13, 13, 0, 0, 0, 0, 19, 0, 0, 0, 0, 0, 0, 0,
      19, 0, 0, 0, 0, 0, 0, 0, 19, 0, 0, 0, 0, 0, 0, 0,
      3, 2, 2, 2, 11, 11, 11, 11, -1, 11, 11, 11, 11, 11, 11, 11,
      19, 0, 0, 0, 0, 0, 0, 0, 19, 0, 0, 0, 0, 0, 0, 0,
      6, 13, 13, 13, 0, 0, 0, 0, 19, 0, 0, 0, 0, 0, 0, 0,
      19, 0, 0, 0, 0, 0, 0, 0, 19, 0, 0, 0, 0, 0, 0, 0,
      6, 13, 13, 13, 0, 0, 0, 0, 19, 0, 0, 0, 0, 0, 0, 0,
      19, 0, 0, 0, 0, 0, 0, 0, 19, 0, 0, 0, 0, 0, 0, 0,
      6, 13, 13, 13, 0, 0, 0, 0, 19, 0, 0, 0, 0, 0, 0, 0,
      19, 0, 0, 0, 0, 0, 0, 0, 19, 0, 0, 0, 0, 0, 0, 0
    ]

    def initialize(width, height, tileset, parameters = nil)
      @tileset     = tileset
      @buffer_x    = ((Graphics.width.to_f / Game_Map::TILE_WIDTH) / 2).ceil
      @buffer_y    = ((Graphics.height.to_f / Game_Map::TILE_HEIGHT) / 2).ceil
      if @tileset.snap_to_large_grid
        @buffer_x += 1 if @buffer_x.odd?
        @buffer_y += 1 if @buffer_x.odd?
      end
      @parameters = parameters || GameData::DungeonParameters.new({})
      if @tileset.snap_to_large_grid
        @parameters.cell_width -= 1 if @parameters.cell_width.odd?
        @parameters.cell_height -= 1 if @parameters.cell_height.odd?
        @parameters.corridor_width += (@parameters.corridor_width == 1) ? 1 : -1 if @parameters.corridor_width.odd?
      end
      if width >= 20
        @width = width
      else
        @width = (width * @parameters.cell_width) + (2 * @buffer_x)
        @width += 1 if @tileset.snap_to_large_grid && @width.odd?
      end
      if height >= 20
        @height = height
      else
        @height = (height * @parameters.cell_height) + (2 * @buffer_y)
        @height += 1 if @tileset.snap_to_large_grid && @height.odd?
      end
      @usable_width = @width
      @usable_height = @height
      if @tileset.snap_to_large_grid
        @usable_width  -= 1 if @usable_width.odd?
        @usable_height -= 1 if @usable_height.odd?
      end
      @room_rects = []
      @map_data    = DungeonLayout.new(@width, @height)
      @need_redraw = false
    end

    def [](x, y, layer = nil)
      return @map_data.value(x, y) if layer.nil?
      return @map_data[x, y, layer]
    end

    def []=(x, y, layer, value)
      @map_data[x, y, layer] = value
    end

    def write
      return @map_data.write
    end

    #===========================================================================

    # Returns whether the given coordinates are a room floor that isn't too
    # close to a corridor. For positioning events/the player upon entering.
    def isRoom?(x, y)
      return false if @map_data.value(x, y) != :room
      (-1..1).each do |i|
        (-1..1).each do |j|
          next if i == 0 && j == 0
          return false if @map_data.value(x + i, y + j) == :corridor
        end
      end
      return true   # No surrounding tiles are corridor floor
    end

    def tile_is_ground?(value)
      return [:room, :corridor].include?(value)
    end

    # Lower wall tiles only.
    def tile_is_wall?(value)
      return [:wall_1, :wall_2, :wall_3, :wall_4, :wall_6, :wall_7, :wall_8, :wall_9,
              :wall_in_1, :wall_in_3, :wall_in_7, :wall_in_9].include?(value)
    end

    def coord_is_ground?(x, y)
      return tile_is_ground?(@map_data[x, y, 0]) && !tile_is_wall?(@map_data[x, y, 1])
    end

    #===========================================================================

    def generate
      @rng_seed = @parameters.rng_seed || $PokemonGlobal.dungeon_rng_seed || Random.new_seed
      $PokemonGlobal.dungeon_rng_seed = nil
      Random.srand(@rng_seed)
      maxWidth = @usable_width - (@buffer_x * 2)
      maxHeight = @usable_height - (@buffer_y * 2)
      return if maxWidth < 0 || maxHeight < 0
      loop do
        @need_redraw = false
        @map_data.clear
        # Generate the basic layout of the map
        generate_layout(maxWidth, maxHeight)
        next if @need_redraw
        # Draw walls
        generate_walls(maxWidth, maxHeight)
        next if @need_redraw
        # Draw decorations
        paint_decorations(maxWidth, maxHeight)
        # Draw wall top tiles
        paint_wall_top_tiles(maxWidth, maxHeight)
        break   # if !@need_redraw
      end
    end

    def generate_layout(maxWidth, maxHeight)
      cellWidth = @parameters.cell_width
      cellHeight = @parameters.cell_height
      # Map is too small, make the whole map a room
      if maxWidth < cellWidth || maxHeight < cellHeight
        paint_ground_rect(@buffer_x, @buffer_y, maxWidth, maxHeight, :room)
        return
      end
      # Generate connections between cells
      maze = Maze.new(maxWidth / cellWidth, maxHeight / cellHeight, @parameters)
      maze.generate_layout
      # If no rooms were generated, make the whole map a room
      if maze.room_count == 0
        paint_ground_rect(@buffer_x, @buffer_y, maxWidth, maxHeight, :room)
        return
      end
      # Draw each cell's contents in turn (room and corridors)
      (maxHeight / cellHeight).times do |y|
        (maxWidth / cellWidth).times do |x|
          paint_node_contents(@buffer_x + (x * cellWidth), @buffer_y + (y * cellHeight), maze.get_node(x, y))
        end
      end
      check_for_isolated_rooms
    end

    def generate_walls(maxWidth, maxHeight)
      # Lower layer
      errors = []
      maxHeight.times do |y|
        maxWidth.times do |x|
          next if !coord_is_ground?(@buffer_x + x, @buffer_y + y)
          paint_walls_around_ground(@buffer_x + x, @buffer_y + y, 0, errors)
        end
      end
      # Check for error tiles
      errors.each do |coord|
        resolve_wall_error(coord[0], coord[1], 0)
        break if @need_redraw
      end
      return if @need_redraw
      return if !@tileset.double_walls
      # Upper layer
      errors = []
      (maxHeight + 2).times do |y|
        (maxWidth + 2).times do |x|
          next if !tile_is_wall?(@map_data[@buffer_x + x - 1, @buffer_y + y - 1, 1])
          paint_walls_around_ground(@buffer_x + x - 1, @buffer_y + y - 1, 1, errors)
        end
      end
      # Check for error tiles
      errors.each do |coord|
        resolve_wall_error(coord[0], coord[1], 1)
        break if @need_redraw
      end
    end

    #===========================================================================

    # Determines whether all floor tiles are contiguous. Sets @need_redraw if
    # there are 2+ floor regions that are isolated from each other.
    def check_for_isolated_rooms
      # Get a floor tile as a starting position
      start = nil
      maxWidth = @usable_width - (@buffer_x * 2)
      maxHeight = @usable_height - (@buffer_y * 2)
      maxHeight.times do |y|
        maxWidth.times do |x|
          next if !tile_is_ground?(@map_data[x + @buffer_x, y + @buffer_y, 0])
          start = [x, y]
          break
        end
        break if start
      end
      if !start
        @need_redraw = true
        return
      end
      # Flood fill (https://en.wikipedia.org/wiki/Flood_fill#Span_Filling)
      to_check = [
        [start[0], start[0], start[1], 1],
        [start[0], start[0], start[1] - 1, -1]
      ]
      visited = []
      loop do
        break if to_check.empty?
        checking = to_check.shift
        x1, x2, y, dy = checking
        x = x1
        if !visited[(y * maxWidth) + x] && tile_is_ground?(@map_data[x + @buffer_x, y + @buffer_y, 0])
          loop do
            break if visited[(y * maxWidth) + x - 1] || !tile_is_ground?(@map_data[x - 1 + @buffer_x, y + @buffer_y, 0])
            visited[(y * maxWidth) + x - 1] = true
            x -= 1
          end
        end
        to_check.push([x, x1 - 1, y - dy, -dy]) if x < x1
        loop do
          break if x1 > x2
          loop do
            break if visited[(y * maxWidth) + x1] || !tile_is_ground?(@map_data[x1 + @buffer_x, y + @buffer_y, 0])
            visited[(y * maxWidth) + x1] = true
            to_check.push([x, x1, y + dy, dy])
            to_check.push([x2 + 1, x1, y - dy, -dy]) if x1 > x2
            x1 += 1
          end
          x1 += 1
          loop do
            break if x1 >= x2
            break if !visited[(y * maxWidth) + x1] && tile_is_ground?(@map_data[x1 + @buffer_x, y + @buffer_y, 0])
            x1 += 1
          end
          x = x1
        end
      end
      # Check for unflooded floor tiles
      maxHeight.times do |y|
        maxWidth.times do |x|
          next if visited[(y * maxWidth) + x] || !tile_is_ground?(@map_data[x + @buffer_x, y + @buffer_y, 0])
          @need_redraw = true
          break
        end
        break if @need_redraw
      end
    end

    # Fixes (most) situations where it isn't immediately obvious how to draw a
    # wall around a floor area.
    def resolve_wall_error(x, y, layer = 0)
      if layer == 0
        is_neighbour = lambda { |til| return tile_is_ground?(til) }
      else
        is_neighbour = lambda { |til| return tile_is_wall?(til) }
      end
      tile = {
        :wall_1    => (layer == 0) ? :wall_1 : :upper_wall_1,
        :wall_2    => (layer == 0) ? :wall_2 : :upper_wall_2,
        :wall_3    => (layer == 0) ? :wall_3 : :upper_wall_3,
        :wall_4    => (layer == 0) ? :wall_4 : :upper_wall_4,
        :wall_6    => (layer == 0) ? :wall_6 : :upper_wall_6,
        :wall_7    => (layer == 0) ? :wall_7 : :upper_wall_7,
        :wall_8    => (layer == 0) ? :wall_8 : :upper_wall_8,
        :wall_9    => (layer == 0) ? :wall_9 : :upper_wall_9,
        :wall_in_1 => (layer == 0) ? :wall_in_1 : :upper_wall_in_1,
        :wall_in_3 => (layer == 0) ? :wall_in_3 : :upper_wall_in_3,
        :wall_in_7 => (layer == 0) ? :wall_in_7 : :upper_wall_in_7,
        :wall_in_9 => (layer == 0) ? :wall_in_9 : :upper_wall_in_9,
        :corridor  => (layer == 0) ? :corridor : :void
      }
      neighbours = 0
      neighbours |= 0x01 if is_neighbour.call(@map_data.value(x,     y - 1))   # N
      neighbours |= 0x02 if is_neighbour.call(@map_data.value(x + 1, y - 1))   # NE
      neighbours |= 0x04 if is_neighbour.call(@map_data.value(x + 1,     y))   # E
      neighbours |= 0x08 if is_neighbour.call(@map_data.value(x + 1, y + 1))   # SE
      neighbours |= 0x10 if is_neighbour.call(@map_data.value(x,     y + 1))   # S
      neighbours |= 0x20 if is_neighbour.call(@map_data.value(x - 1, y + 1))   # SW
      neighbours |= 0x40 if is_neighbour.call(@map_data.value(x - 1,     y))   # W
      neighbours |= 0x80 if is_neighbour.call(@map_data.value(x - 1, y - 1))   # NW
      case neighbours
      when 34
        # --f   floor tile (dashes are walls)
        # -o-   this tile
        # f--   floor tile
        if @map_data.value(x - 1, y - 1) == :void
          @map_data[x, y, 1] = tile[:wall_in_3]
          @map_data[x - 1, y, 1] = tile[:wall_in_7]
          @map_data[x, y - 1, 1] = tile[:wall_in_7]
          @map_data.set_wall(x - 1, y - 1, tile[:wall_7])
        elsif @map_data.value(x + 1, y + 1) == :void
          @map_data[x, y, 1] = tile[:wall_in_7]
          @map_data[x + 1, y, 1] = tile[:wall_in_3]
          @map_data[x, y + 1, 1] = tile[:wall_in_3]
          @map_data.set_wall(x + 1, y + 1, tile[:wall_3])
        elsif @map_data[x, y - 1, 1] == tile[:wall_4] && @map_data[x - 1, y, 1] == tile[:wall_in_9]
          @map_data[x, y, 1] = tile[:wall_in_3]
          @map_data[x, y - 1, 1] = tile[:wall_in_7]
          @map_data.set_ground(x - 1, y, tile[:corridor])
          @map_data[x - 1, y - 1, 1] = (@map_data[x - 1, y - 1, 1] == tile[:wall_6]) ? tile[:wall_in_9] : tile[:wall_8]
        elsif @map_data[x, y - 1, 1] == tile[:wall_in_1] && @map_data[x - 1, y, 1] == tile[:wall_8]
          @map_data[x, y, 1] = tile[:wall_in_3]
          @map_data.set_ground(x, y - 1, tile[:corridor])
          @map_data[x - 1, y, 1] = tile[:wall_in_7]
          @map_data[x - 1, y - 1, 1] = (@map_data[x - 1, y - 1, 1] == tile[:wall_2]) ? tile[:wall_in_1] : tile[:wall_4]
        elsif @map_data[x, y - 1, 1] == tile[:wall_in_1] && @map_data[x - 1, y, 1] == tile[:wall_in_9]
          @map_data[x, y, 1] = tile[:wall_in_3]
          @map_data.set_ground(x, y - 1, tile[:corridor])
          @map_data.set_ground(x - 1, y, tile[:corridor])
          if @map_data[x - 1, y - 1, 1] == :error
            @map_data[x - 1, y - 1, 1] = tile[:wall_in_7]
          else
            @map_data.set_ground(x - 1, y - 1, tile[:corridor])
          end
        elsif @map_data[x, y + 1, 1] == tile[:wall_6] && @map_data[x + 1, y, 1] == tile[:wall_in_1]
          @map_data[x, y, 1] = tile[:wall_in_7]
          @map_data[x, y + 1, 1] = tile[:wall_in_3]
          @map_data.set_ground(x + 1, y, tile[:corridor])
          @map_data[x + 1, y + 1, 1] = (@map_data[x + 1, y + 1, 1] == tile[:wall_4]) ? tile[:wall_in_1] : tile[:wall_2]
        elsif @map_data[x, y + 1, 1] == tile[:wall_in_9] && @map_data[x + 1, y, 1] == tile[:wall_2]
          @map_data[x, y, 1] = tile[:wall_in_7]
          @map_data.set_ground(x, y + 1, tile[:corridor])
          @map_data[x + 1, y, 1] = tile[:wall_in_3]
          @map_data[x + 1, y + 1, 1] = (@map_data[x + 1, y + 1, 1] == tile[:wall_8]) ? tile[:wall_in_9] : tile[:wall_6]
        elsif @map_data[x, y + 1, 1] == tile[:wall_in_9] && @map_data[x + 1, y, 1] == tile[:wall_in_1]
          @map_data[x, y, 1] = tile[:wall_in_7]
          @map_data.set_ground(x, y + 1, tile[:corridor])
          @map_data.set_ground(x + 1, y, tile[:corridor])
          if @map_data[x + 1, y + 1, 1] == :error
            @map_data[x + 1, y + 1, 1] = tile[:wall_in_3]
          else
            @map_data.set_ground(x + 1, y + 1, tile[:corridor])
          end
        else
          # Tile error can't be resolved; will redraw map
          @need_redraw = true
        end
      when 136
        # f--   floor tile (dashes are walls)
        # -o-   this tile
        # --f   floor tile
        if @map_data.value(x - 1, y + 1) == :void
          @map_data[x, y, 1] = tile[:wall_in_9]
          @map_data[x - 1, y, 1] = tile[:wall_in_1]
          @map_data[x, y + 1, 1] = tile[:wall_in_1]
          @map_data.set_wall(x - 1, y + 1, tile[:wall_1])
        elsif @map_data.value(x + 1, y - 1) == :void
          @map_data[x, y, 1] = tile[:wall_in_1]
          @map_data[x + 1, y, 1] = tile[:wall_in_9]
          @map_data[x, y - 1, 1] = tile[:wall_in_9]
          @map_data.set_wall(x + 1, y - 1, tile[:wall_9])
        elsif @map_data[x, y - 1, 1] == tile[:wall_6] && @map_data[x + 1, y, 1] == tile[:wall_in_7]
          @map_data[x, y, 1] = tile[:wall_in_1]
          @map_data[x, y - 1, 1] = tile[:wall_in_9]
          @map_data.set_ground(x + 1, y, tile[:corridor])
          @map_data[x + 1, y - 1, 1] = (@map_data[x + 1, y - 1, 1] == tile[:wall_4]) ? tile[:wall_in_7] : tile[:wall_8]
        elsif @map_data[x, y - 1, 1] == tile[:wall_in_3] && @map_data[x + 1, y, 1] == tile[:wall_8]
          @map_data[x, y, 1] = tile[:wall_in_1]
          @map_data.set_ground(x, y - 1, tile[:corridor])
          @map_data[x + 1, y, 1] = tile[:wall_in_9]
          @map_data[x + 1, y - 1, 1] = (@map_data[x + 1, y - 1, 1] == tile[:wall_2]) ? tile[:wall_in_3] : tile[:wall_6]
        elsif @map_data[x, y - 1, 1] == tile[:wall_in_3] && @map_data[x + 1, y, 1] == tile[:wall_in_7]
          @map_data[x, y, 1] = tile[:wall_in_1]
          @map_data.set_ground(x, y - 1, tile[:corridor])
          @map_data.set_ground(x + 1, y, tile[:corridor])
          if @map_data[x + 1, y - 1, 1] == :error
            @map_data[x + 1, y - 1, 1] = tile[:wall_in_9]
          else
            @map_data.set_ground(x + 1, y - 1, tile[:corridor])
          end
        elsif @map_data[x, y + 1, 1] == tile[:wall_4] && @map_data[x - 1, y, 1] == tile[:wall_in_3]
          @map_data[x, y, 1] = tile[:wall_in_9]
          @map_data[x, y + 1, 1] = tile[:wall_in_1]
          @map_data.set_ground(x - 1, y, tile[:corridor])
          @map_data[x - 1, y + 1, 1] = (@map_data[x - 1, y + 1, 1] == tile[:wall_6]) ? tile[:wall_in_3] : tile[:wall_2]
        elsif @map_data[x, y + 1, 1] == tile[:wall_in_7] && @map_data[x - 1, y, 1] == tile[:wall_2]
          @map_data[x, y, 1] = tile[:wall_in_9]
          @map_data.set_ground(x, y + 1, tile[:corridor])
          @map_data[x - 1, y, 1] = tile[:wall_in_1]
          @map_data[x - 1, y + 1, 1] = (@map_data[x - 1, y + 1, 1] == tile[:wall_8]) ? tile[:wall_in_7] : tile[:wall_4]
        elsif @map_data[x, y + 1, 1] == tile[:wall_in_7] && @map_data[x - 1, y, 1] == tile[:wall_in_3]
          @map_data[x, y, 1] = tile[:wall_in_9]
          @map_data.set_ground(x, y + 1, tile[:corridor])
          @map_data.set_ground(x - 1, y, tile[:corridor])
          if @map_data[x - 1, y + 1, 1] == :error
            @map_data[x - 1, y + 1, 1] = tile[:wall_in_1]
          else
            @map_data.set_ground(x - 1, y + 1, tile[:corridor])
          end
        else
          # Tile error can't be resolved; will redraw map
          @need_redraw = true
        end
      else
        @need_redraw = true
        raise "can't resolve error"
      end
    end

    #===========================================================================

    # Draws a cell's contents, which is an underlying pattern based on
    # tile_layout (the corridors), and possibly a room on top of that.
    def paint_node_contents(cell_x, cell_y, node)
      # Draw corridors connecting this room
      paint_connections(cell_x, cell_y, node.edge_pattern)
      # Generate a randomly placed room
      paint_room(cell_x, cell_y) if node.room?
    end

    def paint_ground_rect(x, y, width, height, tile)
      height.times do |j|
        width.times do |i|
          @map_data[x + i, y + j, 0] = tile
        end
      end
    end

    # Draws corridors leading from the node at (cell_x, cell_y).
    def paint_connections(cell_x, cell_y, pattern)
      x_offset = (@parameters.cell_width - @parameters.corridor_width) / 2
      y_offset = (@parameters.cell_height - @parameters.corridor_width) / 2
      if @parameters.random_corridor_shift
        variance = @parameters.corridor_width
        variance /= 2 if @tileset.snap_to_large_grid
        if variance > 1
          x_shift = rand(variance) - (variance / 2)
          y_shift = rand(variance) - (variance / 2)
          if @tileset.snap_to_large_grid
            x_shift *= 2
            y_shift *= 2
          end
          x_offset += x_shift
          y_offset += y_shift
        end
      end
      if @tileset.snap_to_large_grid
        x_offset += 1 if x_offset.odd?
        y_offset += 1 if y_offset.odd?
      end
      if (pattern & RandomDungeon::EdgeMasks::NORTH) == 0
        paint_ground_rect(cell_x + x_offset, cell_y,
                          @parameters.corridor_width, y_offset + @parameters.corridor_width,
                          :corridor)
      end
      if (pattern & RandomDungeon::EdgeMasks::SOUTH) == 0
        paint_ground_rect(cell_x + x_offset, cell_y + y_offset,
                          @parameters.corridor_width, @parameters.cell_height - y_offset,
                          :corridor)
      end
      if (pattern & RandomDungeon::EdgeMasks::EAST) == 0
        paint_ground_rect(cell_x + x_offset, cell_y + y_offset,
                          @parameters.cell_width - x_offset, @parameters.corridor_width,
                          :corridor)
      end
      if (pattern & RandomDungeon::EdgeMasks::WEST) == 0
        paint_ground_rect(cell_x, cell_y + y_offset,
                          x_offset + @parameters.corridor_width, @parameters.corridor_width,
                          :corridor)
      end
    end

    # Draws a room at (cell_x, cell_y).
    def paint_room(cell_x, cell_y)
      width, height = @parameters.rand_room_size
      return if width <= 0 || height <= 0
      if @tileset.snap_to_large_grid
        width += (width <= @parameters.cell_width / 2) ? 1 : -1 if width.odd?
        height += (height <= @parameters.cell_height / 2) ? 1 : -1 if height.odd?
      end
      center_x, center_y = @parameters.rand_cell_center
      x = cell_x + center_x - (width / 2)
      y = cell_y + center_y - (height / 2)
      if @tileset.snap_to_large_grid
        x += 1 if x.odd?
        y += 1 if y.odd?
      end
      x = x.clamp(@buffer_x, @usable_width - @buffer_x - width)
      y = y.clamp(@buffer_y, @usable_height - @buffer_y - height)
      @room_rects.push([x, y, width, height])
      paint_ground_rect(x, y, width, height, :room)
    end

    def paint_walls_around_ground(x, y, layer, errors)
      (-1..1).each do |j|
        (-1..1).each do |i|
          next if i == 0 && j == 0
          next if @map_data[x + i, y + j, 0] != :void
          tile = get_wall_tile_for_coord(x + i, y + j, layer)
          if [:void, :corridor].include?(tile)
            @map_data[x + i, y + j, 0] = tile
          else
            @map_data.set_wall(x + i, y + j, tile)
          end
          errors.push([x + i, y + j]) if tile == :error
        end
      end
    end

    def get_wall_tile_for_coord(x, y, layer = 0)
      if layer == 0
        is_neighbour = lambda { |x2, y2| return tile_is_ground?(@map_data.value(x2, y2)) }
      else
        is_neighbour = lambda { |x2, y2| return tile_is_wall?(@map_data[x2, y2, 1]) }
      end
      neighbours = 0
      neighbours |= 0x01 if is_neighbour.call(x,     y - 1)   # N
      neighbours |= 0x02 if is_neighbour.call(x + 1, y - 1)   # NE
      neighbours |= 0x04 if is_neighbour.call(x + 1,     y)   # E
      neighbours |= 0x08 if is_neighbour.call(x + 1, y + 1)   # SE
      neighbours |= 0x10 if is_neighbour.call(x,     y + 1)   # S
      neighbours |= 0x20 if is_neighbour.call(x - 1, y + 1)   # SW
      neighbours |= 0x40 if is_neighbour.call(x - 1,     y)   # W
      neighbours |= 0x80 if is_neighbour.call(x - 1, y - 1)   # NW
      case FLOOR_NEIGHBOURS_TO_WALL[neighbours]
      when -1 then return :error   # Needs special attention
      when 1  then return (layer == 0) ? :wall_1 : :upper_wall_1
      when 2  then return (layer == 0) ? :wall_2 : :upper_wall_2
      when 3  then return (layer == 0) ? :wall_3 : :upper_wall_3
      when 4  then return (layer == 0) ? :wall_4 : :upper_wall_4
      when 6  then return (layer == 0) ? :wall_6 : :upper_wall_6
      when 7  then return (layer == 0) ? :wall_7 : :upper_wall_7
      when 8  then return (layer == 0) ? :wall_8 : :upper_wall_8
      when 9  then return (layer == 0) ? :wall_9 : :upper_wall_9
      when 11 then return (layer == 0) ? :wall_in_1 : :upper_wall_in_1
      when 13 then return (layer == 0) ? :wall_in_3 : :upper_wall_in_3
      when 17 then return (layer == 0) ? :wall_in_7 : :upper_wall_in_7
      when 19 then return (layer == 0) ? :wall_in_9 : :upper_wall_in_9
      end
      return :void if neighbours == 0 || layer == 1
      return :corridor
    end

    def paint_decorations(maxWidth, maxHeight)
      # Large patches (grass/sandy area)
      if @tileset.has_decoration?(:floor_patch)
        (maxHeight / @parameters.cell_height).times do |j|
          (maxWidth / @parameters.cell_width).times do |i|
            next if rand(100) >= @parameters.floor_patch_chance
            # Random placing of floor patch tiles
            mid_x = (i * @parameters.cell_width) + rand(@parameters.cell_width)
            mid_y = (j * @parameters.cell_height) + rand(@parameters.cell_height)
            ((mid_y - @parameters.floor_patch_radius)..(mid_y + @parameters.floor_patch_radius)).each do |y|
              ((mid_x - @parameters.floor_patch_radius)..(mid_x + @parameters.floor_patch_radius)).each do |x|
                if @tileset.floor_patch_under_walls
                  next if !tile_is_ground?(@map_data[x + @buffer_x, y + @buffer_y, 0])
                else
                  next if !tile_is_ground?(@map_data.value(x + @buffer_x, y + @buffer_y))
                end
                if (((mid_x - 1)..(mid_x + 1)).include?(x) && ((mid_y - 1)..(mid_y + 1)).include?(y)) ||
                   rand(100) < @parameters.floor_patch_chance
                  @map_data[x + @buffer_x, y + @buffer_y, 0] = :floor_patch
                end
              end
            end
            # Smoothing of placed floor patch tiles
            ((mid_y - @parameters.floor_patch_radius)..(mid_y + @parameters.floor_patch_radius)).each do |y|
              ((mid_x - @parameters.floor_patch_radius)..(mid_x + @parameters.floor_patch_radius)).each do |x|
                if @map_data[x + @buffer_x, y + @buffer_y, 0] == :floor_patch
                  adj_count = 0
                  adj_count += 1 if @map_data[x + @buffer_x - 1, y + @buffer_y, 0] == :floor_patch
                  adj_count += 1 if @map_data[x + @buffer_x, y + @buffer_y - 1, 0] == :floor_patch
                  adj_count += 1 if @map_data[x + @buffer_x + 1, y + @buffer_y, 0] == :floor_patch
                  adj_count += 1 if @map_data[x + @buffer_x, y + @buffer_y + 1, 0] == :floor_patch
                  if adj_count == 0 || (adj_count == 1 && rand(100) < @parameters.floor_patch_smooth_rate * 2)
                    @map_data[x + @buffer_x, y + @buffer_y, 0] = :corridor
                  end
                else
                  if @tileset.floor_patch_under_walls
                    next if !tile_is_ground?(@map_data[x + @buffer_x, y + @buffer_y, 0])
                  else
                    next if !tile_is_ground?(@map_data.value(x + @buffer_x, y + @buffer_y))
                  end
                  adj_count = 0
                  adj_count += 1 if @map_data[x + @buffer_x - 1, y + @buffer_y, 0] == :floor_patch
                  adj_count += 1 if @map_data[x + @buffer_x, y + @buffer_y - 1, 0] == :floor_patch
                  adj_count += 1 if @map_data[x + @buffer_x + 1, y + @buffer_y, 0] == :floor_patch
                  adj_count += 1 if @map_data[x + @buffer_x, y + @buffer_y + 1, 0] == :floor_patch
                  if adj_count >= 2 && rand(100) < adj_count * @parameters.floor_patch_smooth_rate
                    @map_data[x + @buffer_x, y + @buffer_y, 0] = :floor_patch
                  end
                end
              end
            end
          end
        end
      end
      # 2x2 floor decoration (crater)
      if @tileset.has_decoration?(:floor_decoration_large)
        ((maxWidth * maxHeight) / @parameters.floor_decoration_large_density).times do
          x = rand(maxWidth)
          y = rand(maxHeight)
          next if @map_data.value(x + @buffer_x, y + @buffer_y) != :room ||
                  @map_data.value(x + @buffer_x + 1, y + @buffer_y) != :room ||
                  @map_data.value(x + @buffer_x, y + @buffer_y + 1) != :room ||
                  @map_data.value(x + @buffer_x + 1, y + @buffer_y + 1) != :room
          4.times do |c|
            cx = x + @buffer_x + (c % 2)
            cy = y + @buffer_y + (c / 2)
            @map_data[cx, cy, 0] = (c == 0) ? :floor_decoration_large : :ignore
          end
        end
      end
      # 1x1 floor decoration
      if @tileset.has_decoration?(:floor_decoration)
        ((@usable_width * @usable_height) / @parameters.floor_decoration_density).times do
          x = rand(@usable_width)
          y = rand(@usable_height)
          next if !coord_is_ground?(@buffer_x + x, @buffer_y + y)
          @map_data[x + @buffer_x, y + @buffer_y, 0] = :floor_decoration
        end
      end
      # 2x2 void decoration (crevice)
      if @tileset.has_decoration?(:void_decoration_large)
        ((@width * @height) / @parameters.void_decoration_large_density).times do
          x = rand(@width - 1)
          y = rand(@height - 1)
          next if @map_data.value(x, y) != :void ||
                  @map_data.value(x + 1, y) != :void ||
                  @map_data.value(x, y + 1) != :void ||
                  @map_data.value(x + 1, y + 1) != :void
          4.times do |c|
            cx = x + (c % 2)
            cy = y + (c / 2)
            @map_data[cx, cy, 0] = (c == 0) ? :void_decoration_large : :ignore
          end
        end
      end
      # 1x1 void decoration (rock)
      if @tileset.has_decoration?(:void_decoration)
        ((@width * @height) / @parameters.void_decoration_density).times do
          x = rand(@width)
          y = rand(@height)
          next if @map_data.value(x, y) != :void
          @map_data[x, y, 0] = :void_decoration
        end
      end
    end

    def paint_wall_top_tiles(maxWidth, maxHeight)
      return if !@tileset.has_decoration?(:wall_top)
      maxWidth.times do |x|
        maxHeight.times do |y|
          next if ![:wall_2, :wall_in_1, :wall_in_3].include?(@map_data[x + @buffer_x, y + 1 + @buffer_y, 1])
          @map_data[x + @buffer_x, y + @buffer_y, 2] = :wall_top
        end
      end
    end

    #===========================================================================

    # Convert dungeon layout into proper map tiles from a tileset, and modifies
    # the given map's data accordingly.
    def generateMapInPlace(map)
      map.width.times do |i|
        map.height.times do |j|
          3.times do |layer|
            tile_type = @map_data[i, j, layer]
            tile_type = :floor if [:room, :corridor].include?(tile_type)
            case tile_type
            when :ignore
            when :none
              map.data[i, j, layer] = 0
            when :void_decoration_large, :floor_decoration_large
              4.times do |c|
                tile = @tileset.get_random_tile_of_type(tile_type, self, i, j, layer)
                tile += (c % 2) + (8 * (c / 2)) if tile >= 384   # Regular tile
                map.data[i + (c % 2), j + (c / 2), layer] = tile
              end
            else
              tile = @tileset.get_random_tile_of_type(tile_type, self, i, j, layer)
              map.data[i, j, layer] = tile
            end
          end
        end
      end
    end

    # Returns a random room tile a random room where an event of the given size
    # can be placed. Events cannot be placed adjacent to or overlapping each
    # other, and can't be placed right next to the wall of a room (to prevent
    # them blocking a corridor).
    def get_random_room_tile(occupied_tiles, event_width = 1, event_height = 1)
      valid_rooms = @room_rects.clone
      valid_rooms.delete_if { |rect| rect[2] <= event_width + 1 || rect[3] <= event_height + 1 }
      return nil if valid_rooms.empty?
      1000.times do
        room = valid_rooms.sample
        x = 1 + rand(room[2] - event_width - 1)
        y = 1 + rand(room[3] - event_height - 1)
        valid_placement = true
        event_width.times do |i|
          event_height.times do |j|
            if occupied_tiles.any? { |item| (item[0] - (room[0] + x + i)).abs < 2 && (item[1] - (room[1] + y + j)).abs < 2 }
              valid_placement = false
            end
            break if !valid_placement
          end
          break if !valid_placement
        end
        next if !valid_placement
        # Found valid placement; use it
        event_width.times do |i|
          event_height.times do |j|
            occupied_tiles.push([room[0] + x + i, room[1] + y + j])
          end
        end
        return [room[0] + x, room[1] + y + event_height - 1]
      end
      return nil
    end
  end
end

#===============================================================================
# Variables that determine which dungeon parameters to use to generate a random
# dungeon.
#===============================================================================
class PokemonGlobalMetadata
  attr_writer   :dungeon_area, :dungeon_version
  attr_accessor :dungeon_rng_seed

  def dungeon_area
    return @dungeon_area || :none
  end

  def dungeon_version
    return @dungeon_version || 0
  end
end

#===============================================================================
# Code that generates a random dungeon layout, and implements it in a given map.
#===============================================================================
EventHandlers.add(:on_game_map_setup, :random_dungeon,
  proc { |map_id, map, _tileset_data|
    next if !GameData::MapMetadata.try_get(map_id)&.random_dungeon
    # Generate a random dungeon
    tileset_data = GameData::DungeonTileset.try_get(map.tileset_id)
    params = GameData::DungeonParameters.try_get($PokemonGlobal.dungeon_area,
                                                 $PokemonGlobal.dungeon_version)
    dungeon = RandomDungeon::Dungeon.new(params.cell_count_x, params.cell_count_y,
                                         tileset_data, params)
    dungeon.generate
    map.width = dungeon.width
    map.height = dungeon.height
    map.data.resize(map.width, map.height, 3)
    dungeon.generateMapInPlace(map)
    failed = false
    100.times do |i|
      failed = false
      occupied_tiles = []
      # Reposition events
      map.events.each_value do |event|
        event_width = 1
        event_height = 1
        if event.name[/size\((\d+),(\d+)\)/i]
          event_width = $~[1].to_i
          event_height = $~[2].to_i
        end
        tile = dungeon.get_random_room_tile(occupied_tiles, event_width, event_height)
        failed = true if !tile
        break if failed
        event.x = tile[0]
        event.y = tile[1]
      end
      next if failed
      # Reposition the player
      tile = dungeon.get_random_room_tile(occupied_tiles)
      next if !tile
      $game_temp.player_new_x = tile[0]
      $game_temp.player_new_y = tile[1]
      break
    end
    if failed
      raise _INTL("Couldn't place all events and the player in rooms.")
    end
  }
)
