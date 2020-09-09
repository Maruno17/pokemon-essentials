class SpriteAnimation
  @@_animations      = []
  @@_reference_count = {}

  def initialize(sprite)
    @sprite = sprite
  end

  %w[
     x y ox oy viewport flash src_rect opacity tone
  ].each_with_index do |s, _i|
  eval <<-__END__

  def #{s}(*arg)
    @sprite.#{s}(*arg)
  end

  __END__
  end

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
    return if @_animation == nil
    @_animation_hit      = hit
    @_animation_height   = height
    @_animation_duration = @_animation.frame_max
    fr = 20
    if @_animation.name[/\[\s*(\d+?)\s*\]\s*$/]
      fr = $~[1].to_i
    end
    @_animation_frame_skip = Graphics.frame_rate / fr
    animation_name = @_animation.animation_name
    animation_hue  = @_animation.animation_hue
    bitmap = pbGetAnimation(animation_name, animation_hue)
    if @@_reference_count.include?(bitmap)
      @@_reference_count[bitmap] += 1
    else
      @@_reference_count[bitmap] = 1
    end
    @_animation_sprites = []
    if @_animation.position != 3 or not @@_animations.include?(animation)
      16.times do
        sprite = ::Sprite.new(self.viewport)
        sprite.bitmap = bitmap
        sprite.visible = false
        @_animation_sprites.push(sprite)
      end
      unless @@_animations.include?(animation)
        @@_animations.push(animation)
      end
    end
    update_animation
  end

  def loop_animation(animation)
    return if animation == @_loop_animation
    dispose_loop_animation
    @_loop_animation = animation
    return if @_loop_animation == nil
    @_loop_animation_index = 0
    fr = 20
    if @_animation.name[/\[\s*(\d+?)\s*\]\s*$/]
      fr = $~[1].to_i
    end
    @_loop_animation_frame_skip = Graphics.frame_rate / fr
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
    return if @_animation_sprites == nil
    sprite = @_animation_sprites[0]
    if sprite != nil
      @@_reference_count[sprite.bitmap] -= 1
      if @@_reference_count[sprite.bitmap] == 0
        sprite.bitmap.dispose
      end
    end
    for sprite in @_animation_sprites
      sprite.dispose
    end
    @_animation_sprites = nil
    @_animation = nil
  end

  def dispose_loop_animation
    return if @_loop_animation_sprites == nil
    sprite = @_loop_animation_sprites[0]
    if sprite != nil
      @@_reference_count[sprite.bitmap] -= 1
      if @@_reference_count[sprite.bitmap] == 0
        sprite.bitmap.dispose
      end
    end
    for sprite in @_loop_animation_sprites
      sprite.dispose
    end
    @_loop_animation_sprites = nil
    @_loop_animation = nil
  end

  def active?
    return @_loop_animation_sprites != nil || @_animation_sprites != nil
  end

  def effect?
    return @_animation_duration > 0
  end

  def update
    if @_animation != nil
      quick_update = true
      if Graphics.frame_count % @_animation_frame_skip == 0
        @_animation_duration -= 1
        quick_update = false
      end
      update_animation(quick_update)
    end
    if @_loop_animation != nil
      quick_update = (Graphics.frame_count % @_loop_animation_frame_skip != 0)
      update_loop_animation(quick_update)
      if !quick_update
        @_loop_animation_index += 1
        @_loop_animation_index %= @_loop_animation.frame_max
      end
    end
  end

  def update_animation(quick_update = false)
    if @_animation_duration <= 0
      dispose_animation
      return
    end
    frame_index = @_animation.frame_max - @_animation_duration
    cell_data   = @_animation.frames[frame_index].cell_data
    position    = @_animation.position
    animation_set_sprites(@_animation_sprites, cell_data, position, quick_update)
    return if quick_update
    for timing in @_animation.timings
      next if timing.frame != frame_index
      animation_process_timing(timing, @_animation_hit)
    end
  end

  def update_loop_animation(quick_update = false)
    frame_index = @_loop_animation_index
    cell_data   = @_loop_animation.frames[frame_index].cell_data
    position    = @_loop_animation.position
    animation_set_sprites(@_loop_animation_sprites, cell_data, position, quick_update)
    return if quick_update
    for timing in @_loop_animation.timings
      next if timing.frame != frame_index
      animation_process_timing(timing, true)
    end
  end

  def animation_set_sprites(sprites, cell_data, position, quick_update = false)
    sprite_x = 320
    sprite_y = 240
    if position == 3
      if self.viewport != nil
        sprite_x = self.viewport.rect.width / 2
        sprite_y = self.viewport.rect.height - 160
      end
    else
      sprite_x = self.x - self.ox + self.src_rect.width / 2
      sprite_y = self.y - self.oy + self.src_rect.height / 2
      sprite_y -= self.src_rect.height / 4 if position == 0
      sprite_y += self.src_rect.height / 4 if position == 2
    end
    for i in 0..15
      sprite = sprites[i]
      pattern = cell_data[i, 0]
      if sprite == nil or pattern == nil or pattern == -1
        sprite.visible = false if sprite != nil
        next
      end
      sprite.x          = sprite_x + cell_data[i, 1]
      sprite.y          = sprite_y + cell_data[i, 2]
      next if quick_update
      sprite.visible    = true
      sprite.src_rect.set(pattern % 5 * 192, pattern / 5 * 192, 192, 192)
      case @_animation_height
      when 0; sprite.z  = 1
      when 1; sprite.z  = sprite.y+32+15
      when 2; sprite.z  = sprite.y+32+32+17
      else;   sprite.z  = 2000
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
    if (timing.condition == 0) or
       (timing.condition == 1 and hit == true) or
       (timing.condition == 2 and hit == false)
      if timing.se.name != ""
        se = timing.se
        pbSEPlay(se)
      end
      case timing.flash_scope
      when 1
        self.flash(timing.flash_color, timing.flash_duration * 2)
      when 2
        if self.viewport != nil
          self.viewport.flash(timing.flash_color, timing.flash_duration * 2)
        end
      when 3
        self.flash(nil, timing.flash_duration * 2)
      end
    end
  end

  def x=(x)
    sx = x - self.x
    return if sx == 0
    if @_animation_sprites != nil
      for i in 0..15
        @_animation_sprites[i].x += sx
      end
    end
    if @_loop_animation_sprites != nil
      for i in 0..15
        @_loop_animation_sprites[i].x += sx
      end
    end
  end

  def y=(y)
    sy = y - self.y
    return if sy == 0
    if @_animation_sprites != nil
      for i in 0..15
        @_animation_sprites[i].y += sy
      end
    end
    if @_loop_animation_sprites != nil
      for i in 0..15
        @_loop_animation_sprites[i].y += sy
      end
    end
  end
