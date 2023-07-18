#===============================================================================
# Sprite_Shadow (Sprite_Ombre )
# Based on Genzai Kawakami's shadows, dynamisme & features by Rataime, extra
# features Boushy
# Modified by Peter O. to be compatible with Pokémon Essentials
#===============================================================================
class Sprite_Shadow < RPG::Sprite
  attr_accessor :character

  def initialize(viewport, character = nil, params = [])
    super(viewport)
    @source       = params[0]
    @anglemin     = (params.size > 1) ? params[1] : 0
    @anglemax     = (params.size > 2) ? params[2] : 0
    @self_opacity = (params.size > 4) ? params[4] : 100
    @distancemax  = (params.size > 3) ? params[3] : 350
    @character    = character
    update
  end

  def dispose
    @chbitmap&.dispose
    super
  end

  def update
    if !in_range?(@character, @source, @distancemax)
      self.opacity = 0
      return
    end
    super
    if @tile_id != @character.tile_id ||
       @character_name != @character.character_name ||
       @character_hue != @character.character_hue
      @tile_id        = @character.tile_id
      @character_name = @character.character_name
      @character_hue  = @character.character_hue
      @chbitmap&.dispose
      if @tile_id >= 384
        @chbitmap = pbGetTileBitmap(@character.map.tileset_name,
                                    @tile_id, @character.character_hue)
        self.src_rect.set(0, 0, 32, 32)
        @ch = 32
        @cw = 32
        self.ox = 16
        self.oy = 32
      else
        @chbitmap = AnimatedBitmap.new("Graphics/Characters/" + @character.character_name,
                                       @character.character_hue)
        @cw = @chbitmap.width / 4
        @ch = @chbitmap.height / 4
        self.ox = @cw / 2
        self.oy = @ch
      end
    end
    if @chbitmap.is_a?(AnimatedBitmap)
      @chbitmap.update
      self.bitmap = @chbitmap.bitmap
    else
      self.bitmap = @chbitmap
    end
    self.visible = !@character.transparent
    if @tile_id == 0
      sx = @character.pattern * @cw
      sy = (@character.direction - 2) / 2 * @ch
      if self.angle > 90 || angle < -90
        case @character.direction
        when 2 then sy = @ch * 3
        when 4 then sy = @ch * 2
        when 6 then sy = @ch
        when 8 then sy = 0
        end
      end
      self.src_rect.set(sx, sy, @cw, @ch)
    end
    self.x = ScreenPosHelper.pbScreenX(@character)
    self.y = ScreenPosHelper.pbScreenY(@character) - 5
    self.z = ScreenPosHelper.pbScreenZ(@character, @ch) - 1
    self.zoom_x = ScreenPosHelper.pbScreenZoomX(@character)
    self.zoom_y = ScreenPosHelper.pbScreenZoomY(@character)
    self.blend_type = @character.blend_type
    self.bush_depth = @character.bush_depth
    if @character.animation_id != 0
      animation = $data_animations[@character.animation_id]
      animation(animation, true)
      @character.animation_id = 0
    end
    @deltax = ScreenPosHelper.pbScreenX(@source) - self.x
    @deltay = ScreenPosHelper.pbScreenY(@source) - self.y
    self.color = Color.black
    @distance = ((@deltax**2) + (@deltay**2))
    self.opacity = @self_opacity * 13_000 / ((@distance * 370 / @distancemax) + 6000)
    self.angle = 57.3 * Math.atan2(@deltax, @deltay)
    @angle_trigo = self.angle + 90
    @angle_trigo += 360 if @angle_trigo < 0
    if @anglemin != 0 || @anglemax != 0
      if (@angle_trigo < @anglemin || @angle_trigo > @anglemax) && @anglemin < @anglemax
        self.opacity = 0
        return
      end
      if @angle_trigo < @anglemin && @angle_trigo > @anglemax && @anglemin > @anglemax
        self.opacity = 0
        return
      end
    end
  end

  # From Near's Anti Lag Script, edited.
  def in_range?(element, object, range)
    elemScreenX = ScreenPosHelper.pbScreenX(element)
    elemScreenY = ScreenPosHelper.pbScreenY(element)
    objScreenX  = ScreenPosHelper.pbScreenX(object)
    objScreenY  = ScreenPosHelper.pbScreenY(object)
    x = (elemScreenX - objScreenX) * (elemScreenX - objScreenX)
    y = (elemScreenY - objScreenY) * (elemScreenY - objScreenY)
    r = x + y
    return r <= range * range
  end
