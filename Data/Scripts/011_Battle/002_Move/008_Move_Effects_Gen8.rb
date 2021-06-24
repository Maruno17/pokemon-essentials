=begin
Dynamax Cannon - 000
Behemoth Blade - 000
Behemoth Bash - 000
Branch Poke - 000
Overdrive - 000
Glacial Lance - 000
Astral Barrage - 000
Pyro Ball - 00A
Scorching Sands - 00A
Freezing Glare - 00C
Fiery Wrath - 00F
Strange Steam - 013
Breaking Swipe - 042
Thunderous Kick - 043
Drum Beating - 044
Skitter Smack - 045
Spirit Break - 045
Apple Acid - 046
Dragon Energy - 08B
Wicked Blow - 0A0
False Surrender - 0A5
Dual Wingbeat - 0BD
Triple Axel - 0BF
Meteor Assault - 0C2
Eternabeam - 0C2
Snap Trap - 0CF
Thunder Cage - 0CF
Flip Turn - 0EE
=end

#===============================================================================
# Poisons the target. This move becomes physical or special, whichever will deal
# more damage (only considers stats, stat stages and Wonder Room). Makes contact
# if it is a physical move. Has a different animation depending on the move's
# category. (Shell Side Arm)
#===============================================================================
class PokeBattle_Move_176 < PokeBattle_PoisonMove
  def initialize(battle, move)
    super
    @calcCategory = 1
  end

  def physicalMove?(thisType = nil); return (@calcCategory == 0); end
  def specialMove?(thisType = nil);  return (@calcCategory == 1); end
  def contactMove?;                  return physicalMove?;        end

  def pbOnStartUse(user, targets)
    target = targets[0]
    stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
    stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
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
# Burns the target if any of its stats were increased this round.
# (Burning Jealousy)
#===============================================================================
class PokeBattle_Move_177 < PokeBattle_UnimplementedMove
end

#===============================================================================
# Increases the user's Speed by 1 stage. This move's type depends on the user's
# form (Electric if Full Belly, Dark if Hangry). Fails if the user is not
# Morpeko (works if transformed into Morpeko). (Aura Wheel)
#===============================================================================
class PokeBattle_Move_178 < PokeBattle_Move_01F
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
# Increases the user's Attack, Defense, Speed, Special Attack and Special
# Defense by 1 stage each. The user cannot switch out or flee. Fails if the user
# is already affected by the second effect of this move, but can be used if the
# user is prevented from switching out or fleeing by another effect (in which
# case, the second effect of this move is not applied to the user). The user may
# still switch out if holding Shed Shell or Eject Button, or if affected by a
# Red Card. (No Retreat)
#===============================================================================
class PokeBattle_Move_179 < PokeBattle_Move_02D
  def pbMoveFailed?(user, targets)
    if user.effects[PBEffects::NoRetreat]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return super
  end

  def pbEffectGeneral(user)
    super
    if battler.effects[PBEffects::Trapping] == 0 &&
       battler.effects[PBEffects::MeanLook] < 0 &&
       !battler.effects[PBEffects::Ingrain] &&
       @field.effects[PBEffects::FairyLock] == 0
      user.effects[PBEffects::NoRetreat] = true
      @battle.pbDisplay(_INTL("{1} can no longer escape because it used {2}!", user.pbThis, @name))
    end
  end
end

#===============================================================================
# Increases the user's Attack, Defense, Special Attack, Special Defense and
# Speed by 1 stage each, and reduces the user's HP by a third of its total HP.
# Fails if it can't do either effect. (Clangorous Soul)
#===============================================================================
class PokeBattle_Move_17A < PokeBattle_MultiStatUpMove
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
# Raises the Attack and Defense of all user's allies by 1 stage each. Bypasses
# protections, including Crafty Shield. Fails if there is no ally. (Coaching)
#===============================================================================
class PokeBattle_Move_17B < PokeBattle_UnimplementedMove
  # TODO: Needs a new targeting option. Otherwise, see Magnetic Flux.
end

#===============================================================================
# Increases the target's Attack and Special Attack by 2 stages each. (Decorate)
#===============================================================================
class PokeBattle_Move_17C < PokeBattle_Move
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
# Decreases the target's Defense by 1 stage. Power is doubled if Gravity is in
# effect. (Grav Apple)
#===============================================================================
class PokeBattle_Move_17D < PokeBattle_Move_043
  def pbBaseDamage(baseDmg, user, target)
    baseDmg *= 2 if @battle.field.effects[PBEffects::Gravity] > 0
    return baseDmg
  end
