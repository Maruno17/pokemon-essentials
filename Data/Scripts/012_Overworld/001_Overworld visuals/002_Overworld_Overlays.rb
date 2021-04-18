#===============================================================================
# Location signpost
#===============================================================================
class LocationWindow
  def initialize(name)
    @window = Window_AdvancedTextPokemon.new(name)
    @window.resizeToFit(name,Graphics.width)
    @window.x        = 0
    @window.y        = -@window.height
    @window.viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @window.viewport.z = 99999
    @currentmap = $game_map.map_id
    @frames = 0
  end

  def disposed?
    @window.disposed?
  end

  def dispose
    @window.dispose
  end

  def update
    return if @window.disposed?
    @window.update
    if $game_temp.message_window_showing || @currentmap!=$game_map.map_id
      @window.dispose
      return
    end
    if @frames > Graphics.frame_rate * 2
      @window.y -= 4
      @window.dispose if @window.y+@window.height<0
    else
      @window.y += 4 if @window.y<0
      @frames += 1
    end
  end
end



#===============================================================================
# Visibility circle in dark maps
#===============================================================================
class DarknessSprite < SpriteWrapper
  attr_reader :radius

  def initialize(viewport=nil)
    super(viewport)
    @darkness = BitmapWrapper.new(Graphics.width,Graphics.height)
    @radius = radiusMin
    self.bitmap = @darkness
    self.z      = 99998
    refresh
  end

  def dispose
    @darkness.dispose
    super
  end

  def radiusMin; return 64;  end   # Before using Flash
  def radiusMax; return 176; end   # After using Flash

  def radius=(value)
    @radius = value
    refresh
  end

  def refresh
    @darkness.fill_rect(0,0,Graphics.width,Graphics.height,Color.new(0,0,0,255))
    cx = Graphics.width/2
    cy = Graphics.height/2
    cradius = @radius
    numfades = 5
    for i in 1..numfades
      for j in cx-cradius..cx+cradius
        diff2 = (cradius * cradius) - ((j - cx) * (j - cx))
        diff = Math.sqrt(diff2)
        @darkness.fill_rect(j,cy-diff,1,diff*2,Color.new(0,0,0,255.0*(numfades-i)/numfades))
      end
      cradius = (cradius*0.9).floor
    end
  end
end



#===============================================================================
# Light effects
#===============================================================================
class LightEffect
  def initialize(event,viewport=nil,map=nil,filename=nil)
    @light = IconSprite.new(0,0,viewport)
    if filename!=nil && filename!="" && pbResolveBitmap("Graphics/Pictures/"+filename)
      @light.setBitmap("Graphics/Pictures/"+filename)
    else
      @light.setBitmap("Graphics/Pictures/LE")
    end
    @light.z = 1000
    @event = event
    @map = (map) ? map : $game_map
    @disposed = false
  end

  def disposed?
    return @disposed
  end

  def dispose
    @light.dispose
    @map = nil
    @event = nil
    @disposed = true
  end

  def update
    @light.update
  end
end



class LightEffect_Lamp < LightEffect
  def initialize(event,viewport=nil,map=nil)
    lamp = AnimatedBitmap.new("Graphics/Pictures/LE")
    @light = Sprite.new(viewport)
    @light.bitmap  = Bitmap.new(128,64)
    src_rect = Rect.new(0, 0, 64, 64)
    @light.bitmap.blt(0, 0, lamp.bitmap, src_rect)
    @light.bitmap.blt(20, 0, lamp.bitmap, src_rect)
    @light.visible = true
    @light.z       = 1000
    lamp.dispose
    @map = (map) ? map : $game_map
    @event = event
  end
end



class LightEffect_Basic < LightEffect
  def update
    return if !@light || !@event
    super
    @light.opacity = 100
    @light.ox      = 32
    @light.oy      = 48
    if (Object.const_defined?(:ScreenPosHelper) rescue false)
      @light.x      = ScreenPosHelper.pbScreenX(@event)
      @light.y      = ScreenPosHelper.pbScreenY(@event)
      @light.zoom_x = ScreenPosHelper.pbScreenZoomX(@event)
    else
      @light.x      = @event.screen_x
      @light.y      = @event.screen_y
      @light.zoom_x = 1.0
    end
    @light.zoom_y = @light.zoom_x
    @light.tone   = $game_screen.tone
  end
end



class LightEffect_DayNight < LightEffect
  def update
    return if !@light || !@event
    super
    shade = PBDayNight.getShade
    if shade>=144   # If light enough, call it fully day
      shade = 255
    elsif shade<=64   # If dark enough, call it fully night
      shade = 0
    else
      shade = 255-(255*(144-shade)/(144-64))
    end
    @light.opacity = 255-shade
    if @light.opacity>0
      @light.ox = 32
      @light.oy = 48
      if (Object.const_defined?(:ScreenPosHelper) rescue false)
        @light.x      = ScreenPosHelper.pbScreenX(@event)
        @light.y      = ScreenPosHelper.pbScreenY(@event)
        @light.zoom_x = ScreenPosHelper.pbScreenZoomX(@event)
        @light.zoom_y = ScreenPosHelper.pbScreenZoomY(@event)
      else
        @light.x      = @event.screen_x
        @light.y      = @event.screen_y
        @light.zoom_x = 1.0
        @light.zoom_y = 1.0
      end
      @light.tone.set($game_screen.tone.red,
                      $game_screen.tone.green,
                      $game_screen.tone.blue,
                      $game_screen.tone.gray)
    end
  end
end



Events.onSpritesetCreate += proc { |_sender,e|
  spriteset = e[0]      # Spriteset being created
  viewport  = e[1]      # Viewport used for tilemap and characters
  map = spriteset.map   # Map associated with the spriteset (not necessarily the current map)
  for i in map.events.keys
    if map.events[i].name[/^outdoorlight\((\w+)\)$/i]
      filename = $~[1].to_s
      spriteset.addUserSprite(LightEffect_DayNight.new(map.events[i],viewport,map,filename))
    elsif map.events[i].name[/^outdoorlight$/i]
      spriteset.addUserSprite(LightEffect_DayNight.new(map.events[i],viewport,map))
    elsif map.events[i].name[/^light\((\w+)\)$/i]
      filename = $~[1].to_s
      spriteset.addUserSprite(LightEffect_Basic.new(map.events[i],viewport,map,filename))
    elsif map.events[i].name[/^light$/i]
      spriteset.addUserSprite(LightEffect_Basic.new(map.events[i],viewport,map))
    end
  end
  spriteset.addUserSprite(Particle_Engine.new(viewport,map))
}
