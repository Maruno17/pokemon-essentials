#===============================================================================
#
#===============================================================================
module GameData
  class TownMap
    attr_reader :id
    attr_reader :real_name
    attr_reader :filename
    attr_reader :margins
    attr_reader :point_size
    attr_reader :size
    attr_reader :points
    attr_reader :flags
    attr_reader :pbs_file_suffix

    DATA = {}
    DATA_FILENAME = "town_map.dat"
    PBS_BASE_FILENAME = "town_map"
    SCHEMA = {
      "SectionName" => [:id,         "u"],
      "Name"        => [:real_name,  "s"],
      "Filename"    => [:filename,   "s"],
      "Margins"     => [:margins,    "uu"],   # Left/right and top/bottom padding in pixels
      "PointSize"   => [:point_size, "vv"],   # Size of a point in pixels
      "Size"        => [:size,       "vv"],   # Width and height in points
      "Point"       => [:points,     "^uusSUUUU"],
      "Flags"       => [:flags,      "*s"]
    }
    # This schema is for definable properties of individual points (apart from
    # position and name which are above).
    SUB_SCHEMA = {
      "Image"         => [:image,            "s"],
      "Description"   => [:real_description, "q"],
      "FlySpot"       => [:fly_spot,         "vuu"],   # Map ID, x coord, y coord
      "HideFlyIcon"   => [:hide_fly_icon,    "b"],
      "FlyIconOffset" => [:fly_icon_offset,  "ii"],    # x and y offsets in pixels
      "Switch"        => [:switch,           "v"]      # Game Switch ID
    }

    extend ClassMethodsIDNumbers
    include InstanceMethods

    def self.sub_schema
      return SUB_SCHEMA
    end

    #---------------------------------------------------------------------------

    def initialize(hash)
      @id              = hash[:id]
      @real_name       = hash[:real_name]       || "???"
      @filename        = hash[:filename]
      @margins         = hash[:margins]         || [0, 0]
      @point_size      = hash[:point_size]      || [16, 16]
      @size            = hash[:size]            || [30, 20]
      @points          = hash[:points]          || []
      @flags           = hash[:flags]           || []
      @pbs_file_suffix = hash[:pbs_file_suffix] || ""
    end

    # @return [String] the translated name of this region
    def name
      return pbGetMessageFromHash(MessageTypes::REGION_NAMES, @real_name)
    end

    def has_flag?(flag)
      return @flags.any? { |f| f.downcase == flag.downcase }
    end

    alias __orig__get_property_for_PBS get_property_for_PBS unless method_defined?(:__orig__get_property_for_PBS)
    def get_property_for_PBS(key)
      ret = __orig__get_property_for_PBS(key)
      case key
      when "Margins"
        ret = nil if ret == [0, 0]
      end
      return ret
    end

    def get_point_property_for_PBS(key, index = 0)
      return [*@points[index][:position], @points[index][:real_name]] if key == "Point"
      ret = @points[index][SUB_SCHEMA[key][0]]
      ret = nil if ret == false || (ret.is_a?(Array) && ret.length == 0) || ret == ""
      case key
      when "Margins"
        ret = nil if ret == [0, 0]
      when "FlySpot"
        ret = nil if ret && ret.compact.empty?
      end
      return ret
    end
  end
end
