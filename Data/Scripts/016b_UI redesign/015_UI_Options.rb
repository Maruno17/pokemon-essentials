#===============================================================================
#
#===============================================================================
class PokemonSystem
  attr_accessor :battlestyle
  attr_accessor :runstyle
  attr_accessor :sendtoboxes
  attr_accessor :givenicknames
  attr_accessor :textinput
  attr_reader   :bgmvolume
  attr_reader   :sevolume
  attr_writer   :pokemon_cry_volume
  attr_reader   :textspeed
  attr_accessor :battlescene
  attr_reader   :textskin
  attr_reader   :frame
  attr_reader   :screensize
  attr_reader   :language
  attr_writer   :controls

  def initialize
    @battlestyle        = 0     # Battle style (0=switch, 1=set)
    @runstyle           = 0     # Default movement speed (0=walk, 1=run)
    @sendtoboxes        = 0     # Send to Boxes (0=manual, 1=automatic)
    @givenicknames      = 0     # Give nicknames (0=give, 1=don't give)
    @textinput          = 0     # Text input mode (0=cursor, 1=keyboard)
    @language           = 0     # Language (see also Settings::LANGUAGES)
    @main_volume        = 100
    @bgmvolume          = 80    # Volume of background music and ME
    @sevolume           = 100   # Volume of sound effects (except cries)
    @pokemon_cry_volume = 100
    @textspeed          = 1     # Text speed (0=slow, 1=medium, 2=fast, 3=instant)
    @battlescene        = 0     # Battle effects (animations) (0=on, 1=off)
    @textskin           = 0     # Speech frame
    @frame              = 0     # Default window frame (see also Settings::MENU_WINDOWSKINS)
    @screensize         = (Settings::SCREEN_SCALE * 2).floor - 1   # 0=half size, 1=full size, 2=full-and-a-half size, 3=double size
  end

  def language=(value)
    return if @language == value && !@force_set_options
    @language = value
    if Settings::LANGUAGES[@language]
      MessageTypes.load_message_files(Settings::LANGUAGES[@language][1])
    end
  end

  def main_volume
    return @main_volume || 100
  end

  def main_volume=(value)
    return if @main_volume == value && !@force_set_options
    @main_volume = value
    return if !$game_system
    if $game_system.playing_bgm.nil?
      playingBGM = $game_system.getPlayingBGM
      $game_system.bgm_pause
      $game_system.bgm_resume(playingBGM)
    end
    if $game_system.playing_bgs
      $game_system.playing_bgs.volume = @sevolume
      playingBGS = $game_system.getPlayingBGS
      $game_system.bgs_pause
      $game_system.bgs_resume(playingBGS)
    end
  end

  def bgmvolume=(value)
    return if @bgmvolume == value && !@force_set_options
    @bgmvolume = value
    return if !$game_system || $game_system.playing_bgm.nil?
    playingBGM = $game_system.getPlayingBGM
    $game_system.bgm_pause
    $game_system.bgm_resume(playingBGM)
  end

  def sevolume=(value)
    return if @sevolume == value && !@force_set_options
    @sevolume = value
    return if !$game_system || $game_system.playing_bgs.nil?
    $game_system.playing_bgs.volume = @sevolume
    playingBGS = $game_system.getPlayingBGS
    $game_system.bgs_pause
    $game_system.bgs_resume(playingBGS)
  end

  def pokemon_cry_volume
    return @pokemon_cry_volume || 100
  end

  def textspeed=(value)
    return if @textspeed == value && !@force_set_options
    @textspeed = value
    MessageConfig.pbSetTextSpeed(MessageConfig.pbSettingToTextSpeed(@textspeed))
  end

  def textskin=(value)
    return if @textskin == value && !@force_set_options
    @textskin = value
    MessageConfig.pbSetSpeechFrame("Graphics/Windowskins/" + Settings::SPEECH_WINDOWSKINS[@textskin])
  end

  def frame=(value)
    return if @frame == value && !@force_set_options
    @frame = value
    MessageConfig.pbSetSystemFrame("Graphics/Windowskins/" + Settings::MENU_WINDOWSKINS[@frame])
  end

  def screensize=(value)
    return if @screensize == value && !@force_set_options
    @screensize = value
    pbSetResizeFactor(@screensize)
  end

  def controls
    reset_controls if !@controls
    return @controls
  end

  def reset_controls
    @controls ||= {}
    keys = Input::DEFAULT_INPUT_MAPPINGS.keys + Input::DEFAULT_INPUT_MAPPINGS_REMAPPABLE.keys
    keys.uniq!
    keys.each do |key|
      @controls[key] = []
      if Input::DEFAULT_INPUT_MAPPINGS_REMAPPABLE[key]
        @controls[key][0] = Input::DEFAULT_INPUT_MAPPINGS_REMAPPABLE[key][0]
        @controls[key][1] = Input::DEFAULT_INPUT_MAPPINGS_REMAPPABLE[key][1]
      end
    end
  end

  #-----------------------------------------------------------------------------

  def reapply_all_options
    @force_set_options = true
    all_options = self.instance_variables.map { |val| val.to_s.gsub("@", "").to_sym }
    all_options.each do |option|
      next if option == :force_set_options
      self.send((option.to_s + "=").to_sym, self.send(option))
    end
    @force_set_options = false
  end
end

