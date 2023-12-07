#===============================================================================
# Data type properties
#===============================================================================
module UndefinedProperty
  def self.set(_settingname, oldsetting)
    pbMessage(_INTL("This property can't be edited here at this time."))
    return oldsetting
  end

  def self.format(value)
    return value.inspect
  end
end

#===============================================================================
#
#===============================================================================
module ReadOnlyProperty
  def self.set(_settingname, oldsetting)
    pbMessage(_INTL("This property cannot be edited."))
    return oldsetting
  end

  def self.format(value)
    return value.inspect
  end
end

#===============================================================================
#
#===============================================================================
class UIntProperty
  def initialize(maxdigits)
    @maxdigits = maxdigits
  end

  def set(settingname, oldsetting)
    params = ChooseNumberParams.new
    params.setMaxDigits(@maxdigits)
    params.setDefaultValue(oldsetting || 0)
    return pbMessageChooseNumber(_INTL("Set the value for {1}.", settingname), params)
  end

  def defaultValue
    return 0
  end

  def format(value)
    return value.inspect
  end
end

#===============================================================================
#
#===============================================================================
class LimitProperty
  def initialize(maxvalue)
    @maxvalue = maxvalue
  end

  def set(settingname, oldsetting)
    oldsetting = 1 if !oldsetting
    params = ChooseNumberParams.new
    params.setRange(0, @maxvalue)
    params.setDefaultValue(oldsetting)
    return pbMessageChooseNumber(_INTL("Set the value for {1} (0-{2}).", settingname, @maxvalue), params)
  end

  def defaultValue
    return 0
  end

  def format(value)
    return value.inspect
  end
end

#===============================================================================
#
#===============================================================================
class LimitProperty2
  def initialize(maxvalue)
    @maxvalue = maxvalue
  end

  def set(settingname, oldsetting)
    oldsetting = 0 if !oldsetting
    params = ChooseNumberParams.new
    params.setRange(0, @maxvalue)
    params.setDefaultValue(oldsetting)
    params.setCancelValue(-1)
    ret = pbMessageChooseNumber(_INTL("Set the value for {1} (0-{2}).", settingname, @maxvalue), params)
    return (ret >= 0) ? ret : nil
  end

  def defaultValue
    return nil
  end

  def format(value)
    return (value) ? value.inspect : "-"
  end
end

#===============================================================================
#
#===============================================================================
class NonzeroLimitProperty
  def initialize(maxvalue)
    @maxvalue = maxvalue
  end

  def set(settingname, oldsetting)
    oldsetting = 1 if !oldsetting
    params = ChooseNumberParams.new
    params.setRange(1, @maxvalue)
    params.setDefaultValue(oldsetting)
    return pbMessageChooseNumber(_INTL("Set the value for {1}.", settingname), params)
  end

  def defaultValue
    return 1
  end

  def format(value)
    return value.inspect
  end
end

#===============================================================================
#
#===============================================================================
module BooleanProperty
  def self.set(settingname, _oldsetting)
    return pbConfirmMessage(_INTL("Enable the setting {1}?", settingname)) ? true : false
  end

  def self.format(value)
    return value.inspect
  end
end

#===============================================================================
#
#===============================================================================
module BooleanProperty2
  def self.set(_settingname, _oldsetting)
    ret = pbShowCommands(nil, [_INTL("True"), _INTL("False")], -1)
    return (ret >= 0) ? (ret == 0) : nil
  end

  def self.defaultValue
    return nil
  end

  def self.format(value)
    return _INTL("True") if value
    return (value.nil?) ? "-" : _INTL("False")
  end
end

#===============================================================================
#
#===============================================================================
module StringProperty
  def self.set(settingname, oldsetting)
    return pbMessageFreeText(_INTL("Set the value for {1}.", settingname),
                             (oldsetting) ? oldsetting : "", false, 250, Graphics.width)
  end

  def self.format(value)
    return value
  end
end

#===============================================================================
#
#===============================================================================
class LimitStringProperty
  def initialize(limit)
    @limit = limit
  end

  def format(value)
    return value
  end

  def set(settingname, oldsetting)
    return pbMessageFreeText(_INTL("Set the value for {1}.", settingname),
                             (oldsetting) ? oldsetting : "", false, @limit)
  end
end

#===============================================================================
#
#===============================================================================
class EnumProperty
  def initialize(values)
    @values = values
  end

  def set(settingname, oldsetting)
    commands = []
    @values.each do |value|
      commands.push(value)
    end
    cmd = pbMessage(_INTL("Choose a value for {1}.", settingname), commands, -1)
    return oldsetting if cmd < 0
    return cmd
  end

  def defaultValue
    return 0
  end

  def format(value)
    return (value) ? @values[value] : value.inspect
  end
end

#===============================================================================
# Unused
#===============================================================================
class EnumProperty2
  def initialize(value)
    @module = value
  end

  def set(settingname, oldsetting)
    commands = []
    (0..@module.maxValue).each do |i|
      commands.push(getConstantName(@module, i))
    end
    cmd = pbMessage(_INTL("Choose a value for {1}.", settingname), commands, -1, nil, oldsetting)
    return oldsetting if cmd < 0
    return cmd
  end

  def defaultValue
    return nil
  end

  def format(value)
    return (value) ? getConstantName(@module, value) : "-"
  end
end

