#===============================================================================
#
#===============================================================================
class UI::PokedexDexesVisualsList < Window_CommandPokemon
  SEEN_OWNED_ICON_SIZE = [24, 24]

  def initialize(dexes, width)
    @dexes = dexes
    commands = dexes.map { |dex| dex.is_a?(Array) ? dex[1] : dex }
    super(commands, width)
    @selarrow = AnimatedBitmap.new(UI::PokedexDexesVisuals::UI_FOLDER + "sel_arrow_white")
    self.baseColor   = Color.new(248, 248, 248)
    self.shadowColor = Color.black
    self.windowskin  = nil
  end

  def pokedex_folder
    return UI::PokedexDexesVisuals::UI_FOLDER + UI::PokedexDexesVisuals::GRAPHICS_FOLDER
  end

  #-----------------------------------------------------------------------------

  def drawItem(index, count, rect)
    return if index < 0 || index >= @dexes.length
    entry = @dexes[index]
    rect = drawCursor(index, rect)
    # Draw Region Dex name
    pbDrawShadowText(self.contents, rect.x, rect.y + (self.contents.text_offset_y || 0),
                     rect.width, rect.height, @commands[index], self.baseColor, self.shadowColor)
    return if !entry.is_a?(Array)   # "Exit"
    # Draw seen Poké Ball icon
    all_seen = (entry[2] >= entry[4])
    pbDrawImagePositions(self.contents,
                         [[pokedex_folder + "icon_dexes_seen_own", rect.x + 208, rect.y + 6,
                           (all_seen) ? SEEN_OWNED_ICON_SIZE[0] : 0, 0, *SEEN_OWNED_ICON_SIZE]])
    # Draw seen number
    pbDrawShadowText(self.contents, rect.x + 220, rect.y + (self.contents.text_offset_y || 0),
                     64, rect.height, entry[2].to_s, self.baseColor, self.shadowColor, 2)   # Right align
    # Draw owned Poké Ball icon
    all_owned = (entry[3] >= entry[4])
    pbDrawImagePositions(self.contents,
                         [[pokedex_folder + "icon_dexes_seen_own", rect.x + 308, rect.y + 6,
                           (all_owned) ? SEEN_OWNED_ICON_SIZE[0] : 0, SEEN_OWNED_ICON_SIZE[1], *SEEN_OWNED_ICON_SIZE]])
    # Draw owned number
    pbDrawShadowText(self.contents, rect.x + 320, rect.y + (self.contents.text_offset_y || 0),
                     64, rect.height, entry[3].to_s, self.baseColor, self.shadowColor, 2)   # Right align
  end
end

#===============================================================================
#
#===============================================================================
class UI::PokedexDexesVisuals < UI::BaseVisuals
  GRAPHICS_FOLDER   = "Pokedex/"   # Subfolder in Graphics/UI
  TEXT_COLOR_THEMES = {   # Themes not in DEFAULT_TEXT_COLOR_THEMES
    :header => [Color.new(248, 248, 248), Color.new(192, 32, 40)]
  }

  def initialize(dexes)
    @dexes = dexes
    super()
  end

  def initialize_sprites
    initialize_dex_list
  end

  def initialize_dex_list
    @sprites[:dex_list] = UI::PokedexDexesVisualsList.new(@dexes, Graphics.width - 84)
    @sprites[:dex_list].x = 40
    @sprites[:dex_list].y = 192
    @sprites[:dex_list].height = 192
    @sprites[:dex_list].viewport = @viewport
  end

  #-----------------------------------------------------------------------------

  def background_filename
    return gendered_filename(_INTL("bg_pokedex_menu"))
  end

  def dex_number
    idx = @sprites[:dex_list].index
    return -2 if idx < 0 || idx >= @dexes.length || !@dexes[idx].is_a?(Array)
    return @dexes[idx][0]
  end

  #-----------------------------------------------------------------------------

  def refresh_overlay
    super
    draw_headers
  end

  def draw_headers
    draw_text(_INTL("SEEN"), 318, 158, align: :center, theme: :header)
    draw_text(_INTL("OWNED"), 418, 158, align: :center, theme: :header)
  end

  #-----------------------------------------------------------------------------

  def update_input
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
      if dex_number == -2   # "Exit" (-1 is National Pokédex)
        pbPlayCloseMenuSE
        return :quit
      end
      pbPlayDecisionSE
      return :open_dex
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
class UI::PokedexDexes < UI::BaseScreen
  ACTIONS = HandlerHash.new

  def initialize(dex = -2)
    if dex >= -1
      if !$player&.pokedex.accessible_dexes.include?(dex)
        raise _INTL("Wanted to open the Pokédex using Regional Dex {1} but it isn't unlocked.", dex)
      end
      @dex_number = dex
      @skip_ui = true
    end
    @dexes = get_unlocked_dexes
    if @dexes.length == 2   # 1 Dex plus "Exit"
      @dex_number = @dexes.first[0]
      @skip_ui = true
    end
    super()
  end

  def initialize_visuals
    @visuals = UI::PokedexDexesVisuals.new(@dexes)
  end

  #-----------------------------------------------------------------------------

  # This also adds "Exit" to the end.
  def get_unlocked_dexes
    ret = []
    dex_names = Settings.pokedex_names
    $player&.pokedex.accessible_dexes.each do |dex|
      name = _INTL("Pokédex")
      if dex_names[dex]
        name = ((dex_names[dex].is_a?(Array)) ? dex_names[dex][0] : dex_names[dex])
      end
      ret.push([dex, name,
                $player.pokedex.seen_count(dex),
                $player.pokedex.owned_count(dex),
                pbGetRegionalDexLength(dex)])
    end
    ret.push(_INTL("Exit"))
    return ret
  end

  def dex_number
    return @visuals&.dex_number || @dex_number || 0
  end

  ACTIONS.add(:open_dex, {
    :effect => proc { |screen|
      pbFadeOutIn { UI::Pokedex.new(screen.dex_number).main }
    }
  })

  #-----------------------------------------------------------------------------

  # This method is all that happens if this UI is skipped, i.e. the main Pokédex
  # screen should be shown immediately.
  def main_skipped
    # NOTE: There is intentionally no pbFadeOutIn here.
    UI::Pokedex.new(dex_number).main
  end
end

#===============================================================================
# Method for opening the Pokédex.
#===============================================================================
def pbPokedexScreen(dex = -1)
  pbFadeOutIn { UI::PokedexDexes.new(dex).main }
end
