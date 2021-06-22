BattleHandlers::AbilityOnSwitchIn.add(:INTREPIDSWORD,
  proc { |ability, battler, battle|
    battler.pbRaiseStatStageByAbility(:ATTACK, 1, battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DAUNTLESSSHIELD,
  proc { |ability, battler, battle|
    battler.pbRaiseStatStageByAbility(:ATTACK, 1, battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:CURIOUSMEDICINE,
  proc { |ability, battler, battle|
    has_effect = false
    battler.eachAlly do |b|
      next if !b.hasAlteredStatStages?
      has_effect = true
      break
    end
    next if !has_effect
    battle.pbShowAbilitySplash(battler)
    battler.eachAlly do |b|
      next if !b.hasAlteredStatStages?
      b.pbResetStatStages
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s stat changes were removed!", b.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s stat changes were removed by {2}'s {3}!",
           b.pbThis, battler.pbThis(true), battler.abilityName))
      end
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:SCREENCLEANER,
  proc { |ability, battler, battle|
    next if target.pbOwnSide.effects[PBEffects::AuroraVeil] == 0 &&
            target.pbOwnSide.effects[PBEffects::LightScreen] == 0 &&
            target.pbOwnSide.effects[PBEffects::Reflect] == 0 &&
            target.pbOpposingSide.effects[PBEffects::AuroraVeil] == 0 &&
            target.pbOpposingSide.effects[PBEffects::LightScreen] == 0 &&
            target.pbOpposingSide.effects[PBEffects::Reflect] == 0
    battle.pbShowAbilitySplash(battler)
    if battler.pbOpposingSide.effects[PBEffects::AuroraVeil] > 0
      battler.pbOpposingSide.effects[PBEffects::AuroraVeil] = 0
      battle.pbDisplay(_INTL("{1}'s Aurora Veil wore off!", battler.pbOpposingTeam))
    end
    if battler.pbOpposingSide.effects[PBEffects::LightScreen] > 0
      battler.pbOpposingSide.effects[PBEffects::LightScreen] = 0
      battle.pbDisplay(_INTL("{1}'s Light Screen wore off!", battler.pbOpposingTeam))
    end
    if battler.pbOpposingSide.effects[PBEffects::Reflect] > 0
      battler.pbOpposingSide.effects[PBEffects::Reflect] = 0
      battle.pbDisplay(_INTL("{1}'s Reflect wore off!", battler.pbOpposingTeam))
    end
    if battler.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
      battler.pbOwnSide.effects[PBEffects::AuroraVeil] = 0
      battle.pbDisplay(_INTL("{1}'s Aurora Veil wore off!", battler.pbTeam))
    end
    if battler.pbOwnSide.effects[PBEffects::LightScreen] > 0
      battler.pbOwnSide.effects[PBEffects::LightScreen] = 0
      battle.pbDisplay(_INTL("{1}'s Light Screen wore off!", battler.pbTeam))
    end
    if battler.pbOwnSide.effects[PBEffects::Reflect] > 0
      battler.pbOwnSide.effects[PBEffects::Reflect] = 0
      battle.pbDisplay(_INTL("{1}'s Reflect wore off!", battler.pbTeam))
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:SANDSPIT,
  proc { |ability, user, target, move, battle|
    pbBattleWeatherAbility(:Sandstorm, battler, battle)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:COTTONDOWN,
  proc { |ability, user, target, move, battle|
    has_effect = false
    battle.eachBattler do |b|
      next if !b.pbCanLowerStatStage?(:DEFENSE, target)
      has_effect = true
      break
    end
    next if !has_effect
    battle.pbShowAbilitySplash(battler)
    battle.eachBattler do |b|
      b.pbLowerStatStageByAbility(:SPEED, 1, target, false)
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:PERISHBODY,
  proc { |ability, user, target, move, battle|
    next if !move.pbContactMove?(user)
    next if user.fainted?
    next if user.effects[PBEffects::PerishSong] > 0 || target.effects[PBEffects::PerishSong] > 0
    battle.pbShowAbilitySplash(target)
    if user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      user.effects[PBEffects::PerishSong] = 4
      user.effects[PBEffects::PerishSongUser] = target.index
      target.effects[PBEffects::PerishSong] = 4
      target.effects[PBEffects::PerishSongUser] = target.index
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("Both Pokémon will faint in three turns!"))
      else
        battle.pbDisplay(_INTL("Both Pokémon will faint in three turns because of {1}'s {2}!",
           target.pbThis(true), target.abilityName))
      end
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:WANDERINGSPIRIT,
  proc { |ability, user, target, move, battle|
    next if !move.pbContactMove?(user)
    next if user.ungainableAbility? || [:RECEIVER, :WONDERGUARD].include?(user.ability_id)
    oldUserAbil   = nil
    oldTargetAbil = nil
    battle.pbShowAbilitySplash(target) if user.opposes?(target)
    if user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      battle.pbShowAbilitySplash(user, true, false) if user.opposes?(target)
      oldUserAbil   = user.ability
      oldTargetAbil = target.ability
      user.ability   = oldTargetAbil
      target.ability = oldUserAbil
      if user.opposes?(target)
        battle.pbReplaceAbilitySplash(user)
        battle.pbReplaceAbilitySplash(target)
      end
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} swapped Abilities with {2}!", target.pbThis, user.pbThis(true)))
      else
        battle.pbDisplay(_INTL("{1} swapped its {2} Ability with {3}'s {4} Ability!",
           target.pbThis, user.abilityName, user.pbThis(true), target.abilityName))
      end
      if user.opposes?(target)
        battle.pbHideAbilitySplash(user)
        battle.pbHideAbilitySplash(target)
      end
    end
    battle.pbHideAbilitySplash(target) if user.opposes?(target)
    user.pbOnAbilityChanged(oldUserAbil) if oldUserAbil != nil
    target.pbOnAbilityChanged(oldTargetAbil) if oldTargetAbil != nil
    target.pbEffectsOnSwitchIn
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:CHILLINGNEIGH,
  proc { |ability, user, targets, move, battle|
    next if battle.pbAllFainted?(user.idxOpposingSide)
    numFainted = 0
    targets.each { |b| numFainted += 1 if b.damageState.fainted }
    next if numFainted == 0 || !user.pbCanRaiseStatStage?(:ATTACK, user)
    user.pbRaiseStatStageByAbility(:ATTACK, 1, user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:GRIMNEIGH,
  proc { |ability, user, targets, move, battle|
    next if battle.pbAllFainted?(user.idxOpposingSide)
    numFainted = 0
    targets.each { |b| numFainted += 1 if b.damageState.fainted }
    next if numFainted == 0 || !user.pbCanRaiseStatStage?(:SPECIAL_ATTACK, user)
    user.pbRaiseStatStageByAbility(:SPECIAL_ATTACK, 1, user)
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TRANSISTOR ,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:attack_multiplier] *= 1.5 if type == :ELECTRIC
  }
)

BattleHandlers::DamageCalcUserAbility.add(:DRAGONSMAW ,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:attack_multiplier] *= 1.5 if type == :DRAGON
  }
)

BattleHandlers::DamageCalcUserAbility.add(:PUNKROCK ,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:attack_multiplier] *= 1.3 if move.soundMove?
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:PUNKROCK,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:final_damage_multiplier] /= 2 if move.soundMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:STEELYSPIRIT ,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:final_damage_multiplier] *= 1.5 if type == :STEEL
  }
)

BattleHandlers::DamageCalcUserAllyAbility.add(:STEELYSPIRIT,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:final_damage_multiplier] *= 1.5 if type == :STEEL
  }
)

