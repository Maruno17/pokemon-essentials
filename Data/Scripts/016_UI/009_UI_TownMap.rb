#===============================================================================
#
#===============================================================================
class UI::TownMapVisuals < UI::BaseVisuals
  attr_reader :region, :visited_regions

  GRAPHICS_FOLDER      = "Town Map/"   # Subfolder in Graphics/UI
  MAP_TOP_LEFT         = [16, 16]      # Top left of map's display area in pixels
  MAP_SIZE             = [480, 320]    # Size of display area for map in pixels, NOT the map graphic's size
  MAP_SCROLL_PADDING   = [64, 64]      # In pixels. Don't make these more than half of MAP_SIZE!
  CURSOR_MOVE_TIME     = 0.08          # In seconds
  ZOOM_TIME            = 0.2           # In seconds
  ZOOM_CURSOR_POSITION = [MAP_SIZE[0] / 4, MAP_SIZE[1] / 2]
  MARKINGS_COUNT       = 4   # Number of markings a point can have
  MARKING_SPACING      = 8   # In the markings panel (where markings are changed)

  def initialize(region = 0, mode = :normal)
    @region        = region
    @mode          = mode
    @cursor_offset = {:x => 0, :y => 0}
    load_region_data
    find_visited_regions
    super()
    set_player_position
    @sprites[:cursor].x, @sprites[:cursor].y = point_to_screen(@cursor_pos[:x], @cursor_pos[:y])
    center_map_on_cursor
  end

  def initialize_viewport
    super
    @map_viewport = Viewport.new(*MAP_TOP_LEFT, *MAP_SIZE)
    @map_viewport.z = 99999
    @viewport.z = @map_viewport.z + 1
  end

  def initialize_bitmaps
    super
    @bitmaps[:map_markings] = AnimatedBitmap.new(graphics_folder + "map_markings")
    @bitmaps[:details_marking_bg] = AnimatedBitmap.new(graphics_folder + themed_filename("details_marking_bg"))
  end

  def initialize_background
    addBackgroundPlane(@sprites, :background, self.class::GRAPHICS_FOLDER + themed_filename(self.class::BACKGROUND_FILENAME), @viewport)
    @sprites[:background].z = -1000
  end

  def initialize_overlay
    add_overlay(:map_name_overlay, 234, 32)
    @sprites[:map_name_overlay].x = 262
    @sprites[:map_name_overlay].y = Graphics.height - 40
    if @mode == :wall_map
      @sprites[:map_name_overlay].x = (Graphics.width - @sprites[:map_name_overlay].width) / 2
      @sprites[:map_name_overlay].y += 4
    end
    add_overlay(:input_helpers_overlay, 256, 42)
    @sprites[:input_helpers_overlay].y = Graphics.height - 42
  end

  def initialize_sprites
    initialize_map_sprite
    initialize_map_overlay
    initialize_pins
    initialize_cursor
    initialize_details_panel
    initialize_marking_panel
    generate_fly_icons if @mode == :fly
  end

  def initialize_map_sprite
    add_icon_sprite(:map, 0, 0, graphics_folder + @map_data.filename)
    @sprites[:map].viewport = @map_viewport
  end

  # An overlay sprite for the map, which zooms in as it does. Used for drawing
  # unlockable things onto the map.
  def initialize_map_overlay
    add_overlay(:map_overlay, @sprites[:map].width, @sprites[:map].height)
    @sprites[:map_overlay].viewport = @map_viewport
    @sprites[:map_overlay].z = 1
  end

  # These are anything drawn onto the map but which will not enlarge if the map
  # is zoomed in.
  def initialize_pins
    @pins_pos ||= {}
    # Markings
    $PokemonGlobal.townMapMarkings ||= []
    $PokemonGlobal.townMapMarkings[@region] ||= []
    @sprites.each_pair { |key, sprite| sprite.dispose if key.to_s.include?("mark_") }
    @sprites.delete_if { |key, sprite| key.to_s.include?("mark_") }
    @pins_pos.delete_if { |key, sprite| key.to_s.include?("mark_") }
    $PokemonGlobal.townMapMarkings[@region].each do |marking|
      next if !marking || marking[2].all?(0)
      key = "mark_#{marking[0]}_#{marking[1]}".to_sym
      create_pin(key, marking[0], marking[1], graphics_folder + themed_filename("icon_marking"), 50)
    end
    # Roamer icons
    @sprites.each_pair { |key, sprite| sprite.dispose if key.to_s.include?("roamer_") }
    @sprites.delete_if { |key, sprite| key.to_s.include?("roamer_") }
    @pins_pos.delete_if { |key, sprite| key.to_s.include?("roamer_") }
    if @mode != :wall_map
      each_active_roamer do |roamer, i|
        next if !roamer[:icon]
        roamer_map = GameData::MapMetadata.try_get($PokemonGlobal.roamPosition[i])
        next if !roamer_map || !roamer_map.town_map_position
        next if roamer_map.town_map_position[0] != @region
        key = "roamer_#{i}".to_sym
        @pins_pos[key] = [roamer_map.town_map_position[1], roamer_map.town_map_position[2]]
        if roamer_map.town_map_size
          area_width = roamer_map.town_map_size[0]
          area_height = (roamer_map.town_map_size[1].length.to_f / roamer_map.town_map_size[0]).ceil
          @pins_pos[key][0] += (area_width.to_f - 1) / 2
          @pins_pos[key][1] += (area_height.to_f - 1) / 2
        end
        create_pin(key, @pins_pos[key][0], @pins_pos[key][1], graphics_folder + roamer[:icon], 80)
      end
    end
    # Player's head showing their current location
    if !@pins_pos[:player]
      create_pin(:player, 0, 0, GameData::TrainerType.player_map_icon_filename($player.trainer_type), 100)
    end
  end

  def create_pin(key, this_x, this_y, filename, this_z)
    @pins_pos[key] = [this_x, this_y]
    add_icon_sprite(key, 0, 0, filename)
    @sprites[key].x, @sprites[key].y = point_to_screen(this_x, this_y)
    @sprites[key].z = this_z
    @sprites[key].ox = @sprites[key].width / 2
    @sprites[key].oy = @sprites[key].height / 2
    @sprites[key].viewport = @map_viewport
  end

  def initialize_cursor
    @cursor_pos = {:x => 0, :y => 0}   # In points, not pixels
    @sprites[:cursor] = AnimatedSprite.create(
      graphics_folder + themed_filename("cursor"), 2, 5, @map_viewport   # 2 frames, 5/20 seconds per frame
    )
    @sprites[:cursor].z = 1000
    @sprites[:cursor].ox = @sprites[:cursor].height / 2
    @sprites[:cursor].oy = @sprites[:cursor].height / 2
    @sprites[:cursor].play
  end

  def initialize_details_panel
    return if !Settings::ENABLE_TOWN_MAP_ZOOM_IN_FOR_DETAILS
    add_icon_sprite(:details, 256, 16, graphics_folder + themed_filename("details_panel"))
    @sprites[:details].z = 900
    @sprites[:details].visible = false
    add_overlay(:details_overlay, @sprites[:details].width, @sprites[:details].height)
    @sprites[:details_overlay].x = @sprites[:details].x
    @sprites[:details_overlay].y = @sprites[:details].y
    @sprites[:details_overlay].z = @sprites[:details].z + 1
    @sprites[:details_overlay].visible = false
  end

  def initialize_marking_panel
    # Background
    add_icon_sprite(:marking_bg, 0, 0, graphics_folder + themed_filename("marking_bg"))
    @sprites[:marking_bg].z = 1000
    @sprites[:marking_bg].visible = false
    # Overlay
    add_overlay(:marking_overlay, @sprites[:marking_bg].width, @sprites[:marking_bg].height)
    @sprites[:marking_overlay].x = @sprites[:marking_bg].x
    @sprites[:marking_overlay].y = @sprites[:marking_bg].y
    @sprites[:marking_overlay].z = @sprites[:marking_bg].z + 1
    @sprites[:marking_overlay].visible = false
    # Cursor
    @sprites[:marking_cursor] = AnimatedSprite.create(
      graphics_folder + themed_filename("marking_cursor"), 2, 5, @viewport   # 2 frames, 5/20 seconds per frame
    )
    @sprites[:marking_cursor].z = @sprites[:marking_overlay].z + 1
    @sprites[:marking_cursor].ox = @sprites[:marking_cursor].height / 2
    @sprites[:marking_cursor].oy = @sprites[:marking_cursor].height / 2
    @sprites[:marking_cursor].visible = false
    @sprites[:marking_cursor].play
  end

  def dispose
    super
    @map_viewport.dispose
    @viewport.dispose
  end

  #-----------------------------------------------------------------------------

  def themed_filename(base_filename)
    return filename_with_appendix(base_filename, "_wall") if @mode == :wall_map
    # NOTE: The Pokégear theme would be manually chosen by the player, and would
    #       not depend on the player's gender. However, because there isn't a
    #       variable that contains the Pokégear's theme, so for the sake of
    #       example, the player's gender matters here.
    return filename_with_appendix(base_filename, "_f") if $player&.female?
    return base_filename
  end

  def load_region_data
    if !GameData::TownMap.exists?(@region)
      raise _INTL("No Town Map data is defined for region {1}.", @region)
    end
    @map_data = GameData::TownMap.get(@region)
  end

  def find_visited_regions
    @visited_regions = []
    GameData::MapMetadata.each do |map_data|
      next if !map_data.town_map_position || @visited_regions.include?(map_data.town_map_position[0])
      next if !$PokemonGlobal.visitedMaps[map_data.id]
      @visited_regions.push(map_data.town_map_position[0])
    end
  end

  def set_region(new_region)
    return if @region == new_region
    @region = new_region
    load_region_data
    @sprites[:map].setBitmap(graphics_folder + @map_data.filename)
    initialize_pins
    set_player_position
    @sprites[:cursor].x, @sprites[:cursor].y = point_to_screen(@cursor_pos[:x], @cursor_pos[:y])
    center_map_on_cursor
    refresh
  end

  def each_fly_point
    @map_data.points.each do |point|
      yield point if point[:fly_spot]
    end
  end

  def get_point_data(this_x = -1, this_y = -1)
    this_x = @cursor_pos[:x] if this_x < 0
    this_y = @cursor_pos[:y] if this_y < 0
    @map_data.points.each do |point|
      next if point[:position][0] != this_x || point[:position][1] != this_y
      return nil if point[:switch] && (@mode == :wall_map || point[:switch] <= 0 || !$game_switches[point[:switch]])
      return point
    end
    return nil
  end

  #-----------------------------------------------------------------------------

  # Positions the player's head on the town map. It is invisible if the player
  # isn't in a map belonging to that town map. Also sets the cursor's position
  # to the same point.
  def set_player_position
    map_pos = $game_map.metadata&.town_map_position
    if map_pos.nil? || map_pos[0] != @region
      set_cursor_pos((@map_data.size[0] - 1) / 2, (@map_data.size[1] - 1) / 2)   # Middle of the map
      @sprites[:player].visible = false
      return
    end
    @pins_pos[:player] = [map_pos[1], map_pos[2]]
    map_size = $game_map.metadata&.town_map_size
    if map_size
      area_width = map_size[0]
      area_height = (map_size[1].length.to_f / map_size[0]).ceil
      @pins_pos[:player][0] += ($game_player.x * area_width / $game_map.width).floor if area_width > 1
      @pins_pos[:player][1] += ($game_player.y * area_height / $game_map.height).floor if area_height > 1
    end
    @sprites[:player].x, @sprites[:player].y = point_to_screen(*@pins_pos[:player])
    @sprites[:player].visible = true
    set_cursor_pos(*@pins_pos[:player])   # In points
  end

  def can_move_to_point?(new_x, new_y)
    return false if new_x < 0 || new_x >= @map_data.size[0]
    return false if new_y < 0 || new_y >= @map_data.size[1]
    return true
  end

  def cursor_moving?
    return @cursor_offset[:x] != 0 || @cursor_offset[:y] != 0
  end

  def set_cursor_pos(new_x, new_y)
    changed = (@cursor_pos[:x] != new_x) || (@cursor_pos[:y] != new_y)
    @cursor_pos[:x] = new_x
    @cursor_pos[:y] = new_y
    refresh_on_cursor_move if changed
  end

  def point_to_screen(point_x, point_y)
    return point_x_to_screen_x(point_x), point_y_to_screen_y(point_y)
  end

  # Returns the x coordinate of the middle of the point.
  def point_x_to_screen_x(value)
    return ((value * @map_data.point_size[0]) + (@map_data.point_size[0] / 2) + @map_data.margins[0]) * @sprites[:map].zoom_x
  end

  # Returns the y coordinate of the middle of the point.
  def point_y_to_screen_y(value)
    return ((value * @map_data.point_size[1]) + (@map_data.point_size[1] / 2) + @map_data.margins[1]) * @sprites[:map].zoom_y
  end

  # Called during initialization only.
  def center_map_on_cursor
    @map_viewport.ox = @sprites[:cursor].x - (MAP_SIZE[0] / 2)
    @map_viewport.oy = @sprites[:cursor].y - (MAP_SIZE[1] / 2)
    clamp_map_position
  end

  def clamp_map_position
    max_ox = ((@map_data.size[0] * @map_data.point_size[0]) + (@map_data.margins[0] * 2)) * @sprites[:map].zoom_x
    max_oy = ((@map_data.size[1] * @map_data.point_size[1]) + (@map_data.margins[1] * 2)) * @sprites[:map].zoom_y
    if zoomed?
      max_ox -= ZOOM_CURSOR_POSITION[0] * 2
      max_oy -= ZOOM_CURSOR_POSITION[1] * 2
    else
      max_ox -= MAP_SIZE[0]
      max_oy -= MAP_SIZE[1]
    end
    @map_viewport.ox = max_ox if @map_viewport.ox > max_ox
    @map_viewport.oy = max_oy if @map_viewport.oy > max_oy
    @map_viewport.ox = 0 if @map_viewport.ox < 0
    @map_viewport.oy = 0 if @map_viewport.oy < 0
  end

  #-----------------------------------------------------------------------------

  def screen_menu_options
    ret = []
    MenuHandlers.each_available(:town_map_menu, self) do |option, _hash, _name|
      ret.push(option)
    end
    return ret
  end

  def can_access_screen_menu?
    return false if @mode != :normal || @sub_mode == :fly || zoomed?
    return screen_menu_options.length > 1   # At least 1 command (plus "Cancel")
  end

  #-----------------------------------------------------------------------------

  def zoomed?
    return @sprites[:map].zoom_x > 1
  end

  def can_zoom?
    return Settings::ENABLE_TOWN_MAP_ZOOM_IN_FOR_DETAILS && @mode == :normal && !zoomed?
  end

  def zoom_in
    @sprites[:details].visible = true
    @sprites[:details_overlay].visible = true
    @sprites[:input_helpers_overlay].visible = false
    refresh_details_panel(false)
    start_ox = @map_viewport.ox
    start_oy = @map_viewport.oy
    max_ox = (((@map_data.size[0] * @map_data.point_size[0]) + (@map_data.margins[0] * 2)) * 2) - (MAP_SIZE[0] / 2)
    max_oy = (((@map_data.size[1] * @map_data.point_size[1]) + (@map_data.margins[1] * 2)) * 2) - MAP_SIZE[1]
    end_ox = (@sprites[:cursor].x * 2) - ZOOM_CURSOR_POSITION[0]
    end_ox = 0 if end_ox < 0
    end_ox = max_ox if end_ox > max_ox
    end_oy = (@sprites[:cursor].y * 2) - ZOOM_CURSOR_POSITION[1]
    end_oy = 0 if end_oy < 0
    end_oy = max_oy if end_oy > max_oy
    # Animate the zoom in
    animate_zoom(1, 2, start_ox, end_ox, start_oy, end_oy)
    @sprites[:input_helpers_overlay].visible = true
    refresh_input_helpers
  end

  def zoom_out
    @sprites[:input_helpers_overlay].visible = false
    start_ox = @map_viewport.ox
    start_oy = @map_viewport.oy
    max_ox = (@map_data.size[0] * @map_data.point_size[0]) + (@map_data.margins[0] * 2) - MAP_SIZE[0]
    max_oy = (@map_data.size[1] * @map_data.point_size[1]) + (@map_data.margins[1] * 2) - MAP_SIZE[1]
    end_ox = @sprites[:cursor].x - MAP_SIZE[0] / 2
    end_ox = 0 if end_ox < 0
    end_ox = max_ox if end_ox > max_ox
    end_oy = @sprites[:cursor].y - MAP_SIZE[1] / 2
    end_oy = 0 if end_oy < 0
    end_oy = max_oy if end_oy > max_oy
    # Animate the zoom in
    animate_zoom(2, 1, start_ox, end_ox, start_oy, end_oy)
    @sprites[:details].visible = false
    @sprites[:details_overlay].visible = false
    @sprites[:input_helpers_overlay].visible = true
    refresh_input_helpers
  end

  def animate_zoom(start_zoom, end_zoom, start_ox, end_ox, start_oy, end_oy)
    timer_start = System.uptime
    loop do
      Graphics.update
      update_visuals
      now = System.uptime
      @map_viewport.ox = lerp(start_ox, end_ox, ZOOM_TIME, timer_start, now)
      @map_viewport.oy = lerp(start_oy, end_oy, ZOOM_TIME, timer_start, now)
      @sprites[:map].zoom_x = lerp(start_zoom, end_zoom, ZOOM_TIME, timer_start, now)
      @sprites[:map].zoom_y = @sprites[:map].zoom_x
      @sprites[:map_overlay].zoom_x = @sprites[:map].zoom_x
      @sprites[:map_overlay].zoom_y = @sprites[:map].zoom_y
      update_pin_positions_while_zooming
      break if timer_start + ZOOM_TIME <= now
    end
  end

  def update_pin_positions_while_zooming
    @sprites[:cursor].x, @sprites[:cursor].y = point_to_screen(@cursor_pos[:x], @cursor_pos[:y])
    # Player, roamers, markings
    @pins_pos.each_pair do |key, pos|
      @sprites[key].x, @sprites[key].y = point_to_screen(*pos)
    end
  end

  #-----------------------------------------------------------------------------

  def can_mark?
    return Settings::ENABLE_TOWN_MAP_MARKING && @mode == :normal && !can_zoom?
  end

  # Returns the [x, y, [markings]] for the given point. Creates and returns an
  # empty set of markings for that point if there isn't an existing one.
  def markings_of_point(this_x, this_y)
    ret = [@cursor_pos[:x], @cursor_pos[:y], [0] * MARKINGS_COUNT]
    $PokemonGlobal.townMapMarkings[@region].each do |marking|
      next if !marking || marking[0] != @cursor_pos[:x] || marking[1] != @cursor_pos[:y]
      ret = marking
    end
    return ret
  end

  def apply_new_markings(new_markings)
    if new_markings[2].all?(0)
      $PokemonGlobal.townMapMarkings[@region].delete_if { |marking| marking[0] == new_markings[0] && marking[1] == new_markings[1] }
      former_key = "mark_#{new_markings[0]}_#{new_markings[1]}".to_sym
      @sprites.each_pair { |key, sprite| sprite.dispose if key == former_key }
      @sprites.delete(former_key)
      @pins_pos.delete(former_key)
    else
      found_existing = false
      $PokemonGlobal.townMapMarkings[@region].each_with_index do |marking, i|
        next if marking[0] != new_markings[0] || marking[1] != new_markings[1]
        found_existing = true
        $PokemonGlobal.townMapMarkings[@region][i] = new_markings
        break
      end
      if !found_existing
        $PokemonGlobal.townMapMarkings[@region].push(new_markings)
        key = "mark_#{new_markings[0]}_#{new_markings[1]}".to_sym
        create_pin(key, new_markings[0], new_markings[1], graphics_folder + themed_filename("icon_marking"), 50)
      end
    end
  end

  #-----------------------------------------------------------------------------

  def has_fly_points?
    ret = false
    each_fly_point do |point|
      if !$DEBUG || !Input.press?(Input::CTRL)
        next if point[:switch] && (point[:switch] <= 0 || !$game_switches[point[:switch]])
        next if !$PokemonGlobal.visitedMaps[point[:fly_spot][0]]
      end
      ret = true
      break
    end
    return ret
  end

  def start_fly_mode
    return if @mode == :fly || @sub_mode == :fly
    set_sub_mode(:fly)
    generate_fly_icons
    refresh_input_helpers
  end

  def end_fly_mode
    set_sub_mode
    clear_fly_icons
    refresh_input_helpers
  end

  def generate_fly_icons
    @fly_coords = []
    counter = 0
    each_fly_point do |point|
      if !$DEBUG || !Input.press?(Input::CTRL)
        next if point[:switch] && (point[:switch] <= 0 || !$game_switches[point[:switch]])
        next if !$PokemonGlobal.visitedMaps[point[:fly_spot][0]]
      end
      @fly_coords.push(point[:position])
      next if point[:hide_fly_icon]
      counter += 1
      sprite_key = "fly_icon_#{counter}".to_sym
      @sprites[sprite_key] = AnimatedSprite.create(
        graphics_folder + "icon_fly", 2, 10, @map_viewport   # 2 frames, 10/20 seconds per frame
      )
      @sprites[sprite_key].x, @sprites[sprite_key].y = point_to_screen(*point[:position])
      if point[:fly_icon_offset]
        @sprites[sprite_key].x += point[:fly_icon_offset][0]
        @sprites[sprite_key].y += point[:fly_icon_offset][1]
      end
      @sprites[sprite_key].z = 900
      @sprites[sprite_key].ox = @sprites[sprite_key].bitmap.height / 2
      @sprites[sprite_key].oy = @sprites[sprite_key].bitmap.height / 2
      @sprites[sprite_key].play
    end
  end

  def clear_fly_icons
    @sprites.each_pair do |key, sprite|
      next if !key.to_s.include?("fly_icon_")
      sprite.dispose
      @sprites[key] = nil
    end
  end

  #-----------------------------------------------------------------------------

  def refresh
    super
    refresh_map_overlay
    refresh_on_cursor_move
  end

  def refresh_overlay
    super
    refresh_input_helpers
    refresh_map_name
  end

  def refresh_map_overlay
    @sprites[:map_overlay].bitmap.clear
    Settings::REGION_MAP_EXTRAS.each do |graphic|
      next if graphic[0] != @region
      next if !graphic[5] && @mode == :wall_map
      next if graphic[1] <= 0 || !$game_switches[graphic[1]]
      draw_image(graphics_folder + graphic[4],
                 (graphic[2] * @map_data.point_size[0]) + @map_data.margins[0],
                 (graphic[3] * @map_data.point_size[1]) + @map_data.margins[1],
                 overlay: :map_overlay)
    end
  end

  def refresh_on_cursor_move
    refresh_map_name
    refresh_details_panel
  end

  def refresh_map_name
    @sprites[:map_name_overlay].bitmap.clear
    point_data = get_point_data
    if point_data && point_data[:real_name]
      name = pbGetMessageFromHash(MessageTypes::REGION_LOCATION_NAMES, point_data[:real_name])
      name = name.gsub(/\\PN/, $player.name)
      name = name.gsub(/\\v\[(\d+)\]/) { |num| $game_variables[$~[1].to_i].to_s }
      theme = (@mode == :wall_map) ? :black : :white
      draw_text(name, @sprites[:map_name_overlay].width / 2, 6, align: :center, theme: theme, overlay: :map_name_overlay)
    end
  end

  def refresh_input_helpers
    @sprites[:input_helpers_overlay].bitmap.clear
    input_spacing = 24
    icon_text_spacing = 6
    input_x = 4
    action_icon_y = 4
    action_text_y = 12
    draw_input = lambda do |input, action_text|
      draw_input_icon(input_x, action_icon_y, input, action_text, theme: :white, overlay: :input_helpers_overlay)
      input_x += @bitmaps[:input_icons].height + icon_text_spacing
      input_x += @sprites[:input_helpers_overlay].bitmap.text_size(action_text).width
      input_x += input_spacing
    end
    if @mode == :fly || @sub_mode == :fly
      draw_input.call(Input::USE, _INTL("Fly"))
      draw_input.call(Input::BACK, _INTL("Cancel")) if @sub_mode == :fly
      return
    end
    if can_mark?
      draw_input.call(Input::USE, _INTL("Mark"))
    end
    if can_zoom?
      draw_input.call(Input::USE, _INTL("Zoom"))
    elsif zoomed?
      draw_input.call(Input::BACK, _INTL("Zoom"))
    end
    if can_access_screen_menu?
      options = screen_menu_options
      if options.length == 2 && options.include?(:fly_mode)   # Also contains :cancel
        draw_input.call(Input::ACTION, _INTL("Fly"))
      else
        draw_input.call(Input::ACTION, _INTL("Menu"))
      end
    end
  end

  def refresh_details_panel(skip_if_not_visible = true)
    return if skip_if_not_visible && !@sprites[:details]&.visible
    @sprites[:details_overlay].bitmap.clear
    draw_markings_on_details_panel
    draw_point_details_on_details_panel
  end

  def draw_markings_on_details_panel
    return if !Settings::ENABLE_TOWN_MAP_MARKING
    MARKINGS_COUNT.times do |i|
      draw_image(@bitmaps[:details_marking_bg],
                 38 + (168 * (i % 2)) - (@bitmaps[:details_marking_bg].width / 2),
                 44 + (52 * (i / 2)) - (@bitmaps[:details_marking_bg].height / 2),
                 overlay: :details_overlay)
    end
    $PokemonGlobal.townMapMarkings[@region].each do |marking|
      next if !marking || marking[0] != @cursor_pos[:x] || marking[1] != @cursor_pos[:y]
      next if !marking[2]
      marking[2].each_with_index do |mark, i|
        next if mark == 0
        draw_image(@bitmaps[:map_markings],
                   38 + (168 * (i % 2)) - (@bitmaps[:map_markings].height / 2),
                   44 + (52 * (i / 2)) - (@bitmaps[:map_markings].height / 2),
                   @bitmaps[:map_markings].height * (mark - 1), 0,
                   @bitmaps[:map_markings].height, @bitmaps[:map_markings].height,
                   overlay: :details_overlay)
      end
      break
    end
  end

  def draw_point_details_on_details_panel
    point_data = get_point_data
    return if !point_data
    if point_data[:image]
      draw_image(graphics_folder + point_data[:image], 74, 22, overlay: :details_overlay)
    end
    if point_data[:real_description]
      description = pbGetMessageFromHash(MessageTypes::REGION_LOCATION_DESCRIPTIONS, point_data[:real_description])
      description = description.gsub(/\\PN/, $player.name)
      description = description.gsub(/\\v\[(\d+)\]/) { |num| $game_variables[$~[1].to_i].to_s }
      draw_formatted_text(description, 18, 144, 210, theme: :white, overlay: :details_overlay)
    end
  end

  def refresh_markings_panel
    @sprites[:marking_overlay].bitmap.clear
    draw_point_name_on_markings_panel
    draw_marking_slots_on_markings_panel
    draw_markings_lineup_on_markings_panel
  end

  def draw_point_name_on_markings_panel
    point_data = get_point_data
    if point_data && point_data[:real_name]
      name = pbGetMessageFromHash(MessageTypes::REGION_LOCATION_NAMES, point_data[:real_name])
      name = name.gsub(/\\PN/, $player.name)
      name = name.gsub(/\\v\[(\d+)\]/) { |num| $game_variables[$~[1].to_i].to_s }
      draw_text(name, @sprites[:marking_overlay].width / 2, 114, align: :center, theme: :black, overlay: :marking_overlay)
    end
  end

  def draw_marking_slots_on_markings_panel
    # Draw current markings
    middle_y = 168
    MARKINGS_COUNT.times do |i|
      middle_x = (Graphics.width / 2) + ((@bitmaps[:details_marking_bg].width + MARKING_SPACING) * (i - ((MARKINGS_COUNT.to_f - 1) / 2)))
      draw_image(@bitmaps[:details_marking_bg],
                middle_x - (@bitmaps[:details_marking_bg].width / 2),
                middle_y - (@bitmaps[:details_marking_bg].height / 2),
                overlay: :marking_overlay)
      if @markings[2][i] > 0
        draw_image(@bitmaps[:map_markings],
                  middle_x - (@bitmaps[:map_markings].height / 2),
                  middle_y - (@bitmaps[:map_markings].height / 2),
                  @bitmaps[:map_markings].height * (@markings[2][i] - 1), 0,
                  @bitmaps[:map_markings].height, @bitmaps[:map_markings].height,
                  overlay: :marking_overlay)
      end
    end
  end

  def draw_markings_lineup_on_markings_panel
    # Draw all markings to choose from
    middle_y = 292
    icons_count = 1 + (@bitmaps[:map_markings].width / @bitmaps[:map_markings].height)
    icons_count.times do |i|
      middle_x = (Graphics.width / 2) + ((@bitmaps[:details_marking_bg].width + MARKING_SPACING) * (i - ((icons_count.to_f - 1) / 2)))
      draw_image(@bitmaps[:details_marking_bg],
                middle_x - (@bitmaps[:details_marking_bg].width / 2),
                middle_y - (@bitmaps[:details_marking_bg].height / 2),
                overlay: :marking_overlay)
      next if i == 0
      draw_image(@bitmaps[:map_markings],
                middle_x - (@bitmaps[:map_markings].height / 2),
                middle_y - (@bitmaps[:map_markings].height / 2),
                @bitmaps[:map_markings].height * (i - 1), 0,
                @bitmaps[:map_markings].height, @bitmaps[:map_markings].height,
                overlay: :marking_overlay)
    end
  end

  def refresh_markings_cursor
    if @marking_new_index >= 0
      spaces_count = 1 + (@bitmaps[:map_markings].width / @bitmaps[:map_markings].height)
      space_index = @marking_new_index
    else
      spaces_count = MARKINGS_COUNT
      space_index = @marking_index
    end
    middle_x = (Graphics.width / 2) + ((@bitmaps[:details_marking_bg].width + MARKING_SPACING) * (space_index - ((spaces_count.to_f - 1) / 2)))
    @sprites[:marking_cursor].x = middle_x
    @sprites[:marking_cursor].y = (@marking_new_index >= 0) ? 292 : 168
  end

  #-----------------------------------------------------------------------------

  def update_input
    return if cursor_moving? && update_move_cursor
    # Check for cursor movement
    update_direction_input
    if cursor_moving?
      @cursor_timer_start ||= System.uptime
      return
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

  # Moves the cursor after a direction input has said it should move. Returns
  # whether the cursor is still moving.
  def update_move_cursor
    now = System.uptime
    if @cursor_offset[:x] && @cursor_offset[:x] != 0
      point_x = lerp(@cursor_pos[:x] - @cursor_offset[:x], @cursor_pos[:x],
                     CURSOR_MOVE_TIME * @cursor_offset[:x].abs * @sprites[:map].zoom_x,
                     @cursor_timer_start, now)
      @sprites[:cursor].x = point_x_to_screen_x(point_x)
      @cursor_offset[:x] = 0 if @cursor_timer_start + (CURSOR_MOVE_TIME * @cursor_offset[:x].abs * @sprites[:map].zoom_x) <= now
    end
    if @cursor_offset[:y] && @cursor_offset[:y] != 0
      point_y = lerp(@cursor_pos[:y] - @cursor_offset[:y], @cursor_pos[:y],
                     CURSOR_MOVE_TIME * @cursor_offset[:y].abs * @sprites[:map].zoom_y,
                     @cursor_timer_start, now)
      @sprites[:cursor].y = point_y_to_screen_y(point_y)
      @cursor_offset[:y] = 0 if @cursor_timer_start + (CURSOR_MOVE_TIME * @cursor_offset[:y].abs * @sprites[:map].zoom_y) <= now
    end
    update_map_offset
    return true if cursor_moving?
    @cursor_timer_start = nil
    return false
  end

  def update_direction_input
    x_offset = 0
    y_offset = 0
    x_offset = -1 if Input.press?(Input::LEFT)
    x_offset = 1 if Input.press?(Input::RIGHT)
    y_offset = -1 if Input.press?(Input::UP)
    y_offset = 1 if Input.press?(Input::DOWN)
    return if x_offset == 0 && y_offset == 0
    x_offset = 0 if x_offset != 0 && !can_move_to_point?(@cursor_pos[:x] + x_offset, @cursor_pos[:y])
    y_offset = 0 if y_offset != 0 && !can_move_to_point?(@cursor_pos[:x], @cursor_pos[:y] + y_offset)
    return if x_offset == 0 && y_offset == 0
    @cursor_offset[:x] = x_offset
    @cursor_offset[:y] = y_offset
    set_cursor_pos(@cursor_pos[:x] + @cursor_offset[:x], @cursor_pos[:y] + @cursor_offset[:y])
  end

  def update_interaction(input)
    case input
    when Input::USE
      if @mode == :fly || @sub_mode == :fly
        if @fly_coords.include?([@cursor_pos[:x], @cursor_pos[:y]])
          pbPlayDecisionSE
          return :use_fly
        end
      elsif can_zoom?
        pbPlayDecisionSE
        zoom_in
      elsif can_mark?
        pbPlayDecisionSE
        return :marking
      end
    when Input::ACTION
      if @sub_mode == :fly
        pbPlayCancelSE
        end_fly_mode
      elsif can_access_screen_menu?
        pbPlayDecisionSE
        options = screen_menu_options
        return :fly_mode if options.length == 2 && options.include?(:fly_mode)   # Also contains :cancel
        return :screen_menu
      end
    when Input::BACK
      if @sub_mode == :fly
        pbPlayCancelSE
        end_fly_mode
      elsif zoomed?
        pbPlayCancelSE
        zoom_out
      else
        pbPlayCloseMenuSE
        return :quit
      end
    end
    return nil
  end

  # Ensures the cursor remains in the display area by shifting the map sprite's
  # viewport's ox/oy.
  def update_map_offset
    changed = false
    if zoomed?
      if @map_viewport.ox != @sprites[:cursor].x - ZOOM_CURSOR_POSITION[0]
        @map_viewport.ox = @sprites[:cursor].x - ZOOM_CURSOR_POSITION[0]
        changed = true
      end
      if @map_viewport.oy != @sprites[:cursor].y - ZOOM_CURSOR_POSITION[1]
        @map_viewport.oy = @sprites[:cursor].y - ZOOM_CURSOR_POSITION[1]
        changed = true
      end
    else
      if @sprites[:cursor].x - (@map_data.point_size[0] / 2) < @map_viewport.ox + MAP_SCROLL_PADDING[0]
        @map_viewport.ox = @sprites[:cursor].x - (@map_data.point_size[0] / 2) - MAP_SCROLL_PADDING[0]
        changed = true
      elsif @sprites[:cursor].x + (@map_data.point_size[0] / 2) > @map_viewport.ox + MAP_SIZE[0] - MAP_SCROLL_PADDING[0] - @map_data.margins[0]
        @map_viewport.ox = @sprites[:cursor].x + (@map_data.point_size[0] / 2) - MAP_SIZE[0] + MAP_SCROLL_PADDING[0] + @map_data.margins[0]
        changed = true
      end
      if @sprites[:cursor].y - (@map_data.point_size[1] / 2) < @map_viewport.oy + MAP_SCROLL_PADDING[1]
        @map_viewport.oy = @sprites[:cursor].y - (@map_data.point_size[1] / 2) - MAP_SCROLL_PADDING[1]
        changed = true
      elsif @sprites[:cursor].y + (@map_data.point_size[1] / 2) > @map_viewport.oy + MAP_SIZE[1] - MAP_SCROLL_PADDING[1] - @map_data.margins[1]
        @map_viewport.oy = @sprites[:cursor].y + (@map_data.point_size[1] / 2) - MAP_SIZE[1] + MAP_SCROLL_PADDING[1] + @map_data.margins[1]
        changed = true
      end
    end
    clamp_map_position if changed
  end

  #-----------------------------------------------------------------------------

  def update_input_marking
    # Check for movement to a new marking
    if Input.repeat?(Input::LEFT)
      if @marking_new_index >= 0
        @marking_new_index -= 1
        icons_count = 1 + (@bitmaps[:map_markings].width / @bitmaps[:map_markings].height)
        @marking_new_index += icons_count if @marking_new_index < 0
      else
        @marking_index -= 1
        @marking_index += MARKINGS_COUNT if @marking_index < 0
      end
    elsif Input.repeat?(Input::RIGHT)
      if @marking_new_index >= 0
        @marking_new_index += 1
        icons_count = 1 + (@bitmaps[:map_markings].width / @bitmaps[:map_markings].height)
        @marking_new_index -= icons_count if @marking_new_index >= icons_count
      else
        @marking_index += 1
        @marking_index -= MARKINGS_COUNT if @marking_index >= MARKINGS_COUNT
      end
    end
    # Check for up/down movement between marking rows (doesn't apply changes)
    if Input.trigger?(Input::UP) && @marking_new_index >= 0
      pbPlayCursorSE
      @marking_new_index = -1
      refresh_markings_cursor
    elsif Input.trigger?(Input::DOWN) && @marking_new_index < 0
      pbPlayCursorSE
      @marking_new_index = @markings[2][@marking_index]
      refresh_markings_cursor
    end
    # Check for interaction
    if Input.trigger?(Input::USE)
      pbPlayDecisionSE
      if @marking_new_index >= 0   # Chosen a new marking
        if @markings[2][@marking_index] != @marking_new_index
          @markings[2][@marking_index] = @marking_new_index
          refresh_markings_panel
        end
        @marking_new_index = -1
        refresh_markings_cursor
      else   # Start to choose a new marking
        @marking_new_index = @markings[2][@marking_index]
        refresh_markings_cursor
      end
    elsif Input.trigger?(Input::BACK)
      if @marking_new_index >= 0   # Cancel choosing a new marking
        pbPlayCancelSE
        @marking_new_index = -1
        refresh_markings_cursor
      else   # Close the markings panel
        pbPlayCloseMenuSE
        return true
      end
    end
    return false
  end

  def navigate_markings
    # Setup
    @sprites[:marking_bg].visible      = true
    @sprites[:marking_overlay].visible = true
    @sprites[:marking_cursor].visible  = true
    @markings = markings_of_point(@cursor_pos[:x], @cursor_pos[:y])
    @marking_index = 0
    @marking_new_index = -1
    refresh_markings_panel
    refresh_markings_cursor
    # Navigate loop
    loop do
      Graphics.update
      Input.update
      update_visuals
      old_marking_index = @marking_index
      old_marking_new_index = @marking_new_index
      break if update_input_marking
      if @marking_index != old_marking_index ||
         (@marking_new_index != old_marking_new_index && (@marking_new_index == -1) == (old_marking_new_index == -1))
        pbPlayCursorSE
        refresh_markings_cursor
      end
    end
    # Clean up
    @sprites[:marking_bg].visible      = false
    @sprites[:marking_overlay].visible = false
    @sprites[:marking_cursor].visible  = false
    apply_new_markings(@markings)
    @marking_index = nil
    @marking_new_index = nil
  end
