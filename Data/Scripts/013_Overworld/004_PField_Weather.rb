# All weather particles are assumed to start at the top/right and move to the
# bottom/left. Particles are only reset if they are off-screen to the left or
# bottom.
module RPG
  class Weather
    attr_reader :type
    attr_reader :max
    attr_reader :ox
    attr_reader :oy
    MAX_SPRITES = 60

    def initialize(viewport = nil)
      @viewport     = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport.z   = viewport.z + 1
      @origViewport = viewport
      @type         = 0
      @max          = 0
      @ox           = 0
      @oy           = 0
      @tiles_wide   = 0
      @tiles_tall   = 0
      @sun          = 0
      @sunValue     = 0
      @time_until_flash = 0
      # [array of particle bitmaps, array of tile bitmaps,
      #  +x per second (particle), +y per second (particle), +opacity per second (particle),
      #  +x per second (tile), +y per second (tile)]
      @weatherTypes = []
      @weatherTypes[PBFieldWeather::None]      = nil
      @weatherTypes[PBFieldWeather::Rain]      = [[], nil, -1200, 4800, 0]
      @weatherTypes[PBFieldWeather::HeavyRain] = [[], nil, -4800, 4800, 0]
      @weatherTypes[PBFieldWeather::Storm]     = [[], nil, -4800, 4800, 0]
      @weatherTypes[PBFieldWeather::Snow]      = [[], nil, -240, 240, 0]
      @weatherTypes[PBFieldWeather::Blizzard]  = [[], [], -960, 64, 0, -1440, 720]
      @weatherTypes[PBFieldWeather::Sandstorm] = [[], [], -1200, 640, 0, -720, 360]
      @weatherTypes[PBFieldWeather::Sun]       = nil
      @sprites = []
      @sprite_lifetimes = []
      @tiles = []
    end

    def dispose
      @sprites.each { |sprite| sprite.dispose if sprite }
      @tiles.each { |sprite| sprite.dispose if sprite }
      @viewport.dispose
      @weatherTypes.each do |weather|
        next if !weather
        weather[0].each { |bitmap| bitmap.dispose if bitmap }
        weather[1].each { |bitmap| bitmap.dispose if bitmap } if weather[1]
      end
    end

    def type=(type)
      return if @type == type
      @type = type
      case @type
      when PBFieldWeather::None
        @sprites.each { |sprite| sprite.dispose if sprite }
        @sprites.clear
        @tiles.each { |sprite| sprite.dispose if sprite }
        @tiles.clear
        @tiles_wide = @tiles_tall = 0
        return
      when PBFieldWeather::Rain                             then prepareRainBitmap
      when PBFieldWeather::HeavyRain, PBFieldWeather::Storm then prepareStormBitmap
      when PBFieldWeather::Snow                             then prepareSnowBitmaps
      when PBFieldWeather::Blizzard                         then prepareBlizzardBitmaps
      when PBFieldWeather::Sandstorm                        then prepareSandstormBitmaps
      end
      if @weatherTypes[@type] && @weatherTypes[@type][1] && @weatherTypes[@type][1].length > 0
        w = @weatherTypes[@type][1][0].width
        h = @weatherTypes[@type][1][0].height
        @tiles_wide = (Graphics.width.to_f / w).ceil + 1
        @tiles_tall = (Graphics.height.to_f / h).ceil + 1
      else
        @tiles_wide = @tiles_tall = 0
      end
      ensureSprites
      @sprites.each_with_index { |sprite, i| set_sprite_bitmap(sprite, i) }
      @tiles.each_with_index { |sprite, i| set_tile_bitmap(sprite, i) }
    end

    def set_sprite_bitmap(sprite, index)
      return if !sprite
      weatherBitmaps = (@weatherTypes[@type]) ? @weatherTypes[@type][0] : nil
      if !weatherBitmaps
        sprite.bitmap = nil
        return
      end
      case @type
      when PBFieldWeather::Rain, PBFieldWeather::HeavyRain, PBFieldWeather::Storm
        last_index = weatherBitmaps.length - 1   # Last sprite is splash
        if index % 2 == 0
          sprite.bitmap = weatherBitmaps[index % last_index]
        else
          sprite.bitmap = weatherBitmaps[last_index]
        end
      else
        sprite.bitmap = weatherBitmaps[index % weatherBitmaps.length]
      end
    end

    def set_tile_bitmap(sprite, index)
      return if !sprite
      weatherBitmaps = (@weatherTypes[@type]) ? @weatherTypes[@type][1] : nil
      if !weatherBitmaps || weatherBitmaps.length == 0
        sprite.bitmap = nil
        return
      end
      sprite.bitmap = weatherBitmaps[index % weatherBitmaps.length]
      reset_tile_position(sprite, index)
    end

    def max=(value)
      return if @max == value
      @max = value.clamp(0, MAX_SPRITES)
      if @max == 0
        @sprites.each { |sprite| sprite.dispose if sprite }
        @sprites.clear
        @tiles.each { |sprite| sprite.dispose if sprite }
        @tiles.clear
      else
        @sprites.each_with_index { |sprite, i| sprite.visible = (i <= @max) if sprite }
      end
    end

    def ox=(value)
      return if value == @ox
      @ox = value
      @sprites.each { |sprite| sprite.ox = @ox if sprite }
      @tiles.each { |sprite| sprite.ox = @ox if sprite }
    end

    def oy=(value)
      return if value == @oy
      @oy = value
      @sprites.each { |sprite| sprite.oy = @oy if sprite }
      @tiles.each { |sprite| sprite.oy = @oy if sprite }
    end

    def prepareRainBitmap
      rain1 = RPG::Cache.load_bitmap("Graphics/Weather/", "rain_1")
      rain2 = RPG::Cache.load_bitmap("Graphics/Weather/", "rain_2")
      rain3 = RPG::Cache.load_bitmap("Graphics/Weather/", "rain_3")
      rain4 = RPG::Cache.load_bitmap("Graphics/Weather/", "rain_4")   # Splash
      @weatherTypes[PBFieldWeather::Rain][0] = [rain1, rain2, rain3, rain4]
    end

    def prepareStormBitmap
      storm1 = RPG::Cache.load_bitmap("Graphics/Weather/", "storm_1")
      storm2 = RPG::Cache.load_bitmap("Graphics/Weather/", "storm_2")
      storm3 = RPG::Cache.load_bitmap("Graphics/Weather/", "storm_3")
      storm4 = RPG::Cache.load_bitmap("Graphics/Weather/", "storm_4")   # Splash
      @weatherTypes[PBFieldWeather::HeavyRain][0] = [storm1, storm2, storm3, storm4]
      @weatherTypes[PBFieldWeather::Storm][0] = [storm1, storm2, storm3, storm4]
    end

    def prepareSnowBitmaps
      hail1 = RPG::Cache.load_bitmap("Graphics/Weather/", "hail_1")
      hail2 = RPG::Cache.load_bitmap("Graphics/Weather/", "hail_2")
      hail3 = RPG::Cache.load_bitmap("Graphics/Weather/", "hail_3")
      @weatherTypes[PBFieldWeather::Snow][0] = [hail1, hail2, hail3]
    end

    def prepareBlizzardBitmaps
      blizzard1 = RPG::Cache.load_bitmap("Graphics/Weather/", "blizzard_1")
      blizzard2 = RPG::Cache.load_bitmap("Graphics/Weather/", "blizzard_2")
      blizzard3 = RPG::Cache.load_bitmap("Graphics/Weather/", "blizzard_3")
      blizzard4 = RPG::Cache.load_bitmap("Graphics/Weather/", "blizzard_4")
      @weatherTypes[PBFieldWeather::Blizzard][0] = [blizzard1, blizzard2, blizzard3, blizzard4]
      blizzard_tile = RPG::Cache.load_bitmap("Graphics/Weather/", "blizzard_tile")
      @weatherTypes[PBFieldWeather::Blizzard][1] = [blizzard_tile]
    end

    def prepareSandstormBitmaps
      sandstorm1 = RPG::Cache.load_bitmap("Graphics/Weather/", "sandstorm_1")
      sandstorm2 = RPG::Cache.load_bitmap("Graphics/Weather/", "sandstorm_2")
      sandstorm3 = RPG::Cache.load_bitmap("Graphics/Weather/", "sandstorm_3")
      sandstorm4 = RPG::Cache.load_bitmap("Graphics/Weather/", "sandstorm_4")
      @weatherTypes[PBFieldWeather::Sandstorm][0] = [sandstorm1, sandstorm2, sandstorm3, sandstorm4]
      sandstorm_tile = RPG::Cache.load_bitmap("Graphics/Weather/", "sandstorm_tile")
      @weatherTypes[PBFieldWeather::Sandstorm][1] = [sandstorm_tile]
    end

    def ensureSprites
      if @sprites.length < MAX_SPRITES
        for i in 0...MAX_SPRITES
          if !@sprites[i]
            sprite = Sprite.new(@origViewport)
            sprite.z       = 1000
            sprite.ox      = @ox
            sprite.oy      = @oy
            sprite.opacity = 0
            @sprites[i] = sprite
          end
          @sprites[i].visible = (i <= @max)
          @sprite_lifetimes[i] = 0
        end
      end
      if @tiles.length < @tiles_wide * @tiles_tall
        for i in 0...(@tiles_wide * @tiles_tall)
          if !@tiles[i]
            sprite = Sprite.new(@origViewport)
            sprite.z       = 1000
            sprite.ox      = @ox
            sprite.oy      = @oy
            sprite.opacity = 0
            @tiles[i] = sprite
          end
          @tiles[i].visible = true
        end
      end
    end

    def reset_sprite_position(sprite, index)
      if [PBFieldWeather::Rain, PBFieldWeather::HeavyRain, PBFieldWeather::Storm].include?(@type) && index % 2 != 0   # Splash
        sprite.x = @ox - sprite.bitmap.width + rand(Graphics.width + sprite.bitmap.width * 2)
        sprite.y = @oy - sprite.bitmap.height + rand(Graphics.height + sprite.bitmap.height * 2)
        @sprite_lifetimes[index] = (30 + rand(20)) * 10_000   # 0.3-0.5 seconds
      else
        gradient = @weatherTypes[@type][2].to_f / @weatherTypes[@type][3]
        sprite.x = @ox - sprite.bitmap.width + rand(Graphics.width + sprite.bitmap.width * 2 - gradient * Graphics.height)
        sprite.y = @oy - sprite.bitmap.height - rand(Graphics.height)
        @sprite_lifetimes[index] = 1_000_000 * (@oy - sprite.y + rand(Graphics.height * 8 / 5)) / @weatherTypes[@type][3]
      end
      sprite.opacity = 255
    end

    def update_sprite_position(sprite, index)
      return if !sprite
      delta_t = Graphics.delta
      if @sprite_lifetimes[index] > 0
        @sprite_lifetimes[index] -= delta_t
        if @sprite_lifetimes[index] <= 0
          reset_sprite_position(sprite, index)
          return
        end
      end
      if [PBFieldWeather::Rain, PBFieldWeather::HeavyRain, PBFieldWeather::Storm].include?(@type) && index % 2 != 0   # Splash
        sprite.visible = (@sprite_lifetimes[index] < 200_000)   # 0.2 seconds
      else
        sprite.x += @weatherTypes[@type][2] * delta_t / 1_000_000
        sprite.y += @weatherTypes[@type][3] * delta_t / 1_000_000
        if @type == PBFieldWeather::Snow || @type == PBFieldWeather::Blizzard
          sprite.x -= (4 * (sprite.y - @oy)) / Graphics.height
          sprite.x -= [2, 1, 0, -1][rand(4)]
          sprite.y += index % 6
        end
        sprite.opacity += @weatherTypes[@type][4] * delta_t / 1_000_000
      end
      x = sprite.x - @ox
      y = sprite.y - @oy
      # Check if sprite is off-screen; if so, reset it
      if sprite.opacity < 64 || x < -sprite.bitmap.width || y > Graphics.height
        reset_sprite_position(sprite, index)
      end
    end

    def reset_tile_position(sprite, index)
      sprite.x = @ox + (index % @tiles_wide) * sprite.bitmap.width
      sprite.y = @oy + (index / @tiles_wide) * sprite.bitmap.height
    end

    def update_tile_position(sprite, index)
      return if !sprite || !sprite.bitmap
      delta_t = Graphics.delta
      if @tiles_wide > 0 && @tiles_tall > 0
        sprite.x += @weatherTypes[@type][5] * delta_t / 1_000_000
        sprite.y += @weatherTypes[@type][6] * delta_t / 1_000_000
        sprite.x += @tiles_wide * sprite.bitmap.width if sprite.x - @ox + sprite.bitmap.width < 0
        sprite.y -= @tiles_tall * sprite.bitmap.height if sprite.y - @oy > Graphics.height
        sprite.visible = true
        sprite.opacity = 255
      else
        sprite.visible = false
      end
    end

    # Set tone of viewport (general screen brightening/darkening)
    def update_screen_tone
      # @max is (power+1)*MAX_SPRITES/10, where power is between 1 and 9
      case @type
      when PBFieldWeather::None
        @viewport.tone.set(0, 0, 0, 0)
      when PBFieldWeather::Rain
        @viewport.tone.set(-@max * 3 / 4, -@max * 3 / 4, -@max * 3 / 4, 10)
      when PBFieldWeather::HeavyRain
        @viewport.tone.set(-@max * 6 / 4, -@max * 6 / 4, -@max * 6 / 4, 20)
      when PBFieldWeather::Storm
        @viewport.tone.set(-@max * 6 / 4, -@max * 6 / 4, -@max * 6 / 4, 20)
      when PBFieldWeather::Snow
        @viewport.tone.set(     @max / 2,      @max / 2,      @max / 2,  0)
      when PBFieldWeather::Blizzard
        @viewport.tone.set( @max * 3 / 4,  @max * 3 / 4,   max * 3 / 4,  0)
      when PBFieldWeather::Sandstorm
        @viewport.tone.set(     @max / 2,             0,     -@max / 2,  0)
      when PBFieldWeather::Sun
        @sun = @max if @sun != @max && @sun != -@max
        @sun *= -1 if (@sun > 0 && @sunValue > @max) || (@sun < 0 && @sunValue < 0)
        @sunValue += @sun.to_f * Graphics.delta / 400_000   # 0.4 seconds
        @viewport.tone.set(@sunValue + 63, @sunValue + 63, @sunValue / 2 + 31, 0)
      end
    end

    def update
      # @max is (power+1)*MAX_SPRITES/10, where power is between 1 and 9
      update_screen_tone
      # Storm flashes
      if @type == PBFieldWeather::Storm
        if @time_until_flash > 0
          @time_until_flash -= Graphics.delta
          if @time_until_flash <= 0
            @viewport.flash(Color.new(255, 255, 255, 230), (2 + rand(3)) * 20)
          end
        end
        if @time_until_flash <= 0
          @time_until_flash = (1 + rand(12)) * 500_000   # 0.5-6 seconds
        end
      end
      @viewport.update
      # Update weather particles (raindrops, snowflakes, etc.)
      if @weatherTypes[@type]
        ensureSprites
        for i in 0...@max
          update_sprite_position(@sprites[i], i)
        end
        @tiles.each_with_index { |sprite, i| update_tile_position(sprite, i) }
      end
    end
  end
end
