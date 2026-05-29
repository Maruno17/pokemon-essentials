#===============================================================================
#
#===============================================================================
class Battle::Scene
  #-----------------------------------------------------------------------------
  # The player chooses a main command for a Pokémon.
  #-----------------------------------------------------------------------------

  def pbCommandMenu(idxBattler, firstAction)
    cmds = []
    # Commands for top row
    if @battle.pbCanShift?(idxBattler)
      cmds.push(:fight2)
      cmds.push(:shift)
    else
      cmds.push(:fight)
    end
    cmds.push(nil)
    # Commands for bottom row
    cmds.push(:bag) if !@battle.rules[:disable_bag] || !Settings::HIDE_USELESS_BATTLE_COMMANDS
    cmds.push(:call) if @battle.battlers[idxBattler].shadowPokemon?
    if firstAction
      if $DEBUG || !Settings::HIDE_USELESS_BATTLE_COMMANDS
        cmds.push(:run)
      elsif @battle.trainerBattle?
        cmds.push(:run) if !@internalBattle || Settings::CAN_FORFEIT_TRAINER_BATTLES
      elsif !@battle.rules[:cannot_run]
        cmds.push(:run)
      end
    else
      cmds.push(:cancel)
    end
    cmds.push(:pokemon)
    # Open the menu
    ret = pbCommandMenuEx(idxBattler, cmds)
    return ret
  end

  def pbCommandMenuEx(idxBattler, commands)
    pbShowWindow(COMMAND_BOX)
    cw = @sprites["commandWindow"]
    cw.set_index_and_commands(@lastCmd[idxBattler], commands)
    cw.active = true
    pbSelectBattler(idxBattler)
    ret = :cancel
    loop do
      pbUpdate(cw)
      # Actions
      if Input.trigger?(Input::USE)   # Confirm choice
        pbPlayDecisionSE
        ret = cw.command
        @lastCmd[idxBattler] = ret
        break
      elsif Input.trigger?(Input::BACK) && commands.include?(:cancel)   # Cancel
        pbPlayCancelSE
        break
      elsif Input.trigger?(Input::F9) && $DEBUG   # Debug menu
        pbPlayDecisionSE
        ret = :debug
        break
      end
    end
    cw.active = false
    return ret
  end

  #-----------------------------------------------------------------------------
  # The player chooses a move for a Pokémon to use.
  #-----------------------------------------------------------------------------

  def pbFightMenu(idxBattler, megaEvoPossible = false)
    pbShowWindow(FIGHT_BOX)
    battler = @battle.battlers[idxBattler]
    cw = @sprites["fightWindow"]
    move_index = 0
    move_index = @lastMove[idxBattler] if battler.moves[@lastMove[idxBattler]]&.id
    cw.set_battler_and_index(battler, move_index)
    cw.mega_evolution_state = (megaEvoPossible) ? 1 : 0
    cw.active = true
    pbSelectBattler(idxBattler)
    need_full_refresh = false
    need_refresh = false
    loop do
      # Refresh view if necessary
      if need_full_refresh
        pbShowWindow(FIGHT_BOX)
        pbSelectBattler(idxBattler)
        need_full_refresh = false
        need_refresh = true
      end
      if need_refresh
        if megaEvoPossible
          cw.mega_evolution_state = (@battle.pbRegisteredMegaEvolution?(idxBattler)) ? 2 : 1
        end
        need_refresh = false
      end
      # General update
      pbUpdate(cw)
      # Actions
      if Input.trigger?(Input::USE)      # Confirm choice
        pbPlayDecisionSE
        break if yield cw.index
        need_full_refresh = true
        need_refresh = true
      elsif Input.trigger?(Input::BACK)   # Cancel fight menu
        pbPlayCancelSE
        break if yield -1
        need_refresh = true
      elsif Input.trigger?(Input::ACTION)   # Toggle Mega Evolution
        if cw.mega_evolution_state > 0
          pbPlayDecisionSE
          break if yield -2
          need_refresh = true
        end
      end
    end
    cw.active = false
    @lastMove[idxBattler] = cw.index
  end

  #-----------------------------------------------------------------------------
  # Opens the party screen to choose a Pokémon to switch in (or just view its
  # summary screens).
  # mode: 0=Pokémon command, 1=choose a Pokémon to send to the Boxes, 2=view
  #       summaries only, 3=select a Pokémon
  #-----------------------------------------------------------------------------

  def pbPartyScreen(idxBattler, canCancel = false, mode = 0)
    # Fade out and hide all sprites
    visibleSprites = pbFadeOutAndHide(@sprites)
    # Get player's party
    partyPos = @battle.pbPartyOrder(idxBattler)
    partyStart, _partyEnd = @battle.pbTeamIndexRangeFromBattlerIndex(idxBattler)
    modParty = @battle.pbPlayerDisplayParty(idxBattler)
    # Start party screen
    party_mode = :battle_choose_pokemon
    party_mode = :battle_choose_to_box if mode == 1
    party_mode = :battle_choose_to_revive if mode == 3
    screen = UI::Party.new(modParty, mode: party_mode)
    screen.cannot_cancel = !canCancel
    screen.choose_pokemon do |pkmn, party_index|
      if party_index < 0
        screen.show_message(_INTL("You have to choose a Pokémon!")) if !canCancel
        next canCancel
      end
      # Choose a command for the selected Pokémon
      commands = {}
      commands[:switch_in]     = _INTL("Switch In") if mode == 0 && pkmn.able? &&
                                                       (!@battle.rules[:cannot_switch] || !canCancel)
      commands[:send_to_boxes] = _INTL("Send to Boxes") if mode == 1 && !pkmn.cannot_store
      commands[:select]        = _INTL("Select") if mode == 3
      commands[:summary]       = _INTL("Summary")
      commands[:cancel]        = _INTL("Cancel")
      choice = screen.show_menu(_INTL("Do what with {1}?", pkmn.name), commands)
      next false if choice.nil?
      case choice
      when :select, :switch_in, :send_to_boxes
        real_party_index = -1
        partyPos.each_with_index do |pos, i|
          next if pos != party_index + partyStart
          real_party_index = i
          break
        end
        next true if yield real_party_index, screen
      when :summary
        screen.perform_action(:summary)
      end
      next false
    end
    # Fade back into battle screen
    pbFadeInAndShow(@sprites, visibleSprites)
  end

  #-----------------------------------------------------------------------------
  # Opens the Bag screen and chooses an item to use.
  #-----------------------------------------------------------------------------

  def pbItemMenu(idxBattler, _firstAction)
    # Fade out and hide all sprites
    visibleSprites = pbFadeOutAndHide(@sprites)
    # Set Bag starting positions
    oldLastPocket = $bag.last_viewed_pocket
    oldChoices    = $bag.last_pocket_selections.clone
    if @bagLastPocket
      $bag.last_viewed_pocket     = @bagLastPocket
      $bag.last_pocket_selections = @bagChoices
    else
      $bag.reset_last_selections
    end
    wasTargeting = false
    # Start Bag screen
    bag_screen = UI::Bag.new($bag, mode: :battle_choose_item)
    bag_screen.set_filter_proc(proc { |itm|
      use_type = GameData::Item.get(itm).battle_use
      next use_type && use_type > 0
    })
    party_battlers = []
    @battle.eachInTeamFromBattlerIndex(idxBattler) do |pkmn, i|
      party_battlers.push(@battle.pbFindBattler(i, idxBattler))
    end
    bag_screen.visuals.battlers = party_battlers
    bag_screen.show_and_hide do
      # Loop while in Bag screen
      loop do
        # Select an item
        item = bag_screen.choose_item_core
        break if !item
        # Choose a command for the selected item
        item = GameData::Item.get(item)
        itemName = item.name
        useType = item.battle_use
        cmdUse = -1
        commands = []
        commands[cmdUse = commands.length] = _INTL("Use") if useType && useType != 0
        commands[commands.length]          = _INTL("Cancel")
        command = bag_screen.show_menu(_INTL("{1} is selected.", itemName), commands)
        next unless cmdUse >= 0 && command == cmdUse   # Use
        # Use types:
        # 0 = not usable in battle
        # 1 = use on Pokémon (lots of items, Blue Flute)
        # 2 = use on Pokémon's move (Ethers)
        # 3 = use on battler (X items, Persim Berry, Red/Yellow Flutes)
        # 4 = use on opposing battler (Poké Balls)
        # 5 = use no target (Poké Doll, Guard Spec., Poké Flute, Launcher items)
        case useType
        when 1, 2, 3   # Use on Pokémon/Pokémon's move/battler
          # Auto-choose the Pokémon/battler whose action is being decided if they
          # are the only available Pokémon/battler to use the item on
          case useType
          when 1   # Use on Pokémon
            if @battle.pbTeamLengthFromBattlerIndex(idxBattler) == 1
              if yield item.id, useType, @battle.battlers[idxBattler].pokemonIndex, -1, bag_screen
                break
              else
                next
              end
            end
          when 3   # Use on battler
            if @battle.pbPlayerBattlerCount == 1
              if yield item.id, useType, @battle.battlers[idxBattler].pokemonIndex, -1, bag_screen
                break
              else
                next
              end
            end
          end
          # Fade out and hide Bag screen
          bag_sprites_status = pbFadeOutAndHide(bag_screen.sprites)
          # Get player's party
          party    = @battle.pbParty(idxBattler)
          partyPos = @battle.pbPartyOrder(idxBattler)
          partyStart, _partyEnd = @battle.pbTeamIndexRangeFromBattlerIndex(idxBattler)
          modParty = @battle.pbPlayerDisplayParty(idxBattler)
          # Start party screen
          party_idx = -1
          party_screen = UI::Party.new(modParty, mode: :battle_use_item)
          party_screen.choose_pokemon do |pkmn, party_index|
            party_idx = party_index
            next true if party_index < 0
            # Use the item on the selected Pokémon
            real_party_index = -1
            partyPos.each_with_index do |pos, i|
              next if pos != party_index + partyStart
              real_party_index = i
              break
            end
            next false if real_party_index < 0
            next false if !pkmn || pkmn.egg?
            move_index = -1
            if useType == 2   # Use on Pokémon's move
              move_index = party_screen.choose_move(pkmn, _INTL("Restore which move?"))
              next false if move_index < 0
            end
            if yield item.id, useType, real_party_index, move_index, party_screen
              bag_screen.silent_end_screen
              next true
            end
            party_idx = -1
            next false
          end
          break if party_idx >= 0   # Item was used; close the Bag screen
          # Cancelled choosing a Pokémon; show the Bag screen again
          pbFadeInAndShow(bag_screen.sprites, bag_sprites_status)
        when 4   # Use on opposing battler (Poké Balls)
          idxTarget = -1
          if @battle.pbOpposingBattlerCount(idxBattler, true) == 1
            @battle.allOtherSideBattlers(idxBattler, true).each { |b| idxTarget = b.index }
            break if yield item.id, useType, idxTarget, -1, bag_screen
          else
            wasTargeting = true
            # Fade out and hide Bag screen
            bag_sprites_status = pbFadeOutAndHide(bag_screen.sprites)
            # Fade in and show the battle screen, choosing a target
            tempVisibleSprites = visibleSprites.clone
            tempVisibleSprites["commandWindow"] = false
            tempVisibleSprites["targetWindow"]  = true
            idxTarget = pbChooseTarget(idxBattler, GameData::Target.get(:Foe), tempVisibleSprites)
            if idxTarget >= 0
              break if yield item.id, useType, idxTarget, -1, self
            end
            # Target invalid/cancelled choosing a target; show the Bag screen again
            wasTargeting = false
            pbFadeOutAndHide(@sprites)
            pbFadeInAndShow(bag_screen.sprites, bag_sprites_status)
          end
        when 5   # Use with no target
          break if yield item.id, useType, idxBattler, -1, bag_screen
        end
      end
      next true
    end
    @bagLastPocket = $bag.last_viewed_pocket
    @bagChoices    = $bag.last_pocket_selections.clone
    $bag.last_viewed_pocket     = oldLastPocket
    $bag.last_pocket_selections = oldChoices
    # Fade back into battle screen (if not already showing it)
    pbFadeInAndShow(@sprites, visibleSprites) if !wasTargeting
  end

  #-----------------------------------------------------------------------------
  # The player chooses a target battler for a move/item (non-single battles
  # only).
  #-----------------------------------------------------------------------------

  # Returns an array containing battler names to display when choosing a move's
  # target.
  # nil means can't select that position, "" means can select that position but
  # there is no battler there, otherwise is a battler's name.
  def pbCreateTargetTexts(idxBattler, target_data)
    texts = Array.new(@battle.battlers.length) do |i|
      next nil if !@battle.battlers[i]
      showName = false
      # NOTE: Targets listed here are ones with num_targets of 0, plus
      #       RandomNearFoe which should look like it targets the user. All
      #       other targets are handled by the "else" part.
      case target_data.id
      when :None, :User, :RandomNearFoe
        showName = (i == idxBattler)
      when :UserSide
        showName = !@battle.opposes?(i, idxBattler)
      when :FoeSide
        showName = @battle.opposes?(i, idxBattler)
      when :BothSides
        showName = true
      else
        showName = @battle.pbMoveCanTarget?(idxBattler, i, target_data)
      end
      next nil if !showName
      next "" if @battle.battlers[i].fainted? ||
                 @battle.battlers[i].effects[PBEffects::Commanding] >= 0
      next @battle.battlers[i].name
    end
    return texts
  end

  # Returns the initial position of the cursor when choosing a target for a move
  # in a non-single battle.
  def pbFirstTarget(idxBattler, target_data)
    case target_data.id
    when :NearAlly
      @battle.allSameSideBattlers(idxBattler).each do |b|
        next if b.index == idxBattler || !@battle.nearBattlers?(b, idxBattler)
        next if b.fainted?
        return b.index
      end
      @battle.allSameSideBattlers(idxBattler).each do |b|
        next if b.index == idxBattler || !@battle.nearBattlers?(b, idxBattler)
        return b.index
      end
    when :NearFoe, :NearOther
      indices = @battle.pbGetOpposingIndicesInOrder(idxBattler)
      indices.delete_if { |i| @battle.battlers[i]&.effects[PBEffects::Commanding] >= 0 }
      indices.each { |i| return i if @battle.nearBattlers?(i, idxBattler) && !@battle.battlers[i].fainted? }
      indices.each { |i| return i if @battle.nearBattlers?(i, idxBattler) }
    when :Foe, :Other
      indices = @battle.pbGetOpposingIndicesInOrder(idxBattler)
      indices.delete_if { |ind| @battle.battlers[ind]&.effects[PBEffects::Commanding] >= 0 }
      indices.each { |i| return i if !@battle.battlers[i].fainted? }
      return indices.first if !indices.empty?
    end
    return idxBattler   # Target the user initially
  end

  def pbChooseTarget(idxBattler, target_data, visibleSprites = nil)
    pbShowWindow(TARGET_BOX)
    cw = @sprites["targetWindow"]
    # Create an array of battler names (only valid targets are named)
    texts = pbCreateTargetTexts(idxBattler, target_data)
    # Determine mode based on target_data
    mode = (target_data.num_targets == 1) ? 0 : 1
    cw.set_texts_and_mode(texts, mode)
    cw.index = pbFirstTarget(idxBattler, target_data)
    pbSelectBattler((mode == 0) ? cw.index : texts, 2)   # Select initial battler/data box
    pbFadeInAndShow(@sprites, visibleSprites) if visibleSprites
    cw.active = true
    ret = -1
    loop do
      old_index = cw.index
      pbUpdate(cw)
      pbSelectBattler(cw.index, 2) if cw.index != old_index   # Select the new battler/data box
      if Input.trigger?(Input::USE)   # Confirm
        ret = cw.index
        pbPlayDecisionSE
        break
      elsif Input.trigger?(Input::BACK)   # Cancel
        ret = -1
        pbPlayCancelSE
        break
      end
    end
    pbSelectBattler(-1)   # Deselect all battlers/data boxes
    cw.active = false
    return ret
  end

  #-----------------------------------------------------------------------------
  # Opens a Pokémon's summary screen to try to learn a new move.
  #-----------------------------------------------------------------------------

  # Called whenever a Pokémon should forget a move. It should return -1 if the
  # selection is canceled, or 0 to 3 to indicate the move to forget. It should
  # not allow HM moves to be forgotten.
  def pbForgetMove(pkmn, moveToLearn)
    ret = -1
    pbFadeOutIn do
      screen = UI::PokemonSummary.new([pkmn], 0, mode: :choose_move, new_move: moveToLearn)
      ret = screen.choose_move
    end
    return ret
  end

  #-----------------------------------------------------------------------------
  # Opens the nicknaming screen for a newly caught Pokémon.
  #-----------------------------------------------------------------------------

  def pbNameEntry(helpText, pkmn)
    return pbEnterPokemonName(helpText, 0, Pokemon::MAX_NAME_SIZE, "", pkmn)
  end

  #-----------------------------------------------------------------------------
  # Shows the Pokédex entry screen for a newly caught Pokémon.
  #-----------------------------------------------------------------------------

  def pbShowPokedex(species)
    pbShowPokedexEntry(species)
  end
end
