#===============================================================================
#
#===============================================================================
class UI::BagVisualsList < Window_DrawableCommand
  attr_accessor :sorting

  def initialize(bag, x, y, width, height, viewport)
    @bag = bag
    @sorting = false
    super(x, y, width, height, viewport)
    @selarrow  = AnimatedBitmap.new(bag_folder + "cursor")
    @swaparrow = AnimatedBitmap.new(bag_folder + "cursor_swap")
    self.windowskin = nil
  end

  def dispose
    @swaparrow.dispose
    super
  end

  #-----------------------------------------------------------------------------

  def page_row_max;  return UI::BagVisuals::ITEMS_VISIBLE; end
  def page_item_max; return page_row_max; end

  def itemCount
    return (@items&.length || 0) + 1   # The extra 1 is the Close Bag option
  end

  def bag_folder
    return UI::BagVisuals::UI_FOLDER + UI::BagVisuals::GRAPHICS_FOLDER
  end

  def items=(value)
    @items = value
    refresh
  end

  def item_id
    return (@items[self.index]) ? @items[self.index][0] : nil
  end

  #-----------------------------------------------------------------------------

  # Custom method that allows for an extra option to be displayed above and
  # below the main visible list.
  def itemRect(item)
    if item < 0 || item >= @item_max || item < self.top_item - 1 ||
       item > self.top_item + self.page_item_max
      return Rect.new(0, 0, 0, 0)
    end
    cursor_width = (self.width - self.borderX - ((@column_max - 1) * @column_spacing)) / @column_max
    x = item % @column_max * (cursor_width + @column_spacing)
    y = (item / @column_max * @row_height) - @virtualOy
    return Rect.new(x, y, cursor_width, @row_height)
  end

  #-----------------------------------------------------------------------------

  # This draws all the visible options first, and then draws the cursor. It also
  # draws an additional option above the main visible ones.
  def refresh
    @item_max = itemCount
    update_cursor_rect
    dwidth  = self.width - self.borderX
    dheight = self.height - self.borderY
    self.contents = pbDoEnsureBitmap(self.contents, dwidth, dheight)
    self.contents.clear
    @item_max.times do |i|
      next if i < self.top_item - 1 || i > self.top_item + self.page_item_max
      drawItem(i, @item_max, itemRect(i))
    end
    drawCursor(self.index, itemRect(self.index))
  end

  def switching_base_color=(value)
    @switching_base_color = value
  end

  def switching_shadow_color=(value)
    @switching_shadow_color = value
  end

  def drawItem(index, _count, rect)
    textpos = []
    rect = Rect.new(rect.x + 16, rect.y + 16, rect.width - 16, rect.height)
    if index == self.itemCount - 1
      textpos.push([_INTL("CLOSE BAG"), rect.x, rect.y + 2, :left, self.baseColor, self.shadowColor])
    else
      this_item_id = @items[index][0]
      item_data = GameData::Item.get(this_item_id)
      baseColor   = self.baseColor
      shadowColor = self.shadowColor
      if @sorting && index == self.index
        baseColor   = @switching_base_color || self.baseColor
        shadowColor = @switching_shadow_color || self.shadowColor
      end
      # Draw item name
      textpos.push(
        [item_data.display_name, rect.x, rect.y + 2, :left, baseColor, shadowColor]
      )
      # Draw register icon
      showing_register_icon = false
      if item_data.is_important?
        if @bag.registered?(this_item_id)
          pbDrawImagePositions(
            self.contents,
            [[bag_folder + _INTL("icon_register"), rect.x + rect.width - 72, rect.y + 8, 0, 0, -1, 24]]
          )
          showing_register_icon = true
        elsif pbCanRegisterItem?(this_item_id)
          pbDrawImagePositions(
            self.contents,
            [[bag_folder + _INTL("icon_register"), rect.x + rect.width - 72, rect.y + 8, 0, 24, -1, 24]]
          )
          showing_register_icon = true
        end
      end
      # Draw quantity
      if item_data.show_quantity? && !showing_register_icon
        qty = @items[index][1]
        qtytext = _ISPRINTF("×{1: 3d}", qty)
        xQty    = rect.x + rect.width - self.contents.text_size(qtytext).width - 16
        textpos.push([qtytext, xQty, rect.y + 2, :left, baseColor, shadowColor])
      end
    end
    pbDrawTextPositions(self.contents, textpos)
  end

  def drawCursor(index, rect)
    if self.index == index
      bmp = (@sorting) ? @swaparrow.bitmap : @selarrow.bitmap
      pbCopyBitmap(self.contents, bmp, rect.x, rect.y + 2)
    end
  end

  #-----------------------------------------------------------------------------

  def update
    super
    @uparrow.visible   = false
    @downarrow.visible = false
  end
