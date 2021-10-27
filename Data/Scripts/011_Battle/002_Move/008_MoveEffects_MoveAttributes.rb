#===============================================================================
# Inflicts a fixed 20HP damage. (Sonic Boom)
#===============================================================================
class PokeBattle_Move_FixedDamage20 < PokeBattle_FixedDamageMove
  def pbFixedDamage(user,target)
    return 20
  end
end

#===============================================================================
# Inflicts a fixed 40HP damage. (Dragon Rage)
#===============================================================================
class PokeBattle_Move_FixedDamage40 < PokeBattle_FixedDamageMove
  def pbFixedDamage(user,target)
    return 40
  end
end

#===============================================================================
# Halves the target's current HP. (Nature's Madness, Super Fang)
#===============================================================================
class PokeBattle_Move_FixedDamageHalfTargetHP < PokeBattle_FixedDamageMove
  def pbFixedDamage(user,target)
    return (target.hp/2.0).round
  end
end

#===============================================================================
# Inflicts damage equal to the user's level. (Night Shade, Seismic Toss)
#===============================================================================
class PokeBattle_Move_FixedDamageUserLevel < PokeBattle_FixedDamageMove
  def pbFixedDamage(user,target)
    return user.level
  end
end

#===============================================================================
# Inflicts damage between 0.5 and 1.5 times the user's level. (Psywave)
#===============================================================================
class PokeBattle_Move_FixedDamageUserLevelRandom < PokeBattle_FixedDamageMove
  def pbFixedDamage(user,target)
    min = (user.level/2).floor
    max = (user.level*3/2).floor
    return min+@battle.pbRandom(max-min+1)
  end
end

#===============================================================================
# Inflicts damage to bring the target's HP down to equal the user's HP. (Endeavor)
#===============================================================================
class PokeBattle_Move_LowerTargetHPToUserHP < PokeBattle_FixedDamageMove
  def pbFailsAgainstTarget?(user, target, show_message)
    if user.hp>=target.hp
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end

  def pbNumHits(user,targets); return 1; end

  def pbFixedDamage(user,target)
    return target.hp-user.hp
  end
end

#===============================================================================
# OHKO. Accuracy increases by difference between levels of user and target.
#===============================================================================
class PokeBattle_Move_OHKO < PokeBattle_FixedDamageMove
  def pbFailsAgainstTarget?(user, target, show_message)
    if target.level>user.level
      @battle.pbDisplay(_INTL("{1} is unaffected!", target.pbThis)) if show_message
      return true
    end
    if target.hasActiveAbility?(:STURDY) && !@battle.moldBreaker
      if show_message
        @battle.pbShowAbilitySplash(target)
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
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

  def pbAccuracyCheck(user,target)
    acc = @accuracy+user.level-target.level
    return @battle.pbRandom(100)<acc
  end

  def pbFixedDamage(user,target)
    return target.totalhp
  end

  def pbHitEffectivenessMessages(user,target,numTargets=1)
    super
    if target.fainted?
      @battle.pbDisplay(_INTL("It's a one-hit KO!"))
    end
  end
end

#===============================================================================
# OHKO. Accuracy increases by difference between levels of user and target.
# Lower accuracy when used by a non-Ice-type Pokémon. Doesn't affect Ice-type
# Pokémon. (Sheer Cold (Gen 7+))
#===============================================================================
class PokeBattle_Move_OHKOIce < PokeBattle_Move_OHKO
  def pbFailsAgainstTarget?(user, target, show_message)
    if target.pbHasType?(:ICE)
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return super
  end

  def pbAccuracyCheck(user,target)
    acc = @accuracy+user.level-target.level
    acc -= 10 if !user.pbHasType?(:ICE)
    return @battle.pbRandom(100)<acc
  end
end

#===============================================================================
# OHKO. Accuracy increases by difference between levels of user and target. Hits
# targets that are semi-invulnerable underground. (Fissure)
#===============================================================================
class PokeBattle_Move_OHKOHitsUndergroundTarget < PokeBattle_Move_OHKO
  def hitsDiggingTargets?; return true; end
end

#===============================================================================
# The target's ally loses 1/16 of its max HP. (Flame Burst)
#===============================================================================
class PokeBattle_Move_DamageTargetAlly < PokeBattle_Move
  def pbEffectWhenDealingDamage(user,target)
    hitAlly = []
    target.allAllies.each do |b|
      next if !b.near?(target.index)
      next if !b.takesIndirectDamage?
      hitAlly.push([b.index,b.hp])
      b.pbReduceHP(b.totalhp/16,false)
    end
    if hitAlly.length==2
      @battle.pbDisplay(_INTL("The bursting flame hit {1} and {2}!",
         @battle.battlers[hitAlly[0][0]].pbThis(true),
         @battle.battlers[hitAlly[1][0]].pbThis(true)))
    elsif hitAlly.length>0
      hitAlly.each do |b|
        @battle.pbDisplay(_INTL("The bursting flame hit {1}!",
           @battle.battlers[b[0]].pbThis(true)))
      end
    end
    hitAlly.each { |b| @battle.battlers[b[0]].pbItemHPHealCheck }
  end
end

#===============================================================================
# Power increases with the user's HP. (Eruption, Water Spout)
#===============================================================================
class PokeBattle_Move_PowerHigherWithUserHP < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    return [150*user.hp/user.totalhp,1].max
  end
end

#===============================================================================
# Power increases the less HP the user has. (Flail, Reversal)
#===============================================================================
class PokeBattle_Move_PowerLowerWithUserHP < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    ret = 20
    n = 48*user.hp/user.totalhp
    if n<2
      ret = 200
    elsif n<5
      ret = 150
    elsif n<10
      ret = 100
    elsif n<17
      ret = 80
    elsif n<33
      ret = 40
    end
    return ret
  end
end

#===============================================================================
# Power increases with the target's HP. (Crush Grip, Wring Out)
#===============================================================================
class PokeBattle_Move_PowerHigherWithTargetHP < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    return [120*target.hp/target.totalhp,1].max
  end
end

#===============================================================================
# Power increases with the user's happiness. (Return)
#===============================================================================
class PokeBattle_Move_PowerHigherWithUserHappiness < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    return [(user.happiness*2/5).floor,1].max
  end
end

#===============================================================================
# Power decreases with the user's happiness. (Frustration)
#===============================================================================
class PokeBattle_Move_PowerLowerWithUserHappiness < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    return [((255-user.happiness)*2/5).floor,1].max
  end
end

#===============================================================================
# Power increases with the user's positive stat changes (ignores negative ones).
# (Power Trip, Stored Power)
#===============================================================================
class PokeBattle_Move_PowerHigherWithUserPositiveStatStages < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    mult = 1
    GameData::Stat.each_battle { |s| mult += user.stages[s.id] if user.stages[s.id] > 0 }
    return 20 * mult
  end
end

#===============================================================================
# Power increases with the target's positive stat changes (ignores negative ones).
# (Punishment)
#===============================================================================
class PokeBattle_Move_PowerHigherWithTargetPositiveStatStages < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    mult = 3
    GameData::Stat.each_battle { |s| mult += target.stages[s.id] if target.stages[s.id] > 0 }
    return [20 * mult, 200].min
  end
end

#===============================================================================
# Power increases the quicker the user is than the target. (Electro Ball)
#===============================================================================
class PokeBattle_Move_PowerHigherWithUserFasterThanTarget < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    ret = 40
    n = user.pbSpeed/target.pbSpeed
    if n>=4
      ret = 150
    elsif n>=3
      ret = 120
    elsif n>=2
      ret = 80
    elsif n>=1
      ret = 60
    end
    return ret
  end
