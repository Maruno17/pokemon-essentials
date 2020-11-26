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
    attr_reader :player_A
    attr_reader :player_B
    attr_reader :player_C
    attr_reader :player_D
    attr_reader :player_E
    attr_reader :player_F
    attr_reader :player_G
    attr_reader :player_H

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
      "BicycleBGM"       => [8,  "s"],
      "PlayerA"          => [9,  "esssssss", :PBTrainers],
      "PlayerB"          => [10, "esssssss", :PBTrainers],
      "PlayerC"          => [11, "esssssss", :PBTrainers],
      "PlayerD"          => [12, "esssssss", :PBTrainers],
      "PlayerE"          => [13, "esssssss", :PBTrainers],
      "PlayerF"          => [14, "esssssss", :PBTrainers],
      "PlayerG"          => [15, "esssssss", :PBTrainers],
      "PlayerH"          => [16, "esssssss", :PBTrainers]
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
         ["BicycleBGM",       BGMProperty,             _INTL("BGM played while on a bicycle.")],
         ["PlayerA",          PlayerProperty,          _INTL("Specifies player A.")],
         ["PlayerB",          PlayerProperty,          _INTL("Specifies player B.")],
         ["PlayerC",          PlayerProperty,          _INTL("Specifies player C.")],
         ["PlayerD",          PlayerProperty,          _INTL("Specifies player D.")],
         ["PlayerE",          PlayerProperty,          _INTL("Specifies player E.")],
         ["PlayerF",          PlayerProperty,          _INTL("Specifies player F.")],
         ["PlayerG",          PlayerProperty,          _INTL("Specifies player G.")],
         ["PlayerH",          PlayerProperty,          _INTL("Specifies player H.")]
      ]
    end

    def self.get
      return DATA[0]
    end

    def self.get_player(id)
      case id
      when 0 then return self.get.player_A
      when 1 then return self.get.player_B
      when 2 then return self.get.player_C
      when 3 then return self.get.player_D
      when 4 then return self.get.player_E
      when 5 then return self.get.player_F
      when 6 then return self.get.player_G
      when 7 then return self.get.player_H
      end
      return nil
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
      @player_A            = hash[:player_A]
      @player_B            = hash[:player_B]
      @player_C            = hash[:player_C]
      @player_D            = hash[:player_D]
      @player_E            = hash[:player_E]
      @player_F            = hash[:player_F]
      @player_G            = hash[:player_G]
      @player_H            = hash[:player_H]
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
      when "PlayerA"          then return @player_A
      when "PlayerB"          then return @player_B
      when "PlayerC"          then return @player_C
      when "PlayerD"          then return @player_D
      when "PlayerE"          then return @player_E
      when "PlayerF"          then return @player_F
      when "PlayerG"          then return @player_G
      when "PlayerH"          then return @player_H
      end
      return nil
    end
  end
end

#===============================================================================
# Deprecated methods
#===============================================================================
def pbLoadMetadata
  Deprecation.warn_method('pbLoadMetadata', 'v20', 'GameData::Metadata.get or GameData::MapMetadata.get(map_id)')
  return nil
end

