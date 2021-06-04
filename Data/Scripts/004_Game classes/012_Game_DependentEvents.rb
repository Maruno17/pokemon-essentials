class PokemonTemp
  attr_writer :dependentEvents

  def dependentEvents
    @dependentEvents = DependentEvents.new if !@dependentEvents
    return @dependentEvents
  end
end



def pbRemoveDependencies()
  $PokemonTemp.dependentEvents.removeAllEvents()
  pbDeregisterPartner() rescue nil
end

def pbAddDependency(event)
  $PokemonTemp.dependentEvents.addEvent(event)
end

def pbRemoveDependency(event)
  $PokemonTemp.dependentEvents.removeEvent(event)
end

def pbAddDependency2(eventID, eventName, commonEvent)
  $PokemonTemp.dependentEvents.addEvent($game_map.events[eventID],eventName,commonEvent)
end

# Gets the Game_Character object associated with a dependent event.
def pbGetDependency(eventName)
  return $PokemonTemp.dependentEvents.getEventByName(eventName)
end

def pbRemoveDependency2(eventName)
  $PokemonTemp.dependentEvents.removeEventByName(eventName)
end



class PokemonGlobalMetadata
  attr_writer :dependentEvents

  def dependentEvents
    @dependentEvents = [] if !@dependentEvents
    return @dependentEvents
  end
end



def pbTestPass(follower,x,y,_direction=nil)
  return $MapFactory.isPassableStrict?(follower.map.map_id,x,y,follower)
end

# Same map only
def moveThrough(follower,direction)
  oldThrough=follower.through
  follower.through=true
  case direction
  when 2 then follower.move_down
  when 4 then follower.move_left
  when 6 then follower.move_right
  when 8 then follower.move_up
  end
  follower.through=oldThrough
end

# Same map only
def moveFancy(follower,direction)
  deltaX=(direction == 6 ? 1 : (direction == 4 ? -1 : 0))
  deltaY=(direction == 2 ? 1 : (direction == 8 ? -1 : 0))
  newX = follower.x + deltaX
  newY = follower.y + deltaY
  # Move if new position is the player's, or the new position is passable,
  # or the current position is not passable
  if ($game_player.x==newX && $game_player.y==newY) ||
     pbTestPass(follower,newX,newY,0) ||
     !pbTestPass(follower,follower.x,follower.y,0)
    oldThrough=follower.through
    follower.through=true
    case direction
    when 2 then follower.move_down
    when 4 then follower.move_left
    when 6 then follower.move_right
    when 8 then follower.move_up
    end
    follower.through=oldThrough
  end
end

# Same map only
def jumpFancy(follower,direction,leader)
  deltaX=(direction == 6 ? 2 : (direction == 4 ? -2 : 0))
  deltaY=(direction == 2 ? 2 : (direction == 8 ? -2 : 0))
  halfDeltaX=(direction == 6 ? 1 : (direction == 4 ? -1 : 0))
  halfDeltaY=(direction == 2 ? 1 : (direction == 8 ? -1 : 0))
  middle=pbTestPass(follower,follower.x+halfDeltaX,follower.y+halfDeltaY,0)
  ending=pbTestPass(follower,follower.x+deltaX,    follower.y+deltaY,    0)
  if middle
    moveFancy(follower,direction)
    moveFancy(follower,direction)
  elsif ending
    if pbTestPass(follower,follower.x,follower.y,0)
      if leader.jumping?
        follower.jump_speed_real = leader.jump_speed_real * Graphics.frame_rate / 40.0
      else
        follower.jump_speed_real = leader.move_speed_real * Graphics.frame_rate / 20.0
      end
      follower.jump(deltaX,deltaY)
    else
      moveThrough(follower,direction)
      moveThrough(follower,direction)
    end
  end
end

def pbFancyMoveTo(follower,newX,newY,leader)
  if follower.x-newX==-1 && follower.y==newY
    moveFancy(follower,6)
  elsif follower.x-newX==1 && follower.y==newY
    moveFancy(follower,4)
  elsif follower.y-newY==-1 && follower.x==newX
    moveFancy(follower,2)
  elsif follower.y-newY==1 && follower.x==newX
    moveFancy(follower,8)
  elsif follower.x-newX==-2 && follower.y==newY
    jumpFancy(follower,6,leader)
  elsif follower.x-newX==2 && follower.y==newY
    jumpFancy(follower,4,leader)
  elsif follower.y-newY==-2 && follower.x==newX
    jumpFancy(follower,2,leader)
  elsif follower.y-newY==2 && follower.x==newX
    jumpFancy(follower,8,leader)
  elsif follower.x!=newX || follower.y!=newY
    follower.moveto(newX,newY)
  end
