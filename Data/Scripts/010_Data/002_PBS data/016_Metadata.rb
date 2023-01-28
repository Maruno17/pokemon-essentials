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
    attr_reader :pbs_file_suffix

    DATA = {}
    DATA_FILENAME = "metadata.dat"
    PBS_BASE_FILENAME = "metadata"

    SCHEMA = {
      "SectionName"       => [:id,                   "u"],
      "StartMoney"        => [:start_money,          "u"],
      "StartItemStorage"  => [:start_item_storage,   "*e", :Item],
      "Home"              => [:home,                 "vuuu"],
      "StorageCreator"    => [:real_storage_creator, "s"],
      "WildBattleBGM"     => [:wild_battle_BGM,      "s"],
      "TrainerBattleBGM"  => [:trainer_battle_BGM,   "s"],
      "WildVictoryBGM"    => [:wild_victory_BGM,     "s"],
      "TrainerVictoryBGM" => [:trainer_victory_BGM,  "s"],
      "WildCaptureME"     => [:wild_capture_ME,      "s"],
      "SurfBGM"           => [:surf_BGM,             "s"],
      "BicycleBGM"        => [:bicycle_BGM,          "s"]
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
      @id                   = hash[:id]                 || 0
      @start_money          = hash[:start_money]        || 3000
      @start_item_storage   = hash[:start_item_storage] || []
      @home                 = hash[:home]
      @real_storage_creator = hash[:real_storage_creator]
      @wild_battle_BGM      = hash[:wild_battle_BGM]
      @trainer_battle_BGM   = hash[:trainer_battle_BGM]
      @wild_victory_BGM     = hash[:wild_victory_BGM]
      @trainer_victory_BGM  = hash[:trainer_victory_BGM]
      @wild_capture_ME      = hash[:wild_capture_ME]
      @surf_BGM             = hash[:surf_BGM]
      @bicycle_BGM          = hash[:bicycle_BGM]
      @pbs_file_suffix      = hash[:pbs_file_suffix]    || ""
    end

    # @return [String] the translated name of the Pokémon Storage creator
    def storage_creator
      ret = pbGetMessageFromHash(MessageTypes::STORAGE_CREATOR_NAME, @real_storage_creator)
      return nil_or_empty?(ret) ? _INTL("Bill") : ret
    end
  end
end
