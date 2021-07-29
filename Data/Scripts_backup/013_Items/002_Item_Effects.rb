#===============================================================================
# UseText handlers
#===============================================================================
ItemHandlers::UseText.add(:BICYCLE,proc { |item|
  next ($PokemonGlobal.bicycle) ? _INTL("Walk") : _INTL("Use")
})

ItemHandlers::UseText.copy(:BICYCLE,:MACHBIKE,:ACROBIKE)

#===============================================================================
# UseFromBag handlers
# Return values: 0 = not used
#                1 = used, item not consumed
#                2 = close the Bag to use, item not consumed
#                3 = used, item consumed
#                4 = close the Bag to use, item consumed
# If there is no UseFromBag handler for an item being used from the Bag (not on
# a Pokémon and not a TM/HM), calls the UseInField handler for it instead.
#===============================================================================

ItemHandlers::UseFromBag.add(:HONEY,proc { |item|
  next 4
})

ItemHandlers::UseFromBag.add(:ESCAPEROPE,proc { |item|
  if $game_player.pbHasDependentEvents?
    pbMessage(_INTL("It can't be used when you have someone with you."))
    next 0
  end
  if ($PokemonGlobal.escapePoint rescue false) && $PokemonGlobal.escapePoint.length>0
    next 4   # End screen and consume item
  end
  pbMessage(_INTL("Can't use that here."))
  next 0
})

ItemHandlers::UseFromBag.add(:BICYCLE,proc { |item|
  next (pbBikeCheck) ? 2 : 0
})

ItemHandlers::UseFromBag.copy(:BICYCLE,:MACHBIKE,:ACROBIKE)

ItemHandlers::UseFromBag.add(:OLDROD,proc { |item|
  notCliff = $game_map.passable?($game_player.x,$game_player.y,$game_player.direction,$game_player)
  next 2 if $game_player.pbFacingTerrainTag.can_fish && ($PokemonGlobal.surfing || notCliff)
  pbMessage(_INTL("Can't use that here."))
  next 0
})

ItemHandlers::UseFromBag.copy(:OLDROD,:GOODROD,:SUPERROD)

ItemHandlers::UseFromBag.add(:ITEMFINDER,proc { |item|
  next 2
})

ItemHandlers::UseFromBag.copy(:ITEMFINDER,:DOWSINGMCHN,:DOWSINGMACHINE)

#===============================================================================
# ConfirmUseInField handlers
# Return values: true/false
# Called when an item is used from the Ready Menu.
# If an item does not have this handler, it is treated as returning true.
#===============================================================================

ItemHandlers::ConfirmUseInField.add(:ESCAPEROPE,proc { |item|
  escape = ($PokemonGlobal.escapePoint rescue nil)
  if !escape || escape==[]
    pbMessage(_INTL("Can't use that here."))
    next false
  end
  if $game_player.pbHasDependentEvents?
    pbMessage(_INTL("It can't be used when you have someone with you."))
    next false
  end
  mapname = pbGetMapNameFromId(escape[0])
  next pbConfirmMessage(_INTL("Want to escape from here and return to {1}?",mapname))
})

#===============================================================================
# UseInField handlers
# Return values: 0 = not used
#                1 = used, item not consumed
#                3 = used, item consumed
# Called if an item is used from the Bag (not on a Pokémon and not a TM/HM) and
# there is no UseFromBag handler above.
# If an item has this handler, it can be registered to the Ready Menu.
#===============================================================================

def pbRepel(item,steps)
  if $PokemonGlobal.repel>0
    pbMessage(_INTL("But a repellent's effect still lingers from earlier."))
    return 0
  end
  pbUseItemMessage(item)
  $PokemonGlobal.repel = steps
  return 3
end

ItemHandlers::UseInField.add(:REPEL,proc { |item|
  next pbRepel(item,100)
})

ItemHandlers::UseInField.add(:SUPERREPEL,proc { |item|
  next pbRepel(item,200)
})

ItemHandlers::UseInField.add(:MAXREPEL,proc { |item|
  next pbRepel(item,250)
})

Events.onStepTaken += proc {
  if $PokemonGlobal.repel > 0 && !$game_player.terrain_tag.ice   # Shouldn't count down if on ice
    $PokemonGlobal.repel -= 1
    if $PokemonGlobal.repel <= 0
      if $PokemonBag.pbHasItem?(:REPEL) ||
         $PokemonBag.pbHasItem?(:SUPERREPEL) ||
         $PokemonBag.pbHasItem?(:MAXREPEL)
        if pbConfirmMessage(_INTL("The repellent's effect wore off! Would you like to use another one?"))
          ret = nil
          pbFadeOutIn {
            scene = PokemonBag_Scene.new
            screen = PokemonBagScreen.new(scene,$PokemonBag)
            ret = screen.pbChooseItemScreen(Proc.new { |item|
              [:REPEL, :SUPERREPEL, :MAXREPEL].include?(item)
            })
          }
          pbUseItem($PokemonBag,ret) if ret
        end
      else
        pbMessage(_INTL("The repellent's effect wore off!"))
      end
    end
  end
}

