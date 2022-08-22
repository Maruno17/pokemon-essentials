class Battle::AI
  def pbAIRandom(x); return rand(x); end

  def pbStdDev(choices)
    sum = 0
    n   = 0
    choices.each do |c|
      sum += c[1]
      n   += 1
    end
    return 0 if n < 2
    mean = sum.to_f / n
    varianceTimesN = 0
    choices.each do |c|
      next if c[1] <= 0
      deviation = c[1].to_f - mean
      varianceTimesN += deviation * deviation
    end
    # Using population standard deviation
    # [(n-1) makes it a sample std dev, would be 0 with only 1 sample]
    return Math.sqrt(varianceTimesN / n)
  end

  #=============================================================================
  # Move's type effectiveness
  #=============================================================================
  # For switching. Determines the effectiveness of a potential switch-in against
  # an opposing battler.
  def pbCalcTypeModPokemon(pkmn, target_battler)
    mod1 = Effectiveness.calculate(pkmn.types[0], target_battler.types[0], target_battler.types[1])
    mod2 = Effectiveness::NORMAL_EFFECTIVE
    if pkmn.types.length > 1
      mod2 = Effectiveness.calculate(pkmn.types[1], target_battler.types[0], target_battler.types[1])
      mod2 = mod2.to_f / Effectivenesss::NORMAL_EFFECTIVE
    end
    return mod1 * mod2
  end

  #=============================================================================
  # Damage calculation
  #=============================================================================
  def pbRoughDamage(move, target, baseDmg)
    # Fixed damage moves
    return baseDmg if move.move.is_a?(Battle::Move::FixedDamageMove)

    user_battler = @user.battler
    target_battler = target.battler

    # Get the move's type
    type = move.rough_type

    ##### Calculate user's attack stat #####
    atk = @user.rough_stat(:ATTACK)
    if move.move.function == "UseTargetAttackInsteadOfUserAttack"   # Foul Play
      atk = target.rough_stat(:ATTACK)
    elsif move.move.function == "UseUserBaseDefenseInsteadOfUserBaseAttack"   # Body Press
      atk = @user.rough_stat(:DEFENSE)
    elsif move.move.specialMove?(type)
      if move.move.function == "UseTargetAttackInsteadOfUserAttack"   # Foul Play
        atk = target.rough_stat(:SPECIAL_ATTACK)
      else
        atk = @user.rough_stat(:SPECIAL_ATTACK)
      end
    end

    ##### Calculate target's defense stat #####
    defense = target.rough_stat(:DEFENSE)
    if move.move.specialMove?(type) && move.move.function != "UseTargetDefenseInsteadOfTargetSpDef"   # Psyshock
      defense = target.rough_stat(:SPECIAL_DEFENSE)
    end

    ##### Calculate all multiplier effects #####
    multipliers = {
      :base_damage_multiplier  => 1.0,
      :attack_multiplier       => 1.0,
      :defense_multiplier      => 1.0,
      :final_damage_multiplier => 1.0
    }
    # Ability effects that alter damage
    moldBreaker = @trainer.high_skill? && target_battler.hasMoldBreaker?

    if @user.ability_active?
      # NOTE: These abilities aren't suitable for checking at the start of the
      #       round.
      abilityBlacklist = [:ANALYTIC, :SNIPER, :TINTEDLENS, :AERILATE, :PIXILATE, :REFRIGERATE]
      canCheck = true
      abilityBlacklist.each do |m|
        next if move.move.id != m
        canCheck = false
        break
      end
      if canCheck
        Battle::AbilityEffects.triggerDamageCalcFromUser(
          user_battler.ability, user_battler, target_battler, move.move, multipliers, baseDmg, type
        )
      end
    end

    if @trainer.medium_skill? && !moldBreaker
      user_battler.allAllies.each do |b|
        next if !b.abilityActive?
        Battle::AbilityEffects.triggerDamageCalcFromAlly(
          b.ability, user_battler, target_battler, move.move, multipliers, baseDmg, type
        )
      end
    end

    if !moldBreaker && target.ability_active?
      # NOTE: These abilities aren't suitable for checking at the start of the
      #       round.
      abilityBlacklist = [:FILTER, :SOLIDROCK]
      canCheck = true
      abilityBlacklist.each do |m|
        next if move.move.id != m
        canCheck = false
        break
      end
      if canCheck
        Battle::AbilityEffects.triggerDamageCalcFromTarget(
          target_battler.ability, user_battler, target_battler, move.move, multipliers, baseDmg, type
        )
      end
    end

    if @trainer.high_skill? && !moldBreaker
      target_battler.allAllies.each do |b|
        next if !b.abilityActive?
        Battle::AbilityEffects.triggerDamageCalcFromTargetAlly(
          b.ability, user_battler, target_battler, move.move, multipliers, baseDmg, type
        )
      end
    end

    # Item effects that alter damage
    # NOTE: Type-boosting gems aren't suitable for checking at the start of the
    #       round.
    if @user.item_active?
      # NOTE: These items aren't suitable for checking at the start of the
      #       round.
      itemBlacklist = [:EXPERTBELT, :LIFEORB]
      if !itemBlacklist.include?(user_battler.item_id)
        Battle::ItemEffects.triggerDamageCalcFromUser(
          user_battler.item, user_battler, target_battler, move.move, multipliers, baseDmg, type
        )
        user_battler.effects[PBEffects::GemConsumed] = nil   # Untrigger consuming of Gems
      end
      # TODO: Prefer (1.5x?) if item will be consumed and user has Unburden.
    end

    if target.item_active? && target_battler.item && !target_battler.item.is_berry?
      Battle::ItemEffects.triggerDamageCalcFromTarget(
        target_battler.item, user_battler, target_battler, move.move, multipliers, baseDmg, type
      )
    end

    # Global abilities
    if @trainer.medium_skill? &&
       ((@battle.pbCheckGlobalAbility(:DARKAURA) && type == :DARK) ||
        (@battle.pbCheckGlobalAbility(:FAIRYAURA) && type == :FAIRY))
      if @battle.pbCheckGlobalAbility(:AURABREAK)
        multipliers[:base_damage_multiplier] *= 2 / 3.0
      else
        multipliers[:base_damage_multiplier] *= 4 / 3.0
      end
    end

    # Parental Bond
    if @user.has_active_ability?(:PARENTALBOND)
      multipliers[:base_damage_multiplier] *= 1.25
    end

    # Me First
    # TODO

    # Helping Hand - n/a

    # Charge
    if @trainer.medium_skill? &&
       user_battler.effects[PBEffects::Charge] > 0 && type == :ELECTRIC
      multipliers[:base_damage_multiplier] *= 2
    end

    # Mud Sport and Water Sport
    if @trainer.medium_skill?
      if type == :ELECTRIC
        if @battle.allBattlers.any? { |b| b.effects[PBEffects::MudSport] }
          multipliers[:base_damage_multiplier] /= 3
        end
        if @battle.field.effects[PBEffects::MudSportField] > 0
          multipliers[:base_damage_multiplier] /= 3
        end
      end
      if type == :FIRE
        if @battle.allBattlers.any? { |b| b.effects[PBEffects::WaterSport] }
          multipliers[:base_damage_multiplier] /= 3
        end
        if @battle.field.effects[PBEffects::WaterSportField] > 0
          multipliers[:base_damage_multiplier] /= 3
        end
      end
    end

    # Terrain moves
    if @trainer.medium_skill?
      case @battle.field.terrain
      when :Electric
        multipliers[:base_damage_multiplier] *= 1.5 if type == :ELECTRIC && user_battler.affectedByTerrain?
      when :Grassy
        multipliers[:base_damage_multiplier] *= 1.5 if type == :GRASS && user_battler.affectedByTerrain?
      when :Psychic
        multipliers[:base_damage_multiplier] *= 1.5 if type == :PSYCHIC && user_battler.affectedByTerrain?
      when :Misty
        multipliers[:base_damage_multiplier] /= 2 if type == :DRAGON && target_battler.affectedByTerrain?
      end
    end

    # Badge multipliers
    if @trainer.high_skill? && @battle.internalBattle && target_battler.pbOwnedByPlayer?
      # Don't need to check the Atk/Sp Atk-boosting badges because the AI
      # won't control the player's Pokémon.
      if move.move.physicalMove?(type) && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_DEFENSE
        multipliers[:defense_multiplier] *= 1.1
      elsif move.move.specialMove?(type) && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_SPDEF
        multipliers[:defense_multiplier] *= 1.1
      end
    end

    # Multi-targeting attacks
    if @trainer.high_skill? && move.targets_multiple_battlers?
      multipliers[:final_damage_multiplier] *= 0.75
    end

    # Weather
    if @trainer.medium_skill?
      case user_battler.effectiveWeather
      when :Sun, :HarshSun
        case type
        when :FIRE
          multipliers[:final_damage_multiplier] *= 1.5
        when :WATER
          multipliers[:final_damage_multiplier] /= 2
        end
      when :Rain, :HeavyRain
        case type
        when :FIRE
          multipliers[:final_damage_multiplier] /= 2
        when :WATER
          multipliers[:final_damage_multiplier] *= 1.5
        end
      when :Sandstorm
        if target.has_type?(:ROCK) && move.move.specialMove?(type) &&
           move.move.function != "UseTargetDefenseInsteadOfTargetSpDef"   # Psyshock
          multipliers[:defense_multiplier] *= 1.5
        end
      end
    end

    # Critical hits - n/a

    # Random variance - n/a

    # STAB
    if type && @user.has_type?(type)
      if @user.has_active_ability?(:ADAPTABILITY)
        multipliers[:final_damage_multiplier] *= 2
      else
        multipliers[:final_damage_multiplier] *= 1.5
      end
    end

    # Type effectiveness
    typemod = target.effectiveness_of_type_against_battler(type, @user)
    multipliers[:final_damage_multiplier] *= typemod.to_f / Effectiveness::NORMAL_EFFECTIVE

    # Burn
    if @trainer.high_skill? && move.move.physicalMove?(type) &&
       user_battler.status == :BURN && !@user.has_active_ability?(:GUTS) &&
       !(Settings::MECHANICS_GENERATION >= 6 &&
         move.move.function == "DoublePowerIfUserPoisonedBurnedParalyzed")   # Facade
      multipliers[:final_damage_multiplier] /= 2
    end

    # Aurora Veil, Reflect, Light Screen
    if @trainer.medium_skill? && !move.move.ignoresReflect? && !@user.has_active_ability?(:INFILTRATOR)
      if target_battler.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
        if @battle.pbSideBattlerCount(target_battler) > 1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
      elsif target_battler.pbOwnSide.effects[PBEffects::Reflect] > 0 && move.move.physicalMove?(type)
        if @battle.pbSideBattlerCount(target_battler) > 1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
      elsif target_battler.pbOwnSide.effects[PBEffects::LightScreen] > 0 && move.move.specialMove?(type)
        if @battle.pbSideBattlerCount(target_battler) > 1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
      end
    end

    # Minimize
    if @trainer.medium_skill? && target_battler.effects[PBEffects::Minimize] && move.move.tramplesMinimize?
      multipliers[:final_damage_multiplier] *= 2
    end

    # Move-specific base damage modifiers
    # TODO

    # Move-specific final damage modifiers
    # TODO

    ##### Main damage calculation #####
    baseDmg = [(baseDmg * multipliers[:base_damage_multiplier]).round, 1].max
    atk     = [(atk     * multipliers[:attack_multiplier]).round, 1].max
    defense = [(defense * multipliers[:defense_multiplier]).round, 1].max
    damage  = ((((2.0 * user_battler.level / 5) + 2).floor * baseDmg * atk / defense).floor / 50).floor + 2
    damage  = [(damage * multipliers[:final_damage_multiplier]).round, 1].max
    return damage.floor
  end

  #=============================================================================
  # Check if battler has a move that meets the criteria in the block provided
  #=============================================================================
  def check_for_move(battler)
    ret = false
    battler.eachMove do |move|
      next unless yield move
      ret = true
      break
    end
    return ret
  end
end