#===============================================================================
#
#===============================================================================
class StringListProperty
  def self.set(_setting_name, old_setting)
    old_setting = [] if !old_setting
    real_cmds = []
    real_cmds.push([_INTL("[ADD VALUE]"), -1])
    old_setting.length.times do |i|
      real_cmds.push([old_setting[i], 0])
    end
    # Edit list
    cmdwin = pbListWindow([], 200)
    oldsel = nil
    ret = old_setting
    cmd = 0
    commands = []
    do_refresh = true
    loop do
      if do_refresh
        commands = []
        real_cmds.each_with_index do |entry, i|
          commands.push(entry[0])
          cmd = i if oldsel && entry[0] == oldsel
        end
      end
      do_refresh = false
      oldsel = nil
      cmd = pbCommands2(cmdwin, commands, -1, cmd, true)
      if cmd >= 0   # Chose a value
        entry = real_cmds[cmd]
        if entry[1] == -1   # Add new value
          new_value = pbMessageFreeText(_INTL("Enter the new value."),
                                        "", false, 250, Graphics.width)
          if !nil_or_empty?(new_value)
            if real_cmds.any? { |e| e[0] == new_value }
              oldsel = new_value   # Already have value; just move cursor to it
            else
              real_cmds.push([new_value, 0])
            end
            do_refresh = true
          end
        else   # Edit value
          case pbMessage("\\ts[]" + _INTL("Do what with this value?"),
                         [_INTL("Edit"), _INTL("Delete"), _INTL("Cancel")], 3)
          when 0   # Edit
            new_value = pbMessageFreeText(_INTL("Enter the new value."),
                                          entry[0], false, 250, Graphics.width)
            if !nil_or_empty?(new_value)
              if real_cmds.any? { |e| e[0] == new_value }   # Already have value; delete this one
                real_cmds.delete_at(cmd)
                cmd = [cmd, real_cmds.length - 1].min
              else   # Change value
                entry[0] = new_value
              end
              oldsel = new_value
              do_refresh = true
            end
          when 1   # Delete
            real_cmds.delete_at(cmd)
            cmd = [cmd, real_cmds.length - 1].min
            do_refresh = true
          end
        end
      else   # Cancel/quit
        case pbMessage(_INTL("Keep changes?"), [_INTL("Yes"), _INTL("No"), _INTL("Cancel")], 3)
        when 0
          real_cmds.length.times do |i|
            real_cmds[i] = (real_cmds[i][1] == -1) ? nil : real_cmds[i][0]
          end
          real_cmds.compact!
          ret = real_cmds
          break
        when 1
          break
        end
      end
    end
    cmdwin.dispose
    return ret
  end

  def self.defaultValue
    return []
  end

  def self.format(value)
    return (value) ? value.join(",") : ""
  end
end

#===============================================================================
#
#===============================================================================
class GameDataProperty
  def initialize(value)
    raise _INTL("Couldn't find class {1} in module GameData.", value.to_s) if !GameData.const_defined?(value.to_sym)
    @module = GameData.const_get(value.to_sym)
  end

  def set(settingname, oldsetting)
    commands = []
    i = 0
    @module.each do |data|
      if data.respond_to?("id_number")
        commands.push([data.id_number, data.name, data.id])
      else
        commands.push([i, data.name, data.id])
      end
      i += 1
    end
    return pbChooseList(commands, oldsetting, oldsetting, -1)
  end

  def defaultValue
    return nil
  end

  def format(value)
    return (value && @module.exists?(value)) ? @module.get(value).real_name : "-"
  end
end

#===============================================================================
#
#===============================================================================
module BGMProperty
  def self.set(settingname, oldsetting)
    chosenmap = pbListScreen(settingname, MusicFileLister.new(true, oldsetting))
    return (chosenmap && chosenmap != "") ? File.basename(chosenmap, ".*") : oldsetting
  end

  def self.format(value)
    return value
  end
end

#===============================================================================
#
#===============================================================================
module MEProperty
  def self.set(settingname, oldsetting)
    chosenmap = pbListScreen(settingname, MusicFileLister.new(false, oldsetting))
    return (chosenmap && chosenmap != "") ? File.basename(chosenmap, ".*") : oldsetting
  end

  def self.format(value)
    return value
  end
end

#===============================================================================
#
#===============================================================================
module WindowskinProperty
  def self.set(settingname, oldsetting)
    chosenmap = pbListScreen(settingname, GraphicsLister.new("Graphics/Windowskins/", oldsetting))
    return (chosenmap && chosenmap != "") ? File.basename(chosenmap, ".*") : oldsetting
  end

  def self.format(value)
    return value
  end
end

#===============================================================================
#
#===============================================================================
module TrainerTypeProperty
  def self.set(settingname, oldsetting)
    chosenmap = pbListScreen(settingname, TrainerTypeLister.new(0, false))
    return chosenmap || oldsetting
  end

  def self.format(value)
    return (value && GameData::TrainerType.exists?(value)) ? GameData::TrainerType.get(value).real_name : "-"
  end
end

#===============================================================================
#
#===============================================================================
module SpeciesProperty
  def self.set(_settingname, oldsetting)
    ret = pbChooseSpeciesList(oldsetting || nil)
    return ret || oldsetting
  end

  def self.defaultValue
    return nil
  end

  def self.format(value)
    return (value && GameData::Species.exists?(value)) ? GameData::Species.get(value).real_name : "-"
  end
end

#===============================================================================
#
#===============================================================================
class SpeciesFormProperty
  def initialize(default_value)
    @default_value = default_value
  end

  def set(_settingname, oldsetting)
    ret = pbChooseSpeciesFormList(oldsetting || nil)
    return ret || oldsetting
  end

  def defaultValue
    return @default_value
  end

  def format(value)
    if value && GameData::Species.exists?(value)
      species_data = GameData::Species.get(value)
      if species_data.form > 0
        return sprintf("%s_%d", species_data.real_name, species_data.form)
      else
        return species_data.real_name
      end
    end
    return "-"
  end
end

#===============================================================================
#
#===============================================================================
module TypeProperty
  def self.set(_settingname, oldsetting)
    ret = pbChooseTypeList(oldsetting || nil)
    return ret || oldsetting
  end

  def self.defaultValue
    return nil
  end

  def self.format(value)
    return (value && GameData::Type.exists?(value)) ? GameData::Type.get(value).real_name : "-"
  end
end

#===============================================================================
#
#===============================================================================
module TypesProperty
  def self.set(_settingname, oldsetting)
    ret = oldsetting.clone
    index = 0
    loop do
      cmds = []
      2.times { |i| cmds.push(_INTL("Type {1} : {2}", i, ret[i] || "-")) }
      index = pbMessage(_INTL("Set the type(s) for this species."), cmds, -1)
      break if index < 0
      new_type = pbChooseTypeList(ret[index])
      ret[index] = new_type if new_type
      ret.uniq!
      ret.compact!
    end
    return ret if ret != oldsetting.compact && pbConfirmMessage(_INTL("Apply changes?"))
    return oldsetting
  end

  def self.defaultValue
    return [:NORMAL]
  end

  def self.format(value)
    types = value.compact
    types.each_with_index { |type, i| types[i] = GameData::Type.try_get(types[i])&.real_name || "-" }
    return types.join(",")
  end
