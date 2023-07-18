#===============================================================================
# ** Game_Map
#------------------------------------------------------------------------------
#  This class handles the map. It includes scrolling and passable determining
#  functions. Refer to "$game_map" for the instance of this class.
#===============================================================================
class Game_Map
  attr_accessor :map_id
  attr_accessor :tileset_name             # tileset file name
  attr_accessor :autotile_names           # autotile file name
  attr_reader   :passages                 # passage table
  attr_reader   :priorities               # priority table
  attr_reader   :terrain_tags             # terrain tag table
  attr_reader   :events                   # events
  attr_accessor :panorama_name            # panorama file name
  attr_accessor :panorama_hue             # panorama hue
  attr_accessor :fog_name                 # fog file name
  attr_accessor :fog_hue                  # fog hue
  attr_accessor :fog_opacity              # fog opacity level
  attr_accessor :fog_blend_type           # fog blending method
  attr_accessor :fog_zoom                 # fog zoom rate
  attr_accessor :fog_sx                   # fog sx
  attr_accessor :fog_sy                   # fog sy
  attr_reader   :fog_ox                   # fog x-coordinate starting point
  attr_reader   :fog_oy                   # fog y-coordinate starting point
  attr_reader   :fog_tone                 # fog color tone
  attr_accessor :battleback_name          # battleback file name
  attr_reader   :display_x                # display x-coordinate * 128
  attr_reader   :display_y                # display y-coordinate * 128
  attr_accessor :need_refresh             # refresh request flag

  TILE_WIDTH  = 32
  TILE_HEIGHT = 32
  X_SUBPIXELS = 4
  Y_SUBPIXELS = 4
  REAL_RES_X  = TILE_WIDTH * X_SUBPIXELS
  REAL_RES_Y  = TILE_HEIGHT * Y_SUBPIXELS

  def initialize
    @map_id = 0
    @display_x = 0
    @display_y = 0
  end

  def setup(map_id)
    @map_id = map_id
    @map = load_data(sprintf("Data/Map%03d.rxdata", map_id))
    tileset = $data_tilesets[@map.tileset_id]
    updateTileset
    @fog_ox                  = 0
    @fog_oy                  = 0
    @fog_tone                = Tone.new(0, 0, 0, 0)
    @fog_tone_target         = Tone.new(0, 0, 0, 0)
    @fog_tone_duration       = 0
    @fog_tone_timer_start    = nil
    @fog_opacity_duration    = 0
    @fog_opacity_target      = 0
    @fog_opacity_timer_start = nil
    self.display_x           = 0
    self.display_y           = 0
    @need_refresh            = false
    EventHandlers.trigger(:on_game_map_setup, map_id, @map, tileset)
    @events                  = {}
    @map.events.each_key do |i|
      @events[i]             = Game_Event.new(@map_id, @map.events[i], self)
    end
    @common_events           = {}
    (1...$data_common_events.size).each do |i|
      @common_events[i]      = Game_CommonEvent.new(i)
    end
    @scroll_distance_x       = 0
    @scroll_distance_y       = 0
    @scroll_speed            = 4
  end

  def updateTileset
    tileset = $data_tilesets[@map.tileset_id]
    @tileset_name    = tileset.tileset_name
    @autotile_names  = tileset.autotile_names
    @panorama_name   = tileset.panorama_name
    @panorama_hue    = tileset.panorama_hue
    @fog_name        = tileset.fog_name
    @fog_hue         = tileset.fog_hue
    @fog_opacity     = tileset.fog_opacity
    @fog_blend_type  = tileset.fog_blend_type
    @fog_zoom        = tileset.fog_zoom
    @fog_sx          = tileset.fog_sx
    @fog_sy          = tileset.fog_sy
    @battleback_name = tileset.battleback_name
    @passages        = tileset.passages
    @priorities      = tileset.priorities
    @terrain_tags    = tileset.terrain_tags
  end

  def width;          return @map.width;          end
  def height;         return @map.height;         end
  def encounter_list; return @map.encounter_list; end
  def encounter_step; return @map.encounter_step; end
  def data;           return @map.data;           end
  def tileset_id;     return @map.tileset_id;     end
  def bgm;            return @map.bgm;            end

  def name
    return pbGetMapNameFromId(@map_id)
  end

  def metadata
    return GameData::MapMetadata.try_get(@map_id)
  end

  # Returns the name of this map's BGM. If it's night time, returns the night
  # version of the BGM (if it exists).
  def bgm_name
    if PBDayNight.isNight? && FileTest.audio_exist?("Audio/BGM/" + @map.bgm.name + "_n")
      return @map.bgm.name + "_n"
    end
    return @map.bgm.name
  end

  # Autoplays background music
  # Plays music called "[normal BGM]_n" if it's night time and it exists
  def autoplayAsCue
    pbCueBGM(bgm_name, 1.0, @map.bgm.volume, @map.bgm.pitch) if @map.autoplay_bgm
    pbBGSPlay(@map.bgs) if @map.autoplay_bgs
  end

  # Plays background music
  # Plays music called "[normal BGM]_n" if it's night time and it exists
  def autoplay
    pbBGMPlay(bgm_name, @map.bgm.volume, @map.bgm.pitch) if @map.autoplay_bgm
    pbBGSPlay(@map.bgs) if @map.autoplay_bgs
  end

  def valid?(x, y)
    return x >= 0 && x < width && y >= 0 && y < height
  end

  def validLax?(x, y)
    return x >= -10 && x <= width + 10 && y >= -10 && y <= height + 10
  end

  def passable?(x, y, d, self_event = nil)
    return false if !valid?(x, y)
    bit = (1 << ((d / 2) - 1)) & 0x0f
    events.each_value do |event|
      next if event.tile_id <= 0
      next if event == self_event
      next if !event.at_coordinate?(x, y)
      next if event.through
      next if GameData::TerrainTag.try_get(@terrain_tags[event.tile_id]).ignore_passability
      passage = @passages[event.tile_id]
      return false if passage & bit != 0
      return false if passage & 0x0f == 0x0f
      return true if @priorities[event.tile_id] == 0
    end
    return playerPassable?(x, y, d, self_event) if self_event == $game_player
    # All other events
    newx = x
    newy = y
    case d
    when 1
      newx -= 1
      newy += 1
    when 2
      newy += 1
    when 3
      newx += 1
      newy += 1
    when 4
      newx -= 1
    when 6
      newx += 1
    when 7
      newx -= 1
      newy -= 1
    when 8
      newy -= 1
    when 9
      newx += 1
      newy -= 1
    end
    return false if !valid?(newx, newy)
    [2, 1, 0].each do |i|
      tile_id = data[x, y, i]
      terrain = GameData::TerrainTag.try_get(@terrain_tags[tile_id])
      # If already on water, only allow movement to another water tile
      if self_event && terrain.can_surf_freely
        [2, 1, 0].each do |j|
          facing_tile_id = data[newx, newy, j]
          next if facing_tile_id == 0
          return false if facing_tile_id.nil?
          facing_terrain = GameData::TerrainTag.try_get(@terrain_tags[facing_tile_id])
          if facing_terrain.id != :None && !facing_terrain.ignore_passability
            return facing_terrain.can_surf_freely
          end
        end
        return false
      # Can't walk onto ice
      elsif terrain.ice
        return false
      elsif self_event && self_event.x == x && self_event.y == y
        # Can't walk onto ledges
        [2, 1, 0].each do |j|
          facing_tile_id = data[newx, newy, j]
          next if facing_tile_id == 0
          return false if facing_tile_id.nil?
          facing_terrain = GameData::TerrainTag.try_get(@terrain_tags[facing_tile_id])
          return false if facing_terrain.ledge
          break if facing_terrain.id != :None && !facing_terrain.ignore_passability
        end
      end
      next if terrain&.ignore_passability
      next if tile_id == 0
      # Regular passability checks
      passage = @passages[tile_id]
      return false if passage & bit != 0 || passage & 0x0f == 0x0f
      return true if @priorities[tile_id] == 0
    end
    return true
  end

  def playerPassable?(x, y, d, self_event = nil)
    bit = (1 << ((d / 2) - 1)) & 0x0f
    [2, 1, 0].each do |i|
      tile_id = data[x, y, i]
      next if tile_id == 0
      terrain = GameData::TerrainTag.try_get(@terrain_tags[tile_id])
      passage = @passages[tile_id]
      if terrain
        # Ignore bridge tiles if not on a bridge
        next if terrain.bridge && $PokemonGlobal.bridge == 0
        # Make water tiles passable if player is surfing
        return true if $PokemonGlobal.surfing && terrain.can_surf && !terrain.waterfall
        # Prevent cycling in really tall grass/on ice
        return false if $PokemonGlobal.bicycle && (terrain.must_walk || terrain.must_walk_or_run)
        # Depend on passability of bridge tile if on bridge
        if terrain.bridge && $PokemonGlobal.bridge > 0
          return (passage & bit == 0 && passage & 0x0f != 0x0f)
        end
      end
      next if terrain&.ignore_passability
      # Regular passability checks
      return false if passage & bit != 0 || passage & 0x0f == 0x0f
      return true if @priorities[tile_id] == 0
    end
    return true
  end

  # Returns whether the position x,y is fully passable (there is no blocking
  # event there, and the tile is fully passable in all directions).
  def passableStrict?(x, y, d, self_event = nil)
    return false if !valid?(x, y)
    events.each_value do |event|
      next if event == self_event || event.tile_id < 0 || event.through
      next if !event.at_coordinate?(x, y)
      next if GameData::TerrainTag.try_get(@terrain_tags[event.tile_id]).ignore_passability
      return false if @passages[event.tile_id] & 0x0f != 0
      return true if @priorities[event.tile_id] == 0
    end
    [2, 1, 0].each do |i|
      tile_id = data[x, y, i]
      next if tile_id == 0
      next if GameData::TerrainTag.try_get(@terrain_tags[tile_id]).ignore_passability
      return false if @passages[tile_id] & 0x0f != 0
      return true if @priorities[tile_id] == 0
    end
    return true
  end

  def bush?(x, y)
    [2, 1, 0].each do |i|
      tile_id = data[x, y, i]
      next if tile_id == 0
      return false if GameData::TerrainTag.try_get(@terrain_tags[tile_id]).bridge &&
                      $PokemonGlobal.bridge > 0
      return true if @passages[tile_id] & 0x40 == 0x40
    end
    return false
  end

  def deepBush?(x, y)
    [2, 1, 0].each do |i|
      tile_id = data[x, y, i]
      next if tile_id == 0
      terrain = GameData::TerrainTag.try_get(@terrain_tags[tile_id])
      return false if terrain.bridge && $PokemonGlobal.bridge > 0
      return true if terrain.deep_bush && @passages[tile_id] & 0x40 == 0x40
    end
    return false
  end

  def counter?(x, y)
    [2, 1, 0].each do |i|
      tile_id = data[x, y, i]
      next if tile_id == 0
      passage = @passages[tile_id]
      return true if passage & 0x80 == 0x80
    end
    return false
  end

  def terrain_tag(x, y, countBridge = false)
    if valid?(x, y)
      [2, 1, 0].each do |i|
        tile_id = data[x, y, i]
        next if tile_id == 0
        terrain = GameData::TerrainTag.try_get(@terrain_tags[tile_id])
        next if terrain.id == :None || terrain.ignore_passability
        next if !countBridge && terrain.bridge && $PokemonGlobal.bridge == 0
        return terrain
      end
    end
    return GameData::TerrainTag.get(:None)
  end

  # Unused.
  def check_event(x, y)
    self.events.each_value do |event|
      return event.id if event.at_coordinate?(x, y)
    end
  end

  def display_x=(value)
    return if @display_x == value
    @display_x = value
    if metadata&.snap_edges
      max_x = (self.width - (Graphics.width.to_f / TILE_WIDTH)) * REAL_RES_X
      @display_x = [0, [@display_x, max_x].min].max
    end
    $map_factory&.setMapsInRange
  end

  def display_y=(value)
    return if @display_y == value
    @display_y = value
    if metadata&.snap_edges
      max_y = (self.height - (Graphics.height.to_f / TILE_HEIGHT)) * REAL_RES_Y
      @display_y = [0, [@display_y, max_y].min].max
    end
    $map_factory&.setMapsInRange
  end

  def scroll_up(distance)
    self.display_y -= distance
  end

  def scroll_down(distance)
    self.display_y += distance
  end

  def scroll_left(distance)
    self.display_x -= distance
  end

  def scroll_right(distance)
    self.display_x += distance
  end

  # speed is:
  #   1: moves 1 tile in 1.6 seconds
  #   2: moves 1 tile in 0.8 seconds
  #   3: moves 1 tile in 0.4 seconds
  #   4: moves 1 tile in 0.2 seconds
  #   5: moves 1 tile in 0.1 seconds
  #   6: moves 1 tile in 0.05 seconds
  def start_scroll(direction, distance, speed = 4)
    return if direction <= 0 || direction == 5 || direction >= 10
    if [1, 3, 4, 6, 7, 9].include?(direction)   # horizontal
      @scroll_distance_x = distance
      @scroll_distance_x *= -1 if [1, 4, 7].include?(direction)
    end
    if [1, 2, 3, 7, 8, 9].include?(direction)   # vertical
      @scroll_distance_y = distance
      @scroll_distance_y *= -1 if [7, 8, 9].include?(direction)
    end
    @scroll_speed = speed
    @scroll_start_x = display_x
    @scroll_start_y = display_y
    @scroll_timer_start = System.uptime
  end

  # The two distances can be positive or negative.
  def start_scroll_custom(distance_x, distance_y, speed = 4)
    return if distance_x == 0 && distance_y == 0
    @scroll_distance_x = distance_x
    @scroll_distance_y = distance_y
    @scroll_speed = speed
    @scroll_start_x = display_x
    @scroll_start_y = display_y
    @scroll_timer_start = System.uptime
  end

  def scrolling?
    return (@scroll_distance_x || 0) != 0 || (@scroll_distance_y || 0) != 0
  end

  # duration is time in 1/20ths of a second.
  def start_fog_tone_change(tone, duration)
    if duration == 0
      @fog_tone = tone.clone
      return
    end
    @fog_tone_initial = @fog_tone.clone
    @fog_tone_target = tone.clone
    @fog_tone_duration = duration / 20.0
    @fog_tone_timer_start = $stats.play_time
  end

  # duration is time in 1/20ths of a second.
  def start_fog_opacity_change(opacity, duration)
    if duration == 0
      @fog_opacity = opacity.to_f
      return
    end
    @fog_opacity_initial = @fog_opacity
    @fog_opacity_target = opacity.to_f
    @fog_opacity_duration = duration / 20.0
    @fog_opacity_timer_start = $stats.play_time
  end

  def set_tile(x, y, layer, id = 0)
    self.data[x, y, layer] = id
  end

  def erase_tile(x, y, layer)
    set_tile(x, y, layer, 0)
  end

  def refresh
    @events.each_value do |event|
      event.refresh
    end
    @common_events.each_value do |common_event|
      common_event.refresh
    end
    @need_refresh = false
  end

  def update
    uptime_now = System.uptime
    play_now = $stats.play_time
    # Refresh maps if necessary
    if $map_factory
      $map_factory.maps.each { |i| i.refresh if i.need_refresh }
      $map_factory.setCurrentMap
    end
    # If scrolling
    if (@scroll_distance_x || 0) != 0
      duration = @scroll_distance_x.abs * TILE_WIDTH.to_f / (10 * (2**@scroll_speed))
      scroll_offset = lerp(0, @scroll_distance_x, duration, @scroll_timer_start, uptime_now)
      self.display_x = @scroll_start_x + (scroll_offset * REAL_RES_X)
      @scroll_distance_x = 0 if scroll_offset == @scroll_distance_x
    end
    if (@scroll_distance_y || 0) != 0
      duration = @scroll_distance_y.abs * TILE_HEIGHT.to_f / (10 * (2**@scroll_speed))
      scroll_offset = lerp(0, @scroll_distance_y, duration, @scroll_timer_start, uptime_now)
      self.display_y = @scroll_start_y + (scroll_offset * REAL_RES_Y)
      @scroll_distance_y = 0 if scroll_offset == @scroll_distance_y
    end
    # Only update events that are on-screen
    if !$game_temp.in_menu
      @events.each_value { |event| event.update }
    end
    # Update common events
    @common_events.each_value { |common_event| common_event.update }
    # Update fog
    @fog_scroll_last_update_timer = uptime_now if !@fog_scroll_last_update_timer
    scroll_mult = (uptime_now - @fog_scroll_last_update_timer) * 5
    @fog_ox -= @fog_sx * scroll_mult
    @fog_oy -= @fog_sy * scroll_mult
    @fog_scroll_last_update_timer = uptime_now
    if @fog_tone_timer_start
      @fog_tone.red = lerp(@fog_tone_initial.red, @fog_tone_target.red, @fog_tone_duration, @fog_tone_timer_start, play_now)
      @fog_tone.green = lerp(@fog_tone_initial.green, @fog_tone_target.green, @fog_tone_duration, @fog_tone_timer_start, play_now)
      @fog_tone.blue = lerp(@fog_tone_initial.blue, @fog_tone_target.blue, @fog_tone_duration, @fog_tone_timer_start, play_now)
      @fog_tone.gray = lerp(@fog_tone_initial.gray, @fog_tone_target.gray, @fog_tone_duration, @fog_tone_timer_start, play_now)
      if play_now - @fog_tone_timer_start >= @fog_tone_duration
        @fog_tone_initial = nil
        @fog_tone_timer_start = nil
      end
    end
    if @fog_opacity_timer_start
      @fog_opacity = lerp(@fog_opacity_initial, @fog_opacity_target, @fog_opacity_duration, @fog_opacity_timer_start, play_now)
      if play_now - @fog_opacity_timer_start >= @fog_opacity_duration
        @fog_opacity_initial = nil
        @fog_opacity_timer_start = nil
      end
    end
  end
