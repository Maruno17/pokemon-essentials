#===============================================================================
#
#===============================================================================
class PokemonJukebox_Scene
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(commands)
    @commands = commands
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap(_INTL("Graphics/UI/jukebox_bg"))
    @sprites["header"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Jukebox"), 2, -18, 128, 64, @viewport
    )
    @sprites["header"].baseColor   = Color.new(248, 248, 248)
    @sprites["header"].shadowColor = Color.black
    @sprites["header"].windowskin  = nil
    @sprites["commands"] = Window_CommandPokemon.newWithSize(
      @commands, 94, 92, 324, 224, @viewport
    )
    @sprites["commands"].windowskin = nil
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbScene
    ret = -1
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::BACK)
        break
      elsif Input.trigger?(Input::USE)
        ret = @sprites["commands"].index
        break
      end
    end
    return ret
  end

  def pbSetCommands(newcommands, newindex)
    @sprites["commands"].commands = (!newcommands) ? @commands : newcommands
    @sprites["commands"].index    = newindex
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

#===============================================================================
#
#===============================================================================
class PokemonJukeboxScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    commands = []
    cmdMarch   = -1
    cmdLullaby = -1
    cmdOak     = -1
    cmdCustom  = -1
    cmdTurnOff = -1
    commands[cmdMarch = commands.length]   = _INTL("Play: Pokémon March")
    commands[cmdLullaby = commands.length] = _INTL("Play: Pokémon Lullaby")
    commands[cmdOak = commands.length]     = _INTL("Play: Oak")
    commands[cmdCustom = commands.length]  = _INTL("Play: Custom...")
    commands[cmdTurnOff = commands.length] = _INTL("Stop")
    commands[commands.length]              = _INTL("Exit")
    @scene.pbStartScene(commands)
    loop do
      cmd = @scene.pbScene
      if cmd < 0
        pbPlayCloseMenuSE
        break
      elsif cmdMarch >= 0 && cmd == cmdMarch
        pbPlayDecisionSE
        pbBGMPlay("Radio - March", 100, 100)
        if $PokemonMap
          $PokemonMap.lower_encounter_rate = false
          $PokemonMap.higher_encounter_rate = true
        end
      elsif cmdLullaby >= 0 && cmd == cmdLullaby
        pbPlayDecisionSE
        pbBGMPlay("Radio - Lullaby", 100, 100)
        if $PokemonMap
          $PokemonMap.lower_encounter_rate = true
          $PokemonMap.higher_encounter_rate = false
        end
      elsif cmdOak >= 0 && cmd == cmdOak
        pbPlayDecisionSE
        pbBGMPlay("Radio - Oak", 100, 100)
        if $PokemonMap
          $PokemonMap.lower_encounter_rate = false
          $PokemonMap.higher_encounter_rate = false
        end
      elsif cmdCustom >= 0 && cmd == cmdCustom
        pbPlayDecisionSE
        files = []
        Dir.chdir("Audio/BGM/") do
          Dir.glob("*.ogg") { |f| files.push(f) }
          Dir.glob("*.wav") { |f| files.push(f) }
          Dir.glob("*.mid") { |f| files.push(f) }
          Dir.glob("*.midi") { |f| files.push(f) }
        end
        files.map! { |f| File.basename(f, ".*") }
        files.uniq!
        files.sort! { |a, b| a.downcase <=> b.downcase }
        @scene.pbSetCommands(files, 0)
        loop do
          cmd2 = @scene.pbScene
          if cmd2 < 0
            pbPlayCancelSE
            break
          end
          pbPlayDecisionSE
          $game_system.setDefaultBGM(files[cmd2])
          if $PokemonMap
            $PokemonMap.lower_encounter_rate = false
            $PokemonMap.higher_encounter_rate = false
          end
        end
        @scene.pbSetCommands(nil, cmdCustom)
      elsif cmdTurnOff >= 0 && cmd == cmdTurnOff
        pbPlayDecisionSE
        $game_system.setDefaultBGM(nil)
        pbBGMPlay(pbResolveAudioFile($game_map.bgm_name, $game_map.bgm.volume, $game_map.bgm.pitch))
        if $PokemonMap
          $PokemonMap.lower_encounter_rate = false
          $PokemonMap.higher_encounter_rate = false
        end
      else   # Exit
        pbPlayCloseMenuSE
        break
      end
    end
    @scene.pbEndScene
  end
end
