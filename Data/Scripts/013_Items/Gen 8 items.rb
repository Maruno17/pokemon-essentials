ItemHandlers::UseOnPokemon.add(:EXPCANDYXS, proc { |item, pkmn, scene|
  if pkmn.level >= GameData::GrowthRate.max_level || pkmn.shadowPokemon?
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  gain_amount = 100
  maximum = ((pkmn.growth_rate.maximum_exp - pkmn.exp) / gain_amount.to_f).ceil
  maximum = [maximum, $PokemonBag.pbQuantity(item)].min
  qty = scene.scene.pbChooseNumber(
     _INTL("How many {1} do you want to use?", GameData::Item.get(item).name), maximum)
  next false if qty == 0
  scene.scene.pbSetHelpText("") if scene.is_a?(PokemonPartyScreen)
  pbChangeExp(pkmn, pkmn.exp + gain_amount * qty, scene)
  $PokemonBag.pbDeleteItem(item, qty - 1)
  scene.pbHardRefresh
  next true
})

ItemHandlers::UseOnPokemon.add(:EXPCANDYS, proc { |item, pkmn, scene|
  if pkmn.level >= GameData::GrowthRate.max_level || pkmn.shadowPokemon?
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  gain_amount = 800
  maximum = ((pkmn.growth_rate.maximum_exp - pkmn.exp) / gain_amount.to_f).ceil
  maximum = [maximum, $PokemonBag.pbQuantity(item)].min
  qty = scene.scene.pbChooseNumber(
     _INTL("How many {1} do you want to use?", GameData::Item.get(item).name), maximum)
  next false if qty == 0
  scene.scene.pbSetHelpText("") if scene.is_a?(PokemonPartyScreen)
  pbChangeExp(pkmn, pkmn.exp + gain_amount * qty, scene)
  $PokemonBag.pbDeleteItem(item, qty - 1)
  scene.pbHardRefresh
  next true
})

ItemHandlers::UseOnPokemon.add(:EXPCANDYM, proc { |item, pkmn, scene|
  if pkmn.level >= GameData::GrowthRate.max_level || pkmn.shadowPokemon?
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  gain_amount = 3_000
  maximum = ((pkmn.growth_rate.maximum_exp - pkmn.exp) / gain_amount.to_f).ceil
  maximum = [maximum, $PokemonBag.pbQuantity(item)].min
  qty = scene.scene.pbChooseNumber(
     _INTL("How many {1} do you want to use?", GameData::Item.get(item).name), maximum)
  next false if qty == 0
  scene.scene.pbSetHelpText("") if scene.is_a?(PokemonPartyScreen)
  pbChangeExp(pkmn, pkmn.exp + gain_amount * qty, scene)
  $PokemonBag.pbDeleteItem(item, qty - 1)
  scene.pbHardRefresh
  next true
})

ItemHandlers::UseOnPokemon.add(:EXPCANDYL, proc { |item, pkmn, scene|
  if pkmn.level >= GameData::GrowthRate.max_level || pkmn.shadowPokemon?
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  gain_amount = 10_000
  maximum = ((pkmn.growth_rate.maximum_exp - pkmn.exp) / gain_amount.to_f).ceil
  maximum = [maximum, $PokemonBag.pbQuantity(item)].min
  qty = scene.scene.pbChooseNumber(
     _INTL("How many {1} do you want to use?", GameData::Item.get(item).name), maximum)
  next false if qty == 0
  scene.scene.pbSetHelpText("") if scene.is_a?(PokemonPartyScreen)
  pbChangeExp(pkmn, pkmn.exp + gain_amount * qty, scene)
  $PokemonBag.pbDeleteItem(item, qty - 1)
  scene.pbHardRefresh
  next true
})

ItemHandlers::UseOnPokemon.add(:EXPCANDYXL, proc { |item, pkmn, scene|
  if pkmn.level >= GameData::GrowthRate.max_level || pkmn.shadowPokemon?
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  gain_amount = 30_000
  maximum = ((pkmn.growth_rate.maximum_exp - pkmn.exp) / gain_amount.to_f).ceil
  maximum = [maximum, $PokemonBag.pbQuantity(item)].min
  qty = scene.scene.pbChooseNumber(
     _INTL("How many {1} do you want to use?", GameData::Item.get(item).name), maximum)
  next false if qty == 0
  scene.scene.pbSetHelpText("") if scene.is_a?(PokemonPartyScreen)
  pbChangeExp(pkmn, pkmn.exp + gain_amount * qty, scene)
  $PokemonBag.pbDeleteItem(item, qty - 1)
  scene.pbHardRefresh
  next true
})

def pbNatureChangingMint(new_nature, item, pkmn, scene)
  if pkmn.nature_for_stats == new_nature
    scene.pbDisplay(_INTL("It won't have any effect."))
    return false
  end
  if !scene.pbConfirm(_INTL("It might affect {1}'s stats. Are you sure you want to use it?", pkmn.name))
    return false
  end
  pkmn.nature_for_stats = new_nature
  pkmn.calc_stats
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1}'s stats may have changed due to the effects of the {2}!",
     pkmn.name, GameData::Item.get(item).name))
  return true
