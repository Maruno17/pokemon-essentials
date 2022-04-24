#===============================================================================
# CanUseInBattle handlers
#===============================================================================
ItemHandlers::CanUseInBattle.add(:GUARDSPEC, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  if !battler || battler.pbOwnSide.effects[PBEffects::Mist] > 0
    scene.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.add(:POKEDOLL, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  if !battle.wildBattle?
    if showMessages
      scene.pbDisplay(_INTL("Oak's words echoed... There's a time and place for everything! But not now."))
    end
    next false
  end
  if !battle.canRun
    scene.pbDisplay(_INTL("You can't escape!")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.copy(:POKEDOLL, :FLUFFYTAIL, :POKETOY)

ItemHandlers::CanUseInBattle.addIf(proc { |item| GameData::Item.get(item).is_poke_ball? },   # Poké Balls
  proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
    if battle.pbPlayer.party_full? && $PokemonStorage.full?
      scene.pbDisplay(_INTL("There is no room left in the PC!")) if showMessages
      next false
    end
    if battle.disablePokeBalls
      scene.pbDisplay(_INTL("You can't throw a Poké Ball!")) if showMessages
      next false
    end
    # NOTE: Using a Poké Ball consumes all your actions for the round. The code
    #       below is one half of making this happen; the other half is in def
    #       pbItemUsesAllActions?.
    if !firstAction
      scene.pbDisplay(_INTL("It's impossible to aim without being focused!")) if showMessages
      next false
    end
    if battler.semiInvulnerable?
      scene.pbDisplay(_INTL("It's no good! It's impossible to aim at a Pokémon that's not in sight!")) if showMessages
      next false
    end
    # NOTE: The code below stops you from throwing a Poké Ball if there is more
    #       than one unfainted opposing Pokémon. (Snag Balls can be thrown in
    #       this case, but only in trainer battles, and the trainer will deflect
    #       them if they are trying to catch a non-Shadow Pokémon.)
    if battle.pbOpposingBattlerCount > 1 && !(GameData::Item.get(item).is_snag_ball? && battle.trainerBattle?)
      if battle.pbOpposingBattlerCount == 2
        scene.pbDisplay(_INTL("It's no good! It's impossible to aim when there are two Pokémon!")) if showMessages
      elsif showMessages
        scene.pbDisplay(_INTL("It's no good! It's impossible to aim when there is more than one Pokémon!"))
      end
      next false
    end
    next true
  }
)

ItemHandlers::CanUseInBattle.add(:POTION, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  if !pokemon.able? || pokemon.hp == pokemon.totalhp
    scene.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.copy(:POTION,
   :SUPERPOTION, :HYPERPOTION, :MAXPOTION, :BERRYJUICE, :SWEETHEART, :FRESHWATER,
   :SODAPOP, :LEMONADE, :MOOMOOMILK, :ORANBERRY, :SITRUSBERRY, :ENERGYPOWDER,
   :ENERGYROOT)
ItemHandlers::CanUseInBattle.copy(:POTION, :RAGECANDYBAR) if !Settings::RAGE_CANDY_BAR_CURES_STATUS_PROBLEMS

ItemHandlers::CanUseInBattle.add(:AWAKENING, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  next pbBattleItemCanCureStatus?(:SLEEP, pokemon, scene, showMessages)
})

ItemHandlers::CanUseInBattle.copy(:AWAKENING, :CHESTOBERRY)

ItemHandlers::CanUseInBattle.add(:BLUEFLUTE, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  if battler&.hasActiveAbility?(:SOUNDPROOF)
    scene.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    next false
  end
  next pbBattleItemCanCureStatus?(:SLEEP, pokemon, scene, showMessages)
})

ItemHandlers::CanUseInBattle.add(:ANTIDOTE, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  next pbBattleItemCanCureStatus?(:POISON, pokemon, scene, showMessages)
})

ItemHandlers::CanUseInBattle.copy(:ANTIDOTE, :PECHABERRY)

ItemHandlers::CanUseInBattle.add(:BURNHEAL, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  next pbBattleItemCanCureStatus?(:BURN, pokemon, scene, showMessages)
})

ItemHandlers::CanUseInBattle.copy(:BURNHEAL, :RAWSTBERRY)

