#===============================================================================
#
#===============================================================================
class UI::PauseMenuVisuals < UI::BaseVisuals
  def initialize
    @info_text_visible = false
#    @help_text_visible = false
    super
  end

  def initialize_background; end
  def initialize_overlay; end

  def initialize_sprites
    # Pause menu
    @sprites[:commands] = Window_CommandPokemon.new([])
    @sprites[:commands].visible = false
    @sprites[:commands].viewport = @viewport
    # Info text box
    @sprites[:info_text] = Window_UnformattedTextPokemon.newWithSize("", 0, 0, 32, 32, @viewport)
    @sprites[:info_text].visible = false
    # Help text box
#    @sprites[:help_text] = Window_UnformattedTextPokemon.newWithSize("", 0, 0, 32, 32, @viewport)
#    @sprites[:help_text].visible = false
  end

  #-----------------------------------------------------------------------------

  # commands is [[command IDs], [command names]].
  def set_commands(commands)
    @commands = commands
    cmd_window = @sprites[:commands]
    cmd_window.commands = @commands[1]
    cmd_window.index    = $game_temp.menu_last_choice
    cmd_window.resizeToFit(@commands[1])
    cmd_window.x        = Graphics.width - cmd_window.width
    cmd_window.y        = 0
    cmd_window.visible  = true
  end

  #-----------------------------------------------------------------------------

  def show_menu
    @sprites[:commands].visible = true
    @sprites[:info_text].visible = @info_text_visible
#    @sprites[:help_text].visible = @help_text_visible
  end

  def hide_menu
    @sprites[:commands].visible = false
    @sprites[:info_text].visible = false
#    @sprites[:help_text].visible = false
  end

  # Used in Safari Zone and Bug-Catching Contest to show extra information.
  def show_info(text)
    @sprites[:info_text].resizeToFit(text, Graphics.height)
    @sprites[:info_text].text    = text
    @sprites[:info_text].visible = true
    @info_text_visible = true
  end

  # Unused.
#  def show_help(text)
#    @sprites[:help_text].resizeToFit(text, Graphics.height)
#    @sprites[:help_text].text    = text
#    @sprites[:help_text].visible = true
#    pbBottomLeft(@sprites[:help_text])
#    @help_text_visible = true
#  end

  #-----------------------------------------------------------------------------

  def update_visuals
    pbUpdateSceneMap
    super
  end

  def update_input
    if Input.trigger?(Input::BACK) || Input.trigger?(Input::ACTION)
      return :quit
    end
    if Input.trigger?(Input::USE)
      idx = @sprites[:commands].index
      $game_temp.menu_last_choice = idx
      return @commands[0][idx]
    end
    return nil
  end
end

#===============================================================================
#
#===============================================================================
class UI::PauseMenu < UI::BaseScreen
  def initialize
    raise _INTL("Tried to open the pause menu when $player was not defined.") if !$player
    initialize_commands
    super
  end

  def initialize_commands
    @commands ||= [[], []]
    @commands[0].clear
    @commands[1].clear
    @commands_hashes ||= {}
    @commands_hashes.clear
    MenuHandlers.each_available(:pause_menu) do |option, hash, name|
      @commands[0].push(option)
      @commands[1].push(name)
      @commands_hashes[option] = hash
    end
  end

  def initialize_visuals
    @visuals = UI::PauseMenuVisuals.new
    @visuals.set_commands(@commands)
    show_info
  end

  def hide_menu
    @visuals.hide_menu
  end

  def show_menu
    @visuals.show_menu
  end

  def show_info; end

  def start_screen
    pbSEPlay("GUI menu open")
  end

  def end_screen
    return if @disposed
    pbPlayCloseMenuSE
    silent_end_screen
  end

  #-----------------------------------------------------------------------------

  def refresh
    initialize_commands
    @visuals.set_commands(@commands)
    super
  end

  def perform_action(command)
    if @commands_hashes[command]["effect"].call(self)
      # NOTE: Calling end_screen will have been done in the "effect" proc, so
      #       there's no need to do anything special here to mark that this
      #       screen has already been closed/disposed of.
      return :quit
    end
    return nil
  end
end

#===============================================================================
# Pause menu commands.
#===============================================================================

MenuHandlers.add(:pause_menu, :pokedex, {
  "name"      => _INTL("Pokédex"),
  "order"     => 10,
  "condition" => proc { next $player.has_pokedex && $player.pokedex.accessible_dexes.length > 0 },
  "effect"    => proc { |menu|
    pbPlayDecisionSE
    if Settings::USE_CURRENT_REGION_DEX
      pbFadeOutIn do
        scene = PokemonPokedex_Scene.new
        screen = PokemonPokedexScreen.new(scene)
        screen.pbStartScreen
        menu.refresh
      end
    elsif $player.pokedex.accessible_dexes.length == 1
      $PokemonGlobal.pokedexDex = $player.pokedex.accessible_dexes[0]
      pbFadeOutIn do
        scene = PokemonPokedex_Scene.new
        screen = PokemonPokedexScreen.new(scene)
        screen.pbStartScreen
        menu.refresh
      end
    else
      pbFadeOutIn do
        scene = PokemonPokedexMenu_Scene.new
        screen = PokemonPokedexMenuScreen.new(scene)
        screen.pbStartScreen
        menu.refresh
      end
    end
    next false
  }
})

