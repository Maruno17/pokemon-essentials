class PokemonLoadPanel < SpriteWrapper
  attr_reader :selected

  TEXTCOLOR             = Color.new(232,232,232)
  TEXTSHADOWCOLOR       = Color.new(136,136,136)
  MALETEXTCOLOR         = Color.new(56,160,248)
  MALETEXTSHADOWCOLOR   = Color.new(56,104,168)
  FEMALETEXTCOLOR       = Color.new(240,72,88)
  FEMALETEXTSHADOWCOLOR = Color.new(160,64,64)

  def initialize(index,title,isContinue,trainer,framecount,mapid,viewport=nil)
    super(viewport)
    @index = index
    @title = title
    @isContinue = isContinue
    @trainer = trainer
    @totalsec = (framecount || 0) / Graphics.frame_rate
    @mapid = mapid
    @selected = (index==0)
    @bgbitmap = AnimatedBitmap.new("Graphics/Pictures/loadPanels")
    @refreshBitmap = true
    @refreshing = false
    refresh
  end

  def dispose
    @bgbitmap.dispose
    self.bitmap.dispose
    super
  end

  def selected=(value)
    return if @selected==value
    @selected = value
    @refreshBitmap = true
    refresh
  end

  def pbRefresh
    @refreshBitmap = true
    refresh
  end

  def refresh
    return if @refreshing
    return if disposed?
    @refreshing = true
    if !self.bitmap || self.bitmap.disposed?
      self.bitmap = BitmapWrapper.new(@bgbitmap.width,111*2)
      pbSetSystemFont(self.bitmap)
    end
    if @refreshBitmap
      @refreshBitmap = false
      self.bitmap.clear if self.bitmap
      if @isContinue
        self.bitmap.blt(0,0,@bgbitmap.bitmap,Rect.new(0,(@selected) ? 111*2 : 0,@bgbitmap.width,111*2))
      else
        self.bitmap.blt(0,0,@bgbitmap.bitmap,Rect.new(0,111*2*2+((@selected) ? 23*2 : 0),@bgbitmap.width,23*2))
      end
      textpos = []
      if @isContinue
        textpos.push([@title,16*2,5*2,0,TEXTCOLOR,TEXTSHADOWCOLOR])
        textpos.push([_INTL("Badges:"),16*2,56*2,0,TEXTCOLOR,TEXTSHADOWCOLOR])
        textpos.push([@trainer.numbadges.to_s,103*2,56*2,1,TEXTCOLOR,TEXTSHADOWCOLOR])
        textpos.push([_INTL("Pokédex:"),16*2,72*2,0,TEXTCOLOR,TEXTSHADOWCOLOR])
        textpos.push([@trainer.pokedexSeen.to_s,103*2,72*2,1,TEXTCOLOR,TEXTSHADOWCOLOR])
        textpos.push([_INTL("Time:"),16*2,88*2,0,TEXTCOLOR,TEXTSHADOWCOLOR])
        hour = @totalsec / 60 / 60
        min  = @totalsec / 60 % 60
        if hour>0
          textpos.push([_INTL("{1}h {2}m",hour,min),103*2,88*2,1,TEXTCOLOR,TEXTSHADOWCOLOR])
        else
          textpos.push([_INTL("{1}m",min),103*2,88*2,1,TEXTCOLOR,TEXTSHADOWCOLOR])
        end
        if @trainer.male?
          textpos.push([@trainer.name,56*2,32*2,0,MALETEXTCOLOR,MALETEXTSHADOWCOLOR])
        elsif @trainer.female?
          textpos.push([@trainer.name,56*2,32*2,0,FEMALETEXTCOLOR,FEMALETEXTSHADOWCOLOR])
        else
          textpos.push([@trainer.name,56*2,32*2,0,TEXTCOLOR,TEXTSHADOWCOLOR])
        end
        mapname = pbGetMapNameFromId(@mapid)
        mapname.gsub!(/\\PN/,@trainer.name)
        textpos.push([mapname,193*2,5*2,1,TEXTCOLOR,TEXTSHADOWCOLOR])
      else
        textpos.push([@title,16*2,4*2,0,TEXTCOLOR,TEXTSHADOWCOLOR])
      end
      pbDrawTextPositions(self.bitmap,textpos)
    end
    @refreshing = false
  end
end



