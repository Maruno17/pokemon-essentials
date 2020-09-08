#===============================================================================
# SpeedCalcAbility handlers
#===============================================================================

BattleHandlers::SpeedCalcAbility.add(:CHLOROPHYLL,
  proc { |ability,battler,mult|
    w = battler.battle.pbWeather
    next mult*2 if w==PBWeather::Sun || w==PBWeather::HarshSun
  }
)

BattleHandlers::SpeedCalcAbility.add(:QUICKFEET,
  proc { |ability,battler,mult|
    next (mult*1.5).round if battler.pbHasAnyStatus?
  }
)

BattleHandlers::SpeedCalcAbility.add(:SANDRUSH,
  proc { |ability,battler,mult|
    w = battler.battle.pbWeather
    next mult*2 if w==PBWeather::Sandstorm
  }
)

BattleHandlers::SpeedCalcAbility.add(:SLOWSTART,
  proc { |ability,battler,mult|
    next mult/2 if battler.turnCount<=5
  }
)

BattleHandlers::SpeedCalcAbility.add(:SLUSHRUSH,
  proc { |ability,battler,mult|
    w = battler.battle.pbWeather
    next mult*2 if w==PBWeather::Hail
  }
)

BattleHandlers::SpeedCalcAbility.add(:SURGESURFER,
  proc { |ability,battler,mult|
    next mult*2 if battler.battle.field.terrain==PBBattleTerrains::Electric
  }
)

BattleHandlers::SpeedCalcAbility.add(:SWIFTSWIM,
  proc { |ability,battler,mult|
    w = battler.battle.pbWeather
    next mult*2 if w==PBWeather::Rain || w==PBWeather::HeavyRain
  }
)

BattleHandlers::SpeedCalcAbility.add(:UNBURDEN,
  proc { |ability,battler,mult|
    next mult*2 if battler.effects[PBEffects::Unburden] && battler.item==0
  }
)

#===============================================================================
# WeightCalcAbility handlers
#===============================================================================

BattleHandlers::WeightCalcAbility.add(:HEAVYMETAL,
  proc { |ability,battler,w|
    next w*2
  }
)

BattleHandlers::WeightCalcAbility.add(:LIGHTMETAL,
  proc { |ability,battler,w|
    next [w/2,1].max
  }
)

#===============================================================================
# AbilityOnHPDroppedBelowHalf handlers
#===============================================================================

BattleHandlers::AbilityOnHPDroppedBelowHalf.add(:EMERGENCYEXIT,
  proc { |ability,battler,battle|
    next false if battler.effects[PBEffects::SkyDrop]>=0 || battler.inTwoTurnAttack?("0CE")   # Sky Drop
    # In wild battles
    if battle.wildBattle?
      next false if battler.opposes? && battle.pbSideBattlerCount(battler.index)>1
      next false if !battle.pbCanRun?(battler.index)
      battle.pbShowAbilitySplash(battler,true)
      battle.pbHideAbilitySplash(battler)
      battle.pbDisplay(_INTL("{1} fled from battle!",battler.pbThis)) { pbSEPlay("Battle flee") }
      battle.decision = 3   # Escaped
      next true
    end
    # In trainer battles
    next false if battle.pbAllFainted?(battler.idxOpposingSide)
    next false if !battle.pbCanSwitch?(battler.index)   # Battler can't switch out
    next false if !battle.pbCanChooseNonActive?(battler.index)   # No Pokémon can switch in
    battle.pbShowAbilitySplash(battler,true)
    battle.pbHideAbilitySplash(battler)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s {2} activated!",battler.pbThis,battler.abilityName))
    end
    battle.pbDisplay(_INTL("{1} went back to {2}!",
       battler.pbThis,battle.pbGetOwnerName(battler.index)))
    if battle.endOfRound   # Just switch out
      battle.scene.pbRecall(battler.index) if !battler.fainted?
      battler.pbAbilitiesOnSwitchOut   # Inc. primordial weather check
      next true
    end
    newPkmn = battle.pbGetReplacementPokemonIndex(battler.index)   # Owner chooses
    next false if newPkmn<0   # Shouldn't ever do this
    battle.pbRecallAndReplace(battler.index,newPkmn)
    battle.pbClearChoice(battler.index)   # Replacement Pokémon does nothing this round
    next true
  }
)

BattleHandlers::AbilityOnHPDroppedBelowHalf.copy(:EMERGENCYEXIT,:WIMPOUT)

#===============================================================================
# StatusCheckAbilityNonIgnorable handlers
#===============================================================================

BattleHandlers::StatusCheckAbilityNonIgnorable.add(:COMATOSE,
  proc { |ability,battler,status|
    next false if !battler.isSpecies?(:KOMALA)
    next true if status.nil? || status==PBStatuses::SLEEP
  }
)

#===============================================================================
# StatusImmunityAbility handlers
#===============================================================================

BattleHandlers::StatusImmunityAbility.add(:FLOWERVEIL,
  proc { |ability,battler,status|
    next true if battler.pbHasType?(:GRASS)
  }
)

BattleHandlers::StatusImmunityAbility.add(:IMMUNITY,
  proc { |ability,battler,status|
    next true if status==PBStatuses::POISON
  }
)

BattleHandlers::StatusImmunityAbility.copy(:IMMUNITY,:PASTELVEIL)

BattleHandlers::StatusImmunityAbility.add(:INSOMNIA,
  proc { |ability,battler,status|
    next true if status==PBStatuses::SLEEP
  }
)

BattleHandlers::StatusImmunityAbility.copy(:INSOMNIA,:SWEETVEIL,:VITALSPIRIT)

BattleHandlers::StatusImmunityAbility.add(:LEAFGUARD,
  proc { |ability,battler,status|
    w = battler.battle.pbWeather
    next true if w==PBWeather::Sun || w==PBWeather::HarshSun
  }
)

BattleHandlers::StatusImmunityAbility.add(:LIMBER,
  proc { |ability,battler,status|
    next true if status==PBStatuses::PARALYSIS
  }
)

BattleHandlers::StatusImmunityAbility.add(:MAGMAARMOR,
  proc { |ability,battler,status|
    next true if status==PBStatuses::FROZEN
  }
)

BattleHandlers::StatusImmunityAbility.add(:WATERVEIL,
  proc { |ability,battler,status|
    next true if status==PBStatuses::BURN
  }
)

BattleHandlers::StatusImmunityAbility.copy(:WATERVEIL,:WATERBUBBLE)

#===============================================================================
# StatusImmunityAbilityNonIgnorable handlers
#===============================================================================

BattleHandlers::StatusImmunityAbilityNonIgnorable.add(:COMATOSE,
  proc { |ability,battler,status|
    next true if battler.isSpecies?(:KOMALA)
  }
)

BattleHandlers::StatusImmunityAbilityNonIgnorable.add(:SHIELDSDOWN,
  proc { |ability,battler,status|
    next true if battler.isSpecies?(:MINIOR) && battler.form<7
  }
)

#===============================================================================
# StatusImmunityAllyAbility handlers
#===============================================================================

BattleHandlers::StatusImmunityAllyAbility.add(:FLOWERVEIL,
  proc { |ability,battler,status|
    next true if battler.pbHasType?(:GRASS)
  }
)

BattleHandlers::StatusImmunityAllyAbility.add(:SWEETVEIL,
  proc { |ability,battler,status|
    next true if status==PBStatuses::SLEEP
  }
)

BattleHandlers::StatusImmunityAllyAbility.add(:PASTELVEIL,
  proc { |ability,battler,status|
    next true if status==PBStatuses::POISON
  }
)

#===============================================================================
# AbilityOnStatusInflicted handlers
#===============================================================================

BattleHandlers::AbilityOnStatusInflicted.add(:SYNCHRONIZE,
  proc { |ability,battler,user,status|
    next if !user || user.index==battler.index
    case status
    when PBStatuses::POISON
      if user.pbCanPoisonSynchronize?(battler)
        battler.battle.pbShowAbilitySplash(battler)
        msg = nil
        if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          msg = _INTL("{1}'s {2} poisoned {3}!",battler.pbThis,battler.abilityName,user.pbThis(true))
        end
        user.pbPoison(nil,msg,(battler.statusCount>0))
        battler.battle.pbHideAbilitySplash(battler)
      end
    when PBStatuses::BURN
      if user.pbCanBurnSynchronize?(battler)
        battler.battle.pbShowAbilitySplash(battler)
        msg = nil
        if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          msg = _INTL("{1}'s {2} burned {3}!",battler.pbThis,battler.abilityName,user.pbThis(true))
        end
        user.pbBurn(nil,msg)
        battler.battle.pbHideAbilitySplash(battler)
      end
    when PBStatuses::PARALYSIS
      if user.pbCanParalyzeSynchronize?(battler)
        battler.battle.pbShowAbilitySplash(battler)
        msg = nil
        if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          msg = _INTL("{1}'s {2} paralyzed {3}! It may be unable to move!",
             battler.pbThis,battler.abilityName,user.pbThis(true))
        end
        user.pbParalyze(nil,msg)
        battler.battle.pbHideAbilitySplash(battler)
      end
    end
  }
)

#===============================================================================
# StatusCureAbility handlers
#===============================================================================