#===============================================================================
# Main list of options.
#===============================================================================
class UI::OptionsVisualsList < Window_DrawableCommand
  attr_writer   :baseColor, :shadowColor
  attr_accessor :optionColor, :optionShadowColor
  attr_accessor :selectedColor, :selectedShadowColor
  attr_accessor :unsetColor, :unsetShadowColor
  attr_reader   :value_changed

  def initialize(x, y, width, height, viewport)
    @input_icons_bitmap = AnimatedBitmap.new(UI::OptionsVisuals::UI_FOLDER + "input_icons")
    super(x, y, width, height, viewport)
    @index = -1
  end

  def dispose
    super
    @input_icons_bitmap.dispose
  end

  #-----------------------------------------------------------------------------

  def itemCount
    return @options&.length || 0
  end

  def options=(new_options)
    @options = new_options
    self.top_row = 0
    get_values
    @array_second_value_x = 0
    @options.each do |option|
      next if option[:type] != :array || option[:parameters].length != 2
      text_width = self.contents.text_size(option[:parameters][0]).width
      @array_second_value_x = text_width if @array_second_value_x < text_width
    end
    @array_second_value_x += 32
    refresh
  end

  def get_values
    @values = @options.map { |option| option[:get_proc]&.call }
  end

  def lowest_value(option)
    case option[:type]
    when :number_type
      case option[:parameters]
      when Range
        return option[:parameters].begin
      when Array
        return option[:parameters][0] if option[:parameters][0]   # Parameter is [lowest, highest, interval]
      end
      raise _INTL("Option {1} has invalid parameters.", option[:name])
    when :number_slider
      if option[:parameters].is_a?(Array) && option[:parameters][1]
        return option[:parameters][0]   # Parameter is [lowest, highest, interval]
      end
      raise _INTL("Option {1} has invalid parameters.", option[:name])
    end
    raise _INTL("Option {1} has an undefined lowest value.", option[:name])
  end

  def highest_value(option)
    case option[:type]
    when :number_type
      case option[:parameters]
      when Range
        return option[:parameters].end
      when Array
        return option[:parameters][1] if option[:parameters][1]   # Parameter is [lowest, highest, interval]
      end
      raise _INTL("Option {1} has invalid parameters.", option[:name])
    when :number_slider
      if option[:parameters].is_a?(Array) && option[:parameters][1]
        return option[:parameters][1]   # Parameter is [lowest, highest, interval]
      end
      raise _INTL("Option {1} has invalid parameters.", option[:name])
    end
    raise _INTL("Option {1} has an undefined highest value.", option[:name])
  end

  def previous_value(this_index)
    return @values[this_index] if @values[this_index] == 0
    option = @options[this_index]
    case option[:type]
    when :array, :array_one
      return @values[this_index] - 1
    when :number_type
      case option[:parameters]
      when Range
        ret = @values[this_index] - 1
        ret = highest_value(option) - lowest_value(option) if ret < 0   # Wrap around
        return ret
      when Array
        highest = highest_value(option)
        lowest = lowest_value(option)
        interval = option[:parameters][2]
        if @values[this_index] > 0
          ret = @values[this_index] - interval
          ret = 0 if ret < 0
        else
          ret = highest - lowest   # Wrap around
        end
        return ret
      end
    when :number_slider
      highest = highest_value(option)
      lowest = lowest_value(option)
      interval = option[:parameters][2]
      if @values[this_index] > 0
        ret = @values[this_index] - interval
        ret = 0 if ret < 0
        return ret
      end
    end
    return @values[this_index]
  end

  def next_value(this_index)
    option = @options[this_index]
    case option[:type]
    when :array, :array_one
      return @values[this_index] + 1 if @values[this_index] < option[:parameters].length - 1
    when :number_type
      case option[:parameters]
      when Range
        ret = @values[this_index] + 1
        ret = 0 if ret > highest_value(option) - lowest_value(option)   # Wrap around
        return ret
      when Array
        highest = highest_value(option)
        lowest = lowest_value(option)
        interval = option[:parameters][2]
        if @values[this_index] < highest - lowest
          ret = @values[this_index] + interval
          ret = highest - lowest if ret > highest - lowest
        else
          ret = 0   # Wrap around
        end
        return ret
      end
    when :number_slider
      highest = highest_value(option)
      lowest = lowest_value(option)
      interval = option[:parameters][2]
      if @values[this_index] < highest - lowest
        ret = @values[this_index] + interval
        ret = highest - lowest if ret > highest - lowest
        return ret
      end
    end
    return @values[this_index]
  end

  def value(this_index = nil)
    return @values[this_index || self.index]
  end

  def selected_option
    return @options[self.index]
  end

  #-----------------------------------------------------------------------------

  def drawItem(this_index, _count, rect)
    rect = drawCursor(this_index, rect)
    option_start_x = (rect.x + rect.width) / 2
    draw_option_name(this_index, rect, option_start_x)
    draw_option_values(this_index, rect, option_start_x) if this_index < @options.length
  end

  def draw_option_name(this_index, rect, option_start_x)
    if this_index >= @options.length
      pbDrawShadowText(self.contents, rect.x, rect.y, option_start_x, rect.height,
                       _INTL("Back"), self.baseColor, self.shadowColor)
      return
    end
    option = @options[this_index]
    option_name = option[:name]
    option_name_x = rect.x
    option_colors = [self.optionColor, self.optionShadowColor]
    case option[:type]
    when :control
      # Draw icon
      input_index = UI::BaseVisuals::INPUT_ICONS_ORDER.index(option[:parameters]) || 0
      src_rect = Rect.new(input_index * @input_icons_bitmap.height, 0,
                          @input_icons_bitmap.height, @input_icons_bitmap.height)
      self.contents.blt(rect.x, rect.y + 2, @input_icons_bitmap.bitmap, src_rect)
      # Adjust text position
      option_name_x += @input_icons_bitmap.height + 6
    when :use
      option_colors = [self.baseColor, self.shadowColor]
    end
    pbDrawShadowText(self.contents, option_name_x, rect.y, option_start_x, rect.height,
                     option_name, *option_colors)
  end

  def draw_option_values(this_index, rect, option_start_x)
    option_width = rect.x + rect.width - option_start_x
    option = @options[this_index]
    case option[:type]
    when :array
      total_width = 0
      option[:parameters].each { |value| total_width += self.contents.text_size(value).width }
      spacing = (rect.width - option_start_x - total_width) / (option[:parameters].length - 1)
      spacing = 0 if spacing < 0
      x_pos = option_start_x
      option[:parameters].each_with_index do |value, i|
        pbDrawShadowText(self.contents, x_pos, rect.y, option_width, rect.height,
                         value,
                         (i == @values[this_index]) ? self.selectedColor : self.baseColor,
                         (i == @values[this_index]) ? self.selectedShadowColor : self.shadowColor)
        draw_selection_brackets(x_pos, rect.y, value, rect, option_width) if i == @values[this_index]
        if option[:parameters].length == 2
          x_pos += @array_second_value_x
        else
          x_pos += self.contents.text_size(value).width + spacing
        end
      end
    when :number_type
      lowest = lowest_value(option)
      highest = highest_value(option)
      value = _INTL("Type {1}/{2}", lowest + @values[this_index], highest - lowest + 1)
      pbDrawShadowText(self.contents, option_start_x, rect.y, option_width, rect.height,
                       value, self.baseColor, self.shadowColor)
    when :number_slider
      lowest = lowest_value(option)
      highest = highest_value(option)
      spacing = 6   # Gap between slider and number
      # Draw slider bar
      slider_length = option_width - rect.x - self.contents.text_size(highest.to_s).width - spacing
      x_pos = option_start_x
      self.contents.fill_rect(x_pos, rect.y + (rect.height / 2) - 2, slider_length, 4, self.baseColor)
      # Draw slider notch
      self.contents.fill_rect(
        x_pos + ((slider_length - 8) * (@values[this_index] - lowest) / (highest - lowest)),
        rect.y + (rect.height / 2) - 8,
        8, 16, self.selectedColor
      )
      # Draw text
      value = (lowest + @values[this_index]).to_s
      pbDrawShadowText(self.contents, x_pos - rect.x, rect.y, option_width, rect.height,
                       value, self.selectedColor, self.selectedShadowColor, 2)
    when :control
      x_pos = option_start_x
      spacing = option_width / 2
      @values[this_index].each_with_index do |value, i|
        if value
          text = Input.input_name(value, (i == 0) ? :keyboard : :gamepad)
          text_colors = [self.baseColor, self.shadowColor]
        else
          text = "---"
          text_colors = [self.unsetColor, self.unsetShadowColor]
        end
        pbDrawShadowText(self.contents, x_pos, rect.y, option_width, rect.height,
                         text, *text_colors)
        x_pos += spacing
      end
    when :use
      # Draw nothing
    else
      value = option[:parameters][@values[this_index]]
      pbDrawShadowText(self.contents, option_start_x, rect.y, option_width, rect.height,
                       value, self.baseColor, self.shadowColor)
    end
  end

  def draw_selection_brackets(text_x, text_y, text, rect, option_width)
    pbDrawShadowText(self.contents, text_x - option_width, text_y, option_width, rect.height,
                     "[", self.selectedColor, self.selectedShadowColor, 2)
    pbDrawShadowText(self.contents, text_x + self.contents.text_size(text).width, text_y, option_width, rect.height,
                     "]", self.selectedColor, self.selectedShadowColor, 0)
  end

  #-----------------------------------------------------------------------------

  def update
    return if @index < 0
    old_index = self.index
    @value_changed = false
    super
    need_refresh = (self.index != old_index)
    if self.index < @options.length &&
       [:array, :array_one, :number_type, :number_slider].include?(@options[self.index][:type])
      old_value = @values[self.index]
      if Input.repeat?(Input::LEFT)
        @values[self.index] = previous_value(self.index)
      elsif Input.repeat?(Input::RIGHT)
        @values[self.index] = next_value(self.index)
      end
      if self.value != old_value
        pbPlayCursorSE if selected_option[:type] != :number_slider
        need_refresh = true
        @value_changed = true
      end
    end
    refresh if need_refresh
  end
