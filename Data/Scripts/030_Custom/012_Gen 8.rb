#===============================================================================
# Hunger Switch
#===============================================================================
BattleHandlers::AbilityChangeOnBattlerFainting.add(:POWEROFALCHEMY,
  proc { |ability,battler,fainted,battle|
    next if battler.opposes?(fainted)
    abilityBlacklist = [
       # Replaces self with another ability
       :POWEROFALCHEMY,
       :RECEIVER,
       :TRACE,
       # Form-changing abilities
       :BATTLEBOND,
       :DISGUISE,
       :FLOWERGIFT,
       :FORECAST,
       :MULTITYPE,
       :POWERCONSTRUCT,
       :SCHOOLING,
       :SHIELDSDOWN,
       :STANCECHANGE,
       :ZENMODE,
	   :HUNGERSWITCH,
       # Appearance-changing abilities
       :ILLUSION,
       :IMPOSTER,
       # Abilities intended to be inherent properties of a certain species
       :COMATOSE,
       :RKSSYSTEM,
       # Abilities that would be overpowered if allowed to be transferred
       :WONDERGUARD
    ]
    failed = false
    abilityBlacklist.each do |abil|
      next if !isConst?(fainted.ability,PBAbilities,abil)
      failed = true
      break
    end
    next if failed
    battle.pbShowAbilitySplash(battler,true)
    battler.ability = fainted.ability
    battle.pbReplaceAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1}'s {2} was taken over!",fainted.pbThis,fainted.abilityName))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityChangeOnBattlerFainting.copy(:POWEROFALCHEMY,:RECEIVER)
