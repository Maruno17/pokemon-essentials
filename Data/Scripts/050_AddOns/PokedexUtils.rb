class PokedexUtils
  POSSIBLE_ALTS = %w[a b c d e f g h i j k x]

  def pbGetAvailableAlts(species)
    ret = []
    return ret if !species
    dexNum = getDexNumberForSpecies(species)
    isFusion = dexNum > NB_POKEMON
    if !isFusion
      ret << Settings::BATTLERS_FOLDER + dexNum.to_s + "/" + dexNum.to_s + ".png"
      return ret
    end
    body_id = getBodyID(species)
    head_id = getHeadID(species, body_id)

    baseFilename = head_id.to_s + "." + body_id.to_s
    baseFilePath = Settings::CUSTOM_BATTLERS_FOLDER_INDEXED + head_id.to_s + "/" + baseFilename + ".png"
    if pbResolveBitmap(baseFilePath)
      ret << baseFilePath
    end
    POSSIBLE_ALTS.each { |alt_letter|
      altFilePath = Settings::CUSTOM_BATTLERS_FOLDER_INDEXED + head_id.to_s + "/" + baseFilename + alt_letter + ".png"
      if pbResolveBitmap(altFilePath)
        ret << altFilePath
      end
    }
    ret << Settings::BATTLERS_FOLDER + head_id.to_s + "/" + baseFilename + ".png"
    return ret
  end


  #todo: return array for split evolution lines that have multiple final evos
  def getFinalEvolution(species)
    #ex: [[B3H4,Level 32],[B2H5, Level 35]]
    evolution_line = species.get_evolutions
    return species if evolution_line.empty?
    finalEvoId = evolution_line[0][0]
    return evolution_line[]
    for evolution in evolution_line
      evoSpecies = evolution[0]
      p GameData::Species.get(evoSpecies).get_evolutions
      isFinalEvo = GameData::Species.get(evoSpecies).get_evolutions.empty?
      return evoSpecies if isFinalEvo
    end
    return nil
  end

end
