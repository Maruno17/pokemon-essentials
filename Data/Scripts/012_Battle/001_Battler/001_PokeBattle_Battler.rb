class PokeBattle_Battler
  # Fundamental to this object
  attr_reader   :battle
  attr_accessor :index
  # The Pokémon and its properties
  attr_reader   :pokemon
  attr_accessor :pokemonIndex
  attr_accessor :species
  attr_accessor :type1
  attr_accessor :type2
  attr_accessor :ability
  attr_accessor :moves
  attr_accessor :gender
  attr_accessor :iv
  attr_accessor :attack
  attr_accessor :spatk
  attr_accessor :speed
  attr_accessor :stages
  attr_reader   :totalhp
  attr_reader   :fainted    # Boolean to mark whether self has fainted properly
  attr_accessor :captured   # Boolean to mark whether self was captured
  attr_reader   :dummy
  attr_accessor :effects
  # Things the battler has done in battle
  attr_accessor :turnCount
  attr_accessor :participants
  attr_accessor :lastAttacker
  attr_accessor :lastFoeAttacker
  attr_accessor :lastHPLost
  attr_accessor :lastHPLostFromFoe
  attr_accessor :lastMoveUsed
  attr_accessor :lastMoveUsedType
  attr_accessor :lastRegularMoveUsed
  attr_accessor :lastRegularMoveTarget   # For Instruct
  attr_accessor :lastRoundMoved
  attr_accessor :lastMoveFailed        # For Stomping Tantrum
  attr_accessor :lastRoundMoveFailed   # For Stomping Tantrum
  attr_accessor :movesUsed
  attr_accessor :currentMove   # ID of multi-turn move currently being used
  attr_accessor :tookDamage    # Boolean for whether self took damage this round
  attr_accessor :tookPhysicalHit
  attr_accessor :damageState
  attr_accessor :initialHP     # Set at the start of each move's usage

  #=============================================================================
  # Complex accessors
  #=============================================================================
  attr_reader :level

  def level=(value)
    @level = value
    @pokemon.level = value if @pokemon
  end

  attr_reader :form

  def form=(value)
    @form = value
    @pokemon.form = value if @pokemon
  end

  attr_reader :item

  def item=(value)
    @item = value
    @pokemon.setItem(value) if @pokemon
  end

  def defense
    return @spdef if @battle.field.effects[PBEffects::WonderRoom]>0
    return @defense
  end

  attr_writer :defense

  def spdef
    return @defense if @battle.field.effects[PBEffects::WonderRoom]>0
    return @spdef
  end

  attr_writer :spdef

  attr_reader :hp

  def hp=(value)
    @hp = value.to_i
    @pokemon.hp = value.to_i if @pokemon
  end

  def fainted?; return @hp<=0; end
  alias isFainted? fainted?

  attr_reader :status

  def status=(value)
    @effects[PBEffects::Truant] = false if @status==PBStatuses::SLEEP && value!=PBStatuses::SLEEP
    @effects[PBEffects::Toxic]  = 0 if value!=PBStatuses::POISON
    @status = value
    @pokemon.status = value if @pokemon
    self.statusCount = 0 if value!=PBStatuses::POISON && value!=PBStatuses::SLEEP
    @battle.scene.pbRefreshOne(@index)
  end

  attr_reader :statusCount

  def statusCount=(value)
    @statusCount = value
    @pokemon.statusCount = value if @pokemon
  end

  #=============================================================================
  # Properties from Pokémon
  #=============================================================================
  def happiness;    return @pokemon ? @pokemon.happiness : 0;    end
  def nature;       return @pokemon ? @pokemon.nature : 0;       end
  def pokerusStage; return @pokemon ? @pokemon.pokerusStage : 0; end

  #=============================================================================
  # Mega Evolution, Primal Reversion, Shadow Pokémon
  #=============================================================================
  def hasMega?
    return false if @effects[PBEffects::Transform]
    return @pokemon && @pokemon.hasMegaForm?
  end

  def mega?; return @pokemon && @pokemon.mega?; end
  alias isMega? mega?

  def hasPrimal?
    return false if @effects[PBEffects::Transform]
    return @pokemon && @pokemon.hasPrimalForm?
  end

  def primal?; return @pokemon && @pokemon.primal?; end
  alias isPrimal? primal?

  def shadowPokemon?; return false; end
  alias isShadow? shadowPokemon?

  def inHyperMode?; return false; end

  #=============================================================================
  # Display-only properties
  #=============================================================================
  def name
    return @effects[PBEffects::Illusion].name if @effects[PBEffects::Illusion]
    return @name
  end

  attr_writer :name

  def displayPokemon
    return @effects[PBEffects::Illusion] if @effects[PBEffects::Illusion]
    return self.pokemon
  end

  def displaySpecies
    return @effects[PBEffects::Illusion].species if @effects[PBEffects::Illusion]
    return self.species
  end

  def displayGender
    return @effects[PBEffects::Illusion].gender if @effects[PBEffects::Illusion]
    return self.gender
  end

  def displayForm
    return @effects[PBEffects::Illusion].form if @effects[PBEffects::Illusion]
    return self.form
  end

  def shiny?
    return @effects[PBEffects::Illusion].shiny? if @effects[PBEffects::Illusion]
    return @pokemon && @pokemon.shiny?
  end
  alias isShiny? shiny?

  def owned?
    return false if !@battle.wildBattle?
    return $Trainer.owned[displaySpecies]
  end
  alias owned owned?

  def abilityName; return PBAbilities.getName(@ability); end
  def itemName;    return PBItems.getName(@item);        end

  def pbThis(lowerCase=false)
    if opposes?
      if @battle.trainerBattle?
        return lowerCase ? _INTL("the opposing {1}",name) : _INTL("The opposing {1}",name)
      else
        return lowerCase ? _INTL("the wild {1}",name) : _INTL("The wild {1}",name)
      end
    elsif !pbOwnedByPlayer?
      return lowerCase ? _INTL("the ally {1}",name) : _INTL("The ally {1}",name)
    end
    return name
  end

  def pbTeam(lowerCase=false)
    if opposes?
      return lowerCase ? _INTL("the opposing team") : _INTL("The opposing team")
    end
    return lowerCase ? _INTL("your team") : _INTL("Your team")
  end

  def pbOpposingTeam(lowerCase=false)
    if opposes?
      return lowerCase ? _INTL("your team") : _INTL("Your team")
    end
    return lowerCase ? _INTL("the opposing team") : _INTL("The opposing team")
  end

  #=============================================================================
  # Calculated properties
  #=============================================================================
  def pbSpeed
    return 1 if fainted?
    stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
    stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
    stage = @stages[PBStats::SPEED] + 6
    speed = @speed*stageMul[stage]/stageDiv[stage]
    speedMult = 0x1000
    # Ability effects that alter calculated Speed
    if abilityActive?
      speedMult = BattleHandlers.triggerSpeedCalcAbility(@ability,self,speedMult)
    end
    # Item effects that alter calculated Speed
    if itemActive?
      speedMult = BattleHandlers.triggerSpeedCalcItem(@item,self,speedMult)
    end
    # Other effects
    speedMult *= 2 if pbOwnSide.effects[PBEffects::Tailwind]>0
    speedMult /= 2 if pbOwnSide.effects[PBEffects::Swamp]>0
    # Paralysis
    if status==PBStatuses::PARALYSIS && !hasActiveAbility?(:QUICKFEET)
      speedMult /= (NEWEST_BATTLE_MECHANICS) ? 2 : 4
    end
    # Badge multiplier
    if @battle.internalBattle && pbOwnedByPlayer? &&
       @battle.pbPlayer.numbadges>=NUM_BADGES_BOOST_SPEED
      speedMult *= 1.1
    end
    # Calculation
    return [(speed.to_f*speedMult/0x1000).round,1].max
  end

  def pbWeight
    ret = (@pokemon) ? @pokemon.weight : 500
    ret += @effects[PBEffects::WeightChange]
    ret = 1 if ret<1
    if abilityActive? && !@battle.moldBreaker
      ret = BattleHandlers.triggerWeightCalcAbility(@ability,self,ret)
    end
    if itemActive?
      ret = BattleHandlers.triggerWeightCalcItem(@item,self,ret)
    end
    return [ret,1].max
  end

  #=============================================================================
  # Queries about what the battler has
  #=============================================================================
  def plainStats
    ret = []
    ret[PBStats::ATTACK]  = self.attack
    ret[PBStats::DEFENSE] = self.defense
    ret[PBStats::SPATK]   = self.spatk
    ret[PBStats::SPDEF]   = self.spdef
    ret[PBStats::SPEED]   = self.speed
    return ret
  end

  def isSpecies?(species)
    return @pokemon && @pokemon.isSpecies?(species)
  end

  # Returns the active types of this Pokémon. The array should not include the
  # same type more than once, and should not include any invalid type numbers
  # (e.g. -1).
  def pbTypes(withType3=false)
    ret = [@type1]
    ret.push(@type2) if @type2!=@type1
    # Burn Up erases the Fire-type.
    if @effects[PBEffects::BurnUp]
      ret.reject! { |type| isConst?(type,PBTypes,:FIRE) }
    end
    # Roost erases the Flying-type. If there are no types left, adds the Normal-
    # type.
    if @effects[PBEffects::Roost]
      ret.reject! { |type| isConst?(type,PBTypes,:FLYING) }
      ret.push(getConst(PBTypes,:NORMAL) || 0) if ret.length==0
    end
    # Add the third type specially.
    if withType3 && @effects[PBEffects::Type3]>=0
      ret.push(@effects[PBEffects::Type3]) if !ret.include?(@effects[PBEffects::Type3])
    end
    return ret
  end

  def pbHasType?(type)
    type = getConst(PBTypes,type) if type.is_a?(Symbol) || type.is_a?(String)
    return false if !type || type<0
    activeTypes = pbTypes(true)
    return activeTypes.include?(type)
  end

  def pbHasOtherType?(type)
    type = getConst(PBTypes,type) if type.is_a?(Symbol) || type.is_a?(String)
    return false if !type || type<0
    activeTypes = pbTypes(true)
    activeTypes.reject! { |t| t==type }
    return activeTypes.length>0
  end

  # NOTE: Do not create any held item which affects whether a Pokémon's ability
  #       is active. The ability Klutz affects whether a Pokémon's item is
  #       active, and the code for the two combined would cause an infinite loop
  #       (regardless of whether any Pokémon actualy has either the ability or
  #       the item - the code existing is enough to cause the loop).
  def abilityActive?(ignoreFainted=false)
    return false if fainted? && !ignoreFainted
    return false if @battle.field.effects[PBEffects::NeutralizingGas]
    return false if @effects[PBEffects::GastroAcid]
    return true
  end

  def hasActiveAbility?(ability,ignoreFainted=false)
    return false if !abilityActive?(ignoreFainted)
    if ability.is_a?(Array)
      ability.each do |a|
        a = getID(PBAbilities,a)
        return true if a!=0 && a==@ability
      end
      return false
    end
    ability = getID(PBAbilities,ability)
    return ability!=0 && ability==@ability
  end
  alias hasWorkingAbility hasActiveAbility?

  def nonNegatableAbility?
    abilityBlacklist = [
       # Form-changing abilities
       :BATTLEBOND,
       :DISGUISE,
#       :FLOWERGIFT,                                       # This can be negated
#       :FORECAST,                                         # This can be negated
       :MULTITYPE,
       :POWERCONSTRUCT,
       :SCHOOLING,
       :SHIELDSDOWN,
       :STANCECHANGE,
       :ZENMODE,
       :ICEFACE,
       # Abilities intended to be inherent properties of a certain species
       :COMATOSE,
       :RKSSYSTEM,
       :GULPMISSILE
    ]
    abilityBlacklist.each do |abil|
      return true if isConst?(@ability,PBAbilities,abil)
    end
    return false
  end

  def itemActive?(ignoreFainted=false)
    return false if fainted? && !ignoreFainted
    return false if @effects[PBEffects::Embargo]>0
    return false if @battle.field.effects[PBEffects::MagicRoom]>0
    return false if hasActiveAbility?(:KLUTZ,ignoreFainted)
    return true
  end

  def hasActiveItem?(item,ignoreFainted=false)
    return false if !itemActive?(ignoreFainted)
    if item.is_a?(Array)
      item.each do |i|
        i = getID(PBItems,i)
        return true if i!=0 && i==@item
      end
      return false
    end
    item = getID(PBItems,item)
    return item!=0 && item==@item
  end
  alias hasWorkingItem hasActiveItem?

  # Returns whether the specified item will be unlosable for this Pokémon.
  def unlosableItem?(check_item)
    return false if check_item <= 0
    return true if pbIsMail?(check_item)
    return false if @effects[PBEffects::Transform]
    # Items that change a Pokémon's form
    return true if @pokemon && @pokemon.getMegaForm(true) > 0   # Mega Stone
    return pbIsUnlosableItem?(check_item, @species, @ability)
  end

  def eachMove
    @moves.each { |m| yield m if m && m.id != 0 }
  end

  def eachMoveWithIndex
    @moves.each_with_index { |m, i| yield m, i if m && m.id != 0 }
  end

  def pbHasMove?(move_id)
    move_id = getID(PBMoves, move_id)
    return false if !move_id || move_id <= 0
    eachMove { |m| return true if m.id == move_id }
    return false
  end

  def pbHasMoveType?(check_type)
    check_type = getConst(PBTypes, check_type)
    return false if !check_type || check_type < 0
    eachMove { |m| return true if m.type == check_type }
    return false
  end

  def pbHasMoveFunction?(*arg)
    return false if !arg
    eachMove do |m|
      arg.each { |code| return true if m.function == code }
    end
    return false
  end

  def hasMoldBreaker?
    return hasActiveAbility?([:MOLDBREAKER, :TERAVOLT, :TURBOBLAZE])
  end

  def canChangeType?
    return false if isConst?(@ability,PBAbilities,:MULTITYPE) ||
                    isConst?(@ability,PBAbilities,:RKSSYSTEM)
    return true
  end

  def airborne?
    return false if hasActiveItem?(:IRONBALL)
    return false if @effects[PBEffects::Ingrain]
    return false if @effects[PBEffects::SmackDown]
    return false if @battle.field.effects[PBEffects::Gravity] > 0
    return true if pbHasType?(:FLYING)
    return true if hasActiveAbility?(:LEVITATE) && !@battle.moldBreaker
    return true if hasActiveItem?(:AIRBALLOON)
    return true if @effects[PBEffects::MagnetRise] > 0
    return true if @effects[PBEffects::Telekinesis] > 0
    return false
  end

  def affectedByTerrain?
    return false if airborne?
    return false if semiInvulnerable?
    return true
  end

  def takesIndirectDamage?(showMsg=false)
    return false if fainted?
    if hasActiveAbility?(:MAGICGUARD)
      if showMsg
        @battle.pbShowAbilitySplash(self)
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("{1} is unaffected!",pbThis))
        else
          @battle.pbDisplay(_INTL("{1} is unaffected because of its {2}!",pbThis,abilityName))
        end
        @battle.pbHideAbilitySplash(self)
      end
      return false
    end
    return true
  end

  def takesSandstormDamage?
    return false if !takesIndirectDamage?
    return false if pbHasType?(:GROUND) || pbHasType?(:ROCK) || pbHasType?(:STEEL)
    return false if inTwoTurnAttack?("0CA","0CB")   # Dig, Dive
    return false if hasActiveAbility?([:OVERCOAT,:SANDFORCE,:SANDRUSH,:SANDVEIL])
    return false if hasActiveItem?(:SAFETYGOGGLES)
    return true
  end

  def takesHailDamage?
    return false if !takesIndirectDamage?
    return false if pbHasType?(:ICE)
    return false if inTwoTurnAttack?("0CA","0CB")   # Dig, Dive
    return false if hasActiveAbility?([:OVERCOAT,:ICEBODY,:SNOWCLOAK])
    return false if hasActiveItem?(:SAFETYGOGGLES)
    return true
  end

  def takesShadowSkyDamage?
    return false if fainted?
    return false if shadowPokemon?
    return true
  end

  def affectedByPowder?(showMsg=false)
    return false if fainted?
    return true if !NEWEST_BATTLE_MECHANICS
    if pbHasType?(:GRASS)
      @battle.pbDisplay(_INTL("{1} is unaffected!",pbThis)) if showMsg
      return false
    end
    if hasActiveAbility?(:OVERCOAT) && !@battle.moldBreaker
      if showMsg
        @battle.pbShowAbilitySplash(self)
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("{1} is unaffected!",pbThis))
        else
          @battle.pbDisplay(_INTL("{1} is unaffected because of its {2}!",pbThis,abilityName))
        end
        @battle.pbHideAbilitySplash(self)
      end
      return false
    end
    if hasActiveItem?(:SAFETYGOGGLES)
      if showMsg
        @battle.pbDisplay(_INTL("{1} is unaffected because of its {2}!",pbThis,itemName))
      end
      return false
    end
    return true
  end

  def canHeal?
    return false if fainted? || @hp>=@totalhp
    return false if @effects[PBEffects::HealBlock]>0
    return true
  end

  def affectedByContactEffect?(showMsg=false)
    return false if fainted?
    if hasActiveItem?(:PROTECTIVEPADS)
      @battle.pbDisplay(_INTL("{1} protected itself with the {2}!",pbThis,itemName)) if showMsg
      return false
    end
    return true
  end

  def movedThisRound?
    return @lastRoundMoved && @lastRoundMoved==@battle.turnCount
  end

  def usingMultiTurnAttack?
    return true if @effects[PBEffects::TwoTurnAttack]>0
    return true if @effects[PBEffects::HyperBeam]>0
    return true if @effects[PBEffects::Rollout]>0
    return true if @effects[PBEffects::Outrage]>0
    return true if @effects[PBEffects::Uproar]>0
    return true if @effects[PBEffects::Bide]>0
    return false
  end

  def inTwoTurnAttack?(*arg)
    return false if @effects[PBEffects::TwoTurnAttack]==0
    ttaFunction = pbGetMoveData(@effects[PBEffects::TwoTurnAttack],MOVE_FUNCTION_CODE)
    arg.each { |a| return true if a==ttaFunction }
    return false
  end

  def semiInvulnerable?
    return inTwoTurnAttack?("0C9","0CA","0CB","0CC","0CD","0CE","14D")
  end

  def pbEncoredMoveIndex
    return -1 if @effects[PBEffects::Encore]==0 || @effects[PBEffects::EncoreMove]==0
    ret = -1
    eachMoveWithIndex do |m,i|
      next if m.id!=@effects[PBEffects::EncoreMove]
      ret = i
      break
    end
    return ret
  end

  def initialItem
    return @battle.initialItems[@index&1][@pokemonIndex]
  end

  def setInitialItem(newItem)
    @battle.initialItems[@index&1][@pokemonIndex] = newItem
  end

  def recycleItem
    return @battle.recycleItems[@index&1][@pokemonIndex]
  end

  def setRecycleItem(newItem)
    @battle.recycleItems[@index&1][@pokemonIndex] = newItem
  end

  def belched?
    return @battle.belch[@index&1][@pokemonIndex]
  end

  def setBelched
    @battle.belch[@index&1][@pokemonIndex] = true
  end

  #=============================================================================
  # Methods relating to this battler's position on the battlefield
  #=============================================================================
  # Returns whether the given position belongs to the opposing Pokémon's side.
  def opposes?(i=0)
    i = i.index if i.respond_to?("index")
    return (@index&1)!=(i&1)
  end

  # Returns whether the given position/battler is near to self.
  def near?(i)
    i = i.index if i.respond_to?("index")
    return @battle.nearBattlers?(@index,i)
  end

  # Returns whether self is owned by the player.
  def pbOwnedByPlayer?
    return @battle.pbOwnedByPlayer?(@index)
  end

  # Returns 0 if self is on the player's side, or 1 if self is on the opposing
  # side.
  def idxOwnSide
    return @index&1
  end

  # Returns 1 if self is on the player's side, or 0 if self is on the opposing
  # side.
  def idxOpposingSide
    return (@index&1)^1
  end

  # Returns the data structure for this battler's side.
  def pbOwnSide
    return @battle.sides[idxOwnSide]
  end

  # Returns the data structure for the opposing Pokémon's side.
  def pbOpposingSide
    return @battle.sides[idxOpposingSide]
  end

  # Yields each unfainted ally Pokémon.
  def eachAlly
    @battle.battlers.each do |b|
      yield b if b && !b.fainted? && !b.opposes?(@index) && b.index!=@index
    end
  end

  # Yields each unfainted opposing Pokémon.
  def eachOpposing
    @battle.battlers.each { |b| yield b if b && !b.fainted? && b.opposes?(@index) }
  end

  # Returns the battler that is most directly opposite to self. unfaintedOnly is
  # whether it should prefer to return a non-fainted battler.
  def pbDirectOpposing(unfaintedOnly=false)
    @battle.pbGetOpposingIndicesInOrder(@index).each do |i|
      next if !@battle.battlers[i]
      break if unfaintedOnly && @battle.battlers[i].fainted?
      return @battle.battlers[i]
    end
    # Wanted an unfainted battler but couldn't find one; make do with a fainted
    # battler
    @battle.pbGetOpposingIndicesInOrder(@index).each do |i|
      return @battle.battlers[i] if @battle.battlers[i]
    end
    return @battle.battlers[(@index^1)]
  end
end
