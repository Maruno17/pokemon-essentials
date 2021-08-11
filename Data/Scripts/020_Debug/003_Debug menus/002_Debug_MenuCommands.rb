#===============================================================================
#
#===============================================================================
module DebugMenuCommands
  @@commands = HandlerHashBasic.new

  def self.register(option, hash)
    @@commands.add(option, hash)
  end

  def self.registerIf(condition, hash)
    @@commands.addIf(condition, hash)
  end

  def self.copy(option, *new_options)
    @@commands.copy(option, *new_options)
  end

  def self.each
    @@commands.each { |key, hash| yield key, hash }
  end

  def self.hasFunction?(option, function)
    option_hash = @@commands[option]
    return option_hash && option_hash.keys.include?(function)
  end

  def self.getFunction(option, function)
    option_hash = @@commands[option]
    return (option_hash && option_hash[function]) ? option_hash[function] : nil
  end

  def self.call(function, option, *args)
    option_hash = @@commands[option]
    return nil if !option_hash || !option_hash[function]
    return (option_hash[function].call(*args) == true)
  end
end

#===============================================================================
# Field options
#===============================================================================
DebugMenuCommands.register("fieldmenu", {
  "parent"      => "main",
  "name"        => _INTL("Field options..."),
  "description" => _INTL("Warp to maps, edit switches/variables, use the PC, edit Day Care, etc.")
})

DebugMenuCommands.register("warp", {
  "parent"      => "fieldmenu",
  "name"        => _INTL("Warp to Map"),
  "description" => _INTL("Instantly warp to another map of your choice."),
  "effect"      => proc { |sprites, viewport|
    map = pbWarpToMap
    if map
      pbFadeOutAndHide(sprites)
      pbDisposeMessageWindow(sprites["textbox"])
      pbDisposeSpriteHash(sprites)
      viewport.dispose
      if $scene.is_a?(Scene_Map)
        $game_temp.player_new_map_id    = map[0]
        $game_temp.player_new_x         = map[1]
        $game_temp.player_new_y         = map[2]
        $game_temp.player_new_direction = 2
        $scene.transfer_player
      else
        pbCancelVehicles
        $MapFactory.setup(map[0])
        $game_player.moveto(map[1], map[2])
        $game_player.turn_down
        $game_map.update
        $game_map.autoplay
      end
      $game_map.refresh
      next true   # Closes the debug menu to allow the warp
    end
  }
})

DebugMenuCommands.register("refreshmap", {
  "parent"      => "fieldmenu",
  "name"        => _INTL("Refresh Map"),
  "description" => _INTL("Make all events on this map, and common events, refresh themselves."),
  "effect"      => proc {
    $game_map.need_refresh = true
    pbMessage(_INTL("The map will refresh."))
  }
})

DebugMenuCommands.register("switches", {
  "parent"      => "fieldmenu",
  "name"        => _INTL("Switches"),
  "description" => _INTL("Edit all Game Switches (except Script Switches)."),
  "effect"      => proc {
    pbDebugVariables(0)
  }
})

DebugMenuCommands.register("variables", {
  "parent"      => "fieldmenu",
  "name"        => _INTL("Variables"),
  "description" => _INTL("Edit all Game Variables. Can set them to numbers or text."),
  "effect"      => proc {
    pbDebugVariables(1)
  }
})

DebugMenuCommands.register("usepc", {
  "parent"      => "fieldmenu",
  "name"        => _INTL("Use PC"),
  "description" => _INTL("Use a PC to access Pokémon storage and player's PC."),
  "effect"      => proc {
    pbPokeCenterPC
  }
})

DebugMenuCommands.register("togglewallpapers", {
  "parent"      => "fieldmenu",
  "name"        => _INTL("Toggle Storage Wallpapers"),
  "description" => _INTL("Unlock and lock special wallpapers used in Pokémon storage."),
  "effect"      => proc {
    w = $PokemonStorage.allWallpapers
    if w.length <= PokemonStorage::BASICWALLPAPERQTY
      pbMessage(_INTL("There are no special wallpapers defined."))
    else
      paperscmd = 0
      unlockarray = $PokemonStorage.unlockedWallpapers
      loop do
        paperscmds = []
        paperscmds.push(_INTL("Unlock all"))
        paperscmds.push(_INTL("Lock all"))
        for i in PokemonStorage::BASICWALLPAPERQTY...w.length
          paperscmds.push(_INTL("{1} {2}", unlockarray[i] ? "[Y]" : "[  ]", w[i]))
        end
        paperscmd = pbShowCommands(nil, paperscmds, -1, paperscmd)
        break if paperscmd < 0
        if paperscmd == 0   # Unlock all
          for i in PokemonStorage::BASICWALLPAPERQTY...w.length
            unlockarray[i] = true
          end
        elsif paperscmd == 1   # Lock all
          for i in PokemonStorage::BASICWALLPAPERQTY...w.length
            unlockarray[i] = false
          end
        else
          paperindex = paperscmd - 2 + PokemonStorage::BASICWALLPAPERQTY
          unlockarray[paperindex] = !$PokemonStorage.unlockedWallpapers[paperindex]
        end
      end
    end
  }
})

DebugMenuCommands.register("daycare", {
  "parent"      => "fieldmenu",
  "name"        => _INTL("Day Care"),
  "description" => _INTL("View Pokémon in the Day Care and edit them."),
  "effect"      => proc {
    pbDebugDayCare
  }
})

