#===============================================================================
# This module stores encounter-modifying events that can happen during the game.
# A procedure can subscribe to an event by adding itself to the event. It will
# then be called whenever the event occurs.
#===============================================================================
module EncounterModifier
  @@procs    = []
  @@procsEnd = []

  def self.register(p)
    @@procs.push(p)
  end

  def self.registerEncounterEnd(p)
    @@procsEnd.push(p)
  end

  def self.trigger(encounter)
    for prc in @@procs
      encounter = prc.call(encounter)
    end
    return encounter
  end

  def self.triggerEncounterEnd()
    for prc in @@procsEnd
      prc.call()
    end
  end
end



#===============================================================================
# This module stores events that can happen during the game. A procedure can
# subscribe to an event by adding itself to the event. It will then be called
# whenever the event occurs.
#===============================================================================
module Events
  @@OnMapCreate                 = Event.new
  @@OnMapUpdate                 = Event.new
  @@OnMapChange                 = Event.new
  @@OnMapChanging               = Event.new
  @@OnMapSceneChange            = Event.new
  @@OnSpritesetCreate           = Event.new
  @@OnAction                    = Event.new
  @@OnStepTaken                 = Event.new
  @@OnLeaveTile                 = Event.new
  @@OnStepTakenFieldMovement    = Event.new
  @@OnStepTakenTransferPossible = Event.new
  @@OnStartBattle               = Event.new
  @@OnEndBattle                 = Event.new
  @@OnWildPokemonCreate         = Event.new
  @@OnWildBattleOverride        = Event.new
  @@OnWildBattleEnd             = Event.new
  @@OnTrainerPartyLoad          = Event.new
  @@OnChangeDirection           = Event.new

  # Fires whenever a map is created. Event handler receives two parameters: the
  # map (RPG::Map) and the tileset (RPG::Tileset)
  def self.onMapCreate;     @@OnMapCreate;     end
  def self.onMapCreate=(v); @@OnMapCreate = v; end

  # Fires each frame during a map update.
  def self.onMapUpdate;     @@OnMapUpdate;     end
  def self.onMapUpdate=(v); @@OnMapUpdate = v; end

  # Fires whenever one map is about to change to a different one. Event handler
  # receives the new map ID and the Game_Map object representing the new map.
  # When the event handler is called, $game_map still refers to the old map.
  def self.onMapChanging;     @@OnMapChanging;     end
  def self.onMapChanging=(v); @@OnMapChanging = v; end

  # Fires whenever the player moves to a new map. Event handler receives the old
  # map ID or 0 if none. Also fires when the first map of the game is loaded
  def self.onMapChange;     @@OnMapChange;     end
  def self.onMapChange=(v); @@OnMapChange = v; end

  # Fires whenever the map scene is regenerated and soon after the player moves
  # to a new map.
  # Parameters:
  # e[0] - Scene_Map object.
  # e[1] - Whether the player just moved to a new map (either true or false). If
  #        false, some other code had called $scene.createSpritesets to
  #        regenerate the map scene without transferring the player elsewhere
  def self.onMapSceneChange;     @@OnMapSceneChange;     end
  def self.onMapSceneChange=(v); @@OnMapSceneChange = v; end

  # Fires whenever a spriteset is created.
  # Parameters:
  # e[0] - Spriteset being created. e[0].map is the map associated with the
  #        spriteset (not necessarily the current map).
  # e[1] - Viewport used for tilemap and characters
  def self.onSpritesetCreate;     @@OnSpritesetCreate;     end
  def self.onSpritesetCreate=(v); @@OnSpritesetCreate = v; end

  # Triggers when the player presses the Action button on the map.
  def self.onAction;     @@OnAction;     end
  def self.onAction=(v); @@OnAction = v; end

  # Fires whenever the player takes a step.
  def self.onStepTaken;     @@OnStepTaken;     end
  def self.onStepTaken=(v); @@OnStepTaken = v; end

  # Fires whenever the player or another event leaves a tile.
  # Parameters:
  # e[0] - Event that just left the tile.
  # e[1] - Map ID where the tile is located (not necessarily
  #        the current map). Use "$MapFactory.getMap(e[1])" to
  #        get the Game_Map object corresponding to that map.
  # e[2] - X-coordinate of the tile
  # e[3] - Y-coordinate of the tile
  def self.onLeaveTile;     @@OnLeaveTile;     end
  def self.onLeaveTile=(v); @@OnLeaveTile = v; end

  # Fires whenever the player or another event enters a tile.
  # Parameters:
  # e[0] - Event that just entered a tile.
  def self.onStepTakenFieldMovement;     @@OnStepTakenFieldMovement;     end
  def self.onStepTakenFieldMovement=(v); @@OnStepTakenFieldMovement = v; end

  # Fires whenever the player takes a step. The event handler may possibly move
  # the player elsewhere.
  # Parameters:
  # e[0] - Array that contains a single boolean value. If an event handler moves
  #        the player to a new map, it should set this value to true. Other
  #        event handlers should check this parameter's value.
  def self.onStepTakenTransferPossible;     @@OnStepTakenTransferPossible;     end
  def self.onStepTakenTransferPossible=(v); @@OnStepTakenTransferPossible = v; end

  def self.onStartBattle;     @@OnStartBattle;     end
  def self.onStartBattle=(v); @@OnStartBattle = v; end

  def self.onEndBattle;     @@OnEndBattle;     end
  def self.onEndBattle=(v); @@OnEndBattle = v; end

  # Triggers whenever a wild Pokémon is created
  # Parameters:
  # e[0] - Pokémon being created
  def self.onWildPokemonCreate;     @@OnWildPokemonCreate;     end
  def self.onWildPokemonCreate=(v); @@OnWildPokemonCreate = v; end

  # Triggers at the start of a wild battle.  Event handlers can provide their
  # own wild battle routines to override the default behavior.
  def self.onWildBattleOverride;     @@OnWildBattleOverride;     end
  def self.onWildBattleOverride=(v); @@OnWildBattleOverride = v; end

  # Triggers whenever a wild Pokémon battle ends
  # Parameters:
  # e[0] - Pokémon species
  # e[1] - Pokémon level
  # e[2] - Battle result (1-win, 2-loss, 3-escaped, 4-caught, 5-draw)
  def self.onWildBattleEnd;     @@OnWildBattleEnd;     end
  def self.onWildBattleEnd=(v); @@OnWildBattleEnd = v; end

  # Triggers whenever an NPC trainer's Pokémon party is loaded
  # Parameters:
  # e[0] - Trainer
  # e[1] - Items possessed by the trainer
  # e[2] - Party
  def self.onTrainerPartyLoad;     @@OnTrainerPartyLoad;     end
  def self.onTrainerPartyLoad=(v); @@OnTrainerPartyLoad = v; end

  # Fires whenever the player changes direction.
  def self.onChangeDirection;     @@OnChangeDirection;     end
  def self.onChangeDirection=(v); @@OnChangeDirection = v; end
