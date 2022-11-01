
def pbGetTerrainTag()
  return $game_player.pbTerrainTag().id
end


def getLevelAtWhichSpeciesEvolved(species)
  levelAtWhichCurrentSpeciesEvolved=1
  evosArray = species.get_family_evolutions
  for entry in evosArray
    if entry[0] == species.id && entry[1] == :Level
      if entry[2] && entry[2]  < levelAtWhichCurrentSpeciesEvolved
        levelAtWhichCurrentSpeciesEvolved = entry[2]
      end
    end
  end
end


def getNextEvolutions(species, evolutions)
  if !evolutions
    evolutions = species.get_evolutions
  end

  nextEvolutions = []
  currentLowestEvolution = nil
  for evolution in evolutions
    if evolution[1]== :Level
      evoLevel = evolution[2]
      currentLowestLevel = currentLowestEvolution ? currentLowestEvolution[2] : Settings::MAXIMUM_LEVEL
      if evoLevel < currentLowestLevel
        currentLowestEvolution = evolution
      end
    else
      nextEvolutions << evolution
    end
  end
  if currentLowestEvolution != nil
    nextEvolutions << currentLowestEvolution
  end
  return nextEvolutions
end

def extract_custom_sprites_that_evolve_into_non_customs(includeOnlyNextEvos=true)
  outfile = "nonCustomEvos.txt"
  customSpecies = getCustomSpeciesList()

  alreadyWritten = []

  File.open(outfile,"wb") { |f|
    for dexNum in customSpecies
      species = GameData::Species.get(dexNum)
      dex_body = getBodyID(species)
      dex_head = getHeadID(species,dex_body)

      evolutions = species.get_evolutions
      nextEvolutions=evolutions
      if includeOnlyNextEvos
        nextEvolutions = getNextEvolutions(species,evolutions)
      end

      next if nextEvolutions.empty?
      for evolution in nextEvolutions
        evoSpecies = evolution[0]
        if !customSpriteExists(evoSpecies) && !alreadyWritten.include?(evoSpecies)
                  body = getBodyID(evoSpecies)
                  head = getHeadID(evoSpecies,body)
                  f.write((evoSpecies.to_s) +";")
                  f.write((head.to_s) +";")
                  f.write(".;")
                  f.write((body.to_s) +";")
                  f.write("evolves from ;")
                  f.write(species.id.to_s) + ";"
                  f.write((dex_head.to_s) +";")
                  f.write(".;")
                  f.write((dex_body.to_s) +";")
                  f.write("\n")


                  alreadyWritten << evoSpecies
        end
      end
    end
  }

end


def extract_pokes_with_non_custom_final_evos(includeOnlyNextEvos=true)
  outfile = "nonCustomFinals.csv"
  customSpecies = getCustomSpeciesList()

  alreadyWritten = []

  File.open(outfile,"wb") { |f|
    for dexNum in customSpecies
      species = GameData::Species.get(dexNum)
      dex_body = getBodyID(species)
      dex_head = getHeadID(species,dex_body)

      evolutions = species.get_evolutions
      nextEvolutions=evolutions
      if includeOnlyNextEvos
        nextEvolutions = getNextEvolutions(species,evolutions)
      end

      next if nextEvolutions.empty?
      for evolution in nextEvolutions
        evoSpecies = evolution[0]
        isFinalEvo = GameData::Species.get(evoSpecies).get_evolutions.empty?
        if !customSpriteExists(evoSpecies) && !alreadyWritten.include?(evoSpecies) && isFinalEvo
          body = getBodyID(evoSpecies)
          head = getHeadID(evoSpecies,body)
          f.write((evoSpecies.to_s) +";")
          f.write((head.to_s) +";")
          f.write(".;")
          f.write((body.to_s) +";")
          f.write("evolves from ;")
          f.write(species.id.to_s) + ";"
          f.write((dex_head.to_s) +";")
          f.write(".;")
          f.write((dex_body.to_s) +";")
          f.write("\n")


          alreadyWritten << evoSpecies
        end
      end
    end
  }

end





def extract_incomplete_evolution_lines
  outfile = "incompleteLines.txt"
  pokeList = []
  for i in NB_POKEMON+1..PBSpecies.maxValue
    pokeList << i
  end

  to_skip=[]

  File.open(outfile,"wb") { |f|
    for i in pokeList
      next if to_skip.include?(i)

      species = GameData::Species.get(i)
      evolutions = []
      for evoArray in species.get_family_evolutions
        evolutions << evoArray[1]
      end


      non_customs = []
      nbCustoms=0
      for stage in evolutions
        if !customSpriteExists(stage)
          non_customs << stage
        else
          nbCustoms+=1
        end
      end


      #write non customs
      if !non_customs.empty? && nbCustoms > 0
        for missing_sprite in non_customs
          f.write((missing_sprite.to_s) +";")
        end
        f.write((missing_sprite.to_s) +"\n")
      end

      #remove evos from list
      for evo in evolutions
        species = GameData::Species.get(evo)
        to_skip << species.id_number
      end
    end



  }
end