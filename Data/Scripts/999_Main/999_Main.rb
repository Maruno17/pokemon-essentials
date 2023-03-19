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
  commands << "Do not import the new sprites"
  commands << "Replace all the old sprites with the new ones"
  #commands << "Import all the new sprites as alts"

  messageSingular = "While importing custom sprites, the game has detected that {1} new custom sprite already has a version that exist in the game."
  messagePlural = "While importing custom sprites, the game has detected that {1} new custom sprites already have versions that exist in the game."

  messageText = spritesToReplaceList.size==1 ? messageSingular : messagePlural
  message = _INTL(messageText,spritesToReplaceList.length.to_s)
  pbMessage(message)

  command = pbMessage("What to do with the new sprites?",commands,commands.size-1)
  case command
  when 0 #Do not import
    pbMessage("You can manually sort the new sprites in the /indexed folder to choose which ones you want to keep.")
    pbMessage("You can also delete the ones you don't want to replace the main sprites and restart the game.")
    pbMessage("Keep in mind that the game will take longer to load until these sprites are imported/removed.")

    return
  when 1 #Replace olds
    spritesToReplaceList.each do |oldPath, newPath|
      File.rename(oldPath, newPath)
      $game_temp.nb_imported_sprites+=1
      echo "\nSorted " + oldPath + " into " + newPath
    end
    #when 2 #Keep olds (rename new as alts)
  end
end

def pbCallTitle
  #return Scene_DebugIntro.new if $DEBUG
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

def clearTempFolder()
  folder_path = Settings::DOWNLOADED_SPRITES_FOLDER
  Dir.foreach(folder_path) do |file|
    next if file == '.' or file == '..'
    file_path = File.join(folder_path, file)
    File.delete(file_path) if File.file?(file_path)
  end
end

def sortCustomBattlers()
  $game_temp.nb_imported_sprites=0
  echo "Sorting CustomBattlers files..."
  alreadyExists = {}
  Dir.foreach(Settings::CUSTOM_BATTLERS_FOLDER) do |filename|
    next if filename == '.' or filename == '..'
    next if !filename.end_with?(".png")
    headNum = filename.split('.')[0]
    oldPath = Settings::CUSTOM_BATTLERS_FOLDER + filename
    newPath = Settings::CUSTOM_BATTLERS_FOLDER_INDEXED + headNum.to_s + "/" + filename
    begin
      if File.file?(newPath)
        alreadyExists[oldPath] = newPath
        echo "\nFile " + newPath + " already exists... Skipping."

      else
        File.rename(oldPath, newPath)
        $game_temp.nb_imported_sprites+=1
        echo "\nSorted " + filename + " into " + newPath
      end
    rescue
      echo "\nCould not sort "+ filename
    end
  end
  echo "\nFinished sorting"
  $game_temp.unimportedSprites=alreadyExists
end

# def playInViewPort(viewport)
#   @finished=false
#   @currentFrame = 1
#   @initialTime = Time.now
#   @timeElapsed = Time.now
#
#   pbBGMPlay(@bgm)
#   while (@currentFrame <= @maxFrame)# && !(@canStopEarly && Input::ACTION))
#     break if Input.trigger?(Input::C) && @canStopEarly
#     frame = sprintf(@framesPath, @currentFrame)
#     picture = Sprite.new(viewport)
#     picture.bitmap = pbBitmap(frame)
#     picture.visible=true
#     pbWait(Graphics.frame_rate / 20)
#     picture.dispose
#     @currentFrame += 1
#   end
#   @finished=true
#   pbBGMStop
# end


def showLoadingScreen
     intro_frames_path = "Graphics\\titles\\loading_screen"
     picture = Sprite.new(@viewport)
     picture.bitmap = pbBitmap(intro_frames_path)
     picture.visible=true
     pbWait(Graphics.frame_rate / 20)
     picture.dispose
end


def showLoadMovie
  path = "Graphics\\Pictures\\introMarill"
  loading_screen = Sprite.new(@viewport)
  loading_screen.bitmap = pbBitmap(path)
  loading_screen.visible=true
end

def mainFunctionDebug
  begin
    showLoadingScreen
    MessageTypes.loadMessageFile("Data/messages.dat") if safeExists?("Data/messages.dat")
    PluginManager.runPlugins
    Compiler.main
    Game.initialize
    Game.set_up_system
    Graphics.update
    Graphics.freeze
    #clearTempFolder()
    begin
      sortCustomBattlers()
    rescue
      echo "failed to sort custom battlers"
    end
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
