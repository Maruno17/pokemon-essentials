#===============================================================================
# No additional effect.
#===============================================================================
class PokeBattle_Move_000 < PokeBattle_Move
end



#===============================================================================
# Does absolutely nothing. (Splash)
#===============================================================================
class PokeBattle_Move_001 < PokeBattle_Move
  def unusableInGravity?; return true; end

  def pbEffectGeneral(user)
    @battle.pbDisplay(_INTL("But nothing happened!"))
  end
end



#===============================================================================
# Struggle, if defined as a move in moves.txt. Typically it won't be.
#===============================================================================
class PokeBattle_Move_002 < PokeBattle_Struggle
end



#===============================================================================
# Puts the target to sleep.
#===============================================================================
class PokeBattle_Move_003 < PokeBattle_SleepMove
  def pbMoveFailed?(user,targets)
    if NEWEST_BATTLE_MECHANICS && isConst?(@id,PBMoves,:DARKVOID)
      if !user.isSpecies?(:DARKRAI) &&
         !isConst?(user.effects[PBEffects::TransformSpecies],PBSpecies,:DARKRAI)
        @battle.pbDisplay(_INTL("But {1} can't use the move!",user.pbThis))
        return true
      end
    end
    return false
  end

  def pbEndOfMoveUsageEffect(user,targets,numHits,switchedBattlers)
    return if numHits==0
    return if user.fainted? || user.effects[PBEffects::Transform]
    return if !isConst?(@id,PBMoves,:RELICSONG)
    return if !user.isSpecies?(:MELOETTA)
    return if user.hasActiveAbility?(:SHEERFORCE) && @addlEffect>0
    newForm = (oldForm+1)%2
    user.pbChangeForm(newForm,_INTL("{1} transformed!",user.pbThis))
  end
end



#===============================================================================
# Makes the target drowsy; it falls asleep at the end of the next turn. (Yawn)
#===============================================================================
class PokeBattle_Move_004 < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    if target.effects[PBEffects::Yawn]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return true if !target.pbCanSleep?(user,true,self)
    return false
  end

  def pbEffectAgainstTarget(user,target)
    target.effects[PBEffects::Yawn] = 2
    @battle.pbDisplay(_INTL("{1} made {2} drowsy!",user.pbThis,target.pbThis(true)))
  end
end



#===============================================================================
# Poisons the target.
#===============================================================================
class PokeBattle_Move_005 < PokeBattle_PoisonMove
end



#===============================================================================
# Badly poisons the target. (Poison Fang, Toxic)
#===============================================================================
class PokeBattle_Move_006 < PokeBattle_PoisonMove
  def initialize(battle,move)
    super
    @toxic = true
  end

  def pbOverrideSuccessCheckPerHit(user,target)
    return (NEWEST_BATTLE_MECHANICS && statusMove? && user.pbHasType?(:POISON))
  end
end



#===============================================================================
# Paralyzes the target.
# Thunder Wave: Doesn't affect target if move's type has no effect on it.
# Body Slam: Does double damage and has perfect accuracy if target is Minimized.
#===============================================================================
class PokeBattle_Move_007 < PokeBattle_ParalysisMove
  def tramplesMinimize?(param=1)
    # Perfect accuracy and double damage (for Body Slam only)
    return NEWEST_BATTLE_MECHANICS if isConst?(@id,PBMoves,:BODYSLAM)
    return super
  end

  def pbFailsAgainstTarget?(user,target)
    if isConst?(@id,PBMoves,:THUNDERWAVE) && PBTypes.ineffective?(target.damageState.typeMod)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
      return true
    end
    return super
  end
end



#===============================================================================
# Paralyzes the target. Accuracy perfect in rain, 50% in sunshine. Hits some
# semi-invulnerable targets. (Thunder)
#===============================================================================
class PokeBattle_Move_008 < PokeBattle_ParalysisMove
  def hitsFlyingTargets?; return true; end

  def pbBaseAccuracy(user,target)
    case @battle.pbWeather
    when PBWeather::Sun, PBWeather::HarshSun
      return 50
    when PBWeather::Rain, PBWeather::HeavyRain
      return 0
    end
    return super
  end
end



#===============================================================================
# Paralyzes the target. May cause the target to flinch. (Thunder Fang)
#===============================================================================
class PokeBattle_Move_009 < PokeBattle_Move
  def flinchingMove?; return true; end

  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    chance = pbAdditionalEffectChance(user,target,10)
    return if chance==0
    if @battle.pbRandom(100)<chance
      target.pbParalyze(user) if target.pbCanParalyze?(user,false,self)
    end
    target.pbFlinch(user) if @battle.pbRandom(100)<chance
  end
end



#===============================================================================
# Burns the target.
#===============================================================================
class PokeBattle_Move_00A < PokeBattle_BurnMove
end



#===============================================================================
# Burns the target. May cause the target to flinch. (Fire Fang)
#===============================================================================
class PokeBattle_Move_00B < PokeBattle_Move
  def flinchingMove?; return true; end

  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    chance = pbAdditionalEffectChance(user,target,10)
    return if chance==0
    if @battle.pbRandom(100)<chance
      target.pbBurn(user) if target.pbCanBurn?(user,false,self)
    end
    target.pbFlinch(user) if @battle.pbRandom(100)<chance
  end
end



#===============================================================================
# Freezes the target.
#===============================================================================
class PokeBattle_Move_00C < PokeBattle_FreezeMove
end



#===============================================================================
# Freezes the target. Accuracy perfect in hail. (Blizzard)
#===============================================================================
class PokeBattle_Move_00D < PokeBattle_FreezeMove
  def pbBaseAccuracy(user,target)
    return 0 if @battle.pbWeather==PBWeather::Hail
    return super
  end
end



#===============================================================================
# Freezes the target. May cause the target to flinch. (Ice Fang)
#===============================================================================
class PokeBattle_Move_00E < PokeBattle_Move
  def flinchingMove?; return true; end

  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    chance = pbAdditionalEffectChance(user,target,10)
    return if chance==0
    if @battle.pbRandom(100)<chance
      target.pbFreeze if target.pbCanFreeze?(user,false,self)
    end
    target.pbFlinch(user) if @battle.pbRandom(100)<chance
  end
end



#===============================================================================
# Causes the target to flinch.
#===============================================================================
class PokeBattle_Move_00F < PokeBattle_FlinchMove
end



#===============================================================================
# Causes the target to flinch. Does double damage and has perfect accuracy if
# the target is Minimized. (Dragon Rush, Steamroller, Stomp)
#===============================================================================
class PokeBattle_Move_010 < PokeBattle_FlinchMove
  def tramplesMinimize?(param=1)
    return super if isConst?(@id,PBMoves,:DRAGONRUSH) && !NEWEST_BATTLE_MECHANICS
    return true if param==1 && NEWEST_BATTLE_MECHANICS   # Perfect accuracy
    return true if param==2   # Double damage
    return super
  end
end



#===============================================================================
# Causes the target to flinch. Fails if the user is not asleep. (Snore)
#===============================================================================
class PokeBattle_Move_011 < PokeBattle_FlinchMove
  def usableWhenAsleep?; return true; end

  def pbMoveFailed?(user,targets)
    if !user.asleep?
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
end



#===============================================================================
# Causes the target to flinch. Fails if this isn't the user's first turn.
# (Fake Out)
#===============================================================================
class PokeBattle_Move_012 < PokeBattle_FlinchMove
  def pbMoveFailed?(user,targets)
    if user.turnCount>1 || user.lastRoundMoved>=0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
end



#===============================================================================
# Confuses the target.
#===============================================================================
class PokeBattle_Move_013 < PokeBattle_ConfuseMove
end



#===============================================================================
# Confuses the target. Chance of causing confusion depends on the cry's volume.
# Confusion chance is 0% if user doesn't have a recorded cry. (Chatter)
#===============================================================================
class PokeBattle_Move_014 < PokeBattle_ConfuseMove
  def pbOnStartUse(user,targets)
    @chatterChance = 0
    if user.pokemon && user.pokemon.chatter
      # Intensity can be 0-127, so return value is 0-10
      @chatterChance = 10*user.pokemon.chatter.intensity/127
    end
  end

  def addlEffect
    return @chatterChance if !NEWEST_BATTLE_MECHANICS
    return super
  end
end



#===============================================================================
# Confuses the target. Accuracy perfect in rain, 50% in sunshine. Hits some
# semi-invulnerable targets. (Hurricane)
#===============================================================================
class PokeBattle_Move_015 < PokeBattle_ConfuseMove
  def hitsFlyingTargets?; return true; end

  def pbBaseAccuracy(user,target)
    case @battle.pbWeather
    when PBWeather::Sun, PBWeather::HarshSun
      return 50
    when PBWeather::Rain, PBWeather::HeavyRain
      return 0
    end
    return super
  end
