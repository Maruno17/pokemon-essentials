#===============================================================================
# Deprecated
#===============================================================================
class PlayerTrainer
  alias fullname full_name
  alias publicID public_ID
  alias secretID secret_ID
  alias getForeignID make_foreign_ID
  alias trainerTypeName trainer_type_name
  alias moneyEarned base_money
  alias skill skill_level
  alias skillCode skill_code
  alias hasSkillCode has_skill_code?
  alias pokemonParty pokemon_party
  alias ablePokemonParty able_party
  alias partyCount party_count
  alias pokemonCount pokemon_count
  alias ablePokemonCount able_pokemon_count
  alias firstParty first_party
  alias firstPokemon first_pokemon
  alias firstAblePokemon first_able_pokemon
  alias lastParty last_party
  alias lastPokemon last_pokemon
  alias lastAblePokemon last_able_pokemon
  alias formseen seen_forms
  alias formlastseen last_seen_forms
  alias shadowcaught owned_shadow
  alias numbadges badge_count
  alias pokedexSeen seen_count
  alias pokedexOwned owned_count
  alias numFormsSeen seen_forms_count
  alias clearPokedex clear_pokedex
  alias metaID character_ID
  alias mysterygiftaccess mystery_gift_unlocked
  alias mysterygift mystery_gifts
  alias setSeen set_seen
  alias setOwned set_owned
end

class PokeBattle_Trainer
  attr_reader :trainertype, :name, :id, :metaID, :outfit, :language
  attr_reader :party, :badges, :money
  attr_reader :seen, :owned, :formseen, :formlastseen, :shadowcaught
  attr_reader :pokedex, :pokegear
  attr_reader :mysterygiftaccess, :mysterygift

  def self.copy(trainer)
    validate trainer => self
    ret = PlayerTrainer.new(trainer.name, trainer.trainertype)
    ret.id                    = trainer.id
    ret.character_ID          = trainer.metaID if trainer.metaID
    ret.outfit                = trainer.outfit if trainer.outfit
    ret.language              = trainer.language if trainer.language
    trainer.party.each { |p| ret.party.push(PokeBattle_Pokemon.convert(p)) }
    ret.badges                = trainer.badges.clone
    ret.money                 = trainer.money
    trainer.seen.each_with_index { |value, i| ret.set_seen(i) if value }
    trainer.owned.each_with_index { |value, i| ret.set_owned(i) if value }
    trainer.formseen.each_with_index do |value, i|
      ret.seen_forms[GameData::Species.get(i).species] = [value[0].clone, value[1].clone] if value
    end
    trainer.formlastseen.each_with_index do |value, i|
      ret.last_seen_forms[GameData::Species.get(i).species] = value.clone if value
    end
    if trainer.shadowcaught
      trainer.shadowcaught.each_with_index do |value, i|
        ret.owned_shadow[GameData::Species.get(i).species] = true if value
      end
    end
    ret.pokedex               = trainer.pokedex
    ret.pokegear              = trainer.pokegear
    ret.mystery_gift_unlocked = trainer.mysterygiftaccess if trainer.mysterygiftaccess
    ret.mystery_gifts         = trainer.mysterygift.clone if trainer.mysterygift
    return ret
  end
end

# @deprecated Use {Trainer#remove_pokemon_at_index} instead. This alias is slated to be removed in v20.
def pbRemovePokemonAt(index)
  Deprecation.warn_method('pbRemovePokemonAt', 'v20', 'PlayerTrainer#remove_pokemon_at_index')
  return $Trainer.remove_pokemon_at_index(index)
end

# @deprecated Use {Trainer#has_other_able_pokemon?} instead. This alias is slated to be removed in v20.
def pbCheckAble(index)
  Deprecation.warn_method('pbCheckAble', 'v20', 'PlayerTrainer#has_other_able_pokemon?')
  return $Trainer.has_other_able_pokemon?(index)
end

# @deprecated Use {Trainer#all_fainted?} instead. This alias is slated to be removed in v20.
def pbAllFainted
  Deprecation.warn_method('pbAllFainted', 'v20', 'PlayerTrainer#all_fainted?')
  return $Trainer.all_fainted?
end

# @deprecated Use {Trainer#has_species?} instead. This alias is slated to be removed in v20.
def pbHasSpecies?(species, form = -1)
  Deprecation.warn_method('pbHasSpecies?', 'v20', 'PlayerTrainer#has_species?')
  return $Trainer.has_species?(species, form)
end

# @deprecated Use {Trainer#has_fateful_species?} instead. This alias is slated to be removed in v20.
def pbHasFatefulSpecies?(species)
  Deprecation.warn_method('pbHasSpecies?', 'v20', 'PlayerTrainer#has_fateful_species?')
  return $Trainer.has_fateful_species?(species)
end

# @deprecated Use {Trainer#has_pokemon_of_type?} instead. This alias is slated to be removed in v20.
def pbHasType?(type)
  Deprecation.warn_method('pbHasType?', 'v20', 'PlayerTrainer#has_pokemon_of_type?')
  return $Trainer.has_pokemon_of_type?(type)
end

# @deprecated Use {Trainer#get_pokemon_with_move} instead. This alias is slated to be removed in v20.
def pbCheckMove(move)
  Deprecation.warn_method('pbCheckMove', 'v20', 'PlayerTrainer#get_pokemon_with_move')
  return $Trainer.get_pokemon_with_move(move)
end

# @deprecated Use {Trainer#heal_party} instead. This alias is slated to be removed in v20.
def pbHealAll
  Deprecation.warn_method('pbHealAll', 'v20', 'PlayerTrainer#heal_party')
  $Trainer.heal_party
end
