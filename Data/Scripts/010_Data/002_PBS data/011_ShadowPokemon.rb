module GameData
  class ShadowPokemon
    attr_reader :id
    attr_reader :moves
    attr_reader :gauge_size
    attr_reader :flags
    attr_reader :pbs_file_suffix

    DATA = {}
    DATA_FILENAME = "shadow_pokemon.dat"
    PBS_BASE_FILENAME = "shadow_pokemon"

    SCHEMA = {
      "SectionName" => [:id,         "e", :Species],
      "GaugeSize"   => [:gauge_size, "v"],
      "Moves"       => [:moves,      "*e", :Move],
      "Flags"       => [:flags,      "*s"]
    }
    HEART_GAUGE_SIZE = 4000   # Default gauge size

    extend ClassMethodsSymbols
    include InstanceMethods

    alias __orig__load load unless private_method_defined?(:__orig__load)
    def self.load
      __orig__load if safeExists?("Data/#{self::DATA_FILENAME}")
    end

    def initialize(hash)
      @id              = hash[:id]
      @gauge_size      = hash[:gauge_size]      || HEART_GAUGE_SIZE
      @moves           = hash[:moves]           || []
      @flags           = hash[:flags]           || []
      @pbs_file_suffix = hash[:pbs_file_suffix] || ""
    end

    def has_flag?(flag)
      return @flags.any? { |f| f.downcase == flag.downcase }
    end
  end
end
