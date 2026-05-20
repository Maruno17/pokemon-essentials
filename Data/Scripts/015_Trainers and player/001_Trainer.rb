#===============================================================================
# Basic trainer class (use a child class rather than this one)
#===============================================================================
class Trainer
  attr_accessor :trainer_type
  attr_accessor :name
  attr_accessor :id
  attr_accessor :language
  attr_accessor :party

  def initialize(name, trainer_type)
    @trainer_type = GameData::TrainerType.get(trainer_type).id
    @name         = name
    @id           = rand(2**16) | (rand(2**16) << 16)
    @language     = pbGetLanguage
    @party        = []
  end

  #-----------------------------------------------------------------------------

  def inspect
    str = super.chop
    party_str = @party.map { |pkmn| pkmn.species_data.species }.inspect
    str << sprintf(" %s @party=%s>", self.full_name, party_str)
    return str
  end

  def full_name
    return @name if has_flag?("NoName")
    return "#{trainer_type_name} #{@name}"
  end

  #-----------------------------------------------------------------------------

  # Portion of the ID which is visible on the Trainer Card
  def public_ID(id = nil)
    return id ? id & 0xFFFF : @id & 0xFFFF
  end

  # Other portion of the ID
  def secret_ID(id = nil)
    return id ? id >> 16 : @id >> 16
  end

  # Random ID other than this Trainer's ID
  def make_foreign_ID
    loop do
      ret = rand(2**16) | (rand(2**16) << 16)
      return ret if ret != @id
    end
    return 0
  end

  #-----------------------------------------------------------------------------

  def trainer_type_data
    tr_type = self.trainer_type
    return (tr_type) ? GameData::TrainerType.get(tr_type) : nil
  end

  def trainer_type_name; return trainer_type_data&.name         || "???";    end
  def base_money;        return trainer_type_data&.base_money   || 32;       end
  def gender;            return trainer_type_data&.gender       || 0;        end

  def male?
    tr_type_data = trainer_type_data
    return (tr_type_data) ? tr_type_data.male? : true
  end

  def female?
    tr_type_data = trainer_type_data
    return (tr_type_data) ? tr_type_data.female? : false
  end

  def skill_level;       return trainer_type_data&.skill_level || 32;        end
  def default_poke_ball; return trainer_type_data&.poke_ball   || :POKEBALL; end
  def flags;             return trainer_type_data&.flags       || [];        end

  def has_flag?(flag)
    tr_type_data = trainer_type_data
    return (tr_type_data) ? tr_type_data.has_flag?(flag) : false
  end

  #-----------------------------------------------------------------------------

  def pokemon_party
    return @party.find_all { |pkmn| pkmn && !pkmn.egg? }
  end

  def able_party
    return @party.find_all { |pkmn| pkmn && !pkmn.egg? && !pkmn.fainted? }
  end

  def party_count
    return @party.length
  end

  def pokemon_count
    ret = 0
    @party.each { |pkmn| ret += 1 if pkmn && !pkmn.egg? }
    return ret
  end

  def able_pokemon_count
    ret = 0
    @party.each { |pkmn| ret += 1 if pkmn && !pkmn.egg? && !pkmn.fainted? }
    return ret
  end

  def party_full?
    return party_count >= Settings::MAX_PARTY_SIZE
  end

  # Returns true if there are no usable Pokémon in the player's party.
  def all_fainted?
    return able_pokemon_count == 0
  end

  def first_party
    return @party[0]
  end

  def first_pokemon
    return pokemon_party[0]
  end

  def first_able_pokemon
    return able_party[0]
  end

  def last_party
    return (@party.length > 0) ? @party[@party.length - 1] : nil
  end

  def last_pokemon
    pkmn = pokemon_party
    return (pkmn.length > 0) ? pkmn[pkmn.length - 1] : nil
  end

  def last_able_pokemon
    pkmn = able_party
    return (pkmn.length > 0) ? pkmn[pkmn.length - 1] : nil
  end

  def remove_pokemon_at_index(index)
    return false if index < 0 || index >= party_count
    have_able = false
    @party.each_with_index do |pkmn, i|
      have_able = true if i != index && pkmn.able?
      break if have_able
    end
    return false if !have_able
    @party.delete_at(index)
    return true
  end

  # Checks whether the trainer would still have an unfainted Pokémon if the
  # Pokémon given by _index_ were removed from the party.
  def has_other_able_pokemon?(index)
    @party.each_with_index { |pkmn, i| return true if i != index && pkmn.able? }
    return false
  end

  # Returns true if there is a Pokémon of the given species in the trainer's
  # party. You may also specify a particular form it should be.
  def has_species?(species, form = -1)
    return pokemon_party.any? { |pkmn| pkmn&.isSpecies?(species) && (form < 0 || pkmn.form == form) }
  end

  # Returns whether there is a fatefully met Pokémon of the given species in the
  # trainer's party.
  def has_fateful_species?(species)
    return pokemon_party.any? { |pkmn| pkmn&.isSpecies?(species) && pkmn.obtain_method == 4 }
  end

  # Returns whether there is a Pokémon with the given type in the trainer's
  # party. excluded_pokemon is an array of Pokemon objects to ignore.
  def has_pokemon_of_type?(type, excluded_pokemon = [])
    return false if !GameData::Type.exists?(type)
    type = GameData::Type.get(type).id
    return pokemon_party.any? { |pkmn| pkmn&.hasType?(type) && !excluded_pokemon.include?(pkmn) }
  end

  # Checks whether any Pokémon in the party knows the given move, and returns
  # the first Pokémon it finds with that move, or nil if no Pokémon has that move.
  def get_pokemon_with_move(move)
    pokemon_party.each { |pkmn| return pkmn if pkmn.hasMove?(move) }
    return nil
  end

  # Fully heal all Pokémon in the party.
  def heal_party
    @party.each { |pkmn| pkmn.heal }
  end
end

#===============================================================================
# Trainer class for NPC trainers
#===============================================================================
class NPCTrainer < Trainer
  attr_accessor :version
  attr_accessor :items
  attr_accessor :lose_text
  attr_accessor :win_text

  def initialize(name, trainer_type, version = 0)
    super(name, trainer_type)
    @version   = version
    @items     = []
    @lose_text = nil
    @win_text  = nil
  end
end
