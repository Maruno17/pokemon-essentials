module GameData
  class Metadata
    attr_reader :id
    attr_reader :home
    attr_reader :wild_battle_BGM
    attr_reader :trainer_battle_BGM
    attr_reader :wild_victory_ME
    attr_reader :trainer_victory_ME
    attr_reader :wild_capture_ME
    attr_reader :surf_BGM
    attr_reader :bicycle_BGM

    DATA = {}
    DATA_FILENAME = "metadata.dat"

    SCHEMA = {
      "Home"             => [1,  "vuuu"],
      "WildBattleBGM"    => [2,  "s"],
      "TrainerBattleBGM" => [3,  "s"],
      "WildVictoryME"    => [4,  "s"],
      "TrainerVictoryME" => [5,  "s"],
      "WildCaptureME"    => [6,  "s"],
      "SurfBGM"          => [7,  "s"],
      "BicycleBGM"       => [8,  "s"]
    }

    extend ClassMethodsIDNumbers
    include InstanceMethods

    def self.editor_properties
      return [
         ["Home",             MapCoordsFacingProperty, _INTL("Map ID and X and Y coordinates of where the player goes if no Pokémon Center was entered after a loss.")],
         ["WildBattleBGM",    BGMProperty,             _INTL("Default BGM for wild Pokémon battles.")],
         ["TrainerBattleBGM", BGMProperty,             _INTL("Default BGM for Trainer battles.")],
         ["WildVictoryME",    MEProperty,              _INTL("Default ME played after winning a wild Pokémon battle.")],
         ["TrainerVictoryME", MEProperty,              _INTL("Default ME played after winning a Trainer battle.")],
         ["WildCaptureME",    MEProperty,              _INTL("Default ME played after catching a Pokémon.")],
         ["SurfBGM",          BGMProperty,             _INTL("BGM played while surfing.")],
         ["BicycleBGM",       BGMProperty,             _INTL("BGM played while on a bicycle.")]
      ]
    end

    def self.get
      return DATA[0]
    end

    def initialize(hash)
      @id                  = hash[:id]
      @home                = hash[:home]
      @wild_battle_BGM     = hash[:wild_battle_BGM]
      @trainer_battle_BGM  = hash[:trainer_battle_BGM]
      @wild_victory_ME     = hash[:wild_victory_ME]
      @trainer_victory_ME  = hash[:trainer_victory_ME]
      @wild_capture_ME     = hash[:wild_capture_ME]
      @surf_BGM            = hash[:surf_BGM]
      @bicycle_BGM         = hash[:bicycle_BGM]
    end

    def property_from_string(str)
      case str
      when "Home"             then return @home
      when "WildBattleBGM"    then return @wild_battle_BGM
      when "TrainerBattleBGM" then return @trainer_battle_BGM
      when "WildVictoryME"    then return @wild_victory_ME
      when "TrainerVictoryME" then return @trainer_victory_ME
      when "WildCaptureME"    then return @wild_capture_ME
      when "SurfBGM"          then return @surf_BGM
      when "BicycleBGM"       then return @bicycle_BGM
      end
      return nil
    end
  end
end
