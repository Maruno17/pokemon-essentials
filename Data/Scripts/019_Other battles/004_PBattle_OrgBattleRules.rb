def pbBaseStatTotal(species)
  baseStats = pbGetSpeciesData(species,0,SpeciesBaseStats)
  ret = 0
  baseStats.each { |s| ret += s }
  return ret
end

def pbBalancedLevelFromBST(species)
  return (113-(pbBaseStatTotal(species)*0.072)).round
end

def pbTooTall?(pkmn,maxHeightInMeters)
  species = (pkmn.is_a?(PokeBattle_Pokemon)) ? pkmn.species : pkmn
  form    = (pkmn.is_a?(PokeBattle_Pokemon)) ? pkmn.form : 0
  height = pbGetSpeciesData(species,form,SpeciesHeight)
  return height>(maxHeightInMeters*10).round
end

def pbTooHeavy?(pkmn,maxWeightInKg)
  species = (pkmn.is_a?(PokeBattle_Pokemon)) ? pkmn.species : pkmn
  form    = (pkmn.is_a?(PokeBattle_Pokemon)) ? pkmn.form : 0
  weight = pbGetSpeciesData(species,form,SpeciesWeight)
  return weight>(maxWeightInKg*10).round
end



class LevelAdjustment
  BothTeams          = 0
  EnemyTeam          = 1
  MyTeam             = 2
  BothTeamsDifferent = 3

  def type
    @adjustment
  end

  def initialize(adjustment)
    @adjustment=adjustment
  end

  def self.getNullAdjustment(thisTeam,_otherTeam)
    ret=[]
    for i in 0...thisTeam.length
      ret[i]=thisTeam[i].level
    end
    return ret
  end

  def getAdjustment(thisTeam,otherTeam)
    return self.getNullAdjustment(thisTeam,otherTeam)
  end

  def getOldExp(team1,_team2)
    ret=[]
    for i in 0...team1.length
      ret.push(team1[i].exp)
    end
    return ret
  end

  def unadjustLevels(team1,team2,adjustments)
    for i in 0...team1.length
      exp=adjustments[0][i]
      if exp && team1[i].exp!=exp
        team1[i].exp=exp
        team1[i].calcStats
      end
    end
    for i in 0...team2.length
      exp=adjustments[1][i]
      if exp && team2[i].exp!=exp
        team2[i].exp=exp
        team2[i].calcStats
      end
    end
  end

  def adjustLevels(team1,team2)
    adj1=nil
    adj2=nil
    ret=[getOldExp(team1,team2),getOldExp(team2,team1)]
    if @adjustment==BothTeams || @adjustment==MyTeam
      adj1=getAdjustment(team1,team2)
    elsif @adjustment==BothTeamsDifferent
      adj1=getMyAdjustment(team1,team2)
    end
    if @adjustment==BothTeams || @adjustment==EnemyTeam
      adj2=getAdjustment(team2,team1)
    elsif @adjustment==BothTeamsDifferent
      adj2=getTheirAdjustment(team2,team1)
    end
    if adj1
      for i in 0...team1.length
        if team1[i].level!=adj1[i]
          team1[i].level=adj1[i]
          team1[i].calcStats
        end
      end
    end
    if adj2
      for i in 0...team2.length
        if team2[i].level!=adj2[i]
          team2[i].level=adj2[i]
          team2[i].calcStats
        end
      end
    end
    return ret
  end
end



class LevelBalanceAdjustment < LevelAdjustment
  def initialize(minLevel)
    super(LevelAdjustment::BothTeams)
    @minLevel=minLevel
  end

  def getAdjustment(thisTeam,_otherTeam)
    ret=[]
    for i in 0...thisTeam.length
      ret[i]=pbBalancedLevelFromBST(thisTeam[i].species)
    end
    return ret
  end
end



class EnemyLevelAdjustment < LevelAdjustment
  def initialize(level)
    super(LevelAdjustment::EnemyTeam)
    @level=[[1,level].max,PBExperience.maxLevel].min
  end

  def getAdjustment(thisTeam,_otherTeam)
    ret=[]
    for i in 0...thisTeam.length
      ret[i]=@level
    end
    return ret
  end
end



class CombinedLevelAdjustment < LevelAdjustment
  def initialize(my,their)
    super(LevelAdjustment::BothTeamsDifferent)
    @my=my
    @their=their
  end

  def getMyAdjustment(myTeam,theirTeam)
    return @my ? @my.getAdjustment(myTeam,theirTeam) :
       LevelAdjustment.getNullAdjustment(myTeam,theirTeam)
  end

  def getTheirAdjustment(theirTeam,myTeam)
    return @their ? @their.getAdjustment(theirTeam,myTeam) :
       LevelAdjustment.getNullAdjustment(theirTeam,myTeam)
  end
end



class SinglePlayerCappedLevelAdjustment < CombinedLevelAdjustment
  def initialize(level)
    super(CappedLevelAdjustment.new(level),FixedLevelAdjustment.new(level))
  end
end