end

#===============================================================================
# Decreases the target's Speed by 1 stage. Doubles the effectiveness of damaging
# Fire moves used against the target (this effect does not stack). Fails if
# neither of these effects can be applied. (Tar Shot)
#===============================================================================
class PokeBattle_Move_17E < PokeBattle_Move_044
  def pbFailsAgainstTarget?(user, target)
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
# The target's types become Psychic. Fails if the target has the ability
# Multitype/RKS System or has a substitute. (Magic Powder)
#===============================================================================
class PokeBattle_Move_17F < PokeBattle_Move
  def pbFailsAgainstTarget?(user, target)
    if !target.canChangeType? || !GameData::Type.exists?(:PSYCHIC) ||
       !target.pbHasOtherType?(:PSYCHIC) || !target.affectedByPowder?
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    target.pbChangeTypes(:PSYCHIC)
    typeName = GameData::Type.get(:PSYCHIC).name
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!", target.pbThis, typeName))
  end
end

#===============================================================================
# Power is doubled if Electric Terrain applies. (Rising Voltage)
#===============================================================================
class PokeBattle_Move_180 < PokeBattle_Move
  def pbBaseDamage(baseDmg, user, target)
    baseDmg *= 2 if @battle.field.terrain == :Electric
    return baseDmg
  end
end

#===============================================================================
# If Psychic Terrain applies and the user is grounded, power is multiplied by
# 1.5 (in addition to Psychic Terrain's multiplier) and it targets all opposing
# Pokémon. (Expanding Force)
#===============================================================================
class PokeBattle_Move_181 < PokeBattle_Move
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
# Power is doubled if a terrain applies and user is grounded; also, this move's
# type and animation depends on the terrain. (Terrain Pulse)
#===============================================================================
class PokeBattle_Move_182 < PokeBattle_Move
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
# Power is doubled if the user moves before the target, or if the target
# switched in this round. (Bolt Beak, Fishious Rend)
#===============================================================================
class PokeBattle_Move_183 < PokeBattle_Move
  def pbBaseDamage(baseDmg, user, target)
    if @battle.choices[target.index][0] == :None ||   # Switched in
      ([:UseMove, :Shift].include?(@battle.choices[target.index][0]) && !target.movedThisRound?)
      baseDmg *= 2
    end
    return baseDmg
  end
end

#===============================================================================
# Power is doubled if any of the user's stats were lowered this round. (Lash Out)
#===============================================================================
class PokeBattle_Move_184 < PokeBattle_UnimplementedMove
end

#===============================================================================
# If Grassy Terrain applies, priority is increased by 1. (Grassy Glide)
#===============================================================================
class PokeBattle_Move_185 < PokeBattle_Move
  def priority
    ret = super
    ret += 1 if @battle.field.terrain == :Electric
    return ret
  end
end

#===============================================================================
# For the rest of this round, the user avoids all damaging moves that would hit
# it. If a move that makes contact is stopped by this effect, decreases the
# Defense of the Pokémon using that move by 2 stages. Contributes to Protect's
# counter. (Obstruct)
#===============================================================================
class PokeBattle_Move_186 < PokeBattle_ProtectMove
  def initialize(battle,move)
    super
    @effect = PBEffects::Obstruct
  end
end

#===============================================================================
# Unaffected by moves and abilities that would redirect this move. (Snipe Shot)
#===============================================================================
class PokeBattle_Move_187 < PokeBattle_Move
  def cannotRedirect?; return true; end
end

#===============================================================================
# Hits 2 times in a row. The second hit targets the original target's ally if it
# had one (that can be targeted), or the original target if not. If the original
# target cannot be targeted, both hits target its ally. In a triple battle, the
# second hit will (try to) target one adjacent ally (how does it decide which
# one?).
#
# A Pokémon cannot be targeted if:
# * It is the user.
# * It would be immune due to its type or ability.
# * It is protected by a protection move (which ones?).
# * It is semi-invulnerable, or the move fails an accuracy check against it.
# * An ally is the centre of attention (e.g. because of Follow Me).
#
# All Pokémon hit by this move will apply their Pressure ability to it.
# (Dragon Darts)
#===============================================================================
class PokeBattle_Move_188 < PokeBattle_UnimplementedMove
end

