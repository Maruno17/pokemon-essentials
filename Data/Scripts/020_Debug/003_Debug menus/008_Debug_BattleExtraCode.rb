#===============================================================================
# Additonal Methods for the Battle Debug Menu
#===============================================================================
def setSideEffects(sideIdx,sides, battlers)
  viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z = 99999
  sprites = {}
  sprites["right_window"] = SpriteWindow_DebugBattleEffects.new(viewport,sides[sideIdx].effects,SIDE_EFFECTS,battlers)
  right_window = sprites["right_window"]
  right_window.active   = true
  loopHandler = DebugBattle_LoopHandler.new(sprites,right_window,sides[sideIdx].effects,battlers)
  loopHandler.startLoop
  viewport.dispose
end


#===============================================================================
#
#===============================================================================
class SpriteWindow_DebugBattleEffects < Window_DrawableCommand
  include BattleDebugMixin

  def initialize(viewport,dataSource,mapSource,battlers=nil)
    @dataSource = dataSource
    @mapSource = mapSource
    @keyIndexArray = []
    @sortByKey = false
    @battlers = battlers
    super(0,0,Graphics.width,Graphics.height,viewport)
  end

  def refresh
    @item_max = itemCount()
    dwidth  = self.width-self.borderX
    dheight = self.height-self.borderY
    self.contents = pbDoEnsureBitmap(self.contents,dwidth,dheight)
    self.contents.clear
    @keyIndexArray = []
    sortedEffects = @mapSource.sort_by{ |key, value| @sortByKey ? key : value[:name]}

    sortedEffects.each_with_index { |dataArray, i|
      next if i<self.top_item || i>self.top_item+self.page_item_max
      drawItem(dataArray,@item_max,itemRect(i),i)
      @keyIndexArray[i] = dataArray[0]
    }
  end
  

  def drawItem(dataArray,_count,rect,idx)
    pbSetNarrowFont(self.contents)
    key = dataArray[0]
    name = dataArray[1][:name]
    colors = 0
    value = getValue(key)
    if isSwitch(key) || isToBeFormatted(key)
      statusColor = getFormattedStatusColor(value,key)
      status = _INTL("{1}",statusColor[0])
      colors = statusColor[1]
    else
      status = _INTL("{1}",value)
      status = "\"__\"" if !status || status==""
    end
    name = '' if name==nil
    id_text = sprintf("%04d:",key)
    rect = drawCursor(idx,rect)
    totalWidth = rect.width
    idWidth     = totalWidth*15/100
    nameWidth   = totalWidth*65/100
    statusWidth = totalWidth*20/100
    self.shadowtext(rect.x,rect.y,idWidth,rect.height,id_text)
    self.shadowtext(rect.x+idWidth,rect.y,nameWidth,rect.height,name,0,0)
    self.shadowtext(rect.x+idWidth+nameWidth,rect.y,statusWidth,rect.height,status,1,colors)
  end

  def getValue(key)
    return @dataSource[key]
  end

  def isSwitch(key)
    return false if !defined?(@dataSource)
    return !!@dataSource[key] == @dataSource[key]
  end

  def isMoveIDEffect?(key)
    value = @mapSource[key]
    return defined?(value[:type]) && value[:type] == :MOVEID
  end

    def isUserIndexEffect?(key)
        value = @mapSource[key]
        return defined?(value[:type]) && value[:type] == :USERINDEX
    end

  def isToBeFormatted(key)
    return isUserIndexEffect?(key) || isMoveIDEffect?(key)
  end

  def getFormattedStatusColor(value,key)
    status = value
    value = 0 if value == nil
    color = 0
    isMoveIDEffect = isMoveIDEffect?(key)
    if isMoveIDEffect
      status = value > 0 ? GameData::Move.get(value).name : "None"
      color = 3
      return [status,color]
    end

    isUserIdxEffect = isUserIndexEffect?(key)
    if isUserIdxEffect
      status =  value >= 0 ? @battlers[value].name : "None"
      color = 3
      return [status,color]
    end

    status = "Disabled"
    color = 1
    if value==nil
      status = "-"
      color = 0
    elsif value
      status = "Enabled"
      color = 2
    end
    return [status,color]
  end

  def toggleSortMode
    @sortByKey = !@sortByKey
    refresh
  end

  def getByIndex(index)
    return @keyIndexArray[index]
  end

  def itemCount
    return @mapSource.size ? @mapSource.size : 0
  end
  
  def shadowtext(x,y,w,h,t,align=0,colors=0)
    width = self.contents.text_size(t).width
    if align==1 # Right aligned
      x += (w-width)
    elsif align==2 # Centre aligned
      x += (w/2)-(width/2)
    end
    base = Color.new(12*8,12*8,12*8)
    if colors==1 # Red
      base = Color.new(168,48,56)
    elsif colors==2 # Green
      base = Color.new(0,144,0)
    elsif colors==3 # Blue
      base = Color.new(22,111,210)
    end
    pbDrawShadowText(self.contents,x,y,[width,w].max,h,t,base,Color.new(26*8,26*8,25*8))
  end
