# Loads data from a file "safely", similar to load_data. If an encrypted archive
# exists, the real file is deleted to ensure that the file is loaded from the
# encrypted archive.
def pbSafeLoad(file)
  if (safeExists?("./Game.rgssad") || safeExists?("./Game.rgss2a")) && safeExists?(file)
    File.delete(file) rescue nil
  end
  return load_data(file)
end

def pbLoadRxData(file) # :nodoc:
  if $RPGVX
    return load_data(file+".rvdata")
  else
    return load_data(file+".rxdata")
  end
end

def pbChooseLanguage
  commands=[]
  for lang in LANGUAGES
    commands.push(lang[0])
  end
  return pbShowCommands(nil,commands)
end

if !respond_to?("pbSetResizeFactor")
  def pbSetResizeFactor(dummy,dummy2=false); end
  def setScreenBorderName(border); end

  $ResizeFactor    = 1.0
  $ResizeFactorMul = 100
  $ResizeOffsetX   = 0
  $ResizeOffsetY   = 0
  $ResizeFactorSet = false

  module Graphics
    def self.snap_to_bitmap; return nil; end
  end
end


#############
#############


def pbSetUpSystem
  begin
    trainer       = nil
    framecount    = 0
    game_system   = nil
    pokemonSystem = nil
    havedata = false
    File.open(RTP.getSaveFileName("Game.rxdata")) { |f|
      trainer       = Marshal.load(f)
      framecount    = Marshal.load(f)
      game_system   = Marshal.load(f)
      pokemonSystem = Marshal.load(f)
    }
    raise "Corrupted file" if !trainer.is_a?(PokeBattle_Trainer)
    raise "Corrupted file" if !framecount.is_a?(Numeric)
    raise "Corrupted file" if !game_system.is_a?(Game_System)
    raise "Corrupted file" if !pokemonSystem.is_a?(PokemonSystem)
    havedata = true
  rescue
    game_system   = Game_System.new
    pokemonSystem = PokemonSystem.new
  end
  if !$INEDITOR
    $game_system   = game_system
    $PokemonSystem = pokemonSystem
    pbSetResizeFactor([$PokemonSystem.screensize,3].min)
  else
    pbSetResizeFactor(1.0)
  end
  # Load constants
  begin
    consts = pbSafeLoad("Data/Constants.rxdata")
    consts = [] if !consts
  rescue
    consts = []
  end
  for script in consts
    next if !script
    eval(Zlib::Inflate.inflate(script[2]),nil,script[1])
  end
  if LANGUAGES.length>=2
    pokemonSystem.language = pbChooseLanguage if !havedata
    pbLoadMessages("Data/"+LANGUAGES[pokemonSystem.language][1])
  end
end

def pbScreenCapture
  t = pbGetTimeNow
  filestart = t.strftime("[%Y-%m-%d] %H_%M_%S")
  filestart = sprintf("%s.%03d",filestart,(t.to_f-t.to_i)*1000)   # milliseconds
  capturefile = RTP.getSaveFileName(sprintf("%s.png",filestart))
  if capturefile && safeExists?("rubyscreen.dll")
    Graphics.snap_to_bitmap(false).saveToPng(capturefile)
    pbSEPlay("Pkmn exp full") if FileTest.audio_exist?("Audio/SE/Pkmn exp full")
  end
end

def pbDebugF7
  if $DEBUG
    Console::setup_console
    begin
      debugBitmaps
    rescue
    end
    pbSEPlay("Pkmn exp full") if FileTest.audio_exist?("Audio/SE/Pkmn exp full")
  end
end



module Input
  unless defined?(update_KGC_ScreenCapture)
    class << Input
      alias update_KGC_ScreenCapture update
    end
  end

  def self.update
    update_KGC_ScreenCapture
    if trigger?(Input::F8)
      pbScreenCapture
    end
    if trigger?(Input::F7)
      pbDebugF7
    end
  end
end



pbSetUpSystem
