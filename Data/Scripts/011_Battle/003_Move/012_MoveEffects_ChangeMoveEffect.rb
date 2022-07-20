#===============================================================================
# This round, user becomes the target of attacks that have single targets.
# (Follow Me, Rage Powder)
#===============================================================================
class Battle::Move::RedirectAllMovesToUser < Battle::Move
  def pbEffectGeneral(user)
    user.effects[PBEffects::FollowMe] = 1
    user.allAllies.each do |b|
      next if b.effects[PBEffects::FollowMe] < user.effects[PBEffects::FollowMe]
      user.effects[PBEffects::FollowMe] = b.effects[PBEffects::FollowMe] + 1
    end
    user.effects[PBEffects::RagePowder] = true if powderMove?
    @battle.pbDisplay(_INTL("{1} became the center of attention!", user.pbThis))
  end
end

#===============================================================================
# This round, target becomes the target of attacks that have single targets.
# (Spotlight)
#===============================================================================
class Battle::Move::RedirectAllMovesToTarget < Battle::Move
  def canMagicCoat?; return true; end

  def pbEffectAgainstTarget(user, target)
    target.effects[PBEffects::Spotlight] = 1
    target.allAllies.each do |b|
      next if b.effects[PBEffects::Spotlight] < target.effects[PBEffects::Spotlight]
      target.effects[PBEffects::Spotlight] = b.effects[PBEffects::Spotlight] + 1
    end
    @battle.pbDisplay(_INTL("{1} became the center of attention!", target.pbThis))
  end
end

#===============================================================================
# Unaffected by moves and abilities that would redirect this move. (Snipe Shot)
#===============================================================================
class Battle::Move::CannotBeRedirected < Battle::Move
  def cannotRedirect?; return true; end
end

#===============================================================================
# Randomly damages or heals the target. (Present)
# NOTE: Apparently a Normal Gem should be consumed even if this move will heal,
#       but I think that's silly so I've omitted that effect.
#===============================================================================
class Battle::Move::RandomlyDamageOrHealTarget < Battle::Move
  def pbOnStartUse(user, targets)
    @presentDmg = 0   # 0 = heal, >0 = damage
    r = @battle.pbRandom(100)
    if r < 40
      @presentDmg = 40
    elsif r < 70
      @presentDmg = 80
    elsif r < 80
      @presentDmg = 120
    end
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    return false if @presentDmg > 0
    if !target.canHeal?
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end

  def pbDamagingMove?
    return false if @presentDmg == 0
    return super
  end

  def pbBaseDamage(baseDmg, user, target)
    return @presentDmg
  end

  def pbEffectAgainstTarget(user, target)
    return if @presentDmg > 0
    target.pbRecoverHP(target.totalhp / 4)
    @battle.pbDisplay(_INTL("{1}'s HP was restored.", target.pbThis))
  end

  def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    hitNum = 1 if @presentDmg == 0   # Healing anim
    super
  end
end

#===============================================================================
# Damages target if target is a foe, or heals target by 1/2 of its max HP if
# target is an ally. (Pollen Puff)
#===============================================================================
class Battle::Move::HealAllyOrDamageFoe < Battle::Move
  def pbTarget(user)
    return GameData::Target.get(:NearFoe) if user.effects[PBEffects::HealBlock] > 0
    return super
  end

  def pbOnStartUse(user, targets)
    @healing = false
    @healing = !user.opposes?(targets[0]) if targets.length > 0
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    return false if !@healing
    if target.effects[PBEffects::Substitute] > 0 && !ignoresSubstitute?(user)
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    if !target.canHeal?
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end

  def pbDamagingMove?
    return false if @healing
    return super
  end

  def pbEffectAgainstTarget(user, target)
    return if !@healing
    target.pbRecoverHP(target.totalhp / 2)
    @battle.pbDisplay(_INTL("{1}'s HP was restored.", target.pbThis))
  end

  def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    hitNum = 1 if @healing   # Healing anim
    super
  end
end

#===============================================================================
# User is Ghost: User loses 1/2 of max HP, and curses the target.
# Cursed Pokémon lose 1/4 of their max HP at the end of each round.
# User is not Ghost: Decreases the user's Speed by 1 stage, and increases the
# user's Attack and Defense by 1 stage each. (Curse)
#===============================================================================
class Battle::Move::CurseTargetOrLowerUserSpd1RaiseUserAtkDef1 < Battle::Move
  def ignoresSubstitute?(user); return true; end

  def pbTarget(user)
    if user.pbHasType?(:GHOST)
      ghost_target = (Settings::MECHANICS_GENERATION >= 8) ? :RandomNearFoe : :NearFoe
      return GameData::Target.get(ghost_target)
    end
    return super
  end

  def pbMoveFailed?(user, targets)
    return false if user.pbHasType?(:GHOST)
    if !user.pbCanLowerStatStage?(:SPEED, user, self) &&
       !user.pbCanRaiseStatStage?(:ATTACK, user, self) &&
       !user.pbCanRaiseStatStage?(:DEFENSE, user, self)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    if user.pbHasType?(:GHOST) && target.effects[PBEffects::Curse]
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    return if user.pbHasType?(:GHOST)
    # Non-Ghost effect
    if user.pbCanLowerStatStage?(:SPEED, user, self)
      user.pbLowerStatStage(:SPEED, 1, user)
    end
    showAnim = true
    if user.pbCanRaiseStatStage?(:ATTACK, user, self)
      showAnim = false if user.pbRaiseStatStage(:ATTACK, 1, user, showAnim)
    end
    if user.pbCanRaiseStatStage?(:DEFENSE, user, self)
      user.pbRaiseStatStage(:DEFENSE, 1, user, showAnim)
    end
  end

  def pbEffectAgainstTarget(user, target)
    return if !user.pbHasType?(:GHOST)
    # Ghost effect
    @battle.pbDisplay(_INTL("{1} cut its own HP and laid a curse on {2}!", user.pbThis, target.pbThis(true)))
    target.effects[PBEffects::Curse] = true
    user.pbReduceHP(user.totalhp / 2, false, false)
    user.pbItemHPHealCheck
  end

  def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    hitNum = 1 if !user.pbHasType?(:GHOST)   # Non-Ghost anim
    super
  end
end

