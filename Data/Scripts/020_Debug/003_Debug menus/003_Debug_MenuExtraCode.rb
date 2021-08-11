#===============================================================================
#
#===============================================================================
def pbDefaultMap
  return $game_map.map_id if $game_map
  return $data_system.edit_map_id if $data_system
  return 0
end

def pbWarpToMap
  mapid = pbListScreen(_INTL("WARP TO MAP"),MapLister.new(pbDefaultMap))
  if mapid>0
    map = Game_Map.new
    map.setup(mapid)
    success = false
    x = 0
    y = 0
    100.times do
      x = rand(map.width)
      y = rand(map.height)
      next if !map.passableStrict?(x,y,0,$game_player)
      blocked = false
      for event in map.events.values
        if event.at_coordinate?(x, y) && !event.through
          blocked = true if event.character_name != ""
        end
      end
      next if blocked
      success = true
      break
    end
    if !success
      x = rand(map.width)
      y = rand(map.height)
    end
    return [mapid,x,y]
  end
  return nil
end



#===============================================================================
# Debug Variables screen
#===============================================================================
class SpriteWindow_DebugVariables < Window_DrawableCommand
  attr_reader :mode

  def initialize(viewport)
    super(0,0,Graphics.width,Graphics.height,viewport)
  end

  def itemCount
    return (@mode==0) ? $data_system.switches.size-1 : $data_system.variables.size-1
  end

  def mode=(mode)
    @mode = mode
    refresh
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
    end
    pbDrawShadowText(self.contents,x,y,[width,w].max,h,t,base,Color.new(26*8,26*8,25*8))
  end

  def drawItem(index,_count,rect)
    pbSetNarrowFont(self.contents)
    colors = 0; codeswitch = false
    if @mode==0
      name = $data_system.switches[index+1]
      codeswitch = (name[/^s\:/])
      val = (codeswitch) ? (eval($~.post_match) rescue nil) : $game_switches[index+1]
      if val.nil?
        status = "[-]"
        colors = 0
        codeswitch = true
      elsif val   # true
        status = "[ON]"
        colors = 2
      else   # false
        status = "[OFF]"
        colors = 1
      end
    else
      name = $data_system.variables[index+1]
      status = $game_variables[index+1].to_s
      status = "\"__\"" if nil_or_empty?(status)
    end
    name = '' if name==nil
    id_text = sprintf("%04d:",index+1)
    rect = drawCursor(index,rect)
    totalWidth = rect.width
    idWidth     = totalWidth*15/100
    nameWidth   = totalWidth*65/100
    statusWidth = totalWidth*20/100
    self.shadowtext(rect.x,rect.y,idWidth,rect.height,id_text)
    self.shadowtext(rect.x+idWidth,rect.y,nameWidth,rect.height,name,0,(codeswitch) ? 1 : 0)
    self.shadowtext(rect.x+idWidth+nameWidth,rect.y,statusWidth,rect.height,status,1,colors)
  end
end



def pbDebugSetVariable(id,diff)
  $game_variables[id] = 0 if $game_variables[id]==nil
  if $game_variables[id].is_a?(Numeric)
    pbPlayCursorSE
    $game_variables[id] = [$game_variables[id]+diff,99999999].min
    $game_variables[id] = [$game_variables[id],-99999999].max
    $game_map.need_refresh = true
  end
end

def pbDebugVariableScreen(id)
  if $game_variables[id].is_a?(Numeric)
    value = $game_variables[id]
    params = ChooseNumberParams.new
    params.setDefaultValue(value)
    params.setMaxDigits(8)
    params.setNegativesAllowed(true)
    value = pbMessageChooseNumber(_INTL("Set variable {1}.",id),params)
    $game_variables[id] = [value,99999999].min
    $game_variables[id] = [$game_variables[id],-99999999].max
    $game_map.need_refresh = true
  elsif $game_variables[id].is_a?(String)
    value = pbMessageFreeText(_INTL("Set variable {1}.",id),
       $game_variables[id],false,250,Graphics.width)
    $game_variables[id] = value
    $game_map.need_refresh = true
  end
end

