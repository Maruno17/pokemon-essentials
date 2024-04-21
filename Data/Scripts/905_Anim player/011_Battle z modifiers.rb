#===============================================================================
#
#===============================================================================
class Battle::Scene
  alias __newanims__pbCreateBackdropSprites pbCreateBackdropSprites unless method_defined?(:__newanims__pbCreateBackdropSprites)
  def pbCreateBackdropSprites
    __newanims__pbCreateBackdropSprites
    ["battle_bg", "battle_bg2"].each { |spr| @sprites[spr].z = -200 }
    2.times do |side|
      @sprites["base_#{side}"].z = -199
    end
    @sprites["cmdBar_bg"].z += 9999
  end

  alias __newanims__pbInitSprites pbInitSprites unless method_defined?(:__newanims__pbInitSprites)
  def pbInitSprites
    __newanims__pbInitSprites
    @sprites["messageBox"].z += 9999
    @sprites["messageWindow"].z += 9999
    @sprites["commandWindow"].z += 9999
    @sprites["fightWindow"].z += 9999
    @sprites["targetWindow"].z += 9999
    2.times do |side|
      @sprites["partyBar_#{side}"].z += 9999
      NUM_BALLS.times do |i|
        @sprites["partyBall_#{side}_#{i}"].z += 9999
      end
      # Ability splash bars
      @sprites["abilityBar_#{side}"].z += 9999 if USE_ABILITY_SPLASH
    end
    @battle.battlers.each_with_index do |b, i|
      @sprites["dataBox_#{i}"].z += 9999 if b
    end
    @battle.player.each_with_index do |p, i|
      @sprites["player_#{i + 1}"].z = 1500 + (i * 100)
    end
    if @battle.trainerBattle?
      @battle.opponent.each_with_index do |p, i|
        @sprites["trainer_#{i + 1}"].z = 500 - (i * 100)
      end
    end
  end
end

#===============================================================================
# Pokémon sprite (used in battle)
#===============================================================================
class Battle::Scene::BattlerSprite < RPG::Sprite
  def pbSetPosition
    return if !@_iconBitmap
    pbSetOrigin
    if @index.even?
      self.z = 1100 + (100 * @index / 2)
    else
      self.z = 1000 - (100 * (@index + 1) / 2)
    end
    # Set original position
    p = Battle::Scene.pbBattlerPosition(@index, @sideSize)
    @spriteX = p[0]
    @spriteY = p[1]
    # Apply metrics
    @pkmn.species_data.apply_metrics_to_sprite(self, @index)
  end
end

#===============================================================================
# Shadow sprite for Pokémon (used in battle)
#===============================================================================
class Battle::Scene::BattlerShadowSprite < RPG::Sprite
  def pbSetPosition
    return if !@_iconBitmap
    pbSetOrigin
    self.z = -198
    # Set original position
    p = Battle::Scene.pbBattlerPosition(@index, @sideSize)
    self.x = p[0]
    self.y = p[1]
    # Apply metrics
    @pkmn.species_data.apply_metrics_to_sprite(self, @index, true)
  end
end

