#===============================================================================
# User steals the target's item, if the user has none itself. (Covet, Thief)
# Items stolen from wild Pokémon are kept after the battle.
#===============================================================================
class Battle::Move::UserTakesTargetItem < Battle::Move
  def pbEffectAfterAllHits(user, target)
    return if user.wild?   # Wild Pokémon can't thieve
    return if user.fainted?
    return if target.damageState.unaffected || target.damageState.substitute
    return if !target.item || user.item
    return if target.unlosableItem?(target.item)
    return if user.unlosableItem?(target.item)
    return if target.hasActiveAbility?(:STICKYHOLD) && !@battle.moldBreaker
    itemName = target.itemName
    user.item = target.item
    # Permanently steal the item from wild Pokémon
    if target.wild? && !user.initialItem && target.item == target.initialItem
      user.setInitialItem(target.item)
      target.pbRemoveItem
    else
      target.pbRemoveItem(false)
    end
    @battle.pbDisplay(_INTL("{1} stole {2}'s {3}!", user.pbThis, target.pbThis(true), itemName))
    user.pbHeldItemTriggerCheck
  end
end

#===============================================================================
# User gives its item to the target. The item remains given after wild battles.
# (Bestow)
#===============================================================================
class Battle::Move::TargetTakesUserItem < Battle::Move
  def ignoresSubstitute?(user)
    return true if Settings::MECHANICS_GENERATION >= 6
    return super
  end

  def pbMoveFailed?(user, targets)
    if !user.item || user.unlosableItem?(user.item)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    if target.item || target.unlosableItem?(user.item)
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    itemName = user.itemName
    target.item = user.item
    # Permanently steal the item from wild Pokémon
    if user.wild? && !target.initialItem && user.item == user.initialItem
      target.setInitialItem(user.item)
      user.pbRemoveItem
    else
      user.pbRemoveItem(false)
    end
    @battle.pbDisplay(_INTL("{1} received {2} from {3}!", target.pbThis, itemName, user.pbThis(true)))
    target.pbHeldItemTriggerCheck
  end
end

#===============================================================================
# User and target swap items. They remain swapped after wild battles.
# (Switcheroo, Trick)
#===============================================================================
class Battle::Move::UserTargetSwapItems < Battle::Move
  def pbMoveFailed?(user, targets)
    if user.wild?
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    if !user.item && !target.item
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    if target.unlosableItem?(target.item) ||
       target.unlosableItem?(user.item) ||
       user.unlosableItem?(user.item) ||
       user.unlosableItem?(target.item)
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    if target.hasActiveAbility?(:STICKYHOLD) && !@battle.moldBreaker
      if show_message
        @battle.pbShowAbilitySplash(target)
        if Battle::Scene::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("But it failed to affect {1}!", target.pbThis(true)))
        else
          @battle.pbDisplay(_INTL("But it failed to affect {1} because of its {2}!",
                                  target.pbThis(true), target.abilityName))
        end
        @battle.pbHideAbilitySplash(target)
      end
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    oldUserItem = user.item
    oldUserItemName = user.itemName
    oldTargetItem = target.item
    oldTargetItemName = target.itemName
    user.item                             = oldTargetItem
    user.effects[PBEffects::ChoiceBand]   = nil if !user.hasActiveAbility?(:GORILLATACTICS)
    user.effects[PBEffects::Unburden]     = (!user.item && oldUserItem) if user.hasActiveAbility?(:UNBURDEN)
    target.item                           = oldUserItem
    target.effects[PBEffects::ChoiceBand] = nil if !target.hasActiveAbility?(:GORILLATACTICS)
    target.effects[PBEffects::Unburden]   = (!target.item && oldTargetItem) if target.hasActiveAbility?(:UNBURDEN)
    # Permanently steal the item from wild Pokémon
    if target.wild? && !user.initialItem && oldTargetItem == target.initialItem
      user.setInitialItem(oldTargetItem)
    end
    @battle.pbDisplay(_INTL("{1} switched items with its opponent!", user.pbThis))
    @battle.pbDisplay(_INTL("{1} obtained {2}.", user.pbThis, oldTargetItemName)) if oldTargetItem
    @battle.pbDisplay(_INTL("{1} obtained {2}.", target.pbThis, oldUserItemName)) if oldUserItem
    user.pbHeldItemTriggerCheck
    target.pbHeldItemTriggerCheck
  end
