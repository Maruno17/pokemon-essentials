#===============================================================================
# ** Game_Temp
#-------------------------------------------------------------------------------
#  This class handles temporary data that is not included with save data.
#  Refer to "$game_temp" for the instance of this class.
#===============================================================================
class Game_Temp
  attr_accessor :message_window_showing   # message window showing
  attr_accessor :common_event_id          # common event ID
  attr_accessor :in_battle                # in-battle flag
  attr_accessor :battle_abort             # battle flag: interrupt
  attr_accessor :battleback_name          # battleback file name
  attr_accessor :in_menu                  # menu is open
  attr_accessor :menu_beep                # menu: play sound effect flag
  attr_accessor :menu_calling             # menu calling flag
  attr_accessor :debug_calling            # debug calling flag
  attr_accessor :player_transferring      # player place movement flag
  attr_accessor :player_new_map_id        # player destination: map ID
  attr_accessor :player_new_x             # player destination: x-coordinate
  attr_accessor :player_new_y             # player destination: y-coordinate
  attr_accessor :player_new_direction     # player destination: direction
  attr_accessor :transition_processing    # transition processing flag
  attr_accessor :transition_name          # transition file name
  attr_accessor :to_title                 # return to title screen flag
  attr_accessor :fadestate                # for sprite hashes
  attr_accessor :background_bitmap
  attr_accessor :mart_prices
  #-----------------------------------------------------------------------------
  # * Object Initialization
  #-----------------------------------------------------------------------------
  def initialize
    @message_window_showing = false
    @common_event_id        = 0
    @in_battle              = false
    @battle_abort           = false
    @battleback_name        = ''
    @in_menu                = false
    @menu_beep              = false
    @menu_calling           = false
    @debug_calling          = false
    @player_transferring    = false
    @player_new_map_id      = 0
    @player_new_x           = 0
    @player_new_y           = 0
    @player_new_direction   = 0
    @transition_processing  = false
    @transition_name        = ""
    @to_title               = false
    @fadestate              = 0
    @background_bitmap      = nil
    @message_window_showing = false
    @transition_processing  = false
    @mart_prices            = {}
  end

  def clear_mart_prices
    @mart_prices = {}
  end
end