#===============================================================================
# Effect depends on the environment. (Secret Power)
#===============================================================================
class Battle::Move::EffectDependsOnEnvironment < Battle::Move
  def flinchingMove?; return [6, 10, 12].include?(@secretPower); end

  def pbOnStartUse(user, targets)
    # NOTE: This is Gen 7's list plus some of Gen 6 plus a bit of my own.
    @secretPower = 0   # Body Slam, paralysis
    case @battle.field.terrain
    when :Electric
      @secretPower = 1   # Thunder Shock, paralysis
    when :Grassy
      @secretPower = 2   # Vine Whip, sleep
    when :Misty
      @secretPower = 3   # Fairy Wind, lower Sp. Atk by 1
    when :Psychic
      @secretPower = 4   # Confusion, lower Speed by 1
    else
      case @battle.environment
      when :Grass, :TallGrass, :Forest, :ForestGrass
        @secretPower = 2    # (Same as Grassy Terrain)
      when :MovingWater, :StillWater, :Underwater
        @secretPower = 5    # Water Pulse, lower Attack by 1
      when :Puddle
        @secretPower = 6    # Mud Shot, lower Speed by 1
      when :Cave
        @secretPower = 7    # Rock Throw, flinch
      when :Rock, :Sand
        @secretPower = 8    # Mud-Slap, lower Acc by 1
      when :Snow, :Ice
        @secretPower = 9    # Ice Shard, freeze
      when :Volcano
        @secretPower = 10   # Incinerate, burn
      when :Graveyard
        @secretPower = 11   # Shadow Sneak, flinch
      when :Sky
        @secretPower = 12   # Gust, lower Speed by 1
      when :Space
        @secretPower = 13   # Swift, flinch
      when :UltraSpace
        @secretPower = 14   # Psywave, lower Defense by 1
      end
    end
  end

  # NOTE: This intentionally doesn't use def pbAdditionalEffect, because that
  #       method is called per hit and this move's additional effect only occurs
  #       once per use, after all the hits have happened (two hits are possible
  #       via Parental Bond).
  def pbEffectAfterAllHits(user, target)
    return if target.fainted?
    return if target.damageState.unaffected || target.damageState.substitute
    chance = pbAdditionalEffectChance(user, target)
    return if @battle.pbRandom(100) >= chance
    case @secretPower
    when 2
      target.pbSleep if target.pbCanSleep?(user, false, self)
    when 10
      target.pbBurn(user) if target.pbCanBurn?(user, false, self)
    when 0, 1
      target.pbParalyze(user) if target.pbCanParalyze?(user, false, self)
    when 9
      target.pbFreeze if target.pbCanFreeze?(user, false, self)
    when 5
      if target.pbCanLowerStatStage?(:ATTACK, user, self)
        target.pbLowerStatStage(:ATTACK, 1, user)
      end
    when 14
      if target.pbCanLowerStatStage?(:DEFENSE, user, self)
        target.pbLowerStatStage(:DEFENSE, 1, user)
      end
    when 3
      if target.pbCanLowerStatStage?(:SPECIAL_ATTACK, user, self)
        target.pbLowerStatStage(:SPECIAL_ATTACK, 1, user)
      end
    when 4, 6, 12
      if target.pbCanLowerStatStage?(:SPEED, user, self)
        target.pbLowerStatStage(:SPEED, 1, user)
      end
    when 8
      if target.pbCanLowerStatStage?(:ACCURACY, user, self)
        target.pbLowerStatStage(:ACCURACY, 1, user)
      end
    when 7, 11, 13
      target.pbFlinch(user)
    end
  end

  def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    id = :BODYSLAM   # Environment-specific anim
    case @secretPower
    when 1  then id = :THUNDERSHOCK if GameData::Move.exists?(:THUNDERSHOCK)
    when 2  then id = :VINEWHIP if GameData::Move.exists?(:VINEWHIP)
    when 3  then id = :FAIRYWIND if GameData::Move.exists?(:FAIRYWIND)
    when 4  then id = :CONFUSIO if GameData::Move.exists?(:CONFUSION)
    when 5  then id = :WATERPULSE if GameData::Move.exists?(:WATERPULSE)
    when 6  then id = :MUDSHOT if GameData::Move.exists?(:MUDSHOT)
    when 7  then id = :ROCKTHROW if GameData::Move.exists?(:ROCKTHROW)
    when 8  then id = :MUDSLAP if GameData::Move.exists?(:MUDSLAP)
    when 9  then id = :ICESHARD if GameData::Move.exists?(:ICESHARD)
    when 10 then id = :INCINERATE if GameData::Move.exists?(:INCINERATE)
    when 11 then id = :SHADOWSNEAK if GameData::Move.exists?(:SHADOWSNEAK)
    when 12 then id = :GUST if GameData::Move.exists?(:GUST)
    when 13 then id = :SWIFT if GameData::Move.exists?(:SWIFT)
    when 14 then id = :PSYWAVE if GameData::Move.exists?(:PSYWAVE)
    end
    super
  end
end

#===============================================================================
# If Psychic Terrain applies and the user is grounded, power is multiplied by
# 1.5 (in addition to Psychic Terrain's multiplier) and it targets all opposing
# Pokémon. (Expanding Force)
#===============================================================================
class Battle::Move::HitsAllFoesAndPowersUpInPsychicTerrain < Battle::Move
  def pbTarget(user)
    if @battle.field.terrain == :Psychic && user.affectedByTerrain?
      return GameData::Target.get(:AllNearFoes)
    end
    return super
  end

  def pbBaseDamage(baseDmg, user, target)
    if @battle.field.terrain == :Psychic && user.affectedByTerrain?
      baseDmg = baseDmg * 3 / 2
    end
    return baseDmg
  end
end

#===============================================================================
# Powders the foe. This round, if it uses a Fire move, it loses 1/4 of its max
# HP instead. (Powder)
#===============================================================================
class Battle::Move::TargetNextFireMoveDamagesTarget < Battle::Move
  def ignoresSubstitute?(user); return true; end
  def canMagicCoat?;            return true; end

  def pbFailsAgainstTarget?(user, target, show_message)
    if target.effects[PBEffects::Powder]
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    target.effects[PBEffects::Powder] = true
    @battle.pbDisplay(_INTL("{1} is covered in powder!", user.pbThis))
  end
end

