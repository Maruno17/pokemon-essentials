#===============================================================================
#
#===============================================================================
class StandardRestriction
  def isValid?(pkmn)
    return false if !pkmn || pkmn.egg?
    # Species with disadvantageous abilities are not banned
    pkmn.species_data.abilities.each do |a|
      return true if [:TRUANT, :SLOWSTART].include?(a)
    end
    # Certain named species are not banned
    return true if [:DRAGONITE, :SALAMENCE, :TYRANITAR].include?(pkmn.species)
    # Certain named species are banned
    return false if [:WYNAUT, :WOBBUFFET].include?(pkmn.species)
    # Species with total base stat 600 or more are banned
    bst = 0
    pkmn.baseStats.each_value { |s| bst += s }
    return false if bst >= 600
    # Is valid
    return true
  end
end

#===============================================================================
#
#===============================================================================
class HeightRestriction
  def initialize(maxHeightInMeters)
    @level = maxHeightInMeters
  end

  def isValid?(pkmn)
    height = (pkmn.is_a?(Pokemon)) ? pkmn.height : GameData::Species.get(pkmn).height
    return height <= (@level * 10).round
  end
end

#===============================================================================
#
#===============================================================================
class WeightRestriction
  def initialize(maxWeightInKg)
    @level = maxWeightInKg
  end

  def isValid?(pkmn)
    weight = (pkmn.is_a?(Pokemon)) ? pkmn.weight : GameData::Species.get(pkmn).weight
    return weight <= (@level * 10).round
  end
end

#===============================================================================
# Unused
#===============================================================================
class NegativeExtendedGameClause
  def isValid?(pkmn)
    return false if pkmn.isSpecies?(:ARCEUS)
    return false if pkmn.hasItem?(:MICLEBERRY)
    return false if pkmn.hasItem?(:CUSTAPBERRY)
    return false if pkmn.hasItem?(:JABOCABERRY)
    return false if pkmn.hasItem?(:ROWAPBERRY)
  end
end

#===============================================================================
#
#===============================================================================
$babySpeciesData = {}

class BabyRestriction
  def isValid?(pkmn)
    if !$babySpeciesData[pkmn.species]
      $babySpeciesData[pkmn.species] = pkmn.species_data.get_baby_species
    end
    return pkmn.species == $babySpeciesData[pkmn.species]
  end
end

#===============================================================================
#
#===============================================================================
$canEvolve = {}

class UnevolvedFormRestriction
  def isValid?(pkmn)
    if !$babySpeciesData[pkmn.species]
      $babySpeciesData[pkmn.species] = pkmn.species_data.get_baby_species
    end
    return false if pkmn.species != $babySpeciesData[pkmn.species]
    if $canEvolve[pkmn.species].nil?
      $canEvolve[pkmn.species] = (pkmn.species_data.get_evolutions(true).length > 0)
    end
    return $canEvolve[pkmn.species]
  end
end

#===============================================================================
#
#===============================================================================
module NicknameChecker
  @@names = {}

  def getName(species)
    n = @@names[species]
    return n if n
    n = GameData::Species.get(species).name
    @@names[species] = n.upcase
    return n
  end

  def check(name, species)
    name = name.upcase
    return true if name == getName(species)
    return false if @@names.values.include?(name)
    GameData::Species.each_species do |species_data|
      return false if species_data.species != species && getName(species_data.id) == name
    end
    return true
  end
end

#===============================================================================
# No two Pokemon can have the same nickname.
# No nickname can be the same as the (real) name of another Pokemon character.
#===============================================================================
class NicknameClause
  def isValid?(team)
    (team.length - 1).times do |i|
      (i + 1...team.length).each do |j|
        return false if team[i].name == team[j].name
        return false if !NicknameChecker.check(team[i].name, team[i].species)
      end
    end
    return true
  end

  def errorMessage
    return _INTL("No identical nicknames.")
  end
end

#===============================================================================
#
#===============================================================================
class NonEggRestriction
  def isValid?(pkmn)
    return pkmn && !pkmn.egg?
  end
end

#===============================================================================
#
#===============================================================================
class AblePokemonRestriction
  def isValid?(pkmn)
    return pkmn&.able?
  end
end

#===============================================================================
#
#===============================================================================
class SpeciesRestriction
  def initialize(*specieslist)
    @specieslist = specieslist.clone
  end

  def isSpecies?(species, specieslist)
    return specieslist.include?(species)
  end

  def isValid?(pkmn)
    return isSpecies?(pkmn.species, @specieslist)
  end
end

