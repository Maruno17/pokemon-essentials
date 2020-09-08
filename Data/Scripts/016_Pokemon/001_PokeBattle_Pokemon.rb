# This class stores data on each Pokémon. Refer to $Trainer.party for an array
# of each Pokémon in the Trainer's current party.
class PokeBattle_Pokemon
  # @return [String] nickname
  attr_accessor :name
  # @return [Integer] national Pokédex number
  attr_reader   :species
  # @return [Integer] current experience points
  attr_reader   :exp
  # @return [Integer] current HP
  attr_reader   :hp
  # @return [Integer] current Total HP
  attr_reader   :totalhp
  # @return [Integer] current Attack stat
  attr_reader   :attack
  # @return [Integer] current Defense stat
  attr_reader   :defense
  # @return [Integer] current Speed stat
  attr_reader   :speed
  # @return [Integer] current Special Attack stat
  attr_reader   :spatk
  # @return [Integer] current Special Defense stat
  attr_reader   :spdef
  # @return [Integer] status problem (from PBStatus)
  attr_accessor :status
  # @return [Integer] sleep count / toxic flag
  attr_accessor :statusCount
  # @return [0, 1, 2] forces the first / second / hidden ability
  attr_accessor :abilityflag
  # @return [0, 1] forces male (0) or female (1)
  attr_accessor :genderflag
  # @return [Integer] forces a particular nature (nature ID)
  attr_accessor :natureflag
  # @return [Integer] overrides nature's stat-changing effects
  attr_accessor :natureOverride
  # @return [Boolean] whether shininess should be forced
  attr_accessor :shinyflag
  # @return [Array<PBMove>] moves known by this Pokémon
  attr_accessor :moves
  # @return [Array<Integer>] IDs of moves known by this Pokémon when it was obtained
  attr_accessor :firstmoves
  # @return [Integer] id of the item held by this Pokémon (0 = no held item)
  attr_accessor :item
  # @return [PokeBattle_Pokemon, nil] the Pokémon fused into this one (nil if there is none)
  attr_accessor :fused
  # @return [Array<Integer>] array of IV values for HP, Atk, Def, Speed, Sp. Atk and Sp. Def
  attr_accessor :iv
  attr_writer   :ivMaxed     # Array of booleans that max each IV value
  attr_accessor :ev          # Effort Values
  attr_accessor :happiness   # Current happiness
  attr_accessor :ballused    # Ball used
  attr_accessor :eggsteps    # Steps to hatch egg, 0 if Pokémon is not an egg
  attr_writer   :markings    # Markings
  attr_accessor :ribbons     # Array of ribbons
  attr_accessor :pokerus     # Pokérus strain and infection time
  attr_accessor :personalID  # Personal ID
  attr_accessor :trainerID   # 32-bit Trainer ID (the secret ID is in the upper
                             #    16 bits)
  attr_accessor :obtainMode  # Manner obtained:
                             #    0 - met, 1 - as egg, 2 - traded,
                             #    4 - fateful encounter
  attr_accessor :obtainMap   # Map where obtained
  attr_accessor :obtainText  # Replaces the obtain map's name if not nil
  attr_writer   :obtainLevel # Level obtained
  attr_accessor :hatchedMap  # Map where an egg was hatched
  attr_writer   :language    # Language
  attr_accessor :ot          # Original Trainer's name
  attr_writer   :otgender    # Original Trainer's gender:
                             #    0 - male, 1 - female, 2 - mixed, 3 - unknown
                             #    For information only, not used to verify
                             #    ownership of the Pokémon
  attr_writer   :cool,:beauty,:cute,:smart,:tough,:sheen   # Contest stats

  IV_STAT_LIMIT         = 31    # Max total IVs
  EV_LIMIT              = 510   # Max total EVs
  EV_STAT_LIMIT         = 252   # Max EVs that a single stat can have
  MAX_POKEMON_NAME_SIZE = 10    # Maximum length a Pokémon's nickname can be

  #=============================================================================
  # Ownership, obtained information
  #=============================================================================

  # @return [Integer] public portion of the original trainer's ID
  def publicID
    return @trainerID & 0xFFFF
  end

  # @param trainer [PokeBattle_Trainer] the trainer to compare to the OT
  # @return [Boolean] whether the trainer and OT don't match
  def foreign?(trainer)
    return @trainerID != trainer.id || @ot != trainer.name
  end
  alias isForeign? foreign?

  # @return [0, 1, 2] gender of this Pokémon original trainer (0 = male, 1 = female, 2 = unknown)
  def otgender
    return @otgender || 2
  end

  # @return [Integer] this Pokémon's level when it was obtained
  def obtainLevel
    return @obtainLevel || 0
  end

  # @return [Time] time when this Pokémon was obtained
  def timeReceived
    return @timeReceived ? Time.at(@timeReceived) : Time.gm(2000)
  end

  # Sets the time when this Pokémon was obtained.
  # @param value [Integer, Time, #to_i] time in seconds since Unix epoch
  def timeReceived=(value)
    @timeReceived = value.to_i
  end

  # @return [Time] time when this Pokémon hatched
  def timeEggHatched
    if obtainMode==1
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
    @level = PBExperience.pbGetLevelFromExperience(@exp,self.growthrate) if !@level
    return @level
  end

  # Sets this Pokémon's level.
  # @param value [Integer] new level (between 1 and the maximum level)
  def level=(value)
    if value<1 || value>PBExperience.maxLevel
      raise ArgumentError.new(_INTL("The level number ({1}) is invalid.",value))
    end
    @level = value
    self.exp = PBExperience.pbGetStartExperience(value,self.growthrate)
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
    return pbGetSpeciesData(@species,formSimple,SpeciesGrowthRate)
  end

  # @return [Integer] this Pokémon's base Experience value
  def baseExp
    return pbGetSpeciesData(@species,formSimple,SpeciesBaseExp)
  end

  # @return [Float] number between 0 and 1 indicating how much of the current level's
  #   Exp this Pokémon has
  def expFraction
    l = self.level
    return 0.0 if l >= PBExperience.maxLevel
    gr = self.growthrate
    startexp = PBExperience.pbGetStartExperience(l, gr)
    endexp   = PBExperience.pbGetStartExperience(l + 1, gr)
    return 1.0 * (@exp - startexp) / (endexp - startexp)
  end

  #=============================================================================
  # Gender
  #=============================================================================

  # @return [0, 1, 2] this Pokémon's gender (0 = male, 1 = female, 2 = genderless)
  def gender
    # Return sole gender option for all male/all female/genderless species
    genderRate = pbGetSpeciesData(@species,formSimple,SpeciesGenderRate)
    case genderRate
    when PBGenderRates::AlwaysMale;   return 0
    when PBGenderRates::AlwaysFemale; return 1
    when PBGenderRates::Genderless;   return 2
    end
    # Return gender for species that can be male or female
    return @genderflag if @genderflag && (@genderflag == 0 || @genderflag == 1)
    return ((@personalID & 0xFF) < PBGenderRates.genderByte(genderRate)) ? 1 : 0
  end

  # @return [Boolean] whether this Pokémon species is restricted to only ever being one
  #   gender (or genderless)
  def singleGendered?
    genderRate = pbGetSpeciesData(@species,formSimple,SpeciesGenderRate)
    return genderRate == PBGenderRates::AlwaysMale ||
           genderRate == PBGenderRates::AlwaysFemale ||
           genderRate == PBGenderRates::Genderless
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
  def makeMale;   setGender(0); end
  # Makes this Pokémon female.
  def makeFemale; setGender(1); end

  #=============================================================================
  # Ability
  #=============================================================================

  # @return [Integer] the index of this Pokémon's ability
  def abilityIndex
    return @abilityflag || (@personalID & 1)
  end

  # @return [Integer] the ID of this Pokémon's ability
  def ability
    abilIndex = abilityIndex
    # Hidden ability
    if abilIndex >= 2
      hiddenAbil = pbGetSpeciesData(@species,formSimple,SpeciesHiddenAbility)
      if hiddenAbil.is_a?(Array)
        ret = hiddenAbil[abilIndex - 2]
        return ret if ret && ret > 0
      else
        return hiddenAbil if abilIndex == 2 && hiddenAbil > 0
      end
      abilIndex = (@personalID & 1)
    end
    # Natural ability
    abilities = pbGetSpeciesData(@species,formSimple,SpeciesAbilities)
    if abilities.is_a?(Array)
      ret = abilities[abilIndex]
      ret = abilities[(abilIndex + 1) % 2] if !ret || ret == 0
      return ret || 0
    end
    return abilities || 0
  end

  # Returns whether this Pokémon has a particular ability. If no value
  # is given, returns whether this Pokémon has an ability set.
  # @param ability [Integer] ability ID to check
  # @return [Boolean] whether this Pokémon has a particular ability or
  #   an ability at all
  def hasAbility?(ability = 0)
    current_ability = self.ability
    return current_ability > 0 if ability == 0
    return current_ability == getID(PBAbilities,ability)
  end

  # Sets this Pokémon's ability index.
  # @param value [Integer] new ability index
  def setAbility(value)
    @abilityflag = value
  end

  # @return [Boolean] whether this Pokémon has a hidden ability
  def hasHiddenAbility?
    abil = abilityIndex
    return abil!=nil && abil>=2
  end

  # @return [Array<Array<Integer>>] the list of abilities this Pokémon can have
  def getAbilityList
    ret = []
    abilities = pbGetSpeciesData(@species,formSimple,SpeciesAbilities)
    if abilities.is_a?(Array)
      abilities.each_with_index { |a,i| ret.push([a,i]) if a && a>0 }
    else
      ret.push([abilities,0]) if abilities>0
    end
    hiddenAbil = pbGetSpeciesData(@species,formSimple,SpeciesHiddenAbility)
    if hiddenAbil.is_a?(Array)
      hiddenAbil.each_with_index { |a,i| ret.push([a,i+2]) if a && a>0 }
    else
      ret.push([hiddenAbil,2]) if hiddenAbil>0
    end
    return ret
  end

  #=============================================================================
  # Nature
  #=============================================================================

  # @return [Integer] the ID of this Pokémon's nature
  def nature
    return @natureflag || (@personalID%25)
  end

  # Returns the calculated nature, taking into account things that change its
  # stat-altering effect (i.e. Gen 8 mints). Only used for calculating stats.
  # @return [Integer] calculated nature
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
    return current_nature == getID(PBNatures,nature)
  end

  # Sets this Pokémon's nature to a particular nature.
  # @param value [Integer] nature to change to
  def setNature(value)
    @natureflag = getID(PBNatures,value)
    calcStats
  end

  #=============================================================================
  # Shininess
  #=============================================================================

  # @return [Boolean] whether this Pokémon is shiny (differently colored)
  def shiny?
    return @shinyflag if @shinyflag != nil
    a = @personalID ^ @trainerID
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
    return @pokerus/16
  end

  # Returns the Pokérus infection stage for this Pokémon.
  # @return [0, 1, 2] Pokérus infection stage
  #   (0 = not infected, 1 = cured, 2 = infected)
  def pokerusStage
    return 0 if !@pokerus || @pokerus==0        # Not infected
    return 2 if @pokerus>0 && (@pokerus%16)==0  # Cured
    return 1                                    # Infected
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

  # Returns this Pokémon's first type.
  def type1
    return pbGetSpeciesData(@species,formSimple,SpeciesType1)
  end

  # Returns this Pokémon's second type.
  def type2
    ret = pbGetSpeciesData(@species,formSimple,SpeciesType2)
    ret = pbGetSpeciesData(@species,formSimple,SpeciesType1) if !ret
    return ret
  end

  def types
    ret1 = pbGetSpeciesData(@species,formSimple,SpeciesType1)
    ret2 = pbGetSpeciesData(@species,formSimple,SpeciesType2)
    ret = [ret1]
    ret.push(ret2) if ret2 && ret2!=ret1
    return ret
  end

  # Returns whether this Pokémon has the specified type.
  def hasType?(type)
    t = self.types
    if !type.is_a?(Integer)
      return t.any? { |tp| isConst?(tp,PBTypes,type) }
    end
    return t.any? { |tp| tp==type }
  end

  #=============================================================================
  # Moves
  #=============================================================================
  # Returns the number of moves known by the Pokémon.
  def numMoves
    ret = 0
    @moves.each { |m| ret += 1 if m && m.id!=0 }
    return ret
  end

  # Returns true if the Pokémon knows the given move.
  def hasMove?(move)
    move = getID(PBMoves,move)
    return false if !move || move<=0
    @moves.each { |m| return true if m && m.id==move }
    return false
  end
  alias knowsMove? hasMove?

  # Returns the list of moves this Pokémon can learn by levelling up.
  def getMoveList
    return pbGetSpeciesMoveset(@species,formSimple)
  end

  # Sets this Pokémon's movelist to the default movelist it originally had.
  def resetMoves
    lvl = self.level
    fullMoveList = self.getMoveList
    moveList = []
    fullMoveList.each { |m| moveList.push(m[1]) if m[0]<=lvl }
    moveList = moveList.reverse
    moveList |= []   # Remove duplicates
    moveList = moveList.reverse
    listend = moveList.length-4
    listend = 0 if listend<0
    j = 0
    for i in listend...listend+4
      moveid = (i>=moveList.length) ? 0 : moveList[i]
      @moves[j] = PBMove.new(moveid)
      j += 1
    end
  end

  # Silently learns the given move. Will erase the first known move if it has to.
  def pbLearnMove(move)
    move = getID(PBMoves,move)
    return if move<=0
    for i in 0...4   # Already knows move, relocate it to the end of the list
      next if @moves[i].id!=move
      j = i+1
      while j<4
        break if @moves[j].id==0
        tmp = @moves[j]
        @moves[j] = @moves[j-1]
        @moves[j-1] = tmp
        j += 1
      end
      return
    end
    for i in 0...4   # Has empty move slot, put move in there
      next if @moves[i].id!=0
      @moves[i] = PBMove.new(move)
      return
    end
    # Already knows 4 moves, forget the first move and learn the new move
    @moves[0] = @moves[1]
    @moves[1] = @moves[2]
    @moves[2] = @moves[3]
    @moves[3] = PBMove.new(move)
  end

  # Deletes the given move from the Pokémon.
  def pbDeleteMove(move)
    move = getID(PBMoves,move)
    return if !move || move<=0
    newMoves = []
    @moves.each { |m| newMoves.push(m) if m && m.id!=move }
    newMoves.push(PBMove.new(0))
    for i in 0...4
      @moves[i] = newMoves[i]
    end
  end

  # Deletes the move at the given index from the Pokémon.
  def pbDeleteMoveAtIndex(index)
    newMoves = []
    @moves.each_with_index { |m,i| newMoves.push(m) if m && i!=index }
    newMoves.push(PBMove.new(0))
    for i in 0...4
      @moves[i] = newMoves[i]
    end
  end

  # Deletes all moves from the Pokémon.
  def pbDeleteAllMoves
    for i in 0...4
      @moves[i] = PBMove.new(0)
    end
  end

  # Copies currently known moves into a separate array, for Move Relearner.
  def pbRecordFirstMoves
    @firstmoves = []
    @moves.each { |m| @firstmoves.push(m.id) if m && m.id>0 }
  end

  def pbAddFirstMove(move)
    move = getID(PBMoves,move)
    @firstmoves.push(move) if move>0 && !@firstmoves.include?(move)
  end

  def pbRemoveFirstMove(move)
    move = getID(PBMoves,move)
    @firstmoves.delete(move) if move>0
  end

  def pbClearFirstMoves
    @firstmoves = []
  end

  def compatibleWithMove?(move)
    return pbSpeciesCompatible?(self.fSpecies,move)
  end

  #=============================================================================
  # Contest attributes, ribbons
  #=============================================================================
  def cool;   return @cool || 0;   end
  def beauty; return @beauty || 0; end
  def cute;   return @cute || 0;   end
  def smart;  return @smart || 0;  end
  def tough;  return @tough || 0;  end
  def sheen;  return @sheen || 0;  end

  # Returns the number of ribbons this Pokémon has.
  def ribbonCount
    return (@ribbons) ? @ribbons.length : 0
  end

  # Returns whether this Pokémon has the specified ribbon.
  def hasRibbon?(ribbon)
    return false if !@ribbons
    ribbon = getID(PBRibbons,ribbon)
    return false if ribbon==0
    return @ribbons.include?(ribbon)
  end

  # Gives this Pokémon the specified ribbon.
  def giveRibbon(ribbon)
    @ribbons = [] if !@ribbons
    ribbon = getID(PBRibbons,ribbon)
    return if ribbon==0
    @ribbons.push(ribbon) if !@ribbons.include?(ribbon)
  end

  # Replaces one ribbon with the next one along, if possible.
  def upgradeRibbon(*arg)
    @ribbons = [] if !@ribbons
    for i in 0...arg.length-1
      for j in 0...@ribbons.length
        thisribbon = (arg[i].is_a?(Integer)) ? arg[i] : getID(PBRibbons,arg[i])
        if @ribbons[j]==thisribbon
          nextribbon = (arg[i+1].is_a?(Integer)) ? arg[i+1] : getID(PBRibbons,arg[i+1])
          @ribbons[j] = nextribbon
          return nextribbon
        end
      end
    end
    if !hasRibbon?(arg[arg.length-1])
      firstribbon = (arg[0].is_a?(Integer)) ? arg[0] : getID(PBRibbons,arg[0])
      giveRibbon(firstribbon)
      return firstribbon
    end
    return 0
  end

  # Removes the specified ribbon from this Pokémon.
  def takeRibbon(ribbon)
    return if !@ribbons
    ribbon = getID(PBRibbons,ribbon)
    return if ribbon==0
    for i in 0...@ribbons.length
      next if @ribbons[i]!=ribbon
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
  # Returns whether this Pokémon is holding an item. If an item id is passed,
  # returns whether the Pokémon is holding that item.
  def hasItem?(item_id = 0)
    held_item = self.item
    return held_item > 0 if item_id == 0
    return held_item == getID(PBItems,item_id)
  end

  # Sets this Pokémon's item. Accepts symbols.
  def setItem(value)
    self.item = getID(PBItems,value)
  end

  # Returns the items this species can be found holding in the wild.
  def wildHoldItems
    ret = []
    ret.push(pbGetSpeciesData(@species,formSimple,SpeciesWildItemCommon))
    ret.push(pbGetSpeciesData(@species,formSimple,SpeciesWildItemUncommon))
    ret.push(pbGetSpeciesData(@species,formSimple,SpeciesWildItemRare))
    return ret
  end

  # @return [PokemonMail, nil] mail held by this Pokémon (nil if there is none)
  def mail
    return nil if !@mail
    @mail = nil if @mail.item==0 || !hasItem?(@mail.item)
    return @mail
  end

  # @param mail [PokemonMail, nil] mail to be held by this Pokémon (nil if mail is to be removed)
  def mail=(mail)
    if !mail.nil? && !mail.is_a?(PokemonMail)
      raise ArgumentError, _INTL('Invalid value {1} given',mail.inspect)
    end
    @mail = mail
  end

  #=============================================================================
  # Other
  #=============================================================================
  def species=(value)
    hasNickname = nicknamed?
    @species    = value
    @name       = PBSpecies.getName(@species) unless hasNickname
    @level      = nil   # In case growth rate is different for the new species
    @forcedForm = nil
    calcStats
  end

  def isSpecies?(s)
    s = getID(PBSpecies,s)
    return s && @species==s
  end

  # Returns the species name of this Pokémon.
  def speciesName
    return PBSpecies.getName(@species)
  end

  def nicknamed?
    return @name!=self.speciesName
  end

  # Returns this Pokémon's language.
  def language; return @language || 0; end

  # Returns the markings this Pokémon has.
  def markings; return @markings || 0; end

  # Returns a string stating the Unown form of this Pokémon.
  def unownShape
    return "ABCDEFGHIJKLMNOPQRSTUVWXYZ?!"[@form,1]
  end

  # Returns the height of this Pokémon.
  def height
    return pbGetSpeciesData(@species,formSimple,SpeciesHeight)
  end

  # Returns the weight of this Pokémon.
  def weight
    return pbGetSpeciesData(@species,formSimple,SpeciesWeight)
  end

  # Returns an array of booleans indicating whether a stat is made to have
  # maximum IVs (for Hyper Training). Set like @ivMaxed[PBStats::ATTACK] = true
  def ivMaxed
    return @ivMaxed || []
  end

  # Returns this Pokémon's effective IVs, taking into account Hyper Training.
  # Only used for calculating stats.
  def calcIV
    ret = self.iv.clone
    if @ivMaxed
      PBStats.eachStat { |s| ret[s] = IV_STAT_LIMIT if @ivMaxed[s] }
    end
    return ret
  end

  # Returns the EV yield of this Pokémon.
  def evYield
    ret = pbGetSpeciesData(@species,formSimple,SpeciesEffortPoints)
    return ret.clone
  end

  # Sets this Pokémon's HP.
  def hp=(value)
    value = 0 if value<0
    @hp = value
    if @hp==0
      @status      = PBStatuses::NONE
      @statusCount = 0
    end
  end

  def able?
    return !egg? && @hp>0
  end
  alias isAble? able?

  def fainted?
    return !egg? && @hp<=0
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

  # Heals all PP of this Pokémon.
  def healPP(index=-1)
    return if egg?
    if index>=0
      @moves[index].pp = @moves[index].totalpp
    else
      @moves.each { |m| m.pp = m.totalpp }
    end
  end

  # Heals all HP, PP, and status problems of this Pokémon.
  def heal
    return if egg?
    healHP
    healStatus
    healPP
  end

  # Changes the happiness of this Pokémon depending on what happened to change it.
  def changeHappiness(method)
    gain = 0
    case method
    when "walking"
      gain = 1
      gain = 2 if @happiness<200
    when "levelup"
      gain = 3
      gain = 4 if @happiness<200
      gain = 5 if @happiness<100
    when "groom"
      gain = 4
      gain = 10 if @happiness<200
    when "evberry"
      gain = 2
      gain = 5 if @happiness<200
      gain = 10 if @happiness<100
    when "vitamin"
      gain = 2
      gain = 3 if @happiness<200
      gain = 5 if @happiness<100
    when "wing"
      gain = 1
      gain = 2 if @happiness<200
      gain = 3 if @happiness<100
    when "machine"
      gain = 0
      gain = 1 if @happiness<200
    when "battleitem"
      gain = 0
      gain = 1 if @happiness<200
    when "faint"
      gain = -1
    when "faintbad"   # Fainted against an opponent that is 30+ levels higher
      gain = -10
      gain = -5 if @happiness<200
    when "powder"
      gain = -10
      gain = -5 if @happiness<200
    when "energyroot"
      gain = -15
      gain = -10 if @happiness<200
    when "revivalherb"
      gain = -20
      gain = -15 if @happiness<200
    else
      raise _INTL("Unknown happiness-changing method: {1}",method.to_s)
    end
    if gain>0
      gain += 1 if @obtainMap==$game_map.map_id
      gain += 1 if self.ballused==pbGetBallType(:LUXURYBALL)
      gain = (gain*1.5).floor if self.hasItem?(:SOOTHEBELL)
    end
    @happiness += gain
    @happiness = [[255,@happiness].min,0].max
  end

  #=============================================================================
  # Stat calculations, Pokémon creation
  #=============================================================================
  # Returns this Pokémon's base stats. An array of six values.
  def baseStats
    ret = pbGetSpeciesData(@species,formSimple,SpeciesBaseStats)
    return ret.clone
  end

  # Returns the maximum HP of this Pokémon.
  def calcHP(base,level,iv,ev)
    return 1 if base==1   # For Shedinja
    return ((base*2+iv+(ev>>2))*level/100).floor+level+10
  end

  # Returns the specified stat of this Pokémon (not used for total HP).
  def calcStat(base,level,iv,ev,pv)
    return ((((base*2+iv+(ev>>2))*level/100).floor+5)*pv/100).floor
  end

  # Recalculates this Pokémon's stats.
  def calcStats
    bs        = self.baseStats
    usedLevel = self.level
    usedIV    = self.calcIV
    pValues   = PBNatures.getStatChanges(self.calcNature)
    stats = []
    PBStats.eachStat do |s|
      if s==PBStats::HP
        stats[s] = calcHP(bs[s],usedLevel,usedIV[s],@ev[s])
      else
        stats[s] = calcStat(bs[s],usedLevel,usedIV[s],@ev[s],pValues[s])
      end
    end
    hpDiff = @totalhp-@hp
    @totalhp = stats[PBStats::HP]
    @hp      = @totalhp-hpDiff
    @hp      = 0 if @hp<0
    @hp      = @totalhp if @hp>@totalhp
    @attack  = stats[PBStats::ATTACK]
    @defense = stats[PBStats::DEFENSE]
    @spatk   = stats[PBStats::SPATK]
    @spdef   = stats[PBStats::SPDEF]
    @speed   = stats[PBStats::SPEED]
  end

  def clone
    ret = super
    ret.iv      = @iv.clone
    ret.ivMaxed = @ivMaxed.clone
    ret.ev      = @ev.clone
    ret.moves   = []
    @moves.each_with_index { |m,i| ret.moves[i] = m.clone }
    ret.ribbons = @ribbons.clone if @ribbons
    return ret
  end

  # Creates a new Pokémon object.
  #    species   - Pokémon species.
  #    level     - Pokémon level.
  #    player    - PokeBattle_Trainer object for the original trainer.
  #    withMoves - If false, this Pokémon has no moves.
  def initialize(species,level,player=nil,withMoves=true)
    ospecies = species.to_s
    species = getID(PBSpecies,species)
    cname = getConstantName(PBSpecies,species) rescue nil
    realSpecies = pbGetSpeciesFromFSpecies(species)[0] if species && species>0
    if !species || species<=0 || realSpecies>PBSpecies.maxValue || !cname
      raise ArgumentError.new(_INTL("The species given ({1}) is invalid.",ospecies))
    end
    @species      = realSpecies
    @name         = PBSpecies.getName(@species)
    @personalID   = rand(256)
    @personalID   |= rand(256)<<8
    @personalID   |= rand(256)<<16
    @personalID   |= rand(256)<<24
    @hp           = 1
    @totalhp      = 1
    @iv           = []
    @ivMaxed      = []
    @ev           = []
    PBStats.eachStat do |s|
      @iv[s]      = rand(IV_STAT_LIMIT+1)
      @ev[s]      = 0
    end
    @moves        = []
    @status       = PBStatuses::NONE
    @statusCount  = 0
    @item         = 0
    @mail         = nil
    @fused        = nil
    @ribbons      = []
    @ballused     = 0
    @eggsteps     = 0
    if player
      @trainerID  = player.id
      @ot         = player.name
      @otgender   = player.gender
      @language   = player.language
    else
      @trainerID  = 0
      @ot         = ""
      @otgender   = 2
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
    @happiness    = pbGetSpeciesData(@species,formSimple,SpeciesHappiness)
    if withMoves
      self.resetMoves
    else
      for i in 0...4
        @moves[i] = PBMove.new(0)
      end
    end
  end
end



def pbNewPkmn(species,level,owner=nil,withMoves=true)
  owner = $Trainer if !owner
  return PokeBattle_Pokemon.new(species,level,owner,withMoves)
end
alias pbGenPkmn pbNewPkmn
alias pbGenPoke pbNewPkmn
