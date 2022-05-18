class Game_Event < Game_Character
  attr_reader   :map_id
  attr_reader   :trigger
  attr_reader   :list
  attr_reader   :starting
  attr_reader   :tempSwitches   # Temporary self-switches
  attr_accessor :need_refresh

  def initialize(map_id, event, map = nil)
    super(map)
    @map_id       = map_id
    @event        = event
    @id           = @event.id
    @original_x   = @event.x
    @original_y   = @event.y
    if @event.name[/size\((\d+),(\d+)\)/i]
      @width = $~[1].to_i
      @height = $~[2].to_i
    end
    @erased       = false
    @starting     = false
    @need_refresh = false
    @route_erased = false
    @through      = true
    @to_update    = true
    @tempSwitches = {}
    moveto(@event.x, @event.y) if map
    refresh
  end

  def id;   return @event.id;   end
  def name; return @event.name; end

  def set_starting
    @starting = true
  end

  def clear_starting
    @starting = false
  end

  def start
    @starting = true if @list.size > 1
  end

  def erase
    @erased = true
    refresh
  end

  def erase_route
    @route_erased = true
    refresh
  end

  def tsOn?(c)
    return @tempSwitches && @tempSwitches[c] == true
  end

  def tsOff?(c)
    return !@tempSwitches || !@tempSwitches[c]
  end

  def setTempSwitchOn(c)
    @tempSwitches[c] = true
    refresh
  end

  def setTempSwitchOff(c)
    @tempSwitches[c] = false
    refresh
  end

  def isOff?(c)
    return !$game_self_switches[[@map_id, @event.id, c]]
  end

  def switchIsOn?(id)
    switchname = $data_system.switches[id]
    return false if !switchname
    if switchname[/^s\:/]
      return eval($~.post_match)
    else
      return $game_switches[id]
    end
  end

  def variable
    return nil if !$PokemonGlobal.eventvars
    return $PokemonGlobal.eventvars[[@map_id, @event.id]]
  end

  def setVariable(variable)
    $PokemonGlobal.eventvars[[@map_id, @event.id]] = variable
  end

  def varAsInt
    return 0 if !$PokemonGlobal.eventvars
    return $PokemonGlobal.eventvars[[@map_id, @event.id]].to_i
  end

  def expired?(secs = 86_400)
    ontime = self.variable
    time = pbGetTimeNow
    return ontime && (time.to_i > ontime + secs)
  end

  def expiredDays?(days = 1)
    ontime = self.variable.to_i
    return false if !ontime
    now = pbGetTimeNow
    elapsed = (now.to_i - ontime) / 86_400
    elapsed += 1 if (now.to_i - ontime) % 86_400 > ((now.hour * 3600) + (now.min * 60) + now.sec)
    return elapsed >= days
  end

  def cooledDown?(seconds)
    return true if expired?(seconds) && tsOff?("A")
    self.need_refresh = true
    return false
  end

  def cooledDownDays?(days)
    return true if expiredDays?(days) && tsOff?("A")
    self.need_refresh = true
    return false
  end

  def onEvent?
    return @map_id == $game_map.map_id && at_coordinate?($game_player.x, $game_player.y)
  end

  def over_trigger?
    return false if @character_name != "" && !@through
    return false if @event.name[/hiddenitem/i]
    each_occupied_tile do |i, j|
      return true if self.map.passable?(i, j, 0, $game_player)
    end
    return false
  end

  def pbCheckEventTriggerAfterTurning
    return if $game_system.map_interpreter.running? || @starting
    return if @trigger != 2   # Event touch
    return if !@event.name[/(?:sight|trainer)\((\d+)\)/i]
    distance = $~[1].to_i
    return if !pbEventCanReachPlayer?(self, $game_player, distance)
    return if jumping? || over_trigger?
    start
  end

  def check_event_trigger_touch(dir)
    return if $game_system.map_interpreter.running?
    return if @trigger != 2   # Event touch
    case dir
    when 2
      return if $game_player.y != @y + 1
    when 4
      return if $game_player.x != @x - 1
    when 6
      return if $game_player.x != @x + @width
    when 8
      return if $game_player.y != @y - @height
    end
    return if !in_line_with_coordinate?($game_player.x, $game_player.y)
    return if jumping? || over_trigger?
    start
  end

  def check_event_trigger_auto
    case @trigger
    when 2   # Event touch
      if at_coordinate?($game_player.x, $game_player.y) && !jumping? && over_trigger?
        start
      end
    when 3   # Autorun
      start
    end
  end

  def refresh
    new_page = nil
    unless @erased
      @event.pages.reverse.each do |page|
        c = page.condition
        next if c.switch1_valid && !switchIsOn?(c.switch1_id)
        next if c.switch2_valid && !switchIsOn?(c.switch2_id)
        next if c.variable_valid && $game_variables[c.variable_id] < c.variable_value
        if c.self_switch_valid
          key = [@map_id, @event.id, c.self_switch_ch]
          next if $game_self_switches[key] != true
        end
        new_page = page
        break
      end
    end
    return if new_page == @page
    @page = new_page
    clear_starting
    if @page.nil?
      @tile_id        = 0
      @character_name = ""
      @character_hue  = 0
      @move_type      = 0
      @through        = true
      @trigger        = nil
      @list           = nil
      @interpreter    = nil
      return
    end
    @tile_id              = @page.graphic.tile_id
    @character_name       = @page.graphic.character_name
    @character_hue        = @page.graphic.character_hue
    if @original_direction != @page.graphic.direction
      @direction          = @page.graphic.direction
      @original_direction = @direction
      @prelock_direction  = 0
    end
    if @original_pattern != @page.graphic.pattern
      @pattern            = @page.graphic.pattern
      @original_pattern   = @pattern
    end
    @opacity              = @page.graphic.opacity
    @blend_type           = @page.graphic.blend_type
    @move_type            = @page.move_type
    self.move_speed       = @page.move_speed
    self.move_frequency   = @page.move_frequency
    @move_route           = (@route_erased) ? RPG::MoveRoute.new : @page.move_route
    @move_route_index     = 0
    @move_route_forcing   = false
    @walk_anime           = @page.walk_anime
    @step_anime           = @page.step_anime
    @direction_fix        = @page.direction_fix
    @through              = @page.through
    @always_on_top        = @page.always_on_top
    calculate_bush_depth
    @trigger              = @page.trigger
    @list                 = @page.list
    @interpreter          = nil
    if @trigger == 4   # Parallel Process
      @interpreter        = Interpreter.new
    end
    check_event_trigger_auto
  end

  def should_update?(recalc = false)
    return @to_update if !recalc
    return true if @trigger && (@trigger == 3 || @trigger == 4)
    return true if @move_route_forcing || @moveto_happened
    return true if @event.name[/update/i]
    range = 2   # Number of tiles
    return false if self.screen_x - (@sprite_size[0] / 2) > Graphics.width + (range * Game_Map::TILE_WIDTH)
    return false if self.screen_x + (@sprite_size[0] / 2) < -range * Game_Map::TILE_WIDTH
    return false if self.screen_y_ground - @sprite_size[1] > Graphics.height + (range * Game_Map::TILE_HEIGHT)
    return false if self.screen_y_ground < -range * Game_Map::TILE_HEIGHT
    return true
  end

  def update
    @to_update = should_update?(true)
    return if !@to_update
    @moveto_happened = false
    last_moving = moving?
    super
    if !moving? && last_moving
      $game_player.pbCheckEventTriggerFromDistance([2])
    end
    if @need_refresh
      @need_refresh = false
      refresh
    end
    check_event_trigger_auto
    if @interpreter
      unless @interpreter.running?
        @interpreter.setup(@list, @event.id, @map_id)
      end
      @interpreter.update
    end
  end
end
