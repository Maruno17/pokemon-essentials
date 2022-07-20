=begin
A sprite whose sole purpose is to display an animation.  This sprite
can be displayed anywhere on the map and is disposed
automatically when its animation is finished.
Used for grass rustling and so forth.
=end
class AnimationSprite < RPG::Sprite
  def initialize(animID, map, tileX, tileY, viewport = nil, tinting = false, height = 3)
    super(viewport)
    @tileX = tileX
    @tileY = tileY
    self.bitmap = Bitmap.new(1, 1)
    self.bitmap.clear
    @map = map
    setCoords
    pbDayNightTint(self) if tinting
    self.animation($data_animations[animID], true, height)
  end

  def setCoords
    self.x = (((@tileX * Game_Map::REAL_RES_X) - @map.display_x) / Game_Map::X_SUBPIXELS).ceil
    self.x += Game_Map::TILE_WIDTH / 2
    self.y = (((@tileY * Game_Map::REAL_RES_Y) - @map.display_y) / Game_Map::Y_SUBPIXELS).ceil
    self.y += Game_Map::TILE_HEIGHT
  end

  def dispose
    self.bitmap.dispose
    super
  end

  def update
    if !self.disposed?
      setCoords
      super
      self.dispose if !self.effect?
    end
  end
end



class Spriteset_Map
  alias _animationSprite_initialize initialize unless private_method_defined?(:_animationSprite_initialize)
  alias _animationSprite_update update unless method_defined?(:_animationSprite_update)
  alias _animationSprite_dispose dispose unless method_defined?(:_animationSprite_dispose)

  def initialize(map = nil)
    @usersprites = []
    _animationSprite_initialize(map)
  end

  def addUserAnimation(animID, x, y, tinting = false, height = 3)
    sprite = AnimationSprite.new(animID, self.map, x, y, @@viewport1, tinting, height)
    addUserSprite(sprite)
    return sprite
  end

  def addUserSprite(new_sprite)
    @usersprites.each_with_index do |sprite, i|
      next if sprite && !sprite.disposed?
      @usersprites[i] = new_sprite
      return
    end
    @usersprites.push(new_sprite)
  end

  def dispose
    _animationSprite_dispose
    @usersprites.each { |sprite| sprite.dispose }
    @usersprites.clear
  end

  def update
    @@viewport3.tone.set(0, 0, 0, 0)
    _animationSprite_update
    @usersprites.each { |sprite| sprite.update if !sprite.disposed? }
  end
end