end



class DependentEvents
  attr_reader :lastUpdate

  def createEvent(eventData)
    rpgEvent = RPG::Event.new(eventData[3],eventData[4])
    rpgEvent.id = eventData[1]
    if eventData[9]
      # Must setup common event list here and now
      commonEvent = Game_CommonEvent.new(eventData[9])
      rpgEvent.pages[0].list = commonEvent.list
    end
    newEvent = Game_Event.new(eventData[0],rpgEvent,$MapFactory.getMap(eventData[2]))
    newEvent.character_name = eventData[6]
    newEvent.character_hue  = eventData[7]
    case eventData[5]   # direction
    when 2 then newEvent.turn_down
    when 4 then newEvent.turn_left
    when 6 then newEvent.turn_right
    when 8 then newEvent.turn_up
    end
    return newEvent
  end

  def initialize
    # Original map, Event ID, Current map, X, Y, Direction
    events=$PokemonGlobal.dependentEvents
    @realEvents=[]
    @lastUpdate=-1
    for event in events
      @realEvents.push(createEvent(event))
    end
  end

  def pbEnsureEvent(event, newMapID)
    events=$PokemonGlobal.dependentEvents
    for i in 0...events.length
      # Check original map ID and original event ID
      if events[i][0]==event.map_id && events[i][1]==event.id
        # Change current map ID
        events[i][2]=newMapID
        newEvent=createEvent(events[i])
        # Replace event
        @realEvents[i]=newEvent
        @lastUpdate+=1
        return i
      end
    end
    return -1
  end

  def pbFollowEventAcrossMaps(leader,follower,instant=false,leaderIsTrueLeader=true)
    d=leader.direction
    areConnected=$MapFactory.areConnected?(leader.map.map_id,follower.map.map_id)
    # Get the rear facing tile of leader
    facingDirection=10-d
    if !leaderIsTrueLeader && areConnected
      relativePos=$MapFactory.getThisAndOtherEventRelativePos(leader,follower)
      # Assumes leader and follower are both 1x1 tile in size
      if (relativePos[1]==0 && relativePos[0]==2)   # 2 spaces to the right of leader
        facingDirection=6
      elsif (relativePos[1]==0 && relativePos[0]==-2)   # 2 spaces to the left of leader
        facingDirection=4
      elsif relativePos[1]==-2 && relativePos[0]==0   # 2 spaces above leader
        facingDirection=8
      elsif relativePos[1]==2 && relativePos[0]==0   # 2 spaces below leader
        facingDirection=2
      end
    end
    facings=[facingDirection] # Get facing from behind
