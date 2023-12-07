#===============================================================================
# HP/Status options
#===============================================================================
MenuHandlers.add(:pokemon_debug_menu, :hp_status_menu, {
  "name"   => _INTL("HP/status..."),
  "parent" => :main
})

MenuHandlers.add(:pokemon_debug_menu, :set_hp, {
  "name"   => _INTL("Set HP"),
  "parent" => :hp_status_menu,
  "effect" => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    if pkmn.egg?
      screen.pbDisplay(_INTL("{1} is an egg.", pkmn.name))
    else
      params = ChooseNumberParams.new
      params.setRange(0, pkmn.totalhp)
      params.setDefaultValue(pkmn.hp)
      newhp = pbMessageChooseNumber(
        _INTL("Set {1}'s HP (max. {2}).", pkmn.name, pkmn.totalhp), params
      ) { screen.pbUpdate }
      if newhp != pkmn.hp
        pkmn.hp = newhp
        screen.pbRefreshSingle(pkmnid)
      end
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :set_status, {
  "name"   => _INTL("Set status"),
  "parent" => :hp_status_menu,
  "effect" => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    if pkmn.egg?
      screen.pbDisplay(_INTL("{1} is an egg.", pkmn.name))
    elsif pkmn.hp <= 0
      screen.pbDisplay(_INTL("{1} is fainted, can't change status.", pkmn.name))
    else
      cmd = 0
      commands = [_INTL("[Cure]")]
      ids = [:NONE]
      GameData::Status.each do |s|
        next if s.id == :NONE
        commands.push(_INTL("Set {1}", s.name))
        ids.push(s.id)
      end
      loop do
        msg = _INTL("Current status: {1}", GameData::Status.get(pkmn.status).name)
        if pkmn.status == :SLEEP
          msg = _INTL("Current status: {1} (turns: {2})",
                      GameData::Status.get(pkmn.status).name, pkmn.statusCount)
        end
        cmd = screen.pbShowCommands(msg, commands, cmd)
        break if cmd < 0
        case cmd
        when 0   # Cure
          pkmn.heal_status
          screen.pbRefreshSingle(pkmnid)
        else   # Give status problem
          count = 0
          cancel = false
          if ids[cmd] == :SLEEP
            params = ChooseNumberParams.new
            params.setRange(0, 9)
            params.setDefaultValue(3)
            count = pbMessageChooseNumber(
              _INTL("Set the Pokémon's sleep count."), params
            ) { screen.pbUpdate }
            cancel = true if count <= 0
          end
          if !cancel
            pkmn.status      = ids[cmd]
            pkmn.statusCount = count
            screen.pbRefreshSingle(pkmnid)
          end
        end
      end
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :full_heal, {
  "name"   => _INTL("Fully heal"),
  "parent" => :hp_status_menu,
  "effect" => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    if pkmn.egg?
      screen.pbDisplay(_INTL("{1} is an egg.", pkmn.name))
    else
      pkmn.heal
      screen.pbDisplay(_INTL("{1} was fully healed.", pkmn.name))
      screen.pbRefreshSingle(pkmnid)
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :make_fainted, {
  "name"   => _INTL("Make fainted"),
  "parent" => :hp_status_menu,
  "effect" => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    if pkmn.egg?
      screen.pbDisplay(_INTL("{1} is an egg.", pkmn.name))
    else
      pkmn.hp = 0
      screen.pbRefreshSingle(pkmnid)
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :set_pokerus, {
  "name"   => _INTL("Set Pokérus"),
  "parent" => :hp_status_menu,
  "effect" => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    cmd = 0
    loop do
      pokerus = (pkmn.pokerus) ? pkmn.pokerus : 0
      msg = [_INTL("{1} doesn't have Pokérus.", pkmn.name),
             _INTL("Has strain {1}, infectious for {2} more days.", pokerus / 16, pokerus % 16),
             _INTL("Has strain {1}, not infectious.", pokerus / 16)][pkmn.pokerusStage]
      cmd = screen.pbShowCommands(msg,
                                  [_INTL("Give random strain"),
                                   _INTL("Make not infectious"),
                                   _INTL("Clear Pokérus")], cmd)
      break if cmd < 0
      case cmd
      when 0   # Give random strain
        pkmn.givePokerus
        screen.pbRefreshSingle(pkmnid)
      when 1   # Make not infectious
        if pokerus > 0
          strain = pokerus / 16
          p = strain << 4
          pkmn.pokerus = p
          screen.pbRefreshSingle(pkmnid)
        end
      when 2   # Clear Pokérus
        pkmn.pokerus = 0
        screen.pbRefreshSingle(pkmnid)
      end
    end
    next false
  }
})

#===============================================================================
# Level/stats options
#===============================================================================
MenuHandlers.add(:pokemon_debug_menu, :level_stats, {
  "name"   => _INTL("Level/stats..."),
  "parent" => :main
})

MenuHandlers.add(:pokemon_debug_menu, :set_level, {
  "name"   => _INTL("Set level"),
  "parent" => :level_stats,
  "effect" => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    if pkmn.egg?
      screen.pbDisplay(_INTL("{1} is an egg.", pkmn.name))
    else
      params = ChooseNumberParams.new
      params.setRange(1, GameData::GrowthRate.max_level)
      params.setDefaultValue(pkmn.level)
      level = pbMessageChooseNumber(
        _INTL("Set the Pokémon's level (max. {1}).", params.maxNumber), params
      ) { screen.pbUpdate }
      if level != pkmn.level
        pkmn.level = level
        pkmn.calc_stats
        screen.pbRefreshSingle(pkmnid)
      end
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :set_exp, {
  "name"   => _INTL("Set Exp"),
  "parent" => :level_stats,
  "effect" => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    if pkmn.egg?
      screen.pbDisplay(_INTL("{1} is an egg.", pkmn.name))
    else
      minxp = pkmn.growth_rate.minimum_exp_for_level(pkmn.level)
      maxxp = pkmn.growth_rate.minimum_exp_for_level(pkmn.level + 1)
      if minxp == maxxp
        screen.pbDisplay(_INTL("{1} is at the maximum level.", pkmn.name))
      else
        params = ChooseNumberParams.new
        params.setRange(minxp, maxxp - 1)
        params.setDefaultValue(pkmn.exp)
        newexp = pbMessageChooseNumber(
          _INTL("Set the Pokémon's Exp (range {1}-{2}).", minxp, maxxp - 1), params
        ) { screen.pbUpdate }
        if newexp != pkmn.exp
          pkmn.exp = newexp
          pkmn.calc_stats
          screen.pbRefreshSingle(pkmnid)
        end
      end
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :hidden_values, {
  "name"   => _INTL("EV/IV/personal ID..."),
  "parent" => :level_stats,
  "effect" => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    cmd = 0
    loop do
      persid = sprintf("0x%08X", pkmn.personalID)
      cmd = screen.pbShowCommands(_INTL("Personal ID is {1}.", persid),
                                  [_INTL("Set EVs"),
                                   _INTL("Set IVs"),
                                   _INTL("Randomise pID")], cmd)
      break if cmd < 0
      case cmd
      when 0   # Set EVs
        cmd2 = 0
        loop do
          totalev = 0
          evcommands = []
          ev_id = []
          GameData::Stat.each_main do |s|
            evcommands.push(s.name + " (#{pkmn.ev[s.id]})")
            ev_id.push(s.id)
            totalev += pkmn.ev[s.id]
          end
          evcommands.push(_INTL("Randomise all"))
          evcommands.push(_INTL("Max randomise all"))
          cmd2 = screen.pbShowCommands(_INTL("Change which EV?\nTotal: {1}/{2} ({3}%)",
                                             totalev, Pokemon::EV_LIMIT,
                                             100 * totalev / Pokemon::EV_LIMIT), evcommands, cmd2)
          break if cmd2 < 0
          if cmd2 < ev_id.length
            params = ChooseNumberParams.new
            upperLimit = 0
            GameData::Stat.each_main { |s| upperLimit += pkmn.ev[s.id] if s.id != ev_id[cmd2] }
            upperLimit = Pokemon::EV_LIMIT - upperLimit
            upperLimit = [upperLimit, Pokemon::EV_STAT_LIMIT].min
            thisValue = [pkmn.ev[ev_id[cmd2]], upperLimit].min
            params.setRange(0, upperLimit)
            params.setDefaultValue(thisValue)
            params.setCancelValue(thisValue)
            f = pbMessageChooseNumber(_INTL("Set the EV for {1} (max. {2}).",
                                            GameData::Stat.get(ev_id[cmd2]).name, upperLimit), params) { screen.pbUpdate }
            if f != pkmn.ev[ev_id[cmd2]]
              pkmn.ev[ev_id[cmd2]] = f
              pkmn.calc_stats
              screen.pbRefreshSingle(pkmnid)
            end
          else   # (Max) Randomise all
            evTotalTarget = Pokemon::EV_LIMIT
            if cmd2 == evcommands.length - 2   # Randomize all (not max)
              evTotalTarget = rand(Pokemon::EV_LIMIT)
            end
            GameData::Stat.each_main { |s| pkmn.ev[s.id] = 0 }
            while evTotalTarget > 0
              r = rand(ev_id.length)
              next if pkmn.ev[ev_id[r]] >= Pokemon::EV_STAT_LIMIT
              addVal = 1 + rand(Pokemon::EV_STAT_LIMIT / 4)
              addVal = addVal.clamp(0, evTotalTarget)
              addVal = addVal.clamp(0, Pokemon::EV_STAT_LIMIT - pkmn.ev[ev_id[r]])
              next if addVal == 0
              pkmn.ev[ev_id[r]] += addVal
              evTotalTarget -= addVal
            end
            pkmn.calc_stats
            screen.pbRefreshSingle(pkmnid)
          end
        end
      when 1   # Set IVs
        cmd2 = 0
        loop do
          hiddenpower = pbHiddenPower(pkmn)
          totaliv = 0
          ivcommands = []
          iv_id = []
          GameData::Stat.each_main do |s|
            ivcommands.push(s.name + " (#{pkmn.iv[s.id]})")
            iv_id.push(s.id)
            totaliv += pkmn.iv[s.id]
          end
          msg = _INTL("Change which IV?\nHidden Power:\n{1}, power {2}\nTotal: {3}/{4} ({5}%)",
                      GameData::Type.get(hiddenpower[0]).name, hiddenpower[1], totaliv,
                      iv_id.length * Pokemon::IV_STAT_LIMIT, 100 * totaliv / (iv_id.length * Pokemon::IV_STAT_LIMIT))
          ivcommands.push(_INTL("Randomise all"))
          cmd2 = screen.pbShowCommands(msg, ivcommands, cmd2)
          break if cmd2 < 0
          if cmd2 < iv_id.length
            params = ChooseNumberParams.new
            params.setRange(0, Pokemon::IV_STAT_LIMIT)
            params.setDefaultValue(pkmn.iv[iv_id[cmd2]])
            params.setCancelValue(pkmn.iv[iv_id[cmd2]])
            f = pbMessageChooseNumber(_INTL("Set the IV for {1} (max. 31).",
                                            GameData::Stat.get(iv_id[cmd2]).name), params) { screen.pbUpdate }
            if f != pkmn.iv[iv_id[cmd2]]
              pkmn.iv[iv_id[cmd2]] = f
              pkmn.calc_stats
              screen.pbRefreshSingle(pkmnid)
            end
          else   # Randomise all
            GameData::Stat.each_main { |s| pkmn.iv[s.id] = rand(Pokemon::IV_STAT_LIMIT + 1) }
            pkmn.calc_stats
            screen.pbRefreshSingle(pkmnid)
          end
        end
      when 2   # Randomise pID
        pkmn.personalID = rand(2**16) | (rand(2**16) << 16)
        pkmn.calc_stats
        screen.pbRefreshSingle(pkmnid)
      end
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :set_happiness, {
  "name"   => _INTL("Set happiness"),
  "parent" => :level_stats,
  "effect" => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    params = ChooseNumberParams.new
    params.setRange(0, 255)
    params.setDefaultValue(pkmn.happiness)
    h = pbMessageChooseNumber(
      _INTL("Set the Pokémon's happiness (max. 255)."), params
    ) { screen.pbUpdate }
    if h != pkmn.happiness
      pkmn.happiness = h
      screen.pbRefreshSingle(pkmnid)
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :contest_stats, {
  "name"   => _INTL("Contest stats..."),
  "parent" => :level_stats
})

MenuHandlers.add(:pokemon_debug_menu, :set_beauty, {
  "name"   => _INTL("Set Beauty"),
  "parent" => :contest_stats,
  "effect" => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    params = ChooseNumberParams.new
    params.setRange(0, 255)
    params.setDefaultValue(pkmn.beauty)
    newval = pbMessageChooseNumber(
      _INTL("Set the Pokémon's Beauty (max. 255)."), params
    ) { screen.pbUpdate }
    if newval != pkmn.beauty
      pkmn.beauty = newval
      screen.pbRefreshSingle(pkmnid)
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :set_cool, {
  "name"   => _INTL("Set Cool"),
  "parent" => :contest_stats,
  "effect" => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    params = ChooseNumberParams.new
    params.setRange(0, 255)
    params.setDefaultValue(pkmn.cool)
    newval = pbMessageChooseNumber(
      _INTL("Set the Pokémon's Cool (max. 255)."), params
    ) { screen.pbUpdate }
    if newval != pkmn.cool
      pkmn.cool = newval
      screen.pbRefreshSingle(pkmnid)
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :set_cute, {
  "name"   => _INTL("Set Cute"),
  "parent" => :contest_stats,
  "effect" => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    params = ChooseNumberParams.new
    params.setRange(0, 255)
    params.setDefaultValue(pkmn.cute)
    newval = pbMessageChooseNumber(
      _INTL("Set the Pokémon's Cute (max. 255)."), params
    ) { screen.pbUpdate }
    if newval != pkmn.cute
      pkmn.cute = newval
      screen.pbRefreshSingle(pkmnid)
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :set_smart, {
  "name"   => _INTL("Set Smart"),
  "parent" => :contest_stats,
  "effect" => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    params = ChooseNumberParams.new
    params.setRange(0, 255)
    params.setDefaultValue(pkmn.smart)
    newval = pbMessageChooseNumber(
      _INTL("Set the Pokémon's Smart (max. 255)."), params
    ) { screen.pbUpdate }
    if newval != pkmn.smart
      pkmn.smart = newval
      screen.pbRefreshSingle(pkmnid)
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :set_tough, {
  "name"   => _INTL("Set Tough"),
  "parent" => :contest_stats,
  "effect" => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    params = ChooseNumberParams.new
    params.setRange(0, 255)
    params.setDefaultValue(pkmn.tough)
    newval = pbMessageChooseNumber(
      _INTL("Set the Pokémon's Tough (max. 255)."), params
    ) { screen.pbUpdate }
    if newval != pkmn.tough
      pkmn.tough = newval
      screen.pbRefreshSingle(pkmnid)
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :set_sheen, {
  "name"   => _INTL("Set Sheen"),
  "parent" => :contest_stats,
  "effect" => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    params = ChooseNumberParams.new
    params.setRange(0, 255)
    params.setDefaultValue(pkmn.sheen)
    newval = pbMessageChooseNumber(
      _INTL("Set the Pokémon's Sheen (max. 255)."), params
    ) { screen.pbUpdate }
    if newval != pkmn.sheen
      pkmn.sheen = newval
      screen.pbRefreshSingle(pkmnid)
    end
    next false
  }
})

#===============================================================================
# Moves options
#===============================================================================
MenuHandlers.add(:pokemon_debug_menu, :moves, {
  "name"   => _INTL("Moves..."),
  "parent" => :main
})

MenuHandlers.add(:pokemon_debug_menu, :teach_move, {
  "name"   => _INTL("Teach move"),
  "parent" => :moves,
  "effect" => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    move = pbChooseMoveList
    if move
      pbLearnMove(pkmn, move)
      screen.pbRefreshSingle(pkmnid)
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :forget_move, {
  "name"   => _INTL("Forget move"),
  "parent" => :moves,
  "effect" => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    moveindex = screen.pbChooseMove(pkmn, _INTL("Choose move to forget."))
    if moveindex >= 0
      movename = pkmn.moves[moveindex].name
      pkmn.forget_move_at_index(moveindex)
      screen.pbDisplay(_INTL("{1} forgot {2}.", pkmn.name, movename))
      screen.pbRefreshSingle(pkmnid)
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :reset_moves, {
  "name"   => _INTL("Reset moves"),
  "parent" => :moves,
  "effect" => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    pkmn.reset_moves
    screen.pbDisplay(_INTL("{1}'s moves were reset.", pkmn.name))
    screen.pbRefreshSingle(pkmnid)
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :set_move_pp, {
  "name"   => _INTL("Set move PP"),
  "parent" => :moves,
  "effect" => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    cmd = 0
    loop do
      commands = []
      pkmn.moves.each do |i|
        break if !i.id
        if i.total_pp <= 0
          commands.push(_INTL("{1} (PP: ---)", i.name))
        else
          commands.push(_INTL("{1} (PP: {2}/{3})", i.name, i.pp, i.total_pp))
        end
      end
      commands.push(_INTL("Restore all PP"))
      cmd = screen.pbShowCommands(_INTL("Alter PP of which move?"), commands, cmd)
      break if cmd < 0
      if cmd >= 0 && cmd < commands.length - 1   # Move
        move = pkmn.moves[cmd]
        movename = move.name
        if move.total_pp <= 0
          screen.pbDisplay(_INTL("{1} has infinite PP.", movename))
        else
          cmd2 = 0
          loop do
            msg = _INTL("{1}: PP {2}/{3} (PP Up {4}/3)", movename, move.pp, move.total_pp, move.ppup)
            cmd2 = screen.pbShowCommands(msg,
                                         [_INTL("Set PP"),
                                          _INTL("Full PP"),
                                          _INTL("Set PP Up")], cmd2)
            break if cmd2 < 0
            case cmd2
            when 0   # Change PP
              params = ChooseNumberParams.new
              params.setRange(0, move.total_pp)
              params.setDefaultValue(move.pp)
              h = pbMessageChooseNumber(
                _INTL("Set PP of {1} (max. {2}).", movename, move.total_pp), params
              ) { screen.pbUpdate }
              move.pp = h
            when 1   # Full PP
              move.pp = move.total_pp
            when 2   # Change PP Up
              params = ChooseNumberParams.new
              params.setRange(0, 3)
              params.setDefaultValue(move.ppup)
              h = pbMessageChooseNumber(
                _INTL("Set PP Up of {1} (max. 3).", movename), params
              ) { screen.pbUpdate }
              move.ppup = h
              move.pp = move.total_pp if move.pp > move.total_pp
            end
          end
        end
      elsif cmd == commands.length - 1   # Restore all PP
        pkmn.heal_PP
      end
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :set_initial_moves, {
  "name"   => _INTL("Reset initial moves"),
  "parent" => :moves,
  "effect" => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    pkmn.record_first_moves
    screen.pbDisplay(_INTL("{1}'s moves were set as its first-known moves.", pkmn.name))
    screen.pbRefreshSingle(pkmnid)
    next false
  }
})

#===============================================================================
# Other options
#===============================================================================
MenuHandlers.add(:pokemon_debug_menu, :set_item, {
  "name"   => _INTL("Set item"),
  "parent" => :main,
  "effect" => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    cmd = 0
    commands = [
      _INTL("Change item"),
      _INTL("Remove item")
    ]
    loop do
      msg = (pkmn.hasItem?) ? _INTL("Item is {1}.", pkmn.item.name) : _INTL("No item.")
      cmd = screen.pbShowCommands(msg, commands, cmd)
      break if cmd < 0
      case cmd
      when 0   # Change item
        item = pbChooseItemList(pkmn.item_id)
        if item && item != pkmn.item_id
          pkmn.item = item
          if GameData::Item.get(item).is_mail?
            pkmn.mail = Mail.new(item, _INTL("Text"), $player.name)
          end
          screen.pbRefreshSingle(pkmnid)
        end
      when 1   # Remove item
        if pkmn.hasItem?
          pkmn.item = nil
          pkmn.mail = nil
          screen.pbRefreshSingle(pkmnid)
        end
      else
        break
      end
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :set_ability, {
  "name"   => _INTL("Set ability"),
  "parent" => :main,
  "effect" => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    cmd = 0
    commands = [
      _INTL("Set possible ability"),
      _INTL("Set any ability"),
      _INTL("Reset")
    ]
    loop do
      if pkmn.ability
        msg = _INTL("Ability is {1} (index {2}).", pkmn.ability.name, pkmn.ability_index)
      else
        msg = _INTL("No ability (index {1}).", pkmn.ability_index)
      end
      cmd = screen.pbShowCommands(msg, commands, cmd)
      break if cmd < 0
      case cmd
      when 0   # Set possible ability
        abils = pkmn.getAbilityList
        ability_commands = []
        abil_cmd = 0
        abils.each do |i|
          ability_commands.push(((i[1] < 2) ? "" : "(H) ") + GameData::Ability.get(i[0]).name)
          abil_cmd = ability_commands.length - 1 if pkmn.ability_id == i[0]
        end
        abil_cmd = screen.pbShowCommands(_INTL("Choose an ability."), ability_commands, abil_cmd)
        next if abil_cmd < 0
        pkmn.ability_index = abils[abil_cmd][1]
        pkmn.ability = nil
        screen.pbRefreshSingle(pkmnid)
      when 1   # Set any ability
        new_ability = pbChooseAbilityList(pkmn.ability_id)
        if new_ability && new_ability != pkmn.ability_id
          pkmn.ability = new_ability
          screen.pbRefreshSingle(pkmnid)
        end
      when 2   # Reset
        pkmn.ability_index = nil
        pkmn.ability = nil
        screen.pbRefreshSingle(pkmnid)
      end
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :set_nature, {
  "name"   => _INTL("Set nature"),
  "parent" => :main,
  "effect" => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    commands = []
    ids = []
    GameData::Nature.each do |nature|
      if nature.stat_changes.length == 0
        commands.push(_INTL("{1} (---)", nature.real_name))
      else
        plus_text = ""
        minus_text = ""
        nature.stat_changes.each do |change|
          if change[1] > 0
            plus_text += "/" if !plus_text.empty?
            plus_text += GameData::Stat.get(change[0]).name_brief
          elsif change[1] < 0
            minus_text += "/" if !minus_text.empty?
            minus_text += GameData::Stat.get(change[0]).name_brief
          end
        end
        commands.push(_INTL("{1} (+{2}, -{3})", nature.real_name, plus_text, minus_text))
      end
      ids.push(nature.id)
    end
    commands.push(_INTL("[Reset]"))
    cmd = ids.index(pkmn.nature_id || ids[0])
    loop do
      msg = _INTL("Nature is {1}.", pkmn.nature.name)
      cmd = screen.pbShowCommands(msg, commands, cmd)
      break if cmd < 0
      if cmd >= 0 && cmd < commands.length - 1   # Set nature
        pkmn.nature = ids[cmd]
      elsif cmd == commands.length - 1   # Reset
        pkmn.nature = nil
      end
      screen.pbRefreshSingle(pkmnid)
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :set_gender, {
  "name"   => _INTL("Set gender"),
  "parent" => :main,
  "effect" => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    if pkmn.singleGendered?
      screen.pbDisplay(_INTL("{1} is single-gendered or genderless.", pkmn.speciesName))
    else
      cmd = 0
      loop do
        msg = [_INTL("Gender is male."), _INTL("Gender is female.")][pkmn.male? ? 0 : 1]
        cmd = screen.pbShowCommands(msg,
                                    [_INTL("Make male"),
                                     _INTL("Make female"),
                                     _INTL("Reset")], cmd)
        break if cmd < 0
        case cmd
        when 0   # Make male
          pkmn.makeMale
          if !pkmn.male?
            screen.pbDisplay(_INTL("{1}'s gender couldn't be changed.", pkmn.name))
          end
        when 1   # Make female
          pkmn.makeFemale
          if !pkmn.female?
            screen.pbDisplay(_INTL("{1}'s gender couldn't be changed.", pkmn.name))
          end
        when 2   # Reset
          pkmn.gender = nil
        end
        $player.pokedex.register(pkmn) if !settingUpBattle && !pkmn.egg?
        screen.pbRefreshSingle(pkmnid)
      end
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :species_and_form, {
  "name"   => _INTL("Species/form..."),
  "parent" => :main,
  "effect" => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    cmd = 0
    loop do
      msg = [_INTL("Species {1}, form {2}.", pkmn.speciesName, pkmn.form),
             _INTL("Species {1}, form {2} (forced).", pkmn.speciesName, pkmn.form)][(pkmn.forced_form.nil?) ? 0 : 1]
      cmd = screen.pbShowCommands(msg,
                                  [_INTL("Set species"),
                                   _INTL("Set form"),
                                   _INTL("Remove form override")], cmd)
      break if cmd < 0
      case cmd
      when 0   # Set species
        species = pbChooseSpeciesList(pkmn.species)
        if species && species != pkmn.species
          pkmn.species = species
          pkmn.calc_stats
          $player.pokedex.register(pkmn) if !settingUpBattle && !pkmn.egg?
          screen.pbRefreshSingle(pkmnid)
        end
      when 1   # Set form
        cmd2 = 0
        formcmds = [[], []]
        GameData::Species.each do |sp|
          next if sp.species != pkmn.species
          form_name = sp.form_name
          form_name = _INTL("Unnamed form") if !form_name || form_name.empty?
          form_name = sprintf("%d: %s", sp.form, form_name)
          formcmds[0].push(sp.form)
          formcmds[1].push(form_name)
          cmd2 = formcmds[0].length - 1 if pkmn.form == sp.form
        end
        if formcmds[0].length <= 1
          screen.pbDisplay(_INTL("Species {1} only has one form.", pkmn.speciesName))
          if pkmn.form != 0 && screen.pbConfirm(_INTL("Do you want to reset the form to 0?"))
            pkmn.form = 0
            $player.pokedex.register(pkmn) if !settingUpBattle && !pkmn.egg?
            screen.pbRefreshSingle(pkmnid)
          end
        else
          cmd2 = screen.pbShowCommands(_INTL("Set the Pokémon's form."), formcmds[1], cmd2)
          next if cmd2 < 0
          f = formcmds[0][cmd2]
          if f != pkmn.form
            if MultipleForms.hasFunction?(pkmn, "getForm")
              next if !screen.pbConfirm(_INTL("This species decides its own form. Override?"))
              pkmn.forced_form = f
            end
            pkmn.form = f
            $player.pokedex.register(pkmn) if !settingUpBattle && !pkmn.egg?
            screen.pbRefreshSingle(pkmnid)
          end
        end
      when 2   # Remove form override
        pkmn.forced_form = nil
        screen.pbRefreshSingle(pkmnid)
      end
    end
    next false
  }
})

#===============================================================================
# Cosmetic options
#===============================================================================
MenuHandlers.add(:pokemon_debug_menu, :cosmetic, {
  "name"   => _INTL("Cosmetic info..."),
  "parent" => :main
})

MenuHandlers.add(:pokemon_debug_menu, :set_shininess, {
  "name"   => _INTL("Set shininess"),
  "parent" => :cosmetic,
  "effect" => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    cmd = 0
    loop do
      msg_idx = pkmn.shiny? ? (pkmn.super_shiny? ? 1 : 0) : 2
      msg = [_INTL("Is shiny."), _INTL("Is super shiny."), _INTL("Is normal (not shiny).")][msg_idx]
      cmd = screen.pbShowCommands(msg, [_INTL("Make shiny"), _INTL("Make super shiny"),
                                        _INTL("Make normal"), _INTL("Reset")], cmd)
      break if cmd < 0
      case cmd
      when 0   # Make shiny
        pkmn.shiny = true
        pkmn.super_shiny = false
      when 1   # Make super shiny
        pkmn.super_shiny = true
      when 2   # Make normal
        pkmn.shiny = false
        pkmn.super_shiny = false
      when 3   # Reset
        pkmn.shiny = nil
        pkmn.super_shiny = nil
      end
      $player.pokedex.register(pkmn) if !settingUpBattle && !pkmn.egg?
      screen.pbRefreshSingle(pkmnid)
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :set_pokeball, {
  "name"   => _INTL("Set Poké Ball"),
  "parent" => :cosmetic,
  "effect" => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    commands = []
    balls = []
    GameData::Item.each do |item_data|
      balls.push([item_data.id, item_data.name]) if item_data.is_poke_ball?
    end
    balls.sort! { |a, b| a[1] <=> b[1] }
    cmd = 0
    balls.each_with_index do |ball, i|
      next if ball[0] != pkmn.poke_ball
      cmd = i
      break
    end
    balls.each { |ball| commands.push(ball[1]) }
    loop do
      oldball = GameData::Item.get(pkmn.poke_ball).name
      cmd = screen.pbShowCommands(_INTL("{1} used.", oldball), commands, cmd)
      break if cmd < 0
      pkmn.poke_ball = balls[cmd][0]
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :set_ribbons, {
  "name"   => _INTL("Set ribbons"),
  "parent" => :cosmetic,
  "effect" => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    cmd = 0
    loop do
      commands = []
      ids = []
      GameData::Ribbon.each do |ribbon_data|
        commands.push(_INTL("{1} {2}",
                            (pkmn.hasRibbon?(ribbon_data.id)) ? "[Y]" : "[  ]", ribbon_data.name))
        ids.push(ribbon_data.id)
      end
      commands.push(_INTL("Give all"))
      commands.push(_INTL("Clear all"))
      cmd = screen.pbShowCommands(_INTL("{1} ribbons.", pkmn.numRibbons), commands, cmd)
      break if cmd < 0
      if cmd >= 0 && cmd < ids.length   # Toggle ribbon
        if pkmn.hasRibbon?(ids[cmd])
          pkmn.takeRibbon(ids[cmd])
        else
          pkmn.giveRibbon(ids[cmd])
        end
      elsif cmd == commands.length - 2   # Give all
        GameData::Ribbon.each do |ribbon_data|
          pkmn.giveRibbon(ribbon_data.id)
        end
      elsif cmd == commands.length - 1   # Clear all
        pkmn.clearAllRibbons
      end
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :set_nickname, {
  "name"   => _INTL("Set nickname"),
  "parent" => :cosmetic,
  "effect" => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    cmd = 0
    loop do
      speciesname = pkmn.speciesName
      msg = [_INTL("{1} has the nickname {2}.", speciesname, pkmn.name),
             _INTL("{1} has no nickname.", speciesname)][pkmn.nicknamed? ? 0 : 1]
      cmd = screen.pbShowCommands(msg, [_INTL("Rename"), _INTL("Erase name")], cmd)
      break if cmd < 0
      case cmd
      when 0   # Rename
        oldname = (pkmn.nicknamed?) ? pkmn.name : ""
        newname = pbEnterPokemonName(_INTL("{1}'s nickname?", speciesname),
                                     0, Pokemon::MAX_NAME_SIZE, oldname, pkmn)
        pkmn.name = newname
        screen.pbRefreshSingle(pkmnid)
      when 1   # Erase name
        pkmn.name = nil
        screen.pbRefreshSingle(pkmnid)
      end
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :ownership, {
  "name"   => _INTL("Ownership..."),
  "parent" => :cosmetic,
  "effect" => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    cmd = 0
    loop do
      gender = [_INTL("Male"), _INTL("Female"), _INTL("Unknown")][pkmn.owner.gender]
      msg = [_INTL("Player's Pokémon\n{1}\n{2}\n{3} ({4})",
                   pkmn.owner.name, gender, pkmn.owner.public_id, pkmn.owner.id),
             _INTL("Foreign Pokémon\n{1}\n{2}\n{3} ({4})",
                   pkmn.owner.name, gender, pkmn.owner.public_id, pkmn.owner.id)][pkmn.foreign?($player) ? 1 : 0]
      cmd = screen.pbShowCommands(msg,
                                  [_INTL("Make player's"),
                                   _INTL("Set OT's name"),
                                   _INTL("Set OT's gender"),
                                   _INTL("Random foreign ID"),
                                   _INTL("Set foreign ID")], cmd)
      break if cmd < 0
      case cmd
      when 0   # Make player's
        pkmn.owner = Pokemon::Owner.new_from_trainer($player)
      when 1   # Set OT's name
        pkmn.owner.name = pbEnterPlayerName(_INTL("{1}'s OT's name?", pkmn.name), 1, Settings::MAX_PLAYER_NAME_SIZE)
      when 2   # Set OT's gender
        cmd2 = screen.pbShowCommands(_INTL("Set OT's gender."),
                                     [_INTL("Male"), _INTL("Female"), _INTL("Unknown")], pkmn.owner.gender)
        pkmn.owner.gender = cmd2 if cmd2 >= 0
      when 3   # Random foreign ID
        pkmn.owner.id = $player.make_foreign_ID
      when 4   # Set foreign ID
        params = ChooseNumberParams.new
        params.setRange(0, 65_535)
        params.setDefaultValue(pkmn.owner.public_id)
        val = pbMessageChooseNumber(
          _INTL("Set the new ID (max. 65535)."), params
        ) { screen.pbUpdate }
        pkmn.owner.id = val | (val << 16)
      end
    end
    next false
  }
})

#===============================================================================
# Can store/release/trade
#===============================================================================
MenuHandlers.add(:pokemon_debug_menu, :set_discardable, {
  "name"   => _INTL("Set discardable"),
  "parent" => :main,
  "effect" => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    cmd = 0
    loop do
      msg = _INTL("Click option to toggle.")
      cmds = []
      cmds.push((pkmn.cannot_store) ? _INTL("Cannot store") : _INTL("Can store"))
      cmds.push((pkmn.cannot_release) ? _INTL("Cannot release") : _INTL("Can release"))
      cmds.push((pkmn.cannot_trade) ? _INTL("Cannot trade") : _INTL("Can trade"))
      cmd = screen.pbShowCommands(msg, cmds, cmd)
      break if cmd < 0
      case cmd
      when 0   # Toggle storing
        pkmn.cannot_store = !pkmn.cannot_store
      when 1   # Toggle releasing
        pkmn.cannot_release = !pkmn.cannot_release
      when 2   # Toggle trading
        pkmn.cannot_trade = !pkmn.cannot_trade
      end
    end
    next false
  }
})

#===============================================================================
# Other options
#===============================================================================
MenuHandlers.add(:pokemon_debug_menu, :set_egg, {
  "name"        => _INTL("Set egg"),
  "parent"      => :main,
  "always_show" => false,
  "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    cmd = 0
    loop do
      msg = [_INTL("Not an egg"),
             _INTL("Egg (hatches in {1} steps).", pkmn.steps_to_hatch)][pkmn.egg? ? 1 : 0]
      cmd = screen.pbShowCommands(msg,
                                  [_INTL("Make egg"),
                                   _INTL("Make Pokémon"),
                                   _INTL("Set steps left to 1")], cmd)
      break if cmd < 0
      case cmd
      when 0   # Make egg
        if !pkmn.egg? && (pbHasEgg?(pkmn.species) ||
           screen.pbConfirm(_INTL("{1} cannot legally be an egg. Make egg anyway?", pkmn.speciesName)))
          pkmn.level          = Settings::EGG_LEVEL
          pkmn.calc_stats
          pkmn.name           = _INTL("Egg")
          pkmn.steps_to_hatch = pkmn.species_data.hatch_steps
          pkmn.hatched_map    = 0
          pkmn.obtain_method  = 1
          screen.pbRefreshSingle(pkmnid)
        end
      when 1   # Make Pokémon
        if pkmn.egg?
          pkmn.name           = nil
          pkmn.steps_to_hatch = 0
          pkmn.hatched_map    = 0
          pkmn.obtain_method  = 0
          $player.pokedex.register(pkmn) if !settingUpBattle
          screen.pbRefreshSingle(pkmnid)
        end
      when 2   # Set steps left to 1
        pkmn.steps_to_hatch = 1 if pkmn.egg?
      end
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :shadow_pkmn, {
  "name"   => _INTL("Shadow Pkmn..."),
  "parent" => :main,
  "effect" => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    cmd = 0
    loop do
      msg = [_INTL("Not a Shadow Pokémon."),
             _INTL("Heart gauge is {1} (stage {2}).", pkmn.heart_gauge, pkmn.heartStage)][pkmn.shadowPokemon? ? 1 : 0]
      cmd = screen.pbShowCommands(msg, [_INTL("Make Shadow"), _INTL("Set heart gauge")], cmd)
      break if cmd < 0
      case cmd
      when 0   # Make Shadow
        if pkmn.shadowPokemon?
          screen.pbDisplay(_INTL("{1} is already a Shadow Pokémon.", pkmn.name))
        else
          pkmn.makeShadow
          screen.pbRefreshSingle(pkmnid)
        end
      when 1   # Set heart gauge
        if pkmn.shadowPokemon?
          oldheart = pkmn.heart_gauge
          params = ChooseNumberParams.new
          params.setRange(0, pkmn.max_gauge_size)
          params.setDefaultValue(pkmn.heart_gauge)
          val = pbMessageChooseNumber(
            _INTL("Set the heart gauge (max. {1}).", pkmn.max_gauge_size),
            params
          ) { screen.pbUpdate }
          if val != oldheart
            pkmn.adjustHeart(val - oldheart)
            pkmn.check_ready_to_purify
          end
        else
          screen.pbDisplay(_INTL("{1} is not a Shadow Pokémon.", pkmn.name))
        end
      end
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :mystery_gift, {
  "name"        => _INTL("Mystery Gift"),
  "parent"      => :main,
  "always_show" => false,
  "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    pbCreateMysteryGift(0, pkmn)
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :duplicate, {
  "name"        => _INTL("Duplicate"),
  "parent"      => :main,
  "always_show" => false,
  "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    next false if !screen.pbConfirm(_INTL("Are you sure you want to copy this Pokémon?"))
    clonedpkmn = pkmn.clone
    case screen
    when PokemonPartyScreen
      pbStorePokemon(clonedpkmn)
      screen.pbHardRefresh
      screen.pbDisplay(_INTL("The Pokémon was duplicated."))
    when PokemonStorageScreen
      if screen.storage.pbMoveCaughtToParty(clonedpkmn)
        if pkmnid[0] != -1
          screen.pbDisplay(_INTL("The duplicated Pokémon was moved to your party."))
        end
      else
        oldbox = screen.storage.currentBox
        newbox = screen.storage.pbStoreCaught(clonedpkmn)
        if newbox < 0
          screen.pbDisplay(_INTL("All boxes are full."))
        elsif newbox != oldbox
          screen.pbDisplay(_INTL("The duplicated Pokémon was moved to box \"{1}.\"", screen.storage[newbox].name))
          screen.storage.currentBox = oldbox
        end
      end
      screen.pbHardRefresh
    end
    next true
  }
})

MenuHandlers.add(:pokemon_debug_menu, :delete, {
  "name"        => _INTL("Delete"),
  "parent"      => :main,
  "always_show" => false,
  "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    next false if !screen.pbConfirm(_INTL("Are you sure you want to delete this Pokémon?"))
    case screen
    when PokemonPartyScreen
      screen.party.delete_at(pkmnid)
      screen.pbHardRefresh
    when PokemonStorageScreen
      screen.scene.pbRelease(pkmnid, heldpoke)
      (heldpoke) ? screen.heldpkmn = nil : screen.storage.pbDelete(pkmnid[0], pkmnid[1])
      screen.scene.pbRefresh
    end
    next true
  }
})