ItemHandlers::UseInField.add(:BLACKFLUTE,proc { |item|
  pbUseItemMessage(item)
  pbMessage(_INTL("Wild Pokémon will be repelled."))
  $PokemonMap.blackFluteUsed = true
  $PokemonMap.whiteFluteUsed = false
  next 1
})

ItemHandlers::UseInField.add(:WHITEFLUTE,proc { |item|
  pbUseItemMessage(item)
  pbMessage(_INTL("Wild Pokémon will be lured."))
  $PokemonMap.blackFluteUsed = false
  $PokemonMap.whiteFluteUsed = true
  next 1
})

ItemHandlers::UseInField.add(:HONEY,proc { |item|
  pbUseItemMessage(item)
  pbSweetScent
  next 3
})

ItemHandlers::UseInField.add(:ESCAPEROPE,proc { |item|
  escape = ($PokemonGlobal.escapePoint rescue nil)
  if !escape || escape==[]
    pbMessage(_INTL("Can't use that here."))
    next 0
  end
  if $game_player.pbHasDependentEvents?
    pbMessage(_INTL("It can't be used when you have someone with you."))
    next 0
  end
  pbUseItemMessage(item)
  pbFadeOutIn {
    $game_temp.player_new_map_id    = escape[0]
    $game_temp.player_new_x         = escape[1]
    $game_temp.player_new_y         = escape[2]
    $game_temp.player_new_direction = escape[3]
    pbCancelVehicles
    $scene.transfer_player
    $game_map.autoplay
    $game_map.refresh
  }
  pbEraseEscapePoint
  next 3
})

ItemHandlers::UseInField.add(:SACREDASH,proc { |item|
  if $Trainer.pokemon_count == 0
    pbMessage(_INTL("There is no Pokémon."))
    next 0
  end
  canrevive = false
  for i in $Trainer.pokemon_party
    next if !i.fainted?
    canrevive = true; break
  end
  if !canrevive
    pbMessage(_INTL("It won't have any effect."))
    next 0
  end
  revived = 0
  pbFadeOutIn {
    scene = PokemonParty_Scene.new
    screen = PokemonPartyScreen.new(scene,$Trainer.party)
    screen.pbStartScene(_INTL("Using item..."),false)
    for i in 0...$Trainer.party.length
      if $Trainer.party[i].fainted?
        revived += 1
        $Trainer.party[i].heal
        screen.pbRefreshSingle(i)
        screen.pbDisplay(_INTL("{1}'s HP was restored.",$Trainer.party[i].name))
      end
    end
    if revived==0
      screen.pbDisplay(_INTL("It won't have any effect."))
    end
    screen.pbEndScene
  }
  next (revived==0) ? 0 : 3
})

ItemHandlers::UseInField.add(:BICYCLE,proc { |item|
  if pbBikeCheck
    if $PokemonGlobal.bicycle
      pbDismountBike
    else
      pbMountBike
    end
    next 1
  end
  next 0
})

ItemHandlers::UseInField.copy(:BICYCLE,:MACHBIKE,:ACROBIKE)

ItemHandlers::UseInField.add(:OLDROD,proc { |item|
  notCliff = $game_map.passable?($game_player.x,$game_player.y,$game_player.direction,$game_player)
  if !$game_player.pbFacingTerrainTag.can_fish || (!$PokemonGlobal.surfing && !notCliff)
    pbMessage(_INTL("Can't use that here."))
    next 0
  end
  encounter = $PokemonEncounters.has_encounter_type?(:OldRod)
  if pbFishing(encounter,1)
    pbEncounter(:OldRod)
  end
  next 1
})

ItemHandlers::UseInField.add(:GOODROD,proc { |item|
  notCliff = $game_map.passable?($game_player.x,$game_player.y,$game_player.direction,$game_player)
  if !$game_player.pbFacingTerrainTag.can_fish || (!$PokemonGlobal.surfing && !notCliff)
    pbMessage(_INTL("Can't use that here."))
    next 0
  end
  encounter = $PokemonEncounters.has_encounter_type?(:GoodRod)
  if pbFishing(encounter,2)
    pbEncounter(:GoodRod)
  end
  next 1
})

ItemHandlers::UseInField.add(:SUPERROD,proc { |item|
  notCliff = $game_map.passable?($game_player.x,$game_player.y,$game_player.direction,$game_player)
  if !$game_player.pbFacingTerrainTag.can_fish || (!$PokemonGlobal.surfing && !notCliff)
    pbMessage(_INTL("Can't use that here."))
    next 0
  end
  encounter = $PokemonEncounters.has_encounter_type?(:SuperRod)
  if pbFishing(encounter,3)
    pbEncounter(:SuperRod)
  end
  next 1
})