class CappedLevelAdjustment < LevelAdjustment
  def initialize(level)
    super(LevelAdjustment::BothTeams)
    @level=[[1,level].max,PBExperience.maxLevel].min
  end

  def getAdjustment(thisTeam,_otherTeam)
    ret=[]
    for i in 0...thisTeam.length
      ret[i]=[thisTeam[i].level,@level].min
    end
    return ret
  end
end



class FixedLevelAdjustment < LevelAdjustment
  def initialize(level)
    super(LevelAdjustment::BothTeams)
    @level=[[1,level].max,PBExperience.maxLevel].min
  end

  def getAdjustment(thisTeam,_otherTeam)
    ret=[]
    for i in 0...thisTeam.length
      ret[i]=@level
    end
    return ret
  end
end



class TotalLevelAdjustment < LevelAdjustment
  def initialize(minLevel,maxLevel,totalLevel)
    super(LevelAdjustment::EnemyTeam)
    mLevel = PBExperience.maxLevel
    @minLevel=[[1,minLevel].max,mLevel].min
    @maxLevel=[[1,maxLevel].max,mLevel].min
    @totalLevel=totalLevel
  end

  def getAdjustment(thisTeam,_otherTeam)
    ret=[]
    total=0
    for i in 0...thisTeam.length
      ret[i]=@minLevel
      total+=@minLevel
    end
    loop do
      work=false
      for i in 0...thisTeam.length
        if ret[i]>=@maxLevel || total>=@totalLevel
          next
        end
        ret[i]+=1
        total+=1
        work=true
      end
      break if !work
    end
    return ret
  end
end



class OpenLevelAdjustment < LevelAdjustment
  def initialize(minLevel=1)
    super(LevelAdjustment::EnemyTeam)
    @minLevel=minLevel
  end

  def getAdjustment(thisTeam,otherTeam)
    maxLevel=1
    for i in 0...otherTeam.length
      level=otherTeam[i].level
      maxLevel=level if maxLevel<level
    end
    maxLevel=@minLevel if maxLevel<@minLevel
    ret=[]
    for i in 0...thisTeam.length
      ret[i]=maxLevel
    end
    return ret
  end
end



class NonEggRestriction
  def isValid?(pokemon)
    return pokemon && !pokemon.egg?
  end
end



class AblePokemonRestriction
  def isValid?(pokemon)
    return pokemon && !pokemon.egg? && pokemon.hp>0
  end
end



class SpeciesRestriction
  def initialize(*specieslist)
    @specieslist=specieslist.clone
  end

  def isSpecies?(species,specieslist)
    for s in specieslist
      return true if isConst?(species,PBSpecies,s)
    end
    return false
  end

  def isValid?(pokemon)
    count=0
    if isSpecies?(pokemon.species,@specieslist)
      count+=1
    end
    return count!=0
  end
end



class BannedSpeciesRestriction
  def initialize(*specieslist)
    @specieslist=specieslist.clone
  end

  def isSpecies?(species,specieslist)
    for s in specieslist
      return true if isConst?(species,PBSpecies,s)
    end
    return false
  end

  def isValid?(pokemon)
    count=0
    if isSpecies?(pokemon.species,@specieslist)
      count+=1
    end
    return count==0
  end
end



class BannedItemRestriction
  def initialize(*specieslist)
    @specieslist=specieslist.clone
  end

  def isSpecies?(species,specieslist)
    for s in specieslist
      return true if isConst?(species,PBItems,s)
    end
    return false
  end

  def isValid?(pokemon)
    count=0
    if pokemon.item!=0 && isSpecies?(pokemon.item,@specieslist)
      count+=1
    end
    return count==0
  end
end



class RestrictedSpeciesRestriction
  def initialize(maxValue,*specieslist)
    @specieslist=specieslist.clone
    @maxValue=maxValue
  end

  def isSpecies?(species,specieslist)
    for s in specieslist
      return true if isConst?(species,PBSpecies,s)
    end
    return false
  end

  def isValid?(team)
    count=0
    for i in 0...team.length
      if isSpecies?(team[i].species,@specieslist)
        count+=1
      end
    end
    return count<=@maxValue
  end
end



class RestrictedSpeciesTeamRestriction < RestrictedSpeciesRestriction
  def initialize(*specieslist)
    super(4,*specieslist)
  end
end



class RestrictedSpeciesSubsetRestriction < RestrictedSpeciesRestriction
  def initialize(*specieslist)
    super(2,*specieslist)
  end
end



class StandardRestriction
  def isValid?(pokemon)
    return false if !pokemon || pokemon.egg?
    # Species with disadvantageous abilities are not banned
    abilities = pbGetSpeciesData(pokemon.species,pokemon.form,SpeciesAbilities)
    abilities = [abilities] if !abilities.is_a?(Array)
    abilities.each do |a|
      return true if isConst?(a,PBAbilities,:TRUANT) ||
                     isConst?(a,PBAbilities,:SLOWSTART)
    end
    # Certain named species are not banned
    speciesWhitelist = [:DRAGONITE,:SALAMENCE,:TYRANITAR]
    for i in speciesWhitelist
      return true if pokemon.isSpecies?(i)
    end
    # Certain named species are banned
    speciesBlacklist = [:WYNAUT,:WOBBUFFET]
    for i in speciesBlacklist
      return false if pokemon.isSpecies?(i)
    end
    # Species with total base stat 600 or more are banned
    baseStats = pbGetSpeciesData(pokemon.species,pokemon.form,SpeciesBaseStats)
    bst = 0
    baseStats.each { |s| bst += s }
    return false if bst>=600
    # Is valid
    return true
  end