#    facings.push([0,0,4,0,8,0,2,0,6][d])   # Get right facing
#    facings.push([0,0,6,0,2,0,8,0,4][d])   # Get left facing
    if !leaderIsTrueLeader
      facings.push(d) # Get forward facing
    end
    mapTile=nil
    if areConnected
      bestRelativePos=-1
      oldthrough=follower.through
      follower.through=false
      for i in 0...facings.length
        facing=facings[i]
        tile=$MapFactory.getFacingTile(facing,leader)
        # Assumes leader is 1x1 tile in size
        passable=tile && $MapFactory.isPassableStrict?(tile[0],tile[1],tile[2],follower)
        if i==0 && !passable && tile &&
           $MapFactory.getTerrainTag(tile[0],tile[1],tile[2]).ledge
          # If the tile isn't passable and the tile is a ledge,
          # get tile from further behind
          tile=$MapFactory.getFacingTileFromPos(tile[0],tile[1],tile[2],facing)
          passable=tile && $MapFactory.isPassableStrict?(tile[0],tile[1],tile[2],follower)
        end
        if passable
          relativePos=$MapFactory.getThisAndOtherPosRelativePos(
             follower,tile[0],tile[1],tile[2])
          # Assumes follower is 1x1 tile in size
          distance=Math.sqrt(relativePos[0]*relativePos[0]+relativePos[1]*relativePos[1])
          if bestRelativePos==-1 || bestRelativePos>distance
            bestRelativePos=distance
            mapTile=tile
          end
          if i==0 && distance<=1 # Prefer behind if tile can move up to 1 space
            break
          end
        end
      end
      follower.through=oldthrough
    else
      tile=$MapFactory.getFacingTile(facings[0],leader)
      # Assumes leader is 1x1 tile in size
      passable=tile && $MapFactory.isPassableStrict?(tile[0],tile[1],tile[2],follower)
      mapTile=passable ? mapTile : nil
    end
    if mapTile && follower.map.map_id==mapTile[0]
      # Follower is on same map
      newX=mapTile[1]
      newY=mapTile[2]
      deltaX=(d == 6 ? -1 : d == 4 ? 1 : 0)
      deltaY=(d == 2 ? -1 : d == 8 ? 1 : 0)
      posX = newX + deltaX
      posY = newY + deltaY
      follower.move_speed=leader.move_speed # sync movespeed
      if (follower.x-newX==-1 && follower.y==newY) ||
         (follower.x-newX==1 && follower.y==newY) ||
         (follower.y-newY==-1 && follower.x==newX) ||
         (follower.y-newY==1 && follower.x==newX)
        if instant
          follower.moveto(newX,newY)
        else
          pbFancyMoveTo(follower,newX,newY,leader)
        end
      elsif (follower.x-newX==-2 && follower.y==newY) ||
            (follower.x-newX==2 && follower.y==newY) ||
            (follower.y-newY==-2 && follower.x==newX) ||
            (follower.y-newY==2 && follower.x==newX)
        if instant
          follower.moveto(newX,newY)
        else
          pbFancyMoveTo(follower,newX,newY,leader)
        end
      elsif follower.x!=posX || follower.y!=posY
        if instant
          follower.moveto(newX,newY)
        else
          pbFancyMoveTo(follower,posX,posY,leader)
          pbFancyMoveTo(follower,newX,newY,leader)
        end
      end
    else
      if !mapTile
        # Make current position into leader's position
        mapTile=[leader.map.map_id,leader.x,leader.y]
      end
      if follower.map.map_id==mapTile[0]
        # Follower is on same map as leader
        follower.moveto(leader.x,leader.y)
      else
        # Follower will move to different map
        events=$PokemonGlobal.dependentEvents
        eventIndex=pbEnsureEvent(follower,mapTile[0])
        if eventIndex>=0
          newFollower=@realEvents[eventIndex]
          newEventData=events[eventIndex]
          newFollower.moveto(mapTile[1],mapTile[2])
          newEventData[3]=mapTile[1]
          newEventData[4]=mapTile[2]
        end
      end
    end
  end

  def debugEcho
    self.eachEvent { |e,d|
      echoln d
      echoln [e.map_id,e.map.map_id,e.id]
    }
  end

  def pbMapChangeMoveDependentEvents
    events=$PokemonGlobal.dependentEvents
    updateDependentEvents
    leader=$game_player
    for i in 0...events.length
      event=@realEvents[i]
      pbFollowEventAcrossMaps(leader,event,true,i==0)
      # Update X and Y for this event
      events[i][3]=event.x
      events[i][4]=event.y
      events[i][5]=event.direction
      # Set leader to this event
      leader=event
    end
  end

  def pbMoveDependentEvents
    events=$PokemonGlobal.dependentEvents
    updateDependentEvents
    leader=$game_player
    for i in 0...events.length
      event=@realEvents[i]
      pbFollowEventAcrossMaps(leader,event,false,i==0)
      # Update X and Y for this event
      events[i][3]=event.x
      events[i][4]=event.y
      events[i][5]=event.direction
      # Set leader to this event
      leader=event
    end
  end

  def pbTurnDependentEvents
    events=$PokemonGlobal.dependentEvents
    updateDependentEvents
    leader=$game_player
    for i in 0...events.length
      event=@realEvents[i]
      pbTurnTowardEvent(event,leader)
      # Update direction for this event
      events[i][5]=event.direction
      # Set leader to this event
      leader=event
    end
  end

  def eachEvent
    events=$PokemonGlobal.dependentEvents
    for i in 0...events.length
      yield @realEvents[i],events[i]
    end
  end

  def updateDependentEvents
    events=$PokemonGlobal.dependentEvents
    return if events.length==0
    for i in 0...events.length
      event=@realEvents[i]
      next if !@realEvents[i]
      event.transparent=$game_player.transparent
      if event.jumping? || event.moving? ||
         !($game_player.jumping? || $game_player.moving?)
        event.update
      elsif !event.starting
        event.set_starting
        event.update
        event.clear_starting
      end
      events[i][3]=event.x
      events[i][4]=event.y
      events[i][5]=event.direction
    end
    # Check event triggers
    if Input.trigger?(Input::USE) && !$game_temp.in_menu && !$game_temp.in_battle &&
       !$game_player.move_route_forcing && !$game_temp.message_window_showing &&
       !pbMapInterpreterRunning?
      # Get position of tile facing the player
      facingTile=$MapFactory.getFacingTile()
      # Assumes player is 1x1 tile in size
      self.eachEvent { |e,d|
        next if !d[9]
        if e.at_coordinate?($game_player.x, $game_player.y)
          # On same position
          if !e.jumping? && (!e.respond_to?("over_trigger") || e.over_trigger?)
            if e.list.size>1
              # Start event
              $game_map.refresh if $game_map.need_refresh
              e.lock
              pbMapInterpreter.setup(e.list,e.id,e.map.map_id)
            end
          end
        elsif facingTile && e.map.map_id==facingTile[0] &&
              e.at_coordinate?(facingTile[1], facingTile[2])
          # On facing tile
          if !e.jumping? && (!e.respond_to?("over_trigger") || !e.over_trigger?)
            if e.list.size>1
              # Start event
              $game_map.refresh if $game_map.need_refresh
              e.lock
              pbMapInterpreter.setup(e.list,e.id,e.map.map_id)
            end
          end
        end
      }
    end
  end

  def removeEvent(event)
    events=$PokemonGlobal.dependentEvents
    mapid=$game_map.map_id
    for i in 0...events.length
      if events[i][2]==mapid && # Refer to current map
         events[i][0]==event.map_id && # Event's map ID is original ID
         events[i][1]==event.id
        events[i]=nil
        @realEvents[i]=nil
        @lastUpdate+=1
      end
      events.compact!
      @realEvents.compact!
    end
  end

  def getEventByName(name)
    events=$PokemonGlobal.dependentEvents
    for i in 0...events.length
      if events[i] && events[i][8]==name # Arbitrary name given to dependent event
        return @realEvents[i]
      end
    end
    return nil
  end

  def removeAllEvents
    events=$PokemonGlobal.dependentEvents
    events.clear
    @realEvents.clear
    @lastUpdate+=1
  end

  def removeEventByName(name)
    events=$PokemonGlobal.dependentEvents
    for i in 0...events.length
      if events[i] && events[i][8]==name # Arbitrary name given to dependent event
        events[i]=nil
        @realEvents[i]=nil
        @lastUpdate+=1
      end
      events.compact!
      @realEvents.compact!
    end
  end

  def addEvent(event,eventName=nil,commonEvent=nil)
    return if !event
    events=$PokemonGlobal.dependentEvents
    for i in 0...events.length
      if events[i] && events[i][0]==$game_map.map_id && events[i][1]==event.id
        # Already exists
        return
      end
    end
    # Original map ID, original event ID, current map ID,
    # event X, event Y, event direction,
    # event's filename,
    # event's hue, event's name, common event ID
    eventData=[
       $game_map.map_id,event.id,$game_map.map_id,
       event.x,event.y,event.direction,
       event.character_name.clone,
       event.character_hue,eventName,commonEvent
    ]
    newEvent=createEvent(eventData)
    events.push(eventData)
    @realEvents.push(newEvent)
    @lastUpdate+=1
    event.erase
  end
