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
    params.setDefaultValue(oldsetting||0)
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
       (oldsetting) ? oldsetting : "",false,256,Graphics.width)
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
  def self.set(settingname,oldsetting)
    chosenmap = pbListScreen(settingname,TrainerTypeLister.new(oldsetting,false))
    return (chosenmap) ? chosenmap[0] : oldsetting
  end

  def self.format(value)
    return (!value) ? value.inspect : PBTrainers.getName(value)
  end
end



module SpeciesProperty
  def self.set(_settingname,oldsetting)
    ret = pbChooseSpeciesList((oldsetting) ? oldsetting : 1)
    return (ret<=0) ? (oldsetting) ? oldsetting : 0 : ret
  end

  def self.defaultValue
    return 0
  end

  def self.format(value)
    return (value) ? PBSpecies.getName(value) : "-"
  end
end



module TypeProperty
  def self.set(_settingname,oldsetting)
    ret = pbChooseTypeList((oldsetting) ? oldsetting : 0)
    return (ret<0) ? (oldsetting) ? oldsetting : 0 : ret
  end

  def self.defaultValue
    return 0
  end

  def self.format(value)
    return (value) ? PBTypes.getName(value) : "-"
  end
end



module MoveProperty
  def self.set(_settingname,oldsetting)
    ret = pbChooseMoveList((oldsetting) ? oldsetting : 1)
    return (ret<=0) ? (oldsetting) ? oldsetting : 0 : ret
  end

  def self.defaultValue
    return 0
  end

  def self.format(value)
    return (value) ? PBMoves.getName(value) : "-"
  end
end



class MoveProperty2
  def initialize(pokemondata)
    @pokemondata = pokemondata
  end

  def set(_settingname,oldsetting)
    ret = pbChooseMoveListForSpecies(@pokemondata[0],(oldsetting) ? oldsetting : 1)
    return (ret>0) ? ret : (oldsetting) ? oldsetting : nil
  end

  def defaultValue
    return nil
  end

  def format(value)
    return (value) ? PBMoves.getName(value) : "-"
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
  def self.set(_settingname,oldsetting)
    ret = pbChooseItemList((oldsetting) ? oldsetting : 1)
    return (ret>0) ? ret : (oldsetting) ? oldsetting : nil
  end

  def self.defaultValue
    return nil
  end

  def self.format(value)
    return (value) ? PBItems.getName(value) : "-"
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

  def set(settingname,oldsetting)
    oldsetting = [nil] if !oldsetting
    for i in 0...6
      oldsetting[i] = oldsetting[0] if !oldsetting[i]
    end
    properties = [
       [_INTL("HP"),LimitProperty2.new(@limit),_INTL("Individual values for the Pokémon's HP stat (0-{1}).",@limit)],
       [_INTL("Attack"),LimitProperty2.new(@limit),_INTL("Individual values for the Pokémon's Attack stat (0-{1}).",@limit)],
       [_INTL("Defense"),LimitProperty2.new(@limit),_INTL("Individual values for the Pokémon's Defense stat (0-{1}).",@limit)],
       [_INTL("Speed"),LimitProperty2.new(@limit),_INTL("Individual values for the Pokémon's Speed stat (0-{1}).",@limit)],
       [_INTL("Sp. Atk"),LimitProperty2.new(@limit),_INTL("Individual values for the Pokémon's Sp. Atk stat (0-{1}).",@limit)],
       [_INTL("Sp. Def"),LimitProperty2.new(@limit),_INTL("Individual values for the Pokémon's Sp. Def stat (0-{1}).",@limit)]
    ]
    pbPropertyList(settingname,oldsetting,properties,false)
    hasNonNil = false
    hasAltVal = false
    firstVal = oldsetting[0] || 0
    for i in 0...6
      if oldsetting[i]
        hasNonNil = true
        hasAltVal = true if oldsetting[i]!=firstVal
      else
        oldsetting[i] = firstVal
      end
    end
    return nil if !hasNonNil   # All IVs are nil
    return [firstVal] if !hasAltVal   # All IVs are the same, just return 1 value
    return oldsetting   # 6 IVs defined
  end

  def defaultValue
    return nil
  end

  def format(value)
    return "-" if !value
    return value[0].to_s if value.length==1
    ret = ""
    for i in 0...6
      ret.concat(",") if i>0
      ret.concat((value[i] || 0).to_s)
    end
    return ret
  end
