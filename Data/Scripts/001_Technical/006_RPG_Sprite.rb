#===============================================================================
#
#===============================================================================
class SpriteAnimation
  @@_animations      = []
  @@_reference_count = {}

  def initialize(sprite)
    @sprite = sprite
  end

  def x(*arg);        @sprite.x(*arg);        end
  def y(*arg);        @sprite.y(*arg);        end
  def ox(*arg);       @sprite.ox(*arg);       end
  def oy(*arg);       @sprite.oy(*arg);       end
  def viewport(*arg); @sprite.viewport(*arg); end
  def flash(*arg);    @sprite.flash(*arg);    end
  def src_rect(*arg); @sprite.src_rect(*arg); end
  def opacity(*arg);  @sprite.opacity(*arg);  end
  def tone(*arg);     @sprite.tone(*arg);     end

  def self.clear
    @@_animations.clear
  end

  def dispose
    dispose_animation
    dispose_loop_animation
  end

  def animation(animation, hit, height = 3)
    dispose_animation
    @_animation = animation
    return if @_animation.nil?
    @_animation_hit      = hit
    @_animation_height   = height
    @_animation_duration = @_animation.frame_max
    @_animation_index    = -1
    fr = 20
    if @_animation.name[/\[\s*(\d+?)\s*\]\s*$/]
      fr = $~[1].to_i
    end
    @_animation_time_per_frame = 1.0 / fr
    @_animation_timer_start = System.uptime
    animation_name = @_animation.animation_name
    animation_hue  = @_animation.animation_hue
    bitmap = pbGetAnimation(animation_name, animation_hue)
    if @@_reference_count.include?(bitmap)
      @@_reference_count[bitmap] += 1
    else
      @@_reference_count[bitmap] = 1
    end
    @_animation_sprites = []
    if @_animation.position != 3 || !@@_animations.include?(animation)
      16.times do
        sprite = ::Sprite.new(self.viewport)
        sprite.bitmap = bitmap
        sprite.visible = false
        @_animation_sprites.push(sprite)
      end
      @@_animations.push(animation) unless @@_animations.include?(animation)
    end
    update_animation
  end

  def loop_animation(animation)
    return if animation == @_loop_animation
    dispose_loop_animation
    @_loop_animation = animation
    return if @_loop_animation.nil?
    @_loop_animation_duration = @_animation.frame_max
    @_loop_animation_index = -1
    fr = 20
    if @_animation.name[/\[\s*(\d+?)\s*\]\s*$/]
      fr = $~[1].to_i
    end
    @_loop_animation_time_per_frame = 1.0 / fr
    @_loop_animation_timer_start = System.uptime
    animation_name = @_loop_animation.animation_name
    animation_hue  = @_loop_animation.animation_hue
    bitmap = pbGetAnimation(animation_name, animation_hue)
    if @@_reference_count.include?(bitmap)
      @@_reference_count[bitmap] += 1
    else
      @@_reference_count[bitmap] = 1
    end
    @_loop_animation_sprites = []
    16.times do
      sprite = ::Sprite.new(self.viewport)
      sprite.bitmap = bitmap
      sprite.visible = false
      @_loop_animation_sprites.push(sprite)
    end
    update_loop_animation
  end

  def dispose_animation
    return if @_animation_sprites.nil?
    sprite = @_animation_sprites[0]
    if sprite
      @@_reference_count[sprite.bitmap] -= 1
      sprite.bitmap.dispose if @@_reference_count[sprite.bitmap] == 0
    end
    @_animation_sprites.each { |s| s.dispose }
    @_animation_sprites = nil
    @_animation = nil
    @_animation_duration = 0
  end

  def dispose_loop_animation
    return if @_loop_animation_sprites.nil?
    sprite = @_loop_animation_sprites[0]
    if sprite
      @@_reference_count[sprite.bitmap] -= 1
      sprite.bitmap.dispose if @@_reference_count[sprite.bitmap] == 0
    end
    @_loop_animation_sprites.each { |s| s.dispose }
    @_loop_animation_sprites = nil
    @_loop_animation = nil
  end

  def active?
    return @_loop_animation_sprites || @_animation_sprites
  end

  def effect?
    return @_animation_duration > 0
  end

  def update
    update_animation if @_animation
    update_loop_animation if @_loop_animation
  end

  def update_animation
    new_index = ((System.uptime - @_animation_timer_start) / @_animation_time_per_frame).to_i
    if new_index >= @_animation_duration
      dispose_animation
      return
    end
    quick_update = (@_animation_index == new_index)
    @_animation_index = new_index
    frame_index = @_animation_index
    cell_data   = @_animation.frames[frame_index].cell_data
    position    = @_animation.position
    animation_set_sprites(@_animation_sprites, cell_data, position, quick_update)
    return if quick_update
    @_animation.timings.each do |timing|
      next if timing.frame != frame_index
      animation_process_timing(timing, @_animation_hit)
    end
  end

  def update_loop_animation
    new_index = ((System.uptime - @_loop_animation_timer_start) / @_loop_animation_time_per_frame).to_i
    new_index %= @_loop_animation_duration
    quick_update = (@_loop_animation_index == new_index)
    @_loop_animation_index = new_index
    frame_index = @_loop_animation_index
    cell_data   = @_loop_animation.frames[frame_index].cell_data
    position    = @_loop_animation.position
    animation_set_sprites(@_loop_animation_sprites, cell_data, position, quick_update)
    return if quick_update
    @_loop_animation.timings.each do |timing|
      next if timing.frame != frame_index
      animation_process_timing(timing, true)
    end
  end

  def animation_set_sprites(sprites, cell_data, position, quick_update = false)
    sprite_x = 320
    sprite_y = 240
    if position == 3   # Screen
      if self.viewport
        sprite_x = self.viewport.rect.width / 2
        sprite_y = self.viewport.rect.height - 160
      end
    else
      sprite_x = self.x - self.ox + (self.src_rect.width / 2)
      sprite_y = self.y - self.oy
      if self.src_rect.height > 1
        sprite_y += self.src_rect.height / 2 if position == 1   # Middle
        sprite_y += self.src_rect.height if position == 2   # Bottom
      end
    end
    16.times do |i|
      sprite = sprites[i]
      pattern = cell_data[i, 0]
      if sprite.nil? || pattern.nil? || pattern == -1
        sprite.visible = false if sprite
        next
      end
      sprite.x = sprite_x + cell_data[i, 1]
      sprite.y = sprite_y + cell_data[i, 2]
      next if quick_update
      sprite.visible = true
      sprite.src_rect.set((pattern % 5) * 192, (pattern / 5) * 192, 192, 192)
      case @_animation_height
      when 0 then sprite.z = 1
      when 1 then sprite.z = sprite.y + (Game_Map::TILE_HEIGHT * 3 / 2) + 1
      when 2 then sprite.z = sprite.y + (Game_Map::TILE_HEIGHT * 3) + 1
      else        sprite.z = 2000
      end
      sprite.ox         = 96
      sprite.oy         = 96
      sprite.zoom_x     = cell_data[i, 3] / 100.0
      sprite.zoom_y     = cell_data[i, 3] / 100.0
      sprite.angle      = cell_data[i, 4]
      sprite.mirror     = (cell_data[i, 5] == 1)
      sprite.tone       = self.tone
      sprite.opacity    = cell_data[i, 6] * self.opacity / 255.0
      sprite.blend_type = cell_data[i, 7]
    end
  end

  def animation_process_timing(timing, hit)
    if timing.condition == 0 ||
       (timing.condition == 1 && hit == true) ||
       (timing.condition == 2 && hit == false)
      if timing.se.name != ""
        se = timing.se
        pbSEPlay(se)
      end
      case timing.flash_scope
      when 1
        self.flash(timing.flash_color, timing.flash_duration * 2)
      when 2
        self.viewport.flash(timing.flash_color, timing.flash_duration * 2) if self.viewport
      when 3
        self.flash(nil, timing.flash_duration * 2)
      end
    end
  end

  def x=(x)
    sx = x - self.x
    return if sx == 0
    if @_animation_sprites
      16.times { |i| @_animation_sprites[i].x += sx }
    end
    if @_loop_animation_sprites
      16.times { |i| @_loop_animation_sprites[i].x += sx }
    end
  end

  def y=(y)
    sy = y - self.y
    return if sy == 0
    if @_animation_sprites
      16.times { |i| @_animation_sprites[i].y += sy }
    end
    if @_loop_animation_sprites
      16.times { |i| @_loop_animation_sprites[i].y += sy }
    end
  end