end



module LevelRestriction; end



class MinimumLevelRestriction
  attr_reader :level

  def initialize(minLevel)
    @level=minLevel
  end

  def isValid?(pokemon)
    return pokemon.level>=@level
  end
end



class MaximumLevelRestriction
  attr_reader :level

  def initialize(maxLevel)
    @level=maxLevel
  end

  def isValid?(pokemon)
    return pokemon.level<=@level
  end
end



class HeightRestriction
  def initialize(maxHeightInMeters)
    @level=maxHeightInMeters
  end

  def isValid?(pokemon)
    return !pbTooTall?(pokemon,@level)
  end
end



class WeightRestriction
  def initialize(maxWeightInKg)
    @level=maxWeightInKg
  end

  def isValid?(pokemon)
    return !pbTooHeavy?(pokemon,@level)
  end
end



class SoulDewClause
  def isValid?(pokemon)
    return !pokemon.hasItem?(:SOULDEW)
  end
end



class ItemsDisallowedClause
  def isValid?(pokemon)
    return !pokemon.hasItem?
  end
end



class NegativeExtendedGameClause
  def isValid?(pokemon)
    return false if pokemon.isSpecies?(:ARCEUS)
    return false if pokemon.hasItem?(:MICLEBERRY)
    return false if pokemon.hasItem?(:CUSTAPBERRY)
    return false if pokemon.hasItem?(:JABOCABERRY)
    return false if pokemon.hasItem?(:ROWAPBERRY)
  end
end



class TotalLevelRestriction
  attr_reader :level

  def initialize(level)
    @level=level
  end

  def isValid?(team)
    totalLevel=0
    for i in 0...team.length-1
      next if team[i].species==0
      totalLevel+=team[i].level
    end
    return (totalLevel<=@level)
  end

  def errorMessage
    return _INTL("The combined levels exceed {1}.",@level)
  end
end



class SameSpeciesClause
  def isValid?(team)
    species=0
    for i in 0...team.length-1
      next if team[i].species==0
      if species==0
        species=team[i].species
      else
        return false if team[i].species!=species
      end
    end
    return true
  end

  def errorMessage
    return _INTL("Pokémon can't be the same.")
  end
end



class SpeciesClause
  def isValid?(team)
    for i in 0...team.length-1
      next if team[i].species==0
      for j in i+1...team.length
        return false if team[i].species==team[j].species
      end
    end
    return true
  end

  def errorMessage
    return _INTL("Pokémon can't be the same.")
  end
end



$babySpeciesData = {}
$canEvolve       = {}



class BabyRestriction
  def isValid?(pokemon)
    baby=$babySpeciesData[pokemon.species] ? $babySpeciesData[pokemon.species] :
       ($babySpeciesData[pokemon.species]=pbGetBabySpecies(pokemon.species))
    return baby==pokemon.species
  end
end



class UnevolvedFormRestriction
  def isValid?(pokemon)
    baby=$babySpeciesData[pokemon.species] ? $babySpeciesData[pokemon.species] :
       ($babySpeciesData[pokemon.species]=pbGetBabySpecies(pokemon.species))
    return false if baby!=pokemon.species
    canEvolve=($canEvolve[pokemon.species]!=nil) ? $canEvolve[pokemon.species] :
       ($canEvolve[pokemon.species]=(pbGetEvolvedFormData(pokemon.species,true).length!=0))
    return false if !canEvolve
    return true
  end
end



class LittleCupRestriction
  def isValid?(pokemon)
    return false if pokemon.hasItem?(:BERRYJUICE)
    return false if pokemon.hasItem?(:DEEPSEATOOTH)
    return false if pokemon.hasMove?(:SONICBOOM)
    return false if pokemon.hasMove?(:DRAGONRAGE)
    return false if pokemon.isSpecies?(:SCYTHER)
    return false if pokemon.isSpecies?(:SNEASEL)
    return false if pokemon.isSpecies?(:MEDITITE)
    return false if pokemon.isSpecies?(:YANMA)
    return false if pokemon.isSpecies?(:TANGELA)
    return false if pokemon.isSpecies?(:MURKROW)
    return true
  end
end



class ItemClause
  def isValid?(team)
    for i in 0...team.length-1
      next if !team[i].hasItem?
      for j in i+1...team.length
        return false if team[i].item==team[j].item
      end
    end
    return true
  end

  def errorMessage
    return _INTL("No identical hold items.")
  end
end



module NicknameChecker
  @@names={}
  @@namesMaxValue=0

  def getName(species)
    n=@@names[species]
    return n if n
    n=PBSpecies.getName(species)
    @@names[species]=n.upcase
    return n
  end

  def check(name,species)
    name=name.upcase
    return true if name==getName(species)
    if @@names.values.include?(name)
      return false
    end
    for i in @@namesMaxValue..PBSpecies.maxValue
      if i!=species
        n=getName(i)
        return false if n==name
      end
    end
    return true
  end
