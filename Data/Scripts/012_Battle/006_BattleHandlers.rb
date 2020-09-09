module BattleHandlers
  # Battler's speed calculation
  SpeedCalcAbility                    = AbilityHandlerHash.new
  SpeedCalcItem                       = ItemHandlerHash.new
  # Battler's weight calculation
  WeightCalcAbility                   = AbilityHandlerHash.new
  WeightCalcItem                      = ItemHandlerHash.new   # Float Stone
  # Battler's HP changed
  HPHealItem                          = ItemHandlerHash.new
  AbilityOnHPDroppedBelowHalf         = AbilityHandlerHash.new
  # Battler's status problem
  StatusCheckAbilityNonIgnorable      = AbilityHandlerHash.new   # Comatose
  StatusImmunityAbility               = AbilityHandlerHash.new
  StatusImmunityAbilityNonIgnorable   = AbilityHandlerHash.new
  StatusImmunityAllyAbility           = AbilityHandlerHash.new
  AbilityOnStatusInflicted            = AbilityHandlerHash.new   # Synchronize
  StatusCureItem                      = ItemHandlerHash.new
  StatusCureAbility                   = AbilityHandlerHash.new
  # Battler's stat stages
  StatLossImmunityAbility             = AbilityHandlerHash.new
  StatLossImmunityAbilityNonIgnorable = AbilityHandlerHash.new   # Full Metal Body
  StatLossImmunityAllyAbility         = AbilityHandlerHash.new   # Flower Veil
  AbilityOnStatGain                   = AbilityHandlerHash.new   # None!
  AbilityOnStatLoss                   = AbilityHandlerHash.new
  # Priority and turn order
  PriorityChangeAbility               = AbilityHandlerHash.new
  PriorityBracketChangeAbility        = AbilityHandlerHash.new   # Stall
  PriorityBracketChangeItem           = ItemHandlerHash.new
  PriorityBracketUseAbility           = AbilityHandlerHash.new   # None!
  PriorityBracketUseItem              = ItemHandlerHash.new
  # Move usage failures
  AbilityOnFlinch                     = AbilityHandlerHash.new   # Steadfast
  MoveBlockingAbility                 = AbilityHandlerHash.new
  MoveImmunityTargetAbility           = AbilityHandlerHash.new
  # Move usage
  MoveBaseTypeModifierAbility         = AbilityHandlerHash.new
  # Accuracy calculation
  AccuracyCalcUserAbility             = AbilityHandlerHash.new
  AccuracyCalcUserAllyAbility         = AbilityHandlerHash.new   # Victory Star
  AccuracyCalcTargetAbility           = AbilityHandlerHash.new
  AccuracyCalcUserItem                = ItemHandlerHash.new
  AccuracyCalcTargetItem              = ItemHandlerHash.new
  # Damage calculation
  DamageCalcUserAbility               = AbilityHandlerHash.new
  DamageCalcUserAllyAbility           = AbilityHandlerHash.new
  DamageCalcTargetAbility             = AbilityHandlerHash.new
  DamageCalcTargetAbilityNonIgnorable = AbilityHandlerHash.new
  DamageCalcTargetAllyAbility         = AbilityHandlerHash.new
  DamageCalcUserItem                  = ItemHandlerHash.new
  DamageCalcTargetItem                = ItemHandlerHash.new
  # Critical hit calculation
  CriticalCalcUserAbility             = AbilityHandlerHash.new
  CriticalCalcTargetAbility           = AbilityHandlerHash.new
  CriticalCalcUserItem                = ItemHandlerHash.new
  CriticalCalcTargetItem              = ItemHandlerHash.new   # None!
  # Upon a move hitting a target
  TargetAbilityOnHit                  = AbilityHandlerHash.new
  UserAbilityOnHit                    = AbilityHandlerHash.new   # Poison Touch
  TargetItemOnHit                     = ItemHandlerHash.new
  TargetItemOnHitPositiveBerry        = ItemHandlerHash.new
  # Abilities/items that trigger at the end of using a move
  UserAbilityEndOfMove                = AbilityHandlerHash.new
  TargetItemAfterMoveUse              = ItemHandlerHash.new
  UserItemAfterMoveUse                = ItemHandlerHash.new
  TargetAbilityAfterMoveUse           = AbilityHandlerHash.new
  EndOfMoveItem                       = ItemHandlerHash.new   # Leppa Berry
  EndOfMoveStatRestoreItem            = ItemHandlerHash.new   # White Herb
  # Experience and EV gain
  ExpGainModifierItem                 = ItemHandlerHash.new   # Lucky Egg
  EVGainModifierItem                  = ItemHandlerHash.new
  # Weather and terrin
  WeatherExtenderItem                 = ItemHandlerHash.new
  TerrainExtenderItem                 = ItemHandlerHash.new   # Terrain Extender
  TerrainStatBoostItem                = ItemHandlerHash.new
  # End Of Round
  EORWeatherAbility                   = AbilityHandlerHash.new
  EORHealingAbility                   = AbilityHandlerHash.new
  EORHealingItem                      = ItemHandlerHash.new
  EOREffectAbility                    = AbilityHandlerHash.new
  EOREffectItem                       = ItemHandlerHash.new
  EORGainItemAbility                  = AbilityHandlerHash.new
  # Switching and fainting
  CertainSwitchingUserAbility         = AbilityHandlerHash.new   # None!
  CertainSwitchingUserItem            = ItemHandlerHash.new   # Shed Shell
  TrappingTargetAbility               = AbilityHandlerHash.new
  TrappingTargetItem                  = ItemHandlerHash.new   # None!
  AbilityOnSwitchIn                   = AbilityHandlerHash.new
  ItemOnSwitchIn                      = ItemHandlerHash.new   # Air Balloon
  ItemOnIntimidated                   = ItemHandlerHash.new   # Adrenaline Orb
  AbilityOnSwitchOut                  = AbilityHandlerHash.new
  AbilityChangeOnBattlerFainting      = AbilityHandlerHash.new
  AbilityOnBattlerFainting            = AbilityHandlerHash.new   # Soul-Heart
  # Running from battle
  RunFromBattleAbility                = AbilityHandlerHash.new   # Run Away
  RunFromBattleItem                   = ItemHandlerHash.new   # Smoke Ball

  #=============================================================================

  def self.triggerSpeedCalcAbility(ability,battler,mult)
    ret = SpeedCalcAbility.trigger(ability,battler,mult)
    return (ret!=nil) ? ret : mult
  end

  def self.triggerSpeedCalcItem(item,battler,mult)
    ret = SpeedCalcItem.trigger(item,battler,mult)
    return (ret!=nil) ? ret : mult
  end

  #=============================================================================

  def self.triggerWeightCalcAbility(ability,battler,w)
    ret = WeightCalcAbility.trigger(ability,battler,w)
    return (ret!=nil) ? ret : w
  end

  def self.triggerWeightCalcItem(item,battler,w)
    ret = WeightCalcItem.trigger(item,battler,w)
    return (ret!=nil) ? ret : w
  end

  #=============================================================================

  def self.triggerHPHealItem(item,battler,battle,forced)
    ret = HPHealItem.trigger(item,battler,battle,forced)
    return (ret!=nil) ? ret : false
  end

  def self.triggerAbilityOnHPDroppedBelowHalf(ability,user,battle)
    ret = AbilityOnHPDroppedBelowHalf.trigger(ability,user,battle)
    return (ret!=nil) ? ret : false
  end

  #=============================================================================

  def self.triggerStatusCheckAbilityNonIgnorable(ability,battler,status)
    ret = StatusCheckAbilityNonIgnorable.trigger(ability,battler,status)
    return (ret!=nil) ? ret : false
  end

  def self.triggerStatusImmunityAbility(ability,battler,status)
    ret = StatusImmunityAbility.trigger(ability,battler,status)
    return (ret!=nil) ? ret : false
  end

  def self.triggerStatusImmunityAbilityNonIgnorable(ability,battler,status)
    ret = StatusImmunityAbilityNonIgnorable.trigger(ability,battler,status)
    return (ret!=nil) ? ret : false
  end

  def self.triggerStatusImmunityAllyAbility(ability,battler,status)
    ret = StatusImmunityAllyAbility.trigger(ability,battler,status)
    return (ret!=nil) ? ret : false
  end

  def self.triggerAbilityOnStatusInflicted(ability,battler,user,status)
    AbilityOnStatusInflicted.trigger(ability,battler,user,status)
  end

  def self.triggerStatusCureItem(item,battler,battle,forced)
    ret = StatusCureItem.trigger(item,battler,battle,forced)
    return (ret!=nil) ? ret : false
  end

  def self.triggerStatusCureAbility(ability,battler)
    ret = StatusCureAbility.trigger(ability,battler)
    return (ret!=nil) ? ret : false
  end

  #=============================================================================

  def self.triggerStatLossImmunityAbility(ability,battler,stat,battle,showMessages)
    ret = StatLossImmunityAbility.trigger(ability,battler,stat,battle,showMessages)
    return (ret!=nil) ? ret : false
  end

  def self.triggerStatLossImmunityAbilityNonIgnorable(ability,battler,stat,battle,showMessages)
    ret = StatLossImmunityAbilityNonIgnorable.trigger(ability,battler,stat,battle,showMessages)
    return (ret!=nil) ? ret : false
  end

  def self.triggerStatLossImmunityAllyAbility(ability,bearer,battler,stat,battle,showMessages)
    ret = StatLossImmunityAllyAbility.trigger(ability,bearer,battler,stat,battle,showMessages)
    return (ret!=nil) ? ret : false
  end

  def self.triggerAbilityOnStatGain(ability,battler,stat,user)
    AbilityOnStatGain.trigger(ability,battler,stat,user)
  end

  def self.triggerAbilityOnStatLoss(ability,battler,stat,user)
    AbilityOnStatLoss.trigger(ability,battler,stat,user)
  end

  #=============================================================================

  def self.triggerPriorityChangeAbility(ability,battler,move,pri)
    ret = PriorityChangeAbility.trigger(ability,battler,move,pri)
    return (ret!=nil) ? ret : pri
  end

  def self.triggerPriorityBracketChangeAbility(ability,battler,subPri,battle)
    ret = PriorityBracketChangeAbility.trigger(ability,battler,subPri,battle)
    return (ret!=nil) ? ret : subPri
  end

  def self.triggerPriorityBracketChangeItem(item,battler,subPri,battle)
    ret = PriorityBracketChangeItem.trigger(item,battler,subPri,battle)
    return (ret!=nil) ? ret : subPri
  end

  def self.triggerPriorityBracketUseAbility(ability,battler,battle)
    PriorityBracketUseAbility.trigger(ability,battler,battle)
  end

  def self.triggerPriorityBracketUseItem(item,battler,battle)
    PriorityBracketUseItem.trigger(item,battler,battle)
  end

  #=============================================================================

  def self.triggerAbilityOnFlinch(ability,battler,battle)
    AbilityOnFlinch.trigger(ability,battler,battle)
  end

  def self.triggerMoveBlockingAbility(ability,bearer,user,targets,move,battle)
    ret = MoveBlockingAbility.trigger(ability,bearer,user,targets,move,battle)
    return (ret!=nil) ? ret : false
  end

  def self.triggerMoveImmunityTargetAbility(ability,user,target,move,type,battle)
    ret = MoveImmunityTargetAbility.trigger(ability,user,target,move,type,battle)
    return (ret!=nil) ? ret : false
  end

  #=============================================================================

  def self.triggerMoveBaseTypeModifierAbility(ability,user,move,type)
    ret = MoveBaseTypeModifierAbility.trigger(ability,user,move,type)
    return (ret!=nil) ? ret : type
  end

  #=============================================================================

  def self.triggerAccuracyCalcUserAbility(ability,mods,user,target,move,type)
    AccuracyCalcUserAbility.trigger(ability,mods,user,target,move,type)
  end

  def self.triggerAccuracyCalcUserAllyAbility(ability,mods,user,target,move,type)
    AccuracyCalcUserAllyAbility.trigger(ability,mods,user,target,move,type)
  end

  def self.triggerAccuracyCalcTargetAbility(ability,mods,user,target,move,type)
    AccuracyCalcTargetAbility.trigger(ability,mods,user,target,move,type)
  end

  def self.triggerAccuracyCalcUserItem(item,mods,user,target,move,type)
    AccuracyCalcUserItem.trigger(item,mods,user,target,move,type)
  end

  def self.triggerAccuracyCalcTargetItem(item,mods,user,target,move,type)
    AccuracyCalcTargetItem.trigger(item,mods,user,target,move,type)
  end

  #=============================================================================

  def self.triggerDamageCalcUserAbility(ability,user,target,move,mults,baseDmg,type)
    DamageCalcUserAbility.trigger(ability,user,target,move,mults,baseDmg,type)
  end

  def self.triggerDamageCalcUserAllyAbility(ability,user,target,move,mults,baseDmg,type)
    DamageCalcUserAllyAbility.trigger(ability,user,target,move,mults,baseDmg,type)
  end

  def self.triggerDamageCalcTargetAbility(ability,user,target,move,mults,baseDmg,type)
    DamageCalcTargetAbility.trigger(ability,user,target,move,mults,baseDmg,type)
  end

  def self.triggerDamageCalcTargetAbilityNonIgnorable(ability,user,target,move,mults,baseDmg,type)
    DamageCalcTargetAbilityNonIgnorable.trigger(ability,user,target,move,mults,baseDmg,type)
  end

  def self.triggerDamageCalcTargetAllyAbility(ability,user,target,move,mults,baseDmg,type)
    DamageCalcTargetAllyAbility.trigger(ability,user,target,move,mults,baseDmg,type)
  end

  def self.triggerDamageCalcUserItem(item,user,target,move,mults,baseDmg,type)
    DamageCalcUserItem.trigger(item,user,target,move,mults,baseDmg,type)
  end

  def self.triggerDamageCalcTargetItem(item,user,target,move,mults,baseDmg,type)
    DamageCalcTargetItem.trigger(item,user,target,move,mults,baseDmg,type)
  end

  #=============================================================================

  def self.triggerCriticalCalcUserAbility(ability,user,target,c)
    ret = CriticalCalcUserAbility.trigger(ability,user,target,c)
    return (ret!=nil) ? ret : c
  end

  def self.triggerCriticalCalcTargetAbility(ability,user,target,c)
    ret = CriticalCalcTargetAbility.trigger(ability,user,target,c)
    return (ret!=nil) ? ret : c
  end

  def self.triggerCriticalCalcUserItem(item,user,target,c)
    ret = CriticalCalcUserItem.trigger(item,user,target,c)
    return (ret!=nil) ? ret : c
  end

  def self.triggerCriticalCalcTargetItem(item,user,target,c)
    ret = CriticalCalcTargetItem.trigger(item,user,target,c)
    return (ret!=nil) ? ret : c
  end

  #=============================================================================

  def self.triggerTargetAbilityOnHit(ability,user,target,move,battle)
    TargetAbilityOnHit.trigger(ability,user,target,move,battle)
  end

  def self.triggerUserAbilityOnHit(ability,user,target,move,battle)
    UserAbilityOnHit.trigger(ability,user,target,move,battle)
  end

  def self.triggerTargetItemOnHit(item,user,target,move,battle)
    TargetItemOnHit.trigger(item,user,target,move,battle)
  end

  def self.triggerTargetItemOnHitPositiveBerry(item,battler,battle,forced)
    ret = TargetItemOnHitPositiveBerry.trigger(item,battler,battle,forced)
    return (ret!=nil) ? ret : false
  end

  #=============================================================================

  def self.triggerUserAbilityEndOfMove(ability,user,targets,move,battle)
    UserAbilityEndOfMove.trigger(ability,user,targets,move,battle)
  end

  def self.triggerTargetItemAfterMoveUse(item,battler,user,move,switched,battle)
    TargetItemAfterMoveUse.trigger(item,battler,user,move,switched,battle)
  end

  def self.triggerUserItemAfterMoveUse(item,user,targets,move,numHits,battle)
    UserItemAfterMoveUse.trigger(item,user,targets,move,numHits,battle)
  end

  def self.triggerTargetAbilityAfterMoveUse(ability,target,user,move,switched,battle)
    TargetAbilityAfterMoveUse.trigger(ability,target,user,move,switched,battle)
  end

  def self.triggerEndOfMoveItem(item,battler,battle,forced)
    ret = EndOfMoveItem.trigger(item,battler,battle,forced)
    return (ret!=nil) ? ret : false
  end

  def self.triggerEndOfMoveStatRestoreItem(item,battler,battle,forced)
    ret = EndOfMoveStatRestoreItem.trigger(item,battler,battle,forced)
    return (ret!=nil) ? ret : false
  end

  #=============================================================================

  def self.triggerExpGainModifierItem(item,battler,exp)
    ret = ExpGainModifierItem.trigger(item,battler,exp)
    return (ret!=nil) ? ret : -1
  end

  def self.triggerEVGainModifierItem(item,battler,evarray)
    return false if !EVGainModifierItem[item]
    EVGainModifierItem.trigger(item,battler,evarray)
    return true
  end

  #=============================================================================

  def self.triggerWeatherExtenderItem(item,weather,duration,battler,battle)
    ret = WeatherExtenderItem.trigger(item,weather,duration,battler,battle)
    return (ret!=nil) ? ret : duration
  end

  def self.triggerTerrainExtenderItem(item,terrain,duration,battler,battle)
    ret = TerrainExtenderItem.trigger(item,terrain,duration,battler,battle)
    return (ret!=nil) ? ret : duration
  end

  def self.triggerTerrainStatBoostItem(item,battler,battle)
    ret = TerrainStatBoostItem.trigger(item,battler,battle)
    return (ret!=nil) ? ret : false
  end

  #=============================================================================

  def self.triggerEORWeatherAbility(ability,weather,battler,battle)
    EORWeatherAbility.trigger(ability,weather,battler,battle)
  end

  def self.triggerEORHealingAbility(ability,battler,battle)
    EORHealingAbility.trigger(ability,battler,battle)
  end

  def self.triggerEORHealingItem(item,battler,battle)
    EORHealingItem.trigger(item,battler,battle)
  end

  def self.triggerEOREffectAbility(ability,battler,battle)
    EOREffectAbility.trigger(ability,battler,battle)
  end

  def self.triggerEOREffectItem(item,battler,battle)
    EOREffectItem.trigger(item,battler,battle)
  end

  def self.triggerEORGainItemAbility(ability,battler,battle)
    EORGainItemAbility.trigger(ability,battler,battle)
  end

  #=============================================================================

  def self.triggerCertainSwitchingUserAbility(ability,switcher,battle)
    ret = CertainSwitchingUserAbility.trigger(ability,switcher,battle)
    return (ret!=nil) ? ret : false
  end

  def self.triggerCertainSwitchingUserItem(item,switcher,battle)
    ret = CertainSwitchingUserItem.trigger(item,switcher,battle)
    return (ret!=nil) ? ret : false
  end

  def self.triggerTrappingTargetAbility(ability,switcher,bearer,battle)
    ret = TrappingTargetAbility.trigger(ability,switcher,bearer,battle)
    return (ret!=nil) ? ret : false
  end

  def self.triggerTrappingTargetItem(item,switcher,bearer,battle)
    ret = TrappingTargetItem.trigger(item,switcher,bearer,battle)
    return (ret!=nil) ? ret : false
  end

  def self.triggerAbilityOnSwitchIn(ability,battler,battle)
    AbilityOnSwitchIn.trigger(ability,battler,battle)
  end

  def self.triggerItemOnSwitchIn(item,battler,battle)
    ItemOnSwitchIn.trigger(item,battler,battle)
  end

  def self.triggerItemOnIntimidated(item,battler,battle)
    ret = ItemOnIntimidated.trigger(item,battler,battle)
    return (ret!=nil) ? ret : false
  end

  def self.triggerAbilityOnSwitchOut(ability,battler,endOfBattle)
    AbilityOnSwitchOut.trigger(ability,battler,endOfBattle)
  end

  def self.triggerAbilityChangeOnBattlerFainting(ability,battler,fainted,battle)
    AbilityChangeOnBattlerFainting.trigger(ability,battler,fainted,battle)
  end

  def self.triggerAbilityOnBattlerFainting(ability,battler,fainted,battle)
    AbilityOnBattlerFainting.trigger(ability,battler,fainted,battle)
  end

  #=============================================================================

  def self.triggerRunFromBattleAbility(ability,battler)
    ret = RunFromBattleAbility.trigger(ability,battler)
    return (ret!=nil) ? ret : false
  end

  def self.triggerRunFromBattleItem(item,battler)
    ret = RunFromBattleItem.trigger(item,battler)
    return (ret!=nil) ? ret : false
  end
