#===============================================================================
#
#===============================================================================
class CommandMenuList
  attr_accessor :currentList

  def initialize
    @commands    = []
    @currentList = :main
  end

  def add(option, hash, name = nil, description = nil)
    @commands.push([option, hash["parent"], name || hash["name"], description || hash["description"]])
  end

  def list
    ret = []
    @commands.each { |cmd| ret.push(cmd[2]) if cmd[1] == @currentList }
    return ret
  end

  def getCommand(index)
    count = 0
    @commands.each do |cmd|
      next if cmd[1] != @currentList
      return cmd[0] if count == index
      count += 1
    end
    return nil
  end

  def getDesc(index)
    count = 0
    @commands.each do |cmd|
      next if cmd[1] != @currentList
      return cmd[3] if count == index && cmd[3]
      break if count == index
      count += 1
    end
    return "<No description available>"
  end

  def hasSubMenu?(check_cmd)
    @commands.each { |cmd| return true if cmd[1] == check_cmd }
    return false
  end

  def getParent
    ret = nil
    @commands.each do |cmd|
      next if cmd[0] != @currentList
      ret = cmd[1]
      break
    end
    return nil if !ret
    count = 0
    @commands.each do |cmd|
      next if cmd[1] != ret
      return [ret, count] if cmd[0] == @currentList
      count += 1
    end
    return [ret, 0]
  end
end

#===============================================================================
#
#===============================================================================
def pbDebugMenu(show_all = true)
  # Get all commands
  commands = CommandMenuList.new
  MenuHandlers.each_available(:debug_menu) do |option, hash, name|
    next if !show_all && !hash["always_show"].nil? && !hash["always_show"]
    if hash["description"].is_a?(Proc)
      description = hash["description"].call
    elsif !hash["description"].nil?
      description = _INTL(hash["description"])
    end
    commands.add(option, hash, name, description)
  end
  # Setup windows
  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 99999
  sprites = {}
  sprites["textbox"] = pbCreateMessageWindow
  sprites["textbox"].letterbyletter = false
  sprites["cmdwindow"] = Window_CommandPokemonEx.new(commands.list)
  cmdwindow = sprites["cmdwindow"]
  cmdwindow.x        = 0
  cmdwindow.y        = 0
  cmdwindow.width    = Graphics.width
  cmdwindow.height   = Graphics.height - sprites["textbox"].height
  cmdwindow.viewport = viewport
  cmdwindow.visible  = true
  sprites["textbox"].text = commands.getDesc(cmdwindow.index)
  pbFadeInAndShow(sprites)
  # Main loop
  ret = -1
  refresh = true
  loop do
    loop do
      oldindex = cmdwindow.index
      cmdwindow.update
      if refresh || cmdwindow.index != oldindex
        sprites["textbox"].text = commands.getDesc(cmdwindow.index)
        refresh = false
      end
      Graphics.update
      Input.update
      if Input.trigger?(Input::BACK)
        parent = commands.getParent
        if parent
          pbPlayCancelSE
          commands.currentList = parent[0]
          cmdwindow.commands = commands.list
          cmdwindow.index = parent[1]
          refresh = true
        else
          ret = -1
          break
        end
      elsif Input.trigger?(Input::USE)
        ret = cmdwindow.index
        break
      end
    end
    break if ret < 0
    cmd = commands.getCommand(ret)
    if commands.hasSubMenu?(cmd)
      pbPlayDecisionSE
      commands.currentList = cmd
      cmdwindow.commands = commands.list
      cmdwindow.index = 0
      refresh = true
    elsif cmd == :warp
      return if MenuHandlers.call(:debug_menu, cmd, "effect", sprites, viewport)
    else
      MenuHandlers.call(:debug_menu, cmd, "effect")
    end
  end
  pbPlayCloseMenuSE
  pbFadeOutAndHide(sprites)
  pbDisposeMessageWindow(sprites["textbox"])
  pbDisposeSpriteHash(sprites)
  viewport.dispose
end