end



# No two Pokemon can have the same nickname.
# No nickname can be the same as the (real) name of another Pokemon character.
class NicknameClause
  def isValid?(team)
    for i in 0...team.length-1
      for j in i+1...team.length
        return false if team[i].name==team[j].name
        return false if !NicknameChecker.check(team[i].name,team[i].species)
      end
    end
    return true
  end

  def errorMessage
    return _INTL("No identical nicknames.")
  end
end



class PokemonRuleSet
  def minTeamLength
    return [1,self.minLength].max
  end

  def maxTeamLength
    return [6,self.maxLength].max
  end

  def minLength
    return @minLength ? @minLength : self.maxLength
  end

  def maxLength
    return @number<0 ? 6 : @number
  end

  def number
    return self.maxLength
  end

  def initialize(number=0)
    @pokemonRules=[]
    @teamRules=[]
    @subsetRules=[]
    @minLength=1
    @number=number
  end

  def copy
    ret=PokemonRuleSet.new(@number)
    for rule in @pokemonRules
      ret.addPokemonRule(rule)
    end
    for rule in @teamRules
      ret.addTeamRule(rule)
    end
    for rule in @subsetRules
      ret.addSubsetRule(rule)
    end
    return ret
  end

  # Returns the length of a valid subset of a Pokemon team.
  def suggestedNumber
    return self.maxLength
  end

  # Returns a valid level to assign to each member of a valid Pokemon team.
  def suggestedLevel
    minLevel=1
    maxLevel=PBExperience.maxLevel
    num=self.suggestedNumber
    for rule in @pokemonRules
      if rule.is_a?(MinimumLevelRestriction)
        minLevel=rule.level
      elsif rule.is_a?(MaximumLevelRestriction)
        maxLevel=rule.level
      end
    end
    totalLevel=maxLevel*num
    for rule in @subsetRules
      if rule.is_a?(TotalLevelRestriction)
        totalLevel=rule.level
      end
    end
    if totalLevel>=maxLevel*num
      return [maxLevel,minLevel].max
    else
      return [(totalLevel/self.suggestedNumber),minLevel].max
    end
  end

  def setNumberRange(minValue,maxValue)
    @minLength=[1,minValue].max
    @number=[maxValue,6].min
    return self
  end

  def setNumber(value)
    return setNumberRange(value,value)
  end

  def addPokemonRule(rule)
    @pokemonRules.push(rule)
    return self
  end

  # This rule checks
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

  # This rule checks either
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

  def clearPokemonRules
    @pokemonRules.clear
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

  def isPokemonValid?(pokemon)
    return false if !pokemon
    for rule in @pokemonRules
      if !rule.isValid?(pokemon)
        return false
      end
    end
    return true
  end

  def hasRegistrableTeam?(list)
    return false if !list || list.length<self.minTeamLength
    pbEachCombination(list,self.maxTeamLength) { |comb|
      return true if canRegisterTeam?(comb)
    }
    return false
  end

  # Returns true if the team's length is greater or equal to the suggested number
  # and is 6 or less, the team as a whole meets the requirements of any team
  # rules, and at least one subset of the team meets the requirements of any
  # subset rules. Each Pokemon in the team must be valid.
  def canRegisterTeam?(team)
    if !team || team.length<self.minTeamLength
      return false
    end
    if team.length>self.maxTeamLength
      return false
    end
    teamNumber=[self.maxLength,team.length].min
    for pokemon in team
      if !isPokemonValid?(pokemon)
        return false
      end
    end
    for rule in @teamRules
      if !rule.isValid?(team)
        return false
      end
    end
    if @subsetRules.length>0
      pbEachCombination(team,teamNumber) { |comb|
        isValid=true
        for rule in @subsetRules
          next if rule.isValid?(comb)
          isValid=false
          break
        end
        return true if isValid
      }
      return false
    end
    return true
  end

  # Returns true if the team's length is greater or equal to the suggested number
  # and at least one subset of the team meets the requirements of any team rules
  # and subset rules. Not all Pokemon in the team have to be valid.
  def hasValidTeam?(team)
    return false if !team || team.length<self.minTeamLength
    teamNumber=[self.maxLength,team.length].min
    validPokemon=[]
    for pokemon in team
      validPokemon.push(pokemon) if isPokemonValid?(pokemon)
    end
    return false if validPokemon.length<teamNumber
    if @teamRules.length>0
      pbEachCombination(team,teamNumber) { |comb| return true if isValid?(comb) }
      return false
    end
    return true
  end

  # Returns true if the team's length meets the subset length range requirements
  # and the team meets the requirements of any team rules and subset rules. Each
  # Pokemon in the team must be valid.
  def isValid?(team,error=nil)
    if team.length<self.minLength
      error.push(_INTL("Choose a Pokémon.")) if error && self.minLength==1
      error.push(_INTL("{1} Pokémon are needed.",self.minLength)) if error && self.minLength>1
      return false
    elsif team.length>self.maxLength
      error.push(_INTL("No more than {1} Pokémon may enter.",self.maxLength)) if error
      return false
    end
    for pokemon in team
      if !isPokemonValid?(pokemon)
        if pokemon
          error.push(_INTL("This team is not allowed.", pokemon.name)) if error
        else
          error.push(_INTL("{1} is not allowed.", pokemon.name)) if error
        end
        return false
      end
    end
    for rule in @teamRules
      if !rule.isValid?(team)
        error.push(rule.errorMessage) if error
        return false
      end
    end
    for rule in @subsetRules
      if !rule.isValid?(team)
        error.push(rule.errorMessage) if error
        return false
      end
    end
    return true
  end
