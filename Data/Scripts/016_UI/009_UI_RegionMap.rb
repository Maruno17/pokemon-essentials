#===============================================================================
#
#===============================================================================
class MapBottomSprite < SpriteWrapper
  attr_reader :mapname, :maplocation

  def initialize(viewport = nil)
    super(viewport)
    @mapname     = ""
    @maplocation = ""
    @mapdetails  = ""
    @thisbitmap = BitmapWrapper.new(Graphics.width, Graphics.height)
    self.bitmap = BitmapWrapper.new(Graphics.width, Graphics.height)
    pbSetSystemFont(self.bitmap)
    refresh
  end

  def mapname=(value)
    if @mapname != value
      @mapname = value
      refresh
    end
  end

  def maplocation=(value)
    if @maplocation != value
      @maplocation = value
      refresh
    end
  end

  # From Wichu
  def mapdetails=(value)
    if @mapdetails != value
      @mapdetails = value
      refresh
    end
  end

  def refresh
    bitmap.clear
    textpos = [
      [@mapname, 18, -8, 0, Color.new(248, 248, 248), Color.new(0, 0, 0)],
      [@maplocation, 18, 348, 0, Color.new(248, 248, 248), Color.new(0, 0, 0)],
      [@mapdetails, Graphics.width - 16, 348, 1, Color.new(248, 248, 248), Color.new(0, 0, 0)]
    ]
    pbDrawTextPositions(bitmap, textpos)
  end
end

