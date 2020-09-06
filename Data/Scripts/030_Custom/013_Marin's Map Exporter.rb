#==============================================================================#
#                              Map Exporter                                    #
#                                by Marin                                      #
#==============================================================================#
# Manually export a map using `pbExportMap(id)`, or go into the Debug menu and #
#            choose the `Export a Map` option that is now in there.            #
#                                                                              #
#  `pbExportMap(id, options)`, where `options` is an array that can contain:   #
#       - :events  ->  This will also export all events present on the map     #
#       - :player  ->  This will also export the player if they're on that map #
#  `id` can be nil, which case it will use the current map the player is on.   #
#==============================================================================#
#                    Please give credit when using this.                       #
#==============================================================================#

PluginManager.register({
  :name => "Marin's Map Exporter",
  :version => "1.4",
  :credits => "Marin",
  :dependencies => "Marin's Scripting Utilities",
  :link => "https://reliccastle.com/resources/184/"
})

# This is where the map will be exported to once it has been created.
# If this file already exists, it is overwritten.
ExportedMapFilename = "Exported Map.png"



def pbExportMap(id = nil, options = [])
  MarinMapExporter.new(id, options)
end

def pbExportAMap
  vp = Viewport.new(0, 0, Graphics.width, Graphics.height)
  vp.z = 99999
  s = Sprite.new(vp)
  s.bitmap = Bitmap.new(Graphics.width, Graphics.height)
  s.bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(0,0,0))
  mapid = pbListScreen(_INTL("Export Map"),MapLister.new(pbDefaultMap))
  if mapid > 0
    player = $game_map.map_id == mapid
    if player
      cmds = ["Export", "[  ] Events", "[  ] Player", "Cancel"]
    else
      cmds = ["Export", "[  ] Events", "Cancel"]
    end
    cmd = 0
    loop do
      cmd = Kernel.pbShowCommands(nil,cmds,-1,cmd)
      if cmd == 0
        options = []
        options << :events if cmds[1].split("")[1] == "X"
        options << :player if player && cmds[2].split("")[1] == "X"
        pbExportMap(mapid, options)
        Kernel.pbMessage(_INTL("Successfully exported this map."))
        break
      elsif cmd == 1
        if cmds[1].split("")[1] == " "
          cmds[1] = "[X] Events"
        else
          cmds[1] = "[  ] Events"
        end
      elsif cmd == 2 && player
        if cmds[2].split("")[1] == " "
          cmds[2] = "[X] Player"
        else
          cmds[2] = "[  ] Player"
        end
      elsif cmd == 3 || cmd == 2 && !player || cmd == -1
        break
      end
    end
  end
  s.bitmap.dispose
  s.dispose
  vp.dispose
end

alias map_exporter_menu pbDebugMenuCommands
def pbDebugMenuCommands(showall = true)
  cmds = map_exporter_menu(showall)
  if showall
    cmds.add("fieldmenu","exportmap",_INTL("Export a Map"),
        _INTL("Choose one map to export it to a PNG."))
  end
  return cmds
end

alias map_exporter_actions pbDebugMenuActions
def pbDebugMenuActions(cmd = "", sprites = nil, viewport = nil)
  if cmd == "exportmap"
    pbExportAMap
    return true
  end
  return map_exporter_actions(cmd, sprites, viewport)
end

class MarinMapExporter
  def initialize(id = nil, options = [])
    @id = id || $game_map.map_id
    @options = options
    @data = load_data("Data/Map#{@id.to_digits}.rxdata")
    @tiles = @data.data
    @result = Bitmap.new(32 * @tiles.xsize, 32 * @tiles.ysize)
    @tilesetdata = load_data("Data/Tilesets.rxdata")
    tilesetname = @tilesetdata[@data.tileset_id].name
    @tileset = BitmapCache.load_bitmap("Graphics/Tilesets/#{tilesetname}")
    @autotiles = @tilesetdata[@data.tileset_id].autotile_names.map do |e|
      BitmapCache.load_bitmap("Graphics/Autotiles/#{e}")
    end
    for z in 0..2
      for y in 0...@tiles.ysize
        for x in 0...@tiles.xsize
          id = @tiles[x, y, z]
          next if id == 0
          if id < 384 # Autotile
            build_autotile(@result, x * 32, y * 32, id)
          else # Normal tile
            @result.blt(x * 32, y * 32, @tileset,
                Rect.new(32 * ((id - 384) % 8),32 * ((id - 384) / 8).floor,32,32))
          end
        end
      end
    end
    if @options.include?(:events)
      keys = @data.events.keys.sort { |a, b| @data.events[a].y <=> @data.events[b].y }
      keys.each do |id|
        event = @data.events[id]
        page = pbGetActiveEventPage(event, @id)
        if page && page.graphic && page.graphic.character_name
          bmp = BitmapCache.load_bitmap("Graphics/Characters/#{page.graphic.character_name}")
          if bmp
            bmp = bmp.clone
            bmp.hue_change(page.graphic.character_hue) unless page.graphic.character_hue == 0
            ex = bmp.width / 4 * page.graphic.pattern
            ey = bmp.height / 4 * (page.graphic.direction / 2 - 1)
            @result.blt(event.x * 32 + 16 - bmp.width / 8, (event.y + 1) * 32 - bmp.height / 4, bmp,
                Rect.new(ex, ey, bmp.width / 4, bmp.height / 4))
          end
          bmp = nil
        end
      end
    end
    if @options.include?(:player) && $game_map.map_id == @id
      bmp = BitmapCache.load_bitmap("Graphics/Characters/#{$game_player.character_name}")
      dir = $game_player.direction
      @result.blt($game_player.x * 32 + 16 - bmp.width / 8, ($game_player.y + 1) * 32 - bmp.height / 4,
          bmp, Rect.new(0, bmp.height / 4 * (dir / 2 - 1), bmp.width / 4, bmp.height / 4))
    end
    @result.saveToPng(ExportedMapFilename)
    Input.update
  end
  
  def build_autotile(bitmap, x, y, id)
    autotile = @autotiles[id / 48 - 1]
    return unless autotile
    if autotile.height == 32
      bitmap.blt(x,y,autotile,Rect.new(0,0,32,32))
    else
      id %= 48
      tiles = CustomTilemap::Autotiles[id >> 3][id & 7]
      src = Rect.new(0,0,0,0)
      halfTileWidth = halfTileHeight = halfTileSrcWidth = halfTileSrcHeight = 32 >> 1
      for i in 0...4
        tile_position = tiles[i] - 1
        src.set((tile_position % 6) * halfTileSrcWidth,
           (tile_position / 6) * halfTileSrcHeight, halfTileSrcWidth, halfTileSrcHeight)
        bitmap.blt(i % 2 * halfTileWidth + x, i / 2 * halfTileHeight + y,
            autotile, src)
      end
    end
  end
end