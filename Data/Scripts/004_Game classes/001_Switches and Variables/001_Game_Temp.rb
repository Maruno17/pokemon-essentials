#===============================================================================
# ** Game_Temp
#-------------------------------------------------------------------------------
#  This class handles temporary data that is not included with save data.
#  Refer to "$game_temp" for the instance of this class.
#===============================================================================
class Game_Temp
  # Flags requesting something to happen
  attr_accessor :menu_calling             # menu calling flag
  attr_accessor :ready_menu_calling       # ready menu calling flag
  attr_accessor :debug_calling            # debug calling flag
  attr_accessor :interact_calling         # EventHandlers.trigger(:on_player_interact) flag
  attr_accessor :battle_abort             # battle flag: interrupt (unused)
  attr_accessor :title_screen_calling     # return to title screen flag
  attr_accessor :common_event_id          # common event ID to start
  # Flags indicating something is happening
  attr_accessor :in_menu                  # menu is open
  attr_accessor :in_storage               # in-Pokémon storage flag
  attr_accessor :in_battle                # in-battle flag
  attr_accessor :message_window_showing   # message window showing
  attr_accessor :ending_surf              # jumping off surf base flag
  attr_accessor :surf_base_coords         # [x, y] while jumping on/off, or nil
  attr_accessor :in_mini_update           # performing mini update flag
  # Battle
  attr_accessor :battleback_name          # battleback file name
  attr_accessor :force_single_battle      # force next battle to be 1v1 flag
  attr_accessor :waiting_trainer          # [trainer, event ID] or nil
  attr_accessor :last_battle_record       # record of actions in last recorded battle
  # Player transfers
  attr_accessor :player_transferring      # player place movement flag
  attr_accessor :player_new_map_id        # player destination: map ID
  attr_accessor :player_new_x             # player destination: x-coordinate
  attr_accessor :player_new_y             # player destination: y-coordinate
  attr_accessor :player_new_direction     # player destination: direction
  attr_accessor :fly_destination          # [map ID, x, y] or nil
  # Transitions
  attr_accessor :transition_processing    # transition processing flag
  attr_accessor :transition_name          # transition file name
  attr_accessor :background_bitmap
  attr_accessor :fadestate                # for sprite hashes
  # Other
  attr_accessor :begun_new_game           # new game flag (true fron new game until saving)
  attr_accessor :menu_beep                # menu: play sound effect flag
  attr_accessor :menu_last_choice         # pause menu: index of last selection
  attr_accessor :memorized_bgm            # set when trainer intro BGM is played
  attr_accessor :memorized_bgm_position   # set when trainer intro BGM is played
  attr_accessor :darkness_sprite          # DarknessSprite or nil
  attr_accessor :mart_prices

  #-----------------------------------------------------------------------------
  # * Object Initialization
  #-----------------------------------------------------------------------------
  def initialize
    # Flags requesting something to happen
    @menu_calling           = false
    @ready_menu_calling     = false
    @debug_calling          = false
    @interact_calling       = false
    @battle_abort           = false
    @title_screen_calling   = false
    @common_event_id        = 0
    # Flags indicating something is happening
    @in_menu                = false
    @in_storage             = false
    @in_battle              = false
    @message_window_showing = false
    @ending_surf            = false
    @in_mini_update         = false
    # Battle
    @battleback_name        = ""
    @force_single_battle    = false
    # Player transfers
    @player_transferring    = false
    @player_new_map_id      = 0
    @player_new_x           = 0
    @player_new_y           = 0
    @player_new_direction   = 0
    # Transitions
    @transition_processing  = false
    @transition_name        = ""
    @fadestate              = 0
    # Other
    @begun_new_game         = false
    @menu_beep              = false
    @memorized_bgm          = nil
    @memorized_bgm_position = 0
    @menu_last_choice       = 0
    @mart_prices            = {}
  end

  def clear_mart_prices
    @mart_prices = {}
  end
end
