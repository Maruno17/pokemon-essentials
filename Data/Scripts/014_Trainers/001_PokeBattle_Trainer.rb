class PokeBattle_Trainer
  attr_accessor :name
  attr_accessor :id
  attr_writer   :metaID
  attr_accessor :trainertype
  attr_writer   :outfit
  attr_accessor :badges
  attr_reader   :money
  attr_accessor :seen
  attr_accessor :owned
  attr_accessor :formseen
  attr_accessor :formlastseen
  attr_accessor :shadowcaught
  attr_accessor :party
  attr_accessor :pokedex    # Whether the Pokédex was obtained
  attr_accessor :pokegear   # Whether the Pokégear was obtained
  attr_writer   :language

  def trainerTypeName; return GameData::TrainerType.get(@trainertype).name;        end
  def moneyEarned;     return GameData::TrainerType.get(@trainertype).base_money;  end
  def gender;          return GameData::TrainerType.get(@trainertype).gender;      end
  def male?;           return GameData::TrainerType.get(@trainertype).male?;       end
  def female?;         return GameData::TrainerType.get(@trainertype).female?;     end
  alias isMale? male?
  alias isFemale? female?
  def skill;           return GameData::TrainerType.get(@trainertype).skill_level; end
  def skillCode;       return GameData::TrainerType.get(@trainertype).skill_code;  end

  def hasSkillCode(code)
    c = skillCode
    return c && c != "" && c[/#{code}/]
  end

  def fullname
    return _INTL("{1} {2}", trainerTypeName, @name)
  end

  #=============================================================================
  # Unique ID number
  #=============================================================================
  def publicID(id = nil)   # Portion of the ID which is visible on the Trainer Card
    return id ? id & 0xFFFF : @id & 0xFFFF
  end

  def secretID(id = nil)   # Other portion of the ID
    return id ? id >> 16 : @id >> 16
  end

  def getForeignID   # Random ID other than this Trainer's ID
    fid = 0
    loop do
      fid = rand(2 ** 16) | rand(2 ** 16) << 16
      break if fid != @id
    end
    return fid
  end

  def setForeignID(other)
    @id = other.getForeignID
  end

  def metaID
    @metaID = $PokemonGlobal.playerID if !@metaID
    @metaID = 0 if !@metaID
    return @metaID
  end

  #=============================================================================
  # Other properties
  #=============================================================================
  def outfit
    return @outfit || 0
  end

  def language
    return @language || pbGetLanguage
  end

  def money=(value)
    @money = [[value, MAX_MONEY].min, 0].max
  end

  def numbadges   # Number of badges
    ret = 0
    @badges.each { |b| ret += 1 if b }
    return ret
  end

  #=============================================================================
  # Party
  #=============================================================================
  def pokemonParty
    return @party.find_all { |p| p && !p.egg? }
  end

  def ablePokemonParty
    return @party.find_all { |p| p && !p.egg? && !p.fainted? }
  end

  def partyCount
    return @party.length
  end

  def pokemonCount
    ret = 0
    @party.each { |p| ret += 1 if p && !p.egg? }
    return ret
  end

  def ablePokemonCount
    ret = 0
    @party.each { |p| ret += 1 if p && !p.egg? && !p.fainted? }
    return ret
  end

  def firstParty
    return nil if @party.length == 0
    return @party[0]
  end

  def firstPokemon
    p = self.pokemonParty
    return nil if p.length == 0
    return p[0]
  end

  def firstAblePokemon
    p = self.ablePokemonParty
    return nil if p.length == 0
    return p[0]
  end

  def lastParty
    return nil if @party.length == 0
    return @party[@party.length - 1]
  end

  def lastPokemon
    p = self.pokemonParty
    return nil if p.length == 0
    return p[p.length - 1]
  end

  def lastAblePokemon
    p = self.ablePokemonParty
    return nil if p.length == 0
    return p[p.length - 1]
  end

  def party_full?
    return @party.length >= MAX_PARTY_SIZE
  end

  #=============================================================================
  # Pokédex
  #=============================================================================
  def pokedexSeen(region = -1)   # Number of Pokémon seen
    ret = 0
    if region == -1
      GameData::Species.each { |s| ret += 1 if s.form == 0 && @seen[s.species] }
    else
      pbAllRegionalSpecies(region).each { |s| ret += 1 if s && @seen[s] }
    end
    return ret
  end

  def pokedexOwned(region = -1)   # Number of Pokémon owned
    ret = 0
    if region == -1
      GameData::Species.each { |s| ret += 1 if s.form == 0 && @owned[s.species] }
    else
      pbAllRegionalSpecies(region).each { |s| ret += 1 if s && @owned[s] }
    end
    return ret
  end

  def numFormsSeen(species)
    species_data = GameData::Species.try_get(species)
    return 0 if !species_data
    species = species_data.species
    ret = 0
    @formseen[species] = [[], []] if !@formseen[species]
    array = @formseen[species]
    for i in 0...[array[0].length, array[1].length].max
      ret += 1 if array[0][i] || array[1][i]
    end
    return ret
  end

  def seen?(species)
    species_data = GameData::Species.try_get(species)
    return (species_data) ? @seen[species_data.species] : false
  end
  alias hasSeen? seen?

  def owned?(species)
    species_data = GameData::Species.try_get(species)
    return (species_data) ? @owned[species_data.species] : false
  end
  alias hasOwned? owned?

  def setSeen(species)
    species_data = GameData::Species.try_get(species)
    @seen[species_data.species] = true if species_data
  end

  def setOwned(species)
    species_data = GameData::Species.try_get(species)
    @owned[species_data.species] = true if species_data
  end

  def clearPokedex
    @seen         = {}
    @owned        = {}
    @formseen     = {}
    @formlastseen = {}
  end

  #=============================================================================
  # Initializing
  #=============================================================================
  def initialize(name, trainertype)
    @name              = name
    @language          = pbGetLanguage
    @trainertype       = trainertype
    @id                = rand(2 ** 16) | rand(2 ** 16) << 16
    @metaID            = 0
    @outfit            = 0
    @pokegear          = false
    @pokedex           = false
    clearPokedex
    @shadowcaught      = {}
    @badges            = []
    for i in 0...8
      @badges[i]       = false
    end
    @money             = INITIAL_MONEY
    @party             = []
  end
end
