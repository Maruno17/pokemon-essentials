
EXPORT_EXCEPT_MAP_IDS= [768,722,723,724,720]

def exportAllMaps
  for id in 768..784
    begin
      MapExporter.export(id, [:Events]) if !EXPORT_EXCEPT_MAP_IDS.include?(id)
    rescue
      echo "error in " +(id.to_s) +"\n"
    end
  end
end


module MapExporter
  @@map = nil
  @@bitmap = nil
  @@helper = nil

  module_function

  def export(map_id, options)
    map_name = pbGetMapNameFromId(map_id)
    begin
      @@map = $MapFactory.getMapForExport(map_id)
    rescue
      error("Map #{map_id} (#{map_name}) could not be loaded.")
    end
    @@bitmap = Bitmap.new(@@map.width * Game_Map::TILE_HEIGHT, @@map.height * Game_Map::TILE_WIDTH)
    @@helper = TileDrawingHelper.fromTileset($data_tilesets[@@map.tileset_id])
    set_map_options(options)
    if options.include?(:Panorama)
      if !nil_or_empty?(@@map.panorama_name)
        draw_panorama
      else
        echoln "Map #{map_id} (#{map_name}) doesn't have a Panorama."
      end
    end
    draw_reflective_tiles
    draw_all_reflections(options)
    draw_regular_tiles
    if !draw_all_events(options)
      draw_low_priority_tiles
    end
    draw_high_priority_tiles
    draw_all_top_events(options)
    if options.include?(:Fog)
      if nil_or_empty?(@@map.fog_name)
        echoln "Map #{map_id} (#{map_name}) doesn't have a Fog."
      else
        draw_fog
      end
    end
    draw_watermark(options)
    save_map_image
  end

  def draw_all_events(options)
    include_player = options.include?(:Player) && $game_map.map_id == @@map.map_id
    include_dep = options.include?(:DependentEvents) && $game_map.map_id == @@map.map_id
    include_event = true#options.include?(:Events)
    return false if !(include_player || include_dep || include_event)
    for y in 0...@@map.height
      for x in 0...@@map.width
        event = nil
        if include_event
          event_hash = @@map.events.select {|_,e| e.x == x && e.y == y && !e.always_on_top }
          event = event_hash.values.first if !event_hash.empty?
        end
        event = $game_player if !event && include_player && $game_player.x == x && $game_player.y == y && !$game_player.always_on_top
        if include_dep
          $PokemonTemp.dependentEvents.realEvents.each do |e|
            next if !e || e.x != x || e.y != y
            event = e
            break
          end
        end
        if event
          deep_bush = @@map.bush?(x, y)
          draw_event_bitmap(event, deep_bush)
        end
        for z in 0..2
          tile_id = @@map.data[x, y, z] || 0
          priority = @@map.priorities[tile_id]
          next if priority == nil
          next if priority != 1
          tag_data = GameData::TerrainTag.try_get(@@map.terrain_tags[tile_id])
          next if !tag_data || tag_data.shows_reflections
          @@helper.bltTile(@@bitmap, x * Game_Map::TILE_WIDTH, y * Game_Map::TILE_HEIGHT, tile_id)
        end
      end
    end
    return true
  end

  def draw_all_top_events(options)
    include_player = options.include?(:Player) && $game_map.map_id == @@map.map_id
    include_event = options.include?(:Events)
    return false if !(include_player || include_event)
    for y in 0...@@map.height
      for x in 0...@@map.width
        event = nil
        if include_event
          event_hash = @@map.events.select {|_,e| e.x == x && e.y == y && e.always_on_top }
          event = event_hash.values.first if !event_hash.empty?
        end
        event = $game_player if !event && include_player && $game_player.x == x && $game_player.y == y && $game_player.always_on_top
        if event
          deep_bush = @@map.bush?(x, y)
          draw_event_bitmap(event, deep_bush)
        end
      end
    end
    return true
  end

  def draw_all_reflections(options)
    include_player = options.include?(:Player) && $game_map.map_id == @@map.map_id
    include_dep = options.include?(:DependentEvents) && $game_map.map_id == @@map.map_id
    include_event = options.include?(:Events)
    return false if !(include_player || include_dep || include_event)
    for y in 0...@@map.height
      for x in 0...@@map.width
        dep = false
        event = nil
        if include_event
          event_hash = @@map.events.select {|_,e| e.x == x && e.y == y }
          event = event_hash.values.first if !event_hash.empty?
        end
        event = $game_player if !event && include_player && $game_player.x == x && $game_player.y == y
        if include_dep && !event
          $PokemonTemp.dependentEvents.realEvents.each do |e|
            next if !e || e.x != x || e.y != y
            event = e
            dep = true
            break
          end
        end
        draw_event_reflection(event, dep) if event
      end
    end
    return true
  end

  def draw_reflective_tiles
    for y in 0...@@map.height
      for x in 0...@@map.width
        for z in 0..2
          tile_id = @@map.data[x, y, z] || 0
          tag_data = GameData::TerrainTag.try_get(@@map.terrain_tags[tile_id])
          next if !tag_data || !tag_data.shows_reflections
          @@helper.bltTile(@@bitmap, x * Game_Map::TILE_WIDTH, y * Game_Map::TILE_HEIGHT, tile_id)
        end
      end
    end
  end

  def draw_regular_tiles
    for y in 0...@@map.height
      for x in 0...@@map.width
        for z in 0..2
          tile_id = @@map.data[x, y, z] || 0
          priority = @@map.priorities[tile_id]
          next if priority == nil
          next if priority >= 1
          tag_data = GameData::TerrainTag.try_get(@@map.terrain_tags[tile_id])
          next if !tag_data || tag_data.shows_reflections
          @@helper.bltTile(@@bitmap, x * Game_Map::TILE_WIDTH, y * Game_Map::TILE_HEIGHT, tile_id)
        end
      end
    end
  end

  def draw_low_priority_tiles
    for y in 0...@@map.height
      for x in 0...@@map.width
        for z in 0..2
          tile_id = @@map.data[x, y, z] || 0
          priority = @@map.priorities[tile_id]
          next unless priority == 1
          tag_data = GameData::TerrainTag.try_get(@@map.terrain_tags[tile_id])
          next if !tag_data || tag_data.shows_reflections
          @@helper.bltTile(@@bitmap, x * Game_Map::TILE_WIDTH, y * Game_Map::TILE_HEIGHT, tile_id)
        end
      end
    end
  end

  def draw_high_priority_tiles
    for y in 0...@@map.height
      for x in 0...@@map.width
        for z in 0..2
          tile_id = @@map.data[x, y, z] || 0
          priority = @@map.priorities[tile_id]
          next if priority == nil
          next if priority < 2
          tag_data = GameData::TerrainTag.try_get(@@map.terrain_tags[tile_id])
          next if !tag_data || tag_data.shows_reflections
          @@helper.bltTile(@@bitmap, x * Game_Map::TILE_WIDTH, y * Game_Map::TILE_HEIGHT, tile_id)
        end
      end
    end
  end

  def draw_event_bitmap(event, deep_bush)
    hued = false
    tile_bmp = false
    if event.tile_id >= 384
      bmp = pbGetTileBitmap(@@map.tileset_name, event.tile_id, event.character_hue, event.width, event.height)
      hued = true
      tile_bmp = true
    elsif deep_bush
      event.calculate_bush_depth
      temp_bmp = AnimatedBitmap.new("Graphics/Characters/" + "#{event.character_name}", event.character_hue)
      bushmap = BushBitmap.new(temp_bmp, false, event.bush_depth)
      bmp = bushmap.bitmap.clone
      bushmap.dispose
      temp_bmp.dispose
      hued = true
    else
      bmp = RPG::Cache.load_bitmap("Graphics/Characters/", "#{event.character_name}") rescue Bitmap.new(32,32)
    end
    if bmp
      bmp = bmp.clone
      bmp.hue_change(event.character_hue) if event.character_hue != 0 && !hued
      final_x = (event.x * Game_Map::TILE_WIDTH) + ((event.width * Game_Map::TILE_WIDTH)/2) - bmp.width / 8
      final_y = (event.y + 1) * Game_Map::TILE_HEIGHT - bmp.height / 4 + (event.bob_height)
      final_y += 16 if event.character_name[/offset/i]
      draw_event_shadow(event) if defined?(OWShadowSettings)
      draw_surf_base(event) if event == $game_player
      if !tile_bmp
        ex = (bmp.width/4) * event.pattern
        ey = (bmp.height/4) * (event.direction/2 - 1)
        rect = Rect.new(ex, ey, bmp.width / 4, bmp.height / 4)
      else
        final_x +=  (bmp.width/8 - ((event.width * Game_Map::TILE_WIDTH)/2))
        final_y += (bmp.height/4) - (Game_Map::TILE_HEIGHT * event.height)
        rect = Rect.new(0, 0, bmp.width, bmp.height)
      end
      @@bitmap.blt(final_x, final_y, bmp, rect, event.opacity)
      bmp.dispose
    end
    bmp = nil
  end

  def draw_event_shadow(event)
    if OWShadowSettings::CASE_SENSITIVE_BLACKLISTS
      remove = true if OWShadowSettings::SHADOWLESS_CHARACTER_NAME.any?{|e| event.character_name[/#{e}/]}
      remove = true if event != $game_player && OWShadowSettings::SHADOWLESS_EVENT_NAME.any? {|e| event.name[/#{e}/]}
    else
      remove = true if OWShadowSettings::SHADOWLESS_CHARACTER_NAME.any?{|e| event.character_name[/#{e}/i]}
      remove = true if event != $game_player && OWShadowSettings::SHADOWLESS_EVENT_NAME.any? {|e| event.name[/#{e}/i]}
    end
    terrain = @@map.terrain_tag(event.x, event.y)
    remove = true if OWShadowSettings::SHADOWLESS_TERRAIN_NAME.any? {|e| terrain == e} if terrain
    if !(nil_or_empty?(event.character_name) || event.transparent || remove)
      if event == $game_player
        shadow_name = OWShadowSettings::PLAYER_SHADOW_FILENAME
      else
        shadow_name = $~[1] if event.name[/shdw\((.*?)\)/]
      end
      shadow_name = OWShadowSettings::DEFAULT_SHADOW_FILENAME if nil_or_empty?(shadow_name)
      shadow_bmp = RPG::Cache.load_bitmap("Graphics/Characters/Shadows/", "#{shadow_name}")
      shadow_x =  (event.x * Game_Map::TILE_WIDTH) + ((event.width * Game_Map::TILE_WIDTH)/2) - shadow_bmp.width/2
      shadow_y = (event.y + 1) * Game_Map::TILE_HEIGHT - shadow_bmp.height + 2
      @@bitmap.blt(shadow_x, shadow_y, shadow_bmp, Rect.new(0, 0, shadow_bmp.width, shadow_bmp.height), event.opacity)
      shadow_bmp.dispose
    end
  end

  def draw_event_reflection(event, forced = true)
    tile_bmp = false
    if event.tile_id >= 384
      bmp = pbGetTileBitmap(@@map.tileset_name, event.tile_id, event.character_hue, event.width, event.height)
      tile_bmp = true
    else
      bmp = RPG::Cache.load_bitmap("Graphics/Characters/", "#{event.character_name}") rescue Bitmap.new(32,32)
    end
    if bmp
      bmp = bmp.clone
      bmp.hue_change(event.character_hue) if event.character_hue != 0 && !tile_bmp
      height = nil
      fixed = false
      if event == $game_player || forced
        height = $PokemonGlobal.bridge
      elsif event.name[/reflection/i]
        height = 0
        if event.name[/reflection\((\d+)\)/i]
          height = $~[1].to_i || 0
        else
          height = $PokemonGlobal.bridge
        end
      end
      if height
        final_x = (event.x * Game_Map::TILE_WIDTH) + ((event.width * Game_Map::TILE_WIDTH)/2) - bmp.width/8
        final_y = (event.y + 1) * Game_Map::TILE_HEIGHT - 3 - (event.bob_height)
        final_y -= 32 if event.character_name[/offset/i]
        if !tile_bmp
          ex = (bmp.width/4) * event.pattern
          ey = (bmp.height/4) * (event.direction/2 - 1)
          rect = Rect.new(ex, ey, bmp.width/4, bmp.height/4)
        else
          final_x += (bmp.width/8 - ((event.width * Game_Map::TILE_WIDTH)/2))
          rect = Rect.new(0, 0, bmp.width, bmp.height)
        end
        if height > 0
          new_bmp = colorize_and_flip_bitmap(bmp, Color.new(48,96,160), 255, rect)
          opacity = event.opacity
        else
          new_bmp = colorize_and_flip_bitmap(bmp, Color.new(224,224,224), 96, rect)
          opacity = event.opacity*3/4
        end
        offset =  [1.0, 0.95, 1.0, 1.05][(Graphics.frame_count%40)/10]
        @@bitmap.stretch_blt(Rect.new(final_x, final_y, (new_bmp.width * offset), new_bmp.height), new_bmp, Rect.new(0, 0, new_bmp.width, new_bmp.height), opacity)
        new_bmp.dispose
      end
      bmp.dispose
    end
    bmp = nil
  end

  def draw_surf_base(event)
    return if !$PokemonGlobal.surfing && !$PokemonGlobal.diving
    bmp = nil
    if $PokemonGlobal.surfing
      bmp = RPG::Cache.load_bitmap("Graphics/Characters/", "base_surf") rescue Bitmap.new(32,32)
    elsif $PokemonGlobal.diving
      bmp = RPG::Cache.load_bitmap("Graphics/Characters/", "base_dive") rescue Bitmap.new(32,32)
    end
    return if !bmp
    sx = event.pattern_surf * bmp.width/4
    sy = ((event.direction - 2)/2) * bmp.height/4
    final_x = (event.x * Game_Map::TILE_WIDTH) + ((event.width * Game_Map::TILE_WIDTH)/2) - bmp.width/8
    final_y = (event.y + 1) * Game_Map::TILE_HEIGHT - bmp.height / 4 + 16 + (event.bob_height)
    @@bitmap.blt(final_x, final_y, bmp, Rect.new(sx,sy, bmp.width/4, bmp.height/4), event.opacity)
  end

  def draw_fog
    fog_bmp = create_tiled_bitmap("Graphics/Fogs/#{@@map.fog_name}", @@map.fog_hue, @@map.fog_zoom/100.0)
    @@bitmap.blt(0, 0, fog_bmp, Rect.new(0, 0, fog_bmp.width, fog_bmp.height), @@map.fog_opacity)
    fog_bmp.dispose
  end

  def draw_panorama
    pan_bmp = create_tiled_bitmap("Graphics/Panoramas/#{@@map.panorama_name}", @@map.panorama_hue)
    @@bitmap.blt(0, 0, pan_bmp, Rect.new(0, 0, pan_bmp.width, pan_bmp.height))
    pan_bmp.dispose
  end

  def draw_watermark(options)
    return if !options.include?(:GameName) && !options.include?(:MapName)
    map_name  = nil_or_empty?(@@map.name)? pbGetMapNameFromId(@@map.map_id) : @@map.name
    game_name = System.game_title
    base_color = Color.new(248, 248, 248)
    shadow_color = Color.new(64, 64, 64)
    new_bmp = Bitmap.new(@@bitmap.width, @@bitmap.height)
    if options.include?(:GameName)
      if options.include?(:MapName)
        pbSetSmallFont(new_bmp)
      else
        pbSetSystemFont(new_bmp)
      end
      pbDrawTextPositions(new_bmp, [[game_name, new_bmp.width - 8, new_bmp.height - 32, 1, base_color, shadow_color, true]])
      new_font = (@@bitmap.text_size(map_name).height + 6)
    else
      new_font = 0
    end
    if options.include?(:MapName)
      pbSetSystemFont(new_bmp)
      pbDrawTextPositions(new_bmp, [[map_name, new_bmp.width - 8, new_bmp.height - new_font - 38, 1, base_color, shadow_color, true]])
    end
    scale_factor = get_name_scale
    x = @@bitmap.width - (new_bmp.width * scale_factor) - (8 * (scale_factor - 1))
    y = @@bitmap.height - (new_bmp.height * scale_factor) - (8 * (scale_factor - 1))
    rect = Rect.new(x, y, (new_bmp.width * scale_factor), (new_bmp.height * scale_factor))
    @@bitmap.stretch_blt(rect, new_bmp, Rect.new(0, 0, new_bmp.width, new_bmp.height))
    new_bmp.dispose
  end

  def save_map_image
    Dir.mkdir("Exported Maps/") if !safeExists?("Exported Maps/")
    filestart = Time.now.strftime("[%Y-%m-%d %H-%M]")
    map_name  = nil_or_empty?(@@map.name)? pbGetMapNameFromId(@@map.map_id) : @@map.name
    filename = sprintf("%03d - #{map_name} #{filestart}", @@map.map_id)
    min_exists = 0
    if safeExists?("Exported Maps/" + filename + ".png")
      min_exists = 1
      loop do
        break if !safeExists?("Exported Maps/" + "#{filename}(#{min_exists})" + ".png")
        min_exists += 1
      end
    end
    filename = "#{filename}(#{min_exists})" if min_exists > 0
    @@bitmap.to_file("Exported Maps/" + filename + ".png")
    @@bitmap.dispose
    @@bitmap = nil
    @@map    = nil
    @@helper = nil
  end

  def create_tiled_bitmap(filename, hue, zoom = 1.0)
    begin
      bmp = RPG::Cache.load_bitmap("", filename)
    rescue
      error("Could not load image file at #{filename}")
    end
    new_bmp = Bitmap.new(@@map.width * Game_Map::TILE_HEIGHT, @@map.height * Game_Map::TILE_WIDTH)
    i = 0
    while i <= new_bmp.width
      j = 0
      while j <= new_bmp.height
        new_bmp.stretch_blt(Rect.new(i, j, (bmp.width * zoom), (bmp.height * zoom)), bmp, Rect.new(0, 0, bmp.width, bmp.height))
        j += (bmp.height * zoom)
      end
      i += (bmp.width * zoom)
    end
    bmp.dispose
    new_bmp.hue_change(hue)
    return new_bmp
  end

  def get_name_scale
    scale = @@map.width/3
    d = [0, -1 , -2,  2, 1, 0, -1, -2,  2, 1][scale%10]
    scale = (scale + d)/10.0
    return (scale < 1.0) ? 1.0 : scale
  end

  def colorize_and_flip_bitmap(bitmap, color, alpha = 255, rect = nil)
    blankcolor  = bitmap.get_pixel(0,0)
    new_bmp = Bitmap.new(rect.width, rect.height)
    temp_bmp = Bitmap.new(rect.width, rect.height)
    temp_bmp.blt(0, 0, bitmap, rect)
    for x in 0...temp_bmp.width
      for y2 in 0...temp_bmp.height
        y = temp_bmp.height - y2
        newcolor = temp_bmp.get_pixel(x, y2)
        new_bmp.set_pixel(x, y, newcolor) if newcolor
      end
    end
    temp_bmp.dispose
    shadowcolor = (color ? color : blankcolor)
    colorlayer  = Bitmap.new(new_bmp.width, new_bmp.height)
    colorlayer.fill_rect(colorlayer.rect, shadowcolor)
    new_bmp.blt(0, 0, colorlayer, colorlayer.rect, alpha)
    shadowcolor = new_bmp.get_pixel(0,0)
    for x in 0...new_bmp.width
      for y in 0...new_bmp.height
        if new_bmp.get_pixel(x,y) == shadowcolor
          new_bmp.set_pixel(x, y, blankcolor)
        end
      end
    end
    colorlayer.dispose
    return new_bmp
  end

  def set_map_options(options)
    return if !options.include?(:Panorama) && !options.include?(:Fog)
    @@map.events.each do |key, event|
      for page in event.event.pages.reverse
        c = page.condition
        next if c.switch1_valid && !event.switchIsOn?(c.switch1_id)
        next if c.switch2_valid && !event.switchIsOn?(c.switch2_id)
        next if c.variable_valid && $game_variables[c.variable_id] < c.variable_value
        if c.self_switch_valid
          key = [event.map_id, event.id, c.self_switch_ch]
          next if $game_self_switches[key] != true
        end
        page.list.each do |command|
          if command.code == 204
            case command.parameters[0]
            when 0
              next if !options.include?(:Panorama)
              @@map.panorama_name = command.parameters[1] if !nil_or_empty?(@@map.panorama_name)
              @@map.panorama_hue  = command.parameters[2] if @@map.panorama_hue <= 0
            when 1
              next if !options.include?(:Fog)
              @@map.fog_name    = command.parameters[1] if nil_or_empty?(@@map.fog_name)
              @@map.fog_hue     = command.parameters[2] if @@map.fog_hue <= 0
              @@map.fog_opacity = command.parameters[3] if @@map.fog_opacity < command.parameters[3]
              @@map.fog_zoom    = command.parameters[5]
            end
          elsif command.code == 205
            next if !options.include?(:Fog)
            @@map.fog_tone = command.parameters[0]
          elsif command.code == 206
            next if !options.include?(:Fog)
            @@map.fog_opacity = command.parameters[0] if command.parameters[0] != 0
          end
        end
        break
      end
    end
  end

  def error(message)
    emessage = "Map Exporter EX Error:\n\n" + message
    print(_INTL(emessage))
    exit!
  end
end

class Game_Map
  def tileset_id; return @map.tileset_id; end
end

class DependentEvents
  attr_accessor :realEvents
end

class Game_Character
  attr_reader :event
  attr_reader :always_on_top
end

class PokemonMapFactory
  def getMapForExport(id)
    map = Game_Map.new
    map.setup(id)
    return map
  end
end
