#===============================================================================
# Map Factory (allows multiple maps to be loaded at once and connected)
#===============================================================================
class PokemonMapFactory
  attr_reader :maps

  def initialize(id)
    @maps       = []
    @fixup      = false
    @mapChanged = false   # transient instance variable
    setup(id)
  end

  # Clears all maps and sets up the current map with id. This function also sets
  # the positions of neighboring maps and notifies the game system of a map
  # change.
  def setup(id)
    @maps.clear
    @maps[0] = Game_Map.new
    @mapIndex = 0
    oldID = ($game_map) ? $game_map.map_id : 0
    setMapChanging(id,@maps[0]) if oldID!=0 && oldID!=@maps[0].map_id
    $game_map = @maps[0]
    @maps[0].setup(id)
    setMapsInRange
    setMapChanged(oldID)
  end

  def map
    @mapIndex = 0 if !@mapIndex || @mapIndex<0
    return @maps[@mapIndex] if @maps[@mapIndex]
    raise "No maps in save file... (mapIndex=#{@mapIndex})" if @maps.length==0
    for i in 0...@maps.length
      if @maps[i]
        echo("Using next map, may be incorrect (mapIndex=#{@mapIndex}, length=#{@maps.length})")
        return @maps[i]
      end
      raise "No maps in save file... (all maps empty; mapIndex=#{@mapIndex})"
    end
  end

  def hasMap?(id)
    for map in @maps
      return true if map.map_id==id
    end
    return false
  end

  def getMapIndex(id)
    for i in 0...@maps.length
      return i if @maps[i].map_id==id
    end
    return -1
  end

  def getMap(id,add=true)
    for map in @maps
      return map if map.map_id==id
    end
    map = Game_Map.new
    map.setup(id)
    @maps.push(map) if add
    return map
  end

  def getMapNoAdd(id)
    return getMap(id,false)
  end

  def getNewMap(playerX,playerY)
    id = $game_map.map_id
    conns = MapFactoryHelper.getMapConnections
    for conn in conns
      next if conn[0]!=id && conn[3]!=id
      mapidB = nil
      newx = 0
      newy = 0
      if conn[0]==id
        mapidB = conn[3]
        mapB = MapFactoryHelper.getMapDims(conn[3])
        newx = conn[4] - conn[1] + playerX
        newy = conn[5] - conn[2] + playerY
      else
        mapidB = conn[0]
        mapB = MapFactoryHelper.getMapDims(conn[0])
        newx = conn[1] - conn[4] + playerX
        newy = conn[2] - conn[5] + playerY
      end
      if newx>=0 && newx<mapB[0] && newy>=0 && newy<mapB[1]
        return [getMap(mapidB),newx,newy]
      end
    end
    return nil
  end

  def setCurrentMap
    return if $game_player.moving?
    return if $game_map.valid?($game_player.x,$game_player.y)
    newmap = getNewMap($game_player.x,$game_player.y)
    return if !newmap
    oldmap=$game_map.map_id
    if oldmap!=0 && oldmap!=newmap[0].map_id
      setMapChanging(newmap[0].map_id,newmap[0])
    end
    $game_map = newmap[0]
    @mapIndex = getMapIndex($game_map.map_id)
    $game_player.moveto(newmap[1],newmap[2])
    $game_map.update
    pbAutoplayOnTransition
    $game_map.refresh
    setMapChanged(oldmap)
  end

  def setMapsInRange
    return if @fixup
    @fixup = true
    id = $game_map.map_id
    conns = MapFactoryHelper.getMapConnections
    for conn in conns
      if conn[0]==id
        mapA = getMap(conn[0])
        newdispx = (conn[4] - conn[1]) * Game_Map::REAL_RES_X + mapA.display_x
        newdispy = (conn[5] - conn[2]) * Game_Map::REAL_RES_Y + mapA.display_y
        if hasMap?(conn[3]) || MapFactoryHelper.mapInRangeById?(conn[3],newdispx,newdispy)
          mapB = getMap(conn[3])
          mapB.display_x = newdispx if mapB.display_x!=newdispx
          mapB.display_y = newdispy if mapB.display_y!=newdispy
        end
      elsif conn[3]==id
        mapA = getMap(conn[3])
        newdispx = (conn[1] - conn[4]) * Game_Map::REAL_RES_X + mapA.display_x
        newdispy = (conn[2] - conn[5]) * Game_Map::REAL_RES_Y + mapA.display_y
        if hasMap?(conn[0]) || MapFactoryHelper.mapInRangeById?(conn[0],newdispx,newdispy)
          mapB = getMap(conn[0])
          mapB.display_x = newdispx if mapB.display_x!=newdispx
          mapB.display_y = newdispy if mapB.display_y!=newdispy
        end
      end
    end
    @fixup = false
  end

  def setMapChanging(newID,newMap)
    Events.onMapChanging.trigger(self,newID,newMap)
  end

  def setMapChanged(prevMap)
    Events.onMapChange.trigger(self,prevMap)
    @mapChanged = true
  end

  def setSceneStarted(scene)
    Events.onMapSceneChange.trigger(self,scene,@mapChanged)
    @mapChanged = false
  end

  # Similar to Game_Player#passable?, but supports map connections
  def isPassableFromEdge?(x, y)
    return true if $game_map.valid?(x, y)
    newmap = getNewMap(x, y)
    return false if !newmap
    return isPassable?(newmap[0].map_id, newmap[1], newmap[2])
  end

  def isPassable?(mapID, x, y, thisEvent = nil)
    thisEvent = $game_player if !thisEvent
    map = getMapNoAdd(mapID)
    return false if !map
    return false if !map.valid?(x, y)
    return true if thisEvent.through
    # Check passability of tile
    if thisEvent.is_a?(Game_Player)
      return false unless ($DEBUG && Input.press?(Input::CTRL)) ||
         map.passable?(x, y, 0, thisEvent)
    else
      return false unless map.passable?(x, y, 0, thisEvent)
    end
    # Check passability of event(s) in that spot
    for event in map.events.values
      next if event.x != x || event.y != y || event == thisEvent
      return false if !event.through && event.character_name != ""
    end
    # Check passability of player
    if !thisEvent.is_a?(Game_Player)
      if $game_map.map_id == mapID && $game_player.x == x && $game_player.y == y
        return false if !$game_player.through && $game_player.character_name != ""
      end
    end
    return true
  end

  # Only used by dependent events
  def isPassableStrict?(mapID,x,y,thisEvent=nil)
    thisEvent = $game_player if !thisEvent
    map = getMapNoAdd(mapID)
    return false if !map
    return false if !map.valid?(x,y)
    return true if thisEvent.through
    if thisEvent==$game_player
      if !($DEBUG && Input.press?(Input::CTRL))
        return false if !map.passableStrict?(x,y,0,thisEvent)
      end
    else
      return false if !map.passableStrict?(x,y,0,thisEvent)
    end
    for event in map.events.values
      next if event == thisEvent || event.x != x || event.y != y
      return false if !event.through && event.character_name!=""
    end
    return true
  end

  def getTerrainTag(mapid,x,y,countBridge=false)
    map = getMapNoAdd(mapid)
    return map.terrain_tag(x,y,countBridge)
  end

  def getFacingTerrainTag(dir=nil,event=nil)
    tile = getFacingTile(dir,event)
    return 0 if !tile
    return getTerrainTag(tile[0],tile[1],tile[2])
  end

  def getTerrainTagFromCoords(mapid,x,y,countBridge=false)
    tile = getRealTilePos(mapid,x,y)
    return 0 if !tile
    return getTerrainTag(tile[0],tile[1],tile[2])
  end

  def areConnected?(mapID1,mapID2)
    return true if mapID1==mapID2
    conns = MapFactoryHelper.getMapConnections
    for conn in conns
      if (conn[0]==mapID1 && conn[3]==mapID2) ||
         (conn[0]==mapID2 && conn[3]==mapID1)
        return true
      end
    end
    return false
  end

  def getRelativePos(thisMapID,thisX,thisY,otherMapID,otherX,otherY)
    if thisMapID==otherMapID
      # Both events share the same map
      return [otherX-thisX,otherY-thisY]
    end
    conns = MapFactoryHelper.getMapConnections
    for conn in conns
      if conn[0]==thisMapID && conn[1]==otherMapID
        posX = thisX + conn[4] - conn[1] + otherX
        posY = thisY + conn[5] - conn[2] + otherY
        return [posX,posY]
      elsif conn[1]==thisMapID && conn[0]==otherMapID
        posX = thisX + conn[1] - conn[4] + otherX
        posY = thisY + conn[2] - conn[5] + otherY
        return [posX,posY]
      end
    end
    return [0,0]
  end

  # Gets the distance from this event to another event.  Example: If this event's
  # coordinates are (2,5) and the other event's coordinates are (5,1), returns
  # the array (3,-4), because (5-2=3) and (1-5=-4).
  def getThisAndOtherEventRelativePos(thisEvent,otherEvent)
    return [0,0] if !thisEvent || !otherEvent
    return getRelativePos(
       thisEvent.map.map_id,thisEvent.x,thisEvent.y,
       otherEvent.map.map_id,otherEvent.x,otherEvent.y)
  end

  def getThisAndOtherPosRelativePos(thisEvent,otherMapID,otherX,otherY)
    return [0,0] if !thisEvent
    return getRelativePos(
       thisEvent.map.map_id,thisEvent.x,thisEvent.y,otherMapID,otherX,otherY)
  end

  def getOffsetEventPos(event,xOffset,yOffset)
    event = $game_player if !event
    return nil if !event
    return getRealTilePos(event.map.map_id,event.x+xOffset,event.y+yOffset)
  end

  def getFacingTile(direction=nil,event=nil,steps=1)
    event = $game_player if event==nil
    return [0,0,0] if !event
    x = event.x
    y = event.y
    id = event.map.map_id
    direction = event.direction if direction==nil
    return getFacingTileFromPos(id,x,y,direction,steps)
  end

  def getFacingTileFromPos(mapID,x,y,direction=0,steps=1)
    id = mapID
    case direction
    when 1; x -= steps; y += steps
    when 2;             y += steps
    when 3; x += steps; y += steps
    when 4; x -= steps
    when 6; x += steps
    when 7; x -= steps; y -= steps
    when 8;             y -= steps
    when 9; x += steps; y -= steps
    else;   return [id,x,y]
    end
    return getRealTilePos(mapID,x,y)
  end

  def getRealTilePos(mapID,x,y)
    id = mapID
    return [id,x,y] if getMapNoAdd(id).valid?(x,y)
    conns = MapFactoryHelper.getMapConnections
    for conn in conns
      if conn[0]==id
        newX = x + conn[4] - conn[1]
        newY = y + conn[5] - conn[2]
        next if newX<0 || newY<0
        dims = MapFactoryHelper.getMapDims(conn[3])
        next if newX>=dims[0] || newY>=dims[1]
        return [conn[3],newX,newY]
      elsif conn[3]==id
        newX = x + conn[1] - conn[4]
        newY = y + conn[2] - conn[5]
        next if newX<0 || newY<0
        dims = MapFactoryHelper.getMapDims(conn[0])
        next if newX>=dims[0] || newY>=dims[1]
        return [conn[0],newX,newY]
      end
    end
    return nil
  end

  def getFacingCoords(x,y,direction=0,steps=1)
    case direction
    when 1; x -= steps; y += steps
    when 2;             y += steps
    when 3; x += steps; y += steps
    when 4; x -= steps
    when 6; x += steps
    when 7; x -= steps; y -= steps
    when 8;             y -= steps
    when 9; x += steps; y -= steps
    end
    return [x,y]
  end

  def updateMaps(scene)
    updateMapsInternal
    $MapFactory.setSceneStarted(scene) if @mapChanged
  end

  def updateMapsInternal
    return if $game_player.moving?
    if !MapFactoryHelper.hasConnections?($game_map.map_id)
      return if @maps.length==1
      for i in 0...@maps.length
        @maps[i] = nil if $game_map.map_id!=@maps[i].map_id
      end
      @maps.compact!
      @mapIndex = getMapIndex($game_map.map_id)
      return
    end
    setMapsInRange
    deleted = false
    for i in 0...@maps.length
      next if MapFactoryHelper.mapInRange?(@maps[i])
      @maps[i] = nil
      deleted = true
    end
    if deleted
      @maps.compact!
      @mapIndex = getMapIndex($game_map.map_id)
    end
  end
