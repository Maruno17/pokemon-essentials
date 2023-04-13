#===============================================================================
#
#===============================================================================
class PokemonRuleSet
  def initialize(number = 0)
    @pokemonRules = []
    @teamRules    = []
    @subsetRules  = []
    @minLength    = 1
    @number       = number
  end

  def copy
    ret = PokemonRuleSet.new(@number)
    @pokemonRules.each do |rule|
      ret.addPokemonRule(rule)
    end
    @teamRules.each do |rule|
      ret.addTeamRule(rule)
    end
    @subsetRules.each do |rule|
      ret.addSubsetRule(rule)
    end
    return ret
  end

  def minLength
    return (@minLength) ? @minLength : self.maxLength
  end

  def maxLength
    return (@number < 0) ? Settings::MAX_PARTY_SIZE : @number
  end
  alias number maxLength

  def minTeamLength
    return [1, self.minLength].max
  end

  def maxTeamLength
    return [Settings::MAX_PARTY_SIZE, self.maxLength].max
  end

  # Returns the length of a valid subset of a Pokemon team.
  def suggestedNumber
    return self.maxLength
  end

  # Returns a valid level to assign to each member of a valid Pokemon team.
  def suggestedLevel
    minLevel = 1
    maxLevel = GameData::GrowthRate.max_level
    num = self.suggestedNumber
    @pokemonRules.each do |rule|
      case rule
      when MinimumLevelRestriction
        minLevel = rule.level
      when MaximumLevelRestriction
        maxLevel = rule.level
      end
    end
    totalLevel = maxLevel * num
    @subsetRules.each do |rule|
      totalLevel = rule.level if rule.is_a?(TotalLevelRestriction)
    end
    return [maxLevel, minLevel].max if totalLevel >= maxLevel * num
    return [totalLevel / self.suggestedNumber, minLevel].max
  end

  def setNumberRange(minValue, maxValue)
    @minLength = [1, minValue].max
    @number = [1, maxValue].max
    return self
  end

  def setNumber(value)
    return setNumberRange(value, value)
  end

  # This rule checks either:
  # - the entire team to determine whether a subset of the team meets the rule, or
  # - whether the entire team meets the rule. If the condition holds for the
  #   entire team, the condition must also hold for any possible subset of the
  #   team with the suggested number.
  # Examples of team rules:
  # - No two Pokemon can be the same species.
  # - No two Pokemon can hold the same items.
  def addTeamRule(rule)
    @teamRules.push(rule)
    return self
  end

  # This rule checks:
  # - the entire team to determine whether a subset of the team meets the rule, or
  # - a list of Pokemon whose length is equal to the suggested number. For an
  #   entire team, the condition must hold for at least one possible subset of
  #   the team, but not necessarily for the entire team.
  # A subset rule is "number-dependent", that is, whether the condition is likely
  # to hold depends on the number of Pokemon in the subset.
  # Example of a subset rule:
  # - The combined level of X Pokemon can't exceed Y.
  def addSubsetRule(rule)
    @teamRules.push(rule)
    return self
  end

  def addPokemonRule(rule)
    @pokemonRules.push(rule)
    return self
  end

  def clearTeamRules
    @teamRules.clear
    return self
  end

  def clearSubsetRules
    @subsetRules.clear
    return self
  end

  def clearPokemonRules
    @pokemonRules.clear
    return self
  end

  def isPokemonValid?(pkmn)
    return false if !pkmn
    @pokemonRules.each do |rule|
      return false if !rule.isValid?(pkmn)
    end
    return true
  end

  def hasRegistrableTeam?(list)
    return false if !list || list.length < self.minTeamLength
    pbEachCombination(list, self.maxTeamLength) do |comb|
      return true if canRegisterTeam?(comb)
    end
    return false
  end

  # Returns true if the team's length is greater or equal to the suggested
  # number and is Settings::MAX_PARTY_SIZE or less, the team as a whole meets
  # the requirements of any team rules, and at least one subset of the team
  # meets the requirements of any subset rules. Each Pokemon in the team must be
  # valid.
  def canRegisterTeam?(team)
    return false if !team || team.length < self.minTeamLength
    return false if team.length > self.maxTeamLength
    teamNumber = self.minTeamLength
    team.each do |pkmn|
      return false if !isPokemonValid?(pkmn)
    end
    @teamRules.each do |rule|
      return false if !rule.isValid?(team)
    end
    if @subsetRules.length > 0
      pbEachCombination(team, teamNumber) do |comb|
        isValid = true
        @subsetRules.each do |rule|
          next if rule.isValid?(comb)
          isValid = false
          break
        end
        return true if isValid
      end
      return false
    end
    return true
  end

  # Returns true if the team's length is greater or equal to the suggested
  # number and at least one subset of the team meets the requirements of any
  # team rules and subset rules. Not all Pokemon in the team have to be valid.
  def hasValidTeam?(team)
    return false if !team || team.length < self.minTeamLength
    teamNumber = self.minTeamLength
    validPokemon = []
    team.each do |pkmn|
      validPokemon.push(pkmn) if isPokemonValid?(pkmn)
    end
    return false if validPokemon.length < teamNumber
    if @teamRules.length > 0
      pbEachCombination(team, teamNumber) { |comb| return true if isValid?(comb) }
      return false
    end
    return true
  end

  # Returns true if the team's length meets the subset length range requirements
  # and the team meets the requirements of any team rules and subset rules. Each
  # Pokemon in the team must be valid.
  def isValid?(team, error = nil)
    if team.length < self.minLength
      error.push(_INTL("Choose a Pokémon.")) if error && self.minLength == 1
      error.push(_INTL("{1} Pokémon are needed.", self.minLength)) if error && self.minLength > 1
      return false
    elsif team.length > self.maxLength
      error&.push(_INTL("No more than {1} Pokémon may enter.", self.maxLength))
      return false
    end
    team.each do |pkmn|
      next if isPokemonValid?(pkmn)
      if pkmn
        error&.push(_INTL("{1} is not allowed.", pkmn.name))
      elsif error
        error.push(_INTL("This team is not allowed."))
      end
      return false
    end
    @teamRules.each do |rule|
      next if rule.isValid?(team)
      error&.push(rule.errorMessage)
      return false
    end
    @subsetRules.each do |rule|
      next if rule.isValid?(team)
      error&.push(rule.errorMessage)
      return false
    end
    return true
  end
