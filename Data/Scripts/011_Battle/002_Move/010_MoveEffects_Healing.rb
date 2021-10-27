#===============================================================================
# Heals user to full HP. User falls asleep for 2 more rounds. (Rest)
#===============================================================================
class PokeBattle_Move_HealUserFullyAndFallAsleep < PokeBattle_HealingMove
  def pbMoveFailed?(user,targets)
    if user.asleep?
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return true if !user.pbCanSleep?(user,true,self,true)
    return true if super
    return false
  end

  def pbHealAmount(user)
    return user.totalhp-user.hp
  end

  def pbEffectGeneral(user)
    user.pbSleepSelf(_INTL("{1} slept and became healthy!",user.pbThis),3)
    super
  end
end

#===============================================================================
# Heals user by 1/2 of its max HP.
#===============================================================================
class PokeBattle_Move_HealUserHalfOfTotalHP < PokeBattle_HealingMove
  def pbHealAmount(user)
    return (user.totalhp/2.0).round
  end
end

#===============================================================================
# Heals user by an amount depending on the weather. (Moonlight, Morning Sun,
# Synthesis)
#===============================================================================
class PokeBattle_Move_HealUserDependingOnWeather < PokeBattle_HealingMove
  def pbOnStartUse(user,targets)
    case user.effectiveWeather
    when :Sun, :HarshSun
      @healAmount = (user.totalhp*2/3.0).round
    when :None, :StrongWinds
      @healAmount = (user.totalhp/2.0).round
    else
      @healAmount = (user.totalhp/4.0).round
    end
  end

  def pbHealAmount(user)
    return @healAmount
  end
end

#===============================================================================
# Heals user by 1/2 of its max HP, or 2/3 of its max HP in a sandstorm. (Shore Up)
#===============================================================================
class PokeBattle_Move_HealUserDependingOnSandstorm < PokeBattle_HealingMove
  def pbHealAmount(user)
    return (user.totalhp * 2 / 3.0).round if user.effectiveWeather == :Sandstorm
    return (user.totalhp / 2.0).round
  end
end

#===============================================================================
# Heals user by 1/2 of its max HP. (Roost)
# User roosts, and its Flying type is ignored for attacks used against it.
#===============================================================================
class PokeBattle_Move_HealUserHalfOfTotalHPLoseFlyingTypeThisTurn < PokeBattle_HealingMove
  def pbHealAmount(user)
    return (user.totalhp/2.0).round
  end

  def pbEffectGeneral(user)
    super
    user.effects[PBEffects::Roost] = true
  end
end

#===============================================================================
# Cures the target's permanent status problems. Heals user by 1/2 of its max HP.
# (Purify)
#===============================================================================
class PokeBattle_Move_CureTargetStatusHealUserHalfOfTotalHP < PokeBattle_HealingMove
  def canSnatch?;    return false; end   # Because it affects a target
  def canMagicCoat?; return true;  end

  def pbFailsAgainstTarget?(user, target, show_message)
    if target.status == :NONE
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end

  def pbHealAmount(user)
    return (user.totalhp/2.0).round
  end

  def pbEffectAgainstTarget(user,target)
    target.pbCureStatus
    super
  end
end

#===============================================================================
# Decreases the target's Attack by 1 stage. Heals user by an amount equal to the
# target's Attack stat (after applying stat stages, before this move decreases
# it). (Strength Sap)
#===============================================================================
class PokeBattle_Move_HealUserByTargetAttackLowerTargetAttack1 < PokeBattle_Move
  def healingMove?;  return true; end
  def canMagicCoat?; return true; end

  def pbFailsAgainstTarget?(user, target, show_message)
    # NOTE: The official games appear to just check whether the target's Attack
    #       stat stage is -6 and fail if so, but I've added the "fail if target
    #       has Contrary and is at +6" check too for symmetry. This move still
    #       works even if the stat stage cannot be changed due to an ability or
    #       other effect.
    if !@battle.moldBreaker && target.hasActiveAbility?(:CONTRARY) &&
       target.statStageAtMax?(:ATTACK)
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    elsif target.statStageAtMin?(:ATTACK)
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    # Calculate target's effective attack value
    stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
    stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
    atk      = target.attack
    atkStage = target.stages[:ATTACK]+6
    healAmt = (atk.to_f*stageMul[atkStage]/stageDiv[atkStage]).floor
    # Reduce target's Attack stat
    if target.pbCanLowerStatStage?(:ATTACK,user,self)
      target.pbLowerStatStage(:ATTACK,1,user)
    end
    # Heal user
    if target.hasActiveAbility?(:LIQUIDOOZE)
      @battle.pbShowAbilitySplash(target)
      user.pbReduceHP(healAmt)
      @battle.pbDisplay(_INTL("{1} sucked up the liquid ooze!",user.pbThis))
      @battle.pbHideAbilitySplash(target)
      user.pbItemHPHealCheck
    elsif user.canHeal?
      healAmt = (healAmt*1.3).floor if user.hasActiveItem?(:BIGROOT)
      user.pbRecoverHP(healAmt)
      @battle.pbDisplay(_INTL("{1}'s HP was restored.",user.pbThis))
    end
  end