end

#===============================================================================
#
#===============================================================================
module MoveProperty
  def self.set(_settingname, oldsetting)
    ret = pbChooseMoveList(oldsetting || nil)
    return ret || oldsetting
  end

  def self.defaultValue
    return nil
  end

  def self.format(value)
    return (value && GameData::Move.exists?(value)) ? GameData::Move.get(value).real_name : "-"
  end
end

#===============================================================================
#
#===============================================================================
class MovePropertyForSpecies
  def initialize(pokemondata)
    @pokemondata = pokemondata
  end

  def set(_settingname, oldsetting)
    ret = pbChooseMoveListForSpecies(@pokemondata[0], oldsetting || nil)
    return ret || oldsetting
  end

  def defaultValue
    return nil
  end

  def format(value)
    return (value && GameData::Move.exists?(value)) ? GameData::Move.get(value).real_name : "-"
  end
end

#===============================================================================
#
#===============================================================================
module GenderProperty
  def self.set(_settingname, _oldsetting)
    ret = pbShowCommands(nil, [_INTL("Male"), _INTL("Female")], -1)
    return (ret >= 0) ? ret : nil
  end

  def self.defaultValue
    return nil
  end

  def self.format(value)
    return "-" if !value
    return _INTL("Male") if value == 0
    return _INTL("Female") if value == 1
    return "-"
  end
end

#===============================================================================
#
#===============================================================================
module ItemProperty
  def self.set(_settingname, oldsetting)
    ret = pbChooseItemList((oldsetting) ? oldsetting : nil)
    return ret || oldsetting
  end

  def self.defaultValue
    return nil
  end

  def self.format(value)
    return (value && GameData::Item.exists?(value)) ? GameData::Item.get(value).real_name : "-"
  end
end

#===============================================================================
#
#===============================================================================
class IVsProperty
  def initialize(limit)
    @limit = limit
  end

  def set(settingname, oldsetting)
    oldsetting = {} if !oldsetting
    properties = []
    data = []
    stat_ids = []
    GameData::Stat.each_main do |s|
      oldsetting[s.pbs_order] = 0 if !oldsetting[s.pbs_order]
      properties[s.pbs_order] = [s.name, LimitProperty2.new(@limit),
                                 _INTL("Individual values for the Pokémon's {1} stat (0-{2}).", s.name, @limit)]
      data[s.pbs_order] = oldsetting[s.id]
      stat_ids[s.pbs_order] = s.id
    end
    pbPropertyList(settingname, data, properties, false)
    ret = {}
    stat_ids.each_with_index { |s, i| ret[s] = data[i] || 0 }
    return ret
  end

  def defaultValue
    return nil
  end

  def format(value)
    return "-" if !value
    array = []
    GameData::Stat.each_main do |s|
      next if s.pbs_order < 0
      array[s.pbs_order] = value[s.id] || 0
    end
    return array.join(",")
  end
end

#===============================================================================
#
#===============================================================================
class EVsProperty
  def initialize(limit)
    @limit = limit
  end

  def set(settingname, oldsetting)
    oldsetting = {} if !oldsetting
    properties = []
    data = []
    stat_ids = []
    GameData::Stat.each_main do |s|
      oldsetting[s.pbs_order] = 0 if !oldsetting[s.pbs_order]
      properties[s.pbs_order] = [s.name, LimitProperty2.new(@limit),
                                 _INTL("Effort values for the Pokémon's {1} stat (0-{2}).", s.name, @limit)]
      data[s.pbs_order] = oldsetting[s.id]
      stat_ids[s.pbs_order] = s.id
    end
    loop do
      pbPropertyList(settingname, data, properties, false)
      evtotal = 0
      data.each { |value| evtotal += value if value }
      break if evtotal <= Pokemon::EV_LIMIT
      pbMessage(_INTL("Total EVs ({1}) are greater than allowed ({2}). Please reduce them.", evtotal, Pokemon::EV_LIMIT))
    end
    ret = {}
    stat_ids.each_with_index { |s, i| ret[s] = data[i] || 0 }
    return ret
  end

  def defaultValue
    return nil
  end

  def format(value)
    return "-" if !value
    array = []
    GameData::Stat.each_main do |s|
      next if s.pbs_order < 0
      array[s.pbs_order] = value[s.id] || 0
    end
    return array.join(",")
  end
end

#===============================================================================
#
#===============================================================================
class BallProperty
  def initialize(pokemondata)
    @pokemondata = pokemondata
  end

  def set(_settingname, oldsetting)
    return pbChooseBallList(oldsetting)
  end

  def defaultValue
    return nil
  end

  def format(value)
    return (value) ? GameData::Item.get(value).name : "-"
  end
end

#===============================================================================
#
#===============================================================================
module CharacterProperty
  def self.set(settingname, oldsetting)
    chosenmap = pbListScreen(settingname, GraphicsLister.new("Graphics/Characters/", oldsetting))
    return (chosenmap && chosenmap != "") ? File.basename(chosenmap, ".*") : oldsetting
  end

  def self.format(value)
    return value
  end
end

#===============================================================================
#
#===============================================================================
module MapSizeProperty
  def self.set(settingname, oldsetting)
    oldsetting = [0, ""] if !oldsetting
    properties = [
      [_INTL("Width"),         NonzeroLimitProperty.new(30), _INTL("The width of this map in Region Map squares.")],
      [_INTL("Valid Squares"), StringProperty,               _INTL("A series of 1s and 0s marking which squares are part of this map (1=part, 0=not part).")]
    ]
    pbPropertyList(settingname, oldsetting, properties, false)
    return oldsetting
  end

  def self.format(value)
    return value.inspect
  end
