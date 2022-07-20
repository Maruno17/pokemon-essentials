#===============================================================================
# ** Game_CommonEvent
#-------------------------------------------------------------------------------
#  This class handles common events. It includes execution of parallel process
#  event. This class is used within the Game_Map class ($game_map).
#===============================================================================
class Game_CommonEvent
  #-----------------------------------------------------------------------------
  # * Object Initialization
  #     common_event_id : common event ID
  #-----------------------------------------------------------------------------
  def initialize(common_event_id)
    @common_event_id = common_event_id
    @interpreter = nil
    refresh
  end
  #-----------------------------------------------------------------------------
  # * Get Name
  #-----------------------------------------------------------------------------
  def name
    return $data_common_events[@common_event_id].name
  end
  #-----------------------------------------------------------------------------
  # * Get Trigger
  #-----------------------------------------------------------------------------
  def trigger
    return $data_common_events[@common_event_id].trigger
  end
  #-----------------------------------------------------------------------------
  # * Get Condition Switch ID
  #-----------------------------------------------------------------------------
  def switch_id
    return $data_common_events[@common_event_id].switch_id
  end
  #-----------------------------------------------------------------------------
  # * Get List of Event Commands
  #-----------------------------------------------------------------------------
  def list
    return $data_common_events[@common_event_id].list
  end
  #-----------------------------------------------------------------------------
  # * Checks if switch is on
  #-----------------------------------------------------------------------------
  def switchIsOn?(id)
    switchName = $data_system.switches[id]
    return false if !switchName
    if switchName[/^s\:/]
      return eval($~.post_match)
    else
      return $game_switches[id]
    end
  end
  #-----------------------------------------------------------------------------
  # * Refresh
  #-----------------------------------------------------------------------------
  def refresh
    # Create an interpreter for parallel process if necessary
    if self.trigger == 2 && switchIsOn?(self.switch_id)
      if @interpreter.nil?
        @interpreter = Interpreter.new
      end
    else
      @interpreter = nil
    end
  end
  #-----------------------------------------------------------------------------
  # * Frame Update
  #-----------------------------------------------------------------------------
  def update
    return if !@interpreter
    # Set up event if interpreter is not running
    @interpreter.setup(self.list, 0) if !@interpreter.running?
    # Update interpreter
    @interpreter.update
  end
end