end

#===============================================================================
# User gains half the HP it inflicts as damage.
#===============================================================================
class PokeBattle_Move_HealUserByHalfOfDamageDone < PokeBattle_Move
  def healingMove?; return Settings::MECHANICS_GENERATION >= 6; end

  def pbEffectAgainstTarget(user,target)
    return if target.damageState.hpLost<=0
    hpGain = (target.damageState.hpLost/2.0).round
    user.pbRecoverHPFromDrain(hpGain,target)
  end
end

#===============================================================================
# User gains half the HP it inflicts as damage. Fails if target is not asleep.
# (Dream Eater)
#===============================================================================
class PokeBattle_Move_HealUserByHalfOfDamageDoneIfTargetAsleep < PokeBattle_Move
  def healingMove?; return Settings::MECHANICS_GENERATION >= 6; end

  def pbFailsAgainstTarget?(user, target, show_message)
    if !target.asleep?
      @battle.pbDisplay(_INTL("{1} wasn't affected!", target.pbThis)) if show_message
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    return if target.damageState.hpLost<=0
    hpGain = (target.damageState.hpLost/2.0).round
    user.pbRecoverHPFromDrain(hpGain,target)
  end
end

#===============================================================================
# User gains 3/4 the HP it inflicts as damage. (Draining Kiss, Oblivion Wing)
#===============================================================================
class PokeBattle_Move_HealUserByThreeQuartersOfDamageDone < PokeBattle_Move
  def healingMove?; return Settings::MECHANICS_GENERATION >= 6; end

  def pbEffectAgainstTarget(user,target)
    return if target.damageState.hpLost<=0
    hpGain = (target.damageState.hpLost*0.75).round
    user.pbRecoverHPFromDrain(hpGain,target)
  end
end

#===============================================================================
# The user and its allies gain 25% of their total HP. (Life Dew)
#===============================================================================
class PokeBattle_Move_HealUserAndAlliesQuarterOfTotalHP < PokeBattle_Move
  def healingMove?; return true; end

  def pbMoveFailed?(user, targets)
    if @battle.allSameSideBattlers(user).none? { |b| b.canHeal? }
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    return !target.canHeal?
  end

  def pbEffectAgainstTarget(user, target)
    target.pbRecoverHP(target.totalhp / 4)
    @battle.pbDisplay(_INTL("{1}'s HP was restored.", target.pbThis))
  end
end

#===============================================================================
# The user and its allies gain 25% of their total HP and are cured of their
# permanent status problems. (Jungle Healing)
#===============================================================================
class PokeBattle_Move_HealUserAndAlliesQuarterOfTotalHPCureStatus < PokeBattle_Move
  def healingMove?; return true; end

  def pbMoveFailed?(user, targets)
    if @battle.allSameSideBattlers(user).none? { |b| b.canHeal? || b.status != :NONE }
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    return target.status == :NONE && !target.canHeal?
  end

  def pbEffectAgainstTarget(user, target)
    if target.canHeal?
      target.pbRecoverHP(target.totalhp / 4)
      @battle.pbDisplay(_INTL("{1}'s HP was restored.", target.pbThis))
    end
    if target.status != :NONE
      old_status = target.status
      target.pbCureStatus(false)
      case old_status
      when :SLEEP
        @battle.pbDisplay(_INTL("{1} was woken from sleep.", target.pbThis))
      when :POISON
        @battle.pbDisplay(_INTL("{1} was cured of its poisoning.", target.pbThis))
      when :BURN
        @battle.pbDisplay(_INTL("{1}'s burn was healed.", target.pbThis))
      when :PARALYSIS
        @battle.pbDisplay(_INTL("{1} was cured of paralysis.", target.pbThis))
      when :FROZEN
        @battle.pbDisplay(_INTL("{1} was thawed out.", target.pbThis))
      end
    end
  end
