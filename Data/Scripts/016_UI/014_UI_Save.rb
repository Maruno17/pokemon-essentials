#===============================================================================
#
#===============================================================================
class UI::SavePanel < UI::SpriteContainer
  attr_reader :sprites

  GRAPHICS_FOLDER = "Save/"
  TEXT_COLOR_THEMES = {   # Themes not in DEFAULT_TEXT_COLOR_THEMES
    :white  => [Color.new(248, 248, 248), Color.new(172, 188, 188)],
    :male   => [Color.new(0, 112, 248), Color.new(120, 184, 232)],
    :female => [Color.new(232, 32, 16), Color.new(248, 168, 184)]
  }
  PANEL_WIDTH  = 384
  PANEL_HEIGHT = 204

  def initialize(save_data, viewport)
    @save_data = save_data
    @show_arrows = false
    super(viewport)
    refresh
  end

  def initialize_sprites
    initialize_panel_background
    initialize_overlay
    initialize_player_sprite
    initialize_pokemon_icons
    initialize_arrow_sprites
  end

  def initialize_panel_background
    @sprites[:background] = ChangelingSprite.new(0, 0, @viewport)
    panel_srcs.each_pair do |key, values|
      @sprites[:background].add_bitmap(key, values)
    end
    @sprites[:background].change_bitmap(:default)
    record_values(:background)
  end

  def initialize_overlay
    add_overlay(:overlay, @sprites[:background].width, @sprites[:background].height)
    @sprites[:overlay].z = 10
    record_values(:overlay)
  end

  def initialize_player_sprite
    meta = GameData::PlayerMetadata.get(@save_data[:player].character_ID)
    filename = pbGetPlayerCharset(meta.walk_charset, @save_data[:player], true)
    @sprites[:player] = TrainerWalkingCharSprite.new(filename, @viewport)
    if !@sprites[:player].bitmap
      raise _INTL("Player character {1}'s walking charset was not found (filename: \"{2}\").",
                  @save_data[:player].character_ID, filename)
    end
    @sprites[:player].x = 44 - (@sprites[:player].bitmap.width / 8)
    @sprites[:player].y = 36 - (@sprites[:player].bitmap.height / 8)
    @sprites[:player].z = 1
    record_values(:player)
  end

  def initialize_pokemon_icons
    Settings::MAX_PARTY_SIZE.times do |i|
      @sprites["pokemon_#{i}"] = PokemonIconSprite.new(@save_data[:player].party[i], @viewport)
      @sprites["pokemon_#{i}"].x, @sprites["pokemon_#{i}"].y = pokemon_coords(i)
      @sprites["pokemon_#{i}"].z = 1
      @sprites["pokemon_#{i}"].setOffset
      record_values("pokemon_#{i}")
    end
  end

  def initialize_arrow_sprites
    @sprites[:left_arrow] = AnimatedSprite.new(UI_FOLDER + "left_arrow", 8, 40, 28, 2, @viewport)
    @sprites[:left_arrow].x = -16
    @sprites[:left_arrow].y = (height / 2) - 14
    @sprites[:left_arrow].z = 20
    @sprites[:left_arrow].visible = false
    @sprites[:left_arrow].play
    record_values(:left_arrow)
    @sprites[:right_arrow] = AnimatedSprite.new(UI_FOLDER + "right_arrow", 8, 40, 28, 2, @viewport)
    @sprites[:right_arrow].x = width - 24
    @sprites[:right_arrow].y = (height / 2) - 14
    @sprites[:right_arrow].z = 20
    @sprites[:right_arrow].visible = false
    @sprites[:right_arrow].play
    record_values(:right_arrow)
  end

  #-----------------------------------------------------------------------------

  def width
    return PANEL_WIDTH
  end

  def height
    return PANEL_HEIGHT
  end

  def panel_srcs
    return {
      :default  => [graphics_folder + "panels", 0, 0, PANEL_WIDTH, PANEL_HEIGHT],
      :new_slot => [graphics_folder + "panels", 0, PANEL_HEIGHT, PANEL_WIDTH, PANEL_HEIGHT]
    }
  end

  def pokemon_coords(index)
    return 272 + (66 * (index % 2)),
           36 + (50 * (index / 2))
  end

  def show_arrows=(value)
    return if @show_arrows == value
    @show_arrows = value
    @sprites[:left_arrow].visible = value
    @sprites[:right_arrow].visible = value
  end

  def set_data(save_data)
    @save_data = save_data
    @sprites[:background].change_bitmap((@save_data) ? :default : :new_slot)
    set_player_sprite
    refresh
  end

  def set_player_sprite
    if !@save_data
      @sprites[:player].visible = false
      return
    end
    @sprites[:player].visible = true
    meta = GameData::PlayerMetadata.get(@save_data[:player].character_ID)
    filename = pbGetPlayerCharset(meta.walk_charset, @save_data[:player], true)
    @sprites[:player].charset = filename
    if !@sprites[:player].bitmap
      raise _INTL("Player character {1}'s walking charset was not found (filename: \"{2}\").",
                  @save_data[:player].character_ID, filename)
    end
  end

  #-----------------------------------------------------------------------------

  def refresh
    super
    refresh_pokemon
    draw_save_file_text
  end

  def refresh_pokemon
    Settings::MAX_PARTY_SIZE.times do |i|
      if @save_data
        @sprites["pokemon_#{i}"].pokemon = @save_data[:player].party[i]
        @sprites["pokemon_#{i}"].visible = true
      else
        @sprites["pokemon_#{i}"].visible = false
      end
    end
  end

  def draw_save_file_text
    if !@save_data
      draw_text(_INTL("Create a new save file"), width / 2, (height / 2) - 10, align: :center, theme: :gray)
      return
    end
    gender_theme = :default
    if @save_data[:player].male?
      gender_theme = :male
    elsif @save_data[:player].female?
      gender_theme = :female
    end
    # Player's name
    draw_text(@save_data[:player].name, 78, 30, theme: gender_theme)
    # Location
    map_id = @save_data[:map_factory].map.map_id
    map_name = pbGetMapNameFromId(map_id)
    map_name = map_name.gsub(/\\PN/, @save_data[:player].name)
    map_name = map_name.gsub(/\\v\[(\d+)\]/) { |num| @save_data[:variables][$~[1].to_i].to_s }
    draw_text(map_name, 14, 78, theme: :gray)
    # Gym Badges
    draw_text(_INTL("Badges:"), 14, 110, theme: :white)
    draw_text(@save_data[:player].badge_count.to_s, 222, 110, align: :right, theme: :gray)
    # Pokédex owned count
    draw_text(_INTL("Pokédex:"), 14, 142, theme: :white)
    draw_text(@save_data[:player].pokedex.seen_count.to_s, 222, 142, align: :right, theme: :gray)
    # Time played
    draw_text(_INTL("Play time:"), 14, 174, theme: :white)
    play_time = @save_data[:stats]&.real_play_time.to_i || 0
    hour = (play_time / 60) / 60
    min  = (play_time / 60) % 60
    play_time_text = (hour > 0) ? _INTL("{1}h {2}m", hour, min) : _INTL("{1}m", min)
    draw_text(play_time_text, 222, 174, align: :right, theme: :gray)
    save_time = @save_data[:stats]&.real_time_saved
    if save_time && save_time != 0
      save_time = Time.at(save_time)
      if Translation.month_day_date_format?
        save_text = save_time.strftime("%-m/%-d/%Y")
      else
        save_text = save_time.strftime("%-d/%-m/%Y")
      end
      draw_text(save_text, PANEL_WIDTH - 14, 174, align: :right, theme: :gray)
    else
      draw_text("???", PANEL_WIDTH - 14, 174, align: :right, theme: :gray)
    end
  end

  def refresh_existing_pokemon
    Settings::MAX_PARTY_SIZE.times do |i|
      @sprites["pokemon_#{i}"].pokemon = @save_data[:player].party[i]
    end
  end