end

ItemHandlers::UseOnPokemon.add(:LONELYMINT, proc { |item, pkmn, scene|
  pbNatureChangingMint(:LONELY, item, pkmn, scene)
})

ItemHandlers::UseOnPokemon.add(:ADAMANTMINT, proc { |item, pkmn, scene|
  pbNatureChangingMint(:ADAMANT, item, pkmn, scene)
})

ItemHandlers::UseOnPokemon.add(:NAUGHTYMINT, proc { |item, pkmn, scene|
  pbNatureChangingMint(:NAUGHTY, item, pkmn, scene)
})

ItemHandlers::UseOnPokemon.add(:BRAVEMINT, proc { |item, pkmn, scene|
  pbNatureChangingMint(:BRAVE, item, pkmn, scene)
})

ItemHandlers::UseOnPokemon.add(:BOLDMINT, proc { |item, pkmn, scene|
  pbNatureChangingMint(:BOLD, item, pkmn, scene)
})

ItemHandlers::UseOnPokemon.add(:IMPISHMINT, proc { |item, pkmn, scene|
  pbNatureChangingMint(:IMPISH, item, pkmn, scene)
})

ItemHandlers::UseOnPokemon.add(:LAXMINT, proc { |item, pkmn, scene|
  pbNatureChangingMint(:LAX, item, pkmn, scene)
})

ItemHandlers::UseOnPokemon.add(:RELAXEDMINT, proc { |item, pkmn, scene|
  pbNatureChangingMint(:RELAXED, item, pkmn, scene)
})

ItemHandlers::UseOnPokemon.add(:MODESTMINT, proc { |item, pkmn, scene|
  pbNatureChangingMint(:MODEST, item, pkmn, scene)
})

ItemHandlers::UseOnPokemon.add(:MILDMINT, proc { |item, pkmn, scene|
  pbNatureChangingMint(:MILD, item, pkmn, scene)
})

ItemHandlers::UseOnPokemon.add(:RASHMINT, proc { |item, pkmn, scene|
  pbNatureChangingMint(:RASH, item, pkmn, scene)
})

ItemHandlers::UseOnPokemon.add(:QUIETMINT, proc { |item, pkmn, scene|
  pbNatureChangingMint(:QUIET, item, pkmn, scene)
})

ItemHandlers::UseOnPokemon.add(:CALMMINT, proc { |item, pkmn, scene|
  pbNatureChangingMint(:CALM, item, pkmn, scene)
})

ItemHandlers::UseOnPokemon.add(:GENTLEMINT, proc { |item, pkmn, scene|
  pbNatureChangingMint(:GENTLE, item, pkmn, scene)
})

ItemHandlers::UseOnPokemon.add(:CAREFULMINT, proc { |item, pkmn, scene|
  pbNatureChangingMint(:CAREFUL, item, pkmn, scene)
})

ItemHandlers::UseOnPokemon.add(:SASSYMINT, proc { |item, pkmn, scene|
  pbNatureChangingMint(:SASSY, item, pkmn, scene)
})

ItemHandlers::UseOnPokemon.add(:TIMIDMINT, proc { |item, pkmn, scene|
  pbNatureChangingMint(:TIMID, item, pkmn, scene)
})

ItemHandlers::UseOnPokemon.add(:HASTYMINT, proc { |item, pkmn, scene|
  pbNatureChangingMint(:HASTY, item, pkmn, scene)
})

ItemHandlers::UseOnPokemon.add(:JOLLYMINT, proc { |item, pkmn, scene|
  pbNatureChangingMint(:JOLLY, item, pkmn, scene)
})

ItemHandlers::UseOnPokemon.add(:NAIVEMINT, proc { |item, pkmn, scene|
  pbNatureChangingMint(:NAIVE, item, pkmn, scene)
})

ItemHandlers::UseOnPokemon.add(:SERIOUSMINT, proc { |item, pkmn, scene|
  pbNatureChangingMint(:SERIOUS, item, pkmn, scene)
})

ItemHandlers::UseOnPokemon.copy(:MAXREVIVE, :MAXHONEY)

ItemHandlers::CanUseInBattle.copy(:REVIVE, :MAXHONEY)

ItemHandlers::BattleUseOnPokemon.copy(:MAXREVIVE, :MAXHONEY)

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

