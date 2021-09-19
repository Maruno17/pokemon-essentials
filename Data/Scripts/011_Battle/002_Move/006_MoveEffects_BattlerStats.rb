#===============================================================================
# Increases the user's Attack by 1 stage.
#===============================================================================
class PokeBattle_Move_RaiseUserAttack1 < PokeBattle_StatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,1]
  end
end

#===============================================================================
# Increases the user's Attack by 2 stages. (Swords Dance)
#===============================================================================
class PokeBattle_Move_RaiseUserAttack2 < PokeBattle_StatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,2]
  end
end

#===============================================================================
# Increases the user's Attack by 3 stages.
#===============================================================================
class PokeBattle_Move_RaiseUserAttack3 < PokeBattle_StatUpMove
  def initialize(battle, move)
    super
    @statUp = [:ATTACK, 3]
  end
end

#===============================================================================
# If this move KO's the target, increases the user's Attack by 3 stages.
# (Fell Stinger)
#===============================================================================
class PokeBattle_Move_RaiseUserAttack3IfTargetFaints < PokeBattle_Move
  def pbEffectAfterAllHits(user,target)
    return if !target.damageState.fainted
    return if !user.pbCanRaiseStatStage?(:ATTACK,user,self)
    user.pbRaiseStatStage(:ATTACK,3,user)
  end
end

#===============================================================================
# Reduces the user's HP by half of max, and sets its Attack to maximum.
# (Belly Drum)
#===============================================================================
class PokeBattle_Move_MaxUserAttackLoseHalfOfTotalHP < PokeBattle_Move
  def canSnatch?; return true; end

  def pbMoveFailed?(user,targets)
    hpLoss = [user.totalhp/2,1].max
    if user.hp<=hpLoss
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return true if !user.pbCanRaiseStatStage?(:ATTACK,user,self,true)
    return false
  end

  def pbEffectGeneral(user)
    hpLoss = [user.totalhp/2,1].max
    user.pbReduceHP(hpLoss, false, false)
    if user.hasActiveAbility?(:CONTRARY)
      user.stages[:ATTACK] = -6
      user.statsLowered = true
      @battle.pbCommonAnimation("StatDown",user)
      @battle.pbDisplay(_INTL("{1} cut its own HP and minimized its Attack!",user.pbThis))
    else
      user.stages[:ATTACK] = 6
      user.statsRaised = true
      @battle.pbCommonAnimation("StatUp",user)
      @battle.pbDisplay(_INTL("{1} cut its own HP and maximized its Attack!",user.pbThis))
    end
    user.pbItemHPHealCheck
  end
end

#===============================================================================
# Increases the user's Defense by 1 stage. (Harden, Steel Wing, Withdraw)
#===============================================================================
class PokeBattle_Move_RaiseUserDefense1 < PokeBattle_StatUpMove
  def initialize(battle,move)
    super
    @statUp = [:DEFENSE,1]
  end
end

#===============================================================================
# Increases the user's Defense by 1 stage. User curls up. (Defense Curl)
#===============================================================================
class PokeBattle_Move_RaiseUserDefense1CurlUpUser < PokeBattle_StatUpMove
  def initialize(battle,move)
    super
    @statUp = [:DEFENSE,1]
  end

  def pbEffectGeneral(user)
    user.effects[PBEffects::DefenseCurl] = true
    super
  end
end

#===============================================================================
# Increases the user's Defense by 2 stages. (Acid Armor, Barrier, Iron Defense)
#===============================================================================
class PokeBattle_Move_RaiseUserDefense2 < PokeBattle_StatUpMove
  def initialize(battle,move)
    super
    @statUp = [:DEFENSE,2]
  end
end

#===============================================================================
# Increases the user's Defense by 3 stages. (Cotton Guard)
#===============================================================================
class PokeBattle_Move_RaiseUserDefense3 < PokeBattle_StatUpMove
  def initialize(battle,move)
    super
    @statUp = [:DEFENSE,3]
  end
end

#===============================================================================
# Increases the user's Special Attack by 1 stage. (Charge Beam, Fiery Dance)
#===============================================================================
class PokeBattle_Move_RaiseUserSpAtk1 < PokeBattle_StatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPECIAL_ATTACK,1]
  end
end

#===============================================================================
# Increases the user's Special Attack by 2 stages. (Nasty Plot)
#===============================================================================
class PokeBattle_Move_RaiseUserSpAtk2 < PokeBattle_StatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPECIAL_ATTACK,2]
  end
end

#===============================================================================
# Increases the user's Special Attack by 3 stages. (Tail Glow)
#===============================================================================
class PokeBattle_Move_RaiseUserSpAtk3 < PokeBattle_StatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPECIAL_ATTACK,3]
  end
end

#===============================================================================
# Increases the user's Special Defense by 1 stage.
#===============================================================================
class PokeBattle_Move_RaiseUserSpDef1 < PokeBattle_StatUpMove
  def initialize(battle, move)
    super
    @statUp = [:SPECIAL_DEFENSE, 1]
  end
end

#===============================================================================
# Increases the user's Special Defense by 1 stage.
# Charges up user's next attack if it is Electric-type. (Charge)
#===============================================================================
class PokeBattle_Move_RaiseUserSpDef1PowerUpElectricMove < PokeBattle_StatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPECIAL_DEFENSE,1]
  end

  def pbEffectGeneral(user)
    user.effects[PBEffects::Charge] = 2
    @battle.pbDisplay(_INTL("{1} began charging power!",user.pbThis))
    super
  end
end

#===============================================================================
# Increases the user's Special Defense by 2 stages. (Amnesia)
#===============================================================================
class PokeBattle_Move_RaiseUserSpDef2 < PokeBattle_StatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPECIAL_DEFENSE,2]
  end
end

#===============================================================================
# Increases the user's Special Defense by 3 stages.
#===============================================================================
class PokeBattle_Move_RaiseUserSpDef3 < PokeBattle_StatUpMove
  def initialize(battle, move)
    super
    @statUp = [:SPECIAL_DEFENSE, 3]
  end
end

#===============================================================================
# Increases the user's Speed by 1 stage. (Flame Charge)
#===============================================================================
class PokeBattle_Move_RaiseUserSpeed1 < PokeBattle_StatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPEED,1]
  end
end

#===============================================================================
# Increases the user's Speed by 2 stages. (Agility, Rock Polish)
#===============================================================================
class PokeBattle_Move_RaiseUserSpeed2 < PokeBattle_StatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPEED,2]
  end
end

#===============================================================================
# Increases the user's Speed by 2 stages. Lowers user's weight by 100kg.
# (Autotomize)
#===============================================================================
class PokeBattle_Move_RaiseUserSpeed2LowerUserWeight < PokeBattle_StatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPEED,2]
  end

  def pbEffectGeneral(user)
    if user.pbWeight+user.effects[PBEffects::WeightChange]>1
      user.effects[PBEffects::WeightChange] -= 1000
      @battle.pbDisplay(_INTL("{1} became nimble!",user.pbThis))
    end
    super
  end
end

#===============================================================================
# Increases the user's Speed by 3 stages.
#===============================================================================
class PokeBattle_Move_RaiseUserSpeed3 < PokeBattle_StatUpMove
  def initialize(battle, move)
    super
    @statUp = [:SPEED, 3]
  end
end

#===============================================================================
# Increases the user's accuracy by 1 stage.
#===============================================================================
class PokeBattle_Move_RaiseUserAccuracy1 < PokeBattle_StatUpMove
  def initialize(battle, move)
    super
    @statUp = [:ACCURACY, 1]
  end
end

#===============================================================================
# Increases the user's accuracy by 2 stages.
#===============================================================================
class PokeBattle_Move_RaiseUserAccuracy2 < PokeBattle_StatUpMove
  def initialize(battle, move)
    super
    @statUp = [:ACCURACY, 2]
  end
