=begin
# TODO:

Trigger ability (probably not)
Some stuff relating to Shadow Pokémon?
Actual stats? @attack, @defense, etc.
@turnCount

=end

#===============================================================================
#
#===============================================================================
module BattlerDebugMenuCommands
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
# HP/Status options
#===============================================================================
BattlerDebugMenuCommands.register("hpstatusmenu", {
  "parent"      => "main",
  "name"        => _INTL("HP/Status..."),
  "always_show" => true
})

BattlerDebugMenuCommands.register("sethp", {
  "parent"      => "hpstatusmenu",
  "name"        => _INTL("Set HP"),
  "always_show" => true,
  "effect"      => proc { |battler, pkmn, battle|
    if pkmn.egg?
      pbMessage("\\ts[]" + _INTL("{1} is an egg.", pkmn.name))
      next
    elsif battler.totalhp == 1
      pbMessage("\\ts[]" + _INTL("Can't change HP, {1}'s maximum HP is 1.", pkmn.name))
      next
    end
    params = ChooseNumberParams.new
    params.setRange(1, battler.totalhp)
    params.setDefaultValue(battler.hp)
    new_hp = pbMessageChooseNumber(
      "\\ts[]" + _INTL("Set {1}'s HP (1-{2}).", battler.pbThis(true), battler.totalhp), params
    )
    battler.hp = new_hp if new_hp != battler.hp
  }
})

BattlerDebugMenuCommands.register("setstatus", {
  "parent"      => "hpstatusmenu",
  "name"        => _INTL("Set status"),
  "always_show" => true,
  "effect"      => proc { |battler, pkmn, battle|
    if pkmn.egg?
      pbMessage("\\ts[]" + _INTL("{1} is an egg.", pkmn.name))
      next
    elsif pkmn.hp <= 0
      pbMessage("\\ts[]" + _INTL("{1} is fainted, can't change status.", pkmn.name))
      next
    end
    cmd = 0
    commands = [_INTL("[Cure]")]
    ids = [:NONE]
    GameData::Status.each do |s|
      next if s.id == :NONE
      commands.push(_INTL("Set {1}", s.name))
      ids.push(s.id)
    end
    loop do
      msg = _INTL("Current status: {1}", GameData::Status.get(battler.status).name)
      if battler.status == :SLEEP
        msg += " " + _INTL("(turns: {1})", battler.statusCount)
      elsif battler.status == :POISON && battler.statusCount > 0
        msg += " " + _INTL("(toxic, count: {1})", battler.statusCount)
      end
      cmd = pbMessage("\\ts[]" + msg, commands, -1, nil, cmd)
      break if cmd < 0
      case cmd
      when 0   # Cure
        battler.status = :NONE
      else   # Give status problem
        case ids[cmd]
        when :SLEEP
          params = ChooseNumberParams.new
          params.setRange(0, 99)
          params.setDefaultValue((battler.status == :SLEEP) ? battler.statusCount : 3)
          params.setCancelValue(-1)
          count = pbMessageChooseNumber("\\ts[]" + _INTL("Set {1}'s sleep count (0-99).", battler.pbThis(true)), params)
          next if count < 0
          battler.statusCount = count
        when :POISON
          if pbConfirmMessage("\\ts[]" + _INTL("Make {1} badly poisoned (toxic)?", battler.pbThis(true)))
            params = ChooseNumberParams.new
            params.setRange(0, 15)
            params.setDefaultValue(0)
            params.setCancelValue(-1)
            count = pbMessageChooseNumber(
              "\\ts[]" + _INTL("Set {1}'s toxic count (0-15).", battler.pbThis(true)), params
            )
            next if count < 0
            battler.statusCount = 1
            battler.effects[PBEffects::Toxic] = count
          else
            battler.statusCount = 0
          end
        end
        battler.status = ids[cmd]
      end
    end
  }
})

BattlerDebugMenuCommands.register("fullheal", {
  "parent"      => "hpstatusmenu",
  "name"        => _INTL("Heal HP and status"),
  "always_show" => true,
  "effect"      => proc { |battler, pkmn, battle|
    if pkmn.egg?
      pbMessage("\\ts[]" + _INTL("{1} is an egg.", pkmn.name))
      next
    end
    battler.hp = battler.totalhp
    battler.status = :NONE
  }
})

