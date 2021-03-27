# All weather particles are assumed to start at the top/right and move to the
# bottom/left. Particles are only reset if they are off-screen to the left or
# bottom.
module RPG
  class Weather
    attr_reader :type
    attr_reader :max
    attr_reader :ox
    attr_reader :oy
    MAX_SPRITES              = 60
    FADE_OLD_TILES_START     = 0
    FADE_OLD_TILES_END       = 1
    FADE_OLD_TONE_START      = 0
    FADE_OLD_TONE_END        = 2
    FADE_OLD_PARTICLES_START = 1
    FADE_OLD_PARTICLES_END   = 3
    FADE_NEW_PARTICLES_START = 2
    FADE_NEW_PARTICLES_END   = 4
    FADE_NEW_TONE_START      = 3   # Shouldn't be sooner than FADE_OLD_TONE_END + 1
    FADE_NEW_TONE_END        = 5
    FADE_NEW_TILES_START     = 4   # Shouldn't be sooner than FADE_OLD_TILES_END
    FADE_NEW_TILES_END       = 5

    def initialize(viewport = nil)
      @viewport         = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport.z       = viewport.z + 1
      @origViewport     = viewport
      # [array of particle bitmaps, array of tile bitmaps,
      #  +x per second (particle), +y per second (particle), +opacity per second (particle),
      #  +x per second (tile), +y per second (tile)]
      @weatherTypes = []
      @weatherTypes[PBFieldWeather::None]      = nil
      @weatherTypes[PBFieldWeather::Rain]      = [[], nil, -1200, 4800, 0]
      @weatherTypes[PBFieldWeather::HeavyRain] = [[], nil, -4800, 4800, 0]
      @weatherTypes[PBFieldWeather::Storm]     = [[], nil, -4800, 4800, 0]
      @weatherTypes[PBFieldWeather::Snow]      = [[], nil, -240, 240, 0]
      @weatherTypes[PBFieldWeather::Blizzard]  = [[], [], -960, 256, 0, -1440, 720]
      @weatherTypes[PBFieldWeather::Sandstorm] = [[], [], -1200, 640, 0, -720, 360]
      @weatherTypes[PBFieldWeather::Sun]       = nil
      @weatherTypes[PBFieldWeather::Fog]       = [[], [], 0, 0, 0, -32, 0]
      @type                 = 0
      @max                  = 0
      @ox                   = 0
      @oy                   = 0
      @tiles_wide           = 0
      @tiles_tall           = 0
      @tile_x               = 0.0
      @tile_y               = 0.0
      @sun_magnitude        = 0   # +/- maximum addition to sun tone
      @sun_strength         = 0   # Current addition to sun tone (0 to @sun_magnitude)
      @time_until_flash     = 0
      @sprites              = []
      @sprite_lifetimes     = []
      @tiles                = []
      @new_sprites          = []
      @new_sprite_lifetimes = []
      @fading               = false
    end

    def dispose
      @sprites.each { |sprite| sprite.dispose if sprite }
      @new_sprites.each { |sprite| sprite.dispose if sprite }
      @tiles.each { |sprite| sprite.dispose if sprite }
      @viewport.dispose
      @weatherTypes.each do |weather|
        next if !weather
        weather[0].each { |bitmap| bitmap.dispose if bitmap }
        weather[1].each { |bitmap| bitmap.dispose if bitmap } if weather[1]
      end
    end

    def fade_in(new_type, new_max, duration = 1)
      return if @fading
      new_max = 0 if new_type == PBFieldWeather::None
      return if @type == new_type && @max == new_max
      if duration > 0
        @target_type = new_type
        @target_max = new_max
        prepare_bitmaps(@target_type)
        @old_max = @max
        @new_max = 0   # Current number of new particles
        @old_tone = Tone.new(@viewport.tone.red, @viewport.tone.green,
                             @viewport.tone.blue, @viewport.tone.gray)
        @target_tone = get_weather_tone(@target_type, @target_max)
        @fade_time = 0.0
        @time_shift = 0
        if @type == PBFieldWeather::None
          @time_shift += 2   # No previous weather to fade out first
        elsif !@weatherTypes[@type] || !@weatherTypes[@type][1] || @weatherTypes[@type][1].length == 0
          @time_shift += 1   # No previous tiles to fade out first
        end
        @fading = true
        @new_sprites.each { |sprite| sprite.dispose if sprite }
        @new_sprites.clear
        ensureSprites
        @new_sprites.each_with_index { |sprite, i| set_sprite_bitmap(sprite, i, @target_type) }
      else
        self.type = new_type
        self.max = new_max
      end
    end

    def type=(type)
      return if @type == type
      if @fading
        @max = @target_max
        @fading = false
      end
      @type = type
      prepare_bitmaps(@type)
      if @weatherTypes[@type] && @weatherTypes[@type][1] && @weatherTypes[@type][1].length > 0
        w = @weatherTypes[@type][1][0].width
        h = @weatherTypes[@type][1][0].height
        @tiles_wide = (Graphics.width.to_f / w).ceil + 1
        @tiles_tall = (Graphics.height.to_f / h).ceil + 1
      else
        @tiles_wide = @tiles_tall = 0
      end
      ensureSprites
      @sprites.each_with_index { |sprite, i| set_sprite_bitmap(sprite, i, @type) }
      ensureTiles
      @tiles.each_with_index { |sprite, i| set_tile_bitmap(sprite, i, @type) }
    end

    def max=(value)
      return if @max == value
      @max = value.clamp(0, MAX_SPRITES)
      ensureSprites
      for i in 0...MAX_SPRITES
        @sprites[i].visible = (i < @max) if @sprites[i]
      end
    end

    def ox=(value)
      return if value == @ox
      @ox = value
      @sprites.each { |sprite| sprite.ox = @ox if sprite }
      @new_sprites.each { |sprite| sprite.ox = @ox if sprite }
      @tiles.each { |sprite| sprite.ox = @ox if sprite }
    end

    def oy=(value)
      return if value == @oy
      @oy = value
      @sprites.each { |sprite| sprite.oy = @oy if sprite }
      @new_sprites.each { |sprite| sprite.oy = @oy if sprite }
      @tiles.each { |sprite| sprite.oy = @oy if sprite }
    end

    def get_weather_tone(weather_type, maximum)
      case weather_type
      when PBFieldWeather::Rain
        return Tone.new(-maximum * 3 / 4, -maximum * 3 / 4, -maximum * 3 / 4, 10)
      when PBFieldWeather::HeavyRain
        return Tone.new(-maximum * 6 / 4, -maximum * 6 / 4, -maximum * 6 / 4, 20)
      when PBFieldWeather::Storm
        return Tone.new(-maximum * 6 / 4, -maximum * 6 / 4, -maximum * 6 / 4, 20)
      when PBFieldWeather::Snow
        return Tone.new(     maximum / 2,      maximum / 2,      maximum / 2,  0)
      when PBFieldWeather::Blizzard
        return Tone.new( maximum * 3 / 4,  maximum * 3 / 4,  maximum * 3 / 4,  0)
      when PBFieldWeather::Sandstorm
        return Tone.new(     maximum / 2,             0,        -maximum / 2,  0)
      when PBFieldWeather::Sun
        return Tone.new(64, 64, 32, 0)
      end
      return Tone.new(0, 0, 0, 0)
    end

    def prepare_bitmaps(new_type)
      case new_type
      when PBFieldWeather::Rain                             then prepareRainBitmaps
      when PBFieldWeather::HeavyRain, PBFieldWeather::Storm then prepareStormBitmaps
      when PBFieldWeather::Snow                             then prepareSnowBitmaps
      when PBFieldWeather::Blizzard                         then prepareBlizzardBitmaps
      when PBFieldWeather::Sandstorm                        then prepareSandstormBitmaps
      when PBFieldWeather::Fog                              then prepareFogBitmaps
      end
    end

    def prepareRainBitmaps
      rain1 = RPG::Cache.load_bitmap("Graphics/Weather/", "rain_1")
      rain2 = RPG::Cache.load_bitmap("Graphics/Weather/", "rain_2")
      rain3 = RPG::Cache.load_bitmap("Graphics/Weather/", "rain_3")
      rain4 = RPG::Cache.load_bitmap("Graphics/Weather/", "rain_4")   # Splash
      @weatherTypes[PBFieldWeather::Rain][0] = [rain1, rain2, rain3, rain4]
    end

    def prepareStormBitmaps
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

    def prepareFogBitmaps
      fog_tile = RPG::Cache.load_bitmap("Graphics/Weather/", "fog_tile")
      @weatherTypes[PBFieldWeather::Fog][1] = [fog_tile]
    end

    def ensureSprites
      if @sprites.length < MAX_SPRITES && @weatherTypes[@type] &&
         @weatherTypes[@type][0] && @weatherTypes[@type][0].length > 0
        for i in 0...MAX_SPRITES
          if !@sprites[i]
            sprite = Sprite.new(@origViewport)
            sprite.z       = 1000
            sprite.ox      = @ox
            sprite.oy      = @oy
            sprite.opacity = 0
            @sprites[i] = sprite
          end
          @sprites[i].visible = (i < @max)
          @sprite_lifetimes[i] = 0
        end
      end
      if @fading && @new_sprites.length < MAX_SPRITES && @weatherTypes[@target_type] &&
         @weatherTypes[@target_type][0] && @weatherTypes[@target_type][0].length > 0
        for i in 0...MAX_SPRITES
          if !@new_sprites[i]
            sprite = Sprite.new(@origViewport)
            sprite.z       = 1000
            sprite.ox      = @ox
            sprite.oy      = @oy
            sprite.opacity = 0
            @new_sprites[i] = sprite
          end
          @new_sprites[i].visible = (i < @new_max)
          @new_sprite_lifetimes[i] = 0
        end
      end
    end

    def ensureTiles
      return if @tiles.length >= @tiles_wide * @tiles_tall
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

    def set_sprite_bitmap(sprite, index, weather_type)
      return if !sprite
      weatherBitmaps = (@weatherTypes[weather_type]) ? @weatherTypes[weather_type][0] : nil
      if !weatherBitmaps || weatherBitmaps.length == 0
        sprite.bitmap = nil
        return
      end
      case weather_type
      when PBFieldWeather::Rain, PBFieldWeather::HeavyRain, PBFieldWeather::Storm
        last_index = weatherBitmaps.length - 1   # Last sprite is splash
        if (index % 2) == 0
          sprite.bitmap = weatherBitmaps[index % last_index]
        else
          sprite.bitmap = weatherBitmaps[last_index]
        end
      else
        sprite.bitmap = weatherBitmaps[index % weatherBitmaps.length]
      end
    end

    def set_tile_bitmap(sprite, index, weather_type)
      return if !sprite || !weather_type
      weatherBitmaps = (@weatherTypes[weather_type]) ? @weatherTypes[weather_type][1] : nil
      if weatherBitmaps && weatherBitmaps.length > 0
        sprite.bitmap = weatherBitmaps[index % weatherBitmaps.length]
      else
        sprite.bitmap = nil
      end
    end

    def reset_sprite_position(sprite, index, is_new_sprite = false)
      weather_type = (is_new_sprite) ? @target_type : @type
      lifetimes = (is_new_sprite) ? @new_sprite_lifetimes : @sprite_lifetimes
      if index < (is_new_sprite ? @new_max : @max)
        sprite.visible = true
      else
        sprite.visible = false
        lifetimes[index] = 0
        return
      end
      if [PBFieldWeather::Rain, PBFieldWeather::HeavyRain,
         PBFieldWeather::Storm].include?(weather_type) && (index % 2) != 0   # Splash
        sprite.x = @ox - sprite.bitmap.width + rand(Graphics.width + sprite.bitmap.width * 2)
        sprite.y = @oy - sprite.bitmap.height + rand(Graphics.height + sprite.bitmap.height * 2)
        lifetimes[index] = (30 + rand(20)) * 0.01   # 0.3-0.5 seconds
      else
        gradient = @weatherTypes[weather_type][2].to_f / @weatherTypes[weather_type][3]
        if gradient.abs >= 1
          # Position sprite to the right of the screen
          sprite.x = @ox + Graphics.width + rand(Graphics.width)
          sprite.y = @oy + Graphics.height - rand(Graphics.height + sprite.bitmap.height - Graphics.width / gradient)
          distance_to_cover = sprite.x - @ox - Graphics.width / 2 + sprite.bitmap.width + rand(Graphics.width * 8 / 5)
          lifetimes[index] = (distance_to_cover.to_f / @weatherTypes[weather_type][2]).abs
        else
          # Position sprite to the top of the screen
          sprite.x = @ox - sprite.bitmap.width + rand(Graphics.width + sprite.bitmap.width - gradient * Graphics.height)
          sprite.y = @oy - sprite.bitmap.height - rand(Graphics.height)
          distance_to_cover = @oy - sprite.y + Graphics.height / 2 + rand(Graphics.height * 8 / 5)
          lifetimes[index] = (distance_to_cover.to_f / @weatherTypes[weather_type][3]).abs
        end
      end
      sprite.opacity = 255
    end

    def update_sprite_position(sprite, index, is_new_sprite = false)
      return if !sprite || !sprite.bitmap || !sprite.visible
      delta_t = Graphics.delta_s
      lifetimes = (is_new_sprite) ? @new_sprite_lifetimes : @sprite_lifetimes
      if lifetimes[index] >= 0
        lifetimes[index] -= delta_t
        if lifetimes[index] <= 0
          reset_sprite_position(sprite, index, is_new_sprite)
          return
        end
      end
      # Determine which weather type this sprite is representing
      weather_type = (is_new_sprite) ? @target_type : @type
      # Update visibility/position/opacity of sprite
      if [PBFieldWeather::Rain, PBFieldWeather::HeavyRain,
          PBFieldWeather::Storm].include?(weather_type) && (index % 2) != 0   # Splash
        sprite.opacity = (lifetimes[index] < 0.2) ? 255 : 0   # 0.2 seconds
      else
        dist_x = @weatherTypes[weather_type][2] * delta_t
        dist_y = @weatherTypes[weather_type][3] * delta_t
        sprite.x += dist_x
        sprite.y += dist_y
        if weather_type == PBFieldWeather::Snow
          sprite.x += dist_x * (sprite.y - @oy) / (Graphics.height * 3)   # Faster when further down screen
          sprite.x += [2, 1, 0, -1][rand(4)] * dist_x / 8   # Random movement
          sprite.y += [2, 1, 1, 0, 0, -1][index % 6] * dist_y / 10   # Variety
        end
        sprite.opacity += @weatherTypes[weather_type][4] * delta_t
        x = sprite.x - @ox
        y = sprite.y - @oy
        # Check if sprite is off-screen; if so, reset it
        if sprite.opacity < 64 || x < -sprite.bitmap.width || y > Graphics.height
          reset_sprite_position(sprite, index, is_new_sprite)
        end
      end
    end

    def recalculate_tile_positions
      delta_t = Graphics.delta_s
      weather_type = @type
      if @fading && @fade_time >= [FADE_OLD_TONE_END - @time_shift, 0].max
        weather_type = @target_type
      end
      @tile_x += @weatherTypes[weather_type][5] * delta_t
      @tile_y += @weatherTypes[weather_type][6] * delta_t
      if @tile_x < -@tiles_wide * @weatherTypes[weather_type][1][0].width
        @tile_x += @tiles_wide * @weatherTypes[weather_type][1][0].width
      end
      if @tile_y > @tiles_tall * @weatherTypes[weather_type][1][0].height
        @tile_y -= @tiles_tall * @weatherTypes[weather_type][1][0].height
      end
    end

    def update_tile_position(sprite, index)
      return if !sprite || !sprite.bitmap || !sprite.visible
      weather_type = @type
      if @fading && @fade_time >= [FADE_OLD_TONE_END - @time_shift, 0].max
        weather_type = @target_type
      end
      sprite.x = @ox + @tile_x + (index % @tiles_wide) * sprite.bitmap.width
      sprite.y = @oy + @tile_y + (index / @tiles_wide) * sprite.bitmap.height
      sprite.x += @tiles_wide * sprite.bitmap.width if sprite.x - @ox < -sprite.bitmap.width
      sprite.y -= @tiles_tall * sprite.bitmap.height if sprite.y - @oy > Graphics.height
      sprite.visible = true
      if @fading && @type != @target_type
        if @fade_time >= FADE_OLD_TILES_START && @fade_time < FADE_OLD_TILES_END
          if @time_shift == 0   # There were old tiles to fade out
            fraction = (@fade_time - [FADE_OLD_TILES_START - @time_shift, 0].max) / (FADE_OLD_TILES_END - FADE_OLD_TILES_START)
            sprite.opacity = 255 * (1 - fraction)
          end
        elsif @fade_time >= [FADE_NEW_TILES_START - @time_shift, 0].max &&
              @fade_time < [FADE_NEW_TILES_END - @time_shift, 0].max
          fraction = (@fade_time - [FADE_NEW_TILES_START - @time_shift, 0].max) / (FADE_NEW_TILES_END - FADE_NEW_TILES_START)
          sprite.opacity = 255 * fraction
        else
          sprite.opacity = 0
        end
      else
        sprite.opacity = (@max > 0) ? 255 : 0
      end
    end

    # Set tone of viewport (general screen brightening/darkening)
    def update_screen_tone
      weather_type = @type
      weather_max = @max
      fraction = 1
      tone_red = 0
      tone_green = 0
      tone_blue = 0
      tone_gray = 0
      # Get base tone
      if @fading
        if @type == @target_type   # Just changing max
          if @fade_time >= [FADE_NEW_TONE_START - @time_shift, 0].max &&
             @fade_time < [FADE_NEW_TONE_END - @time_shift, 0].max
            weather_max = @target_max
            fract = (@fade_time - [FADE_NEW_TONE_START - @time_shift, 0].max) / (FADE_NEW_TONE_END - FADE_NEW_TONE_START)
            tone_red = @target_tone.red + (1 - fract) * (@old_tone.red - @target_tone.red)
            tone_green = @target_tone.green + (1 - fract) * (@old_tone.green - @target_tone.green)
            tone_blue = @target_tone.blue + (1 - fract) * (@old_tone.blue - @target_tone.blue)
            tone_gray = @target_tone.gray + (1 - fract) * (@old_tone.gray - @target_tone.gray)
          else
            tone_red = @viewport.tone.red
            tone_green = @viewport.tone.green
            tone_blue = @viewport.tone.blue
            tone_gray = @viewport.tone.gray
          end
        elsif @time_shift < 2 && @fade_time >= FADE_OLD_TONE_START && @fade_time < FADE_OLD_TONE_END
          weather_max = @old_max
          fraction = ((@fade_time - FADE_OLD_TONE_START) / (FADE_OLD_TONE_END - FADE_OLD_TONE_START)).clamp(0, 1)
          fraction = 1 - fraction
          tone_red = @old_tone.red
          tone_green = @old_tone.green
          tone_blue = @old_tone.blue
          tone_gray = @old_tone.gray
        elsif @fade_time >= [FADE_NEW_TONE_START - @time_shift, 0].max
          weather_type = @target_type
          weather_max = @target_max
          fraction = ((@fade_time - [FADE_NEW_TONE_START - @time_shift, 0].max) / (FADE_NEW_TONE_END - FADE_NEW_TONE_START)).clamp(0, 1)
          tone_red = @target_tone.red
          tone_green = @target_tone.green
          tone_blue = @target_tone.blue
          tone_gray = @target_tone.gray
        end
      else
        base_tone = get_weather_tone(weather_type, weather_max)
        tone_red = base_tone.red
        tone_green = base_tone.green
        tone_blue = base_tone.blue
        tone_gray = base_tone.gray
      end
      # Modify base tone
      if weather_type == PBFieldWeather::Sun
        @sun_magnitude = weather_max if @sun_magnitude != weather_max && @sun_magnitude != -weather_max
        @sun_magnitude *= -1 if (@sun_magnitude > 0 && @sun_strength > @sun_magnitude) ||
                                (@sun_magnitude < 0 && @sun_strength < 0)
        @sun_strength += @sun_magnitude.to_f * Graphics.delta_s * 0.4   # 0.4 seconds
        tone_red += @sun_strength
        tone_green += @sun_strength
        tone_blue += @sun_strength / 2
      end
      # Apply screen tone
      @viewport.tone.set(tone_red * fraction, tone_green * fraction,
                         tone_blue * fraction, tone_gray * fraction)
    end

    def update_fading
      return if !@fading
      old_fade_time = @fade_time
      @fade_time += Graphics.delta_s
      # Change tile bitmaps
      if @type != @target_type
        tile_change_threshold = [FADE_OLD_TONE_END - @time_shift, 0].max
        if old_fade_time <= tile_change_threshold && @fade_time > tile_change_threshold
          @tile_x = @tile_y = 0.0
          if @weatherTypes[@target_type] && @weatherTypes[@target_type][1] && @weatherTypes[@target_type][1].length > 0
            w = @weatherTypes[@target_type][1][0].width
            h = @weatherTypes[@target_type][1][0].height
            @tiles_wide = (Graphics.width.to_f / w).ceil + 1
            @tiles_tall = (Graphics.height.to_f / h).ceil + 1
            ensureTiles
            @tiles.each_with_index { |sprite, i| set_tile_bitmap(sprite, i, @target_type) }
          else
            @tiles_wide = @tiles_tall = 0
          end
        end
      end
      # Reduce the number of old weather particles
      if @max > 0 && @fade_time >= [FADE_OLD_PARTICLES_START - @time_shift, 0].max
        fraction = (@fade_time - [FADE_OLD_PARTICLES_START - @time_shift, 0].max) / (FADE_OLD_PARTICLES_END - FADE_OLD_PARTICLES_START)
        @max = @old_max * (1 - fraction)
        # NOTE: Sprite visibilities aren't updated here; a sprite is allowed to
        #       die off naturally in def reset_sprite_position.
      end
      # Increase the number of new weather particles
      if @new_max < @target_max && @fade_time >= [FADE_NEW_PARTICLES_START - @time_shift, 0].max
        fraction = (@fade_time - [FADE_NEW_PARTICLES_START - @time_shift, 0].max) / (FADE_NEW_PARTICLES_END - FADE_NEW_PARTICLES_START)
        @new_max = (@target_max * fraction).floor
        @new_sprites.each_with_index { |sprite, i| sprite.visible = (i < @new_max) if sprite }
      end
      # End fading
      if @fade_time >= ((@target_type == PBFieldWeather::None) ? FADE_OLD_PARTICLES_END : FADE_NEW_TILES_END) - @time_shift
        if !@sprites.any? { |sprite| sprite.visible }
          @type                 = @target_type
          @max                  = @target_max
          @target_type          = nil
          @target_max           = nil
          @old_max              = nil
          @new_max              = nil
          @old_tone             = nil
          @target_tone          = nil
          @fade_time            = 0.0
          @time_shift           = 0
          @sprites.each { |sprite| sprite.dispose if sprite }
          @sprites              = @new_sprites
          @new_sprites          = []
          @sprite_lifetimes     = @new_sprite_lifetimes
          @new_sprite_lifetimes = []
          @fading               = false
        end
      end
    end

    def update
      update_fading
      update_screen_tone
      # Storm flashes
      if @type == PBFieldWeather::Storm && !@fading
        if @time_until_flash > 0
          @time_until_flash -= Graphics.delta_s
          if @time_until_flash <= 0
            @viewport.flash(Color.new(255, 255, 255, 230), (2 + rand(3)) * 20)
          end
        end
        if @time_until_flash <= 0
          @time_until_flash = (1 + rand(12)) * 0.5   # 0.5-6 seconds
        end
      end
      @viewport.update
      # Update weather particles (raindrops, snowflakes, etc.)
      if @weatherTypes[@type] && @weatherTypes[@type][0] && @weatherTypes[@type][0].length > 0
        ensureSprites
        for i in 0...MAX_SPRITES
          update_sprite_position(@sprites[i], i, false)
        end
      elsif @sprites.length > 0
        @sprites.each { |sprite| sprite.dispose if sprite }
        @sprites.clear
      end
      # Update new weather particles (while fading in only)
      if @fading && @weatherTypes[@target_type] && @weatherTypes[@target_type][0] && @weatherTypes[@target_type][0].length > 0
        ensureSprites
        for i in 0...MAX_SPRITES
          update_sprite_position(@new_sprites[i], i, true)
        end
      elsif @new_sprites.length > 0
        @new_sprites.each { |sprite| sprite.dispose if sprite }
        @new_sprites.clear
      end
      # Update weather tiles (sandstorm/blizzard tiled overlay)
      if @tiles_wide > 0 && @tiles_tall > 0
        ensureTiles
        recalculate_tile_positions
        @tiles.each_with_index { |sprite, i| update_tile_position(sprite, i) }
      elsif @tiles.length > 0
        @tiles.each { |sprite| sprite.dispose if sprite }
        @tiles.clear
      end
    end
  end
end