end

#===============================================================================
# Increases the user's accuracy by 3 stages.
#===============================================================================
class PokeBattle_Move_RaiseUserAccuracy3 < PokeBattle_StatUpMove
  def initialize(battle, move)
    super
    @statUp = [:ACCURACY, 3]
  end
end

#===============================================================================
# Increases the user's evasion by 1 stage. (Double Team)
#===============================================================================
class PokeBattle_Move_RaiseUserEvasion1 < PokeBattle_StatUpMove
  def initialize(battle,move)
    super
    @statUp = [:EVASION,1]
  end
end

#===============================================================================
# Increases the user's evasion by 2 stages.
#===============================================================================
class PokeBattle_Move_RaiseUserEvasion2 < PokeBattle_StatUpMove
  def initialize(battle, move)
    super
    @statUp = [:EVASION, 2]
  end
end

#===============================================================================
# Increases the user's evasion by 2 stages. Minimizes the user. (Minimize)
#===============================================================================
class PokeBattle_Move_RaiseUserEvasion2MinimizeUser < PokeBattle_StatUpMove
  def initialize(battle,move)
    super
    @statUp = [:EVASION,2]
  end

  def pbEffectGeneral(user)
    user.effects[PBEffects::Minimize] = true
    super
  end
end

#===============================================================================
# Increases the user's evasion by 3 stages.
#===============================================================================
class PokeBattle_Move_RaiseUserEvasion3 < PokeBattle_StatUpMove
  def initialize(battle, move)
    super
    @statUp = [:EVASION, 3]
  end
end

#===============================================================================
# Increases the user's critical hit rate. (Focus Energy)
#===============================================================================
class PokeBattle_Move_RaiseUserCriticalHitRate2 < PokeBattle_Move
  def canSnatch?; return true; end

  def pbMoveFailed?(user,targets)
    if user.effects[PBEffects::FocusEnergy]>=2
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.effects[PBEffects::FocusEnergy] = 2
    @battle.pbDisplay(_INTL("{1} is getting pumped!",user.pbThis))
  end
end

#===============================================================================
# Increases the user's Attack and Defense by 1 stage each. (Bulk Up)
#===============================================================================
class PokeBattle_Move_RaiseUserAtkDef1 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,1,:DEFENSE,1]
  end
end

#===============================================================================
# Increases the user's Attack, Defense and accuracy by 1 stage each. (Coil)
#===============================================================================
class PokeBattle_Move_RaiseUserAtkDefAcc1 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,1,:DEFENSE,1,:ACCURACY,1]
  end
end

#===============================================================================
# Increases the user's Attack and Special Attack by 1 stage each. (Work Up)
#===============================================================================
class PokeBattle_Move_RaiseUserAtkSpAtk1 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,1,:SPECIAL_ATTACK,1]
  end
end

#===============================================================================
# Increases the user's Attack and Sp. Attack by 1 stage each.
# In sunny weather, increases are 2 stages each instead. (Growth)
#===============================================================================
class PokeBattle_Move_RaiseUserAtkSpAtk1Or2InSun < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,1,:SPECIAL_ATTACK,1]
  end

  def pbOnStartUse(user,targets)
    increment = 1
    increment = 2 if [:Sun, :HarshSun].include?(user.effectiveWeather)
    @statUp[1] = @statUp[3] = increment
  end
end

#===============================================================================
# Decreases the user's Defense and Special Defense by 1 stage each.
# Increases the user's Attack, Speed and Special Attack by 2 stages each.
# (Shell Smash)
#===============================================================================
class PokeBattle_Move_LowerUserDefSpDef1RaiseUserAtkSpAtkSpd2 < PokeBattle_Move
  def canSnatch?; return true; end

  def initialize(battle,move)
    super
    @statUp   = [:ATTACK,2,:SPECIAL_ATTACK,2,:SPEED,2]
    @statDown = [:DEFENSE,1,:SPECIAL_DEFENSE,1]
  end

  def pbMoveFailed?(user,targets)
    failed = true
    for i in 0...@statUp.length/2
      if user.pbCanRaiseStatStage?(@statUp[i*2],user,self)
        failed = false
        break
      end
    end
    for i in 0...@statDown.length/2
      if user.pbCanLowerStatStage?(@statDown[i*2],user,self)
        failed = false
        break
      end
    end
    if failed
      @battle.pbDisplay(_INTL("{1}'s stats can't be changed further!",user.pbThis))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    showAnim = true
    for i in 0...@statDown.length/2
      next if !user.pbCanLowerStatStage?(@statDown[i*2],user,self)
      if user.pbLowerStatStage(@statDown[i*2],@statDown[i*2+1],user,showAnim)
        showAnim = false
      end
    end
    showAnim = true
    for i in 0...@statUp.length/2
      next if !user.pbCanRaiseStatStage?(@statUp[i*2],user,self)
      if user.pbRaiseStatStage(@statUp[i*2],@statUp[i*2+1],user,showAnim)
        showAnim = false
      end
    end
  end
end

#===============================================================================
# Increases the user's Attack and Speed by 1 stage each. (Dragon Dance)
#===============================================================================
class PokeBattle_Move_RaiseUserAtkSpd1 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,1,:SPEED,1]
  end
end

#===============================================================================
# Increases the user's Speed by 2 stages, and its Attack by 1 stage. (Shift Gear)
#===============================================================================
class PokeBattle_Move_RaiseUserAtk1Spd2 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPEED,2,:ATTACK,1]
  end
end

#===============================================================================
# Increases the user's Attack and accuracy by 1 stage each. (Hone Claws)
#===============================================================================
class PokeBattle_Move_RaiseUserAtkAcc1 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,1,:ACCURACY,1]
  end
end

#===============================================================================
# Increases the user's Defense and Special Defense by 1 stage each.
# (Cosmic Power, Defend Order)
#===============================================================================
class PokeBattle_Move_RaiseUserDefSpDef1 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:DEFENSE,1,:SPECIAL_DEFENSE,1]
  end
end

#===============================================================================
# Increases the user's Sp. Attack and Sp. Defense by 1 stage each. (Calm Mind)
#===============================================================================
class PokeBattle_Move_RaiseUserSpAtkSpDef1 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPECIAL_ATTACK,1,:SPECIAL_DEFENSE,1]
  end
end

#===============================================================================
# Increases the user's Sp. Attack, Sp. Defense and Speed by 1 stage each.
# (Quiver Dance)
#===============================================================================
class PokeBattle_Move_RaiseUserSpAtkSpDefSpd1 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPECIAL_ATTACK,1,:SPECIAL_DEFENSE,1,:SPEED,1]
  end
end

#===============================================================================
# Increases the user's Attack, Defense, Speed, Special Attack and Special Defense
# by 1 stage each. (Ancient Power, Ominous Wind, Silver Wind)
#===============================================================================
class PokeBattle_Move_RaiseUserMainStats1 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,1,:DEFENSE,1,:SPECIAL_ATTACK,1,:SPECIAL_DEFENSE,1,:SPEED,1]
  end
end

#===============================================================================
# Increases the user's Attack, Defense, Special Attack, Special Defense and
# Speed by 1 stage each, and reduces the user's HP by a third of its total HP.
# Fails if it can't do either effect. (Clangorous Soul)
#===============================================================================
class PokeBattle_Move_RaiseUserMainStats1LoseThirdOfTotalHP < PokeBattle_MultiStatUpMove
  def initialize(battle, move)
    super
    @statUp = [
      :ATTACK, 1,
      :DEFENSE, 1,
      :SPECIAL_ATTACK, 1,
      :SPECIAL_DEFENSE, 1,
      :SPEED, 1
    ]
  end

  def pbMoveFailed?(user, targets)
    if user.hp <= [user.totalhp / 3, 1].max
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return super
  end

  def pbEffectGeneral(user)
    super
    user.pbReduceHP([user.totalhp / 3, 1].max, false)
    user.pbItemHPHealCheck
  end
