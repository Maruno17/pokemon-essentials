#===============================================================================
# Miniature game map/Town Map drawing
#===============================================================================
class MapSprite
  def initialize(map,viewport=nil)
    @sprite=Sprite.new(viewport)
    @sprite.bitmap=createMinimap(map)
    @sprite.x=(Graphics.width/2)-(@sprite.bitmap.width/2)
    @sprite.y=(Graphics.height/2)-(@sprite.bitmap.height/2)
  end

  def dispose
    @sprite.bitmap.dispose
    @sprite.dispose
  end

  def z=(value)
    @sprite.z=value
  end

  def getXY
    return nil if !Input.triggerex?(Input::LeftMouseKey)
    mouse = Mouse::getMousePos(true)
    return nil if !mouse
    if mouse[0]<@sprite.x || mouse[0]>=@sprite.x+@sprite.bitmap.width
      return nil
    end
    if mouse[1]<@sprite.y || mouse[1]>=@sprite.y+@sprite.bitmap.height
      return nil
    end
    x = mouse[0]-@sprite.x
    y = mouse[1]-@sprite.y
    return [x/4,y/4]
  end
end



class SelectionSprite < Sprite
  def initialize(viewport=nil)
    @sprite=Sprite.new(viewport)
    @sprite.bitmap=nil
    @sprite.z=2
    @othersprite=nil
  end

  def disposed?
    return @sprite.disposed?
  end

  def dispose
    @sprite.bitmap.dispose if @sprite.bitmap
    @othersprite=nil
    @sprite.dispose
  end

  def othersprite=(value)
    @othersprite=value
    if @othersprite && !@othersprite.disposed? &&
       @othersprite.bitmap && !@othersprite.bitmap.disposed?
      @sprite.bitmap=pbDoEnsureBitmap(
         @sprite.bitmap,@othersprite.bitmap.width,@othersprite.bitmap.height)
      red=Color.new(255,0,0)
      @sprite.bitmap.clear
      @sprite.bitmap.fill_rect(0,0,@othersprite.bitmap.width,2,red)
      @sprite.bitmap.fill_rect(0,@othersprite.bitmap.height-2,
         @othersprite.bitmap.width,2,red)
      @sprite.bitmap.fill_rect(0,0,2,@othersprite.bitmap.height,red)
      @sprite.bitmap.fill_rect(@othersprite.bitmap.width-2,0,2,
         @othersprite.bitmap.height,red)
    end
  end

  def update
    if @othersprite && !@othersprite.disposed?
      @sprite.visible=@othersprite.visible
      @sprite.x=@othersprite.x
      @sprite.y=@othersprite.y
    else
      @sprite.visible=false
    end
  end
end



class RegionMapSprite
  def initialize(map,viewport=nil)
    @sprite=Sprite.new(viewport)
    @sprite.bitmap=createRegionMap(map)
    @sprite.x=(Graphics.width/2)-(@sprite.bitmap.width/2)
    @sprite.y=(Graphics.height/2)-(@sprite.bitmap.height/2)
  end

  def dispose
    @sprite.bitmap.dispose
    @sprite.dispose
  end

  def z=(value)
    @sprite.z=value
  end

  def getXY
    return nil if !Input.triggerex?(Input::LeftMouseKey)
    mouse=Mouse::getMousePos(true)
    return nil if !mouse
    if mouse[0]<@sprite.x||mouse[0]>=@sprite.x+@sprite.bitmap.width
      return nil
    end
    if mouse[1]<@sprite.y||mouse[1]>=@sprite.y+@sprite.bitmap.height
      return nil
    end
    x=mouse[0]-@sprite.x
    y=mouse[1]-@sprite.y
    return [x/8,y/8]
  end
end



