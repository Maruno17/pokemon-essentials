#===============================================================================
#
#===============================================================================
module GameData
  class Ribbon
    attr_reader :id
    attr_reader :real_name
    attr_reader :icon_position   # Where this ribbon's graphic is within ribbons.png
    attr_reader :real_description
    attr_reader :flags
    attr_reader :pbs_file_suffix

    DATA = {}
    DATA_FILENAME = "ribbons.dat"
    PBS_BASE_FILENAME = "ribbons"
    SCHEMA = {
      "SectionName"  => [:id,               "m"],
      "Name"         => [:real_name,        "s"],
      "IconPosition" => [:icon_position,    "u"],
      "Description"  => [:real_description, "q"],
      "Flags"        => [:flags,            "*s"]
    }

    extend ClassMethodsSymbols
    include InstanceMethods

    #---------------------------------------------------------------------------

    def initialize(hash)
      @id               = hash[:id]
      @real_name        = hash[:real_name]        || "Unnamed"
      @icon_position    = hash[:icon_position]    || 0
      @real_description = hash[:real_description] || "???"
      @flags            = hash[:flags]            || []
      @pbs_file_suffix  = hash[:pbs_file_suffix]  || ""
    end

    # @return [String] the translated name of this ribbon
    def name
      return pbGetMessageFromHash(MessageTypes::RIBBON_NAMES, @real_name)
    end

    # @return [String] the translated description of this ribbon
    def description
      return pbGetMessageFromHash(MessageTypes::RIBBON_DESCRIPTIONS, @real_description)
    end

    def has_flag?(flag)
      return @flags.any? { |f| f.downcase == flag.downcase }
    end
  end
end