#===============================================================================
# Level/stats options
#===============================================================================
BattlerDebugMenuCommands.register("levelstats", {
  "parent"      => "main",
  "name"        => _INTL("Stats/level..."),
  "always_show" => true
})

BattlerDebugMenuCommands.register("setstatstages", {
  "parent"      => "levelstats",
  "name"        => _INTL("Set stat stages"),
  "always_show" => true,
  "effect"      => proc { |battler, pkmn, battle|
    if pkmn.egg?
      pbMessage("\\ts[]" + _INTL("{1} is an egg.", pkmn.name))
      next
    end
    cmd = 0
    loop do
      commands = []
      stat_ids = []
      GameData::Stat.each_battle do |stat|
        command_name = stat.name + ": "
        command_name += "+" if battler.stages[stat.id] > 0
        command_name += battler.stages[stat.id].to_s
        commands.push(command_name)
        stat_ids.push(stat.id)
      end
      commands.push(_INTL("[Reset all]"))
      cmd = pbMessage("\\ts[]" + _INTL("Choose a stat stage to change."), commands, -1, nil, cmd)
      break if cmd < 0
      if cmd < stat_ids.length   # Set a stat
        params = ChooseNumberParams.new
        params.setRange(-6, 6)
        params.setNegativesAllowed(true)
        params.setDefaultValue(battler.stages[stat_ids[cmd]])
        value = pbMessageChooseNumber(
          "\\ts[]" + _INTL("Set the stage for {1}.", GameData::Stat.get(stat_ids[cmd]).name), params
        )
        battler.stages[stat_ids[cmd]] = value
      else   # Reset all stats
        GameData::Stat.each_battle { |stat| battler.stages[stat.id] = 0 }
      end
    end
  }
})

BattlerDebugMenuCommands.register("setlevel", {
  "parent"      => "levelstats",
  "name"        => _INTL("Set level"),
  "always_show" => true,
  "effect"      => proc { |battler, pkmn, battle|
    if pkmn.egg?
      pbMessage("\\ts[]" + _INTL("{1} is an egg.", pkmn.name))
      next
    end
    params = ChooseNumberParams.new
    params.setRange(1, GameData::GrowthRate.max_level)
    params.setDefaultValue(pkmn.level)
    level = pbMessageChooseNumber(
      "\\ts[]" + _INTL("Set the Pokémon's level (max. {1}).", params.maxNumber), params
    )
    if level != pkmn.level
      pkmn.level = level
      pkmn.calc_stats
      battler.pbUpdate
    end
  }
})

BattlerDebugMenuCommands.register("setexp", {
  "parent"      => "levelstats",
  "name"        => _INTL("Set Exp"),
  "always_show" => true,
  "effect"      => proc { |battler, pkmn, battle|
    if pkmn.egg?
      pbMessage("\\ts[]" + _INTL("{1} is an egg.", pkmn.name))
      next
    end
    min_exp = pkmn.growth_rate.minimum_exp_for_level(pkmn.level)
    max_exp = pkmn.growth_rate.minimum_exp_for_level(pkmn.level + 1)
    if min_exp == max_exp
      pbMessage("\\ts[]" + _INTL("{1} is at the maximum level.", pkmn.name))
      next
    end
    params = ChooseNumberParams.new
    params.setRange(min_exp, max_exp - 1)
    params.setDefaultValue(pkmn.exp)
    new_exp = pbMessageChooseNumber(
      "\\ts[]" + _INTL("Set the Pokémon's Exp (range {1}-{2}).", min_exp, max_exp - 1), params
    )
    pkmn.exp = new_exp if new_exp != pkmn.exp
  }
})