def createRegionMap(map)
  @mapdata = pbLoadTownMapData
  @map=@mapdata[map]
  bitmap=AnimatedBitmap.new("Graphics/Pictures/#{@map[1]}").deanimate
  retbitmap=BitmapWrapper.new(bitmap.width/2,bitmap.height/2)
  retbitmap.stretch_blt(
     Rect.new(0,0,bitmap.width/2,bitmap.height/2),
     bitmap,
     Rect.new(0,0,bitmap.width,bitmap.height)
  )
  bitmap.dispose
  return retbitmap
end

def getMapNameList
  @mapdata = pbLoadTownMapData
  ret=[]
  for i in 0...@mapdata.length
    next if !@mapdata[i]
    ret.push(
       [i,pbGetMessage(MessageTypes::RegionNames,i)]
    )
  end
  return ret
end

def createMinimap2(mapid)
  map=load_data(sprintf("Data/Map%03d.rxdata",mapid)) rescue nil
  return BitmapWrapper.new(32,32) if !map
  bitmap=BitmapWrapper.new(map.width*4,map.height*4)
  black=Color.new(0,0,0)
  bigmap=(map.width>40 && map.height>40)
  tilesets=load_data("Data/Tilesets.rxdata")
  tileset=tilesets[map.tileset_id]
  return bitmap if !tileset
  helper=TileDrawingHelper.fromTileset(tileset)
  for y in 0...map.height
    for x in 0...map.width
      if bigmap
        next if (x>8 && x<=map.width-8 && y>8 && y<=map.height-8)
      end
      for z in 0..2
        id=map.data[x,y,z]
        next if id==0 || !id
        helper.bltSmallTile(bitmap,x*4,y*4,4,4,id)
      end
    end
  end
  bitmap.fill_rect(0,0,bitmap.width,1,black)
  bitmap.fill_rect(0,bitmap.height-1,bitmap.width,1,black)
  bitmap.fill_rect(0,0,1,bitmap.height,black)
  bitmap.fill_rect(bitmap.width-1,0,1,bitmap.height,black)
  return bitmap
end

def createMinimap(mapid)
  map=load_data(sprintf("Data/Map%03d.rxdata",mapid)) rescue nil
  return BitmapWrapper.new(32,32) if !map
  bitmap=BitmapWrapper.new(map.width*4,map.height*4)
  black=Color.new(0,0,0)
  tilesets=load_data("Data/Tilesets.rxdata")
  tileset=tilesets[map.tileset_id]
  return bitmap if !tileset
  helper=TileDrawingHelper.fromTileset(tileset)
  for y in 0...map.height
    for x in 0...map.width
      for z in 0..2
        id=map.data[x,y,z]
        id=0 if !id
        helper.bltSmallTile(bitmap,x*4,y*4,4,4,id)
      end
    end
  end
  bitmap.fill_rect(0,0,bitmap.width,1,black)
  bitmap.fill_rect(0,bitmap.height-1,bitmap.width,1,black)
  bitmap.fill_rect(0,0,1,bitmap.height,black)
  bitmap.fill_rect(bitmap.width-1,0,1,bitmap.height,black)
  return bitmap
end

def chooseMapPoint(map,rgnmap=false)
  viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z=99999
  title=Window_UnformattedTextPokemon.new(_INTL("Click a point on the map."))
  title.x=0
  title.y=Graphics.height-64
  title.width=Graphics.width
  title.height=64
  title.viewport=viewport
  title.z=2
  if rgnmap
    sprite=RegionMapSprite.new(map,viewport)
  else
    sprite=MapSprite.new(map,viewport)
  end
  sprite.z=2
  ret=nil
  loop do
    Graphics.update
    Input.update
    xy=sprite.getXY
    if xy
      ret=xy
      break
    end
    if Input.trigger?(Input::B)
      ret=nil
      break
    end
  end
  sprite.dispose
  title.dispose
  return ret
end



