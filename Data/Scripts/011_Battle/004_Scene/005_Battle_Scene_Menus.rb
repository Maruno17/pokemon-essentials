#===============================================================================
# Base class for all three menu classes below.
#===============================================================================
class Battle::Scene::MenuBase < UI::SpriteContainer
  attr_reader   :index
  attr_accessor :active

  TEXT_COLOR_THEMES = {   # These color themes are added to @sprites[:overlay]
    :default => [Battle::Scene::MESSAGE_BASE_COLOR, Battle::Scene::MESSAGE_SHADOW_COLOR]   # Base and shadow colour
  }
  BUTTON_HEIGHT = 46

  def initialize(viewport = nil)
    @index   = 0
    @visible = false
    @active  = false
    super
  end

  #-----------------------------------------------------------------------------

  def index=(value)
    old_value = @index
    @index = value
    refresh if @index != old_value
  end
end

#===============================================================================
# Command menu (Fight/Pokémon/Bag/Run).
#===============================================================================
class Battle::Scene::CommandMenu < Battle::Scene::MenuBase
  attr_accessor :commands

  GRAPHICS_FOLDER = "Battle/"
  # The order of command buttons as drawn in cursor_command.png. If one is in an
  # array with "true", it is a wide button (typically for the button in the top
  # row).
  BUTTON_CONTENTS = [
    [:fight, true],
    :fight2,
    :shift,
    :pokemon,
    :bag,
    :run,
    :call,
    [:throw_ball, true],
    :throw_rock,
    :throw_bait,
    :throw_ball_contest,
    :cancel
  ]
  # The two widths of buttons depicted in cursor_command.png.
  BUTTON_WIDTHS = [128, 256]   # Regular size, wide size
  # Number of pixels that adjacent buttons overlap each other.
  BUTTON_OVERLAP = [4, 4]

  def initialize(viewport, z, battle)
    @battle = battle
    @commands = []
    super(viewport)
    self.x = 0
    self.y = Graphics.height - @sprites[:overlay].height
    self.z = z
  end

  def initialize_bitmaps
    @bitmaps[:buttons]     = AnimatedBitmap.new(graphics_folder + _INTL("cursor_command"))
    @bitmaps[:party_balls] = AnimatedBitmap.new(graphics_folder + "icon_command_party")
  end

  def initialize_sprites
    initialize_overlay
  end

  def initialize_overlay
    add_overlay(:party_overlay, Graphics.width, 96)
    @sprites[:party_overlay].z = 1
    record_values(:party_overlay)
    add_overlay(:overlay, Graphics.width, 96)
    @sprites[:overlay].z = 2
    record_values(:overlay)
  end

  #-----------------------------------------------------------------------------

  def index=(new_index)
    old_value = @index
    @index = (new_index.is_a?(Symbol)) ? @commands.index { |command| command[0] == new_index } : new_index
    refresh if @index != old_value
  end

  def set_index_and_commands(new_index, new_commands)
    self.commands = new_commands
    @index = (new_index.is_a?(Symbol)) ? @commands.index { |command| command[0] == new_index } : new_index
    full_refresh
  end

  def command
    return @commands[@index][0]
  end

  # cmds = [:fight, nil, :bag, :run, :pokemon], where nil means new row.
  def commands=(cmds)
    @commands = []
    row = 0
    row_widths = [0]
    cmds.each do |cmd|
      if cmd.nil?
        row += 1
        row_widths[row] = 0
        next
      end
      src_index = BUTTON_CONTENTS.index { |btn| (!btn.is_a?(Array) && btn == cmd) || (btn.is_a?(Array) && btn[0] == cmd) }
      content = BUTTON_CONTENTS[src_index]
      src_width = (content.is_a?(Array) && content[1]) ? BUTTON_WIDTHS[1] : BUTTON_WIDTHS[0]
      button_x = (@sprites[:overlay].width / 2) + row_widths[row]
      button_y = 6 + (row * (BUTTON_HEIGHT - BUTTON_OVERLAP[1]))
      @commands.push([cmd, row, src_index, button_x, button_y, src_width])
      row_widths[row] += src_width - BUTTON_OVERLAP[0]
    end
    # Adjust the button_x for each command based on the total width of its row
    @commands.each do |command|
      command[3] -= (row_widths[command[1]] + BUTTON_OVERLAP[0]) / 2
    end
  end

  #-----------------------------------------------------------------------------

  def refresh_overlay
    super
    draw_command_buttons
  end

  def full_refresh
    super
    @sprites[:party_overlay].bitmap.clear if @sprites[:party_overlay]
    draw_player_party_icons
    draw_opponent_party_icons
  end

  def draw_player_party_icons
    return if @battle.is_a?(SafariBattle)
    party = @battle.pbParty(0)
    Battle::Scene::NUM_BALLS.times do |i|
      pkmn = party[i]
      status = 0
      if pkmn.nil?
        status = 3
      elsif !pkmn.able?
        status = 2
      elsif pkmn.status != :NONE
        status = 1
      end
      draw_image(@bitmaps[:party_balls], 2 + (i * (@bitmaps[:party_balls].height - 2)), 6,
                 status * @bitmaps[:party_balls].height, 0,
                 @bitmaps[:party_balls].height, @bitmaps[:party_balls].height,
                 overlay: :party_overlay)
    end
  end

  def draw_opponent_party_icons
    return if @battle.wildBattle? || @battle.is_a?(SafariBattle)
    party = @battle.pbParty(1)
    Battle::Scene::NUM_BALLS.times do |i|
      pkmn = party[i]
      status = 0
      if pkmn.nil?
        status = 3
      elsif !pkmn.able?
        status = 2
      elsif pkmn.status != :NONE
        status = 1
      end
      draw_image(@bitmaps[:party_balls],
                 Graphics.width - @bitmaps[:party_balls].height - 2 - (i * (@bitmaps[:party_balls].height - 2)), 6,
                 status * @bitmaps[:party_balls].height, 0,
                 @bitmaps[:party_balls].height, @bitmaps[:party_balls].height,
                 overlay: :party_overlay)
    end
  end

  def draw_command_buttons
    sel_command = @commands[@index]
    # Draw all unselected command buttons
    @commands.each do |command|
      next if command[0] == sel_command[0]
      draw_image(@bitmaps[:buttons], command[3], command[4],
                 0, command[2] * BUTTON_HEIGHT, command[5], BUTTON_HEIGHT)
    end
    # Draw selected command button
    draw_image(@bitmaps[:buttons], sel_command[3], sel_command[4],
               @bitmaps[:buttons].width / 2, sel_command[2] * BUTTON_HEIGHT, sel_command[5], BUTTON_HEIGHT)
  end

  #-----------------------------------------------------------------------------

  def update_input
    return if !active
    old_index = @index
    old_row = @commands[@index][1]
    if Input.repeat?(Input::LEFT)
      if @index > 0 && @commands[@index - 1][1] == old_row   # In same row
        @index -= 1
      elsif @index == 0
        @index = @commands.index { |command| command[1] == old_row + 1 }   # First button in next row
      end
    elsif Input.repeat?(Input::RIGHT)
      if @commands[@index + 1] && @commands[@index + 1][1] == old_row   # In same row
        @index += 1
      elsif old_row == 0 && @commands[@index + 1][1] != old_row
        new_index = @index
        @commands.each_with_index { |command, i| new_index = i if command[1] == old_row + 1 }
        @index = new_index   # Last button in next row
      end
    elsif Input.repeat?(Input::UP)
      old_x = @commands[@index][3] + (@commands[@index][5] / 2)   # Middle of button
      difference = 999   # Very high to begin with
      @commands.each_with_index do |command, i|
        next if command[1] != old_row - 1
        this_x = command[3] + (command[5] / 2)   # Middle of button
        if (this_x - old_x).abs < difference
          difference = (this_x - old_x).abs
          @index = i
        end
      end
    elsif Input.repeat?(Input::DOWN)
      old_x = @commands[@index][3] + (@commands[@index][5] / 2)   # Middle of button
      difference = 999   # Very high to begin with
      @commands.each_with_index do |command, i|
        next if command[1] != old_row + 1
        this_x = command[3] + (command[5] / 2)   # Middle of button
        if (this_x - old_x).abs <= difference
          difference = (this_x - old_x).abs
          @index = i
        end
      end
    end
    @index ||= old_index
    if @index != old_index
      pbPlayCursorSE
      refresh
    end
  end

  def update
    super
    update_input
  end
