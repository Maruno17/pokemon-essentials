#===============================================================================
# User flees from battle. (Teleport (Gen 7-))
#===============================================================================
class Battle::Move::FleeFromBattle < Battle::Move
  def pbMoveFailed?(user, targets)
    if !@battle.pbCanRun?(user.index)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.pbDisplay(_INTL("{1} fled from battle!", user.pbThis))
    @battle.decision = 3   # Escaped
  end
end

#===============================================================================
# User switches out. If user is a wild Pokémon, ends the battle instead.
# (Teleport (Gen 8+))
#===============================================================================
class Battle::Move::SwitchOutUserStatusMove < Battle::Move
  def pbMoveFailed?(user, targets)
    if user.wild?
      if !@battle.pbCanRun?(user.index)
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
    elsif !@battle.pbCanChooseNonActive?(user.index)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEndOfMoveUsageEffect(user, targets, numHits, switchedBattlers)
    return if user.wild?
    @battle.pbDisplay(_INTL("{1} went back to {2}!", user.pbThis,
                            @battle.pbGetOwnerName(user.index)))
    @battle.pbPursuit(user.index)
    return if user.fainted?
    newPkmn = @battle.pbGetReplacementPokemonIndex(user.index)   # Owner chooses
    return if newPkmn < 0
    @battle.pbRecallAndReplace(user.index, newPkmn)
    @battle.pbClearChoice(user.index)   # Replacement Pokémon does nothing this round
    @battle.moldBreaker = false
    @battle.pbOnBattlerEnteringBattle(user.index)
    switchedBattlers.push(user.index)
  end

  def pbEffectGeneral(user)
    if user.wild?
      @battle.pbDisplay(_INTL("{1} fled from battle!", user.pbThis))
      @battle.decision = 3   # Escaped
    end
  end
end

#===============================================================================
# After inflicting damage, user switches out. Ignores trapping moves.
# (U-turn, Volt Switch)
#===============================================================================
class Battle::Move::SwitchOutUserDamagingMove < Battle::Move
  def pbEndOfMoveUsageEffect(user, targets, numHits, switchedBattlers)
    return if user.fainted? || numHits == 0 || @battle.pbAllFainted?(user.idxOpposingSide)
    targetSwitched = true
    targets.each do |b|
      targetSwitched = false if !switchedBattlers.include?(b.index)
    end
    return if targetSwitched
    return if !@battle.pbCanChooseNonActive?(user.index)
    @battle.pbDisplay(_INTL("{1} went back to {2}!", user.pbThis,
                            @battle.pbGetOwnerName(user.index)))
    @battle.pbPursuit(user.index)
    return if user.fainted?
    newPkmn = @battle.pbGetReplacementPokemonIndex(user.index)   # Owner chooses
    return if newPkmn < 0
    @battle.pbRecallAndReplace(user.index, newPkmn)
    @battle.pbClearChoice(user.index)   # Replacement Pokémon does nothing this round
    @battle.moldBreaker = false
    @battle.pbOnBattlerEnteringBattle(user.index)
    switchedBattlers.push(user.index)
  end
end

#===============================================================================
# Decreases the target's Attack and Special Attack by 1 stage each. Then, user
# switches out. Ignores trapping moves. (Parting Shot)
#===============================================================================
class Battle::Move::LowerTargetAtkSpAtk1SwitchOutUser < Battle::Move::TargetMultiStatDownMove
  def initialize(battle, move)
    super
    @statDown = [:ATTACK, 1, :SPECIAL_ATTACK, 1]
  end

  def pbEndOfMoveUsageEffect(user, targets, numHits, switchedBattlers)
    switcher = user
    targets.each do |b|
      next if switchedBattlers.include?(b.index)
      switcher = b if b.effects[PBEffects::MagicCoat] || b.effects[PBEffects::MagicBounce]
    end
    return if switcher.fainted? || numHits == 0
    return if !@battle.pbCanChooseNonActive?(switcher.index)
    @battle.pbDisplay(_INTL("{1} went back to {2}!", switcher.pbThis,
                            @battle.pbGetOwnerName(switcher.index)))
    @battle.pbPursuit(switcher.index)
    return if switcher.fainted?
    newPkmn = @battle.pbGetReplacementPokemonIndex(switcher.index)   # Owner chooses
    return if newPkmn < 0
    @battle.pbRecallAndReplace(switcher.index, newPkmn)
    @battle.pbClearChoice(switcher.index)   # Replacement Pokémon does nothing this round
    @battle.moldBreaker = false if switcher.index == user.index
    @battle.pbOnBattlerEnteringBattle(switcher.index)
    switchedBattlers.push(switcher.index)
  end