ItemHandlers::UseInField.add(:ITEMFINDER,proc { |item|
  event = pbClosestHiddenItem
  if !event
    pbMessage(_INTL("... \\wt[10]... \\wt[10]... \\wt[10]...\\wt[10]Nope! There's no response."))
  else
    offsetX = event.x-$game_player.x
    offsetY = event.y-$game_player.y
    if offsetX==0 && offsetY==0   # Standing on the item, spin around
      4.times do
        pbWait(Graphics.frame_rate*2/10)
        $game_player.turn_right_90
      end
      pbWait(Graphics.frame_rate*3/10)
      pbMessage(_INTL("The {1}'s indicating something right underfoot!",GameData::Item.get(item).name))
    else   # Item is nearby, face towards it
      direction = $game_player.direction
      if offsetX.abs>offsetY.abs
        direction = (offsetX<0) ? 4 : 6
      else
        direction = (offsetY<0) ? 8 : 2
      end
      case direction
      when 2 then $game_player.turn_down
      when 4 then $game_player.turn_left
      when 6 then $game_player.turn_right
      when 8 then $game_player.turn_up
      end
      pbWait(Graphics.frame_rate*3/10)
      pbMessage(_INTL("Huh? The {1}'s responding!\1",GameData::Item.get(item).name))
      pbMessage(_INTL("There's an item buried around here!"))
    end
  end
  next 1
})

ItemHandlers::UseInField.copy(:ITEMFINDER,:DOWSINGMCHN,:DOWSINGMACHINE)

ItemHandlers::UseInField.add(:TOWNMAP,proc { |item|
  pbShowMap(-1,false)
  next 1
})

ItemHandlers::UseInField.add(:COINCASE,proc { |item|
  pbMessage(_INTL("Coins: {1}", $Trainer.coins.to_s_formatted))
  next 1
})

ItemHandlers::UseInField.add(:EXPALL,proc { |item|
  $PokemonBag.pbChangeItem(:EXPALL,:EXPALLOFF)
  pbMessage(_INTL("The Exp Share was turned off."))
  next 1
})

ItemHandlers::UseInField.add(:EXPALLOFF,proc { |item|
  $PokemonBag.pbChangeItem(:EXPALLOFF,:EXPALL)
  pbMessage(_INTL("The Exp Share was turned on."))
  next 1
})

#===============================================================================
# UseOnPokemon handlers
#===============================================================================

# Applies to all items defined as an evolution stone.
# No need to add more code for new ones.
ItemHandlers::UseOnPokemon.addIf(proc { |item| GameData::Item.get(item).is_evolution_stone? },
  proc { |item,pkmn,scene|
    if pkmn.shadowPokemon?
      scene.pbDisplay(_INTL("It won't have any effect."))
      next false
    end
    newspecies = pkmn.check_evolution_on_use_item(item)
    if newspecies
      pbFadeOutInWithMusic {
        evo = PokemonEvolutionScene.new
        evo.pbStartScreen(pkmn,newspecies)
        evo.pbEvolution(false)
        evo.pbEndScreen
        if scene.is_a?(PokemonPartyScreen)
          scene.pbRefreshAnnotations(proc { |p| !p.check_evolution_on_use_item(item).nil? })
          scene.pbRefresh
        end
      }
      next true
    end
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  }
)

ItemHandlers::UseOnPokemon.add(:POTION,proc { |item,pkmn,scene|
  next pbHPItem(pkmn,20,scene)
})

ItemHandlers::UseOnPokemon.copy(:POTION,:BERRYJUICE,:SWEETHEART)
ItemHandlers::UseOnPokemon.copy(:POTION,:RAGECANDYBAR) if !Settings::RAGE_CANDY_BAR_CURES_STATUS_PROBLEMS

ItemHandlers::UseOnPokemon.add(:SUPERPOTION,proc { |item,pkmn,scene|
  next pbHPItem(pkmn,50,scene)
})

ItemHandlers::UseOnPokemon.add(:HYPERPOTION,proc { |item,pkmn,scene|
  next pbHPItem(pkmn,200,scene)
})

ItemHandlers::UseOnPokemon.add(:MAXPOTION,proc { |item,pkmn,scene|
  next pbHPItem(pkmn,pkmn.totalhp-pkmn.hp,scene)
})

ItemHandlers::UseOnPokemon.add(:FRESHWATER,proc { |item,pkmn,scene|
  next pbHPItem(pkmn,50,scene)
})

ItemHandlers::UseOnPokemon.add(:SODAPOP,proc { |item,pkmn,scene|
  next pbHPItem(pkmn,60,scene)
})

ItemHandlers::UseOnPokemon.add(:LEMONADE,proc { |item,pkmn,scene|
  next pbHPItem(pkmn,80,scene)
})

