# TODO: This code is incomplete, in that all the MenuHandlers for the pause menu
#       assume the visuals class has def pbRefresh, def pbEndScene, def
#       pbHideMenu and def pbShowMenu.

#===============================================================================
#
#===============================================================================
class UI::PauseMenuVisuals < UI::BaseUIVisuals
  def initialize
    @info_state = false
    # @help_state = false
    super
  end

  def initialize_background; end
  def initialize_overlay; end

  def initialize_sprites
    # Pause menu
    @sprites[:commands] = Window_CommandPokemon.new([])
    @sprites[:commands].visible = false
    @sprites[:commands].viewport = @viewport
    # Info text box
    @sprites[:info_text] = Window_UnformattedTextPokemon.newWithSize("", 0, 0, 32, 32, @viewport)
    @sprites[:info_text].visible = false
    # Help text box
    # @sprites[:help_text] = Window_UnformattedTextPokemon.newWithSize("", 0, 0, 32, 32, @viewport)
    # @sprites[:help_text].visible = false
  end

  #-----------------------------------------------------------------------------

  # commands is [[command IDs], [command names]].
  def set_commands(commands)
    @commands = commands
    cmd_window = @sprites[:commands]
    cmd_window = @commands[1]
    cmd_window.index    = $game_temp.menu_last_choice
    cmd_window.resizeToFit(@commands)
    cmd_window.x        = Graphics.width - cmd_window.width
    cmd_window.y        = 0
    cmd_window.visible  = true
  end

  #-----------------------------------------------------------------------------

  def show_menu
    @sprites[:commands].visible = true
    @sprites[:info_text].visible = @info_state
    # @sprites[:help_text].visible = @help_state
  end

  def hide_menu
    @sprites[:commands].visible = false
    @sprites[:info_text].visible = false
    # @sprites[:help_text].visible = false
  end

  # Used in Safari Zone and Bug-Catching Contest to show extra information.
  def show_info(text)
    @sprites[:info_text].resizeToFit(text, Graphics.height)
    @sprites[:info_text].text    = text
    @sprites[:info_text].visible = true
    @info_state = true
  end

  # Unused.
  # def show_help(text)
  #   @sprites[:help_text].resizeToFit(text, Graphics.height)
  #   @sprites[:help_text].text    = text
  #   @sprites[:help_text].visible = true
  #   pbBottomLeft(@sprites[:help_text])
  #   @help_state = true
  # end

  #-----------------------------------------------------------------------------

  def update_visuals
    pbUpdateSceneMap
    super
  end

  def update_input
    if Input.trigger?(Input::BACK) || Input.trigger?(Input::ACTION)
      return :quit
    end
    if Input.trigger?(Input::USE)
      idx = @sprites[:commands].index
      return @commands[0][idx]
    end
    return nil
  end
end

#===============================================================================
#
#===============================================================================
class UI::PauseMenuScreen < UI::BaseUIScreen
  def initialize
    raise _INTL("Tried to open the pause menu when $player was not defined.") if !$player
    initialize_commands
    super
  end

  def initialize_commands
    @commands ||= [[], []]
    @commands.clear
    @commands_hashes ||= {}
    @commands_hashes.clear
    MenuHandlers.each_available(:pause_menu) do |option, hash, name|
      @commands[0].push(option)
      @commands[1].push(name)
      @commands_hashes[option] = hash
    end
  end

  def initialize_visuals
    @visuals = UI::PauseMenuVisuals.new
    @visuals.set_commands(@commands)
  end

  def start_screen
    pbSEPlay("GUI menu open")
  end

  def end_screen
    pbPlayCloseMenuSE if !@silent_quit
    @visuals.dispose
  end

  #-----------------------------------------------------------------------------

  def perform_action(command)
    if @commands_hashes[command]["effect"].call(@visuals)
      @silent_quit = true
      return :quit
    end
    return nil
  end
end