end

#===============================================================================
# User switches out. Various effects affecting the user are passed to the
# replacement. (Baton Pass)
#===============================================================================
class Battle::Move::SwitchOutUserPassOnEffects < Battle::Move
  def pbMoveFailed?(user, targets)
    if !@battle.pbCanChooseNonActive?(user.index)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEndOfMoveUsageEffect(user, targets, numHits, switchedBattlers)
    return if user.fainted? || numHits == 0
    return if !@battle.pbCanChooseNonActive?(user.index)
    @battle.pbPursuit(user.index)
    return if user.fainted?
    newPkmn = @battle.pbGetReplacementPokemonIndex(user.index)   # Owner chooses
    return if newPkmn < 0
    @battle.pbRecallAndReplace(user.index, newPkmn, false, true)
    @battle.pbClearChoice(user.index)   # Replacement Pokémon does nothing this round
    @battle.moldBreaker = false
    @battle.pbOnBattlerEnteringBattle(user.index)
    switchedBattlers.push(user.index)
  end
end

#===============================================================================
# In wild battles, makes target flee. Fails if target is a higher level than the
# user.
# In trainer battles, target switches out.
# For status moves. (Roar, Whirlwind)
#===============================================================================
class Battle::Move::SwitchOutTargetStatusMove < Battle::Move
  def ignoresSubstitute?(user); return true; end
  def canMagicCoat?;            return true; end

  def pbFailsAgainstTarget?(user, target, show_message)
    if target.hasActiveAbility?(:SUCTIONCUPS) && !@battle.moldBreaker
      if show_message
        @battle.pbShowAbilitySplash(target)
        if Battle::Scene::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("{1} anchors itself!", target.pbThis))
        else
          @battle.pbDisplay(_INTL("{1} anchors itself with {2}!", target.pbThis, target.abilityName))
        end
        @battle.pbHideAbilitySplash(target)
      end
      return true
    end
    if target.effects[PBEffects::Ingrain]
      @battle.pbDisplay(_INTL("{1} anchored itself with its roots!", target.pbThis)) if show_message
      return true
    end
    if !@battle.canRun
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    if @battle.wildBattle? && target.level > user.level
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    if @battle.trainerBattle?
      canSwitch = false
      @battle.eachInTeamFromBattlerIndex(target.index) do |_pkmn, i|
        next if !@battle.pbCanSwitchLax?(target.index, i)
        canSwitch = true
        break
      end
      if !canSwitch
        @battle.pbDisplay(_INTL("But it failed!")) if show_message
        return true
      end
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.decision = 3 if @battle.wildBattle?   # Escaped from battle
  end

  def pbSwitchOutTargetEffect(user, targets, numHits, switched_battlers)
    return if @battle.wildBattle? || !switched_battlers.empty?
    return if user.fainted? || numHits == 0
    targets.each do |b|
      next if b.fainted? || b.damageState.unaffected
      next if b.effects[PBEffects::Ingrain]
      next if b.hasActiveAbility?(:SUCTIONCUPS) && !@battle.moldBreaker
      newPkmn = @battle.pbGetReplacementPokemonIndex(b.index, true)   # Random
      next if newPkmn < 0
      @battle.pbRecallAndReplace(b.index, newPkmn, true)
      @battle.pbDisplay(_INTL("{1} was dragged out!", b.pbThis))
      @battle.pbClearChoice(b.index)   # Replacement Pokémon does nothing this round
      @battle.pbOnBattlerEnteringBattle(b.index)
      switched_battlers.push(b.index)
      break
    end
  end
end

