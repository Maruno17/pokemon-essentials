# TODO: Better randomisation of moves, including tracking of how many times each
#       function code has been tested (note that some Pokémon may not be used in
#       battle, so their moves won't be score).
# TODO: Add held items.

#===============================================================================
#
#===============================================================================
def debug_set_up_trainer
  # Values to return
  trainer_array = []
  foe_items     = []   # Items can't be used except in internal battles
  pokemon_array = []
  party_starts  = [0]

  # Choose random trainer type and trainer name
  trainer_type = :CHAMPION   # GameData::TrainerType.keys.sample
  trainer_name = ["Alpha", "Bravo", "Charlie", "Delta", "Echo",
                  "Foxtrot", "Golf", "Hotel", "India", "Juliette",
                  "Kilo", "Lima", "Mike", "November", "Oscar",
                  "Papa", "Quebec", "Romeo", "Sierra", "Tango",
                  "Uniform", "Victor", "Whiskey", "X-ray", "Yankee", "Zulu"].sample

  # Generate trainer
  trainer = NPCTrainer.new(trainer_name, trainer_type)
  trainer.id        = $player.make_foreign_ID
  trainer.lose_text = "I lost."
  # [:MAXPOTION, :FULLHEAL, :MAXREVIVE, :REVIVE].each do |item|
  #   trainer.items.push(item)
  # end
  # foe_items.push(trainer.items)
  trainer_array.push(trainer)

  # Generate party
  valid_species = []
  GameData::Species.each_species { |sp| valid_species.push(sp.species) }
  Settings::MAX_PARTY_SIZE.times do |i|
    this_species = valid_species.sample
    this_level = 100   # rand(1, Settings::MAXIMUM_LEVEL)
    pkmn = Pokemon.new(this_species, this_level, trainer, false)
    all_moves = pkmn.getMoveList.map { |m| m[1] }
    all_moves.uniq!
    moves = all_moves.sample(4)
    moves.each { |m| pkmn.learn_move(m) }
    trainer.party.push(pkmn)
    pokemon_array.push(pkmn)
  end

  # Return values
  return trainer_array, foe_items, pokemon_array, party_starts
end

def debug_test_auto_battle(logging = false, console_messages = true)
  old_internal = $INTERNAL
  $INTERNAL = logging
  if console_messages
    echoln "Start of testing auto-battle."
    echoln "" if !$INTERNAL
  end
  PBDebug.log("")
  PBDebug.log("================================================================")
  PBDebug.log("")
  # Generate information for the foes
  foe_trainers, foe_items, foe_party, foe_party_starts = debug_set_up_trainer
  # Generate information for the player and partner trainer(s)
  player_trainers, ally_items, player_party, player_party_starts = debug_set_up_trainer
  # Log the combatants
  echo_participant = lambda do |trainer, party, index|
    trainer_txt = "[Trainer #{index}] #{trainer.full_name} [skill: #{trainer.skill_level}]"
    ($INTERNAL) ? PBDebug.log_header(trainer_txt) : echoln(trainer_txt)
    party.each do |pkmn|
      pkmn_txt = "#{pkmn.name}, Lv.#{pkmn.level}"
      pkmn_txt += " [Ability: #{pkmn.ability&.name || "---"}]"
      pkmn_txt += " [Item: #{pkmn.item&.name || "---"}]"
      ($INTERNAL) ? PBDebug.log(pkmn_txt) : echoln(pkmn_txt)
      moves_msg = "    Moves: "
      pkmn.moves.each_with_index do |move, i|
        moves_msg += ", " if i > 0
        moves_msg += move.name
      end
      ($INTERNAL) ? PBDebug.log(moves_msg) : echoln(moves_msg)
    end
  end
  echo_participant.call(player_trainers[0], player_party, 1) if console_messages
  PBDebug.log("")
  if console_messages
    echoln "" if !$INTERNAL
    echo_participant.call(foe_trainers[0], foe_party, 2)
    echoln "" if !$INTERNAL
  end
  # Create the battle scene (the visual side of it)
  scene = Battle::DebugSceneNoVisuals.new(logging)
  # Create the battle class (the mechanics side of it)
  battle = Battle.new(scene, player_party, foe_party, player_trainers, foe_trainers)
  battle.party1starts   = player_party_starts
  battle.party2starts   = foe_party_starts
  battle.ally_items     = ally_items
  battle.items          = foe_items

  battle.debug          = true
  battle.internalBattle = false
  battle.controlPlayer  = true
  # Set various other properties in the battle class
  BattleCreationHelperMethods.prepare_battle(battle)
  # Perform the battle itself
  outcome = battle.pbStartBattle
  # End
  if console_messages
    text = ["Undecided",
            "Trainer 1 #{player_trainers[0].name} won",
            "Trainer 2 #{foe_trainers[0].name} won",
            "Ran/forfeited",
            "Wild Pokémon caught",
            "Draw"][outcome]
    echoln sprintf("%s after %d rounds", text, battle.turnCount + 1)
    echoln ""
  end
  $INTERNAL = old_internal
end

#===============================================================================
# Add to Debug menu.
#===============================================================================
MenuHandlers.add(:debug_menu, :test_auto_battle, {
  "name"        => "Test Auto Battle",
  "parent"      => :main,
  "description" => "Runs an AI-controlled battle with no visuals.",
  "always_show" => false,
  "effect"      => proc {
    debug_test_auto_battle
  }
})

MenuHandlers.add(:debug_menu, :test_auto_battle_logging, {
  "name"        => "Test Auto Battle with Logging",
  "parent"      => :main,
  "description" => "Runs an AI-controlled battle with no visuals. Logs messages.",
  "always_show" => false,
  "effect"      => proc {
    debug_test_auto_battle(true)
    pbMessage("Battle transcript was logged in Data/debuglog.txt.")
  }
})

MenuHandlers.add(:debug_menu, :bulk_test_auto_battle, {
  "name"        => "Bulk Test Auto Battle",
  "parent"      => :main,
  "description" => "Runs 50 AI-controlled battles with no visuals.",
  "always_show" => false,
  "effect"      => proc {
    echoln "Running 50 battles.."
    50.times do |i|
      echoln "#{i + 1}..."
      debug_test_auto_battle(false, false)
    end
    echoln "Done!"
  }
})