#===============================================================================
# Power is doubled if Fusion Flare has already been used this round. (Fusion Bolt)
#===============================================================================
class Battle::Move::DoublePowerAfterFusionFlare < Battle::Move
  def pbChangeUsageCounters(user, specialUsage)
    @doublePower = @battle.field.effects[PBEffects::FusionFlare]
    super
  end

  def pbBaseDamageMultiplier(damageMult, user, target)
    damageMult *= 2 if @doublePower
    return damageMult
  end

  def pbEffectGeneral(user)
    @battle.field.effects[PBEffects::FusionBolt] = true
  end

  def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    hitNum = 1 if (targets.length > 0 && targets[0].damageState.critical) ||
                  @doublePower   # Charged anim
    super
  end
end

#===============================================================================
# Power is doubled if Fusion Bolt has already been used this round. (Fusion Flare)
#===============================================================================
class Battle::Move::DoublePowerAfterFusionBolt < Battle::Move
  def pbChangeUsageCounters(user, specialUsage)
    @doublePower = @battle.field.effects[PBEffects::FusionBolt]
    super
  end

  def pbBaseDamageMultiplier(damageMult, user, target)
    damageMult *= 2 if @doublePower
    return damageMult
  end

  def pbEffectGeneral(user)
    @battle.field.effects[PBEffects::FusionFlare] = true
  end

  def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    hitNum = 1 if (targets.length > 0 && targets[0].damageState.critical) ||
                  @doublePower   # Charged anim
    super
  end
end

#===============================================================================
# Powers up the ally's attack this round by 1.5. (Helping Hand)
#===============================================================================
class Battle::Move::PowerUpAllyMove < Battle::Move
  def ignoresSubstitute?(user); return true; end

  def pbFailsAgainstTarget?(user, target, show_message)
    if target.fainted? || target.effects[PBEffects::HelpingHand]
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return true if pbMoveFailedTargetAlreadyMoved?(target, show_message)
    return false
  end

  def pbEffectAgainstTarget(user, target)
    target.effects[PBEffects::HelpingHand] = true
    @battle.pbDisplay(_INTL("{1} is ready to help {2}!", user.pbThis, target.pbThis(true)))
  end
end

#===============================================================================
# Counters a physical move used against the user this round, with 2x the power.
# (Counter)
#===============================================================================
class Battle::Move::CounterPhysicalDamage < Battle::Move::FixedDamageMove
  def pbAddTarget(targets, user)
    t = user.effects[PBEffects::CounterTarget]
    return if t < 0 || !user.opposes?(t)
    user.pbAddTarget(targets, user, @battle.battlers[t], self, false)
  end

  def pbMoveFailed?(user, targets)
    if targets.length == 0
      @battle.pbDisplay(_INTL("But there was no target..."))
      return true
    end
    return false
  end

  def pbFixedDamage(user, target)
    dmg = user.effects[PBEffects::Counter] * 2
    dmg = 1 if dmg == 0
    return dmg
  end
end

#===============================================================================
# Counters a specical move used against the user this round, with 2x the power.
# (Mirror Coat)
#===============================================================================
class Battle::Move::CounterSpecialDamage < Battle::Move::FixedDamageMove
  def pbAddTarget(targets, user)
    t = user.effects[PBEffects::MirrorCoatTarget]
    return if t < 0 || !user.opposes?(t)
    user.pbAddTarget(targets, user, @battle.battlers[t], self, false)
  end

  def pbMoveFailed?(user, targets)
    if targets.length == 0
      @battle.pbDisplay(_INTL("But there was no target..."))
      return true
    end
    return false
  end

  def pbFixedDamage(user, target)
    dmg = user.effects[PBEffects::MirrorCoat] * 2
    dmg = 1 if dmg == 0
    return dmg
  end
end

#===============================================================================
# Counters the last damaging move used against the user this round, with 1.5x
# the power. (Metal Burst)
#===============================================================================
class Battle::Move::CounterDamagePlusHalf < Battle::Move::FixedDamageMove
  def pbAddTarget(targets, user)
    return if user.lastFoeAttacker.length == 0
    lastAttacker = user.lastFoeAttacker.last
    return if lastAttacker < 0 || !user.opposes?(lastAttacker)
    user.pbAddTarget(targets, user, @battle.battlers[lastAttacker], self, false)
  end

  def pbMoveFailed?(user, targets)
    if targets.length == 0
      @battle.pbDisplay(_INTL("But there was no target..."))
      return true
    end
    return false
  end

  def pbFixedDamage(user, target)
    dmg = (user.lastHPLostFromFoe * 1.5).floor
    dmg = 1 if dmg == 0
    return dmg
  end
end

#===============================================================================
# Increases the user's Defense and Special Defense by 1 stage each. Ups the
# user's stockpile by 1 (max. 3). (Stockpile)
#===============================================================================
class Battle::Move::UserAddStockpileRaiseDefSpDef1 < Battle::Move
  def canSnatch?; return true; end

  def pbMoveFailed?(user, targets)
    if user.effects[PBEffects::Stockpile] >= 3
      @battle.pbDisplay(_INTL("{1} can't stockpile any more!", user.pbThis))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.effects[PBEffects::Stockpile] += 1
    @battle.pbDisplay(_INTL("{1} stockpiled {2}!",
                            user.pbThis, user.effects[PBEffects::Stockpile]))
    showAnim = true
    if user.pbCanRaiseStatStage?(:DEFENSE, user, self)
      if user.pbRaiseStatStage(:DEFENSE, 1, user, showAnim)
        user.effects[PBEffects::StockpileDef] += 1
        showAnim = false
      end
    end
    if user.pbCanRaiseStatStage?(:SPECIAL_DEFENSE, user, self)
      if user.pbRaiseStatStage(:SPECIAL_DEFENSE, 1, user, showAnim)
        user.effects[PBEffects::StockpileSpDef] += 1
      end
    end
  end
end