#===============================================================================
# In wild battles, makes target flee. Fails if target is a higher level than the
# user.
# In trainer battles, target switches out.
# For damaging moves. (Circle Throw, Dragon Tail)
#===============================================================================
class Battle::Move::SwitchOutTargetDamagingMove < Battle::Move
  def pbEffectAgainstTarget(user, target)
    if @battle.wildBattle? && target.level <= user.level && @battle.canRun &&
       (target.effects[PBEffects::Substitute] == 0 || ignoresSubstitute?(user))
      @battle.decision = 3
    end
  end

  def pbSwitchOutTargetEffect(user, targets, numHits, switched_battlers)
    return if @battle.wildBattle? || !switched_battlers.empty?
    return if user.fainted? || numHits == 0
    targets.each do |b|
      next if b.fainted? || b.damageState.unaffected || b.damageState.substitute
      next if b.effects[PBEffects::Ingrain]
      next if b.hasActiveAbility?(:SUCTIONCUPS) && !@battle.moldBreaker
      newPkmn = @battle.pbGetReplacementPokemonIndex(b.index, true)   # Random
      next if newPkmn < 0
      @battle.pbRecallAndReplace(b.index, newPkmn, true)
      @battle.pbDisplay(_INTL("{1} was dragged out!", b.pbThis))
      @battle.pbClearChoice(b.index)   # Replacement Pokémon does nothing this round
      @battle.pbOnBattlerEnteringBattle(b.index)
      switched_battlers.push(b.index)
      break
    end
  end
end

#===============================================================================
# Trapping move. Traps for 5 or 6 rounds. Trapped Pokémon lose 1/16 of max HP
# at end of each round.
#===============================================================================
class Battle::Move::BindTarget < Battle::Move
  def pbEffectAgainstTarget(user, target)
    return if target.fainted? || target.damageState.substitute
    return if target.effects[PBEffects::Trapping] > 0
    # Set trapping effect duration and info
    if user.hasActiveItem?(:GRIPCLAW)
      target.effects[PBEffects::Trapping] = (Settings::MECHANICS_GENERATION >= 5) ? 8 : 6
    else
      target.effects[PBEffects::Trapping] = 5 + @battle.pbRandom(2)
    end
    target.effects[PBEffects::TrappingMove] = @id
    target.effects[PBEffects::TrappingUser] = user.index
    # Message
    msg = _INTL("{1} was trapped in the vortex!", target.pbThis)
    case @id
    when :BIND
      msg = _INTL("{1} was squeezed by {2}!", target.pbThis, user.pbThis(true))
    when :CLAMP
      msg = _INTL("{1} clamped {2}!", user.pbThis, target.pbThis(true))
    when :FIRESPIN
      msg = _INTL("{1} was trapped in the fiery vortex!", target.pbThis)
    when :INFESTATION
      msg = _INTL("{1} has been afflicted with an infestation by {2}!", target.pbThis, user.pbThis(true))
    when :MAGMASTORM
      msg = _INTL("{1} became trapped by Magma Storm!", target.pbThis)
    when :SANDTOMB
      msg = _INTL("{1} became trapped by Sand Tomb!", target.pbThis)
    when :WHIRLPOOL
      msg = _INTL("{1} became trapped in the vortex!", target.pbThis)
    when :WRAP
      msg = _INTL("{1} was wrapped by {2}!", target.pbThis, user.pbThis(true))
    end
    @battle.pbDisplay(msg)
  end
end

#===============================================================================
# Trapping move. Traps for 5 or 6 rounds. Trapped Pokémon lose 1/16 of max HP
# at end of each round. (Whirlpool)
# Power is doubled if target is using Dive. Hits some semi-invulnerable targets.
#===============================================================================
class Battle::Move::BindTargetDoublePowerIfTargetUnderwater < Battle::Move::BindTarget
  def hitsDivingTargets?; return true; end

  def pbModifyDamage(damageMult, user, target)
    damageMult *= 2 if target.inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderwater")
    return damageMult
  end
end