end

#===============================================================================
# User recovers the last item it held and consumed. (Recycle)
#===============================================================================
class Battle::Move::RestoreUserConsumedItem < Battle::Move
  def canSnatch?; return true; end

  def pbMoveFailed?(user, targets)
    if !user.recycleItem
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    item = user.recycleItem
    user.item = item
    user.setInitialItem(item) if @battle.wildBattle? && !user.initialItem
    user.setRecycleItem(nil)
    user.effects[PBEffects::PickupItem] = nil
    user.effects[PBEffects::PickupUse]  = 0
    itemName = GameData::Item.get(item).name
    if itemName.starts_with_vowel?
      @battle.pbDisplay(_INTL("{1} found an {2}!", user.pbThis, itemName))
    else
      @battle.pbDisplay(_INTL("{1} found a {2}!", user.pbThis, itemName))
    end
    user.pbHeldItemTriggerCheck
  end
end

#===============================================================================
# Target drops its item. It regains the item at the end of the battle. (Knock Off)
# If target has a losable item, damage is multiplied by 1.5.
#===============================================================================
class Battle::Move::RemoveTargetItem < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    if Settings::MECHANICS_GENERATION >= 6 &&
       target.item && !target.unlosableItem?(target.item)
       # NOTE: Damage is still boosted even if target has Sticky Hold or a
       #       substitute.
      baseDmg = (baseDmg * 1.5).round
    end
    return baseDmg
  end

  def pbEffectAfterAllHits(user, target)
    return if user.wild?   # Wild Pokémon can't knock off
    return if user.fainted?
    return if target.damageState.unaffected || target.damageState.substitute
    return if !target.item || target.unlosableItem?(target.item)
    return if target.hasActiveAbility?(:STICKYHOLD) && !@battle.moldBreaker
    itemName = target.itemName
    target.pbRemoveItem(false)
    @battle.pbDisplay(_INTL("{1} dropped its {2}!", target.pbThis, itemName))
  end
end

#===============================================================================
# Target's berry/Gem is destroyed. (Incinerate)
#===============================================================================
class Battle::Move::DestroyTargetBerryOrGem < Battle::Move
  def pbEffectWhenDealingDamage(user, target)
    return if target.damageState.substitute || target.damageState.berryWeakened
    return if !target.item || (!target.item.is_berry? &&
              !(Settings::MECHANICS_GENERATION >= 6 && target.item.is_gem?))
    item_name = target.itemName
    target.pbRemoveItem
    @battle.pbDisplay(_INTL("{1}'s {2} was incinerated!", target.pbThis, item_name))
  end
end

#===============================================================================
# Negates the effect and usability of the target's held item for the rest of the
# battle (even if it is switched out). Fails if the target doesn't have a held
# item, the item is unlosable, the target has Sticky Hold, or the target is
# behind a substitute. (Corrosive Gas)
#===============================================================================
class Battle::Move::CorrodeTargetItem < Battle::Move
  def canMagicCoat?; return true; end

  def pbFailsAgainstTarget?(user, target, show_message)
    if !target.item || target.unlosableItem?(target.item) ||
       target.effects[PBEffects::Substitute] > 0
      @battle.pbDisplay(_INTL("{1} is unaffected!", target.pbThis)) if show_message
      return true
    end
    if target.hasActiveAbility?(:STICKYHOLD) && !@battle.moldBreaker
      if show_message
        @battle.pbShowAbilitySplash(target)
        if Battle::Scene::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("{1} is unaffected!", target.pbThis))
        else
          @battle.pbDisplay(_INTL("{1} is unaffected because of its {2}!",
                                  target.pbThis(true), target.abilityName))
        end
        @battle.pbHideAbilitySplash(target)
      end
      return true
    end
    if @battle.corrosiveGas[target.index % 2][target.pokemonIndex]
      @battle.pbDisplay(_INTL("{1} is unaffected!", target.pbThis)) if show_message
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    @battle.corrosiveGas[target.index % 2][target.pokemonIndex] = true
    @battle.pbDisplay(_INTL("{1} corroded {2}'s {3}!",
                            user.pbThis, target.pbThis(true), target.itemName))
  end
