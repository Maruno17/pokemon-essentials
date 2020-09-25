class Game_Character
  attr_reader   :id
  attr_reader   :original_x
  attr_reader   :original_y
  attr_reader   :x
  attr_reader   :y
  attr_reader   :real_x
  attr_reader   :real_y
  attr_accessor :sprite_size
  attr_reader   :tile_id
  attr_accessor :character_name
  attr_accessor :character_hue
  attr_reader   :opacity
  attr_reader   :blend_type
  attr_reader   :direction
  attr_accessor :pattern
  attr_reader   :pattern_surf
  attr_accessor :lock_pattern
  attr_reader   :move_route_forcing
  attr_accessor :through
  attr_accessor :animation_id
  attr_accessor :transparent
  attr_reader   :move_speed
  attr_accessor :walk_anime
  attr_writer   :bob_height

  def initialize(map=nil)
    @map                       = map
    @id                        = 0
    @original_x                = 0
    @original_y                = 0
    @x                         = 0
    @y                         = 0
    @real_x                    = 0
    @real_y                    = 0
    @sprite_size               = [Game_Map::TILE_WIDTH, Game_Map::TILE_HEIGHT]
    @tile_id                   = 0
    @character_name            = ""
    @character_hue             = 0
    @opacity                   = 255
    @blend_type                = 0
    @direction                 = 2
    @pattern                   = 0
    @pattern_surf              = 0
    @lock_pattern              = false
    @move_route_forcing        = false
    @through                   = false
    @animation_id              = 0
    @transparent               = false
    @original_direction        = 2
    @original_pattern          = 0
    @move_type                 = 0
    self.move_speed            = 3
    self.move_frequency        = 6
    @move_route                = nil
    @move_route_index          = 0
    @original_move_route       = nil
    @original_move_route_index = 0
    @walk_anime                = true    # Whether character should animate while moving
    @step_anime                = false   # Whether character should animate while still
    @direction_fix             = false
    @always_on_top             = false
    @anime_count               = 0
    @stop_count                = 0
    @jump_peak                 = 0   # Max height while jumping
    @jump_distance             = 0   # Total distance of jump
    @jump_distance_left        = 0   # Distance left to travel
    @jump_count                = 0   # Frames left in a stationary jump
    @bob_height                = 0
    @wait_count                = 0
    @moved_this_frame          = false
    @locked                    = false
    @prelock_direction         = 0
  end

  def move_speed=(val)
    return if val==@move_speed
    @move_speed = val
    # @move_speed_real is the number of quarter-pixels to move each frame. There
    # are 128 quarter-pixels per tile. By default, it is calculated from
    # @move_speed and has these values (assuming 40 fps):
    # 1 => 3.2    # 40 frames per tile
    # 2 => 6.4    # 20 frames per tile
    # 3 => 12.8   # 10 frames per tile - walking speed
    # 4 => 25.6   # 5 frames per tile - running speed (2x walking speed)
    # 5 => 32     # 4 frames per tile - cycling speed (1.25x running speed)
    # 6 => 64     # 2 frames per tile
    self.move_speed_real = (val == 6) ? 64 : (val == 5) ? 32 : (2 ** (val + 1)) * 0.8
  end

  def move_speed_real
    self.move_speed = @move_speed if !@move_speed_real
    return @move_speed_real
  end

  def move_speed_real=(val)
    @move_speed_real = val * 40.0 / Graphics.frame_rate
  end

  def jump_speed_real
    return (2 ** (3 + 1)) * 0.8 * 40.0 / Graphics.frame_rate   # Walking speed
  end

  def move_frequency=(val)
    return if val==@move_frequency
    @move_frequency = val
    # @move_frequency_real is the number of frames to wait between each action
    # in a move route (not forced). Specifically, this is the number of frames
    # to wait after the character stops moving because of the previous action.
    # By default, it is calculated from @move_frequency and has these values
    # (assuming 40 fps):
    # 1 => 190   # 4.75 seconds
    # 2 => 144   # 3.6 seconds
    # 3 => 102   # 2.55 seconds
    # 4 => 64    # 1.6 seconds
    # 5 => 30    # 0.75 seconds
    # 6 => 0     # 0 seconds, i.e. continuous movement
    self.move_frequency_real = (40 - val * 2) * (6 - val)
  end

  def move_frequency_real
    self.move_frequency = @move_frequency if !@move_frequency_real
    return @move_frequency_real
  end

  def move_frequency_real=(val)
    @move_frequency_real = val * Graphics.frame_rate / 40.0
  end

  def bob_height
    @bob_height = 0 if !@bob_height
    return @bob_height
  end

  def lock
    return if @locked
    @prelock_direction = 0   # Was @direction but disabled
    turn_toward_player
    @locked = true
  end

  def minilock
    @prelock_direction = 0   # Was @direction but disabled
    @locked = true
  end

  def lock?
    return @locked
  end

  def unlock
    return unless @locked
    @locked = false
    @direction = @prelock_direction if !@direction_fix and @prelock_direction != 0
  end

  #=============================================================================
  # Information from map data
  #=============================================================================
  def map
    return (@map) ? @map : $game_map
  end

  def terrain_tag
    return self.map.terrain_tag(@x, @y)
  end

  def bush_depth
    return 0 if @tile_id > 0 || @always_on_top or jumping?
    xbehind = @x + (@direction==4 ? 1 : @direction==6 ? -1 : 0)
    ybehind = @y + (@direction==8 ? 1 : @direction==2 ? -1 : 0)
    return Game_Map::TILE_HEIGHT if self.map.deepBush?(@x, @y) and self.map.deepBush?(xbehind, ybehind)
    return 12 if !moving? and self.map.bush?(@x, @y)
    return 0
  end

  #=============================================================================
  # Passability
  #=============================================================================
  def passableEx?(x, y, d, strict=false)
    new_x = x + (d == 6 ? 1 : d == 4 ? -1 : 0)
    new_y = y + (d == 2 ? 1 : d == 8 ? -1 : 0)
    return false unless self.map.valid?(new_x, new_y)
    return true if @through
    if strict
      return false unless self.map.passableStrict?(x, y, d, self)
      return false unless self.map.passableStrict?(new_x, new_y, 10 - d, self)
    else
      return false unless self.map.passable?(x, y, d, self)
      return false unless self.map.passable?(new_x, new_y, 10 - d, self)
    end
    for event in self.map.events.values
      next if event.x != new_x || event.y != new_y || event.through
      return false if self != $game_player || event.character_name != ""
    end
    if $game_player.x == new_x and $game_player.y == new_y
      return false if !$game_player.through && @character_name != ""
    end
    return true
  end

  def passable?(x,y,d)
    return passableEx?(x,y,d,false)
  end

  def passableStrict?(x,y,d)
    return passableEx?(x,y,d,true)
  end

  #=============================================================================
  # Screen position of the character
  #=============================================================================
  def screen_x
    ret = ((@real_x - self.map.display_x) / Game_Map::X_SUBPIXELS).round
    ret += Game_Map::TILE_WIDTH/2
    return ret
  end

  def screen_y_ground
    ret = ((@real_y - self.map.display_y) / Game_Map::Y_SUBPIXELS).round
    ret += Game_Map::TILE_HEIGHT
    return ret
  end

  def screen_y
    ret = screen_y_ground
    if jumping?
      if @jump_count > 0
        jump_fraction = ((@jump_count * jump_speed_real / Game_Map::REAL_RES_X) - 0.5).abs   # 0.5 to 0 to 0.5
      else
        jump_fraction = ((@jump_distance_left / @jump_distance) - 0.5).abs   # 0.5 to 0 to 0.5
      end
      ret += @jump_peak * (4 * jump_fraction**2 - 1)
    end
    return ret
  end

  def screen_z(height = 0)
    return 999 if @always_on_top
    z = screen_y_ground
    if @tile_id > 0
      begin
        return z + self.map.priorities[@tile_id] * 32
      rescue
        raise "Event's graphic is an out-of-range tile (event #{@id}, map #{self.map.map_id})"
      end
    end
    # Add z if height exceeds 32
    return z + ((height > Game_Map::TILE_HEIGHT) ? Game_Map::TILE_HEIGHT - 1 : 0)
  end

  #=============================================================================
  # Movement
  #=============================================================================
  def moving?
    return @real_x != @x * Game_Map::REAL_RES_X ||
           @real_y != @y * Game_Map::REAL_RES_Y
  end

  def jumping?
    return (@jump_distance_left || 0) > 0 || @jump_count > 0
  end

  def straighten
    @pattern = 0 if @walk_anime or @step_anime
    @anime_count = 0
    @prelock_direction = 0
  end

  def force_move_route(move_route)
    if @original_move_route == nil
      @original_move_route       = @move_route
      @original_move_route_index = @move_route_index
    end
    @move_route         = move_route
    @move_route_index   = 0
    @move_route_forcing = true
    @prelock_direction  = 0
    @wait_count         = 0
    move_type_custom
  end

  def moveto(x, y)
    @x = x % self.map.width
    @y = y % self.map.height
    @real_x = @x * Game_Map::REAL_RES_X
    @real_y = @y * Game_Map::REAL_RES_Y
    @prelock_direction = 0
    triggerLeaveTile
  end

  def triggerLeaveTile
    if @oldX && @oldY && @oldMap &&
       (@oldX!=self.x || @oldY!=self.y || @oldMap!=self.map.map_id)
      Events.onLeaveTile.trigger(self,self,@oldMap,@oldX,@oldY)
    end
    @oldX = self.x
    @oldY = self.y
    @oldMap = self.map.map_id
  end

  def increase_steps
    @stop_count = 0
    triggerLeaveTile
  end

  #=============================================================================
  # Movement commands
  #=============================================================================
  def move_type_random
    case rand(6)
    when 0..3; move_random
    when 4;    move_forward
    when 5;    @stop_count = 0
    end
  end

  def move_type_toward_player
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    if sx.abs + sy.abs >= 20
      move_random
      return
    end
    case rand(6)
    when 0..3; move_toward_player
    when 4;    move_random
    when 5;    move_forward
    end
  end

  def move_type_custom
    return if jumping? or moving?
    while @move_route_index < @move_route.list.size
      command = @move_route.list[@move_route_index]
      if command.code == 0
        if @move_route.repeat
          @move_route_index = 0
        else
          if @move_route_forcing
            @move_route_forcing = false
            @move_route       = @original_move_route
            @move_route_index = @original_move_route_index
            @original_move_route = nil
          end
          @stop_count = 0
        end
        return
      end
      if command.code <= 14
        case command.code
        when 1;  move_down
        when 2;  move_left
        when 3;  move_right
        when 4;  move_up
        when 5;  move_lower_left
        when 6;  move_lower_right
        when 7;  move_upper_left
        when 8;  move_upper_right
        when 9;  move_random
        when 10; move_toward_player
        when 11; move_away_from_player
        when 12; move_forward
        when 13; move_backward
        when 14; jump(command.parameters[0], command.parameters[1])
        end
        @move_route_index += 1 if @move_route.skippable or moving? or jumping?
        return
      end
      if command.code == 15   # Wait
        @wait_count = (command.parameters[0] * Graphics.frame_rate / 20) - 1
        @move_route_index += 1
        return
      end
      if command.code >= 16 and command.code <= 26
        case command.code
        when 16; turn_down
        when 17; turn_left
        when 18; turn_right
        when 19; turn_up
        when 20; turn_right_90
        when 21; turn_left_90
        when 22; turn_180
        when 23; turn_right_or_left_90
        when 24; turn_random
        when 25; turn_toward_player
        when 26; turn_away_from_player
        end
        @move_route_index += 1
        return
      end
      if command.code >= 27
        case command.code
        when 27
          $game_switches[command.parameters[0]] = true
          self.map.need_refresh = true
        when 28
          $game_switches[command.parameters[0]] = false
          self.map.need_refresh = true
        when 29; self.move_speed = command.parameters[0]
        when 30; self.move_frequency = command.parameters[0]
        when 31; @walk_anime = true
        when 32; @walk_anime = false
        when 33; @step_anime = true
        when 34; @step_anime = false
        when 35; @direction_fix = true
        when 36; @direction_fix = false
        when 37; @through = true
        when 38; @through = false
        when 39; @always_on_top = true
        when 40; @always_on_top = false
        when 41
          @tile_id = 0
          @character_name = command.parameters[0]
          @character_hue = command.parameters[1]
          if @original_direction != command.parameters[2]
            @direction = command.parameters[2]
            @original_direction = @direction
            @prelock_direction = 0
          end
          if @original_pattern != command.parameters[3]
            @pattern = command.parameters[3]
            @original_pattern = @pattern
          end
        when 42; @opacity = command.parameters[0]
        when 43; @blend_type = command.parameters[0]
        when 44; pbSEPlay(command.parameters[0])
        when 45; eval(command.parameters[0])
        end
        @move_route_index += 1
      end
    end
  end

  def move_up(turn_enabled = true)
    turn_up if turn_enabled
    if passable?(@x, @y, 8)
      turn_up
      @y -= 1
      increase_steps
    else
      check_event_trigger_touch(@x, @y-1)
    end
  end

  def move_down(turn_enabled = true)
    turn_down if turn_enabled
    if passable?(@x, @y, 2)
      turn_down
      @y += 1
      increase_steps
    else
      check_event_trigger_touch(@x, @y+1)
    end
  end

  def move_left(turn_enabled = true)
    turn_left if turn_enabled
    if passable?(@x, @y, 4)
      turn_left
      @x -= 1
      increase_steps
    else
      check_event_trigger_touch(@x-1, @y)
    end
  end

  def move_right(turn_enabled = true)
    turn_right if turn_enabled
    if passable?(@x, @y, 6)
      turn_right
      @x += 1
      increase_steps
    else
      check_event_trigger_touch(@x+1, @y)
    end
  end

  def move_upper_left
    unless @direction_fix
      @direction = (@direction == 6 ? 4 : @direction == 2 ? 8 : @direction)
    end
    if (passable?(@x, @y, 8) and passable?(@x, @y - 1, 4)) or
       (passable?(@x, @y, 4) and passable?(@x - 1, @y, 8))
      @x -= 1
      @y -= 1
      increase_steps
    end
  end

  def move_upper_right
    unless @direction_fix
      @direction = (@direction == 4 ? 6 : @direction == 2 ? 8 : @direction)
    end
    if (passable?(@x, @y, 8) and passable?(@x, @y - 1, 6)) or
       (passable?(@x, @y, 6) and passable?(@x + 1, @y, 8))
      @x += 1
      @y -= 1
      increase_steps
    end
  end

  def move_lower_left
    unless @direction_fix
      @direction = (@direction == 6 ? 4 : @direction == 8 ? 2 : @direction)
    end
    if (passable?(@x, @y, 2) and passable?(@x, @y + 1, 4)) or
       (passable?(@x, @y, 4) and passable?(@x - 1, @y, 2))
      @x -= 1
      @y += 1
      increase_steps
    end
  end

  def move_lower_right
    unless @direction_fix
      @direction = (@direction == 4 ? 6 : @direction == 8 ? 2 : @direction)
    end
    if (passable?(@x, @y, 2) and passable?(@x, @y + 1, 6)) or
       (passable?(@x, @y, 6) and passable?(@x + 1, @y, 2))
      @x += 1
      @y += 1
      increase_steps
    end
  end

  def moveLeft90   # anticlockwise
    case self.direction
    when 2; move_right   # down
    when 4; move_down    # left
    when 6; move_up      # right
    when 8; move_left    # up
    end
  end

  def moveRight90   # clockwise
    case self.direction
    when 2; move_left    # down
    when 4; move_up      # left
    when 6; move_down    # right
    when 8; move_right   # up
    end
  end

  def move_random
    case rand(4)
    when 0; move_down(false)
    when 1; move_left(false)
    when 2; move_right(false)
    when 3; move_up(false)
    end
  end

  def move_random_range(xrange=-1,yrange=-1)
    dirs = []   # 0=down, 1=left, 2=right, 3=up
    if xrange<0
      dirs.push(1); dirs.push(2)
    elsif xrange>0
      dirs.push(1) if @x > @original_x - xrange
      dirs.push(2) if @x < @original_x + xrange
    end
    if yrange<0
      dirs.push(0); dirs.push(3)
    elsif yrange>0
      dirs.push(0) if @y < @original_y + yrange
      dirs.push(3) if @y > @original_y - yrange
    end
    return if dirs.length==0
    case dirs[rand(dirs.length)]
    when 0; move_down(false)
    when 1; move_left(false)
    when 2; move_right(false)
    when 3; move_up(false)
    end
  end

  def move_random_UD(range=-1)
    move_random_range(0,range)
  end

  def move_random_LR(range=-1)
    move_random_range(range,0)
  end

  def move_toward_player
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    return if sx == 0 and sy == 0
    abs_sx = sx.abs
    abs_sy = sy.abs
    if abs_sx == abs_sy
      (rand(2) == 0) ? abs_sx += 1 : abs_sy += 1
    end
    if abs_sx > abs_sy
      (sx > 0) ? move_left : move_right
      if not moving? and sy != 0
        (sy > 0) ? move_up : move_down
      end
    else
      (sy > 0) ? move_up : move_down
      if not moving? and sx != 0
        (sx > 0) ? move_left : move_right
      end
    end
  end

  def move_away_from_player
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    return if sx == 0 and sy == 0
    abs_sx = sx.abs
    abs_sy = sy.abs
    if abs_sx == abs_sy
      (rand(2) == 0) ? abs_sx += 1 : abs_sy += 1
    end
    if abs_sx > abs_sy
      (sx > 0) ? move_right : move_left
      if not moving? and sy != 0
        (sy > 0) ? move_down : move_up
      end
    else
      (sy > 0) ? move_down : move_up
      if not moving? and sx != 0
        (sx > 0) ? move_right : move_left
      end
    end
  end

  def move_forward
    case @direction
    when 2; move_down(false)
    when 4; move_left(false)
    when 6; move_right(false)
    when 8; move_up(false)
    end
  end

  def move_backward
    last_direction_fix = @direction_fix
    @direction_fix = true
    case @direction
    when 2; move_up(false)
    when 4; move_right(false)
    when 6; move_left(false)
    when 8; move_down(false)
    end
    @direction_fix = last_direction_fix
  end

  def jump(x_plus, y_plus)
    if x_plus != 0 or y_plus != 0
      if x_plus.abs > y_plus.abs
        (x_plus < 0) ? turn_left : turn_right
      else
        (y_plus < 0) ? turn_up : turn_down
      end
    end
    new_x = @x + x_plus
    new_y = @y + y_plus
    if (x_plus == 0 and y_plus == 0) || passable?(new_x, new_y, 0)
      @x = new_x
      @y = new_y
      real_distance = Math::sqrt(x_plus * x_plus + y_plus * y_plus)
      distance = [1, real_distance].max
      @jump_peak = distance * Game_Map::TILE_HEIGHT * 3 / 8   # 3/4 of tile for ledge jumping
      @jump_distance = [x_plus.abs * Game_Map::REAL_RES_X, y_plus.abs * Game_Map::REAL_RES_Y].max
      @jump_distance_left = 1   # Just needs to be non-zero
      if real_distance > 0   # Jumping to somewhere else
        @jump_count = 0
      else   # Jumping on the spot
        @jump_count = Game_Map::REAL_RES_X / jump_speed_real   # Number of frames to jump one tile
      end
      @stop_count = 0
      if self.is_a?(Game_Player)
        $PokemonTemp.dependentEvents.pbMoveDependentEvents
      end
      triggerLeaveTile
    end
  end

  def jumpForward
    case self.direction
    when 2; jump(0,1)    # down
    when 4; jump(-1,0)   # left
    when 6; jump(1,0)    # right
    when 8; jump(0,-1)   # up
    end
  end

  def jumpBackward
    case self.direction
    when 2; jump(0,-1)   # down
    when 4; jump(1,0)    # left
    when 6; jump(-1,0)   # right
    when 8; jump(0,1)    # up
    end
  end

  def turnGeneric(dir)
    return if @direction_fix
    oldDirection = @direction
    @direction = dir
    @stop_count = 0
    pbCheckEventTriggerAfterTurning if dir != oldDirection
  end

  def turn_up;    turnGeneric(8); end
  def turn_down;  turnGeneric(2); end
  def turn_left;  turnGeneric(4); end
  def turn_right; turnGeneric(6); end

  def turn_right_90
    case @direction
    when 2; turn_left
    when 4; turn_up
    when 6; turn_down
    when 8; turn_right
    end
  end

  def turn_left_90
    case @direction
    when 2; turn_right
    when 4; turn_down
    when 6; turn_up
    when 8; turn_left
    end
  end

  def turn_180
    case @direction
    when 2; turn_up
    when 4; turn_right
    when 6; turn_left
    when 8; turn_down
    end
  end

  def turn_right_or_left_90
    (rand(2) == 0) ? turn_right_90 : turn_left_90
  end

  def turn_random
    case rand(4)
    when 0; turn_up
    when 1; turn_right
    when 2; turn_left
    when 3; turn_down
    end
  end

  def turn_toward_player
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    return if sx == 0 and sy == 0
    if sx.abs > sy.abs
      (sx > 0) ? turn_left : turn_right
    else
      (sy > 0) ? turn_up : turn_down
    end
  end

  def turn_away_from_player
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    return if sx == 0 and sy == 0
    if sx.abs > sy.abs
      (sx > 0) ? turn_right : turn_left
    else
      (sy > 0) ? turn_down : turn_up
    end
  end

  #=============================================================================
  # Updating
  #=============================================================================
  def update
    @moved_last_frame = @moved_this_frame
    if !$game_temp.in_menu
      # Update command
      update_command
      # Update movement
      (moving? || jumping?) ? update_move : update_stop
    end
    # Update animation
    update_pattern
  end

  def update_command
    if @wait_count > 0
      @wait_count -= 1
    elsif @move_route_forcing
      move_type_custom
    elsif !@starting && !lock? && !moving? && !jumping?
      update_command_new
    end
  end

  def update_command_new
    # @stop_count is the number of frames since the last movement finished.
    # @move_frequency has these values:
    # 1 => @stop_count > 190   # 4.75 seconds
    # 2 => @stop_count > 144   # 3.6 seconds
    # 3 => @stop_count > 102   # 2.55 seconds
    # 4 => @stop_count > 64    # 1.6 seconds
    # 5 => @stop_count > 30    # 0.75 seconds
    # 6 => @stop_count > 0     # 0 seconds
    if @stop_count >= self.move_frequency_real
      case @move_type
      when 1; move_type_random
      when 2; move_type_toward_player
      when 3; move_type_custom
      end
    end
  end

  def update_move
    # Move the character (the 0.1 catches rounding errors)
    distance = (jumping?) ? jump_speed_real : move_speed_real
    dest_x = @x * Game_Map::REAL_RES_X
    dest_y = @y * Game_Map::REAL_RES_Y
    if @real_x < dest_x
      @real_x += distance
      @real_x = dest_x if @real_x > dest_x - 0.1
    else
      @real_x -= distance
      @real_x = dest_x if @real_x < dest_x + 0.1
    end
    if @real_y < dest_y
      @real_y += distance
      @real_y = dest_y if @real_y > dest_y - 0.1
    else
      @real_y -= distance
      @real_y = dest_y if @real_y < dest_y + 0.1
    end
    # Refresh how far is left to travel in a jump
    if jumping?
      @jump_count -= 1 if @jump_count > 0   # For stationary jumps only
      @jump_distance_left = [(dest_x - @real_x).abs, (dest_y - @real_y).abs].max
    end
    # End of a step, so perform events that happen at this time
    Events.onStepTakenFieldMovement.trigger(self, self) if !jumping? && !moving?
    # Increment animation counter
    @anime_count += 1 if @walk_anime || @step_anime
    @moved_this_frame = true
  end

  def update_stop
    @anime_count += 1 if @step_anime
    @stop_count  += 1 if !@starting && !lock?
    @moved_this_frame = false
  end

  def update_pattern
    return if @lock_pattern
#    return if @jump_count > 0   # Don't animate if jumping on the spot
    # Character has stopped moving, return to original pattern
    if @moved_last_frame && !@moved_this_frame && !@step_anime
      @pattern = @original_pattern
      @anime_count = 0
      return
    end
    # Character has started to move, change pattern immediately
    if !@moved_last_frame && @moved_this_frame && !@step_anime
      @pattern = (@pattern + 1) % 4 if @walk_anime
      @anime_count = 0
      return
    end
    # Calculate how many frames each pattern should display for, i.e. the time
    # it takes to move half a tile (or a whole tile if cycling). We assume the
    # game uses square tiles.
    real_speed = (jumping?) ? jump_speed_real : move_speed_real
    frames_per_pattern = Game_Map::REAL_RES_X / (real_speed * 2.0)
    frames_per_pattern *= 2 if move_speed == 6   # Cycling/fastest speed
    return if @anime_count < frames_per_pattern
    # Advance to the next animation frame
    @pattern = (@pattern + 1) % 4
    @anime_count -= frames_per_pattern
  end
end