#===============================================================================
# Target can no longer switch out or flee, as long as the user remains active.
# (Anchor Shot, Block, Mean Look, Spider Web, Spirit Shackle, Thousand Waves)
#===============================================================================
class Battle::Move::TrapTargetInBattle < Battle::Move
  def canMagicCoat?; return true; end

  def pbFailsAgainstTarget?(user, target, show_message)
    return false if damagingMove?
    if target.effects[PBEffects::MeanLook] >= 0
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    if Settings::MORE_TYPE_EFFECTS && target.pbHasType?(:GHOST)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true))) if show_message
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    return if damagingMove?
    target.effects[PBEffects::MeanLook] = user.index
    @battle.pbDisplay(_INTL("{1} can no longer escape!", target.pbThis))
  end

  def pbAdditionalEffect(user, target)
    return if target.fainted? || target.damageState.substitute
    return if target.effects[PBEffects::MeanLook] >= 0
    return if Settings::MORE_TYPE_EFFECTS && target.pbHasType?(:GHOST)
    target.effects[PBEffects::MeanLook] = user.index
    @battle.pbDisplay(_INTL("{1} can no longer escape!", target.pbThis))
  end
end

#===============================================================================
# The target can no longer switch out or flee, while the user remains in battle.
# At the end of each round, the target's Defense and Special Defense are lowered
# by 1 stage each. (Octolock)
#===============================================================================
class Battle::Move::TrapTargetInBattleLowerTargetDefSpDef1EachTurn < Battle::Move
  def pbFailsAgainstTarget?(user, target, show_message)
    return false if damagingMove?
    if target.effects[PBEffects::Octolock] >= 0
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    if Settings::MORE_TYPE_EFFECTS && target.pbHasType?(:GHOST)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true))) if show_message
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    target.effects[PBEffects::Octolock] = user.index
    @battle.pbDisplay(_INTL("{1} can no longer escape because of {2}!", target.pbThis, @name))
  end
end

#===============================================================================
# Prevents the user and the target from switching out or fleeing. This effect
# isn't applied if either Pokémon is already prevented from switching out or
# fleeing. (Jaw Lock)
#===============================================================================
class Battle::Move::TrapUserAndTargetInBattle < Battle::Move
  def pbAdditionalEffect(user, target)
    return if user.fainted? || target.fainted? || target.damageState.substitute
    return if Settings::MORE_TYPE_EFFECTS && target.pbHasType?(:GHOST)
    return if user.trappedInBattle? || target.trappedInBattle?
    target.effects[PBEffects::JawLock] = user.index
    @battle.pbDisplay(_INTL("Neither Pokémon can run away!"))
  end
end

#===============================================================================
# No Pokémon can switch out or flee until the end of the next round. (Fairy Lock)
#===============================================================================
class Battle::Move::TrapAllBattlersInBattleForOneTurn < Battle::Move
  def pbMoveFailed?(user, targets)
    if @battle.field.effects[PBEffects::FairyLock] > 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.field.effects[PBEffects::FairyLock] = 2
    @battle.pbDisplay(_INTL("No one will be able to run away during the next turn!"))
  end
end

#===============================================================================
# Interrupts a foe switching out or using U-turn/Volt Switch/Parting Shot. Power
# is doubled in that case. (Pursuit)
# (Handled in Battle's pbAttackPhase): Makes this attack happen before switching.
#===============================================================================
class Battle::Move::PursueSwitchingFoe < Battle::Move
  def pbAccuracyCheck(user, target)
    return true if @battle.switching
    return super
  end

  def pbBaseDamage(baseDmg, user, target)
    baseDmg *= 2 if @battle.switching
    return baseDmg
  end
end

#===============================================================================
# Fails if user has not been hit by an opponent's physical move this round.
# (Shell Trap)
#===============================================================================
class Battle::Move::UsedAfterUserTakesPhysicalDamage < Battle::Move
  def pbDisplayChargeMessage(user)
    user.effects[PBEffects::ShellTrap] = true
    @battle.pbCommonAnimation("ShellTrap", user)
    @battle.pbDisplay(_INTL("{1} set a shell trap!", user.pbThis))
  end

  def pbDisplayUseMessage(user)
    super if user.tookPhysicalHit
  end

  def pbMoveFailed?(user, targets)
    if !user.effects[PBEffects::ShellTrap]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    if !user.tookPhysicalHit
      @battle.pbDisplay(_INTL("{1}'s shell trap didn't work!", user.pbThis))
      return true
    end
    return false
  end
