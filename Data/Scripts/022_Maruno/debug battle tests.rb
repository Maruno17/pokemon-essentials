# TODO: Be much more relevant with the choosing of held items. For example,
#       only give a weather-boosting item to a Pokémon that can create the
#       corresponding weather.
# TODO: Add alternate forms, which will give access to more abilities. Note that
#       some alternate forms require fusion or specific held items or other
#       things.

AI_MOVE_TESTING_THRESHOLD    = 500
AI_ABILITY_TESTING_THRESHOLD = 100
AI_ITEM_TESTING_THRESHOLD    = 100

#===============================================================================
#
#===============================================================================
# There are some duplicate effects in here (e.g. Power Weight/Bracer/etc.), but
# whatever.
ITEMS_WITH_HELD_EFFECTS = [
  :AIRBALLOON, :BRIGHTPOWDER, :EVIOLITE, :FLOATSTONE, :DESTINYKNOT,
  :ROCKYHELMET, :ASSAULTVEST, :SAFETYGOGGLES, :PROTECTIVEPADS, :HEAVYDUTYBOOTS,
  :UTILITYUMBRELLA, :EJECTBUTTON, :EJECTPACK, :REDCARD, :SHEDSHELL, :CHOICEBAND,
  :CHOICESPECS, :CHOICESCARF, :HEATROCK, :DAMPROCK, :SMOOTHROCK, :ICYROCK,
  :TERRAINEXTENDER, :LIGHTCLAY, :GRIPCLAW, :BINDINGBAND, :BIGROOT, :BLACKSLUDGE,
  :LEFTOVERS, :SHELLBELL, :MENTALHERB, :WHITEHERB, :POWERHERB, :ABSORBBULB,
  :CELLBATTERY, :LUMINOUSMOSS, :SNOWBALL, :WEAKNESSPOLICY, :BLUNDERPOLICY,
  :THROATSPRAY, :ADRENALINEORB, :ROOMSERVICE, :ELECTRICSEED, :GRASSYSEED,
  :MISTYSEED, :PSYCHICSEED, :LIFEORB, :EXPERTBELT, :METRONOME, :MUSCLEBAND,
  :WISEGLASSES, :RAZORCLAW, :SCOPELENS, :WIDELENS, :ZOOMLENS, :KINGSROCK,
  :RAZORFANG, :LAGGINGTAIL, :QUICKCLAW, :FOCUSBAND, :FOCUSSASH, :FLAMEORB,
  :TOXICORB, :STICKYBARB, :IRONBALL, :RINGTARGET, :MACHOBRACE, :POWERWEIGHT,
  :POWERBRACER, :POWERBELT, :POWERLENS, :POWERBAND, :POWERANKLET, :LAXINCENSE,
  :FULLINCENSE, :SEAINCENSE, :WAVEINCENSE, :ROSEINCENSE, :ODDINCENSE,
  :ROCKINCENSE, :CHARCOAL, :MYSTICWATER, :MAGNET, :MIRACLESEED, :NEVERMELTICE,
  :BLACKBELT, :POISONBARB, :SOFTSAND, :SHARPBEAK, :TWISTEDSPOON, :SILVERPOWDER,
  :HARDSTONE, :SPELLTAG, :DRAGONFANG, :BLACKGLASSES, :METALCOAT, :SILKSCARF,
  :FIREGEM, :WATERGEM, :ELECTRICGEM, :GRASSGEM, :ICEGEM, :FIGHTINGGEM,
  :POISONGEM, :GROUNDGEM, :FLYINGGEM, :PSYCHICGEM, :BUGGEM, :ROCKGEM, :GHOSTGEM,
  :DRAGONGEM, :DARKGEM, :STEELGEM, :FAIRYGEM, :NORMALGEM, :CHERIBERRY,
  :CHESTOBERRY, :PECHABERRY, :RAWSTBERRY, :ASPEARBERRY, :LEPPABERRY, :ORANBERRY,
  :PERSIMBERRY, :LUMBERRY, :SITRUSBERRY, :FIGYBERRY, :WIKIBERRY, :MAGOBERRY,
  :AGUAVBERRY, :IAPAPABERRY, :OCCABERRY, :PASSHOBERRY, :WACANBERRY, :RINDOBERRY,
  :YACHEBERRY, :CHOPLEBERRY, :KEBIABERRY, :SHUCABERRY, :COBABERRY, :PAYAPABERRY,
  :TANGABERRY, :CHARTIBERRY, :KASIBBERRY, :HABANBERRY, :COLBURBERRY,
  :BABIRIBERRY, :ROSELIBERRY, :CHILANBERRY, :LIECHIBERRY, :GANLONBERRY,
  :SALACBERRY, :PETAYABERRY, :APICOTBERRY, :LANSATBERRY, :STARFBERRY,
  :ENIGMABERRY, :MICLEBERRY, :CUSTAPBERRY, :JABOCABERRY, :ROWAPBERRY, :KEEBERRY,
  :MARANGABERRY
]
# These items have no effect if held by other species. Includes the Plates
# because other items also have the type-boosting effect and we don't need to
# test that effect of Plates.
SIGNATURE_ITEMS = {
  :PIKACHU   => :LIGHTBALL,
  :CHANSEY   => :LUCKYPUNCH,
  :DITTO     => [:METALPOWDER, :QUICKPOWDER],
  :CUBONE    => :THICKCLUB,
  :MAROWAK   => :THICKCLUB,
  :FARFETCHD => :LEEK,
  :SIRFETCHD => :LEEK,
  :LATIOS    => :SOULDEW,
  :LATIAS    => :SOULDEW,
  :CLAMPERL  => [:DEEPSEATOOTH, :DEEPSEASCALE],
  :DIALGA    => :ADAMANTORB,
  :PALKIA    => :LUSTROUSORB,
  :ARCEUS    => [:FLAMEPLATE, :SPLASHPLATE, :ZAPPLATE, :MEADOWPLATE,
                 :ICICLEPLATE, :FISTPLATE, :TOXICPLATE, :EARTHPLATE, :SKYPLATE,
                 :MINDPLATE, :INSECTPLATE, :STONEPLATE, :SPOOKYPLATE,
                 :DRACOPLATE, :DREADPLATE, :IRONPLATE, :PIXIEPLATE],
  :GENESECT  => [:DOUSEDRIVE, :SHOCKDRIVE, :BURNDRIVE, :CHILLDRIVE],
  :SILVALLY  => [:FIREMEMORY, :WATERMEMORY, :ELECTRICMEMORY, :GRASSMEMORY,
                 :ICEMEMORY, :FIGHTINGMEMORY, :POISONMEMORY, :GROUNDMEMORY,
                 :FLYINGMEMORY, :PSYCHICMEMORY, :BUGMEMORY, :ROCKMEMORY,
                 :GHOSTMEMORY, :DRAGONMEMORY, :DARKMEMORY, :STEELMEMORY,
                 :FAIRYMEMORY],
  :GROUDON   => :REDORB,        # Form-changing item
  :KYOGRE    => :BLUEORB,       # Form-changing item
  :GIRATINA  => :GRISEOUSORB,   # Form-changing item
  :ZACIAN    => :RUSTEDSWORD,   # Form-changing item
  :ZAMAZENTA => :RUSTEDSHIELD   # Form-changing item
}
MEGA_STONES = [
  :VENUSAURITE, :CHARIZARDITEX, :CHARIZARDITEY, :BLASTOISINITE, :BEEDRILLITE,
  :PIDGEOTITE, :ALAKAZITE, :SLOWBRONITE, :GENGARITE, :KANGASKHANITE, :PINSIRITE,
  :GYARADOSITE, :AERODACTYLITE, :MEWTWONITEX, :MEWTWONITEY, :AMPHAROSITE,
  :STEELIXITE, :SCIZORITE, :HERACRONITE, :HOUNDOOMINITE, :TYRANITARITE,
  :SCEPTILITE, :BLAZIKENITE, :SWAMPERTITE, :GARDEVOIRITE, :SABLENITE, :MAWILITE,
  :AGGRONITE, :MEDICHAMITE, :MANECTITE, :SHARPEDONITE, :CAMERUPTITE,
  :ALTARIANITE, :BANETTITE, :ABSOLITE, :GLALITITE, :SALAMENCITE, :METAGROSSITE,
  :LATIASITE, :LATIOSITE, :LOPUNNITE, :GARCHOMPITE, :LUCARIONITE, :ABOMASITE,
  :GALLADITE, :AUDINITE, :DIANCITE
]

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
  trainer.items.push(:MEGARING)
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
    # Generate moveset for pkmn (from level-up moves first, then from tutor
    # moves + egg moves, then from all moves)
    all_moves = pkmn.getMoveList.map { |m| m[1] }
    all_moves.uniq!
    all_moves.reject! { |m| $tested_moves[m] && $tested_moves[m] > AI_MOVE_TESTING_THRESHOLD }
    if all_moves.length == 0
      all_moves = pkmn.species_data.tutor_moves.clone + pkmn.species_data.get_egg_moves.clone
      all_moves.reject! { |m| $tested_moves[m] && $tested_moves[m] > AI_MOVE_TESTING_THRESHOLD }
      if all_moves.length == 0
        all_moves = GameData::Move.keys.clone
        all_moves.reject! { |m| $tested_moves[m] && $tested_moves[m] > AI_MOVE_TESTING_THRESHOLD }
      end
    end
    if all_moves.length == 0 && !$shown_all_moves_tested_message
      echoln "All moves have been tested at least #{AI_MOVE_TESTING_THRESHOLD} times!"
      $shown_all_moves_tested_message = true
    end
    moves = all_moves.sample(4)
    moves.each { |m| pkmn.learn_move(m) }
    # Generate held item for pkmn (compatible Mega Stone first, then compatible
    # signature item, then any item with a held effect)
    all_items = []   # Find all compatible Mega Stones
    GameData::Species.each do |sp|
      next if sp.species != pkmn.species || sp.unmega_form != pkmn.form
      all_items.push(sp.mega_stone) if sp.mega_stone
    end
    all_items.reject! { |i| $tested_items[i] && $tested_items[i] > AI_ITEM_TESTING_THRESHOLD }
    if all_items.length > 0 && rand(100) < 50
      pkmn.item = all_items.sample
    elsif SIGNATURE_ITEMS.keys.include?(pkmn.species) && rand(100) < 75
      all_items = SIGNATURE_ITEMS[pkmn.species].clone
      if all_items.is_a?(Array)
        all_items.reject! { |i| $tested_items[i] && $tested_items[i] > AI_ITEM_TESTING_THRESHOLD }
        pkmn.item = all_items.sample if all_items.length > 0
      else
        pkmn.item = all_items if !$tested_items[all_items] || $tested_items[all_items] <= AI_ITEM_TESTING_THRESHOLD
      end
    end
    if !pkmn.hasItem? && rand(100) < 75
      all_items = ITEMS_WITH_HELD_EFFECTS.clone
      all_items.reject! { |i| $tested_items[i] && $tested_items[i] > AI_ITEM_TESTING_THRESHOLD }
      all_items = ITEMS_WITH_HELD_EFFECTS.clone if all_items.length == 0
      pkmn.item = all_items.sample
    end
    # Generate ability for pkmn (any available to that species/form)
    abil = pkmn.ability_id
    if $tested_abilities[abil] && $tested_abilities[abil] > AI_ABILITY_TESTING_THRESHOLD
      abils = pkmn.getAbilityList
      abils.reject! { |a| $tested_abilities[a[0]] && $tested_abilities[a[0]] > AI_ABILITY_TESTING_THRESHOLD }
      pkmn.ability_index = abils.sample[1] if abils.length > 0
    end
    trainer.party.push(pkmn)
    pokemon_array.push(pkmn)
  end

  # Return values
  return trainer_array, foe_items, pokemon_array, party_starts