end

#===============================================================================
#
#===============================================================================
module RPG
  class Sprite < ::Sprite
    def initialize(viewport = nil)
      super(viewport)
      @_animation_duration = 0
      @_animation_frame = 0
      @animations = []
      @loopAnimations = []
    end

    def dispose
      dispose_animation
      dispose_loop_animation
      super
    end

    def dispose_animation
      @animations.each { |a| a&.dispose_animation }
      @animations.clear
    end

    def dispose_loop_animation
      @loopAnimations.each { |a| a&.dispose_loop_animation }
      @loopAnimations.clear
    end

    def x=(x)
      @animations.each { |a| a.x = x if a }
      @loopAnimations.each { |a| a.x = x if a }
      super
    end

    def y=(y)
      @animations.each { |a| a.y = y if a }
      @loopAnimations.each { |a| a.y = y if a }
      super
    end

    def pushAnimation(array, anim)
      array.length.times do |i|
        next if array[i]&.active?
        array[i] = anim
        return
      end
      array.push(anim)
    end

    def animation(animation, hit, height = 3)
      anim = SpriteAnimation.new(self)
      anim.animation(animation, hit, height)
      pushAnimation(@animations, anim)
    end

    def loop_animation(animation)
      anim = SpriteAnimation.new(self)
      anim.loop_animation(animation)
      pushAnimation(@loopAnimations, anim)
    end

    def effect?
      @animations.each { |a| return true if a.effect? }
      return false
    end

    def update_animation
      @animations.each { |a| a.update_animation if a&.active? }
    end

    def update_loop_animation
      @loopAnimations.each { |a| a.update_loop_animation if a&.active? }
    end

    def update
      super
      @animations.each { |a| a.update }
      @loopAnimations.each { |a| a.update }
      SpriteAnimation.clear
    end
  end
end

#===============================================================================
# A version of class Sprite that allows its coordinates to be floats rather than
# integers.
#===============================================================================
class FloatSprite < Sprite
  def x; return @float_x; end
  def y; return @float_y; end

  def x=(value)
    @float_x = value
    super
  end

  def y=(value)
    @float_y = value
    super
  end
end