BattleHandlers::StatusCureAbility.add(:IMMUNITY,
  proc { |ability,battler|
    next if battler.status!=PBStatuses::POISON
    battler.battle.pbShowAbilitySplash(battler)
    battler.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battler.battle.pbDisplay(_INTL("{1}'s {2} cured its poisoning!",battler.pbThis,battler.abilityName))
    end
    battler.battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::StatusCureAbility.add(:INSOMNIA,
  proc { |ability,battler|
    next if battler.status!=PBStatuses::SLEEP
    battler.battle.pbShowAbilitySplash(battler)
    battler.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battler.battle.pbDisplay(_INTL("{1}'s {2} woke it up!",battler.pbThis,battler.abilityName))
    end
    battler.battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::StatusCureAbility.copy(:INSOMNIA,:VITALSPIRIT)

BattleHandlers::StatusCureAbility.add(:LIMBER,
  proc { |ability,battler|
    next if battler.status!=PBStatuses::PARALYSIS
    battler.battle.pbShowAbilitySplash(battler)
    battler.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battler.battle.pbDisplay(_INTL("{1}'s {2} cured its paralysis!",battler.pbThis,battler.abilityName))
    end
    battler.battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::StatusCureAbility.add(:MAGMAARMOR,
  proc { |ability,battler|
    next if battler.status!=PBStatuses::FROZEN
    battler.battle.pbShowAbilitySplash(battler)
    battler.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battler.battle.pbDisplay(_INTL("{1}'s {2} defrosted it!",battler.pbThis,battler.abilityName))
    end
    battler.battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::StatusCureAbility.add(:OBLIVIOUS,
  proc { |ability,battler|
    next if battler.effects[PBEffects::Attract]<0 &&
            (battler.effects[PBEffects::Taunt]==0 || !NEWEST_BATTLE_MECHANICS)
    battler.battle.pbShowAbilitySplash(battler)
    if battler.effects[PBEffects::Attract]>=0
      battler.pbCureAttract
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battler.battle.pbDisplay(_INTL("{1} got over its infatuation.",battler.pbThis))
      else
        battler.battle.pbDisplay(_INTL("{1}'s {2} cured its infatuation status!",
           battler.pbThis,battler.abilityName))
      end
    end
    if battler.effects[PBEffects::Taunt]>0 && NEWEST_BATTLE_MECHANICS
      battler.effects[PBEffects::Taunt] = 0
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battler.battle.pbDisplay(_INTL("{1}'s Taunt wore off!",battler.pbThis))
      else
        battler.battle.pbDisplay(_INTL("{1}'s {2} made its taunt wear off!",
           battler.pbThis,battler.abilityName))
      end
    end
    battler.battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::StatusCureAbility.add(:OWNTEMPO,
  proc { |ability,battler|
    next if battler.effects[PBEffects::Confusion]==0
    battler.battle.pbShowAbilitySplash(battler)
    battler.pbCureConfusion
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battler.battle.pbDisplay(_INTL("{1} snapped out of its confusion.",battler.pbThis))
    else
      battler.battle.pbDisplay(_INTL("{1}'s {2} snapped it out of its confusion!",
         battler.pbThis,battler.abilityName))
    end
    battler.battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::StatusCureAbility.add(:WATERVEIL,
  proc { |ability,battler|
    next if battler.status!=PBStatuses::BURN
    battler.battle.pbShowAbilitySplash(battler)
    battler.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battler.battle.pbDisplay(_INTL("{1}'s {2} healed its burn!",battler.pbThis,battler.abilityName))
    end
    battler.battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::StatusCureAbility.copy(:WATERVEIL,:WATERBUBBLE)

#===============================================================================
# StatLossImmunityAbility handlers
#===============================================================================

BattleHandlers::StatLossImmunityAbility.add(:BIGPECKS,
  proc { |ability,battler,stat,battle,showMessages|
    next false if stat!=PBStats::DEFENSE
    if showMessages
      battle.pbShowAbilitySplash(battler)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s {2} cannot be lowered!",battler.pbThis,PBStats.getName(stat)))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents {3} loss!",battler.pbThis,
           battler.abilityName,PBStats.getName(stat)))
      end
      battle.pbHideAbilitySplash(battler)
    end
    next true
  }
)

BattleHandlers::StatLossImmunityAbility.add(:CLEARBODY,
  proc { |ability,battler,stat,battle,showMessages|
    if showMessages
      battle.pbShowAbilitySplash(battler)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s stats cannot be lowered!",battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",battler.pbThis,battler.abilityName))
      end
      battle.pbHideAbilitySplash(battler)
    end
    next true
  }
)

BattleHandlers::StatLossImmunityAbility.copy(:CLEARBODY,:WHITESMOKE)

BattleHandlers::StatLossImmunityAbility.add(:FLOWERVEIL,
  proc { |ability,battler,stat,battle,showMessages|
    next false if !battler.pbHasType?(:GRASS)
    if showMessages
      battle.pbShowAbilitySplash(battler)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s stats cannot be lowered!",battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",battler.pbThis,battler.abilityName))
      end
      battle.pbHideAbilitySplash(battler)
    end
    next true
  }
)

BattleHandlers::StatLossImmunityAbility.add(:HYPERCUTTER,
  proc { |ability,battler,stat,battle,showMessages|
    next false if stat!=PBStats::ATTACK
    if showMessages
      battle.pbShowAbilitySplash(battler)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s {2} cannot be lowered!",battler.pbThis,PBStats.getName(stat)))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents {3} loss!",battler.pbThis,
           battler.abilityName,PBStats.getName(stat)))
      end
      battle.pbHideAbilitySplash(battler)
    end
    next true
  }
)

BattleHandlers::StatLossImmunityAbility.add(:KEENEYE,
  proc { |ability,battler,stat,battle,showMessages|
    next false if stat!=PBStats::ACCURACY
    if showMessages
      battle.pbShowAbilitySplash(battler)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s {2} cannot be lowered!",battler.pbThis,PBStats.getName(stat)))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents {3} loss!",battler.pbThis,
           battler.abilityName,PBStats.getName(stat)))
      end
      battle.pbHideAbilitySplash(battler)
    end
    next true
  }
)

#===============================================================================
# StatLossImmunityAbilityNonIgnorable handlers
#===============================================================================

BattleHandlers::StatLossImmunityAbilityNonIgnorable.add(:FULLMETALBODY,
  proc { |ability,battler,stat,battle,showMessages|
    if showMessages
      battle.pbShowAbilitySplash(battler)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s stats cannot be lowered!",battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",battler.pbThis,battler.abilityName))
      end
      battle.pbHideAbilitySplash(battler)
    end
    next true
  }
)

#===============================================================================
# StatLossImmunityAllyAbility handlers
#===============================================================================

BattleHandlers::StatLossImmunityAllyAbility.add(:FLOWERVEIL,
  proc { |ability,bearer,battler,stat,battle,showMessages|
    next false if !battler.pbHasType?(:GRASS)
    if showMessages
      battle.pbShowAbilitySplash(bearer)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s stats cannot be lowered!",battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s stat loss!",
           bearer.pbThis,bearer.abilityName,battler.pbThis(true)))
      end
      battle.pbHideAbilitySplash(bearer)
    end
    next true
  }
)

#===============================================================================
# AbilityOnStatGain handlers
#===============================================================================

# There aren't any!

#===============================================================================
# AbilityOnStatLoss handlers
#===============================================================================

BattleHandlers::AbilityOnStatLoss.add(:COMPETITIVE,
  proc { |ability,battler,stat,user|
    next if user && !user.opposes?(battler)
    battler.pbRaiseStatStageByAbility(PBStats::SPATK,2,battler)
  }
)

BattleHandlers::AbilityOnStatLoss.add(:DEFIANT,
  proc { |ability,battler,stat,user|
    next if user && !user.opposes?(battler)
    battler.pbRaiseStatStageByAbility(PBStats::ATTACK,2,battler)
  }
)

#===============================================================================
# PriorityChangeAbility handlers
#===============================================================================

BattleHandlers::PriorityChangeAbility.add(:GALEWINGS,
  proc { |ability,battler,move,pri|
    next pri+1 if battler.hp==battler.totalhp && isConst?(move.type,PBTypes,:FLYING)
  }
)

BattleHandlers::PriorityChangeAbility.add(:PRANKSTER,
  proc { |ability,battler,move,pri|
    if move.statusMove?
      battler.effects[PBEffects::Prankster] = true
      next pri+1
    end
  }
)

BattleHandlers::PriorityChangeAbility.add(:TRIAGE,
  proc { |ability,battler,move,pri|
    next pri+3 if move.healingMove?
  }
)

#===============================================================================
# PriorityBracketChangeAbility handlers
#===============================================================================

BattleHandlers::PriorityBracketChangeAbility.add(:STALL,
  proc { |ability,battler,subPri,battle|
    next -1 if subPri==0
  }
)

BattleHandlers::PriorityBracketChangeAbility.add(:QUICKDRAW,
  proc { |ability,battler,subPri,battle|
    next 1 if subPri<1 && battle.pbRandom(10)<3
  }
)

#===============================================================================
# PriorityBracketUseAbility handlers
#===============================================================================

BattleHandlers::PriorityBracketUseAbility.add(:QUICKDRAW,
  proc { |ability,battler,battle|
    battle.pbDisplay(_INTL("{1}'s {2} let it move first!",battler.pbThis,battler.abilityName))
  }
)

#===============================================================================
# AbilityOnFlinch handlers
#===============================================================================

BattleHandlers::AbilityOnFlinch.add(:STEADFAST,
  proc { |ability,battler,battle|
    battler.pbRaiseStatStageByAbility(PBStats::SPEED,1,battler)
  }
)

#===============================================================================
# MoveBlockingAbility handlers
#===============================================================================

BattleHandlers::MoveBlockingAbility.add(:DAZZLING,
  proc { |ability,bearer,user,targets,move,battle|
    next false if battle.choices[user.index][4]<=0
    next false if !bearer.opposes?(user)
    ret = false
    targets.each do |b|
      next if !b.opposes?(user)
      ret = true
    end
    next ret
  }
)

BattleHandlers::MoveBlockingAbility.copy(:DAZZLING,:QUEENLYMAJESTY)

#===============================================================================
# MoveImmunityTargetAbility handlers
#===============================================================================

