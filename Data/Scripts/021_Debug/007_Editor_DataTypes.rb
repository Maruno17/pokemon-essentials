#===============================================================================
# Data type properties
#===============================================================================
module UndefinedProperty
  def self.set(_settingname,oldsetting)
    pbMessage(_INTL("This property can't be edited here at this time."))
    return oldsetting
  end

  def self.format(value)
    return value.inspect
  end
end



module ReadOnlyProperty
  def self.set(_settingname,oldsetting)
    pbMessage(_INTL("This property cannot be edited."))
    return oldsetting
  end

  def self.format(value)
    return value.inspect
  end
end



class UIntProperty
  def initialize(maxdigits)
    @maxdigits = maxdigits
  end

  def set(settingname,oldsetting)
    params = ChooseNumberParams.new
    params.setMaxDigits(@maxdigits)
    params.setDefaultValue(oldsetting || 0)
    return pbMessageChooseNumber(_INTL("Set the value for {1}.",settingname),params)
  end

  def defaultValue
    return 0
  end

  def format(value)
    return value.inspect
  end
end



class LimitProperty
  def initialize(maxvalue)
    @maxvalue = maxvalue
  end

  def set(settingname,oldsetting)
    oldsetting = 1 if !oldsetting
    params = ChooseNumberParams.new
    params.setRange(0,@maxvalue)
    params.setDefaultValue(oldsetting)
    return pbMessageChooseNumber(_INTL("Set the value for {1} (0-#{@maxvalue}).",settingname),params)
  end

  def defaultValue
    return 0
  end

  def format(value)
    return value.inspect
  end
end



class LimitProperty2
  def initialize(maxvalue)
    @maxvalue = maxvalue
  end

  def set(settingname,oldsetting)
    oldsetting = 0 if !oldsetting
    params = ChooseNumberParams.new
    params.setRange(0,@maxvalue)
    params.setDefaultValue(oldsetting)
    params.setCancelValue(-1)
    ret = pbMessageChooseNumber(_INTL("Set the value for {1} (0-#{@maxvalue}).",settingname),params)
    return (ret>=0) ? ret : nil
  end

  def defaultValue
    return nil
  end

  def format(value)
    return (value) ? value.inspect : "-"
  end
end



class NonzeroLimitProperty
  def initialize(maxvalue)
    @maxvalue = maxvalue
  end

  def set(settingname,oldsetting)
    oldsetting = 1 if !oldsetting
    params = ChooseNumberParams.new
    params.setRange(1,@maxvalue)
    params.setDefaultValue(oldsetting)
    return pbMessageChooseNumber(_INTL("Set the value for {1}.",settingname),params)
  end

  def defaultValue
    return 1
  end

  def format(value)
    return value.inspect
  end
end



module BooleanProperty
  def self.set(settingname,_oldsetting)
    return pbConfirmMessage(_INTL("Enable the setting {1}?",settingname)) ? true : false
  end

  def self.format(value)
    return value.inspect
  end
end



module BooleanProperty2
  def self.set(_settingname,_oldsetting)
    ret = pbShowCommands(nil,[_INTL("True"),_INTL("False")],-1)
    return (ret>=0) ? (ret==0) : nil
  end

  def self.defaultValue
    return nil
  end

  def self.format(value)
    return (value) ? _INTL("True") : (value!=nil) ? _INTL("False") : "-"
  end
end



module StringProperty
  def self.set(settingname,oldsetting)
    return pbMessageFreeText(_INTL("Set the value for {1}.",settingname),
       (oldsetting) ? oldsetting : "",false,250,Graphics.width)
  end

  def self.format(value)
    return value
  end
end



class LimitStringProperty
  def initialize(limit)
    @limit = limit
  end

  def format(value)
    return value
  end

  def set(settingname,oldsetting)
    return pbMessageFreeText(_INTL("Set the value for {1}.",settingname),
       (oldsetting) ? oldsetting : "",false,@limit)
  end
end



class EnumProperty
  def initialize(values)
    @values = values
  end

  def set(settingname,oldsetting)
    commands = []
    for value in @values
      commands.push(value)
    end
    cmd = pbMessage(_INTL("Choose a value for {1}.",settingname),commands,-1)
    return oldsetting if cmd<0
    return cmd
  end

  def defaultValue
    return 0
  end

  def format(value)
    return (value) ? @values[value] : value.inspect
  end
end



module BGMProperty
  def self.set(settingname,oldsetting)
    chosenmap = pbListScreen(settingname,MusicFileLister.new(true,oldsetting))
    return (chosenmap && chosenmap!="") ? chosenmap : oldsetting
  end

  def self.format(value)
    return value
  end
end



module MEProperty
  def self.set(settingname,oldsetting)
    chosenmap = pbListScreen(settingname,MusicFileLister.new(false,oldsetting))
    return (chosenmap && chosenmap!="") ? chosenmap : oldsetting
  end

  def self.format(value)
    return value
  end
