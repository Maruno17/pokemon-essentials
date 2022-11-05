class DoublePreviewScreen
  def initialize(poke1,poke2, usingSuperSplicers=false)
    @typewindows=[]
    @picture1=nil
    @picture2=nil
    @draw_types = nil
    @draw_level = nil
  end

  def draw_window(dexNumber ,level, x, y)
    body_pokemon = getBodyID(dexNumber)
    head_pokemon = getHeadID(dexNumber,body_pokemon)

    picturePath = getPicturePath(body_pokemon,head_pokemon)
    bitmap = AnimatedBitmap.new(picturePath)
    bitmap.scale_bitmap(Settings::FRONTSPRITE_SCALE)

    hasCustom = picturePath.include?("CustomBattlers")


    previewwindow = PictureWindow.new(bitmap)
    previewwindow.x = x
    previewwindow.y = y
    previewwindow.z = 1000000

    drawFusionInformation(dexNumber,level, x)

    if !$Trainer.seen?(dexNumber)
      if hasCustom
        previewwindow.picture.pbSetColor(150, 255, 150, 200)
      else
        previewwindow.picture.pbSetColor(255, 255, 255, 200)
      end
    end
    return previewwindow
  end

  def getPicturePath(body_pokemon, head_pokemon)
    pathCustom = _INTL("Graphics/CustomBattlers/{1}.{2}.png", body_pokemon, head_pokemon)
    if (pbResolveBitmap(pathCustom))
      picturePath = pathCustom
    else
      picturePath = _INTL("Graphics/Battlers/{1}/{1}.{2}.png", body_pokemon, head_pokemon)
    end
    return picturePath
  end

  def drawFusionInformation(fusedDexNum, level, x=0)
    viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @typewindows << drawPokemonType(fusedDexNum,viewport, x+40,220) if @draw_types
    drawFusionPreviewText(viewport, "Lv. " + level.to_s, x+60, 40,) if @draw_level
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