#===============================================================================
#
#===============================================================================
class PokemonRegionMap_Scene
  LEFT          = 0
  TOP           = 0
  RIGHT         = 29
  BOTTOM        = 19
  SQUARE_WIDTH  = 16
  SQUARE_HEIGHT = 16

  def initialize(region =- 1, wallmap = true)
    @region  = region
    @wallmap = wallmap
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(as_editor = false, fly_map = false)
    @editor   = as_editor
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @map_data = pbLoadTownMapData
    @fly_map = fly_map
    @mode    = fly_map ? 1 : 0
    map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
    playerpos = map_metadata ? map_metadata.town_map_position : nil
    if !playerpos
      mapindex = 0
      @map     = @map_data[0]
      @map_x    = LEFT
      @map_y    = TOP
    elsif @region >= 0 && @region != playerpos[0] && @map_data[@region]
      mapindex = @region
      @map     = @map_data[@region]
      @map_x    = LEFT
      @map_y    = TOP
    else
      mapindex = playerpos[0]
      @map     = @map_data[playerpos[0]]
      @map_x    = playerpos[1]
      @map_y    = playerpos[2]
      mapsize = map_metadata.town_map_size
      if mapsize && mapsize[0] && mapsize[0] > 0
        sqwidth  = mapsize[0]
        sqheight = (mapsize[1].length * 1.0 / mapsize[0]).ceil
        @map_x += ($game_player.x * sqwidth / $game_map.width).floor if sqwidth > 1
        @map_y += ($game_player.y * sqheight / $game_map.height).floor if sqheight > 1
      end
    end
    unless @map
      pbMessage(_INTL("The map data cannot be found."))
      return false
    end
    addBackgroundOrColoredPlane(@sprites, "background", "mapbg", Color.new(0, 0, 0), @viewport)
    @sprites["map"] = IconSprite.new(0, 0, @viewport)
    @sprites["map"].setBitmap("Graphics/Pictures/#{@map[1]}")
    @sprites["map"].x += (Graphics.width - @sprites["map"].bitmap.width) / 2
    @sprites["map"].y += (Graphics.height - @sprites["map"].bitmap.height) / 2
    Settings::REGION_MAP_EXTRAS.each do |hidden|
      next unless hidden[0] == mapindex && ((@wallmap && hidden[5]) || location_hidden?(hidden[1]))
      unless @sprites["map2"]
        @sprites["map2"] = BitmapSprite.new(480, 320, @viewport)
        @sprites["map2"].x = @sprites["map"].x
        @sprites["map2"].y = @sprites["map"].y
      end
      pbDrawImagePositions(@sprites["map2"].bitmap, [
                             ["Graphics/Pictures/#{hidden[4]}", hidden[2] * SQUARE_WIDTH, hidden[3] * SQUARE_HEIGHT]
                           ])
    end
    @sprites["mapbottom"] = MapBottomSprite.new(@viewport)
    @sprites["mapbottom"].mapname     = pbGetMessage(MessageTypes::RegionNames, mapindex)
    @sprites["mapbottom"].maplocation = pbGetMapLocation(@map_x, @map_y)
    @sprites["mapbottom"].mapdetails  = pbGetMapDetails(@map_x, @map_y)
    if playerpos && mapindex == playerpos[0]
      @sprites["player"] = IconSprite.new(0, 0, @viewport)
      @sprites["player"].setBitmap(GameData::TrainerType.player_map_icon_filename($Trainer.trainer_type))
      @sprites["player"].x = get_x_coord_on_grid(@map_x)
      @sprites["player"].y = get_y_coord_on_grid(@map_y)
    end
    k = 0
    (LEFT..RIGHT).each do |i|
      (TOP..BOTTOM).each do |j|
        healspot = pbGetHealingSpot(i, j)
        next unless healspot && $PokemonGlobal.visitedMaps[healspot[0]]
        @sprites["point#{k}"] = AnimatedSprite.create("Graphics/Pictures/mapFly", 2, 16)
        @sprites["point#{k}"].viewport = @viewport
        @sprites["point#{k}"].x        = get_x_coord_on_grid(i)
        @sprites["point#{k}"].y        = get_y_coord_on_grid(j)
        @sprites["point#{k}"].visible  = @mode == 1
        @sprites["point#{k}"].play
        k += 1
      end
    end
    @sprites["cursor"] = AnimatedSprite.create("Graphics/Pictures/mapCursor", 2, 5)
    @sprites["cursor"].viewport = @viewport
    @sprites["cursor"].x        = get_x_coord_on_grid(@map_x)
    @sprites["cursor"].y        = get_y_coord_on_grid(@map_y)
    @sprites["cursor"].play
    @sprites["help"] = BitmapSprite.new(Graphics.width, 28, @viewport)
    refresh_fly_screen
    @changed = false
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def get_x_coord_on_grid(x)
    return -SQUARE_WIDTH / 2 + (x * SQUARE_WIDTH) + (Graphics.width - @sprites["map"].bitmap.width) / 2
  end

  def get_y_coord_on_grid(y)
    return -SQUARE_HEIGHT / 2 + (y * SQUARE_HEIGHT) + (Graphics.height - @sprites["map"].bitmap.height) / 2
  end

  def location_hidden?(loc)
    return !@wallmap && loc.is_a?(Integer) && loc >0 && $game_switches[loc]
  end

  # TODO: Why is this PBS file writer here?
  def pbSaveMapData
    File.open("PBS/town_map.txt","wb") { |f|
      Compiler.add_PBS_header_to_file(f)
      for i in 0...@map_data.length
        map = @map_data[i]
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

  def pbGetMapLocation(x, y)
    return "" unless @map[2]
    maps = @map[2].select { |loc| loc[0] == x && loc[1] == y }
    return "" if maps.empty?
    maps.each do |loc|
      if !location_hidden?(loc[7])
        maploc = pbGetMessageFromHash(MessageTypes::PlaceNames, loc[2])
        return @editor ? loc[2] : maploc
      else
        return ""
      end
    end
  end

  def pbChangeMapLocation(x,y)
    return "" unless @editor && @map[2]
    map = @map[2].select { |loc| loc[0] == x && loc[1] == y }[0]
    currentobj  = map
    currentname = map[2]
    currentname = pbMessageFreeText(_INTL("Set the name for this point."), currentname, false, 250) { pbUpdate }
    if currentname
      if currentobj
        currentobj[2] = currentname
      else
        newobj = [x, y, currentname, ""]
        @map[2].push(newobj)
      end
      @changed = true
    end
  end

  def pbGetMapDetails(x,y) # From Wichu, with my help
    return "" unless @map[2]
    maps = @map[2].select { |loc| loc[0] == x && loc[1] == y }
    return "" if maps.empty?
    maps.each do |loc|
      if !location_hidden?(loc[7])
        mapdesc = pbGetMessageFromHash(MessageTypes::PlaceDescriptions,loc[3])
        return (@editor) ? loc[3] : mapdesc
      else
        return ""
      end
    end
  end

  def pbGetHealingSpot(x,y)
    return nil unless @map[2]
    maps = @map[2].select { |loc| loc[0] == x && loc[1] == y }
    return nil if maps.empty?
    maps.each do |loc|
      return ((loc[4] && loc[5] && loc[6]) ? [loc[4],loc[5],loc[6]] : nil)
    end
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
    x_offset = 0
    y_offset = 0
    new_x    = 0
    new_y    = 0
    dist_per_frame = 8 * 20 / Graphics.frame_rate
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if x_offset != 0 || y_offset != 0
        x_offset += (x_offset > 0) ? -dist_per_frame : (x_offset < 0) ? dist_per_frame : 0
        y_offset += (y_offset > 0) ? -dist_per_frame : (y_offset < 0) ? dist_per_frame : 0
        @sprites["cursor"].x = new_x - x_offset
        @sprites["cursor"].y = new_y - y_offset
        next
      end
      ox = 0
      oy = 0
      case Input.dir8
      when 1   # lower left
        oy = 1 if @map_y < BOTTOM
        ox = -1 if @map_x > LEFT
      when 2   # down
        oy = 1 if @map_y < BOTTOM
      when 3   # lower right
        oy = 1 if @map_y < BOTTOM
        ox = 1 if @map_x < RIGHT
      when 4   # left
        ox = -1 if @map_x > LEFT
      when 6   # right
        ox = 1 if @map_x < RIGHT
      when 7   # upper left
        oy = -1 if @map_y > TOP
        ox = -1 if @map_x > LEFT
      when 8   # up
        oy = -1 if @map_y > TOP
      when 9   # upper right
        oy = -1 if @map_y > TOP
        ox = 1 if @map_x < RIGHT
      end
      if ox != 0 || oy != 0
        @map_x += ox
        @map_y += oy
        x_offset = ox * SQUARE_WIDTH
        y_offset = oy * SQUARE_HEIGHT
        new_x = @sprites["cursor"].x + x_offset
        new_y = @sprites["cursor"].y + y_offset
      end
      @sprites["mapbottom"].maplocation = pbGetMapLocation(@map_x, @map_y)
      @sprites["mapbottom"].mapdetails  = pbGetMapDetails(@map_x, @map_y)
      if Input.trigger?(Input::BACK)
        if @editor && @changed
          pbSaveMapData if pbConfirmMessage(_INTL("Save changes?")) { pbUpdate }
          break if pbConfirmMessage(_INTL("Exit from the map?")) { pbUpdate }
        else
          break
        end
      elsif Input.trigger?(Input::USE) && @mode == 1 # Choosing an area to fly to
        healspot = pbGetHealingSpot(@map_x, @map_y)
        if healspot &&
           ($PokemonGlobal.visitedMaps[healspot[0]] || ($DEBUG && Input.press?(Input::CTRL)))
          name = pbGetMapNameFromId(healspot[0])
          return healspot if @fly_map || pbConfirmMessage(_INTL("Would you like to fly to {1}?", name)) { pbUpdate }
        end
      elsif Input.trigger?(Input::USE) && @editor   # Intentionally after other USE input check
        pbChangeMapLocation(@map_x, @map_y)
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
