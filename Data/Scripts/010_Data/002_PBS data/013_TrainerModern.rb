module GameData
  class TrainerModern
    attr_reader :id
    attr_reader :id_number
    attr_reader :trainer_type
    attr_reader :real_name
    attr_reader :version
    attr_reader :items
    attr_reader :real_lose_text
    attr_reader :pokemon

    DATA = {}
    DATA_FILENAME = "trainers_modern.dat"

    SCHEMA = {
      "Items" => [:items, "*e", :Item],
      "LoseText" => [:lose_text, "s"],
      "Pokemon" => [:pokemon, "ev", :Species], # Species, level
      "Form" => [:form, "u"],
      "Name" => [:name, "s"],
      "Moves" => [:moves, "*e", :Move],
      "Ability" => [:ability, "s"],
      "AbilityIndex" => [:ability_index, "u"],
      "Item" => [:item, "e", :Item],
      "Gender" => [:gender, "e", { "M" => 0, "m" => 0, "Male" => 0, "male" => 0, "0" => 0,
                                   "F" => 1, "f" => 1, "Female" => 1, "female" => 1, "1" => 1 }],
      "Nature" => [:nature, "e", :Nature],
      "IV" => [:iv, "uUUUUU"],
      "EV" => [:ev, "uUUUUU"],
      "Happiness" => [:happiness, "u"],
      "Shiny" => [:shininess, "b"],
      "Shadow" => [:shadowness, "b"],
      "Ball" => [:poke_ball, "s"],
    }

    extend ClassMethods
    include InstanceMethods

    # @param tr_type [Symbol, String]
    # @param tr_name [String]
    # @param tr_version [Integer, nil]
    # @return [Boolean] whether the given other is defined as a self
    def self.exists?(tr_type, tr_name, tr_version = 0)
      validate tr_type => [Symbol, String]
      validate tr_name => [String]
      key = [tr_type.to_sym, tr_name, tr_version]
      return !self::DATA[key].nil?
    end

    # @param tr_type [Symbol, String]
    # @param tr_name [String]
    # @param tr_version [Integer, nil]
    # @return [self]
    def self.get(tr_type, tr_name, tr_version = 0)
      validate tr_type => [Symbol, String]
      validate tr_name => [String]
      key = [tr_type.to_sym, tr_name, tr_version]
      raise "Unknown trainer #{tr_type} #{tr_name} #{tr_version}." unless self::DATA.has_key?(key)
      return self::DATA[key]
    end

    # @param tr_type [Symbol, String]
    # @param tr_name [String]
    # @param tr_version [Integer, nil]
    # @return [self, nil]
    def self.try_get(tr_type, tr_name, tr_version = 0)
      validate tr_type => [Symbol, String]
      validate tr_name => [String]
      key = [tr_type.to_sym, tr_name, tr_version]
      return (self::DATA.has_key?(key)) ? self::DATA[key] : nil
    end

    def self.list_all()
      return self::DATA
    end

    def initialize(hash)
      @id = hash[:id]
      @id_number = hash[:id_number]
      @trainer_type = hash[:trainer_type]
      @real_name = hash[:name] || "Unnamed"
      @version = hash[:version] || 0
      @items = hash[:items] || []
      @real_lose_text = hash[:lose_text] || "..."
      @pokemon = hash[:pokemon] || []
      @pokemon.each do |pkmn|
        GameData::Stat.each_main do |s|
          pkmn[:iv][s.id] ||= 0 if pkmn[:iv]
          pkmn[:ev][s.id] ||= 0 if pkmn[:ev]
        end
      end
    end

    # @return [String] the translated name of this trainer
    def name
      return pbGetMessageFromHash(MessageTypes::TrainerNames, @real_name)
    end

    # @return [String] the translated in-battle lose message of this trainer
    def lose_text
      return pbGetMessageFromHash(MessageTypes::TrainerLoseText, @real_lose_text)
    end

    def replace_species_with_placeholder(species)
      case species
      when Settings::RIVAL_STARTER_PLACEHOLDER_SPECIES
        return pbGet(Settings::RIVAL_STARTER_PLACEHOLDER_VARIABLE)
      when Settings::VAR_1_PLACEHOLDER_SPECIES
        return pbGet(1)
      when Settings::VAR_2_PLACEHOLDER_SPECIES
        return pbGet(2)
      when Settings::VAR_3_PLACEHOLDER_SPECIES
        return pbGet(3)
      end
    end

    def generateRandomChampionSpecies(old_species)
      customsList = getCustomSpeciesList()
      bst_range = pbGet(VAR_RANDOMIZER_TRAINER_BST)
      new_species = $game_switches[SWITCH_RANDOM_GYM_CUSTOMS] ? getSpecies(getNewCustomSpecies(old_species, customsList, bst_range)) : getSpecies(getNewSpecies(old_species, bst_range))
      #every pokemon should be fully evolved
      evolved_species_id = getEvolution(new_species)
      evolved_species_id = getEvolution(evolved_species_id)
      evolved_species_id = getEvolution(evolved_species_id)
      evolved_species_id = getEvolution(evolved_species_id)
      return getSpecies(evolved_species_id)
    end

    def generateRandomGymSpecies(old_species)
      gym_index = pbGet(VAR_CURRENT_GYM_TYPE)
      return old_species if gym_index == -1
      return generateRandomChampionSpecies(old_species) if gym_index == 999
      type_id = pbGet(VAR_GYM_TYPES_ARRAY)[gym_index]
      return old_species if type_id == -1

      customsList = getCustomSpeciesList()
      bst_range = pbGet(VAR_RANDOMIZER_TRAINER_BST)
      gym_type = GameData::Type.get(type_id)
      while true
        new_species = $game_switches[SWITCH_RANDOM_GYM_CUSTOMS] ? getSpecies(getNewCustomSpecies(old_species, customsList, bst_range)) : getSpecies(getNewSpecies(old_species, bst_range))
        if new_species.hasType?(gym_type)
          return new_species
        end
      end
    end

    def replace_species_to_randomized_gym(species, trainerId, pokemonIndex)
      if $PokemonGlobal.randomGymTrainersHash == nil
        $PokemonGlobal.randomGymTrainersHash = {}
      end
      if $game_switches[SWITCH_RANDOM_GYM_PERSIST_TEAMS] && $PokemonGlobal.randomGymTrainersHash != nil
        if $PokemonGlobal.randomGymTrainersHash[trainerId] != nil && $PokemonGlobal.randomGymTrainersHash[trainerId].length >= $PokemonGlobal.randomTrainersHash[trainerId].length
          return getSpecies($PokemonGlobal.randomGymTrainersHash[trainerId][pokemonIndex])
        end
      end
      new_species = generateRandomGymSpecies(species)
      if $game_switches[SWITCH_RANDOM_GYM_PERSIST_TEAMS]
        add_generated_species_to_gym_array(new_species, trainerId)
      end
      return new_species
    end

    def add_generated_species_to_gym_array(new_species, trainerId)
      if (new_species.is_a?(Symbol))
        id = new_species
      else
        id = new_species.id_number
      end

      expected_team_length = 1
      expected_team_length = $PokemonGlobal.randomTrainersHash[trainerId].length if $PokemonGlobal.randomTrainersHash[trainerId]
      new_team = []
      if $PokemonGlobal.randomGymTrainersHash[trainerId]
        new_team = $PokemonGlobal.randomGymTrainersHash[trainerId]
      end
      if new_team.length < expected_team_length
        new_team << id
      end
      $PokemonGlobal.randomGymTrainersHash[trainerId] = new_team
    end

    def replace_species_to_randomized_regular(species, trainerId, pokemonIndex)
      if $PokemonGlobal.randomTrainersHash[trainerId] == nil
        Kernel.pbMessage(_INTL("The trainers need to be re-shuffled."))
        Kernel.pbShuffleTrainers()
      end
      new_species_dex = $PokemonGlobal.randomTrainersHash[trainerId][pokemonIndex]
      return getSpecies(new_species_dex)
    end

    def isGymBattle
      return ($game_switches[SWITCH_RANDOM_TRAINERS] && ($game_variables[VAR_CURRENT_GYM_TYPE] != -1) || ($game_switches[SWITCH_FIRST_RIVAL_BATTLE] && $game_switches[SWITCH_RANDOM_STARTERS]))
    end

    def replace_species_to_randomized(species, trainerId, pokemonIndex)
      return species if $game_switches[SWITCH_FIRST_RIVAL_BATTLE]
      if isGymBattle() && $game_switches[SWITCH_RANDOMIZE_GYMS_SEPARATELY]
        return replace_species_to_randomized_gym(species, trainerId, pokemonIndex)
      end
      return replace_species_to_randomized_regular(species, trainerId, pokemonIndex)

    end

    def replaceSingleSpeciesModeIfApplicable(species)
      if $game_switches[SWITCH_SINGLE_POKEMON_MODE]
        if $game_switches[SWITCH_SINGLE_POKEMON_MODE_HEAD]
          return replaceFusionsHeadWithSpecies(species)
        elsif $game_switches[SWITCH_SINGLE_POKEMON_MODE_BODY]
          return replaceFusionsBodyWithSpecies(species)
        elsif $game_switches[SWITCH_SINGLE_POKEMON_MODE_RANDOM]
          if (rand(2) == 0)
            return replaceFusionsHeadWithSpecies(species)
          else
            return replaceFusionsBodyWithSpecies(species)
          end
        end
      end
      return species
    end

    def replaceFusionsHeadWithSpecies(species)
      speciesId = getDexNumberForSpecies(species)
      if speciesId > NB_POKEMON
        bodyPoke = getBodyID(speciesId)
        headPoke = pbGet(VAR_SINGLE_POKEMON_MODE)
        newSpecies = bodyPoke * NB_POKEMON + headPoke
        return getPokemon(newSpecies)
      end
      return species
    end

    def replaceFusionsBodyWithSpecies(species)
      speciesId = getDexNumberForSpecies(species)
      if speciesId > NB_POKEMON
        bodyPoke = pbGet(VAR_SINGLE_POKEMON_MODE)
        headPoke = getHeadID(species)
        newSpecies = bodyPoke * NB_POKEMON + headPoke
        return getPokemon(newSpecies)
      end
      return species
    end

    def to_trainer
      placeholder_species = [Settings::RIVAL_STARTER_PLACEHOLDER_SPECIES,
                             Settings::VAR_1_PLACEHOLDER_SPECIES,
                             Settings::VAR_2_PLACEHOLDER_SPECIES,
                             Settings::VAR_3_PLACEHOLDER_SPECIES]
      # Determine trainer's name
      tr_name = self.name
      Settings::RIVAL_NAMES.each do |rival|
        next if rival[0] != @trainer_type || !$game_variables[rival[1]].is_a?(String)
        tr_name = $game_variables[rival[1]]
        break
      end
      # Create trainer object
      trainer = NPCTrainer.new(tr_name, @trainer_type)
      trainer.id = $Trainer.make_foreign_ID
      trainer.items = @items.clone
      trainer.lose_text = self.lose_text

      isRematch = $game_switches[SWITCH_IS_REMATCH]
      isPlayingRandomized = $game_switches[SWITCH_RANDOM_TRAINERS] && !$game_switches[SWITCH_FIRST_RIVAL_BATTLE]
      rematchId = getRematchId(trainer.name, trainer.trainer_type)

      # Create each Pokémon owned by the trainer
      index = 0
      @pokemon.each do |pkmn_data|
        #replace placeholder species infinite fusion edit
        species = GameData::Species.get(pkmn_data[:species]).species
        original_species = species
        if placeholder_species.include?(species)
          species = replace_species_with_placeholder(species)
        else
          species = replace_species_to_randomized(species, self.id, index) if isPlayingRandomized
        end
        species = replaceSingleSpeciesModeIfApplicable(species)
        if $game_switches[SWITCH_REVERSED_MODE]
          species = reverseFusionSpecies(species)
        end
        level = pkmn_data[:level]
        if $game_switches[SWITCH_GAME_DIFFICULTY_HARD]
          level = (level * Settings::HARD_MODE_LEVEL_MODIFIER).ceil
          if level > Settings::MAXIMUM_LEVEL
            level = Settings::MAXIMUM_LEVEL
          end
        end

        if $game_switches[Settings::OVERRIDE_BATTLE_LEVEL_SWITCH]
          override_level = $game_variables[Settings::OVERRIDE_BATTLE_LEVEL_VALUE_VAR]
          if override_level.is_a?(Integer)
            level = override_level
          end
        end
        ####

        #trainer rematch infinite fusion edit
        if isRematch
          nbRematch = getNumberRematch(rematchId)
          level = getRematchLevel(level, nbRematch)
          species = evolveRematchPokemon(nbRematch, species)
        end

        pkmn = Pokemon.new(species, level, trainer, false)

        trainer.party.push(pkmn)
        # Set Pokémon's properties if defined
        if pkmn_data[:form]
          pkmn.forced_form = pkmn_data[:form] if MultipleForms.hasFunction?(species, "getForm")
          pkmn.form_simple = pkmn_data[:form]
        end

        if $game_switches[SWITCH_RANDOM_HELD_ITEMS]
          pkmn.item = pbGetRandomHeldItem().id
        else
          pkmn.item = pkmn_data[:item]
        end
        if pkmn_data[:moves] && pkmn_data[:moves].length > 0 && original_species == species
          pkmn_data[:moves].each { |move| pkmn.learn_move(move) }
        else
          pkmn.reset_moves
        end
        pkmn.ability_index = pkmn_data[:ability_index]
        pkmn.ability = pkmn_data[:ability]
        pkmn.gender = pkmn_data[:gender] || ((trainer.male?) ? 0 : 1)
        pkmn.shiny = (pkmn_data[:shininess]) ? true : false
        if pkmn_data[:nature]
          pkmn.nature = pkmn_data[:nature]
        else
          nature = pkmn.species_data.id_number + GameData::TrainerType.get(trainer.trainer_type).id_number
          pkmn.nature = nature % (GameData::Nature::DATA.length / 2)
        end
        GameData::Stat.each_main do |s|
          if pkmn_data[:iv]
            pkmn.iv[s.id] = pkmn_data[:iv][s.id]
          else
            pkmn.iv[s.id] = [pkmn_data[:level] / 2, Pokemon::IV_STAT_LIMIT].min
          end
          if pkmn_data[:ev]
            pkmn.ev[s.id] = pkmn_data[:ev][s.id]
          else
            pkmn.ev[s.id] = [pkmn_data[:level] * 3 / 2, Pokemon::EV_LIMIT / 6].min
          end
        end
        pkmn.happiness = pkmn_data[:happiness] if pkmn_data[:happiness]
        pkmn.name = pkmn_data[:name] if pkmn_data[:name] && !pkmn_data[:name].empty?
        if pkmn_data[:shadowness]
          pkmn.makeShadow
          pkmn.update_shadow_moves(true)
          pkmn.shiny = false
        end
        pkmn.poke_ball = pkmn_data[:poke_ball] if pkmn_data[:poke_ball]
        pkmn.calc_stats

        index += 1
      end
      return trainer
    end
  end
end

#===============================================================================
# Deprecated methods
#===============================================================================
# @deprecated This alias is slated to be removed in v20.
def pbGetTrainerData(tr_type, tr_name, tr_version = 0)
  Deprecation.warn_method('pbGetTrainerData', 'v20', 'GameData::Trainer.get(tr_type, tr_name, tr_version)')
  return GameData::Trainer.get(tr_type, tr_name, tr_version)
end