end



module RPG
  class Sprite < ::Sprite
    def initialize(viewport = nil)
      super(viewport)
      @_whiten_duration    = 0
      @_appear_duration    = 0
      @_escape_duration    = 0
      @_collapse_duration  = 0
      @_damage_duration    = 0
      @_animation_duration = 0
      @_blink              = false
      @animations     = []
      @loopAnimations = []
    end

    def dispose
      dispose_damage
      dispose_animation
      dispose_loop_animation
      super
    end

    def whiten
      self.blend_type     = 0
      self.color.set(255, 255, 255, 128)
      self.opacity        = 255
      @_whiten_duration   = 16
      @_appear_duration   = 0
      @_escape_duration   = 0
      @_collapse_duration = 0
    end

    def appear
      self.blend_type     = 0
      self.color.set(0, 0, 0, 0)
      self.opacity        = 0
      @_appear_duration   = 16
      @_whiten_duration   = 0
      @_escape_duration   = 0
      @_collapse_duration = 0
    end

    def escape
      self.blend_type     = 0
      self.color.set(0, 0, 0, 0)
      self.opacity        = 255
      @_escape_duration   = 32
      @_whiten_duration   = 0
      @_appear_duration   = 0
      @_collapse_duration = 0
    end

    def collapse
      self.blend_type     = 1
      self.color.set(255, 64, 64, 255)
      self.opacity        = 255
      @_collapse_duration = 48
      @_whiten_duration   = 0
      @_appear_duration   = 0
      @_escape_duration   = 0
    end

    def damage(value, critical)
      dispose_damage
      damage_string = (value.is_a?(Numeric)) ? value.abs.to_s : value.to_s
      bitmap = Bitmap.new(160, 48)
      bitmap.font.name = "Arial Black"
      bitmap.font.size = 32
      bitmap.font.color.set(0, 0, 0)
      bitmap.draw_text(-1, 12-1, 160, 36, damage_string, 1)
      bitmap.draw_text(+1, 12-1, 160, 36, damage_string, 1)
      bitmap.draw_text(-1, 12+1, 160, 36, damage_string, 1)
      bitmap.draw_text(+1, 12+1, 160, 36, damage_string, 1)
      if value.is_a?(Numeric) and value < 0
        bitmap.font.color.set(176, 255, 144)
      else
        bitmap.font.color.set(255, 255, 255)
      end
      bitmap.draw_text(0, 12, 160, 36, damage_string, 1)
      if critical
        bitmap.font.size = 20
        bitmap.font.color.set(0, 0, 0)
        bitmap.draw_text(-1, -1, 160, 20, "CRITICAL", 1)
        bitmap.draw_text(+1, -1, 160, 20, "CRITICAL", 1)
        bitmap.draw_text(-1, +1, 160, 20, "CRITICAL", 1)
        bitmap.draw_text(+1, +1, 160, 20, "CRITICAL", 1)
        bitmap.font.color.set(255, 255, 255)
        bitmap.draw_text(0, 0, 160, 20, "CRITICAL", 1)
      end
      @_damage_sprite = ::Sprite.new(self.viewport)
      @_damage_sprite.bitmap = bitmap
      @_damage_sprite.ox     = 80
      @_damage_sprite.oy     = 20
      @_damage_sprite.x      = self.x
      @_damage_sprite.y      = self.y - self.oy / 2
      @_damage_sprite.z      = 3000
      @_damage_duration      = 40
    end

    def pushAnimation(array, anim)
      for i in 0...array.length
        next if array[i] && array[i].active?
        array[i] = anim
        return
      end
      array.push(anim)
    end

    def animation(animation, hit, height = 3)
      anim = SpriteAnimation.new(self)
      anim.animation(animation,hit,height)
      pushAnimation(@animations,anim)
    end

    def loop_animation(animation)
      anim = SpriteAnimation.new(self)
      anim.loop_animation(animation)
      pushAnimation(@loopAnimations,anim)
    end

    def dispose_damage
      return if @_damage_sprite == nil
      @_damage_sprite.bitmap.dispose
      @_damage_sprite.dispose
      @_damage_sprite   = nil
      @_damage_duration = 0
    end

    def dispose_animation
      for a in @animations
        a.dispose_animation if a
      end
      @animations.clear
    end

    def dispose_loop_animation
      for a in @loopAnimations
        a.dispose_loop_animation if a
      end
      @loopAnimations.clear
    end

    def blink_on
      return if @_blink
      @_blink = true
      @_blink_count = 0
    end

    def blink_off
      return unless @_blink
      @_blink = false
      self.color.set(0, 0, 0, 0)
    end

    def blink?
      return @_blink
    end

    def effect?
      return true if @_whiten_duration > 0
      return true if @_appear_duration > 0
      return true if @_escape_duration > 0
      return true if @_collapse_duration > 0
      return true if @_damage_duration > 0
      for a in @animations
        return true if a.effect?
      end
      return false
    end

    def update
      super
      if @_whiten_duration > 0
        @_whiten_duration -= 1
        self.color.alpha = 128 - (16 - @_whiten_duration) * 10
      end
      if @_appear_duration > 0
        @_appear_duration -= 1
        self.opacity = (16 - @_appear_duration) * 16
      end
      if @_escape_duration > 0
        @_escape_duration -= 1
        self.opacity = 256 - (32 - @_escape_duration) * 10
      end
      if @_collapse_duration > 0
        @_collapse_duration -= 1
        self.opacity = 256 - (48 - @_collapse_duration) * 6
      end
      if @_damage_duration > 0
        @_damage_duration -= 1
        case @_damage_duration
        when 38..39
          @_damage_sprite.y -= 4
        when 36..37
          @_damage_sprite.y -= 2
        when 34..35
          @_damage_sprite.y += 2
        when 28..33
          @_damage_sprite.y += 4
        end
        @_damage_sprite.opacity = 256 - (12 - @_damage_duration) * 32
        if @_damage_duration == 0
          dispose_damage
        end
      end
      for a in @animations
        a.update
      end
      for a in @loopAnimations
        a.update
      end
      if @_blink
        @_blink_count = (@_blink_count + 1) % 32
        if @_blink_count < 16
          alpha = (16 - @_blink_count) * 6
        else
          alpha = (@_blink_count - 16) * 6
        end
        self.color.set(255, 255, 255, alpha)
      end
      SpriteAnimation.clear
    end

    def update_animation
      for a in @animations
        a.update_animation if a && a.active?
      end
    end

    def update_loop_animation
      for a in @loopAnimations
        a.update_loop_animation if a && a.active?
      end
    end

    def x=(x)
      for a in @animations
        a.x = x if a
      end
      for a in @loopAnimations
        a.x = x if a
      end
      super
    end

    def y=(y)
      for a in @animations
        a.y = y if a
      end
      for a in @loopAnimations
        a.y = y if a
      end
      super
    end
  end
end
