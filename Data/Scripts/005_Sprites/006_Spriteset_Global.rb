class Spriteset_Global
  attr_reader :playersprite

  @@viewport2 = Viewport.new(0, 0, Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT)
  @@viewport2.z = 200

  def initialize
    @map_id = $game_map&.map_id || 0
    @follower_sprites = FollowerSprites.new(Spriteset_Map.viewport)
    @playersprite = Sprite_Character.new(Spriteset_Map.viewport, $game_player)
    @weather = RPG::Weather.new(Spriteset_Map.viewport)
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
    @weather.dispose
    @weather = nil
    @picture_sprites.each { |sprite| sprite.dispose }
    @picture_sprites.clear
    @timer_sprite.dispose
    @timer_sprite = nil
  end

  def update
    @follower_sprites.update
    @playersprite.update
    if @weather.type != $game_screen.weather_type
      @weather.fade_in($game_screen.weather_type, $game_screen.weather_max, $game_screen.weather_duration)
    end
    if @map_id != $game_map.map_id
      offsets = $map_factory.getRelativePos(@map_id, 0, 0, $game_map.map_id, 0, 0)
      if offsets == [0, 0]
        @weather.ox_offset = 0
        @weather.oy_offset = 0
      else
        @weather.ox_offset += offsets[0] * Game_Map::TILE_WIDTH
        @weather.oy_offset += offsets[1] * Game_Map::TILE_HEIGHT
      end
      @map_id = $game_map.map_id
    end
    @weather.ox = ($game_map.display_x / Game_Map::X_SUBPIXELS).round
    @weather.oy = ($game_map.display_y / Game_Map::Y_SUBPIXELS).round
    @weather.update
    @picture_sprites.each { |sprite| sprite.update }
    @timer_sprite.update
  end
end