ItemHandlers::UseOnPokemon.add(:MOOMOOMILK,proc { |item,pkmn,scene|
  next pbHPItem(pkmn,100,scene)
})

ItemHandlers::UseOnPokemon.add(:ORANBERRY,proc { |item,pkmn,scene|
  next pbHPItem(pkmn,10,scene)
})

ItemHandlers::UseOnPokemon.add(:SITRUSBERRY,proc { |item,pkmn,scene|
  next pbHPItem(pkmn,pkmn.totalhp/4,scene)
})

ItemHandlers::UseOnPokemon.add(:AWAKENING,proc { |item,pkmn,scene|
  if pkmn.fainted? || pkmn.status != :SLEEP
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.heal_status
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1} woke up.",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.copy(:AWAKENING,:CHESTOBERRY,:BLUEFLUTE,:POKEFLUTE)

ItemHandlers::UseOnPokemon.add(:ANTIDOTE,proc { |item,pkmn,scene|
  if pkmn.fainted? || pkmn.status != :POISON
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.heal_status
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1} was cured of its poisoning.",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.copy(:ANTIDOTE,:PECHABERRY)

ItemHandlers::UseOnPokemon.add(:BURNHEAL,proc { |item,pkmn,scene|
  if pkmn.fainted? || pkmn.status != :BURN
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.heal_status
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1}'s burn was healed.",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.copy(:BURNHEAL,:RAWSTBERRY)

ItemHandlers::UseOnPokemon.add(:PARALYZEHEAL,proc { |item,pkmn,scene|
  if pkmn.fainted? || pkmn.status != :PARALYSIS
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.heal_status
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1} was cured of paralysis.",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.copy(:PARALYZEHEAL,:PARLYZHEAL,:CHERIBERRY)

ItemHandlers::UseOnPokemon.add(:ICEHEAL,proc { |item,pkmn,scene|
  if pkmn.fainted? || pkmn.status != :FROZEN
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.heal_status
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1} was thawed out.",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.copy(:ICEHEAL,:ASPEARBERRY)

ItemHandlers::UseOnPokemon.add(:FULLHEAL,proc { |item,pkmn,scene|
  if pkmn.fainted? || pkmn.status == :NONE
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.heal_status
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1} became healthy.",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.copy(:FULLHEAL,
   :LAVACOOKIE,:OLDGATEAU,:CASTELIACONE,:LUMIOSEGALETTE,:SHALOURSABLE,
   :BIGMALASADA,:LUMBERRY)
ItemHandlers::UseOnPokemon.copy(:FULLHEAL,:RAGECANDYBAR) if Settings::RAGE_CANDY_BAR_CURES_STATUS_PROBLEMS

ItemHandlers::UseOnPokemon.add(:FULLRESTORE,proc { |item,pkmn,scene|
  if pkmn.fainted? || (pkmn.hp==pkmn.totalhp && pkmn.status == :NONE)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  hpgain = pbItemRestoreHP(pkmn,pkmn.totalhp-pkmn.hp)
  pkmn.heal_status
  scene.pbRefresh
  if hpgain>0
    scene.pbDisplay(_INTL("{1}'s HP was restored by {2} points.",pkmn.name,hpgain))
  else
    scene.pbDisplay(_INTL("{1} became healthy.",pkmn.name))
  end
  next true
})

ItemHandlers::UseOnPokemon.add(:REVIVE,proc { |item,pkmn,scene|
  if !pkmn.fainted?
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.hp = (pkmn.totalhp/2).floor
  pkmn.hp = 1 if pkmn.hp<=0
  pkmn.heal_status
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1}'s HP was restored.",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:MAXREVIVE,proc { |item,pkmn,scene|
  if !pkmn.fainted?
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.heal_HP
  pkmn.heal_status
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1}'s HP was restored.",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:ENERGYPOWDER,proc { |item,pkmn,scene|
  if pbHPItem(pkmn,50,scene)
    pkmn.changeHappiness("powder")
    next true
  end
  next false
})

ItemHandlers::UseOnPokemon.add(:ENERGYROOT,proc { |item,pkmn,scene|
  if pbHPItem(pkmn,200,scene)
    pkmn.changeHappiness("energyroot")
    next true
  end
  next false
})

ItemHandlers::UseOnPokemon.add(:HEALPOWDER,proc { |item,pkmn,scene|
  if pkmn.fainted? || pkmn.status == :NONE
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.heal_status
  pkmn.changeHappiness("powder")
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1} became healthy.",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:REVIVALHERB,proc { |item,pkmn,scene|
  if !pkmn.fainted?
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.heal_HP
  pkmn.heal_status
  pkmn.changeHappiness("revivalherb")
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1}'s HP was restored.",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:ETHER,proc { |item,pkmn,scene|
  move = scene.pbChooseMove(pkmn,_INTL("Restore which move?"))
  next false if move<0
  if pbRestorePP(pkmn,move,10)==0
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  scene.pbDisplay(_INTL("PP was restored."))
  next true
})

ItemHandlers::UseOnPokemon.copy(:ETHER,:LEPPABERRY)

ItemHandlers::UseOnPokemon.add(:MAXETHER,proc { |item,pkmn,scene|
  move = scene.pbChooseMove(pkmn,_INTL("Restore which move?"))
  next false if move<0
  if pbRestorePP(pkmn,move,pkmn.moves[move].total_pp-pkmn.moves[move].pp)==0
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  scene.pbDisplay(_INTL("PP was restored."))
  next true
})

ItemHandlers::UseOnPokemon.add(:ELIXIR,proc { |item,pkmn,scene|
  pprestored = 0
  for i in 0...pkmn.moves.length
    pprestored += pbRestorePP(pkmn,i,10)
  end
  if pprestored==0
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  scene.pbDisplay(_INTL("PP was restored."))
  next true
})

ItemHandlers::UseOnPokemon.add(:MAXELIXIR,proc { |item,pkmn,scene|
  pprestored = 0
  for i in 0...pkmn.moves.length
    pprestored += pbRestorePP(pkmn,i,pkmn.moves[i].total_pp-pkmn.moves[i].pp)
  end
  if pprestored==0
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  scene.pbDisplay(_INTL("PP was restored."))
  next true
})

ItemHandlers::UseOnPokemon.add(:PPUP,proc { |item,pkmn,scene|
  move = scene.pbChooseMove(pkmn,_INTL("Boost PP of which move?"))
  if move>=0
    if pkmn.moves[move].total_pp<=1 || pkmn.moves[move].ppup>=3
      scene.pbDisplay(_INTL("It won't have any effect."))
      next false
    end
    pkmn.moves[move].ppup += 1
    movename = pkmn.moves[move].name
    scene.pbDisplay(_INTL("{1}'s PP increased.",movename))
    next true
  end
  next false
})

ItemHandlers::UseOnPokemon.add(:PPMAX,proc { |item,pkmn,scene|
  move = scene.pbChooseMove(pkmn,_INTL("Boost PP of which move?"))
  if move>=0
    if pkmn.moves[move].total_pp<=1 || pkmn.moves[move].ppup>=3
      scene.pbDisplay(_INTL("It won't have any effect."))
      next false
    end
    pkmn.moves[move].ppup = 3
    movename = pkmn.moves[move].name
    scene.pbDisplay(_INTL("{1}'s PP increased.",movename))
    next true
  end
  next false
})

ItemHandlers::UseOnPokemon.add(:HPUP,proc { |item,pkmn,scene|
  if pbRaiseEffortValues(pkmn,:HP)==0
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1}'s HP increased.",pkmn.name))
  pkmn.changeHappiness("vitamin")
  next true
})

