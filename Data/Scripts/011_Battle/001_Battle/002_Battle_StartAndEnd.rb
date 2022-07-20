class Battle
  class BattleAbortedException < Exception; end

  def pbAbort
    raise BattleAbortedException.new("Battle aborted")
  end

  #=============================================================================
  # Makes sure all Pokémon exist that need to. Alter the type of battle if
  # necessary. Will never try to create battler positions, only delete them
  # (except for wild Pokémon whose number of positions are fixed). Reduces the
  # size of each side by 1 and tries again. If the side sizes are uneven, only
  # the larger side's size will be reduced by 1 each time, until both sides are
  # an equal size (then both sides will be reduced equally).
  #=============================================================================
  def pbEnsureParticipants
    # Prevent battles larger than 2v2 if both sides have multiple trainers
    # NOTE: This is necessary to ensure that battlers can never become unable to
    #       hit each other due to being too far away. In such situations,
    #       battlers will move to the centre position at the end of a round, but
    #       because they cannot move into a position owned by a different
    #       trainer, it's possible that battlers will be unable to move close
    #       enough to hit each other if there are multiple trainers on both
    #       sides.
    if trainerBattle? && (@sideSizes[0] > 2 || @sideSizes[1] > 2) &&
       @player.length > 1 && @opponent.length > 1
      raise _INTL("Can't have battles larger than 2v2 where both sides have multiple trainers")
    end
    # Find out how many Pokémon each trainer has
    side1counts = pbAbleTeamCounts(0)
    side2counts = pbAbleTeamCounts(1)
    # Change the size of the battle depending on how many wild Pokémon there are
    if wildBattle? && side2counts[0] != @sideSizes[1]
      if @sideSizes[0] == @sideSizes[1]
        # Even number of battlers per side, change both equally
        @sideSizes = [side2counts[0], side2counts[0]]
      else
        # Uneven number of battlers per side, just change wild side's size
        @sideSizes[1] = side2counts[0]
      end
    end
    # Check if battle is possible, including changing the number of battlers per
    # side if necessary
    loop do
      needsChanging = false
      2.times do |side|   # Each side in turn
        next if side == 1 && wildBattle?   # Wild side's size already checked above
        sideCounts = (side == 0) ? side1counts : side2counts
        requireds = []
        # Find out how many Pokémon each trainer on side needs to have
        @sideSizes[side].times do |i|
          idxTrainer = pbGetOwnerIndexFromBattlerIndex((i * 2) + side)
          requireds[idxTrainer] = 0 if requireds[idxTrainer].nil?
          requireds[idxTrainer] += 1
        end
        # Compare the have values with the need values
        if requireds.length > sideCounts.length
          raise _INTL("Error: def pbGetOwnerIndexFromBattlerIndex gives invalid owner index ({1} for battle type {2}v{3}, trainers {4}v{5})",
                      requireds.length - 1, @sideSizes[0], @sideSizes[1], side1counts.length, side2counts.length)
        end
        sideCounts.each_with_index do |_count, i|
          if !requireds[i] || requireds[i] == 0
            case side
            when 0
              raise _INTL("Player-side trainer {1} has no battler position for their Pokémon to go (trying {2}v{3} battle)",
                          i + 1, @sideSizes[0], @sideSizes[1])
            when 1
              raise _INTL("Opposing trainer {1} has no battler position for their Pokémon to go (trying {2}v{3} battle)",
                          i + 1, @sideSizes[0], @sideSizes[1])
            end
          end
          next if requireds[i] <= sideCounts[i]   # Trainer has enough Pokémon to fill their positions
          if requireds[i] == 1
            raise _INTL("Player-side trainer {1} has no able Pokémon", i + 1) if side == 0
            raise _INTL("Opposing trainer {1} has no able Pokémon", i + 1) if side == 1
          end
          # Not enough Pokémon, try lowering the number of battler positions
          needsChanging = true
          break
        end
        break if needsChanging
      end
      break if !needsChanging
      # Reduce one or both side's sizes by 1 and try again
      if wildBattle?
        PBDebug.log("#{@sideSizes[0]}v#{@sideSizes[1]} battle isn't possible " +
                    "(#{side1counts} player-side teams versus #{side2counts[0]} wild Pokémon)")
        newSize = @sideSizes[0] - 1
      else
        PBDebug.log("#{@sideSizes[0]}v#{@sideSizes[1]} battle isn't possible " +
                    "(#{side1counts} player-side teams versus #{side2counts} opposing teams)")
        newSize = @sideSizes.max - 1
      end
      if newSize == 0
        raise _INTL("Couldn't lower either side's size any further, battle isn't possible")
      end
      2.times do |side|
        next if side == 1 && wildBattle?   # Wild Pokémon's side size is fixed
        next if @sideSizes[side] == 1 || newSize > @sideSizes[side]
        @sideSizes[side] = newSize
      end
      PBDebug.log("Trying #{@sideSizes[0]}v#{@sideSizes[1]} battle instead")
    end
  end

  #=============================================================================
  # Set up all battlers
  #=============================================================================
  def pbCreateBattler(idxBattler, pkmn, idxParty)
    if !@battlers[idxBattler].nil?
      raise _INTL("Battler index {1} already exists", idxBattler)
    end
    @battlers[idxBattler] = Battler.new(self, idxBattler)
    @positions[idxBattler] = ActivePosition.new
    pbClearChoice(idxBattler)
    @successStates[idxBattler] = SuccessState.new
    @battlers[idxBattler].pbInitialize(pkmn, idxParty)
  end

  def pbSetUpSides
    ret = [[], []]
    2.times do |side|
      # Set up wild Pokémon
      if side == 1 && wildBattle?
        pbParty(1).each_with_index do |pkmn, idxPkmn|
          pbCreateBattler((2 * idxPkmn) + side, pkmn, idxPkmn)
          # Changes the Pokémon's form upon entering battle (if it should)
          @peer.pbOnEnteringBattle(self, @battlers[(2 * idxPkmn) + side], pkmn, true)
          pbSetSeen(@battlers[(2 * idxPkmn) + side])
          @usedInBattle[side][idxPkmn] = true
        end
        next
      end
      # Set up player's Pokémon and trainers' Pokémon
      trainer = (side == 0) ? @player : @opponent
      requireds = []
      # Find out how many Pokémon each trainer on side needs to have
      @sideSizes[side].times do |i|
        idxTrainer = pbGetOwnerIndexFromBattlerIndex((i * 2) + side)
        requireds[idxTrainer] = 0 if requireds[idxTrainer].nil?
        requireds[idxTrainer] += 1
      end
      # For each trainer in turn, find the needed number of Pokémon for them to
      # send out, and initialize them
      battlerNumber = 0
      partyOrder = pbPartyOrder(side)
      starts = pbPartyStarts(side)
      trainer.each_with_index do |_t, idxTrainer|
        ret[side][idxTrainer] = []
        eachInTeam(side, idxTrainer) do |pkmn, idxPkmn|
          next if !pkmn.able?
          idxBattler = (2 * battlerNumber) + side
          pbCreateBattler(idxBattler, pkmn, idxPkmn)
          ret[side][idxTrainer].push(idxBattler)
          if idxPkmn != starts[idxTrainer] + battlerNumber
            idxOther = starts[idxTrainer] + battlerNumber
            partyOrder[idxPkmn], partyOrder[idxOther] = partyOrder[idxOther], partyOrder[idxPkmn]
          end
          battlerNumber += 1
          break if ret[side][idxTrainer].length >= requireds[idxTrainer]
        end
      end
    end
    return ret
  end

  #=============================================================================
  # Send out all battlers at the start of battle
  #=============================================================================
  def pbStartBattleSendOut(sendOuts)
    # "Want to battle" messages
    if wildBattle?
      foeParty = pbParty(1)
      case foeParty.length
      when 1
        pbDisplayPaused(_INTL("Oh! A wild {1} appeared!", foeParty[0].name))
      when 2
        pbDisplayPaused(_INTL("Oh! A wild {1} and {2} appeared!", foeParty[0].name,
                              foeParty[1].name))
      when 3
        pbDisplayPaused(_INTL("Oh! A wild {1}, {2} and {3} appeared!", foeParty[0].name,
                              foeParty[1].name, foeParty[2].name))
      end
    else   # Trainer battle
      case @opponent.length
      when 1
        pbDisplayPaused(_INTL("You are challenged by {1}!", @opponent[0].full_name))
      when 2
        pbDisplayPaused(_INTL("You are challenged by {1} and {2}!", @opponent[0].full_name,
                              @opponent[1].full_name))
      when 3
        pbDisplayPaused(_INTL("You are challenged by {1}, {2} and {3}!",
                              @opponent[0].full_name, @opponent[1].full_name, @opponent[2].full_name))
      end
    end
    # Send out Pokémon (opposing trainers first)
    [1, 0].each do |side|
      next if side == 1 && wildBattle?
      msg = ""
      toSendOut = []
      trainers = (side == 0) ? @player : @opponent
      # Opposing trainers and partner trainers's messages about sending out Pokémon
      trainers.each_with_index do |t, i|
        next if side == 0 && i == 0   # The player's message is shown last
        msg += "\r\n" if msg.length > 0
        sent = sendOuts[side][i]
        case sent.length
        when 1
          msg += _INTL("{1} sent out {2}!", t.full_name, @battlers[sent[0]].name)
        when 2
          msg += _INTL("{1} sent out {2} and {3}!", t.full_name,
                       @battlers[sent[0]].name, @battlers[sent[1]].name)
        when 3
          msg += _INTL("{1} sent out {2}, {3} and {4}!", t.full_name,
                       @battlers[sent[0]].name, @battlers[sent[1]].name, @battlers[sent[2]].name)
        end
        toSendOut.concat(sent)
      end
      # The player's message about sending out Pokémon
      if side == 0
        msg += "\r\n" if msg.length > 0
        sent = sendOuts[side][0]
        case sent.length
        when 1
          msg += _INTL("Go! {1}!", @battlers[sent[0]].name)
        when 2
          msg += _INTL("Go! {1} and {2}!", @battlers[sent[0]].name, @battlers[sent[1]].name)
        when 3
          msg += _INTL("Go! {1}, {2} and {3}!", @battlers[sent[0]].name,
                       @battlers[sent[1]].name, @battlers[sent[2]].name)
        end
        toSendOut.concat(sent)
      end
      pbDisplayBrief(msg) if msg.length > 0
      # The actual sending out of Pokémon
      animSendOuts = []
      toSendOut.each do |idxBattler|
        animSendOuts.push([idxBattler, @battlers[idxBattler].pokemon])
      end
      pbSendOut(animSendOuts, true)
    end
  end

  #=============================================================================
  # Start a battle
  #=============================================================================
  def pbStartBattle
    PBDebug.log("")
    PBDebug.log("******************************************")
    logMsg = "[Started battle] "
    if @sideSizes[0] == 1 && @sideSizes[1] == 1
      logMsg += "Single "
    elsif @sideSizes[0] == 2 && @sideSizes[1] == 2
      logMsg += "Double "
    elsif @sideSizes[0] == 3 && @sideSizes[1] == 3
      logMsg += "Triple "
    else
      logMsg += "#{@sideSizes[0]}v#{@sideSizes[1]} "
    end
    logMsg += "wild " if wildBattle?
    logMsg += "trainer " if trainerBattle?
    logMsg += "battle (#{@player.length} trainer(s) vs. "
    logMsg += "#{pbParty(1).length} wild Pokémon)" if wildBattle?
    logMsg += "#{@opponent.length} trainer(s))" if trainerBattle?
    PBDebug.log(logMsg)
    pbEnsureParticipants
    pbParty(0).each { |pkmn| @peer.pbOnStartingBattle(self, pkmn, wildBattle?) if pkmn }
    pbParty(1).each { |pkmn| @peer.pbOnStartingBattle(self, pkmn, wildBattle?) if pkmn }
    begin
      pbStartBattleCore
    rescue BattleAbortedException
      @decision = 0
      @scene.pbEndBattle(@decision)
    end
    return @decision
  end

  def pbStartBattleCore
    # Set up the battlers on each side
    sendOuts = pbSetUpSides
    # Create all the sprites and play the battle intro animation
    @scene.pbStartBattle(self)
    # Show trainers on both sides sending out Pokémon
    pbStartBattleSendOut(sendOuts)
    # Weather announcement
    weather_data = GameData::BattleWeather.try_get(@field.weather)
    pbCommonAnimation(weather_data.animation) if weather_data
    case @field.weather
    when :Sun         then pbDisplay(_INTL("The sunlight is strong."))
    when :Rain        then pbDisplay(_INTL("It is raining."))
    when :Sandstorm   then pbDisplay(_INTL("A sandstorm is raging."))
    when :Hail        then pbDisplay(_INTL("Hail is falling."))
    when :HarshSun    then pbDisplay(_INTL("The sunlight is extremely harsh."))
    when :HeavyRain   then pbDisplay(_INTL("It is raining heavily."))
    when :StrongWinds then pbDisplay(_INTL("The wind is strong."))
    when :ShadowSky   then pbDisplay(_INTL("The sky is shadowy."))
    end
    # Terrain announcement
    terrain_data = GameData::BattleTerrain.try_get(@field.terrain)
    pbCommonAnimation(terrain_data.animation) if terrain_data
    case @field.terrain
    when :Electric
      pbDisplay(_INTL("An electric current runs across the battlefield!"))
    when :Grassy
      pbDisplay(_INTL("Grass is covering the battlefield!"))
    when :Misty
      pbDisplay(_INTL("Mist swirls about the battlefield!"))
    when :Psychic
      pbDisplay(_INTL("The battlefield is weird!"))
    end
    # Abilities upon entering battle
    pbOnAllBattlersEnteringBattle
    # Main battle loop
    pbBattleLoop
  end

  #=============================================================================
  # Main battle loop
  #=============================================================================
  def pbBattleLoop
    @turnCount = 0
    loop do   # Now begin the battle loop
      PBDebug.log("")
      PBDebug.log("***Round #{@turnCount + 1}***")
      if @debug && @turnCount >= 100
        @decision = pbDecisionOnTime
        PBDebug.log("")
        PBDebug.log("***Undecided after 100 rounds, aborting***")
        pbAbort
        break
      end
      PBDebug.log("")
      # Command phase
      PBDebug.logonerr { pbCommandPhase }
      break if @decision > 0
      # Attack phase
      PBDebug.logonerr { pbAttackPhase }
      break if @decision > 0
      # End of round phase
      PBDebug.logonerr { pbEndOfRoundPhase }
      break if @decision > 0
      @turnCount += 1
    end
    pbEndOfBattle
  end

  #=============================================================================
  # End of battle
  #=============================================================================
  def pbGainMoney
    return if !@internalBattle || !@moneyGain
    # Money rewarded from opposing trainers
    if trainerBattle?
      tMoney = 0
      @opponent.each_with_index do |t, i|
        tMoney += pbMaxLevelInTeam(1, i) * t.base_money
      end
      tMoney *= 2 if @field.effects[PBEffects::AmuletCoin]
      tMoney *= 2 if @field.effects[PBEffects::HappyHour]
      oldMoney = pbPlayer.money
      pbPlayer.money += tMoney
      moneyGained = pbPlayer.money - oldMoney
      if moneyGained > 0
        $stats.battle_money_gained += moneyGained
        pbDisplayPaused(_INTL("You got ${1} for winning!", moneyGained.to_s_formatted))
      end
    end
    # Pick up money scattered by Pay Day
    if @field.effects[PBEffects::PayDay] > 0
      @field.effects[PBEffects::PayDay] *= 2 if @field.effects[PBEffects::AmuletCoin]
      @field.effects[PBEffects::PayDay] *= 2 if @field.effects[PBEffects::HappyHour]
      oldMoney = pbPlayer.money
      pbPlayer.money += @field.effects[PBEffects::PayDay]
      moneyGained = pbPlayer.money - oldMoney
      if moneyGained > 0
        $stats.battle_money_gained += moneyGained
        pbDisplayPaused(_INTL("You picked up ${1}!", moneyGained.to_s_formatted))
      end
    end
  end

  def pbLoseMoney
    return if !@internalBattle || !@moneyGain
    return if $game_switches[Settings::NO_MONEY_LOSS]
    maxLevel = pbMaxLevelInTeam(0, 0)   # Player's Pokémon only, not partner's
    multiplier = [8, 16, 24, 36, 48, 64, 80, 100, 120]
    idxMultiplier = [pbPlayer.badge_count, multiplier.length - 1].min
    tMoney = maxLevel * multiplier[idxMultiplier]
    tMoney = pbPlayer.money if tMoney > pbPlayer.money
    oldMoney = pbPlayer.money
    pbPlayer.money -= tMoney
    moneyLost = oldMoney - pbPlayer.money
    if moneyLost > 0
      $stats.battle_money_lost += moneyLost
      if trainerBattle?
        pbDisplayPaused(_INTL("You gave ${1} to the winner...", moneyLost.to_s_formatted))
      else
        pbDisplayPaused(_INTL("You panicked and dropped ${1}...", moneyLost.to_s_formatted))
      end
    end
  end

  def pbEndOfBattle
    oldDecision = @decision
    @decision = 4 if @decision == 1 && wildBattle? && @caughtPokemon.length > 0
    case oldDecision
    ##### WIN #####
    when 1
      PBDebug.log("")
      PBDebug.log("***Player won***")
      if trainerBattle?
        @scene.pbTrainerBattleSuccess
        case @opponent.length
        when 1
          pbDisplayPaused(_INTL("You defeated {1}!", @opponent[0].full_name))
        when 2
          pbDisplayPaused(_INTL("You defeated {1} and {2}!", @opponent[0].full_name,
                                @opponent[1].full_name))
        when 3
          pbDisplayPaused(_INTL("You defeated {1}, {2} and {3}!", @opponent[0].full_name,
                                @opponent[1].full_name, @opponent[2].full_name))
        end
        @opponent.each_with_index do |trainer, i|
          @scene.pbShowOpponent(i)
          msg = trainer.lose_text
          msg = "..." if !msg || msg.empty?
          pbDisplayPaused(msg.gsub(/\\[Pp][Nn]/, pbPlayer.name))
        end
      end
      # Gain money from winning a trainer battle, and from Pay Day
      pbGainMoney if @decision != 4
      # Hide remaining trainer
      @scene.pbShowOpponent(@opponent.length) if trainerBattle? && @caughtPokemon.length > 0
    ##### LOSE, DRAW #####
    when 2, 5
      PBDebug.log("")
      PBDebug.log("***Player lost***") if @decision == 2
      PBDebug.log("***Player drew with opponent***") if @decision == 5
      if @internalBattle
        pbDisplayPaused(_INTL("You have no more Pokémon that can fight!"))
        if trainerBattle?
          case @opponent.length
          when 1
            pbDisplayPaused(_INTL("You lost against {1}!", @opponent[0].full_name))
          when 2
            pbDisplayPaused(_INTL("You lost against {1} and {2}!",
                                  @opponent[0].full_name, @opponent[1].full_name))
          when 3
            pbDisplayPaused(_INTL("You lost against {1}, {2} and {3}!",
                                  @opponent[0].full_name, @opponent[1].full_name, @opponent[2].full_name))
          end
        end
        # Lose money from losing a battle
        pbLoseMoney
        pbDisplayPaused(_INTL("You blacked out!")) if !@canLose
      elsif @decision == 2   # Lost in a Battle Frontier battle
        if @opponent
          @opponent.each_with_index do |trainer, i|
            @scene.pbShowOpponent(i)
            msg = trainer.win_text
            msg = "..." if !msg || msg.empty?
            pbDisplayPaused(msg.gsub(/\\[Pp][Nn]/, pbPlayer.name))
          end
        end
      end
    ##### CAUGHT WILD POKÉMON #####
    when 4
      @scene.pbWildBattleSuccess if !Settings::GAIN_EXP_FOR_CAPTURE
    end
    # Register captured Pokémon in the Pokédex, and store them
    pbRecordAndStoreCaughtPokemon
    # Collect Pay Day money in a wild battle that ended in a capture
    pbGainMoney if @decision == 4
    # Pass on Pokérus within the party
    if @internalBattle
      infected = []
      $player.party.each_with_index do |pkmn, i|
        infected.push(i) if pkmn.pokerusStage == 1
      end
      infected.each do |idxParty|
        strain = $player.party[idxParty].pokerusStrain
        if idxParty > 0 && $player.party[idxParty - 1].pokerusStage == 0 && rand(3) == 0   # 33%
          $player.party[idxParty - 1].givePokerus(strain)
        end
        if idxParty < $player.party.length - 1 && $player.party[idxParty + 1].pokerusStage == 0 && rand(3) == 0   # 33%
          $player.party[idxParty + 1].givePokerus(strain)
        end
      end
    end
    # Clean up battle stuff
    @scene.pbEndBattle(@decision)
    @battlers.each do |b|
      next if !b
      pbCancelChoice(b.index)   # Restore unused items to Bag
      Battle::AbilityEffects.triggerOnSwitchOut(b.ability, b, true) if b.abilityActive?
    end
    pbParty(0).each_with_index do |pkmn, i|
      next if !pkmn
      @peer.pbOnLeavingBattle(self, pkmn, @usedInBattle[0][i], true)   # Reset form
      pkmn.item = @initialItems[0][i]
    end
    return @decision
  end

  #=============================================================================
  # Judging
  #=============================================================================
  def pbJudgeCheckpoint(user, move = nil); end

  def pbDecisionOnTime
    counts   = [0, 0]
    hpTotals = [0, 0]
    2.times do |side|
      pbParty(side).each do |pkmn|
        next if !pkmn || !pkmn.able?
        counts[side]   += 1
        hpTotals[side] += pkmn.hp
      end
    end
    return 1 if counts[0] > counts[1]       # Win (player has more able Pokémon)
    return 2 if counts[0] < counts[1]       # Loss (foe has more able Pokémon)
    return 1 if hpTotals[0] > hpTotals[1]   # Win (player has more HP in total)
    return 2 if hpTotals[0] < hpTotals[1]   # Loss (foe has more HP in total)
    return 5                              # Draw
  end

  # Unused
  def pbDecisionOnTime2
    counts   = [0, 0]
    hpTotals = [0, 0]
    2.times do |side|
      pbParty(side).each do |pkmn|
        next if !pkmn || !pkmn.able?
        counts[side]   += 1
        hpTotals[side] += 100 * pkmn.hp / pkmn.totalhp
      end
      hpTotals[side] /= counts[side] if counts[side] > 1
    end
    return 1 if counts[0] > counts[1]       # Win (player has more able Pokémon)
    return 2 if counts[0] < counts[1]       # Loss (foe has more able Pokémon)
    return 1 if hpTotals[0] > hpTotals[1]   # Win (player has a bigger average HP %)
    return 2 if hpTotals[0] < hpTotals[1]   # Loss (foe has a bigger average HP %)
    return 5                              # Draw
  end

  def pbDecisionOnDraw; return 5; end     # Draw

  def pbJudge
    fainted1 = pbAllFainted?(0)
    fainted2 = pbAllFainted?(1)
    if fainted1 && fainted2
      @decision = pbDecisionOnDraw   # Draw
    elsif fainted1
      @decision = 2                  # Loss
    elsif fainted2
      @decision = 1                  # Win
    end
  end
end
