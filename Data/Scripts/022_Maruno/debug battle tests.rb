# TODO: Better randomisation of moves, including tracking of how many times each
#       function code has been tested (note that some Pokémon may not be used in
#       battle, so their moves won't be score).
# TODO: Add held items.

AI_MOVE_TESTING_THRESHOLD = 100

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
    all_moves.reject! { |m| $tested_moves[m] && $tested_moves[m] > AI_MOVE_TESTING_THRESHOLD }
    if all_moves.length == 0
      all_moves = GameData::Move.keys
      all_moves.reject! { |m| $tested_moves[m] && $tested_moves[m] > AI_MOVE_TESTING_THRESHOLD }
    end
    if all_moves.length == 0
      echoln "All moves have been tested at least #{AI_MOVE_TESTING_THRESHOLD} times!"
    end
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
  mar_load_tested_moves_record

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

  mar_save_tested_moves_record
end

def mar_load_tested_moves_record
  return if $tested_moves
  pbRgssOpen("tested_moves.dat", "rb") { |f| $tested_moves = Marshal.load(f) }
end

def mar_save_tested_moves_record
  File.open("tested_moves.dat", "wb") { |f| Marshal.dump($tested_moves || {}, f) }
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

MenuHandlers.add(:debug_menu, :load_tested_moves, {
  "name"        => "Load tested moves",
  "parent"      => :main,
  "description" => "Load tested moves",
  "always_show" => false,
  "effect"      => proc {
    mar_load_tested_moves_record
  }
})

MenuHandlers.add(:debug_menu, :review_tested_moves, {
  "name"        => "Review tested moves",
  "parent"      => :main,
  "description" => "List all tested moves and how much they have been tested.",
  "always_show" => false,
  "effect"      => proc {
    mar_save_tested_moves_record
    thresholded_moves = []
    ($tested_moves || {}).each_pair do |move, count|
      next if !count || count < AI_MOVE_TESTING_THRESHOLD
      thresholded_moves.push([move, count])
    end
    thresholded_moves.sort! { |a, b| a[0].to_s <=> b[0].to_s }
    remaining_moves = GameData::Move.keys.clone
    thresholded_moves.each { |m| remaining_moves.delete(m[0]) }
    remaining_moves.sort! { |a, b| a.to_s <=> b.to_s }

    File.open("tested moves summary.txt", "wb") do |f|
      f.write(0xEF.chr)
      f.write(0xBB.chr)
      f.write(0xBF.chr)
      f.write("================================================\r\n")
      f.write("Met threshold of #{AI_MOVE_TESTING_THRESHOLD}: #{thresholded_moves.length}\r\n")
      f.write("================================================\r\n")
      thresholded_moves.each do |m|
        f.write("#{m[0]} = #{m[1]}\r\n")
      end
      f.write("\r\n")
      f.write("\r\n")
      f.write("\r\n")
      f.write("================================================\r\n")
      f.write("Remaining moves: #{remaining_moves.length}\r\n")
      f.write("================================================\r\n")
      remaining_moves.each do |m|
        if $tested_moves && $tested_moves[m]
          f.write("#{m} = #{$tested_moves[m]}\r\n")
        else
          f.write("#{m}\r\n")
        end
      end
    end

    echoln "Done."
  }
})
