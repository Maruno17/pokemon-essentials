#===============================================================================
#
#===============================================================================
def findBottom(bitmap)
  return 0 if !bitmap
  for i in 1..bitmap.height
    for j in 0..bitmap.width - 1
      return bitmap.height - i if bitmap.get_pixel(j, bitmap.height - i).alpha > 0
    end
  end
  return 0
end

def pbAutoPositionAll
  GameData::Species.each do |sp|
    Graphics.update if sp.id_number % 50 == 0
    bitmap1 = GameData::Species.sprite_bitmap(sp.species, sp.form, nil, nil, nil, true)
    bitmap2 = GameData::Species.sprite_bitmap(sp.species, sp.form)
    if bitmap1 && bitmap1.bitmap   # Player's y
      sp.back_sprite_x = 0
      sp.back_sprite_y = (bitmap1.height - (findBottom(bitmap1.bitmap) + 1)) / 2
    end
    if bitmap2 && bitmap2.bitmap   # Foe's y
      sp.front_sprite_x = 0
      sp.front_sprite_y = (bitmap2.height - (findBottom(bitmap2.bitmap) + 1)) / 2
      sp.front_sprite_y += 4   # Just because
    end
    sp.front_sprite_altitude = 0   # Shouldn't be used
    sp.shadow_x              = 0
    sp.shadow_size           = 2
    bitmap1.dispose if bitmap1
    bitmap2.dispose if bitmap2
  end
  GameData::Species.save
  Compiler.write_pokemon
  Compiler.write_pokemon_forms
end

