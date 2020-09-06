class IntroEventScene < EventScene
  TICKS_PER_PIC         = 40   # 20 ticks per second, so 2 seconds
  TICKS_PER_ENTER_FLASH = 40
  FADE_TICKS            = 8

  def initialize(pics,splash,_viewport=nil)
    super(nil)
    @pics   = pics
    @splash = splash
    @pic = addImage(0,0,"")
    @pic.setOpacity(0,0)    # set opacity to 0 after waiting 0 frames
    @pic2 = addImage(0,0,"")   # flashing "Press Enter" picture
    @pic2.setOpacity(0,0)
    @index = 0
    data_system = pbLoadRxData("Data/System")
    pbBGMPlay(data_system.title_bgm)
    openPic(self,nil)
  end

  def openPic(_scene,*args)
    onCTrigger.clear
    @pic.name = "Graphics/Titles/"+@pics[@index]
    # fade to opacity 255 in FADE_TICKS ticks after waiting 0 frames
    @pic.moveOpacity(0,FADE_TICKS,255)
    pictureWait
    @timer = 0                          # reset the timer
    onUpdate.set(method(:picUpdate))    # call picUpdate every frame
    onCTrigger.set(method(:closePic))   # call closePic when C key is pressed
  end

  def closePic(scene,args)
    onUpdate.clear
    onCTrigger.clear
    @pic.moveOpacity(0,FADE_TICKS,0)
    pictureWait
    @index += 1   # Move to the next picture
    if @index>=@pics.length
      openSplash(scene,args)
    else
      openPic(scene,args)
    end
  end

  def picUpdate(scene,args)
    @timer += 1
    if @timer>TICKS_PER_PIC*Graphics.frame_rate/20
      @timer = 0
      closePic(scene,args)   # Close the picture
    end
  end

  def openSplash(_scene,*args)
    onUpdate.clear
    onCTrigger.clear
    @pic.name = "Graphics/Titles/"+@splash
    @pic.moveOpacity(0,FADE_TICKS,255)
    @pic2.name = "Graphics/Titles/start"
    @pic2.setXY(0,0,322)
    @pic2.setVisible(0,true)
    @pic2.moveOpacity(0,FADE_TICKS,255)
    pictureWait
    onUpdate.set(method(:splashUpdate))    # call splashUpdate every frame
    onCTrigger.set(method(:closeSplash))   # call closeSplash when C key is pressed
  end

  def closeSplash(scene,*args)
    onUpdate.clear
    onCTrigger.clear
    # Play random cry
    cry = pbCryFile(1+rand(PBSpecies.maxValue))
    pbSEPlay(cry,80,100) if cry
    @pic.moveXY(0,20,0,0)
    pictureWait
    # Fade out
    @pic.moveOpacity(0,FADE_TICKS,0)
    @pic2.clearProcesses
    @pic2.moveOpacity(0,FADE_TICKS,0)
    pbBGMStop(1.0)
    pictureWait
    scene.dispose   # Close the scene
    sscene = PokemonLoad_Scene.new
    sscreen = PokemonLoadScreen.new(sscene)
    sscreen.pbStartLoadScreen
  end

  def closeSplashDelete(scene,*args)
    onUpdate.clear
    onCTrigger.clear
    # Play random cry
    cry = pbCryFile(1+rand(PBSpecies.maxValue))
    pbSEPlay(cry,80,100) if cry
    @pic.moveXY(0,20,0,0)
    pictureWait
    # Fade out
    @pic.moveOpacity(0,FADE_TICKS,0)
    @pic2.clearProcesses
    @pic2.moveOpacity(0,FADE_TICKS,0)
    pbBGMStop(1.0)
    pictureWait
    scene.dispose   # Close the scene
    sscene = PokemonLoad_Scene.new
    sscreen = PokemonLoadScreen.new(sscene)
    sscreen.pbStartDeleteScreen
  end

  def splashUpdate(scene,args)
    # Flashing of "Press Enter" picture
    if !@pic2.running?
      @pic2.moveOpacity(TICKS_PER_ENTER_FLASH*2/10,TICKS_PER_ENTER_FLASH*4/10,0)
      @pic2.moveOpacity(TICKS_PER_ENTER_FLASH*6/10,TICKS_PER_ENTER_FLASH*4/10,255)
    end
    if Input.press?(Input::DOWN) &&
       Input.press?(Input::B) &&
       Input.press?(Input::CTRL)
      closeSplashDelete(scene,args)
    end
  end
end



class Scene_Intro
  def initialize(pics, splash = nil)
    @pics   = pics
    @splash = splash
  end

  def main
    Graphics.transition(0)
    @eventscene = IntroEventScene.new(@pics,@splash)
    @eventscene.main
    Graphics.freeze
  end
end
