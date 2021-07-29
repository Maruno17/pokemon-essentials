#===============================================================================
# Deprecated
#===============================================================================
class Trainer
  deprecated_method_alias :fullname, :full_name, removal_in: 'v20'
  deprecated_method_alias :publicID, :public_ID, removal_in: 'v20'
  deprecated_method_alias :secretID, :secret_ID, removal_in: 'v20'
  deprecated_method_alias :getForeignID, :make_foreign_ID, removal_in: 'v20'
  deprecated_method_alias :trainerTypeName, :trainer_type_name, removal_in: 'v20'
  deprecated_method_alias :isMale?, :male?, removal_in: 'v20'
  deprecated_method_alias :isFemale?, :female?, removal_in: 'v20'
  deprecated_method_alias :moneyEarned, :base_money, removal_in: 'v20'
  deprecated_method_alias :skill, :skill_level, removal_in: 'v20'
  deprecated_method_alias :skillCode, :skill_code, removal_in: 'v20'
  deprecated_method_alias :hasSkillCode, :has_skill_code?, removal_in: 'v20'
  deprecated_method_alias :pokemonParty, :pokemon_party, removal_in: 'v20'
  deprecated_method_alias :ablePokemonParty, :able_party, removal_in: 'v20'
  deprecated_method_alias :partyCount, :party_count, removal_in: 'v20'
  deprecated_method_alias :pokemonCount, :pokemon_count, removal_in: 'v20'
  deprecated_method_alias :ablePokemonCount, :able_pokemon_count, removal_in: 'v20'
  deprecated_method_alias :firstParty, :first_party, removal_in: 'v20'
  deprecated_method_alias :firstPokemon, :first_pokemon, removal_in: 'v20'
  deprecated_method_alias :firstAblePokemon, :first_able_pokemon, removal_in: 'v20'
  deprecated_method_alias :lastParty, :last_party, removal_in: 'v20'
  deprecated_method_alias :lastPokemon, :last_pokemon, removal_in: 'v20'
  deprecated_method_alias :lastAblePokemon, :last_able_pokemon, removal_in: 'v20'
end

class Player < Trainer
  class Pokedex
    # @deprecated Use {seen?} or {set_seen} instead. This alias is slated to be removed in v20.
    attr_reader :seen_forms
  end

  deprecated_method_alias :numbadges, :badge_count, removal_in: 'v20'
  deprecated_method_alias :metaID, :character_ID, removal_in: 'v20'
  deprecated_method_alias :mysterygiftaccess, :mystery_gift_unlocked, removal_in: 'v20'
  deprecated_method_alias :mysterygift, :mystery_gifts, removal_in: 'v20'
  deprecated_method_alias :hasSeen?, :seen?, removal_in: 'v20'
  deprecated_method_alias :hasOwned?, :owned?, removal_in: 'v20'
  deprecated_method_alias :pokegear, :has_pokegear, removal_in: 'v20'

  # @deprecated Use {Player::Pokedex#set_seen} instead. This alias is slated to be removed in v20.
  def setSeen(species)
    Deprecation.warn_method('Player#setSeen', 'v20', 'Player::Pokedex#set_seen(species)')
    return @pokedex.set_seen(species)
  end

  # @deprecated Use {Player::Pokedex#set_owned} instead. This alias is slated to be removed in v20.
  def setOwned(species)
    Deprecation.warn_method('Player#setOwned', 'v20', 'Player::Pokedex#set_owned(species)')
    return @pokedex.set_owned(species)
  end

  # @deprecated Use {Player::Pokedex#seen_count} instead. This alias is slated to be removed in v20.
  def pokedexSeen(dex = -1)
    Deprecation.warn_method('Player#pokedexSeen', 'v20', 'Player::Pokedex#seen_count')
    return @pokedex.seen_count(dex)
  end

  # @deprecated Use {Player::Pokedex#owned_count} instead. This alias is slated to be removed in v20.
  def pokedexOwned(dex = -1)
    Deprecation.warn_method('Player#pokedexOwned', 'v20', 'Player::Pokedex#owned_count')
    return @pokedex.owned_count(dex)
  end

  # @deprecated Use {Player::Pokedex#seen_forms_count} instead. This alias is slated to be removed in v20.
  def numFormsSeen(species)
    Deprecation.warn_method('Player#numFormsSeen', 'v20', 'Player::Pokedex#seen_forms_count')
    return @pokedex.seen_forms_count(species)
  end

  # @deprecated Use {Player::Pokedex#clear} instead. This alias is slated to be removed in v20.
  def clearPokedex
    Deprecation.warn_method('Player#clearPokedex', 'v20', 'Player::Pokedex#clear')
    return @pokedex.clear
  end
end

