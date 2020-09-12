def pbIsOldSpecialType?(type)
  return isConst?(type,PBTypes,:FIRE) ||
         isConst?(type,PBTypes,:WATER) ||
         isConst?(type,PBTypes,:ICE) ||
         isConst?(type,PBTypes,:GRASS) ||
         isConst?(type,PBTypes,:ELECTRIC) ||
         isConst?(type,PBTypes,:PSYCHIC) ||
         isConst?(type,PBTypes,:DRAGON) ||
         isConst?(type,PBTypes,:DARK)
end

def pbGetLegalMoves(species)
  moves = []
  return moves if !species || species<=0
  moveset = pbGetSpeciesMoveset(species)
  moveset.each { |m| moves.push(m[1]) }
  itemData = pbLoadItemsData
  tmdat = pbLoadSpeciesTMData
  for i in 0...itemData.length
    next if !itemData[i]
    atk = itemData[i][8]
    next if !atk || atk==0
    next if !tmdat[atk]
    if tmdat[atk].any? { |item| item==species }
      moves.push(atk)
    end
  end
  babyspecies = pbGetBabySpecies(species)
  eggMoves = pbGetSpeciesEggMoves(babyspecies)
  eggMoves.each { |m| moves.push(m) }
  moves |= []
  return moves
end

def pbSafeCopyFile(x,y,z=nil)
  if safeExists?(x)
    safetocopy = true
    filedata = nil
    if safeExists?(y)
      different = false
      if FileTest.size(x)!=FileTest.size(y)
        different = true
      else
        filedata2 = ""
        File.open(x,"rb") { |f| filedata  = f.read }
        File.open(y,"rb") { |f| filedata2 = f.read }
        different = true if filedata!=filedata2
      end
      if different
        safetocopy=pbConfirmMessage(_INTL("A different file named '{1}' already exists. Overwrite it?",y))
      else
        # No need to copy
        return
      end
    end
    if safetocopy
      if !filedata
        File.open(x,"rb") { |f| filedata = f.read }
      end
      File.open((z) ? z : y,"wb") { |f| f.write(filedata) }
    end
  end
end

def pbAllocateAnimation(animations,name)
  for i in 1...animations.length
    anim = animations[i]
    return i if !anim
#    if name && name!="" && anim.name==name
#      # use animation with same name
#      return i
#    end
    if anim.length==1 && anim[0].length==2 && anim.name==""
      # assume empty
      return i
    end
  end
  oldlength = animations.length
  animations.resize(10)
  return oldlength
end

def pbMapTree
  mapinfos = pbLoadRxData("Data/MapInfos")
  maplevels = []
  retarray = []
  for i in mapinfos.keys
    info = mapinfos[i]
    level = -1
    while info
      info = mapinfos[info.parent_id]
      level += 1
    end
    if level>=0
      info = mapinfos[i]
      maplevels.push([i,level,info.parent_id,info.order])
    end
  end
  maplevels.sort! { |a,b|
    next a[1]<=>b[1] if a[1]!=b[1] # level
    next a[2]<=>b[2] if a[2]!=b[2] # parent ID
    next a[3]<=>b[3] # order
  }
  stack = []
  stack.push(0,0)
  while stack.length>0
    parent = stack[stack.length-1]
    index = stack[stack.length-2]
    if index>=maplevels.length
      stack.pop
      stack.pop
      next
    end
    maplevel = maplevels[index]
    stack[stack.length-2] += 1
    if maplevel[2]!=parent
      stack.pop
      stack.pop
      next
    end
    retarray.push([maplevel[0],mapinfos[maplevel[0]].name,maplevel[1]])
    for i in index+1...maplevels.length
      if maplevels[i][2]==maplevel[0]
        stack.push(i)
        stack.push(maplevel[0])
        break
      end
    end
  end
  return retarray
end



#===============================================================================
# Make up internal names for things based on their actual names
#===============================================================================
module MakeshiftConsts
  @@consts = []

  def self.get(c,i,modname=nil)
    @@consts[c] = [] if !@@consts[c]
    return @@consts[c][i] if @@consts[c][i]
    if modname
      v = getConstantName(modname,i) rescue nil
      if v
        @@consts[c][i] = v
        return v
      end
    end
    trname = pbGetMessage(c,i)
    trconst = trname.gsub(/é/,"e")
    trconst = trconst.upcase
    trconst = trconst.gsub(/♀/,"fE")
    trconst = trconst.gsub(/♂/,"mA")
    trconst = trconst.gsub(/[^A-Za-z0-9_]/,"")
    if trconst.length==0
      return nil if trname.length==0
      trconst = sprintf("T_%03d",i)
    elsif !trconst[0,1][/[A-Z]/]
      trconst = "T_"+trconst
    end
    while @@consts[c].include?(trconst)
 	   trconst = sprintf("%s_%03d",trconst,i)
    end
    @@consts[c][i] = trconst
    return trconst
  end