end

#===============================================================================
#
#===============================================================================
class UI::SaveVisuals < UI::BaseVisuals
  attr_reader :index

  GRAPHICS_FOLDER = "Save/"   # Subfolder in Graphics/UI
  PANEL_SPACING   = 8

  # save_data here is an array of [save filename, save data hash]. It has been
  # compacted.
  def initialize(save_data, current_save_data, default_index = 0)
    @save_data          = save_data
    @current_save_data  = current_save_data
    @index              = default_index   # Which save slot is selected
    @choosing_save_file = false
    super()
  end

  def initialize_sprites
    initialize_continue_panels
  end

  def initialize_continue_panels
    # Continue panel in middle
    this_index = @index
    @sprites[:continue] = create_slot_panel(this_index)
    # Continue panel to left
    if !@save_data.empty? && Settings::SAVE_SLOTS == :multiple
      previous_index = this_index - 1
      @sprites[:continue_previous] = create_slot_panel(this_index - 1)
      @sprites[:continue_previous].x = @sprites[:continue].x - @sprites[:continue].width - PANEL_SPACING
      @sprites[:continue_previous].visible = false
      # Continue panel to right
      next_index = this_index + 1
      @sprites[:continue_next] = create_slot_panel(this_index + 1)
      @sprites[:continue_next].x = @sprites[:continue].x + @sprites[:continue].width + PANEL_SPACING
      @sprites[:continue_next].visible = false
    end
  end

  #-----------------------------------------------------------------------------

  def create_slot_panel(slot_index, initializing = true)
    slot_index += @save_data.length + 1 if slot_index < 0
    slot_index -= @save_data.length + 1 if slot_index >= @save_data.length + 1
    if initializing
      this_save_data = @current_save_data[1]
    else
      this_save_data = (@save_data[slot_index]) ? @save_data[slot_index][1] : nil
    end
    ret = UI::SavePanel.new(this_save_data, @viewport)
    ret.x = (Graphics.width - ret.width) / 2
    ret.y = 40
    return ret
  end

  #-----------------------------------------------------------------------------

  def set_index(new_index, forced = false)
    while new_index < 0
      new_index += @save_data.length + 1
    end
    while new_index >= @save_data.length + 1
      new_index -= @save_data.length + 1
    end
    return if !forced && @index == new_index
    # Set the new index
    @index = new_index
    # Show the newly selected slot's information in the Continue panel
    this_save_data = (@save_data[@index]) ? @save_data[@index][1] : nil
    @sprites[:continue].set_data(this_save_data)
    # Show the newly adjacent slots' information in the adjacent Continue panels
    prev_index = @index - 1
    prev_index += @save_data.length + 1 if prev_index < 0
    this_save_data = (@save_data[prev_index]) ? @save_data[prev_index][1] : nil
    @sprites[:continue_previous]&.set_data(this_save_data)
    next_index = (@index + 1) % (@save_data.length + 1)
    this_save_data = (@save_data[next_index]) ? @save_data[next_index][1] : nil
    @sprites[:continue_next]&.set_data(this_save_data)
    refresh
    pbPlayCursorSE if !forced
  end

  def go_to_next_save_slot
    set_index(@index + 1)
  end

  def go_to_previous_save_slot
    set_index(@index - 1)
  end

  #-----------------------------------------------------------------------------

  def start_choose_save_file
    @choosing_save_file = true
    @sprites[:continue_previous]&.visible = true
    @sprites[:continue_next]&.visible = true
    @sprites[:continue].show_arrows = true
    set_index(@index, true)
  end

  #-----------------------------------------------------------------------------

  def refresh_overlay
    super
    if @choosing_save_file
      if @save_data[index] &&
         @save_data[index][1][:game_system].adventure_magic_number
        if @save_data[index][1][:game_system].adventure_magic_number == $game_system.adventure_magic_number
          save_time = @save_data[index][1][:stats].real_play_time
          delta_time = ($stats.play_time - save_time).to_i
          if delta_time >= 0
            hour = (delta_time / 60) / 60
            min  = (delta_time / 60) % 60
            if hour > 0
              draw_text(_INTL("Play time since save: {1}h {2}m", hour, min), 8, 4, theme: :gray)
            else
              draw_text(_INTL("Play time since save: {1}m", min), 8, 4, theme: :gray)
            end
          else
            draw_text(_INTL("Alternate version of your adventure!"), 8, 4, theme: :gray)
          end
        else
          draw_text(_INTL("Different adventure!"), 8, 4, theme: :gray)
        end
      end
      if @save_data[@index]
        draw_text(sprintf("%d/%d", @index + 1, @save_data.length), Graphics.width - 8, 4, align: :right, theme: :gray)
      end
    elsif $stats.save_count > 0 && $stats.real_time_saved && $stats.real_time_saved > 0
      save_time = Time.at($stats.real_time_saved)
      if Translation.month_day_date_format?
        date_text = save_time.strftime("%-m/%-d/%Y")
      else
        date_text = save_time.strftime("%-d/%-m/%Y")
      end
      time_text = save_time.strftime("%H:%M")
      draw_text(_INTL("Last saved on {1} at {2}", date_text, time_text), 8, 4, theme: :gray)
    end
  end

  def full_refresh
    refresh
    @sprites.each_pair { |key, sprite| sprite.refresh if sprite.respond_to?(:refresh) }
  end

  #-----------------------------------------------------------------------------

  def update_input
    # Check for movement to a different save slot
    if Input.repeat?(Input::LEFT)
      go_to_previous_save_slot
    elsif Input.repeat?(Input::RIGHT)
      go_to_next_save_slot
    end
    # Check for interaction
    if Input.trigger?(Input::USE)
      return update_interaction(Input::USE)
    elsif Input.trigger?(Input::BACK)
      return update_interaction(Input::BACK)
    end
    return nil
  end

  def update_interaction(input)
    case input
    when Input::USE
      pbPlayDecisionSE
      return :choose_slot
    when Input::BACK
      pbPlayCancelSE
      return :quit
    end
    return nil
  end

  #-----------------------------------------------------------------------------

  def navigate
    help_text = _INTL("Choose a file to save in.")
    help_window = Window_AdvancedTextPokemon.newWithSize(
      help_text, 0, 0, Graphics.width, 96, @viewport
    )
    help_window.z = 2000
    help_window.setSkin(MessageConfig.pbGetSpeechFrame)
    help_window.letterbyletter = false
    pbBottomRight(help_window)
    # Navigate loop
    ret = super
    # Clean up
    help_window.dispose
    return ret
  end