end



#===============================================================================
# Attracts the target. (Attract)
#===============================================================================
class PokeBattle_Move_016 < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end

  def pbFailsAgainstTarget?(user,target)
    return false if damagingMove?
    return true if !target.pbCanAttract?(user)
    return true if pbMoveFailedAromaVeil?(user,target)
    return false
  end

  def pbEffectAgainstTarget(user,target)
    return if damagingMove?
    target.pbAttract(user)
  end

  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    target.pbAttract(user) if target.pbCanAttract?(user,false)
  end
end



#===============================================================================
# Burns, freezes or paralyzes the target. (Tri Attack)
#===============================================================================
class PokeBattle_Move_017 < PokeBattle_Move
  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    case @battle.pbRandom(3)
    when 0; target.pbBurn(user) if target.pbCanBurn?(user,false,self)
    when 1; target.pbFreeze if target.pbCanFreeze?(user,false,self)
    when 2; target.pbParalyze(user) if target.pbCanParalyze?(user,false,self)
    end
  end
end



#===============================================================================
# Cures user of burn, poison and paralysis. (Refresh)
#===============================================================================
class PokeBattle_Move_018 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if user.status!=PBStatuses::BURN &&
       user.status!=PBStatuses::POISON &&
       user.status!=PBStatuses::PARALYSIS
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    t = user.status
    user.pbCureStatus(false)
    case t
    when PBStatuses::BURN
      @battle.pbDisplay(_INTL("{1} healed its burn!",user.pbThis))
    when PBStatuses::POISON
      @battle.pbDisplay(_INTL("{1} cured its poisoning!",user.pbThis))
    when PBStatuses::PARALYSIS
      @battle.pbDisplay(_INTL("{1} cured its paralysis!",user.pbThis))
    end
  end
end



#===============================================================================
# Cures all party Pokémon of permanent status problems. (Aromatherapy, Heal Bell)
#===============================================================================
# NOTE: In Gen 5, this move should have a target of UserSide, while in Gen 6+ it
#       should have a target of UserAndAllies. This is because, in Gen 5, this
#       move shouldn't call def pbSuccessCheckAgainstTarget for each Pokémon
#       currently in battle that will be affected by this move (i.e. allies
#       aren't protected by their substitute/ability/etc., but they are in Gen
#       6+). We achieve this by not targeting any battlers in Gen 5, since
#       pbSuccessCheckAgainstTarget is only called for targeted battlers.
class PokeBattle_Move_019 < PokeBattle_Move
  def worksWithNoTargets?; return true; end

  def pbMoveFailed?(user,targets)
    failed = true
    @battle.eachSameSideBattler(user) do |b|
      next if b.status==PBStatuses::NONE
      failed = false
      break
    end
    if !failed
      @battle.pbParty(user.index).each do |pkmn|
        next if !pkmn || !pkmn.able? || pkmn.status==PBStatuses::NONE
        failed = false
        break
      end
    end
    if failed
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user,target)
    return target.status==PBStatuses::NONE
  end

  def pbAromatherapyHeal(pkmn,battler=nil)
    oldStatus = (battler) ? battler.status : pkmn.status
    curedName = (battler) ? battler.pbThis : pkmn.name
    if battler
      battler.pbCureStatus(false)
    else
      pkmn.status      = PBStatuses::NONE
      pkmn.statusCount = 0
    end
    case oldStatus
    when PBStatuses::SLEEP
      @battle.pbDisplay(_INTL("{1} was woken from sleep.",curedName))
    when PBStatuses::POISON
      @battle.pbDisplay(_INTL("{1} was cured of its poisoning.",curedName))
    when PBStatuses::BURN
      @battle.pbDisplay(_INTL("{1}'s burn was healed.",curedName))
    when PBStatuses::PARALYSIS
      @battle.pbDisplay(_INTL("{1} was cured of paralysis.",curedName))
    when PBStatuses::FROZEN
      @battle.pbDisplay(_INTL("{1} was thawed out.",curedName))
    end
  end

  def pbEffectAgainstTarget(user,target)
    # Cure all Pokémon in battle on the user's side.
    pbAromatherapyHeal(target.pokemon,target)
  end

  def pbEffectGeneral(user)
    # Cure all Pokémon in battle on the user's side. For the benefit of the Gen
    # 5 version of this move, to make Pokémon out in battle get cured first.
    if pbTarget(user)!=PBTargets::UserAndAllies
      @battle.eachSameSideBattler(user) do |b|
        next if b.status==PBStatuses::NONE
        pbAromatherapyHeal(b.pokemon,b)
      end
    end
    # Cure all Pokémon in the user's and partner trainer's party.
    # NOTE: This intentionally affects the partner trainer's inactive Pokémon
    #       too.
    @battle.pbParty(user.index).each_with_index do |pkmn,i|
      next if !pkmn || !pkmn.able? || pkmn.status==PBStatuses::NONE
      next if @battle.pbFindBattler(i,user)   # Skip Pokémon in battle
      pbAromatherapyHeal(pkmn)
    end
  end

  def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
    super
    if isConst?(@id,PBMoves,:AROMATHERAPY)
      @battle.pbDisplay(_INTL("A soothing aroma wafted through the area!"))
    elsif isConst?(@id,PBMoves,:HEALBELL)
      @battle.pbDisplay(_INTL("A bell chimed!"))
    end
  end
end



#===============================================================================
# Safeguards the user's side from being inflicted with status problems.
# (Safeguard)
#===============================================================================
class PokeBattle_Move_01A < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if user.pbOwnSide.effects[PBEffects::Safeguard]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.pbOwnSide.effects[PBEffects::Safeguard] = 5
    @battle.pbDisplay(_INTL("{1} became cloaked in a mystical veil!",user.pbTeam))
  end
end



#===============================================================================
# User passes its status problem to the target. (Psycho Shift)
#===============================================================================
class PokeBattle_Move_01B < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if user.status==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user,target)
    if !target.pbCanInflictStatus?(user.status,user,false,self)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    msg = ""
    case user.status
    when PBStatuses::SLEEP
      target.pbSleep
      msg = _INTL("{1} woke up.",user.pbThis)
    when PBStatuses::POISON
      target.pbPoison(user,nil,user.statusCount!=0)
      msg = _INTL("{1} was cured of its poisoning.",user.pbThis)
    when PBStatuses::BURN
      target.pbBurn(user)
      msg = _INTL("{1}'s burn was healed.",user.pbThis)
    when PBStatuses::PARALYSIS
      target.pbParalyze(user)
      msg = _INTL("{1} was cured of paralysis.",user.pbThis)
    when PBStatuses::FROZEN
      target.pbFreeze
      msg = _INTL("{1} was thawed out.",user.pbThis)
    end
    if msg!=""
      user.pbCureStatus(false)
      @battle.pbDisplay(msg)
    end
  end
end



#===============================================================================
# Increases the user's Attack by 1 stage.
#===============================================================================
class PokeBattle_Move_01C < PokeBattle_StatUpMove
  def initialize(battle,move)
    super
    @statUp = [PBStats::ATTACK,1]
  end
end



#===============================================================================
# Increases the user's Defense by 1 stage. (Harden, Steel Wing, Withdraw)
#===============================================================================
class PokeBattle_Move_01D < PokeBattle_StatUpMove
  def initialize(battle,move)
    super
    @statUp = [PBStats::DEFENSE,1]
  end
end



#===============================================================================
# Increases the user's Defense by 1 stage. User curls up. (Defense Curl)
#===============================================================================
class PokeBattle_Move_01E < PokeBattle_StatUpMove
  def initialize(battle,move)
    super
    @statUp = [PBStats::DEFENSE,1]
  end

  def pbEffectGeneral(user)
    user.effects[PBEffects::DefenseCurl] = true
    super
  end
end



#===============================================================================
# Increases the user's Speed by 1 stage. (Flame Charge)
#===============================================================================
class PokeBattle_Move_01F < PokeBattle_StatUpMove
  def initialize(battle,move)
    super
    @statUp = [PBStats::SPEED,1]
  end
end



#===============================================================================
# Increases the user's Special Attack by 1 stage. (Charge Beam, Fiery Dance)
#===============================================================================
class PokeBattle_Move_020 < PokeBattle_StatUpMove
  def initialize(battle,move)
    super
    @statUp = [PBStats::SPATK,1]
  end
