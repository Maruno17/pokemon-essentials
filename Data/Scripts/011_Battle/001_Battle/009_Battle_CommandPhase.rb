class Battle
  #=============================================================================
  # Clear commands
  #=============================================================================
  def pbClearChoice(idxBattler)
    @choices[idxBattler] = [] if !@choices[idxBattler]
    @choices[idxBattler][0] = :None
    @choices[idxBattler][1] = 0
    @choices[idxBattler][2] = nil
    @choices[idxBattler][3] = -1
  end

  def pbCancelChoice(idxBattler)
    # If idxBattler's choice was to use an item, return that item to the Bag
    if @choices[idxBattler][0] == :UseItem
      item = @choices[idxBattler][1]
      pbReturnUnusedItemToBag(item, idxBattler) if item
    end
    # If idxBattler chose to Mega Evolve, cancel it
    pbUnregisterMegaEvolution(idxBattler)
    # Clear idxBattler's choice
    pbClearChoice(idxBattler)
  end

  #=============================================================================
  # Use main command menu (Fight/Pokémon/Bag/Run)
  #=============================================================================
  def pbCommandMenu(idxBattler, firstAction)
    return @scene.pbCommandMenu(idxBattler, firstAction)
  end

  #=============================================================================
  # Check whether actions can be taken
  #=============================================================================
  def pbCanShowCommands?(idxBattler)
    battler = @battlers[idxBattler]
    return false if !battler || battler.fainted?
    return false if battler.usingMultiTurnAttack?
    return true
  end

  def pbCanShowFightMenu?(idxBattler)
    battler = @battlers[idxBattler]
    # Encore
    return false if battler.effects[PBEffects::Encore] > 0
    # No moves that can be chosen (will Struggle instead)
    usable = false
    battler.eachMoveWithIndex do |_m, i|
      next if !pbCanChooseMove?(idxBattler, i, false)
      usable = true
      break
    end
    return usable
  end

  #=============================================================================
  # Use sub-menus to choose an action, and register it if is allowed
  #=============================================================================
  # Returns true if a choice was made, false if cancelled.
  def pbFightMenu(idxBattler)
    # Auto-use Encored move or no moves choosable, so auto-use Struggle
    return pbAutoChooseMove(idxBattler) if !pbCanShowFightMenu?(idxBattler)
    # Battle Palace only
    return true if pbAutoFightMenu(idxBattler)
    # Regular move selection
    ret = false
    @scene.pbFightMenu(idxBattler, pbCanMegaEvolve?(idxBattler)) do |cmd|
      case cmd
      when -1   # Cancel
      when -2   # Toggle Mega Evolution
        pbToggleRegisteredMegaEvolution(idxBattler)
        next false
      when -3   # Shift
        pbUnregisterMegaEvolution(idxBattler)
        pbRegisterShift(idxBattler)
        ret = true
      else      # Chose a move to use
        next false if cmd < 0 || !@battlers[idxBattler].moves[cmd] ||
                      !@battlers[idxBattler].moves[cmd].id
        next false if !pbRegisterMove(idxBattler, cmd)
        next false if !singleBattle? &&
                      !pbChooseTarget(@battlers[idxBattler], @battlers[idxBattler].moves[cmd])
        ret = true
      end
      next true
    end
    return ret
  end

  def pbAutoFightMenu(idxBattler); return false; end

  def pbChooseTarget(battler, move)
    target_data = move.pbTarget(battler)
    idxTarget = @scene.pbChooseTarget(battler.index, target_data)
    return false if idxTarget < 0
    pbRegisterTarget(battler.index, idxTarget)
    return true
  end

  def pbItemMenu(idxBattler, firstAction)
    if !@internalBattle
      pbDisplay(_INTL("Items can't be used here."))
      return false
    end
    ret = false
    @scene.pbItemMenu(idxBattler, firstAction) do |item, useType, idxPkmn, idxMove, itemScene|
      next false if !item
      battler = pkmn = nil
      case useType
      when 1, 2   # Use on Pokémon/Pokémon's move
        next false if !ItemHandlers.hasBattleUseOnPokemon(item)
        battler = pbFindBattler(idxPkmn, idxBattler)
        pkmn    = pbParty(idxBattler)[idxPkmn]
        next false if !pbCanUseItemOnPokemon?(item, pkmn, battler, itemScene)
      when 3   # Use on battler
        next false if !ItemHandlers.hasBattleUseOnBattler(item)
        battler = pbFindBattler(idxPkmn, idxBattler)
        pkmn    = battler.pokemon if battler
        next false if !pbCanUseItemOnPokemon?(item, pkmn, battler, itemScene)
      when 4   # Poké Balls
        next false if idxPkmn < 0
        battler = @battlers[idxPkmn]
        pkmn    = battler.pokemon if battler
      when 5   # No target (Poké Doll, Guard Spec., Launcher items)
        battler = @battlers[idxBattler]
        pkmn    = battler.pokemon if battler
      else
        next false
      end
      next false if !pkmn
      next false if !ItemHandlers.triggerCanUseInBattle(item, pkmn, battler, idxMove,
                                                        firstAction, self, itemScene)
      next false if !pbRegisterItem(idxBattler, item, idxPkmn, idxMove)
      ret = true
      next true
    end
    return ret
  end

  def pbPartyMenu(idxBattler)
    ret = -1
    if @debug
      ret = @battleAI.pbDefaultChooseNewEnemy(idxBattler)
    else
      ret = pbPartyScreen(idxBattler, false, true, true)
    end
    return ret >= 0
  end

  def pbRunMenu(idxBattler)
    # Regardless of succeeding or failing to run, stop choosing actions
    return pbRun(idxBattler) != 0
  end

  def pbCallMenu(idxBattler)
    return pbRegisterCall(idxBattler)
  end

  def pbDebugMenu
    pbBattleDebug(self)
    @scene.pbRefreshEverything
    allBattlers.each { |b| b.pbCheckFormOnWeatherChange }
    pbEndPrimordialWeather
    allBattlers.each { |b| b.pbAbilityOnTerrainChange }
    allBattlers.each do |b|
      b.pbCheckFormOnMovesetChange
      b.pbCheckFormOnStatusChange
    end
  end

  #=============================================================================
  # Command phase
  #=============================================================================
  def pbCommandPhase
    @command_phase = true
    @scene.pbBeginCommandPhase
    # Reset choices if commands can be shown
    @battlers.each_with_index do |b, i|
      next if !b
      pbClearChoice(i) if pbCanShowCommands?(i)
    end
    # Reset choices to perform Mega Evolution if it wasn't done somehow
    2.times do |side|
      @megaEvolution[side].each_with_index do |megaEvo, i|
        @megaEvolution[side][i] = -1 if megaEvo >= 0
      end
    end
    # Choose actions for the round (player first, then AI)
    pbCommandPhaseLoop(true)    # Player chooses their actions
    if @decision != 0   # Battle ended, stop choosing actions
      @command_phase = false
      return
    end
    pbCommandPhaseLoop(false)   # AI chooses their actions
    @command_phase = false
  end

  def pbCommandPhaseLoop(isPlayer)
    # NOTE: Doing some things (e.g. running, throwing a Poké Ball) takes up all
    #       your actions in a round.
    actioned = []
    idxBattler = -1
    loop do
      break if @decision != 0   # Battle ended, stop choosing actions
      idxBattler += 1
      break if idxBattler >= @battlers.length
      next if !@battlers[idxBattler] || pbOwnedByPlayer?(idxBattler) != isPlayer
      if @choices[idxBattler][0] != :None || !pbCanShowCommands?(idxBattler)
        # Action is forced, can't choose one
        PBDebug.log_ai("#{@battlers[idxBattler].pbThis} (#{idxBattler}) is forced to use a multi-turn move")
        next
      end
      # AI controls this battler
      if @controlPlayer || !pbOwnedByPlayer?(idxBattler)
        @battleAI.pbDefaultChooseEnemyCommand(idxBattler)
        next
      end
      # Player chooses an action
      actioned.push(idxBattler)
      commandsEnd = false   # Whether to cancel choosing all other actions this round
      loop do
        cmd = pbCommandMenu(idxBattler, actioned.length == 1)
        # If being Sky Dropped, can't do anything except use a move
        if cmd > 0 && @battlers[idxBattler].effects[PBEffects::SkyDrop] >= 0
          pbDisplay(_INTL("Sky Drop won't let {1} go!", @battlers[idxBattler].pbThis(true)))
          next
        end
        case cmd
        when 0    # Fight
          break if pbFightMenu(idxBattler)
        when 1    # Bag
          if pbItemMenu(idxBattler, actioned.length == 1)
            commandsEnd = true if pbItemUsesAllActions?(@choices[idxBattler][1])
            break
          end
        when 2    # Pokémon
          break if pbPartyMenu(idxBattler)
        when 3    # Run
          # NOTE: "Run" is only an available option for the first battler the
          #       player chooses an action for in a round. Attempting to run
          #       from battle prevents you from choosing any other actions in
          #       that round.
          if pbRunMenu(idxBattler)
            commandsEnd = true
            break
          end
        when 4    # Call
          break if pbCallMenu(idxBattler)
        when -2   # Debug
          pbDebugMenu
          next
        when -1   # Go back to previous battler's action choice
          next if actioned.length <= 1
          actioned.pop   # Forget this battler was done
          idxBattler = actioned.last - 1
          pbCancelChoice(idxBattler + 1)   # Clear the previous battler's choice
          actioned.pop   # Forget the previous battler was done
          break
        end
        pbCancelChoice(idxBattler)
      end
      break if commandsEnd
    end
  end
end