#===============================================================================
# Power is 100 multiplied by the user's stockpile (X). Resets the stockpile to
# 0. Decreases the user's Defense and Special Defense by X stages each. (Spit Up)
#===============================================================================
class Battle::Move::PowerDependsOnUserStockpile < Battle::Move
  def pbMoveFailed?(user, targets)
    if user.effects[PBEffects::Stockpile] == 0
      @battle.pbDisplay(_INTL("But it failed to spit up a thing!"))
      return true
    end
    return false
  end

  def pbBaseDamage(baseDmg, user, target)
    return 100 * user.effects[PBEffects::Stockpile]
  end

  def pbEffectAfterAllHits(user, target)
    return if user.fainted? || user.effects[PBEffects::Stockpile] == 0
    return if target.damageState.unaffected
    @battle.pbDisplay(_INTL("{1}'s stockpiled effect wore off!", user.pbThis))
    return if @battle.pbAllFainted?(target.idxOwnSide)
    showAnim = true
    if user.effects[PBEffects::StockpileDef] > 0 &&
       user.pbCanLowerStatStage?(:DEFENSE, user, self)
      showAnim = false if user.pbLowerStatStage(:DEFENSE, user.effects[PBEffects::StockpileDef], user, showAnim)
    end
    if user.effects[PBEffects::StockpileSpDef] > 0 &&
       user.pbCanLowerStatStage?(:SPECIAL_DEFENSE, user, self)
      user.pbLowerStatStage(:SPECIAL_DEFENSE, user.effects[PBEffects::StockpileSpDef], user, showAnim)
    end
    user.effects[PBEffects::Stockpile]      = 0
    user.effects[PBEffects::StockpileDef]   = 0
    user.effects[PBEffects::StockpileSpDef] = 0
  end
end

#===============================================================================
# Heals user depending on the user's stockpile (X). Resets the stockpile to 0.
# Decreases the user's Defense and Special Defense by X stages each. (Swallow)
#===============================================================================
class Battle::Move::HealUserDependingOnUserStockpile < Battle::Move
  def healingMove?; return true; end
  def canSnatch?;   return true; end

  def pbMoveFailed?(user, targets)
    if user.effects[PBEffects::Stockpile] == 0
      @battle.pbDisplay(_INTL("But it failed to swallow a thing!"))
      return true
    end
    if !user.canHeal? &&
       user.effects[PBEffects::StockpileDef] == 0 &&
       user.effects[PBEffects::StockpileSpDef] == 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    hpGain = 0
    case [user.effects[PBEffects::Stockpile], 1].max
    when 1 then hpGain = user.totalhp / 4
    when 2 then hpGain = user.totalhp / 2
    when 3 then hpGain = user.totalhp
    end
    if user.pbRecoverHP(hpGain) > 0
      @battle.pbDisplay(_INTL("{1}'s HP was restored.", user.pbThis))
    end
    @battle.pbDisplay(_INTL("{1}'s stockpiled effect wore off!", user.pbThis))
    showAnim = true
    if user.effects[PBEffects::StockpileDef] > 0 &&
       user.pbCanLowerStatStage?(:DEFENSE, user, self)
      if user.pbLowerStatStage(:DEFENSE, user.effects[PBEffects::StockpileDef], user, showAnim)
        showAnim = false
      end
    end
    if user.effects[PBEffects::StockpileSpDef] > 0 &&
       user.pbCanLowerStatStage?(:SPECIAL_DEFENSE, user, self)
      user.pbLowerStatStage(:SPECIAL_DEFENSE, user.effects[PBEffects::StockpileSpDef], user, showAnim)
    end
    user.effects[PBEffects::Stockpile]      = 0
    user.effects[PBEffects::StockpileDef]   = 0
    user.effects[PBEffects::StockpileSpDef] = 0
  end
end

#===============================================================================
# Combos with another Pledge move used by the ally. (Grass Pledge)
# If the move is a combo, power is doubled and causes either a sea of fire or a
# swamp on the opposing side.
#===============================================================================
class Battle::Move::GrassPledge < Battle::Move::PledgeMove
  def initialize(battle, move)
    super
    # [Function code to combo with, effect, override type, override animation]
    @combos = [["FirePledge",  :SeaOfFire, :FIRE, :FIREPLEDGE],
               ["WaterPledge", :Swamp,     nil,   nil]]
  end
end

#===============================================================================
# Combos with another Pledge move used by the ally. (Fire Pledge)
# If the move is a combo, power is doubled and causes either a rainbow on the
# user's side or a sea of fire on the opposing side.
#===============================================================================
class Battle::Move::FirePledge < Battle::Move::PledgeMove
  def initialize(battle, move)
    super
    # [Function code to combo with, effect, override type, override animation]
    @combos = [["WaterPledge", :Rainbow,   :WATER, :WATERPLEDGE],
               ["GrassPledge", :SeaOfFire, nil,    nil]]
  end
end

#===============================================================================
# Combos with another Pledge move used by the ally. (Water Pledge)
# If the move is a combo, power is doubled and causes either a swamp on the
# opposing side or a rainbow on the user's side.
#===============================================================================
class Battle::Move::WaterPledge < Battle::Move::PledgeMove
  def initialize(battle, move)
    super
    # [Function code to combo with, effect, override type, override animation]
    @combos = [["GrassPledge", :Swamp,   :GRASS, :GRASSPLEDGE],
               ["FirePledge",  :Rainbow, nil,    nil]]
  end
end