end



#===============================================================================
# Increases the user's Special Defense by 1 stage.
# Charges up user's next attack if it is Electric-type. (Charge)
#===============================================================================
class PokeBattle_Move_021 < PokeBattle_StatUpMove
  def initialize(battle,move)
    super
    @statUp = [PBStats::SPDEF,1]
  end

  def pbEffectGeneral(user)
    user.effects[PBEffects::Charge] = 2
    @battle.pbDisplay(_INTL("{1} began charging power!",user.pbThis))
    super
  end
end



#===============================================================================
# Increases the user's evasion by 1 stage. (Double Team)
#===============================================================================
class PokeBattle_Move_022 < PokeBattle_StatUpMove
  def initialize(battle,move)
    super
    @statUp = [PBStats::EVASION,1]
  end
end



#===============================================================================
# Increases the user's critical hit rate. (Focus Energy)
#===============================================================================
class PokeBattle_Move_023 < PokeBattle_Move
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
class PokeBattle_Move_024 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [PBStats::ATTACK,1,PBStats::DEFENSE,1]
  end
end



#===============================================================================
# Increases the user's Attack, Defense and accuracy by 1 stage each. (Coil)
#===============================================================================
class PokeBattle_Move_025 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [PBStats::ATTACK,1,PBStats::DEFENSE,1,PBStats::ACCURACY,1]
  end
end



#===============================================================================
# Increases the user's Attack and Speed by 1 stage each. (Dragon Dance)
#===============================================================================
class PokeBattle_Move_026 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [PBStats::ATTACK,1,PBStats::SPEED,1]
  end
end



#===============================================================================
# Increases the user's Attack and Special Attack by 1 stage each. (Work Up)
#===============================================================================
class PokeBattle_Move_027 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [PBStats::ATTACK,1,PBStats::SPATK,1]
  end
end



#===============================================================================
# Increases the user's Attack and Sp. Attack by 1 stage each.
# In sunny weather, increases are 2 stages each instead. (Growth)
#===============================================================================
class PokeBattle_Move_028 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [PBStats::ATTACK,1,PBStats::SPATK,1]
  end

  def pbOnStartUse(user,targets)
    increment = 1
    if @battle.pbWeather==PBWeather::Sun ||
       @battle.pbWeather==PBWeather::HarshSun
      increment = 2
    end
    @statUp[1] = @statUp[3] = increment
  end
end



#===============================================================================
# Increases the user's Attack and accuracy by 1 stage each. (Hone Claws)
#===============================================================================
class PokeBattle_Move_029 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [PBStats::ATTACK,1,PBStats::ACCURACY,1]
  end
end



#===============================================================================
# Increases the user's Defense and Special Defense by 1 stage each.
# (Cosmic Power, Defend Order)
#===============================================================================
class PokeBattle_Move_02A < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [PBStats::DEFENSE,1,PBStats::SPDEF,1]
  end
end



#===============================================================================
# Increases the user's Sp. Attack, Sp. Defense and Speed by 1 stage each.
# (Quiver Dance)
#===============================================================================
class PokeBattle_Move_02B < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [PBStats::SPATK,1,PBStats::SPDEF,1,PBStats::SPEED,1]
  end
end



#===============================================================================
# Increases the user's Sp. Attack and Sp. Defense by 1 stage each. (Calm Mind)
#===============================================================================
class PokeBattle_Move_02C < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [PBStats::SPATK,1,PBStats::SPDEF,1]
  end
end



#===============================================================================
# Increases the user's Attack, Defense, Speed, Special Attack and Special Defense
# by 1 stage each. (Ancient Power, Ominous Wind, Silver Wind)
#===============================================================================
class PokeBattle_Move_02D < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [PBStats::ATTACK,1,PBStats::DEFENSE,1,
               PBStats::SPATK,1,PBStats::SPDEF,1,
               PBStats::SPEED,1]
  end
end



#===============================================================================
# Increases the user's Attack by 2 stages. (Swords Dance)
#===============================================================================
class PokeBattle_Move_02E < PokeBattle_StatUpMove
  def initialize(battle,move)
    super
    @statUp = [PBStats::ATTACK,2]
  end
end



#===============================================================================
# Increases the user's Defense by 2 stages. (Acid Armor, Barrier, Iron Defense)
#===============================================================================
class PokeBattle_Move_02F < PokeBattle_StatUpMove
  def initialize(battle,move)
    super
    @statUp = [PBStats::DEFENSE,2]
  end
end



#===============================================================================
# Increases the user's Speed by 2 stages. (Agility, Rock Polish)
#===============================================================================
class PokeBattle_Move_030 < PokeBattle_StatUpMove
  def initialize(battle,move)
    super
    @statUp = [PBStats::SPEED,2]
  end
end



#===============================================================================
# Increases the user's Speed by 2 stages. Lowers user's weight by 100kg.
# (Autotomize)
#===============================================================================
class PokeBattle_Move_031 < PokeBattle_StatUpMove
  def initialize(battle,move)
    super
    @statUp = [PBStats::SPEED,2]
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
# Increases the user's Special Attack by 2 stages. (Nasty Plot)
#===============================================================================
class PokeBattle_Move_032 < PokeBattle_StatUpMove
  def initialize(battle,move)
    super
    @statUp = [PBStats::SPATK,2]
  end
end



#===============================================================================
# Increases the user's Special Defense by 2 stages. (Amnesia)
#===============================================================================
class PokeBattle_Move_033 < PokeBattle_StatUpMove
  def initialize(battle,move)
    super
    @statUp = [PBStats::SPDEF,2]
  end
end



#===============================================================================
# Increases the user's evasion by 2 stages. Minimizes the user. (Minimize)
#===============================================================================
class PokeBattle_Move_034 < PokeBattle_StatUpMove
  def initialize(battle,move)
    super
    @statUp = [PBStats::EVASION,2]
  end

  def pbEffectGeneral(user)
    user.effects[PBEffects::Minimize] = true
    super
  end
end



#===============================================================================
# Decreases the user's Defense and Special Defense by 1 stage each.
# Increases the user's Attack, Speed and Special Attack by 2 stages each.
# (Shell Smash)
#===============================================================================
class PokeBattle_Move_035 < PokeBattle_Move
  def initialize(battle,move)
    super
    @statUp   = [PBStats::ATTACK,2,PBStats::SPATK,2,PBStats::SPEED,2]
    @statDown = [PBStats::DEFENSE,1,PBStats::SPDEF,1]
  end

  def pbMoveFailed?(user,targets)
    failed = true
    for i in 0...@statUp.length/2
      if user.pbCanRaiseStatStage?(@statUp[i*2],user,self)
        failed = false; break
      end
    end
    for i in 0...@statDown.length/2
      if user.pbCanLowerStatStage?(@statDown[i*2],user,self)
        failed = false; break
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
# Increases the user's Speed by 2 stages, and its Attack by 1 stage. (Shift Gear)
#===============================================================================
class PokeBattle_Move_036 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [PBStats::SPEED,2,PBStats::ATTACK,1]
  end
end



#===============================================================================
# Increases one random stat of the target by 2 stages (except HP). (Acupressure)
#===============================================================================
class PokeBattle_Move_037 < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    @statArray = []
    PBStats.eachBattleStat do |s|
      @statArray.push(s) if target.pbCanRaiseStatStage?(s,user,self)
    end
    if @statArray.length==0
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",target.pbThis))
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
# Increases the user's Defense by 3 stages. (Cotton Guard)
#===============================================================================
class PokeBattle_Move_038 < PokeBattle_StatUpMove
  def initialize(battle,move)
    super
    @statUp = [PBStats::DEFENSE,3]
  end
end



#===============================================================================
# Increases the user's Special Attack by 3 stages. (Tail Glow)
#===============================================================================
class PokeBattle_Move_039 < PokeBattle_StatUpMove
  def initialize(battle,move)
    super
    @statUp = [PBStats::SPATK,3]
  end
end



#===============================================================================
# Reduces the user's HP by half of max, and sets its Attack to maximum.
# (Belly Drum)
#===============================================================================
class PokeBattle_Move_03A < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    hpLoss = [user.totalhp/2,1].max
    if user.hp<=hpLoss
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return true if !user.pbCanRaiseStatStage?(PBStats::ATTACK,user,self,true)
    return false
  end

  def pbEffectGeneral(user)
    hpLoss = [user.totalhp/2,1].max
    user.pbReduceHP(hpLoss,false)
    if user.hasActiveAbility?(:CONTRARY)
      user.stages[PBStats::ATTACK] = -6
      @battle.pbCommonAnimation("StatDown",user)
      @battle.pbDisplay(_INTL("{1} cut its own HP and minimized its Attack!",user.pbThis))
    else
      user.stages[PBStats::ATTACK] = 6
      @battle.pbCommonAnimation("StatUp",user)
      @battle.pbDisplay(_INTL("{1} cut its own HP and maximized its Attack!",user.pbThis))
    end
    user.pbItemHPHealCheck
  end
