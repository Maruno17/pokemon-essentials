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
    cmdwindow.index    = $game_temp.menu_last_choice
    cmdwindow.resizeToFit(commands)
    cmdwindow.x        = Graphics.width-cmdwindow.width
    cmdwindow.y        = 0
    cmdwindow.visible  = true
    loop do
      cmdwindow.update
      Graphics.update
      Input.update
      pbUpdateSceneMap
      if Input.trigger?(Input::BACK) || Input.trigger?(Input::ACTION)
        ret = -1
        break
      elsif Input.trigger?(Input::USE)
        ret = cmdwindow.index
        $game_temp.menu_last_choice = ret
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
    if !$player
      if $DEBUG
        pbMessage(_INTL("The player trainer was not defined, so the pause menu can't be displayed."))
        pbMessage(_INTL("Please see the documentation to learn how to set up the trainer player."))
      end
      return
    end
    @scene.pbStartScene
    endscene    = false
    commands    = []
    display_cmd = []
    PauseMenuCommands.each_availible do |option, name, info|
      commands.push(option)
      name = name.gsub("\\PN", $player.name)
      display_cmd.push(name)
      @scene.pbShowInfo(info) if !nil_or_empty?(info)
    end
    loop do
      command = @scene.pbShowCommands(display_cmd)
      if command < 0
        pbPlayCloseMenuSE
        break
      end
      cmd      = commands[command]
      endscene = PauseMenuCommands.call("effect", cmd, @scene)
      break if endscene
    end
    @scene.pbEndScene if !endscene
  end
end

#===============================================================================
# Module to register and handle commands in the Pause Menu
#===============================================================================
module PauseMenuCommands
  @@commands = HandlerHashBasic.new

  def self.register(option, hash)
    @@commands.add(option, hash)
  end

  def self.each_availible
    @@commands.each { |key, hash|
      name      = hash["name"]
      condition = hash["condition"]
      info      = (hash["info"] ? hash["info"].call : nil)
      yield key, name, info if condition&.call
    }
  end

  def self.call(function, option, *args)
    option_hash = @@commands[option]
    return nil if !option_hash || !option_hash[function]
    return (option_hash[function].call(*args) == true)
  end
end

#===============================================================================
# Individual commands for the Pause Menu
#===============================================================================
# Pokedex ----------------------------------------------------------------------
PauseMenuCommands.register("pokedex", {
  "name"        => _INTL("Pokedex"),
  "condition"   => proc {
    next $player.has_pokedex && $player.pokedex.accessible_dexes.length > 0
  },
  "effect"      => proc { |menu|
    pbPlayDecisionSE
    if Settings::USE_CURRENT_REGION_DEX
      pbFadeOutIn {
        scene = PokemonPokedex_Scene.new
        screen = PokemonPokedexScreen.new(scene)
        screen.pbStartScreen
        menu.pbRefresh
      }
    else
      if $player.pokedex.accessible_dexes.length == 1
        $PokemonGlobal.pokedexDex = $player.pokedex.accessible_dexes[0]
        pbFadeOutIn {
          scene = PokemonPokedex_Scene.new
          screen = PokemonPokedexScreen.new(scene)
          screen.pbStartScreen
          menu.pbRefresh
        }
      else
        pbFadeOutIn {
          scene = PokemonPokedexmenu.new
          screen = PokemonPokedexMenuScreen.new(scene)
          screen.pbStartScreen
          menu.pbRefresh
        }
      end
    end
  }
})

# Pokemon Party ----------------------------------------------------------------
PauseMenuCommands.register("party", {
  "name"        => _INTL("Pokémon"),
  "condition"   => proc { next $player.party_count > 0 },
  "effect"      => proc { |menu|
    pbPlayDecisionSE
    hiddenmove = nil
    pbFadeOutIn {
      sscene = PokemonParty_Scene.new
      sscreen = PokemonPartyScreen.new(sscene, $player.party)
      hiddenmove = sscreen.pbPokemonScreen
      (hiddenmove) ? menu.pbEndScene : menu.pbRefresh
    }
    if hiddenmove
      $game_temp.in_menu = false
      pbUseHiddenMove(hiddenmove[0],hiddenmove[1])
      next true
    end
  }
})

# Bag --------------------------------------------------------------------------
PauseMenuCommands.register("bag", {
  "name"        => _INTL("Bag"),
  "condition"   => proc { next !pbInBugContest? },
  "effect"      => proc { |menu|
    pbPlayDecisionSE
    item = nil
    pbFadeOutIn {
      scene = PokemonBag_Scene.new
      screen = PokemonBagScreen.new(scene, $bag)
      item = screen.pbStartScreen
      (item) ? menu.pbEndScene : menu.pbRefresh
    }
    if item
      $game_temp.in_menu = false
      pbUseKeyItemInField(item)
      next true
    end
  }
})

# Pokegear ---------------------------------------------------------------------
PauseMenuCommands.register("pokegear", {
  "name"        => _INTL("Pokégear"),
  "condition"   => proc { next $player.has_pokegear },
  "effect"      => proc { |menu|
    pbPlayDecisionSE
    pbFadeOutIn {
      scene = PokemonPokegear_Scene.new
      screen = PokemonPokegearScreen.new(scene)
      screen.pbStartScreen
      ($game_temp.fly_destination) ? menu.pbEndScene : menu.pbRefresh
    }
    next true if pbFlyToNewLocation
  }
})

