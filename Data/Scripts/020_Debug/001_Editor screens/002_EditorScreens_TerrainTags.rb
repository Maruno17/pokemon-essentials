#===============================================================================
# Edits the terrain tags of tiles in tilesets.
#===============================================================================
class PokemonTilesetScene
  TILE_SIZE          = 32   # in pixels
  TILES_PER_ROW      = 8
  TILESET_WIDTH      = TILES_PER_ROW * TILE_SIZE
  TILES_PER_AUTOTILE = 48
  TILESET_START_ID   = TILES_PER_ROW * TILES_PER_AUTOTILE
  CURSOR_COLOR       = Color.new(255, 0, 0)
  TEXT_COLOR         = Color.new(80, 80, 80)
  TEXT_SHADOW_COLOR  = Color.new(192, 192, 192)

  def initialize
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @tilesets_data = load_data("Data/Tilesets.rxdata")
    @tileset = @tilesets_data[1]
    @tilehelper = TileDrawingHelper.fromTileset(@tileset)
    @sprites = {}
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(_INTL("Tileset Editor\r\nQ/W: SCROLL\r\nZ: MENU"),
       TILESET_WIDTH, 0, Graphics.width - TILESET_WIDTH, 128, @viewport)
    @sprites["tileset"] = IconSprite.new(0, 0, @viewport)
    @sprites["tileset"].setBitmap("Graphics/Tilesets/#{@tileset.tileset_name}")
    @sprites["tileset"].src_rect = Rect.new(0, 0, TILESET_WIDTH, Graphics.height)
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["overlay"].x = 0
    @sprites["overlay"].y = 0
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["title"].visible = true
    @sprites["tileset"].visible = true
    @sprites["overlay"].visible = true
    @x = 0
    @y = -TILE_SIZE
    @topy = -TILE_SIZE
    @height = @sprites["tileset"].bitmap.height
    pbUpdateTileset
  end

  def pbUpdateTileset
    @sprites["overlay"].bitmap.clear
    @sprites["tileset"].src_rect = Rect.new(0, @topy, TILESET_WIDTH, Graphics.height)
    # Draw all text over tiles, along with their coordinates (and graphics for autotiles)
    textpos = []
    tilesize = @tileset.terrain_tags.xsize
    for yy in 0...Graphics.height / TILE_SIZE
      ypos = (yy + (@topy / TILE_SIZE)) * TILES_PER_ROW + TILESET_START_ID
      next if ypos >= tilesize
      for xx in 0...TILES_PER_ROW
        if ypos < TILESET_START_ID
          @tilehelper.bltTile(@sprites["overlay"].bitmap, xx * TILE_SIZE, yy * TILE_SIZE, xx * TILES_PER_AUTOTILE)
        end
        terr = (ypos < TILESET_START_ID) ? @tileset.terrain_tags[xx * TILES_PER_AUTOTILE] : @tileset.terrain_tags[ypos + xx]
        textpos.push(["#{terr}", xx * TILE_SIZE + TILE_SIZE / 2, yy * TILE_SIZE - 6, 2, TEXT_COLOR, TEXT_SHADOW_COLOR])
      end
    end
    pbDrawTextPositions(@sprites["overlay"].bitmap, textpos)
    # Draw cursor
    @sprites["overlay"].bitmap.fill_rect(@x,                 @y - @topy,                 TILE_SIZE, 4, CURSOR_COLOR)
    @sprites["overlay"].bitmap.fill_rect(@x,                 @y - @topy,                 4, TILE_SIZE, CURSOR_COLOR)
    @sprites["overlay"].bitmap.fill_rect(@x,                 @y - @topy + TILE_SIZE - 4, TILE_SIZE, 4, CURSOR_COLOR)
    @sprites["overlay"].bitmap.fill_rect(@x + TILE_SIZE - 4, @y - @topy,                 4, TILE_SIZE, CURSOR_COLOR)
    pbUpdateTileInformation
  end

  def pbUpdateTileInformation
    overlay = @sprites["overlay"].bitmap
    tile_x = Graphics.width * 3 / 4 - TILE_SIZE
    tile_y = Graphics.height / 2 - TILE_SIZE
    tile_id = pbGetSelected(@x, @y) || 0
    # Draw tile (at 200% size)
    @tilehelper.bltSmallTile(overlay, tile_x, tile_y, TILE_SIZE * 2, TILE_SIZE * 2, tile_id)
    # Draw box around tile image
    overlay.fill_rect(tile_x - 1,             tile_y - 1,             TILE_SIZE * 2 + 2, 1, Color.new(255, 255, 255))
    overlay.fill_rect(tile_x - 1,             tile_y - 1,             1, TILE_SIZE * 2 + 2, Color.new(255, 255, 255))
    overlay.fill_rect(tile_x - 1,             tile_y + TILE_SIZE * 2, TILE_SIZE * 2 + 2, 1, Color.new(255, 255, 255))
    overlay.fill_rect(tile_x + TILE_SIZE * 2, tile_y - 1,             1, TILE_SIZE * 2 + 2, Color.new(255, 255, 255))
    # Write terrain tag info about selected tile
    terrain_tag = @tileset.terrain_tags[tile_id] || 0
    if GameData::TerrainTag.exists?(terrain_tag)
      terrain_tag_name = sprintf("%d: %s", terrain_tag, GameData::TerrainTag.get(terrain_tag).real_name)
    else
      terrain_tag_name = terrain_tag.to_s
    end
    textpos = [
      [_INTL("Terrain Tag:"), tile_x + TILE_SIZE, tile_y + TILE_SIZE * 2 + 10, 2, Color.new(248, 248, 248), Color.new(40, 40, 40)],
      [terrain_tag_name, tile_x + TILE_SIZE, tile_y + TILE_SIZE * 2 + 42, 2, Color.new(248, 248, 248), Color.new(40, 40, 40)]
    ]
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
  end

  def pbChooseTileset
    commands = []
    for i in 1...@tilesets_data.length
      commands.push(sprintf("%03d %s", i, @tilesets_data[i].name))
    end
    ret = pbShowCommands(nil, commands, -1)
    if ret >= 0
      @tileset = @tilesets_data[ret + 1]
      @tilehelper.dispose
      @tilehelper = TileDrawingHelper.fromTileset(@tileset)
      @sprites["tileset"].setBitmap("Graphics/Tilesets/#{@tileset.tileset_name}")
      @x = 0
      @y = -TILE_SIZE
      @topy = -TILE_SIZE
      pbUpdateTileset
      @height = @sprites["tileset"].bitmap.height
    end
  end

  def pbGetSelected(x, y)
    return TILES_PER_AUTOTILE * (x / TILE_SIZE) if y < 0   # Autotile
    return TILESET_START_ID + (y / TILE_SIZE) * TILES_PER_ROW + (x / TILE_SIZE)
  end

  def pbSetSelected(i,value)
    if i < TILESET_START_ID
      for j in 0...TILES_PER_AUTOTILE
        @tileset.terrain_tags[i + j] = value
      end
    else
      @tileset.terrain_tags[i] = value
    end
  end

  def update_cursor_position(x_offset, y_offset)
    old_x = @x
    old_y = @y
    if x_offset != 0
      @x += x_offset * TILE_SIZE
      @x = @x.clamp(0, TILESET_WIDTH - TILE_SIZE)
    end
    if y_offset != 0
      @y += y_offset * TILE_SIZE
      @y = @y.clamp(-TILE_SIZE, @height - TILE_SIZE)
      @topy = @y if @y < @topy
      @topy = @y - Graphics.height + TILE_SIZE if @y >= @topy + Graphics.height
    end
    pbUpdateTileset if @x != old_x || @y != old_y
  end

  def pbStartScene
    pbFadeInAndShow(@sprites)
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
        update_cursor_position(0, -Graphics.height / TILE_SIZE)
      elsif Input.repeat?(Input::JUMPDOWN)
        update_cursor_position(0, Graphics.height / TILE_SIZE)
      elsif Input.trigger?(Input::ACTION)
        commands = [
           _INTL("Go to bottom"),
           _INTL("Go to top"),
           _INTL("Change tileset"),
           _INTL("Cancel")
        ]
        case pbShowCommands(nil,commands,-1)
        when 0
          @y = @height - TILE_SIZE
          @topy = @y - Graphics.height + TILE_SIZE if @y - @topy >= Graphics.height
          pbUpdateTileset
        when 1
          @y = -TILE_SIZE
          @topy = @y if @y < @topy
          pbUpdateTileset
        when 2
          pbChooseTileset
        end
      elsif Input.trigger?(Input::BACK)
        if pbConfirmMessage(_INTL("Save changes?"))
          save_data("Data/Tilesets.rxdata", @tilesets_data)
          $data_tilesets = @tilesets_data
          if $game_map && $MapFactory
            $MapFactory.setup($game_map.map_id)
            $game_player.center($game_player.x, $game_player.y)
            if $scene.is_a?(Scene_Map)
              $scene.disposeSpritesets
              $scene.createSpritesets
            end
          end
          pbMessage(_INTL("To ensure that the changes remain, close and reopen RPG Maker XP."))
        end
        break if pbConfirmMessage(_INTL("Exit from the editor?"))
      elsif Input.trigger?(Input::USE)
        selected = pbGetSelected(@x, @y)
        params = ChooseNumberParams.new
        params.setRange(0, 99)
        params.setDefaultValue(@tileset.terrain_tags[selected])
        pbSetSelected(selected,pbMessageChooseNumber(_INTL("Set the terrain tag."), params))
        pbUpdateTileset
      end
    end
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    @tilehelper.dispose
  end
end



def pbTilesetScreen
  pbFadeOutIn {
    scene = PokemonTilesetScene.new
    scene.pbStartScene
  }
end
