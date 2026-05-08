#===============================================================================
#
#===============================================================================
class UI::PartyVisualsPanel < UI::SpriteContainer
  attr_reader :index, :switch_index
  attr_reader :pokemon, :text

  GRAPHICS_FOLDER = "Party/"
  TEXT_COLOR_THEMES = {   # Themes not in DEFAULT_TEXT_COLOR_THEMES
    :male    => [Color.new(0, 112, 248), Color.new(120, 184, 232)],
    :female  => [Color.new(232, 32, 16), Color.new(248, 168, 184)]
  }

  def initialize(pokemon, index, viewport)
    @pokemon      = pokemon
    @index        = index
    @x            = (@index % 2) * Graphics.width / 2
    @y            = (16 * (@index % 2)) + (96 * (@index / 2))
    @selected     = false
    @switch_index = -1   # -1 = not switching, 0+ = index of first panel for switching
    @text         = nil
    super(viewport)
  end

  def initialize_bitmaps
    @bitmaps[:numbers] = AnimatedBitmap.new(graphics_folder + "numbers")
  end

  def initialize_sprites
    initialize_panel_bg
    initialize_overlay
    initialize_other_sprites
  end

  def initialize_panel_bg
    @sprites[:panel_bg] = ChangelingSprite.new(0, 0, @viewport)
    @sprites[:panel_bg].add_bitmap(:blank,       graphics_folder + "panel_blank")
    @sprites[:panel_bg].add_bitmap(:able,        graphics_folder + "panel_rect")
    @sprites[:panel_bg].add_bitmap(:able_sel,    graphics_folder + "panel_rect_sel")
    @sprites[:panel_bg].add_bitmap(:fainted,     graphics_folder + "panel_rect_faint")
    @sprites[:panel_bg].add_bitmap(:fainted_sel, graphics_folder + "panel_rect_faint_sel")
    @sprites[:panel_bg].add_bitmap(:switch,      graphics_folder + "panel_rect_switch")
    @sprites[:panel_bg].add_bitmap(:switch_sel,  graphics_folder + "panel_rect_switch_sel")
    @sprites[:panel_bg].add_bitmap(:switch_sel2, graphics_folder + "panel_rect_switch_sel2")
    record_values(:panel_bg)
  end

  def initialize_overlay
    add_overlay(:overlay, 256, 98)
    record_values(:overlay)
  end

  def initialize_other_sprites
    # HP bar sprite
    @sprites[:hp_bar] = ChangelingSprite.new(104, 50, @viewport)
    @sprites[:hp_bar].z = 1
    @sprites[:hp_bar].add_bitmap(:able, graphics_folder + _INTL("hp_bar"))
    @sprites[:hp_bar].add_bitmap(:fainted, graphics_folder + _INTL("hp_bar_faint"))
    @sprites[:hp_bar].add_bitmap(:switch, graphics_folder + _INTL("hp_bar_switch"))
    record_values(:hp_bar)
    # Ball sprite
    @sprites[:ball] = ChangelingSprite.new(10, 0, @viewport)
    @sprites[:ball].z = 1
    @sprites[:ball].add_bitmap(:desel, graphics_folder + "icon_ball")
    @sprites[:ball].add_bitmap(:sel, graphics_folder + "icon_ball_sel")
    record_values(:ball)
    # Pokémon icon
    @sprites[:pokemon] = PokemonIconSprite.new(@pokemon, @viewport)
    @sprites[:pokemon].x = 60
    @sprites[:pokemon].y = 40
    @sprites[:pokemon].z = 2
    @sprites[:pokemon].setOffset(PictureOrigin::CENTER)
    @sprites[:pokemon].active = @active
    record_values(:pokemon)
    # Held item icon
    @sprites[:held_item] = HeldItemIconSprite.new(70, 48, @pokemon, @viewport)
    @sprites[:held_item].z = 3
    record_values(:held_item)
  end

  #-----------------------------------------------------------------------------

  def text=(value)
    return if @text == value
    @text = value
    refresh
  end

  def pokemon=(value)
    @pokemon = value
    @sprites[:pokemon].pokemon = @pokemon if @sprites[:pokemon] && !@sprites[:pokemon].disposed?
    @sprites[:held_item].pokemon = @pokemon if @sprites[:held_item] && !@sprites[:held_item].disposed?
    refresh
  end

  def blank?
    return @pokemon.nil?
  end

  def selected=(value)
    return if @selected == value
    @selected = value
    @sprites[:pokemon].selected = @selected
    refresh
  end

  def set_switch_index(value)
    @switch_index = value
    refresh
  end

  #-----------------------------------------------------------------------------

  def refresh
    super
    refresh_panel_bg
    refresh_hp_bar_graphic
    refresh_ball_graphic
    refresh_pokemon_icon
    refresh_held_item_icon
  end

  def refresh_panel_bg
    return if !@sprites[:panel_bg] || @sprites[:panel_bg].disposed?
    if @pokemon.nil?
      @sprites[:panel_bg].change_bitmap(:blank)
    elsif @selected
      if @switch_index == @index
        @sprites[:panel_bg].change_bitmap(:switch_sel2)
      elsif @switch_index >= 0
        @sprites[:panel_bg].change_bitmap(:switch_sel)
      elsif @pokemon.fainted?
        @sprites[:panel_bg].change_bitmap(:fainted_sel)
      else
        @sprites[:panel_bg].change_bitmap(:able_sel)
      end
    else
      if @switch_index == @index
        @sprites[:panel_bg].change_bitmap(:switch)
      elsif @pokemon.fainted?
        @sprites[:panel_bg].change_bitmap(:fainted)
      else
        @sprites[:panel_bg].change_bitmap(:able)
      end
    end
  end

  def refresh_hp_bar_graphic
    return if !@sprites[:hp_bar] || @sprites[:hp_bar].disposed?
    @sprites[:hp_bar].visible = (@pokemon && !@pokemon.egg? && !(@text && @text.length > 0))
    return if !@sprites[:hp_bar].visible
    if @switch_index == @index || (@switch_index >= 0 && @selected)
      @sprites[:hp_bar].change_bitmap(:switch)
    elsif @pokemon.fainted?
      @sprites[:hp_bar].change_bitmap(:fainted)
    else
      @sprites[:hp_bar].change_bitmap(:able)
    end
  end

  def refresh_ball_graphic
    return if !@sprites[:ball] || @sprites[:ball].disposed?
    @sprites[:ball].visible = !@pokemon.nil?
    @sprites[:ball].change_bitmap((@selected) ? :sel : :desel)
  end

  def refresh_pokemon_icon
    return if !@sprites[:pokemon] || @sprites[:pokemon].disposed?
    @sprites[:pokemon].visible = !@pokemon.nil?
    @sprites[:pokemon].selected = @selected
  end

  def refresh_held_item_icon
    return if !@sprites[:held_item] || @sprites[:held_item].disposed?
    @sprites[:held_item].visible = !@pokemon.nil?
  end

  def refresh_overlay
    super
    return if @pokemon.nil?
    draw_name
    draw_level
    draw_gender
    draw_hp_bar
    draw_hp_numbers
    draw_status_icon
    draw_shiny_icon
    draw_annotation
  end

  #-----------------------------------------------------------------------------

  def draw_name
    pokemon_name = @pokemon.name
    pokemon_name = crop_text(pokemon_name, 144)
    name_width = @sprites[:overlay].bitmap.text_size(pokemon_name).width
    draw_text(pokemon_name, 94 - [name_width - 130, 0].max, 22, theme: :white)
  end

  def draw_level
    return if @pokemon.egg?
    draw_image(graphics_folder + _INTL("level"), 16, 70)
    draw_number_from_image(@bitmaps[:numbers], @pokemon.level, 38, 70)
  end

  def draw_gender
    return if @pokemon.egg?
    if @pokemon.male?
      draw_text(_INTL("♂"), 230, 22, theme: :male)
    elsif @pokemon.female?
      draw_text(_INTL("♀"), 230, 22, theme: :female)
    end
  end

  def draw_hp_bar
    return if @pokemon.egg? || @pokemon.fainted? || (@text && @text.length > 0)
    bar_x = 136
    bar_y = 52
    bar_total_width = 96
    bar_height = 8
    bar_width = [@pokemon.hp * bar_total_width / @pokemon.totalhp.to_f, 1.0].max
    bar_width = ((bar_width / 2).round) * 2   # Make the bar's length a multiple of 2 pixels
    bar_width -= 2 if bar_width == bar_total_width && @pokemon.hp < @pokemon.totalhp
    hp_zone = 0                                                  # Green
    hp_zone = 1 if @pokemon.hp <= (@pokemon.totalhp / 2).floor   # Yellow
    hp_zone = 2 if @pokemon.hp <= (@pokemon.totalhp / 4).floor   # Red
    draw_image(graphics_folder + "hp_bar_fill", bar_x, bar_y,
               0, hp_zone * bar_height, bar_width, bar_height)
  end

  def draw_hp_numbers
    return if @pokemon.egg? || (@text && @text.length > 0)
    draw_number_from_image(@bitmaps[:numbers], @pokemon.hp, 178, 70, align: :right)
    draw_number_from_image(@bitmaps[:numbers], "/" + @pokemon.totalhp.to_s, 178, 70, align: :left)
  end

  def draw_status_icon
    return if @pokemon.egg? || (@text && @text.length > 0)
    status = -1
    if @pokemon.fainted?
      status = GameData::Status.count - 1
    elsif @pokemon.status != :NONE
      status = GameData::Status.get(@pokemon.status).icon_position
    elsif @pokemon.pokerusStage == 1
      status = GameData::Status.count
    end
    if status >= 0
      draw_image(UI_FOLDER + _INTL("statuses"), 86, 68,
                0, status * GameData::Status::ICON_SIZE[1], *GameData::Status::ICON_SIZE)
    end
  end

  def draw_shiny_icon
    return if @pokemon.egg? || (@text && @text.length > 0)
    draw_image(UI_FOLDER + "shiny", 88, 48) if @pokemon.shiny?
  end

  def draw_annotation
    draw_text(@text, 94, 62, theme: :white) if @text && @text.length > 0
  end
