#===============================================================================
# Scene class for handling appearance of the screen
#===============================================================================
class MoveRelearner_Scene
  VISIBLEMOVES = 4

  def pbDisplay(msg, brief = false)
    UIHelper.pbDisplay(@sprites["msgwindow"], msg, brief) { pbUpdate }
  end

  def pbConfirm(msg)
    UIHelper.pbConfirm(@sprites["msgwindow"], msg) { pbUpdate }
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(pokemon, moves)
    @pokemon = pokemon
    @moves = moves
    moveCommands = []
    moves.each { |m| moveCommands.push(GameData::Move.get(m).name) }
    # Create sprite hash
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    addBackgroundPlane(@sprites, "bg", "Move Reminder/bg", @viewport)
    @sprites["pokeicon"] = PokemonIconSprite.new(@pokemon, @viewport)
    @sprites["pokeicon"].setOffset(PictureOrigin::CENTER)
    @sprites["pokeicon"].x = 320
    @sprites["pokeicon"].y = 84
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/UI/Move Reminder/cursor")
    @sprites["background"].y = 78
    @sprites["background"].src_rect = Rect.new(0, 72, 258, 72)
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["commands"] = Window_CommandPokemon.new(moveCommands, 32)
    @sprites["commands"].height = 32 * (VISIBLEMOVES + 1)
    @sprites["commands"].visible = false
    @sprites["msgwindow"] = Window_AdvancedTextPokemon.new("")
    @sprites["msgwindow"].visible = false
    @sprites["msgwindow"].viewport = @viewport
    @typebitmap = AnimatedBitmap.new(_INTL("Graphics/UI/types"))
    pbDrawMoveList
    pbDeactivateWindows(@sprites)
    # Fade in all sprites
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbDrawMoveList
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    @pokemon.types.each_with_index do |type, i|
      type_number = GameData::Type.get(type).icon_position
      type_rect = Rect.new(0, type_number * 28, 64, 28)
      type_x = (@pokemon.types.length == 1) ? 400 : 366 + (70 * i)
      overlay.blt(type_x, 70, @typebitmap.bitmap, type_rect)
    end
    textpos = [
      [_INTL("Teach which move?"), 16, 14, :left, Color.new(88, 88, 80), Color.new(168, 184, 184)]
    ]
    imagepos = []
    yPos = 88
    VISIBLEMOVES.times do |i|
      moveobject = @moves[@sprites["commands"].top_item + i]
      if moveobject
        moveData = GameData::Move.get(moveobject)
        type_number = GameData::Type.get(moveData.display_type(@pokemon)).icon_position
        imagepos.push([_INTL("Graphics/UI/types"), 12, yPos - 4, 0, type_number * 28, 64, 28])
        textpos.push([moveData.name, 80, yPos, :left, Color.new(248, 248, 248), Color.black])
        textpos.push([_INTL("PP"), 112, yPos + 32, :left, Color.new(64, 64, 64), Color.new(176, 176, 176)])
        if moveData.total_pp > 0
          textpos.push([moveData.total_pp.to_s + "/" + moveData.total_pp.to_s, 230, yPos + 32, :right,
                        Color.new(64, 64, 64), Color.new(176, 176, 176)])
        else
          textpos.push(["--", 230, yPos + 32, :right, Color.new(64, 64, 64), Color.new(176, 176, 176)])
        end
      end
      yPos += 64
    end
    imagepos.push(["Graphics/UI/Move Reminder/cursor",
                   0, 78 + ((@sprites["commands"].index - @sprites["commands"].top_item) * 64),
                   0, 0, 258, 72])
    selMoveData = GameData::Move.get(@moves[@sprites["commands"].index])
    power = selMoveData.display_damage(@pokemon)
    category = selMoveData.display_category(@pokemon)
    accuracy = selMoveData.display_accuracy(@pokemon)
    textpos.push([_INTL("CATEGORY"), 272, 120, :left, Color.new(248, 248, 248), Color.black])
    textpos.push([_INTL("POWER"), 272, 152, :left, Color.new(248, 248, 248), Color.black])
    textpos.push([power <= 1 ? power == 1 ? "???" : "---" : power.to_s, 468, 152, :center,
                  Color.new(64, 64, 64), Color.new(176, 176, 176)])
    textpos.push([_INTL("ACCURACY"), 272, 184, :left, Color.new(248, 248, 248), Color.black])
    textpos.push([accuracy == 0 ? "---" : "#{accuracy}%", 468, 184, :center,
                  Color.new(64, 64, 64), Color.new(176, 176, 176)])
    pbDrawTextPositions(overlay, textpos)
    imagepos.push(["Graphics/UI/category", 436, 116, 0, category * 28, 64, 28])
    if @sprites["commands"].index < @moves.length - 1
      imagepos.push(["Graphics/UI/Move Reminder/buttons", 48, 350, 0, 0, 76, 32])
    end
    if @sprites["commands"].index > 0
      imagepos.push(["Graphics/UI/Move Reminder/buttons", 134, 350, 76, 0, 76, 32])
    end
    pbDrawImagePositions(overlay, imagepos)
    drawTextEx(overlay, 272, 216, 230, 5, selMoveData.description,
               Color.new(64, 64, 64), Color.new(176, 176, 176))
  end

  # Processes the scene
  def pbChooseMove
    oldcmd = -1
    pbActivateWindow(@sprites, "commands") do
      loop do
        oldcmd = @sprites["commands"].index
        Graphics.update
        Input.update
        pbUpdate
        if @sprites["commands"].index != oldcmd
          @sprites["background"].x = 0
          @sprites["background"].y = 78 + ((@sprites["commands"].index - @sprites["commands"].top_item) * 64)
          pbDrawMoveList
        end
        if Input.trigger?(Input::BACK)
          return nil
        elsif Input.trigger?(Input::USE)
          return @moves[@sprites["commands"].index]
        end
      end
    end
  end

  # End the scene here
  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @typebitmap.dispose
    @viewport.dispose
  end