end



def pbGetTypeConst(i)
  ret = MakeshiftConsts.get(MessageTypes::Types,i,PBTypes)
  if !ret
    ret = ["NORMAL","FIGHTING","FLYING","POISON","GROUND",
           "ROCK","BUG","GHOST","STEEL","QMARKS",
           "FIRE","WATER","GRASS","ELECTRIC","PSYCHIC",
           "ICE","DRAGON","DARK"][i]
  end
  return ret
end

def pbGetEvolutionConst(i)
  ret = MakeshiftConsts.get(50,i,PBEvolution)
  if !ret
    ret = ["None",
           "Happiness","HappinessDay","HappinessNight","Level","Trade",
           "TradeItem","Item","AttackGreater","AtkDefEqual","DefenseGreater",
           "Silcoon","Cascoon","Ninjask","Shedinja","Beauty",
           "ItemMale","ItemFemale","DayHoldItem","NightHoldItem","HasMove",
           "HasInParty","LevelMale","LevelFemale","Location","TradeSpecies",
           "Custom1","Custom2","Custom3","Custom4","Custom5"]
    i = 0 if i>=ret.length || i<0
    ret = ret[i]
  end
  return ret
end

def pbGetEggGroupConst(i)
  ret = MakeshiftConsts.get(51,i,PBEggGroups)
  if !ret
    ret = ["Undiscovered",
           "Monster","Water1","Bug","Flying","Field",
           "Fairy","Grass","Humanlike","Water3","Mineral",
           "Amorphous","Water2","Ditto","Dragon"][i]
    i = 0 if i>=ret.length || i<0
    ret = ret[i]
  end
  return ret
end

def pbGetColorConst(i)
  ret = MakeshiftConsts.get(52,i,PBColors)
  if !ret
    ret = ["Red","Blue","Yellow","Green","Black","Brown","Purple","Gray","White","Pink"]
    i = 0 if i>=ret.length || i<0
    ret = ret[i]
  end
  return ret
end

def pbGetGenderConst(i)
  ret = MakeshiftConsts.get(53,i,PBGenderRates)
  if !ret
    ret = ["Genderless","AlwaysMale","FemaleOneEighth","Female25Percent",
           "Female50Percent","Female75Percent","FemaleSevenEighths",
           "AlwaysFemale"]
    i = 0 if i>=ret.length || i<0
    ret = ret[i]
  end
  return ret
end

def pbGetHabitatConst(i)
  ret = MakeshiftConsts.get(53,i,PBHabitats)
  if !ret
    ret = ["","Grassland","Forest","WatersEdge","Sea","Cave","Mountain",
           "RoughTerrain","Urban","Rare"]
    i = 0 if i>=ret.length || i<0
    ret = ret[i]
  end
  return ret
end

def pbGetAbilityConst(i)
  return MakeshiftConsts.get(MessageTypes::Abilities,i,PBAbilities)
end

def pbGetMoveConst(i)
  return MakeshiftConsts.get(MessageTypes::Moves,i,PBMoves)
end

def pbGetItemConst(i)
  return MakeshiftConsts.get(MessageTypes::Items,i,PBItems)
end

def pbGetSpeciesConst(i)
  return MakeshiftConsts.get(MessageTypes::Species,i,PBSpecies)
end

def pbGetTrainerConst(i)
  return MakeshiftConsts.get(MessageTypes::TrainerTypes,i,PBTrainers)
end



#===============================================================================
# List all members of a class
#===============================================================================
# Displays a list of all Pokémon species, and returns the ID of the species
# selected (or 0 if the selection was canceled). "default", if specified, is the
# ID of the species to initially select. Pressing Input::A will toggle the list
# sorting between numerical and alphabetical.
def pbChooseSpeciesList(default=0)
  commands = []
  for i in 1..PBSpecies.maxValue
    cname = getConstantName(PBSpecies,i) rescue nil
    commands.push([i,PBSpecies.getName(i)]) if cname
  end
  return pbChooseList(commands,default,0,-1)
end

