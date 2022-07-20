#===============================================================================
#
#===============================================================================
class PokemonChallengeRules
  attr_reader :ruleset
  attr_reader :battletype
  attr_reader :levelAdjustment

  def initialize(ruleset = nil)
    @ruleset         = (ruleset) ? ruleset : PokemonRuleSet.new
    @battletype      = BattleTower.new
    @levelAdjustment = nil
    @battlerules     = []
  end

  def copy
    ret = PokemonChallengeRules.new(@ruleset.copy)
    ret.setBattleType(@battletype)
    ret.setLevelAdjustment(@levelAdjustment)
    @battlerules.each do |rule|
      ret.addBattleRule(rule)
    end
    return ret
  end

  def setRuleset(rule)
    @ruleset = rule
    return self
  end

  def setBattleType(rule)
    @battletype = rule
    return self
  end

  def setLevelAdjustment(rule)
    @levelAdjustment = rule
    return self
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

  def adjustLevels(party1, party2)
    return @levelAdjustment.adjustLevels(party1, party2) if @levelAdjustment
    return nil
  end

  def unadjustLevels(party1, party2, adjusts)
    @levelAdjustment.unadjustLevels(party1, party2, adjusts) if @levelAdjustment && adjusts
  end

  def adjustLevelsBilateral(party1, party2)
    if @levelAdjustment && @levelAdjustment.type == LevelAdjustment::BothTeams
      return @levelAdjustment.adjustLevels(party1, party2)
    end
    return nil
  end

  def unadjustLevelsBilateral(party1, party2, adjusts)
    if @levelAdjustment && adjusts && @levelAdjustment.type == LevelAdjustment::BothTeams
      @levelAdjustment.unadjustLevels(party1, party2, adjusts)
    end
  end

  def addPokemonRule(rule)
    self.ruleset.addPokemonRule(rule)
    return self
  end

  def addLevelRule(minLevel, maxLevel, totalLevel)
    self.addPokemonRule(MinimumLevelRestriction.new(minLevel))
    self.addPokemonRule(MaximumLevelRestriction.new(maxLevel))
    self.addSubsetRule(TotalLevelRestriction.new(totalLevel))
    self.setLevelAdjustment(TotalLevelAdjustment.new(minLevel, maxLevel, totalLevel))
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

  def createBattle(scene, trainer1, trainer2)
    battle = @battletype.pbCreateBattle(scene, trainer1, trainer2)
    @battlerules.each do |p|
      p.setRule(battle)
    end
    return battle
  end
end

#===============================================================================
# Stadium Cups rules
#===============================================================================
def pbPikaCupRules(double)
  ret = PokemonChallengeRules.new
  ret.addPokemonRule(StandardRestriction.new)
  ret.addLevelRule(15, 20, 50)
  ret.addTeamRule(SpeciesClause.new)
  ret.addTeamRule(ItemClause.new)
  ret.addBattleRule(SleepClause.new)
  ret.addBattleRule(FreezeClause.new)
  ret.addBattleRule(SelfKOClause.new)
  ret.setDoubleBattle(double)
  ret.setNumber(3)
  return ret
end

def pbPokeCupRules(double)
  ret = PokemonChallengeRules.new
  ret.addPokemonRule(StandardRestriction.new)
  ret.addLevelRule(50, 55, 155)
  ret.addTeamRule(SpeciesClause.new)
  ret.addTeamRule(ItemClause.new)
  ret.addBattleRule(SleepClause.new)
  ret.addBattleRule(FreezeClause.new)
  ret.addBattleRule(SelfdestructClause.new)
  ret.setDoubleBattle(double)
  ret.setNumber(3)
  return ret
end

def pbPrimeCupRules(double)
  ret = PokemonChallengeRules.new
  ret.setLevelAdjustment(OpenLevelAdjustment.new(GameData::GrowthRate.max_level))
  ret.addTeamRule(SpeciesClause.new)
  ret.addTeamRule(ItemClause.new)
  ret.addBattleRule(SleepClause.new)
  ret.addBattleRule(FreezeClause.new)
  ret.addBattleRule(SelfdestructClause.new)
  ret.setDoubleBattle(double)
  return ret