ItemHandlers::UseOnPokemon.add(:PROTEIN,proc { |item,pkmn,scene|
  if pbRaiseEffortValues(pkmn,:ATTACK)==0
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  scene.pbDisplay(_INTL("{1}'s Attack increased.",pkmn.name))
  pkmn.changeHappiness("vitamin")
  next true
})

ItemHandlers::UseOnPokemon.add(:IRON,proc { |item,pkmn,scene|
  if pbRaiseEffortValues(pkmn,:DEFENSE)==0
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  scene.pbDisplay(_INTL("{1}'s Defense increased.",pkmn.name))
  pkmn.changeHappiness("vitamin")
  next true
})

ItemHandlers::UseOnPokemon.add(:CALCIUM,proc { |item,pkmn,scene|
  if pbRaiseEffortValues(pkmn,:SPECIAL_ATTACK)==0
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  scene.pbDisplay(_INTL("{1}'s Special Attack increased.",pkmn.name))
  pkmn.changeHappiness("vitamin")
  next true
})

ItemHandlers::UseOnPokemon.add(:ZINC,proc { |item,pkmn,scene|
  if pbRaiseEffortValues(pkmn,:SPECIAL_DEFENSE)==0
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  scene.pbDisplay(_INTL("{1}'s Special Defense increased.",pkmn.name))
  pkmn.changeHappiness("vitamin")
  next true
})

ItemHandlers::UseOnPokemon.add(:CARBOS,proc { |item,pkmn,scene|
  if pbRaiseEffortValues(pkmn,:SPEED)==0
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  scene.pbDisplay(_INTL("{1}'s Speed increased.",pkmn.name))
  pkmn.changeHappiness("vitamin")
  next true
})

ItemHandlers::UseOnPokemon.add(:HEALTHWING,proc { |item,pkmn,scene|
  if pbRaiseEffortValues(pkmn,:HP,1,false)==0
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1}'s HP increased.",pkmn.name))
  pkmn.changeHappiness("wing")
  next true
})