end

#===============================================================================
#
#===============================================================================
class UI::PartyVisualsButton < UI::SpriteContainer
  GRAPHICS_FOLDER = "Party/"

  def initialize(text, x, y, narrow, viewport)
    @text = text
    @x = x
    @y = y
    @narrow = narrow
    @selected = false
    super(viewport)
    refresh
  end

  def initialize_sprites
    @sprites[:button] = ChangelingSprite.new(0, 0, @viewport)
    if @narrow
      @sprites[:button].add_bitmap(:desel, graphics_folder + "cancel_button_narrow")
      @sprites[:button].add_bitmap(:sel, graphics_folder + "cancel_button_narrow_sel")
    else
      @sprites[:button].add_bitmap(:desel, graphics_folder + "cancel_button")
      @sprites[:button].add_bitmap(:sel, graphics_folder + "cancel_button_sel")
    end
    @sprites[:button].change_bitmap(:desel)
    record_values(:button)
    initialize_overlay
  end

  def initialize_overlay
    add_overlay(:overlay, 112, 48)
    @sprites[:overlay].z = 1
    record_values(:overlay)
  end

  #-----------------------------------------------------------------------------

  def selected=(value)
    return if @selected == value
    @selected = value
    refresh
  end

  #-----------------------------------------------------------------------------

  def refresh
    super
    @sprites[:button].change_bitmap((@selected) ? :sel : :desel)
  end

  def refresh_overlay
    super
    draw_text(@text, @sprites[:overlay].width / 2, (@narrow) ? 8 : 14, align: :center, theme: :white)
  end
end

