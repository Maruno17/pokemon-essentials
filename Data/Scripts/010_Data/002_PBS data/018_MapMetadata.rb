#===============================================================================
#
#===============================================================================
module GameData
  class MapMetadata
    attr_reader :id
    attr_reader :real_name
    attr_reader :town_map_position
    attr_reader :town_map_size
    attr_reader :outdoor_map
    attr_reader :announce_location
    attr_reader :location_sign
    attr_reader :can_bicycle
    attr_reader :always_bicycle
    attr_reader :weather
    attr_reader :no_reflections
    attr_reader :still_reflections
    attr_reader :dive_map_id
    attr_reader :teleport_destination
    attr_reader :dark_map
    attr_reader :safari_map
    attr_reader :random_dungeon
    attr_reader :snap_edges
    attr_reader :battle_background
    attr_reader :battle_environment
    attr_reader :wild_battle_BGM
    attr_reader :trainer_battle_BGM
    attr_reader :wild_victory_BGM
    attr_reader :trainer_victory_BGM
    attr_reader :wild_capture_ME
    attr_reader :flags
    attr_reader :pbs_file_suffix

    DATA = {}
    DATA_FILENAME = "map_metadata.dat"
    PBS_BASE_FILENAME = "map_metadata"
    SCHEMA = {
      "SectionName"       => [:id,                   "u"],
      "Name"              => [:real_name,            "s"],
      "MapPosition"       => [:town_map_position,    "uuu"],
      "MapSize"           => [:town_map_size,        "us"],
      "Outdoor"           => [:outdoor_map,          "b"],
      "ShowArea"          => [:announce_location,    "b"],
      "LocationSign"      => [:location_sign,        "s"],
      "Bicycle"           => [:can_bicycle,          "b"],
      "BicycleAlways"     => [:always_bicycle,       "b"],
      "Weather"           => [:weather,              "eu", :Weather],
      "NoReflections"     => [:no_reflections,       "b"],
      "StillReflections"  => [:still_reflections,    "b"],
      "DiveMap"           => [:dive_map_id,          "v"],
      "HealingSpot"       => [:teleport_destination, "vuu"],
      "DarkMap"           => [:dark_map,             "b"],
      "SafariMap"         => [:safari_map,           "b"],
      "Dungeon"           => [:random_dungeon,       "b"],
      "SnapEdges"         => [:snap_edges,           "b"],
      "BattleBack"        => [:battle_background,    "s"],
      "Environment"       => [:battle_environment,   "e", :Environment],
      "WildBattleBGM"     => [:wild_battle_BGM,      "s"],
      "TrainerBattleBGM"  => [:trainer_battle_BGM,   "s"],
      "WildVictoryBGM"    => [:wild_victory_BGM,     "s"],
      "TrainerVictoryBGM" => [:trainer_victory_BGM,  "s"],
      "WildCaptureME"     => [:wild_capture_ME,      "s"],
      "Flags"             => [:flags,                "*s"]
    }

    extend ClassMethodsIDNumbers
    include InstanceMethods

    def self.editor_properties
      return [
        ["ID",                ReadOnlyProperty,        _INTL("ID number of this map.")],
        ["Name",              StringProperty,          _INTL("The name of the map, as seen by the player. Can be different to the map's name as seen in RMXP.")],
        ["MapPosition",       RegionMapCoordsProperty, _INTL("Identifies the point on the regional map for this map.")],
        ["MapSize",           MapSizeProperty,         _INTL("The width of the map in Town Map squares, and a string indicating which squares are part of this map.")],
        ["Outdoor",           BooleanProperty,         _INTL("If true, this map is an outdoor map and will be tinted according to time of day.")],
        ["ShowArea",          BooleanProperty,         _INTL("If true, the game will display the map's name upon entry.")],
        ["LocationSign",      StringProperty,          _INTL("Filename in 'Graphics/UI/Location/' to be used as the location sign.")],
        ["Bicycle",           BooleanProperty,         _INTL("If true, the bicycle can be used on this map.")],
        ["BicycleAlways",     BooleanProperty,         _INTL("If true, the bicycle will be mounted automatically on this map and cannot be dismounted.")],
        ["Weather",           WeatherEffectProperty,   _INTL("Weather conditions in effect for this map.")],
        ["NoReflections",     BooleanProperty,         _INTL("If true, reflections of events and the player will not be shown.")],
        ["StillReflections",  BooleanProperty,         _INTL("If true, reflections of events and the player will not ripple horizontally.")],
        ["DiveMap",           MapProperty,             _INTL("Specifies the underwater layer of this map. Use only if this map has deep water.")],
        ["HealingSpot",       MapCoordsProperty,       _INTL("Map ID of this Pokémon Center's town, and X and Y coordinates of its entrance within that town.")],
        ["DarkMap",           BooleanProperty,         _INTL("If true, this map is dark and a circle of light appears around the player. Flash can be used to expand the circle.")],
        ["SafariMap",         BooleanProperty,         _INTL("If true, this map is part of the Safari Zone (both indoor and outdoor). Not to be used in the reception desk.")],
        ["Dungeon",           BooleanProperty,         _INTL("If true, this map has a randomly generated layout. See the wiki for more information.")],
        ["SnapEdges",         BooleanProperty,         _INTL("If true, when the player goes near this map's edge, the game doesn't center the player as usual.")],
        ["BattleBack",        StringProperty,          _INTL("PNG files named 'XXX_bg', 'XXX_base0', 'XXX_base1', 'XXX_message' in Battlebacks folder, where XXX is this property's value.")],
        ["Environment",       GameDataProperty.new(:Environment), _INTL("The default battle environment for battles on this map.")],
        ["WildBattleBGM",     BGMProperty,             _INTL("Default BGM for wild Pokémon battles on this map.")],
        ["TrainerBattleBGM",  BGMProperty,             _INTL("Default BGM for trainer battles on this map.")],
        ["WildVictoryBGM",    BGMProperty,             _INTL("Default BGM played after winning a wild Pokémon battle on this map.")],
        ["TrainerVictoryBGM", BGMProperty,             _INTL("Default BGM played after winning a Trainer battle on this map.")],
        ["WildCaptureME",     MEProperty,              _INTL("Default ME played after catching a wild Pokémon on this map.")],
        ["Flags",             StringListProperty,      _INTL("Words/phrases that distinguish this map from others.")]
      ]
    end

    #---------------------------------------------------------------------------

    def initialize(hash)
      @id                   = hash[:id]
      @real_name            = hash[:real_name]
      @town_map_position    = hash[:town_map_position]
      @town_map_size        = hash[:town_map_size]
      @outdoor_map          = hash[:outdoor_map]
      @announce_location    = hash[:announce_location]
      @location_sign        = hash[:location_sign]
      @can_bicycle          = hash[:can_bicycle]
      @always_bicycle       = hash[:always_bicycle]
      @weather              = hash[:weather]
      @no_reflections       = hash[:no_reflections]
      @still_reflections    = hash[:still_reflections]
      @dive_map_id          = hash[:dive_map_id]
      @teleport_destination = hash[:teleport_destination]
      @dark_map             = hash[:dark_map]
      @safari_map           = hash[:safari_map]
      @random_dungeon       = hash[:random_dungeon]
      @snap_edges           = hash[:snap_edges]
      @battle_background    = hash[:battle_background]
      @battle_environment   = hash[:battle_environment]
      @wild_battle_BGM      = hash[:wild_battle_BGM]
      @trainer_battle_BGM   = hash[:trainer_battle_BGM]
      @wild_victory_BGM     = hash[:wild_victory_BGM]
      @trainer_victory_BGM  = hash[:trainer_victory_BGM]
      @wild_capture_ME      = hash[:wild_capture_ME]
      @flags                = hash[:flags]           || []
      @pbs_file_suffix      = hash[:pbs_file_suffix] || ""
    end

    # @return [String] the translated name of this map
    def name
      ret = pbGetMessageFromHash(MessageTypes::MAP_NAMES, @real_name)
      ret = pbGetBasicMapNameFromId(@id) if nil_or_empty?(ret)
      ret.gsub!(/\\PN/, $player.name) if $player
      return ret
    end

    def has_flag?(flag)
      return @flags.any? { |f| f.downcase == flag.downcase }
    end

    alias __orig__get_property_for_PBS get_property_for_PBS unless method_defined?(:__orig__get_property_for_PBS)
    def get_property_for_PBS(key)
      key = "SectionName" if key == "ID"
      return __orig__get_property_for_PBS(key)
    end
  end
end
