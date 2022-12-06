class PBFusion
  Unknown = 0 # Do not use
  Happiness = 1
  HappinessDay = 2
  HappinessNight = 3
  Level = 4
  Trade = 5
  TradeItem = 6
  Item = 7
  AttackGreater = 8
  AtkDefEqual = 9
  DefenseGreater = 10
  Silcoon = 11
  Cascoon = 12
  Ninjask = 13
  Shedinja = 14
  Beauty = 15
  ItemMale = 16
  ItemFemale = 17
  DayHoldItem = 18
  NightHoldItem = 19
  HasMove = 20
  HasInParty = 21
  LevelMale = 22
  LevelFemale = 23
  Location = 24
  TradeSpecies = 25
  Custom1 = 26
  Custom2 = 27
  Custom3 = 28
  Custom4 = 29
  Custom5 = 30
  Custom6 = 31
  Custom7 = 32

  EVONAMES = ["Unknown",
              "Happiness", "HappinessDay", "HappinessNight", "Level", "Trade",
              "TradeItem", "Item", "AttackGreater", "AtkDefEqual", "DefenseGreater",
              "Silcoon", "Cascoon", "Ninjask", "Shedinja", "Beauty",
              "ItemMale", "ItemFemale", "DayHoldItem", "NightHoldItem", "HasMove",
              "HasInParty", "LevelMale", "LevelFemale", "Location", "TradeSpecies",
              "Custom1", "Custom2", "Custom3", "Custom4", "Custom5", "Custom6", "Custom7"
  ]

  # 0 = no parameter
  # 1 = Positive integer
  # 2 = Item internal name
  # 3 = Move internal name
  # 4 = Species internal name
  # 5 = Type internal name
  EVOPARAM = [0, # Unknown (do not use)
              0, 0, 0, 1, 0, # Happiness, HappinessDay, HappinessNight, Level, Trade
              2, 2, 1, 1, 1, # TradeItem, Item, AttackGreater, AtkDefEqual, DefenseGreater
              1, 1, 1, 1, 1, # Silcoon, Cascoon, Ninjask, Shedinja, Beauty
              2, 2, 2, 2, 3, # ItemMale, ItemFemale, DayHoldItem, NightHoldItem, HasMove
              4, 1, 1, 1, 4, # HasInParty, LevelMale, LevelFemale, Location, TradeSpecies
              1, 1, 1, 1, 1, 1, 1 # Custom 1-7
  ]
end