def pbGetMetadata(map_id, metadata_type)
  if map_id == 0   # Global metadata
    Deprecation.warn_method('pbGetMetadata', 'v20', 'GameData::Metadata.get.something')
    ret = GameData::Metadata.get
    case metadata_type
    when Metadata::HOME               then return ret.home
    when Metadata::WILD_BATTLE_BGM    then return ret.wild_battle_BGM
    when Metadata::TRAINER_BATTLE_BGM then return ret.trainer_battle_BGM
    when Metadata::WILD_VICTORY_ME    then return ret.wild_victory_ME
    when Metadata::TRAINER_VICTORY_ME then return ret.trainer_victory_ME
    when Metadata::WILD_CAPTURE_ME    then return ret.wild_capture_ME
    when Metadata::SURF_BGM           then return ret.surf_BGM
    when Metadata::BICYCLE_BGM        then return ret.bicycle_BGM
    when Metadata::PLAYER_A           then return ret.player_A
    when Metadata::PLAYER_B           then return ret.player_B
    when Metadata::PLAYER_C           then return ret.player_C
    when Metadata::PLAYER_D           then return ret.player_D
    when Metadata::PLAYER_E           then return ret.player_E
    when Metadata::PLAYER_F           then return ret.player_F
    when Metadata::PLAYER_G           then return ret.player_G
    when Metadata::PLAYER_H           then return ret.player_H
    end
  else   # Map metadata
    Deprecation.warn_method('pbGetMetadata', 'v20', 'GameData::MapMetadata.get(map_id).something')
    ret = GameData::MapMetadata.get(map_id)
    case metadata_type
    when MapMetadata::OUTDOOR            then return ret.outdoor_map
    when MapMetadata::SHOW_AREA          then return ret.announce_location
    when MapMetadata::BICYCLE            then return ret.can_bicycle
    when MapMetadata::BICYCLE_ALWAYS     then return ret.always_bicycle
    when MapMetadata::HEALING_SPOT       then return ret.teleport_destination
    when MapMetadata::WEATHER            then return ret.weather
    when MapMetadata::MAP_POSITION       then return ret.town_map_position
    when MapMetadata::DIVE_MAP           then return ret.dive_map_id
    when MapMetadata::DARK_MAP           then return ret.dark_map
    when MapMetadata::SAFARI_MAP         then return ret.safari_map
    when MapMetadata::SNAP_EDGES         then return ret.snap_edges
    when MapMetadata::DUNGEON            then return ret.random_dungeon
    when MapMetadata::BATTLE_BACK        then return ret.battle_background
    when MapMetadata::WILD_BATTLE_BGM    then return ret.wild_battle_BGM
    when MapMetadata::TRAINER_BATTLE_BGM then return ret.trainer_battle_BGM
    when MapMetadata::WILD_VICTORY_ME    then return ret.wild_victory_ME
    when MapMetadata::TRAINER_VICTORY_ME then return ret.trainer_victory_ME
    when MapMetadata::WILD_CAPTURE_ME    then return ret.wild_capture_ME
    when MapMetadata::MAP_SIZE           then return ret.town_map_size
    when MapMetadata::ENVIRONMENT        then return ret.battle_environment
    end
  end
  return nil
end

module Metadata
  HOME               = 1
  WILD_BATTLE_BGM    = 2
  TRAINER_BATTLE_BGM = 3
  WILD_VICTORY_ME    = 4
  TRAINER_VICTORY_ME = 5
  WILD_CAPTURE_ME    = 6
  SURF_BGM           = 7
  BICYCLE_BGM        = 8
  PLAYER_A           = 9
  PLAYER_B           = 10
  PLAYER_C           = 11
  PLAYER_D           = 12
  PLAYER_E           = 13
  PLAYER_F           = 14
  PLAYER_G           = 15
  PLAYER_H           = 16
end

module MapMetadata
  OUTDOOR            = 1
  SHOW_AREA          = 2
  BICYCLE            = 3
  BICYCLE_ALWAYS     = 4
  HEALING_SPOT       = 5
  WEATHER            = 6
  MAP_POSITION       = 7
  DIVE_MAP           = 8
  DARK_MAP           = 9
  SAFARI_MAP         = 10
  SNAP_EDGES         = 11
  DUNGEON            = 12
  BATTLE_BACK        = 13
  WILD_BATTLE_BGM    = 14
  TRAINER_BATTLE_BGM = 15
  WILD_VICTORY_ME    = 16
  TRAINER_VICTORY_ME = 17
  WILD_CAPTURE_ME    = 18
  MAP_SIZE           = 19
  ENVIRONMENT        = 20
end
