class MapBottomSprite < SpriteWrapper
  attr_reader :mapname
  attr_reader :maplocation

  def initialize(viewport=nil)
    super(viewport)
    @mapname     = ""
    @maplocation = ""
    @mapdetails  = ""
    @thisbitmap = BitmapWrapper.new(Graphics.width,Graphics.height)
    pbSetSystemFont(@thisbitmap)
    self.x = 0
    self.y = 0
    self.bitmap = @thisbitmap
    refresh
  end

  def dispose
    @thisbitmap.dispose
    super
  end

  def mapname=(value)
    if @mapname!=value
      @mapname = value
      refresh
    end
  end

  def maplocation=(value)
    if @maplocation!=value
      @maplocation = value
      refresh
    end
  end

  def mapdetails=(value)  # From Wichu
    if @mapdetails!=value
      @mapdetails = value
      refresh
    end
  end

  def refresh
    self.bitmap.clear
    textpos = [
       [@mapname,18,-2,0,Color.new(248,248,248),Color.new(0,0,0)],
       [@maplocation,18,354,0,Color.new(248,248,248),Color.new(0,0,0)],
       [@mapdetails,Graphics.width-16,354,1,Color.new(248,248,248),Color.new(0,0,0)]
    ]
    pbDrawTextPositions(self.bitmap,textpos)
  end
end