DebugMenuCommands.register("relicstone", {
  "parent"      => "fieldmenu",
  "name"        => _INTL("Use Relic Stone"),
  "description" => _INTL("Shadow Pokémon. Choose a Pokémon to show to the Relic Stone for purification."),
  "effect"      => proc {
    pbRelicStone
  }
})

DebugMenuCommands.register("purifychamber", {
  "parent"      => "fieldmenu",
  "name"        => _INTL("Use Purify Chamber"),
  "description" => _INTL("Shadow Pokémon. Open the Purify Chamber for purification."),
  "effect"      => proc {
    pbPurifyChamber
  }
})

#===============================================================================
# Battle options
#===============================================================================
DebugMenuCommands.register("battlemenu", {
  "parent"      => "main",
  "name"        => _INTL("Battle options..."),
  "description" => _INTL("Start battles, reset this map's trainers, ready rematches, edit roamers, etc.")
})

DebugMenuCommands.register("testwildbattle", {
  "parent"      => "battlemenu",
  "name"        => _INTL("Test Wild Battle"),
  "description" => _INTL("Start a single battle against a wild Pokémon. You choose the species/level."),
  "effect"      => proc {
    species = pbChooseSpeciesList
    if species
      params = ChooseNumberParams.new
      params.setRange(1, GameData::GrowthRate.max_level)
      params.setInitialValue(5)
      params.setCancelValue(0)
      level = pbMessageChooseNumber(_INTL("Set the wild {1}'s level.",
         GameData::Species.get(species).name), params)
      if level > 0
        $PokemonTemp.encounterType = nil
        pbWildBattle(species, level)
      end
    end
    next false
  }
})

DebugMenuCommands.register("testwildbattleadvanced", {
  "parent"      => "battlemenu",
  "name"        => _INTL("Test Wild Battle Advanced"),
  "description" => _INTL("Start a battle against 1 or more wild Pokémon. Battle size is your choice."),
  "effect"      => proc {
    pkmn = []
    size0 = 1
    pkmnCmd = 0
    loop do
      pkmnCmds = []
      pkmn.each { |p| pkmnCmds.push(sprintf("%s Lv.%d", p.name, p.level)) }
      pkmnCmds.push(_INTL("[Add Pokémon]"))
      pkmnCmds.push(_INTL("[Set player side size]"))
      pkmnCmds.push(_INTL("[Start {1}v{2} battle]", size0, pkmn.length))
      pkmnCmd = pbShowCommands(nil, pkmnCmds, -1, pkmnCmd)
      break if pkmnCmd < 0
      if pkmnCmd == pkmnCmds.length - 1      # Start battle
        if pkmn.length == 0
          pbMessage(_INTL("No Pokémon were chosen, cannot start battle."))
          next
        end
        setBattleRule(sprintf("%dv%d", size0, pkmn.length))
        $PokemonTemp.encounterType = nil
        pbWildBattleCore(*pkmn)
        break
      elsif pkmnCmd == pkmnCmds.length - 2   # Set player side size
        if !pbCanDoubleBattle?
          pbMessage(_INTL("You only have one Pokémon."))
          next
        end
        maxVal = (pbCanTripleBattle?) ? 3 : 2
        params = ChooseNumberParams.new
        params.setRange(1, maxVal)
        params.setInitialValue(size0)
        params.setCancelValue(0)
        newSize = pbMessageChooseNumber(
           _INTL("Choose the number of battlers on the player's side (max. {1}).", maxVal), params)
        size0 = newSize if newSize > 0
      elsif pkmnCmd == pkmnCmds.length - 3   # Add Pokémon
        species = pbChooseSpeciesList
        if species
          params = ChooseNumberParams.new
          params.setRange(1, GameData::GrowthRate.max_level)
          params.setInitialValue(5)
          params.setCancelValue(0)
          level = pbMessageChooseNumber(_INTL("Set the wild {1}'s level.",
             GameData::Species.get(species).name), params)
          pkmn.push(Pokemon.new(species, level)) if level > 0
        end
      else                                   # Edit a Pokémon
        if pbConfirmMessage(_INTL("Change this Pokémon?"))
          scr = PokemonDebugPartyScreen.new
          scr.pbPokemonDebug(pkmn[pkmnCmd], -1, nil, true)
          scr.pbEndScreen
        elsif pbConfirmMessage(_INTL("Delete this Pokémon?"))
          pkmn[pkmnCmd] = nil
          pkmn.compact!
        end
      end
    end
    next false
  }
})

DebugMenuCommands.register("testtrainerbattle", {
  "parent"      => "battlemenu",
  "name"        => _INTL("Test Trainer Battle"),
  "description" => _INTL("Start a single battle against a trainer of your choice."),
  "effect"      => proc {
    trainerdata = pbListScreen(_INTL("SINGLE TRAINER"), TrainerBattleLister.new(0, false))
    if trainerdata
      pbTrainerBattle(trainerdata[0], trainerdata[1], nil, false, trainerdata[2], true)
    end
    next false
  }
})

