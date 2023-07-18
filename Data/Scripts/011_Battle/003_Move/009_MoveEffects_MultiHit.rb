#===============================================================================
# Hits twice.
#===============================================================================
class Battle::Move::HitTwoTimes < Battle::Move
  def multiHitMove?;            return true; end
  def pbNumHits(user, targets); return 2;    end
end

#===============================================================================
# Hits twice. May poison the target on each hit. (Twineedle)
#===============================================================================
class Battle::Move::HitTwoTimesPoisonTarget < Battle::Move::PoisonTarget
  def multiHitMove?;            return true; end
  def pbNumHits(user, targets); return 2;    end
end

#===============================================================================
# Hits twice. Causes the target to flinch. (Double Iron Bash)
#===============================================================================
class Battle::Move::HitTwoTimesFlinchTarget < Battle::Move::FlinchTarget
  def multiHitMove?;            return true; end
  def pbNumHits(user, targets); return 2;    end
end

#===============================================================================
# Hits in 2 volleys. The second volley targets the original target's ally if it
# has one (that can be targeted), or the original target if not. A battler
# cannot be targeted if it is is immune to or protected from this move somehow,
# or if this move will miss it. (Dragon Darts)
# NOTE: This move sometimes shows a different failure message compared to the
#       official games. This is because of the order in which failure checks are
#       done (all checks for each target in turn, versus all targets for each
#       check in turn). This is considered unimportant, and since correcting it
#       would involve extensive code rewrites, it is being ignored.
#===============================================================================
class Battle::Move::HitTwoTimesTargetThenTargetAlly < Battle::Move
  def pbNumHits(user, targets); return 1;    end
  def pbRepeatHit?;             return true; end

  def pbModifyTargets(targets, user)
    return if targets.length != 1
    choices = []
    targets[0].allAllies.each { |b| user.pbAddTarget(choices, user, b, self) }
    return if choices.length == 0
    idxChoice = (choices.length > 1) ? @battle.pbRandom(choices.length) : 0
    user.pbAddTarget(targets, user, choices[idxChoice], self, !pbTarget(user).can_choose_distant_target?)
  end

  def pbShowFailMessages?(targets)
    if targets.length > 1
      valid_targets = targets.select { |b| !b.fainted? && !b.damageState.unaffected }
      return valid_targets.length <= 1
    end
    return super
  end

  def pbDesignateTargetsForHit(targets, hitNum)
    valid_targets = []
    targets.each { |b| valid_targets.push(b) if !b.damageState.unaffected }
    return [valid_targets[1]] if valid_targets[1] && hitNum == 1
    return [valid_targets[0]]
  end
end

#===============================================================================
# Hits 3 times. Power is multiplied by the hit number. (Triple Kick)
# An accuracy check is performed for each hit.
#===============================================================================
class Battle::Move::HitThreeTimesPowersUpWithEachHit < Battle::Move
  def multiHitMove?;            return true; end
  def pbNumHits(user, targets); return 3;    end

  def successCheckPerHit?
    return @accCheckPerHit
  end

  def pbOnStartUse(user, targets)
    @calcBaseDmg = 0
    @accCheckPerHit = !user.hasActiveAbility?(:SKILLLINK)
  end

  def pbBaseDamage(baseDmg, user, target)
    @calcBaseDmg += baseDmg
    return @calcBaseDmg
  end
end

#===============================================================================
# Hits 3 times in a row. If each hit could be a critical hit, it will definitely
# be a critical hit. (Surging Strikes)
#===============================================================================
class Battle::Move::HitThreeTimesAlwaysCriticalHit < Battle::Move
  def multiHitMove?;                   return true; end
  def pbNumHits(user, targets);        return 3;    end
  def pbCritialOverride(user, target); return 1;    end
end

#===============================================================================
# Hits 2-5 times.
#===============================================================================
class Battle::Move::HitTwoToFiveTimes < Battle::Move
  def multiHitMove?; return true; end

  def pbNumHits(user, targets)
    hitChances = [
      2, 2, 2, 2, 2, 2, 2,
      3, 3, 3, 3, 3, 3, 3,
      4, 4, 4,
      5, 5, 5
    ]
    r = @battle.pbRandom(hitChances.length)
    r = hitChances.length - 1 if user.hasActiveAbility?(:SKILLLINK)
    return hitChances[r]
  end
end

