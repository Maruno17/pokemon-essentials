class PokemonGlobalMetadata
  attr_accessor :pokeradarBattery
end



class Game_Temp
  attr_accessor :poke_radar_data   # [species, level, chain count, grasses (x,y,ring,rarity)]
end



################################################################################
# Using the Poke Radar
################################################################################
def pbCanUsePokeRadar?
  # Can't use Radar if not in tall grass
  terrain = $game_map.terrain_tag($game_player.x, $game_player.y)
  if !terrain.land_wild_encounters || !terrain.shows_grass_rustle
    pbMessage(_INTL("Can't use that here."))
    return false
  end
  # Can't use Radar if map has no grass-based encounters (ignoring Bug Contest)
  if !$PokemonEncounters.has_normal_land_encounters?
    pbMessage(_INTL("Can't use that here."))
    return false
  end
  # Can't use Radar while cycling
  if $PokemonGlobal.bicycle
    pbMessage(_INTL("Can't use that while on a bicycle."))
    return false
  end
  # Debug
  return true if $DEBUG && Input.press?(Input::CTRL)
  # Can't use Radar if it isn't fully charged
  if $PokemonGlobal.pokeradarBattery && $PokemonGlobal.pokeradarBattery > 0
    pbMessage(_INTL("The battery has run dry!\nFor it to recharge, you need to walk another {1} steps.",
                    $PokemonGlobal.pokeradarBattery))
    return false
  end
  return true
end

def pbUsePokeRadar
  return false if !pbCanUsePokeRadar?
  $stats.poke_radar_count += 1
  $game_temp.poke_radar_data = [0, 0, 0, [], false] if !$game_temp.poke_radar_data
  $game_temp.poke_radar_data[4] = false
  $PokemonGlobal.pokeradarBattery = 50
  pbPokeRadarHighlightGrass
  return true
end

def pbPokeRadarCancel
  $game_temp.poke_radar_data = nil
end

def pbPokeRadarHighlightGrass(showmessage = true)
  grasses = []   # x, y, ring (0-3 inner to outer), rarity
  # Choose 1 random tile from each ring around the player
  4.times do |i|
    r = rand((i + 1) * 8)
    # Get coordinates of randomly chosen tile
    x = $game_player.x
    y = $game_player.y
    if r <= (i + 1) * 2
      x = $game_player.x - i - 1 + r
      y = $game_player.y - i - 1
    elsif r <= ((i + 1) * 6) - 2
      x = [$game_player.x + i + 1, $game_player.x - i - 1][r % 2]
      y = $game_player.y - i + ((r - 1 - ((i + 1) * 2)) / 2).floor
    else
      x = $game_player.x - i + r - ((i + 1) * 6)
      y = $game_player.y + i + 1
    end
    # Add tile to grasses array if it's a valid grass tile
    next if x < 0 || x >= $game_map.width ||
            y < 0 || y >= $game_map.height
    terrain = $game_map.terrain_tag(x, y)
    next if !terrain.land_wild_encounters || !terrain.shows_grass_rustle
    # Choose a rarity for the grass (0=normal, 1=rare, 2=shiny)
    s = (rand(100) < 25) ? 1 : 0
    if $game_temp.poke_radar_data && $game_temp.poke_radar_data[2] > 0
      v = [(65_536 / Settings::SHINY_POKEMON_CHANCE) - ([$game_temp.poke_radar_data[2], 40].min * 200), 200].max
      v = (65_536 / v.to_f).ceil
      s = 2 if rand(65_536) < v
    end
    grasses.push([x, y, i, s])
  end
  if grasses.length == 0
    # No shaking grass found, break the chain
    pbMessage(_INTL("The grassy patch remained quiet...")) if showmessage
    pbPokeRadarCancel
  else
    # Show grass rustling animations
    grasses.each do |grass|
      case grass[3]
      when 0   # Normal rustle
        $scene.spriteset.addUserAnimation(Settings::RUSTLE_NORMAL_ANIMATION_ID, grass[0], grass[1], true, 1)
      when 1   # Vigorous rustle
        $scene.spriteset.addUserAnimation(Settings::RUSTLE_VIGOROUS_ANIMATION_ID, grass[0], grass[1], true, 1)
      when 2   # Shiny rustle
        $scene.spriteset.addUserAnimation(Settings::RUSTLE_SHINY_ANIMATION_ID, grass[0], grass[1], true, 1)
      end
    end
    $game_temp.poke_radar_data[3] = grasses if $game_temp.poke_radar_data
    pbWait(Graphics.frame_rate / 2)
  end
end

def pbPokeRadarGetShakingGrass
  return -1 if !$game_temp.poke_radar_data
  grasses = $game_temp.poke_radar_data[3]
  return -1 if grasses.length == 0
  grasses.each do |i|
    return i[2] if $game_player.x == i[0] && $game_player.y == i[1]
  end
  return -1
end

def pbPokeRadarOnShakingGrass
  return pbPokeRadarGetShakingGrass >= 0
end

