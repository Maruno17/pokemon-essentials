class Spriteset_Global
  attr_reader :playersprite
  @@viewport2 = Viewport.new(0, 0, Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT)
  @@viewport2.z = 200

  def initialize
    @playersprite = Sprite_Character.new(Spriteset_Map.viewport, $game_player)
    @picture_sprites = []
    for i in 1..100
      @picture_sprites.push(Sprite_Picture.new(@@viewport2, $game_screen.pictures[i]))
    end
    @timer_sprite = Sprite_Timer.new
    update
  end

  def dispose
    @playersprite.dispose
    @picture_sprites.each { |sprite| sprite.dispose }
    @timer_sprite.dispose
    @playersprite = nil
    @picture_sprites.clear
    @timer_sprite = nil
  end

  def update
    @playersprite.update
    @picture_sprites.each { |sprite| sprite.update }
    @timer_sprite.update
  end
end
