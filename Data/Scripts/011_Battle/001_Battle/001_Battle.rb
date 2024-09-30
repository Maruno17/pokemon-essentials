#===============================================================================
# Results of battle (see module Outcome):
#    0 - Undecided or aborted
#    1 - Player won
#    2 - Player lost
#    3 - Player or wild Pokémon ran from battle, or player forfeited the match
#    4 - Wild Pokémon was caught
#    5 - Draw
# Possible actions a battler can take in a round:
#    :None
#    :UseMove
#    :SwitchOut
#    :UseItem
#    :Call
#    :Run
#    :Shift
# NOTE: If you want to have more than 3 Pokémon on a side at once, you will need
#       to edit some code. Mainly this is to change/add coordinates for the
#       sprites, describe the relationships between Pokémon and trainers, and to
#       change messages. The methods that will need editing are as follows:
#           class Battle
#             def setBattleMode
#             def pbGetOwnerIndexFromBattlerIndex
#             def pbGetOpposingIndicesInOrder
#             def nearBattlers?
#             def pbStartBattleSendOut
#             def pbEORShiftDistantBattlers
#             def pbCanShift?
#             def pbEndOfRoundPhase
#           class Battle::Scene::TargetMenu
#             def initialize
#           class Battle::Scene::PokemonDataBox
#             def initializeDataBoxGraphic
#           class Battle::Scene
#             def self.pbBattlerPosition
#             def self.pbTrainerPosition
#           class Game_Temp
#             def add_battle_rule
#       (There is no guarantee that this list is complete.)
#===============================================================================
class Battle
  module Outcome
    UNDECIDED = 0
    WIN       = 1
    LOSE      = 2   # Also used when player forfeits a trainer battle
    FLEE      = 3   # Player or wild Pokémon ran away, count as a win
    CATCH     = 4   # Counts as a win
    DRAW      = 5

    def self.decided?(decision)
      return decision != UNDECIDED
    end

    def self.should_black_out?(decision)
      return decision == LOSE || decision == DRAW
    end

    def self.success?(decision)
      return !self.should_black_out?(decision)
    end
  end

  #-----------------------------------------------------------------------------

  attr_reader   :scene            # Scene object for this battle
  attr_reader   :peer
  attr_reader   :field            # Effects common to the whole of a battle
  attr_reader   :sides            # Effects common to each side of a battle
  attr_reader   :positions        # Effects that apply to a battler position
  attr_reader   :battlers         # Currently active Pokémon
  attr_reader   :sideSizes        # Array of number of battlers per side
  attr_accessor :backdrop         # Filename fragment used for background graphics
  attr_accessor :backdropBase     # Filename fragment used for base graphics
  attr_accessor :time             # Time of day (0=day, 1=eve, 2=night)
  attr_accessor :environment      # Battle surroundings (for mechanics purposes)
  attr_reader   :turnCount
  attr_accessor :decision         # Outcome of battle
  attr_reader   :player           # Player trainer (or array of trainers)
  attr_reader   :opponent         # Opponent trainer (or array of trainers)
  attr_accessor :items            # Items held by opponents
  attr_accessor :ally_items       # Items held by allies
  attr_accessor :party1starts     # Array of start indexes for each player-side trainer's party
  attr_accessor :party2starts     # Array of start indexes for each opponent-side trainer's party
  attr_accessor :internalBattle   # Internal battle flag
  attr_accessor :debug            # Debug flag
  attr_accessor :canRun           # True if player can run from battle
  attr_accessor :canLose          # True if player won't black out if they lose
  attr_accessor :canSwitch        # True if player is allowed to switch Pokémon
  attr_accessor :switchStyle      # Switch/Set "battle style" option
  attr_accessor :showAnims        # "Battle Effects" option
  attr_accessor :controlPlayer    # Whether player's Pokémon are AI controlled
  attr_accessor :expGain          # Whether Pokémon can gain Exp/EVs
  attr_accessor :moneyGain        # Whether the player can gain/lose money
  attr_accessor :disablePokeBalls # Whether Poké Balls cannot be thrown at all
  attr_accessor :sendToBoxes      # Send to Boxes (0=ask, 1=don't ask, 2=must add to party)
  attr_accessor :rules
  attr_accessor :choices          # Choices made by each Pokémon this round
  attr_accessor :megaEvolution    # Battle index of each trainer's Pokémon to Mega Evolve
  attr_reader   :initialItems
  attr_reader   :recycleItems
  attr_reader   :belch
  attr_reader   :battleBond
  attr_reader   :corrosiveGas
  attr_reader   :usedInBattle     # Whether each Pokémon was used in battle (for Burmy)
  attr_reader   :successStates    # Success states
  attr_accessor :lastMoveUsed     # Last move used
  attr_accessor :lastMoveUser     # Last move user
  attr_accessor :first_poke_ball  # ID of the first thrown Poké Ball that failed
  attr_accessor :poke_ball_failed # Set after first_poke_ball to prevent it being set again
  attr_reader   :switching        # True if during the switching phase of the round
  attr_reader   :futureSight      # True if Future Sight is hitting
  attr_reader   :command_phase
  attr_reader   :endOfRound       # True during the end of round
  attr_accessor :moldBreaker      # True if Mold Breaker applies
  attr_reader   :struggle         # The Struggle move

  def pbRandom(x); return rand(x); end

  #-----------------------------------------------------------------------------

  def initialize(scene, p1, p2, player, opponent)
    if p1.length == 0
      raise ArgumentError.new(_INTL("Party 1 has no Pokémon."))
    elsif p2.length == 0
      raise ArgumentError.new(_INTL("Party 2 has no Pokémon."))
    end
    @scene             = scene
    @peer              = Peer.new
    @field             = ActiveField.new    # Whole field (gravity/rooms)
    @sides             = [ActiveSide.new,   # Player's side
                          ActiveSide.new]   # Foe's side
    @positions         = []                 # Battler positions
    @battlers          = []
    @sideSizes         = [1, 1]   # Single battle, 1v1
    @backdrop          = ""
    @backdropBase      = nil
    @time              = 0
    @environment       = :None   # e.g. Tall grass, cave, still water
    @turnCount         = 0
    @decision          = Outcome::UNDECIDED
    @caughtPokemon     = []
    player   = [player] if !player.nil? && !player.is_a?(Array)
    opponent = [opponent] if !opponent.nil? && !opponent.is_a?(Array)
    @player            = player     # Array of Player/NPCTrainer objects, or nil
    @opponent          = opponent   # Array of NPCTrainer objects, or nil
    @items             = nil
    @ally_items        = nil        # Array of items held by ally. This is just used for Mega Evolution for now.
    @party1            = p1
    @party2            = p2
    @party1order       = Array.new(@party1.length) { |i| i }
    @party2order       = Array.new(@party2.length) { |i| i }
    @party1starts      = [0]
    @party2starts      = [0]
    @internalBattle    = true
    @debug             = false
    @canRun            = true
    @canLose           = false
    @canSwitch         = true
    @switchStyle       = true
    @showAnims         = true
    @controlPlayer     = false
    @expGain           = true
    @moneyGain         = true
    @disablePokeBalls  = false
    @sendToBoxes       = 1
    @rules             = {}
    @priority          = []
    @priorityTrickRoom = false
    @choices           = []
    @megaEvolution     = [
      [-1] * (@player ? @player.length : 1),
      [-1] * (@opponent ? @opponent.length : 1)
    ]
    @initialItems      = [
      Array.new(@party1.length) { |i| (@party1[i]) ? @party1[i].item_id : nil },
      Array.new(@party2.length) { |i| (@party2[i]) ? @party2[i].item_id : nil }
    ]
    @recycleItems      = [Array.new(@party1.length, nil),   Array.new(@party2.length, nil)]
    @belch             = [Array.new(@party1.length, false), Array.new(@party2.length, false)]
    @battleBond        = [Array.new(@party1.length, false), Array.new(@party2.length, false)]
    @corrosiveGas      = [Array.new(@party1.length, false), Array.new(@party2.length, false)]
    @usedInBattle      = [Array.new(@party1.length, false), Array.new(@party2.length, false)]
    @successStates     = []
    @lastMoveUsed      = nil
    @lastMoveUser      = -1
    @switching         = false
    @futureSight       = false
    @command_phase     = false
    @endOfRound        = false
    @moldBreaker       = false
    @runCommand        = 0
    @nextPickupUse     = 0
    @struggle          = Move::Struggle.new(self, nil)
    @mega_rings        = []
    GameData::Item.each { |item| @mega_rings.push(item.id) if item.has_flag?("MegaRing") }
    @battleAI          = AI.new(self)
  end

  def decided?
    return Outcome.decided?(@decision)
  end

  #-----------------------------------------------------------------------------
  # Information about the type and size of the battle.
  #-----------------------------------------------------------------------------

  def wildBattle?;    return @opponent.nil?;  end
  def trainerBattle?; return !@opponent.nil?; end

  # Sets the number of battler slots on each side of the field independently.
  # For "1v2" names, the first number is for the player's side and the second
  # number is for the opposing side.
  def setBattleMode(mode)
    @sideSizes =
      case mode
      when "triple", "3v3" then [3, 3]
      when "3v2"           then [3, 2]
      when "3v1"           then [3, 1]
      when "2v3"           then [2, 3]
      when "double", "2v2" then [2, 2]
      when "2v1"           then [2, 1]
      when "1v3"           then [1, 3]
      when "1v2"           then [1, 2]
      else                      [1, 1]   # Single, 1v1 (default)
      end
  end

  def singleBattle?
    return pbSideSize(0) == 1 && pbSideSize(1) == 1
  end

  def pbSideSize(index)
    return @sideSizes[index % 2]
  end

  def maxBattlerIndex
    return (pbSideSize(0) > pbSideSize(1)) ? (pbSideSize(0) - 1) * 2 : (pbSideSize(1) * 2) - 1
  end

  #-----------------------------------------------------------------------------
  # Trainers and owner-related methods.
  #-----------------------------------------------------------------------------

  def pbPlayer; return @player[0]; end

  # Given a battler index, returns the index within @player/@opponent of the
  # trainer that controls that battler index.
  # NOTE: You shouldn't ever have more trainers on a side than there are battler
  #       positions on that side. This method doesn't account for if you do.
  def pbGetOwnerIndexFromBattlerIndex(idxBattler)
    trainer = (opposes?(idxBattler)) ? @opponent : @player
    return 0 if !trainer
    case trainer.length
    when 2
      n = pbSideSize(idxBattler % 2)
      return [0, 0, 1][idxBattler / 2] if n == 3
      return idxBattler / 2   # Same as [0,1][idxBattler/2], i.e. 2 battler slots
    when 3
      return idxBattler / 2
    end
    return 0
  end

  def pbGetOwnerFromBattlerIndex(idxBattler)
    idxTrainer = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    trainer = (opposes?(idxBattler)) ? @opponent : @player
    return (trainer.nil?) ? nil : trainer[idxTrainer]
  end

  def pbGetOwnerIndexFromPartyIndex(idxBattler, idxParty)
    ret = -1
    pbPartyStarts(idxBattler).each_with_index do |start, i|
      break if start > idxParty
      ret = i
    end
    return ret
  end

  # Only used for the purpose of an error message when one trainer tries to
  # switch another trainer's Pokémon.
  def pbGetOwnerFromPartyIndex(idxBattler, idxParty)
    idxTrainer = pbGetOwnerIndexFromPartyIndex(idxBattler, idxParty)
    trainer = (opposes?(idxBattler)) ? @opponent : @player
    return (trainer.nil?) ? nil : trainer[idxTrainer]
  end

  def pbGetOwnerName(idxBattler)
    idxTrainer = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    return @opponent[idxTrainer].full_name if opposes?(idxBattler)   # Opponent
    return @player[idxTrainer].full_name if idxTrainer > 0   # Ally trainer
    return @player[idxTrainer].name   # Player
  end

  def pbGetOwnerItems(idxBattler)
    if opposes?(idxBattler)
      return [] if !@items
      return @items[pbGetOwnerIndexFromBattlerIndex(idxBattler)]
    end
    return [] if !@ally_items
    return @ally_items[pbGetOwnerIndexFromBattlerIndex(idxBattler)]
  end

  # Returns whether the battler in position idxBattler is owned by the same
  # trainer that owns the Pokémon in party slot idxParty. This assumes that
  # both the battler position and the party slot are from the same side.
  def pbIsOwner?(idxBattler, idxParty)
    idxTrainer1 = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    idxTrainer2 = pbGetOwnerIndexFromPartyIndex(idxBattler, idxParty)
    return idxTrainer1 == idxTrainer2
  end

  def pbOwnedByPlayer?(idxBattler)
    return false if opposes?(idxBattler)
    return pbGetOwnerIndexFromBattlerIndex(idxBattler) == 0
  end

  # Returns the number of Pokémon positions controlled by the given trainerIndex
  # on the given side of battle.
  def pbNumPositions(side, idxTrainer)
    ret = 0
    pbSideSize(side).times do |i|
      t = pbGetOwnerIndexFromBattlerIndex((i * 2) + side)
      next if t != idxTrainer
      ret += 1
    end
    return ret
  end

  #-----------------------------------------------------------------------------
  # Get party information (counts all teams on the same side).
  #-----------------------------------------------------------------------------

  def pbParty(idxBattler)
    return (opposes?(idxBattler)) ? @party2 : @party1
  end

  def pbOpposingParty(idxBattler)
    return (opposes?(idxBattler)) ? @party1 : @party2
  end

  def pbPartyOrder(idxBattler)
    return (opposes?(idxBattler)) ? @party2order : @party1order
  end

  def pbPartyStarts(idxBattler)
    return (opposes?(idxBattler)) ? @party2starts : @party1starts
  end

  # Returns the player's team in its display order. Used when showing the party
  # screen.
  def pbPlayerDisplayParty(idxBattler = 0)
    partyOrders = pbPartyOrder(idxBattler)
    idxStart, _idxEnd = pbTeamIndexRangeFromBattlerIndex(idxBattler)
    ret = []
    eachInTeamFromBattlerIndex(idxBattler) { |pkmn, i| ret[partyOrders[i] - idxStart] = pkmn }
    return ret
  end

  def pbAbleCount(idxBattler = 0)
    party = pbParty(idxBattler)
    count = 0
    party.each { |pkmn| count += 1 if pkmn&.able? }
    return count
  end

  def pbAbleNonActiveCount(idxBattler = 0)
    party = pbParty(idxBattler)
    inBattleIndices = allSameSideBattlers(idxBattler).map { |b| b.pokemonIndex }
    count = 0
    party.each_with_index do |pkmn, idxParty|
      next if !pkmn || !pkmn.able?
      next if inBattleIndices.include?(idxParty)
      count += 1
    end
    return count
  end

  def pbAllFainted?(idxBattler = 0)
    return pbAbleCount(idxBattler) == 0
  end

  def pbTeamAbleNonActiveCount(idxBattler = 0)
    inBattleIndices = allSameSideBattlers(idxBattler).map { |b| b.pokemonIndex }
    count = 0
    eachInTeamFromBattlerIndex(idxBattler) do |pkmn, i|
      next if !pkmn || !pkmn.able?
      next if inBattleIndices.include?(i)
      count += 1
    end
    return count
  end

  # For the given side of the field (0=player's, 1=opponent's), returns an array
  # containing the number of able Pokémon in each team.
  def pbAbleTeamCounts(side)
    party = pbParty(side)
    partyStarts = pbPartyStarts(side)
    ret = []
    idxTeam = -1
    nextStart = 0
    party.each_with_index do |pkmn, i|
      if i >= nextStart
        idxTeam += 1
        nextStart = (idxTeam < partyStarts.length - 1) ? partyStarts[idxTeam + 1] : party.length
      end
      next if !pkmn || !pkmn.able?
      ret[idxTeam] = 0 if !ret[idxTeam]
      ret[idxTeam] += 1
    end
    return ret
  end

  #-----------------------------------------------------------------------------
  # Get team information (a team is only the Pokémon owned by a particular
  # trainer).
  #-----------------------------------------------------------------------------

  def pbTeamIndexRangeFromBattlerIndex(idxBattler)
    partyStarts = pbPartyStarts(idxBattler)
    idxTrainer = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    idxPartyStart = partyStarts[idxTrainer]
    idxPartyEnd   = (idxTrainer < partyStarts.length - 1) ? partyStarts[idxTrainer + 1] : pbParty(idxBattler).length
    return idxPartyStart, idxPartyEnd
  end

  def pbTeamLengthFromBattlerIndex(idxBattler)
    idxPartyStart, idxPartyEnd = pbTeamIndexRangeFromBattlerIndex(idxBattler)
    return idxPartyEnd - idxPartyStart
  end

  def eachInTeamFromBattlerIndex(idxBattler)
    party = pbParty(idxBattler)
    idxPartyStart, idxPartyEnd = pbTeamIndexRangeFromBattlerIndex(idxBattler)
    party.each_with_index { |pkmn, i| yield pkmn, i if pkmn && i >= idxPartyStart && i < idxPartyEnd }
  end

  def eachInTeam(side, idxTrainer)
    party       = pbParty(side)
    partyStarts = pbPartyStarts(side)
    idxPartyStart = partyStarts[idxTrainer]
    idxPartyEnd   = (idxTrainer < partyStarts.length - 1) ? partyStarts[idxTrainer + 1] : party.length
    party.each_with_index { |pkmn, i| yield pkmn, i if pkmn && i >= idxPartyStart && i < idxPartyEnd }
  end

  # Used for Illusion.
  # NOTE: This cares about the temporary rearranged order of the team. That is,
  #       if you do some switching, the last Pokémon in the team could change
  #       and the Illusion could be a different Pokémon.
  def pbLastInTeam(idxBattler)
    party       = pbParty(idxBattler)
    partyOrders = pbPartyOrder(idxBattler)
    idxPartyStart, idxPartyEnd = pbTeamIndexRangeFromBattlerIndex(idxBattler)
    ret = -1
    party.each_with_index do |pkmn, i|
      next if i < idxPartyStart || i >= idxPartyEnd   # Check the team only
      next if !pkmn || !pkmn.able?   # Can't copy a non-fainted Pokémon or egg
      ret = i if ret < 0 || partyOrders[i] > partyOrders[ret]
    end
    return ret
  end

  # Used to calculate money gained/lost after winning/losing a battle.
  def pbMaxLevelInTeam(side, idxTrainer)
    ret = 1
    eachInTeam(side, idxTrainer) do |pkmn, _i|
      ret = pkmn.level if pkmn.level > ret
    end
    return ret
  end

  #-----------------------------------------------------------------------------
  # Iterate through battlers.
  #-----------------------------------------------------------------------------

  # Unused
  def eachBattler
    @battlers.each { |b| yield b if b && !b.fainted? }
  end

  def allBattlers
    return @battlers.select { |b| b && !b.fainted? }
  end

  # Unused
  def eachSameSideBattler(idxBattler = 0)
    idxBattler = idxBattler.index if idxBattler.respond_to?("index")
    @battlers.each { |b| yield b if b && !b.fainted? && !b.opposes?(idxBattler) }
  end

  def allSameSideBattlers(idxBattler = 0)
    idxBattler = idxBattler.index if idxBattler.respond_to?("index")
    return @battlers.select { |b| b && !b.fainted? && !b.opposes?(idxBattler) }
  end

  # Unused
  def eachOtherSideBattler(idxBattler = 0)
    idxBattler = idxBattler.index if idxBattler.respond_to?("index")
    @battlers.each { |b| yield b if b && !b.fainted? && b.opposes?(idxBattler) }
  end

  def allOtherSideBattlers(idxBattler = 0)
    idxBattler = idxBattler.index if idxBattler.respond_to?("index")
    return @battlers.select { |b| b && !b.fainted? && b.opposes?(idxBattler) }
  end

  def pbSideBattlerCount(idxBattler = 0)
    return allSameSideBattlers(idxBattler).length
  end

  def pbOpposingBattlerCount(idxBattler = 0)
    return allOtherSideBattlers(idxBattler).length
  end

  # This method only counts the player's Pokémon, not a partner trainer's.
  def pbPlayerBattlerCount
    return allSameSideBattlers.select { |b| b.pbOwnedByPlayer? }.length
  end

  def pbCheckGlobalAbility(abil, check_mold_breaker = false)
    allBattlers.each do |b|
      return b if b.hasActiveAbility?(abil) && (!check_mold_breaker || !b.beingMoldBroken?)
    end
    return nil
  end

  def pbCheckOpposingAbility(abil, idxBattler = 0, nearOnly = false)
    allOtherSideBattlers(idxBattler).each do |b|
      next if nearOnly && !b.near?(idxBattler)
      return b if b.hasActiveAbility?(abil)
    end
    return nil
  end

  # Returns an array containing the IDs of all active abilities.
  def pbAllActiveAbilities
    ret = []
    allBattlers.each { |b| ret.push(b.ability_id) if b.abilityActive? }
    return ret
  end

  # Given a battler index, and using battle side sizes, returns an array of
  # battler indices from the opposing side that are in order of most "opposite".
  # Used when choosing a target and pressing up/down to move the cursor to the
  # opposite side, and also when deciding which target to select first for some
  # moves.
  def pbGetOpposingIndicesInOrder(idxBattler)
    case pbSideSize(0)
    when 1
      case pbSideSize(1)
      when 1   # 1v1 single
        return [0] if opposes?(idxBattler)
        return [1]
      when 2   # 1v2
        return [0] if opposes?(idxBattler)
        return [3, 1]
      when 3   # 1v3
        return [0] if opposes?(idxBattler)
        return [3, 5, 1]
      end
    when 2
      case pbSideSize(1)
      when 1   # 2v1
        return [0, 2] if opposes?(idxBattler)
        return [1]
      when 2   # 2v2 double
        return [[3, 1], [2, 0], [1, 3], [0, 2]][idxBattler]
      when 3   # 2v3
        return [[5, 3, 1], [2, 0], [3, 1, 5]][idxBattler] if idxBattler < 3
        return [0, 2]
      end
    when 3
      case pbSideSize(1)
      when 1   # 3v1
        return [2, 0, 4] if opposes?(idxBattler)
        return [1]
      when 2   # 3v2
        return [[3, 1], [2, 4, 0], [3, 1], [2, 0, 4], [1, 3]][idxBattler]
      when 3   # 3v3 triple
        return [[5, 3, 1], [4, 2, 0], [3, 5, 1], [2, 0, 4], [1, 3, 5], [0, 2, 4]][idxBattler]
      end
    end
    return [idxBattler]
  end

  #-----------------------------------------------------------------------------
  # Comparing the positions of two battlers.
  #-----------------------------------------------------------------------------

  def opposes?(idxBattler1, idxBattler2 = 0)
    idxBattler1 = idxBattler1.index if idxBattler1.respond_to?("index")
    idxBattler2 = idxBattler2.index if idxBattler2.respond_to?("index")
    return (idxBattler1 & 1) != (idxBattler2 & 1)
  end

  def nearBattlers?(idxBattler1, idxBattler2)
    return false if idxBattler1 == idxBattler2
    return true if pbSideSize(0) <= 2 && pbSideSize(1) <= 2
    # Get all pairs of battler positions that are not close to each other
    pairsArray = [[0, 4], [1, 5]]   # Covers 3v1 and 1v3
    case pbSideSize(0)
    when 3
      case pbSideSize(1)
      when 3   # 3v3 (triple)
        pairsArray.push([0, 1])
        pairsArray.push([4, 5])
      when 2   # 3v2
        pairsArray.push([0, 1])
        pairsArray.push([3, 4])
      end
    when 2       # 2v3
      pairsArray.push([0, 1])
      pairsArray.push([2, 5])
    end
    # See if any pair matches the two battlers being assessed
    pairsArray.each do |pair|
      return false if pair.include?(idxBattler1) && pair.include?(idxBattler2)
    end
    return true
  end

  #-----------------------------------------------------------------------------
  # Altering a party or rearranging battlers.
  #-----------------------------------------------------------------------------

  def pbRemoveFromParty(idxBattler, idxParty)
    party = pbParty(idxBattler)
    # Erase the Pokémon from the party
    party[idxParty] = nil
    # Rearrange the display order of the team to place the erased Pokémon last
    # in it (to avoid gaps)
    partyOrders = pbPartyOrder(idxBattler)
    partyStarts = pbPartyStarts(idxBattler)
    idxTrainer = pbGetOwnerIndexFromPartyIndex(idxBattler, idxParty)
    idxPartyStart = partyStarts[idxTrainer]
    idxPartyEnd   = (idxTrainer < partyStarts.length - 1) ? partyStarts[idxTrainer + 1] : party.length
    origPartyPos = partyOrders[idxParty]   # Position of erased Pokémon initially
    partyOrders[idxParty] = idxPartyEnd   # Put erased Pokémon last in the team
    party.each_with_index do |_pkmn, i|
      next if i < idxPartyStart || i >= idxPartyEnd   # Only check the team
      next if partyOrders[i] < origPartyPos   # Appeared before erased Pokémon
      partyOrders[i] -= 1   # Appeared after erased Pokémon; bump it up by 1
    end
  end

  def pbSwapBattlers(idxA, idxB)
    return false if !@battlers[idxA] || !@battlers[idxB]
    # Can't swap if battlers aren't owned by the same trainer
    return false if opposes?(idxA, idxB)
    return false if pbGetOwnerIndexFromBattlerIndex(idxA) != pbGetOwnerIndexFromBattlerIndex(idxB)
    @battlers[idxA],       @battlers[idxB]       = @battlers[idxB],       @battlers[idxA]
    @battlers[idxA].index, @battlers[idxB].index = @battlers[idxB].index, @battlers[idxA].index
    @choices[idxA],        @choices[idxB]        = @choices[idxB],        @choices[idxA]
    @scene.pbSwapBattlerSprites(idxA, idxB)
    # Swap the target of any battlers' effects that point at either of the
    # swapped battlers, to ensure they still point at the correct target
    # NOTE: LeechSeed is not swapped, because drained HP goes to whichever
    #       Pokémon is in the position that Leech Seed was used from.
    # NOTE: PerishSongUser doesn't need to change, as it's only used to
    #       determine which side the Perish Song user was on, and a battler
    #       can't change sides.
    effectsToSwap = [PBEffects::Attract,
                     PBEffects::BideTarget,
                     PBEffects::CounterTarget,
                     PBEffects::JawLock,
                     PBEffects::LockOnPos,
                     PBEffects::MeanLook,
                     PBEffects::MirrorCoatTarget,
                     PBEffects::Octolock,
                     PBEffects::SkyDrop,
                     PBEffects::TrappingUser]
    allBattlers.each do |b|
      effectsToSwap.each do |i|
        next if b.effects[i] != idxA && b.effects[i] != idxB
        b.effects[i] = (b.effects[i] == idxA) ? idxB : idxA
      end
    end
    return true
  end

  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------

  # Returns the battler representing the Pokémon at index idxParty in its party,
  # on the same side as a battler with battler index of idxBattlerOther.
  def pbFindBattler(idxParty, idxBattlerOther = 0)
    allSameSideBattlers(idxBattlerOther).each { |b| return b if b.pokemonIndex == idxParty }
    return nil
  end

  # Only used for Wish, as the Wishing Pokémon will no longer be in battle.
  def pbThisEx(idxBattler, idxParty)
    party = pbParty(idxBattler)
    if opposes?(idxBattler)
      return _INTL("The opposing {1}", party[idxParty].name) if trainerBattle?
      return _INTL("The wild {1}", party[idxParty].name)
    end
    return _INTL("The ally {1}", party[idxParty].name) if !pbOwnedByPlayer?(idxBattler)
    return party[idxParty].name
  end

  def pbSetSeen(battler)
    return if !battler || !@internalBattle
    if battler.is_a?(Battler)
      pbPlayer.pokedex.register(battler.displaySpecies, battler.displayGender,
                                battler.displayForm, battler.shiny?)
    else
      pbPlayer.pokedex.register(battler)
    end
  end

  def pbSetCaught(battler)
    return if !battler || !@internalBattle
    if battler.is_a?(Battler)
      pbPlayer.pokedex.register_caught(battler.displaySpecies)
    else
      pbPlayer.pokedex.register_caught(battler.species)
    end
  end

  def pbSetDefeated(battler)
    return if !battler || !@internalBattle
    if battler.is_a?(Battler)
      pbPlayer.pokedex.register_defeated(battler.displaySpecies)
    else
      pbPlayer.pokedex.register_defeated(battler.species)
    end
  end

  def nextPickupUse
    @nextPickupUse += 1
    return @nextPickupUse
  end

  #-----------------------------------------------------------------------------
  # Weather.
  #-----------------------------------------------------------------------------

  def defaultWeather=(value)
    @field.defaultWeather  = value
    @field.weather         = value
    @field.weatherDuration = -1
  end

  # Returns the effective weather (note that weather effects can be negated)
  def pbWeather
    return :None if allBattlers.any? { |b| b.hasActiveAbility?([:CLOUDNINE, :AIRLOCK]) }
    return @field.weather
  end

  # Used for causing weather by a move or by an ability.
  def pbStartWeather(user, newWeather, fixedDuration = false, showAnim = true)
    return if @field.weather == newWeather
    @field.weather = newWeather
    duration = (fixedDuration) ? 5 : -1
    if duration > 0 && user && user.itemActive?
      duration = Battle::ItemEffects.triggerWeatherExtender(user.item, @field.weather,
                                                            duration, user, self)
    end
    @field.weatherDuration = duration
    weather_data = GameData::BattleWeather.try_get(@field.weather)
    pbCommonAnimation(weather_data.animation) if showAnim && weather_data
    pbHideAbilitySplash(user) if user
    case @field.weather
    when :Sun         then pbDisplay(_INTL("The sunlight turned harsh!"))
    when :Rain        then pbDisplay(_INTL("It started to rain!"))
    when :Sandstorm   then pbDisplay(_INTL("A sandstorm brewed!"))
    when :Hail        then pbDisplay(_INTL("It started to hail!"))
    when :Snowstorm   then pbDisplay(_INTL("It started to snow!"))
    when :HarshSun    then pbDisplay(_INTL("The sunlight turned extremely harsh!"))
    when :HeavyRain   then pbDisplay(_INTL("A heavy rain began to fall!"))
    when :StrongWinds then pbDisplay(_INTL("Mysterious strong winds are protecting Flying-type Pokémon!"))
    when :ShadowSky   then pbDisplay(_INTL("A shadow sky appeared!"))
    end
    # Check for end of primordial weather, and weather-triggered form changes
    allBattlers.each { |b| b.pbCheckFormOnWeatherChange }
    pbEndPrimordialWeather
  end

  def pbEndPrimordialWeather
    return if @field.weather == @field.defaultWeather
    oldWeather = @field.weather
    # End Primordial Sea, Desolate Land, Delta Stream
    case @field.weather
    when :HarshSun
      if !pbCheckGlobalAbility(:DESOLATELAND)
        @field.weather = :None
        pbDisplay(_INTL("The harsh sunlight faded!"))
      end
    when :HeavyRain
      if !pbCheckGlobalAbility(:PRIMORDIALSEA)
        @field.weather = :None
        pbDisplay(_INTL("The heavy rain has lifted!"))
      end
    when :StrongWinds
      if !pbCheckGlobalAbility(:DELTASTREAM)
        @field.weather = :None
        pbDisplay(_INTL("The mysterious air current has dissipated!"))
      end
    end
    if @field.weather != oldWeather
      # Check for form changes caused by the weather changing
      allBattlers.each { |b| b.pbCheckFormOnWeatherChange }
      # Start up the default weather
      pbStartWeather(nil, @field.defaultWeather) if @field.defaultWeather != :None
    end
  end

  def pbStartWeatherAbility(new_weather, battler, ignore_primal = false)
    return if !ignore_primal && [:HarshSun, :HeavyRain, :StrongWinds].include?(@field.weather)
    return if @field.weather == new_weather
    pbShowAbilitySplash(battler)
    if !Scene::USE_ABILITY_SPLASH
      pbDisplay(_INTL("{1}'s {2} activated!", battler.pbThis, battler.abilityName))
    end
    fixed_duration = false
    fixed_duration = true if Settings::FIXED_DURATION_WEATHER_FROM_ABILITY &&
                             ![:HarshSun, :HeavyRain, :StrongWinds].include?(new_weather)
    pbStartWeather(battler, new_weather, fixed_duration)
    # NOTE: The ability splash is hidden again in def pbStartWeather.
  end

  #-----------------------------------------------------------------------------
  # Terrain.
  #-----------------------------------------------------------------------------

  def defaultTerrain=(value)
    @field.defaultTerrain  = value
    @field.terrain         = value
    @field.terrainDuration = -1
  end

  def pbStartTerrain(user, newTerrain, fixedDuration = true)
    return if @field.terrain == newTerrain
    @field.terrain = newTerrain
    duration = (fixedDuration) ? 5 : -1
    if duration > 0 && user && user.itemActive?
      duration = Battle::ItemEffects.triggerTerrainExtender(user.item, newTerrain,
                                                            duration, user, self)
    end
    @field.terrainDuration = duration
    terrain_data = GameData::BattleTerrain.try_get(@field.terrain)
    pbCommonAnimation(terrain_data.animation) if terrain_data
    pbHideAbilitySplash(user) if user
    case @field.terrain
    when :Electric
      pbDisplay(_INTL("An electric current runs across the battlefield!"))
    when :Grassy
      pbDisplay(_INTL("Grass grew to cover the battlefield!"))
    when :Misty
      pbDisplay(_INTL("Mist swirled about the battlefield!"))
    when :Psychic
      pbDisplay(_INTL("The battlefield got weird!"))
    end
    # Check for abilities/items that trigger upon the terrain changing
    allBattlers.each { |b| b.pbAbilityOnTerrainChange }
    allBattlers.each { |b| b.pbItemTerrainStatBoostCheck }
  end

  #-----------------------------------------------------------------------------
  # Messages and animations.
  #-----------------------------------------------------------------------------

  def pbDisplay(msg, &block)
    @scene.pbDisplayMessage(msg, &block)
  end

  def pbDisplayBrief(msg)
    @scene.pbDisplayMessage(msg, true)
  end

  def pbDisplayPaused(msg, &block)
    @scene.pbDisplayPausedMessage(msg, &block)
  end

  def pbDisplayConfirm(msg)
    return @scene.pbDisplayConfirmMessage(msg)
  end

  # defaultValue of -1 means "can't cancel". If it's 0 or greater, returns that
  # value when pressing the "Back" button.
  def pbShowCommands(msg, commands, defaultValue = -1)
    return @scene.pbShowCommands(msg, commands, defaultValue)
  end

  def pbAnimation(move, user, targets, hitNum = 0)
    @scene.pbAnimation(move, user, targets, hitNum) if @showAnims
  end

  def pbCommonAnimation(name, user = nil, targets = nil)
    @scene.pbCommonAnimation(name, user, targets) if @showAnims
  end

  def pbShowAbilitySplash(battler, delay = false, logTrigger = true)
    PBDebug.log("[Ability triggered] #{battler.pbThis}'s #{battler.abilityName}") if logTrigger
    return if !Scene::USE_ABILITY_SPLASH
    @scene.pbShowAbilitySplash(battler)
    if delay
      timer_start = System.uptime
      until System.uptime - timer_start >= 1   # 1 second
        @scene.pbUpdate
      end
    end
  end

  def pbHideAbilitySplash(battler)
    return if !Scene::USE_ABILITY_SPLASH
    @scene.pbHideAbilitySplash(battler)
  end

  def pbReplaceAbilitySplash(battler)
    return if !Scene::USE_ABILITY_SPLASH
    @scene.pbReplaceAbilitySplash(battler)
  end
end