end

def pbFancyCupRules(double)
  ret = PokemonChallengeRules.new
  ret.addPokemonRule(StandardRestriction.new)
  ret.addLevelRule(25, 30, 80)
  ret.addPokemonRule(HeightRestriction.new(2))
  ret.addPokemonRule(WeightRestriction.new(20))
  ret.addPokemonRule(BabyRestriction.new)
  ret.addTeamRule(SpeciesClause.new)
  ret.addTeamRule(ItemClause.new)
  ret.addBattleRule(SleepClause.new)
  ret.addBattleRule(FreezeClause.new)
  ret.addBattleRule(PerishSongClause.new)
  ret.addBattleRule(SelfdestructClause.new)
  ret.setDoubleBattle(double)
  ret.setNumber(3)
  return ret
end

def pbLittleCupRules(double)
  ret = PokemonChallengeRules.new
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
  ret = PokemonChallengeRules.new
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
  ret.setDoubleBattle(double)
  ret.setNumber(3)
  return ret
end

#===============================================================================
# Battle Frontier rules
#===============================================================================
def pbBattleTowerRules(double, openlevel)
  ret = PokemonChallengeRules.new
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

def pbBattlePalaceRules(double, openlevel)
  return pbBattleTowerRules(double, openlevel).setBattleType(BattlePalace.new)
end

def pbBattleArenaRules(openlevel)
  return pbBattleTowerRules(false, openlevel).setBattleType(BattleArena.new)
end

def pbBattleFactoryRules(double, openlevel)
  ret = PokemonChallengeRules.new
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
  ret.setDoubleBattle(double)
  return ret
end

#===============================================================================
# Other Interesting Rulesets
#===============================================================================
=begin
# Official Species Restriction
.addPokemonRule(BannedSpeciesRestriction.new(
   :MEWTWO, :MEW,
   :LUGIA, :HOOH, :CELEBI,
   :KYOGRE, :GROUDON, :RAYQUAZA, :JIRACHI, :DEOXYS,
   :DIALGA, :PALKIA, :GIRATINA, :MANAPHY, :PHIONE,
   :DARKRAI, :SHAYMIN, :ARCEUS))
.addBattleRule(SoulDewBattleClause.new)

# New Official Species Restriction
.addPokemonRule(BannedSpeciesRestriction.new(
   :MEW,
   :CELEBI,
   :JIRACHI, :DEOXYS,
   :MANAPHY, :PHIONE, :DARKRAI, :SHAYMIN, :ARCEUS))
.addBattleRule(SoulDewBattleClause.new)

# Pocket Monsters Stadium
PokemonChallengeRules.new
.addPokemonRule(SpeciesRestriction.new(
   :VENUSAUR, :CHARIZARD, :BLASTOISE, :BEEDRILL, :FEAROW,
   :PIKACHU, :NIDOQUEEN, :NIDOKING, :DUGTRIO, :PRIMEAPE,
   :ARCANINE, :ALAKAZAM, :MACHAMP, :GOLEM, :MAGNETON,
   :CLOYSTER, :GENGAR, :ONIX, :HYPNO, :ELECTRODE,
   :EXEGGUTOR, :CHANSEY, :KANGASKHAN, :STARMIE, :SCYTHER,
   :JYNX, :PINSIR, :TAUROS, :GYARADOS, :LAPRAS,
   :DITTO, :VAPOREON, :JOLTEON, :FLAREON, :AERODACTYL,
   :SNORLAX, :ARTICUNO, :ZAPDOS, :MOLTRES, :DRAGONITE
))