def pbDebugVariables(mode)
  viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z = 99999
  sprites = {}
  sprites["right_window"] = SpriteWindow_DebugVariables.new(viewport)
  right_window = sprites["right_window"]
  right_window.mode     = mode
  right_window.active   = true
  loop do
    Graphics.update
    Input.update
    pbUpdateSpriteHash(sprites)
    if Input.trigger?(Input::BACK)
      pbPlayCancelSE
      break
    end
    current_id = right_window.index+1
    if mode==0 # Switches
      if Input.trigger?(Input::USE)
        pbPlayDecisionSE
        $game_switches[current_id] = !$game_switches[current_id]
        right_window.refresh
        $game_map.need_refresh = true
      end
    elsif mode==1 # Variables
      if Input.repeat?(Input::LEFT)
        pbDebugSetVariable(current_id,-1)
        right_window.refresh
      elsif Input.repeat?(Input::RIGHT)
        pbDebugSetVariable(current_id,1)
        right_window.refresh
      elsif Input.trigger?(Input::ACTION)
        if $game_variables[current_id]==0
          $game_variables[current_id] = ""
        elsif $game_variables[current_id]==""
          $game_variables[current_id] = 0
        elsif $game_variables[current_id].is_a?(Numeric)
          $game_variables[current_id] = 0
        elsif $game_variables[current_id].is_a?(String)
          $game_variables[current_id] = ""
        end
        right_window.refresh
        $game_map.need_refresh = true
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        pbDebugVariableScreen(current_id)
        right_window.refresh
      end
    end
  end
  pbDisposeSpriteHash(sprites)
  viewport.dispose
end