class SpriteMetafile
  VIEWPORT = 0
  TONE = 1
  SRC_RECT = 2
  VISIBLE = 3
  X = 4
  Y = 5
  Z = 6
  OX = 7
  OY = 8
  ZOOM_X = 9
  ZOOM_Y = 10
  ANGLE = 11
  MIRROR = 12
  BUSH_DEPTH = 13
  OPACITY = 14
  BLEND_TYPE = 15
  COLOR = 16
  FLASHCOLOR = 17
  FLASHDURATION = 18
  BITMAP = 19

  def length
    return @metafile.length
  end

  def [](i)
    return @metafile[i]
  end

  def initialize(viewport = nil)
    @metafile = []
    @values = [
      viewport,
      Tone.new(0, 0, 0, 0), Rect.new(0, 0, 0, 0),
      true,
      0, 0, 0, 0, 0, 100, 100,
      0, false, 0, 255, 0,
      Color.new(0, 0, 0, 0), Color.new(0, 0, 0, 0),
      0
    ]
  end

  def disposed?
    return false
  end

  def dispose
  end

  def flash(color, duration)
    if duration > 0
      @values[FLASHCOLOR] = color.clone
      @values[FLASHDURATION] = duration
      @metafile.push([FLASHCOLOR, color])
      @metafile.push([FLASHDURATION, duration])
    end
  end

  def x
    return @values[X]
  end

  def x=(value)
    @values[X] = value
    @metafile.push([X, value])
  end

  def y
    return @values[Y]
  end

  def y=(value)
    @values[Y] = value
    @metafile.push([Y, value])
  end

  def bitmap
    return nil
  end

  def bitmap=(value)
    if value && !value.disposed?
      @values[SRC_RECT].set(0, 0, value.width, value.height)
      @metafile.push([SRC_RECT, @values[SRC_RECT].clone])
    end
  end

  def src_rect
    return @values[SRC_RECT]
  end

  def src_rect=(value)
    @values[SRC_RECT] = value
    @metafile.push([SRC_RECT, value])
  end

  def visible
    return @values[VISIBLE]
  end

  def visible=(value)
    @values[VISIBLE] = value
    @metafile.push([VISIBLE, value])
  end

  def z
    return @values[Z]
  end

  def z=(value)
    @values[Z] = value
    @metafile.push([Z, value])
  end

  def ox
    return @values[OX]
  end

  def ox=(value)
    @values[OX] = value
    @metafile.push([OX, value])
  end

  def oy
    return @values[OY]
  end

  def oy=(value)
    @values[OY] = value
    @metafile.push([OY, value])
  end

  def zoom_x
    return @values[ZOOM_X]
  end

  def zoom_x=(value)
    @values[ZOOM_X] = value
    @metafile.push([ZOOM_X, value])
  end

  def zoom_y
    return @values[ZOOM_Y]
  end

  def zoom_y=(value)
    @values[ZOOM_Y] = value
    @metafile.push([ZOOM_Y, value])
  end

  def angle
    return @values[ANGLE]
  end

  def angle=(value)
    @values[ANGLE] = value
    @metafile.push([ANGLE, value])
  end

  def mirror
    return @values[MIRROR]
  end

  def mirror=(value)
    @values[MIRROR] = value
    @metafile.push([MIRROR, value])
  end

  def bush_depth
    return @values[BUSH_DEPTH]
  end

  def bush_depth=(value)
    @values[BUSH_DEPTH] = value
    @metafile.push([BUSH_DEPTH, value])
  end

  def opacity
    return @values[OPACITY]
  end

  def opacity=(value)
    @values[OPACITY] = value
    @metafile.push([OPACITY, value])
  end

  def blend_type
    return @values[BLEND_TYPE]
  end

  def blend_type=(value)
    @values[BLEND_TYPE] = value
    @metafile.push([BLEND_TYPE, value])
  end

  def color
    return @values[COLOR]
  end

  def color=(value)
    @values[COLOR] = value.clone
    @metafile.push([COLOR, @values[COLOR]])
  end

  def tone
    return @values[TONE]
  end

  def tone=(value)
    @values[TONE] = value.clone
    @metafile.push([TONE, @values[TONE]])
  end

  def update
    @metafile.push([-1, nil])
  end
end

class SpriteMetafilePlayer
  def initialize(metafile, sprite = nil)
    @metafile = metafile
    @sprites = []
    @playing = false
    @index = 0
    @sprites.push(sprite) if sprite
  end

  def add(sprite)
    @sprites.push(sprite)
  end

  def playing?
    return @playing
  end

  def play
    @playing = true
    @index = 0
  end

  def update
    if @playing
      for j in @index...@metafile.length
        @index = j + 1
        break if @metafile[j][0] < 0
        code = @metafile[j][0]
        value = @metafile[j][1]
        for sprite in @sprites
          case code
          when SpriteMetafile::X
            sprite.x = value
          when SpriteMetafile::Y
            sprite.y = value
          when SpriteMetafile::OX
            sprite.ox = value
          when SpriteMetafile::OY
            sprite.oy = value
          when SpriteMetafile::ZOOM_X
            sprite.zoom_x = value
          when SpriteMetafile::ZOOM_Y
            sprite.zoom_y = value
          when SpriteMetafile::SRC_RECT
            sprite.src_rect = value
          when SpriteMetafile::VISIBLE
            sprite.visible = value
          when SpriteMetafile::Z
            sprite.z = value
            # prevent crashes
          when SpriteMetafile::ANGLE
            sprite.angle = (value == 180) ? 179.9 : value
          when SpriteMetafile::MIRROR
            sprite.mirror = value
          when SpriteMetafile::BUSH_DEPTH
            sprite.bush_depth = value
          when SpriteMetafile::OPACITY
            sprite.opacity = value
          when SpriteMetafile::BLEND_TYPE
            sprite.blend_type = value
          when SpriteMetafile::COLOR
            sprite.color = value
          when SpriteMetafile::TONE
            sprite.tone = value
          end
        end
      end
      @playing = false if @index == @metafile.length
    end
  end