end



BASE_ACC  = 0
ACC_STAGE = 1
EVA_STAGE = 2
ACC_MULT  = 3
EVA_MULT  = 4

BASE_DMG_MULT  = 0
ATK_MULT       = 1
DEF_MULT       = 2
FINAL_DMG_MULT = 3

def pbBattleConfusionBerry(battler,battle,item,forced,flavor,confuseMsg)
  return false if !forced && !battler.canHeal?
  return false if !forced && !battler.pbCanConsumeBerry?(item,false)
  itemName = PBItems.getName(item)
  battle.pbCommonAnimation("EatBerry",battler) if !forced
  amt = (NEWEST_BATTLE_MECHANICS) ? battler.pbRecoverHP(battler.totalhp/2) : battler.pbRecoverHP(battler.totalhp/8)
  if battler.hasActiveAbility?(:RIPEN)
    amt *= 2
  end
  if amt>0
    if forced
      PBDebug.log("[Item triggered] Forced consuming of #{itemName}")
      battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1} restored its health using its {2}!",battler.pbThis,itemName))
    end
  end
  nUp = PBNatures.getStatRaised(battler.nature)
  nDn = PBNatures.getStatLowered(battler.nature)
  if nUp!=nDn && nDn-1==flavor
    battle.pbDisplay(confuseMsg)
    battler.pbConfuse if battler.pbCanConfuseSelf?(false)
  end
  return true
