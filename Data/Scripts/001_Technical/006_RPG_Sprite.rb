#===============================================================================
# Additions to class Sprite that allows class AnimationContainerSprite to attach
# overworld animations to itself.
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