end

def pbSaveSpriteState(sprite)
  state = []
  return state if !sprite || sprite.disposed?
  state[SpriteMetafile::BITMAP] = sprite.x
  state[SpriteMetafile::X] = sprite.x
  state[SpriteMetafile::Y] = sprite.y
  state[SpriteMetafile::SRC_RECT] = sprite.src_rect.clone
  state[SpriteMetafile::VISIBLE] = sprite.visible
  state[SpriteMetafile::Z] = sprite.z
  state[SpriteMetafile::OX] = sprite.ox
  state[SpriteMetafile::OY] = sprite.oy
  state[SpriteMetafile::ZOOM_X] = sprite.zoom_x
  state[SpriteMetafile::ZOOM_Y] = sprite.zoom_y
  state[SpriteMetafile::ANGLE] = sprite.angle
  state[SpriteMetafile::MIRROR] = sprite.mirror
  state[SpriteMetafile::BUSH_DEPTH] = sprite.bush_depth
  state[SpriteMetafile::OPACITY] = sprite.opacity
  state[SpriteMetafile::BLEND_TYPE] = sprite.blend_type
  state[SpriteMetafile::COLOR] = sprite.color.clone
  state[SpriteMetafile::TONE] = sprite.tone.clone
  return state
end

def pbRestoreSpriteState(sprite, state)
  return if !state || !sprite || sprite.disposed?
  sprite.x = state[SpriteMetafile::X]
  sprite.y = state[SpriteMetafile::Y]
  sprite.src_rect = state[SpriteMetafile::SRC_RECT]
  sprite.visible = state[SpriteMetafile::VISIBLE]
  sprite.z = state[SpriteMetafile::Z]
  sprite.ox = state[SpriteMetafile::OX]
  sprite.oy = state[SpriteMetafile::OY]
  sprite.zoom_x = state[SpriteMetafile::ZOOM_X]
  sprite.zoom_y = state[SpriteMetafile::ZOOM_Y]
  sprite.angle = state[SpriteMetafile::ANGLE]
  sprite.mirror = state[SpriteMetafile::MIRROR]
  sprite.bush_depth = state[SpriteMetafile::BUSH_DEPTH]
  sprite.opacity = state[SpriteMetafile::OPACITY]
  sprite.blend_type = state[SpriteMetafile::BLEND_TYPE]
  sprite.color = state[SpriteMetafile::COLOR]
  sprite.tone = state[SpriteMetafile::TONE]
end

def pbSaveSpriteStateAndBitmap(sprite)
  return [] if !sprite || sprite.disposed?
  state = pbSaveSpriteState(sprite)
  state[SpriteMetafile::BITMAP] = sprite.bitmap
  return state
end

def pbRestoreSpriteStateAndBitmap(sprite, state)
  return if !state || !sprite || sprite.disposed?
  sprite.bitmap = state[SpriteMetafile::BITMAP]
  pbRestoreSpriteState(sprite, state)
  return state
end

#####################

