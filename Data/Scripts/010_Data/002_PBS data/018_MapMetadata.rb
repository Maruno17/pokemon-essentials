module GameData
  class MapMetadata
    attr_reader :id
    attr_reader :real_name
    attr_reader :outdoor_map
    attr_reader :announce_location
    attr_reader :can_bicycle
    attr_reader :always_bicycle
    attr_reader :teleport_destination
    attr_reader :weather
    attr_reader :town_map_position
    attr_reader :dive_map_id
    attr_reader :dark_map
    attr_reader :safari_map
    attr_reader :snap_edges
    attr_reader :random_dungeon
    attr_reader :battle_background
    attr_reader :wild_battle_BGM
    attr_reader :trainer_battle_BGM
    attr_reader :wild_victory_BGM
    attr_reader :trainer_victory_BGM
    attr_reader :wild_capture_ME
    attr_reader :town_map_size
    attr_reader :battle_environment
    attr_reader :flags

    DATA = {}
    DATA_FILENAME = "map_metadata.dat"

    SCHEMA = {
      "Name"              => [1,  "s"],
      "Outdoor"           => [2,  "b"],
      "ShowArea"          => [3,  "b"],
      "Bicycle"           => [4,  "b"],
      "BicycleAlways"     => [5,  "b"],
      "HealingSpot"       => [6,  "vuu"],
      "Weather"           => [7,  "eu", :Weather],
      "MapPosition"       => [8,  "uuu"],
      "DiveMap"           => [9,  "v"],
      "DarkMap"           => [10,  "b"],
      "SafariMap"         => [11, "b"],
      "SnapEdges"         => [12, "b"],
      "Dungeon"           => [13, "b"],
      "BattleBack"        => [14, "s"],
      "WildBattleBGM"     => [15, "s"],
      "TrainerBattleBGM"  => [16, "s"],
      "WildVictoryBGM"    => [17, "s"],
      "TrainerVictoryBGM" => [18, "s"],
      "WildCaptureME"     => [19, "s"],
      "MapSize"           => [20, "us"],
      "Environment"       => [21, "e", :Environment],
      "Flags"             => [22, "*s"]
    }

    extend ClassMethodsIDNumbers
    include InstanceMethods

    def self.editor_properties
      return [
        ["Name",              StringProperty,          _INTL("The name of the map, as seen by the player. Can be different to the map's name as seen in RMXP.")],
        ["Outdoor",           BooleanProperty,         _INTL("If true, this map is an outdoor map and will be tinted according to time of day.")],
        ["ShowArea",          BooleanProperty,         _INTL("If true, the game will display the map's name upon entry.")],
        ["Bicycle",           BooleanProperty,         _INTL("If true, the bicycle can be used on this map.")],
        ["BicycleAlways",     BooleanProperty,         _INTL("If true, the bicycle will be mounted automatically on this map and cannot be dismounted.")],
        ["HealingSpot",       MapCoordsProperty,       _INTL("Map ID of this Pokémon Center's town, and X and Y coordinates of its entrance within that town.")],
        ["Weather",           WeatherEffectProperty,   _INTL("Weather conditions in effect for this map.")],
        ["MapPosition",       RegionMapCoordsProperty, _INTL("Identifies the point on the regional map for this map.")],
        ["DiveMap",           MapProperty,             _INTL("Specifies the underwater layer of this map. Use only if this map has deep water.")],
        ["DarkMap",           BooleanProperty,         _INTL("If true, this map is dark and a circle of light appears around the player. Flash can be used to expand the circle.")],
        ["SafariMap",         BooleanProperty,         _INTL("If true, this map is part of the Safari Zone (both indoor and outdoor). Not to be used in the reception desk.")],
        ["SnapEdges",         BooleanProperty,         _INTL("If true, when the player goes near this map's edge, the game doesn't center the player as usual.")],
        ["Dungeon",           BooleanProperty,         _INTL("If true, this map has a randomly generated layout. See the wiki for more information.")],
        ["BattleBack",        StringProperty,          _INTL("PNG files named 'XXX_bg', 'XXX_base0', 'XXX_base1', 'XXX_message' in Battlebacks folder, where XXX is this property's value.")],
        ["WildBattleBGM",     BGMProperty,             _INTL("Default BGM for wild Pokémon battles on this map.")],
        ["TrainerBattleBGM",  BGMProperty,             _INTL("Default BGM for trainer battles on this map.")],
        ["WildVictoryBGM",    BGMProperty,             _INTL("Default BGM played after winning a wild Pokémon battle on this map.")],
        ["TrainerVictoryBGM", BGMProperty,             _INTL("Default BGM played after winning a Trainer battle on this map.")],
        ["WildCaptureME",     MEProperty,              _INTL("Default ME played after catching a wild Pokémon on this map.")],
        ["MapSize",           MapSizeProperty,         _INTL("The width of the map in Town Map squares, and a string indicating which squares are part of this map.")],
        ["Environment",       GameDataProperty.new(:Environment), _INTL("The default battle environment for battles on this map.")],
        ["Flags",             StringListProperty,      _INTL("Words/phrases that distinguish this map from others.")]
      ]
    end

    def initialize(hash)
      @id                   = hash[:id]
      @real_name            = hash[:name]
      @outdoor_map          = hash[:outdoor_map]
      @announce_location    = hash[:announce_location]
      @can_bicycle          = hash[:can_bicycle]
      @always_bicycle       = hash[:always_bicycle]
      @teleport_destination = hash[:teleport_destination]
      @weather              = hash[:weather]
      @town_map_position    = hash[:town_map_position]
      @dive_map_id          = hash[:dive_map_id]
      @dark_map             = hash[:dark_map]
      @safari_map           = hash[:safari_map]
      @snap_edges           = hash[:snap_edges]
      @random_dungeon       = hash[:random_dungeon]
      @battle_background    = hash[:battle_background]
      @wild_battle_BGM      = hash[:wild_battle_BGM]
      @trainer_battle_BGM   = hash[:trainer_battle_BGM]
      @wild_victory_BGM     = hash[:wild_victory_BGM]
      @trainer_victory_BGM  = hash[:trainer_victory_BGM]
      @wild_capture_ME      = hash[:wild_capture_ME]
      @town_map_size        = hash[:town_map_size]
      @battle_environment   = hash[:battle_environment]
      @flags                = hash[:flags] || []
    end

    def property_from_string(str)
      case str
      when "Name"              then return @real_name
      when "Outdoor"           then return @outdoor_map
      when "ShowArea"          then return @announce_location
      when "Bicycle"           then return @can_bicycle
      when "BicycleAlways"     then return @always_bicycle
      when "HealingSpot"       then return @teleport_destination
      when "Weather"           then return @weather
      when "MapPosition"       then return @town_map_position
      when "DiveMap"           then return @dive_map_id
      when "DarkMap"           then return @dark_map
      when "SafariMap"         then return @safari_map
      when "SnapEdges"         then return @snap_edges
      when "Dungeon"           then return @random_dungeon
      when "BattleBack"        then return @battle_background
      when "WildBattleBGM"     then return @wild_battle_BGM
      when "TrainerBattleBGM"  then return @trainer_battle_BGM
      when "WildVictoryBGM"    then return @wild_victory_BGM
      when "TrainerVictoryBGM" then return @trainer_victory_BGM
      when "WildCaptureME"     then return @wild_capture_ME
      when "MapSize"           then return @town_map_size
      when "Environment"       then return @battle_environment
      when "Flags"             then return @flags
      end
      return nil
    end

    # @return [String] the translated name of this map
    def name
      return pbGetMapNameFromId(@id)
    end

    def has_flag?(flag)
      return @flags.any? { |f| f.downcase == flag.downcase }
    end
  end
end
