#===============================================================================
# ** Interpreter
#-------------------------------------------------------------------------------
#  This interpreter runs event commands. This class is used within the
#  Game_System class and the Game_Event class.
#===============================================================================
class Interpreter
  #-----------------------------------------------------------------------------
  # * Object Initialization
  #     depth : nest depth
  #     main  : main flag
  #-----------------------------------------------------------------------------
  def initialize(depth = 0, main = false)
    @depth = depth
    @main  = main
    if depth > 100
      print("Common event call has exceeded maximum limit.")
      exit
    end
    clear
  end

  def inspect
    str = super.chop
    str << sprintf(" @event_id: %d>", @event_id)
    return str
  end

  def clear
    @map_id             = 0       # map ID when starting up
    @event_id           = 0       # event ID
    @message_waiting    = false   # waiting for message to end
    @move_route_waiting = false   # waiting for move completion
    @wait_count         = 0       # wait count
    @child_interpreter  = nil     # child interpreter
    @branch             = {}      # branch data
    @buttonInput        = false
    @hidden_choices     = []
    @renamed_choices    = []
    end_follower_overrides
  end
  #-----------------------------------------------------------------------------
  # * Event Setup
  #     list     : list of event commands
  #     event_id : event ID
  #-----------------------------------------------------------------------------
  def setup(list, event_id, map_id = nil)
    clear
    @map_id = map_id || $game_map.map_id
    @event_id = event_id
    @list = list
    @index = 0
    @branch.clear
  end

  def setup_starting_event
    $game_map.refresh if $game_map.need_refresh
    # Set up common event if one wants to start
    if $game_temp.common_event_id > 0
      setup($data_common_events[$game_temp.common_event_id].list, 0)
      $game_temp.common_event_id = 0
      return
    end
    # Check all map events for one that wants to start, and set it up
    $game_map.events.each_value do |event|
      next if !event.starting
      if event.trigger < 3   # Isn't autorun or parallel processing
        event.lock
        event.clear_starting
      end
      setup(event.list, event.id, event.map.map_id)
      return
    end
    # Check all common events for one that is autorun, and set it up
    $data_common_events.compact.each do |common_event|
      next if common_event.trigger != 1 || !$game_switches[common_event.switch_id]
      setup(common_event.list, 0)
      return
    end
  end

  def running?
    return !@list.nil?
  end
  #-----------------------------------------------------------------------------
  # * Frame Update
  #-----------------------------------------------------------------------------
  def update
    @loop_count = 0
    loop do
      @loop_count += 1
      if @loop_count > 100   # Call Graphics.update for freeze prevention
        Graphics.update
        @loop_count = 0
      end
      # If this interpreter's map isn't the current map or connected to it,
      # forget this interpreter's event ID
      if $game_map.map_id != @map_id && !$map_factory.areConnected?($game_map.map_id, @map_id)
        @event_id = 0
      end
      # Update child interpreter if one exists
      if @child_interpreter
        @child_interpreter.update
        @child_interpreter = nil if !@child_interpreter.running?
        return if @child_interpreter
      end
      # Do nothing if a message is being shown
      return if @message_waiting
      # Do nothing if any event or the player is in the middle of a move route
      if @move_route_waiting
        return if $game_player.move_route_forcing
        $game_map.events.each_value do |event|
          return if event.move_route_forcing
        end
        $game_temp.followers.each_follower do |event, follower|
          return if event.move_route_forcing
        end
        @move_route_waiting = false
      end
      # Do nothing while waiting
      if @wait_count > 0
        @wait_count -= 1
        return
      end
      # Do nothing if the pause menu is going to open
      return if $game_temp.menu_calling
      # If there are no commands in the list, try to find something that wants to run
      if @list.nil?
        setup_starting_event if @main
        return if @list.nil?   # Couldn't find anything that wants to run
      end
      # Execute the next command
      return if execute_command == false
      # Move to the next @index
      @index += 1
    end
  end
  #-----------------------------------------------------------------------------
  # * Execute script
  #-----------------------------------------------------------------------------
  def execute_script(script)
    begin
      result = eval(script)
      return result
    rescue Exception
      e = $!
      raise if e.is_a?(SystemExit) || e.class.to_s == "Reset"
      event = get_self
      # Gather text for error message
      message = pbGetExceptionMessage(e)
      backtrace_text = ""
      if e.is_a?(SyntaxError)
        script.each_line { |line|
          line.gsub!(/\s+$/, "")
          if line[/^\s*\(/]
            message += "\r\n***Line '#{line}' shouldn't begin with '('. Try putting the '('\r\n"
            message += "at the end of the previous line instead, or using 'extendtext.exe'."
          end
        }
      else
        backtrace_text += "\r\n"
        backtrace_text += "Backtrace:"
        e.backtrace[0, 10].each { |i| backtrace_text += "\r\n#{i}" }
        backtrace_text.gsub!(/Section(\d+)/) { $RGSS_SCRIPTS[$1.to_i][1] } rescue nil
        backtrace_text += "\r\n"
      end
      # Assemble error message
      err = "Script error in Interpreter\r\n"
      if $game_map
        map_name = ($game_map.name rescue nil) || "???"
        if event
          err = "Script error in event #{event.id} (coords #{event.x},#{event.y}), map #{$game_map.map_id} (#{map_name})\r\n"
        else
          err = "Script error in Common Event, map #{$game_map.map_id} (#{map_name})\r\n"
        end
      end
      err += "Exception: #{e.class}\r\n"
      err += "Message: #{message}\r\n\r\n"
      err += "***Full script:\r\n#{script}"   # \r\n"
      err += backtrace_text
      # Raise error
      raise EventScriptError.new(err)
    end
  end
  #-----------------------------------------------------------------------------
  # * Get Character
  #     parameter : parameter
  #-----------------------------------------------------------------------------
  def get_character(parameter = 0)
    case parameter
    when -1   # player
      return $game_player
    when 0    # this event
      events = $game_map.events
      return (events) ? events[@event_id] : nil
    else      # specific event
      events = $game_map.events
      return (events) ? events[parameter] : nil
    end
  end

  def get_player
    return get_character(-1)
  end

  def get_self
    return get_character(0)
  end

  def get_event(parameter)
    return get_character(parameter)
  end
  #-----------------------------------------------------------------------------
  # * Freezes all events on the map (for use at the beginning of common events)
  #-----------------------------------------------------------------------------
  def pbGlobalLock
    $game_map.events.each_value { |event| event.minilock }
  end
  #-----------------------------------------------------------------------------
  # * Unfreezes all events on the map (for use at the end of common events)
  #-----------------------------------------------------------------------------
  def pbGlobalUnlock
    $game_map.events.each_value { |event| event.unlock }
  end
  #-----------------------------------------------------------------------------
  # * Gets the next index in the interpreter, ignoring certain commands between messages
  #-----------------------------------------------------------------------------
  def pbNextIndex(index)
    return -1 if !@list || @list.length == 0
    i = index + 1
    loop do
      return i if i >= @list.length - 1
      case @list[i].code
      when 118, 108, 408   # Label, Comment
        i += 1
      when 413             # Repeat Above
        i = pbRepeatAbove(i)
      when 113             # Break Loop
        i = pbBreakLoop(i)
      when 119             # Jump to Label
        newI = pbJumpToLabel(i, @list[i].parameters[0])
        i = (newI > i) ? newI : i + 1
      else
        return i
      end
    end
  end

  def pbRepeatAbove(index)
    index = @list[index].indent
    loop do
      index -= 1
      return index + 1 if @list[index].indent == indent
    end
  end

  def pbBreakLoop(index)
    indent = @list[index].indent
    temp_index = index
    loop do
      temp_index += 1
      return index + 1 if temp_index >= @list.size - 1
      return temp_index + 1 if @list[temp_index].code == 413 &&
                               @list[temp_index].indent < indent
    end
  end

  def pbJumpToLabel(index, label_name)
    temp_index = 0
    loop do
      return index + 1 if temp_index >= @list.size - 1
      return temp_index + 1 if @list[temp_index].code == 118 &&
                               @list[temp_index].parameters[0] == label_name
      temp_index += 1
    end
  end

  def follower_move_route(id = nil)
    @follower_move_route = true
    @follower_move_route_id = id
  end

  def follower_animation(id = nil)
    @follower_animation = true
    @follower_animation_id = id
  end

  def end_follower_overrides
    @follower_move_route = false
    @follower_move_route_id = nil
    @follower_animation = false
    @follower_animation_id = nil
  end

  #-----------------------------------------------------------------------------
  # * Various methods to be used in a script event command.
  #-----------------------------------------------------------------------------
  # Helper function that shows a picture in a script.
  def pbShowPicture(number, name, origin, x, y, zoomX = 100, zoomY = 100, opacity = 255, blendType = 0)
    number += ($game_temp.in_battle ? 50 : 0)
    $game_screen.pictures[number].show(name, origin, x, y, zoomX, zoomY, opacity, blendType)
  end

  # Erases an event and adds it to the list of erased events so that
  # it can stay erased when the game is saved then loaded again.
  def pbEraseThisEvent
    if $game_map.events[@event_id]
      $game_map.events[@event_id].erase
      $PokemonMap&.addErasedEvent(@event_id)
    end
    @index += 1
    return true
  end

  # Runs a common event.
  def pbCommonEvent(id)
    common_event = $data_common_events[id]
    return if !common_event
    if $game_temp.in_battle
      $game_system.battle_interpreter.setup(common_event.list, 0)
    else
      interp = Interpreter.new
      interp.setup(common_event.list, 0)
      loop do
        Graphics.update
        Input.update
        interp.update
        pbUpdateSceneMap
        break if !interp.running?
      end
    end
  end

  # Sets another event's self switch (eg. pbSetSelfSwitch(20, "A", true) ).
  def pbSetSelfSwitch(eventid, switch_name, value, mapid = -1)
    mapid = @map_id if mapid < 0
    old_value = $game_self_switches[[mapid, eventid, switch_name]]
    $game_self_switches[[mapid, eventid, switch_name]] = value
    if value != old_value && $map_factory.hasMap?(mapid)
      $map_factory.getMap(mapid, false).need_refresh = true
    end
  end

  def tsOff?(c)
    return get_self.tsOff?(c)
  end
  alias isTempSwitchOff? tsOff?

  def tsOn?(c)
    return get_self.tsOn?(c)
  end
  alias isTempSwitchOn? tsOn?

  def setTempSwitchOn(c)
    get_self.setTempSwitchOn(c)
  end

  def setTempSwitchOff(c)
    get_self.setTempSwitchOff(c)
  end

  def getVariable(*arg)
    if arg.length == 0
      return nil if !$PokemonGlobal.eventvars
      return $PokemonGlobal.eventvars[[@map_id, @event_id]]
    else
      return $game_variables[arg[0]]
    end
  end

  def setVariable(*arg)
    if arg.length == 1
      $PokemonGlobal.eventvars = {} if !$PokemonGlobal.eventvars
      $PokemonGlobal.eventvars[[@map_id, @event_id]] = arg[0]
    else
      $game_variables[arg[0]] = arg[1]
      $game_map.need_refresh = true
    end
  end

  def pbGetPokemon(id)
    return $player.party[pbGet(id)]
  end

  def pbSetEventTime(*arg)
    $PokemonGlobal.eventvars = {} if !$PokemonGlobal.eventvars
    time = pbGetTimeNow
    time = time.to_i
    pbSetSelfSwitch(@event_id, "A", true)
    $PokemonGlobal.eventvars[[@map_id, @event_id]] = time
    arg.each do |otherevt|
      pbSetSelfSwitch(otherevt, "A", true)
      $PokemonGlobal.eventvars[[@map_id, otherevt]] = time
    end
  end

  # Used in boulder events. Allows an event to be pushed.
  def pbPushThisEvent
    event = get_self
    old_x  = event.x
    old_y  = event.y
    # Apply strict version of passable, which treats tiles that are passable
    # only from certain directions as fully impassible
    return if !event.can_move_in_direction?($game_player.direction, true)
    $stats.strength_push_count += 1
    case $game_player.direction
    when 2 then event.move_down
    when 4 then event.move_left
    when 6 then event.move_right
    when 8 then event.move_up
    end
    $PokemonMap&.addMovedEvent(@event_id)
    if old_x != event.x || old_y != event.y
      $game_player.lock
      loop do
        Graphics.update
        Input.update
        pbUpdateSceneMap
        break if !event.moving?
      end
      $game_player.unlock
    end
  end

  def pbPushThisBoulder
    pbPushThisEvent if $PokemonMap.strengthUsed
    return true
  end

  def pbSmashThisEvent
    event = get_self
    pbSmashEvent(event) if event
    @index += 1
    return true
  end

  def pbTrainerIntro(symbol)
    return true if $DEBUG && !GameData::TrainerType.exists?(symbol)
    tr_type = GameData::TrainerType.get(symbol).id
    pbGlobalLock
    pbPlayTrainerIntroBGM(tr_type)
    return true
  end

  def pbTrainerEnd
    pbGlobalUnlock
    event = get_self
    event&.erase_route
  end

  def setPrice(item, buy_price = -1, sell_price = -1)
    item = GameData::Item.get(item).id
    $game_temp.mart_prices[item] = [-1, -1] if !$game_temp.mart_prices[item]
    $game_temp.mart_prices[item][0] = buy_price if buy_price > 0
    if sell_price >= 0   # 0=can't sell
      $game_temp.mart_prices[item][1] = sell_price * 2
    elsif buy_price > 0
      $game_temp.mart_prices[item][1] = buy_price
    end
  end

  def setSellPrice(item, sell_price)
    setPrice(item, -1, sell_price)
  end
end
