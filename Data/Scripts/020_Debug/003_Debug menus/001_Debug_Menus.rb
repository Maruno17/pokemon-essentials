#===============================================================================
#
#===============================================================================
class CommandMenuList
  attr_accessor :currentList

  def initialize
    @commands    = []
    @currentList = "main"
  end

  def add(option, hash)
    @commands.push([option, hash["parent"], hash["name"], hash["description"]])
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
  commands = CommandMenuList.new
  DebugMenuCommands.each do |option, hash|
    commands.add(option, hash) if show_all || hash["always_show"]
  end
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
    elsif cmd == "warp"
      return if DebugMenuCommands.call("effect", cmd, sprites, viewport)
    else
      DebugMenuCommands.call("effect", cmd)
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
    command = 0
    commands = CommandMenuList.new
    PokemonDebugMenuCommands.each do |option, hash|
      commands.add(option, hash) if !settingUpBattle || hash["always_show"]
    end
    loop do
      command = pbShowCommands(_INTL("Do what with {1}?", pkmn.name), commands.list, command)
      if command < 0
        parent = commands.getParent
        if parent
          commands.currentList = parent[0]
          command = parent[1]
        else
          break
        end
      else
        cmd = commands.getCommand(command)
        if commands.hasSubMenu?(cmd)
          commands.currentList = cmd
          command = 0
        elsif PokemonDebugMenuCommands.call("effect", cmd, pkmn, pkmnid, heldpoke, settingUpBattle, self)
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
    commands = CommandMenuList.new
    BattleDebugMenuCommands.each do |option, hash|
      commands.add(option, hash) if show_all || hash["always_show"]
    end
    viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    viewport.z = 99999
    sprites = {}
    sprites["textbox"] = pbCreateMessageWindow
    sprites["textbox"].letterbyletter = false
    sprites["cmdwindow"] = Window_CommandPokemonEx.new(commands.list)
    cmdwindow = sprites["cmdwindow"]
    cmdwindow.x        = 0
    cmdwindow.y        = 0
    cmdwindow.height   = Graphics.height - sprites["textbox"].height
    cmdwindow.viewport = viewport
    cmdwindow.visible  = true
    sprites["textbox"].text = commands.getDesc(cmdwindow.index)
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
        BattleDebugMenuCommands.call("effect", cmd, battle)
      end
    end
    pbPlayCloseMenuSE
    pbDisposeMessageWindow(sprites["textbox"])
    pbDisposeSpriteHash(sprites)
    viewport.dispose
  end

  def pbBattleBattlerDebug(battler, show_all = true)
    commands = CommandMenuList.new
    BattlerDebugMenuCommands.each do |option, hash|
      commands.add(option, hash) if show_all || hash["always_show"]
    end
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
    need_refresh = true
    cmd = 0
    loop do
      if need_refresh
        help_text = ""
        help_text += sprintf("[%d] %s", battler.index, battler.pbThis)
        help_text += "\r\n"
        help_text += _INTL("Species: {1}", GameData::Species.get(battler.species).name)
        help_text += "\r\n"
        help_text += _INTL("Form: {1}", battler.form)
        help_text += "\r\n"
        help_text += _INTL("Level {1}, {2}", battler.level,
           (battler.pokemon.male?) ? "♂" : (battler.pokemon.female?) ? "♀" : "genderless")
        help_text += ", " + _INTL("Shiny") if battler.pokemon.shiny?
        help_text += "\r\n"
        help_text += _INTL("HP: {1}/{2} ({3}%)", battler.hp, battler.totalhp, (100.0 * battler.hp / battler.totalhp).to_i)
        help_text += "\r\n"
        help_text += _INTL("Status: {1}", GameData::Status.get(battler.status).name)
        case battler.status
        when :SLEEP
          help_text += " " + _INTL("({1} rounds left)", battler.statusCount)
        when :POISON
          if battler.statusCount > 0
            help_text += " " + _INTL("(toxic, {1}/16)", battler.effects[PBEffects::Toxic])
          end
        end
        help_text += "\r\n"
        stages = []
        GameData::Stat.each_battle do |stat|
          next if battler.stages[stat.id] == 0
          stage_text = ""
          stage_text += "+" if battler.stages[stat.id] > 0
          stage_text += battler.stages[stat.id].to_s
          stage_text += " " + stat.name_brief
          stages.push(stage_text)
        end
        help_text += _INTL("Stat stages: {1}", (stages.empty?) ? "-" : stages.join(", "))
        help_text += "\r\n"
        help_text += _INTL("Ability: {1}", (battler.ability) ? battler.abilityName : "-")
        help_text += "\r\n"
        help_text += _INTL("Item: {1}", (battler.item) ? battler.itemName : "-")
        sprites["infowindow"].text = help_text
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
          BattlerDebugMenuCommands.call("effect", real_cmd, battler, battler.pokemon, battler.battle)
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