end

#===============================================================================
# Screen class for handling game logic
#===============================================================================
class MoveRelearnerScreen
  def initialize(scene)
    @scene = scene
  end

  def pbGetRelearnableMoves(pkmn)
    return [] if !pkmn || pkmn.egg? || pkmn.shadowPokemon?
    moves = []
    pkmn.getMoveList.each do |m|
      next if m[0] > pkmn.level || pkmn.hasMove?(m[1])
      moves.push(m[1]) if !moves.include?(m[1])
    end
    if Settings::MOVE_RELEARNER_CAN_TEACH_MORE_MOVES && pkmn.first_moves
      tmoves = []
      pkmn.first_moves.each do |i|
        tmoves.push(i) if !moves.include?(i) && !pkmn.hasMove?(i)
      end
      moves = tmoves + moves   # List first moves before level-up moves
    end
    return moves | []   # remove duplicates
  end

  def pbStartScreen(pkmn)
    moves = pbGetRelearnableMoves(pkmn)
    @scene.pbStartScene(pkmn, moves)
    loop do
      move = @scene.pbChooseMove
      if move
        if @scene.pbConfirm(_INTL("Teach {1}?", GameData::Move.get(move).name))
          if pbLearnMove(pkmn, move)
            $stats.moves_taught_by_reminder += 1
            @scene.pbEndScene
            return true
          end
        end
      elsif @scene.pbConfirm(_INTL("Give up trying to teach a new move to {1}?", pkmn.name))
        @scene.pbEndScene
        return false
      end
    end
  end
end

#===============================================================================
#
#===============================================================================
def pbRelearnMoveScreen(pkmn)
  retval = true
  pbFadeOutIn do
    scene = MoveRelearner_Scene.new
    screen = MoveRelearnerScreen.new(scene)
    retval = screen.pbStartScreen(pkmn)
  end
  return retval
end
