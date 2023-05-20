#===============================================================================
#
#===============================================================================
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

def pbSafeCopyFile(x, y, z = nil)
  if FileTest.exist?(x)
    safetocopy = true
    filedata = nil
    if FileTest.exist?(y)
      different = false
      if FileTest.size(x) == FileTest.size(y)
        filedata2 = ""
        File.open(x, "rb") { |f| filedata  = f.read }
        File.open(y, "rb") { |f| filedata2 = f.read }
        different = true if filedata != filedata2
      else
        different = true
      end
      if different
        safetocopy = pbConfirmMessage(_INTL("A different file named '{1}' already exists. Overwrite it?", y))
      else
        # No need to copy
        return
      end
    end
    if safetocopy
      if !filedata
        File.open(x, "rb") { |f| filedata = f.read }
      end
      File.open((z) ? z : y, "wb") { |f| f.write(filedata) }
    end
  end
end

def pbAllocateAnimation(animations, name)
  (1...animations.length).each do |i|
    anim = animations[i]
    return i if !anim
#    if name && name!="" && anim.name==name
#      # use animation with same name
#      return i
#    end
    if anim.length == 1 && anim[0].length == 2 && anim.name == ""
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
  mapinfos.each_key do |i|
    info = mapinfos[i]
    level = -1
    while info
      info = mapinfos[info.parent_id]
      level += 1
    end
    if level >= 0
      info = mapinfos[i]
      maplevels.push([i, level, info.parent_id, info.order])
    end
  end
  maplevels.sort! do |a, b|
    next a[1] <=> b[1] if a[1] != b[1] # level
    next a[2] <=> b[2] if a[2] != b[2] # parent ID
    next a[3] <=> b[3] # order
  end
  stack = []
  stack.push(0, 0)
  while stack.length > 0
    parent = stack[stack.length - 1]
    index = stack[stack.length - 2]
    if index >= maplevels.length
      stack.pop
      stack.pop
      next
    end
    maplevel = maplevels[index]
    stack[stack.length - 2] += 1
    if maplevel[2] != parent
      stack.pop
      stack.pop
      next
    end
    retarray.push([maplevel[0], mapinfos[maplevel[0]].name, maplevel[1]])
    (index + 1...maplevels.length).each do |i|
      next if maplevels[i][2] != maplevel[0]
      stack.push(i)
      stack.push(maplevel[0])
      break
    end
  end
  return retarray
end

#===============================================================================
# List all members of a class
#===============================================================================
def pbChooseFromGameDataList(game_data, default = nil)
  if !GameData.const_defined?(game_data.to_sym)
    raise _INTL("Couldn't find class {1} in module GameData.", game_data.to_s)
  end
  game_data_module = GameData.const_get(game_data.to_sym)
  commands = []
  game_data_module.each do |data|
    name = data.real_name
    name = yield(data) if block_given?
    next if !name
    commands.push([commands.length + 1, name, data.id])
  end
  return pbChooseList(commands, default, nil, -1)
end

# Displays a list of all Pokémon species, and returns the ID of the species
# selected (or nil if the selection was canceled). "default", if specified, is
# the ID of the species to initially select. Pressing Input::ACTION will toggle
# the list sorting between numerical and alphabetical.
def pbChooseSpeciesList(default = nil)
  return pbChooseFromGameDataList(:Species, default) do |data|
    next (data.form > 0) ? nil : data.real_name
  end
end

def pbChooseSpeciesFormList(default = nil)
  return pbChooseFromGameDataList(:Species, default) do |data|
    next (data.form > 0) ? sprintf("%s_%d", data.real_name, data.form) : data.real_name
  end
end

# Displays a list of all types, and returns the ID of the type selected (or nil
# if the selection was canceled). "default", if specified, is the ID of the type
# to initially select. Pressing Input::ACTION will toggle the list sorting
# between numerical and alphabetical.
def pbChooseTypeList(default = nil)
  return pbChooseFromGameDataList(:Type, default) do |data|
    next (data.pseudo_type) ? nil : data.real_name
  end
end

# Displays a list of all items, and returns the ID of the item selected (or nil
# if the selection was canceled). "default", if specified, is the ID of the item
# to initially select. Pressing Input::ACTION will toggle the list sorting
# between numerical and alphabetical.
def pbChooseItemList(default = nil)
  return pbChooseFromGameDataList(:Item, default)
end

# Displays a list of all abilities, and returns the ID of the ability selected
# (or nil if the selection was canceled). "default", if specified, is the ID of
# the ability to initially select. Pressing Input::ACTION will toggle the list
# sorting between numerical and alphabetical.
def pbChooseAbilityList(default = nil)
  return pbChooseFromGameDataList(:Ability, default)
end

# Displays a list of all moves, and returns the ID of the move selected (or nil
# if the selection was canceled). "default", if specified, is the ID of the move
# to initially select. Pressing Input::ACTION will toggle the list sorting
# between numerical and alphabetical.
def pbChooseMoveList(default = nil)
  return pbChooseFromGameDataList(:Move, default)
end

