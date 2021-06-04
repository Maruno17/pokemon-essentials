#===============================================================================
# Fishing
#===============================================================================
def pbFishing(hasEncounter,rodType=1)
  speedup = ($Trainer.first_pokemon && [:STICKYHOLD, :SUCTIONCUPS].include?($Trainer.first_pokemon.ability_id))
  biteChance = 100
  hookChance = 100
  oldpattern = $game_player.fullPattern
  msgWindow = pbCreateMessageWindow
  ret = true
  loop do
    time = 8+rand(6)
    time = [time,5+rand(6)].min if speedup
    message = ""
    time.times { message += ".   " }
    if pbWaitMessage(msgWindow,time)
      $game_player.setDefaultCharName(nil,oldpattern)
      break
    end
    if hasEncounter && rand(100)<biteChance
      $scene.spriteset.addUserAnimation(Settings::EXCLAMATION_ANIMATION_ID,$game_player.x,$game_player.y,true,3)
      frames = Graphics.frame_rate - rand(Graphics.frame_rate/2)   # 0.5-1 second
        $game_player.setDefaultCharName(nil,oldpattern)
        break
      end
      if Settings::FISHING_AUTO_HOOK || rand(100) < hookChance
        $game_player.setDefaultCharName(nil,oldpattern)
        ret = true
        break
      end
#      biteChance += 15
#      hookChance += 15
  end
  pbDisposeMessageWindow(msgWindow)
  return ret
end

# Show waiting dots before a Pokemon bites
def pbWaitMessage(msgWindow,time)
  message = ""
  periodTime = Graphics.frame_rate*4/10   # 0.4 seconds, 16 frames per dot
  (time+1).times do |i|
    message += ".   " if i>0
    pbMessageDisplay(msgWindow,message,false)
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

# A Pokemon is biting, reflex test to reel it in
def pbWaitForInput(msgWindow,message,frames)
  pbMessageDisplay(msgWindow,message,false)
  numFrame = 0
  twitchFrame = 0
  twitchFrameTime = Graphics.frame_rate/10   # 0.1 seconds, 4 frames
  loop do
    Graphics.update
    Input.update
    pbUpdateSceneMap
    # Twitch cycle: 1,0,1,0,0,0,0,0
    twitchFrame = (twitchFrame+1)%(twitchFrameTime*8)
    case twitchFrame%twitchFrameTime
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