end

#===============================================================================
#
#===============================================================================
class UI::Save < UI::BaseScreen
  attr_reader :save_data

  include UI::LoadSaveDataMixin

  def initialize
    create_current_save_data
    load_all_save_data
    determine_default_save_file
    super
  end

  def initialize_visuals
    @visuals = UI::SaveVisuals.new(@save_data, @current_save_data, @default_index)
  end

  #-----------------------------------------------------------------------------

  def index
    return @visuals&.index || @default_index
  end

  #-----------------------------------------------------------------------------

  # This is pseudo-save data containing the current state of the game.
  def create_current_save_data
    @current_save_data = [0, {
      :player      => $player,
      :map_factory => $map_factory,
      :variables   => $game_variables,
      :stats       => $stats
    }]
    @current_save_data[1][:stats].set_time_last_saved
  end

  def determine_default_save_file
    # Find the save file index matching the current game's filename number
    if $stats.save_filename_number && $stats.save_filename_number >= 0
      expected_filename = SaveData.filename_from_index($stats.save_filename_number)
      @default_index = @save_data.index { |sav| sav[0] == expected_filename }
      @default_index ||= @save_data.length   # Just in case
    else
      @default_index = @save_data.length   # New save slot
    end
  end

  def different_adventure?(slot_index)
    return false if !@save_data[slot_index]
    return false if !@save_data[slot_index][1][:game_system].adventure_magic_number
    return @save_data[slot_index][1][:game_system].adventure_magic_number != $game_system.adventure_magic_number
  end

  def prompt_overwrite_save_file(slot_index)
    if different_adventure?(slot_index)
      show_message(_INTL("WARNING!") + "\1")
      show_message(_INTL("There is a different game file that is already saved.") + "\1")
      show_message(_INTL("If you save now, the other file's adventure, including items and Pokémon, will be entirely lost.") + "\1")
      if !show_confirm_serious_message(_INTL("Are you sure you want to save now and overwrite the other save file?"))
        return false
      end
    end
    return true
  end

  # NOTE: Save filenames are "Game#.rxdata" where "#" is slot_index, except for
  #       0 which just produces "Game.rzdata". This is to support old save
  #       files which are that name.
  def save_game(file_number)
    if Game.save(file_number)
      # Refresh the panels to show the new save's data
      file = SaveData.filename_from_index(file_number)
      slot_index = @save_data.index { |sav| sav[0] == file }
      slot_index ||= @save_data.length   # New save file
      this_save_data = load_save_file(SaveData::DIRECTORY, file)
      @save_data[slot_index] = [file, this_save_data]
      @visuals.set_index(slot_index, true)
      # Announce the save success
      show_message(_INTL("{1} saved the game.", $player.name)) do
        pbSEStop
        pbMEPlay("GUI save game")
        wait(1)
      end
      @result = true
    else
      pbSEPlay("GUI save choice")
      show_message(_INTL("Save failed."))
      @result = false
    end
  end

  def get_save_file_number(slot_index = -1)
    filename = (slot_index >= 0 && @save_data[slot_index]) ? @save_data[slot_index][0] : @save_data.last[0]
    filename[SaveData::FILENAME_REGEX]   # Just to get the number in the filename
    ret = $~[1].to_i
    ret += 1 if slot_index < 0 || !@save_data[slot_index]
    return ret
  end

  #-----------------------------------------------------------------------------

  def main
    start_screen
    # If the player doesn't want to save, just exit the screen
    if !show_confirm_message(_INTL("Would you like to save the game?"))
      end_screen
      return false
    end
    # If there are no existing save files, just save in the first slot
    if @save_data.empty?
      save_game(0)
      end_screen
      return @result
    end
    # If there are existing save files, do something depending on which save
    # files are allowed to be made
    case Settings::SAVE_SLOTS
    when :multiple
      # Choose a save slot to replace
      @visuals.start_choose_save_file
      loop do
        command = @visuals.navigate
        break if command == :quit
        if !@save_data[index] ||
           show_confirm_message(_INTL("Do you want to overwrite this save file?"))
          if different_adventure?(index)
            show_message(_INTL("WARNING!") + "\1")
            pbPlayDecisionSE
            show_message(_INTL("This save file is a different adventure.") + "\1")
            pbPlayDecisionSE
            show_message(_INTL("If you save now, that adventure, including items and Pokémon, will be entirely lost.") + "\1")
            pbPlayDecisionSE
            next if !show_confirm_serious_message(_INTL("Are you sure you want to overwrite it?"))
          end
          file_number = get_save_file_number(index)
          save_game(file_number)
          break
        end
      end
    when :adventure
      if $stats.save_filename_number && $stats.save_filename_number >= 0   # Was saved previously
        save_game($stats.save_filename_number)
      else
        file_number = get_save_file_number(-1)   # New save slot
        save_game(file_number)
      end
    when :one
      save_game(0) if prompt_overwrite_save_file(0)
    end
    end_screen
    return @result
  end
end

#===============================================================================
#
#===============================================================================
def pbSaveScreen
  ret = false
  pbFadeOutIn { ret = UI::Save.new.main }
  return ret
end

def pbEmergencySave
  oldscene = $scene
  $scene = nil
  pbMessage(_INTL("The script is taking too long. The game will restart."))
  return if !$player
  filename_number = $stats.save_filename_number || -1
  filename = SaveData.filename_from_index(filename_number)
  if SaveData.exists?
    File.open(SaveData::DIRECTORY + filename, "rb") do |r|
      File.open(SaveData::DIRECTORY + filename + ".bak", "wb") do |w|
        loop do
          s = r.read(4096)
          break if !s
          w.write(s)
        end
      end
    end
  end
  if Game.save(filename_number)
    pbMessage("\\se[]" + _INTL("The game was saved.") + "\\me[GUI save game]\\wtnp[20]")
    pbMessage("\\se[]" + _INTL("The previous save file has been backed up.") + "\\wtnp[20]")
  else
    pbMessage("\\se[]" + _INTL("Save failed.") + "\\wtnp[30]")
  end
  $scene = oldscene
end