end

#===============================================================================
#
#===============================================================================
class UI::BagVisuals < UI::BaseVisuals
  attr_reader :sprites

  GRAPHICS_FOLDER   = "Bag/"   # Subfolder in Graphics/UI
  TEXT_COLOR_THEMES = {   # These color themes are added to @sprites[:overlay]
    :default   => [Color.new(248, 248, 248), Color.new(104, 104, 104)],   # Base and shadow colour
#    :white     => [Color.new(248, 248, 248), Color.new(104, 104, 104)],   # Summary screen's white
#    :black     => [Color.new(64, 64, 64), Color.new(176, 176, 176)]       # Summary screen's black
    :white     => [Color.new(248, 248, 248), Color.new(0, 0, 0)],
    :black     => [Color.new(88, 88, 80), Color.new(168, 184, 184)],
    :switching => [Color.new(224, 0, 0), Color.new(248, 144, 144)]
  }
  ITEMS_VISIBLE = 7

  def initialize(bag, mode = :normal)
    @bag = bag
    @mode = mode
    @pocket = @bag.last_viewed_pocket
    super()
  end

  def initialize_bitmaps
    @bitmaps[:slider] = AnimatedBitmap.new(graphics_folder + "icon_slider")
    @bitmaps[:pocket_icons] = AnimatedBitmap.new(graphics_folder + "icon_pocket")
  end

  def initialize_overlay
    super
    add_overlay(:slider_overlay, 36, 470 + 38 + 38)
    @sprites[:slider_overlay].x = 470
    @sprites[:slider_overlay].y = 54 - 38
  end

  def initialize_sprites
    initialize_pocket_sprites
    initialize_item_list
    initialize_item_sprites
  end

  def initialize_pocket_sprites
    @sprites[:bag] = IconSprite.new(30, 20, @viewport)
    @sprites[:pocket_icons] = BitmapSprite.new(186, 32, @viewport)
    @sprites[:pocket_icons].x = 0
    @sprites[:pocket_icons].y = 224
    # TODO: I won't need these two animated arrows once new ones are put next to
    #       the pocket icons.
    # Arrow to indicate more ribbons are above the ones visible when navigating ribbons
    add_animated_arrow(:left_arrow, -4, 76, :left)
    @sprites[:left_arrow].z = 1700
    # TODO: Set visibility.
#    @sprites[:left_arrow].visible = (!@choosing || numfilledpockets > 1)
    # Arrow to indicate more ribbons are below the ones visible when navigating ribbons
    add_animated_arrow(:right_arrow, 150, 76, :right)
    @sprites[:right_arrow].z = 1700
    # TODO: Set visibility.