#===============================================================================
# Hits 2-5 times. If the user is Ash Greninja, powers up and hits 3 times.
# (Water Shuriken)
#===============================================================================
class Battle::Move::HitTwoToFiveTimesOrThreeForAshGreninja < Battle::Move::HitTwoToFiveTimes
  def pbNumHits(user, targets)
    return 3 if user.isSpecies?(:GRENINJA) && user.form == 2
    return super
  end

  def pbBaseDamage(baseDmg, user, target)
    return 20 if user.isSpecies?(:GRENINJA) && user.form == 2
    return super
  end
end

#===============================================================================
# Hits 2-5 times in a row. If the move does not fail, increases the user's Speed
# by 1 stage and decreases the user's Defense by 1 stage. (Scale Shot)
#===============================================================================
class Battle::Move::HitTwoToFiveTimesRaiseUserSpd1LowerUserDef1 < Battle::Move::HitTwoToFiveTimes
  def pbEffectAfterAllHits(user, target)
    return if target.damageState.unaffected
    if user.pbCanLowerStatStage?(:DEFENSE, user, self)
      user.pbLowerStatStage(:DEFENSE, 1, user)
    end
    if user.pbCanRaiseStatStage?(:SPEED, user, self)
      user.pbRaiseStatStage(:SPEED, 1, user)
    end
  end
end

#===============================================================================
# Hits X times, where X is the number of non-user unfainted status-free Pokémon
# in the user's party (not including partner trainers). Fails if X is 0.
# Base power of each hit depends on the base Attack stat for the species of that
# hit's participant. (Beat Up)
#===============================================================================
class Battle::Move::HitOncePerUserTeamMember < Battle::Move
  def multiHitMove?; return true; end

  def pbMoveFailed?(user, targets)
    @beatUpList = []
    @battle.eachInTeamFromBattlerIndex(user.index) do |pkmn, i|
      next if !pkmn.able? || pkmn.status != :NONE
      @beatUpList.push(i)
    end
    if @beatUpList.length == 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbNumHits(user, targets)
    return @beatUpList.length
  end

  def pbBaseDamage(baseDmg, user, target)
    i = @beatUpList.shift   # First element in array, and removes it from array
    atk = @battle.pbParty(user.index)[i].baseStats[:ATTACK]
    return 5 + (atk / 10)
  end
end

#===============================================================================
# Attacks first turn, skips second turn (if successful).
#===============================================================================
class Battle::Move::AttackAndSkipNextTurn < Battle::Move
  def pbEffectGeneral(user)
    user.effects[PBEffects::HyperBeam] = 2
    user.currentMove = @id
  end
end

#===============================================================================
# Two turn attack. Skips first turn, attacks second turn. (Razor Wind)
#===============================================================================
class Battle::Move::TwoTurnAttack < Battle::Move::TwoTurnMove
  def pbChargingTurnMessage(user, targets)
    @battle.pbDisplay(_INTL("{1} whipped up a whirlwind!", user.pbThis))
  end
end

#===============================================================================
# Two turn attack. Skips first turn, attacks second turn. (Solar Beam, Solar Blade)
# Power halved in all weather except sunshine. In sunshine, takes 1 turn instead.
#===============================================================================
class Battle::Move::TwoTurnAttackOneTurnInSun < Battle::Move::TwoTurnMove
  def pbIsChargingTurn?(user)
    ret = super
    if !user.effects[PBEffects::TwoTurnAttack] &&
       [:Sun, :HarshSun].include?(user.effectiveWeather)
      @powerHerb = false
      @chargingTurn = true
      @damagingTurn = true
      return false
    end
    return ret
  end

  def pbChargingTurnMessage(user, targets)
    @battle.pbDisplay(_INTL("{1} took in sunlight!", user.pbThis))
  end

  def pbBaseDamageMultiplier(damageMult, user, target)
    damageMult /= 2 if ![:None, :Sun, :HarshSun].include?(user.effectiveWeather)
    return damageMult
  end
end

#===============================================================================
# Two turn attack. Skips first turn, attacks second turn. (Freeze Shock)
# May paralyze the target.
#===============================================================================
class Battle::Move::TwoTurnAttackParalyzeTarget < Battle::Move::TwoTurnMove
  def pbChargingTurnMessage(user, targets)
    @battle.pbDisplay(_INTL("{1} became cloaked in a freezing light!", user.pbThis))
  end

  def pbAdditionalEffect(user, target)
    return if target.damageState.substitute
    target.pbParalyze(user) if target.pbCanParalyze?(user, false, self)
  end
end

