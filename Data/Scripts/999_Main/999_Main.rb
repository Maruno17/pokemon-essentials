pbCompiler



class Scene_DebugIntro
  def main
    Graphics.transition(0)
    sscene = PokemonLoad_Scene.new
    sscreen = PokemonLoadScreen.new(sscene)
    sscreen.pbStartLoadScreen
    Graphics.freeze
  end
end



def pbCallTitle
  return Scene_DebugIntro.new if $DEBUG
  # First parameter is an array of images in the Titles
  # directory without a file extension, to show before the
  # actual title screen.  Second parameter is the actual
  # title screen filename, also in Titles with no extension.
  return Scene_Intro.new(['intro1'], 'splash')
end

def mainFunction
  if $DEBUG
    pbCriticalCode { mainFunctionDebug }
  else
    mainFunctionDebug
  end
  return 1
end

def mainFunctionDebug
  begin
    getCurrentProcess = Win32API.new("kernel32.dll","GetCurrentProcess","","l")
    setPriorityClass  = Win32API.new("kernel32.dll","SetPriorityClass",%w(l i),"")
    setPriorityClass.call(getCurrentProcess.call(),32768)   # "Above normal" priority class
    $data_animations    = pbLoadRxData("Data/Animations")
    $data_tilesets      = pbLoadRxData("Data/Tilesets")
    $data_common_events = pbLoadRxData("Data/CommonEvents")
    $data_system        = pbLoadRxData("Data/System")
    $game_system        = Game_System.new
    setScreenBorderName("border")   # Sets image file for the border
    Graphics.update
    Graphics.freeze
    $scene = pbCallTitle
    while $scene!=nil
      $scene.main
    end
    Graphics.transition(20)
  rescue Hangup
    pbPrintException($!) if !$DEBUG
    pbEmergencySave
    raise
  end
end

loop do
  retval = mainFunction
  if retval==0   # failed
    loop do
      Graphics.update
    end
  elsif retval==1   # ended successfully
    break
  end
end