# Displays an alphabetically sorted list of all moves, and returns the ID of the
# move selected (or -1 if the selection was canceled). "default", if specified,
# is the ID of the move to initially select.
def pbChooseMoveList(default=0)
  commands = []
  for i in 1..PBMoves.maxValue
    cname = getConstantName(PBMoves,i) rescue nil
    commands.push([i,PBMoves.getName(i)]) if cname
  end
  return pbChooseList(commands,default,0)
end

def pbChooseMoveListForSpecies(species,defaultMoveID=0)
  cmdwin = pbListWindow([],200)
  commands = []
  moveDefault = 0
  legalMoves = pbGetLegalMoves(species)
  for move in legalMoves
    commands.push([move,PBMoves.getName(move)])
  end
  commands.sort! { |a,b| a[1]<=>b[1] }
  if defaultMoveID>0
    commands.each_with_index do |_item,i|
      moveDefault = i if moveDefault==0 && i[0]==defaultMoveID
    end
  end
  commands2 = []
  for i in 1..PBMoves.maxValue
    if PBMoves.getName(i)!=nil && PBMoves.getName(i)!=""
      commands2.push([i,PBMoves.getName(i)])
    end
  end
  commands2.sort! { |a,b| a[1]<=>b[1] }
  if defaultMoveID>0
    commands2.each_with_index do |_item,i|
      moveDefault = i if moveDefault==0 && i[0]==defaultMoveID
    end
  end
  commands.concat(commands2)
  realcommands = []
  for command in commands
    realcommands.push("#{command[1]}")
  end
  ret = pbCommands2(cmdwin,realcommands,-1,moveDefault,true)
  cmdwin.dispose
  return (ret>=0) ? commands[ret][0] : 0
end

# Displays an alphabetically sorted list of all types, and returns the ID of the
# type selected (or -1 if the selection was canceled). "default", if specified,
# is the ID of the type to initially select.
def pbChooseTypeList(default=-1)
  commands = []
  for i in 0..PBTypes.maxValue
    cname = getConstantName(PBTypes,i) rescue nil
    commands.push([i,PBTypes.getName(i)]) if cname && !PBTypes.isPseudoType?(i)
  end
  return pbChooseList(commands,default)
end

# Displays a list of all items, and returns the ID of the item selected (or -1
# if the selection was canceled). "default", if specified, is the ID of the item
# to initially select. Pressing Input::A will toggle the list sorting between
# numerical and alphabetical.
def pbChooseItemList(default=0)
  commands = []
  for i in 1..PBItems.maxValue
    cname = getConstantName(PBItems,i) rescue nil
    commands.push([i,PBItems.getName(i)]) if cname
  end
  return pbChooseList(commands,default,0,-1)
end

# Displays a list of all abilities, and returns the ID of the ability selected
# (or -1 if the selection was canceled). "default", if specified, is the ID of
# the ability to initially select. Pressing Input::A will toggle the list
# sorting between numerical and alphabetical.
def pbChooseAbilityList(default=0)
  commands = []
  for i in 1..PBAbilities.maxValue
    cname = getConstantName(PBAbilities,i) rescue nil
    commands.push([i,PBAbilities.getName(i)]) if cname
  end
  return pbChooseList(commands,default,0,-1)
end

def pbChooseBallList(defaultMoveID=-1)
  cmdwin = pbListWindow([],200)
  commands = []
  moveDefault = 0
  for key in $BallTypes.keys
    item = getID(PBItems,$BallTypes[key])
    commands.push([key,item,PBItems.getName(item)]) if item && item>0
  end
  commands.sort! { |a,b| a[2]<=>b[2] }
  if defaultMoveID>=0
    for i in 0...commands.length
      moveDefault = i if defaultMoveID==commands[i][0]
    end
  end
  realcommands = []
  for i in commands
    realcommands.push(i[2])
  end
  ret = pbCommands2(cmdwin,realcommands,-1,moveDefault,true)
  cmdwin.dispose
  return (ret>=0) ? commands[ret][0] : defaultMoveID
end



#===============================================================================
# General list methods
#===============================================================================
def pbCommands2(cmdwindow,commands,cmdIfCancel,defaultindex=-1,noresize=false)
  cmdwindow.commands = commands
  cmdwindow.index    = defaultindex if defaultindex>=0
  cmdwindow.x        = 0
  cmdwindow.y        = 0
  if noresize
    cmdwindow.height = Graphics.height
  else
    cmdwindow.width  = Graphics.width/2
  end
  cmdwindow.height   = Graphics.height if cmdwindow.height>Graphics.height
  cmdwindow.z        = 99999
  cmdwindow.visible  = true
  cmdwindow.active   = true
  command = 0
  loop do
    Graphics.update
    Input.update
    cmdwindow.update
    if Input.trigger?(Input::B)
      if cmdIfCancel>0
        command = cmdIfCancel-1
        break
      elsif cmdIfCancel<0
        command = cmdIfCancel
        break
      end
    elsif Input.trigger?(Input::C) || (cmdwindow.doubleclick? rescue false)
      command = cmdwindow.index
      break
    end
  end
  ret = command
  cmdwindow.active = false
  return ret