end


#===============================================================================
#
#===============================================================================
class SpriteWindow_DebugBattleMetaData < SpriteWindow_DebugBattleEffects
  include BattleDebugMixin

  def drawItem(dataArray,_count,rect,idx)
    pbSetNarrowFont(self.contents)
    key = dataArray[0]
    name = dataArray[1][:name]
    colors = 0
    value = getValue(key)

    if isSwitch(key) || isToBeFormatted(key)
      statusColor = getFormattedStatusColor(value,key)
      status = _INTL("{1}",statusColor[0])
      colors = statusColor[1]
    else
      status = _INTL("{1}",value)
      status = "\"__\"" if !status || status==""
    end
    name = '' if name==nil
    rect = drawCursor(idx,rect)
    totalWidth = rect.width
    idWidth     = totalWidth*15/100
    nameWidth   = totalWidth*65/100
    statusWidth = totalWidth*20/100
    self.shadowtext(rect.x,rect.y,idWidth,rect.height,name)
    self.shadowtext(rect.x+idWidth+nameWidth,rect.y,statusWidth,rect.height,status,1,colors)
  end

  def getItemNames(trainerIdx)
    items = @dataSource.items[trainerIdx]
    if !items || items.length<=0
      return "None"
    end
    itemString = ""
    itemArray.each_with_index{ |itemID, idx|
      itemString += _INTL("{1}", GameData::Item.get(item).name)
      itemString += "," if idx+1 < itemArray.length
    }
    return itemString
  end
  
  def getTrainersWithItems
    opponents = @dataSource.opponent
    return "None" if !opponents
    items = @dataSource.items
    trainerNames = ""
    opponents.each_with_index{ |opponent, idx|
      hasItems = items[idx].length > 0
      next if !hasItems
      trainerNames += opponent.name 
      trainerNames += "," if idx+1 < opponents.length
    }
    return "None" if trainerNames.length == 0
    return trainerNames
  end

  def getValue(key)
    return @dataSource.send(key)
  end

  def isSwitch(key)
    return !!@dataSource.send(key) == @dataSource.send(key)
  end

  def isToBeFormatted(key)
    return true
  end

  def getFormattedStatusColor(value,key)
    status = value
    color = 0
    case key
      when :expGain
        status = value ? "Enabled" : "Disabled"
        color = value ? 2 : 1
      when :items
        status =  " "
      when :switchStyle
        status = value ? "Switch" : "Set"
        color = value ? 2 : 1
      when :internalBattle
        status = value ? "[ON]" : "[OFF]"
        color = value ? 2 : 1
      when :time
        status = value == 0 ? "Day" : value == 1 ? "Evening" : "Night"
    end
    return [status,color]
  end
end
#===============================================================================
#
#===============================================================================
class SpriteWindow_DebugStatChanges < SpriteWindow_DebugBattleEffects
  include BattleDebugMixin

  # override method to prevent bug where some stats are treated as switches
  def isSwitch(key)
    return false
  end

  def getValue(key)
    return @dataSource.stages[key]
  end

  def drawItem(dataArray,_count,rect,idx)
    pbSetNarrowFont(self.contents)
    
    stat    = dataArray[0]
    name    = dataArray[1][:name]
    value   = getValue(stat)
    status  = _INTL("{1}",value)
    colors  = value > 0 ? 2 : value < 0 ? 1 : 0
    
    rect = drawCursor(idx,rect)
    totalWidth = rect.width
    nameWidth   = totalWidth*65/100
    statusWidth = totalWidth*20/100
    self.shadowtext(rect.x,rect.y,nameWidth,rect.height,name,0,0)
    self.shadowtext(rect.x+nameWidth,rect.y,statusWidth,rect.height,status,1,colors)
  end
