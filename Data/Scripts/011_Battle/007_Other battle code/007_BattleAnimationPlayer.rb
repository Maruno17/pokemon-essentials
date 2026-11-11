#===============================================================================
#
#===============================================================================
class AnimationPlayer
  class FakeBattler
    attr_reader :index, :idxOwnSide
    attr_reader :pokemon

    def initialize(index, species, form = 0, gender = 0)
      @index = index
      @idxOwnSide = index & 1
      @pokemon = AnimationPlayer::FakePokemon.new(species, form, gender)
    end
  end

  class FakePokemon
    attr_reader :species, :form, :gender

    def initialize(species, form = 0, gender = 0)
      # NOTE: species will be a string, but it doesn't need to be a symbol.
      @species = species
      @form = form
      @gender = gender
    end

    def shiny?
      return false
    end
  end

  #-----------------------------------------------------------------------------

  attr_accessor :looping
  attr_reader   :slowdown   # 1 = normal speed, 2 = half speed, 3 = one third speed, etc.
  attr_reader   :sprites, :particle_sprites, :emitters
  attr_reader   :scene, :user
  attr_reader   :forceInvisibilities

  # animation is either a GameData::Animation or a hash made from one.
  # user is a Battler or FakeBattler, or nil if there is no user.
  # targets is an array of Battlers or FakeBattlers, or nil if there are none.
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
    @forceInvisibilities = []
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
    case particle[:graphic]
    when "USER", "USER_OPP", "USER_FRONT", "USER_BACK"
      particle_sprite.forceInvisibility = @forceInvisibilities[@user.index]
    when "TARGET", "TARGET_OPP", "TARGET_FRONT", "TARGET_BACK"
      particle_sprite.forceInvisibility = @forceInvisibilities[target_idx]
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
    emitter.forceInvisibilities = @forceInvisibilities
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