end



#===============================================================================
# Decreases the user's Attack and Defense by 1 stage each. (Superpower)
#===============================================================================
class PokeBattle_Move_03B < PokeBattle_StatDownMove
  def initialize(battle,move)
    super
    @statDown = [PBStats::ATTACK,1,PBStats::DEFENSE,1]
  end
end



#===============================================================================
# Decreases the user's Defense and Special Defense by 1 stage each.
# (Close Combat, Dragon Ascent)
#===============================================================================
class PokeBattle_Move_03C < PokeBattle_StatDownMove
  def initialize(battle,move)
    super
    @statDown = [PBStats::DEFENSE,1,PBStats::SPDEF,1]
  end
end



#===============================================================================
# Decreases the user's Defense, Special Defense and Speed by 1 stage each.
# (V-create)
#===============================================================================
class PokeBattle_Move_03D < PokeBattle_StatDownMove
  def initialize(battle,move)
    super
    @statDown = [PBStats::SPEED,1,PBStats::DEFENSE,1,PBStats::SPDEF,1]
  end
end



#===============================================================================
# Decreases the user's Speed by 1 stage. (Hammer Arm, Ice Hammer)
#===============================================================================
class PokeBattle_Move_03E < PokeBattle_StatDownMove
  def initialize(battle,move)
    super
    @statDown = [PBStats::SPEED,1]
  end
end



#===============================================================================
# Decreases the user's Special Attack by 2 stages.
#===============================================================================
class PokeBattle_Move_03F < PokeBattle_StatDownMove
  def initialize(battle,move)
    super
    @statDown = [PBStats::SPATK,2]
  end
end



#===============================================================================
# Increases the target's Special Attack by 1 stage. Confuses the target. (Flatter)
#===============================================================================
class PokeBattle_Move_040 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    failed = true
    targets.each do |b|
      next if !b.pbCanRaiseStatStage?(PBStats::SPATK,user,self) &&
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
    if target.pbCanRaiseStatStage?(PBStats::SPATK,user,self)
      target.pbRaiseStatStage(PBStats::SPATK,1,user)
    end
    target.pbConfuse if target.pbCanConfuse?(user,false,self)
  end
end



#===============================================================================
# Increases the target's Attack by 2 stages. Confuses the target. (Swagger)
#===============================================================================
class PokeBattle_Move_041 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    failed = true
    targets.each do |b|
      next if !b.pbCanRaiseStatStage?(PBStats::ATTACK,user,self) &&
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
    if target.pbCanRaiseStatStage?(PBStats::ATTACK,user,self)
      target.pbRaiseStatStage(PBStats::ATTACK,2,user)
    end
    target.pbConfuse if target.pbCanConfuse?(user,false,self)
  end
end



#===============================================================================
# Decreases the target's Attack by 1 stage.
#===============================================================================
class PokeBattle_Move_042 < PokeBattle_TargetStatDownMove
  def initialize(battle,move)
    super
    @statDown = [PBStats::ATTACK,1]
  end
end


#===============================================================================
# Decreases the target's Defense by 1 stage.
#===============================================================================
class PokeBattle_Move_043 < PokeBattle_TargetStatDownMove
  def initialize(battle,move)
    super
    @statDown = [PBStats::DEFENSE,1]
  end
end



#===============================================================================
# Decreases the target's Speed by 1 stage.
#===============================================================================
class PokeBattle_Move_044 < PokeBattle_TargetStatDownMove
  def initialize(battle,move)
    super
    @statDown = [PBStats::SPEED,1]
  end

  def pbBaseDamage(baseDmg,user,target)
    if isConst?(@id,PBMoves,:BULLDOZE) && @battle.field.terrain==PBBattleTerrains::Grassy
      baseDmg = (baseDmg/2.0).round
    end
    return baseDmg
  end
end



#===============================================================================
# Decreases the target's Special Attack by 1 stage.
#===============================================================================
class PokeBattle_Move_045 < PokeBattle_TargetStatDownMove
  def initialize(battle,move)
    super
    @statDown = [PBStats::SPATK,1]
  end
end



#===============================================================================
# Decreases the target's Special Defense by 1 stage.
#===============================================================================
class PokeBattle_Move_046 < PokeBattle_TargetStatDownMove
  def initialize(battle,move)
    super
    @statDown = [PBStats::SPDEF,1]
  end
end



#===============================================================================
# Decreases the target's accuracy by 1 stage.
#===============================================================================
class PokeBattle_Move_047 < PokeBattle_TargetStatDownMove
  def initialize(battle,move)
    super
    @statDown = [PBStats::ACCURACY,1]
  end
end



#===============================================================================
# Decreases the target's evasion by 1 stage OR 2 stages. (Sweet Scent)
#===============================================================================
class PokeBattle_Move_048 < PokeBattle_TargetStatDownMove
  def initialize(battle,move)
    super
    @statDown = [PBStats::EVASION,(NEWEST_BATTLE_MECHANICS) ? 2 : 1]
  end
end



#===============================================================================
# Decreases the target's evasion by 1 stage. Ends all barriers and entry
# hazards for the target's side OR on both sides. (Defog)
#===============================================================================
class PokeBattle_Move_049 < PokeBattle_TargetStatDownMove
  def ignoresSubstitute?(user); return true; end

  def initialize(battle,move)
    super
    @statDown = [PBStats::EVASION,1]
  end

  def pbFailsAgainstTarget?(user,target)
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
    return false if NEWEST_BATTLE_MECHANICS &&
                    (targetOpposingSide.effects[PBEffects::StealthRock] ||
                    targetOpposingSide.effects[PBEffects::Spikes]>0 ||
                    targetOpposingSide.effects[PBEffects::ToxicSpikes]>0 ||
                    targetOpposingSide.effects[PBEffects::StickyWeb])
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
       (NEWEST_BATTLE_MECHANICS &&
       target.pbOpposingSide.effects[PBEffects::StealthRock])
      target.pbOwnSide.effects[PBEffects::StealthRock]      = false
      target.pbOpposingSide.effects[PBEffects::StealthRock] = false if NEWEST_BATTLE_MECHANICS
      @battle.pbDisplay(_INTL("{1} blew away stealth rocks!",user.pbThis))
    end
    if target.pbOwnSide.effects[PBEffects::Spikes]>0 ||
       (NEWEST_BATTLE_MECHANICS &&
       target.pbOpposingSide.effects[PBEffects::Spikes]>0)
      target.pbOwnSide.effects[PBEffects::Spikes]      = 0
      target.pbOpposingSide.effects[PBEffects::Spikes] = 0 if NEWEST_BATTLE_MECHANICS
      @battle.pbDisplay(_INTL("{1} blew away spikes!",user.pbThis))
    end
    if target.pbOwnSide.effects[PBEffects::ToxicSpikes]>0 ||
       (NEWEST_BATTLE_MECHANICS &&
       target.pbOpposingSide.effects[PBEffects::ToxicSpikes]>0)
      target.pbOwnSide.effects[PBEffects::ToxicSpikes]      = 0
      target.pbOpposingSide.effects[PBEffects::ToxicSpikes] = 0 if NEWEST_BATTLE_MECHANICS
      @battle.pbDisplay(_INTL("{1} blew away poison spikes!",user.pbThis))
    end
    if target.pbOwnSide.effects[PBEffects::StickyWeb] ||
       (NEWEST_BATTLE_MECHANICS &&
       target.pbOpposingSide.effects[PBEffects::StickyWeb])
      target.pbOwnSide.effects[PBEffects::StickyWeb]      = false
      target.pbOpposingSide.effects[PBEffects::StickyWeb] = false if NEWEST_BATTLE_MECHANICS
      @battle.pbDisplay(_INTL("{1} blew away sticky webs!",user.pbThis))
    end
  end
end



#===============================================================================
# Decreases the target's Attack and Defense by 1 stage each. (Tickle)
#===============================================================================
class PokeBattle_Move_04A < PokeBattle_TargetMultiStatDownMove
  def initialize(battle,move)
    super
    @statDown = [PBStats::ATTACK,1,PBStats::DEFENSE,1]
  end
end



