class PokemonGlobalMetadata
  attr_accessor :roamPosition
  attr_accessor :roamedAlready   # Whether a roamer has been encountered on current map
  attr_accessor :roamEncounter
  attr_accessor :roamPokemon
  attr_writer   :roamPokemonCaught

  def roamPokemonCaught
    return @roamPokemonCaught || []
  end
end



#===============================================================================
# Making roaming Pokémon roam around.
#===============================================================================
# Resets all roaming Pokemon that were defeated without having been caught.
def pbResetAllRoamers
  return if !$PokemonGlobal.roamPokemon
  for i in 0...$PokemonGlobal.roamPokemon.length
    next if $PokemonGlobal.roamPokemon[i]!=true || !$PokemonGlobal.roamPokemonCaught[i]
    $PokemonGlobal.roamPokemon[i] = nil
  end
end

# Gets the roaming areas for a particular Pokémon.
def pbRoamingAreas(idxRoamer)
  # [species ID, level, Game Switch, encounter type, battle BGM, area maps hash]
  roamData = Settings::ROAMING_SPECIES[idxRoamer]
  return roamData[5] if roamData && roamData[5]
  return Settings::ROAMING_AREAS
end

# Puts a roamer in a completely random map available to it.
def pbRandomRoam(index)
  return if !$PokemonGlobal.roamPosition
  keys = pbRoamingAreas(index).keys
  $PokemonGlobal.roamPosition[index] = keys[rand(keys.length)]
end

# Makes all roaming Pokémon roam to another map.
def pbRoamPokemon
  $PokemonGlobal.roamPokemon = [] if !$PokemonGlobal.roamPokemon
  # Start all roamers off in random maps
  if !$PokemonGlobal.roamPosition
    $PokemonGlobal.roamPosition = {}
    for i in 0...Settings::ROAMING_SPECIES.length
      next if !GameData::Species.exists?(i[0])
      keys = pbRoamingAreas(i).keys
      $PokemonGlobal.roamPosition[i] = keys[rand(keys.length)]
    end
  end
  # Roam each Pokémon in turn
  for i in 0...Settings::ROAMING_SPECIES.length
    pbRoamPokemonOne(i)
  end
end

# Makes a single roaming Pokémon roam to another map. Doesn't roam if it isn't
# currently possible to encounter it (i.e. its Game Switch is off).
def pbRoamPokemonOne(idxRoamer)
  # [species ID, level, Game Switch, encounter type, battle BGM, area maps hash]
  roamData = Settings::ROAMING_SPECIES[idxRoamer]
  return if roamData[2]>0 && !$game_switches[roamData[2]]   # Game Switch is off
  return if !GameData::Species.exists?(roamData[0])
  # Get hash of area patrolled by the roaming Pokémon
  mapIDs = pbRoamingAreas(idxRoamer).keys
  return if !mapIDs || mapIDs.length==0   # No roaming area defined somehow
  # Get the roaming Pokémon's current map
  currentMap = $PokemonGlobal.roamPosition[idxRoamer]
  if !currentMap
    currentMap = mapIDs[rand(mapIDs.length)]
    $PokemonGlobal.roamPosition[idxRoamer] = currentMap
  end
  # Make an array of all possible maps the roaming Pokémon could roam to
  newMapChoices = []
  nextMaps = pbRoamingAreas(idxRoamer)[currentMap]
  return if !nextMaps
  for map in nextMaps
    # Only add map as a choice if the player hasn't been there recently
    newMapChoices.push(map)
  end
  # Rarely, add a random possible map into the mix
  if rand(32)==0
    newMapChoices.push(mapIDs[rand(mapIDs.length)])
  end
  # Choose a random new map to roam to
  if newMapChoices.length>0
    $PokemonGlobal.roamPosition[idxRoamer] = newMapChoices[rand(newMapChoices.length)]
  end
end

# When the player moves to a new map (with a different name), make all roaming
# Pokémon roam.
Events.onMapChange += proc { |_sender,e|
  oldMapID = e[0]
  # Get and compare map names
  mapInfos = pbLoadMapInfos
  next if mapInfos && oldMapID>0 && mapInfos[oldMapID] &&
     mapInfos[oldMapID].name && $game_map.name==mapInfos[oldMapID].name
  # Make roaming Pokémon roam
  pbRoamPokemon
  $PokemonGlobal.roamedAlready = false
}



#===============================================================================
# Encountering a roaming Pokémon in a wild battle.
#===============================================================================
class PokemonTemp
  attr_accessor :roamerIndex   # Index of roaming Pokémon to encounter next
end



# Returns whether the given category of encounter contains the actual encounter
# method that will occur in the player's current position.
def pbRoamingMethodAllowed(roamer_method)
  enc_type = $PokemonEncounters.encounter_type
  type = GameData::EncounterType.get(enc_type).type
  case roamer_method
  when 0   # Any step-triggered method (except Bug Contest)
    return [:land, :cave, :water].include?(type)
  when 1   # Walking (except Bug Contest)
    return [:land, :cave].include?(type)
  when 2   # Surfing
    return type == :water
  when 3   # Fishing
    return type == :fishing
  when 4   # Water-based
    return [:water, :fishing].include?(type)
  end
  return false
