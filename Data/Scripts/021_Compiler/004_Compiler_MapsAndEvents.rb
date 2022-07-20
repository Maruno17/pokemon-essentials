module Compiler
  SCRIPT_REPLACEMENTS = [
    ["Kernel.",                      ""],
    ["$PokemonBag.pbQuantity",       "$bag.quantity"],
    ["$PokemonBag.pbHasItem?",       "$bag.has?"],
    ["$PokemonBag.pbCanStore?",      "$bag.can_add?"],
    ["$PokemonBag.pbStoreItem",      "$bag.add"],
    ["$PokemonBag.pbStoreAllOrNone", "$bag.add_all"],
    ["$PokemonBag.pbChangeItem",     "$bag.replace_item"],
    ["$PokemonBag.pbDeleteItem",     "$bag.remove"],
    ["$PokemonBag.pbIsRegistered?",  "$bag.registered?"],
    ["$PokemonBag.pbRegisterItem",   "$bag.register"],
    ["$PokemonBag.pbUnregisterItem", "$bag.unregister"],
    ["$PokemonBag",                  "$bag"],
    ["pbQuantity",                   "$bag.quantity"],
    ["pbHasItem?",                   "$bag.has?"],
    ["pbCanStore?",                  "$bag.can_add?"],
    ["pbStoreItem",                  "$bag.add"],
    ["pbStoreAllOrNone",             "$bag.add_all"],
    ["$Trainer",                     "$player"],
    ["$SaveVersion",                 "$save_engine_version"],
    ["$game_version",                "$save_game_version"],
    ["$MapFactory",                  "$map_factory"],
    ["pbDayCareDeposited",           "DayCare.count"],
    ["pbDayCareGetDeposited",        "DayCare.get_details"],
    ["pbDayCareGetLevelGain",        "DayCare.get_level_gain"],
    ["pbDayCareDeposit",             "DayCare.deposit"],
    ["pbDayCareWithdraw",            "DayCare.withdraw"],
    ["pbDayCareChoose",              "DayCare.choose"],
    ["pbDayCareGetCompatibility",    "DayCare.get_compatibility"],
    ["pbEggGenerated?",              "DayCare.egg_generated?"],
    ["pbDayCareGenerateEgg",         "DayCare.collect_egg"],
    ["get_character(0)",             "get_self"],
    ["get_character(-1)",            "get_player"],
    ["pbCheckAble",                  "$player.has_other_able_pokemon?"],
    ["$PokemonTemp.lastbattle",      "$game_temp.last_battle_record"],
    ["calcStats",                    "calc_stats"]
  ]

  module_function

  #=============================================================================
  # Add new map files to the map tree.
  #=============================================================================
  def import_new_maps
    return false if !$DEBUG
    mapfiles = {}
    # Get IDs of all maps in the Data folder
    Dir.chdir("Data") {
      mapData = sprintf("Map*.rxdata")
      Dir.glob(mapData).each do |map|
        mapfiles[$1.to_i(10)] = true if map[/map(\d+)\.rxdata/i]
      end
    }
    mapinfos = pbLoadMapInfos
    maxOrder = 0
    # Exclude maps found in mapinfos
    mapinfos.each_key do |id|
      next if !mapinfos[id]
      mapfiles.delete(id) if mapfiles[id]
      maxOrder = [maxOrder, mapinfos[id].order].max
    end
    # Import maps not found in mapinfos
    maxOrder += 1
    imported = false
    count = 0
    mapfiles.each_key do |id|
      next if id == 999   # Ignore 999 (random dungeon map)
      mapinfo = RPG::MapInfo.new
      mapinfo.order = maxOrder
      mapinfo.name  = sprintf("MAP%03d", id)
      maxOrder += 1
      mapinfos[id] = mapinfo
      imported = true
      count += 1
    end
    if imported
      save_data(mapinfos, "Data/MapInfos.rxdata")
      $game_temp.map_infos = nil
      pbMessage(_INTL("{1} new map(s) copied to the Data folder were successfully imported.", count))
    end
    return imported
  end

  #=============================================================================
  # Generate and modify event commands.
  #=============================================================================
  def generate_move_route(commands)
    route           = RPG::MoveRoute.new
    route.repeat    = false
    route.skippable = true
    route.list.clear
    i = 0
    while i < commands.length
      case commands[i]
      when PBMoveRoute::Wait, PBMoveRoute::SwitchOn, PBMoveRoute::SwitchOff,
           PBMoveRoute::ChangeSpeed, PBMoveRoute::ChangeFreq, PBMoveRoute::Opacity,
           PBMoveRoute::Blending, PBMoveRoute::PlaySE, PBMoveRoute::Script
        route.list.push(RPG::MoveCommand.new(commands[i], [commands[i + 1]]))
        i += 1
      when PBMoveRoute::ScriptAsync
        route.list.push(RPG::MoveCommand.new(PBMoveRoute::Script, [commands[i + 1]]))
        route.list.push(RPG::MoveCommand.new(PBMoveRoute::Wait, [0]))
        i += 1
      when PBMoveRoute::Jump
        route.list.push(RPG::MoveCommand.new(commands[i], [commands[i + 1], commands[i + 2]]))
        i += 2
      when PBMoveRoute::Graphic
        route.list.push(RPG::MoveCommand.new(commands[i], [commands[i + 1], commands[i + 2], commands[i + 3], commands[i + 4]]))
        i += 4
      else
        route.list.push(RPG::MoveCommand.new(commands[i]))
      end
      i += 1
    end
    route.list.push(RPG::MoveCommand.new(0))
    return route
  end

  def push_move_route(list, character, route, indent = 0)
    route = generate_move_route(route) if route.is_a?(Array)
    route.list.length.times do |i|
      list.push(
        RPG::EventCommand.new((i == 0) ? 209 : 509, indent,
                              (i == 0) ? [character, route] : [route.list[i - 1]])
      )
    end
  end

  def push_move_route_and_wait(list, character, route, indent = 0)
    push_move_route(list, character, route, indent)
    push_event(list, 210, [], indent)
  end

  def push_wait(list, frames, indent = 0)
    push_event(list, 106, [frames], indent)
  end

  def push_event(list, cmd, params = nil, indent = 0)
    list.push(RPG::EventCommand.new(cmd, indent, params || []))
  end

  def push_end(list)
    list.push(RPG::EventCommand.new(0, 0, []))
  end

  def push_comment(list, cmt, indent = 0)
    textsplit2 = cmt.split(/\n/)
    textsplit2.length.times do |i|
      list.push(RPG::EventCommand.new((i == 0) ? 108 : 408, indent, [textsplit2[i].gsub(/\s+$/, "")]))
    end
  end

  def push_text(list, text, indent = 0)
    return if !text
    textsplit = text.split(/\\m/)
    textsplit.each do |t|
      first = true
      textsplit2 = t.split(/\n/)
      textsplit2.length.times do |i|
        textchunk = textsplit2[i].gsub(/\s+$/, "")
        if textchunk && textchunk != ""
          list.push(RPG::EventCommand.new((first) ? 101 : 401, indent, [textchunk]))
          first = false
        end
      end
    end
  end

  def push_script(list, script, indent = 0)
    return if !script
    first = true
    textsplit2 = script.split(/\n/)
    textsplit2.length.times do |i|
      textchunk = textsplit2[i].gsub(/\s+$/, "")
      if textchunk && textchunk != ""
        list.push(RPG::EventCommand.new((first) ? 355 : 655, indent, [textchunk]))
        first = false
      end
    end
  end

  def push_exit(list, indent = 0)
    list.push(RPG::EventCommand.new(115, indent, []))
  end

  def push_else(list, indent = 0)
    list.push(RPG::EventCommand.new(0, indent, []))
    list.push(RPG::EventCommand.new(411, indent - 1, []))
  end

  def push_branch(list, script, indent = 0)
    list.push(RPG::EventCommand.new(111, indent, [12, script]))
  end

  def push_branch_end(list, indent = 0)
    list.push(RPG::EventCommand.new(0, indent, []))
    list.push(RPG::EventCommand.new(412, indent - 1, []))
  end

  def push_self_switch(list, swtch, switchOn, indent = 0)
    list.push(RPG::EventCommand.new(123, indent, [swtch, switchOn ? 0 : 1]))
  end

  def apply_pages(page, pages)
    pages.each do |p|
      p.graphic       = page.graphic
      p.walk_anime    = page.walk_anime
      p.step_anime    = page.step_anime
      p.direction_fix = page.direction_fix
      p.through       = page.through
      p.always_on_top = page.always_on_top
    end
  end

  def add_passage_list(event, mapData)
    return if !event || event.pages.length == 0
    page                         = RPG::Event::Page.new
    page.condition.switch1_valid = true
    page.condition.switch1_id    = mapData.registerSwitch('s:tsOff?("A")')
    page.graphic.character_name  = ""
    page.trigger                 = 3   # Autorun
    page.list.clear
    list = page.list
    push_branch(list, "get_self.onEvent?")
    push_event(list, 208, [0], 1)   # Change Transparent Flag
    push_wait(list, 6, 1)          # Wait
    push_event(list, 208, [1], 1)   # Change Transparent Flag
    push_move_route_and_wait(list, -1, [PBMoveRoute::Down], 1)
    push_branch_end(list, 1)
    push_script(list, "setTempSwitchOn(\"A\")")
    push_end(list)
    event.pages.push(page)
  end

  #=============================================================================
  #
  #=============================================================================
  def safequote(x)
    x = x.gsub(/\"\#\'\\/) { |a| "\\" + a }
    x = x.gsub(/\t/, "\\t")
    x = x.gsub(/\r/, "\\r")
    x = x.gsub(/\n/, "\\n")
    return x
  end

  def safequote2(x)
    x = x.gsub(/\"\#\'\\/) { |a| "\\" + a }
    x = x.gsub(/\t/, "\\t")
    x = x.gsub(/\r/, "\\r")
    x = x.gsub(/\n/, " ")
    return x
  end

  def pbEventId(event)
    list = event.pages[0].list
    return nil if list.length == 0
    codes = []
    i = 0
    while i < list.length
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

  #=============================================================================
  #
  #=============================================================================
  class MapData
    attr_reader :mapinfos

    def initialize
      @mapinfos = pbLoadMapInfos
      @system   = load_data("Data/System.rxdata")
      @tilesets = load_data("Data/Tilesets.rxdata")
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
      return sprintf("Data/map%03d.rxdata", mapID)
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

    def getEventFromXY(mapID, x, y)
      return nil if x < 0 || y < 0
      mapPositions = @mapxy[mapID]
      return mapPositions[(y * @mapWidths[mapID]) + x] if mapPositions
      map = getMap(mapID)
      return nil if !map
      @mapWidths[mapID]  = map.width
      @mapHeights[mapID] = map.height
      mapPositions = []
      width = map.width
      map.events.each_value do |e|
        mapPositions[(e.y * width) + e.x] = e if e
      end
      @mapxy[mapID] = mapPositions
      return mapPositions[(y * width) + x]
    end

    def getEventFromID(mapID, id)
      map = getMap(mapID)
      return nil if !map
      return map.events[id]
    end

    def getTilesetPassages(map, mapID)
      begin
        return @tilesets[map.tileset_id].passages
      rescue
        raise "Tileset data for tileset number #{map.tileset_id} used on map #{mapID} was not found. " +
              "The tileset was likely deleted, but one or more maps still use it."
      end
    end

    def getTilesetPriorities(map, mapID)
      begin
        return @tilesets[map.tileset_id].priorities
      rescue
        raise "Tileset data for tileset number #{map.tileset_id} used on map #{mapID} was not found. " +
              "The tileset was likely deleted, but one or more maps still use it."
      end
    end

    def isPassable?(mapID, x, y)
      map = getMap(mapID)
      return false if !map
      return false if x < 0 || x >= map.width || y < 0 || y >= map.height
      passages   = getTilesetPassages(map, mapID)
      priorities = getTilesetPriorities(map, mapID)
      [2, 1, 0].each do |i|
        tile_id = map.data[x, y, i]
        return false if tile_id.nil?
        passage = passages[tile_id]
        if !passage
          raise "The tile used on map #{mapID} at coordinates (#{x}, #{y}) on layer #{i + 1} doesn't exist in the tileset. " +
                "It should be deleted to prevent errors."
        end
        return false if passage & 0x0f == 0x0f
        return true if priorities[tile_id] == 0
      end
      return true
    end

    def isCounterTile?(mapID, x, y)
      map = getMap(mapID)
      return false if !map
      passages = getTilesetPassages(map, mapID)
      [2, 1, 0].each do |i|
        tile_id = map.data[x, y, i]
        return false if tile_id.nil?
        passage = passages[tile_id]
        if !passage
          raise "The tile used on map #{mapID} at coordinates (#{x}, #{y}) on layer #{i + 1} doesn't exist in the tileset. " +
                "It should be deleted to prevent errors."
        end
        return true if passage & 0x80 == 0x80
      end
      return false
    end

    def setCounterTile(mapID, x, y)
      map = getMap(mapID)
      return if !map
      passages = getTilesetPassages(map, mapID)
      [2, 1, 0].each do |i|
        tile_id = map.data[x, y, i]
        next if tile_id == 0
        passages[tile_id] |= 0x80
        break
      end
    end

    def registerSwitch(switch)
      return @registeredSwitches[switch] if @registeredSwitches[switch]
      (1..5000).each do |id|
        name = @system.switches[id]
        next if name && name != "" && name != switch
        @system.switches[id] = switch
        @registeredSwitches[switch] = id
        return id
      end
      return 1
    end

    def saveMap(mapID)
      save_data(getMap(mapID), mapFilename(mapID)) rescue nil
    end

    def saveTilesets
      save_data(@tilesets, "Data/Tilesets.rxdata")
      save_data(@system, "Data/System.rxdata")
    end
  end

  #=============================================================================
  #
  #=============================================================================
  class TrainerChecker
    def initialize
      @dontaskagain = false
    end

    def pbTrainerTypeCheck(trainer_type)
      return if !$DEBUG || @dontaskagain
      return if GameData::TrainerType.exists?(trainer_type)
      if pbConfirmMessage(_INTL("Add new trainer type {1}?", trainer_type.to_s))
        pbTrainerTypeEditorNew(trainer_type.to_s)
      end
    end

    def pbTrainerBattleCheck(tr_type, tr_name, tr_version)
      return if !$DEBUG || @dontaskagain
      # Check for existence of trainer type
      pbTrainerTypeCheck(tr_type)
      return if !GameData::TrainerType.exists?(tr_type)
      tr_type = GameData::TrainerType.get(tr_type).id
      # Check for existence of trainer
      return if GameData::Trainer.exists?(tr_type, tr_name, tr_version)
      # Add new trainer
      cmd = pbMissingTrainer(tr_type, tr_name, tr_version)
      if cmd == 2
        @dontaskagain = true
        Graphics.update
      end
    end
  end

  #=============================================================================
  # Convert trainer comments to trainer event.
  #=============================================================================
  def convert_to_trainer_event(event, trainerChecker)
    return nil if !event || event.pages.length == 0
    list = event.pages[0].list
    return nil if list.length < 2
    commands = []
    isFirstCommand = false
    # Find all the trainer comments in the event
    list.length.times do |i|
      next if list[i].code != 108   # Comment (first line)
      command = list[i].parameters[0]
      ((i + 1)...list.length).each do |j|
        break if list[j].code != 408   # Comment (continuation line)
        command += "\r\n" + list[j].parameters[0]
      end
      if command[/^(Battle\:|Type\:|Name\:|BattleID\:|DoubleBattle\:|Backdrop\:|EndSpeech\:|Outcome\:|Continue\:|EndBattle\:|EndIfSwitch\:|VanishIfSwitch\:|RegSpeech\:)/i]
        commands.push(command)
        isFirstCommand = true if i == 0
      end
    end
    return nil if commands.length == 0
    # Found trainer comments; create a new Event object to replace this event
    ret = RPG::Event.new(event.x, event.y)
    ret.name = event.name
    ret.id   = event.id
    firstpage = Marshal.load(Marshal.dump(event.pages[0]))   # Copy event's first page
    firstpage.trigger = 2   # On event touch
    firstpage.list    = []   # Clear page's commands
    # Rename the event if there's nothing above the trainer comments
    if isFirstCommand
      if !event.name[/trainer/i]
        ret.name = "Trainer(3)"
      elsif event.name[/^\s*trainer\s*\((\d+)\)\s*$/i]
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
    commands.each do |command|
      if command[/^Battle\:\s*([\s\S]+)$/i]
        battles.push($~[1])
        push_comment(firstpage.list, command) if rewriteComments
      elsif command[/^Type\:\s*([\s\S]+)$/i]
        trtype = $~[1].gsub(/^\s+/, "").gsub(/\s+$/, "")
        push_comment(firstpage.list, command) if rewriteComments
      elsif command[/^Name\:\s*([\s\S]+)$/i]
        trname = $~[1].gsub(/^\s+/, "").gsub(/\s+$/, "")
        push_comment(firstpage.list, command) if rewriteComments
      elsif command[/^BattleID\:\s*(\d+)$/i]
        battleid = $~[1].to_i
        push_comment(firstpage.list, command) if rewriteComments
      elsif command[/^DoubleBattle\:\s*([\s\S]+)$/i]
        value = $~[1].gsub(/^\s+/, "").gsub(/\s+$/, "")
        doublebattle = true if value.upcase == "TRUE" || value.upcase == "YES"
        push_comment(firstpage.list, command) if rewriteComments
      elsif command[/^Backdrop\:\s*([\s\S]+)$/i]
        backdrop = $~[1].gsub(/^\s+/, "").gsub(/\s+$/, "")
        push_comment(firstpage.list, command) if rewriteComments
      elsif command[/^EndSpeech\:\s*([\s\S]+)$/i]
        endspeeches.push(command)
        push_comment(firstpage.list, command) if rewriteComments
      elsif command[/^Outcome\:\s*(\d+)$/i]
        outcome = $~[1].to_i
        push_comment(firstpage.list, command) if rewriteComments
      elsif command[/^Continue\:\s*([\s\S]+)$/i]
        value = $~[1].gsub(/^\s+/, "").gsub(/\s+$/, "")
        continue = true if value.upcase == "TRUE" || value.upcase == "YES"
        push_comment(firstpage.list, command) if rewriteComments
      elsif command[/^EndBattle\:\s*([\s\S]+)$/i]
        endbattles.push($~[1].gsub(/^\s+/, "").gsub(/\s+$/, ""))
        push_comment(firstpage.list, command) if rewriteComments
      elsif command[/^EndIfSwitch\:\s*([\s\S]+)$/i]
        endifswitch.push(($~[1].gsub(/^\s+/, "").gsub(/\s+$/, "")).to_i)
        push_comment(firstpage.list, command) if rewriteComments
      elsif command[/^VanishIfSwitch\:\s*([\s\S]+)$/i]
        vanishifswitch.push(($~[1].gsub(/^\s+/, "").gsub(/\s+$/, "")).to_i)
        push_comment(firstpage.list, command) if rewriteComments
      elsif command[/^RegSpeech\:\s*([\s\S]+)$/i]
        regspeech = $~[1].gsub(/^\s+/, "").gsub(/\s+$/, "")
        push_comment(firstpage.list, command) if rewriteComments
      end
    end
    return nil if battles.length <= 0
    # Run trainer check now, except in editor
    trainerChecker.pbTrainerBattleCheck(trtype, trname, battleid)
    # Set the event's charset to one depending on the trainer type if the event
    # doesn't have a charset
    if firstpage.graphic.character_name == "" && GameData::TrainerType.exists?(trtype)
      trainerid = GameData::TrainerType.get(trtype).id
      filename = GameData::TrainerType.charset_filename_brief(trainerid)
      if FileTest.image_exist?("Graphics/Characters/" + filename)
        firstpage.graphic.character_name = sprintf(filename)
      end
    end
    # Create strings that will be used repeatedly
    safetrcombo = sprintf(":%s,\"%s\"", trtype, safequote(trname))   # :YOUNGSTER,"Joey"
    introplay   = sprintf("pbTrainerIntro(:%s)", trtype)
    # Write first page
    push_comment(firstpage.list, endspeeches[0]) if endspeeches[0]   # Just so it isn't lost
    push_script(firstpage.list, introplay)   # pbTrainerIntro
    push_script(firstpage.list, "pbNoticePlayer(get_self)")
    push_text(firstpage.list, battles[0])
    if battles.length > 1   # Has rematches
      push_script(firstpage.list, sprintf("pbTrainerCheck(%s,%d,%d)", safetrcombo, battles.length, battleid))
    end
    push_script(firstpage.list, "setBattleRule(\"double\")") if doublebattle
    push_script(firstpage.list, sprintf("setBattleRule(\"backdrop\",\"%s\")", safequote(backdrop))) if backdrop
    push_script(firstpage.list, sprintf("setBattleRule(\"outcomeVar\",%d)", outcome)) if outcome > 1
    push_script(firstpage.list, "setBattleRule(\"canLose\")") if continue
    if battleid > 0
      battleString = sprintf("TrainerBattle.start(%s,%d)", safetrcombo, battleid)
    else
      battleString = sprintf("TrainerBattle.start(%s)", safetrcombo)
    end
    push_branch(firstpage.list, battleString)
    if battles.length > 1   # Has rematches
      push_script(firstpage.list,
                  sprintf("pbPhoneRegisterBattle(_I(\"%s\"),get_self,%s,%d)",
                          regspeech, safetrcombo, battles.length), 1)
    end
    push_self_switch(firstpage.list, "A", true, 1)
    push_branch_end(firstpage.list, 1)
    push_script(firstpage.list, "pbTrainerEnd", 0)
    push_end(firstpage.list)
    # Copy first page to last page and make changes to its properties
    lastpage = Marshal.load(Marshal.dump(firstpage))
    lastpage.trigger   = 0   # On action
    lastpage.list      = []   # Clear page's commands
    lastpage.condition = firstpage.condition.clone
    lastpage.condition.self_switch_valid = true
    lastpage.condition.self_switch_ch    = "A"
    # Copy last page to rematch page
    rematchpage = Marshal.load(Marshal.dump(lastpage))
    rematchpage.list      = lastpage.list.clone   # Copy the last page's commands
    rematchpage.condition = lastpage.condition.clone
    rematchpage.condition.self_switch_valid = true
    rematchpage.condition.self_switch_ch    = "B"
    # Write rematch and last pages
    (1...battles.length).each do |i|
      # Run trainer check now, except in editor
      trainerChecker.pbTrainerBattleCheck(trtype, trname, battleid + i)
      if i == battles.length - 1
        push_branch(rematchpage.list, sprintf("pbPhoneBattleCount(%s)>=%d", safetrcombo, i))
        push_branch(lastpage.list, sprintf("pbPhoneBattleCount(%s)>%d", safetrcombo, i))
      else
        push_branch(rematchpage.list, sprintf("pbPhoneBattleCount(%s)==%d", safetrcombo, i))
        push_branch(lastpage.list, sprintf("pbPhoneBattleCount(%s)==%d", safetrcombo, i))
      end
      # Rematch page
      push_script(rematchpage.list, introplay, 1)   # pbTrainerIntro
      push_text(rematchpage.list, battles[i], 1)
      push_script(rematchpage.list, "setBattleRule(\"double\")", 1) if doublebattle
      push_script(rematchpage.list, sprintf("setBattleRule(\"backdrop\",%s)", safequote(backdrop)), 1) if backdrop
      push_script(rematchpage.list, sprintf("setBattleRule(\"outcomeVar\",%d)", outcome), 1) if outcome > 1
      push_script(rematchpage.list, "setBattleRule(\"canLose\")", 1) if continue
      battleString = sprintf("TrainerBattle.start(%s,%d)", safetrcombo, battleid + i)
      push_branch(rematchpage.list, battleString, 1)
      push_script(rematchpage.list, sprintf("pbPhoneIncrement(%s,%d)", safetrcombo, battles.length), 2)
      push_self_switch(rematchpage.list, "A", true, 2)
      push_self_switch(rematchpage.list, "B", false, 2)
      push_script(rematchpage.list, "pbTrainerEnd", 2)
      push_branch_end(rematchpage.list, 2)
      push_exit(rematchpage.list, 1)   # Exit Event Processing
      push_branch_end(rematchpage.list, 1)
      # Last page
      if endbattles.length > 0
        ebattle = (endbattles[i]) ? endbattles[i] : endbattles[endbattles.length - 1]
        push_text(lastpage.list, ebattle, 1)
      end
      push_script(lastpage.list,
                  sprintf("pbPhoneRegisterBattle(_I(\"%s\"),get_self,%s,%d)",
                          regspeech, safetrcombo, battles.length), 1)
      push_exit(lastpage.list, 1)   # Exit Event Processing
      push_branch_end(lastpage.list, 1)
    end
    # Finish writing rematch page
    push_end(rematchpage.list)
    # Finish writing last page
    ebattle = (endbattles[0]) ? endbattles[0] : "..."
    push_text(lastpage.list, ebattle)
    if battles.length > 1
      push_script(lastpage.list,
                  sprintf("pbPhoneRegisterBattle(_I(\"%s\"),get_self,%s,%d)",
                          regspeech, safetrcombo, battles.length))
    end
    push_end(lastpage.list)
    # Add pages to the new event
    if battles.length == 1   # Only one battle
      ret.pages = [firstpage, lastpage]
    else   # Has rematches
      ret.pages = [firstpage, rematchpage, lastpage]
    end
    # Copy last page to endIfSwitch page
    endifswitch.each do |endswitch|
      endIfSwitchPage = Marshal.load(Marshal.dump(lastpage))
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
      push_text(endIfSwitchPage.list, ebattle)
      push_end(endIfSwitchPage.list)
      ret.pages.push(endIfSwitchPage)
    end
    # Copy last page to vanishIfSwitch page
    vanishifswitch.each do |vanishswitch|
      vanishIfSwitchPage = Marshal.load(Marshal.dump(lastpage))
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
      push_end(vanishIfSwitchPage.list)
      ret.pages.push(vanishIfSwitchPage)
    end
    return ret
  end

  #=============================================================================
  # Convert event name to item event.
  # Checks if the event's name is "Item:POTION" or "HiddenItem:POTION". If so,
  # rewrites the whole event into one now named "Item"/"HiddenItem" which gives
  # that item when interacted with.
  #=============================================================================
  def convert_to_item_event(event)
    return nil if !event || event.pages.length == 0
    name = event.name
    ret       = RPG::Event.new(event.x, event.y)
    ret.name  = event.name
    ret.id    = event.id
    ret.pages = []
    itemName = ""
    hidden = false
    if name[/^hiddenitem\:\s*(\w+)\s*$/i]
      itemName = $1
      return nil if !GameData::Item.exists?(itemName)
      ret.name = "HiddenItem"
      hidden = true
    elsif name[/^item\:\s*(\w+)\s*$/i]
      itemName = $1
      return nil if !GameData::Item.exists?(itemName)
      ret.name = "Item"
    else
      return nil
    end
    # Event page 1
    page = RPG::Event::Page.new
    page.graphic.character_name = "Object ball" if !hidden
    page.list = []
    push_branch(page.list, sprintf("pbItemBall(:%s)", itemName))
    push_self_switch(page.list, "A", true, 1)
    push_else(page.list, 1)
    push_branch_end(page.list, 1)
    push_end(page.list)
    ret.pages.push(page)
    # Event page 2
    page = RPG::Event::Page.new
    page.condition.self_switch_valid = true
    page.condition.self_switch_ch    = "A"
    ret.pages.push(page)
    return ret
  end

  #=============================================================================
  # Checks whether a given event is likely to be a door. If so, rewrite it to
  # include animating the event as though it was a door opening and closing as the
  # player passes through.
  #=============================================================================
  def update_door_event(event, mapData)
    changed = false
    return false if event.is_a?(RPG::CommonEvent)
    # Check if event has 2+ pages and the last page meets all of these criteria:
    #   - Has a condition of a Switch being ON
    #   - The event has a charset graphic
    #   - There are more than 5 commands in that page, the first of which is a
    #     Conditional Branch
    lastPage = event.pages[event.pages.length - 1]
    if event.pages.length >= 2 &&
       lastPage.condition.switch1_valid &&
       lastPage.graphic.character_name != "" &&
       lastPage.list.length > 5 &&
       lastPage.list[0].code == 111
      # This bit of code is just in case Switch 22 has been renamed/repurposed,
      # which is highly unlikely. It changes the Switch used in the condition to
      # whichever is named 's:tsOff?("A")'.
      if lastPage.condition.switch1_id == 22 &&
         mapData.switchName(lastPage.condition.switch1_id) != 's:tsOff?("A")'
        lastPage.condition.switch1_id = mapData.registerSwitch('s:tsOff?("A")')
        changed = true
      end
      # If the last page's Switch condition uses a Switch named 's:tsOff?("A")',
      # check the penultimate page. If it contains exactly 1 "Transfer Player"
      # command and does NOT contain a "Change Transparent Flag" command, rewrite
      # both the penultimate page and the last page.
      if mapData.switchName(lastPage.condition.switch1_id) == 's:tsOff?("A")'
        list = event.pages[event.pages.length - 2].list
        transferCommand = list.find_all { |cmd| cmd.code == 201 }   # Transfer Player
        if transferCommand.length == 1 && list.none? { |cmd| cmd.code == 208 }   # Change Transparent Flag
          # Rewrite penultimate page
          list.clear
          push_move_route_and_wait(   # Move Route for door opening
            list, 0,
            [PBMoveRoute::PlaySE, RPG::AudioFile.new("Door enter"), PBMoveRoute::Wait, 2,
             PBMoveRoute::TurnLeft, PBMoveRoute::Wait, 2,
             PBMoveRoute::TurnRight, PBMoveRoute::Wait, 2,
             PBMoveRoute::TurnUp, PBMoveRoute::Wait, 2]
          )
          push_move_route_and_wait(   # Move Route for player entering door
            list, -1,
            [PBMoveRoute::ThroughOn, PBMoveRoute::Up, PBMoveRoute::ThroughOff]
          )
          push_event(list, 208, [0])   # Change Transparent Flag (invisible)
          push_script(list, "Followers.follow_into_door")
          push_event(list, 210, [], indent)   # Wait for Move's Completion
          push_move_route_and_wait(   # Move Route for door closing
            list, 0,
            [PBMoveRoute::Wait, 2,
             PBMoveRoute::TurnRight, PBMoveRoute::Wait, 2,
             PBMoveRoute::TurnLeft, PBMoveRoute::Wait, 2,
             PBMoveRoute::TurnDown, PBMoveRoute::Wait, 2]
          )
          push_event(list, 223, [Tone.new(-255, -255, -255), 6])   # Change Screen Color Tone
          push_wait(list, 8)   # Wait
          push_event(list, 208, [1])   # Change Transparent Flag (visible)
          push_event(list, transferCommand[0].code, transferCommand[0].parameters)   # Transfer Player
          push_event(list, 223, [Tone.new(0, 0, 0), 6])   # Change Screen Color Tone
          push_end(list)
          # Rewrite last page
          list = lastPage.list
          list.clear
          push_branch(list, "get_self.onEvent?")   # Conditional Branch
          push_event(list, 208, [0], 1)   # Change Transparent Flag (invisible)
          push_script(list, "Followers.hide_followers", 1)
          push_move_route_and_wait(   # Move Route for setting door to open
            list, 0,
            [PBMoveRoute::TurnLeft, PBMoveRoute::Wait, 6],
            1
          )
          push_event(list, 208, [1], 1)   # Change Transparent Flag (visible)
          push_move_route_and_wait(list, -1, [PBMoveRoute::Down], 1)   # Move Route for player exiting door
          push_script(list, "Followers.put_followers_on_player", 1)
          push_move_route_and_wait(   # Move Route for door closing
            list, 0,
            [PBMoveRoute::TurnUp, PBMoveRoute::Wait, 2,
             PBMoveRoute::TurnRight, PBMoveRoute::Wait, 2,
             PBMoveRoute::TurnDown, PBMoveRoute::Wait, 2],
            1
          )
          push_branch_end(list, 1)
          push_script(list, "setTempSwitchOn(\"A\")")
          push_end(list)
          changed = true
        end
      end
    end
    return changed
  end

  #=============================================================================
  # Fix up standard code snippets
  #=============================================================================
  def event_is_empty?(e)
    return true if !e
    return false if e.is_a?(RPG::CommonEvent)
    return e.pages.length == 0
  end

  # Checks if the event has exactly 1 page, said page has no graphic, it has
  # less than 12 commands and at least one is a Transfer Player, and the tiles
  # to the left/right/upper left/upper right are not passable but the event's
  # tile is. Causes a second page to be added to the event which is the "is
  # player on me?" check that occurs when the map is entered.
  def likely_passage?(thisEvent, mapID, mapData)
    return false if !thisEvent || thisEvent.pages.length == 0
    return false if thisEvent.pages.length != 1
    if thisEvent.pages[0].graphic.character_name == "" &&
       thisEvent.pages[0].list.length <= 12 &&
       thisEvent.pages[0].list.any? { |cmd| cmd.code == 201 } &&   # Transfer Player
#       mapData.isPassable?(mapID,thisEvent.x,thisEvent.y+1) &&
       mapData.isPassable?(mapID, thisEvent.x, thisEvent.y) &&
       !mapData.isPassable?(mapID, thisEvent.x - 1, thisEvent.y) &&
       !mapData.isPassable?(mapID, thisEvent.x + 1, thisEvent.y) &&
       !mapData.isPassable?(mapID, thisEvent.x - 1, thisEvent.y - 1) &&
       !mapData.isPassable?(mapID, thisEvent.x + 1, thisEvent.y - 1)
      return true
    end
    return false
  end

  def fix_event_name(event)
    return false if !event
    case event.name.downcase
    when "tree"
      event.name = "CutTree"
    when "rock"
      event.name = "SmashRock"
    when "boulder"
      event.name = "StrengthBoulder"
    else
      return false
    end
    return true
  end

  def replace_scripts(script)
    ret = false
    SCRIPT_REPLACEMENTS.each { |pair| ret = true if script.gsub!(pair[0], pair[1]) }
    ret = true if script.gsub!(/\$game_variables\[(\d+)\](?!\s*(?:\=|\!|<|>))/) { |m| "pbGet(" + $~[1] + ")" }
    ret = true if script.gsub!(/\$player\.party\[\s*pbGet\((\d+)\)\s*\]/) { |m| "pbGetPokemon(" + $~[1] + ")" }
    return ret
  end

  def fix_event_scripts(event)
    return false if event_is_empty?(event)
    ret = false
    pbEachPage(event) do |page|
      page.list.each do |cmd|
        params = cmd.parameters
        case cmd.code
        when 355, 655   # Script (first line, continuation line)
          ret = true if params[0].is_a?(String) && replace_scripts(params[0])
        when 111   # Conditional Branch
          ret = true if params[0] == 12 && replace_scripts(params[1])
        end
      end
    end
    return ret
  end

  # Splits the given code string into an array of parameters (all strings),
  # using "," as the delimiter. It will not split in the middle of a string
  # parameter. Used to extract parameters from a script call in an event.
  def split_string_with_quotes(str)
    ret = []
    new_str = ""
    in_msg = false
    str.scan(/./) do |s|
      if s == "," && !in_msg
        ret.push(new_str.strip)
        new_str = ""
      else
        in_msg = !in_msg if s == "\""
        new_str += s
      end
    end
    new_str.strip!
    ret.push(new_str) if !new_str.empty?
    return ret
  end

  def replace_old_battle_scripts(event, list, index)
    changed = false
    script = list[index].parameters[1]
    if script[/^\s*pbWildBattle\((.+)\)\s*$/]
      battle_params = split_string_with_quotes($1)   # Split on commas
      list[index].parameters[1] = sprintf("WildBattle.start(#{battle_params[0]}, #{battle_params[1]})")
      old_indent = list[index].indent
      new_events = []
      if battle_params[3] && battle_params[3][/false/]
        push_script(new_events, "setBattleRule(\"cannotRun\")", old_indent)
      end
      if battle_params[4] && battle_params[4][/true/]
        push_script(new_events, "setBattleRule(\"canLose\")", old_indent)
      end
      if battle_params[2] && battle_params[2] != "1"
        push_script(new_events, "setBattleRule(\"outcome\", #{battle_params[2]})", old_indent)
      end
      list[index, 0] = new_events if new_events.length > 0
      changed = true
    elsif script[/^\s*pbDoubleWildBattle\((.+)\)\s*$/]
      battle_params = split_string_with_quotes($1)   # Split on commas
      pkmn1 = "#{battle_params[0]}, #{battle_params[1]}"
      pkmn2 = "#{battle_params[2]}, #{battle_params[3]}"
      list[index].parameters[1] = sprintf("WildBattle.start(#{pkmn1}, #{pkmn2})")
      old_indent = list[index].indent
      new_events = []
      if battle_params[3] && battle_params[5][/false/]
        push_script(new_events, "setBattleRule(\"cannotRun\")", old_indent)
      end
      if battle_params[4] && battle_params[6][/true/]
        push_script(new_events, "setBattleRule(\"canLose\")", old_indent)
      end
      if battle_params[2] && battle_params[4] != "1"
        push_script(new_events, "setBattleRule(\"outcome\", #{battle_params[4]})", old_indent)
      end
      list[index, 0] = new_events if new_events.length > 0
      changed = true
    elsif script[/^\s*pbTripleWildBattle\((.+)\)\s*$/]
      battle_params = split_string_with_quotes($1)   # Split on commas
      pkmn1 = "#{battle_params[0]}, #{battle_params[1]}"
      pkmn2 = "#{battle_params[2]}, #{battle_params[3]}"
      pkmn3 = "#{battle_params[4]}, #{battle_params[5]}"
      list[index].parameters[1] = sprintf("WildBattle.start(#{pkmn1}, #{pkmn2}, #{pkmn3})")
      old_indent = list[index].indent
      new_events = []
      if battle_params[3] && battle_params[7][/false/]
        push_script(new_events, "setBattleRule(\"cannotRun\")", old_indent)
      end
      if battle_params[4] && battle_params[8][/true/]
        push_script(new_events, "setBattleRule(\"canLose\")", old_indent)
      end
      if battle_params[2] && battle_params[6] != "1"
        push_script(new_events, "setBattleRule(\"outcome\", #{battle_params[6]})", old_indent)
      end
      list[index, 0] = new_events if new_events.length > 0
      changed = true
    elsif script[/^\s*pbTrainerBattle\((.+)\)\s*$/]
      echoln ""
      echoln $1
      battle_params = split_string_with_quotes($1)   # Split on commas
      echoln battle_params
      trainer1 = "#{battle_params[0]}, #{battle_params[1]}"
      trainer1 += ", #{battle_params[4]}" if battle_params[4] && battle_params[4] != "nil"
      list[index].parameters[1] = "TrainerBattle.start(#{trainer1})"
      old_indent = list[index].indent
      new_events = []
      if battle_params[2] && !battle_params[2].empty? && battle_params[2] != "nil"
        echoln battle_params[2]
        speech = battle_params[2].gsub(/^\s*_I\(\s*"\s*/, "").gsub(/\"\s*\)\s*$/, "")
        echoln speech
        push_comment(new_events, "EndSpeech: #{speech.strip}", old_indent)
      end
      if battle_params[3] && battle_params[3][/true/]
        push_script(new_events, "setBattleRule(\"double\")", old_indent)
      end
      if battle_params[5] && battle_params[5][/true/]
        push_script(new_events, "setBattleRule(\"canLose\")", old_indent)
      end
      if battle_params[6] && battle_params[6] != "1"
        push_script(new_events, "setBattleRule(\"outcome\", #{battle_params[6]})", old_indent)
      end
      list[index, 0] = new_events if new_events.length > 0
      changed = true
    elsif script[/^\s*pbDoubleTrainerBattle\((.+)\)\s*$/]
      battle_params = split_string_with_quotes($1)   # Split on commas
      trainer1 = "#{battle_params[0]}, #{battle_params[1]}"
      trainer1 += ", #{battle_params[2]}" if battle_params[2] && battle_params[2] != "nil"
      trainer2 = "#{battle_params[4]}, #{battle_params[5]}"
      trainer2 += ", #{battle_params[6]}" if battle_params[6] && battle_params[6] != "nil"
      list[index].parameters[1] = "TrainerBattle.start(#{trainer1}, #{trainer2})"
      old_indent = list[index].indent
      new_events = []
      if battle_params[3] && !battle_params[3].empty? && battle_params[3] != "nil"
        speech = battle_params[3].gsub(/^\s*_I\(\s*"\s*/, "").gsub(/\"\s*\)\s*$/, "")
        push_comment(new_events, "EndSpeech1: #{speech.strip}", old_indent)
      end
      if battle_params[7] && !battle_params[7].empty? && battle_params[7] != "nil"
        speech = battle_params[7].gsub(/^\s*_I\(\s*"\s*/, "").gsub(/\"\s*\)\s*$/, "")
        push_comment(new_events, "EndSpeech2: #{speech.strip}", old_indent)
      end
      if battle_params[8] && battle_params[8][/true/]
        push_script(new_events, "setBattleRule(\"canLose\")", old_indent)
      end
      if battle_params[9] && battle_params[9] != "1"
        push_script(new_events, "setBattleRule(\"outcome\", #{battle_params[9]})", old_indent)
      end
      list[index, 0] = new_events if new_events.length > 0
      changed = true
    elsif script[/^\s*pbTripleTrainerBattle\((.+)\)\s*$/]
      battle_params = split_string_with_quotes($1)   # Split on commas
      trainer1 = "#{battle_params[0]}, #{battle_params[1]}"
      trainer1 += ", #{battle_params[2]}" if battle_params[2] && battle_params[2] != "nil"
      trainer2 = "#{battle_params[4]}, #{battle_params[5]}"
      trainer2 += ", #{battle_params[6]}" if battle_params[6] && battle_params[6] != "nil"
      trainer3 = "#{battle_params[8]}, #{battle_params[9]}"
      trainer3 += ", #{battle_params[10]}" if battle_params[10] && battle_params[10] != "nil"
      list[index].parameters[1] = "TrainerBattle.start(#{trainer1}, #{trainer2}, #{trainer3})"
      old_indent = list[index].indent
      new_events = []
      if battle_params[3] && !battle_params[3].empty? && battle_params[3] != "nil"
        speech = battle_params[3].gsub(/^\s*_I\(\s*"\s*/, "").gsub(/\"\s*\)\s*$/, "")
        push_comment(new_events, "EndSpeech1: #{speech.strip}", old_indent)
      end
      if battle_params[7] && !battle_params[7].empty? && battle_params[7] != "nil"
        speech = battle_params[7].gsub(/^\s*_I\(\s*"\s*/, "").gsub(/\"\s*\)\s*$/, "")
        push_comment(new_events, "EndSpeech2: #{speech.strip}", old_indent)
      end
      if battle_params[7] && !battle_params[7].empty? && battle_params[11] != "nil"
        speech = battle_params[11].gsub(/^\s*_I\(\s*"\s*/, "").gsub(/\"\s*\)\s*$/, "")
        push_comment(new_events, "EndSpeech3: #{speech.strip}", old_indent)
      end
      if battle_params[12] && battle_params[12][/true/]
        push_script(new_events, "setBattleRule(\"canLose\")", old_indent)
      end
      if battle_params[13] && battle_params[13] != "1"
        push_script(new_events, "setBattleRule(\"outcome\", #{battle_params[13]})", old_indent)
      end
      list[index, 0] = new_events if new_events.length > 0
      changed = true
    end
    return changed
  end

  def fix_event_use(event, _mapID, mapData)
    return nil if event_is_empty?(event)
    changed = false
    trainerMoneyRE = /^\s*\$player\.money\s*(<|<=|>|>=)\s*(\d+)\s*$/
    itemBallRE     = /^\s*(Kernel\.)?pbItemBall/
    # Rewrite event if it looks like a door
    changed = true if update_door_event(event, mapData)
    # Check through each page of the event in turn
    pbEachPage(event) do |page|
      i = 0
      list = page.list
      while i < list.length
        params = list[i].parameters
        case list[i].code
#        when 655   # Script (continuation line)
        when 355   # Script (first line)
          lastScript = i
          if !params[0].is_a?(String)
            i += 1
            next
          end
          # Check if the script is an old way of healing the entire party, and if
          # so, replace it with a better version that uses event commands
          if params[0][0, 1] != "f" && params[0][0, 1] != "p" && params[0][0, 1] != "K"
            i += 1
            next
          end
          # Script begins with "f" (for...), "p" (pbMethod) or "K" (Kernel.)
          script = " " + params[0]
          j = i + 1
          while j < list.length
            break if list[j].code != 655   # Script (continuation line)
            script += list[j].parameters[0]
            lastScript = j
            j += 1
          end
          script.gsub!(/\s+/, "")
          # Using old method of recovering
          case script
          when "foriin$player.partyi.healend"
            (i..lastScript).each do |j|
              list.delete_at(i)
            end
            list.insert(i,
                        RPG::EventCommand.new(314, list[i].indent, [0]))   # Recover All
            changed = true
          when "pbFadeOutIn(99999){foriin$player.partyi.healend}"
            oldIndent = list[i].indent
            (i..lastScript).each do |j|
              list.delete_at(i)
            end
            list.insert(
              i,
              RPG::EventCommand.new(223, oldIndent, [Tone.new(-255, -255, -255), 6]),   # Fade to black
              RPG::EventCommand.new(106, oldIndent, [6]),                               # Wait
              RPG::EventCommand.new(314, oldIndent, [0]),                               # Recover All
              RPG::EventCommand.new(223, oldIndent, [Tone.new(0, 0, 0), 6]),            # Fade to normal
              RPG::EventCommand.new(106, oldIndent, [6])                                # Wait
            )
            changed = true
          end
        when 108   # Comment (first line)
          # Replace a "SellItem:POTION,200" comment with event commands that do so
          if params[0][/SellItem\s*\(\s*(\w+)\s*\,\s*(\d+)\s*\)/]
            itemname = $1
            cost     = $2.to_i
            if GameData::Item.exists?(itemname)
              oldIndent = list[i].indent
              list.delete_at(i)
              newEvents = []
              if cost == 0
                push_branch(newEvents, "$bag.can_add?(:#{itemname})", oldIndent)
                push_text(newEvents, _INTL("Here you go!"), oldIndent + 1)
                push_script(newEvents, "pbReceiveItem(:#{itemname})", oldIndent + 1)
                push_else(newEvents, oldIndent + 1)
                push_text(newEvents, _INTL("You have no room left in the Bag."), oldIndent + 1)
              else
                push_event(newEvents, 111, [7, cost, 0], oldIndent)
                push_branch(newEvents, "$bag.can_add?(:#{itemname})", oldIndent + 1)
                push_event(newEvents, 125, [1, 0, cost], oldIndent + 2)
                push_text(newEvents, _INTL("\\GHere you go!"), oldIndent + 2)
                push_script(newEvents, "pbReceiveItem(:#{itemname})", oldIndent + 2)
                push_else(newEvents, oldIndent + 2)
                push_text(newEvents, _INTL("\\GYou have no room left in the Bag."), oldIndent + 2)
                push_branch_end(newEvents, oldIndent + 2)
                push_else(newEvents, oldIndent + 1)
                push_text(newEvents, _INTL("\\GYou don't have enough money."), oldIndent + 1)
              end
              push_branch_end(newEvents, oldIndent + 1)
              list[i, 0] = newEvents   # insert 'newEvents' at index 'i'
              changed = true
            end
          end
        when 115   # Exit Event Processing
          if i == list.length - 2
            # Superfluous exit command, delete it
            list.delete_at(i)
            changed = true
          end
        when 201   # Transfer Player
          if list.length <= 8
=begin
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
              if likely_passage?(e,params[1],mapData)   # Checks the first page
                add_passage_list(e,mapData)
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
                  arr.push(list[i])
                  list.delete_at(i)
                  while i<list.length
                    break if !list[i] || list[i].code!=509   # Set Move Route (continuation line)
                    arr.push(list[i])
                    list.delete_at(i)
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
                    deleteMoveRouteAt.call(list,i+1)
                    params[4] = 2
                    changed = true
                  elsif route.list[0].code==17   # Player Turn Left
                    deleteMoveRouteAt.call(list,i+1)
                    params[4] = 4
                    changed = true
                  elsif route.list[0].code==18   # Player Turn Right
                    deleteMoveRouteAt.call(list,i+1)
                    params[4] = 6
                    changed = true
                  elsif route.list[0].code==19   # Player Turn Up
                    deleteMoveRouteAt.call(list,i+1)
                    params[4] = 8
                    changed = true
                  elsif (route.list[0].code==1 || route.list[0].code==2 ||   # Player Move (4-dir)
                     route.list[0].code==3 || route.list[0].code==4) && list.length==4
                    params[4] = [0,2,4,6,8][route.list[0].code]
                    deletedRoute = deleteMoveRouteAt.call(list,i+1)
                    changed = true
                  end
                end
              # If an event command before this one is a Move Route that just
              # turns the player, delete it and make this Transfer Player command
              # set the player's direction instead.
              # (I don't know if it makes sense to do this, as there could be a
              # lot of commands between then and this Transfer Player which this
              # code can't recognise and deal with, so I've quoted this code out.)
              elsif params[4]==0 && i>3   # Retain direction
#                for j in 0...i
#                  if list[j].code==209 && list[j].parameters[0]==-1   # Set Move Route
#                    route = list[j].parameters[1]
#                    if route && route.list.length<=2
#                      oldlistlength = list.length
#                      # Delete superfluous move route command if necessary
#                      if route.list[0].code==16      # Player Turn Down
#                        deleteMoveRouteAt.call(list,j)
#                        params[4] = 2
#                        changed = true
#                        i -= (oldlistlength-list.length)
#                      elsif route.list[0].code==17   # Player Turn Left
#                        deleteMoveRouteAt.call(list,j)
#                        params[4] = 4
#                        changed = true
#                        i -= (oldlistlength-list.length)
#                      elsif route.list[0].code==18   # Player Turn Right
#                        deleteMoveRouteAt.call(list,j)
#                        params[4] = 6
#                        changed = true
#                        i -= (oldlistlength-list.length)
#                      elsif route.list[0].code==19   # Player Turn Up
#                        deleteMoveRouteAt.call(list,j)
#                        params[4] = 8
#                        changed = true
#                        i -= (oldlistlength-list.length)
#                      end
#                    end
#                  end
#                end
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
                    deleteMoveRouteAt.call(list,i+2)
                    params[4] = 2
                    changed = true
                  elsif route.list[0].code==17   # Player Turn Left
                    deleteMoveRouteAt.call(list,i+2)
                    params[4] = 4
                    changed = true
                  elsif route.list[0].code==18   # Player Turn Right
                    deleteMoveRouteAt.call(list,i+2)
                    params[4] = 6
                    changed = true
                  elsif route.list[0].code==19   # Player Turn Up
                    deleteMoveRouteAt.call(list,i+2)
                    params[4] = 8
                    changed = true
                  end
                end
              end
            end
=end
            # If this is the only event command, convert to a full event
            if list.length == 2 || (list.length == 3 && (list[0].code == 250 || list[1].code == 250))   # Play SE
              params[5] = 1   # No fade
              fullTransfer = list[i]
              indent = list[i].indent
              (list.length - 1).times { list.delete_at(0) }
              list.insert(
                0,
                RPG::EventCommand.new(250, indent, [RPG::AudioFile.new("Exit Door", 80, 100)]),   # Play SE
                RPG::EventCommand.new(223, indent, [Tone.new(-255, -255, -255), 6]),              # Fade to black
                RPG::EventCommand.new(106, indent, [8]),                                          # Wait
                fullTransfer,                                                                     # Transfer event
                RPG::EventCommand.new(223, indent, [Tone.new(0, 0, 0), 6])                        # Fade to normal
              )
              changed = true
            end
#            if deletedRoute
#              insertMoveRouteAt.call(list,list.length-1,deletedRoute)
#              changed = true
#            end
          end
        when 101   # Show Text
          # Capitalise/decapitalise various text formatting codes
          if list[i].parameters[0][0, 1] == "\\"
            newx = list[i].parameters[0].clone
            newx.sub!(/^\\[Bb]\s+/, "\\b")
            newx.sub!(/^\\[Rr]\s+/, "\\r")
            newx.sub!(/^\\[Pp][Gg]\s+/, "\\pg")
            newx.sub!(/^\\[Pp][Oo][Gg]\s+/, "\\pog")
            newx.sub!(/^\\[Gg]\s+/, "\\G")
            newx.sub!(/^\\[Cc][Nn]\s+/, "\\CN")
            if list[i].parameters[0] != newx
              list[i].parameters[0] = newx
              changed = true
            end
          end
          # Split Show Text commands with 5+ lines into multiple Show Text
          # commands each with a maximum of 4 lines
          lines = 1
          j = i + 1
          while j < list.length
            break if list[j].code != 401   # Show Text (continuation line)
            if lines % 4 == 0
              list[j].code = 101   # Show Text
              changed = true
            end
            lines += 1
            j += 1
          end
          # If this Show Text command has 2+ lines of text but not much actual
          # text in the first line, merge the second line into it
          if lines >= 2 && list[i].parameters[0].length > 0 && list[i].parameters[0].length <= 20 &&
             !list[i].parameters[0][/\\n/]
            # Very short line
            list[i].parameters[0] += "\\n" + list[i + 1].parameters[0]
            list.delete_at(i + 1)
            i -= 1   # revisit this text command
            changed = true
          # Check whether this Show Text command has 3+ lines and the next command
          # is also a Show Text
          elsif lines >= 3 && list[i + lines] && list[i + lines].code == 101   # Show Text
            # Check whether a sentence is being broken midway between two Text
            # commands (i.e. the first Show Text doesn't end in certain punctuation)
            lastLine = list[i + lines - 1].parameters[0].sub(/\s+$/, "")
            if lastLine.length > 0 && !lastLine[/[\\<]/] && lastLine[/[^\.,\!\?\;\-\"]$/]
              message = list[i].parameters[0]
              j = i + 1
              while j < list.length
                break if list[j].code != 401   # Show Text (continuation line)
                message += "\n" + list[j].parameters[0]
                j += 1
              end
              # Find a punctuation mark to split at
              punct = [message.rindex(". "), message.rindex(".\n"),
                       message.rindex("!"), message.rindex("?"), -1].compact.max
              if punct == -1
                punct = [message.rindex(", "), message.rindex(",\n"), -1].compact.max
              end
              if punct != -1
                # Delete old message
                indent = list[i].indent
                newMessage  = message[0, punct + 1].split("\n")
                nextMessage = message[punct + 1, message.length].sub(/^\s+/, "").split("\n")
                list[i + lines].code = 401
                lines.times { list.delete_at(i) }
                j = nextMessage.length - 1
                while j >= 0
                  list.insert(i, RPG::EventCommand.new((j == 0) ? 101 : 401, indent, [nextMessage[j]]))
                  j -= 1
                end
                j = newMessage.length - 1
                while j >= 0
                  list.insert(i, RPG::EventCommand.new((j == 0) ? 101 : 401, indent, [newMessage[j]]))
                  j -= 1
                end
                changed = true
                i += 1
                next
              end
            end
          end
        when 111   # Conditional Branch
          if list[i].parameters[0] == 12   # script
            script = list[i].parameters[1]
            changed = true if replace_old_battle_scripts(event, list, i)
            if script[trainerMoneyRE]   # Compares $player.money with a value
              # Checking money directly
              operator = $1
              amount   = $2.to_i
              case operator
              when "<"
                params[0] = 7   # gold
                params[2] = 1
                params[1] = amount - 1
                changed = true
              when "<="
                params[0] = 7   # gold
                params[2] = 1
                params[1] = amount
                changed = true
              when ">"
                params[0] = 7   # gold
                params[2] = 0
                params[1] = amount + 1
                changed = true
              when ">="
                params[0] = 7   # gold
                params[2] = 0
                params[1] = amount
                changed = true
              end
            elsif script[itemBallRE] && i > 0   # Contains pbItemBall after another command
              # Using pbItemBall on non-item events, change it
              list[i].parameters[1] = script.sub(/pbItemBall/, "pbReceiveItem")
              changed = true
            elsif script[/^\s*(TrainerBattle.start)/]
              # Check if trainer battle conditional branch is empty
              j = i + 1
              isempty = true
              elseIndex = -1
              # Check if page is empty
              while j < page.list.length
                if list[j].indent <= list[i].indent
                  if list[j].code == 411   # Else
                    elseIndex = j
                  else
                    break   # Reached end of Conditional Branch
                  end
                end
                if list[j].code != 0 && list[j].code != 411   # Else
                  isempty = false
                  break
                end
                j += 1
              end
              if isempty
                if elseIndex >= 0
                  list.insert(
                    elseIndex + 1,
                    RPG::EventCommand.new(115, list[i].indent + 1, [])   # Exit Event Processing
                  )
                else
                  list.insert(
                    i + 1,
                    RPG::EventCommand.new(0, list[i].indent + 1, []),    # Empty Event
                    RPG::EventCommand.new(411, list[i].indent, []),      # Else
                    RPG::EventCommand.new(115, list[i].indent + 1, [])   # Exit Event Processing
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

  #=============================================================================
  # Convert events used as counters into proper counters.
  #=============================================================================
  # Checks if the event has just 1 page, which has no conditions and no commands
  # and whose movement type is "Fixed".
  def plain_event?(event)
    return false unless event
    return false if event.pages.length > 1
    return false if event.pages[0].move_type != 0
    return false if event.pages[0].condition.switch1_valid ||
                    event.pages[0].condition.switch2_valid ||
                    event.pages[0].condition.variable_valid ||
                    event.pages[0].condition.self_switch_valid
    return true if event.pages[0].list.length <= 1
    return false
  end

  # Checks if the event has just 1 page, which has no conditions and whose
  # movement type is "Fixed". Then checks if there are no commands, or it looks
  # like a simple Mart or a Poké Center nurse event.
  def plain_event_or_mart?(event)
    return false unless event
    return false if event.pages.length > 1
    return false if event.pages[0].move_type != 0
    return false if event.pages[0].condition.switch1_valid ||
                    event.pages[0].condition.switch2_valid ||
                    event.pages[0].condition.variable_valid ||
                    event.pages[0].condition.self_switch_valid
    # No commands in the event
    return true if event.pages[0].list.length <= 1
    # pbPokemonMart events
    return true if event.pages[0].list.length <= 12 &&
                   event.pages[0].graphic.character_name != "" &&   # Has charset
                   event.pages[0].list[0].code == 355 &&   # First line is Script
                   event.pages[0].list[0].parameters[0][/^pbPokemonMart/]
    # pbSetPokemonCenter events
    return true if event.pages[0].list.length > 8 &&
                   event.pages[0].graphic.character_name != "" &&   # Has charset
                   event.pages[0].list[0].code == 355 &&   # First line is Script
                   event.pages[0].list[0].parameters[0][/^pbSetPokemonCenter/]
    return false
  end

  # Given two events that are next to each other, decides whether otherEvent is
  # likely to be a "counter event", i.e. is placed on a tile with the Counter
  # flag, or is on a non-passable tile between two passable tiles (e.g. a desk)
  # where one of those two tiles is occupied by thisEvent.
  def likely_counter?(thisEvent, otherEvent, mapID, mapData)
    # Check whether otherEvent is on a counter tile
    return true if mapData.isCounterTile?(mapID, otherEvent.x, otherEvent.y)
    # Check whether otherEvent is between an event with a graphic (e.g. an NPC)
    # and a spot where the player can be
    yonderX = otherEvent.x + (otherEvent.x - thisEvent.x)
    yonderY = otherEvent.y + (otherEvent.y - thisEvent.y)
    return thisEvent.pages[0].graphic.character_name != "" &&    # Has charset
           otherEvent.pages[0].graphic.character_name == "" &&   # Has no charset
           otherEvent.pages[0].trigger == 0 &&                   # Action trigger
           mapData.isPassable?(mapID, thisEvent.x, thisEvent.y) &&
           !mapData.isPassable?(mapID, otherEvent.x, otherEvent.y) &&
           mapData.isPassable?(mapID, yonderX, yonderY)
  end

  # Checks all events in the given map to see if any look like they've been
  # placed on a desk with an NPC behind it, where the event on the desk is the
  # actual interaction with the NPC. In other words, it's not making proper use
  # of the counter flag (which lets the player interact with an event on the
  # other side of counter tiles).
  # Any events found to be like this have their contents merged into the NPC
  # event and the counter event itself is deleted. The tile below the counter
  # event gets its counter flag set (if it isn't already).
  def check_counters(map, mapID, mapData)
    toDelete = []
    changed = false
    map.events.each_key do |key|
      event = map.events[key]
      next if !plain_event_or_mart?(event)
      # Found an event that is empty or looks like a simple Mart or a Poké
      # Center nurse. Check adjacent events to see if they are "counter events".
      neighbors = []
      neighbors.push(mapData.getEventFromXY(mapID, event.x, event.y - 1))
      neighbors.push(mapData.getEventFromXY(mapID, event.x, event.y + 1))
      neighbors.push(mapData.getEventFromXY(mapID, event.x - 1, event.y))
      neighbors.push(mapData.getEventFromXY(mapID, event.x + 1, event.y))
      neighbors.compact!
      neighbors.each do |otherEvent|
        next if plain_event?(otherEvent)   # Blank/cosmetic-only event
        next if !likely_counter?(event, otherEvent, mapID, mapData)
        # Found an adjacent event that looks like it's supposed to be a counter.
        # Set the counter flag of the tile beneath the counter event, copy the
        # counter event's pages to the NPC event, and delete the counter event.
        mapData.setCounterTile(mapID, otherEvent.x, otherEvent.y)
        savedPage = event.pages[0]
        event.pages = otherEvent.pages
        apply_pages(savedPage, event.pages)   # Apply NPC's visuals to new event pages
        toDelete.push(otherEvent.id)
        changed = true
      end
    end
    toDelete.each { |key| map.events.delete(key) }
    return changed
  end

  #=============================================================================
  # Main compiler method for events
  #=============================================================================
  def compile_trainer_events(_mustcompile)
    mapData = MapData.new
    t = Time.now.to_i
    Graphics.update
    trainerChecker = TrainerChecker.new
    change_record = []
    Console.echo_li _INTL("Processing {1} maps...", mapData.mapinfos.keys.length)
    idx = 0
    mapData.mapinfos.keys.sort.each do |id|
      echo "." if idx % 20 == 0
      idx += 1
      Graphics.update if idx % 250 == 0
      changed = false
      map = mapData.getMap(id)
      next if !map || !mapData.mapinfos[id]
      map.events.each_key do |key|
        if Time.now.to_i - t >= 5
          Graphics.update
          t = Time.now.to_i
        end
        newevent = convert_to_trainer_event(map.events[key], trainerChecker)
        if newevent
          map.events[key] = newevent
          changed = true
        end
        newevent = convert_to_item_event(map.events[key])
        if newevent
          map.events[key] = newevent
          changed = true
        end
        changed = true if fix_event_name(map.events[key])
        changed = true if fix_event_scripts(map.events[key])
        newevent = fix_event_use(map.events[key], id, mapData)
        if newevent
          map.events[key] = newevent
          changed = true
        end
      end
      if Time.now.to_i - t >= 5
        Graphics.update
        t = Time.now.to_i
      end
      changed = true if check_counters(map, id, mapData)
      if changed
        mapData.saveMap(id)
        mapData.saveTilesets
        change_record.push(_INTL("Map {1}: '{2}' was modified and saved.", id, mapData.mapinfos[id].name))
      end
    end
    Console.echo_done(true)
    change_record.each { |msg| Console.echo_warn msg }
    changed = false
    Graphics.update
    commonEvents = load_data("Data/CommonEvents.rxdata")
    Console.echo_li _INTL("Processing common events...")
    commonEvents.length.times do |key|
      newevent = fix_event_use(commonEvents[key], 0, mapData)
      if newevent
        commonEvents[key] = newevent
        changed = true
      end
    end
    save_data(commonEvents, "Data/CommonEvents.rxdata") if changed
    Console.echo_done(true)
    if change_record.length > 0 || changed
      Console.echo_warn _INTL("RMXP data was altered. Close RMXP now to ensure changes are applied.")
    end
  end
end
