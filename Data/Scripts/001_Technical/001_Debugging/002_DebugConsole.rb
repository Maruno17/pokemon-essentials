# To use the console, use the executable explicitly built
# with the console enabled on Windows. On Linux and macOS,
# just launch the executable directly from a terminal.
module Console
  def self.setup_console
    return unless $DEBUG
    echoln "--------------------------------"
    echoln "#{System.game_title} Output Window"
    echoln "--------------------------------"
    echoln "If you are seeing this window, you are running"
    echoln "#{System.game_title} in Debug Mode. This means"
    echoln "that you're either playing a Debug Version, or"
    echoln "you are playing from within RPG Maker XP."
    echoln ""
    echoln "Closing this window will close the game. If"
    echoln "you want to get rid of this window, run the"
    echoln "program from the Shell, or download a Release"
    echoln "version."
    echoln ""
    echoln "--------------------------------"
    echoln "Debug Output:"
    echoln "--------------------------------"
    echoln ""
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
    return unless $DEBUG
    printf(string.is_a?(String) ? string : string.inspect)
  end

  def echoln(string)
    echo(string)
    echo("\r\n")
  end
end

Console.setup_console
