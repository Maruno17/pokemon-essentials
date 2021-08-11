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
          pbFlash(Color.new(255, 0, 0, 128), 8)
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
  event = e[0]   # Get the event affected by field movement
  thistile = $MapFactory.getRealTilePos(event.map.map_id,event.x,event.y)
  map = $MapFactory.getMap(thistile[0])
  for i in [2, 1, 0]
    tile_id = map.data[thistile[1],thistile[2],i]
    next if tile_id == nil
    next if GameData::TerrainTag.try_get(map.terrain_tags[tile_id]).id != :SootGrass
    if event == $game_player && GameData::Item.exists?(:SOOTSACK)
      $Trainer.soot += 1 if $PokemonBag.pbHasItem?(:SOOTSACK)
    end
#    map.data[thistile[1], thistile[2], i] = 0
#    $scene.createSingleSpriteset(map.map_id)
    break
  end
}

# Show grass rustle animation, and auto-move the player over waterfalls and ice
Events.onStepTakenFieldMovement += proc { |_sender, e|
  event = e[0]   # Get the event affected by field movement
  if $scene.is_a?(Scene_Map)
    event.each_occupied_tile do |x, y|
      if $MapFactory.getTerrainTag(event.map.map_id, x, y, true).shows_grass_rustle
        $scene.spriteset.addUserAnimation(Settings::GRASS_ANIMATION_ID, x, y, true, 1)
      end
    end
    if event == $game_player
      currentTag = $game_player.pbTerrainTag
      if currentTag.waterfall_crest
        pbDescendWaterfall
      elsif currentTag.ice && !$PokemonGlobal.sliding
        pbSlideOnIce
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
  $game_screen.weather(:None, 0, 0)
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
# NOTE: Assumes the event is 1x1 tile in size. Only returns one tile.
def pbFacingTile(direction=nil,event=nil)
  return $MapFactory.getFacingTile(direction,event) if $MapFactory
  return pbFacingTileRegular(direction,event)
end

# NOTE: Assumes the event is 1x1 tile in size. Only returns one tile.
def pbFacingTileRegular(direction = nil, event = nil)
  event = $game_player if !event
  return [0, 0, 0] if !event
  x = event.x
  y = event.y
  direction = event.direction if !direction
  x_offset = [0, -1, 0, 1, -1, 0, 1, -1, 0, 1][direction]
  y_offset = [0, 1, 1, 1, 0, 0, 0, -1, -1, -1][direction]
  return [$game_map.map_id, x + x_offset, y + y_offset]
end

# Returns whether event is in line with the player, is facing the player and is
# within distance tiles of the player.
def pbEventFacesPlayer?(event, player, distance)
  return false if !event || !player || distance <= 0
  x_min = x_max = y_min = y_max = -1
  case event.direction
  when 2   # Down
    x_min = event.x
    x_max = event.x + event.width - 1
    y_min = event.y + 1
    y_max = event.y + distance
  when 4   # Left
    x_min = event.x - distance
    x_max = event.x - 1
    y_min = event.y - event.height + 1
    y_max = event.y
  when 6   # Right
    x_min = event.x + event.width
    x_max = event.x + event.width - 1 + distance
    y_min = event.y - event.height + 1
    y_max = event.y
  when 8   # Up
    x_min = event.x
    x_max = event.x + event.width - 1
    y_min = event.y - event.height + 1 - distance
    y_max = event.y - event.height
  else
    return false
  end
  return player.x >= x_min && player.x <= x_max &&
         player.y >= y_min && player.y <= y_max
end

# Returns whether event is able to walk up to the player.
def pbEventCanReachPlayer?(event, player, distance)
  return false if !pbEventFacesPlayer?(event, player, distance)
  delta_x = (event.direction == 6) ? 1 : (event.direction == 4) ? -1 : 0
  delta_y = (event.direction == 2) ? 1 : (event.direction == 8) ? -1 : 0
  case event.direction
  when 2   # Down
    real_distance = player.y - event.y - 1
  when 4   # Left
    real_distance = event.x - player.x - 1
  when 6   # Right
    real_distance = player.x - event.x - event.width
  when 8   # Up
    real_distance = event.y - event.height - player.y
  end
  if real_distance > 0
    real_distance.times do |i|
      return false if !event.can_move_from_coordinate?(event.x + i * delta_x, event.y + i * delta_y, event.direction)
    end
  end
  return true
end

# Returns whether the two events are standing next to each other and facing each
# other.
def pbFacingEachOther(event1, event2)
  return pbEventFacesPlayer?(event1, event2, 1) && pbEventFacesPlayer?(event2, event1, 1)
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
  if $game_player.pbFacingTerrainTag.ledge
    if pbJumpToward(2,true)
      $scene.spriteset.addUserAnimation(Settings::DUST_ANIMATION_ID,$game_player.x,$game_player.y,true,1)
      $game_player.increase_steps
      $game_player.check_event_trigger_here([1,2])
    end
    return true
  end
  return false
end

def pbSlideOnIce
  return if !$game_player.pbTerrainTag.ice
  $PokemonGlobal.sliding = true
  direction    = $game_player.direction
  oldwalkanime = $game_player.walk_anime
  $game_player.straighten
  $game_player.walk_anime = false
  loop do
    break if !$game_player.can_move_in_direction?(direction)
    break if !$game_player.pbTerrainTag.ice
    $game_player.move_forward
    while $game_player.moving?
      pbUpdateSceneMap
      Graphics.update
      Input.update
    end
  end
  $game_player.center($game_player.x, $game_player.y)
  $game_player.straighten
  $game_player.walk_anime = oldwalkanime
  $PokemonGlobal.sliding = false
end

def pbTurnTowardEvent(event,otherEvent)
  sx = 0
  sy = 0
  if $MapFactory
    relativePos = $MapFactory.getThisAndOtherEventRelativePos(otherEvent,event)
    sx = relativePos[0]
    sy = relativePos[1]
  else
    sx = event.x - otherEvent.x
    sy = event.y - otherEvent.y
  end
  sx += (event.width - otherEvent.width) / 2.0
  sy -= (event.height - otherEvent.height) / 2.0
  return if sx == 0 && sy == 0
  if sx.abs > sy.abs
    (sx > 0) ? event.turn_left : event.turn_right
  else
    (sy > 0) ? event.turn_up : event.turn_down
  end
end

def pbMoveTowardPlayer(event)
  maxsize = [$game_map.width, $game_map.height].max
  return if !pbEventCanReachPlayer?(event, $game_player, maxsize)
  loop do
    x = event.x
    y = event.y
    event.move_toward_player
    break if event.x == x && event.y == y
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
    i.calc_stats
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