#===============================================================================
#
#===============================================================================
class UI::PartyVisuals < UI::BaseVisuals
  attr_reader   :index
  attr_accessor :cannot_cancel

  GRAPHICS_FOLDER = "Party/"   # Subfolder in Graphics/UI
  TEXT_COLOR_THEMES = {   # Themes not in DEFAULT_TEXT_COLOR_THEMES
    :input_helper => [Color.new(248, 248, 248), Color.black],
  }

  def initialize(party, mode = :normal)
    @party = party
    @mode  = mode
    @index = (@party.length == 0) ? Settings::MAX_PARTY_SIZE : 0
    @multi_select = (@mode == :choose_entry_order)
    @cannot_cancel = false   # Used in battle when forced to switch in a Pokémon
    super()
    set_index(@index)
  end

  def initialize_message_box
    super
    @sprites[:help_window] = Window_AdvancedTextPokemon.new("")
    @sprites[:help_window].viewport = @viewport
    @sprites[:help_window].z        = 1500
    @sprites[:help_window].setSkin(MessageConfig.pbGetSpeechFrame)
    pbBottomLeftLines(@sprites[:help_window], 1, 396)
  end

  def initialize_sprites
    initialize_panels
    initialize_cancel_button
  end

  def initialize_panels
    Settings::MAX_PARTY_SIZE.times do |i|
      @sprites["pokemon#{i}"] = UI::PartyVisualsPanel.new(@party[i], i, @viewport)
    end
  end

  def initialize_cancel_button
    party_max = Settings::MAX_PARTY_SIZE
    if @multi_select
      @sprites["pokemon#{party_max}"] = UI::PartyVisualsButton.new(_INTL("CONFIRM"), 396, 308, true, @viewport)
      @sprites["pokemon#{party_max + 1}"] = UI::PartyVisualsButton.new(_INTL("CANCEL"), 396, 346, true, @viewport)
    else
      @sprites["pokemon#{party_max}"] = UI::PartyVisualsButton.new(_INTL("CANCEL"), 396, 328, false, @viewport)
    end
  end

  #-----------------------------------------------------------------------------

  def can_access_screen_menu?
    return false if @mode != :normal
    return !switching? && (can_access_storage? || @party.length > 1)
  end

  def can_access_storage?
    return false if @mode != :normal
    return ($player.has_box_link || $bag.has?(:POKEMONBOXLINK)) &&
           !$game_switches[Settings::DISABLE_BOX_LINK_SWITCH] &&
           !$game_map.metadata&.has_flag?("DisableBoxLink")
  end

  def set_help_text(text)
    @sprites[:help_window].text = text
    pbBottomLeftLines(@sprites[:help_window], 1, 396)
    @sprites[:help_window].resizeHeightToFit(text, @sprites[:help_window].width)
    pbBottomLeft(@sprites[:help_window])
    @sprites[:help_window].visible = true
  end

  def panels_have_annotations?
    return !@sprites["pokemon0"].text.nil?
  end

  def set_annotations(annot)
    Settings::MAX_PARTY_SIZE.times do |i|
      @sprites["pokemon#{i}"].text = (annot) ? annot[i] : nil
    end
  end

  def set_able_annotation_proc(use_proc, valid_values, use_annotations)
    @use_proc = use_proc
    @valid_values = valid_values
    @use_annotations = use_annotations
    refresh_able_annotations
  end

  # Used for extra restrictions on Pokémon when choosing one to trade.
  def set_able_annotation_proc2(use_proc, valid_values, use_annotations)
    @use_proc2 = use_proc
    @valid_values2 = valid_values
    @use_annotations2 = use_annotations
    refresh_able_annotations
  end

  def set_index(new_index)
    @index = new_index
    num_sprites = Settings::MAX_PARTY_SIZE + ((@multi_select) ? 2 : 1)
    num_sprites.times do |i|
      @sprites["pokemon#{i}"].selected = (i == @index)
    end
  end

  #-----------------------------------------------------------------------------

  def switch_index
    return @sprites["pokemon0"].switch_index
  end

  def switching?
    return switch_index >= 0
  end

  def start_switching(index)
    Settings::MAX_PARTY_SIZE.times do |i|
      @sprites["pokemon#{i}"].set_switch_index(index)
    end
  end

  def end_switching
    Settings::MAX_PARTY_SIZE.times do |i|
      @sprites["pokemon#{i}"].set_switch_index(-1)
    end
  end

  def animate_switch_panels_out(index1, index2)
    pbSEPlay("GUI party switch")
    # Setup values
    sprite1 = @sprites["pokemon#{index1}"]
    sprite2 = @sprites["pokemon#{index2}"]
    sprite1_start_x = sprite1.x
    sprite2_start_x = sprite2.x
    sprite1_dir = (index1.even?) ? -1 : 1
    sprite2_dir = (index2.even?) ? -1 : 1
    # Animate the panels moving off-screen
    duration = 0.4
    timer_start = System.uptime
    loop do
      sprite1.x = sprite1_start_x + lerp(0, sprite1_dir * Graphics.width / 2, duration, timer_start, System.uptime)
      sprite2.x = sprite2_start_x + lerp(0, sprite2_dir * Graphics.width / 2, duration, timer_start, System.uptime)
      Graphics.update
      Input.update
      update_visuals
      break if sprite1.x == sprite1_start_x + (sprite1_dir * Graphics.width / 2)
    end
  end

  def animate_switch_panels_in(index1, index2)
    pbSEPlay("GUI party switch")
    # Setup values
    sprite1 = @sprites["pokemon#{index1}"]
    sprite2 = @sprites["pokemon#{index2}"]
    sprite1.pokemon = @party[index1]
    sprite2.pokemon = @party[index2]
    sprite1_start_x = sprite1.x
    sprite2_start_x = sprite2.x
    sprite1_dir = (index1.even?) ? 1 : -1
    sprite2_dir = (index2.even?) ? 1 : -1
    # Animate the panels moving back into position
    duration = 0.4
    timer_start = System.uptime
    loop do
      sprite1.x = sprite1_start_x + lerp(0, sprite1_dir * Graphics.width / 2, duration, timer_start, System.uptime)
      sprite2.x = sprite2_start_x + lerp(0, sprite2_dir * Graphics.width / 2, duration, timer_start, System.uptime)
      Graphics.update
      Input.update
      update_visuals
      break if sprite1.x == sprite1_start_x + (sprite1_dir * Graphics.width / 2)
    end
  end

  #-----------------------------------------------------------------------------

  def show_message(text)
    @sprites[:help_window].visible = false
    super
    @sprites[:help_window].visible = true
  end

  def show_confirm_message(text)
    @sprites[:help_window].visible = false
    ret = super
    @sprites[:help_window].visible = true
    return ret
  end

  def show_menu(text, options, index = 0, align: :horizontal, cmd_side: :right)
    @sprites[:help_window].visible = false