end

#===============================================================================
# Fight menu (choose a move).
#===============================================================================
class Battle::Scene::FightMenu < Battle::Scene::MenuBase
  attr_reader :battler
  attr_reader :mega_evolution_state

  GRAPHICS_FOLDER = "Battle/"
  TEXT_COLOR_THEMES = {   # These color themes are added to @sprites[:overlay]
    :default   => [Battle::Scene::MESSAGE_BASE_COLOR, Battle::Scene::MESSAGE_SHADOW_COLOR],   # Base and shadow colour
    :pp_yellow => [Color.new(248, 192, 0), Color.new(144, 104, 0)],   # Base and shadow colour
    :pp_orange => [Color.new(248, 136, 32), Color.new(144, 72, 24)],   # Base and shadow colour
    :pp_red    => [Color.new(248, 72, 72), Color.new(136, 48, 48)]   # Base and shadow colour
  }
  BUTTON_WIDTH = 200
  # Number of pixels that adjacent buttons overlap each other.
  BUTTON_OVERLAP = [4, 4]
  TYPE_ICON_HEIGHT = GameData::Type::ICON_SIZE[1]

  def initialize(viewport, z)
    @battler              = nil
    @mega_evolution_state = 0   # 0=don't show, 1=show unpressed, 2=show pressed
    super(viewport)
    self.x = 0
    self.y = Graphics.height - 96
    self.z = z
  end

  def initialize_bitmaps
    @bitmaps[:types] = AnimatedBitmap.new(UI_FOLDER + _INTL("types"))
  end

  def initialize_sprites
    initialize_background
    initialize_overlay
    initialize_move_buttons
    initialize_mega_evolution_button
  end

  def initialize_background
    add_icon_sprite(:bg, 0, 0, graphics_folder + "overlay_fight")
    record_values(:bg)
  end

  def initialize_overlay
    # Bitmap in which the selected move's type and PP are drawn
    add_overlay(:overlay, Graphics.width, 96)
    @sprites[:overlay].z = 6
    pbSetNarrowFont(@sprites[:overlay].bitmap)
    record_values(:overlay)
    # Bitmap in which the move names are written
    add_overlay(:move_name_overlay, Graphics.width, 96)
    @sprites[:move_name_overlay].z = 5
    pbSetNarrowFont(@sprites[:move_name_overlay].bitmap)
    record_values(:move_name_overlay)
  end

  def initialize_move_buttons
    Pokemon::MAX_MOVES.times do |i|
      button_x = 4 + ((i % 2) * (BUTTON_WIDTH - BUTTON_OVERLAP[0]))
      button_y = 6 + ((i / 2) * (BUTTON_HEIGHT - BUTTON_OVERLAP[1]))
      add_icon_sprite("move_#{i}".to_sym, button_x, button_y, graphics_folder + _INTL("cursor_fight"))
      @sprites["move_#{i}".to_sym].src_rect.width = BUTTON_WIDTH
      @sprites["move_#{i}".to_sym].src_rect.height = BUTTON_HEIGHT
      record_values("move_#{i}".to_sym)
    end
  end

  def initialize_mega_evolution_button
    add_icon_sprite(:mega_evolution, 2, -46, graphics_folder + "cursor_mega")
    @sprites[:mega_evolution].z = -1
    @sprites[:mega_evolution].src_rect.height = 46
    @sprites[:mega_evolution].visible = false
    record_values(:mega_evolution)
  end

  #-----------------------------------------------------------------------------

  def battler=(value)
    @battler = value
    full_refresh
  end

  def mega_evolution_state=(value)
    old_value = @mega_evolution_state
    @mega_evolution_state = value
    refresh_mega_evolution_button
  end

  def set_battler_and_index(new_battler, new_index)
    @battler = new_battler
    @index = new_index
    full_refresh
  end

  #-----------------------------------------------------------------------------

  def refresh
    super
    return if !@battler
    refresh_selected_button
    refresh_mega_evolution_button
  end

  def full_refresh
    refresh
    draw_move_names_on_buttons
  end

  def refresh_selected_button
    moves = (@battler) ? @battler.moves : []
    # Choose appropriate button graphics and z positions
    Pokemon::MAX_MOVES.times do |i|
      button = @sprites["move_#{i}".to_sym]
      button.visible = !!moves[i]
      next if !moves[i]
      button.src_rect.x = (i == @index) ? BUTTON_WIDTH : 0
      button.src_rect.y = GameData::Type.get(moves[i].display_type(@battler)).icon_position * BUTTON_HEIGHT
      button.z          = self.z + ((i == @index) ? 4 : 3)
    end
    draw_move_info(moves[@index])
  end

  def refresh_mega_evolution_button
    @sprites[:mega_evolution].visible    = (@mega_evolution_state > 0)
    @sprites[:mega_evolution].src_rect.y = (@mega_evolution_state - 1) * 46
  end

  def draw_move_names_on_buttons
    @sprites[:move_name_overlay].bitmap.clear
    moves = (@battler) ? @battler.moves : []
    Pokemon::MAX_MOVES.times do |i|
      next if !moves[i]
      button = @sprites["move_#{i}".to_sym]
      text_x = button.x - self.x + (button.src_rect.width / 2)
      text_y = button.y - self.y + 14
      name_theme = :default
      move_type = moves[i].display_type(@battler)
      if Settings::BATTLE_MOVE_NAME_COLOR_FROM_GRAPHIC && move_type
        # NOTE: This takes a color from a particular pixel in the button
        #       graphic and makes the move name's base color that same color.
        #       The pixel is at coordinates 10,34 in the button box. If you
        #       change the graphic, you may want to change the below line of
        #       code to ensure the font is an appropriate color.
        sampled_color = button.bitmap.get_pixel(10, button.src_rect.y + 34)
        @sprites[:move_name_overlay].add_text_theme(move_type, sampled_color, TEXT_COLOR_THEMES[:default][1])
        name_theme = move_type
      end
      draw_text(moves[i].name, text_x, text_y, align: :center, theme: name_theme, overlay: :move_name_overlay)
    end
  end

  def draw_move_info(move)
    return if !move
    area_middle = @sprites[:overlay].width - 56
    # Draw type icon
    type_number = GameData::Type.get(move.display_type(@battler)).icon_position
    draw_image(@bitmaps[:types], area_middle - (GameData::Type::ICON_SIZE[0] / 2), 22,
               0, type_number * GameData::Type::ICON_SIZE[1], *GameData::Type::ICON_SIZE)
    # Draw PP text
    if move.total_pp > 0
      pp_fraction = [(4.0 * move.pp / move.total_pp).ceil, 3].min
      pp_theme = [:pp_red, :pp_orange, :pp_yellow, :default][pp_fraction]
      draw_text(_INTL("PP: {1}/{2}", move.pp, move.total_pp), area_middle, 58,
                align: :center, theme: pp_theme)
    end
  end

  #-----------------------------------------------------------------------------

  def update_input
    return if !active
    old_index = @index
    if Input.repeat?(Input::LEFT)
      @index -= 1 if (@index % 2) == 1
    elsif Input.repeat?(Input::RIGHT)
      @index += 1 if (@index % 2) == 0 && @battler.moves[@index + 1]&.id
    elsif Input.repeat?(Input::UP)
      @index -= 2 if @index >= 2
    elsif Input.repeat?(Input::DOWN)
      @index += 2 if @battler.moves[@index + 2]&.id && @index < 2
    end
    if @index != old_index
      pbPlayCursorSE
      refresh
    end
  end

  def update
    super
    update_input
  end