end



class DebugBattle_LoopHandler
    include BattleDebugMixin

    def initialize(sprites,window,dataSource,battlers,battler=nil,minNumeric=-1,maxNumeric=99,allowSorting=true)
      @sprites        = sprites
      @window         = window
      @dataSource     = dataSource
      @minNumeric     = minNumeric
      @maxNumeric     = maxNumeric 
      @allowSorting   = allowSorting
      @battlers       = battlers
      @battler        = battler
      @battle         = nil
    end

    def setMinMaxValues(minNumeric,maxNumeric)
      @minNumeric     = minNumeric
      @maxNumeric     = maxNumeric 
    end

    def allowSorting=(allowSorting)
      @allowSorting = allowSorting
    end

    def setBattle=(battle)
      @battle = battle
    end

    def startLoop()
      loop do
        Graphics.update
        Input.update
        pbUpdateSpriteHash(@sprites)
        if Input.trigger?(Input::BACK)
            pbPlayCancelSE
            break
        end
        index = @window.index
        key = @window.getByIndex(index)
        if Input.trigger?(Input::SPECIAL) && @allowSorting
            @window.toggleSortMode
        end
        if @window.isSwitch(key) # Switches
            if Input.trigger?(Input::USE)
                toggleSwitch(key)
                @window.refresh
            end
        elsif isNumeric(key) && !Input.trigger?(Input::USE) # Numerics
            if Input.repeat?(Input::LEFT) && leftInputConditions(key)
                decreaseNumeric(key)
                @window.refresh
            elsif Input.repeat?(Input::RIGHT) && rightInputConditions(key)
                increaseNumeric(key)
                @window.refresh
            end
        elsif Input.trigger?(Input::USE)
            pbPlayDecisionSE
            handleCInput(key)
            @window.refresh
        end
      end
      pbDisposeSpriteHash(@sprites)
    end

    def isNumeric(key)
      return  @window.getValue(key).is_a?(Numeric)
    end

    def leftInputConditions(key)
      value = @window.getValue(key)
      return false if @window.isMoveIDEffect?(key)
      return value > -1 if @window.isUserIndexEffect?(key)
      return value > @minNumeric
    end
    
    def rightInputConditions(key)
      value = @window.getValue(key)
      return false if @window.isMoveIDEffect?(key)
      return value < @battlers.length-1 if @window.isUserIndexEffect?(key)
      return value < @maxNumeric
    end

    def toggleSwitch(key)
      @dataSource[key] = !@dataSource[key]
    end

    def increaseNumeric(key)
      @dataSource[key] += 1
    end

    def decreaseNumeric(key)
      @dataSource[key] -= 1
    end

    def handleCInput(key)
      currentValue = @dataSource[key] 
      if @window.isMoveIDEffect?(key) && @battler
          moveId = selectMoveForID(@battler,currentValue)
          @dataSource[key] = moveId
          return
      end

      if @window.isUserIndexEffect?(key)
          userIndex = selectUserForIndex(currentValue)
          @dataSource[key] = userIndex
          return
      end

      return if !isNumeric(key)
      setNumeric(key)
    end

    def setNumeric(key)
      currentValue = @dataSource[key]
      @dataSource[key] = getNumericValue("Enter value.",currentValue)
    end
    
end



class DebugBattleMeta_LoopHandler < DebugBattle_LoopHandler

    def isNumeric(key)
      return  @dataSource.send(key).is_a?(Numeric)
    end

    def leftInputConditions(key)
      return @dataSource.send(key) > @minNumeric && key!=:time
    end
    
    def rightInputConditions(key)
      return key!=:time
    end

    def toggleSwitch(key)
      @dataSource.instance_variable_set("@#{key}", !@dataSource.send(key))
    end

    def increaseNumeric(key)
      @dataSource.instance_variable_set("@#{key}", @dataSource.send(key)+1)
    end

    def decreaseNumeric(key)
      @dataSource.instance_variable_set("@#{key}", @dataSource.send(key)-1)
    end

    def handleCInput(key)
      currentValue = @dataSource.send(key)
      if key == :time
          newValue = setTime(currentValue)
          @dataSource.instance_variable_set("@#{key}", newValue)
      elsif key == :items
          @dataSource.setTrainerItems
      elsif key == :environment
          setEnvironment(@battle)
      elsif isNumeric(key)
          setNumeric(key,currentValue)
      end
    end

    def setNumeric(key,currentValue)
      newValue = getNumericValue("Enter value.",currentValue)
      @dataSource.instance_variable_set("@#{key}", newValue)
    end

