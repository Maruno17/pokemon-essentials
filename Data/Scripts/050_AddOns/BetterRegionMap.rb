#==============================================================================#
#                              Better Region Map                               #
#                       By Marin, with edits by Boonzeet                       #
#==============================================================================#
#   This region map is smoother and allows you to use region maps larger than  #
#                                   480x320.                                   #
#                                                                              #
#     This resource also comes with a new townmapgen.html to support for the   #
#                                larger images.                                #
#==============================================================================#
#  This region map now supports hidden islands (e.g. Berth or Faraday).        #
#==============================================================================#
#                    Please give credit when using this.                       #
#==============================================================================#
#
# PluginManager.register({
#                          :name => "Better Region Map",
#                          :version => "1.2",
#                          :credits => ["Marin", "Boonzeet"],
#                          :dependencies => "Marin's Scripting Utilities",
#                          :link => "https://reliccastle.com/resources/174/"
#                        })

def pbBetterRegionMap(region = -1, show_player = true, can_fly = false, wallmap = false, species = nil,fly_anywhere=false)
  scene = BetterRegionMap.new(-1, show_player, can_fly, wallmap, species,fly_anywhere)
  return scene.flydata
end

class PokemonGlobalMetadata
  attr_writer :regionMapSel
  attr_writer :region

  def regionMapSel
    @regionMapSel ||= [0, 0]
    return @regionMapSel
  end

  def region
    @region ||= 0
    return @region
  end
end