#    cmd_side = (@index.even?) ? :right : :left
    ret = super(text, options, index, align: align, cmd_side: cmd_side)
    @sprites[:help_window].visible = true
    return ret
  end

  def show_choice(options, index = 0)
    @sprites[:help_window].visible = false
    ret = super
    @sprites[:help_window].visible = true
    return ret
  end

  def choose_number(help_text, maximum, init_num = 1)
    @sprites[:help_window].visible = false
    ret = super
    @sprites[:help_window].visible = true
    return ret
  end

  #-----------------------------------------------------------------------------

  def refresh
    super
    ensure_valid_index
    draw_input_helpers
    refresh_panels
  end

  def ensure_valid_index
    old_index = @index
    @index = @party.length - 1 if @index < Settings::MAX_PARTY_SIZE && @index >= @party.length
    set_index(@index) if @index != old_index
  end

  def refresh_panels
    Settings::MAX_PARTY_SIZE.times { |i| refresh_panel(i) }
  end

  def refresh_panel(panel_index)
    sprite = @sprites["pokemon#{panel_index}"]
    return if !sprite
    if sprite.is_a?(UI::PartyVisualsPanel)
      sprite.pokemon = sprite.pokemon
    else
      sprite.refresh
    end
  end

  def refresh_party
    Settings::MAX_PARTY_SIZE.times do |i|
      @sprites["pokemon#{i}"].pokemon = @party[i]
    end
  end

  def refresh_able_annotations
    Settings::MAX_PARTY_SIZE.times do |i|
      next if @sprites["pokemon#{i}"].blank?
      if !@use_proc && !@use_proc2
        @sprites["pokemon#{i}"].text = nil
        next
      end
      usability = @use_proc&.call(@party[i])
      if @use_proc2
        usability2 = @use_proc2.call(@party[i])
        usability = usability2 if usability.nil? || !@valid_values2.include?(usability2)
      end
      annot = _INTL("Cannot Choose")
      annot = @use_annotations[usability] if @use_annotations && @use_annotations[usability]
      annot = @use_annotations2[usability] if @use_annotations2 && @use_annotations2[usability]
      @sprites["pokemon#{i}"].text = annot
    end
  end

  def draw_input_helpers
    return if !can_access_screen_menu?
    draw_input_icon(48, Graphics.height - 96, Input::ACTION, _INTL("Menu"), theme: :input_helper)
  end

  #-----------------------------------------------------------------------------

  def update_input
    # Check for movement to a new Pokémon/button
    old_index = @index
    update_cursor_movement
    if @index != old_index
      pbPlayCursorSE
      set_index(@index)
    end
    # Check for interaction
    if Input.trigger?(Input::USE)
      return update_interaction(Input::USE)
    elsif Input.trigger?(Input::BACK)
      return update_interaction(Input::BACK)
    elsif Input.trigger?(Input::ACTION)
      return update_interaction(Input::ACTION)
    end
    return nil
  end

  def update_cursor_movement
    num_sprites = Settings::MAX_PARTY_SIZE + ((@multi_select) ? 2 : 1)
    if Input.repeat?(Input::UP)
      if @index >= Settings::MAX_PARTY_SIZE
        @index -= 1
        @index = @party.length - 1 if @index < Settings::MAX_PARTY_SIZE && !@party[@index]
        @index = num_sprites - 1 if @index < Settings::MAX_PARTY_SIZE && !@party[@index]   # In case party is empty
      else
        loop do
          @index -= 2
          break if @index < 0 || @party[@index]
        end
        @index = num_sprites - 1 if @index < 0   # Wrap around to the cancel button
      end
    elsif Input.repeat?(Input::DOWN)
      if @index >= Settings::MAX_PARTY_SIZE - 1
        @index += 1
        @index = 0 if @index >= num_sprites   # Wrap around to the first Pokémon
      else
        @index += 2
      end
      @index = Settings::MAX_PARTY_SIZE if @index < Settings::MAX_PARTY_SIZE && !@party[@index]
    elsif Input.repeat?(Input::LEFT)
      loop do
        @index -= 1
        break if @index < 0 || @index >= Settings::MAX_PARTY_SIZE || @party[@index]
      end
      @index = num_sprites - 1 if @index < 0   # Wrap around to the cancel button
    elsif Input.repeat?(Input::RIGHT)
      loop do
        @index += 1
        break if @index >= Settings::MAX_PARTY_SIZE || @party[@index]
      end
      @index = 0 if @index >= num_sprites   # Wrap around to the first Pokémon
      @index = Settings::MAX_PARTY_SIZE if @index < Settings::MAX_PARTY_SIZE && !@party[@index]
    end
  end

  def update_interaction(input)
    case input
    when Input::USE
      return :switch_pokemon_end if switching?
      if @index == Settings::MAX_PARTY_SIZE
        pbPlayCloseMenuSE
        return :quit
      elsif @sub_mode == :switch_pokemon
        return :switch_pokemon_start
      elsif @sub_mode == :switch_items
        return :item_move if @party[@index].hasItem?
        return nil
      end
      pbPlayDecisionSE
      return :interact_menu
    when Input::ACTION
      if can_access_screen_menu?
        pbPlayDecisionSE
        return :screen_menu
      end
    when Input::BACK
      return :switch_pokemon_cancel if switching?
      return :clear_sub_mode if (@sub_mode || :none) != :none
      pbPlayCloseMenuSE
      return :quit
    end
    return nil
  end

  def navigate
    refresh
    super
  end

  #-----------------------------------------------------------------------------

  def update_input_choose_pokemon
    # Check for movement to a new Pokémon/button
    old_index = @index
    update_cursor_movement
    if @index != old_index
      pbPlayCursorSE
      set_index(@index)
    end
    # Check for interaction
    if Input.trigger?(Input::USE)
      return update_interaction_choose_pokemon(Input::USE)
    elsif Input.trigger?(Input::BACK)
      return update_interaction_choose_pokemon(Input::BACK)
    end
    return nil
  end

  def update_interaction_choose_pokemon(input)
    case input
    when Input::USE
      if @index == Settings::MAX_PARTY_SIZE
        return :confirm if @multi_select   # Confirm
        (switching? || @cannot_cancel) ? pbPlayCancelSE : pbPlayCloseMenuSE
        return :quit   # Cancel
      elsif @index == Settings::MAX_PARTY_SIZE + 1   # Cancel (if Confirm is also a button)
        (switching? || @cannot_cancel) ? pbPlayCancelSE : pbPlayCloseMenuSE
        return :quit
      else
        return :chosen   # A Pokémon
      end
    when Input::BACK
      (switching? || @cannot_cancel) ? pbPlayCancelSE : pbPlayCloseMenuSE
      return :quit
    end
    return nil
  end

  def navigate_choose_pokemon
    ret = nil
    loop do
      Graphics.update
      Input.update
      update_visuals
      ret = update_input_choose_pokemon
      break if ret
    end
    return ret
  end
end

