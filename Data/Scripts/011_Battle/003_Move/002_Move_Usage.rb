class Battle::Move
  #=============================================================================
  # Effect methods per move usage
  #=============================================================================
  def pbCanChooseMove?(user, commandPhase, showMessages); return true; end   # For Belch
  def pbDisplayChargeMessage(user); end   # For Focus Punch/shell Trap/Beak Blast
  def pbOnStartUse(user, targets); end
  def pbAddTarget(targets, user); end   # For Counter, etc. and Bide
  def pbModifyTargets(targets, user); end   # For Dragon Darts

  # Reset move usage counters (child classes can increment them).
  def pbChangeUsageCounters(user, specialUsage)
    user.effects[PBEffects::FuryCutter]   = 0
    user.effects[PBEffects::ParentalBond] = 0
    user.effects[PBEffects::ProtectRate]  = 1
    @battle.field.effects[PBEffects::FusionBolt]  = false
    @battle.field.effects[PBEffects::FusionFlare] = false
  end

  def pbDisplayUseMessage(user)
    @battle.pbDisplayBrief(_INTL("{1} used {2}!", user.pbThis, @name))
  end

  def pbShowFailMessages?(targets); return true; end
  def pbMissMessage(user, target); return false; end

  #=============================================================================
  #
  #=============================================================================
  # Whether the move is currently in the "charging" turn of a two-turn move.
  # Is false if Power Herb or another effect lets a two-turn move charge and
  # attack in the same turn.
  # user.effects[PBEffects::TwoTurnAttack] is set to the move's ID during the
  # charging turn, and is nil during the attack turn.
  def pbIsChargingTurn?(user); return false; end
  def pbDamagingMove?; return damagingMove?; end

  def pbContactMove?(user)
    return false if user.hasActiveAbility?(:LONGREACH)
    return contactMove?
  end

  # The maximum number of hits in a round this move will actually perform. This
  # can be 1 for Beat Up, and can be 2 for any moves affected by Parental Bond.
  def pbNumHits(user, targets)
    if user.hasActiveAbility?(:PARENTALBOND) && pbDamagingMove? &&
       !chargingTurnMove? && targets.length == 1
      # Record that Parental Bond applies, to weaken the second attack
      user.effects[PBEffects::ParentalBond] = 3
      return 2
    end
    return 1
  end

  # For two-turn moves when they charge and attack in the same turn.
  def pbQuickChargingMove(user, targets); end

  #=============================================================================
  # Effect methods per hit
  #=============================================================================
  def pbOverrideSuccessCheckPerHit(user, target); return false; end
  def pbCrashDamage(user); end
  def pbInitialEffect(user, targets, hitNum); end
  def pbDesignateTargetsForHit(targets, hitNum); return targets; end   # For Dragon Darts
  def pbRepeatHit?; return false; end   # For Dragon Darts

  def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    return if !showAnimation
    if user.effects[PBEffects::ParentalBond] == 1
      @battle.pbCommonAnimation("ParentalBond", user, targets)
    else
      @battle.pbAnimation(id, user, targets, hitNum)
    end
  end

  def pbSelfKO(user); end
  def pbEffectWhenDealingDamage(user, target); end
  def pbEffectAgainstTarget(user, target); end
  def pbEffectGeneral(user); end
  def pbAdditionalEffect(user, target); end
  def pbEffectAfterAllHits(user, target); end   # Move effects that occur after all hits
  def pbSwitchOutTargetEffect(user, targets, numHits, switched_battlers); end
  def pbEndOfMoveUsageEffect(user, targets, numHits, switchedBattlers); end

  #=============================================================================
  # Check if target is immune to the move because of its ability
  #=============================================================================
  def pbImmunityByAbility(user, target, show_message)
    return false if @battle.moldBreaker
    ret = false
    if target.abilityActive?
      ret = Battle::AbilityEffects.triggerMoveImmunity(target.ability, user, target,
                                                       self, @calcType, @battle, show_message)
    end
    return ret
  end

  #=============================================================================
  # Move failure checks
  #=============================================================================
  # Check whether the move fails completely due to move-specific requirements.
  def pbMoveFailed?(user, targets); return false; end
  # Checks whether the move will be ineffective against the target.
  def pbFailsAgainstTarget?(user, target, show_message); return false; end

  def pbMoveFailedLastInRound?(user, showMessage = true)
    unmoved = @battle.allBattlers.any? do |b|
      next b.index != user.index &&
           [:UseMove, :Shift].include?(@battle.choices[b.index][0]) &&
           !b.movedThisRound?
    end
    if !unmoved
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return true
    end
    return false
  end

  def pbMoveFailedTargetAlreadyMoved?(target, showMessage = true)
    if (@battle.choices[target.index][0] != :UseMove &&
       @battle.choices[target.index][0] != :Shift) || target.movedThisRound?
      @battle.pbDisplay(_INTL("But it failed!")) if showMessage
      return true
    end
    return false
  end

  def pbMoveFailedAromaVeil?(user, target, showMessage = true)
    return false if @battle.moldBreaker
    if target.hasActiveAbility?(:AROMAVEIL)
      if showMessage
        @battle.pbShowAbilitySplash(target)
        if Battle::Scene::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("{1} is unaffected!", target.pbThis))
        else
          @battle.pbDisplay(_INTL("{1} is unaffected because of its {2}!",
                                  target.pbThis, target.abilityName))
        end
        @battle.pbHideAbilitySplash(target)
      end
      return true
    end
    target.allAllies.each do |b|
      next if !b.hasActiveAbility?(:AROMAVEIL)
      if showMessage
        @battle.pbShowAbilitySplash(b)
        if Battle::Scene::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("{1} is unaffected!", target.pbThis))
        else
          @battle.pbDisplay(_INTL("{1} is unaffected because of {2}'s {3}!",
                                  target.pbThis, b.pbThis(true), b.abilityName))
        end
        @battle.pbHideAbilitySplash(b)
      end
      return true
    end
    return false
  end

  #=============================================================================
  # Weaken the damage dealt (doesn't actually change a battler's HP)
  #=============================================================================
  def pbCheckDamageAbsorption(user, target)
    # Substitute will take the damage
    if target.effects[PBEffects::Substitute] > 0 && !ignoresSubstitute?(user) &&
       (!user || user.index != target.index)
      target.damageState.substitute = true
      return
    end
    # Ice Face will take the damage
    if !@battle.moldBreaker && target.isSpecies?(:EISCUE) &&
       target.form == 0 && target.ability == :ICEFACE && physicalMove?
      target.damageState.iceFace = true
      return
    end
    # Disguise will take the damage
    if !@battle.moldBreaker && target.isSpecies?(:MIMIKYU) &&
       target.form == 0 && target.ability == :DISGUISE
      target.damageState.disguise = true
      return
    end
  end

  def pbReduceDamage(user, target)
    damage = target.damageState.calcDamage
    # Substitute takes the damage
    if target.damageState.substitute
      damage = target.effects[PBEffects::Substitute] if damage > target.effects[PBEffects::Substitute]
      target.damageState.hpLost       = damage
      target.damageState.totalHPLost += damage
      return
    end
    # Disguise/Ice Face takes the damage
    return if target.damageState.disguise || target.damageState.iceFace
    # Target takes the damage
    if damage >= target.hp
      damage = target.hp
      # Survive a lethal hit with 1 HP effects
      if nonLethal?(user, target)
        damage -= 1
      elsif target.effects[PBEffects::Endure]
        target.damageState.endured = true
        damage -= 1
      elsif damage == target.totalhp
        if target.hasActiveAbility?(:STURDY) && !@battle.moldBreaker
          target.damageState.sturdy = true
          damage -= 1
        elsif target.hasActiveItem?(:FOCUSSASH) && target.hp == target.totalhp
          target.damageState.focusSash = true
          damage -= 1
        elsif target.hasActiveItem?(:FOCUSBAND) && @battle.pbRandom(100) < 10
          target.damageState.focusBand = true
          damage -= 1
        elsif Settings::AFFECTION_EFFECTS && @battle.internalBattle &&
              target.pbOwnedByPlayer? && !target.mega?
          chance = [0, 0, 0, 10, 15, 25][target.affection_level]
          if chance > 0 && @battle.pbRandom(100) < chance
            target.damageState.affection_endured = true
            damage -= 1
          end
        end
      end
    end
    damage = 0 if damage < 0
    target.damageState.hpLost       = damage
    target.damageState.totalHPLost += damage
  end

  #=============================================================================
  # Change the target's HP by the amount calculated above
  #=============================================================================
  def pbInflictHPDamage(target)
    if target.damageState.substitute
      target.effects[PBEffects::Substitute] -= target.damageState.hpLost
    elsif target.damageState.hpLost > 0
      target.pbReduceHP(target.damageState.hpLost, false, true, false)
    end
  end

  #=============================================================================
  # Animate the damage dealt, including lowering the HP
  #=============================================================================
  # Animate being damaged and losing HP (by a move)
  def pbAnimateHitAndHPLost(user, targets)
    # Animate allies first, then foes
    animArray = []
    2.times do |side|   # side here means "allies first, then foes"
      targets.each do |b|
        next if b.damageState.unaffected || b.damageState.hpLost == 0
        next if (side == 0 && b.opposes?(user)) || (side == 1 && !b.opposes?(user))
        oldHP = b.hp
        if b.damageState.substitute
          old_sub_hp = b.effects[PBEffects::Substitute] + b.damageState.hpLost
          PBDebug.log("[Substitute HP change] #{b.pbThis}'s substitute lost #{b.damageState.hpLost} HP (#{old_sub_hp} -> #{b.effects[PBEffects::Substitute]})")
        else
          oldHP += b.damageState.hpLost
        end
        effectiveness = 0
        if Effectiveness.resistant?(b.damageState.typeMod)
          effectiveness = 1
        elsif Effectiveness.super_effective?(b.damageState.typeMod)
          effectiveness = 2
        end
        animArray.push([b, oldHP, effectiveness])
      end
      if animArray.length > 0
        @battle.scene.pbHitAndHPLossAnimation(animArray)
        animArray.clear
      end
    end
  end

  #=============================================================================
  # Messages upon being hit
  #=============================================================================
  def pbEffectivenessMessage(user, target, numTargets = 1)
    return if self.is_a?(Battle::Move::FixedDamageMove)
    return if target.damageState.disguise || target.damageState.iceFace
    if Effectiveness.super_effective?(target.damageState.typeMod)
      if numTargets > 1
        @battle.pbDisplay(_INTL("It's super effective on {1}!", target.pbThis(true)))
      else
        @battle.pbDisplay(_INTL("It's super effective!"))
      end
    elsif Effectiveness.not_very_effective?(target.damageState.typeMod)
      if numTargets > 1
        @battle.pbDisplay(_INTL("It's not very effective on {1}...", target.pbThis(true)))
      else
        @battle.pbDisplay(_INTL("It's not very effective..."))
      end
    end
  end

  def pbHitEffectivenessMessages(user, target, numTargets = 1)
    return if target.damageState.disguise || target.damageState.iceFace
    if target.damageState.substitute
      @battle.pbDisplay(_INTL("The substitute took damage for {1}!", target.pbThis(true)))
    end
    if target.damageState.critical
      if $game_temp.party_critical_hits_dealt &&
         $game_temp.party_critical_hits_dealt[user.pokemonIndex] &&
         user.pbOwnedByPlayer?
        $game_temp.party_critical_hits_dealt[user.pokemonIndex] += 1
      end
      if target.damageState.affection_critical
        if numTargets > 1
          @battle.pbDisplay(_INTL("{1} landed a critical hit on {2}, wishing to be praised!",
                                  user.pbThis, target.pbThis(true)))
        else
          @battle.pbDisplay(_INTL("{1} landed a critical hit, wishing to be praised!", user.pbThis))
        end
      elsif numTargets > 1
        @battle.pbDisplay(_INTL("A critical hit on {1}!", target.pbThis(true)))
      else
        @battle.pbDisplay(_INTL("A critical hit!"))
      end
    end
    # Effectiveness message, for moves with 1 hit
    if !multiHitMove? && user.effects[PBEffects::ParentalBond] == 0
      pbEffectivenessMessage(user, target, numTargets)
    end
    if target.damageState.substitute && target.effects[PBEffects::Substitute] == 0
      target.effects[PBEffects::Substitute] = 0
      @battle.pbDisplay(_INTL("{1}'s substitute faded!", target.pbThis))
    end
  end

  def pbEndureKOMessage(target)
    if target.damageState.disguise
      @battle.pbShowAbilitySplash(target)
      if Battle::Scene::USE_ABILITY_SPLASH
        @battle.pbDisplay(_INTL("Its disguise served it as a decoy!"))
      else
        @battle.pbDisplay(_INTL("{1}'s disguise served it as a decoy!", target.pbThis))
      end
      @battle.pbHideAbilitySplash(target)
      target.pbChangeForm(1, _INTL("{1}'s disguise was busted!", target.pbThis))
      target.pbReduceHP(target.totalhp / 8, false) if Settings::MECHANICS_GENERATION >= 8
    elsif target.damageState.iceFace
      @battle.pbShowAbilitySplash(target)
      if !Battle::Scene::USE_ABILITY_SPLASH
        @battle.pbDisplay(_INTL("{1}'s {2} activated!", target.pbThis, target.abilityName))
      end
      target.pbChangeForm(1, _INTL("{1} transformed!", target.pbThis))
      @battle.pbHideAbilitySplash(target)
    elsif target.damageState.endured
      @battle.pbDisplay(_INTL("{1} endured the hit!", target.pbThis))
    elsif target.damageState.sturdy
      @battle.pbShowAbilitySplash(target)
      if Battle::Scene::USE_ABILITY_SPLASH
        @battle.pbDisplay(_INTL("{1} endured the hit!", target.pbThis))
      else
        @battle.pbDisplay(_INTL("{1} hung on with Sturdy!", target.pbThis))
      end
      @battle.pbHideAbilitySplash(target)
    elsif target.damageState.focusSash
      @battle.pbCommonAnimation("UseItem", target)
      @battle.pbDisplay(_INTL("{1} hung on using its Focus Sash!", target.pbThis))
      target.pbConsumeItem
    elsif target.damageState.focusBand
      @battle.pbCommonAnimation("UseItem", target)
      @battle.pbDisplay(_INTL("{1} hung on using its Focus Band!", target.pbThis))
    elsif target.damageState.affection_endured
      @battle.pbDisplay(_INTL("{1} toughed it out so you wouldn't feel sad!", target.pbThis))
    end
  end

  # Used by Counter/Mirror Coat/Metal Burst/Revenge/Focus Punch/Bide/Assurance.
  def pbRecordDamageLost(user, target)
    damage = target.damageState.hpLost
    # NOTE: In Gen 3 where a move's category depends on its type, Hidden Power
    #       is for some reason countered by Counter rather than Mirror Coat,
    #       regardless of its calculated type. Hence the following two lines of
    #       code.
    moveType = nil
    moveType = :NORMAL if @function_code == "TypeDependsOnUserIVs"   # Hidden Power
    if !target.damageState.substitute
      if physicalMove?(moveType)
        target.effects[PBEffects::Counter]       = damage
        target.effects[PBEffects::CounterTarget] = user.index
      elsif specialMove?(moveType)
        target.effects[PBEffects::MirrorCoat]       = damage
        target.effects[PBEffects::MirrorCoatTarget] = user.index
      end
    end
    if target.effects[PBEffects::Bide] > 0
      target.effects[PBEffects::BideDamage] += damage
      target.effects[PBEffects::BideTarget] = user.index
    end
    target.damageState.fainted = true if target.fainted?
    target.lastHPLost = damage
    target.tookMoveDamageThisRound = true if damage > 0 && !target.damageState.substitute   # For Focus Punch
    target.tookDamageThisRound = true if damage > 0   # For Assurance
    target.lastAttacker.push(user.index)              # For Revenge
    if target.opposes?(user)
      target.lastHPLostFromFoe = damage               # For Metal Burst
      target.lastFoeAttacker.push(user.index)         # For Metal Burst
    end
    if $game_temp.party_direct_damage_taken &&
       $game_temp.party_direct_damage_taken[target.pokemonIndex] &&
       target.pbOwnedByPlayer?
      $game_temp.party_direct_damage_taken[target.pokemonIndex] += damage
    end
  end
end
