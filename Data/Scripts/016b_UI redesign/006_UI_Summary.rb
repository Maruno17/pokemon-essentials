#===============================================================================
#
#===============================================================================
class MoveSelectionSprite < Sprite
  attr_reader :index

  def initialize(viewport = nil, preselected = false, fifthmove = false)
    super(viewport)
    @movesel = AnimatedBitmap.new("Graphics/UI/Summary/cursor_move")
    @frame = 0
    @index = 0
    @fifthmove = fifthmove
    @preselected = preselected
    @updating = false
    refresh
  end

  def dispose
    @movesel.dispose
    super
  end

  def index=(value)
    @index = value
    refresh
  end

  def refresh
    w = @movesel.width
    h = @movesel.height / 2
    self.x = 240
    self.y = 92 + (self.index * 64)
    self.y -= 76 if @fifthmove
    self.y += 20 if @fifthmove && self.index == Pokemon::MAX_MOVES   # Add a gap
    self.bitmap = @movesel.bitmap
    if @preselected
      self.src_rect.set(0, h, w, h)
    else
      self.src_rect.set(0, 0, w, h)
    end
  end

  def update
    @updating = true
    super
    @movesel.update
    @updating = false
    refresh
  end
end

#===============================================================================
#
#===============================================================================
class RibbonSelectionSprite < MoveSelectionSprite
  def initialize(viewport = nil, preselected = false)
    super(viewport)
    @movesel = AnimatedBitmap.new("Graphics/UI/Summary/cursor_ribbon")
    @frame = 0
    @index = 0
    @preselected = preselected
    @updating = false
    @spriteVisible = true
    refresh
  end

  def visible=(value)
    super
    @spriteVisible = value if !@updating
  end

  def recheck_visibility
    @updating = true
    self.visible = @spriteVisible && @index >= 0 &&
                   @index < UI::PokemonSummaryVisuals::RIBBON_COLUMNS * UI::PokemonSummaryVisuals::RIBBON_ROWS
    @updating = false
  end

  def refresh
    recheck_visibility
    cols = UI::PokemonSummaryVisuals::RIBBON_COLUMNS
    offset_x = UI::PokemonSummaryVisuals::RIBBON_SIZE[0] + UI::PokemonSummaryVisuals::RIBBON_SPACING_X
    offset_y = UI::PokemonSummaryVisuals::RIBBON_SIZE[1] + UI::PokemonSummaryVisuals::RIBBON_SPACING_Y
    self.x = UI::PokemonSummaryVisuals::RIBBON_X - 2 + ((self.index % cols) * offset_x)
    self.y = UI::PokemonSummaryVisuals::RIBBON_Y - 2 + ((self.index / cols) * offset_y)
    self.bitmap = @movesel.bitmap
    w = @movesel.width
    h = @movesel.height / 2
    if @preselected
      self.src_rect.set(0, h, w, h)
    else
      self.src_rect.set(0, 0, w, h)
    end
  end

  def update
    super
    recheck_visibility
    @movesel.update
    refresh
  end
end