end



module WindowskinProperty
  def self.set(settingname,oldsetting)
    chosenmap = pbListScreen(settingname,GraphicsLister.new("Graphics/Windowskins/",oldsetting))
    return (chosenmap && chosenmap!="") ? chosenmap : oldsetting
  end

  def self.format(value)
    return value
  end
end



module TrainerTypeProperty
  def self.set(settingname, oldsetting)
    chosenmap = pbListScreen(settingname, TrainerTypeLister.new(0, false))
    return chosenmap || oldsetting
  end

  def self.format(value)
    return (value && GameData::TrainerType.exists?(value)) ? GameData::TrainerType.get(value).real_name : "-"
  end
end



module SpeciesProperty
  def self.set(_settingname,oldsetting)
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



module SpeciesFormProperty
  def self.set(_settingname,oldsetting)
    ret = pbChooseSpeciesFormList(oldsetting || nil)
    return ret || oldsetting
  end

  def self.defaultValue
    return nil
  end

  def self.format(value)
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



class GenderProperty
  def set(_settingname,_oldsetting)
    ret = pbShowCommands(nil,[_INTL("Male"),_INTL("Female")],-1)
    return (ret>=0) ? ret : nil
  end

  def defaultValue
    return nil
  end

  def format(value)
    return _INTL("-") if !value
    return (value==0) ? _INTL("Male") : (value==1) ? _INTL("Female") : "-"
  end
end



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



module NatureProperty
  def self.set(_settingname,_oldsetting)
    commands = []
    (PBNatures.getCount).times do |i|
      commands.push(PBNatures.getName(i))
    end
    ret = pbShowCommands(nil,commands,-1)
    return (ret>=0) ? ret : nil
  end

  def self.defaultValue
    return nil
  end

  def self.format(value)
    return (value) ? getConstantName(PBNatures,value) : "-"
  end
end



class IVsProperty
  def initialize(limit)
    @limit = limit
  end

  def set(settingname, oldsetting)
    oldsetting = [nil] if !oldsetting
    for i in 0...6
      oldsetting[i] = oldsetting[0] if !oldsetting[i]
    end
    properties = []
    properties[PBStats::HP]      = [_INTL("HP"),      LimitProperty2.new(@limit), _INTL("Individual values for the Pokémon's HP stat (0-{1}).", @limit)]
    properties[PBStats::ATTACK]  = [_INTL("Attack"),  LimitProperty2.new(@limit), _INTL("Individual values for the Pokémon's Attack stat (0-{1}).", @limit)]
    properties[PBStats::DEFENSE] = [_INTL("Defense"), LimitProperty2.new(@limit), _INTL("Individual values for the Pokémon's Defense stat (0-{1}).", @limit)]
    properties[PBStats::SPATK]   = [_INTL("Sp. Atk"), LimitProperty2.new(@limit), _INTL("Individual values for the Pokémon's Sp. Atk stat (0-{1}).", @limit)]
    properties[PBStats::SPDEF]   = [_INTL("Sp. Def"), LimitProperty2.new(@limit), _INTL("Individual values for the Pokémon's Sp. Def stat (0-{1}).", @limit)]
    properties[PBStats::SPEED]   = [_INTL("Speed"),   LimitProperty2.new(@limit), _INTL("Individual values for the Pokémon's Speed stat (0-{1}).", @limit)]
    pbPropertyList(settingname, oldsetting, properties, false)
    hasNonNil = false
    firstVal = oldsetting[0] || 0
    for i in 0...6
      (oldsetting[i]) ? hasNonNil = true : oldsetting[i] = firstVal
    end
    return (hasNonNil) ? oldsetting : nil
  end

  def defaultValue
    return nil
  end

  def format(value)
    return "-" if !value
    return value[0].to_s if value.uniq.length == 1
    ret = ""
    for i in 0...6
      ret.concat(",") if i > 0
      ret.concat((value[i] || 0).to_s)
    end
    return ret
  end
end