end

def chooseMapPoint(map, rgnmap = false)
  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 99999
  title = Window_UnformattedTextPokemon.newWithSize(
    _INTL("Click a point on the map."), 0, Graphics.height - 64, Graphics.width, 64, viewport
  )
  title.z = 2
  if rgnmap
    sprite = RegionMapSprite.new(map, viewport)
  else
    sprite = MapSprite.new(map, viewport)
  end
  sprite.z = 2
  ret = nil
  loop do
    Graphics.update
    Input.update
    xy = sprite.getXY
    if xy
      ret = xy
      break
    end
    if Input.trigger?(Input::BACK)
      ret = nil
      break
    end
  end
  sprite.dispose
  title.dispose
  return ret
end

#===============================================================================
#
#===============================================================================
module MapCoordsProperty
  def self.set(settingname, oldsetting)
    chosenmap = pbListScreen(settingname, MapLister.new((oldsetting) ? oldsetting[0] : 0))
    if chosenmap >= 0
      mappoint = chooseMapPoint(chosenmap)
      return (mappoint) ? [chosenmap, mappoint[0], mappoint[1]] : oldsetting
    else
      return oldsetting
    end
  end

  def self.format(value)
    return value.inspect
  end
end

#===============================================================================
#
#===============================================================================
module MapCoordsFacingProperty
  def self.set(settingname, oldsetting)
    chosenmap = pbListScreen(settingname, MapLister.new((oldsetting) ? oldsetting[0] : 0))
    if chosenmap >= 0
      mappoint = chooseMapPoint(chosenmap)
      if mappoint
        facing = pbMessage(_INTL("Choose the direction to face in."),
                           [_INTL("Down"), _INTL("Left"), _INTL("Right"), _INTL("Up")], -1)
        return (facing >= 0) ? [chosenmap, mappoint[0], mappoint[1], [2, 4, 6, 8][facing]] : oldsetting
      else
        return oldsetting
      end
    else
      return oldsetting
    end
  end

  def self.format(value)
    return value.inspect
  end
end

#===============================================================================
#
#===============================================================================
module RegionMapCoordsProperty
  def self.set(_settingname, oldsetting)
    regions = self.getMapNameList
    selregion = -1
    case regions.length
    when 0
      pbMessage(_INTL("No region maps are defined."))
      return oldsetting
    when 1
      selregion = regions[0][0]
    else
      cmds = []
      regions.each { |region| cmds.push(region[1]) }
      selcmd = pbMessage(_INTL("Choose a region map."), cmds, -1)
      return oldsetting if selcmd < 0
      selregion = regions[selcmd][0]
    end
    mappoint = chooseMapPoint(selregion, true)
    return (mappoint) ? [selregion, mappoint[0], mappoint[1]] : oldsetting
  end

  def self.format(value)
    return value.inspect
  end

  def self.getMapNameList
    ret = []
    GameData::TownMap.each { |town_map| ret.push([town_map.id, town_map.name]) }
    return ret
  end
end

#===============================================================================
#
#===============================================================================
module WeatherEffectProperty
  def self.set(_settingname, oldsetting)
    oldsetting = [:None, 100] if !oldsetting
    options = []
    ids = []
    default = 0
    GameData::Weather.each do |w|
      default = ids.length if w.id == oldsetting[0]
      options.push(w.real_name)
      ids.push(w.id)
    end
    cmd = pbMessage(_INTL("Choose a weather effect."), options, -1, nil, default)
    return nil if cmd < 0 || ids[cmd] == :None
    params = ChooseNumberParams.new
    params.setRange(0, 100)
    params.setDefaultValue(oldsetting[1])
    number = pbMessageChooseNumber(_INTL("Set the probability of the weather."), params)
    return [ids[cmd], number]
  end

  def self.format(value)
    return (value) ? GameData::Weather.get(value[0]).real_name + ",#{value[1]}" : "-"
  end
end

#===============================================================================
#
#===============================================================================
module MapProperty
  def self.set(settingname, oldsetting)
    chosenmap = pbListScreen(settingname, MapLister.new(oldsetting || 0))
    return (chosenmap > 0) ? chosenmap : oldsetting
  end

  def self.defaultValue
    return nil
  end

  def self.format(value)
    return value.inspect
  end
end

#===============================================================================
#
#===============================================================================
module ItemNameProperty
  def self.set(settingname, oldsetting)
    return pbMessageFreeText(_INTL("Set the value for {1}.", settingname),
                             (oldsetting) ? oldsetting : "", false, 30)
  end

  def self.defaultValue
    return "???"
  end

  def self.format(value)
    return value
  end
end

#===============================================================================
#
#===============================================================================
module PocketProperty
  def self.set(_settingname, oldsetting)
    commands = Settings.bag_pocket_names.clone
    cmd = pbMessage(_INTL("Choose a pocket for this item."), commands, -1)
    return (cmd >= 0) ? cmd + 1 : oldsetting
  end

  def self.defaultValue
    return 1
  end

  def self.format(value)
    return _INTL("No Pocket") if value == 0
    return (value) ? Settings.bag_pocket_names[value - 1] : value.inspect
  end
end

#===============================================================================
#
#===============================================================================
module BaseStatsProperty
  def self.set(settingname, oldsetting)
    return oldsetting if !oldsetting
    properties = []
    data = []
    stat_ids = []
    GameData::Stat.each_main do |s|
      next if s.pbs_order < 0
      properties[s.pbs_order] = [_INTL("Base {1}", s.name), NonzeroLimitProperty.new(255),
                                 _INTL("Base {1} stat of the Pokémon.", s.name)]
      data[s.pbs_order] = oldsetting[s.pbs_order] || 10
      stat_ids[s.pbs_order] = s.id
    end
    if pbPropertyList(settingname, data, properties, true)
      ret = []
      stat_ids.each_with_index { |s, i| ret[i] = data[i] || 10 }
      oldsetting = ret
    end
    return oldsetting
  end

  def self.defaultValue
    ret = []
    GameData::Stat.each_main { |s| ret[s.pbs_order] = 10 if s.pbs_order >= 0 }
    return ret
  end

  def self.format(value)
    return value.join(",")
  end
