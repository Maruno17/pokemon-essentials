#===============================================================================
# Base class for all hardcoded battle animations.
#===============================================================================
class Battle::Scene::Animation
  def initialize(sprites, viewport)
    @sprites  = sprites
    @viewport = viewport
    @pictureEx      = []   # For all the PictureEx
    @pictureSprites = []   # For all the sprites
    @tempSprites    = []   # For sprites that exist only for this animation
    @animDone       = false
    createProcesses
  end

  def dispose
    @tempSprites.each { |s| s&.dispose }
  end

  def createProcesses; end
  def empty?; return @pictureEx.length == 0; end
  def animDone?; return @animDone; end

  def addSprite(s, origin = PictureOrigin::TOP_LEFT)
    num = @pictureEx.length
    picture = PictureEx.new(s.z)
    picture.x       = s.x
    picture.y       = s.y
    picture.visible = s.visible
    picture.color   = s.color.clone
    picture.tone    = s.tone.clone
    picture.setOrigin(0, origin)
    @pictureEx[num] = picture
    @pictureSprites[num] = s
    return picture
  end

  def addNewSprite(x, y, name, origin = PictureOrigin::TOP_LEFT)
    num = @pictureEx.length
    picture = PictureEx.new(num)
    picture.setXY(0, x, y)
    picture.setName(0, name)
    picture.setOrigin(0, origin)
    @pictureEx[num] = picture
    s = IconSprite.new(x, y, @viewport)
    s.setBitmap(name)
    @pictureSprites[num] = s
    @tempSprites.push(s)
    return picture
  end

  def update
    return if @animDone
    @tempSprites.each { |s| s&.update }
    finished = true
    @pictureEx.each_with_index do |p, i|
      next if !p.running?
      finished = false
      p.update
      setPictureIconSprite(@pictureSprites[i], p)
    end
    @animDone = true if finished
  end
end