class EVsProperty
  def initialize(limit)
    @limit = limit
  end

  def set(settingname, oldsetting)
    oldsetting = [nil] if !oldsetting
    for i in 0...6
      oldsetting[i] = oldsetting[0] if !oldsetting[i]
    end
    properties = []
    properties[PBStats::HP]      = [_INTL("HP"),      LimitProperty2.new(@limit), _INTL("Effort values for the Pokémon's HP stat (0-{1}).", @limit)]
    properties[PBStats::ATTACK]  = [_INTL("Attack"),  LimitProperty2.new(@limit), _INTL("Effort values for the Pokémon's Attack stat (0-{1}).", @limit)]
    properties[PBStats::DEFENSE] = [_INTL("Defense"), LimitProperty2.new(@limit), _INTL("Effort values for the Pokémon's Defense stat (0-{1}).", @limit)]
    properties[PBStats::SPATK]   = [_INTL("Sp. Atk"), LimitProperty2.new(@limit), _INTL("Effort values for the Pokémon's Sp. Atk stat (0-{1}).", @limit)]
    properties[PBStats::SPDEF]   = [_INTL("Sp. Def"), LimitProperty2.new(@limit), _INTL("Effort values for the Pokémon's Sp. Def stat (0-{1}).", @limit)]
    properties[PBStats::SPEED]   = [_INTL("Speed"),   LimitProperty2.new(@limit), _INTL("Effort values for the Pokémon's Speed stat (0-{1}).", @limit)]
    loop do
      pbPropertyList(settingname, oldsetting, properties, false)
      evtotal = 0
      for i in 0...6
        evtotal += oldsetting[i] if oldsetting[i]
      end
      if evtotal > Pokemon::EV_LIMIT
        pbMessage(_INTL("Total EVs ({1}) are greater than allowed ({2}). Please reduce them.", evtotal, Pokemon::EV_LIMIT))
      else
        break
      end
    end
    hasNonNil = false
    firstVal = oldsetting[0] || 0
    for i in 0...6
      (oldsetting[i]) ? hasNonNil = true : oldsetting[i] = firstVal
    end
    return (hasNonNil) ? oldsetting : nil
  end

  def defaultValue
    return nil
  end

  def format(value)
    return "-" if !value
    return value[0].to_s if value.uniq.length == 1
    ret = ""
    for i in 0...6
      ret.concat(",") if i > 0
      ret.concat((value[i] || 0).to_s)
    end
    return ret
  end
end



class BallProperty
  def initialize(pokemondata)
    @pokemondata = pokemondata
  end

  def set(_settingname,oldsetting)
    ret = pbChooseBallList((oldsetting) ? oldsetting : -1)
    return (ret>=0) ? ret : (oldsetting) ? oldsetting : nil
  end

  def defaultValue
    return nil
  end

  def format(value)
    return (value) ? pbBallTypeToItem(value).name : "-"
  end
end



module CharacterProperty
  def self.set(settingname,oldsetting)
    chosenmap = pbListScreen(settingname,GraphicsLister.new("Graphics/Characters/",oldsetting))
    return (chosenmap && chosenmap!="") ? chosenmap : oldsetting
  end

  def self.format(value)
    return value
  end
end



module PlayerProperty
  def self.set(settingname,oldsetting)
    oldsetting = [0,"xxx","xxx","xxx","xxx","xxx","xxx","xxx"] if !oldsetting
    properties = [
       [_INTL("Trainer Type"), TrainerTypeProperty, _INTL("Trainer type of this player.")],
       [_INTL("Sprite"),       CharacterProperty,   _INTL("Walking character sprite.")],
       [_INTL("Cycling"),      CharacterProperty,   _INTL("Cycling character sprite.")],
       [_INTL("Surfing"),      CharacterProperty,   _INTL("Surfing character sprite.")],
       [_INTL("Running"),      CharacterProperty,   _INTL("Running character sprite.")],
       [_INTL("Diving"),       CharacterProperty,   _INTL("Diving character sprite.")],
       [_INTL("Fishing"),      CharacterProperty,   _INTL("Fishing character sprite.")],
       [_INTL("Field Move"),   CharacterProperty,   _INTL("Using a field move character sprite.")]
    ]
    pbPropertyList(settingname,oldsetting,properties,false)
    return oldsetting
  end

  def self.format(value)
    return value.inspect
  end
end



module MapSizeProperty
  def self.set(settingname,oldsetting)
    oldsetting = [0,""] if !oldsetting
    properties = [
       [_INTL("Width"),NonzeroLimitProperty.new(30),_INTL("The width of this map in Region Map squares.")],
       [_INTL("Valid Squares"),StringProperty,_INTL("A series of 1s and 0s marking which squares are part of this map (1=part, 0=not part).")],
    ]
    pbPropertyList(settingname,oldsetting,properties,false)
    return oldsetting
  end

  def self.format(value)
    return value.inspect
  end
end



def chooseMapPoint(map,rgnmap=false)
  viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z=99999
  title=Window_UnformattedTextPokemon.new(_INTL("Click a point on the map."))
  title.x=0
  title.y=Graphics.height-64
  title.width=Graphics.width
  title.height=64
  title.viewport=viewport
  title.z=2
  if rgnmap
    sprite=RegionMapSprite.new(map,viewport)
  else
    sprite=MapSprite.new(map,viewport)
  end
  sprite.z=2
  ret=nil
  loop do
    Graphics.update
    Input.update
    xy=sprite.getXY
    if xy
      ret=xy
      break
    end
    if Input.trigger?(Input::B)
      ret=nil
      break
    end
  end
  sprite.dispose
  title.dispose
  return ret
end



