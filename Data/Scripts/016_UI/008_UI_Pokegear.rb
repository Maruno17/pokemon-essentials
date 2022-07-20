#===============================================================================
#
#===============================================================================
class PokegearButton < Sprite
  attr_reader :index
  attr_reader :name
  attr_reader :selected

  TEXT_BASE_COLOR = Color.new(248, 248, 248)
  TEXT_SHADOW_COLOR = Color.new(40, 40, 40)

  def initialize(command, x, y, viewport = nil)
    super(viewport)
    @image = command[0]
    @name  = command[1]
    @selected = false
    if $player.female? && pbResolveBitmap(sprintf("Graphics/Pictures/Pokegear/icon_button_f"))
      @button = AnimatedBitmap.new("Graphics/Pictures/Pokegear/icon_button_f")
    else
      @button = AnimatedBitmap.new("Graphics/Pictures/Pokegear/icon_button")
    end
    @contents = BitmapWrapper.new(@button.width, @button.height)
    self.bitmap = @contents
    self.x = x - (@button.width / 2)
    self.y = y
    pbSetSystemFont(self.bitmap)
    refresh
  end

  def dispose
    @button.dispose
    @contents.dispose
    super
  end

  def selected=(val)
    oldsel = @selected
    @selected = val
    refresh if oldsel != val
  end

  def refresh
    self.bitmap.clear
    rect = Rect.new(0, 0, @button.width, @button.height / 2)
    rect.y = @button.height / 2 if @selected
    self.bitmap.blt(0, 0, @button.bitmap, rect)
    textpos = [
      [@name, rect.width / 2, (rect.height / 2) - 10, 2, TEXT_BASE_COLOR, TEXT_SHADOW_COLOR]
    ]
    pbDrawTextPositions(self.bitmap, textpos)
    imagepos = [
      [sprintf("Graphics/Pictures/Pokegear/icon_" + @image), 18, 10]
    ]
    pbDrawImagePositions(self.bitmap, imagepos)
  end
end

#===============================================================================
#
#===============================================================================
class PokemonPokegear_Scene
  def pbUpdate
    @commands.length.times do |i|
      @sprites["button#{i}"].selected = (i == @index)
    end
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(commands)
    @commands = commands
    @index = 0
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    if $player.female? && pbResolveBitmap(sprintf("Graphics/Pictures/Pokegear/bg_f"))
      @sprites["background"].setBitmap("Graphics/Pictures/Pokegear/bg_f")
    else
      @sprites["background"].setBitmap("Graphics/Pictures/Pokegear/bg")
    end
    @commands.length.times do |i|
      @sprites["button#{i}"] = PokegearButton.new(@commands[i], Graphics.width / 2, 0, @viewport)
      button_height = @sprites["button#{i}"].bitmap.height / 2
      @sprites["button#{i}"].y = ((Graphics.height - (@commands.length * button_height)) / 2) + (i * button_height)
    end
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbScene
    ret = -1
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        ret = @index
        break
      elsif Input.trigger?(Input::UP)
        pbPlayCursorSE if @commands.length > 1
        @index -= 1
        @index = @commands.length - 1 if @index < 0
      elsif Input.trigger?(Input::DOWN)
        pbPlayCursorSE if @commands.length > 1
        @index += 1
        @index = 0 if @index >= @commands.length
      end
    end
    return ret
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    dispose
  end

  def dispose
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

#===============================================================================
#
#===============================================================================
class PokemonPokegearScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    # Get all commands
    command_list = []
    commands = []
    MenuHandlers.each_available(:pokegear_menu) do |option, hash, name|
      command_list.push([hash["icon_name"] || "", name])
      commands.push(hash)
    end
    @scene.pbStartScene(command_list)
    # Main loop
    end_scene = false
    loop do
      choice = @scene.pbScene
      if choice < 0
        end_scene = true
        break
      end
      break if commands[choice]["effect"].call(@scene)
    end
    @scene.pbEndScene if end_scene
  end
end

#===============================================================================
#
#===============================================================================
MenuHandlers.add(:pokegear_menu, :map, {
  "name"      => _INTL("Map"),
  "icon_name" => "map",
  "order"     => 10,
  "effect"    => proc { |menu|
    pbFadeOutIn {
      scene = PokemonRegionMap_Scene.new(-1, false)
      screen = PokemonRegionMapScreen.new(scene)
      ret = screen.pbStartScreen
      if ret
        $game_temp.fly_destination = ret
        menu.dispose
        next 99999
      end
    }
    next $game_temp.fly_destination
  }
})

MenuHandlers.add(:pokegear_menu, :phone, {
  "name"      => _INTL("Phone"),
  "icon_name" => "phone",
  "order"     => 20,
  "condition" => proc { next $PokemonGlobal.phoneNumbers && $PokemonGlobal.phoneNumbers.length > 0 },
  "effect"    => proc { |menu|
    pbFadeOutIn { PokemonPhoneScene.new.start }
    next false
  }
})

MenuHandlers.add(:pokegear_menu, :jukebox, {
  "name"      => _INTL("Jukebox"),
  "icon_name" => "jukebox",
  "order"     => 30,
  "effect"    => proc { |menu|
    pbFadeOutIn {
      scene = PokemonJukebox_Scene.new
      screen = PokemonJukeboxScreen.new(scene)
      screen.pbStartScreen
    }
    next false
  }
})