#===============================================================================
# Two turn attack. Skips first turn, attacks second turn. (Ice Burn)
# May burn the target.
#===============================================================================
class Battle::Move::TwoTurnAttackBurnTarget < Battle::Move::TwoTurnMove
  def pbChargingTurnMessage(user, targets)
    @battle.pbDisplay(_INTL("{1} became cloaked in freezing air!", user.pbThis))
  end

  def pbAdditionalEffect(user, target)
    return if target.damageState.substitute
    target.pbBurn(user) if target.pbCanBurn?(user, false, self)
  end
end

#===============================================================================
# Two turn attack. Skips first turn, attacks second turn. (Sky Attack)
# May make the target flinch.
#===============================================================================
class Battle::Move::TwoTurnAttackFlinchTarget < Battle::Move::TwoTurnMove
  def flinchingMove?; return true; end

  def pbChargingTurnMessage(user, targets)
    @battle.pbDisplay(_INTL("{1} became cloaked in a harsh light!", user.pbThis))
  end

  def pbAdditionalEffect(user, target)
    return if target.damageState.substitute
    target.pbFlinch(user)
  end
end

#===============================================================================
# Two turn attack. Skips first turn, and increases the user's Special Attack,
# Special Defense and Speed by 2 stages each in the second turn. (Geomancy)
#===============================================================================
class Battle::Move::TwoTurnAttackRaiseUserSpAtkSpDefSpd2 < Battle::Move::TwoTurnMove
  attr_reader :statUp

  def initialize(battle, move)
    super
    @statUp = [:SPECIAL_ATTACK, 2, :SPECIAL_DEFENSE, 2, :SPEED, 2]
  end

  def pbMoveFailed?(user, targets)
    return false if user.effects[PBEffects::TwoTurnAttack]   # Charging turn
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

  def pbChargingTurnMessage(user, targets)
    @battle.pbDisplay(_INTL("{1} is absorbing power!", user.pbThis))
  end

  def pbEffectGeneral(user)
    return if !@damagingTurn
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
# Two turn attack. Ups user's Defense by 1 stage first turn, attacks second turn.
# (Skull Bash)
#===============================================================================
class Battle::Move::TwoTurnAttackChargeRaiseUserDefense1 < Battle::Move::TwoTurnMove
  attr_reader :statUp

  def initialize(battle, move)
    super
    @statUp = [:DEFENSE, 1]
  end

  def pbChargingTurnMessage(user, targets)
    @battle.pbDisplay(_INTL("{1} tucked in its head!", user.pbThis))
  end

  def pbChargingTurnEffect(user, target)
    if user.pbCanRaiseStatStage?(@statUp[0], user, self)
      user.pbRaiseStatStage(@statUp[0], @statUp[1], user)
    end
  end
end

#===============================================================================
# Two-turn attack. On the first turn, increases the user's Special Attack by 1
# stage. On the second turn, does damage. (Meteor Beam)
#===============================================================================
class Battle::Move::TwoTurnAttackChargeRaiseUserSpAtk1 < Battle::Move::TwoTurnMove
  attr_reader :statUp

  def initialize(battle, move)
    super
    @statUp = [:SPECIAL_ATTACK, 1]
  end

  def pbChargingTurnMessage(user, targets)
    @battle.pbDisplay(_INTL("{1} is overflowing with space power!", user.pbThis))
  end

  def pbChargingTurnEffect(user, target)
    if user.pbCanRaiseStatStage?(@statUp[0], user, self)
      user.pbRaiseStatStage(@statUp[0], @statUp[1], user)
    end
  end
end

#===============================================================================
# Two turn attack. Skips first turn, attacks second turn. (Dig)
# (Handled in Battler's pbSuccessCheckPerHit): Is semi-invulnerable during use.
#===============================================================================
class Battle::Move::TwoTurnAttackInvulnerableUnderground < Battle::Move::TwoTurnMove
  def pbChargingTurnMessage(user, targets)
    @battle.pbDisplay(_INTL("{1} burrowed its way under the ground!", user.pbThis))
  end
end

#===============================================================================
# Two turn attack. Skips first turn, attacks second turn. (Dive)
# (Handled in Battler's pbSuccessCheckPerHit): Is semi-invulnerable during use.
#===============================================================================
class Battle::Move::TwoTurnAttackInvulnerableUnderwater < Battle::Move::TwoTurnMove
  def pbChargingTurnMessage(user, targets)
    @battle.pbDisplay(_INTL("{1} hid underwater!", user.pbThis))
  end
end