end



def pbOnSpritesetCreate(spriteset,viewport)
  Events.onSpritesetCreate.trigger(nil,spriteset,viewport)
end



#===============================================================================
# Constant checks
#===============================================================================
# Pokérus check
Events.onMapUpdate += proc { |_sender,_e|
  next if !$Trainer
  last = $PokemonGlobal.pokerusTime
  now = pbGetTimeNow
  if !last || last.year!=now.year || last.month!=now.month || last.day!=now.day
    for i in $Trainer.pokemon_party
      i.lowerPokerusCount
    end
    $PokemonGlobal.pokerusTime = now
  end
}

# Returns whether the Poké Center should explain Pokérus to the player, if a
# healed Pokémon has it.
def pbPokerus?
  return false if $game_switches[Settings::SEEN_POKERUS_SWITCH]
  for i in $Trainer.party
    return true if i.pokerusStage==1
  end
  return false
end



class PokemonTemp
  attr_accessor :batterywarning
  attr_accessor :cueBGM
  attr_accessor :cueFrames
end



def pbBatteryLow?
  pstate = System.power_state
  # If it's not discharging, it doesn't matter if it's low
  return false if !pstate[:discharging]
  # Check for less than 10m, priority over the percentage
  # Some laptops (Chromebooks, Macbooks) have very long lifetimes
  return true if pstate[:seconds] && pstate[:seconds] <= 600
  # Check for <=15%
  return true if pstate[:percent] && pstate[:percent] <= 15
  return false
end

Events.onMapUpdate += proc { |_sender,_e|
  if !$PokemonTemp.batterywarning && pbBatteryLow?
    if !$game_temp.in_menu && !$game_temp.in_battle &&
       !$game_player.move_route_forcing && !$game_temp.message_window_showing &&
       !pbMapInterpreterRunning?
      if pbGetTimeNow.sec==0
        pbMessage(_INTL("The game has detected that the battery is low. You should save soon to avoid losing your progress."))
        $PokemonTemp.batterywarning = true
      end
    end
  end
  if $PokemonTemp.cueFrames
    $PokemonTemp.cueFrames -= 1
    if $PokemonTemp.cueFrames<=0
      $PokemonTemp.cueFrames = nil
      if $game_system.getPlayingBGM==nil
        pbBGMPlay($PokemonTemp.cueBGM)
      end
    end
  end
}



#===============================================================================
# Checks per step
#===============================================================================
# Party Pokémon gain happiness from walking
Events.onStepTaken += proc {
  $PokemonGlobal.happinessSteps = 0 if !$PokemonGlobal.happinessSteps
  $PokemonGlobal.happinessSteps += 1
  if $PokemonGlobal.happinessSteps>=128
    for pkmn in $Trainer.able_party
      pkmn.changeHappiness("walking") if rand(2)==0
    end
    $PokemonGlobal.happinessSteps = 0
  end
}

# Poison party Pokémon
Events.onStepTakenTransferPossible += proc { |_sender,e|
  handled = e[0]
  next if handled[0]
  if $PokemonGlobal.stepcount%4==0 && Settings::POISON_IN_FIELD
    flashed = false
    for i in $Trainer.able_party
      if i.status == :POISON && !i.hasAbility?(:IMMUNITY)
        if !flashed
          $game_screen.start_flash(Color.new(255,0,0,128), 4)
          flashed = true
        end
        i.hp -= 1 if i.hp>1 || Settings::POISON_FAINT_IN_FIELD
        if i.hp==1 && !Settings::POISON_FAINT_IN_FIELD
          i.status = :NONE
          pbMessage(_INTL("{1} survived the poisoning.\\nThe poison faded away!\1",i.name))
          next
        elsif i.hp==0
          i.changeHappiness("faint")
          i.status = :NONE
          pbMessage(_INTL("{1} fainted...",i.name))
        end
        if $Trainer.able_pokemon_count == 0
          handled[0] = true
          pbCheckAllFainted
        end
      end
    end
  end
}

