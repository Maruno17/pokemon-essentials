class Spriteset_Global
  attr_reader :playersprite

  @@viewport2 = Viewport.new(0, 0, Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT)
  @@viewport2.z = 200

  def initialize
    @follower_sprites = FollowerSprites.new(Spriteset_Map.viewport)
    @playersprite = Sprite_Character.new(Spriteset_Map.viewport, $game_player)
    @picture_sprites = []
    (1..100).each do |i|
      @picture_sprites.push(Sprite_Picture.new(@@viewport2, $game_screen.pictures[i]))
    end
    @timer_sprite = Sprite_Timer.new
    update
  end

  def dispose
    @follower_sprites.dispose
    @follower_sprites = nil
    @playersprite.dispose
    @playersprite = nil
    @picture_sprites.each { |sprite| sprite.dispose }
    @picture_sprites.clear
    @timer_sprite.dispose
    @timer_sprite = nil
  end

  def update
    @follower_sprites.update
    @playersprite.update
    @picture_sprites.each { |sprite| sprite.update }
    @timer_sprite.update
  end
end
