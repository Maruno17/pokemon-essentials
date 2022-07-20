class Battle::AI
  #=============================================================================
  # Get a score for the given move based on its effect
  #=============================================================================
  alias aiEffectScorePart1_pbGetMoveScoreFunctionCode pbGetMoveScoreFunctionCode

  def pbGetMoveScoreFunctionCode(score, move, user, target, skill = 100)
    case move.function
    #---------------------------------------------------------------------------
    when "SleepTarget", "SleepTargetIfUserDarkrai", "SleepTargetChangeUserMeloettaForm"
      if target.pbCanSleep?(user, false)
        score += 30
        if skill >= PBTrainerAI.mediumSkill
          score -= 30 if target.effects[PBEffects::Yawn] > 0
        end
        if skill >= PBTrainerAI.highSkill
          score -= 30 if target.hasActiveAbility?(:MARVELSCALE)
        end
        if skill >= PBTrainerAI.bestSkill
          if target.pbHasMoveFunction?("FlinchTargetFailsIfUserNotAsleep",
                                       "UseRandomUserMoveIfAsleep")   # Snore, Sleep Talk
            score -= 50
          end
        end
      elsif skill >= PBTrainerAI.mediumSkill
        score -= 90 if move.statusMove?
      end
    #---------------------------------------------------------------------------
    when "SleepTargetNextTurn"
      if target.effects[PBEffects::Yawn] > 0 || !target.pbCanSleep?(user, false)
        score -= 90 if skill >= PBTrainerAI.mediumSkill
      else
        score += 30
        if skill >= PBTrainerAI.highSkill
          score -= 30 if target.hasActiveAbility?(:MARVELSCALE)
        end
        if skill >= PBTrainerAI.bestSkill
          if target.pbHasMoveFunction?("FlinchTargetFailsIfUserNotAsleep",
                                       "UseRandomUserMoveIfAsleep")   # Snore, Sleep Talk
            score -= 50
          end
        end
      end
    #---------------------------------------------------------------------------
    when "PoisonTarget"
      if target.pbCanPoison?(user, false)
        score += 30
        if skill >= PBTrainerAI.mediumSkill
          score += 30 if target.hp <= target.totalhp / 4
          score += 50 if target.hp <= target.totalhp / 8
          score -= 40 if target.effects[PBEffects::Yawn] > 0
        end
        if skill >= PBTrainerAI.highSkill
          score += 10 if pbRoughStat(target, :DEFENSE, skill) > 100
          score += 10 if pbRoughStat(target, :SPECIAL_DEFENSE, skill) > 100
          score -= 40 if target.hasActiveAbility?([:GUTS, :MARVELSCALE, :TOXICBOOST])
        end
      elsif skill >= PBTrainerAI.mediumSkill
        score -= 90 if move.statusMove?
      end
    #---------------------------------------------------------------------------
    when "PoisonTargetLowerTargetSpeed1"
      if !target.pbCanPoison?(user, false) && !target.pbCanLowerStatStage?(:SPEED, user)
        score -= 90
      else
        if target.pbCanPoison?(user, false)
          score += 30
          if skill >= PBTrainerAI.mediumSkill
            score += 30 if target.hp <= target.totalhp / 4
            score += 50 if target.hp <= target.totalhp / 8
            score -= 40 if target.effects[PBEffects::Yawn] > 0
          end
          if skill >= PBTrainerAI.highSkill
            score += 10 if pbRoughStat(target, :DEFENSE, skill) > 100
            score += 10 if pbRoughStat(target, :SPECIAL_DEFENSE, skill) > 100
            score -= 40 if target.hasActiveAbility?([:GUTS, :MARVELSCALE, :TOXICBOOST])
          end
        end
        if target.pbCanLowerStatStage?(:SPEED, user)
          score += target.stages[:SPEED] * 10
          if skill >= PBTrainerAI.highSkill
            aspeed = pbRoughStat(user, :SPEED, skill)
            ospeed = pbRoughStat(target, :SPEED, skill)
            score += 30 if aspeed < ospeed && aspeed * 2 > ospeed
          end
        end
      end
    #---------------------------------------------------------------------------
    when "BadPoisonTarget"
      if target.pbCanPoison?(user, false)
        score += 30
        if skill >= PBTrainerAI.mediumSkill
          score += 30 if target.hp <= target.totalhp / 4
          score += 50 if target.hp <= target.totalhp / 8
          score -= 40 if target.effects[PBEffects::Yawn] > 0
        end
        if skill >= PBTrainerAI.highSkill
          score += 10 if pbRoughStat(target, :DEFENSE, skill) > 100
          score += 10 if pbRoughStat(target, :SPECIAL_DEFENSE, skill) > 100
          score -= 40 if target.hasActiveAbility?([:GUTS, :MARVELSCALE, :TOXICBOOST])
        end
      elsif skill >= PBTrainerAI.mediumSkill
        score -= 90 if move.statusMove?
      end
    #---------------------------------------------------------------------------
    when "ParalyzeTarget", "ParalyzeTargetIfNotTypeImmune",
         "ParalyzeTargetAlwaysHitsInRainHitsTargetInSky", "ParalyzeFlinchTarget"
      if target.pbCanParalyze?(user, false) &&
         !(skill >= PBTrainerAI.mediumSkill &&
         move.id == :THUNDERWAVE &&
         Effectiveness.ineffective?(pbCalcTypeMod(move.type, user, target)))
        score += 30
        if skill >= PBTrainerAI.mediumSkill
          aspeed = pbRoughStat(user, :SPEED, skill)
          ospeed = pbRoughStat(target, :SPEED, skill)
          if aspeed < ospeed
            score += 30
          elsif aspeed > ospeed
            score -= 40
          end
        end
        if skill >= PBTrainerAI.highSkill
          score -= 40 if target.hasActiveAbility?([:GUTS, :MARVELSCALE, :QUICKFEET])
        end
      elsif skill >= PBTrainerAI.mediumSkill
        score -= 90 if move.statusMove?
      end
    #---------------------------------------------------------------------------
    when "BurnTarget"
      if target.pbCanBurn?(user, false)
        score += 30
        if skill >= PBTrainerAI.highSkill
          score -= 40 if target.hasActiveAbility?([:GUTS, :MARVELSCALE, :QUICKFEET, :FLAREBOOST])
        end
      elsif skill >= PBTrainerAI.mediumSkill
        score -= 90 if move.statusMove?
      end
    #---------------------------------------------------------------------------
    when "BurnTargetIfTargetStatsRaisedThisTurn"
      if target.pbCanBurn?(user, false)
        score += 40
        if skill >= PBTrainerAI.highSkill
          score -= 40 if target.hasActiveAbility?([:GUTS, :MARVELSCALE, :QUICKFEET, :FLAREBOOST])
        end
      else
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "BurnFlinchTarget"
      if target.pbCanBurn?(user, false)
        score += 30
        if skill >= PBTrainerAI.highSkill
          score -= 40 if target.hasActiveAbility?([:GUTS, :MARVELSCALE, :QUICKFEET, :FLAREBOOST])
        end
      elsif skill >= PBTrainerAI.mediumSkill
        score -= 90 if move.statusMove?
      end
    #---------------------------------------------------------------------------
    when "FreezeTarget"
      if target.pbCanFreeze?(user, false)
        score += 30
        if skill >= PBTrainerAI.highSkill
          score -= 20 if target.hasActiveAbility?(:MARVELSCALE)
        end
      elsif skill >= PBTrainerAI.mediumSkill
        score -= 90 if move.statusMove?
      end
    #---------------------------------------------------------------------------
    when "FreezeTargetSuperEffectiveAgainstWater"
      if target.pbCanFreeze?(user, false)
        score += 30
        if skill >= PBTrainerAI.highSkill
          score -= 20 if target.hasActiveAbility?(:MARVELSCALE)
        end
      end
    #---------------------------------------------------------------------------
    when "FreezeTargetAlwaysHitsInHail", "FreezeFlinchTarget"
      if target.pbCanFreeze?(user, false)
        score += 30
        if skill >= PBTrainerAI.highSkill
          score -= 20 if target.hasActiveAbility?(:MARVELSCALE)
        end
      elsif skill >= PBTrainerAI.mediumSkill
        score -= 90 if move.statusMove?
      end
    #---------------------------------------------------------------------------
    when "ParalyzeBurnOrFreezeTarget"
      score += 30 if target.status == :NONE
    #---------------------------------------------------------------------------
    when "GiveUserStatusToTarget"
      if user.status == :NONE
        score -= 90
      else
        score += 40
      end
    #---------------------------------------------------------------------------
    when "CureUserBurnPoisonParalysis"
      case user.status
      when :POISON
        score += 40
        if skill >= PBTrainerAI.mediumSkill
          if user.hp < user.totalhp / 8
            score += 60
          elsif skill >= PBTrainerAI.highSkill &&
                user.hp < (user.effects[PBEffects::Toxic] + 1) * user.totalhp / 16
            score += 60
          end
        end
      when :BURN, :PARALYSIS
        score += 40
      else
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "CureUserPartyStatus"
      statuses = 0
      @battle.pbParty(user.index).each do |pkmn|
        statuses += 1 if pkmn && pkmn.status != :NONE
      end
      if statuses == 0
        score -= 80
      else
        score += 20 * statuses
      end
    #---------------------------------------------------------------------------
    when "CureTargetBurn"
      if target.opposes?(user)
        score -= 40 if target.status == :BURN
      elsif target.status == :BURN
        score += 40
      end
    #---------------------------------------------------------------------------
    when "StartUserSideImmunityToInflictedStatus"
      if user.pbOwnSide.effects[PBEffects::Safeguard] > 0
        score -= 80
      elsif user.status != :NONE
        score -= 40
      else
        score += 30
      end
    #---------------------------------------------------------------------------
    when "FlinchTarget"
      score += 30
      if skill >= PBTrainerAI.highSkill
        score += 30 if !target.hasActiveAbility?(:INNERFOCUS) &&
                       target.effects[PBEffects::Substitute] == 0
      end
    #---------------------------------------------------------------------------
    when "FlinchTargetFailsIfUserNotAsleep"
      if user.asleep?
        score += 100   # Because it can only be used while asleep
        if skill >= PBTrainerAI.highSkill
          score += 30 if !target.hasActiveAbility?(:INNERFOCUS) &&
                         target.effects[PBEffects::Substitute] == 0
        end
      else
        score -= 90   # Because it will fail here
        score = 0 if skill >= PBTrainerAI.bestSkill
      end
    #---------------------------------------------------------------------------
    when "FlinchTargetFailsIfNotUserFirstTurn"
      if user.turnCount == 0
        if skill >= PBTrainerAI.highSkill
          score += 30 if !target.hasActiveAbility?(:INNERFOCUS) &&
                         target.effects[PBEffects::Substitute] == 0
        end
      else
        score -= 90   # Because it will fail here
        score = 0 if skill >= PBTrainerAI.bestSkill
      end
    #---------------------------------------------------------------------------
    when "FlinchTargetDoublePowerIfTargetInSky"
      if skill >= PBTrainerAI.highSkill
        score += 30 if !target.hasActiveAbility?(:INNERFOCUS) &&
                       target.effects[PBEffects::Substitute] == 0
      end
    #---------------------------------------------------------------------------
    when "ConfuseTarget", "ConfuseTargetAlwaysHitsInRainHitsTargetInSky"
      if target.pbCanConfuse?(user, false)
        score += 30
      elsif skill >= PBTrainerAI.mediumSkill
        score -= 90 if move.statusMove?
      end
    #---------------------------------------------------------------------------
    when "AttractTarget"
      canattract = true
      agender = user.gender
      ogender = target.gender
      if agender == 2 || ogender == 2 || agender == ogender
        score -= 90
        canattract = false
      elsif target.effects[PBEffects::Attract] >= 0
        score -= 80
        canattract = false
      elsif skill >= PBTrainerAI.bestSkill && target.hasActiveAbility?(:OBLIVIOUS)
        score -= 80
        canattract = false
      end
      if skill >= PBTrainerAI.highSkill
        if canattract && target.hasActiveItem?(:DESTINYKNOT) &&
           user.pbCanAttract?(target, false)
          score -= 30
        end
      end
    #---------------------------------------------------------------------------
    when "SetUserTypesBasedOnEnvironment"
      if !user.canChangeType?
        score -= 90
      elsif skill >= PBTrainerAI.mediumSkill
        new_type = nil
        case @battle.field.terrain
        when :Electric
          new_type = :ELECTRIC if GameData::Type.exists?(:ELECTRIC)
        when :Grassy
          new_type = :GRASS if GameData::Type.exists?(:GRASS)
        when :Misty
          new_type = :FAIRY if GameData::Type.exists?(:FAIRY)
        when :Psychic
          new_type = :PSYCHIC if GameData::Type.exists?(:PSYCHIC)
        end
        if !new_type
          envtypes = {
            :None        => :NORMAL,
            :Grass       => :GRASS,
            :TallGrass   => :GRASS,
            :MovingWater => :WATER,
            :StillWater  => :WATER,
            :Puddle      => :WATER,
            :Underwater  => :WATER,
            :Cave        => :ROCK,
            :Rock        => :GROUND,
            :Sand        => :GROUND,
            :Forest      => :BUG,
            :ForestGrass => :BUG,
            :Snow        => :ICE,
            :Ice         => :ICE,
            :Volcano     => :FIRE,
            :Graveyard   => :GHOST,
            :Sky         => :FLYING,
            :Space       => :DRAGON,
            :UltraSpace  => :PSYCHIC
          }
          new_type = envtypes[@battle.environment]
          new_type = nil if !GameData::Type.exists?(new_type)
          new_type ||= :NORMAL
        end
        score -= 90 if !user.pbHasOtherType?(new_type)
      end
    #---------------------------------------------------------------------------
    when "SetUserTypesToResistLastAttack"
      if !user.canChangeType?
        score -= 90
      elsif !target.lastMoveUsed || !target.lastMoveUsedType ||
            GameData::Type.get(target.lastMoveUsedType).pseudo_type
        score -= 90
      else
        aType = nil
        target.eachMove do |m|
          next if m.id != target.lastMoveUsed
          aType = m.pbCalcType(user)
          break
        end
        if aType
          has_possible_type = false
          GameData::Type.each do |t|
            next if t.pseudo_type || user.pbHasType?(t.id) ||
                    !Effectiveness.resistant_type?(target.lastMoveUsedType, t.id)
            has_possible_type = true
            break
          end
          score -= 90 if !has_possible_type
        else
          score -= 90
        end
      end
    #---------------------------------------------------------------------------
    when "SetUserTypesToTargetTypes"
      if !user.canChangeType? || target.pbTypes(true).length == 0
        score -= 90
      elsif user.pbTypes == target.pbTypes &&
            user.effects[PBEffects::Type3] == target.effects[PBEffects::Type3]
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "SetUserTypesToUserMoveType"
      if user.canChangeType?
        has_possible_type = false
        user.eachMoveWithIndex do |m, i|
          break if Settings::MECHANICS_GENERATION >= 6 && i > 0
          next if GameData::Type.get(m.type).pseudo_type
          next if user.pbHasType?(m.type)
          has_possible_type = true
          break
        end
        score -= 90 if !has_possible_type
      else
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "SetTargetTypesToPsychic"
      if target.pbHasOtherType?(:PSYCHIC)
        score -= 90
      elsif !target.canChangeType?
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "SetTargetTypesToWater"
      if target.effects[PBEffects::Substitute] > 0 || !target.canChangeType?
        score -= 90
      elsif !target.pbHasOtherType?(:WATER)
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "AddGhostTypeToTarget"
      score -= 90 if target.pbHasType?(:GHOST)
    #---------------------------------------------------------------------------
    when "AddGrassTypeToTarget"
      score -= 90 if target.pbHasType?(:GRASS)
    #---------------------------------------------------------------------------
    when "UserLosesFireType"
      score -= 90 if !user.pbHasType?(:FIRE)
    #---------------------------------------------------------------------------
    when "SetTargetAbilityToSimple"
      if target.effects[PBEffects::Substitute] > 0
        score -= 90
      elsif skill >= PBTrainerAI.mediumSkill
        if target.unstoppableAbility? || [:TRUANT, :SIMPLE].include?(target.ability)
          score -= 90
        end
      end
    #---------------------------------------------------------------------------
    when "SetTargetAbilityToInsomnia"
      if target.effects[PBEffects::Substitute] > 0
        score -= 90
      elsif skill >= PBTrainerAI.mediumSkill
        if target.unstoppableAbility? || [:TRUANT, :INSOMNIA].include?(target.ability_id)
          score -= 90
        end
      end
    #---------------------------------------------------------------------------
    when "SetUserAbilityToTargetAbility"
      score -= 40   # don't prefer this move
      if skill >= PBTrainerAI.mediumSkill
        if !target.ability || user.ability == target.ability ||
           [:MULTITYPE, :RKSSYSTEM].include?(user.ability_id) ||
           [:FLOWERGIFT, :FORECAST, :ILLUSION, :IMPOSTER, :MULTITYPE, :RKSSYSTEM,
            :TRACE, :WONDERGUARD, :ZENMODE].include?(target.ability_id)
          score -= 90
        end
      end
      if skill >= PBTrainerAI.highSkill
        if target.ability == :TRUANT && user.opposes?(target)
          score -= 90
        elsif target.ability == :SLOWSTART && user.opposes?(target)
          score -= 90
        end
      end
    #---------------------------------------------------------------------------
    when "SetTargetAbilityToUserAbility"
      score -= 40   # don't prefer this move
      if target.effects[PBEffects::Substitute] > 0
        score -= 90
      elsif skill >= PBTrainerAI.mediumSkill
        if !user.ability || user.ability == target.ability ||
           [:MULTITYPE, :RKSSYSTEM, :TRUANT].include?(target.ability_id) ||
           [:FLOWERGIFT, :FORECAST, :ILLUSION, :IMPOSTER, :MULTITYPE, :RKSSYSTEM,
            :TRACE, :ZENMODE].include?(user.ability_id)
          score -= 90
        end
        if skill >= PBTrainerAI.highSkill
          if user.ability == :TRUANT && user.opposes?(target)
            score += 90
          elsif user.ability == :SLOWSTART && user.opposes?(target)
            score += 90
          end
        end
      end
    #---------------------------------------------------------------------------
    when "UserTargetSwapAbilities"
      score -= 40   # don't prefer this move
      if skill >= PBTrainerAI.mediumSkill
        if (!user.ability && !target.ability) ||
           user.ability == target.ability ||
           [:ILLUSION, :MULTITYPE, :RKSSYSTEM, :WONDERGUARD].include?(user.ability_id) ||
           [:ILLUSION, :MULTITYPE, :RKSSYSTEM, :WONDERGUARD].include?(target.ability_id)
          score -= 90
        end
      end
      if skill >= PBTrainerAI.highSkill
        if target.ability == :TRUANT && user.opposes?(target)
          score -= 90
        elsif target.ability == :SLOWSTART && user.opposes?(target)
          score -= 90
        end
      end
    #---------------------------------------------------------------------------
    when "NegateTargetAbility"
      if target.effects[PBEffects::Substitute] > 0 ||
         target.effects[PBEffects::GastroAcid]
        score -= 90
      elsif skill >= PBTrainerAI.highSkill
        score -= 90 if [:MULTITYPE, :RKSSYSTEM, :SLOWSTART, :TRUANT].include?(target.ability_id)
      end
    #---------------------------------------------------------------------------
    when "NegateTargetAbilityIfTargetActed"
      if skill >= PBTrainerAI.mediumSkill
        userSpeed   = pbRoughStat(user, :SPEED, skill)
        targetSpeed = pbRoughStat(target, :SPEED, skill)
        if userSpeed < targetSpeed
          score += 30
        end
      else
        score += 30
      end
    #---------------------------------------------------------------------------
    when "IgnoreTargetAbility"
    #---------------------------------------------------------------------------
    when "StartUserAirborne"
      if user.effects[PBEffects::MagnetRise] > 0 ||
         user.effects[PBEffects::Ingrain] ||
         user.effects[PBEffects::SmackDown]
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "StartTargetAirborneAndAlwaysHitByMoves"
      if target.effects[PBEffects::Telekinesis] > 0 ||
         target.effects[PBEffects::Ingrain] ||
         target.effects[PBEffects::SmackDown]
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "HitsTargetInSky"
    #---------------------------------------------------------------------------
    when "HitsTargetInSkyGroundsTarget"
      if skill >= PBTrainerAI.mediumSkill
        score += 20 if target.effects[PBEffects::MagnetRise] > 0
        score += 20 if target.effects[PBEffects::Telekinesis] > 0
        score += 20 if target.inTwoTurnAttack?("TwoTurnAttackInvulnerableInSky",
                                               "TwoTurnAttackInvulnerableInSkyParalyzeTarget")
        score += 20 if target.pbHasType?(:FLYING)
        score += 20 if target.hasActiveAbility?(:LEVITATE)
        score += 20 if target.hasActiveItem?(:AIRBALLOON)
      end
    #---------------------------------------------------------------------------
    when "StartGravity"
      if @battle.field.effects[PBEffects::Gravity] > 0
        score -= 90
      elsif skill >= PBTrainerAI.mediumSkill
        score -= 30
        score -= 20 if user.effects[PBEffects::SkyDrop] >= 0
        score -= 20 if user.effects[PBEffects::MagnetRise] > 0
        score -= 20 if user.effects[PBEffects::Telekinesis] > 0
        score -= 20 if user.pbHasType?(:FLYING)
        score -= 20 if user.hasActiveAbility?(:LEVITATE)
        score -= 20 if user.hasActiveItem?(:AIRBALLOON)
        score += 20 if target.effects[PBEffects::SkyDrop] >= 0
        score += 20 if target.effects[PBEffects::MagnetRise] > 0
        score += 20 if target.effects[PBEffects::Telekinesis] > 0
        score += 20 if target.inTwoTurnAttack?("TwoTurnAttackInvulnerableInSky",
                                               "TwoTurnAttackInvulnerableInSkyParalyzeTarget",
                                               "TwoTurnAttackInvulnerableInSkyTargetCannotAct")
        score += 20 if target.pbHasType?(:FLYING)
        score += 20 if target.hasActiveAbility?(:LEVITATE)
        score += 20 if target.hasActiveItem?(:AIRBALLOON)
      end
    #---------------------------------------------------------------------------
    when "TransformUserIntoTarget"
      score -= 70
    #---------------------------------------------------------------------------
    else
      return aiEffectScorePart1_pbGetMoveScoreFunctionCode(score, move, user, target, skill)
    end
    return score
  end
end
