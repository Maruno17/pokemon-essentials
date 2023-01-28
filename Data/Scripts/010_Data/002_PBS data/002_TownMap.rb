module GameData
  class TownMap
    attr_reader :id
    attr_reader :real_name
    attr_reader :filename
    attr_reader :point
    attr_reader :flags
    attr_reader :pbs_file_suffix

    DATA = {}
    DATA_FILENAME = "town_map.dat"
    PBS_BASE_FILENAME = "town_map"

    SCHEMA = {
      "SectionName" => [:id,        "u"],
      "Name"        => [:real_name, "s"],
      "Filename"    => [:filename,  "s"],
      "Point"       => [:point,     "^uusSUUUU"],
      "Flags"       => [:flags,     "*s"]
    }

    extend ClassMethodsIDNumbers
    include InstanceMethods

    def initialize(hash)
      @id              = hash[:id]
      @real_name       = hash[:real_name]       || "???"
      @filename        = hash[:filename]
      @point           = hash[:point]           || []
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
  end
end
