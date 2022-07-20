#===============================================================================
# Miniature game map drawing
#===============================================================================
class MapSprite
  def initialize(map, viewport = nil)
    @sprite = Sprite.new(viewport)
    @sprite.bitmap = createMinimap(map)
    @sprite.x = (Graphics.width / 2) - (@sprite.bitmap.width / 2)
    @sprite.y = (Graphics.height / 2) - (@sprite.bitmap.height / 2)
  end

  def dispose
    @sprite.bitmap.dispose
    @sprite.dispose
  end

  def z=(value)
    @sprite.z = value
  end

  def getXY
    return nil if !Input.trigger?(Input::MOUSELEFT)
    mouse = Mouse.getMousePos(true)
    return nil if !mouse
    if mouse[0] < @sprite.x || mouse[0] >= @sprite.x + @sprite.bitmap.width
      return nil
    end
    if mouse[1] < @sprite.y || mouse[1] >= @sprite.y + @sprite.bitmap.height
      return nil
    end
    x = mouse[0] - @sprite.x
    y = mouse[1] - @sprite.y
    return [x / 4, y / 4]
  end
end

#===============================================================================
#
#===============================================================================
class SelectionSprite < Sprite
  def initialize(viewport = nil)
    @sprite = Sprite.new(viewport)
    @sprite.bitmap = nil
    @sprite.z = 2
    @othersprite = nil
  end

  def disposed?
    return @sprite.disposed?
  end

  def dispose
    @sprite.bitmap&.dispose
    @othersprite = nil
    @sprite.dispose
  end

  def othersprite=(value)
    @othersprite = value
    if @othersprite && !@othersprite.disposed? &&
       @othersprite.bitmap && !@othersprite.bitmap.disposed?
      @sprite.bitmap = pbDoEnsureBitmap(
        @sprite.bitmap, @othersprite.bitmap.width, @othersprite.bitmap.height
      )
      red = Color.new(255, 0, 0)
      @sprite.bitmap.clear
      @sprite.bitmap.fill_rect(0, 0, @othersprite.bitmap.width, 2, red)
      @sprite.bitmap.fill_rect(0, @othersprite.bitmap.height - 2,
                               @othersprite.bitmap.width, 2, red)
      @sprite.bitmap.fill_rect(0, 0, 2, @othersprite.bitmap.height, red)
      @sprite.bitmap.fill_rect(@othersprite.bitmap.width - 2, 0, 2,
                               @othersprite.bitmap.height, red)
    end
  end

  def update
    if @othersprite && !@othersprite.disposed?
      @sprite.visible = @othersprite.visible
      @sprite.x = @othersprite.x
      @sprite.y = @othersprite.y
    else
      @sprite.visible = false
    end
  end
end

#===============================================================================
#
#===============================================================================
class RegionMapSprite
  def initialize(map, viewport = nil)
    @sprite = Sprite.new(viewport)
    @sprite.bitmap = createRegionMap(map)
    @sprite.x = (Graphics.width / 2) - (@sprite.bitmap.width / 2)
    @sprite.y = (Graphics.height / 2) - (@sprite.bitmap.height / 2)
  end

  def dispose
    @sprite.bitmap.dispose
    @sprite.dispose
  end

  def z=(value)
    @sprite.z = value
  end

  def createRegionMap(map)
    @mapdata = pbLoadTownMapData
    @map = @mapdata[map]
    bitmap = AnimatedBitmap.new("Graphics/Pictures/#{@map[1]}").deanimate
    retbitmap = BitmapWrapper.new(bitmap.width / 2, bitmap.height / 2)
    retbitmap.stretch_blt(
      Rect.new(0, 0, bitmap.width / 2, bitmap.height / 2),
      bitmap,
      Rect.new(0, 0, bitmap.width, bitmap.height)
    )
    bitmap.dispose
    return retbitmap
  end

  def getXY
    return nil if !Input.trigger?(Input::MOUSELEFT)
    mouse = Mouse.getMousePos(true)
    return nil if !mouse
    if mouse[0] < @sprite.x || mouse[0] >= @sprite.x + @sprite.bitmap.width
      return nil
    end
    if mouse[1] < @sprite.y || mouse[1] >= @sprite.y + @sprite.bitmap.height
      return nil
    end
    x = mouse[0] - @sprite.x
    y = mouse[1] - @sprite.y
    return [x / 8, y / 8]
  end
end