end

class PokeBattle_FakePokemon < Pokemon
    
    def initialize(originalPokemon,battler)
      species = originalPokemon.species
      level = battler.level
      owner = originalPokemon.owner
      super(species,level,owner,false)
      @personalID       = originalPokemon.personalID
      @hp               = originalPokemon.hp
      @totalhp          = originalPokemon.totalhp
      @iv               = originalPokemon.iv
      @ivMaxed          = originalPokemon.ivMaxed
      @ev               = originalPokemon.ev  
      @trainerID        = originalPokemon.owner.id
      @ot               = originalPokemon.owner.name
      @otgender         = originalPokemon.owner.gender
      @obtain_method    = originalPokemon.obtain_method
      @obtain_map       = originalPokemon.obtain_map
      @obtain_text      = originalPokemon.obtain_text
      @obtain_level     = originalPokemon.obtain_level
      @hatched_map      = originalPokemon.hatched_map
      @timeReceived     = originalPokemon.timeReceived
      @timeEggHatched   = originalPokemon.timeEggHatched
      @nature           = originalPokemon.nature
      @nature_for_stats = originalPokemon.nature_for_stats
      @timeReceived     = originalPokemon.timeReceived
      @moves            = battler.moves
      @status           = battler.status
      @item             = battler.item
      @type1            = battler.type1
      @type2            = battler.type2
      @ability          = battler.ability
      calc_stats
    end
end



# Meta Data related methods
def pbGenerateTimeCommands(time)
  timeCommands = []
  currentTime = time
  times = ["Day", "Evening","Night"]
  for i in 0..2
    activeString = currentTime == i ? "x" : " "
    timeCommands.push([i,_INTL("[{1}] {2}",activeString,times[i])])
  end
  return timeCommands
end

def setTime(currentTime)
  timeCommands = pbGenerateTimeCommands(currentTime)
  return pbChooseList(timeCommands,currentTime,currentTime,0)
end


def pbGenerateItemCommands(items)
  itemsCommands = []
  
  items.each_with_index{|item, idx| 
    itemName = GameData::Item.get(item).name
    itemsCommands.push([idx,_INTL("{1}",itemName)])
  }
    itemsCommands.push([items.length+1, _INTL("[Add item]")])
    itemsCommands.push([-1,_INTL("[Return]")])
  return itemsCommands
end

def generateOpponentCommands
  opponentCommands = []
  self.opponent.each_with_index{|opponent, idx|
    items = self.items[idx]
    itemLength = items.length
    opponentCommands.push([idx,_INTL("{1}: {2} items",opponent.name,itemLength)])
  }
  return opponentCommands
end

def setTrainerItems
  if !self.opponent
    return pbMessage("No other trainers found!")
  end
  opponentCommands = generateOpponentCommands
  opponentIdx = pbChooseList(opponentCommands,0,-1,0)
  return if opponentIdx<0
  itemCmd = 0
  loop do
    currentItems = self.items[opponentIdx]
    itemCommands = pbGenerateItemCommands(currentItems)
    itemCmd = pbChooseList(itemCommands,-1)
    break if itemCmd<0
    if itemCmd==itemCommands.length-1   # Add item
      pbListScreenBlock(_INTL("ADD ITEMS"),ItemLister.new(0)) { |button,item|
        if button==Input::USE && item
          self.items[opponentIdx].push(item)
          pbMessage(_INTL("Gave {1} to {2}.",GameData::Item.get(item).name,self.opponent[opponentIdx].name))
        end
      }
    else  
      if pbConfirmMessage(_INTL("Change this item?"))
        item = pbListScreen(_INTL("CHOOSE AN ITEM"),
          ItemLister.new(0))
        if item
          setTrainerItem(opponentIdx, itemCmd, item)
        end
      
      elsif pbConfirmMessage(_INTL("Delete this item?"))
        setTrainerItem(opponentIdx, itemCmd, nil)
      end
    end
  end
