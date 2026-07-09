#===============================================================================
# Category has the following effects:
#   - Determines the in-battle weather.
#   - Some abilities reduce the encounter rate in certain categories of weather.
#   - Some evolution methods check the current weather's category.
#   - The :Rain category treats the last listed particle graphic as a water splash rather
#     than a raindrop, which behaves differently.
#   - :Rain auto-waters berry plants.
# Delta values are per second.
# For the tone_proc, strength goes from 0 to RPG::Weather::MAX_SPRITES (60) and
# will typically be the maximum.
#===============================================================================
module GameData
  class Weather
    attr_reader :id
    attr_reader :id_number
    attr_reader :real_name
    attr_reader :category   # :None, :Rain, :Hail, :Sandstorm, :Sun, :Fog
    attr_reader :graphics   # [[particle file names], [tile file names]]
    attr_reader :particle_delta_x
    attr_reader :particle_delta_y
    attr_reader :particle_delta_opacity
    attr_reader :tile_delta_x
    attr_reader :tile_delta_y
    attr_reader :tone_proc

    DATA = {}

    extend ClassMethods
    include InstanceMethods

    def self.load; end
    def self.save; end

    #---------------------------------------------------------------------------

    def initialize(hash)
      @id                     = hash[:id]
      @id_number              = hash[:id_number]
      @real_name              = hash[:id].to_s                || "Unnamed"
      @category               = hash[:category]               || :None
      @particle_delta_x       = hash[:particle_delta_x]       || 0
      @particle_delta_y       = hash[:particle_delta_y]       || 0
      @particle_delta_opacity = hash[:particle_delta_opacity] || 0
      @tile_delta_x           = hash[:tile_delta_x]           || 0
      @tile_delta_y           = hash[:tile_delta_y]           || 0
      @graphics               = hash[:graphics]               || []
      @tone_proc              = hash[:tone_proc]
    end

    alias name real_name

    def has_particles?
      return @graphics[0] && @graphics[0].length > 0
    end

    def has_tiles?
      return @graphics[1] && @graphics[1].length > 0
    end

    def tone(strength)
      return (@tone_proc) ? @tone_proc.call(strength) : Tone.new(0, 0, 0, 0)
    end
  end
end

#===============================================================================
#
#===============================================================================

GameData::Weather.register({
  :id               => :None,
  :id_number        => 0   # Must be 0 (preset RMXP weather)
})

GameData::Weather.register({
  :id               => :Rain,
  :id_number        => 1,   # Must be 1 (preset RMXP weather)
  :category         => :Rain,
  :graphics         => [["rain_1", "rain_2", "rain_3", "rain_4"]],   # Last is splash
  :particle_delta_x => -600,
  :particle_delta_y => 2400,
  :tone_proc        => proc { |strength|
    next Tone.new(-strength / 2, -strength / 2, -strength / 2, 10)
  }
})

# NOTE: This randomly flashes the screen in RPG::Weather#update.
GameData::Weather.register({
  :id               => :Storm,
  :id_number        => 2,   # Must be 2 (preset RMXP weather)
  :category         => :Rain,
  :graphics         => [["storm_1", "storm_2", "storm_3", "storm_4"]],   # Last is splash
  :particle_delta_x => -3600,
  :particle_delta_y => 3600,
  :tone_proc        => proc { |strength|
    next Tone.new(-strength * 3 / 4, -strength * 3 / 4, -strength * 3 / 4, 10)
  }
})

# NOTE: This alters the movement of snow particles in RPG::Weather#update_sprite_position.
GameData::Weather.register({
  :id               => :Snow,
  :id_number        => 3,   # Must be 3 (preset RMXP weather)
  :category         => :Hail,
  :graphics         => [["hail_1", "hail_2", "hail_3"]],
  :particle_delta_x => -240,
  :particle_delta_y => 240,
  :tone_proc        => proc { |strength|
    next Tone.new(strength / 2, strength / 2, strength / 2, 0)
  }
})

GameData::Weather.register({
  :id               => :Blizzard,
  :id_number        => 4,
  :category         => :Hail,
  :graphics         => [["blizzard_1", "blizzard_2", "blizzard_3", "blizzard_4"], ["blizzard_tile"]],
  :particle_delta_x => -720,
  :particle_delta_y => 240,
  :tile_delta_x     => -1200,
  :tile_delta_y     => 600,
  :tone_proc        => proc { |strength|
    next Tone.new(strength * 3 / 4, strength * 3 / 4, strength * 3 / 4, 0)
  }
})

GameData::Weather.register({
  :id               => :Sandstorm,
  :id_number        => 5,
  :category         => :Sandstorm,
  :graphics         => [["sandstorm_1", "sandstorm_2", "sandstorm_3", "sandstorm_4"], ["sandstorm_tile"]],
  :particle_delta_x => -1200,
  :particle_delta_y => 640,
  :tile_delta_x     => -800,
  :tile_delta_y     => 400,
  :tone_proc        => proc { |strength|
    next Tone.new(strength / 2, 0, -strength / 2, 0)
  }
})

GameData::Weather.register({
  :id               => :HeavyRain,
  :id_number        => 6,
  :category         => :Rain,
  :graphics         => [["storm_1", "storm_2", "storm_3", "storm_4"]],   # Last is splash
  :particle_delta_x => -3600,
  :particle_delta_y => 3600,
  :tone_proc        => proc { |strength|
    next Tone.new(-strength * 3 / 4, -strength * 3 / 4, -strength * 3 / 4, 10)
  }
})

# NOTE: This alters the screen tone in RPG::Weather#update_screen_tone.
GameData::Weather.register({
  :id               => :Sun,
  :id_number        => 7,
  :category         => :Sun,
  :tone_proc        => proc { |strength|
    next Tone.new(64, 64, 32, 0)
  }
})

GameData::Weather.register({
  :id               => :Fog,
  :category         => :Fog,
  :id_number        => 8,
  :tile_delta_x     => -32,
  :tile_delta_y     => 0,
  :graphics         => [nil, ["fog_tile"]]
})