#===============================================================================
# Visual Editor (map connections)
#===============================================================================
class MapScreenScene
  def getMapSprite(id)
    if !@mapsprites[id]
      @mapsprites[id] = Sprite.new(@viewport)
      @mapsprites[id].z = 0
      @mapsprites[id].bitmap = nil
    end
    if !@mapsprites[id].bitmap || @mapsprites[id].bitmap.disposed?
      @mapsprites[id].bitmap = createMinimap(id)
    end
    return @mapsprites[id]
  end

  def close
    pbDisposeSpriteHash(@sprites)
    pbDisposeSpriteHash(@mapsprites)
    @viewport.dispose
  end

  def setMapSpritePos(id, x, y)
    sprite = getMapSprite(id)
    sprite.x = x
    sprite.y = y
    sprite.visible = true
  end

  def putNeighbors(id, sprites)
    conns = @mapconns
    mapsprite = getMapSprite(id)
    dispx = mapsprite.x
    dispy = mapsprite.y
    conns.each do |conn|
      if conn[0] == id
        b = sprites.any? { |i| i == conn[3] }
        if !b
          x = ((conn[1] - conn[4]) * 4) + dispx
          y = ((conn[2] - conn[5]) * 4) + dispy
          setMapSpritePos(conn[3], x, y)
          sprites.push(conn[3])
          putNeighbors(conn[3], sprites)
        end
      elsif conn[3] == id
        b = sprites.any? { |i| i == conn[0] }
        if !b
          x = ((conn[4] - conn[1]) * 4) + dispx
          y = ((conn[5] - conn[2]) * 4) + dispy
          setMapSpritePos(conn[0], x, y)
          sprites.push(conn[3])
          putNeighbors(conn[0], sprites)
        end
      end
    end
  end

  def hasConnections?(conns, id)
    conns.each do |conn|
      return true if conn[0] == id || conn[3] == id
    end
    return false
  end

  def connectionsSymmetric?(conn1, conn2)
    if conn1[0] == conn2[0]
      # Equality
      return false if conn1[1] != conn2[1]
      return false if conn1[2] != conn2[2]
      return false if conn1[3] != conn2[3]
      return false if conn1[4] != conn2[4]
      return false if conn1[5] != conn2[5]
      return true
    elsif conn1[0] == conn2[3]
      # Symmetry
      return false if conn1[1] != -conn2[1]
      return false if conn1[2] != -conn2[2]
      return false if conn1[3] != conn2[0]
      return false if conn1[4] != -conn2[4]
      return false if conn1[5] != -conn2[5]
      return true
    end
    return false
  end

  def removeOldConnections(ret, mapid)
    ret.delete_if { |conn| conn[0] == mapid || conn[3] == mapid }
  end

  # Returns the maps within _keys_ that are directly connected to this map, _map_.
  def getDirectConnections(keys, map)
    thissprite = getMapSprite(map)
    thisdims = MapFactoryHelper.getMapDims(map)
    ret = []
    keys.each do |i|
      next if i == map
      othersprite = getMapSprite(i)
      otherdims = MapFactoryHelper.getMapDims(i)
      x1 = (thissprite.x - othersprite.x) / 4
      y1 = (thissprite.y - othersprite.y) / 4
      if x1 == otherdims[0] || x1 == -thisdims[0] ||
         y1 == otherdims[1] || y1 == -thisdims[1]
        ret.push(i)
      end
    end
    # If no direct connections, add an indirect connection
    if ret.length == 0
      key = (map == keys[0]) ? keys[1] : keys[0]
      ret.push(key)
    end
    return ret
  end

  def generateConnectionData
    ret = []
    # Create a clone of current map connection
    @mapconns.each do |conn|
      ret.push(conn.clone)
    end
    keys = @mapsprites.keys
    return ret if keys.length < 2
    # Remove all connections containing any sprites on the canvas from the array
    keys.each do |i|
      removeOldConnections(ret, i)
    end
    # Rebuild connections
    keys.each do |i|
      refs = getDirectConnections(keys, i)
      refs.each do |refmap|
        othersprite = getMapSprite(i)
        refsprite = getMapSprite(refmap)
        c1 = (refsprite.x - othersprite.x) / 4
        c2 = (refsprite.y - othersprite.y) / 4
        conn = [refmap, 0, 0, i, c1, c2]
        j = 0
        while j < ret.length && !connectionsSymmetric?(ret[j], conn)
          j += 1
        end
        if j == ret.length
          ret.push(conn)
        end
      end
    end
    return ret
  end

  def serializeConnectionData
    conndata = generateConnectionData
    save_data(conndata, "Data/map_connections.dat")
    Compiler.write_connections
    @mapconns = conndata
  end

  def putSprite(id)
    addSprite(id)
    putNeighbors(id, [])
  end

  def addSprite(id)
    mapsprite = getMapSprite(id)
    x = (Graphics.width - mapsprite.bitmap.width) / 2
    y = (Graphics.height - mapsprite.bitmap.height) / 2
    mapsprite.x = x.to_i & ~3
    mapsprite.y = y.to_i & ~3
  end

  def saveMapSpritePos
    @mapspritepos.clear
    @mapsprites.each_key do |i|
      s = @mapsprites[i]
      @mapspritepos[i] = [s.x, s.y] if s && !s.disposed?
    end
  end

  def mapScreen
    @sprites = {}
    @mapsprites = {}
    @mapspritepos = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @lasthitmap = -1
    @lastclick = -1
    @oldmousex = nil
    @oldmousey = nil
    @dragging = false
    @dragmapid = -1
    @dragOffsetX = 0
    @dragOffsetY = 0
    @selmapid = -1
    @sprites["background"] = ColoredPlane.new(Color.new(160, 208, 240), @viewport)
    @sprites["selsprite"] = SelectionSprite.new(@viewport)
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("D: Help"), 0, Graphics.height - 64, Graphics.width, 64, @viewport
    )
    @sprites["title"].z = 2
    @mapinfos = pbLoadMapInfos
    conns = MapFactoryHelper.getMapConnections
    @mapconns = []
    conns.each do |map_conns|
      next if !map_conns
      map_conns.each do |c|
        @mapconns.push(c.clone) if @mapconns.none? { |x| x[0] == c[0] && x[3] == c[3] }
      end
    end
    if $game_map
      @currentmap = $game_map.map_id
    else
      @currentmap = ($data_system) ? $data_system.edit_map_id : 1
    end
    putSprite(@currentmap)
  end

  def setTopSprite(id)
    @mapsprites.each_key do |i|
      @mapsprites[i].z = (i == id) ? 1 : 0
    end
  end

  def helpWindow
    helptext = _INTL("A: Add map to canvas\r\n")
    helptext += _INTL("DEL: Delete map from canvas\r\n")
    helptext += _INTL("S: Go to another map\r\n")
    helptext += _INTL("Click to select a map\r\n")
    helptext += _INTL("Double-click: Edit map's metadata\r\n")
    helptext += _INTL("Drag map to move it\r\n")
    helptext += _INTL("Arrow keys/drag canvas: Move around canvas")
    title = Window_UnformattedTextPokemon.newWithSize(
      helptext, 0, 0, Graphics.width * 8 / 10, Graphics.height, @viewport
    )
    title.z = 2
    loop do
      Graphics.update
      Input.update
      break if Input.trigger?(Input::BACK) || Input.trigger?(Input::USE)
    end
    Input.update
    title.dispose
  end

  def getMapRect(mapid)
    sprite = getMapSprite(mapid)
    return nil if !sprite
    return [sprite.x, sprite.y,
            sprite.x + sprite.bitmap.width, sprite.y + sprite.bitmap.height]
  end

  def onDoubleClick(map_id)
    pbEditMapMetadata(map_id) if map_id > 0
  end

  def onClick(mapid, x, y)
    if @lastclick > 0 && Graphics.frame_count - @lastclick < Graphics.frame_rate * 0.5
      onDoubleClick(mapid)
      @lastclick = -1
    else
      @lastclick = Graphics.frame_count
      if mapid >= 0
        @dragging = true
        @dragmapid = mapid
        sprite = getMapSprite(mapid)
        @sprites["selsprite"].othersprite = sprite
        @selmapid = mapid
        @dragOffsetX = sprite.x - x
        @dragOffsetY = sprite.y - y
        setTopSprite(mapid)
      else
        @sprites["selsprite"].othersprite = nil
        @dragging = true
        @dragmapid = mapid
        @selmapid = -1
        @dragOffsetX = x
        @dragOffsetY = y
        saveMapSpritePos
      end
    end
  end

  def onRightClick(mapid, x, y)
