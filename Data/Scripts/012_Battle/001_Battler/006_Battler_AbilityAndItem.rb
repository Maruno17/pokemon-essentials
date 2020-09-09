class PokeBattle_Battler
  #=============================================================================
  # Called when a Pokémon (self) is sent into battle or its ability changes.
  #=============================================================================
  def pbEffectsOnSwitchIn(switchIn=false)
    # Healing Wish/Lunar Dance/entry hazards
    @battle.pbOnActiveOne(self) if switchIn
    # Primal Revert upon entering battle
    @battle.pbPrimalReversion(@index) if !fainted?
    # Ending primordial weather, checking Trace
    pbContinualAbilityChecks(true)
    # Abilities that trigger upon switching in
    if (!fainted? && nonNegatableAbility?) || abilityActive?
      BattleHandlers.triggerAbilityOnSwitchIn(@ability,self,@battle)
    end
    # Check for end of primordial weather
    @battle.pbEndPrimordialWeather
    # Items that trigger upon switching in (Air Balloon message)
    if switchIn && itemActive?
      BattleHandlers.triggerItemOnSwitchIn(@item,self,@battle)
    end
    # Berry check, status-curing ability check
    pbHeldItemTriggerCheck if switchIn
    pbAbilityStatusCureCheck
  end

  #=============================================================================
  # Ability effects
  #=============================================================================
  def pbAbilitiesOnSwitchOut
    if abilityActive?
      BattleHandlers.triggerAbilityOnSwitchOut(@ability,self,false)
    end
    # Reset form
    @battle.peer.pbOnLeavingBattle(@battle,@pokemon,@battle.usedInBattle[idxOwnSide][@index/2])
    # Treat self as fainted
    @hp = 0
    @fainted = true
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
  end

  # Used for Emergency Exit/Wimp Out.
  def pbAbilitiesOnDamageTaken(oldHP,newHP=-1)
    return false if !abilityActive?
    newHP = @hp if newHP<0
    return false if oldHP<@totalhp/2 || newHP>=@totalhp/2   # Didn't drop below half
    ret = BattleHandlers.triggerAbilityOnHPDroppedBelowHalf(@ability,self,@battle)
    return ret   # Whether self has switched out
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
      abilityBlacklist = [
         # Replaces self with another ability
         :POWEROFALCHEMY,
         :RECEIVER,
         :TRACE,
         # Form-changing abilities
         :BATTLEBOND,
         :DISGUISE,
         :FLOWERGIFT,
         :FORECAST,
         :MULTITYPE,
         :POWERCONSTRUCT,
         :SCHOOLING,
         :SHIELDSDOWN,
         :STANCECHANGE,
         :ZENMODE,
         :ICEFACE,
         # Appearance-changing abilities
         :ILLUSION,
         :IMPOSTER,
         # Abilities intended to be inherent properties of a certain species
         :COMATOSE,
         :RKSSYSTEM,
         :GULPMISSILE,
         # Abilities that are plain old blocked.
         :NEUTRALIZINGGAS
      ]
      choices = []
      @battle.eachOtherSideBattler(@index) do |b|
        abilityBlacklist.each do |abil|
          next if !isConst?(b.ability,PBAbilities,abil)
          choices.push(b)
          break
        end
      end
      if choices.length>0
        choice = choices[@battle.pbRandom(choices.length)]
        @battle.pbShowAbilitySplash(self)
        @ability = choice.ability
        @battle.pbDisplay(_INTL("{1} traced {2}'s {3}!",pbThis,choice.pbThis(true),choice.abilityName))
        @battle.pbHideAbilitySplash(self)
        if !onSwitchIn && (nonNegatableAbility? || abilityActive?)
          BattleHandlers.triggerAbilityOnSwitchIn(@ability,self,@battle)
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
      BattleHandlers.triggerStatusCureAbility(@ability,self)
    end
  end

  #=============================================================================
  # Ability change
  #=============================================================================
  def pbOnAbilityChanged(oldAbil)
    if @effects[PBEffects::Illusion] && isConst?(oldAbil,PBAbilities,:ILLUSION)
      @effects[PBEffects::Illusion] = nil
      if !@effects[PBEffects::Transform]
        @battle.scene.pbChangePokemon(self,@pokemon)
        @battle.pbDisplay(_INTL("{1}'s {2} wore off!",pbThis,PBAbilities.getName(oldAbil)))
        @battle.pbSetSeen(self)
      end
    end
    @effects[PBEffects::GastroAcid] = false if nonNegatableAbility?
    @effects[PBEffects::SlowStart]  = 0 if !isConst?(@ability,PBAbilities,:SLOWSTART)
    # Revert form if Flower Gift/Forecast was lost
    pbCheckFormOnWeatherChange
    # Check for end of primordial weather
    @battle.pbEndPrimordialWeather
  end

  #=============================================================================
  # Held item consuming/removing
  #=============================================================================
  def pbCanConsumeBerry?(_item,alwaysCheckGluttony=true)
    return false if @battle.pbCheckOpposingAbility(:UNNERVE,@index)
    return true if @hp<=@totalhp/4
    if alwaysCheckGluttony || NEWEST_BATTLE_MECHANICS
      return true if @hp<=@totalhp/2 && hasActiveAbility?(:GLUTTONY)
    end
    return false
  end

  # permanent is whether the item is lost even after battle. Is false for Knock
  # Off.
  def pbRemoveItem(permanent=true)
    @effects[PBEffects::ChoiceBand] = -1
    @effects[PBEffects::Unburden]   = true if @item>0
    setInitialItem(0) if self.initialItem==@item && permanent
    self.item = 0
  end

  def pbConsumeItem(recoverable=true,symbiosis=true,belch=true)
    PBDebug.log("[Item consumed] #{pbThis} consumed its held #{PBItems.getName(@item)}")
    if recoverable
      setRecycleItem(@item)
      @effects[PBEffects::PickupItem] = @item
      @effects[PBEffects::PickupUse]  = @battle.nextPickupUse
    end
    setBelched if belch && pbIsBerry?(@item)
    pbRemoveItem
    pbSymbiosis if symbiosis
  end

  def pbSymbiosis
    return if fainted?
    return if @item!=0
    @battle.pbPriority(true).each do |b|
      next if b.opposes?
      next if !b.hasActiveAbility?(:SYMBIOSIS)
      next if b.item==0 || b.unlosableItem?(b.item)
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
      b.item = 0
      b.effects[PBEffects::Unburden] = true
      @battle.pbHideAbilitySplash(b)
      pbHeldItemTriggerCheck
      break
    end
  end

  def pbHeldItemTriggered(thisItem,forcedItem=0,fling=false)
    # Cheek Pouch
    if hasActiveAbility?(:CHEEKPOUCH) && pbIsBerry?(thisItem) && canHeal?
      @battle.pbShowAbilitySplash(self)
      pbRecoverHP(@totalhp/3)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        @battle.pbDisplay(_INTL("{1}'s HP was restored.",pbThis))
      else
        @battle.pbDisplay(_INTL("{1}'s {2} restored its HP.",pbThis,abilityName))
      end
      @battle.pbHideAbilitySplash(self)
    end
    pbConsumeItem if forcedItem<=0
    pbSymbiosis if forcedItem>0 && !fling   # Bug Bite/Pluck users trigger Symbiosis
  end

  #=============================================================================
  # Held item trigger checks
  #=============================================================================
  # NOTE: A Pokémon using Bug Bite/Pluck, and a Pokémon having an item thrown at
  #       it via Fling, will gain the effect of the item even if the Pokémon is
  #       affected by item-negating effects.
  # If forcedItem is -1, the Pokémon's held item is forced to be consumed. If it
  # is greater than 0, a different item (of that ID) is forced to be consumed
  # (not the Pokémon's held one).
  def pbHeldItemTriggerCheck(forcedItem=0,fling=false)
    return if fainted?
    return if forcedItem==0 && !itemActive?
    pbItemHPHealCheck(forcedItem,fling)
    pbItemStatusCureCheck(forcedItem,fling)
    pbItemEndOfMoveCheck(forcedItem,fling)
    # For Enigma Berry, Kee Berry and Maranga Berry, which have their effects
    # when forcibly consumed by Pluck/Fling.
    if forcedItem!=0
      thisItem = (forcedItem>0) ? forcedItem : @item
      if BattleHandlers.triggerTargetItemOnHitPositiveBerry(thisItem,self,@battle,true)
        pbHeldItemTriggered(thisItem,forcedItem,fling)
      end
    end
  end

  # forcedItem is an item ID for Bug Bite/Pluck/Fling, and 0 otherwise.
  # fling is for Fling only.
  def pbItemHPHealCheck(forcedItem=0,fling=false)
    return if forcedItem==0 && !itemActive?
    thisItem = (forcedItem>0) ? forcedItem : @item
    if BattleHandlers.triggerHPHealItem(thisItem,self,@battle,(forcedItem!=0))
      pbHeldItemTriggered(thisItem,forcedItem,fling)
    elsif forcedItem==0
      pbItemTerrainStatBoostCheck
    end
  end

  # Cures status conditions, confusion, infatuation and the other effects cured
  # by Mental Herb.
  # forcedItem is an item ID for Pluck/Fling, and 0 otherwise. fling is for
  # Fling only.
  def pbItemStatusCureCheck(forcedItem=0,fling=false)
    return if fainted?
    return if forcedItem==0 && !itemActive?
    thisItem = (forcedItem>0) ? forcedItem : @item
    if BattleHandlers.triggerStatusCureItem(thisItem,self,@battle,(forcedItem!=0))
      pbHeldItemTriggered(thisItem,forcedItem,fling)
    end
  end

  # Called at the end of using a move.
  # forcedItem is an item ID for Pluck/Fling, and 0 otherwise. fling is for
  # Fling only.
  def pbItemEndOfMoveCheck(forcedItem=0,fling=false)
    return if fainted?
    return if forcedItem==0 && !itemActive?
    thisItem = (forcedItem>0) ? forcedItem : @item
    if BattleHandlers.triggerEndOfMoveItem(thisItem,self,@battle,(forcedItem!=0))
      pbHeldItemTriggered(thisItem,forcedItem,fling)
    elsif BattleHandlers.triggerEndOfMoveStatRestoreItem(thisItem,self,@battle,(forcedItem!=0))
      pbHeldItemTriggered(thisItem,forcedItem,fling)
    end
  end

  # Used for White Herb (restore lowered stats). Only called by Moody and Sticky
  # Web, as all other stat reduction happens because of/during move usage and
  # this handler is also called at the end of each move's usage.
  # forcedItem is an item ID for Pluck/Fling, and 0 otherwise. fling is for
  # Fling only.
  def pbItemStatRestoreCheck(forcedItem=0,fling=false)
    return if fainted?
    return if forcedItem==0 && !itemActive?
    thisItem = (forcedItem>0) ? forcedItem : @item
    if BattleHandlers.triggerEndOfMoveStatRestoreItem(thisItem,self,@battle,(forcedItem!=0))
      pbHeldItemTriggered(thisItem,forcedItem,fling)
    end
  end

  # Called when the battle terrain changes and when a Pokémon loses HP.
  # forcedItem is an item ID for Pluck/Fling, and 0 otherwise. fling is for
  # Fling only.
  def pbItemTerrainStatBoostCheck
    return if !itemActive?
    if BattleHandlers.triggerTerrainStatBoostItem(@item,self,@battle)
      pbHeldItemTriggered(@item)
    end
  end

  # Used for Adrenaline Orb. Called when Intimidate is triggered (even if
  # Intimidate has no effect on the Pokémon).
  # forcedItem is an item ID for Pluck/Fling, and 0 otherwise. fling is for
  # Fling only.
  def pbItemOnIntimidatedCheck
    return if !itemActive?
    if BattleHandlers.triggerItemOnIntimidated(@item,self,@battle)
      pbHeldItemTriggered(@item)
    end
  end
end