def pbCheckAllFainted
  if $Trainer.able_pokemon_count == 0
    pbMessage(_INTL("You have no more Pokémon that can fight!\1"))
    pbMessage(_INTL("You blacked out!"))
    pbBGMFade(1.0)
    pbBGSFade(1.0)
    pbFadeOutIn { pbStartOver }
  end
end

# Gather soot from soot grass
Events.onStepTakenFieldMovement += proc { |_sender,e|
  event = e[0] # Get the event affected by field movement
  thistile = $MapFactory.getRealTilePos(event.map.map_id,event.x,event.y)
  map = $MapFactory.getMap(thistile[0])
  sootlevel = -1
  for i in [2, 1, 0]
    tile_id = map.data[thistile[1],thistile[2],i]
    next if tile_id==nil
    if map.terrain_tags[tile_id]==PBTerrain::SootGrass
      sootlevel = i
      break
    end
  end
  if sootlevel>=0 && GameData::Item.exists?(:SOOTSACK)
    $PokemonGlobal.sootsack = 0 if !$PokemonGlobal.sootsack
#    map.data[thistile[1],thistile[2],sootlevel]=0
    if event==$game_player && $PokemonBag.pbHasItem?(:SOOTSACK)
      $PokemonGlobal.sootsack += 1
    end
#    $scene.createSingleSpriteset(map.map_id)
  end
}

# Show grass rustle animation, and auto-move the player over waterfalls and ice
Events.onStepTakenFieldMovement += proc { |_sender,e|
  event = e[0] # Get the event affected by field movement
  if $scene.is_a?(Scene_Map)
    currentTag = pbGetTerrainTag(event)
    if PBTerrain.isJustGrass?(pbGetTerrainTag(event,true))  # Won't show if under bridge
      $scene.spriteset.addUserAnimation(Settings::GRASS_ANIMATION_ID,event.x,event.y,true,1)
    elsif event==$game_player
      if currentTag==PBTerrain::WaterfallCrest
        # Descend waterfall, but only if this event is the player
        pbDescendWaterfall(event)
      elsif PBTerrain.isIce?(currentTag) && !$PokemonGlobal.sliding
        pbSlideOnIce(event)
      end
    end
  end
}

def pbOnStepTaken(eventTriggered)
  if $game_player.move_route_forcing || pbMapInterpreterRunning?
    Events.onStepTakenFieldMovement.trigger(nil,$game_player)
    return
  end
  $PokemonGlobal.stepcount = 0 if !$PokemonGlobal.stepcount
  $PokemonGlobal.stepcount += 1
  $PokemonGlobal.stepcount &= 0x7FFFFFFF
  repel_active = ($PokemonGlobal.repel > 0)
  Events.onStepTaken.trigger(nil)
#  Events.onStepTakenFieldMovement.trigger(nil,$game_player)
  handled = [nil]
  Events.onStepTakenTransferPossible.trigger(nil,handled)
  return if handled[0]
  pbBattleOnStepTaken(repel_active) if !eventTriggered && !$game_temp.in_menu
  $PokemonTemp.encounterTriggered = false   # This info isn't needed here
end

# Start wild encounters while turning on the spot
Events.onChangeDirection += proc {
  repel_active = ($PokemonGlobal.repel > 0)
  pbBattleOnStepTaken(repel_active) if !$game_temp.in_menu
}

def pbBattleOnStepTaken(repel_active)
  return if $Trainer.able_pokemon_count == 0
  return if !$PokemonEncounters.encounter_possible_here?
  encounter_type = $PokemonEncounters.encounter_type
  return if !encounter_type
  return if !$PokemonEncounters.encounter_triggered?(encounter_type, repel_active)
  $PokemonTemp.encounterType = encounter_type
  encounter = $PokemonEncounters.choose_wild_pokemon(encounter_type)
  encounter = EncounterModifier.trigger(encounter)
  if $PokemonEncounters.allow_encounter?(encounter, repel_active)
    if $PokemonEncounters.have_double_wild_battle?
      encounter2 = $PokemonEncounters.choose_wild_pokemon(encounter_type)
      encounter2 = EncounterModifier.trigger(encounter2)
      pbDoubleWildBattle(encounter[0], encounter[1], encounter2[0], encounter2[1])
    else
      pbWildBattle(encounter[0], encounter[1])
    end
    $PokemonTemp.encounterType = nil
    $PokemonTemp.encounterTriggered = true
  end
  $PokemonTemp.forceSingleBattle = false
  EncounterModifier.triggerEncounterEnd
end



