module GameData
  class DungeonParameters
    attr_reader :id, :area, :version
    attr_reader :cell_count_x, :cell_count_y
    attr_reader :cell_width, :cell_height
    attr_reader :room_min_width, :room_min_height
    attr_reader :room_max_width, :room_max_height
    attr_reader :corridor_width, :random_corridor_shift
    # Layouts:
    #   :full          - every node in the map
    #   :no_corners    - every node except for one in each corner
    #   :ring          - every node around the edge of the map
    #   :antiring      - every node except one that touches an edge of the map
    #   :plus          - every node in a plus (+) shape
    #   :diagonal_up   - every node in a line from bottom left to top right (/)
    #   :diagonal_down - every node in a line from top left to bottom right (\)
    #   :cross         - every node in a cross (x) shape
    #   :quadrants     - every node except the middles of each edge (i.e. each corner bulges out)
    attr_reader :node_layout, :room_layout
    attr_reader :room_chance   # Percentage of active roomable nodes that will become rooms
    attr_reader :extra_connections_count
    attr_reader :floor_patch_radius, :floor_patch_chance, :floor_patch_smooth_rate
    attr_reader :floor_decoration_density, :floor_decoration_large_density
    attr_reader :void_decoration_density, :void_decoration_large_density
    attr_reader :rng_seed
    attr_reader :flags
    attr_reader :pbs_file_suffix

    DATA = {}
    DATA_FILENAME = "dungeon_parameters.dat"
    PBS_BASE_FILENAME = "dungeon_parameters"

    SCHEMA = {
      "SectionName"      => [:id,                      "mV"],
      "DungeonSize"      => [:dungeon_size,            "vv"],
      "CellSize"         => [:cell_size,               "vv"],
      "MinRoomSize"      => [:min_room_size,           "vv"],
      "MaxRoomSize"      => [:max_room_size,           "vv"],
      "CorridorWidth"    => [:corridor_width,          "v"],
      "ShiftCorridors"   => [:random_corridor_shift,   "b"],
      "NodeLayout"       => [:node_layout,             "m"],
      "RoomLayout"       => [:room_layout,             "m"],
      "RoomChance"       => [:room_chance,             "v"],
      "ExtraConnections" => [:extra_connections_count, "u"],
      "FloorPatches"     => [:floor_patches,           "vvu"],
      "FloorDecorations" => [:floor_decorations,       "uu"],
      "VoidDecorations"  => [:void_decorations,        "uu"],
      "RNGSeed"          => [:rng_seed,                "u"],
      "Flags"            => [:flags,                   "*s"]
    }

    extend ClassMethodsSymbols
    include InstanceMethods

    # @param area [Symbol, String, self]
    # @param version [Integer]
    # @return [self]
    def self.try_get(area, version = 0)
      validate area => [Symbol, self, String]
      validate version => Integer
      area = area.id if area.is_a?(self)
      area = area.to_sym if area.is_a?(String)
      trial = sprintf("%s_%d", area, version).to_sym
      area_version = (DATA[trial].nil?) ? area : trial
      return (DATA.has_key?(area_version)) ? DATA[area_version] : self.new({})
    end

    def initialize(hash)
      @id                             = hash[:id]
      @area                           = hash[:area]
      @version                        = hash[:version]                 || 0
      @cell_count_x                   = (hash[:dungeon_size]) ? hash[:dungeon_size][0] : 5
      @cell_count_y                   = (hash[:dungeon_size]) ? hash[:dungeon_size][1] : 5
      @cell_width                     = (hash[:cell_size]) ? hash[:cell_size][0] : 10
      @cell_height                    = (hash[:cell_size]) ? hash[:cell_size][1] : 10
      @room_min_width                 = (hash[:min_room_size]) ? hash[:min_room_size][0] : 5
      @room_min_height                = (hash[:min_room_size]) ? hash[:min_room_size][1] : 5
      @room_max_width                 = (hash[:max_room_size]) ? hash[:max_room_size][0] : @cell_width - 1
      @room_max_height                = (hash[:max_room_size]) ? hash[:max_room_size][1] : @cell_height - 1
      @corridor_width                 = hash[:corridor_width]          || 2
      @random_corridor_shift          = hash[:random_corridor_shift]
      @node_layout                    = hash[:node_layout]             || :full
      @room_layout                    = hash[:room_layout]             || :full
      @room_chance                    = hash[:room_chance]             || 70
      @extra_connections_count        = hash[:extra_connections_count] || 2
      @floor_patch_radius             = (hash[:floor_patches]) ? hash[:floor_patches][0] : 3
      @floor_patch_chance             = (hash[:floor_patches]) ? hash[:floor_patches][1] : 75
      @floor_patch_smooth_rate        = (hash[:floor_patches]) ? hash[:floor_patches][2] : 25
      @floor_decoration_density       = (hash[:floor_decorations]) ? hash[:floor_decorations][0] : 50
      @floor_decoration_large_density = (hash[:floor_decorations]) ? hash[:floor_decorations][1] : 200
      @void_decoration_density        = (hash[:void_decorations]) ? hash[:void_decorations][0] : 50
      @void_decoration_large_density  = (hash[:void_decorations]) ? hash[:void_decorations][1] : 200
      @rng_seed                       = hash[:rng_seed]
      @flags                          = hash[:flags]                   || []
      @pbs_file_suffix                = hash[:pbs_file_suffix]         || ""
    end

    def has_flag?(flag)
      return @flags.any? { |f| f.downcase == flag.downcase }
    end

    def rand_cell_center
      x = (@cell_width / 2) + rand(-2..2)
      y = (@cell_height / 2) + rand(-2..2)
      return x, y
    end

    def rand_room_size
      width = @room_min_width
      if @room_max_width > @room_min_width
        width = rand(@room_min_width..@room_max_width)
      end
      height = @room_min_height
      if @room_max_height > @room_min_height
        height = rand(@room_min_height..@room_max_height)
      end
      return width, height
    end

    alias __orig__get_property_for_PBS get_property_for_PBS unless method_defined?(:__orig__get_property_for_PBS)
    def get_property_for_PBS(key)
      case key
      when "SectionName"      then return [@area, (@version > 0) ? @version : nil]
      when "DungeonSize"      then return [@cell_count_x, @cell_count_y]
      when "CellSize"         then return [@cell_width, @cell_height]
      when "MinRoomSize"      then return [@room_min_width, @room_min_height]
      when "MaxRoomSize"      then return [@room_max_width, @room_max_height]
      when "FloorPatches"     then return [@floor_patch_radius, @floor_patch_chance, @floor_patch_smooth_rate]
      when "FloorDecorations" then return [@floor_decoration_density, @floor_decoration_large_density]
      when "VoidDecorations"  then return [@void_decoration_density, @void_decoration_large_density]
      end
      return __orig__get_property_for_PBS(key)
    end
  end
end