end



class EVsProperty
  def initialize(limit)
    @limit = limit
  end

  def set(settingname,oldsetting)
    oldsetting = [nil] if !oldsetting
    for i in 0...6
      oldsetting[i] = oldsetting[0] if !oldsetting[i]
    end
    properties = [
       [_INTL("HP"),LimitProperty2.new(@limit),_INTL("Effort values for the Pokémon's HP stat (0-{1}).",@limit)],
       [_INTL("Attack"),LimitProperty2.new(@limit),_INTL("Effort values for the Pokémon's Attack stat (0-{1}).",@limit)],
       [_INTL("Defense"),LimitProperty2.new(@limit),_INTL("Effort values for the Pokémon's Defense stat (0-{1}).",@limit)],
       [_INTL("Speed"),LimitProperty2.new(@limit),_INTL("Effort values for the Pokémon's Speed stat (0-{1}).",@limit)],
       [_INTL("Sp. Atk"),LimitProperty2.new(@limit),_INTL("Effort values for the Pokémon's Sp. Atk stat (0-{1}).",@limit)],
       [_INTL("Sp. Def"),LimitProperty2.new(@limit),_INTL("Effort values for the Pokémon's Sp. Def stat (0-{1}).",@limit)]
    ]
    loop do
      pbPropertyList(settingname,oldsetting,properties,false)
      evtotal = 0
      for i in 0...6
        evtotal += oldsetting[i] if oldsetting[i]
      end
      if evtotal>PokeBattle_Pokemon::EV_LIMIT
        pbMessage(_INTL("Total EVs ({1}) are greater than allowed ({2}). Please reduce them.",
           evtotal,PokeBattle_Pokemon::EV_LIMIT))
      else
        break
      end
    end
    hasNonNil = false
    hasAltVal = false
    firstVal = oldsetting[0] || 0
    for i in 0...6
      if oldsetting[i]
        hasNonNil = true
        hasAltVal = true if oldsetting[i]!=firstVal
      else
        oldsetting[i] = firstVal
      end
    end
    return nil if !hasNonNil   # All EVs are nil
    return [firstVal] if !hasAltVal   # All EVs are the same, just return 1 value
    return oldsetting   # 6 EVs defined
  end

  def defaultValue
    return nil
  end

  def format(value)
    return "-" if !value
    return value[0].to_s if value.length==1
    ret = ""
    for i in 0...6
      ret.concat(",") if i>0
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
    return "-" if !value
    return PBItems.getName(pbBallTypeToItem(value))
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
       [_INTL("Trainer Type"),TrainerTypeProperty,_INTL("Trainer type of this player.")],
       [_INTL("Sprite"),CharacterProperty,_INTL("Walking character sprite.")],
       [_INTL("Cycling"),CharacterProperty,_INTL("Cycling character sprite.")],
       [_INTL("Surfing"),CharacterProperty,_INTL("Surfing character sprite.")],
       [_INTL("Running"),CharacterProperty,_INTL("Running character sprite.")],
       [_INTL("Diving"),CharacterProperty,_INTL("Diving character sprite.")],
       [_INTL("Fishing"),CharacterProperty,_INTL("Fishing character sprite.")],
       [_INTL("Field Move"),CharacterProperty,_INTL("Using a field move character sprite.")]
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
    regions = getMapNameList
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
  def self.set(settingname,oldsetting)
    return pbMessageFreeText(_INTL("Set the value for {1}.",settingname),
       (oldsetting) ? oldsetting : "",false,12)
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
    return [_INTL("Items"),_INTL("Medicine"),_INTL("Poké Balls"),
       _INTL("TMs & HMs"),_INTL("Berries"),_INTL("Mail"),
       _INTL("Battle Items"),_INTL("Key Items")]
  end

  def self.set(_settingname,oldsetting)
    cmd = pbMessage(_INTL("Choose a pocket for this item."),pocketnames(),-1)
    return (cmd>=0) ? cmd+1 : oldsetting
  end

  def self.defaultValue
    return 1
  end

  def self.format(value)
    return _INTL("No Pocket") if value==0
    return (value) ? pocketnames[value-1] : value.inspect
  end