ItemHandlers::UseOnPokemon.add(:MUSCLEWING,proc { |item,pkmn,scene|
  if pbRaiseEffortValues(pkmn,:ATTACK,1,false)==0
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  scene.pbDisplay(_INTL("{1}'s Attack increased.",pkmn.name))
  pkmn.changeHappiness("wing")
  next true
})

ItemHandlers::UseOnPokemon.add(:RESISTWING,proc { |item,pkmn,scene|
  if pbRaiseEffortValues(pkmn,:DEFENSE,1,false)==0
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  scene.pbDisplay(_INTL("{1}'s Defense increased.",pkmn.name))
  pkmn.changeHappiness("wing")
  next true
})

ItemHandlers::UseOnPokemon.add(:GENIUSWING,proc { |item,pkmn,scene|
  if pbRaiseEffortValues(pkmn,:SPECIAL_ATTACK,1,false)==0
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  scene.pbDisplay(_INTL("{1}'s Special Attack increased.",pkmn.name))
  pkmn.changeHappiness("wing")
  next true
})

ItemHandlers::UseOnPokemon.add(:CLEVERWING,proc { |item,pkmn,scene|
  if pbRaiseEffortValues(pkmn,:SPECIAL_DEFENSE,1,false)==0
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  scene.pbDisplay(_INTL("{1}'s Special Defense increased.",pkmn.name))
  pkmn.changeHappiness("wing")
  next true
})

ItemHandlers::UseOnPokemon.add(:SWIFTWING,proc { |item,pkmn,scene|
  if pbRaiseEffortValues(pkmn,:SPEED,1,false)==0
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  scene.pbDisplay(_INTL("{1}'s Speed increased.",pkmn.name))
  pkmn.changeHappiness("wing")
  next true
})

ItemHandlers::UseOnPokemon.add(:RARECANDY,proc { |item,pkmn,scene|
  if pkmn.level>=GameData::GrowthRate.max_level || pkmn.shadowPokemon?
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pbChangeLevel(pkmn,pkmn.level+1,scene)
  scene.pbHardRefresh
  next true
})

ItemHandlers::UseOnPokemon.add(:POMEGBERRY,proc { |item,pkmn,scene|
  next pbRaiseHappinessAndLowerEV(pkmn,scene,:HP,[
     _INTL("{1} adores you! Its base HP fell!",pkmn.name),
     _INTL("{1} became more friendly. Its base HP can't go lower.",pkmn.name),
     _INTL("{1} became more friendly. However, its base HP fell!",pkmn.name)
  ])
})

ItemHandlers::UseOnPokemon.add(:KELPSYBERRY,proc { |item,pkmn,scene|
  next pbRaiseHappinessAndLowerEV(pkmn,scene,:ATTACK,[
     _INTL("{1} adores you! Its base Attack fell!",pkmn.name),
     _INTL("{1} became more friendly. Its base Attack can't go lower.",pkmn.name),
     _INTL("{1} became more friendly. However, its base Attack fell!",pkmn.name)
  ])
})

ItemHandlers::UseOnPokemon.add(:QUALOTBERRY,proc { |item,pkmn,scene|
  next pbRaiseHappinessAndLowerEV(pkmn,scene,:DEFENSE,[
     _INTL("{1} adores you! Its base Defense fell!",pkmn.name),
     _INTL("{1} became more friendly. Its base Defense can't go lower.",pkmn.name),
     _INTL("{1} became more friendly. However, its base Defense fell!",pkmn.name)
  ])
})

ItemHandlers::UseOnPokemon.add(:HONDEWBERRY,proc { |item,pkmn,scene|
  next pbRaiseHappinessAndLowerEV(pkmn,scene,:SPECIAL_ATTACK,[
     _INTL("{1} adores you! Its base Special Attack fell!",pkmn.name),
     _INTL("{1} became more friendly. Its base Special Attack can't go lower.",pkmn.name),
     _INTL("{1} became more friendly. However, its base Special Attack fell!",pkmn.name)
  ])
})

ItemHandlers::UseOnPokemon.add(:GREPABERRY,proc { |item,pkmn,scene|
  next pbRaiseHappinessAndLowerEV(pkmn,scene,:SPECIAL_DEFENSE,[
     _INTL("{1} adores you! Its base Special Defense fell!",pkmn.name),
     _INTL("{1} became more friendly. Its base Special Defense can't go lower.",pkmn.name),
     _INTL("{1} became more friendly. However, its base Special Defense fell!",pkmn.name)
  ])
})

ItemHandlers::UseOnPokemon.add(:TAMATOBERRY,proc { |item,pkmn,scene|
  next pbRaiseHappinessAndLowerEV(pkmn,scene,:SPEED,[
     _INTL("{1} adores you! Its base Speed fell!",pkmn.name),
     _INTL("{1} became more friendly. Its base Speed can't go lower.",pkmn.name),
     _INTL("{1} became more friendly. However, its base Speed fell!",pkmn.name)
  ])
})

