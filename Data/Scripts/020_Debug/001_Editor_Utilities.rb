def pbGetLegalMoves(species)
  species_data = GameData::Species.get(species)
  moves = []
  return moves if !species_data
  species_data.moves.each { |m| moves.push(m[1]) }
  species_data.tutor_moves.each { |m| moves.push(m) }
  babyspecies = species_data.get_baby_species
  GameData::Species.get(babyspecies).egg_moves.each { |m| moves.push(m) }
  moves |= []   # Remove duplicates
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
  mapinfos = pbLoadMapInfos
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
# List all members of a class
#===============================================================================
# Displays a list of all Pokémon species, and returns the ID of the species
# selected (or nil if the selection was canceled). "default", if specified, is
# the ID of the species to initially select. Pressing Input::ACTION will toggle
# the list sorting between numerical and alphabetical.
def pbChooseSpeciesList(default = nil)
  commands = []
  GameData::Species.each { |s| commands.push([s.id_number, s.real_name, s.id]) if s.form == 0 }
  return pbChooseList(commands, default, nil, -1)
end

def pbChooseSpeciesFormList(default = nil)
  commands = []
  GameData::Species.each do |s|
    name = (s.form == 0) ? s.real_name : sprintf("%s_%d", s.real_name, s.form)
    commands.push([s.id_number, name, s.id])
  end
  return pbChooseList(commands, default, nil, -1)
end

# Displays a list of all moves, and returns the ID of the move selected (or nil
# if the selection was canceled). "default", if specified, is the ID of the move
# to initially select. Pressing Input::ACTION will toggle the list sorting
# between numerical and alphabetical.
def pbChooseMoveList(default = nil)
  commands = []
  GameData::Move.each { |i| commands.push([i.id_number, i.real_name, i.id]) }
  return pbChooseList(commands, default, nil, -1)
end

def pbChooseMoveListForSpecies(species, defaultMoveID = nil)
  cmdwin = pbListWindow([], 200)
  commands = []
  # Get all legal moves
  legalMoves = pbGetLegalMoves(species)
  legalMoves.each do |move|
    move_data = GameData::Move.get(move)
    commands.push([move_data.id_number, move_data.name, move_data.id])
  end
  commands.sort! { |a, b| a[1] <=> b[1] }
  moveDefault = 0
  if defaultMoveID
    commands.each_with_index do |_item, i|
      moveDefault = i if moveDefault == 0 && i[2] == defaultMoveID
    end
  end
  # Get all moves
  commands2 = []
  GameData::Move.each do |move_data|
    commands2.push([move_data.id_number, move_data.name, move_data.id])
  end
  commands2.sort! { |a, b| a[1] <=> b[1] }
  if defaultMoveID
    commands2.each_with_index do |_item, i|
      moveDefault = i if moveDefault == 0 && i[2] == defaultMoveID
    end
  end
  # Choose from all moves
  commands.concat(commands2)
  realcommands = []
  commands.each { |cmd| realcommands.push(cmd[1]) }
  ret = pbCommands2(cmdwin, realcommands, -1, moveDefault, true)
  cmdwin.dispose
  return (ret >= 0) ? commands[ret][2] : nil
end

# Displays a list of all types, and returns the ID of the type selected (or nil
# if the selection was canceled). "default", if specified, is the ID of the type
# to initially select. Pressing Input::ACTION will toggle the list sorting
# between numerical and alphabetical.
def pbChooseTypeList(default = nil)
  commands = []
  GameData::Type.each { |t| commands.push([t.id_number, t.name, t.id]) if !t.pseudo_type }
  return pbChooseList(commands, default, nil, -1)
end

# Displays a list of all items, and returns the ID of the item selected (or nil
# if the selection was canceled). "default", if specified, is the ID of the item
# to initially select. Pressing Input::ACTION will toggle the list sorting
# between numerical and alphabetical.
def pbChooseItemList(default = nil)
  commands = []
  GameData::Item.each { |i| commands.push([i.id_number, i.name, i.id]) }
  return pbChooseList(commands, default, nil, -1)
end