ItemHandlers::CanUseInBattle.add(:PARALYZEHEAL, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  next pbBattleItemCanCureStatus?(:PARALYSIS, pokemon, scene, showMessages)
})

ItemHandlers::CanUseInBattle.copy(:PARALYZEHEAL, :PARLYZHEAL, :CHERIBERRY)

ItemHandlers::CanUseInBattle.add(:ICEHEAL, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  next pbBattleItemCanCureStatus?(:FROZEN, pokemon, scene, showMessages)
})

ItemHandlers::CanUseInBattle.copy(:ICEHEAL, :ASPEARBERRY)

ItemHandlers::CanUseInBattle.add(:FULLHEAL, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  if !pokemon.able? ||
     (pokemon.status == :NONE &&
     (!battler || battler.effects[PBEffects::Confusion] == 0))
    scene.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.copy(:FULLHEAL,
   :LAVACOOKIE, :OLDGATEAU, :CASTELIACONE, :LUMIOSEGALETTE, :SHALOURSABLE,
   :BIGMALASADA, :PEWTERCRUNCHIES, :LUMBERRY, :HEALPOWDER)
ItemHandlers::CanUseInBattle.copy(:FULLHEAL, :RAGECANDYBAR) if Settings::RAGE_CANDY_BAR_CURES_STATUS_PROBLEMS

ItemHandlers::CanUseInBattle.add(:FULLRESTORE, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  if !pokemon.able? ||
     (pokemon.hp == pokemon.totalhp && pokemon.status == :NONE &&
     (!battler || battler.effects[PBEffects::Confusion] == 0))
    scene.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.add(:REVIVE, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  if pokemon.able? || pokemon.egg?
    scene.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.copy(:REVIVE, :MAXREVIVE, :REVIVALHERB, :MAXHONEY)

ItemHandlers::CanUseInBattle.add(:ETHER, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  if !pokemon.able? || move < 0 ||
     pokemon.moves[move].total_pp <= 0 ||
     pokemon.moves[move].pp == pokemon.moves[move].total_pp
    scene.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.copy(:ETHER, :MAXETHER, :LEPPABERRY)

ItemHandlers::CanUseInBattle.add(:ELIXIR, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  if !pokemon.able?
    scene.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    next false
  end
  canRestore = false
  pokemon.moves.each do |m|
    next if m.id == 0
    next if m.total_pp <= 0 || m.pp == m.total_pp
    canRestore = true
    break
  end
  if !canRestore
    scene.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.copy(:ELIXIR, :MAXELIXIR)

ItemHandlers::CanUseInBattle.add(:REDFLUTE, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  if !battler || battler.effects[PBEffects::Attract] < 0 ||
     battler.hasActiveAbility?(:SOUNDPROOF)
    scene.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.add(:PERSIMBERRY, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  if !battler || battler.effects[PBEffects::Confusion] == 0
    scene.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.add(:YELLOWFLUTE, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  if !battler || battler.effects[PBEffects::Confusion] == 0 ||
     battler.hasActiveAbility?(:SOUNDPROOF)
    scene.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.add(:XATTACK, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  next pbBattleItemCanRaiseStat?(:ATTACK, battler, scene, showMessages)
})

ItemHandlers::CanUseInBattle.copy(:XATTACK, :XATTACK2, :XATTACK3, :XATTACK6)

ItemHandlers::CanUseInBattle.add(:XDEFENSE, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  next pbBattleItemCanRaiseStat?(:DEFENSE, battler, scene, showMessages)
})

ItemHandlers::CanUseInBattle.copy(:XDEFENSE,
   :XDEFENSE2, :XDEFENSE3, :XDEFENSE6, :XDEFEND, :XDEFEND2, :XDEFEND3, :XDEFEND6)

ItemHandlers::CanUseInBattle.add(:XSPATK, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  next pbBattleItemCanRaiseStat?(:SPECIAL_ATTACK, battler, scene, showMessages)
})

ItemHandlers::CanUseInBattle.copy(:XSPATK,
   :XSPATK2, :XSPATK3, :XSPATK6, :XSPECIAL, :XSPECIAL2, :XSPECIAL3, :XSPECIAL6)

ItemHandlers::CanUseInBattle.add(:XSPDEF, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  next pbBattleItemCanRaiseStat?(:SPECIAL_DEFENSE, battler, scene, showMessages)
})

ItemHandlers::CanUseInBattle.copy(:XSPDEF, :XSPDEF2, :XSPDEF3, :XSPDEF6)

ItemHandlers::CanUseInBattle.add(:XSPEED, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  next pbBattleItemCanRaiseStat?(:SPEED, battler, scene, showMessages)
})

ItemHandlers::CanUseInBattle.copy(:XSPEED, :XSPEED2, :XSPEED3, :XSPEED6)

ItemHandlers::CanUseInBattle.add(:XACCURACY, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  next pbBattleItemCanRaiseStat?(:ACCURACY, battler, scene, showMessages)
})

ItemHandlers::CanUseInBattle.copy(:XACCURACY, :XACCURACY2, :XACCURACY3, :XACCURACY6)

ItemHandlers::CanUseInBattle.add(:MAXMUSHROOMS, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  if !pbBattleItemCanRaiseStat?(:ATTACK, battler, scene, false) &&
     !pbBattleItemCanRaiseStat?(:DEFENSE, battler, scene, false) &&
     !pbBattleItemCanRaiseStat?(:SPECIAL_ATTACK, battler, scene, false) &&
     !pbBattleItemCanRaiseStat?(:SPECIAL_DEFENSE, battler, scene, false) &&
     !pbBattleItemCanRaiseStat?(:SPEED, battler, scene, false)
    scene.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.add(:DIREHIT, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  if !battler || battler.effects[PBEffects::FocusEnergy] >= 1
    scene.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.add(:DIREHIT2, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  if !battler || battler.effects[PBEffects::FocusEnergy] >= 2
    scene.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.add(:DIREHIT3, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  if !battler || battler.effects[PBEffects::FocusEnergy] >= 3
    scene.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.add(:POKEFLUTE, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  if battle.allBattlers.none? { |b| b.status == :SLEEP && !b.hasActiveAbility?(:SOUNDPROOF) }
    scene.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    next false
  end
  next true
})

#===============================================================================
# UseInBattle handlers
# For items used directly or on an opposing battler
#===============================================================================
ItemHandlers::UseInBattle.add(:GUARDSPEC, proc { |item, battler, battle|
  battler.pbOwnSide.effects[PBEffects::Mist] = 5
  battle.pbDisplay(_INTL("{1} became shrouded in mist!", battler.pbTeam))
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::UseInBattle.add(:POKEDOLL, proc { |item, battler, battle|
  battle.decision = 3
  battle.pbDisplayPaused(_INTL("You got away safely!"))
})

ItemHandlers::UseInBattle.copy(:POKEDOLL, :FLUFFYTAIL, :POKETOY)

ItemHandlers::UseInBattle.add(:POKEFLUTE, proc { |item, battler, battle|
  battle.allBattlers.each do |b|
    b.pbCureStatus(false) if b.status == :SLEEP && !b.hasActiveAbility?(:SOUNDPROOF)
  end
  battle.pbDisplay(_INTL("All Pokémon were roused by the tune!"))
})

ItemHandlers::UseInBattle.addIf(proc { |item| GameData::Item.get(item).is_poke_ball? },   # Poké Balls
  proc { |item, battler, battle|
    battle.pbThrowPokeBall(battler.index, item)
  }
)

#===============================================================================
# BattleUseOnPokemon handlers
# For items used on Pokémon or on a Pokémon's move
#===============================================================================
ItemHandlers::BattleUseOnPokemon.add(:POTION, proc { |item, pokemon, battler, choices, scene|
  pbBattleHPItem(pokemon, battler, 20, scene)
})

ItemHandlers::BattleUseOnPokemon.copy(:POTION, :BERRYJUICE, :SWEETHEART)
ItemHandlers::BattleUseOnPokemon.copy(:POTION, :RAGECANDYBAR) if !Settings::RAGE_CANDY_BAR_CURES_STATUS_PROBLEMS

ItemHandlers::BattleUseOnPokemon.add(:SUPERPOTION, proc { |item, pokemon, battler, choices, scene|
  pbBattleHPItem(pokemon, battler, (Settings::REBALANCED_HEALING_ITEM_AMOUNTS) ? 60 : 50, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:HYPERPOTION, proc { |item, pokemon, battler, choices, scene|
  pbBattleHPItem(pokemon, battler, (Settings::REBALANCED_HEALING_ITEM_AMOUNTS) ? 120 : 200, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:MAXPOTION, proc { |item, pokemon, battler, choices, scene|
  pbBattleHPItem(pokemon, battler, pokemon.totalhp - pokemon.hp, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:FRESHWATER, proc { |item, pokemon, battler, choices, scene|
  pbBattleHPItem(pokemon, battler, (Settings::REBALANCED_HEALING_ITEM_AMOUNTS) ? 30 : 50, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:SODAPOP, proc { |item, pokemon, battler, choices, scene|
  pbBattleHPItem(pokemon, battler, (Settings::REBALANCED_HEALING_ITEM_AMOUNTS) ? 50 : 60, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:LEMONADE, proc { |item, pokemon, battler, choices, scene|
  pbBattleHPItem(pokemon, battler, (Settings::REBALANCED_HEALING_ITEM_AMOUNTS) ? 70 : 80, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:MOOMOOMILK, proc { |item, pokemon, battler, choices, scene|
  pbBattleHPItem(pokemon, battler, 100, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:ORANBERRY, proc { |item, pokemon, battler, choices, scene|
  pbBattleHPItem(pokemon, battler, 10, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:SITRUSBERRY, proc { |item, pokemon, battler, choices, scene|
  pbBattleHPItem(pokemon, battler, pokemon.totalhp / 4, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:AWAKENING, proc { |item, pokemon, battler, choices, scene|
  pokemon.heal_status
  battler&.pbCureStatus(false)
  name = (battler) ? battler.pbThis : pokemon.name
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1} woke up.", name))
})

ItemHandlers::BattleUseOnPokemon.copy(:AWAKENING, :CHESTOBERRY, :BLUEFLUTE)

ItemHandlers::BattleUseOnPokemon.add(:ANTIDOTE, proc { |item, pokemon, battler, choices, scene|
  pokemon.heal_status
  battler&.pbCureStatus(false)
  name = (battler) ? battler.pbThis : pokemon.name
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1} was cured of its poisoning.", name))
})

ItemHandlers::BattleUseOnPokemon.copy(:ANTIDOTE, :PECHABERRY)

ItemHandlers::BattleUseOnPokemon.add(:BURNHEAL, proc { |item, pokemon, battler, choices, scene|
  pokemon.heal_status
  battler&.pbCureStatus(false)
  name = (battler) ? battler.pbThis : pokemon.name
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1}'s burn was healed.", name))
})

ItemHandlers::BattleUseOnPokemon.copy(:BURNHEAL, :RAWSTBERRY)

ItemHandlers::BattleUseOnPokemon.add(:PARALYZEHEAL, proc { |item, pokemon, battler, choices, scene|
  pokemon.heal_status
  battler&.pbCureStatus(false)
  name = (battler) ? battler.pbThis : pokemon.name
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1} was cured of paralysis.", name))
})

ItemHandlers::BattleUseOnPokemon.copy(:PARALYZEHEAL, :PARLYZHEAL, :CHERIBERRY)

ItemHandlers::BattleUseOnPokemon.add(:ICEHEAL, proc { |item, pokemon, battler, choices, scene|
  pokemon.heal_status
  battler&.pbCureStatus(false)
  name = (battler) ? battler.pbThis : pokemon.name
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1} was thawed out.", name))
})

ItemHandlers::BattleUseOnPokemon.copy(:ICEHEAL, :ASPEARBERRY)

ItemHandlers::BattleUseOnPokemon.add(:FULLHEAL, proc { |item, pokemon, battler, choices, scene|
  pokemon.heal_status
  battler&.pbCureStatus(false)
  battler&.pbCureConfusion
  name = (battler) ? battler.pbThis : pokemon.name
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1} became healthy.", name))
})

ItemHandlers::BattleUseOnPokemon.copy(:FULLHEAL,
   :LAVACOOKIE, :OLDGATEAU, :CASTELIACONE, :LUMIOSEGALETTE, :SHALOURSABLE,
   :BIGMALASADA, :PEWTERCRUNCHIES, :LUMBERRY)
ItemHandlers::BattleUseOnPokemon.copy(:FULLHEAL, :RAGECANDYBAR) if Settings::RAGE_CANDY_BAR_CURES_STATUS_PROBLEMS

ItemHandlers::BattleUseOnPokemon.add(:FULLRESTORE, proc { |item, pokemon, battler, choices, scene|
  pokemon.heal_status
  battler&.pbCureStatus(false)
  battler&.pbCureConfusion
  name = (battler) ? battler.pbThis : pokemon.name
  if pokemon.hp < pokemon.totalhp
    pbBattleHPItem(pokemon, battler, pokemon.totalhp, scene)
  else
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1} became healthy.", name))
  end
})

ItemHandlers::BattleUseOnPokemon.add(:REVIVE, proc { |item, pokemon, battler, choices, scene|
  pokemon.hp = pokemon.totalhp / 2
  pokemon.hp = 1 if pokemon.hp <= 0
  pokemon.heal_status
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1} recovered from fainting!", pokemon.name))
})

ItemHandlers::BattleUseOnPokemon.add(:MAXREVIVE, proc { |item, pokemon, battler, choices, scene|
  pokemon.heal_HP
  pokemon.heal_status
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1} recovered from fainting!", pokemon.name))
})

ItemHandlers::BattleUseOnPokemon.copy(:MAXREVIVE, :MAXHONEY)

ItemHandlers::BattleUseOnPokemon.add(:ENERGYPOWDER, proc { |item, pokemon, battler, choices, scene|
  if pbBattleHPItem(pokemon, battler, (Settings::REBALANCED_HEALING_ITEM_AMOUNTS) ? 60 : 50, scene)
    pokemon.changeHappiness("powder")
  end
})

ItemHandlers::BattleUseOnPokemon.add(:ENERGYROOT, proc { |item, pokemon, battler, choices, scene|
  if pbBattleHPItem(pokemon, battler, (Settings::REBALANCED_HEALING_ITEM_AMOUNTS) ? 120 : 200, scene)
    pokemon.changeHappiness("energyroot")
  end
})

ItemHandlers::BattleUseOnPokemon.add(:HEALPOWDER, proc { |item, pokemon, battler, choices, scene|
  pokemon.heal_status
  battler&.pbCureStatus(false)
  battler&.pbCureConfusion
  pokemon.changeHappiness("powder")
  name = (battler) ? battler.pbThis : pokemon.name
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1} became healthy.", name))
})

ItemHandlers::BattleUseOnPokemon.add(:REVIVALHERB, proc { |item, pokemon, battler, choices, scene|
  pokemon.heal_HP
  pokemon.heal_status
  pokemon.changeHappiness("revivalherb")
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1} recovered from fainting!", pokemon.name))
})

ItemHandlers::BattleUseOnPokemon.add(:ETHER, proc { |item, pokemon, battler, choices, scene|
  idxMove = choices[3]
  pbBattleRestorePP(pokemon, battler, idxMove, 10)
  scene.pbDisplay(_INTL("PP was restored."))
})

ItemHandlers::BattleUseOnPokemon.copy(:ETHER, :LEPPABERRY)

ItemHandlers::BattleUseOnPokemon.add(:MAXETHER, proc { |item, pokemon, battler, choices, scene|
  idxMove = choices[3]
  pbBattleRestorePP(pokemon, battler, idxMove, pokemon.moves[idxMove].total_pp)
  scene.pbDisplay(_INTL("PP was restored."))
})

ItemHandlers::BattleUseOnPokemon.add(:ELIXIR, proc { |item, pokemon, battler, choices, scene|
  pokemon.moves.length.times do |i|
    pbBattleRestorePP(pokemon, battler, i, 10)
  end
  scene.pbDisplay(_INTL("PP was restored."))
})

ItemHandlers::BattleUseOnPokemon.add(:MAXELIXIR, proc { |item, pokemon, battler, choices, scene|
  pokemon.moves.length.times do |i|
    pbBattleRestorePP(pokemon, battler, i, pokemon.moves[i].total_pp)
  end
  scene.pbDisplay(_INTL("PP was restored."))
})

#===============================================================================
# BattleUseOnBattler handlers
# For items used on a Pokémon in battle
#===============================================================================

ItemHandlers::BattleUseOnBattler.add(:REDFLUTE, proc { |item, battler, scene|
  battler.pbCureAttract
  scene.pbDisplay(_INTL("{1} got over its infatuation.", battler.pbThis))
})

ItemHandlers::BattleUseOnBattler.add(:YELLOWFLUTE, proc { |item, battler, scene|
  battler.pbCureConfusion
  scene.pbDisplay(_INTL("{1} snapped out of its confusion.", battler.pbThis))
})

ItemHandlers::BattleUseOnBattler.copy(:YELLOWFLUTE, :PERSIMBERRY)

ItemHandlers::BattleUseOnBattler.add(:XATTACK, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:ATTACK, (Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:XATTACK2, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:ATTACK, 2, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:XATTACK3, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:ATTACK, 3, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:XATTACK6, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:ATTACK, 6, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:XDEFENSE, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:DEFENSE, (Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.copy(:XDEFENSE, :XDEFEND)

ItemHandlers::BattleUseOnBattler.add(:XDEFENSE2, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:DEFENSE, 2, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.copy(:XDEFENSE2, :XDEFEND2)

ItemHandlers::BattleUseOnBattler.add(:XDEFENSE3, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:DEFENSE, 3, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.copy(:XDEFENSE3, :XDEFEND3)

ItemHandlers::BattleUseOnBattler.add(:XDEFENSE6, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:DEFENSE, 6, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.copy(:XDEFENSE6, :XDEFEND6)

ItemHandlers::BattleUseOnBattler.add(:XSPATK, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:SPECIAL_ATTACK, (Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.copy(:XSPATK, :XSPECIAL)

ItemHandlers::BattleUseOnBattler.add(:XSPATK2, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:SPECIAL_ATTACK, 2, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.copy(:XSPATK2, :XSPECIAL2)

ItemHandlers::BattleUseOnBattler.add(:XSPATK3, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:SPECIAL_ATTACK, 3, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.copy(:XSPATK3, :XSPECIAL3)

ItemHandlers::BattleUseOnBattler.add(:XSPATK6, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:SPECIAL_ATTACK, 6, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.copy(:XSPATK6, :XSPECIAL6)

ItemHandlers::BattleUseOnBattler.add(:XSPDEF, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:SPECIAL_DEFENSE, (Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:XSPDEF2, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:SPECIAL_DEFENSE, 2, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:XSPDEF3, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:SPECIAL_DEFENSE, 3, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:XSPDEF6, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:SPECIAL_DEFENSE, 6, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:XSPEED, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:SPEED, (Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:XSPEED2, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:SPEED, 2, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:XSPEED3, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:SPEED, 3, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:XSPEED6, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:SPEED, 6, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:XACCURACY, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:ACCURACY, (Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:XACCURACY2, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:ACCURACY, 2, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:XACCURACY3, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:ACCURACY, 3, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:XACCURACY6, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:ACCURACY, 6, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:MAXMUSHROOMS, proc { |item, battler, scene|
  show_anim = true
  GameData::Stat.each_main_battle do |stat|
    next if !battler.pbCanRaiseStatStage?(stat.id, battler)
    battler.pbRaiseStatStage(stat.id, 1, battler, show_anim)
    show_anim = false
  end
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:DIREHIT, proc { |item, battler, scene|
  battler.effects[PBEffects::FocusEnergy] = 2
  scene.pbDisplay(_INTL("{1} is getting pumped!", battler.pbThis))
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:DIREHIT2, proc { |item, battler, scene|
  battler.effects[PBEffects::FocusEnergy] = 2
  scene.pbDisplay(_INTL("{1} is getting pumped!", battler.pbThis))
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:DIREHIT3, proc { |item, battler, scene|
  battler.effects[PBEffects::FocusEnergy] = 3
  scene.pbDisplay(_INTL("{1} is getting pumped!", battler.pbThis))
  battler.pokemon.changeHappiness("battleitem")
})