#===============================================================================
# Mixin module for certain hardcoded battle animations that involve Poké Balls.
#===============================================================================
module Battle::Scene::Animation::BallAnimationMixin
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
      particle.setZ(0, 5105 + num)
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
      ray = addNewSprite(ballX + (ray_min_radius * Math.cos(radian)),
                        ballY - (ray_min_radius * Math.sin(radian)),
                        "Graphics/Battle animations/ballBurst_ray", PictureOrigin::BOTTOM)
      ray.setZ(0, 5100)
      ray.setZoomXY(0, 200, start_zoom)
      ray.setTone(0, variances[0]) if poke_ball != :CHERISHBALL
      ray.setOpacity(0, 0)
      ray.setVisible(0, false)
      ray.setAngle(0, angle)
      # Animate ray
      start = delay + (i / 2)
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
        particle.setZ(0, 5110 + num)
        particle.setZoom(0, (80 - (num * 20)) / (["ring2"].include?(variances[5 - (3 * num)]) ? 2 : 1))
        particle.setTone(0, variances[6 - (3 * num)])
        particle.setVisible(0, false)
      end
      # Animate particles
      start = delay + (i / 4)
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
      particle.setZ(0, 5100 + num)
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
    glare1.moveOpacity(delay + (particle_duration / 2), particle_duration / 2, 0)
    [glare1, glare2, glare3].each_with_index do |particle, num|
      particle.moveTone(delay, particle_duration, variances[8 - (3 * num)])
    end
    if poke_ball == :DUSKBALL
      glare2.moveZoom(delay, particle_duration, 350)
      glare3.moveZoom(delay, particle_duration, 500)
      [glare2, glare3].each_with_index do |particle, num|
        particle.moveOpacity(delay + (particle_duration / 2), particle_duration / 2, 0)
      end
    else
      glare2.moveZoom(delay, particle_duration, (poke_ball == :MASTERBALL) ? 400 : 250)
      glare2.moveOpacity(delay + (particle_duration / 2), particle_duration / 3, 0)
      glare3.moveZoom(delay, particle_duration, (poke_ball == :MASTERBALL) ? 800 : 500)
      glare3.moveOpacity(delay + (particle_duration / 2), particle_duration / 3, 0)
    end
    [glare1, glare2, glare3].each { |p| p.setVisible(delay + particle_duration, false) }
    # Burst particles
    num_particles.times do |i|
      # Set up particle that keeps moving out
      particle1 = addNewSprite(ballX, ballY, "Graphics/Battle animations/ballBurst_particle", PictureOrigin::CENTER)
      particle1.setZ(0, 5105)
      particle1.setZoom(0, 150)
      particle1.setOpacity(0, 160)
      particle1.setVisible(0, false)
      # Set up particles that curve back in
      particle2 = addNewSprite(ballX, ballY, "Graphics/Battle animations/ballBurst_#{variances[12]}", PictureOrigin::CENTER)
      particle3 = addNewSprite(ballX, ballY, "Graphics/Battle animations/ballBurst_#{variances[9]}", PictureOrigin::CENTER)
      [particle2, particle3].each_with_index do |particle, num|
        particle.setZ(0, 5110 + num)
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
                         ballX + (p1_x_offset * index * 2 / particle_duration),
                         ballY - (p1_y_offset * index * 2 / particle_duration))
        [particle2, particle3].each do |particle|
          particle.moveXY(delay + j, 1,
                          ballX + (radius * Math.cos(radian)),
                          ballY - (radius * Math.sin(radian)))
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
          particle.moveZoom(delay + (particle_duration * 2 / 3), particle_duration / 3, 10)
        else
          particle.moveZoom(delay + (particle_duration * 2 / 3), particle_duration / 3, 25)
        end
        # Rotate (for Premier Ball)
        particle.moveAngle(delay, particle_duration, -180) if poke_ball == :PREMIERBALL
        # Change tone, fade out
        particle.moveTone(delay + (particle_duration / 3), (particle_duration.to_f / 3).ceil, variances[14 - (3 * num)])
        particle.moveOpacity(delay + particle_duration - 3, 3, 128)   # Fade out at end
      end
      [particle1, particle2, particle3].each { |p| p.setVisible(delay + particle_duration, false) }
    end
    # Web sprite (for Net Ball)
    if poke_ball == :NETBALL
      web = addNewSprite(ballX, ballY, "Graphics/Battle animations/ballBurst_web", PictureOrigin::CENTER)
      web.setZ(0, 5123)
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
      now = start + ((web_duration / 4) * 4)
      web.moveZoom(delay + now, particle_duration + ring_duration - now, 150)
      web.moveOpacity(delay + particle_duration, ring_duration, 0)
      web.setVisible(delay + particle_duration + ring_duration, false)
    end
    # Ring particle
    ring = addNewSprite(ballX, ballY, "Graphics/Battle animations/ballBurst_ring1", PictureOrigin::CENTER)
    ring.setZ(0, 5110)
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
      star.setZ(0, 5110)
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
        a = (2 * y_pos[2]) - (4 * y_pos[1])
        b = y_pos[2] - a
        y = ((a * proportion) + b) * proportion
        star.moveXY(delay + j, 1, ballX + ([-1, 0, 1][i] * x), ballY - y)
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
      particle.setZ(0, 5110)
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
          prop = (j.to_f - (burst_duration / 2)) / (burst_duration / 2)
          radius *= 1 - prop
        end
        if j == 0
          particle.setXY(delay + j, ballX + (radius * Math.cos(radian)), ballY - (radius * Math.sin(radian)))
        else
          particle.moveXY(delay + j, 1, ballX + (radius * Math.cos(radian)), ballY - (radius * Math.sin(radian)))
        end
      end
      particle.moveZoom(delay, burst_duration, 0)
      particle.moveTone(delay + (color_duration / 2), color_duration / 2, Tone.new(0, 0, -192))   # Yellow
      particle.moveTone(delay + color_duration, shrink_duration, Tone.new(0, -128, -248))   # Dark orange
      particle.moveOpacity(delay + color_duration, shrink_duration, 0)   # Fade out at end
      particle.setVisible(delay + burst_duration, false)
    end
    # Ring particles
    ring1 = addNewSprite(ballX, ballY, "Graphics/Battle animations/ballBurst_ring1", PictureOrigin::CENTER)
    ring1.setZ(0, 5110)
    ring1.setZoom(0, 0)
    ring1.setVisible(0, false)
    ring2 = addNewSprite(ballX, ballY, "Graphics/Battle animations/ballBurst_ring2", PictureOrigin::CENTER)
    ring2.setZ(0, 5110)
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

