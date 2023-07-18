# DO NOT USE ANY CLASS NAMES IN HERE AS FUNCTION CODES!
# These are base classes for other classes to build on; those other classes are
# named after function codes, so use those instead.

#===============================================================================
# Superclass that handles moves using a non-existent function code.
# Damaging moves just do damage with no additional effect.
# Status moves always fail.
#===============================================================================
class Battle::Move::Unimplemented < Battle::Move
  def pbMoveFailed?(user, targets)
    if statusMove?
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
end

#===============================================================================
# Pseudomove for confusion damage.
#===============================================================================
class Battle::Move::Confusion < Battle::Move
  def initialize(battle, move)
    @battle        = battle
    @realMove      = move
    @id            = :CONFUSEDAMAGE
    @name          = ""
    @function_code = "None"
    @power         = 40
    @type          = nil
    @category      = 0
    @accuracy      = 100
    @pp            = -1
    @target        = :User
    @priority      = 0
    @flags         = []
    @addlEffect    = 0
    @powerBoost    = false
    @snatched      = false
  end

  def physicalMove?(thisType = nil);   return true;  end
  def specialMove?(thisType = nil);    return false; end
  def pbCritialOverride(user, target); return -1;    end
end

#===============================================================================
# Struggle.
#===============================================================================
class Battle::Move::Struggle < Battle::Move
  def initialize(battle, move)
    @battle        = battle
    @realMove      = nil                     # Not associated with a move
    @id            = :STRUGGLE
    @name          = _INTL("Struggle")
    @function_code = "Struggle"
    @power         = 50
    @type          = nil
    @category      = 0
    @accuracy      = 0
    @pp            = -1
    @target        = :RandomNearFoe
    @priority      = 0
    @flags         = ["Contact", "CanProtect"]
    @addlEffect    = 0
    @powerBoost    = false
    @snatched      = false
  end

  def physicalMove?(thisType = nil); return true;  end
  def specialMove?(thisType = nil);  return false; end

  def pbEffectAfterAllHits(user, target)
    return if target.damageState.unaffected
    user.pbReduceHP((user.totalhp / 4.0).round, false)
    @battle.pbDisplay(_INTL("{1} is damaged by recoil!", user.pbThis))
    user.pbItemHPHealCheck
  end
end

#===============================================================================
# Raise one of user's stats.
#===============================================================================
class Battle::Move::StatUpMove < Battle::Move
  attr_reader :statUp

  def canSnatch?; return true; end

  def pbMoveFailed?(user, targets)
    return false if damagingMove?
    return !user.pbCanRaiseStatStage?(@statUp[0], user, self, true)
  end

  def pbEffectGeneral(user)
    return if damagingMove?
    user.pbRaiseStatStage(@statUp[0], @statUp[1], user)
  end

  def pbAdditionalEffect(user, target)
    if user.pbCanRaiseStatStage?(@statUp[0], user, self)
      user.pbRaiseStatStage(@statUp[0], @statUp[1], user)
    end
  end
end

#===============================================================================
# Raise multiple of user's stats.
#===============================================================================
class Battle::Move::MultiStatUpMove < Battle::Move
  attr_reader :statUp

  def canSnatch?; return true; end

  def pbMoveFailed?(user, targets)
    return false if damagingMove?
    failed = true
    (@statUp.length / 2).times do |i|
      next if !user.pbCanRaiseStatStage?(@statUp[i * 2], user, self)
      failed = false
      break
    end
    if failed
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!", user.pbThis))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    return if damagingMove?
    showAnim = true
    (@statUp.length / 2).times do |i|
      next if !user.pbCanRaiseStatStage?(@statUp[i * 2], user, self)
      if user.pbRaiseStatStage(@statUp[i * 2], @statUp[(i * 2) + 1], user, showAnim)
        showAnim = false
      end
    end
  end

  def pbAdditionalEffect(user, target)
    showAnim = true
    (@statUp.length / 2).times do |i|
      next if !user.pbCanRaiseStatStage?(@statUp[i * 2], user, self)
      if user.pbRaiseStatStage(@statUp[i * 2], @statUp[(i * 2) + 1], user, showAnim)
        showAnim = false
      end
    end
  end