BattleHandlers::MoveImmunityTargetAbility.add(:BULLETPROOF,
  proc { |ability,user,target,move,type,battle|
    next false if !move.bombMove?
    battle.pbShowAbilitySplash(target)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
    else
      battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
         target.pbThis,target.abilityName,move.name))
    end
    battle.pbHideAbilitySplash(target)
    next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:FLASHFIRE,
  proc { |ability,user,target,move,type,battle|
    next false if user.index==target.index
    next false if !isConst?(type,PBTypes,:FIRE)
    battle.pbShowAbilitySplash(target)
    if !target.effects[PBEffects::FlashFire]
      target.effects[PBEffects::FlashFire] = true
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("The power of {1}'s Fire-type moves rose!",target.pbThis(true)))
      else
        battle.pbDisplay(_INTL("The power of {1}'s Fire-type moves rose because of its {2}!",
           target.pbThis(true),target.abilityName))
      end
    else
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
      else
        battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
           target.pbThis,target.abilityName,move.name))
      end
    end
    battle.pbHideAbilitySplash(target)
    next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:LIGHTNINGROD,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:ELECTRIC,PBStats::SPATK,1,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:MOTORDRIVE,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:ELECTRIC,PBStats::SPEED,1,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:SAPSIPPER,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:GRASS,PBStats::ATTACK,1,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:SOUNDPROOF,
  proc { |ability,user,target,move,type,battle|
    next false if !move.soundMove?
    battle.pbShowAbilitySplash(target)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
    else
      battle.pbDisplay(_INTL("{1}'s {2} blocks {3}!",target.pbThis,target.abilityName,move.name))
    end
    battle.pbHideAbilitySplash(target)
    next true

  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:STORMDRAIN,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:WATER,PBStats::SPATK,1,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:TELEPATHY,
  proc { |ability,user,target,move,type,battle|
    next false if move.statusMove?
    next false if user.index==target.index || target.opposes?(user)
    battle.pbShowAbilitySplash(target)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1} avoids attacks by its ally Pokémon!",target.pbThis(true)))
    else
      battle.pbDisplay(_INTL("{1} avoids attacks by its ally Pokémon with {2}!",
         target.pbThis,target.abilityName))
    end
    battle.pbHideAbilitySplash(target)
    next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:VOLTABSORB,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityHealAbility(user,target,move,type,:ELECTRIC,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:WATERABSORB,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityHealAbility(user,target,move,type,:WATER,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.copy(:WATERABSORB,:DRYSKIN)

BattleHandlers::MoveImmunityTargetAbility.add(:WONDERGUARD,
  proc { |ability,user,target,move,type,battle|
    next false if move.statusMove?
    next false if type<0 || PBTypes.superEffective?(target.damageState.typeMod)
    battle.pbShowAbilitySplash(target)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
    else
      battle.pbDisplay(_INTL("{1} avoided damage with {2}!",target.pbThis,target.abilityName))
    end
    battle.pbHideAbilitySplash(target)
    next true
  }
)

#===============================================================================
# MoveBaseTypeModifierAbility handlers
#===============================================================================

BattleHandlers::MoveBaseTypeModifierAbility.add(:AERILATE,
  proc { |ability,user,move,type|
    next if !isConst?(type,PBTypes,:NORMAL) || !hasConst?(PBTypes,:FLYING)
    move.powerBoost = true
    next getConst(PBTypes,:FLYING)
  }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:GALVANIZE,
  proc { |ability,user,move,type|
    next if !isConst?(type,PBTypes,:NORMAL) || !hasConst?(PBTypes,:ELECTRIC)
    move.powerBoost = true
    next getConst(PBTypes,:ELECTRIC)
  }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:LIQUIDVOICE,
  proc { |ability,user,move,type|
    next getConst(PBTypes,:WATER) if hasConst?(PBTypes,:WATER) && move.soundMove?
  }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:NORMALIZE,
  proc { |ability,user,move,type|
    next if !hasConst?(PBTypes,:NORMAL)
    move.powerBoost = true if NEWEST_BATTLE_MECHANICS
    next getConst(PBTypes,:NORMAL)
  }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:PIXILATE,
  proc { |ability,user,move,type|
    next if !isConst?(type,PBTypes,:NORMAL) || !hasConst?(PBTypes,:FAIRY)
    move.powerBoost = true
    next getConst(PBTypes,:FAIRY)
  }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:REFRIGERATE,
  proc { |ability,user,move,type|
    next if !isConst?(type,PBTypes,:NORMAL) || !hasConst?(PBTypes,:ICE)
    move.powerBoost = true
    next getConst(PBTypes,:ICE)
  }
)

#===============================================================================
# AccuracyCalcUserAbility handlers
#===============================================================================

BattleHandlers::AccuracyCalcUserAbility.add(:COMPOUNDEYES,
  proc { |ability,mods,user,target,move,type|
    mods[ACC_MULT] = (mods[ACC_MULT]*1.3).round
  }
)

BattleHandlers::AccuracyCalcUserAbility.add(:HUSTLE,
  proc { |ability,mods,user,target,move,type|
    mods[ACC_MULT] = (mods[ACC_MULT]*0.8).round if move.physicalMove?
  }
)

BattleHandlers::AccuracyCalcUserAbility.add(:KEENEYE,
  proc { |ability,mods,user,target,move,type|
    mods[EVA_STAGE] = 0 if mods[EVA_STAGE]>0 && NEWEST_BATTLE_MECHANICS
  }
)

BattleHandlers::AccuracyCalcUserAbility.add(:NOGUARD,
  proc { |ability,mods,user,target,move,type|
    mods[BASE_ACC] = 0
  }
)

BattleHandlers::AccuracyCalcUserAbility.add(:UNAWARE,
  proc { |ability,mods,user,target,move,type|
    mods[EVA_STAGE] = 0 if move.damagingMove?
  }
)

BattleHandlers::AccuracyCalcUserAbility.add(:VICTORYSTAR,
  proc { |ability,mods,user,target,move,type|
    mods[ACC_MULT] = (mods[ACC_MULT]*1.1).round
  }
)

#===============================================================================
# AccuracyCalcUserAllyAbility handlers
#===============================================================================

BattleHandlers::AccuracyCalcUserAllyAbility.add(:VICTORYSTAR,
  proc { |ability,mods,user,target,move,type|
    mods[ACC_MULT] = (mods[ACC_MULT]*1.1).round
  }
)

#===============================================================================
# AccuracyCalcTargetAbility handlers
#===============================================================================

BattleHandlers::AccuracyCalcTargetAbility.add(:LIGHTNINGROD,
  proc { |ability,mods,user,target,move,type|
    mods[BASE_ACC] = 0 if isConst?(type,PBTypes,:ELECTRIC)
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:NOGUARD,
  proc { |ability,mods,user,target,move,type|
    mods[BASE_ACC] = 0
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:SANDVEIL,
  proc { |ability,mods,user,target,move,type|
    if target.battle.pbWeather==PBWeather::Sandstorm
      mods[EVA_MULT] = (mods[EVA_MULT]*1.25).round
    end
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:SNOWCLOAK,
  proc { |ability,mods,user,target,move,type|
    if target.battle.pbWeather==PBWeather::Hail
      mods[EVA_MULT] = (mods[EVA_MULT]*1.25).round
    end
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:STORMDRAIN,
  proc { |ability,mods,user,target,move,type|
    mods[BASE_ACC] = 0 if isConst?(type,PBTypes,:WATER)
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:TANGLEDFEET,
  proc { |ability,mods,user,target,move,type|
    mods[ACC_MULT] /= 2 if target.effects[PBEffects::Confusion]>0
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:UNAWARE,
  proc { |ability,mods,user,target,move,type|
    mods[ACC_STAGE] = 0 if move.damagingMove?
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:WONDERSKIN,
  proc { |ability,mods,user,target,move,type|
    if move.statusMove? && user.opposes?(target)
      mods[BASE_ACC] = 0 if mods[BASE_ACC]>50
    end
  }
)

#===============================================================================
# DamageCalcUserAbility handlers
#===============================================================================

BattleHandlers::DamageCalcUserAbility.add(:AERILATE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[BASE_DMG_MULT] = (mults[BASE_DMG_MULT]*1.2).round if move.powerBoost
  }
)

BattleHandlers::DamageCalcUserAbility.copy(:AERILATE,:PIXILATE,:REFRIGERATE,:GALVANIZE)

BattleHandlers::DamageCalcUserAbility.add(:ANALYTIC,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if (target.battle.choices[target.index][0]!=:UseMove &&
       target.battle.choices[target.index][0]!=:Shift) ||
       target.movedThisRound?
      mults[BASE_DMG_MULT] = (mults[BASE_DMG_MULT]*1.3).round
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:BLAZE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.hp<=user.totalhp/3 && isConst?(type,PBTypes,:FIRE)
      mults[ATK_MULT] = (mults[ATK_MULT]*1.5).round
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:DEFEATIST,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[ATK_MULT] = (mults[ATK_MULT]*0.5).round if user.hp<=user.totalhp/2
  }
)

BattleHandlers::DamageCalcUserAbility.add(:FLAREBOOST,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.burned? && move.specialMove?
      mults[BASE_DMG_MULT] = (mults[BASE_DMG_MULT]*1.5).round
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:FLASHFIRE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.effects[PBEffects::FlashFire] && isConst?(type,PBTypes,:FIRE)
      mults[ATK_MULT] = (mults[ATK_MULT]*1.5).round
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:FLOWERGIFT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    w = user.battle.pbWeather
    if move.physicalMove? && (w==PBWeather::Sun || w==PBWeather::HarshSun)
      mults[ATK_MULT] = (mults[ATK_MULT]*1.5).round
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:GUTS,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.pbHasAnyStatus? && move.physicalMove?
      mults[ATK_MULT] = (mults[ATK_MULT]*1.5).round
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:HUGEPOWER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[ATK_MULT] *= 2 if move.physicalMove?
  }
)

BattleHandlers::DamageCalcUserAbility.copy(:HUGEPOWER,:PUREPOWER)

BattleHandlers::DamageCalcUserAbility.add(:HUSTLE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[ATK_MULT] = (mults[ATK_MULT]*1.5).round if move.physicalMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:IRONFIST,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[BASE_DMG_MULT] = (mults[BASE_DMG_MULT]*1.2).round if move.punchingMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:MEGALAUNCHER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[BASE_DMG_MULT] = (mults[BASE_DMG_MULT]*1.5).round if move.pulseMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:MINUS,
  proc { |ability,user,target,move,mults,baseDmg,type|
    next if !move.specialMove?
    user.eachAlly do |b|
      next if !b.hasActiveAbility?([:MINUS,:PLUS])
      mults[ATK_MULT] = (mults[ATK_MULT]*1.5).round
      break
    end
  }
)

BattleHandlers::DamageCalcUserAbility.copy(:MINUS,:PLUS)

BattleHandlers::DamageCalcUserAbility.add(:NEUROFORCE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if PBTypes.superEffective?(target.damageState.typeMod)
      mults[FINAL_DMG_MULT] = (mults[FINAL_DMG_MULT]*1.25).round
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:OVERGROW,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.hp<=user.totalhp/3 && isConst?(type,PBTypes,:GRASS)
      mults[ATK_MULT] = (mults[ATK_MULT]*1.5).round
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:RECKLESS,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[BASE_DMG_MULT] = (mults[BASE_DMG_MULT]*1.2).round if move.recoilMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:RIVALRY,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.gender!=2 && target.gender!=2
      if user.gender==target.gender
        mults[BASE_DMG_MULT] = (mults[BASE_DMG_MULT]*1.25).round
      else
        mults[BASE_DMG_MULT] = (mults[BASE_DMG_MULT]*0.75).round
      end
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SANDFORCE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.battle.pbWeather==PBWeather::Sandstorm &&
       (isConst?(type,PBTypes,:ROCK) ||
       isConst?(type,PBTypes,:GROUND) ||
       isConst?(type,PBTypes,:STEEL))
      mults[BASE_DMG_MULT] = (mults[BASE_DMG_MULT]*1.3).round
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SHEERFORCE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[BASE_DMG_MULT] = (mults[BASE_DMG_MULT]*1.3).round if move.addlEffect>0
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SLOWSTART,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.turnCount<=5 && move.physicalMove?
      mults[ATK_MULT] = (mults[ATK_MULT]*0.5).round
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SOLARPOWER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    w = user.battle.pbWeather
    if move.specialMove? && (w==PBWeather::Sun || w==PBWeather::HarshSun)
      mults[ATK_MULT] = (mults[ATK_MULT]*1.5).round
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SNIPER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if target.damageState.critical
      mults[FINAL_DMG_MULT] = (mults[FINAL_DMG_MULT]*1.5).round
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:STAKEOUT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[ATK_MULT] *= 2 if target.battle.choices[target.index][0]==:SwitchOut
  }
)

BattleHandlers::DamageCalcUserAbility.add(:STEELWORKER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[ATK_MULT] = (mults[ATK_MULT]*1.5).round if isConst?(type,PBTypes,:STEEL)
  }
)

BattleHandlers::DamageCalcUserAbility.add(:STRONGJAW,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[BASE_DMG_MULT] = (mults[BASE_DMG_MULT]*1.5).round if move.bitingMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SWARM,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.hp<=user.totalhp/3 && isConst?(type,PBTypes,:BUG)
      mults[ATK_MULT] = (mults[ATK_MULT]*1.5).round
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TECHNICIAN,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.index!=target.index && move.id>0 && baseDmg*mults[BASE_DMG_MULT]/0x1000<=60
      mults[BASE_DMG_MULT] = (mults[BASE_DMG_MULT]*1.5).round
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TINTEDLENS,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[FINAL_DMG_MULT] *= 2 if PBTypes.resistant?(target.damageState.typeMod)
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TORRENT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.hp<=user.totalhp/3 && isConst?(type,PBTypes,:WATER)
      mults[ATK_MULT] = (mults[ATK_MULT]*1.5).round
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TOUGHCLAWS,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[BASE_DMG_MULT] = (mults[BASE_DMG_MULT]*4/3.0).round if move.contactMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TOXICBOOST,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.poisoned? && move.physicalMove?
      mults[BASE_DMG_MULT] = (mults[BASE_DMG_MULT]*1.5).round
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:WATERBUBBLE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[ATK_MULT] *= 2 if isConst?(type,PBTypes,:WATER)
  }
)

BattleHandlers::DamageCalcUserAbility.add(:GORILLATACTICS,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[ATK_MULT] = (mults[ATK_MULT]*1.5).round if move.physicalMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:PUNKROCK,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[ATK_MULT] = (mults[ATK_MULT]*1.3).round if move.soundMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:STEELYSPIRIT,
  proc { |ability,user,target,move,mults,baseDmg,type|
      mults[ATK_MULT] = (mults[ATK_MULT]*1.5).round if isConst?(type,PBTypes,:STEEL)
  }
)

#===============================================================================
# DamageCalcUserAllyAbility handlers
#===============================================================================

BattleHandlers::DamageCalcUserAllyAbility.add(:BATTERY,
  proc { |ability,user,target,move,mults,baseDmg,type|
    next if !move.specialMove?
    mults[FINAL_DMG_MULT] = (mults[FINAL_DMG_MULT]*1.3).round
  }
)

BattleHandlers::DamageCalcUserAllyAbility.add(:FLOWERGIFT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    w = user.battle.pbWeather
    if move.physicalMove? && (w==PBWeather::Sun || w==PBWeather::HarshSun)
      mults[ATK_MULT] = (mults[ATK_MULT]*1.5).round
    end
  }
)

BattleHandlers::DamageCalcUserAllyAbility.add(:POWERSPOT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[FINAL_DMG_MULT] = (mults[FINAL_DMG_MULT]*1.3).round
  }
)

BattleHandlers::DamageCalcUserAllyAbility.add(:STEELYSPIRIT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[ATK_MULT] = (mults[ATK_MULT]*1.5).round if isConst?(type,PBTypes,:STEEL)
  }
)

#===============================================================================
# DamageCalcTargetAbility handlers
#===============================================================================

BattleHandlers::DamageCalcTargetAbility.add(:DRYSKIN,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if isConst?(type,PBTypes,:FIRE)
      mults[BASE_DMG_MULT] = (mults[BASE_DMG_MULT]*1.25).round
    end
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:FILTER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if PBTypes.superEffective?(target.damageState.typeMod)
      mults[FINAL_DMG_MULT] = (mults[FINAL_DMG_MULT]*0.75).round
    end
  }
)

