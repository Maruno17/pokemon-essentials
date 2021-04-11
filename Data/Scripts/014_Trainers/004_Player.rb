#===============================================================================
# Trainer class for the player
#===============================================================================
class Player < Trainer
  attr_writer   :character_ID
  attr_accessor :outfit
  attr_accessor :badges
  attr_reader   :money
  attr_reader   :pokedex
  attr_accessor :has_pokedex
  attr_accessor :pokegear                # Whether the Pokégear was obtained
  attr_accessor :mystery_gift_unlocked   # Whether MG can be used from load screen
  attr_accessor :mystery_gifts           # Variable that stores downloaded MG data

  def inspect
    str = self.to_s.chop
    party_str = @party.map { |p| p.species_data.species }.inspect
    str << format(' %s @party=%s>', self.full_name, party_str)
    return str
  end

  def character_ID
    @character_ID = $PokemonGlobal.playerID || 0 if !@character_ID
    return @character_ID
  end

  def money=(value)
    @money = value.clamp(0, Settings::MAX_MONEY)
  end

  def badge_count
    ret = 0
    @badges.each { |b| ret += 1 if b }
    return ret
  end

  #=============================================================================

  def seen?(species)
    return @pokedex.seen?(species)
  end
  alias hasSeen? seen?

  def owned?(species)
    return @pokedex.owned?(species)
  end
  alias hasOwned? owned?

  #=============================================================================

  def initialize(name, trainer_type)
    super
    @character_ID          = nil
    @outfit                = 0
    @badges                = [false] * 8
    @money                 = Settings::INITIAL_MONEY
    @pokedex               = Pokedex.new
    @pokegear              = false
    @has_pokedex           = false
    @mystery_gift_unlocked = false
    @mystery_gifts         = []
  end
end