#===============================================================================
# Debug Day Care screen
#===============================================================================
def pbDebugDayCare
  commands = [_INTL("Withdraw Pokémon 1"),
              _INTL("Withdraw Pokémon 2"),
              _INTL("Deposit Pokémon"),
              _INTL("Generate egg"),
              _INTL("Collect egg")]
  viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z = 99999
  sprites = {}
  addBackgroundPlane(sprites,"background","hatchbg",viewport)
  sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,viewport)
  pbSetSystemFont(sprites["overlay"].bitmap)
  sprites["cmdwindow"] = Window_CommandPokemonEx.new(commands)
  cmdwindow = sprites["cmdwindow"]
  cmdwindow.x        = 0
  cmdwindow.y        = Graphics.height-128
  cmdwindow.width    = Graphics.width
  cmdwindow.height   = 128
  cmdwindow.viewport = viewport
  cmdwindow.columns = 2
  base   = Color.new(248,248,248)
  shadow = Color.new(104,104,104)
  refresh = true
  loop do
    if refresh
      if pbEggGenerated?
        commands[3] = _INTL("Discard egg")
      else
        commands[3] = _INTL("Generate egg")
      end
      cmdwindow.commands = commands
      sprites["overlay"].bitmap.clear
      textpos = []
      for i in 0...2
        textpos.push([_INTL("Pokémon {1}",i+1),Graphics.width/4+i*Graphics.width/2,2,2,base,shadow])
      end
      for i in 0...pbDayCareDeposited
        next if !$PokemonGlobal.daycare[i][0]
        y = 34
        pkmn      = $PokemonGlobal.daycare[i][0]
        initlevel = $PokemonGlobal.daycare[i][1]
        leveldiff = pkmn.level-initlevel
        textpos.push(["#{pkmn.name} (#{pkmn.speciesName})",8+i*Graphics.width/2,y,0,base,shadow])
        y += 32
        if pkmn.male?
          textpos.push([_INTL("Male ♂"),8+i*Graphics.width/2,y,0,Color.new(128,192,248),shadow])
        elsif pkmn.female?
          textpos.push([_INTL("Female ♀"),8+i*Graphics.width/2,y,0,Color.new(248,96,96),shadow])
        else
          textpos.push([_INTL("Genderless"),8+i*Graphics.width/2,y,0,base,shadow])
        end
        y += 32
        if initlevel>=GameData::GrowthRate.max_level
          textpos.push(["Lv. #{initlevel} (max)",8+i*Graphics.width/2,y,0,base,shadow])
        elsif leveldiff>0
          textpos.push(["Lv. #{initlevel} -> #{pkmn.level} (+#{leveldiff})",
             8+i*Graphics.width/2,y,0,base,shadow])
        else
          textpos.push(["Lv. #{initlevel} (no change)",8+i*Graphics.width/2,y,0,base,shadow])
        end
        y += 32
        if pkmn.level<GameData::GrowthRate.max_level
          endexp = pkmn.growth_rate.minimum_exp_for_level(pkmn.level + 1)
          textpos.push(["To next Lv.: #{endexp-pkmn.exp}",8+i*Graphics.width/2,y,0,base,shadow])
          y += 32
        end
        cost = pbDayCareGetCost(i)
        textpos.push(["Cost: $#{cost}",8+i*Graphics.width/2,y,0,base,shadow])
      end
      if pbEggGenerated?
        textpos.push(["Egg waiting for collection",Graphics.width/2,210,2,Color.new(248,248,0),shadow])
      elsif pbDayCareDeposited==2
        if pbDayCareGetCompat==0
          textpos.push(["Pokémon cannot breed",Graphics.width/2,210,2,Color.new(248,96,96),shadow])
        else
          textpos.push(["Pokémon can breed",Graphics.width/2,210,2,Color.new(64,248,64),shadow])
        end
      end
      pbDrawTextPositions(sprites["overlay"].bitmap,textpos)
      refresh = false
    end
    pbUpdateSpriteHash(sprites)
    Graphics.update
    Input.update
    if Input.trigger?(Input::BACK)
      break
    elsif Input.trigger?(Input::USE)
      case cmdwindow.index
      when 0   # Withdraw Pokémon 1
        if !$PokemonGlobal.daycare[0][0]
          pbPlayBuzzerSE
        elsif $Trainer.party_full?
          pbPlayBuzzerSE
          pbMessage(_INTL("Party is full, can't withdraw Pokémon."))
        else
          pbPlayDecisionSE
          pbDayCareGetDeposited(0,3,4)
          pbDayCareWithdraw(0)
          refresh = true
        end
      when 1  # Withdraw Pokémon 2
        if !$PokemonGlobal.daycare[1][0]
          pbPlayBuzzerSE
        elsif $Trainer.party_full?
          pbPlayBuzzerSE
          pbMessage(_INTL("Party is full, can't withdraw Pokémon."))
        else
          pbPlayDecisionSE
          pbDayCareGetDeposited(1,3,4)
          pbDayCareWithdraw(1)
          refresh = true
        end
      when 2   # Deposit Pokémon
        if pbDayCareDeposited==2
          pbPlayBuzzerSE
        elsif $Trainer.party.length==0
          pbPlayBuzzerSE
          pbMessage(_INTL("Party is empty, can't deposit Pokémon."))
        else
          pbPlayDecisionSE
          pbChooseNonEggPokemon(1,3)
          if pbGet(1)>=0
            pbDayCareDeposit(pbGet(1))
            refresh = true
          end
        end
      when 3   # Generate/discard egg
        if pbEggGenerated?
          pbPlayDecisionSE
          $PokemonGlobal.daycareEgg      = 0
          $PokemonGlobal.daycareEggSteps = 0
          refresh = true
        else
          if pbDayCareDeposited!=2 || pbDayCareGetCompat==0
            pbPlayBuzzerSE
          else
            pbPlayDecisionSE
            $PokemonGlobal.daycareEgg = 1
            refresh = true
          end
        end
      when 4   # Collect egg
        if $PokemonGlobal.daycareEgg!=1
          pbPlayBuzzerSE
        elsif $Trainer.party_full?
          pbPlayBuzzerSE
          pbMessage(_INTL("Party is full, can't collect the egg."))
        else
          pbPlayDecisionSE
          pbDayCareGenerateEgg
          $PokemonGlobal.daycareEgg      = 0
          $PokemonGlobal.daycareEggSteps = 0
          pbMessage(_INTL("Collected the {1} egg.", $Trainer.last_party.speciesName))
          refresh = true
        end
      end
    end
  end
  pbDisposeSpriteHash(sprites)
  viewport.dispose
end



