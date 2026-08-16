#===============================================================================
#
#===============================================================================
class AnimationPlayer::Emitter
  attr_accessor :slowdown
  attr_accessor :emitter_position_polar_coordinates, :emitter_spawn_polar_coordinates
  attr_reader   :particle_sprites

  # These properties are used by individual ParticleSprites spawned by this
  # emitter, and aren't used by the emitter itself so don't need updating here.
  PARTICLE_PROPERTIES = [:frame, :frame2,
                         :blending, :blending2,
                         :flip, :flip2,
                         :x, :x2, :y, :y2, :r, :theta, :z, :z2,
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
    # TODO: Ideally this would simulate the :emitting processes and determine
    #       the return value exactly. Can simulate it during initialisation to
    #       create a set of time ranges, then this method can just return
    #       whether time is within any of those ranges.
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
    if relative_to_index && relative_to_index >= 0 && relative_to_index.odd?
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
        x_from_focus = particle_sprite.emitter_params[:emitter_x] + start_x
        y_from_focus = particle_sprite.emitter_params[:emitter_y] + start_y
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
      ang = particle_sprite.emitter_params[:direction]   # Auto-movement direction
      if ang.nil?   # Direction away from emitter
        if start_x == 0
          ang = (start_y > 0) ? 270 : 90
        else
          ang = Math.atan(start_y / start_x) * 180 / Math::PI
        end
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
        [:x, :y, :r, :theta, :priority, :zoom_x, :zoom_y, :angle, :flip, :opacity].each do |property|
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
