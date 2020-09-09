#===============================================================================
# Add new map files to the map tree.
#===============================================================================
def pbImportNewMaps
  return false if !$DEBUG
  mapfiles = {}
  # Get IDs of all maps in the Data folder
  Dir.chdir("Data") {
    mapData = sprintf("Map*.%s",$RPGVX ? "rvdata" : "rxdata")
    for map in Dir.glob(mapData)
      if $RPGVX
        mapfiles[$1.to_i(10)] = true if map[/map(\d+)\.rvdata/i]
      else
        mapfiles[$1.to_i(10)] = true if map[/map(\d+)\.rxdata/i]
      end
    end
  }
  mapinfos = pbLoadRxData("Data/MapInfos")
  maxOrder = 0
  # Exclude maps found in mapinfos
  for id in mapinfos.keys
    next if !mapinfos[id]
    mapfiles.delete(id) if mapfiles[id]
    maxOrder = [maxOrder,mapinfos[id].order].max
  end
  # Import maps not found in mapinfos
  maxOrder += 1
  imported = false
  count = 0
  for id in mapfiles.keys
    next if id==999   # Ignore 999 (random dungeon map)
    mapinfo = RPG::MapInfo.new
    mapinfo.order = maxOrder
    mapinfo.name  = sprintf("MAP%03d",id)
    maxOrder += 1
    mapinfos[id] = mapinfo
    imported = true
    count += 1
  end
  if imported
    if $RPGVX
      save_data(mapinfos,"Data/MapInfos.rvdata")
    else
      save_data(mapinfos,"Data/MapInfos.rxdata")
    end
    pbMessage(_INTL("{1} new map(s) copied to the Data folder were successfully imported.",count))
  end
  return imported
end

#===============================================================================
# Generate and modify event commands.
#===============================================================================
def pbGenerateMoveRoute(commands)
  route           = RPG::MoveRoute.new
  route.repeat    = false
  route.skippable = true
  route.list.clear
  i = 0
  while i<commands.length
    case commands[i]
    when PBMoveRoute::Wait, PBMoveRoute::SwitchOn, PBMoveRoute::SwitchOff,
         PBMoveRoute::ChangeSpeed, PBMoveRoute::ChangeFreq, PBMoveRoute::Opacity,
         PBMoveRoute::Blending, PBMoveRoute::PlaySE, PBMoveRoute::Script
      route.list.push(RPG::MoveCommand.new(commands[i],[commands[i+1]]))
      i += 1
    when PBMoveRoute::ScriptAsync
      route.list.push(RPG::MoveCommand.new(PBMoveRoute::Script,[commands[i+1]]))
      route.list.push(RPG::MoveCommand.new(PBMoveRoute::Wait,[0]))
      i += 1
    when PBMoveRoute::Jump
      route.list.push(RPG::MoveCommand.new(commands[i],[commands[i+1],commands[i+2]]))
      i += 2
    when PBMoveRoute::Graphic
      route.list.push(RPG::MoveCommand.new(commands[i],[commands[i+1],commands[i+2],commands[i+3],commands[i+4]]))
      i += 4
    else
      route.list.push(RPG::MoveCommand.new(commands[i]))
    end
    i += 1
  end
  route.list.push(RPG::MoveCommand.new(0))
  return route
end

def pbPushMoveRoute(list,character,route,indent=0)
  route = pbGenerateMoveRoute(route) if route.is_a?(Array)
  for i in 0...route.list.length
    list.push(RPG::EventCommand.new(
       (i==0) ? 209 : 509,indent,
       (i==0) ? [character,route] : [route.list[i-1]]))
  end
end

def pbPushMoveRouteAndWait(list,character,route,indent=0)
  pbPushMoveRoute(list,character,route,indent)
  pbPushEvent(list,210,[],indent)
end

def pbPushWait(list,frames,indent=0)
  pbPushEvent(list,106,[frames],indent)
end

def pbPushEvent(list,cmd,params=nil,indent=0)
  list.push(RPG::EventCommand.new(cmd,indent,params ? params : []))
end

def pbPushEnd(list)
  list.push(RPG::EventCommand.new(0,0,[]))
end

def pbPushComment(list,cmt,indent=0)
  textsplit2 = cmt.split(/\n/)
  for i in 0...textsplit2.length
    list.push(RPG::EventCommand.new((i==0) ? 108 : 408,indent,[textsplit2[i].gsub(/\s+$/,"")]))
  end
end

def pbPushText(list,text,indent=0)
  return if !text
  textsplit = text.split(/\\m/)
  for t in textsplit
    first = true
    if $RPGVX
      list.push(RPG::EventCommand.new(101,indent,["",0,0,2]))
      first = false
    end
    textsplit2 = t.split(/\n/)
    for i in 0...textsplit2.length
      textchunk = textsplit2[i].gsub(/\s+$/,"")
      if textchunk && textchunk!=""
        list.push(RPG::EventCommand.new((first) ? 101 : 401,indent,[textchunk]))
        first = false
      end
    end
  end
end

def pbPushScript(list,script,indent=0)
  return if !script
  first = true
  textsplit2 = script.split(/\n/)
  for i in 0...textsplit2.length
    textchunk = textsplit2[i].gsub(/\s+$/,"")
    if textchunk && textchunk!=""
      list.push(RPG::EventCommand.new((first) ? 355 : 655,indent,[textchunk]))
      first = false
    end
  end
end

def pbPushExit(list,indent=0)
  list.push(RPG::EventCommand.new(115,indent,[]))
end

def pbPushElse(list,indent=0)
  list.push(RPG::EventCommand.new(0,indent,[]))
  list.push(RPG::EventCommand.new(411,indent-1,[]))
end

def pbPushBranchEnd(list,indent=0)
  list.push(RPG::EventCommand.new(0,indent,[]))
  list.push(RPG::EventCommand.new(412,indent-1,[]))
end

def pbPushBranch(list,script,indent=0)
  list.push(RPG::EventCommand.new(111,indent,[12,script]))
end

def pbPushSelfSwitch(list,swtch,switchOn,indent=0)
  list.push(RPG::EventCommand.new(123,indent,[swtch,switchOn ? 0 : 1]))
end

def applyPages(page,pages)
  for p in pages
    p.graphic       = page.graphic
    p.walk_anime    = page.walk_anime
    p.step_anime    = page.step_anime
    p.direction_fix = page.direction_fix
    p.through       = page.through
    p.always_on_top = page.always_on_top
  end
end

def pbAddPassageList(event,mapData)
  return if !event || event.pages.length==0
  page                         = RPG::Event::Page.new
  page.condition.switch1_valid = true
  page.condition.switch1_id    = mapData.registerSwitch('s:tsOff?("A")')
  page.graphic.character_name  = ""
  page.trigger                 = 3   # Autorun
  page.list.clear
  list = page.list
  pbPushBranch(list,"get_character(0).onEvent?")
  pbPushEvent(list,208,[0],1)   # Change Transparent Flag
  pbPushWait(list,6,1)          # Wait
  pbPushEvent(list,208,[1],1)   # Change Transparent Flag
  pbPushMoveRouteAndWait(list,-1,[PBMoveRoute::Down],1)
  pbPushBranchEnd(list,1)
  pbPushScript(list,"setTempSwitchOn(\"A\")")
  pbPushEnd(list)
  event.pages.push(page)
end

