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

  # There are three kinds of animations shown when a Poké Ball opens up: one for
  # when attempting to capture a Pokémon, one when recalling a Pokémon, and one
  # for all other cases (e.g. sending out). This is anim_type (one of :capture,
  # :recall and :main). The recall animation is the same for all Poké Balls, and
  # the other two animations are different for each Poké Ball.
  def getBallBurstAnimationName(poke_ball, anim_type = :main)
    animations = pbLoadBattleAnimations
    if anim_type == :recall
      anim_name = "BallBurstRecall"
      return anim_name if animations&.get_from_name("Common:" + anim_name)
    else
      name = poke_ball.to_s
      if anim_type == :capture
        anim = animations&.get_from_name("Common:BallBurstCapture" + name)
        return "BallBurstCapture" + name if anim
        anim = animations&.get_from_name("Common:BallBurstCapture")
        return "BallBurstCapture" if anim
      end
      anim = animations&.get_from_name("Common:BallBurst" + name)
      return "BallBurst" + name if anim
    end
    return "BallBurst"
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

  # The regular Poké Ball burst animation.
  def ballBurst(delay, ball, ballX, ballY, poke_ball)
    ball.setDelta(delay, 0, 0, [@battler.battle.scene, :pbBallBurstCommonAnimation,
                                [getBallBurstAnimationName(poke_ball), @battler, ballX, ballY]])
  end

  # The Poké Ball burst animation used when absorbing a wild Pokémon during a
  # capture attempt.
  def ballBurstCapture(delay, ball, ballX, ballY, poke_ball)
    ball.setDelta(delay, 0, 0, [@battler.battle.scene, :pbBallBurstCommonAnimation,
                                [getBallBurstAnimationName(poke_ball, :capture), @battler, ballX, ballY]])
  end

  def ballCaptureSuccess(ball, delay, ballX, ballY)
    ball.setSE(delay, "Battle catch click")
    ball.moveTone(delay, 4, Tone.new(-64, -64, -64, 128))
  end

  # The Poké Ball burst animation used when recalling a Pokémon.
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
      particle = addNewSprite(ballX, ballY,
         "Graphics/Battle animations/ballBurst_particle", PictureOrigin::CENTER)
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
      particle.moveZoom(delay, burst_duration, 0.75)
      particle.moveTone(delay + color_duration / 2, color_duration / 2, Tone.new(0, 0, -192, -64))   # Yellow
      particle.moveTone(delay + color_duration, shrink_duration, Tone.new(0, -128, -248, -224))   # Dark orange
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