class PokemonFusionScene
  private

  def pbGenerateMetafiles(s1x, s1y, s2x, s2y, s3x, s3y, sxx, s3xx)
    sprite = SpriteMetafile.new
    sprite3 = SpriteMetafile.new
    sprite2 = SpriteMetafile.new

    sprite.opacity = 255
    sprite3.opacity = 255
    sprite2.opacity = 0

    sprite.ox = s1x
    sprite.oy = s1y
    sprite2.ox = s2x
    sprite2.oy = s2y
    sprite3.ox = s3x
    sprite3.oy = s3y

    sprite.x = sxx
    sprite3.x = s3xx

    red = 10
    green = 5
    blue = 90

    for j in 0...26
      sprite.color.red = red
      sprite.color.green = green
      sprite.color.blue = blue
      sprite.color.alpha = j * 10
      sprite.color = sprite.color

      sprite3.color.red = red
      sprite3.color.green = green
      sprite3.color.blue = blue
      sprite3.color.alpha = j * 10
      sprite3.color = sprite3.color

      sprite2.color = sprite.color
      sprite.update
      sprite3.update
      sprite2.update
    end
    anglechange = 0
    sevenseconds = Graphics.frame_rate * 3 #actually 3 seconds
    for j in 0...sevenseconds
      sprite.angle += anglechange
      sprite.angle %= 360

      sprite3.angle += anglechange
      sprite3.angle %= 360

      anglechange += 5 if j % 2 == 0
      if j >= sevenseconds - 50
        sprite2.angle = sprite.angle
        sprite2.opacity += 6
      end

      if sprite.x < sprite3.x && j >= 20
        sprite.x += 2
        sprite3.x -= 2
      else
        #sprite.ox+=1
        #sprite3.ox+=1
      end

      sprite.update
      sprite3.update
      sprite2.update
    end
    sprite.angle = 360 - sprite.angle
    sprite3.angle = 360 - sprite.angle
    sprite2.angle = 360 - sprite2.angle
    for j in 0...sevenseconds
      sprite2.angle += anglechange
      sprite2.angle %= 360
      anglechange -= 5 if j % 2 == 0
      if j < 50
        sprite.angle = sprite2.angle
        sprite.opacity -= 6

        sprite3.angle = sprite2.angle
        sprite3.opacity -= 6
      end

      sprite3.update
      sprite.update
      sprite2.update

    end
    for j in 0...26
      sprite2.color.red = 30
      sprite2.color.green = 230
      sprite2.color.blue = 55
      sprite2.color.alpha = (26 - j) * 10
      sprite2.color = sprite2.color
      sprite.color = sprite2.color
      sprite.update
      sprite2.update
    end
    @metafile1 = sprite
    @metafile2 = sprite2
    @metafile3 = sprite3

  end

  # Starts the fusion screen

  def pbStartScreen(pokemon1, pokemon2, newspecies)
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @pokemon1 = pokemon1
    @pokemon2 = pokemon2

    @newspecies = newspecies
    addBackgroundOrColoredPlane(@sprites, "background", "DNAbg",
                                Color.new(248, 248, 248), @viewport)

    poke1_number = GameData::Species.get(@pokemon1.species).id_number
    poke2_number = GameData::Species.get(@pokemon2.species).id_number

    @sprites["rsprite1"] = PokemonSprite.new(@viewport)
    @sprites["rsprite2"] = PokemonSprite.new(@viewport)
    @sprites["rsprite3"] = PokemonSprite.new(@viewport)

    @sprites["rsprite1"].setPokemonBitmapFromId(poke1_number, false, pokemon1.shiny?)
    @sprites["rsprite3"].setPokemonBitmapFromId(poke2_number, false, pokemon2.shiny?)

    @sprites["rsprite2"].setPokemonBitmapFromId(@newspecies, false, pokemon1.shiny? || pokemon2.shiny?, pokemon1.shiny?, pokemon2.shiny?)

    @sprites["rsprite1"].ox = @sprites["rsprite1"].bitmap.width / 2
    @sprites["rsprite1"].oy = @sprites["rsprite1"].bitmap.height / 2

    @sprites["rsprite3"].ox = @sprites["rsprite3"].bitmap.width / 2
    @sprites["rsprite3"].oy = @sprites["rsprite3"].bitmap.height / 2

    @sprites["rsprite2"].ox = @sprites["rsprite2"].bitmap.width / 2
    @sprites["rsprite2"].oy = @sprites["rsprite2"].bitmap.height / 2

    @sprites["rsprite2"].x = Graphics.width / 2
    @sprites["rsprite1"].y = (Graphics.height - 96) / 2
    @sprites["rsprite3"].y = (Graphics.height - 96) / 2

    @sprites["rsprite1"].x = (Graphics.width / 2) - 100
    @sprites["rsprite3"].x = (Graphics.width / 2) + 100

    @sprites["rsprite2"].y = (Graphics.height - 96) / 2
    @sprites["rsprite2"].opacity = 0

    @sprites["rsprite1"].zoom_x = Settings::FRONTSPRITE_SCALE
    @sprites["rsprite1"].zoom_y = Settings::FRONTSPRITE_SCALE

    @sprites["rsprite2"].zoom_x = Settings::FRONTSPRITE_SCALE
    @sprites["rsprite2"].zoom_y = Settings::FRONTSPRITE_SCALE

    @sprites["rsprite3"].zoom_x = Settings::FRONTSPRITE_SCALE
    @sprites["rsprite3"].zoom_y = Settings::FRONTSPRITE_SCALE

    pbGenerateMetafiles(@sprites["rsprite1"].ox, @sprites["rsprite1"].oy, @sprites["rsprite2"].ox, @sprites["rsprite2"].oy, @sprites["rsprite3"].ox, @sprites["rsprite3"].oy, @sprites["rsprite1"].x, @sprites["rsprite3"].x)

    @sprites["msgwindow"] = Kernel.pbCreateMessageWindow(@viewport)
    pbFadeInAndShow(@sprites)

    ####FUSION MULTIPLIER

    #####LEVELS
    level1 = pokemon1.level
    level2 = pokemon2.level

    ####LEVEL DIFFERENCE
    if (level1 >= level2) then
      avgLevel = (2 * level1 + level2) / 3
    else
      avgLevel = (2 * level2 + level1) / 3
    end

    ####CAPTURE RATES
    ####Check success Poke 1
    # if (fusionCheckSuccess (30, leveldiff, level1,fusionmultiplier)) then
    #   return 1
    # else
    #  return 0
    #end

    ####Check success Poke 2
    # if (fusionCheckSuccess (30, leveldiff, level1,fusionmultiplier)) then
    #   return 1
    # else
    #   return 0
    # end
    return 1
  end

  def calculateAverageValue(value1, value2)
    return ((value1 + value2) / 2).floor
  end

  def pickHighestOfTwoValues(value1, value2)
    return value1 >= value2 ? value1 : value2
  end

  def setFusionIVs(supersplicers)
    if supersplicers
      setHighestFusionIvs()
    else
      averageFusionIvs()
    end
  end

  def averageFusionIvs()
    @pokemon1.iv[:HP] = calculateAverageValue(@pokemon1.iv[:HP], @pokemon2.iv[:HP])
    @pokemon1.iv[:ATTACK] = calculateAverageValue(@pokemon1.iv[:ATTACK], @pokemon2.iv[:ATTACK])
    @pokemon1.iv[:DEFENSE] = calculateAverageValue(@pokemon1.iv[:DEFENSE], @pokemon2.iv[:DEFENSE])
    @pokemon1.iv[:SPECIAL_ATTACK] = calculateAverageValue(@pokemon1.iv[:SPECIAL_ATTACK], @pokemon2.iv[:SPECIAL_ATTACK])
    @pokemon1.iv[:SPECIAL_DEFENSE] = calculateAverageValue(@pokemon1.iv[:SPECIAL_DEFENSE], @pokemon2.iv[:SPECIAL_DEFENSE])
    @pokemon1.iv[:SPEED] = calculateAverageValue(@pokemon1.iv[:SPEED], @pokemon2.iv[:SPEED])
  end

  #unused. was meant for super splicers, but too broken
  def setHighestFusionIvs()
    @pokemon1.iv[:HP] = pickHighestOfTwoValues(@pokemon1.iv[:HP], @pokemon2.iv[:HP])
    @pokemon1.iv[:ATTACK] = pickHighestOfTwoValues(@pokemon1.iv[:ATTACK], @pokemon2.iv[:ATTACK])
    @pokemon1.iv[:DEFENSE] = pickHighestOfTwoValues(@pokemon1.iv[:DEFENSE], @pokemon2.iv[:DEFENSE])
    @pokemon1.iv[:SPECIAL_ATTACK] = pickHighestOfTwoValues(@pokemon1.iv[:SPECIAL_ATTACK], @pokemon2.iv[:SPECIAL_ATTACK])
    @pokemon1.iv[:SPECIAL_DEFENSE] = pickHighestOfTwoValues(@pokemon1.iv[:SPECIAL_DEFENSE], @pokemon2.iv[:SPECIAL_DEFENSE])
    @pokemon1.iv[:SPEED] = pickHighestOfTwoValues(@pokemon1.iv[:SPEED], @pokemon2.iv[:SPEED])
  end

  # Closes the evolution screen.
  def pbEndScreen
    Kernel.pbDisposeMessageWindow(@sprites["msgwindow"]) if @sprites["msgwindow"]
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites) if @sprites
    @viewport.dispose
  end

  # Opens the fusion screen

  def pbFusionScreen(cancancel = false, superSplicer = false, firstOptionSelected = false)
    metaplayer1 = SpriteMetafilePlayer.new(@metafile1, @sprites["rsprite1"])
    metaplayer2 = SpriteMetafilePlayer.new(@metafile2, @sprites["rsprite2"])
    metaplayer3 = SpriteMetafilePlayer.new(@metafile3, @sprites["rsprite3"])

    metaplayer1.play
    metaplayer2.play
    metaplayer3.play

    pbBGMStop()
    pbPlayCry(@pokemon)
    Kernel.pbMessageDisplay(@sprites["msgwindow"],
                            _INTL("The Pokémon are being fused!", @pokemon1.name))

    Kernel.pbMessageWaitForInput(@sprites["msgwindow"], 100, true)
    pbPlayDecisionSE()
    oldstate = pbSaveSpriteState(@sprites["rsprite1"])
    oldstate2 = pbSaveSpriteState(@sprites["rsprite2"])
    oldstate3 = pbSaveSpriteState(@sprites["rsprite3"])

    pbBGMPlay("fusion")

    canceled = false
    noMoves = false
    begin
      metaplayer1.update
      metaplayer2.update
      metaplayer3.update

      Graphics.update
      Input.update
      if Input.trigger?(Input::B) && Input.trigger?(Input::C) # && Input.trigger?(Input::A)# && cancancel
        noMoves = true
        pbSEPlay("buzzer")
        Graphics.update
      end
    end while metaplayer1.playing? && metaplayer2.playing?
    if canceled
      pbBGMStop()
      pbPlayCancelSE()
      # Kernel.pbMessageDisplay(@sprites["msgwindow"],
      @pbEndScreen
      _INTL("Huh? The fusion was cancelled!")
    else
      frames = pbCryFrameLength(@newspecies)
      pbBGMStop()
      pbPlayCry(@newspecies)
      frames.times do
        Graphics.update
      end
      pbMEPlay("Voltorb Flip Win")
      newSpecies = GameData::Species.get(@newspecies)
      newspeciesname = newSpecies.real_name
      oldspeciesname = GameData::Species.get(@pokemon1.species).real_name

      Kernel.pbMessageDisplay(@sprites["msgwindow"],
                              _INTL("\\se[]Congratulations! Your Pokémon were fused into {2}!\\wt[80]", @pokemon1.name, newspeciesname))

      #exp
      @pokemon1.exp_when_fused_head = @pokemon2.exp
      @pokemon1.exp_when_fused_body = @pokemon1.exp
      @pokemon1.exp_gained_since_fused = 0

      if @pokemon2.shiny?
        @pokemon1.head_shiny = true
      end
      if @pokemon1.shiny?
        @pokemon1.body_shiny = true
      end
      @pokemon1.debug_shiny = true if @pokemon1.debug_shiny || @pokemon2.debug_shiny

      setFusionIVs(superSplicer)
      #add to pokedex 
      if !$Trainer.pokedex.owned?(newSpecies)
        $Trainer.pokedex.set_seen(newSpecies)
        $Trainer.pokedex.set_owned(newSpecies)
        Kernel.pbMessageDisplay(@sprites["msgwindow"],
                                _INTL("{1}'s data was added to the Pokédex", newspeciesname))
        @scene.pbShowPokedex(@newspecies)
      end
      #first check if hidden ability
      hiddenAbility1 = @pokemon1.ability == @pokemon1.getAbilityList[0][-1]
      hiddenAbility2 = @pokemon2.ability == @pokemon2.getAbilityList[0][-1]

      #change species
      @pokemon1.species = newSpecies
      if @pokemon2.egg? || @pokemon1.egg?
        @pokemon1.steps_to_hatch = @pokemon1.species_data.hatch_steps
      end
      #@pokemon1.ability = pbChooseAbility(@pokemon1, hiddenAbility1, hiddenAbility2)
      pbChooseAbility(@pokemon1, hiddenAbility1, hiddenAbility2)

      setFusionMoves(@pokemon1, @pokemon2, firstOptionSelected) if !noMoves

      # if superSplicer
      #   @pokemon1.nature = pbChooseNature(@pokemon1.nature, @pokemon2.nature)
      # end
      #Check moves for new species
      # movelist = @pokemon1.getMoveList
      # for i in movelist
      #   if i[0] == @pokemon1.level
      #     pbLearnMove(@pokemon1, i[1]) if !noMoves #(pokemon,move,ignoreifknown=true, byTM=false , quick =true)
      #   end
      # end
      #@pokemon1.ability = pbChooseAbility(@pokemon1,@pokemon2)
      removeItem = false
      if @pokemon2.isShiny? || @pokemon1.isShiny?
        @pokemon1.makeShiny
        if !(@pokemon1.debug_shiny  ||@pokemon2.debug_shiny)
          @pokemon1.natural_shiny = true if @pokemon2.natural_shiny
        end
      end

      #make it untraded, pour qu'on puisse le unfused après, même si un des 2 était traded
      @pokemon1.obtain_method = 0
      @pokemon1.owner = Pokemon::Owner.new_from_trainer($Trainer)

      pbSEPlay("Voltorb Flip Point")

      @pokemon1.name = newspeciesname if @pokemon1.name == oldspeciesname

      @pokemon1.level = setPokemonLevel(@pokemon1.level, @pokemon2.level, superSplicer)
      @pokemon1.calc_stats
      @pokemon1.obtain_method = 0

    end
  end
