class Scene_DebugIntro
  attr_accessor :map_renderer
  def main
    Graphics.transition(0)
    sscene = PokemonLoad_Scene.new
    sscreen = PokemonLoadScreen.new(sscene)
    sscreen.pbStartLoadScreen
    Graphics.freeze
  end
end

def resetPlayerPosition
  save_data = load_save_file(SaveData::FILE_PATH)
  map = save_data[:map_factory].map.map_id
  x = save_data[:game_player].x
  y = save_data[:game_player].y
  dir = save_data[:game_player].direction
  $MapFactory.setup(map)
  $game_player.moveto(x,y)
  $game_player.direction = dir
end


def load_save_file(file_path)
  save_data = SaveData.read_from_file(file_path)
  unless SaveData.valid?(save_data)
    if File.file?(file_path + '.bak')
      pbMessage(_INTL('The save file is corrupt. A backup will be loaded.'))
      save_data = load_save_file(file_path + '.bak')
    else
      self.prompt_save_deletion
      return {}
    end
  end
  return save_data
end

def returnToTitle()
  resetPlayerPosition
  pbMapInterpreter.command_end
  $game_temp.to_title = true
end

def pbCallTitle
  $game_temp.to_title = false
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

def mainFunctionDebug
  begin
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
