#===============================================================================
#
#===============================================================================
class UI::MoveReminderCursor < IconSprite
  attr_accessor :top_index

  CURSOR_WIDTH     = 258
  CURSOR_HEIGHT    = 72
  CURSOR_THICKNESS = 6

  def initialize(viewport = nil)
    super(0, 0, viewport)
    setBitmap("Graphics/UI/Move Reminder/cursor")
    self.src_rect = Rect.new(0, 0, CURSOR_WIDTH, CURSOR_HEIGHT)
    self.z = 1600
    @bg_sprite = IconSprite.new(x, y, viewport)
    @bg_sprite.setBitmap("Graphics/UI/Move Reminder/cursor")
    @bg_sprite.src_rect = Rect.new(0, CURSOR_HEIGHT, CURSOR_WIDTH, CURSOR_HEIGHT)
    @top_index = 0
    self.index = 0
  end

  def dispose
    @bg_sprite.dispose
    @bg_sprite = nil
    super
  end

  def index=(value)
    @index = value
    refresh_position
  end

  def visible=(value)
    super
    @bg_sprite.visible = value
  end

  def refresh_position
    return if @index < 0
    self.x = UI::MoveReminderVisuals::MOVE_LIST_X
    self.y = UI::MoveReminderVisuals::MOVE_LIST_Y - CURSOR_THICKNESS
    self.y += (@index - @top_index) * UI::MoveReminderVisuals::MOVE_LIST_SPACING
    @bg_sprite.x = self.x
    @bg_sprite.y = self.y
  end
end