module MapCoordsProperty
  def self.set(settingname,oldsetting)
    chosenmap = pbListScreen(settingname,MapLister.new((oldsetting) ? oldsetting[0] : 0))
    if chosenmap>=0
      mappoint = chooseMapPoint(chosenmap)
      return (mappoint) ? [chosenmap,mappoint[0],mappoint[1]] : oldsetting
    else
      return oldsetting
    end
  end

  def self.format(value)
    return value.inspect
  end
end



module MapCoordsFacingProperty
  def self.set(settingname,oldsetting)
    chosenmap = pbListScreen(settingname,MapLister.new((oldsetting) ? oldsetting[0] : 0))
    if chosenmap>=0
      mappoint = chooseMapPoint(chosenmap)
      if mappoint
        facing = pbMessage(_INTL("Choose the direction to face in."),
           [_INTL("Down"),_INTL("Left"),_INTL("Right"),_INTL("Up")],-1)
        return (facing>=0) ? [chosenmap,mappoint[0],mappoint[1],[2,4,6,8][facing]] : oldsetting
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



module RegionMapCoordsProperty
  def self.set(_settingname,oldsetting)
    regions = self.getMapNameList
    selregion = -1
    if regions.length==0
      pbMessage(_INTL("No region maps are defined."))
      return oldsetting
    elsif regions.length==1
      selregion = regions[0][0]
    else
      cmds = []
      for region in regions
        cmds.push(region[1])
      end
      selcmd = pbMessage(_INTL("Choose a region map."),cmds,-1)
      if selcmd>=0
        selregion = regions[selcmd][0]
      else
        return oldsetting
      end
    end
    mappoint = chooseMapPoint(selregion,true)
    return (mappoint) ? [selregion,mappoint[0],mappoint[1]] : oldsetting
  end

  def self.format(value)
    return value.inspect
  end

  def self.getMapNameList
    mapdata = pbLoadTownMapData
    ret=[]
    for i in 0...mapdata.length
      next if !mapdata[i]
      ret.push(
         [i,pbGetMessage(MessageTypes::RegionNames,i)]
      )
    end
    return ret
  end
end



module WeatherEffectProperty
  def self.set(_settingname,oldsetting)
    options = []
    for i in 0..PBFieldWeather.maxValue
      options.push(getConstantName(PBFieldWeather,i) || "ERROR")
    end
    cmd = pbMessage(_INTL("Choose a weather effect."),options,1)
    if cmd==0
      return nil
    else
      params = ChooseNumberParams.new
      params.setRange(0,100)
      params.setDefaultValue((oldsetting) ? oldsetting[1] : 100)
      number = pbMessageChooseNumber(_INTL("Set the probability of the weather."),params)
      return [cmd,number]
    end
  end

  def self.format(value)
    return (value) ? (getConstantName(PBFieldWeather,value[0]) || "ERROR")+",#{value[1]}" : "-"
  end
end



module EnvironmentProperty
  def self.set(_settingname,_oldsetting)
    options = []
    for i in 0..PBEnvironment.maxValue
      options.push(getConstantName(PBEnvironment,i) || "ERROR")
    end
    cmd = pbMessage(_INTL("Choose an environment."),options,1)
    return cmd
  end

  def self.format(value)
    return (value) ? (getConstantName(PBEnvironment,value) || "ERROR") : "-"
  end
end



module MapProperty
  def self.set(settingname,oldsetting)
    chosenmap = pbListScreen(settingname,MapLister.new(oldsetting ? oldsetting : 0))
    return (chosenmap>0) ? chosenmap : oldsetting
  end

  def self.defaultValue
    return 0
  end

  def self.format(value)
    return value.inspect
  end
end



module ItemNameProperty
  def self.set(settingname, oldsetting)
    return pbMessageFreeText(_INTL("Set the value for {1}.",settingname),
       (oldsetting) ? oldsetting : "",false,30)
  end

  def self.defaultValue
    return "???"
  end

  def self.format(value)
    return value
  end
end



module PocketProperty
  def self.pocketnames
    return [_INTL("Items"), _INTL("Medicine"), _INTL("Poké Balls"),
       _INTL("TMs & HMs"), _INTL("Berries"), _INTL("Mail"),
       _INTL("Battle Items"), _INTL("Key Items")]
  end

  def self.set(_settingname, oldsetting)
    cmd = pbMessage(_INTL("Choose a pocket for this item."), pocketnames(), -1)
    return (cmd >= 0) ? cmd + 1 : oldsetting
  end

  def self.defaultValue
    return 1
  end

  def self.format(value)
    return _INTL("No Pocket") if value == 0
    return (value) ? pocketnames[value - 1] : value.inspect
  end
end