#===============================================================================
# Hits 3 times in a row. If each hit could be a critical hit, it will definitely
# be a critical hit. (Surging Strikes)
#===============================================================================
class PokeBattle_Move_189 < PokeBattle_Move
  def multiHitMove?;                   return true; end
  def pbNumHits(user, targets);        return 3;    end
  def pbCritialOverride(user, target); return 1;    end
end

#===============================================================================
# Hits 2-5 times in a row. If the move does not fail, increases the user's Speed
# by 1 stage and decreases the user's Defense by 1 stage. (Scale Shot)
#===============================================================================
class PokeBattle_Move_18A < PokeBattle_Move
  def multiHitMove?; return true; end

  def pbNumHits(user, targets)
    hitChances = [
      2, 2, 2, 2, 2, 2, 2,
      3, 3, 3, 3, 3, 3, 3,
      4, 4, 4,
      5, 5, 5]
    r = @battle.pbRandom(hitChances.length)
    r = hitChances.length - 1 if user.hasActiveAbility?(:SKILLLINK)
    return hitChances[r]
  end

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
# Two-turn attack. On the first turn, increases the user's Special Attack by 1
# stage. On the second turn, does damage. (Meteor Beam)
#===============================================================================
class PokeBattle_Move_18B < PokeBattle_TwoTurnMove
  def pbChargingTurnMessage(user, targets)
    @battle.pbDisplay(_INTL("{1} is overflowing with space power!", user.pbThis))
  end

  def pbChargingTurnEffect(user, target)
    if user.pbCanRaiseStatStage?(:SPECIAL_ATTACK, user, self)
      user.pbRaiseStatStage(:SPECIAL_ATTACK, 1, user)
    end
  end
end

#===============================================================================
# The user and its allies gain 25% of their total HP. (Life Dew)
#===============================================================================
class PokeBattle_Move_18C < PokeBattle_Move
  def healingMove?; return true; end

  def pbMoveFailed?(user, targets)
    failed = true
    @battle.eachSameSideBattler(user) do |b|
      next if !b.canHeal?
      failed = false
      break
    end
    if failed
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user, target)
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
class PokeBattle_Move_18D < PokeBattle_Move
  def healingMove?; return true; end

  def pbMoveFailed?(user, targets)
    failed = true
    @battle.eachSameSideBattler(user) do |b|
      next if b.status == :NONE && !b.canHeal?
      failed = false
      break
    end
    if failed
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user, target)
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
# User faints. If Misty Terrain applies, base power is multiplied by 1.5.
# (Misty Explosion)
#===============================================================================
class PokeBattle_Move_18E < PokeBattle_Move_0E0
  def pbBaseDamage(baseDmg, user, target)
    baseDmg = baseDmg * 3 / 2 if @battle.field.terrain == :Misty
    return baseDmg
  end
end

#===============================================================================
# The target can no longer switch out or flee, while the user remains in battle.
# At the end of each round, the target's Defense and Special Defense are lowered
# by 1 stage each. (Octolock)
# TODO: Can the user lock multiple other Pokémon at once?
#===============================================================================
class PokeBattle_Move_18F < PokeBattle_Move
  def pbFailsAgainstTarget?(user, target)
    return false if damagingMove?
    if target.effects[PBEffects::Octolock] >= 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    if Settings::MORE_TYPE_EFFECTS && target.pbHasType?(:GHOST)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
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
class PokeBattle_Move_190 < PokeBattle_UnimplementedMove
end

#===============================================================================
# The user consumes its held berry and gains its effect. Also, increases the
# user's Defense by 2 stages. The berry can be consumed even if Unnerve/Magic
# Room apply. Fails if the user is not holding a berry. This move cannot be
# chosen to be used if the user is not holding a berry. (Stuff Cheeks)
#===============================================================================
class PokeBattle_Move_191 < PokeBattle_UnimplementedMove
end

