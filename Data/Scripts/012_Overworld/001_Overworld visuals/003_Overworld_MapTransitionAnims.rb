#===============================================================================
# Entering/exiting cave animations
#===============================================================================
def pbCaveEntranceEx(exiting)
  # Create bitmap
  sprite = BitmapSprite.new(Graphics.width, Graphics.height)
  sprite.z = 100000
  # Define values used for the animation
  duration = 0.4
  totalBands = 15
  bandheight = ((Graphics.height / 2.0) - 10) / totalBands
  bandwidth  = ((Graphics.width / 2.0) - 12) / totalBands
  start_gray = (exiting) ? 0 : 255
  end_gray = (exiting) ? 255 : 0
  # Create initial array of band colors (black if exiting, white if entering)
  grays = Array.new(totalBands) { |i| start_gray }
  # Animate bands changing color
  timer_start = System.uptime
  until System.uptime - timer_start >= duration
    x = 0
    y = 0
    # Calculate color of each band
    totalBands.times do |k|
      grays[k] = lerp(start_gray, end_gray, duration, timer_start + (k * duration / totalBands), System.uptime)
    end
    # Draw gray rectangles
    rectwidth  = Graphics.width
    rectheight = Graphics.height
    totalBands.times do |i|
      currentGray = grays[i]
      sprite.bitmap.fill_rect(Rect.new(x, y, rectwidth, rectheight),
                              Color.new(currentGray, currentGray, currentGray))
      x += bandwidth
      y += bandheight
      rectwidth  -= bandwidth * 2
      rectheight -= bandheight * 2
    end
    Graphics.update
    Input.update
  end
  # Set the tone at end of band animation
  if exiting
    pbToneChangeAll(Tone.new(255, 255, 255), 0)
  else
    pbToneChangeAll(Tone.new(-255, -255, -255), 0)
  end
  # Animate fade to white (if exiting) or black (if entering)
  timer_start = System.uptime
  loop do
    sprite.color = Color.new(end_gray, end_gray, end_gray,
                             lerp(0, 255, duration, timer_start, System.uptime))
    Graphics.update
    Input.update
    break if sprite.color.alpha >= 255
  end
  # Set the tone at end of fading animation
  pbToneChangeAll(Tone.new(0, 0, 0), 8)
  # Pause briefly
  timer_start = System.uptime
  until System.uptime - timer_start >= 0.1
    Graphics.update
    Input.update
  end
  sprite.dispose
end

def pbCaveEntrance
  pbSetEscapePoint
  pbCaveEntranceEx(false)
end

def pbCaveExit
  pbEraseEscapePoint
  pbCaveEntranceEx(true)
end

#===============================================================================
# Blacking out animation
#===============================================================================
def pbStartOver(game_over = false)
  if pbInBugContest?
    pbBugContestStartOver
    return
  end
  $stats.blacked_out_count += 1
  $player.heal_party
  if $PokemonGlobal.pokecenterMapId && $PokemonGlobal.pokecenterMapId >= 0
    if game_over
      pbMessage("\\w[]\\wm\\c[8]\\l[3]" +
                _INTL("After the unfortunate defeat, you hurry to the Pokémon Center."))
    elsif $player.all_fainted?
      pbMessage("\\w[]\\wm\\c[8]\\l[3]" +
                _INTL("You hurry to the Pokémon Center, shielding your exhausted Pokémon from any further harm..."))
    else   # Forfeited a trainer battle
      pbMessage("\\w[]\\wm\\c[8]\\l[3]" +
                _INTL("You went running to the Pokémon Center to regroup and reconsider your battle strategy..."))
    end
    pbCancelVehicles
    Followers.clear
    $game_switches[Settings::STARTING_OVER_SWITCH] = true
    $game_temp.player_new_map_id    = $PokemonGlobal.pokecenterMapId
    $game_temp.player_new_x         = $PokemonGlobal.pokecenterX
    $game_temp.player_new_y         = $PokemonGlobal.pokecenterY
    $game_temp.player_new_direction = $PokemonGlobal.pokecenterDirection
    pbDismountBike
    $scene.transfer_player if $scene.is_a?(Scene_Map)
    $game_map.refresh
  else
    homedata = GameData::PlayerMetadata.get($player.character_ID)&.home
    homedata = GameData::Metadata.get.home if !homedata
    if homedata && !pbRgssExists?(sprintf("Data/Map%03d.rxdata", homedata[0]))
      if $DEBUG
        pbMessage(_ISPRINTF("Can't find the map 'Map{1:03d}' in the Data folder. The game will resume at the player's position.", homedata[0]))
      end
      $player.heal_party
      return
    end
    if game_over
      pbMessage("\\w[]\\wm\\c[8]\\l[3]" +
                _INTL("After the unfortunate defeat, you hurry back home."))
    elsif $player.all_fainted?
      pbMessage("\\w[]\\wm\\c[8]\\l[3]" +
                _INTL("You hurry back home, shielding your exhausted Pokémon from any further harm..."))
    else   # Forfeited a trainer battle
      pbMessage("\\w[]\\wm\\c[8]\\l[3]" +
                _INTL("You went running back home to regroup and reconsider your battle strategy..."))
    end
    if homedata
      pbCancelVehicles
      Followers.clear
      $game_switches[Settings::STARTING_OVER_SWITCH] = true
      $game_temp.player_new_map_id    = homedata[0]
      $game_temp.player_new_x         = homedata[1]
      $game_temp.player_new_y         = homedata[2]
      $game_temp.player_new_direction = homedata[3]
      pbDismountBike
      $scene.transfer_player if $scene.is_a?(Scene_Map)
      $game_map.refresh
    else
      $player.heal_party
    end
  end
  pbEraseEscapePoint
end