#===============================================================================
#
#===============================================================================
class BannedSpeciesRestriction
  def initialize(*specieslist)
    @specieslist = specieslist.clone
  end

  def isSpecies?(species, specieslist)
    return specieslist.include?(species)
  end

  def isValid?(pkmn)
    return !isSpecies?(pkmn.species, @specieslist)
  end
end

#===============================================================================
#
#===============================================================================
class RestrictedSpeciesRestriction
  def initialize(maxValue, *specieslist)
    @specieslist = specieslist.clone
    @maxValue = maxValue
  end

  def isSpecies?(species, specieslist)
    return specieslist.include?(species)
  end

  def isValid?(team)
    count = 0
    team.each do |pkmn|
      count += 1 if pkmn && isSpecies?(pkmn.species, @specieslist)
    end
    return count <= @maxValue
  end
end

#===============================================================================
#
#===============================================================================
class RestrictedSpeciesTeamRestriction < RestrictedSpeciesRestriction
  def initialize(*specieslist)
    super(4, *specieslist)
  end
end

#===============================================================================
#
#===============================================================================
class RestrictedSpeciesSubsetRestriction < RestrictedSpeciesRestriction
  def initialize(*specieslist)
    super(2, *specieslist)
  end
end

#===============================================================================
#
#===============================================================================
class SameSpeciesClause
  def isValid?(team)
    species = []
    team.each do |pkmn|
      species.push(pkmn.species) if pkmn && !species.include?(pkmn.species)
    end
    return species.length == 1
  end

  def errorMessage
    return _INTL("Pokémon must be the same species.")
  end
end

#===============================================================================
#
#===============================================================================
class SpeciesClause
  def isValid?(team)
    species = []
    team.each do |pkmn|
      next if !pkmn
      return false if species.include?(pkmn.species)
      species.push(pkmn.species)
    end
    return true
  end

  def errorMessage
    return _INTL("Pokémon can't be the same species.")
  end
end

#===============================================================================
#
#===============================================================================
class MinimumLevelRestriction
  attr_reader :level

  def initialize(minLevel)
    @level = minLevel
  end

  def isValid?(pkmn)
    return pkmn.level >= @level
  end
end

#===============================================================================
#
#===============================================================================
class MaximumLevelRestriction
  attr_reader :level

  def initialize(maxLevel)
    @level = maxLevel
  end

  def isValid?(pkmn)
    return pkmn.level <= @level
  end
end

#===============================================================================
#
#===============================================================================
class TotalLevelRestriction
  attr_reader :level

  def initialize(level)
    @level = level
  end

  def isValid?(team)
    totalLevel = 0
    team.each { |pkmn| totalLevel += pkmn.level if pkmn }
    return totalLevel <= @level
  end

  def errorMessage
    return _INTL("The combined levels exceed {1}.", @level)
  end
end

#===============================================================================
#
#===============================================================================
class BannedItemRestriction
  def initialize(*itemlist)
    @itemlist = itemlist.clone
  end

  def isSpecies?(item, itemlist)
    return itemlist.include?(item)
  end

  def isValid?(pkmn)
    return !pkmn.item_id || !isSpecies?(pkmn.item_id, @itemlist)
  end
end

#===============================================================================
#
#===============================================================================
class ItemsDisallowedClause
  def isValid?(pkmn)
    return !pkmn.hasItem?
  end
end

#===============================================================================
#
#===============================================================================
class SoulDewClause
  def isValid?(pkmn)
    return !pkmn.hasItem?(:SOULDEW)
  end
end

#===============================================================================
#
#===============================================================================
class ItemClause
  def isValid?(team)
    items = []
    team.each do |pkmn|
      next if !pkmn || !pkmn.hasItem?
      return false if items.include?(pkmn.item_id)
      items.push(pkmn.item_id)
    end
    return true
  end

  def errorMessage
    return _INTL("No identical hold items.")
  end
end

#===============================================================================
#
#===============================================================================
class LittleCupRestriction
  def isValid?(pkmn)
    return false if pkmn.hasItem?(:BERRYJUICE)
    return false if pkmn.hasItem?(:DEEPSEATOOTH)
    return false if pkmn.hasMove?(:SONICBOOM)
    return false if pkmn.hasMove?(:DRAGONRAGE)
    return false if pkmn.isSpecies?(:SCYTHER)
    return false if pkmn.isSpecies?(:SNEASEL)
    return false if pkmn.isSpecies?(:MEDITITE)
    return false if pkmn.isSpecies?(:YANMA)
    return false if pkmn.isSpecies?(:TANGELA)
    return false if pkmn.isSpecies?(:MURKROW)
    return true
  end
end
