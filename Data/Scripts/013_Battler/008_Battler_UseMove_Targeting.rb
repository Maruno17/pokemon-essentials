class PokeBattle_Battler
  #=============================================================================
  # Get move's user
  #=============================================================================
  def pbFindUser(_choice,_move)
    return self
  end

  def pbChangeUser(choice,move,user)
    # Snatch
    move.snatched = false
    if move.canSnatch?
      newUser = nil; strength = 100
      @battle.eachBattler do |b|
        next if b.effects[PBEffects::Snatch]==0 ||
                b.effects[PBEffects::Snatch]>=strength
        next if b.effects[PBEffects::SkyDrop]>=0
        newUser = b
        strength = b.effects[PBEffects::Snatch]
      end
      if newUser
        user = newUser
        user.effects[PBEffects::Snatch] = 0
        move.snatched = true
        @battle.moldBreaker = user.hasMoldBreaker?
        choice[3] = -1   # Clear pre-chosen target
      end
    end
    return user
  end

  #=============================================================================
  # Get move's default target(s)
  #=============================================================================
  def pbFindTargets(choice,move,user)
    preTarget = choice[3]   # A target that was already chosen
    targets = []
    # Get list of targets
    targeting = move.pbTarget(user)
    # Expanding Force
    if move.function == "192" &&
       @battle.field.terrain == PBBattleTerrains::Psychic && !user.airborne?
       @battle.eachOtherSideBattler(user.index) { |b| pbAddTarget(targets,user,b,move,false) }
    end
    case targeting   # Curse can change its target type
    when PBTargets::NearAlly
      targetBattler = (preTarget>=0) ? @battle.battlers[preTarget] : nil
      if !pbAddTarget(targets,user,targetBattler,move)
        pbAddTargetRandomAlly(targets,user,move)
      end
    when PBTargets::UserOrNearAlly
      targetBattler = (preTarget>=0) ? @battle.battlers[preTarget] : nil
      if !pbAddTarget(targets,user,targetBattler,move,true,true)
        pbAddTarget(targets,user,user,move,true,true)
      end
    when PBTargets::NearFoe, PBTargets::NearOther
      targetBattler = (preTarget>=0) ? @battle.battlers[preTarget] : nil
      if !pbAddTarget(targets,user,targetBattler,move)
        if preTarget>=0 && !user.opposes?(preTarget)
          pbAddTargetRandomAlly(targets,user,move)
        else
          pbAddTargetRandomFoe(targets,user,move)
        end
      end
    when PBTargets::AllNearFoes
      @battle.eachOtherSideBattler(user.index) { |b| pbAddTarget(targets,user,b,move) }
    when PBTargets::RandomNearFoe
      pbAddTargetRandomFoe(targets,user,move)
    when PBTargets::AllNearOthers
      @battle.eachBattler { |b| pbAddTarget(targets,user,b,move) }
    when PBTargets::Other
      targetBattler = (preTarget>=0) ? @battle.battlers[preTarget] : nil
      if !pbAddTarget(targets,user,targetBattler,move,false)
        if preTarget>=0 && !user.opposes?(preTarget)
          pbAddTargetRandomAlly(targets,user,move,false)
        else
          pbAddTargetRandomFoe(targets,user,move,false)
        end
      end
    when PBTargets::UserAndAllies
      pbAddTarget(targets,user,user,move,true,true)
      @battle.eachSameSideBattler(user.index) { |b| pbAddTarget(targets,user,b,move,false,true) }
    when PBTargets::AllFoes
      @battle.eachOtherSideBattler(user.index) { |b| pbAddTarget(targets,user,b,move,false) }
    when PBTargets::AllBattlers
      @battle.eachBattler { |b| pbAddTarget(targets,user,b,move,false,true) }
    else
      # Used by Counter/Mirror Coat/Metal Burst/Bide
      move.pbAddTarget(targets,user)   # Move-specific pbAddTarget, not the def below
    end
    return targets
  end

  #=============================================================================
  # Redirect attack to another target
  #=============================================================================
  def pbChangeTargets(move,user,targets)
    targetType = move.pbTarget(user)
    return targets if @battle.switching   # For Pursuit interrupting a switch
    return targets if move.cannotRedirect?
    return targets if !PBTargets.canChooseOneFoeTarget?(targetType) || targets.length!=1
    # Stalwart / Propeller Tail
    return targets if user.hasActiveAbility?(:STALWART) || user.hasActiveAbility?(:PROPELLERTAIL)
	return targets if isConst?(move.id,PBMoves,:SNIPESHOT)
    priority = @battle.pbPriority(true)
    nearOnly = !PBTargets.canChooseDistantTarget?(move.target)
    # Spotlight (takes priority over Follow Me/Rage Powder/Lightning Rod/Storm Drain)
    newTarget = nil; strength = 100   # Lower strength takes priority
    priority.each do |b|
      next if b.fainted? || b.effects[PBEffects::SkyDrop]>=0
      next if b.effects[PBEffects::Spotlight]==0 ||
              b.effects[PBEffects::Spotlight]>=strength
      next if !b.opposes?(user)
      next if nearOnly && !b.near?(user)
      newTarget = b
      strength = b.effects[PBEffects::Spotlight]
    end
    if newTarget
      PBDebug.log("[Move target changed] #{newTarget.pbThis}'s Spotlight made it the target")
      targets = []
      pbAddTarget(targets,user,newTarget,move,nearOnly)
      return targets
    end
    # Follow Me/Rage Powder (takes priority over Lightning Rod/Storm Drain)
    newTarget = nil; strength = 100   # Lower strength takes priority
    priority.each do |b|
      next if b.fainted? || b.effects[PBEffects::SkyDrop]>=0
      next if b.effects[PBEffects::RagePowder] && !user.affectedByPowder?
      next if b.effects[PBEffects::FollowMe]==0 ||
              b.effects[PBEffects::FollowMe]>=strength
      next if !b.opposes?(user)
      next if nearOnly && !b.near?(user)
      newTarget = b
      strength = b.effects[PBEffects::FollowMe]
    end
    if newTarget
      PBDebug.log("[Move target changed] #{newTarget.pbThis}'s Follow Me/Rage Powder made it the target")
      targets = []
      pbAddTarget(targets,user,newTarget,move,nearOnly)
      return targets
    end
    # Lightning Rod
    targets = pbChangeTargetByAbility(:LIGHTNINGROD,:ELECTRIC,move,user,targets,priority,nearOnly)
    # Storm Drain
    targets = pbChangeTargetByAbility(:STORMDRAIN,:WATER,move,user,targets,priority,nearOnly)
    return targets
  end

  def pbChangeTargetByAbility(drawingAbility,drawnType,move,user,targets,priority,nearOnly)
    return targets if !isConst?(move.calcType,PBTypes,drawnType)
    return targets if targets[0].hasActiveAbility?(drawingAbility)
    priority.each do |b|
      next if b.index==user.index || b.index==targets[0].index
      next if !b.hasActiveAbility?(drawingAbility)
      next if nearOnly && !b.near?(user)
      @battle.pbShowAbilitySplash(b)
      targets.clear
      pbAddTarget(targets,user,b,move,nearOnly)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        @battle.pbDisplay(_INTL("{1} took the attack!",b.pbThis))
      else
        @battle.pbDisplay(_INTL("{1} took the attack with its {2}!",b.pbThis,b.abilityName))
      end
      @battle.pbHideAbilitySplash(b)
      break
    end
    return targets
  end

  #=============================================================================
  # Register target
  #=============================================================================
  def pbAddTarget(targets,user,target,move,nearOnly=true,allowUser=false)
    return false if !target || (target.fainted? && !move.cannotRedirect?)
    return false if !(allowUser && user==target) && nearOnly && !user.near?(target)
    targets.each { |b| return true if b.index==target.index }   # Already added
    targets.push(target)
    return true
  end

  def pbAddTargetRandomAlly(targets,user,_move,nearOnly=true)
    choices = []
    user.eachAlly do |b|
      next if nearOnly && !user.near?(b)
      pbAddTarget(choices,user,b,nearOnly)
    end
    if choices.length>0
      pbAddTarget(targets,user,choices[@battle.pbRandom(choices.length)],nearOnly)
    end
  end

  def pbAddTargetRandomFoe(targets,user,_move,nearOnly=true)
    choices = []
    user.eachOpposing do |b|
      next if nearOnly && !user.near?(b)
      pbAddTarget(choices,user,b,nearOnly)
    end
    if choices.length>0
      pbAddTarget(targets,user,choices[@battle.pbRandom(choices.length)],nearOnly)
    end
  end
end