end

#===============================================================================
# Power is doubled if a user's ally has already used this move this round. (Round)
# If an ally is about to use the same move, make it go next, ignoring priority.
#===============================================================================
class Battle::Move::UsedAfterAllyRoundWithDoublePower < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    baseDmg *= 2 if user.pbOwnSide.effects[PBEffects::Round]
    return baseDmg
  end

  def pbEffectGeneral(user)
    user.pbOwnSide.effects[PBEffects::Round] = true
    user.allAllies.each do |b|
      next if @battle.choices[b.index][0] != :UseMove || b.movedThisRound?
      next if @battle.choices[b.index][2].function != @function
      b.effects[PBEffects::MoveNext] = true
      b.effects[PBEffects::Quash]    = 0
      break
    end
  end
end

#===============================================================================
# Target moves immediately after the user, ignoring priority/speed. (After You)
#===============================================================================
class Battle::Move::TargetActsNext < Battle::Move
  def ignoresSubstitute?(user); return true; end

  def pbFailsAgainstTarget?(user, target, show_message)
    # Target has already moved this round
    return true if pbMoveFailedTargetAlreadyMoved?(target, show_message)
    # Target was going to move next anyway (somehow)
    if target.effects[PBEffects::MoveNext]
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    # Target didn't choose to use a move this round
    oppMove = @battle.choices[target.index][2]
    if !oppMove
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    target.effects[PBEffects::MoveNext] = true
    target.effects[PBEffects::Quash]    = 0
    @battle.pbDisplay(_INTL("{1} took the kind offer!", target.pbThis))
  end
end

#===============================================================================
# Target moves last this round, ignoring priority/speed. (Quash)
#===============================================================================
class Battle::Move::TargetActsLast < Battle::Move
  def pbFailsAgainstTarget?(user, target, show_message)
    return true if pbMoveFailedTargetAlreadyMoved?(target, show_message)
    # Target isn't going to use a move
    oppMove = @battle.choices[target.index][2]
    if !oppMove
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    # Target is already maximally Quashed and will move last anyway
    highestQuash = 0
    @battle.allBattlers.each do |b|
      next if b.effects[PBEffects::Quash] <= highestQuash
      highestQuash = b.effects[PBEffects::Quash]
    end
    if highestQuash > 0 && target.effects[PBEffects::Quash] == highestQuash
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    # Target was already going to move last
    if highestQuash == 0 && @battle.pbPriority.last.index == target.index
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    highestQuash = 0
    @battle.allBattlers.each do |b|
      next if b.effects[PBEffects::Quash] <= highestQuash
      highestQuash = b.effects[PBEffects::Quash]
    end
    target.effects[PBEffects::Quash]    = highestQuash + 1
    target.effects[PBEffects::MoveNext] = false
    @battle.pbDisplay(_INTL("{1}'s move was postponed!", target.pbThis))
  end
end