end



module BaseStatsProperty
  def self.set(settingname,oldsetting)
    return oldsetting if !oldsetting
    properties = []
    properties[PBStats::HP]      = _INTL("Base HP"),NonzeroLimitProperty.new(255),_INTL("Base HP stat of the Pokémon.")
    properties[PBStats::ATTACK]  = _INTL("Base Attack"),NonzeroLimitProperty.new(255),_INTL("Base Attack stat of the Pokémon.")
    properties[PBStats::DEFENSE] = _INTL("Base Defense"),NonzeroLimitProperty.new(255),_INTL("Base Defense stat of the Pokémon.")
    properties[PBStats::SPATK]   = _INTL("Base Sp. Attack"),NonzeroLimitProperty.new(255),_INTL("Base Special Attack stat of the Pokémon.")
    properties[PBStats::SPDEF]   = _INTL("Base Sp. Defense"),NonzeroLimitProperty.new(255),_INTL("Base Special Defense stat of the Pokémon.")
    properties[PBStats::SPEED]   = _INTL("Base Speed"),NonzeroLimitProperty.new(255),_INTL("Base Speed stat of the Pokémon.")
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
    properties[PBStats::HP]      = _INTL("HP EVs"),LimitProperty.new(255),_INTL("Number of HP Effort Value points gained from the Pokémon.")
    properties[PBStats::ATTACK]  = _INTL("Attack EVs"),LimitProperty.new(255),_INTL("Number of Attack Effort Value points gained from the Pokémon.")
    properties[PBStats::DEFENSE] = _INTL("Defense EVs"),LimitProperty.new(255),_INTL("Number of Defense Effort Value points gained from the Pokémon.")
    properties[PBStats::SPATK]   = _INTL("Sp. Attack EVs"),LimitProperty.new(255),_INTL("Number of Special Attack Effort Value points gained from the Pokémon.")
    properties[PBStats::SPDEF]   = _INTL("Sp. Defense EVs"),LimitProperty.new(255),_INTL("Number of Special Defense Effort Value points gained from the Pokémon.")
    properties[PBStats::SPEED]   = _INTL("Speed EVs"),LimitProperty.new(255),_INTL("Number of Speed Effort Value points gained from the Pokémon.")
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
  def self.set(_settingname,oldsetting)
    ret = pbChooseAbilityList((oldsetting) ? oldsetting : 1)
    return (ret<=0) ? (oldsetting) ? oldsetting : 0 : ret
  end

  def self.defaultValue
    return 0
  end

  def self.format(value)
    return (value) ? PBAbilities.getName(value) : "-"
  end
end



