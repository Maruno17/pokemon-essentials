#===============================================================================
#
#===============================================================================
def findBottom(bitmap)
  return 0 if !bitmap
  for i in 1..bitmap.height
    for j in 0..bitmap.width-1
      return bitmap.height-i if bitmap.get_pixel(j,bitmap.height-i).alpha>0
    end
  end
  return 0
end

def pbAutoPositionAll
  metrics = pbLoadSpeciesMetrics
  for i in 1..PBSpecies.maxValueF
    s = pbGetSpeciesFromFSpecies(i)
    Graphics.update if i%50==0
    bitmap1 = pbLoadSpeciesBitmap(s[0],false,s[1],false,false,true)
    bitmap2 = pbLoadSpeciesBitmap(s[0],false,s[1])
    metrics[MetricBattlerPlayerX][i]    = 0   # Player's x
    if bitmap1 && bitmap1.bitmap   # Player's y
      metrics[MetricBattlerPlayerY][i]  = (bitmap1.height-(findBottom(bitmap1.bitmap)+1))/2
    end
    metrics[MetricBattlerEnemyX][i]     = 0   # Foe's x
    if bitmap2 && bitmap2.bitmap   # Foe's y
      metrics[MetricBattlerEnemyY][i]   = (bitmap2.height-(findBottom(bitmap2.bitmap)+1))/2
      metrics[MetricBattlerEnemyY][i]   += 4   # Just because
    end
    metrics[MetricBattlerAltitude][i]   = 0   # Foe's altitude, not used now
    metrics[MetricBattlerShadowX][i]    = 0   # Shadow's x
    metrics[MetricBattlerShadowSize][i] = 2   # Shadow size
    bitmap1.dispose if bitmap1
    bitmap2.dispose if bitmap2
  end
  save_data(metrics,"Data/species_metrics.dat")
  $PokemonTemp.speciesMetrics = nil
  pbSavePokemonData
  pbSavePokemonFormsData
end