end

def setTrainerItem(opponentIdx, itemIdx, newItem)
  self.items[opponentIdx][itemIdx] = newItem
  self.items[opponentIdx].compact!
end


def setEnvironment(battle)
  environmentCommands = []
  currentEnvironment = battle.environment
  environmentIdxMap = []
  counter = 0
  GameData::Environment.each { |environment|
    environmentCommands.push([counter, _INTL("{1}",environment.name)])
    environmentIdxMap[counter] = environment.id
    counter += 1
  }
  currentEnvironment = battle.environment
  currentEnvironmentIdx = environmentIdxMap.index(currentEnvironment)
  
  newEnvironmentIdx = pbChooseList(environmentCommands, currentEnvironmentIdx, currentEnvironmentIdx, 1)
  newEnvironment = environmentIdxMap[newEnvironmentIdx]
  environmentChanged = newEnvironment != currentEnvironment

  if !environmentChanged
    return;
  end
  battle.environment = newEnvironment
end


# Creates a duplicate of the Pokemon object, to reflect changes from the debug menu
def fakePokemonForSummary(battler)
  originalPokemon = battler.pokemon
  fakePokemon = PokeBattle_FakePokemon.new(originalPokemon,battler)
  return fakePokemon
end

def generateMoveCommands(battler, isSelectionOnly=false)
  moves = []
  battler.moves.each_with_index{ |move,idx| 
    moves.push([idx, _INTL("{1} {2}/{3}",move.name,move.pp,move.total_pp)])
  }
  emptySlots = 4 - battler.moves.length;

  emptySlots.times { |idx|
    moves.push([idx + battler.moves.length, _INTL("-")]) if !isSelectionOnly
  }

  if !isSelectionOnly
    moves.push([4, _INTL("Deplete all PP")])
    moves.push([5, _INTL("Refill all PP")])
  end
  return moves
end
  
def generateMoveActionCommands
  return [
    [0, _INTL("Change Move")],
    [1, _INTL("Set PP")],
    [2, _INTL("Delete Move")]
  ]
end

def generateTypeCommands(battler)
  type1 = GameData::Type.get(battler.type1).name
  type2 = !battler.type2 ? "None" : GameData::Type.get(battler.type2).name 
  type3 = !battler.effects[PBEffects::Type3] ? "None" : GameData::Type.get(battler.effects[PBEffects::Type3]).name
  return [
    [1, _INTL("{1}",type1)],
    [2, _INTL("{1}",type2)],
    [3, _INTL("{1} (Type effect)",type3)]
  ]
end


def selectMoveForID(battler,currentValue)
  currentMove = battler.moves.detect{ |move| move.id == currentValue}
  currentIndex = currentMove ? battler.moves.index(currentMove) : -1
  moveCommands = generateMoveCommands(battler,true)
  moveIdx = pbChooseList(moveCommands,currentIndex,-1,0)
  return -1 if moveIdx < 0
  return battler.moves[moveIdx].id
end

def selectMoveForFunctionCode(battler,currentValue)
  currentFunction = battler.moves.detect{ |move| move.function == currentValue}
  currentIndex = currentFunction ? battler.moves.index(currentFunction) : -1
  moveCommands = generateMoveCommands(battler,true)
  moveIdx = pbChooseList(moveCommands,currentIndex,-1,0)
  return -1 if moveIdx < 0
  return battler.moves[moveIdx].function
end


def selectUserForIndex(currentIndex)
  battlerCommands = []
  for i in 0...@battlers.length
    battlerCommands.push([i, _INTL("[{1}] {2}",i,@battlers[i].name)])
  end
  battlerIdx = pbChooseList(battlerCommands,currentIndex,-1,0)
  return battlerIdx
end

def getNumericValue(msg,currentValue,min=-1,max=99,allowNegative=true)
    params  = ChooseNumberParams.new
    params.setRange(min,max)
    params.setNegativesAllowed(allowNegative)
    params.setInitialValue(currentValue)
    params.setCancelValue(currentValue)
    return pbMessageChooseNumber(_INTL("{1}",msg),params)
end

class PokeBattle_Battler
  def totalhp=(totalhp)
    @totalhp = totalhp
  end
end