module GameData
  class Species
    def self.sprite_bitmap_from_pokemon(pkmn, back = false, species = nil)
      species = pkmn.species if !species
      species = GameData::Species.get(species).id_number # Just to be sure it's a number
      return self.egg_sprite_bitmap(species, pkmn.form) if pkmn.egg?
      if back
        ret = self.back_sprite_bitmap(species, nil, nil, pkmn.shiny?,pkmn.bodyShiny?,pkmn.headShiny?)
      else
        ret = self.front_sprite_bitmap(species, nil, nil, pkmn.shiny?,pkmn.bodyShiny?,pkmn.headShiny?)
      end
      return ret
    end

    def self.sprite_bitmap_from_pokemon_id(id, back = false, shiny=false, bodyShiny=false,headShiny=false)
      if back
        ret = self.back_sprite_bitmap(id,nil,nil,shiny,bodyShiny,headShiny)
      else
        ret = self.front_sprite_bitmap(id,nil,nil,shiny,bodyShiny,headShiny)
      end
      return ret
    end

    MAX_SHIFT_VALUE = 360
    MINIMUM_OFFSET=40
    ADDITIONAL_OFFSET_WHEN_TOO_CLOSE=40
    MINIMUM_DEX_DIF=20

    def self.calculateShinyHueOffset(dex_number, isBodyShiny = false, isHeadShiny = false)
      if dex_number <= NB_POKEMON
        if SHINY_COLOR_OFFSETS[dex_number]
          return SHINY_COLOR_OFFSETS[dex_number]
        end
        body_number = dex_number
        head_number=dex_number

        else
        body_number = getBodyID(dex_number)
        head_number=getHeadID(dex_number,body_number)
      end
      if isBodyShiny && isHeadShiny && SHINY_COLOR_OFFSETS[body_number]  && SHINY_COLOR_OFFSETS[head_number]
        offset = SHINY_COLOR_OFFSETS[body_number] + SHINY_COLOR_OFFSETS[head_number]
      elsif isHeadShiny && SHINY_COLOR_OFFSETS[head_number]
        offset = SHINY_COLOR_OFFSETS[head_number]
      elsif isBodyShiny && SHINY_COLOR_OFFSETS[body_number]
        offset = SHINY_COLOR_OFFSETS[body_number]
      else
        offset = calculateShinyHueOffsetDefaultMethod(body_number,head_number,dex_number,isBodyShiny,isHeadShiny)
      end
      return offset
    end


    def self.calculateShinyHueOffsetDefaultMethod(body_number,head_number,dex_number, isBodyShiny = false, isHeadShiny = false)
      dex_offset = dex_number
      #body_number = getBodyID(dex_number)
      #head_number=getHeadID(dex_number,body_number)
      dex_diff = (body_number-head_number).abs
      if isBodyShiny && isHeadShiny
        dex_offset = dex_number
      elsif isHeadShiny
        dex_offset = head_number
      elsif isBodyShiny
        dex_offset = dex_diff > MINIMUM_DEX_DIF ? body_number : body_number+ADDITIONAL_OFFSET_WHEN_TOO_CLOSE
      end
      offset = dex_offset + Settings::SHINY_HUE_OFFSET
      offset /= MAX_SHIFT_VALUE if offset > NB_POKEMON
      offset = MINIMUM_OFFSET if offset < MINIMUM_OFFSET
      offset = MINIMUM_OFFSET if (MAX_SHIFT_VALUE - offset).abs < MINIMUM_OFFSET
      offset += pbGet(VAR_SHINY_HUE_OFFSET) #for testing - always 0 during normal gameplay
      return offset
    end

    def self.front_sprite_bitmap(dex_number, a = 0, b = 0, isShiny = false, bodyShiny = false, headShiny = false)
      #la méthode est utilisé ailleurs avec d'autres arguments (gender, form, etc.) mais on les veut pas
      if dex_number.is_a?(Symbol)
        dex_number = GameData::Species.get(dex_number).id_number
      end
      filename = self.sprite_filename(dex_number)
      sprite = (filename) ? AnimatedBitmap.new(filename) : nil
      if isShiny
      sprite.shiftColors(self.calculateShinyHueOffset(dex_number, bodyShiny, headShiny))
      end
      return sprite
    end

    def self.back_sprite_bitmap(dex_number, b = 0, form = 0, isShiny = false, bodyShiny = false, headShiny = false)
      filename = self.sprite_filename(dex_number)
      sprite = (filename) ? AnimatedBitmap.new(filename) : nil
      if isShiny
        sprite.shiftColors(self.calculateShinyHueOffset(dex_number, bodyShiny, headShiny))
      end
      return sprite
    end

    def self.egg_sprite_bitmap(dex_number, form = 0)
      filename = self.egg_sprite_filename(dex_number, form)
      return (filename) ? AnimatedBitmap.new(filename) : nil
    end

    def self.getSpecialSpriteName(dexNum)
      base_path = "Graphics/Battlers/special/"
      case dexNum
      when Settings::ZAPMOLCUNO_NB..Settings::ZAPMOLCUNO_NB + 1
        return sprintf(base_path + "144.145.146")
      when Settings::ZAPMOLCUNO_NB + 2
        return sprintf(base_path + "243.244.245")
      when Settings::ZAPMOLCUNO_NB + 3
        return sprintf(base_path +"340.341.342")
      when Settings::ZAPMOLCUNO_NB + 4
        return sprintf(base_path +"343.344.345")
      when Settings::ZAPMOLCUNO_NB + 5
        return sprintf(base_path +"349.350.351")
      when Settings::ZAPMOLCUNO_NB + 6
        return sprintf(base_path +"151.251.381")
      when Settings::ZAPMOLCUNO_NB + 11
        return sprintf(base_path +"150.348.380")
        #starters
      when Settings::ZAPMOLCUNO_NB + 7
        return sprintf(base_path +"3.6.9")
      when Settings::ZAPMOLCUNO_NB + 8
        return sprintf(base_path +"154.157.160")
      when Settings::ZAPMOLCUNO_NB + 9
        return sprintf(base_path +"278.281.284")
      when Settings::ZAPMOLCUNO_NB + 10
        return sprintf(base_path +"318.321.324")
        #starters prevos
      when Settings::ZAPMOLCUNO_NB + 12
        return sprintf(base_path +"1.4.7")
      when Settings::ZAPMOLCUNO_NB + 13
        return sprintf(base_path +"2.5.8")
      when Settings::ZAPMOLCUNO_NB + 14
        return sprintf(base_path +"152.155.158")
      when Settings::ZAPMOLCUNO_NB + 15
        return sprintf(base_path +"153.156.159")
      when Settings::ZAPMOLCUNO_NB + 16
        return sprintf(base_path +"276.279.282")
      when Settings::ZAPMOLCUNO_NB + 17
        return sprintf(base_path +"277.280.283")
      when Settings::ZAPMOLCUNO_NB + 18
        return sprintf(base_path +"316.319.322")
      when Settings::ZAPMOLCUNO_NB + 19
        return sprintf(base_path +"317.320.323")
      when Settings::ZAPMOLCUNO_NB + 20 #birdBoss Left
        return sprintf(base_path +"invisible")
      when Settings::ZAPMOLCUNO_NB + 21 #birdBoss middle
        return sprintf(base_path + "144.145.146")
      when Settings::ZAPMOLCUNO_NB + 22 #birdBoss right
        return sprintf(base_path +"invisible")
      when Settings::ZAPMOLCUNO_NB + 23 #sinnohboss left
        return sprintf(base_path +"invisible")
      when Settings::ZAPMOLCUNO_NB + 24 #sinnohboss middle
        return sprintf(base_path +"343.344.345")
      when Settings::ZAPMOLCUNO_NB + 25 #sinnohboss right
        return sprintf(base_path +"invisible")
      else
        return sprintf(base_path + "000")
      end
    end

    def self.sprite_filename(dex_number)
      return nil if dex_number == nil
      if dex_number <= Settings::NB_POKEMON
        folder = dex_number.to_s
        filename = sprintf("%s.png", dex_number)
        head_id=nil
      else
        if dex_number >= Settings::ZAPMOLCUNO_NB
          specialPath = getSpecialSpriteName(dex_number)
          return pbResolveBitmap(specialPath)
          head_id=nil
        else
          body_id = getBodyID(dex_number)
          head_id = getHeadID(dex_number, body_id)
          folder = head_id.to_s
          filename = sprintf("%s.%s.png", head_id, body_id)
        end
      end
      customPath = pbResolveBitmap(Settings::CUSTOM_BATTLERS_FOLDER + "/" + head_id.to_s + "/" +filename)
      species = getSpecies(dex_number)
      use_custom = customPath && !species.always_use_generated
      if use_custom
        return customPath
      end
      return Settings::BATTLERS_FOLDER + folder + "/" + filename
    end

  end
end