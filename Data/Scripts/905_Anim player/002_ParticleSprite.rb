#===============================================================================
# NOTE: This assumes that processes are added (for a given property) in the
#       order they happen.
#===============================================================================
class AnimationPlayer::ParticleSprite
  attr_accessor :sprite
  attr_accessor :focus_xy, :offset_xy, :focus_z
  attr_accessor :base_angle, :angle_override
  attr_accessor :foe_invert_x, :foe_invert_y, :foe_flip

  FRAMES_PER_SECOND = 20.0

  def initialize
    @processes = []
    @sprite = nil
    @battler_sprite = false
    initialize_values
  end

  def initialize_values
    @values = GameData::Animation::PARTICLE_KEYFRAME_DEFAULT_VALUES.clone
  end

  def dispose
    return if battler_sprite? || !@sprite || @sprite.disposed?
    @sprite.bitmap&.dispose
    @sprite.dispose
  end

  #-----------------------------------------------------------------------------

  def set_as_battler_sprite
    @battler_sprite = true
    @values[:visible] = true
  end

  def battler_sprite?
    return @battler_sprite
  end

  #-----------------------------------------------------------------------------

  def add_set_process(property, frame, value)
    add_move_process(property, frame, 0, value, :none)
  end

  def add_move_process(property, start_frame, duration, value, interpolation = :linear)
    # First nil is progress (nil = not started, true = running, false = finished)
    # Second nil is start value (set when the process starts running)
    @processes.push([property, start_frame, duration, value, interpolation, nil, nil])
  end

  def delete_processes(property)
    @processes.delete_if { |process| process[0] == property }
  end

  # Sets sprite's initial For looping purposes.
  def reset_processes
    initialize_values
    set_as_battler_sprite if battler_sprite?   # Start battler sprites as visible
    @values.each_pair { |property, value| update_sprite_property(property, value) }
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
    @values[process[0]] = AnimationPlayer::Helper.interpolate(
      process[4], process[6], process[3], process[2] / FRAMES_PER_SECOND,
      process[1] / FRAMES_PER_SECOND, elapsed_time
    )
    if elapsed_time >= (process[1] + process[2]) / FRAMES_PER_SECOND
      process[5] = false   # Mark process as finished
    end
  end

  def update_sprite(changed_properties)
    changed_properties.uniq!
    changed_properties.each do |property|
      update_sprite_property(property, @values[property])
    end
  end

  def update_sprite_property(property, value)
    if !@sprite
      pbSEPlay(*value) if [:se, :user_cry, :target_cry].include?(property) && value
      return
    end
    case property
    when :frame       then @sprite.src_rect.x = value.floor * @sprite.src_rect.width
    when :blending    then @sprite.blend_type = value
    when :flip
      @sprite.mirror = value
      @sprite.mirror = !@sprite.mirror if @foe_flip
    when :x
      value = value.round
      value *= -1 if @foe_invert_x
      AnimationPlayer::Helper.apply_xy_focus_to_sprite(@sprite, :x, value, @focus_xy)
      @sprite.x += @offset_xy[0]
      update_angle_pointing_at_focus
    when :y
      value = value.round
      value *= -1 if @foe_invert_y
      AnimationPlayer::Helper.apply_xy_focus_to_sprite(@sprite, :y, value, @focus_xy)
      @sprite.y += @offset_xy[1]
      update_angle_pointing_at_focus
    when :z
      AnimationPlayer::Helper.apply_z_focus_to_sprite(@sprite, value, @focus_z)
    when :zoom_x      then @sprite.zoom_x = value / 100.0
    when :zoom_y      then @sprite.zoom_y = value / 100.0
    when :angle
      if @angle_override == :always_point_at_focus
        update_angle_pointing_at_focus
        @sprite.angle += value
      else
        @sprite.angle = value + (@base_angle || 0)
      end
    when :visible     then @sprite.visible = value
    when :opacity     then @sprite.opacity = value
    when :color_red   then @sprite.color.red = value
    when :color_green then @sprite.color.green = value
    when :color_blue  then @sprite.color.blue = value
    when :color_alpha then @sprite.color.alpha = value
    when :tone_red    then @sprite.tone.red = value
    when :tone_green  then @sprite.tone.green = value
    when :tone_blue   then @sprite.tone.blue = value
    when :tone_gray   then @sprite.tone.gray = value
    end
  end

  # This assumes vertically up is an angle of 0, and the angle increases
  # anticlockwise.
  def update_angle_pointing_at_focus
    return if @angle_override != :always_point_at_focus
    # Get coordinates
    sprite_x = @sprite.x
    sprite_y = @sprite.y
    target_x = (@focus_xy.length == 2) ? @focus_xy[1][0] : @focus_xy[0][0]
    target_x += @offset_xy[0]
    target_y = (@focus_xy.length == 2) ? @focus_xy[1][1] : @focus_xy[0][1]
    target_y += @offset_xy[1]
    @sprite.angle = AnimationPlayer::Helper.angle_between(sprite_x, sprite_y, target_x, target_y)
    @sprite.angle += (@base_angle || 0)
  end

  def update(elapsed_time)
    frame = (elapsed_time * FRAMES_PER_SECOND).floor
    changed_properties = []
    @processes.each do |process|
      # Skip processes that aren't due to start yet
      next if process[1] > frame
      # Skip processes that have already fully happened
      next if process[5] == false
      # Mark process as running if it isn't already
      start_process(process)
      # Update process's value
      update_process_value(process, elapsed_time)
      changed_properties.push(process[0])   # Record property as having changed
    end
    # Apply changed values to sprite
    update_sprite(changed_properties) if !changed_properties.empty?
  end
end
