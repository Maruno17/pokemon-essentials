#===============================================================================
#
#===============================================================================
class PokemonPauseMenu_Scene
  def pbStartScene
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["cmdwindow"] = Window_CommandPokemon.new([])
    @sprites["cmdwindow"].visible = false
    @sprites["cmdwindow"].viewport = @viewport
    @sprites["infowindow"] = Window_UnformattedTextPokemon.newWithSize("",0,0,32,32,@viewport)
    @sprites["infowindow"].visible = false
    @sprites["helpwindow"] = Window_UnformattedTextPokemon.newWithSize("",0,0,32,32,@viewport)
    @sprites["helpwindow"].visible = false
    @infostate = false
    @helpstate = false
    pbSEPlay("GUI menu open")
  end

  def pbShowInfo(text)
    @sprites["infowindow"].resizeToFit(text,Graphics.height)
    @sprites["infowindow"].text    = text
    @sprites["infowindow"].visible = true
    @infostate = true
  end

  def pbShowHelp(text)
    @sprites["helpwindow"].resizeToFit(text,Graphics.height)
    @sprites["helpwindow"].text    = text
    @sprites["helpwindow"].visible = true
    pbBottomLeft(@sprites["helpwindow"])
    @helpstate = true
  end

  def pbShowMenu
    @sprites["cmdwindow"].visible = true
    @sprites["infowindow"].visible = @infostate
    @sprites["helpwindow"].visible = @helpstate
  end

  def pbHideMenu
    @sprites["cmdwindow"].visible = false
    @sprites["infowindow"].visible = false
    @sprites["helpwindow"].visible = false
  end

  def pbShowCommands(commands)
    ret = -1
    cmdwindow = @sprites["cmdwindow"]
    cmdwindow.commands = commands
    cmdwindow.index    = $PokemonTemp.menuLastChoice
    cmdwindow.resizeToFit(commands)
    cmdwindow.x        = Graphics.width-cmdwindow.width
    cmdwindow.y        = 0
    cmdwindow.visible  = true
    loop do
      cmdwindow.update
      Graphics.update
      Input.update
      pbUpdateSceneMap
      if Input.trigger?(Input::BACK)
        ret = -1
        break
      elsif Input.trigger?(Input::USE)
        ret = cmdwindow.index
        $PokemonTemp.menuLastChoice = ret
        break
      end
    end
    return ret
  end

  def pbEndScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbRefresh; end
end

