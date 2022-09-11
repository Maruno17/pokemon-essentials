module GameData
  class Metadata
    attr_reader :id
    attr_reader :start_money
    attr_reader :start_item_storage
    attr_reader :home
    attr_reader :real_storage_creator
    attr_reader :wild_battle_BGM
    attr_reader :trainer_battle_BGM
    attr_reader :wild_victory_BGM
    attr_reader :trainer_victory_BGM
    attr_reader :wild_capture_ME
    attr_reader :surf_BGM
    attr_reader :bicycle_BGM

    DATA = {}
    DATA_FILENAME = "metadata.dat"

    SCHEMA = {
      "StartMoney"        => [1,  "u"],
      "StartItemStorage"  => [2,  "*e", :Item],
      "Home"              => [3,  "vuuu"],
      "StorageCreator"    => [4,  "s"],
      "WildBattleBGM"     => [5,  "s"],
      "TrainerBattleBGM"  => [6,  "s"],
      "WildVictoryBGM"    => [7,  "s"],
      "TrainerVictoryBGM" => [8,  "s"],
      "WildCaptureME"     => [9,  "s"],
      "SurfBGM"           => [10, "s"],
      "BicycleBGM"        => [11, "s"]
    }

    extend ClassMethodsIDNumbers
    include InstanceMethods

    def self.editor_properties
      return [
        ["StartMoney",        LimitProperty.new(Settings::MAX_MONEY), _INTL("The amount of money that the player starts the game with.")],
        ["StartItemStorage",  GameDataPoolProperty.new(:Item),        _INTL("Items that are already in the player's PC at the start of the game.")],
        ["Home",              MapCoordsFacingProperty, _INTL("Map ID and X/Y coordinates of where the player goes after a loss if no Pokémon Center was visited.")],
        ["StorageCreator",    StringProperty,          _INTL("Name of the Pokémon Storage creator (the storage option is named \"XXX's PC\").")],
        ["WildBattleBGM",     BGMProperty,             _INTL("Default BGM for wild Pokémon battles.")],
        ["TrainerBattleBGM",  BGMProperty,             _INTL("Default BGM for Trainer battles.")],
        ["WildVictoryBGM",    BGMProperty,             _INTL("Default BGM played after winning a wild Pokémon battle.")],
        ["TrainerVictoryBGM", BGMProperty,             _INTL("Default BGM played after winning a Trainer battle.")],
        ["WildCaptureME",     MEProperty,              _INTL("Default ME played after catching a Pokémon.")],
        ["SurfBGM",           BGMProperty,             _INTL("BGM played while surfing.")],
        ["BicycleBGM",        BGMProperty,             _INTL("BGM played while on a bicycle.")]
      ]
    end

    def self.get
      return DATA[0]
    end

    def initialize(hash)
      @id                   = hash[:id]
      @start_money          = hash[:start_money] || 3000
      @start_item_storage   = hash[:start_item_storage] || []
      @home                 = hash[:home]
      @real_storage_creator = hash[:storage_creator]
      @wild_battle_BGM      = hash[:wild_battle_BGM]
      @trainer_battle_BGM   = hash[:trainer_battle_BGM]
      @wild_victory_BGM     = hash[:wild_victory_BGM]
      @trainer_victory_BGM  = hash[:trainer_victory_BGM]
      @wild_capture_ME      = hash[:wild_capture_ME]
      @surf_BGM             = hash[:surf_BGM]
      @bicycle_BGM          = hash[:bicycle_BGM]
    end

    # @return [String] the translated name of the Pokémon Storage creator
    def storage_creator
      ret = pbGetMessage(MessageTypes::StorageCreator, 0)
      return nil_or_empty?(ret) ? _INTL("Bill") : ret
    end

    def property_from_string(str)
      case str
      when "StartMoney"        then return @start_money
      when "StartItemStorage"  then return @start_item_storage
      when "Home"              then return @home
      when "StorageCreator"    then return @real_storage_creator
      when "WildBattleBGM"     then return @wild_battle_BGM
      when "TrainerBattleBGM"  then return @trainer_battle_BGM
      when "WildVictoryBGM"    then return @wild_victory_BGM
      when "TrainerVictoryBGM" then return @trainer_victory_BGM
      when "WildCaptureME"     then return @wild_capture_ME
      when "SurfBGM"           then return @surf_BGM
      when "BicycleBGM"        then return @bicycle_BGM
      end
      return nil
    end
  end
end
