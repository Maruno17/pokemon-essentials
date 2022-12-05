class Scene_DebugIntro
  def main
    Graphics.transition(0)
    sscene = PokemonLoad_Scene.new
    sscreen = PokemonLoadScreen.new(sscene)
    sscreen.pbStartLoadScreen
    Graphics.freeze
  end
end

def handleReplaceExistingSprites()
  spritesToReplaceList= $game_temp.unimportedSprites
  $game_temp.unimportedSprites=nil
  return if spritesToReplaceList.size==0
  commands = []
  #commands << "Pick which sprites to use as mains"
  commands << "Replace all the old sprites with the new ones"
  #commands << "Import all the new sprites as alts"
  commands << "Do not import the new sprites"

  messageSingular = "While importing custom sprites, the game has detected that {1} new custom sprite already has a version that exist in the game."
  messagePlural = "While importing custom sprites, the game has detected that {1} new custom sprites already have versions that exist in the game."

  messageText = spritesToReplaceList.size==1 ? messageSingular : messagePlural
  message = _INTL(messageText,spritesToReplaceList.length.to_s)
  pbMessage(message)

  command = pbMessage("What to do with the new sprites?",commands,commands.size-1)
  case command
  when 0 #Replace olds
    spritesToReplaceList.each do |oldPath, newPath|
      File.rename(oldPath, newPath)
      echo "\nSorted " + oldPath + " into " + newPath
    end
    #when 1 #Keep olds (rename new as alts)
  when 1 #Do not import
    pbMessage("You can manually sort the new sprites in the /indexed folder to choose which ones you want to keep.")
    return
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
  alreadyExists = {}
  Dir.foreach(Settings::CUSTOM_BATTLERS_FOLDER) do |filename|
    next if filename == '.' or filename == '..'
    next if !filename.end_with?(".png")
    headNum = filename.split('.')[0]
    oldPath = Settings::CUSTOM_BATTLERS_FOLDER + "/" + filename
    newPath = Settings::CUSTOM_BATTLERS_FOLDER_INDEXED + "/" + headNum.to_s + "/" +filename
    begin
      if File.file?(newPath)
        alreadyExists[oldPath] = newPath
        echo "\nFile " + newPath + " already exists... Skipping."

      else
        File.rename(oldPath, newPath)
        echo "\nSorted " + filename + " into " + newPath
      end
    rescue
      echo "\nCould not sort "+ filename
    end
  end
  echo "\nFinished sorting"
  $game_temp.unimportedSprites=alreadyExists
end


def mainFunctionDebug
  begin
    MessageTypes.loadMessageFile("Data/messages.dat") if safeExists?("Data/messages.dat")
    PluginManager.runPlugins
    Compiler.main
    Game.initialize
    Game.set_up_system
    Graphics.update
    Graphics.freeze
    sortCustomBattlers()

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