#===============================================================================
# Uses the last move that was used. (Copycat)
#===============================================================================
class Battle::Move::UseLastMoveUsed < Battle::Move
  def callsAnotherMove?; return true; end

  def initialize(battle, move)
    super
    @moveBlacklist = [
      # Struggle, Belch
      "Struggle",                                          # Struggle
      "FailsIfUserNotConsumedBerry",                       # Belch              # Not listed on Bulbapedia
      # Moves that affect the moveset
      "ReplaceMoveThisBattleWithTargetLastMoveUsed",       # Mimic
      "ReplaceMoveWithTargetLastMoveUsed",                 # Sketch
      "TransformUserIntoTarget",                           # Transform
      # Counter moves
      "CounterPhysicalDamage",                             # Counter
      "CounterSpecialDamage",                              # Mirror Coat
      "CounterDamagePlusHalf",                             # Metal Burst        # Not listed on Bulbapedia
      # Helping Hand, Feint (always blacklisted together, don't know why)
      "PowerUpAllyMove",                                   # Helping Hand
      "RemoveProtections",                                 # Feint
      # Protection moves
      "ProtectUser",                                       # Detect, Protect
      "ProtectUserSideFromPriorityMoves",                  # Quick Guard        # Not listed on Bulbapedia
      "ProtectUserSideFromMultiTargetDamagingMoves",       # Wide Guard         # Not listed on Bulbapedia
      "UserEnduresFaintingThisTurn",   # Endure
      "ProtectUserSideFromDamagingMovesIfUserFirstTurn",   # Mat Block
      "ProtectUserSideFromStatusMoves",                    # Crafty Shield      # Not listed on Bulbapedia
      "ProtectUserFromDamagingMovesKingsShield",           # King's Shield
      "ProtectUserFromTargetingMovesSpikyShield",          # Spiky Shield
      "ProtectUserBanefulBunker",                          # Baneful Bunker
      # Moves that call other moves
      "UseLastMoveUsedByTarget",                           # Mirror Move
      "UseLastMoveUsed",                                   # Copycat (this move)
      "UseMoveTargetIsAboutToUse",                         # Me First
      "UseMoveDependingOnEnvironment",                     # Nature Power       # Not listed on Bulbapedia
      "UseRandomUserMoveIfAsleep",                         # Sleep Talk
      "UseRandomMoveFromUserParty",                        # Assist
      "UseRandomMove",                                     # Metronome
      # Move-redirecting and stealing moves
      "BounceBackProblemCausingStatusMoves",               # Magic Coat         # Not listed on Bulbapedia
      "StealAndUseBeneficialStatusMove",                   # Snatch
      "RedirectAllMovesToUser",                            # Follow Me, Rage Powder
      "RedirectAllMovesToTarget",                          # Spotlight
      # Set up effects that trigger upon KO
      "ReduceAttackerMovePPTo0IfUserFaints",               # Grudge             # Not listed on Bulbapedia
      "AttackerFaintsIfUserFaints",                        # Destiny Bond
      # Held item-moving moves
      "UserTakesTargetItem",                               # Covet, Thief
      "UserTargetSwapItems",                               # Switcheroo, Trick
      "TargetTakesUserItem",                               # Bestow
      # Moves that start focussing at the start of the round
      "FailsIfUserDamagedThisTurn",                        # Focus Punch
      "UsedAfterUserTakesPhysicalDamage",                  # Shell Trap
      "BurnAttackerBeforeUserActs",                        # Beak Blast
      # Event moves that do nothing
      "DoesNothingFailsIfNoAlly",                          # Hold Hands
      "DoesNothingCongratulations"                         # Celebrate
    ]
    if Settings::MECHANICS_GENERATION >= 6
      @moveBlacklist += [
        # Target-switching moves
        "SwitchOutTargetStatusMove",                       # Roar, Whirlwind
        "SwitchOutTargetDamagingMove"                      # Circle Throw, Dragon Tail
      ]
    end
  end

  def pbChangeUsageCounters(user, specialUsage)
    super
    @copied_move = @battle.lastMoveUsed
  end

  def pbMoveFailed?(user, targets)
    if !@copied_move ||
       @moveBlacklist.include?(GameData::Move.get(@copied_move).function_code)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.pbUseMoveSimple(@copied_move)
  end
end

#===============================================================================
# Uses the last move that the target used. (Mirror Move)
#===============================================================================
class Battle::Move::UseLastMoveUsedByTarget < Battle::Move
  def ignoresSubstitute?(user); return true; end
  def callsAnotherMove?; return true; end

  def pbFailsAgainstTarget?(user, target, show_message)
    if !target.lastRegularMoveUsed ||
       GameData::Move.get(target.lastRegularMoveUsed).flags.none? { |f| f[/^CanMirrorMove$/i] }
      @battle.pbDisplay(_INTL("The mirror move failed!")) if show_message
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    user.pbUseMoveSimple(target.lastRegularMoveUsed, target.index)
  end

  def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    # No animation
  end
end

#===============================================================================
# Uses the move the target was about to use this round, with 1.5x power.
# (Me First)
#===============================================================================
class Battle::Move::UseMoveTargetIsAboutToUse < Battle::Move
  def ignoresSubstitute?(user); return true; end
  def callsAnotherMove?; return true; end

  def initialize(battle, move)
    super
    @moveBlacklist = [
      "UserTakesTargetItem",                # Covet, Thief
      # Struggle, Belch
      "Struggle",                           # Struggle
      "FailsIfUserNotConsumedBerry",        # Belch
      # Counter moves
      "CounterPhysicalDamage",              # Counter
      "CounterSpecialDamage",               # Mirror Coat
      "CounterDamagePlusHalf",              # Metal Burst
      # Moves that start focussing at the start of the round
      "FailsIfUserDamagedThisTurn",         # Focus Punch
      "UsedAfterUserTakesPhysicalDamage",   # Shell Trap
      "BurnAttackerBeforeUserActs"          # Beak Blast
    ]
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    return true if pbMoveFailedTargetAlreadyMoved?(target, show_message)
    oppMove = @battle.choices[target.index][2]
    if !oppMove || oppMove.statusMove? || @moveBlacklist.include?(oppMove.function)
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    user.effects[PBEffects::MeFirst] = true
    user.pbUseMoveSimple(@battle.choices[target.index][2].id)
    user.effects[PBEffects::MeFirst] = false
  end
end

#===============================================================================
# Uses a different move depending on the environment. (Nature Power)
# NOTE: This code does not support the Gen 5 and older definition of the move
#       where it targets the user. It makes more sense for it to target another
#       Pokémon.
#===============================================================================
class Battle::Move::UseMoveDependingOnEnvironment < Battle::Move
  def callsAnotherMove?; return true; end

  def pbOnStartUse(user, targets)
    # NOTE: It's possible in theory to not have the move Nature Power wants to
    #       turn into, but what self-respecting game wouldn't at least have Tri
    #       Attack in it?
    @npMove = :TRIATTACK
    case @battle.field.terrain
    when :Electric
      @npMove = :THUNDERBOLT if GameData::Move.exists?(:THUNDERBOLT)
    when :Grassy
      @npMove = :ENERGYBALL if GameData::Move.exists?(:ENERGYBALL)
    when :Misty
      @npMove = :MOONBLAST if GameData::Move.exists?(:MOONBLAST)
    when :Psychic
      @npMove = :PSYCHIC if GameData::Move.exists?(:PSYCHIC)
    else
      try_move = nil
      case @battle.environment
      when :Grass, :TallGrass, :Forest, :ForestGrass
        try_move = (Settings::MECHANICS_GENERATION >= 6) ? :ENERGYBALL : :SEEDBOMB
      when :MovingWater, :StillWater, :Underwater
        try_move = :HYDROPUMP
      when :Puddle
        try_move = :MUDBOMB
      when :Cave
        try_move = (Settings::MECHANICS_GENERATION >= 6) ? :POWERGEM : :ROCKSLIDE
      when :Rock, :Sand
        try_move = (Settings::MECHANICS_GENERATION >= 6) ? :EARTHPOWER : :EARTHQUAKE
      when :Snow
        try_move = :BLIZZARD
        try_move = :FROSTBREATH if Settings::MECHANICS_GENERATION == 6
        try_move = :ICEBEAM if Settings::MECHANICS_GENERATION >= 7
      when :Ice
        try_move = :ICEBEAM
      when :Volcano
        try_move = :LAVAPLUME
      when :Graveyard
        try_move = :SHADOWBALL
      when :Sky
        try_move = :AIRSLASH
      when :Space
        try_move = :DRACOMETEOR
      when :UltraSpace
        try_move = :PSYSHOCK
      end
      @npMove = try_move if GameData::Move.exists?(try_move)
    end
  end

  def pbEffectAgainstTarget(user, target)
    @battle.pbDisplay(_INTL("{1} turned into {2}!", @name, GameData::Move.get(@npMove).name))
    user.pbUseMoveSimple(@npMove, target.index)
  end
