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
      (Graphics.frame_rate / 20).times do
        Graphics.update
        Input.update
        pbUpdateSceneMap
      end
    end
  end
end

def pbFishingEnd
  if !pbCommonEvent(Settings::FISHING_END_COMMON_EVENT)
    4.times do |pattern|
      $game_player.pattern = pattern
      (Graphics.frame_rate / 20).times do
        Graphics.update
        Input.update
        pbUpdateSceneMap
      end
    end
  end
  yield if block_given?
  $game_player.set_movement_type(($PokemonGlobal.surfing) ? :surfing : :walking)
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
      pbFishingEnd {
        pbMessageDisplay(msgWindow, _INTL("Not even a nibble..."))
      }
      break
    end
    if hasEncounter && rand(100) < biteChance
      $scene.spriteset.addUserAnimation(Settings::EXCLAMATION_ANIMATION_ID, $game_player.x, $game_player.y, true, 3)
      frames = Graphics.frame_rate - rand(Graphics.frame_rate / 2)   # 0.5-1 second
      if !pbWaitForInput(msgWindow, message + _INTL("\r\nOh! A bite!"), frames)
        pbFishingEnd {
          pbMessageDisplay(msgWindow, _INTL("The Pokémon got away..."))
        }
        break
      end
      if Settings::FISHING_AUTO_HOOK || rand(100) < hookChance
        pbFishingEnd {
          pbMessageDisplay(msgWindow, _INTL("Landed a Pokémon!")) if !Settings::FISHING_AUTO_HOOK
        }
        ret = true
        break
      end
#      biteChance += 15
#      hookChance += 15
    else
      pbFishingEnd {
        pbMessageDisplay(msgWindow, _INTL("Not even a nibble..."))
      }
      break
    end
  end
  pbDisposeMessageWindow(msgWindow)
  return ret
end

# Show waiting dots before a Pokémon bites
def pbWaitMessage(msgWindow, time)
  message = ""
  periodTime = Graphics.frame_rate * 4 / 10   # 0.4 seconds, 16 frames per dot
  (time + 1).times do |i|
    message += ".   " if i > 0
    pbMessageDisplay(msgWindow, message, false)
    periodTime.times do
      Graphics.update
      Input.update
      pbUpdateSceneMap
      if Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
        return true
      end
    end
  end
  return false
end

# A Pokémon is biting, reflex test to reel it in
def pbWaitForInput(msgWindow, message, frames)
  pbMessageDisplay(msgWindow, message, false)
  numFrame = 0
  twitchFrame = 0
  twitchFrameTime = Graphics.frame_rate * 2 / 10   # 0.2 seconds, 8 frames
  loop do
    Graphics.update
    Input.update
    pbUpdateSceneMap
    # Twitch cycle: 1,0,1,0,0,0,0,0
    twitchFrame = (twitchFrame + 1) % (twitchFrameTime * 8)
    case twitchFrame % twitchFrameTime
    when 0, 2
      $game_player.pattern = 1
    else
      $game_player.pattern = 0
    end
    if Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
      $game_player.pattern = 0
      return true
    end
    break if !Settings::FISHING_AUTO_HOOK && numFrame > frames
    numFrame += 1
  end
  return false
end
