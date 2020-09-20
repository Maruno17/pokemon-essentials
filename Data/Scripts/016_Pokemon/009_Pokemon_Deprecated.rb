#===============================================================================
# Deprecated classes & methods for Pokémon
#===============================================================================

# @deprecated Use {Pokemon} instead. PokeBattle_Pokemon has been turned into an alias
#   and is slated to be removed in vXX.
class PokeBattle_Pokemon; end

PokeBattle_Pokemon = Pokemon

# (see Pokemon#initialize)
# @deprecated Use +Pokemon.new+ instead. This method and its aliases are
#   slated to be removed in vXX.
def pbNewPkmn(species, level, owner = $Trainer, withMoves = true)
  Kernel.echoln("WARN: pbNewPkmn and its aliases are deprecated and slated to be removed in Essentials vXX")
  return Pokemon.new(species, level, owner, withMoves)
end
alias pbGenPkmn pbNewPkmn
alias pbGenPoke pbNewPkmn