DebugMenuCommands.register("testtrainerbattleadvanced", {
  "parent"      => "battlemenu",
  "name"        => _INTL("Test Trainer Battle Advanced"),
  "description" => _INTL("Start a battle against 1 or more trainers with a battle size of your choice."),
  "effect"      => proc {
    trainers = []
    size0 = 1
    size1 = 1
    trainerCmd = 0
    loop do
      trainerCmds = []
      trainers.each { |t| trainerCmds.push(sprintf("%s x%d", t[1].full_name, t[1].party_count)) }
      trainerCmds.push(_INTL("[Add trainer]"))
      trainerCmds.push(_INTL("[Set player side size]"))
      trainerCmds.push(_INTL("[Set opponent side size]"))
      trainerCmds.push(_INTL("[Start {1}v{2} battle]", size0, size1))
      trainerCmd = pbShowCommands(nil, trainerCmds, -1, trainerCmd)
      break if trainerCmd < 0
      if trainerCmd == trainerCmds.length - 1      # Start battle
        if trainers.length == 0
          pbMessage(_INTL("No trainers were chosen, cannot start battle."))
          next
        elsif size1 < trainers.length
          pbMessage(_INTL("Opposing side size is invalid. It should be at least {1}.", trainers.length))
          next
        elsif size1 > trainers.length && trainers[0][1].party_count == 1
          pbMessage(
             _INTL("Opposing side size cannot be {1}, as that requires the first trainer to have 2 or more Pokémon, which they don't.",
             size1))
          next
        end
        setBattleRule(sprintf("%dv%d", size0, size1))
        battleArgs = []
        trainers.each { |t| battleArgs.push(t[1]) }
        pbTrainerBattleCore(*battleArgs)
        break
      elsif trainerCmd == trainerCmds.length - 2   # Set opponent side size
        if trainers.length == 0 || (trainers.length == 1 && trainers[0][1].party_count == 1)
          pbMessage(_INTL("No trainers were chosen or trainer only has one Pokémon."))
          next
        end
        maxVal = 2
        maxVal = 3 if trainers.length >= 3 ||
                      (trainers.length == 2 && trainers[0][1].party_count >= 2) ||
                      trainers[0][1].party_count >= 3
        params = ChooseNumberParams.new
        params.setRange(1, maxVal)
        params.setInitialValue(size1)
        params.setCancelValue(0)
        newSize = pbMessageChooseNumber(
           _INTL("Choose the number of battlers on the opponent's side (max. {1}).", maxVal), params)
        size1 = newSize if newSize > 0
      elsif trainerCmd == trainerCmds.length - 3   # Set player side size
        if !pbCanDoubleBattle?
          pbMessage(_INTL("You only have one Pokémon."))
          next
        end
        maxVal = (pbCanTripleBattle?) ? 3 : 2
        params = ChooseNumberParams.new
        params.setRange(1, maxVal)
        params.setInitialValue(size0)
        params.setCancelValue(0)
        newSize = pbMessageChooseNumber(
           _INTL("Choose the number of battlers on the player's side (max. {1}).", maxVal), params)
        size0 = newSize if newSize > 0
      elsif trainerCmd == trainerCmds.length - 4   # Add trainer
        trainerdata = pbListScreen(_INTL("CHOOSE A TRAINER"), TrainerBattleLister.new(0, false))
        if trainerdata
          tr = pbLoadTrainer(trainerdata[0], trainerdata[1], trainerdata[2])
          trainers.push([0, tr])
        end
      else                                         # Edit a trainer
        if pbConfirmMessage(_INTL("Change this trainer?"))
          trainerdata = pbListScreen(_INTL("CHOOSE A TRAINER"),
             TrainerBattleLister.new(trainers[trainerCmd][0], false))
          if trainerdata
            tr = pbLoadTrainer(trainerdata[0], trainerdata[1], trainerdata[2])
            trainers[trainerCmd] = [0, tr]
          end
        elsif pbConfirmMessage(_INTL("Delete this trainer?"))
          trainers[trainerCmd] = nil
          trainers.compact!
        end
      end
    end
    next false
  }
})

DebugMenuCommands.register("togglelogging", {
  "parent"      => "battlemenu",
  "name"        => _INTL("Toggle Battle Logging"),
  "description" => _INTL("Record debug logs for battles in Data/debuglog.txt."),
  "effect"      => proc {
    $INTERNAL = !$INTERNAL
    pbMessage(_INTL("Debug logs for battles will be made in the Data folder.")) if $INTERNAL
    pbMessage(_INTL("Debug logs for battles will not be made.")) if !$INTERNAL
  }
})

DebugMenuCommands.register("resettrainers", {
  "parent"      => "battlemenu",
  "name"        => _INTL("Reset Map's Trainers"),
  "description" => _INTL("Turn off Self Switches A and B for all events with \"Trainer\" in their name."),
  "effect"      => proc {
    if $game_map
      for event in $game_map.events.values
        if event.name[/trainer/i]
          $game_self_switches[[$game_map.map_id, event.id, "A"]] = false
          $game_self_switches[[$game_map.map_id, event.id, "B"]] = false
        end
      end
      $game_map.need_refresh = true
      pbMessage(_INTL("All Trainers on this map were reset."))
    else
      pbMessage(_INTL("This command can't be used here."))
    end
  }
})

DebugMenuCommands.register("readyrematches", {
  "parent"      => "battlemenu",
  "name"        => _INTL("Ready All Phone Rematches"),
  "description" => _INTL("Make all trainers in the phone ready for rematches."),
  "effect"      => proc {
    if !$PokemonGlobal.phoneNumbers || $PokemonGlobal.phoneNumbers.length == 0
      pbMessage(_INTL("There are no trainers in the Phone."))
    else
      for i in $PokemonGlobal.phoneNumbers
        next if i.length != 8   # Isn't a trainer with an event
        i[4] = 2
        pbSetReadyToBattle(i)
      end
      pbMessage(_INTL("All trainers in the Phone are now ready to rebattle."))
    end
  }
})

