class SafariState
  attr_accessor :ballcount
  attr_accessor :decision
  attr_accessor :steps

  def initialize
    @start      = nil
    @ballcount  = 0
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
    @start      = [$game_map.map_id,$game_player.x,$game_player.y,$game_player.direction]
    @ballcount  = ballcount
    @inProgress = true
    @steps      = SAFARI_STEPS
  end

  def pbEnd
    @start      = nil
    @ballcount  = 0
    @inProgress = false
    @steps      = 0
    @decision   = 0
    $game_map.need_refresh = true
  end
end



Events.onMapChange += proc { |_sender,*args|
  pbSafariState.pbEnd if !pbInSafari?
}

def pbInSafari?
  if pbSafariState.inProgress?
    # Reception map is handled separately from safari map since the reception
    # map can be outdoors, with its own grassy patches.
    reception = pbSafariState.pbReceptionMap
    return true if $game_map.map_id==reception
    return true if pbGetMetadata($game_map.map_id,MetadataSafariMap)
  end
  return false
end

def pbSafariState
  $PokemonGlobal.safariState = SafariState.new if !$PokemonGlobal.safariState
  return $PokemonGlobal.safariState
end

Events.onStepTakenTransferPossible += proc { |_sender,e|
  handled = e[0]
  next if handled[0]
  if pbInSafari? && pbSafariState.decision==0 && SAFARI_STEPS>0
    pbSafariState.steps -= 1
    if pbSafariState.steps<=0
      pbMessage(_INTL("PA:  Ding-dong!\1"))
      pbMessage(_INTL("PA:  Your safari game is over!"))
      pbSafariState.decision = 1
      pbSafariState.pbGoToStart
      handled[0] = true
    end
  end
}

Events.onWildBattleOverride += proc { |_sender,e|
  species = e[0]
  level   = e[1]
  handled = e[2]
  next if handled[0]!=nil
  next if !pbInSafari?
  handled[0] = pbSafariBattle(species,level)
}

def pbSafariBattle(species,level)
  # Generate a wild Pokémon based on the species and level
  pkmn = pbGenerateWildPokemon(species,level)
  foeParty = [pkmn]
  # Calculate who the trainer is
  playerTrainer = $Trainer
  # Create the battle scene (the visual side of it)
  scene = pbNewBattleScene
  # Create the battle class (the mechanics side of it)
  battle = PokeBattle_SafariZone.new(scene,playerTrainer,foeParty)
  battle.ballCount = pbSafariState.ballcount
  pbPrepareBattle(battle)
  # Perform the battle itself
  decision = 0
  pbBattleAnimation(pbGetWildBattleBGM(foeParty),0,foeParty) {
    pbSceneStandby {
      decision = battle.pbStartBattle
    }
  }
  Input.update
  # Update Safari game data based on result of battle
  pbSafariState.ballcount = battle.ballCount
  if pbSafariState.ballcount<=0
    if decision!=2   # Last Safari Ball was used to catch the wild Pokémon
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
  pbSet(1,decision)
  # Used by the Poké Radar to update/break the chain
  Events.onWildBattleEnd.trigger(nil,species,level,decision)
  # Return the outcome of the battle
  return decision
end
