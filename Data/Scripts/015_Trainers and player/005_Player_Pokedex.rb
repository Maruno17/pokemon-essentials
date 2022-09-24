class Player < Trainer
  # Represents the player's Pokédex.
  class Pokedex
    # @return [Array<Integer>] an array of accessible Dexes
    # @see #refresh_accessible_dexes
    attr_reader :accessible_dexes

    def inspect
      str = super.chop
      str << format(' seen: %d, owned: %d>', self.seen_count, self.owned_count)
      return str
    end

    # Creates an empty Pokédex.
    def initialize
      @unlocked_dexes = []
      0.upto(pbLoadRegionalDexes.length) do |i|
        @unlocked_dexes[i] = (i == 0)
      end
      self.clear
    end

    # Clears the Pokédex.
    def clear
      @seen = {} #deprecated
      @owned = {} #deprecated
      @seen_standard = initStandardDexArray()
      @seen_fusion = initFusionDexArray()
      @seen_triple = {}

      @owned_standard = initStandardDexArray()
      @owned_fusion = initFusionDexArray()
      @owned_triple = {}

      @seen_forms = {}
      @last_seen_forms = {}
      @owned_shadow = {}
      self.refresh_accessible_dexes
    end

    def initStandardDexArray()
      dex_array = []
      (0..NB_POKEMON).each { |poke|
        if poke == 0
          dex_array << nil
        end
        dex_array << false
      }
      return dex_array
    end

    def initFusionDexArray()
      head_array = []
      (0..NB_POKEMON).each { |head|
        body_array = []
        if head == 0
          head_array << nil
        end
        (0..NB_POKEMON).each { |body|
          if body == 0
            body_array << nil
          end
          body_array << false
        }
        head_array << body_array
      }
      return head_array
    end

    def isTripleFusion(num)
      return isTripleFusion?(num)
    end

    def isTripleFusion?(num)
      return num >= Settings::ZAPMOLCUNO_NB
    end

    def isFusion(num)
      return num > Settings::NB_POKEMON && !isTripleFusion(num)
    end

    def set_seen_fusion(species)
      bodyId = getBodyID(species)
      headId = getHeadID(species, bodyId)
      @seen_fusion[headId][bodyId] = true
    end

    def set_seen_normalDex(species)
      dex_num = getDexNumberForSpecies(species)
      @seen_standard[dex_num] = true
    end

    def set_seen_triple(species)
      if species.is_a?(Pokemon)
        species_id = species.species
      else
        species_id = GameData::Species.try_get(species)&.species
      end
      return if species_id.nil?
      @seen_triple[species_id] = true
    end

    def set_seen(species, should_refresh_dexes = true)
      dexNum = getDexNumberForSpecies(species)
      if isTripleFusion(dexNum)
        set_seen_triple(species)
      elsif isFusion(dexNum)
        set_seen_fusion(species)
      else
        set_seen_normalDex(species)
      end
      self.refresh_accessible_dexes if should_refresh_dexes
    end

    # @param species [Symbol, GameData::Species] species to check
    # @return [Boolean] whether the species is seen

    def seen_fusion?(species)
      bodyId = getBodyID(species)
      headId = getHeadID(species, bodyId)
      return @seen_fusion[headId][bodyId]
    end

    # def seen_normalDex?(species)
    #   species_id = GameData::Species.try_get(species)&.species
    #   return false if species_id.nil?
    #   return @seen[species_id] == true
    # end
    def seen_normalDex?(species)
      return @seen_standard[getDexNumberForSpecies(species)]
    end

    def seen_triple?(species)
      species_id = GameData::Species.try_get(species)&.species
      return false if species_id.nil?
      return @seen_triple[species_id]
    end

    def seen?(species)
      return false if !species
      num = getDexNumberForSpecies(species)
      if isTripleFusion(num)
        return seen_triple?(species)
      elsif isFusion(num)
        return seen_fusion?(species)
      else
        return seen_normalDex?(species)
      end
    end

    def seen_form?(species, gender, form)
      return false
      # species_id = GameData::Species.try_get(species)&.species
      # return false if species_id.nil?
      # @seen_forms[species_id] ||= [[], []]
      # return @seen_forms[species_id][gender][form] == true
    end

    # Returns the amount of seen Pokémon.
    # If a region ID is given, returns the amount of seen Pokémon
    # in that region.
    # @param dex [Integer] region ID
    def seen_count(dex = -1)
      if dex_sync_needed?()
        resync_pokedex()
      end
      return count_dex(@seen_standard, @seen_fusion) + @owned_triple.size
    end

    # Returns whether there are any seen Pokémon.
    # If a region is given, returns whether there are seen Pokémon
    # in that region.
    # @param region [Integer] region ID
    # @return [Boolean] whether there are any seen Pokémon
    def seen_any?(dex = -1)
      return seen_count >= 1
    end

    # Returns the amount of seen forms for the given species.
    # @param species [Symbol, GameData::Species] Pokémon species
    # @return [Integer] amount of seen forms
    def seen_forms_count(species)
      return 0
    end

    # @param species [Symbol, GameData::Species] Pokémon species
    def last_form_seen(species)
      @last_seen_forms[species] ||= []
      return @last_seen_forms[species][0] || 0, @last_seen_forms[species][1] || 0
    end

    # @param species [Symbol, GameData::Species] Pokémon species
    # @param gender [Integer] gender (0=male, 1=female, 2=genderless)
    # @param form [Integer] form number
    def set_last_form_seen(species, gender = 0, form = 0)
      @last_seen_forms[species] = [gender, form]
    end

    #===========================================================================

    # Sets the given species as owned in the Pokédex.
    # @param species [Symbol, GameData::Species] species to set as owned
    # @param should_refresh_dexes [Boolean] whether Dex accessibility should be recalculated
    def set_owned_fusion(species)
      bodyId = getBodyID(species)
      headId = getHeadID(species, bodyId)
      @owned_fusion[headId][bodyId] = true
    end

    def set_owned_triple(species)
      species_id = GameData::Species.try_get(species)&.species
      return if species_id.nil?
      @owned_triple[species_id] = true
    end

    def set_owned_normalDex(species)
      @owned_standard[getDexNumberForSpecies(species)] = true
    end

    def set_owned(species, should_refresh_dexes = true)
      dexNum = getDexNumberForSpecies(species)
      if isTripleFusion(dexNum)
        set_owned_triple(species)
      elsif isFusion(dexNum)
        set_owned_fusion(species)
      else
        set_owned_normalDex(species)
      end
      self.refresh_accessible_dexes if should_refresh_dexes
    end

    # Sets the given species as owned in the Pokédex.
    # @param species [Symbol, GameData::Species] species to set as owned
    def set_shadow_pokemon_owned(species)
      return
    end

    # @param species [Symbol, GameData::Species] species to check
    # @return [Boolean] whether the species is owned
    def owned_fusion?(species)
      bodyId = getBodyID(species)
      headId = getHeadID(species, bodyId)
      return @owned_fusion[headId][bodyId] == true
    end

    def owned_triple?(species)
      species_id = GameData::Species.try_get(species)&.species
      return false if species_id.nil?
      return @owned_triple[species_id]
    end

    def owned?(species)
      num = getDexNumberForSpecies(species)
      if isTripleFusion(num)
        return owned_triple?(species)
      elsif isFusion(num)
        return owned_fusion?(species)
      else
        return owned_normalDex?(species)
      end
    end

    def owned_normalDex?(species)
      return @owned_standard[getDexNumberForSpecies(species)]
    end

    # @param species [Symbol, GameData::Species] species to check
    # @return [Boolean] whether a Shadow Pokémon of the species is owned
    def owned_shadow_pokemon?(species)
      return
    end

    # Returns the amount of owned Pokémon.
    # If a region ID is given, returns the amount of owned Pokémon
    # in that region.
    # @param region [Integer] region ID
    def owned_count(dex = -1)
      if dex_sync_needed?()
        resync_pokedex()
      end
      return count_dex(@owned_standard, @owned_fusion) + @owned_triple.size
    end

    def count_dex(standardList, fusedList)
      owned_standard = count_true(standardList)
      owned_fused = 0
      fusedList.each { |head_poke_list|
        if head_poke_list != nil
          owned_fused += count_true(head_poke_list)
        end
      }
      return owned_standard + owned_fused
    end

    def count_true(list)
      count = 0
      list.each { |owned|
        if owned
          count += 1
        end
      }
      return count
    end

    def dex_sync_needed?()
      return @owned_standard == nil || @owned_fusion == nil || @owned_triple == nil
    end

    #todo:
    # loop on @owned and @seen and add the pokemon in @owned_standard/fusion @seen_standard/fusion
    # then clear @owned and @seen
    def resync_pokedex()
      init_new_pokedex_if_needed()
      @seen.each { |pokemon|
        set_seen(pokemon[0])
      }
      @owned.each { |pokemon|
        set_owned(pokemon[0])
      }
      self.refresh_accessible_dexes
      @seen = {} #deprecated
      @owned = {} #deprecated
      #self.clear
    end


    def resync_boxes_to_pokedex
      $PokemonStorage.boxes.each { |box|
        box.pokemon.each { |pokemon|
          if pokemon != nil
            if !pokemon.egg?
              set_owned(pokemon.species)
              set_seen(pokemon.species)
            end
          end
        }
      }
    end

    def init_new_pokedex_if_needed()
      @seen_standard = initStandardDexArray() if @seen_standard == nil
      @seen_fusion = initFusionDexArray() if @seen_fusion == nil
      @seen_triple = {} if @seen_triple == nil

      @owned_standard = initStandardDexArray() if @owned_standard == nil
      @owned_fusion = initFusionDexArray() if @owned_fusion == nil
      @owned_triple = {} if @owned_triple == nil
    end

    #===========================================================================

    # @param pkmn [Pokemon, Symbol, GameData::Species] Pokemon to register as seen
    # @param gender [Integer] gender to register (0=male, 1=female, 2=genderless)
    # @param form [Integer] form to register
    def register(species, gender = 0, form = 0, should_refresh_dexes = true)
      set_seen(species, should_refresh_dexes)
    end

    # @param pkmn [Pokemon] Pokemon to register as most recently seen
    def register_last_seen(pkmn)
      return
      # validate pkmn => Pokemon
      # species_data = pkmn.species_data
      # form = species_data.pokedex_form
      # form = 0 if species_data.form_name.nil? || species_data.form_name.empty?
      # @last_seen_forms[pkmn.species] = [pkmn.gender, form]
    end

    #===========================================================================

    # Unlocks the given Dex, -1 being the National Dex.
    # @param dex [Integer] Dex ID (-1 is the National Dex)
    def unlock(dex)
      validate dex => Integer
      dex = @unlocked_dexes.length - 1 if dex < 0 || dex > @unlocked_dexes.length - 1
      @unlocked_dexes[dex] = true
      self.refresh_accessible_dexes
    end

    # Locks the given Dex, -1 being the National Dex.
    # @param dex [Integer] Dex ID (-1 is the National Dex)
    def lock(dex)
      validate dex => Integer
      dex = @unlocked_dexes.length - 1 if dex < 0 || dex > @unlocked_dexes.length - 1
      @unlocked_dexes[dex] = false
      self.refresh_accessible_dexes
    end

    # @param dex [Integer] Dex ID (-1 is the National Dex)
    # @return [Boolean] whether the given Dex is unlocked
    def unlocked?(dex)
      return dex == 0
      # validate dex => Integer
      # dex = @unlocked_dexes.length - 1 if dex == -1
      # return @unlocked_dexes[dex] == true
    end

    # @return [Integer] the number of defined Dexes (including the National Dex)
    def dexes_count
      return @unlocked_dexes.length
    end

    # Decides which Dex lists are able to be viewed (i.e. they are unlocked and
    # have at least 1 seen species in them), and saves all accessible Dex region
    # numbers into {#accessible_dexes}. National Dex comes after all regional
    # Dexes.
    # If the Dex list shown depends on the player's location, this just decides
    # if a species in the current region has been seen - doesn't look at other
    # regions.
    def refresh_accessible_dexes
      @accessible_dexes = []
      if self.unlocked?(0) && self.seen_any?
        @accessible_dexes.push(-1)
      end
    end

    #===========================================================================

    private

    # @param hash [Hash]
    # @param region [Integer]
    # @return [Integer]
    def count_species(hash, region = -1)
      return hash.size()
    end
  end
end