end

#===============================================================================
# Lower multiple of user's stats.
#===============================================================================
class Battle::Move::StatDownMove < Battle::Move
  attr_reader :statDown

  def pbEffectWhenDealingDamage(user, target)
    return if @battle.pbAllFainted?(target.idxOwnSide)
    showAnim = true
    (@statDown.length / 2).times do |i|
      next if !user.pbCanLowerStatStage?(@statDown[i * 2], user, self)
      if user.pbLowerStatStage(@statDown[i * 2], @statDown[(i * 2) + 1], user, showAnim)
        showAnim = false
      end
    end
  end
end

#===============================================================================
# Lower one of target's stats.
#===============================================================================
class Battle::Move::TargetStatDownMove < Battle::Move
  attr_reader :statDown

  def canMagicCoat?; return true; end

  def pbFailsAgainstTarget?(user, target, show_message)
    return false if damagingMove?
    return !target.pbCanLowerStatStage?(@statDown[0], user, self, show_message)
  end

  def pbEffectAgainstTarget(user, target)
    return if damagingMove?
    target.pbLowerStatStage(@statDown[0], @statDown[1], user)
  end

  def pbAdditionalEffect(user, target)
    return if target.damageState.substitute
    return if !target.pbCanLowerStatStage?(@statDown[0], user, self)
    target.pbLowerStatStage(@statDown[0], @statDown[1], user)
  end
end

#===============================================================================
# Lower multiple of target's stats.
#===============================================================================
class Battle::Move::TargetMultiStatDownMove < Battle::Move
  attr_reader :statDown

  def canMagicCoat?; return true; end

  def pbFailsAgainstTarget?(user, target, show_message)
    return false if damagingMove?
    failed = true
    (@statDown.length / 2).times do |i|
      next if !target.pbCanLowerStatStage?(@statDown[i * 2], user, self)
      failed = false
      break
    end
    if failed
      # NOTE: It's a bit of a faff to make sure the appropriate failure message
      #       is shown here, I know.
      canLower = false
      if target.hasActiveAbility?(:CONTRARY) && !@battle.moldBreaker
        (@statDown.length / 2).times do |i|
          next if target.statStageAtMax?(@statDown[i * 2])
          canLower = true
          break
        end
        @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!", user.pbThis)) if !canLower && show_message
      else
        (@statDown.length / 2).times do |i|
          next if target.statStageAtMin?(@statDown[i * 2])
          canLower = true
          break
        end
        @battle.pbDisplay(_INTL("{1}'s stats won't go any lower!", user.pbThis)) if !canLower && show_message
      end
      if canLower
        target.pbCanLowerStatStage?(@statDown[0], user, self, show_message)
      end
      return true
    end
    return false
  end

  def pbCheckForMirrorArmor(user, target)
    if target.hasActiveAbility?(:MIRRORARMOR) && user.index != target.index
      failed = true
      (@statDown.length / 2).times do |i|
        next if target.statStageAtMin?(@statDown[i * 2])
        next if !user.pbCanLowerStatStage?(@statDown[i * 2], target, self, false, false, true)
        failed = false
        break
      end
      if failed
        @battle.pbShowAbilitySplash(target)
        if !Battle::Scene::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("{1}'s {2} activated!", target.pbThis, target.abilityName))
        end
        user.pbCanLowerStatStage?(@statDown[0], target, self, true, false, true)   # Show fail message
        @battle.pbHideAbilitySplash(target)
        return false
      end
    end
    return true
  end

  def pbLowerTargetMultipleStats(user, target)
    return if !pbCheckForMirrorArmor(user, target)
    showAnim = true
    showMirrorArmorSplash = true
    (@statDown.length / 2).times do |i|
      next if !target.pbCanLowerStatStage?(@statDown[i * 2], user, self)
      if target.pbLowerStatStage(@statDown[i * 2], @statDown[(i * 2) + 1], user,
                                 showAnim, false, (showMirrorArmorSplash) ? 1 : 3)
        showAnim = false
      end
      showMirrorArmorSplash = false
    end
    @battle.pbHideAbilitySplash(target)   # To hide target's Mirror Armor splash
  end

  def pbEffectAgainstTarget(user, target)
    pbLowerTargetMultipleStats(user, target) if !damagingMove?
  end

  def pbAdditionalEffect(user, target)
    pbLowerTargetMultipleStats(user, target) if !target.damageState.substitute
  end