end

#===============================================================================
#
#===============================================================================
class UI::TownMap < UI::BaseScreen
  ACTIONS = HandlerHash.new

  # mode is one of:
  #   :normal
  #   :wall_map - Doesn't show unlockable content, can't change region, can't fly
  #   :fly      - Can't zoom or change region, choose a point to fly to
  def initialize(this_region = -1, mode: :normal)
    @region = this_region
    if @region < 0
      this_map_data = $game_map.metadata&.town_map_position
      @region = (this_map_data) ? this_map_data[0] : 0
    end
    @mode = mode
    super()
  end

  def initialize_visuals
    @visuals = UI::TownMapVisuals.new(@region, @mode)
  end

  #-----------------------------------------------------------------------------

  # Shows a choice menu using the MenuHandlers options below.
  ACTIONS.add(:screen_menu, {
    :menu         => :town_map_menu,
    :menu_message => proc { |screen| _INTL("Choose an option.") }
  })

  #-----------------------------------------------------------------------------

  ACTIONS.add(:change_region, {
    :effect => proc { |screen|
      commands = {}
      index = 0
      screen.visited_regions.each do |region|
        region_data = GameData::TownMap.get(region)
        index = commands.length if region_data.id == screen.region
        commands[region] = region_data.name
      end
      commands[:cancel] = _INTL("Cancel")
      region = screen.show_choice_message(_INTL("Which region's map do you want to view?"), commands, screen.region)
      screen.set_region(region) if region && region != :cancel
    }
  })

  def visited_regions
    return @visuals.visited_regions
  end

  def region
    return @visuals.region
  end

  def set_region(new_region)
    @visuals.set_region(new_region)
  end

  #-----------------------------------------------------------------------------

  ACTIONS.add(:fly_mode, {
    :effect => proc { |screen|
      screen.start_fly_mode
    }
  })
  ACTIONS.add(:use_fly, {
    :returns_value => true,
    :effect => proc { |screen|
      next (screen.set_fly_destination) ? :quit : :none
    }
  })

  def has_fly_points?
    return @visuals.has_fly_points?
  end

  def start_fly_mode
    @visuals.start_fly_mode
  end

  def set_fly_destination
    point_data = @visuals.get_point_data
    if !point_data || !point_data[:fly_spot]
      raise _INTL("No data for this point defined in town_map.txt somehow.")
    end
    if @mode != :fly
      map_name = pbGetMapNameFromId(point_data[:fly_spot][0])
      return false if !show_confirm_message(_INTL("Would you like to use Fly to go to {1}?", map_name))
    end
    @result = point_data[:fly_spot]
    return true
  end

  #-----------------------------------------------------------------------------

  ACTIONS.add(:marking, {
    :effect => proc { |screen|
      screen.visuals.navigate_markings
      screen.refresh
    }
  })