module BaseStatsProperty
  def self.set(settingname,oldsetting)
    return oldsetting if !oldsetting
    properties = []
    properties[PBStats::HP]      = _INTL("Base HP"),          NonzeroLimitProperty.new(255), _INTL("Base HP stat of the Pokémon.")
    properties[PBStats::ATTACK]  = _INTL("Base Attack"),      NonzeroLimitProperty.new(255), _INTL("Base Attack stat of the Pokémon.")
    properties[PBStats::DEFENSE] = _INTL("Base Defense"),     NonzeroLimitProperty.new(255), _INTL("Base Defense stat of the Pokémon.")
    properties[PBStats::SPATK]   = _INTL("Base Sp. Attack"),  NonzeroLimitProperty.new(255), _INTL("Base Special Attack stat of the Pokémon.")
    properties[PBStats::SPDEF]   = _INTL("Base Sp. Defense"), NonzeroLimitProperty.new(255), _INTL("Base Special Defense stat of the Pokémon.")
    properties[PBStats::SPEED]   = _INTL("Base Speed"),       NonzeroLimitProperty.new(255), _INTL("Base Speed stat of the Pokémon.")
    if !pbPropertyList(settingname,oldsetting,properties,true)
      oldsetting = nil
    else
      oldsetting = nil if !oldsetting[0] || oldsetting[0]==0
    end
    return oldsetting
  end

  def self.defaultValue
    return 10
  end

  def self.format(value)
    return value.inspect
  end
end



module EffortValuesProperty
  def self.set(settingname,oldsetting)
    return oldsetting if !oldsetting
    properties = []
    properties[PBStats::HP]      = [_INTL("HP EVs"),          LimitProperty.new(255), _INTL("Number of HP Effort Value points gained from the Pokémon.")]
    properties[PBStats::ATTACK]  = [_INTL("Attack EVs"),      LimitProperty.new(255), _INTL("Number of Attack Effort Value points gained from the Pokémon.")]
    properties[PBStats::DEFENSE] = [_INTL("Defense EVs"),     LimitProperty.new(255), _INTL("Number of Defense Effort Value points gained from the Pokémon.")]
    properties[PBStats::SPATK]   = [_INTL("Sp. Attack EVs"),  LimitProperty.new(255), _INTL("Number of Special Attack Effort Value points gained from the Pokémon.")]
    properties[PBStats::SPDEF]   = [_INTL("Sp. Defense EVs"), LimitProperty.new(255), _INTL("Number of Special Defense Effort Value points gained from the Pokémon.")]
    properties[PBStats::SPEED]   = [_INTL("Speed EVs"),       LimitProperty.new(255), _INTL("Number of Speed Effort Value points gained from the Pokémon.")]
    if !pbPropertyList(settingname,oldsetting,properties,true)
      oldsetting = nil
    else
      oldsetting = nil if !oldsetting[0] || oldsetting[0]==0
    end
    return oldsetting
  end

  def self.defaultValue
    return 0
  end

  def self.format(value)
    return value.inspect
  end
end



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



module MovePoolProperty
  def self.set(_settingname, oldsetting)
    # Get all moves in move pool
    realcmds = []
    realcmds.push([-1, nil, -1, "-"])   # Level, move ID, index in this list, name
    for i in 0...oldsetting.length
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
            params.setRange(0, PBExperience.maxLevel)
            params.setDefaultValue(1)
            params.setCancelValue(-1)
            newlevel = pbMessageChooseNumber(_INTL("Choose a level."),params)
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
            case pbMessage(_INTL("\\ts[]Do what with this move?"),
               [_INTL("Change level"), _INTL("Change move"), _INTL("Delete"), _INTL("Cancel")], 4)
            when 0   # Change level
              params = ChooseNumberParams.new
              params.setRange(0, PBExperience.maxLevel)
              params.setDefaultValue(entry[0])
              newlevel = pbMessageChooseNumber(_INTL("Choose a new level."), params)
              if newlevel >= 0 && newlevel != entry[0]
                havemove = -1
                realcmds.each do |e|
                  havemove = e[2] if e[0] == newlevel && e[1] == entry[1]
                end
                if havemove >= 0   # Move already known at new level; delete this move
                  realcmds[cmd[1]] = nil
                  realcmds.compact!
                  oldsel = havemove
                else   # Apply the new level
                  entry[0] = newlevel
                  oldsel = entry[2]
                end
                refreshlist = true
              end
            when 1   # Change move
              newmove = pbChooseMoveList(entry[1])
              if newmove
                havemove = -1
                realcmds.each do |e|
                  havemove = e[2] if e[0] == entry[0] && e[1] == newmove
                end
                if havemove >= 0   # New move already known at level; delete this move
                  realcmds[cmd[1]] = nil
                  realcmds.compact!
                  oldsel = havemove
                else   # Apply the new move
                  entry[1] = newmove
                  entry[3] = GameData::Move.get(newmove).real_name
                  oldsel = entry[2]
                end
                refreshlist = true
              end
            when 2   # Delete
              realcmds[cmd[1]] = nil
              realcmds.compact!
              cmd[1] = [cmd[1], realcmds.length - 1].min
              refreshlist = true
            end
          end
        else   # Cancel/quit
          case pbMessage(_INTL("Save changes?"),
             [_INTL("Yes"), _INTL("No"), _INTL("Cancel")], 3)
          when 0
            for i in 0...realcmds.length
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
    for i in 0...value.length
      ret << "," if i > 0
      ret << sprintf("%s,%s", value[i][0], GameData::Move.get(value[i][1]).real_name)
    end
    return ret
  end