end

#===============================================================================
#
#===============================================================================
# Scroll the map in the given direction by the given distance at the (optional)
# given speed.
def pbScrollMap(direction, distance, speed = 4)
  if speed == 0
    if [1, 2, 3].include?(direction)
      $game_map.scroll_down(distance * Game_Map::REAL_RES_Y)
    elsif [7, 8, 9].include?(direction)
      $game_map.scroll_up(distance * Game_Map::REAL_RES_Y)
    end
    if [3, 6, 9].include?(direction)
      $game_map.scroll_right(distance * Game_Map::REAL_RES_X)
    elsif [1, 4, 7].include?(direction)
      $game_map.scroll_left(distance * Game_Map::REAL_RES_X)
    end
  else
    $game_map.start_scroll(direction, distance, speed)
    loop do
      Graphics.update
      Input.update
      pbUpdateSceneMap
      break if !$game_map.scrolling?
    end
  end
end

# Scroll the map to center on the given coordinates at the (optional) given
# speed. The scroll can happen in up to two parts, depending on where the target
# is relative to the current location: an initial diagonal movement and a
# following cardinal (vertical/horizontal) movement.
def pbScrollMapTo(x, y, speed = 4)
  if !$game_map.valid?(x, y)
    print "pbScrollMapTo: given x,y is invalid"
    return
  elsif !(0..6).include?(speed)
    print "pbScrollMapTo: invalid speed (0-6 only)"
    return
  end
  # Get tile coordinates that the screen is currently scrolled to
  screen_offset_x = (Graphics.width - Game_Map::TILE_WIDTH) * Game_Map::X_SUBPIXELS / 2
  screen_offset_y = (Graphics.height - Game_Map::TILE_HEIGHT) * Game_Map::Y_SUBPIXELS / 2
  current_tile_x = ($game_map.display_x + screen_offset_x) / Game_Map::REAL_RES_X
  current_tile_y = ($game_map.display_y + screen_offset_y) / Game_Map::REAL_RES_Y
  offset_x = x - current_tile_x
  offset_y = y - current_tile_y
  return if offset_x == 0 && offset_y == 0
  if speed == 0
    if offset_y > 0
      $game_map.scroll_down(offset_y.abs * Game_Map::REAL_RES_Y)
    elsif offset_y < 0
      $game_map.scroll_up(offset_y.abs * Game_Map::REAL_RES_Y)
    end
    if offset_x > 0
      $game_map.scroll_right(offset_x.abs * Game_Map::REAL_RES_X)
    elsif offset_x < 0
      $game_map.scroll_left(offset_x.abs * Game_Map::REAL_RES_X)
    end
  else
    $game_map.start_scroll_custom(offset_x, offset_y, speed)
    loop do
      Graphics.update
      Input.update
      pbUpdateSceneMap
      break if !$game_map.scrolling?
    end
  end
end

# Scroll the map to center on the player at the (optional) given speed.
def pbScrollMapToPlayer(speed = 4)
  pbScrollMapTo($game_player.x, $game_player.y, speed)
end