#===============================================================================
# Decreases the target's Attack by 2 stages. (Charm, Feather Dance)
#===============================================================================
class PokeBattle_Move_04B < PokeBattle_TargetStatDownMove
  def initialize(battle,move)
    super
    @statDown = [PBStats::ATTACK,2]
  end
end



#===============================================================================
# Decreases the target's Defense by 2 stages. (Screech)
#===============================================================================
class PokeBattle_Move_04C < PokeBattle_TargetStatDownMove
  def initialize(battle,move)
    super
    @statDown = [PBStats::DEFENSE,2]
  end
end



#===============================================================================
# Decreases the target's Speed by 2 stages. (Cotton Spore, Scary Face, String Shot)
#===============================================================================
class PokeBattle_Move_04D < PokeBattle_TargetStatDownMove
  def initialize(battle,move)
    super
    inc = 2
    inc = 1 if isConst?(@id,PBMoves,:STRINGSHOT) && !NEWEST_BATTLE_MECHANICS
    @statDown = [PBStats::SPEED,inc]
  end
end



#===============================================================================
# Decreases the target's Special Attack by 2 stages. Only works on the opposite
# gender. (Captivate)
#===============================================================================
class PokeBattle_Move_04E < PokeBattle_TargetStatDownMove
  def initialize(battle,move)
    super
    @statDown = [PBStats::SPATK,2]
  end

  def pbFailsAgainstTarget?(user,target)
    return true if super
    return false if damagingMove?
    if user.gender==2 || target.gender==2 || user.gender==target.gender
      @battle.pbDisplay(_INTL("{1} is unaffected!",target.pbThis))
      return true
    end
    if target.hasActiveAbility?(:OBLIVIOUS) && !@battle.moldBreaker
      @battle.pbShowAbilitySplash(target)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        @battle.pbDisplay(_INTL("{1} is unaffected!",target.pbThis))
      else
        @battle.pbDisplay(_INTL("{1}'s {2} prevents romance!",target.pbThis,target.abilityName))
      end
      @battle.pbHideAbilitySplash(target)
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
# Decreases the target's Special Defense by 2 stages.
#===============================================================================
class PokeBattle_Move_04F < PokeBattle_TargetStatDownMove
  def initialize(battle,move)
    super
    @statDown = [PBStats::SPDEF,2]
  end
end



#===============================================================================
# Resets all target's stat stages to 0. (Clear Smog)
#===============================================================================
class PokeBattle_Move_050 < PokeBattle_Move
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
class PokeBattle_Move_051 < PokeBattle_Move
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
# User and target swap their Attack and Special Attack stat stages. (Power Swap)
#===============================================================================
class PokeBattle_Move_052 < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end

  def pbEffectAgainstTarget(user,target)
    [PBStats::ATTACK,PBStats::SPATK].each do |s|
      user.stages[s],target.stages[s] = target.stages[s],user.stages[s]
    end
    @battle.pbDisplay(_INTL("{1} switched all changes to its Attack and Sp. Atk with the target!",user.pbThis))
  end
end



#===============================================================================
# User and target swap their Defense and Special Defense stat stages. (Guard Swap)
#===============================================================================
class PokeBattle_Move_053 < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end

  def pbEffectAgainstTarget(user,target)
    [PBStats::DEFENSE,PBStats::SPDEF].each do |s|
      user.stages[s],target.stages[s] = target.stages[s],user.stages[s]
    end
    @battle.pbDisplay(_INTL("{1} switched all changes to its Defense and Sp. Def with the target!",user.pbThis))
  end
end



#===============================================================================
# User and target swap all their stat stages. (Heart Swap)
#===============================================================================
class PokeBattle_Move_054 < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end

  def pbEffectAgainstTarget(user,target)
    PBStats.eachBattleStat do |s|
      user.stages[s],target.stages[s] = target.stages[s],user.stages[s]
    end
    @battle.pbDisplay(_INTL("{1} switched stat changes with the target!",user.pbThis))
  end
end



#===============================================================================
# User copies the target's stat stages. (Psych Up)
#===============================================================================
class PokeBattle_Move_055 < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end

  def pbEffectAgainstTarget(user,target)
    PBStats.eachBattleStat { |s| user.stages[s] = target.stages[s] }
    if NEWEST_BATTLE_MECHANICS
      user.effects[PBEffects::FocusEnergy] = target.effects[PBEffects::FocusEnergy]
      user.effects[PBEffects::LaserFocus]  = target.effects[PBEffects::LaserFocus]
    end
    @battle.pbDisplay(_INTL("{1} copied {2}'s stat changes!",user.pbThis,target.pbThis(true)))
  end
end



#===============================================================================
# For 5 rounds, user's and ally's stat stages cannot be lowered by foes. (Mist)
#===============================================================================
class PokeBattle_Move_056 < PokeBattle_Move
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
class PokeBattle_Move_057 < PokeBattle_Move
  def pbEffectGeneral(user)
    user.attack,user.defense = user.defense,user.attack
    user.effects[PBEffects::PowerTrick] = !user.effects[PBEffects::PowerTrick]
    @battle.pbDisplay(_INTL("{1} switched its Attack and Defense!",user.pbThis))
  end
end



#===============================================================================
# Averages the user's and target's Attack.
# Averages the user's and target's Special Attack. (Power Split)
#===============================================================================
class PokeBattle_Move_058 < PokeBattle_Move
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
class PokeBattle_Move_059 < PokeBattle_Move
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
class PokeBattle_Move_05A < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    newHP = (user.hp+target.hp)/2
    if user.hp>newHP;    user.pbReduceHP(user.hp-newHP,false,false)
    elsif user.hp<newHP; user.pbRecoverHP(newHP-user.hp,false)
    end
    if target.hp>newHP;    target.pbReduceHP(target.hp-newHP,false,false)
    elsif target.hp<newHP; target.pbRecoverHP(newHP-target.hp,false)
    end
    @battle.pbDisplay(_INTL("The battlers shared their pain!"))
    user.pbItemHPHealCheck
    target.pbItemHPHealCheck
  end
end



#===============================================================================
# For 4 rounds, doubles the Speed of all battlers on the user's side. (Tailwind)
#===============================================================================
class PokeBattle_Move_05B < PokeBattle_Move
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
# This move turns into the last move used by the target, until user switches
# out. (Mimic)
#===============================================================================
class PokeBattle_Move_05C < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end

  def initialize(battle,move)
    super
    @moveBlacklist = [
       "014",   # Chatter
       "0B6",   # Metronome
       # Struggle
       "002",   # Struggle
       # Moves that affect the moveset
       "05C",   # Mimic
       "05D",   # Sketch
       "069"    # Transform
    ]
  end

  def pbMoveFailed?(user,targets)
    if user.effects[PBEffects::Transform] || !user.pbHasMove?(@id)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user,target)
    lastMoveData = pbGetMoveData(target.lastRegularMoveUsed)
    if target.lastRegularMoveUsed<=0 ||
       user.pbHasMove?(target.lastRegularMoveUsed) ||
       @moveBlacklist.include?(lastMoveData[MOVE_FUNCTION_CODE]) ||
       isConst?(lastMoveData[MOVE_TYPE],PBTypes,:SHADOW)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    user.eachMoveWithIndex do |m,i|
      next if m.id!=@id
      newMove = PBMove.new(target.lastRegularMoveUsed)
      user.moves[i] = PokeBattle_Move.pbFromPBMove(@battle,newMove)
      @battle.pbDisplay(_INTL("{1} learned {2}!",user.pbThis,
         PBMoves.getName(target.lastRegularMoveUsed)))
      user.pbCheckFormOnMovesetChange
      break
    end
  end
end



#===============================================================================
# This move permanently turns into the last move used by the target. (Sketch)
#===============================================================================
class PokeBattle_Move_05D < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end

  def initialize(battle,move)
    super
    @moveBlacklist = [
       "014",   # Chatter
       "05D",   # Sketch (this move)
       # Struggle
       "002"    # Struggle
    ]
  end

  def pbMoveFailed?(user,targets)
    if user.effects[PBEffects::Transform] || !user.pbHasMove?(@id)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user,target)
    lastMoveData = pbGetMoveData(target.lastRegularMoveUsed)
    if target.lastRegularMoveUsed<=0 ||
       user.pbHasMove?(target.lastRegularMoveUsed) ||
       @moveBlacklist.include?(lastMoveData[MOVE_FUNCTION_CODE]) ||
       isConst?(lastMoveData[MOVE_TYPE],PBTypes,:SHADOW)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    user.eachMoveWithIndex do |m,i|
      next if m.id!=@id
      newMove = PBMove.new(target.lastRegularMoveUsed)
      user.pokemon.moves[i] = newMove
      user.moves[i] = PokeBattle_Move.pbFromPBMove(@battle,newMove)
      @battle.pbDisplay(_INTL("{1} learned {2}!",user.pbThis,
         PBMoves.getName(target.lastRegularMoveUsed)))
      user.pbCheckFormOnMovesetChange
      break
    end
  end