end



module EggMovesProperty
  def self.set(_settingname, oldsetting)
    # Get all egg moves
    realcmds = []
    realcmds.push([nil, _INTL("[ADD MOVE]"), -1])
    for i in 0...oldsetting.length
      realcmds.push([oldsetting[i], GameData::Move.get(oldsetting[i]).real_name, 0])
    end
    # Edit egg moves list
    cmdwin = pbListWindow([], 200)
    oldsel = nil
    ret = oldsetting
    cmd = 0
    commands = []
    refreshlist = true
    loop do
      if refreshlist
        realcmds.sort! { |a, b| (a[2] == b[2]) ? a[1] <=> b[1] : a[2] <=> b[2] }
        commands = []
        realcmds.each_with_index do |entry, i|
          commands.push(entry[1])
          cmd = i if oldsel && entry[0] == oldsel
        end
      end
      refreshlist = false
      oldsel = nil
      cmd = pbCommands2(cmdwin, commands, -1, cmd, true)
      if cmd >= 0   # Chose an entry
        entry = realcmds[cmd]
        if entry[2] == -1   # Add new move
          newmove = pbChooseMoveList
          if newmove
            if realcmds.any? { |e| e[0] == newmove }
              oldsel = newmove   # Already have move; just move cursor to it
            else
              realcmds.push([newmove, GameData::Move.get(newmove).name, 0])
            end
            refreshlist = true
          end
        else   # Edit move
          case pbMessage(_INTL("\\ts[]Do what with this move?"),
             [_INTL("Change move"), _INTL("Delete"), _INTL("Cancel")], 3)
          when 0   # Change move
            newmove = pbChooseMoveList(entry[0])
            if newmove
              if realcmds.any? { |e| e[0] == newmove }   # Already have move; delete this one
                realcmds[cmd] = nil
                realcmds.compact!
                cmd = [cmd, realcmds.length - 1].min
              else   # Change move
                realcmds[cmd] = [newmove, GameData::Move.get(newmove).name, 0]
              end
              oldsel = newmove
              refreshlist = true
            end
          when 1   # Delete
            realcmds[cmd] = nil
            realcmds.compact!
            cmd = [cmd, realcmds.length - 1].min
            refreshlist = true
          end
        end
      else   # Cancel/quit
        case pbMessage(_INTL("Save changes?"),
           [_INTL("Yes"), _INTL("No"), _INTL("Cancel")], 3)
        when 0
          for i in 0...realcmds.length
            realcmds[i] = realcmds[i][0]
          end
          realcmds.compact!
          ret = realcmds
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
    ret = ""
    for i in 0...value.length
      ret << "," if i > 0
      ret << GameData::Move.get(value[i]).real_name
    end
    return ret
  end
end



