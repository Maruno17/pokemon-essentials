#===============================================================================
#
#===============================================================================
class UI::LoadPanel < UI::SpriteContainer
  GRAPHICS_FOLDER = "Load/"
  TEXT_COLOR_THEMES = {   # These color themes are added to @sprites[:overlay]
    :default => [Color.new(88, 88, 80), Color.new(168, 184, 184)]   # Base and shadow colour
  }
  PANEL_WIDTH  = 392
  PANEL_HEIGHT = 56

  def initialize(label, viewport)
    @label    = label
    @selected = nil
    super(viewport)
  end

  def initialize_sprites
    initialize_panel_background
    initialize_overlay
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
    add_overlay(:overlay, @sprites[:background].src_rect.width, @sprites[:background].src_rect.height)
    @sprites[:overlay].z = 10
    record_values(:overlay)
  end

  #-----------------------------------------------------------------------------

  def width
    return self.class::PANEL_WIDTH
  end

  def height
    return self.class::PANEL_HEIGHT
  end

  def panel_srcs
    return {
      :default  => [graphics_folder + "panels", 0, UI::LoadContinuePanel::PANEL_HEIGHT * 2,
                    self.class::PANEL_WIDTH, self.class::PANEL_HEIGHT],
      :selected => [graphics_folder + "panels", 0, (UI::LoadContinuePanel::PANEL_HEIGHT * 2) + self.class::PANEL_HEIGHT,
                    self.class::PANEL_WIDTH, self.class::PANEL_HEIGHT]
    }
  end

  def selected=(value)
    return if @selected == value
    @selected = value
    @sprites[:background].change_bitmap((@selected) ? :selected : :default)
    refresh
  end

  #-----------------------------------------------------------------------------

  def refresh
    super
    draw_text(@label, 18, 18)
  end
end