# Town Map ---------------------------------------------------------------------
PauseMenuCommands.register("townmap", {
  "name"        => _INTL("Town Map"),
  "condition"   => proc { next $bag.has?(:TOWNMAP) && !$player.has_pokegear },
  "effect"      => proc { |menu|
    pbPlayDecisionSE
    pbFadeOutIn {
      scene = PokemonRegionMap_Scene.new(-1, false)
      screen = PokemonRegionMapScreen.new(scene)
      ret = screen.pbStartScreen
      $game_temp.fly_destination = ret if ret
      ($game_temp.fly_destination) ? menu.pbEndScene : menu.pbRefresh
    }
    next true if pbFlyToNewLocation
  }
})

# Trainer Card -----------------------------------------------------------------
PauseMenuCommands.register("trainercard", {
  "name"        => _INTL("\\PN"),
  "condition"   => proc { next true },
  "effect"      => proc { |menu|
    pbPlayDecisionSE
    pbFadeOutIn {
      scene = PokemonTrainerCard_Scene.new
      screen = PokemonTrainerCardScreen.new(scene)
      screen.pbStartScreen
      menu.pbRefresh
    }
  }
})

# Quit Safari Game -------------------------------------------------------------
PauseMenuCommands.register("quitsafari", {
  "name"        => _INTL("Exit Safari"),
  "condition"   => proc { next pbInSafari? && !pbInBugContest? },
  "info"        => proc {
    if Settings::SAFARI_STEPS <= 0
      next _INTL("Balls: {1}", pbSafariState.ballcount)
    else
      next _INTL("Steps: {1}/{2}\nBalls: {3}",
         pbSafariState.steps, Settings::SAFARI_STEPS, pbSafariState.ballcount)
    end
  },
  "effect"      => proc { |menu|
    menu.pbHideMenu
    if pbConfirmMessage(_INTL("Would you like to leave the Safari Game right now?"))
      menu.pbEndScene
      pbSafariState.decision = 1
      pbSafariState.pbGoToStart
      next true
    else
      menu.pbRefresh
      menu.pbShowMenu
    end
  }
})

# Quit Bug Contest -------------------------------------------------------------
PauseMenuCommands.register("quitbugcontest", {
  "name"        => _INTL("Quit Contest"),
  "condition"   => proc { next pbInBugContest? && !pbInSafari? },
  "info"        => proc {
    if pbBugContestState.lastPokemon
      next _INTL("Caught: {1}\nLevel: {2}\nBalls: {3}",
         pbBugContestState.lastPokemon.speciesName,
         pbBugContestState.lastPokemon.level,
         pbBugContestState.ballcount)
    else
      next _INTL("Caught: None\nBalls: {1}", pbBugContestState.ballcount)
    end
  },
  "effect"      => proc { |menu|
    menu.pbHideMenu
    if pbConfirmMessage(_INTL("Would you like to end the Contest now?"))
      menu.pbEndScene
      pbBugContestState.pbStartJudging
      next true
    else
      menu.pbRefresh
      menu.pbShowMenu
    end
  }
})

# Save Game --------------------------------------------------------------------
PauseMenuCommands.register("savegame", {
  "name"        => _INTL("Save"),
  "condition"   => proc {
    next $game_system && !$game_system.save_disabled && !pbInBugContest? && !pbInSafari?
  },
  "effect"      => proc { |menu|
    menu.pbHideMenu
    scene = PokemonSave_Scene.new
    screen = PokemonSaveScreen.new(scene)
    if screen.pbSaveScreen
      menu.pbEndScene
      next true
    else
      menu.pbRefresh
      menu.pbShowMenu
    end
  }
})

# Options ----------------------------------------------------------------------
PauseMenuCommands.register("options", {
  "name"        => _INTL("Options"),
  "condition"   => proc { next true },
  "effect"      => proc { |menu|
    pbPlayDecisionSE
    pbFadeOutIn {
      scene = PokemonOption_Scene.new
      screen = PokemonOptionScreen.new(scene)
      screen.pbStartScreen
      pbUpdateSceneMap
      menu.pbRefresh
    }
  }
})

# Debug Menu -------------------------------------------------------------------
PauseMenuCommands.register("debug", {
  "name"        => _INTL("Debug"),
  "condition"   => proc { next $DEBUG },
  "effect"      => proc { |menu|
    pbPlayDecisionSE
    pbFadeOutIn {
      pbDebugMenu
      menu.pbRefresh
    }
  }
})

# Quit Game --------------------------------------------------------------------
PauseMenuCommands.register("quitgame", {
  "name"        => _INTL("Quit Game"),
  "condition"   => proc { next true },
  "effect"      => proc { |menu|
    menu.pbHideMenu
    if pbConfirmMessage(_INTL("Are you sure you want to quit the game?"))
      scene = PokemonSave_Scene.new
      screen = PokemonSaveScreen.new(scene)
      screen.pbSaveScreen
      menu.pbEndScene
      $scene = nil
      next true
    else
      menu.pbRefresh
      menu.pbShowMenu
    end
  }
})