#===============================================================================
# Visual Editor (map connections)
#===============================================================================
class MapScreenScene
  GLOBALMETADATA=[
     ["Home",MapCoordsFacingProperty,
        _INTL("Map ID and X and Y coordinates of where the player goes if no Pokémon Center was entered after a loss.")],
     ["WildBattleBGM",BGMProperty,
        _INTL("Default BGM for wild Pokémon battles.")],
     ["TrainerBattleBGM",BGMProperty,
        _INTL("Default BGM for Trainer battles.")],
     ["WildVictoryME",MEProperty,
        _INTL("Default ME played after winning a wild Pokémon battle.")],
     ["TrainerVictoryME",MEProperty,
        _INTL("Default ME played after winning a Trainer battle.")],
     ["WildCaptureME",MEProperty,
        _INTL("Default ME played after catching a Pokémon.")],
     ["SurfBGM",BGMProperty,
        _INTL("BGM played while surfing.")],
     ["BicycleBGM",BGMProperty,
        _INTL("BGM played while on a bicycle.")],
     ["PlayerA",PlayerProperty,
        _INTL("Specifies player A.")],
     ["PlayerB",PlayerProperty,
        _INTL("Specifies player B.")],
     ["PlayerC",PlayerProperty,
        _INTL("Specifies player C.")],
     ["PlayerD",PlayerProperty,
        _INTL("Specifies player D.")],
     ["PlayerE",PlayerProperty,
        _INTL("Specifies player E.")],
     ["PlayerF",PlayerProperty,
        _INTL("Specifies player F.")],
     ["PlayerG",PlayerProperty,
        _INTL("Specifies player G.")],
     ["PlayerH",PlayerProperty,
        _INTL("Specifies player H.")]
  ]
  LOCALMAPS = [
     ["Outdoor",BooleanProperty,
        _INTL("If true, this map is an outdoor map and will be tinted according to time of day.")],
     ["ShowArea",BooleanProperty,
        _INTL("If true, the game will display the map's name upon entry.")],
     ["Bicycle",BooleanProperty,
        _INTL("If true, the bicycle can be used on this map.")],
     ["BicycleAlways",BooleanProperty,
        _INTL("If true, the bicycle will be mounted automatically on this map and cannot be dismounted.")],
     ["HealingSpot",MapCoordsProperty,
        _INTL("Map ID of this Pokémon Center's town, and X and Y coordinates of its entrance within that town.")],
     ["Weather",WeatherEffectProperty,
        _INTL("Weather conditions in effect for this map.")],
     ["MapPosition",RegionMapCoordsProperty,
        _INTL("Identifies the point on the regional map for this map.")],
     ["DiveMap",MapProperty,
        _INTL("Specifies the underwater layer of this map. Use only if this map has deep water.")],
     ["DarkMap",BooleanProperty,
        _INTL("If true, this map is dark and a circle of light appears around the player. Flash can be used to expand the circle.")],
     ["SafariMap",BooleanProperty,
        _INTL("If true, this map is part of the Safari Zone (both indoor and outdoor). Not to be used in the reception desk.")],
     ["SnapEdges",BooleanProperty,
        _INTL("If true, when the player goes near this map's edge, the game doesn't center the player as usual.")],
     ["Dungeon",BooleanProperty,
        _INTL("If true, this map has a randomly generated layout. See the wiki for more information.")],
     ["BattleBack",StringProperty,
        _INTL("PNG files named 'XXX_bg', 'XXX_base0', 'XXX_base1', 'XXX_message' in Battlebacks folder, where XXX is this property's value.")],
     ["WildBattleBGM",BGMProperty,
        _INTL("Default BGM for wild Pokémon battles on this map.")],
     ["TrainerBattleBGM",BGMProperty,
        _INTL("Default BGM for trainer battles on this map.")],
     ["WildVictoryME",MEProperty,
        _INTL("Default ME played after winning a wild Pokémon battle on this map.")],
     ["TrainerVictoryME",MEProperty,
        _INTL("Default ME played after winning a Trainer battle on this map.")],
     ["WildCaptureME",MEProperty,
        _INTL("Default ME played after catching a wild Pokémon on this map.")],
     ["MapSize",MapSizeProperty,
        _INTL("The width of the map in Town Map squares, and a string indicating which squares are part of this map.")],
     ["Environment",EnvironmentProperty,
        _INTL("The default battle environment for battles on this map.")]
  ]

  def getMapSprite(id)
    if !@mapsprites[id]
      @mapsprites[id]=Sprite.new(@viewport)
      @mapsprites[id].z=0
      @mapsprites[id].bitmap=nil
    end
    if !@mapsprites[id].bitmap || @mapsprites[id].bitmap.disposed?
      @mapsprites[id].bitmap=createMinimap(id)
    end
    return @mapsprites[id]
  end

  def close
    pbDisposeSpriteHash(@sprites)
    pbDisposeSpriteHash(@mapsprites)
    @viewport.dispose
  end

  def setMapSpritePos(id,x,y)
    sprite=getMapSprite(id)
    sprite.x=x
    sprite.y=y
    sprite.visible=true
  end

  def putNeighbors(id,sprites)
    conns=@mapconns
    mapsprite=getMapSprite(id)
    dispx=mapsprite.x
    dispy=mapsprite.y
    for conn in conns
      if conn[0]==id
        b=sprites.any? { |i| i==conn[3] }
        if !b
          x=(conn[1]-conn[4])*4+dispx
          y=(conn[2]-conn[5])*4+dispy
          setMapSpritePos(conn[3],x,y)
          sprites.push(conn[3])
          putNeighbors(conn[3],sprites)
        end
      elsif conn[3]==id
        b=sprites.any? { |i| i==conn[0] }
        if !b
          x=(conn[4]-conn[1])*4+dispx
          y=(conn[5]-conn[2])*4+dispy
          setMapSpritePos(conn[0],x,y)
          sprites.push(conn[3])
          putNeighbors(conn[0],sprites)
        end
      end
    end
  end

  def hasConnections?(conns,id)
    for conn in conns
      return true if conn[0]==id || conn[3]==id
    end
    return false
  end

  def connectionsSymmetric?(conn1,conn2)
    if conn1[0]==conn2[0]
      # Equality
      return false if conn1[1]!=conn2[1]
      return false if conn1[2]!=conn2[2]
      return false if conn1[3]!=conn2[3]
      return false if conn1[4]!=conn2[4]
      return false if conn1[5]!=conn2[5]
      return true
    elsif conn1[0]==conn2[3]
      # Symmetry
      return false if conn1[1]!=-conn2[1]
      return false if conn1[2]!=-conn2[2]
      return false if conn1[3]!=conn2[0]
      return false if conn1[4]!=-conn2[4]
      return false if conn1[5]!=-conn2[5]
      return true
    end
    return false
  end

  def removeOldConnections(ret,mapid)
    for i in 0...ret.length
      ret[i]=nil if ret[i][0]==mapid || ret[i][3]==mapid
    end
    ret.compact!
  end

