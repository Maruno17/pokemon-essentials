#===============================================================================
# Methods used by both AnimationPlayer and AnimationEditor::Canvas.
#===============================================================================
module AnimationPlayer::Helper
  PROPERTIES_SET_BY_SPAWNER = {
    :random_direction            => [:x, :y],
    :random_direction_gravity    => [:x, :y],
    :random_up_direction_gravity => [:x, :y]
  }
  GRAVITY_STRENGTH = 500
  BATTLE_MESSAGE_BAR_HEIGHT = 96   # NOTE: You shouldn't need to change this.

  module_function

  # Returns the duration of the animation in frames (1/20ths of a second).
  def get_duration(particles)
    ret = 0
    particles.each do |particle|
      particle.each_pair do |property, value|
        next if !value.is_a?(Array) || value.empty?
        max = value.last[0] + value.last[1]   # Keyframe + duration
        # Particle spawners can delay their particles; account for this
        if (particle[:spawner] || :none) != :none
          max += get_particle_delay(particle, (particle[:spawn_quantity] || 1) - 1)
        end
        ret = max if ret < max
      end
    end
    return ret
  end

  # Returns the frame that the particle has its earliest command.
  def get_first_command_frame(particle)
    ret = -1
    particle.each_pair do |property, cmds|
      next if !cmds.is_a?(Array) || cmds.empty?
      cmds.each do |cmd|
        ret = cmd[0] if ret < 0 || ret > cmd[0]
      end
    end
    return (ret >= 0) ? ret : 0
  end

  # Returns the frame that the particle has (the end of) its latest command.
  def get_last_command_frame(particle)
    ret = -1
    particle.each_pair do |property, cmds|
      next if !cmds.is_a?(Array) || cmds.empty?
      cmds.each do |cmd|
        ret = cmd[0] + cmd[1] if ret < cmd[0] + cmd[1]
      end
    end
    return ret
  end

  # For spawner particles
  def get_particle_delay(particle, instance)
    case particle[:spawner] || :none
    when :random_direction, :random_direction_gravity, :random_up_direction_gravity
      return instance / 4
    end
    return 0
  end

  #-----------------------------------------------------------------------------

  def get_xy_focus(particle, user_index, target_index, user_coords, target_coords)
    ret = nil
    case particle[:focus]
    when :foreground, :midground, :background
    when :user
      ret = [user_coords.clone]
    when :target
      ret = [target_coords.clone]
    when :user_and_target
      ret = [user_coords.clone, target_coords.clone]
    when :user_side_foreground, :user_side_background
      ret = [Battle::Scene.pbBattlerPosition(user_index)]
    when :target_side_foreground, :target_side_background
      ret = [Battle::Scene.pbBattlerPosition(target_index)]
    end
    return ret
  end

  def get_xy_offset(particle, sprite)
    ret = [0, 0]
    case particle[:graphic]
    when "USER", "USER_OPP", "USER_FRONT", "USER_BACK",
        "TARGET", "TARGET_OPP", "TARGET_FRONT", "TARGET_BACK"
      ret[1] += sprite.bitmap.height / 2 if sprite
    end
    return ret
  end

  # property is :x or :y.
  def apply_xy_focus_to_sprite(sprite, property, value, focus)
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
    when :user
      ret = 1000 + ((100 * ((user_index / 2) + 1)) * (user_index.even? ? 1 : -1))
    when :target
      ret = 1000 + ((100 * ((target_index / 2) + 1)) * (target_index.even? ? 1 : -1))
    when :user_and_target
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

  def angle_between(x1, y1, x2, y2)
    diff_x = x1 - x2
    diff_y = y1 - y2
    ret = Math.atan(diff_x.to_f / diff_y) * 180 / Math::PI
    ret += 180 if diff_y < 0
    return ret
  end

  def initial_angle_between(particle, focus, offset)
    x1 = 0
    y1 = 0
    x2 = (focus.length == 2) ? focus[1][0] : focus[0][0]
    y2 = (focus.length == 2) ? focus[1][1] : focus[0][1]
    [:x, :y].each do |property|
      next if !particle[property]
      particle[property].each do |cmd|
        break if cmd[1] > 0
        if property == :x
          x1 = cmd[2]
        else
          y1 = cmd[2]
        end
        break
      end
    end
    if focus
      if focus.length == 2
        distance = GameData::Animation::USER_AND_TARGET_SEPARATION
        x1 = focus[0][0] + ((x1.to_f / distance[0]) * (focus[1][0] - focus[0][0])).to_i
        y1 = focus[0][1] + ((y1.to_f / distance[1]) * (focus[1][1] - focus[0][1])).to_i
      else
        x1 += focus[0][0]
        y1 += focus[0][1]
      end
    end
    x1 += offset[0]
    y1 += offset[1]
    return angle_between(x1, y1, x2, y2)
  end

  #-----------------------------------------------------------------------------

  # user_sprites, target_sprites = [front sprite, back sprite]
  def set_bitmap_and_origin(particle, sprite, user_index, target_index, user_sprites, target_sprites)
    return if sprite&.is_a?(Battle::Scene::BattlerSprite)
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
      sprite.bitmap = RPG::Cache.load_bitmap("Graphics/Battle animations/", particle[:graphic])
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
      if particle[:graphic][/\[\s*bottom\s*\]\s*$/i]   # [bottom] at end of filename
        sprite.oy = sprite.bitmap.height
      end
    end
  end

  #-----------------------------------------------------------------------------

  def interpolate(interpolation, start_val, end_val, duration, start_time, now)
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
    when :gravity   # Used by particle spawner
      # end_val is [initial speed, gravity]
      # s = ut + 1/2 at^2
      t = now - start_time
      ret = start_val + (end_val[0] * t) + (end_val[1] * t * t / 2)
      return ret.round
    end
    raise _INTL("Unknown interpolation method {1}.", interpolation)
  end
end