#===============================================================================
#
#===============================================================================
class UI::LoadContinuePanel < UI::LoadPanel
  attr_reader :sprites

  GRAPHICS_FOLDER = "Load/"
  TEXT_COLOR_THEMES = {   # These color themes are added to @sprites[:overlay]
    :default => [Color.new(88, 88, 80), Color.new(168, 184, 184)],   # Base and shadow colour
    :male    => [Color.new(0, 112, 248), Color.new(120, 184, 232)],
    :female  => [Color.new(232, 32, 16), Color.new(248, 168, 184)]
  }
  PANEL_WIDTH  = 392
  PANEL_HEIGHT = 248

  def initialize(label, save_data, slot_index, total_slots, viewport)
    @save_data   = save_data
    @slot_index  = slot_index
    @total_slots = total_slots
    super(label, viewport)
    refresh
  end

  def initialize_sprites
    super
    initialize_player_sprite
    initialize_pokemon_icons
    initialize_arrow_sprites
  end

  def initialize_player_sprite
    meta = GameData::PlayerMetadata.get(@save_data[:player].character_ID)
    filename = pbGetPlayerCharset(meta.walk_charset, @save_data[:player], true)
    @sprites[:player] = TrainerWalkingCharSprite.new(filename, @viewport)
    if !@sprites[:player].bitmap
      raise _INTL("Player character {1}'s walking charset was not found (filename: \"{2}\").",
                  @save_data[:player].character_ID, filename)
    end
    @sprites[:player].x = 48 - (@sprites[:player].bitmap.width / 8)
    @sprites[:player].y = 72 - (@sprites[:player].bitmap.height / 8)
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
    @sprites[:left_arrow].play
    record_values(:left_arrow)
    @sprites[:right_arrow] = AnimatedSprite.new(UI_FOLDER + "right_arrow", 8, 40, 28, 2, @viewport)
    @sprites[:right_arrow].x = width - 24
    @sprites[:right_arrow].y = (height / 2) - 14
    @sprites[:right_arrow].z = 20
    @sprites[:right_arrow].play
    record_values(:right_arrow)
  end

  #-----------------------------------------------------------------------------

  def panel_srcs
    return {
      :default  => [graphics_folder + "panels", 0, 0,
                    self.class::PANEL_WIDTH, self.class::PANEL_HEIGHT],
      :selected => [graphics_folder + "panels", 0, self.class::PANEL_HEIGHT,
                    self.class::PANEL_WIDTH, self.class::PANEL_HEIGHT]
    }
  end

  def pokemon_coords(index)
    return 276 + (66 * (index % 2)),
           74 + (50 * (index / 2))
  end

  def visible=(value)
    super
    @sprites[:left_arrow].visible = (@selected && @total_slots >= 2)
    @sprites[:right_arrow].visible = (@selected && @total_slots >= 2)
  end

  def selected=(value)
    @sprites[:left_arrow].visible = (value && @total_slots >= 2)
    @sprites[:right_arrow].visible = (value && @total_slots >= 2)
    super
  end

  def set_data(save_data, slot_index, total_slots)
    @save_data   = save_data
    @slot_index  = slot_index
    @total_slots = total_slots
    @sprites[:left_arrow].visible = (@selected && total_slots >= 2)
    @sprites[:right_arrow].visible = (@selected && total_slots >= 2)
    set_player_sprite
    refresh
  end

  def set_player_sprite
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
    draw_slot_number
    draw_save_file_text
  end

  def refresh_pokemon
    Settings::MAX_PARTY_SIZE.times do |i|
      @sprites["pokemon_#{i}"].pokemon = @save_data[:player].party[i]
    end
  end

  def draw_slot_number
    return if @total_slots <= 1
    draw_text(sprintf("%d/%d", @slot_index + 1, @total_slots), PANEL_WIDTH - 18, 18, align: :right)
  end

  def draw_save_file_text
    gender_theme = :default
    if @save_data[:player].male?
      gender_theme = :male
    elsif @save_data[:player].female?
      gender_theme = :female
    end
    # Player's name
    draw_text(@save_data[:player].name, 78, 66, theme: gender_theme)
    # Location
    map_id = @save_data[:map_factory].map.map_id
    map_name = pbGetMapNameFromId(map_id)
    map_name = map_name.gsub(/\\PN/, @save_data[:player].name)
    map_name = map_name.gsub(/\\v\[(\d+)\]/) { |num| @save_data[:variables][$~[1].to_i].to_s }
    draw_text(map_name, 18, 114, theme: gender_theme)
    # Gym Badges
    draw_text(_INTL("Badges:"), 18, 146)
    draw_text(@save_data[:player].badge_count.to_s, 156, 146, theme: gender_theme)
    # Pokédex owned count
    draw_text(_INTL("Pokédex:"), 18, 178)
    draw_text(@save_data[:player].pokedex.seen_count.to_s, 156, 178, theme: gender_theme)
    # Time played
    draw_text(_INTL("Time played:"), 18, 210)
    play_time = @save_data[:stats]&.play_time.to_i || 0
    hour = (play_time / 60) / 60
    min  = (play_time / 60) % 60
    play_time_text = (hour > 0) ? _INTL("{1}h {2}m", hour, min) : _INTL("{1}m", min)
    draw_text(play_time_text, 156, 210, theme: gender_theme)
    save_time = @save_data[:stats]&.real_time_saved
    if save_time
      save_time = Time.at(save_time)
      if System.user_language[3..4] == "US"   # If the user is in the United States
        save_text = save_time.strftime("%-m/&-d/%Y")
      else
        save_text = save_time.strftime("%-d/%-m/%Y")
      end
      draw_text(save_text, PANEL_WIDTH - 18, 210, align: :right, theme: gender_theme)
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
class UI::LoadVisuals < UI::BaseVisuals
  attr_reader :slot_index

  GRAPHICS_FOLDER    = "Load/"   # Subfolder in Graphics/UI
  PANEL_SPACING_EDGE = 4
  PANEL_SPACING      = PANEL_SPACING_EDGE * 2

  # save_data here is an array of all save files' data. It has been compacted.
  # commands is {:continue => _INTL("Continue"), :new_game => _INTL("New Game")}, etc.
  def initialize(commands, save_data, default_slot_index = 0)
    @save_data = save_data
    @commands = commands
    @index = @commands.keys.first   # A symbol from @commands
    @slot_index = default_slot_index   # Which save slot is selected
    super()
  end

  def initialize_sprites
    initialize_continue_panels
    initialize_other_panels
  end

  def initialize_continue_panels
    return if @save_data.nil? || @commands.keys.first != :continue
    # Continue panel in middle
    this_slot_index = @slot_index
    @sprites[:continue] = create_continue_panel(this_slot_index)
    # Continue panel to left
    if @save_data.length >= 2
      previous_slot_index = this_slot_index - 1
      @sprites[:continue_previous] = create_continue_panel(this_slot_index - 1)
      @sprites[:continue_previous].x = @sprites[:continue].x - @sprites[:continue].width - PANEL_SPACING
      # Continue panel to right
      next_slot_index = this_slot_index + 1
      @sprites[:continue_next] = create_continue_panel(this_slot_index + 1)
      @sprites[:continue_next].x = @sprites[:continue].x + @sprites[:continue].width + PANEL_SPACING
    end
  end

  def initialize_other_panels
    @commands.each_pair do |key, text|
      next if key == :continue
      @sprites[key] = UI::LoadPanel.new(text, @viewport)
      @sprites[key].x = (Graphics.width - @sprites[key].width) / 2
    end
    @sprites[:mystery_gift]&.visible = @save_data[@slot_index] && @save_data[@slot_index][1][:player].mystery_gift_unlocked
  end

  #-----------------------------------------------------------------------------

  def create_continue_panel(slot_index)
    slot_index += @save_data.length if slot_index < 0
    slot_index -= @save_data.length if slot_index >= @save_data.length
    ret = UI::LoadContinuePanel.new(@commands[:continue],
      @save_data[slot_index][1], slot_index, @save_data.length, @viewport)
    ret.x = (Graphics.width - ret.width) / 2
    return ret
  end

  def set_index(new_index)
    @index = new_index
    refresh_on_index_changed(@index)
  end

  def go_to_next_option(play_se = true)
    return if @commands.length == 1
    old_index = @commands.keys.index(@index)
    new_index = old_index
    loop do
      new_index = (new_index + 1) % @commands.length
      break if @sprites[@commands.keys[new_index]] && @sprites[@commands.keys[new_index]].visible
      break if new_index == old_index
    end
    return if new_index == old_index
    pbPlayCursorSE if play_se
    set_index(@commands.keys[new_index])
  end

  def go_to_previous_option(play_se = true)
    return if @commands.length == 1
    old_index = @commands.keys.index(@index)
    new_index = old_index
    loop do
      new_index -= 1
      new_index += @commands.length if new_index < 0
      break if @sprites[@commands.keys[new_index]] && @sprites[@commands.keys[new_index]].visible
      break if new_index == old_index
    end
    return if new_index == old_index
    pbPlayCursorSE if play_se
    set_index(@commands.keys[new_index])
  end

  #-----------------------------------------------------------------------------

  def set_slot_index(new_index, forced = false)
    while new_index < 0
      new_index += @save_data.length
    end
    while new_index >= @save_data.length
      new_index -= @save_data.length
    end
    return if !forced && @slot_index == new_index
    # Set the new index
    @slot_index = new_index
    # Show the newly selected slot's information in the Continue panel
    @sprites[:continue].set_data(@save_data[@slot_index][1], @slot_index, @save_data.length)
    # Show the newly adjacent slots' information in the adjacent Continue panels
    prev_index = @slot_index - 1
    prev_index += @save_data.length if prev_index < 0
    @sprites[:continue_previous]&.set_data(@save_data[prev_index][1], prev_index, @save_data.length)
    next_index = (@slot_index + 1) % @save_data.length
    @sprites[:continue_next]&.set_data(@save_data[next_index][1], next_index, @save_data.length)
    # Determine whether the Mystery Gift option is visible
    @sprites[:mystery_gift].visible = @save_data[@slot_index][1][:player].mystery_gift_unlocked
    refresh_panel_positions
    SaveData.load_bootup_values(@save_data[@slot_index][1], true)
    pbPlayCursorSE if !forced
  end

  def go_to_next_save_slot
    set_slot_index(@slot_index + 1)
  end

  def go_to_previous_save_slot
    set_slot_index(@slot_index - 1)
  end

  #-----------------------------------------------------------------------------

  def refresh
    super
    @commands.keys.each { |key| @sprites[key]&.refresh }
    refresh_panel_positions
    refresh_selected_panel
  end

  def full_refresh
    refresh
    @sprites.each_pair { |key, sprite| sprite.refresh if sprite.respond_to?(:refresh) }
  end

  def refresh_panel_positions
    @panel_y_offset ||= 0
    sprite_y = PANEL_SPACING_EDGE
    # Determine the relative positions of all option panels
    sprite_pos = {}
    @commands.keys.each do |key|
      next if !@sprites[key] || !@sprites[key].visible   # If Mystery Gift option isn't available
      sprite_pos[key] = sprite_y
      sprite_y += @sprites[key].height + PANEL_SPACING
    end
    # Determine an offset that ensures the selected option panel is on-screen
    screen_y = sprite_pos[@index] - @panel_y_offset
    if screen_y < PANEL_SPACING_EDGE
      @panel_y_offset = sprite_pos[@index] - PANEL_SPACING_EDGE
    elsif screen_y + @sprites[@index].height > Graphics.height - PANEL_SPACING_EDGE
      @panel_y_offset = sprite_pos[@index] + @sprites[@index].height + PANEL_SPACING_EDGE - Graphics.height
    end
    # Apply the calculated positions to all option panels
    sprite_pos.each_pair do |key, value|
      @sprites[key].y = value - @panel_y_offset
    end
    @sprites[:continue_previous]&.y = @sprites[:continue].y
    @sprites[:continue_next]&.y = @sprites[:continue].y
  end

  def refresh_selected_panel
    @commands.keys.each do |key|
      @sprites[key]&.selected = (key == @index)
    end
    @sprites[:continue_previous]&.selected = false
    @sprites[:continue_next]&.selected = false
  end

  def refresh_on_index_changed(old_index)
    refresh_selected_panel
    refresh_panel_positions
  end

  def refresh_after_save_file_deleted
    @slot_index = [@slot_index, @save_data.length - 1].min
    if @save_data.empty?
      [:continue, :continue_previous, :continue_next].each do |key|
        @sprites[key].dispose if @sprites[key] && !@sprites[key].disposed?
        @sprites[key] = nil
      end
      @sprites[:mystery_gift].visible = false
      go_to_next_option(false)
    else
      if @save_data.length == 1
        [:continue_previous, :continue_next].each do |key|
          @sprites[key].dispose if @sprites[key] && !@sprites[key].disposed?
          @sprites[key] = nil
        end
      end
      set_slot_index(@slot_index, true)
    end
  end

  #-----------------------------------------------------------------------------

  def update_input
    # Check for movement to a new option
    if Input.repeat?(Input::UP)
      go_to_previous_option
    elsif Input.repeat?(Input::DOWN)
      go_to_next_option
    end
    # Check for movement to a different save slot
    if @index == :continue && @save_data.length > 1
      if Input.repeat?(Input::LEFT)
        go_to_previous_save_slot
      elsif Input.repeat?(Input::RIGHT)
        go_to_next_save_slot
      end
    end
    # Check for interaction
    if Input.trigger?(Input::USE)
      if @index == :continue && Input.press?(Input::ACTION) && Input.press?(Input::BACK)
        pbPlayDecisionSE
        return :delete_save
      end
      return update_interaction(Input::USE)
    end
    return nil
  end

  def update_interaction(input)
    case input
    when Input::USE
      pbPlayDecisionSE if @index != :quit_game
      return @index   # This is a key from @commands
    end
    return nil
  end
