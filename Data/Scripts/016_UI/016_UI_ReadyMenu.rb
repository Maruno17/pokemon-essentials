#===============================================================================
#
#===============================================================================
class ReadyMenuButton < Sprite
  attr_reader :index   # ID of button
  attr_reader :selected
  attr_reader :side

  def initialize(index, command, selected, side, viewport = nil)
    super(viewport)
    @index = index
    @command = command   # Item/move ID, name, mode (T move/F item), pkmnIndex
    @selected = selected
    @side = side
    if @command[2]
      @button = AnimatedBitmap.new("Graphics/UI/Ready Menu/icon_movebutton")
    else
      @button = AnimatedBitmap.new("Graphics/UI/Ready Menu/icon_itembutton")
    end
    @contents = Bitmap.new(@button.width, @button.height / 2)
    self.bitmap = @contents
    pbSetSystemFont(self.bitmap)
    if @command[2]
      @icon = PokemonIconSprite.new($player.party[@command[3]], viewport)
      @icon.setOffset(PictureOrigin::CENTER)
    else
      @icon = ItemIconSprite.new(0, 0, @command[0], viewport)
    end
    @icon.z = self.z + 1
    refresh
  end

  def dispose
    @button.dispose
    @contents.dispose
    @icon.dispose
    super
  end

  def visible=(val)
    @icon.visible = val
    super(val)
  end

  def selected=(val)
    oldsel = @selected
    @selected = val
    refresh if oldsel != val
  end

  def side=(val)
    oldsel = @side
    @side = val
    refresh if oldsel != val
  end

  def refresh
    sel = (@selected == @index && (@side == 0) == @command[2])
    self.y = ((Graphics.height - (@button.height / 2)) / 2) - ((@selected - @index) * ((@button.height / 2) + 4))
    if @command[2]   # Pokémon
      self.x = (sel) ? 0 : -16
      @icon.x = self.x + 52
      @icon.y = self.y + 32
    else   # Item
      self.x = (sel) ? Graphics.width - @button.width : Graphics.width + 16 - @button.width
      @icon.x = self.x + 32
      @icon.y = self.y + (@button.height / 4)
    end
    self.bitmap.clear
    rect = Rect.new(0, (sel) ? @button.height / 2 : 0, @button.width, @button.height / 2)
    self.bitmap.blt(0, 0, @button.bitmap, rect)
    textx = 164
    if !@command[2]
      textx = (GameData::Item.get(@command[0]).is_important?) ? 146 : 124
    end
    textpos = [
      [@command[1], textx, 24, :center, Color.new(248, 248, 248), Color.new(40, 40, 40), :outline]
    ]
    if !@command[2] && !GameData::Item.get(@command[0]).is_important?
      qty = $bag.quantity(@command[0])
      if qty > 99
        textpos.push([_INTL(">99"), 230, 24, :right,
                      Color.new(248, 248, 248), Color.new(40, 40, 40), :outline])
      else
        textpos.push([_INTL("x{1}", qty), 230, 24, :right,
                      Color.new(248, 248, 248), Color.new(40, 40, 40), :outline])
      end
    end
    pbDrawTextPositions(self.bitmap, textpos)
  end

  def update
    @icon&.update
    super
  end
end

#===============================================================================
#
#===============================================================================
class PokemonReadyMenu_Scene
  attr_reader :sprites

  def pbStartScene(commands)
    @commands = commands
    @movecommands = []
    @itemcommands = []
    @commands[0].length.times do |i|
      @movecommands.push(@commands[0][i][1])
    end
    @commands[1].length.times do |i|
      @itemcommands.push(@commands[1][i][1])
    end
    @index = $bag.ready_menu_selection
    if @index[0] >= @movecommands.length && @movecommands.length > 0
      @index[0] = @movecommands.length - 1
    end
    if @index[1] >= @itemcommands.length && @itemcommands.length > 0
      @index[1] = @itemcommands.length - 1
    end
    if @index[2] == 0 && @movecommands.length == 0
      @index[2] = 1
    elsif @index[2] == 1 && @itemcommands.length == 0
      @index[2] = 0
    end
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["cmdwindow"] = Window_CommandPokemon.new((@index[2] == 0) ? @movecommands : @itemcommands)
    @sprites["cmdwindow"].height = 192
    @sprites["cmdwindow"].visible = false
    @sprites["cmdwindow"].viewport = @viewport
    @commands[0].length.times do |i|
      @sprites["movebutton#{i}"] = ReadyMenuButton.new(i, @commands[0][i], @index[0], @index[2], @viewport)
    end
    @commands[1].length.times do |i|
      @sprites["itembutton#{i}"] = ReadyMenuButton.new(i, @commands[1][i], @index[1], @index[2], @viewport)
    end
    pbSEPlay("GUI menu open")
  end

  def pbShowMenu
    @sprites["cmdwindow"].visible = false
    @commands[0].length.times do |i|
      @sprites["movebutton#{i}"].visible = true
    end
    @commands[1].length.times do |i|
      @sprites["itembutton#{i}"].visible = true
    end
  end

  def pbHideMenu
    @sprites["cmdwindow"].visible = false
    @commands[0].length.times do |i|
      @sprites["movebutton#{i}"].visible = false
    end
    @commands[1].length.times do |i|
      @sprites["itembutton#{i}"].visible = false
    end
  end

  def pbShowCommands
    ret = -1
    cmdwindow = @sprites["cmdwindow"]
    cmdwindow.commands = (@index[2] == 0) ? @movecommands : @itemcommands
    cmdwindow.index    = @index[@index[2]]
    cmdwindow.visible  = false
    loop do
      pbUpdate
      if Input.trigger?(Input::LEFT) && @index[2] == 1 && @movecommands.length > 0
        @index[2] = 0
        pbChangeSide
      elsif Input.trigger?(Input::RIGHT) && @index[2] == 0 && @itemcommands.length > 0
        @index[2] = 1
        pbChangeSide
      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        ret = -1
        break
      elsif Input.trigger?(Input::USE)
        ret = [@index[2], cmdwindow.index]
        break
      end
    end
    return ret
  end

  def pbEndScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbChangeSide
    @commands[0].length.times do |i|
      @sprites["movebutton#{i}"].side = @index[2]
    end
    @commands[1].length.times do |i|
      @sprites["itembutton#{i}"].side = @index[2]
    end
    @sprites["cmdwindow"].commands = (@index[2] == 0) ? @movecommands : @itemcommands
    @sprites["cmdwindow"].index = @index[@index[2]]
  end

  def pbRefresh; end

  def pbUpdate
    oldindex = @index[@index[2]]
    @index[@index[2]] = @sprites["cmdwindow"].index
    if @index[@index[2]] != oldindex
      case @index[2]
      when 0
        @commands[0].length.times do |i|
          @sprites["movebutton#{i}"].selected = @index[@index[2]]
        end
      when 1
        @commands[1].length.times do |i|
          @sprites["itembutton#{i}"].selected = @index[@index[2]]
        end
      end
    end
    pbUpdateSpriteHash(@sprites)
    Graphics.update
    Input.update
    pbUpdateSceneMap
  end