module MovePoolProperty
  def self.set(_settingname,oldsetting)
    ret = oldsetting
    cmdwin = pbListWindow([],200)
    commands = []
    realcmds = []
    realcmds.push([-1,0,-1])
    for i in 0...oldsetting.length
      realcmds.push([oldsetting[i][0],oldsetting[i][1],i])
    end
    refreshlist = true; oldsel = -1
    cmd = [0,0]
    loop do
      if refreshlist
        realcmds.sort! { |a,b| (a[0]==b[0]) ? a[2]<=>b[2] : a[0]<=>b[0] }
        commands = []
        for i in 0...realcmds.length
          if realcmds[i][0]==-1
            commands.push(_INTL("[ADD MOVE]"))
          else
            commands.push(_INTL("{1}: {2}",realcmds[i][0],PBMoves.getName(realcmds[i][1])))
          end
          cmd[1] = i if oldsel>=0 && realcmds[i][2]==oldsel
        end
      end
      refreshlist = false; oldsel = -1
      cmd = pbCommands3(cmdwin,commands,-1,cmd[1],true)
      if cmd[0]==1   # Swap move up
        if cmd[1]<realcmds.length-1 && realcmds[cmd[1]][0]==realcmds[cmd[1]+1][0]
          realcmds[cmd[1]+1][2],realcmds[cmd[1]][2] = realcmds[cmd[1]][2],realcmds[cmd[1]+1][2]
          refreshlist = true
        end
      elsif cmd[0]==2   # Swap move down
        if cmd[1]>0 && realcmds[cmd[1]][0]==realcmds[cmd[1]-1][0]
          realcmds[cmd[1]-1][2],realcmds[cmd[1]][2] = realcmds[cmd[1]][2],realcmds[cmd[1]-1][2]
          refreshlist = true
        end
      elsif cmd[0]==0
        if cmd[1]>=0
          entry = realcmds[cmd[1]]
          if entry[0]==-1   # Add new move
            params = ChooseNumberParams.new
            params.setRange(0,PBExperience.maxLevel)
            params.setDefaultValue(1)
            params.setCancelValue(-1)
            newlevel = pbMessageChooseNumber(_INTL("Choose a level."),params)
            if newlevel>=0
              newmove = pbChooseMoveList
              if newmove>0
                havemove = -1
                for i in 0...realcmds.length
                  havemove = realcmds[i][2] if realcmds[i][0]==newlevel && realcmds[i][1]==newmove
                end
                if havemove>=0
                  oldsel = havemove
                else
                  maxid = -1
                  for i in realcmds; maxid = [maxid,i[2]].max; end
                  realcmds.push([newlevel,newmove,maxid+1])
                end
                refreshlist = true
              end
            end
          else   # Edit move
            cmd2 = pbMessage(_INTL("\\ts[]Do what with this move?"),
               [_INTL("Change level"),_INTL("Change move"),_INTL("Delete"),_INTL("Cancel")],4)
            if cmd2==0
              params = ChooseNumberParams.new
              params.setRange(0,PBExperience.maxLevel)
              params.setDefaultValue(entry[0])
              newlevel = pbMessageChooseNumber(_INTL("Choose a new level."),params)
              if newlevel>=0 && newlevel!=entry[0]
                havemove = -1
                for i in 0...realcmds.length
                  havemove = realcmds[i][2] if realcmds[i][0]==newlevel && realcmds[i][1]==entry[1]
                end
                if havemove>=0
                  realcmds[cmd[1]] = nil
                  realcmds.compact!
                  oldsel = havemove
                else
                  entry[0] = newlevel
                  oldsel = entry[2]
                end
                refreshlist = true
              end
            elsif cmd2==1
              newmove = pbChooseMoveList(entry[1])
              if newmove>0
                havemove = -1
                for i in 0...realcmds.length
                  havemove = realcmds[i][2] if realcmds[i][0]==entry[0] && realcmds[i][1]==newmove
                end
                if havemove>=0
                  realcmds[cmd[1]] = nil
                  realcmds.compact!
                  oldsel = havemove
                else
                  entry[1] = newmove
                  oldsel = entry[2]
                end
                refreshlist = true
              end
            elsif cmd2==2
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
                realcmds[i] = nil if realcmds[i][0]==0
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

  def self.defaultValue
    return []
  end

  def self.format(value)
    ret = ""
    for i in 0...value.length
      ret << "," if i>0
      ret << sprintf("#{value[i][0]},#{PBMoves.getName(value[i][1])}")
    end
    return ret
  end
end