end

#===============================================================================
# Power increases the quicker the target is than the user. (Gyro Ball)
#===============================================================================
class PokeBattle_Move_PowerHigherWithTargetFasterThanUser < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    return [[(25*target.pbSpeed/user.pbSpeed).floor,150].min,1].max
  end
end

#===============================================================================
# Power increases the less PP this move has. (Trump Card)
#===============================================================================
class PokeBattle_Move_PowerHigherWithLessPP < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    dmgs = [200,80,60,50,40]
    ppLeft = [@pp,dmgs.length-1].min   # PP is reduced before the move is used
    return dmgs[ppLeft]
  end
end

#===============================================================================
# Power increases the heavier the target is. (Grass Knot, Low Kick)
#===============================================================================
class PokeBattle_Move_PowerHigherWithTargetWeight < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    ret = 20
    weight = target.pbWeight
    if weight>=2000
      ret = 120
    elsif weight>=1000
      ret = 100
    elsif weight>=500
      ret = 80
    elsif weight>=250
      ret = 60
    elsif weight>=100
      ret = 40
    end
    return ret
  end
end

#===============================================================================
# Power increases the heavier the user is than the target. (Heat Crash, Heavy Slam)
# Does double damage and has perfect accuracy if the target is Minimized.
#===============================================================================
class PokeBattle_Move_PowerHigherWithUserHeavierThanTarget < PokeBattle_Move
  def tramplesMinimize?(param=1)
    return true if Settings::MECHANICS_GENERATION >= 7   # Perfect accuracy and double damage
    return super
  end

  def pbBaseDamage(baseDmg,user,target)
    ret = 40
    n = (user.pbWeight/target.pbWeight).floor
    if n>=5
      ret = 120
    elsif n>=4
      ret = 100
    elsif n>=3
      ret = 80
    elsif n>=2
      ret = 60
    end
    return ret
  end
end

#===============================================================================
# Power doubles for each consecutive use. (Fury Cutter)
#===============================================================================
class PokeBattle_Move_PowerHigherWithConsecutiveUse < PokeBattle_Move
  def pbChangeUsageCounters(user,specialUsage)
    oldVal = user.effects[PBEffects::FuryCutter]
    super
    maxMult = 1
    while (@baseDamage<<(maxMult-1))<160
      maxMult += 1   # 1-4 for base damage of 20, 1-3 for base damage of 40
    end
    user.effects[PBEffects::FuryCutter] = (oldVal>=maxMult) ? maxMult : oldVal+1
  end

  def pbBaseDamage(baseDmg,user,target)
    return baseDmg<<(user.effects[PBEffects::FuryCutter]-1)
  end
end

#===============================================================================
# Power is multiplied by the number of consecutive rounds in which this move was
# used by any Pokémon on the user's side. (Echoed Voice)
#===============================================================================
class PokeBattle_Move_PowerHigherWithConsecutiveUseOnUserSide < PokeBattle_Move
  def pbChangeUsageCounters(user,specialUsage)
    oldVal = user.pbOwnSide.effects[PBEffects::EchoedVoiceCounter]
    super
    if !user.pbOwnSide.effects[PBEffects::EchoedVoiceUsed]
      user.pbOwnSide.effects[PBEffects::EchoedVoiceCounter] = (oldVal>=5) ? 5 : oldVal+1
    end
    user.pbOwnSide.effects[PBEffects::EchoedVoiceUsed] = true
  end

  def pbBaseDamage(baseDmg,user,target)
    return baseDmg*user.pbOwnSide.effects[PBEffects::EchoedVoiceCounter]   # 1-5
  end
end

#===============================================================================
# Power is chosen at random. Power is doubled if the target is using Dig. Hits
# some semi-invulnerable targets. (Magnitude)
#===============================================================================
class PokeBattle_Move_RandomPowerDoublePowerIfTargetUnderground < PokeBattle_Move
  def hitsDiggingTargets?; return true; end

  def pbOnStartUse(user,targets)
    baseDmg = [10,30,50,70,90,110,150]
    magnitudes = [
       4,
       5,5,
       6,6,6,6,
       7,7,7,7,7,7,
       8,8,8,8,
       9,9,
       10
    ]
    magni = magnitudes[@battle.pbRandom(magnitudes.length)]
    @magnitudeDmg = baseDmg[magni-4]
    @battle.pbDisplay(_INTL("Magnitude {1}!",magni))
  end

  def pbBaseDamage(baseDmg,user,target)
    return @magnitudeDmg
  end

  def pbModifyDamage(damageMult,user,target)
    damageMult *= 2 if target.inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground")
    damageMult /= 2 if @battle.field.terrain == :Grassy
    return damageMult
  end
end

#===============================================================================
# Power is doubled if the target's HP is down to 1/2 or less. (Brine)
#===============================================================================
class PokeBattle_Move_DoublePowerIfTargetHPLessThanHalf < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    baseDmg *= 2 if target.hp<=target.totalhp/2
    return baseDmg
  end
end

#===============================================================================
# Power is doubled if the user is burned, poisoned or paralyzed. (Facade)
# Burn's halving of Attack is negated (new mechanics).
#===============================================================================
class PokeBattle_Move_DoublePowerIfUserPoisonedBurnedParalyzed < PokeBattle_Move
  def damageReducedByBurn?; return Settings::MECHANICS_GENERATION <= 5; end

  def pbBaseDamage(baseDmg,user,target)
    baseDmg *= 2 if user.poisoned? || user.burned? || user.paralyzed?
    return baseDmg
  end
end

#===============================================================================
# Power is doubled if the target is asleep. Wakes the target up. (Wake-Up Slap)
#===============================================================================
class PokeBattle_Move_DoublePowerIfTargetAsleepCureTarget < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    if target.asleep? &&
       (target.effects[PBEffects::Substitute]==0 || ignoresSubstitute?(user))
      baseDmg *= 2
    end
    return baseDmg
  end

  def pbEffectAfterAllHits(user,target)
    return if target.fainted?
    return if target.damageState.unaffected || target.damageState.substitute
    return if target.status != :SLEEP
    target.pbCureStatus
  end
end

#===============================================================================
# Power is doubled if the target is poisoned. (Venoshock)
#===============================================================================
class PokeBattle_Move_DoublePowerIfTargetPoisoned < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    if target.poisoned? &&
       (target.effects[PBEffects::Substitute]==0 || ignoresSubstitute?(user))
      baseDmg *= 2
    end
    return baseDmg
  end
end



#===============================================================================
# Power is doubled if the target is paralyzed. Cures the target of paralysis.
# (Smelling Salts)
#===============================================================================
class PokeBattle_Move_DoublePowerIfTargetParalyzedCureTarget < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    if target.paralyzed? &&
       (target.effects[PBEffects::Substitute]==0 || ignoresSubstitute?(user))
      baseDmg *= 2
    end
    return baseDmg
  end

  def pbEffectAfterAllHits(user,target)
    return if target.fainted?
    return if target.damageState.unaffected || target.damageState.substitute
    return if target.status != :PARALYSIS
    target.pbCureStatus
  end
end

#===============================================================================
# Power is doubled if the target has a status problem. (Hex)
#===============================================================================
class PokeBattle_Move_DoublePowerIfTargetStatusProblem < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    if target.pbHasAnyStatus? &&
       (target.effects[PBEffects::Substitute]==0 || ignoresSubstitute?(user))
      baseDmg *= 2
    end
    return baseDmg
  end
