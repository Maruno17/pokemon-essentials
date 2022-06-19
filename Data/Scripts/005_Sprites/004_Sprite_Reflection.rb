class Sprite_Reflection
  attr_reader :visible
  attr_accessor :event

  def initialize(sprite, event, viewport = nil)
    @rsprite  = sprite
    @sprite   = nil
    @event    = event
    @height   = 0
    @fixedheight = false
    if @event && @event != $game_player && @event.name[/reflection\((\d+)\)/i]
      @height = $~[1].to_i || 0
      @fixedheight = true
    end
    @viewport = viewport
    @disposed = false
    update
  end

  def dispose
    if !@disposed
      @sprite&.dispose
      @sprite   = nil
      @disposed = true
    end
  end

  def disposed?
    @disposed
  end

  def visible=(value)
    @visible = value
    @sprite.visible = value if @sprite && !@sprite.disposed?
  end

  def update
    return if disposed?
    shouldShow = @rsprite.visible
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
      x = @rsprite.x - @rsprite.ox * TilemapRenderer::ZOOM_X
      y = @rsprite.y - @rsprite.oy * TilemapRenderer::ZOOM_Y
      y -= Game_Map::TILE_HEIGHT * TilemapRenderer::ZOOM_Y if @rsprite.character.character_name[/offset/i]
      @height = $PokemonGlobal.bridge if !@fixedheight
      y += @height * TilemapRenderer::ZOOM_Y * Game_Map::TILE_HEIGHT / 2
      width  = @rsprite.src_rect.width
      height = @rsprite.src_rect.height
      @sprite.x        = x + (width / 2) * TilemapRenderer::ZOOM_X
      @sprite.y        = y + (height + (height / 2)) * TilemapRenderer::ZOOM_Y
      @sprite.ox       = width / 2
      @sprite.oy       = (height / 2) - 2   # Hard-coded 2 pixel shift up
      @sprite.oy       -= @rsprite.character.bob_height * 2
      @sprite.z        = -50   # Still water is -100, map is 0 and above
      @sprite.z        += 1 if @event == $game_player
      @sprite.zoom_x   = @rsprite.zoom_x
      @sprite.zoom_y   = @rsprite.zoom_y
      frame = (Graphics.frame_count % 40) / 10
      @sprite.zoom_x   *= [1.0, 0.95, 1.0, 1.05][frame]
      @sprite.angle    = 180.0
      @sprite.mirror   = true
      @sprite.bitmap   = @rsprite.bitmap
      @sprite.tone     = @rsprite.tone
      if @height > 0
        @sprite.color   = Color.new(48, 96, 160, 255)   # Dark still water
        @sprite.opacity = @rsprite.opacity
        @sprite.visible = !Settings::TIME_SHADING   # Can't time-tone a colored sprite
      else
        @sprite.color   = Color.new(224, 224, 224, 96)
        @sprite.opacity = @rsprite.opacity * 3 / 4
        @sprite.visible = true
      end
      @sprite.src_rect = @rsprite.src_rect
    end
  end
end
