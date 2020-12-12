#===============================================================================
# Instances of this class are individual Pokémon.
# The player's party Pokémon are stored in the array $Trainer.party.
#===============================================================================
class Pokemon
  # @return [String] the nickname of this Pokémon
  attr_accessor :name
  # @return [Integer] this Pokémon's national Pokédex number
  attr_reader   :species
  # @return [Integer] the current experience points
  attr_reader   :exp
  # @return [Integer] the current HP
  attr_reader   :hp
  # @return [Integer] the current Total HP
  attr_reader   :totalhp
  # @return [Integer] the current Attack stat
  attr_reader   :attack
  # @return [Integer] the current Defense stat
  attr_reader   :defense
  # @return [Integer] the current Special Attack stat
  attr_reader   :spatk
  # @return [Integer] the current Special Defense stat
  attr_reader   :spdef
  # @return [Integer] the current Speed stat
  attr_reader   :speed
  # If defined, forces the Pokémon's ability to be the first natural (0),
  # second natural (1) or a hidden (2-5) ability available to its species.
  # It is not possible to give the Pokémon any ability other than those
  # defined in the PBS file "pokemon.txt" for its species
  # (or "pokemonforms.txt" for its species and form).
  # @return [0, 1, 2, 3, 4, 5, nil] forced ability index (nil if none is set)
  attr_accessor :abilityflag
  # If defined, forces this Pokémon to be male (0) or female (1).
  # @return [0, 1, nil] gender to force: male (0) or female (1) (nil if undefined)
  attr_accessor :genderflag
  # If defined, forces this Pokémon to have a particular nature.
  # @return [Integer, nil] ID of the nature to force (nil if undefined)
  attr_accessor :natureflag
  # If defined, overrides this Pokémon's nature's stat-changing effects.
  # @return [Integer, nil] overridden nature stat-changing effects (nil if undefined)
  attr_accessor :natureOverride
  # If defined, forces the Pokémon to be shiny (true) or not (false).
  # @return [Boolean, nil] whether shininess should be forced (nil if undefined)
  attr_accessor :shinyflag
  # @return [Array<PBMove>] the moves known by this Pokémon
  attr_accessor :moves
  # @return [Array<Integer>] the IDs of moves known by this Pokémon when it was obtained
  attr_accessor :firstmoves
  # @return [Symbol] the ID of the item held by this Pokémon (nil = no held item)
  attr_accessor :item_id
  # @return [Integer] this Pokémon's current status (from PBStatuses)
  attr_reader   :status
  # @return [Integer] sleep count / toxic flag / 0:
  #   sleep (number of rounds before waking up), toxic (0 = regular poison, 1 = toxic)
  attr_reader   :statusCount
  # Another Pokémon which has been fused with this Pokémon (or nil if there is none).
  # Currently only used by Kyurem, to record a fused Reshiram or Zekrom.
  # @return [Pokemon, nil] the Pokémon fused into this one (nil if there is none)
  attr_accessor :fused
  # @return [Array<Integer>] an array of IV values for HP, Atk, Def, Speed, Sp. Atk and Sp. Def
  attr_accessor :iv
  # @param value [Array<Boolean>] an array of booleans that max each IV value
  attr_writer   :ivMaxed
  # @return [Array<Integer>] this Pokémon's effort values
  attr_accessor :ev
  # @return [Integer] this Pokémon's current happiness (an integer between 0 and 255)
  attr_accessor :happiness
  # @return [Integer] the type of ball used (refer to {$BallTypes} for valid types)
  attr_accessor :ballused
  # @return [Integer] the number of steps until this Pokémon hatches, 0 if this Pokémon is not an egg
  attr_accessor :eggsteps
  # @param value [Integer] new markings for this Pokémon
  attr_writer   :markings
  # @return [Array<Integer>] an array of ribbons owned by this Pokémon
  attr_accessor :ribbons
  # @return [Integer] the Pokérus strain and infection time
  attr_accessor :pokerus
  # @return [Integer] this Pokémon's personal ID
  attr_accessor :personalID
  # @return [Integer] the manner this Pokémon was obtained:
  #   0 (met), 1 (as egg), 2 (traded), 4 (fateful encounter)
  attr_accessor :obtainMode
  # @return [Integer] the ID of the map this Pokémon was obtained in
  attr_accessor :obtainMap
  # Describes the manner this Pokémon was obtained. If left undefined,
  # the obtain map's name is used.
  # @return [String] the obtain text
  attr_accessor :obtainText
  # @param value [Integer] new obtain level
  attr_writer   :obtainLevel
  # If this Pokémon hatched from an egg, returns the map ID where the hatching happened.
  # Otherwise returns 0.
  # @return [Integer] the map ID where egg was hatched (0 by default)
  attr_accessor :hatchedMap
  # @param value [Integer] new contest stat
  attr_writer   :cool,:beauty,:cute,:smart,:tough,:sheen

  # Max total IVs
  IV_STAT_LIMIT = 31
  # Max total EVs
  EV_LIMIT      = 510
  # Max EVs that a single stat can have
  EV_STAT_LIMIT = 252
  # Maximum length a Pokémon's nickname can be
  MAX_NAME_SIZE = 10
  # Maximum number of moves a Pokémon can know at once
  MAX_MOVES     = 4

  #=============================================================================
  # Ownership, obtained information
  #=============================================================================

  # @return [Owner] this Pokémon's owner
  def owner
    return @owner
  end

  # Changes this Pokémon's owner.
  # @param new_owner [Owner] the owner to change to
  def owner=(new_owner)
    validate new_owner => Owner
    @owner = new_owner
  end

  # @param trainer [PokeBattle_Trainer] the trainer to compare to the OT
  # @return [Boolean] whether the given trainer and this Pokémon's original trainer don't match
  def foreign?(trainer)
    return @owner.id != trainer.id || @owner.name != trainer.name
  end
  alias isForeign? foreign?

  # @return [Integer] this Pokémon's level when it was obtained
  def obtainLevel
    return @obtainLevel || 0
  end

  # @return [Time] the time when this Pokémon was obtained
  def timeReceived
    return @timeReceived ? Time.at(@timeReceived) : Time.gm(2000)
  end

  # Sets the time when this Pokémon was obtained.
  # @param value [Integer, Time, #to_i] time in seconds since Unix epoch
  def timeReceived=(value)
    @timeReceived = value.to_i
  end

  # @return [Time] the time when this Pokémon hatched
  def timeEggHatched
    if obtainMode == 1
      return @timeEggHatched ? Time.at(@timeEggHatched) : Time.gm(2000)
    else
      return Time.gm(2000)
    end
  end

  # Sets the time when this Pokémon hatched.
  # @param value [Integer, Time, #to_i] time in seconds since Unix epoch
  def timeEggHatched=(value)
    @timeEggHatched = value.to_i
  end

  #=============================================================================
  # Level
  #=============================================================================

  # @return [Integer] this Pokémon's level
  def level
    @level = PBExperience.pbGetLevelFromExperience(@exp, self.growthrate) if !@level
    return @level
  end

  # Sets this Pokémon's level. The given level must be between 1 and the
  # maximum level (defined in {PBExperience}).
  # @param value [Integer] new level (between 1 and the maximum level)
  def level=(value)
    if value < 1 || value > PBExperience.maxLevel
      raise ArgumentError.new(_INTL("The level number ({1}) is invalid.", value))
    end
    @level = value
    self.exp = PBExperience.pbGetStartExperience(value, self.growthrate)
  end

  # Sets this Pokémon's Exp. Points.
  # @param value [Integer] new experience points
  def exp=(value)
    @exp = value
    @level = nil
  end

  # @return [Boolean] whether this Pokémon is an egg
  def egg?
    return @eggsteps > 0
  end
  alias isEgg? egg?

  # @return [Integer] this Pokémon's growth rate (from PBGrowthRates)
  def growthrate
    return pbGetSpeciesData(@species, formSimple, SpeciesData::GROWTH_RATE)
  end

  # @return [Integer] this Pokémon's base Experience value
  def baseExp
    return pbGetSpeciesData(@species, formSimple, SpeciesData::BASE_EXP)
  end

  # @return [Float] a number between 0 and 1 indicating how much of the current level's
  #   Exp this Pokémon has
  def expFraction
    lvl = self.level
    return 0.0 if lvl >= PBExperience.maxLevel
    growth_rate = self.growthrate
    start_exp = PBExperience.pbGetStartExperience(lvl, growth_rate)
    end_exp   = PBExperience.pbGetStartExperience(lvl + 1, growth_rate)
    return 1.0 * (@exp - start_exp) / (end_exp - start_exp)
  end

  #=============================================================================
  # Gender
  #=============================================================================

  # @return [0, 1, 2] this Pokémon's gender (0 = male, 1 = female, 2 = genderless)
  def gender
    # Return sole gender option for all male/all female/genderless species
    gender_rate = pbGetSpeciesData(@species, formSimple, SpeciesData::GENDER_RATE)
    case gender_rate
    when PBGenderRates::AlwaysMale   then return 0
    when PBGenderRates::AlwaysFemale then return 1
    when PBGenderRates::Genderless   then return 2
    end
    # Return gender for species that can be male or female
    return @genderflag if @genderflag && (@genderflag == 0 || @genderflag == 1)
    return ((@personalID & 0xFF) < PBGenderRates.genderByte(gender_rate)) ? 1 : 0
  end

  # @return [Boolean] whether this Pokémon species is restricted to only ever being one
  #   gender (or genderless)
  def singleGendered?
    gender_rate = pbGetSpeciesData(@species, formSimple, SpeciesData::GENDER_RATE)
    return gender_rate == PBGenderRates::AlwaysMale ||
           gender_rate == PBGenderRates::AlwaysFemale ||
           gender_rate == PBGenderRates::Genderless
  end
  alias isSingleGendered? singleGendered?

  # @return [Boolean] whether this Pokémon is male
  def male?
    return self.gender == 0
  end
  alias isMale? male?

  # @return [Boolean] whether this Pokémon is female
  def female?
    return self.gender == 1
  end
  alias isFemale? female?

  # @return [Boolean] whether this Pokémon is genderless
  def genderless?
    return self.gender == 2
  end
  alias isGenderless? genderless?

  # Sets this Pokémon's gender to a particular gender (if possible).
  # @param value [0, 1, 2] new gender (0 = male, 1 = female, 2 = genderless)
  def setGender(value)
    @genderflag = value if !singleGendered?
  end

  # Makes this Pokémon male.
  def makeMale; setGender(0); end
  # Makes this Pokémon female.
  def makeFemale; setGender(1); end

  #=============================================================================
  # Ability
  #=============================================================================

  # @return [Integer] the index of this Pokémon's ability
  def abilityIndex
    return @abilityflag || (@personalID & 1)
  end

  # @return [GameData::Ability, nil] an Ability object corresponding to this Pokémon's ability
  def ability
    ret = ability_id
    return GameData::Ability.try_get(ret)
  end

  # @return [Symbol, nil] the ability symbol of this Pokémon's ability
  def ability_id
    abilIndex = abilityIndex
    # Hidden ability
    if abilIndex >= 2
      hiddenAbil = pbGetSpeciesData(@species, formSimple, SpeciesData::HIDDEN_ABILITY)
      if hiddenAbil.is_a?(Array)
        ret = hiddenAbil[abilIndex - 2]
        return ret if GameData::Ability.exists?(ret)
      elsif abilIndex == 2
        return hiddenAbil if GameData::Ability.exists?(hiddenAbil)
      end
      abilIndex = (@personalID & 1)
    end
    # Natural ability
    abilities = pbGetSpeciesData(@species, formSimple, SpeciesData::ABILITIES)
    if abilities.is_a?(Array)
      ret = abilities[abilIndex]
      ret = abilities[(abilIndex + 1) % 2] if !GameData::Ability.exists?(ret)
      return ret
    end
    return abilities
  end

  # Returns whether this Pokémon has a particular ability. If no value
  # is given, returns whether this Pokémon has an ability set.
  # @param check_ability [Symbol, GameData::Ability, Integer] ability ID to check
  # @return [Boolean] whether this Pokémon has a particular ability or
  #   an ability at all
  def hasAbility?(check_ability = nil)
    current_ability = self.ability
    return !current_ability.nil? if check_ability.nil?
    return current_ability == check_ability
  end

  # Sets this Pokémon's ability index.
  # @param value [Integer] new ability index
  def setAbility(value)
    @abilityflag = value
  end

  # @return [Boolean] whether this Pokémon has a hidden ability
  def hasHiddenAbility?
    abil = abilityIndex
    return abil >= 2
  end

  # @return [Array<Array<Integer>>] the list of abilities this Pokémon can have,
  #   where every element is [ability ID, ability index]
  def getAbilityList
    ret = []
    abilities = pbGetSpeciesData(@species, formSimple, SpeciesData::ABILITIES)
    if abilities.is_a?(Array)
      abilities.each_with_index { |a, i| ret.push([a, i]) if a }
    else
      ret.push([abilities, 0]) if abilities > 0
    end
    hiddenAbil = pbGetSpeciesData(@species, formSimple, SpeciesData::HIDDEN_ABILITY)
    if hiddenAbil.is_a?(Array)
      hiddenAbil.each_with_index { |a, i| ret.push([a, i + 2]) if a }
    else
      ret.push([hiddenAbil, 2]) if hiddenAbil > 0
    end
    return ret
  end

  #=============================================================================
  # Nature
  #=============================================================================

  # @return [Integer] the ID of this Pokémon's nature
  def nature
    return @natureflag || (@personalID % 25)
  end

  # Returns the calculated nature, taking into account things that change its
  # stat-altering effect (i.e. Gen 8 mints). Only used for calculating stats.
  # @return [Integer] this Pokémon's calculated nature
  def calcNature
    return @natureOverride if @natureOverride
    return self.nature
  end

  # Returns whether this Pokémon has a particular nature. If no value
  # is given, returns whether this Pokémon has a nature set.
  # @param nature [Integer] nature ID to check
  # @return [Boolean] whether this Pokémon has a particular nature or
  #   a nature at all
  def hasNature?(nature = -1)
    current_nature = self.nature
    return current_nature >= 0 if nature < 0
    return current_nature == getID(PBNatures, nature)
  end

  # Sets this Pokémon's nature to a particular nature.
  # @param value [Integer, String, Symbol] nature to change to
  def setNature(value)
    @natureflag = getID(PBNatures, value)
    calcStats
  end

  #=============================================================================
  # Shininess
  #=============================================================================

  # @return [Boolean] whether this Pokémon is shiny (differently colored)
  def shiny?
    return @shinyflag if @shinyflag != nil
    a = @personalID ^ @owner.id
    b = a & 0xFFFF
    c = (a >> 16) & 0xFFFF
    d = b ^ c
    return d < SHINY_POKEMON_CHANCE
  end
  alias isShiny? shiny?

  # Makes this Pokémon shiny.
  def makeShiny
    @shinyflag = true
  end

  # Makes this Pokémon not shiny.
  def makeNotShiny
    @shinyflag = false
  end

  #=============================================================================
  # Pokérus
  #=============================================================================

  # @return [Integer] the Pokérus infection stage for this Pokémon
  def pokerusStrain
    return @pokerus / 16
  end

  # Returns the Pokérus infection stage for this Pokémon. The possible stages are
  # 0 (not infected), 1 (infected) and 2 (cured)
  # @return [0, 1, 2] current Pokérus infection stage
  def pokerusStage
    return 0 if !@pokerus || @pokerus == 0
    return 2 if @pokerus > 0 && (@pokerus % 16) == 0
    return 1
  end

  # Gives this Pokémon Pokérus (either the specified strain or a random one).
  # @param strain [Integer] Pokérus strain to give
  def givePokerus(strain = 0)
    return if self.pokerusStage == 2   # Can't re-infect a cured Pokémon
    strain = 1 + rand(15) if strain <= 0 || strain >= 16
    time = 1 + (strain % 4)
    @pokerus = time
    @pokerus |= strain << 4
  end

  # Resets the infection time for this Pokémon's Pokérus (even if cured).
  def resetPokerusTime
    return if @pokerus == 0
    strain = @pokerus % 16
    time = 1 + (strain % 4)
    @pokerus = time
    @pokerus |= strain << 4
  end

  # Reduces the time remaining for this Pokémon's Pokérus (if infected).
  def lowerPokerusCount
    return if self.pokerusStage != 1
    @pokerus -= 1
  end

  #=============================================================================
  # Types
  #=============================================================================

  # @return [Integer] this Pokémon's first type
  def type1
    return pbGetSpeciesData(@species, formSimple, SpeciesData::TYPE1)
  end

  # @return [Integer] this Pokémon's second type, or the first type if none is defined
  def type2
    ret = pbGetSpeciesData(@species, formSimple, SpeciesData::TYPE2)
    ret = pbGetSpeciesData(@species, formSimple, SpeciesData::TYPE1) if !ret
    return ret
  end

  # @return [Array<Integer>] an array of this Pokémon's types
  def types
    ret1 = pbGetSpeciesData(@species, formSimple, SpeciesData::TYPE1)
    ret2 = pbGetSpeciesData(@species, formSimple, SpeciesData::TYPE2)
    ret = [ret1]
    ret.push(ret2) if ret2 && ret2 != ret1
    return ret
  end

  # @param type [Integer, Symbol, String] type to check
  # @return [Boolean] whether this Pokémon has the specified type
  def hasType?(type)
    type = GameData::Type.get(type).id
    return self.types.include?(type)
  end

  #=============================================================================
  # Moves
  #=============================================================================

  # @return [Integer] the number of moves known by the Pokémon
  def numMoves
    return @moves.length
  end

  # @param move [Integer, Symbol, String] ID of the move to check
  # @return [Boolean] whether the Pokémon knows the given move
  def hasMove?(move_id)
    move_data = GameData::Move.try_get(move_id)
    return false if !move_data
    return @moves.any? { |m| m.id == move_data.id }
  end
  alias knowsMove? hasMove?

  # Returns the list of moves this Pokémon can learn by levelling up.
  # @return [Array<Array<Integer>>] this Pokémon's move list, where every element is [level, move ID]
  def getMoveList
    return pbGetSpeciesMoveset(@species, formSimple)
  end

  # Sets this Pokémon's movelist to the default movelist it originally had.
  def resetMoves
    this_level = self.level
    # Find all level-up moves that self could have learned
    moveset = self.getMoveList
    knowable_moves = []
    moveset.each { |m| knowable_moves.push(m[1]) if m[0] <= this_level }
    # Remove duplicates (retaining the latest copy of each move)
    knowable_moves = knowable_moves.reverse
    knowable_moves |= []
    knowable_moves = knowable_moves.reverse
    # Add all moves
    @moves.clear
    first_move_index = knowable_moves.length - MAX_MOVES
    first_move_index = 0 if first_move_index < 0
    for i in first_move_index...knowable_moves.length
      @moves.push(PBMove.new(knowable_moves[i]))
    end
  end

  # Silently learns the given move. Will erase the first known move if it has to.
  # @param move_id [Integer, Symbol, String] ID of the move to learn
  def pbLearnMove(move_id)
    move_data = GameData::Move.try_get(move_id)
    return if !move_data
    # Check if self already knows the move; if so, move it to the end of the array
    @moves.each_with_index do |m, i|
      next if m.id != move_data.id
      @moves.push(m)
      @moves.delete_at(i)
      return
    end
    # Move is not already known; learn it
    @moves.push(PBMove.new(move_data.id))
    # Delete the first known move if self now knows more moves than it should
    @moves.shift if numMoves > MAX_MOVES
  end

  # Deletes the given move from the Pokémon.
  # @param move_id [Integer, Symbol, String] ID of the move to delete
  def pbDeleteMove(move_id)
    move_data = GameData::Move.try_get(move_id)
    return if !move_data
    @moves.delete_if { |m| m.id == move_data.id }
  end

  # Deletes the move at the given index from the Pokémon.
  # @param index [Integer] index of the move to be deleted
  def pbDeleteMoveAtIndex(index)
    @moves.delete_at(index)
  end

  # Deletes all moves from the Pokémon.
  def pbDeleteAllMoves
    @moves = []
  end

  # Copies currently known moves into a separate array, for Move Relearner.
  def pbRecordFirstMoves
    @firstmoves = []
    @moves.each { |m| @firstmoves.push(m.id) }
  end

  # Adds a move to this Pokémon's first moves.
  # @param move_id [Integer, Symbol, String] ID of the move to add
  def pbAddFirstMove(move_id)
    move_data = GameData::Move.try_get(move_id)
    @firstmoves.push(move_data.id) if move_data && !@firstmoves.include?(move_data.id)
  end

  # Removes a move from this Pokémon's first moves.
  # @param move_id [Integer, Symbol, String] ID of the move to remove
  def pbRemoveFirstMove(move_id)
    move_data = GameData::Move.try_get(move_id)
    @firstmoves.delete(move_data.id) if move_data
  end

  # Clears this Pokémon's first moves.
  def pbClearFirstMoves
    @firstmoves = []
  end

  # @param move [Integer, Symbol, String] ID of the move to check
  # @return [Boolean] whether the Pokémon is compatible with the given move
  def compatibleWithMove?(move_id)
    return pbSpeciesCompatible?(self.fSpecies, move_id)
  end

  #=============================================================================
  # Contest attributes, ribbons
  #=============================================================================

  # @return [Integer] this Pokémon's cool contest attribute
  def cool
    return @cool || 0
  end

  # @return [Integer] this Pokémon's beauty contest attribute
  def beauty
    return @beauty || 0
  end

  # @return [Integer] this Pokémon's cute contest attribute
  def cute
    return @cute || 0
  end

  # @return [Integer] this Pokémon's smart contest attribute
  def smart
    return @smart || 0
  end

  # @return [Integer] this Pokémon's tough contest attribute
  def tough;
    return @tough || 0
  end

  # @return [Integer] this Pokémon's sheen contest attribute
  def sheen
    return @sheen || 0
  end

  # @return [Integer] the number of ribbons this Pokémon has
  def ribbonCount
    return (@ribbons) ? @ribbons.length : 0
  end

  # @param ribbon [Integer, Symbol, String] ribbon ID to check
  # @return [Boolean] whether this Pokémon has the specified ribbon
  def hasRibbon?(ribbon)
    return false if !@ribbons
    ribbon = getID(PBRibbons, ribbon)
    return false if ribbon == 0
    return @ribbons.include?(ribbon)
  end

  # Gives a ribbon to this Pokémon.
  # @param ribbon [Integer, Symbol, String] ID of the ribbon to give
  def giveRibbon(ribbon)
    @ribbons = [] if !@ribbons
    ribbon = getID(PBRibbons, ribbon)
    return if ribbon == 0
    @ribbons.push(ribbon) if !@ribbons.include?(ribbon)
  end

  # Replaces one ribbon with the next one along, if possible.
  def upgradeRibbon(*arg)
    @ribbons = [] if !@ribbons
    for i in 0...arg.length - 1
      for j in 0...@ribbons.length
        thisribbon = (arg[i].is_a?(Integer)) ? arg[i] : getID(PBRibbons, arg[i])
        if @ribbons[j] == thisribbon
          nextribbon = (arg[i+1].is_a?(Integer)) ? arg[i+1] : getID(PBRibbons, arg[i+1])
          @ribbons[j] = nextribbon
          return nextribbon
        end
      end
    end
    if !hasRibbon?(arg[arg.length - 1])
      firstribbon = (arg[0].is_a?(Integer)) ? arg[0] : getID(PBRibbons, arg[0])
      giveRibbon(firstribbon)
      return firstribbon
    end
    return 0
  end

  # Removes the specified ribbon from this Pokémon.
  # @param ribbon [Integer, Symbol, String] id of the ribbon to remove
  def takeRibbon(ribbon)
    return if !@ribbons
    ribbon = getID(PBRibbons, ribbon)
    return if ribbon == 0
    for i in 0...@ribbons.length
      next if @ribbons[i] != ribbon
      @ribbons[i] = nil
      break
    end
    @ribbons.compact!
  end

  # Removes all ribbons from this Pokémon.
  def clearAllRibbons
    @ribbons = []
  end

  #=============================================================================
  # Items
  #=============================================================================

  # @return [GameData::Item, nil] an Item object corresponding to this Pokémon's item
  def item
    ret = @item_id
    return GameData::Item.try_get(ret)
  end

  # Returns whether this Pokémon is holding an item. If an item id is passed,
  # returns whether the Pokémon is holding that item.
  # @param check_item [Symbol, GameData::Item, Integer] item ID to check
  # @return [Boolean] whether the Pokémon is holding the specified item or
  #   an item at all
  def hasItem?(check_item = nil)
    current_item = self.item
    return !current_item.nil? if check_item.nil?
    return current_item == check_item
  end

  # Gives an item to this Pokémon. Passing 0 as the argument removes the held item.
  # @param value [Symbol, GameData::Item, Integer] id of the item to give to this
  #   Pokémon (a non-valid value sets it to nil)
  def setItem(value)
    new_item = GameData::Item.try_get(value)
    @item_id = (new_item) ? new_item.id : nil
  end

  # @return [Array<Integer>] the items this species can be found holding in the wild
  def wildHoldItems
    ret = []
    ret.push(pbGetSpeciesData(@species, formSimple, SpeciesData::WILD_ITEM_COMMON))
    ret.push(pbGetSpeciesData(@species, formSimple, SpeciesData::WILD_ITEM_UNCOMMON))
    ret.push(pbGetSpeciesData(@species, formSimple, SpeciesData::WILD_ITEM_RARE))
    return ret
  end

  # @return [PokemonMail, nil] mail held by this Pokémon (nil if there is none)
  def mail
    return nil if !@mail
    @mail = nil if !@mail.item || !hasItem?(@mail.item)
    return @mail
  end

  # If mail is a PokemonMail object, gives that mail to this Pokémon. If nil is given,
  # removes the held mail.
  # @param mail [PokemonMail, nil] mail to be held by this Pokémon (nil if mail is to be removed)
  def mail=(mail)
    if !mail.nil? && !mail.is_a?(PokemonMail)
      raise ArgumentError, _INTL('Invalid value {1} given', mail.inspect)
    end
    @mail = mail
  end

  #=============================================================================
  # Status
  #=============================================================================

  # Sets this Pokémon's status. See {PBStatuses} for all possible status effects.
  # @param value [Integer, Symbol, String] status to set (from {PBStatuses})
  def status=(value)
    new_status = getID(PBStatuses, value)
    if !new_status
      raise ArgumentError, _INTL('Attempted to set {1} as Pokémon status', value.class.name)
    end
    @status = new_status
  end

  # Sets a new status count. See {#statusCount} for more information.
  # @param new_status_count [Integer] new sleep count / toxic flag
  def statusCount=(new_status_count)
    @statusCount = new_status_count
  end

  # @return [Boolean] whether the Pokémon is not fainted and not an egg
  def able?
    return !egg? && @hp > 0
  end
  alias isAble? able?

  # @return [Boolean] whether the Pokémon is fainted
  def fainted?
    return !egg? && @hp <= 0
  end
  alias isFainted? fainted?

  # Heals all HP of this Pokémon.
  def healHP
    return if egg?
    @hp = @totalhp
  end

  # Heals the status problem of this Pokémon.
  def healStatus
    return if egg?
    @status      = PBStatuses::NONE
    @statusCount = 0
  end

  # Restores all PP of this Pokémon. If a move index is given, restores the PP
  # of the move in that index.
  # @param move_index [Integer] index of the move to heal (-1 if all moves
  #   should be healed)
  def healPP(move_index = -1)
    return if egg?
    if move_index >= 0
      @moves[move_index].pp = @moves[move_index].total_pp
    else
      @moves.each { |m| m.pp = m.total_pp }
    end
  end

  # Heals all HP, PP, and status problems of this Pokémon.
  def heal
    return if egg?
    healHP
    healStatus
    healPP
  end

  #=============================================================================
  # Other
  #=============================================================================

  # Changes the Pokémon's species and re-calculates its statistics.
  # @param species_id [Integer] id of the species to change this Pokémon to
  def species=(species_id)
    has_nickname = nicknamed?
    @species, new_form = pbGetSpeciesFromFSpecies(species_id)
    @form = new_form if @species != value
    @name       = speciesName unless has_nickname
    @level      = nil   # In case growth rate is different for the new species
    @forcedForm = nil
    calcStats
  end

  # @param species [Integer, Symbol, String] id of the species to check for
  # @return [Boolean] whether this Pokémon is of the specified species
  def isSpecies?(species)
    species = getID(PBSpecies, species)
    return species && @species == species
  end

  # @return [String] the species name of this Pokémon
  def speciesName
    return PBSpecies.getName(@species)
  end

  # @return [Boolean] whether this Pokémon has been nicknamed
  def nicknamed?
    return @name != self.speciesName
  end

  # @return [Integer] the markings this Pokémon has
  def markings
    return @markings || 0
  end

  # @return [String] a string stating the Unown form of this Pokémon
  def unownShape
    return "ABCDEFGHIJKLMNOPQRSTUVWXYZ?!"[@form, 1]
  end

  # @return [Integer] the height of this Pokémon in decimetres (0.1 metres)
  def height
    return pbGetSpeciesData(@species, formSimple, SpeciesData::HEIGHT)
  end

  # @return [Integer] the weight of this Pokémon in hectograms (0.1 kilograms)
  def weight
    return pbGetSpeciesData(@species, formSimple, SpeciesData::WEIGHT)
  end

  # Returns an array of booleans indicating whether a stat is made to have
  # maximum IVs (for Hyper Training). Set like @ivMaxed[PBStats::ATTACK] = true
  # @return [Array<Boolean>] array indicating whether each stat has maximum IVs
  def ivMaxed
    return @ivMaxed || []
  end

  # Returns this Pokémon's effective IVs, taking into account Hyper Training.
  # Only used for calculating stats.
  # @return [Array<Boolean>] array containing this Pokémon's effective IVs
  def calcIV
    ret = self.iv.clone
    if @ivMaxed
      PBStats.eachStat { |s| ret[s] = IV_STAT_LIMIT if @ivMaxed[s] }
    end
    return ret
  end

  # @return [Array<Integer>] the EV yield of this Pokémon (an array of six values)
  def evYield
    ret = pbGetSpeciesData(@species, formSimple, SpeciesData::EFFORT_POINTS)
    return ret.clone
  end

  # Sets the Pokémon's health.
  # @param value [Integer] new hp value
  def hp=(value)
    value = 0 if value < 0
    @hp = value
    if @hp == 0
      @status      = PBStatuses::NONE
      @statusCount = 0
    end
  end

  # Changes the happiness of this Pokémon depending on what happened to change it.
  # @param method [String] the happiness changing method (e.g. 'walking')
  def changeHappiness(method)
    gain = 0
    case method
    when "walking"
      gain = 1
      gain = 2 if @happiness < 200
    when "levelup"
      gain = 3
      gain = 4 if @happiness < 200
      gain = 5 if @happiness < 100
    when "groom"
      gain = 4
      gain = 10 if @happiness < 200
    when "evberry"
      gain = 2
      gain = 5 if @happiness < 200
      gain = 10 if @happiness < 100
    when "vitamin"
      gain = 2
      gain = 3 if @happiness < 200
      gain = 5 if @happiness < 100
    when "wing"
      gain = 1
      gain = 2 if @happiness < 200
      gain = 3 if @happiness < 100
    when "machine"
      gain = 0
      gain = 1 if @happiness < 200
    when "battleitem"
      gain = 0
      gain = 1 if @happiness < 200
    when "faint"
      gain = -1
    when "faintbad"   # Fainted against an opponent that is 30+ levels higher
      gain = -10
      gain = -5 if @happiness < 200
    when "powder"
      gain = -10
      gain = -5 if @happiness < 200
    when "energyroot"
      gain = -15
      gain = -10 if @happiness < 200
    when "revivalherb"
      gain = -20
      gain = -15 if @happiness < 200
    else
      raise _INTL("Unknown happiness-changing method: {1}", method.to_s)
    end
    if gain > 0
      gain += 1 if @obtainMap == $game_map.map_id
      gain += 1 if self.ballused == pbGetBallType(:LUXURYBALL)
      gain = (gain * 1.5).floor if self.hasItem?(:SOOTHEBELL)
    end
    @happiness += gain
    @happiness = [[255, @happiness].min, 0].max
  end

  #=============================================================================
  # Stat calculations
  #=============================================================================

  # @return [Array<Integer>] this Pokémon's base stats, an array of six values
  def baseStats
    ret = pbGetSpeciesData(@species, formSimple, SpeciesData::BASE_STATS)
    return ret.clone
  end

  # @return [Integer] the maximum HP of this Pokémon
  def calcHP(base, level, iv, ev)
    return 1 if base == 1   # For Shedinja
    return ((base * 2 + iv + (ev / 4)) * level / 100).floor + level + 10
  end

  # @return [Integer] the specified stat of this Pokémon (not used for total HP)
  def calcStat(base, level, iv, ev, pv)
    return ((((base * 2 + iv + (ev / 4)) * level / 100).floor + 5) * pv / 100).floor
  end

  # Recalculates this Pokémon's stats.
  def calcStats
    bs        = self.baseStats
    usedLevel = self.level
    usedIV    = self.calcIV
    pValues   = PBNatures.getStatChanges(self.calcNature)
    stats = []
    PBStats.eachStat do |s|
      if s == PBStats::HP
        stats[s] = calcHP(bs[s], usedLevel, usedIV[s], @ev[s])
      else
        stats[s] = calcStat(bs[s], usedLevel, usedIV[s], @ev[s], pValues[s])
      end
    end
    hpDiff = @totalhp - @hp
    @totalhp = stats[PBStats::HP]
    @hp      = @totalhp - hpDiff
    @hp      = 0 if @hp < 0
    @hp      = @totalhp if @hp > @totalhp
    @attack  = stats[PBStats::ATTACK]
    @defense = stats[PBStats::DEFENSE]
    @spatk   = stats[PBStats::SPATK]
    @spdef   = stats[PBStats::SPDEF]
    @speed   = stats[PBStats::SPEED]
  end

  #=============================================================================
  # Pokémon creation
  #=============================================================================

  # Creates a copy of this Pokémon and returns it.
  # @return [Pokemon] a copy of this Pokémon
  def clone
    ret = super
    ret.iv      = @iv.clone
    ret.ivMaxed = @ivMaxed.clone
    ret.ev      = @ev.clone
    ret.moves   = []
    ret.owner   = @owner.clone
    @moves.each_with_index { |m, i| ret.moves[i] = m.clone }
    ret.ribbons = @ribbons.clone if @ribbons
    return ret
  end

  # Creates a new Pokémon object.
  # @param species [Integer, Symbol, String] Pokémon species
  # @param level [Integer] Pokémon level
  # @param owner [Owner, PokeBattle_Trainer] Pokémon owner (the player by default)
  # @param withMoves [Boolean] whether the Pokémon should have moves
  def initialize(species, level, owner = $Trainer, withMoves = true)
    ospecies = species.to_s
    species = getID(PBSpecies, species)
    cname = getConstantName(PBSpecies, species) rescue nil
    realSpecies = pbGetSpeciesFromFSpecies(species)[0] if species && species > 0
    if !species || species <= 0 || realSpecies > PBSpecies.maxValue || !cname
      raise ArgumentError.new(_INTL("The species given ({1}) is invalid.", ospecies))
    end
    @species      = realSpecies
    @name         = speciesName
    @personalID   = rand(2**16) | rand(2**16) << 16
    @hp           = 1
    @totalhp      = 1
    @iv           = []
    @ivMaxed      = []
    @ev           = []
    PBStats.eachStat do |s|
      @iv[s]      = rand(IV_STAT_LIMIT + 1)
      @ev[s]      = 0
    end
    @moves        = []
    @status       = PBStatuses::NONE
    @statusCount  = 0
    @item_id      = nil
    @mail         = nil
    @fused        = nil
    @ribbons      = []
    @ballused     = 0
    @eggsteps     = 0
    if owner.is_a?(Owner)
      @owner = owner
    elsif owner.is_a?(PokeBattle_Trainer)
      @owner = Owner.new_from_trainer(owner)
    else
      @owner = Owner.new(0, '', 2, 2)
    end
    @obtainMap    = ($game_map) ? $game_map.map_id : 0
    @obtainText   = nil
    @obtainLevel  = level
    @obtainMode   = 0   # Met
    @obtainMode   = 4 if $game_switches && $game_switches[FATEFUL_ENCOUNTER_SWITCH]
    @hatchedMap   = 0
    @timeReceived = pbGetTimeNow.to_i
    self.level    = level
    calcStats
    @hp           = @totalhp
    @happiness    = pbGetSpeciesData(@species, formSimple, SpeciesData::HAPPINESS)
    self.resetMoves if withMoves
  end
end