#===============================================================================
# NOTE: This assumes that processes are added (for a given property) in the
#       order they happen.
#===============================================================================
class AnimationPlayer::ParticleSprite
  attr_reader   :name
  attr_reader   :sprite, :tiled_sprites
  attr_accessor :focus_xy, :offset_xy, :focus_z
  attr_reader   :property_offsets
  attr_accessor :initial_angle, :random_invert_angle, :random_invert_flip
  attr_accessor :foe_invert_x, :foe_invert_y, :foe_invert_z, :foe_flip
  attr_accessor :slowdown
  attr_reader   :values
  attr_accessor :forceInvisibility
  # Used by particles from emitter
  attr_reader   :emitter_params

  def initialize(name)
    @name = name
    @property_offsets = {}
    @processes = []
    @sprite = nil
    @is_battler_sprite = false
    @emitter_params = {:type => :none, :start_time => 0}
    @slowdown = 1
    initialize_values
  end

  def initialize_values
    @values = GameData::Animation::PARTICLE_KEYFRAME_DEFAULT_VALUES.clone
  end

  def dispose
    return if is_battler_sprite? || !@sprite || @sprite.empty?
    @sprite.each do |spr|
      spr.bitmap&.dispose
      spr.dispose
    end
    @sprite.clear
    if @tiled_sprites
      @tiled_sprites.each { |spr| spr&.dispose }
      @tiled_sprites.clear
    end
  end

  #-----------------------------------------------------------------------------

  # NOTE: is_battler is needed because sprite.is_a?(Battle::Scene::BattlerSprite)
  #       won't work in the Animation Editor, where battler sprites are just
  #       Sprites.
  def set_sprite(sprite, is_battler = false)
    @sprite ||= []
    @sprite.push(sprite)
    set_as_battler_sprite if is_battler
  end

  def set_tiled_sprites(particle, user_index, target_index, user_sprites, target_sprites)
    @tiled_sprites = []
    3.times do |i|
      @tiled_sprites.push(Sprite.new(@sprite[0].viewport))
      AnimationPlayer::Helper.set_bitmap_and_origin(
        particle, @tiled_sprites.last, user_index, target_index, user_sprites, target_sprites
      )
    end
  end

  def set_as_battler_sprite
    @is_battler_sprite = true
    @values[:visible] = true
  end

  def is_battler_sprite?
    return @is_battler_sprite
  end

  #-----------------------------------------------------------------------------

  def set_base_property_offset(property, value)
    @property_offsets[property] = value
  end

  #-----------------------------------------------------------------------------

  # start_time is in seconds.
  def add_set_process(property, start_time, value)
    add_move_process(property, start_time, 0, value, :none)
  end

  # start_time and duration are in seconds.
  def add_move_process(property, start_time, duration, value, interpolation = :linear)
    # First nil is progress (nil = not started, true = running, false = finished)
    # Second nil is start value (set when the process starts running)
    @processes.push([property, start_time, duration, value, interpolation, nil, nil])
  end

  def delete_processes(property)
    @processes.delete_if { |process| process[0] == property }
  end

  # Sets sprite's initial properties. For looping purposes.
  def reset_processes
    initialize_values
    set_as_battler_sprite if is_battler_sprite?   # Start battler sprites as visible
    @values.each_pair { |property, value| apply_sprite_property(property, value) }
    @processes.each { |process| process[5] = nil }
  end

  #-----------------------------------------------------------------------------

  def start_process(process)
    return if !process[5].nil?
    process[6] = @values[process[0]]
    process[5] = true
  end

  def update_process_value(process, elapsed_time)
    # SetXYZ
    if process[2] == 0
      @values[process[0]] = process[3]
      process[5] = false   # Mark process as finished
      return
    end
    # MoveXYZ
    case process[0]
    when :color, :color2
      new_val = []
      4.times do |i|   # R, G, B, A
        start_val = process[6][2 * i, 2].to_i(16)
        end_val = process[3][2 * i, 2].to_i(16)
        val = AnimationPlayer::Helper.interpolate(
          process[4], start_val, end_val, process[2],
          process[1], elapsed_time
        )
        new_val.push(sprintf("%02X", val))
      end
      @values[process[0]] = new_val.join
    when :tone, :tone2
      new_val = []
      4.times do |i|   # R, G, B, G
        start_val = process[6][3 * i, 3].to_i(16)
        end_val = process[3][3 * i, 3].to_i(16)
        val = AnimationPlayer::Helper.interpolate(
          process[4], start_val, end_val, process[2],
          process[1], elapsed_time
        )
        new_val.push((val >= 0 ? "+" : "-") + sprintf("%02X", val.abs))
      end
      @values[process[0]] = new_val.join
    else
      @values[process[0]] = AnimationPlayer::Helper.interpolate(
        process[4], process[6], process[3], process[2],
        process[1], elapsed_time
      )
    end
    # Mark process as finished (if it has)
    process[5] = false if elapsed_time >= process[1] + process[2]
  end

  # Calculates (usually only) :x and :y based on the emitter type.
  def update_emitter_type_properties(elapsed_time, changed_properties)
    return if (@emitter_params[:type] || :none) == :none
    delta_t = (elapsed_time - @emitter_params[:start_time]) / @slowdown.to_f
    case (@emitter_params[:type] || :none)
    when :no_movement
      # NOTE: This doesn't change any properties.
    when :straight
      if @emitter_params[:speed_x] != 0
        new_x = (@emitter_params[:speed_x] * delta_t).round
        @values[:auto_movement_x] = new_x
        changed_properties.push(:x)
      end
      if @emitter_params[:speed_y] != 0
        new_y = (@emitter_params[:speed_y] * delta_t).round
        @values[:auto_movement_y] = new_y
        changed_properties.push(:y)
      end
    when :projectile
      if @emitter_params[:speed_x] != 0
        new_x = (@emitter_params[:speed_x] * delta_t).round
        @values[:auto_movement_x] = new_x
        changed_properties.push(:x)
      end
      if @emitter_params[:speed_y] != 0 || @emitter_params[:gravity] != 0
        new_y = ((@emitter_params[:speed_y] * delta_t) + (@emitter_params[:gravity] * delta_t * delta_t / 2)).round   # s = ut + 1/2 at^2
        @values[:auto_movement_y] = new_y
        changed_properties.push(:y)
      end
    when :dampened
      use_time = delta_t
      if @emitter_params[:deceleration] > 0
        balance_time = (@emitter_params[:speed].to_f / @emitter_params[:deceleration]).abs
        use_time = balance_time if use_time > balance_time
      end
      if @emitter_params[:speed_x] != 0
        new_x = ((@emitter_params[:speed_x] * use_time) + (@emitter_params[:deceleration_x] * use_time * use_time / 2)).round   # s = ut + 1/2 at^2
        @values[:auto_movement_x] = new_x
        changed_properties.push(:x)
      end
      if @emitter_params[:speed_y] != 0
        new_y = ((@emitter_params[:speed_y] * use_time) + (@emitter_params[:deceleration_y] * use_time * use_time / 2)).round   # s = ut + 1/2 at^2
        @values[:auto_movement_y] = new_y
        changed_properties.push(:y)
      end
    when :helix
      if @emitter_params[:period_x] != 0
        new_angle = @emitter_params[:direction] || 0
        new_angle += (360 * delta_t / @emitter_params[:period_x]) * (@emitter_params[:clockwise] ? -1 : 1)
        new_x = @values[:radius_x] * @emitter_params[:radius_x_mult] * Math.sin(new_angle * Math::PI / 180)
        @values[:auto_movement_x] = new_x
        changed_properties.push(:x)
      end
      if @emitter_params[:speed] != 0
        new_y = (@emitter_params[:speed] * delta_t).round
        @values[:auto_movement_y] = new_y
        changed_properties.push(:y)
      end
      if @emitter_params[:period_z] != 0
        new_angle = @emitter_params[:direction] || 0
        new_angle += (360 * delta_t / @emitter_params[:period_z]) * (@emitter_params[:clockwise] ? -1 : 1)
        new_z = @values[:radius_z] * @emitter_params[:radius_z_mult] * Math.cos(new_angle * Math::PI / 180)
        @values[:auto_movement_z] = new_z
        changed_properties.push(:z)
      end
    when :polar
      if @emitter_params[:period_x] != 0
        new_angle = @emitter_params[:direction] || 0
        new_angle += (360 * delta_t / @emitter_params[:period_x]) * (@emitter_params[:clockwise] ? -1 : 1)
        new_x = @values[:radius_x] * @emitter_params[:radius_x_mult] * Math.cos(new_angle * Math::PI / 180)
        @values[:auto_movement_x] = new_x
        changed_properties.push(:x)
      end
      if @emitter_params[:period_y] != 0
        new_angle = (@emitter_params[:direction] || 0) + (360 * delta_t / @emitter_params[:period_y])
        new_y = -@values[:radius_y] * @emitter_params[:radius_y_mult] * Math.sin(new_angle * Math::PI / 180)
        @values[:auto_movement_y] = new_y
        changed_properties.push(:y)
      end
    end
  end

  def update_sprite(changed_properties)
    changed_properties.uniq!
    changed_properties.each do |property|
      apply_sprite_property(property, @values[property])
    end
  end

  def apply_sprite_property(property, value)
    if !@sprite
      pbSEPlay(*value) if [:se, :user_cry, :target_cry].include?(property) && value
      return
    end
    case property
    when :x, :spawn_x_offset, :spawn_x_multiplier
      value = @values[:x].round   # Spawn point to current location
      value += @values[:auto_movement_x] || 0   # Used by emitters
      spawn_offset = (@property_offsets[:spawn_x] || 0) + (@values[:spawn_x_offset] || 0)
      spawn_offset *= @values[:spawn_x_multiplier] / 100.0
      value += spawn_offset   # Emitter to spawn point
      value += (@property_offsets[:emitter_x] || 0)   # Focus to emitter
      value *= @emitter_params[:x_multiplier] || 1
      value *= -1 if @foe_invert_x
      AnimationPlayer::Helper.apply_xy_value_using_focus_to_sprite(@sprite[0], :x, value, @focus_xy)   # Screen to focus
      @sprite[0].x += @offset_xy[0]
      # Apply value to other sprites
      apply_sprite_property(:x2, @values[:x2])   # Second layer
      if @tiled_sprites
        while @sprite[0].x < 0
          @sprite[0].x += @sprite[0].src_rect.width
        end
        while @sprite[0].x >= @sprite[0].src_rect.width
          @sprite[0].x -= @sprite[0].src_rect.width
        end
        @tiled_sprites.each_with_index do |spr, i|
          spr.x = @sprite[0].x
          spr.x -= @sprite[0].src_rect.width if i.even?
        end
      end
      apply_sprite_property_override(:angle)
    when :x2
      @sprite[1].x = @sprite[0].x + value if @sprite[1]
    when :y, :spawn_y_offset, :spawn_y_multiplier
      value = @values[:y].round   # Spawn point to current location
      value += @values[:auto_movement_y] || 0   # Used by emitters
      spawn_offset = (@property_offsets[:spawn_y] || 0) + (@values[:spawn_y_offset] || 0)
      spawn_offset *= @values[:spawn_y_multiplier] / 100.0
      value += spawn_offset   # Emitter to spawn point
      value += (@property_offsets[:emitter_y] || 0)   # Focus to emitter
      value *= @emitter_params[:y_multiplier] || 1
      value *= -1 if @foe_invert_y
      AnimationPlayer::Helper.apply_xy_value_using_focus_to_sprite(@sprite[0], :y, value, @focus_xy)   # Screen to focus
      @sprite[0].y += @offset_xy[1]
      # Apply value to other sprites
      apply_sprite_property(:y2, @values[:y2])   # Second layer
      if @tiled_sprites
        while @sprite[0].y < 0
          @sprite[0].y += @sprite[0].src_rect.height
        end
        while @sprite[0].y >= @sprite[0].src_rect.height
          @sprite[0].y -= @sprite[0].src_rect.height
        end
        @tiled_sprites.each_with_index do |spr, i|
          spr.y = @sprite[0].y
          spr.y -= @sprite[0].src_rect.height if i > 0
        end
      end
      apply_sprite_property_override(:angle)
    when :y2
      @sprite[1].y = @sprite[0].y + value if @sprite[1]
    when :r, :theta
      dist = @values[:r]
      dir = @values[:theta]
      @values[:x] = (dist * Math.cos(dir * Math::PI / 180)).round
      @values[:y] = (-dist * Math.sin(dir * Math::PI / 180)).round
      apply_sprite_property(:x, @values[:x])
      apply_sprite_property(:y, @values[:y])
    when :spawn_r_offset, :spawn_theta_offset, :spawn_r_multiplier
      dist = (@property_offsets[:spawn_r] || 0) + (@values[:spawn_r_offset] || 0)
      dist *= @values[:spawn_r_multiplier] / 100.0
      dir = (@property_offsets[:spawn_theta] || 0) + (@values[:spawn_theta_offset] || 0)
      @values[:spawn_x_offset] = dist * Math.cos(dir * Math::PI / 180)
      @values[:spawn_x_offset] -= (@property_offsets[:spawn_x] || 0)
      @values[:spawn_y_offset] = -dist * Math.sin(dir * Math::PI / 180)
      @values[:spawn_y_offset] -= (@property_offsets[:spawn_y] || 0)
      apply_sprite_property(:x, @values[:x])
      apply_sprite_property(:y, @values[:y])
    when :z
      value += @values[:auto_movement_z] || 0   # Used by emitters
      value += (@property_offsets[property] || 0)
      value += @emitter_params[:z] || 0
      if @foe_invert_z
        if @focus_z.is_a?(Array)
          value = AnimationEditor::PROPERTY_RANGES[:z].sum + GameData::Animation::USER_AND_TARGET_SEPARATION[2] - value
        else
          value *= -1
        end
      end
      AnimationPlayer::Helper.apply_z_focus_to_sprite(@sprite[0], value, @focus_z)
      apply_sprite_property(:z2, @values[:z2])
      if @tiled_sprites
        @tiled_sprites.each { |spr| spr.z = @sprite[0].z }
      end
    when :z2
      @sprite[1].z = @sprite[0].z + value if @sprite[1]
    when :zoom_x
      value += (@property_offsets[property] || 0)
      value *= @emitter_params[:zoom_multiplier] || 1
      value *= @emitter_params[:zoom_mult] || 1
      value *= @emitter_params[:zoom_x_mult] || 1
      @sprite[0].zoom_x = value / 100.0
      apply_sprite_property(:zoom_x2, @values[:zoom_x2])
    when :zoom_x2
      @sprite[1].zoom_x = @sprite[0].zoom_x * value / 100.0 if @sprite[1]
    when :zoom_y
      value += (@property_offsets[property] || 0)
      value *= @emitter_params[:zoom_multiplier] || 1
      value *= @emitter_params[:zoom_mult] || 1
      value *= @emitter_params[:zoom_y_mult] || 1
      @sprite[0].zoom_y = value / 100.0
      apply_sprite_property(:zoom_y2, @values[:zoom_y2])
    when :zoom_y2
      @sprite[1].zoom_y = @sprite[0].zoom_y * value / 100.0 if @sprite[1]
    when :angle
      if @initial_angle == :always_particle_to_focus
        apply_sprite_property_override(:angle)
      else
        value += (@property_offsets[property] || 0)
        value += @emitter_params[:angle] || 0
        @sprite[0].angle = value
      end
      @sprite[0].angle *= -1 if @random_invert_angle
      apply_sprite_property(:angle2, @values[:angle2])
    when :angle2
     if @sprite[1]
        new_val = value
        new_val *= -1 if @random_invert_angle
        @sprite[1].angle = @sprite[0].angle + new_val
      end
    when :flip
      @sprite[0].mirror = value
      @sprite[0].mirror = !@sprite[0].mirror if @foe_flip
      @sprite[0].mirror = !@sprite[0].mirror if @random_invert_flip
      apply_sprite_property(:flip2, @values[:flip2])
      if @tiled_sprites
        @tiled_sprites.each { |spr| spr.mirror = @sprite[0].mirror }
      end
    when :flip2
     if @sprite[1]
        @sprite[1].mirror = @sprite[0].mirror
        @sprite[1].mirror = !@sprite[1].mirror if value
      end
    when :visible
      @sprite.each { |spr| spr.visible = !@forceInvisibility && value }
      if @tiled_sprites
        @tiled_sprites.each { |spr| spr.visible = !@forceInvisibility && value }
      end
    when :opacity
      value += (@property_offsets[property] || 0)
      value *= @emitter_params[:opacity_multiplier] || 1
      @sprite[0].opacity = value
      apply_sprite_property(:opacity2, @values[:opacity2]) if @sprite[1]
      if @tiled_sprites
        @tiled_sprites.each { |spr| spr.opacity = @sprite[0].opacity }
      end
    when :opacity2
      if @sprite[1]
        @sprite[1].opacity = @sprite[0].opacity + (value * (@emitter_params[:opacity_multiplier] || 1))
      end
    when :color
      @sprite[0].color = Color.new_from_rgb(value)
      if @tiled_sprites
        @tiled_sprites.each { |spr| spr.color = Color.new_from_rgb(value) }
      end
    when :color2
      @sprite[1].color = Color.new_from_rgb(value) if @sprite[1]
    when :tone
      @sprite[0].tone = Tone.new_from_rgbg(value)
      if @tiled_sprites
        @tiled_sprites.each { |spr| spr.tone = Tone.new_from_rgbg(value) }
      end
    when :tone2
      @sprite[1].tone = Tone.new_from_rgbg(value) if @sprite[1]
    when :invert_color
      @sprite[0].invert = value
      apply_sprite_property(:invert_color2, @values[:invert_color2])
      if @tiled_sprites
        @tiled_sprites.each { |spr| spr.invert = @sprite[0].invert }
      end
    when :invert_color2
      if @sprite[1]
        @sprite[1].invert = @sprite[0].invert
        @sprite[1].invert = !@sprite[1].invert if value
      end
    when :frame
      value += (@property_offsets[property] || 0)
      @sprite[0].src_rect.x = value.floor * @sprite[0].src_rect.width
    when :frame2
      @sprite[1].src_rect.x = value.floor * @sprite[1].src_rect.width if @sprite[1]
    when :blending
      @sprite[0].blend_type = value
      if @tiled_sprites
        @tiled_sprites.each { |spr| spr.blend_type = value }
      end
    when :blending2
      @sprite[1].blend_type = value if @sprite[1]
    when :mask_blending
      @sprite[0].pattern_blend_type = value
    when :mask_opacity
      @sprite[0].pattern_opacity = value
    when :mask_x
      @sprite[0].pattern_scroll_x = value
    when :mask_y
      @sprite[0].pattern_scroll_y = value
    when :mask_zoom_x
      @sprite[0].pattern_zoom_x = value / 100.0
    when :mask_zoom_y
      @sprite[0].pattern_zoom_y = value / 100.0
    end
  end

  def apply_sprite_property_override(property)
    case property
    when :angle
      # NOTE: As with everything else, an angle of 0 corresponds to right, and
      #       the angle increases anticlockwise. Most directional particles
      #       (e.g. needles) point up and will need rotating by 270 degrees to
      #       get them to point towards the focus.
      return if @initial_angle != :always_particle_to_focus
      # Get coordinates
      sprite_x = @sprite[0].x
      sprite_y = @sprite[0].y
      target_x = (@focus_xy.length == 2) ? @focus_xy[1][0] : @focus_xy[0][0]
      target_x += @offset_xy[0]
      target_y = (@focus_xy.length == 2) ? @focus_xy[1][1] : @focus_xy[0][1]
      target_y += @offset_xy[1]
      # Recalculate angle
      @sprite[0].angle = AnimationPlayer::Helper.angle_between(sprite_x, sprite_y, target_x, target_y)
      @sprite[0].angle += (@property_offsets[property] || 0)
      @sprite[0].angle += @values[:angle]
      apply_sprite_property(:angle2, @values[:angle2])
    end
  end

  # elapsed_time is in seconds since the start of the animation.
  def update(elapsed_time)
    changed_properties = []
    @processes.each do |process|
      next if process[1] > elapsed_time   # Not due to start yet
      next if process[5] == false   # Process has already fully happened
      start_process(process)
      update_process_value(process, elapsed_time)
      changed_properties.push(process[0])   # Record property as having changed
    end
    # Update constantly recalculated values, i.e. x/y for emitted sprites
    update_emitter_type_properties(elapsed_time, changed_properties)
    # Apply changed values to sprite
    update_sprite(changed_properties) if !changed_properties.empty?
  end