end

#===============================================================================
# For 5 rounds, the target cannot use its held item, its held item has no
# effect, and no items can be used on it. (Embargo)
#===============================================================================
class Battle::Move::StartTargetCannotUseItem < Battle::Move
  def canMagicCoat?; return true; end

  def pbFailsAgainstTarget?(user, target, show_message)
    if target.effects[PBEffects::Embargo] > 0
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    target.effects[PBEffects::Embargo] = 5
    @battle.pbDisplay(_INTL("{1} can't use items anymore!", target.pbThis))
  end
end

#===============================================================================
# For 5 rounds, all held items cannot be used in any way and have no effect.
# Held items can still change hands, but can't be thrown. (Magic Room)
#===============================================================================
class Battle::Move::StartNegateHeldItems < Battle::Move
  def pbEffectGeneral(user)
    if @battle.field.effects[PBEffects::MagicRoom] > 0
      @battle.field.effects[PBEffects::MagicRoom] = 0
      @battle.pbDisplay(_INTL("The area returned to normal!"))
    else
      @battle.field.effects[PBEffects::MagicRoom] = 5
      @battle.pbDisplay(_INTL("It created a bizarre area in which Pokémon's held items lose their effects!"))
    end
  end

  def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    return if @battle.field.effects[PBEffects::MagicRoom] > 0   # No animation
    super
  end
end

#===============================================================================
# The user consumes its held berry and gains its effect. Also, increases the
# user's Defense by 2 stages. The berry can be consumed even if Unnerve/Magic
# Room apply. Fails if the user is not holding a berry. This move cannot be
# chosen to be used if the user is not holding a berry. (Stuff Cheeks)
#===============================================================================
class Battle::Move::UserConsumeBerryRaiseDefense2 < Battle::Move::StatUpMove
  def initialize(battle, move)
    super
    @statUp = [:DEFENSE, 2]
  end

  def pbCanChooseMove?(user, commandPhase, showMessages)
    item = user.item
    if !item || !item.is_berry? || !user.itemActive?
      if showMessages
        msg = _INTL("{1} can't use that move because it doesn't have a Berry!", user.pbThis)
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false
    end
    return true
  end

  def pbMoveFailed?(user, targets)
    # NOTE: Unnerve does not stop a Pokémon using this move.
    item = user.item
    if !item || !item.is_berry? || !user.itemActive?
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return super
  end

  def pbEffectGeneral(user)
    super
    @battle.pbDisplay(_INTL("{1} ate its {2}!", user.pbThis, user.itemName))
    item = user.item
    user.pbConsumeItem(true, false)   # Don't trigger Symbiosis yet
    user.pbHeldItemTriggerCheck(item, false)
  end
end

