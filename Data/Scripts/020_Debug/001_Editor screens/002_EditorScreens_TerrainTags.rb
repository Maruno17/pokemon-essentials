#===============================================================================
# Edits the terrain tags of tiles in tilesets.
#===============================================================================
class PokemonTilesetScene
  TILE_SIZE            = 32   # in pixels
  TILES_PER_ROW        = 8
  TILESET_WIDTH        = TILES_PER_ROW * TILE_SIZE
  TILES_PER_AUTOTILE   = 48
  TILESET_START_ID     = TILES_PER_ROW * TILES_PER_AUTOTILE
  TILE_BACKGROUND      = Color.magenta
  CURSOR_COLOR         = Color.new(255, 0, 0)   # Red
  CURSOR_OUTLINE_COLOR = Color.white
  TEXT_COLOR           = Color.white
  TEXT_SHADOW_COLOR    = Color.black

  def initialize
    @tilesets_data = load_data("Data/Tilesets.rxdata")
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Tileset Editor\nA/S: SCROLL\nZ: MENU"),
      TILESET_WIDTH, 0, Graphics.width - TILESET_WIDTH, 128, @viewport
    )
    @sprites["background"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["tileset"] = BitmapSprite.new(TILESET_WIDTH, Graphics.height, @viewport)
    @sprites["tileset"].z = 10
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["overlay"].z = 20
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @visible_height = @sprites["tileset"].bitmap.height / TILE_SIZE
    load_tileset(1)
  end

  def open_screen
    pbFadeInAndShow(@sprites)
  end

  def close_screen
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    @tilehelper.dispose
    if $game_map && $map_factory
      $map_factory.setup($game_map.map_id)
      $game_player.center($game_player.x, $game_player.y)
      if $scene.is_a?(Scene_Map)
        $scene.dispose
        $scene.createSpritesets
      end
    end
  end

  def load_tileset(id)
    @tileset = @tilesets_data[id]
    @tilehelper&.dispose
    @tilehelper = TileDrawingHelper.fromTileset(@tileset)
    @x = 0
    @y = 0
    @top_y = 0
    @height = ((@tileset.terrain_tags.xsize - TILESET_START_ID) / TILES_PER_ROW) + 1
    draw_tiles
    draw_overlay
  end

  def choose_tileset
    commands = []
    (1...@tilesets_data.length).each do |i|
      commands.push(sprintf("%03d %s", i, @tilesets_data[i].name))
    end
    ret = pbShowCommands(nil, commands, -1)
    load_tileset(ret + 1) if ret >= 0
  end

  def draw_tiles
    @sprites["background"].bitmap.clear
    @sprites["tileset"].bitmap.clear
    @visible_height.times do |yy|
      autotile_row = (@top_y == 0 && yy == 0)   # Autotiles
      id_y_offset = (autotile_row) ? 0 : TILESET_START_ID + ((@top_y + yy - 1) * TILES_PER_ROW)
      break if @top_y + yy >= @height
      TILES_PER_ROW.times do |xx|
        @sprites["background"].bitmap.fill_rect(xx * TILE_SIZE, yy * TILE_SIZE, TILE_SIZE, TILE_SIZE, TILE_BACKGROUND)
        id_x_offset = (autotile_row) ? xx * TILES_PER_AUTOTILE : xx
        @tilehelper.bltTile(@sprites["tileset"].bitmap, xx * TILE_SIZE, yy * TILE_SIZE,
                            id_y_offset + id_x_offset)
      end
    end
  end

  def draw_overlay
    @sprites["overlay"].bitmap.clear
    # Draw all text over tiles (terrain tag numbers)
    textpos = []
    @visible_height.times do |yy|
      TILES_PER_ROW.times do |xx|
        tile_id = tile_ID_from_coordinates(xx, @top_y + yy)
        terr = @tileset.terrain_tags[tile_id]
        next if terr == 0
        textpos.push([terr.to_s, (xx * TILE_SIZE) + (TILE_SIZE / 2), (yy * TILE_SIZE) + 6,
                      :center, TEXT_COLOR, TEXT_SHADOW_COLOR, :outline])
      end
    end
    pbDrawTextPositions(@sprites["overlay"].bitmap, textpos)
    # Draw cursor
    draw_cursor
    # Draw information about selected tile on right side
    draw_tile_details
  end

  def draw_cursor
    cursor_x = @x * TILE_SIZE
    cursor_y = (@y - @top_y) * TILE_SIZE
    cursor_width = TILE_SIZE
    cursor_height = TILE_SIZE
    bitmap = @sprites["overlay"].bitmap
    bitmap.fill_rect(cursor_x - 2,                cursor_y - 2,                 cursor_width + 4, 8,  CURSOR_OUTLINE_COLOR)
    bitmap.fill_rect(cursor_x - 2,                cursor_y - 2,                 8, cursor_height + 4, CURSOR_OUTLINE_COLOR)
    bitmap.fill_rect(cursor_x - 2,                cursor_y + cursor_height - 6, cursor_width + 4, 8,  CURSOR_OUTLINE_COLOR)
    bitmap.fill_rect(cursor_x + cursor_width - 6, cursor_y - 2,                 8, cursor_height + 4, CURSOR_OUTLINE_COLOR)
    bitmap.fill_rect(cursor_x,                    cursor_y,                     cursor_width, 4,      CURSOR_COLOR)
    bitmap.fill_rect(cursor_x,                    cursor_y,                     4, cursor_height,     CURSOR_COLOR)
    bitmap.fill_rect(cursor_x,                    cursor_y + cursor_height - 4, cursor_width, 4,      CURSOR_COLOR)
    bitmap.fill_rect(cursor_x + cursor_width - 4, cursor_y,                     4, cursor_height,     CURSOR_COLOR)
  end

  def draw_tile_details
    overlay = @sprites["overlay"].bitmap
    tile_size = 4   # Size multiplier
    tile_x = (Graphics.width * 3 / 4) - (TILE_SIZE * tile_size / 2)
    tile_y = (Graphics.height / 2) - (TILE_SIZE * tile_size / 2)
    tile_id = tile_ID_from_coordinates(@x, @y) || 0
    # Draw tile (at 400% size)
    @sprites["background"].bitmap.fill_rect(tile_x, tile_y, TILE_SIZE * tile_size, TILE_SIZE * tile_size, TILE_BACKGROUND)
    @tilehelper.bltSmallTile(overlay, tile_x, tile_y, TILE_SIZE * tile_size, TILE_SIZE * tile_size, tile_id)
    # Draw box around tile image
    overlay.fill_rect(tile_x - 1,                       tile_y - 1,                       (TILE_SIZE * tile_size) + 2, 1, Color.white)
    overlay.fill_rect(tile_x - 1,                       tile_y - 1,                       1, (TILE_SIZE * tile_size) + 2, Color.white)
    overlay.fill_rect(tile_x - 1,                       tile_y + (TILE_SIZE * tile_size), (TILE_SIZE * tile_size) + 2, 1, Color.white)
    overlay.fill_rect(tile_x + (TILE_SIZE * tile_size), tile_y - 1,                       1, (TILE_SIZE * tile_size) + 2, Color.white)
    # Write terrain tag info about selected tile
    terrain_tag = @tileset.terrain_tags[tile_id] || 0
    if GameData::TerrainTag.exists?(terrain_tag)
      terrain_tag_name = sprintf("%d: %s", terrain_tag, GameData::TerrainTag.get(terrain_tag).real_name)
    else
      terrain_tag_name = terrain_tag.to_s
    end
    textpos = [
      [_INTL("Terrain Tag:"), Graphics.width * 3 / 4, tile_y + (TILE_SIZE * tile_size) + 22,
       :center, Color.new(248, 248, 248), Color.new(40, 40, 40)],
      [terrain_tag_name, Graphics.width * 3 / 4, tile_y + (TILE_SIZE * tile_size) + 54,
       :center, Color.new(248, 248, 248), Color.new(40, 40, 40)]
    ]
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
  end

  def tile_ID_from_coordinates(x, y)
    return x * TILES_PER_AUTOTILE if y == 0   # Autotile
    return TILESET_START_ID + ((y - 1) * TILES_PER_ROW) + x
  end

  def set_terrain_tag_for_tile_ID(i, value)
    if i < TILESET_START_ID
      TILES_PER_AUTOTILE.times { |j| @tileset.terrain_tags[i + j] = value }
    else
      @tileset.terrain_tags[i] = value
    end
  end

  def update_cursor_position(x_offset, y_offset)
    old_x = @x
    old_y = @y
    old_top_y = @top_y
    if x_offset != 0
      @x += x_offset
      @x = @x.clamp(0, TILES_PER_ROW - 1)
    end
    if y_offset != 0
      @y += y_offset
      @y = @y.clamp(0, @height - 1)
      @top_y = @y if @y < @top_y
      @top_y = @y - @visible_height + 1 if @y >= @top_y + @visible_height
      @top_y = 0 if @top_y < 0
    end
    draw_tiles if @top_y != old_top_y
    draw_overlay if @x != old_x || @y != old_y
  end

  def pbStartScene
    open_screen
    loop do
      Graphics.update
      Input.update
      if Input.repeat?(Input::UP)
        update_cursor_position(0, -1)
      elsif Input.repeat?(Input::DOWN)
        update_cursor_position(0, 1)
      elsif Input.repeat?(Input::LEFT)
        update_cursor_position(-1, 0)
      elsif Input.repeat?(Input::RIGHT)
        update_cursor_position(1, 0)
      elsif Input.repeat?(Input::JUMPUP)
        update_cursor_position(0, -@visible_height / 2)
      elsif Input.repeat?(Input::JUMPDOWN)
        update_cursor_position(0, @visible_height / 2)
      elsif Input.trigger?(Input::ACTION)
        commands = [
          _INTL("Go to bottom"),
          _INTL("Go to top"),
          _INTL("Change tileset"),
          _INTL("Cancel")
        ]
        case pbShowCommands(nil, commands, -1)
        when 0
          update_cursor_position(0, 99_999)
        when 1
          update_cursor_position(0, -99_999)
        when 2
          choose_tileset
        end
      elsif Input.trigger?(Input::BACK)
        if pbConfirmMessage(_INTL("Save changes?"))
          save_data(@tilesets_data, "Data/Tilesets.rxdata")
          $data_tilesets = @tilesets_data
          pbMessage(_INTL("To ensure that the changes remain, close and reopen RPG Maker XP."))
        end
        break if pbConfirmMessage(_INTL("Exit from the editor?"))
      elsif Input.trigger?(Input::USE)
        selected = tile_ID_from_coordinates(@x, @y)
        old_tag = @tileset.terrain_tags[selected]
        cmds = []
        ids = []
        old_idx = 0
        GameData::TerrainTag.each do |tag|
          old_idx = cmds.length if tag.id_number == old_tag
          cmds.push("#{tag.id_number}: #{tag.real_name}")
          ids.push(tag.id_number)
        end
        val = pbMessage("\\l[1]\\ts[]" + _INTL("Set the terrain tag."), cmds, -1, nil, old_idx)
        if val >= 0 && val != old_tag
          set_terrain_tag_for_tile_ID(selected, ids[val])
          draw_overlay
        end
      end
    end
    close_screen
  end
end

#===============================================================================
#
#===============================================================================
def pbTilesetScreen
  pbFadeOutIn do
    Graphics.resize_screen(Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT * 2)
    pbSetResizeFactor(1)
    scene = PokemonTilesetScene.new
    scene.pbStartScene
    Graphics.resize_screen(Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT)
    pbSetResizeFactor($PokemonSystem.screensize)
  end
end
