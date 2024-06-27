#===============================================================================
#
#===============================================================================
class Battle
  #-----------------------------------------------------------------------------
  # Choosing to use an item.
  #-----------------------------------------------------------------------------

  def pbCanUseItemOnPokemon?(item, pkmn, battler, scene, showMessages = true)
    if !pkmn || pkmn.egg?
      scene.pbDisplay(_INTL("It won't have any effect.")) if showMessages
      return false
    end
    # Embargo
    if battler && battler.effects[PBEffects::Embargo] > 0
      if showMessages
        scene.pbDisplay(_INTL("Embargo's effect prevents the item's use on {1}!",
                              battler.pbThis(true)))
      end
      return false
    end
    # Hyper Mode and non-Scents
    if pkmn.hyper_mode && !GameData::Item.get(item)&.is_scent?
      scene.pbDisplay(_INTL("It won't have any effect.")) if showMessages
      return false
    end
    return true
  end

  # NOTE: Using a Poké Ball consumes all your actions for the round. The method
  #       below is one half of making this happen; the other half is in the
  #       ItemHandlers::CanUseInBattle for Poké Balls.
  def pbItemUsesAllActions?(item)
    return true if GameData::Item.get(item).is_poke_ball?
    return false
  end

  def pbRegisterItem(idxBattler, item, idxTarget = nil, idxMove = nil)
    # Register for use of item on a Pokémon in the party
    @choices[idxBattler][0] = :UseItem
    @choices[idxBattler][1] = item        # ID of item to be used
    @choices[idxBattler][2] = idxTarget   # Party index of Pokémon to use item on
    @choices[idxBattler][3] = idxMove     # Index of move to recharge (Ethers)
    # Delete the item from the Bag. If it turns out it will have no effect, it
    # will be re-added to the Bag later.
    pbConsumeItemInBag(item, idxBattler)
    return true
  end

  #-----------------------------------------------------------------------------
  # Using an item.
  #-----------------------------------------------------------------------------

  def pbConsumeItemInBag(item, idxBattler)
    return if !item
    return if !GameData::Item.get(item).consumed_after_use?
    if pbOwnedByPlayer?(idxBattler)
      if !$bag.remove(item)
        raise _INTL("Tried to consume item that wasn't in the Bag somehow.")
      end
    else
      items = pbGetOwnerItems(idxBattler)
      items.delete_at(items.index(item)) if items
    end
  end

  def pbReturnUnusedItemToBag(item, idxBattler)
    return if !item
    return if !GameData::Item.get(item).consumed_after_use?
    if pbOwnedByPlayer?(idxBattler)
      if $bag&.can_add?(item)
        $bag.add(item)
      else
        raise _INTL("Couldn't return unused item to Bag somehow.")
      end
    else
      items = pbGetOwnerItems(idxBattler)
      items&.push(item)
    end
  end

  def pbUseItemMessage(item, trainerName)
    itemName = GameData::Item.get(item).portion_name
    if itemName.starts_with_vowel?
      pbDisplayBrief(_INTL("{1} used an {2}.", trainerName, itemName))
    else
      pbDisplayBrief(_INTL("{1} used a {2}.", trainerName, itemName))
    end
  end

  # Uses an item on a Pokémon in the trainer's party.
  def pbUseItemOnPokemon(item, idxParty, userBattler)
    trainerName = pbGetOwnerName(userBattler.index)
    pbUseItemMessage(item, trainerName)
    pkmn = pbParty(userBattler.index)[idxParty]
    battler = pbFindBattler(idxParty, userBattler.index)
    ch = @choices[userBattler.index]
    if ItemHandlers.triggerCanUseInBattle(item, pkmn, battler, ch[3], true, self, @scene, false)
      ItemHandlers.triggerBattleUseOnPokemon(item, pkmn, battler, ch, @scene)
      ch[1] = nil   # Delete item from choice
      return
    end
    pbDisplay(_INTL("But it had no effect!"))
    # Return unused item to Bag
    pbReturnUnusedItemToBag(item, userBattler.index)
  end

  # Uses an item on a Pokémon in battle that belongs to the trainer.
  def pbUseItemOnBattler(item, idxParty, userBattler)
    trainerName = pbGetOwnerName(userBattler.index)
    pbUseItemMessage(item, trainerName)
    battler = pbFindBattler(idxParty, userBattler.index)
    ch = @choices[userBattler.index]
    if battler
      if ItemHandlers.triggerCanUseInBattle(item, battler.pokemon, battler, ch[3], true, self, @scene, false)
        ItemHandlers.triggerBattleUseOnBattler(item, battler, @scene)
        ch[1] = nil   # Delete item from choice
        battler.pbItemOnStatDropped
        return
      else
        pbDisplay(_INTL("But it had no effect!"))
      end
    else
      pbDisplay(_INTL("But it's not where this item can be used!"))
    end
    # Return unused item to Bag
    pbReturnUnusedItemToBag(item, userBattler.index)
  end

  # Uses a Poké Ball in battle directly.
  def pbUsePokeBallInBattle(item, idxBattler, userBattler)
    idxBattler = userBattler.index if idxBattler < 0
    battler = @battlers[idxBattler]
    ItemHandlers.triggerUseInBattle(item, battler, self)
    @choices[userBattler.index][1] = nil   # Delete item from choice
  end

  # Uses an item in battle directly.
  def pbUseItemInBattle(item, idxBattler, userBattler)
    trainerName = pbGetOwnerName(userBattler.index)
    pbUseItemMessage(item, trainerName)
    battler = (idxBattler < 0) ? userBattler : @battlers[idxBattler]
    pkmn = battler.pokemon
    ch = @choices[userBattler.index]
    if ItemHandlers.triggerCanUseInBattle(item, pkmn, battler, ch[3], true, self, @scene, false)
      ItemHandlers.triggerUseInBattle(item, battler, self)
      ch[1] = nil   # Delete item from choice
      return
    end
    pbDisplay(_INTL("But it had no effect!"))
    # Return unused item to Bag
    pbReturnUnusedItemToBag(item, userBattler.index)
  end
end