end

#===============================================================================
# Increases the user's Attack, Defense, Speed, Special Attack and Special
# Defense by 1 stage each. The user cannot switch out or flee. Fails if the user
# is already affected by the second effect of this move, but can be used if the
# user is prevented from switching out or fleeing by another effect (in which
# case, the second effect of this move is not applied to the user). The user may
# still switch out if holding Shed Shell or Eject Button, or if affected by a
# Red Card. (No Retreat)
#===============================================================================
class PokeBattle_Move_RaiseUserMainStats1TrapUserInBattle < PokeBattle_Move_RaiseUserMainStats1
  def pbMoveFailed?(user, targets)
    if user.effects[PBEffects::NoRetreat]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return super
  end

  def pbEffectGeneral(user)
    super
    if !user.trappedInBattle?
      user.effects[PBEffects::NoRetreat] = true
      @battle.pbDisplay(_INTL("{1} can no longer escape because it used {2}!", user.pbThis, @name))
    end
  end
end

#===============================================================================
# User rages until the start of a round in which they don't use this move. (Rage)
# (Handled in Battler's pbProcessMoveAgainstTarget): Ups rager's Attack by 1
# stage each time it loses HP due to a move.
#===============================================================================
class PokeBattle_Move_StartRaiseUserAtk1WhenDamaged < PokeBattle_Move
  def pbEffectGeneral(user)
    user.effects[PBEffects::Rage] = true
  end
end

#===============================================================================
# Decreases the user's Attack by 1 stage.
#===============================================================================
class PokeBattle_Move_LowerUserAttack1 < PokeBattle_StatDownMove
  def initialize(battle, move)
    super
    @statDown = [:ATTACK, 1]
  end
end

#===============================================================================
# Decreases the user's Attack by 2 stages.
#===============================================================================
class PokeBattle_Move_LowerUserAttack2 < PokeBattle_StatDownMove
  def initialize(battle, move)
    super
    @statDown = [:ATTACK, 2]
  end
end

#===============================================================================
# Decreases the user's Defense by 1 stage. (Clanging Scales)
#===============================================================================
class PokeBattle_Move_LowerUserDefense1 < PokeBattle_StatDownMove
  def initialize(battle,move)
    super
    @statDown = [:DEFENSE,1]
  end
end

#===============================================================================
# Decreases the user's Defense by 2 stages.
#===============================================================================
class PokeBattle_Move_LowerUserDefense2 < PokeBattle_StatDownMove
  def initialize(battle, move)
    super
    @statDown = [:DEFENSE, 2]
  end
end

#===============================================================================
# Decreases the user's Special Attack by 1 stage.
#===============================================================================
class PokeBattle_Move_LowerUserSpAtk1 < PokeBattle_StatDownMove
  def initialize(battle, move)
    super
    @statDown = [:SPECIAL_ATTACK, 1]
  end
end

#===============================================================================
# Decreases the user's Special Attack by 2 stages.
#===============================================================================
class PokeBattle_Move_LowerUserSpAtk2 < PokeBattle_StatDownMove
  def initialize(battle,move)
    super
    @statDown = [:SPECIAL_ATTACK,2]
  end
end

#===============================================================================
# Decreases the user's Special Defense by 1 stage.
#===============================================================================
class PokeBattle_Move_LowerUserSpDef1 < PokeBattle_StatDownMove
  def initialize(battle, move)
    super
    @statDown = [:SPECIAL_DEFENSE, 1]
  end
end

#===============================================================================
# Decreases the user's Special Defense by 2 stages.
#===============================================================================
class PokeBattle_Move_LowerUserSpDef2 < PokeBattle_StatDownMove
  def initialize(battle, move)
    super
    @statDown = [:SPECIAL_DEFENSE, 2]
  end
end

#===============================================================================
# Decreases the user's Speed by 1 stage. (Hammer Arm, Ice Hammer)
#===============================================================================
class PokeBattle_Move_LowerUserSpeed1 < PokeBattle_StatDownMove
  def initialize(battle,move)
    super
    @statDown = [:SPEED,1]
  end
end

#===============================================================================
# Decreases the user's Speed by 2 stages.
#===============================================================================
class PokeBattle_Move_LowerUserSpeed2 < PokeBattle_StatDownMove
  def initialize(battle, move)
    super
    @statDown = [:SPEED, 2]
  end
end

#===============================================================================
# Decreases the user's Attack and Defense by 1 stage each. (Superpower)
#===============================================================================
class PokeBattle_Move_LowerUserAtkDef1 < PokeBattle_StatDownMove
  def initialize(battle,move)
    super
    @statDown = [:ATTACK,1,:DEFENSE,1]
  end
end

#===============================================================================
# Decreases the user's Defense and Special Defense by 1 stage each.
# (Close Combat, Dragon Ascent)
#===============================================================================
class PokeBattle_Move_LowerUserDefSpDef1 < PokeBattle_StatDownMove
  def initialize(battle,move)
    super
    @statDown = [:DEFENSE,1,:SPECIAL_DEFENSE,1]
  end
end



#===============================================================================
# Decreases the user's Defense, Special Defense and Speed by 1 stage each.
# (V-create)
#===============================================================================
class PokeBattle_Move_LowerUserDefSpDefSpd1 < PokeBattle_StatDownMove
  def initialize(battle,move)
    super
    @statDown = [:SPEED,1,:DEFENSE,1,:SPECIAL_DEFENSE,1]
  end
end

#===============================================================================
# Increases the user's and allies' Attack by 1 stage. (Howl (Gen 8+))
#===============================================================================
class PokeBattle_Move_RaiseTargetAttack1 < PokeBattle_Move
  def canSnatch?; return true; end

  def pbMoveFailed?(user, targets)
    return false if damagingMove?
    failed = true
    targets.each do |b|
      next if b.pbCanRaiseStatStage?(:ATTACK, user, self)
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
    return false if damagingMove?
    return !target.pbCanRaiseStatStage?(:ATTACK, user, self, show_message)
  end

  def pbEffectAgainstTarget(user, target)
    return if damagingMove?
    target.pbRaiseStatStage(:ATTACK, 1, user)
  end

  def pbAdditionalEffect(user, target)
    return if !target.pbCanRaiseStatStage?(:ATTACK, user, self)
    target.pbRaiseStatStage(:ATTACK, 1, user)
  end
end

#===============================================================================
# Increases the target's Attack by 2 stages. Confuses the target. (Swagger)
#===============================================================================
class PokeBattle_Move_RaiseTargetAttack2ConfuseTarget < PokeBattle_Move
  def canMagicCoat?; return true; end

  def pbMoveFailed?(user,targets)
    failed = true
    targets.each do |b|
      next if !b.pbCanRaiseStatStage?(:ATTACK,user,self) &&
              !b.pbCanConfuse?(user,false,self)
      failed = false
      break
    end
    if failed
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    if target.pbCanRaiseStatStage?(:ATTACK,user,self)
      target.pbRaiseStatStage(:ATTACK,2,user)
    end
    target.pbConfuse if target.pbCanConfuse?(user,false,self)
  end
end

#===============================================================================
# Increases the target's Special Attack by 1 stage. Confuses the target. (Flatter)
#===============================================================================
class PokeBattle_Move_RaiseTargetSpAtk1ConfuseTarget < PokeBattle_Move
  def canMagicCoat?; return true; end

  def pbMoveFailed?(user,targets)
    failed = true
    targets.each do |b|
      next if !b.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self) &&
              !b.pbCanConfuse?(user,false,self)
      failed = false
      break
    end
    if failed
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    if target.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self)
      target.pbRaiseStatStage(:SPECIAL_ATTACK,1,user)
    end
    target.pbConfuse if target.pbCanConfuse?(user,false,self)
  end