end

#===============================================================================
#
#===============================================================================
class UI::OptionsVisuals < UI::BaseVisuals
  attr_reader :page
  attr_reader :in_load_screen

  GRAPHICS_FOLDER   = "Options/"   # Subfolder in Graphics/UI
  TEXT_COLOR_THEMES = {   # Themes not in DEFAULT_TEXT_COLOR_THEMES
    :page_name        => [Color.new(248, 248, 248), Color.new(168, 184, 184)],
    :option_name      => [Color.new(192, 120, 0), Color.new(248, 176, 80)],
    :unselected_value => [Color.new(80, 80, 88), Color.new(160, 160, 168)],
    :selected_value   => [Color.new(248, 48, 24), Color.new(248, 136, 128)],
    :unset_control    => [Color.new(160, 160, 168), Color.new(224, 224, 232)]
  }
  OPTIONS_VISIBLE  = 6
  PAGE_TAB_SPACING = 4

  #-----------------------------------------------------------------------------

  PAGE_HANDLERS = HandlerHash.new
  PAGE_HANDLERS.add(:gameplay, {
    :name  => proc { next _INTL("Gameplay") },
    :order => 10,
    :description => proc { next _INTL("Change how the game behaves.") }
  })
  PAGE_HANDLERS.add(:audio, {
    :name  => proc { next _INTL("Audio") },
    :order => 20,
    :description => proc { next _INTL("Change the game's volume.") }
  })
  PAGE_HANDLERS.add(:graphics, {
    :name  => proc { next _INTL("Graphics") },
    :order => 30,
    :description => proc { next _INTL("Change how the game appears.") }
  })
  PAGE_HANDLERS.add(:controls, {
    :name  => proc { next _INTL("Controls") },
    :order => 40,
    :description => proc { next _INTL("Edit the keyboard controls.") }
  })

  #-----------------------------------------------------------------------------

  def initialize(options, in_load_screen = false)
    @options        = options
    @in_load_screen = in_load_screen
    @page           = all_pages.first
    super()
  end

  def initialize_bitmaps
    super
    @bitmaps[:page_icons] = AnimatedBitmap.new(graphics_folder + "page_icons")
  end

  def initialize_message_box
    super
    @sprites[:speech_box].letterbyletter = false
    @sprites[:speech_box].visible        = true
  end

  def initialize_sprites
    initialize_page_tabs
    initialize_page_cursor
    initialize_options_list
  end

  def initialize_page_tabs
    add_overlay(:page_icons,
                all_pages.length * ((@bitmaps[:page_icons].width / 2) + PAGE_TAB_SPACING),
                @bitmaps[:page_icons].height)
    @sprites[:page_icons].x = Graphics.width - @sprites[:page_icons].width
    @sprites[:page_icons].y = 4
  end

  def initialize_page_cursor
    add_icon_sprite(:page_cursor, @sprites[:page_icons].x - 2, @sprites[:page_icons].y - 2,
                    graphics_folder + "page_cursor")
    @sprites[:page_cursor].z = 1100
  end

  def initialize_options_list
    @sprites[:options_list] = UI::OptionsVisualsList.new(0, 64, Graphics.width, (OPTIONS_VISIBLE * 32) + 32, @viewport)
    @sprites[:options_list].optionColor         = get_text_color_theme(:option_name)[0]
    @sprites[:options_list].optionShadowColor   = get_text_color_theme(:option_name)[1]
    @sprites[:options_list].baseColor           = get_text_color_theme(:unselected_value)[0]
    @sprites[:options_list].shadowColor         = get_text_color_theme(:unselected_value)[1]
    @sprites[:options_list].selectedColor       = get_text_color_theme(:selected_value)[0]
    @sprites[:options_list].selectedShadowColor = get_text_color_theme(:selected_value)[1]
    @sprites[:options_list].unsetColor          = get_text_color_theme(:unset_control)[0]
    @sprites[:options_list].unsetShadowColor    = get_text_color_theme(:unset_control)[1]
    @sprites[:options_list].options             = options_for_page(@page)
  end

  #-----------------------------------------------------------------------------

  def all_pages
    ret = []
    PAGE_HANDLERS.each { |key, hash| ret.push([key, hash[:order] || 0]) }
    ret.sort_by! { |val| val[1] }
    ret.map! { |val| val[0] }
    return ret
  end

  def set_page(value)
    return if @page == value
    @page = value
    @sprites[:options_list].options = options_for_page(@page)
    refresh
  end

  def go_to_next_page
    pages = all_pages
    page_number = pages.index(@page)
    new_page = pages[(page_number + 1) % pages.length]
    return if new_page == @page
    pbPlayCursorSE
    set_page(new_page)
  end

  def go_to_previous_page
    pages = all_pages
    page_number = pages.index(@page)
    new_page = pages[(page_number - 1) % pages.length]
    return if new_page == @page
    pbPlayCursorSE
    set_page(new_page)
  end

  def index
    return @sprites[:options_list].index
  end

  def set_index(value)
    old_index = index
    @sprites[:options_list].index = value
    refresh_on_index_changed(old_index)
  end

  def options_for_page(this_page)
    return @options.filter { |option| option[:page] == this_page }
  end

  def selected_option
    return @sprites[:options_list].selected_option
  end

  #-----------------------------------------------------------------------------

  def refresh
    super
    refresh_page_tabs
    refresh_page_cursor
    refresh_options_list
    refresh_selected_option
  end

  def refresh_on_index_changed(old_index)
    refresh_selected_option
    if (old_index < 0) != (index < 0)
      refresh_page_cursor
      refresh_options_list
    end
  end

  def refresh_page_tabs
    @sprites[:page_icons].bitmap.clear
    all_pages.each_with_index do |this_page, i|
      tab_x = i * ((@bitmaps[:page_icons].width / 2) + PAGE_TAB_SPACING)
      draw_image(@bitmaps[:page_icons], tab_x, 0,
                 (this_page == @page) ? @bitmaps[:page_icons].width / 2 : 0, 0,
                 @bitmaps[:page_icons].width / 2, @bitmaps[:page_icons].height, overlay: :page_icons)
      page_name = PAGE_HANDLERS[this_page][:name].call
      draw_text(page_name, tab_x + (@bitmaps[:page_icons].width / 4), 14,
                align: :center, theme: :page_name, overlay: :page_icons)
    end
  end

  def refresh_page_cursor
    @sprites[:page_cursor].visible = (index < 0)
    @sprites[:page_cursor].x = @sprites[:page_icons].x - 2
    @sprites[:page_cursor].x += all_pages.index(@page) * ((@bitmaps[:page_icons].width / 2) + PAGE_TAB_SPACING)
  end

  def refresh_options_list
    @sprites[:options_list].refresh
  end

  def refresh_selected_option
    # Call selected option's "on_select" proc (if defined)
    @sprites[:speech_box].letterbyletter = false
    # Set descriptive text
    description = ""
    option = selected_option
    if index < 0   # Selecting a tab
      if PAGE_HANDLERS[@page][:description].is_a?(Proc)
        description = PAGE_HANDLERS[@page][:description].call
      elsif !PAGE_HANDLERS[@page][:description].nil?
        description = _INTL(PAGE_HANDLERS[@page][:description])
      end
    elsif option
      option[:on_select]&.call(self)   # Can change speech box's letterbyletter
      if option[:description].is_a?(Proc)
        description = option[:description].call
      elsif !option[:description].nil?
        description = _INTL(option[:description])
      end
    else   # Back
      description = _INTL("Go back.")
    end
    @sprites[:speech_box].text = description
  end

  #-----------------------------------------------------------------------------

  def update_input_tabs
    if Input.repeat?(Input::DOWN)
      pbPlayCursorSE
      set_index(0)
    elsif Input.repeat?(Input::LEFT)
      go_to_previous_page
    elsif Input.repeat?(Input::RIGHT)
      go_to_next_page
    end
    # Check for interaction
    if Input.trigger?(Input::USE)
      pbPlayCursorSE
      set_index(0)
    elsif Input.trigger?(Input::BACK)
      pbPlayCloseMenuSE
      return :quit
    end
    return nil
  end

  def update_input
    # Update value change
    if @sprites[:options_list].value_changed
      selected_option[:set_proc].call(@sprites[:options_list].value, self)
    end
    # Do page selection
    return update_input_tabs if @sprites[:options_list].index < 0
    # Check for interaction
    if Input.trigger?(Input::USE)
      if selected_option && selected_option[:use_proc]
        pbPlayDecisionSE
        return :use_option
      end
    elsif Input.trigger?(Input::BACK)
      pbPlayCancelSE
      set_index(-1)
    end
    return nil
  end

  def change_key_or_button
    this_input = selected_option[:parameters]
    @sprites[:speech_box].text = _INTL("Press a key or Esc to cancel.")
    pressed_key = nil
    pressed_button = nil
    # Detect key/button press
    loop do
      Graphics.update
      Input.update
      # Cancel
      if Input::DEFAULT_INPUT_MAPPINGS[Input::BACK].flatten.any? { |key| Input.pressex?(key) }
        pbPlayCancelSE
        break
      end
      # Check for key/button press
      Input::REMAP_KEYBOARD_KEYS.keys.each do |key|
        pressed_key = key if Input.triggerex?(key)
        break if pressed_key
      end
      break if pressed_key
      Input::REMAP_GAMEPAD_BUTTONS.keys.each do |key|
        pressed_button = key if Input::Controller.triggerex?(key)
        break if pressed_button
      end
      break if pressed_button
      Input::REMAP_GAMEPAD_AXIS.keys.each do |key|
        pressed_button = key if Input.axis_triggerex?(key)
        break if pressed_button
      end
      break if pressed_button
    end
    # Change input binding if key/button was pressed
    if pressed_key || pressed_button
      pbPlayDecisionSE
      control_index = (pressed_key ? 0 : 1)
      if $PokemonSystem.controls[this_input][control_index] == (pressed_key || pressed_button)
        $PokemonSystem.controls[this_input][control_index] = nil
      else
        $PokemonSystem.controls[this_input][control_index] = pressed_key || pressed_button
        $PokemonSystem.controls.each_pair do |ctrl_input, keys|
          keys[0] = nil if ctrl_input != this_input && pressed_key && keys[0] == pressed_key
          keys[1] = nil if ctrl_input != this_input && pressed_button && keys[1] == pressed_button
        end
      end
    end
    # Clean up
    @sprites[:options_list].get_values
    refresh
    Input.update
  end