#===============================================================================
# Debug roaming Pokémon screen
#===============================================================================
class SpriteWindow_DebugRoamers < Window_DrawableCommand
  def initialize(viewport)
    super(0,0,Graphics.width,Graphics.height,viewport)
  end

  def roamerCount
    return Settings::ROAMING_SPECIES.length
  end

  def itemCount
    return self.roamerCount+2
  end

  def shadowtext(t,x,y,w,h,align=0,colors=0)
    width = self.contents.text_size(t).width
    if align==1 ;   x += (w-width)         # Right aligned
    elsif align==2; x += (w/2)-(width/2)   # Centre aligned
    end
    base = Color.new(12*8,12*8,12*8)
    if colors==1;    base = Color.new(168,48,56)   # Red
    elsif colors==2; base = Color.new(0,144,0)     # Green
    end
    pbDrawShadowText(self.contents,x,y,[width,w].max,h,t,base,Color.new(26*8,26*8,25*8))
  end

  def drawItem(index,_count,rect)
    pbSetNarrowFont(self.contents)
    rect = drawCursor(index,rect)
    nameWidth   = rect.width*50/100
    statusWidth = rect.width*50/100
    if index==self.itemCount-2
      # Advance roaming
      self.shadowtext(_INTL("[All roam to new locations]"),rect.x,rect.y,nameWidth,rect.height)
    elsif index==self.itemCount-1
      # Advance roaming
      self.shadowtext(_INTL("[Clear all current roamer locations]"),rect.x,rect.y,nameWidth,rect.height)
    else
      pkmn = Settings::ROAMING_SPECIES[index]
      name = GameData::Species.get(pkmn[0]).name + " (Lv. #{pkmn[1]})"
      status = ""
      statuscolor = 0
      if pkmn[2]<=0 || $game_switches[pkmn[2]]
        status = $PokemonGlobal.roamPokemon[index]
        if status==true
          if $PokemonGlobal.roamPokemonCaught[index]
            status = "[CAUGHT]"
          else
            status = "[DEFEATED]"
          end
          statuscolor = 1
        else
          # roaming
          curmap = $PokemonGlobal.roamPosition[index]
          if curmap
            mapinfos = pbLoadMapInfos
            status = "[ROAMING][#{curmap}: #{mapinfos[curmap].name}]"
          else
            status = "[ROAMING][map not set]"
          end
          statuscolor = 2
        end
      else
        status = "[NOT ROAMING][Switch #{pkmn[2]} is off]"
      end
      self.shadowtext(name,rect.x,rect.y,nameWidth,rect.height)
      self.shadowtext(status,rect.x+nameWidth,rect.y,statusWidth,rect.height,1,statuscolor)
    end
  end
end



def pbDebugRoamers
  viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z = 99999
  sprites = {}
  sprites["cmdwindow"] = SpriteWindow_DebugRoamers.new(viewport)
  cmdwindow = sprites["cmdwindow"]
  cmdwindow.active   = true
  loop do
    Graphics.update
    Input.update
    pbUpdateSpriteHash(sprites)
    if Input.trigger?(Input::ACTION) && cmdwindow.index<cmdwindow.roamerCount &&
       (pkmn[2]<=0 || $game_switches[pkmn[2]]) &&
       $PokemonGlobal.roamPokemon[cmdwindow.index]!=true
      # Roam selected Pokémon
      pbPlayDecisionSE
      if Input.press?(Input::CTRL)   # Roam to current map
        if $PokemonGlobal.roamPosition[cmdwindow.index]==pbDefaultMap
          $PokemonGlobal.roamPosition[cmdwindow.index] = nil
        else
          $PokemonGlobal.roamPosition[cmdwindow.index] = pbDefaultMap
        end
        cmdwindow.refresh
      else   # Roam to a random other map
        oldmap = $PokemonGlobal.roamPosition[cmdwindow.index]
        pbRoamPokemonOne(cmdwindow.index)
        if $PokemonGlobal.roamPosition[cmdwindow.index] == oldmap
          $PokemonGlobal.roamPosition[cmdwindow.index] = nil
          pbRoamPokemonOne(cmdwindow.index)
        end
        $PokemonGlobal.roamedAlready = false
        cmdwindow.refresh
      end
    elsif Input.trigger?(Input::BACK)
      pbPlayCancelSE
      break
    elsif Input.trigger?(Input::USE)
      if cmdwindow.index<cmdwindow.roamerCount
        pbPlayDecisionSE
        # Toggle through roaming, not roaming, defeated
        pkmn = Settings::ROAMING_SPECIES[cmdwindow.index]
        if pkmn[2]>0 && !$game_switches[pkmn[2]]
          # not roaming -> roaming
          $game_switches[pkmn[2]] = true
        elsif $PokemonGlobal.roamPokemon[cmdwindow.index]!=true
          # roaming -> defeated
          $PokemonGlobal.roamPokemon[cmdwindow.index] = true
          $PokemonGlobal.roamPokemonCaught[cmdwindow.index] = false
        elsif $PokemonGlobal.roamPokemon[cmdwindow.index] == true &&
           !$PokemonGlobal.roamPokemonCaught[cmdwindow.index]
          # defeated -> caught
          $PokemonGlobal.roamPokemonCaught[cmdwindow.index] = true
        elsif pkmn[2]>0
          # caught -> not roaming (or roaming if Switch ID is 0
          $game_switches[pkmn[2]] = false if pkmn[2]>0
          $PokemonGlobal.roamPokemon[cmdwindow.index] = nil
          $PokemonGlobal.roamPokemonCaught[cmdwindow.index] = false
        end
        cmdwindow.refresh
      elsif cmdwindow.index==cmdwindow.itemCount-2   # All roam
        if Settings::ROAMING_SPECIES.length==0
          pbPlayBuzzerSE
        else
          pbPlayDecisionSE
          pbRoamPokemon
          $PokemonGlobal.roamedAlready = false
          cmdwindow.refresh
        end
      else   # Clear all roaming locations
        if Settings::ROAMING_SPECIES.length==0
          pbPlayBuzzerSE
        else
          pbPlayDecisionSE
          for i in 0...Settings::ROAMING_SPECIES.length
            $PokemonGlobal.roamPosition[i] = nil
          end
          $PokemonGlobal.roamedAlready = false
          cmdwindow.refresh
        end
      end
    end
  end
  pbDisposeSpriteHash(sprites)
  viewport.dispose