end

def clearUIForMoves
  addBackgroundOrColoredPlane(@sprites, "background", "DNAbg",
                              Color.new(248, 248, 248), @viewport)
  pbDisposeSpriteHash(@sprites)

end

#todo: find a better name for this method...
def setAbilityAndNatureAndNickname(abilitiesList, naturesList)
  clearUIForMoves

  scene = FusionSelectOptionsScene.new(abilitiesList, naturesList, @pokemon1, @pokemon2)
  screen = PokemonOptionScreen.new(scene)
  screen.pbStartScreen

  @pokemon1.ability = scene.selectedAbility
  @pokemon1.nature = scene.selectedNature
  if scene.hasNickname
    @pokemon1.name = scene.nickname
  end

end

def setFusionMoves(fusedPoke, poke2, selected2ndOption = false)
  #NEW METHOD (not ready)

  # clearUIForMoves
  #
  # moves=fusedPoke.moves
  # scene = FusionMovesOptionsScene.new(fusedPoke,poke2)
  # screen = PokemonOptionScreen.new(scene)
  # screen.pbStartScreen
  # moves =[scene.move1,scene.move2,scene.move3,scene.move3]
  #
  # fusedPoke.moves=moves
  bodySpecies = getBodyID(fusedPoke)
  headSpecies = getHeadID(fusedPoke, bodySpecies)
  bodySpeciesName = GameData::Species.get(bodySpecies).real_name
  headSpeciesName = GameData::Species.get(headSpecies).real_name

  choice = Kernel.pbMessage("What to do with the moveset?", [_INTL("Combine movesets"), _INTL("Keep {1}'s moveset", bodySpeciesName), _INTL("Keep {1}'s moveset", headSpeciesName)], 0)
  if choice == 1
    if selected2ndOption
      fusedPoke.moves = poke2.moves
    else
      return
    end
    return
  elsif choice == 2
    if selected2ndOption
      return
    else
      fusedPoke.moves = poke2.moves
    end
    return
  else
    #Learn moves
    movelist = poke2.moves
    for move in movelist
      if move.id != 0
        pbLearnMove(fusedPoke, move.id, true, false, true)
      end
    end
  end
