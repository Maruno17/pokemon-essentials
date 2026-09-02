#===============================================================================
#
#===============================================================================
class AnimationPlayer
  attr_accessor :looping
  attr_reader   :slowdown   # 1 = normal speed, 2 = half speed, 3 = one third speed, etc.
  attr_reader   :sprites, :particle_sprites, :emitters

  # animation is either a GameData::Animation or a hash made from one.
  # user is a Battler, or nil.
  # targets is an array of Battlers, or nil.
  # scene is either Battle::Scene or AnimationEditor::Canvas.
  def initialize(animation, user, targets, scene)
    @animation = animation
    @user = user
    @targets = targets
    @scene = scene
    @side_sizes = [1, 1]
    if @scene.is_a?(Battle::Scene)
      @side_sizes[0] = @scene.battle.pbSideSize(0)
      @side_sizes[1] = @scene.battle.pbSideSize(1)
    elsif @scene.is_a?(AnimationEditor::Canvas)
      @side_sizes[0] = @scene.side_size(0)
      @side_sizes[1] = @scene.side_size(1)
    end
    @viewport = @scene.viewport
    @sprites = @scene.sprites
    initialize_battler_sprite_names
    initialize_battler_coordinates
    @looping = false
    @slowdown = 1
    @timer_start = nil
    @particle_sprites = []   # Each is a ParticleSprite
    @emitters = []
    @fps = (@animation.is_a?(GameData::Animation)) ? @animation.fps : @animation[:fps]
    @duration = total_duration
  end

  # Doesn't actually create any sprites; just gathers them into a more useful
  # array.
  def initialize_battler_sprite_names
    @battler_filenames = []
    if @user
      pkmn = @user.pokemon
      @battler_filenames[@user.index] = []
      @battler_filenames[@user.index].push(GameData::Species.front_sprite_filename(
        pkmn.species, pkmn.form, pkmn.gender, pkmn.shiny?)
      )
      @battler_filenames[@user.index].push(GameData::Species.back_sprite_filename(
        pkmn.species, pkmn.form, pkmn.gender, pkmn.shiny?)
      )
    end
    if @targets
      @targets.each do |target|
        pkmn = target.pokemon
        @battler_filenames[target.index] = []
        @battler_filenames[target.index].push(GameData::Species.front_sprite_filename(
          pkmn.species, pkmn.form, pkmn.gender, pkmn.shiny?)
        )
        @battler_filenames[target.index].push(GameData::Species.back_sprite_filename(
          pkmn.species, pkmn.form, pkmn.gender, pkmn.shiny?)
        )
      end
    end
  end

  # Get the centers of each battler involved in the animation.
  def initialize_battler_coordinates
    @user_coords = nil
    if @user
      sprite = @sprites["pokemon_#{@user.index}"]
      @user_coords = [sprite.x - sprite.ox + (sprite.bitmap.width / 2),
                      sprite.y - sprite.oy + (sprite.bitmap.height / 2)]
    end
    @target_coords = []
    if @targets
      @targets.each do |target|
        sprite = @sprites["pokemon_#{target.index}"]
        @target_coords[target.index] = [sprite.x - sprite.ox + (sprite.bitmap.width / 2),
                                        sprite.y - sprite.oy + (sprite.bitmap.height / 2)]
      end
    end
  end

  def dispose
    @particle_sprites.each { |particle| particle&.dispose }
    @particle_sprites.clear
    @emitters.each { |emitter| emitter&.dispose }
    @emitters.clear
  end

  #-----------------------------------------------------------------------------

  def particles
    return (@animation.is_a?(GameData::Animation)) ? @animation.particles : @animation[:particles]
  end

  # Return value is in seconds.
  def total_duration
    ret = AnimationPlayer::Helper.get_duration(particles) / @fps.to_f
    ret *= @slowdown
    return ret
  end

  def slowdown=(value)
    @slowdown = value
    @duration = total_duration
  end

  # If the particle's focus is :user_and_target, this will return the user's
  # index.
  def index_of_particle_focus(particle, target_idx = -1)
    ret = -1
    if GameData::Animation::FOCUS_TYPES_WITH_USER.include?(particle[:focus])
      ret = @user.index
    elsif GameData::Animation::FOCUS_TYPES_WITH_TARGET.include?(particle[:focus])
      ret = target_idx
    end
    return ret
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
    ((@animation.is_a?(GameData::Animation)) ? @animation.scripts : @animation[:scripts]).each do |script|
      next if !AnimationPlayer::END_ANIMATION_SCRIPTS[script]
      AnimationPlayer::END_ANIMATION_SCRIPTS.trigger(script, self)
    end
  end

  def finished?
    return @finished
  end

  def can_continue_battle?
    return finished?
  end

  #-----------------------------------------------------------------------------

  # Creates sprites and ParticleSprites, and sets sprite properties that won't
  # change during the animation.
  def set_up
    particles.each do |particle|
      if (particle[:emitter_type] || :none) != :none
        set_up_emitter(particle)
        next
      end
      if GameData::Animation::FOCUS_TYPES_WITH_TARGET.include?(particle[:focus]) && @targets
        # One sprite per target
        one_per_side = [:target_side_foreground, :target_side_background].include?(particle[:focus])
        sides_covered = []
        @targets.each do |target|
          next if one_per_side && sides_covered.include?(target.index % 2)
          create_particle_sprite(particle, target.index)
          sides_covered.push(target.index % 2)
        end
      else
        # One sprite
        create_particle_sprite(particle)
      end
    end
    reset_particle_sprites
  end

  # Sets the initial properties of all sprites, and marks all processes as not
  # yet started.
  def reset_particle_sprites
    @particle_sprites.each { |particle| particle.reset_processes }
    @emitters.each { |emitter| emitter.reset_processes }
  end

  #-----------------------------------------------------------------------------

  def create_particle_sprite(particle, target_idx = -1)
    particle_sprite = AnimationPlayer::ParticleSprite.new(particle[:name])
    @particle_sprites.push(particle_sprite)
    create_particle_sprite_assign_sprite(particle_sprite, particle, target_idx)
    create_particle_sprite_set_coordinates(particle_sprite, particle, target_idx)
    create_particle_sprite_set_flips(particle_sprite, particle, target_idx)
    create_particle_sprite_set_base_property_offsets(particle_sprite, particle, target_idx)
    create_particle_sprite_add_commands(particle_sprite, particle, target_idx)
  end

  def create_particle_sprite_assign_sprite(particle_sprite, particle, target_idx = -1)
    # Get/create a sprite
    sprite = nil
    sprite2 = nil
    is_battler_sprite = false
    case particle[:name]
    when "User"
      sprite = @sprites["pokemon_#{@user.index}"]
      is_battler_sprite = true
    when "Target"
      sprite = @sprites["pokemon_#{target_idx}"]
      is_battler_sprite = true
    when "SE"
      # Intentionally no sprite created
    else
      sprite = Sprite.new(@viewport)
    end
    return if sprite.nil?
    # Apply sprite to particle sprite
    particle_sprite.set_sprite(sprite, is_battler_sprite)
    if particle[:second_layer]
      sprite2 = Sprite.new(@viewport)
      particle_sprite.set_sprite(sprite2, false)
    end
    # Set sprite's graphic and ox/oy
    if !is_battler_sprite
      AnimationPlayer::Helper.set_bitmap_and_origin(
        particle, sprite, @user&.index, target_idx,
        @battler_filenames[@user&.index || -1], @battler_filenames[target_idx]
      )
      AnimationPlayer::Helper.set_bitmap_and_origin(
        particle, sprite2, @user&.index, target_idx,
        @battler_filenames[@user&.index || -1], @battler_filenames[target_idx]
      )
      if particle[:tiled_graphic]
        particle_sprite.set_tiled_sprites(particle, @user&.index, target_idx,
                                          @battler_filenames[@user&.index || -1],
                                          @battler_filenames[target_idx])
      end
    end
    if sprite && (particle[:mask_graphic] || "") != ""
      sprite.pattern = RPG::Cache.load_bitmap("Graphics/Battle animations/", particle[:mask_graphic] || "")
    end
  end

  # Calculate x/y/z focus values and additional x/y modifier and pass them all
  # to particle_sprite.
  def create_particle_sprite_set_coordinates(particle_sprite, particle, target_idx = -1)
    focus_xy = AnimationPlayer::Helper.get_xy_focus(
      particle, @user&.index, target_idx, @user_coords, @target_coords[target_idx], @side_sizes
    )
    offset_xy = AnimationPlayer::Helper.get_xy_offset(particle, (particle_sprite.sprite) ? particle_sprite.sprite[0] : nil)
    case particle[:graphic]
    when "USER", "USER_OPP", "USER_FRONT", "USER_BACK"
      sprite = @sprites["pokemon_#{@user.index}"]
      particle_sprite.sprite.each { |spr| spr.ox = sprite.ox }
      particle_sprite.sprite.each { |spr| spr.oy = sprite.oy }
      offset_xy[0] += sprite.ox - (sprite.bitmap.width / 2)
      offset_xy[1] += sprite.oy - sprite.bitmap.height
    when "TARGET", "TARGET_OPP", "TARGET_FRONT", "TARGET_BACK"
      sprite = @sprites["pokemon_#{target_idx}"]
      particle_sprite.sprite.each { |spr| spr.ox = sprite.ox }
      particle_sprite.sprite.each { |spr| spr.oy = sprite.oy }
      offset_xy[0] += sprite.ox - (sprite.bitmap.width / 2)
      offset_xy[1] += sprite.oy - sprite.bitmap.height
    end
    focus_z = AnimationPlayer::Helper.get_z_focus(particle, @user&.index, target_idx)
    particle_sprite.focus_xy = focus_xy
    particle_sprite.offset_xy = offset_xy
    particle_sprite.focus_z = focus_z
  end

  # Set whether properties should be modified if the particle's target is on the
  # opposing side.
  def create_particle_sprite_set_flips(particle_sprite, particle, target_idx = -1)
    relative_to_index = index_of_particle_focus(particle, target_idx)
    no_user = (@animation.is_a?(GameData::Animation)) ? @animation.no_user : @animation[:no_user]
    if (relative_to_index >= 0 && relative_to_index.odd?) ||   # Focus is on opposing side
       (relative_to_index < 0 && !no_user && @user.index.odd?)   # Focus is screen and user exists on opposing side
      particle_sprite.foe_invert_z = particle[:foe_invert_z]
      return if GameData::Animation::FOCUS_TYPES_WITH_USER_AND_TARGET.include?(particle[:focus])
      particle_sprite.foe_invert_x = particle[:foe_invert_x]
      particle_sprite.foe_invert_y = particle[:foe_invert_y]
      particle_sprite.foe_flip     = particle[:foe_flip]
    end
  end

  def create_particle_sprite_set_base_property_offsets(particle_sprite, particle, target_idx = -1)
    particle_sprite.initial_angle = particle[:initial_angle] || :none
    relative_to_index = index_of_particle_focus(particle, target_idx)
    if relative_to_index >= 0
      case particle[:initial_angle] || :none
      when :particle_to_focus
        val = AnimationPlayer::Helper.initial_angle_between(
          particle, particle_sprite.focus_xy, particle_sprite.offset_xy
        )
        particle_sprite.set_base_property_offset(:angle, val)
      end
    end
    if particle[:random_angle_range] && particle[:random_angle_range] != GameData::Animation::PARTICLE_KEYFRAME_DEFAULT_VALUES[:random_angle_range]
      ang = rand(-particle[:random_angle_range], particle[:random_angle_range])
      particle_sprite.set_base_property_offset(:angle, ang)
    end
    particle_sprite.random_invert_angle = particle[:random_invert_angle]
    particle_sprite.random_invert_flip = particle[:random_invert_flip]
  end

  def create_particle_sprite_add_commands(particle_sprite, particle, target_idx = -1)
    # Find earliest command and add a "make visible" command then
    if particle_sprite.sprite && !particle_sprite.is_battler_sprite?
      first_cmd = AnimationPlayer::Helper.get_first_command_frame(particle)
      particle_sprite.add_set_process(:visible, first_cmd * @slowdown / @fps.to_f, true) if first_cmd >= 0
      # Apply random frame
      if particle[:random_frame_max] && particle[:random_frame_max] > 0
        particle_sprite.add_set_process(:frame, first_cmd * @slowdown / @fps.to_f, rand(particle[:random_frame_max] + 1))
      end
    end
    # Add all commands
    particle.each_pair do |property, cmds|
      next if !cmds.is_a?(Array) || cmds.empty?
      next if [:x, :y].include?(property) && particle[:polar_coordinates]
      next if [:r, :theta].include?(property) && !particle[:polar_coordinates]
      cmds.each do |cmd|
        if cmd[1] > 0
          particle_sprite.add_move_process(property, cmd[0] * @slowdown / @fps.to_f, cmd[1] * @slowdown / @fps.to_f, cmd[2], cmd[3] || :linear)
          next
        elsif particle_sprite.sprite
          particle_sprite.add_set_process(property, cmd[0] * @slowdown / @fps.to_f, cmd[2])
          next
        end
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
        particle_sprite.add_set_process(property, cmd[0] * @slowdown / @fps.to_f, [filename, cmd[3], cmd[4]]) if filename
      end
    end
  end

  #-----------------------------------------------------------------------------

  def set_up_emitter(particle)
    emitter = AnimationPlayer::Emitter.new(@viewport, particle, @fps)
    @emitters.push(emitter)
    emitter.slowdown = @slowdown
    emitter.set_user_and_targets(@user, @targets)
    emitter.set_sprites(@sprites)
    emitter.set_battler_filenames(@battler_filenames)
    emitter.set_focus_coords(@user_coords, @target_coords)
    emitter.set_side_sizes(@side_sizes)
    emitter.no_user = (@animation.is_a?(GameData::Animation)) ? @animation.no_user : @animation[:no_user]
    emitter.no_target = (@animation.is_a?(GameData::Animation)) ? @animation.no_target : @animation[:no_target]
    set_up_emitter_parameters(emitter, particle)
    add_emitter_commands(emitter, particle)
  end

  def set_up_emitter_parameters(emitter, particle)
    emitter.emitter_position_polar_coordinates = particle[:emitter_position_polar_coordinates]
    emitter.emitter_spawn_polar_coordinates = particle[:emitter_spawn_polar_coordinates]
  end

  def add_emitter_commands(emitter, particle)
    # Particle commands are given to the emitter as though they begin at
    # keyframe 0]
    frame_offset = AnimationPlayer::Helper.get_first_command_frame(
      particle, AnimationPlayer::Emitter::PARTICLE_PROPERTIES
    )
    # Add all commands
    particle.each_pair do |property, cmds|
      next if !cmds.is_a?(Array) || cmds.empty?
      next if [:x, :y].include?(property) && particle[:polar_coordinates]
      next if [:r, :theta].include?(property) && !particle[:polar_coordinates]
      cmds.each do |cmd|
        if AnimationPlayer::Emitter::PARTICLE_PROPERTIES.include?(property)
          if cmd[1] > 0
            emitter.add_move_process(property, (cmd[0] - frame_offset) * @slowdown / @fps.to_f, cmd[1] * @slowdown / @fps.to_f, cmd[2], cmd[3] || :linear)
          else
            emitter.add_set_process(property, (cmd[0] - frame_offset) * @slowdown / @fps.to_f, cmd[2])
          end
        else
          if cmd[1] > 0
            emitter.add_emitter_move_process(property, cmd[0] * @slowdown / @fps.to_f, cmd[1] * @slowdown / @fps.to_f, cmd[2], cmd[3] || :linear)
          else
            emitter.add_emitter_set_process(property, cmd[0] * @slowdown / @fps.to_f, cmd[2])
          end
        end
      end
    end
  end

  #-----------------------------------------------------------------------------

  def update
    return if !playing?
    if @need_reset
      reset_particle_sprites
      start
      @need_reset = false
    end
    time_now = System.uptime
    elapsed_time = time_now - @timer_start
    # Update all particles/sprites
    @particle_sprites.each { |particle| particle.update(elapsed_time) }
    @emitters.each { |emitter| emitter.update(elapsed_time) }
    # Run update scripts
    ((@animation.is_a?(GameData::Animation)) ? @animation.scripts : @animation[:scripts]).each do |script|
      next if !AnimationPlayer::UPDATE_ANIMATION_SCRIPTS[script]
      AnimationPlayer::UPDATE_ANIMATION_SCRIPTS.trigger(script, self, elapsed_time / @slowdown)
    end
    # Finish or loop the animation
    if elapsed_time >= @duration
      if looping
        @need_reset = true
      else
        finish
      end
    end
  end
end