end



class BattleType
  def pbCreateBattle(scene,trainer1,trainer2)
    return PokeBattle_Battle.new(scene,
       trainer1.party,trainer2.party,trainer1,trainer2)
  end
end



class BattleTower < BattleType
  def pbCreateBattle(scene,trainer1,trainer2)
    return PokeBattle_RecordedBattle.new(scene,
       trainer1.party,trainer2.party,trainer1,trainer2)
  end
end



class BattlePalace < BattleType
  def pbCreateBattle(scene,trainer1,trainer2)
    return PokeBattle_RecordedBattlePalace.new(scene,
       trainer1.party,trainer2.party,trainer1,trainer2)
  end
end



class BattleArena < BattleType
  def pbCreateBattle(scene,trainer1,trainer2)
    return PokeBattle_RecordedBattleArena.new(scene,
       trainer1.party,trainer2.party,trainer1,trainer2)
  end
end



class BattleRule
  def setRule(battle); end
end



class DoubleBattle < BattleRule
  def setRule(battle); battle.setBattleMode("double"); end
end



class SingleBattle < BattleRule
  def setRule(battle); battle.setBattleMode("single"); end
end



class SoulDewBattleClause < BattleRule
  def setRule(battle); battle.rules["souldewclause"] = true; end
end



class SleepClause < BattleRule
  def setRule(battle); battle.rules["sleepclause"] = true; end
end



class FreezeClause < BattleRule
  def setRule(battle); battle.rules["freezeclause"] = true; end
end



class EvasionClause < BattleRule
  def setRule(battle); battle.rules["evasionclause"] = true; end
end



class OHKOClause < BattleRule
  def setRule(battle); battle.rules["ohkoclause"] = true; end
end



class PerishSongClause < BattleRule
  def setRule(battle); battle.rules["perishsong"] = true; end
end



class SelfKOClause < BattleRule
  def setRule(battle); battle.rules["selfkoclause"] = true; end
end



class SelfdestructClause < BattleRule
  def setRule(battle); battle.rules["selfdestructclause"] = true; end
end



class SonicBoomClause < BattleRule
  def setRule(battle); battle.rules["sonicboomclause"] = true; end
end



class ModifiedSleepClause < BattleRule
  def setRule(battle); battle.rules["modifiedsleepclause"] = true; end
end



class SkillSwapClause < BattleRule
  def setRule(battle); battle.rules["skillswapclause"] = true; end
end



class PokemonChallengeRules
  attr_reader :ruleset
  attr_reader :battletype
  attr_reader :levelAdjustment

  def initialize(ruleset=nil)
    @ruleset=ruleset ? ruleset : PokemonRuleSet.new
    @battletype=BattleTower.new
    @levelAdjustment=nil
    @battlerules=[]
  end

  def copy
    ret=PokemonChallengeRules.new(@ruleset.copy)
    ret.setBattleType(@battletype)
    ret.setLevelAdjustment(@levelAdjustment)
    for rule in @battlerules
      ret.addBattleRule(rule)
    end
    return ret
  end

  def number
    return self.ruleset.number
  end

  def setNumber(number)
    self.ruleset.setNumber(number)
    return self
  end

  def setDoubleBattle(value)
    if value
      self.ruleset.setNumber(4)
      self.addBattleRule(DoubleBattle.new)
    else
      self.ruleset.setNumber(3)
      self.addBattleRule(SingleBattle.new)
    end
    return self
  end

  def adjustLevelsBilateral(party1,party2)
    if @levelAdjustment && @levelAdjustment.type==LevelAdjustment::BothTeams
      return @levelAdjustment.adjustLevels(party1,party2)
    else
      return nil
    end
  end

  def unadjustLevelsBilateral(party1,party2,adjusts)
    if @levelAdjustment && adjusts && @levelAdjustment.type==LevelAdjustment::BothTeams
      @levelAdjustment.unadjustLevels(party1,party2,adjusts)
    end
  end

  def adjustLevels(party1,party2)
    if @levelAdjustment
      return @levelAdjustment.adjustLevels(party1,party2)
    else
      return nil
    end
  end

  def unadjustLevels(party1,party2,adjusts)
    if @levelAdjustment && adjusts
      @levelAdjustment.unadjustLevels(party1,party2,adjusts)
    end
  end

  def addPokemonRule(rule)
    self.ruleset.addPokemonRule(rule)
    return self
  end

  def addLevelRule(minLevel,maxLevel,totalLevel)
    self.addPokemonRule(MinimumLevelRestriction.new(minLevel))
    self.addPokemonRule(MaximumLevelRestriction.new(maxLevel))
    self.addSubsetRule(TotalLevelRestriction.new(totalLevel))
    self.setLevelAdjustment(TotalLevelAdjustment.new(minLevel,maxLevel,totalLevel))
    return self
  end

  def addSubsetRule(rule)
    self.ruleset.addSubsetRule(rule)
    return self
  end

  def addTeamRule(rule)
    self.ruleset.addTeamRule(rule)
    return self
  end

  def addBattleRule(rule)
    @battlerules.push(rule)
    return self
  end

  def createBattle(scene,trainer1,trainer2)
    battle=@battletype.pbCreateBattle(scene,trainer1,trainer2)
    for p in @battlerules
      p.setRule(battle)
    end
    return battle
  end

  def setRuleset(rule)
    @ruleset=rule
    return self
  end

  def setBattleType(rule)
    @battletype=rule
    return self
  end

  def setLevelAdjustment(rule)
    @levelAdjustment=rule
    return self
  end