#===============================================================================
#
#===============================================================================
class UI::PokemonSummaryVisuals < UI::BaseVisuals
  GRAPHICS_FOLDER   = "Summary/"   # Subfolder in Graphics/UI
  TEXT_COLOR_THEMES = {   # These color themes are added to @sprites[:overlay]
    :default      => [Color.new(248, 248, 248), Color.new(104, 104, 104)],   # Base and shadow colour
    :white        => [Color.new(248, 248, 248), Color.new(104, 104, 104)],
    :raised_stat  => [Color.new(248, 248, 248), Color.new(136, 96, 72)],
    :lowered_stat => [Color.new(248, 248, 248), Color.new(64, 120, 152)],
    :black        => [Color.new(64, 64, 64), Color.new(176, 176, 176)],
    :faded        => [Color.new(192, 200, 208), Color.new(208, 216, 224)],
    :male         => [Color.new(24, 112, 216), Color.new(136, 168, 208)],
    :female       => [Color.new(248, 56, 32), Color.new(224, 152, 144)],
    :shiny        => [Color.new(248, 56, 32), Color.new(224, 152, 144)],
    :pp_half      => [Color.new(248, 192, 0), Color.new(144, 104, 0)],
    :pp_quarter   => [Color.new(248, 136, 32), Color.new(144, 72, 24)],
    :pp_zero      => [Color.new(248, 72, 72), Color.new(136, 48, 48)]
  }
  MARKING_WIDTH          = 16
  MARKING_HEIGHT         = 16
  RIBBON_SIZE            = [64, 64]   # [width, height]
  RIBBON_SPACING_X       = 4
  RIBBON_SPACING_Y       = 4
  RIBBON_COLUMNS         = 4
  RIBBON_ROWS            = 3
  RIBBON_X               = 230   # Left edge of top left ribbon
  RIBBON_Y               = 78    # Top edge of top left ribbon
  RIBBON_COLUMNS_GRAPHIC = 8     # In the ribbons.png graphic

  def initialize(party, party_index = 0, mode = :normal, new_move = nil)
    @party       = party
    @party_index = party_index
    @pokemon     = @party[@party_index]
    @mode        = mode
    @new_move    = new_move   # Only used if @mode is :choose_move
    @page        = (@mode == :choose_move) ? 4 : 1
    @move_index  = (@mode == :choose_move) ? 0 : nil
    super()
  end

  def initialize_bitmaps
    @bitmaps[:types]    = AnimatedBitmap.new(UI_FOLDER + _INTL("types"))
    @bitmaps[:markings] = AnimatedBitmap.new(graphics_folder + "markings")
  end

  def initialize_sprites
    # Pokémon sprite
    @sprites[:pokemon] = PokemonSprite.new(@viewport)
    @sprites[:pokemon].setOffset(PictureOrigin::CENTER)
    @sprites[:pokemon].x       = 104
    @sprites[:pokemon].y       = 206
    @sprites[:pokemon].visible = (@mode != :choose_move)
    @sprites[:pokemon].setPokemonBitmap(@pokemon)
    # Held item icon
    @sprites[:held_item_icon] = ItemIconSprite.new(30, 320, @pokemon.item_id, @viewport)
    @sprites[:held_item_icon].blankzero = true
    # Page-specific sprites
    initialize_move_page_sprites
    initialize_ribbon_page_sprites
    initialize_marking_sprites
  end

  def initialize_move_page_sprites
    # Pokémon icon
    @sprites[:pokemon_icon] = PokemonIconSprite.new(@pokemon, @viewport)
    @sprites[:pokemon_icon].setOffset(PictureOrigin::CENTER)
    @sprites[:pokemon_icon].x       = 46
    @sprites[:pokemon_icon].y       = 92
    @sprites[:pokemon_icon].visible = (@mode == :choose_move)
    # Cursor to highlight a move selected to be swapped
    @sprites[:selected_move_cursor] = MoveSelectionSprite.new(@viewport, true)
    @sprites[:selected_move_cursor].z       = 1600
    @sprites[:selected_move_cursor].visible = false
    # Cursor to highlight the currently selected move
    @sprites[:move_cursor] = MoveSelectionSprite.new(@viewport, false, !@new_move.nil?)
    @sprites[:move_cursor].z       = 1600
    @sprites[:move_cursor].visible = (@mode == :choose_move)
  end

  def initialize_ribbon_page_sprites
    # Cursor to highlight a ribbon selected to be swapped
    @sprites[:selected_ribbon_cursor] = RibbonSelectionSprite.new(@viewport, true)
    @sprites[:selected_ribbon_cursor].z       = 1600
    @sprites[:selected_ribbon_cursor].visible = false
    # Cursor to highlight the currently selected ribbon
    @sprites[:ribbon_cursor] = RibbonSelectionSprite.new(@viewport)
    @sprites[:ribbon_cursor].z       = 1600
    @sprites[:ribbon_cursor].visible = false
    # Arrow to indicate more ribbons are above the ones visible when navigating ribbons
    @sprites[:up_arrow] = AnimatedSprite.new(UI_FOLDER + "up_arrow", 8, 28, 40, 2, @viewport)
    @sprites[:up_arrow].x = 350
    @sprites[:up_arrow].y = 56
    @sprites[:up_arrow].z = 1700
    @sprites[:up_arrow].play
    @sprites[:up_arrow].visible = false
    # Arrow to indicate more ribbons are below the ones visible when navigating ribbons
    @sprites[:down_arrow] = AnimatedSprite.new(UI_FOLDER + "down_arrow", 8, 28, 40, 2, @viewport)
    @sprites[:down_arrow].x = 350
    @sprites[:down_arrow].y = 260
    @sprites[:down_arrow].z = 1700
    @sprites[:down_arrow].play
    @sprites[:down_arrow].visible = false
  end

  def initialize_marking_sprites
    # Background image of marking panel
    add_icon_sprite(:marking_bg, 260, 88, graphics_folder + "overlay_marking")
    @sprites[:marking_bg].z = 1400
    @sprites[:marking_bg].visible = false
    # Overlay for marking panel
    add_overlay(:marking_overlay)
    @sprites[:marking_overlay].z = 1500
    @sprites[:marking_overlay].visible = false
    # Cursor to highlight the currently selected marking option
    add_icon_sprite(:marking_cursor, 0, 0, graphics_folder + "cursor_marking")
    @sprites[:marking_cursor].z = 1600
    @sprites[:marking_cursor].src_rect.height = @sprites[:marking_cursor].bitmap.height / 2
    @sprites[:marking_cursor].visible = false
  end

  #-----------------------------------------------------------------------------

  def background_filename
    return "bg_learnmove" if @new_move
    return "bg_movedetail" if @move_index
    return "bg_egg" if @pokemon.egg?
    return BACKGROUND_FILENAME + "_" + @page.to_s
  end

  #-----------------------------------------------------------------------------

  def go_to_next_page
    return if @pokemon.egg?
    return if @page == 5
    @page += 1
    pbSEPlay("GUI summary change page")
    @ribbon_offset = 0
    refresh
  end

  def go_to_previous_page
    return if @pokemon.egg?
    return if @page == 1
    @page -= 1
    @ribbon_offset = 0
    pbSEPlay("GUI summary change page")
    refresh
  end

  def set_party_index(new_index)
    return if @party_index == new_index
    @party_index = new_index
    @pokemon = @party[@party_index]
    @page = 1 if @pokemon.egg?
    @sprites[:pokemon].setPokemonBitmap(@pokemon)
    @sprites[:held_item_icon].item = @pokemon.item_id
    @ribbon_offset = 0
    pbSEStop
    @pokemon.play_cry
    refresh
  end

  #-----------------------------------------------------------------------------

  def refresh
    super
    refresh_background
    draw_page_contents
  end

  def refresh_background
    @sprites[:background].setBitmap(graphics_folder + background_filename)
  end

  def draw_markings(x, y)
    mark_variants = @bitmaps[:markings].bitmap.height / MARKING_HEIGHT
    markings = @pokemon.markings
    mark_rect = Rect.new(0, 0, MARKING_WIDTH, MARKING_HEIGHT)
    (@bitmaps[:markings].bitmap.width / MARKING_WIDTH).times do |i|
      mark_rect.x = i * MARKING_WIDTH
      mark_rect.y = [(markings[i] || 0), mark_variants - 1].min * MARKING_HEIGHT
      @sprites[:overlay].bitmap.blt(x + (i * MARKING_WIDTH), y, @bitmaps[:markings].bitmap, mark_rect)
    end
  end

  def draw_page_contents
    if @new_move || @move_index
      selected_move = ((@move_index || 0) == Pokemon::MAX_MOVES) ? @new_move : @pokemon.moves[@move_index || 0]
      draw_page_four(selected_move)
      return
    end
    @sprites[:held_item_icon].item = @pokemon.item_id
    @sprites[:pokemon].setPokemonBitmap(@pokemon)
    @sprites[:pokemon_icon].pokemon = @pokemon
    # Show the Poké Ball containing the Pokémon
    ball_filename = graphics_folder + sprintf("icon_ball_%s", @pokemon.poke_ball)
    draw_image(ball_filename, 14, 60)
    # Draw Pokémon egg page
    if @pokemon.egg?
      draw_page_one_egg
      return
    end
    # Show status/fainted/Pokérus infected icon
    status = -1
    if @pokemon.fainted?
      status = GameData::Status.count - 1
    elsif @pokemon.status != :NONE
      status = GameData::Status.get(@pokemon.status).icon_position
    elsif @pokemon.pokerusStage == 1
      status = GameData::Status.count
    end
    if status >= 0
      draw_image(UI_FOLDER + _INTL("statuses"), 124, 100,
                 0, status * GameData::Status::ICON_SIZE[1], *GameData::Status::ICON_SIZE)
    end
    # Show Pokérus cured icon
    draw_image(graphics_folder + "icon_pokerus", 176, 100) if @pokemon.pokerusStage == 2
    # Show shininess star
    draw_image(UI_FOLDER + "shiny", 2, 134) if @pokemon.shiny?
    # Write various bits of text
    page_name = [_INTL("INFO"),
                 _INTL("TRAINER MEMO"),
                 _INTL("SKILLS"),
                 _INTL("MOVES"),
                 _INTL("RIBBONS")][@page - 1]
    draw_text(page_name, 26, 22)
    draw_text(@pokemon.name, 46, 68)
    draw_text(@pokemon.level, 46, 98, theme: :black)
    draw_text(_INTL("Item"), 66, 324)
    # Write the held item's name
    if @pokemon.hasItem?
      draw_text(@pokemon.item.name, 16, 358, theme: :black)
    else
      draw_text(_INTL("None"), 16, 358, theme: :faded)
    end
    # Write the gender symbol
    if @pokemon.male?
      draw_text(_INTL("♂"), 178, 68, theme: :male)
    elsif @pokemon.female?
      draw_text(_INTL("♀"), 178, 68, theme: :female)
    end
    # Draw the Pokémon's markings
    draw_markings(84, 292)
    # Draw page-specific information
    case @page
    when 1 then draw_page_one
    when 2 then draw_page_two
    when 3 then draw_page_three
    when 4 then draw_page_four
    when 5 then draw_page_five
    end
  end

  def draw_page_one
    # If a Shadow Pokémon, draw the heart gauge area and bar
    if @pokemon.shadowPokemon?
      shadow_fract = @pokemon.heart_gauge.to_f / @pokemon.max_gauge_size
      draw_image(graphics_folder + "overlay_shadow", 224, 240)
      draw_image(graphics_folder + "overlay_shadowbar", 242, 280,
                 0, 0, (shadow_fract * 248).floor, -1)
    end
    # Write various bits of text
    draw_text(_INTL("Dex No."), 238, 86)
    draw_text(_INTL("Species"), 238, 118)
    draw_text(@pokemon.speciesName, 435, 118, align: :center, theme: :black)
    draw_text(_INTL("Type"), 238, 150)
    draw_text(_INTL("OT"), 238, 182)
    draw_text(_INTL("ID No."), 238, 214)
    # Write the Regional/National Dex number
    dex_num = 0
    dex_num_shift = false
    if $player.pokedex.unlocked?(-1)   # National Dex is unlocked
      dex_num = (GameData::Species.keys.index(@pokemon.species_data.species) || 0) + 1
      dex_num_shift = true if Settings::DEXES_WITH_OFFSETS.include?(-1)
    else
      ($player.pokedex.dexes_count - 1).times do |i|
        next if !$player.pokedex.unlocked?(i)
        num = pbGetRegionalNumber(i, @pokemon.species)
        break if num <= 0
        dex_num = num
        dex_num_shift = true if Settings::DEXES_WITH_OFFSETS.include?(i)
        break
      end
    end
    dex_num_theme = (@pokemon.shiny?) ? :shiny : :black
    if dex_num <= 0
      draw_text("???", 435, 86, align: :center, theme: dex_num_theme)
    else
      dex_num -= 1 if dex_num_shift
      draw_text(sprintf("%03d", dex_num), 435, 86, align: :center, theme: dex_num_theme)
    end
    # Write Original Trainer's name and ID number
    if @pokemon.owner.name.empty?
      draw_text(_INTL("RENTAL"), 435, 182, align: :center, theme: :black)
      draw_text("?????", 435, 214, align: :center, theme: :black)
    else
      owner_theme = :black
      case @pokemon.owner.gender
      when 0 then owner_theme = :male
      when 1 then owner_theme = :female
      end
      draw_text(@pokemon.owner.name, 435, 182, align: :center, theme: owner_theme)
      draw_text(sprintf("%05d", @pokemon.owner.public_id), 435, 214, align: :center, theme: :black)
    end
    # Write Exp text OR heart gauge message (if a Shadow Pokémon)
    if @pokemon.shadowPokemon?
      draw_text(_INTL("Heart Gauge"), 238, 246)
      black_text_tag = shadowc3tag(*TEXT_COLOR_THEMES[:black])
      heart_message = [_INTL("The door to its heart is open! Undo the final lock!"),
                       _INTL("The door to its heart is almost fully open."),
                       _INTL("The door to its heart is nearly open."),
                       _INTL("The door to its heart is opening wider."),
                       _INTL("The door to its heart is opening up."),
                       _INTL("The door to its heart is tightly shut.")][@pokemon.heartStage]
      memo = black_text_tag + heart_message
      drawFormattedTextEx(@sprites[:overlay].bitmap, 234, 310, 264, memo)
    else
      end_exp = @pokemon.growth_rate.minimum_exp_for_level(@pokemon.level + 1)
      draw_text(_INTL("Exp. Points"), 238, 246)
      draw_text(@pokemon.exp.to_s_formatted, 488, 278, align: :right, theme: :black)
      draw_text(_INTL("To Next Lv."), 238, 310)
      draw_text((end_exp - @pokemon.exp).to_s_formatted, 488, 342, align: :right, theme: :black)
    end
    # Draw Pokémon type(s)
    @pokemon.types.each_with_index do |type, i|
      type_number = GameData::Type.get(type).icon_position
      type_rect = Rect.new(0, type_number * GameData::Type::ICON_SIZE[1], *GameData::Type::ICON_SIZE)
      type_x = (@pokemon.types.length == 1) ? 402 : 370 + ((GameData::Type::ICON_SIZE[0] + 2) * i)
      @sprites[:overlay].bitmap.blt(type_x, 146, @bitmaps[:types].bitmap, type_rect)
    end
    # Draw Exp bar
    if @pokemon.level < GameData::GrowthRate.max_level
      exp_width = @pokemon.exp_fraction * 128
      exp_width = ((exp_width / 2).round) * 2
      draw_image(graphics_folder + "overlay_exp", 362, 372,
                 0, 0, exp_width, -1)
    end
  end

  def draw_page_one_egg
    # Write various bits of text
    draw_text(_INTL("TRAINER MEMO"), 26, 22)
    draw_text(@pokemon.name, 46, 68)
    draw_text(_INTL("Item"), 66, 324)
    # Write the held item's name
    if @pokemon.hasItem?
      draw_text(@pokemon.item.name, 16, 358, theme: :black)
    else
      draw_text(_INTL("None"), 16, 358, theme: :faded)
    end
    # Set up memo
    red_text_tag = shadowc3tag(*TEXT_COLOR_THEMES[:shiny])
    black_text_tag = shadowc3tag(*TEXT_COLOR_THEMES[:black])
    memo = ""
    # Add date received to memo
    if @pokemon.timeReceived
      date  = @pokemon.timeReceived.day
      month = pbGetMonthName(@pokemon.timeReceived.mon)
      year  = @pokemon.timeReceived.year
      # TODO: Write this date the wrong way round for United States of Americans.
      memo += black_text_tag + _INTL("{1} {2}, {3}", date, month, year) + "\n"
    end
    # Add map name egg was received on to memo
    map_name = pbGetMapNameFromId(@pokemon.obtain_map)
    map_name = @pokemon.obtain_text if @pokemon.obtain_text && !@pokemon.obtain_text.empty?
    if map_name && map_name != ""
      map_name = red_text_tag + map_name + black_text_tag
      memo += black_text_tag + _INTL("A mysterious Pokémon Egg received from {1}.", map_name) + "\n"
    else
      memo += black_text_tag + _INTL("A mysterious Pokémon Egg.") + "\n"
    end
    memo += "\n"   # Empty line
    # Add Egg Watch blurb to memo
    memo += black_text_tag + _INTL("\"The Egg Watch\"") + "\n"
    egg_state = _INTL("It looks like this Egg will take a long time to hatch.")
    egg_state = _INTL("What will hatch from this? It doesn't seem close to hatching.") if @pokemon.steps_to_hatch < 10_200
    egg_state = _INTL("It appears to move occasionally. It may be close to hatching.") if @pokemon.steps_to_hatch < 2550
    egg_state = _INTL("Sounds can be heard coming from inside! It will hatch soon!") if @pokemon.steps_to_hatch < 1275
    memo += black_text_tag + egg_state
    # Draw all text
    drawFormattedTextEx(@sprites[:overlay].bitmap, 232, 86, 268, memo)
    # Draw the Pokémon's markings
    draw_markings(84, 292)
  end

  def draw_page_two
    # Set up memo
    red_text_tag = shadowc3tag(*TEXT_COLOR_THEMES[:shiny])
    black_text_tag = shadowc3tag(*TEXT_COLOR_THEMES[:black])
    memo = ""
    # Add nature to memo
    show_nature = (!@pokemon.shadowPokemon? || @pokemon.heartStage <= 3)
    if show_nature
      nature_name = red_text_tag + @pokemon.nature.name + black_text_tag
      memo += _INTL("{1} nature.", nature_name) + "\n"
    end
    # Add date received to memo
    if @pokemon.timeReceived
      date  = @pokemon.timeReceived.day
      month = pbGetMonthName(@pokemon.timeReceived.mon)
      year  = @pokemon.timeReceived.year
      # TODO: Write this date the wrong way round for United States of Americans.
      memo += black_text_tag + _INTL("{1} {2}, {3}", date, month, year) + "\n"
    end
    # Add map name Pokémon was received on to memo
    map_name = pbGetMapNameFromId(@pokemon.obtain_map)
    map_name = @pokemon.obtain_text if @pokemon.obtain_text && !@pokemon.obtain_text.empty?
    map_name = _INTL("Faraway place") if nil_or_empty?(map_name)
    memo += red_text_tag + map_name + "\n"
    # Write how Pokémon was obtained
    met_text = [
      _INTL("Met at Lv. {1}.", @pokemon.obtain_level),
      _INTL("Egg received."),
      _INTL("Traded at Lv. {1}.", @pokemon.obtain_level),
      "",
      _INTL("Had a fateful encounter at Lv. {1}.", @pokemon.obtain_level)
    ][@pokemon.obtain_method]
    memo += black_text_tag + met_text + "\n" if met_text && met_text != ""
    # If Pokémon was hatched, add when and where it hatched to memo
    if @pokemon.obtain_method == 1
      if @pokemon.timeEggHatched
        date  = @pokemon.timeEggHatched.day
        month = pbGetMonthName(@pokemon.timeEggHatched.mon)
        year  = @pokemon.timeEggHatched.year
        # TODO: Write this date the wrong way round for United States of Americans.
        memo += black_text_tag + _INTL("{1} {2}, {3}", date, month, year) + "\n"
      end
      map_name = pbGetMapNameFromId(@pokemon.hatched_map)
      map_name = _INTL("Faraway place") if nil_or_empty?(map_name)
      memo += red_text_tag + map_name + "\n"
      memo += black_text_tag + _INTL("Egg hatched.") + "\n"
    else
      memo += "\n"   # Empty line
    end
    # Add characteristic to memo
    if show_nature
      best_stat = nil
      best_iv = 0
      stats_order = [:HP, :ATTACK, :DEFENSE, :SPEED, :SPECIAL_ATTACK, :SPECIAL_DEFENSE]
      start_point = @pokemon.personalID % stats_order.length   # Tiebreaker
      stats_order.length.times do |i|
        stat = stats_order[(i + start_point) % stats_order.length]
        if !best_stat || @pokemon.iv[stat] > @pokemon.iv[best_stat]
          best_stat = stat
          best_iv = @pokemon.iv[best_stat]
        end
      end
      characteristics = {
        :HP              => [_INTL("Loves to eat."),
                            _INTL("Takes plenty of siestas."),
                            _INTL("Nods off a lot."),
                            _INTL("Scatters things often."),
                            _INTL("Likes to relax.")],
        :ATTACK          => [_INTL("Proud of its power."),
                            _INTL("Likes to thrash about."),
                            _INTL("A little quick tempered."),
                            _INTL("Likes to fight."),
                            _INTL("Quick tempered.")],
        :DEFENSE         => [_INTL("Sturdy body."),
                            _INTL("Capable of taking hits."),
                            _INTL("Highly persistent."),
                            _INTL("Good endurance."),
                            _INTL("Good perseverance.")],
        :SPECIAL_ATTACK  => [_INTL("Highly curious."),
                            _INTL("Mischievous."),
                            _INTL("Thoroughly cunning."),
                            _INTL("Often lost in thought."),
                            _INTL("Very finicky.")],
        :SPECIAL_DEFENSE => [_INTL("Strong willed."),
                            _INTL("Somewhat vain."),
                            _INTL("Strongly defiant."),
                            _INTL("Hates to lose."),
                            _INTL("Somewhat stubborn.")],
        :SPEED           => [_INTL("Likes to run."),
                            _INTL("Alert to sounds."),
                            _INTL("Impetuous and silly."),
                            _INTL("Somewhat of a clown."),
                            _INTL("Quick to flee.")]
      }
      memo += black_text_tag + characteristics[best_stat][best_iv % 5] + "\n"
    end
    # Write memo
    drawFormattedTextEx(@sprites[:overlay].bitmap, 232, 86, 268, memo)
  end

  def draw_page_three
    # Determine which stats are boosted and lowered by the Pokémon's nature
    stat_themes = {}
    GameData::Stat.each_main { |s| stat_themes[s.id] = :default }
    if !@pokemon.shadowPokemon? || @pokemon.heartStage <= 3
      @pokemon.nature_for_stats.stat_changes.each do |change|
        stat_themes[change[0]] = :raised_stat if change[1] > 0
        stat_themes[change[0]] = :lowered_stat if change[1] < 0
      end
    end
    # Write stats text
    draw_text(_INTL("HP"), 292, 82, align: :center, theme: stat_themes[:HP])
    draw_text(sprintf("%d/%d", @pokemon.hp, @pokemon.totalhp), 462, 82, align: :right, theme: :black)
    draw_text(_INTL("Attack"), 248, 126, theme: stat_themes[:ATTACK])
    draw_text(@pokemon.attack.to_s, 456, 126, align: :right, theme: :black)
    draw_text(_INTL("Defense"), 248, 158, theme: stat_themes[:DEFENSE])
    draw_text(@pokemon.defense.to_s, 456, 158, align: :right, theme: :black)
    draw_text(_INTL("Sp. Atk"), 248, 190, theme: stat_themes[:SPECIAL_ATTACK])
    draw_text(@pokemon.spatk.to_s, 456, 190, align: :right, theme: :black)
    draw_text(_INTL("Sp. Def"), 248, 222, theme: stat_themes[:SPECIAL_DEFENSE])
    draw_text(@pokemon.spdef.to_s, 456, 222, align: :right, theme: :black)
    draw_text(_INTL("Speed"), 248, 254, theme: stat_themes[:SPEED])
    draw_text(@pokemon.speed.to_s, 456, 254, align: :right, theme: :black)
    # Draw ability name and description
    draw_text(_INTL("Ability"), 224, 290)
    ability = @pokemon.ability
    if ability
      draw_text(ability.name, 362, 290, theme: :black)
      drawTextEx(@sprites[:overlay].bitmap, 224, 322, 282, 2, ability.description, *TEXT_COLOR_THEMES[:black])
    end
    # Draw HP bar
    if @pokemon.hp > 0
      bar_width = @pokemon.hp * 96 / @pokemon.totalhp.to_f
      bar_width = 1 if bar_width < 1
      bar_width = ((bar_width / 2).round) * 2
      hp_zone = 0
      hp_zone = 1 if @pokemon.hp <= (@pokemon.totalhp / 2).floor
      hp_zone = 2 if @pokemon.hp <= (@pokemon.totalhp / 4).floor
      draw_image(graphics_folder + "overlay_hp", 360, 110,
                 0, hp_zone * 6, bar_width, 6)
    end
  end

  def draw_page_four(selected_move = nil)
    # Write move names, types and PP amounts for each known move
    text_y = 104
    text_y -= 76 if @new_move
    limit = (@new_move) ? Pokemon::MAX_MOVES + 1 : Pokemon::MAX_MOVES
    limit.times do |i|
      move = @pokemon.moves[i]
      if i == Pokemon::MAX_MOVES
        move = @new_move
        text_y += 20
      end
      if move
        # Draw move type icon
        type_number = GameData::Type.get(move.display_type(@pokemon)).icon_position
        type_rect = Rect.new(0, type_number * GameData::Type::ICON_SIZE[1], *GameData::Type::ICON_SIZE)
        @sprites[:overlay].bitmap.blt(248, text_y - 4, @bitmaps[:types].bitmap, type_rect)
        # Draw move name
        draw_text(move.name, 316, text_y, theme: :black)
        # Draw PP text
        if move.total_pp > 0
          draw_text(_INTL("PP"), 342, text_y + 32, theme: :black)
          pp_text_theme = :black
          if move.pp == 0
            pp_text_theme = :pp_zero
          elsif move.pp * 4 <= move.total_pp
            pp_text_theme = :pp_quarter
          elsif move.pp * 2 <= move.total_pp
            pp_text_theme = :pp_half
          end
          draw_text(sprintf("%d/%d", move.pp, move.total_pp), 460, text_y + 32, align: :right, theme: pp_text_theme)
        end
      else
        # Draw non-existent move name
        draw_text("-", 316, text_y, theme: :black)
        # Draw non-existent PP text
        draw_text("--", 442, text_y + 32, align: :right, theme: :black)
      end
      text_y += 64
    end
    if selected_move
      # Write page header
      draw_text(_INTL("MOVES"), 26, 22)
      # Draw Pokémon's type icon(s)
      @pokemon.types.each_with_index do |type, i|
        type_number = GameData::Type.get(type).icon_position
        type_rect = Rect.new(0, type_number * GameData::Type::ICON_SIZE[1], *GameData::Type::ICON_SIZE)
        type_x = (@pokemon.types.length == 1) ? 130 : 96 + ((GameData::Type::ICON_SIZE[0] + 6) * i)
        @sprites[:overlay].bitmap.blt(type_x, 78, @bitmaps[:types].bitmap, type_rect)
      end
      # Draw selected move's damage category icon
      draw_text(_INTL("CATEGORY"), 20, 128)
      draw_image(UI_FOLDER + "category", 166, 124,
        0, selected_move.display_category(@pokemon) * GameData::Move::CATEGORY_ICON_SIZE[1], *GameData::Move::CATEGORY_ICON_SIZE)
      # Write selected move's power
      draw_text(_INTL("POWER"), 20, 160)
      power_text = selected_move.display_damage(@pokemon)
      power_text = "---" if power_text == 0   # Status move
      power_text = "???" if power_text == 1   # Variable power move
      draw_text(power_text.to_s, 216, 160, align: :right, theme: :black)
      # Write selected move's accuracy
      draw_text(_INTL("ACCURACY"), 20, 192)
      accuracy = selected_move.display_accuracy(@pokemon)
      if accuracy == 0
        draw_text("---", 216, 192, align: :right, theme: :black)
      else
        draw_text("#{accuracy}%", 216 + @sprites[:overlay].bitmap.text_size("%").width, 192, align: :right, theme: :black)
      end
      # Write selected move's description
      drawTextEx(@sprites[:overlay].bitmap, 4, 224, 230, 5, selected_move.description, *TEXT_COLOR_THEMES[:black])
    end
  end

  def draw_page_five
    @sprites[:up_arrow].visible   = false
    @sprites[:down_arrow].visible = false
    # Write various bits of text
    draw_text(_INTL("No. of Ribbons:"), 234, 338, theme: :black)
    draw_text(@pokemon.numRibbons.to_s, 450, 338, align: :right, theme: :black)
    # Draw all ribbons
    (RIBBON_COLUMNS * RIBBON_ROWS).times do |index|   # Number of visible ribbons
      r_index = (@ribbon_offset * RIBBON_COLUMNS) + index
      break if !@pokemon.ribbons[r_index]
      ribbon_data = GameData::Ribbon.get(@pokemon.ribbons[r_index])
      image_offset = ribbon_data.icon_position
      draw_image(graphics_folder + "ribbons",
                 RIBBON_X + ((RIBBON_SIZE[0] + RIBBON_SPACING_X) * (index % RIBBON_COLUMNS)),
                 RIBBON_Y + ((RIBBON_SIZE[1] + RIBBON_SPACING_Y) * (index / RIBBON_COLUMNS).floor),
                 RIBBON_SIZE[0] * (image_offset % RIBBON_COLUMNS_GRAPHIC),
                 RIBBON_SIZE[1] * (image_offset / RIBBON_COLUMNS_GRAPHIC).floor,
                 *RIBBON_SIZE)
    end
    # Draw details of the selected ribbon
    if @ribbon_index
      ribbon_id = @pokemon.ribbons[@ribbon_index]
      # Draw the description box
      draw_image(graphics_folder + "overlay_ribbon", 8, 280)
      if ribbon_id
        ribbon_data = GameData::Ribbon.get(ribbon_id)
        # Draw name of selected ribbon
        draw_text(ribbon_data.name, 18, 292)
        # Draw selected ribbon's description
        drawTextEx(@sprites[:overlay].bitmap, 18, 324, 480, 2, ribbon_data.description, *TEXT_COLOR_THEMES[:black])
      end
    end
  end

  #-----------------------------------------------------------------------------

  def refresh_markings_panel
    # Set values to use when drawing the markings panel
    marking_x = 300
    marking_y = 154
    marking_spacing_x = 42 + MARKING_WIDTH
    marking_spacing_y = 34 + MARKING_HEIGHT
    markings_per_row = 3
    mark_variants = @bitmaps[:markings].bitmap.height / MARKING_HEIGHT
    mark_rect = Rect.new(0, 0, MARKING_WIDTH, MARKING_HEIGHT)
    # Clear the bitmap
    @sprites[:marking_overlay].bitmap.clear
    # Draw marking icons
    (@bitmaps[:markings].bitmap.width / MARKING_WIDTH).times do |i|
      mark_rect.x = i * MARKING_WIDTH
      mark_rect.y = [(@markings[i] || 0), mark_variants - 1].min * MARKING_HEIGHT
      @sprites[:marking_overlay].bitmap.blt(
        marking_x + (marking_spacing_x * (i % markings_per_row)),
        marking_y + (marking_spacing_y * (i / markings_per_row)),
        @bitmaps[:markings].bitmap, mark_rect
      )
    end
    # Draw text
    draw_text(_INTL("Mark {1}", @pokemon.name), 366, 102, align: :center, overlay: :marking_overlay)
    draw_text(_INTL("OK"), 366, 254, align: :center, overlay: :marking_overlay)
    draw_text(_INTL("Cancel"), 366, 304, align: :center, overlay: :marking_overlay)
  end

  def refresh_markings_cursor
    case @marking_index
    when 6   # OK
      @sprites[:marking_cursor].x = 284
      @sprites[:marking_cursor].y = 244
      @sprites[:marking_cursor].src_rect.y = @sprites[:marking_cursor].bitmap.height / 2
    when 7   # Cancel
      @sprites[:marking_cursor].x = 284
      @sprites[:marking_cursor].y = 294
      @sprites[:marking_cursor].src_rect.y = @sprites[:marking_cursor].bitmap.height / 2
    else
      @sprites[:marking_cursor].x = 284 + (58 * (@marking_index % 3))
      @sprites[:marking_cursor].y = 144 + (50 * (@marking_index / 3))
      @sprites[:marking_cursor].src_rect.y = 0
    end
  end

  #-----------------------------------------------------------------------------

  def update_input
    # Check for movement to a new Pokémon
    if Input.trigger?(Input::UP)
      return :previous_pokemon
    elsif Input.trigger?(Input::DOWN)
      return :next_pokemon
    end
    # Check for movement to a new page
    if Input.trigger?(Input::LEFT)
      go_to_previous_page
    elsif Input.trigger?(Input::RIGHT)
      go_to_next_page
    end
    # Check for interaction
    if Input.trigger?(Input::USE)
      if @page == 4   # Moves
        pbPlayDecisionSE
        return :navigate_moves
      elsif @page == 5   # Ribbons
        pbPlayDecisionSE
        return :navigate_ribbons
      elsif @mode != :in_battle
        pbPlayDecisionSE
        return :interact_menu
      end
    elsif Input.trigger?(Input::BACK)
      pbPlayCloseMenuSE
      return :quit
    elsif Input.trigger?(Input::ACTION)
      pbSEStop
      @pokemon.play_cry
    end
    return nil
  end

  #-----------------------------------------------------------------------------

  # Returns true to finish choosing a move.
  def update_input_move
    # Check for movement to a new move
    if Input.repeat?(Input::UP)
      max_move_index = (@new_move) ? Pokemon::MAX_MOVES : Pokemon::MAX_MOVES - 1
      @move_index -= 1
      @move_index = max_move_index if @move_index < 0   # Wrap around
      if @move_index < Pokemon::MAX_MOVES && @move_index >= @pokemon.numMoves
        @move_index = @pokemon.numMoves - 1   # Wrap around
      end
    elsif Input.repeat?(Input::DOWN)
      max_move_index = (@new_move) ? Pokemon::MAX_MOVES : Pokemon::MAX_MOVES - 1
      @move_index += 1
      @move_index = 0 if @move_index > max_move_index   # Wrap around
      if @move_index < Pokemon::MAX_MOVES && @move_index >= @pokemon.numMoves
        @move_index = (@new_move) ? max_move_index : 0   # Wrap around or go to new move
      end
    end
    # Check for interaction
    if Input.trigger?(Input::USE)
      pbPlayDecisionSE
      return true if @mode == :choose_move
      if !@pokemon.shadowPokemon?
        if @swap_move_index >= 0
          # End swapping moves
          if @move_index != @swap_move_index
            @pokemon.moves[@move_index], @pokemon.moves[@swap_move_index] = @pokemon.moves[@swap_move_index], @pokemon.moves[@move_index]
          end
          @swap_move_index = -1
          @sprites[:selected_move_cursor].visible = false
          refresh
        else
          # Start swapping moves
          @swap_move_index = @move_index
          @sprites[:selected_move_cursor].visible = true
          @sprites[:selected_move_cursor].index   = @swap_move_index
          @sprites[:selected_move_cursor].z = @sprites[:move_cursor].z + 1
        end
      end
    elsif Input.trigger?(Input::BACK)
      if @mode == :choose_move
        pbPlayCloseMenuSE
        @move_index = -1
        return true
      else
        # Cancel swapping, or return true
        if @swap_move_index >= 0
          pbPlayCancelSE
          @swap_move_index = -1
          @sprites[:selected_move_cursor].visible = false
        else
          pbPlayCloseMenuSE
          return true
        end
      end
    end
    return false
  end

  # This is used for both general navigating through the list of moves (allowing
  # swapping of moves) and for choosing a move to forget when trying to learn a
  # new one.
  def navigate_moves
    @sprites[:pokemon].visible = false if @sprites[:pokemon]
    @sprites[:pokemon_icon].pokemon = @pokemon
    @sprites[:pokemon_icon].visible = true
    @sprites[:held_item_icon].visible = false if @sprites[:held_item_icon]
    @move_index ||= 0
    @swap_move_index = -1
    refresh
    @sprites[:move_cursor].visible = true
    @sprites[:move_cursor].index = @move_index
    loop do
      Graphics.update
      Input.update
      update_visuals
      old_move_index = @move_index
      break if update_input_move
      if @move_index != old_move_index
        pbPlayCursorSE
        @sprites[:move_cursor].index = @move_index
        if @swap_move_index >= 0
          @sprites[:selected_move_cursor].z = @sprites[:move_cursor].z + 1
          @sprites[:selected_move_cursor].z -= 2 if @move_index != @swap_move_index
        end
        refresh
      end
    end
    if @mode != :choose_move
      @sprites[:move_cursor].visible = false
      @sprites[:pokemon].visible  = true
      @sprites[:pokemon_icon].visible = false
      @sprites[:held_item_icon].visible = true
    end
    ret = @move_index
    @move_index = nil
    return ret
  end

  #-----------------------------------------------------------------------------

  def update_input_ribbon
    # Check for movement to a new ribbon
    if Input.repeat?(Input::UP)
      total_rows = [((@pokemon.ribbons.length + RIBBON_COLUMNS - 1) / RIBBON_COLUMNS).floor, RIBBON_ROWS].max
      @ribbon_index -= RIBBON_COLUMNS
      @ribbon_index += total_rows * RIBBON_COLUMNS if @ribbon_index < 0   # Wrap around
    elsif Input.repeat?(Input::DOWN)
      total_rows = [((@pokemon.ribbons.length + RIBBON_COLUMNS - 1) / RIBBON_COLUMNS).floor, RIBBON_ROWS].max
      @ribbon_index += RIBBON_COLUMNS
      @ribbon_index -= total_rows * RIBBON_COLUMNS if @ribbon_index >= total_rows * RIBBON_COLUMNS   # Wrap around
    elsif Input.repeat?(Input::LEFT)
      @ribbon_index -= 1
      @ribbon_index += RIBBON_COLUMNS if (@ribbon_index % RIBBON_COLUMNS) == RIBBON_COLUMNS - 1
    elsif Input.repeat?(Input::RIGHT)
      @ribbon_index += 1
      @ribbon_index -= RIBBON_COLUMNS if (@ribbon_index % RIBBON_COLUMNS) == 0
    end
    # Check for interaction
    if Input.trigger?(Input::USE)
      if @swap_ribbon_index >= 0
        # End swapping ribbons
        pbPlayDecisionSE
        if @ribbon_index != @swap_ribbon_index
          @pokemon.ribbons[@ribbon_index], @pokemon.ribbons[@swap_ribbon_index] = @pokemon.ribbons[@swap_ribbon_index], @pokemon.ribbons[@ribbon_index]
          @pokemon.ribbons.compact!
          if @ribbon_index >= @pokemon.ribbons.length
            @ribbon_index = @pokemon.ribbons.length - 1
          end
        end
        @swap_ribbon_index = -1
        @sprites[:selected_ribbon_cursor].visible = false
        refresh
      elsif @pokemon.ribbons[@ribbon_index]
        # Start swapping ribbons
        pbPlayDecisionSE
        @swap_ribbon_index = @ribbon_index
        @sprites[:selected_ribbon_cursor].visible = true
        @sprites[:selected_ribbon_cursor].index = @swap_ribbon_index - (@ribbon_offset * RIBBON_COLUMNS)
        @sprites[:selected_ribbon_cursor].z = @sprites[:ribbon_cursor].z + 1
      end
    elsif Input.trigger?(Input::BACK)
      # Cancel swapping, or return true
      if @swap_ribbon_index >= 0
        pbPlayCancelSE
        @swap_ribbon_index = -1
        @sprites[:selected_ribbon_cursor].visible = false
      else
        pbPlayCloseMenuSE
        return true
      end
    end
    return false
  end

  def navigate_ribbons
    @ribbon_index = @ribbon_offset * RIBBON_COLUMNS
    @swap_ribbon_index = -1
    total_rows = [(@pokemon.ribbons.length + RIBBON_COLUMNS - 1) / RIBBON_COLUMNS, RIBBON_ROWS].max
    refresh
    @sprites[:ribbon_cursor].visible = true
    @sprites[:ribbon_cursor].index = @ribbon_index - (@ribbon_offset * RIBBON_COLUMNS)
    loop do
      @sprites[:up_arrow].visible = (@ribbon_offset > 0)
      @sprites[:down_arrow].visible = (@ribbon_offset < total_rows - RIBBON_ROWS)
      Graphics.update
      Input.update
      update_visuals
      old_ribbon_index = @ribbon_index
      old_swap_ribbon_index = @swap_ribbon_index
      break if update_input_ribbon
      if @ribbon_index != old_ribbon_index || @swap_ribbon_index != old_swap_ribbon_index
        pbPlayCursorSE if @swap_ribbon_index == old_swap_ribbon_index
        sel_ribbon_row = @ribbon_index / RIBBON_COLUMNS
        @ribbon_offset = [@ribbon_offset, sel_ribbon_row].min   # Scroll up
        @ribbon_offset = [@ribbon_offset, sel_ribbon_row - RIBBON_ROWS + 1].max   # Scroll down
        @sprites[:ribbon_cursor].index = @ribbon_index - (@ribbon_offset * RIBBON_COLUMNS)
        @sprites[:selected_ribbon_cursor].index = @swap_ribbon_index - (@ribbon_offset * RIBBON_COLUMNS)
        if @swap_ribbon_index >= 0
          @sprites[:selected_ribbon_cursor].z = @sprites[:ribbon_cursor].z + 1
          @sprites[:selected_ribbon_cursor].z -= 2 if @ribbon_index != @swap_ribbon_index
        end
        refresh
      end
    end
    @sprites[:ribbon_cursor].visible = false
    @sprites[:up_arrow].visible      = false
    @sprites[:down_arrow].visible    = false
    @ribbon_index = nil
  end

  #-----------------------------------------------------------------------------

  def update_input_marking
    # Check for movement to a new option
    if Input.repeat?(Input::UP)
      if @marking_index == 7
        @marking_index = 6
      elsif @marking_index == 6
        @marking_index = 4
      elsif @marking_index < 3
        @marking_index = 7
      else
        @marking_index -= 3
      end
    elsif Input.repeat?(Input::DOWN)
      if @marking_index == 7
        @marking_index = 1
      elsif @marking_index == 6
        @marking_index = 7
      elsif @marking_index >= 3
        @marking_index = 6
      else
        @marking_index += 3
      end
    elsif Input.repeat?(Input::LEFT)
      if @marking_index < 6
        @marking_index -= 1
        @marking_index += 3 if (@marking_index % 3) == 2
      end
    elsif Input.repeat?(Input::RIGHT)
      if @marking_index < 6
        @marking_index += 1
        @marking_index -= 3 if (@marking_index % 3) == 0
      end
    end
    # Check for interaction
    if Input.trigger?(Input::USE)
      pbPlayDecisionSE
      case @marking_index
      when 6   # OK
        return true
      when 7   # Cancel
        @marking_index = -1
        return true
      else   # Change marking
        mark_variants = @bitmaps[:markings].bitmap.height / MARKING_HEIGHT
        @markings[@marking_index] = ((@markings[@marking_index] || 0) + 1) % mark_variants
        refresh_markings_panel
      end
    elsif Input.trigger?(Input::BACK)
      pbPlayCloseMenuSE
      @marking_index = -1
      return true
    elsif Input.trigger?(Input::ACTION)
      if @marking_index < 6 && @markings[@marking_index] > 0
        pbPlayDecisionSE
        @markings[@marking_index] = 0
        refresh_markings_panel
      end
    end
    return false
  end

  def navigate_markings
    @sprites[:marking_bg].visible      = true
    @sprites[:marking_overlay].visible = true
    @sprites[:marking_cursor].visible  = true
    @markings = @pokemon.markings.clone
    @marking_index = 0
    refresh_markings_panel
    refresh_markings_cursor
    loop do
      Graphics.update
      Input.update
      update_visuals
      old_marking_index = @marking_index
      break if update_input_marking
      if @marking_index != old_marking_index
        pbPlayCursorSE
        refresh_markings_panel
        refresh_markings_cursor
      end
    end
    @sprites[:marking_bg].visible      = false
    @sprites[:marking_overlay].visible = false
    @sprites[:marking_cursor].visible  = false
    @pokemon.markings = @markings if @marking_index >= 0
    @marking_index = nil
  end