end

#===============================================================================
#
#===============================================================================
class UI::Load < UI::BaseScreen
  attr_reader :save_data

  SCREEN_ID = :load_screen

  def initialize
    load_save_data
    if $DEBUG && !FileTest.exist?("Game.rgssad") && Settings::SKIP_CONTINUE_SCREEN
      @disposed = true
      perform_action((@save_data.empty?) ? :new_game : :continue)
      return
    end
    set_commands
    super
  end

  def initialize_visuals
    @visuals = UI::LoadVisuals.new(@commands, @save_data, @default_slot_index)
  end

  #-----------------------------------------------------------------------------

  def slot_index
    return @visuals&.slot_index || @default_slot_index
  end

  def set_commands
    @commands = {}
    MenuHandlers.each_available(:load_screen, self) do |option, _hash, name|
      @commands[option] = name
    end
  end

  #-----------------------------------------------------------------------------

  def load_save_data
    @save_data = []
    @default_slot_index = 0
    last_edited_time = nil
    files = SaveData.all_save_files
    files.each do |file|
      # Load the save file
      this_save_data = SaveData.read_from_file(SaveData::DIRECTORY + file)
      if !SaveData.valid?(this_save_data)
        if File.file?(SaveData::DIRECTORY + file + ".bak")
          show_message(_INTL("The save file is corrupt. A backup will be loaded."))
          this_save_data = load_save_file(SaveData::FILE_PATH + ".bak")
        else
          prompt_corrupted_save_deletion(file)
        end
      end
      @save_data.push([file, this_save_data])
      # Find the most recently edited save file; default to selecting that one
      save_time = this_save_data[:stats].real_time_saved || 0
      if !last_edited_time || save_time > last_edited_time
        last_edited_time = save_time
        @default_slot_index = @save_data.length - 1
      end
    end
    SaveData.load_bootup_values(@save_data[@default_slot_index][1], true) if !@save_data.empty?
  end

  def prompt_corrupted_save_deletion(filename)
    show_message(_INTL("The save file is corrupt, or is incompatible with this game.") + "\1")
    pbPlayDecisionSE
    exit if !show_confirm_serious_message(_INTL("Do you want to delete the save file and start anew?"))
    delete_save_data(filename)
    $PokemonSystem = PokemonSystem.new
  end

  def prompt_save_deletion(filename)
    if show_confirm_serious_message(_INTL("Delete this save file?"))
      show_message(_INTL("Once a save file has been deleted, there is no way to recover it.") + "\1")
      pbPlayDecisionSE
      if show_confirm_serious_message(_INTL("Delete the save file anyway?"))
        delete_save_data(filename) {
          @save_data.delete_if { |save| save[0] == filename }
          @visuals.refresh_after_save_file_deleted
        }
      end
    end
  end

  def delete_save_data(filename)
    begin
      SaveData.delete_file(filename)
      yield if block_given?
      show_message(_INTL("The save file was deleted."))
    rescue SystemCallError
      show_message(_INTL("The save file could not be deleted."))
    end
  end

  #-----------------------------------------------------------------------------

  def full_refresh
    @visuals.full_refresh
  end
