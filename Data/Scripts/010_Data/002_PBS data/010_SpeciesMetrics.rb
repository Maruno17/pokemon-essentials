module GameData
  class SpeciesMetrics
    attr_reader   :id
    attr_reader   :species
    attr_reader   :form
    attr_accessor :back_sprite
    attr_accessor :front_sprite
    attr_accessor :front_sprite_altitude
    attr_accessor :shadow_x
    attr_accessor :shadow_size
    attr_reader   :pbs_file_suffix

    DATA = {}
    DATA_FILENAME = "species_metrics.dat"
    PBS_BASE_FILENAME = "pokemon_metrics"

    SCHEMA = {
      "SectionName"         => [:id,                    "eV", :Species],
      "BackSprite"          => [:back_sprite,           "ii"],
      "FrontSprite"         => [:front_sprite,          "ii"],
      "FrontSpriteAltitude" => [:front_sprite_altitude, "i"],
      "ShadowX"             => [:shadow_x,              "i"],
      "ShadowSize"          => [:shadow_size,           "u"]
    }

    extend ClassMethodsSymbols
    include InstanceMethods

    # @param species [Symbol, String]
    # @param form [Integer]
    # @return [self, nil]
    def self.get_species_form(species, form)
      return nil if !species || !form
      validate species => [Symbol, String]
      validate form => Integer
      raise _INTL("Undefined species {1}.", species) if !GameData::Species.exists?(species)
      species = species.to_sym if species.is_a?(String)
      if form > 0
        trial = sprintf("%s_%d", species, form).to_sym
        if !DATA.has_key?(trial)
          self.register({:id => species}) if !DATA[species]
          self.register({
            :id                    => trial,
            :species               => species,
            :form                  => form,
            :back_sprite           => DATA[species].back_sprite.clone,
            :front_sprite          => DATA[species].front_sprite.clone,
            :front_sprite_altitude => DATA[species].front_sprite_altitude,
            :shadow_x              => DATA[species].shadow_x,
            :shadow_size           => DATA[species].shadow_size
          })
        end
        return DATA[trial]
      end
      self.register({:id => species}) if !DATA[species]
      return DATA[species]
    end

    def initialize(hash)
      @id                    = hash[:id]
      @species               = hash[:species]               || @id
      @form                  = hash[:form]                  || 0
      @back_sprite           = hash[:back_sprite]           || [0, 0]
      @front_sprite          = hash[:front_sprite]          || [0, 0]
      @front_sprite_altitude = hash[:front_sprite_altitude] || 0
      @shadow_x              = hash[:shadow_x]              || 0
      @shadow_size           = hash[:shadow_size]           || 2
      @pbs_file_suffix       = hash[:pbs_file_suffix]       || ""
    end

    def apply_metrics_to_sprite(sprite, index, shadow = false)
      if shadow
        sprite.x += @shadow_x * 2 if (index & 1) == 1   # Foe Pokémon
      elsif (index & 1) == 0   # Player's Pokémon
        sprite.x += @back_sprite[0] * 2
        sprite.y += @back_sprite[1] * 2
      else                     # Foe Pokémon
        sprite.x += @front_sprite[0] * 2
        sprite.y += @front_sprite[1] * 2
        sprite.y -= @front_sprite_altitude * 2
      end
    end

    def shows_shadow?
      return true
#      return @front_sprite_altitude > 0
    end

    alias __orig__get_property_for_PBS get_property_for_PBS unless method_defined?(:__orig__get_property_for_PBS)
    def get_property_for_PBS(key)
      ret = __orig__get_property_for_PBS(key)
      case key
      when "SectionName"
        ret = [@species, (@form > 0) ? @form : nil]
      when "FrontSpriteAltitude"
        ret = nil if ret == 0
      end
      return ret
    end
  end
end