end



#===============================================================================
# Text import/export for localisation
#===============================================================================
def pbExtractText
  msgwindow = pbCreateMessageWindow
  if safeExists?("intl.txt") &&
     !pbConfirmMessageSerious(_INTL("intl.txt already exists. Overwrite it?"))
    pbDisposeMessageWindow(msgwindow)
    return
  end
  pbMessageDisplay(msgwindow,_INTL("Please wait.\\wtnp[0]"))
  MessageTypes.extract("intl.txt")
  pbMessageDisplay(msgwindow,_INTL("All text in the game was extracted and saved to intl.txt.\1"))
  pbMessageDisplay(msgwindow,_INTL("To localize the text for a particular language, translate every second line in the file.\1"))
  pbMessageDisplay(msgwindow,_INTL("After translating, choose \"Compile Text.\""))
  pbDisposeMessageWindow(msgwindow)
end

def pbCompileTextUI
  msgwindow = pbCreateMessageWindow
  pbMessageDisplay(msgwindow,_INTL("Please wait.\\wtnp[0]"))
  begin
    pbCompileText
    pbMessageDisplay(msgwindow,_INTL("Successfully compiled text and saved it to intl.dat.\1"))
    pbMessageDisplay(msgwindow,_INTL("To use the file in a game, place the file in the Data folder under a different name, and edit the Settings::LANGUAGES array in the scripts."))
  rescue RuntimeError
    pbMessageDisplay(msgwindow,_INTL("Failed to compile text: {1}",$!.message))
  end
  pbDisposeMessageWindow(msgwindow)
end

#===============================================================================
# Battle animations import/export
#===============================================================================
def pbExportAllAnimations
  begin
    Dir.mkdir("Animations") rescue nil
    animations = pbLoadBattleAnimations
    if animations
      msgwindow = pbCreateMessageWindow
      for anim in animations
        next if !anim || anim.length==0 || anim.name==""
        pbMessageDisplay(msgwindow,anim.name,false)
        Graphics.update
        safename = anim.name.gsub(/\W/,"_")
        Dir.mkdir("Animations/#{safename}") rescue nil
        File.open("Animations/#{safename}/#{safename}.anm","wb") { |f|
          f.write(dumpBase64Anim(anim))
        }
        if anim.graphic && anim.graphic!=""
          graphicname = RTP.getImagePath("Graphics/Animations/"+anim.graphic)
          pbSafeCopyFile(graphicname,"Animations/#{safename}/"+File.basename(graphicname))
        end
        for timing in anim.timing
          if !timing.timingType || timing.timingType==0
            if timing.name && timing.name!=""
              audioName = RTP.getAudioPath("Audio/SE/Anim/"+timing.name)
              pbSafeCopyFile(audioName,"Animations/#{safename}/"+File.basename(audioName))
            end
          elsif timing.timingType==1 || timing.timingType==3
            if timing.name && timing.name!=""
              graphicname = RTP.getImagePath("Graphics/Animations/"+timing.name)
              pbSafeCopyFile(graphicname,"Animations/#{safename}/"+File.basename(graphicname))
            end
          end
        end
      end
      pbDisposeMessageWindow(msgwindow)
      pbMessage(_INTL("All animations were extracted and saved to the Animations folder."))
    else
      pbMessage(_INTL("There are no animations to export."))
    end
  rescue
    p $!.message,$!.backtrace
    pbMessage(_INTL("The export failed."))
  end
end

