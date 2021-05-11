module GameData
  class TrainerType
    attr_reader :id
    attr_reader :id_number
    attr_reader :real_name
    attr_reader :base_money
    attr_reader :battle_BGM
    attr_reader :victory_ME
    attr_reader :intro_ME
    attr_reader :gender
    attr_reader :skill_level
    attr_reader :skill_code

    DATA = {}
    DATA_FILENAME = "trainer_types.dat"

    extend ClassMethods
    include InstanceMethods

    def self.check_file(tr_type, path, optional_suffix = "", suffix = "")
      tr_type_data = self.try_get(tr_type)
      return nil if tr_type_data.nil?
      # Check for files
      if optional_suffix && !optional_suffix.empty?
        ret = path + tr_type_data.id.to_s + optional_suffix + suffix
        return ret if pbResolveBitmap(ret)
        ret = path + sprintf("%03d", tr_type_data.id_number) + optional_suffix + suffix
        return ret if pbResolveBitmap(ret)
      end
      ret = path + tr_type_data.id.to_s + suffix
      return ret if pbResolveBitmap(ret)
      ret = path + sprintf("%03d", tr_type_data.id_number) + suffix
      return (pbResolveBitmap(ret)) ? ret : nil
    end

    def self.charset_filename(tr_type)
      return self.check_file(tr_type, "Graphics/Characters/trainer_")
    end

    def self.charset_filename_brief(tr_type)
      ret = self.charset_filename(tr_type)
      ret.slice!("Graphics/Characters/") if ret
      return ret
    end

    def self.front_sprite_filename(tr_type)
      return self.check_file(tr_type, "Graphics/Trainers/")
    end

    def self.player_front_sprite_filename(tr_type)
      outfit = ($Trainer) ? $Trainer.outfit : 0
      return self.check_file(tr_type, "Graphics/Trainers/", sprintf("_%d", outfit))
    end

    def self.back_sprite_filename(tr_type)
      return self.check_file(tr_type, "Graphics/Trainers/", "", "_back")
    end

    def self.player_back_sprite_filename(tr_type)
      outfit = ($Trainer) ? $Trainer.outfit : 0
      return self.check_file(tr_type, "Graphics/Trainers/", sprintf("_%d", outfit), "_back")
    end

    def self.map_icon_filename(tr_type)
      return self.check_file(tr_type, "Graphics/Pictures/mapPlayer")
    end

    def self.player_map_icon_filename(tr_type)
      outfit = ($Trainer) ? $Trainer.outfit : 0
      return self.check_file(tr_type, "Graphics/Pictures/mapPlayer", sprintf("_%d", outfit))
    end

    def initialize(hash)
      @id          = hash[:id]
      @id_number   = hash[:id_number]   || -1
      @real_name   = hash[:name]        || "Unnamed"
      @base_money  = hash[:base_money]  || 30
      @battle_BGM  = hash[:battle_BGM]
      @victory_ME  = hash[:victory_ME]
      @intro_ME    = hash[:intro_ME]
      @gender      = hash[:gender]      || 2
      @skill_level = hash[:skill_level] || @base_money
      @skill_code  = hash[:skill_code]
    end

    # @return [String] the translated name of this trainer type
    def name
      return pbGetMessage(MessageTypes::TrainerTypes, @id_number)
    end

    def male?;   return @gender == 0; end
    def female?; return @gender == 1; end
  end
end

#===============================================================================
# Deprecated methods
#===============================================================================
# @deprecated This alias is slated to be removed in v20.
def pbGetTrainerTypeData(tr_type)
  Deprecation.warn_method('pbGetTrainerTypeData', 'v20', 'GameData::TrainerType.get(trainer_type)')
  return GameData::TrainerType.get(tr_type)
end

# @deprecated This alias is slated to be removed in v20.
def pbTrainerCharFile(tr_type)   # Used by the phone
  Deprecation.warn_method('pbTrainerCharFile', 'v20', 'GameData::TrainerType.charset_filename(trainer_type)')
  return GameData::TrainerType.charset_filename(tr_type)
end

# @deprecated This alias is slated to be removed in v20.
def pbTrainerCharNameFile(tr_type)   # Used by Battle Frontier and compiler
  Deprecation.warn_method('pbTrainerCharNameFile', 'v20', 'GameData::TrainerType.charset_filename_brief(trainer_type)')
  return GameData::TrainerType.charset_filename_brief(tr_type)
end

# @deprecated This alias is slated to be removed in v20.
def pbTrainerSpriteFile(tr_type)
  Deprecation.warn_method('pbTrainerSpriteFile', 'v20', 'GameData::TrainerType.front_sprite_filename(trainer_type)')
  return GameData::TrainerType.front_sprite_filename(tr_type)
end

# @deprecated This alias is slated to be removed in v20.
def pbTrainerSpriteBackFile(tr_type)
  Deprecation.warn_method('pbTrainerSpriteBackFile', 'v20', 'GameData::TrainerType.back_sprite_filename(trainer_type)')
  return GameData::TrainerType.back_sprite_filename(tr_type)
end

# @deprecated This alias is slated to be removed in v20.
def pbPlayerSpriteFile(tr_type)
  Deprecation.warn_method('pbPlayerSpriteFile', 'v20', 'GameData::TrainerType.player_front_sprite_filename(trainer_type)')
  return GameData::TrainerType.player_front_sprite_filename(tr_type)
end

# @deprecated This alias is slated to be removed in v20.
def pbPlayerSpriteBackFile(tr_type)
  Deprecation.warn_method('pbPlayerSpriteBackFile', 'v20', 'GameData::TrainerType.player_back_sprite_filename(trainer_type)')
  return GameData::TrainerType.player_back_sprite_filename(tr_type)
end

# @deprecated This alias is slated to be removed in v20.
def pbTrainerHeadFile(tr_type)
  Deprecation.warn_method('pbTrainerHeadFile', 'v20', 'GameData::TrainerType.map_icon_filename(trainer_type)')
  return GameData::TrainerType.map_icon_filename(tr_type)
end

# @deprecated This alias is slated to be removed in v20.
def pbPlayerHeadFile(tr_type)
  Deprecation.warn_method('pbPlayerHeadFile', 'v20', 'GameData::TrainerType.player_map_icon_filename(trainer_type)')
  return GameData::TrainerType.player_map_icon_filename(tr_type)
end