end

#===============================================================================
# Heals target by 1/2 of its max HP. (Heal Pulse)
#===============================================================================
class PokeBattle_Move_HealTargetHalfOfTotalHP < PokeBattle_Move
  def healingMove?;  return true; end
  def canMagicCoat?; return true; end

  def pbFailsAgainstTarget?(user, target, show_message)
    if target.hp==target.totalhp
      @battle.pbDisplay(_INTL("{1}'s HP is full!", target.pbThis)) if show_message
      return true
    elsif !target.canHeal?
      @battle.pbDisplay(_INTL("{1} is unaffected!", target.pbThis)) if show_message
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    hpGain = (target.totalhp/2.0).round
    if pulseMove? && user.hasActiveAbility?(:MEGALAUNCHER)
      hpGain = (target.totalhp*3/4.0).round
    end
    target.pbRecoverHP(hpGain)
    @battle.pbDisplay(_INTL("{1}'s HP was restored.",target.pbThis))
  end
end

#===============================================================================
# Heals target by 1/2 of its max HP, or 2/3 of its max HP in Grassy Terrain.
# (Floral Healing)
#===============================================================================
class PokeBattle_Move_HealTargetDependingOnGrassyTerrain < PokeBattle_Move
  def healingMove?;  return true; end
  def canMagicCoat?; return true; end

  def pbFailsAgainstTarget?(user, target, show_message)
    if target.hp==target.totalhp
      @battle.pbDisplay(_INTL("{1}'s HP is full!", target.pbThis)) if show_message
      return true
    elsif !target.canHeal?
      @battle.pbDisplay(_INTL("{1} is unaffected!", target.pbThis)) if show_message
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    hpGain = (target.totalhp/2.0).round
    hpGain = (target.totalhp*2/3.0).round if @battle.field.terrain == :Grassy
    target.pbRecoverHP(hpGain)
    @battle.pbDisplay(_INTL("{1}'s HP was restored.",target.pbThis))
  end
end

#===============================================================================
# Battler in user's position is healed by 1/2 of its max HP, at the end of the
# next round. (Wish)
#===============================================================================
class PokeBattle_Move_HealUserPositionNextTurn < PokeBattle_Move
  def healingMove?; return true; end
  def canSnatch?;   return true; end

  def pbMoveFailed?(user,targets)
    if @battle.positions[user.index].effects[PBEffects::Wish]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.positions[user.index].effects[PBEffects::Wish]       = 2
    @battle.positions[user.index].effects[PBEffects::WishAmount] = (user.totalhp/2.0).round
    @battle.positions[user.index].effects[PBEffects::WishMaker]  = user.pokemonIndex
  end
end

#===============================================================================
# Rings the user. Ringed Pokémon gain 1/16 of max HP at the end of each round.
# (Aqua Ring)
#===============================================================================
class PokeBattle_Move_StartHealUserEachTurn < PokeBattle_Move
  def canSnatch?; return true; end

  def pbMoveFailed?(user,targets)
    if user.effects[PBEffects::AquaRing]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.effects[PBEffects::AquaRing] = true
    @battle.pbDisplay(_INTL("{1} surrounded itself with a veil of water!",user.pbThis))
  end
end

#===============================================================================
# Ingrains the user. Ingrained Pokémon gain 1/16 of max HP at the end of each
# round, and cannot flee or switch out. (Ingrain)
#===============================================================================
class PokeBattle_Move_StartHealUserEachTurnTrapUserInBattle < PokeBattle_Move
  def canSnatch?; return true; end

  def pbMoveFailed?(user,targets)
    if user.effects[PBEffects::Ingrain]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.effects[PBEffects::Ingrain] = true
    @battle.pbDisplay(_INTL("{1} planted its roots!",user.pbThis))
  end
end

#===============================================================================
# Target will lose 1/4 of max HP at end of each round, while asleep. (Nightmare)
#===============================================================================
class PokeBattle_Move_StartDamageTargetEachTurnIfTargetAsleep < PokeBattle_Move
  def pbFailsAgainstTarget?(user, target, show_message)
    if !target.asleep? || target.effects[PBEffects::Nightmare]
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    target.effects[PBEffects::Nightmare] = true
    @battle.pbDisplay(_INTL("{1} began having a nightmare!",target.pbThis))
  end