#    @sprites[:right_arrow].visible = (!@choosing || numfilledpockets > 1)
  end

  def initialize_item_list
    @sprites[:item_list] = UI::BagVisualsList.new(@bag, 168, -8, 314, 40 + 32 + (ITEMS_VISIBLE * 32), @viewport)
    @sprites[:item_list].baseColor              = TEXT_COLOR_THEMES[:black][0]
    @sprites[:item_list].shadowColor            = TEXT_COLOR_THEMES[:black][1]
    @sprites[:item_list].switching_base_color   = TEXT_COLOR_THEMES[:switching][0]
    @sprites[:item_list].switching_shadow_color = TEXT_COLOR_THEMES[:switching][1]
    @sprites[:item_list].items                  = @bag.pockets[@pocket]
    @sprites[:item_list].index                  = @bag.last_viewed_index(@pocket) if @mode != :choose_item
    @sprites[:item_list].active                 = false
  end

  def initialize_item_sprites
    # Selected item's icon
    @sprites[:item_icon] = ItemIconSprite.new(48, Graphics.height - 48, nil, @viewport)
    # Selected item's description text box
    @sprites[:item_description] = Window_UnformattedTextPokemon.newWithSize(
      "", 72, 272, Graphics.width - 96, 128, @viewport
    )
    @sprites[:item_description].baseColor   = TEXT_COLOR_THEMES[:white][0]
    @sprites[:item_description].shadowColor = TEXT_COLOR_THEMES[:white][1]
    @sprites[:item_description].visible     = true
    @sprites[:item_description].windowskin  = nil
  end

  #-----------------------------------------------------------------------------

  def background_filename
    ret = gendered_filename(self.class::BACKGROUND_FILENAME + "_" + @pocket.to_s)
    return ret if pbResolveBitmap(graphics_folder + ret)
    return super
  end

  def index
    return @sprites[:item_list].index
  end

  def item
    return @sprites[:item_list].item_id
  end

  #-----------------------------------------------------------------------------

  def set_filter_proc(filter_proc)
    @filter_proc = filter_proc
    # Create filtered pocket lists
    all_pockets = GameData::BagPocket.all_pockets
    @filtered_list = {}
    all_pockets.each do |pckt|
      @filtered_list[pckt] = []
      @bag.pockets[pckt].length.times do |j|
        @filtered_list[pckt].push(@bag.pockets[pckt][j]) if @filter_proc.call(@bag.pockets[pckt][j][0])
      end
    end
    # Ensure current pocket is one that isn't empty
    new_pocket_index = 0
    if @mode == :choose_item_in_battle && !@filtered_list[@bag.last_viewed_pocket].empty?
      new_pocket_index = all_pockets.index(@bag.last_viewed_pocket)
    end
    all_pockets.length.times do |i|
      next_pocket_index = (new_pocket_index + i) % all_pockets.length
      next if @filtered_list[all_pockets[next_pocket_index]].empty?
      new_pocket_index = next_pocket_index
      break
    end
    new_pocket_index = 0 if @filtered_list[all_pockets[new_pocket_index]].empty?   # In case all pockets are empty
    new_pocket = all_pockets[new_pocket_index]
    # Set the new pocket
    set_pocket(new_pocket)
    @sprites[:item_list].index = 0
  end

  def set_pocket(new_pocket)
    @pocket = new_pocket
    @bag.last_viewed_pocket = @pocket if @mode != :choose_item
    if @filtered_list
      @sprites[:item_list].items = @filtered_list[@pocket]
    else
      @sprites[:item_list].items = @bag.pockets[@pocket]
    end
    @sprites[:item_list].index = @bag.last_viewed_index(@pocket)
    refresh
  end

  def go_to_next_pocket
    new_pocket = @pocket
    all_pockets = GameData::BagPocket.all_pockets
    new_pocket_index = all_pockets.index(new_pocket)
    loop do
      new_pocket_index = (new_pocket_index + 1) % all_pockets.length
      new_pocket = all_pockets[new_pocket_index]
      break if ![:choose_item, :choose_item_in_battle].include?(@mode)
      break if new_pocket == @pocket   # Bag is empty somehow
      if @filtered_list
        break if @filtered_list[new_pocket].length > 0
      else
        break if @bag.pockets[new_pocket].length > 0
      end
    end
    return if new_pocket == @pocket
    pbPlayCursorSE
    set_pocket(new_pocket)
  end

  def go_to_previous_pocket
    new_pocket = @pocket
    all_pockets = GameData::BagPocket.all_pockets
    new_pocket_index = all_pockets.index(new_pocket)
    loop do
      new_pocket_index = (new_pocket_index - 1) % all_pockets.length
      new_pocket = all_pockets[new_pocket_index]
      break if ![:choose_item, :choose_item_in_battle].include?(@mode)
      break if new_pocket == @pocket   # Bag is empty somehow
      if @filtered_list
        break if @filtered_list[new_pocket].length > 0
      else
        break if @bag.pockets[new_pocket].length > 0
      end
    end
    return if new_pocket == @pocket
    pbPlayCursorSE
    set_pocket(new_pocket)
  end

  def switch_index
    return @switch_index || -1
  end

  def can_switch?
    return false if @mode != :normal || @filtered_list
    return false if @bag.pockets[@pocket].length <= 1
    return false if index >= @bag.pockets[@pocket].length
    return false if GameData::BagPocket.get(@pocket).auto_sort
    return true
  end

  def switching?
    return switch_index >= 0
  end

  def start_switching(sw_index)
    @switch_index = sw_index
    @sprites[:item_list].sorting = true
    refresh_item_list
  end

  def end_switching
    @switch_index = -1
    @sprites[:item_list].sorting = false
    refresh_item_list
  end

  def cancel_switching
    this_pocket = @bag.pockets[@pocket]
    this_pocket.insert(@switch_index, this_pocket.delete_at(@sprites[:item_list].index))
    @sprites[:item_list].items = this_pocket
    @sprites[:item_list].index = @switch_index
    end_switching
    refresh
  end

  #-----------------------------------------------------------------------------

  def refresh
    super
    refresh_background
    refresh_pocket_icons
    refresh_pocket
    refresh_item_list
    refresh_slider
    refresh_selected_item
  end

  def refresh_background
    @sprites[:background].setBitmap(graphics_folder + background_filename)
  end

  def refresh_pocket_icons
    icon_size = [28, 28]
    icon_overlap = 6
    icon_x = 2
    icon_y = 2
    @sprites[:pocket_icons].bitmap.clear
    all_pockets = GameData::BagPocket.all_pockets
    # Draw regular pocket icons
    all_pockets.each_with_index do |pckt, i|
      icon_pos = GameData::BagPocket.get(pckt).icon_position
      draw_image(@bitmaps[:pocket_icons], icon_x + (i * (icon_size[0] - icon_overlap)), icon_y,
                icon_pos * icon_size[0], icon_size[1], *icon_size, overlay: :pocket_icons)
    end
    # Draw disabled pocket icons
    if [:choose_item, :choose_item_in_battle].include?(@mode) && @filtered_list
      all_pockets.each_with_index do |pckt, i|
        next if @filtered_list[pckt].length > 0
        icon_pos = GameData::BagPocket.get(pckt).icon_position
        draw_image(@bitmaps[:pocket_icons], icon_x + (i * (icon_size[0] - icon_overlap)), icon_y,
                   icon_pos * icon_size[0], icon_size[1] * 2, *icon_size, overlay: :pocket_icons)
      end
    end
    # Draw selected pocket's icon
    pocket_number = GameData::BagPocket.index(@pocket)
    icon_pos = GameData::BagPocket.get(@pocket).icon_position
    draw_image(@bitmaps[:pocket_icons], icon_x + (pocket_number * (icon_size[0] - icon_overlap)), icon_y,
               icon_pos * icon_size[0], 0, *icon_size, overlay: :pocket_icons)
    # TODO: Draw the left and right arrows, if @mode != :choose_item ||
    #       @filtered_list has 2+ non-empty pockets.
  end

  def refresh_pocket
    # Draw pocket's name
    draw_text(GameData::BagPocket.get(@pocket).name, 94, 186, align: :center, theme: :black)
    # Set the bag sprite
    bag_sprite_filename = graphics_folder + gendered_filename(sprintf("bag_%s", @pocket.to_s))
    @sprites[:bag].setBitmap(bag_sprite_filename)
  end

  def refresh_item_list
    @sprites[:item_list].refresh
  end

  # TODO: Probably turn this method into a helper method. Put the defined values
  #       in constants so that initializing the slider overlay can use them to
  #       automatically determine its size.
  def refresh_slider
    @sprites[:slider_overlay].bitmap.clear
    # Define useful values
    slider_rects = {
      :up_arrow   => [0, 0, 36, 38],
      :down_arrow => [0, 38, 36, 38],
      :box_top    => [36, 0, 36, 4],
      :box_middle => [36, 4, 36, 16],
      :box_bottom => [36, 20, 36, 18]
    }
    slider_x = 0
    slider_y = slider_rects[:up_arrow][3]
    slider_height = 174
    min_box_height = slider_rects[:box_top][3] + slider_rects[:box_middle][3] + slider_rects[:box_bottom][3]
    # Draw things
    show_slider = false
    # Draw slider up arrow
    if @sprites[:item_list].top_row > 0
      draw_image(@bitmaps[:slider], slider_x, slider_y - slider_rects[:up_arrow][3],
                 *slider_rects[:up_arrow], overlay: :slider_overlay)
      show_slider = true
    end
    # Draw slider down arrow
    if @sprites[:item_list].top_item + @sprites[:item_list].page_item_max < @sprites[:item_list].itemCount
      draw_image(@bitmaps[:slider], slider_x, slider_y + slider_height,
                 *slider_rects[:down_arrow], overlay: :slider_overlay)
      show_slider = true
    end
    # Draw slider box
    if show_slider
      box_height = (slider_height * @sprites[:item_list].page_row_max / @sprites[:item_list].row_max).floor
      box_height += [(slider_height - box_height) / 2, slider_height / 6].min   # Make it bigger than expected
      box_height = [box_height.floor, min_box_height].max
      box_y = slider_rects[:up_arrow][3]
      box_y += ((slider_height - box_height) * @sprites[:item_list].top_row / (@sprites[:item_list].row_max - @sprites[:item_list].page_row_max)).floor
      # Draw slider box top
      draw_image(@bitmaps[:slider], slider_x, box_y,
                 *slider_rects[:box_top], overlay: :slider_overlay)
      # Draw slider box middle
      middle_height = box_height - slider_rects[:box_top][3] - slider_rects[:box_bottom][3]
      iterations = (middle_height / slider_rects[:box_middle][3].to_f).ceil
      iterations.times do |i|
        segment_y = box_y + slider_rects[:box_top][3] + (i * slider_rects[:box_middle][3])
        box_middle_rect = slider_rects[:box_middle].clone
        if i == iterations - 1   # Last part
          box_middle_rect[3] = middle_height - (i * slider_rects[:box_middle][3])
        end
        draw_image(@bitmaps[:slider], slider_x, segment_y,
                   *box_middle_rect, overlay: :slider_overlay)
      end
      # Draw slider box bottom
      draw_image(@bitmaps[:slider], slider_x, box_y + box_height - slider_rects[:box_bottom][3],
                 *slider_rects[:box_bottom], overlay: :slider_overlay)
    end
  end

  def refresh_selected_item
    selected_item = item
    # Set the selected item's icon
    @sprites[:item_icon].item = selected_item
    # Set the selected item's description
    if selected_item
      @sprites[:item_description].text = GameData::Item.get(selected_item).description
    else
      @sprites[:item_description].text = _INTL("Close bag.")
    end
  end

  def refresh_on_index_changed(old_index)
    if switching?
      # Skip past "Cancel"
      this_pocket = @bag.pockets[@pocket]
      if index >= this_pocket.length
        @sprites[:item_list].index = (old_index == this_pocket.length - 1) ? 0 : this_pocket.length - 1
      end
      # Move the item being switched
      this_pocket.insert(index, this_pocket.delete_at(old_index))
      @sprites[:item_list].items = this_pocket
    end
    @bag.set_last_viewed_index(@pocket, index) if @mode != :choose_item
    refresh_slider
    refresh_selected_item
  end

  #-----------------------------------------------------------------------------

  def update_input
    # Check for movement to a new pocket
    if Input.repeat?(Input::LEFT)
      go_to_previous_pocket if !switching?
    elsif Input.repeat?(Input::RIGHT)
      go_to_next_pocket if !switching?
    end
    # Check for interaction
    if Input.trigger?(Input::USE)
      return update_interaction(Input::USE)
    elsif Input.trigger?(Input::BACK)
      return update_interaction(Input::BACK)
    elsif Input.trigger?(Input::ACTION)
      return update_interaction(Input::ACTION)
    elsif Input.trigger?(Input::SPECIAL)
      return update_interaction(Input::SPECIAL)
    end
    return nil
  end

  def update_interaction(input)
    case input
    when Input::USE
      if switching?
        pbPlayDecisionSE
        return :switch_item_end
      end
      if !item   # "CLOSE BAG"
        pbPlayCloseMenuSE
        return :quit
      end
      pbPlayDecisionSE
      return :interact_menu
    when Input::ACTION
      if switching?
        pbPlayDecisionSE
        return :switch_item_end
      elsif can_switch?
        pbPlayDecisionSE
        return :switch_item_start
      end
    when Input::SPECIAL
      # TODO: May be unused. Originally toggled registering an item, but this
      #       has been disabled for ages.
    when Input::BACK
      if switching?
        pbPlayCancelSE
        return :switch_item_cancel
      end
      pbPlayCloseMenuSE
      return :quit
    end
    return nil
  end

  def navigate
    @sprites[:item_list].active = true
    ret = super
    @sprites[:item_list].active = false
    return ret
  end

  #-----------------------------------------------------------------------------

  def update_input_choose_item
    # Check for movement to a new pocket
    if Input.repeat?(Input::LEFT)
      go_to_previous_pocket
    elsif Input.repeat?(Input::RIGHT)
      go_to_next_pocket
    end
    # Check for interaction
    if Input.trigger?(Input::USE)
      return update_interaction_choose_item(Input::USE)
    elsif Input.trigger?(Input::BACK)
      return update_interaction_choose_item(Input::BACK)
    end
    return nil
  end

  def update_interaction_choose_item(input)
    case input
    when Input::USE
      if !item   # "CLOSE BAG"
        pbPlayCloseMenuSE
        return :quit
      end
      pbPlayDecisionSE
      return :chosen
    when Input::BACK
      pbPlayCloseMenuSE
      return :quit
    end
    return nil
  end

  def navigate_choose_item
    @sprites[:item_list].active = true
    ret = nil
    loop do
      Graphics.update
      Input.update
      old_index = index
      update_visuals
      refresh_on_index_changed(old_index) if index != old_index
      ret = update_input_choose_item
      break if ret
    end
    @sprites[:item_list].active = false
    return ret
  end