end



###########################################
#  Generation IV Cups
###########################################
class StandardRules < PokemonRuleSet
  attr_reader :number

  def initialize(number,level=nil)
    super(number)
    addPokemonRule(StandardRestriction.new)
    addPokemonRule(SpeciesClause.new)
    addPokemonRule(ItemClause.new)
    if level
      addPokemonRule(MaximumLevelRestriction.new(level))
    end
  end
end



class StandardCup < StandardRules
  def initialize
    super(3,50)
  end

  def name
    return _INTL("STANDARD Cup")
  end
end



class DoubleCup < StandardRules
  def initialize
    super(4,50)
  end

  def name
    return _INTL("DOUBLE Cup")
  end
end



class FancyCup < PokemonRuleSet
  def initialize
    super(3)
    addPokemonRule(StandardRestriction.new)
    addPokemonRule(MaximumLevelRestriction.new(30))
    addSubsetRule(TotalLevelRestriction.new(80))
    addPokemonRule(HeightRestriction.new(2))
    addPokemonRule(WeightRestriction.new(20))
    addPokemonRule(BabyRestriction.new)
    addPokemonRule(SpeciesClause.new)
    addPokemonRule(ItemClause.new)
  end

  def name
    return _INTL("FANCY Cup")
  end
end



class LittleCup < PokemonRuleSet
  def initialize
    super(3)
    addPokemonRule(StandardRestriction.new)
    addPokemonRule(MaximumLevelRestriction.new(5))
    addPokemonRule(BabyRestriction.new)
    addPokemonRule(SpeciesClause.new)
    addPokemonRule(ItemClause.new)
  end

  def name
    return _INTL("LITTLE Cup")
  end
end



class LightCup < PokemonRuleSet
  def initialize
    super(3)
    addPokemonRule(StandardRestriction.new)
    addPokemonRule(MaximumLevelRestriction.new(50))
    addPokemonRule(WeightRestriction.new(99))
    addPokemonRule(BabyRestriction.new)
    addPokemonRule(SpeciesClause.new)
    addPokemonRule(ItemClause.new)
  end
  def name
    return _INTL("LIGHT Cup")
  end
end



###########################################
#  Stadium Cups
###########################################
def pbPikaCupRules(double)
  ret=PokemonChallengeRules.new
  ret.addPokemonRule(StandardRestriction.new)
  ret.addLevelRule(15,20,50)
  ret.addTeamRule(SpeciesClause.new)
  ret.addTeamRule(ItemClause.new)
  ret.addBattleRule(SleepClause.new)
  ret.addBattleRule(FreezeClause.new)
  ret.addBattleRule(SelfKOClause.new)
  ret.setDoubleBattle(double).setNumber(3)
  return ret
end

def pbPokeCupRules(double)
  ret=PokemonChallengeRules.new
  ret.addPokemonRule(StandardRestriction.new)
  ret.addLevelRule(50,55,155)
  ret.addTeamRule(SpeciesClause.new)
  ret.addTeamRule(ItemClause.new)
  ret.addBattleRule(SleepClause.new)
  ret.addBattleRule(FreezeClause.new)
  ret.addBattleRule(SelfdestructClause.new)
  ret.setDoubleBattle(double).setNumber(3)
  return ret
end

def pbPrimeCupRules(double)
  ret=PokemonChallengeRules.new
  ret.setLevelAdjustment(OpenLevelAdjustment.new(PBExperience.maxLevel))
  ret.addTeamRule(SpeciesClause.new)
  ret.addTeamRule(ItemClause.new)
  ret.addBattleRule(SleepClause.new)
  ret.addBattleRule(FreezeClause.new)
  ret.addBattleRule(SelfdestructClause.new)
  ret.setDoubleBattle(double)
  return ret
end

def pbFancyCupRules(double)
  ret=PokemonChallengeRules.new
  ret.addPokemonRule(StandardRestriction.new)
  ret.addLevelRule(25,30,80)
  ret.addPokemonRule(HeightRestriction.new(2))
  ret.addPokemonRule(WeightRestriction.new(20))
  ret.addPokemonRule(BabyRestriction.new)
  ret.addTeamRule(SpeciesClause.new)
  ret.addTeamRule(ItemClause.new)
  ret.addBattleRule(SleepClause.new)
  ret.addBattleRule(FreezeClause.new)
  ret.addBattleRule(PerishSongClause.new)
  ret.addBattleRule(SelfdestructClause.new)
  ret.setDoubleBattle(double).setNumber(3)
  return ret
