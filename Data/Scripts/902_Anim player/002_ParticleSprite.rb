#===============================================================================
# NOTE: This assumes that processes are added (for a given property) in the
#       order they happen.
#===============================================================================
class AnimationPlayer::ParticleSprite
  attr_reader   :sprite
  attr_accessor :focus_xy, :offset_xy, :focus_z
  attr_reader   :property_offsets
  attr_accessor :angle_override, :random_invert_angle, :random_invert_flip
  attr_accessor :foe_invert_x, :foe_invert_y, :foe_flip
  attr_accessor :slowdown
  # Used by particles from emitter
  attr_reader   :emitter_params

  def initialize
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
      @tiled_sprites.push(Sprite.new(sprite.viewport))
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

  # :angle => value is particle[:angle_override] from GameData::Animation::ANGLE_OVERRIDES.
  def set_base_property_offset(property, value)
    case property
    when :angle
      @angle_override = value || :none   # Only used for :always_point_at_focus
    else
      @property_offsets[property] = value
    end
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

  # Sets sprite's initial For looping purposes.
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

  # Usually only :x and :y.
  def update_emitter_type_properties(elapsed_time, changed_properties)
    return if (@emitter_params[:type] || :none) == :none
    delta_t = (elapsed_time - @emitter_params[:start_time]) / @slowdown.to_f
    case (@emitter_params[:type] || :none)
    when :no_movement
      # NOTE: This doesn't change any properties.
    when :straight
      if @emitter_params[:speed_x] != 0
        new_x = (@emitter_params[:speed_x] * delta_t).round
        @values[:base_x] = new_x
        changed_properties.push(:x)
      end
      if @emitter_params[:speed_y] != 0
        new_y = (@emitter_params[:speed_y] * delta_t).round
        @values[:base_y] = new_y
        changed_properties.push(:y)
      end
    when :projectile
      if @emitter_params[:speed_x] != 0
        new_x = (@emitter_params[:speed_x] * delta_t).round
        @values[:base_x] = new_x
        changed_properties.push(:x)
      end
      if @emitter_params[:speed_y] != 0 || @emitter_params[:gravity] != 0
        new_y = ((@emitter_params[:speed_y] * delta_t) + (@emitter_params[:gravity] * delta_t * delta_t / 2)).round   # s = ut + 1/2 at^2
        @values[:base_y] = new_y
        changed_properties.push(:y)
      end
    when :helix
      if @emitter_params[:period_x] != 0
        new_angle = @emitter_params[:angle]
        new_angle += (360 * delta_t / @emitter_params[:period_x]) * (@emitter_params[:clockwise] ? -1 : 1)
        new_x = @values[:radius_x] * @emitter_params[:radius_x_mult] * Math.sin(new_angle * Math::PI / 180)
        @values[:base_x] = new_x
        changed_properties.push(:x)
      end
      if @emitter_params[:speed] != 0
        new_y = (@emitter_params[:speed] * delta_t).round
        @values[:base_y] = new_y
        changed_properties.push(:y)
      end
      if @emitter_params[:period_z] != 0
        new_angle = @emitter_params[:angle]
        new_angle += (360 * delta_t / @emitter_params[:period_z]) * (@emitter_params[:clockwise] ? -1 : 1)
        new_z = @values[:radius_z] * @emitter_params[:radius_z_mult] * Math.cos(new_angle * Math::PI / 180)
        @values[:z] = new_z
        changed_properties.push(:z)
      end
    when :polar
      if @emitter_params[:period_x] != 0
        new_angle = @emitter_params[:angle]
        new_angle += (360 * delta_t / @emitter_params[:period_x]) * (@emitter_params[:clockwise] ? -1 : 1)
        new_x = @values[:radius_x] * @emitter_params[:radius_x_mult] * Math.cos(new_angle * Math::PI / 180)
        @values[:base_x] = new_x
        changed_properties.push(:x)
      end
      if @emitter_params[:period_y] != 0
        new_angle = @emitter_params[:angle] + (360 * delta_t / @emitter_params[:period_y])
        new_y = -@values[:radius_y] * @emitter_params[:radius_y_mult] * Math.sin(new_angle * Math::PI / 180)
        @values[:base_y] = new_y
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
    when :x
      value = value.round + (@property_offsets[property] || 0)
      value += @values[:base_x] || 0   # Used by emitters
      value *= -1 if @foe_invert_x
      AnimationPlayer::Helper.apply_xy_focus_to_sprite(@sprite[0], :x, value, @focus_xy)
      @sprite[0].x += @offset_xy[0]
      apply_sprite_property(:x2, @values[:x2])
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
    when :y
      value = value.round + (@property_offsets[property] || 0)
      value += @values[:base_y] || 0   # Used by emitters
      value *= -1 if @foe_invert_y
      AnimationPlayer::Helper.apply_xy_focus_to_sprite(@sprite[0], :y, value, @focus_xy)
      @sprite[0].y += @offset_xy[1]
      apply_sprite_property(:y2, @values[:y2])
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
    when :z
      value += (@property_offsets[property] || 0)
      AnimationPlayer::Helper.apply_z_focus_to_sprite(@sprite[0], value, @focus_z)
      apply_sprite_property(:z2, @values[:z2])
      if @tiled_sprites
        @tiled_sprites.each { |spr| spr.z = @sprite[0].z }
      end
    when :z2
      @sprite[1].z = @sprite[0].z + value if @sprite[1]
    when :zoom_x
      value += (@property_offsets[property] || 0)
      value *= @emitter_params[:zoom_mult] || 1
      value *= @emitter_params[:zoom_x_mult] || 1
      @sprite[0].zoom_x = value / 100.0
      apply_sprite_property(:zoom_x2, @values[:zoom_x2])
    when :zoom_x2
      @sprite[1].zoom_x = @sprite[0].zoom_x * value / 100.0 if @sprite[1]
    when :zoom_y
      value += (@property_offsets[property] || 0)
      value *= @emitter_params[:zoom_mult] || 1
      value *= @emitter_params[:zoom_y_mult] || 1
      @sprite[0].zoom_y = value / 100.0
      apply_sprite_property(:zoom_y2, @values[:zoom_y2])
    when :zoom_y2
      @sprite[1].zoom_y = @sprite[0].zoom_y * value / 100.0 if @sprite[1]
    when :angle
      if @angle_override == :always_point_at_focus
        apply_sprite_property_override(:angle)
      else
        @sprite[0].angle = value + (@property_offsets[property] || 0)
      end
      @sprite[0].angle *= -1 if @random_invert_angle
      apply_sprite_property(:angle2, @values[:angle2])
    when :angle2
     if @sprite[1]
        new_val = value
        new_val *= -1 if @random_invert_angle
        @sprite[1].angle = @sprite[0].angle + new_val
      end
    when :visible
      @sprite.each { |spr| spr.visible = value }
      if @tiled_sprites
        @tiled_sprites.each { |spr| spr.visible = value }
      end
    when :opacity
      @sprite[0].opacity = value + (@property_offsets[property] || 0)
      apply_sprite_property(:opacity2, @values[:opacity2]) if @sprite[1]
      if @tiled_sprites
        @tiled_sprites.each { |spr| spr.opacity = @sprite[0].opacity }
      end
    when :opacity2
      @sprite[1].opacity = @sprite[0].opacity + value if @sprite[1]
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
      # NOTE: This assumes vertically up is an angle of 0, and the angle
      #       increases anticlockwise.
      return if @angle_override != :always_point_at_focus
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