def pbChooseMoveListForSpecies(species, defaultMoveID = nil)
  cmdwin = pbListWindow([], 200)
  commands = []
  index = 1
  # Get all legal moves
  legalMoves = pbGetLegalMoves(species)
  legalMoves.each do |move|
    move_data = GameData::Move.get(move)
    commands.push([index, move_data.name, move_data.id])
    index += 1
  end
  commands.sort! { |a, b| a[1] <=> b[1] }
  moveDefault = 0
  if defaultMoveID
    commands.each_with_index do |item, i|
      moveDefault = i if moveDefault == 0 && item[2] == defaultMoveID
    end
  end
  # Get all moves
  commands2 = []
  GameData::Move.each do |move_data|
    commands2.push([index, move_data.name, move_data.id])
    index += 1
  end
  commands2.sort! { |a, b| a[1] <=> b[1] }
  if defaultMoveID
    commands2.each_with_index do |item, i|
      moveDefault = i if moveDefault == 0 && item[2] == defaultMoveID
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

def pbChooseBallList(defaultMoveID = nil)
  cmdwin = pbListWindow([], 200)
  commands = []
  moveDefault = 0
  GameData::Item.each do |item_data|
    commands.push([item_data.id, item_data.name]) if item_data.is_poke_ball?
  end
  commands.sort! { |a, b| a[1] <=> b[1] }
  if defaultMoveID
    commands.each_with_index do |cmd, i|
      next if cmd[0] != defaultMoveID
      moveDefault = i
      break
    end
  end
  realcommands = []
  commands.each do |i|
    realcommands.push(i[1])
  end
  ret = pbCommands2(cmdwin, realcommands, -1, moveDefault, true)
  cmdwin.dispose
  return (ret >= 0) ? commands[ret][0] : defaultMoveID
end

#===============================================================================
# General list methods
#===============================================================================
def pbCommands2(cmdwindow, commands, cmdIfCancel, defaultindex = -1, noresize = false)
  cmdwindow.commands = commands
  cmdwindow.index    = defaultindex if defaultindex >= 0
  cmdwindow.x        = 0
  cmdwindow.y        = 0
  if noresize
    cmdwindow.height = Graphics.height
  else
    cmdwindow.width  = Graphics.width / 2
  end
  cmdwindow.height   = Graphics.height if cmdwindow.height > Graphics.height
  cmdwindow.z        = 99999
  cmdwindow.visible  = true
  cmdwindow.active   = true
  command = 0
  loop do
    Graphics.update
    Input.update
    cmdwindow.update
    if Input.trigger?(Input::BACK)
      if cmdIfCancel > 0
        command = cmdIfCancel - 1
        break
      elsif cmdIfCancel < 0
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

def pbCommands3(cmdwindow, commands, cmdIfCancel, defaultindex = -1, noresize = false)
  cmdwindow.commands = commands
  cmdwindow.index    = defaultindex if defaultindex >= 0
  cmdwindow.x        = 0
  cmdwindow.y        = 0
  if noresize
    cmdwindow.height = Graphics.height
  else
    cmdwindow.width  = Graphics.width / 2
  end
  cmdwindow.height   = Graphics.height if cmdwindow.height > Graphics.height
  cmdwindow.z        = 99999
  cmdwindow.visible  = true
  cmdwindow.active   = true
  command = 0
  loop do
    Graphics.update
    Input.update
    cmdwindow.update
    if Input.trigger?(Input::SPECIAL)
      command = [5, cmdwindow.index]
      break
    elsif Input.press?(Input::ACTION)
      if Input.repeat?(Input::UP)
        command = [1, cmdwindow.index]
        break
      elsif Input.repeat?(Input::DOWN)
        command = [2, cmdwindow.index]
        break
      elsif Input.trigger?(Input::LEFT)
        command = [3, cmdwindow.index]
        break
      elsif Input.trigger?(Input::RIGHT)
        command = [4, cmdwindow.index]
        break
      end
    elsif Input.trigger?(Input::BACK)
      if cmdIfCancel > 0
        command = [0, cmdIfCancel - 1]
        break
      elsif cmdIfCancel < 0
        command = [0, cmdIfCancel]
        break
      end
    elsif Input.trigger?(Input::USE)
      command = [0, cmdwindow.index]
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
      case sortMode
      when 0
        commands.sort! { |a, b| a[0] <=> b[0] }
      when 1
        commands.sort! { |a, b| a[1] <=> b[1] }
      end
      if itemID.is_a?(Symbol)
        commands.each_with_index { |command, i| itemIndex = i if command[2] == itemID }
      elsif itemID && itemID > 0
        commands.each_with_index { |command, i| itemIndex = i if command[0] == itemID }
      end
      realcommands = []
      commands.each do |command|
        if sortType <= 0
          realcommands.push(sprintf("%03d: %s", command[0], command[1]))
        else
          realcommands.push(command[1])
        end
      end
      sorting = false
    end
    cmd = pbCommandsSortable(cmdwin, realcommands, -1, itemIndex, (sortType < 0))
    case cmd[0]
    when 0   # Chose an option or cancelled
      itemID = (cmd[1] < 0) ? cancelValue : (commands[cmd[1]][2] || commands[cmd[1]][0])
      break
    when 1   # Toggle sorting
      itemID = commands[cmd[1]][2] || commands[cmd[1]][0]
      sortMode = (sortMode + 1) % 2
      sorting = true
    end
  end
  cmdwin.dispose
  return itemID
end

def pbCommandsSortable(cmdwindow, commands, cmdIfCancel, defaultindex = -1, sortable = false)
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
      command = [1, cmdwindow.index]
      break
    elsif Input.trigger?(Input::BACK)
      command = [0, (cmdIfCancel > 0) ? cmdIfCancel - 1 : cmdIfCancel]
      break
    elsif Input.trigger?(Input::USE)
      command = [0, cmdwindow.index]
      break
    end
  end
  ret = command
  cmdwindow.active = false
  return ret
end