end

#===============================================================================
# Increases target's Special Defense by 1 stage. (Aromatic Mist)
#===============================================================================
class PokeBattle_Move_RaiseTargetSpDef1 < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end

  def pbFailsAgainstTarget?(user, target, show_message)
    return true if !target.pbCanRaiseStatStage?(:SPECIAL_DEFENSE, user, self, show_message)
    return false
  end

  def pbEffectAgainstTarget(user,target)
    target.pbRaiseStatStage(:SPECIAL_DEFENSE,1,user)
  end
end

#===============================================================================
# Increases one random stat of the target by 2 stages (except HP). (Acupressure)
#===============================================================================
class PokeBattle_Move_RaiseTargetRandomStat2 < PokeBattle_Move
  def pbFailsAgainstTarget?(user, target, show_message)
    @statArray = []
    GameData::Stat.each_battle do |s|
      @statArray.push(s.id) if target.pbCanRaiseStatStage?(s.id,user,self)
    end
    if @statArray.length==0
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!", target.pbThis)) if show_message
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    stat = @statArray[@battle.pbRandom(@statArray.length)]
    target.pbRaiseStatStage(stat,2,user)
  end
end

#===============================================================================
# Increases the target's Attack and Special Attack by 2 stages each. (Decorate)
#===============================================================================
class PokeBattle_Move_RaiseTargetAtkSpAtk2 < PokeBattle_Move
  def pbMoveFailed?(user, targets)
    failed = true
    targets.each do |b|
      next if !b.pbCanRaiseStatStage?(:ATTACK, user, self) &&
              !b.pbCanRaiseStatStage?(:SPECIAL_ATTACK, user, self)
      failed = false
      break
    end
    if failed
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    if target.pbCanRaiseStatStage?(:ATTACK, user, self)
      target.pbRaiseStatStage(:ATTACK, 2, user)
    end
    if target.pbCanRaiseStatStage?(:SPECIAL_ATTACK, user, self)
      target.pbRaiseStatStage(:SPECIAL_ATTACK, 2, user)
    end
  end
end

#===============================================================================
# Decreases the target's Attack by 1 stage.
#===============================================================================
class PokeBattle_Move_LowerTargetAttack1 < PokeBattle_TargetStatDownMove
  def initialize(battle,move)
    super
    @statDown = [:ATTACK,1]
  end
end

#===============================================================================
# Decreases the target's Attack by 1 stage. Bypasses target's Substitute. (Play Nice)
#===============================================================================
class PokeBattle_Move_LowerTargetAttack1BypassSubstitute < PokeBattle_TargetStatDownMove
  def ignoresSubstitute?(user); return true; end

  def initialize(battle,move)
    super
    @statDown = [:ATTACK,1]
  end
end

#===============================================================================
# Decreases the target's Attack by 2 stages. (Charm, Feather Dance)
#===============================================================================
class PokeBattle_Move_LowerTargetAttack2 < PokeBattle_TargetStatDownMove
  def initialize(battle,move)
    super
    @statDown = [:ATTACK,2]
  end
end

#===============================================================================
# Decreases the target's Attack by 3 stages.
#===============================================================================
class PokeBattle_Move_LowerTargetAttack3 < PokeBattle_TargetStatDownMove
  def initialize(battle, move)
    super
    @statDown = [:ATTACK, 3]
  end
end

#===============================================================================
# Decreases the target's Defense by 1 stage.
#===============================================================================
class PokeBattle_Move_LowerTargetDefense1 < PokeBattle_TargetStatDownMove
  def initialize(battle,move)
    super
    @statDown = [:DEFENSE,1]
  end
end

#===============================================================================
# Decreases the target's Defense by 1 stage. Power is doubled if Gravity is in
# effect. (Grav Apple)
#===============================================================================
class PokeBattle_Move_LowerTargetDefense1DoublePowerInGravity < PokeBattle_Move_LowerTargetDefense1
  def pbBaseDamage(baseDmg, user, target)
    baseDmg *= 2 if @battle.field.effects[PBEffects::Gravity] > 0
    return baseDmg
  end
end

#===============================================================================
# Decreases the target's Defense by 2 stages. (Screech)
#===============================================================================
class PokeBattle_Move_LowerTargetDefense2 < PokeBattle_TargetStatDownMove
  def initialize(battle,move)
    super
    @statDown = [:DEFENSE,2]
  end
end

#===============================================================================
# Decreases the target's Defense by 3 stages.
#===============================================================================
class PokeBattle_Move_LowerTargetDefense3 < PokeBattle_TargetStatDownMove
  def initialize(battle, move)
    super
    @statDown = [:DEFENSE, 3]
  end
end

#===============================================================================
# Decreases the target's Special Attack by 1 stage.
#===============================================================================
class PokeBattle_Move_LowerTargetSpAtk1 < PokeBattle_TargetStatDownMove
  def initialize(battle,move)
    super
    @statDown = [:SPECIAL_ATTACK,1]
  end
end

#===============================================================================
# Decreases the target's Special Attack by 2 stages. (Eerie Impulse)
#===============================================================================
class PokeBattle_Move_LowerTargetSpAtk2 < PokeBattle_TargetStatDownMove
  def initialize(battle,move)
    super
    @statDown = [:SPECIAL_ATTACK,2]
  end
end

#===============================================================================
# Decreases the target's Special Attack by 2 stages. Only works on the opposite
# gender. (Captivate)
#===============================================================================
class PokeBattle_Move_LowerTargetSpAtk2IfCanAttract < PokeBattle_TargetStatDownMove
  def initialize(battle,move)
    super
    @statDown = [:SPECIAL_ATTACK,2]
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    return true if super
    return false if damagingMove?
    if user.gender==2 || target.gender==2 || user.gender==target.gender
      @battle.pbDisplay(_INTL("{1} is unaffected!",target.pbThis)) if show_message
      return true
    end
    if target.hasActiveAbility?(:OBLIVIOUS) && !@battle.moldBreaker
      if show_message
        @battle.pbShowAbilitySplash(target)
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("{1} is unaffected!", target.pbThis))
        else
          @battle.pbDisplay(_INTL("{1}'s {2} prevents romance!", target.pbThis, target.abilityName))
        end
        @battle.pbHideAbilitySplash(target)
      end
      return true
    end
    return false
  end

  def pbAdditionalEffect(user,target)
    return if user.gender==2 || target.gender==2 || user.gender==target.gender
    return if target.hasActiveAbility?(:OBLIVIOUS) && !@battle.moldBreaker
    super
  end
end

#===============================================================================
# Decreases the target's Special Attack by 3 stages.
#===============================================================================
class PokeBattle_Move_LowerTargetSpAtk3 < PokeBattle_TargetStatDownMove
  def initialize(battle, move)
    super
    @statDown = [:SPECIAL_ATTACK, 3]
  end
end

#===============================================================================
# Decreases the target's Special Defense by 1 stage.
#===============================================================================
class PokeBattle_Move_LowerTargetSpDef1 < PokeBattle_TargetStatDownMove
  def initialize(battle,move)
    super
    @statDown = [:SPECIAL_DEFENSE,1]
  end
end

#===============================================================================
# Decreases the target's Special Defense by 2 stages.
#===============================================================================
class PokeBattle_Move_LowerTargetSpDef2 < PokeBattle_TargetStatDownMove
  def initialize(battle,move)
    super
    @statDown = [:SPECIAL_DEFENSE,2]
  end
end