end

#===============================================================================
#
#===============================================================================
class UI::Bag < UI::BaseScreen
  attr_reader :bag

  SCREEN_ID = :bag_screen

  def initialize(bag, mode: :normal)
    @bag = bag
    @mode = mode
    super()
  end

  def initialize_visuals
    @visuals = UI::BagVisuals.new(@bag, @mode)
  end

  #-----------------------------------------------------------------------------

  def item
    return nil if @visuals.item.nil?
    return GameData::Item.get(@visuals.item)
  end

  def set_filter_proc(filter_proc)
    @visuals.set_filter_proc(filter_proc)
  end

  def switch_index
    return @visuals.switch_index
  end

  def switching?
    return @visuals.switching?
  end

  def start_switching(index = nil)
    @visuals.start_switching(index || @visuals.index)
  end

  def cancel_switching
    @visuals.cancel_switching
  end

  def switch_items(index1, index2)
    @visuals.end_switching
  end

  #-----------------------------------------------------------------------------

  def choose_item
    start_screen
    loop do
      on_start_main_loop
      chosen_item = choose_item_core
      if chosen_item && block_given?
        next if !yield chosen_item
      end
      @result = chosen_item
      break
    end
    end_screen
    return @result
  end

  def choose_item_core
    command = @visuals.navigate_choose_item
    return item.id if command == :chosen
    return nil
  end