end

#===============================================================================
#
#===============================================================================
class UI::Options < UI::BaseScreen
  ACTIONS = HandlerHash.new

  def initialize(in_load_screen = false)
    @in_load_screen = in_load_screen
    @options = get_all_options
    super()
  end

  def initialize_visuals
    @visuals = UI::OptionsVisuals.new(@options, @in_load_screen)
  end

  def get_all_options
    ret = []
    MenuHandlers.each_available(:options_menu) do |option, hash, name|
      if hash["description"].is_a?(Proc)
        description = hash["description"].call
      elsif !hash["description"].nil?
        description = _INTL(hash["description"])
      end
      ret.push({
        :option      => option,
        :page        => hash["page"],
        :name        => name,
        :description => description,
        :type        => hash["type"],
        :parameters  => hash["parameters"],
        :on_select   => hash["on_select"],
        :get_proc    => hash["get_proc"],
        :set_proc    => hash["set_proc"],
        :use_proc    => hash["use_proc"]
      })
      ret.last[:parameters].map! { |val| _INTL(val) } if ret.last[:type] == :array
    end
    return ret
  end

  ACTIONS.add(:use_option, {
    :effect => proc { |screen|
      option = screen.visuals.selected_option
      option[:use_proc].call(screen)
    }
  })
end