#===============================================================================
#
#===============================================================================
class SpritePositioner
  def pbOpen
    @sprites = {}
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    battlebg   = "Graphics/Battlebacks/indoor1_bg"
    playerbase = "Graphics/Battlebacks/indoor1_base0"
    enemybase  = "Graphics/Battlebacks/indoor1_base1"
    @sprites["battle_bg"] = AnimatedPlane.new(@viewport)
    @sprites["battle_bg"].setBitmap(battlebg)
    @sprites["battle_bg"].z = 0
    baseX, baseY = PokeBattle_SceneConstants.pbBattlerPosition(0)
    @sprites["base_0"] = IconSprite.new(baseX,baseY,@viewport)
    @sprites["base_0"].setBitmap(playerbase)
    @sprites["base_0"].x -= @sprites["base_0"].bitmap.width/2 if @sprites["base_0"].bitmap
    @sprites["base_0"].y -= @sprites["base_0"].bitmap.height if @sprites["base_0"].bitmap
    @sprites["base_0"].z = 1
    baseX, baseY = PokeBattle_SceneConstants.pbBattlerPosition(1)
    @sprites["base_1"] = IconSprite.new(baseX,baseY,@viewport)
    @sprites["base_1"].setBitmap(enemybase)
    @sprites["base_1"].x -= @sprites["base_1"].bitmap.width/2 if @sprites["base_1"].bitmap
    @sprites["base_1"].y -= @sprites["base_1"].bitmap.height/2 if @sprites["base_1"].bitmap
    @sprites["base_1"].z = 1
    @sprites["messageBox"] = IconSprite.new(0,Graphics.height-96,@viewport)
    @sprites["messageBox"].setBitmap("Graphics/Pictures/Battle/debug_message")
    @sprites["messageBox"].z = 2
    @sprites["shadow_1"] = IconSprite.new(0,0,@viewport)
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
    @species = 0
    @metrics = pbLoadSpeciesMetrics
    @metricsChanged = false
    refresh
    @starting = true
  end

  def pbClose
    if @metricsChanged
      if pbConfirmMessage(_INTL("Some metrics have been edited. Save changes?"))
        pbSaveMetrics
        @metricsChanged = false
      end
    end
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbSaveMetrics
    save_data(@metrics,"Data/species_metrics.dat")
    $PokemonTemp.speciesMetrics = nil
    pbSavePokemonData
    pbSavePokemonFormsData
  end

  def update
    pbUpdateSpriteHash(@sprites)
  end

  def refresh
    if @species<=0
      @sprites["pokemon_0"].visible = false
      @sprites["pokemon_1"].visible = false
      @sprites["shadow_1"].visible = false
      return
    end
    for i in 0...2
      pos = PokeBattle_SceneConstants.pbBattlerPosition(i,1)
      @sprites["pokemon_#{i}"].x = pos[0]
      @sprites["pokemon_#{i}"].y = pos[1]
      pbApplyBattlerMetricsToSprite(@sprites["pokemon_#{i}"],i,@species,false,@metrics)
      @sprites["pokemon_#{i}"].visible = true
      if i==1
        @sprites["shadow_1"].x = pos[0]
        @sprites["shadow_1"].y = pos[1]
        if @sprites["shadow_1"].bitmap
          @sprites["shadow_1"].x -= @sprites["shadow_1"].bitmap.width/2
          @sprites["shadow_1"].y -= @sprites["shadow_1"].bitmap.height/2
        end
        pbApplyBattlerMetricsToSprite(@sprites["shadow_1"],i,@species,true,@metrics)
        @sprites["shadow_1"].visible = true
      end
    end
  end

  def pbAutoPosition
    oldmetric1 = (@metrics[MetricBattlerPlayerY][@species] || 0)
    oldmetric3 = (@metrics[MetricBattlerEnemyY][@species] || 0)
    oldmetric4 = (@metrics[MetricBattlerAltitude][@species] || 0)
    bitmap1 = @sprites["pokemon_0"].bitmap
    bitmap2 = @sprites["pokemon_1"].bitmap
    newmetric1 = (bitmap1.height-(findBottom(bitmap1)+1))/2
    newmetric3 = (bitmap2.height-(findBottom(bitmap2)+1))/2
    newmetric3 += 4   # Just because
    if newmetric1!=oldmetric1 || newmetric3!=oldmetric3 || oldmetric4!=0
      @metrics[MetricBattlerPlayerY][@species]  = newmetric1
      @metrics[MetricBattlerEnemyY][@species]   = newmetric3
      @metrics[MetricBattlerAltitude][@species] = 0
      @metricsChanged = true
      refresh
    end
  end

  def pbChangeSpecies(species)
    @species = species
    spe,frm = pbGetSpeciesFromFSpecies(@species)
    @sprites["pokemon_0"].setSpeciesBitmap(spe,false,frm,false,false,true)
    @sprites["pokemon_1"].setSpeciesBitmap(spe,false,frm,false,false,false)
    @sprites["shadow_1"].setBitmap(pbCheckPokemonShadowBitmapFiles(spe,frm,@metrics))
  end

  def pbShadowSize
    pbChangeSpecies(@species)
    refresh
    oldval = (@metrics[MetricBattlerShadowSize][@species] || 2)
    cmdvals = [0]; commands = [_INTL("None")]
    defindex = 0
    i = 0
    loop do
      i += 1
      fn = sprintf("Graphics/Pictures/Battle/battler_shadow_%d",i)
      break if !pbResolveBitmap(fn)
      cmdvals.push(i); commands.push(i.to_s)
      defindex = cmdvals.length-1 if oldval==i
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
      if cw.index!=oldindex
        oldindex = cw.index
        @metrics[MetricBattlerShadowSize][@species] = cmdvals[cw.index]
        pbChangeSpecies(@species)
        refresh
      end
      if Input.trigger?(Input::A)   # Cycle to next option
        pbPlayDecisionSE
        @metricsChanged = true if @metrics[MetricBattlerShadowSize][@species]!=oldval
        ret = true
        break
      elsif Input.trigger?(Input::B)
        @metrics[MetricBattlerShadowSize][@species] = oldval
        pbPlayCancelSE
        break
      elsif Input.trigger?(Input::C)
        pbPlayDecisionSE
        break
      end
    end
    cw.dispose
    return ret
  end

  def pbSetParameter(param)
    return if @species<=0
    if param==2
      return pbShadowSize
    elsif param==4
      pbAutoPosition
      return false
    end
    case param
    when 0
      sprite = @sprites["pokemon_0"]
      xpos = (@metrics[MetricBattlerPlayerX][@species] || 0)
      ypos = (@metrics[MetricBattlerPlayerY][@species] || 0)
    when 1
      sprite = @sprites["pokemon_1"]
      xpos = (@metrics[MetricBattlerEnemyX][@species] || 0)
      ypos = (@metrics[MetricBattlerEnemyY][@species] || 0)
    when 3
      sprite = @sprites["shadow_1"]
      xpos = (@metrics[MetricBattlerShadowX][@species] || 0)
      ypos = 0
    end
    oldxpos = xpos
    oldypos = ypos
    @sprites["info"].visible = true
    ret = false
    loop do
      sprite.visible = (Graphics.frame_count%16)<12
      Graphics.update
      Input.update
      self.update
      case param
      when 0; @sprites["info"].setTextToFit("Ally Position = #{xpos},#{ypos}")
      when 1; @sprites["info"].setTextToFit("Enemy Position = #{xpos},#{ypos}")
      when 3; @sprites["info"].setTextToFit("Shadow Position = #{xpos}")
      end
      if Input.repeat?(Input::UP) && param!=3
        ypos -= 1
        case param
        when 0; @metrics[MetricBattlerPlayerY][@species] = ypos
        when 1; @metrics[MetricBattlerEnemyY][@species]  = ypos
        end
        refresh
      elsif Input.repeat?(Input::DOWN) && param!=3
        ypos += 1
        case param
        when 0; @metrics[MetricBattlerPlayerY][@species] = ypos
        when 1; @metrics[MetricBattlerEnemyY][@species]  = ypos
        end
        refresh
      end
      if Input.repeat?(Input::LEFT)
        xpos -= 1
        case param
        when 0; @metrics[MetricBattlerPlayerX][@species] = xpos
        when 1; @metrics[MetricBattlerEnemyX][@species]  = xpos
        when 3; @metrics[MetricBattlerShadowX][@species] = xpos
        end
        refresh
      elsif Input.repeat?(Input::RIGHT)
        xpos += 1
        case param
        when 0; @metrics[MetricBattlerPlayerX][@species] = xpos
        when 1; @metrics[MetricBattlerEnemyX][@species]  = xpos
        when 3; @metrics[MetricBattlerShadowX][@species] = xpos
        end
        refresh
      end
      if Input.repeat?(Input::A) && param!=3   # Cycle to next option
        @metricsChanged = true if xpos!=oldxpos || ypos!=oldypos
        ret = true
        pbPlayDecisionSE
        break
      elsif Input.repeat?(Input::B)
        case param
        when 0
          @metrics[MetricBattlerPlayerX][@species] = oldxpos
          @metrics[MetricBattlerPlayerY][@species] = oldypos
        when 1
          @metrics[MetricBattlerEnemyX][@species] = oldxpos
          @metrics[MetricBattlerEnemyY][@species] = oldypos
        when 3
          @metrics[MetricBattlerShadowX][@species] = oldxpos
        end
        pbPlayCancelSE
        refresh
        break
      elsif Input.repeat?(Input::C)
        @metricsChanged = true if xpos!=oldxpos || (param!=3 && ypos!=oldypos)
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
    cw.x        = Graphics.width-cw.width
    cw.y        = Graphics.height-cw.height
    cw.viewport = @viewport
    ret = -1
    loop do
      Graphics.update
      Input.update
      cw.update
      self.update
      if Input.trigger?(Input::C)
        pbPlayDecisionSE
        ret = cw.index
        break
      elsif Input.trigger?(Input::B)
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
    cw = Window_CommandPokemonEx.newEmpty(0,0,260,32+24*6,@viewport)
    cw.rowHeight = 24
    pbSetSmallFont(cw.contents)
    cw.x = Graphics.width-cw.width
    cw.y = Graphics.height-cw.height
    allspecies = []
    commands = []
    for i in 1..PBSpecies.maxValueF
      s = pbGetSpeciesFromFSpecies(i)
      name = PBSpecies.getName(s[0])
      name = _INTL("{1} (form {2})",name,s[1]) if s[1]>0
      allspecies.push([i,s[0],name]) if name!=""
    end
    allspecies.sort! { |a,b| a[1]==b[1] ? a[0]<=>b[0] : a[2]<=>b[2] }
    for s in allspecies
      commands.push(_INTL("{1} - {2}",s[1],s[2]))
    end
    cw.commands = commands
    cw.index    = @oldSpeciesIndex
    species = 0
    oldindex = -1
    loop do
      Graphics.update
      Input.update
      cw.update
      if cw.index!=oldindex
        oldindex = cw.index
        pbChangeSpecies(allspecies[cw.index][0])
        refresh
      end
      self.update
      if Input.trigger?(Input::B)
        pbChangeSpecies(0)
        refresh
        break
      elsif Input.trigger?(Input::C)
        pbChangeSpecies(allspecies[cw.index][0])
        species = allspecies[cw.index][0]
        break
      end
    end
    @oldSpeciesIndex = cw.index
    cw.dispose
    return species
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
      break if species<=0
      loop do
        command = @scene.pbMenu(species)
        break if command<0
        loop do
          par = @scene.pbSetParameter(command)
          break if !par
          command = (command+1)%3
        end
      end
    end
    @scene.pbClose
  end
end