class PokemonLoad_Scene
  def pbStartScene(commands,showContinue,trainer,framecount,mapid)
    @commands = commands
    @sprites = {}
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99998
    addBackgroundOrColoredPlane(@sprites,"background","loadbg",Color.new(248,248,248),@viewport)
    y = 16*2
    for i in 0...commands.length
      @sprites["panel#{i}"] = PokemonLoadPanel.new(i,commands[i],
         (showContinue) ? (i==0) : false,trainer,framecount,mapid,@viewport)
      @sprites["panel#{i}"].x = 24*2
      @sprites["panel#{i}"].y = y
      @sprites["panel#{i}"].pbRefresh
      y += (showContinue && i==0) ? 112*2 : 24*2
    end
    @sprites["cmdwindow"] = Window_CommandPokemon.new([])
    @sprites["cmdwindow"].viewport = @viewport
    @sprites["cmdwindow"].visible  = false
  end

  def pbStartScene2
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbStartDeleteScene
    @sprites = {}
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99998
    addBackgroundOrColoredPlane(@sprites,"background","loadbg",Color.new(248,248,248),@viewport)
  end

  def pbUpdate
    oldi = @sprites["cmdwindow"].index rescue 0
    pbUpdateSpriteHash(@sprites)
    newi = @sprites["cmdwindow"].index rescue 0
    if oldi!=newi
      @sprites["panel#{oldi}"].selected = false
      @sprites["panel#{oldi}"].pbRefresh
      @sprites["panel#{newi}"].selected = true
      @sprites["panel#{newi}"].pbRefresh
      while @sprites["panel#{newi}"].y>Graphics.height-40*2
        for i in 0...@commands.length
          @sprites["panel#{i}"].y -= 24*2
        end
        for i in 0...6
          break if !@sprites["party#{i}"]
          @sprites["party#{i}"].y -= 24*2
        end
        @sprites["player"].y -= 24*2 if @sprites["player"]
      end
      while @sprites["panel#{newi}"].y<16*2
        for i in 0...@commands.length
          @sprites["panel#{i}"].y += 24*2
        end
        for i in 0...6
          break if !@sprites["party#{i}"]
          @sprites["party#{i}"].y += 24*2
        end
        @sprites["player"].y += 24*2 if @sprites["player"]
      end
    end
  end

  def pbSetParty(trainer)
    return if !trainer || !trainer.party
    meta = GameData::Metadata.get_player(trainer.metaID)
    if meta
      filename = pbGetPlayerCharset(meta,1,trainer,true)
      @sprites["player"] = TrainerWalkingCharSprite.new(filename,@viewport)
      charwidth  = @sprites["player"].bitmap.width
      charheight = @sprites["player"].bitmap.height
      @sprites["player"].x        = 56*2-charwidth/8
      @sprites["player"].y        = 56*2-charheight/8
      @sprites["player"].src_rect = Rect.new(0,0,charwidth/4,charheight/4)
    end
    for i in 0...trainer.party.length
      @sprites["party#{i}"] = PokemonIconSprite.new(trainer.party[i],@viewport)
      @sprites["party#{i}"].setOffset(PictureOrigin::Center)
      @sprites["party#{i}"].x = (167+33*(i%2))*2
      @sprites["party#{i}"].y = (56+25*(i/2))*2
      @sprites["party#{i}"].z = 99999
    end
  end

  def pbChoose(commands)
    @sprites["cmdwindow"].commands = commands
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::C)
        return @sprites["cmdwindow"].index
      end
    end
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbCloseScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end