BattlerDebugMenuCommands.register("hiddenvalues", {
  "parent"      => "levelstats",
  "name"        => _INTL("EV/IV..."),
  "always_show" => true,
  "effect"      => proc { |battler, pkmn, battle|
    cmd = 0
    loop do
      persid = sprintf("0x%08X", pkmn.personalID)
      cmd = pbMessage("\\ts[]" + _INTL("Personal ID is {1}.", persid),
                      [_INTL("Set EVs"), _INTL("Set IVs")], -1, nil, cmd)
      break if cmd < 0
      case cmd
      when 0   # Set EVs
        cmd2 = 0
        loop do
          total_evs = 0
          ev_commands = []
          ev_id = []
          GameData::Stat.each_main do |s|
            ev_commands.push(s.name + " (#{pkmn.ev[s.id]})")
            ev_id.push(s.id)
            total_evs += pkmn.ev[s.id]
          end
          ev_commands.push(_INTL("Randomise all"))
          ev_commands.push(_INTL("Max randomise all"))
          cmd2 = pbMessage("\\ts[]" + _INTL("Change which EV?\nTotal: {1}/{2} ({3}%)",
                                            total_evs, Pokemon::EV_LIMIT, 100 * total_evs / Pokemon::EV_LIMIT),
                           ev_commands, -1, nil, cmd2)
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
            f = pbMessageChooseNumber("\\ts[]" + _INTL("Set the EV for {1} (max. {2}).",
                                                       GameData::Stat.get(ev_id[cmd2]).name, upperLimit), params)
            if f != pkmn.ev[ev_id[cmd2]]
              pkmn.ev[ev_id[cmd2]] = f
              pkmn.calc_stats
              battler.pbUpdate
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
            battler.pbUpdate
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
          cmd2 = pbMessage("\\ts[]" + msg, ivcommands, -1, nil, cmd2)
          break if cmd2 < 0
          if cmd2 < iv_id.length
            params = ChooseNumberParams.new
            params.setRange(0, Pokemon::IV_STAT_LIMIT)
            params.setDefaultValue(pkmn.iv[iv_id[cmd2]])
            params.setCancelValue(pkmn.iv[iv_id[cmd2]])
            f = pbMessageChooseNumber("\\ts[]" + _INTL("Set the IV for {1} (max. 31).",
                                                       GameData::Stat.get(iv_id[cmd2]).name), params)
            if f != pkmn.iv[iv_id[cmd2]]
              pkmn.iv[iv_id[cmd2]] = f
              pkmn.calc_stats
              battler.pbUpdate
            end
          else   # Randomise all
            GameData::Stat.each_main { |s| pkmn.iv[s.id] = rand(Pokemon::IV_STAT_LIMIT + 1) }
            pkmn.calc_stats
            battler.pbUpdate
          end
        end
      end
    end
  }
})

BattlerDebugMenuCommands.register("sethappiness", {
  "parent"      => "levelstats",
  "name"        => _INTL("Set happiness"),
  "always_show" => true,
  "effect"      => proc { |battler, pkmn, battle|
    params = ChooseNumberParams.new
    params.setRange(0, 255)
    params.setDefaultValue(pkmn.happiness)
    h = pbMessageChooseNumber("\\ts[]" + _INTL("Set the Pokémon's happiness (max. 255)."), params)
    pkmn.happiness = h if h != pkmn.happiness
  }
})

#===============================================================================
# Types
#===============================================================================
BattlerDebugMenuCommands.register("settypes", {
  "parent"      => "main",
  "name"        => _INTL("Set types"),
  "always_show" => true,
  "effect"      => proc { |battler, pkmn, battle|
    max_main_types = 2   # The most types a Pokémon can have normally
    cmd = 0
    loop do
      commands = []
      types = []
      (0...max_main_types).each do |i|
        type = battler.types[i]
        type_name = (type) ? GameData::Type.get(type).name : "-"
        commands.push(_INTL("Type {1}: {2}", i + 1, type_name))
        types.push(type)
      end
      extra_type = battler.effects[PBEffects::Type3]
      extra_type_name = (extra_type) ? GameData::Type.get(extra_type).name : "-"
      commands.push(_INTL("Extra type: {1}", extra_type_name))
      types.push(extra_type)
      msg = _INTL("Effective types: {1}", battler.pbTypes(true).map { |t| GameData::Type.get(t).name }.join("/"))
      msg += "\r\n" + _INTL("(Change a type to itself to remove it.)")
      cmd = pbMessage("\\ts[]" + msg, commands, -1, nil, cmd)
      break if cmd < 0
      old_type = types[cmd]
      new_type = pbChooseTypeList(old_type)
      if new_type
        if new_type == old_type
          if pbConfirmMessage(_INTL("Remove this type?"))
            if cmd < max_main_types
              battler.types[cmd] = nil
            else
              battler.effects[PBEffects::Type3] = nil
            end
            battler.types.compact!
          end
        else
          if cmd < max_main_types
            battler.types[cmd] = new_type
          else
            battler.effects[PBEffects::Type3] = new_type
          end
        end
      end
    end
  }
})

