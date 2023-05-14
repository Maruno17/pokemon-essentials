class Battle::Battler
  #=============================================================================
  # Increase stat stages
  #=============================================================================
  def statStageAtMax?(stat)
    return @stages[stat] >= STAT_STAGE_MAXIMUM
  end

  def pbCanRaiseStatStage?(stat, user = nil, move = nil, showFailMsg = false, ignoreContrary = false)
    return false if fainted?
    # Contrary
    if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
      return pbCanLowerStatStage?(stat, user, move, showFailMsg, true)
    end
    # Check the stat stage
    if statStageAtMax?(stat)
      if showFailMsg
        @battle.pbDisplay(_INTL("{1}'s {2} won't go any higher!",
                                pbThis, GameData::Stat.get(stat).name))
      end
      return false
    end
    return true
  end

  def pbRaiseStatStageBasic(stat, increment, ignoreContrary = false)
    if !@battle.moldBreaker
      # Contrary
      if hasActiveAbility?(:CONTRARY) && !ignoreContrary
        return pbLowerStatStageBasic(stat, increment, true)
      end
      # Simple
      increment *= 2 if hasActiveAbility?(:SIMPLE)
    end
    # Change the stat stage
    increment = [increment, STAT_STAGE_MAXIMUM - @stages[stat]].min
    if increment > 0
      stat_name = GameData::Stat.get(stat).name
      new = @stages[stat] + increment
      PBDebug.log("[Stat change] #{pbThis}'s #{stat_name} changed by +#{increment} (#{@stages[stat]} -> #{new})")
      @stages[stat] += increment
      @statsRaisedThisRound = true
    end
    return increment
  end

  def pbRaiseStatStage(stat, increment, user, showAnim = true, ignoreContrary = false)
    # Contrary
    if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
      return pbLowerStatStage(stat, increment, user, showAnim, true)
    end
    # Perform the stat stage change
    increment = pbRaiseStatStageBasic(stat, increment, ignoreContrary)
    return false if increment <= 0
    # Stat up animation and message
    @battle.pbCommonAnimation("StatUp", self) if showAnim
    arrStatTexts = [
      _INTL("{1}'s {2} rose!", pbThis, GameData::Stat.get(stat).name),
      _INTL("{1}'s {2} rose sharply!", pbThis, GameData::Stat.get(stat).name),
      _INTL("{1}'s {2} rose drastically!", pbThis, GameData::Stat.get(stat).name)
    ]
    @battle.pbDisplay(arrStatTexts[[increment - 1, 2].min])
    # Trigger abilities upon stat gain
    if abilityActive?
      Battle::AbilityEffects.triggerOnStatGain(self.ability, self, stat, user)
    end
    return true
  end

  def pbRaiseStatStageByCause(stat, increment, user, cause, showAnim = true, ignoreContrary = false)
    # Contrary
    if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
      return pbLowerStatStageByCause(stat, increment, user, cause, showAnim, true)
    end
    # Perform the stat stage change
    increment = pbRaiseStatStageBasic(stat, increment, ignoreContrary)
    return false if increment <= 0
    # Stat up animation and message
    @battle.pbCommonAnimation("StatUp", self) if showAnim
    if user.index == @index
      arrStatTexts = [
        _INTL("{1}'s {2} raised its {3}!", pbThis, cause, GameData::Stat.get(stat).name),
        _INTL("{1}'s {2} sharply raised its {3}!", pbThis, cause, GameData::Stat.get(stat).name),
        _INTL("{1}'s {2} drastically raised its {3}!", pbThis, cause, GameData::Stat.get(stat).name)
      ]
    else
      arrStatTexts = [
        _INTL("{1}'s {2} raised {3}'s {4}!", user.pbThis, cause, pbThis(true), GameData::Stat.get(stat).name),
        _INTL("{1}'s {2} sharply raised {3}'s {4}!", user.pbThis, cause, pbThis(true), GameData::Stat.get(stat).name),
        _INTL("{1}'s {2} drastically raised {3}'s {4}!", user.pbThis, cause, pbThis(true), GameData::Stat.get(stat).name)
      ]
    end
    @battle.pbDisplay(arrStatTexts[[increment - 1, 2].min])
    # Trigger abilities upon stat gain
    if abilityActive?
      Battle::AbilityEffects.triggerOnStatGain(self.ability, self, stat, user)
    end
    return true
  end

  def pbRaiseStatStageByAbility(stat, increment, user, splashAnim = true)
    return false if fainted?
    ret = false
    @battle.pbShowAbilitySplash(user) if splashAnim
    if pbCanRaiseStatStage?(stat, user, nil, Battle::Scene::USE_ABILITY_SPLASH)
      if Battle::Scene::USE_ABILITY_SPLASH
        ret = pbRaiseStatStage(stat, increment, user)
      else
        ret = pbRaiseStatStageByCause(stat, increment, user, user.abilityName)
      end
    end
    @battle.pbHideAbilitySplash(user) if splashAnim
    return ret
  end

  #=============================================================================
  # Decrease stat stages
  #=============================================================================
  def statStageAtMin?(stat)
    return @stages[stat] <= -STAT_STAGE_MAXIMUM
  end

  def pbCanLowerStatStage?(stat, user = nil, move = nil, showFailMsg = false,
                           ignoreContrary = false, ignoreMirrorArmor = false)
    return false if fainted?
    if !@battle.moldBreaker
      # Contrary
      if hasActiveAbility?(:CONTRARY) && !ignoreContrary
        return pbCanRaiseStatStage?(stat, user, move, showFailMsg, true)
      end
      # Mirror Armor
      if hasActiveAbility?(:MIRRORARMOR) && !ignoreMirrorArmor &&
         user && user.index != @index && !statStageAtMin?(stat)
        return true
      end
    end
    if !user || user.index != @index   # Not self-inflicted
      if @effects[PBEffects::Substitute] > 0 &&
         (ignoreMirrorArmor || !(move && move.ignoresSubstitute?(user)))
        @battle.pbDisplay(_INTL("{1} is protected by its substitute!", pbThis)) if showFailMsg
        return false
      end
      if pbOwnSide.effects[PBEffects::Mist] > 0 &&
         !(user && user.hasActiveAbility?(:INFILTRATOR))
        @battle.pbDisplay(_INTL("{1} is protected by Mist!", pbThis)) if showFailMsg
        return false
      end
      if abilityActive?
        return false if !@battle.moldBreaker && Battle::AbilityEffects.triggerStatLossImmunity(
          self.ability, self, stat, @battle, showFailMsg
        )
        return false if Battle::AbilityEffects.triggerStatLossImmunityNonIgnorable(
          self.ability, self, stat, @battle, showFailMsg
        )
      end
      if !@battle.moldBreaker
        allAllies.each do |b|
          next if !b.abilityActive?
          return false if Battle::AbilityEffects.triggerStatLossImmunityFromAlly(
            b.ability, b, self, stat, @battle, showFailMsg
          )
        end
      end
    end
    # Check the stat stage
    if statStageAtMin?(stat)
      if showFailMsg
        @battle.pbDisplay(_INTL("{1}'s {2} won't go any lower!",
                                pbThis, GameData::Stat.get(stat).name))
      end
      return false
    end
    return true
  end

  def pbLowerStatStageBasic(stat, increment, ignoreContrary = false)
    if !@battle.moldBreaker
      # Contrary
      if hasActiveAbility?(:CONTRARY) && !ignoreContrary
        return pbRaiseStatStageBasic(stat, increment, true)
      end
      # Simple
      increment *= 2 if hasActiveAbility?(:SIMPLE)
    end
    # Change the stat stage
    increment = [increment, STAT_STAGE_MAXIMUM + @stages[stat]].min
    if increment > 0
      stat_name = GameData::Stat.get(stat).name
      new = @stages[stat] - increment
      PBDebug.log("[Stat change] #{pbThis}'s #{stat_name} changed by -#{increment} (#{@stages[stat]} -> #{new})")
      @stages[stat] -= increment
      @statsLoweredThisRound = true
      @statsDropped = true
    end
    return increment
  end

  def pbLowerStatStage(stat, increment, user, showAnim = true, ignoreContrary = false,
                       mirrorArmorSplash = 0, ignoreMirrorArmor = false)
    if !@battle.moldBreaker
      # Contrary
      if hasActiveAbility?(:CONTRARY) && !ignoreContrary
        return pbRaiseStatStage(stat, increment, user, showAnim, true)
      end
      # Mirror Armor
      if hasActiveAbility?(:MIRRORARMOR) && !ignoreMirrorArmor &&
         user && user.index != @index && !statStageAtMin?(stat)
        if mirrorArmorSplash < 2
          @battle.pbShowAbilitySplash(self)
          if !Battle::Scene::USE_ABILITY_SPLASH
            @battle.pbDisplay(_INTL("{1}'s {2} activated!", pbThis, abilityName))
          end
        end
        ret = false
        if user.pbCanLowerStatStage?(stat, self, nil, true, ignoreContrary, true)
          ret = user.pbLowerStatStage(stat, increment, self, showAnim, ignoreContrary, mirrorArmorSplash, true)
        end
        @battle.pbHideAbilitySplash(self) if mirrorArmorSplash.even?   # i.e. not 1 or 3
        return ret
      end
    end
    # Perform the stat stage change
    increment = pbLowerStatStageBasic(stat, increment, ignoreContrary)
    return false if increment <= 0
    # Stat down animation and message
    @battle.pbCommonAnimation("StatDown", self) if showAnim
    arrStatTexts = [
      _INTL("{1}'s {2} fell!", pbThis, GameData::Stat.get(stat).name),
      _INTL("{1}'s {2} harshly fell!", pbThis, GameData::Stat.get(stat).name),
      _INTL("{1}'s {2} severely fell!", pbThis, GameData::Stat.get(stat).name)
    ]
    @battle.pbDisplay(arrStatTexts[[increment - 1, 2].min])
    # Trigger abilities upon stat loss
    if abilityActive?
      Battle::AbilityEffects.triggerOnStatLoss(self.ability, self, stat, user)
    end
    return true
  end

  def pbLowerStatStageByCause(stat, increment, user, cause, showAnim = true,
                              ignoreContrary = false, ignoreMirrorArmor = false)
    if !@battle.moldBreaker
      # Contrary
      if hasActiveAbility?(:CONTRARY) && !ignoreContrary
        return pbRaiseStatStageByCause(stat, increment, user, cause, showAnim, true)
      end
      # Mirror Armor
      if hasActiveAbility?(:MIRRORARMOR) && !ignoreMirrorArmor &&
         user && user.index != @index && !statStageAtMin?(stat)
        @battle.pbShowAbilitySplash(self)
        if !Battle::Scene::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("{1}'s {2} activated!", pbThis, abilityName))
        end
        ret = false
        if user.pbCanLowerStatStage?(stat, self, nil, true, ignoreContrary, true)
          ret = user.pbLowerStatStageByCause(stat, increment, self, abilityName, showAnim, ignoreContrary, true)
        end
        @battle.pbHideAbilitySplash(self)
        return ret
      end
    end
    # Perform the stat stage change
    increment = pbLowerStatStageBasic(stat, increment, ignoreContrary)
    return false if increment <= 0
    # Stat down animation and message
    @battle.pbCommonAnimation("StatDown", self) if showAnim
    if user.index == @index
      arrStatTexts = [
        _INTL("{1}'s {2} lowered its {3}!", pbThis, cause, GameData::Stat.get(stat).name),
        _INTL("{1}'s {2} harshly lowered its {3}!", pbThis, cause, GameData::Stat.get(stat).name),
        _INTL("{1}'s {2} severely lowered its {3}!", pbThis, cause, GameData::Stat.get(stat).name)
      ]
    else
      arrStatTexts = [
        _INTL("{1}'s {2} lowered {3}'s {4}!", user.pbThis, cause, pbThis(true), GameData::Stat.get(stat).name),
        _INTL("{1}'s {2} harshly lowered {3}'s {4}!", user.pbThis, cause, pbThis(true), GameData::Stat.get(stat).name),
        _INTL("{1}'s {2} severely lowered {3}'s {4}!", user.pbThis, cause, pbThis(true), GameData::Stat.get(stat).name)
      ]
    end
    @battle.pbDisplay(arrStatTexts[[increment - 1, 2].min])
    # Trigger abilities upon stat loss
    if abilityActive?
      Battle::AbilityEffects.triggerOnStatLoss(self.ability, self, stat, user)
    end
    return true
  end

  def pbLowerStatStageByAbility(stat, increment, user, splashAnim = true, checkContact = false)
    ret = false
    @battle.pbShowAbilitySplash(user) if splashAnim
    if pbCanLowerStatStage?(stat, user, nil, Battle::Scene::USE_ABILITY_SPLASH) &&
       (!checkContact || affectedByContactEffect?(Battle::Scene::USE_ABILITY_SPLASH))
      if Battle::Scene::USE_ABILITY_SPLASH
        ret = pbLowerStatStage(stat, increment, user)
      else
        ret = pbLowerStatStageByCause(stat, increment, user, user.abilityName)
      end
    end
    @battle.pbHideAbilitySplash(user) if splashAnim
    return ret
  end

  def pbLowerAttackStatStageIntimidate(user)
    return false if fainted?
    # NOTE: Substitute intentionally blocks Intimidate even if self has Contrary.
    if @effects[PBEffects::Substitute] > 0
      if Battle::Scene::USE_ABILITY_SPLASH
        @battle.pbDisplay(_INTL("{1} is protected by its substitute!", pbThis))
      else
        @battle.pbDisplay(_INTL("{1}'s substitute protected it from {2}'s {3}!",
                                pbThis, user.pbThis(true), user.abilityName))
      end
      return false
    end
    if Settings::MECHANICS_GENERATION >= 8 && hasActiveAbility?([:OBLIVIOUS, :OWNTEMPO, :INNERFOCUS, :SCRAPPY])
      @battle.pbShowAbilitySplash(self)
      if Battle::Scene::USE_ABILITY_SPLASH
        @battle.pbDisplay(_INTL("{1}'s {2} cannot be lowered!", pbThis, GameData::Stat.get(:ATTACK).name))
      else
        @battle.pbDisplay(_INTL("{1}'s {2} prevents {3} loss!", pbThis, abilityName,
                                GameData::Stat.get(:ATTACK).name))
      end
      @battle.pbHideAbilitySplash(self)
      return false
    end
    if Battle::Scene::USE_ABILITY_SPLASH
      return pbLowerStatStageByAbility(:ATTACK, 1, user, false)
    end
    # NOTE: These checks exist to ensure appropriate messages are shown if
    #       Intimidate is blocked somehow (i.e. the messages should mention the
    #       Intimidate ability by name).
    if !hasActiveAbility?(:CONTRARY)
      if pbOwnSide.effects[PBEffects::Mist] > 0
        @battle.pbDisplay(_INTL("{1} is protected from {2}'s {3} by Mist!",
                                pbThis, user.pbThis(true), user.abilityName))
        return false
      end
      if abilityActive? &&
         (Battle::AbilityEffects.triggerStatLossImmunity(self.ability, self, :ATTACK, @battle, false) ||
          Battle::AbilityEffects.triggerStatLossImmunityNonIgnorable(self.ability, self, :ATTACK, @battle, false))
        @battle.pbDisplay(_INTL("{1}'s {2} prevented {3}'s {4} from working!",
                                pbThis, abilityName, user.pbThis(true), user.abilityName))
        return false
      end
      allAllies.each do |b|
        next if !b.abilityActive?
        if Battle::AbilityEffects.triggerStatLossImmunityFromAlly(b.ability, b, self, :ATTACK, @battle, false)
          @battle.pbDisplay(_INTL("{1} is protected from {2}'s {3} by {4}'s {5}!",
                                  pbThis, user.pbThis(true), user.abilityName, b.pbThis(true), b.abilityName))
          return false
        end
      end
    end
    return false if !pbCanLowerStatStage?(:ATTACK, user)
    return pbLowerStatStageByCause(:ATTACK, 1, user, user.abilityName)
  end

  #=============================================================================
  # Reset stat stages
  #=============================================================================
  def hasAlteredStatStages?
    GameData::Stat.each_battle { |s| return true if @stages[s.id] != 0 }
    return false
  end

  def hasRaisedStatStages?
    GameData::Stat.each_battle { |s| return true if @stages[s.id] > 0 }
    return false
  end

  def hasLoweredStatStages?
    GameData::Stat.each_battle { |s| return true if @stages[s.id] < 0 }
    return false
  end

  def pbResetStatStages
    GameData::Stat.each_battle do |s|
      if @stages[s.id] > 0
        @statsLoweredThisRound = true
        @statsDropped = true
      elsif @stages[s.id] < 0
        @statsRaisedThisRound = true
      end
      @stages[s.id] = 0
    end
  end
end