#===============================================================================
# Decreases the target's Special Defense by 3 stages.
#===============================================================================
class PokeBattle_Move_LowerTargetSpDef3 < PokeBattle_TargetStatDownMove
  def initialize(battle, move)
    super
    @statDown = [:SPECIAL_DEFENSE, 3]
  end
end

#===============================================================================
# Decreases the target's Speed by 1 stage.
#===============================================================================
class PokeBattle_Move_LowerTargetSpeed1 < PokeBattle_TargetStatDownMove
  def initialize(battle,move)
    super
    @statDown = [:SPEED,1]
  end
end

#===============================================================================
# Decreases the target's Speed by 1 stage. Power is halved in Grassy Terrain.
# (Bulldoze)
#===============================================================================
class PokeBattle_Move_LowerTargetSpeed1WeakerInGrassyTerrain < PokeBattle_TargetStatDownMove
  def initialize(battle,move)
    super
    @statDown = [:SPEED,1]
  end

  def pbBaseDamage(baseDmg,user,target)
    baseDmg = (baseDmg/2.0).round if @battle.field.terrain == :Grassy
    return baseDmg
  end
end

#===============================================================================
# Decreases the target's Speed by 1 stage. Doubles the effectiveness of damaging
# Fire moves used against the target (this effect does not stack). Fails if
# neither of these effects can be applied. (Tar Shot)
#===============================================================================
class PokeBattle_Move_LowerTargetSpeed1MakeTargetWeakerToFire < PokeBattle_TargetStatDownMove
  def initialize(battle,move)
    super
    @statDown = [:SPEED,1]
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    return super if target.effects[PBEffects::TarShot]
    return false
  end

  def pbEffectAgainstTarget(user, target)
    super
    if !target.effects[PBEffects::TarShot]
      target.effects[PBEffects::TarShot] = true
      @battle.pbDisplay(_INTL("{1} became weaker to fire!", target.pbThis))
    end
  end
end

#===============================================================================
# Decreases the target's Speed by 2 stages. (Cotton Spore, Scary Face, String Shot)
#===============================================================================
class PokeBattle_Move_LowerTargetSpeed2 < PokeBattle_TargetStatDownMove
  def initialize(battle,move)
    super
    @statDown = [:SPEED, 2]
  end
end

#===============================================================================
# Decreases the target's Speed by 3 stages.
#===============================================================================
class PokeBattle_Move_LowerTargetSpeed3 < PokeBattle_TargetStatDownMove
  def initialize(battle, move)
    super
    @statDown = [:SPEED, 3]
  end
end

#===============================================================================
# Decreases the target's accuracy by 1 stage.
#===============================================================================
class PokeBattle_Move_LowerTargetAccuracy1 < PokeBattle_TargetStatDownMove
  def initialize(battle,move)
    super
    @statDown = [:ACCURACY,1]
  end
end

#===============================================================================
# Decreases the target's accuracy by 2 stages.
#===============================================================================
class PokeBattle_Move_LowerTargetAccuracy2 < PokeBattle_TargetStatDownMove
  def initialize(battle, move)
    super
    @statDown = [:ACCURACY, 2]
  end
end

#===============================================================================
# Decreases the target's accuracy by 3 stages.
#===============================================================================
class PokeBattle_Move_LowerTargetAccuracy3 < PokeBattle_TargetStatDownMove
  def initialize(battle, move)
    super
    @statDown = [:ACCURACY, 3]
  end
end

#===============================================================================
# Decreases the target's evasion by 1 stage. (Sweet Scent (Gen 5-))
#===============================================================================
class PokeBattle_Move_LowerTargetEvasion1 < PokeBattle_TargetStatDownMove
  def initialize(battle,move)
    super
    @statDown = [:EVASION, 1]
  end
end

#===============================================================================
# Decreases the target's evasion by 1 stage. Ends all barriers and entry
# hazards for the target's side OR on both sides. (Defog)
#===============================================================================
class PokeBattle_Move_LowerTargetEvasion1RemoveSideEffects < PokeBattle_TargetStatDownMove
  def ignoresSubstitute?(user); return true; end

  def initialize(battle,move)
    super
    @statDown = [:EVASION,1]
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    targetSide = target.pbOwnSide
    targetOpposingSide = target.pbOpposingSide
    return false if targetSide.effects[PBEffects::AuroraVeil]>0 ||
                    targetSide.effects[PBEffects::LightScreen]>0 ||
                    targetSide.effects[PBEffects::Reflect]>0 ||
                    targetSide.effects[PBEffects::Mist]>0 ||
                    targetSide.effects[PBEffects::Safeguard]>0
    return false if targetSide.effects[PBEffects::StealthRock] ||
                    targetSide.effects[PBEffects::Spikes]>0 ||
                    targetSide.effects[PBEffects::ToxicSpikes]>0 ||
                    targetSide.effects[PBEffects::StickyWeb]
    return false if Settings::MECHANICS_GENERATION >= 6 &&
                    (targetOpposingSide.effects[PBEffects::StealthRock] ||
                    targetOpposingSide.effects[PBEffects::Spikes]>0 ||
                    targetOpposingSide.effects[PBEffects::ToxicSpikes]>0 ||
                    targetOpposingSide.effects[PBEffects::StickyWeb])
    return false if Settings::MECHANICS_GENERATION >= 8 && @battle.field.terrain != :None
    return super
  end

  def pbEffectAgainstTarget(user,target)
    if target.pbCanLowerStatStage?(@statDown[0],user,self)
      target.pbLowerStatStage(@statDown[0],@statDown[1],user)
    end
    if target.pbOwnSide.effects[PBEffects::AuroraVeil]>0
      target.pbOwnSide.effects[PBEffects::AuroraVeil] = 0
      @battle.pbDisplay(_INTL("{1}'s Aurora Veil wore off!",target.pbTeam))
    end
    if target.pbOwnSide.effects[PBEffects::LightScreen]>0
      target.pbOwnSide.effects[PBEffects::LightScreen] = 0
      @battle.pbDisplay(_INTL("{1}'s Light Screen wore off!",target.pbTeam))
    end
    if target.pbOwnSide.effects[PBEffects::Reflect]>0
      target.pbOwnSide.effects[PBEffects::Reflect] = 0
      @battle.pbDisplay(_INTL("{1}'s Reflect wore off!",target.pbTeam))
    end
    if target.pbOwnSide.effects[PBEffects::Mist]>0
      target.pbOwnSide.effects[PBEffects::Mist] = 0
      @battle.pbDisplay(_INTL("{1}'s Mist faded!",target.pbTeam))
    end
    if target.pbOwnSide.effects[PBEffects::Safeguard]>0
      target.pbOwnSide.effects[PBEffects::Safeguard] = 0
      @battle.pbDisplay(_INTL("{1} is no longer protected by Safeguard!!",target.pbTeam))
    end
    if target.pbOwnSide.effects[PBEffects::StealthRock] ||
       (Settings::MECHANICS_GENERATION >= 6 &&
       target.pbOpposingSide.effects[PBEffects::StealthRock])
      target.pbOwnSide.effects[PBEffects::StealthRock]      = false
      target.pbOpposingSide.effects[PBEffects::StealthRock] = false if Settings::MECHANICS_GENERATION >= 6
      @battle.pbDisplay(_INTL("{1} blew away stealth rocks!",user.pbThis))
    end
    if target.pbOwnSide.effects[PBEffects::Spikes]>0 ||
       (Settings::MECHANICS_GENERATION >= 6 &&
       target.pbOpposingSide.effects[PBEffects::Spikes]>0)
      target.pbOwnSide.effects[PBEffects::Spikes]      = 0
      target.pbOpposingSide.effects[PBEffects::Spikes] = 0 if Settings::MECHANICS_GENERATION >= 6
      @battle.pbDisplay(_INTL("{1} blew away spikes!",user.pbThis))
    end
    if target.pbOwnSide.effects[PBEffects::ToxicSpikes]>0 ||
       (Settings::MECHANICS_GENERATION >= 6 &&
       target.pbOpposingSide.effects[PBEffects::ToxicSpikes]>0)
      target.pbOwnSide.effects[PBEffects::ToxicSpikes]      = 0
      target.pbOpposingSide.effects[PBEffects::ToxicSpikes] = 0 if Settings::MECHANICS_GENERATION >= 6
      @battle.pbDisplay(_INTL("{1} blew away poison spikes!",user.pbThis))
    end
    if target.pbOwnSide.effects[PBEffects::StickyWeb] ||
       (Settings::MECHANICS_GENERATION >= 6 &&
       target.pbOpposingSide.effects[PBEffects::StickyWeb])
      target.pbOwnSide.effects[PBEffects::StickyWeb]      = false
      target.pbOpposingSide.effects[PBEffects::StickyWeb] = false if Settings::MECHANICS_GENERATION >= 6
      @battle.pbDisplay(_INTL("{1} blew away sticky webs!",user.pbThis))
    end
    if Settings::MECHANICS_GENERATION >= 8 && @battle.field.terrain != :None
      case @battle.field.terrain
      when :Electric
        @battle.pbDisplay(_INTL("The electricity disappeared from the battlefield."))
      when :Grassy
        @battle.pbDisplay(_INTL("The grass disappeared from the battlefield."))
      when :Misty
        @battle.pbDisplay(_INTL("The mist disappeared from the battlefield."))
      when :Psychic
        @battle.pbDisplay(_INTL("The weirdness disappeared from the battlefield."))
      end
      @battle.field.terrain = :None
    end
  end
