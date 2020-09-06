class PokeBattle_Battler
  #=============================================================================
  # Generalised checks for whether a status problem can be inflicted
  #=============================================================================
  # NOTE: Not all "does it have this status?" checks use this method. If the
  #       check is leading up to curing self of that status condition, then it
  #       will look at the value of @status directly instead - if it is that
  #       PBStatuses value then it is curable. This method only checks for
  #       "counts as having that status", which includes Comatose which can't be
  #       cured.
  def pbHasStatus?(checkStatus)
    if BattleHandlers.triggerStatusCheckAbilityNonIgnorable(@ability,self,checkStatus)
      return true
    end
    return @status==checkStatus
  end

  def pbHasAnyStatus?
    if BattleHandlers.triggerStatusCheckAbilityNonIgnorable(@ability,self,nil)
      return true
    end
    return @status!=PBStatuses::NONE
  end

  def pbCanInflictStatus?(newStatus,user,showMessages,move=nil,ignoreStatus=false)
    return false if fainted?
    selfInflicted = (user && user.index==@index)
    # Already have that status problem
    if self.status==newStatus && !ignoreStatus
      if showMessages
        msg = ""
        case self.status
        when PBStatuses::SLEEP;     msg = _INTL("{1} is already asleep!",pbThis)
        when PBStatuses::POISON;    msg = _INTL("{1} is already poisoned!",pbThis)
        when PBStatuses::BURN;      msg = _INTL("{1} already has a burn!",pbThis)
        when PBStatuses::PARALYSIS; msg = _INTL("{1} is already paralyzed!",pbThis)
        when PBStatuses::FROZEN;    msg = _INTL("{1} is already frozen solid!",pbThis)
        end
        @battle.pbDisplay(msg)
      end
      return false
    end
    # Trying to replace a status problem with another one
    if self.status!=PBStatuses::NONE && !ignoreStatus && !selfInflicted
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      return false
    end
    # Trying to inflict a status problem on a Pokémon behind a substitute
    if @effects[PBEffects::Substitute]>0 && !(move && move.ignoresSubstitute?(user)) &&
       !selfInflicted
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      return false
    end
    # Weather immunity
    if newStatus==PBStatuses::FROZEN &&
       (@battle.pbWeather==PBWeather::Sun || @battle.pbWeather==PBWeather::HarshSun)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      return false
    end
    # Terrains immunity
    if affectedByTerrain?
      case @battle.field.terrain
      when PBBattleTerrains::Electric
        if newStatus==PBStatuses::SLEEP
          @battle.pbDisplay(_INTL("{1} surrounds itself with electrified terrain!",
             pbThis(true))) if showMessages
          return false
        end
      when PBBattleTerrains::Misty
        @battle.pbDisplay(_INTL("{1} surrounds itself with misty terrain!",pbThis(true))) if showMessages
        return false
      end
    end
    # Uproar immunity
    if newStatus==PBStatuses::SLEEP &&
       !(hasActiveAbility?(:SOUNDPROOF) && !@battle.moldBreaker)
      @battle.eachBattler do |b|
        next if b.effects[PBEffects::Uproar]==0
        @battle.pbDisplay(_INTL("But the uproar kept {1} awake!",pbThis(true))) if showMessages
        return false
      end
    end
    # Type immunities
    hasImmuneType = false
    case newStatus
    when PBStatuses::SLEEP
      # No type is immune to sleep
    when PBStatuses::POISON
      if !(user && user.hasActiveAbility?(:CORROSION))
        hasImmuneType |= pbHasType?(:POISON)
        hasImmuneType |= pbHasType?(:STEEL)
      end
    when PBStatuses::BURN
      hasImmuneType |= pbHasType?(:FIRE)
    when PBStatuses::PARALYSIS
      hasImmuneType |= pbHasType?(:ELECTRIC) && NEWEST_BATTLE_MECHANICS
    when PBStatuses::FROZEN
      hasImmuneType |= pbHasType?(:ICE)
    end
    if hasImmuneType
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      return false
    end
    # Ability immunity
    immuneByAbility = false; immAlly = nil
    if BattleHandlers.triggerStatusImmunityAbilityNonIgnorable(@ability,self,newStatus)
      immuneByAbility = true
    elsif selfInflicted || !@battle.moldBreaker
      if abilityActive? && BattleHandlers.triggerStatusImmunityAbility(@ability,self,newStatus)
        immuneByAbility = true
      else
        eachAlly do |b|
          next if !b.abilityActive?
          next if !BattleHandlers.triggerStatusImmunityAllyAbility(b.ability,self,newStatus)
          immuneByAbility = true
          immAlly = b
          break
        end
      end
    end
    if immuneByAbility
      if showMessages
        @battle.pbShowAbilitySplash(immAlly || self)
        msg = ""
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          case newStatus
          when PBStatuses::SLEEP;     msg = _INTL("{1} stays awake!",pbThis)
          when PBStatuses::POISON;    msg = _INTL("{1} cannot be poisoned!",pbThis)
          when PBStatuses::BURN;      msg = _INTL("{1} cannot be burned!",pbThis)
          when PBStatuses::PARALYSIS; msg = _INTL("{1} cannot be paralyzed!",pbThis)
          when PBStatuses::FROZEN;    msg = _INTL("{1} cannot be frozen solid!",pbThis)
          end
        elsif immAlly
          case newStatus
          when PBStatuses::SLEEP
            msg = _INTL("{1} stays awake because of {2}'s {3}!",
               pbThis,immAlly.pbThis(true),immAlly.abilityName)
          when PBStatuses::POISON
            msg = _INTL("{1} cannot be poisoned because of {2}'s {3}!",
               pbThis,immAlly.pbThis(true),immAlly.abilityName)
          when PBStatuses::BURN
            msg = _INTL("{1} cannot be burned because of {2}'s {3}!",
               pbThis,immAlly.pbThis(true),immAlly.abilityName)
          when PBStatuses::PARALYSIS
            msg = _INTL("{1} cannot be paralyzed because of {2}'s {3}!",
               pbThis,immAlly.pbThis(true),immAlly.abilityName)
          when PBStatuses::FROZEN
            msg = _INTL("{1} cannot be frozen solid because of {2}'s {3}!",
               pbThis,immAlly.pbThis(true),immAlly.abilityName)
          end
        else
          case newStatus
          when PBStatuses::SLEEP;     msg = _INTL("{1} stays awake because of its {2}!",pbThis,abilityName)
          when PBStatuses::POISON;    msg = _INTL("{1}'s {2} prevents poisoning!",pbThis,abilityName)
          when PBStatuses::BURN;      msg = _INTL("{1}'s {2} prevents burns!",pbThis,abilityName)
          when PBStatuses::PARALYSIS; msg = _INTL("{1}'s {2} prevents paralysis!",pbThis,abilityName)
          when PBStatuses::FROZEN;    msg = _INTL("{1}'s {2} prevents freezing!",pbThis,abilityName)
          end
        end
        @battle.pbDisplay(msg)
        @battle.pbHideAbilitySplash(immAlly || self)
      end
      return false
    end
    # Safeguard immunity
    if pbOwnSide.effects[PBEffects::Safeguard]>0 && !selfInflicted && move &&
       !(user && user.hasActiveAbility?(:INFILTRATOR))
      @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanSynchronizeStatus?(status,target)
    return false if fainted?
    # Trying to replace a status problem with another one
    return false if self.status!=PBStatuses::NONE
    # Terrain immunity
    return false if @battle.field.terrain==PBBattleTerrains::Misty && affectedByTerrain?
    # Type immunities
    hasImmuneType = false
    case self.status
    when PBStatuses::POISON
      # NOTE: target will have Synchronize, so it can't have Corrosion.
      if !(target && target.hasActiveAbility?(:CORROSION))
        hasImmuneType |= pbHasType?(:POISON)
        hasImmuneType |= pbHasType?(:STEEL)
      end
    when PBStatuses::BURN
      hasImmuneType |= pbHasType?(:FIRE)
    when PBStatuses::PARALYSIS
      hasImmuneType |= pbHasType?(:ELECTRIC) && NEWEST_BATTLE_MECHANICS
    end
    return false if hasImmuneType
    # Ability immunity
    if BattleHandlers.triggerStatusImmunityAbilityNonIgnorable(@ability,self,status)
      return false
    end
    if abilityActive? && BattleHandlers.triggerStatusImmunityAbility(@ability,self,status)
      return false
    end
    eachAlly do |b|
      next if !b.abilityActive?
      next if !BattleHandlers.triggerStatusImmunityAllyAbility(b.ability,self,status)
      return false
    end
    # Safeguard immunity
    if pbOwnSide.effects[PBEffects::Safeguard]>0 &&
       !(user && user.hasActiveAbility?(:INFILTRATOR))
      return false
    end
    return true
  end

  #=============================================================================
  # Generalised infliction of status problem
  #=============================================================================
  def pbInflictStatus(newStatus,newStatusCount=0,msg=nil,user=nil)
    # Inflict the new status
    self.status      = newStatus
    self.statusCount = newStatusCount
    @effects[PBEffects::Toxic] = 0
    # Record status change in debug log, generate default message, show animation
    case newStatus
    when PBStatuses::SLEEP
      @battle.pbCommonAnimation("Sleep",self)
      msg = _INTL("{1} fell asleep!",pbThis) if !msg || msg==""
    when PBStatuses::POISON
      if newStatusCount>0
        @battle.pbCommonAnimation("Toxic",self)
        msg = _INTL("{1} was badly poisoned!",pbThis) if !msg || msg==""
      else
        @battle.pbCommonAnimation("Poison",self)
        msg = _INTL("{1} was poisoned!",pbThis) if !msg || msg==""
      end
    when PBStatuses::BURN
      @battle.pbCommonAnimation("Burn",self)
      msg = _INTL("{1} was burned!",pbThis) if !msg || msg==""
    when PBStatuses::PARALYSIS
      @battle.pbCommonAnimation("Paralysis",self)
      msg = _INTL("{1} is paralyzed! It may be unable to move!",pbThis) if !msg || msg==""
    when PBStatuses::FROZEN
      @battle.pbCommonAnimation("Frozen",self)
      msg = _INTL("{1} was frozen solid!",pbThis) if !msg || msg==""
    end
    # Show message
    @battle.pbDisplay(msg) if msg && msg!=""
    PBDebug.log("[Status change] #{pbThis}'s sleep count is #{newStatusCount}") if newStatus==PBStatuses::SLEEP
    pbCheckFormOnStatusChange
    # Synchronize
    if abilityActive?
      BattleHandlers.triggerAbilityOnStatusInflicted(@ability,self,user,newStatus)
    end
    # Status cures
    pbItemStatusCureCheck
    pbAbilityStatusCureCheck
    # Petal Dance/Outrage/Thrash get cancelled immediately by falling asleep
    # NOTE: I don't know why this applies only to Outrage and only to falling
    #       asleep (i.e. it doesn't cancel Rollout/Uproar/other multi-turn
    #       moves, and it doesn't cancel any moves if self becomes frozen/
    #       disabled/anything else). This behaviour was tested in Gen 5.
    if @status==PBStatuses::SLEEP && @effects[PBEffects::Outrage]>0
      @effects[PBEffects::Outrage] = 0
      @currentMove = 0
    end
  end

  #=============================================================================
  # Sleep
  #=============================================================================
  def asleep?
    return pbHasStatus?(PBStatuses::SLEEP)
  end

  def pbCanSleep?(user,showMessages,move=nil,ignoreStatus=false)
    return pbCanInflictStatus?(PBStatuses::SLEEP,user,showMessages,move,ignoreStatus)
  end

  def pbCanSleepYawn?
    return false if self.status!=PBStatuses::NONE
    if affectedByTerrain?
      return false if @battle.field.terrain==PBBattleTerrains::Electric
      return false if @battle.field.terrain==PBBattleTerrains::Misty
    end
    if !hasActiveAbility?(:SOUNDPROOF)
      @battle.eachBattler do |b|
        return false if b.effects[PBEffects::Uproar]>0
      end
    end
    if BattleHandlers.triggerStatusImmunityAbilityNonIgnorable(@ability,self,PBStatuses::SLEEP)
      return false
    end
    # NOTE: Bulbapedia claims that Flower Veil shouldn't prevent sleep due to
    #       drowsiness, but I disagree because that makes no sense. Also, the
    #       comparable Sweet Veil does prevent sleep due to drowsiness.
    if abilityActive? && BattleHandlers.triggerStatusImmunityAbility(@ability,self,PBStatuses::SLEEP)
      return false
    end
    eachAlly do |b|
      next if !b.abilityActive?
      next if !BattleHandlers.triggerStatusImmunityAllyAbility(b.ability,self,PBStatuses::SLEEP)
      return false
    end
    # NOTE: Bulbapedia claims that Safeguard shouldn't prevent sleep due to
    #       drowsiness. I disagree with this too. Compare with the other sided
    #       effects Misty/Electric Terrain, which do prevent it.
    return false if pbOwnSide.effects[PBEffects::Safeguard]>0
    return true
  end

  def pbSleep(msg=nil)
    pbInflictStatus(PBStatuses::SLEEP,pbSleepDuration,msg)
  end

  def pbSleepSelf(msg=nil,duration=-1)
    pbInflictStatus(PBStatuses::SLEEP,pbSleepDuration(duration),msg)
  end

  def pbSleepDuration(duration=-1)
    duration = 2+@battle.pbRandom(3) if duration<=0
    duration = (duration/2).floor if hasActiveAbility?(:EARLYBIRD)
    return duration
  end

  #=============================================================================
  # Poison
  #=============================================================================
  def poisoned?
    return pbHasStatus?(PBStatuses::POISON)
  end

  def pbCanPoison?(user,showMessages,move=nil)
    return pbCanInflictStatus?(PBStatuses::POISON,user,showMessages,move)
  end

  def pbCanPoisonSynchronize?(target)
    return pbCanSynchronizeStatus?(PBStatuses::POISON,target)
  end

  def pbPoison(user=nil,msg=nil,toxic=false)
    pbInflictStatus(PBStatuses::POISON,(toxic) ? 1 : 0,msg,user)
  end

  #=============================================================================
  # Burn
  #=============================================================================
  def burned?
    return pbHasStatus?(PBStatuses::BURN)
  end

  def pbCanBurn?(user,showMessages,move=nil)
    return pbCanInflictStatus?(PBStatuses::BURN,user,showMessages,move)
  end

  def pbCanBurnSynchronize?(target)
    return pbCanSynchronizeStatus?(PBStatuses::BURN,target)
  end

  def pbBurn(user=nil,msg=nil)
    pbInflictStatus(PBStatuses::BURN,0,msg,user)
  end

  #=============================================================================
  # Paralyze
  #=============================================================================
  def paralyzed?
    return pbHasStatus?(PBStatuses::PARALYSIS)
  end

  def pbCanParalyze?(user,showMessages,move=nil)
    return pbCanInflictStatus?(PBStatuses::PARALYSIS,user,showMessages,move)
  end

  def pbCanParalyzeSynchronize?(target)
    return pbCanSynchronizeStatus?(PBStatuses::PARALYSIS,target)
  end

  def pbParalyze(user=nil,msg=nil)
    pbInflictStatus(PBStatuses::PARALYSIS,0,msg,user)
  end

  #=============================================================================
  # Freeze
  #=============================================================================
  def frozen?
    return pbHasStatus?(PBStatuses::FROZEN)
  end

  def pbCanFreeze?(user,showMessages,move=nil)
    return pbCanInflictStatus?(PBStatuses::FROZEN,user,showMessages,move)
  end

  def pbFreeze(msg=nil)
    pbInflictStatus(PBStatuses::FROZEN,0,msg)
  end

  #=============================================================================
  # Generalised status displays
  #=============================================================================
  def pbContinueStatus
    anim = ""; msg = ""
    case self.status
    when PBStatuses::SLEEP
      anim = "Sleep";     msg = _INTL("{1} is fast asleep.",pbThis)
    when PBStatuses::POISON
      anim = (@statusCount>0) ? "Toxic" : "Poison"
      msg = _INTL("{1} was hurt by poison!",pbThis)
    when PBStatuses::BURN
      anim = "Burn";      msg = _INTL("{1} was hurt by its burn!",pbThis)
    when PBStatuses::PARALYSIS
      anim = "Paralysis"; msg = _INTL("{1} is paralyzed! It can't move!",pbThis)
    when PBStatuses::FROZEN
      anim = "Frozen";    msg = _INTL("{1} is frozen solid!",pbThis)
    end
    @battle.pbCommonAnimation(anim,self) if anim!=""
    yield if block_given?
    @battle.pbDisplay(msg) if msg!=""
    PBDebug.log("[Status continues] #{pbThis}'s sleep count is #{@statusCount}") if self.status==PBStatuses::SLEEP
  end

  def pbCureStatus(showMessages=true)
    oldStatus = status
    self.status = PBStatuses::NONE
    if showMessages
      case oldStatus
      when PBStatuses::SLEEP;     @battle.pbDisplay(_INTL("{1} woke up!",pbThis))
      when PBStatuses::POISON;    @battle.pbDisplay(_INTL("{1} was cured of its poisoning.",pbThis))
      when PBStatuses::BURN;      @battle.pbDisplay(_INTL("{1}'s burn was healed.",pbThis))
      when PBStatuses::PARALYSIS; @battle.pbDisplay(_INTL("{1} was cured of paralysis.",pbThis))
      when PBStatuses::FROZEN;    @battle.pbDisplay(_INTL("{1} thawed out!",pbThis))
      end
    end
    PBDebug.log("[Status change] #{pbThis}'s status was cured") if !showMessages
  end

  #=============================================================================
  # Confusion
  #=============================================================================
  def pbCanConfuse?(user=nil,showMessages=true,move=nil,selfInflicted=false)
    return false if fainted?
    if @effects[PBEffects::Confusion]>0
      @battle.pbDisplay(_INTL("{1} is already confused.",pbThis)) if showMessages
      return false
    end
    if @effects[PBEffects::Substitute]>0 && !(move && move.ignoresSubstitute?(user)) &&
       !selfInflicted
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    # Terrains immunity
    if affectedByTerrain? && @battle.field.terrain==PBBattleTerrains::Misty
      @battle.pbDisplay(_INTL("{1} surrounds itself with misty terrain!",pbThis(true))) if showMessages
      return false
    end
    if selfInflicted || !@battle.moldBreaker
      if hasActiveAbility?(:OWNTEMPO)
        if showMessages
          @battle.pbShowAbilitySplash(self)
          if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            @battle.pbDisplay(_INTL("{1} doesn't become confused!",pbThis))
          else
            @battle.pbDisplay(_INTL("{1}'s {2} prevents confusion!",pbThis,abilityName))
          end
          @battle.pbHideAbilitySplash(self)
        end
        return false
      end
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 && !selfInflicted &&
       !(user && user.hasActiveAbility?(:INFILTRATOR))
      @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanConfuseSelf?(showMessages)
    return pbCanConfuse?(nil,showMessages,nil,true)
  end

  def pbConfuse(msg=nil)
    @effects[PBEffects::Confusion] = pbConfusionDuration
    @battle.pbCommonAnimation("Confusion",self)
    msg = _INTL("{1} became confused!",pbThis) if !msg || msg==""
    @battle.pbDisplay(msg)
    PBDebug.log("[Lingering effect] #{pbThis}'s confusion count is #{@effects[PBEffects::Confusion]}")
    # Confusion cures
    pbItemStatusCureCheck
    pbAbilityStatusCureCheck
  end

  def pbConfusionDuration(duration=-1)
    duration = 2+@battle.pbRandom(4) if duration<=0
    return duration
  end

  def pbCureConfusion
    @effects[PBEffects::Confusion] = 0
  end

  #=============================================================================
  # Attraction
  #=============================================================================
  def pbCanAttract?(user,showMessages=true)
    return false if fainted?
    return false if !user || user.fainted?
    if @effects[PBEffects::Attract]>=0
      @battle.pbDisplay(_INTL("{1} is unaffected!",pbThis)) if showMessages
      return false
    end
    agender = user.gender
    ogender = gender
    if agender==2 || ogender==2 || agender==ogender
      @battle.pbDisplay(_INTL("{1} is unaffected!",pbThis)) if showMessages
      return false
    end
    if !@battle.moldBreaker
      if hasActiveAbility?([:AROMAVEIL,:OBLIVIOUS])
        if showMessages
          @battle.pbShowAbilitySplash(self)
          if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            @battle.pbDisplay(_INTL("{1} is unaffected!",pbThis))
          else
            @battle.pbDisplay(_INTL("{1}'s {2} prevents romance!",pbThis,abilityName))
          end
          @battle.pbHideAbilitySplash(self)
        end
        return false
      else
        eachAlly do |b|
          next if !b.hasActiveAbility?(:AROMAVEIL)
          if showMessages
            @battle.pbShowAbilitySplash(self)
            if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
              @battle.pbDisplay(_INTL("{1} is unaffected!",pbThis))
            else
              @battle.pbDisplay(_INTL("{1}'s {2} prevents romance!",b.pbThis,b.abilityName))
            end
            @battle.pbHideAbilitySplash(self)
          end
          return true
        end
      end
    end
    return true
  end

  def pbAttract(user,msg=nil)
    @effects[PBEffects::Attract] = user.index
    @battle.pbCommonAnimation("Attract",self)
    msg = _INTL("{1} fell in love!",pbThis) if !msg || msg==""
    @battle.pbDisplay(msg)
    # Destiny Knot
    if hasActiveItem?(:DESTINYKNOT) && user.pbCanAttract?(self,false)
      user.pbAttract(self,_INTL("{1} fell in love from the {2}!",user.pbThis(true),itemName))
    end
    # Attraction cures
    pbItemStatusCureCheck
    pbAbilityStatusCureCheck
  end

  def pbCureAttract
    @effects[PBEffects::Attract] = -1
  end

  #=============================================================================
  # Flinching
  #=============================================================================
  def pbFlinch(_user=nil)
    return if hasActiveAbility?(:INNERFOCUS) && !@battle.moldBreaker
    @effects[PBEffects::Flinch] = true
  end
end