end

#===============================================================================
# Uses a random move that exists. (Metronome)
#===============================================================================
class Battle::Move::UseRandomMove < Battle::Move
  def callsAnotherMove?; return true; end

  def initialize(battle, move)
    super
    @moveBlacklist = [
      "FlinchTargetFailsIfUserNotAsleep",                  # Snore
      "TargetActsNext",                                    # After You
      "TargetActsLast",                                    # Quash
      "TargetUsesItsLastUsedMoveAgain",                    # Instruct
      # Struggle, Belch
      "Struggle",                                          # Struggle
      "FailsIfUserNotConsumedBerry",                       # Belch
      # Moves that affect the moveset
      "ReplaceMoveThisBattleWithTargetLastMoveUsed",       # Mimic
      "ReplaceMoveWithTargetLastMoveUsed",                 # Sketch
      "TransformUserIntoTarget",                           # Transform
      # Counter moves
      "CounterPhysicalDamage",                             # Counter
      "CounterSpecialDamage",                              # Mirror Coat
      "CounterDamagePlusHalf",                             # Metal Burst        # Not listed on Bulbapedia
      # Helping Hand, Feint (always blacklisted together, don't know why)
      "PowerUpAllyMove",                                   # Helping Hand
      "RemoveProtections",                                 # Feint
      # Protection moves
      "ProtectUser",                                       # Detect, Protect
      "ProtectUserSideFromPriorityMoves",                  # Quick Guard
      "ProtectUserSideFromMultiTargetDamagingMoves",       # Wide Guard
      "UserEnduresFaintingThisTurn",                       # Endure
      "ProtectUserSideFromDamagingMovesIfUserFirstTurn",   # Mat Block
      "ProtectUserSideFromStatusMoves",                    # Crafty Shield
      "ProtectUserFromDamagingMovesKingsShield",           # King's Shield
      "ProtectUserFromDamagingMovesObstruct",              # Obstruct
      "ProtectUserFromTargetingMovesSpikyShield",          # Spiky Shield
      "ProtectUserBanefulBunker",                          # Baneful Bunker
      # Moves that call other moves
      "UseLastMoveUsedByTarget",                           # Mirror Move
      "UseLastMoveUsed",                                   # Copycat
      "UseMoveTargetIsAboutToUse",                         # Me First
      "UseMoveDependingOnEnvironment",                     # Nature Power
      "UseRandomUserMoveIfAsleep",                         # Sleep Talk
      "UseRandomMoveFromUserParty",                        # Assist
      "UseRandomMove",                                     # Metronome
      # Move-redirecting and stealing moves
      "BounceBackProblemCausingStatusMoves",               # Magic Coat         # Not listed on Bulbapedia
      "StealAndUseBeneficialStatusMove",                   # Snatch
      "RedirectAllMovesToUser",                            # Follow Me, Rage Powder
      "RedirectAllMovesToTarget",                          # Spotlight
      # Set up effects that trigger upon KO
      "ReduceAttackerMovePPTo0IfUserFaints",               # Grudge             # Not listed on Bulbapedia
      "AttackerFaintsIfUserFaints",                        # Destiny Bond
      # Held item-moving moves
      "UserTakesTargetItem",                               # Covet, Thief
      "UserTargetSwapItems",                               # Switcheroo, Trick
      "TargetTakesUserItem",                               # Bestow
      # Moves that start focussing at the start of the round
      "FailsIfUserDamagedThisTurn",                        # Focus Punch
      "UsedAfterUserTakesPhysicalDamage",                  # Shell Trap
      "BurnAttackerBeforeUserActs",                        # Beak Blast
      # Event moves that do nothing
      "DoesNothingFailsIfNoAlly",                          # Hold Hands
      "DoesNothingCongratulations"                         # Celebrate
    ]
  end

  def pbMoveFailed?(user, targets)
    @metronomeMove = nil
    move_keys = GameData::Move.keys
    # NOTE: You could be really unlucky and roll blacklisted moves 1000 times in
    #       a row. This is too unlikely to care about, though.
    1000.times do
      move_id = move_keys[@battle.pbRandom(move_keys.length)]
      move_data = GameData::Move.get(move_id)
      next if @moveBlacklist.include?(move_data.function_code)
      next if move_data.has_flag?("CannotMetronome")
      next if move_data.type == :SHADOW
      @metronomeMove = move_data.id
      break
    end
    if !@metronomeMove
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.pbUseMoveSimple(@metronomeMove)
  end
end