#===============================================================================
# Two turn attack. Skips first turn, attacks second turn. (Fly)
# (Handled in Battler's pbSuccessCheckPerHit): Is semi-invulnerable during use.
#===============================================================================
class Battle::Move::TwoTurnAttackInvulnerableInSky < Battle::Move::TwoTurnMove
  def unusableInGravity?; return true; end

  def pbChargingTurnMessage(user, targets)
    @battle.pbDisplay(_INTL("{1} flew up high!", user.pbThis))
  end
end

#===============================================================================
# Two turn attack. Skips first turn, attacks second turn. (Bounce)
# May paralyze the target.
# (Handled in Battler's pbSuccessCheckPerHit): Is semi-invulnerable during use.
#===============================================================================
class Battle::Move::TwoTurnAttackInvulnerableInSkyParalyzeTarget < Battle::Move::TwoTurnMove
  def unusableInGravity?; return true; end

  def pbChargingTurnMessage(user, targets)
    @battle.pbDisplay(_INTL("{1} sprang up!", user.pbThis))
  end

  def pbAdditionalEffect(user, target)
    return if target.damageState.substitute
    target.pbParalyze(user) if target.pbCanParalyze?(user, false, self)
  end
end

#===============================================================================
# Two turn attack. Skips first turn, attacks second turn. (Sky Drop)
# (Handled in Battler's pbSuccessCheckPerHit): Is semi-invulnerable during use.
# Target is also semi-invulnerable during use, and can't take any action.
# Doesn't damage airborne Pokémon (but still makes them unable to move during).
#===============================================================================
class Battle::Move::TwoTurnAttackInvulnerableInSkyTargetCannotAct < Battle::Move::TwoTurnMove
  def unusableInGravity?; return true; end

  def pbIsChargingTurn?(user)
    # NOTE: Sky Drop doesn't benefit from Power Herb, probably because it works
    #       differently (i.e. immobilises the target during use too).
    @powerHerb = false
    @chargingTurn = (user.effects[PBEffects::TwoTurnAttack].nil?)
    @damagingTurn = (!user.effects[PBEffects::TwoTurnAttack].nil?)
    return !@damagingTurn
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    if !target.opposes?(user)
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    if target.effects[PBEffects::Substitute] > 0 && !ignoresSubstitute?(user)
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    if Settings::MECHANICS_GENERATION >= 6 && target.pbWeight >= 2000   # 200.0kg
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    if target.semiInvulnerable? ||
       (target.effects[PBEffects::SkyDrop] >= 0 && @chargingTurn)
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    if target.effects[PBEffects::SkyDrop] != user.index && @damagingTurn
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end

  def pbCalcTypeMod(movetype, user, target)
    return Effectiveness::INEFFECTIVE_MULTIPLIER if target.pbHasType?(:FLYING)
    return super
  end

  def pbChargingTurnMessage(user, targets)
    @battle.pbDisplay(_INTL("{1} took {2} into the sky!", user.pbThis, targets[0].pbThis(true)))
  end

  def pbAttackingTurnMessage(user, targets)
    @battle.pbDisplay(_INTL("{1} was freed from the Sky Drop!", targets[0].pbThis))
  end

  def pbChargingTurnEffect(user, target)
    target.effects[PBEffects::SkyDrop] = user.index
  end

  def pbEffectAfterAllHits(user, target)
    target.effects[PBEffects::SkyDrop] = -1 if @damagingTurn
  end
end

#===============================================================================
# Two turn attack. Skips first turn, attacks second turn. Is invulnerable during
# use. Ends target's protections upon hit. (Shadow Force, Phantom Force)
#===============================================================================
class Battle::Move::TwoTurnAttackInvulnerableRemoveProtections < Battle::Move::TwoTurnMove
  def pbChargingTurnMessage(user, targets)
    @battle.pbDisplay(_INTL("{1} vanished instantly!", user.pbThis))
  end

  def pbAttackingTurnEffect(user, target)
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
# User must use this move for 2 more rounds. No battlers can sleep. (Uproar)
# NOTE: Bulbapedia claims that an uproar will wake up Pokémon even if they have
#       Soundproof, and will not allow Pokémon to fall asleep even if they have
#       Soundproof. I think this is an oversight, so I've let Soundproof Pokémon
#       be unaffected by Uproar waking/non-sleeping effects.
#===============================================================================
class Battle::Move::MultiTurnAttackPreventSleeping < Battle::Move
  def pbEffectGeneral(user)
    return if user.effects[PBEffects::Uproar] > 0
    user.effects[PBEffects::Uproar] = 3
    user.currentMove = @id
    @battle.pbDisplay(_INTL("{1} caused an uproar!", user.pbThis))
    @battle.pbPriority(true).each do |b|
      next if b.fainted? || b.status != :SLEEP
      next if b.hasActiveAbility?(:SOUNDPROOF)
      b.pbCureStatus
    end
  end
