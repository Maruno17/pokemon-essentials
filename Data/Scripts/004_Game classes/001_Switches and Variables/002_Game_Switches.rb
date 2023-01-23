#===============================================================================
# ** Game_Switches
#-------------------------------------------------------------------------------
#  This class handles switches. It's a wrapper for the built-in class "Array."
#  Refer to "$game_switches" for the instance of this class.
#===============================================================================
class Game_Switches
  def initialize
    @data = []
  end

  # Get Switch
  #     switch_id : switch ID
  def [](switch_id)
    return @data[switch_id] if switch_id <= 5000 && @data[switch_id]
    return false
  end

  # Set Switch
  #     switch_id : switch ID
  #     value     : ON (true) / OFF (false)
  def []=(switch_id, value)
    @data[switch_id] = value if switch_id <= 5000
  end
end