MenuHandlers.add(:pause_menu, :party, {
  "name"      => _INTL("Pokémon"),
  "order"     => 20,
  "condition" => proc { next $player.party_count > 0 },
  "effect"    => proc { |menu|
    pbPlayDecisionSE
    hidden_move = nil
    pbFadeOutIn do
      sscene = PokemonParty_Scene.new
      sscreen = PokemonPartyScreen.new(sscene, $player.party)
      hidden_move = sscreen.pbPokemonScreen
      (hidden_move) ? menu.silent_end_screen : menu.refresh
    end
    next false if !hidden_move
    $game_temp.in_menu = false
    pbUseHiddenMove(hidden_move[0], hidden_move[1])
    next true
  }
})

MenuHandlers.add(:pause_menu, :bag, {
  "name"      => _INTL("Bag"),
  "order"     => 30,
  "condition" => proc { next !pbInBugContest? },
  "effect"    => proc { |menu|
    pbPlayDecisionSE
    item = nil
    pbFadeOutIn do
      scene = PokemonBag_Scene.new
      screen = PokemonBagScreen.new(scene, $bag)
      item = screen.pbStartScreen
      (item) ? menu.silent_end_screen : menu.refresh
    end
    next false if !item
    $game_temp.in_menu = false
    pbUseKeyItemInField(item)
    next true
  }
})

MenuHandlers.add(:pause_menu, :pokegear, {
  "name"      => _INTL("Pokégear"),
  "order"     => 40,
  "condition" => proc { next $player.has_pokegear },
  "effect"    => proc { |menu|
    pbPlayDecisionSE
    pbFadeOutIn do
      scene = PokemonPokegear_Scene.new
      screen = PokemonPokegearScreen.new(scene)
      screen.pbStartScreen
      ($game_temp.fly_destination) ? menu.silent_end_screen : menu.refresh
    end
    next pbFlyToNewLocation
  }
})

MenuHandlers.add(:pause_menu, :town_map, {
  "name"      => _INTL("Town Map"),
  "order"     => 40,
  "condition" => proc { next !$player.has_pokegear && $bag.has?(:TOWNMAP) },
  "effect"    => proc { |menu|
    pbPlayDecisionSE
    pbFadeOutIn do
      scene = PokemonRegionMap_Scene.new(-1, false)
      screen = PokemonRegionMapScreen.new(scene)
      ret = screen.pbStartScreen
      $game_temp.fly_destination = ret if ret
      ($game_temp.fly_destination) ? menu.silent_end_screen : menu.refresh
    end
    next pbFlyToNewLocation
  }
})

MenuHandlers.add(:pause_menu, :trainer_card, {
  "name"      => proc { next $player.name },
  "order"     => 50,
  "effect"    => proc { |menu|
    pbPlayDecisionSE
    pbFadeOutIn do
      UI::TrainerCard.new.main
      menu.refresh
    end
    next false
  }
})

MenuHandlers.add(:pause_menu, :save, {
  "name"      => _INTL("Save"),
  "order"     => 60,
  "condition" => proc {
    next $game_system && !$game_system.save_disabled && !pbInSafari? && !pbInBugContest?
  },
  "effect"    => proc { |menu|
    menu.hide_menu
    scene = PokemonSave_Scene.new
    screen = PokemonSaveScreen.new(scene)
    if screen.pbSaveScreen
      menu.silent_end_screen
      next true
    end
    menu.refresh
    menu.show_menu
    next false
  }
})

MenuHandlers.add(:pause_menu, :options, {
  "name"      => _INTL("Options"),
  "order"     => 70,
  "effect"    => proc { |menu|
    pbPlayDecisionSE
    pbFadeOutIn do
      scene = PokemonOption_Scene.new
      screen = PokemonOptionScreen.new(scene)
      screen.pbStartScreen
      pbUpdateSceneMap
      menu.refresh
    end
    next false
  }
})

MenuHandlers.add(:pause_menu, :debug, {
  "name"      => _INTL("Debug"),
  "order"     => 80,
  "condition" => proc { next $DEBUG },
  "effect"    => proc { |menu|
    pbPlayDecisionSE
    pbFadeOutIn do
      pbDebugMenu
      menu.refresh
    end
    next false
  }
})

MenuHandlers.add(:pause_menu, :quit_game, {
  "name"      => _INTL("Quit Game"),
  "order"     => 90,
  "effect"    => proc { |menu|
    menu.hide_menu
    if pbConfirmMessage(_INTL("Are you sure you want to quit the game?"))
      scene = PokemonSave_Scene.new
      screen = PokemonSaveScreen.new(scene)
      screen.pbSaveScreen
      menu.silent_end_screen
      $scene = nil
      next true
    end
    menu.refresh
    menu.show_info
    next false
  }
})