end



class DependentEventSprites
  def initialize(viewport,map)
    @disposed=false
    @sprites=[]
    @map=map
    @viewport=viewport
    refresh
    @lastUpdate=nil
  end

  def refresh
    for sprite in @sprites
      sprite.dispose
    end
    @sprites.clear
    $PokemonTemp.dependentEvents.eachEvent { |event,data|
      if data[0]==@map.map_id # Check original map
        @map.events[data[1]].erase
      end
      if data[2]==@map.map_id # Check current map
        @sprites.push(Sprite_Character.new(@viewport,event))
      end
    }
  end

  def update
    if $PokemonTemp.dependentEvents.lastUpdate!=@lastUpdate
      refresh
      @lastUpdate=$PokemonTemp.dependentEvents.lastUpdate
    end
    for sprite in @sprites
      sprite.update
    end
  end

  def dispose
    return if @disposed
    for sprite in @sprites
      sprite.dispose
    end
    @sprites.clear
    @disposed=true
  end

  def disposed?
    @disposed
  end
end



Events.onSpritesetCreate += proc { |_sender,e|
  spriteset = e[0]   # Spriteset being created
  viewport  = e[1]   # Viewport used for tilemap and characters
  map = spriteset.map   # Map associated with the spriteset (not necessarily the current map)
  spriteset.addUserSprite(DependentEventSprites.new(viewport,map))
}

Events.onMapSceneChange += proc { |_sender,e|
  mapChanged = e[1]
  if mapChanged
    $PokemonTemp.dependentEvents.pbMapChangeMoveDependentEvents
  end
}
