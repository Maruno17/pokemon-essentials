#===============================================================================
# NOTE: z values:
#       -200 = backdrop.
#       -199 = side bases
#       -198 = battler shadows.
#       0 +/-50 = background focus, foe side background.
#       900, 800, 700... +/-50 = foe battlers.
#       1000 +/-50 = foe side foreground, player side background.
#       1100, 1200, 1300... +/-50 = player battlers.
#       2000 +/-50 = player side foreground, foreground focus.
#       9999+ = UI

# TODO: Should the canvas be able to show boxes/faded sprites of particles from
#       the previous keyframe? I suppose ideally, but don't worry about it.
# TODO: Battler/particle sprites should be their own class, which combine a
#       sprite and a target-dependent coloured frame. Alternatively, have the
#       frame be a separate sprite but only draw it around the currently
#       selected particle(s).
# TODO: Ideally refresh the canvas while editing a particle's property in the
#       :commands_pane component (e.g. moving a number slider but not finalising
#       it). Refresh a single particle. I don't think any other side pane needs
#       to refresh the canvas in the middle of changing a value. The new value
#       of a control in the middle of being changed isn't part of the particle's
#       data, so it'll need to be input manually somehow.
#===============================================================================
class AnimationEditor::Canvas < Sprite
  def initialize(viewport, anim, settings)
    super(viewport)
    @anim          = anim
    @settings      = settings
    @keyframe      = 0
    @user_coords   = []
    @target_coords = []
    @playing       = false   # TODO: What should this affect? Is it needed?
    initialize_background
    initialize_battlers
    initialize_particle_sprites
    refresh
  end

  def initialize_background
    self.z = -200
    # NOTE: The background graphic is self.bitmap.
    # TODO: Add second (flipped) background graphic, for screen shake commands.
    player_base_pos = Battle::Scene.pbBattlerPosition(0)
    @player_base = IconSprite.new(*player_base_pos, viewport)
    @player_base.z = -199
    foe_base_pos = Battle::Scene.pbBattlerPosition(1)
    @foe_base = IconSprite.new(*foe_base_pos, viewport)
    @foe_base.z = -199
    @message_bar_sprite = Sprite.new(viewport)
    @message_bar_sprite.z = 9999
  end

  def initialize_battlers
    @battler_sprites = []
  end

  def initialize_particle_sprites
    @particle_sprites = []
  end

  def dispose
    @user_bitmap_front&.dispose
    @user_bitmap_back&.dispose
    @target_bitmap_front&.dispose
    @target_bitmap_back&.dispose
    @player_base.dispose
    @foe_base.dispose
    @message_bar_sprite.dispose
    @battler_sprites.each { |s| s.dispose if s && !s.disposed? }
    @battler_sprites.clear
    @particle_sprites.each do |s|
      if s.is_a?(Array)
        s.each { |s2| s2.dispose if s2 && !s2.disposed? }
      else
        s.dispose if s && !s.disposed?
      end
    end
    @particle_sprites.clear
    super
  end

  #-----------------------------------------------------------------------------

  # Returns whether the user is on the foe's (non-player's) side.
  def sides_swapped?
    return @settings[:user_opposes] || [:opp_move, :opp_common].include?(@anim[:type])
  end

  # index is a battler index (even for player's side, odd for foe's side)
  def side_size(index)
    side = index % 2
    side = (side + 1) % 2 if sides_swapped?
    return @settings[:side_sizes][side]
  end

  def user_index
    ret = @settings[:user_index]
    ret += 1 if sides_swapped?
    return ret
  end

  def target_indices
    ret = @settings[:target_indices].clone
    if sides_swapped?
      ret.length.times do |i|
        ret[i] += (ret[i].even?) ? 1 : -1
      end
    end
    return ret
  end

  def position_empty?(index)
    return user_index != index && !target_indices.include?(index)
  end

  def keyframe=(val)
    return if @keyframe == val || val < 0
    @keyframe = val
    refresh
  end

  #-----------------------------------------------------------------------------

  def busy?
    return false
  end

  def changed?
    return false
  end

  #-----------------------------------------------------------------------------

  def prepare_to_play_animation
    # TODO: Hide particle sprites, set battler sprites to starting positions so
    #       that the animation can play properly. Also need a way to end this
    #       override after the animation finishes playing. This method does not
    #       literally play the animation; the main editor screen or playback
    #       control does that.
    @playing = true
  end

  def end_playing_animation
    @playing = false
    refresh
  end

  #-----------------------------------------------------------------------------

  def refresh_bg_graphics
    return if @bg_name && @bg_name == @settings[:canvas_bg]
    @bg_name = @settings[:canvas_bg]
    # TODO: Make the choice of background graphics match the in-battle one in
    #       def pbCreateBackdropSprites. Ideally make that method a class method
    #       so the canvas can use it rather than duplicate it.
    self.bitmap = RPG::Cache.load_bitmap("Graphics/Battlebacks/", @bg_name + "_bg")
    @player_base.setBitmap("Graphics/Battlebacks/" + @bg_name + "_base0")
    @player_base.ox = @player_base.bitmap.width / 2
    @player_base.oy = @player_base.bitmap.height
    @foe_base.setBitmap("Graphics/Battlebacks/" + @bg_name + "_base1")
    @foe_base.ox = @foe_base.bitmap.width / 2
    @foe_base.oy = @foe_base.bitmap.height / 2
    @message_bar_sprite.bitmap = RPG::Cache.load_bitmap("Graphics/Battlebacks/", @bg_name + "_message")
    @message_bar_sprite.y = Settings::SCREEN_HEIGHT - @message_bar_sprite.height
  end

  # TODO: def refresh_box_display which checks @settings for whether boxes
  #       should be drawn around sprites.

  # TODO: Create shadow sprites?
  def ensure_battler_sprites
    if !@side_size0 || @side_size0 != side_size(0)
      @battler_sprites.each_with_index { |s, i| s.dispose if i.even? && s && !s.disposed? }
      @side_size0 = side_size(0)
      @side_size0.times do |i|
        next if position_empty?(i * 2)
        @battler_sprites[i * 2] = Sprite.new(self.viewport)
      end
    end
    if !@side_size1 || @side_size1 != side_size(1)
      @battler_sprites.each_with_index { |s, i| s.dispose if i.odd? && s && !s.disposed? }
      @side_size1 = side_size(1)
      @side_size1.times do |i|
        next if position_empty?((i * 2) + 1)
        @battler_sprites[(i * 2) + 1] = Sprite.new(self.viewport)
      end
    end
  end

  def refresh_battler_graphics
    if !@user_sprite_name || !@user_sprite_name || @user_sprite_name != @settings[:user_sprite_name]
      @user_sprite_name = @settings[:user_sprite_name]
      @user_bitmap_front&.dispose
      @user_bitmap_back&.dispose
      @user_bitmap_front = RPG::Cache.load_bitmap("Graphics/Pokemon/Front/", @user_sprite_name)
      @user_bitmap_back = RPG::Cache.load_bitmap("Graphics/Pokemon/Back/", @user_sprite_name)
    end
    if !@target_bitmap_front || !@target_sprite_name || @target_sprite_name != @settings[:target_sprite_name]
      @target_sprite_name = @settings[:target_sprite_name]
      @target_bitmap_front&.dispose
      @target_bitmap_back&.dispose
      @target_bitmap_front = RPG::Cache.load_bitmap("Graphics/Pokemon/Front/", @target_sprite_name)
      @target_bitmap_back = RPG::Cache.load_bitmap("Graphics/Pokemon/Back/", @target_sprite_name)
    end
  end

  def refresh_battler_positions
    user_idx = user_index
    @user_coords = recalculate_battler_position(
      user_idx, side_size(user_idx), @user_sprite_name,
      (user_idx.even?) ? @user_bitmap_back : @user_bitmap_front
    )
    target_indices.each do |target_idx|
      @target_coords[target_idx] = recalculate_battler_position(
        target_idx, side_size(target_idx), @target_sprite_name,
        (target_idx.even?) ? @target_bitmap_back : @target_bitmap_front
      )
    end
  end

  def recalculate_battler_position(index, size, sprite_name, btmp)
    spr = Sprite.new(self.viewport)
    spr.x, spr.y = Battle::Scene.pbBattlerPosition(index, size)
    data = GameData::Species.get_species_form(sprite_name, 0)   # Form 0
    data.apply_metrics_to_sprite(spr, index) if data
    return [spr.x, spr.y - (btmp.height / 2)]
  end

  def create_particle_sprite(index, target_idx = -1)
    if target_idx >= 0
      if @particle_sprites[index].is_a?(Array)
        return if @particle_sprites[index][target_idx] && !@particle_sprites[index][target_idx].disposed?
      else
        @particle_sprites[index].dispose if @particle_sprites[index] && !@particle_sprites[index].disposed?
        @particle_sprites[index] = []
      end
      @particle_sprites[index][target_idx] = Sprite.new(self.viewport)
    else
      if @particle_sprites[index].is_a?(Array)
        @particle_sprites[index].each { |s| s.dispose if s && !s.disposed? }
        @particle_sprites[index] = nil
      else
        return if @particle_sprites[index] && !@particle_sprites[index].disposed?
      end
      @particle_sprites[index] = Sprite.new(self.viewport)
    end
  end

  def refresh_sprite(index, target_idx = -1)
    particle = @anim[:particles][index]
    return if !particle
    # Get sprite
    case particle[:name]
    when "SE"
      return
    when "User"
      spr = @battler_sprites[user_index]
      raise _INTL("Sprite for particle {1} not found somehow (battler index {2}).",
                  particle[:name], user_index) if !spr
    when "Target"
      spr = @battler_sprites[target_idx]
      raise _INTL("Sprite for particle {1} not found somehow (battler index {2}).",
                  particle[:name], target_idx) if !spr
    else
      create_particle_sprite(index, target_idx)
      if target_idx >= 0
        spr = @particle_sprites[index][target_idx]
      else
        spr = @particle_sprites[index]
      end
    end
    # Calculate all values of particle at the current keyframe
    values = AnimationEditor::ParticleDataHelper.get_all_keyframe_particle_values(particle, @keyframe)
    values.each_pair do |property, val|
      values[property] = val[0]
    end
    # Set visibility
    spr.visible = values[:visible]
    return if !spr.visible
    # Set opacity
    spr.opacity = values[:opacity]
    # Set coordinates
    spr.x = values[:x]
    spr.y = values[:y]
    case particle[:focus]
    when :foreground, :midground, :background
    when :user
      spr.x += @user_coords[0]
      spr.y += @user_coords[1]
    when :target
      spr.x += @target_coords[target_idx][0]
      spr.y += @target_coords[target_idx][1]
    when :user_and_target
      user_pos = @user_coords
      target_pos = @target_coords[target_idx]
      distance = GameData::Animation::USER_AND_TARGET_SEPARATION
      spr.x = user_pos[0] + ((values[:x].to_f / distance[0]) * (target_pos[0] - user_pos[0])).to_i
      spr.y = user_pos[1] + ((values[:y].to_f / distance[1]) * (target_pos[1] - user_pos[1])).to_i
    when :user_side_foreground, :user_side_background
      base_coords = Battle::Scene.pbBattlerPosition(target_idx)
      spr.x += base_coords[0]
      spr.y += base_coords[1]
    when :target_side_foreground, :target_side_background
      base_coords = Battle::Scene.pbBattlerPosition(target_idx)
      spr.x += base_coords[0]
      spr.y += base_coords[1]
    end
    # Set graphic and ox/oy (may also alter y coordinate)
    case particle[:graphic]
    when "USER", "USER_OPP", "USER_FRONT", "USER_BACK",
         "TARGET", "TARGET_OPP", "TARGET_FRONT", "TARGET_BACK"
      case particle[:graphic]
      when "USER"
        spr.bitmap = (user_index.even?) ? @user_bitmap_back : @user_bitmap_front
      when "USER_OPP"
        spr.bitmap = (user_index.even?) ? @user_bitmap_front : @user_bitmap_back
      when "USER_FRONT"
        spr.bitmap = @user_bitmap_front
      when "USER_BACK"
        spr.bitmap = @user_bitmap_back
      when "TARGET"
        if target_idx < 0
          raise _INTL("Particle {1} was given a graphic of \"TARGET\" but its focus doesn't include a target.",
                      particle[:name])
        end
        spr.bitmap = (target_idx.even?) ? @target_bitmap_back : @target_bitmap_front
      when "TARGET_OPP"
        if target_idx < 0
          raise _INTL("Particle {1} was given a graphic of \"TARGET_OPP\" but its focus doesn't include a target.",
                      particle[:name])
        end
        spr.bitmap = (target_idx.even?) ? @target_bitmap_front : @target_bitmap_back
      when "TARGET_FRONT"
        if target_idx < 0
          raise _INTL("Particle {1} was given a graphic of \"TARGET_FRONT\" but its focus doesn't include a target.",
                      particle[:name])
        end
        spr.bitmap = @target_bitmap_front
      when "TARGET_BACK"
        if target_idx < 0
          raise _INTL("Particle {1} was given a graphic of \"TARGET_BACK\" but its focus doesn't include a target.",
                      particle[:name])
        end
        spr.bitmap = @target_bitmap_back
      end
      spr.ox = spr.bitmap.width / 2
      spr.oy = spr.bitmap.height
      spr.y += spr.bitmap.height / 2
    else
      spr.bitmap = RPG::Cache.load_bitmap("Graphics/Battle animations/", particle[:graphic])
      # TODO: Set the oy to spr.bitmap.height if particle[:graphic] has
      #       something special in it (don't know what yet).
      if spr.bitmap.width > spr.bitmap.height * 2
        spr.src_rect.set(values[:frame] * spr.bitmap.height, 0, spr.bitmap.height, spr.bitmap.height)
        spr.ox = spr.bitmap.height / 2
        spr.oy = spr.bitmap.height / 2
      else
        spr.src_rect.set(0, 0, spr.bitmap.width, spr.bitmap.height)
        spr.ox = spr.bitmap.width / 2
        spr.oy = spr.bitmap.height / 2
      end
    end
    # Set z (priority)
    spr.z = values[:z]
    case particle[:focus]
    when :foreground
      spr.z += 2000
    when :midground
      spr.z += 1000
    when :background
      # NOTE: No change.
    when :user
      spr.z += 1000 + ((100 * ((user_index / 2) + 1)) * (user_index.even? ? 1 : -1))
    when :target
      spr.z += 1000 + ((100 * ((target_idx / 2) + 1)) * (target_idx.even? ? 1 : -1))
    when :user_and_target
      user_pos = 1000 + ((100 * ((user_index / 2) + 1)) * (user_index.even? ? 1 : -1))
      target_pos = 1000 + ((100 * ((target_idx / 2) + 1)) * (target_idx.even? ? 1 : -1))
      distance = GameData::Animation::USER_AND_TARGET_SEPARATION[2]
      spr.z = user_pos + ((values[:z].to_f / distance) * (target_pos - user_pos)).to_i
    when :user_side_foreground, :target_side_foreground
      this_idx = (particle[:focus] == :user_side_foreground) ? user_index : target_idx
      spr.z += 1000
      spr.z += 1000 if this_idx.even?   # On player's side
    when :user_side_background, :target_side_background
      this_idx = (particle[:focus] == :user_side_background) ? user_index : target_idx
      spr.z += 1000 if this_idx.even?   # On player's side
    end
    # Set various other properties
    spr.zoom_x = values[:zoom_x] / 100.0
    spr.zoom_y = values[:zoom_y] / 100.0
    spr.angle = values[:angle]
    spr.mirror = values[:flip]
    spr.blend_type = values[:blending]
    # Set color and tone
    spr.color.set(values[:color_red], values[:color_green], values[:color_blue], values[:color_alpha])
    spr.tone.set(values[:tone_red], values[:tone_green], values[:tone_blue], values[:tone_gray])
  end

  def refresh_particle(index)
    target_indices.each { |target_idx| refresh_sprite(index, target_idx) }
  end

  def refresh
    refresh_bg_graphics
    ensure_battler_sprites
    refresh_battler_graphics
    refresh_battler_positions
    @battler_sprites.each { |s| s.visible = false if s && !s.disposed? }
    @particle_sprites.each do |s|
      if s.is_a?(Array)
        s.each { |s2| s2.visible = false if s2 && !s2.disposed? }
      else
        s.visible = false if s && !s.disposed?
      end
    end
    @anim[:particles].each_with_index do |particle, i|
      if GameData::Animation::FOCUS_TYPES_WITH_TARGET.include?(particle[:focus])
        refresh_particle(i)
      else
        refresh_sprite(i) if particle[:name] != "SE"
      end
    end
  end

  #-----------------------------------------------------------------------------

  # TODO: def update_input. Includes def pbSpriteHitTest equivalent.

  def update
    # TODO: Update input (mouse clicks, dragging particles).
    # TODO: Keyboard shortcuts?
  end
end
