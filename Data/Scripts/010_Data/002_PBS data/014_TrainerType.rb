module GameData
  class TrainerType
    attr_reader :id
    attr_reader :real_name
    attr_reader :gender
    attr_reader :base_money
    attr_reader :skill_level
    attr_reader :flags
    attr_reader :intro_BGM
    attr_reader :battle_BGM
    attr_reader :victory_BGM
    attr_reader :pbs_file_suffix

    DATA = {}
    DATA_FILENAME = "trainer_types.dat"
    PBS_BASE_FILENAME = "trainer_types"

    SCHEMA = {
      "SectionName" => [:id,          "m"],
      "Name"        => [:real_name,   "s"],
      "Gender"      => [:gender,      "e", {"Male" => 0, "male" => 0, "M" => 0, "m" => 0, "0" => 0,
                                            "Female" => 1, "female" => 1, "F" => 1, "f" => 1, "1" => 1,
                                            "Unknown" => 2, "unknown" => 2, "Other" => 2, "other" => 2,
                                            "Mixed" => 2, "mixed" => 2, "X" => 2, "x" => 2, "2" => 2}],
      "BaseMoney"   => [:base_money,  "u"],
      "SkillLevel"  => [:skill_level, "u"],
      "Flags"       => [:flags,       "*s"],
      "IntroBGM"    => [:intro_BGM,   "s"],
      "BattleBGM"   => [:battle_BGM,  "s"],
      "VictoryBGM"  => [:victory_BGM, "s"]
    }

    extend ClassMethodsSymbols
    include InstanceMethods

    def self.editor_properties
      gender_array = []
      self.schema["Gender"][2].each { |key, value| gender_array[value] = key if !gender_array[value] }
      return [
        ["ID",         ReadOnlyProperty,               _INTL("ID of this Trainer Type (used as a symbol like :XXX).")],
        ["Name",       StringProperty,                 _INTL("Name of this Trainer Type as displayed by the game.")],
        ["Gender",     EnumProperty.new(gender_array), _INTL("Gender of this Trainer Type.")],
        ["BaseMoney",  LimitProperty.new(9999),        _INTL("Player earns this much money times the highest level among the trainer's Pokémon.")],
        ["SkillLevel", LimitProperty2.new(9999),       _INTL("Skill level of this Trainer Type.")],
        ["Flags",      StringListProperty,             _INTL("Words/phrases that can be used to make trainers of this type behave differently to others.")],
        ["IntroBGM",   BGMProperty,                    _INTL("BGM played before battles against trainers of this type.")],
        ["BattleBGM",  BGMProperty,                    _INTL("BGM played in battles against trainers of this type.")],
        ["VictoryBGM", BGMProperty,                    _INTL("BGM played when player wins battles against trainers of this type.")]
      ]
    end

    def self.check_file(tr_type, path, optional_suffix = "", suffix = "")
      tr_type_data = self.try_get(tr_type)
      return nil if tr_type_data.nil?
      # Check for files
      if optional_suffix && !optional_suffix.empty?
        ret = path + tr_type_data.id.to_s + optional_suffix + suffix
        return ret if pbResolveBitmap(ret)
      end
      ret = path + tr_type_data.id.to_s + suffix
      return (pbResolveBitmap(ret)) ? ret : nil
    end

    def self.charset_filename(tr_type)
      return self.check_file(tr_type, "Graphics/Characters/trainer_")
    end

    def self.charset_filename_brief(tr_type)
      ret = self.charset_filename(tr_type)
      ret&.slice!("Graphics/Characters/")
      return ret
    end

    def self.front_sprite_filename(tr_type)
      return self.check_file(tr_type, "Graphics/Trainers/")
    end

    def self.player_front_sprite_filename(tr_type)
      outfit = ($player) ? $player.outfit : 0
      return self.check_file(tr_type, "Graphics/Trainers/", sprintf("_%d", outfit))
    end

    def self.back_sprite_filename(tr_type)
      return self.check_file(tr_type, "Graphics/Trainers/", "", "_back")
    end

    def self.player_back_sprite_filename(tr_type)
      outfit = ($player) ? $player.outfit : 0
      return self.check_file(tr_type, "Graphics/Trainers/", sprintf("_%d", outfit), "_back")
    end

    def self.map_icon_filename(tr_type)
      return self.check_file(tr_type, "Graphics/UI/Town Map/player_")
    end

    def self.player_map_icon_filename(tr_type)
      outfit = ($player) ? $player.outfit : 0
      return self.check_file(tr_type, "Graphics/UI/Town Map/player_", sprintf("_%d", outfit))
    end

    def initialize(hash)
      @id              = hash[:id]
      @real_name       = hash[:real_name]       || "Unnamed"
      @gender          = hash[:gender]          || 2
      @base_money      = hash[:base_money]      || 30
      @skill_level     = hash[:skill_level]     || @base_money
      @flags           = hash[:flags]           || []
      @intro_BGM       = hash[:intro_BGM]
      @battle_BGM      = hash[:battle_BGM]
      @victory_BGM     = hash[:victory_BGM]
      @pbs_file_suffix = hash[:pbs_file_suffix] || ""
    end

    # @return [String] the translated name of this trainer type
    def name
      return pbGetMessageFromHash(MessageTypes::TRAINER_TYPE_NAMES, @real_name)
    end

    def male?;   return @gender == 0; end
    def female?; return @gender == 1; end

    def has_flag?(flag)
      return @flags.any? { |f| f.downcase == flag.downcase }
    end

    alias __orig__get_property_for_PBS get_property_for_PBS unless method_defined?(:__orig__get_property_for_PBS)
    def get_property_for_PBS(key)
      key = "SectionName" if key == "ID"
      ret = __orig__get_property_for_PBS(key)
      ret = nil if key == "SkillLevel" && ret == @base_money
      return ret
    end
  end
end