# 1999 Tournament Rules
PokemonChallengeRules.new
.addTeamRule(SpeciesClause.new)
.addPokemonRule(ItemsDisallowedClause.new)
.addBattleRule(SleepClause.new)
.addBattleRule(FreezeClause.new)
.addBattleRule(SelfdestructClause.new)
.setDoubleBattle(false)
.setLevelRule(1, 50, 150)
.addPokemonRule(BannedSpeciesRestriction.new(
   :VENUSAUR, :DUGTRIO, :ALAKAZAM, :GOLEM, :MAGNETON,
   :GENGAR, :HYPNO, :ELECTRODE, :EXEGGUTOR, :CHANSEY,
   :KANGASKHAN, :STARMIE, :JYNX, :TAUROS, :GYARADOS,
   :LAPRAS, :DITTO, :VAPOREON, :JOLTEON, :SNORLAX,
   :ARTICUNO, :ZAPDOS, :DRAGONITE, :MEWTWO, :MEW))

# 2005 Tournament Rules
PokemonChallengeRules.new
.addPokemonRule(BannedSpeciesRestriction.new(
   :DRAGONITE, :MEW, :MEWTWO,
   :TYRANITAR, :LUGIA, :CELEBI, :HOOH,
   :GROUDON, :KYOGRE, :RAYQUAZA, :JIRACHI, :DEOXYS))
.setDoubleBattle(true)
.addLevelRule(1, 50, 200)
.addTeamRule(ItemClause.new)
.addPokemonRule(BannedItemRestriction.new(:SOULDEW, :ENIGMABERRY))
.addBattleRule(SleepClause.new)
.addBattleRule(FreezeClause.new)
.addBattleRule(SelfdestructClause.new)
.addBattleRule(PerishSongClause.new)

# 2008 Tournament Rules
PokemonChallengeRules.new
.addPokemonRule(BannedSpeciesRestriction.new(
   :MEWTWO, :MEW,
   :TYRANITAR, :LUGIA, :HOOH, :CELEBI,
   :GROUDON, :KYOGRE, :RAYQUAZA, :JIRACHI, :DEOXYS,
   :PALKIA, :DIALGA, :PHIONE, :MANAPHY, :ROTOM, :SHAYMIN, :DARKRAI))
.setDoubleBattle(true)
.addLevelRule(1, 50, 200)
.addTeamRule(NicknameClause.new)
.addTeamRule(ItemClause.new)
.addBattleRule(SoulDewBattleClause.new)

# 2010 Tournament Rules
PokemonChallengeRules.new
.addPokemonRule(BannedSpeciesRestriction.new(
   :MEW,
   :CELEBI,
   :JIRACHI, :DEOXYS,
   :PHIONE, :MANAPHY, :SHAYMIN, :DARKRAI, :ARCEUS))
.addSubsetRule(RestrictedSpeciesSubsetRestriction.new(
   :MEWTWO,
   :LUGIA, :HOOH,
   :GROUDON, :KYOGRE, :RAYQUAZA,
   :PALKIA, :DIALGA, :GIRATINA))
.setDoubleBattle(true)
.addLevelRule(1, 100, 600)
.setLevelAdjustment(CappedLevelAdjustment.new(50))
.addTeamRule(NicknameClause.new)
.addTeamRule(ItemClause.new)
.addPokemonRule(SoulDewClause.new)

# Pokemon Colosseum -- Anything Goes
PokemonChallengeRules.new
.addLevelRule(1, 100, 600)
.addBattleRule(SleepClause.new)
.addBattleRule(FreezeClause.new)
.addBattleRule(SelfdestructClause.new)
.addBattleRule(PerishSongClause.new)

# Pokemon Colosseum -- Max Lv. 50
PokemonChallengeRules.new
.addLevelRule(1, 50, 300)
.addTeamRule(SpeciesClause.new)
.addTeamRule(ItemClause.new)
.addBattleRule(SleepClause.new)
.addBattleRule(FreezeClause.new)
.addBattleRule(SelfdestructClause.new)
.addBattleRule(PerishSongClause.new)

# Pokemon Colosseum -- Max Lv. 100
PokemonChallengeRules.new
.addLevelRule(1, 100, 600)
.addTeamRule(SpeciesClause.new)
.addTeamRule(ItemClause.new)
.addBattleRule(SleepClause.new)
.addBattleRule(FreezeClause.new)
.addBattleRule(SelfdestructClause.new)
.addBattleRule(PerishSongClause.new)
=end
