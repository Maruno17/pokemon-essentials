# To use the console, use the executable explicitly built
# with the console enabled on Windows. On Linux and macOS,
# just launch the executable directly from a terminal.
module Console
  def self.setup_console
    return unless $DEBUG
    echo "#{System.game_title} Output Window\n"
    echo "-------------------------------\n"
    echo "If you are seeing this window, you are running\n"
    echo "#{System.game_title} in Debug Mode. This means\n"
    echo "that you're either playing a Debug Version, or\n"
    echo "you are playing from within RPG Maker XP.\n"
    echo "\n"
    echo "Closing this window will close the game. If \n"
    echo "you want to get rid of this window, run the\n"
    echo "program from the Shell, or download a Release\n"
    echo "version.\n"
    echo "\n"
    echo "Gameplay will be paused while the console has\n"
    echo "focus. To resume playing, switch to the Game\n"
    echo "Window.\n"
    echo "-------------------------------\n"
    echo "Debug Output:\n"
    echo "-------------------------------\n\n"
  end

  def self.readInput
    return gets.strip
  end

  def self.readInput2
    return self.readInput
  end

  def self.get_input
    echo self.readInput2
  end
end



module Kernel
  def echo(string)
    unless $DEBUG
      return
    end
    printf(string.is_a?(String) ? string : string.inspect)
  end

  def echoln(string)
    echo(string)
    echo("\r\n")
  end
end
