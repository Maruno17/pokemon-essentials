#===============================================================================
#
#===============================================================================
class PokemonTrainerCard_Scene
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    background = pbResolveBitmap("Graphics/UI/Trainer Card/bg_f")
    if $player.female? && background
      addBackgroundPlane(@sprites, "bg", "Trainer Card/bg_f", @viewport)
    else
      addBackgroundPlane(@sprites, "bg", "Trainer Card/bg", @viewport)
    end
    cardexists = pbResolveBitmap(_INTL("Graphics/UI/Trainer Card/card_f"))
    @sprites["card"] = IconSprite.new(0, 0, @viewport)
    if $player.female? && cardexists
      @sprites["card"].setBitmap(_INTL("Graphics/UI/Trainer Card/card_f"))
    else
      @sprites["card"].setBitmap(_INTL("Graphics/UI/Trainer Card/card"))
    end
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["trainer"] = IconSprite.new(336, 112, @viewport)
    @sprites["trainer"].setBitmap(GameData::TrainerType.player_front_sprite_filename($player.trainer_type))
    @sprites["trainer"].x -= (@sprites["trainer"].bitmap.width - 128) / 2
    @sprites["trainer"].y -= (@sprites["trainer"].bitmap.height - 128)
    @sprites["trainer"].z = 2
    pbDrawTrainerCardFront
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbDrawTrainerCardFront
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    baseColor   = Color.new(72, 72, 72)
    shadowColor = Color.new(160, 160, 160)
    totalsec = $stats.play_time.to_i
    hour = totalsec / 60 / 60
    min = totalsec / 60 % 60
    time = (hour > 0) ? _INTL("{1}h {2}m", hour, min) : _INTL("{1}m", min)
    $PokemonGlobal.startTime = Time.now if !$PokemonGlobal.startTime
    starttime = _INTL("{1} {2}, {3}",
                      pbGetAbbrevMonthName($PokemonGlobal.startTime.mon),
                      $PokemonGlobal.startTime.day,
                      $PokemonGlobal.startTime.year)
    textPositions = [
      [_INTL("Name"), 34, 70, :left, baseColor, shadowColor],
      [$player.name, 302, 70, :right, baseColor, shadowColor],
      [_INTL("ID No."), 332, 70, :left, baseColor, shadowColor],
      [sprintf("%05d", $player.public_ID), 468, 70, :right, baseColor, shadowColor],
      [_INTL("Money"), 34, 118, :left, baseColor, shadowColor],
      [_INTL("${1}", $player.money.to_s_formatted), 302, 118, :right, baseColor, shadowColor],
      [_INTL("Pokédex"), 34, 166, :left, baseColor, shadowColor],
      [sprintf("%d/%d", $player.pokedex.owned_count, $player.pokedex.seen_count), 302, 166, :right, baseColor, shadowColor],
      [_INTL("Time"), 34, 214, :left, baseColor, shadowColor],
      [time, 302, 214, :right, baseColor, shadowColor],
      [_INTL("Started"), 34, 262, :left, baseColor, shadowColor],
      [starttime, 302, 262, :right, baseColor, shadowColor]
    ]
    pbDrawTextPositions(overlay, textPositions)
    x = 72
    region = pbGetCurrentRegion(0) # Get the current region
    imagePositions = []
    8.times do |i|
      if $player.badges[i + (region * 8)]
        imagePositions.push(["Graphics/UI/Trainer Card/icon_badges", x, 310, i * 32, region * 32, 32, 32])
      end
      x += 48
    end
    pbDrawImagePositions(overlay, imagePositions)
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