end

def pbCommands3(cmdwindow,commands,cmdIfCancel,defaultindex=-1,noresize=false)
  cmdwindow.commands = commands
  cmdwindow.index    = defaultindex if defaultindex>=0
  cmdwindow.x        = 0
  cmdwindow.y        = 0
  if noresize
    cmdwindow.height = Graphics.height
  else
    cmdwindow.width  = Graphics.width/2
  end
  cmdwindow.height   = Graphics.height if cmdwindow.height>Graphics.height
  cmdwindow.z        = 99999
  cmdwindow.visible  = true
  cmdwindow.active   = true
  command = 0
  loop do
    Graphics.update
    Input.update
    cmdwindow.update
    if Input.trigger?(Input::F5)
      command = [5,cmdwindow.index]
      break
    elsif Input.press?(Input::A)
      if Input.repeat?(Input::UP)
        command = [1,cmdwindow.index]
        break
      elsif Input.repeat?(Input::DOWN)
        command = [2,cmdwindow.index]
        break
      elsif Input.press?(Input::LEFT)
        command = [3,cmdwindow.index]
        break
      elsif Input.press?(Input::RIGHT)
        command = [4,cmdwindow.index]
        break
      end
    elsif Input.trigger?(Input::B)
      if cmdIfCancel>0
        command = [0,cmdIfCancel-1]
        break
      elsif cmdIfCancel<0
        command = [0,cmdIfCancel]
        break
      end
    elsif Input.trigger?(Input::C) || (cmdwindow.doubleclick? rescue false)
      command = [0,cmdwindow.index]
      break
    end
  end
  ret = command
  cmdwindow.active = false
  return ret
end

def pbChooseList(commands,default=0,cancelValue=-1,sortType=1)
  cmdwin = pbListWindow([])
  itemID = default
  itemIndex = 0
  sortMode = (sortType>=0) ? sortType : 0 # 0=ID, 1=alphabetical
  sorting = true
  loop do
    if sorting
      if sortMode==0
        commands.sort! { |a,b| a[0]<=>b[0] }
      elsif sortMode==1
        commands.sort! { |a,b| a[1]<=>b[1] }
      end
      if itemID>0
        commands.each_with_index { |command,i| itemIndex = i if command[0]==itemID }
      end
      realcommands = []
      for command in commands
        if sortType<=0
          realcommands.push(sprintf("%03d: %s",command[0],command[1]))
        else
          realcommands.push(command[1])
        end
      end
      sorting = false
    end
    cmd = pbCommandsSortable(cmdwin,realcommands,-1,itemIndex,(sortType<0))
    if cmd[0]==0   # Chose an option or cancelled
      itemID = (cmd[1]<0) ? cancelValue : commands[cmd[1]][0]
      break
    elsif cmd[0]==1   # Toggle sorting
      itemID = commands[cmd[1]][0]
      sortMode = (sortMode+1)%2
      sorting = true
    end
  end
  cmdwin.dispose
  return itemID
end

def pbCommandsSortable(cmdwindow,commands,cmdIfCancel,defaultindex=-1,sortable=false)
  cmdwindow.commands = commands
  cmdwindow.index    = defaultindex if defaultindex >= 0
  cmdwindow.x        = 0
  cmdwindow.y        = 0
  cmdwindow.width    = Graphics.width / 2 if cmdwindow.width < Graphics.width / 2
  cmdwindow.height   = Graphics.height
  cmdwindow.z        = 99999
  cmdwindow.active   = true
  command = 0
  loop do
    Graphics.update
    Input.update
    cmdwindow.update
    if Input.trigger?(Input::A) && sortable
      command = [1,cmdwindow.index]
      break
    elsif Input.trigger?(Input::B)
      command = [0,(cmdIfCancel>0) ? cmdIfCancel-1 : cmdIfCancel]
      break
    elsif Input.trigger?(Input::C) || (cmdwindow.doubleclick? rescue false)
      command = [0,cmdwindow.index]
      break
    end
  end
  ret = command
  cmdwindow.active = false
  return ret
end
