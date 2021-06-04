#===============================================================================
# ** Game_Player
#-------------------------------------------------------------------------------
#  This class handles the player. Its functions include event starting
#  determinants and map scrolling. Refer to "$game_player" for the one
#  instance of this class.
#===============================================================================
class Game_Player < Game_Character
  attr_accessor :bump_se
  attr_accessor :charsetData
  attr_accessor :encounter_count

  SCREEN_CENTER_X = (Settings::SCREEN_WIDTH / 2 - Game_Map::TILE_WIDTH / 2) * Game_Map::X_SUBPIXELS
  SCREEN_CENTER_Y = (Settings::SCREEN_HEIGHT / 2 - Game_Map::TILE_HEIGHT / 2) * Game_Map::Y_SUBPIXELS

  def initialize(*arg)
    super(*arg)
    @lastdir=0
    @lastdirframe=0
    @bump_se=0
  end

  def map
    @map = nil
    return $game_map
  end

  def pbHasDependentEvents?
    return $PokemonGlobal.dependentEvents.length>0
  end

  def bump_into_object
    return if @bump_se && @bump_se>0
    pbSEPlay("Player bump")
    @bump_se = Graphics.frame_rate/4
  end

  def move_generic(dir, turn_enabled = true)
    turn_generic(dir, true) if turn_enabled
    if !$PokemonTemp.encounterTriggered
      if can_move_in_direction?(dir)
        x_offset = (dir == 4) ? -1 : (dir == 6) ? 1 : 0
        y_offset = (dir == 8) ? -1 : (dir == 2) ? 1 : 0
        return if pbLedge(x_offset, y_offset)
        return if pbEndSurf(x_offset, y_offset)
        turn_generic(dir, true)
        if !$PokemonTemp.encounterTriggered
          @x += x_offset
          @y += y_offset
          $PokemonTemp.dependentEvents.pbMoveDependentEvents
          increase_steps
        end
      elsif !check_event_trigger_touch(dir)
        bump_into_object
      end
    end
    $PokemonTemp.encounterTriggered = false
  end

  def turn_generic(dir, keep_enc_indicator = false)
    old_direction = @direction
    super(dir)
    if @direction != old_direction && !@move_route_forcing && !pbMapInterpreterRunning?
      Events.onChangeDirection.trigger(self, self)
      $PokemonTemp.encounterTriggered = false if !keep_enc_indicator
    end
  end

  def pbTriggeredTrainerEvents(triggers,checkIfRunning=true)
    result = []
    # If event is running
    return result if checkIfRunning && $game_system.map_interpreter.running?
    # All event loops
    for event in $game_map.events.values
      next if !event.name[/trainer\((\d+)\)/i]
      distance = $~[1].to_i
      # If event coordinates and triggers are consistent
      if pbEventCanReachPlayer?(event,self,distance) && triggers.include?(event.trigger)
        # If starting determinant is front event (other than jumping)
        result.push(event) if !event.jumping? && !event.over_trigger?
      end
    end
    return result
  end

  def pbTriggeredCounterEvents(triggers,checkIfRunning=true)
    result = []
    # If event is running
    return result if checkIfRunning && $game_system.map_interpreter.running?
    # All event loops
    for event in $game_map.events.values
      next if !event.name[/counter\((\d+)\)/i]
      distance = $~[1].to_i
      # If event coordinates and triggers are consistent
      if pbEventFacesPlayer?(event,self,distance) && triggers.include?(event.trigger)
        # If starting determinant is front event (other than jumping)
        result.push(event) if !event.jumping? && !event.over_trigger?
      end
    end
    return result
  end

  def pbCheckEventTriggerAfterTurning; end

  def pbCheckEventTriggerFromDistance(triggers)
    ret = pbTriggeredTrainerEvents(triggers)
    ret.concat(pbTriggeredCounterEvents(triggers))
    return false if ret.length==0
    for event in ret
      event.start
    end
    return true
  end

  def pbTerrainTag(countBridge = false)
    return $MapFactory.getTerrainTag(self.map.map_id, @x, @y, countBridge) if $MapFactory
    return $game_map.terrain_tag(@x, @y, countBridge)
  end

  def pbFacingEvent(ignoreInterpreter=false)
    return nil if $game_system.map_interpreter.running? && !ignoreInterpreter
    # Check the tile in front of the player for events
    new_x = @x + (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
    new_y = @y + (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
    return nil if !$game_map.valid?(new_x, new_y)
    for event in $game_map.events.values
      next if !event.at_coordinate?(new_x, new_y)
      next if event.jumping? || event.over_trigger?
      return event
    end
    # If the tile in front is a counter, check one tile beyond that for events
    if $game_map.counter?(new_x, new_y)
      new_x += (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
      new_y += (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
      for event in $game_map.events.values
        next if !event.at_coordinate?(new_x, new_y)
        next if event.jumping? || event.over_trigger?
        return event
      end
    end
    return nil
  end

  def pbFacingTerrainTag(dir = nil)
    dir = self.direction if !dir
    return $MapFactory.getFacingTerrainTag(dir, self) if $MapFactory
    facing = pbFacingTile(dir, self)
    return $game_map.terrain_tag(facing[1], facing[2])
  end

  #-----------------------------------------------------------------------------
  # * Passable Determinants
  #     x : x-coordinate
  #     y : y-coordinate
  #     d : direction (0,2,4,6,8)
  #         * 0 = Determines if all directions are impassable (for jumping)
  #-----------------------------------------------------------------------------
  def passable?(x, y, d, strict = false)
    # Get new coordinates
    new_x = x + (d == 6 ? 1 : d == 4 ? -1 : 0)
    new_y = y + (d == 2 ? 1 : d == 8 ? -1 : 0)
    # If coordinates are outside of map
    return false if !$game_map.validLax?(new_x, new_y)
    if !$game_map.valid?(new_x, new_y)
      return false if !$MapFactory
      return $MapFactory.isPassableFromEdge?(new_x, new_y)
    end
    # If debug mode is ON and Ctrl key was pressed
    return true if $DEBUG && Input.press?(Input::CTRL)
    return super
  end

  #-----------------------------------------------------------------------------
  # * Set Map Display Position to Center of Screen
  #-----------------------------------------------------------------------------
  def center(x, y)
    self.map.display_x = x * Game_Map::REAL_RES_X - SCREEN_CENTER_X
    self.map.display_y = y * Game_Map::REAL_RES_Y - SCREEN_CENTER_Y
  end

  #-----------------------------------------------------------------------------
  # * Move to Designated Position
  #     x : x-coordinate
  #     y : y-coordinate
  #-----------------------------------------------------------------------------
  def moveto(x, y)
    super
    # Centering
    center(x, y)
    # Make encounter count
    make_encounter_count
  end

  #-----------------------------------------------------------------------------
  # * Make Encounter Count
  #-----------------------------------------------------------------------------
  def make_encounter_count
    # Image of two dice rolling
    if $game_map.map_id != 0
      n = $game_map.encounter_step
      @encounter_count = rand(n) + rand(n) + 1
    end
  end

  #-----------------------------------------------------------------------------
  # * Refresh
  #-----------------------------------------------------------------------------
  def refresh
    @opacity    = 255
    @blend_type = 0
  end

  #-----------------------------------------------------------------------------
  # * Trigger event(s) at the same coordinates as self with the appropriate
  #   trigger(s) that can be triggered
  #-----------------------------------------------------------------------------
  def check_event_trigger_here(triggers)
    result = false
    # If event is running
    return result if $game_system.map_interpreter.running?
    # All event loops
    for event in $game_map.events.values
      # If event coordinates and triggers are consistent
      next if !event.at_coordinate?(@x, @y)
      next if !triggers.include?(event.trigger)
      # If starting determinant is same position event (other than jumping)
      next if event.jumping? || !event.over_trigger?
      event.start
      result = true
    end
    return result
  end

  #-----------------------------------------------------------------------------
  # * Front Event Starting Determinant
  #-----------------------------------------------------------------------------
  def check_event_trigger_there(triggers)
    result = false
    # If event is running
    return result if $game_system.map_interpreter.running?
    # Calculate front event coordinates
    new_x = @x + (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
    new_y = @y + (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
    return false if !$game_map.valid?(new_x, new_y)
    # All event loops
    for event in $game_map.events.values
      # If event coordinates and triggers are consistent
      next if !event.at_coordinate?(new_x, new_y)
      next if !triggers.include?(event.trigger)
      # If starting determinant is front event (other than jumping)
      next if event.jumping? || event.over_trigger?
      event.start
      result = true
    end
    # If fitting event is not found
    if result == false
      # If front tile is a counter
      if $game_map.counter?(new_x, new_y)
        # Calculate coordinates of 1 tile further away
        new_x += (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
        new_y += (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
        return false if !$game_map.valid?(new_x, new_y)
        # All event loops
        for event in $game_map.events.values
          # If event coordinates and triggers are consistent
          next if !event.at_coordinate?(new_x, new_y)
          next if !triggers.include?(event.trigger)
          # If starting determinant is front event (other than jumping)
          next if event.jumping? || event.over_trigger?
          event.start
          result = true
        end
      end
    end
    return result
  end

  #-----------------------------------------------------------------------------
  # * Touch Event Starting Determinant
  #-----------------------------------------------------------------------------
  def check_event_trigger_touch(dir)
    result = false
    return result if $game_system.map_interpreter.running?
    # All event loops
    x_offset = (dir == 4) ? -1 : (dir == 6) ? 1 : 0
    y_offset = (dir == 8) ? -1 : (dir == 2) ? 1 : 0
    for event in $game_map.events.values
      next if ![1, 2].include?(event.trigger)   # Player touch, event touch
      # If event coordinates and triggers are consistent
      next if !event.at_coordinate?(@x + x_offset, @y + y_offset)
      if event.name[/trainer\((\d+)\)/i]
        distance = $~[1].to_i
        next if !pbEventCanReachPlayer?(event,self,distance)
      elsif event.name[/counter\((\d+)\)/i]
        distance = $~[1].to_i
        next if !pbEventFacesPlayer?(event,self,distance)
      end
      # If starting determinant is front event (other than jumping)
      next if event.jumping? || event.over_trigger?
      event.start
      result = true
    end
    return result
  end

  #-----------------------------------------------------------------------------
  # * Frame Update
  #-----------------------------------------------------------------------------
  def update
    last_real_x = @real_x
    last_real_y = @real_y
    super
    update_screen_position(last_real_x, last_real_y)
    # Update dependent events
    $PokemonTemp.dependentEvents.updateDependentEvents
    # Count down the time between allowed bump sounds
    @bump_se -= 1 if @bump_se && @bump_se>0
    # Finish up dismounting from surfing
    if $PokemonTemp.endSurf && !moving?
      pbCancelVehicles
      $PokemonTemp.surfJump = nil
      $PokemonTemp.endSurf  = false
    end
    update_event_triggering
  end

  def update_command_new
    dir = Input.dir4
    unless pbMapInterpreterRunning? || $game_temp.message_window_showing ||
           $PokemonTemp.miniupdate || $game_temp.in_menu
      # Move player in the direction the directional button is being pressed
      if @moved_last_frame ||
         (dir > 0 && dir == @lastdir && Graphics.frame_count - @lastdirframe > Graphics.frame_rate / 20)
        case dir
        when 2 then move_down
        when 4 then move_left
        when 6 then move_right
        when 8 then move_up
        end
      elsif dir != @lastdir
        case dir
        when 2 then turn_down
        when 4 then turn_left
        when 6 then turn_right
        when 8 then turn_up
        end
      end
    end
    # Record last direction input
    @lastdirframe = Graphics.frame_count if dir != @lastdir
    @lastdir      = dir
  end

  # Center player on-screen
  def update_screen_position(last_real_x, last_real_y)
    return if self.map.scrolling? || !(@moved_last_frame || @moved_this_frame)
    self.map.display_x = @real_x - SCREEN_CENTER_X
    self.map.display_y = @real_y - SCREEN_CENTER_Y
  end

  def update_event_triggering
    return if moving?
    # Try triggering events upon walking into them/in front of them
    if @moved_this_frame
      $PokemonTemp.dependentEvents.pbTurnDependentEvents
      result = pbCheckEventTriggerFromDistance([2])
      # Event determinant is via touch of same position event
      result |= check_event_trigger_here([1,2])
      # No events triggered, try other event triggers upon finishing a step
      pbOnStepTaken(result)
    end
    # Try to manually interact with events
    if Input.trigger?(Input::USE) && !$PokemonTemp.miniupdate
      # Same position and front event determinant
      check_event_trigger_here([0])
      check_event_trigger_there([0,2])
    end
  end
end



def pbGetPlayerCharset(meta,charset,trainer=nil,force=false)
  trainer = $Trainer if !trainer
  outfit = (trainer) ? trainer.outfit : 0
  if $game_player && $game_player.charsetData && !force
    return nil if $game_player.charsetData[0] == $Trainer.character_ID &&
                  $game_player.charsetData[1] == charset &&
                  $game_player.charsetData[2] == outfit
  end
  $game_player.charsetData = [$Trainer.character_ID,charset,outfit] if $game_player
  ret = meta[charset]
  ret = meta[1] if nil_or_empty?(ret)
  if pbResolveBitmap("Graphics/Characters/"+ret+"_"+outfit.to_s)
    ret = ret+"_"+outfit.to_s
  end
  return ret
end

def pbUpdateVehicle
  meta = GameData::Metadata.get_player($Trainer.character_ID)
  if meta
    charset = 1                                 # Regular graphic
    if $PokemonGlobal.diving;     charset = 5   # Diving graphic
    elsif $PokemonGlobal.surfing; charset = 3   # Surfing graphic
    elsif $PokemonGlobal.bicycle; charset = 2   # Bicycle graphic
    end
    newCharName = pbGetPlayerCharset(meta,charset)
    $game_player.character_name = newCharName if newCharName
  end
end

def pbCancelVehicles(destination=nil)
  $PokemonGlobal.surfing = false
  $PokemonGlobal.diving  = false
  $PokemonGlobal.bicycle = false if !destination || !pbCanUseBike?(destination)
  pbUpdateVehicle
end

def pbCanUseBike?(map_id)
  map_metadata = GameData::MapMetadata.try_get(map_id)
  return false if !map_metadata
  return true if map_metadata.always_bicycle
  val = map_metadata.can_bicycle || map_metadata.outdoor_map
  return (val) ? true : false
end

def pbMountBike
  return if $PokemonGlobal.bicycle
  $PokemonGlobal.bicycle = true
  pbUpdateVehicle
  bike_bgm = GameData::Metadata.get.bicycle_BGM
  pbCueBGM(bike_bgm, 0.5) if bike_bgm
  pbPokeRadarCancel
end

def pbDismountBike
  return if !$PokemonGlobal.bicycle
  $PokemonGlobal.bicycle = false
  pbUpdateVehicle
  $game_map.autoplayAsCue
end