end

#===============================================================================
# Actions that can be triggered in the load screen.
#===============================================================================
UIActionHandlers.add(UI::Load::SCREEN_ID, :continue, {
  :effect => proc { |screen|
    screen.end_screen
    Game.load(screen.save_data[screen.slot_index][1])
  }
})

UIActionHandlers.add(UI::Load::SCREEN_ID, :mystery_gift, {
  :effect => proc { |screen|
    pbFadeOutInWithUpdate(screen.sprites) do
      pbDownloadMysteryGift(screen.save_data[screen.slot_index][1][:player])
    end
  }
})

UIActionHandlers.add(UI::Load::SCREEN_ID, :new_game, {
  :effect => proc { |screen|
    screen.end_screen
    Game.start_new
  }
})

UIActionHandlers.add(UI::Load::SCREEN_ID, :options, {
  :effect => proc { |screen|
    pbFadeOutInWithUpdate(screen.sprites) do
      options_scene = PokemonOption_Scene.new
      options_screen = PokemonOptionScreen.new(options_scene)
      options_screen.pbStartScreen(true)
      screen.full_refresh
    end
  }
})

UIActionHandlers.add(UI::Load::SCREEN_ID, :language, {
  :effect => proc { |screen|
    screen.end_screen
    $PokemonSystem.language = pbChooseLanguage
    MessageTypes.load_message_files(Settings::LANGUAGES[$PokemonSystem.language][1])
    if screen.save_data[screen.slot_index]
      screen.save_data[screen.slot_index][1][:pokemon_system] = $PokemonSystem
      File.open(SaveData::DIRECTORY + screen.save_data[screen.slot_index][0], "wb") do |file|
        Marshal.dump(screen.save_data[screen.slot_index][1], file)
      end
    end
    $scene = pbCallTitle
  }
})