BattleHandlers::DamageCalcTargetAbility.copy(:FILTER,:SOLIDROCK)

BattleHandlers::DamageCalcTargetAbility.add(:FLOWERGIFT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    w = user.battle.pbWeather
    if move.specialMove? && (w==PBWeather::Sun || w==PBWeather::HarshSun)
      mults[DEF_MULT] = (mults[DEF_MULT]*1.5).round
    end
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:FLUFFY,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[FINAL_DMG_MULT] *= 2 if isConst?(move.calcType,PBTypes,:FIRE)
    mults[FINAL_DMG_MULT] = (mults[FINAL_DMG_MULT]*0.5).round if move.contactMove?
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:FURCOAT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[DEF_MULT] *= 2 if move.physicalMove? || move.function=="122"   # Psyshock
  }
)

  BattleHandlers::DamageCalcTargetAbility.add(:ICESCALES,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[DEF_MULT] *= 2 if move.specialMove? || move.function=="122"   # Psyshock
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:GRASSPELT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.battle.field.terrain==PBBattleTerrains::Grassy
      mults[DEF_MULT] = (mults[DEF_MULT]*1.5).round
    end
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:HEATPROOF,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[BASE_DMG_MULT] = (mults[BASE_DMG_MULT]*0.5).round if isConst?(type,PBTypes,:FIRE)
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:MARVELSCALE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if target.pbHasAnyStatus? && move.physicalMove?
      mults[DEF_MULT] = (mults[DEF_MULT]*1.5).round
    end
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:MULTISCALE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if target.hp==target.totalhp
      mults[FINAL_DMG_MULT] = (mults[FINAL_DMG_MULT]*0.5).round
    end
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:THICKFAT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if isConst?(type,PBTypes,:FIRE) || isConst?(type,PBTypes,:ICE)
      mults[BASE_DMG_MULT] = (mults[BASE_DMG_MULT]*0.5).round
    end
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:WATERBUBBLE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if isConst?(type,PBTypes,:FIRE)
      mults[FINAL_DMG_MULT] = (mults[FINAL_DMG_MULT]*0.5).round
    end
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:PUNKROCK,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[DEF_MULT] *= 2 if move.soundMove?
  }
)

#===============================================================================
# DamageCalcTargetAbilityNonIgnorable handlers
#===============================================================================

BattleHandlers::DamageCalcTargetAbilityNonIgnorable.add(:PRISMARMOR,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if PBTypes.superEffective?(target.damageState.typeMod)
      mults[FINAL_DMG_MULT] = (mults[FINAL_DMG_MULT]*0.75).round
    end
  }
)

BattleHandlers::DamageCalcTargetAbilityNonIgnorable.add(:SHADOWSHIELD,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if target.hp==target.totalhp
      mults[FINAL_DMG_MULT] = (mults[FINAL_DMG_MULT]*0.5).round
    end
  }
)

#===============================================================================
# DamageCalcTargetAllyAbility handlers
#===============================================================================

BattleHandlers::DamageCalcTargetAllyAbility.add(:FLOWERGIFT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    w = user.battle.pbWeather
    if move.specialMove? && (w==PBWeather::Sun || w==PBWeather::HarshSun)
      mults[DEF_MULT] = (mults[DEF_MULT]*1.5).round
    end
  }
)

BattleHandlers::DamageCalcTargetAllyAbility.add(:FRIENDGUARD,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[FINAL_DMG_MULT] = (mults[FINAL_DMG_MULT]*0.75).round
  }
)

#===============================================================================
# CriticalCalcUserAbility handlers
#===============================================================================

BattleHandlers::CriticalCalcUserAbility.add(:MERCILESS,
  proc { |ability,user,target,c|
    next 99 if target.poisoned?
  }
)

BattleHandlers::CriticalCalcUserAbility.add(:SUPERLUCK,
  proc { |ability,user,target,c|
    next c+1
  }
)

#===============================================================================
# CriticalCalcTargetAbility handlers
#===============================================================================

BattleHandlers::CriticalCalcTargetAbility.add(:BATTLEARMOR,
  proc { |ability,user,target,c|
    next -1
  }
)

BattleHandlers::CriticalCalcTargetAbility.copy(:BATTLEARMOR,:SHELLARMOR)

#===============================================================================
# TargetAbilityOnHit handlers
#===============================================================================

