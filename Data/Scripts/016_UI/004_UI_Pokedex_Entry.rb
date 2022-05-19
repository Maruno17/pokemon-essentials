#===============================================================================
#
#===============================================================================
class PokemonPokedexInfo_Scene
  def pbStartScene(dexlist, index, region)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @dexlist = dexlist
    @index   = index
    @region  = region
    @page = 1
    @show_battled_count = false
    @typebitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Pokedex/icon_types"))
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["infosprite"] = PokemonSprite.new(@viewport)
    @sprites["infosprite"].setOffset(PictureOrigin::CENTER)
    @sprites["infosprite"].x = 104
    @sprites["infosprite"].y = 136
    @mapdata = pbLoadTownMapData
    mappos = $game_map.metadata&.town_map_position
    if @region < 0                                 # Use player's current region
      @region = (mappos) ? mappos[0] : 0                      # Region 0 default
    end
    @sprites["areamap"] = IconSprite.new(0, 0, @viewport)
    @sprites["areamap"].setBitmap("Graphics/Pictures/#{@mapdata[@region][1]}")
    @sprites["areamap"].x += (Graphics.width - @sprites["areamap"].bitmap.width) / 2
    @sprites["areamap"].y += (Graphics.height + 32 - @sprites["areamap"].bitmap.height) / 2
    Settings::REGION_MAP_EXTRAS.each do |hidden|
      next if hidden[0] != @region || hidden[1] <= 0 || !$game_switches[hidden[1]]
      pbDrawImagePositions(
        @sprites["areamap"].bitmap,
        [["Graphics/Pictures/#{hidden[4]}",
          hidden[2] * PokemonRegionMap_Scene::SQUARE_WIDTH,
          hidden[3] * PokemonRegionMap_Scene::SQUARE_HEIGHT]]
      )
    end
    @sprites["areahighlight"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["areaoverlay"] = IconSprite.new(0, 0, @viewport)
    @sprites["areaoverlay"].setBitmap("Graphics/Pictures/Pokedex/overlay_area")
    @sprites["formfront"] = PokemonSprite.new(@viewport)
    @sprites["formfront"].setOffset(PictureOrigin::CENTER)
    @sprites["formfront"].x = 130
    @sprites["formfront"].y = 158
    @sprites["formback"] = PokemonSprite.new(@viewport)
    @sprites["formback"].setOffset(PictureOrigin::BOTTOM)
    @sprites["formback"].x = 382   # y is set below as it depends on metrics
    @sprites["formicon"] = PokemonSpeciesIconSprite.new(nil, @viewport)
    @sprites["formicon"].setOffset(PictureOrigin::CENTER)
    @sprites["formicon"].x = 82
    @sprites["formicon"].y = 328
    @sprites["uparrow"] = AnimatedSprite.new("Graphics/Pictures/uparrow", 8, 28, 40, 2, @viewport)
    @sprites["uparrow"].x = 242
    @sprites["uparrow"].y = 268
    @sprites["uparrow"].play
    @sprites["uparrow"].visible = false
    @sprites["downarrow"] = AnimatedSprite.new("Graphics/Pictures/downarrow", 8, 28, 40, 2, @viewport)
    @sprites["downarrow"].x = 242
    @sprites["downarrow"].y = 348
    @sprites["downarrow"].play
    @sprites["downarrow"].visible = false
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    pbUpdateDummyPokemon
    @available = pbGetAvailableForms
    drawPage(@page)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbStartSceneBrief(species)  # For standalone access, shows first page only
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    dexnum = 0
    dexnumshift = false
    if $player.pokedex.unlocked?(-1)   # National Dex is unlocked
      species_data = GameData::Species.try_get(species)
      if species_data
        nationalDexList = [:NONE]
        GameData::Species.each_species { |s| nationalDexList.push(s.species) }
        dexnum = nationalDexList.index(species_data.species) || 0
        dexnumshift = true if dexnum > 0 && Settings::DEXES_WITH_OFFSETS.include?(-1)
      end
    else
      ($player.pokedex.dexes_count - 1).times do |i|   # Regional Dexes
        next if !$player.pokedex.unlocked?(i)
        num = pbGetRegionalNumber(i, species)
        next if num <= 0
        dexnum = num
        dexnumshift = true if Settings::DEXES_WITH_OFFSETS.include?(i)
        break
      end
    end
    @dexlist = [[species, "", 0, 0, dexnum, dexnumshift]]
    @index   = 0
    @page = 1
    @brief = true
    @typebitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Pokedex/icon_types"))
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["infosprite"] = PokemonSprite.new(@viewport)
    @sprites["infosprite"].setOffset(PictureOrigin::CENTER)
    @sprites["infosprite"].x = 104
    @sprites["infosprite"].y = 136
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    pbUpdateDummyPokemon
    drawPage(@page)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @typebitmap.dispose
    @viewport.dispose
  end

  def pbUpdate
    if @page == 2
      intensity = (Graphics.frame_count % 40) * 12
      intensity = 480 - intensity if intensity > 240
      @sprites["areahighlight"].opacity = intensity
    end
    pbUpdateSpriteHash(@sprites)
  end

  def pbUpdateDummyPokemon
    @species = @dexlist[@index][0]
    @gender, @form, _shiny = $player.pokedex.last_form_seen(@species)
    @shiny = false
    metrics_data = GameData::SpeciesMetrics.get_species_form(@species, @form)
    @sprites["infosprite"].setSpeciesBitmap(@species, @gender, @form, @shiny)
    @sprites["formfront"]&.setSpeciesBitmap(@species, @gender, @form, @shiny)
    if @sprites["formback"]
      @sprites["formback"].setSpeciesBitmap(@species, @gender, @form, @shiny, false, true)
      @sprites["formback"].y = 256
      @sprites["formback"].y += metrics_data.back_sprite[1] * 2
    end
    @sprites["formicon"]&.pbSetParams(@species, @gender, @form, @shiny)
  end

  def pbGetAvailableForms
    ret = []
    multiple_forms = false
    # Find all genders/forms of @species that have been seen
    GameData::Species.each do |sp|
      next if sp.species != @species
      next if sp.form != 0 && (!sp.real_form_name || sp.real_form_name.empty?)
      next if sp.pokedex_form != sp.form
      multiple_forms = true if sp.form > 0
      if sp.single_gendered?
        real_gender = (sp.gender_ratio == :AlwaysFemale) ? 1 : 0
        next if !$player.pokedex.seen_form?(@species, real_gender, sp.form) && !Settings::DEX_SHOWS_ALL_FORMS
        real_gender = 2 if sp.gender_ratio == :Genderless
        ret.push([sp.form_name, real_gender, sp.form])
      else   # Both male and female
        2.times do |real_gender|
          next if !$player.pokedex.seen_form?(@species, real_gender, sp.form) && !Settings::DEX_SHOWS_ALL_FORMS
          ret.push([sp.form_name, real_gender, sp.form])
          break if sp.form_name && !sp.form_name.empty?   # Only show 1 entry for each non-0 form
        end
      end
    end
    # Sort all entries
    ret.sort! { |a, b| (a[2] == b[2]) ? a[1] <=> b[1] : a[2] <=> b[2] }
    # Create form names for entries if they don't already exist
    ret.each do |entry|
      if !entry[0] || entry[0].empty?   # Necessarily applies only to form 0
        case entry[1]
        when 0 then entry[0] = _INTL("Male")
        when 1 then entry[0] = _INTL("Female")
        else
          entry[0] = (multiple_forms) ? _INTL("One Form") : _INTL("Genderless")
        end
      end
      entry[1] = 0 if entry[1] == 2   # Genderless entries are treated as male
    end
    return ret
  end

  def drawPage(page)
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    # Make certain sprites visible
    @sprites["infosprite"].visible    = (@page == 1)
    @sprites["areamap"].visible       = (@page == 2) if @sprites["areamap"]
    @sprites["areahighlight"].visible = (@page == 2) if @sprites["areahighlight"]
    @sprites["areaoverlay"].visible   = (@page == 2) if @sprites["areaoverlay"]
    @sprites["formfront"].visible     = (@page == 3) if @sprites["formfront"]
    @sprites["formback"].visible      = (@page == 3) if @sprites["formback"]
    @sprites["formicon"].visible      = (@page == 3) if @sprites["formicon"]
    # Draw page-specific information
    case page
    when 1 then drawPageInfo
    when 2 then drawPageArea
    when 3 then drawPageForms
    end
  end

  def drawPageInfo
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/bg_info"))
    overlay = @sprites["overlay"].bitmap
    base   = Color.new(88, 88, 80)
    shadow = Color.new(168, 184, 184)
    imagepos = []
    if @brief
      imagepos.push([_INTL("Graphics/Pictures/Pokedex/overlay_info"), 0, 0])
    end
    species_data = GameData::Species.get_species_form(@species, @form)
    # Write various bits of text
    indexText = "???"
    if @dexlist[@index][4] > 0
      indexNumber = @dexlist[@index][4]
      indexNumber -= 1 if @dexlist[@index][5]
      indexText = sprintf("%03d", indexNumber)
    end
    textpos = [
      [_INTL("{1}{2} {3}", indexText, " ", species_data.name),
       246, 48, 0, Color.new(248, 248, 248), Color.new(0, 0, 0)]
    ]
    if @show_battled_count
      textpos.push([_INTL("Number Battled"), 314, 164, 0, base, shadow])
      textpos.push([$player.pokedex.battled_count(@species).to_s, 452, 196, 1, base, shadow])
    else
      textpos.push([_INTL("Height"), 314, 164, 0, base, shadow])
      textpos.push([_INTL("Weight"), 314, 196, 0, base, shadow])
    end
    if $player.owned?(@species)
      # Write the category
      textpos.push([_INTL("{1} Pokémon", species_data.category), 246, 80, 0, base, shadow])
      # Write the height and weight
      if !@show_battled_count
        height = species_data.height
        weight = species_data.weight
        if System.user_language[3..4] == "US"   # If the user is in the United States
          inches = (height / 0.254).round
          pounds = (weight / 0.45359).round
          textpos.push([_ISPRINTF("{1:d}'{2:02d}\"", inches / 12, inches % 12), 460, 164, 1, base, shadow])
          textpos.push([_ISPRINTF("{1:4.1f} lbs.", pounds / 10.0), 494, 196, 1, base, shadow])
        else
          textpos.push([_ISPRINTF("{1:.1f} m", height / 10.0), 470, 164, 1, base, shadow])
          textpos.push([_ISPRINTF("{1:.1f} kg", weight / 10.0), 482, 196, 1, base, shadow])
        end
      end
      # Draw the Pokédex entry text
      drawTextEx(overlay, 40, 246, Graphics.width - (40 * 2), 4,   # overlay, x, y, width, num lines
                 species_data.pokedex_entry, base, shadow)
      # Draw the footprint
      footprintfile = GameData::Species.footprint_filename(@species, @form)
      if footprintfile
        footprint = RPG::Cache.load_bitmap("", footprintfile)
        overlay.blt(226, 138, footprint, footprint.rect)
        footprint.dispose
      end
      # Show the owned icon
      imagepos.push(["Graphics/Pictures/Pokedex/icon_own", 212, 44])
      # Draw the type icon(s)
      species_data.types.each_with_index do |type, i|
        type_number = GameData::Type.get(type).icon_position
        type_rect = Rect.new(0, type_number * 32, 96, 32)
        overlay.blt(296 + (100 * i), 120, @typebitmap.bitmap, type_rect)
      end
    else
      # Write the category
      textpos.push([_INTL("????? Pokémon"), 246, 80, 0, base, shadow])
      # Write the height and weight
      if !@show_battled_count
        if System.user_language[3..4] == "US"   # If the user is in the United States
          textpos.push([_INTL("???'??\""), 460, 164, 1, base, shadow])
          textpos.push([_INTL("????.? lbs."), 494, 196, 1, base, shadow])
        else
          textpos.push([_INTL("????.? m"), 470, 164, 1, base, shadow])
          textpos.push([_INTL("????.? kg"), 482, 196, 1, base, shadow])
        end
      end
    end
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
    # Draw all images
    pbDrawImagePositions(overlay, imagepos)
  end

  def pbFindEncounter(enc_types, species)
    return false if !enc_types
    enc_types.each_value do |slots|
      next if !slots
      slots.each { |slot| return true if GameData::Species.get(slot[1]).species == species }
    end
    return false
  end

  # Returns a 1D array of values corresponding to points on the Town Map. Each
  # value is true or false.
  def pbGetEncounterPoints
    # Determine all visible points on the Town Map (i.e. only ones with a
    # defined point in town_map.txt, and which either have no Self Switch
    # controlling their visibility or whose Self Switch is ON)
    visible_points = []
    @mapdata[@region][2].each do |loc|
      next if loc[7] && !$game_switches[loc[7]]   # Point is not visible
      visible_points.push([loc[0], loc[1]])
    end
    # Find all points with a visible area for @species
    town_map_width = 1 + PokemonRegionMap_Scene::RIGHT - PokemonRegionMap_Scene::LEFT
    ret = []
    GameData::Encounter.each_of_version($PokemonGlobal.encounter_version) do |enc_data|
      next if !pbFindEncounter(enc_data.types, @species)   # Species isn't in encounter table
      # Get the map belonging to the encounter table
      map_metadata = GameData::MapMetadata.try_get(enc_data.map)
      next if !map_metadata || map_metadata.has_flag?("HideEncountersInPokedex")
      mappos = map_metadata.town_map_position
      next if mappos[0] != @region   # Map isn't in the region being shown
      # Get the size and shape of the map in the Town Map
      map_size = map_metadata.town_map_size
      map_width = 1
      map_height = 1
      map_shape = "1"
      if map_size && map_size[0] && map_size[0] > 0   # Map occupies multiple points
        map_width = map_size[0]
        map_shape = map_size[1]
        map_height = (map_shape.length.to_f / map_width).ceil
      end
      # Mark each visible point covered by the map as containing the area
      map_width.times do |i|
        map_height.times do |j|
          next if map_shape[i + (j * map_width), 1].to_i == 0   # Point isn't part of map
          next if !visible_points.include?([mappos[1] + i, mappos[2] + j])   # Point isn't visible
          ret[mappos[1] + i + ((mappos[2] + j) * town_map_width)] = true
        end
      end
    end
    return ret
  end

  def drawPageArea
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/bg_area"))
    overlay = @sprites["overlay"].bitmap
    base   = Color.new(88, 88, 80)
    shadow = Color.new(168, 184, 184)
    @sprites["areahighlight"].bitmap.clear
    # Get all points to be shown as places where @species can be encountered
    points = pbGetEncounterPoints
    # Draw coloured squares on each point of the Town Map with a nest
    pointcolor   = Color.new(0, 248, 248)
    pointcolorhl = Color.new(192, 248, 248)
    town_map_width = 1 + PokemonRegionMap_Scene::RIGHT - PokemonRegionMap_Scene::LEFT
    sqwidth = PokemonRegionMap_Scene::SQUARE_WIDTH
    sqheight = PokemonRegionMap_Scene::SQUARE_HEIGHT
    points.length.times do |j|
      next if !points[j]
      x = (j % town_map_width) * sqwidth
      x += (Graphics.width - @sprites["areamap"].bitmap.width) / 2
      y = (j / town_map_width) * sqheight
      y += (Graphics.height + 32 - @sprites["areamap"].bitmap.height) / 2
      @sprites["areahighlight"].bitmap.fill_rect(x, y, sqwidth, sqheight, pointcolor)
      if j - town_map_width < 0 || !points[j - town_map_width]
        @sprites["areahighlight"].bitmap.fill_rect(x, y - 2, sqwidth, 2, pointcolorhl)
      end
      if j + town_map_width >= points.length || !points[j + town_map_width]
        @sprites["areahighlight"].bitmap.fill_rect(x, y + sqheight, sqwidth, 2, pointcolorhl)
      end
      if j % town_map_width == 0 || !points[j - 1]
        @sprites["areahighlight"].bitmap.fill_rect(x - 2, y, 2, sqheight, pointcolorhl)
      end
      if (j + 1) % town_map_width == 0 || !points[j + 1]
        @sprites["areahighlight"].bitmap.fill_rect(x + sqwidth, y, 2, sqheight, pointcolorhl)
      end
    end
    # Set the text
    textpos = []
    if points.length == 0
      pbDrawImagePositions(
        overlay,
        [[sprintf("Graphics/Pictures/Pokedex/overlay_areanone"), 108, 188]]
      )
      textpos.push([_INTL("Area unknown"), Graphics.width / 2, (Graphics.height / 2) + 6, 2, base, shadow])
    end
    textpos.push([pbGetMessage(MessageTypes::RegionNames, @region), 414, 50, 2, base, shadow])
    textpos.push([_INTL("{1}'s area", GameData::Species.get(@species).name),
                  Graphics.width / 2, 358, 2, base, shadow])
    pbDrawTextPositions(overlay, textpos)
  end

  def drawPageForms
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/bg_forms"))
    overlay = @sprites["overlay"].bitmap
    base   = Color.new(88, 88, 80)
    shadow = Color.new(168, 184, 184)
    # Write species and form name
    formname = ""
    @available.each do |i|
      if i[1] == @gender && i[2] == @form
        formname = i[0]
        break
      end
    end
    textpos = [
      [GameData::Species.get(@species).name, Graphics.width / 2, Graphics.height - 82, 2, base, shadow],
      [formname, Graphics.width / 2, Graphics.height - 50, 2, base, shadow]
    ]
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
  end

  def pbGoToPrevious
    newindex = @index
    while newindex > 0
      newindex -= 1
      if $player.seen?(@dexlist[newindex][0])
        @index = newindex
        break
      end
    end
  end

  def pbGoToNext
    newindex = @index
    while newindex < @dexlist.length - 1
      newindex += 1
      if $player.seen?(@dexlist[newindex][0])
        @index = newindex
        break
      end
    end
  end

  def pbChooseForm
    index = 0
    @available.length.times do |i|
      if @available[i][1] == @gender && @available[i][2] == @form
        index = i
        break
      end
    end
    oldindex = -1
    loop do
      if oldindex != index
        $player.pokedex.set_last_form_seen(@species, @available[index][1], @available[index][2])
        pbUpdateDummyPokemon
        drawPage(@page)
        @sprites["uparrow"].visible   = (index > 0)
        @sprites["downarrow"].visible = (index < @available.length - 1)
        oldindex = index
      end
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::UP)
        pbPlayCursorSE
        index = (index + @available.length - 1) % @available.length
      elsif Input.trigger?(Input::DOWN)
        pbPlayCursorSE
        index = (index + 1) % @available.length
      elsif Input.trigger?(Input::BACK)
        pbPlayCancelSE
        break
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        break
      end
    end
    @sprites["uparrow"].visible   = false
    @sprites["downarrow"].visible = false
  end

  def pbScene
    Pokemon.play_cry(@species, @form)
    loop do
      Graphics.update
      Input.update
      pbUpdate
      dorefresh = false
      if Input.trigger?(Input::ACTION)
        pbSEStop
        Pokemon.play_cry(@species, @form) if @page == 1
      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::USE)
        case @page
        when 1   # Info
          @show_battled_count = !@show_battled_count
          dorefresh = true
        when 2   # Area
