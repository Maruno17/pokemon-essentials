class Sprite_Reflection
  attr_reader :visible

  def initialize(parent_sprite, viewport = nil)
    @parent_sprite = parent_sprite
    @sprite = nil
    @height = 0
    @fixedheight = false
    if @parent_sprite.character && @parent_sprite.character != $game_player &&
       @parent_sprite.character.name[/reflection\((\d+)\)/i]
      @height = $~[1].to_i || 0
      @fixedheight = true
    end
    @viewport = viewport
    @disposed = false
    update
  end

  def dispose
    return if @disposed
    @sprite&.dispose
    @sprite = nil
    @parent_sprite = nil
    @disposed = true
  end

  def disposed?
    return @disposed
  end

  def event
    return @parent_sprite.character
  end

  def visible=(value)
    @visible = value
    @sprite.visible = value if @sprite && !@sprite.disposed?
  end

  def update
    return if disposed?
    shouldShow = @parent_sprite.visible
    if !shouldShow
      # Just-in-time disposal of sprite
      if @sprite
        @sprite.dispose
        @sprite = nil
      end
      return
    end
    # Just-in-time creation of sprite
    @sprite = Sprite.new(@viewport) if !@sprite
    if @sprite
      x = @parent_sprite.x - (@parent_sprite.ox * TilemapRenderer::ZOOM_X)
      y = @parent_sprite.y - (@parent_sprite.oy * TilemapRenderer::ZOOM_Y)
      y -= Game_Map::TILE_HEIGHT * TilemapRenderer::ZOOM_Y if event.character_name[/offset/i]
      @height = $PokemonGlobal.bridge if !@fixedheight
      y += @height * TilemapRenderer::ZOOM_Y * Game_Map::TILE_HEIGHT / 2
      width  = @parent_sprite.src_rect.width
      height = @parent_sprite.src_rect.height
      @sprite.x        = x + ((width / 2) * TilemapRenderer::ZOOM_X)
      @sprite.y        = y + ((height + (height / 2)) * TilemapRenderer::ZOOM_Y)
      @sprite.ox       = width / 2
      @sprite.oy       = (height / 2) - 2   # Hard-coded 2 pixel shift up
      @sprite.oy       -= event.bob_height * 2
      @sprite.z        = -50   # Still water is -100, map is 0 and above
      @sprite.z        += 1 if event == $game_player
      @sprite.zoom_x   = @parent_sprite.zoom_x
      if Settings::ANIMATE_REFLECTIONS && !GameData::MapMetadata.try_get(event.map_id)&.still_reflections
        @sprite.zoom_x   += 0.05 * @sprite.zoom_x * Math.sin(2 * Math::PI * System.uptime)
      end
      @sprite.zoom_y   = @parent_sprite.zoom_y
      @sprite.angle    = 180.0
      @sprite.mirror   = true
      @sprite.bitmap   = @parent_sprite.bitmap
      @sprite.tone     = @parent_sprite.tone
      if @height > 0
        @sprite.color   = Color.new(48, 96, 160, 255)   # Dark still water
        @sprite.opacity = @parent_sprite.opacity
        @sprite.visible = !Settings::TIME_SHADING   # Can't time-tone a colored sprite
      else
        @sprite.color   = Color.new(224, 224, 224, 96)
        @sprite.opacity = @parent_sprite.opacity * 3 / 4
        @sprite.visible = true
      end
      @sprite.src_rect = @parent_sprite.src_rect
    end
  end
end