module EggMovesProperty
  def self.set(_settingname,oldsetting)
    ret = oldsetting
    cmdwin = pbListWindow([],200)
    commands = []
    realcmds = []
    realcmds.push([0,_INTL("[ADD MOVE]"),-1])
    for i in 0...oldsetting.length
      realcmds.push([oldsetting[i],PBMoves.getName(oldsetting[i]),0])
    end
    refreshlist = true; oldsel = -1
    cmd = 0
    loop do
      if refreshlist
        realcmds.sort! { |a,b| (a[2]==b[2]) ? a[1]<=>b[1] : a[2]<=>b[2] }
        commands = []
        for i in 0...realcmds.length
          commands.push(realcmds[i][1])
          cmd = i if oldsel>=0 && realcmds[i][0]==oldsel
        end
      end
      refreshlist = false; oldsel = -1
      cmd = pbCommands2(cmdwin,commands,-1,cmd,true)
      if cmd>=0
        entry = realcmds[cmd]
        if entry[0]==0   # Add new move
          newmove = pbChooseMoveList
          if newmove>0
            havemove = false
            for i in 0...realcmds.length
              havemove = true if realcmds[i][0]==newmove
            end
            if havemove
              oldsel = newmove
            else
              realcmds.push([newmove,PBMoves.getName(newmove),0])
            end
            refreshlist = true
          end
        else   # Edit move
          cmd2 = pbMessage(_INTL("\\ts[]Do what with this move?"),
             [_INTL("Change move"),_INTL("Delete"),_INTL("Cancel")],3)
          if cmd2==0
            newmove = pbChooseMoveList(entry[0])
            if newmove>0
              havemove = false
              for i in 0...realcmds.length
                havemove = true if realcmds[i][0]==newmove
              end
              if havemove
                realcmds[cmd] = nil
                realcmds.compact!
                cmd = [cmd,realcmds.length-1].min
              else
                realcmds[cmd] = [newmove,PBMoves.getName(newmove),0]
              end
              oldsel = newmove
              refreshlist = true
            end
          elsif cmd2==1
            realcmds[cmd] = nil
            realcmds.compact!
            cmd = [cmd,realcmds.length-1].min
            refreshlist = true
          end
        end
      else
        cmd2 = pbMessage(_INTL("Save changes?"),
           [_INTL("Yes"),_INTL("No"),_INTL("Cancel")],3)
        if cmd2==0 || cmd2==1
          if cmd2==0
            for i in 0...realcmds.length
              realcmds[i] = realcmds[i][0]
              realcmds[i] = nil if realcmds[i]==0
            end
            realcmds.compact!
            ret = realcmds
          end
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
      ret << "," if i>0
      ret << sprintf("#{PBMoves.getName(value[i])}")
    end
    return ret
  end
end



module FormNamesProperty
  def self.set(_settingname,oldsetting)
    ret = oldsetting
    cmdwin = pbListWindow([],200)
    commands = []
    realcmds = []
    realcmds.push([_INTL("[ADD FORM]"),-1])
    for i in 0...oldsetting.length
      realcmds.push([oldsetting[i],i])
    end
    refreshlist = true; oldsel = -1
    cmd = [0,0]
    loop do
      if refreshlist
        realcmds.sort! { |a,b| a[1]<=>b[1] }
        commands = []
        for i in 0...realcmds.length
          text = (realcmds[i][1]>=0) ? sprintf("#{realcmds[i][1]} - #{realcmds[i][0]}") : realcmds[i][0]
          commands.push(text)
          cmd[1] = i if oldsel>=0 && realcmds[i][1]==oldsel
        end
      end
      refreshlist = false; oldsel = -1
      cmd = pbCommands3(cmdwin,commands,-1,cmd[1],true)
      if cmd[0]==1   # Swap name up
        if cmd[1]<realcmds.length-1 && realcmds[cmd[1]][1]>=0 && realcmds[cmd[1]+1][1]>=0
          realcmds[cmd[1]+1][1],realcmds[cmd[1]][1] = realcmds[cmd[1]][1],realcmds[cmd[1]+1][1]
          refreshlist = true
        end
      elsif cmd[0]==2   # Swap name down
        if cmd[1]>0 && realcmds[cmd[1]][1]>=0 && realcmds[cmd[1]-1][1]>=0
          realcmds[cmd[1]-1][1],realcmds[cmd[1]][1] = realcmds[cmd[1]][1],realcmds[cmd[1]-1][1]
          refreshlist = true
        end
      elsif cmd[0]==0
        if cmd[1]>=0
          entry = realcmds[cmd[1]]
          if entry[1]<0   # Add new form
            newname = pbMessageFreeText(_INTL("Choose a form name (no commas)."),"",false,255)
            if newname!=""
              realcmds.push([newname,realcmds.length-1])
              refreshlist = true
            end
          else   # Edit form name
            cmd2 = pbMessage(_INTL("\\ts[]Do what with this form name?"),
               [_INTL("Rename"),_INTL("Delete"),_INTL("Cancel")],3)
            if cmd2==0
              newname = pbMessageFreeText(_INTL("Choose a form name (no commas)."),entry[0],false,255)
              if newname!=""
                realcmds[cmd[1]][0] = newname
                refreshlist = true
              end
            elsif cmd2==1
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
                if realcmds[i][1]<0
                  realcmds[i] = nil
                else
                  realcmds[i] = realcmds[i][0]
                end
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

  def self.defaultValue
    return []
  end

  def self.format(value)
    ret = ""
    for i in 0...value.length
      ret << "," if i>0
      ret << sprintf("#{value[i]}")
    end
    return ret
  end
