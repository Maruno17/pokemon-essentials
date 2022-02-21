def pbEmergencySave
  oldscene = $scene
  $scene = nil
  pbMessage(_INTL("The script is taking too long. The game will restart."))
  return if !$player
  if SaveData.exists?
    File.open(SaveData::FILE_PATH, "rb") do |r|
      File.open(SaveData::FILE_PATH + ".bak", "wb") do |w|
        loop do
          s = r.read(4096)
          break if !s
          w.write(s)
        end
      end
    end
  end
  if Game.save
    pbMessage(_INTL("\\se[]The game was saved.\\me[GUI save game] The previous save file has been backed up.\\wtnp[30]"))
  else
    pbMessage(_INTL("\\se[]Save failed.\\wtnp[30]"))
  end
  $scene = oldscene
end

#===============================================================================
#
#===============================================================================
class PokemonSave_Scene
  def pbStartScreen
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    totalsec = $stats.play_time.to_i
    hour = totalsec / 60 / 60
    min = totalsec / 60 % 60
    mapname = $game_map.name
    textColor = ["0070F8,78B8E8", "E82010,F8A8B8", "0070F8,78B8E8"][$player.gender]
    locationColor = "209808,90F090"   # green
    loctext = _INTL("<ac><c3={1}>{2}</c3></ac>", locationColor, mapname)
    loctext += _INTL("Player<r><c3={1}>{2}</c3><br>", textColor, $player.name)
    if hour > 0
      loctext += _INTL("Time<r><c3={1}>{2}h {3}m</c3><br>", textColor, hour, min)
    else
      loctext += _INTL("Time<r><c3={1}>{2}m</c3><br>", textColor, min)
    end
    loctext += _INTL("Badges<r><c3={1}>{2}</c3><br>", textColor, $player.badge_count)
    if $player.has_pokedex
      loctext += _INTL("Pokédex<r><c3={1}>{2}/{3}</c3>", textColor, $player.pokedex.owned_count, $player.pokedex.seen_count)
    end
    @sprites["locwindow"] = Window_AdvancedTextPokemon.new(loctext)
    @sprites["locwindow"].viewport = @viewport
    @sprites["locwindow"].x = 0
    @sprites["locwindow"].y = 0
    @sprites["locwindow"].width = 228 if @sprites["locwindow"].width < 228
    @sprites["locwindow"].visible = true
  end

  def pbEndScreen
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

#===============================================================================
#
#===============================================================================
class PokemonSaveScreen
  def initialize(scene)
    @scene = scene
  end

  def pbDisplay(text, brief = false)
    @scene.pbDisplay(text, brief)
  end

  def pbDisplayPaused(text)
    @scene.pbDisplayPaused(text)
  end

  def pbConfirm(text)
    return @scene.pbConfirm(text)
  end

  def pbSaveScreen
    ret = false
    @scene.pbStartScreen
    if pbConfirmMessage(_INTL("Would you like to save the game?"))
      if SaveData.exists? && $game_temp.begun_new_game
        pbMessage(_INTL("WARNING!"))
        pbMessage(_INTL("There is a different game file that is already saved."))
        pbMessage(_INTL("If you save now, the other file's adventure, including items and Pokémon, will be entirely lost."))
        if !pbConfirmMessageSerious(_INTL("Are you sure you want to save now and overwrite the other save file?"))
          pbSEPlay("GUI save choice")
          @scene.pbEndScreen
          return false
        end
      end
      $game_temp.begun_new_game = false
      pbSEPlay("GUI save choice")
      if Game.save
        pbMessage(_INTL("\\se[]{1} saved the game.\\me[GUI save game]\\wtnp[30]", $player.name))
        ret = true
      else
        pbMessage(_INTL("\\se[]Save failed.\\wtnp[30]"))
        ret = false
      end
    else
      pbSEPlay("GUI save choice")
    end
    @scene.pbEndScreen
    return ret
  end
end

#===============================================================================
#
#===============================================================================
def pbSaveScreen
  scene = PokemonSave_Scene.new
  screen = PokemonSaveScreen.new(scene)
  ret = screen.pbSaveScreen
  return ret
end