class EvolutionsProperty
  def initialize
    @methods = []
    (PBEvolution.maxValue + 1).times do |i|
      @methods[i] = getConstantName(PBEvolution, i)
    end
  end

  def set(_settingname,oldsetting)
    ret = oldsetting
    cmdwin = pbListWindow([])
    commands = []
    realcmds = []
    realcmds.push([-1,0,0,-1])
    for i in 0...oldsetting.length
      realcmds.push([oldsetting[i][0],oldsetting[i][1],oldsetting[i][2],i])
    end
    refreshlist = true; oldsel = -1
    cmd = [0,0]
    loop do
      if refreshlist
        realcmds.sort! { |a,b| a[3]<=>b[3] }
        commands = []
        for i in 0...realcmds.length
          if realcmds[i][0]<0
            commands.push(_INTL("[ADD EVOLUTION]"))
          else
            level = realcmds[i][1]
            param_type = PBEvolution.getFunction(realcmds[i][0], "parameterType")
            has_param = !PBEvolution.hasFunction?(realcmds[i][0], "parameterType") || param_type != nil
            if has_param
              if param_type && !GameData.const_defined?(param_type.to_sym)
                level = getConstantName(param_type, level)
              else
                level = level.to_s
              end
              level = "???" if !level || level.empty?
              commands.push(_INTL("{1}: {2}, {3}",
                 GameData::Species.get(realcmds[i][2]).name, @methods[realcmds[i][0]], level.to_s))
            else
              commands.push(_INTL("{1}: {2}",
                 GameData::Species.get(realcmds[i][2]).name, @methods[realcmds[i][0]]))
            end
          end
          cmd[1] = i if oldsel>=0 && realcmds[i][3]==oldsel
        end
      end
      refreshlist = false; oldsel = -1
      cmd = pbCommands3(cmdwin,commands,-1,cmd[1],true)
      if cmd[0]==1   # Swap evolution up
        if cmd[1]>0 && cmd[1]<realcmds.length-1
          realcmds[cmd[1]+1][3],realcmds[cmd[1]][3] = realcmds[cmd[1]][3],realcmds[cmd[1]+1][3]
          refreshlist = true
        end
      elsif cmd[0]==2   # Swap evolution down
        if cmd[1]>1
          realcmds[cmd[1]-1][3],realcmds[cmd[1]][3] = realcmds[cmd[1]][3],realcmds[cmd[1]-1][3]
          refreshlist = true
        end
      elsif cmd[0]==0
        if cmd[1]>=0
          entry = realcmds[cmd[1]]
          if entry[0]==-1   # Add new evolution path
            pbMessage(_INTL("Choose an evolved form, method and parameter."))
            newspecies = pbChooseSpeciesList
            if newspecies
              newmethod = pbMessage(_INTL("Choose an evolution method."),@methods,-1)
              if newmethod>0
                newparam = -1
                param_type = PBEvolution.getFunction(newmethod, "parameterType")
                has_param = !PBEvolution.hasFunction?(newmethod, "parameterType") || param_type != nil
                if has_param
                  allow_zero = false
                  case param_type
                  when :Item
                    newparam = pbChooseItemList
                  when :Move
                    newparam = pbChooseMoveList
                  when :Species
                    newparam = pbChooseSpeciesList
                  when :Type
                    newparam = pbChooseTypeList
                  when :Ability
                    newparam = pbChooseAbilityList
                  else
                    allow_zero = true
                    params = ChooseNumberParams.new
                    params.setRange(0,65535)
                    params.setCancelValue(-1)
                    newparam = pbMessageChooseNumber(_INTL("Choose a parameter."),params)
                  end
                end
                if !has_param || newparam.is_a?(Symbol) ||
                   (newparam.is_a?(Integer) && (newparam > 0 || (allow_zero && newparam == 0)))
                  havemove = -1
                  for i in 0...realcmds.length
                    havemove = realcmds[i][3] if realcmds[i][0]==newmethod &&
                                                 realcmds[i][1]==newparam &&
                                                 realcmds[i][2]==newspecies
                  end
                  if havemove>=0
                    oldsel = havemove
                  else
                    maxid = -1
                    for i in realcmds; maxid = [maxid,i[3]].max; end
                    realcmds.push([newmethod,newparam,newspecies,maxid+1])
                    oldsel = maxid+1
                  end
                  refreshlist = true
                end
              end
            end
          else   # Edit evolution
            cmd2 = pbMessage(_INTL("\\ts[]Do what with this evolution?"),
               [_INTL("Change species"),_INTL("Change method"),
                _INTL("Change parameter"),_INTL("Delete"),_INTL("Cancel")],5)
            if cmd2==0   # Change species
              newspecies = pbChooseSpeciesList(entry[2])
              if newspecies
                havemove = -1
                for i in 0...realcmds.length
                  havemove = realcmds[i][3] if realcmds[i][0]==entry[0] &&
                                               realcmds[i][1]==entry[1] &&
                                               realcmds[i][2]==newspecies
                end
                if havemove>=0
                  realcmds[cmd[1]] = nil
                  realcmds.compact!
                  oldsel = havemove
                else
                  entry[2] = newspecies
                  oldsel = entry[3]
                end
                refreshlist = true
              end
            elsif cmd2==1   # Change method
              newmethod = pbMessage(_INTL("Choose an evolution method."),@methods,-1,nil,entry[0])
              if newmethod>0
                havemove = -1
                for i in 0...realcmds.length
                  havemove = realcmds[i][3] if realcmds[i][0]==newmethod &&
                                               realcmds[i][1]==entry[1] &&
                                               realcmds[i][2]==entry[2]
                end
                if havemove>=0
                  realcmds[cmd[1]] = nil
                  realcmds.compact!
                  oldsel = havemove
                elsif newmethod != entry[0]
                  entry[0] = newmethod
                  entry[1] = 0
                  oldsel = entry[3]
                end
                refreshlist = true
              end
            elsif cmd2==2   # Change parameter
              newparam = -1
              param_type = PBEvolution.getFunction(entry[0], "parameterType")
              has_param = !PBEvolution.hasFunction?(entry[0], "parameterType") || param_type != nil
              if has_param
                allow_zero = false
                case param_type
                when :Item
                  newparam = pbChooseItemList(entry[1])
                when :Move
                  newparam = pbChooseMoveList(entry[1])
                when :Species
                  newparam = pbChooseSpeciesList(entry[1])
                when :Type
                  newparam = pbChooseTypeList(entry[1])
                when :Ability
                  newparam = pbChooseAbilityList(entry[1])
                else
                  allow_zero = true
                  params = ChooseNumberParams.new
                  params.setRange(0,65535)
                  params.setDefaultValue(entry[1])
                  params.setCancelValue(-1)
                  newparam = pbMessageChooseNumber(_INTL("Choose a parameter."),params)
                end
                if newparam.is_a?(Symbol) ||
                   (newparam.is_a?(Integer) && (newparam > 0 || (allow_zero && newparam == 0)))
                  havemove = -1
                  for i in 0...realcmds.length
                    havemove = realcmds[i][3] if realcmds[i][0]==entry[0] &&
                                                 realcmds[i][1]==newparam &&
                                                 realcmds[i][2]==entry[2]
                  end
                  if havemove>=0
                    realcmds[cmd[1]] = nil
                    realcmds.compact!
                    oldsel = havemove
                  else
                    entry[1] = newparam
                    oldsel = entry[3]
                  end
                  refreshlist = true
                end
              else
                pbMessage(_INTL("This evolution method doesn't use a parameter."))
              end
            elsif cmd2==3   # Delete
              realcmds[cmd[1]] = nil
              realcmds.compact!
              cmd[1] = [cmd[1],realcmds.length-1].min
              refreshlist = true
            end
          end
        else
          cmd2 = pbMessage(_INTL("Save changes?"),
             [_INTL("Yes"),_INTL("No"),_INTL("Cancel")],3)
          if cmd2==0 || cmd2==1
            if cmd2==0
              for i in 0...realcmds.length
                realcmds[i].pop
                realcmds[i] = nil if realcmds[i][0]==-1
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
    ret = ""
    for i in 0...value.length
      ret << "," if i>0
      param = value[i][1]
      param_type = PBEvolution.getFunction(value[i][0], "parameterType")
      if param_type && !GameData.const_defined?(param_type.to_sym)
        param = getConstantName(param_type, param)
      else
        param = param.to_s
      end
      param = "" if !param
      ret << sprintf("#{GameData::Species.get(value[i][2]).name},#{@methods[value[i][0]]},#{param}")
    end
    return ret
  end