# Returns the maps within _keys_ that are directly connected to this map, _map_.
  def getDirectConnections(keys,map)
    thissprite=getMapSprite(map)
    thisdims=MapFactoryHelper.getMapDims(map)
    ret=[]
    for i in keys
      next if i==map
      othersprite=getMapSprite(i)
      otherdims=MapFactoryHelper.getMapDims(i)
      x1=(thissprite.x-othersprite.x)/4
      y1=(thissprite.y-othersprite.y)/4
      if (x1==otherdims[0] || x1==-thisdims[0] ||
          y1==otherdims[1] || y1==-thisdims[1])
        ret.push(i)
      end
    end
    # If no direct connections, add an indirect connection
    if ret.length==0
      key=(map==keys[0]) ? keys[1] : keys[0]
      ret.push(key)
    end
    return ret
  end

  def generateConnectionData
    ret=[]
    # Create a clone of current map connection
    for conn in @mapconns
      ret.push(conn.clone)
    end
    keys=@mapsprites.keys
    return ret if keys.length<2
    # Remove all connections containing any sprites on the canvas from the array
    for i in keys
      removeOldConnections(ret,i)
    end
    # Rebuild connections
    for i in keys
      refs=getDirectConnections(keys,i)
      for refmap in refs
        othersprite=getMapSprite(i)
        refsprite=getMapSprite(refmap)
        c1=(refsprite.x-othersprite.x)/4
        c2=(refsprite.y-othersprite.y)/4
        conn=[refmap,0,0,i,c1,c2]
        j=0
        while j<ret.length && !connectionsSymmetric?(ret[j],conn)
          j+=1
        end
        if j==ret.length
          ret.push(conn)
        end
      end
    end
    return ret
  end

  def serializeConnectionData
    conndata=generateConnectionData()
    pbSerializeConnectionData(conndata,@mapinfos)
    @mapconns=conndata
  end

  def putSprite(id)
    addSprite(id)
    putNeighbors(id,[])
  end

  def addSprite(id)
    mapsprite=getMapSprite(id)
    x=(Graphics.width-mapsprite.bitmap.width)/2
    y=(Graphics.height-mapsprite.bitmap.height)/2
    mapsprite.x=x.to_i&~3
    mapsprite.y=y.to_i&~3
  end

  def saveMapSpritePos
    @mapspritepos.clear
    for i in @mapsprites.keys
      s=@mapsprites[i]
      @mapspritepos[i]=[s.x,s.y] if s && !s.disposed?
    end
  end

  def mapScreen
    @sprites={}
    @mapsprites={}
    @mapspritepos={}
    @viewport=Viewport.new(0,0,800,600)
    @viewport.z=99999
    @lasthitmap=-1
    @lastclick=-1
    @oldmousex=nil
    @oldmousey=nil
    @dragging=false
    @dragmapid=-1
    @dragOffsetX=0
    @dragOffsetY=0
    @selmapid=-1
    addBackgroundPlane(@sprites,"background","Trainer Card/bg",@viewport)
    @sprites["selsprite"]=SelectionSprite.new(@viewport)
    @sprites["title"]=Window_UnformattedTextPokemon.new(_INTL("F: Help"))
    @sprites["title"].x=0
    @sprites["title"].y=600-64
    @sprites["title"].width=800
    @sprites["title"].height=64
    @sprites["title"].viewport=@viewport
    @sprites["title"].z=2
    @mapinfos=load_data("Data/MapInfos.rxdata")
    @encdata=pbLoadEncountersData
    conns=MapFactoryHelper.getMapConnections
    @mapconns=[]
    for c in conns
      @mapconns.push(c.clone)
    end
    @metadata=pbLoadMetadata
    if $game_map
      @currentmap=$game_map.map_id
    else
      system=load_data("Data/System.rxdata")
      @currentmap=system.edit_map_id
    end
    putSprite(@currentmap)
  end

  def setTopSprite(id)
    for i in @mapsprites.keys
      if i==id
        @mapsprites[i].z=1
      else
        @mapsprites[i].z=0
      end
    end
  end

  def getMetadata(mapid,metadataType)
    return @metadata[mapid][metadataType] if @metadata[mapid]
  end

  def setMetadata(mapid,metadataType,data)
    @metadata[mapid]=[] if !@metadata[mapid]
    @metadata[mapid][metadataType]=data
  end

  def serializeMetadata
    pbSerializeMetadata(@metadata,@mapinfos)
  end

  def helpWindow
    helptext=_INTL("A: Add map to canvas\r\n")
    helptext+=_INTL("DEL: Delete map from canvas\r\n")
    helptext+=_INTL("S: Go to another map\r\n")
    helptext+=_INTL("Click to select a map\r\n")
    helptext+=_INTL("Double-click: Edit map's metadata\r\n")
    helptext+=_INTL("E: Edit map's encounters\r\n")
    helptext+=_INTL("Drag map to move it\r\n")
    helptext+=_INTL("Arrow keys/drag canvas: Move around canvas")
    title=Window_UnformattedTextPokemon.new(helptext)
    title.x=0
    title.y=0
    title.width=800*8/10
    title.height=600
    title.viewport=@viewport
    title.z=2
    loop do
      Graphics.update
      Input.update
      break if Input.trigger?(Input::B) || Input.trigger?(Input::C)
    end
    Input.update
    title.dispose
  end

  def propertyList(map,properties)
    infos=load_data("Data/MapInfos.rxdata")
    mapname=(map==0) ? _INTL("Global Metadata") : infos[map].name
    data=[]
    for i in 0...properties.length
      data.push(getMetadata(map,i+1))
    end
    pbPropertyList(mapname,data,properties)
    for i in 0...properties.length
      setMetadata(map,i+1,data[i])
    end
  end

  def getMapRect(mapid)
    sprite=getMapSprite(mapid)
    if sprite
      return [
         sprite.x,
         sprite.y,
         sprite.x+sprite.bitmap.width,
         sprite.y+sprite.bitmap.height
      ]
    else
      return nil
    end
  end

  def onDoubleClick(mapid)
    if mapid>=0
      propertyList(mapid,LOCALMAPS)
    else
      propertyList(0,GLOBALMETADATA)
    end
  end

  def onClick(mapid,x,y)
    if @lastclick>0 && Graphics.frame_count-@lastclick<15
      onDoubleClick(mapid)
      @lastclick=-1
    else
      @lastclick=Graphics.frame_count
      if mapid>=0
        @dragging=true
        @dragmapid=mapid
        sprite=getMapSprite(mapid)
        @sprites["selsprite"].othersprite=sprite
        @selmapid=mapid
        @dragOffsetX=sprite.x-x
        @dragOffsetY=sprite.y-y
        setTopSprite(mapid)
      else
        @sprites["selsprite"].othersprite=nil
        @dragging=true
        @dragmapid=mapid
        @selmapid=-1
        @dragOffsetX=x
        @dragOffsetY=y
        saveMapSpritePos
      end
    end
  end

  def onRightClick(mapid,x,y)