end

#===============================================================================
#
#===============================================================================
class StandardRules < PokemonRuleSet
  attr_reader :number

  def initialize(number, level = nil)
    super(number)
    addPokemonRule(StandardRestriction.new)
    addTeamRule(SpeciesClause.new)
    addTeamRule(ItemClause.new)
    addPokemonRule(MaximumLevelRestriction.new(level)) if level
  end
end

#===============================================================================
#
#===============================================================================
class StandardCup < StandardRules
  def initialize
    super(3, 50)
  end

  def name
    return _INTL("Standard Cup")
  end
end

#===============================================================================
#
#===============================================================================
class DoubleCup < StandardRules
  def initialize
    super(4, 50)
  end

  def name
    return _INTL("Double Cup")
  end
end

#===============================================================================
#
#===============================================================================
class FancyCup < PokemonRuleSet
  def initialize
    super(3)
    addPokemonRule(StandardRestriction.new)
    addPokemonRule(MaximumLevelRestriction.new(30))
    addSubsetRule(TotalLevelRestriction.new(80))
    addPokemonRule(HeightRestriction.new(2))
    addPokemonRule(WeightRestriction.new(20))
    addPokemonRule(BabyRestriction.new)
    addTeamRule(SpeciesClause.new)
    addTeamRule(ItemClause.new)
  end

  def name
    return _INTL("Fancy Cup")
  end
end

#===============================================================================
#
#===============================================================================
class LittleCup < PokemonRuleSet
  def initialize
    super(3)
    addPokemonRule(StandardRestriction.new)
    addPokemonRule(MaximumLevelRestriction.new(5))
    addPokemonRule(BabyRestriction.new)
    addTeamRule(SpeciesClause.new)
    addTeamRule(ItemClause.new)
  end

  def name
    return _INTL("Little Cup")
  end
end

#===============================================================================
#
#===============================================================================
class LightCup < PokemonRuleSet
  def initialize
    super(3)
    addPokemonRule(StandardRestriction.new)
    addPokemonRule(MaximumLevelRestriction.new(50))
    addPokemonRule(WeightRestriction.new(99))
    addPokemonRule(BabyRestriction.new)
    addTeamRule(SpeciesClause.new)
    addTeamRule(ItemClause.new)
  end

  def name
    return _INTL("Light Cup")
  end
end
