class DoublePreviewScreen
  SELECT_ARROW_X_LEFT= 100
  SELECT_ARROW_X_RIGHT= 350
  SELECT_ARROW_X_CANCEL= 230

  SELECT_ARROW_Y_SELECT= 0
  SELECT_ARROW_Y_CANCEL= 210
  ARROW_GRAPHICS_PATH = "Graphics/Pictures/selHand"
  CANCEL_BUTTON_PATH = "Graphics/Pictures/previewScreen_Cancel"
  BACKGROUND_PATH = "Graphics/Pictures/shadeFull_"


  CANCEL_BUTTON_X= 140
  CANCEL_BUTTON_Y= 260

  def initialize(species_left, species_right)
    @species_left = species_left
    @species_right = species_right

    @typewindows = []
    @picture1 = nil
    @picture2 = nil
    @draw_types = nil
    @draw_level = nil
    @selected = 0
    @last_post=0
    @sprites      = {}

    initializeBackground
    initializeSelectArrow
    initializeCancelButton
  end

  def getBackgroundPicture
    return BACKGROUND_PATH
  end


  def getSelection
    selected = startSelection
    @sprites["cancel"].visible=false
    #@sprites["arrow"].visible=false

    #todo: il y a un fuck en quelque part.... en attendant ca marche inversé ici
    return @species_left if selected == 0
    return @species_right if selected == 1
    return -1
  end

  def startSelection
    loop do
      Graphics.update
      Input.update
      updateSelection
      if Input.trigger?(Input::USE)
        return @selected
      end
      if Input.trigger?(Input::BACK)
        return -1
      end
    end
  end

  def updateSelection
    currentSelected = @selected
    updateSelectionIndex
    if @selected != currentSelected
      updateSelectionGraphics
    end
  end

  def updateSelectionIndex
    if Input.trigger?(Input::LEFT)
      @selected = 0
    elsif Input.trigger?(Input::RIGHT)
      @selected = 1
    end
    if @selected == -1
      if Input.trigger?(Input::UP)
        @selected = @last_post
      end
    else
      if Input.trigger?(Input::DOWN)
        @last_post = @selected
        @selected = -1
      end
    end
  end

  def updateSelectionGraphics
    if @selected == 0
      @sprites["arrow"].x = SELECT_ARROW_X_LEFT
      @sprites["arrow"].y = SELECT_ARROW_Y_SELECT
    elsif @selected == 1
      @sprites["arrow"].x = SELECT_ARROW_X_RIGHT
      @sprites["arrow"].y = SELECT_ARROW_Y_SELECT
    else
      @sprites["arrow"].x = SELECT_ARROW_X_CANCEL
      @sprites["arrow"].y = SELECT_ARROW_Y_CANCEL
    end
    pbUpdateSpriteHash(@sprites)
  end

  def draw_window(dexNumber, level, x, y)
    body_pokemon = getBodyID(dexNumber)
    head_pokemon = getHeadID(dexNumber, body_pokemon)

    picturePath = getPicturePath(head_pokemon, body_pokemon)
    bitmap = AnimatedBitmap.new(picturePath)
    bitmap.scale_bitmap(Settings::FRONTSPRITE_SCALE)

    hasCustom = picturePath.include?("CustomBattlers")

    previewwindow = PictureWindow.new(bitmap)
    previewwindow.x = x
    previewwindow.y = y
    previewwindow.z = 100000

    drawFusionInformation(dexNumber, level, x)

    if !$Trainer.seen?(dexNumber)
      if hasCustom
        previewwindow.picture.pbSetColor(150, 255, 150, 200)
      else
        previewwindow.picture.pbSetColor(255, 255, 255, 200)
      end
    end
    return previewwindow
  end


  def getPicturePath(head_pokemon, body_pokemon)
    pathCustom = _INTL("Graphics/CustomBattlers/{1}.{2}.png", head_pokemon, body_pokemon)
    if (pbResolveBitmap(pathCustom))
      picturePath = pathCustom
    else
      picturePath = _INTL("Graphics/Battlers/{1}/{1}.{2}.png",head_pokemon , body_pokemon)
    end
    return picturePath
  end

  def drawFusionInformation(fusedDexNum, level, x = 0)
    viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @typewindows << drawPokemonType(fusedDexNum, viewport, x + 40, 220) if @draw_types
    drawFusionPreviewText(viewport, "Lv. " + level.to_s, x + 60, 40,) if @draw_level
  end


  def initializeSelectArrow
    @sprites["arrow"] = IconSprite.new(0, 0, @viewport)
    @sprites["arrow"].setBitmap(ARROW_GRAPHICS_PATH)
    @sprites["arrow"].x = SELECT_ARROW_X_LEFT
    @sprites["arrow"].y = SELECT_ARROW_Y_SELECT
    @sprites["arrow"].z = 100001
  end


  def initializeCancelButton()
    @sprites["cancel"] = IconSprite.new(0, 0, @viewport)
    @sprites["cancel"].setBitmap(CANCEL_BUTTON_PATH)
    @sprites["cancel"].x = CANCEL_BUTTON_X
    @sprites["cancel"].y = CANCEL_BUTTON_Y
    @sprites["cancel"].z = 100000
  end

  def initializeBackground()
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap(getBackgroundPicture)
    @sprites["background"].x = 0
    @sprites["background"].y = 0
    @sprites["background"].z = 99999
  end

  def drawFusionPreviewText(viewport, text, x, y)
    label_base_color = Color.new(248, 248, 248)
    label_shadow_color = Color.new(104, 104, 104)
    overlay = BitmapSprite.new(Graphics.width, Graphics.height, viewport).bitmap
    textpos = [[text, x, y, 0, label_base_color, label_shadow_color]]
    pbDrawTextPositions(overlay, textpos)
  end

  def dispose
    @picture1.dispose
    @picture2.dispose
    for typeWindow in @typewindows
      typeWindow.dispose
    end
    pbDisposeSpriteHash(@sprites)

  end

  def drawPokemonType(pokemon_id, viewport, x_pos = 192, y_pos = 264)
    width = 66
    viewport.z = 1000001
    overlay = BitmapSprite.new(Graphics.width, Graphics.height, viewport).bitmap

    pokemon = GameData::Species.get(pokemon_id)
    typebitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
    type1_number = GameData::Type.get(pokemon.type1).id_number
    type2_number = GameData::Type.get(pokemon.type2).id_number
    type1rect = Rect.new(0, type1_number * 28, 64, 28)
    type2rect = Rect.new(0, type2_number * 28, 64, 28)
    if pokemon.type1 == pokemon.type2
      overlay.blt(x_pos + (width / 2), y_pos, typebitmap.bitmap, type1rect)
    else
      overlay.blt(x_pos, y_pos, typebitmap.bitmap, type1rect)
      overlay.blt(x_pos + width, y_pos, typebitmap.bitmap, type2rect)
    end
    return viewport
  end

end
