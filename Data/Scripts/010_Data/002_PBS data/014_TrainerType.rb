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

    DATA = {}
    DATA_FILENAME = "trainer_types.dat"

    SCHEMA = {
      "Name"       => [:name,        "s"],
      "Gender"     => [:gender,      "e", { "Male" => 0, "male" => 0, "M" => 0, "m" => 0, "0" => 0,
                                           "Female" => 1, "female" => 1, "F" => 1, "f" => 1, "1" => 1,
                                           "Unknown" => 2, "unknown" => 2, "Other" => 2, "other" => 2,
                                           "Mixed" => 2, "mixed" => 2, "X" => 2, "x" => 2, "2" => 2 }],
      "BaseMoney"  => [:base_money,  "u"],
      "SkillLevel" => [:skill_level, "u"],
      "Flags"      => [:flags,       "*s"],
      "IntroBGM"   => [:intro_BGM,   "s"],
      "BattleBGM"  => [:battle_BGM,  "s"],
      "VictoryBGM" => [:victory_BGM, "s"]
    }

    extend ClassMethodsSymbols
    include InstanceMethods

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
      return self.check_file(tr_type, "Graphics/Pictures/mapPlayer")
    end

    def self.player_map_icon_filename(tr_type)
      outfit = ($player) ? $player.outfit : 0
      return self.check_file(tr_type, "Graphics/Pictures/mapPlayer", sprintf("_%d", outfit))
    end

    def initialize(hash)
      @id          = hash[:id]
      @real_name   = hash[:name]        || "Unnamed"
      @gender      = hash[:gender]      || 2
      @base_money  = hash[:base_money]  || 30
      @skill_level = hash[:skill_level] || @base_money
      @flags       = hash[:flags]       || []
      @intro_BGM   = hash[:intro_BGM]
      @battle_BGM  = hash[:battle_BGM]
      @victory_BGM = hash[:victory_BGM]
    end

    # @return [String] the translated name of this trainer type
    def name
      return pbGetMessageFromHash(MessageTypes::TrainerTypes, @real_name)
    end

    def male?;   return @gender == 0; end
    def female?; return @gender == 1; end

    def has_flag?(flag)
      return @flags.any? { |f| f.downcase == flag.downcase }
    end
  end
end