end

def pbLittleCupRules(double)
  ret=PokemonChallengeRules.new
  ret.addPokemonRule(StandardRestriction.new)
  ret.addPokemonRule(UnevolvedFormRestriction.new)
  ret.setLevelAdjustment(EnemyLevelAdjustment.new(5))
  ret.addPokemonRule(MaximumLevelRestriction.new(5))
  ret.addTeamRule(SpeciesClause.new)
  ret.addTeamRule(ItemClause.new)
  ret.addBattleRule(SleepClause.new)
  ret.addBattleRule(FreezeClause.new)
  ret.addBattleRule(SelfdestructClause.new)
  ret.addBattleRule(PerishSongClause.new)
  ret.addBattleRule(SonicBoomClause.new)
  ret.setDoubleBattle(double)
  return ret
end

def pbStrictLittleCupRules(double)
  ret=PokemonChallengeRules.new
  ret.addPokemonRule(StandardRestriction.new)
  ret.addPokemonRule(UnevolvedFormRestriction.new)
  ret.setLevelAdjustment(EnemyLevelAdjustment.new(5))
  ret.addPokemonRule(MaximumLevelRestriction.new(5))
  ret.addPokemonRule(LittleCupRestriction.new)
  ret.addTeamRule(SpeciesClause.new)
  ret.addBattleRule(SleepClause.new)
  ret.addBattleRule(EvasionClause.new)
  ret.addBattleRule(OHKOClause.new)
  ret.addBattleRule(SelfKOClause.new)
  ret.setDoubleBattle(double).setNumber(3)
  return ret
end



###########################################
#  Battle Frontier Rules
###########################################
def pbBattleTowerRules(double,openlevel)
  ret=PokemonChallengeRules.new
  if openlevel
    ret.setLevelAdjustment(OpenLevelAdjustment.new(60))
  else
    ret.setLevelAdjustment(CappedLevelAdjustment.new(50))
  end
  ret.addPokemonRule(StandardRestriction.new)
  ret.addTeamRule(SpeciesClause.new)
  ret.addTeamRule(ItemClause.new)
  ret.addBattleRule(SoulDewBattleClause.new)
  ret.setDoubleBattle(double)
  return ret
end

def pbBattlePalaceRules(double,openlevel)
  return pbBattleTowerRules(double,openlevel).setBattleType(BattlePalace.new)
end

def pbBattleArenaRules(openlevel)
  return pbBattleTowerRules(false,openlevel).setBattleType(BattleArena.new)
end

def pbBattleFactoryRules(double,openlevel)
  ret=PokemonChallengeRules.new
  if openlevel
    ret.setLevelAdjustment(FixedLevelAdjustment.new(100))
    ret.addPokemonRule(MaximumLevelRestriction.new(100))
  else
    ret.setLevelAdjustment(FixedLevelAdjustment.new(50))
    ret.addPokemonRule(MaximumLevelRestriction.new(50))
  end
  ret.addTeamRule(SpeciesClause.new)
  ret.addPokemonRule(BannedSpeciesRestriction.new(:UNOWN))
  ret.addTeamRule(ItemClause.new)
  ret.addBattleRule(SoulDewBattleClause.new)
  ret.setDoubleBattle(double).setNumber(0)
  return ret
end



=begin
###########################################
# Other Interesting Rulesets
###########################################

# Official Species Restriction
.addPokemonRule(BannedSpeciesRestriction.new(
   :MEWTWO,:MEW,
   :LUGIA,:HOOH,:CELEBI,
   :KYOGRE,:GROUDON,:RAYQUAZA,:JIRACHI,:DEOXYS,
   :DIALGA,:PALKIA,:GIRATINA,:MANAPHY,:PHIONE,
   :DARKRAI,:SHAYMIN,:ARCEUS))
.addBattleRule(SoulDewBattleClause.new)



# New Official Species Restriction
.addPokemonRule(BannedSpeciesRestriction.new(
   :MEW,
   :CELEBI,
   :JIRACHI,:DEOXYS,
   :MANAPHY,:PHIONE,:DARKRAI,:SHAYMIN,:ARCEUS))
.addBattleRule(SoulDewBattleClause.new)



# Pocket Monsters Stadium
PokemonChallengeRules.new
.addPokemonRule(SpeciesRestriction.new(
   :VENUSAUR,:CHARIZARD,:BLASTOISE,:BEEDRILL,:FEAROW,
   :PIKACHU,:NIDOQUEEN,:NIDOKING,:DUGTRIO,:PRIMEAPE,
   :ARCANINE,:ALAKAZAM,:MACHAMP,:GOLEM,:MAGNETON,
   :CLOYSTER,:GENGAR,:ONIX,:HYPNO,:ELECTRODE,
   :EXEGGUTOR,:CHANSEY,:KANGASKHAN,:STARMIE,:SCYTHER,
   :JYNX,:PINSIR,:TAUROS,:GYARADOS,:LAPRAS,
   :DITTO,:VAPOREON,:JOLTEON,:FLAREON,:AERODACTYL,
   :SNORLAX,:ARTICUNO,:ZAPDOS,:MOLTRES,:DRAGONITE
))



