#===============================================================================
#
#===============================================================================
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
       [@mapname,18,-8,0,Color.new(248,248,248),Color.new(0,0,0)],
       [@maplocation,18,348,0,Color.new(248,248,248),Color.new(0,0,0)],
       [@mapdetails,Graphics.width-16,348,1,Color.new(248,248,248),Color.new(0,0,0)]
    ]
    pbDrawTextPositions(self.bitmap,textpos)
  end
end

#===============================================================================
#
#===============================================================================
class PokemonRegionMap_Scene
  LEFT   = 0
  TOP    = 0
  RIGHT  = 29
  BOTTOM = 19
  SQUAREWIDTH  = 16
  SQUAREHEIGHT = 16

  def initialize(region =- 1, wallmap = true)
    @region  = region
    @wallmap = wallmap
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(as_editor = false, fly_map = false)
    @editor   = as_editor
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @mapdata = pbLoadTownMapData
    @fly_map = fly_map
    @mode    = fly_map ? 1 : 0
    map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
    playerpos = (map_metadata) ? map_metadata.town_map_position : nil
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
      mapsize = map_metadata.town_map_size
      if mapsize && mapsize[0] && mapsize[0]>0
        sqwidth  = mapsize[0]
        sqheight = (mapsize[1].length*1.0/mapsize[0]).ceil
        @mapX += ($game_player.x*sqwidth/$game_map.width).floor if sqwidth>1
        @mapY += ($game_player.y*sqheight/$game_map.height).floor if sqheight>1
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
    for hidden in Settings::REGION_MAP_EXTRAS
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
      @sprites["player"].setBitmap(GameData::TrainerType.player_map_icon_filename($Trainer.trainer_type))
      @sprites["player"].x = -SQUAREWIDTH/2+(@mapX*SQUAREWIDTH)+(Graphics.width-@sprites["map"].bitmap.width)/2
      @sprites["player"].y = -SQUAREHEIGHT/2+(@mapY*SQUAREHEIGHT)+(Graphics.height-@sprites["map"].bitmap.height)/2
    end
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
          @sprites["point#{k}"].visible  = @mode == 1
          k += 1
        end
      end
    end
    @sprites["cursor"] = AnimatedSprite.create("Graphics/Pictures/mapCursor",2,5)
    @sprites["cursor"].viewport = @viewport
    @sprites["cursor"].x        = -SQUAREWIDTH/2+(@mapX*SQUAREWIDTH)+(Graphics.width-@sprites["map"].bitmap.width)/2
    @sprites["cursor"].y        = -SQUAREHEIGHT/2+(@mapY*SQUAREHEIGHT)+(Graphics.height-@sprites["map"].bitmap.height)/2
    @sprites["cursor"].play
    @sprites["help"] = BitmapSprite.new(Graphics.width, 28, @viewport)
    refresh_fly_screen
    @changed = false
    pbFadeInAndShow(@sprites) { pbUpdate }
    return true
  end

  # TODO: Why is this PBS file writer here?
  def pbSaveMapData
    File.open("PBS/town_map.txt","wb") { |f|
      Compiler.add_PBS_header_to_file(f)
      for i in 0...@mapdata.length
        map = @mapdata[i]
        next if !map
        f.write("\#-------------------------------\r\n")
        f.write(sprintf("[%d]\r\n",i))
        f.write(sprintf("Name = %s\r\nFilename = %s\r\n",
          Compiler.csvQuote(map[0]), Compiler.csvQuote(map[1])))
        for loc in map[2]
          f.write("Point = ")
          Compiler.pbWriteCsvRecord(loc,f,[nil,"uussUUUU"])
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
    currentname = pbMessageFreeText(_INTL("Set the name for this point."),currentname,false,250) { pbUpdate }
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

  def refresh_fly_screen
    return if @fly_map || !pbCanFly? || !Settings::CAN_FLY_FROM_TOWN_MAP
    @sprites["help"].bitmap.clear
    pbSetSystemFont(@sprites["help"].bitmap)
    text = @mode == 0 ? _INTL("ACTION: Open Fly Menu") : _INTL("ACTION: Close Fly Menu")
    pbDrawTextPositions(@sprites["help"].bitmap, [[text, Graphics.width - 8, -8, 1, Color.new(248,248,248), Color.new(0,0,0)]])
    @sprites.each do |key, sprite|
      next if !key.include?("point")
      sprite.visible = @mode == 1
      sprite.frame   = 0
    end
  end

  def pbMapScene
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
      if Input.trigger?(Input::BACK)
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
      elsif Input.trigger?(Input::USE) && @mode == 1  # Choosing an area to fly to
        healspot = pbGetHealingSpot(@mapX,@mapY)
        if healspot &&
           ($PokemonGlobal.visitedMaps[healspot[0]] || ($DEBUG && Input.press?(Input::CTRL)))
           name = pbGetMapNameFromId(healspot[0])
          return healspot if @fly_map || pbConfirmMessage(_INTL("Would you like to fly to {1}?", name)) { pbUpdate }
        end
      elsif Input.trigger?(Input::USE) && @editor   # Intentionally after other USE input check
        pbChangeMapLocation(@mapX,@mapY)
      elsif Input.trigger?(Input::ACTION) && !@wallmap && !@fly_map && pbCanFly?
        pbPlayDecisionSE
        @mode = (@mode == 1 ? 0 : 1)
        refresh_fly_screen
      end
    end
    pbPlayCloseMenuSE
    return nil
  end
end

#===============================================================================
#
#===============================================================================
class PokemonRegionMapScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartFlyScreen
    @scene.pbStartScene(false, true)
    ret = @scene.pbMapScene
    @scene.pbEndScene
    return ret
  end

  def pbStartScreen
    @scene.pbStartScene($DEBUG)
    ret = @scene.pbMapScene
    @scene.pbEndScene
    return ret
  end
end

#===============================================================================
#
#===============================================================================
def pbShowMap(region = -1, wallmap = true)
  pbFadeOutIn {
    scene = PokemonRegionMap_Scene.new(region, wallmap)
    screen = PokemonRegionMapScreen.new(scene)
    ret = screen.pbStartScreen
    $PokemonTemp.flydata = ret if ret && !wallmap
  }
end