#===============================================================================
#
#===============================================================================
class SpritePositioner
  def pbOpen
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    battlebg   = "Graphics/Battlebacks/indoor1_bg"
    playerbase = "Graphics/Battlebacks/indoor1_base0"
    enemybase  = "Graphics/Battlebacks/indoor1_base1"
    @sprites["battle_bg"] = AnimatedPlane.new(@viewport)
    @sprites["battle_bg"].setBitmap(battlebg)
    @sprites["battle_bg"].z = 0
    baseX, baseY = PokeBattle_SceneConstants.pbBattlerPosition(0)
    @sprites["base_0"] = IconSprite.new(baseX, baseY, @viewport)
    @sprites["base_0"].setBitmap(playerbase)
    @sprites["base_0"].x -= @sprites["base_0"].bitmap.width / 2 if @sprites["base_0"].bitmap
    @sprites["base_0"].y -= @sprites["base_0"].bitmap.height if @sprites["base_0"].bitmap
    @sprites["base_0"].z = 1
    baseX, baseY = PokeBattle_SceneConstants.pbBattlerPosition(1)
    @sprites["base_1"] = IconSprite.new(baseX, baseY, @viewport)
    @sprites["base_1"].setBitmap(enemybase)
    @sprites["base_1"].x -= @sprites["base_1"].bitmap.width / 2 if @sprites["base_1"].bitmap
    @sprites["base_1"].y -= @sprites["base_1"].bitmap.height / 2 if @sprites["base_1"].bitmap
    @sprites["base_1"].z = 1
    @sprites["messageBox"] = IconSprite.new(0, Graphics.height - 96, @viewport)
    @sprites["messageBox"].setBitmap("Graphics/Pictures/Battle/debug_message")
    @sprites["messageBox"].z = 2
    @sprites["shadow_1"] = IconSprite.new(0, 0, @viewport)
    @sprites["shadow_1"].z = 3
    @sprites["pokemon_0"] = PokemonSprite.new(@viewport)
    @sprites["pokemon_0"].setOffset(PictureOrigin::Bottom)
    @sprites["pokemon_0"].z = 4
    @sprites["pokemon_1"] = PokemonSprite.new(@viewport)
    @sprites["pokemon_1"].setOffset(PictureOrigin::Bottom)
    @sprites["pokemon_1"].z = 4
    @sprites["info"] = Window_UnformattedTextPokemon.new("")
    @sprites["info"].viewport = @viewport
    @sprites["info"].visible  = false
    @oldSpeciesIndex = 0
    @species = nil   # This can be a species_form
    @metricsChanged = false
    refresh
    @starting = true
  end

  def pbClose
    if @metricsChanged && pbConfirmMessage(_INTL("Some metrics have been edited. Save changes?"))
      pbSaveMetrics
      @metricsChanged = false
    else
      GameData::Species.load   # Clear all changes to metrics
    end
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbSaveMetrics
    GameData::Species.save
    Compiler.write_pokemon
    Compiler.write_pokemon_forms
  end

  def update
    pbUpdateSpriteHash(@sprites)
  end

  def refresh
    if !@species
      @sprites["pokemon_0"].visible = false
      @sprites["pokemon_1"].visible = false
      @sprites["shadow_1"].visible = false
      return
    end
    species_data = GameData::Species.get(@species)
    for i in 0...2
      pos = PokeBattle_SceneConstants.pbBattlerPosition(i, 1)
      @sprites["pokemon_#{i}"].x = pos[0]
      @sprites["pokemon_#{i}"].y = pos[1]
      species_data.apply_metrics_to_sprite(@sprites["pokemon_#{i}"], i)
      @sprites["pokemon_#{i}"].visible = true
      if i == 1
        @sprites["shadow_1"].x = pos[0]
        @sprites["shadow_1"].y = pos[1]
        if @sprites["shadow_1"].bitmap
          @sprites["shadow_1"].x -= @sprites["shadow_1"].bitmap.width / 2
          @sprites["shadow_1"].y -= @sprites["shadow_1"].bitmap.height / 2
        end
        species_data.apply_metrics_to_sprite(@sprites["shadow_1"], i, true)
        @sprites["shadow_1"].visible = true
      end
    end
  end

  def pbAutoPosition
    species_data = GameData::Species.get(@species)
    old_back_y         = species_data.back_sprite_y
    old_front_y        = species_data.front_sprite_y
    old_front_altitude = species_data.front_sprite_altitude
    bitmap1 = @sprites["pokemon_0"].bitmap
    bitmap2 = @sprites["pokemon_1"].bitmap
    new_back_y  = (bitmap1.height - (findBottom(bitmap1) + 1)) / 2
    new_front_y = (bitmap2.height - (findBottom(bitmap2) + 1)) / 2
    new_front_y += 4   # Just because
    if new_back_y != old_back_y || new_front_y != old_front_y || old_front_altitude != 0
      species_data.back_sprite_y         = new_back_y
      species_data.front_sprite_y        = new_front_y
      species_data.front_sprite_altitude = 0
      @metricsChanged = true
      refresh
    end
  end

  def pbChangeSpecies(species)
    @species = species
    species_data = GameData::Species.try_get(@species)
    return if !species_data
    spe = species_data.species
    frm = species_data.form
    @sprites["pokemon_0"].setSpeciesBitmap(spe, 0, frm, false, false, true)
    @sprites["pokemon_1"].setSpeciesBitmap(spe, 0, frm)
    @sprites["shadow_1"].setBitmap(GameData::Species.shadow_filename(spe, frm))
  end

  def pbShadowSize
    pbChangeSpecies(@species)
    refresh
    species_data = GameData::Species.get(@species)
    if pbResolveBitmap(sprintf("Graphics/Pokemon/Shadow/%s_%d", species_data.species, species_data.form)) ||
       pbResolveBitmap(sprintf("Graphics/Pokemon/Shadow/%s", species_data.species))
      pbMessage("This species has its own shadow sprite in Graphics/Pokemon/Shadow/. The shadow size metric cannot be edited.")
      return false
    end
    oldval = species_data.shadow_size
    cmdvals = [0]
    commands = [_INTL("None")]
    defindex = 0
    i = 0
    loop do
      i += 1
      fn = sprintf("Graphics/Pokemon/Shadow/%d", i)
      break if !pbResolveBitmap(fn)
      cmdvals.push(i)
      commands.push(i.to_s)
      defindex = cmdvals.length - 1 if oldval == i
    end
    cw = Window_CommandPokemon.new(commands)
    cw.index    = defindex
    cw.viewport = @viewport
    ret = false
    oldindex = cw.index
    loop do
      Graphics.update
      Input.update
      cw.update
      self.update
      if cw.index != oldindex
        oldindex = cw.index
        species_data.shadow_size = cmdvals[cw.index]
        pbChangeSpecies(@species)
        refresh
      end
      if Input.trigger?(Input::ACTION)   # Cycle to next option
        pbPlayDecisionSE
        @metricsChanged = true if species_data.shadow_size != oldval
        ret = true
        break
      elsif Input.trigger?(Input::BACK)
        species_data.shadow_size = oldval
        pbPlayCancelSE
        break
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        break
      end
    end
    cw.dispose
    return ret
  end

  def pbSetParameter(param)
    return if !@species
    return pbShadowSize if param == 2
    if param == 4
      pbAutoPosition
      return false
    end
    species_data = GameData::Species.get(@species)
    case param
    when 0
      sprite = @sprites["pokemon_0"]
      xpos = species_data.back_sprite_x
      ypos = species_data.back_sprite_y
    when 1
      sprite = @sprites["pokemon_1"]
      xpos = species_data.front_sprite_x
      ypos = species_data.front_sprite_y
    when 3
      sprite = @sprites["shadow_1"]
      xpos = species_data.shadow_x
      ypos = 0
    end
    oldxpos = xpos
    oldypos = ypos
    @sprites["info"].visible = true
    ret = false
    loop do
      sprite.visible = (Graphics.frame_count % 16) < 12   # Flash the selected sprite
      Graphics.update
      Input.update
      self.update
      case param
      when 0 then @sprites["info"].setTextToFit("Ally Position = #{xpos},#{ypos}")
      when 1 then @sprites["info"].setTextToFit("Enemy Position = #{xpos},#{ypos}")
      when 3 then @sprites["info"].setTextToFit("Shadow Position = #{xpos}")
      end
      if (Input.repeat?(Input::UP) || Input.repeat?(Input::DOWN)) && param != 3
        ypos += (Input.repeat?(Input::DOWN)) ? 1 : -1
        case param
        when 0 then species_data.back_sprite_y  = ypos
        when 1 then species_data.front_sprite_y = ypos
        end
        refresh
      end
      if Input.repeat?(Input::LEFT) || Input.repeat?(Input::RIGHT)
        xpos += (Input.repeat?(Input::RIGHT)) ? 1 : -1
        case param
        when 0 then species_data.back_sprite_x  = xpos
        when 1 then species_data.front_sprite_x = xpos
        when 3 then species_data.shadow_x       = xpos
        end
        refresh
      end
      if Input.repeat?(Input::ACTION) && param != 3   # Cycle to next option
        @metricsChanged = true if xpos != oldxpos || ypos != oldypos
        ret = true
        pbPlayDecisionSE
        break
      elsif Input.repeat?(Input::BACK)
        case param
        when 0
          species_data.back_sprite_x = oldxpos
          species_data.back_sprite_y = oldypos
        when 1
          species_data.front_sprite_x = oldxpos
          species_data.front_sprite_y = oldypos
        when 3
          species_data.shadow_x = oldxpos
        end
        pbPlayCancelSE
        refresh
        break
      elsif Input.repeat?(Input::USE)
        @metricsChanged = true if xpos != oldxpos || (param != 3 && ypos != oldypos)
        pbPlayDecisionSE
        break
      end
    end
    @sprites["info"].visible = false
    sprite.visible = true
    return ret
  end

  def pbMenu(species)
    pbChangeSpecies(species)
    refresh
    cw = Window_CommandPokemon.new([
       _INTL("Set Ally Position"),
       _INTL("Set Enemy Position"),
       _INTL("Set Shadow Size"),
       _INTL("Set Shadow Position"),
       _INTL("Auto-Position Sprites")
    ])
    cw.x        = Graphics.width - cw.width
    cw.y        = Graphics.height - cw.height
    cw.viewport = @viewport
    ret = -1
    loop do
      Graphics.update
      Input.update
      cw.update
      self.update
      if Input.trigger?(Input::USE)
        pbPlayDecisionSE
        ret = cw.index
        break
      elsif Input.trigger?(Input::BACK)
        pbPlayCancelSE
        break
      end
    end
    cw.dispose
    return ret
  end

  def pbChooseSpecies
    if @starting
      pbFadeInAndShow(@sprites) { update }
      @starting = false
    end
    cw = Window_CommandPokemonEx.newEmpty(0, 0, 260, 32 + 24 * 6, @viewport)
    cw.rowHeight = 24
    pbSetSmallFont(cw.contents)
    cw.x = Graphics.width - cw.width
    cw.y = Graphics.height - cw.height
    allspecies = []
    GameData::Species.each do |sp|
      name = (sp.form == 0) ? sp.name : _INTL("{1} (form {2})", sp.real_name, sp.form)
      allspecies.push([sp.id, sp.species, name]) if name && !name.empty?
    end
    allspecies.sort! { |a, b| a[2] <=> b[2] }
    commands = []
    allspecies.each { |sp| commands.push(sp[2]) }
    cw.commands = commands
    cw.index    = @oldSpeciesIndex
    ret = nil
    oldindex = -1
    loop do
      Graphics.update
      Input.update
      cw.update
      if cw.index != oldindex
        oldindex = cw.index
        pbChangeSpecies(allspecies[cw.index][0])
        refresh
      end
      self.update
      if Input.trigger?(Input::BACK)
        pbChangeSpecies(nil)
        refresh
        break
      elsif Input.trigger?(Input::USE)
        pbChangeSpecies(allspecies[cw.index][0])
        ret = allspecies[cw.index][0]
        break
      end
    end
    @oldSpeciesIndex = cw.index
    cw.dispose
    return ret
  end
end

#===============================================================================
#
#===============================================================================
class SpritePositionerScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStart
    @scene.pbOpen
    loop do
      species = @scene.pbChooseSpecies
      break if !species
      loop do
        command = @scene.pbMenu(species)
        break if command < 0
        loop do
          par = @scene.pbSetParameter(command)
          break if !par
          command = (command + 1) % 3
        end
      end
    end
    @scene.pbClose
  end
end
