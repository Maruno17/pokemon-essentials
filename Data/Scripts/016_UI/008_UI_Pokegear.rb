#===============================================================================
#
#===============================================================================
class PokegearButton < SpriteWrapper

  BASE_COLOR   = Color.new(248, 248, 248)
  SHADOW_COLOR = Color.new(40, 40, 40)

  attr_reader :index
  attr_reader :name
  attr_reader :selected

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
    self.x = x - @button.width/2
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
    height = self.bitmap.text_size(@name).height
    textpos = [
      [@name, rect.width / 2, (rect.height / 2) - height, 2, BASE_COLOR, SHADOW_COLOR]
    ]
    pbDrawTextPositions(self.bitmap, textpos)
    bmp = RPG::Cache.load_bitmap("Graphics/Pictures/Pokegear/", @image) rescue Bitmap.new(32, 32)
    x =  rect.width / 15
    y =  (rect.height - bmp.height) / 2
    self.bitmap.blt(x, y, bmp, Rect.new(0, 0, bmp.width, bmp.height))
    imagepos = [
      ["Graphics/Pictures/Pokegear/icon_" + @image, 18, 10]
    ]
    bmp.dispose
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
    @commands.each_with_index do |command, i|
      @sprites["button#{i}"] = PokegearButton.new(command, Graphics.width / 2, 0, @viewport)
      height = @sprites["button#{i}"].bitmap.height / 2
      y = (Graphics.height / 2) - (@commands.length * height / 2) + (height * i)
      @sprites["button#{i}"].y = y
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
    commands    = []
    display_cmd = []
    endscene    = false
    MenuHandlers::Pokegear.each_available do |option, hash|
      commands.push(option)
      icon = nil_or_empty?(hash["icon"]) ? "" : hash["icon"]
      name = MenuHandlers::Pokegear.get_string_option("name", option)
      display_cmd.push([icon, name])
    end
    @scene.pbStartScene(display_cmd)
    loop do
      command = @scene.pbScene
      break if command < 0
      cmd = commands[command]
      endscene  = MenuHandlers::Pokegear.call("effect", cmd)
      break if endscene
    end
    ($game_temp.fly_destination) ? @scene.dispose : @scene.pbEndScene
  end
end


#===============================================================================
# Module to register and handle commands in the Pokegear
#===============================================================================
module MenuHandlers
  class Pokegear
    extend HandlerMethods

    @commands = HandlerHashBasic.new

  end
end


#===============================================================================
# Individual commands for the Pokegear
#===============================================================================
# Town Map ---------------------------------------------------------------------
MenuHandlers::Pokegear.register("map", {
  "name"        => _INTL("Map"),
  "icon"        => "icon_map",
  "condition"   => proc { next true },
  "priority"    => 30,
  "effect"      => proc {
    pbFadeOutIn {
      scene = PokemonRegionMap_Scene.new(-1, false)
      screen = PokemonRegionMapScreen.new(scene)
      ret = screen.pbStartScreen
      if ret
        $game_temp.fly_destination = ret
        next 99999   # Ugly hack to make Pokégear scene not reappear if flying
      end
    }
    next ($game_temp.fly_destination) ? true : false
  }
})

# Phone ------------------------------------------------------------------------
MenuHandlers::Pokegear.register("phone", {
  "name"        => _INTL("Phone"),
  "icon"        => "icon_phone",
  "priority"    => 20,
  "condition"   => proc {
    next $PokemonGlobal.phoneNumbers && $PokemonGlobal.phoneNumbers.length > 0
  },
  "effect"      => proc {
    pbFadeOutIn { PokemonPhoneScene.new.start }
    next false
  }
})

# Jukebox ----------------------------------------------------------------------
MenuHandlers::Pokegear.register("jukebox", {
  "name"        => _INTL("Jukebox"),
  "icon"        => "icon_jukebox",
  "condition"   => proc { next true },
  "priority"    => 10,
  "effect"      => proc {
    pbFadeOutIn {
      scene = PokemonJukebox_Scene.new
      screen = PokemonJukeboxScreen.new(scene)
      screen.pbStartScreen
    }
    next false
  }
})