end



#===============================================================================
# Map Factory Helper (stores map connection and size data and calculations
# involving them)
#===============================================================================
module MapFactoryHelper
  @@MapConnections = nil
  @@MapDims        = nil

  def self.clear
    @@MapConnections = nil
    @@MapDims        = nil
  end

  def self.getMapConnections
    if !@@MapConnections
      @@MapConnections = []
      begin
        conns = load_data("Data/map_connections.dat")
      rescue
        conns = []
      end
      for i in 0...conns.length
        conn = conns[i]
        v = getMapEdge(conn[0],conn[1])
        dims = getMapDims(conn[0])
        next if dims[0]==0 || dims[1]==0
        if conn[1]=="N" || conn[1]=="S"
          conn[1] = conn[2]
          conn[2] = v
        elsif conn[1]=="E" || conn[1]=="W"
          conn[1] = v
        end
        v = getMapEdge(conn[3],conn[4])
        dims = getMapDims(conn[3])
        next if dims[0]==0 || dims[1]==0
        if conn[4]=="N" || conn[4]=="S"
          conn[4] = conn[5]
          conn[5] = v
        elsif conn[4]=="E" || conn[4]=="W"
          conn[4] = v
        end
        @@MapConnections.push(conn)
      end
    end
    return @@MapConnections
  end

  def self.hasConnections?(id)
    conns = MapFactoryHelper.getMapConnections
    for conn in conns
      return true if conn[0]==id || conn[3]==id
    end
    return false
  end

  # Gets the height and width of the map with id
  def self.getMapDims(id)
    # Create cache if doesn't exist
    @@MapDims = [] if !@@MapDims
    # Add map to cache if can't be found
    if !@@MapDims[id]
      begin
        map = pbLoadRxData(sprintf("Data/Map%03d", id))
        @@MapDims[id] = [map.width,map.height]
      rescue
        @@MapDims[id] = [0,0]
      end
    end
    # Return map in cache
    return @@MapDims[id]
  end

  # Returns the X or Y coordinate of an edge on the map with id.
  # Considers the special strings "N","W","E","S"
  def self.getMapEdge(id,edge)
    return 0 if edge=="N" || edge=="W"
    dims = getMapDims(id)   # Get dimensions
    return dims[0] if edge=="E"
    return dims[1] if edge=="S"
    return dims[0]   # real dimension (use width)
  end

  def self.mapInRange?(map)
    range = 6   # Number of tiles
    dispx = map.display_x
    dispy = map.display_y
    return false if dispx >= (map.width + range) * Game_Map::REAL_RES_X
    return false if dispy >= (map.height + range) * Game_Map::REAL_RES_Y
    return false if dispx <= -(Graphics.width + range * Game_Map::TILE_WIDTH) * Game_Map::X_SUBPIXELS
    return false if dispy <= -(Graphics.height + range * Game_Map::TILE_HEIGHT) * Game_Map::Y_SUBPIXELS
    return true
  end

  def self.mapInRangeById?(id,dispx,dispy)
    range = 6   # Number of tiles
    dims = MapFactoryHelper.getMapDims(id)
    return false if dispx >= (dims[0] + range) * Game_Map::REAL_RES_X
    return false if dispy >= (dims[1] + range) * Game_Map::REAL_RES_Y
    return false if dispx <= -(Graphics.width + range * Game_Map::TILE_WIDTH) * Game_Map::X_SUBPIXELS
    return false if dispy <= -(Graphics.height + range * Game_Map::TILE_HEIGHT) * Game_Map::Y_SUBPIXELS
    return true
  end
end



def updateTilesets
  maps = $MapFactory.maps
  for map in maps
    map.updateTileset if map
  end
end