def pbImportAllAnimations
  animationFolders = []
  if safeIsDirectory?("Animations")
    Dir.foreach("Animations") { |fb|
      f = "Animations/"+fb
      if safeIsDirectory?(f) && fb!="." && fb!=".."
        animationFolders.push(f)
      end
    }
  end
  if animationFolders.length==0
    pbMessage(_INTL("There are no animations to import. Put each animation in a folder within the Animations folder."))
  else
    msgwindow = pbCreateMessageWindow
    animations = pbLoadBattleAnimations
    animations = PBAnimations.new if !animations
    for folder in animationFolders
      pbMessageDisplay(msgwindow,folder,false)
      Graphics.update
      audios = []
      files = Dir.glob(folder+"/*.*")
      %w( wav ogg mid wma mp3 ).each { |ext|
        upext = ext.upcase
        audios.concat(files.find_all { |f| f[f.length-3,3]==ext })
        audios.concat(files.find_all { |f| f[f.length-3,3]==upext })
      }
      for audio in audios
        pbSafeCopyFile(audio,RTP.getAudioPath("Audio/SE/Anim/"+File.basename(audio)),"Audio/SE/Anim/"+File.basename(audio))
      end
      images = []
      %w( png gif ).each { |ext|   # jpg jpeg bmp
        upext = ext.upcase
        images.concat(files.find_all { |f| f[f.length-3,3]==ext })
        images.concat(files.find_all { |f| f[f.length-3,3]==upext })
      }
      for image in images
        pbSafeCopyFile(image,RTP.getImagePath("Graphics/Animations/"+File.basename(image)),"Graphics/Animations/"+File.basename(image))
      end
      Dir.glob(folder+"/*.anm") { |f|
        textdata = loadBase64Anim(IO.read(f)) rescue nil
        if textdata && textdata.is_a?(PBAnimation)
          index = pbAllocateAnimation(animations,textdata.name)
          missingFiles = []
          textdata.name = File.basename(folder) if textdata.name==""
          textdata.id = -1   # This is not an RPG Maker XP animation
          pbConvertAnimToNewFormat(textdata)
          if textdata.graphic && textdata.graphic!=""
            if !safeExists?(folder+"/"+textdata.graphic) &&
               !FileTest.image_exist?("Graphics/Animations/"+textdata.graphic)
              textdata.graphic = ""
              missingFiles.push(textdata.graphic)
            end
          end
          for timing in textdata.timing
            if timing.name && timing.name!=""
              if !safeExists?(folder+"/"+timing.name) &&
                 !FileTest.audio_exist?("Audio/SE/Anim/"+timing.name)
                timing.name = ""
                missingFiles.push(timing.name)
              end
            end
          end
          animations[index] = textdata
        end
      }
    end
    save_data(animations,"Data/PkmnAnimations.rxdata")
    $PokemonTemp.battleAnims = nil
    pbDisposeMessageWindow(msgwindow)
    pbMessage(_INTL("All animations were imported."))
  end
end

#===============================================================================
# Properly erases all non-existent tiles in maps (including event graphics)
#===============================================================================
def pbDebugFixInvalidTiles
  num_errors = 0
  num_error_maps = 0
  tilesets = $data_tilesets
  mapData = Compiler::MapData.new
  t = Time.now.to_i
  Graphics.update
  for id in mapData.mapinfos.keys.sort
    if Time.now.to_i - t >= 5
      Graphics.update
      t = Time.now.to_i
    end
    changed = false
    map = mapData.getMap(id)
    next if !map || !mapData.mapinfos[id]
    pbSetWindowText(_INTL("Processing map {1} ({2})", id, mapData.mapinfos[id].name))
    passages = mapData.getTilesetPassages(map, id)
    # Check all tiles in map for non-existent tiles
    for x in 0...map.data.xsize
      for y in 0...map.data.ysize
        for i in 0...map.data.zsize
          tile_id = map.data[x, y, i]
          next if pbCheckTileValidity(tile_id, map, tilesets, passages)
          map.data[x, y, i] = 0
          changed = true
          num_errors += 1
        end
      end
    end
    # Check all events in map for page graphics using a non-existent tile
    for key in map.events.keys
      event = map.events[key]
      for page in event.pages
        next if page.graphic.tile_id <= 0
        next if pbCheckTileValidity(page.graphic.tile_id, map, tilesets, passages)
        page.graphic.tile_id = 0
        changed = true
        num_errors += 1
      end
    end
    next if !changed
    # Map was changed; save it
    num_error_maps += 1
    mapData.saveMap(id)
  end
  if num_error_maps == 0
    pbMessage(_INTL("No invalid tiles were found."))
  else
    pbMessage(_INTL("{1} error(s) were found across {2} map(s) and fixed.", num_errors, num_error_maps))
    pbMessage(_INTL("Close RPG Maker XP to ensure the changes are applied properly."))
  end
