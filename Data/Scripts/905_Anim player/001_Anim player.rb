#===============================================================================
#
#===============================================================================
class AnimationPlayer
  attr_accessor :looping
  attr_accessor :slowdown   # 1 = normal speed, 2 = half speed, 3 = one third speed, etc.

  # animation is either a GameData::Animation or a hash made from one.
  # user is a Battler, or nil
  # targets is an array of Battlers, or nil
  def initialize(animation, user, targets, scene)
    @animation = animation
    @user = user
    @targets = targets
    @scene = scene
    @viewport = @scene.viewport
    @sprites = @scene.sprites
    initialize_battler_sprite_names
    initialize_battler_coordinates
    @looping = false
    @slowdown = 1
    @timer_start = nil
    @anim_sprites = []   # Each is a ParticleSprite
    @spawner_sprites = []
    @duration = total_duration
  end

  # Doesn't actually create any sprites; just gathers them into a more useful array
  def initialize_battler_sprite_names
    @battler_sprites = []
    if @user
      pkmn = @user.pokemon
      @battler_sprites[@user.index] = []
      @battler_sprites[@user.index].push(GameData::Species.front_sprite_filename(
          pkmn.species, pkmn.form, pkmn.gender))
      @battler_sprites[@user.index].push(GameData::Species.back_sprite_filename(
        pkmn.species, pkmn.form, pkmn.gender))
    end
    if @targets
      @targets.each do |target|
        pkmn = target.pokemon
        @battler_sprites[target.index] = []
        @battler_sprites[target.index].push(GameData::Species.front_sprite_filename(
            pkmn.species, pkmn.form, pkmn.gender))
        @battler_sprites[target.index].push(GameData::Species.back_sprite_filename(
          pkmn.species, pkmn.form, pkmn.gender))
      end
    end
  end

  def initialize_battler_coordinates
    @user_coords = nil
    if @user
      sprite = @sprites["pokemon_#{@user.index}"]
      @user_coords = [sprite.x, sprite.y - (sprite.bitmap.height / 2)]
    end
    @target_coords = []
    if @targets
      @targets.each do |target|
        sprite = @sprites["pokemon_#{target.index}"]
        @target_coords[target.index] = [sprite.x, sprite.y - (sprite.bitmap.height / 2)]
      end
    end
  end

  def dispose
    @anim_sprites.each { |particle| particle.dispose }
    @anim_sprites.clear
  end

  #-----------------------------------------------------------------------------

  def particles
    return (@animation.is_a?(GameData::Animation)) ? @animation.particles : @animation[:particles]
  end

  # Return value is in seconds.
  def total_duration
    ret = AnimationPlayer::Helper.get_duration(particles) / 20.0
    ret *= slowdown
    return ret
  end

  #-----------------------------------------------------------------------------

  def set_up_particle(particle, target_idx = -1, instance = 0)
    particle_sprite = AnimationPlayer::ParticleSprite.new
    # Get/create a sprite
    sprite = nil
    case particle[:name]
    when "User"
      sprite = @sprites["pokemon_#{@user.index}"]
      particle_sprite.set_as_battler_sprite
    when "Target"
      sprite = @sprites["pokemon_#{target_idx}"]
      particle_sprite.set_as_battler_sprite
    when "SE"
      # Intentionally no sprite created
    else
      sprite = Sprite.new(@viewport)
    end
    particle_sprite.sprite = sprite if sprite
    # Set sprite's graphic and ox/oy
    if sprite
      AnimationPlayer::Helper.set_bitmap_and_origin(particle, sprite, @user&.index, target_idx,
        @battler_sprites[@user&.index || -1], @battler_sprites[target_idx])
      end
    # Calculate x/y/z focus values and additional x/y modifier and pass them all
    # to particle_sprite
    focus_xy = AnimationPlayer::Helper.get_xy_focus(particle, @user&.index, target_idx,
                                                    @user_coords, @target_coords[target_idx])
    offset_xy = AnimationPlayer::Helper.get_xy_offset(particle, sprite)
    focus_z = AnimationPlayer::Helper.get_z_focus(particle, @user&.index, target_idx)
    particle_sprite.focus_xy = focus_xy
    particle_sprite.offset_xy = offset_xy
    particle_sprite.focus_z = focus_z
    # Set whether properties should be modified if the particle's target is on
    # the opposing side
    relative_to_index = -1
    if GameData::Animation::FOCUS_TYPES_WITH_USER.include?(particle[:focus])
      relative_to_index = @user.index
    elsif GameData::Animation::FOCUS_TYPES_WITH_TARGET.include?(particle[:focus])
      relative_to_index = target_idx
    end
    if relative_to_index >= 0 && relative_to_index.odd? && particle[:focus] != :user_and_target
      particle_sprite.foe_invert_x = particle[:foe_invert_x]
      particle_sprite.foe_invert_y = particle[:foe_invert_y]
      particle_sprite.foe_flip = particle[:foe_flip]
    end
    particle_sprite.base_angle = 0
    case particle[:angle_override]
    when :initial_angle_to_focus
      target_x = (focus_xy.length == 2) ? focus_xy[1][0] : focus_xy[0][0]
      target_x += offset_xy[0]
      target_y = (focus_xy.length == 2) ? focus_xy[1][1] : focus_xy[0][1]
      target_y += offset_xy[1]
      particle_sprite.base_angle = AnimationPlayer::Helper.initial_angle_between(particle, focus_xy, offset_xy)
    when :always_point_at_focus
      particle_sprite.angle_override = particle[:angle_override] if relative_to_index >= 0
    end
    # Find earliest command and add a "make visible" command then
    delay = AnimationPlayer::Helper.get_particle_delay(particle, instance)
    if sprite && !particle_sprite.battler_sprite?
      first_cmd = AnimationPlayer::Helper.get_first_command_frame(particle)
      particle_sprite.add_set_process(:visible, (first_cmd + delay) * slowdown, true) if first_cmd >= 0
      # Apply random frame
      if particle[:random_frame_max] && particle[:random_frame_max] > 0
        particle_sprite.add_set_process(:frame, (first_cmd + delay) * slowdown, rand(particle[:random_frame_max] + 1))
      end
    end
    # Add all commands
    spawner_type = particle[:spawner] || :none
    regular_properties_skipped = AnimationPlayer::Helper::PROPERTIES_SET_BY_SPAWNER[spawner_type] || []
    particle.each_pair do |property, cmds|
      next if !cmds.is_a?(Array) || cmds.empty?
      next if regular_properties_skipped.include?(property)
      cmds.each do |cmd|
        if cmd[1] == 0
          if sprite
            particle_sprite.add_set_process(property, (cmd[0] + delay) * slowdown, cmd[2])
          else
            # SE particle
            filename = nil
            case property
            when :user_cry
              filename = GameData::Species.cry_filename_from_pokemon(@user.pokemon) if @user
            when :target_cry
              # NOTE: If there are multiple targets, only the first one's cry
              #       will be played.
              if @targets && !@targets.empty?
                filename = GameData::Species.cry_filename_from_pokemon(@targets.first.pokemon)
              end
            else
              filename = "Anim/" + cmd[2]
            end
            particle_sprite.add_set_process(property, (cmd[0] + delay) * slowdown, [filename, cmd[3], cmd[4]]) if filename
          end
        else
          particle_sprite.add_move_process(property, (cmd[0] + delay) * slowdown, cmd[1] * slowdown, cmd[2], cmd[3] || :linear)
        end
      end
    end
    # Finish up
    @anim_sprites.push(particle_sprite)
    @spawner_sprites.push([particle_sprite, particle, target_idx, instance, delay]) if spawner_type != :none
  end

  def add_spawner_commands(particle_sprite, particle, target_idx, instance, delay, add_as_spawner = true)
    spawner_type = particle[:spawner] || :none
    return if spawner_type == :none
    @spawner_sprites.push([particle_sprite, particle, target_idx, instance, delay]) if add_as_spawner
    life_start = AnimationPlayer::Helper.get_first_command_frame(particle)
    life_end = AnimationPlayer::Helper.get_last_command_frame(particle)
    life_end = AnimationPlayer::Helper.get_duration(particles) if life_end < 0
    lifetime = life_end - life_start
    case spawner_type
    when :random_direction, :random_direction_gravity, :random_up_direction_gravity
      if spawner_type == :random_up_direction_gravity
        angle = 30 + rand(120)
      else
        angle = rand(360)
        angle = rand(360) if angle >= 180 && spawner_type == :random_direction_gravity   # Prefer upwards angles
      end
      speed = rand(200, 400)
      start_x_speed = speed * Math.cos(angle * Math::PI / 180)
      start_y_speed = -speed * Math.sin(angle * Math::PI / 180)
      start_x = (start_x_speed * 0.05) + rand(-8, 8)
      start_y = (start_y_speed * 0.05) + rand(-8, 8)
      # Set initial positions
      [:x, :y].each do |property|
        particle_sprite.delete_processes(property)
        if particle[property] && !particle[property].empty?
          offset = (property == :x) ? start_x : start_y
          particle[property].each do |cmd|
            next if cmd[1] > 0
            particle_sprite.add_set_process(property, (cmd[0] + delay) * slowdown, cmd[2] + offset)
            break
          end
        end
      end
      # Set movements
      particle_sprite.add_move_process(:x,
        (life_start + delay) * slowdown, lifetime * slowdown,
        start_x + (start_x_speed * lifetime / 20.0), :linear)
      if [:random_direction_gravity, :random_up_direction_gravity].include?(spawner_type)
        particle_sprite.add_move_process(:y,
          (life_start + delay) * slowdown, lifetime * slowdown,
          [start_y_speed / slowdown, AnimationPlayer::Helper::GRAVITY_STRENGTH.to_f / (slowdown * slowdown)], :gravity)
      else
        particle_sprite.add_move_process(:y,
          (life_start + delay) * slowdown, lifetime * slowdown,
          start_y + (start_y_speed * lifetime / 20.0), :linear)
      end
    end
  end

  # Creates sprites and ParticleSprites, and sets sprite properties that won't
  # change during the animation.
  def set_up
    particles.each do |particle|
      qty = 1
      qty = particle[:spawn_quantity] || 1 if particle[:spawner] && particle[:spawner] != :none
      qty.times do |i|
        if GameData::Animation::FOCUS_TYPES_WITH_TARGET.include?(particle[:focus]) && @targets
          one_per_side = [:target_side_foreground, :target_side_background].include?(particle[:focus])
          sides_covered = []
          @targets.each do |target|
            next if one_per_side && sides_covered.include?(target.index % 2)
            set_up_particle(particle, target.index, i)
            sides_covered.push(target.index % 2)
          end
        else
          set_up_particle(particle, -1, i)
        end
      end
    end
    reset_anim_sprites
  end

  # Sets the initial properties of all sprites, and marks all processes as not
  # yet started.
  def reset_anim_sprites
    @anim_sprites.each { |particle| particle.reset_processes }
    # Randomise spawner particle properties
    @spawner_sprites.each { |spawner| add_spawner_commands(*spawner, false) }
  end

  #-----------------------------------------------------------------------------

  def start
    @timer_start = System.uptime
  end

  def playing?
    return !@timer_start.nil?
  end

  def finish
    @timer_start = nil
    @finished = true
  end

  def finished?
    return @finished
  end

  def can_continue_battle?
    return finished?
  end

  #-----------------------------------------------------------------------------

  def update
    return if !playing?
    if @need_reset
      reset_anim_sprites
      start
      @need_reset = false
    end
    time_now = System.uptime
    elapsed = time_now - @timer_start
    # Update all particles/sprites
    @anim_sprites.each { |particle| particle.update(elapsed) }
    # Finish or loop the animation
    if elapsed >= @duration * @slowdown
      if looping
        @need_reset = true
      else
        finish
      end
    end
  end
end