end

#===============================================================================
# Power is doubled if the user has no held item. (Acrobatics)
#===============================================================================
class PokeBattle_Move_DoublePowerIfUserHasNoItem < PokeBattle_Move
  def pbBaseDamageMultiplier(damageMult,user,target)
    damageMult *= 2 if !user.item || user.effects[PBEffects::GemConsumed]
    return damageMult
  end
end

#===============================================================================
# Power is doubled if the target is using Dive. Hits some semi-invulnerable
# targets. (Surf)
#===============================================================================
class PokeBattle_Move_DoublePowerIfTargetUnderwater < PokeBattle_Move
  def hitsDivingTargets?; return true; end

  def pbModifyDamage(damageMult,user,target)
    damageMult *= 2 if target.inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderwater")
    return damageMult
  end
end

#===============================================================================
# Power is doubled if the target is using Dig. Power is halved if Grassy Terrain
# is in effect. Hits some semi-invulnerable targets. (Earthquake)
#===============================================================================
class PokeBattle_Move_DoublePowerIfTargetUnderground < PokeBattle_Move
  def hitsDiggingTargets?; return true; end

  def pbModifyDamage(damageMult,user,target)
    damageMult *= 2 if target.inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground")
    damageMult /= 2 if @battle.field.terrain == :Grassy
    return damageMult
  end
end

#===============================================================================
# Power is doubled if the target is using Bounce, Fly or Sky Drop. Hits some
# semi-invulnerable targets. (Gust)
#===============================================================================
class PokeBattle_Move_DoublePowerIfTargetInSky < PokeBattle_Move
  def hitsFlyingTargets?; return true; end

  def pbBaseDamage(baseDmg,user,target)
    baseDmg *= 2 if target.inTwoTurnAttack?("TwoTurnAttackInvulnerableInSky",
                                            "TwoTurnAttackInvulnerableInSkyParalyzeTarget",
                                            "TwoTurnAttackInvulnerableInSkyTargetCannotAct") ||
                    target.effects[PBEffects::SkyDrop]>=0
    return baseDmg
  end
end

#===============================================================================
# Power is doubled if Electric Terrain applies. (Rising Voltage)
#===============================================================================
class PokeBattle_Move_DoublePowerInElectricTerrain < PokeBattle_Move
  def pbBaseDamage(baseDmg, user, target)
    baseDmg *= 2 if @battle.field.terrain == :Electric && target.affectedByTerrain?
    return baseDmg
  end
end

#===============================================================================
# Power is doubled if the user's last move failed. (Stomping Tantrum)
#===============================================================================
class PokeBattle_Move_DoublePowerIfUserLastMoveFailed < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    baseDmg *= 2 if user.lastRoundMoveFailed
    return baseDmg
  end
end

#===============================================================================
# Power is doubled if a user's teammate fainted last round. (Retaliate)
#===============================================================================
class PokeBattle_Move_DoublePowerIfAllyFaintedLastTurn < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    lrf = user.pbOwnSide.effects[PBEffects::LastRoundFainted]
    baseDmg *= 2 if lrf>=0 && lrf==@battle.turnCount-1
    return baseDmg
  end
end

#===============================================================================
# Power is doubled if the user has lost HP due to the target's move this round.
# (Avalanche, Revenge)
#===============================================================================
class PokeBattle_Move_DoublePowerIfUserLostHPThisTurn < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    baseDmg *= 2 if user.lastAttacker.include?(target.index)
    return baseDmg
  end
end

#===============================================================================
# Power is doubled if the target has already lost HP this round. (Assurance)
#===============================================================================
class PokeBattle_Move_DoublePowerIfTargetLostHPThisTurn < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    baseDmg *= 2 if target.tookDamageThisRound
    return baseDmg
  end
end

#===============================================================================
# Power is doubled if any of the user's stats were lowered this round. (Lash Out)
#===============================================================================
class PokeBattle_Move_DoublePowerIfUserStatsLoweredThisTurn < PokeBattle_Move
  def pbBaseDamage(baseDmg, user, target)
    baseDmg *= 2 if user.statsLoweredThisRound
    return baseDmg
  end
end

#===============================================================================
# Power is doubled if the target has already moved this round. (Payback)
#===============================================================================
class PokeBattle_Move_DoublePowerIfTargetActed < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    if @battle.choices[target.index][0]!=:None &&
       ((@battle.choices[target.index][0]!=:UseMove &&
       @battle.choices[target.index][0]!=:Shift) || target.movedThisRound?)
      baseDmg *= 2
    end
    return baseDmg
  end
end

#===============================================================================
# Power is doubled if the user moves before the target, or if the target
# switched in this round. (Bolt Beak, Fishious Rend)
#===============================================================================
class PokeBattle_Move_DoublePowerIfTargetNotActed < PokeBattle_Move
  def pbBaseDamage(baseDmg, user, target)
    if @battle.choices[target.index][0] == :None ||   # Switched in
      ([:UseMove, :Shift].include?(@battle.choices[target.index][0]) && !target.movedThisRound?)
      baseDmg *= 2
    end
    return baseDmg
  end
end

#===============================================================================
# This attack is always a critical hit. (Frost Breath, Storm Throw)
#===============================================================================
class PokeBattle_Move_AlwaysCriticalHit < PokeBattle_Move
  def pbCritialOverride(user,target); return 1; end
end

#===============================================================================
# Until the end of the next round, the user's moves will always be critical hits.
# (Laser Focus)
#===============================================================================
class PokeBattle_Move_EnsureNextCriticalHit < PokeBattle_Move
  def canSnatch?; return true; end

  def pbEffectGeneral(user)
    user.effects[PBEffects::LaserFocus] = 2
    @battle.pbDisplay(_INTL("{1} concentrated intensely!",user.pbThis))
  end
end

#===============================================================================
# For 5 rounds, foes' attacks cannot become critical hits. (Lucky Chant)
#===============================================================================
class PokeBattle_Move_StartPreventCriticalHitsAgainstUserSide < PokeBattle_Move
  def canSnatch?; return true; end

  def pbMoveFailed?(user,targets)
    if user.pbOwnSide.effects[PBEffects::LuckyChant]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.pbOwnSide.effects[PBEffects::LuckyChant] = 5
    @battle.pbDisplay(_INTL("The Lucky Chant shielded {1} from critical hits!",user.pbTeam(true)))
  end
end

#===============================================================================
# If target would be KO'd by this attack, it survives with 1HP instead.
# (False Swipe, Hold Back)
#===============================================================================
class PokeBattle_Move_CannotMakeTargetFaint < PokeBattle_Move
  def nonLethal?(user,target); return true; end
end

#===============================================================================
# If user would be KO'd this round, it survives with 1HP instead. (Endure)
#===============================================================================
class PokeBattle_Move_UserEnduresFaintingThisTurn < PokeBattle_ProtectMove
  def initialize(battle,move)
    super
    @effect = PBEffects::Endure
  end

  def pbProtectMessage(user)
    @battle.pbDisplay(_INTL("{1} braced itself!",user.pbThis))
  end
end

