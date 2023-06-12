#===============================================================================
# ** Modified Scene_Map class for Pokémon.
#-------------------------------------------------------------------------------
#
#===============================================================================
class Scene_Map
  attr_reader :spritesetGlobal
  attr_reader :map_renderer

  def spriteset(map_id = -1)
    return @spritesets[map_id] if map_id > 0 && @spritesets[map_id]
    @spritesets.each_value do |i|
      return i if i.map == $game_map
    end
    return @spritesets.values[0]
  end

  def createSpritesets
    @map_renderer = TilemapRenderer.new(Spriteset_Map.viewport) if !@map_renderer || @map_renderer.disposed?
    @spritesetGlobal = Spriteset_Global.new if !@spritesetGlobal
    @spritesets = {}
    $map_factory.maps.each do |map|
      @spritesets[map.map_id] = Spriteset_Map.new(map)
    end
    $map_factory.setSceneStarted(self)
    updateSpritesets(true)
  end

  def createSingleSpriteset(map)
    temp = $scene.spriteset.getAnimations
    @spritesets[map] = Spriteset_Map.new($map_factory.maps[map])
    $scene.spriteset.restoreAnimations(temp)
    $map_factory.setSceneStarted(self)
    updateSpritesets(true)
  end

  def disposeSpritesets
    return if !@spritesets
    @spritesets.each_key do |i|
      next if !@spritesets[i]
      @spritesets[i].dispose
      @spritesets[i] = nil
    end
    @spritesets.clear
    @spritesets = {}
  end

  def dispose
    disposeSpritesets
    @map_renderer.dispose
    @map_renderer = nil
    @spritesetGlobal.dispose
    @spritesetGlobal = nil
  end

  def autofade(mapid)
    playingBGM = $game_system.playing_bgm
    playingBGS = $game_system.playing_bgs
    return if !playingBGM && !playingBGS
    map = load_data(sprintf("Data/Map%03d.rxdata", mapid))
    if playingBGM && map.autoplay_bgm
      test_filename = map.bgm.name
      test_filename += "_n" if PBDayNight.isNight? && FileTest.audio_exist?("Audio/BGM/" + test_filename + "_n")
      pbBGMFade(0.8) if playingBGM.name != test_filename
    end
    if playingBGS && map.autoplay_bgs && playingBGS.name != map.bgs.name
      pbBGMFade(0.8)
    end
    Graphics.frame_reset
  end

  def transfer_player(cancel_swimming = true)
    $game_temp.player_transferring = false
    pbCancelVehicles($game_temp.player_new_map_id, cancel_swimming)
    autofade($game_temp.player_new_map_id)
    pbBridgeOff
    @spritesetGlobal.playersprite.clearShadows
    if $game_map.map_id != $game_temp.player_new_map_id
      $map_factory.setup($game_temp.player_new_map_id)
    end
    $game_player.moveto($game_temp.player_new_x, $game_temp.player_new_y)
    case $game_temp.player_new_direction
    when 2 then $game_player.turn_down
    when 4 then $game_player.turn_left
    when 6 then $game_player.turn_right
    when 8 then $game_player.turn_up
    end
    $game_player.straighten
    $game_temp.followers.map_transfer_followers
    $game_map.update
    disposeSpritesets
    RPG::Cache.clear
    createSpritesets
    if $game_temp.transition_processing
      $game_temp.transition_processing = false
      Graphics.transition
    end
    $game_map.autoplay
    Graphics.frame_reset
    Input.update
  end

  def call_menu
    $game_temp.menu_calling = false
    $game_temp.in_menu = true
    $game_player.straighten
    $game_map.update
    sscene = PokemonPauseMenu_Scene.new
    sscreen = PokemonPauseMenu.new(sscene)
    sscreen.pbStartPokemonMenu
    $game_temp.in_menu = false
  end

  def call_debug
    $game_temp.debug_calling = false
    pbPlayDecisionSE
    $game_player.straighten
    pbFadeOutIn { pbDebugMenu }
  end

  def miniupdate
    $game_temp.in_mini_update = true
    loop do
      $game_player.update
      updateMaps
      $game_system.update
      $game_screen.update
      break if !$game_temp.player_transferring
      transfer_player(false)
      break if $game_temp.transition_processing
    end
    updateSpritesets
    $game_temp.in_mini_update = false
  end

  def updateMaps
    $map_factory.maps.each do |map|
      map.update
    end
    $map_factory.updateMaps(self)
  end

  def updateSpritesets(refresh = false)
    @spritesets = {} if !@spritesets
    $map_factory.maps.each do |map|
      @spritesets[map.map_id] = Spriteset_Map.new(map) if !@spritesets[map.map_id]
    end
    keys = @spritesets.keys.clone
    keys.each do |i|
      if $map_factory.hasMap?(i)
        @spritesets[i].update
      else
        @spritesets[i]&.dispose
        @spritesets[i] = nil
        @spritesets.delete(i)
      end
    end
    @spritesetGlobal.update
    pbDayNightTint(@map_renderer)
    @map_renderer.refresh if refresh
    @map_renderer.update
    EventHandlers.trigger(:on_frame_update)
  end

  def update
    loop do
      pbMapInterpreter.update
      $game_player.update
      updateMaps
      $game_system.update
      $game_screen.update
      break if !$game_temp.player_transferring
      transfer_player(false)
      break if $game_temp.transition_processing
    end
    updateSpritesets
    if $game_temp.title_screen_calling
      SaveData.mark_values_as_unloaded
      $scene = pbCallTitle
      return
    end
    if $game_temp.transition_processing
      $game_temp.transition_processing = false
      if $game_temp.transition_name == ""
        Graphics.transition
      else
        Graphics.transition(40, "Graphics/Transitions/" + $game_temp.transition_name)
      end
    end
    return if $game_temp.message_window_showing
    if !pbMapInterpreterRunning? && !$PokemonGlobal.forced_movement?
      if Input.trigger?(Input::USE)
        $game_temp.interact_calling = true
      elsif Input.trigger?(Input::ACTION)
        if !$game_system.menu_disabled && !$game_player.moving?
          $game_temp.menu_calling = true
          $game_temp.menu_beep = true
        end
      elsif Input.trigger?(Input::SPECIAL)
        $game_temp.ready_menu_calling = true if !$game_player.moving?
      elsif Input.press?(Input::F9)
        $game_temp.debug_calling = true if $DEBUG
      end
    end
    if !$game_player.moving?
      if $game_temp.menu_calling
        call_menu
      elsif $game_temp.debug_calling
        call_debug
      elsif $game_temp.ready_menu_calling
        $game_temp.ready_menu_calling = false
        $game_player.straighten
        pbUseKeyItem
      elsif $game_temp.interact_calling
        $game_temp.interact_calling = false
        triggered = false
        # Try to trigger an event the player is standing on, and one in front of
        # the player
        if !$game_temp.in_mini_update
          triggered ||= $game_player.check_event_trigger_here([0])
          triggered ||= $game_player.check_event_trigger_there([0, 2]) if !triggered
        end
        # Try to trigger an interaction with a tile
        if !triggered
          $game_player.straighten
          EventHandlers.trigger(:on_player_interact)
        end
      end
    end
  end

  def main
    createSpritesets
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      update
      break if $scene != self
    end
    Graphics.freeze
    dispose
    if $game_temp.title_screen_calling
      pbMapInterpreter.command_end if pbMapInterpreterRunning?
      $game_temp.last_uptime_refreshed_play_time = nil
      $game_temp.title_screen_calling = false
      pbBGMFade(1.0)
      Graphics.transition
      Graphics.freeze
    end
  end
end