DebugMenuCommands.register("roamers", {
  "parent"      => "battlemenu",
  "name"        => _INTL("Roaming Pokémon"),
  "description" => _INTL("Toggle and edit all roaming Pokémon."),
  "effect"      => proc {
    pbDebugRoamers
  }
})

DebugMenuCommands.register("encounterversion", {
  "parent"      => "battlemenu",
  "name"        => _INTL("Set Encounters Version"),
  "description" => _INTL("Choose which version of wild encounters should be used."),
  "effect"      => proc {
    params = ChooseNumberParams.new
    params.setRange(0, 99)
    params.setInitialValue($PokemonGlobal.encounter_version)
    params.setCancelValue(-1)
    value = pbMessageChooseNumber(_INTL("Set encounters version to which value?"), params)
    if value >= 0
      $PokemonGlobal.encounter_version = value
    end
  }
})

#===============================================================================
# Item options
#===============================================================================
DebugMenuCommands.register("itemsmenu", {
  "parent"      => "main",
  "name"        => _INTL("Item options..."),
  "description" => _INTL("Give and take items.")
})

DebugMenuCommands.register("additem", {
  "parent"      => "itemsmenu",
  "name"        => _INTL("Add Item"),
  "description" => _INTL("Choose an item and a quantity of it to add to the Bag."),
  "effect"      => proc {
    pbListScreenBlock(_INTL("ADD ITEM"), ItemLister.new) { |button, item|
      if button == Input::USE && item
        params = ChooseNumberParams.new
        params.setRange(1, Settings::BAG_MAX_PER_SLOT)
        params.setInitialValue(1)
        params.setCancelValue(0)
        qty = pbMessageChooseNumber(_INTL("Add how many {1}?",
           GameData::Item.get(item).name_plural), params)
        if qty > 0
          $PokemonBag.pbStoreItem(item, qty)
          pbMessage(_INTL("Gave {1}x {2}.", qty, GameData::Item.get(item).name))
        end
      end
    }
  }
})

DebugMenuCommands.register("fillbag", {
  "parent"      => "itemsmenu",
  "name"        => _INTL("Fill Bag"),
  "description" => _INTL("Add a certain number of every item to the Bag."),
  "effect"      => proc {
    params = ChooseNumberParams.new
    params.setRange(1, Settings::BAG_MAX_PER_SLOT)
    params.setInitialValue(1)
    params.setCancelValue(0)
    qty = pbMessageChooseNumber(_INTL("Choose the number of items."), params)
    if qty > 0
      GameData::Item.each { |i| $PokemonBag.pbStoreItem(i.id, qty) }
      pbMessage(_INTL("The Bag was filled with {1} of each item.", qty))
    end
  }
})

DebugMenuCommands.register("emptybag", {
  "parent"      => "itemsmenu",
  "name"        => _INTL("Empty Bag"),
  "description" => _INTL("Remove all items from the Bag."),
  "effect"      => proc {
    $PokemonBag.clear
    pbMessage(_INTL("The Bag was cleared."))
  }
})

#===============================================================================
# Pokémon options
#===============================================================================
DebugMenuCommands.register("pokemonmenu", {
  "parent"      => "main",
  "name"        => _INTL("Pokémon options..."),
  "description" => _INTL("Give Pokémon, heal party, fill/empty PC storage, etc.")
})

DebugMenuCommands.register("addpokemon", {
  "parent"      => "pokemonmenu",
  "name"        => _INTL("Add Pokémon"),
  "description" => _INTL("Give yourself a Pokémon of a chosen species/level. Goes to PC if party is full."),
  "effect"      => proc {
    species = pbChooseSpeciesList
    if species
      params = ChooseNumberParams.new
      params.setRange(1, GameData::GrowthRate.max_level)
      params.setInitialValue(5)
      params.setCancelValue(0)
      level = pbMessageChooseNumber(_INTL("Set the Pokémon's level."), params)
      pbAddPokemon(species, level) if level > 0
    end
  }
})

DebugMenuCommands.register("demoparty", {
  "parent"      => "pokemonmenu",
  "name"        => _INTL("Give Demo Party"),
  "description" => _INTL("Give yourself 6 preset Pokémon. They overwrite the current party."),
  "effect"      => proc {
    party = []
    species = [:PIKACHU, :PIDGEOTTO, :KADABRA, :GYARADOS, :DIGLETT, :CHANSEY]
    for id in species
      party.push(id) if GameData::Species.exists?(id)
    end
    $Trainer.party.clear
    # Generate Pokémon of each species at level 20
    party.each do |species|
      pkmn = Pokemon.new(species, 20)
      $Trainer.party.push(pkmn)
      $Trainer.pokedex.register(pkmn)
      $Trainer.pokedex.set_owned(species)
      case species
      when :PIDGEOTTO
        pkmn.learn_move(:FLY)
      when :KADABRA
        pkmn.learn_move(:FLASH)
        pkmn.learn_move(:TELEPORT)
      when :GYARADOS
        pkmn.learn_move(:SURF)
        pkmn.learn_move(:DIVE)
        pkmn.learn_move(:WATERFALL)
      when :DIGLETT
        pkmn.learn_move(:DIG)
        pkmn.learn_move(:CUT)
        pkmn.learn_move(:HEADBUTT)
        pkmn.learn_move(:ROCKSMASH)
      when :CHANSEY
        pkmn.learn_move(:SOFTBOILED)
        pkmn.learn_move(:STRENGTH)
        pkmn.learn_move(:SWEETSCENT)
      end
      pkmn.record_first_moves
    end
    pbMessage(_INTL("Filled party with demo Pokémon."))
  }
})

