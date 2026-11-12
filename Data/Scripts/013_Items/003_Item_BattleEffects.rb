#===============================================================================
# CanUseInBattle handlers.
#===============================================================================

ItemHandlers::CanUseInBattle.add(:GUARDSPEC, proc { |item, pokemon, battler, move, firstAction, battle, visuals, showMessages|
  if !battler || battler.pbOwnSide.effects[PBEffects::Mist] > 0
    visuals.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.add(:POKEDOLL, proc { |item, pokemon, battler, move, firstAction, battle, visuals, showMessages|
  if !battle.wildBattle?
    if showMessages
      visuals.pbDisplay(_INTL("Oak's words echoed... There's a time and place for everything! But not now."))
    end
    next false
  end
  if battle.rules[:cannot_run]
    visuals.pbDisplay(_INTL("You can't escape!")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.copy(:POKEDOLL, :FLUFFYTAIL, :POKETOY)

ItemHandlers::CanUseInBattle.addIf(:poke_balls,
  proc { |item| GameData::Item.get(item).is_poke_ball? },
  proc { |item, pokemon, battler, move, firstAction, battle, visuals, showMessages|
    if battle.pbPlayer.party_full? && $PokemonStorage.full?
      visuals.pbDisplay(_INTL("There is no room left in the PC!")) if showMessages
      next false
    end
    if battle.rules[:disable_poke_balls]
      visuals.pbDisplay(_INTL("You can't throw a Poké Ball!")) if showMessages
      next false
    end
    # NOTE: Using a Poké Ball consumes all your actions for the round. The code
    #       below is one half of making this happen; the other half is in def
    #       pbItemUsesAllActions?.
    if !firstAction
      visuals.pbDisplay(_INTL("It's impossible to aim without being focused!")) if showMessages
      next false
    end
    if battler.semiInvulnerable? || battler.effects[PBEffects::Commanding] >= 0
      visuals.pbDisplay(_INTL("It's no good! It's impossible to aim at a Pokémon that's not in sight!")) if showMessages
      next false
    end
    if battler.effects[PBEffects::CommandedBy] >= 0
      visuals.pbDisplay(_INTL("It's no good! It's impossible to aim unless there is only one Pokémon!")) if showMessages
      next false
    end
    # NOTE: The code below stops you from throwing a Poké Ball if there is more
    #       than one unfainted opposing Pokémon. (Snag Balls can be thrown in
    #       this case, but only in trainer battles, and the trainer will deflect
    #       them if they are trying to catch a non-Shadow Pokémon.)
    if battle.pbOpposingBattlerCount(0, true) > 1 &&
       !(GameData::Item.get(item).is_snag_ball? && battle.trainerBattle?)
      visuals.pbDisplay(_INTL("It's no good! It's impossible to aim unless there is only one Pokémon!")) if showMessages
      next false
    end
    next true
  }
)

ItemHandlers::CanUseInBattle.add(:POTION, proc { |item, pokemon, battler, move, firstAction, battle, visuals, showMessages|
  if !pokemon.able? || pokemon.hp == pokemon.totalhp
    visuals.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.copy(:POTION,
                                  :SUPERPOTION, :HYPERPOTION, :MAXPOTION,
                                  :BERRYJUICE, :SWEETHEART, :FRESHWATER, :SODAPOP,
                                  :LEMONADE, :MOOMOOMILK, :ORANBERRY, :SITRUSBERRY,
                                  :ENERGYPOWDER, :ENERGYROOT)
ItemHandlers::CanUseInBattle.copy(:POTION, :RAGECANDYBAR) if !Settings::RAGE_CANDY_BAR_CURES_STATUS_PROBLEMS

ItemHandlers::CanUseInBattle.add(:AWAKENING, proc { |item, pokemon, battler, move, firstAction, battle, visuals, showMessages|
  next pbBattleItemCanCureStatus?(:SLEEP, pokemon, visuals, showMessages)
})

ItemHandlers::CanUseInBattle.copy(:AWAKENING, :CHESTOBERRY)

ItemHandlers::CanUseInBattle.add(:BLUEFLUTE, proc { |item, pokemon, battler, move, firstAction, battle, visuals, showMessages|
  if battler&.hasActiveAbility?(:SOUNDPROOF)
    visuals.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    next false
  end
  next pbBattleItemCanCureStatus?(:SLEEP, pokemon, visuals, showMessages)
})

ItemHandlers::CanUseInBattle.add(:ANTIDOTE, proc { |item, pokemon, battler, move, firstAction, battle, visuals, showMessages|
  next pbBattleItemCanCureStatus?(:POISON, pokemon, visuals, showMessages)
})

ItemHandlers::CanUseInBattle.copy(:ANTIDOTE, :PECHABERRY)

ItemHandlers::CanUseInBattle.add(:BURNHEAL, proc { |item, pokemon, battler, move, firstAction, battle, visuals, showMessages|
  next pbBattleItemCanCureStatus?(:BURN, pokemon, visuals, showMessages)
})

ItemHandlers::CanUseInBattle.copy(:BURNHEAL, :RAWSTBERRY)

ItemHandlers::CanUseInBattle.add(:PARALYZEHEAL, proc { |item, pokemon, battler, move, firstAction, battle, visuals, showMessages|
  next pbBattleItemCanCureStatus?(:PARALYSIS, pokemon, visuals, showMessages)
})

ItemHandlers::CanUseInBattle.copy(:PARALYZEHEAL, :PARLYZHEAL, :CHERIBERRY)

ItemHandlers::CanUseInBattle.add(:ICEHEAL, proc { |item, pokemon, battler, move, firstAction, battle, visuals, showMessages|
  next pbBattleItemCanCureStatus?(:FROZEN, pokemon, visuals, showMessages)
})

ItemHandlers::CanUseInBattle.copy(:ICEHEAL, :ASPEARBERRY)

ItemHandlers::CanUseInBattle.add(:FULLHEAL, proc { |item, pokemon, battler, move, firstAction, battle, visuals, showMessages|
  if !pokemon.able? ||
     (pokemon.status == :NONE &&
     (!battler || battler.effects[PBEffects::Confusion] == 0))
    visuals.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.copy(:FULLHEAL,
                                  :LAVACOOKIE, :OLDGATEAU, :CASTELIACONE,
                                  :LUMIOSEGALETTE, :SHALOURSABLE, :BIGMALASADA,
                                  :PEWTERCRUNCHIES, :LUMBERRY, :HEALPOWDER)
ItemHandlers::CanUseInBattle.copy(:FULLHEAL, :RAGECANDYBAR) if Settings::RAGE_CANDY_BAR_CURES_STATUS_PROBLEMS

ItemHandlers::CanUseInBattle.add(:FULLRESTORE, proc { |item, pokemon, battler, move, firstAction, battle, visuals, showMessages|
  if !pokemon.able? ||
     (pokemon.hp == pokemon.totalhp && pokemon.status == :NONE &&
     (!battler || battler.effects[PBEffects::Confusion] == 0))
    visuals.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.add(:REVIVE, proc { |item, pokemon, battler, move, firstAction, battle, visuals, showMessages|
  if !pokemon.fainted?
    visuals.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.copy(:REVIVE, :MAXREVIVE, :REVIVALHERB, :MAXHONEY)

ItemHandlers::CanUseInBattle.add(:ETHER, proc { |item, pokemon, battler, move, firstAction, battle, visuals, showMessages|
  if !pokemon.able? || move < 0 ||
     pokemon.moves[move].total_pp <= 0 ||
     pokemon.moves[move].pp == pokemon.moves[move].total_pp
    visuals.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.copy(:ETHER, :MAXETHER, :LEPPABERRY)

ItemHandlers::CanUseInBattle.add(:ELIXIR, proc { |item, pokemon, battler, move, firstAction, battle, visuals, showMessages|
  if !pokemon.able?
    visuals.pbDisplay(_INTL("It won't have any effect.")) if showMessages
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
    visuals.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.copy(:ELIXIR, :MAXELIXIR)

ItemHandlers::CanUseInBattle.add(:REDFLUTE, proc { |item, pokemon, battler, move, firstAction, battle, visuals, showMessages|
  if !battler || battler.effects[PBEffects::Attract] < 0 ||
     battler.hasActiveAbility?(:SOUNDPROOF)
    visuals.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.add(:PERSIMBERRY, proc { |item, pokemon, battler, move, firstAction, battle, visuals, showMessages|
  if !battler || battler.effects[PBEffects::Confusion] == 0
    visuals.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.add(:YELLOWFLUTE, proc { |item, pokemon, battler, move, firstAction, battle, visuals, showMessages|
  if !battler || battler.effects[PBEffects::Confusion] == 0 ||
     battler.hasActiveAbility?(:SOUNDPROOF)
    visuals.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.add(:XATTACK, proc { |item, pokemon, battler, move, firstAction, battle, visuals, showMessages|
  next pbBattleItemCanRaiseStat?(:ATTACK, battler, visuals, showMessages)
})

ItemHandlers::CanUseInBattle.copy(:XATTACK, :XATTACK2, :XATTACK3, :XATTACK6)

ItemHandlers::CanUseInBattle.add(:XDEFENSE, proc { |item, pokemon, battler, move, firstAction, battle, visuals, showMessages|
  next pbBattleItemCanRaiseStat?(:DEFENSE, battler, visuals, showMessages)
})

ItemHandlers::CanUseInBattle.copy(:XDEFENSE,
                                  :XDEFENSE2, :XDEFENSE3, :XDEFENSE6,
                                  :XDEFEND, :XDEFEND2, :XDEFEND3, :XDEFEND6)

ItemHandlers::CanUseInBattle.add(:XSPATK, proc { |item, pokemon, battler, move, firstAction, battle, visuals, showMessages|
  next pbBattleItemCanRaiseStat?(:SPECIAL_ATTACK, battler, visuals, showMessages)
})

ItemHandlers::CanUseInBattle.copy(:XSPATK,
                                  :XSPATK2, :XSPATK3, :XSPATK6,
                                  :XSPECIAL, :XSPECIAL2, :XSPECIAL3, :XSPECIAL6)

ItemHandlers::CanUseInBattle.add(:XSPDEF, proc { |item, pokemon, battler, move, firstAction, battle, visuals, showMessages|
  next pbBattleItemCanRaiseStat?(:SPECIAL_DEFENSE, battler, visuals, showMessages)
})

ItemHandlers::CanUseInBattle.copy(:XSPDEF, :XSPDEF2, :XSPDEF3, :XSPDEF6)

ItemHandlers::CanUseInBattle.add(:XSPEED, proc { |item, pokemon, battler, move, firstAction, battle, visuals, showMessages|
  next pbBattleItemCanRaiseStat?(:SPEED, battler, visuals, showMessages)
})

ItemHandlers::CanUseInBattle.copy(:XSPEED, :XSPEED2, :XSPEED3, :XSPEED6)

ItemHandlers::CanUseInBattle.add(:XACCURACY, proc { |item, pokemon, battler, move, firstAction, battle, visuals, showMessages|
  next pbBattleItemCanRaiseStat?(:ACCURACY, battler, visuals, showMessages)
})

ItemHandlers::CanUseInBattle.copy(:XACCURACY, :XACCURACY2, :XACCURACY3, :XACCURACY6)

ItemHandlers::CanUseInBattle.add(:MAXMUSHROOMS, proc { |item, pokemon, battler, move, firstAction, battle, visuals, showMessages|
  if !pbBattleItemCanRaiseStat?(:ATTACK, battler, visuals, false) &&
     !pbBattleItemCanRaiseStat?(:DEFENSE, battler, visuals, false) &&
     !pbBattleItemCanRaiseStat?(:SPECIAL_ATTACK, battler, visuals, false) &&
     !pbBattleItemCanRaiseStat?(:SPECIAL_DEFENSE, battler, visuals, false) &&
     !pbBattleItemCanRaiseStat?(:SPEED, battler, visuals, false)
    visuals.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.add(:DIREHIT, proc { |item, pokemon, battler, move, firstAction, battle, visuals, showMessages|
  if !battler || battler.criticalHitRate >= 2
    visuals.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.add(:DIREHIT2, proc { |item, pokemon, battler, move, firstAction, battle, visuals, showMessages|
  if !battler || battler.criticalHitRate >= 2
    visuals.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.add(:DIREHIT3, proc { |item, pokemon, battler, move, firstAction, battle, visuals, showMessages|
  if !battler || battler.criticalHitRate >= 3
    visuals.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.add(:POKEFLUTE, proc { |item, pokemon, battler, move, firstAction, battle, visuals, showMessages|
  if battle.allBattlers.none? { |b| b.status == :SLEEP && !b.hasActiveAbility?(:SOUNDPROOF) }
    visuals.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    next false
  end
  next true
})

#===============================================================================
# UseInBattle handlers.
# For items used directly or on an opposing battler.
#===============================================================================

ItemHandlers::UseInBattle.add(:GUARDSPEC, proc { |item, battler, battle|
  battler.pbOwnSide.effects[PBEffects::Mist] = 5
  battle.pbDisplay(_INTL("{1} became shrouded in mist!", battler.pbTeam))
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::UseInBattle.add(:POKEDOLL, proc { |item, battler, battle|
  battle.decision = Battle::Outcome::FLEE
  battle.pbDisplayPaused(_INTL("You got away safely!"))
})

ItemHandlers::UseInBattle.copy(:POKEDOLL, :FLUFFYTAIL, :POKETOY)

ItemHandlers::UseInBattle.add(:POKEFLUTE, proc { |item, battler, battle|
  battle.allBattlers.each do |b|
    b.pbCureStatus(false) if b.status == :SLEEP && !b.hasActiveAbility?(:SOUNDPROOF)
  end
  battle.pbDisplay(_INTL("All Pokémon were roused by the tune!"))
})

ItemHandlers::UseInBattle.addIf(:poke_balls,
  proc { |item| GameData::Item.get(item).is_poke_ball? },
  proc { |item, battler, battle|
    battle.pbThrowPokeBall(battler.index, item)
  }
)

#===============================================================================
# BattleUseOnPokemon handlers.
# For items used on Pokémon or on a Pokémon's move.
#===============================================================================

ItemHandlers::BattleUseOnPokemon.add(:POTION, proc { |item, pokemon, battler, choices, visuals|
  pbBattleHPItem(pokemon, battler, 20, visuals)
})

ItemHandlers::BattleUseOnPokemon.copy(:POTION, :BERRYJUICE, :SWEETHEART)
ItemHandlers::BattleUseOnPokemon.copy(:POTION, :RAGECANDYBAR) if !Settings::RAGE_CANDY_BAR_CURES_STATUS_PROBLEMS

ItemHandlers::BattleUseOnPokemon.add(:SUPERPOTION, proc { |item, pokemon, battler, choices, visuals|
  pbBattleHPItem(pokemon, battler, (Settings::REBALANCED_HEALING_ITEM_AMOUNTS) ? 60 : 50, visuals)
})

ItemHandlers::BattleUseOnPokemon.add(:HYPERPOTION, proc { |item, pokemon, battler, choices, visuals|
  pbBattleHPItem(pokemon, battler, (Settings::REBALANCED_HEALING_ITEM_AMOUNTS) ? 120 : 200, visuals)
})

ItemHandlers::BattleUseOnPokemon.add(:MAXPOTION, proc { |item, pokemon, battler, choices, visuals|
  pbBattleHPItem(pokemon, battler, pokemon.totalhp - pokemon.hp, visuals)
})

ItemHandlers::BattleUseOnPokemon.add(:FRESHWATER, proc { |item, pokemon, battler, choices, visuals|
  pbBattleHPItem(pokemon, battler, (Settings::REBALANCED_HEALING_ITEM_AMOUNTS) ? 30 : 50, visuals)
})

ItemHandlers::BattleUseOnPokemon.add(:SODAPOP, proc { |item, pokemon, battler, choices, visuals|
  pbBattleHPItem(pokemon, battler, (Settings::REBALANCED_HEALING_ITEM_AMOUNTS) ? 50 : 60, visuals)
})

ItemHandlers::BattleUseOnPokemon.add(:LEMONADE, proc { |item, pokemon, battler, choices, visuals|
  pbBattleHPItem(pokemon, battler, (Settings::REBALANCED_HEALING_ITEM_AMOUNTS) ? 70 : 80, visuals)
})

ItemHandlers::BattleUseOnPokemon.add(:MOOMOOMILK, proc { |item, pokemon, battler, choices, visuals|
  pbBattleHPItem(pokemon, battler, 100, visuals)
})

ItemHandlers::BattleUseOnPokemon.add(:ORANBERRY, proc { |item, pokemon, battler, choices, visuals|
  pbBattleHPItem(pokemon, battler, 10, visuals)
})

ItemHandlers::BattleUseOnPokemon.add(:SITRUSBERRY, proc { |item, pokemon, battler, choices, visuals|
  pbBattleHPItem(pokemon, battler, pokemon.totalhp / 4, visuals)
})

ItemHandlers::BattleUseOnPokemon.add(:AWAKENING, proc { |item, pokemon, battler, choices, visuals|
  pokemon.heal_status
  battler&.pbCureStatus(false)
  name = (battler) ? battler.pbThis : pokemon.name
  visuals.pbRefresh
  visuals.pbDisplay(_INTL("{1} woke up.", name))
})

ItemHandlers::BattleUseOnPokemon.copy(:AWAKENING, :CHESTOBERRY, :BLUEFLUTE)

ItemHandlers::BattleUseOnPokemon.add(:ANTIDOTE, proc { |item, pokemon, battler, choices, visuals|
  pokemon.heal_status
  battler&.pbCureStatus(false)
  name = (battler) ? battler.pbThis : pokemon.name
  visuals.pbRefresh
  visuals.pbDisplay(_INTL("{1} was cured of its poisoning.", name))
})

ItemHandlers::BattleUseOnPokemon.copy(:ANTIDOTE, :PECHABERRY)

ItemHandlers::BattleUseOnPokemon.add(:BURNHEAL, proc { |item, pokemon, battler, choices, visuals|
  pokemon.heal_status
  battler&.pbCureStatus(false)
  name = (battler) ? battler.pbThis : pokemon.name
  visuals.pbRefresh
  visuals.pbDisplay(_INTL("{1}'s burn was healed.", name))
})

ItemHandlers::BattleUseOnPokemon.copy(:BURNHEAL, :RAWSTBERRY)

ItemHandlers::BattleUseOnPokemon.add(:PARALYZEHEAL, proc { |item, pokemon, battler, choices, visuals|
  pokemon.heal_status
  battler&.pbCureStatus(false)
  name = (battler) ? battler.pbThis : pokemon.name
  visuals.pbRefresh
  visuals.pbDisplay(_INTL("{1} was cured of paralysis.", name))
})

ItemHandlers::BattleUseOnPokemon.copy(:PARALYZEHEAL, :PARLYZHEAL, :CHERIBERRY)

ItemHandlers::BattleUseOnPokemon.add(:ICEHEAL, proc { |item, pokemon, battler, choices, visuals|
  pokemon.heal_status
  battler&.pbCureStatus(false)
  name = (battler) ? battler.pbThis : pokemon.name
  visuals.pbRefresh
  visuals.pbDisplay(_INTL("{1} was thawed out.", name))
})

ItemHandlers::BattleUseOnPokemon.copy(:ICEHEAL, :ASPEARBERRY)

ItemHandlers::BattleUseOnPokemon.add(:FULLHEAL, proc { |item, pokemon, battler, choices, visuals|
  pokemon.heal_status
  battler&.pbCureStatus(false)
  battler&.pbCureConfusion
  name = (battler) ? battler.pbThis : pokemon.name
  visuals.pbRefresh
  visuals.pbDisplay(_INTL("{1} became healthy.", name))
})

ItemHandlers::BattleUseOnPokemon.copy(:FULLHEAL,
                                      :LAVACOOKIE, :OLDGATEAU, :CASTELIACONE,
                                      :LUMIOSEGALETTE, :SHALOURSABLE, :BIGMALASADA,
                                      :PEWTERCRUNCHIES, :LUMBERRY)
ItemHandlers::BattleUseOnPokemon.copy(:FULLHEAL, :RAGECANDYBAR) if Settings::RAGE_CANDY_BAR_CURES_STATUS_PROBLEMS

ItemHandlers::BattleUseOnPokemon.add(:FULLRESTORE, proc { |item, pokemon, battler, choices, visuals|
  pokemon.heal_status
  battler&.pbCureStatus(false)
  battler&.pbCureConfusion
  name = (battler) ? battler.pbThis : pokemon.name
  if pokemon.hp < pokemon.totalhp
    pbBattleHPItem(pokemon, battler, pokemon.totalhp, visuals)
  else
    visuals.pbRefresh
    visuals.pbDisplay(_INTL("{1} became healthy.", name))
  end
})

ItemHandlers::BattleUseOnPokemon.add(:REVIVE, proc { |item, pokemon, battler, choices, visuals|
  pokemon.hp = pokemon.totalhp / 2
  pokemon.hp = 1 if pokemon.hp <= 0
  pokemon.heal_status
  visuals.pbRefresh
  visuals.pbDisplay(_INTL("{1} recovered from fainting!", pokemon.name))
})

ItemHandlers::BattleUseOnPokemon.add(:MAXREVIVE, proc { |item, pokemon, battler, choices, visuals|
  pokemon.heal_HP
  pokemon.heal_status
  visuals.pbRefresh
  visuals.pbDisplay(_INTL("{1} recovered from fainting!", pokemon.name))
})

ItemHandlers::BattleUseOnPokemon.copy(:MAXREVIVE, :MAXHONEY)

ItemHandlers::BattleUseOnPokemon.add(:ENERGYPOWDER, proc { |item, pokemon, battler, choices, visuals|
  if pbBattleHPItem(pokemon, battler, (Settings::REBALANCED_HEALING_ITEM_AMOUNTS) ? 60 : 50, visuals)
    pokemon.changeHappiness("powder")
  end
})

ItemHandlers::BattleUseOnPokemon.add(:ENERGYROOT, proc { |item, pokemon, battler, choices, visuals|
  if pbBattleHPItem(pokemon, battler, (Settings::REBALANCED_HEALING_ITEM_AMOUNTS) ? 120 : 200, visuals)
    pokemon.changeHappiness("energyroot")
  end
})

ItemHandlers::BattleUseOnPokemon.add(:HEALPOWDER, proc { |item, pokemon, battler, choices, visuals|
  pokemon.heal_status
  battler&.pbCureStatus(false)
  battler&.pbCureConfusion
  pokemon.changeHappiness("powder")
  name = (battler) ? battler.pbThis : pokemon.name
  visuals.pbRefresh
  visuals.pbDisplay(_INTL("{1} became healthy.", name))
})

ItemHandlers::BattleUseOnPokemon.add(:REVIVALHERB, proc { |item, pokemon, battler, choices, visuals|
  pokemon.heal_HP
  pokemon.heal_status
  pokemon.changeHappiness("revivalherb")
  visuals.pbRefresh
  visuals.pbDisplay(_INTL("{1} recovered from fainting!", pokemon.name))
})

ItemHandlers::BattleUseOnPokemon.add(:ETHER, proc { |item, pokemon, battler, choices, visuals|
  idxMove = choices[3]
  pbBattleRestorePP(pokemon, battler, idxMove, 10)
  pbSEPlay("Use item in party")
  if battler
    if battler.battle.pbOwnedByPlayer?(battler.index)
      visuals.pbDisplay(_INTL("The PP of {1}'s {2} was restored!",
                              battler.name, pokemon.moves[idxMove].name))
    else
      visuals.pbDisplay(_INTL("{1}'s {2} had its {3} PP restored!",
                              battler.battle.pbGetOwnerName(battler.index),
                              battler.name, pokemon.moves[idxMove].name))
    end
  else
    visuals.pbDisplay(_INTL("The PP of {1}'s {2} was restored!", pokemon.name, pokemon.moves[idxMove].name))
  end
})

ItemHandlers::BattleUseOnPokemon.copy(:ETHER, :LEPPABERRY)

ItemHandlers::BattleUseOnPokemon.add(:MAXETHER, proc { |item, pokemon, battler, choices, visuals|
  idxMove = choices[3]
  pbBattleRestorePP(pokemon, battler, idxMove, pokemon.moves[idxMove].total_pp)
  pbSEPlay("Use item in party")
  if battler
    if battler.battle.pbOwnedByPlayer?(battler.index)
      visuals.pbDisplay(_INTL("The PP of {1}'s {2} was restored!",
                              battler.name, pokemon.moves[idxMove].name))
    else
      visuals.pbDisplay(_INTL("{1}'s {2} had its {3} PP restored!",
                              battler.battle.pbGetOwnerName(battler.index),
                              battler.name, pokemon.moves[idxMove].name))
    end
  else
    visuals.pbDisplay(_INTL("The PP of {1}'s {2} was restored!", pokemon.name, pokemon.moves[idxMove].name))
  end
})

ItemHandlers::BattleUseOnPokemon.add(:ELIXIR, proc { |item, pokemon, battler, choices, visuals|
  pokemon.moves.length.times do |i|
    pbBattleRestorePP(pokemon, battler, i, 10)
  end
  pbSEPlay("Use item in party")
  if battler
    if battler.battle.pbOwnedByPlayer?(battler.index)
      visuals.pbDisplay(_INTL("All of {1}'s moves had their PP restored!", battler.name))
    else
      visuals.pbDisplay(_INTL("{1}'s {2} had PP restored to all of its moves!",
                              battler.battle.pbGetOwnerName(battler.index), battler.name))
    end
  else
    visuals.pbDisplay(_INTL("All of {1}'s moves had their PP restored!", pokemon.name))
  end
})

ItemHandlers::BattleUseOnPokemon.add(:MAXELIXIR, proc { |item, pokemon, battler, choices, visuals|
  pokemon.moves.length.times do |i|
    pbBattleRestorePP(pokemon, battler, i, pokemon.moves[i].total_pp)
  end
  pbSEPlay("Use item in party")
  if battler
    if battler.battle.pbOwnedByPlayer?(battler.index)
      visuals.pbDisplay(_INTL("All of {1}'s moves had their PP restored!", battler.name))
    else
      visuals.pbDisplay(_INTL("{1}'s {2} had PP restored to all of its moves!",
                              battler.battle.pbGetOwnerName(battler.index), battler.name))
    end
  else
    visuals.pbDisplay(_INTL("All of {1}'s moves had their PP restored!", pokemon.name))
  end
})

#===============================================================================
# BattleUseOnBattler handlers.
# For items used on a Pokémon in battle.
#===============================================================================

ItemHandlers::BattleUsableOnBattler.add(:REDFLUTE, proc { |item, battler|
  next battler.effects[PBEffects::Attract] >= 0
})
ItemHandlers::BattleUseOnBattler.add(:REDFLUTE, proc { |item, battler, visuals|
  battler.pbCureAttract
  visuals.pbDisplay(_INTL("{1} got over its infatuation.", battler.pbThis))
})

ItemHandlers::BattleUsableOnBattler.add(:YELLOWFLUTE, proc { |item, battler|
  next battler.effects[PBEffects::Confusion] > 0
})
ItemHandlers::BattleUseOnBattler.add(:YELLOWFLUTE, proc { |item, battler, visuals|
  battler.pbCureConfusion
  visuals.pbDisplay(_INTL("{1} snapped out of its confusion.", battler.pbThis))
})

ItemHandlers::BattleUsableOnBattler.copy(:YELLOWFLUTE, :PERSIMBERRY)
ItemHandlers::BattleUseOnBattler.copy(:YELLOWFLUTE, :PERSIMBERRY)

ItemHandlers::BattleUsableOnBattler.add(:XATTACK, proc { |item, battler|
  next battler.pbCanRaiseStatStage?(:ATTACK, battler)
})
ItemHandlers::BattleUseOnBattler.add(:XATTACK, proc { |item, battler, visuals|
  battler.pbRaiseStatStage(:ATTACK, (Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUsableOnBattler.copy(:XATTACK, :XATTACK2, :XATTACK3, :XATTACK6)
ItemHandlers::BattleUseOnBattler.add(:XATTACK2, proc { |item, battler, visuals|
  battler.pbRaiseStatStage(:ATTACK, 2, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:XATTACK3, proc { |item, battler, visuals|
  battler.pbRaiseStatStage(:ATTACK, 3, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:XATTACK6, proc { |item, battler, visuals|
  battler.pbRaiseStatStage(:ATTACK, 6, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUsableOnBattler.add(:XDEFENSE, proc { |item, battler|
  next battler.pbCanRaiseStatStage?(:DEFENSE, battler)
})
ItemHandlers::BattleUseOnBattler.add(:XDEFENSE, proc { |item, battler, visuals|
  battler.pbRaiseStatStage(:DEFENSE, (Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUsableOnBattler.copy(:XDEFENSE, :XDEFEND)
ItemHandlers::BattleUseOnBattler.copy(:XDEFENSE, :XDEFEND)

ItemHandlers::BattleUsableOnBattler.copy(:XDEFENSE, :XDEFENSE2, :XDEFEND2, :XDEFENSE3, :XDEFEND3, :XDEFENSE6, :XDEFEND6)
ItemHandlers::BattleUseOnBattler.add(:XDEFENSE2, proc { |item, battler, visuals|
  battler.pbRaiseStatStage(:DEFENSE, 2, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.copy(:XDEFENSE2, :XDEFEND2)

ItemHandlers::BattleUseOnBattler.add(:XDEFENSE3, proc { |item, battler, visuals|
  battler.pbRaiseStatStage(:DEFENSE, 3, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.copy(:XDEFENSE3, :XDEFEND3)

ItemHandlers::BattleUseOnBattler.add(:XDEFENSE6, proc { |item, battler, visuals|
  battler.pbRaiseStatStage(:DEFENSE, 6, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.copy(:XDEFENSE6, :XDEFEND6)

ItemHandlers::BattleUsableOnBattler.add(:XSPATK, proc { |item, battler|
  next battler.pbCanRaiseStatStage?(:SPECIAL_ATTACK, battler)
})
ItemHandlers::BattleUseOnBattler.add(:XSPATK, proc { |item, battler, visuals|
  battler.pbRaiseStatStage(:SPECIAL_ATTACK, (Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUsableOnBattler.copy(:XSPATK, :XSPECIAL)
ItemHandlers::BattleUseOnBattler.copy(:XSPATK, :XSPECIAL)

ItemHandlers::BattleUsableOnBattler.copy(:XSPATK, :XSPATK2, :XSPECIAL2, :XSPATK3, :XSPECIAL3, :XSPATK6, :XSPECIAL6)
ItemHandlers::BattleUseOnBattler.add(:XSPATK2, proc { |item, battler, visuals|
  battler.pbRaiseStatStage(:SPECIAL_ATTACK, 2, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.copy(:XSPATK2, :XSPECIAL2)

ItemHandlers::BattleUseOnBattler.add(:XSPATK3, proc { |item, battler, visuals|
  battler.pbRaiseStatStage(:SPECIAL_ATTACK, 3, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.copy(:XSPATK3, :XSPECIAL3)

ItemHandlers::BattleUseOnBattler.add(:XSPATK6, proc { |item, battler, visuals|
  battler.pbRaiseStatStage(:SPECIAL_ATTACK, 6, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.copy(:XSPATK6, :XSPECIAL6)

ItemHandlers::BattleUsableOnBattler.add(:XSPDEF, proc { |item, battler|
  next battler.pbCanRaiseStatStage?(:SPECIAL_DEFENSE, battler)
})
ItemHandlers::BattleUseOnBattler.add(:XSPDEF, proc { |item, battler, visuals|
  battler.pbRaiseStatStage(:SPECIAL_DEFENSE, (Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUsableOnBattler.copy(:XSPDEF, :XSPDEF2, :XSPDEF3, :XSPDEF6)
ItemHandlers::BattleUseOnBattler.add(:XSPDEF2, proc { |item, battler, visuals|
  battler.pbRaiseStatStage(:SPECIAL_DEFENSE, 2, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:XSPDEF3, proc { |item, battler, visuals|
  battler.pbRaiseStatStage(:SPECIAL_DEFENSE, 3, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:XSPDEF6, proc { |item, battler, visuals|
  battler.pbRaiseStatStage(:SPECIAL_DEFENSE, 6, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUsableOnBattler.add(:XSPEED, proc { |item, battler|
  next battler.pbCanRaiseStatStage?(:SPEED, battler)
})
ItemHandlers::BattleUseOnBattler.add(:XSPEED, proc { |item, battler, visuals|
  battler.pbRaiseStatStage(:SPEED, (Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUsableOnBattler.copy(:XSPEED, :XSPEED2, :XSPEED3, :XSPEED6)
ItemHandlers::BattleUseOnBattler.add(:XSPEED2, proc { |item, battler, visuals|
  battler.pbRaiseStatStage(:SPEED, 2, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:XSPEED3, proc { |item, battler, visuals|
  battler.pbRaiseStatStage(:SPEED, 3, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:XSPEED6, proc { |item, battler, visuals|
  battler.pbRaiseStatStage(:SPEED, 6, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUsableOnBattler.add(:XACCURACY, proc { |item, battler|
  next battler.pbCanRaiseStatStage?(:ACCURACY, battler)
})
ItemHandlers::BattleUseOnBattler.add(:XACCURACY, proc { |item, battler, visuals|
  battler.pbRaiseStatStage(:ACCURACY, (Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUsableOnBattler.copy(:XACCURACY, :XACCURACY2, :XACCURACY3, :XACCURACY6)
ItemHandlers::BattleUseOnBattler.add(:XACCURACY2, proc { |item, battler, visuals|
  battler.pbRaiseStatStage(:ACCURACY, 2, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:XACCURACY3, proc { |item, battler, visuals|
  battler.pbRaiseStatStage(:ACCURACY, 3, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:XACCURACY6, proc { |item, battler, visuals|
  battler.pbRaiseStatStage(:ACCURACY, 6, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUsableOnBattler.add(:MAXMUSHROOMS, proc { |item, battler|
  can_raise = false
  GameData::Stat.each_main_battle do |stat|
    can_raise = true if battler.pbCanRaiseStatStage?(stat.id, battler)
    break if can_raise
  end
  next can_raise
})
ItemHandlers::BattleUseOnBattler.add(:MAXMUSHROOMS, proc { |item, battler, visuals|
  show_anim = true
  GameData::Stat.each_main_battle do |stat|
    next if !battler.pbCanRaiseStatStage?(stat.id, battler)
    battler.pbRaiseStatStage(stat.id, 1, battler, show_anim)
    show_anim = false
  end
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUsableOnBattler.add(:DIREHIT, proc { |item, battler|
  next battler.criticalHitRate < 2
})
ItemHandlers::BattleUseOnBattler.add(:DIREHIT, proc { |item, battler, visuals|
  battler.setCriticalHitRate(2)
  visuals.pbCommonAnimation("CriticalHitRateUp", battler)
  visuals.pbDisplay(_INTL("{1} is getting pumped!", battler.pbThis))
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUsableOnBattler.add(:DIREHIT2, proc { |item, battler|
  next battler.criticalHitRate < 2
})
ItemHandlers::BattleUseOnBattler.add(:DIREHIT2, proc { |item, battler, visuals|
  battler.setCriticalHitRate(2)
  visuals.pbCommonAnimation("CriticalHitRateUp", battler)
  visuals.pbDisplay(_INTL("{1} is getting pumped!", battler.pbThis))
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUsableOnBattler.add(:DIREHIT3, proc { |item, battler|
  next battler.criticalHitRate < 3
})
ItemHandlers::BattleUseOnBattler.add(:DIREHIT3, proc { |item, battler, visuals|
  battler.setCriticalHitRate(3)
  visuals.pbCommonAnimation("CriticalHitRateUp", battler)
  visuals.pbDisplay(_INTL("{1} is getting pumped!", battler.pbThis))
  battler.pokemon.changeHappiness("battleitem")
})