end

#===============================================================================
#
#===============================================================================
def debug_test_auto_battle(logging = false, console_messages = true)
  mar_load_tested_data_record

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

  mar_save_tested_data_record
end

def mar_load_tested_data_record
  if !$tested_moves
    pbRgssOpen("tested_moves.dat", "rb") { |f| $tested_moves = Marshal.load(f) }
  end
  if !$tested_abilities
    pbRgssOpen("tested_abilities.dat", "rb") { |f| $tested_abilities = Marshal.load(f) }
  end
  if !$tested_items
    pbRgssOpen("tested_items.dat", "rb") { |f| $tested_items = Marshal.load(f) }
  end
end

def mar_save_tested_data_record
  $tested_moves ||= {}
  $tested_abilities ||= {}
  $tested_items ||= {}
  File.open("tested_moves.dat", "wb") { |f| Marshal.dump($tested_moves, f) }
  File.open("tested_abilities.dat", "wb") { |f| Marshal.dump($tested_abilities, f) }
  File.open("tested_items.dat", "wb") { |f| Marshal.dump($tested_items, f) }
end

#===============================================================================
# Add to Debug menu.
#===============================================================================
MenuHandlers.add(:debug_menu, :ai_testing_menu, {
  "name"        => "AI Testing...",
  "parent"      => :main,
  "description" => "Functions that help to test the AI.",
  "always_show" => false
})

