#===============================================================================
#
#===============================================================================
class UI::PauseMenuVisuals < UI::BaseVisuals
  def initialize
    @info_text_visible = false
    super
  end

  def initialize_background; end
  def initialize_overlay; end

  def initialize_sprites
    # Location window
    map_name = $game_map.name
    location_sign_graphic = $game_map.metadata&.location_sign || Settings::DEFAULT_LOCATION_SIGN_GRAPHIC
    @sprites[:location] = LocationWindow.new(map_name, location_sign_graphic, false, @viewport)
    # Delete any location window currently being displayed
    $scene.spriteset.usersprites.each { |sprite| sprite.dispose if sprite.is_a?(LocationWindow) }
    # Pause menu
    @sprites[:commands] = Window_CommandPokemon.new([])
    @sprites[:commands].z = 100
    @sprites[:commands].visible = false
    @sprites[:commands].viewport = @viewport
    # Info text box
    @sprites[:info_text] = Window_UnformattedTextPokemon.newWithSize("", 0, 0, 32, 32, @viewport)
    @sprites[:info_text].z = 100
    @sprites[:info_text].visible = false
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
  end

  def hide_menu
    @sprites[:commands].visible = false
    @sprites[:info_text].visible = false
  end

  # Used in Safari Zone and Bug-Catching Contest to show extra information.
  def show_info(text)
    @sprites[:info_text].resizeToFit(text, Graphics.height)
    @sprites[:info_text].text = text
    @sprites[:info_text].y = Graphics.height - @sprites[:info_text].height
    @sprites[:info_text].visible = true
    @info_text_visible = true
  end

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
    pbPlayOpenMenuSE
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
    pbFadeOutIn do
      UI::PokedexDexes.new.main
      menu.refresh
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
    pbFadeOutIn do
      UI::Party.new($player.party).main
      ($game_temp.field_move_to_use) ? menu.silent_end_screen : menu.refresh
    end
    next false if !$game_temp.field_move_to_use
    $game_temp.in_menu = false
    pbUseHiddenMove($game_temp.field_move_user, $game_temp.field_move_to_use)
    $game_temp.field_move_user = nil
    $game_temp.field_move_to_use = nil
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
      bag_screen = UI::Bag.new($bag)
      bag_screen.main
      item = bag_screen.result
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
  "condition" => proc { next Settings::SHOW_TOWN_MAP_IN_PAUSE_MENU && !$player.has_pokegear && $bag.has?(:TOWNMAP) },
  "effect"    => proc { |menu|
    pbPlayDecisionSE
    pbFadeOutIn do
      town_map_screen = UI::TownMap.new
      town_map_screen.main
      ret = town_map_screen.result
      $game_temp.fly_destination = ret if ret
      ($game_temp.fly_destination) ? menu.silent_end_screen : menu.refresh
    end
    next pbFlyToNewLocation
  }
})

MenuHandlers.add(:pause_menu, :trainer_card, {
  "name"      => proc { |menu| next $player.name },
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
    pbPlayDecisionSE
    ret = false
    pbFadeOutIn do
      ret = UI::Save.new.main
      if ret
        menu.silent_end_screen
      else
        menu.refresh
      end
    end
    next ret
  }
})

MenuHandlers.add(:pause_menu, :options, {
  "name"      => _INTL("Options"),
  "order"     => 70,
  "effect"    => proc { |menu|
    pbPlayDecisionSE
    pbFadeOutIn do
      UI::Options.new.main
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
      pbPlayCloseMenuSE
      pbBGMFade(1.0)
      pbBGSFade(1.0)
      menu.visuals.fade_out
      menu.silent_end_screen
      SaveData.mark_values_as_unloaded
      $scene = pbCallTitle
      next true
    end
    menu.refresh
    menu.show_info
    next false
  }
})
