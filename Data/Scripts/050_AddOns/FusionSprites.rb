module GameData
  class Species
    def self.sprite_bitmap_from_pokemon(pkmn, back = false, species = nil)
      species = pkmn.species if !species
      species = GameData::Species.get(species).id_number # Just to be sure it's a number
      return self.egg_sprite_bitmap(species, pkmn.form) if pkmn.egg?
      if back
        ret = self.back_sprite_bitmap(species)
      else
        ret = self.front_sprite_bitmap(species)
      end
      return ret
    end

    def self.sprite_bitmap_from_pokemon_id(id, back = false)
      if back
        ret = self.back_sprite_bitmap(id)
      else
        ret = self.front_sprite_bitmap(id)
      end
      return ret
    end

    def self.front_sprite_bitmap(dex_number,a=0,b=0,c=0,d=0)  #la méthode est utilisé ailleurs avec d'autres arguments (gender, form, etc.) mais on les veut pas
      if dex_number.is_a?(Symbol)
        dex_number = GameData::Species.get(dex_number).id_number
      end
      filename = self.sprite_filename(dex_number)
      return (filename) ? AnimatedBitmap.new(filename) : nil
    end

    def self.back_sprite_bitmap(dex_number,species=0, form = 0, gender = 0, shiny = false, shadow = false)
      filename = self.sprite_filename(dex_number)
      return (filename) ? AnimatedBitmap.new(filename) : nil
    end

    def self.egg_sprite_bitmap(dex_number, form = 0)
      filename = self.egg_sprite_filename(dex_number, form)
      return (filename) ? AnimatedBitmap.new(filename) : nil
    end

    def self.getSpecialSpriteName(dexNum)
      base_path="Graphics/Battlers/special/"
      case dexNum
      when Settings::ZAPMOLCUNO_NB..Settings::ZAPMOLCUNO_NB+1
        return sprintf(base_path + "144.145.146")
      when Settings::ZAPMOLCUNO_NB+2
        return sprintf(base_path + "243.244.245")
      when Settings::ZAPMOLCUNO_NB+3
        return sprintf(base_path +"340.341.342")
      when Settings::ZAPMOLCUNO_NB+4
        return sprintf(base_path +"343.344.345")
      when Settings::ZAPMOLCUNO_NB+5
        return sprintf(base_path +"349.350.351")
      when Settings::ZAPMOLCUNO_NB+6
        return sprintf(base_path +"151.251.381")
        #starters
      when Settings::ZAPMOLCUNO_NB+7
        return sprintf(base_path +"3.6.9")
      when Settings::ZAPMOLCUNO_NB+8
        return sprintf(base_path +"154.157.160")
      when Settings::ZAPMOLCUNO_NB+9
        return sprintf(base_path +"278.281.284")
      when Settings::ZAPMOLCUNO_NB+10
        return sprintf(base_path +"318.321.324")
      else
        return sprintf(base_path + "000")
      end
    end

    def self.sprite_filename(dex_number)
      return nil if dex_number == nil
      if dex_number <= Settings::NB_POKEMON
        folder = dex_number.to_s
        filename = sprintf("%s.png", dex_number)
      else
        if dex_number >=Settings::ZAPMOLCUNO_NB
          specialPath = getSpecialSpriteName(dex_number)
          return pbResolveBitmap(specialPath)
        else
          body_id = getBodyID(dex_number)
          head_id = getHeadID(dex_number, body_id)
          folder = head_id.to_s
          filename = sprintf("%s.%s.png", head_id, body_id)
        end
      end
      customPath = pbResolveBitmap(Settings::CUSTOM_BATTLERS_FOLDER + filename)
      regularPath = Settings::BATTLERS_FOLDER + folder + "/" + filename
      return customPath ? customPath : pbResolveBitmap(regularPath)
    end

  end
end