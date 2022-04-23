class PokeRadar_UI
  attr_reader :sprites
  attr_reader :disposed

  ICON_START_X = 50
  ICON_START_Y = 5

  ICON_MARGIN_X = 50
  ICON_MARGIN_Y = 50

  ICON_LINE_END = 450


  def initialize(seenPokemon = [], unseenPokemon = [], rarePokemon = [])
    @seen_pokemon = seenPokemon
    @unseen_pokemon = unseenPokemon
    @rare_pokemon = rarePokemon

    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/Pokeradar/banner")
    @sprites["background"].zoom_x = 2
    @sprites["background"].zoom_y = 2

    @sprites["background"].visible = true

    @current_x = 50
    @current_y = 0
    displaySeen()
    displayUnseen()
    displayRare()
  end

  def dispose
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose if @viewport != nil
  end

  #display rare with a (circle?) under the sprite to highlight it
  # blacken if not seen
  def displayRare()
    @rare_pokemon.each { |pokemon|
      blackened = !$Trainer.seen?(pokemon)
      addPokemonIcon(pokemon,blackened,true)
    }
  end

  def displaySeen()
    @seen_pokemon.each { |pokemonId|
      addPokemonIcon(pokemonId, false )
    }
  end

  def displayUnseen()
    @unseen_pokemon.each { |pokemonId|
      addPokemonIcon(pokemonId, true)
    }
  end

  def addPokemonIcon(pokemonId, blackened = false, rare=false)
    iconId = _INTL("icon{1}", pokemonId)
    pokemonBitmap = pbCheckPokemonIconFiles(getDexNumberForSpecies(pokemonId))
    if rare
      outlineSprite = IconSprite.new(@current_x, @current_y)
      outlineSprite.setBitmap("Graphics/Pictures/Pokeradar/highlight")
      outlineSprite.visible=true
      @sprites[iconId + "_outline"] = outlineSprite
    end

    iconSprite = IconSprite.new(@current_x, @current_y)
    iconSprite.setBitmap(pokemonBitmap)
    @sprites[iconId] = iconSprite
    @sprites[iconId].src_rect.width /= 2


    if blackened
        @sprites[iconId].setColor(0,0,0,200)
    end
    @sprites[iconId].visible = true
    @sprites[iconId].x = @current_x
    @sprites[iconId].y = @current_y
    @sprites[iconId].z = 100

    @current_x += ICON_MARGIN_X
    if @current_x > ICON_LINE_END
      @current_x = ICON_START_X
      @current_y +=ICON_MARGIN_Y
      @sprites["background"].zoom_y += 1
    end

  end

end