end

#===============================================================================
# User must use this move for 1 or 2 more rounds. At end, user becomes confused.
# (Outrage, Petal Dange, Thrash)
#===============================================================================
class Battle::Move::MultiTurnAttackConfuseUserAtEnd < Battle::Move
  def pbEffectAfterAllHits(user, target)
    if !target.damageState.unaffected && user.effects[PBEffects::Outrage] == 0
      user.effects[PBEffects::Outrage] = 2 + @battle.pbRandom(2)
      user.currentMove = @id
    end
    if user.effects[PBEffects::Outrage] > 0
      user.effects[PBEffects::Outrage] -= 1
      if user.effects[PBEffects::Outrage] == 0 && user.pbCanConfuseSelf?(false)
        user.pbConfuse(_INTL("{1} became confused due to fatigue!", user.pbThis))
      end
    end
  end
end

#===============================================================================
# User must use this move for 4 more rounds. Power doubles each round.
# Power is also doubled if user has curled up. (Ice Ball, Rollout)
#===============================================================================
class Battle::Move::MultiTurnAttackPowersUpEachTurn < Battle::Move
  def pbNumHits(user, targets); return 1; end

  def pbBaseDamage(baseDmg, user, target)
    shift = (5 - user.effects[PBEffects::Rollout])   # 0-4, where 0 is most powerful
    shift = 0 if user.effects[PBEffects::Rollout] == 0   # For first turn
    shift += 1 if user.effects[PBEffects::DefenseCurl]
    baseDmg *= 2**shift
    return baseDmg
  end

  def pbEffectAfterAllHits(user, target)
    if !target.damageState.unaffected && user.effects[PBEffects::Rollout] == 0
      user.effects[PBEffects::Rollout] = 5
      user.currentMove = @id
    end
    user.effects[PBEffects::Rollout] -= 1 if user.effects[PBEffects::Rollout] > 0
  end
end

#===============================================================================
# User bides its time this round and next round. The round after, deals 2x the
# total direct damage it took while biding to the last battler that damaged it.
# (Bide)
#===============================================================================
class Battle::Move::MultiTurnAttackBideThenReturnDoubleDamage < Battle::Move::FixedDamageMove
  def pbAddTarget(targets, user)
    return if user.effects[PBEffects::Bide] != 1   # Not the attack turn
    idxTarget = user.effects[PBEffects::BideTarget]
    t = (idxTarget >= 0) ? @battle.battlers[idxTarget] : nil
    if !user.pbAddTarget(targets, user, t, self, false)
      user.pbAddTargetRandomFoe(targets, user, self, false)
    end
  end

  def pbMoveFailed?(user, targets)
    return false if user.effects[PBEffects::Bide] != 1   # Not the attack turn
    if user.effects[PBEffects::BideDamage] == 0
      @battle.pbDisplay(_INTL("But it failed!"))
      user.effects[PBEffects::Bide] = 0   # No need to reset other Bide variables
      return true
    end
    if targets.length == 0
      @battle.pbDisplay(_INTL("But there was no target..."))
      user.effects[PBEffects::Bide] = 0   # No need to reset other Bide variables
      return true
    end
    return false
  end

  def pbOnStartUse(user, targets)
    @damagingTurn = (user.effects[PBEffects::Bide] == 1)   # If attack turn
  end

  def pbDisplayUseMessage(user)
    if @damagingTurn   # Attack turn
      @battle.pbDisplayBrief(_INTL("{1} unleashed energy!", user.pbThis))
    elsif user.effects[PBEffects::Bide] > 1   # Charging turns
      @battle.pbDisplayBrief(_INTL("{1} is storing energy!", user.pbThis))
    else
      super   # Start using Bide
    end
  end

  # Stops damage being dealt in the charging turns.
  def pbDamagingMove?
    return false if !@damagingTurn
    return super
  end

  def pbFixedDamage(user, target)
    return user.effects[PBEffects::BideDamage] * 2
  end

  def pbEffectGeneral(user)
    if user.effects[PBEffects::Bide] == 0   # Starting using Bide
      user.effects[PBEffects::Bide]       = 3
      user.effects[PBEffects::BideDamage] = 0
      user.effects[PBEffects::BideTarget] = -1
      user.currentMove = @id
    end
    user.effects[PBEffects::Bide] -= 1
  end

  def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    hitNum = 1 if !@damagingTurn   # Charging anim
    super
  end
end