end

def pbCheckTileValidity(tile_id, map, tilesets, passages)
  return false if !tile_id
  if tile_id > 0 && tile_id < 384
    # Check for defined autotile
    autotile_id = tile_id / 48 - 1
    autotile_name = tilesets[map.tileset_id].autotile_names[autotile_id]
    return true if autotile_name && autotile_name != ""
  else
    # Check for tileset data
    return true if passages[tile_id]
  end
  return false
end



#===============================================================================
# Pseudo-party screen for editing Pokémon being set up for a wild battle
#===============================================================================
class PokemonDebugPartyScreen
  def initialize
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @messageBox = Window_AdvancedTextPokemon.new("")
    @messageBox.viewport       = @viewport
    @messageBox.visible        = false
    @messageBox.letterbyletter = true
    pbBottomLeftLines(@messageBox,2)
    @helpWindow = Window_UnformattedTextPokemon.new("")
    @helpWindow.viewport = @viewport
    @helpWindow.visible  = true
    pbBottomLeftLines(@helpWindow,1)
  end

  def pbEndScreen
    @messageBox.dispose
    @helpWindow.dispose
    @viewport.dispose
  end

  def pbDisplay(text)
    @messageBox.text    = text
    @messageBox.visible = true
    @helpWindow.visible = false
    pbPlayDecisionSE
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if @messageBox.busy?
        if Input.trigger?(Input::USE)
          pbPlayDecisionSE if @messageBox.pausing?
          @messageBox.resume
        end
      else
        if Input.trigger?(Input::BACK) || Input.trigger?(Input::USE)
          break
        end
      end
    end
    @messageBox.visible = false
    @helpWindow.visible = true
  end

  def pbConfirm(text)
    ret = -1
    @messageBox.text    = text
    @messageBox.visible = true
    @helpWindow.visible = false
    using(cmdwindow = Window_CommandPokemon.new([_INTL("Yes"),_INTL("No")])) {
      cmdwindow.visible = false
      pbBottomRight(cmdwindow)
      cmdwindow.y -= @messageBox.height
      cmdwindow.z = @viewport.z+1
      loop do
        Graphics.update
        Input.update
        cmdwindow.visible = true if !@messageBox.busy?
        cmdwindow.update
        pbUpdate
        if !@messageBox.busy?
          if Input.trigger?(Input::BACK)
            ret = false
            break
          elsif Input.trigger?(Input::USE) && @messageBox.resume
            ret = (cmdwindow.index==0)
            break
          end
        end
      end
    }
    @messageBox.visible = false
    @helpWindow.visible = true
    return ret
  end

  def pbShowCommands(text,commands,index=0)
    ret = -1
    @helpWindow.visible = true
    using(cmdwindow = Window_CommandPokemonColor.new(commands)) {
      cmdwindow.z     = @viewport.z+1
      cmdwindow.index = index
      pbBottomRight(cmdwindow)
      @helpWindow.resizeHeightToFit(text,Graphics.width-cmdwindow.width)
      @helpWindow.text = text
      pbBottomLeft(@helpWindow)
      loop do
        Graphics.update
        Input.update
        cmdwindow.update
        pbUpdate
        if Input.trigger?(Input::BACK)
          pbPlayCancelSE
          ret = -1
          break
        elsif Input.trigger?(Input::USE)
          pbPlayDecisionSE
          ret = cmdwindow.index
          break
        end
      end
    }
    return ret
  end

  def pbChooseMove(pkmn,text,index=0)
    moveNames = []
    for i in pkmn.moves
      if i.total_pp<=0
        moveNames.push(_INTL("{1} (PP: ---)",i.name))
      else
        moveNames.push(_INTL("{1} (PP: {2}/{3})",i.name,i.pp,i.total_pp))
      end
    end
    return pbShowCommands(text,moveNames,index)
  end

  def pbRefreshSingle(index); end

  def update
    @messageBox.update
    @helpWindow.update
  end
  alias pbUpdate update
end