class PokemonRegionMap_Scene
  LEFT   = 0
  TOP    = 0
  RIGHT  = 29
  BOTTOM = 19
  SQUAREWIDTH  = 16
  SQUAREHEIGHT = 16

  def initialize(region=-1,wallmap=true)
    @region  = region
    @wallmap = wallmap
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(aseditor=false,mode=0)
    @editor = aseditor
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @mapdata = pbLoadTownMapData
    playerpos = (!$game_map) ? nil : pbGetMetadata($game_map.map_id,MetadataMapPosition)
    if !playerpos
      mapindex = 0
      @map     = @mapdata[0]
      @mapX    = LEFT
      @mapY    = TOP
    elsif @region>=0 && @region!=playerpos[0] && @mapdata[@region]
      mapindex = @region
      @map     = @mapdata[@region]
      @mapX    = LEFT
      @mapY    = TOP
    else
      mapindex = playerpos[0]
      @map     = @mapdata[playerpos[0]]
      @mapX    = playerpos[1]
      @mapY    = playerpos[2]
      mapsize = (!$game_map) ? nil : pbGetMetadata($game_map.map_id,MetadataMapSize)
      if mapsize && mapsize[0] && mapsize[0]>0
        sqwidth  = mapsize[0]
        sqheight = (mapsize[1].length*1.0/mapsize[0]).ceil
        if sqwidth>1
          @mapX += ($game_player.x*sqwidth/$game_map.width).floor
        end
        if sqheight>1
          @mapY += ($game_player.y*sqheight/$game_map.height).floor
        end
      end
    end
    if !@map
      pbMessage(_INTL("The map data cannot be found."))
      return false
    end
    addBackgroundOrColoredPlane(@sprites,"background","mapbg",Color.new(0,0,0),@viewport)
    @sprites["map"] = IconSprite.new(0,0,@viewport)
    @sprites["map"].setBitmap("Graphics/Pictures/#{@map[1]}")
    @sprites["map"].x += (Graphics.width-@sprites["map"].bitmap.width)/2
    @sprites["map"].y += (Graphics.height-@sprites["map"].bitmap.height)/2
    for hidden in REGION_MAP_EXTRAS
      if hidden[0]==mapindex && ((@wallmap && hidden[5]) ||
         (!@wallmap && hidden[1]>0 && $game_switches[hidden[1]]))
        if !@sprites["map2"]
          @sprites["map2"] = BitmapSprite.new(480,320,@viewport)
          @sprites["map2"].x = @sprites["map"].x
          @sprites["map2"].y = @sprites["map"].y
        end
        pbDrawImagePositions(@sprites["map2"].bitmap,[
           ["Graphics/Pictures/#{hidden[4]}",hidden[2]*SQUAREWIDTH,hidden[3]*SQUAREHEIGHT]
        ])
      end
    end
    @sprites["mapbottom"] = MapBottomSprite.new(@viewport)
    @sprites["mapbottom"].mapname     = pbGetMessage(MessageTypes::RegionNames,mapindex)
    @sprites["mapbottom"].maplocation = pbGetMapLocation(@mapX,@mapY)
    @sprites["mapbottom"].mapdetails  = pbGetMapDetails(@mapX,@mapY)
    if playerpos && mapindex==playerpos[0]
      @sprites["player"] = IconSprite.new(0,0,@viewport)
      @sprites["player"].setBitmap(pbPlayerHeadFile($Trainer.trainertype))
      @sprites["player"].x = -SQUAREWIDTH/2+(@mapX*SQUAREWIDTH)+(Graphics.width-@sprites["map"].bitmap.width)/2
      @sprites["player"].y = -SQUAREHEIGHT/2+(@mapY*SQUAREHEIGHT)+(Graphics.height-@sprites["map"].bitmap.height)/2
    end
    if mode>0
      k = 0
      for i in LEFT..RIGHT
        for j in TOP..BOTTOM
          healspot = pbGetHealingSpot(i,j)
          if healspot && $PokemonGlobal.visitedMaps[healspot[0]]
            @sprites["point#{k}"] = AnimatedSprite.create("Graphics/Pictures/mapFly",2,16)
            @sprites["point#{k}"].viewport = @viewport
            @sprites["point#{k}"].x        = -SQUAREWIDTH/2+(i*SQUAREWIDTH)+(Graphics.width-@sprites["map"].bitmap.width)/2
            @sprites["point#{k}"].y        = -SQUAREHEIGHT/2+(j*SQUAREHEIGHT)+(Graphics.height-@sprites["map"].bitmap.height)/2
            @sprites["point#{k}"].play
            k += 1
          end
        end
      end
    end
    @sprites["cursor"] = AnimatedSprite.create("Graphics/Pictures/mapCursor",2,5)
    @sprites["cursor"].viewport = @viewport
    @sprites["cursor"].x        = -SQUAREWIDTH/2+(@mapX*SQUAREWIDTH)+(Graphics.width-@sprites["map"].bitmap.width)/2
    @sprites["cursor"].y        = -SQUAREHEIGHT/2+(@mapY*SQUAREHEIGHT)+(Graphics.height-@sprites["map"].bitmap.height)/2
    @sprites["cursor"].play
    @changed = false
    pbFadeInAndShow(@sprites) { pbUpdate }
    return true
  end

  def pbSaveMapData
    File.open("PBS/townmap.txt","wb") { |f|
      for i in 0...@mapdata.length
        map = @mapdata[i]
        return if !map
        f.write(sprintf("[%d]\r\n",i))
        f.write(sprintf("Name=%s\r\nFilename=%s\r\n",csvQuote(map[0]),csvQuote(map[1])))
        for loc in map[2]
          f.write("Point=")
          pbWriteCsvRecord(loc,f,[nil,"uussUUUU"])
          f.write("\r\n")
        end
      end
    }
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbGetMapLocation(x,y)
    return "" if !@map[2]
    for loc in @map[2]
      if loc[0]==x && loc[1]==y
        if !loc[7] || (!@wallmap && $game_switches[loc[7]])
          maploc = pbGetMessageFromHash(MessageTypes::PlaceNames,loc[2])
          return @editor ? loc[2] : maploc
        else
          return ""
        end
      end
    end
    return ""
  end

  def pbChangeMapLocation(x,y)
    return if !@editor
    return "" if !@map[2]
    currentname = ""
    currentobj  = nil
    for loc in @map[2]
      if loc[0]==x && loc[1]==y
        currentobj  = loc
        currentname = loc[2]
        break
      end
    end
    currentname = pbMessageFreeText(_INTL("Set the name for this point."),currentname,false,256) { pbUpdate }
    if currentname
      if currentobj
        currentobj[2] = currentname
      else
        newobj = [x,y,currentname,""]
        @map[2].push(newobj)
      end
      @changed = true
    end
  end

  def pbGetMapDetails(x,y) # From Wichu, with my help
    return "" if !@map[2]
    for loc in @map[2]
      if loc[0]==x && loc[1]==y
        if !loc[7] || (!@wallmap && $game_switches[loc[7]])
          mapdesc = pbGetMessageFromHash(MessageTypes::PlaceDescriptions,loc[3])
          return (@editor) ? loc[3] : mapdesc
        else
          return ""
        end
      end
    end
    return ""
  end

  def pbGetHealingSpot(x,y)
    return nil if !@map[2]
    for loc in @map[2]
      if loc[0]==x && loc[1]==y
        if !loc[4] || !loc[5] || !loc[6]
          return nil
        else
          return [loc[4],loc[5],loc[6]]
        end
      end
    end
    return nil
  end

  def pbMapScene(mode=0)
    xOffset = 0
    yOffset = 0
    newX = 0
    newY = 0
    @sprites["cursor"].x = -SQUAREWIDTH/2+(@mapX*SQUAREWIDTH)+(Graphics.width-@sprites["map"].bitmap.width)/2
    @sprites["cursor"].y = -SQUAREHEIGHT/2+(@mapY*SQUAREHEIGHT)+(Graphics.height-@sprites["map"].bitmap.height)/2
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if xOffset!=0 || yOffset!=0
        distancePerFrame = 8*20/Graphics.frame_rate
        xOffset += (xOffset>0) ? -distancePerFrame : (xOffset<0) ? distancePerFrame : 0
        yOffset += (yOffset>0) ? -distancePerFrame : (yOffset<0) ? distancePerFrame : 0
        @sprites["cursor"].x = newX-xOffset
        @sprites["cursor"].y = newY-yOffset
        next
      end
      @sprites["mapbottom"].maplocation = pbGetMapLocation(@mapX,@mapY)
      @sprites["mapbottom"].mapdetails  = pbGetMapDetails(@mapX,@mapY)
      ox = 0
      oy = 0
      case Input.dir8
      when 1   # lower left
        oy = 1 if @mapY<BOTTOM
        ox = -1 if @mapX>LEFT
      when 2   # down
        oy = 1 if @mapY<BOTTOM
      when 3   # lower right
        oy = 1 if @mapY<BOTTOM
        ox = 1 if @mapX<RIGHT
      when 4   # left
        ox = -1 if @mapX>LEFT
      when 6   # right
        ox = 1 if @mapX<RIGHT
      when 7   # upper left
        oy = -1 if @mapY>TOP
        ox = -1 if @mapX>LEFT
      when 8   # up
        oy = -1 if @mapY>TOP
      when 9   # upper right
        oy = -1 if @mapY>TOP
        ox = 1 if @mapX<RIGHT
      end
      if ox!=0 || oy!=0
        @mapX += ox
        @mapY += oy
        xOffset = ox*SQUAREWIDTH
        yOffset = oy*SQUAREHEIGHT
        newX = @sprites["cursor"].x+xOffset
        newY = @sprites["cursor"].y+yOffset
      end
      if Input.trigger?(Input::B)
        if @editor && @changed
          if pbConfirmMessage(_INTL("Save changes?")) { pbUpdate }
            pbSaveMapData
          end
          if pbConfirmMessage(_INTL("Exit from the map?")) { pbUpdate }
            break
          end
        else
          break
        end
      elsif Input.trigger?(Input::C) && mode==1   # Choosing an area to fly to
        healspot = pbGetHealingSpot(@mapX,@mapY)
        if healspot
          if $PokemonGlobal.visitedMaps[healspot[0]] || ($DEBUG && Input.press?(Input::CTRL))
            return healspot
          end
        end
      elsif Input.trigger?(Input::C) && @editor   # Intentionally after other C input check
        pbChangeMapLocation(@mapX,@mapY)
      end
    end
    pbPlayCloseMenuSE
    return nil
  end
end



class PokemonRegionMapScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartFlyScreen
    @scene.pbStartScene(false,1)
    ret = @scene.pbMapScene(1)
    @scene.pbEndScene
    return ret
  end

  def pbStartScreen
    @scene.pbStartScene($DEBUG)
    @scene.pbMapScene
    @scene.pbEndScene
  end
end



def pbShowMap(region=-1,wallmap=true)
  pbFadeOutIn {
    scene = PokemonRegionMap_Scene.new(region,wallmap)
    screen = PokemonRegionMapScreen.new(scene)
    screen.pbStartScreen
  }
end