#===============================================================================
# Checks when moving between maps
#===============================================================================
# Clears the weather of the old map, if the old map has defined weather and the
# new map either has the same name as the old map or doesn't have defined
# weather.
Events.onMapChanging += proc { |_sender, e|
  new_map_ID = e[0]
  next if new_map_ID == 0
  old_map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
  next if !old_map_metadata || !old_map_metadata.weather
  map_infos = pbLoadMapInfos
  if $game_map.name == map_infos[new_map_ID].name
    new_map_metadata = GameData::MapMetadata.try_get(new_map_ID)
    next if new_map_metadata && new_map_metadata.weather
  end
  $game_screen.weather(PBFieldWeather::None, 0, 0)
}

# Set up various data related to the new map
Events.onMapChange += proc { |_sender, e|
  old_map_ID = e[0]   # previous map ID, is 0 if no map ID
  new_map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
  if new_map_metadata && new_map_metadata.teleport_destination
    $PokemonGlobal.healingSpot = new_map_metadata.teleport_destination
  end
  $PokemonMap.clear if $PokemonMap
  $PokemonEncounters.setup($game_map.map_id) if $PokemonEncounters
  $PokemonGlobal.visitedMaps[$game_map.map_id] = true
  next if old_map_ID == 0 || old_map_ID == $game_map.map_id
  next if !new_map_metadata || !new_map_metadata.weather
  map_infos = pbLoadMapInfos
  if $game_map.name == map_infos[old_map_ID].name
    old_map_metadata = GameData::MapMetadata.try_get(old_map_ID)
    next if old_map_metadata && old_map_metadata.weather
  end
  new_weather = new_map_metadata.weather
  $game_screen.weather(new_weather[0], 9, 0) if rand(100) < new_weather[1]
}

Events.onMapSceneChange += proc { |_sender, e|
  scene      = e[0]
  mapChanged = e[1]
  next if !scene || !scene.spriteset
  # Update map trail
  if $game_map
    $PokemonGlobal.mapTrail = [] if !$PokemonGlobal.mapTrail
    if $PokemonGlobal.mapTrail[0] != $game_map.map_id
      $PokemonGlobal.mapTrail.pop if $PokemonGlobal.mapTrail.length >= 4
    end
    $PokemonGlobal.mapTrail = [$game_map.map_id] + $PokemonGlobal.mapTrail
  end
  # Display darkness circle on dark maps
  map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
  if map_metadata && map_metadata.dark_map
    $PokemonTemp.darknessSprite = DarknessSprite.new
    scene.spriteset.addUserSprite($PokemonTemp.darknessSprite)
    if $PokemonGlobal.flashUsed
      $PokemonTemp.darknessSprite.radius = $PokemonTemp.darknessSprite.radiusMax
    end
  else
    $PokemonGlobal.flashUsed = false
    $PokemonTemp.darknessSprite.dispose if $PokemonTemp.darknessSprite
    $PokemonTemp.darknessSprite = nil
  end
  # Show location signpost
  if mapChanged && map_metadata && map_metadata.announce_location
    nosignpost = false
    if $PokemonGlobal.mapTrail[1]
      for i in 0...Settings::NO_SIGNPOSTS.length / 2
        nosignpost = true if Settings::NO_SIGNPOSTS[2 * i] == $PokemonGlobal.mapTrail[1] &&
                             Settings::NO_SIGNPOSTS[2 * i + 1] == $game_map.map_id
        nosignpost = true if Settings::NO_SIGNPOSTS[2 * i + 1] == $PokemonGlobal.mapTrail[1] &&
                             Settings::NO_SIGNPOSTS[2 * i] == $game_map.map_id
        break if nosignpost
      end
      mapinfos = pbLoadMapInfos
      oldmapname = mapinfos[$PokemonGlobal.mapTrail[1]].name
      nosignpost = true if $game_map.name == oldmapname
    end
    scene.spriteset.addUserSprite(LocationWindow.new($game_map.name)) if !nosignpost
  end
  # Force cycling/walking
  if map_metadata && map_metadata.always_bicycle
    pbMountBike
  elsif !pbCanUseBike?($game_map.map_id)
    pbDismountBike
  end
}



#===============================================================================
# Event locations, terrain tags
#===============================================================================
def pbEventFacesPlayer?(event,player,distance)
  return false if distance<=0
  # Event can't reach player if no coordinates coincide
  return false if event.x!=player.x && event.y!=player.y
  deltaX = (event.direction==6) ? 1 : (event.direction==4) ? -1 : 0
  deltaY = (event.direction==2) ? 1 : (event.direction==8) ? -1 : 0
  # Check for existence of player
  curx = event.x
  cury = event.y
  found = false
  distance.times do
    curx += deltaX
    cury += deltaY
    if player.x==curx && player.y==cury
      found = true
      break
    end
  end
  return found
end

def pbEventCanReachPlayer?(event,player,distance)
  return false if distance<=0
  # Event can't reach player if no coordinates coincide
  return false if event.x!=player.x && event.y!=player.y
  deltaX = (event.direction==6) ? 1 : (event.direction==4) ? -1 : 0
  deltaY = (event.direction==2) ? 1 : (event.direction==8) ? -1 : 0
  # Check for existence of player
  curx = event.x
  cury = event.y
  found = false
  realdist = 0
  distance.times do
    curx += deltaX
    cury += deltaY
    if player.x==curx && player.y==cury
      found = true
      break
    end
    realdist += 1
  end
  return false if !found
  # Check passibility
  curx = event.x
  cury = event.y
  realdist.times do
    return false if !event.passable?(curx,cury,event.direction)
    curx += deltaX
    cury += deltaY
  end
  return true