end

#===============================================================================
#
#===============================================================================
class AnimationPlayer::Emitter
  attr_accessor :slowdown
  attr_accessor :emitter_position_polar_coordinates, :emitter_spawn_polar_coordinates
  attr_accessor :no_user, :no_target
  attr_reader   :particle_sprites
  attr_accessor :forceInvisibilities

  # These properties are used by individual ParticleSprites spawned by this
  # emitter, and aren't used by the emitter itself so don't need updating here.
  PARTICLE_PROPERTIES = [:frame, :frame2,
                         :blending, :blending2,
                         :flip, :flip2,
                         :x, :x2, :y, :y2, :r, :theta, :z, :z2,
                         :spawn_x_offset, :spawn_x_multiplier, :spawn_y_offset, :spawn_y_multiplier,
                         :spawn_r_offset, :spawn_r_multiplier, :spawn_theta_offset,
                         :radius_x, :radius_y, :radius_z,
                         :zoom_x, :zoom_x2, :zoom_y, :zoom_y2,
                         :angle, :angle2,
                         :visible,
                         :opacity, :opacity2,
                         :color, :color2, :tone, :tone2,
                         :invert_color, :invert_color2,
                         :mask_blending,
                         :mask_opacity,
                         :mask_x, :mask_y,
                         :mask_zoom_x, :mask_zoom_y]

  def initialize(viewport, particle, fps)
    @viewport = viewport
    @particle = particle
    @fps = fps
    @processes = []
    @emitter_processes = []
    @particle_sprites = []
    initialize_values
    @next_emission = -1   # Time in seconds of the next emission
    @time_between_emissions = 1.0 / (@particle[:emitter_rate] || GameData::Animation::PARTICLE_DEFAULT_VALUES[:emitter_rate])
  end

  def initialize_values
    @values = GameData::Animation::PARTICLE_KEYFRAME_DEFAULT_VALUES.clone
  end

  def dispose
    @particle_sprites.each { |particle| particle&.dispose }
    @particle_sprites.clear
  end

  #-----------------------------------------------------------------------------

  def name
    return @particle[:name]
  end

  # If the particle's focus is :user_and_target, this will return the user's
  # index.
  def index_of_particle_focus(target_idx = -1)
    ret = -1
    if GameData::Animation::FOCUS_TYPES_WITH_USER.include?(@particle[:focus])
      ret = @user.index
    elsif GameData::Animation::FOCUS_TYPES_WITH_TARGET.include?(@particle[:focus])
      ret = target_idx
    end
    return ret
  end

  #-----------------------------------------------------------------------------

  def set_user_and_targets(user, targets)
    @user = user
    @targets = targets
  end

  def set_sprites(sprites)
    @sprites = sprites
  end

  def set_battler_filenames(battler_filenames)
    @battler_filenames = battler_filenames
  end

  def set_focus_coords(user_coords, target_coords)
    @user_coords = user_coords
    @target_coords = target_coords
  end

  def set_side_sizes(side_sizes)
    @side_sizes = side_sizes
  end

  #-----------------------------------------------------------------------------

  # start_time is in seconds.
  def add_set_process(property, start_time, value)
    add_move_process(property, start_time, 0, value, :none)
  end

  # start_time and duration are in seconds.
  def add_move_process(property, start_time, duration, value, interpolation = :linear)
    # First nil is progress (nil = not started, true = running, false = finished)
    # Second nil is start value (set when the process starts running)
    @processes.push([property, start_time, duration, value, interpolation, nil, nil])
  end

  def delete_processes(property)
    @processes.delete_if { |process| process[0] == property }
  end

  # start_time is in seconds.
  def add_emitter_set_process(property, start_time, value)
    add_emitter_move_process(property, start_time, 0, value, :none)
  end

  # start_time and duration are in seconds.
  def add_emitter_move_process(property, start_time, duration, value, interpolation = :linear)
    # First nil is progress (nil = not started, true = running, false = finished)
    # Second nil is start value (set when the process starts running)
    @emitter_processes.push([property, start_time, duration, value, interpolation, nil, nil])
  end

  # Sets the initial properties of all sprites, and marks all processes as not
  # yet started.
  def reset_processes
    dispose   # This doesn't dispose self, only the ParticleSprites
    initialize_values
    @emitter_processes.each { |process| process[5] = nil }
  end

  #-----------------------------------------------------------------------------

  def emit_new_particles(elapsed_time)
    return if @next_emission < 0
    loop do
      break if @next_emission > elapsed_time   # In the future
      if emitting_at?(@next_emission)
        if GameData::Animation::FOCUS_TYPES_WITH_TARGET.include?(@particle[:focus]) && !@target_coords.empty?
          # One sprite per target
          one_per_side = [:target_side_foreground, :target_side_background].include?(@particle[:focus])
          sides_covered = []
          @target_coords.each_with_index do |target, i|
            next if !target
            next if one_per_side && sides_covered.include?(i % 2)
            (@particle[:emitter_intensity] || 1).times do
              create_particle_sprite(i)
            end
            sides_covered.push(i % 2)
          end
        else
          # One sprite
          (@particle[:emitter_intensity] || 1).times do
            create_particle_sprite
          end
        end
      end
      @next_emission += @time_between_emissions * @slowdown
    end
    @next_emission = -1 if !@values[:emitting]
  end

  def emitting_at?(time)
    return @values[:emitting]
  end

  #-----------------------------------------------------------------------------

  # @next_emission is the time the sprite is being emitted.
  def create_particle_sprite(target_idx = -1)
    particle_sprite = AnimationPlayer::ParticleSprite.new(self.name)
    particle_sprite.slowdown = @slowdown
    particle_sprite.emitter_params[:type] = @particle[:emitter_type]
    particle_sprite.emitter_params[:start_time] = @next_emission
    @particle_sprites.push(particle_sprite)
    create_particle_sprite_assign_sprite(particle_sprite, target_idx)
    create_particle_sprite_set_coordinates(particle_sprite, target_idx)
    create_particle_sprite_set_flips(particle_sprite, target_idx)
    create_particle_sprite_set_movement_values(particle_sprite, target_idx)
    create_particle_sprite_set_base_property_offsets(particle_sprite, target_idx)
    create_particle_sprite_add_commands(particle_sprite, target_idx)
  end

  def create_particle_sprite_assign_sprite(particle_sprite, target_idx = -1)
    # Get/create a sprite
    sprite = nil
    sprite2 = nil
    is_battler_sprite = false
    case @particle[:name]
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
    if @particle[:second_layer]
      sprite2 = Sprite.new(@viewport)
      particle_sprite.set_sprite(sprite2, false)
    end
    # Set sprite's graphic and ox/oy
    if !is_battler_sprite
      AnimationPlayer::Helper.set_bitmap_and_origin(
        @particle, sprite, @user&.index, target_idx,
        @battler_filenames[@user&.index || -1], @battler_filenames[target_idx]
      )
      AnimationPlayer::Helper.set_bitmap_and_origin(
        @particle, sprite2, @user&.index, target_idx,
        @battler_filenames[@user&.index || -1], @battler_filenames[target_idx]
      )
    end
    case @particle[:graphic]
    when "USER", "USER_OPP", "USER_FRONT", "USER_BACK"
      particle_sprite.forceInvisibility = @forceInvisibilities[@user.index]
    when "TARGET", "TARGET_OPP", "TARGET_FRONT", "TARGET_BACK"
      particle_sprite.forceInvisibility = @forceInvisibilities[target_idx]
    end
    if sprite && (@particle[:mask_graphic] || "") != ""
      sprite.pattern = RPG::Cache.load_bitmap("Graphics/Battle animations/", @particle[:mask_graphic] || "")
    end
  end

  # Calculate x/y/z focus values and additional x/y modifier and pass them all
  # to particle_sprite.
  def create_particle_sprite_set_coordinates(particle_sprite, target_idx = -1)
    particle_sprite.focus_xy = AnimationPlayer::Helper.get_xy_focus(
      @particle, @user&.index, target_idx, @user_coords, @target_coords[target_idx], @side_sizes
    )
    particle_sprite.offset_xy = AnimationPlayer::Helper.get_xy_offset(@particle, (particle_sprite.sprite) ? particle_sprite.sprite[0] : nil)
    particle_sprite.focus_z = AnimationPlayer::Helper.get_z_focus(@particle, @user&.index, target_idx)
    if @emitter_position_polar_coordinates
      particle_sprite.set_base_property_offset(:emitter_x, (@values[:emitter_r] * Math.cos(@values[:emitter_theta] * Math::PI / 180)).round)
      particle_sprite.set_base_property_offset(:emitter_y, (-@values[:emitter_r] * Math.sin(@values[:emitter_theta] * Math::PI / 180)).round)
    else
      particle_sprite.set_base_property_offset(:emitter_x, @values[:emitter_x])
      particle_sprite.set_base_property_offset(:emitter_y, @values[:emitter_y])
    end
  end

  # Set whether properties should be inverted/flipped, including if the
  # particle's target is on the opposing side.
  def create_particle_sprite_set_flips(particle_sprite, target_idx = -1)
    # Random inverts/flips
    particle_sprite.random_invert_angle = true if @particle[:random_invert_angle] && rand(2) == 0
    particle_sprite.random_invert_flip = true if @particle[:random_invert_flip] && rand(2) == 0
    # Inverts/flips if the focus is on the opposing side
    relative_to_index = index_of_particle_focus(target_idx)
    if (relative_to_index >= 0 && relative_to_index.odd?) ||
       (relative_to_index < 0 && !@no_user && @user.index.odd?)
      particle_sprite.foe_invert_z = @particle[:foe_invert_z]
      if !GameData::Animation::FOCUS_TYPES_WITH_USER_AND_TARGET.include?(@particle[:focus])
        particle_sprite.foe_invert_x = @particle[:foe_invert_x]
        particle_sprite.foe_invert_y = @particle[:foe_invert_y]
        particle_sprite.foe_flip     = @particle[:foe_flip]
      end
    end
  end

  def create_particle_sprite_set_movement_values(particle_sprite, target_idx = -1)
    [
      [:emit_speed, :speed],
      [:emit_direction, :direction],
      [:emit_gravity, :gravity],
      [:emit_deceleration, :deceleration],
      [:emit_period_x, :period_x],
      [:emit_period_y, :period_y],
      [:emit_period_z, :period_z],
    ].each do |property|
      val = @values[property[0]]
      val_range = @values[(property[0].to_s + "_range").to_sym]
      val += rand(-val_range, val_range) if val_range > 0
      particle_sprite.emitter_params[property[1]] = val
    end
    # Periods
    particle_sprite.emitter_params[:period_x] /= 100.0
    particle_sprite.emitter_params[:period_y] /= 100.0
    particle_sprite.emitter_params[:period_z] /= 100.0
    # Radius/zoom random percentage modifiers (they're turned into multipliers)
    [
      [:emit_radius_x_range, :radius_x_mult],
      [:emit_radius_y_range, :radius_y_mult],
      [:emit_radius_z_range, :radius_z_mult],
      [:emit_zoom_range, :zoom_mult],
      [:emit_zoom_x_range, :zoom_x_mult],
      [:emit_zoom_y_range, :zoom_y_mult]
    ].each do |property|
      val = @values[property[0]]
      val = rand(-val, val) if val > 0
      particle_sprite.emitter_params[property[1]] = (val + 100) / 100.0
    end
    # Clockwise
    particle_sprite.emitter_params[:clockwise] = @values[:emit_clockwise]
    # Offsets
    particle_sprite.emitter_params[:z] = @values[:emit_z_offset] || 0
    particle_sprite.emitter_params[:angle] = @values[:emit_angle_offset] || 0
    # Multipliers
    particle_sprite.emitter_params[:x_multiplier] = @values[:emit_x_multiplier] / 100.0
    particle_sprite.emitter_params[:y_multiplier] = @values[:emit_y_multiplier] / 100.0
    particle_sprite.emitter_params[:zoom_multiplier] = @values[:emit_zoom_multiplier] / 100.0
    particle_sprite.emitter_params[:opacity_multiplier] = @values[:emit_opacity_multiplier] / 100.0
    # X/Y speed
    speed = particle_sprite.emitter_params[:speed]
    angle = particle_sprite.emitter_params[:direction]
    speed_x = speed * Math.cos(angle * Math::PI / 180)
    speed_y = -speed * Math.sin(angle * Math::PI / 180)
    particle_sprite.emitter_params[:speed_x] = speed_x
    particle_sprite.emitter_params[:speed_y] = speed_y
    # X/Y deceleration
    deceleration = particle_sprite.emitter_params[:deceleration]
    decel_x = deceleration * Math.cos(angle * Math::PI / 180).abs
    decel_y = deceleration * Math.sin(angle * Math::PI / 180).abs
    decel_x *= -1 if particle_sprite.emitter_params[:speed_x] > 0
    decel_y *= -1 if particle_sprite.emitter_params[:speed_y] > 0
    particle_sprite.emitter_params[:deceleration_x] = decel_x
    particle_sprite.emitter_params[:deceleration_y] = decel_y
  end

  def create_particle_sprite_set_base_property_offsets(particle_sprite, target_idx = -1)
    # Spawn X, spawn Y
    if @emitter_spawn_polar_coordinates
      start_r = @values[:spawn_r]
      start_r_range = @values[:spawn_r_range]
      start_r += rand(-start_r_range, start_r_range) if start_r_range > 0
      start_theta = @values[:spawn_theta]
      start_theta_range = @values[:spawn_theta_range]
      start_theta += rand(-start_theta_range, start_theta_range) if start_theta_range > 0
      start_x = (start_r * Math.cos(start_theta * Math::PI / 180)).round
      start_y = (-start_r * Math.sin(start_theta * Math::PI / 180)).round
      particle_sprite.set_base_property_offset(:spawn_r, start_r)
      particle_sprite.set_base_property_offset(:spawn_theta, start_theta)
    else
      start_x = @values[:spawn_x]
      start_x_range = @values[:spawn_x_range]
      start_x += rand(-start_x_range, start_x_range) if start_x_range > 0
      start_y = @values[:spawn_y]
      start_y_range = @values[:spawn_y_range]
      start_y += rand(-start_y_range, start_y_range) if start_y_range > 0
    end
    particle_sprite.set_base_property_offset(:spawn_x, start_x)
    particle_sprite.set_base_property_offset(:spawn_y, start_y)
    # Angle
    particle_sprite.initial_angle = @particle[:initial_angle] || :none
    relative_to_index = index_of_particle_focus(target_idx)
    if relative_to_index >= 0
      case @particle[:initial_angle] || :none
      when :particle_to_focus
        x_from_focus = (particle_sprite.emitter_params[:emitter_x] || 0) + start_x
        y_from_focus = (particle_sprite.emitter_params[:emitter_y] || 0) + start_y
        val = AnimationPlayer::Helper.initial_angle_between(
          [x_from_focus, y_from_focus], particle_sprite.focus_xy, particle_sprite.offset_xy
        )
        particle_sprite.set_base_property_offset(:angle, val)
      when :emitter_to_focus
        val = AnimationPlayer::Helper.initial_angle_between(
          @particle, particle_sprite.focus_xy, particle_sprite.offset_xy
        )
        particle_sprite.set_base_property_offset(:angle, val)
      end
    end
    # Angle depends on the movement direction, or if that isn't set, where the
    # particle is spawned relative to the emitter (pointing away from the
    # emitter)
    case @particle[:initial_angle] || :none
    when :emitted_direction
      if (!@particle[:emit_direction] || @particle[:emit_direction].empty?) &&
         (!@particle[:emit_direction_range] || @particle[:emit_direction_range].empty?)
        ang = (Math.atan2(-start_y, start_x.to_f) * 180 / Math::PI).round   # Direction away from emitter
      else
        ang = particle_sprite.emitter_params[:direction]   # Auto-movement direction
      end
      ang *= -1 if particle_sprite.random_invert_angle
      if @values[:emit_x_multiplier] != 100 || @values[:emit_y_multiplier] != 100
        start_x = Math.cos(ang * Math::PI / 180) * @values[:emit_x_multiplier] / 100.0
        start_y = Math.sin(ang * Math::PI / 180) * @values[:emit_y_multiplier] / 100.0
        if start_x == 0
          ang = (start_y > 0) ? 270 : 90
        else
          ang = Math.atan(start_y / start_x) * 180 / Math::PI
        end
        ang += 180 if start_x < 0
      end
      particle_sprite.set_base_property_offset(:angle, ang)
    end
    # Randomization of angle
    if @particle[:random_angle_range] && @particle[:random_angle_range] != GameData::Animation::PARTICLE_KEYFRAME_DEFAULT_VALUES[:random_angle_range]
      ang = rand(-@particle[:random_angle_range], @particle[:random_angle_range])
      particle_sprite.set_base_property_offset(:angle, (particle_sprite.property_offsets[:angle] || 0) + ang)
    end
  end

  # NOTE: @processes assume the first keyframe is 0.
  def create_particle_sprite_add_commands(particle_sprite, target_idx = -1)
    # Find earliest command and add certain command then to account for
    # randomness added above
    if !particle_sprite.is_battler_sprite?
      if AnimationPlayer::Helper.get_first_command_frame(@particle, PARTICLE_PROPERTIES) >= 0
        [:x, :y, :r, :theta, :z, :zoom_x, :zoom_y, :angle, :flip, :opacity].each do |property|
          next if [:x, :y].include?(property) && @particle[:polar_coordinates]
          next if [:r, :theta].include?(property) && !@particle[:polar_coordinates]
          particle_sprite.add_set_process(property, @next_emission, GameData::Animation::PARTICLE_KEYFRAME_DEFAULT_VALUES[property])
        end
        particle_sprite.add_set_process(:visible, @next_emission, true)
      end
      # Apply random frame
      if @particle[:random_frame_max] && @particle[:random_frame_max] > 0
        particle_sprite.add_set_process(:frame, @next_emission, rand(@particle[:random_frame_max] + 1))
      end
    end
    # Add all commands
    @processes.each do |cmd|
      if cmd[2] > 0
        particle_sprite.add_move_process(cmd[0], @next_emission + cmd[1], cmd[2], cmd[3], cmd[4] || :linear)
      elsif particle_sprite.sprite
        particle_sprite.add_set_process(cmd[0], @next_emission + cmd[1], cmd[3])
      end
    end
  end

  #-----------------------------------------------------------------------------

  def start_process(process)
    return if !process[5].nil?
    process[6] = @values[process[0]]
    process[5] = true
  end

  def update_process_value(process, elapsed_time)
    # SetXYZ
    if process[2] == 0
      @values[process[0]] = process[3]
      process[5] = false   # Mark process as finished
      # Change last emission time if appropriate
      @next_emission = process[1] if process[0] == :emitting && @values[process[0]]
      return
    end
    # MoveXYZ
    case process[0]
    when :color
      new_val = []
      4.times do |i|   # R, G, B, A
        start_val = process[6][2 * i, 2].to_i(16)
        end_val = process[3][2 * i, 2].to_i(16)
        val = AnimationPlayer::Helper.interpolate(
          process[4], start_val, end_val, process[2],
          process[1], elapsed_time
        )
        new_val.push(sprintf("%02X", val))
      end
      @values[process[0]] = new_val.join
    when :tone
      new_val = []
      4.times do |i|   # R, G, B, G
        start_val = process[6][3 * i, 3].to_i(16)
        end_val = process[3][3 * i, 3].to_i(16)
        val = AnimationPlayer::Helper.interpolate(
          process[4], start_val, end_val, process[2],
          process[1], elapsed_time
        )
        new_val.push((val >= 0 ? "+" : "-") + sprintf("%02X", val.abs))
      end
      @values[process[0]] = new_val.join
    else
      @values[process[0]] = AnimationPlayer::Helper.interpolate(
        process[4], process[6], process[3], process[2],
        process[1], elapsed_time
      )
    end
    # Mark process as finished (if it has)
    process[5] = false if elapsed_time >= process[1] + process[2]
  end

  # elapsed_time is in seconds since the start of the animation.
  def update(elapsed_time)
    # Update emitter property values
    changed_properties = []
    @emitter_processes.each do |process|
      next if process[1] > elapsed_time   # Not due to start yet
      next if process[5] == false   # Process has already fully happened
      start_process(process)
      update_process_value(process, elapsed_time)
      changed_properties.push(process[0])   # Record property as having changed
    end
    # Check whether new particles need to be emitted, and do so
    emit_new_particles(elapsed_time)
    # Update all particles/sprites
    @particle_sprites.each { |particle| particle.update(elapsed_time) }
  end