end

#===============================================================================
# Target menu (choose a move's target).
#===============================================================================
class Battle::Scene::TargetMenu < Battle::Scene::MenuBase
  attr_reader :mode

  GRAPHICS_FOLDER = "Battle/"
  TEXT_COLOR_THEMES = {   # These color themes are added to @sprites[:overlay]
    :default   => [Color.new(240, 248, 224), Color.new(64, 64, 64)]   # Base and shadow colour
  }
  BUTTON_WIDTHS = [236, 170]   # 1-2 buttons in row, 3+ buttons in row
  # Number of pixels that adjacent buttons overlap each other.
  BUTTON_OVERLAP = [4, 4]

  # NOTE: @mode is for which buttons are shown as selected.
  #       0=select 1 button (@index), 1=select all buttons with text
  def initialize(viewport, z, side_sizes)
    @mode = 0
    @side_sizes = side_sizes
    @max_index = (@side_sizes[0] > @side_sizes[1]) ? (@side_sizes[0] - 1) * 2 : (@side_sizes[1] * 2) - 1
    @use_small_buttons = (@side_sizes.max > 2)
    @texts = []
    super(viewport)
    self.x = 0
    self.y = Graphics.height - 96
    self.z = z
  end

  def initialize_sprites
    initialize_overlay
    initialize_target_buttons
  end

  def initialize_overlay
    add_overlay(:overlay, Graphics.width, 96)
    @sprites[:overlay].z = 5
    pbSetNarrowFont(@sprites[:overlay].bitmap)
    record_values(:overlay)
  end

  def initialize_target_buttons
    (@max_index + 1).times do |i|
      num_buttons = @side_sizes[i % 2]
      next if num_buttons <= i / 2
      # NOTE: Battler indices go from left to right from the perspective of
      #       that side's trainer, so index is different for each side for the
      #       same value of i/2.
      index = (i.even?) ? i / 2 : num_buttons - 1 - (i / 2)
      add_icon_sprite("button_#{i}".to_sym, 0, 0, graphics_folder + _INTL("cursor_target"))
      button = @sprites["button_#{i}".to_sym]
      button.src_rect.width = (@use_small_buttons) ? BUTTON_WIDTHS[1] : BUTTON_WIDTHS[0]
      button.src_rect.height = BUTTON_HEIGHT
      total_width = (num_buttons * button.src_rect.width) - ((num_buttons - 1) * BUTTON_OVERLAP[0])
      button.x = (@sprites[:overlay].width - total_width) / 2
      button.x += index * (button.src_rect.width - BUTTON_OVERLAP[0])
      button.y = 6 + (((i + 1) % 2) * (BUTTON_HEIGHT - BUTTON_OVERLAP[1]))
      record_values("button_#{i}".to_sym)
    end
  end

  #-----------------------------------------------------------------------------

  def set_texts_and_mode(texts, mode)
    @texts = texts
    @mode  = mode
    refresh
  end

  #-----------------------------------------------------------------------------

  def refresh
    super
    refresh_selected_button
    draw_target_names_on_buttons
  end

  def refresh_selected_button
    # Choose appropriate button graphics and z positions
    (@max_index + 1).times do |i|
      button = @sprites["button_#{i}".to_sym]
      next if !button
      selected = false
      button_type = 0
      if @texts[i]
        selected ||= (@mode == 0 && i == @index)
        selected ||= (@mode == 1)
        button_type = (i.even?) ? 1 : 2
      end
      src_button_type = (2 * button_type) + ((@use_small_buttons) ? 1 : 0)
      button.src_rect.x = (selected) ? BUTTON_WIDTHS[0] : 0
      button.src_rect.y = src_button_type * BUTTON_HEIGHT
      button.z          = self.z + ((selected) ? 3 : 2)
    end
  end

  def draw_target_names_on_buttons
    (@max_index + 1).times do |i|
      next if nil_or_empty?(@texts[i])
      button = @sprites["button_#{i}".to_sym]
      next if !button
      text_x = button.x - self.x + (button.src_rect.width / 2)
      text_y = button.y - self.y + 14
      draw_text(@texts[i], text_x, text_y, align: :center)
    end
  end

  #-----------------------------------------------------------------------------

  def update_input
    return if !active
    return if @mode != 0
    old_index = @index
    if Input.repeat?(Input::LEFT) || Input.repeat?(Input::RIGHT)
      inc = (@index.even?) ? -2 : 2
      inc *= -1 if Input.press?(Input::RIGHT)
      index_length = @side_sizes[@index % 2] * 2
      new_index = @index
      loop do
        new_index += inc
        break if new_index < 0 || new_index >= index_length
        next if @texts[new_index].nil?
        @index = new_index
        break
      end
    elsif (Input.repeat?(Input::UP) && @index.even?) ||
          (Input.repeat?(Input::DOWN) && @index.odd?)
      sel_sprite = @sprites["button_#{@index}".to_sym]
      old_x = sel_sprite.x + (sel_sprite.src_rect.width / 2)   # Middle of button
      difference = 999   # Very high to begin with
      new_index = @index
      (@max_index + 1).times do |i|
        next if (i % 2) == (@index % 2) || @texts[i].nil?
        this_sprite = @sprites["button_#{i}".to_sym]
        next if !this_sprite
        this_x = this_sprite.x + (this_sprite.src_rect.width / 2)   # Middle of button
        if (this_x - old_x).abs < difference
          difference = (this_x - old_x).abs
          new_index = i
        end
      end
      @index = new_index
    end
    if @index != old_index
      pbPlayCursorSE
      refresh
    end
  end

  def update
    super
    update_input
  end
end