end

def pbFacingTileRegular(direction=nil,event=nil)
  event = $game_player if !event
  return [0,0,0] if !event
  x = event.x
  y = event.y
  direction = event.direction if !direction
  case direction
  when 1
    y += 1
    x -= 1
  when 2
    y += 1
  when 3
    y += 1
    x += 1
  when 4
    x -= 1
  when 6
    x += 1
  when 7
    y -= 1
    x -= 1
  when 8
    y -= 1
  when 9
    y -= 1
    x += 1
  end
  return [$game_map.map_id,x,y]
end

def pbFacingTile(direction=nil,event=nil)
  return $MapFactory.getFacingTile(direction,event) if $MapFactory
  return pbFacingTileRegular(direction,event)
end

def pbFacingEachOther(event1,event2)
  return false if !event1 || !event2
  if $MapFactory
    tile1 = $MapFactory.getFacingTile(nil,event1)
    tile2 = $MapFactory.getFacingTile(nil,event2)
    return false if !tile1 || !tile2
    return tile1[0]==event2.map.map_id &&
           tile1[1]==event2.x && tile1[2]==event2.y &&
           tile2[0]==event1.map.map_id &&
           tile2[1]==event1.x && tile2[2]==event1.y
  else
    tile1 = pbFacingTile(nil,event1)
    tile2 = pbFacingTile(nil,event2)
    return false if !tile1 || !tile2
    return tile1[1]==event2.x && tile1[2]==event2.y &&
           tile2[1]==event1.x && tile2[2]==event1.y
  end
end

def pbGetTerrainTag(event=nil,countBridge=false)
  event = $game_player if !event
  return 0 if !event
  if $MapFactory
    return $MapFactory.getTerrainTag(event.map.map_id,event.x,event.y,countBridge)
  end
  $game_map.terrain_tag(event.x,event.y,countBridge)
end

def pbFacingTerrainTag(event=nil,dir=nil)
  if $MapFactory
    return $MapFactory.getFacingTerrainTag(dir,event)
  end
  event = $game_player if !event
  return 0 if !event
  facing = pbFacingTile(dir,event)
  return $game_map.terrain_tag(facing[1],facing[2])
end



#===============================================================================
# Audio playing
#===============================================================================
def pbCueBGM(bgm,seconds,volume=nil,pitch=nil)
  return if !bgm
  bgm        = pbResolveAudioFile(bgm,volume,pitch)
  playingBGM = $game_system.playing_bgm
  if !playingBGM || playingBGM.name!=bgm.name || playingBGM.pitch!=bgm.pitch
    pbBGMFade(seconds)
    if !$PokemonTemp.cueFrames
      $PokemonTemp.cueFrames = (seconds*Graphics.frame_rate)*3/5
    end
    $PokemonTemp.cueBGM=bgm
  elsif playingBGM
    pbBGMPlay(bgm)
  end
end

def pbAutoplayOnTransition
  surfbgm = GameData::Metadata.get.surf_BGM
  if $PokemonGlobal.surfing && surfbgm
    pbBGMPlay(surfbgm)
  else
    $game_map.autoplayAsCue
  end
end

def pbAutoplayOnSave
  surfbgm = GameData::Metadata.get.surf_BGM
  if $PokemonGlobal.surfing && surfbgm
    pbBGMPlay(surfbgm)
  else
    $game_map.autoplay
  end
end



#===============================================================================
# Event movement
#===============================================================================
module PBMoveRoute
  Down               = 1
  Left               = 2
  Right              = 3
  Up                 = 4
  LowerLeft          = 5
  LowerRight         = 6
  UpperLeft          = 7
  UpperRight         = 8
  Random             = 9
  TowardPlayer       = 10
  AwayFromPlayer     = 11
  Forward            = 12
  Backward           = 13
  Jump               = 14 # xoffset, yoffset
  Wait               = 15 # frames
  TurnDown           = 16
  TurnLeft           = 17
  TurnRight          = 18
  TurnUp             = 19
  TurnRight90        = 20
  TurnLeft90         = 21
  Turn180            = 22
  TurnRightOrLeft90  = 23
  TurnRandom         = 24
  TurnTowardPlayer   = 25
  TurnAwayFromPlayer = 26
  SwitchOn           = 27 # 1 param
  SwitchOff          = 28 # 1 param
  ChangeSpeed        = 29 # 1 param
  ChangeFreq         = 30 # 1 param
  WalkAnimeOn        = 31
  WalkAnimeOff       = 32
  StepAnimeOn        = 33
  StepAnimeOff       = 34
  DirectionFixOn     = 35
  DirectionFixOff    = 36
  ThroughOn          = 37
  ThroughOff         = 38
  AlwaysOnTopOn      = 39
  AlwaysOnTopOff     = 40
  Graphic            = 41 # Name, hue, direction, pattern
  Opacity            = 42 # 1 param
  Blending           = 43 # 1 param
  PlaySE             = 44 # 1 param
  Script             = 45 # 1 param
  ScriptAsync        = 101 # 1 param
end