#===============================================================================
# Uses a random move known by any non-user Pokémon in the user's party. (Assist)
#===============================================================================
class Battle::Move::UseRandomMoveFromUserParty < Battle::Move
  def callsAnotherMove?; return true; end

  def initialize(battle, move)
    super
    @moveBlacklist = [
      # Struggle, Belch
      "Struggle",                                          # Struggle
      "FailsIfUserNotConsumedBerry",                       # Belch
      # Moves that affect the moveset
      "ReplaceMoveThisBattleWithTargetLastMoveUsed",       # Mimic
      "ReplaceMoveWithTargetLastMoveUsed",                 # Sketch
      "TransformUserIntoTarget",                           # Transform
      # Counter moves
      "CounterPhysicalDamage",                             # Counter
      "CounterSpecialDamage",                              # Mirror Coat
      "CounterDamagePlusHalf",                             # Metal Burst        # Not listed on Bulbapedia
      # Helping Hand, Feint (always blacklisted together, don't know why)
      "PowerUpAllyMove",                                   # Helping Hand
      "RemoveProtections",                                 # Feint
      # Protection moves
      "ProtectUser",                                       # Detect, Protect
      "ProtectUserSideFromPriorityMoves",                  # Quick Guard        # Not listed on Bulbapedia
      "ProtectUserSideFromMultiTargetDamagingMoves",       # Wide Guard         # Not listed on Bulbapedia
      "UserEnduresFaintingThisTurn",                       # Endure
      "ProtectUserSideFromDamagingMovesIfUserFirstTurn",   # Mat Block
      "ProtectUserSideFromStatusMoves",                    # Crafty Shield      # Not listed on Bulbapedia
      "ProtectUserFromDamagingMovesKingsShield",           # King's Shield
      "ProtectUserFromTargetingMovesSpikyShield",          # Spiky Shield
      "ProtectUserBanefulBunker",                          # Baneful Bunker
      # Moves that call other moves
      "UseLastMoveUsedByTarget",                           # Mirror Move
      "UseLastMoveUsed",                                   # Copycat
      "UseMoveTargetIsAboutToUse",                         # Me First
#      "UseMoveDependingOnEnvironment",                    # Nature Power       # See below
      "UseRandomUserMoveIfAsleep",                         # Sleep Talk
      "UseRandomMoveFromUserParty",                        # Assist
      "UseRandomMove",                                     # Metronome
      # Move-redirecting and stealing moves
      "BounceBackProblemCausingStatusMoves",               # Magic Coat         # Not listed on Bulbapedia
      "StealAndUseBeneficialStatusMove",                   # Snatch
      "RedirectAllMovesToUser",                            # Follow Me, Rage Powder
      "RedirectAllMovesToTarget",                          # Spotlight
      # Set up effects that trigger upon KO
      "ReduceAttackerMovePPTo0IfUserFaints",               # Grudge             # Not listed on Bulbapedia
      "AttackerFaintsIfUserFaints",                        # Destiny Bond
      # Target-switching moves
#      "SwitchOutTargetStatusMove",                        # Roar, Whirlwind    # See below
      "SwitchOutTargetDamagingMove",                       # Circle Throw, Dragon Tail
      # Held item-moving moves
      "UserTakesTargetItem",                               # Covet, Thief
      "UserTargetSwapItems",                               # Switcheroo, Trick
      "TargetTakesUserItem",                               # Bestow
      # Moves that start focussing at the start of the round
      "FailsIfUserDamagedThisTurn",                        # Focus Punch
      "UsedAfterUserTakesPhysicalDamage",                  # Shell Trap
      "BurnAttackerBeforeUserActs",                        # Beak Blast
      # Event moves that do nothing
      "DoesNothingFailsIfNoAlly",                          # Hold Hands
      "DoesNothingCongratulations"                         # Celebrate
    ]
    if Settings::MECHANICS_GENERATION >= 6
      @moveBlacklist += [
        # Moves that call other moves
        "UseMoveDependingOnEnvironment",                   # Nature Power
        # Two-turn attacks
        "TwoTurnAttack",                                   # Razor Wind                # Not listed on Bulbapedia
        "TwoTurnAttackOneTurnInSun",                       # Solar Beam, Solar Blade   # Not listed on Bulbapedia
        "TwoTurnAttackParalyzeTarget",                     # Freeze Shock              # Not listed on Bulbapedia
        "TwoTurnAttackBurnTarget",                         # Ice Burn                  # Not listed on Bulbapedia
        "TwoTurnAttackFlinchTarget",                       # Sky Attack                # Not listed on Bulbapedia
        "TwoTurnAttackChargeRaiseUserDefense1",            # Skull Bash                # Not listed on Bulbapedia
        "TwoTurnAttackInvulnerableInSky",                  # Fly
        "TwoTurnAttackInvulnerableUnderground",            # Dig
        "TwoTurnAttackInvulnerableUnderwater",             # Dive
        "TwoTurnAttackInvulnerableInSkyParalyzeTarget",    # Bounce
        "TwoTurnAttackInvulnerableRemoveProtections",      # Shadow Force/Phantom Force
        "TwoTurnAttackInvulnerableInSkyTargetCannotAct",   # Sky Drop
        "AllBattlersLoseHalfHPUserSkipsNextTurn",          # Shadow Half
        "TwoTurnAttackRaiseUserSpAtkSpDefSpd2",            # Geomancy                  # Not listed on Bulbapedia
        # Target-switching moves
        "SwitchOutTargetStatusMove"                        # Roar, Whirlwind
      ]
    end
  end

  def pbMoveFailed?(user, targets)
    @assistMoves = []
    # NOTE: This includes the Pokémon of ally trainers in multi battles.
    @battle.pbParty(user.index).each_with_index do |pkmn, i|
      next if !pkmn || i == user.pokemonIndex
      next if Settings::MECHANICS_GENERATION >= 6 && pkmn.egg?
      pkmn.moves.each do |move|
        next if @moveBlacklist.include?(move.function_code)
        next if move.type == :SHADOW
        @assistMoves.push(move.id)
      end
    end
    if @assistMoves.length == 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    move = @assistMoves[@battle.pbRandom(@assistMoves.length)]
    user.pbUseMoveSimple(move)
  end
end

