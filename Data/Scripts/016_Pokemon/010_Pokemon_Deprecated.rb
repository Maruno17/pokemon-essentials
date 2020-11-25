#===============================================================================
# Deprecated classes, methods and constants for Pokémon.
# These will be removed in a future Essentials version.
#===============================================================================

# @deprecated Use {Pokemon} instead. PokeBattle_Pokemon has been turned into an alias
#   and is slated to be removed in v20.
class PokeBattle_Pokemon; end

PokeBattle_Pokemon = Pokemon

class Pokemon
  # @deprecated Use {MAX_NAME_SIZE} instead. This alias is slated to be removed in v20.
  MAX_POKEMON_NAME_SIZE = MAX_NAME_SIZE

  # @deprecated Use {Owner#public_id} instead. This alias is slated to be removed in v20.
  def publicID
    Deprecation.warn_method('Pokemon#publicID', 'v20', 'Pokemon::Owner#public_id')
    return @owner.public_id
  end

  # @deprecated Use {Owner#id} instead. This alias is slated to be removed in v20.
  def trainerID
    Deprecation.warn_method('Pokemon#trainerID', 'v20', 'Pokemon::Owner#id')
    return @owner.id
  end

  # @deprecated Use {Owner#id=} instead. This alias is slated to be removed in v20.
  def trainerID=(value)
    Deprecation.warn_method('Pokemon#trainerID=', 'v20', 'Pokemon::Owner#id=')
    @owner.id = value
  end

  # @deprecated Use {Owner#name} instead. This alias is slated to be removed in v20.
  def ot
    Deprecation.warn_method('Pokemon#ot', 'v20', 'Pokemon::Owner#name')
    return @owner.name
  end

  # @deprecated Use {Owner#name=} instead. This alias is slated to be removed in v20.
  def ot=(value)
    Deprecation.warn_method('Pokemon#ot=', 'v20', 'Pokemon::Owner#name=')
    @owner.name = value
  end

  # @deprecated Use {Owner#gender} instead. This alias is slated to be removed in v20.
  def otgender
    Deprecation.warn_method('Pokemon#otgender', 'v20', 'Pokemon::Owner#gender')
    return @owner.gender
  end

  # @deprecated Use {Owner#gender=} instead. This alias is slated to be removed in v20.
  def otgender=(value)
    Deprecation.warn_method('Pokemon#otgender=', 'v20', 'Pokemon::Owner#gender=')
    @owner.gender = value
  end

  # @deprecated Use {Owner#language} instead. This alias is slated to be removed in v20.
  def language
    Deprecation.warn_method('Pokemon#language', 'v20', 'Pokemon::Owner#language')
    return @owner.language
  end

  # @deprecated Use {Owner#language=} instead. This alias is slated to be removed in v20.
  def language=(value)
    Deprecation.warn_method('Pokemon#language=', 'v20', 'Pokemon::Owner#language=')
    @owner.language = value
  end
end

# (see Pokemon#initialize)
# @deprecated Use +Pokemon.new+ instead. This method and its aliases are
#   slated to be removed in v20.
def pbNewPkmn(species, level, owner = $Trainer, withMoves = true)
  Deprecation.warn_method('pbNewPkmn', 'v20', 'Pokemon.new')
  return Pokemon.new(species, level, owner, withMoves)
end
alias pbGenPkmn pbNewPkmn
alias pbGenPoke pbNewPkmn
