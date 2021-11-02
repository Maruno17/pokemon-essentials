# To use the console, use the executable explicitly built
# with the console enabled on Windows. On Linux and macOS,
# just launch the executable directly from a terminal.
module Console
  def self.setup_console
    return unless $DEBUG
    echoln "GPU Cache Max: #{Bitmap.max_size}"
    echoln "-------------------------------------------------------------------------------"
    echoln "#{System.game_title} Output Window"
    echoln "-------------------------------------------------------------------------------"
    echoln "If you can see this window, you are running the game in Debug Mode. This means"
    echoln "that you're either playing a debug version of the game, or you're playing from"
    echoln "within RPG Maker XP."
    echoln ""
    echoln "Closing this window will close the game. If you want to get rid of this window,"
    echoln "run the program from the Shell, or download a release version of the game."
    echoln ""
    echoln "-------------------------------------------------------------------------------"
    echoln "Debug Output:"
    echoln "-------------------------------------------------------------------------------"
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
    echo string
    echo "\r\n"
  end
end

Console.setup_console

#===============================================================================
#  Console message formatting
#===============================================================================
module ConsoleRGB
  # string colors
  CMD_COLORS = {
    default: '38', black: '30', red: '31', green: '32', brown: '33', blue: '34',
    purple: '35', cyan: '36', gray: '37',
    dark_gray: '1;30', light_red: '1;31', light_green: '1;32', yellow: '1;33',
    light_blue: '1;34', light_purple: '1;35', light_cyan: '1;36', white: '1;37'
  }
  # background colors
  CMD_BG_COLORS = {
    default: '0', black: '40', red: '41', green: '42', brown: '43', blue: '44',
    purple: '45', cyan: '46', gray: '47',
    dark_gray: '100', light_red: '101', light_green: '102', yellow: '103',
    light_blue: '104', light_purple: '105', light_cyan: '106', white: '107'
  }
  # font options
  CMD_FONT_OPTIONS = {
    bold: '1', dim: '2', italic: '3', underline: '4', reverse: '7', hidden: '8'
  }
  # syntax highlighting based on markup
  CMD_SYNTAX_COLOR = {
    '`' => :cyan, '"' => :purple, "'" => :purple, '$' => :green, '~' => :red
  }
  # syntax options based on markup
  CMD_SYNTAX_OPTIONS = {
    '*' => :bold, '|' => :italic, '__' => :underline
  }

  #-----------------------------------------------------------------------------
  #  apply console coloring
  #-----------------------------------------------------------------------------
  def self.colors(string, text: :default, bg: :default, **options)
    # get colors
    code_text = CMD_COLORS[text]
    code_bg   = CMD_BG_COLORS[bg]
    # get options
    option_pool = options.select { |key, val| CMD_FONT_OPTIONS.key?(key) && val }
    font_options = option_pool.keys.map { |opt| CMD_FONT_OPTIONS[opt] }.join(';').squeeze
    # return formatted string
    return "\e[#{code_bg};#{font_options};#{code_text}m#{string}\e[0m".squeeze(';')
  end

  #-----------------------------------------------------------------------------
  #  character markup to color mapping for console
  #-----------------------------------------------------------------------------
  # component level
  def self.markup_component(string, options = {})
    # syntax markup format options
    [CMD_SYNTAX_COLOR, CMD_SYNTAX_OPTIONS].each_with_index do |hash, i|
      hash.each do |key, value|
        l = key.length
        # ensure escape
        key = key.chars.map { |c| "\\#{c}" }.join
        # define regex
        regex = "#{key}.*?#{key}"
        # match markup
        string.scan(/#{regex}/).each do |cpt|
          options[i == 0 ? :text : value] = i == 0 ? value : true
          options, string = self.markup_component(cpt[l...-l], options)
        end
      end
    end
    return options, string
  end

  # full string
  def self.markup(string)
    final_options = {}
    (CMD_SYNTAX_COLOR.merge(CMD_SYNTAX_OPTIONS)).each_key do |key|
      # ensure escape
      key = key.chars.map { |c| "\\#{c}" }.join
      # define regex
      regex = "#{key}.*?#{key}"
      string.scan(/#{regex}/).each do |cpt|
        options, clean = self.markup_component(cpt)
        if final_options[clean]
          final_options[clean].deep_merge!(options)
        else
          final_options[clean] = options.clone
        end
        string.gsub!(cpt, clean)
      end
    end
    # iterate through final options and apply them
    final_options.each do |key, opt|
      string.gsub!(key, self.colors(key, **opt))
    end
    return string
  end

  #-----------------------------------------------------------------------------
  #  echo string into console (example short hand for common options)
  #-----------------------------------------------------------------------------
  # heading 1
  def self.echo_h1(msg)
    echoln ConsoleRGB.colors("*** #{msg} ***\r\n", text: :brown)
  end

  # heading 2
  def self.echo_h2(msg, **options)
    echoln ConsoleRGB.colors("#{msg}\r\n", **options)
  end

  # heading 3
  def self.echo_h3(msg)
    echoln ConsoleRGB.markup("#{msg}\r\n")
  end

  # list item
  def self.echo_li(msg)
    echo ConsoleRGB.colors("  -> ", text: :brown)
    echo ConsoleRGB.markup(msg)
  end

  # list item (ends the line)
  def self.echoln_li(msg)
    self.echo_li(msg + "\r\n")
  end

  # paragraph with markup
  def self.echo_p(msg)
    echoln ConsoleRGB.markup(msg)
  end

  # warning message
  def self.echo_warn(msg)
    echoln ConsoleRGB.colors("WARNING: " + msg, text: :yellow)
  end

  # error message
  def self.echo_error(msg)
    echoln ConsoleRGB.colors("ERROR: " + msg, text: :light_red)
  end

  # status output
  def self.echo_status(status)
    echoln status ? ConsoleRGB.colors('OK', text: :green) : ConsoleRGB.colors('FAIL', text: :red)
  end

  # completion output
  def self.echo_complete(status)
    echoln status ? ConsoleRGB.colors('done', text: :green) : ConsoleRGB.colors('error', text: :red)
  end
end