BattleHandlers::DamageCalcUserAllyAbility.add(:POWERSPOT,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:final_damage_multiplier] *= 1.3
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:ICESCALES,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:final_damage_multiplier] /= 2 if move.specialMove?
  }
)

BattleHandlers::StatusImmunityAbility.copy(:IMMUNITY, :PASTELVEIL)

BattleHandlers::StatusImmunityAbility.add(:PASTELVEIL,
  proc { |ability, battler, status|
    next true if status == :POISON
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:PASTELVEIL,
  proc { |ability, battler, battle|
    has_effect = false
    battler.eachAlly do |b|
      next if b.status != :POISON
      has_effect = true
      break
    end
    next if !has_effect
    battle.pbShowAbilitySplash(battler)
    battler.eachAlly do |b|
      next if b.status != :POISON
      b.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s {2} cured {3}'s poisoning!",
           battler.pbThis, battler.abilityName, b.pbThis(true)))
      end
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::PriorityBracketChangeAbility.add(:QUICKDRAW,
  proc { |ability, battler, subPri, battle|
    next 1 if subPri == 0 && battle.pbRandom(100) < 30
  }
)

BattleHandlers::PriorityBracketUseAbility.add(:QUICKDRAW,
  proc { |ability, battler, battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} made {2} move faster!", battler.abilityName, battler.pbThis(true)))
    battle.pbHideAbilitySplash(battler)
  }
)

=begin

#===============================================================================

Hunger Switch
At the end of each round, switches the bearer's form (if it is Morpeko).

Ball Fetch
At the end of a round in which a thrown Poké Ball fails to catch a Pokémon,
bearer picks up that Poké Ball. Applies only to the first thrown Poké Ball, and
only triggers once.

Steam Engine
When bearer is hit by a Fire- or Water-type move, bearer gets +6 Speed (after
the effect of that move is applied). Outside of battle, makes eggs hatch twice
as fast (doesn't stack with other such abilities).

Ice Face
When bearer is hit by a physical move while in its initial form, it takes no
damage and its form changes. At he end of a round in which hail weather started,
the bearer regains its initial form.

As One (Chilling)
Combination of Unnerve and Chilling Neigh. Message upon entering battle says it
has two abilities; other triggers use the name of the appropriate ability rather
than "As One".

As One (Grim)
Combination of Unnerve and Grim Neigh. Message upon entering battle says it has
two abilities; other triggers use the name of the appropriate ability rather
than "As One".

Gorilla Tactics
Boosts bearer's Attack by 50%, but restricts bearer to one move (cf. Choice
Band). Power boost stacks with Choice Band.

Unseen Fist
The bearer's moves will do damage with contact moves even if the target is
protected from it. (Does this mean it just bypasses the protection?)

Mirror Armor
If a move/ability tries to lower the bearer's stat(s), the effect is reflected
back at the causer.

Ripen
Doubles the effects of the bearer's held berries.

Neutralizing Gas
Suppresses all other abilities. Once this ability stops applying, triggers all
abilities that activate when gained (if this happens because bearer switches
out, abilities trigger before the replacement switches in).

Propellor Tail, Stalwart
Bearer's moves cannot be redirected.

Mimicry
The bearer's type changes depending on the terrain. Triggers upon entering
battle and when terrain changes (and not when bearer's type is changed, e.g.
with Soak).

Gulp Missile
After using Surf/Dive, changes the bearer's form depending on its HP. If hit by
an attack while in one of these forms, damages the attacker and causes an effect
depending on the form.

=end