end



#===============================================================================
# Changes user's type to that of a random user's move, except a type the user
# already has (even partially), OR changes to the user's first move's type.
# (Conversion)
#===============================================================================
class PokeBattle_Move_05E < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if !user.canChangeType?
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    userTypes = user.pbTypes(true)
    @newTypes = []
    user.eachMoveWithIndex do |m,i|
      break if NEWEST_BATTLE_MECHANICS && i>0
      next if PBTypes.isPseudoType?(m.type)
      next if userTypes.include?(m.type)
      @newTypes.push(m.type) if !@newTypes.include?(m.type)
    end
    if @newTypes.length==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    newType = @newTypes[@battle.pbRandom(@newTypes.length)]
    user.pbChangeTypes(newType)
    typeName = PBTypes.getName(newType)
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",user.pbThis,typeName))
  end
end



#===============================================================================
# Changes user's type to a random one that resists/is immune to the last move
# used by the target. (Conversion 2)
#===============================================================================
class PokeBattle_Move_05F < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end

  def pbMoveFailed?(user,targets)
    if !user.canChangeType?
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user,target)
    if target.lastMoveUsed<=0 ||
       target.lastMoveUsedType<0 ||
       PBTypes.isPseudoType?(pbGetMoveData(target.lastMoveUsed,MOVE_TYPE))
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    @newTypes = []
    for i in 0..PBTypes.maxValue
      next if PBTypes.isPseudoType?(i)
      next if user.pbHasType?(i)
      next if !PBTypes.resistant?(target.lastMoveUsedType,i)
      @newTypes.push(i)
    end
    if @newTypes.length==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    newType = @newTypes[@battle.pbRandom(@newTypes.length)]
    user.pbChangeTypes(newType)
    typeName = PBTypes.getName(newType)
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",user.pbThis,typeName))
  end
end



#===============================================================================
# Changes user's type depending on the environment. (Camouflage)
#===============================================================================
class PokeBattle_Move_060 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if !user.canChangeType?
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    @newType = getID(PBTypes,:NORMAL)
    checkedTerrain = false
    case @battle.field.terrain
    when PBBattleTerrains::Electric
      if hasConst?(PBTypes,:ELECTRIC)
        @newType = getID(PBTypes,:ELECTRIC); checkedTerrain = true
      end
    when PBBattleTerrains::Grassy
      if hasConst?(PBTypes,:GRASS)
        @newType = getID(PBTypes,:GRASS); checkedTerrain = true
      end
    when PBBattleTerrains::Misty
      if hasConst?(PBTypes,:FAIRY)
        @newType = getID(PBTypes,:FAIRY); checkedTerrain = true
      end
    when PBBattleTerrains::Psychic
      if hasConst?(PBTypes,:PSYCHIC)
        @newType = getID(PBTypes,:PSYCHIC); checkedTerrain = true
      end
    end
    if !checkedTerrain
      case @battle.environment
      when PBEnvironment::Grass;       @newType = getID(PBTypes,:GRASS)
      when PBEnvironment::TallGrass;   @newType = getID(PBTypes,:GRASS)
      when PBEnvironment::MovingWater; @newType = getID(PBTypes,:WATER)
      when PBEnvironment::StillWater;  @newType = getID(PBTypes,:WATER)
      when PBEnvironment::Puddle;      @newType = getID(PBTypes,:WATER)
      when PBEnvironment::Underwater;  @newType = getID(PBTypes,:WATER)
      when PBEnvironment::Cave;        @newType = getID(PBTypes,:ROCK)
      when PBEnvironment::Rock;        @newType = getID(PBTypes,:GROUND)
      when PBEnvironment::Sand;        @newType = getID(PBTypes,:GROUND)
      when PBEnvironment::Forest;      @newType = getID(PBTypes,:BUG)
      when PBEnvironment::ForestGrass; @newType = getID(PBTypes,:BUG)
      when PBEnvironment::Snow;        @newType = getID(PBTypes,:ICE)
      when PBEnvironment::Ice;         @newType = getID(PBTypes,:ICE)
      when PBEnvironment::Volcano;     @newType = getID(PBTypes,:FIRE)
      when PBEnvironment::Graveyard;   @newType = getID(PBTypes,:GHOST)
      when PBEnvironment::Sky;         @newType = getID(PBTypes,:FLYING)
      when PBEnvironment::Space;       @newType = getID(PBTypes,:DRAGON)
      when PBEnvironment::UltraSpace;  @newType = getID(PBTypes,:PSYCHIC)
      end
    end
    if !user.pbHasOtherType?(@newType)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.pbChangeTypes(@newType)
    typeName = PBTypes.getName(@newType)
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",user.pbThis,typeName))
  end
end



#===============================================================================
# Target becomes Water type. (Soak)
#===============================================================================
class PokeBattle_Move_061 < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    if !target.canChangeType? ||
       !target.pbHasOtherType?(getConst(PBTypes,:WATER))
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    newType = getConst(PBTypes,:WATER)
    user.pbChangeTypes(newType)
    typeName = PBTypes.getName(newType)
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",target.pbThis,typeName))
  end
end



#===============================================================================
# User copes target's types. (Reflect Type)
#===============================================================================
class PokeBattle_Move_062 < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end

  def pbMoveFailed?(user,targets)
    if !user.canChangeType?
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user,target)
    newTypes = target.pbTypes(true)
    if newTypes.length==0   # Target has no type to copy
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    if user.pbTypes==target.pbTypes &&
       user.effects[PBEffects::Type3]==target.effects[PBEffects::Type3]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    user.pbChangeTypes(target)
    @battle.pbDisplay(_INTL("{1}'s type changed to match {2}'s!",
       user.pbThis,target.pbThis(true)))
  end
end



#===============================================================================
# Target's ability becomes Simple. (Simple Beam)
#===============================================================================
class PokeBattle_Move_063 < PokeBattle_Move
  def initialize(battle,move)
    super
    @abilityBlacklist = [
       :TRUANT,
       # This ability
       :SIMPLE,
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
  end

  def pbMoveFailed?(user,targets)
    if !hasConst?(PBAbilities,:SIMPLE)   # Ability isn't defined
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user,target)
    @abilityBlacklist.each do |abil|
      next if !isConst?(target.ability,PBAbilities,abil)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    @battle.pbShowAbilitySplash(target,true,false)
    oldAbil = target.ability
    target.ability = getConst(PBAbilities,:SIMPLE)
    @battle.pbReplaceAbilitySplash(target)
    @battle.pbDisplay(_INTL("{1} acquired {2}!",target.pbThis,target.abilityName))
    @battle.pbHideAbilitySplash(target)
    target.pbOnAbilityChanged(oldAbil)
  end
end



#===============================================================================
# Target's ability becomes Insomnia. (Worry Seed)
#===============================================================================
class PokeBattle_Move_064 < PokeBattle_Move
  def initialize(battle,move)
    super
    @abilityBlacklist = [
       :TRUANT,
       # This ability
       :INSOMNIA,
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
  end

  def pbMoveFailed?(user,targets)
    if !hasConst?(PBAbilities,:INSOMNIA)   # Ability isn't defined
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user,target)
    @abilityBlacklist.each do |abil|
      next if !isConst?(target.ability,PBAbilities,abil)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    @battle.pbShowAbilitySplash(target,true,false)
    oldAbil = target.ability
    target.ability = getConst(PBAbilities,:INSOMNIA)
    @battle.pbReplaceAbilitySplash(target)
    @battle.pbDisplay(_INTL("{1} acquired {2}!",target.pbThis,target.abilityName))
    @battle.pbHideAbilitySplash(target)
    target.pbOnAbilityChanged(oldAbil)
  end
end