#===============================================================================
# Additonal Methods for the Battle Debug Menu
#===============================================================================
def setSideEffects(sideIdx,sides, battlers)
  viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z = 99999
  sprites = {}
  sprites["right_window"] = SpriteWindow_DebugBattleEffects.new(viewport,sides[sideIdx],SIDE_EFFECTS,battlers)
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
    return @dataSource.effects[key]
  end

  def isSwitch(key)
    return false if !defined?(@dataSource.effects)
    return !!@dataSource.effects[key] == @dataSource.effects[key]
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
    color = 0
    isMoveIDEffect = isMoveIDEffect?(key)
    if isMoveIDEffect
      status = value > 0 ? PBMoves.getName(value) : "None"
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

  def getItemNames(trainerIdx)
    items = @dataSource.items[trainerIdx]
    if !items || items.length<=0
      return "None"
    end
    itemString = ""
    itemArray.each_with_index{ |itemID, idx|
      itemString += _INTL("{1}", PBItems.getName(itemID))
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
    stat = dataArray[0]
    name = dataArray[1][:name]
    value = getValue(stat)
    status = _INTL("{1}",value)
    colors = value > 0 ? 2 : value < 0 ? 1 : 0
    
    rect = drawCursor(idx,rect)
    totalWidth = rect.width
    nameWidth   = totalWidth*65/100
    statusWidth = totalWidth*20/100
    self.shadowtext(rect.x,rect.y,nameWidth,rect.height,name,0,0)
    self.shadowtext(rect.x+nameWidth,rect.y,statusWidth,rect.height,status,1,colors)
  end
end


def pbNoSortingChooseList(commands,default=0,cancelValue=-1)
    cmdwin = pbListWindow([])
    itemID = default
    itemIndex = default
    loop do
        realcommands = []
        for command in commands
            realcommands.push(command[1])
            
        end
        cmd = pbCommandsSortable(cmdwin,realcommands,-1,itemIndex,false)
        if cmd[0]==0   # Chose an option or cancelled
            itemID = (cmd[1]<0) ? cancelValue : commands[cmd[1]][0]
            break
        end
    end
    cmdwin.dispose
    return itemID
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
    end

    def setMinMaxValues(minNumeric,maxNumeric)
        @minNumeric     = minNumeric
        @maxNumeric     = maxNumeric 
    end

    def allowSorting=(allowSorting)
        @allowSorting = allowSorting
    end

    def startLoop()
        loop do
            Graphics.update
            Input.update
            pbUpdateSpriteHash(@sprites)
            if Input.trigger?(Input::B)
                pbPlayCancelSE
                break
            end
            index = @window.index
            key = @window.getByIndex(index)
            if Input.trigger?(Input::A) && @allowSorting
                @window.toggleSortMode
            end
            if @window.isSwitch(key) # Switches
                if Input.trigger?(Input::C)
                    toggleSwitch(key)
                    @window.refresh
                end
            elsif isNumeric(key) && !Input.trigger?(Input::C) # Numerics
                if Input.repeat?(Input::LEFT) && leftInputConditions(key)
                    decreaseNumeric(key)
                    @window.refresh
                elsif Input.repeat?(Input::RIGHT) && rightInputConditions(key)
                    increaseNumeric(key)
                    @window.refresh
                end
            elsif Input.trigger?(Input::C)
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
        elsif isNumeric(key)
            setNumeric(key,currentValue)
        end
    end

    def setNumeric(key,currentValue)
        newValue = getNumericValue("Enter value.",currentValue)
        @dataSource.instance_variable_set("@#{key}", newValue)
    end

end


class PokeBattlle_FakePokemon < PokeBattle_Pokemon
    
    def initialize(oPokemon,battler)
        species = oPokemon.species
        level = battler.level
        owner = nil
        super(species,level,owner,false)
        @personalID     = oPokemon.personalID
        @hp             = oPokemon.hp
        @totalhp        = oPokemon.totalhp
        @iv             = oPokemon.iv
        @ivMaxed        = oPokemon.ivMaxed
        @ev             = oPokemon.ev
        @moves          = battler.moves
        @status         = battler.status
        @item           = battler.item
        @trainerID      = oPokemon.trainerID
        @ot             = oPokemon.ot
        @otgender       = oPokemon.otgender
        @obtainMap      = oPokemon.obtainMap
        @obtainText     = oPokemon.obtainText
        @obtainLevel    = oPokemon.obtainLevel
        @obtainMode     = oPokemon.obtainMode
        @hatchedMap     = oPokemon.hatchedMap
        @natureflag     = oPokemon.natureflag
        @timeReceived   = oPokemon.timeReceived
        @type1          = battler.type1
        @type2          = battler.type2
        @ability        = battler.ability
        calcStats
    end

    def type1
        return @type1
    end

    def type2
        return @type2
    end

    def ability
        return @ability
    end
end