end

#===============================================================================
#
#===============================================================================
# Shows a choice menu using the MenuHandlers options below.
UIActionHandlers.add(UI::Bag::SCREEN_ID, :screen_menu, {
  :menu         => :bag_screen_menu,
  :menu_message => proc { |screen| _INTL("Choose an option.") }
})

#-------------------------------------------------------------------------------

# Shows a choice menu using the MenuHandlers options below.
UIActionHandlers.add(UI::Bag::SCREEN_ID, :interact_menu, {
  :menu         => :bag_screen_interact,
  :menu_message => proc { |screen| _INTL("{1} is selected.", screen.item.name) }
})

UIActionHandlers.add(UI::Bag::SCREEN_ID, :read_mail, {
  :effect => proc { |screen|
    pbFadeOutInWithUpdate(screen.sprites) do
      pbDisplayMail(Mail.new(screen.item.id, "", ""))
    end
  }
})

UIActionHandlers.add(UI::Bag::SCREEN_ID, :use, {
  :returns_value => true,
  :effect        => proc { |screen|
    item = screen.item.id
    ret = pbUseItem(screen.bag, item, screen)
    # ret: 0=Item wasn't used; 1=Item used; 2=Close Bag to use in field
    if ret == 2
      screen.result = item
      next :quit
    end
    screen.refresh
    next nil
  }
})