#===============================================================================
# Moves options
#===============================================================================
BattlerDebugMenuCommands.register("moves", {
  "parent"      => "main",
  "name"        => _INTL("Moves..."),
  "always_show" => true
})

BattlerDebugMenuCommands.register("teachmove", {
  "parent"      => "moves",
  "name"        => _INTL("Teach move"),
  "always_show" => true,
  "effect"      => proc { |battler, pkmn, battle|
    if pkmn.numMoves >= Pokemon::MAX_MOVES
      pbMessage("\\ts[]" + _INTL("{1} already knows {2} moves. It needs to forget one first.",
                                 pkmn.name, pkmn.numMoves))
      next
    end
    new_move = pbChooseMoveList
    next if !new_move
    move_name = GameData::Move.get(new_move).name
    if pkmn.hasMove?(new_move)
      pbMessage("\\ts[]" + _INTL("{1} already knows {2}.", pkmn.name, move_name))
      next
    end
    pkmn.learn_move(new_move)
    battler.moves.push(Move.from_pokemon_move(self, pkmn.moves.last)) if battler
    pbMessage("\\ts[]" + _INTL("{1} learned {2}!", pkmn.name, move_name))
  }
})

BattlerDebugMenuCommands.register("forgetmove", {
  "parent"      => "moves",
  "name"        => _INTL("Forget move"),
  "always_show" => true,
  "effect"      => proc { |battler, pkmn, battle|
    move_names = []
    move_indices = []
    pkmn.moves.each_with_index do |move, index|
      next if !move || !move.id
      if move.total_pp <= 0
        move_names.push(_INTL("{1} (PP: ---)", move.name))
      else
        move_names.push(_INTL("{1} (PP: {2}/{3})", move.name, move.pp, move.total_pp))
      end
      move_indices.push(index)
    end
    cmd = pbMessage("\\ts[]" + _INTL("Forget which move?"), move_names, -1)
    next if cmd < 0
    old_move_name = pkmn.moves[move_indices[cmd]].name
    pkmn.forget_move_at_index(move_indices[cmd])
    battler.moves.delete_at(move_indices[cmd]) if battler
    pbMessage("\\ts[]" + _INTL("{1} forgot {2}.", pkmn.name, old_move_name))
  }
})

