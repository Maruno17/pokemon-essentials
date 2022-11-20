module GameData
  class ShadowPokemon
    attr_reader :id
    attr_reader :moves
    attr_reader :gauge_size
    attr_reader :flags

    DATA = {}
    DATA_FILENAME = "shadow_pokemon.dat"

    SCHEMA = {
      "SectionName" => [:id,         "e", :Species],
      "GaugeSize"   => [:gauge_size, "v"],
      "Moves"       => [:moves,      "*m"],   # Not enumerated when compiled
      "Flags"       => [:flags,      "*s"]
    }
    HEART_GAUGE_SIZE = 4000   # Default gauge size

    extend ClassMethodsSymbols
    include InstanceMethods

    def initialize(hash)
      @id         = hash[:id]
      @gauge_size = hash[:gauge_size] || HEART_GAUGE_SIZE
      @moves      = hash[:moves]      || []
      @flags      = hash[:flags]      || []
    end

    def has_flag?(flag)
      return @flags.any? { |f| f.downcase == flag.downcase }
    end
  end
end