#===============================================================================
# Options Menu commands.
#===============================================================================

MenuHandlers.add(:options_menu, :battle_style, {
  "page"        => :gameplay,
  "name"        => _INTL("Battle Style"),
  "order"       => 10,
  "type"        => :array,
  "parameters"  => [_INTL("Switch"), _INTL("Set")],
  "description" => _INTL("Choose whether you can switch Pokémon when an opponent's Pokémon faints."),
  "get_proc"    => proc { next $PokemonSystem.battlestyle },
  "set_proc"    => proc { |value, _screen| $PokemonSystem.battlestyle = value }
})

MenuHandlers.add(:options_menu, :movement_style, {
  "page"        => :gameplay,
  "name"        => _INTL("Default Movement"),
  "order"       => 20,
  "type"        => :array,
  "parameters"  => [_INTL("Walking"), _INTL("Running")],
  "description" => _INTL("Choose your movement speed. Hold Back while moving to move at the other speed."),
  "condition"   => proc { next $player&.has_running_shoes },
  "get_proc"    => proc { next $PokemonSystem.runstyle },
  "set_proc"    => proc { |value, _sceme| $PokemonSystem.runstyle = value }
})

MenuHandlers.add(:options_menu, :send_to_boxes, {
  "page"        => :gameplay,
  "name"        => _INTL("Send to Boxes"),
  "order"       => 30,
  "type"        => :array,
  "parameters"  => [_INTL("Manual"), _INTL("Automatic")],
  "description" => _INTL("Choose whether caught Pokémon are sent to your Boxes when your party is full."),
  "condition"   => proc { next Settings::NEW_CAPTURE_CAN_REPLACE_PARTY_MEMBER },
  "get_proc"    => proc { next $PokemonSystem.sendtoboxes },
  "set_proc"    => proc { |value, _screen| $PokemonSystem.sendtoboxes = value }
})