#===============================================================================
#
#===============================================================================
class UI::MoveReminderVisuals < UI::BaseVisuals
  attr_reader :index

  GRAPHICS_FOLDER   = "Move Reminder/"   # Subfolder in Graphics/UI
  MOVE_LIST_X       = 0
  MOVE_LIST_Y       = 84
  MOVE_LIST_SPACING = 64    # Y distance between top of two adjacent move areas
  VISIBLE_MOVES     = 4

  def initialize(pokemon, moves)
    @pokemon   = pokemon
    @moves     = moves
    @top_index = 0
    @index     = 0
    super()
    refresh_cursor
  end

  def initialize_bitmaps
    @bitmaps[:types]   = AnimatedBitmap.new(UI_FOLDER + _INTL("types"))
    @bitmaps[:buttons] = AnimatedBitmap.new(graphics_folder + "buttons")
  end

  def initialize_sprites
    # Pokémon icon
    @sprites[:pokemon_icon] = PokemonIconSprite.new(@pokemon, @viewport)
    @sprites[:pokemon_icon].setOffset(PictureOrigin::CENTER)
    @sprites[:pokemon_icon].x = 314
    @sprites[:pokemon_icon].y = 84
    @sprites[:pokemon_icon].z = 200
    # Cursor
    @sprites[:cursor] = UI::MoveReminderCursor.new(@viewport)
  end

  #-----------------------------------------------------------------------------

  def moves=(move_list)
    @moves = move_list
    @index = @moves.length - 1 if @index >= @moves.length
    refresh_on_index_changed(@index)
    @sprites[:cursor] = false if @moves.empty?
    refresh
  end

  #-----------------------------------------------------------------------------

  def refresh_overlay
    super
    draw_header
    draw_pokemon_type_icons(396, 70, 6)
    draw_moves_list
    draw_move_properties
    draw_buttons
  end

  def draw_header
    draw_text(_INTL("Teach which move?"), 16, 14, theme: :gray)
  end

  # x and y are the top left corner of the type icon if there is only one type.
  def draw_pokemon_type_icons(x, y, spacing)
    @pokemon.types.each_with_index do |type, i|
      type_number = GameData::Type.get(type).icon_position
      offset = ((@pokemon.types.length - 1) * (GameData::Type::ICON_SIZE[0] + spacing) / 2)
      offset = (offset / 2) * 2
      type_x = x - offset + ((GameData::Type::ICON_SIZE[0] + spacing) * i)
      draw_image(@bitmaps[:types], type_x, y,
                 0, type_number * GameData::Type::ICON_SIZE[1], *GameData::Type::ICON_SIZE)
    end
  end

  def draw_moves_list
    VISIBLE_MOVES.times do |i|
      move = @moves[@top_index + i]
      next if move.nil?
      move_data = GameData::Move.get(move)
      draw_move_in_list(move_data, MOVE_LIST_X, MOVE_LIST_Y + (i * MOVE_LIST_SPACING))
    end
  end

  def draw_move_in_list(move_data, x, y)
    # Draw move name
    move_name = move_data.name
    move_name = crop_text(move_name, 230)
    draw_text(move_name, x + 10, y + 6, theme: :white)
    # Draw move type icon
    type_number = GameData::Type.get(move_data.display_type(@pokemon)).icon_position
    draw_image(@bitmaps[:types], x + 10, y + 32,
               0, type_number * GameData::Type::ICON_SIZE[1], *GameData::Type::ICON_SIZE)
    # Draw move category
    draw_image(UI_FOLDER + "category", x + 76, y + 32,
               0, move_data.display_category(@pokemon) * GameData::Move::CATEGORY_ICON_SIZE[1], *GameData::Move::CATEGORY_ICON_SIZE)
    # Draw PP text
    if move_data.total_pp > 0
      draw_text(_INTL("PP"), x + 150, y + 38, theme: :black)
      draw_text(sprintf("%d/%d", move_data.total_pp, move_data.total_pp), x + 240, y + 38, align: :right, theme: :black)
    end
  end

  def draw_move_properties
    move = @moves[@index]
    return if move.nil?
    move_data = GameData::Move.get(move)
    # Power
    draw_text(_INTL("POWER"), 278, 120, theme: :white)
    power_text = move_data.display_power(@pokemon)
    power_text = "---" if power_text == 0   # Status move
    power_text = "???" if power_text == 1   # Variable power move
    draw_text(power_text, 480, 120, align: :right, theme: :black)
    # Accuracy
    draw_text(_INTL("ACCURACY"), 278, 152, theme: :white)
    accuracy = move_data.display_accuracy(@pokemon)
    if accuracy == 0
      draw_text("---", 480, 152, align: :right, theme: :black)
    else
      draw_text(accuracy, 480, 152, align: :right, theme: :black)
      draw_text("%", 480, 152, theme: :black)
    end
    # Description
    draw_paragraph_text(move_data.description, 262, 184, 246, 6, theme: :black)
  end

  def draw_buttons
    draw_image(@bitmaps[:buttons], 44, 350, 0, 0, 76, 32) if @top_index < @moves.length - VISIBLE_MOVES
    draw_image(@bitmaps[:buttons], 132, 350, 76, 0, 76, 32) if @top_index > 0
  end

  #-----------------------------------------------------------------------------

  def refresh_cursor
    @sprites[:cursor].top_index = @top_index
    @sprites[:cursor].index = @index
  end

  def refresh_on_index_changed(old_index)
    pbPlayCursorSE
    # Change @top_index to keep @index in the middle of the visible list (or as
    # close to it as possible)
    middle_range_top = (VISIBLE_MOVES / 2) - ((VISIBLE_MOVES + 1) % 2)
    middle_range_bottom = VISIBLE_MOVES / 2
    if @index < @top_index + middle_range_top
      @top_index = @index - middle_range_top
    elsif @index > @top_index + middle_range_bottom
      @top_index = @index - middle_range_bottom
    end
    @top_index = @top_index.clamp(0, [@moves.length - VISIBLE_MOVES, 0].max)
    refresh_cursor
    refresh
  end

  #-----------------------------------------------------------------------------

  def update_input
    # Check for movement to a new move
    update_cursor_movement
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
    # Check for movement to a new move
    if Input.repeat?(Input::UP)
      @index -= 1
      if Input.trigger?(Input::UP)
        @index = @moves.length - 1 if @index < 0   # Wrap around
      else
        @index = 0 if @index < 0
      end
    elsif Input.repeat?(Input::DOWN)
      @index += 1
      if Input.trigger?(Input::DOWN)
        @index = 0 if @index >= @moves.length   # Wrap around
      else
        @index = @moves.length - 1 if @index >= @moves.length
      end
    elsif Input.repeat?(Input::QUICK_UP)
      @index -= VISIBLE_MOVES
      @index = 0 if @index < 0
    elsif Input.repeat?(Input::QUICK_DOWN)
      @index += VISIBLE_MOVES
      @index = @moves.length - 1 if @index >= @moves.length
    end
    return false
  end

  def update_interaction(input)
    case input
    when Input::USE
      pbPlayDecisionSE
      return :learn
    when Input::BACK
      pbPlayCloseMenuSE
      return :quit
    end
    return nil
  end
