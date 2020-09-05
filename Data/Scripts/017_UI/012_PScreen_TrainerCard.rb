class PokemonTrainerCard_Scene
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    background = pbResolveBitmap(sprintf("Graphics/Pictures/Trainer Card/bg_f"))
    if $Trainer.female? && background
      addBackgroundPlane(@sprites,"bg","Trainer Card/bg_f",@viewport)
    else
      addBackgroundPlane(@sprites,"bg","Trainer Card/bg",@viewport)
    end
    cardexists = pbResolveBitmap(sprintf("Graphics/Pictures/Trainer Card/card_f"))
    @sprites["card"] = IconSprite.new(0,0,@viewport)
    if $Trainer.female? && cardexists
      @sprites["card"].setBitmap("Graphics/Pictures/Trainer Card/card_f")
    else
      @sprites["card"].setBitmap("Graphics/Pictures/Trainer Card/card")
    end
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["trainer"] = IconSprite.new(336,112,@viewport)
    @sprites["trainer"].setBitmap(pbPlayerSpriteFile($Trainer.trainertype))
    @sprites["trainer"].x -= (@sprites["trainer"].bitmap.width-128)/2
    @sprites["trainer"].y -= (@sprites["trainer"].bitmap.height-128)
    @sprites["trainer"].z = 2
    pbDrawTrainerCardFront
    if $PokemonGlobal.trainerRecording
      $PokemonGlobal.trainerRecording.play
    end
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbDrawTrainerCardFront
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    baseColor   = Color.new(72,72,72)
    shadowColor = Color.new(160,160,160)
    totalsec = Graphics.frame_count / Graphics.frame_rate
    hour = totalsec / 60 / 60
    min = totalsec / 60 % 60
    time = (hour>0) ? _INTL("{1}h {2}m",hour,min) : _INTL("{1}m",min)
    $PokemonGlobal.startTime = pbGetTimeNow if !$PokemonGlobal.startTime
    starttime = _INTL("{1} {2}, {3}",
       pbGetAbbrevMonthName($PokemonGlobal.startTime.mon),
       $PokemonGlobal.startTime.day,
       $PokemonGlobal.startTime.year)
    textPositions = [
       [_INTL("Name"),34,64,0,baseColor,shadowColor],
       [$Trainer.name,302,64,1,baseColor,shadowColor],
       [_INTL("ID No."),332,64,0,baseColor,shadowColor],
       [sprintf("%05d",$Trainer.publicID($Trainer.id)),468,64,1,baseColor,shadowColor],
       [_INTL("Money"),34,112,0,baseColor,shadowColor],
       [_INTL("${1}",$Trainer.money.to_s_formatted),302,112,1,baseColor,shadowColor],
       [_INTL("Pokédex"),34,160,0,baseColor,shadowColor],
       [sprintf("%d/%d",$Trainer.pokedexOwned,$Trainer.pokedexSeen),302,160,1,baseColor,shadowColor],
       [_INTL("Time"),34,208,0,baseColor,shadowColor],
       [time,302,208,1,baseColor,shadowColor],
       [_INTL("Started"),34,256,0,baseColor,shadowColor],
       [starttime,302,256,1,baseColor,shadowColor]
    ]
    pbDrawTextPositions(overlay,textPositions)
    x = 72
    region = pbGetCurrentRegion(0) # Get the current region
    imagePositions = []
    for i in 0...8
      if $Trainer.badges[i+region*8]
        imagePositions.push(["Graphics/Pictures/Trainer Card/icon_badges",x,310,i*32,region*32,32,32])
      end
      x += 48
    end
    pbDrawImagePositions(overlay,imagePositions)
  end

  def pbTrainerCard
    pbSEPlay("GUI trainer card open")
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::B)
        pbPlayCloseMenuSE
        break
      end
    end
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end



class PokemonTrainerCardScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbTrainerCard
    @scene.pbEndScene
  end
end