end

#===============================================================================
# Decreases the target's evasion by 2 stages. (Sweet Scent (Gen 6+))
#===============================================================================
class PokeBattle_Move_LowerTargetEvasion2 < PokeBattle_TargetStatDownMove
  def initialize(battle,move)
    super
    @statDown = [:EVASION, 2]
  end
end

#===============================================================================
# Decreases the target's evasion by 3 stages.
#===============================================================================
class PokeBattle_Move_LowerTargetEvasion3 < PokeBattle_TargetStatDownMove
  def initialize(battle, move)
    super
    @statDown = [:EVASION, 3]
  end
end

#===============================================================================
# Decreases the target's Attack and Defense by 1 stage each. (Tickle)
#===============================================================================
class PokeBattle_Move_LowerTargetAtkDef1 < PokeBattle_TargetMultiStatDownMove
  def initialize(battle,move)
    super
    @statDown = [:ATTACK,1,:DEFENSE,1]
  end
end

#===============================================================================
# Decreases the target's Attack and Special Attack by 1 stage each. (Noble Roar)
#===============================================================================
class PokeBattle_Move_LowerTargetAtkSpAtk1 < PokeBattle_TargetMultiStatDownMove
  def initialize(battle,move)
    super
    @statDown = [:ATTACK,1,:SPECIAL_ATTACK,1]
  end
end

#===============================================================================
# Decreases the Attack, Special Attack and Speed of all poisoned targets by 1
# stage each. (Venom Drench)
#===============================================================================
class PokeBattle_Move_LowerPoisonedTargetAtkSpAtkSpd1 < PokeBattle_Move
  def canMagicCoat?; return true; end

  def initialize(battle,move)
    super
    @statDown = [:ATTACK, 1, :SPECIAL_ATTACK, 1, :SPEED, 1]
  end

  def pbMoveFailed?(user,targets)
    @validTargets = []
    targets.each do |b|
      next if !b || b.fainted?
      next if !b.poisoned?
      next if !b.pbCanLowerStatStage?(:ATTACK,user,self) &&
              !b.pbCanLowerStatStage?(:SPECIAL_ATTACK,user,self) &&
              !b.pbCanLowerStatStage?(:SPEED,user,self)
      @validTargets.push(b.index)
    end
    if @validTargets.length==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbCheckForMirrorArmor(user, target)
    if target.hasActiveAbility?(:MIRRORARMOR) && user.index != target.index
      failed = true
      for i in 0...@statDown.length / 2
        next if target.statStageAtMin?(@statDown[i * 2])
        next if !user.pbCanLowerStatStage?(@statDown[i * 2], target, self, false, false, true)
        failed = false
        break
      end
      if failed
        @battle.pbShowAbilitySplash(target)
        if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("{1}'s {2} activated!", target.pbThis, target.abilityName))
        end
        user.pbCanLowerStatStage?(@statDown[0], target, self, true, false, true)   # Show fail message
        @battle.pbHideAbilitySplash(target)
        return false
      end
    end
    return true
  end

  def pbEffectAgainstTarget(user,target)
    return if !@validTargets.include?(target.index)
    return if !pbCheckForMirrorArmor(user, target)
    showAnim = true
    showMirrorArmorSplash = true
    for i in 0...@statDown.length / 2
      next if !target.pbCanLowerStatStage?(@statDown[i * 2], user, self)
      if target.pbLowerStatStage(@statDown[i * 2], @statDown[i * 2 + 1], user,
         showAnim, false, (showMirrorArmorSplash) ? 1 : 3)
        showAnim = false
      end
      showMirrorArmorSplash = false
    end
    @battle.pbHideAbilitySplash(target)   # To hide target's Mirror Armor splash
  end
end

#===============================================================================
# Raises the Attack and Defense of all user's allies by 1 stage each. Bypasses
# protections, including Crafty Shield. Fails if there is no ally. (Coaching)
#===============================================================================
class PokeBattle_Move_RaiseUserAndAlliesAtkDef1 < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end
  def canSnatch?; return true; end

  def pbMoveFailed?(user, targets)
    @validTargets = []
    @battle.eachSameSideBattler(user) do |b|
      next if b.index == user.index
      next if !b.pbCanRaiseStatStage?(:ATTACK, user, self) &&
              !b.pbCanRaiseStatStage?(:DEFENSE, user, self)
      @validTargets.push(b)
    end
    if @validTargets.length == 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    return false if @validTargets.any? { |b| b.index == target.index }
    @battle.pbDisplay(_INTL("{1}'s stats can't be raised further!", target.pbThis)) if show_message
    return true
  end

  def pbEffectAgainstTarget(user, target)
    showAnim = true
    if target.pbCanRaiseStatStage?(:ATTACK, user, self)
      if target.pbRaiseStatStage(:ATTACK, 1, user, showAnim)
        showAnim = false
      end
    end
    if target.pbCanRaiseStatStage?(:DEFENSE, user, self)
      target.pbRaiseStatStage(:DEFENSE, 1, user, showAnim)
    end
  end
end

#===============================================================================
# Increases the user's and its ally's Attack and Special Attack by 1 stage each,
# if they have Plus or Minus. (Gear Up)
#===============================================================================
# NOTE: In Gen 5, this move should have a target of UserSide, while in Gen 6+ it
#       should have a target of UserAndAllies. This is because, in Gen 5, this
#       move shouldn't call def pbSuccessCheckAgainstTarget for each Pokémon
#       currently in battle that will be affected by this move (i.e. allies
#       aren't protected by their substitute/ability/etc., but they are in Gen
#       6+). We achieve this by not targeting any battlers in Gen 5, since
#       pbSuccessCheckAgainstTarget is only called for targeted battlers.
class PokeBattle_Move_RaisePlusMinusUserAndAlliesAtkSpAtk1 < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end
  def canSnatch?;               return true; end

  def pbMoveFailed?(user,targets)
    @validTargets = []
    @battle.eachSameSideBattler(user) do |b|
      next if !b.hasActiveAbility?([:MINUS,:PLUS])
      next if !b.pbCanRaiseStatStage?(:ATTACK,user,self) &&
              !b.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self)
      @validTargets.push(b)
    end
    if @validTargets.length==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    return false if @validTargets.any? { |b| b.index==target.index }
    return true if !target.hasActiveAbility?([:MINUS,:PLUS])
    @battle.pbDisplay(_INTL("{1}'s stats can't be raised further!", target.pbThis)) if show_message
    return true
  end

  def pbEffectAgainstTarget(user,target)
    showAnim = true
    if target.pbCanRaiseStatStage?(:ATTACK,user,self)
      if target.pbRaiseStatStage(:ATTACK,1,user,showAnim)
        showAnim = false
      end
    end
    if target.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self)
      target.pbRaiseStatStage(:SPECIAL_ATTACK,1,user,showAnim)
    end
  end

  def pbEffectGeneral(user)
    return if pbTarget(user) != :UserSide
    @validTargets.each { |b| pbEffectAgainstTarget(user,b) }
  end