end

#===============================================================================
#
#===============================================================================
module EffortValuesProperty
  def self.set(settingname, oldsetting)
    return oldsetting if !oldsetting
    properties = []
    data = []
    stat_ids = []
    GameData::Stat.each_main do |s|
      next if s.pbs_order < 0
      properties[s.pbs_order] = [_INTL("{1} EVs", s.name), LimitProperty.new(255),
                                 _INTL("Number of {1} Effort Value points gained from the Pokémon.", s.name)]
      data[s.pbs_order] = 0
      oldsetting.each { |ev| data[s.pbs_order] = ev[1] if ev[0] == s.id }
      stat_ids[s.pbs_order] = s.id
    end
    if pbPropertyList(settingname, data, properties, true)
      ret = []
      stat_ids.each_with_index do |s, i|
        index = GameData::Stat.get(s).pbs_order
        ret.push([s, data[index]]) if data[index] > 0
      end
      oldsetting = ret
    end
    return oldsetting
  end

  def self.defaultValue
    return []
  end

  def self.format(value)
    return "" if !value
    ret = ""
    value.each_with_index do |val, i|
      ret += "," if i > 0
      ret += GameData::Stat.get(val[0]).real_name_brief + "," + val[1].to_s
    end
    return ret
  end
end

#===============================================================================
#
#===============================================================================
module AbilityProperty
  def self.set(_settingname, oldsetting)
    ret = pbChooseAbilityList((oldsetting) ? oldsetting : nil)
    return ret || oldsetting
  end

  def self.defaultValue
    return nil
  end

  def self.format(value)
    return (value && GameData::Ability.exists?(value)) ? GameData::Ability.get(value).real_name : "-"
  end
end

#===============================================================================
#
#===============================================================================
class GameDataPoolProperty
  def initialize(game_data, allow_multiple = true, auto_sort = false)
    if !GameData.const_defined?(game_data.to_sym)
      raise _INTL("Couldn't find class {1} in module GameData.", game_data.to_s)
    end
    @game_data = game_data
    @game_data_module = GameData.const_get(game_data.to_sym)
    @allow_multiple = allow_multiple
    @auto_sort = auto_sort   # Alphabetically
  end

  def set(setting_name, old_setting)
    ret = old_setting
    old_setting.uniq! if !@allow_multiple
    old_setting.sort! if @auto_sort
    # Get all values already in the pool
    values = []
    values.push([nil, _INTL("[ADD VALUE]")])   # Value ID, name
    old_setting.each do |value|
      values.push([value, @game_data_module.get(value).real_name])
    end
    # Set things up
    command_window = pbListWindow([], 200)
    cmd = [0, 0]   # [input type, list index] (input type: 0=select, 1=swap up, 2=swap down)
    commands = []
    need_refresh = true
    # Edit value pool
    loop do
      if need_refresh
        if @auto_sort
          values.sort! { |a, b| (a[0].nil?) ? -1 : b[0].nil? ? 1 : a[1] <=> b[1] }
        end
        commands = values.map { |entry| entry[1] }
        need_refresh = false
      end
      # Choose a value
      cmd = pbCommands3(command_window, commands, -1, cmd[1], true)
      case cmd[0]   # 0=selected/cancelled, 1=pressed Action+Up, 2=pressed Action+Down
      when 1   # Swap value up
        if cmd[1] > 0 && cmd[1] < values.length - 1
          values[cmd[1] + 1], values[cmd[1]] = values[cmd[1]], values[cmd[1] + 1]
          need_refresh = true
        end
      when 2   # Swap value down
        if cmd[1] > 1
          values[cmd[1] - 1], values[cmd[1]] = values[cmd[1]], values[cmd[1] - 1]
          need_refresh = true
        end
      when 0
        if cmd[1] >= 0   # Chose an entry
          entry = values[cmd[1]]
          if entry[0].nil?   # Add new value
            new_value = pbChooseFromGameDataList(@game_data)
            if new_value
              if !@allow_multiple && values.any? { |val| val[0] == new_value }
                cmd[1] = values.index { |val| val[0] == new_value }
                next
              end
              values.push([new_value, @game_data_module.get(new_value).real_name])
              need_refresh = true
            end
          else   # Edit existing value
            case pbMessage("\\ts[]" + _INTL("Do what with this value?"),
                           [_INTL("Change value"), _INTL("Delete"), _INTL("Cancel")], 3)
            when 0   # Change value
              new_value = pbChooseFromGameDataList(@game_data, entry[0])
              if new_value && new_value != entry[0]
                if !@allow_multiple && values.any? { |val| val[0] == new_value }
                  values.delete_at(cmd[1])
                  cmd[1] = values.index { |val| val[0] == new_value }
                  need_refresh = true
                  next
                end
                entry[0] = new_value
                entry[1] = @game_data_module.get(new_value).real_name
                if @auto_sort
                  values.sort! { |a, b| a[1] <=> b[1] }
                  cmd[1] = values.index { |val| val[0] == new_value }
                end
                need_refresh = true
              end
            when 1   # Delete
              values.delete_at(cmd[1])
              cmd[1] = [cmd[1], values.length - 1].min
              need_refresh = true
            end
          end
        else   # Cancel/quit
          case pbMessage(_INTL("Apply changes?"),
                         [_INTL("Yes"), _INTL("No"), _INTL("Cancel")], 3)
          when 0
            values.shift   # Remove the "add value" option
            values.length.times do |i|
              values[i] = values[i][0]
            end
            values.compact!
            ret = values
            break
          when 1
            break
          end
        end
      end
    end
    command_window.dispose
    return ret
  end

  def defaultValue
    return []
  end

  def format(value)
    return value.map { |val| @game_data_module.get(val).real_name }.join(",")
  end
end

#===============================================================================
#
#===============================================================================
class EggMovesProperty < GameDataPoolProperty
  def initialize
    super(:Move, false, true)
  end
end

#===============================================================================
#
#===============================================================================
class EggGroupsProperty < GameDataPoolProperty
  def initialize
    super(:EggGroup, false, false)
  end