class PokemonLoadScreen
  def initialize(scene)
    @scene = scene
  end

  def pbTryLoadFile(savefile)
    trainer       = nil
    framecount    = nil
    game_system   = nil
    pokemonSystem = nil
    mapid         = nil
    File.open(savefile) { |f|
      trainer       = Marshal.load(f)
      framecount    = Marshal.load(f)
      game_system   = Marshal.load(f)
      pokemonSystem = Marshal.load(f)
      mapid         = Marshal.load(f)
    }
    raise "Corrupted file" if !trainer.is_a?(PokeBattle_Trainer)
    raise "Corrupted file" if !framecount.is_a?(Numeric)
    raise "Corrupted file" if !game_system.is_a?(Game_System)
    raise "Corrupted file" if !pokemonSystem.is_a?(PokemonSystem)
    raise "Corrupted file" if !mapid.is_a?(Numeric)
    return [trainer,framecount,game_system,pokemonSystem,mapid]
  end

  def pbStartDeleteScreen
    savefile = RTP.getSaveFileName("Game.rxdata")
    @scene.pbStartDeleteScene
    @scene.pbStartScene2
    if safeExists?(savefile)
      if pbConfirmMessageSerious(_INTL("Delete all saved data?"))
        pbMessage(_INTL("Once data has been deleted, there is no way to recover it.\1"))
        if pbConfirmMessageSerious(_INTL("Delete the saved data anyway?"))
          pbMessage(_INTL("Deleting all data. Don't turn off the power.\\wtnp[0]"))
          begin; File.delete(savefile); rescue; end
          begin; File.delete(savefile+".bak"); rescue; end
          pbMessage(_INTL("The save file was deleted."))
        end
      end
    else
      pbMessage(_INTL("No save file was found."))
    end
    @scene.pbEndScene
    $scene = pbCallTitle
  end

  def pbStartLoadScreen
    $PokemonTemp   = PokemonTemp.new
    $game_temp     = Game_Temp.new
    $game_system   = Game_System.new
    $PokemonSystem = PokemonSystem.new if !$PokemonSystem
    savefile = RTP.getSaveFileName("Game.rxdata")
    FontInstaller.install
    data_system = pbLoadRxData("Data/System")
    mapfile = sprintf("Data/Map%03d.rxdata",data_system.start_map_id)
    if data_system.start_map_id==0 || !pbRgssExists?(mapfile)
      pbMessage(_INTL("No starting position was set in the map editor.\1"))
      pbMessage(_INTL("The game cannot continue."))
      @scene.pbEndScene
      $scene = nil
      return
    end
    commands = []
    cmdContinue    = -1
    cmdNewGame     = -1
    cmdOption      = -1
    cmdLanguage    = -1
    cmdMysteryGift = -1
    cmdDebug       = -1
    cmdQuit        = -1
    if safeExists?(savefile)
      trainer      = nil
      framecount   = 0
      mapid        = 0
      haveBackup   = false
      showContinue = false
      begin
        trainer, framecount, $game_system, $PokemonSystem, mapid = pbTryLoadFile(savefile)
        showContinue = true
      rescue
        if safeExists?(savefile+".bak")
          begin
            trainer, framecount, $game_system, $PokemonSystem, mapid = pbTryLoadFile(savefile+".bak")
            haveBackup   = true
            showContinue = true
          rescue
          end
        end
        if haveBackup
          pbMessage(_INTL("The save file is corrupt. The previous save file will be loaded."))
        else
          pbMessage(_INTL("The save file is corrupt, or is incompatible with this game."))
          if !pbConfirmMessageSerious(_INTL("Do you want to delete the save file and start anew?"))
            $scene = nil
            return
          end
          begin; File.delete(savefile); rescue; end
          begin; File.delete(savefile+".bak"); rescue; end
          $game_system   = Game_System.new
          $PokemonSystem = PokemonSystem.new if !$PokemonSystem
          pbMessage(_INTL("The save file was deleted."))
        end
      end
      if showContinue
        if !haveBackup
          begin; File.delete(savefile+".bak"); rescue; end
        end
      end
      commands[cmdContinue = commands.length]    = _INTL("Continue") if showContinue
      commands[cmdNewGame = commands.length]     = _INTL("New Game")
      commands[cmdMysteryGift = commands.length] = _INTL("Mystery Gift") if (trainer.mysterygiftaccess rescue false)
    else
      commands[cmdNewGame = commands.length]     = _INTL("New Game")
    end
    commands[cmdOption = commands.length]        = _INTL("Options")
    commands[cmdLanguage = commands.length]      = _INTL("Language") if LANGUAGES.length>=2
    commands[cmdDebug = commands.length]         = _INTL("Debug") if $DEBUG
    commands[cmdQuit = commands.length]          = _INTL("Quit Game")
    @scene.pbStartScene(commands,showContinue,trainer,framecount,mapid)
    @scene.pbSetParty(trainer) if showContinue
    @scene.pbStartScene2
    pbLoadBattleAnimations
    loop do
      command = @scene.pbChoose(commands)
      if cmdContinue>=0 && command==cmdContinue
        unless safeExists?(savefile)
          pbPlayBuzzerSE
          next
        end
        pbPlayDecisionSE
        @scene.pbEndScene
        metadata = nil
        File.open(savefile) { |f|
          Marshal.load(f)   # Trainer already loaded
          $Trainer             = trainer
          Graphics.frame_count = Marshal.load(f)
          $game_system         = Marshal.load(f)
          Marshal.load(f)   # PokemonSystem already loaded
          Marshal.load(f)   # Current map id no longer needed
          $game_switches       = Marshal.load(f)
          $game_variables      = Marshal.load(f)
          $game_self_switches  = Marshal.load(f)
          $game_screen         = Marshal.load(f)
          $MapFactory          = Marshal.load(f)
          $game_map            = $MapFactory.map
          $game_player         = Marshal.load(f)
          $PokemonGlobal       = Marshal.load(f)
          metadata             = Marshal.load(f)
          $PokemonBag          = Marshal.load(f)
          $PokemonStorage      = Marshal.load(f)
          $SaveVersion         = Marshal.load(f) unless f.eof?
          pbRefreshResizeFactor   # To fix Game_Screen pictures
          magicNumberMatches = false
          if $data_system.respond_to?("magic_number")
            magicNumberMatches = ($game_system.magic_number==$data_system.magic_number)
          else
            magicNumberMatches = ($game_system.magic_number==$data_system.version_id)
          end
          if !magicNumberMatches || $PokemonGlobal.safesave
            if pbMapInterpreterRunning?
              pbMapInterpreter.setup(nil,0)
            end
            begin
              $MapFactory.setup($game_map.map_id)   # calls setMapChanged
            rescue Errno::ENOENT
              if $DEBUG
                pbMessage(_INTL("Map {1} was not found.",$game_map.map_id))
                map = pbWarpToMap
                if map
                  $MapFactory.setup(map[0])
                  $game_player.moveto(map[1],map[2])
                else
                  $game_map = nil
                  $scene = nil
                  return
                end
              else
                $game_map = nil
                $scene = nil
                pbMessage(_INTL("The map was not found. The game cannot continue."))
              end
            end
            $game_player.center($game_player.x, $game_player.y)
          else
            $MapFactory.setMapChanged($game_map.map_id)
          end
        }
        if !$game_map.events   # Map wasn't set up
          $game_map = nil
          $scene = nil
          pbMessage(_INTL("The map is corrupt. The game cannot continue."))
          return
        end
        $PokemonMap = metadata
        $PokemonEncounters = PokemonEncounters.new
        $PokemonEncounters.setup($game_map.map_id)
        pbAutoplayOnSave
        $game_map.update
        $PokemonMap.updateMap
        $scene = Scene_Map.new
        return
      elsif cmdNewGame>=0 && command==cmdNewGame
        pbPlayDecisionSE
        @scene.pbEndScene
        if $game_map && $game_map.events
          for event in $game_map.events.values
            event.clear_starting
          end
        end
        $game_temp.common_event_id = 0 if $game_temp
        $scene               = Scene_Map.new
        Graphics.frame_count = 0
        $game_system         = Game_System.new
        $game_switches       = Game_Switches.new
        $game_variables      = Game_Variables.new
        $game_self_switches  = Game_SelfSwitches.new
        $game_screen         = Game_Screen.new
        $game_player         = Game_Player.new
        $PokemonMap          = PokemonMapMetadata.new
        $PokemonGlobal       = PokemonGlobalMetadata.new
        $PokemonStorage      = PokemonStorage.new
        $PokemonEncounters   = PokemonEncounters.new
        $PokemonTemp.begunNewGame = true
        pbRefreshResizeFactor   # To fix Game_Screen pictures
        $data_system         = pbLoadRxData("Data/System")
        $MapFactory          = PokemonMapFactory.new($data_system.start_map_id)   # calls setMapChanged
        $game_player.moveto($data_system.start_x, $data_system.start_y)
        $game_player.refresh
        $game_map.autoplay
        $game_map.update
        return
      elsif cmdMysteryGift>=0 && command==cmdMysteryGift
        pbPlayDecisionSE
        pbFadeOutIn {
          trainer = pbDownloadMysteryGift(trainer)
        }
      elsif cmdOption>=0 && command==cmdOption
        pbPlayDecisionSE
        pbFadeOutIn {
          scene = PokemonOption_Scene.new
          screen = PokemonOptionScreen.new(scene)
          screen.pbStartScreen(true)
        }
      elsif cmdLanguage>=0 && command==cmdLanguage
        pbPlayDecisionSE
        @scene.pbEndScene
        $PokemonSystem.language = pbChooseLanguage
        pbLoadMessages("Data/"+LANGUAGES[$PokemonSystem.language][1])
        savedata = []
        if safeExists?(savefile)
          File.open(savefile,"rb") { |f|
            16.times { savedata.push(Marshal.load(f)) }
          }
          savedata[3]=$PokemonSystem
          begin
            File.open(RTP.getSaveFileName("Game.rxdata"),"wb") { |f|
              16.times { |i| Marshal.dump(savedata[i],f) }
            }
          rescue
          end
        end
        $scene = pbCallTitle
        return
      elsif cmdDebug>=0 && command==cmdDebug
        pbPlayDecisionSE
        pbFadeOutIn { pbDebugMenu(false) }
      elsif cmdQuit>=0 && command==cmdQuit
        pbPlayCloseMenuSE
        @scene.pbEndScene
        $scene = nil
        return
      end
    end
  end