# 1999 Tournament Rules
PokemonChallengeRules.new
.addTeamRule(SpeciesClause.new)
.addPokemonRule(ItemsDisallowedClause.new)
.addBattleRule(SleepClause.new)
.addBattleRule(FreezeClause.new)
.addBattleRule(SelfdestructClause.new)
.setDoubleBattle(false)
.setLevelRule(1,50,150)
.addPokemonRule(BannedSpeciesRestriction.new(
   :VENUSAUR,:DUGTRIO,:ALAKAZAM,:GOLEM,:MAGNETON,
   :GENGAR,:HYPNO,:ELECTRODE,:EXEGGUTOR,:CHANSEY,
   :KANGASKHAN,:STARMIE,:JYNX,:TAUROS,:GYARADOS,
   :LAPRAS,:DITTO,:VAPOREON,:JOLTEON,:SNORLAX,
   :ARTICUNO,:ZAPDOS,:DRAGONITE,:MEWTWO,:MEW))



# 2005 Tournament Rules
PokemonChallengeRules.new
.addPokemonRule(BannedSpeciesRestriction.new(
   :DRAGONITE,:MEW,:MEWTWO,
   :TYRANITAR,:LUGIA,:CELEBI,:HOOH,:GROUDON,:KYOGRE,:RAYQUAZA,
   :JIRACHI,:DEOXYS))
.setDoubleBattle(true)
.addLevelRule(1,50,200)
.addTeamRule(ItemClause.new)
.addPokemonRule(BannedItemRestriction.new(:SOULDEW,:ENIGMABERRY))
.addBattleRule(SleepClause.new)
.addBattleRule(FreezeClause.new)
.addBattleRule(SelfdestructClause.new)
.addBattleRule(PerishSongClause.new)



# 2008 Tournament Rules
PokemonChallengeRules.new
.addPokemonRule(BannedSpeciesRestriction.new(
   :MEWTWO,:MEW,:TYRANITAR,:LUGIA,:HOOH,:CELEBI,
   :GROUDON,:KYOGRE,:RAYQUAZA,:JIRACHI,:DEOXYS,
   :PALKIA,:DIALGA,:PHIONE,:MANAPHY,:ROTOM,:SHAYMIN,:DARKRAI))
.setDoubleBattle(true)
.addLevelRule(1,50,200)
.addTeamRule(NicknameClause.new)
.addTeamRule(ItemClause.new)
.addBattleRule(SoulDewBattleClause.new)



# 2010 Tournament Rules
PokemonChallengeRules.new
.addPokemonRule(BannedSpeciesRestriction.new(
   :MEW,:CELEBI,:JIRACHI,:DEOXYS,
   :PHIONE,:MANAPHY,:SHAYMIN,:DARKRAI,:ARCEUS))
.addSubsetRule(RestrictedSpeciesSubsetRestriction.new(
   :MEWTWO,:LUGIA,:HOOH,
   :GROUDON,:KYOGRE,:RAYQUAZA,
   :PALKIA,:DIALGA,:GIRATINA))
.setDoubleBattle(true)
.addLevelRule(1,100,600)
.setLevelAdjustment(CappedLevelAdjustment.new(50))
.addTeamRule(NicknameClause.new)
.addTeamRule(ItemClause.new)
.addPokemonRule(SoulDewClause.new)



# Pokemon Colosseum -- Anything Goes
PokemonChallengeRules.new
.addLevelRule(1,100,600)
.addBattleRule(SleepClause.new)
.addBattleRule(FreezeClause.new)
.addBattleRule(SelfdestructClause.new)
.addBattleRule(PerishSongClause.new)



# Pokemon Colosseum -- Max Lv. 50
PokemonChallengeRules.new
.addLevelRule(1,50,300)
.addTeamRule(SpeciesClause.new)
.addTeamRule(ItemClause.new)
.addBattleRule(SleepClause.new)
.addBattleRule(FreezeClause.new)
.addBattleRule(SelfdestructClause.new)
.addBattleRule(PerishSongClause.new)



# Pokemon Colosseum -- Max Lv. 100
PokemonChallengeRules.new
.addLevelRule(1,100,600)
.addTeamRule(SpeciesClause.new)
.addTeamRule(ItemClause.new)
.addBattleRule(SleepClause.new)
.addBattleRule(FreezeClause.new)
.addBattleRule(SelfdestructClause.new)
.addBattleRule(PerishSongClause.new)



# Battle Time (includes animations)
If the time runs out, the team with the most Pok�mon left wins. If both teams have
the same number of Pokémon left, total HP remaining breaks the tie. If both HP
totals are identical, the battle is a draw.

# Command Time
If the player is in the process of switching Pokémon when the time runs out, the
one that can still battle that's closest to the top of the roster is chosen.
Otherwise, the attack on top of the list is chosen.
=end
