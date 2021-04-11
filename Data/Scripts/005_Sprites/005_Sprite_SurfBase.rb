class Sprite_SurfBase
  attr_reader   :visible
  attr_accessor :event

  def initialize(sprite,event,viewport=nil)
    @rsprite  = sprite
    @sprite   = nil
    @event    = event
    @viewport = viewport
    @disposed = false
    @surfbitmap = AnimatedBitmap.new("Graphics/Characters/base_surf")
    @divebitmap = AnimatedBitmap.new("Graphics/Characters/base_dive")
    RPG::Cache.retain("Graphics/Characters/base_surf")
    RPG::Cache.retain("Graphics/Characters/base_dive")
    @cws = @surfbitmap.width/4
    @chs = @surfbitmap.height/4
    @cwd = @divebitmap.width/4
    @chd = @divebitmap.height/4
    update
  end

  def dispose
    return if @disposed
    @sprite.dispose if @sprite
    @sprite   = nil
    @surfbitmap.dispose
    @divebitmap.dispose
    @disposed = true
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
    if !$PokemonGlobal.surfing && !$PokemonGlobal.diving
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
      if $PokemonGlobal.surfing
        @sprite.bitmap = @surfbitmap.bitmap
        cw = @cws
        ch = @chs
      elsif $PokemonGlobal.diving
        @sprite.bitmap = @divebitmap.bitmap
        cw = @cwd
        ch = @chd
      end
      sx = @event.pattern_surf*cw
      sy = ((@event.direction-2)/2)*ch
      @sprite.src_rect.set(sx,sy,cw,ch)
      if $PokemonTemp.surfJump
        @sprite.x = ($PokemonTemp.surfJump[0]*Game_Map::REAL_RES_X-@event.map.display_x+3)/4+(Game_Map::TILE_WIDTH/2)
        @sprite.y = ($PokemonTemp.surfJump[1]*Game_Map::REAL_RES_Y-@event.map.display_y+3)/4+(Game_Map::TILE_HEIGHT/2)+16
      else
        @sprite.x = @rsprite.x
        @sprite.y = @rsprite.y
      end
      @sprite.ox      = cw/2
      @sprite.oy      = ch-16   # Assume base needs offsetting
      @sprite.oy      -= @event.bob_height
      @sprite.z       = @event.screen_z(ch)-1
      @sprite.zoom_x  = @rsprite.zoom_x
      @sprite.zoom_y  = @rsprite.zoom_y
      @sprite.tone    = @rsprite.tone
      @sprite.color   = @rsprite.color
      @sprite.opacity = @rsprite.opacity
    end
  end
end
