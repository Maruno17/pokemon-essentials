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
      pbFadeOutIn {
        $game_temp.player_transferring   = true
        $game_temp.transition_processing = true
        $game_temp.player_new_map_id    = @start[0]
        $game_temp.player_new_x         = @start[1]
        $game_temp.player_new_y         = @start[2]
        $game_temp.player_new_direction = 2
        $scene.transfer_player
      }
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



EventHandlers.add(:on_full_map_change, :safari_end, proc {
  pbSafariState.pbEnd if !pbInSafari?
})

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

EventHandlers.add(:on_player_movement, :safari_steps, proc { |handled|
  next if handled[0]
  if pbInSafari? && pbSafariState.decision == 0 && Settings::SAFARI_STEPS > 0
    pbSafariState.steps -= 1
    if pbSafariState.steps <= 0
      pbMessage(_INTL("PA:  Ding-dong!\1"))
      pbMessage(_INTL("PA:  Your safari game is over!"))
      pbSafariState.decision = 1
      pbSafariState.pbGoToStart
      handled[0] = true
    end
  end
})

EventHandlers.add(:override_wild_battle, :safari_battle, proc { |species, level, battle|
  next if !battle[0].nil?
  next if !pbInSafari?
  battle[0] = pbSafariBattle(species, level)
})

def pbSafariBattle(species, level)
  # Record information about party Pokémon to be used at the end of battle (e.g.
  # comparing levels for an evolution check)
  EventHandlers.trigger(:before_battle)
  # Generate a wild Pokémon based on the species and level
  pkmn = pbGenerateWildPokemon(species, level)
  foeParty = [pkmn]
  # Calculate who the trainer is
  playerTrainer = $player
  # Create the battle scene (the visual side of it)
  scene = pbNewBattleScene
  # Create the battle class (the mechanics side of it)
  battle = SafariBattle.new(scene, playerTrainer, foeParty)
  battle.ballCount = pbSafariState.ballcount
  pbPrepareBattle(battle)
  # Perform the battle itself
  decision = 0
  pbBattleAnimation(pbGetWildBattleBGM(foeParty), 0, foeParty) {
    pbSceneStandby {
      decision = battle.pbStartBattle
    }
  }
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
  EventHandlers.trigger(:after_battle, species, level, decision)
  # Return the outcome of the battle
  return decision
end
