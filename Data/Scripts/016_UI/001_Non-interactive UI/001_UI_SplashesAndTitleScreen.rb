#===============================================================================
#
#===============================================================================
class IntroEventScene < EventScene
  # Splash screen images that appear for a few seconds and then disappear.
  SPLASH_IMAGES         = ["splash1", "splash2"]
  # The main title screen background image.
  TITLE_BG_IMAGE        = "title"
  TITLE_START_IMAGE     = "start"
  TITLE_START_IMAGE_X   = 0
  TITLE_START_IMAGE_Y   = 322
  SECONDS_PER_SPLASH    = 2
  TICKS_PER_ENTER_FLASH = 40   # 20 ticks per second
  FADE_TICKS            = 8    # 20 ticks per second

  def initialize(viewport = nil)
    super(viewport)
    @pic = addImage(0, 0, "")
    @pic.setOpacity(0, 0)        # set opacity to 0 after waiting 0 frames
    @pic2 = addImage(0, 0, "")   # flashing "Press Enter" picture
    @pic2.setOpacity(0, 0)       # set opacity to 0 after waiting 0 frames
    @index = 0
    if SPLASH_IMAGES.empty?
      open_title_screen(self, nil)
    else
      open_splash(self, nil)
    end
  end

  def open_splash(_scene, *args)
    onCTrigger.clear
    @pic.name = "Graphics/Titles/" + SPLASH_IMAGES[@index]
    # fade to opacity 255 in FADE_TICKS ticks after waiting 0 frames
    @pic.moveOpacity(0, FADE_TICKS, 255)
    pictureWait
    @timer = System.uptime                  # reset the timer
    onUpdate.set(method(:splash_update))    # called every frame
    onCTrigger.set(method(:close_splash))   # called when C key is pressed
  end

  def close_splash(scene, args)
    onUpdate.clear
    onCTrigger.clear
    @pic.moveOpacity(0, FADE_TICKS, 0)
    pictureWait
    @index += 1   # Move to the next picture
    if @index >= SPLASH_IMAGES.length
      open_title_screen(scene, args)
    else
      open_splash(scene, args)
    end
  end

  def splash_update(scene, args)
    close_splash(scene, args) if System.uptime - @timer >= SECONDS_PER_SPLASH
  end

  def open_title_screen(_scene, *args)
    onUpdate.clear
    onCTrigger.clear
    @pic.name = "Graphics/Titles/" + TITLE_BG_IMAGE
    @pic.moveOpacity(0, FADE_TICKS, 255)
    @pic2.name = "Graphics/Titles/" + TITLE_START_IMAGE
    @pic2.setXY(0, TITLE_START_IMAGE_X, TITLE_START_IMAGE_Y)
    @pic2.setVisible(0, true)
    @pic2.moveOpacity(0, FADE_TICKS, 255)
    pictureWait
    pbBGMPlay($data_system.title_bgm)
    onUpdate.set(method(:title_screen_update))    # called every frame
    onCTrigger.set(method(:close_title_screen))   # called when C key is pressed
  end

  def fade_out_title_screen(scene)
    onUpdate.clear
    onCTrigger.clear
    # Play random cry
    species_keys = GameData::Species.keys
    species_data = GameData::Species.get(species_keys.sample)
    Pokemon.play_cry(species_data.species, species_data.form)
    @pic.moveXY(0, 20, 0, 0)   # Adds 20 ticks (1 second) pause
    pictureWait
    # Fade out
    @pic.moveOpacity(0, FADE_TICKS, 0)
    @pic2.clearProcesses
    @pic2.moveOpacity(0, FADE_TICKS, 0)
    pbBGMStop(1.0)
    pictureWait
    scene.dispose   # Close the scene
  end

  def close_title_screen(scene, *args)
    fade_out_title_screen(scene)
    sscene = PokemonLoad_Scene.new
    sscreen = PokemonLoadScreen.new(sscene)
    sscreen.pbStartLoadScreen
  end

  def close_title_screen_delete(scene, *args)
    fade_out_title_screen(scene)
    sscene = PokemonLoad_Scene.new
    sscreen = PokemonLoadScreen.new(sscene)
    sscreen.pbStartDeleteScreen
  end

  def title_screen_update(scene, args)
    # Flashing of "Press Enter" picture
    if !@pic2.running?
      @pic2.moveOpacity(TICKS_PER_ENTER_FLASH * 2 / 10, TICKS_PER_ENTER_FLASH * 4 / 10, 0)
      @pic2.moveOpacity(TICKS_PER_ENTER_FLASH * 6 / 10, TICKS_PER_ENTER_FLASH * 4 / 10, 255)
    end
    if Input.press?(Input::DOWN) &&
       Input.press?(Input::BACK) &&
       Input.press?(Input::CTRL)
      close_title_screen_delete(scene, args)
    end
  end
end

#===============================================================================
#
#===============================================================================
class Scene_Intro
  def main
    Graphics.transition(0)
    @eventscene = IntroEventScene.new
    @eventscene.main
    Graphics.freeze
  end
end