end

#===============================================================================
# Methods used by both AnimationPlayer and AnimationEditor::Canvas.
#===============================================================================
module AnimationPlayer::Helper
  BATTLE_MESSAGE_BAR_HEIGHT = 96   # NOTE: You shouldn't need to change this.

  module_function

  # Returns the duration of the animation in frames (1/20ths of a second).
  def get_duration(particles)
    ret = 0
    particles.each do |particle|
      if (particle[:emitter_type] || :none) == :none
        particle.each_pair do |property, value|
          next if !value.is_a?(Array) || value.empty?
          max = get_last_command_frame(particle)
          ret = max if ret < max
        end
      else   # Emitter
        if particle[:emitting]
          particle_start = get_first_command_frame(particle, AnimationPlayer::Emitter::PARTICLE_PROPERTIES)
          particle_end = get_last_command_frame(particle, AnimationPlayer::Emitter::PARTICLE_PROPERTIES)
          max = 0
          particle[:emitting].each do |cmd|
            max = cmd[0] + cmd[1] if max < cmd[0] + cmd[1]
          end
          ret = [ret, max + (particle_end - particle_start)].max
        end
      end
    end
    return ret
  end

  # Returns the frame that the particle has its earliest command.
  # whitelist_properties is used by emitters.
  def get_first_command_frame(particle, whitelist_properties = nil)
    ret = -1
    particle.each_pair do |property, cmds|
      next if whitelist_properties && !whitelist_properties.include?(property)
      next if !cmds.is_a?(Array) || cmds.empty?
      cmds.each do |cmd|
        ret = cmd[0] if ret < 0 || ret > cmd[0]
      end
    end
    return (ret >= 0) ? ret : 0
  end

  # Returns the frame that the particle has (the end of) its latest command.
  def get_last_command_frame(particle, whitelist_properties = nil)
    ret = -1
    particle.each_pair do |property, cmds|
      next if whitelist_properties && !whitelist_properties.include?(property)
      next if !cmds.is_a?(Array) || cmds.empty?
      cmds.each do |cmd|
        ret = cmd[0] + cmd[1] if ret < cmd[0] + cmd[1]
      end
    end
    return ret
  end

  #-----------------------------------------------------------------------------

  def get_xy_focus(particle, user_index, target_index, user_coords, target_coords, side_sizes)
    ret = nil
    case particle[:focus]
    when :foreground, :midground, :background
    when :user
      ret = [user_coords.clone]
    when :user_position
      ret = [[user_coords[0], Battle::Scene.pbBattlerPosition(user_index, side_sizes[user_index % 2])[1]]]
    when :target
      ret = [target_coords.clone]
    when :target_position
      ret = [[target_coords[0], Battle::Scene.pbBattlerPosition(target_index, side_sizes[target_index % 2])[1]]]
    when :user_and_target
      ret = [user_coords.clone, target_coords.clone]
    when :user_position_and_target
      ret = [[user_coords[0], Battle::Scene.pbBattlerPosition(user_index, side_sizes[user_index % 2])[1]],
             target_coords.clone]
    when :user_and_target_position
      ret = [user_coords.clone,
             [target_coords[0], Battle::Scene.pbBattlerPosition(target_index, side_sizes[target_index % 2])[1]]]
    when :user_position_and_target_position
      ret = [[user_coords[0], Battle::Scene.pbBattlerPosition(user_index, side_sizes[user_index % 2])[1]],
             [target_coords[0], Battle::Scene.pbBattlerPosition(target_index, side_sizes[target_index % 2])[1]]]
    when :user_side_foreground, :user_side_background
      ret = [Battle::Scene.pbBattlerPosition(user_index)]
    when :non_user_side_foreground, :non_user_side_background
      ret = [Battle::Scene.pbBattlerPosition(user_index + 1)]
    when :target_side_foreground, :target_side_background
      ret = [Battle::Scene.pbBattlerPosition(target_index)]
    when :user_and_other_side
      ret = [user_coords.clone, Battle::Scene.pbBattlerPosition(user_index + 1)]
    end
    return ret
  end

  def get_xy_offset(particle, sprite)
    ret = [0, 0]
    case particle[:graphic]
    when "USER", "USER_OPP", "USER_FRONT", "USER_BACK",
         "TARGET", "TARGET_OPP", "TARGET_FRONT", "TARGET_BACK"
      ret[1] += sprite.bitmap.height / 2 if sprite&.bitmap
    end
    return ret
  end

  # property is :x or :y.
  def apply_xy_value_using_focus_to_sprite(sprite, property, value, focus)
    result = value
    coord_idx = (property == :x) ? 0 : 1
    if focus
      if focus.length == 2
        distance = GameData::Animation::USER_AND_TARGET_SEPARATION
        result = focus[0][coord_idx] + ((value.to_f / distance[coord_idx]) * (focus[1][coord_idx] - focus[0][coord_idx])).to_i
      else
        result = value + focus[0][coord_idx]
      end
    end
    case property
    when :x then sprite.x = result
    when :y then sprite.y = result
    end
  end

  #-----------------------------------------------------------------------------

  # Returns either a number or an array of two numbers.
  def get_z_focus(particle, user_index, target_index)
    ret = 0
    case particle[:focus]
    when :foreground
      ret = 2000
    when :midground
      ret = 1000
    when :background
      # NOTE: No change.
    when :user, :user_position
      ret = 1000 + ((100 * ((user_index / 2) + 1)) * (user_index.even? ? 1 : -1))
    when :target, :target_position
      ret = 1000 + ((100 * ((target_index / 2) + 1)) * (target_index.even? ? 1 : -1))
    when :user_and_target, :user_position_and_target, :user_and_target_position,
         :user_position_and_target_position
      user_pos = 1000 + ((100 * ((user_index / 2) + 1)) * (user_index.even? ? 1 : -1))
      target_pos = 1000 + ((100 * ((target_index / 2) + 1)) * (target_index.even? ? 1 : -1))
      ret = [user_pos, target_pos]
    when :user_side_foreground, :target_side_foreground
      this_idx = (particle[:focus] == :user_side_foreground) ? user_index : target_index
      ret = 1000
      ret += 1000 if this_idx.even?   # On player's side
    when :user_side_background, :target_side_background
      this_idx = (particle[:focus] == :user_side_background) ? user_index : target_index
      ret = 1000 if this_idx.even?   # On player's side
    when :non_user_side_foreground
      ret = 1000
      ret += 1000 if user_index.odd?   # User is on foe's side
    when :non_user_side_background
      ret = 1000 if user_index.odd?   # User is on foe's side
    when :user_and_other_side   # Other side's foreground
      user_pos = 1000 + ((100 * ((user_index / 2) + 1)) * (user_index.even? ? 1 : -1))
      side_pos = 1000 + (user_index.odd? ? 1000 : 0)
      ret = [user_pos, side_pos]
    end
    return ret
  end

  def apply_z_focus_to_sprite(sprite, z, focus)
    if focus.is_a?(Array)
      distance = GameData::Animation::USER_AND_TARGET_SEPARATION[2]
      if z >= 0
        if focus[0] > focus[1]
          sprite.z = focus[0] + z
        else
          sprite.z = focus[0] - z
        end
      elsif z <= distance
        if focus[0] > focus[1]
          sprite.z = focus[1] + z + distance
        else
          sprite.z = focus[1] - z + distance
        end
      else
        sprite.z = focus[0] + ((z.to_f / distance) * (focus[1] - focus[0])).to_i
      end
    elsif focus
      sprite.z = z + focus
    else
      sprite.z = z
    end
  end

  #-----------------------------------------------------------------------------

  # Returns the direction (an angle) that "to" is from "from". The angle that
  # "from" has to face to be looking at "to".
  def angle_between(from_x, from_y, to_x, to_y)
    diff_x = to_x - from_x
    diff_y = to_y - from_y
    ret = -Math.atan2(diff_y.to_f, diff_x) * 180 / Math::PI
    ret += 360 if ret < 0
    return ret
  end

  # Returns the direction (an angle) that the particle is in from the focus.
  def initial_angle_between(particle, focus, offset)
    particle_x = 0
    particle_y = 0
    focus_x = 0
    focus_y = 0
    if focus
      focus_x = (focus.length == 2) ? focus[1][0] : focus[0][0]
      focus_y = (focus.length == 2) ? focus[1][1] : focus[0][1]
    end
    if particle.is_a?(Array)
      particle_x, particle_y = particle
    else
      coords = [:x, :y]
      coords = [:emitter_x, :emitter_y] if (particle[:emitter_type] || :none) != :none
      coords.each do |property|
        next if !particle[property]
        particle[property].each do |cmd|
          break if cmd[1] > 0
          if property == :x
            particle_x = cmd[2]
          else
            particle_y = cmd[2]
          end
          break
        end
      end
    end
    if focus
      if focus.length == 2
        distance = GameData::Animation::USER_AND_TARGET_SEPARATION
        particle_x = focus[0][0] + ((particle_x.to_f / distance[0]) * (focus[1][0] - focus[0][0])).to_i
        particle_y = focus[0][1] + ((particle_y.to_f / distance[1]) * (focus[1][1] - focus[0][1])).to_i
      else
        particle_x += focus[0][0]
        particle_y += focus[0][1]
      end
    end
    particle_x += offset[0]
    particle_y += offset[1]
    return angle_between(particle_x, particle_y, focus_x, focus_y)
  end

  #-----------------------------------------------------------------------------

  # user_sprites, target_sprites = [front sprite, back sprite]
  def set_bitmap_and_origin(particle, sprite, user_index, target_index, user_sprites, target_sprites)
    return if !sprite || sprite.is_a?(Battle::Scene::BattlerSprite)
    case particle[:graphic]
    when "USER", "USER_OPP", "USER_FRONT", "USER_BACK",
         "TARGET", "TARGET_OPP", "TARGET_FRONT", "TARGET_BACK"
      filename = nil
      case particle[:graphic]
      when "USER"
        filename = (user_index.even?) ? user_sprites[1] : user_sprites[0]
      when "USER_OPP"
        filename = (user_index.even?) ? user_sprites[0] : user_sprites[1]
      when "USER_FRONT"
        filename = user_sprites[0]
      when "USER_BACK"
        filename = user_sprites[1]
      when "TARGET"
        filename = (target_index.even?) ? target_sprites[1] : target_sprites[0]
      when "TARGET_OPP"
        filename = (target_index.even?) ? target_sprites[0] : target_sprites[1]
      when "TARGET_FRONT"
        filename = target_sprites[0]
      when "TARGET_BACK"
        filename = target_sprites[1]
      end
      sprite.bitmap = RPG::Cache.load_bitmap("", filename)
      sprite.ox = sprite.bitmap.width / 2
      sprite.oy = sprite.bitmap.height
    else
      sprite.bitmap = RPG::Cache.load_bitmap("Graphics/Battle animations/", particle[:graphic] || "")
      sprite.src_rect.set(0, 0, sprite.bitmap.width, sprite.bitmap.height)
      if [:foreground, :midground, :background].include?(particle[:focus]) &&
         sprite.bitmap.width >= Settings::SCREEN_WIDTH &&
         sprite.bitmap.height >= Settings::SCREEN_HEIGHT - BATTLE_MESSAGE_BAR_HEIGHT
        sprite.ox = 0
        sprite.oy = 0
      elsif sprite.bitmap.width > sprite.bitmap.height * 2
        sprite.src_rect.set(0, 0, sprite.bitmap.height, sprite.bitmap.height)
        sprite.ox = sprite.bitmap.height / 2
        sprite.oy = sprite.bitmap.height / 2
      else
        sprite.ox = sprite.bitmap.width / 2
        sprite.oy = sprite.bitmap.height / 2
      end
      if (particle[:graphic] || "")[/\[\s*bottom\s*\]\s*$/i]   # [bottom] at end of filename
        sprite.oy = sprite.bitmap.height
      end
    end
  end

  def adjust_origin_by_battler_metrics(particle, sprite, index, filename)
    return if sprite.nil?
    # Origin is already [sprite.bitmap.width / 2, sprite.bitmap.height], so just
    # need to apply metrics
    back_sprite = false
    back_sprite = true if ["USER_BACK", "TARGET_BACK"].include?(particle[:graphic])
    back_sprite = true if index.odd? && ["USER_OPP", "TARGET_OPP"].include?(particle[:graphic])
    back_sprite = true if index.even? && ["USER", "TARGET"].include?(particle[:graphic])
    species = filename.gsub("_female", "").gsub("_shadow", "")
    form = 0
    if species[/^(\w+)_(\d+)$/]
      species = $~[1]
      form = $~[2].to_i
    end
    metrics = GameData::SpeciesMetrics.get_species_form(species, form)
    return if metrics.nil?
    metrics.apply_metrics_to_sprite(sprite, (back_sprite) ? 0 : 1, false, true)
  end

  #-----------------------------------------------------------------------------

  def interpolate(interpolation, start_val, end_val, duration, start_time, now)
    return start_val if now <= start_time
    return end_val if now >= start_time + duration
    case interpolation
    when :linear
      return lerp(start_val, end_val, duration, start_time, now).to_i
    when :ease_in   # Quadratic
      ret = start_val
      x = (now - start_time) / duration.to_f
      ret += (end_val - start_val) * x * x
      return ret.round
    when :ease_out   # Quadratic
      ret = start_val
      x = (now - start_time) / duration.to_f
      ret += (end_val - start_val) * (1 - ((1 - x) * (1 - x)))
      return ret.round
    when :ease_both   # Quadratic
      ret = start_val
      x = (now - start_time) / duration.to_f
      if x < 0.5
        ret += (end_val - start_val) * x * x * 2
      else
        ret += (end_val - start_val) * (1 - (((-2 * x) + 2) * ((-2 * x) + 2) / 2))
      end
      return ret.round
    when :gravity   # Used by particle emitter
      # end_val is [initial speed, gravity]
      # s = ut + 1/2 at^2
      t = now - start_time
      ret = start_val + (end_val[0] * t) + (end_val[1] * t * t / 2)
      return ret.round
    end
    raise _INTL("Unknown interpolation method {1}.", interpolation)
  end
end
