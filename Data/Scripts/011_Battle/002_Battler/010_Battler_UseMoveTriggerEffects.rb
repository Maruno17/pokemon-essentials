class Battle::Battler
  #=============================================================================
  # Effect per hit
  #=============================================================================
  def pbEffectsOnMakingHit(move, user, target)
    if target.damageState.calcDamage > 0 && !target.damageState.substitute
      # Target's ability
      if target.abilityActive?(true)
        oldHP = user.hp
        Battle::AbilityEffects.triggerOnBeingHit(target.ability, user, target, move, @battle)
        user.pbItemHPHealCheck if user.hp < oldHP
      end
      # Cramorant - Gulp Missile
      if target.isSpecies?(:CRAMORANT) && target.ability == :GULPMISSILE &&
         target.form > 0 && !target.effects[PBEffects::Transform]
        oldHP = user.hp
        # NOTE: Strictly speaking, an attack animation should be shown (the
        #       target Cramorant attacking the user) and the ability splash
        #       shouldn't be shown.
        @battle.pbShowAbilitySplash(target)
        if user.takesIndirectDamage?(Battle::Scene::USE_ABILITY_SPLASH)
          @battle.scene.pbDamageAnimation(user)
          user.pbReduceHP(user.totalhp / 4, false)
        end
        case target.form
        when 1   # Gulping Form
          user.pbLowerStatStageByAbility(:DEFENSE, 1, target, false)
        when 2   # Gorging Form
          user.pbParalyze(target) if user.pbCanParalyze?(target, false)
        end
        @battle.pbHideAbilitySplash(target)
        user.pbItemHPHealCheck if user.hp < oldHP
      end
      # User's ability
      if user.abilityActive?(true)
        Battle::AbilityEffects.triggerOnDealingHit(user.ability, user, target, move, @battle)
        user.pbItemHPHealCheck
      end
      # Target's item
      if target.itemActive?(true)
        oldHP = user.hp
        Battle::ItemEffects.triggerOnBeingHit(target.item, user, target, move, @battle)
        user.pbItemHPHealCheck if user.hp < oldHP
      end
    end
    if target.opposes?(user)
      # Rage
      if target.effects[PBEffects::Rage] && !target.fainted? &&
         target.pbCanRaiseStatStage?(:ATTACK, target)
        @battle.pbDisplay(_INTL("{1}'s rage is building!", target.pbThis))
        target.pbRaiseStatStage(:ATTACK, 1, target)
      end
      # Beak Blast
      if target.effects[PBEffects::BeakBlast]
        PBDebug.log("[Lingering effect] #{target.pbThis}'s Beak Blast")
        if move.pbContactMove?(user) && user.affectedByContactEffect? &&
           user.pbCanBurn?(target, false, self)
          user.pbBurn(target)
        end
      end
      # Shell Trap (make the trapper move next if the trap was triggered)
      if target.effects[PBEffects::ShellTrap] && move.physicalMove? &&
         @battle.choices[target.index][0] == :UseMove && !target.movedThisRound? &&
         target.damageState.hpLost > 0 && !target.damageState.substitute
        target.tookPhysicalHit              = true
        target.effects[PBEffects::MoveNext] = true
        target.effects[PBEffects::Quash]    = 0
      end
      # Grudge
      if target.effects[PBEffects::Grudge] && target.fainted?
        user.pbSetPP(move, 0)
        @battle.pbDisplay(_INTL("{1}'s {2} lost all of its PP due to the grudge!",
                                user.pbThis, move.name))
      end
      # Destiny Bond (recording that it should apply)
      if target.effects[PBEffects::DestinyBond] && target.fainted? &&
         user.effects[PBEffects::DestinyBondTarget] < 0
        user.effects[PBEffects::DestinyBondTarget] = target.index
      end
    end
  end

  #=============================================================================
  # Effects after all hits (i.e. at end of move usage)
  #=============================================================================
  def pbEffectsAfterMove(user, targets, move, numHits)
    # Defrost
    if move.damagingMove?
      targets.each do |b|
        next if b.damageState.unaffected || b.damageState.substitute
        next if b.status != :FROZEN
        # NOTE: Non-Fire-type moves that thaw the user will also thaw the
        #       target (in Gen 6+).
        if move.calcType == :FIRE || (Settings::MECHANICS_GENERATION >= 6 && move.thawsUser?)
          b.pbCureStatus
        end
      end
    end
    # Destiny Bond
    # NOTE: Although Destiny Bond is similar to Grudge, they don't apply at
    #       the same time (however, Destiny Bond does check whether it's going
    #       to trigger at the same time as Grudge).
    if user.effects[PBEffects::DestinyBondTarget] >= 0 && !user.fainted?
      dbName = @battle.battlers[user.effects[PBEffects::DestinyBondTarget]].pbThis
      @battle.pbDisplay(_INTL("{1} took its attacker down with it!", dbName))
      user.pbReduceHP(user.hp, false)
      user.pbItemHPHealCheck
      user.pbFaint
      @battle.pbJudgeCheckpoint(user)
    end
    # User's ability
    if user.abilityActive?
      Battle::AbilityEffects.triggerOnEndOfUsingMove(user.ability, user, targets, move, @battle)
    end
    if !user.fainted? && !user.effects[PBEffects::Transform] &&
       !@battle.pbAllFainted?(user.idxOpposingSide)
      # Greninja - Battle Bond
      if user.isSpecies?(:GRENINJA) && user.ability == :BATTLEBOND &&
         !@battle.battleBond[user.index & 1][user.pokemonIndex]
        numFainted = 0
        targets.each { |b| numFainted += 1 if b.damageState.fainted }
        if numFainted > 0 && user.form == 1
          @battle.battleBond[user.index & 1][user.pokemonIndex] = true
          @battle.pbDisplay(_INTL("{1} became fully charged due to its bond with its Trainer!", user.pbThis))
          @battle.pbShowAbilitySplash(user, true)
          @battle.pbHideAbilitySplash(user)
          user.pbChangeForm(2, _INTL("{1} became Ash-Greninja!", user.pbThis))
        end
      end
      # Cramorant = Gulp Missile
      if user.isSpecies?(:CRAMORANT) && user.ability == :GULPMISSILE && user.form == 0 &&
         ((move.id == :SURF && numHits > 0) || (move.id == :DIVE && move.chargingTurn))
        # NOTE: Intentionally no ability splash or message here.
        user.pbChangeForm((user.hp > user.totalhp / 2) ? 1 : 2, nil)
      end
    end
    # Room Service
    if move.function_code == "StartSlowerBattlersActFirst" && @battle.field.effects[PBEffects::TrickRoom] > 0
      @battle.allBattlers.each do |b|
        next if !b.hasActiveItem?(:ROOMSERVICE)
        next if !b.pbCanLowerStatStage?(:SPEED)
        @battle.pbCommonAnimation("UseItem", b)
        b.pbLowerStatStage(:SPEED, 1, nil)
        b.pbConsumeItem
      end
    end
    # Consume user's Gem
    if user.effects[PBEffects::GemConsumed]
      # NOTE: The consume animation and message for Gems are shown immediately
      #       after the move's animation, but the item is only consumed now.
      user.pbConsumeItem
    end
    switched_battlers = []   # Indices of battlers that were switched out somehow
    # Target switching caused by Roar, Whirlwind, Circle Throw, Dragon Tail
    move.pbSwitchOutTargetEffect(user, targets, numHits, switched_battlers)
    # Target's item, user's item, target's ability (all negated by Sheer Force)
    if !(user.hasActiveAbility?(:SHEERFORCE) && move.addlEffect > 0)
      pbEffectsAfterMove2(user, targets, move, numHits, switched_battlers)
    end
    # Some move effects that need to happen here, i.e. user switching caused by
    # U-turn/Volt Switch/Baton Pass/Parting Shot, Relic Song's form changing,
    # Fling/Natural Gift consuming item.
    if !switched_battlers.include?(user.index)
      move.pbEndOfMoveUsageEffect(user, targets, numHits, switched_battlers)
    end
    # User's ability/item that switches the user out (all negated by Sheer Force)
    if !(user.hasActiveAbility?(:SHEERFORCE) && move.addlEffect > 0)
      pbEffectsAfterMove3(user, targets, move, numHits, switched_battlers)
    end
    if numHits > 0
      @battle.allBattlers.each { |b| b.pbItemEndOfMoveCheck }
    end
  end

  # Everything in this method is negated by Sheer Force.
  def pbEffectsAfterMove2(user, targets, move, numHits, switched_battlers)
    # Target's held item (Eject Button, Red Card, Eject Pack)
    @battle.pbPriority(true).each do |b|
      if targets.any? { |targetB| targetB.index == b.index } &&
         !b.damageState.unaffected && b.damageState.calcDamage > 0 && b.itemActive?
        Battle::ItemEffects.triggerAfterMoveUseFromTarget(b.item, b, user, move, switched_battlers, @battle)
      end
      # Target's Eject Pack
      if switched_battlers.empty? && b.index != user.index && b.pbItemOnStatDropped(user)
        switched_battlers.push(b.index)
      end
    end
    # User's held item (Life Orb, Shell Bell, Throat Spray, Eject Pack)
    if !switched_battlers.include?(user.index) && user.itemActive?   # Only if user hasn't switched out
      Battle::ItemEffects.triggerAfterMoveUseFromUser(user.item, user, targets, move, numHits, @battle)
    end
    # Target's ability (Berserk, Color Change, Emergency Exit, Pickpocket, Wimp Out)
    @battle.pbPriority(true).each do |b|
      if targets.any? { |targetB| targetB.index == b.index } &&
         !b.damageState.unaffected && !switched_battlers.include?(b.index) && b.abilityActive?
        Battle::AbilityEffects.triggerAfterMoveUseFromTarget(b.ability, b, user, move, switched_battlers, @battle)
      end
      # Target's Emergency Exit, Wimp Out (including for Pokémon hurt by Flame Burst)
      if switched_battlers.empty? && move.damagingMove? &&
         b.index != user.index && b.pbAbilitiesOnDamageTaken(user)
        switched_battlers.push(b.index)
      end
    end
  end

  # Everything in this method is negated by Sheer Force.
  def pbEffectsAfterMove3(user, targets, move, numHits, switched_battlers)
    # User's held item that switches it out (Eject Pack)
    if switched_battlers.empty? && user.pbItemOnStatDropped(user)
      switched_battlers.push(user.index)
    end
    # User's ability (Emergency Exit, Wimp Out)
    if switched_battlers.empty? && move.damagingMove? && user.pbAbilitiesOnDamageTaken(user)
      switched_battlers.push(user.index)
    end
  end
end