# @deprecated Use {Player} instead. PokeBattle_Trainer is slated to be removed in v20.
class PokeBattle_Trainer
  attr_reader :trainertype, :name, :id, :metaID, :outfit, :language
  attr_reader :party, :badges, :money
  attr_reader :seen, :owned, :formseen, :formlastseen, :shadowcaught
  attr_reader :pokedex, :pokegear
  attr_reader :mysterygiftaccess, :mysterygift

  def self.convert(trainer)
    validate trainer => self
    ret = Player.new(trainer.name, trainer.trainertype)
    ret.id                    = trainer.id
    ret.character_ID          = trainer.metaID if trainer.metaID
    ret.outfit                = trainer.outfit if trainer.outfit
    ret.language              = trainer.language if trainer.language
    trainer.party.each { |p| ret.party.push(PokeBattle_Pokemon.convert(p)) }
    ret.badges                = trainer.badges.clone
    ret.money                 = trainer.money
    trainer.seen.each_with_index { |value, i| ret.pokedex.set_seen(i, false) if value }
    trainer.owned.each_with_index { |value, i| ret.pokedex.set_owned(i, false) if value }
    trainer.formseen.each_with_index do |value, i|
      species_id = GameData::Species.try_get(i)&.species
      next if species_id.nil? || value.nil?
      ret.pokedex.seen_forms[species_id] = [value[0].clone, value[1].clone] if value
    end
    trainer.formlastseen.each_with_index do |value, i|
      species_id = GameData::Species.try_get(i)&.species
      next if species_id.nil? || value.nil?
      ret.pokedex.set_last_form_seen(species_id, value[0], value[1]) if value
    end
    if trainer.shadowcaught
      trainer.shadowcaught.each_with_index do |value, i|
        ret.pokedex.set_shadow_pokemon_owned(i) if value
      end
    end
    ret.pokedex.refresh_accessible_dexes
    ret.has_pokedex           = trainer.pokedex
    ret.has_pokegear          = trainer.pokegear
    ret.mystery_gift_unlocked = trainer.mysterygiftaccess if trainer.mysterygiftaccess
    ret.mystery_gifts         = trainer.mysterygift.clone if trainer.mysterygift
    return ret
  end
end

# @deprecated Use {Player#remove_pokemon_at_index} instead. This alias is slated to be removed in v20.
def pbRemovePokemonAt(index)
  Deprecation.warn_method('pbRemovePokemonAt', 'v20', 'Player#remove_pokemon_at_index')
  return $Trainer.remove_pokemon_at_index(index)
end

# @deprecated Use {Player#has_other_able_pokemon?} instead. This alias is slated to be removed in v20.
def pbCheckAble(index)
  Deprecation.warn_method('pbCheckAble', 'v20', 'Player#has_other_able_pokemon?')
  return $Trainer.has_other_able_pokemon?(index)
end

# @deprecated Use {Player#all_fainted?} instead. This alias is slated to be removed in v20.
def pbAllFainted
  Deprecation.warn_method('pbAllFainted', 'v20', 'Player#all_fainted?')
  return $Trainer.all_fainted?
end

# @deprecated Use {Player#has_species?} instead. This alias is slated to be removed in v20.
def pbHasSpecies?(species, form = -1)
  Deprecation.warn_method('pbHasSpecies?', 'v20', 'Player#has_species?')
  return $Trainer.has_species?(species, form)
end

# @deprecated Use {Player#has_fateful_species?} instead. This alias is slated to be removed in v20.
def pbHasFatefulSpecies?(species)
  Deprecation.warn_method('pbHasFatefulSpecies?', 'v20', 'Player#has_fateful_species?')
  return $Trainer.has_fateful_species?(species)
end

# @deprecated Use {Player#has_pokemon_of_type?} instead. This alias is slated to be removed in v20.
def pbHasType?(type)
  Deprecation.warn_method('pbHasType?', 'v20', 'Player#has_pokemon_of_type?')
  return $Trainer.has_pokemon_of_type?(type)
end

# @deprecated Use {Player#get_pokemon_with_move} instead. This alias is slated to be removed in v20.
def pbCheckMove(move)
  Deprecation.warn_method('pbCheckMove', 'v20', 'Player#get_pokemon_with_move')
  return $Trainer.get_pokemon_with_move(move)
end

# @deprecated Use {Player#heal_party} instead. This alias is slated to be removed in v20.
def pbHealAll
  Deprecation.warn_method('pbHealAll', 'v20', 'Player#heal_party')
  $Trainer.heal_party
end

# @deprecated Use {Player::Pokedex#unlock} instead. This alias is slated to be removed in v20.
def pbUnlockDex(dex=-1)
  Deprecation.warn_method('pbUnlockDex', 'v20', '$Trainer.pokedex.unlock(dex)')
  $Trainer.pokedex.unlock(dex)
end

# @deprecated Use {Player::Pokedex#lock} instead. This alias is slated to be removed in v20.
def pbLockDex(dex=-1)
  Deprecation.warn_method('pbLockDex', 'v20', '$Trainer.pokedex.lock(dex)')
  $Trainer.pokedex.lock(dex)
end

# @deprecated Use {Player::Pokedex#register} instead. This alias is slated to be removed in v20.
def pbSeenForm(species, gender = 0, form = 0)
  Deprecation.warn_method('pbSeenForm', 'v20', '$Trainer.pokedex.register(species, gender, form)')
  $Trainer.pokedex.register(species, gender, form)
end

# @deprecated Use {Player::Pokedex#register_last_seen} instead. This alias is slated to be removed in v20.
def pbUpdateLastSeenForm(pkmn)
  Deprecation.warn_method('Player#pokedexSeen', 'v20', '$Trainer.pokedex.register_last_seen(pkmn)')
  $Trainer.pokedex.register_last_seen(pkmn)
end