MenuHandlers.add(:debug_menu, :generate_test_data, {
  "name"        => "Generate new test data",
  "parent"      => :ai_testing_menu,
  "description" => "Save current tested moves/abilities/items data. If none, generates it from scratch.",
  "always_show" => false,
  "effect"      => proc {
    mar_save_tested_data_record
  }
})

MenuHandlers.add(:debug_menu, :test_auto_battle, {
  "name"        => "Test Auto Battle",
  "parent"      => :ai_testing_menu,
  "description" => "Runs an AI-controlled battle with no visuals.",
  "always_show" => false,
  "effect"      => proc {
    debug_test_auto_battle
  }
})

MenuHandlers.add(:debug_menu, :test_auto_battle_logging, {
  "name"        => "Test Auto Battle with logging",
  "parent"      => :ai_testing_menu,
  "description" => "Runs an AI-controlled battle with no visuals. Logs messages.",
  "always_show" => false,
  "effect"      => proc {
    debug_test_auto_battle(true)
    pbMessage("Battle transcript was logged in Data/debuglog.txt.")
  }
})

MenuHandlers.add(:debug_menu, :bulk_test_auto_battle, {
  "name"        => "Bulk test Auto Battle",
  "parent"      => :ai_testing_menu,
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

#===============================================================================
#
#===============================================================================
MenuHandlers.add(:debug_menu, :review_tested_data, {
  "name"        => "Review tested moves/abilities/items",
  "parent"      => :ai_testing_menu,
  "description" => "List how much all moves/abilities/items have been tested.",
  "always_show" => false,
  "effect"      => proc {
    mar_load_tested_data_record

    max_move_length = 0
    GameData::Move.keys.each { |m| max_move_length = [m.to_s.length, max_move_length].max }
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
        f.write(m[0].to_s)
        f.write(" " * (5 + max_move_length - m[0].to_s.length))
        f.write(m[1].to_s)
        f.write("\r\n")
      end
      f.write("\r\n")
      f.write("\r\n")
      f.write("\r\n")
      f.write("================================================\r\n")
      f.write("Remaining moves: #{remaining_moves.length}\r\n")
      f.write("================================================\r\n")
      remaining_moves.each do |m|
        f.write(m.to_s)
        if $tested_moves && $tested_moves[m]
          f.write(" " * (5 + max_move_length - m.to_s.length))
          f.write($tested_moves[m].to_s)
        end
        f.write("\r\n")
      end
    end
    echoln "Moves: #{thresholded_moves.length} tested at least #{AI_MOVE_TESTING_THRESHOLD} times."
    echoln "       #{remaining_moves.length} moves need more testing."

    #---------------------------------------------------------------------------

    max_ability_length = 0
    GameData::Ability.keys.each { |a| max_ability_length = [a.to_s.length, max_ability_length].max }
    thresholded_abilities = []
    ($tested_abilities || {}).each_pair do |abil, count|
      next if !count || count < AI_ABILITY_TESTING_THRESHOLD
      thresholded_abilities.push([abil, count])
    end
    thresholded_abilities.sort! { |a, b| a[0].to_s <=> b[0].to_s }
    remaining_abilities = GameData::Ability.keys.clone
    thresholded_abilities.each { |a| remaining_abilities.delete(a[0]) }
    remaining_abilities.sort! { |a, b| a.to_s <=> b.to_s }

    File.open("tested abilities summary.txt", "wb") do |f|
      f.write(0xEF.chr)
      f.write(0xBB.chr)
      f.write(0xBF.chr)
      f.write("================================================\r\n")
      f.write("Met threshold of #{AI_ABILITY_TESTING_THRESHOLD}: #{thresholded_abilities.length}\r\n")
      f.write("================================================\r\n")
      thresholded_abilities.each do |a|
        f.write(a[0].to_s)
        f.write(" " * (5 + max_ability_length - a[0].to_s.length))
        f.write(a[1].to_s)
        f.write("\r\n")
      end
      f.write("\r\n")
      f.write("\r\n")
      f.write("\r\n")
      f.write("================================================\r\n")
      f.write("Remaining abilities: #{remaining_abilities.length}\r\n")
      f.write("================================================\r\n")
      remaining_abilities.each do |a|
        f.write(a.to_s)
        if $tested_abilities && $tested_abilities[a]
          f.write(" " * (5 + max_ability_length - a.to_s.length))
          f.write($tested_abilities[a].to_s)
        end
        f.write("\r\n")
      end
    end
    echoln "Abilities: #{thresholded_abilities.length} tested at least #{AI_ABILITY_TESTING_THRESHOLD} times."
    echoln "           #{remaining_abilities.length} abilities need more testing."

    #---------------------------------------------------------------------------

    max_item_length = 0
    ITEMS_WITH_HELD_EFFECTS.each { |i| max_item_length = [i.to_s.length, max_item_length].max }
    thresholded_items = []
    ($tested_items || {}).each_pair do |item, count|
      next if !count || count < AI_ITEM_TESTING_THRESHOLD
      thresholded_items.push([item, count])
    end
    thresholded_items.sort! { |a, b| a[0].to_s <=> b[0].to_s }
    remaining_items = ITEMS_WITH_HELD_EFFECTS.clone
    remaining_items += MEGA_STONES.clone
    SIGNATURE_ITEMS.each_pair do |species, items|
      if items.is_a?(Array)
        remaining_items += items
      else
        remaining_items.push(items)
      end
    end
    remaining_items.uniq!
    thresholded_items.each { |i| remaining_items.delete(i[0]) }
    remaining_items.sort! { |a, b| a.to_s <=> b.to_s }

    File.open("tested items summary.txt", "wb") do |f|
      f.write(0xEF.chr)
      f.write(0xBB.chr)
      f.write(0xBF.chr)
      f.write("================================================\r\n")
      f.write("Met threshold of #{AI_ITEM_TESTING_THRESHOLD}: #{thresholded_items.length}\r\n")
      f.write("================================================\r\n")
      thresholded_items.each do |i|
        f.write(i[0].to_s)
        f.write(" " * (5 + max_item_length - i[0].to_s.length))
        f.write(i[1].to_s)
        f.write("\r\n")
      end
      f.write("\r\n")
      f.write("\r\n")
      f.write("\r\n")
      f.write("================================================\r\n")
      f.write("Remaining items: #{remaining_items.length}\r\n")
      f.write("================================================\r\n")
      remaining_items.each do |i|
        f.write(i.to_s)
        if $tested_items && $tested_items[i]
          f.write(" " * (5 + max_item_length - i.to_s.length))
          f.write($tested_items[i].to_s)
        end
        f.write("\r\n")
      end
    end
    echoln "Items: #{thresholded_items.length} tested at least #{AI_ITEM_TESTING_THRESHOLD} times."
    echoln "       #{remaining_items.length} items need more testing."
  }
})