end

#===============================================================================
# ? CLASS Sprite_Character edit
#===============================================================================
class Sprite_Character < RPG::Sprite
  alias shadow_initialize initialize unless private_method_defined?(:shadow_initialize)

  def initialize(viewport, character = nil)
    @ombrelist = []
    @character = character
    shadow_initialize(viewport, @character)
  end

  def setShadows(map, shadows)
    if character.is_a?(Game_Event) && shadows.length > 0
      params = XPML_read(map, "Shadow", @character, 4)
      if params
        shadows.each do |shadow|
          @ombrelist.push(Sprite_Shadow.new(viewport, @character, shadows))
        end
      end
    end
    if character.is_a?(Game_Player) && shadows.length > 0
      shadows.each do |shadow|
        @ombrelist.push(Sprite_Shadow.new(viewport, $game_player, shadow))
      end
    end
    update
  end

  def clearShadows
    @ombrelist.each { |s| s&.dispose }
    @ombrelist.clear
  end

  alias shadow_update update unless method_defined?(:shadow_update)

  def update
    shadow_update
    @ombrelist.each { |ombre| ombre.update }
  end
end

#===============================================================================
# ? CLASS Game_Event edit
#===============================================================================
class Game_Event
  attr_accessor :id
end

#===============================================================================
# ? CLASS Spriteset_Map edit
#===============================================================================
class Spriteset_Map
  attr_accessor :shadows

  alias shadow_initialize initialize unless private_method_defined?(:shadow_initialize)

  def initialize(map = nil)
    @shadows = []
    warn = false
    map = $game_map if !map
    map.events.keys.sort.each do |k|
      ev = map.events[k]
      warn = true if ev.list && ev.list.length > 0 && ev.list[0].code == 108 &&
                     (ev.list[0].parameters == ["s"] || ev.list[0].parameters == ["o"])
      params = XPML_read(map, "Shadow Source", ev, 4)
      @shadows.push([ev] + params) if params
    end
    if warn == true
      p "Warning : At least one event on this map uses the obsolete way to add shadows"
    end
    shadow_initialize(map)
    @character_sprites.each do |sprite|
      sprite.setShadows(map, @shadows)
    end
    $scene.spritesetGlobal.playersprite.setShadows(map, @shadows)
  end
end

#===============================================================================
# ? XPML Definition, by Rataime, using ideas from Near Fantastica
#
#   Returns nil if the markup wasn't present at all,
#   returns [] if there wasn't any parameters, else
#   returns a parameters list with "int" converted as int
#   eg :
#   begin first
#   begin second
#   param1 1
#   param2 two
#   begin third
#   anything 3
#
#   p XPML_read("first", event_id) -> []
#   p XPML_read("second", event_id) -> [1, "two"]
#   p XPML_read("third", event_id) -> [3]
#   p XPML_read("forth", event_id) -> nil
#===============================================================================
def XPML_read(map, markup, event, max_param_number = 0)
  parameter_list = nil
  return nil if !event || event.list.nil?
  event.list.size.times do |i|
    next unless event.list[i].code == 108 &&
                event.list[i].parameters[0].downcase == "begin " + markup.downcase
    parameter_list = [] if parameter_list.nil?
    ((i + 1)...event.list.size).each do |j|
      return parameter_list if event.list[j].code != 108
      parts = event.list[j].parameters[0].split
      return parameter_list if parts.size == 1 || parts[0].downcase == "begin"
      if parts[1].to_i != 0 || parts[1] == "0"
        parameter_list.push(parts[1].to_i)
      else
        parameter_list.push(parts[1])
      end
      return parameter_list if max_param_number != 0 && j == i + max_param_number
    end
  end
  return parameter_list
end