#===============================================================================
# Weakens Electric attacks. (Mud Sport)
#===============================================================================
class PokeBattle_Move_StartWeakenElectricMoves < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if Settings::MECHANICS_GENERATION >= 6
      if @battle.field.effects[PBEffects::MudSportField]>0
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
    else
      if @battle.allBattlers.any? { |b| b.effects[PBEffects::MudSport] }
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
    end
    return false
  end

  def pbEffectGeneral(user)
    if Settings::MECHANICS_GENERATION >= 6
      @battle.field.effects[PBEffects::MudSportField] = 5
    else
      user.effects[PBEffects::MudSport] = true
    end
    @battle.pbDisplay(_INTL("Electricity's power was weakened!"))
  end
end

#===============================================================================
# Weakens Fire attacks. (Water Sport)
#===============================================================================
class PokeBattle_Move_StartWeakenFireMoves < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if Settings::MECHANICS_GENERATION >= 6
      if @battle.field.effects[PBEffects::WaterSportField]>0
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
    else
      if @battle.allBattlers.any? { |b| b.effects[PBEffects::WaterSport] }
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
    end
    return false
  end

  def pbEffectGeneral(user)
    if Settings::MECHANICS_GENERATION >= 6
      @battle.field.effects[PBEffects::WaterSportField] = 5
    else
      user.effects[PBEffects::WaterSport] = true
    end
    @battle.pbDisplay(_INTL("Fire's power was weakened!"))
  end
end

#===============================================================================
# For 5 rounds, lowers power of physical attacks against the user's side.
# (Reflect)
#===============================================================================
class PokeBattle_Move_StartWeakenPhysicalDamageAgainstUserSide < PokeBattle_Move
  def canSnatch?; return true; end

  def pbMoveFailed?(user,targets)
    if user.pbOwnSide.effects[PBEffects::Reflect]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.pbOwnSide.effects[PBEffects::Reflect] = 5
    user.pbOwnSide.effects[PBEffects::Reflect] = 8 if user.hasActiveItem?(:LIGHTCLAY)
    @battle.pbDisplay(_INTL("{1} raised {2}'s Defense!",@name,user.pbTeam(true)))
  end
end

#===============================================================================
# For 5 rounds, lowers power of special attacks against the user's side. (Light Screen)
#===============================================================================
class PokeBattle_Move_StartWeakenSpecialDamageAgainstUserSide < PokeBattle_Move
  def canSnatch?; return true; end

  def pbMoveFailed?(user,targets)
    if user.pbOwnSide.effects[PBEffects::LightScreen]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.pbOwnSide.effects[PBEffects::LightScreen] = 5
    user.pbOwnSide.effects[PBEffects::LightScreen] = 8 if user.hasActiveItem?(:LIGHTCLAY)
    @battle.pbDisplay(_INTL("{1} raised {2}'s Special Defense!",@name,user.pbTeam(true)))
  end
end

#===============================================================================
# For 5 rounds, lowers power of attacks against the user's side. Fails if
# weather is not hail. (Aurora Veil)
#===============================================================================
class PokeBattle_Move_StartWeakenDamageAgainstUserSideIfHail < PokeBattle_Move
  def canSnatch?; return true; end

  def pbMoveFailed?(user,targets)
    if user.effectiveWeather != :Hail
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    if user.pbOwnSide.effects[PBEffects::AuroraVeil]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.pbOwnSide.effects[PBEffects::AuroraVeil] = 5
    user.pbOwnSide.effects[PBEffects::AuroraVeil] = 8 if user.hasActiveItem?(:LIGHTCLAY)
    @battle.pbDisplay(_INTL("{1} made {2} stronger against physical and special moves!",
       @name,user.pbTeam(true)))
  end
end

#===============================================================================
# Ends the opposing side's Light Screen, Reflect and Aurora Break. (Brick Break,
# Psychic Fangs)
#===============================================================================
class PokeBattle_Move_RemoveScreens < PokeBattle_Move
  def ignoresReflect?; return true; end

  def pbEffectGeneral(user)
    if user.pbOpposingSide.effects[PBEffects::LightScreen]>0
      user.pbOpposingSide.effects[PBEffects::LightScreen] = 0
      @battle.pbDisplay(_INTL("{1}'s Light Screen wore off!",user.pbOpposingTeam))
    end
    if user.pbOpposingSide.effects[PBEffects::Reflect]>0
      user.pbOpposingSide.effects[PBEffects::Reflect] = 0
      @battle.pbDisplay(_INTL("{1}'s Reflect wore off!",user.pbOpposingTeam))
    end
    if user.pbOpposingSide.effects[PBEffects::AuroraVeil]>0
      user.pbOpposingSide.effects[PBEffects::AuroraVeil] = 0
      @battle.pbDisplay(_INTL("{1}'s Aurora Veil wore off!",user.pbOpposingTeam))
    end
  end

  def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
    if user.pbOpposingSide.effects[PBEffects::LightScreen]>0 ||
       user.pbOpposingSide.effects[PBEffects::Reflect]>0 ||
       user.pbOpposingSide.effects[PBEffects::AuroraVeil]>0
      hitNum = 1   # Wall-breaking anim
    end
    super
  end
end

#===============================================================================
# User is protected against moves with the "B" flag this round. (Detect, Protect)
#===============================================================================
class PokeBattle_Move_ProtectUser < PokeBattle_ProtectMove
  def initialize(battle,move)
    super
    @effect = PBEffects::Protect
  end
end

#===============================================================================
# User is protected against moves with the "B" flag this round. If a Pokémon
# makes contact with the user while this effect applies, that Pokémon is
# poisoned. (Baneful Bunker)
#===============================================================================
class PokeBattle_Move_ProtectUserBanefulBunker < PokeBattle_ProtectMove
  def initialize(battle,move)
    super
    @effect = PBEffects::BanefulBunker
  end
end

#===============================================================================
# User is protected against damaging moves this round. Decreases the Attack of
# the user of a stopped contact move by 2 stages. (King's Shield)
#===============================================================================
class PokeBattle_Move_ProtectUserFromDamagingMovesKingsShield < PokeBattle_ProtectMove
  def initialize(battle,move)
    super
    @effect = PBEffects::KingsShield
  end
end

#===============================================================================
# For the rest of this round, the user avoids all damaging moves that would hit
# it. If a move that makes contact is stopped by this effect, decreases the
# Defense of the Pokémon using that move by 2 stages. Contributes to Protect's
# counter. (Obstruct)
#===============================================================================
class PokeBattle_Move_ProtectUserFromDamagingMovesObstruct < PokeBattle_ProtectMove
  def initialize(battle, move)
    super
    @effect = PBEffects::Obstruct
  end
end

#===============================================================================
# User is protected against moves that target it this round. Damages the user of
# a stopped contact move by 1/8 of its max HP. (Spiky Shield)
#===============================================================================
class PokeBattle_Move_ProtectUserFromTargetingMovesSpikyShield < PokeBattle_ProtectMove
  def initialize(battle,move)
    super
    @effect = PBEffects::SpikyShield
  end
end

#===============================================================================
# This round, the user's side is unaffected by damaging moves. (Mat Block)
#===============================================================================
class PokeBattle_Move_ProtectUserSideFromDamagingMovesIfUserFirstTurn < PokeBattle_Move
  def canSnatch?; return true; end

  def pbMoveFailed?(user,targets)
    if user.turnCount > 1
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return true if pbMoveFailedLastInRound?(user)
    return false
  end

  def pbEffectGeneral(user)
    user.pbOwnSide.effects[PBEffects::MatBlock] = true
    @battle.pbDisplay(_INTL("{1} intends to flip up a mat and block incoming attacks!",user.pbThis))
  end
end