end

#===============================================================================
# Fixed damage-inflicting move.
#===============================================================================
class Battle::Move::FixedDamageMove < Battle::Move
  def pbFixedDamage(user, target); return 1; end

  def pbCalcDamage(user, target, numTargets = 1)
    target.damageState.critical   = false
    target.damageState.calcDamage = pbFixedDamage(user, target)
    target.damageState.calcDamage = 1 if target.damageState.calcDamage < 1
  end
end

#===============================================================================
# Two turn move.
#===============================================================================
class Battle::Move::TwoTurnMove < Battle::Move
  attr_reader :chargingTurn

  def chargingTurnMove?; return true; end

  # user.effects[PBEffects::TwoTurnAttack] is set to the move's ID if this
  # method returns true, or nil if false.
  # Non-nil means the charging turn. nil means the attacking turn.
  def pbIsChargingTurn?(user)
    @powerHerb = false
    @chargingTurn = false   # Assume damaging turn by default
    @damagingTurn = true
    # nil at start of charging turn, move's ID at start of damaging turn
    if !user.effects[PBEffects::TwoTurnAttack]
      @powerHerb = user.hasActiveItem?(:POWERHERB)
      @chargingTurn = true
      @damagingTurn = @powerHerb
    end
    return !@damagingTurn   # Deliberately not "return @chargingTurn"
  end

  # Stops damage being dealt in the first (charging) turn.
  def pbDamagingMove?
    return false if !@damagingTurn
    return super
  end

  # Does the charging part of this move, for when this move only takes one round
  # to use.
  def pbQuickChargingMove(user, targets)
    return if !@chargingTurn || !@damagingTurn   # Move only takes one turn to use
    pbChargingTurnMessage(user, targets)
    pbShowAnimation(@id, user, targets, 1)   # Charging anim
    targets.each { |b| pbChargingTurnEffect(user, b) }
    if @powerHerb
      # Moves that would make the user semi-invulnerable will hide the user
      # after the charging animation, so the "UseItem" animation shouldn't show
      # for it
      if !["TwoTurnAttackInvulnerableInSky",
           "TwoTurnAttackInvulnerableUnderground",
           "TwoTurnAttackInvulnerableUnderwater",
           "TwoTurnAttackInvulnerableInSkyParalyzeTarget",
           "TwoTurnAttackInvulnerableRemoveProtections",
           "TwoTurnAttackInvulnerableInSkyTargetCannotAct"].include?(@function_code)
        @battle.pbCommonAnimation("UseItem", user)
      end
      @battle.pbDisplay(_INTL("{1} became fully charged due to its Power Herb!", user.pbThis))
      user.pbConsumeItem
    end
  end

  def pbAccuracyCheck(user, target)
    return true if !@damagingTurn
    return super
  end

  def pbInitialEffect(user, targets, hitNum)
    if @damagingTurn
      pbAttackingTurnMessage(user, targets)
    elsif @chargingTurn
      pbChargingTurnMessage(user, targets)
    end
  end

  def pbChargingTurnMessage(user, targets)
    @battle.pbDisplay(_INTL("{1} began charging up!", user.pbThis))
  end

  def pbAttackingTurnMessage(user, targets); end

  def pbEffectAgainstTarget(user, target)
    if @damagingTurn
      pbAttackingTurnEffect(user, target)
    elsif @chargingTurn
      pbChargingTurnEffect(user, target)
    end
  end

  def pbChargingTurnEffect(user, target)
    # Skull Bash/Sky Drop are the only two-turn moves with an effect here, and
    # the latter just records the target is being Sky Dropped
  end

  def pbAttackingTurnEffect(user, target); end

  def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    hitNum = 1 if @chargingTurn && !@damagingTurn   # Charging anim
    super
  end