MenuHandlers.add(:options_menu, :give_nicknames, {
  "page"        => :gameplay,
  "name"        => _INTL("Give Nicknames"),
  "order"       => 40,
  "type"        => :array,
  "parameters"  => [_INTL("Give"), _INTL("Don't give")],
  "description" => _INTL("Choose whether you can give a nickname to a Pokémon when you obtain it."),
  "get_proc"    => proc { next $PokemonSystem.givenicknames },
  "set_proc"    => proc { |value, _screen| $PokemonSystem.givenicknames = value }
})

MenuHandlers.add(:options_menu, :text_input_style, {
  "page"        => :gameplay,
  "name"        => _INTL("Text Entry"),
  "order"       => 50,
  "type"        => :array,
  "parameters"  => [_INTL("Cursor"), _INTL("Free type")],
  "description" => _INTL("Choose how you want to enter text."),
  "get_proc"    => proc { next $PokemonSystem.textinput },
  "set_proc"    => proc { |value, _screen| $PokemonSystem.textinput = value }
})

MenuHandlers.add(:options_menu, :language, {
  "page"        => :gameplay,
  "name"        => _INTL("Language"),
  "order"       => 60,
  "type"        => (Settings::LANGUAGES.length == 2) ? :array : :array_one,
  "parameters"  => Settings::LANGUAGES.map { |lang| lang[0] },
  "description" => _INTL("Choose the game's language."),
  "condition"   => proc { next Settings::LANGUAGES.length >= 2 },
  "get_proc"    => proc { next $PokemonSystem.language },
  "set_proc"    => proc { |value, _screen| $PokemonSystem.language = value }
})

#-------------------------------------------------------------------------------

MenuHandlers.add(:options_menu, :main_volume, {
  "page"        => :audio,
  "name"        => _INTL("Main Volume"),
  "order"       => 10,
  "type"        => :number_slider,
  "parameters"  => [0, 100, 5],   # [minimum_value, maximum_value, interval]
  "description" => _INTL("Adjust the volume of all audio in the game."),
  "get_proc"    => proc { next $PokemonSystem.main_volume },
  "set_proc"    => proc { |value, screen| $PokemonSystem.main_volume = value }
})

MenuHandlers.add(:options_menu, :bgm_volume, {
  "page"        => :audio,
  "name"        => _INTL("Background Music"),
  "order"       => 20,
  "type"        => :number_slider,
  "parameters"  => [0, 100, 5],   # [minimum_value, maximum_value, interval]
  "description" => _INTL("Adjust the volume of the background music."),
  "get_proc"    => proc { next $PokemonSystem.bgmvolume },
  "set_proc"    => proc { |value, screen| $PokemonSystem.bgmvolume = value }
})

