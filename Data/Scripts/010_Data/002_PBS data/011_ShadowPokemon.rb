#===============================================================================
#
#===============================================================================
module GameData
  class ShadowPokemon
    attr_reader :id
    attr_reader :species
    attr_reader :form
    attr_reader :moves
    attr_reader :gauge_size
    attr_reader :flags
    attr_reader :pbs_file_suffix

    DATA = {}
    DATA_FILENAME = "shadow_pokemon.dat"
    PBS_BASE_FILENAME = "shadow_pokemon"
    OPTIONAL = true
    SCHEMA = {
      "SectionName" => [:id,         "eV", :Species],
      "GaugeSize"   => [:gauge_size, "v"],
      "Moves"       => [:moves,      "*e", :Move],
      "Flags"       => [:flags,      "*s"]
    }
    HEART_GAUGE_SIZE = 4000   # Default gauge size

    extend ClassMethodsSymbols
    include InstanceMethods

    singleton_class.alias_method(:__orig__load, :load) unless singleton_class.method_defined?(:__orig__load)
    def self.load
      __orig__load if FileTest.exist?("Data/#{self::DATA_FILENAME}")
    end

    # @param species [Symbol, self, String]
    # @param form [Integer]
    # @return [self, nil]
    def self.get_species_form(species, form)
      return nil if !species || !form
      validate species => [Symbol, self, String]
      validate form => Integer
      species = species.species if species.is_a?(self)
      species = species.to_sym if species.is_a?(String)
      trial = sprintf("%s_%d", species, form).to_sym
      species_form = (DATA[trial].nil?) ? species : trial
      return (DATA.has_key?(species_form)) ? DATA[species_form] : nil
    end

    #---------------------------------------------------------------------------

    def initialize(hash)
      @id              = hash[:id]
      @species         = hash[:species]         || @id
      @form            = hash[:form]            || 0
      @gauge_size      = hash[:gauge_size]      || HEART_GAUGE_SIZE
      @moves           = hash[:moves]           || []
      @flags           = hash[:flags]           || []
      @pbs_file_suffix = hash[:pbs_file_suffix] || ""
    end

    def has_flag?(flag)
      return @flags.any? { |f| f.downcase == flag.downcase }
    end

    alias __orig__get_property_for_PBS get_property_for_PBS unless method_defined?(:__orig__get_property_for_PBS)
    def get_property_for_PBS(key)
      ret = __orig__get_property_for_PBS(key)
      case key
      when "SectionName"
        ret = [@species, (@form > 0) ? @form : nil]
      end
      return ret
    end
  end
end