DebugMenuCommands.register("healparty", {
  "parent"      => "pokemonmenu",
  "name"        => _INTL("Heal Party"),
  "description" => _INTL("Fully heal the HP/status/PP of all Pokémon in the party."),
  "effect"      => proc {
    $Trainer.party.each { |pkmn| pkmn.heal }
    pbMessage(_INTL("Your Pokémon were fully healed."))
  }
})

DebugMenuCommands.register("quickhatch", {
  "parent"      => "pokemonmenu",
  "name"        => _INTL("Quick Hatch"),
  "description" => _INTL("Make all eggs in the party require just one more step to hatch."),
  "effect"      => proc {
    $Trainer.party.each { |pkmn| pkmn.steps_to_hatch = 1 if pkmn.egg? }
    pbMessage(_INTL("All eggs in your party now require one step to hatch."))
  }
})

DebugMenuCommands.register("fillboxes", {
  "parent"      => "pokemonmenu",
  "name"        => _INTL("Fill Storage Boxes"),
  "description" => _INTL("Add one Pokémon of each species (at Level 50) to storage."),
  "effect"      => proc {
    added = 0
    box_qty = $PokemonStorage.maxPokemon(0)
    completed = true
    GameData::Species.each do |species_data|
      sp = species_data.species
      f = species_data.form
      # Record each form of each species as seen and owned
      if f == 0
        if [:AlwaysMale, :AlwaysFemale, :Genderless].include?(species_data.gender_ratio)
          g = (species_data.gender_ratio == :AlwaysFemale) ? 1 : 0
          $Trainer.pokedex.register(sp, g, f, false)
        else   # Both male and female
          $Trainer.pokedex.register(sp, 0, f, false)
          $Trainer.pokedex.register(sp, 1, f, false)
        end
        $Trainer.pokedex.set_owned(sp, false)
      elsif species_data.real_form_name && !species_data.real_form_name.empty?
        g = (species_data.gender_ratio == :AlwaysFemale) ? 1 : 0
        $Trainer.pokedex.register(sp, g, f, false)
      end
      # Add Pokémon (if form 0, i.e. one of each species)
      next if f != 0
      if added >= Settings::NUM_STORAGE_BOXES * box_qty
        completed = false
        next
      end
      added += 1
      $PokemonStorage[(added - 1) / box_qty, (added - 1) % box_qty] = Pokemon.new(sp, 50)
    end
    $Trainer.pokedex.refresh_accessible_dexes
    pbMessage(_INTL("Storage boxes were filled with one Pokémon of each species."))
    if !completed
      pbMessage(_INTL("Note: The number of storage spaces ({1} boxes of {2}) is less than the number of species.",
         Settings::NUM_STORAGE_BOXES, box_qty))
    end
  }
})

DebugMenuCommands.register("clearboxes", {
  "parent"      => "pokemonmenu",
  "name"        => _INTL("Clear Storage Boxes"),
  "description" => _INTL("Remove all Pokémon in storage."),
  "effect"      => proc {
    for i in 0...$PokemonStorage.maxBoxes
      for j in 0...$PokemonStorage.maxPokemon(i)
        $PokemonStorage[i, j] = nil
      end
    end
    pbMessage(_INTL("The storage boxes were cleared."))
  }
})

DebugMenuCommands.register("openstorage", {
  "parent"      => "pokemonmenu",
  "name"        => _INTL("Access Pokémon Storage"),
  "description" => _INTL("Opens the Pokémon storage boxes in Organize Boxes mode."),
  "effect"      => proc {
    pbFadeOutIn {
      scene = PokemonStorageScene.new
      screen = PokemonStorageScreen.new(scene, $PokemonStorage)
      screen.pbStartScreen(0)
    }
  }
})

#===============================================================================
# Player options
#===============================================================================
DebugMenuCommands.register("playermenu", {
  "parent"      => "main",
  "name"        => _INTL("Player options..."),
  "description" => _INTL("Set money, badges, Pokédexes, player's appearance and name, etc.")
})

DebugMenuCommands.register("setbadges", {
  "parent"      => "playermenu",
  "name"        => _INTL("Set Badges"),
  "description" => _INTL("Toggle possession of each Gym Badge."),
  "effect"      => proc {
    badgecmd = 0
    loop do
      badgecmds = []
      badgecmds.push(_INTL("Give all"))
      badgecmds.push(_INTL("Remove all"))
      for i in 0...24
        badgecmds.push(_INTL("{1} Badge {2}", $Trainer.badges[i] ? "[Y]" : "[  ]", i + 1))
      end
      badgecmd = pbShowCommands(nil, badgecmds, -1, badgecmd)
      break if badgecmd < 0
      if badgecmd == 0   # Give all
        24.times { |i| $Trainer.badges[i] = true }
      elsif badgecmd == 1   # Remove all
        24.times { |i| $Trainer.badges[i] = false }
      else
        $Trainer.badges[badgecmd - 2] = !$Trainer.badges[badgecmd - 2]
      end
    end
  }
})