#===============================================================================
# The target uses its most recent move again. (Instruct)
#===============================================================================
class Battle::Move::TargetUsesItsLastUsedMoveAgain < Battle::Move
  def ignoresSubstitute?(user); return true; end

  def initialize(battle, move)
    super
    @moveBlacklist = [
      "MultiTurnAttackBideThenReturnDoubleDamage",   # Bide
      "ProtectUserFromDamagingMovesKingsShield",   # King's Shield
      "TargetUsesItsLastUsedMoveAgain",   # Instruct (this move)
      # Struggle
      "Struggle",   # Struggle
      # Moves that affect the moveset
      "ReplaceMoveThisBattleWithTargetLastMoveUsed",   # Mimic
      "ReplaceMoveWithTargetLastMoveUsed",   # Sketch
      "TransformUserIntoTarget",   # Transform
      # Moves that call other moves
      "UseLastMoveUsedByTarget",   # Mirror Move
      "UseLastMoveUsed",   # Copycat
      "UseMoveTargetIsAboutToUse",   # Me First
      "UseMoveDependingOnEnvironment",   # Nature Power
      "UseRandomUserMoveIfAsleep",   # Sleep Talk
      "UseRandomMoveFromUserParty",   # Assist
      "UseRandomMove",   # Metronome
      # Moves that require a recharge turn
      "AttackAndSkipNextTurn",   # Hyper Beam
      # Two-turn attacks
      "TwoTurnAttack",   # Razor Wind
      "TwoTurnAttackOneTurnInSun",   # Solar Beam, Solar Blade
      "TwoTurnAttackParalyzeTarget",   # Freeze Shock
      "TwoTurnAttackBurnTarget",   # Ice Burn
      "TwoTurnAttackFlinchTarget",   # Sky Attack
      "TwoTurnAttackChargeRaiseUserDefense1",   # Skull Bash
      "TwoTurnAttackInvulnerableInSky",   # Fly
      "TwoTurnAttackInvulnerableUnderground",   # Dig
      "TwoTurnAttackInvulnerableUnderwater",   # Dive
      "TwoTurnAttackInvulnerableInSkyParalyzeTarget",   # Bounce
      "TwoTurnAttackInvulnerableRemoveProtections",   # Shadow Force, Phantom Force
      "TwoTurnAttackInvulnerableInSkyTargetCannotAct",   # Sky Drop
      "AllBattlersLoseHalfHPUserSkipsNextTurn",   # Shadow Half
      "TwoTurnAttackRaiseUserSpAtkSpDefSpd2",   # Geomancy
      # Moves that start focussing at the start of the round
      "FailsIfUserDamagedThisTurn",   # Focus Punch
      "UsedAfterUserTakesPhysicalDamage",   # Shell Trap
      "BurnAttackerBeforeUserActs"   # Beak Blast
    ]
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    if !target.lastRegularMoveUsed || !target.pbHasMove?(target.lastRegularMoveUsed)
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    if target.usingMultiTurnAttack?
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    targetMove = @battle.choices[target.index][2]
    if targetMove && (targetMove.function == "FailsIfUserDamagedThisTurn" ||   # Focus Punch
                      targetMove.function == "UsedAfterUserTakesPhysicalDamage" ||   # Shell Trap
                      targetMove.function == "BurnAttackerBeforeUserActs")    # Beak Blast
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    if @moveBlacklist.include?(GameData::Move.get(target.lastRegularMoveUsed).function_code)
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    idxMove = -1
    target.eachMoveWithIndex do |m, i|
      idxMove = i if m.id == target.lastRegularMoveUsed
    end
    if target.moves[idxMove].pp == 0 && target.moves[idxMove].total_pp > 0
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    target.effects[PBEffects::Instruct] = true
  end
end

#===============================================================================
# For 5 rounds, for each priority bracket, slow Pokémon move before fast ones.
# (Trick Room)
#===============================================================================
class Battle::Move::StartSlowerBattlersActFirst < Battle::Move
  def pbEffectGeneral(user)
    if @battle.field.effects[PBEffects::TrickRoom] > 0
      @battle.field.effects[PBEffects::TrickRoom] = 0
      @battle.pbDisplay(_INTL("{1} reverted the dimensions!", user.pbThis))
    else
      @battle.field.effects[PBEffects::TrickRoom] = 5
      @battle.pbDisplay(_INTL("{1} twisted the dimensions!", user.pbThis))
    end
  end

  def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    return if @battle.field.effects[PBEffects::TrickRoom] > 0   # No animation
    super
  end
end

#===============================================================================
# If Grassy Terrain applies, priority is increased by 1. (Grassy Glide)
#===============================================================================
class Battle::Move::HigherPriorityInGrassyTerrain < Battle::Move
  def pbPriority(user)
    ret = super
    ret += 1 if @battle.field.terrain == :Grass && user.affectedByTerrain?
    return ret
  end
end

