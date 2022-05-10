##### by route
#
# Randomize encounter by routes
# Script by Frogman
#

def Kernel.randomizeWildPokemonByRoute()
  bstRange = $game_variables[197]
  randomizeToFusions = $game_switches[953]
  $game_switches[829] = randomizeToFusions #unused mais probab. utile pour débugger les inévitables bugs quand les gens vont se partager leurs fichiers
  maxSpecies = randomizeToFusions ? PBSpecies.maxValue : NB_POKEMON
  data=load_data("Data/encounters.dat")
  map_index = 0
  nb_maps= data.size
  if data.is_a?(Hash)
    for map in data
      map_index += 1
      displayProgress(map_index,nb_maps,bstRange)
      map_id = map[0]
      encountersList = map[1][1]
      next if encountersList== nil
      type_index =-1
      for encounterType in encountersList
          type_index +=1
          next if encounterType == nil
          previousSpecies = -1
          previousNewSpecies = -1
          encounter_index = 0
          for encounter in encounterType
             species = encounter[0]
             if species != previousSpecies    
                newSpecies= getNewSpecies(species,bstRange,true,maxSpecies)
                previousSpecies = species
                previousNewSpecies = newSpecies
             else
                newSpecies = previousNewSpecies
              end
            if data[map_id][1][type_index][encounter_index] != nil
              data[map_id][1][type_index][encounter_index][0] = newSpecies
            end
            encounter_index  +=1
          end   #for -encounter
      end #for encountertype
    end   #for - map
  end #if
  filename = "Data/encounters_randomized.dat"
  save_data(Marshal.load(Marshal.dump(data)),filename)
  $PokemonEncounters.setup($game_map.map_id)
 end
 
  
  #file = File.new('Data/test.txt', 'w')
  #file.puts data.inspect
 

def displayProgress(current,total,bst)
  return if bst >= 100
  return if bst >= 20 && current % 10 != 0
  Kernel.pbMessageNoSound(_INTL("\\ts[]Generating encounters file...\\n Map {1}/{2}\\^",current,total))
end

#
# class PokemonEncounters
#
#     def setup(mapID)
#     @density=nil
#     @stepcount=0
#     @enctypes=[]
#     begin
#
#       data=load_data(getEncountersFilePath())
#       if data.is_a?(Hash) && data[mapID]
#         @density=data[mapID][0]
#         @enctypes=data[mapID][1]
#       else
#         @density=nil
#         @enctypes=[]
#       end
#       rescue
#       @density=nil
#       @enctypes=[]
#     end
#   end
#
#   def getEncountersFilePath()
#     if $game_switches[777] && $game_switches[778]   #[777] = random-by-area  [778] = wildpokerandom activated
#       return "Data/encounters_randomized.dat"
#     else
#       return "Data/encounters.dat"
#     end
#   end
#
#   def pbMapEncounter(mapID,enctype)
#     if enctype<0 || enctype>EncounterTypes::EnctypeChances.length
#       raise ArgumentError.new(_INTL("Encounter type out of range"))
#     end
#     data=load_data(getEncountersFilePath())
#     if data.is_a?(Hash) && data[mapID]
#       enctypes=data[mapID][1]
#     else
#       return nil
#     end
#     return nil if enctypes[enctype]==nil
#     chances=EncounterTypes::EnctypeChances[enctype]
#     chancetotal=0
#     chances.each {|a| chancetotal+=a}
#     rnd=rand(chancetotal)
#     chosenpkmn=0
#     chance=0
#     for i in 0...chances.length
#       chance+=chances[i]
#       if rnd<chance
#         chosenpkmn=i
#         break
#       end
#     end
#     encounter=enctypes[enctype][chosenpkmn]
#     level=encounter[1]+rand(1+encounter[2]-encounter[1])
#     return [encounter[0],level]
#   end
# end



def getRandomPokemon(originalPokemon,bstRange,maxDexNumber)
  originalBst = getBaseStatsTotal(originalPokemon)
  bstMin = originalBst-bstRange
  bstMax = originalBst+bstRange
  
  foundAPokemon = false
  int i=0
  while ! foundAPokemon
    newPoke = rand(maxDexNumber-1)+1
    newPokeBST = getBaseStatsTotal(newPoke)
    if newPokeBST >= bstMin && newPokeBST <= bstMax
      foundAPokemon = true
    end
    i+=1
    if i %10 ==0
      bstMin-=5
      bstMax+=5
    end
  end
  return newPoke
end

def getBaseStatsTotal(species)
      baseStats=$pkmn_dex[species][5]
      baseStat_temp = 0
      for i in 0...baseStats.length
        baseStat_temp+=baseStats[i]
      end
      return (baseStat_temp/range).floor
end


######################################################