#===============================================================================
# User's side is protected against status moves this round. (Crafty Shield)
#===============================================================================
class PokeBattle_Move_ProtectUserSideFromStatusMoves < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if user.pbOwnSide.effects[PBEffects::CraftyShield]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return true if pbMoveFailedLastInRound?(user)
    return false
  end

  def pbEffectGeneral(user)
    user.pbOwnSide.effects[PBEffects::CraftyShield] = true
    @battle.pbDisplay(_INTL("Crafty Shield protected {1}!",user.pbTeam(true)))
  end
end

#===============================================================================
# User's side is protected against moves with priority greater than 0 this round.
# (Quick Guard)
#===============================================================================
class PokeBattle_Move_ProtectUserSideFromPriorityMoves < PokeBattle_ProtectMove
  def canSnatch?; return true; end

  def initialize(battle,move)
    super
    @effect      = PBEffects::QuickGuard
    @sidedEffect = true
  end
end

#===============================================================================
# User's side is protected against moves that target multiple battlers this round.
# (Wide Guard)
#===============================================================================
class PokeBattle_Move_ProtectUserSideFromMultiTargetDamagingMoves < PokeBattle_ProtectMove
  def canSnatch?; return true; end

  def initialize(battle,move)
    super
    @effect      = PBEffects::WideGuard
    @sidedEffect = true
  end
end

#===============================================================================
# Ends target's protections immediately. (Feint)
#===============================================================================
class PokeBattle_Move_RemoveProtections < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    target.effects[PBEffects::BanefulBunker]          = false
    target.effects[PBEffects::KingsShield]            = false
    target.effects[PBEffects::Obstruct]               = false
    target.effects[PBEffects::Protect]                = false
    target.effects[PBEffects::SpikyShield]            = false
    target.pbOwnSide.effects[PBEffects::CraftyShield] = false
    target.pbOwnSide.effects[PBEffects::MatBlock]     = false
    target.pbOwnSide.effects[PBEffects::QuickGuard]   = false
    target.pbOwnSide.effects[PBEffects::WideGuard]    = false
  end
end

#===============================================================================
# Ends target's protections immediately. (Hyperspace Hole)
#===============================================================================
class PokeBattle_Move_RemoveProtectionsBypassSubstitute < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end

  def pbEffectAgainstTarget(user,target)
    target.effects[PBEffects::BanefulBunker]          = false
    target.effects[PBEffects::KingsShield]            = false
    target.effects[PBEffects::Obstruct]               = false
    target.effects[PBEffects::Protect]                = false
    target.effects[PBEffects::SpikyShield]            = false
    target.pbOwnSide.effects[PBEffects::CraftyShield] = false
    target.pbOwnSide.effects[PBEffects::MatBlock]     = false
    target.pbOwnSide.effects[PBEffects::QuickGuard]   = false
    target.pbOwnSide.effects[PBEffects::WideGuard]    = false
  end
end

#===============================================================================
# Decreases the user's Defense by 1 stage. Ends target's protections
# immediately. (Hyperspace Fury)
#===============================================================================
class PokeBattle_Move_HoopaRemoveProtectionsBypassSubstituteLowerUserDef1 < PokeBattle_StatDownMove
  def ignoresSubstitute?(user); return true; end

  def initialize(battle,move)
    super
    @statDown = [:DEFENSE,1]
  end

  def pbMoveFailed?(user,targets)
    if !user.isSpecies?(:HOOPA)
      @battle.pbDisplay(_INTL("But {1} can't use the move!",user.pbThis(true)))
      return true
    elsif user.form!=1
      @battle.pbDisplay(_INTL("But {1} can't use it the way it is now!",user.pbThis(true)))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    target.effects[PBEffects::BanefulBunker]          = false
    target.effects[PBEffects::KingsShield]            = false
    target.effects[PBEffects::Obstruct]               = false
    target.effects[PBEffects::Protect]                = false
    target.effects[PBEffects::SpikyShield]            = false
    target.pbOwnSide.effects[PBEffects::CraftyShield] = false
    target.pbOwnSide.effects[PBEffects::MatBlock]     = false
    target.pbOwnSide.effects[PBEffects::QuickGuard]   = false
    target.pbOwnSide.effects[PBEffects::WideGuard]    = false
  end
end

#===============================================================================
# User takes recoil damage equal to 1/4 of the damage this move dealt.
#===============================================================================
class PokeBattle_Move_RecoilQuarterOfDamageDealt < PokeBattle_RecoilMove
  def pbRecoilDamage(user,target)
    return (target.damageState.totalHPLost/4.0).round
  end
end

#===============================================================================
# User takes recoil damage equal to 1/3 of the damage this move dealt.
#===============================================================================
class PokeBattle_Move_RecoilThirdOfDamageDealt < PokeBattle_RecoilMove
  def pbRecoilDamage(user,target)
    return (target.damageState.totalHPLost/3.0).round
  end
end

#===============================================================================
# User takes recoil damage equal to 1/3 of the damage this move dealt.
# May paralyze the target. (Volt Tackle)
#===============================================================================
class PokeBattle_Move_RecoilThirdOfDamageDealtParalyzeTarget < PokeBattle_RecoilMove
  def pbRecoilDamage(user,target)
    return (target.damageState.totalHPLost/3.0).round
  end

  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    target.pbParalyze(user) if target.pbCanParalyze?(user,false,self)
  end
end

#===============================================================================
# User takes recoil damage equal to 1/3 of the damage this move dealt.
# May burn the target. (Flare Blitz)
#===============================================================================
class PokeBattle_Move_RecoilThirdOfDamageDealtBurnTarget < PokeBattle_RecoilMove
  def pbRecoilDamage(user,target)
    return (target.damageState.totalHPLost/3.0).round
  end

  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    target.pbBurn(user) if target.pbCanBurn?(user,false,self)
  end
end

#===============================================================================
# User takes recoil damage equal to 1/2 of the damage this move dealt.
# (Head Smash, Light of Ruin)
#===============================================================================
class PokeBattle_Move_RecoilHalfOfDamageDealt < PokeBattle_RecoilMove
  def pbRecoilDamage(user,target)
    return (target.damageState.totalHPLost/2.0).round
  end
end

#===============================================================================
# Type effectiveness is multiplied by the Flying-type's effectiveness against
# the target. Does double damage and has perfect accuracy if the target is
# Minimized. (Flying Press)
#===============================================================================
class PokeBattle_Move_EffectivenessIncludesFlyingType < PokeBattle_Move
  def tramplesMinimize?(param=1)
    return true if param==1 && Settings::MECHANICS_GENERATION >= 6   # Perfect accuracy
    return true if param==2   # Double damage
    return super
  end

  def pbCalcTypeModSingle(moveType,defType,user,target)
    ret = super
    if GameData::Type.exists?(:FLYING)
      flyingEff = Effectiveness.calculate_one(:FLYING, defType)
      ret *= flyingEff.to_f / Effectiveness::NORMAL_EFFECTIVE_ONE
    end
    return ret
  end
end