end

#===============================================================================
#
#===============================================================================
class UI::PokemonSummary < UI::BaseScreen
  # party is an array of Pokémon or a single Pokémon.
  # mode is :normal or :choose_move or :in_battle.
  # If mode is :choose_move, new_move is either nil or a move ID.
  def initialize(party, party_index = 0, mode: :normal, new_move: nil)
    @party = (party.is_a?(Array)) ? party : [party]
    @party_index = party_index
    @pokemon = @party[@party_index]
    @mode = mode
    @new_move = (new_move) ? Pokemon::Move.new(new_move) : nil
    super()
    @result = @party_index if @result.nil?
  end

  def initialize_visuals
    @visuals = UI::PokemonSummaryVisuals.new(@party, @party_index, @mode, @new_move)
  end

  def start_screen
    super   # Fade in
    @pokemon.play_cry if @mode != :choose_move
  end

  #-----------------------------------------------------------------------------

  def main
    if @mode == :choose_move
      pbSEPlay("GUI menu open")
      start_screen
      @result = perform_action(:navigate_moves)
      end_screen
      return
    end
    super
  end

  def perform_action(command)
    case command
    when :previous_pokemon
      if @party_index > 0
        new_index = @party_index
        loop do
          new_index -= 1
          break if @party[new_index]
          break if new_index <= 0
        end
        if new_index != @party_index && @party[new_index]
          @party_index = new_index
          @pokemon = @party[@party_index]
          @visuals.set_party_index(@party_index)
        end
      end
    when :next_pokemon
      if @party_index < @party.length - 1
        new_index = @party_index
        loop do
          new_index += 1
          break if @party[new_index]
          break if new_index >= @party.length - 1
        end
        if new_index != @party_index && @party[new_index]
          @party_index = new_index
          @pokemon = @party[@party_index]
          @visuals.set_party_index(@party_index)
        end
      end
    when :navigate_moves
      move_index = @visuals.navigate_moves
      return move_index if @mode == :choose_move
      refresh
    when :navigate_ribbons
      @visuals.navigate_ribbons
      refresh
    when :marking
      @visuals.navigate_markings
      refresh
    when :interact_menu
      if @mode != :in_battle
        commands = {}
        if !@pokemon.egg?
          commands[:give_item] = _INTL("Give item")
          commands[:take_item] = _INTL("Take item") if @pokemon.hasItem?
          commands[:pokedex]   = _INTL("View Pokédex") if $player.has_pokedex
        end
        commands[:marking]     = _INTL("Mark")
        commands[:cancel]      = _INTL("Cancel")
        choice = show_choice(commands)
        perform_action(choice)
      end
    when :give_item
      item = nil
      pbFadeOutIn do
        scene = PokemonBag_Scene.new
        screen = PokemonBagScreen.new(scene, $bag)
        item = screen.pbChooseItemScreen(proc { |itm| GameData::Item.get(itm).can_hold? })
      end
      if item
        refresh if pbGiveItemToPokemon(item, @pokemon, self, @party_index)
      end
    when :take_item
      refresh if pbTakeItemFromPokemon(@pokemon, self)
    when :pokedex
      $player.pokedex.register_last_seen(@pokemon)
      pbFadeOutIn do
        scene = PokemonPokedexInfo_Scene.new
        screen = PokemonPokedexInfoScreen.new(scene)
        screen.pbStartSceneSingle(@pokemon.species)
      end
      refresh
    end
    return nil
  end
end

#===============================================================================
#
#===============================================================================
def pbChooseMove(pokemon, variableNumber, nameVarNumber)
  return if !pokemon
  ret = -1
  pbFadeOutIn do
    screen = UI::PokemonSummary.new(pokemon, mode: :choose_move)
    ret = screen.result
  end
  $game_variables[variableNumber] = ret
  if ret >= 0
    $game_variables[nameVarNumber] = pokemon.moves[ret].name
  else
    $game_variables[nameVarNumber] = ""
  end
  $game_map.need_refresh = true if $game_map
end