MenuHandlers.add(:options_menu, :se_volume, {
  "page"        => :audio,
  "name"        => _INTL("Sound Effects"),
  "order"       => 30,
  "type"        => :number_slider,
  "parameters"  => [0, 100, 5],   # [minimum_value, maximum_value, interval]
  "description" => _INTL("Adjust the volume of sound effects."),
  "get_proc"    => proc { next $PokemonSystem.sevolume },
  "set_proc"    => proc { |value, _screen|
    next if $PokemonSystem.sevolume == value
    $PokemonSystem.sevolume = value
    pbPlayCursorSE
  }
})

MenuHandlers.add(:options_menu, :pokemon_cry_volume, {
  "page"        => :audio,
  "name"        => _INTL("Pokémon Cries"),
  "order"       => 40,
  "type"        => :number_slider,
  "parameters"  => [0, 100, 5],   # [minimum_value, maximum_value, interval]
  "description" => _INTL("Adjust the volume of Pokémon cries."),
  "get_proc"    => proc { next $PokemonSystem.pokemon_cry_volume },
  "set_proc"    => proc { |value, _screen|
    next if $PokemonSystem.pokemon_cry_volume == value
    $PokemonSystem.pokemon_cry_volume = value
    pbPlayCursorSE
  }
})

#-------------------------------------------------------------------------------

MenuHandlers.add(:options_menu, :text_speed, {
  "page"        => :graphics,
  "name"        => _INTL("Text Speed"),
  "order"       => 10,
  "type"        => :array,
  "parameters"  => [_INTL("Slow"), _INTL("Mid"), _INTL("Fast"), _INTL("Inst")],
  "description" => _INTL("Choose the speed at which text appears."),
  "on_select"   => proc { |screen| screen.sprites[:speech_box].letterbyletter = true },
  "get_proc"    => proc { next $PokemonSystem.textspeed },
  "set_proc"    => proc { |value, screen|
    next if value == $PokemonSystem.textspeed
    $PokemonSystem.textspeed = value
    # Display the message with the selected text speed to gauge it better.
    screen.sprites[:speech_box].textspeed      = MessageConfig.pbGetTextSpeed
    screen.sprites[:speech_box].letterbyletter = true
    screen.sprites[:speech_box].text           = screen.sprites[:speech_box].text
  }
})

MenuHandlers.add(:options_menu, :battle_animations, {
  "page"        => :graphics,
  "name"        => _INTL("Battle Effects"),
  "order"       => 20,
  "type"        => :array,
  "parameters"  => [_INTL("On"), _INTL("Off")],
  "description" => _INTL("Choose whether you wish to see move animations in battle."),
  "get_proc"    => proc { next $PokemonSystem.battlescene },
  "set_proc"    => proc { |value, _screen| $PokemonSystem.battlescene = value }
})

MenuHandlers.add(:options_menu, :speech_frame, {
  "page"        => :graphics,
  "name"        => _INTL("Speech Frame"),
  "order"       => 30,
  "type"        => :number_type,
  "parameters"  => 1..Settings::SPEECH_WINDOWSKINS.length,
  "description" => _INTL("Choose the appearance of dialogue boxes."),
  "condition"   => proc { next Settings::SPEECH_WINDOWSKINS.length > 1 },
  "get_proc"    => proc { next $PokemonSystem.textskin },
  "set_proc"    => proc { |value, screen|
    $PokemonSystem.textskin = value
    # Change the windowskin of the options text box to selected one
    screen.sprites[:speech_box].setSkin(MessageConfig.pbGetSpeechFrame)
  }
})

MenuHandlers.add(:options_menu, :menu_frame, {
  "page"        => :graphics,
  "name"        => _INTL("Menu Frame"),
  "order"       => 40,
  "type"        => :number_type,
  "parameters"  => 1..Settings::MENU_WINDOWSKINS.length,
  "description" => _INTL("Choose the appearance of menu boxes."),
  "condition"   => proc { next Settings::MENU_WINDOWSKINS.length > 1 },
  "get_proc"    => proc { next $PokemonSystem.frame },
  "set_proc"    => proc { |value, screen|
    $PokemonSystem.frame = value
    # Change the windowskin of the options text box to selected one
    screen.sprites[:options_list].setSkin(MessageConfig.pbGetSystemFrame)
  }
})

MenuHandlers.add(:options_menu, :screen_size, {
  "page"        => :graphics,
  "name"        => _INTL("Screen Size"),
  "order"       => 50,
  "type"        => :array,
  "parameters"  => [_INTL("S"), _INTL("M"), _INTL("L"), _INTL("XL"), _INTL("Full")],
  "description" => _INTL("Choose the size of the game window."),
  "get_proc"    => proc { next [$PokemonSystem.screensize, 4].min },
  "set_proc"    => proc { |value, _screen| $PokemonSystem.screensize = value }
})

#-------------------------------------------------------------------------------

MenuHandlers.add(:options_menu, :control_up, {
  "page"        => :controls,
  "name"        => _INTL("Up"),
  "order"       => 10,
  "type"        => :control,
  "parameters"  => Input::UP,
  "description" => _INTL("Moves around in the field. Navigates menus and moves cursors. [Also: Up]"),
  "get_proc"    => proc { next $PokemonSystem.controls[Input::UP] },
  "set_proc"    => proc { |value, _screen| $PokemonSystem.controls[Input::UP] = value },
  "use_proc"    => proc { |screen| screen.visuals.change_key_or_button }
})

