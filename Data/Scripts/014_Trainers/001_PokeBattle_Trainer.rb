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

  def trainerTypeName   # Name of this trainer type (localized)
    return PBTrainers.getName(@trainertype) rescue _INTL("PkMn Trainer")
  end

  def fullname
    return _INTL("{1} {2}",self.trainerTypeName,@name)
  end

  def publicID(id=nil)   # Portion of the ID which is visible on the Trainer Card
    return id ? id&0xFFFF : @id&0xFFFF
  end

  def secretID(id=nil)   # Other portion of the ID
    return id ? id>>16 : @id>>16
  end

  def getForeignID   # Random ID other than this Trainer's ID
    fid=0
    loop do
      fid=rand(256)
      fid|=rand(256)<<8
      fid|=rand(256)<<16
      fid|=rand(256)<<24
      break if fid!=@id
    end
    return fid
  end

  def setForeignID(other)
    @id=other.getForeignID
  end

  def metaID
    @metaID=$PokemonGlobal.playerID if !@metaID
    @metaID=0 if !@metaID
    return @metaID
  end

  def outfit
    return @outfit || 0
  end

  def language
    return @language || pbGetLanguage
  end

  def money=(value)
    @money=[[value,MAX_MONEY].min,0].max
  end

  def moneyEarned   # Money won when trainer is defeated
    data = pbGetTrainerTypeData(@trainertype)
    return data[3] if data && data[3]
    return 30
  end

  def skill   # Skill level (for AI)
    data = pbGetTrainerTypeData(@trainertype)
    return data[8] if data && data[8]
    return 30
  end

  def skillCode
    data = pbGetTrainerTypeData(@trainertype)
    return data[9] if data && data[9]
    return ""
  end

  def hasSkillCode(code)
    c = skillCode
    return true if c && c!="" && c[/#{code}/]
    return false
  end

  def numbadges   # Number of badges
    ret = 0
    @badges.each { |b| ret += 1 if b }
    return ret
  end

  def gender
    data = pbGetTrainerTypeData(@trainertype)
    return data[7] if data && data[7]
    return 2   # Gender unknown
  end

  def male?; return self.gender==0; end
  alias isMale? male?

  def female?; return self.gender==1; end
  alias isFemale? female?

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
    return nil if @party.length==0
    return @party[0]
  end

  def firstPokemon
    p=self.pokemonParty
    return nil if p.length==0
    return p[0]
  end

  def firstAblePokemon
    p=self.ablePokemonParty
    return nil if p.length==0
    return p[0]
  end

  def lastParty
    return nil if @party.length==0
    return @party[@party.length-1]
  end

  def lastPokemon
    p=self.pokemonParty
    return nil if p.length==0
    return p[p.length-1]
  end

  def lastAblePokemon
    p=self.ablePokemonParty
    return nil if p.length==0
    return p[p.length-1]
  end

  def pokedexSeen(region=-1)   # Number of Pokémon seen
    ret=0
    if region==-1
      for i in 1..PBSpecies.maxValue
        ret+=1 if @seen[i]
      end
    else
      regionlist=pbAllRegionalSpecies(region)
      for i in regionlist
        ret+=1 if i > 0 && @seen[i]
      end
    end
    return ret
  end

  def pokedexOwned(region=-1)   # Number of Pokémon owned
    ret=0
    if region==-1
      for i in 0..PBSpecies.maxValue
        ret+=1 if @owned[i]
      end
    else
      regionlist=pbAllRegionalSpecies(region)
      for i in regionlist
        ret+=1 if @owned[i]
      end
    end
    return ret
  end

  def numFormsSeen(species)
    species=getID(PBSpecies,species)
    return 0 if species<=0
    ret=0
    array=@formseen[species]
    for i in 0...[array[0].length,array[1].length].max
      ret+=1 if array[0][i] || array[1][i]
    end
    return ret
  end

  def seen?(species)
    species=getID(PBSpecies,species)
    return species>0 ? @seen[species] : false
  end
  alias hasSeen? seen?

  def owned?(species)
    species=getID(PBSpecies,species)
    return species>0 ? @owned[species] : false
  end
  alias hasOwned? owned?

  def setSeen(species)
    species=getID(PBSpecies,species)
    @seen[species]=true if species>0
  end

  def setOwned(species)
    species=getID(PBSpecies,species)
    @owned[species]=true if species>0
  end

  def clearPokedex
    @seen         = []
    @owned        = []
    @formseen     = []
    @formlastseen = []
    for i in 1..PBSpecies.maxValue
      @seen[i]         = false
      @owned[i]        = false
      @formlastseen[i] = []
      @formseen[i]     = [[],[]]
    end
  end

  def initialize(name,trainertype)
    @name              = name
    @language          = pbGetLanguage
    @trainertype       = trainertype
    @id                = rand(256)
    @id                |= rand(256)<<8
    @id                |= rand(256)<<16
    @id                |= rand(256)<<24
    @metaID            = 0
    @outfit            = 0
    @pokegear          = false
    @pokedex           = false
    clearPokedex
    @shadowcaught      = []
    for i in 1..PBSpecies.maxValue
      @shadowcaught[i] = false
    end
    @badges            = []
    for i in 0...8
      @badges[i]       = false
    end
    @money             = INITIAL_MONEY
    @party             = []
  end
end