end

#===============================================================================
# Increases the user's and its ally's Defense and Special Defense by 1 stage
# each, if they have Plus or Minus. (Magnetic Flux)
#===============================================================================
# NOTE: In Gen 5, this move should have a target of UserSide, while in Gen 6+ it
#       should have a target of UserAndAllies. This is because, in Gen 5, this
#       move shouldn't call def pbSuccessCheckAgainstTarget for each Pokémon
#       currently in battle that will be affected by this move (i.e. allies
#       aren't protected by their substitute/ability/etc., but they are in Gen
#       6+). We achieve this by not targeting any battlers in Gen 5, since
#       pbSuccessCheckAgainstTarget is only called for targeted battlers.
class PokeBattle_Move_RaisePlusMinusUserAndAlliesDefSpDef1 < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end
  def canSnatch?; return true; end

  def pbMoveFailed?(user,targets)
    @validTargets = []
    @battle.eachSameSideBattler(user) do |b|
      next if !b.hasActiveAbility?([:MINUS,:PLUS])
      next if !b.pbCanRaiseStatStage?(:DEFENSE,user,self) &&
              !b.pbCanRaiseStatStage?(:SPECIAL_DEFENSE,user,self)
      @validTargets.push(b)
    end
    if @validTargets.length==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    return false if @validTargets.any? { |b| b.index==target.index }
    return true if !target.hasActiveAbility?([:MINUS,:PLUS])
    @battle.pbDisplay(_INTL("{1}'s stats can't be raised further!", target.pbThis)) if show_message
    return true
  end

  def pbEffectAgainstTarget(user,target)
    showAnim = true
    if target.pbCanRaiseStatStage?(:DEFENSE,user,self)
      if target.pbRaiseStatStage(:DEFENSE,1,user,showAnim)
        showAnim = false
      end
    end
    if target.pbCanRaiseStatStage?(:SPECIAL_DEFENSE,user,self)
      target.pbRaiseStatStage(:SPECIAL_DEFENSE,1,user,showAnim)
    end
  end

  def pbEffectGeneral(user)
    return if pbTarget(user) != :UserSide
    @validTargets.each { |b| pbEffectAgainstTarget(user,b) }
  end
end

#===============================================================================
# Increases the Attack and Special Attack of all Grass-type Pokémon in battle by
# 1 stage each. Doesn't affect airborne Pokémon. (Rototiller)
#===============================================================================
class PokeBattle_Move_RaiseGroundedGrassBattlersAtkSpAtk1 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    @validTargets = []
    @battle.eachBattler do |b|
      next if !b.pbHasType?(:GRASS)
      next if b.airborne? || b.semiInvulnerable?
      next if !b.pbCanRaiseStatStage?(:ATTACK,user,self) &&
              !b.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self)
      @validTargets.push(b.index)
    end
    if @validTargets.length==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    return false if @validTargets.include?(target.index)
    return true if !target.pbHasType?(:GRASS)
    return true if target.airborne? || target.semiInvulnerable?
    @battle.pbDisplay(_INTL("{1}'s stats can't be raised further!", target.pbThis)) if show_message
    return true
  end

  def pbEffectAgainstTarget(user,target)
    showAnim = true
    if target.pbCanRaiseStatStage?(:ATTACK,user,self)
      if target.pbRaiseStatStage(:ATTACK,1,user,showAnim)
        showAnim = false
      end
    end
    if target.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self)
      target.pbRaiseStatStage(:SPECIAL_ATTACK,1,user,showAnim)
    end
  end
end

#===============================================================================
# Increases the Defense of all Grass-type Pokémon on the field by 1 stage each.
# (Flower Shield)
#===============================================================================
class PokeBattle_Move_RaiseGrassBattlersDef1 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    @validTargets = []
    @battle.eachBattler do |b|
      next if !b.pbHasType?(:GRASS)
      next if b.semiInvulnerable?
      next if !b.pbCanRaiseStatStage?(:DEFENSE,user,self)
      @validTargets.push(b.index)
    end
    if @validTargets.length==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    return false if @validTargets.include?(target.index)
    return true if !target.pbHasType?(:GRASS) || target.semiInvulnerable?
    return !target.pbCanRaiseStatStage?(:DEFENSE, user, self, show_message)
  end

  def pbEffectAgainstTarget(user,target)
    target.pbRaiseStatStage(:DEFENSE,1,user)
  end
end

#===============================================================================
# User and target swap their Attack and Special Attack stat stages. (Power Swap)
#===============================================================================
class PokeBattle_Move_UserTargetSwapAtkSpAtkStages < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end

  def pbEffectAgainstTarget(user,target)
    [:ATTACK,:SPECIAL_ATTACK].each do |s|
      if user.stages[s] > target.stages[s]
        user.statsLowered = true
        target.statsRaised = true
      elsif user.stages[s] < target.stages[s]
        user.statsRaised = true
        target.statsLowered = true
      end
      user.stages[s],target.stages[s] = target.stages[s],user.stages[s]
    end
    @battle.pbDisplay(_INTL("{1} switched all changes to its Attack and Sp. Atk with the target!",user.pbThis))
  end
end

#===============================================================================
# User and target swap their Defense and Special Defense stat stages. (Guard Swap)
#===============================================================================
class PokeBattle_Move_UserTargetSwapDefSpDefStages < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end

  def pbEffectAgainstTarget(user,target)
    [:DEFENSE,:SPECIAL_DEFENSE].each do |s|
      if user.stages[s] > target.stages[s]
        user.statsLowered = true
        target.statsRaised = true
      elsif user.stages[s] < target.stages[s]
        user.statsRaised = true
        target.statsLowered = true
      end
      user.stages[s],target.stages[s] = target.stages[s],user.stages[s]
    end
    @battle.pbDisplay(_INTL("{1} switched all changes to its Defense and Sp. Def with the target!",user.pbThis))
  end
end

#===============================================================================
# User and target swap all their stat stages. (Heart Swap)
#===============================================================================
class PokeBattle_Move_UserTargetSwapStatStages < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end

  def pbEffectAgainstTarget(user,target)
    GameData::Stat.each_battle do |s|
      if user.stages[s.id] > target.stages[s.id]
        user.statsLowered = true
        target.statsRaised = true
      elsif user.stages[s.id] < target.stages[s.id]
        user.statsRaised = true
        target.statsLowered = true
      end
      user.stages[s.id],target.stages[s.id] = target.stages[s.id],user.stages[s.id]
    end
    @battle.pbDisplay(_INTL("{1} switched stat changes with the target!",user.pbThis))
  end
end