#   echo("rightclick (#{mapid})\r\n")
  end

  def onMouseUp(mapid)
#   echo("mouseup (#{mapid})\r\n")
    @dragging=false if @dragging
  end

  def onRightMouseUp(mapid)
#   echo("rightmouseup (#{mapid})\r\n")
  end

  def onMouseOver(mapid,x,y)
#   echo("mouseover (#{mapid},#{x},#{y})\r\n")
  end

  def onMouseMove(mapid,x,y)
#   echo("mousemove (#{mapid},#{x},#{y})\r\n")
    if @dragging
      if @dragmapid>=0
        sprite=getMapSprite(@dragmapid)
        x=x+@dragOffsetX
        y=y+@dragOffsetY
        sprite.x=x&~3
        sprite.y=y&~3
        @sprites["title"].text=_ISPRINTF("F: Help [{1:03d}: {2:s}]",mapid,@mapinfos[@dragmapid].name)
      else
        xpos=x-@dragOffsetX
        ypos=y-@dragOffsetY
        for i in @mapspritepos.keys
          sprite=getMapSprite(i)
          sprite.x=(@mapspritepos[i][0]+xpos)&~3
          sprite.y=(@mapspritepos[i][1]+ypos)&~3
        end
        @sprites["title"].text=_INTL("F: Help")
      end
    else
      if mapid>=0
        @sprites["title"].text=_ISPRINTF("F: Help [{1:03d}: {2:s}]",mapid,@mapinfos[mapid].name)
      else
        @sprites["title"].text=_INTL("F: Help")
      end
    end
  end

  def hittest(x,y)
    for i in @mapsprites.keys
      sx=@mapsprites[i].x
      sy=@mapsprites[i].y
      sr=sx+@mapsprites[i].bitmap.width
      sb=sy+@mapsprites[i].bitmap.height
      return i if x>=sx && x<sr && y>=sy && y<sb
    end
    return -1
  end

  def chooseMapScreen(title,currentmap)
    return pbListScreen(title,MapLister.new(currentmap))
  end

  def update
    mousepos=Mouse::getMousePos
    if mousepos
      hitmap=hittest(mousepos[0],mousepos[1])
      if Input.triggerex?(Input::LeftMouseKey)
        onClick(hitmap,mousepos[0],mousepos[1])
      elsif Input.triggerex?(Input::RightMouseKey)
        onRightClick(hitmap,mousepos[0],mousepos[1])
      elsif Input.releaseex?(Input::LeftMouseKey)
        onMouseUp(hitmap)
      elsif Input.releaseex?(Input::RightMouseKey)
        onRightMouseUp(hitmap)
      else
        if @lasthitmap!=hitmap
          onMouseOver(hitmap,mousepos[0],mousepos[1])
          @lasthitmap=hitmap
        end
        if @oldmousex!=mousepos[0]||@oldmousey!=mousepos[1]
          onMouseMove(hitmap,mousepos[0],mousepos[1])
          @oldmousex=mousepos[0]
          @oldmousey=mousepos[1]
        end
      end
    end
    if Input.press?(Input::UP)
      for i in @mapsprites
        next if !i
        i[1].y+=4
      end
    end
    if Input.press?(Input::DOWN)
      for i in @mapsprites
        next if !i
        i[1].y-=4
      end
    end
    if Input.press?(Input::LEFT)
      for i in @mapsprites
        next if !i
        i[1].x+=4
      end
    end
    if Input.press?(Input::RIGHT)
      for i in @mapsprites
        next if !i
        i[1].x-=4
      end
    end
    if Input.triggerex?("A"[0])
      id=chooseMapScreen(_INTL("Add Map"),@currentmap)
      if id>0
        addSprite(id)
        setTopSprite(id)
        @mapconns=generateConnectionData
      end
    elsif Input.triggerex?("S"[0])
      id=chooseMapScreen(_INTL("Go to Map"),@currentmap)
      if id>0
        @mapconns=generateConnectionData
        pbDisposeSpriteHash(@mapsprites)
        @mapsprites.clear
        @sprites["selsprite"].othersprite=nil
        @selmapid=-1
        putSprite(id)
        @currentmap=id
      end
    elsif Input.trigger?(Input::DELETE)
      if @mapsprites.keys.length>1 && @selmapid>=0
        @mapsprites[@selmapid].bitmap.dispose
        @mapsprites[@selmapid].dispose
        @mapsprites.delete(@selmapid)
        @sprites["selsprite"].othersprite=nil
        @selmapid=-1
      end
    elsif Input.triggerex?("E"[0])
      pbEncounterEditorMap(@encdata,@selmapid) if @selmapid>=0
    elsif Input.trigger?(Input::F5)
      helpWindow
    end
    pbUpdateSpriteHash(@sprites)
  end

  def pbMapScreenLoop
    loop do
      Graphics.update
      Input.update
      update
      if Input.trigger?(Input::B)
        if pbConfirmMessage(_INTL("Save changes?"))
          serializeConnectionData
          serializeMetadata
          save_data(@encdata,"Data/encounters.dat")
          pbClearData
          pbSaveEncounterData
        end
        break if pbConfirmMessage(_INTL("Exit from the editor?"))
      end
    end
  end
end



def pbConnectionsEditor
  pbCriticalCode {
     mapscreen = MapScreenScene.new
     mapscreen.mapScreen
     mapscreen.pbMapScreenLoop
     mapscreen.close
  }
end