end

def pbBattleStatIncreasingBerry(battler,battle,item,forced,stat,increment=1)
  return false if !forced && !battler.pbCanConsumeBerry?(item)
  return false if !battler.pbCanRaiseStatStage?(stat,battler)
  itemName = PBItems.getName(item)
  if battler.hasActiveAbility?(:RIPEN)
    increment *=2
  end
  if forced
    PBDebug.log("[Item triggered] Forced consuming of #{itemName}")
    return battler.pbRaiseStatStage(stat,increment,battler)
  end
  battle.pbCommonAnimation("EatBerry",battler)
  return battler.pbRaiseStatStageByCause(stat,increment,battler,itemName)
end

# For abilities that grant immunity to moves of a particular type, and raises
# one of the ability's bearer's stats instead.
def pbBattleMoveImmunityStatAbility(user,target,move,moveType,immuneType,stat,increment,battle)
  return false if user.index==target.index
  return false if !isConst?(moveType,PBTypes,immuneType)
  battle.pbShowAbilitySplash(target)
  if target.pbCanRaiseStatStage?(stat,target)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      target.pbRaiseStatStage(stat,increment,target)
    else
      target.pbRaiseStatStageByCause(stat,increment,target,target.abilityName)
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
  return true
end

# For abilities that grant immunity to moves of a particular type, and heals the
# ability's bearer by 1/4 of its total HP instead.
def pbBattleMoveImmunityHealAbility(user,target,move,moveType,immuneType,battle)
  return false if user.index==target.index
  return false if !isConst?(moveType,PBTypes,immuneType)
  battle.pbShowAbilitySplash(target)
  if target.canHeal? && target.pbRecoverHP(target.totalhp/4)>0
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s HP was restored.",target.pbThis))
    else
      battle.pbDisplay(_INTL("{1}'s {2} restored its HP.",target.pbThis,target.abilityName))
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
  return true