BattlerDebugMenuCommands.register("setmovepp", {
  "parent"      => "moves",
  "name"        => _INTL("Set move PP"),
  "always_show" => true,
  "effect"      => proc { |battler, pkmn, battle|
    cmd = 0
    loop do
      move_names = []
      move_indices = []
      pkmn.moves.each_with_index do |move, index|
        next if !move || !move.id
        if move.total_pp <= 0
          move_names.push(_INTL("{1} (PP: ---)", move.name))
        else
          move_names.push(_INTL("{1} (PP: {2}/{3})", move.name, move.pp, move.total_pp))
        end
        move_indices.push(index)
      end
      commands = move_names + [_INTL("Restore all PP")]
      cmd = pbMessage("\\ts[]" + _INTL("Alter PP of which move?"), commands, -1, nil, cmd)
      break if cmd < 0
      if cmd >= 0 && cmd < move_names.length   # Move
        move = pkmn.moves[move_indices[cmd]]
        move_name = move.name
        if move.total_pp <= 0
          pbMessage("\\ts[]" + _INTL("{1} has infinite PP.", move_name))
        else
          cmd2 = 0
          loop do
            msg = _INTL("{1}: PP {2}/{3} (PP Up {4}/3)", move_name, move.pp, move.total_pp, move.ppup)
            cmd2 = pbMessage("\\ts[]" + msg,
                             [_INTL("Set PP"), _INTL("Full PP"), _INTL("Set PP Up")], -1, nil, cmd2)
            break if cmd2 < 0
            case cmd2
            when 0   # Change PP
              params = ChooseNumberParams.new
              params.setRange(0, move.total_pp)
              params.setDefaultValue(move.pp)
              h = pbMessageChooseNumber(
                "\\ts[]" + _INTL("Set PP of {1} (max. {2}).", move_name, move.total_pp), params
              )
              move.pp = h
              if battler && battler.moves[move_indices[cmd]].id == move.id
                battler.moves[move_indices[cmd]].pp = move.pp
              end
            when 1   # Full PP
              move.pp = move.total_pp
              if battler && battler.moves[move_indices[cmd]].id == move.id
                battler.moves[move_indices[cmd]].pp = move.pp
              end
            when 2   # Change PP Up
              params = ChooseNumberParams.new
              params.setRange(0, 3)
              params.setDefaultValue(move.ppup)
              h = pbMessageChooseNumber(
                "\\ts[]" + _INTL("Set PP Up of {1} (max. 3).", move_name), params
              )
              move.ppup = h
              move.pp = move.total_pp if move.pp > move.total_pp
              if battler && battler.moves[move_indices[cmd]].id == move.id
                battler.moves[move_indices[cmd]].pp = move.pp
              end
            end
          end
        end
      elsif cmd == commands.length - 1   # Restore all PP
        pkmn.heal_PP
        if battler
          battler.moves.each { |move| move.pp = move.total_pp }
        end
      end
    end
  }
})

#===============================================================================
# Other options
#===============================================================================
BattlerDebugMenuCommands.register("setitem", {
  "parent"      => "main",
  "name"        => _INTL("Set item"),
  "always_show" => true,
  "effect"      => proc { |battler, pkmn, battle|
    cmd = 0
    commands = [
      _INTL("Change item"),
      _INTL("Remove item")
    ]
    loop do
      msg = (pkmn.hasItem?) ? _INTL("Item is {1}.", pkmn.item.name) : _INTL("No item.")
      cmd = pbMessage("\\ts[]" + msg, commands, -1, nil, cmd)
      break if cmd < 0
      case cmd
      when 0   # Change item
        item = pbChooseItemList(pkmn.item_id)
        if item && item != pkmn.item_id
          battler.item = item
          if GameData::Item.get(item).is_mail?
            pkmn.mail = Mail.new(item, _INTL("Text"), $player.name)
          end
        end
      when 1   # Remove item
        if pkmn.hasItem?
          battler.item = nil
          pkmn.mail = nil
        end
      else
        break
      end
    end
  }
})

BattlerDebugMenuCommands.register("setability", {
  "parent"      => "main",
  "name"        => _INTL("Set ability"),
  "always_show" => true,
  "effect"      => proc { |battler, pkmn, battle|
    cmd = 0
    commands = [
      _INTL("Set ability for battler"),
      _INTL("Set ability for Pokémon"),
      _INTL("Reset")
    ]
    loop do
      msg = _INTL("Battler's ability is {1}. Pokémon's ability is {2}.",
                  battler.abilityName, pkmn.ability.name)
      cmd = pbMessage("\\ts[]" + msg, commands, -1, nil, cmd)
      break if cmd < 0
      case cmd
      when 0   # Set ability for battler
        new_ability = pbChooseAbilityList(pkmn.ability_id)
        if new_ability && new_ability != battler.ability_id
          battler.ability = new_ability
        end
      when 1   # Set ability for Pokémon
        new_ability = pbChooseAbilityList(pkmn.ability_id)
        if new_ability && new_ability != pkmn.ability_id
          pkmn.ability = new_ability
          battler.ability = pkmn.ability
        end
      when 2   # Reset
        pkmn.ability_index = nil
        pkmn.ability = nil
        battler.ability = pkmn.ability
      end
    end
  }
})