MenuHandlers.add(:options_menu, :control_left, {
  "page"        => :controls,
  "name"        => _INTL("Left"),
  "order"       => 20,
  "type"        => :control,
  "parameters"  => Input::LEFT,
  "description" => _INTL("Moves around in the field. Navigates menus and moves cursors. [Also: Left]"),
  "get_proc"    => proc { next $PokemonSystem.controls[Input::LEFT] },
  "set_proc"    => proc { |value, _screen| $PokemonSystem.controls[Input::LEFT] = value },
  "use_proc"    => proc { |screen| screen.visuals.change_key_or_button }
})

MenuHandlers.add(:options_menu, :control_down, {
  "page"        => :controls,
  "name"        => _INTL("Down"),
  "order"       => 30,
  "type"        => :control,
  "parameters"  => Input::DOWN,
  "description" => _INTL("Moves around in the field. Navigates menus and moves cursors. [Also: Down]"),
  "get_proc"    => proc { next $PokemonSystem.controls[Input::DOWN] },
  "set_proc"    => proc { |value, _screen| $PokemonSystem.controls[Input::DOWN] = value },
  "use_proc"    => proc { |screen| screen.visuals.change_key_or_button }
})

MenuHandlers.add(:options_menu, :control_right, {
  "page"        => :controls,
  "name"        => _INTL("Right"),
  "order"       => 40,
  "type"        => :control,
  "parameters"  => Input::RIGHT,
  "description" => _INTL("Moves around in the field. Navigates menus and moves cursors. [Also: Right]"),
  "get_proc"    => proc { next $PokemonSystem.controls[Input::RIGHT] },
  "set_proc"    => proc { |value, _screen| $PokemonSystem.controls[Input::RIGHT] = value },
  "use_proc"    => proc { |screen| screen.visuals.change_key_or_button }
})

MenuHandlers.add(:options_menu, :control_use, {
  "page"        => :controls,
  "name"        => _INTL("Use"),
  "order"       => 50,
  "type"        => :control,
  "parameters"  => Input::USE,
  "description" => _INTL("Interacts with a thing or person. Makes a choice. [Also: Return, Space]"),
  "get_proc"    => proc { next $PokemonSystem.controls[Input::USE] },
  "set_proc"    => proc { |value, _screen| $PokemonSystem.controls[Input::USE] = value },
  "use_proc"    => proc { |screen| screen.visuals.change_key_or_button }
})

MenuHandlers.add(:options_menu, :control_back, {
  "page"        => :controls,
  "name"        => _INTL("Back"),
  "order"       => 60,
  "type"        => :control,
  "parameters"  => Input::BACK,
  "description" => _INTL("Exits menus and cancels choices. Changes field movement speed if held. [Also: Esc]"),
  "get_proc"    => proc { next $PokemonSystem.controls[Input::BACK] },
  "set_proc"    => proc { |value, _screen| $PokemonSystem.controls[Input::BACK] = value },
  "use_proc"    => proc { |screen| screen.visuals.change_key_or_button }
})

MenuHandlers.add(:options_menu, :control_action, {
  "page"        => :controls,
  "name"        => _INTL("Action"),
  "order"       => 70,
  "type"        => :control,
  "parameters"  => Input::ACTION,
  "description" => _INTL("Opens the Pause Menu in the field. Extra actions in some menus. [Also: Backspace]"),
  "get_proc"    => proc { next $PokemonSystem.controls[Input::ACTION] },
  "set_proc"    => proc { |value, _screen| $PokemonSystem.controls[Input::ACTION] = value },
  "use_proc"    => proc { |screen| screen.visuals.change_key_or_button }
})

MenuHandlers.add(:options_menu, :control_jump_up, {
  "page"        => :controls,
  "name"        => _INTL("Quick Up"),
  "order"       => 80,
  "type"        => :control,
  "parameters"  => Input::QUICK_UP,
  "description" => _INTL("Opens the Ready Menu in the field. Quickly navigates left or up in some menus."),
  "get_proc"    => proc { next $PokemonSystem.controls[Input::QUICK_UP] },
  "set_proc"    => proc { |value, _screen| $PokemonSystem.controls[Input::QUICK_UP] = value },
  "use_proc"    => proc { |screen| screen.visuals.change_key_or_button }
})

MenuHandlers.add(:options_menu, :control_jump_down, {
  "page"        => :controls,
  "name"        => _INTL("Quick Down"),
  "order"       => 90,
  "type"        => :control,
  "parameters"  => Input::QUICK_DOWN,
  "description" => _INTL("Opens the Ready Menu in the field. Quickly navigates right or down in some menus."),
  "get_proc"    => proc { next $PokemonSystem.controls[Input::QUICK_DOWN] },
  "set_proc"    => proc { |value, _screen| $PokemonSystem.controls[Input::QUICK_DOWN] = value },
  "use_proc"    => proc { |screen| screen.visuals.change_key_or_button }
})

MenuHandlers.add(:options_menu, :reset_controls, {
  "page"        => :controls,
  "name"        => _INTL("Reset Controls"),
  "order"       => 900,
  "type"        => :use,
  "description" => _INTL("Reset all key bindings to their default values."),
  "use_proc"    => proc { |screen|
    $PokemonSystem.reset_controls
    screen.sprites[:options_list].get_values
    screen.refresh
    Input.update
  }
})
