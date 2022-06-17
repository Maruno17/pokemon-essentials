#==============================================================================
# ** Game_Map
#------------------------------------------------------------------------------
#  This class handles the map. It includes scrolling and passable determining
#  functions. Refer to "$game_map" for the instance of this class.
#==============================================================================
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
    @fog_ox               = 0
    @fog_oy               = 0
    @fog_tone             = Tone.new(0, 0, 0, 0)
    @fog_tone_target      = Tone.new(0, 0, 0, 0)
    @fog_tone_duration    = 0
    @fog_opacity_duration = 0
    @fog_opacity_target   = 0
    self.display_x        = 0
    self.display_y        = 0
    @need_refresh         = false
    EventHandlers.trigger(:on_game_map_setup, map_id, @map, tileset)
    @events               = {}
    @map.events.each_key do |i|
      @events[i]          = Game_Event.new(@map_id, @map.events[i], self)
    end
    @common_events        = {}
    (1...$data_common_events.size).each do |i|
      @common_events[i]   = Game_CommonEvent.new(i)
    end
    @scroll_direction     = 2
    @scroll_rest          = 0
    @scroll_speed         = 4
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

  #-----------------------------------------------------------------------------
  # Returns the name of this map's BGM. If it's night time, returns the night
  # version of the BGM (if it exists).
  #-----------------------------------------------------------------------------
  def bgm_name
    if PBDayNight.isNight? && FileTest.audio_exist?("Audio/BGM/" + @map.bgm.name + "_n")
      return @map.bgm.name + "_n"
    end
    return @map.bgm.name
  end
  #-----------------------------------------------------------------------------
  # * Autoplays background music
  #   Plays music called "[normal BGM]_n" if it's night time and it exists
  #-----------------------------------------------------------------------------
  def autoplayAsCue
    pbCueBGM(bgm_name, 1.0, @map.bgm.volume, @map.bgm.pitch) if @map.autoplay_bgm
    pbBGSPlay(@map.bgs) if @map.autoplay_bgs
  end
  #-----------------------------------------------------------------------------
  # * Plays background music
  #   Plays music called "[normal BGM]_n" if it's night time and it exists
  #-----------------------------------------------------------------------------
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
        return false if $PokemonGlobal.bicycle && terrain.must_walk
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
  # event there, and the tile is fully passable in all directions)
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

  def start_scroll(direction, distance, speed)
    @scroll_direction = direction
    if [2, 8].include?(direction)   # down or up
      @scroll_rest = distance * REAL_RES_Y
    else
      @scroll_rest = distance * REAL_RES_X
    end
    @scroll_speed = speed
  end

  def scrolling?
    return @scroll_rest > 0
  end

  def start_fog_tone_change(tone, duration)
    @fog_tone_target = tone.clone
    @fog_tone_duration = duration
    if @fog_tone_duration == 0
      @fog_tone = @fog_tone_target.clone
    end
  end

  def start_fog_opacity_change(opacity, duration)
    @fog_opacity_target = opacity.to_f
    @fog_opacity_duration = duration
    if @fog_opacity_duration == 0
      @fog_opacity = @fog_opacity_target
    end
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
    # refresh maps if necessary
    if $map_factory
      $map_factory.maps.each do |i|
        i.refresh if i.need_refresh
      end
      $map_factory.setCurrentMap
    end
    # If scrolling
    if @scroll_rest > 0
      distance = (1 << @scroll_speed) * 40.0 / Graphics.frame_rate
      distance = @scroll_rest if distance > @scroll_rest
      case @scroll_direction
      when 2 then scroll_down(distance)
      when 4 then scroll_left(distance)
      when 6 then scroll_right(distance)
      when 8 then scroll_up(distance)
      end
      @scroll_rest -= distance
    end
    # Only update events that are on-screen
    @events.each_value do |event|
      event.update
    end
    # Update common events
    @common_events.each_value do |common_event|
      common_event.update
    end
    # Update fog
    @fog_ox -= @fog_sx / 8.0
    @fog_oy -= @fog_sy / 8.0
    if @fog_tone_duration >= 1
      d = @fog_tone_duration
      target = @fog_tone_target
      @fog_tone.red   = ((@fog_tone.red * (d - 1)) + target.red) / d
      @fog_tone.green = ((@fog_tone.green * (d - 1)) + target.green) / d
      @fog_tone.blue  = ((@fog_tone.blue * (d - 1)) + target.blue) / d
      @fog_tone.gray  = ((@fog_tone.gray * (d - 1)) + target.gray) / d
      @fog_tone_duration -= 1
    end
    if @fog_opacity_duration >= 1
      d = @fog_opacity_duration
      @fog_opacity = ((@fog_opacity * (d - 1)) + @fog_opacity_target) / d
      @fog_opacity_duration -= 1
    end
  end
end

#===============================================================================
#
#===============================================================================
def pbScrollMap(direction, distance, speed)
  if speed == 0
    case direction
    when 2 then $game_map.scroll_down(distance * Game_Map::REAL_RES_Y)
    when 4 then $game_map.scroll_left(distance * Game_Map::REAL_RES_X)
    when 6 then $game_map.scroll_right(distance * Game_Map::REAL_RES_X)
    when 8 then $game_map.scroll_up(distance * Game_Map::REAL_RES_Y)
    end
  else
    $game_map.start_scroll(direction, distance, speed)
    oldx = $game_map.display_x
    oldy = $game_map.display_y
    loop do
      Graphics.update
      Input.update
      break if !$game_map.scrolling?
      pbUpdateSceneMap
      break if $game_map.display_x == oldx && $game_map.display_y == oldy
      oldx = $game_map.display_x
      oldy = $game_map.display_y
    end
  end
end