end



class EvolutionsProperty
  def initialize(methods)
    @methods = methods
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
            if param_type
              level = (Object.const_get(param_type).getName(level) rescue getConstantName(param_type, level) rescue level)
            end
            level = "" if !level
            commands.push(_INTL("{1}: {2}, {3}",
               PBSpecies.getName(realcmds[i][2]),@methods[realcmds[i][0]],level.to_s))
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
            if newspecies>0
              newmethod = pbMessage(_INTL("Choose an evolution method."),@methods,-1)
              if newmethod>0
                newparam = -1
                allow_zero = false
                param_type = PBEvolution.getFunction(newmethod, "parameterType")
                case param_type
                when :PBItems
                  newparam = pbChooseItemList
                when :PBMoves
                  newparam = pbChooseMoveList
                when :PBSpecies
                  newparam = pbChooseSpeciesList
                when :PBTypes
                  allow_zero = true
                  newparam = pbChooseTypeList
                when :PBAbilities
                  newparam = pbChooseAbilityList
                else
                  allow_zero = true
                  params = ChooseNumberParams.new
                  params.setRange(0,65535)
                  params.setCancelValue(-1)
                  newparam = pbMessageChooseNumber(_INTL("Choose a parameter."),params)
                end
                if newparam && (newparam>0 || (allow_zero && newparam == 0))
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
              if newspecies>0
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
              allow_zero = false
              param_type = PBEvolution.getFunction(entry[0], "parameterType")
              case param_type
              when :PBItems
                newparam = pbChooseItemList(entry[1])
              when :PBMoves
                newparam = pbChooseMoveList(entry[1])
              when :PBSpecies
                newparam = pbChooseSpeciesList(entry[1])
              when :PBTypes
                allow_zero = true
                newparam = pbChooseTypeList(entry[1])
              when :PBAbilities
                newparam = pbChooseAbilityList(entry[1])
              else
                allow_zero = true
                params = ChooseNumberParams.new
                params.setRange(0,65535)
                params.setDefaultValue(entry[1])
                params.setCancelValue(-1)
                newparam = pbMessageChooseNumber(_INTL("Choose a parameter."),params)
              end
              if newparam && (newparam>0 || (allow_zero && newparam == 0))
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
      if param_type
        param = (Object.const_get(param_type).getName(param) rescue getConstantName(param_type, param) rescue param)
      end
      param = "" if !param
      ret << sprintf("#{PBSpecies.getName(value[i][2])},#{@methods[value[i][0]]},#{param}")
    end
    return ret
  end
end



#===============================================================================
# Core property editor script
#===============================================================================
def pbPropertyList(title,data,properties,saveprompt=false)
  viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z = 99999
  list = pbListWindow([],Graphics.width*5/10)
  list.viewport = viewport
  list.z        = 2
  title = Window_UnformattedTextPokemon.new(title)
  title.x        = list.width
  title.y        = 0
  title.width    = Graphics.width*5/10
  title.height   = 64
  title.viewport = viewport
  title.z        = 2
  desc = Window_UnformattedTextPokemon.new("")
  desc.x        = list.width
  desc.y        = title.height
  desc.width    = Graphics.width*5/10
  desc.height   = Graphics.height-title.height
  desc.viewport = viewport
  desc.z        = 2
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