#   echoln "rightclick (#{mapid})"
  end

  def onMouseUp(mapid)
#   echoln "mouseup (#{mapid})"
    @dragging = false if @dragging
  end

  def onRightMouseUp(mapid)
#   echoln "rightmouseup (#{mapid})"
  end

  def onMouseOver(mapid, x, y)
#   echoln "mouseover (#{mapid},#{x},#{y})"
  end

  def onMouseMove(mapid, x, y)
#   echoln "mousemove (#{mapid},#{x},#{y})"
    if @dragging
      if @dragmapid >= 0
        sprite = getMapSprite(@dragmapid)
        x = x + @dragOffsetX
        y = y + @dragOffsetY
        sprite.x = x & ~3
        sprite.y = y & ~3
        @sprites["title"].text = _ISPRINTF("D: Help [{1:03d}: {2:s}]", mapid, @mapinfos[@dragmapid].name)
      else
        xpos = x - @dragOffsetX
        ypos = y - @dragOffsetY
        @mapspritepos.each_key do |i|
          sprite = getMapSprite(i)
          sprite.x = (@mapspritepos[i][0] + xpos) & ~3
          sprite.y = (@mapspritepos[i][1] + ypos) & ~3
        end
        @sprites["title"].text = _INTL("D: Help")
      end
    elsif mapid >= 0
      @sprites["title"].text = _ISPRINTF("D: Help [{1:03d}: {2:s}]", mapid, @mapinfos[mapid].name)
    else
      @sprites["title"].text = _INTL("D: Help")
    end
  end

  def hittest(x, y)
    @mapsprites.each_key do |i|
      sx = @mapsprites[i].x
      sy = @mapsprites[i].y
      sr = sx + @mapsprites[i].bitmap.width
      sb = sy + @mapsprites[i].bitmap.height
      return i if x >= sx && x < sr && y >= sy && y < sb
    end
    return -1
  end

  def chooseMapScreen(title, currentmap)
    return pbListScreen(title, MapLister.new(currentmap))
  end

  def update
    mousepos = Mouse.getMousePos
    if mousepos
      hitmap = hittest(mousepos[0], mousepos[1])
      if Input.trigger?(Input::MOUSELEFT)
        onClick(hitmap, mousepos[0], mousepos[1])
      elsif Input.trigger?(Input::MOUSERIGHT)
        onRightClick(hitmap, mousepos[0], mousepos[1])
      elsif Input.release?(Input::MOUSELEFT)
        onMouseUp(hitmap)
      elsif Input.release?(Input::MOUSERIGHT)
        onRightMouseUp(hitmap)
      else
        if @lasthitmap != hitmap
          onMouseOver(hitmap, mousepos[0], mousepos[1])
          @lasthitmap = hitmap
        end
        if @oldmousex != mousepos[0] || @oldmousey != mousepos[1]
          onMouseMove(hitmap, mousepos[0], mousepos[1])
          @oldmousex = mousepos[0]
          @oldmousey = mousepos[1]
        end
      end
    end
    if Input.press?(Input::UP)
      @mapsprites.each do |i|
        i[1].y += 4 if i
      end
    end
    if Input.press?(Input::DOWN)
      @mapsprites.each do |i|
        i[1].y -= 4 if i
      end
    end
    if Input.press?(Input::LEFT)
      @mapsprites.each do |i|
        i[1].x += 4 if i
      end
    end
    if Input.press?(Input::RIGHT)
      @mapsprites.each do |i|
        i[1].x -= 4 if i
      end
    end
    if Input.triggerex?(:A)
      id = chooseMapScreen(_INTL("Add Map"), @currentmap)
      if id > 0
        addSprite(id)
        setTopSprite(id)
        @mapconns = generateConnectionData
      end
    elsif Input.triggerex?(:S)
      id = chooseMapScreen(_INTL("Go to Map"), @currentmap)
      if id > 0
        @mapconns = generateConnectionData
        pbDisposeSpriteHash(@mapsprites)
        @mapsprites.clear
        @sprites["selsprite"].othersprite = nil
        @selmapid = -1
        putSprite(id)
        @currentmap = id
      end
    elsif Input.triggerex?(:DELETE)
      if @mapsprites.keys.length > 1 && @selmapid >= 0
        @mapsprites[@selmapid].bitmap.dispose
        @mapsprites[@selmapid].dispose
        @mapsprites.delete(@selmapid)
        @sprites["selsprite"].othersprite = nil
        @selmapid = -1
      end
    elsif Input.triggerex?(:D)
      helpWindow
    end
    pbUpdateSpriteHash(@sprites)
  end

  def pbMapScreenLoop
    loop do
      Graphics.update
      Input.update
      update
      if Input.trigger?(Input::BACK)
        if pbConfirmMessage(_INTL("Save changes?"))
          serializeConnectionData
          MapFactoryHelper.clear
        else
          GameData::Encounter.load
        end
        break if pbConfirmMessage(_INTL("Exit from the editor?"))
      end
    end
  end
end

#===============================================================================
#
#===============================================================================
def pbConnectionsEditor
  pbCriticalCode {
    Graphics.resize_screen(Settings::SCREEN_WIDTH + 288, Settings::SCREEN_HEIGHT + 288)
    pbSetResizeFactor(1)
    mapscreen = MapScreenScene.new
    mapscreen.mapScreen
    mapscreen.pbMapScreenLoop
    mapscreen.close
    Graphics.resize_screen(Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT)
    pbSetResizeFactor($PokemonSystem.screensize)
  }
end