def pbMoveRoute(event,commands,waitComplete=false)
  route = RPG::MoveRoute.new
  route.repeat    = false
  route.skippable = true
  route.list.clear
  route.list.push(RPG::MoveCommand.new(PBMoveRoute::ThroughOn))
  i=0
  while i<commands.length
    case commands[i]
    when PBMoveRoute::Wait, PBMoveRoute::SwitchOn, PBMoveRoute::SwitchOff,
       PBMoveRoute::ChangeSpeed, PBMoveRoute::ChangeFreq, PBMoveRoute::Opacity,
       PBMoveRoute::Blending, PBMoveRoute::PlaySE, PBMoveRoute::Script
      route.list.push(RPG::MoveCommand.new(commands[i],[commands[i+1]]))
      i += 1
    when PBMoveRoute::ScriptAsync
      route.list.push(RPG::MoveCommand.new(PBMoveRoute::Script,[commands[i+1]]))
      route.list.push(RPG::MoveCommand.new(PBMoveRoute::Wait,[0]))
      i += 1
    when PBMoveRoute::Jump
      route.list.push(RPG::MoveCommand.new(commands[i],[commands[i+1],commands[i+2]]))
      i += 2
    when PBMoveRoute::Graphic
      route.list.push(RPG::MoveCommand.new(commands[i],
         [commands[i+1],commands[i+2],commands[i+3],commands[i+4]]))
      i += 4
    else
      route.list.push(RPG::MoveCommand.new(commands[i]))
    end
    i += 1
  end
  route.list.push(RPG::MoveCommand.new(PBMoveRoute::ThroughOff))
  route.list.push(RPG::MoveCommand.new(0))
  if event
    event.force_move_route(route)
  end
  return route
end

def pbWait(numFrames)
  numFrames.times do
    Graphics.update
    Input.update
    pbUpdateSceneMap
  end
end



#===============================================================================
# Player/event movement in the field
#===============================================================================
def pbLedge(_xOffset,_yOffset)
  if PBTerrain.isLedge?(pbFacingTerrainTag)
    if pbJumpToward(2,true)
      $scene.spriteset.addUserAnimation(Settings::DUST_ANIMATION_ID,$game_player.x,$game_player.y,true,1)
      $game_player.increase_steps
      $game_player.check_event_trigger_here([1,2])
    end
    return true
  end
  return false
end

def pbSlideOnIce(event=nil)
  event = $game_player if !event
  return if !event
  return if !PBTerrain.isIce?(pbGetTerrainTag(event))
  $PokemonGlobal.sliding = true
  direction    = event.direction
  oldwalkanime = event.walk_anime
  event.straighten
  event.walk_anime = false
  loop do
    break if !event.passable?(event.x,event.y,direction)
    break if !PBTerrain.isIce?(pbGetTerrainTag(event))
    event.move_forward
    while event.moving?
      pbUpdateSceneMap
      Graphics.update
      Input.update
    end
  end
  event.center(event.x,event.y)
  event.straighten
  event.walk_anime = oldwalkanime
  $PokemonGlobal.sliding = false
end

def pbTurnTowardEvent(event,otherEvent)
  sx = 0; sy = 0
  if $MapFactory
    relativePos = $MapFactory.getThisAndOtherEventRelativePos(otherEvent,event)
    sx = relativePos[0]
    sy = relativePos[1]
  else
    sx = event.x - otherEvent.x
    sy = event.y - otherEvent.y
  end
  return if sx == 0 and sy == 0
  if sx.abs > sy.abs
    (sx > 0) ? event.turn_left : event.turn_right
  else
    (sy > 0) ? event.turn_up : event.turn_down
  end
end

def pbMoveTowardPlayer(event)
  maxsize = [$game_map.width,$game_map.height].max
  return if !pbEventCanReachPlayer?(event,$game_player,maxsize)
  loop do
    x = event.x
    y = event.y
    event.move_toward_player
    break if event.x==x && event.y==y
    while event.moving?
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
  end
  $PokemonMap.addMovedEvent(event.id) if $PokemonMap
end

def pbJumpToward(dist=1,playSound=false,cancelSurf=false)
  x = $game_player.x
  y = $game_player.y
  case $game_player.direction
  when 2 then $game_player.jump(0, dist)    # down
  when 4 then $game_player.jump(-dist, 0)   # left
  when 6 then $game_player.jump(dist, 0)    # right
  when 8 then $game_player.jump(0, -dist)   # up
  end
  if $game_player.x!=x || $game_player.y!=y
    pbSEPlay("Player jump") if playSound
    $PokemonEncounters.reset_step_count if cancelSurf
    $PokemonTemp.endSurf = true if cancelSurf
    while $game_player.jumping?
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
    return true
  end
  return false
end



#===============================================================================
# Fishing
#===============================================================================
def pbFishingBegin
  $PokemonGlobal.fishing = true
  if !pbCommonEvent(Settings::FISHING_BEGIN_COMMON_EVENT)
    patternb = 2*$game_player.direction - 1
    meta = GameData::Metadata.get_player($PokemonGlobal.playerID)
    num = ($PokemonGlobal.surfing) ? 7 : 6
    if meta && meta[num] && meta[num]!=""
      charset = pbGetPlayerCharset(meta,num)
      4.times do |pattern|
        $game_player.setDefaultCharName(charset,patternb-pattern,true)
        (Graphics.frame_rate/20).times do
          Graphics.update
          Input.update
          pbUpdateSceneMap
        end
      end
    end
  end