#===============================================================================
#
#===============================================================================
module PokemonDebugMixin
  def pbPokemonDebug(pkmn, pkmnid, heldpoke = nil, settingUpBattle = false)
    # Get all commands
    commands = CommandMenuList.new
    MenuHandlers.each_available(:pokemon_debug_menu) do |option, hash, name|
      next if settingUpBattle && !hash["always_show"].nil? && !hash["always_show"]
      commands.add(option, hash, name)
    end
    # Main loop
    command = 0
    loop do
      command = pbShowCommands(_INTL("Do what with {1}?", pkmn.name), commands.list, command)
      if command < 0
        parent = commands.getParent
        break if !parent
        commands.currentList = parent[0]
        command = parent[1]
      else
        cmd = commands.getCommand(command)
        if commands.hasSubMenu?(cmd)
          commands.currentList = cmd
          command = 0
        elsif MenuHandlers.call(:pokemon_debug_menu, cmd, "effect", pkmn, pkmnid, heldpoke, settingUpBattle, self)
          break
        end
      end
    end
  end
end

#===============================================================================
#
#===============================================================================
module Battle::DebugMixin
  def pbBattleDebug(battle, show_all = true)
    # Get all commands
    commands = CommandMenuList.new
    MenuHandlers.each_available(:battle_debug_menu) do |option, hash, name|
      next if !show_all && !hash["always_show"].nil? && !hash["always_show"]
      if hash["description"].is_a?(Proc)
        description = hash["description"].call
      elsif !hash["description"].nil?
        description = _INTL(hash["description"])
      end
      commands.add(option, hash, name, description)
    end
    # Setup windows
    viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    viewport.z = 99999
    sprites = {}
    sprites["textbox"] = pbCreateMessageWindow
    sprites["textbox"].letterbyletter = false
    sprites["cmdwindow"] = Window_CommandPokemonEx.new(commands.list)
    cmdwindow = sprites["cmdwindow"]
    cmdwindow.x        = 0
    cmdwindow.y        = 0
    cmdwindow.width    = Graphics.width / 2
    cmdwindow.height   = Graphics.height - sprites["textbox"].height
    cmdwindow.viewport = viewport
    cmdwindow.visible  = true
    sprites["textbox"].text = commands.getDesc(cmdwindow.index)
    # Main loop
    ret = -1
    refresh = true
    loop do
      loop do
        oldindex = cmdwindow.index
        cmdwindow.update
        if refresh || cmdwindow.index != oldindex
          sprites["textbox"].text = commands.getDesc(cmdwindow.index)
          refresh = false
        end
        Graphics.update
        Input.update
        if Input.trigger?(Input::BACK)
          parent = commands.getParent
          if parent
            pbPlayCancelSE
            commands.currentList = parent[0]
            cmdwindow.commands = commands.list
            cmdwindow.index = parent[1]
            refresh = true
          else
            ret = -1
            break
          end
        elsif Input.trigger?(Input::USE)
          ret = cmdwindow.index
          break
        end
      end
      break if ret < 0
      cmd = commands.getCommand(ret)
      if commands.hasSubMenu?(cmd)
        pbPlayDecisionSE
        commands.currentList = cmd
        cmdwindow.commands = commands.list
        cmdwindow.index = 0
        refresh = true
      else
        MenuHandlers.call(:battle_debug_menu, cmd, "effect", battle)
      end
    end
    pbPlayCloseMenuSE
    pbDisposeMessageWindow(sprites["textbox"])
    pbDisposeSpriteHash(sprites)
    viewport.dispose
  end

  def pbBattleDebugBattlerInfo(battler)
    ret = ""
    return ret if battler.nil?
    # Battler index, name
    ret += sprintf("[%d] %s", battler.index, battler.pbThis)
    ret += "\n"
    # Species
    ret += _INTL("Species: {1}", GameData::Species.get(battler.species).name)
    ret += "\n"
    # Form number
    ret += _INTL("Form: {1}", battler.form)
    ret += "\n"
    # Level, gender, shininess
    ret += _INTL("Level {1}, {2}", battler.level,
                 (battler.pokemon.male?) ? "♂" : (battler.pokemon.female?) ? "♀" : _INTL("genderless"))
    ret += ", " + _INTL("shiny") if battler.pokemon.shiny?
    ret += "\n"
    # HP
    ret += _INTL("HP: {1}/{2} ({3}%)", battler.hp, battler.totalhp, (100.0 * battler.hp / battler.totalhp).to_i)
    ret += "\n"
    # Status
    ret += _INTL("Status: {1}", GameData::Status.get(battler.status).name)
    case battler.status
    when :SLEEP
      ret += " " + _INTL("({1} rounds left)", battler.statusCount)
    when :POISON
      if battler.statusCount > 0
        ret += " " + _INTL("(toxic, {1}/16)", battler.effects[PBEffects::Toxic])
      end
    end
    ret += "\n"
    # Stat stages
    stages = []
    GameData::Stat.each_battle do |stat|
      next if battler.stages[stat.id] == 0
      stage_text = ""
      stage_text += "+" if battler.stages[stat.id] > 0
      stage_text += battler.stages[stat.id].to_s
      stage_text += " " + stat.name_brief
      stages.push(stage_text)
    end
    ret += _INTL("Stat stages: {1}", (stages.empty?) ? "-" : stages.join(", "))
    ret += "\n"
    # Ability
    ret += _INTL("Ability: {1}", (battler.ability) ? battler.abilityName : "-")
    ret += "\n"
    # Held item
    ret += _INTL("Item: {1}", (battler.item) ? battler.itemName : "-")
    return ret
  end

  def pbBattleDebugPokemonInfo(pkmn)
    ret = ""
    return ret if pkmn.nil?
    sp_data = pkmn.species_data
    # Name, species
    ret += sprintf("%s (%s)", pkmn.name, sp_data.name)
    ret += "\n"
    # Form number
    ret += _INTL("Form: {1}", sp_data.form)
    ret += "\n"
    # Level, gender, shininess
    ret += _INTL("Level {1}, {2}", pkmn.level,
                 (pkmn.male?) ? "♂" : (pkmn.female?) ? "♀" : _INTL("genderless"))
    ret += ", " + _INTL("shiny") if pkmn.shiny?
    ret += "\n"
    # HP
    ret += _INTL("HP: {1}/{2} ({3}%)", pkmn.hp, pkmn.totalhp, (100.0 * pkmn.hp / pkmn.totalhp).to_i)
    ret += "\n"
    # Status
    ret += _INTL("Status: {1}", GameData::Status.get(pkmn.status).name)
    case pkmn.status
    when :SLEEP
      ret += " " + _INTL("({1} rounds left)", pkmn.statusCount)
    when :POISON
      ret += " " + _INTL("(toxic)") if pkmn.statusCount > 0
    end
    ret += "\n"
    # Ability
    ret += _INTL("Ability: {1}", pkmn.ability&.name || "-")
    ret += "\n"
    # Held item
    ret += _INTL("Item: {1}", pkmn.item&.name || "-")
    return ret
  end

  def pbBattlePokemonDebug(pkmn, battler = nil)
    # Get all commands
    commands = CommandMenuList.new
    MenuHandlers.each_available(:battle_pokemon_debug_menu) do |option, hash, name|
      next if battler && hash["usage"] == :pokemon
      next if !battler && hash["usage"] == :battler
      commands.add(option, hash, name)
    end
    # Setup windows
    viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    viewport.z = 99999
    sprites = {}
    sprites["infowindow"] = Window_AdvancedTextPokemon.new("")
    infowindow = sprites["infowindow"]
    infowindow.x        = 0
    infowindow.y        = 0
    infowindow.width    = Graphics.width / 2
    infowindow.height   = Graphics.height
    infowindow.viewport = viewport
    infowindow.visible  = true
    sprites["dummywindow"] = Window_AdvancedTextPokemon.new("")
    sprites["dummywindow"].y = Graphics.height
    sprites["dummywindow"].width = Graphics.width
    sprites["dummywindow"].height = 0
    # Main loop
    need_refresh = true
    cmd = 0
    loop do
      if need_refresh
        if battler
          sprites["infowindow"].text = pbBattleDebugBattlerInfo(battler)
        else
          sprites["infowindow"].text = pbBattleDebugPokemonInfo(pkmn)
        end
        need_refresh = false
      end
      # Choose a command
      cmd = Kernel.pbShowCommands(sprites["dummywindow"], commands.list, -1, cmd)
      if cmd < 0   # Cancel
        parent = commands.getParent
        if parent   # Go up a level
          commands.currentList = parent[0]
          cmd = parent[1]
        else   # Exit
          break
        end
      else
        real_cmd = commands.getCommand(cmd)
        if commands.hasSubMenu?(real_cmd)
          commands.currentList = real_cmd
          cmd = 0
        else
          MenuHandlers.call(:battle_pokemon_debug_menu, real_cmd, "effect", pkmn, battler, self)
          need_refresh = true
        end
      end
    end
    pbDisposeSpriteHash(sprites)
    viewport.dispose
  end
end

#===============================================================================
#
#===============================================================================
class PokemonPartyScreen
  include PokemonDebugMixin
end

class PokemonStorageScreen
  include PokemonDebugMixin
end

class PokemonDebugPartyScreen
  include PokemonDebugMixin
end

class Battle
  include Battle::DebugMixin
end
