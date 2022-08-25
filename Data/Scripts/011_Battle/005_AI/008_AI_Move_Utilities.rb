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
