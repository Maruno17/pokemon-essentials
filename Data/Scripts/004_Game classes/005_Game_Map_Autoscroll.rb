#===============================================================================
# ** Map Autoscroll
#-------------------------------------------------------------------------------
# Wachunga
# Version 1.02
# 2005-12-18
#===============================================================================
=begin

  This script supplements the built-in "Scroll Map" event command with the
  aim of simplifying cutscenes (and map scrolling in general). Whereas the
  normal event command requires a direction and number of tiles to scroll,
  Map Autoscroll scrolls the map to center on the tile whose x and y
  coordinates are given.

  FEATURES
  - automatic map scrolling to given x,y coordinate (or player)
  - destination is fixed, so it's possible to scroll to same place even if
    origin is variable (e.g. moving NPC)
  - variable speed (just like "Scroll Map" event command)
  - diagonal scrolling supported

  SETUP
  Instead of a "Scroll Map" event command, use the "Call Script" command
  and enter on the following on the first line:

  autoscroll(x,y)

  (replacing "x" and "y" with the x and y coordinates of the tile to scroll to)

  To specify a scroll speed other than the default (4), use:

  autoscroll(x,y,speed)

  (now also replacing "speed" with the scroll speed from 1-6)

  Diagonal scrolling happens automatically when the destination is diagonal
  relative to the starting point (i.e., not directly up, down, left or right).

  To scroll to the player, instead use the following:

  autoscroll_player(speed)

  Note: because of how the interpreter and the "Call Script" event command
  are setup, the call to autoscroll(...) can only be on the first line of
  the "Call Script" event command (and not flowing down to subsequent lines).

  For example, the following call may not work as expected:

  autoscroll($game_variables[1],
  $game_variables[2])

  (since the long argument names require dropping down to a second line)
  A work-around is to setup new variables with shorter names in a preceding
  (separate) "Call Script" event command:

  @x = $game_variables[1]
  @y = $game_variables[2]

  and then use those as arguments:

  autoscroll(@x,@y)

  The renaming must be in a separate "Call Script" because otherwise
  the call to autoscroll(...) isn't on the first line.

  Originally requested by militantmilo80:
  http://www.rmxp.net/forums/index.php?showtopic=29519

=end

class Interpreter
  SCROLL_SPEED_DEFAULT = 4
  #-----------------------------------------------------------------------------
  # * Map Autoscroll to Coordinates
  #     x     : x coordinate to scroll to and center on
  #     y     : y coordinate to scroll to and center on
  #     speed : (optional) scroll speed (from 1-6, default being 4)
  #-----------------------------------------------------------------------------
  def autoscroll(x, y, speed = SCROLL_SPEED_DEFAULT)
    if $game_map.scrolling?
      return false
    elsif !$game_map.valid?(x, y)
      print "Map Autoscroll: given x,y is invalid"
      return command_skip
    elsif !(1..6).include?(speed)
      print "Map Autoscroll: invalid speed (1-6 only)"
      return command_skip
    end
    center_x = ((Graphics.width / 2) - (Game_Map::TILE_WIDTH / 2)) * 4   # X coordinate in the center of the screen
    center_y = ((Graphics.height / 2) - (Game_Map::TILE_HEIGHT / 2)) * 4   # Y coordinate in the center of the screen
    max_x = ($game_map.width - (Graphics.width.to_f / Game_Map::TILE_WIDTH)) * 4 * Game_Map::TILE_WIDTH
    max_y = ($game_map.height - (Graphics.height.to_f / Game_Map::TILE_HEIGHT)) * 4 * Game_Map::TILE_HEIGHT
    count_x = ($game_map.display_x - [0, [(x * Game_Map::REAL_RES_X) - center_x, max_x].min].max) / Game_Map::REAL_RES_X
    count_y = ($game_map.display_y - [0, [(y * Game_Map::REAL_RES_Y) - center_y, max_y].min].max) / Game_Map::REAL_RES_Y
    if @diag
      @diag = false
      dir = nil
      if count_x != 0 && count_y != 0
        return false
      elsif count_x > 0
        dir = 4
      elsif count_x < 0
        dir = 6
      elsif count_y > 0
        dir = 8
      elsif count_y < 0
        dir = 2
      end
      count = count_x == 0 ? count_y.abs : count_x.abs
    else
      @diag = true
      dir = nil
      if count_x > 0
        if count_y > 0
          dir = 7
        elsif count_y < 0
          dir = 1
        end
      elsif count_x < 0
        if count_y > 0
          dir = 9
        elsif count_y < 0
          dir = 3
        end
      end
      count = [count_x.abs, count_y.abs].min
    end
    $game_map.start_scroll(dir, count, speed) if dir
    return !@diag
  end

  #-----------------------------------------------------------------------------
  # * Map Autoscroll (to Player)
  #     speed : (optional) scroll speed (from 1-6, default being 4)
  #-----------------------------------------------------------------------------
  def autoscroll_player(speed = SCROLL_SPEED_DEFAULT)
    autoscroll($game_player.x, $game_player.y, speed)
  end
end



class Game_Map
  def scroll_downright(distance)
    @display_x = [@display_x + distance,
                  (self.width - (Graphics.width.to_f / TILE_WIDTH)) * REAL_RES_X].min
    @display_y = [@display_y + distance,
                  (self.height - (Graphics.height.to_f / TILE_HEIGHT)) * REAL_RES_Y].min
  end

  def scroll_downleft(distance)
    @display_x = [@display_x - distance, 0].max
    @display_y = [@display_y + distance,
                  (self.height - (Graphics.height.to_f / TILE_HEIGHT)) * REAL_RES_Y].min
  end

  def scroll_upright(distance)
    @display_x = [@display_x + distance,
                  (self.width - (Graphics.width.to_f / TILE_WIDTH)) * REAL_RES_X].min
    @display_y = [@display_y - distance, 0].max
  end

  def scroll_upleft(distance)
    @display_x = [@display_x - distance, 0].max
    @display_y = [@display_y - distance, 0].max
  end

  def update_scrolling
    # If scrolling
    if @scroll_rest > 0
      # Change from scroll speed to distance in map coordinates
      distance = (1 << @scroll_speed) * 40 / Graphics.frame_rate
      distance = @scroll_rest if distance > @scroll_rest
      # Execute scrolling
      case @scroll_direction
      when 1 then scroll_downleft(distance)
      when 2 then scroll_down(distance)
      when 3 then scroll_downright(distance)
      when 4 then scroll_left(distance)
      when 6 then scroll_right(distance)
      when 7 then scroll_upleft(distance)
      when 8 then scroll_up(distance)
      when 9 then scroll_upright(distance)
      end
      # Subtract distance scrolled
      @scroll_rest -= distance
    end
  end
end
