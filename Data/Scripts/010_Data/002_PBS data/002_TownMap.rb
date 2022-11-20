module GameData
  class TownMap
    attr_reader :id
    attr_reader :real_name
    attr_reader :filename
    attr_reader :point
    attr_reader :flags

    DATA = {}
    DATA_FILENAME = "town_map.dat"

    SCHEMA = {
      "SectionName" => [:id,        "u"],
      "Name"        => [:real_name, "s"],
      "Filename"    => [:filename,  "s"],
      "Point"       => [:point,     "^uussUUUU"],
      "Flags"       => [:flags,     "*s"]
    }

    extend ClassMethodsIDNumbers
    include InstanceMethods

    def initialize(hash)
      @id        = hash[:id]
      @real_name = hash[:real_name] || "???"
      @filename  = hash[:filename]
      @point     = hash[:point]     || []
      @flags     = hash[:flags]     || []
    end

    # @return [String] the translated name of this region
    def name
      return pbGetMessage(MessageTypes::RegionNames, @id)
    end

    def has_flag?(flag)
      return @flags.any? { |f| f.downcase == flag.downcase }
    end
  end
end