end

def pbFishingEnd
  if !pbCommonEvent(Settings::FISHING_END_COMMON_EVENT)
    patternb = 2*($game_player.direction - 2)
    meta = GameData::Metadata.get_player($PokemonGlobal.playerID)
    num = ($PokemonGlobal.surfing) ? 7 : 6
    if meta && meta[num] && meta[num]!=""
      charset = pbGetPlayerCharset(meta,num)
      4.times do |pattern|
        $game_player.setDefaultCharName(charset,patternb+pattern,true)
        (Graphics.frame_rate/20).times do
          Graphics.update
          Input.update
          pbUpdateSceneMap
        end
      end
    end
  end
  $PokemonGlobal.fishing = false
end

def pbFishing(hasEncounter,rodType=1)
  speedup = ($Trainer.first_pokemon && [:STICKYHOLD, :SUCTIONCUPS].include?($Trainer.first_pokemon.ability_id))
  biteChance = 20+(25*rodType)   # 45, 70, 95
  biteChance *= 1.5 if speedup   # 67.5, 100, 100
  hookChance = 100
  oldpattern = $game_player.fullPattern
  pbFishingBegin
  msgWindow = pbCreateMessageWindow
  ret = false
  loop do
    time = 5+rand(6)
    time = [time,5+rand(6)].min if speedup
    message = ""
    time.times { message += ".   " }
    if pbWaitMessage(msgWindow,time)
      pbFishingEnd
      $game_player.setDefaultCharName(nil,oldpattern)
      pbMessageDisplay(msgWindow,_INTL("Not even a nibble..."))
      break
    end
    if hasEncounter && rand(100)<biteChance
      $scene.spriteset.addUserAnimation(Settings::EXCLAMATION_ANIMATION_ID,$game_player.x,$game_player.y,true,3)
      frames = Graphics.frame_rate - rand(Graphics.frame_rate/2)   # 0.5-1 second
      if !pbWaitForInput(msgWindow,message+_INTL("\r\nOh! A bite!"),frames)
        pbFishingEnd
        $game_player.setDefaultCharName(nil,oldpattern)
        pbMessageDisplay(msgWindow,_INTL("The Pokémon got away..."))
        break
      end
      if Settings::FISHING_AUTO_HOOK || rand(100) < hookChance
        pbFishingEnd
        pbMessageDisplay(msgWindow,_INTL("Landed a Pokémon!")) if !Settings::FISHING_AUTO_HOOK
        $game_player.setDefaultCharName(nil,oldpattern)
        ret = true
        break
      end
#      biteChance += 15
#      hookChance += 15
    else
      pbFishingEnd
      $game_player.setDefaultCharName(nil,oldpattern)
      pbMessageDisplay(msgWindow,_INTL("Not even a nibble..."))
      break
    end
  end
  pbDisposeMessageWindow(msgWindow)
  return ret
end

# Show waiting dots before a Pokémon bites
def pbWaitMessage(msgWindow,time)
  message = ""
  periodTime = Graphics.frame_rate*4/10   # 0.4 seconds, 16 frames per dot
  (time+1).times do |i|
    message += ".   " if i>0
    pbMessageDisplay(msgWindow,message,false)
    periodTime.times do
      Graphics.update
      Input.update
      pbUpdateSceneMap
      if Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
        return true
      end
    end
  end
  return false
end

# A Pokémon is biting, reflex test to reel it in
def pbWaitForInput(msgWindow,message,frames)
  pbMessageDisplay(msgWindow,message,false)
  numFrame = 0
  twitchFrame = 0
  twitchFrameTime = Graphics.frame_rate/10   # 0.1 seconds, 4 frames
  loop do
    Graphics.update
    Input.update
    pbUpdateSceneMap
    # Twitch cycle: 1,0,1,0,0,0,0,0
    twitchFrame = (twitchFrame+1)%(twitchFrameTime*8)
    case twitchFrame%twitchFrameTime
    when 0, 2
      $game_player.pattern = 1
    else
      $game_player.pattern = 0
    end
    if Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
      $game_player.pattern = 0
      return true
    end
    break if !Settings::FISHING_AUTO_HOOK && numFrame > frames
    numFrame += 1
  end
  return false
end



#===============================================================================
# Bridges, cave escape points, and setting the heal point
#===============================================================================
def pbBridgeOn(height=2)
  $PokemonGlobal.bridge = height
end

def pbBridgeOff
  $PokemonGlobal.bridge = 0
end

def pbSetEscapePoint
  $PokemonGlobal.escapePoint = [] if !$PokemonGlobal.escapePoint
  xco = $game_player.x
  yco = $game_player.y
  case $game_player.direction
  when 2   # Down
    yco -= 1
    dir = 8
  when 4   # Left
    xco += 1
    dir = 6
  when 6   # Right
    xco -= 1
    dir = 4
  when 8   # Up
    yco += 1
    dir = 2
  end
  $PokemonGlobal.escapePoint = [$game_map.map_id,xco,yco,dir]
end

