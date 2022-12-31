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