#===============================================================================
# Poisons the target. This move becomes physical or special, whichever will deal
# more damage (only considers stats, stat stages and Wonder Room). Makes contact
# if it is a physical move. Has a different animation depending on the move's
# category. (Shell Side Arm)
#===============================================================================
class PokeBattle_Move_CategoryDependsOnHigherDamagePoisonTarget < PokeBattle_PoisonMove
  def initialize(battle, move)
    super
    @calcCategory = 1
  end

  def physicalMove?(thisType = nil); return (@calcCategory == 0); end
  def specialMove?(thisType = nil);  return (@calcCategory == 1); end
  def contactMove?;                  return physicalMove?;        end

  def pbOnStartUse(user, targets)
    target = targets[0]
    stageMul = [2, 2, 2, 2, 2, 2, 2, 3, 4, 5, 6, 7, 8]
    stageDiv = [8, 7, 6, 5, 4, 3, 2, 2, 2, 2, 2, 2, 2]
    # Calculate user's effective attacking values
    attack_stage         = user.stages[:ATTACK] + 6
    real_attack          = (user.attack.to_f * stageMul[attack_stage] / stageDiv[attack_stage]).floor
    special_attack_stage = user.stages[:SPECIAL_ATTACK] + 6
    real_special_attack  = (user.spatk.to_f * stageMul[special_attack_stage] / stageDiv[special_attack_stage]).floor
    # Calculate target's effective defending values
    defense_stage         = target.stages[:DEFENSE] + 6
    real_defense          = (target.defense.to_f * stageMul[defense_stage] / stageDiv[defense_stage]).floor
    special_defense_stage = target.stages[:SPECIAL_DEFENSE] + 6
    real_special_defense  = (target.spdef.to_f * stageMul[special_defense_stage] / stageDiv[special_defense_stage]).floor
    # Perform simple damage calculation
    physical_damage = real_attack.to_f / real_defense
    special_damage = real_special_attack.to_f / real_special_defense
    # Determine move's category
    if physical_damage == special_damage
      @calcCategry = @battle.pbRandom(2)
    else
      @calcCategory = (physical_damage > special_damage) ? 0 : 1
    end
  end

  def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    hitNum = 1 if physicalMove?
    super
  end
end

#===============================================================================
# Ignores all abilities that alter this move's success or damage. This move is
# physical if user's Attack is higher than its Special Attack (after applying
# stat stages), and special otherwise. (Photon Geyser)
#===============================================================================
class PokeBattle_Move_CategoryDependsOnHigherDamageIgnoreTargetAbility < PokeBattle_Move_IgnoreTargetAbility
  def initialize(battle,move)
    super
    @calcCategory = 1
  end

  def physicalMove?(thisType=nil); return (@calcCategory==0); end
  def specialMove?(thisType=nil);  return (@calcCategory==1); end

  def pbOnStartUse(user,targets)
    # Calculate user's effective attacking value
    stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
    stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
    atk        = user.attack
    atkStage   = user.stages[:ATTACK]+6
    realAtk    = (atk.to_f*stageMul[atkStage]/stageDiv[atkStage]).floor
    spAtk      = user.spatk
    spAtkStage = user.stages[:SPECIAL_ATTACK]+6
    realSpAtk  = (spAtk.to_f*stageMul[spAtkStage]/stageDiv[spAtkStage]).floor
    # Determine move's category
    @calcCategory = (realAtk>realSpAtk) ? 0 : 1
  end
end

#===============================================================================
# The user's Defense (and its Defense stat stages) are used instead of the
# user's Attack (and Attack stat stages) to calculate damage. All other effects
# are applied normally, applying the user's Attack modifiers and not the user's
# Defence modifiers. (Body Press)
#===============================================================================
class PokeBattle_Move_UseUserBaseDefenseInsteadOfUserBaseAttack < PokeBattle_Move
  def pbGetAttackStats(user, target)
    return user.defense, user.stages[:DEFENSE] + 6
  end
end

#===============================================================================
# Target's Attack is used instead of user's Attack for this move's calculations.
# (Foul Play)
#===============================================================================
class PokeBattle_Move_UseTargetAttackInsteadOfUserAttack < PokeBattle_Move
  def pbGetAttackStats(user,target)
    if specialMove?
      return target.spatk, target.stages[:SPECIAL_ATTACK]+6
    end
    return target.attack, target.stages[:ATTACK]+6
  end
end

#===============================================================================
# Target's Defense is used instead of its Special Defense for this move's
# calculations. (Psyshock, Psystrike, Secret Sword)
#===============================================================================
class PokeBattle_Move_UseTargetDefenseInsteadOfTargetSpDef < PokeBattle_Move
  def pbGetDefenseStats(user,target)
    return target.defense, target.stages[:DEFENSE]+6
  end
end

#===============================================================================
# User's attack next round against the target will definitely hit.
# (Lock-On, Mind Reader)
#===============================================================================
class PokeBattle_Move_EnsureNextMoveAlwaysHits < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    user.effects[PBEffects::LockOn]    = 2
    user.effects[PBEffects::LockOnPos] = target.index
    @battle.pbDisplay(_INTL("{1} took aim at {2}!",user.pbThis,target.pbThis(true)))
  end
end

#===============================================================================
# Target's evasion stat changes are ignored from now on. (Foresight, Odor Sleuth)
# Normal and Fighting moves have normal effectiveness against the Ghost-type target.
#===============================================================================
class PokeBattle_Move_StartNegateTargetEvasionStatStageAndGhostImmunity < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end
  def canMagicCoat?;            return true; end

  def pbEffectAgainstTarget(user,target)
    target.effects[PBEffects::Foresight] = true
    @battle.pbDisplay(_INTL("{1} was identified!",target.pbThis))
  end
end

#===============================================================================
# Target's evasion stat changes are ignored from now on. (Miracle Eye)
# Psychic moves have normal effectiveness against the Dark-type target.
#===============================================================================
class PokeBattle_Move_StartNegateTargetEvasionStatStageAndDarkImmunity < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end
  def canMagicCoat?;            return true; end

  def pbEffectAgainstTarget(user,target)
    target.effects[PBEffects::MiracleEye] = true
    @battle.pbDisplay(_INTL("{1} was identified!",target.pbThis))
  end
end

#===============================================================================
# This move ignores target's Defense, Special Defense and evasion stat changes.
# (Chip Away, Darkest Lariat, Sacred Sword)
#===============================================================================
class PokeBattle_Move_IgnoreTargetDefSpDefEvaStatStages < PokeBattle_Move
  def pbCalcAccuracyMultipliers(user,target,multipliers)
    super
    modifiers[:evasion_stage] = 0
  end

  def pbGetDefenseStats(user,target)
    ret1, _ret2 = super
    return ret1, 6   # Def/SpDef stat stage
  end
end

#===============================================================================
# This move's type is the same as the user's first type. (Revelation Dance)
#===============================================================================
class PokeBattle_Move_TypeIsUserFirstType < PokeBattle_Move
  def pbBaseType(user)
    userTypes = user.pbTypes(true)
    return userTypes[0]
  end
end

#===============================================================================
# Power and type depends on the user's IVs. (Hidden Power)
#===============================================================================
class PokeBattle_Move_TypeDependsOnUserIVs < PokeBattle_Move
  def pbBaseType(user)
    hp = pbHiddenPower(user)
    return hp[0]
  end

  def pbBaseDamage(baseDmg,user,target)
    return super if Settings::MECHANICS_GENERATION >= 6
    hp = pbHiddenPower(user)
    return hp[1]
  end
end