#===============================================================================
#
#===============================================================================
def safequote(x)
  x = x.gsub(/\"\#\'\\/) { |a| "\\"+a }
  x = x.gsub(/\t/,"\\t")
  x = x.gsub(/\r/,"\\r")
  x = x.gsub(/\n/,"\\n")
  return x
end

def safequote2(x)
  x = x.gsub(/\"\#\'\\/) { |a| "\\"+a }
  x = x.gsub(/\t/,"\\t")
  x = x.gsub(/\r/,"\\r")
  x = x.gsub(/\n/," ")
  return x
end

def pbEventId(event)
  list = event.pages[0].list
  return nil if list.length==0
  codes = []
  i = 0
  while i<list.length
    codes.push(list[i].code)
    i += 1
  end
end

def pbEachPage(e)
  return true if !e
  if e.is_a?(RPG::CommonEvent)
    yield e
  else
    e.pages.each { |page| yield page }
  end
end



#===============================================================================
#
#===============================================================================
class MapData
  attr_reader :mapinfos

  def initialize
    @mapinfos = pbLoadRxData("Data/MapInfos")
    @system   = pbLoadRxData("Data/System")
    @tilesets = pbLoadRxData("Data/Tilesets")
    @mapxy      = []
    @mapWidths  = []
    @mapHeights = []
    @maps       = []
    @registeredSwitches = {}
  end

  def switchName(id)
    return @system.switches[id] || ""
  end

  def mapFilename(mapID)
    filename = sprintf("Data/map%03d",mapID)
    filename += ($RPGVX) ? ".rvdata" : ".rxdata"
    return filename
  end

  def getMap(mapID)
    return @maps[mapID] if @maps[mapID]
    begin
      @maps[mapID] = load_data(mapFilename(mapID))
      return @maps[mapID]
    rescue
      return nil
    end
  end

  def getEventFromXY(mapID,x,y)
    return nil if x<0 || y<0
    mapPositions = @mapxy[mapID]
    return mapPositions[y*@mapWidths[mapID]+x] if mapPositions
    map = getMap(mapID)
    return nil if !map
    @mapWidths[mapID]  = map.width
    @mapHeights[mapID] = map.height
    mapPositions = []
    width = map.width
    for e in map.events.values
      mapPositions[e.y*width+e.x] = e if e
    end
    @mapxy[mapID] = mapPositions
    return mapPositions[y*width+x]
  end

  def getEventFromID(mapID,id)
    map = getMap(mapID)
    return nil if !map
    return map.events[id]
  end

  def getTilesetPassages(map,mapID)
    begin
      return @tilesets[map.tileset_id].passages
    rescue
      raise "Tileset data for tileset number #{map.tileset_id} used on map #{mapID} was not found. " +
            "The tileset was likely deleted, but one or more maps still use it."
    end
  end

  def getTilesetPriorities(map,mapID)
    begin
      return @tilesets[map.tileset_id].priorities
    rescue
      raise "Tileset data for tileset number #{map.tileset_id} used on map #{mapID} was not found. " +
            "The tileset was likely deleted, but one or more maps still use it."
    end
  end

  def isPassable?(mapID,x,y)
    return true if $RPGVX
    map = getMap(mapID)
    return false if !map
    return false if x<0 || x>=map.width || y<0 || y>=map.height
    passages   = getTilesetPassages(map,mapID)
    priorities = getTilesetPriorities(map,mapID)
    for i in [2, 1, 0]
      tile_id = map.data[x, y, i]
      return false if tile_id==nil
      passage = passages[tile_id]
      if !passage
        raise "The tile used on map #{mapID} at coordinates (#{x}, #{y}) on layer #{i+1} doesn't exist in the tileset. " +
              "It should be deleted to prevent errors."
      end
      return false if passage&0x0f==0x0f
      return true if priorities[tile_id]==0
    end
    return true
  end

  def isCounterTile?(mapID,x,y)
    return false if $RPGVX
    map = getMap(mapID)
    return false if !map
    passages = getTilesetPassages(map,mapID)
    for i in [2, 1, 0]
      tile_id = map.data[x, y, i]
      return false if tile_id==nil
      passage = passages[tile_id]
      if !passage
        raise "The tile used on map #{mapID} at coordinates (#{x}, #{y}) on layer #{i+1} doesn't exist in the tileset. " +
              "It should be deleted to prevent errors."
      end
      return true if passage&0x80==0x80
    end
    return false
  end

  def setCounterTile(mapID,x,y)
    return if $RPGVX
    map = getMap(mapID)
    return if !map
    passages = getTilesetPassages(map,mapID)
    for i in [2, 1, 0]
      tile_id = map.data[x, y, i]
      next if tile_id==0
      passages[tile_id] |= 0x80
      break
    end
  end

  def registerSwitch(switch)
    return @registeredSwitches[switch] if @registeredSwitches[switch]
    for id in 1..5000
      name = @system.switches[id]
      next if name && name!="" && name!=switch
      @system.switches[id] = switch
      @registeredSwitches[switch] = id
      return id
    end
    return 1
  end

  def saveMap(mapID)
    save_data(getMap(mapID),mapFilename(mapID)) rescue nil
  end

  def saveTilesets
    filename = "Data/Tilesets"
    filename += ($RPGVX) ? ".rvdata" : ".rxdata"
    save_data(@tilesets,filename)
    filename = "Data/System"
    filename += ($RPGVX) ? ".rvdata" : ".rxdata"
    save_data(@system,filename)
  end
end



#===============================================================================
#
#===============================================================================
class TrainerChecker
  def initialize
    @trainers     = nil
    @trainertypes = nil
    @dontaskagain = false
  end

  def pbTrainerTypeCheck(symbol)
    ret = true
    if $DEBUG
      return if @dontaskagain
      if !hasConst?(PBTrainers,symbol)
        ret = false
      else
        trtype = PBTrainers.const_get(symbol)
        @trainertypes = load_data("Data/trainer_types.dat") if !@trainertypes
        ret = false  if !@trainertypes || !@trainertypes[trtype]
      end
      if !ret
        if pbConfirmMessage(_INTL("Add new trainer named {1}?",symbol))
          pbTrainerTypeEditorNew(symbol.to_s)
          @trainers     = nil
          @trainertypes = nil
        end
#        if pbMapInterpreter
#          pbMapInterpreter.command_end rescue nil
#        end
      end
    end
    return ret
  end

  def pbTrainerBattleCheck(trtype,trname,trid)
    return if !$DEBUG || @dontaskagain
    if trtype.is_a?(String) || trtype.is_a?(Symbol)
      pbTrainerTypeCheck(trtype)
      return if !hasConst?(PBTrainers,trtype)
      trtype = PBTrainers.const_get(trtype)
    end
    @trainers = load_data("Data/trainers.dat") if !@trainers
    if @trainers
      for trainer in @trainers
        return if trainer[0]==trtype && trainer[1]==trname && trainer[4]==trid
      end
    end
    cmd = pbMissingTrainer(trtype,trname,trid)
    if cmd==2
      @dontaskagain = true
      Graphics.update
    end
    @trainers     = nil
    @trainertypes = nil
  end
end



#===============================================================================
# Convert trainer comments to trainer event.
#===============================================================================
def pbConvertToTrainerEvent(event,trainerChecker)
  return nil if !event || event.pages.length==0
  list = event.pages[0].list
  return nil if list.length<2
  commands = []
  isFirstCommand = false
  # Find all the trainer comments in the event
  for i in 0...list.length
    next if list[i].code!=108   # Comment (first line)
    command = list[i].parameters[0]
    for j in (i+1)...list.length
      break if list[j].code!=408   # Comment (continuation line)
      command += "\r\n"+list[j].parameters[0]
    end
    if command[/^(Battle\:|Type\:|Name\:|BattleID\:|DoubleBattle\:|Backdrop\:|EndSpeech\:|Outcome\:|Continue\:|EndBattle\:|EndIfSwitch\:|VanishIfSwitch\:|RegSpeech\:)/i]
      commands.push(command)
      isFirstCommand = true if i==0
    end
  end
  return nil if commands.length==0
  # Found trainer comments; create a new Event object to replace this event
  ret = RPG::Event.new(event.x,event.y)
  ret.name = event.name
  ret.id   = event.id
  firstpage = Marshal::load(Marshal.dump(event.pages[0]))   # Copy event's first page
  firstpage.trigger = 2   # On event touch
  firstpage.list    = []   # Clear page's commands
  # Rename the event if there's nothing above the trainer comments
  if isFirstCommand
    if !event.name[/trainer/i]
      ret.name = "Trainer(3)"
    elsif event.name[/^\s*trainer\s+\((\d+)\)\s*$/i]
      ret.name = "Trainer(#{$1})"
    end
  end
  # Compile the trainer comments
  rewriteComments = false   # You can change this
  battles        = []
  trtype         = nil
  trname         = nil
  battleid       = 0
  doublebattle   = false
  backdrop       = nil
  endspeeches    = []
  outcome        = 0
  continue       = false
  endbattles     = []
  endifswitch    = []
  vanishifswitch = []
  regspeech      = nil
  for command in commands
    if command[/^Battle\:\s*([\s\S]+)$/i]
      battles.push($~[1])
      pbPushComment(firstpage.list,command) if rewriteComments
    elsif command[/^Type\:\s*([\s\S]+)$/i]
      trtype = $~[1].gsub(/^\s+/,"").gsub(/\s+$/,"")
      pbPushComment(firstpage.list,command) if rewriteComments
    elsif command[/^Name\:\s*([\s\S]+)$/i]
      trname = $~[1].gsub(/^\s+/,"").gsub(/\s+$/,"")
      pbPushComment(firstpage.list,command) if rewriteComments
    elsif command[/^BattleID\:\s*(\d+)$/i]
      battleid = $~[1].to_i
      pbPushComment(firstpage.list,command) if rewriteComments
    elsif command[/^DoubleBattle\:\s*([\s\S]+)$/i]
      value = $~[1].gsub(/^\s+/,"").gsub(/\s+$/,"")
      doublebattle = true if value.upcase=="TRUE" || value.upcase=="YES"
      pbPushComment(firstpage.list,command) if rewriteComments
    elsif command[/^Backdrop\:\s*([\s\S]+)$/i]
      backdrop = $~[1].gsub(/^\s+/,"").gsub(/\s+$/,"")
      pbPushComment(firstpage.list,command) if rewriteComments
    elsif command[/^EndSpeech\:\s*([\s\S]+)$/i]
      endspeeches.push($~[1].gsub(/^\s+/,"").gsub(/\s+$/,""))
      pbPushComment(firstpage.list,command) if rewriteComments
    elsif command[/^Outcome\:\s*(\d+)$/i]
      outcome = $~[1].to_i
      pbPushComment(firstpage.list,command) if rewriteComments
    elsif command[/^Continue\:\s*([\s\S]+)$/i]
      value = $~[1].gsub(/^\s+/,"").gsub(/\s+$/,"")
      continue = true if value.upcase=="TRUE" || value.upcase=="YES"
      pbPushComment(firstpage.list,command) if rewriteComments
    elsif command[/^EndBattle\:\s*([\s\S]+)$/i]
      endbattles.push($~[1].gsub(/^\s+/,"").gsub(/\s+$/,""))
      pbPushComment(firstpage.list,command) if rewriteComments
    elsif command[/^EndIfSwitch\:\s*([\s\S]+)$/i]
      endifswitch.push(($~[1].gsub(/^\s+/,"").gsub(/\s+$/,"")).to_i)
      pbPushComment(firstpage.list,command) if rewriteComments
    elsif command[/^VanishIfSwitch\:\s*([\s\S]+)$/i]
      vanishifswitch.push(($~[1].gsub(/^\s+/,"").gsub(/\s+$/,"")).to_i)
      pbPushComment(firstpage.list,command) if rewriteComments
    elsif command[/^RegSpeech\:\s*([\s\S]+)$/i]
      regspeech = $~[1].gsub(/^\s+/,"").gsub(/\s+$/,"")
      pbPushComment(firstpage.list,command) if rewriteComments
    end
  end
  return nil if battles.length<=0
  # Run trainer check now, except in editor
  trainerChecker.pbTrainerBattleCheck(trtype,trname,battleid) if !$INEDITOR
  # Set the event's charset to one depending on the trainer type if the event
  # doesn't have a charset
  if firstpage.graphic.character_name=="" && hasConst?(PBTrainers,trtype)
    trainerid = getConst(PBTrainers,trtype)
    if trainerid
      filename = pbTrainerCharNameFile(trainerid)
      if FileTest.image_exist?("Graphics/Characters/"+filename)
        firstpage.graphic.character_name = sprintf(filename)
      end
    end
  end
  # Create strings that will be used repeatedly
  safetrcombo = sprintf(":%s,\"%s\"",trtype,safequote(trname))   # :YOUNGSTER,"Joey"
  introplay   = sprintf("pbTrainerIntro(:%s)",trtype)
  # Write first page
  pbPushScript(firstpage.list,introplay)   # pbTrainerIntro
  pbPushScript(firstpage.list,"pbNoticePlayer(get_character(0))")
  pbPushText(firstpage.list,battles[0])
  if battles.length>1   # Has rematches
    pbPushScript(firstpage.list,sprintf("pbTrainerCheck(%s,%d,%d)",safetrcombo,battles.length,battleid))
  end
  pbPushScript(firstpage.list,"setBattleRule(\"double\")") if doublebattle
  pbPushScript(firstpage.list,sprintf("setBattleRule(\"backdrop\",\"%s\")",safequote(backdrop))) if backdrop
  pbPushScript(firstpage.list,sprintf("setBattleRule(\"outcomeVar\",%d)",outcomeVar)) if outcome>1
  pbPushScript(firstpage.list,"setBattleRule(\"canLose\")") if continue
  espeech = (endspeeches[0]) ? sprintf("_I(\"%s\")",safequote2(endspeeches[0])) : "nil"
  if battleid>0
    battleString = sprintf("pbTrainerBattle(%s,%s,nil,%d)",safetrcombo,espeech,battleid)
  elsif endspeeches[0]
    battleString = sprintf("pbTrainerBattle(%s,%s)",safetrcombo,espeech)
  else
    battleString = sprintf("pbTrainerBattle(%s)",safetrcombo)
  end
  pbPushBranch(firstpage.list,battleString)
  if battles.length>1   # Has rematches
    pbPushScript(firstpage.list,
       sprintf("pbPhoneRegisterBattle(_I(\"%s\"),get_character(0),%s,%d)",
       regspeech,safetrcombo,battles.length),1)
  end
  pbPushSelfSwitch(firstpage.list,"A",true,1)
  pbPushBranchEnd(firstpage.list,1)
  pbPushScript(firstpage.list,"pbTrainerEnd",0)
  pbPushEnd(firstpage.list)
  # Copy first page to last page and make changes to its properties
  lastpage = Marshal::load(Marshal.dump(firstpage))
  lastpage.trigger   = 0   # On action
  lastpage.list      = []   # Clear page's commands
  lastpage.condition = firstpage.condition.clone
  lastpage.condition.self_switch_valid = true
  lastpage.condition.self_switch_ch    = "A"
  # Copy last page to rematch page
  rematchpage = Marshal::load(Marshal.dump(lastpage))
  rematchpage.list      = lastpage.list.clone   # Copy the last page's commands
  rematchpage.condition = lastpage.condition.clone
  rematchpage.condition.self_switch_valid = true
  rematchpage.condition.self_switch_ch    = "B"
  # Write rematch and last pages
  for i in 1...battles.length
    # Run trainer check now, except in editor
    trainerChecker.pbTrainerBattleCheck(trtype,trname,battleid+i) if !$INEDITOR
    if i==battles.length-1
      pbPushBranch(rematchpage.list,sprintf("pbPhoneBattleCount(%s)>=%d",safetrcombo,i))
      pbPushBranch(lastpage.list,sprintf("pbPhoneBattleCount(%s)>%d",safetrcombo,i))
    else
      pbPushBranch(rematchpage.list,sprintf("pbPhoneBattleCount(%s)==%d",safetrcombo,i))
      pbPushBranch(lastpage.list,sprintf("pbPhoneBattleCount(%s)==%d",safetrcombo,i))
    end
    # Rematch page
    pbPushScript(rematchpage.list,introplay,1)   # pbTrainerIntro
    pbPushText(rematchpage.list,battles[i],1)
    pbPushScript(rematchpage.list,"setBattleRule(\"double\")",1) if doublebattle
    pbPushScript(rematchpage.list,sprintf("setBattleRule(\"backdrop\",%s)",safequote(backdrop)),1) if backdrop
    pbPushScript(rematchpage.list,sprintf("setBattleRule(\"outcomeVar\",%d)",outcomeVar),1) if outcome>1
    pbPushScript(rematchpage.list,"setBattleRule(\"canLose\")",1) if continue
    espeech = nil
    if endspeeches.length>0
      espeech = (endspeeches[i]) ? endspeeches[i] : endspeeches[endspeeches.length-1]
    end
    espeech = (espeech) ? sprintf("_I(\"%s\")",safequote2(espeech)) : "nil"
    battleString = sprintf("pbTrainerBattle(%s,%s,nil,%d)",safetrcombo,espeech,battleid+i)
    pbPushBranch(rematchpage.list,battleString,1)
    pbPushScript(rematchpage.list,sprintf("pbPhoneIncrement(%s,%d)",safetrcombo,battles.length),2)
    pbPushSelfSwitch(rematchpage.list,"A",true,2)
    pbPushSelfSwitch(rematchpage.list,"B",false,2)
    pbPushScript(rematchpage.list,"pbTrainerEnd",2)
    pbPushBranchEnd(rematchpage.list,2)
    pbPushExit(rematchpage.list,1)   # Exit Event Processing
    pbPushBranchEnd(rematchpage.list,1)
    # Last page
    if endbattles.length>0
      ebattle = (endbattles[i]) ? endbattles[i] : endbattles[endbattles.length-1]
      pbPushText(lastpage.list,ebattle,1)
    end
    pbPushScript(lastpage.list,
       sprintf("pbPhoneRegisterBattle(_I(\"%s\"),get_character(0),%s,%d)",
       regspeech,safetrcombo,battles.length),1)
    pbPushExit(lastpage.list,1)   # Exit Event Processing
    pbPushBranchEnd(lastpage.list,1)
  end
  # Finish writing rematch page
  pbPushEnd(rematchpage.list)
  # Finish writing last page
  ebattle = (endbattles[0]) ? endbattles[0] : "..."
  pbPushText(lastpage.list,ebattle)
  if battles.length>1
    pbPushScript(lastpage.list,
       sprintf("pbPhoneRegisterBattle(_I(\"%s\"),get_character(0),%s,%d)",
       regspeech,safetrcombo,battles.length))
  end
  pbPushEnd(lastpage.list)
  # Add pages to the new event
  if battles.length==1   # Only one battle
    ret.pages = [firstpage,lastpage]
  else   # Has rematches
    ret.pages = [firstpage,rematchpage,lastpage]
  end
  # Copy last page to endIfSwitch page
  for endswitch in endifswitch
    endIfSwitchPage = Marshal::load(Marshal.dump(lastpage))
    endIfSwitchPage.condition = lastpage.condition.clone
    if endIfSwitchPage.condition.switch1_valid   # Add another page condition
      endIfSwitchPage.condition.switch2_valid = true
      endIfSwitchPage.condition.switch2_id    = endswitch
    else
      endIfSwitchPage.condition.switch1_valid = true
      endIfSwitchPage.condition.switch1_id    = endswitch
    end
    endIfSwitchPage.condition.self_switch_valid = false
    endIfSwitchPage.list = []   # Clear page's commands
    ebattle = (endbattles[0]) ? endbattles[0] : "..."
    pbPushText(endIfSwitchPage.list,ebattle)
    pbPushEnd(endIfSwitchPage.list)
    ret.pages.push(endIfSwitchPage)
  end
  # Copy last page to vanishIfSwitch page
  for vanishswitch in vanishifswitch
    vanishIfSwitchPage = Marshal::load(Marshal.dump(lastpage))
    vanishIfSwitchPage.graphic.character_name = ""   # No charset
    vanishIfSwitchPage.condition = lastpage.condition.clone
    if vanishIfSwitchPage.condition.switch1_valid   # Add another page condition
      vanishIfSwitchPage.condition.switch2_valid = true
      vanishIfSwitchPage.condition.switch2_id    = vanishswitch
    else
      vanishIfSwitchPage.condition.switch1_valid = true
      vanishIfSwitchPage.condition.switch1_id    = vanishswitch
    end
    vanishIfSwitchPage.condition.self_switch_valid = false
    vanishIfSwitchPage.list = []   # Clear page's commands
    pbPushEnd(vanishIfSwitchPage.list)
    ret.pages.push(vanishIfSwitchPage)
  end
  return ret
end

#===============================================================================
# Convert event name to item event.
# Checks if the event's name is "Item:POTION" or "HiddenItem:POTION". If so,
# rewrites the whole event into one now named "Item"/"HiddenItem" which gives
# that item when interacted with.
#===============================================================================
def pbConvertToItemEvent(event)
  return nil if !event || event.pages.length==0
  name = event.name
  ret       = RPG::Event.new(event.x,event.y)
  ret.name  = event.name
  ret.id    = event.id
  ret.pages = []
  itemName = ""
  hidden = false
  if name[/^HiddenItem\:\s*(\w+)\s*$/]
    itemName = $1
    return nil if !hasConst?(PBItems,itemName)
    ret.name = "HiddenItem"
    hidden = true
  elsif name[/^Item\:\s*(\w+)\s*$/]
    itemName = $1
    return nil if !hasConst?(PBItems,itemName)
    ret.name = "Item"
  else
    return nil
  end
  # Event page 1
  page = RPG::Event::Page.new
  page.graphic.character_name = "Object ball" if !hidden
  page.list = []
  pbPushBranch(page.list,sprintf("pbItemBall(:%s)",itemName))
  pbPushSelfSwitch(page.list,"A",true,1)
  pbPushElse(page.list,1)
  pbPushBranchEnd(page.list,1)
  pbPushEnd(page.list)
  ret.pages.push(page)
  # Event page 2
  page = RPG::Event::Page.new
  page.condition.self_switch_valid = true
  page.condition.self_switch_ch    = "A"
  ret.pages.push(page)
  return ret
end

#===============================================================================
# Checks whether a given event is likely to be a door. If so, rewrite it to
# include animating the event as though it was a door opening and closing as the
# player passes through.
#===============================================================================
def pbUpdateDoor(event,mapData)
  changed = false
  return false if event.is_a?(RPG::CommonEvent)
  # Check if event has 2+ pages and the last page meets all of these criteria:
  #   - Has a condition of a Switch being ON
  #   - The event has a charset graphic
  #   - There are more than 5 commands in that page, the first of which is a
  #     Conditional Branch
  lastPage = event.pages[event.pages.length-1]
  if event.pages.length>=2 &&
     lastPage.condition.switch1_valid &&
     lastPage.graphic.character_name!="" &&
     lastPage.list.length>5 &&
     lastPage.list[0].code==111
    # This bit of code is just in case Switch 22 has been renamed/repurposed,
    # which is highly unlikely. It changes the Switch used in the condition to
    # whichever is named 's:tsOff?("A")'.
    if lastPage.condition.switch1_id==22 &&
       mapData.switchName(lastPage.condition.switch1_id)!='s:tsOff?("A")'
      lastPage.condition.switch1_id = mapData.registerSwitch('s:tsOff?("A")')
      changed = true
    end
    # If the last page's Switch condition uses a Switch named 's:tsOff?("A")',
    # check the penultimate page. If it contains exactly 1 "Transfer Player"
    # command and does NOT contain a "Change Transparent Flag" command, rewrite
    # both the penultimate page and the last page.
    if mapData.switchName(lastPage.condition.switch1_id)=='s:tsOff?("A")'
      list = event.pages[event.pages.length-2].list
      transferCommand = list.find_all { |cmd| cmd.code==201 }   # Transfer Player
      if transferCommand.length==1 && !list.any? { |cmd| cmd.code==208 }   # Change Transparent Flag
        # Rewrite penultimate page
        list.clear
        pbPushMoveRouteAndWait(list,0,[   # Move Route for door opening
           PBMoveRoute::PlaySE,RPG::AudioFile.new("Door enter"),PBMoveRoute::Wait,2,
           PBMoveRoute::TurnLeft,PBMoveRoute::Wait,2,
           PBMoveRoute::TurnRight,PBMoveRoute::Wait,2,
           PBMoveRoute::TurnUp,PBMoveRoute::Wait,2])
        pbPushMoveRouteAndWait(list,-1,[   # Move Route for player entering door
           PBMoveRoute::ThroughOn,PBMoveRoute::Up,PBMoveRoute::ThroughOff])
        pbPushEvent(list,208,[0])   # Change Transparent Flag (invisible)
        pbPushMoveRouteAndWait(list,0,[PBMoveRoute::Wait,2,   # Move Route for door closing
           PBMoveRoute::TurnRight,PBMoveRoute::Wait,2,
           PBMoveRoute::TurnLeft,PBMoveRoute::Wait,2,
           PBMoveRoute::TurnDown,PBMoveRoute::Wait,2])
        pbPushEvent(list,223,[Tone.new(-255,-255,-255),6])   # Change Screen Color Tone
        pbPushWait(list,8)   # Wait
        pbPushEvent(list,208,[1])   # Change Transparent Flag (visible)
        pbPushEvent(list,transferCommand[0].code,transferCommand[0].parameters)   # Transfer Player
        pbPushEvent(list,223,[Tone.new(0,0,0),6])   # Change Screen Color Tone
        pbPushEnd(list)
        # Rewrite last page
        list = lastPage.list
        list.clear
        pbPushBranch(list,"get_character(0).onEvent?")   # Conditional Branch
        pbPushEvent(list,208,[0],1)   # Change Transparent Flag (invisible)
        pbPushMoveRouteAndWait(list,0,[   # Move Route for setting door to open
           PBMoveRoute::TurnLeft,PBMoveRoute::Wait,6],1)
        pbPushEvent(list,208,[1],1)   # Change Transparent Flag (visible)
        pbPushMoveRouteAndWait(list,-1,[PBMoveRoute::Down],1)   # Move Route for player exiting door
        pbPushMoveRouteAndWait(list,0,[   # Move Route for door closing
           PBMoveRoute::TurnUp,PBMoveRoute::Wait,2,
           PBMoveRoute::TurnRight,PBMoveRoute::Wait,2,
           PBMoveRoute::TurnDown,PBMoveRoute::Wait,2],1)
        pbPushBranchEnd(list,1)
        pbPushScript(list,"setTempSwitchOn(\"A\")")
        pbPushEnd(list)
        changed = true
      end
    end
  end
  return changed
end

#===============================================================================
# Fix up standard code snippets
#===============================================================================
def pbEventIsEmpty?(e)
  return true if !e
  return false if e.is_a?(RPG::CommonEvent)
  return e.pages.length==0
end

# Checks if the event has exactly 1 page, said page has no graphic, it has less
# than 12 commands and at least one is a Transfer Player, and the tiles to the
# left/right/upper left/upper right are not passable but the event's tile is.
# Causes a second page to be added to the event which is the "is player on me?"
# check that occurs when the map is entered.
def isLikelyPassage?(thisEvent,mapID,mapData)
  return false if !thisEvent || thisEvent.pages.length==0
  return false if thisEvent.pages.length!=1
  if thisEvent.pages[0].graphic.character_name=="" &&
     thisEvent.pages[0].list.length<=12 &&
     thisEvent.pages[0].list.any? { |cmd| cmd.code==201 } &&   # Transfer Player
#     mapData.isPassable?(mapID,thisEvent.x,thisEvent.y+1) &&
     mapData.isPassable?(mapID,thisEvent.x,thisEvent.y) &&
     !mapData.isPassable?(mapID,thisEvent.x-1,thisEvent.y) &&
     !mapData.isPassable?(mapID,thisEvent.x+1,thisEvent.y) &&
     !mapData.isPassable?(mapID,thisEvent.x-1,thisEvent.y-1) &&
     !mapData.isPassable?(mapID,thisEvent.x+1,thisEvent.y-1)
    return true
  end
  return false
end

def pbChangeScript(script,re)
  tmp = script[0].gsub(re) { yield($~) }
  if script[0]!=tmp
    script[0] = tmp; return true
  end
  return false
end

def pbChangeScripts(script)
  changed = false
  changed |= pbChangeScript(script,/\$game_variables\[(\d+)\](?!\s*(?:\=|\!|<|>))/) { |m| "pbGet("+m[1]+")" }
  changed |= pbChangeScript(script,/\$Trainer\.party\[\s*pbGet\((\d+)\)\s*\]/) { |m| "pbGetPokemon("+m[1]+")" }
  return changed
end

def pbFixEventUse(event,_mapID,mapData)
  return nil if pbEventIsEmpty?(event)
  changed = false
  trainerMoneyRE = /^\s*\$Trainer\.money\s*(<|<=|>|>=)\s*(\d+)\s*$/
  itemBallRE     = /^\s*(Kernel\.)?pbItemBall/
  # Rewrite event if it looks like a door
  changed = true if pbUpdateDoor(event,mapData)
  # Check through each page of the event in turn
  pbEachPage(event) do |page|
    i = 0
    list = page.list
    while i<list.length
      params = list[i].parameters
      case list[i].code
      when 655   # Script (continuation line)
        x = [params[0]]
        changed |= pbChangeScripts(x)
        params[0] = x[0]
      when 355   # Script (first line)
        lastScript = i
        if !params[0].is_a?(String)
          i += 1
          next
        end
        x = [params[0]]
        changed |= pbChangeScripts(x)
        params[0] = x[0]
        # Check if the script is an old way of healing the entire party, and if
        # so, replace it with a better version that uses event commands
        if params[0][0,1]!="f" && params[0][0,1]!="p" && params[0][0,1]!="K"
          i += 1
          next
        end
        # Script begins with "f" (for...), "p" (pbMethod) or "K" (Kernel.)
        script = " "+params[0]
        j = i+1
        while j<list.length
          break if list[j].code!=655   # Script (continuation line)
          script += list[j].parameters[0]
          lastScript = j
          j += 1
        end
        script.gsub!(/\s+/,"")
        # Using old method of recovering
        if script=="foriin$Trainer.partyi.healend"
          for j in i..lastScript
            list.delete_at(i)
          end
          list.insert(i,
             RPG::EventCommand.new(314,list[i].indent,[0])   # Recover All
          )
          changed=true
        elsif script=="pbFadeOutIn(99999){foriin$Trainer.partyi.healend}"
          oldIndent = list[i].indent
          for j in i..lastScript
            list.delete_at(i)
          end
          list.insert(i,
             RPG::EventCommand.new(223,oldIndent,[Tone.new(-255,-255,-255),6]),   # Fade to black
             RPG::EventCommand.new(106,oldIndent,[6]),                            # Wait
             RPG::EventCommand.new(314,oldIndent,[0]),                            # Recover All
             RPG::EventCommand.new(223,oldIndent,[Tone.new(0,0,0),6]),            # Fade to normal
             RPG::EventCommand.new(106,oldIndent,[6])                             # Wait
          )
          changed = true
        end
      when 108   # Comment (first line)
        # Replace a "SellItem:POTION,200" comment with event commands that do so
        if params[0][/SellItem\s*\(\s*(\w+)\s*\,\s*(\d+)\s*\)/]
          itemname = $1
          cost     = $2.to_i
          if hasConst?(PBItems,itemname)
            oldIndent = list[i].indent
            list.delete_at(i)
            newEvents = []
            if cost==0
              pbPushBranch(newEvents,"$PokemonBag.pbCanStore?(:#{itemname})",oldIndent)
              pbPushText(newEvents,_INTL("Here you go!"),oldIndent+1)
              pbPushScript(newEvents,"pbReceiveItem(:#{itemname})",oldIndent+1)
              pbPushElse(newEvents,oldIndent+1)
              pbPushText(newEvents,_INTL("You have no room left in the Bag."),oldIndent+1)
              pbPushBranchEnd(newEvents,oldIndent+1)
            else
              pbPushEvent(newEvents,111,[7,cost,0],oldIndent)
              pbPushBranch(newEvents,"$PokemonBag.pbCanStore?(:#{itemname})",oldIndent+1)
              pbPushEvent(newEvents,125,[1,0,cost],oldIndent+2)
              pbPushText(newEvents,_INTL("\\GHere you go!"),oldIndent+2)
              pbPushScript(newEvents,"pbReceiveItem(:#{itemname})",oldIndent+2)
              pbPushElse(newEvents,oldIndent+2)
              pbPushText(newEvents,_INTL("\\GYou have no room left in the Bag."),oldIndent+2)
              pbPushBranchEnd(newEvents,oldIndent+2)
              pbPushElse(newEvents,oldIndent+1)
              pbPushText(newEvents,_INTL("\\GYou don't have enough money."),oldIndent+1)
              pbPushBranchEnd(newEvents,oldIndent+1)
            end
            list[i,0] = newEvents   # insert 'newEvents' at index 'i'
            changed = true
          end
        end
      when 115   # Exit Event Processing
        if i==list.length-2
          # Superfluous exit command, delete it
          list.delete_at(i)
          changed = true
        end
      when 201   # Transfer Player
        if list.length<=8
          if params[0]==0
            # Look for another event just above the position this Transfer
            # Player command will transfer to - it may be a door, in which case
            # this command should transfer the player onto the door instead of
            # in front of it.
            e = mapData.getEventFromXY(params[1],params[2],params[3]-1)
            # This bit of code is just in case Switch 22 has been renamed/
            # repurposed, which is highly unlikely. It changes the Switch used
            # in the found event's condition to whichever is named
            # 's:tsOff?("A")'.
            if e && e.pages.length>=2 &&
               e.pages[e.pages.length-1].condition.switch1_valid &&
               e.pages[e.pages.length-1].condition.switch1_id==22 &&
               mapData.switchName(e.pages[e.pages.length-1].condition.switch1_id)!='s:tsOff?("A")' &&
               e.pages[e.pages.length-1].list.length>5 &&
               e.pages[e.pages.length-1].list[0].code==111   # Conditional Branch
              e.pages[e.pages.length-1].condition.switch1_id = mapData.registerSwitch('s:tsOff?("A")')
              mapData.saveMap(params[1])
              changed = true
            end
            # Checks if the found event is a simple Transfer Player one nestled
            # between tiles that aren't passable - it is likely a door, so give
            # it a second page with an "is player on me?" check.
            if isLikelyPassage?(e,params[1],mapData)   # Checks the first page
              pbAddPassageList(e,mapData)
              mapData.saveMap(params[1])
              changed = true
            end
            # If the found event's last page's Switch condition uses a Switch
            # named 's:tsOff?("A")', it really does look like a door. Make this
            # command transfer the player on top of it rather than in front of
            # it.
            if e && e.pages.length>=2 &&
               e.pages[e.pages.length-1].condition.switch1_valid &&
               mapData.switchName(e.pages[e.pages.length-1].condition.switch1_id)=='s:tsOff?("A")'
              # If this is really a door, move transfer target to it
              params[3] -= 1   # Move this command's destination up 1 tile (onto the found event)
              params[5]  = 1   # No fade (the found event should take care of that)
              changed = true
            end
            deletedRoute = nil
            deleteMoveRouteAt = proc { |list,i|
              arr = []
              if list[i] && list[i].code==209   # Set Move Route
                arr.push(list[i]); list.delete_at(i)
                while i<list.length
                  break if !list[i] || list[i].code!=509   # Set Move Route (continuation line)
                  arr.push(list[i]); list.delete_at(i)
                end
              end
              next arr
            }
            insertMoveRouteAt = proc { |list,i,route|
              j = route.length-1
              while j>=0
                list.insert(i,route[j])
                j -= 1
              end
            }
            # If the next event command is a Move Route that moves the player,
            # check whether all it does is turn the player in a direction (or
            # its first item is to move the player in a direction). If so, this
            # Transfer Player command may as well set the player's direction
            # instead; make it do so and delete that Move Route.
            if params[4]==0 &&   # Retain direction
               i+1<list.length && list[i+1].code==209 && list[i+1].parameters[0]==-1   # Set Move Route
              route = list[i+1].parameters[1]
              if route && route.list.length<=2
                # Delete superfluous move route command if necessary
                if route.list[0].code==16      # Player Turn Down
                  deleteMoveRouteAt.call(list,i+1); params[4] = 2; changed = true
                elsif route.list[0].code==17   # Player Turn Left
                  deleteMoveRouteAt.call(list,i+1); params[4] = 4; changed = true
                elsif route.list[0].code==18   # Player Turn Right
                  deleteMoveRouteAt.call(list,i+1); params[4] = 6; changed = true
                elsif route.list[0].code==19   # Player Turn Up
                  deleteMoveRouteAt.call(list,i+1); params[4] = 8; changed = true
                elsif (route.list[0].code==1 || route.list[0].code==2 ||   # Player Move (4-dir)
                   route.list[0].code==3 || route.list[0].code==4) && list.length==4
                  params[4] = [0,2,4,6,8][route.list[0].code]
                  deletedRoute = deleteMoveRouteAt.call(list,i+1); changed = true
                end
              end
            # If an event command before this one is a Move Route that just
            # turns the player, delete it and make this Transfer Player command
            # set the player's direction instead.
            # (I don't know if it makes sense to do this, as there could be a
            # lot of commands between then and this Transfer Player which this
            # code can't recognise and deal with, so I've quoted this code out.)
            elsif params[4]==0 && i>3   # Retain direction
#              for j in 0...i
#                if list[j].code==209 && list[j].parameters[0]==-1   # Set Move Route
#                  route = list[j].parameters[1]
#                  if route && route.list.length<=2
#                    oldlistlength = list.length
#                    # Delete superfluous move route command if necessary
#                    if route.list[0].code==16      # Player Turn Down
#                      deleteMoveRouteAt.call(list,j); params[4] = 2; changed = true; i -= (oldlistlength-list.length)
#                    elsif route.list[0].code==17   # Player Turn Left
#                      deleteMoveRouteAt.call(list,j); params[4] = 4; changed = true; i -= (oldlistlength-list.length)
#                    elsif route.list[0].code==18   # Player Turn Right
#                      deleteMoveRouteAt.call(list,j); params[4] = 6; changed = true; i -= (oldlistlength-list.length)
#                    elsif route.list[0].code==19   # Player Turn Up
#                      deleteMoveRouteAt.call(list,j); params[4] = 8; changed = true; i -= (oldlistlength-list.length)
#                    end
#                  end
#                end
#              end
            # If the next event command changes the screen color, and the one
            # after that is a Move Route which only turns the player in a
            # direction, this Transfer Player command may as well set the
            # player's direction instead; make it do so and delete that Move
            # Route.
            elsif params[4]==0 &&   # Retain direction
               i+2<list.length &&
               list[i+1].code==223 &&   # Change Screen Color Tone
               list[i+2].code==209 &&   # Set Move Route
               list[i+2].parameters[0]==-1
              route = list[i+2].parameters[1]
              if route && route.list.length<=2
                # Delete superfluous move route command if necessary
                if route.list[0].code==16      # Player Turn Down
                  deleteMoveRouteAt.call(list,i+2); params[4] = 2; changed = true
                elsif route.list[0].code==17   # Player Turn Left
                  deleteMoveRouteAt.call(list,i+2); params[4] = 4; changed = true
                elsif route.list[0].code==18   # Player Turn Right
                  deleteMoveRouteAt.call(list,i+2); params[4] = 6; changed = true
                elsif route.list[0].code==19   # Player Turn Up
                  deleteMoveRouteAt.call(list,i+2); params[4] = 8; changed = true
                end
              end
            end
          end
          # If this is the only event command, convert to a full event
          if list.length==2 || (list.length==3 && (list[0].code==250 || list[1].code==250))   # Play SE
            params[5] = 1   # No fade
            fullTransfer = list[i]
            indent = list[i].indent
            (list.length-1).times { list.delete_at(0) }
            list.insert(0,
               RPG::EventCommand.new(250,indent,[RPG::AudioFile.new("Exit Door",80,100)]),   # Play SE
               RPG::EventCommand.new(223,indent,[Tone.new(-255,-255,-255),6]),               # Fade to black
               RPG::EventCommand.new(106,indent,[8]),                                        # Wait
               fullTransfer,                                                                 # Transfer event
               RPG::EventCommand.new(223,indent,[Tone.new(0,0,0),6])                         # Fade to normal
            )
            changed = true
          end
          if deletedRoute
            insertMoveRouteAt.call(list,list.length-1,deletedRoute)
            changed = true
          end
        end
      when 101   # Show Text
        # Capitalise/decapitalise various text formatting codes
        if list[i].parameters[0][0,1]=="\\"
          newx = list[i].parameters[0].clone
          newx.sub!(/^\\[Bb]\s+/,"\\b")
          newx.sub!(/^\\[Rr]\s+/,"\\r")
          newx.sub!(/^\\[Pp][Gg]\s+/,"\\pg")
          newx.sub!(/^\\[Pp][Oo][Gg]\s+/,"\\pog")
          newx.sub!(/^\\[Gg]\s+/,"\\G")
          newx.sub!(/^\\[Cc][Nn]\s+/,"\\CN")
          if list[i].parameters[0]!=newx
            list[i].parameters[0] = newx
            changed = true
          end
        end
        # Split Show Text commands with 5+ lines into multiple Show Text
        # commands each with a maximum of 4 lines
        lines = 1
        j = i+1
        while j<list.length
          break if list[j].code!=401   # Show Text (continuation line)
          if lines%4==0
            list[j].code = 101   # Show Text
            changed = true
          end
          lines += 1
          j += 1
        end
        # If this Show Text command has 2+ lines of text but not much actual
        # text in the first line, merge the second line into it
        if lines>=2 && list[i].parameters[0].length>0 && list[i].parameters[0].length<=20 &&
           !list[i].parameters[0][/\\n/]
          # Very short line
          list[i].parameters[0] += "\\n"+list[i+1].parameters[0]
          list.delete_at(i+1)
          i -= 1   # revisit this text command
          changed = true
        # Check whether this Show Text command has 3+ lines and the next command
        # is also a Show Text
        elsif lines>=3 && list[i+lines] && list[i+lines].code==101   # Show Text
          # Check whether a sentence is being broken midway between two Text
          # commands (i.e. the first Show Text doesn't end in certain punctuation)
          lastLine = list[i+lines-1].parameters[0].sub(/\s+$/,"")
          if lastLine.length>0 && !lastLine[/[\\<]/] && lastLine[/[^\.,\!\?\;\-\"]$/]
            message = list[i].parameters[0]
            j = i+1
            while j<list.length
              break if list[j].code!=401   # Show Text (continuation line)
              message += "\n"+list[j].parameters[0]
              j += 1
            end
            # Find a punctuation mark to split at
            punct = [message.rindex(". "),message.rindex(".\n"),
               message.rindex("!"),message.rindex("?"),-1].compact.max
            if punct==-1
              punct = [message.rindex(", "),message.rindex(",\n"),-1].compact.max
            end
            if punct!=-1
              # Delete old message
              indent = list[i].indent
              newMessage  = message[0,punct+1].split("\n")
              nextMessage = message[punct+1,message.length].sub(/^\s+/,"").split("\n")
              list[i+lines].code = 401
              lines.times { list.delete_at(i) }
              j = nextMessage.length-1
              while j>=0
                list.insert(i,RPG::EventCommand.new((j==0) ? 101 : 401,indent,[nextMessage[j]]))
                j-=1
              end
              j = newMessage.length-1
              while j>=0
                list.insert(i,RPG::EventCommand.new((j==0) ? 101 : 401,indent,[newMessage[j]]))
                j -= 1
              end
              changed = true
              i += 1
              next
            end
          end
        end
      when 111   # Conditional Branch
        if list[i].parameters[0]==12   # script
          x = [list[i].parameters[1]]
          changed |= pbChangeScripts(x)
          list[i].parameters[1] = x[0]
          script = x[0]
          if script[trainerMoneyRE]   # Compares $Trainer.money with a value
            # Checking money directly
            operator = $1
            amount   = $2.to_i
            if operator=="<"
              params[0] = 7   # gold
              params[2] = 1
              params[1] = amount-1
              changed = true
            elsif operator=="<="
              params[0] = 7   # gold
              params[2] = 1
              params[1] = amount
              changed = true
            elsif operator==">"
              params[0] = 7   # gold
              params[2] = 0
              params[1] = amount+1
              changed = true
            elsif operator==">="
              params[0] = 7   # gold
              params[2] = 0
              params[1] = amount
              changed = true
            end
          elsif script[itemBallRE] && i>0   # Contains pbItemBall after another command
            # Using pbItemBall on non-item events, change it
            list[i].parameters[1] = script.sub(/pbItemBall/,"pbReceiveItem")
            changed = true
          elsif script[/^\s*(Kernel\.)?(pbTrainerBattle|pbDoubleTrainerBattle)/]
            # Check if trainer battle conditional branch is empty
            j = i+1
            isempty = true
            elseIndex = -1
            # Check if page is empty
            while j<page.list.length
              if list[j].indent<=list[i].indent
                if list[j].code==411   # Else
                  elseIndex = j
                else
                  break   # Reached end of Conditional Branch
                end
              end
              if list[j].code!=0 && list[j].code!=411   # Else
                isempty = false
                break
              end
              j += 1
            end
            if isempty
              if elseIndex>=0
                list.insert(elseIndex+1,
                   RPG::EventCommand.new(115,list[i].indent+1,[])   # Exit Event Processing
                )
              else
                list.insert(i+1,
                   RPG::EventCommand.new(0,list[i].indent+1,[]),    # Empty Event
                   RPG::EventCommand.new(411,list[i].indent,[]),    # Else
                   RPG::EventCommand.new(115,list[i].indent+1,[])   # Exit Event Processing
                )
              end
              changed = true
            end
          end
        end
      end
      i += 1
    end
  end
  return (changed) ? event : nil
end

#===============================================================================
# Convert events used as counters into proper counters.
#===============================================================================
# Checks if the event has just 1 page, which has no conditions and no commands
# and whose movement type is "Fixed".
def isPlainEvent?(event)
  return false unless event
  return false if event.pages.length>1
  return false if event.pages[0].move_type!=0
  return false if event.pages[0].condition.switch1_valid ||
                  event.pages[0].condition.switch2_valid ||
                  event.pages[0].condition.variable_valid ||
                  event.pages[0].condition.self_switch_valid
  return true if event.pages[0].list.length<=1
  return false
end

# Checks if the event has just 1 page, which has no conditions and whose
# movement type is "Fixed". Then checks if there are no commands, or it looks
# like a simple Mart or a Poké Center nurse event.
def isPlainEventOrMart?(event)
  return false unless event
  return false if event.pages.length>1
  return false if event.pages[0].move_type!=0
  return false if event.pages[0].condition.switch1_valid ||
                  event.pages[0].condition.switch2_valid ||
                  event.pages[0].condition.variable_valid ||
                  event.pages[0].condition.self_switch_valid
  # No commands in the event
  return true if event.pages[0].list.length<=1
  # pbPokemonMart events
  return true if event.pages[0].list.length<=12 &&
                 event.pages[0].graphic.character_name!="" &&   # Has charset
                 event.pages[0].list[0].code==355 &&   # First line is Script
                 event.pages[0].list[0].parameters[0][/^pbPokemonMart/]
  # pbSetPokemonCenter events
  return true if event.pages[0].list.length>8 &&
                 event.pages[0].graphic.character_name!="" &&   # Has charset
                 event.pages[0].list[0].code==355 &&   # First line is Script
                 event.pages[0].list[0].parameters[0][/^pbSetPokemonCenter/]
  return false
end

# Given two events that are next to each other, decides whether otherEvent is
# likely to be a "counter event", i.e. is placed on a tile with the Counter
# flag, or is on a non-passable tile between two passable tiles (e.g. a desk)
# where one of those two tiles is occupied by thisEvent.
def isLikelyCounter?(thisEvent,otherEvent,mapID,mapData)
  # Check whether otherEvent is on a counter tile
  return true if mapData.isCounterTile?(mapID,otherEvent.x,otherEvent.y)
  # Check whether otherEvent is between an event with a graphic (e.g. an NPC)
  # and a spot where the player can be
  yonderX = otherEvent.x + (otherEvent.x - thisEvent.x)
  yonderY = otherEvent.y + (otherEvent.y - thisEvent.y)
  return thisEvent.pages[0].graphic.character_name!="" &&    # Has charset
         otherEvent.pages[0].graphic.character_name=="" &&   # Has no charset
         otherEvent.pages[0].trigger==0 &&                   # Action trigger
         mapData.isPassable?(mapID,thisEvent.x,thisEvent.y) &&
         !mapData.isPassable?(mapID,otherEvent.x,otherEvent.y) &&
         mapData.isPassable?(mapID,yonderX,yonderY)
end

# Checks all events in the given map to see if any look like they've been placed
# on a desk with an NPC behind it, where the event on the desk is the actual
# interaction with the NPC. In other words, it's not making proper use of the
# counter flag (which lets the player interact with an event on the other side
# of counter tiles).
# Any events found to be like this have their contents merged into the NPC event
# and the counter event itself is deleted. The tile below the counter event gets
# its counter flag set (if it isn't already).
def pbCheckCounters(map,mapID,mapData)
  toDelete = []
  changed = false
  for key in map.events.keys
    event = map.events[key]
    next if !isPlainEventOrMart?(event)
    # Found an event that is empty or looks like a simple Mart or a Poké Center
    # nurse. Check adjacent events to see if they are "counter events".
    neighbors = []
    neighbors.push(mapData.getEventFromXY(mapID,event.x,event.y-1))
    neighbors.push(mapData.getEventFromXY(mapID,event.x,event.y+1))
    neighbors.push(mapData.getEventFromXY(mapID,event.x-1,event.y))
    neighbors.push(mapData.getEventFromXY(mapID,event.x+1,event.y))
    neighbors.compact!
    for otherEvent in neighbors
      next if isPlainEvent?(otherEvent)   # Blank/cosmetic-only event
      next if !isLikelyCounter?(event,otherEvent,mapID,mapData)
      # Found an adjacent event that looks like it's supposed to be a counter.
      # Set the counter flag of the tile beneath the counter event, copy the
      # counter event's pages to the NPC event, and delete the counter event.
      mapData.setCounterTile(mapID,otherEvent.x,otherEvent.y)
      savedPage = event.pages[0]
      event.pages = otherEvent.pages
      applyPages(savedPage,event.pages)   # Apply NPC's visuals to new event pages
      toDelete.push(otherEvent.id)
      changed = true
    end
  end
  toDelete.each { |key| map.events.delete(key) }
  return changed
end

#===============================================================================
# Main compiler method for events
#===============================================================================
def pbCompileTrainerEvents(_mustcompile)
  mapData = MapData.new
  t = Time.now.to_i
  Graphics.update
  trainerChecker = TrainerChecker.new
  for id in mapData.mapinfos.keys.sort
    changed = false
    map = mapData.getMap(id)
    next if !map || !mapData.mapinfos[id]
    Win32API.SetWindowText(_INTL("Processing map {1} ({2})",id,mapData.mapinfos[id].name))
    for key in map.events.keys
      if Time.now.to_i-t>=5
        Graphics.update
        t = Time.now.to_i
      end
      newevent = pbConvertToTrainerEvent(map.events[key],trainerChecker)
      if newevent
        map.events[key] = newevent; changed = true
      end
      newevent = pbConvertToItemEvent(map.events[key])
      if newevent
        map.events[key] = newevent; changed = true
      end
      newevent = pbFixEventUse(map.events[key],id,mapData)
      if newevent
        map.events[key] = newevent; changed = true
      end
    end
    if Time.now.to_i-t>=5
      Graphics.update
      t = Time.now.to_i
    end
    changed = true if pbCheckCounters(map,id,mapData)
    if changed
      mapData.saveMap(id)
      mapData.saveTilesets
    end
  end
  changed = false
  Graphics.update
  commonEvents = pbLoadRxData("Data/CommonEvents")
  Win32API.SetWindowText(_INTL("Processing common events"))
  for key in 0...commonEvents.length
    newevent = pbFixEventUse(commonEvents[key],0,mapData)
    if newevent
      commonEvents[key] = newevent; changed = true
    end
  end
  if changed
    if $RPGVX
      save_data(commonEvents,"Data/CommonEvents.rvdata")
    else
      save_data(commonEvents,"Data/CommonEvents.rxdata")
    end
  end
end
