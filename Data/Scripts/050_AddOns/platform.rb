#
# # ▼▲▼ XRXS50. Action-Maps XC. ▼▲▼ built 033010
# # by 桜雅 在土
#
# #======================================================
# # □ Customization points
# #======================================================
# class XRXS50
#   #
#   # Action-Maps - ID maps actives
#   #
#
#   ENABLE_FULL_ACTY_MAPS = [404,547,548,549,550,217,614,615,656]
#
#   #
#   # Slide descent (diagonal drop)
#   #
#   ENABLE_SLIDE_DESCENT = true
#   #
#   # true: Jump in the direction facing orientation: Jump
#   # false : Jump to the direction in which the key is pressed.
#   #
#   JUMP_AS_KEY = true
# end
# #======================================================
# # ■ Game_Player
# #======================================================
# class Game_Player < Game_Character
#   #------------------------------------------------------
#   # Public Variable
#   #------------------------------------------------------
#   # Existing
#   attr_writer :direction_fix
#   attr_accessor :walk_anime
#   # New
#   attr_accessor :now_jumps
#   attr_writer :xrxs50_direction_sidefix
#   #------------------------------------------------------
#   # ○Maximum jump number
#   #------------------------------------------------------
#   def max_jumps
#     return $game_switches[890] ? 5 : 2
#   end
#   #------------------------------------------------------
#   # ● Vers la gauche
#   #------------------------------------------------------
#   alias xrxs50_turn_left turn_left
#   def turn_left
#     if @xrxs50_direction_sidefix
#       @direction = 4
#     else
#       turn_generic(4)
#
#
#     end
#   end
#
#   #------------------------------------------------------
#   # ● Vers la droite
#   #------------------------------------------------------
#   alias xrxs50_turn_right turn_right
#   def turn_right
#     if @xrxs50_direction_sidefix
#       @direction = 6
#     else
#       turn_generic(6)
#     end
#   end
#   #------------------------------------------------------
#   # ● Vers le haut et le bas
#   #------------------------------------------------------
#   alias xrxs50_turn_up turn_up
#   def turn_up
#     if @xrxs50_direction_sidefix and Input.press?(Input::UP)
#       return if $game_switches[890]
#       @direction = 8
#       xrxs50_turn_up
#     else
#       turn_generic(8)
#     end
#   end
#
#   alias xrxs50_turn_down turn_down
#   def turn_down
#     if @xrxs50_direction_sidefix and Input.press?(Input::DOWN)
#       xrxs50_turn_right
#     else
#       turn_generic(2)
#     end
#   end
#
# end
#
#
#
#
# #======================================================
# # ■ Scene_Map
# #======================================================
# class Scene_Map
#   #------------------------------------------------------
#   # ● Main processing
#   #------------------------------------------------------
#   alias xrxs50_main main
#   def main
#     # Check
#     xrxs50_enable_check
#     # Recall
#     xrxs50_main
#   end
#   #------------------------------------------------------
#   # ● Frame update
#   #------------------------------------------------------
#   alias xrxs50_update update
#   def update
#     # Recall
#     xrxs50_update
#     # Frame update (coordinate system update)
#     if @xrxs50_enable
#       update_coordinates
#     end
#   end
#   #------------------------------------------------------
#   # ○ Frame update (coordinate system update)
#   #------------------------------------------------------
#   def update_coordinates
#     if $game_player.passable?($game_player.x,$game_player.y,2) #2
#       unless $game_player.moving?
#
#         if XRXS50::ENABLE_SLIDE_DESCENT and
#           Input.press?(Input::RIGHT) and
#           $game_player.passable?($game_player.x,$game_player.y+1,6) #1,6
#           $game_player.move_lower_right
#           $game_player.turn_right
#         elsif XRXS50::ENABLE_SLIDE_DESCENT and
#           Input.press?(Input::LEFT) and
#           $game_player.passable?($game_player.x,$game_player.y+1,4)
#           $game_player.move_lower_left
#           $game_player.turn_left
#         else
#           $game_player.move_down
#         end
#       end
#     else
#       if Input.trigger?(Input::UP) && !$game_switches[890]
#         @direction =8 #8
#       end
#       $game_player.move_down
#       $game_player.walk_anime = true unless $game_player.walk_anime
#       $game_player.now_jumps = 0
#
#
#     end
#
#     input = $game_switches[890] ? Input::UP  : Input::X
#     if Input.trigger?(input) and $game_player.now_jumps < $game_player.max_jumps
#       if XRXS50::JUMP_AS_KEY
#         direction = $game_player.direction == 4  ?  -1 : 1
#         #si pas jump as key
#       else
#         if Input.press?(Input::RIGHT)
#           direction = 1
#         elsif Input.press?(Input::LEFT)
#           direction = -1
#         else
#           direction = 0
#         end
#       end
#
#       #if $game_switches[31] == true
#       #         @direction =8 #8#  Jump Height
#       #else
#       $game_player.jump(direction, -2)#  Jump Height
#       pbSEPlay("Jump",100)
#       #end
#       $game_player.now_jumps += 1 #1
#       $game_player.walk_anime = false
#     end
#   end
#
#   #------------------------------------------------------
#   # ● Location movement of player
#   #------------------------------------------------------
#   #alias xrxs50_transfer_player transfer_player
#   #def transfer_player(cancelVehicles=false)
#   # #Recall
#   #xrxs50_transfer_player
#   # #Check
#   #xrxs50_enable_check
#   #end
#
#   def transfer_player(cancelVehicles=true)
#     $game_temp.player_transferring = false
#     if cancelVehicles
#       Kernel.pbCancelVehicles($game_temp.player_new_map_id)
#     end
#     autofade($game_temp.player_new_map_id)
#     pbBridgeOff
#     if $game_map.map_id != $game_temp.player_new_map_id
#       $MapFactory.setup($game_temp.player_new_map_id)
#     end
#     $game_player.moveto($game_temp.player_new_x, $game_temp.player_new_y)
#     case $game_temp.player_new_direction
#     when 2
#       $game_player.turn_down
#     when 4
#       $game_player.turn_left
#     when 6
#       $game_player.turn_right
#     when 8
#       $game_player.turn_up
#     end
#
#     xrxs50_enable_check
#     $game_player.straighten
#     $game_map.update
#     disposeSpritesets
#     GC.start
#     createSpritesets
#     if $game_temp.transition_processing
#       $game_temp.transition_processing = false
#       Graphics.transition(20)
#     end
#     $game_map.autoplay
#     Graphics.frame_reset
#     Input.update
#   end
#
#
#
#   #------------------------------------------------------
#   # ○ XRXS50 Decision whether to run
#   #------------------------------------------------------
#   def xrxs50_enable_check
#     if XRXS50::ENABLE_FULL_ACTY_MAPS.include?($game_map.map_id)
#
#       $game_player.now_jumps = 0 if $game_player.now_jumps.nil?
#       @xrxs50_enable = true #Gravité
#       $game_player.direction_fix =true
#       $game_player.xrxs50_direction_sidefix = true
#
#     else
#       @xrxs50_enable = false
#       $game_player.direction_fix = false
#       $game_player.xrxs50_direction_sidefix = false
#     end
#   end
# end
#
#
#