end



################################################################################
# Font installer
################################################################################
module FontInstaller
  # filenames of fonts to be installed
  Filenames = [
     'pkmnem.ttf',
     'pkmnemn.ttf',
     'pkmnems.ttf',
     'pkmnrs.ttf',
     'pkmndp.ttf',
     'pkmnfl.ttf'
  ]
  # names (not filenames) of fonts to be installed
  Names = [
    'Power Green',
    'Power Green Narrow',
    'Power Green Small',
    'Power Red and Blue',
    'Power Clear',
    'Power Red and Green'
  ]
  # whether to notify player (via pop-up message) that fonts were installed
  Notify = true
  # location of fonts (relative to game folder)
  Source = 'Fonts/'

  def self.getFontFolder
    fontfolder = MiniRegistry.get(MiniRegistry::HKEY_CURRENT_USER,
       "Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders","Fonts")
    return fontfolder+"\\" if fontfolder
    if ENV['SystemRoot']
      return ENV['SystemRoot'] + '\\Fonts\\'
    elsif ENV['windir']
      return ENV['windir'] + '\\Fonts\\'
    else
      return '\\Windows\\Fonts\\'
    end
  end

  AFR = Win32API.new('gdi32', 'AddFontResource', ['P'], 'L')
  WPS = Win32API.new('kernel32', 'WriteProfileString', ['P'] * 3, 'L')
  SM  = Win32API.new('user32', 'PostMessage', ['L'] * 4, 'L')
  WM_FONTCHANGE = 0x001D
  HWND_BROADCAST = 0xffff

  def self.copy_file(src,dest)
    File.open(src,'rb') { |r|
      File.open(dest,'wb') { |w|
        while s = r.read(4096)
          w.write s
        end
      }
    }
  end

  def self.pbResolveFont(name)
    RTP.eachPathFor(Source+name) { |file|
      return file if safeExists?(file)
    }
    return Source+name
  end

  def self.install
    success = []
    # Check if all fonts already exist
    filesExist = true
    dest = self.getFontFolder
    for i in 0...Names.size
      filesExist = false if !safeExists?(dest + Filenames[i])
    end
    return if filesExist
    # Check if all source fonts exist
    exist = true
    for i in 0...Names.size
      if !RTP.exists?(Source + Filenames[i])
        exist = false
        break
      end
    end
    return if !exist # Exit if not all source fonts exist
    pbMessage(_INTL("One or more fonts used in this game do not exist on the system.\1"))
    pbMessage(_INTL("The game can be played, but the look of the game's text will not be optimal."))
    failed = false
    for i in 0...Filenames.size
      f = Filenames[i]
      if safeExists?(dest + f) && !Font.exist?(Names[i])
        File.delete(dest + f) rescue nil
      end
      # check if already installed...
      if not safeExists?(dest + f)
        # check to ensure font is in specified location...
        if RTP.exists?(Source + f)
          # copy file to fonts folder
          succeeded = false
          begin
            copy_file(pbResolveFont(f), dest + f)
            # add font resource
            AFR.call(dest + f)
            # add entry to win.ini/registry
            WPS.call('Fonts', Names[i] + ' (TrueType)', f)
            succeeded = safeExists?(dest + f)
          rescue SystemCallError
            # failed
            succeeded = false
          end
          if succeeded
            success.push(Names[i])
          else
            failed = true
          end
        end
      else
        success.push(Names[i]) # assume success
      end
    end
    if success.length>0 # one or more fonts successfully installed
      SM.call(HWND_BROADCAST,WM_FONTCHANGE,0,0)
      if Notify
        fonts = ''
        success.each do |f|
          fonts << f << ', '
        end
        if failed
          pbMessage(_INTL("Some of the fonts were successfully installed.\1"))
          pbMessage(_INTL("To install the other fonts, copy the files in this game's Fonts folder to the Fonts folder in Control Panel.\1"))
        else
          pbMessage(_INTL("The fonts were successfully installed.\1"))
        end
        if pbConfirmMessage(_INTL("Would you like to restart the game and apply the changes?"))
          a = Thread.new { system('Game') }
          exit
        end
      end
    else
      # No fonts were installed.
      pbMessage(_INTL("To install the necessary fonts, copy the files in this game's Fonts folder to the Fonts folder in Control Panel."))
    end
  end
end