end

#===============================================================================
#
#===============================================================================
class AbilitiesProperty < GameDataPoolProperty
  def initialize
    super(:Ability, false, false)
  end
end

#===============================================================================
#
#===============================================================================
module LevelUpMovesProperty
  def self.set(_settingname, oldsetting)
    # Get all moves in move pool
    realcmds = []
    realcmds.push([-1, nil, -1, "-"])   # Level, move ID, index in this list, name
    oldsetting.length.times do |i|
      realcmds.push([oldsetting[i][0], oldsetting[i][1], i, GameData::Move.get(oldsetting[i][1]).real_name])
    end
    # Edit move pool
    cmdwin = pbListWindow([], 200)
    oldsel = -1
    ret = oldsetting
    cmd = [0, 0]
    commands = []
    refreshlist = true
    loop do
      if refreshlist
        realcmds.sort! { |a, b| (a[0] == b[0]) ? a[2] <=> b[2] : a[0] <=> b[0] }
        commands = []
        realcmds.each_with_index do |entry, i|
          if entry[0] == -1
            commands.push(_INTL("[ADD MOVE]"))
          else
            commands.push(_INTL("{1}: {2}", entry[0], entry[3]))
          end
          cmd[1] = i if oldsel >= 0 && entry[2] == oldsel
        end
      end
      refreshlist = false
      oldsel = -1
      cmd = pbCommands3(cmdwin, commands, -1, cmd[1], true)
      case cmd[0]
      when 1   # Swap move up (if both moves have the same level)
        if cmd[1] < realcmds.length - 1 && realcmds[cmd[1]][0] == realcmds[cmd[1] + 1][0]
          realcmds[cmd[1] + 1][2], realcmds[cmd[1]][2] = realcmds[cmd[1]][2], realcmds[cmd[1] + 1][2]
          refreshlist = true
        end
      when 2   # Swap move down (if both moves have the same level)
        if cmd[1] > 0 && realcmds[cmd[1]][0] == realcmds[cmd[1] - 1][0]
          realcmds[cmd[1] - 1][2], realcmds[cmd[1]][2] = realcmds[cmd[1]][2], realcmds[cmd[1] - 1][2]
          refreshlist = true
        end
      when 0
        if cmd[1] >= 0   # Chose an entry
          entry = realcmds[cmd[1]]
          if entry[0] == -1   # Add new move
            params = ChooseNumberParams.new
            params.setRange(0, GameData::GrowthRate.max_level)
            params.setDefaultValue(1)
            params.setCancelValue(-1)
            newlevel = pbMessageChooseNumber(_INTL("Choose a level."), params)
            if newlevel >= 0
              newmove = pbChooseMoveList
              if newmove
                havemove = -1
                realcmds.each do |e|
                  havemove = e[2] if e[0] == newlevel && e[1] == newmove
                end
                if havemove >= 0
                  oldsel = havemove
                else
                  maxid = -1
                  realcmds.each { |e| maxid = [maxid, e[2]].max }
                  realcmds.push([newlevel, newmove, maxid + 1, GameData::Move.get(newmove).real_name])
                end
                refreshlist = true
              end
            end
          else   # Edit existing move
            case pbMessage("\\ts[]" + _INTL("Do what with this move?"),
                           [_INTL("Change level"), _INTL("Change move"), _INTL("Delete"), _INTL("Cancel")], 4)
            when 0   # Change level
              params = ChooseNumberParams.new
              params.setRange(0, GameData::GrowthRate.max_level)
              params.setDefaultValue(entry[0])
              newlevel = pbMessageChooseNumber(_INTL("Choose a new level."), params)
              if newlevel >= 0 && newlevel != entry[0]
                havemove = -1
                realcmds.each do |e|
                  havemove = e[2] if e[0] == newlevel && e[1] == entry[1]
                end
                if havemove >= 0   # Move already known at new level; delete this move
                  realcmds.delete_at(cmd[1])
                  oldsel = havemove
                else   # Apply the new level
                  entry[0] = newlevel
                  oldsel = entry[2]
                end
                refreshlist = true
              end
            when 1   # Change move
              newmove = pbChooseMoveList(entry[1])
              if newmove && newmove != entry[1]
                havemove = -1
                realcmds.each do |e|
                  havemove = e[2] if e[0] == entry[0] && e[1] == newmove
                end
                if havemove >= 0   # New move already known at level; delete this move
                  realcmds.delete_at(cmd[1])
                  cmd[1] = [cmd[1], realcmds.length - 1].min
                  oldsel = havemove
                else   # Apply the new move
                  entry[1] = newmove
                  entry[3] = GameData::Move.get(newmove).real_name
                  oldsel = entry[2]
                end
                refreshlist = true
              end
            when 2   # Delete
              realcmds.delete_at(cmd[1])
              cmd[1] = [cmd[1], realcmds.length - 1].min
              refreshlist = true
            end
          end
        else   # Cancel/quit
          case pbMessage(_INTL("Save changes?"),
                         [_INTL("Yes"), _INTL("No"), _INTL("Cancel")], 3)
          when 0
            realcmds.shift
            realcmds.length.times do |i|
              realcmds[i].pop   # Remove name
              realcmds[i].pop   # Remove index in this list
            end
            realcmds.compact!
            ret = realcmds
            break
          when 1
            break
          end
        end
      end
    end
    cmdwin.dispose
    return ret
  end

  def self.defaultValue
    return []
  end

  def self.format(value)
    ret = ""
    value.length.times do |i|
      ret << "," if i > 0
      ret << sprintf("%s,%s", value[i][0], GameData::Move.get(value[i][1]).real_name)
    end
    return ret
  end
end