UIActionHandlers.add(UI::Bag::SCREEN_ID, :give, {
  :effect => proc { |screen|
    if $player.pokemon_count == 0
      screen.show_message(_INTL("There is no Pokémon."))
    elsif screen.item.is_important?
      screen.show_message(_INTL("The {1} can't be held.", screen.item.portion_name))
    else
      pbFadeOutInWithUpdate(screen.sprites) do
        party_screen = UI::Party.new($player.party, mode: :choose_pokemon)
        party_screen.choose_pokemon do |pkmn, party_index|
          pbGiveItemToPokemon(screen.item.id, party_screen.pokemon, party_screen, party_index) if party_index >= 0
          next true
        end
        screen.refresh
      end
    end
  }
})

UIActionHandlers.add(UI::Bag::SCREEN_ID, :toss, {
  :effect => proc { |screen|
    qty = screen.bag.quantity(screen.item.id)
    if qty > 1
      help_text = _INTL("Toss out how many {1}?", screen.item.portion_name_plural)
      qty = screen.choose_number(help_text, qty)
    end
    if qty > 0
      item_name = (qty > 1) ? screen.item.portion_name_plural : screen.item.portion_name
      if screen.show_confirm_message(_INTL("Is it OK to throw away {1} {2}?", qty, item_name))
        qty.times { screen.bag.remove(screen.item.id) }
        screen.refresh
        screen.show_message(_INTL("Threw away {1} {2}.", qty, item_name))
      end
    end
  }
})

