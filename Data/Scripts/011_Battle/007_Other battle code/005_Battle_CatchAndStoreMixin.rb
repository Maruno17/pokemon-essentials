#===============================================================================
#
#===============================================================================
module Battle::CatchAndStoreMixin
  #-----------------------------------------------------------------------------
  # Store caught Pokémon.
  #-----------------------------------------------------------------------------

  def pbStorePokemon(pkmn)
    # Nickname the Pokémon (unless it's a Shadow Pokémon)
    if !pkmn.shadowPokemon?
      if $PokemonSystem.givenicknames == 0 &&
         pbDisplayConfirm(_INTL("Would you like to give a nickname to {1}?", pkmn.name))
        nickname = @scene.pbNameEntry(_INTL("{1}'s nickname?", pkmn.speciesName), pkmn)
        pkmn.name = nickname
      end
    end
    # Store the Pokémon
    if pbPlayer.party_full? && (@sendToBoxes == 0 || @sendToBoxes == 2)   # Ask/must add to party
      cmds = [_INTL("Add to your party"),
              _INTL("Send to a Box"),
              _INTL("See {1}'s summary", pkmn.name),
              _INTL("Check party")]
      cmds.delete_at(1) if @sendToBoxes == 2   # Remove "Send to a Box" option
      loop do
        cmd = pbShowCommands(_INTL("Where do you want to send {1} to?", pkmn.name), cmds, 99)
        next if cmd == 99 && @sendToBoxes == 2   # Can't cancel if must add to party
        break if cmd == 99   # Cancelling = send to a Box
        cmd += 1 if cmd >= 1 && @sendToBoxes == 2
        case cmd
        when 0   # Add to your party
          can_store = false
          eachInTeam(0, 0) do |pkmn, i|
            can_store = true if !pkmn.cannot_store
            break if can_store
          end
          if !can_store
            pbDisplay(_INTL("You can't make room in your party for {1}!", pkmn.name))
            break
          end
          pbDisplay(_INTL("Choose a Pokémon in your party to send to your Boxes."))
          party_index = -1
          @scene.pbPartyScreen(0, (@sendToBoxes != 2), 1) do |idxParty, _party_screen|
            party_index = idxParty
            next true
          end
          next if party_index < 0   # Cancelled
          party_size = pbPlayer.party.length
          # Get chosen Pokémon and clear battle-related conditions
          send_pkmn = pbPlayer.party[party_index]
          @peer.pbOnLeavingBattle(self, send_pkmn, @usedInBattle[0][party_index], true)
          send_pkmn.statusCount = 0 if send_pkmn.status == :POISON   # Bad poison becomes regular
          send_pkmn.makeUnmega
          send_pkmn.makeUnprimal
          # Send chosen Pokémon to storage
          stored_box = @peer.pbStorePokemon(pbPlayer, send_pkmn)
          pbPlayer.party.delete_at(party_index)
          box_name = @peer.pbBoxName(stored_box)
          pbDisplayPaused(_INTL("{1} has been sent to Box \"{2}\".", send_pkmn.name, box_name))
          # Rearrange all remembered properties of party Pokémon
          (party_index...party_size).each do |idx|
            if idx < party_size - 1
              @usedInBattle[0][idx] = @usedInBattle[0][idx + 1]
              $game_temp.party_levels_before_battle[idx] = $game_temp.party_levels_before_battle[idx + 1]
            else
              @usedInBattle[0][idx] = nil
              $game_temp.party_levels_before_battle[idx] = nil
            end
          end
          break
        when 1   # Send to a Box
          break
        when 2   # See X's summary
          pbFadeOutIn do
            UI::PokemonSummary.new(pkmn, mode: :in_battle).main
          end
        when 3   # Check party
          @scene.pbPartyScreen(0, true, 2)
        end
      end
    end
    # Store as normal (add to party if there's space, or send to a Box if not)
    stored_box = @peer.pbStorePokemon(pbPlayer, pkmn)
    if stored_box < 0
      pbDisplayPaused(_INTL("{1} has been added to your party.", pkmn.name))
    else
      # Messages saying the Pokémon was stored in a PC box
      box_name = @peer.pbBoxName(stored_box)
      pbDisplayPaused(_INTL("{1} has been sent to Box \"{2}\"!", pkmn.name, box_name))
    end
  end

  # Register all caught Pokémon in the Pokédex, and store them.
  def pbRecordAndStoreCaughtPokemon
    @caughtPokemon.each do |pkmn|
      pbSetCaught(pkmn)
      pbSetSeen(pkmn)   # In case the form changed upon leaving battle
      # Record the Pokémon's species as owned in the Pokédex
      if !pbPlayer.owned?(pkmn.species)
        pbPlayer.pokedex.set_owned(pkmn.species)
        if $player.has_pokedex && $player.pokedex.species_in_unlocked_dex?(pkmn.species)
          pbDisplayPaused(_INTL("{1}'s data was added to the Pokédex.", pkmn.name))
          pbPlayer.pokedex.register_last_seen(pkmn)
          @scene.pbShowPokedex(pkmn.species)
        end
      end
      # Record a Shadow Pokémon's species as having been caught
      pbPlayer.pokedex.set_shadow_pokemon_owned(pkmn.species) if pkmn.shadowPokemon?
      # Store caught Pokémon
      pbStorePokemon(pkmn)
    end
    @caughtPokemon.clear
  end

  #-----------------------------------------------------------------------------
  # Throw a Poké Ball.
  #-----------------------------------------------------------------------------

  def pbThrowPokeBall(idxBattler, ball, catch_rate = nil, showPlayer = false)
    # Determine which Pokémon you're throwing the Poké Ball at
    battler = @battlers[idxBattler]
    battler = @battlers[idxBattler].pbDirectOpposing(true) if !battler.opposes?
    battler = battler.allAllies[0] if battler.fainted?
    pkmn = battler.pokemon
    # Throw message
    pbThrowPokeBallMessage(battler, ball)
    # Failure checks (Pokémon is fainted, or opposing trainer blocks the Poké
    # Ball)
    return if pbThrowPokeBallNegated?(battler, ball)
    # Calculate the number of shakes (4=capture)
    @criticalCapture = false
    num_shakes = pbCaptureCalc(pkmn, battler, catch_rate, ball)
    if num_shakes != 4
      @first_poke_ball = ball if !@poke_ball_failed   # For Ball Fetch
      @poke_ball_failed = true                        # For Ball Fetch
    end
    # Animation of Ball throw, absorb, shake and capture/burst out
    @scene.pbThrow(ball, num_shakes, @criticalCapture, battler.index, showPlayer)
    # Outcome
    pbThrowPokeBallOutcome(battler, pkmn, ball, num_shakes)
  end

  def pbThrowPokeBallMessage(battler, ball)
    return if battler.fainted?   # Messages are shown in def pbThrowPokeBallNegated? for this
    item_name = GameData::Item.get(ball).name
    if item_name.starts_with_vowel?
      pbDisplayBrief(_INTL("{1} threw an {2}!", pbPlayer.name, item_name))
    else
      pbDisplayBrief(_INTL("{1} threw a {2}!", pbPlayer.name, item_name))
    end
  end

  def pbThrowPokeBallNegated?(battler, ball)
    if battler.fainted?
      item_name = GameData::Item.get(ball).name
      PBDebug.log("[Threw Poké Ball] #{item_name}, failed due to no target")
      if item_name.starts_with_vowel?
        pbDisplay(_INTL("{1} threw an {2}!", pbPlayer.name, item_name))
      else
        pbDisplay(_INTL("{1} threw a {2}!", pbPlayer.name, item_name))
      end
      pbDisplay(_INTL("But there was no target..."))
      return true
    end
    if trainerBattle? && !(GameData::Item.get(ball).is_snag_ball? && battler.shadowPokemon?)
      item_name = GameData::Item.get(ball).name
      PBDebug.log("[Threw Poké Ball] #{item_name}, failed due to opposing trainer blocking")
      @scene.pbThrowAndDeflect(ball, 1)   # Animation
      pbDisplay(_INTL("The Trainer blocked your {1}! Don't be a thief!", item_name))
      return true
    end
    return false
  end

  #-----------------------------------------------------------------------------
  # Calculate how many shakes a thrown Poké Ball will make (4 = capture).
  #-----------------------------------------------------------------------------

  def pbCaptureCalc(pkmn, battler, base_catch_rate, ball)
    # Certain capture checks
    return 4 if $DEBUG && Input.press?(Input::CTRL)
    return 4 if Battle::PokeBallEffects.isUnconditional?(ball, self, battler)
    return 4 if @rules[:certain_capture]
    # Get a catch rate if one wasn't provided
    base_catch_rate = pkmn.species_data.catch_rate if !base_catch_rate
    # Modify catch_rate depending on the Poké Ball's effect
    if !pkmn.species_data.has_flag?("UltraBeast") || ball == :BEASTBALL
      base_catch_rate = Battle::PokeBallEffects.modifyCatchRate(ball, base_catch_rate, self, battler)
    else
      base_catch_rate = [base_catch_rate / 10.0, 1].max
    end
    # Modify catch_rate depending on HP
    mod_catch_rate = base_catch_rate * 4096
    mod_catch_rate *= ((3 * battler.totalhp) - (2 * battler.hp)) / (3 * battler.totalhp).to_f
    # Higher wild level penalty if the player can't make the Pokémon obey
    if Settings::CATCH_RATE_PENALTY_IF_POKEMON_WILL_NOT_OBEY &&
       pkmn.level > battler.pbMaxLevelBadgeObedience + 5
      badges_needed = battler.pbBadgesNeededToObey
      mod_catch_rate *= 0.8**badges_needed if badges_needed > 0
    end
    # Floor the mod_catch_rate
    mod_catch_rate = mod_catch_rate.floor
    mod_catch_rate = 1 if mod_catch_rate < 1
    # Status bonus
    if battler.status == :SLEEP || battler.status == :FROZEN
      mod_catch_rate *= 2.5
    elsif battler.status != :NONE
      mod_catch_rate *= 1.5
    end
    # Low wild level bonus (Gen 9's version)
    if Settings::CATCH_RATE_BONUS_FOR_LOW_LEVEL
      mod_catch_rate *= [(36 - (2 * pkmn.level)) / 10.0, 1].max
    end
    # Higher wild level penalty if the player doesn't have enough Gym Badges (Gen 8 only)
    if Settings::NUM_BADGES_TO_NOT_MAKE_HIGHER_LEVEL_CAPTURES_HARDER > $player.badge_count
      max_player_level = 0
      allSameSideBattlers(0, true).each { |b| max_player_level = b.level if b.level > max_player_level }
      mod_catch_rate /= 10.0 if pkmn.level > max_player_level
    end
    # Floor the mod_catch_rate
    mod_catch_rate = mod_catch_rate.floor
    mod_catch_rate = 1 if mod_catch_rate < 1
    # Definite capture, no need to perform randomness checks
    return 4 if mod_catch_rate >= 255 * 4096
    # Second half of the shakes calculation (from Gen 6)
    shake_chance = (65_536 * ((mod_catch_rate.to_f / (255 * 4096))**0.1875)).floor
    # Critical capture check
    if Settings::ENABLE_CRITICAL_CAPTURES
      dex_modifier = 0
      num_owned = $player.pokedex.owned_count
      if num_owned > 600
        dex_modifier = 5
      elsif num_owned > 450
        dex_modifier = 4
      elsif num_owned > 300
        dex_modifier = 3
      elsif num_owned > 150
        dex_modifier = 2
      elsif num_owned > 30
        dex_modifier = 1
      end
      dex_modifier *= 2 if $bag.has?(:CATCHINGCHARM)
      critical_chance = mod_catch_rate * dex_modifier / (12 * 4096)
      # Calculate the number of shakes
      if critical_chance > 0 && pbRandom(256) < critical_chance
        @criticalCapture = true
        return 4 if pbRandom(65_536) < shake_chance
        return 0
      end
    end
    # Calculate the number of shakes
    num_shakes = 0
    4.times do |i|
      break if num_shakes < i
      num_shakes += 1 if pbRandom(65_536) < shake_chance
    end
    return num_shakes
  end

  #-----------------------------------------------------------------------------
  # The outcome of the capture attempt (after the animation).
  #-----------------------------------------------------------------------------

  def pbThrowPokeBallOutcome(battler, pkmn, ball, num_shakes)
    # Succeeded
    if num_shakes == 4
      PBDebug.log("[Threw Poké Ball] #{GameData::Item.get(ball).name}, #{num_shakes} shakes (succeeded)")
      pbThrowPokeBallSuccess(battler, pkmn, ball)
      return
    end
    # Failed
    PBDebug.log("[Threw Poké Ball] #{GameData::Item.get(ball).name}, #{num_shakes} shakes (failed)")
    case num_shakes
    when 0 then pbDisplay(_INTL("Oh no! The Pokémon broke free!"))
    when 1 then pbDisplay(_INTL("Aww! It appeared to be caught!"))
    when 2 then pbDisplay(_INTL("Aargh! Almost had it!"))
    when 3 then pbDisplay(_INTL("Gah! It was so close, too!"))
    end
    Battle::PokeBallEffects.onFailCatch(ball, self, battler)
  end

  def pbThrowPokeBallSuccess(battler, pkmn, ball)
    pbDisplayBrief(_INTL("Gotcha! {1} was caught!", pkmn.name))
    @scene.pbThrowSuccess   # Play capture success jingle
    pbRemoveFromParty(battler.index, battler.pokemonIndex)
    # Gain Exp
    if Settings::GAIN_EXP_FOR_CAPTURE
      battler.captured = true
      pbGainExp
      battler.captured = false
    end
    battler.pbReset
    if pbAllFainted?(battler.index)
      @decision = (trainerBattle?) ? Battle::Outcome::WIN : Battle::Outcome::CATCH
    end
    # Modify the Pokémon's properties because of the capture
    if GameData::Item.get(ball).is_snag_ball?
      pkmn.owner = Pokemon::Owner.new_from_trainer(pbPlayer)
    end
    Battle::PokeBallEffects.onCatch(ball, self, pkmn)
    pkmn.poke_ball = ball
    pkmn.makeUnmega if pkmn.mega?
    pkmn.makeUnprimal
    pkmn.update_shadow_moves if pkmn.shadowPokemon?
    pkmn.record_first_moves
    # Reset form
    pkmn.forced_form = nil if MultipleForms.hasFunction?(pkmn.species, "getForm")
    @peer.pbOnLeavingBattle(self, pkmn, true, true)
    # Make the Poké Ball and data box disappear
    @scene.pbHideCaptureBall(battler.index)
    # Save the Pokémon for storage at the end of battle
    @caughtPokemon.push(pkmn)
  end
end

#===============================================================================
#
#===============================================================================
class Battle
  include Battle::CatchAndStoreMixin
end