ItemHandlers::UseOnPokemon.add(:GRACIDEA,proc { |item,pkmn,scene|
  if !pkmn.isSpecies?(:SHAYMIN) || pkmn.form != 0 ||
     pkmn.status == :FROZEN || PBDayNight.isNight?
    scene.pbDisplay(_INTL("It had no effect."))
    next false
  end
  if pkmn.fainted?
    scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
    next false
  end
  pkmn.setForm(1) {
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1} changed Forme!",pkmn.name))
  }
  next true
})

ItemHandlers::UseOnPokemon.add(:REDNECTAR,proc { |item,pkmn,scene|
  if !pkmn.isSpecies?(:ORICORIO) || pkmn.form==0
    scene.pbDisplay(_INTL("It had no effect."))
    next false
  end
  if pkmn.fainted?
    scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
  end
  pkmn.setForm(0) {
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1} changed form!",pkmn.name))
  }
  next true
})

ItemHandlers::UseOnPokemon.add(:YELLOWNECTAR,proc { |item,pkmn,scene|
  if !pkmn.isSpecies?(:ORICORIO) || pkmn.form==1
    scene.pbDisplay(_INTL("It had no effect."))
    next false
  end
  if pkmn.fainted?
    scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
  end
  pkmn.setForm(1) {
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1} changed form!",pkmn.name))
  }
  next true
})

ItemHandlers::UseOnPokemon.add(:PINKNECTAR,proc { |item,pkmn,scene|
  if !pkmn.isSpecies?(:ORICORIO) || pkmn.form==2
    scene.pbDisplay(_INTL("It had no effect."))
    next false
  end
  if pkmn.fainted?
    scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
  end
  pkmn.setForm(2) {
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1} changed form!",pkmn.name))
  }
  next true
})

ItemHandlers::UseOnPokemon.add(:PURPLENECTAR,proc { |item,pkmn,scene|
  if !pkmn.isSpecies?(:ORICORIO) || pkmn.form==3
    scene.pbDisplay(_INTL("It had no effect."))
    next false
  end
  if pkmn.fainted?
    scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
  end
  pkmn.setForm(3) {
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1} changed form!",pkmn.name))
  }
  next true
})

ItemHandlers::UseOnPokemon.add(:REVEALGLASS,proc { |item,pkmn,scene|
  if !pkmn.isSpecies?(:TORNADUS) &&
     !pkmn.isSpecies?(:THUNDURUS) &&
     !pkmn.isSpecies?(:LANDORUS)
    scene.pbDisplay(_INTL("It had no effect."))
    next false
  end
  if pkmn.fainted?
    scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
    next false
  end
  newForm = (pkmn.form==0) ? 1 : 0
  pkmn.setForm(newForm) {
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1} changed Forme!",pkmn.name))
  }
  next true
})

ItemHandlers::UseOnPokemon.add(:PRISONBOTTLE,proc { |item,pkmn,scene|
  if !pkmn.isSpecies?(:HOOPA)
    scene.pbDisplay(_INTL("It had no effect."))
    next false
  end
  if pkmn.fainted?
    scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
  end
  newForm = (pkmn.form==0) ? 1 : 0
  pkmn.setForm(newForm) {
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1} changed Forme!",pkmn.name))
  }
  next true
})

ItemHandlers::UseOnPokemon.add(:DNASPLICERS,proc { |item,pkmn,scene|
  if !pkmn.isSpecies?(:KYUREM)
    scene.pbDisplay(_INTL("It had no effect."))
    next false
  end
  if pkmn.fainted?
    scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
    next false
  end
  # Fusing
  if pkmn.fused.nil?
    chosen = scene.pbChoosePokemon(_INTL("Fuse with which Pokémon?"))
    next false if chosen<0
    poke2 = $Trainer.party[chosen]
    if pkmn==poke2
      scene.pbDisplay(_INTL("It cannot be fused with itself."))
      next false
    elsif poke2.egg?
      scene.pbDisplay(_INTL("It cannot be fused with an Egg."))
      next false
    elsif poke2.fainted?
      scene.pbDisplay(_INTL("It cannot be fused with that fainted Pokémon."))
      next false
    elsif !poke2.isSpecies?(:RESHIRAM) &&
          !poke2.isSpecies?(:ZEKROM)
      scene.pbDisplay(_INTL("It cannot be fused with that Pokémon."))
      next false
    end
    newForm = 0
    newForm = 1 if poke2.isSpecies?(:RESHIRAM)
    newForm = 2 if poke2.isSpecies?(:ZEKROM)
    pkmn.setForm(newForm) {
      pkmn.fused = poke2
      $Trainer.remove_pokemon_at_index(chosen)
      scene.pbHardRefresh
      scene.pbDisplay(_INTL("{1} changed Forme!",pkmn.name))
    }
    next true
  end
  # Unfusing
  if $Trainer.party_full?
    scene.pbDisplay(_INTL("You have no room to separate the Pokémon."))
    next false
  end
  pkmn.setForm(0) {
    $Trainer.party[$Trainer.party.length] = pkmn.fused
    pkmn.fused = nil
    scene.pbHardRefresh
    scene.pbDisplay(_INTL("{1} changed Forme!",pkmn.name))
  }
  next true
})