ItemHandlers::BattleUseOnBattler.add(:MAXMUSHROOMS,proc { |item, battler, scene|
  battler.pbRaiseStatStage(:ATTACK, 1, battler) if battler.pbCanRaiseStatStage?(:ATTACK, battler)
  battler.pbRaiseStatStage(:DEFENSE, 1, battler) if battler.pbCanRaiseStatStage?(:DEFENSE, battler)
  battler.pbRaiseStatStage(:SPECIAL_ATTACK, 1, battler) if battler.pbCanRaiseStatStage?(:SPECIAL_ATTACK, battler)
  battler.pbRaiseStatStage(:SPECIAL_DEFENSE, 1, battler) if battler.pbCanRaiseStatStage?(:SPECIAL_DEFENSE, battler)
  battler.pbRaiseStatStage(:SPEED, 1, battler) if battler.pbCanRaiseStatStage?(:SPEED, battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::UseOnPokemon.add(:REINSOFUNITY, proc { |item, pkmn, scene|
  if !pkmn.isSpecies?(:CALYREX)
    scene.pbDisplay(_INTL("It had no effect."))
    next false
  elsif pkmn.fainted?
    scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
    next false
  end
  # Fusing
  if pkmn.fused.nil?
    chosen = scene.pbChoosePokemon(_INTL("Fuse with which Pokémon?"))
    next false if chosen < 0
    other_pkmn = $Trainer.party[chosen]
    if pkmn == other_pkmn
      scene.pbDisplay(_INTL("It cannot be fused with itself."))
      next false
    elsif other_pkmn.egg?
      scene.pbDisplay(_INTL("It cannot be fused with an Egg."))
      next false
    elsif other_pkmn.fainted?
      scene.pbDisplay(_INTL("It cannot be fused with that fainted Pokémon."))
      next false
    elsif !other_pkmn.isSpecies?(:GLASTRIER) &&
          !other_pkmn.isSpecies?(:SPECTRIER)
      scene.pbDisplay(_INTL("It cannot be fused with that Pokémon."))
      next false
    end
    newForm = 0
    newForm = 1 if other_pkmn.isSpecies?(:GLASTRIER)
    newForm = 2 if other_pkmn.isSpecies?(:SPECTRIER)
    pkmn.setForm(newForm) {
      pkmn.fused = other_pkmn
      $Trainer.remove_pokemon_at_index(chosen)
      scene.pbHardRefresh
      scene.pbDisplay(_INTL("{1} changed Forme!", pkmn.name))
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
    scene.pbDisplay(_INTL("{1} changed Forme!", pkmn.name))
  }
  next true
})

ItemHandlers::UseOnPokemon.add(:ABILITYPATCH, proc { |item, pkmn, scene|
  if scene.pbConfirm(_INTL("Do you want to change {1}'s Ability?", pkmn.name))
    abils = pkmn.getAbilityList
    new_ability_id = nil
    abils.each { |a| new_ability_id = a[0] if a[1] == 2 }
    if !new_ability_id || pkmn.hasHiddenAbility? || pkmn.isSpecies?(:ZYGARDE)
      scene.pbDisplay(_INTL("It won't have any effect."))
      next false
    end
    new_ability_name = GameData::Ability.get(new_ability_id).name
    pkmn.ability_index = 2
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1}'s Ability changed! Its Ability is now {2}!",
       pkmn.name, new_ability_name))
    next true
  end
  next false
})

ItemHandlers::UseOnPokemon.add(:ROTOMCATALOG, proc { |item, pkmn, scene|
  if !pkmn.isSpecies?(:ROTOM)
    scene.pbDisplay(_INTL("It had no effect."))
    next false
  elsif pkmn.fainted?
    scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
    next false
  end
  choices = [
    _INTL("Light bulb"),
    _INTL("Microwave oven"),
    _INTL("Washing machine"),
    _INTL("Refrigerator"),
    _INTL("Electric fan"),
    _INTL("Lawn mower"),
    _INTL("Cancel")
  ]
  new_form = scene.pbShowCommands(_INTL("Which appliance would you like to order?"),
     commands, pkmn.form)
  if new_form == pkmn.form
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  elsif new_form > 0 && new_form < choices.length - 1
    pkmn.setForm(new_form) {
      scene.pbRefresh
      scene.pbDisplay(_INTL("{1} transformed!", pkmn.name))
    }
    next true
  end
  next false
})

BattleHandlers::UserItemAfterMoveUse.add(:THROATSPRAY,
  proc { |item, user, targets, move, numHits, battle|
    next if battle.pbAllFainted?(user.idxOwnSide) ||
            battle.pbAllFainted?(user.idxOpposingSide)
    next if !move.soundMove? || numHits == 0
    next if !user.pbCanRaiseStatStage?(:SPECIAL_ATTACK, user)
    user.pbRaiseStatStage(:SPECIAL_ATTACK, 1, user)
    user.pbConsumeItem
  }
)


=begin

#===============================================================================

Eject Pack
When holder's stat(s) is lowered, consume item and holder switches out. Not
triggered by Parting Shot, or if a faster mon's Eject Button/Eject Pack
triggers.

Blunder Policy
If holder's move fails its accuracy check, consume item and holder gets +2
Speed. Doesn't trigger if move was an OHKO move, or Triple Kick that hit at
least once.

Room Service
If Trick Room is used, or if holder switches in while Trick Room applies,
consume item and holder gets -1 Speed.

Pokémon Box Link
Key item, unusable. Enables pressing a button while in the party screen to open
the "Organise Boxes" mode of Pokémon storage. This is disabled at certain times,
perhaps when a Game Switch is on.

Catching Charm
Increases the chance of a critical catch. By how much?

=end
