#===============================================================================
# ** Game_CommonEvent
#-------------------------------------------------------------------------------
#  This class handles common events. It includes execution of parallel process
#  event. This class is used within the Game_Map class ($game_map).
#===============================================================================
class Game_CommonEvent
  def initialize(common_event_id)
    @common_event_id = common_event_id
    @interpreter = nil
    refresh
  end

  def name
    return $data_common_events[@common_event_id].name
  end

  def trigger
    return $data_common_events[@common_event_id].trigger
  end

  def switch_id
    return $data_common_events[@common_event_id].switch_id
  end

  def list
    return $data_common_events[@common_event_id].list
  end

  def switchIsOn?(id)
    switchName = $data_system.switches[id]
    return false if !switchName
    if switchName[/^s\:/]
      return eval($~.post_match)
    else
      return $game_switches[id]
    end
  end

  def refresh
    # Create an interpreter for parallel process if necessary
    if self.trigger == 2 && switchIsOn?(self.switch_id)
      @interpreter = Interpreter.new if @interpreter.nil?
    else
      @interpreter = nil
    end
  end

  def update
    return if !@interpreter
    # Set up event if interpreter is not running
    @interpreter.setup(self.list, 0) if !@interpreter.running?
    # Update interpreter
    @interpreter.update
  end
end