#===============================================================================
# All Pokémon (except semi-invulnerable ones) consume their held berries and
# gain their effects. Berries can be consumed even if Unnerve/Magic Room apply.
# Fails if no Pokémon have a held berry. If this move would trigger an ability
# that negates the move, e.g. Lightning Rod, the bearer of that ability will
# have their ability triggered regardless of whether they are holding a berry,
# and they will not consume their berry (how does this interact with the move
# failing?). (Teatime)
#===============================================================================
class PokeBattle_Move_192 < PokeBattle_UnimplementedMove
end

#===============================================================================
# Negates the effect and usability of the target's held item for the rest of the
# battle (even if it is switched out). Fails if the target doesn't have a held
# item, the item is unlosable, the target has Sticky Hold, or the target is
# behind a substitute. (Corrosive Gas)
#===============================================================================
class PokeBattle_Move_193 < PokeBattle_UnimplementedMove
end

#===============================================================================
# The user takes recoil damage equal to 1/2 of its total HP (rounded up, min. 1
# damage). (Steel Beam)
#===============================================================================
class PokeBattle_Move_194 < PokeBattle_RecoilMove
  def pbRecoilDamage(user, target)
    return (user.totalhp / 2.0).ceil
  end
end

#===============================================================================
# Decreases the PP of the last attack used by the target by 3 (or as much as
# possible). (Eerie Spell)
#===============================================================================
class PokeBattle_Move_195 < PokeBattle_Move
  def pbFailsAgainstTarget?(user, target)
    last_move = target.pbGetMoveWithID(target.lastRegularMoveUsed)
    if !last_move || last_move.pp == 0 || last_move.total_pp <= 0
      @battle.pbDisplay(_INTL("But it failed!"))
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
# Fails if the target is not holding an item, or if the target is affected by
# Magic Room/Klutz. (Poltergeist)
#===============================================================================
class PokeBattle_Move_196 < PokeBattle_Move
  def pbFailsAgainstTarget?(user, target)
    if !target.item || !target.itemActive?
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    @battle.pbDisplay(_INTL("{1} is about to be attacked by its {2}!", target.pbThis, target.itemName))
    return false
  end
end

#===============================================================================
# The user's Defense (and its Defense stat stages) are used instead of the
# user's Attack (and Attack stat stages) to calculate damage. All other effects
# are applied normally, applying the user's Attack modifiers and not the user's
# Defence modifiers. (Body Press)
#===============================================================================
class PokeBattle_Move_197 < PokeBattle_Move
  def pbGetAttackStats(user, target)
    return user.defense, user.stages[:DEFENSE] + 6
  end
end

#===============================================================================
# All effects that apply to one side of the field are swapped to the opposite
# side. (Court Change)
#===============================================================================
class PokeBattle_Move_198 < PokeBattle_Move
  def initialize(battle, move)
    super
    @number_effects = [
      PBEffects::AuroraVeil,
      PBEffects::LightScreen,
      PBEffects::Mist,
      PBEffects::Rainbow,
      PBEffects::Reflect,
      PBEffects::Safeguard,
      PBEffects::SeaOfFire,
      PBEffects::Spikes,
      PBEffects::Swamp,
      PBEffects::Tailwind,
      PBEffects::ToxicSpikes
    ]
    @boolean_effects = [
      PBEffects::StealthRock,
      PBEffects::StickyWeb
    ]
  end

  def pbMoveFailed?(user, targets)
    has_effect = false
    for side in 0...2
      effects = @battle.sides[side].effects
      @number_effects.each do |e|
        next if effects[e] == 0
        has_effect = true
        break
      end
      break if has_effect
      @boolean_effects.each do |e|
        next if !effects[e]
        has_effect = true
        break
      end
      break if has_effect
    end
    if !has_effect
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    side0 = @battle.sides[0]
    side1 = @battle.sides[1]
    @number_effects.each do |e|
      side0.effects[e], side1.effects[e] = side1.effects[e], side0.effects[e]
    end
    @boolean_effects.each do |e|
      side0.effects[e], side1.effects[e] = side1.effects[e], side0.effects[e]
    end
    @battle.pbDisplay(_INTL("{1} swapped the battle effects affecting each side of the field!", user.pbThis))
  end
end

#===============================================================================
# Removes the current terrain. Fails if there is no terrain in effect.
# (Steel Roller)
#===============================================================================
class PokeBattle_Move_199 < PokeBattle_Move
  def pbMoveFailed?(user, targets)
    if @battle.field.terrain == :None
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
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