BattlerDebugMenuCommands.register("setnature", {
  "parent"      => "main",
  "name"        => _INTL("Set nature"),
  "always_show" => true,
  "effect"      => proc { |battler, pkmn, battle|
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
      cmd = pbMessage("\\ts[]" + msg, commands, -1, nil, cmd)
      break if cmd < 0
      if cmd >= 0 && cmd < commands.length - 1   # Set nature
        pkmn.nature = ids[cmd]
      elsif cmd == commands.length - 1   # Reset
        pkmn.nature = nil
      end
      battler.pbUpdate
    end
  }
})

BattlerDebugMenuCommands.register("setgender", {
  "parent"      => "main",
  "name"        => _INTL("Set gender"),
  "always_show" => true,
  "effect"      => proc { |battler, pkmn, battle|
    if pkmn.singleGendered?
      pbMessage("\\ts[]" + _INTL("{1} is single-gendered or genderless.", pkmn.speciesName))
      next
    end
    cmd = 0
    loop do
      msg = [_INTL("Gender is male."), _INTL("Gender is female.")][pkmn.male? ? 0 : 1]
      cmd = pbMessage("\\ts[]" + msg,
                      [_INTL("Make male"), _INTL("Make female"), _INTL("Reset")], -1, nil, cmd)
      break if cmd < 0
      case cmd
      when 0   # Make male
        pkmn.makeMale
        pbMessage("\\ts[]" + _INTL("{1}'s gender couldn't be changed.", pkmn.name)) if !pkmn.male?
      when 1   # Make female
        pkmn.makeFemale
        pbMessage("\\ts[]" + _INTL("{1}'s gender couldn't be changed.", pkmn.name)) if !pkmn.female?
      when 2   # Reset
        pkmn.gender = nil
      end
    end
  }
})

BattlerDebugMenuCommands.register("speciesform", {
  "parent"      => "main",
  "name"        => _INTL("Set form"),
  "always_show" => true,
  "effect"      => proc { |battler, pkmn, battle|
    cmd = 0
    formcmds = [[], []]
    GameData::Species.each do |sp|
      next if sp.species != pkmn.species
      form_name = sp.form_name
      form_name = _INTL("Unnamed form") if !form_name || form_name.empty?
      form_name = sprintf("%d: %s", sp.form, form_name)
      formcmds[0].push(sp.form)
      formcmds[1].push(form_name)
      cmd = formcmds[0].length - 1 if pkmn.form == sp.form
    end
    if formcmds[0].length <= 1
      pbMessage("\\ts[]" + _INTL("Species {1} only has one form.", pkmn.speciesName))
      next
    end
    loop do
      cmd = pbMessage("\\ts[]" + _INTL("Form is {1}.", pkmn.form), formcmds[1], -1, nil, cmd)
      next if cmd < 0
      f = formcmds[0][cmd]
      if f != pkmn.form
        pkmn.forced_form = nil
        if MultipleForms.hasFunction?(pkmn, "getForm")
          next if !pbConfirmMessage(_INTL("This species decides its own form. Override?"))
          pkmn.forced_form = f
        end
        pkmn.form_simple = f
      end
    end
  }
})

#===============================================================================
# Shininess
#===============================================================================
BattlerDebugMenuCommands.register("setshininess", {
  "parent"      => "main",
  "name"        => _INTL("Set shininess"),
  "always_show" => true,
  "effect"      => proc { |battler, pkmn, battle|
    cmd = 0
    loop do
      msg_idx = pkmn.shiny? ? (pkmn.super_shiny? ? 1 : 0) : 2
      msg = [_INTL("Is shiny."), _INTL("Is super shiny."), _INTL("Is normal (not shiny).")][msg_idx]
      cmd = pbMessage("\\ts[]" + msg,
                      [_INTL("Make shiny"),
                       _INTL("Make super shiny"),
                       _INTL("Make normal"),
                       _INTL("Reset")], -1, nil, cmd)
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
    end
  }
})

#===============================================================================
# Set effects
#===============================================================================
BattlerDebugMenuCommands.register("set_effects", {
  "parent"      => "main",
  "name"        => _INTL("Set effects"),
  "always_show" => true,
  "effect"      => proc { |battler, pkmn, battle|
    editor = Battle::DebugSetEffects.new(battle, :battler, battler.index)
    editor.update
    editor.dispose
  }
})