#===============================================================================
# Shows the battle scene fading in while elements slide around into place
#===============================================================================
class Battle::Scene::Animation::Intro < Battle::Scene::Animation
  def createProcesses
    appearTime = 20   # This is in 1/20 seconds
    # Background
    if @sprites["battle_bg2"]
      makeSlideSprite("battle_bg", 0.5, appearTime)
      makeSlideSprite("battle_bg2", 0.5, appearTime)
    end
    # Bases
    makeSlideSprite("base_0", 1, appearTime, PictureOrigin::BOTTOM)
    makeSlideSprite("base_1", -1, appearTime, PictureOrigin::CENTER)
    # Player sprite, partner trainer sprite
    @battle.player.each_with_index do |_p, i|
      makeSlideSprite("player_#{i + 1}", 1, appearTime, PictureOrigin::BOTTOM)
    end
    # Opposing trainer sprite(s) or wild Pokémon sprite(s)
    if @battle.trainerBattle?
      @battle.opponent.each_with_index do |_p, i|
        makeSlideSprite("trainer_#{i + 1}", -1, appearTime, PictureOrigin::BOTTOM)
      end
    else   # Wild battle
      @battle.pbParty(1).each_with_index do |_pkmn, i|
        idxBattler = (2 * i) + 1
        makeSlideSprite("pokemon_#{idxBattler}", -1, appearTime, PictureOrigin::BOTTOM)
      end
    end
    # Shadows
    @battle.battlers.length.times do |i|
      makeSlideSprite("shadow_#{i}", (i.even?) ? 1 : -1, appearTime, PictureOrigin::CENTER)
    end
    # Fading blackness over whole screen
    blackScreen = addNewSprite(0, 0, "Graphics/Battle animations/black_screen")
    blackScreen.setZ(0, 99999)
    blackScreen.moveOpacity(0, 8, 0)
    # Fading blackness over command bar
    blackBar = addNewSprite(@sprites["cmdBar_bg"].x, @sprites["cmdBar_bg"].y,
                            "Graphics/Battle animations/black_bar")
    blackBar.setZ(0, 99998)
    blackBar.moveOpacity(appearTime * 3 / 4, appearTime / 4, 0)
  end
end

