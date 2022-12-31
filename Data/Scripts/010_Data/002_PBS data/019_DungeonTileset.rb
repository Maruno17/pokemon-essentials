module GameData
  class DungeonTileset
    attr_reader :id
    attr_reader :tile_type_ids
    attr_reader :snap_to_large_grid   # "large" means 2x2 tiles
    attr_reader :large_void_tiles     # "large" means 2x2 tiles
    attr_reader :large_wall_tiles     # "large" means 1x2 or 2x1 tiles depending on side
    attr_reader :large_floor_tiles    # "large" means 2x2 tiles
    attr_reader :double_walls
    attr_reader :floor_patch_under_walls
    attr_reader :thin_north_wall_offset
    attr_reader :flags
    attr_reader :pbs_file_suffix

    DATA = {}
    DATA_FILENAME = "dungeon_tilesets.dat"
    PBS_BASE_FILENAME = "dungeon_tilesets"

    SCHEMA = {
      "SectionName"          => [:id,                      "u"],
      "Autotile"             => [:autotile,                "^um"],
      "Tile"                 => [:tile,                    "^um"],
      "SnapToLargeGrid"      => [:snap_to_large_grid,      "b"],
      "LargeVoidTiles"       => [:large_void_tiles,        "b"],
      "LargeWallTiles"       => [:large_wall_tiles,        "b"],
      "LargeFloorTiles"      => [:large_floor_tiles,       "b"],
      "DoubleWalls"          => [:double_walls,            "b"],
      "FloorPatchUnderWalls" => [:floor_patch_under_walls, "b"],
      "ThinNorthWallOffset"  => [:thin_north_wall_offset,  "i"],
      "Flags"                => [:flags,                   "*s"]
    }

    extend ClassMethodsIDNumbers
    include InstanceMethods

    # @param other [self, Integer]
    # @return [self]
    def self.try_get(other)
      validate other => [Integer, self]
      return other if other.is_a?(self)
      return (self::DATA.has_key?(other)) ? self::DATA[other] : self.get(self::DATA.keys.first)
    end

    def initialize(hash)
      @id                      = hash[:id]
      @snap_to_large_grid      = hash[:snap_to_large_grid]      || false
      @large_void_tiles        = hash[:large_void_tiles]        || false
      @large_wall_tiles        = hash[:large_wall_tiles]        || false
      @large_floor_tiles       = hash[:large_floor_tiles]       || false
      @double_walls            = hash[:double_walls]            || false
      @floor_patch_under_walls = hash[:floor_patch_under_walls] || false
      @thin_north_wall_offset  = hash[:thin_north_wall_offset]  || 0
      @flags                   = hash[:flags]                   || []
      @tile_type_ids           = {}
      set_tile_type_ids(hash)
      @pbs_file_suffix         = hash[:pbs_file_suffix]         || ""
    end

    def set_tile_type_ids(hash)
      [hash[:autotile], hash[:tile]].each_with_index do |array, i|
        array.each do |tile_info|
          next if !tile_info
          tile_type = tile_info[1]
          if tile_type == :walls
            if @double_walls
              if @large_wall_tiles
                push_tile(:wall_1, 384 + tile_info[0] + 33)
                push_tile(:wall_2, 384 + tile_info[0] + 34)
                push_tile(:wall_3, 384 + tile_info[0] + 36)
                push_tile(:wall_4, 384 + tile_info[0] + 17)
                push_tile(:wall_6, 384 + tile_info[0] + 20)
                push_tile(:wall_7, 384 + tile_info[0] + 9)
                push_tile(:wall_8, 384 + tile_info[0] + 10)
                push_tile(:wall_9, 384 + tile_info[0] + 12)
                push_tile(:wall_in_1, 384 + tile_info[0] + 23)
                push_tile(:wall_in_3, 384 + tile_info[0] + 22)
                push_tile(:wall_in_7, 384 + tile_info[0] + 31)
                push_tile(:wall_in_9, 384 + tile_info[0] + 30)
                push_tile(:upper_wall_1, 384 + tile_info[0] + 40)
                push_tile(:upper_wall_2, 384 + tile_info[0] + 42)
                push_tile(:upper_wall_3, 384 + tile_info[0] + 45)
                push_tile(:upper_wall_4, 384 + tile_info[0] + 16)
                push_tile(:upper_wall_6, 384 + tile_info[0] + 21)
                push_tile(:upper_wall_7, 384 + tile_info[0] + 0)
                push_tile(:upper_wall_8, 384 + tile_info[0] + 2)
                push_tile(:upper_wall_9, 384 + tile_info[0] + 5)
                push_tile(:upper_wall_in_1, 384 + tile_info[0] + 7)
                push_tile(:upper_wall_in_3, 384 + tile_info[0] + 6)
                push_tile(:upper_wall_in_7, 384 + tile_info[0] + 15)
                push_tile(:upper_wall_in_9, 384 + tile_info[0] + 14)
              else
                push_tile(:wall_1, 384 + tile_info[0] + 25)
                push_tile(:wall_2, 384 + tile_info[0] + 26)
                push_tile(:wall_3, 384 + tile_info[0] + 27)
                push_tile(:wall_4, 384 + tile_info[0] + 17)
                push_tile(:wall_6, 384 + tile_info[0] + 19)
                push_tile(:wall_7, 384 + tile_info[0] + 9)
                push_tile(:wall_8, 384 + tile_info[0] + 10)
                push_tile(:wall_9, 384 + tile_info[0] + 11)
                push_tile(:wall_in_1, 384 + tile_info[0] + 22)
                push_tile(:wall_in_3, 384 + tile_info[0] + 21)
                push_tile(:wall_in_7, 384 + tile_info[0] + 30)
                push_tile(:wall_in_9, 384 + tile_info[0] + 29)
                push_tile(:upper_wall_1, 384 + tile_info[0] + 32)
                push_tile(:upper_wall_2, 384 + tile_info[0] + 34)
                push_tile(:upper_wall_3, 384 + tile_info[0] + 36)
                push_tile(:upper_wall_4, 384 + tile_info[0] + 16)
                push_tile(:upper_wall_6, 384 + tile_info[0] + 20)
                push_tile(:upper_wall_7, 384 + tile_info[0] + 0)
                push_tile(:upper_wall_8, 384 + tile_info[0] + 2)
                push_tile(:upper_wall_9, 384 + tile_info[0] + 4)
                push_tile(:upper_wall_in_1, 384 + tile_info[0] + 6)
                push_tile(:upper_wall_in_3, 384 + tile_info[0] + 5)
                push_tile(:upper_wall_in_7, 384 + tile_info[0] + 14)
                push_tile(:upper_wall_in_9, 384 + tile_info[0] + 13)
              end
            elsif @large_wall_tiles
              push_tile(:wall_1, 384 + tile_info[0] + 24)
              push_tile(:wall_2, 384 + tile_info[0] + 25)
              push_tile(:wall_3, 384 + tile_info[0] + 27)
              push_tile(:wall_4, 384 + tile_info[0] + 8)
              push_tile(:wall_6, 384 + tile_info[0] + 11)
              push_tile(:wall_7, 384 + tile_info[0] + 0)
              push_tile(:wall_8, 384 + tile_info[0] + 1)
              push_tile(:wall_9, 384 + tile_info[0] + 3)
              push_tile(:wall_in_1, 384 + tile_info[0] + 5)
              push_tile(:wall_in_3, 384 + tile_info[0] + 4)
              push_tile(:wall_in_7, 384 + tile_info[0] + 13)
              push_tile(:wall_in_9, 384 + tile_info[0] + 12)
            else
              push_tile(:wall_1, 384 + tile_info[0] + 16)
              push_tile(:wall_2, 384 + tile_info[0] + 17)
              push_tile(:wall_3, 384 + tile_info[0] + 18)
              push_tile(:wall_4, 384 + tile_info[0] + 8)
              push_tile(:wall_6, 384 + tile_info[0] + 10)
              push_tile(:wall_7, 384 + tile_info[0] + 0)
              push_tile(:wall_8, 384 + tile_info[0] + 1)
              push_tile(:wall_9, 384 + tile_info[0] + 2)
              push_tile(:wall_in_1, 384 + tile_info[0] + 4)
              push_tile(:wall_in_3, 384 + tile_info[0] + 3)
              push_tile(:wall_in_7, 384 + tile_info[0] + 12)
              push_tile(:wall_in_9, 384 + tile_info[0] + 11)
            end
          end
          id = (i == 0) ? tile_info[0] * 48 : 384 + tile_info[0]
          push_tile(tile_type, id, false)
        end
      end
    end

    def push_tile(tile_type, id, auto = true)
      @tile_type_ids[tile_type] ||= []
      @tile_type_ids[tile_type].push([id, auto])
    end

    def has_flag?(flag)
      return @flags.any? { |f| f.downcase == flag.downcase }
    end

    def has_decoration?(deco)
      return @tile_type_ids.include?(deco) && @tile_type_ids[deco].length > 0
    end

    def get_random_tile_of_type(tile_type, dungeon, x, y, layer)
      tiles = @tile_type_ids[tile_type]
      return 0 if !tiles || tiles.empty?
      ret = tiles.sample[0]
      if ret < 384   # Autotile
        nb = TileDrawingHelper.tableNeighbors(dungeon, x, y, layer)
        variant = TileDrawingHelper::NEIGHBORS_TO_AUTOTILE_INDEX[nb]
        ret += variant
      else
        case tile_type
        when :void
          if @large_void_tiles
            ret += 1 if x.odd?
            ret += 8 if y.odd?
          end
        when :floor
          if large_floor_tiles
            ret += 1 if x.odd?
            ret += 8 if y.odd?
          end
        when :wall_2, :wall_8, :wall_top
          ret += 1 if @large_wall_tiles && x.odd?
        when :wall_4, :wall_6
          ret += 8 if @large_wall_tiles && y.odd?
        end
        # Different wall tiles for northern walls if there's another wall directly
        # north of them (i.e. tree tiles that shouldn't have shaded grass because
        # there isn't a tree-enclosed area there)
        if @thin_north_wall_offset != 0 && [:wall_7, :wall_8, :wall_9].include?(tile_type)
          ret += @thin_north_wall_offset if dungeon.tile_is_wall?(dungeon[x, y - 1, 1])
        end
      end
      return ret
    end

    alias __orig__get_property_for_PBS get_property_for_PBS unless method_defined?(:__orig__get_property_for_PBS)
    def get_property_for_PBS(key)
      ret = __orig__get_property_for_PBS(key)
      case key
      when "ThinNorthWallOffset"
        ret = nil if ret == 0
      when "Tile", "Autotile"
        ret = []
        @tile_type_ids.each do |tile_type, tile_ids|
          tile_ids.each do |tile|
            case key
            when "Tile"
              ret.push([tile[0] - 384, tile_type]) if !tile[1] && tile[0] >= 384
            when "Autotile"
              ret.push([tile[0] / 48, tile_type]) if !tile[1] && tile[0] < 384
            end
          end
        end
        ret = nil if ret.length == 0
      end
      return ret
    end
  end
end