DebugMenuCommands.register("setmoney", {
  "parent"      => "playermenu",
  "name"        => _INTL("Set Money"),
  "description" => _INTL("Edit how much money you have."),
  "effect"      => proc {
    params = ChooseNumberParams.new
    params.setRange(0, Settings::MAX_MONEY)
    params.setDefaultValue($Trainer.money)
    $Trainer.money = pbMessageChooseNumber(_INTL("Set the player's money."), params)
    pbMessage(_INTL("You now have ${1}.", $Trainer.money.to_s_formatted))
  }
})

DebugMenuCommands.register("setcoins", {
  "parent"      => "playermenu",
  "name"        => _INTL("Set Coins"),
  "description" => _INTL("Edit how many Game Corner Coins you have."),
  "effect"      => proc {
    params = ChooseNumberParams.new
    params.setRange(0, Settings::MAX_COINS)
    params.setDefaultValue($Trainer.coins)
    $Trainer.coins = pbMessageChooseNumber(_INTL("Set the player's Coin amount."), params)
    pbMessage(_INTL("You now have {1} Coins.", $Trainer.coins.to_s_formatted))
  }
})

DebugMenuCommands.register("setbp", {
  "parent"      => "playermenu",
  "name"        => _INTL("Set Battle Points"),
  "description" => _INTL("Edit how many Battle Points you have."),
  "effect"      => proc {
    params = ChooseNumberParams.new
    params.setRange(0, Settings::MAX_BATTLE_POINTS)
    params.setDefaultValue($Trainer.battle_points)
    $Trainer.battle_points = pbMessageChooseNumber(_INTL("Set the player's BP amount."), params)
    pbMessage(_INTL("You now have {1} BP.", $Trainer.battle_points.to_s_formatted))
  }
})

DebugMenuCommands.register("toggleshoes", {
  "parent"      => "playermenu",
  "name"        => _INTL("Toggle Running Shoes"),
  "description" => _INTL("Toggle possession of running shoes."),
  "effect"      => proc {
    $Trainer.has_running_shoes = !$Trainer.has_running_shoes
    pbMessage(_INTL("Gave Running Shoes.")) if $Trainer.has_running_shoes
    pbMessage(_INTL("Lost Running Shoes.")) if !$Trainer.has_running_shoes
  }
})

DebugMenuCommands.register("togglepokegear", {
  "parent"      => "playermenu",
  "name"        => _INTL("Toggle Pokégear"),
  "description" => _INTL("Toggle possession of the Pokégear."),
  "effect"      => proc {
    $Trainer.has_pokegear = !$Trainer.has_pokegear
    pbMessage(_INTL("Gave Pokégear.")) if $Trainer.has_pokegear
    pbMessage(_INTL("Lost Pokégear.")) if !$Trainer.has_pokegear
  }
})

DebugMenuCommands.register("dexlists", {
  "parent"      => "playermenu",
  "name"        => _INTL("Toggle Pokédex and Dexes"),
  "description" => _INTL("Toggle possession of the Pokédex, and edit Regional Dex accessibility."),
  "effect"      => proc {
    dexescmd = 0
    loop do
      dexescmds = []
      dexescmds.push(_INTL("Have Pokédex: {1}", $Trainer.has_pokedex ? "[YES]" : "[NO]"))
      dex_names = Settings.pokedex_names
      for i in 0...dex_names.length
        name = (dex_names[i].is_a?(Array)) ? dex_names[i][0] : dex_names[i]
        unlocked = $Trainer.pokedex.unlocked?(i)
        dexescmds.push(_INTL("{1} {2}", unlocked ? "[Y]" : "[  ]", name))
      end
      dexescmd = pbShowCommands(nil, dexescmds, -1, dexescmd)
      break if dexescmd < 0
      dexindex = dexescmd - 1
      if dexindex < 0   # Toggle Pokédex ownership
        $Trainer.has_pokedex = !$Trainer.has_pokedex
      else   # Toggle Regional Dex accessibility
        if $Trainer.pokedex.unlocked?(dexindex)
          $Trainer.pokedex.lock(dexindex)
        else
          $Trainer.pokedex.unlock(dexindex)
        end
      end
    end
  }
})

DebugMenuCommands.register("setplayer", {
  "parent"      => "playermenu",
  "name"        => _INTL("Set Player Character"),
  "description" => _INTL("Edit the player's character, as defined in \"metadata.txt\"."),
  "effect"      => proc {
    limit = 0
    for i in 0...8
      meta = GameData::Metadata.get_player(i)
      next if meta
      limit = i
      break
    end
    if limit <= 1
      pbMessage(_INTL("There is only one player defined."))
    else
      params = ChooseNumberParams.new
      params.setRange(0, limit - 1)
      params.setDefaultValue($Trainer.character_ID)
      newid = pbMessageChooseNumber(_INTL("Choose the new player character."), params)
      if newid != $Trainer.character_ID
        pbChangePlayer(newid)
        pbMessage(_INTL("The player character was changed."))
      end
    end
  }
})