UIActionHandlers.add(UI::Load::SCREEN_ID, :debug, {
  :effect => proc { |screen|
    pbFadeOutInWithUpdate(screen.sprites) do
      pbDebugMenu(false)
    end
  }
})

UIActionHandlers.add(UI::Load::SCREEN_ID, :quit_game, {
  :effect => proc { |screen|
    pbPlayCloseMenuSE
    screen.end_screen
    $scene = nil
  }
})

UIActionHandlers.add(UI::Load::SCREEN_ID, :delete_save, {
  :effect => proc { |screen|
    screen.prompt_save_deletion(screen.save_data[screen.slot_index][0])
  }
})

#===============================================================================
# Menu options that exist in the load screen.
#===============================================================================
MenuHandlers.add(:load_screen, :continue, {
  "name"      => _INTL("Continue"),
  "order"     => 10,
  "condition" => proc { |screen| next screen.save_data && !screen.save_data.empty? }
})

# NOTE: Mystery Gift is always added as an option here, even if no save files
#       have unlocked it. Whether it is shown depends on the selected save file,
#       and its visibility is toggled elsewhere because of that.
MenuHandlers.add(:load_screen, :mystery_gift, {
  "name"      => _INTL("Mystery Gift"),
  "order"     => 20,
  "condition" => proc { |screen| next screen.save_data && !screen.save_data.empty? }
})

MenuHandlers.add(:load_screen, :new_game, {
  "name"      => _INTL("New Game"),
  "order"     => 30
})

MenuHandlers.add(:load_screen, :options, {
  "name"      => _INTL("Options"),
  "order"     => 40
})

# TODO: Put language in the options screen?
MenuHandlers.add(:load_screen, :language, {
  "name"      => _INTL("Language"),
  "order"     => 50,
  "condition" => proc { |screen| next Settings::LANGUAGES.length >= 2 }
})

MenuHandlers.add(:load_screen, :debug, {
  "name"      => _INTL("Debug"),
  "order"     => 60,
  "condition" => proc { |screen| next $DEBUG }
})

MenuHandlers.add(:load_screen, :quit_game, {
  "name"      => _INTL("Quit Game"),
  "order"     => 9999
})