end

#===============================================================================
# Healing move.
#===============================================================================
class Battle::Move::HealingMove < Battle::Move
  def healingMove?;       return true; end
  def pbHealAmount(user); return 1;    end
  def canSnatch?;         return true; end

  def pbMoveFailed?(user, targets)
    if user.hp == user.totalhp
      @battle.pbDisplay(_INTL("{1}'s HP is full!", user.pbThis))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    amt = pbHealAmount(user)
    user.pbRecoverHP(amt)
    @battle.pbDisplay(_INTL("{1}'s HP was restored.", user.pbThis))
  end
end

#===============================================================================
# Recoil move.
#===============================================================================
class Battle::Move::RecoilMove < Battle::Move
  def recoilMove?;                  return true; end
  def pbRecoilDamage(user, target); return 1;    end

  def pbEffectAfterAllHits(user, target)
    return if target.damageState.unaffected
    return if !user.takesIndirectDamage?
    return if user.hasActiveAbility?(:ROCKHEAD)
    amt = pbRecoilDamage(user, target)
    amt = 1 if amt < 1
    user.pbReduceHP(amt, false)
    @battle.pbDisplay(_INTL("{1} is damaged by recoil!", user.pbThis))
    user.pbItemHPHealCheck
  end
end

#===============================================================================
# Protect move.
#===============================================================================
class Battle::Move::ProtectMove < Battle::Move
  def initialize(battle, move)
    super
    @sidedEffect = false
  end

  def pbChangeUsageCounters(user, specialUsage)
    oldVal = user.effects[PBEffects::ProtectRate]
    super
    user.effects[PBEffects::ProtectRate] = oldVal
  end

  def pbMoveFailed?(user, targets)
    if @sidedEffect
      if user.pbOwnSide.effects[@effect]
        user.effects[PBEffects::ProtectRate] = 1
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
    elsif user.effects[@effect]
      user.effects[PBEffects::ProtectRate] = 1
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    if (!@sidedEffect || Settings::MECHANICS_GENERATION <= 5) &&
       user.effects[PBEffects::ProtectRate] > 1 &&
       @battle.pbRandom(user.effects[PBEffects::ProtectRate]) != 0
      user.effects[PBEffects::ProtectRate] = 1
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    if pbMoveFailedLastInRound?(user)
      user.effects[PBEffects::ProtectRate] = 1
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    if @sidedEffect
      user.pbOwnSide.effects[@effect] = true
    else
      user.effects[@effect] = true
    end
    user.effects[PBEffects::ProtectRate] *= (Settings::MECHANICS_GENERATION >= 6) ? 3 : 2
    pbProtectMessage(user)
  end

  def pbProtectMessage(user)
    if @sidedEffect
      @battle.pbDisplay(_INTL("{1} protected {2}!", @name, user.pbTeam(true)))
    else
      @battle.pbDisplay(_INTL("{1} protected itself!", user.pbThis))
    end
  end
end

#===============================================================================
# Weather-inducing move.
#===============================================================================
class Battle::Move::WeatherMove < Battle::Move
  attr_reader :weatherType

  def initialize(battle, move)
    super
    @weatherType = :None
  end

  def pbMoveFailed?(user, targets)
    case @battle.field.weather
    when :HarshSun
      @battle.pbDisplay(_INTL("The extremely harsh sunlight was not lessened at all!"))
      return true
    when :HeavyRain
      @battle.pbDisplay(_INTL("There is no relief from this heavy rain!"))
      return true
    when :StrongWinds
      @battle.pbDisplay(_INTL("The mysterious air current blows on regardless!"))
      return true
    when @weatherType
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.pbStartWeather(user, @weatherType, true, false)
  end
