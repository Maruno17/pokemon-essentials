class FusionMovesOptionsScene < PokemonOption_Scene
  attr_accessor :move1
  attr_accessor :move2
  attr_accessor :move3
  attr_accessor :move4

  def initialize(poke1, poke2)
    @poke1 = poke1
    @poke2 = poke2

    @move1 = @poke1.moves[0]
    @move2 = @poke1.moves[1]
    @move3 = @poke1.moves[2]
    @move4 = @poke1.moves[3]


    @index1=0
    @index2=0
    @index3=0
    @index4=0


    @selBaseColor = Color.new(48,96,216)
    @selShadowColor = Color.new(32,32,32)
  end

  def initUIElements
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL(""), 0, 0, Graphics.width, 64, @viewport)
    @sprites["textbox"] = pbCreateMessageWindow
    @sprites["textbox"].letterbyletter = false
    pbSetSystemFont(@sprites["textbox"].contents)
  end



  def pbStartScene(inloadscreen = false)
    super
    @typebitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["overlay"].z = 9999
    pbSetSystemFont(@sprites["overlay"].bitmap)

    @sprites["option"].nameBaseColor = Color.new(35, 130, 200)
    @sprites["option"].nameShadowColor = Color.new(20, 75, 115)
    @changedColor = true
    for i in 0...@PokemonOptions.length
      @sprites["option"][i] = (@PokemonOptions[i].get || 0)
    end
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Select moves"), 0, 0, Graphics.width, 64, @viewport)
    @sprites["title"].setSkin("Graphics/Windowskins/invisible")
    @sprites["option"].setSkin("Graphics/Windowskins/invisible")
    @sprites["textbox"].setSkin("Graphics/Windowskins/invisible")
    # @sprites["textbox"].text = _INTL("Select moves")
    updateDescription(0)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def draw_empty_move_info
    # code here
  end

  def draw_move_info(pokemonMove)
    move = GameData::Move.get(pokemonMove.id)
    move_base_color = Color.new(50, 40, 230)
    move_base_shadow = Color.new(14, 14, 114)

    label_base_color = Color.new(248, 248, 248)
    label_shadow_color = Color.new(104, 104, 104)

    value_base_color = Color.new(248, 248, 248)
    value_shadow_color = Color.new(104, 104, 104)

    @sprites["title"].text = _INTL("{1}", move.real_name)

    damage = move.base_damage == 0 ? "-" : move.base_damage.to_s
    accuracy = move.accuracy == 0 ? "100" : move.accuracy.to_s
    pp = move.total_pp.to_s
    if !move
      damage="-"
      accuracy="-"
      pp="-"
    end

    textpos = [
      [_INTL("Type"), 20, 84, 0, label_base_color, label_shadow_color],
      [_INTL("Category"), 20, 116, 0, label_base_color, label_shadow_color],

      [_INTL("Power"), 20, 148, 0, label_base_color, label_shadow_color],
      [_INTL("{1}", damage), 140, 148, 0, value_base_color, value_shadow_color],

      [_INTL("Accuracy"), 20, 180, 0, label_base_color, label_shadow_color],
      [_INTL("{1}%", accuracy), 140, 180, 0, value_base_color, value_shadow_color],

      [_INTL("PP"), 20, 212, 0, label_base_color, label_shadow_color], #move.total_pp
      [_INTL("{1}", pp), 140, 212, 0, value_base_color, value_shadow_color] #move.total_pp

    ]
    imagepos = []

    yPos = 90
    type_number = GameData::Type.get(move.type).id_number
    category = move.category
    imagepos.push(["Graphics/Pictures/types", 120, 94, 0, type_number * 28, 64, 28]) #248
    imagepos.push(["Graphics/Pictures/category", 120, 124, 0, category * 28, 64, 28])
    if !move
      imagepos=[]
    end
    @sprites["overlay"].bitmap.clear
    pbDrawTextPositions(@sprites["overlay"].bitmap, textpos)
    pbDrawImagePositions(@sprites["overlay"].bitmap, imagepos)

  end

  def draw_pokemon_type
    type1_number = GameData::Type.get(@poke1.type1).id_number
    type2_number = GameData::Type.get(@poke1.type2).id_number
    type1rect = Rect.new(0, type1_number * 28, 64, 28)
    type2rect = Rect.new(0, type2_number * 28, 64, 28)
    if @poke1.type1 == @poke1.type2
      overlay.blt(130, 78, @typebitmap.bitmap, type1rect)
    else
      overlay.blt(96, 78, @typebitmap.bitmap, type1rect)
      overlay.blt(166, 78, @typebitmap.bitmap, type2rect)
    end
  end

  def updateDescription(index)
    index = 0 if !index
    begin
      move = getMoveForIndex(index)
      draw_move_info(move)
      new_description = getMoveDescription(move)
      @sprites["textbox"].text = _INTL(new_description)
    rescue
      @sprites["textbox"].text = getDefaultDescription
    end
  end

  def getDefaultDescription
    return  _INTL("No move selected")
  end

  def getMoveForIndex(index)
    case index
    when 0
      return @move1
    when 1
      return @move2
    when 2
      return @move3
    when 3
      return @move4
    end
    return nil
  end

  def pbFadeInAndShow(sprites, visiblesprites = nil)
    return if !@changedColor
    super
  end

  def getMoveName(move)
    return " - " if !@sprites["option"] && !move
    move = @poke1.moves[@sprites["option"].index] if !move
    return GameData::Move.get(move.id).real_name
  end

  def getMoveDescription(move)
    return " - " if !@sprites["option"] && !move
    move = @poke1.moves[@sprites["option"].index] if !move
    return GameData::Move.get(move.id).real_description
  end

  def pbGetOptions(inloadscreen = false)
    options = [
      EnumOption.new(_INTL(""), [_INTL(getMoveName(@poke1.moves[0])), _INTL(getMoveName(@poke2.moves[0]))],
                     proc { 0 },
                     proc { |value|
                       @move1 = value == 0 ? @poke1.moves[0] : @poke2.moves[0]
                     }, [getMoveDescription(@poke1.moves[0]), getMoveDescription(@poke2.moves[0])]
      ),
      EnumOption.new(_INTL(""), [_INTL(getMoveName(@poke1.moves[1])), _INTL(getMoveName(@poke2.moves[1]))],
                     proc { 0 },
                     proc { |value|
                       @move2 = value == 0 ? @poke1.moves[1] : @poke2.moves[1]
                     }, [getMoveDescription(@poke1.moves[1]), getMoveDescription(@poke2.moves[1])]
      ),
      EnumOption.new(_INTL(""), [_INTL(getMoveName(@poke1.moves[2])), _INTL(getMoveName(@poke2.moves[2]))],
                     proc { 0 },
                     proc { |value|
                       @move3 = value == 0 ? @poke1.moves[2] : @poke2.moves[2]
                     }, [getMoveDescription(@poke1.moves[2]), getMoveDescription(@poke2.moves[2])]
      ),
      EnumOption.new(_INTL(""), [_INTL(getMoveName(@poke1.moves[3])), _INTL(getMoveName(@poke2.moves[3]))],
                     proc { 0 },
                     proc { |value|
                       @move4 = value == 0 ? @poke1.moves[3] : @poke2.moves[3]
                     }, [getMoveDescription(@poke1.moves[3]), getMoveDescription(@poke2.moves[3])]
      )
    ]
    return options
  end

  def isConfirmedOnKeyPress
    return true
  end

  def initOptionsWindow
    optionsWindow = Window_PokemonOptionFusionMoves.new(@PokemonOptions, 0,
                                             @sprites["title"].height, Graphics.width,
                                             Graphics.height - @sprites["title"].height - @sprites["textbox"].height)
    optionsWindow.viewport = @viewport
    optionsWindow.visible = true
    return optionsWindow
  end

end


class Window_PokemonOptionFusionMoves < Window_PokemonOption
  def initialize(options, x, y, width, height)
    super
    @mustUpdateOptions=true
    @mustUpdateDescription=true
    @confirmed=false
  end

  def drawCursor(index,rect)
    if self.index==index
      pbCopyBitmap(self.contents, @selarrow.bitmap,rect.x+175,rect.y)
    end
    return Rect.new(rect.x+16,rect.y,rect.width-16,rect.height)
  end

    def dont_draw_item(index)
    return index == @options.length
  end
end