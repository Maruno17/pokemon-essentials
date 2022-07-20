module GameData
  class PlayerMetadata
    attr_reader :id
    attr_reader :trainer_type
    attr_reader :walk_charset
    attr_reader :home

    DATA = {}
    DATA_FILENAME = "player_metadata.dat"

    SCHEMA = {
      "TrainerType"     => [1, "e", :TrainerType],
      "WalkCharset"     => [2, "s"],
      "RunCharset"      => [3, "s"],
      "CycleCharset"    => [4, "s"],
      "SurfCharset"     => [5, "s"],
      "DiveCharset"     => [6, "s"],
      "FishCharset"     => [7, "s"],
      "SurfFishCharset" => [8, "s"],
      "Home"            => [9, "vuuu"]
    }

    extend ClassMethodsIDNumbers
    include InstanceMethods

    def self.editor_properties
      return [
        ["TrainerType",     TrainerTypeProperty,     _INTL("Trainer type of this player.")],
        ["WalkCharset",     CharacterProperty,       _INTL("Charset used while the player is still or walking.")],
        ["RunCharset",      CharacterProperty,       _INTL("Charset used while the player is running. Uses WalkCharset if undefined.")],
        ["CycleCharset",    CharacterProperty,       _INTL("Charset used while the player is cycling. Uses RunCharset if undefined.")],
        ["SurfCharset",     CharacterProperty,       _INTL("Charset used while the player is surfing. Uses CycleCharset if undefined.")],
        ["DiveCharset",     CharacterProperty,       _INTL("Charset used while the player is diving. Uses SurfCharset if undefined.")],
        ["FishCharset",     CharacterProperty,       _INTL("Charset used while the player is fishing. Uses WalkCharset if undefined.")],
        ["SurfFishCharset", CharacterProperty,       _INTL("Charset used while the player is fishing while surfing. Uses FishCharset if undefined.")],
        ["Home",            MapCoordsFacingProperty, _INTL("Map ID and X/Y coordinates of where the player goes after a loss if no Pokémon Center was visited.")]
      ]
    end

    # @param player_id [Integer]
    # @return [self, nil]
    def self.get(player_id = 1)
      validate player_id => Integer
      return self::DATA[player_id] if self::DATA.has_key?(player_id)
      return self::DATA[1]
    end

    def initialize(hash)
      @id                = hash[:id]
      @trainer_type      = hash[:trainer_type]
      @walk_charset      = hash[:walk_charset]
      @run_charset       = hash[:run_charset]
      @cycle_charset     = hash[:cycle_charset]
      @surf_charset      = hash[:surf_charset]
      @dive_charset      = hash[:dive_charset]
      @fish_charset      = hash[:fish_charset]
      @surf_fish_charset = hash[:surf_fish_charset]
      @home              = hash[:home]
    end

    def run_charset
      return @run_charset || @walk_charset
    end

    def cycle_charset
      return @cycle_charset || run_charset
    end

    def surf_charset
      return @surf_charset || cycle_charset
    end

    def dive_charset
      return @dive_charset || surf_charset
    end

    def fish_charset
      return @fish_charset || @walk_charset
    end

    def surf_fish_charset
      return @surf_fish_charset || fish_charset
    end

    def property_from_string(str)
      case str
      when "TrainerType"     then return @trainer_type
      when "WalkCharset"     then return @walk_charset
      when "RunCharset"      then return @run_charset
      when "CycleCharset"    then return @cycle_charset
      when "SurfCharset"     then return @surf_charset
      when "DiveCharset"     then return @dive_charset
      when "FishCharset"     then return @fish_charset
      when "SurfFishCharset" then return @surf_fish_charset
      when "Home"            then return @home
      end
      return nil
    end
  end
end