# Handles both registering and unregistering the item.
UIActionHandlers.add(UI::Bag::SCREEN_ID, :register, {
  :effect => proc { |screen|
    if screen.bag.registered?(screen.item.id)
      screen.bag.unregister(screen.item.id)
    else
      screen.bag.register(screen.item.id)
    end
    screen.refresh
  }
})

UIActionHandlers.add(UI::Bag::SCREEN_ID, :debug, {
  :effect => proc { |screen|
    command = 0
    loop do
      command = screen.show_choice_message(
        _INTL("Do what with {1}?", screen.item.name),
        [_INTL("Change quantity"), _INTL("Make Mystery Gift"), _INTL("Cancel")], command)
      case command
      when 0   # Change quantity
        qty = screen.bag.quantity(screen.item.id)
        item_name_plural = screen.item.name_plural
        params = ChooseNumberParams.new
        params.setRange(0, PokemonBag::MAX_PER_SLOT)
        params.setDefaultValue(qty)
        new_qty = screen.choose_number(
          _INTL("Choose new quantity of {1} (max. {2}).", item_name_plural, PokemonBag::MAX_PER_SLOT), params
        )
        if new_qty > qty
          screen.bag.add(screen.item.id, new_qty - qty)
        elsif new_qty < qty
          screen.bag.remove(screen.item.id, qty - new_qty)
        end
        screen.refresh
        break if new_qty == 0
      when 1   # Make Mystery Gift
        pbCreateMysteryGift(1, screen.item.id)
      else
        break
      end
    end
  }
})