def pbEraseEscapePoint
  $PokemonGlobal.escapePoint = []
end

def pbSetPokemonCenter
  $PokemonGlobal.pokecenterMapId     = $game_map.map_id
  $PokemonGlobal.pokecenterX         = $game_player.x
  $PokemonGlobal.pokecenterY         = $game_player.y
  $PokemonGlobal.pokecenterDirection = $game_player.direction
end



#===============================================================================
# Partner trainer
#===============================================================================
def pbRegisterPartner(tr_type, tr_name, tr_id = 0)
  tr_type = GameData::TrainerType.get(tr_type).id
  pbCancelVehicles
  trainer = pbLoadTrainer(tr_type, tr_name, tr_id)
  Events.onTrainerPartyLoad.trigger(nil, trainer)
  for i in trainer.party
    i.owner = Pokemon::Owner.new_from_trainer(trainer)
    i.calcStats
  end
  $PokemonGlobal.partner = [tr_type, tr_name, trainer.id, trainer.party]
end

def pbDeregisterPartner
  $PokemonGlobal.partner = nil
end



#===============================================================================
# Picking up an item found on the ground
#===============================================================================
def pbItemBall(item,quantity=1)
  item = GameData::Item.get(item)
  return false if !item || quantity<1
  itemname = (quantity>1) ? item.name_plural : item.name
  pocket = item.pocket
  move = item.move
  if $PokemonBag.pbStoreItem(item,quantity)   # If item can be picked up
    meName = (item.is_key_item?) ? "Key item get" : "Item get"
    if item == :LEFTOVERS
      pbMessage(_INTL("\\me[{1}]You found some \\c[1]{2}\\c[0]!\\wtnp[30]",meName,itemname))
    elsif item.is_machine?   # TM or HM
      pbMessage(_INTL("\\me[{1}]You found \\c[1]{2} {3}\\c[0]!\\wtnp[30]",meName,itemname,GameData::Move.get(move).name))
    elsif quantity>1
      pbMessage(_INTL("\\me[{1}]You found {2} \\c[1]{3}\\c[0]!\\wtnp[30]",meName,quantity,itemname))
    elsif itemname.starts_with_vowel?
      pbMessage(_INTL("\\me[{1}]You found an \\c[1]{2}\\c[0]!\\wtnp[30]",meName,itemname))
    else
      pbMessage(_INTL("\\me[{1}]You found a \\c[1]{2}\\c[0]!\\wtnp[30]",meName,itemname))
    end
    pbMessage(_INTL("You put the {1} away\\nin the <icon=bagPocket{2}>\\c[1]{3} Pocket\\c[0].",
       itemname,pocket,PokemonBag.pocketNames()[pocket]))
    return true
  end
  # Can't add the item
  if item == :LEFTOVERS
    pbMessage(_INTL("You found some \\c[1]{1}\\c[0]!\\wtnp[30]",itemname))
  elsif item.is_machine?   # TM or HM
    pbMessage(_INTL("You found \\c[1]{1} {2}\\c[0]!\\wtnp[30]",itemname,GameData::Move.get(move).name))
  elsif quantity>1
    pbMessage(_INTL("You found {1} \\c[1]{2}\\c[0]!\\wtnp[30]",quantity,itemname))
  elsif itemname.starts_with_vowel?
    pbMessage(_INTL("You found an \\c[1]{1}\\c[0]!\\wtnp[30]",itemname))
  else
    pbMessage(_INTL("You found a \\c[1]{1}\\c[0]!\\wtnp[30]",itemname))
  end
  pbMessage(_INTL("But your Bag is full..."))
  return false
end



#===============================================================================
# Being given an item
#===============================================================================
def pbReceiveItem(item,quantity=1)
  item = GameData::Item.get(item)
  return false if !item || quantity<1
  itemname = (quantity>1) ? item.name_plural : item.name
  pocket = item.pocket
  move = item.move
  meName = (item.is_key_item?) ? "Key item get" : "Item get"
  if item == :LEFTOVERS
    pbMessage(_INTL("\\me[{1}]You obtained some \\c[1]{2}\\c[0]!\\wtnp[30]",meName,itemname))
  elsif item.is_machine?   # TM or HM
    pbMessage(_INTL("\\me[{1}]You obtained \\c[1]{2} {3}\\c[0]!\\wtnp[30]",meName,itemname,GameData::Move.get(move).name))
  elsif quantity>1
    pbMessage(_INTL("\\me[{1}]You obtained {2} \\c[1]{3}\\c[0]!\\wtnp[30]",meName,quantity,itemname))
  elsif itemname.starts_with_vowel?
    pbMessage(_INTL("\\me[{1}]You obtained an \\c[1]{2}\\c[0]!\\wtnp[30]",meName,itemname))
  else
    pbMessage(_INTL("\\me[{1}]You obtained a \\c[1]{2}\\c[0]!\\wtnp[30]",meName,itemname))
  end
  if $PokemonBag.pbStoreItem(item,quantity)   # If item can be added
    pbMessage(_INTL("You put the {1} away\\nin the <icon=bagPocket{2}>\\c[1]{3} Pocket\\c[0].",
       itemname,pocket,PokemonBag.pocketNames()[pocket]))
    return true
  end
  return false   # Can't add the item
end