def pbHiddenPower(pkmn)
  # NOTE: This allows Hidden Power to be Fairy-type (if you have that type in
  #       your game). I don't care that the official games don't work like that.
  iv = pkmn.iv
  idxType = 0
  power = 60
  types = []
  GameData::Type.each do |t|
    types[t.icon_position] ||= []
    types[t.icon_position].push(t.id) if !t.pseudo_type && ![:NORMAL, :SHADOW].include?(t.id)
  end
  types.flatten!.compact!
  idxType |= (iv[:HP]&1)
  idxType |= (iv[:ATTACK]&1)<<1
  idxType |= (iv[:DEFENSE]&1)<<2
  idxType |= (iv[:SPEED]&1)<<3
  idxType |= (iv[:SPECIAL_ATTACK]&1)<<4
  idxType |= (iv[:SPECIAL_DEFENSE]&1)<<5
  idxType = (types.length-1)*idxType/63
  type = types[idxType]
  if Settings::MECHANICS_GENERATION <= 5
    powerMin = 30
    powerMax = 70
    power |= (iv[:HP]&2)>>1
    power |= (iv[:ATTACK]&2)
    power |= (iv[:DEFENSE]&2)<<1
    power |= (iv[:SPEED]&2)<<2
    power |= (iv[:SPECIAL_ATTACK]&2)<<3
    power |= (iv[:SPECIAL_DEFENSE]&2)<<4
    power = powerMin+(powerMax-powerMin)*power/63
  end
  return [type,power]
end

#===============================================================================
# Power and type depend on the user's held berry. Destroys the berry.
# (Natural Gift)
#===============================================================================
class PokeBattle_Move_TypeAndPowerDependOnUserBerry < PokeBattle_Move
  def initialize(battle,move)
    super
    @typeArray = {
       :NORMAL   => [:CHILANBERRY],
       :FIRE     => [:CHERIBERRY,  :BLUKBERRY,   :WATMELBERRY, :OCCABERRY],
       :WATER    => [:CHESTOBERRY, :NANABBERRY,  :DURINBERRY,  :PASSHOBERRY],
       :ELECTRIC => [:PECHABERRY,  :WEPEARBERRY, :BELUEBERRY,  :WACANBERRY],
       :GRASS    => [:RAWSTBERRY,  :PINAPBERRY,  :RINDOBERRY,  :LIECHIBERRY],
       :ICE      => [:ASPEARBERRY, :POMEGBERRY,  :YACHEBERRY,  :GANLONBERRY],
       :FIGHTING => [:LEPPABERRY,  :KELPSYBERRY, :CHOPLEBERRY, :SALACBERRY],
       :POISON   => [:ORANBERRY,   :QUALOTBERRY, :KEBIABERRY,  :PETAYABERRY],
       :GROUND   => [:PERSIMBERRY, :HONDEWBERRY, :SHUCABERRY,  :APICOTBERRY],
       :FLYING   => [:LUMBERRY,    :GREPABERRY,  :COBABERRY,   :LANSATBERRY],
       :PSYCHIC  => [:SITRUSBERRY, :TAMATOBERRY, :PAYAPABERRY, :STARFBERRY],
       :BUG      => [:FIGYBERRY,   :CORNNBERRY,  :TANGABERRY,  :ENIGMABERRY],
       :ROCK     => [:WIKIBERRY,   :MAGOSTBERRY, :CHARTIBERRY, :MICLEBERRY],
       :GHOST    => [:MAGOBERRY,   :RABUTABERRY, :KASIBBERRY,  :CUSTAPBERRY],
       :DRAGON   => [:AGUAVBERRY,  :NOMELBERRY,  :HABANBERRY,  :JABOCABERRY],
       :DARK     => [:IAPAPABERRY, :SPELONBERRY, :COLBURBERRY, :ROWAPBERRY, :MARANGABERRY],
       :STEEL    => [:RAZZBERRY,   :PAMTREBERRY, :BABIRIBERRY],
       :FAIRY    => [:ROSELIBERRY, :KEEBERRY]
    }
    @damageArray = {
       60 => [:CHERIBERRY,  :CHESTOBERRY, :PECHABERRY,  :RAWSTBERRY,  :ASPEARBERRY,
              :LEPPABERRY,  :ORANBERRY,   :PERSIMBERRY, :LUMBERRY,    :SITRUSBERRY,
              :FIGYBERRY,   :WIKIBERRY,   :MAGOBERRY,   :AGUAVBERRY,  :IAPAPABERRY,
              :RAZZBERRY,   :OCCABERRY,   :PASSHOBERRY, :WACANBERRY,  :RINDOBERRY,
              :YACHEBERRY,  :CHOPLEBERRY, :KEBIABERRY,  :SHUCABERRY,  :COBABERRY,
              :PAYAPABERRY, :TANGABERRY,  :CHARTIBERRY, :KASIBBERRY,  :HABANBERRY,
              :COLBURBERRY, :BABIRIBERRY, :CHILANBERRY, :ROSELIBERRY],
       70 => [:BLUKBERRY,   :NANABBERRY,  :WEPEARBERRY, :PINAPBERRY,  :POMEGBERRY,
              :KELPSYBERRY, :QUALOTBERRY, :HONDEWBERRY, :GREPABERRY,  :TAMATOBERRY,
              :CORNNBERRY,  :MAGOSTBERRY, :RABUTABERRY, :NOMELBERRY,  :SPELONBERRY,
              :PAMTREBERRY],
       80 => [:WATMELBERRY, :DURINBERRY,  :BELUEBERRY,  :LIECHIBERRY, :GANLONBERRY,
              :SALACBERRY,  :PETAYABERRY, :APICOTBERRY, :LANSATBERRY, :STARFBERRY,
              :ENIGMABERRY, :MICLEBERRY,  :CUSTAPBERRY, :JABOCABERRY, :ROWAPBERRY,
              :KEEBERRY,    :MARANGABERRY]
    }
  end

  def pbMoveFailed?(user,targets)
    # NOTE: Unnerve does not stop a Pokémon using this move.
    item = user.item
    if !item || !item.is_berry? || !user.itemActive?
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  # NOTE: The AI calls this method via pbCalcType, but it involves user.item
  #       which here is assumed to be not nil (because item.id is called). Since
  #       the AI won't want to use it if the user has no item anyway, perhaps
  #       this is good enough.
  def pbBaseType(user)
    item = user.item
    ret = :NORMAL
    if item
      @typeArray.each do |type, items|
        next if !items.include?(item.id)
        ret = type if GameData::Type.exists?(type)
        break
      end
    end
    return ret
  end

  # This is a separate method so that the AI can use it as well
  def pbNaturalGiftBaseDamage(heldItem)
    ret = 1
    @damageArray.each do |dmg, items|
      next if !items.include?(heldItem)
      ret = dmg
      ret += 20 if Settings::MECHANICS_GENERATION >= 6
      break
    end
    return ret
  end

  def pbBaseDamage(baseDmg,user,target)
    return pbNaturalGiftBaseDamage(user.item.id)
  end

  def pbEndOfMoveUsageEffect(user,targets,numHits,switchedBattlers)
    # NOTE: The item is consumed even if this move was Protected against or it
    #       missed. The item is not consumed if the target was switched out by
    #       an effect like a target's Red Card.
    # NOTE: There is no item consumption animation.
    user.pbConsumeItem(true,true,false) if user.item
  end
end

