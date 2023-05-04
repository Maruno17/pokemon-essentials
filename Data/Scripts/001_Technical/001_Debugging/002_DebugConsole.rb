# To use the console, use the executable explicitly built with the console
# enabled on Windows. On Linux and macOS, just launch the executable directly
# from a terminal.
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
    echo "\n"
  end
end

Console.setup_console

#===============================================================================
#  Console message formatting
#===============================================================================
module Console
  module_function

  #-----------------------------------------------------------------------------
  #  echo string into console (example shorthand for common options)
  #-----------------------------------------------------------------------------
  # heading 1
  def echo_h1(msg)
    echoln markup_style("*** #{msg} ***", text: :brown)
    echoln ""
  end

  # heading 2
  def echo_h2(msg, **options)
    echoln markup_style(msg, **options)
    echoln ""
  end

  # heading 3
  def echo_h3(msg)
    echoln markup(msg)
    echoln ""
  end

  # list item
  def echo_li(msg, pad = 0, color = :brown)
    echo markup_style("  -> ", text: color)
    pad = (pad - msg.length) > 0 ? "." * (pad - msg.length) : ""
    echo markup(msg + pad)
  end

  # list item with line break after
  def echoln_li(msg, pad = 0, color = :brown)
    self.echo_li(msg, pad, color)
    echoln ""
  end

  # Same as echoln_li but text is in green
  def echoln_li_done(msg)
    self.echo_li(markup_style(msg, text: :green), 0, :green)
    echoln ""
    echoln ""
  end

  # paragraph with markup
  def echo_p(msg)
    echoln markup(msg)
  end

  # warning message
  def echo_warn(msg)
    echoln markup_style("WARNING: #{msg}", text: :yellow)
  end

  # error message
  def echo_error(msg)
    echoln markup_style("ERROR: #{msg}", text: :light_red)
  end

  # status output
  def echo_status(status)
    if status
      echoln markup_style("OK", text: :green)
    else
      echoln markup_style("FAIL", text: :red)
    end
  end

  # completion output
  def echo_done(status)
    if status
      echoln markup_style("done", text: :green)
    else
      echoln markup_style("error", text: :red)
    end
  end

  #-----------------------------------------------------------------------------
  # Markup options
  #-----------------------------------------------------------------------------
  def string_colors
    {
      default: "38", black: "30", red: "31", green: "32", brown: "33",
      blue: "34", purple: "35", cyan: "36", gray: "37",
      dark_gray: "1;30", light_red: "1;31", light_green: "1;32", yellow: "1;33",
      light_blue: "1;34", light_purple: "1;35", light_cyan: "1;36", white: "1;37"
    }
  end

  def background_colors
    {
      default: "0", black: "40", red: "41", green: "42", brown: "43",
      blue: "44", purple: "45", cyan: "46", gray: "47",
      dark_gray: "100", light_red: "101", light_green: "102", yellow: "103",
      light_blue: "104", light_purple: "105", light_cyan: "106", white: "107"
    }
  end

  def font_options
    {
      bold: "1", dim: "2", italic: "3", underline: "4", reverse: "7",
      hidden: "8"
    }
  end

  # Text markup that turns text between them a certain color
  def markup_colors
    {
      "`" => :cyan, '"' => :purple, "==" => :purple, "$" => :green, "~" => :red
    }
  end

  def markup_options
    {
      "__" => :underline, "*" => :bold, "|" => :italic
    }
  end

  # apply console coloring
  def markup_style(string, text: :default, bg: :default, **options)
    # get colors
    code_text = string_colors[text]
    code_bg   = background_colors[bg]
    # get options
    options_pool = options.select { |key, val| font_options.key?(key) && val }
    markup_pool  = options_pool.keys.map { |opt| font_options[opt] }.join(";").squeeze
    # return formatted string
    return "\e[#{code_bg};#{markup_pool};#{code_text}m#{string}\e[0m".squeeze(";")
  end

  #-----------------------------------------------------------------------------
  # Perform markup on text
  #-----------------------------------------------------------------------------

  def markup_all_options
    @markup_all_options ||= markup_colors.merge(markup_options)
  end

  def markup_component(string, component, key, options)
    # trim inner markup content
    l = key.length
    trimmed = component[l...-l]
    # merge markup options
    options[trimmed] = {} unless options[trimmed]
    options[trimmed].deep_merge!({}.tap do |new_opt|
      new_opt[:text] = markup_colors[key] if markup_colors.key?(key)
      new_opt[markup_options[key]] = true if markup_options.key?(key)
    end)
    # remove markup from input string
    string.gsub!(component, trimmed)
    # return output
    return string, options
  end

  def markup_breakdown(string, options = {})
    # iterate through all options
    markup_all_options.each_key do |key|
      # ensure escape
      key_char = key.chars.map { |c| "\\#{c}" }.join
      # define regex
      regex = "#{key_char}.*?#{key_char}"
      # go through matches
      string.scan(/#{regex}/).each do |component|
        return *markup_breakdown(*markup_component(string, component, key, options))
      end
    end
    # return output
    return string, options
  end

  def markup(string)
    # get a breakdown of all markup options
    string, options = markup_breakdown(string)
    # iterate through each option and apply
    options.each do |key, opt|
      string.gsub!(key, markup_style(key, **opt))
    end
    # return string
    return string
  end
end