#===============================================================================
#
#===============================================================================
class UI::Party < UI::BaseScreen
  attr_reader :party

  ACTIONS = HandlerHash.new

  # mode is one of:
  #   :normal                  Can choose Fly/Dig/Teleport to use.
  #   :choose_pokemon          Result is index of chosen Pokémon; def pbMoveTutorChoose
  #                            wants this to yield when chosen.
  #   :battle_choose_pokemon   For battle.
  #   :battle_choose_to_box    For battle. Like :choose_pokemon but with a different help text.
  #   :battle_choose_to_revive For battle (Revival Blessing). Like :choose_pokemon but with a different help text.
  #   :battle_use_item         For battle.
  #   :use_item                Like :choose_pokemon but with a different help text.
  #   :teach_pokemon           Like :choose_pokemon but with a different help text.
  #   :choose_entry_order      Battle Frontier thing.
  def initialize(party, mode: :normal)
    @party = (party.is_a?(Array)) ? party : [party]
    @mode  = mode
    super()
    reset_help_text
  end

  def initialize_visuals
    @visuals = UI::PartyVisuals.new(@party, @mode)
  end

  #-----------------------------------------------------------------------------

  def pokemon
    return (index < @party.length) ? @party[index] : nil
  end

  def cannot_cancel=(value)
    @visuals.cannot_cancel = value
  end

  def can_access_storage?
    return @visuals.can_access_storage?
  end

  def set_index(new_index)
    @visuals.set_index(new_index)
  end

  def set_help_text(text)
    @visuals.set_help_text(text)
  end

  def set_able_annotation_proc(use_proc, valid_values, use_annotations)
    @use_proc = use_proc
    @valid_values = valid_values
    @visuals.set_able_annotation_proc(use_proc, valid_values, use_annotations)
  end

  # Used for extra restrictions on Pokémon when choosing one to trade.
  def set_able_annotation_proc2(use_proc, valid_values, use_annotations)
    @use_proc2 = use_proc
    @valid_values2 = valid_values
    @visuals.set_able_annotation_proc2(use_proc, valid_values, use_annotations)
  end

  def set_annotations(annot)
    @visuals.set_annotations(annot)
  end

  def clear_annotations
    @visuals.set_annotations(nil)
  end

  #-----------------------------------------------------------------------------

  # Shows a choice menu using the MenuHandlers options below.
  ACTIONS.add(:screen_menu, {
    :menu         => :party_screen_menu,
    :menu_message => proc { |screen| _INTL("Choose an option.") }
  })
  # Shows a choice menu using the MenuHandlers options below.
  ACTIONS.add(:interact_menu, {
    :menu         => :party_screen_interact,
    :menu_message => proc { |screen| _INTL("Do what with {1}?", screen.pokemon.name) }
  })
  # Shows a choice menu using the MenuHandlers options below.
  ACTIONS.add(:item_menu, {
    :menu         => :party_screen_interact_item,
    :menu_message => proc { |screen| _INTL("Do what with an item?") }
  })

  alias pbShowCommands show_menu

  #-----------------------------------------------------------------------------

  ACTIONS.add(:summary, {
    :effect => proc { |screen|
      summary_mode = [
        :battle_choose_pokemon, :battle_choose_to_box,
        :battle_choose_to_revive, :battle_use_item
      ].include?(screen.mode) ? :in_battle : :normal
      pbFadeOutInWithUpdate(screen.sprites) do
        new_index = UI::PokemonSummary.new(screen.party, screen.index, mode: summary_mode).main
        screen.set_index(new_index)
        screen.refresh
      end
    }
  })
  ACTIONS.add(:debug, {
    :effect => proc { |screen|
      screen.pokemon_debug_menu(screen.pokemon, screen.index)
    }
  })
  ACTIONS.add(:open_storage, {
    :effect => proc { |screen|
      pbFadeOutInWithUpdate(screen.sprites) do
        UI::PokemonStorage.new($PokemonStorage, mode: :organize).main
        screen.refresh_party
        screen.refresh
      end
    }
  })

  #-----------------------------------------------------------------------------

  ACTIONS.add(:switch_pokemon_start, {
    :effect => proc { |screen|
      pbPlayDecisionSE
      screen.start_switching
    }
  })
  ACTIONS.add(:switch_pokemon_end, {
    :effect => proc { |screen|
      screen.switch_pokemon(screen.switch_index, screen.index)
    }
  })
  ACTIONS.add(:switch_pokemon_cancel, {
    :effect => proc { |screen|
      pbPlayCancelSE
      screen.end_switching
    }
  })
  ACTIONS.add(:switch_pokemon_mode, {
    :effect => proc { |screen|
      screen.set_sub_mode(:switch_pokemon)
    }
  })
  ACTIONS.add(:clear_sub_mode, {
    :effect => proc { |screen|
      pbPlayCancelSE
      screen.set_sub_mode
    }
  })

  def switch_index
    return @visuals.switch_index
  end

  def switching?
    return @visuals.switching?
  end

  def start_switching(index = nil)
    @visuals.start_switching(index || @visuals.index)
  end

  def end_switching
    @visuals.end_switching
  end

  def switch_pokemon(index1, index2)
    if index1 >= 0 && index1 < @party.length &&
       index2 >= 0 && index2 < @party.length &&
       index1 != index2
      @visuals.animate_switch_panels_out(index1, index2)
      @party[index1], @party[index2] = @party[index2], @party[index1]
      @visuals.animate_switch_panels_in(index1, index2)
    end
    end_switching
  end

  #-----------------------------------------------------------------------------

  ACTIONS.add(:item_use, {
    :effect => proc { |screen|
      pkmn = screen.pokemon
      used_item = nil
      used = false
      pbFadeOutInWithUpdate(screen.sprites) do
        old_last_pocket       = $bag.last_viewed_pocket
        old_pocket_selections = $bag.last_pocket_selections.clone
        $bag.reset_last_selections
        bag_screen = UI::Bag.new($bag, mode: :choose_item)
        bag_screen.set_filter_proc(proc { |itm|
          item_data = GameData::Item.get(itm)
          next false if !pbCanUseItemOnPokemon?(itm)
          next false if !pbItemHasEffectOnPokemon?(itm, pkmn)
          if item_data.is_machine?
            move = item_data.move
            next false if pkmn.hasMove?(move) || !pkmn.compatible_with_move?(move)
          end
          next true
        })
        used_item = bag_screen.choose_item
        if used_item && ItemHandlers.useOpensScreen?(used_item)
          pbUseItemOnPokemon(used_item, pkmn, bag_screen)
          screen.refresh
          used = true
        end
        $bag.last_viewed_pocket     = old_last_pocket
        $bag.last_pocket_selections = old_pocket_selections
      end
      if used_item && !used
        pbUseItemOnPokemon(used_item, pkmn, screen)
        screen.refresh
      end
    }
  })
  ACTIONS.add(:item_give, {
    :effect => proc { |screen|
      pkmn = screen.pokemon
      given_item = nil
      pbFadeOutInWithUpdate(screen.sprites) do
        old_last_pocket       = $bag.last_viewed_pocket
        old_pocket_selections = $bag.last_pocket_selections.clone
        bag_screen = UI::Bag.new($bag, mode: :choose_item)
        bag_screen.set_filter_proc(proc { |itm| GameData::Item.get(itm).can_hold? })
        given_item = bag_screen.choose_item
        $bag.last_viewed_pocket     = old_last_pocket
        $bag.last_pocket_selections = old_pocket_selections
      end
      if given_item
        pbGiveItemToPokemon(given_item, pkmn, screen, screen.index)
        screen.refresh
      end
    }
  })
  ACTIONS.add(:item_take, {
    :effect => proc { |screen|
      pkmn = screen.pokemon
      screen.refresh if pbTakeItemFromPokemon(pkmn, screen)
    }
  })
  ACTIONS.add(:item_move, {
    :effect => proc { |screen|
      pbPlayDecisionSE
      old_pkmn = screen.pokemon
      old_item = old_pkmn.item
      old_item_name = old_item.name
      old_item_portion_name = old_item.portion_name
      screen.set_help_text(_INTL("Move held item to where?"))
      old_party_idx = screen.index
      moved = false
      loop do
        screen.start_switching(old_party_idx)
        new_party_idx = screen.choose_pokemon_core
        if new_party_idx < 0 || new_party_idx == old_party_idx
          screen.end_switching
          break
        end
        new_pkmn = screen.party[new_party_idx]
        if new_pkmn.egg?
          screen.show_message(_INTL("Eggs can't hold items."))
          next
        elsif !new_pkmn.hasItem?
          new_pkmn.item = old_item
          old_pkmn.item = nil
          screen.end_switching
          screen.show_message(_INTL("{1} was given the {2} to hold.", new_pkmn.name, old_item_portion_name))
          moved = true
          break
        elsif new_pkmn.item.is_mail?
          screen.show_message(_INTL("{1}'s mail must be removed before giving it an item.", new_pkmn.name))
          next
        end
        # New Pokémon is also holding an item; ask what to do with it
        new_item = new_pkmn.item
        new_item_portion_name = new_item.portion_name
        if new_item_portion_name.starts_with_vowel?
          screen.show_message(_INTL("{1} is already holding an {2}.", new_pkmn.name, new_item_portion_name) + "\1")
        else
          screen.show_message(_INTL("{1} is already holding a {2}.", new_pkmn.name, new_item_portion_name) + "\1")
        end
        next if !screen.show_confirm_message(_INTL("Would you like to switch the two items?"))
        new_pkmn.item = old_item
        old_pkmn.item = new_item
        screen.end_switching
        screen.show_message(_INTL("{1} was given the {2} to hold.", new_pkmn.name, old_item_portion_name) + "\1")
        screen.show_message(_INTL("{1} was given the {2} to hold.", old_pkmn.name, new_item_portion_name))
        moved = true
        break
      end
      screen.set_index(old_party_idx) if !moved
    }
  })
  ACTIONS.add(:mail_menu, {
    :menu         => :party_screen_interact_mail,
    :menu_message => proc { |screen| _INTL("Do what with the Mail?") }
  })
  ACTIONS.add(:item_move_mode, {
    :effect => proc { |screen|
      screen.set_sub_mode(:switch_items)
    }
  })
  ACTIONS.add(:mail_read, {
    :effect => proc { |screen|
      pbFadeOutInWithUpdate(screen.sprites) do
        pbDisplayMail(screen.pokemon.mail, screen.pokemon)
      end
    }
  })
  ACTIONS.add(:mail_take, {
    :effect => proc { |screen|
      screen.refresh if pbTakeItemFromPokemon(screen.pokemon, screen)
    }
  })

  #-----------------------------------------------------------------------------

  # NOTE: This code adds a number of ACTIONS, one per move usable in the
  #       overworld.
  HiddenMoveHandlers.eachHandler do |move_id|
    eval <<-__END__
      ACTIONS.add(:use_#{move_id}, {
        :effect => proc { |screen|
          screen.use_field_move(:#{move_id})
        }
      })
    __END__
  end
  ACTIONS.add(:use_MILKDRINK, {
    :effect => proc { |screen|
      screen.use_field_move(:MILKDRINK)
    }
  })
  ACTIONS.add(:use_SOFTBOILED, {
    :effect => proc { |screen|
      screen.use_field_move(:SOFTBOILED)
    }
  })

  # For Soft-Boiled and Milk Drink.
  def use_field_move(move_id)
    pkmn = pokemon
    move = pkmn.moves.select { |mov| mov.id == move_id }.first
    move_name = move.name
    case move_id
    when :SOFTBOILED, :MILKDRINK
      heal_amt = [(pkmn.totalhp / 5).floor, 1].max
      if pkmn.hp <= heal_amt
        show_message(_INTL("Not enough HP..."))
        return
      end
      old_party_idx = index
      start_switching(old_party_idx)
      loop do
        set_help_text(_INTL("Use on which Pokémon?"))
        new_party_idx = choose_pokemon_core
        if new_party_idx < 0 || new_party_idx == old_party_idx
          end_switching
          break
        end
        new_pkmn = pokemon
        if new_party_idx == old_party_idx
          show_message(_INTL("{1} can't use {2} on itself!", pkmn.name, move_name))
        elsif new_pkmn.egg?
          show_message(_INTL("{1} can't be used on an Egg!", move_name))
        elsif new_pkmn.fainted? || new_pkmn.hp == new_pkmn.totalhp
          show_message(_INTL("{1} can't be used on that Pokémon.", move_name))
        else
          pkmn.hp -= heal_amt
          hp_gain = pbItemRestoreHP(new_pkmn, heal_amt)
          show_message(_INTL("{1}'s HP was restored by {2} points.", new_pkmn.name, hp_gain))
          refresh
        end
        break if pkmn.hp <= heal_amt
      end
      end_switching
      set_index(old_party_idx)
    else
      if pbCanUseHiddenMove?(pkmn, move_id) && pbConfirmUseHiddenMove(pkmn, move_id)
        if move_id == :FLY
          pbFadeOutInWithUpdate(sprites) do
            town_map_screen = UI::TownMap.new(mode: :fly)
            town_map_screen.main
            if town_map_screen.result
              $game_temp.field_move_to_use = move_id
              $game_temp.field_move_user = pkmn
              $game_temp.fly_destination = town_map_screen.result
              silent_end_screen
            end
          end
        else
          $game_temp.field_move_to_use = move_id
          $game_temp.field_move_user = pkmn
          end_screen
        end
      end
    end
  end

  #-----------------------------------------------------------------------------

  def refresh
    super
    reset_help_text
  end

  def reset_help_text
    case @mode
    when :normal
      if switching?
        set_help_text(_INTL("Move to where?"))
      else
        case @visuals.sub_mode
        when :switch_pokemon
          set_help_text(_INTL("Choose Pokémon to switch."))
        when :switch_items
          set_help_text(_INTL("Choose to switch items."))
        else
          set_help_text((@party.length > 1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
        end
      end
    when :choose_pokemon, :battle_choose_pokemon
      if switching?
        set_help_text(_INTL("Move to where?"))
      else
        set_help_text(_INTL("Choose a Pokémon."))
      end
    when :use_item, :battle_use_item
      set_help_text(_INTL("Use on which Pokémon?"))
    when :teach_pokemon
      set_help_text(_INTL("Teach which Pokémon?"))
    when :battle_choose_to_box
      set_help_text(_INTL("Send which Pokémon to Boxes?"))
    when :battle_choose_to_revive
      set_help_text(_INTL("Choose Pokémon to revive."))
    when :choose_entry_order
      set_help_text(_INTL("Choose Pokémon and confirm."))
    end
  end

  def refresh_party
    @visuals.refresh_party
  end

  #-----------------------------------------------------------------------------

  def on_start_main_loop
    reset_help_text
  end

  def choose_pokemon
    start_screen
    loop do
      on_start_main_loop
      chosen_index = choose_pokemon_core
      if block_given?
        next if !yield @party[chosen_index], chosen_index
      end
      @result = chosen_index
      break
    end
    end_screen
    return @result
  end

  def choose_pokemon_core
    ret = -1
    loop do
      command = @visuals.navigate_choose_pokemon
      if command != :chosen || index < 0 || index >= @party.length
        ret = -1
        break
      end
      if @use_proc2 || @use_proc22
        usability = @use_proc&.call(pokemon)
        if @use_proc2
          usability2 = @use_proc2.call(pokemon)
          usability = usability2 if usability.nil? || !@valid_values2.include?(usability2)
        end
        if !(@valid_values&.include?(usability) || @valid_values2&.include?(usability))
          if pokemon.egg?
            show_message(_INTL("This egg can't be chosen."))
          else
            show_message(_INTL("This Pokémon can't be chosen."))
          end
          next
        end
      end
      ret = index
      break
    end
    return ret
  end

  # Used by the Battle Frontier.
  def choose_pokemon_entry_order(ruleset)
    return nil if !ruleset.hasValidTeam?(@party)
    # Setup party panel annotations
    annot = []
    statuses = []
    ordinals = [_INTL("INELIGIBLE"), _INTL("Not Entered"), _INTL("BANNED")]
    positions = [_INTL("First"), _INTL("Second"), _INTL("Third"), _INTL("Fourth"),
                 _INTL("Fifth"), _INTL("Sixth"), _INTL("Seventh"), _INTL("Eighth"),
                 _INTL("Ninth"), _INTL("Tenth"), _INTL("Eleventh"), _INTL("Twelfth")]
    Settings::MAX_PARTY_SIZE.times do |i|
      ordinals.push(positions[i] || "#{i + 1}th")
    end
    @party.length.times do |i|
      statuses[i] = (ruleset.isPokemonValid?(@party[i])) ? 1 : 2
      annot[i] = ordinals[statuses[i]]
    end
    set_annotations(annot)
    # Main loop
    start_screen
    ret = nil
    added_entry = false   # Whether an entry was added in the previous loop
    loop do
      on_start_main_loop
      # Get an array of the chosen Pokémon in order
      real_order = []
      @party.length.times do |i|
        @party.length.times do |j|
          next if statuses[j] != i + 3
          real_order.push(j)
          break
        end
      end
      real_order.length.times { |i| statuses[real_order[i]] = i + 3 }
      # Refresh annotations
      @party.length.times { |i| annot[i] = ordinals[statuses[i]] }
      set_annotations(annot)
      # Move index to the "Confirm" button if the required number of Pokémon are
      # now chosen
      if real_order.length == ruleset.number && added_entry
        @visuals.set_index(Settings::MAX_PARTY_SIZE)
      end
      added_entry = false
      # Choose a Pokémon or button
      command = @visuals.navigate_choose_pokemon
      case command
      when :chosen
        commands = {}
        commands[:enter]     = _INTL("Entry") if (statuses[index] || 0) == 1   # Not entered yet
        commands[:not_enter] = _INTL("No Entry") if (statuses[index] || 0) > 2   # Already entered
        commands[:summary]   = _INTL("Summary")
        commands[:cancel]    = _INTL("Cancel")
        chosen_command = show_menu(_INTL("Do what with {1}?", pokemon.name), commands)
        case chosen_command
        when :enter
          if real_order.length >= ruleset.number && ruleset.number > 0
            show_message(_INTL("No more than {1} Pokémon may enter.", ruleset.number))
          else
            statuses[index] = real_order.length + 3
            added_entry = true
            refresh
          end
        when :not_enter
          statuses[index] = 1
          refresh
        when :summary
          perform_action(:summary)
        end
      when :confirm
        ret = []
        real_order.each { |i| ret.push(@party[i]) }
        error = []
        break if ruleset.isValid?(ret, error)
        show_message(error[0])
        ret = nil
      when :quit   # Cancelled
        break
      end
    end
    end_screen
    @result = ret
    return @result
  end

  def choose_move(pkmn, message)
    move_names = []
    pkmn.moves.each do |move|
      next if !move || !move.id
      if move.total_pp <= 0
        move_names.push(_INTL("{1} (PP: ---)", move.name))
      else
        move_names.push(_INTL("{1} (PP: {2}/{3})", move.name, move.pp, move.total_pp))
      end
    end
    return show_menu(message, move_names, align: :vertical)
  end

  alias pbChooseMove choose_move
end

#===============================================================================
# Menu options for choice menus that exist in the party screen.
#===============================================================================
MenuHandlers.add(:party_screen_menu, :open_storage, {
  "name"      => _INTL("Access Pokémon Boxes"),
  "order"     => 10,
  "condition" => proc { |screen| next screen.can_access_storage? }
})

MenuHandlers.add(:party_screen_menu, :switch_pokemon_mode, {
  "name"      => _INTL("Mode: Switch Pokémon"),
  "order"     => 20,
  "condition" => proc { |screen| next screen.party.length > 1 }
})

MenuHandlers.add(:party_screen_menu, :item_move_mode, {
  "name"      => _INTL("Mode: Switch items"),
  "order"     => 30,
  "condition" => proc { |screen| next screen.party.length > 1 }
})

MenuHandlers.add(:party_screen_menu, :cancel, {
  "name"      => _INTL("Cancel"),
  "order"     => 9999
})

#-------------------------------------------------------------------------------

MenuHandlers.add(:party_screen_interact, :summary, {
  "name"      => _INTL("Summary"),
  "order"     => 10
})

MenuHandlers.add(:party_screen_interact, :debug, {
  "name"      => _INTL("Debug"),
  "order"     => 20,
  "condition" => proc { |screen| next $DEBUG }
})

MenuHandlers.add(:party_screen_interact, :field_moves, {
  "order"         => 30,
  "multi_options" => proc { |screen|
    ret = []
    next ret if screen.pokemon.egg?
    screen.pokemon.moves.each do |move|
      next if !HiddenMoveHandlers.hasHandler(move.id) &&
              ![:MILKDRINK, :SOFTBOILED].include?(move.id)
      ret.push(["use_#{move.id}".to_sym, "<c3=0050A0,80C0F0>" + move.name + "</c3>"])
    end
    next ret
  }
})

MenuHandlers.add(:party_screen_interact, :switch_pokemon_start, {
  "name"      => _INTL("Switch"),
  "order"     => 40,
  "condition" => proc { |screen| next screen.party.length > 1 }
})

MenuHandlers.add(:party_screen_interact, :item_menu, {
  "name"      => _INTL("Item"),
  "order"     => 50,
  "condition" => proc { |screen| next !screen.pokemon.egg? && !screen.pokemon.mail }
})

MenuHandlers.add(:party_screen_interact_item, :item_use, {
  "name"      => _INTL("Use"),
  "order"     => 10
})

MenuHandlers.add(:party_screen_interact_item, :item_give, {
  "name"      => _INTL("Give"),
  "order"     => 20
})

MenuHandlers.add(:party_screen_interact_item, :item_take, {
  "name"      => _INTL("Take"),
  "order"     => 30,
  "condition" => proc { |screen| next screen.pokemon.hasItem? }
})

MenuHandlers.add(:party_screen_interact_item, :item_move, {
  "name"      => _INTL("Move"),
  "order"     => 40,
  "condition" => proc { |screen| next screen.pokemon.hasItem? && !screen.pokemon.item.is_mail? }
})

MenuHandlers.add(:party_screen_interact_item, :item_cancel, {
  "name"      => _INTL("Cancel"),
  "order"     => 9999
})

MenuHandlers.add(:party_screen_interact, :mail_menu, {
  "name"      => _INTL("Mail"),
  "order"     => 50,
  "condition" => proc { |screen| next !screen.pokemon.egg? && screen.pokemon.mail }
})

MenuHandlers.add(:party_screen_interact_mail, :mail_read, {
  "name"      => _INTL("Read"),
  "order"     => 10
})

MenuHandlers.add(:party_screen_interact_mail, :mail_take, {
  "name"      => _INTL("Take"),
  "order"     => 20
})

MenuHandlers.add(:party_screen_interact_mail, :mail_cancel, {
  "name"      => _INTL("Cancel"),
  "order"     => 30
})

MenuHandlers.add(:party_screen_interact, :cancel, {
  "name"      => _INTL("Cancel"),
  "order"     => 9999
})

#===============================================================================
# Open the party screen.
#===============================================================================
def pbPokemonScreen
  pbFadeOutIn do
    UI::Party.new($player.party).main
  end
end

#===============================================================================
# Choose a Pokémon in the party.
#===============================================================================
# Choose a Pokémon/egg from the party.
# Stores result in variable _index_game_var_ and the chosen Pokémon's name in
# variable _name_game_var_; result is -1 if no Pokémon was chosen
# _allowIneligible is unused.
def pbChoosePokemon(index_game_var, name_game_var, able_proc = nil, _allow_ineligible = false)
  chosen = -1
  pbFadeOutIn do
    screen = UI::Party.new($player.party, mode: :choose_pokemon)
    if able_proc
      valid_values = [true]
      use_annotations = {
        true  => _INTL("Can Choose"),
        false => _INTL("Cannot Choose")
      }
      screen.set_able_annotation_proc(able_proc, valid_values, use_annotations)
    end
    chosen = screen.choose_pokemon
  end
  pbSet(index_game_var, chosen)
  pbSet(name_game_var, (chosen >= 0) ? $player.party[chosen].name : "")
end

def pbChooseNonEggPokemon(index_game_var, name_game_var)
  pbChoosePokemon(index_game_var, name_game_var, proc { |pkmn| !pkmn.egg? })
end

def pbChooseAblePokemon(index_game_var, name_game_var)
  pbChoosePokemon(index_game_var, name_game_var, proc { |pkmn| !pkmn.egg? && pkmn.hp > 0 })
end

# Same as pbChoosePokemon, but prevents choosing an egg or a Shadow Pokémon or a
# Pokémon that is marked and untradable.
def pbChooseTradablePokemon(index_game_var, name_game_var, able_proc = nil, _allow_ineligible = false)
  chosen = 0
  pbFadeOutIn do
    screen = UI::Party.new($player.party, mode: :choose_pokemon)
    valid_values = [true]
    use_annotations = {
      true  => _INTL("Can Choose"),
      false => _INTL("Cannot Choose")
    }
    screen.set_able_annotation_proc(able_proc, valid_values, use_annotations) if able_proc
    able_proc2 = proc { |pkmn| next !pkmn.egg? && !pkmn.shadowPokemon? && !pkmn.cannot_trade }
    screen.set_able_annotation_proc2(able_proc2, valid_values, use_annotations)
    chosen = screen.choose_pokemon
  end
  pbSet(index_game_var, chosen)
  pbSet(name_game_var, (chosen >= 0) ? $player.party[chosen].name : "")
end

def pbChoosePokemonForTrade(index_game_var, name_game_var, wanted)
  wanted = GameData::Species.get(wanted).species
  pbChooseTradablePokemon(index_game_var, name_game_var, proc { |pkmn|
    next pkmn.isSpecies?(wanted)
  })
end