BattleHandlers::TargetAbilityOnHit.add(:AFTERMATH,
  proc { |ability,user,target,move,battle|
    next if !target.fainted?
    next if !move.pbContactMove?(user)
    battle.pbShowAbilitySplash(target)
    if !battle.moldBreaker
      dampBattler = battle.pbCheckGlobalAbility(:DAMP)
      if dampBattler
        battle.pbShowAbilitySplash(dampBattler)
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          battle.pbDisplay(_INTL("{1} cannot use {2}!",target.pbThis,target.abilityName))
        else
          battle.pbDisplay(_INTL("{1} cannot use {2} because of {3}'s {4}!",
             target.pbThis,target.abilityName,dampBattler.pbThis(true),dampBattler.abilityName))
        end
        battle.pbHideAbilitySplash(dampBattler)
        battle.pbHideAbilitySplash(target)
        next
      end
    end
    if user.takesIndirectDamage?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      battle.scene.pbDamageAnimation(user)
      user.pbReduceHP(user.totalhp/4,false)
      battle.pbDisplay(_INTL("{1} was caught in the aftermath!",user.pbThis))
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:ANGERPOINT,
  proc { |ability,user,target,move,battle|
    next if !target.damageState.critical
    next if !target.pbCanRaiseStatStage?(PBStats::ATTACK,target)
    battle.pbShowAbilitySplash(target)
    target.stages[PBStats::ATTACK] = 6
    battle.pbCommonAnimation("StatUp",target)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1} maxed its {2}!",target.pbThis,PBStats.getName(PBStats::ATTACK)))
    else
      battle.pbDisplay(_INTL("{1}'s {2} maxed its {3}!",
         target.pbThis,target.abilityName,PBStats.getName(PBStats::ATTACK)))
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:CURSEDBODY,
  proc { |ability,user,target,move,battle|
    next if user.fainted?
    next if user.effects[PBEffects::Disable]>0
    regularMove = nil
    user.eachMove do |m|
      next if m.id!=user.lastRegularMoveUsed
      regularMove = m
      break
    end
    next if !regularMove || (regularMove.pp==0 && regularMove.totalpp>0)
    next if battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(target)
    if !move.pbMoveFailedAromaVeil?(target,user,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      user.effects[PBEffects::Disable]     = 3
      user.effects[PBEffects::DisableMove] = regularMove.id
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s {2} was disabled!",user.pbThis,regularMove.name))
      else
        battle.pbDisplay(_INTL("{1}'s {2} was disabled by {3}'s {4}!",
           user.pbThis,regularMove.name,target.pbThis(true),target.abilityName))
      end
      battle.pbHideAbilitySplash(target)
      user.pbItemStatusCureCheck
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:CUTECHARM,
  proc { |ability,user,target,move,battle|
    next if target.fainted?
    next if !move.pbContactMove?(user)
    next if battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(target)
    if user.pbCanAttract?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} made {3} fall in love!",target.pbThis,
           target.abilityName,user.pbThis(true))
      end
      user.pbAttract(target,msg)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:EFFECTSPORE,
  proc { |ability,user,target,move,battle|
    # NOTE: This ability has a 30% chance of triggering, not a 30% chance of
    #       inflicting a status condition. It can try (and fail) to inflict a
    #       status condition that the user is immune to.
    next if !move.pbContactMove?(user)
    next if battle.pbRandom(100)>=30
    r = battle.pbRandom(3)
    next if r==0 && user.asleep?
    next if r==1 && user.poisoned?
    next if r==2 && user.paralyzed?
    battle.pbShowAbilitySplash(target)
    if user.affectedByPowder?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      case r
      when 0
        if user.pbCanSleep?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
          msg = nil
          if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            msg = _INTL("{1}'s {2} made {3} fall asleep!",target.pbThis,
               target.abilityName,user.pbThis(true))
          end
          user.pbSleep(msg)
        end
      when 1
        if user.pbCanPoison?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
          msg = nil
          if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            msg = _INTL("{1}'s {2} poisoned {3}!",target.pbThis,
               target.abilityName,user.pbThis(true))
          end
          user.pbPoison(target,msg)
        end
      when 2
        if user.pbCanParalyze?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
          msg = nil
          if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            msg = _INTL("{1}'s {2} paralyzed {3}! It may be unable to move!",
               target.pbThis,target.abilityName,user.pbThis(true))
          end
          user.pbParalyze(target,msg)
        end
      end
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:FLAMEBODY,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if user.burned? || battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(target)
    if user.pbCanBurn?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} burned {3}!",target.pbThis,target.abilityName,user.pbThis(true))
      end
      user.pbBurn(target,msg)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:GOOEY,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    user.pbLowerStatStageByAbility(PBStats::SPEED,1,target,true,true)
  }
)

BattleHandlers::TargetAbilityOnHit.copy(:GOOEY,:TANGLINGHAIR)

BattleHandlers::TargetAbilityOnHit.add(:ILLUSION,
  proc { |ability,user,target,move,battle|
    # NOTE: This intentionally doesn't show the ability splash.
    next if !target.effects[PBEffects::Illusion]
    target.effects[PBEffects::Illusion] = nil
    battle.scene.pbChangePokemon(target,target.pokemon)
    battle.pbDisplay(_INTL("{1}'s illusion wore off!",target.pbThis))
    battle.pbSetSeen(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:INNARDSOUT,
  proc { |ability,user,target,move,battle|
    next if !target.fainted? || user.dummy
    battle.pbShowAbilitySplash(target)
    if user.takesIndirectDamage?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      battle.scene.pbDamageAnimation(user)
      user.pbReduceHP(target.damageState.hpLost,false)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} is hurt!",user.pbThis))
      else
        battle.pbDisplay(_INTL("{1} is hurt by {2}'s {3}!",user.pbThis,
           target.pbThis(true),target.abilityName))
      end
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:IRONBARBS,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    battle.pbShowAbilitySplash(target)
    if user.takesIndirectDamage?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      battle.scene.pbDamageAnimation(user)
      user.pbReduceHP(user.totalhp/8,false)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} is hurt!",user.pbThis))
      else
        battle.pbDisplay(_INTL("{1} is hurt by {2}'s {3}!",user.pbThis,
           target.pbThis(true),target.abilityName))
      end
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.copy(:IRONBARBS,:ROUGHSKIN)

BattleHandlers::TargetAbilityOnHit.add(:JUSTIFIED,
  proc { |ability,user,target,move,battle|
    next if !isConst?(move.calcType,PBTypes,:DARK)
    target.pbRaiseStatStageByAbility(PBStats::ATTACK,1,target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:MUMMY,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if user.fainted?
    abilityBlacklist = [
       # This ability
       :MUMMY,
       # Form-changing abilities
       :BATTLEBOND,
       :DISGUISE,
#       :FLOWERGIFT,                                      # This can be replaced
#       :FORECAST,                                        # This can be replaced
       :MULTITYPE,
       :POWERCONSTRUCT,
       :SCHOOLING,
       :SHIELDSDOWN,
       :STANCECHANGE,
       :ZENMODE,
       :ICEFACE,
       # Abilities intended to be inherent properties of a certain species
       :COMATOSE,
       :RKSSYSTEM,
       :GULPMISSILE
    ]
    failed = false
    abilityBlacklist.each do |abil|
      next if !isConst?(user.ability,PBAbilities,abil)
      failed = true
      break
    end
    next if failed
    oldAbil = -1
    battle.pbShowAbilitySplash(target) if user.opposes?(target)
    if user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      oldAbil = user.ability
      battle.pbShowAbilitySplash(user,true,false) if user.opposes?(target)
      user.ability = getConst(PBAbilities,:MUMMY)
      battle.pbReplaceAbilitySplash(user) if user.opposes?(target)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s Ability became {2}!",user.pbThis,user.abilityName))
      else
        battle.pbDisplay(_INTL("{1}'s Ability became {2} because of {3}!",
           user.pbThis,user.abilityName,target.pbThis(true)))
      end
      battle.pbHideAbilitySplash(user) if user.opposes?(target)
    end
    battle.pbHideAbilitySplash(target) if user.opposes?(target)
    user.pbOnAbilityChanged(oldAbil) if oldAbil>=0
  }
)

BattleHandlers::TargetAbilityOnHit.add(:POISONPOINT,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if user.poisoned? || battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(target)
    if user.pbCanPoison?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} poisoned {3}!",target.pbThis,target.abilityName,user.pbThis(true))
      end
      user.pbPoison(target,msg)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:RATTLED,
  proc { |ability,user,target,move,battle|
    next if !isConst?(move.calcType,PBTypes,:BUG) &&
            !isConst?(move.calcType,PBTypes,:DARK) &&
            !isConst?(move.calcType,PBTypes,:GHOST)
    target.pbRaiseStatStageByAbility(PBStats::SPEED,1,target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:STAMINA,
  proc { |ability,user,target,move,battle|
    target.pbRaiseStatStageByAbility(PBStats::DEFENSE,1,target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:SANDSPIT,
  proc { |ability,target,battler,move,battle|
    pbBattleWeatherAbility(PBWeather::Sandstorm,battler,battle)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:STATIC,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if user.paralyzed? || battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(target)
    if user.pbCanParalyze?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} paralyzed {3}! It may be unable to move!",
           target.pbThis,target.abilityName,user.pbThis(true))
      end
      user.pbParalyze(target,msg)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:WATERCOMPACTION,
  proc { |ability,user,target,move,battle|
    next if !isConst?(move.calcType,PBTypes,:WATER)
    target.pbRaiseStatStageByAbility(PBStats::DEFENSE,2,target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:WEAKARMOR,
  proc { |ability,user,target,move,battle|
    next if !move.physicalMove?
    next if !target.pbCanLowerStatStage?(PBStats::DEFENSE,target) &&
            !target.pbCanRaiseStatStage?(PBStats::SPEED,target)
    battle.pbShowAbilitySplash(target)
    target.pbLowerStatStageByAbility(PBStats::DEFENSE,1,target,false)
    target.pbRaiseStatStageByAbility(PBStats::SPEED,
       (NEWEST_BATTLE_MECHANICS) ? 2 : 1,target,false)
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:STEAMENGINE,
  proc { |ability,user,target,move,battle|
    next if !isConst?(move.calcType,PBTypes,:FIRE) &&
	    !isConst?(move.calcType,PBTypes,:WATER)
    target.pbRaiseStatStageByAbility(PBStats::SPEED,6,target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:WANDERINGSPIRIT,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if user.fainted?
    abilityBlacklist = [
       :DISGUISE,
       :FLOWERGIFT,
       :GULPMISSILE,
       :ICEFACE,
       :IMPOSTER,
       :RECEIVER,
       :RKSSYSTEM,
       :SCHOOLING,
       :STANCECHANGE,
       :WONDERGUARD,
       :ZENMODE,
       # Abilities that are plain old blocked.
       :NEUTRALIZINGGAS
    ]
    failed = false
    abilityBlacklist.each do |abil|
      next if !isConst?(user.ability,PBAbilities,abil)
      failed = true
      break
    end
    next if failed
    oldAbil = -1
    battle.pbShowAbilitySplash(target) if user.opposes?(target)
    if user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      oldAbil = user.ability
      battle.pbShowAbilitySplash(user,true,false) if user.opposes?(target)
      user.ability = getConst(PBAbilities,:WANDERINGSPIRIT)
      target.ability = oldAbil
      if user.opposes?(target)
        battle.pbReplaceAbilitySplash(user)
        battle.pbReplaceAbilitySplash(target)
      end
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s Ability became {2}!",user.pbThis,user.abilityName))
      else
        battle.pbDisplay(_INTL("{1}'s Ability became {2} because of {3}!",
           user.pbThis,user.abilityName,target.pbThis(true)))
      end

      battle.pbHideAbilitySplash(user)
    end
    battle.pbHideAbilitySplash(target) if user.opposes?(target)
    if oldAbil>=0
      user.pbOnAbilityChanged(oldAbil)
      target.pbOnAbilityChanged(getConst(PBAbilities,:WANDERINGSPIRIT))
    end

  }
)

BattleHandlers::TargetAbilityOnHit.add(:PERISHBODY,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if !user.affectedByContactEffect?
    next if user.effects[PBEffects::PerishSong]>0
    battle.pbShowAbilitySplash(target)
    battle.pbDisplay(_INTL("Both Pokémon will faint in three turns!"))
    user.effects[PBEffects::PerishSong] = 3
    target.effects[PBEffects::PerishSong] = 3 if target.effects[PBEffects::PerishSong] == 0
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:COTTONDOWN,
  proc { |ability,user,target,move,battle|
    battle.pbShowAbilitySplash(target)
    target.eachOpposing{|b|
      b.pbLowerStatStage(PBStats::SPEED,1,target)
    }
    target.eachAlly{|b|
      b.pbLowerStatStage(PBStats::SPEED,1,target)
    }
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:GULPMISSILE,
  proc { |ability,user,target,move,battle|
    next if target.form==0
    if isConst?(target.species,PBSpecies,:CRAMORANT)
      battle.pbShowAbilitySplash(target)
      gulpform=target.form
      target.form = 0
      battle.scene.pbChangePokemon(target,target.pokemon)
      if user.takesIndirectDamage?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
        battle.scene.pbDamageAnimation(user)
        user.pbReduceHP(user.totalhp/4,false)
        if gulpform==1
          user.pbLowerStatStageByAbility(PBStats::DEFENSE,1,target,false)
        elsif gulpform==2
          msg = nil
          user.pbParalyze(target,msg)
        end
      end
      battle.pbHideAbilitySplash(target)
    end
  }
)
#===============================================================================
# UserAbilityOnHit handlers
#===============================================================================

BattleHandlers::UserAbilityOnHit.add(:POISONTOUCH,
  proc { |ability,user,target,move,battle|
    next if !move.contactMove?
    next if battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(user)
    if target.hasActiveAbility?(:SHIELDDUST) && !battle.moldBreaker
      battle.pbShowAbilitySplash(target)
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} is unaffected!",target.pbThis))
      end
      battle.pbHideAbilitySplash(target)
    elsif target.pbCanPoison?(user,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} poisoned {3}!",user.pbThis,user.abilityName,target.pbThis(true))
      end
      target.pbPoison(user,msg)
    end
    battle.pbHideAbilitySplash(user)
  }
)

#===============================================================================
# UserAbilityEndOfMove handlers
#===============================================================================

BattleHandlers::UserAbilityEndOfMove.add(:BEASTBOOST,
  proc { |ability,user,targets,move,battle|
    next if battle.pbAllFainted?(user.idxOpposingSide)
    numFainted = 0
    targets.each { |b| numFainted += 1 if b.damageState.fainted }
    next if numFainted==0
    userStats = user.plainStats
    highestStatValue = userStats.max
    PBStats.eachMainBattleStat do |s|
      next if userStats[s]<highestStatValue
      if user.pbCanRaiseStatStage?(s,user)
        user.pbRaiseStatStageByAbility(s,numFainted,user)
      end
      break
    end
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:MAGICIAN,
  proc { |ability,user,targets,move,battle|
    next if !battle.futureSight
    next if !move.pbDamagingMove?
    next if user.item>0
    next if battle.wildBattle? && user.opposes?
    targets.each do |b|
      next if b.damageState.unaffected || b.damageState.substitute
      next if b.item==0
      next if b.unlosableItem?(b.item) || user.unlosableItem?(b.item)
      battle.pbShowAbilitySplash(user)
      if b.hasActiveAbility?(:STICKYHOLD)
        battle.pbShowAbilitySplash(b) if user.opposes?(b)
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          battle.pbDisplay(_INTL("{1}'s item cannot be stolen!",b.pbThis))
        end
        battle.pbHideAbilitySplash(b) if user.opposes?(b)
        next
      end
      user.item = b.item
      b.item = 0
      b.effects[PBEffects::Unburden] = true
      if battle.wildBattle? && user.initialItem==0 && b.initialItem==user.item
        user.setInitialItem(user.item)
        b.setInitialItem(0)
      end
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} stole {2}'s {3}!",user.pbThis,
           b.pbThis(true),user.itemName))
      else
        battle.pbDisplay(_INTL("{1} stole {2}'s {3} with {4}!",user.pbThis,
           b.pbThis(true),user.itemName,user.abilityName))
      end
      battle.pbHideAbilitySplash(user)
      user.pbHeldItemTriggerCheck
      break
    end
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:MOXIE,
  proc { |ability,user,targets,move,battle|
    next if battle.pbAllFainted?(user.idxOpposingSide)
    numFainted = 0
    targets.each { |b| numFainted += 1 if b.damageState.fainted }
    next if numFainted==0 || !user.pbCanRaiseStatStage?(PBStats::ATTACK,user)
    user.pbRaiseStatStageByAbility(PBStats::ATTACK,numFainted,user)
  }
)

#===============================================================================
# TargetAbilityAfterMoveUse handlers
#===============================================================================

BattleHandlers::TargetAbilityAfterMoveUse.add(:BERSERK,
  proc { |ability,target,user,move,switched,battle|
    next if !move.damagingMove?
    next if target.damageState.initialHP<target.totalhp/2 || target.hp>=target.totalhp/2
    next if !target.pbCanRaiseStatStage?(PBStats::SPATK,target)
    target.pbRaiseStatStageByAbility(PBStats::SPATK,1,target)
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:COLORCHANGE,
  proc { |ability,target,user,move,switched,battle|
    next if target.damageState.calcDamage==0 || target.damageState.substitute
    next if move.calcType<0 || PBTypes.isPseudoType?(move.calcType)
    next if target.pbHasType?(move.calcType) && !target.pbHasOtherType?(move.calcType)
    typeName = PBTypes.getName(move.calcType)
    battle.pbShowAbilitySplash(target)
    target.pbChangeTypes(move.calcType)
    battle.pbDisplay(_INTL("{1}'s {2} made it the {3} type!",target.pbThis,
       target.abilityName,typeName))
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:PICKPOCKET,
  proc { |ability,target,user,move,switched,battle|
    # NOTE: According to Bulbapedia, this can still trigger to steal the user's
    #       item even if it was switched out by a Red Card. This doesn't make
    #       sense, so this code doesn't do it.
    next if battle.wildBattle? && target.opposes?
    next if !move.contactMove?
    next if switched.include?(user.index)
    next if user.effects[PBEffects::Substitute]>0 || target.damageState.substitute
    next if target.item>0 || user.item==0
    next if user.unlosableItem?(user.item) || target.unlosableItem?(user.item)
    battle.pbShowAbilitySplash(target)
    if user.hasActiveAbility?(:STICKYHOLD)
      battle.pbShowAbilitySplash(user) if target.opposes?(user)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s item cannot be stolen!",user.pbThis))
      end
      battle.pbHideAbilitySplash(user) if target.opposes?(user)
      battle.pbHideAbilitySplash(target)
      next
    end
    target.item = user.item
    user.item = 0
    user.effects[PBEffects::Unburden] = true
    if battle.wildBattle? && target.initialItem==0 && user.initialItem==target.item
      target.setInitialItem(target.item)
      user.setInitialItem(0)
    end
    battle.pbDisplay(_INTL("{1} pickpocketed {2}'s {3}!",target.pbThis,
       user.pbThis(true),target.itemName))
    battle.pbHideAbilitySplash(target)
    target.pbHeldItemTriggerCheck
  }
)

#===============================================================================
# EORWeatherAbility handlers
#===============================================================================

BattleHandlers::EORWeatherAbility.add(:DRYSKIN,
  proc { |ability,weather,battler,battle|
    case weather
    when PBWeather::Sun, PBWeather::HarshSun
      battle.pbShowAbilitySplash(battler)
      battle.scene.pbDamageAnimation(battler)
      battler.pbReduceHP(battler.totalhp/8,false)
      battle.pbDisplay(_INTL("{1} was hurt by the sunlight!",battler.pbThis))
      battle.pbHideAbilitySplash(battler)
      battler.pbItemHPHealCheck
    when PBWeather::Rain, PBWeather::HeavyRain
      next if !battler.canHeal?
      battle.pbShowAbilitySplash(battler)
      battler.pbRecoverHP(battler.totalhp/8)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s {2} restored its HP.",battler.pbThis,battler.abilityName))
      end
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::EORWeatherAbility.add(:ICEBODY,
  proc { |ability,weather,battler,battle|
    next unless weather==PBWeather::Hail
    next if !battler.canHeal?
    battle.pbShowAbilitySplash(battler)
    battler.pbRecoverHP(battler.totalhp/16)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1}'s {2} restored its HP.",battler.pbThis,battler.abilityName))
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EORWeatherAbility.add(:RAINDISH,
  proc { |ability,weather,battler,battle|
    next unless weather==PBWeather::Rain || weather==PBWeather::HeavyRain
    next if !battler.canHeal?
    battle.pbShowAbilitySplash(battler)
    battler.pbRecoverHP(battler.totalhp/16)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1}'s {2} restored its HP.",battler.pbThis,battler.abilityName))
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EORWeatherAbility.add(:SOLARPOWER,
  proc { |ability,weather,battler,battle|
    next unless weather==PBWeather::Sun || weather==PBWeather::HarshSun
    battle.pbShowAbilitySplash(battler)
    battle.scene.pbDamageAnimation(battler)
    battler.pbReduceHP(battler.totalhp/8,false)
    battle.pbDisplay(_INTL("{1} was hurt by the sunlight!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
    battler.pbItemHPHealCheck
  }
)

#===============================================================================
# EORHealingAbility handlers
#===============================================================================

BattleHandlers::EORHealingAbility.add(:HEALER,
  proc { |ability,battler,battle|
    next unless battle.pbRandom(100)<30
    battler.eachAlly do |b|
      next if b.status==PBStatuses::NONE
      battle.pbShowAbilitySplash(battler)
      oldStatus = b.status
      b.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        case oldStatus
        when PBStatuses::SLEEP
          battle.pbDisplay(_INTL("{1}'s {2} woke its partner up!",battler.pbThis,battler.abilityName))
        when PBStatuses::POISON
          battle.pbDisplay(_INTL("{1}'s {2} cured its partner's poison!",battler.pbThis,battler.abilityName))
        when PBStatuses::BURN
          battle.pbDisplay(_INTL("{1}'s {2} healed its partner's burn!",battler.pbThis,battler.abilityName))
        when PBStatuses::PARALYSIS
          battle.pbDisplay(_INTL("{1}'s {2} cured its partner's paralysis!",battler.pbThis,battler.abilityName))
        when PBStatuses::FROZEN
          battle.pbDisplay(_INTL("{1}'s {2} defrosted its partner!",battler.pbThis,battler.abilityName))
        end
      end
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::EORHealingAbility.add(:HYDRATION,
  proc { |ability,battler,battle|
    next if battler.status==PBStatuses::NONE
    curWeather = battle.pbWeather
    next if curWeather!=PBWeather::Rain && curWeather!=PBWeather::HeavyRain
    battle.pbShowAbilitySplash(battler)
    oldStatus = battler.status
    battler.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      case oldStatus
      when PBStatuses::SLEEP
        battle.pbDisplay(_INTL("{1}'s {2} woke it up!",battler.pbThis,battler.abilityName))
      when PBStatuses::POISON
        battle.pbDisplay(_INTL("{1}'s {2} cured its poison!",battler.pbThis,battler.abilityName))
      when PBStatuses::BURN
        battle.pbDisplay(_INTL("{1}'s {2} healed its burn!",battler.pbThis,battler.abilityName))
      when PBStatuses::PARALYSIS
        battle.pbDisplay(_INTL("{1}'s {2} cured its paralysis!",battler.pbThis,battler.abilityName))
      when PBStatuses::FROZEN
        battle.pbDisplay(_INTL("{1}'s {2} defrosted it!",battler.pbThis,battler.abilityName))
      end
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EORHealingAbility.add(:SHEDSKIN,
  proc { |ability,battler,battle|
    next if battler.status==PBStatuses::NONE
    next unless battle.pbRandom(100)<30
    battle.pbShowAbilitySplash(battler)
    oldStatus = battler.status
    battler.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      case oldStatus
      when PBStatuses::SLEEP
        battle.pbDisplay(_INTL("{1}'s {2} woke it up!",battler.pbThis,battler.abilityName))
      when PBStatuses::POISON
        battle.pbDisplay(_INTL("{1}'s {2} cured its poison!",battler.pbThis,battler.abilityName))
      when PBStatuses::BURN
        battle.pbDisplay(_INTL("{1}'s {2} healed its burn!",battler.pbThis,battler.abilityName))
      when PBStatuses::PARALYSIS
        battle.pbDisplay(_INTL("{1}'s {2} cured its paralysis!",battler.pbThis,battler.abilityName))
      when PBStatuses::FROZEN
        battle.pbDisplay(_INTL("{1}'s {2} defrosted it!",battler.pbThis,battler.abilityName))
      end
    end
    battle.pbHideAbilitySplash(battler)
  }
)

#===============================================================================
# EOREffectAbility handlers
#===============================================================================

BattleHandlers::EOREffectAbility.add(:BADDREAMS,
  proc { |ability,battler,battle|
    battle.eachOtherSideBattler(battler.index) do |b|
      next if !b.near?(battler) || !b.asleep?
      battle.pbShowAbilitySplash(battler)
      next if !b.takesIndirectDamage?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      oldHP = b.hp
      b.pbReduceHP(b.totalhp/8)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} is tormented!",b.pbThis))
      else
        battle.pbDisplay(_INTL("{1} is tormented by {2}'s {3}!",b.pbThis,
           battler.pbThis(true),battler.abilityName))
      end
      battle.pbHideAbilitySplash(battler)
      b.pbItemHPHealCheck
      b.pbAbilitiesOnDamageTaken(oldHP)
      b.pbFaint if b.fainted?
    end
  }
)

BattleHandlers::EOREffectAbility.add(:MOODY,
  proc { |ability,battler,battle|
    randomUp = []; randomDown = []
    PBStats.eachBattleStat do |s|
      randomUp.push(s) if battler.pbCanRaiseStatStage?(s,battler)
      randomDown.push(s) if battler.pbCanLowerStatStage?(s,battler)
    end
    next if randomUp.length==0 && randomDown.length==0
    battle.pbShowAbilitySplash(battler)
    if randomUp.length>0
      r = battle.pbRandom(randomUp.length)
      battler.pbRaiseStatStageByAbility(randomUp[r],2,battler,false)
      randomDown.delete(randomUp[r])
    end
    if randomDown.length>0
      r = battle.pbRandom(randomDown.length)
      battler.pbLowerStatStageByAbility(randomDown[r],1,battler,false)
    end
    battle.pbHideAbilitySplash(battler)
    battler.pbItemStatRestoreCheck if randomDown.length>0
  }
)

BattleHandlers::EOREffectAbility.add(:SPEEDBOOST,
  proc { |ability,battler,battle|
    # A Pokémon's turnCount is 0 if it became active after the beginning of a
    # round
    if battler.turnCount>0 && battler.pbCanRaiseStatStage?(PBStats::SPEED,battler)
      battler.pbRaiseStatStageByAbility(PBStats::SPEED,1,battler)
    end
  }
)

BattleHandlers::EOREffectAbility.add(:BALLFETCH,
  proc { |ability,battler,battle|
    if battler.item == 0 && battler.effects[PBEffects::BallFetch]==0 && $BallRetrieved != 0
      battle.pbShowAbilitySplash(battler)
      battler.effects[PBEffects::BallFetch]=1
      battler.item = $BallRetrieved
      battler.setInitialItem($BallRetrieved)
      $BallRetrieved = 0
      battler.battle.pbDisplay(_INTL("{1}'s {2} fetched the {3}!",battler.pbThis,battler.abilityName,battler.itemName))
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::EOREffectAbility.add(:HUNGERSWITCH,
  proc { |ability,battler,battle|
    if isConst?(battler.species,PBSpecies,:MORPEKO)
      battle.pbShowAbilitySplash(battler)
      battler.form=(battler.form==0) ? 1 : 0
      battler.pbUpdate(true)
      battle.scene.pbChangePokemon(battler,battler.pokemon)
      battle.pbDisplay(_INTL("{1} transformed!",battler.pbThis))
      battle.pbHideAbilitySplash(battler)
    end
  }
)

#===============================================================================
# EORGainItemAbility handlers
#===============================================================================

BattleHandlers::EORGainItemAbility.add(:HARVEST,
  proc { |ability,battler,battle|
    next if battler.item>0
    next if battler.recycleItem<=0 || !pbIsBerry?(battler.recycleItem)
    curWeather = battle.pbWeather
    if curWeather!=PBWeather::Sun && curWeather!=PBWeather::HarshSun
      next unless battle.pbRandom(100)<50
    end
    battle.pbShowAbilitySplash(battler)
    battler.item = battler.recycleItem
    battler.setRecycleItem(0)
    battler.setInitialItem(battler.item) if battler.initialItem==0
    battle.pbDisplay(_INTL("{1} harvested one {2}!",battler.pbThis,battler.itemName))
    battle.pbHideAbilitySplash(battler)
    battler.pbHeldItemTriggerCheck
  }
)

BattleHandlers::EORGainItemAbility.add(:PICKUP,
  proc { |ability,battler,battle|
    next if battler.item>0
    foundItem = 0; fromBattler = nil; use = 0
    battle.eachBattler do |b|
      next if b.index==battler.index
      next if b.effects[PBEffects::PickupUse]<=use
      foundItem   = b.effects[PBEffects::PickupItem]
      fromBattler = b
      use         = b.effects[PBEffects::PickupUse]
    end
    next if foundItem<=0
    battle.pbShowAbilitySplash(battler)
    battler.item = foundItem
    fromBattler.effects[PBEffects::PickupItem] = 0
    fromBattler.effects[PBEffects::PickupUse]  = 0
    fromBattler.setRecycleItem(0) if fromBattler.recycleItem==foundItem
    if battle.wildBattle? && battler.initialItem==0 && fromBattler.initialItem==foundItem
      battler.setInitialItem(foundItem)
      fromBattler.setInitialItem(0)
    end
    battle.pbDisplay(_INTL("{1} found one {2}!",battler.pbThis,battler.itemName))
    battle.pbHideAbilitySplash(battler)
    battler.pbHeldItemTriggerCheck
  }
)

#===============================================================================
# CertainSwitchingUserAbility handlers
#===============================================================================

# There aren't any!

#===============================================================================
# TrappingTargetAbility handlers
#===============================================================================

BattleHandlers::TrappingTargetAbility.add(:ARENATRAP,
  proc { |ability,switcher,bearer,battle|
    next true if !switcher.airborne?
  }
)

BattleHandlers::TrappingTargetAbility.add(:MAGNETPULL,
  proc { |ability,switcher,bearer,battle|
    next true if switcher.pbHasType?(:STEEL)
  }
)

BattleHandlers::TrappingTargetAbility.add(:SHADOWTAG,
  proc { |ability,switcher,bearer,battle|
    next true if !switcher.hasActiveAbility?(:SHADOWTAG)
  }
)

#===============================================================================
# AbilityOnSwitchIn handlers
#===============================================================================

BattleHandlers::AbilityOnSwitchIn.add(:AIRLOCK,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1} has {2}!",battler.pbThis,battler.abilityName))
    end
    battle.pbDisplay(_INTL("The effects of the weather disappeared."))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.copy(:AIRLOCK,:CLOUDNINE)

BattleHandlers::AbilityOnSwitchIn.add(:ANTICIPATION,
  proc { |ability,battler,battle|
    next if !battler.pbOwnedByPlayer?
    battlerTypes = battler.pbTypes(true)
    type1 = (battlerTypes.length>0) ? battlerTypes[0] : nil
    type2 = (battlerTypes.length>1) ? battlerTypes[1] : type1
    type3 = (battlerTypes.length>2) ? battlerTypes[2] : type2
    found = false
    battle.eachOtherSideBattler(battler.index) do |b|
      b.eachMove do |m|
        next if m.statusMove?
        moveData = pbGetMoveData(m.id)
        if type1
          moveType = moveData[MOVE_TYPE]
          if NEWEST_BATTLE_MECHANICS && isConst?(m.id,PBMoves,:HIDDENPOWER)
            moveType = pbHiddenPower(b.pokemon)[0]
          end
          eff = PBTypes.getCombinedEffectiveness(moveType,type1,type2,type3)
          next if PBTypes.ineffective?(eff)
          next if !PBTypes.superEffective?(eff) && moveData[MOVE_FUNCTION_CODE]!="070"   # OHKO
        else
          next if moveData[MOVE_FUNCTION_CODE]!="070"   # OHKO
        end
        found = true
        break
      end
      break if found
    end
    if found
      battle.pbShowAbilitySplash(battler)
      battle.pbDisplay(_INTL("{1} shuddered with anticipation!",battler.pbThis))
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:AURABREAK,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} reversed all other Pokémon's auras!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:COMATOSE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is drowsing!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DARKAURA,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is radiating a dark aura!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DELTASTREAM,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(PBWeather::StrongWinds,battler,battle,true)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DESOLATELAND,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(PBWeather::HarshSun,battler,battle,true)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DOWNLOAD,
  proc { |ability,battler,battle|
    oDef = oSpDef = 0
    battle.eachOtherSideBattler(battler.index) do |b|
      oDef   += b.defense
      oSpDef += b.spdef
    end
    stat = (oDef<oSpDef) ? PBStats::ATTACK : PBStats::SPATK
    battler.pbRaiseStatStageByAbility(stat,1,battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DRIZZLE,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(PBWeather::Rain,battler,battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DROUGHT,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(PBWeather::Sun,battler,battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:ELECTRICSURGE,
  proc { |ability,battler,battle|
    next if battle.field.terrain==PBBattleTerrains::Electric
    battle.pbShowAbilitySplash(battler)
    battle.pbStartTerrain(battler,PBBattleTerrains::Electric)
    # NOTE: The ability splash is hidden again in def pbStartTerrain.
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:FAIRYAURA,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is radiating a fairy aura!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:FOREWARN,
  proc { |ability,battler,battle|
    next if !battler.pbOwnedByPlayer?
    highestPower = 0
    forewarnMoves = []
    battle.eachOtherSideBattler(battler.index) do |b|
      b.eachMove do |m|
        moveData = pbGetMoveData(m.id)
        power = moveData[MOVE_BASE_DAMAGE]
        power = 160 if ["070"].include?(moveData[MOVE_FUNCTION_CODE])    # OHKO
        power = 150 if ["08B"].include?(moveData[MOVE_FUNCTION_CODE])    # Eruption
        # Counter, Mirror Coat, Metal Burst
        power = 120 if ["071","072","073"].include?(moveData[MOVE_FUNCTION_CODE])
        # Sonic Boom, Dragon Rage, Night Shade, Endeavor, Psywave,
        # Return, Frustration, Crush Grip, Gyro Ball, Hidden Power,
        # Natural Gift, Trump Card, Flail, Grass Knot
        power = 80 if ["06A","06B","06D","06E","06F",
                       "089","08A","08C","08D","090",
                       "096","097","098","09A"].include?(moveData[MOVE_FUNCTION_CODE])
        next if power<highestPower
        forewarnMoves = [] if power>highestPower
        forewarnMoves.push(m.id)
        highestPower = power
      end
    end
    if forewarnMoves.length>0
      battle.pbShowAbilitySplash(battler)
      forewarnMoveID = forewarnMoves[battle.pbRandom(forewarnMoves.length)]
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} was alerted to {2}!",
          battler.pbThis,PBMoves.getName(forewarnMoveID)))
      else
        battle.pbDisplay(_INTL("{1}'s Forewarn alerted it to {2}!",
          battler.pbThis,PBMoves.getName(forewarnMoveID)))
      end
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:FRISK,
  proc { |ability,battler,battle|
    next if !battler.pbOwnedByPlayer?
    foes = []
    battle.eachOtherSideBattler(battler.index) do |b|
      foes.push(b) if b.item>0
    end
    if foes.length>0
      battle.pbShowAbilitySplash(battler)
      if NEWEST_BATTLE_MECHANICS
        foes.each do |b|
          battle.pbDisplay(_INTL("{1} frisked {2} and found its {3}!",
             battler.pbThis,b.pbThis(true),PBItems.getName(b.item)))
        end
      else
        foe = foes[battle.pbRandom(foes.length)]
        battle.pbDisplay(_INTL("{1} frisked the foe and found one {2}!",
           battler.pbThis,PBItems.getName(foe.item)))
      end
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:GRASSYSURGE,
  proc { |ability,battler,battle|
    next if battle.field.terrain==PBBattleTerrains::Grassy
    battle.pbShowAbilitySplash(battler)
    battle.pbStartTerrain(battler,PBBattleTerrains::Grassy)
    # NOTE: The ability splash is hidden again in def pbStartTerrain.
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:IMPOSTER,
  proc { |ability,battler,battle|
    next if battler.effects[PBEffects::Transform]
    choice = battler.pbDirectOpposing
    next if choice.fainted?
    next if choice.effects[PBEffects::Transform] ||
            choice.effects[PBEffects::Illusion] ||
            choice.effects[PBEffects::Substitute]>0 ||
            choice.effects[PBEffects::SkyDrop]>=0 ||
            choice.semiInvulnerable?
    battle.pbShowAbilitySplash(battler,true)
    battle.pbHideAbilitySplash(battler)
    battle.pbAnimation(getConst(PBMoves,:TRANSFORM),battler,choice)
    battle.scene.pbChangePokemon(battler,choice.pokemon)
    battler.pbTransform(choice)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:INTIMIDATE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.eachOtherSideBattler(battler.index) do |b|
      next if !b.near?(battler)
      b.pbLowerAttackStatStageIntimidate(battler)
      b.pbItemOnIntimidatedCheck
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:MISTYSURGE,
  proc { |ability,battler,battle|
    next if battle.field.terrain==PBBattleTerrains::Misty
    battle.pbShowAbilitySplash(battler)
    battle.pbStartTerrain(battler,PBBattleTerrains::Misty)
    # NOTE: The ability splash is hidden again in def pbStartTerrain.
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:MOLDBREAKER,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} breaks the mold!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:PRESSURE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is exerting its pressure!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:PRIMORDIALSEA,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(PBWeather::HeavyRain,battler,battle,true)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:PSYCHICSURGE,
  proc { |ability,battler,battle|
    next if battle.field.terrain==PBBattleTerrains::Psychic
    battle.pbShowAbilitySplash(battler)
    battle.pbStartTerrain(battler,PBBattleTerrains::Psychic)
    # NOTE: The ability splash is hidden again in def pbStartTerrain.
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:SANDSTREAM,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(PBWeather::Sandstorm,battler,battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:SLOWSTART,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battler.effects[PBEffects::SlowStart] = 5
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1} can't get it going!",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1} can't get it going because of its {2}!",
         battler.pbThis,battler.abilityName))
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:SNOWWARNING,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(PBWeather::Hail,battler,battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:TERAVOLT,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is radiating a bursting aura!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:TURBOBLAZE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is radiating a blazing aura!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:UNNERVE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is too nervous to eat Berries!",battler.pbOpposingTeam))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:INTREPIDSWORD,
  proc { |ability,battler,battle|
    stat = PBStats::ATTACK
    battler.pbRaiseStatStageByAbility(stat,1,battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DAUNTLESSSHIELD,
  proc { |ability,battler,battle|
    stat = PBStats::DEFENSE
    battler.pbRaiseStatStageByAbility(stat,1,battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:SCREENCLEANER,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    for side in 0...2
      if battle.sides[side].effects[PBEffects::LightScreen]>0
        battle.sides[side].effects[PBEffects::LightScreen] = 0
        battle.pbDisplay(_INTL("{1}'s Light Screen wore off!",@battlers[side].pbTeam))
      end
      if battle.sides[side].effects[PBEffects::Reflect]>0
        battle.sides[side].effects[PBEffects::Reflect] = 0
        battle.pbDisplay(_INTL("{1}'s Reflect wore off!",@battlers[side].pbOpposingTeam))
      end
      if battle.sides[side].effects[PBEffects::AuroraVeil]>0
        battle.sides[side].effects[PBEffects::AuroraVeil] = 0
        battle.pbDisplay(_INTL("{1}'s Aurora Veil wore off!",@battlers[side].pbOpposingTeam))
      end
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:PASTELVEIL,
  proc { |ability,battler,battle|
    battler.eachAlly do |b|
      next if b.status != PBStatuses::POISON
      battle.pbShowAbilitySplash(battler)
      b.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s {2} cured its {3}'s poison!",battler.pbThis,battler.abilityName,b.pbThis(true)))
      end
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:NEUTRALIZINGGAS,
  proc { |ability,battler,battle|
    next if battle.field.effects[PBEffects::NeutralizingGas]
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1}'s gas nullified all abilities!",pbThis))
    battle.field.effects[PBEffects::NeutralizingGas] = true
    battle.pbHideAbilitySplash(battler)
  }
)
#===============================================================================
# AbilityOnSwitchOut handlers
#===============================================================================

BattleHandlers::AbilityOnSwitchOut.add(:NATURALCURE,
  proc { |ability,battler,endOfBattle|
    PBDebug.log("[Ability triggered] #{battler.pbThis}'s #{battler.abilityName}")
    battler.status = PBStatuses::NONE
  }
)

BattleHandlers::AbilityOnSwitchOut.add(:REGENERATOR,
  proc { |ability,battler,endOfBattle|
    next if !endOfBattle
    PBDebug.log("[Ability triggered] #{battler.pbThis}'s #{battler.abilityName}")
    battler.pbRecoverHP(battler.totalhp/3,false,false)
  }
)

#===============================================================================
# AbilityChangeOnBattlerFainting handlers
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
       :ICEFACE,
       # Appearance-changing abilities
       :ILLUSION,
       :IMPOSTER,
       # Abilities intended to be inherent properties of a certain species
       :COMATOSE,
       :RKSSYSTEM,
       :GULPMISSILE,
       # Abilities that would be overpowered if allowed to be transferred
       :WONDERGUARD,
       # Abilities that are plain old blocked.
       :NEUTRALIZINGGAS
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

#===============================================================================
# AbilityOnBattlerFainting handlers
#===============================================================================

BattleHandlers::AbilityOnBattlerFainting.add(:SOULHEART,
  proc { |ability,battler,fainted,battle|
    battler.pbRaiseStatStageByAbility(PBStats::SPATK,1,battler)
  }
)

#===============================================================================
# RunFromBattleAbility handlers
#===============================================================================

BattleHandlers::RunFromBattleAbility.add(:RUNAWAY,
  proc { |ability,battler|
    next true
  }
)