#          dorefresh = true
        when 3   # Forms
          if @available.length > 1
            pbPlayDecisionSE
            pbChooseForm
            dorefresh = true
          end
        end
      elsif Input.trigger?(Input::UP)
        oldindex = @index
        pbGoToPrevious
        if @index != oldindex
          pbUpdateDummyPokemon
          @available = pbGetAvailableForms
          pbSEStop
          (@page == 1) ? Pokemon.play_cry(@species, @form) : pbPlayCursorSE
          dorefresh = true
        end
      elsif Input.trigger?(Input::DOWN)
        oldindex = @index
        pbGoToNext
        if @index != oldindex
          pbUpdateDummyPokemon
          @available = pbGetAvailableForms
          pbSEStop
          (@page == 1) ? Pokemon.play_cry(@species, @form) : pbPlayCursorSE
          dorefresh = true
        end
      elsif Input.trigger?(Input::LEFT)
        oldpage = @page
        @page -= 1
        @page = 1 if @page < 1
        @page = 3 if @page > 3
        if @page != oldpage
          pbPlayCursorSE
          dorefresh = true
        end
      elsif Input.trigger?(Input::RIGHT)
        oldpage = @page
        @page += 1
        @page = 1 if @page < 1
        @page = 3 if @page > 3
        if @page != oldpage
          pbPlayCursorSE
          dorefresh = true
        end
      end
      if dorefresh
        drawPage(@page)
      end
    end
    return @index
  end

  def pbSceneBrief
    Pokemon.play_cry(@species, @form)
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::ACTION)
        pbSEStop
        Pokemon.play_cry(@species, @form)
      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        break
      end
    end
  end
end

#===============================================================================
#
#===============================================================================
class PokemonPokedexInfoScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen(dexlist, index, region)
    @scene.pbStartScene(dexlist, index, region)
    ret = @scene.pbScene
    @scene.pbEndScene
    return ret   # Index of last species viewed in dexlist
  end

  def pbStartSceneSingle(species)   # For use from a Pokémon's summary screen
    region = -1
    if Settings::USE_CURRENT_REGION_DEX
      region = pbGetCurrentRegion
      region = -1 if region >= $player.pokedex.dexes_count - 1
    else
      region = $PokemonGlobal.pokedexDex   # National Dex -1, regional Dexes 0, 1, etc.
    end
    dexnum = pbGetRegionalNumber(region, species)
    dexnumshift = Settings::DEXES_WITH_OFFSETS.include?(region)
    dexlist = [[species, GameData::Species.get(species).name, 0, 0, dexnum, dexnumshift]]
    @scene.pbStartScene(dexlist, 0, region)
    @scene.pbScene
    @scene.pbEndScene
  end

  def pbDexEntry(species)   # For use when capturing a new species
    @scene.pbStartSceneBrief(species)
    @scene.pbSceneBrief
    @scene.pbEndScene
  end
end