end



module EncounterSlotProperty
  def self.set(setting_name, data)
    max_level = PBExperience.maxLevel
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
      [_INTL("Species"),       SpeciesFormProperty,                 _INTL("A Pokémon species/form.")],
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
def pbPropertyList(title,data,properties,saveprompt=false)
  viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z = 99999
  list = pbListWindow([], Graphics.width / 2)
  list.viewport = viewport
  list.z        = 2
  title = Window_UnformattedTextPokemon.newWithSize(title,
     list.width, 0, Graphics.width / 2, 64, viewport)
  title.z = 2
  desc = Window_UnformattedTextPokemon.newWithSize("",
     list.width, title.height, Graphics.width / 2, Graphics.height - title.height, viewport)
  desc.z = 2
  selectedmap = -1
  retval = nil
  commands = []
  for i in 0...properties.length
    propobj = properties[i][1]
    commands.push(sprintf("%s=%s",properties[i][0],propobj.format(data[i])))
  end
  list.commands = commands
  list.index    = 0
  begin
    loop do
      Graphics.update
      Input.update
      list.update
      desc.update
      if list.index!=selectedmap
        desc.text = properties[list.index][2]
        selectedmap = list.index
      end
      if Input.trigger?(Input::A)
        propobj = properties[selectedmap][1]
        if propobj!=ReadOnlyProperty && !propobj.is_a?(ReadOnlyProperty) &&
           pbConfirmMessage(_INTL("Reset the setting {1}?",properties[selectedmap][0]))
          if propobj.respond_to?("defaultValue")
            data[selectedmap] = propobj.defaultValue
          else
            data[selectedmap] = nil
          end
        end
        commands.clear
        for i in 0...properties.length
          propobj = properties[i][1]
          commands.push(sprintf("%s=%s",properties[i][0],propobj.format(data[i])))
        end
        list.commands = commands
      elsif Input.trigger?(Input::B)
        selectedmap = -1
        break
      elsif Input.trigger?(Input::C) || (list.doubleclick? rescue false)
        propobj = properties[selectedmap][1]
        oldsetting = data[selectedmap]
        newsetting = propobj.set(properties[selectedmap][0],oldsetting)
        data[selectedmap] = newsetting
        commands.clear
        for i in 0...properties.length
          propobj = properties[i][1]
          commands.push(sprintf("%s=%s",properties[i][0],propobj.format(data[i])))
        end
        list.commands = commands
        break
      end
    end
    if selectedmap==-1 && saveprompt
      cmd = pbMessage(_INTL("Save changes?"),
         [_INTL("Yes"),_INTL("No"),_INTL("Cancel")],3)
      if cmd==2
        selectedmap = list.index
      else
        retval = (cmd==0)
      end
    end
  end while selectedmap!=-1
  title.dispose
  list.dispose
  desc.dispose
  Input.update
  return retval
end