#===============================================================================
# User copies target's ability. (Role Play)
#===============================================================================
class PokeBattle_Move_065 < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end

  def initialize(battle,move)
    super
    @abilityBlacklistUnlosable = [
       # Form-changing abilities
       :BATTLEBOND,
       :DISGUISE,
#       :FLOWERGIFT,                                          # This can be lost
#       :FORECAST,                                            # This can be lost
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
    @abilityBlacklistUngainable = [
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
  end

  def pbMoveFailed?(user,targets)
    @abilityBlacklistUnlosable.each do |abil|
      next if !isConst?(user.ability,PBAbilities,abil)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user,target)
    if target.ability==0 || user.ability==target.ability
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    @abilityBlacklistUngainable.each do |abil|
      next if !isConst?(target.ability,PBAbilities,abil)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    @battle.pbShowAbilitySplash(user,true,false)
    oldAbil = user.ability
    user.ability = target.ability
    @battle.pbReplaceAbilitySplash(user)
    @battle.pbDisplay(_INTL("{1} copied {2}'s {3}!",
       user.pbThis,target.pbThis(true),target.abilityName))
    @battle.pbHideAbilitySplash(user)
    user.pbOnAbilityChanged(oldAbil)
    user.pbEffectsOnSwitchIn
  end
end



#===============================================================================
# Target copies user's ability. (Entrainment)
#===============================================================================
class PokeBattle_Move_066 < PokeBattle_Move
  def initialize(battle,move)
    super
    @abilityBlacklistUnlosable = [
       :TRUANT,
       # Form-changing abilities
       :BATTLEBOND,
       :DISGUISE,
#       :FLOWERGIFT,                                          # This can be lost
#       :FORECAST,                                            # This can be lost
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
    @abilityBlacklistUngainable = [
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
       # Abilities that are plain old blocked.
       :NEUTRALIZINGGAS
    ]
  end

  def pbMoveFailed?(user,targets)
    if user.ability==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    @abilityBlacklistUngainable.each do |abil|
      next if !isConst?(user.ability,PBAbilities,abil)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user,target)
    @abilityBlacklistUnlosable.each do |abil|
      next if !isConst?(target.ability,PBAbilities,abil)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    @battle.pbShowAbilitySplash(target,true,false)
    oldAbil = target.ability
    target.ability = user.ability
    @battle.pbReplaceAbilitySplash(target)
    @battle.pbDisplay(_INTL("{1} acquired {2}!",target.pbThis,target.abilityName))
    @battle.pbHideAbilitySplash(target)
    target.pbOnAbilityChanged(oldAbil)
    target.pbEffectsOnSwitchIn
  end
end



#===============================================================================
# User and target swap abilities. (Skill Swap)
#===============================================================================
class PokeBattle_Move_067 < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end

  def initialize(battle,move)
    super
    @abilityBlacklistUnlosable = [
       # Form-changing abilities
       :BATTLEBOND,
       :DISGUISE,
#       :FLOWERGIFT,                                          # This can be lost
#       :FORECAST,                                            # This can be lost
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
       :GULPMISSILE,
       # Abilities that are plain old blocked.
       :NEUTRALIZINGGAS
    ]
    @abilityBlacklistUngainable = [
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
  end

  def pbMoveFailed?(user,targets)
    if user.ability==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    @abilityBlacklistUnlosable.each do |abil|
      next if !isConst?(user.ability,PBAbilities,abil)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    @abilityBlacklistUngainable.each do |abil|
      next if !isConst?(user.ability,PBAbilities,abil)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user,target)
    if target.ability==0 ||
       (user.ability==target.ability && !NEWEST_BATTLE_MECHANICS)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    @abilityBlacklistUnlosable.each do |abil|
      next if !isConst?(target.ability,PBAbilities,abil)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    @abilityBlacklistUngainable.each do |abil|
      next if !isConst?(target.ability,PBAbilities,abil)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    if user.opposes?(target)
      @battle.pbShowAbilitySplash(user,false,false)
      @battle.pbShowAbilitySplash(target,true,false)
    end
    oldUserAbil   = user.ability
    oldTargetAbil = target.ability
    user.ability   = oldTargetAbil
    target.ability = oldUserAbil
    if user.opposes?(target)
      @battle.pbReplaceAbilitySplash(user)
      @battle.pbReplaceAbilitySplash(target)
    end
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      @battle.pbDisplay(_INTL("{1} swapped Abilities with its target!",user.pbThis))
    else
      @battle.pbDisplay(_INTL("{1} swapped its {2} Ability with its target's {3} Ability!",
         user.pbThis,target.abilityName,user.abilityName))
    end
    if user.opposes?(target)
      @battle.pbHideAbilitySplash(user)
      @battle.pbHideAbilitySplash(target)
    end
    user.pbOnAbilityChanged(oldUserAbil)
    target.pbOnAbilityChanged(oldTargetAbil)
    user.pbEffectsOnSwitchIn
    target.pbEffectsOnSwitchIn
  end
end



#===============================================================================
# Target's ability is negated. (Gastro Acid)
#===============================================================================
class PokeBattle_Move_068 < PokeBattle_Move
  def initialize(battle,move)
    super
    @abilityBlacklist = [
       # Form-changing abilities
       :BATTLEBOND,
       :DISGUISE,
#       :FLOWERGIFT,                                       # This can be negated
#       :FORECAST,                                         # This can be negated
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
  end

  def pbFailsAgainstTarget?(user,target)
    @abilityBlacklist.each do |abil|
      next if !isConst?(target.ability,PBAbilities,abil)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    target.effects[PBEffects::GastroAcid] = true
    target.effects[PBEffects::Truant]     = false
    @battle.pbDisplay(_INTL("{1}'s Ability was suppressed!",target.pbThis))
    target.pbOnAbilityChanged(target.ability)
  end
end



#===============================================================================
# User transforms into the target. (Transform)
#===============================================================================
class PokeBattle_Move_069 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if user.effects[PBEffects::Transform]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user,target)
    if target.effects[PBEffects::Transform] ||
       target.effects[PBEffects::Illusion]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    user.pbTransform(target)
  end

  def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
    super
    @battle.scene.pbChangePokemon(user,targets[0].pokemon)
  end
end



#===============================================================================
# Inflicts a fixed 20HP damage. (Sonic Boom)
#===============================================================================
class PokeBattle_Move_06A < PokeBattle_FixedDamageMove
  def pbFixedDamage(user,target)
    return 20
  end
end



#===============================================================================
# Inflicts a fixed 40HP damage. (Dragon Rage)
#===============================================================================
class PokeBattle_Move_06B < PokeBattle_FixedDamageMove
  def pbFixedDamage(user,target)
    return 40
  end
end



#===============================================================================
# Halves the target's current HP. (Nature's Madness, Super Fang)
#===============================================================================
class PokeBattle_Move_06C < PokeBattle_FixedDamageMove
  def pbFixedDamage(user,target)
    return (target.hp/2.0).round
  end
end



#===============================================================================
# Inflicts damage equal to the user's level. (Night Shade, Seismic Toss)
#===============================================================================
class PokeBattle_Move_06D < PokeBattle_FixedDamageMove
  def pbFixedDamage(user,target)
    return user.level
  end
end



#===============================================================================
# Inflicts damage to bring the target's HP down to equal the user's HP. (Endeavor)
#===============================================================================
class PokeBattle_Move_06E < PokeBattle_FixedDamageMove
  def pbFailsAgainstTarget?(user,target)
    if user.hp>=target.hp
      @battle.pbDisplay(_INTL("But it failed!"))
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
# Inflicts damage between 0.5 and 1.5 times the user's level. (Psywave)
#===============================================================================
class PokeBattle_Move_06F < PokeBattle_FixedDamageMove
  def pbFixedDamage(user,target)
    min = (user.level/2).floor
    max = (user.level*3/2).floor
    return min+@battle.pbRandom(max-min+1)
  end
end



#===============================================================================
# OHKO. Accuracy increases by difference between levels of user and target.
#===============================================================================
class PokeBattle_Move_070 < PokeBattle_FixedDamageMove
  def hitsDiggingTargets?; return isConst?(@id,PBMoves,:FISSURE); end

  def pbFailsAgainstTarget?(user,target)
    if target.level>user.level
      @battle.pbDisplay(_INTL("{1} is unaffected!",target.pbThis))
      return true
    end
    if target.hasActiveAbility?(:STURDY) && !@battle.moldBreaker
      @battle.pbShowAbilitySplash(target)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        @battle.pbDisplay(_INTL("But it failed to affect {1}!",target.pbThis(true)))
      else
        @battle.pbDisplay(_INTL("But it failed to affect {1} because of its {2}!",
           target.pbThis(true),target.abilityName))
      end
      @battle.pbHideAbilitySplash(target)
      return true
    end
    if NEWEST_BATTLE_MECHANICS &&
       isConst?(target.damageState.typeMod,PBTypes,:ICE) && target.pbHasType?(:ICE)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbAccuracyCheck(user,target)
    acc = @accuracy+user.level-target.level
    acc -= 10 if NEWEST_BATTLE_MECHANICS && isConst?(@id,PBMoves,:SHEERCOLD) &&
                                            !user.pbHasType?(:ICE)
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
# Counters a physical move used against the user this round, with 2x the power.
# (Counter)
#===============================================================================
class PokeBattle_Move_071 < PokeBattle_FixedDamageMove
  def pbAddTarget(targets,user)
    t = user.effects[PBEffects::CounterTarget]
    return if t<0 || !user.opposes?(t)
    user.pbAddTarget(targets,user,@battle.battlers[t],self,false)
  end

  def pbMoveFailed?(user,targets)
    if targets.length==0
      @battle.pbDisplay(_INTL("But there was no target..."))
      return true
    end
    return false
  end

  def pbFixedDamage(user,target)
    dmg = user.effects[PBEffects::Counter]*2
    dmg = 1 if dmg==0
    return dmg
  end
end



#===============================================================================
# Counters a specical move used against the user this round, with 2x the power.
# (Mirror Coat)
#===============================================================================
class PokeBattle_Move_072 < PokeBattle_FixedDamageMove
  def pbAddTarget(targets,user)
    t = user.effects[PBEffects::MirrorCoatTarget]
    return if t<0 || !user.opposes?(t)
    user.pbAddTarget(targets,user,@battle.battlers[t],self,false)
  end

  def pbMoveFailed?(user,targets)
    if targets.length==0
      @battle.pbDisplay(_INTL("But there was no target..."))
      return true
    end
    return false
  end

  def pbFixedDamage(user,target)
    dmg = user.effects[PBEffects::MirrorCoat]*2
    dmg = 1 if dmg==0
    return dmg
  end
end



#===============================================================================
# Counters the last damaging move used against the user this round, with 1.5x
# the power. (Metal Burst)
#===============================================================================
class PokeBattle_Move_073 < PokeBattle_FixedDamageMove
  def pbAddTarget(targets,user)
    return if user.lastFoeAttacker.length==0
    lastAttacker = user.lastFoeAttacker[user.lastFoeAttacker.last]
    return if lastAttacker<0 || !user.opposes?(lastAttacker)
    user.pbAddTarget(targets,user,@battle.battlers[lastAttacker],self,false)
  end

  def pbMoveFailed?(user,targets)
    if targets.length==0
      @battle.pbDisplay(_INTL("But there was no target..."))
      return true
    end
    return false
  end

  def pbFixedDamage(user,target)
    dmg = (user.lastHPLostFromFoe*1.5).floor
    dmg = 1 if dmg==0
    return dmg
  end
end



#===============================================================================
# The target's ally loses 1/16 of its max HP. (Flame Burst)
#===============================================================================
class PokeBattle_Move_074 < PokeBattle_Move
  def pbEffectWhenDealingDamage(user,target)
    hitAlly = []
    target.eachAlly do |b|
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
    switchedAlly = []
    hitAlly.each do |b|
      @battle.battlers[b[0]].pbItemHPHealCheck
      if @battle.battlers[b[0]].pbAbilitiesOnDamageTaken(b[1])
        switchedAlly.push(@battle.battlers[b[0]])
      end
    end
    switchedAlly.each { |b| b.pbEffectsOnSwitchIn(true) }
  end
end



#===============================================================================
# Power is doubled if the target is using Dive. Hits some semi-invulnerable
# targets. (Surf)
#===============================================================================
class PokeBattle_Move_075 < PokeBattle_Move
  def hitsDivingTargets?; return true; end

  def pbModifyDamage(damageMult,user,target)
    damageMult *= 2 if target.inTwoTurnAttack?("0CB")   # Dive
    return damageMult
  end

  def pbEffectAfterAllHits(user,target)
    if isConst?(user.species,PBSpecies,:CRAMORANT) &&
      user.hasActiveAbility?(:GULPMISSILE) && user.form==0
      user.form=2
      user.form=1 if user.hp>(user.totalhp/2)
      @battle.scene.pbChangePokemon(user,user.pokemon)
    end
  end
end



#===============================================================================
# Power is doubled if the target is using Dig. Power is halved if Grassy Terrain
# is in effect. Hits some semi-invulnerable targets. (Earthquake)
#===============================================================================
class PokeBattle_Move_076 < PokeBattle_Move
  def hitsDiggingTargets?; return true; end

  def pbModifyDamage(damageMult,user,target)
    damageMult *= 2 if target.inTwoTurnAttack?("0CA")   # Dig
    damageMult = (damageMult/2.0).round if @battle.field.terrain==PBBattleTerrains::Grassy
    return damageMult
  end
end



#===============================================================================
# Power is doubled if the target is using Bounce, Fly or Sky Drop. Hits some
# semi-invulnerable targets. (Gust)
#===============================================================================
class PokeBattle_Move_077 < PokeBattle_Move
  def hitsFlyingTargets?; return true; end

  def pbBaseDamage(baseDmg,user,target)
    baseDmg *= 2 if target.inTwoTurnAttack?("0C9","0CC","0CE") ||  # Fly/Bounce/Sky Drop
                    target.effects[PBEffects::SkyDrop]>=0
    return baseDmg
  end
end



#===============================================================================
# Power is doubled if the target is using Bounce, Fly or Sky Drop. Hits some
# semi-invulnerable targets. May make the target flinch. (Twister)
#===============================================================================
class PokeBattle_Move_078 < PokeBattle_FlinchMove
  def hitsFlyingTargets?; return true; end

  def pbBaseDamage(baseDmg,user,target)
    baseDmg *= 2 if target.inTwoTurnAttack?("0C9","0CC","0CE") ||  # Fly/Bounce/Sky Drop
                    target.effects[PBEffects::SkyDrop]>=0
    return baseDmg
  end
end



#===============================================================================
# Power is doubled if Fusion Flare has already been used this round. (Fusion Bolt)
#===============================================================================
class PokeBattle_Move_079 < PokeBattle_Move
  def pbChangeUsageCounters(user,specialUsage)
    @doublePower = @battle.field.effects[PBEffects::FusionFlare]
    super
  end

  def pbBaseDamageMultiplier(damageMult,user,target)
    damageMult *= 2 if @doublePower
    return damageMult
  end

  def pbEffectGeneral(user)
    @battle.field.effects[PBEffects::FusionBolt] = true
  end

  def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
    hitNum = 1 if (targets.length>0 && targets[0].damageState.critical) ||
                  @doublePower   # Charged anim
    super
  end
end



#===============================================================================
# Power is doubled if Fusion Bolt has already been used this round. (Fusion Flare)
#===============================================================================
class PokeBattle_Move_07A < PokeBattle_Move
  def pbChangeUsageCounters(user,specialUsage)
    @doublePower = @battle.field.effects[PBEffects::FusionBolt]
    super
  end

  def pbBaseDamageMultiplier(damageMult,user,target)
    damageMult *= 2 if @doublePower
    return damageMult
  end

  def pbEffectGeneral(user)
    @battle.field.effects[PBEffects::FusionFlare] = true
  end

  def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
    hitNum = 1 if (targets.length>0 && targets[0].damageState.critical) ||
                  @doublePower   # Charged anim
    super
  end
end



#===============================================================================
# Power is doubled if the target is poisoned. (Venoshock)
#===============================================================================
class PokeBattle_Move_07B < PokeBattle_Move
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
class PokeBattle_Move_07C < PokeBattle_Move
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
    return if target.status!=PBStatuses::PARALYSIS
    target.pbCureStatus
  end
end



#===============================================================================
# Power is doubled if the target is asleep. Wakes the target up. (Wake-Up Slap)
#===============================================================================
class PokeBattle_Move_07D < PokeBattle_Move
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
    return if target.status!=PBStatuses::SLEEP
    target.pbCureStatus
  end
end



#===============================================================================
# Power is doubled if the user is burned, poisoned or paralyzed. (Facade)
# Burn's halving of Attack is negated (new mechanics).
#===============================================================================
class PokeBattle_Move_07E < PokeBattle_Move
  def damageReducedByBurn?; return !NEWEST_BATTLE_MECHANICS; end

  def pbBaseDamage(baseDmg,user,target)
    baseDmg *= 2 if user.poisoned? || user.burned? || user.paralyzed?
    return baseDmg
  end
end



#===============================================================================
# Power is doubled if the target has a status problem. (Hex)
#===============================================================================
class PokeBattle_Move_07F < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    if target.pbHasAnyStatus? &&
       (target.effects[PBEffects::Substitute]==0 || ignoresSubstitute?(user))
      baseDmg *= 2
    end
    return baseDmg
  end
end
