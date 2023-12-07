#===============================================================================
#
#===============================================================================
class SafariState
  attr_accessor :ballcount
  attr_accessor :captures
  attr_accessor :decision
  attr_accessor :steps

  def initialize
    @start      = nil
    @ballcount  = 0
    @captures   = 0
    @inProgress = false
    @steps      = 0
    @decision   = 0
  end

  def pbReceptionMap
    return @inProgress ? @start[0] : 0
  end

  def inProgress?
    return @inProgress
  end

  def pbGoToStart
    if $scene.is_a?(Scene_Map)
      pbFadeOutIn do
        $game_temp.player_transferring   = true
        $game_temp.transition_processing = true
        $game_temp.player_new_map_id    = @start[0]
        $game_temp.player_new_x         = @start[1]
        $game_temp.player_new_y         = @start[2]
        $game_temp.player_new_direction = 2
        pbDismountBike
        $scene.transfer_player
      end
    end
  end

  def pbStart(ballcount)
    @start      = [$game_map.map_id, $game_player.x, $game_player.y, $game_player.direction]
    @ballcount  = ballcount
    @inProgress = true
    @steps      = Settings::SAFARI_STEPS
  end

  def pbEnd
    @start      = nil
    @ballcount  = 0
    @captures   = 0
    @inProgress = false
    @steps      = 0
    @decision   = 0
    $game_map.need_refresh = true
  end
end

#===============================================================================
#
#===============================================================================
def pbInSafari?
  if pbSafariState.inProgress?
    # Reception map is handled separately from safari map since the reception
    # map can be outdoors, with its own grassy patches.
    reception = pbSafariState.pbReceptionMap
    return true if $game_map.map_id == reception
    return true if $game_map.metadata&.safari_map
  end
  return false
end

def pbSafariState
  $PokemonGlobal.safariState = SafariState.new if !$PokemonGlobal.safariState
  return $PokemonGlobal.safariState
end

#===============================================================================
#
#===============================================================================
EventHandlers.add(:on_enter_map, :end_safari_game,
  proc { |_old_map_id|
    pbSafariState.pbEnd if !pbInSafari?
  }
)

EventHandlers.add(:on_player_step_taken_can_transfer, :safari_game_counter,
  proc { |handled|
    # handled is an array: [nil]. If [true], a transfer has happened because of
    # this event, so don't do anything that might cause another one
    next if handled[0]
    next if Settings::SAFARI_STEPS == 0 || !pbInSafari? || pbSafariState.decision != 0
    pbSafariState.steps -= 1
    next if pbSafariState.steps > 0
    pbMessage("\\se[Safari Zone end]" + _INTL("PA: Ding-dong!") + "\1")
    pbMessage(_INTL("PA: Your safari game is over!"))
    pbSafariState.decision = 1
    pbSafariState.pbGoToStart
    handled[0] = true
  }
)

#===============================================================================
#
#===============================================================================
EventHandlers.add(:on_calling_wild_battle, :safari_battle,
  proc { |pkmn, handled|
    # handled is an array: [nil]. If [true] or [false], the battle has already
    # been overridden (the boolean is its outcome), so don't do anything that
    # would override it again
    next if !handled[0].nil?
    next if !pbInSafari?
    handled[0] = pbSafariBattle(pkmn)
  }
)

def pbSafariBattle(pkmn, level = 1)
  # Generate a wild Pokémon based on the species and level
  pkmn = pbGenerateWildPokemon(pkmn, level) if !pkmn.is_a?(Pokemon)
  foeParty = [pkmn]
  # Calculate who the trainer is
  playerTrainer = $player
  # Create the battle scene (the visual side of it)
  scene = BattleCreationHelperMethods.create_battle_scene
  # Create the battle class (the mechanics side of it)
  battle = SafariBattle.new(scene, playerTrainer, foeParty)
  battle.ballCount = pbSafariState.ballcount
  BattleCreationHelperMethods.prepare_battle(battle)
  # Perform the battle itself
  decision = 0
  pbBattleAnimation(pbGetWildBattleBGM(foeParty), 0, foeParty) do
    pbSceneStandby { decision = battle.pbStartBattle }
  end
  Input.update
  # Update Safari game data based on result of battle
  pbSafariState.ballcount = battle.ballCount
  if pbSafariState.ballcount <= 0
    if decision != 2   # Last Safari Ball was used to catch the wild Pokémon
      pbMessage(_INTL("Announcer: You're out of Safari Balls! Game over!"))
    end
    pbSafariState.decision = 1
    pbSafariState.pbGoToStart
  end
  # Save the result of the battle in Game Variable 1
  #    0 - Undecided or aborted
  #    2 - Player ran out of Safari Balls
  #    3 - Player or wild Pokémon ran from battle, or player forfeited the match
  #    4 - Wild Pokémon was caught
  if decision == 4
    $stats.safari_pokemon_caught += 1
    pbSafariState.captures += 1
    $stats.most_captures_per_safari_game = [$stats.most_captures_per_safari_game, pbSafariState.captures].max
  end
  pbSet(1, decision)
  # Used by the Poké Radar to update/break the chain
  EventHandlers.trigger(:on_wild_battle_end, pkmn.species_data.id, pkmn.level, decision)
  # Return the outcome of the battle
  return decision
end

#===============================================================================
#
#===============================================================================
class PokemonPauseMenu
  alias __safari_pbShowInfo pbShowInfo unless method_defined?(:__safari_pbShowInfo)

  def pbShowInfo
    __safari_pbShowInfo
    return if !pbInSafari?
    if Settings::SAFARI_STEPS <= 0
      @scene.pbShowInfo(_INTL("Balls: {1}", pbSafariState.ballcount))
    else
      @scene.pbShowInfo(_INTL("Steps: {1}/{2}\nBalls: {3}",
                              pbSafariState.steps, Settings::SAFARI_STEPS, pbSafariState.ballcount))
    end
  end
end

MenuHandlers.add(:pause_menu, :quit_safari_game, {
  "name"      => _INTL("Quit"),
  "order"     => 60,
  "condition" => proc { next pbInSafari? },
  "effect"    => proc { |menu|
    menu.pbHideMenu
    if pbConfirmMessage(_INTL("Would you like to leave the Safari Game right now?"))
      menu.pbEndScene
      pbSafariState.decision = 1
      pbSafariState.pbGoToStart
      next true
    end
    menu.pbRefresh
    menu.pbShowMenu
    next false
  }
})