end

#===============================================================================
# Seeds the target. Seeded Pokémon lose 1/8 of max HP at the end of each round,
# and the Pokémon in the user's position gains the same amount. (Leech Seed)
#===============================================================================
class PokeBattle_Move_StartLeechSeedTarget < PokeBattle_Move
  def canMagicCoat?; return true; end

  def pbFailsAgainstTarget?(user, target, show_message)
    if target.effects[PBEffects::LeechSeed]>=0
      @battle.pbDisplay(_INTL("{1} evaded the attack!", target.pbThis)) if show_message
      return true
    end
    if target.pbHasType?(:GRASS)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true))) if show_message
      return true
    end
    return false
  end

  def pbMissMessage(user,target)
    @battle.pbDisplay(_INTL("{1} evaded the attack!",target.pbThis))
    return true
  end

  def pbEffectAgainstTarget(user,target)
    target.effects[PBEffects::LeechSeed] = user.index
    @battle.pbDisplay(_INTL("{1} was seeded!",target.pbThis))
  end
end

#===============================================================================
# The user takes damage equal to 1/2 of its total HP, even if the target is
# unaffected (this is not recoil damage). (Steel Beam)
#===============================================================================
class PokeBattle_Move_UserLosesHalfOfTotalHP < PokeBattle_Move
  def pbEffectAfterAllHits(user, target)
    return if !user.takesIndirectDamage?
    amt = (user.totalhp / 2.0).ceil
    amt = 1 if amt < 1
    user.pbReduceHP(amt, false)
    @battle.pbDisplay(_INTL("{1} is damaged by recoil!", user.pbThis))
    user.pbItemHPHealCheck
  end
end

#===============================================================================
# Damages user by 1/2 of its max HP, even if this move misses. (Mind Blown)
#===============================================================================
class PokeBattle_Move_UserLosesHalfOfTotalHPExplosive < PokeBattle_Move
  def worksWithNoTargets?; return true; end

  def pbMoveFailed?(user,targets)
    if !@battle.moldBreaker
      bearer = @battle.pbCheckGlobalAbility(:DAMP)
      if bearer!=nil
        @battle.pbShowAbilitySplash(bearer)
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("{1} cannot use {2}!",user.pbThis,@name))
        else
          @battle.pbDisplay(_INTL("{1} cannot use {2} because of {3}'s {4}!",
             user.pbThis,@name,bearer.pbThis(true),bearer.abilityName))
        end
        @battle.pbHideAbilitySplash(bearer)
        return true
      end
    end
    return false
  end

  def pbSelfKO(user)
    return if !user.takesIndirectDamage?
    user.pbReduceHP((user.totalhp/2.0).round,false)
    user.pbItemHPHealCheck
  end
end

#===============================================================================
# User faints, even if the move does nothing else. (Explosion, Self-Destruct)
#===============================================================================
class PokeBattle_Move_UserFaintsExplosive < PokeBattle_Move
  def worksWithNoTargets?;     return true; end
  def pbNumHits(user,targets); return 1;    end

  def pbMoveFailed?(user,targets)
    if !@battle.moldBreaker
      bearer = @battle.pbCheckGlobalAbility(:DAMP)
      if bearer!=nil
        @battle.pbShowAbilitySplash(bearer)
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("{1} cannot use {2}!",user.pbThis,@name))
        else
          @battle.pbDisplay(_INTL("{1} cannot use {2} because of {3}'s {4}!",
             user.pbThis,@name,bearer.pbThis(true),bearer.abilityName))
        end
        @battle.pbHideAbilitySplash(bearer)
        return true
      end
    end
    return false
  end

  def pbSelfKO(user)
    return if user.fainted?
    user.pbReduceHP(user.hp,false)
    user.pbItemHPHealCheck
  end
end

#===============================================================================
# User faints. If Misty Terrain applies, base power is multiplied by 1.5.
# (Misty Explosion)
#===============================================================================
class PokeBattle_Move_UserFaintsPowersUpInMistyTerrainExplosive < PokeBattle_Move_UserFaintsExplosive
  def pbBaseDamage(baseDmg, user, target)
    baseDmg = baseDmg * 3 / 2 if @battle.field.terrain == :Misty
    return baseDmg
  end
end