end

#===============================================================================
# Menu options for choice menus that exist in the party screen.
#===============================================================================
MenuHandlers.add(:town_map_menu, :fly_mode, {
  "name"      => _INTL("Fly"),
  "order"     => 10,
  "condition" => proc { |screen|
    this_map_data = $game_map.metadata&.town_map_position
    current_region = (this_map_data) ? this_map_data[0] : 0
    next Settings::CAN_FLY_FROM_TOWN_MAP && pbCanFly? && screen.mode == :normal &&
         current_region == screen.region && screen.has_fly_points?
  }
})

MenuHandlers.add(:town_map_menu, :change_region, {
  "name"      => _INTL("Change region"),
  "order"     => 20,
  "condition" => proc { |screen|
    next screen.mode == :normal && screen.visited_regions.length >= 2
  }
})

MenuHandlers.add(:town_map_menu, :cancel, {
  "name"  => _INTL("Cancel"),
  "order" => 9999
})

#===============================================================================
#
#===============================================================================
def pbShowMap(region = -1, wall_map = true)
  mode = (wall_map) ? :wall_map : :normal
  pbFadeOutIn do
    town_map_screen = UI::TownMap.new(region, mode: mode)
    town_map_screen.main
    $game_temp.fly_destination = town_map_screen.result if town_map_screen.result
  end
end