# Displays a list of all abilities, and returns the ID of the ability selected
# (or nil if the selection was canceled). "default", if specified, is the ID of
# the ability to initially select. Pressing Input::ACTION will toggle the list
# sorting between numerical and alphabetical.
def pbChooseAbilityList(default = nil)
  commands = []
  GameData::Ability.each { |a| commands.push([a.id_number, a.name, a.id]) }
  return pbChooseList(commands, default, nil, -1)
end

def pbChooseBallList(defaultMoveID = nil)
  cmdwin = pbListWindow([], 200)
  commands = []
  moveDefault = 0
  for key in $BallTypes.keys
    item = GameData::Item.try_get($BallTypes[key])
    commands.push([$BallTypes[key], item.name]) if item
  end
  commands.sort! { |a, b| a[1] <=> b[1] }
  if defaultMoveID
    for i in 0...commands.length
      moveDefault = i if commands[i][0] == defaultMoveID
    end
  end
  realcommands = []
  for i in commands
    realcommands.push(i[1])
  end
  ret = pbCommands2(cmdwin, realcommands, -1, moveDefault, true)
  cmdwin.dispose
  return (ret >= 0) ? commands[ret][0] : defaultMoveID
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
    if Input.trigger?(Input::BACK)
      if cmdIfCancel>0
        command = cmdIfCancel-1
        break
      elsif cmdIfCancel<0
        command = cmdIfCancel
        break
      end
    elsif Input.trigger?(Input::USE)
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
    if Input.trigger?(Input::SPECIAL)
      command = [5,cmdwindow.index]
      break
    elsif Input.press?(Input::ACTION)
      if Input.repeat?(Input::UP)
        command = [1,cmdwindow.index]
        break
      elsif Input.repeat?(Input::DOWN)
        command = [2,cmdwindow.index]
        break
      elsif Input.trigger?(Input::LEFT)
        command = [3,cmdwindow.index]
        break
      elsif Input.trigger?(Input::RIGHT)
        command = [4,cmdwindow.index]
        break
      end
    elsif Input.trigger?(Input::BACK)
      if cmdIfCancel>0
        command = [0,cmdIfCancel-1]
        break
      elsif cmdIfCancel<0
        command = [0,cmdIfCancel]
        break
      end
    elsif Input.trigger?(Input::USE)
      command = [0,cmdwindow.index]
      break
    end
  end
  ret = command
  cmdwindow.active = false
  return ret
end

def pbChooseList(commands, default = 0, cancelValue = -1, sortType = 1)
  cmdwin = pbListWindow([])
  itemID = default
  itemIndex = 0
  sortMode = (sortType >= 0) ? sortType : 0   # 0=ID, 1=alphabetical
  sorting = true
  loop do
    if sorting
      if sortMode == 0
        commands.sort! { |a, b| a[0] <=> b[0] }
      elsif sortMode == 1
        commands.sort! { |a, b| a[1] <=> b[1] }
      end
      if itemID.is_a?(Symbol)
        commands.each_with_index { |command, i| itemIndex = i if command[2] == itemID }
      elsif itemID && itemID > 0
        commands.each_with_index { |command, i| itemIndex = i if command[0] == itemID }
      end
      realcommands = []
      for command in commands
        if sortType <= 0
          realcommands.push(sprintf("%03d: %s", command[0], command[1]))
        else
          realcommands.push(command[1])
        end
      end
      sorting = false
    end
    cmd = pbCommandsSortable(cmdwin, realcommands, -1, itemIndex, (sortType < 0))
    if cmd[0] == 0   # Chose an option or cancelled
      itemID = (cmd[1] < 0) ? cancelValue : (commands[cmd[1]][2] || commands[cmd[1]][0])
      break
    elsif cmd[0] == 1   # Toggle sorting
      itemID = commands[cmd[1]][2] || commands[cmd[1]][0]
      sortMode = (sortMode + 1) % 2
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
    if Input.trigger?(Input::ACTION) && sortable
      command = [1,cmdwindow.index]
      break
    elsif Input.trigger?(Input::BACK)
      command = [0,(cmdIfCancel>0) ? cmdIfCancel-1 : cmdIfCancel]
      break
    elsif Input.trigger?(Input::USE)
      command = [0,cmdwindow.index]
      break
    end
  end
  ret = command
  cmdwindow.active = false
  return ret
end