#===============================================================================
# Uses a random move the user knows. Fails if user is not asleep. (Sleep Talk)
#===============================================================================
class Battle::Move::UseRandomUserMoveIfAsleep < Battle::Move
  def usableWhenAsleep?; return true; end
  def callsAnotherMove?; return true; end

  def initialize(battle, move)
    super
    @moveBlacklist = [
      "MultiTurnAttackPreventSleeping",                  # Uproar
      "MultiTurnAttackBideThenReturnDoubleDamage",       # Bide
      # Struggle, Belch
      "Struggle",                                        # Struggle             # Not listed on Bulbapedia
      "FailsIfUserNotConsumedBerry",                     # Belch
      # Moves that affect the moveset (except Transform)
      "ReplaceMoveThisBattleWithTargetLastMoveUsed",     # Mimic
      "ReplaceMoveWithTargetLastMoveUsed",               # Sketch
      # Moves that call other moves
      "UseLastMoveUsedByTarget",                         # Mirror Move
      "UseLastMoveUsed",                                 # Copycat
      "UseMoveTargetIsAboutToUse",                       # Me First
      "UseMoveDependingOnEnvironment",                   # Nature Power         # Not listed on Bulbapedia
      "UseRandomUserMoveIfAsleep",                       # Sleep Talk
      "UseRandomMoveFromUserParty",                      # Assist
      "UseRandomMove",                                   # Metronome
      # Two-turn attacks
      "TwoTurnAttack",                                   # Razor Wind
      "TwoTurnAttackOneTurnInSun",                       # Solar Beam, Solar Blade
      "TwoTurnAttackParalyzeTarget",                     # Freeze Shock
      "TwoTurnAttackBurnTarget",                         # Ice Burn
      "TwoTurnAttackFlinchTarget",                       # Sky Attack
      "TwoTurnAttackChargeRaiseUserDefense1",            # Skull Bash
      "TwoTurnAttackInvulnerableInSky",                  # Fly
      "TwoTurnAttackInvulnerableUnderground",            # Dig
      "TwoTurnAttackInvulnerableUnderwater",             # Dive
      "TwoTurnAttackInvulnerableInSkyParalyzeTarget",    # Bounce
      "TwoTurnAttackInvulnerableRemoveProtections",      # Shadow Force/Phantom Force
      "TwoTurnAttackInvulnerableInSkyTargetCannotAct",   # Sky Drop
      "AllBattlersLoseHalfHPUserSkipsNextTurn",          # Shadow Half
      "TwoTurnAttackRaiseUserSpAtkSpDefSpd2",            # Geomancy
      # Moves that start focussing at the start of the round
      "FailsIfUserDamagedThisTurn",                      # Focus Punch
      "UsedAfterUserTakesPhysicalDamage",                # Shell Trap
      "BurnAttackerBeforeUserActs"                       # Beak Blast
    ]
  end

  def pbMoveFailed?(user, targets)
    @sleepTalkMoves = []
    user.eachMoveWithIndex do |m, i|
      next if @moveBlacklist.include?(m.function)
      next if !@battle.pbCanChooseMove?(user.index, i, false, true)
      @sleepTalkMoves.push(i)
    end
    if !user.asleep? || @sleepTalkMoves.length == 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    choice = @sleepTalkMoves[@battle.pbRandom(@sleepTalkMoves.length)]
    user.pbUseMoveSimple(user.moves[choice].id, user.pbDirectOpposing.index)
  end
end

#===============================================================================
# This round, reflects all moves with the "C" flag targeting the user back at
# their origin. (Magic Coat)
#===============================================================================
class Battle::Move::BounceBackProblemCausingStatusMoves < Battle::Move
  def pbEffectGeneral(user)
    user.effects[PBEffects::MagicCoat] = true
    @battle.pbDisplay(_INTL("{1} shrouded itself with Magic Coat!", user.pbThis))
  end
end

#===============================================================================
# This round, snatches all used moves with the "D" flag. (Snatch)
#===============================================================================
class Battle::Move::StealAndUseBeneficialStatusMove < Battle::Move
  def pbEffectGeneral(user)
    user.effects[PBEffects::Snatch] = 1
    @battle.allBattlers.each do |b|
      next if b.effects[PBEffects::Snatch] < user.effects[PBEffects::Snatch]
      user.effects[PBEffects::Snatch] = b.effects[PBEffects::Snatch] + 1
    end
    @battle.pbDisplay(_INTL("{1} waits for a target to make a move!", user.pbThis))
  end
end

#===============================================================================
# This move turns into the last move used by the target, until user switches
# out. (Mimic)
#===============================================================================
class Battle::Move::ReplaceMoveThisBattleWithTargetLastMoveUsed < Battle::Move
  def ignoresSubstitute?(user); return true; end

  def initialize(battle, move)
    super
    @moveBlacklist = [
      "UseRandomMove",                                 # Metronome
      # Struggle
      "Struggle",                                      # Struggle
      # Moves that affect the moveset
      "ReplaceMoveThisBattleWithTargetLastMoveUsed",   # Mimic
      "ReplaceMoveWithTargetLastMoveUsed",             # Sketch
      "TransformUserIntoTarget"                        # Transform
    ]
  end

  def pbMoveFailed?(user, targets)
    if user.effects[PBEffects::Transform] || !user.pbHasMove?(@id)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    lastMoveData = GameData::Move.try_get(target.lastRegularMoveUsed)
    if !lastMoveData ||
       user.pbHasMove?(target.lastRegularMoveUsed) ||
       @moveBlacklist.include?(lastMoveData.function_code) ||
       lastMoveData.type == :SHADOW
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    user.eachMoveWithIndex do |m, i|
      next if m.id != @id
      newMove = Pokemon::Move.new(target.lastRegularMoveUsed)
      user.moves[i] = Battle::Move.from_pokemon_move(@battle, newMove)
      @battle.pbDisplay(_INTL("{1} learned {2}!", user.pbThis, newMove.name))
      user.pbCheckFormOnMovesetChange
      break
    end
  end
end

#===============================================================================
# This move permanently turns into the last move used by the target. (Sketch)
#===============================================================================
class Battle::Move::ReplaceMoveWithTargetLastMoveUsed < Battle::Move
  def ignoresSubstitute?(user); return true; end

  def initialize(battle, move)
    super
    @moveBlacklist = [
      "ReplaceMoveWithTargetLastMoveUsed",   # Sketch (this move)
      # Struggle
      "Struggle"                             # Struggle
    ]
  end

  def pbMoveFailed?(user, targets)
    if user.effects[PBEffects::Transform] || !user.pbHasMove?(@id)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    lastMoveData = GameData::Move.try_get(target.lastRegularMoveUsed)
    if !lastMoveData ||
       user.pbHasMove?(target.lastRegularMoveUsed) ||
       @moveBlacklist.include?(lastMoveData.function_code) ||
       lastMoveData.type == :SHADOW
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    user.eachMoveWithIndex do |m, i|
      next if m.id != @id
      newMove = Pokemon::Move.new(target.lastRegularMoveUsed)
      user.pokemon.moves[i] = newMove
      user.moves[i] = Battle::Move.from_pokemon_move(@battle, newMove)
      @battle.pbDisplay(_INTL("{1} learned {2}!", user.pbThis, newMove.name))
      user.pbCheckFormOnMovesetChange
      break
    end
  end
end