#===============================================================================
# All Pokémon (except semi-invulnerable ones) consume their held berries and
# gain their effects. Berries can be consumed even if Unnerve/Magic Room apply.
# Fails if no Pokémon have a held berry. If this move would trigger an ability
# that negates the move, e.g. Lightning Rod, the bearer of that ability will
# have their ability triggered regardless of whether they are holding a berry,
# and they will not consume their berry. (Teatime)
# TODO: This isn't quite right for the messages shown when a berry is consumed.
#===============================================================================
class Battle::Move::AllBattlersConsumeBerry < Battle::Move
  def pbMoveFailed?(user, targets)
    failed = true
    targets.each do |b|
      next if !b.item || !b.item.is_berry?
      next if b.semiInvulnerable?
      failed = false
      break
    end
    if failed
      @battle.pbDisplay(_INTL("But nothing happened!"))
      return true
    end
    return false
  end

  def pbOnStartUse(user, targets)
    @battle.pbDisplay(_INTL("It's teatime! Everyone dug in to their Berries!"))
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    return true if !target.item || !target.item.is_berry? || target.semiInvulnerable?
    return false
  end

  def pbEffectAgainstTarget(user, target)
    @battle.pbCommonAnimation("EatBerry", target)
    item = target.item
    target.pbConsumeItem(true, false)   # Don't trigger Symbiosis yet
    target.pbHeldItemTriggerCheck(item, false)
  end
end

#===============================================================================
# User consumes target's berry and gains its effect. (Bug Bite, Pluck)
#===============================================================================
class Battle::Move::UserConsumeTargetBerry < Battle::Move
  def pbEffectAfterAllHits(user, target)
    return if user.fainted? || target.fainted?
    return if target.damageState.unaffected || target.damageState.substitute
    return if !target.item || !target.item.is_berry?
    return if target.hasActiveAbility?(:STICKYHOLD) && !@battle.moldBreaker
    item = target.item
    itemName = target.itemName
    target.pbRemoveItem
    @battle.pbDisplay(_INTL("{1} stole and ate its target's {2}!", user.pbThis, itemName))
    user.pbHeldItemTriggerCheck(item, false)
  end
end

#===============================================================================
# User flings its item at the target. Power/effect depend on the item. (Fling)
#===============================================================================
class Battle::Move::ThrowUserItemAtTarget < Battle::Move
  def pbCheckFlingSuccess(user)
    @willFail = false
    @willFail = true if !user.item || !user.itemActive? || user.unlosableItem?(user.item)
    return if @willFail
    @willFail = true if user.item.is_berry? && !user.canConsumeBerry?
    return if @willFail
    @willFail = user.item.flags.none? { |f| f[/^Fling_/i] }
  end

  def pbMoveFailed?(user, targets)
    if @willFail
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbDisplayUseMessage(user)
    super
    pbCheckFlingSuccess(user)
    if !@willFail
      @battle.pbDisplay(_INTL("{1} flung its {2}!", user.pbThis, user.itemName))
    end
  end

  def pbNumHits(user, targets); return 1; end

  def pbBaseDamage(baseDmg, user, target)
    return 0 if !user.item
    user.item.flags.each do |flag|
      return [$~[1].to_i, 10].max if flag[/^Fling_(\d+)$/i]
    end
    return 10
  end

  def pbEffectAgainstTarget(user, target)
    return if target.damageState.substitute
    return if target.hasActiveAbility?(:SHIELDDUST) && !@battle.moldBreaker
    case user.item_id
    when :POISONBARB
      target.pbPoison(user) if target.pbCanPoison?(user, false, self)
    when :TOXICORB
      target.pbPoison(user, nil, true) if target.pbCanPoison?(user, false, self)
    when :FLAMEORB
      target.pbBurn(user) if target.pbCanBurn?(user, false, self)
    when :LIGHTBALL
      target.pbParalyze(user) if target.pbCanParalyze?(user, false, self)
    when :KINGSROCK, :RAZORFANG
      target.pbFlinch(user)
    else
      target.pbHeldItemTriggerCheck(user.item, true)
    end
  end

  def pbEndOfMoveUsageEffect(user, targets, numHits, switchedBattlers)
    # NOTE: The item is consumed even if this move was Protected against or it
    #       missed. The item is not consumed if the target was switched out by
    #       an effect like a target's Red Card.
    # NOTE: There is no item consumption animation.
    user.pbConsumeItem(true, true, false) if user.item
  end
end