#===============================================================================
# Type depends on the user's held Plate. (Judgment)
#===============================================================================
class PokeBattle_Move_TypeDependsOnUserPlate < PokeBattle_Move
  def initialize(battle,move)
    super
    @itemTypes = {
       :FISTPLATE   => :FIGHTING,
       :SKYPLATE    => :FLYING,
       :TOXICPLATE  => :POISON,
       :EARTHPLATE  => :GROUND,
       :STONEPLATE  => :ROCK,
       :INSECTPLATE => :BUG,
       :SPOOKYPLATE => :GHOST,
       :IRONPLATE   => :STEEL,
       :FLAMEPLATE  => :FIRE,
       :SPLASHPLATE => :WATER,
       :MEADOWPLATE => :GRASS,
       :ZAPPLATE    => :ELECTRIC,
       :MINDPLATE   => :PSYCHIC,
       :ICICLEPLATE => :ICE,
       :DRACOPLATE  => :DRAGON,
       :DREADPLATE  => :DARK,
       :PIXIEPLATE  => :FAIRY
    }
  end

  def pbBaseType(user)
    ret = :NORMAL
    if user.itemActive?
      @itemTypes.each do |item, itemType|
        next if user.item != item
        ret = itemType if GameData::Type.exists?(itemType)
        break
      end
    end
    return ret
  end
end

#===============================================================================
# Type depends on the user's held Memory. (Multi-Attack)
#===============================================================================
class PokeBattle_Move_TypeDependsOnUserMemory < PokeBattle_Move
  def initialize(battle,move)
    super
    @itemTypes = {
       :FIGHTINGMEMORY => :FIGHTING,
       :FLYINGMEMORY   => :FLYING,
       :POISONMEMORY   => :POISON,
       :GROUNDMEMORY   => :GROUND,
       :ROCKMEMORY     => :ROCK,
       :BUGMEMORY      => :BUG,
       :GHOSTMEMORY    => :GHOST,
       :STEELMEMORY    => :STEEL,
       :FIREMEMORY     => :FIRE,
       :WATERMEMORY    => :WATER,
       :GRASSMEMORY    => :GRASS,
       :ELECTRICMEMORY => :ELECTRIC,
       :PSYCHICMEMORY  => :PSYCHIC,
       :ICEMEMORY      => :ICE,
       :DRAGONMEMORY   => :DRAGON,
       :DARKMEMORY     => :DARK,
       :FAIRYMEMORY    => :FAIRY
    }
  end

  def pbBaseType(user)
    ret = :NORMAL
    if user.itemActive?
      @itemTypes.each do |item, itemType|
        next if user.item != item
        ret = itemType if GameData::Type.exists?(itemType)
        break
      end
    end
    return ret
  end
end

#===============================================================================
# Type depends on the user's held Drive. (Techno Blast)
#===============================================================================
class PokeBattle_Move_TypeDependsOnUserDrive < PokeBattle_Move
  def initialize(battle,move)
    super
    @itemTypes = {
       :SHOCKDRIVE => :ELECTRIC,
       :BURNDRIVE  => :FIRE,
       :CHILLDRIVE => :ICE,
       :DOUSEDRIVE => :WATER
    }
  end

  def pbBaseType(user)
    ret = :NORMAL
    if user.itemActive?
      @itemTypes.each do |item, itemType|
        next if user.item != item
        ret = itemType if GameData::Type.exists?(itemType)
        break
      end
    end
    return ret
  end

  def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
    t = pbBaseType(user)
    hitNum = 0
    hitNum = 1 if t == :ELECTRIC
    hitNum = 2 if t == :FIRE
    hitNum = 3 if t == :ICE
    hitNum = 4 if t == :WATER
    super
  end
end

#===============================================================================
# Increases the user's Speed by 1 stage. This move's type depends on the user's
# form (Electric if Full Belly, Dark if Hangry). Fails if the user is not
# Morpeko (works if transformed into Morpeko). (Aura Wheel)
#===============================================================================
class PokeBattle_Move_TypeDependsOnUserMorpekoFormRaiseUserSpeed1 < PokeBattle_Move_RaiseUserSpeed1
  def pbMoveFailed?(user, targets)
    if !user.isSpecies?(:MORPEKO) && user.effects[PBEffects::TransformSpecies] != :MORPEKO
      @battle.pbDisplay(_INTL("But {1} can't use the move!", user.pbThis))
      return true
    end
    return false
  end

  def pbBaseType(user)
    return :DARK if user.form == 1 && GameData::Type.exists?(:DARK)
    return @type
  end
end

#===============================================================================
# Power is doubled in weather. Type changes depending on the weather. (Weather Ball)
#===============================================================================
class PokeBattle_Move_TypeAndPowerDependOnWeather < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    baseDmg *= 2 if user.effectiveWeather != :None
    return baseDmg
  end

  def pbBaseType(user)
    ret = :NORMAL
    case user.effectiveWeather
    when :Sun, :HarshSun
      ret = :FIRE if GameData::Type.exists?(:FIRE)
    when :Rain, :HeavyRain
      ret = :WATER if GameData::Type.exists?(:WATER)
    when :Sandstorm
      ret = :ROCK if GameData::Type.exists?(:ROCK)
    when :Hail
      ret = :ICE if GameData::Type.exists?(:ICE)
    end
    return ret
  end

  def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
    t = pbBaseType(user)
    hitNum = 1 if t == :FIRE   # Type-specific anims
    hitNum = 2 if t == :WATER
    hitNum = 3 if t == :ROCK
    hitNum = 4 if t == :ICE
    super
  end
end

#===============================================================================
# Power is doubled if a terrain applies and user is grounded; also, this move's
# type and animation depends on the terrain. (Terrain Pulse)
#===============================================================================
class PokeBattle_Move_TypeAndPowerDependOnTerrain < PokeBattle_Move
  def pbBaseDamage(baseDmg, user, target)
    baseDmg *= 2 if @battle.field.terrain != :None && user.affectedByTerrain?
    return baseDmg
  end

  def pbBaseType(user)
    ret = :NORMAL
    case @battle.field.terrain
    when :Electric
      ret = :ELECTRIC if GameData::Type.exists?(:ELECTRIC)
    when :Grassy
      ret = :GRASS if GameData::Type.exists?(:GRASS)
    when :Misty
      ret = :FAIRY if GameData::Type.exists?(:FAIRY)
    when :Psychic
      ret = :PSYCHIC if GameData::Type.exists?(:PSYCHIC)
    end
    return ret
  end

  def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    t = pbBaseType(user)
    hitNum = 1 if t == :ELECTRIC   # Type-specific anims
    hitNum = 2 if t == :GRASS
    hitNum = 3 if t == :FAIRY
    hitNum = 4 if t == :PSYCHIC
    super
  end
end

#===============================================================================
# Target's moves become Electric-type for the rest of the round. (Electrify)
#===============================================================================
class PokeBattle_Move_TargetMovesBecomeElectric < PokeBattle_Move
  def pbFailsAgainstTarget?(user, target, show_message)
    if target.effects[PBEffects::Electrify]
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return true if pbMoveFailedTargetAlreadyMoved?(target, show_message)
    return false
  end

  def pbEffectAgainstTarget(user,target)
    target.effects[PBEffects::Electrify] = true
    @battle.pbDisplay(_INTL("{1}'s moves have been electrified!",target.pbThis))
  end
end

#===============================================================================
# All Normal-type moves become Electric-type for the rest of the round.
# (Ion Deluge, Plasma Fists)
#===============================================================================
class PokeBattle_Move_NormalMovesBecomeElectric < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    return false if damagingMove?
    if @battle.field.effects[PBEffects::IonDeluge]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return true if pbMoveFailedLastInRound?(user)
    return false
  end

  def pbEffectGeneral(user)
    return if @battle.field.effects[PBEffects::IonDeluge]
    @battle.field.effects[PBEffects::IonDeluge] = true
    @battle.pbDisplay(_INTL("A deluge of ions showers the battlefield!"))
  end
end
