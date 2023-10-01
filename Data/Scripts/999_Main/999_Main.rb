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

def mainFunctionDebug
  begin
    MessageTypes.load_default_messages if FileTest.exist?("Data/messages_core.dat")
    if $DEBUG && !FileTest.exist?("Game.rgssad") && Settings::PROMPT_TO_COMPILE
      pbSetResizeFactor(1)   # Needed to make the message look good
      if pbConfirmMessage("\\ts[]" + "Do you want to compile your data and plugins?")
        $full_compile = true
      end
    end
    PluginManager.runPlugins
    Compiler.main
    Game.initialize
    Game.set_up_system
    Graphics.update
    Graphics.freeze
    $scene = pbCallTitle
    $scene.main until $scene.nil?
    Graphics.transition
  rescue Hangup
    pbPrintException($!) if !$DEBUG
    pbEmergencySave
    raise
  end
end

loop do
  retval = mainFunction
  case retval
  when 0   # failed
    loop do
      Graphics.update
    end
  when 1   # ended successfully
    break
  end
end