#===============================================================================
#
#===============================================================================
class PokemonPauseMenu
  def initialize(scene)
    @scene = scene
  end

  def pbShowMenu
    @scene.pbRefresh
    @scene.pbShowMenu
  end

  def pbStartPokemonMenu
    if !$Trainer
      if $DEBUG
        pbMessage(_INTL("The player trainer was not defined, so the pause menu can't be displayed."))
        pbMessage(_INTL("Please see the documentation to learn how to set up the trainer player."))
      end
      return
    end
    @scene.pbStartScene
    endscene = true
    commands = []
    cmdPokedex  = -1
    cmdPokemon  = -1
    cmdBag      = -1
    cmdTrainer  = -1
    cmdSave     = -1
    cmdOption   = -1
    cmdPokegear = -1
    cmdDebug    = -1
    cmdQuit     = -1
    cmdEndGame  = -1
    if $Trainer.has_pokedex && $Trainer.pokedex.accessible_dexes.length > 0
      commands[cmdPokedex = commands.length] = _INTL("Pokédex")
    end
    commands[cmdPokemon = commands.length]   = _INTL("Pokémon") if $Trainer.party_count > 0
    commands[cmdBag = commands.length]       = _INTL("Bag") if !pbInBugContest?
    commands[cmdPokegear = commands.length]  = _INTL("Pokégear") if $Trainer.has_pokegear
    commands[cmdTrainer = commands.length]   = $Trainer.name
    if pbInSafari?
      if Settings::SAFARI_STEPS <= 0
        @scene.pbShowInfo(_INTL("Balls: {1}",pbSafariState.ballcount))
      else
        @scene.pbShowInfo(_INTL("Steps: {1}/{2}\nBalls: {3}",
           pbSafariState.steps, Settings::SAFARI_STEPS, pbSafariState.ballcount))
      end
      commands[cmdQuit = commands.length]    = _INTL("Quit")
    elsif pbInBugContest?
      if pbBugContestState.lastPokemon
        @scene.pbShowInfo(_INTL("Caught: {1}\nLevel: {2}\nBalls: {3}",
           pbBugContestState.lastPokemon.speciesName,
           pbBugContestState.lastPokemon.level,
           pbBugContestState.ballcount))
      else
        @scene.pbShowInfo(_INTL("Caught: None\nBalls: {1}",pbBugContestState.ballcount))
      end
      commands[cmdQuit = commands.length]    = _INTL("Quit Contest")
    else
      commands[cmdSave = commands.length]    = _INTL("Save") if $game_system && !$game_system.save_disabled
    end
    commands[cmdOption = commands.length]    = _INTL("Options")
    commands[cmdDebug = commands.length]     = _INTL("Debug") if $DEBUG
    commands[cmdEndGame = commands.length]   = _INTL("Quit Game")
    loop do
      command = @scene.pbShowCommands(commands)
      if cmdPokedex>=0 && command==cmdPokedex
        pbPlayDecisionSE
        if Settings::USE_CURRENT_REGION_DEX
          pbFadeOutIn {
            scene = PokemonPokedex_Scene.new
            screen = PokemonPokedexScreen.new(scene)
            screen.pbStartScreen
            @scene.pbRefresh
          }
        else
          if $Trainer.pokedex.accessible_dexes.length == 1
            $PokemonGlobal.pokedexDex = $Trainer.pokedex.accessible_dexes[0]
            pbFadeOutIn {
              scene = PokemonPokedex_Scene.new
              screen = PokemonPokedexScreen.new(scene)
              screen.pbStartScreen
              @scene.pbRefresh
            }
          else
            pbFadeOutIn {
              scene = PokemonPokedexMenu_Scene.new
              screen = PokemonPokedexMenuScreen.new(scene)
              screen.pbStartScreen
              @scene.pbRefresh
            }
          end
        end
      elsif cmdPokemon>=0 && command==cmdPokemon
        pbPlayDecisionSE
        hiddenmove = nil
        pbFadeOutIn {
          sscene = PokemonParty_Scene.new
          sscreen = PokemonPartyScreen.new(sscene,$Trainer.party)
          hiddenmove = sscreen.pbPokemonScreen
          (hiddenmove) ? @scene.pbEndScene : @scene.pbRefresh
        }
        if hiddenmove
          $game_temp.in_menu = false
          pbUseHiddenMove(hiddenmove[0],hiddenmove[1])
          return
        end
      elsif cmdBag>=0 && command==cmdBag
        pbPlayDecisionSE
        item = nil
        pbFadeOutIn {
          scene = PokemonBag_Scene.new
          screen = PokemonBagScreen.new(scene,$PokemonBag)
          item = screen.pbStartScreen
          (item) ? @scene.pbEndScene : @scene.pbRefresh
        }
        if item
          $game_temp.in_menu = false
          pbUseKeyItemInField(item)
          return
        end
      elsif cmdPokegear>=0 && command==cmdPokegear
        pbPlayDecisionSE
        pbFadeOutIn {
          scene = PokemonPokegear_Scene.new
          screen = PokemonPokegearScreen.new(scene)
          screen.pbStartScreen
          @scene.pbRefresh
        }
      elsif cmdTrainer>=0 && command==cmdTrainer
        pbPlayDecisionSE
        pbFadeOutIn {
          scene = PokemonTrainerCard_Scene.new
          screen = PokemonTrainerCardScreen.new(scene)
          screen.pbStartScreen
          @scene.pbRefresh
        }
      elsif cmdQuit>=0 && command==cmdQuit
        @scene.pbHideMenu
        if pbInSafari?
          if pbConfirmMessage(_INTL("Would you like to leave the Safari Game right now?"))
            @scene.pbEndScene
            pbSafariState.decision = 1
            pbSafariState.pbGoToStart
            return
          else
            pbShowMenu
          end
        else
          if pbConfirmMessage(_INTL("Would you like to end the Contest now?"))
            @scene.pbEndScene
            pbBugContestState.pbStartJudging
            return
          else
            pbShowMenu
          end
        end
      elsif cmdSave>=0 && command==cmdSave
        @scene.pbHideMenu
        scene = PokemonSave_Scene.new
        screen = PokemonSaveScreen.new(scene)
        if screen.pbSaveScreen
          @scene.pbEndScene
          endscene = false
          break
        else
          pbShowMenu
        end
      elsif cmdOption>=0 && command==cmdOption
        pbPlayDecisionSE
        pbFadeOutIn {
          scene = PokemonOption_Scene.new
          screen = PokemonOptionScreen.new(scene)
          screen.pbStartScreen
          pbUpdateSceneMap
          @scene.pbRefresh
        }
      elsif cmdDebug>=0 && command==cmdDebug
        pbPlayDecisionSE
        pbFadeOutIn {
          pbDebugMenu
          @scene.pbRefresh
        }
      elsif cmdEndGame>=0 && command==cmdEndGame
        @scene.pbHideMenu
        if pbConfirmMessage(_INTL("Are you sure you want to quit the game?"))
          scene = PokemonSave_Scene.new
          screen = PokemonSaveScreen.new(scene)
          if screen.pbSaveScreen
            @scene.pbEndScene
          end
          @scene.pbEndScene
          $scene = nil
          return
        else
          pbShowMenu
        end
      else
        pbPlayCloseMenuSE
        break
      end
    end
    @scene.pbEndScene if endscene
  end
end
