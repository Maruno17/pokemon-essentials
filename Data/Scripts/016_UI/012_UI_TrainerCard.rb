#===============================================================================
#
#===============================================================================
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
    is_postgame = $game_switches[SWITCH_BEAT_THE_LEAGUE]
    if $Trainer.female? && cardexists
      path = "Graphics/Pictures/Trainer Card/card_f"
      if is_postgame
        path+="_postgame"
      end
      @sprites["card"].setBitmap(path)
    else
      path = "Graphics/Pictures/Trainer Card/card"
      if is_postgame
        path+="_postgame"
      end
      @sprites["card"].setBitmap(path)
    end
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["trainer"] = IconSprite.new(336,112,@viewport)
    @sprites["trainer"].setBitmap(GameData::TrainerType.player_front_sprite_filename($Trainer.trainer_type))
    @sprites["trainer"].x -= (@sprites["trainer"].bitmap.width-128)/2
    @sprites["trainer"].y -= (@sprites["trainer"].bitmap.height-128)
    @sprites["trainer"].z = 2
    pbDrawTrainerCardFront
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
       [_INTL("Name"),34,58,0,baseColor,shadowColor],
       [$Trainer.name,302,58,1,baseColor,shadowColor],
       [_INTL("ID No."),332,58,0,baseColor,shadowColor],
       [sprintf("%05d",$Trainer.public_ID),468,58,1,baseColor,shadowColor],
       [_INTL("Money"),34,106,0,baseColor,shadowColor],
       [_INTL("${1}",$Trainer.money.to_s_formatted),302,106,1,baseColor,shadowColor],
       [_INTL("Pokédex"),34,154,0,baseColor,shadowColor],
       [sprintf("%d/%d",$Trainer.pokedex.owned_count,$Trainer.pokedex.seen_count),302,154,1,baseColor,shadowColor],
       [_INTL("Time"),34,202,0,baseColor,shadowColor],
       [time,302,202,1,baseColor,shadowColor],
       [_INTL("Started"),34,250,0,baseColor,shadowColor],
       [starttime,302,250,1,baseColor,shadowColor]
    ]
    pbDrawTextPositions(overlay,textPositions)
    x = 72
    imagePositions = []
    postgame = $game_switches[SWITCH_BEAT_THE_LEAGUE]
    numberOfBadgesDisplayed = postgame ? 16 : 8
    for i in 0...numberOfBadgesDisplayed
      badgeRow= i<8 ? 0 : 1
      if $Trainer.badges[i]
        if i == 8
          x =72
        end
        badge_graphic_x = badgeRow == 0 ? i*32 : (i-8)*32
        badge_graphic_y =badgeRow*32
        y = getBadgeDisplayHeight(postgame,i)
        imagePositions.push(["Graphics/Pictures/Trainer Card/icon_badges",x,y,badge_graphic_x,badge_graphic_y,32,32])
      end
      x += 48
    end
    pbDrawImagePositions(overlay,imagePositions)
  end

  def getBadgeDisplayHeight(postgame,i)
    if postgame
      if i < 8
        y=310
      else
        y=344
      end
    else
      y = 312
    end
    return y
  end

  def pbTrainerCard
    pbSEPlay("GUI trainer card open")
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::BACK)
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

#===============================================================================
#
#===============================================================================
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
