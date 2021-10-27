class PokeBattle_Battler
  #=============================================================================
  # Ability effects
  #=============================================================================
  def pbAbilitiesOnSwitchOut
    if abilityActive?
      BattleHandlers.triggerAbilityOnSwitchOut(self.ability,self,false)
    end
    # Reset form
    @battle.peer.pbOnLeavingBattle(@battle,@pokemon,@battle.usedInBattle[idxOwnSide][@index/2])
    # Treat self as fainted
    @hp = 0
    @fainted = true
    # Check for end of Neutralizing Gas/Unnerve
    pbAbilitiesOnNeutralizingGasEnding if hasActiveAbility?(:NEUTRALIZINGGAS, true)
    pbItemsOnUnnerveEnding if hasActiveAbility?(:UNNERVE, true)
    # Check for end of primordial weather
    @battle.pbEndPrimordialWeather
  end

  def pbAbilitiesOnFainting
    # Self fainted; check all other battlers to see if their abilities trigger
    @battle.pbPriority(true).each do |b|
      next if !b || !b.abilityActive?
      BattleHandlers.triggerAbilityChangeOnBattlerFainting(b.ability,b,self,@battle)
    end
    @battle.pbPriority(true).each do |b|
      next if !b || !b.abilityActive?
      BattleHandlers.triggerAbilityOnBattlerFainting(b.ability,b,self,@battle)
    end
    pbAbilitiesOnNeutralizingGasEnding if hasActiveAbility?(:NEUTRALIZINGGAS, true)
    pbItemsOnUnnerveEnding if hasActiveAbility?(:UNNERVE, true)
  end

  # Used for Emergency Exit/Wimp Out. Returns whether self has switched out.
  def pbAbilitiesOnDamageTaken(move_user = nil)
    return false if !@droppedBelowHalfHP
    return false if !abilityActive?
    return BattleHandlers.triggerAbilityOnHPDroppedBelowHalf(self.ability, self, move_user, @battle)
  end

  def pbAbilityOnTerrainChange(ability_changed = false)
    return if !abilityActive?
    BattleHandlers.triggerAbilityOnTerrainChange(self.ability, self, @battle, ability_changed)
  end

  # Used for Rattled's Gen 8 effect. Called when Intimidate is triggered.
  def pbAbilitiesOnIntimidated
    return if !abilityActive?
    BattleHandlers.triggerAbilityOnIntimidated(self.ability, self, @battle)
  end

  def pbAbilitiesOnNeutralizingGasEnding
    return if @battle.pbCheckGlobalAbility(:NEUTRALIZINGGAS)
    @battle.pbDisplay(_INTL("The effects of the neutralizing gas wore off!"))
    @battle.pbEndPrimordialWeather
    @battle.pbPriority(true).each do |b|
      next if b.fainted?
      next if !b.unstoppableAbility? && !b.abilityActive?
      BattleHandlers.triggerAbilityOnSwitchIn(b.ability, b, @battle)
    end
  end

  # Called when a Pokémon (self) enters battle, at the end of each move used,
  # and at the end of each round.
  def pbContinualAbilityChecks(onSwitchIn=false)
    # Check for end of primordial weather
    @battle.pbEndPrimordialWeather
    # Trace
    if hasActiveAbility?(:TRACE)
      # NOTE: In Gen 5 only, Trace only triggers upon the Trace bearer switching
      #       in and not at any later times, even if a traceable ability turns
      #       up later. Essentials ignores this, and allows Trace to trigger
      #       whenever it can even in the old battle mechanics.
      choices = []
      choices = @battle.allOtherSideBattlers(@index).select { |b|
        next !b.ungainableAbility? &&
             ![:POWEROFALCHEMY, :RECEIVER, :TRACE].include?(b.ability_id)
      }
      if choices.length>0
        choice = choices[@battle.pbRandom(choices.length)]
        @battle.pbShowAbilitySplash(self)
        self.ability = choice.ability
        @battle.pbDisplay(_INTL("{1} traced {2}'s {3}!",pbThis,choice.pbThis(true),choice.abilityName))
        @battle.pbHideAbilitySplash(self)
        if !onSwitchIn && (unstoppableAbility? || abilityActive?)
          BattleHandlers.triggerAbilityOnSwitchIn(self.ability,self,@battle)
        end
      end
    end
  end

  #=============================================================================
  # Ability curing
  #=============================================================================
  # Cures status conditions, confusion and infatuation.
  def pbAbilityStatusCureCheck
    if abilityActive?
      BattleHandlers.triggerStatusCureAbility(self.ability,self)
    end
  end

  #=============================================================================
  # Ability change
  #=============================================================================
  def pbOnLosingAbility(oldAbil, suppressed = false)
    if oldAbil == :NEUTRALIZINGGAS && (suppressed || !@effects[PBEffects::GastroAcid])
      pbAbilitiesOnNeutralizingGasEnding
    elsif oldAbil == :UNNERVE && (suppressed || !@effects[PBEffects::GastroAcid])
      pbItemsOnUnnerveEnding
    elsif oldAbil == :ILLUSION && @effects[PBEffects::Illusion]
      @effects[PBEffects::Illusion] = nil
      if !@effects[PBEffects::Transform]
        @battle.scene.pbChangePokemon(self, @pokemon)
        @battle.pbDisplay(_INTL("{1}'s {2} wore off!", pbThis, GameData::Ability.get(oldAbil).name))
        @battle.pbSetSeen(self)
      end
    end
    @effects[PBEffects::GastroAcid] = false if unstoppableAbility?
    @effects[PBEffects::SlowStart]  = 0 if self.ability != :SLOWSTART
    @effects[PBEffects::Truant]     = false if self.ability != :TRUANT
    # Check for end of primordial weather
    @battle.pbEndPrimordialWeather
    # Revert form if Flower Gift/Forecast was lost
    pbCheckFormOnWeatherChange(true)
    # Abilities that trigger when the terrain changes
    pbAbilityOnTerrainChange(true)
  end

  def pbTriggerAbilityOnGainingIt
    # Ending primordial weather, checking Trace
    pbContinualAbilityChecks(true)   # Don't trigger Traced ability as it's triggered below
    # Abilities that trigger upon switching in
    if (!fainted? && unstoppableAbility?) || abilityActive?
      BattleHandlers.triggerAbilityOnSwitchIn(self.ability, self, @battle)
    end
    # Status-curing ability check
    pbAbilityStatusCureCheck
    # Check for end of primordial weather
    @battle.pbEndPrimordialWeather
  end

  #=============================================================================
  # Held item consuming/removing
  #=============================================================================
  def canConsumeBerry?
    return false if @battle.pbCheckOpposingAbility(:UNNERVE, @index)
    return true
  end

  def canConsumePinchBerry?(check_gluttony = true)
    return false if !canConsumeBerry?
    return true if @hp <= @totalhp / 4
    return true if @hp <= @totalhp / 2 && (!check_gluttony || hasActiveAbility?(:GLUTTONY))
    return false
  end

  # permanent is whether the item is lost even after battle. Is false for Knock
  # Off.
  def pbRemoveItem(permanent = true)
    @effects[PBEffects::ChoiceBand] = nil if !hasActiveAbility?(:GORILLATACTICS)
    @effects[PBEffects::Unburden]   = true if self.item && hasActiveAbility?(:UNBURDEN)
    setInitialItem(nil) if permanent && self.item == self.initialItem
    self.item = nil
  end

  def pbConsumeItem(recoverable=true,symbiosis=true,belch=true)
    PBDebug.log("[Item consumed] #{pbThis} consumed its held #{itemName}")
    if recoverable
      setRecycleItem(@item_id)
      @effects[PBEffects::PickupItem] = @item_id
      @effects[PBEffects::PickupUse]  = @battle.nextPickupUse
    end
    setBelched if belch && self.item.is_berry?
    pbRemoveItem
    pbSymbiosis if symbiosis
  end

  def pbSymbiosis
    return if fainted?
    return if self.item
    @battle.pbPriority(true).each do |b|
      next if b.opposes?
      next if !b.hasActiveAbility?(:SYMBIOSIS)
      next if !b.item || b.unlosableItem?(b.item)
      next if unlosableItem?(b.item)
      @battle.pbShowAbilitySplash(b)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        @battle.pbDisplay(_INTL("{1} shared its {2} with {3}!",
           b.pbThis,b.itemName,pbThis(true)))
      else
        @battle.pbDisplay(_INTL("{1}'s {2} let it share its {3} with {4}!",
           b.pbThis,b.abilityName,b.itemName,pbThis(true)))
      end
      self.item = b.item
      b.item = nil
      b.effects[PBEffects::Unburden] = true if b.hasActiveAbility?(:UNBURDEN)
      @battle.pbHideAbilitySplash(b)
      pbHeldItemTriggerCheck
      break
    end
  end

  # item_to_use is an item ID or GameData::Item object. own_item is whether the
  # item is held by self. fling is for Fling only.
  def pbHeldItemTriggered(item_to_use, own_item = true, fling = false)
    # Cheek Pouch
    if hasActiveAbility?(:CHEEKPOUCH) && GameData::Item.get(item_to_use).is_berry? && canHeal?
      @battle.pbShowAbilitySplash(self)
      pbRecoverHP(@totalhp / 3)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        @battle.pbDisplay(_INTL("{1}'s HP was restored.", pbThis))
      else
        @battle.pbDisplay(_INTL("{1}'s {2} restored its HP.", pbThis, abilityName))
      end
      @battle.pbHideAbilitySplash(self)
    end
    pbConsumeItem if own_item
    pbSymbiosis if !own_item && !fling   # Bug Bite/Pluck users trigger Symbiosis
  end

  #=============================================================================
  # Held item trigger checks
  #=============================================================================
  # NOTE: A Pokémon using Bug Bite/Pluck, and a Pokémon having an item thrown at
  #       it via Fling, will gain the effect of the item even if the Pokémon is
  #       affected by item-negating effects.
  # item_to_use is an item ID for Bug Bite/Pluck and Fling, and nil otherwise.
  # fling is for Fling only.
  def pbHeldItemTriggerCheck(item_to_use = nil, fling = false)
    return if fainted?
    return if !item_to_use && !itemActive?
    pbItemHPHealCheck(item_to_use, fling)
    pbItemStatusCureCheck(item_to_use, fling)
    pbItemEndOfMoveCheck(item_to_use, fling)
    # For Enigma Berry, Kee Berry and Maranga Berry, which have their effects
    # when forcibly consumed by Pluck/Fling.
    if item_to_use
      itm = item_to_use || self.item
      if BattleHandlers.triggerTargetItemOnHitPositiveBerry(itm, self, @battle, true)
        pbHeldItemTriggered(itm, false, fling)
      end
    end
  end

  # item_to_use is an item ID for Bug Bite/Pluck and Fling, and nil otherwise.
  # fling is for Fling only.
  def pbItemHPHealCheck(item_to_use = nil, fling = false)
    return if !item_to_use && !itemActive?
    itm = item_to_use || self.item
    if BattleHandlers.triggerHPHealItem(itm, self, @battle, !item_to_use.nil?)
      pbHeldItemTriggered(itm, item_to_use.nil?, fling)
    elsif !item_to_use
      pbItemTerrainStatBoostCheck
    end
  end

  # Cures status conditions, confusion, infatuation and the other effects cured
  # by Mental Herb.
  # item_to_use is an item ID for Bug Bite/Pluck and Fling, and nil otherwise.
  # fling is for Fling only.
  def pbItemStatusCureCheck(item_to_use = nil, fling = false)
    return if fainted?
    return if !item_to_use && !itemActive?
    itm = item_to_use || self.item
    if BattleHandlers.triggerStatusCureItem(itm, self, @battle, !item_to_use.nil?)
      pbHeldItemTriggered(itm, item_to_use.nil?, fling)
    end
  end

  # Called at the end of using a move.
  # item_to_use is an item ID for Bug Bite/Pluck and Fling, and nil otherwise.
  # fling is for Fling only.
  def pbItemEndOfMoveCheck(item_to_use = nil, fling = false)
    return if fainted?
    return if !item_to_use && !itemActive?
    itm = item_to_use || self.item
    if BattleHandlers.triggerEndOfMoveItem(itm, self, @battle, !item_to_use.nil?)
      pbHeldItemTriggered(itm, item_to_use.nil?, fling)
    elsif BattleHandlers.triggerEndOfMoveStatRestoreItem(itm, self, @battle, !item_to_use.nil?)
      pbHeldItemTriggered(itm, item_to_use.nil?, fling)
    end
  end

  # Used for White Herb (restore lowered stats). Only called by Moody and Sticky
  # Web, as all other stat reduction happens because of/during move usage and
  # this handler is also called at the end of each move's usage.
  # item_to_use is an item ID for Bug Bite/Pluck and Fling, and nil otherwise.
  # fling is for Fling only.
  def pbItemStatRestoreCheck(item_to_use = nil, fling = false)
    return if fainted?
    return if !item_to_use && !itemActive?
    itm = item_to_use || self.item
    if BattleHandlers.triggerEndOfMoveStatRestoreItem(itm, self, @battle, !item_to_use.nil?)
      pbHeldItemTriggered(itm, item_to_use.nil?, fling)
    end
  end

  # Called when the battle terrain changes and when a Pokémon loses HP.
  def pbItemTerrainStatBoostCheck
    return if !itemActive?
    if BattleHandlers.triggerTerrainStatBoostItem(self.item, self, @battle)
      pbHeldItemTriggered(self.item)
    end
  end

  # Used for Adrenaline Orb. Called when Intimidate is triggered (even if
  # Intimidate has no effect on the Pokémon).
  def pbItemOnIntimidatedCheck
    return if !itemActive?
    if BattleHandlers.triggerItemOnIntimidated(self.item, self, @battle)
      pbHeldItemTriggered(self.item)
    end
  end

  # Used for Eject Pack. Returns whether self has switched out.
  def pbItemOnStatDropped(move_user = nil)
    return false if !@statsDropped
    return false if !itemActive?
    return BattleHandlers.triggerItemOnStatDropped(self.item, self, move_user, @battle)
  end

  def pbItemsOnUnnerveEnding
    @battle.pbPriority(true).each do |b|
      b.pbHeldItemTriggerCheck if b.item && b.item.is_berry?
    end
  end
end