#===============================================================================
# Decreases the PP of the last attack used by the target by 3 (or as much as
# possible). (Eerie Spell)
#===============================================================================
class Battle::Move::LowerPPOfTargetLastMoveBy3 < Battle::Move
  def pbFailsAgainstTarget?(user, target, show_message)
    last_move = target.pbGetMoveWithID(target.lastRegularMoveUsed)
    if !last_move || last_move.pp == 0 || last_move.total_pp <= 0
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    last_move = target.pbGetMoveWithID(target.lastRegularMoveUsed)
    reduction = [3, last_move.pp].min
    target.pbSetPP(last_move, last_move.pp - reduction)
    @battle.pbDisplay(_INTL("It reduced the PP of {1}'s {2} by {3}!",
                            target.pbThis(true), last_move.name, reduction))
  end
end

#===============================================================================
# Target's last move used loses 4 PP. (Spite)
#===============================================================================
class Battle::Move::LowerPPOfTargetLastMoveBy4 < Battle::Move
  def ignoresSubstitute?(user); return true; end
  def canMagicCoat?;            return true; end

  def pbFailsAgainstTarget?(user, target, show_message)
    last_move = target.pbGetMoveWithID(target.lastRegularMoveUsed)
    if !last_move || last_move.pp == 0 || last_move.total_pp <= 0
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    last_move = target.pbGetMoveWithID(target.lastRegularMoveUsed)
    reduction = [4, last_move.pp].min
    target.pbSetPP(last_move, last_move.pp - reduction)
    @battle.pbDisplay(_INTL("It reduced the PP of {1}'s {2} by {3}!",
                            target.pbThis(true), last_move.name, reduction))
  end
end

#===============================================================================
# For 5 rounds, disables the last move the target used. (Disable)
#===============================================================================
class Battle::Move::DisableTargetLastMoveUsed < Battle::Move
  def ignoresSubstitute?(user); return true; end
  def canMagicCoat?;            return true; end

  def pbFailsAgainstTarget?(user, target, show_message)
    if target.effects[PBEffects::Disable] > 0 || !target.lastRegularMoveUsed
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return true if pbMoveFailedAromaVeil?(user, target, show_message)
    canDisable = false
    target.eachMove do |m|
      next if m.id != target.lastRegularMoveUsed
      next if m.pp == 0 && m.total_pp > 0
      canDisable = true
      break
    end
    if !canDisable
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    target.effects[PBEffects::Disable]     = 5
    target.effects[PBEffects::DisableMove] = target.lastRegularMoveUsed
    @battle.pbDisplay(_INTL("{1}'s {2} was disabled!", target.pbThis,
                            GameData::Move.get(target.lastRegularMoveUsed).name))
    target.pbItemStatusCureCheck
  end
end

#===============================================================================
# The target can no longer use the same move twice in a row. (Torment)
#===============================================================================
class Battle::Move::DisableTargetUsingSameMoveConsecutively < Battle::Move
  def ignoresSubstitute?(user); return true; end
  def canMagicCoat?;            return true; end

  def pbFailsAgainstTarget?(user, target, show_message)
    if target.effects[PBEffects::Torment]
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return true if pbMoveFailedAromaVeil?(user, target, show_message)
    return false
  end

  def pbEffectAgainstTarget(user, target)
    target.effects[PBEffects::Torment] = true
    @battle.pbDisplay(_INTL("{1} was subjected to torment!", target.pbThis))
    target.pbItemStatusCureCheck
  end
end