end

EncounterModifier.register(proc { |encounter|
  $PokemonTemp.roamerIndex = nil
  next nil if !encounter
  # Give the regular encounter if encountering a roaming Pokémon isn't possible
  next encounter if $PokemonGlobal.roamedAlready
  next encounter if $PokemonGlobal.partner
  next encounter if $PokemonTemp.pokeradar
  next encounter if rand(100) < 75   # 25% chance of encountering a roaming Pokémon
  # Look at each roaming Pokémon in turn and decide whether it's possible to
  # encounter it
  currentRegion = pbGetCurrentRegion
  currentMapName = pbGetMessage(MessageTypes::MapNames, $game_map.map_id)
  possible_roamers = []
  Settings::ROAMING_SPECIES.each_with_index do |data, i|
    # data = [species, level, Game Switch, roamer method, battle BGM, area maps hash]
    next if !GameData::Species.exists?(data[0])
    next if data[2] > 0 && !$game_switches[data[2]]   # Isn't roaming
    next if $PokemonGlobal.roamPokemon[i] == true   # Roaming Pokémon has been caught
    # Get the roamer's current map
    roamerMap = $PokemonGlobal.roamPosition[i]
    if !roamerMap
      mapIDs = pbRoamingAreas(i).keys   # Hash of area patrolled by the roaming Pokémon
      next if !mapIDs || mapIDs.length == 0   # No roaming area defined somehow
      roamerMap = mapIDs[rand(mapIDs.length)]
      $PokemonGlobal.roamPosition[i] = roamerMap
    end
    # If roamer isn't on the current map, check if it's on a map with the same
    # name and in the same region
    if roamerMap != $game_map.map_id
      map_metadata = GameData::MapMetadata.try_get(roamerMap)
      next if !map_metadata || !map_metadata.town_map_position ||
              map_metadata.town_map_position[0] != currentRegion
      next if pbGetMessage(MessageTypes::MapNames, roamerMap) != currentMapName
    end
    # Check whether the roamer's roamer method is currently possible
    next if !pbRoamingMethodAllowed(data[3])
    # Add this roaming Pokémon to the list of possible roaming Pokémon to encounter
    possible_roamers.push([i, data[0], data[1], data[4]])   # [i, species, level, BGM]
  end
  # No encounterable roaming Pokémon were found, just have the regular encounter
  next encounter if possible_roamers.length == 0
  # Pick a roaming Pokémon to encounter out of those available
  roamer = possible_roamers[rand(possible_roamers.length)]
  $PokemonGlobal.roamEncounter = roamer
  $PokemonTemp.roamerIndex     = roamer[0]
  $PokemonGlobal.nextBattleBGM = roamer[3] if roamer[3] && !roamer[3].empty?
  $PokemonTemp.forceSingleBattle = true
  next [roamer[1], roamer[2]]   # Species, level
})

Events.onWildBattleOverride += proc { |_sender,e|
  species = e[0]
  level   = e[1]
  handled = e[2]
  next if handled[0]!=nil
  next if !$PokemonGlobal.roamEncounter || $PokemonTemp.roamerIndex.nil?
  handled[0] = pbRoamingPokemonBattle(species, level)
}

def pbRoamingPokemonBattle(species, level)
  # Get the roaming Pokémon to encounter; generate it based on the species and
  # level if it doesn't already exist
  idxRoamer = $PokemonTemp.roamerIndex
  if !$PokemonGlobal.roamPokemon[idxRoamer] ||
     !$PokemonGlobal.roamPokemon[idxRoamer].is_a?(Pokemon)
    $PokemonGlobal.roamPokemon[idxRoamer] = pbGenerateWildPokemon(species,level,true)
  end
  # Set some battle rules
  setBattleRule("single")
  setBattleRule("roamerFlees")
  # Perform the battle
  decision = pbWildBattleCore($PokemonGlobal.roamPokemon[idxRoamer])
  # Update Roaming Pokémon data based on result of battle
  if decision==1 || decision==4   # Defeated or caught
    $PokemonGlobal.roamPokemon[idxRoamer]       = true
    $PokemonGlobal.roamPokemonCaught[idxRoamer] = (decision==4)
  end
  $PokemonGlobal.roamEncounter = nil
  $PokemonGlobal.roamedAlready = true
  # Used by the Poké Radar to update/break the chain
  Events.onWildBattleEnd.trigger(nil,species,level,decision)
  # Return false if the player lost or drew the battle, and true if any other result
  return (decision!=2 && decision!=5)
end

EncounterModifier.registerEncounterEnd(proc {
  $PokemonTemp.roamerIndex = nil
})