class BetterRegionMap
  CursorAnimateDelay = 12.0
  CursorMoveSpeed = 4.0
  TileWidth = 16.0
  TileHeight = 16.0

  FlyPointAnimateDelay = 20.0

  attr_reader :flydata

  def initialize(region = -1, show_player = true, can_fly = false, wallmap = false, species = nil,fly_anywhere=false)
    region = 0
    showBlk
    map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
    if map_metadata
      playerpos = $game_map ? map_metadata.town_map_position : nil#pbGetMetadata($game_map.map_id, MetadataMapPosition) : nil
    end
    if playerpos == nil
      playerpos = [0,0]
    end
    @fly_anywhere = fly_anywhere
    @region = (region < 0) ? playerpos[0] : region
    @species = species
    @show_player = (show_player && playerpos[0] == @region)
    @can_fly = can_fly
    @data = load_data("Data/town_map.dat")[@region]
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @mapdata = pbLoadTownMapData
    @mapvp = Viewport.new(16, 32, 480, 320)
    @mapvp.z = 100000
    @mapoverlayvp = Viewport.new(16,32,480,320)
    @mapoverlayvp.z = 100001
    @viewport2 = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport2.z = 100001
    @sprites = SpriteHash.new
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].bmp("Graphics/Pictures/mapbg")
    @window = SpriteHash.new
    @window["map"] = Sprite.new(@mapvp)
    @window["map"].bmp("Graphics/Pictures/#{@data[1]}")
    # for hidden in REGION_MAP_EXTRAS
    #   if hidden[0] == @region && ((wallmap && hidden[5]) || # always show if looking at wall map, irrespective of switch
    #     (!wallmap && hidden[1] > 0 && $game_switches[hidden[1]]))
    #     if !@window["map2"]
    #       @window["map2"] = BitmapSprite.new(480,320,@mapoverlayvp)
    #     end
    #     pbDrawImagePositions(@window["map2"].bitmap, [
    #       ["Graphics/Pictures/#{hidden[4]}", hidden[2] * TileWidth, hidden[3] * TileHeight, 0, 0, -1, -1],
    #     ])
    #   end
    # end
    @window["player"] = Sprite.new(@mapoverlayvp)
    if @show_player
      if map_metadata
        player = map_metadata.town_map_position

        if player && player[0] == @region
          $PokemonGlobal.regionMapSel[0] = player[1]
          $PokemonGlobal.regionMapSel[1] = player[2]
          gender = $Trainer.gender.to_digits(3)
          @window["player"].bmp("Graphics/Pictures/mapPlayer#{gender}")
          @window["player"].x = TileWidth * player[1] + (TileWidth / 2.0)
          @window["player"].y = TileHeight * player[2] + (TileHeight / 2.0)
          @window["player"].center_origins
        end
      else

      end

    end
    @window["areahighlight"] = BitmapSprite.new(@window["map"].bitmap.width,@window["map"].bitmap.height,@mapoverlayvp)
    @window["areahighlight"].y = -8
    # pokedex highlights
    if @species != nil
      @window["areahighlight"].bitmap.clear
      # Fill the array "points" with all squares of the region map in which the
      # species can be found

      mapwidth = @window["map"].bitmap.width/BetterRegionMap::TileWidth
      data = calculatePointsAndCenter(mapwidth)

      points = data[0]
      minxy = data[1]
      maxxy = data[2]

      # Draw coloured squares on each square of the region map with a nest
      pointcolor   = Color.new(0,248,248)
      pointcolorhl = Color.new(192,248,248)

      sqwidth = TileWidth.round
      sqheight = TileHeight.round

      for j in 0...points.length
        if points[j]
          x = (j % mapwidth) * sqwidth
          y = (j / mapwidth) * sqheight
          @window["areahighlight"].bitmap.fill_rect(x, y, sqwidth, sqheight, pointcolor)
          if j - mapwidth < 0 || !points[j - mapwidth]
            @window["areahighlight"].bitmap.fill_rect(x, y - 2, sqwidth, 2, pointcolorhl)
          end
          if j + mapwidth >= points.length || !points[j + mapwidth]
            @window["areahighlight"].bitmap.fill_rect(x, y + sqheight, sqwidth, 2, pointcolorhl)
          end
          if j % mapwidth == 0 || !points[j - 1]
            @window["areahighlight"].bitmap.fill_rect(x - 2, y, 2, sqheight, pointcolorhl)
          end
          if (j + 1) % mapwidth == 0 || !points[j + 1]
            @window["areahighlight"].bitmap.fill_rect(x + sqwidth, y, 2, sqheight, pointcolorhl)
          end
        end
      end
    end

    @sprites["cursor"] = Sprite.new(@viewport2)
    @sprites["cursor"].bmp("Graphics/Pictures/mapCursor")
    @sprites["cursor"].src_rect.width = @sprites["cursor"].bmp.height

    if !$PokemonGlobal.regionMapSel
      $PokemonGlobal.regionMapSel = [0,0]
    end
    if @species != nil && minxy[0] != nil && maxxy[1] != nil
      $PokemonGlobal.regionMapSel[0] = ((minxy[0] + maxxy[0]) / 2).round
      $PokemonGlobal.regionMapSel[1] = ((minxy[1] + maxxy[1]) / 2).round
    end

    @sprites["cursor"].x = 16 + TileWidth * $PokemonGlobal.regionMapSel[0]
    @sprites["cursor"].y = 32 + TileHeight * $PokemonGlobal.regionMapSel[1]

    @sprites["cursor"].z = 11

    # Center the window on the cursor
    # windowminx = -1 * (@window["map"].bmp.width - Settings::SCREEN_WIDTH)
    # windowminx = 0 if windowminx > 0
    # windowminy = -1 * (@window["map"].bmp.height - Settings::SCREEN_HEIGHT)
    # windowminy = 0 if windowminy > 0
    #
    # if @sprites["cursor"].x > (Settings::SCREEN_WIDTH / 2)
    #   @window.x = (Settings::SCREEN_WIDTH / 2 ) - @sprites["cursor"].x
    #   if (@window.x < windowminx)
    #     @window.x = windowminx
    #   end
    #   @sprites["cursor"].x += @window.x
    # end
    # if @sprites["cursor"].y > (Settings::SCREEN_HEIGHT / 2)
    #   @window.y = (Settings::SCREEN_HEIGHT / 2 ) - @sprites["cursor"].y
    #   if @window.y < windowminy
    #     @window.y = windowminy
    #   end
    #   @sprites["cursor"].y += @window.y
    # end

    @sprites["cursor"].ox = (@sprites["cursor"].bmp.height - TileWidth) / 2.0
    @sprites["cursor"].oy = @sprites["cursor"].ox
    @sprites["txt"] = TextSprite.new(@viewport)
    @sprites["arrowLeft"] = Sprite.new(@viewport2)
    @sprites["arrowLeft"].bmp("Graphics/Pictures/mapArrowRight")
    @sprites["arrowLeft"].mirror = true
    @sprites["arrowLeft"].center_origins
    @sprites["arrowLeft"].xyz = 12, Graphics.height / 2
    @sprites["arrowRight"] = Sprite.new(@viewport2)
    @sprites["arrowRight"].bmp("Graphics/Pictures/mapArrowRight")
    @sprites["arrowRight"].center_origins
    @sprites["arrowRight"].xyz = Graphics.width - 12, Graphics.height / 2
    @sprites["arrowUp"] = Sprite.new(@viewport2)
    @sprites["arrowUp"].bmp("Graphics/Pictures/mapArrowDown")
    @sprites["arrowUp"].angle = 180
    @sprites["arrowUp"].center_origins
    @sprites["arrowUp"].xyz = Graphics.width / 2, 24
    @sprites["arrowDown"] = Sprite.new(@viewport2)
    @sprites["arrowDown"].bmp("Graphics/Pictures/mapArrowDown")
    @sprites["arrowDown"].center_origins
    @sprites["arrowDown"].xyz = Graphics.width / 2, Graphics.height - 24

    update_text
    @dirs = []
    @mdirs = []
    @i = 0

    if can_fly
      @spots = {}
      n = 0
      for x in 0...(@window["map"].bmp.width / TileWidth)
        for y in 0...(@window["map"].bmp.height / TileHeight)
          healspot = pbGetHealingSpot(x, y)
          if can_fly_to_location(healspot)
            @window["point#{n}"] = Sprite.new(@mapvp)
            @window["point#{n}"].bmp("Graphics/Pictures/mapFly")
            @window["point#{n}"].src_rect.width = @window["point#{n}"].bmp.height
            @window["point#{n}"].x = TileWidth * x + (TileWidth / 2)
            @window["point#{n}"].y = TileHeight * y + (TileHeight / 2)
            @window["point#{n}"].oy = @window["point#{n}"].bmp.height / 2.0
            @window["point#{n}"].ox = @window["point#{n}"].oy
            @spots[[x, y]] = healspot
            n += 1
          end
        end
      end
    end

    hideBlk { update(false) }
    main
  end

  def can_fly_to_location(healspot)
    return true if healspot && @fly_anywhere
    return healspot && $PokemonGlobal.visitedMaps[healspot[0]]
  end

  def pbGetHealingSpot(x, y)
    return nil if !@data[2]
    for loc in @data[2]
      if loc[0] == x && loc[1] == y
        if !loc[4] || !loc[5] || !loc[6]
          return nil
        else
          return [loc[4], loc[5], loc[6]]
        end
      end
    end
    return nil
  end

  def main
    loop do
      update
      if Input.press?(Input::RIGHT) && ![4, 6].any? { |e| @dirs.include?(e) || @mdirs.include?(e) }
        if @sprites["cursor"].x < 480
          $PokemonGlobal.regionMapSel[0] += 1
          @sx = @sprites["cursor"].x
          @dirs << 6
        elsif @window.x > -1 * (@window["map"].bmp.width - 480)
          $PokemonGlobal.regionMapSel[0] += 1
          @mx = @window.x
          @mdirs << 6
        end
      end
      if Input.press?(Input::LEFT) && ![4, 6].any? { |e| @dirs.include?(e) || @mdirs.include?(e) }
        if @sprites["cursor"].x > 16
          $PokemonGlobal.regionMapSel[0] -= 1
          @sx = @sprites["cursor"].x
          @dirs << 4
        elsif @window.x < 0
          $PokemonGlobal.regionMapSel[0] -= 1
          @mx = @window.x
          @mdirs << 4
        end
      end
      if Input.press?(Input::DOWN) && ![2, 8].any? { |e| @dirs.include?(e) || @mdirs.include?(e) }
        if @sprites["cursor"].y <= 320
          $PokemonGlobal.regionMapSel[1] += 1
          @sy = @sprites["cursor"].y
          @dirs << 2
        elsif @window.y > -1 * (@window["map"].bmp.height - 320)
          $PokemonGlobal.regionMapSel[1] += 1
          @my = @window.y
          @mdirs << 2
        end
      end
      if Input.press?(Input::UP) && ![2, 8].any? { |e| @dirs.include?(e) || @mdirs.include?(e) }
        if @sprites["cursor"].y > 32
          $PokemonGlobal.regionMapSel[1] -= 1
          @sy = @sprites["cursor"].y
          @dirs << 8
        elsif @window.y < 0
          $PokemonGlobal.regionMapSel[1] -= 1
          @my = @window.y
          @mdirs << 8
        end
      end
      if Input.trigger?(Input::C)
        x, y = $PokemonGlobal.regionMapSel
        if @spots && @spots[[x, y]]
          @flydata = @spots[[x, y]]
          break
        end
      end
      break if Input.trigger?(Input::B)
    end
    dispose
  end

  def update(update_gfx = true)
    @sprites["arrowLeft"].visible = @window.x < 0
    @sprites["arrowRight"].visible = @window.x > -1 * (@window["map"].bmp.width - 480)
    @sprites["arrowUp"].visible = @window.y < 0
    @sprites["arrowDown"].visible = @window.y > -1 * (@window["map"].bmp.height - 320)

    if update_gfx
      Graphics.update
      Input.update
    end

    intensity = (Graphics.frame_count % 40) * 12
    intensity = 480 - intensity if intensity > 240
    @window["areahighlight"].opacity = intensity

    @i += 1
    if @i % CursorAnimateDelay == 0
      @sprites["cursor"].src_rect.x += @sprites["cursor"].src_rect.width
      @sprites["cursor"].src_rect.x = 0 if @sprites["cursor"].src_rect.x >= @sprites["cursor"].bmp.width
    end
    if @i % FlyPointAnimateDelay == 0
      @window.keys.each do |e|
        next unless e.to_s.start_with?("point")
        @window[e].src_rect.x += @window[e].src_rect.width
        @window[e].src_rect.x = 0 if @window[e].src_rect.x >= @window[e].bmp.width
      end
    end

    if @i % 2 == 0
      case @i % 32
      when 0...8
        @sprites["arrowLeft"].x -= 1
        @sprites["arrowRight"].x += 1
        @sprites["arrowUp"].y -= 1
        @sprites["arrowDown"].y += 1
      when 8...24
        @sprites["arrowLeft"].x += 1
        @sprites["arrowRight"].x -= 1
        @sprites["arrowUp"].y += 1
        @sprites["arrowDown"].y -= 1
      when 24...32
        @sprites["arrowLeft"].x -= 1
        @sprites["arrowRight"].x += 1
        @sprites["arrowUp"].y -= 1
        @sprites["arrowDown"].y += 1
      end
    end

    # Cursor movement
    if @dirs.include?(6)
      @hor_count ||= 0
      @hor_count += 1
      update_text if @hor_count == (CursorMoveSpeed / 2.0).round
      @sprites["cursor"].x = @sx + (TileWidth / CursorMoveSpeed.to_f) * @hor_count
      if @hor_count == CursorMoveSpeed
        @dirs.delete(6)
        @hor_count = nil
        @sx = nil
      end
    end
    if @dirs.include?(4)
      @hor_count ||= 0
      @hor_count += 1
      update_text if @hor_count == (CursorMoveSpeed / 2.0).round
      @sprites["cursor"].x = @sx - (TileWidth / CursorMoveSpeed.to_f) * @hor_count
      if @hor_count == CursorMoveSpeed
        @dirs.delete(4)
        @hor_count = nil
        @sx = nil
      end
    end
    if @dirs.include?(8)
      @ver_count ||= 0
      @ver_count += 1
      update_text if @ver_count == (CursorMoveSpeed / 2.0).round
      @sprites["cursor"].y = @sy - (TileHeight / CursorMoveSpeed.to_f) * @ver_count
      if @ver_count == CursorMoveSpeed
        @dirs.delete(8)
        @ver_count = nil
        @sy = nil
      end
    end
    if @dirs.include?(2)
      @ver_count ||= 0
      @ver_count += 1
      update_text if @ver_count == (CursorMoveSpeed / 2.0).round
      @sprites["cursor"].y = @sy + (TileHeight / CursorMoveSpeed.to_f) * @ver_count
      if @ver_count == CursorMoveSpeed
        @dirs.delete(2)
        @ver_count = nil
        @sy = nil
      end
    end

    # Map movement
    if @mdirs.include?(6)
      @hor_count ||= 0
      @hor_count += 1
      update_text if @hor_count == (CursorMoveSpeed / 2.0).round
      @window.x = @mx - (TileWidth / CursorMoveSpeed.to_f) * @hor_count
      if @hor_count == CursorMoveSpeed
        @mdirs.delete(6)
        @hor_count = nil
        @mx = nil
      end
    end
    if @mdirs.include?(4)
      @hor_count ||= 0
      @hor_count += 1
      update_text if @hor_count == (CursorMoveSpeed / 2.0).round
      @window.x = @mx + (TileWidth / CursorMoveSpeed.to_f) * @hor_count
      if @hor_count == CursorMoveSpeed
        @mdirs.delete(4)
        @hor_count = nil
        @mx = nil
      end
    end
    if @mdirs.include?(8)
      @ver_count ||= 0
      @ver_count += 1
      update_text if @ver_count == (CursorMoveSpeed / 2.0).round
      @window.y = @my + (TileHeight / CursorMoveSpeed.to_f) * @ver_count
      if @ver_count == CursorMoveSpeed
        @mdirs.delete(8)
        @ver_count = nil
        @my = nil
      end
    end
    if @mdirs.include?(2)
      @ver_count ||= 0
      @ver_count += 1
      update_text if @ver_count == (CursorMoveSpeed / 2.0).round
      @window.y = @my - (TileHeight / CursorMoveSpeed.to_f) * @ver_count
      if @ver_count == CursorMoveSpeed
        @mdirs.delete(2)
        @ver_count = nil
        @my = nil
      end
    end
  end

  def update_text
    location = @data[2].find do |e|
      e[0] == $PokemonGlobal.regionMapSel[0] &&
        e[1] == $PokemonGlobal.regionMapSel[1]
    end
    text = ""
    text = location[2] if location
    poi = ""
    poi = location[3] if location && location[3]
    @sprites["txt"].draw([
                           [pbGetMessage(MessageTypes::RegionNames, @region), 16, 0, 0,
                            Color.new(255, 255, 255), Color.new(0, 0, 0)],
                           [text, 16, 354, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
                           [poi, 496, 354, 1, Color.new(255, 255, 255), Color.new(0, 0, 0)],
                         ], true)
  end

  def dispose
    showBlk { update(false) }
    @sprites.dispose
    @window.dispose
    @viewport.dispose
    @viewport2.dispose
    @mapvp.dispose
    hideBlk
    Input.update
  end
end

#==============================================================================#
# Overwrites some old methods to use the new region map                        #
#==============================================================================#

ItemHandlers::UseInField.add(:TOWNMAP, proc { |item|
  pbBetterRegionMap
  next 1
})

def pbShowMap(region = -1, wallmap = true) # pokegear
pbBetterRegionMap(region, true, false, wallmap)
end


def calculatePointsAndCenter(mapwidth)
  # Fill the array "points" with all squares of the region map in which the
  # species can be found
  points = []

  encdata = pbLoadEncountersData

  minxy = [nil, nil] # top-leftmost tile
  maxxy = [nil, nil] # bottom-rightmost tile

  for enc in encdata.keys
    enctypes = encdata[enc][1]
    if pbFindEncounter(enctypes, @species)
      mappos = GameData::MapMetadata.get(enc).town_map_position

      if mappos && mappos[0] == @region
        showpoint = true
        for loc in @mapdata[@region][2]
          showpoint = false if loc[0] == mappos[1] && loc[1] == mappos[2] &&
            loc[7] && !$game_switches[loc[7]]
        end
        if showpoint
          #mapsize = pbGetMetadata(enc, MetadataMapSize)
          mapsize = GameData::MapMetadata.get(enc).town_map_size

          if mapsize && mapsize[0] && mapsize[0] > 0
            sqwidth  = mapsize[0]
            sqheight = (mapsize[1].length * 1.0 / mapsize[0]).ceil
            for i in 0...sqwidth
              for j in 0...sqheight
                if mapsize[1][i + j * sqwidth, 1].to_i > 0
                  # work out the upper-leftmost and lower-rightmost tiles
                  minxy[0] = (minxy[0] == nil || minxy[0] > mappos[1]+i) ? mappos[1]+i : minxy[0]
                  minxy[1] = (minxy[1] == nil || minxy[1] > mappos[2]+j) ? mappos[2]+j : minxy[1]
                  maxxy[0] = (maxxy[0] == nil || maxxy[0] < mappos[1]+i) ? mappos[1]+i : maxxy[0]
                  maxxy[1] = (maxxy[1] == nil || maxxy[1] < mappos[2]+j) ? mappos[2]+j : maxxy[1]
                  points[mappos[1] + i + (mappos[2] + j) * mapwidth] = true
                end
              end
            end
          else
            # work out the upper-leftmost and lower-rightmost tiles
            minxy[0] = (minxy[0] == nil || minxy[0] > mappos[1]) ? mappos[1] : minxy[0]
            minxy[1] = minxy[1] == nil || minxy[1] > mappos[2] ? mappos[2] : minxy[1]
            maxxy[0] = (maxxy[0] == nil || maxxy[0] < mappos[1]) ? mappos[1] : maxxy[0]
            maxxy[1] = (maxxy[1] == nil || maxxy[1] < mappos[2]) ? mappos[2] : maxxy[1]
            points[mappos[1] + mappos[2] * mapwidth] = true
          end
        end
      end
    end
  end
  return [points, minxy, maxxy]
end

class PokemonReadyMenu
  def pbStartReadyMenu(moves,items)
    commands = [[],[]]   # Moves, items
    for i in moves
      commands[0].push([i[0], GameData::Move.get(i[0]).name, true, i[1]])
    end
    commands[0].sort! { |a,b| a[1]<=>b[1] }
    for i in items
      commands[1].push([i, GameData::Item.get(i).name, false])
    end
    commands[1].sort! { |a,b| a[1]<=>b[1] }
    @scene.pbStartScene(commands)
    loop do
      command = @scene.pbShowCommands
      break if command==-1
      if command[0]==0   # Use a move
        move = commands[0][command[1]][0]
        user = $Trainer.party[commands[0][command[1]][3]]
        if move == :FLY || move == :TELEPORT
          ###############################################
          pbHideMenu
          ret = pbBetterRegionMap(-1, true, true)
          pbShowMenu unless ret
          ###############################################
          if ret
            $PokemonTemp.flydata = ret
            $game_temp.in_menu = false
            Kernel.pbUseHiddenMove(user, move)
            break
          end
        else
          pbHideMenu
          if pbConfirmUseHiddenMove(user,move)
            $game_temp.in_menu = false
            pbUseHiddenMove(user,move)
            break
          else
            pbShowMenu
          end
        end
      else   # Use an item
      item = commands[1][command[1]][0]
      pbHideMenu
      if ItemHandlers.triggerConfirmUseInField(item)
        $game_temp.in_menu = false
        break if pbUseKeyItemInField(item)
        $game_temp.in_menu = true
      end
      end
      pbShowMenu
    end
    @scene.pbEndScene
  end
end

#
# class PokemonPokedexInfo_Scene
#   def drawPageArea
#     @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/bg_area"))
#     overlay = @sprites["overlay"].bitmap
#     base   = Color.new(88,88,80)
#     shadow = Color.new(168,184,184)
#     @sprites["areahighlight"].bitmap.clear
#
#     mapwidth = @sprites["areamap"].bitmap.width/BetterRegionMap::TileWidth
#     data = calculatePointsAndCenter(mapwidth)
#
#     points = data[0]
#     minxy = data[1]
#     maxxy = data[2]
#
#     # Draw coloured squares on each square of the region map with a nest
#     pointcolor   = Color.new(0,248,248)
#     pointcolorhl = Color.new(192,248,248)
#     sqwidth = PokemonRegionMap_Scene::SQUAREWIDTH
#     sqheight = PokemonRegionMap_Scene::SQUAREHEIGHT
#
#
#     # Center the window on the center of visible areas
#     if minxy[0] != nil && maxxy[0] != nil
#       center_x = ((minxy[0]+maxxy[0])/2).round * sqwidth
#       center_y = ((minxy[1]+maxxy[1])/2).round * sqheight - 40
#     else
#       center_x = Settings::SCREEN_WIDTH/2
#       center_y = Settings::SCREEN_HEIGHT/2 - 40
#     end
#
#     windowminx = -1 * (@sprites["areamap"].bmp.width - Settings::SCREEN_WIDTH + 16)
#     windowminy = -1 * (@sprites["areamap"].bmp.height - Settings::SCREEN_HEIGHT + 16)
#
#     if center_x > (Settings::SCREEN_WIDTH / 2)
#       @sprites["areamap"].x = (480 / 2 ) - center_x
#       if (@sprites["areamap"].x < windowminx)
#         @sprites["areamap"].x = windowminx
#       end
#     else
#       @sprites["areamap"].x = windowminx
#     end
#     if center_y > (Settings::SCREEN_HEIGHT / 2)
#       @sprites["areamap"].y = (320 / 2 ) - center_y
#       if @sprites["areamap"].y < windowminy
#         @sprites["areamap"].y = windowminy
#       end
#     else
#       @sprites["areamap"].y = windowminy
#     end
#
#     for j in 0...points.length
#       if points[j]
#         x = (j%mapwidth)*sqwidth
#         x += @sprites["areamap"].x
#         y = (j/mapwidth)*sqheight
#         y += @sprites["areamap"].y - 8
#         @sprites["areahighlight"].bitmap.fill_rect(x,y,sqwidth,sqheight,pointcolor)
#         if j-mapwidth<0 || !points[j-mapwidth]
#           @sprites["areahighlight"].bitmap.fill_rect(x,y-2,sqwidth,2,pointcolorhl)
#         end
#         if j+mapwidth>=points.length || !points[j+mapwidth]
#           @sprites["areahighlight"].bitmap.fill_rect(x,y+sqheight,sqwidth,2,pointcolorhl)
#         end
#         if j%mapwidth==0 || !points[j-1]
#           @sprites["areahighlight"].bitmap.fill_rect(x-2,y,2,sqheight,pointcolorhl)
#         end
#         if (j+1)%mapwidth==0 || !points[j+1]
#           @sprites["areahighlight"].bitmap.fill_rect(x+sqwidth,y,2,sqheight,pointcolorhl)
#         end
#       end
#     end
#
#     # Set the text
#     textpos = []
#     if points.length==0
#       pbDrawImagePositions(overlay,[
#         [sprintf("Graphics/Pictures/Pokedex/overlay_areanone"),108,188]
#       ])
#       textpos.push([_INTL("Area unknown"),Graphics.width/2,Graphics.height/2,2,base,shadow])
#     end
#     textpos.push([pbGetMessage(MessageTypes::RegionNames,@region),414,44,2,base,shadow])
#     textpos.push([_INTL("{1}'s area",PBSpecies.getName(@species)),
#                   Graphics.width/2,352,2,base,shadow])
#
#     textpos.push([_INTL("Full view"),Graphics.width/2,306,2,base,shadow])
#     pbDrawTextPositions(overlay,textpos)
#   end
# end
#
# class PokemonPokedexInfo_Scene
#   def pbScene
#     pbPlayCrySpecies(@species,@form)
#     loop do
#       Graphics.update
#       Input.update
#       pbUpdate
#       dorefresh = false
#       if Input.trigger?(Input::A)
#         pbSEStop
#         pbPlayCrySpecies(@species,@form) if @page==1
#       elsif Input.trigger?(Input::B)
#         pbPlayCloseMenuSE
#         break
#       elsif Input.trigger?(Input::C)
#         if @page==2   # Area
#           pbBetterRegionMap(@region,false,false,false,@species)
#         elsif @page==3   # Forms
#           if @available.length>1
#             pbPlayDecisionSE
#             pbChooseForm
#             dorefresh = true
#           end
#         end
#       elsif Input.trigger?(Input::UP)
#         oldindex = @index
#         pbGoToPrevious
#         if @index!=oldindex
#           pbUpdateDummyPokemon
#           @available = pbGetAvailableForms
#           pbSEStop
#           (@page==1) ? pbPlayCrySpecies(@species,@form) : pbPlayCursorSE
#           dorefresh = true
#         end
#       elsif Input.trigger?(Input::DOWN)
#         oldindex = @index
#         pbGoToNext
#         if @index!=oldindex
#           pbUpdateDummyPokemon
#           @available = pbGetAvailableForms
#           pbSEStop
#           (@page==1) ? pbPlayCrySpecies(@species,@form) : pbPlayCursorSE
#           dorefresh = true
#         end
#       elsif Input.trigger?(Input::LEFT)
#         oldpage = @page
#         @page -= 1
#         @page = 1 if @page<1
#         @page = 3 if @page>3
#         if @page!=oldpage
#           pbPlayCursorSE
#           dorefresh = true
#         end
#       elsif Input.trigger?(Input::RIGHT)
#         oldpage = @page
#         @page += 1
#         @page = 1 if @page<1
#         @page = 3 if @page>3
#         if @page!=oldpage
#           pbPlayCursorSE
#           dorefresh = true
#         end
#       end
#       if dorefresh
#         drawPage(@page)
#       end
#     end
#     return @index
#   end
# end