ItemHandlers::UseOnPokemon.add(:NSOLARIZER,proc { |item,pkmn,scene|
  if !pkmn.isSpecies?(:NECROZMA) || pkmn.form == 2
    scene.pbDisplay(_INTL("It had no effect."))
    next false
  end
  if pkmn.fainted?
    scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
    next false
  end
  # Fusing
  if pkmn.fused.nil?
    chosen = scene.pbChoosePokemon(_INTL("Fuse with which Pokémon?"))
    next false if chosen<0
    poke2 = $Trainer.party[chosen]
    if pkmn==poke2
      scene.pbDisplay(_INTL("It cannot be fused with itself."))
      next false
    elsif poke2.egg?
      scene.pbDisplay(_INTL("It cannot be fused with an Egg."))
      next false
    elsif poke2.fainted?
      scene.pbDisplay(_INTL("It cannot be fused with that fainted Pokémon."))
      next false
    elsif !poke2.isSpecies?(:SOLGALEO)
      scene.pbDisplay(_INTL("It cannot be fused with that Pokémon."))
      next false
    end
    pkmn.setForm(1) {
      pkmn.fused = poke2
      $Trainer.remove_pokemon_at_index(chosen)
      scene.pbHardRefresh
      scene.pbDisplay(_INTL("{1} changed Forme!",pkmn.name))
    }
    next true
  end
  # Unfusing
  if $Trainer.party_full?
    scene.pbDisplay(_INTL("You have no room to separate the Pokémon."))
    next false
  end
  pkmn.setForm(0) {
    $Trainer.party[$Trainer.party.length] = pkmn.fused
    pkmn.fused = nil
    scene.pbHardRefresh
    scene.pbDisplay(_INTL("{1} changed Forme!",pkmn.name))
  }
  next true
})

ItemHandlers::UseOnPokemon.add(:NLUNARIZER,proc { |item,pkmn,scene|
  if !pkmn.isSpecies?(:NECROZMA) || pkmn.form == 1
    scene.pbDisplay(_INTL("It had no effect."))
    next false
  end
  if pkmn.fainted?
    scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
    next false
  end
  # Fusing
  if pkmn.fused.nil?
    chosen = scene.pbChoosePokemon(_INTL("Fuse with which Pokémon?"))
    next false if chosen<0
    poke2 = $Trainer.party[chosen]
    if pkmn==poke2
      scene.pbDisplay(_INTL("It cannot be fused with itself."))
      next false
    elsif poke2.egg?
      scene.pbDisplay(_INTL("It cannot be fused with an Egg."))
      next false
    elsif poke2.fainted?
      scene.pbDisplay(_INTL("It cannot be fused with that fainted Pokémon."))
      next false
    elsif !poke2.isSpecies?(:LUNALA)
      scene.pbDisplay(_INTL("It cannot be fused with that Pokémon."))
      next false
    end
    pkmn.setForm(2) {
      pkmn.fused = poke2
      $Trainer.remove_pokemon_at_index(chosen)
      scene.pbHardRefresh
      scene.pbDisplay(_INTL("{1} changed Forme!",pkmn.name))
    }
    next true
  end
  # Unfusing
  if $Trainer.party_full?
    scene.pbDisplay(_INTL("You have no room to separate the Pokémon."))
    next false
  end
  pkmn.setForm(0) {
    $Trainer.party[$Trainer.party.length] = pkmn.fused
    pkmn.fused = nil
    scene.pbHardRefresh
    scene.pbDisplay(_INTL("{1} changed Forme!",pkmn.name))
  }
  next true
})

ItemHandlers::UseOnPokemon.add(:ABILITYCAPSULE,proc { |item,pkmn,scene|
  abils = pkmn.getAbilityList
  abil1 = nil; abil2 = nil
  for i in abils
    abil1 = i[0] if i[1]==0
    abil2 = i[0] if i[1]==1
  end
  if abil1.nil? || abil2.nil? || pkmn.hasHiddenAbility? || pkmn.isSpecies?(:ZYGARDE)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  newabil = (pkmn.ability_index + 1) % 2
  newabilname = GameData::Ability.get((newabil==0) ? abil1 : abil2).name
  if scene.pbConfirm(_INTL("Would you like to change {1}'s Ability to {2}?",
     pkmn.name,newabilname))
    pkmn.ability_index = newabil
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1}'s Ability changed to {2}!",pkmn.name,newabilname))
    next true
  end
  next false
})