DebugMenuCommands.register("changeoutfit", {
  "parent"      => "playermenu",
  "name"        => _INTL("Set Player Outfit"),
  "description" => _INTL("Edit the player's outfit number."),
  "effect"      => proc {
    oldoutfit = $Trainer.outfit
    params = ChooseNumberParams.new
    params.setRange(0, 99)
    params.setDefaultValue(oldoutfit)
    $Trainer.outfit = pbMessageChooseNumber(_INTL("Set the player's outfit."), params)
    pbMessage(_INTL("Player's outfit was changed.")) if $Trainer.outfit != oldoutfit
  }
})

DebugMenuCommands.register("renameplayer", {
  "parent"      => "playermenu",
  "name"        => _INTL("Set Player Name"),
  "description" => _INTL("Rename the player."),
  "effect"      => proc {
    trname = pbEnterPlayerName("Your name?", 0, Settings::MAX_PLAYER_NAME_SIZE, $Trainer.name)
    if nil_or_empty?(trname) && pbConfirmMessage(_INTL("Give yourself a default name?"))
      trainertype = $Trainer.trainer_type
      gender      = pbGetTrainerTypeGender(trainertype)
      trname      = pbSuggestTrainerName(gender)
    end
    if nil_or_empty?(trname)
      pbMessage(_INTL("The player's name remained {1}.", $Trainer.name))
    else
      $Trainer.name = trname
      pbMessage(_INTL("The player's name was changed to {1}.", $Trainer.name))
    end
  }
})

DebugMenuCommands.register("randomid", {
  "parent"      => "playermenu",
  "name"        => _INTL("Randomize Player ID"),
  "description" => _INTL("Generate a random new ID for the player."),
  "effect"      => proc {
    $Trainer.id = rand(2 ** 16) | rand(2 ** 16) << 16
    pbMessage(_INTL("The player's ID was changed to {1} (full ID: {2}).", $Trainer.public_ID, $Trainer.id))
  }
})

#===============================================================================
# Information editors
#===============================================================================
DebugMenuCommands.register("editorsmenu", {
  "parent"      => "main",
  "name"        => _INTL("Information editors..."),
  "description" => _INTL("Edit information in the PBS files, terrain tags, battle animations, etc."),
  "always_show" => true
})

DebugMenuCommands.register("setmetadata", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("Edit Metadata"),
  "description" => _INTL("Edit global and map metadata."),
  "always_show" => true,
  "effect"      => proc {
    pbMetadataScreen(pbDefaultMap)
  }
})

DebugMenuCommands.register("mapconnections", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("Edit Map Connections"),
  "description" => _INTL("Connect maps using a visual interface. Can also edit map encounters/metadata."),
  "always_show" => true,
  "effect"      => proc {
    pbFadeOutIn { pbConnectionsEditor }
  }
})

DebugMenuCommands.register("terraintags", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("Edit Terrain Tags"),
  "description" => _INTL("Edit the terrain tags of tiles in tilesets. Required for tags 8+."),
  "always_show" => true,
  "effect"      => proc {
    pbFadeOutIn { pbTilesetScreen }
  }
})

DebugMenuCommands.register("setencounters", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("Edit Wild Encounters"),
  "description" => _INTL("Edit the wild Pokémon that can be found on maps, and how they are encountered."),
  "always_show" => true,
  "effect"      => proc {
    pbFadeOutIn { pbEncountersEditor }
  }
})

DebugMenuCommands.register("trainertypes", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("Edit Trainer Types"),
  "description" => _INTL("Edit the properties of trainer types."),
  "always_show" => true,
  "effect"      => proc {
    pbFadeOutIn { pbTrainerTypeEditor }
  }
})

DebugMenuCommands.register("edittrainers", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("Edit Individual Trainers"),
  "description" => _INTL("Edit individual trainers, their Pokémon and items."),
  "always_show" => true,
  "effect"      => proc {
    pbFadeOutIn { pbTrainerBattleEditor }
  }
})

DebugMenuCommands.register("edititems", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("Edit Items"),
  "description" => _INTL("Edit item data."),
  "always_show" => true,
  "effect"      => proc {
    pbFadeOutIn { pbItemEditor }
  }
})

DebugMenuCommands.register("editpokemon", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("Edit Pokémon"),
  "description" => _INTL("Edit Pokémon species data."),
  "always_show" => true,
  "effect"      => proc {
    pbFadeOutIn { pbPokemonEditor }
  }
})

DebugMenuCommands.register("editdexes", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("Edit Regional Dexes"),
  "description" => _INTL("Create, rearrange and delete Regional Pokédex lists."),
  "always_show" => true,
  "effect"      => proc {
    pbFadeOutIn { pbRegionalDexEditorMain }
  }
})

DebugMenuCommands.register("positionsprites", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("Edit Pokémon Sprite Positions"),
  "description" => _INTL("Reposition Pokémon sprites in battle."),
  "always_show" => true,
  "effect"      => proc {
    pbFadeOutIn {
      sp = SpritePositioner.new
      sps = SpritePositionerScreen.new(sp)
      sps.pbStart
    }
  }
})

DebugMenuCommands.register("autopositionsprites", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("Auto-Position All Sprites"),
  "description" => _INTL("Automatically reposition all Pokémon sprites in battle. Don't use lightly."),
  "always_show" => true,
  "effect"      => proc {
    if pbConfirmMessage(_INTL("Are you sure you want to reposition all sprites?"))
      msgwindow = pbCreateMessageWindow
      pbMessageDisplay(msgwindow, _INTL("Repositioning all sprites. Please wait."), false)
      Graphics.update
      pbAutoPositionAll
      pbDisposeMessageWindow(msgwindow)
    end
  }
})