#===============================================================================
# Inflicts fixed damage equal to user's current HP. (Final Gambit)
# User faints (if successful).
#===============================================================================
class PokeBattle_Move_UserFaintsFixedDamageUserHP < PokeBattle_FixedDamageMove
  def pbNumHits(user,targets); return 1; end

  def pbOnStartUse(user,targets)
    @finalGambitDamage = user.hp
  end

  def pbFixedDamage(user,target)
    return @finalGambitDamage
  end

  def pbSelfKO(user)
    return if user.fainted?
    user.pbReduceHP(user.hp,false)
    user.pbItemHPHealCheck
  end
end

#===============================================================================
# Decreases the target's Attack and Special Attack by 2 stages each. (Memento)
# User faints (if successful).
#===============================================================================
class PokeBattle_Move_UserFaintsLowerTargetAtkSpAtk2 < PokeBattle_TargetMultiStatDownMove
  def canMagicCoat?; return false; end

  def initialize(battle,move)
    super
    @statDown = [:ATTACK,2,:SPECIAL_ATTACK,2]
  end

  # NOTE: The user faints even if the target's stats cannot be changed, so this
  #       method must always return false to allow the move's usage to continue.
  def pbFailsAgainstTarget?(user, target, show_message)
    return false
  end

  def pbSelfKO(user)
    return if user.fainted?
    user.pbReduceHP(user.hp,false)
    user.pbItemHPHealCheck
  end
end

#===============================================================================
# User faints. The Pokémon that replaces the user is fully healed (HP and
# status). Fails if user won't be replaced. (Healing Wish)
#===============================================================================
class PokeBattle_Move_UserFaintsHealAndCureReplacement < PokeBattle_Move
  def healingMove?; return true; end
  def canSnatch?;   return true; end

  def pbMoveFailed?(user,targets)
    if !@battle.pbCanChooseNonActive?(user.index)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbSelfKO(user)
    return if user.fainted?
    user.pbReduceHP(user.hp,false)
    user.pbItemHPHealCheck
    @battle.positions[user.index].effects[PBEffects::HealingWish] = true
  end
end

#===============================================================================
# User faints. The Pokémon that replaces the user is fully healed (HP, PP and
# status). Fails if user won't be replaced. (Lunar Dance)
#===============================================================================
class PokeBattle_Move_UserFaintsHealAndCureReplacementRestorePP < PokeBattle_Move
  def healingMove?; return true; end
  def canSnatch?;   return true; end

  def pbMoveFailed?(user,targets)
    if !@battle.pbCanChooseNonActive?(user.index)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbSelfKO(user)
    return if user.fainted?
    user.pbReduceHP(user.hp,false)
    user.pbItemHPHealCheck
    @battle.positions[user.index].effects[PBEffects::LunarDance] = true
  end
end

#===============================================================================
# All current battlers will perish after 3 more rounds. (Perish Song)
#===============================================================================
class PokeBattle_Move_StartPerishCountsForAllBattlers < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    failed = true
    targets.each do |b|
      next if b.effects[PBEffects::PerishSong]>0   # Heard it before
      failed = false
      break
    end
    if failed
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    return target.effects[PBEffects::PerishSong]>0   # Heard it before
  end

  def pbEffectAgainstTarget(user,target)
    target.effects[PBEffects::PerishSong]     = 4
    target.effects[PBEffects::PerishSongUser] = user.index
  end

  def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
    super
    @battle.pbDisplay(_INTL("All Pokémon that hear the song will faint in three turns!"))
  end
end

#===============================================================================
# If user is KO'd before it next moves, the battler that caused it also faints.
# (Destiny Bond)
#===============================================================================
class PokeBattle_Move_AttackerFaintsIfUserFaints < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if Settings::MECHANICS_GENERATION >= 7 && user.effects[PBEffects::DestinyBondPrevious]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.effects[PBEffects::DestinyBond] = true
    @battle.pbDisplay(_INTL("{1} is hoping to take its attacker down with it!",user.pbThis))
  end
end

#===============================================================================
# If user is KO'd before it next moves, the attack that caused it loses all PP.
# (Grudge)
#===============================================================================
class PokeBattle_Move_SetAttackerMovePPTo0IfUserFaints < PokeBattle_Move
  def pbEffectGeneral(user)
    user.effects[PBEffects::Grudge] = true
    @battle.pbDisplay(_INTL("{1} wants its target to bear a grudge!",user.pbThis))
  end
end