def pbPokeRadarGetEncounter(rarity = 0)
  # Poké Radar-exclusive encounters can only be found in vigorously-shaking grass
  if rarity > 0
    # Get all Poké Radar-exclusive encounters for this map
    map = $game_map.map_id
    array = []
    Settings::POKE_RADAR_ENCOUNTERS.each do |enc|
      array.push(enc) if enc[0] == map && GameData::Species.exists?(enc[2])
    end
    # If there are any exclusives, first have a chance of encountering those
    if array.length > 0
      rnd = rand(100)
      array.each do |enc|
        rnd -= enc[1]
        next if rnd >= 0
        level = (enc[4] && enc[4] > enc[3]) ? rand(enc[3]..enc[4]) : enc[3]
        return [enc[2], level]
      end
    end
  end
  # Didn't choose a Poké Radar-exclusive species, choose a regular encounter instead
  return $PokemonEncounters.choose_wild_pokemon($PokemonEncounters.encounter_type, rarity + 1)
end

################################################################################
# Event handlers
################################################################################
EventHandlers.add(:on_wild_species_chosen, :poke_radar_chain,
  proc { |encounter|
    if GameData::EncounterType.get($game_temp.encounter_type).type != :land ||
       $PokemonGlobal.bicycle || $PokemonGlobal.partner
      pbPokeRadarCancel
      next
    end
    ring = pbPokeRadarGetShakingGrass
    if ring >= 0   # Encounter triggered by stepping into rustling grass
      # Get rarity of shaking grass
      rarity = 0   # 0 = rustle, 1 = vigorous rustle, 2 = shiny rustle
      $game_temp.poke_radar_data[3].each { |g| rarity = g[3] if g[2] == ring }
      if $game_temp.poke_radar_data[2] > 0   # Chain count, i.e. is chaining
        chain_chance = 58 + (ring * 10)
        chain_chance += [$game_temp.poke_radar_data[2], 40].min / 4   # Chain length
        chain_chance += 10 if $game_temp.poke_radar_data[4]   # Previous in chain was caught
        if rarity == 2 || rand(100) < chain_chance
          # Continue the chain
          encounter[0] = $game_temp.poke_radar_data[0]   # Species
          encounter[1] = $game_temp.poke_radar_data[1]   # Level
          $game_temp.force_single_battle = true
        else
          # Break the chain, force an encounter with a different species
          100.times do
            break if encounter && encounter[0] != $game_temp.poke_radar_data[0]
            new_encounter = $PokemonEncounters.choose_wild_pokemon($PokemonEncounters.encounter_type)
            encounter[0] = new_encounter[0]
            encounter[1] = new_encounter[1]
          end
          if encounter[0] == $game_temp.poke_radar_data[0] && encounter[1] == $game_temp.poke_radar_data[1]
            # Chain couldn't be broken somehow; continue it after all
            $game_temp.force_single_battle = true
          else
            pbPokeRadarCancel
          end
        end
      else   # Not chaining; will start one
        # Force random wild encounter, vigorous shaking means rarer species
        new_encounter = pbPokeRadarGetEncounter(rarity)
        encounter[0] = new_encounter[0]
        encounter[1] = new_encounter[1]
        $game_temp.force_single_battle = true
      end
    elsif encounter   # Encounter triggered by stepping in non-rustling grass
      pbPokeRadarCancel
    end
  }
)

EventHandlers.add(:on_wild_pokemon_created, :poke_radar_shiny,
  proc { |pkmn|
    next if !$game_temp.poke_radar_data
    grasses = $game_temp.poke_radar_data[3]
    next if !grasses
    grasses.each do |grass|
      next if $game_player.x != grass[0] || $game_player.y != grass[1]
      pkmn.shiny = true if grass[3] == 2
      break
    end
  }
)

EventHandlers.add(:on_wild_battle_end, :poke_radar_continue_chain,
  proc { |species, level, decision|
    if $game_temp.poke_radar_data && [1, 4].include?(decision)   # Defeated/caught
      $game_temp.poke_radar_data[0] = species
      $game_temp.poke_radar_data[1] = level
      $game_temp.poke_radar_data[2] += 1
      $stats.poke_radar_longest_chain = [$game_temp.poke_radar_data[2], $stats.poke_radar_longest_chain].max
      # Catching makes the next Radar encounter more likely to continue the chain
      $game_temp.poke_radar_data[4] = (decision == 4)
      pbPokeRadarHighlightGrass(false)
    else
      pbPokeRadarCancel
    end
  }
)

EventHandlers.add(:on_player_step_taken, :poke_radar,
  proc {
    if $PokemonGlobal.pokeradarBattery && $PokemonGlobal.pokeradarBattery > 0 &&
       !$game_temp.poke_radar_data
      $PokemonGlobal.pokeradarBattery -= 1
    end
    terrain = $game_map.terrain_tag($game_player.x, $game_player.y)
    if !terrain.land_wild_encounters || !terrain.shows_grass_rustle
      pbPokeRadarCancel
    end
  }
)

EventHandlers.add(:on_enter_map, :cancel_poke_radar,
  proc { |_old_map_id|
    pbPokeRadarCancel
  }
)

################################################################################
# Item handlers
################################################################################
ItemHandlers::UseInField.add(:POKERADAR, proc { |item|
  next pbUsePokeRadar
})

ItemHandlers::UseFromBag.add(:POKERADAR, proc { |item|
  next (pbCanUsePokeRadar?) ? 2 : 0
})