DebugMenuCommands.register("animeditor", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("Battle Animation Editor"),
  "description" => _INTL("Edit the battle animations."),
  "always_show" => true,
  "effect"      => proc {
    pbFadeOutIn { pbAnimationEditor }
  }
})

DebugMenuCommands.register("animorganiser", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("Battle Animation Organiser"),
  "description" => _INTL("Rearrange/add/delete battle animations."),
  "always_show" => true,
  "effect"      => proc {
    pbFadeOutIn { pbAnimationsOrganiser }
  }
})

DebugMenuCommands.register("importanims", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("Import All Battle Animations"),
  "description" => _INTL("Import all battle animations from the \"Animations\" folder."),
  "always_show" => true,
  "effect"      => proc {
    pbImportAllAnimations
  }
})

DebugMenuCommands.register("exportanims", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("Export All Battle Animations"),
  "description" => _INTL("Export all battle animations individually to the \"Animations\" folder."),
  "always_show" => true,
  "effect"      => proc {
    pbExportAllAnimations
  }
})

#===============================================================================
# Other options
#===============================================================================
DebugMenuCommands.register("othermenu", {
  "parent"      => "main",
  "name"        => _INTL("Other options..."),
  "description" => _INTL("Mystery Gifts, translations, compile data, etc."),
  "always_show" => true
})

DebugMenuCommands.register("mysterygift", {
  "parent"      => "othermenu",
  "name"        => _INTL("Manage Mystery Gifts"),
  "description" => _INTL("Edit and enable/disable Mystery Gifts."),
  "always_show" => true,
  "effect"      => proc {
    pbManageMysteryGifts
  }
})

DebugMenuCommands.register("extracttext", {
  "parent"      => "othermenu",
  "name"        => _INTL("Extract Text"),
  "description" => _INTL("Extract all text in the game to a single file for translating."),
  "always_show" => true,
  "effect"      => proc {
    pbExtractText
  }
})

DebugMenuCommands.register("compiletext", {
  "parent"      => "othermenu",
  "name"        => _INTL("Compile Text"),
  "description" => _INTL("Import text and converts it into a language file."),
  "always_show" => true,
  "effect"      => proc {
    pbCompileTextUI
  }
})

DebugMenuCommands.register("compiledata", {
  "parent"      => "othermenu",
  "name"        => _INTL("Compile Data"),
  "description" => _INTL("Fully compile all data."),
  "always_show" => true,
  "effect"      => proc {
    msgwindow = pbCreateMessageWindow
    Compiler.compile_all(true) { |msg| pbMessageDisplay(msgwindow, msg, false); echoln(msg) }
    pbMessageDisplay(msgwindow, _INTL("All game data was compiled."))
    pbDisposeMessageWindow(msgwindow)
  }
})

DebugMenuCommands.register("createpbs", {
  "parent"      => "othermenu",
  "name"        => _INTL("Create PBS File(s)"),
  "description" => _INTL("Choose one or all PBS files and create it."),
  "always_show" => true,
  "effect"      => proc {
    cmd = 0
    cmds = [
      _INTL("[Create all]"),
      "abilities.txt",
      "berryplants.txt",
      "connections.txt",
      "encounters.txt",
      "items.txt",
      "metadata.txt",
      "moves.txt",
      "phone.txt",
      "pokemon.txt",
      "pokemonforms.txt",
      "regionaldexes.txt",
      "ribbons.txt",
      "shadowmoves.txt",
      "townmap.txt",
      "trainerlists.txt",
      "trainers.txt",
      "trainertypes.txt",
      "types.txt"
    ]
    loop do
      cmd = pbShowCommands(nil, cmds, -1, cmd)
      case cmd
      when 0  then Compiler.write_all
      when 1  then Compiler.write_abilities
      when 2  then Compiler.write_berry_plants
      when 3  then Compiler.write_connections
      when 4  then Compiler.write_encounters
      when 5  then Compiler.write_items
      when 6  then Compiler.write_metadata
      when 7  then Compiler.write_moves
      when 8  then Compiler.write_phone
      when 9  then Compiler.write_pokemon
      when 10 then Compiler.write_pokemon_forms
      when 11 then Compiler.write_regional_dexes
      when 12 then Compiler.write_ribbons
      when 13 then Compiler.write_shadow_movesets
      when 14 then Compiler.write_town_map
      when 15 then Compiler.write_trainer_lists
      when 16 then Compiler.write_trainers
      when 17 then Compiler.write_trainer_types
      when 18 then Compiler.write_types
      else break
      end
      pbMessage(_INTL("File written."))
    end
  }
})

DebugMenuCommands.register("renamesprites", {
  "parent"      => "othermenu",
  "name"        => _INTL("Rename Old Sprites"),
  "description" => _INTL("Renames and moves Pokémon/item/trainer sprites from their old places."),
  "always_show" => true,
  "effect"      => proc {
    SpriteRenamer.convert_files
  }
})

DebugMenuCommands.register("invalidtiles", {
  "parent"      => "othermenu",
  "name"        => _INTL("Fix Invalid Tiles"),
  "description" => _INTL("Scans all maps and erases non-existent tiles."),
  "always_show" => true,
  "effect"      => proc {
    pbDebugFixInvalidTiles
  }
})