end

#===============================================================================
#
#===============================================================================
class UI::MoveReminder < UI::BaseScreen
  attr_reader :pokemon

  ACTIONS = HandlerHash.new

  # mode is either :normal or :single.
  def initialize(pokemon, mode: :normal)
    @pokemon = pokemon
    @mode = mode
    generate_move_list
    super()
  end

  def initialize_visuals
    @visuals = UI::MoveReminderVisuals.new(@pokemon, @moves)
  end

  #-----------------------------------------------------------------------------

  def generate_move_list
    @moves = []
    return if !@pokemon || @pokemon.egg? || @pokemon.shadowPokemon?
    @pokemon.getMoveList.each do |move|
      next if @pokemon.hasMove?(move[1])
      next if !Settings::MOVE_RELEARNER_CAN_TEACH_ANY_LEVEL_MOVES && move[0] > @pokemon.level
      @moves.push(move[1]) if !@moves.include?(move[1])
    end
    if Settings::MOVE_RELEARNER_CAN_TEACH_MORE_MOVES && @pokemon.first_moves
      first_moves = []
      @pokemon.first_moves.each do |move|
        first_moves.push(move) if !@moves.include?(move) && !@pokemon.hasMove?(move)
      end
      @moves = first_moves + @moves   # List first moves before level-up moves
    end
    @moves = @moves | []   # remove duplicates
  end

  def refresh_move_list
    generate_move_list
    @visuals.moves = @moves
  end

  #-----------------------------------------------------------------------------

  def move
    return @moves[self.index]
  end

  #-----------------------------------------------------------------------------

  ACTIONS.add(:learn, {
    :effect => proc { |screen|
      next if !screen.show_confirm_message(_INTL("Teach {1}?", GameData::Move.get(screen.move).name))
      next if !pbLearnMove(screen.pokemon, screen.move, false, false, screen)
      $stats.moves_taught_by_reminder += 1
      if screen.mode == :normal
        screen.refresh_move_list
      else
        screen.end_screen
      end
    }
  })

  #-----------------------------------------------------------------------------

  def main
    return if @disposed
    start_screen
    loop do
      on_start_main_loop
      command = @visuals.navigate
      break if command == :quit && (@mode == :normal ||
               show_confirm_message(_INTL("Give up trying to teach a new move to {1}?", @pokemon.name)))
      perform_action(command)
      if @moves.empty?
        show_message(_INTL("There are no more moves for {1} to learn.", @pokemon.name))
        break
      end
      if @disposed
        @result = true
        break
      end
    end
    end_screen
    return @result
  end
end

#===============================================================================
#
#===============================================================================
def pbRelearnMoveScreen(pkmn)
  ret = true
  pbFadeOutIn do
    ret = UI::MoveReminder.new(pkmn, mode: :single).main
  end
  return ret
end
