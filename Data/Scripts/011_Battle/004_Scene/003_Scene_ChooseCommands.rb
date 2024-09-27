#===============================================================================
#
#===============================================================================
class Battle::Scene
  #-----------------------------------------------------------------------------
  # The player chooses a main command for a Pokémon.
  # Return values: -1=Cancel, 0=Fight, 1=Bag, 2=Pokémon, 3=Run, 4=Call
  #-----------------------------------------------------------------------------

  def pbCommandMenu(idxBattler, firstAction)
    shadowTrainer = (GameData::Type.exists?(:SHADOW) && @battle.trainerBattle?)
    cmds = [
      _INTL("What will\n{1} do?", @battle.battlers[idxBattler].name),
      _INTL("Fight"),
      _INTL("Bag"),
      _INTL("Pokémon"),
      (shadowTrainer) ? _INTL("Call") : (firstAction) ? _INTL("Run") : _INTL("Cancel")
    ]
    ret = pbCommandMenuEx(idxBattler, cmds, (shadowTrainer) ? 2 : (firstAction) ? 0 : 1)
    ret = 4 if ret == 3 && shadowTrainer   # Convert "Run" to "Call"
    ret = -1 if ret == 3 && !firstAction   # Convert "Run" to "Cancel"
    return ret
  end

  # Mode: 0 = regular battle with "Run" (first choosable action in the round only)
  #       1 = regular battle with "Cancel"
  #       2 = regular battle with "Call" (for Shadow Pokémon battles)
  #       3 = Safari Zone
  #       4 = Bug-Catching Contest
  def pbCommandMenuEx(idxBattler, texts, mode = 0)
    pbShowWindow(COMMAND_BOX)
    cw = @sprites["commandWindow"]
    cw.setTexts(texts)
    cw.setIndexAndMode(@lastCmd[idxBattler], mode)
    pbSelectBattler(idxBattler)
    ret = -1
    loop do
      oldIndex = cw.index
      pbUpdate(cw)
      # Update selected command
      if Input.trigger?(Input::LEFT)
        cw.index -= 1 if (cw.index & 1) == 1
      elsif Input.trigger?(Input::RIGHT)
        cw.index += 1 if (cw.index & 1) == 0
      elsif Input.trigger?(Input::UP)
        cw.index -= 2 if (cw.index & 2) == 2
      elsif Input.trigger?(Input::DOWN)
        cw.index += 2 if (cw.index & 2) == 0
      end
      pbPlayCursorSE if cw.index != oldIndex
      # Actions
      if Input.trigger?(Input::USE)                 # Confirm choice
        pbPlayDecisionSE
        ret = cw.index
        @lastCmd[idxBattler] = ret
        break
      elsif Input.trigger?(Input::BACK) && mode == 1   # Cancel
        pbPlayCancelSE
        break
      elsif Input.trigger?(Input::F9) && $DEBUG    # Debug menu
        pbPlayDecisionSE
        ret = -2
        break
      end
    end
    return ret
  end

  #-----------------------------------------------------------------------------
  # The player chooses a move for a Pokémon to use.
  #-----------------------------------------------------------------------------

  def pbFightMenu(idxBattler, megaEvoPossible = false)
    battler = @battle.battlers[idxBattler]
    cw = @sprites["fightWindow"]
    cw.battler = battler
    moveIndex = 0
    if battler.moves[@lastMove[idxBattler]]&.id
      moveIndex = @lastMove[idxBattler]
    end
    cw.shiftMode = (@battle.pbCanShift?(idxBattler)) ? 1 : 0
    cw.setIndexAndMode(moveIndex, (megaEvoPossible) ? 1 : 0)
    needFullRefresh = true
    needRefresh = false
    loop do
      # Refresh view if necessary
      if needFullRefresh
        pbShowWindow(FIGHT_BOX)
        pbSelectBattler(idxBattler)
        needFullRefresh = false
      end
      if needRefresh
        if megaEvoPossible
          newMode = (@battle.pbRegisteredMegaEvolution?(idxBattler)) ? 2 : 1
          cw.mode = newMode if newMode != cw.mode
        end
        needRefresh = false
      end
      oldIndex = cw.index
      # General update
      pbUpdate(cw)
      # Update selected command
      if Input.trigger?(Input::LEFT)
        cw.index -= 1 if (cw.index & 1) == 1
      elsif Input.trigger?(Input::RIGHT)
        cw.index += 1 if battler.moves[cw.index + 1]&.id && (cw.index & 1) == 0
      elsif Input.trigger?(Input::UP)
        cw.index -= 2 if (cw.index & 2) == 2
      elsif Input.trigger?(Input::DOWN)
        cw.index += 2 if battler.moves[cw.index + 2]&.id && (cw.index & 2) == 0
      end
      pbPlayCursorSE if cw.index != oldIndex
      # Actions
      if Input.trigger?(Input::USE)      # Confirm choice
        pbPlayDecisionSE
        break if yield cw.index
        needFullRefresh = true
        needRefresh = true
      elsif Input.trigger?(Input::BACK)   # Cancel fight menu
        pbPlayCancelSE
        break if yield -1
        needRefresh = true
      elsif Input.trigger?(Input::ACTION)   # Toggle Mega Evolution
        if megaEvoPossible
          pbPlayDecisionSE
          break if yield -2
          needRefresh = true
        end
      elsif Input.trigger?(Input::SPECIAL)   # Shift
        if cw.shiftMode > 0
          pbPlayDecisionSE
          break if yield -3
          needRefresh = true
        end
      end
    end
    @lastMove[idxBattler] = cw.index
  end

  #-----------------------------------------------------------------------------
  # Opens the party screen to choose a Pokémon to switch in (or just view its
  # summary screens).
  # mode: 0=Pokémon command, 1=choose a Pokémon to send to the Boxes, 2=view
  #       summaries only
  #-----------------------------------------------------------------------------

  def pbPartyScreen(idxBattler, canCancel = false, mode = 0)
    # Fade out and hide all sprites
    visibleSprites = pbFadeOutAndHide(@sprites)
    # Get player's party
    partyPos = @battle.pbPartyOrder(idxBattler)
    partyStart, _partyEnd = @battle.pbTeamIndexRangeFromBattlerIndex(idxBattler)
    modParty = @battle.pbPlayerDisplayParty(idxBattler)
    # Start party screen
    party_mode = (mode == 1) ? :battle_choose_to_box : :battle_choose_pokemon
    screen = UI::Party.new(modParty, mode: party_mode)
    screen.choose_pokemon do |pkmn, party_index|
      next canCancel if party_index < 0
      # Choose a command for the selected Pokémon
      commands = {}
      commands[:switch_in]     = _INTL("Switch In") if mode == 0 && pkmn.able? &&
                                                       (@battle.canSwitch || !canCancel)
      commands[:send_to_boxes] = _INTL("Send to Boxes") if mode == 1
      commands[:summary]       = _INTL("Summary")
      commands[:cancel]        = _INTL("Cancel")
      choice = screen.show_menu(_INTL("Do what with {1}?", pkmn.name), commands)
      next canCancel if choice.nil?
      case choice
      when :switch_in, :send_to_boxes
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
    bag_screen = UI::Bag.new($bag, mode: :choose_item_in_battle)
    bag_screen.set_filter_proc(proc { |itm|
      use_type = GameData::Item.get(itm).battle_use
      next use_type && use_type > 0
    })
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
          if @battle.pbOpposingBattlerCount(idxBattler) == 1
            @battle.allOtherSideBattlers(idxBattler).each { |b| idxTarget = b.index }
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
      next (@battle.battlers[i].fainted?) ? "" : @battle.battlers[i].name
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
      indices.each { |i| return i if @battle.nearBattlers?(i, idxBattler) && !@battle.battlers[i].fainted? }
      indices.each { |i| return i if @battle.nearBattlers?(i, idxBattler) }
    when :Foe, :Other
      indices = @battle.pbGetOpposingIndicesInOrder(idxBattler)
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
    cw.setDetails(texts, mode)
    cw.index = pbFirstTarget(idxBattler, target_data)
    pbSelectBattler((mode == 0) ? cw.index : texts, 2)   # Select initial battler/data box
    pbFadeInAndShow(@sprites, visibleSprites) if visibleSprites
    ret = -1
    loop do
      oldIndex = cw.index
      pbUpdate(cw)
      # Update selected command
      if mode == 0   # Choosing just one target, can change index
        if Input.trigger?(Input::LEFT) || Input.trigger?(Input::RIGHT)
          inc = (cw.index.even?) ? -2 : 2
          inc *= -1 if Input.trigger?(Input::RIGHT)
          indexLength = @battle.sideSizes[cw.index % 2] * 2
          newIndex = cw.index
          loop do
            newIndex += inc
            break if newIndex < 0 || newIndex >= indexLength
            next if texts[newIndex].nil?
            cw.index = newIndex
            break
          end
        elsif (Input.trigger?(Input::UP) && cw.index.even?) ||
              (Input.trigger?(Input::DOWN) && cw.index.odd?)
          tryIndex = @battle.pbGetOpposingIndicesInOrder(cw.index)
          tryIndex.each do |idxBattlerTry|
            next if texts[idxBattlerTry].nil?
            cw.index = idxBattlerTry
            break
          end
        end
        if cw.index != oldIndex
          pbPlayCursorSE
          pbSelectBattler(cw.index, 2)   # Select the new battler/data box
        end
      end
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
    pbFadeOutIn do
      scene = PokemonPokedexInfo_Scene.new
      screen = PokemonPokedexInfoScreen.new(scene)
      screen.pbDexEntry(species)
    end
  end
end
