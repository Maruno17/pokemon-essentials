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
  echo "Sorting CustomBattlers files..."
  Dir.foreach(Settings::CUSTOM_BATTLERS_FOLDER) do |filename|
    next if filename == '.' or filename == '..'
    next if !filename.end_with?(".png")
    headNum = filename.split('.')[0]
    oldPath = Settings::CUSTOM_BATTLERS_FOLDER + "/" + filename
    newPath = Settings::CUSTOM_BATTLERS_FOLDER_INDEXED + "/" + headNum.to_s + "/" +filename
    begin
      File.rename(oldPath, newPath)
      echo "\nSorted " + filename + " into " + newPath
    rescue
      echo "\nCould not sort "+ filename
    end
  end
  echo "\nFinished sorting"
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