#===============================================================================
# Shows a Pokémon being sent out on the player's side (including by a partner).
# Includes the Poké Ball being thrown.
#===============================================================================
class Battle::Scene::Animation::PokeballPlayerSendOut < Battle::Scene::Animation
  def createProcesses
    batSprite = @sprites["pokemon_#{@battler.index}"]
    shaSprite = @sprites["shadow_#{@battler.index}"]
    traSprite = @sprites["player_#{@idxTrainer}"]
    # Calculate the Poké Ball graphic to use
    poke_ball = (batSprite.pkmn) ? batSprite.pkmn.poke_ball : nil
    # Calculate the color to turn the battler sprite
    col = getBattlerColorFromPokeBall(poke_ball)
    col.alpha = 255
    # Calculate start and end coordinates for battler sprite movement
    ballPos = Battle::Scene.pbBattlerPosition(@battler.index, batSprite.sideSize)
    battlerStartX = ballPos[0]   # Is also where the Ball needs to end
    battlerStartY = ballPos[1]   # Is also where the Ball needs to end + 18
    battlerEndX = batSprite.x
    battlerEndY = batSprite.y
    # Calculate start and end coordinates for Poké Ball sprite movement
    ballStartX = -6
    ballStartY = 202
    ballMidX = 0   # Unused in trajectory calculation
    ballMidY = battlerStartY - 144
    # Set up Poké Ball sprite
    ball = addBallSprite(ballStartX, ballStartY, poke_ball)
    ball.setZ(0, 1025)
    ball.setVisible(0, false)
    # Poké Ball tracking the player's hand animation (if trainer is visible)
    if @showingTrainer && traSprite && traSprite.x > 0
      ball.setZ(0, traSprite.z - 1)
      ballStartX, ballStartY = ballTracksHand(ball, traSprite)
    end
    delay = ball.totalDuration   # 0 or 7
    # Poké Ball trajectory animation
    createBallTrajectory(ball, delay, 12,
                         ballStartX, ballStartY, ballMidX, ballMidY, battlerStartX, battlerStartY - 18)
    ball.setZ(9, batSprite.z - 1)
    delay = ball.totalDuration + 4
    delay += 10 * @idxOrder   # Stagger appearances if multiple Pokémon are sent out at once
    ballOpenUp(ball, delay - 2, poke_ball)
    ballBurst(delay, ball, battlerStartX, battlerStartY - 18, poke_ball)
    ball.moveOpacity(delay + 2, 2, 0)
    # Set up battler sprite
    battler = addSprite(batSprite, PictureOrigin::BOTTOM)
    battler.setXY(0, battlerStartX, battlerStartY)
    battler.setZoom(0, 0)
    battler.setColor(0, col)
    # Battler animation
    battlerAppear(battler, delay, battlerEndX, battlerEndY, batSprite, col)
    if @shadowVisible
      # Set up shadow sprite
      shadow = addSprite(shaSprite, PictureOrigin::CENTER)
      shadow.setOpacity(0, 0)
      # Shadow animation
      shadow.setVisible(delay, @shadowVisible)
      shadow.moveOpacity(delay + 5, 10, 255)
    end
  end
end

#===============================================================================
# Shows the player throwing a Poké Ball and it being deflected
#===============================================================================
class Battle::Scene::Animation::PokeballThrowDeflect < Battle::Scene::Animation
  def createProcesses
    # Calculate start and end coordinates for battler sprite movement
    batSprite = @sprites["pokemon_#{@battler.index}"]
    ballPos = Battle::Scene.pbBattlerPosition(@battler.index, batSprite.sideSize)
    ballStartX = -6
    ballStartY = 246
    ballMidX   = 190   # Unused in arc calculation
    ballMidY   = 78
    ballEndX   = ballPos[0]
    ballEndY   = 112
    # Set up Poké Ball sprite
    ball = addBallSprite(ballStartX, ballStartY, @poke_ball)
    ball.setZ(0, 5090)
    # Poké Ball arc animation
    ball.setSE(0, "Battle throw")
    createBallTrajectory(ball, 0, 16,
                         ballStartX, ballStartY, ballMidX, ballMidY, ballEndX, ballEndY)
    # Poké Ball knocked back
    delay = ball.totalDuration
    ball.setSE(delay, "Battle ball drop")
    ball.moveXY(delay, 8, -32, Graphics.height - 96 + 32)   # Back to player's corner
    createBallTumbling(ball, delay, 8)
  end
end
