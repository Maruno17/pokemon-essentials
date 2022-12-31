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
  def pbCalcTypeModSingle(moveType, defType, user, target)
    ret = Effectiveness.calculate(moveType, defType)
    if Effectiveness.ineffective_type?(moveType, defType)
      # Ring Target
      if target.hasActiveItem?(:RINGTARGET)
        ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
      end
      # Foresight
      if (user.hasActiveAbility?(:SCRAPPY) || target.effects[PBEffects::Foresight]) &&
         defType == :GHOST
        ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
      end
      # Miracle Eye
      if target.effects[PBEffects::MiracleEye] && defType == :DARK
        ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
      end
    elsif Effectiveness.super_effective_type?(moveType, defType)
      # Delta Stream's weather
      if target.effectiveWeather == :StrongWinds && defType == :FLYING
        ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
      end
    end
    # Grounded Flying-type Pokémon become susceptible to Ground moves
    if !target.airborne? && defType == :FLYING && moveType == :GROUND
      ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
    end
    return ret
  end

  def pbCalcTypeMod(moveType, user, target)
    ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
    return ret if !moveType
    return ret if moveType == :GROUND && target.pbHasType?(:FLYING) && target.hasActiveItem?(:IRONBALL)
    # Get effectivenesses
    if moveType == :SHADOW
      if target.shadowPokemon?
        ret = Effectiveness::NOT_VERY_EFFECTIVE_MULTIPLIER
      else
        ret = Effectiveness::SUPER_EFFECTIVE_MULTIPLIER
      end
    else
      target.pbTypes(true).each do |type|
        ret *= pbCalcTypeModSingle(moveType, type, user, target)
      end
    end
    return ret
  end

  # For switching. Determines the effectiveness of a potential switch-in against
  # an opposing battler.
  def pbCalcTypeModPokemon(pkmn, target_battler)
    ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
    pkmn.types.each do |thisType|
      ret *= Effectiveness.calculate(thisType, *target_battler.types)
    end
    return ret
  end

  #=============================================================================
  # Yields certain AIBattler objects
  #=============================================================================
  def each_battler
    @battlers.each_with_index do |battler, i|
      next if !battler || battler.fainted?
      yield battler, i
    end
  end

  def each_foe_battler(side)
    @battlers.each_with_index do |battler, i|
      next if !battler || battler.fainted?
      yield battler, i if i.even? != side.even?
    end
  end

  def each_same_side_battler(side)
    @battlers.each_with_index do |battler, i|
      next if !battler || battler.fainted?
      yield battler, i if i.even? == side.even?
    end
  end

  def each_ally(index)
    @battlers.each_with_index do |battler, i|
      next if !battler || battler.fainted?
      yield battler, i if i != index && i.even? == index.even?
    end
  end
end