#===============================================================================
# For 4 rounds, the target must use the same move each round. (Encore)
#===============================================================================
class Battle::Move::DisableTargetUsingDifferentMove < Battle::Move
  def ignoresSubstitute?(user); return true; end
  def canMagicCoat?;            return true; end

  def initialize(battle, move)
    super
    @moveBlacklist = [
      "DisableTargetUsingDifferentMove",   # Encore
      # Struggle
      "Struggle",   # Struggle
      # Moves that affect the moveset
      "ReplaceMoveThisBattleWithTargetLastMoveUsed",   # Mimic
      "ReplaceMoveWithTargetLastMoveUsed",   # Sketch
      "TransformUserIntoTarget",   # Transform
      # Moves that call other moves (see also below)
      "UseLastMoveUsedByTarget"   # Mirror Move
    ]
    if Settings::MECHANICS_GENERATION >= 7
      @moveBlacklist += [
        # Moves that call other moves
#        "UseLastMoveUsedByTarget",   # Mirror Move                 # See above
        "UseLastMoveUsed",   # Copycat
        "UseMoveTargetIsAboutToUse",   # Me First
        "UseMoveDependingOnEnvironment",   # Nature Power
        "UseRandomUserMoveIfAsleep",   # Sleep Talk
        "UseRandomMoveFromUserParty",   # Assist
        "UseRandomMove"   # Metronome
      ]
    end
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    if target.effects[PBEffects::Encore] > 0
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    if !target.lastRegularMoveUsed ||
       @moveBlacklist.include?(GameData::Move.get(target.lastRegularMoveUsed).function_code)
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    if target.effects[PBEffects::ShellTrap]
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return true if pbMoveFailedAromaVeil?(user, target, show_message)
    canEncore = false
    target.eachMove do |m|
      next if m.id != target.lastRegularMoveUsed
      next if m.pp == 0 && m.total_pp > 0
      canEncore = true
      break
    end
    if !canEncore
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    target.effects[PBEffects::Encore]     = 4
    target.effects[PBEffects::EncoreMove] = target.lastRegularMoveUsed
    @battle.pbDisplay(_INTL("{1} received an encore!", target.pbThis))
    target.pbItemStatusCureCheck
  end
end

#===============================================================================
# For 4 rounds, disables the target's non-damaging moves. (Taunt)
#===============================================================================
class Battle::Move::DisableTargetStatusMoves < Battle::Move
  def ignoresSubstitute?(user); return true; end
  def canMagicCoat?;            return true; end

  def pbFailsAgainstTarget?(user, target, show_message)
    if target.effects[PBEffects::Taunt] > 0
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return true if pbMoveFailedAromaVeil?(user, target, show_message)
    if Settings::MECHANICS_GENERATION >= 6 && target.hasActiveAbility?(:OBLIVIOUS) &&
       !@battle.moldBreaker
      if show_message
        @battle.pbShowAbilitySplash(target)
        if Battle::Scene::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("But it failed!"))
        else
          @battle.pbDisplay(_INTL("But it failed because of {1}'s {2}!",
                                  target.pbThis(true), target.abilityName))
        end
        @battle.pbHideAbilitySplash(target)
      end
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    target.effects[PBEffects::Taunt] = 4
    @battle.pbDisplay(_INTL("{1} fell for the taunt!", target.pbThis))
    target.pbItemStatusCureCheck
  end
end

#===============================================================================
# For 5 rounds, disables the target's healing moves. (Heal Block)
#===============================================================================
class Battle::Move::DisableTargetHealingMoves < Battle::Move
  def canMagicCoat?; return true; end

  def pbFailsAgainstTarget?(user, target, show_message)
    if target.effects[PBEffects::HealBlock] > 0
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return true if pbMoveFailedAromaVeil?(user, target, show_message)
    return false
  end

  def pbEffectAgainstTarget(user, target)
    target.effects[PBEffects::HealBlock] = 5
    @battle.pbDisplay(_INTL("{1} was prevented from healing!", target.pbThis))
    target.pbItemStatusCureCheck
  end
end

#===============================================================================
# Target cannot use sound-based moves for 2 more rounds. (Throat Chop)
#===============================================================================
class Battle::Move::DisableTargetSoundMoves < Battle::Move
  def pbAdditionalEffect(user, target)
    return if target.fainted? || target.damageState.substitute
    if target.effects[PBEffects::ThroatChop] == 0
      @battle.pbDisplay(_INTL("The effects of {1} prevent {2} from using certain moves!",
                              @name, target.pbThis(true)))
    end
    target.effects[PBEffects::ThroatChop] = 3
  end
end

#===============================================================================
# Disables all target's moves that the user also knows. (Imprison)
#===============================================================================
class Battle::Move::DisableTargetMovesKnownByUser < Battle::Move
  def canSnatch?; return true; end

  def pbMoveFailed?(user, targets)
    if user.effects[PBEffects::Imprison]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.effects[PBEffects::Imprison] = true
    @battle.pbDisplay(_INTL("{1} sealed any moves its target shares with it!", user.pbThis))
  end
end