#===============================================================================
#
#===============================================================================
class EvolutionsProperty
  def initialize
    @methods = []
    @evo_ids = []
    GameData::Evolution.each_alphabetically do |e|
      @methods.push(e.real_name)
      @evo_ids.push(e.id)
    end
  end

  def edit_parameter(evo_method, value = nil)
    param_type = GameData::Evolution.get(evo_method).parameter
    return nil if param_type.nil?
    ret = value
    case param_type
    when :Item
      ret = pbChooseItemList(value)
    when :Move
      ret = pbChooseMoveList(value)
    when :Species
      ret = pbChooseSpeciesList(value)
    when :Type
      ret = pbChooseTypeList(value)
    when :Ability
      ret = pbChooseAbilityList(value)
    when String
      ret = pbMessageFreeText(_INTL("Enter a value."), ret || "", false, 250, Graphics.width)
      ret.strip!
      ret = nil if ret.empty?
    else
      params = ChooseNumberParams.new
      params.setRange(0, 65_535)
      params.setDefaultValue(value.to_i) if value
      params.setCancelValue(-1)
      ret = pbMessageChooseNumber(_INTL("Choose a parameter."), params)
      ret = nil if ret < 0
    end
    return (ret) ? ret.to_s : nil
  end

  def set(_settingname, oldsetting)
    ret = oldsetting
    cmdwin = pbListWindow([])
    commands = []
    realcmds = []
    realcmds.push([-1, 0, 0, -1])
    oldsetting.length.times do |i|
      realcmds.push([oldsetting[i][0], oldsetting[i][1], oldsetting[i][2], i])
    end
    refreshlist = true
    oldsel = -1
    cmd = [0, 0]
    loop do
      if refreshlist
        realcmds.sort! { |a, b| a[3] <=> b[3] }
        commands = []
        realcmds.length.times do |i|
          if realcmds[i][3] < 0
            commands.push(_INTL("[ADD EVOLUTION]"))
          else
            level = realcmds[i][2]
            evo_method_data = GameData::Evolution.get(realcmds[i][1])
            param_type = evo_method_data.parameter
            if param_type.nil?
              commands.push(_INTL("{1}: {2}",
                                  GameData::Species.get(realcmds[i][0]).name, evo_method_data.real_name))
            else
              if param_type.is_a?(Symbol) && !GameData.const_defined?(param_type)
                level = getConstantName(param_type, level)
              end
              level = "???" if !level || (level.is_a?(String) && level.empty?)
              commands.push(_INTL("{1}: {2}, {3}",
                                  GameData::Species.get(realcmds[i][0]).name, evo_method_data.real_name, level.to_s))
            end
          end
          cmd[1] = i if oldsel >= 0 && realcmds[i][3] == oldsel
        end
      end
      refreshlist = false
      oldsel = -1
      cmd = pbCommands3(cmdwin, commands, -1, cmd[1], true)
      case cmd[0]
      when 1   # Swap evolution up
        if cmd[1] > 0 && cmd[1] < realcmds.length - 1
          realcmds[cmd[1] + 1][3], realcmds[cmd[1]][3] = realcmds[cmd[1]][3], realcmds[cmd[1] + 1][3]
          refreshlist = true
        end
      when 2   # Swap evolution down
        if cmd[1] > 1
          realcmds[cmd[1] - 1][3], realcmds[cmd[1]][3] = realcmds[cmd[1]][3], realcmds[cmd[1] - 1][3]
          refreshlist = true
        end
      when 0
        if cmd[1] >= 0
          entry = realcmds[cmd[1]]
          if entry[3] == -1   # Add new evolution path
            pbMessage(_INTL("Choose an evolved form, method and parameter."))
            newspecies = pbChooseSpeciesList
            if newspecies
              newmethodindex = pbMessage(_INTL("Choose an evolution method."), @methods, -1)
              if newmethodindex >= 0
                newmethod = @evo_ids[newmethodindex]
                newparam = edit_parameter(newmethod)
                if newparam || GameData::Evolution.get(newmethod).parameter.nil?
                  existing_evo = -1
                  realcmds.length.times do |i|
                    existing_evo = realcmds[i][3] if realcmds[i][0] == newspecies &&
                                                     realcmds[i][1] == newmethod &&
                                                     realcmds[i][2] == newparam
                  end
                  if existing_evo >= 0
                    oldsel = existing_evo
                  else
                    maxid = -1
                    realcmds.each { |i| maxid = [maxid, i[3]].max }
                    realcmds.push([newspecies, newmethod, newparam, maxid + 1])
                    oldsel = maxid + 1
                  end
                  refreshlist = true
                end
              end
            end
          else   # Edit evolution
            case pbMessage("\\ts[]" + _INTL("Do what with this evolution?"),
                           [_INTL("Change species"), _INTL("Change method"),
                            _INTL("Change parameter"), _INTL("Delete"), _INTL("Cancel")], 5)
            when 0   # Change species
              newspecies = pbChooseSpeciesList(entry[0])
              if newspecies
                existing_evo = -1
                realcmds.length.times do |i|
                  existing_evo = realcmds[i][3] if realcmds[i][0] == newspecies &&
                                                   realcmds[i][1] == entry[1] &&
                                                   realcmds[i][2] == entry[2]
                end
                if existing_evo >= 0
                  realcmds.delete_at(cmd[1])
                  oldsel = existing_evo
                else
                  entry[0] = newspecies
                  oldsel = entry[3]
                end
                refreshlist = true
              end
            when 1   # Change method
              default_index = 0
              @evo_ids.each_with_index { |evo, i| default_index = i if evo == entry[1] }
              newmethodindex = pbMessage(_INTL("Choose an evolution method."), @methods, -1, nil, default_index)
              if newmethodindex >= 0
                newmethod = @evo_ids[newmethodindex]
                existing_evo = -1
                realcmds.length.times do |i|
                  existing_evo = realcmds[i][3] if realcmds[i][0] == entry[0] &&
                                                   realcmds[i][1] == newmethod &&
                                                   realcmds[i][2] == entry[2]
                end
                if existing_evo >= 0
                  realcmds.delete_at(cmd[1])
                  oldsel = existing_evo
                elsif newmethod != entry[1]
                  entry[1] = newmethod
                  entry[2] = 0
                  oldsel = entry[3]
                end
                refreshlist = true
              end
            when 2   # Change parameter
              if GameData::Evolution.get(entry[1]).parameter.nil?
                pbMessage(_INTL("This evolution method doesn't use a parameter."))
              else
                newparam = edit_parameter(entry[1], entry[2])
                if newparam
                  existing_evo = -1
                  realcmds.length.times do |i|
                    existing_evo = realcmds[i][3] if realcmds[i][0] == entry[0] &&
                                                     realcmds[i][1] == entry[1] &&
                                                     realcmds[i][2] == newparam
                  end
                  if existing_evo >= 0
                    realcmds.delete_at(cmd[1])
                    oldsel = existing_evo
                  else
                    entry[2] = newparam
                    oldsel = entry[3]
                  end
                  refreshlist = true
                end
              end
            when 3   # Delete
              realcmds.delete_at(cmd[1])
              cmd[1] = [cmd[1], realcmds.length - 1].min
              refreshlist = true
            end
          end
        else
          cmd2 = pbMessage(_INTL("Save changes?"),
                           [_INTL("Yes"), _INTL("No"), _INTL("Cancel")], 3)
          if [0, 1].include?(cmd2)
            if cmd2 == 0
              realcmds.length.times do |i|
                realcmds[i].pop
                realcmds[i] = nil if realcmds[i][0] == -1
              end
              realcmds.compact!
              ret = realcmds
            end
            break
          end
        end
      end
    end
    cmdwin.dispose
    return ret
  end

  def defaultValue
    return []
  end

  def format(value)
    return "" if !value
    ret = ""
    value.length.times do |i|
      ret << "," if i > 0
      ret << (value[i][0].to_s + ",")
      ret << (value[i][1].to_s + ",")
      ret << value[i][2].to_s if value[i][2]
    end
    return ret
  end