#-------------------------------------------------------------------------------

UIActionHandlers.add(UI::Bag::SCREEN_ID, :switch_item_start, {
  :effect => proc { |screen|
    screen.start_switching
  }
})

UIActionHandlers.add(UI::Bag::SCREEN_ID, :switch_item_end, {
  :effect => proc { |screen|
    screen.switch_items(screen.switch_index, screen.index)
  }
})

UIActionHandlers.add(UI::Bag::SCREEN_ID, :switch_item_cancel, {
  :effect => proc { |screen|
    screen.cancel_switching
  }
})

#===============================================================================
# Menu options for choice menus that exist in the party screen.
#===============================================================================
MenuHandlers.add(:bag_screen_menu, :open_storage, {
  "name"      => _INTL("Access Pokémon Boxes"),
  "order"     => 10,
#  "condition" => proc { |screen| next screen.can_access_storage? }
})

MenuHandlers.add(:bag_screen_menu, :cancel, {
  "name"      => _INTL("Cancel"),
  "order"     => 9999
})

#-------------------------------------------------------------------------------

MenuHandlers.add(:bag_screen_interact, :read_mail, {
  "name"      => _INTL("Read"),
  "order"     => 10,
  "condition" => proc { |screen| next screen.item.is_mail? }
})

MenuHandlers.add(:bag_screen_interact, :use, {
  "name"      => proc { |screen|
    next ItemHandlers.getUseText(screen.item.id) if ItemHandlers.hasUseText(screen.item.id)
    next _INTL("Use")
  },
  "order"     => 20,
  "condition" => proc { |screen|
    next ItemHandlers.hasOutHandler(screen.item.id) || (screen.item.is_machine? && $player.party.length > 0)
  }
})

MenuHandlers.add(:bag_screen_interact, :give, {
  "name"      => _INTL("Give"),
  "order"     => 30,
  "condition" => proc { |screen| next $player.pokemon_party.length > 0 && screen.item.can_hold? }
})

MenuHandlers.add(:bag_screen_interact, :toss, {
  "name"      => _INTL("Toss"),
  "order"     => 40,
  "condition" => proc { |screen| next !screen.item.is_important? || $DEBUG }
})

MenuHandlers.add(:bag_screen_interact, :register, {
  "name"      => proc { |screen|
    next _INTL("Deselect") if $bag.registered?(screen.item.id)
    next _INTL("Select")
  },
  "order"     => 50,
  "condition" => proc { |screen| next pbCanRegisterItem?(screen.item.id) }
})

MenuHandlers.add(:bag_screen_interact, :debug, {
  "name"      => _INTL("Debug"),
  "order"     => 60,
  "condition" => proc { |screen| next $DEBUG }
})

MenuHandlers.add(:bag_screen_interact, :cancel, {
  "name"      => _INTL("Cancel"),
  "order"     => 9999
})