end

def setPokemonLevel(pokemon1, pokemon2, superSplicers)
  lv1 = @pokemon1.level
  lv2 = @pokemon2.level
  return calculateFusedPokemonLevel(lv1, lv2, superSplicers)
end

def calculateFusedPokemonLevel(lv1, lv2, superSplicers)
  if superSplicers
    if lv1 > lv2
      return lv1
    else
      return lv2
    end
  else
    if (lv1 >= lv2) then
      return (2 * lv1 + lv2) / 3
    else
      return (2 * lv2 + lv1) / 3
    end
  end
  return lv1
end

def pbShowPokedex(species)
  pbFadeOutIn {
    scene = PokemonPokedexInfo_Scene.new
    screen = PokemonPokedexInfoScreen.new(scene)
    screen.pbDexEntry(species)
  }
end

def pbChooseAbility(poke, hidden1 = false, hidden2 = false)
  abilityList = poke.getAbilityList
  #pas sur de l'ordre pour les hidden (3 et 4) peut-être a inverser
  #Mais les fusions ont tjrs 4 hidden abilities
  #2. l'autre ability du poke 1
  #3. l'autre ability du poke 2
  #4. hidden du poke 1
  #5. hidden du poke2

  abID1 = hidden1 ? abilityList[4][0] : abilityList[0][0]
  abID2 = hidden2 ? abilityList[5][0] : abilityList[1][0]

  ability1_name = GameData::Ability.get(abID1).name
  ability2_name = GameData::Ability.get(abID2).name
  availableNatures = []
  availableNatures << @pokemon1.nature
  availableNatures << @pokemon2.nature

  setAbilityAndNatureAndNickname([GameData::Ability.get(abID1), GameData::Ability.get(abID2)], availableNatures)

  # if (Kernel.pbMessage("Choose an ability. ???", [_INTL("{1}", ability1_name), _INTL("{1}", ability2_name)], 2)) == 0
  #   return abID1 #hidden1 ? 4 : 0
  # end
  # return abID2 #hidden2 ? 5 : 1
end

def pbChooseNature(species1_nature, species2_nature)
  nature1 = GameData::Nature.get(species1_nature)
  nature2 = GameData::Nature.get(species2_nature)

  if (Kernel.pbMessage("Choose a nature.", [_INTL("{1}", nature1.real_name), _INTL("{1}", nature2.real_name)], 2)) == 0
    return nature1.id_number
  else
    return nature2.id_number
  end
end

#EDITED FOR GEN2
def fixEvolutionOverflow(retB, retH, oldSpecies)
  #raise Exception.new("retB: " + retB.to_s + " retH: " + retH.to_s)

  oldBody = getBasePokemonID(oldSpecies)
  oldHead = getBasePokemonID(oldSpecies, false)
  return -1 if isNegativeOrNull(retB) && isNegativeOrNull(retH)
  return oldBody * NB_POKEMON + retH if isNegativeOrNull(retB) #only head evolves
  return retB * NB_POKEMON + oldHead if isNegativeOrNull(retH) #only body evolves
  return retB * NB_POKEMON + retH #both evolve
end

