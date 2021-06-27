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

    def self.front_sprite_bitmap(dex_number)
      filename = self.sprite_filename(dex_number)
      return (filename) ? AnimatedBitmap.new(filename) : nil
    end

    def self.back_sprite_bitmap(dex_number)
      filename = self.sprite_filename(dex_number)
      return (filename) ? AnimatedBitmap.new(filename) : nil
    end

    def self.egg_sprite_bitmap(dex_number, form = 0)
      filename = self.egg_sprite_filename(dex_number, form)
      return (filename) ? AnimatedBitmap.new(filename) : nil
    end

    def self.sprite_filename(dex_number)
      if dex_number <= Settings::NB_POKEMON
        folder = dex_number.to_s
        filename = sprintf("%s.png", dex_number)
      else
        body_id = getBodyID(dex_number)
        head_id = getHeadID(dex_number, body_id)
        folder = head_id.to_s
        filename = sprintf("%s.%s.png", head_id, body_id)
      end
      customPath = pbResolveBitmap(Settings::CUSTOM_BATTLERS_FOLDER + filename)
      regularPath = Settings::BATTLERS_FOLDER + folder + "/" + filename
      return customPath ? customPath : pbResolveBitmap(regularPath)
    end

  end
end