end

def pbBattleGem(user,type,move,mults,moveType)
  # Pledge moves never consume Gems
  return if move.is_a?(PokeBattle_PledgeMove)
  return if !isConst?(moveType,PBTypes,type)
  user.effects[PBEffects::GemConsumed] = user.item
  if NEWEST_BATTLE_MECHANICS
    mults[BASE_DMG_MULT] = (mults[BASE_DMG_MULT]*1.3).round
  else
    mults[BASE_DMG_MULT] = (mults[BASE_DMG_MULT]*1.5).round
  end
end

def pbBattleTypeWeakingBerry(type,moveType,target,mults)
  return if !isConst?(moveType,PBTypes,type)
  return if PBTypes.resistant?(target.damageState.typeMod) && !isConst?(moveType,PBTypes,:NORMAL)
  if target.hasActiveAbility?(:RIPEN)
    mults[FINAL_DMG_MULT] = (mults[FINAL_DMG_MULT]/4).round
  else
    mults[FINAL_DMG_MULT] = (mults[FINAL_DMG_MULT]/2).round
  end
  target.damageState.berryWeakened = true
  target.battle.pbCommonAnimation("EatBerry",target)
end

def pbBattleWeatherAbility(weather,battler,battle,ignorePrimal=false)
  return if !ignorePrimal &&
     (battle.field.weather==PBWeather::HarshSun ||
     battle.field.weather==PBWeather::HeavyRain ||
     battle.field.weather==PBWeather::StrongWinds)
  return if battle.field.weather==weather
  battle.pbShowAbilitySplash(battler)
  if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
    battle.pbDisplay(_INTL("{1}'s {2} activated!",battler.pbThis,battler.abilityName))
  end
  fixedDuration = false
  fixedDuration = true if NEWEST_BATTLE_MECHANICS &&
                          weather!=PBWeather::HarshSun &&
                          weather!=PBWeather::HeavyRain &&
                          weather!=PBWeather::StrongWinds
  battle.pbStartWeather(battler,weather,fixedDuration)
  # NOTE: The ability splash is hidden again in def pbStartWeather.
end
