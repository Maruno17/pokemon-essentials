#===============================================================================
# Deprecated classes, methods and constants for Pokémon.
# These will be removed in a future Essentials version.
#===============================================================================

# @deprecated Use {Pokemon} instead. PokeBattle_Pokemon has been turned into an alias
#   and is slated to be removed in vXX.
class PokeBattle_Pokemon; end

PokeBattle_Pokemon = Pokemon

class Pokemon
  # @deprecated Use {MAX_NAME_SIZE} instead. This alias is slated to be removed in vXX.
  MAX_POKEMON_NAME_SIZE = MAX_NAME_SIZE

  # @deprecated Use {Owner#public_id} instead. This alias is slated to be removed in vXX.
  def publicID
    Deprecation.warn_method('Pokemon#publicID', 'vXX', 'Pokemon::Owner#public_id')
    return @owner.public_id
  end

  # @deprecated Use {Owner#id} instead. This alias is slated to be removed in vXX.
  def trainerID
    Deprecation.warn_method('Pokemon#trainerID', 'vXX', 'Pokemon::Owner#id')
    return @owner.id
  end

  # @deprecated Use {Owner#id=} instead. This alias is slated to be removed in vXX.
  def trainerID=(value)
    Deprecation.warn_method('Pokemon#trainerID=', 'vXX', 'Pokemon::Owner#id=')
    @owner.id = value
  end
end

# (see Pokemon#initialize)
# @deprecated Use +Pokemon.new+ instead. This method and its aliases are
#   slated to be removed in vXX.
def pbNewPkmn(species, level, owner = $Trainer, withMoves = true)
  Deprecation.warn_method('pbNewPkmn', 'vXX', 'Pokemon.new')
  return Pokemon.new(species, level, owner, withMoves)
end
alias pbGenPkmn pbNewPkmn
alias pbGenPoke pbNewPkmn