end

#===============================================================================
# Pledge move.
#===============================================================================
class Battle::Move::PledgeMove < Battle::Move
  def pbOnStartUse(user, targets)
    @pledgeSetup = false
    @pledgeCombo = false
    @pledgeOtherUser = nil
    @comboEffect = nil
    @overrideAnim = nil
    # Check whether this is the use of a combo move
    @combos.each do |i|
      next if i[0] != user.effects[PBEffects::FirstPledge]
      @battle.pbDisplay(_INTL("The two moves have become one! It's a combined move!"))
      @pledgeCombo = true
      @comboEffect = i[1]
      @overrideAnim = i[3]
      break
    end
    return if @pledgeCombo
    # Check whether this is the setup of a combo move
    user.allAllies.each do |b|
      next if @battle.choices[b.index][0] != :UseMove || b.movedThisRound?
      move = @battle.choices[b.index][2]
      next if !move
      @combos.each do |i|
        next if i[0] != move.function_code
        @pledgeSetup = true
        @pledgeOtherUser = b
        break
      end
      break if @pledgeSetup
    end
  end

  def pbDamagingMove?
    return false if @pledgeSetup
    return super
  end

  def pbBaseType(user)
    # This method is called before pbOnStartUse, so it has to calculate the type
    # separately
    @combos.each do |i|
      next if i[0] != user.effects[PBEffects::FirstPledge]
      next if !GameData::Type.exists?(i[2])
      return i[2]
    end
    return super
  end

  def pbBaseDamage(baseDmg, user, target)
    baseDmg *= 2 if @pledgeCombo
    return baseDmg
  end

  def pbEffectGeneral(user)
    user.effects[PBEffects::FirstPledge] = nil
    return if !@pledgeSetup
    @battle.pbDisplay(_INTL("{1} is waiting for {2}'s move...",
                            user.pbThis, @pledgeOtherUser.pbThis(true)))
    @pledgeOtherUser.effects[PBEffects::FirstPledge] = @function_code
    @pledgeOtherUser.effects[PBEffects::MoveNext]    = true
    user.lastMoveFailed = true   # Treated as a failure for Stomping Tantrum
  end

  def pbEffectAfterAllHits(user, target)
    return if !@pledgeCombo
    msg = nil
    animName = nil
    case @comboEffect
    when :SeaOfFire   # Grass + Fire
      if user.pbOpposingSide.effects[PBEffects::SeaOfFire] == 0
        user.pbOpposingSide.effects[PBEffects::SeaOfFire] = 4
        msg = _INTL("A sea of fire enveloped {1}!", user.pbOpposingTeam(true))
        animName = (user.opposes?) ? "SeaOfFire" : "SeaOfFireOpp"
      end
    when :Rainbow   # Fire + Water
      if user.pbOwnSide.effects[PBEffects::Rainbow] == 0
        user.pbOwnSide.effects[PBEffects::Rainbow] = 4
        msg = _INTL("A rainbow appeared in the sky on {1}'s side!", user.pbTeam(true))
        animName = (user.opposes?) ? "RainbowOpp" : "Rainbow"
      end
    when :Swamp   # Water + Grass
      if user.pbOpposingSide.effects[PBEffects::Swamp] == 0
        user.pbOpposingSide.effects[PBEffects::Swamp] = 4
        msg = _INTL("A swamp enveloped {1}!", user.pbOpposingTeam(true))
        animName = (user.opposes?) ? "Swamp" : "SwampOpp"
      end
    end
    @battle.pbDisplay(msg) if msg
    @battle.pbCommonAnimation(animName) if animName
  end

  def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    return if @pledgeSetup   # No animation for setting up
    id = @overrideAnim if @overrideAnim
    return super
  end
end