#===============================================================================
# User copies the target's stat stages. (Psych Up)
#===============================================================================
class PokeBattle_Move_UserCopyTargetStatStages < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end

  def pbEffectAgainstTarget(user,target)
    GameData::Stat.each_battle do |s|
      if user.stages[s.id] > target.stages[s.id]
        user.statsLowered = true
      elsif user.stages[s.id] < target.stages[s.id]
        user.statsRaised = true
      end
      user.stages[s.id] = target.stages[s.id]
    end
    if Settings::NEW_CRITICAL_HIT_RATE_MECHANICS
      user.effects[PBEffects::FocusEnergy] = target.effects[PBEffects::FocusEnergy]
      user.effects[PBEffects::LaserFocus]  = target.effects[PBEffects::LaserFocus]
    end
    @battle.pbDisplay(_INTL("{1} copied {2}'s stat changes!",user.pbThis,target.pbThis(true)))
  end
end

#===============================================================================
# User gains stat stages equal to each of the target's positive stat stages,
# and target's positive stat stages become 0, before damage calculation.
# (Spectral Thief)
#===============================================================================
class PokeBattle_Move_UserStealTargetPositiveStatStages < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end

  def pbCalcDamage(user,target,numTargets=1)
    if target.hasRaisedStatStages?
      pbShowAnimation(@id,user,target,1)   # Stat stage-draining animation
      @battle.pbDisplay(_INTL("{1} stole the target's boosted stats!",user.pbThis))
      showAnim = true
      GameData::Stat.each_battle do |s|
        next if target.stages[s.id] <= 0
        if user.pbCanRaiseStatStage?(s.id,user,self)
          if user.pbRaiseStatStage(s.id,target.stages[s.id],user,showAnim)
            showAnim = false
          end
        end
        target.statsLowered = true
        target.stages[s.id] = 0
      end
    end
    super
  end
end

#===============================================================================
# Reverses all stat changes of the target. (Topsy-Turvy)
#===============================================================================
class PokeBattle_Move_InvertTargetStatStages < PokeBattle_Move
  def canMagicCoat?; return true; end

  def pbFailsAgainstTarget?(user, target, show_message)
    if !target.hasAlteredStatStages?
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    GameData::Stat.each_battle do |s|
      if target.stages[s.id] > 0
        target.statsLowered = true
      elsif target.stages[s.id] < 0
        target.statsRaised = true
      end
      target.stages[s.id] *= -1
    end
    @battle.pbDisplay(_INTL("{1}'s stats were reversed!",target.pbThis))
  end
end

#===============================================================================
# Resets all target's stat stages to 0. (Clear Smog)
#===============================================================================
class PokeBattle_Move_ResetTargetStatStages < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    if target.damageState.calcDamage>0 && !target.damageState.substitute &&
       target.hasAlteredStatStages?
      target.pbResetStatStages
      @battle.pbDisplay(_INTL("{1}'s stat changes were removed!",target.pbThis))
    end
  end
end

#===============================================================================
# Resets all stat stages for all battlers to 0. (Haze)
#===============================================================================
class PokeBattle_Move_ResetAllBattlersStatStages < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    failed = true
    @battle.eachBattler do |b|
      failed = false if b.hasAlteredStatStages?
      break if !failed
    end
    if failed
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.eachBattler { |b| b.pbResetStatStages }
    @battle.pbDisplay(_INTL("All stat changes were eliminated!"))
  end
end

#===============================================================================
# For 5 rounds, user's and ally's stat stages cannot be lowered by foes. (Mist)
#===============================================================================
class PokeBattle_Move_StartUserSideImmunityToStatStageLowering < PokeBattle_Move
  def canSnatch?; return true; end

  def pbMoveFailed?(user,targets)
    if user.pbOwnSide.effects[PBEffects::Mist]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.pbOwnSide.effects[PBEffects::Mist] = 5
    @battle.pbDisplay(_INTL("{1} became shrouded in mist!",user.pbTeam))
  end
end

#===============================================================================
# Swaps the user's Attack and Defense stats. (Power Trick)
#===============================================================================
class PokeBattle_Move_UserSwapBaseAtkDef < PokeBattle_Move
  def canSnatch?; return true; end

  def pbEffectGeneral(user)
    user.attack,user.defense = user.defense,user.attack
    user.effects[PBEffects::PowerTrick] = !user.effects[PBEffects::PowerTrick]
    @battle.pbDisplay(_INTL("{1} switched its Attack and Defense!",user.pbThis))
  end
end

#===============================================================================
# User and target swap their Speed stats (not their stat stages). (Speed Swap)
#===============================================================================
class PokeBattle_Move_UserTargetSwapBaseSpeed < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end

  def pbEffectAgainstTarget(user,target)
    user.speed, target.speed = target.speed, user.speed
    @battle.pbDisplay(_INTL("{1} switched Speed with its target!",user.pbThis))
  end
end

#===============================================================================
# Averages the user's and target's Attack.
# Averages the user's and target's Special Attack. (Power Split)
#===============================================================================
class PokeBattle_Move_UserTargetAverageBaseAtkSpAtk < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    newatk   = ((user.attack+target.attack)/2).floor
    newspatk = ((user.spatk+target.spatk)/2).floor
    user.attack = target.attack = newatk
    user.spatk  = target.spatk  = newspatk
    @battle.pbDisplay(_INTL("{1} shared its power with the target!",user.pbThis))
  end
end

#===============================================================================
# Averages the user's and target's Defense.
# Averages the user's and target's Special Defense. (Guard Split)
#===============================================================================
class PokeBattle_Move_UserTargetAverageBaseDefSpDef < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    newdef   = ((user.defense+target.defense)/2).floor
    newspdef = ((user.spdef+target.spdef)/2).floor
    user.defense = target.defense = newdef
    user.spdef   = target.spdef   = newspdef
    @battle.pbDisplay(_INTL("{1} shared its guard with the target!",user.pbThis))
  end
end

#===============================================================================
# Averages the user's and target's current HP. (Pain Split)
#===============================================================================
class PokeBattle_Move_UserTargetAverageHP < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    newHP = (user.hp+target.hp)/2
    if user.hp>newHP
      user.pbReduceHP(user.hp-newHP,false,false)
    elsif user.hp<newHP
      user.pbRecoverHP(newHP-user.hp,false)
    end
    if target.hp>newHP
      target.pbReduceHP(target.hp-newHP,false,false)
    elsif target.hp<newHP
      target.pbRecoverHP(newHP-target.hp,false)
    end
    @battle.pbDisplay(_INTL("The battlers shared their pain!"))
    user.pbItemHPHealCheck
    target.pbItemHPHealCheck
  end
end

#===============================================================================
# For 4 rounds, doubles the Speed of all battlers on the user's side. (Tailwind)
#===============================================================================
class PokeBattle_Move_StartUserSideDoubleSpeed < PokeBattle_Move
  def canSnatch?; return true; end

  def pbMoveFailed?(user,targets)
    if user.pbOwnSide.effects[PBEffects::Tailwind]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.pbOwnSide.effects[PBEffects::Tailwind] = 4
    @battle.pbDisplay(_INTL("The Tailwind blew from behind {1}!",user.pbTeam(true)))
  end
end

#===============================================================================
# For 5 rounds, swaps all battlers' base Defense with base Special Defense.
# (Wonder Room)
#===============================================================================
class PokeBattle_Move_StartSwapAllBattlersBaseDefensiveStats < PokeBattle_Move
  def pbEffectGeneral(user)
    if @battle.field.effects[PBEffects::WonderRoom]>0
      @battle.field.effects[PBEffects::WonderRoom] = 0
      @battle.pbDisplay(_INTL("Wonder Room wore off, and the Defense and Sp. Def stats returned to normal!"))
    else
      @battle.field.effects[PBEffects::WonderRoom] = 5
      @battle.pbDisplay(_INTL("It created a bizarre area in which the Defense and Sp. Def stats are swapped!"))
    end
  end

  def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
    return if @battle.field.effects[PBEffects::WonderRoom]>0   # No animation
    super
  end
end
