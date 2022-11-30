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
  return Scene_Intro.new
end

def mainFunction
  if $DEBUG
    pbCriticalCode { mainFunctionDebug }
  else
    mainFunctionDebug
  end
  return 1
end

def sortCustomBattlers()
  customBattlersFolder = 'Graphics/CustomBattlers'
  echo "Sorting CustomBattlers files..."
  Dir.foreach(customBattlersFolder) do |filename|
    next if filename == '.' or filename == '..'
    next if !filename.end_with?(".png")
    headNum = filename.split('.')[0]
    oldPath = customBattlersFolder + "/" + filename
    newPath = customBattlersFolder + "/" + headNum.to_s + "/" +filename
    echo "\n"
    echo "Sorted " + filename + " into " + newPath
    begin
      File.rename(oldPath, newPath)
    rescue
      echo "Could not sort "+ filename
    end
  end
end


def mainFunctionDebug
  begin
    sortCustomBattlers()
    MessageTypes.loadMessageFile("Data/messages.dat") if safeExists?("Data/messages.dat")
    PluginManager.runPlugins
    Compiler.main
    Game.initialize
    Game.set_up_system
    Graphics.update
    Graphics.freeze
    $scene = pbCallTitle
    $scene.main until $scene.nil?
    Graphics.transition(20)
  rescue Hangup
    pbPrintException($!) if !$DEBUG
    pbEmergencySave
    raise
  end
end

loop do
  retval = mainFunction
  if retval == 0   # failed
    loop do
      Graphics.update
    end
  elsif retval == 1   # ended successfully
    break
  end
end