#===============================================================================
# Mixin module for certain hardcoded battle animations that involve Poké Balls.
#===============================================================================
module Battle::Scene::Animation::BallAnimationMixin
  # Returns the color that the Pokémon turns when it goes into or out of its
  # Poké Ball.
  def getBattlerColorFromPokeBall(poke_ball)
    case poke_ball
    when :GREATBALL   then return Color.new(132, 189, 247)
    when :SAFARIBALL  then return Color.new(189, 247, 165)
    when :ULTRABALL   then return Color.new(255, 255, 123)
    when :MASTERBALL  then return Color.new(189, 165, 231)
    when :NETBALL     then return Color.new(173, 255, 206)
    when :DIVEBALL    then return Color.new(99, 206, 247)
    when :NESTBALL    then return Color.new(247, 222,  82)
    when :REPEATBALL  then return Color.new(255, 198, 132)
    when :TIMERBALL   then return Color.new(239, 247, 247)
    when :LUXURYBALL  then return Color.new(255, 140,  82)
    when :PREMIERBALL then return Color.new(255,  74,  82)
    when :DUSKBALL    then return Color.new(115, 115, 140)
    when :HEALBALL    then return Color.new(255, 198, 231)
    when :QUICKBALL   then return Color.new(140, 214, 255)
    when :CHERISHBALL then return Color.new(247,  66,  41)
    end
    return Color.new(255, 181, 247)   # Poké Ball, Sport Ball, Apricorn Balls, others
  end

  def addBallSprite(ballX, ballY, poke_ball)
    file_path = sprintf("Graphics/Battle animations/ball_%s", poke_ball)
    ball = addNewSprite(ballX, ballY, file_path, PictureOrigin::CENTER)
    @ballSprite = @pictureSprites.last
    if @ballSprite.bitmap.width >= @ballSprite.bitmap.height
      @ballSprite.src_rect.width = @ballSprite.bitmap.height / 2
      ball.setSrcSize(0, @ballSprite.bitmap.height / 2, @ballSprite.bitmap.height)
    end
    return ball
  end

  def ballTracksHand(ball, traSprite, safariThrow = false)
    # Back sprite isn't animated, no hand-tracking needed
    if traSprite.bitmap.width < traSprite.bitmap.height * 2
      ball.setVisible(7, true)
      ballStartX = traSprite.x
      ballStartX -= ball.totalDuration * (Graphics.width / (2 * 16)) if !safariThrow
      ballStartY = traSprite.y - (traSprite.bitmap.height / 2)
      return ballStartX, ballStartY
    end
    # Back sprite is animated, make the Poké Ball track the trainer's hand
    coordSets = [[traSprite.x - 44, traSprite.y - 32], [-10, -36], [118, -4]]
    case @trainer.trainer_type
    when :POKEMONTRAINER_Leaf
      coordSets = [[traSprite.x - 30, traSprite.y - 30], [-18, -36], [118, -6]]
    when :POKEMONTRAINER_Brendan
      coordSets = [[traSprite.x - 46, traSprite.y - 40], [-4, -30], [118, -2]]
    when :POKEMONTRAINER_May
      coordSets = [[traSprite.x - 44, traSprite.y - 38], [-8, -30], [122, 0]]
    end
    # Arm stretched out behind player
    ball.setVisible(0, true)
    ball.setXY(0, coordSets[0][0], coordSets[0][1])
    ball.moveDelta(0, 5, -5 * (Graphics.width / (2 * 16)), 0) if !safariThrow
    ball.setDelta(0, -12, 0) if safariThrow
    # Arm mid throw
    ball.setDelta(5, coordSets[1][0], coordSets[1][1])
    ball.moveDelta(5, 2, -2 * (Graphics.width / (2 * 16)), 0) if !safariThrow
    ball.setDelta(5, 34, 0) if safariThrow
    # Start of throw
    ball.setDelta(7, coordSets[2][0], coordSets[2][1])
    ball.setDelta(7, -14, 0) if safariThrow
    # Update Poké Ball trajectory's start position
    ballStartX = ballStartY = 0
    coordSets.each do |c|
      ballStartX += c[0]
      ballStartY += c[1]
    end
    ballStartX -= ball.totalDuration * (Graphics.width / (2 * 16)) if !safariThrow
    ballStartX += 8 if safariThrow   # -12 + 34 - 14
    return ballStartX, ballStartY
  end

  def trainerThrowingFrames(ball, trainer, traSprite)
    ball.setZ(0, traSprite.z - 1)
    # Change trainer's frames
    size = traSprite.src_rect.width   # Width per frame
    trainer.setSrc(0, size, 0)
    trainer.setSrc(5, size * 2, 0)
    trainer.setSrc(7, size * 3, 0)
    trainer.setSrc(9, size * 4, 0)
    trainer.setSrc(18, 0, 0)
    # Alter trainer's positioning
    trainer.setDelta(0, -12, 0)
    trainer.setDelta(5, 34, 0)
    trainer.setDelta(7, -14, 0)
    trainer.setDelta(9, 28, 0)
    trainer.moveDelta(10, 3, -6, 6)
    trainer.setDelta(18, -4, 0)
    trainer.setDelta(19, -26, -6)
    # Make ball track the trainer's hand
    ballStartX, ballStartY = ballTracksHand(ball, traSprite, true)
    return ballStartX, ballStartY
  end

  def createBallTrajectory(ball, delay, duration, startX, startY, midX, midY, endX, endY)
    # NOTE: This trajectory is the same regardless of whether the player's
    #       sprite is being shown on-screen (and sliding off while animating a
    #       throw). Instead, that throw animation and initialDelay are designed
    #       to make sure the Ball's trajectory starts at the same position.
    ball.setVisible(delay, true)
    a = (2 * startY) - (4 * midY) + (2 * endY)
    b = (4 * midY) - (3 * startY) - endY
    c = startY
    (1..duration).each do |i|
      t = i.to_f / duration                # t ranges from 0 to 1
      x = startX + ((endX - startX) * t)   # Linear in t
      y = (a * (t**2)) + (b * t) + c       # Quadratic in t
      ball.moveXY(delay + i - 1, 1, x, y)
    end
    createBallTumbling(ball, delay, duration)
  end

  def createBallTumbling(ball, delay, duration)
    # Animate ball frames
    numTumbles = 1
    numFrames  = 1
    if @ballSprite && @ballSprite.bitmap.width >= @ballSprite.bitmap.height
      # 2* because each frame is twice as tall as it is wide
      numFrames = 2 * @ballSprite.bitmap.width / @ballSprite.bitmap.height
    end
    if numFrames > 1
      curFrame = 0
      (1..duration).each do |i|
        thisFrame = numFrames * numTumbles * i / duration
        if thisFrame > curFrame
          curFrame = thisFrame
          ball.setSrc(delay + i - 1, (curFrame % numFrames) * @ballSprite.bitmap.height / 2, 0)
        end
      end
      ball.setSrc(delay + duration, 0, 0)
    end
    # Rotate ball
    ball.moveAngle(delay, duration, 360 * 3)
    ball.setAngle(delay + duration, 0)
  end

  def ballSetOpen(ball, delay, poke_ball)
    file_path = sprintf("Graphics/Battle animations/ball_%s_open", poke_ball)
    ball.setName(delay, file_path)
    if @ballSprite && @ballSprite.bitmap.width >= @ballSprite.bitmap.height
      ball.setSrcSize(delay, @ballSprite.bitmap.height / 2, @ballSprite.bitmap.height)
    end
  end

  def ballSetClosed(ball, delay, poke_ball)
    file_path = sprintf("Graphics/Battle animations/ball_%s", poke_ball)
    ball.setName(delay, file_path)
    if @ballSprite && @ballSprite.bitmap.width >= @ballSprite.bitmap.height
      ball.setSrcSize(delay, @ballSprite.bitmap.height / 2, @ballSprite.bitmap.height)
    end
  end

  def ballOpenUp(ball, delay, poke_ball, showSquish = true, playSE = true)
    if showSquish
      ball.moveZoomXY(delay, 1, 120, 80)   # Squish
      ball.moveZoom(delay + 5, 1, 100)     # Unsquish
      delay += 6
    end
    ball.setSE(delay, "Battle recall") if playSE
    ballSetOpen(ball, delay, poke_ball)
  end

  def battlerAppear(battler, delay, battlerX, battlerY, batSprite, color)
    battler.setVisible(delay, true)
    battler.setOpacity(delay, 255)
    battler.moveXY(delay, 5, battlerX, battlerY)
    battler.moveZoom(delay, 5, 100, [batSprite, :pbPlayIntroAnimation])
    # NOTE: As soon as the battler sprite finishes zooming, and just as it
    #       starts changing its tone to normal, it plays its intro animation.
    color.alpha = 0
    battler.moveColor(delay + 5, 10, color)
  end

  def battlerAbsorb(battler, delay, battlerX, battlerY, color)
    color.alpha = 255
    battler.moveColor(delay, 10, color)   # Change color of battler to a solid shade
    delay = battler.totalDuration
    battler.moveXY(delay, 5, battlerX, battlerY)
    battler.moveZoom(delay, 5, 0)   # Shrink battler into Poké Ball
    battler.setVisible(delay + 5, false)
  end

  # NOTE: This array makes the Ball Burst animation differ between types of Poké
  #       Ball in certain simple ways. The HGSS animations occasionally have
  #       additional differences, which haven't been coded yet in Essentials as
  #       they're more complex and I couldn't be bothered.
  BALL_BURST_VARIANCES = {
    # [ray start tone, ray end tone,
    #  top particle filename, top particle start tone, top particle end tone,
    #  bottom particle filename, bottom particle start tone, bottom particle end tone,
    #  top glare filename, top glare start tone, top glare end tone,
    #  bottom glare filename, bottom glare start tone, bottom glare end tone]
    :POKEBALL    => [Tone.new(0, 0, 0), Tone.new(0, 0, -192),   # White, yellow
                     "particle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "particle", Tone.new(0, 0, -96), Tone.new(0, -128, -248),   # Yellow, dark orange
                     "particle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "particle", Tone.new(0, 0, -96), Tone.new(0, 0, -192)],   # Light yellow, yellow
    :GREATBALL   => [Tone.new(0, 0, 0), Tone.new(-128, -64, 0),   # White, blue
                     "particle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "particle", Tone.new(-128, 0, 0), Tone.new(-248, -64, 0),   # Cyan, dark cyan
                     "particle", Tone.new(0, 0, 0), Tone.new(-96, -48, 0),   # White, light blue
                     "particle", Tone.new(-96, -48, 0), Tone.new(-192, -96, 0)],   # Blue, dark blue
    :SAFARIBALL  => [Tone.new(0, 0, -32), Tone.new(-128, 0, -128),   # Pale yellow, green
                     "particle", Tone.new(0, 0, -64), Tone.new(-160, 0, -160),   # Beige, darker green
                     "particle", Tone.new(0, 0, -64), Tone.new(-160, 0, -160),   # Beige, darker green
                     "particle", Tone.new(0, 0, 0), Tone.new(-80, 0, -80),   # White, light green
                     "particle", Tone.new(-32, 0, -96), Tone.new(-160, 0, -160)],   # Pale green, darker green
    :ULTRABALL   => [Tone.new(0, 0, 0), Tone.new(0, 0, -192),   # White, yellow
                     "particle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "particle", Tone.new(0, 0, -64), Tone.new(0, 0, -224),   # Pale yellow, yellow
                     "dazzle", Tone.new(0, 0, 0), Tone.new(0, 0, -128),   # White, light yellow
                     "particle", Tone.new(0, 0, -64), Tone.new(0, 0, -224)],   # Pale yellow, yellow
    :MASTERBALL  => [Tone.new(0, 0, 0), Tone.new(-48, -200, -56),   # White, magenta
                     "particle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "particle", Tone.new(0, 0, 0), Tone.new(-48, -200, -56),   # White, magenta
                     "dazzle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "dazzle", Tone.new(-48, -200, -56), Tone.new(-48, -200, -56)],   # Magenta, magenta
    :NETBALL     => [Tone.new(0, 0, 0), Tone.new(0, -64, 0),   # White, lilac
                     "particle", Tone.new(0, 0, 0), Tone.new(0, -64, 0),   # White, lilac
                     "particle", Tone.new(0, 0, 0), Tone.new(0, -64, 0),   # White, lilac
                     "particle", Tone.new(0, 0, 0), Tone.new(0, -64, 0),   # White, lilac
                     "web", Tone.new(-32, -64, -32), Tone.new(-64, -128, -64)],   # Light purple, purple
    :DIVEBALL    => [Tone.new(0, 0, 0), Tone.new(-192, -128, -32),   # White, dark blue
                     "bubble", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "particle", Tone.new(-184, -40, 0), Tone.new(-184, -40, 0),   # Cyan, cyan
                     "dazzle", Tone.new(-184, -40, 0), Tone.new(-184, -40, 0),   # Cyan, cyan
                     "particle", Tone.new(0, 0, 0), Tone.new(-184, -40, 0)],   # White, cyan
    :NESTBALL    => [Tone.new(0, 0, 0), Tone.new(0, 0, -192),   # White, yellow
                     "particle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "particle", Tone.new(0, 0, -96), Tone.new(0, -128, -248),   # Light yellow, dark orange
                     "dazzle", Tone.new(0, 0, 0), Tone.new(-96, 0, -96),   # White, green
                     "particle", Tone.new(-96, 0, -96), Tone.new(-192, 0, -192)],   # Green, dark green
    :REPEATBALL  => [Tone.new(0, 0, 0), Tone.new(0, 0, -192),   # White, yellow
                     "ring3", Tone.new(-16, -16, -88), Tone.new(-32, -32, -176),   # Yellow, yellow
                     "particle", Tone.new(-144, -144, -144), Tone.new(-160, -160, -160),   # Grey, grey
                     "particle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "particle", Tone.new(0, -128, -248), Tone.new(0, -128, -248)],   # Dark orange, dark orange
    :TIMERBALL   => [Tone.new(0, 0, 0), Tone.new(0, 0, -192),   # White, yellow
                     "particle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "particle", Tone.new(0, 0, -96), Tone.new(0, -128, -248),   # Yellow, dark orange
                     "particle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "particle", Tone.new(0, 0, -96), Tone.new(0, 0, -192)],   # Light yellow, yellow
    :LUXURYBALL  => [Tone.new(0, 0, 0), Tone.new(0, -128, -160),   # White, orange
                     "particle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "particle", Tone.new(0, 0, -96), Tone.new(0, -128, -248),   # Yellow, dark orange
                     "particle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "particle", Tone.new(0, -64, -144), Tone.new(0, -192, -248)],   # Light orange, red
    :PREMIERBALL => [Tone.new(0, -160, -148), Tone.new(0, 0, 0),   # Red, white
                     "particle", Tone.new(0, -192, -152), Tone.new(0, -192, -152),   # Red, red
                     "particle", Tone.new(0, 0, 0), Tone.new(0, -192, -152),   # White, red
                     "dazzle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "particle", Tone.new(0, 0, 0), Tone.new(0, 0, 0)],   # White, white
    :DUSKBALL    => [Tone.new(-48, -200, -56), Tone.new(-160, -224, -160),   # Magenta, dark purple
                     "particle", Tone.new(-248, -248, -248), Tone.new(-248, -248, -248),   # Black, black
                     "particle", Tone.new(-24, -96, -32), Tone.new(-24, -96, -32),   # Light magenta, light magenta
                     "particle", Tone.new(-248, -248, -248), Tone.new(-248, -248, -248),   # Black, black
                     "whirl", Tone.new(-160, -224, -160), Tone.new(-160, -224, -160)],   # Dark purple, dark purple
    :HEALBALL    => [Tone.new(-8, -48, -8), Tone.new(-16, -128, -112),   # Pink, dark pink
                     "diamond", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "diamond", Tone.new(0, -96, -104), Tone.new(-160, -64, 0),   # Pink/orange, cyan
                     "dazzle", Tone.new(0, 0, 0), Tone.new(-32, -112, -80),   # White, magenta
                     "particle", Tone.new(-8, -48, -8), Tone.new(-64, -224, -160)],   # Pink, dark magenta
    :QUICKBALL   => [Tone.new(-64, 0, 0), Tone.new(-192, -96, 0),   # Light cyan, dark blue
                     "particle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "particle", Tone.new(0, 0, -96), Tone.new(0, -128, -248),   # Yellow, dark orange
                     "particle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "particle", Tone.new(-96, 0, 0), Tone.new(-192, -96, 0)],   # Cyan, dark blue
    :CHERISHBALL => [Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white (unused; see below)
                     "particle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "particle", Tone.new(0, 0, 0), Tone.new(0, 0, -192),   # White ,yellow
                     "particle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "particle", Tone.new(0, 0, -96), Tone.new(0, 0, -192)]   # Light yellow, yellow
  }

  # The regular Poké Ball burst animation, for when a Pokémon appears from a
  # Poké Ball.
  def ballBurst(delay, ball, ballX, ballY, poke_ball)
    num_particles = 15
    num_rays = 10
    glare_fade_duration = 8   # Lifetimes/durations are in 20ths of a second
    particle_lifetime = 15
    particle_fade_duration = 8
    ray_lifetime = 13
    ray_fade_duration = 5
    ray_min_radius = 24   # How far out from the center a ray starts
    cherish_ball_ray_tones = [Tone.new(-104, -144, -8),   # Indigo
                              Tone.new(-64, -144, -24),   # Purple
                              Tone.new(-8, -144, -64),   # Pink
                              Tone.new(-8, -48, -152),   # Orange
                              Tone.new(-8, -32, -160)]   # Yellow
    # Get array of things that vary for each kind of Poké Ball
    variances = BALL_BURST_VARIANCES[poke_ball] || BALL_BURST_VARIANCES[:POKEBALL]
    # Set up glare particles
    glare1 = addNewSprite(ballX, ballY, "Graphics/Battle animations/ballBurst_#{variances[11]}", PictureOrigin::CENTER)
    glare2 = addNewSprite(ballX, ballY, "Graphics/Battle animations/ballBurst_#{variances[8]}", PictureOrigin::CENTER)
    [glare1, glare2].each_with_index do |particle, num|
      particle.setZ(0, 105 + num)
      particle.setZoom(0, 0)
      particle.setTone(0, variances[12 - (3 * num)])
      particle.setVisible(0, false)
    end
    [glare1, glare2].each_with_index do |particle, num|
      particle.moveTone(delay + glare_fade_duration + 3, glare_fade_duration / 2, variances[13 - (3 * num)])
    end
    # Animate glare particles
    [glare1, glare2].each { |p| p.setVisible(delay, true) }
    if poke_ball == :MASTERBALL
      glare1.moveAngle(delay, 19, -135)
      glare1.moveZoom(delay, glare_fade_duration, 250)
    elsif poke_ball == :DUSKBALL
      glare1.moveAngle(delay, 19, -270)
    elsif ["whirl"].include?(variances[11])
      glare1.moveZoom(delay, glare_fade_duration, 200)
    else
      glare1.moveZoom(delay, glare_fade_duration, (["dazzle", "ring3", "web"].include?(variances[11])) ? 100 : 250)
    end
    glare1.moveOpacity(delay + glare_fade_duration + 3, glare_fade_duration, 0)
    if poke_ball == :MASTERBALL
      glare2.moveAngle(delay, 19, -135)
      glare2.moveZoom(delay, glare_fade_duration, 200)
    else
      glare2.moveZoom(delay, glare_fade_duration, (["dazzle", "ring3", "web"].include?(variances[8])) ? 125 : 200)
    end
    glare2.moveOpacity(delay + glare_fade_duration + 3, glare_fade_duration - 2, 0)
    [glare1, glare2].each { |p| p.setVisible(delay + 19, false) }
    # Rays
    num_rays.times do |i|
      # Set up ray
      angle = rand(360)
      radian = (angle + 90) * Math::PI / 180
      start_zoom = rand(50...100)
      ray = addNewSprite(ballX + ray_min_radius * Math.cos(radian),
                         ballY - ray_min_radius * Math.sin(radian),
                         "Graphics/Battle animations/ballBurst_ray", PictureOrigin::BOTTOM)
      ray.setZ(0, 100)
      ray.setZoomXY(0, 200, start_zoom)
      ray.setTone(0, variances[0]) if poke_ball != :CHERISHBALL
      ray.setOpacity(0, 0)
      ray.setVisible(0, false)
      ray.setAngle(0, angle)
      # Animate ray
      start = delay + i / 2
      ray.setVisible(start, true)
      ray.moveZoomXY(start, ray_lifetime, 200, start_zoom * 6)
      ray.moveOpacity(start, 2, 255)   # Quickly fade in
      ray.moveOpacity(start + ray_lifetime - ray_fade_duration, ray_fade_duration, 0)   # Fade out
      if poke_ball == :CHERISHBALL
        ray_lifetime.times do |frame|
          ray.setTone(start + frame, cherish_ball_ray_tones[frame % cherish_ball_ray_tones.length])
        end
      else
        ray.moveTone(start + ray_lifetime - ray_fade_duration, ray_fade_duration, variances[1])
      end
      ray.setVisible(start + ray_lifetime, false)
    end
    # Particles
    num_particles.times do |i|
      # Set up particles
      particle1 = addNewSprite(ballX, ballY, "Graphics/Battle animations/ballBurst_#{variances[5]}", PictureOrigin::CENTER)
      particle2 = addNewSprite(ballX, ballY, "Graphics/Battle animations/ballBurst_#{variances[2]}", PictureOrigin::CENTER)
      [particle1, particle2].each_with_index do |particle, num|
        particle.setZ(0, 110 + num)
        particle.setZoom(0, (80 - (num * 20)) / (["ring2"].include?(variances[5 - (3 * num)]) ? 2 : 1))
        particle.setTone(0, variances[6 - (3 * num)])
        particle.setVisible(0, false)
      end
      # Animate particles
      start = delay + i / 4
      max_radius = rand(256...384)
      angle = rand(360)
      radian = angle * Math::PI / 180
      [particle1, particle2].each_with_index do |particle, num|
        particle.setVisible(start, true)
        particle.moveDelta(start, particle_lifetime, max_radius * Math.cos(radian), max_radius * Math.sin(radian))
        particle.moveZoom(start, particle_lifetime, 10)
        particle.moveTone(start + particle_lifetime - particle_fade_duration,
                           particle_fade_duration / 2, variances[7 - (3 * num)])
        particle.moveOpacity(start + particle_lifetime - particle_fade_duration,
                             particle_fade_duration,
                             0)   # Fade out at end
        particle.setVisible(start + particle_lifetime, false)
      end
    end
  end

  # NOTE: This array makes the Ball Burst capture animation differ between types
  #       of Poké Ball in certain simple ways. The HGSS animations occasionally
  #       have additional differences, which haven't been coded yet in
  #       Essentials as they're more complex and I couldn't be bothered.
  BALL_BURST_CAPTURE_VARIANCES = {
    # [top glare filename, top particle start tone, top particle end tone,
    #  middle glare filename, middle glare start tone, middle glare end tone,
    #  bottom glare filename, bottom glare start tone, bottom glare end tone,
    #  top particle filename, top particle start tone, top particle end tone,
    #  bottom particle filename, bottom particle start tone, bottom particle end tone,
    #  ring tone start, ring tone end]
    :POKEBALL    => ["particle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "dazzle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "particle", Tone.new(0, 0, 0), Tone.new(0, 0, -192),   # White, yellow
                     "particle_s", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "particle_s", Tone.new(0, 0, 0), Tone.new(0, 0, -192),   # White, yellow
                     Tone.new(0, 0, -96), Tone.new(0, 0, -96)],   # Light yellow, light yellow
    :GREATBALL   => ["particle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "dazzle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "particle", Tone.new(0, 0, 0), Tone.new(0, 0, -192),   # White, yellow
                     "particle_s", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "particle_s", Tone.new(0, 0, 0), Tone.new(-128, -64, 0),   # White, blue
                     Tone.new(-128, -32, 0), Tone.new(-128, -32, 0)],   # Blue, blue
    :SAFARIBALL  => ["particle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "dazzle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "particle", Tone.new(0, 0, 0), Tone.new(0, 0, -192),   # White, yellow
                     "particle_s", Tone.new(-48, 0, -48), Tone.new(-48, 0, -48),   # Light green, light green
                     "particle_s", Tone.new(-48, 0, -48), Tone.new(-128, 0, -128),   # Light green, green
                     Tone.new(-48, 0, -48), Tone.new(-128, 0, -128)],   # Light green, green
    :ULTRABALL   => ["particle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "dazzle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "particle", Tone.new(0, 0, 0), Tone.new(0, 0, -192),   # White, yellow
                     "particle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "dazzle", Tone.new(0, 0, 0), Tone.new(0, 0, -192),   # White, yellow
                     Tone.new(0, 0, -128), Tone.new(0, 0, -128)],   # Light yellow, light yellow
    :MASTERBALL  => ["particle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "dazzle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "particle", Tone.new(-64, -128, -64), Tone.new(-96, -160, -96),   # Purple, darker purple
                     "dazzle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "particle", Tone.new(0, -80, 0), Tone.new(0, -128, -64),   # Purple, hot pink
                     Tone.new(0, 0, 0), Tone.new(-48, -200, -80)],   # White, magenta
    :NETBALL     => ["particle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "dazzle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "particle", Tone.new(0, 0, 0), Tone.new(0, 0, -192),   # White, yellow
                     "particle_s", Tone.new(-128, -56, 0), Tone.new(-128, -56, 0),   # Blue, blue
                     "particle_s", Tone.new(-128, -56, 0), Tone.new(-128, -56, 0),   # Blue, blue
                     Tone.new(-160, -64, 0), Tone.new(-128, -56, 0)],   # Cyan, blue
    :DIVEBALL    => ["particle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "dazzle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "particle", Tone.new(0, 0, 0), Tone.new(0, 0, -192),   # White, yellow
                     "bubble", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "particle", Tone.new(-128, -48, 0), Tone.new(-128, -48, 0),   # Aqua, aqua
                     Tone.new(-64, 0, 0), Tone.new(-180, -32, -32)],   # Light blue, turquoise
    :NESTBALL    => ["particle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "dazzle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "particle", Tone.new(0, 0, 0), Tone.new(0, 0, -192),   # White, yellow
                     "ring3", Tone.new(-32, 0, -104), Tone.new(-104, -16, -128),   # Lime green, green
                     "ring3", Tone.new(0, 0, 0), Tone.new(0, 0, -192),   # White, yellow (unused)
                     Tone.new(-48, 0, -48), Tone.new(-128, 0, -128)],   # Light green, green
    :REPEATBALL  => ["particle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "dazzle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "particle", Tone.new(0, 0, 0), Tone.new(0, 0, -192),   # White, yellow
                     "ring3", Tone.new(-16, -16, -88), Tone.new(-32, -32, -176),   # Yellow, yellow
                     "particle", Tone.new(-144, -144, -144), Tone.new(-160, -160, -160),   # Grey, grey
                     Tone.new(0, 0, -96), Tone.new(0, 0, -96)],   # Light yellow, light yellow
    :TIMERBALL   => ["particle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "dazzle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "particle", Tone.new(0, 0, 0), Tone.new(0, 0, -192),   # White, yellow
                     "particle_s", Tone.new(0, 0, 0), Tone.new(0, 0, -96),   # White, light yellow
                     "particle_s", Tone.new(0, -48, -160), Tone.new(0, 0, -96),   # Orange, light yellow
                     Tone.new(0, -48, -128), Tone.new(0, -160, -248)],   # Light orange, dark orange
    :LUXURYBALL  => ["particle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "dazzle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "particle", Tone.new(0, 0, 0), Tone.new(0, -192, -248),   # White, red
                     "particle_s", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "particle_s", Tone.new(0, 0, 0), Tone.new(0, 0, -192),   # White, yellow
                     Tone.new(0, -48, -128), Tone.new(0, -192, -248)],   # Light orange, red
    :PREMIERBALL => ["particle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "dazzle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "particle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "particle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "ring4", Tone.new(-16, -40, -80), Tone.new(-16, -136, -176),   # Light orange, dark orange
                     Tone.new(0, 0, 0), Tone.new(0, 0, 0)],   # White, white
    :DUSKBALL    => ["particle", Tone.new(-255, -255, -255), Tone.new(-255, -255, -255),   # Black, black
                     "whirl", Tone.new(-112, -184, -128), Tone.new(-255, -255, -255),   # Purple, black
                     "whirl", Tone.new(-112, -184, -128), Tone.new(-112, -184, -128),   # Purple, purple
                     "particle", Tone.new(-112, -184, -128), Tone.new(-255, -255, -255),   # Purple, black
                     "particle_s", Tone.new(-112, -184, -128), Tone.new(-255, -255, -255),   # Purple, black
                     Tone.new(0, 0, -96), Tone.new(0, 0, -96)],   # Light yellow, light yellow
    :HEALBALL    => ["particle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "dazzle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "particle", Tone.new(0, -32, 0), Tone.new(0, -32, 0),   # Light pink, light pink
                     "diamond", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "diamond", Tone.new(0, 0, 0), Tone.new(-160, -64, 0),   # White, cyan
                     Tone.new(0, 0, 0), Tone.new(0, -32, 0)],   # White, light pink
    :QUICKBALL   => ["particle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "dazzle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "particle", Tone.new(0, 0, 0), Tone.new(0, 0, -192),   # White, yellow
                     "particle_s", Tone.new(0, 0, 0), Tone.new(0, 0, -96),   # White, light yellow
                     "particle_s", Tone.new(0, -48, -160), Tone.new(0, 0, -96),   # Orange, light yellow
                     Tone.new(0, -48, -128), Tone.new(0, -160, -248)],   # Light orange, dark orange
    :CHERISHBALL => ["particle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "dazzle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "particle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "particle", Tone.new(0, 0, 0), Tone.new(0, 0, 0),   # White, white
                     "ring4", Tone.new(-16, -40, -80), Tone.new(-16, -136, -176),   # Light orange, dark orange
                     Tone.new(0, 0, 0), Tone.new(0, 0, 0)]   # White, white
  }

  # The Poké Ball burst animation used when absorbing a wild Pokémon during a
  # capture attempt.
  def ballBurstCapture(delay, ball, ballX, ballY, poke_ball)
    particle_duration = 10
    ring_duration = 5
    num_particles = 9
    base_angle = 270
    base_radius = (poke_ball == :MASTERBALL) ? 192 : 144   # How far out from the Poké Ball the particles go
    # Get array of things that vary for each kind of Poké Ball
    variances = BALL_BURST_CAPTURE_VARIANCES[poke_ball] || BALL_BURST_CAPTURE_VARIANCES[:POKEBALL]
    # Set up glare particles
    glare1 = addNewSprite(ballX, ballY, "Graphics/Battle animations/ballBurst_#{variances[6]}", PictureOrigin::CENTER)
    glare2 = addNewSprite(ballX, ballY, "Graphics/Battle animations/ballBurst_#{variances[3]}", PictureOrigin::CENTER)
    glare3 = addNewSprite(ballX, ballY, "Graphics/Battle animations/ballBurst_#{variances[0]}", PictureOrigin::CENTER)
    [glare1, glare2, glare3].each_with_index do |particle, num|
      particle.setZ(0, 100 + num)
      particle.setZoom(0, 0)
      particle.setTone(0, variances[7 - (3 * num)])
      particle.setVisible(0, false)
    end
    glare2.setOpacity(0, 160)
    glare3.setOpacity(0, 160) if poke_ball != :DUSKBALL
    # Animate glare particles
    [glare1, glare2, glare3].each { |p| p.setVisible(delay, true) }
    case poke_ball
    when :MASTERBALL
      glare1.moveZoom(delay, particle_duration, 1200)
    when :DUSKBALL
      glare1.moveZoom(delay, particle_duration, 350)
    else
      glare1.moveZoom(delay, particle_duration, 600)
    end
    glare1.moveOpacity(delay + particle_duration / 2, particle_duration / 2, 0)
    [glare1, glare2, glare3].each_with_index do |particle, num|
      particle.moveTone(delay, particle_duration, variances[8 - (3 * num)])
    end
    if poke_ball == :DUSKBALL
      glare2.moveZoom(delay, particle_duration, 350)
      glare3.moveZoom(delay, particle_duration, 500)
      [glare2, glare3].each_with_index do |particle, num|
        particle.moveOpacity(delay + particle_duration / 2, particle_duration / 2, 0)
      end
    else
      glare2.moveZoom(delay, particle_duration, (poke_ball == :MASTERBALL) ? 400 : 250)
      glare2.moveOpacity(delay + particle_duration / 2, particle_duration / 3, 0)
      glare3.moveZoom(delay, particle_duration, (poke_ball == :MASTERBALL) ? 800 : 500)
      glare3.moveOpacity(delay + particle_duration / 2, particle_duration / 3, 0)
    end
    [glare1, glare2, glare3].each { |p| p.setVisible(delay + particle_duration, false) }
    # Burst particles
    num_particles.times do |i|
      # Set up particle that keeps moving out
      particle1 = addNewSprite(ballX, ballY, "Graphics/Battle animations/ballBurst_particle", PictureOrigin::CENTER)
      particle1.setZ(0, 105)
      particle1.setZoom(0, 150)
      particle1.setOpacity(0, 160)
      particle1.setVisible(0, false)
      # Set up particles that curve back in
      particle2 = addNewSprite(ballX, ballY, "Graphics/Battle animations/ballBurst_#{variances[12]}", PictureOrigin::CENTER)
      particle3 = addNewSprite(ballX, ballY, "Graphics/Battle animations/ballBurst_#{variances[9]}", PictureOrigin::CENTER)
      [particle2, particle3].each_with_index do |particle, num|
        particle.setZ(0, 110 + num)
        particle.setZoom(0, (poke_ball == :NESTBALL) ? 50 : 0)
        particle.setTone(0, variances[13 - (3 * num)])
        particle.setVisible(0, false)
        particle.setAngle(0, rand(360)) if poke_ball == :PREMIERBALL
      end
      particle3.setOpacity(0, 128) if poke_ball == :DIVEBALL
      # Particle animations
      [particle1, particle2, particle3].each { |p| p.setVisible(delay, true) }
      particle2.setVisible(delay, false) if poke_ball == :NESTBALL
      start_angle = base_angle + (i * 360 / num_particles)
      p1_x_offset = base_radius * Math.cos(start_angle * Math::PI / 180)
      p1_y_offset = base_radius * Math.sin(start_angle * Math::PI / 180)
      particle_duration.times do |j|
        index = j + 1
        angle = start_angle + (index * (360 / num_particles) / particle_duration)
        radian = angle * Math::PI / 180
        radius = base_radius
        prop = index.to_f / (particle_duration / 2)
        prop = 2 - prop if index > particle_duration / 2
        radius *= prop
        particle1.moveXY(delay + j, 1,
                         ballX + p1_x_offset * index * 2 / particle_duration,
                         ballY - p1_y_offset * index * 2 / particle_duration)
        [particle2, particle3].each do |particle|
          particle.moveXY(delay + j, 1,
                          ballX + radius * Math.cos(radian),
                          ballY - radius * Math.sin(radian))
        end
      end
      particle1.moveZoom(delay, particle_duration, 0)
      particle1.moveOpacity(delay, particle_duration, 0)
      [particle2, particle3].each_with_index do |particle, num|
        # Zoom in
        if num == 0 && poke_ball == :MASTERBALL
          particle.moveZoom(delay, particle_duration / 2, 225)
        elsif num == 0 && poke_ball == :DIVEBALL
          particle.moveZoom(delay, particle_duration / 2, 125)
        elsif ["particle"].include?(variances[12 - (3 * num)])
          particle.moveZoom(delay, particle_duration / 2, (poke_ball == :PREMIERBALL) ? 50 : 80)
        elsif ["ring3"].include?(variances[12 - (3 * num)])
          particle.moveZoom(delay, particle_duration / 2, 50)
        elsif ["dazzle", "ring4", "diamond"].include?(variances[12 - (3 * num)])
          particle.moveZoom(delay, particle_duration / 2, 60)
        else
          particle.moveZoom(delay, particle_duration / 2, 100)
        end
        # Zoom out
        if ["particle", "dazzle", "ring3", "ring4", "diamond"].include?(variances[12 - (3 * num)])
          particle.moveZoom(delay + particle_duration * 2 / 3, particle_duration / 3, 10)
        else
          particle.moveZoom(delay + particle_duration * 2 / 3, particle_duration / 3, 25)
        end
        # Rotate (for Premier Ball)
        particle.moveAngle(delay, particle_duration, -180) if poke_ball == :PREMIERBALL
        # Change tone, fade out
        particle.moveTone(delay + particle_duration / 3, (particle_duration.to_f / 3).ceil, variances[14 - (3 * num)])
        particle.moveOpacity(delay + particle_duration - 3, 3, 128)   # Fade out at end
      end
      [particle1, particle2, particle3].each { |p| p.setVisible(delay + particle_duration, false) }
    end
    # Web sprite (for Net Ball)
    if poke_ball == :NETBALL
      web = addNewSprite(ballX, ballY, "Graphics/Battle animations/ballBurst_web", PictureOrigin::CENTER)
      web.setZ(0, 123)
      web.setZoom(0, 120)
      web.setOpacity(0, 0)
      web.setTone(0, Tone.new(-32, -32, -128))
      web.setVisible(0, false)
      start = particle_duration / 2
      web.setVisible(delay + start, true)
      web.moveOpacity(delay + start, 2, 160)
      web_duration = particle_duration + ring_duration - (particle_duration / 2)
      (web_duration / 4).times do |i|
        web.moveZoom(delay + start + (i * 4), 2, 150)
        web.moveZoom(delay + start + (i * 4) + 2, 2, 120)
      end
      now = start + (web_duration / 4) * 4
      web.moveZoom(delay + now, particle_duration + ring_duration - now, 150)
      web.moveOpacity(delay + particle_duration, ring_duration, 0)
      web.setVisible(delay + particle_duration + ring_duration, false)
    end
    # Ring particle
    ring = addNewSprite(ballX, ballY, "Graphics/Battle animations/ballBurst_ring1", PictureOrigin::CENTER)
    ring.setZ(0, 110)
    ring.setZoom(0, 0)
    ring.setTone(0, variances[15])
    ring.setVisible(0, false)
    # Ring particle animation
    ring.setVisible(delay + particle_duration, true)
    ring.moveZoom(delay + particle_duration - 2, ring_duration + 2, 125)   # Start slightly early
    ring.moveTone(delay + particle_duration, ring_duration, variances[16])
    ring.moveOpacity(delay + particle_duration, ring_duration, 0)
    ring.setVisible(delay + particle_duration + ring_duration, false)
    # Mark the end of the burst animation
    ball.setDelta(delay + particle_duration + ring_duration, 0, 0)
  end

  # The animation shown over a thrown Poké Ball when it has successfully caught
  # a Pokémon.
  def ballCaptureSuccess(ball, delay, ballX, ballY)
    ball.setSE(delay, "Battle catch click")
    ball.moveTone(delay, 4, Tone.new(-128, -128, -128))   # Ball goes darker
    delay = ball.totalDuration
    star_duration = 12   # In 20ths of a second
    y_offsets = [[0, 74, 52], [0, 62, 28], [0, 74, 48]]
    3.times do |i|   # Left, middle, right
      # Set up particle
      star = addNewSprite(ballX, ballY, "Graphics/Battle animations/ballBurst_star", PictureOrigin::CENTER)
      star.setZ(0, 110)
      star.setZoom(0, [50, 50, 33][i])
      start_angle = [0, 345, 15][i]
      star.setAngle(0, start_angle)
      star.setOpacity(0, 0)
      star.setVisible(0, false)
      # Particle animation
      star.setVisible(delay, true)
      y_pos = y_offsets[i]
      star_duration.times do |j|
        index = j + 1
        x = 72 * index / star_duration
        proportion = index.to_f / star_duration
        a = (2 * y_pos[2]) - 4 * y_pos[1]
        b = y_pos[2] - a
        y = ((a * proportion) + b) * proportion
        star.moveXY(delay + j, 1, ballX + [-1, 0, 1][i] * x, ballY - y)
      end
      star.moveAngle(delay, star_duration, start_angle + [144, 0, 45][i]) if i.even?
      star.moveOpacity(delay, 4, 255)   # Fade in
      star.moveTone(delay + 3, 3, Tone.new(0, 0, -96))   # Light yellow
      star.moveTone(delay + 6, 3, Tone.new(0, 0, 0))   # White
      star.moveOpacity(delay + 8, 4, 0)   # Fade out
    end
  end

  # The Poké Ball burst animation used when recalling a Pokémon. In HGSS, this
  # is the same for all types of Poké Ball except for the color that the battler
  # turns - see def getBattlerColorFromPokeBall.
  def ballBurstRecall(delay, ball, ballX, ballY, poke_ball)
    color_duration = 10   # Change color of battler to a solid shade - see def battlerAbsorb
    shrink_duration = 5   # Shrink battler into Poké Ball - see def battlerAbsorb
    burst_duration = color_duration + shrink_duration
    # Burst particles
    num_particles = 5
    base_angle = 55
    base_radius = 64   # How far out from the Poké Ball the particles go
    num_particles.times do |i|
      # Set up particle
      particle = addNewSprite(ballX, ballY, "Graphics/Battle animations/ballBurst_particle", PictureOrigin::CENTER)
      particle.setZ(0, 110)
      particle.setZoom(0, 150)
      particle.setOpacity(0, 0)
      particle.setVisible(0, false)
      # Particle animation
      particle.setVisible(delay, true)
      particle.moveOpacity(delay, 2, 255)   # Fade in quickly
      burst_duration.times do |j|
        angle = base_angle + (i * 360 / num_particles) + (135.0 * j / burst_duration)
        radian = angle * Math::PI / 180
        radius = base_radius
        if j < burst_duration / 5
          prop = j.to_f / (color_duration / 3)
          radius *= 0.75 + (prop / 4)
        elsif j >= burst_duration / 2
          prop = (j.to_f - burst_duration / 2) / (burst_duration / 2)
          radius *= 1 - prop
        end
        if j == 0
          particle.setXY(delay + j, ballX + radius * Math.cos(radian), ballY - radius * Math.sin(radian))
        else
          particle.moveXY(delay + j, 1, ballX + radius * Math.cos(radian), ballY - radius * Math.sin(radian))
        end
      end
      particle.moveZoom(delay, burst_duration, 0)
      particle.moveTone(delay + color_duration / 2, color_duration / 2, Tone.new(0, 0, -192))   # Yellow
      particle.moveTone(delay + color_duration, shrink_duration, Tone.new(0, -128, -248))   # Dark orange
      particle.moveOpacity(delay + color_duration, shrink_duration, 0)   # Fade out at end
      particle.setVisible(delay + burst_duration, false)
    end
    # Ring particles
    ring1 = addNewSprite(ballX, ballY, "Graphics/Battle animations/ballBurst_ring1", PictureOrigin::CENTER)
    ring1.setZ(0, 110)
    ring1.setZoom(0, 0)
    ring1.setVisible(0, false)
    ring2 = addNewSprite(ballX, ballY, "Graphics/Battle animations/ballBurst_ring2", PictureOrigin::CENTER)
    ring2.setZ(0, 110)
    ring2.setVisible(0, false)
    # Ring particle animations
    ring1.setVisible(delay + burst_duration - 2, true)
    ring1.moveZoom(delay + burst_duration - 2, 4, 100)
    ring1.setVisible(delay + burst_duration + 2, false)
    ring2.setVisible(delay + burst_duration + 2, true)
    ring2.moveZoom(delay + burst_duration + 2, 4, 200)
    ring2.moveOpacity(delay + burst_duration + 2, 4, 0)
  end
end
