#===============================================================================
# HP/Status options.
#===============================================================================

MenuHandlers.add(:pokemon_debug_menu, :hp_status_menu, {
  "name"   => _INTL("HP/status..."),
  "parent" => :main
})

MenuHandlers.add(:pokemon_debug_menu, :set_hp, {
  "name"   => _INTL("Set HP"),
  "parent" => :hp_status_menu,
  "effect" => proc { |pkmn, party_index, setting_up_battle, screen|
    if pkmn.egg?
      screen.show_message(_INTL("{1} is an egg.", pkmn.name))
      next false
    end
    params = ChooseNumberParams.new
    params.setRange(0, pkmn.totalhp)
    params.setDefaultValue(pkmn.hp)
    new_hp = screen.choose_number("\\se[]" + _INTL("Set the Pokémon's HP (max. {1}).", params.maxNumber), params)
    if new_hp != pkmn.hp
      pkmn.hp = new_hp
      screen.refresh
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :set_status, {
  "name"   => _INTL("Set status"),
  "parent" => :hp_status_menu,
  "effect" => proc { |pkmn, party_index, setting_up_battle, screen|
    if pkmn.egg?
      screen.show_message(_INTL("{1} is an egg.", pkmn.name))
      next false
    elsif pkmn.hp <= 0
      screen.show_message(_INTL("{1} is fainted, can't change status.", pkmn.name))
      next false
    end
    commands = {:NONE => _INTL("[Cure]")}
    GameData::Status.each do |s|
      commands[s.id] = _INTL("Set {1}", s.name) if s.id != :NONE
    end
    cmd = commands.keys.first
    loop do
      msg = _INTL("Current status: {1}", GameData::Status.get(pkmn.status).name)
      if pkmn.status == :SLEEP
        msg = _INTL("Current status: {1} (turns: {2})", GameData::Status.get(pkmn.status).name, pkmn.statusCount)
      end
      cmd = screen.show_menu(msg, commands, commands.keys.index(cmd))
      break if cmd.nil?
      case cmd
      when :NONE   # Cure
        pkmn.heal_status
        screen.refresh
      else   # Give status problem
        count = 0
        cancel = false
        if cmd == :SLEEP
          params = ChooseNumberParams.new
          params.setRange(0, 9)
          params.setDefaultValue(3)
          count = screen.choose_number("\\se[]" + _INTL("Set the Pokémon's sleep count."), params)
          cancel = true if count <= 0
        end
        if !cancel
          pkmn.status      = cmd
          pkmn.statusCount = count
          screen.refresh
        end
      end
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :full_heal, {
  "name"   => _INTL("Fully heal"),
  "parent" => :hp_status_menu,
  "effect" => proc { |pkmn, party_index, setting_up_battle, screen|
    if pkmn.egg?
      screen.show_message(_INTL("{1} is an egg.", pkmn.name))
    else
      pkmn.heal
      screen.refresh
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :make_fainted, {
  "name"   => _INTL("Make fainted"),
  "parent" => :hp_status_menu,
  "effect" => proc { |pkmn, party_index, setting_up_battle, screen|
    if pkmn.egg?
      screen.show_message(_INTL("{1} is an egg.", pkmn.name))
    else
      pkmn.hp = 0
      screen.refresh
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :set_pokerus, {
  "name"   => _INTL("Set Pokérus"),
  "parent" => :hp_status_menu,
  "effect" => proc { |pkmn, party_index, setting_up_battle, screen|
    commands = {
      :random_strain  => _INTL("Give random strain"),
      :non_infectious => _INTL("Make not infectious"),
      :clear          => _INTL("Clear Pokérus")
    }
    cmd = commands.keys.first
    loop do
      pokerus = (pkmn.pokerus) ? pkmn.pokerus : 0
      msg = [_INTL("{1} doesn't have Pokérus.", pkmn.name),
             _INTL("Has strain {1}, infectious for {2} more days.", pokerus / 16, pokerus % 16),
             _INTL("Has strain {1}, not infectious.", pokerus / 16)][pkmn.pokerusStage]
      cmd = screen.show_menu(msg, commands, commands.keys.index(cmd))
      break if cmd.nil?
      case cmd
      when :random_strain
        pkmn.pokerus = 0
        pkmn.givePokerus
        screen.refresh
      when :non_infectious
        if pokerus > 0
          strain = pokerus / 16
          p = strain << 4
          pkmn.pokerus = p
          screen.refresh
        end
      when :clear
        pkmn.pokerus = 0
        screen.refresh
      end
    end
    next false
  }
})

#===============================================================================
# Level/stats options.
#===============================================================================

MenuHandlers.add(:pokemon_debug_menu, :level_stats, {
  "name"   => _INTL("Level/stats..."),
  "parent" => :main
})

MenuHandlers.add(:pokemon_debug_menu, :set_level, {
  "name"   => _INTL("Set level"),
  "parent" => :level_stats,
  "effect" => proc { |pkmn, party_index, setting_up_battle, screen|
    if pkmn.egg?
      screen.show_message(_INTL("{1} is an egg.", pkmn.name))
      next false
    end
    params = ChooseNumberParams.new
    params.setRange(1, GameData::GrowthRate.max_level)
    params.setDefaultValue(pkmn.level)
    level = screen.choose_number("\\se[]" + _INTL("Set the Pokémon's level (max. {1}).", params.maxNumber), params)
    if level != pkmn.level
      pkmn.level = level
      pkmn.calc_stats
      screen.refresh
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :set_exp, {
  "name"   => _INTL("Set Exp"),
  "parent" => :level_stats,
  "effect" => proc { |pkmn, party_index, setting_up_battle, screen|
    if pkmn.egg?
      screen.show_message(_INTL("{1} is an egg.", pkmn.name))
      next false
    end
    min_xp = pkmn.growth_rate.minimum_exp_for_level(pkmn.level)
    max_xp = pkmn.growth_rate.minimum_exp_for_level(pkmn.level + 1)
    if min_xp == max_xp
      screen.show_message(_INTL("{1} is at the maximum level.", pkmn.name))
      next false
    end
    params = ChooseNumberParams.new
    params.setRange(min_xp, max_xp - 1)
    params.setDefaultValue(pkmn.exp)
    new_exp = screen.choose_number("\\se[]" + _INTL("Set the Pokémon's Exp (range {1}-{2}).", min_xp, max_xp - 1), params)
    if new_exp != pkmn.exp
      pkmn.exp = new_exp
      pkmn.calc_stats
      screen.refresh
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :hidden_values, {
  "name"   => _INTL("EV/IV/personal ID..."),
  "parent" => :level_stats,
  "effect" => proc { |pkmn, party_index, setting_up_battle, screen|
    commands = {
      :set_evs    => _INTL("Set EVs"),
      :set_ivs    => _INTL("Set IVs"),
      :random_pid => _INTL("Randomize pID")
    }
    cmd = commands.keys.first
    loop do
      pers_id = sprintf("0x%08X", pkmn.personalID)
      cmd = screen.show_menu(_INTL("Personal ID is {1}.", pers_id), commands, commands.keys.index(cmd))
      break if cmd.nil?
      case cmd
      when :set_evs
        ev_cmd = nil
        loop do
          total_evs = 0
          ev_commands = {}
          stats = []
          GameData::Stat.each_main do |s|
            ev_commands[s.id] = s.name + " (#{pkmn.ev[s.id]})"
            stats.push(s.id)
            total_evs += pkmn.ev[s.id]
          end
          ev_commands[:randomize] = _INTL("Randomize all")
          ev_commands[:max_randomize] = _INTL("Max randomize all")
          ev_cmd ||= ev_commands.keys.first
          ev_cmd = screen.show_menu(
            _INTL("Change which EV?\nTotal: {1}/{2} ({3}%)", total_evs, Pokemon::EV_LIMIT, 100 * total_evs / Pokemon::EV_LIMIT),
            ev_commands, ev_commands.keys.index(ev_cmd)
          )
          break if ev_cmd.nil?
          case ev_cmd
          when :randomize, :max_randomize
            ev_total_target = (ev_cmd == :randomize) ? rand(Pokemon::EV_LIMIT) : Pokemon::EV_LIMIT
            stats.each { |stat| pkmn.ev[stat] = 0 }
            while ev_total_target > 0
              stat = stats.sample
              next if pkmn.ev[stat] >= Pokemon::EV_STAT_LIMIT
              add_val = [1 + rand(Pokemon::EV_STAT_LIMIT / 4), ev_total_target, Pokemon::EV_STAT_LIMIT - pkmn.ev[stat]].min
              next if add_val == 0
              pkmn.ev[stat] += add_val
              ev_total_target -= add_val
            end
            pkmn.calc_stats
            screen.refresh
          else   # Set a particular stat's EVs
            params = ChooseNumberParams.new
            total_other_evs = 0
            stats.each { |stat| total_other_evs += pkmn.ev[stat] if stat != ev_cmd }
            upper_limit = [Pokemon::EV_LIMIT - total_other_evs, Pokemon::EV_STAT_LIMIT].min
            this_value = [pkmn.ev[ev_cmd], upper_limit].min
            params.setRange(0, upper_limit)
            params.setDefaultValue(this_value)
            params.setCancelValue(this_value)
            new_val = screen.choose_number("\\se[]" + _INTL("Set the EV for {1} (max. {2}).",
                                                            GameData::Stat.get(ev_cmd).name, upper_limit), params)
            if new_val != pkmn.ev[ev_cmd]
              pkmn.ev[ev_cmd] = new_val
              pkmn.calc_stats
              screen.refresh
            end
          end
        end
      when :set_ivs
        iv_cmd = nil
        loop do
          total_ivs = 0
          iv_commands = {}
          stats = []
          GameData::Stat.each_main do |s|
            iv_commands[s.id] = s.name + " (#{pkmn.iv[s.id]})"
            stats.push(s.id)
            total_ivs += pkmn.iv[s.id]
          end
          iv_commands[:randomize] = _INTL("Randomize all")
          iv_cmd ||= iv_commands.keys.first
          hidden_power = pbHiddenPower(pkmn)
          msg = _INTL("Change which IV?\nHidden Power:\n{1}, power {2}\nTotal: {3}/{4} ({5}%)",
                      GameData::Type.get(hidden_power[0]).name, hidden_power[1], total_ivs,
                      stats.length * Pokemon::IV_STAT_LIMIT, 100 * total_ivs / (stats.length * Pokemon::IV_STAT_LIMIT))
          iv_cmd = screen.show_menu(msg, iv_commands, iv_commands.keys.index(iv_cmd))
          break if iv_cmd.nil?
          case iv_cmd
          when :randomize
            stats.each { |stat| pkmn.iv[stat] = rand(Pokemon::IV_STAT_LIMIT + 1) }
            pkmn.calc_stats
            screen.refresh
          else   # Set a particular stat's IVs
            params = ChooseNumberParams.new
            params.setRange(0, Pokemon::IV_STAT_LIMIT)
            params.setDefaultValue(pkmn.iv[iv_cmd])
            params.setCancelValue(pkmn.iv[iv_cmd])
            new_val = screen.choose_number("\\se[]" + _INTL("Set the IV for {1} (max. {2}).",
                                                            GameData::Stat.get(iv_cmd).name, params.maxNumber), params)
            if new_val != pkmn.iv[iv_cmd]
              pkmn.iv[iv_cmd] = new_val
              pkmn.calc_stats
              screen.refresh
            end
          end
        end
      when :random_pid
        pkmn.personalID = rand(2**16) | (rand(2**16) << 16)
        pkmn.calc_stats
        screen.refresh
      end
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :set_happiness, {
  "name"   => _INTL("Set happiness"),
  "parent" => :level_stats,
  "effect" => proc { |pkmn, party_index, setting_up_battle, screen|
    params = ChooseNumberParams.new
    params.setRange(0, 255)
    params.setDefaultValue(pkmn.happiness)
    new_val = screen.choose_number("\\se[]" + _INTL("Set the Pokémon's happiness (max. {1}).", params.maxNumber), params)
    if new_val != pkmn.happiness
      pkmn.happiness = new_val
      screen.refresh
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
  "effect" => proc { |pkmn, party_index, setting_up_battle, screen|
    params = ChooseNumberParams.new
    params.setRange(0, 255)
    params.setDefaultValue(pkmn.beauty)
    new_val = screen.choose_number("\\se[]" + _INTL("Set the Pokémon's Beauty (max. {1}).", params.maxNumber), params)
    if new_val != pkmn.beauty
      pkmn.beauty = new_val
      screen.refresh
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :set_cool, {
  "name"   => _INTL("Set Cool"),
  "parent" => :contest_stats,
  "effect" => proc { |pkmn, party_index, setting_up_battle, screen|
    params = ChooseNumberParams.new
    params.setRange(0, 255)
    params.setDefaultValue(pkmn.cool)
    new_val = screen.choose_number("\\se[]" + _INTL("Set the Pokémon's Cool (max. {1}).", params.maxNumber), params)
    if new_val != pkmn.cool
      pkmn.cool = new_val
      screen.refresh
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :set_cute, {
  "name"   => _INTL("Set Cute"),
  "parent" => :contest_stats,
  "effect" => proc { |pkmn, party_index, setting_up_battle, screen|
    params = ChooseNumberParams.new
    params.setRange(0, 255)
    params.setDefaultValue(pkmn.cute)
    new_val = screen.choose_number("\\se[]" + _INTL("Set the Pokémon's Cute (max. {1}).", params.maxNumber), params)
    if new_val != pkmn.cute
      pkmn.cute = new_val
      screen.refresh
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :set_smart, {
  "name"   => _INTL("Set Smart"),
  "parent" => :contest_stats,
  "effect" => proc { |pkmn, party_index, setting_up_battle, screen|
    params = ChooseNumberParams.new
    params.setRange(0, 255)
    params.setDefaultValue(pkmn.smart)
    new_val = screen.choose_number("\\se[]" + _INTL("Set the Pokémon's Smart (max. {1}).", params.maxNumber), params)
    if new_val != pkmn.smart
      pkmn.smart = new_val
      screen.refresh
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :set_tough, {
  "name"   => _INTL("Set Tough"),
  "parent" => :contest_stats,
  "effect" => proc { |pkmn, party_index, setting_up_battle, screen|
    params = ChooseNumberParams.new
    params.setRange(0, 255)
    params.setDefaultValue(pkmn.tough)
    new_val = screen.choose_number("\\se[]" + _INTL("Set the Pokémon's Tough (max. {1}).", params.maxNumber), params)
    if new_val != pkmn.tough
      pkmn.tough = new_val
      screen.refresh
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :set_sheen, {
  "name"   => _INTL("Set Sheen"),
  "parent" => :contest_stats,
  "effect" => proc { |pkmn, party_index, setting_up_battle, screen|
    params = ChooseNumberParams.new
    params.setRange(0, 255)
    params.setDefaultValue(pkmn.sheen)
    new_val = screen.choose_number("\\se[]" + _INTL("Set the Pokémon's Sheen (max. {1}).", params.maxNumber), params)
    if new_val != pkmn.sheen
      pkmn.sheen = new_val
      screen.refresh
    end
    next false
  }
})

#===============================================================================
# Moves options.
#===============================================================================

MenuHandlers.add(:pokemon_debug_menu, :moves, {
  "name"   => _INTL("Moves..."),
  "parent" => :main
})

MenuHandlers.add(:pokemon_debug_menu, :teach_move, {
  "name"   => _INTL("Teach move"),
  "parent" => :moves,
  "effect" => proc { |pkmn, party_index, setting_up_battle, screen|
    move = pbChooseMoveList
    if move
      pbLearnMove(pkmn, move)
      screen.refresh
    else
      pbPlayCancelSE
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :forget_move, {
  "name"   => _INTL("Forget move"),
  "parent" => :moves,
  "effect" => proc { |pkmn, party_index, setting_up_battle, screen|
    move_index = screen.choose_move(pkmn, _INTL("Choose move to forget."))
    if move_index >= 0
      move_name = pkmn.moves[move_index].name
      pkmn.forget_move_at_index(move_index)
      screen.refresh
      screen.show_message(_INTL("{1} forgot {2}.", pkmn.name, move_name))
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :reset_moves, {
  "name"   => _INTL("Reset moves"),
  "parent" => :moves,
  "effect" => proc { |pkmn, party_index, setting_up_battle, screen|
    pkmn.reset_moves
    screen.refresh
    screen.show_message(_INTL("{1}'s moves were reset.", pkmn.name))
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :set_move_pp, {
  "name"   => _INTL("Set move PP..."),
  "parent" => :moves,
  "effect" => proc { |pkmn, party_index, setting_up_battle, screen|
    cmd = nil
    loop do
      commands = {}
      pkmn.moves.each_with_index do |move, i|
        break if !move.id
        if move.total_pp <= 0
          commands[i] = _INTL("{1} (PP: ---)", move.name)
        else
          commands[i] = _INTL("{1} (PP: {2}/{3})", move.name, move.pp, move.total_pp)
        end
      end
      commands[:restore_pp] = _INTL("[Restore all PP]")
      cmd ||= commands.keys.first
      cmd = screen.show_menu(_INTL("Alter PP of which move?"), commands, commands.keys.index(cmd))
      break if cmd.nil?
      if cmd == :restore_pp
        pkmn.heal_PP
      elsif pkmn.moves[cmd].total_pp <= 0
        screen.show_message(_INTL("{1} has infinite PP.", pkmn.moves[cmd].name))
      else
        move = pkmn.moves[cmd]
        pp_commands = {
          :set_pp  => _INTL("Set PP"),
          :full_pp => _INTL("Full PP"),
          :pp_up   => _INTL("Set PP Up")
        }
        pp_cmd = pp_commands.keys.first
        loop do
          msg = _INTL("{1}: PP {2}/{3} (PP Up {4}/3)", move.name, move.pp, move.total_pp, move.ppup)
          pp_cmd = screen.show_menu(msg, pp_commands, pp_commands.keys.index(pp_cmd))
          break if pp_cmd.nil?
          case pp_cmd
          when :set_pp
            params = ChooseNumberParams.new
            params.setRange(0, move.total_pp)
            params.setDefaultValue(move.pp)
            move.pp = screen.choose_number("\\se[]" + _INTL("Set PP of {1} (max. {2}).", move.name, params.maxNumber), params)
          when :full_pp
            move.pp = move.total_pp
          when :pp_up
            params = ChooseNumberParams.new
            params.setRange(0, 3)
            params.setDefaultValue(move.ppup)
            new_val = screen.choose_number("\\se[]" + _INTL("Set PP Up of {1} (max. {2}).", move.name, params.maxNumber), params)
            move.ppup = new_val
          end
        end
      end
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :set_initial_moves, {
  "name"   => _INTL("Reset initial moves"),
  "parent" => :moves,
  "effect" => proc { |pkmn, party_index, setting_up_battle, screen|
    pkmn.record_first_moves
    screen.refresh
    screen.show_message(_INTL("{1}'s current moves were set as its first-known moves.", pkmn.name))
    next false
  }
})

#===============================================================================
# Other options.
#===============================================================================

MenuHandlers.add(:pokemon_debug_menu, :set_item, {
  "name"   => _INTL("Set item"),
  "parent" => :main,
  "effect" => proc { |pkmn, party_index, setting_up_battle, screen|
    commands = {
      :change_item => _INTL("Change item"),
      :delete_item => _INTL("Remove item")
    }
    cmd = commands.keys.first
    loop do
      msg = (pkmn.hasItem?) ? _INTL("Item is {1}.", pkmn.item.name) : _INTL("No item.")
      cmd = screen.show_menu(msg, commands, commands.keys.index(cmd))
      break if cmd.nil?
      case cmd
      when :change_item
        item = pbChooseItemList(pkmn.item_id)
        if item && item != pkmn.item_id
          pbPlayDecisionSE
          pkmn.item = item
          pkmn.mail = Mail.new(item, _INTL("Text"), $player.name) if GameData::Item.get(item).is_mail?
          screen.refresh
        else
          pbPlayCancelSE
        end
      when :delete_item
        if pkmn.hasItem?
          pkmn.item = nil
          screen.refresh
        end
      end
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :set_ability, {
  "name"   => _INTL("Set ability"),
  "parent" => :main,
  "effect" => proc { |pkmn, party_index, setting_up_battle, screen|
    commands = {
      :set_ability_index => _INTL("Set possible ability"),
      :give_any_ability  => _INTL("Set any ability"),
      :reset_ability     => _INTL("Reset")
    }
    cmd = commands.keys.first
    loop do
      if pkmn.ability
        msg = _INTL("Ability is {1} (index {2}).", pkmn.ability.name, pkmn.ability_index)
      else
        msg = _INTL("No ability (index {1}).", pkmn.ability_index)
      end
      cmd = screen.show_menu(msg, commands, commands.keys.index(cmd))
      break if cmd.nil?
      case cmd
      when :set_ability_index
        abils = pkmn.getAbilityList
        ability_commands = {}
        abil_cmd = nil
        abils.each do |abil|
          ability_commands[abil[1]] = ((abil[1] < 2) ? "" : "(H) ") + GameData::Ability.get(abil[0]).name
          abil_cmd = abil[1] if pkmn.ability_id == abil[0]
        end
        abil_cmd ||= ability_commands.keys.first
        abil_cmd = screen.show_menu(_INTL("Choose an ability."), ability_commands, ability_commands.keys.index(abil_cmd))
        next if abil_cmd.nil?
        pkmn.ability_index = abil_cmd
        pkmn.ability = nil
        screen.refresh
      when :give_any_ability
        new_ability = pbChooseAbilityList(pkmn.ability_id)
        if new_ability && new_ability != pkmn.ability_id
          pbPlayDecisionSE
          pkmn.ability = new_ability
          screen.refresh
        else
          pbPlayCancelSE
        end
      when :reset_ability
        pkmn.ability_index = nil
        pkmn.ability = nil
        screen.refresh
      end
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :set_nature, {
  "name"   => _INTL("Set nature"),
  "parent" => :main,
  "effect" => proc { |pkmn, party_index, setting_up_battle, screen|
    commands = {}
    GameData::Nature.each do |nature|
      if nature.stat_changes.length == 0
        commands[nature.id] = _INTL("{1} (---)", nature.real_name)
        next
      end
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
      commands[nature.id] = _INTL("{1} (+{2}, -{3})", nature.real_name, plus_text, minus_text)
    end
    commands[:reset_nature] = _INTL("[Reset]")
    cmd = (commands.keys.include?(pkmn.nature_id)) ? pkmn.nature_id : commands.keys.first
    loop do
      cmd = screen.show_menu(_INTL("Nature is {1}.", pkmn.nature.name), commands, commands.keys.index(cmd))
      break if cmd.nil?
      pkmn.nature = (cmd == :reset_nature) ? nil : cmd
      screen.refresh
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :set_gender, {
  "name"   => _INTL("Set gender"),
  "parent" => :main,
  "effect" => proc { |pkmn, party_index, setting_up_battle, screen|
    if pkmn.singleGendered?
      screen.show_message(_INTL("{1} is single-gendered or genderless.", pkmn.speciesName))
      next false
    end
    commands = {
      :make_male    => _INTL("Make male"),
      :make_female  => _INTL("Make female"),
      :reset_gender => _INTL("Reset")
    }
    cmd = commands.keys.first
    loop do
      msg = _INTL("Unknown gender.")
      msg = _INTL("Gender is male.") if pkmn.male?
      msg = _INTL("Gender is female.") if pkmn.female?
      cmd = screen.show_menu(msg, commands, commands.keys.index(cmd))
      break if cmd.nil?
      case cmd
      when :make_male
        pkmn.makeMale
        screen.show_message(_INTL("{1}'s gender couldn't be changed.", pkmn.name)) if !pkmn.male?
      when :make_female
        pkmn.makeFemale
        screen.show_message(_INTL("{1}'s gender couldn't be changed.", pkmn.name)) if !pkmn.female?
      when :reset_gender
        pkmn.gender = nil
      end
      $player.pokedex.register(pkmn) if !setting_up_battle && !pkmn.egg?
      screen.refresh
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :species_and_form, {
  "name"   => _INTL("Species/form..."),
  "parent" => :main,
  "effect" => proc { |pkmn, party_index, setting_up_battle, screen|
    commands = {
      :set_species => _INTL("Set species"),
      :set_form    => _INTL("Set form"),
      :reset_form  => _INTL("Remove form override")
    }
    cmd = commands.keys.first
    loop do
      msg = [_INTL("Species {1}, form {2}.", pkmn.speciesName, pkmn.form),
             _INTL("Species {1}, form {2} (forced).", pkmn.speciesName, pkmn.form)][(pkmn.forced_form.nil?) ? 0 : 1]
      cmd = screen.show_menu(msg, commands, commands.keys.index(cmd))
      break if cmd.nil?
      case cmd
      when :set_species
        species = pbChooseSpeciesList(pkmn.species)
        if species && species != pkmn.species
          pbPlayDecisionSE
          pkmn.species = species
          pkmn.gender = nil
          pkmn.calc_stats
          $player.pokedex.register(pkmn) if !setting_up_battle && !pkmn.egg?
          screen.refresh
        else
          pbPlayCancelSE
        end
      when :set_form
        # TODO: Allow setting any form number for any species.
        form_cmd = 0
        form_commands = {}
        GameData::Species.each do |sp|
          next if sp.species != pkmn.species
          form_name = sp.form_name
          form_name = _INTL("Unnamed form") if !form_name || form_name.empty?
          form_name = sprintf("%d: %s", sp.form, form_name)
          form_commands[sp.form] = form_name
          form_cmd = sp.form if pkmn.form == sp.form
        end
        if form_commands.length <= 1
          screen.show_message(_INTL("Species {1} only has one form.", pkmn.speciesName))
          if pkmn.form != 0 && screen.show_confirm_message(_INTL("Do you want to reset the form to 0?"))
            pkmn.form = 0
            $player.pokedex.register(pkmn) if !setting_up_battle && !pkmn.egg?
            screen.refresh
          end
        else
          form_cmd = screen.show_menu(_INTL("Set the Pokémon's form."), form_commands, form_commands.keys.index(form_cmd))
          next if form_cmd.nil?
          if form_cmd != pkmn.form
            if MultipleForms.hasFunction?(pkmn, "getForm")
              next if !screen.show_confirm_message(_INTL("This species decides its own form. Override?"))
              pkmn.forced_form = form_cmd
            end
            pkmn.form = form_cmd
            $player.pokedex.register(pkmn) if !setting_up_battle && !pkmn.egg?
            screen.refresh
          end
        end
      when :reset_form
        pkmn.forced_form = nil
        screen.refresh
      end
    end
    next false
  }
})

#===============================================================================
# Cosmetic options.
#===============================================================================

MenuHandlers.add(:pokemon_debug_menu, :cosmetic, {
  "name"   => _INTL("Cosmetic info..."),
  "parent" => :main
})

MenuHandlers.add(:pokemon_debug_menu, :set_shininess, {
  "name"   => _INTL("Set shininess"),
  "parent" => :cosmetic,
  "effect" => proc { |pkmn, party_index, setting_up_battle, screen|
    commands = {
      :make_shiny       => _INTL("Make shiny"),
      :make_super_shiny => _INTL("Make super shiny"),
      :make_not_shiny   => _INTL("Make normal"),
      :reset_shininess  => _INTL("Reset")
    }
    cmd = commands.keys.first
    loop do
      msg_idx = pkmn.shiny? ? (pkmn.super_shiny? ? 1 : 0) : 2
      msg = [_INTL("Is shiny."), _INTL("Is super shiny."), _INTL("Is normal (not shiny).")][msg_idx]
      cmd = screen.show_menu(msg, commands, commands.keys.index(cmd))
      break if cmd.nil?
      case cmd
      when :make_shiny
        pkmn.shiny = true
        pkmn.super_shiny = false
      when :make_super_shiny
        pkmn.super_shiny = true
      when :make_not_shiny
        pkmn.shiny = false
        pkmn.super_shiny = false
      when :reset_shininess
        pkmn.shiny = nil
        pkmn.super_shiny = nil
      end
      $player.pokedex.register(pkmn) if !setting_up_battle && !pkmn.egg?
      screen.refresh
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :set_pokeball, {
  "name"   => _INTL("Set Poké Ball"),
  "parent" => :cosmetic,
  "effect" => proc { |pkmn, party_index, setting_up_battle, screen|
    commands = {}
    cmd = nil
    GameData::Item.each do |item|
      next if !item.is_poke_ball?
      commands[item.id] = item.name
      cmd = item.id if item.id == pkmn.poke_ball
    end
    commands = commands.sort_by { |key, val| val }.to_h
    cmd ||= commands.keys.first
    loop do
      cmd = screen.show_menu(_INTL("{1} used.", GameData::Item.get(pkmn.poke_ball).name), commands, commands.keys.index(cmd))
      break if cmd.nil?
      pkmn.poke_ball = cmd
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :set_ribbons, {
  "name"   => _INTL("Set ribbons"),
  "parent" => :cosmetic,
  "effect" => proc { |pkmn, party_index, setting_up_battle, screen|
    cmd = nil
    loop do
      commands = {}
      GameData::Ribbon.each do |ribbon|
        commands[ribbon.id] = (pkmn.hasRibbon?(ribbon.id) ? "[Y]" : "[  ]") + " " + ribbon.name
      end
      commands[:give_all]  = _INTL("Give all")
      commands[:clear_all] = _INTL("Clear all")
      cmd ||= commands.keys.first
      cmd = screen.show_menu(_INTL("{1} ribbons.", pkmn.numRibbons), commands, commands.keys.index(cmd))
      break if cmd.nil?
      case cmd
      when :give_all
        GameData::Ribbon.each { |ribbon| pkmn.giveRibbon(ribbon.id) }
      when :clear_all
        pkmn.clearAllRibbons
      else   # Toggle a specific ribbon
        pkmn.hasRibbon?(cmd) ? pkmn.takeRibbon(cmd) : pkmn.giveRibbon(cmd)
      end
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :set_nickname, {
  "name"   => _INTL("Set nickname"),
  "parent" => :cosmetic,
  "effect" => proc { |pkmn, party_index, setting_up_battle, screen|
    commands = {
      :rename     => _INTL("Rename"),
      :clear_name => _INTL("Erase name")
    }
    cmd = commands.keys.first
    loop do
      species_name = pkmn.speciesName
      msg = [_INTL("{1} has the nickname {2}.", species_name, pkmn.name),
             _INTL("{1} has no nickname.", species_name)][pkmn.nicknamed? ? 0 : 1]
      cmd = screen.show_menu(msg, commands, commands.keys.index(cmd))
      break if cmd.nil?
      case cmd
      when :rename
        old_name = (pkmn.nicknamed?) ? pkmn.name : ""
        pkmn.name = pbEnterPokemonName(_INTL("{1}'s nickname?", species_name),
                                       0, Pokemon::MAX_NAME_SIZE, old_name, pkmn)
      when :clear_name
        pkmn.name = nil
      end
      screen.refresh
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :ownership, {
  "name"   => _INTL("Ownership..."),
  "parent" => :cosmetic,
  "effect" => proc { |pkmn, party_index, setting_up_battle, screen|
    commands = {
      :make_players      => _INTL("Make player's"),
      :set_ot_name       => _INTL("Set OT's name"),
      :set_ot_gender     => _INTL("Set OT's gender"),
      :random_foreign_id => _INTL("Random foreign ID"),
      :set_id            => _INTL("Set foreign ID")
    }
    cmd = commands.keys.first
    loop do
      gender_text = _INTL("Unknown gender")
      gender_text = _INTL("Male") if pkmn.owner.male?
      gender_text = _INTL("Female") if pkmn.owner.female?
      public_id_text = sprintf("%05d", pkmn.owner.public_id)
      msg = [_INTL("Player's Pokémon\n{1}\n{2}\n{3} ({4})",
                   pkmn.owner.name, gender_text, public_id_text, pkmn.owner.id),
             _INTL("Foreign Pokémon\n{1}\n{2}\n{3} ({4})",
                   pkmn.owner.name, gender_text, public_id_text, pkmn.owner.id)][pkmn.foreign?($player) ? 1 : 0]
      cmd = screen.show_menu(msg, commands, commands.keys.index(cmd))
      break if cmd.nil?
      case cmd
      when :make_players
        pkmn.owner = Pokemon::Owner.new_from_trainer($player)
      when :set_ot_name
        pkmn.owner.name = pbEnterPlayerName(_INTL("{1}'s OT's name?", pkmn.name), 1, Settings::MAX_PLAYER_NAME_SIZE, pkmn.owner.name)
      when :set_ot_gender
        gender_commands = {
          0 => _INTL("Male"),
          1 => _INTL("Female"),
          2 => _INTL("Unknown")
        }
        gender_cmd = gender_commands.keys.index(pkmn.owner.gender) || gender_commands.keys.first
        gender_cmd = screen.show_menu(_INTL("Set OT's gender."), gender_commands, gender_cmd)
        pkmn.owner.gender = gender_cmd if gender_cmd
      when :random_foreign_id
        pkmn.owner.id = $player.make_foreign_ID
      when :set_id
        params = ChooseNumberParams.new
        params.setRange(0, 65_535)
        params.setDefaultValue(pkmn.owner.public_id)
        new_val = screen.choose_number("\\se[]" + _INTL("Set the new ID (max. {1}).", params.maxNumber), params)
        pkmn.owner.id = new_val | (new_val << 16)
      end
    end
    next false
  }
})

#===============================================================================
# Can store/release/trade.
#===============================================================================

MenuHandlers.add(:pokemon_debug_menu, :set_discardable, {
  "name"   => _INTL("Set discardable"),
  "parent" => :main,
  "effect" => proc { |pkmn, party_index, setting_up_battle, screen|
    cmd = nil
    loop do
      commands = {
        :store   => (pkmn.cannot_store) ? _INTL("Cannot store") : _INTL("Can store"),
        :release => (pkmn.cannot_release) ? _INTL("Cannot release") : _INTL("Can release"),
        :trade   => (pkmn.cannot_trade) ? _INTL("Cannot trade") : _INTL("Can trade")
      }
      cmd ||= commands.keys.first
      cmd = screen.show_menu(_INTL("Click option to toggle."), commands, commands.keys.index(cmd))
      break if cmd.nil?
      case cmd
      when :store
        pkmn.cannot_store = !pkmn.cannot_store
      when :release
        pkmn.cannot_release = !pkmn.cannot_release
      when :trade
        pkmn.cannot_trade = !pkmn.cannot_trade
      end
    end
    next false
  }
})

#===============================================================================
# Other options.
#===============================================================================

MenuHandlers.add(:pokemon_debug_menu, :set_egg, {
  "name"        => _INTL("Set egg"),
  "parent"      => :main,
  "always_show" => false,
  "effect"      => proc { |pkmn, party_index, setting_up_battle, screen|
    commands = {
      :make_egg     => _INTL("Make egg"),
      :make_pokemon => _INTL("Make Pokémon"),
      :one_egg_step => _INTL("Set steps left to 1")
    }
    cmd = commands.keys.first
    loop do
      msg = [_INTL("Not an egg."),
             _INTL("Egg (hatches in {1} steps).", pkmn.steps_to_hatch)][pkmn.egg? ? 1 : 0]
      cmd = screen.show_menu(msg, commands, commands.keys.index(cmd))
      break if cmd.nil?
      case cmd
      when :make_egg
        if !pkmn.egg? && (pbHasEgg?(pkmn.species) ||
           screen.show_confirm_message(_INTL("{1} cannot legally be an egg. Make egg anyway?", pkmn.speciesName)))
          pkmn.level          = Settings::EGG_LEVEL
          pkmn.calc_stats
          pkmn.name           = _INTL("Egg")
          pkmn.steps_to_hatch = pkmn.species_data.hatch_steps
          pkmn.hatched_map    = 0
          pkmn.obtain_method  = 1
          screen.refresh
        end
      when :make_pokemon
        if pkmn.egg?
          pkmn.name           = nil
          pkmn.steps_to_hatch = 0
          pkmn.hatched_map    = 0
          pkmn.obtain_method  = 0
          $player.pokedex.register(pkmn) if !setting_up_battle
          screen.refresh
        end
      when :one_egg_step
        pkmn.steps_to_hatch = 1 if pkmn.egg?
      end
    end
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :shadow_pkmn, {
  "name"   => _INTL("Shadow Pkmn..."),
  "parent" => :main,
  "effect" => proc { |pkmn, party_index, setting_up_battle, screen|
    # TODO: Option to make not a Shadow Pokémon.
    commands = {
      :make_shadow     => _INTL("Make Shadow"),
      :set_heart_gauge => _INTL("Set heart gauge")
    }
    cmd = commands.keys.first
    loop do
      msg = [_INTL("Not a Shadow Pokémon."),
             _INTL("Heart gauge is {1} (stage {2}).", pkmn.heart_gauge, pkmn.heartStage)][pkmn.shadowPokemon? ? 1 : 0]
      cmd = screen.show_menu(msg, commands, commands.keys.index(cmd))
      break if cmd.nil?
      case cmd
      when :make_shadow
        if pkmn.shadowPokemon?
          screen.show_message(_INTL("{1} is already a Shadow Pokémon.", pkmn.name))
        else
          pkmn.makeShadow
          screen.refresh
        end
      when :set_heart_gauge
        if pkmn.shadowPokemon?
          params = ChooseNumberParams.new
          params.setRange(0, pkmn.max_gauge_size)
          params.setDefaultValue(pkmn.heart_gauge)
          new_val = screen.choose_number("\\se[]" + _INTL("Set the heart gauge (max. {1}).", params.maxNumber), params)
          if new_val != pkmn.heart_gauge
            pkmn.adjustHeart(new_val - pkmn.heart_gauge)
            pkmn.check_ready_to_purify
          end
        else
          screen.show_message(_INTL("{1} is not a Shadow Pokémon.", pkmn.name))
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
  "effect"      => proc { |pkmn, party_index, setting_up_battle, screen|
    pbCreateMysteryGift(0, pkmn)
    next false
  }
})

MenuHandlers.add(:pokemon_debug_menu, :duplicate, {
  "name"        => _INTL("Duplicate"),
  "parent"      => :main,
  "always_show" => false,
  "effect"      => proc { |pkmn, party_index, setting_up_battle, screen|
    next false if !screen.show_confirm_message(_INTL("Are you sure you want to copy this Pokémon?"))
    cloned_pkmn = pkmn.clone
    case screen
    when UI::Party
      pbStorePokemon(cloned_pkmn)   # Add to party, or to storage if party is full
      screen.refresh_party
      screen.refresh
    when UI::PokemonStorage
      if screen.storage.pbMoveCaughtToParty(cloned_pkmn)
        screen.show_message(_INTL("The duplicated Pokémon was moved to your party.")) if party_index[0] >= 0
      else
        old_box = screen.storage.currentBox
        new_box = screen.storage.pbStoreCaught(cloned_pkmn)
        if new_box < 0
          screen.show_message(_INTL("All boxes are full."))
        elsif new_box != old_box
          screen.show_message(_INTL("The duplicated Pokémon was moved to box \"{1}.\"", screen.storage[new_box].name))
          screen.storage.currentBox = old_box
        end
      end
      screen.refresh
    end
    next true
  }
})

MenuHandlers.add(:pokemon_debug_menu, :delete, {
  "name"        => _INTL("Delete"),
  "parent"      => :main,
  "always_show" => false,
  "effect"      => proc { |pkmn, party_index, setting_up_battle, screen|
    next false if !screen.show_confirm_message(_INTL("Are you sure you want to delete this Pokémon?"))
    case screen
    when UI::Party
      screen.party.delete_at(party_index)
      screen.refresh_party
    when UI::PokemonStorage
      screen.visuals.release_pokemon(true)
      screen.storage.pbDelete(party_index[0], party_index[1]) if !screen.holding_pokemon?
    end
    screen.refresh
    next true
  }
})