end

#===============================================================================
#
#===============================================================================
class PokemonReadyMenu
  def initialize(scene)
    @scene = scene
  end

  def pbHideMenu
    @scene.pbHideMenu
  end

  def pbShowMenu
    @scene.pbRefresh
    @scene.pbShowMenu
  end

  def pbStartReadyMenu(moves, items)
    commands = [[], []]   # Moves, items
    moves.each do |i|
      commands[0].push([i[0], GameData::Move.get(i[0]).name, true, i[1]])
    end
    commands[0].sort! { |a, b| a[1] <=> b[1] }
    items.each do |i|
      commands[1].push([i, GameData::Item.get(i).name, false])
    end
    commands[1].sort! { |a, b| a[1] <=> b[1] }
    @scene.pbStartScene(commands)
    loop do
      command = @scene.pbShowCommands
      break if command == -1
      if command[0] == 0   # Use a move
        move = commands[0][command[1]][0]
        user = $player.party[commands[0][command[1]][3]]
        if move == :FLY
          ret = nil
          pbFadeOutInWithUpdate(99999, @scene.sprites) do
            pbHideMenu
            scene = PokemonRegionMap_Scene.new(-1, false)
            screen = PokemonRegionMapScreen.new(scene)
            ret = screen.pbStartFlyScreen
            pbShowMenu if !ret
          end
          if ret
            $game_temp.fly_destination = ret
            $game_temp.in_menu = false
            pbUseHiddenMove(user, move)
            break
          end
        else
          pbHideMenu
          if pbConfirmUseHiddenMove(user, move)
            $game_temp.in_menu = false
            pbUseHiddenMove(user, move)
            break
          else
            pbShowMenu
          end
        end
      else   # Use an item
        item = commands[1][command[1]][0]
        pbHideMenu
        if ItemHandlers.triggerConfirmUseInField(item)
          $game_temp.in_menu = false
          break if pbUseKeyItemInField(item)
          $game_temp.in_menu = true
        end
      end
      pbShowMenu
    end
    @scene.pbEndScene
  end
end

#===============================================================================
# Using a registered item
#===============================================================================
def pbUseKeyItem
  moves = [:CUT, :DEFOG, :DIG, :DIVE, :FLASH, :FLY, :HEADBUTT, :ROCKCLIMB,
           :ROCKSMASH, :SECRETPOWER, :STRENGTH, :SURF, :SWEETSCENT, :TELEPORT,
           :WATERFALL, :WHIRLPOOL]
  real_moves = []
  moves.each do |move|
    $player.party.each_with_index do |pkmn, i|
      next if pkmn.egg? || !pkmn.hasMove?(move)
      real_moves.push([move, i]) if pbCanUseHiddenMove?(pkmn, move, false)
    end
  end
  real_items = []
  $bag.registered_items.each do |i|
    itm = GameData::Item.get(i).id
    real_items.push(itm) if $bag.has?(itm)
  end
  if real_items.length == 0 && real_moves.length == 0
    pbMessage(_INTL("An item in the Bag can be registered to this key for instant use."))
  else
    $game_temp.in_menu = true
    $game_map.update
    sscene = PokemonReadyMenu_Scene.new
    sscreen = PokemonReadyMenu.new(sscene)
    sscreen.pbStartReadyMenu(real_moves, real_items)
    $game_temp.in_menu = false
  end
end