end

#===============================================================================
#
#===============================================================================
module EncounterSlotProperty
  def self.set(setting_name, data)
    max_level = GameData::GrowthRate.max_level
    if !data
      data = [20, nil, 5, 5]
      GameData::Species.each do |species_data|
        data[1] = species_data.species
        break
      end
    end
    data[3] = data[2] if !data[3]
    properties = [
      [_INTL("Probability"),   NonzeroLimitProperty.new(999),       _INTL("Relative probability of choosing this slot.")],
      [_INTL("Species"),       SpeciesFormProperty.new(data[1]),    _INTL("A Pokémon species/form.")],
      [_INTL("Minimum level"), NonzeroLimitProperty.new(max_level), _INTL("Minimum level of this species (1-{1}).", max_level)],
      [_INTL("Maximum level"), NonzeroLimitProperty.new(max_level), _INTL("Maximum level of this species (1-{1}).", max_level)]
    ]
    pbPropertyList(setting_name, data, properties, false)
    if data[2] > data[3]
      data[3], data[2] = data[2], data[3]
    end
    return data
  end

  def self.defaultValue
    return nil
  end

  def self.format(value)
    return "-" if !value
    species_data = GameData::Species.get(value[1])
    if species_data.form > 0
      if value[2] == value[3]
        return sprintf("%d, %s_%d (Lv.%d)", value[0],
                       species_data.real_name, species_data.form, value[2])
      end
      return sprintf("%d, %s_%d (Lv.%d-%d)", value[0],
                     species_data.real_name, species_data.form, value[2], value[3])
    end
    if value[2] == value[3]
      return sprintf("%d, %s (Lv.%d)", value[0], species_data.real_name, value[2])
    end
    return sprintf("%d, %s (Lv.%d-%d)", value[0], species_data.real_name, value[2], value[3])
  end
end

#===============================================================================
# Core property editor script
#===============================================================================
def pbPropertyList(title, data, properties, saveprompt = false)
  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 99999
  list = pbListWindow([], Graphics.width / 2)
  list.viewport = viewport
  list.z        = 2
  title = Window_UnformattedTextPokemon.newWithSize(
    title, list.width, 0, Graphics.width / 2, 64, viewport
  )
  title.z = 2
  desc = Window_UnformattedTextPokemon.newWithSize(
    "", list.width, title.height, Graphics.width / 2, Graphics.height - title.height, viewport
  )
  desc.z = 2
  selectedmap = -1
  retval = nil
  commands = []
  properties.length.times do |i|
    propobj = properties[i][1]
    commands.push(sprintf("%s=%s", properties[i][0], propobj.format(data[i])))
  end
  list.commands = commands
  list.index    = 0
  loop do
    loop do
      Graphics.update
      Input.update
      list.update
      desc.update
      if list.index != selectedmap
        desc.text = properties[list.index][2]
        selectedmap = list.index
      end
      if Input.trigger?(Input::ACTION)
        propobj = properties[selectedmap][1]
        if propobj != ReadOnlyProperty && !propobj.is_a?(ReadOnlyProperty) &&
           pbConfirmMessage(_INTL("Reset the setting {1}?", properties[selectedmap][0]))
          if propobj.respond_to?("defaultValue")
            data[selectedmap] = propobj.defaultValue
          else
            data[selectedmap] = nil
          end
        end
        commands.clear
        properties.length.times do |i|
          propobj = properties[i][1]
          commands.push(sprintf("%s=%s", properties[i][0], propobj.format(data[i])))
        end
        list.commands = commands
      elsif Input.trigger?(Input::BACK)
        selectedmap = -1
        break
      elsif Input.trigger?(Input::USE)
        propobj = properties[selectedmap][1]
        oldsetting = data[selectedmap]
        newsetting = propobj.set(properties[selectedmap][0], oldsetting)
        data[selectedmap] = newsetting
        commands.clear
        properties.length.times do |i|
          propobj = properties[i][1]
          commands.push(sprintf("%s=%s", properties[i][0], propobj.format(data[i])))
        end
        list.commands = commands
        break
      end
    end
    if selectedmap == -1 && saveprompt
      cmd = pbMessage(_INTL("Save changes?"),
                      [_INTL("Yes"), _INTL("No"), _INTL("Cancel")], 3)
      if cmd == 2
        selectedmap = list.index
      else
        retval = (cmd == 0)
      end
    end
    break unless selectedmap != -1
  end
  title.dispose
  list.dispose
  desc.dispose
  Input.update
  return retval
end
