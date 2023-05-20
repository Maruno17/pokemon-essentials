#===============================================================================
# Fishing
#===============================================================================
def pbFishingBegin
  $PokemonGlobal.fishing = true
  if !pbCommonEvent(Settings::FISHING_BEGIN_COMMON_EVENT)
    $game_player.set_movement_type(($PokemonGlobal.surfing) ? :surf_fishing : :fishing)
    $game_player.lock_pattern = true
    4.times do |pattern|
      $game_player.pattern = 3 - pattern
      pbWait(0.05)
    end
  end
end

def pbFishingEnd
  if !pbCommonEvent(Settings::FISHING_END_COMMON_EVENT)
    4.times do |pattern|
      $game_player.pattern = pattern
      pbWait(0.05)
    end
  end
  yield if block_given?
  $game_player.set_movement_type(($PokemonGlobal.surfing) ? :surfing_stopped : :walking_stopped)
  $game_player.lock_pattern = false
  $game_player.straighten
  $PokemonGlobal.fishing = false
end

def pbFishing(hasEncounter, rodType = 1)
  $stats.fishing_count += 1
  speedup = ($player.first_pokemon && [:STICKYHOLD, :SUCTIONCUPS].include?($player.first_pokemon.ability_id))
  biteChance = 20 + (25 * rodType)   # 45, 70, 95
  biteChance *= 1.5 if speedup   # 67.5, 100, 100
  hookChance = 100
  pbFishingBegin
  msgWindow = pbCreateMessageWindow
  ret = false
  loop do
    time = rand(5..10)
    time = [time, rand(5..10)].min if speedup
    message = ""
    time.times { message += ".   " }
    if pbWaitMessage(msgWindow, time)
      pbFishingEnd { pbMessageDisplay(msgWindow, _INTL("Not even a nibble...")) }
      break
    end
    if hasEncounter && rand(100) < biteChance
      $scene.spriteset.addUserAnimation(Settings::EXCLAMATION_ANIMATION_ID, $game_player.x, $game_player.y, true, 3)
      duration = rand(5..10) / 10.0   # 0.5-1 seconds
      if !pbWaitForInput(msgWindow, message + "\n" + _INTL("Oh! A bite!"), duration)
        pbFishingEnd { pbMessageDisplay(msgWindow, _INTL("The Pokémon got away...")) }
        break
      end
      if Settings::FISHING_AUTO_HOOK || rand(100) < hookChance
        pbFishingEnd do
          pbMessageDisplay(msgWindow, _INTL("Landed a Pokémon!")) if !Settings::FISHING_AUTO_HOOK
        end
        ret = true
        break
      end
#      biteChance += 15
#      hookChance += 15
    else
      pbFishingEnd { pbMessageDisplay(msgWindow, _INTL("Not even a nibble...")) }
      break
    end
  end
  pbDisposeMessageWindow(msgWindow)
  return ret
end

# Show waiting dots before a Pokémon bites
def pbWaitMessage(msgWindow, time)
  message = ""
  (time + 1).times do |i|
    message += ".   " if i > 0
    pbMessageDisplay(msgWindow, message, false)
    pbWait(0.4) do |delta_t|
      return true if Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
    end
  end
  return false
end

# A Pokémon is biting, reflex test to reel it in
def pbWaitForInput(msgWindow, message, duration)
  pbMessageDisplay(msgWindow, message, false)
  twitch_frame_duration = 0.2   # 0.2 seconds
  timer_start = System.uptime
  loop do
    Graphics.update
    Input.update
    pbUpdateSceneMap
    # Twitch cycle: 1,0,1,0,0,0,0,0
    twitch_frame = ((System.uptime - timer_start) / twitch_frame_duration).to_i % 8
    case twitch_frame
    when 0, 2
      $game_player.pattern = 1
    else
      $game_player.pattern = 0
    end
    if Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
      $game_player.pattern = 0
      return true
    end
    break if !Settings::FISHING_AUTO_HOOK && System.uptime - timer_start > duration
  end
  return false
end
