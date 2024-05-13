#===============================================================================
# NOTE: z values:
#       -200 = backdrop.
#       -199 = side bases
#       -198 = battler shadows.
#       0 +/-50 = background focus, foe side background.
#       500, 400, 300... = foe trainers.
#       900, 800, 700... +/-50 = foe battlers.
#       1000 +/-50 = foe side foreground, player side background.
#       1100, 1200, 1300... +/-50 = player battlers.
#       1500, 1600, 1700... = player trainers.
#       2000 +/-50 = player side foreground, foreground focus.
#       9999+ = UI
#===============================================================================
class AnimationEditor::Canvas < Sprite
  attr_reader :sprites    # Only used while playing the animation
  attr_reader :values

  FRAME_SIZE = 48
  PARTICLE_FRAME_COLOR = Color.new(0, 0, 0, 64)

  include UIControls::StyleMixin

  def initialize(viewport, anim, settings)
    super(viewport)
    @anim              = anim
    @settings          = settings
    @keyframe          = 0
    @display_keyframe  = 0
    @selected_particle = -2
    @captured          = nil
    @user_coords       = []
    @target_coords     = []
    initialize_background
    initialize_battlers
    initialize_particle_sprites
    initialize_particle_frames
    refresh
  end

  def initialize_background
    self.z = -200
    # NOTE: The background graphic is self.bitmap.
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

  def initialize_particle_frames
    # Frame for selected particle
    @sel_frame_bitmap = Bitmap.new(FRAME_SIZE, FRAME_SIZE)
    @sel_frame_bitmap.outline_rect(0, 0, @sel_frame_bitmap.width, @sel_frame_bitmap.height, PARTICLE_FRAME_COLOR)
    @sel_frame_bitmap.outline_rect(2, 2, @sel_frame_bitmap.width - 4, @sel_frame_bitmap.height - 4, PARTICLE_FRAME_COLOR)
    @sel_frame_sprite = Sprite.new(viewport)
    @sel_frame_sprite.bitmap = @sel_frame_bitmap
    @sel_frame_sprite.z = 99999
    @sel_frame_sprite.ox = @sel_frame_bitmap.width / 2
    @sel_frame_sprite.oy = @sel_frame_bitmap.height / 2
    # Frame for other particles
    @frame_bitmap = Bitmap.new(FRAME_SIZE, FRAME_SIZE)
    @frame_bitmap.outline_rect(1, 1, @frame_bitmap.width - 2, @frame_bitmap.height - 2, PARTICLE_FRAME_COLOR)
    @battler_frame_sprites = []
    @frame_sprites = []
  end

  def dispose
    @user_bitmap_front&.dispose
    @user_bitmap_back&.dispose
    @target_bitmap_front&.dispose
    @target_bitmap_back&.dispose
    @sel_frame_bitmap&.dispose
    @frame_bitmap&.dispose
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
    @battler_frame_sprites.each { |s| s.dispose if s && !s.disposed? }
    @battler_frame_sprites.clear
    @frame_sprites.each do |s|
      if s.is_a?(Array)
        s.each { |s2| s2.dispose if s2 && !s2.disposed? }
      else
        s.dispose if s && !s.disposed?
      end
    end
    @frame_sprites.clear
    @sel_frame_sprite&.dispose
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

  def first_target_index
    return target_indices.compact[0]
  end

  def position_empty?(index)
    return false if !@anim[:no_user] && user_index == index
    return false if !@anim[:no_target] && target_indices.include?(index)
    return true
  end

  def show_particle_sprite?(index)
    return false if index < 0 || index >= @anim[:particles].length
    particle = @anim[:particles][index]
    return false if !particle || particle[:name] == "SE"
    return false if particle[:spawner] && particle[:spawner] != :none
    return true
  end

  def color_scheme=(value)
    return if @color_scheme == value
    @color_scheme = value
    self.bitmap.font.color = text_color
    self.bitmap.font.size = text_size
    refresh
  end

  def selected_particle=(val)
    return if @selected_particle == val
    @selected_particle = val
    refresh_particle_frame
  end

  def keyframe=(val)
    return if @keyframe == val
    @keyframe = val
    return if val < 0
    @display_keyframe = val
    refresh
  end

  def mouse_pos
    mouse_coords = Mouse.getMousePos
    return nil, nil if !mouse_coords
    ret_x = mouse_coords[0] - self.viewport.rect.x - self.x
    ret_y = mouse_coords[1] - self.viewport.rect.y - self.y
    return nil, nil if ret_x < 0 || ret_x >= self.viewport.rect.width ||
                       ret_y < 0 || ret_y >= self.viewport.rect.height
    return ret_x, ret_y
  end

  def mouse_in_sprite?(sprite, mouse_x, mouse_y)
    return false if mouse_x < sprite.x - sprite.ox
    return false if mouse_x >= sprite.x - sprite.ox + sprite.width
    return false if mouse_y < sprite.y - sprite.oy
    return false if mouse_y >= sprite.y - sprite.oy + sprite.height
    return true
  end

  #-----------------------------------------------------------------------------

  def busy?
    return !@captured.nil?
  end

  def changed?
    return !@values.nil?
  end

  def clear_changed
    @values = nil
  end

  #-----------------------------------------------------------------------------

  def prepare_to_play_animation
    @sprites = {}
    # Populate @sprites with sprites that are present during battle, and reset
    # their x/y/z values so the animation player knows where they start
    idx = user_index
    particle_idx = @anim[:particles].index { |particle| particle[:name] == "User" }
    if particle_idx
      @sprites["pokemon_#{idx}"] = @battler_sprites[idx]
      @battler_sprites[idx].x = @user_coords[0]
      @battler_sprites[idx].y = @user_coords[1]
      offset_xy = AnimationPlayer::Helper.get_xy_offset(@anim[:particles][particle_idx], @battler_sprites[idx])
      focus_z = AnimationPlayer::Helper.get_z_focus(@anim[:particles][particle_idx], idx, idx)
      @battler_sprites[idx].x += offset_xy[0]
      @battler_sprites[idx].y += offset_xy[1]
      AnimationPlayer::Helper.apply_z_focus_to_sprite(@battler_sprites[idx], 0, focus_z)
    end
    particle_idx = @anim[:particles].index { |particle| particle[:name] == "Target" }
    if particle_idx
      target_indices.each do |idx|
        @sprites["pokemon_#{idx}"] = @battler_sprites[idx]
        @battler_sprites[idx].x = @target_coords[idx][0]
        @battler_sprites[idx].y = @target_coords[idx][1]
        if particle_idx
          offset_xy = AnimationPlayer::Helper.get_xy_offset(@anim[:particles][particle_idx], @battler_sprites[idx])
          focus_z = AnimationPlayer::Helper.get_z_focus(@anim[:particles][particle_idx], idx, idx)
        else
          offset_xy = [0, @battler_sprites[idx].bitmap.height / 2]
          focus_z = 1000 + ((100 * ((idx / 2) + 1)) * (idx.even? ? 1 : -1))
        end
        @battler_sprites[idx].x += offset_xy[0]
        @battler_sprites[idx].y += offset_xy[1]
        AnimationPlayer::Helper.apply_z_focus_to_sprite(@battler_sprites[idx], 0, focus_z)
      end
    end
    hide_all_sprites
    @sel_frame_sprite.visible = false
    @playing = true
  end

  def end_playing_animation
    @sprites.clear
    @sprites = nil
    @playing = false
    refresh
  end

  #-----------------------------------------------------------------------------

  def refresh_bg_graphics
    return if @bg_name && @bg_name == @settings[:canvas_bg]
    @bg_name = @settings[:canvas_bg]
    core_name = @bg_name.sub(/_eve$/, "").sub(/_night$/, "")
    if pbResolveBitmap("Graphics/Battlebacks/" + @bg_name + "_bg")
      self.bitmap = RPG::Cache.load_bitmap("Graphics/Battlebacks/", @bg_name + "_bg")
    else
      self.bitmap = RPG::Cache.load_bitmap("Graphics/Battlebacks/", core_name + "_bg")
    end
    if pbResolveBitmap("Graphics/Battlebacks/" + @bg_name + "_base0")
      @player_base.setBitmap("Graphics/Battlebacks/" + @bg_name + "_base0")
    else
      @player_base.setBitmap("Graphics/Battlebacks/" + core_name + "_base0")
    end
    @player_base.ox = @player_base.bitmap.width / 2
    @player_base.oy = @player_base.bitmap.height
    if pbResolveBitmap("Graphics/Battlebacks/" + @bg_name + "_base1")
      @foe_base.setBitmap("Graphics/Battlebacks/" + @bg_name + "_base1")
    else
      @foe_base.setBitmap("Graphics/Battlebacks/" + core_name + "_base1")
    end
    @foe_base.ox = @foe_base.bitmap.width / 2
    @foe_base.oy = @foe_base.bitmap.height / 2
    if pbResolveBitmap("Graphics/Battlebacks/" + @bg_name + "_message")
      @message_bar_sprite.bitmap = RPG::Cache.load_bitmap("Graphics/Battlebacks/", @bg_name + "_message")
    else
      @message_bar_sprite.bitmap = RPG::Cache.load_bitmap("Graphics/Battlebacks/", core_name + "_message")
    end
    @message_bar_sprite.y = Settings::SCREEN_HEIGHT - @message_bar_sprite.height
  end

  def create_frame_sprite(index, sub_index = -1)
    if sub_index >= 0
      if @frame_sprites[index].is_a?(Array)
        return if @frame_sprites[index][sub_index] && !@frame_sprites[index][sub_index].disposed?
      else
        @frame_sprites[index].dispose if @frame_sprites[index] && !@frame_sprites[index].disposed?
        @frame_sprites[index] = []
      end
    else
      if @frame_sprites[index].is_a?(Array)
        @frame_sprites[index].each { |s| s.dispose if s && !s.disposed? }
        @frame_sprites[index] = nil
      else
        return if @frame_sprites[index] && !@frame_sprites[index].disposed?
      end
    end
    sprite = Sprite.new(viewport)
    sprite.bitmap = @frame_bitmap
    sprite.z = 99998
    sprite.ox = @frame_bitmap.width / 2
    sprite.oy = @frame_bitmap.height / 2
    if sub_index >= 0
      @frame_sprites[index] ||= []
      @frame_sprites[index][sub_index] = sprite
    else
      @frame_sprites[index] = sprite
    end
  end

  def ensure_battler_sprites
    should_ensure = @sides_swapped.nil? || @sides_swapped != sides_swapped? ||
                    @settings_user_index.nil? || @settings_user_index != @settings[:user_index] ||
                    @settings_target_indices.nil? || @settings_target_indices != @settings[:target_indices]
    if should_ensure || !@side_size0 || @side_size0 != side_size(0)
      @battler_sprites.each_with_index { |s, i| s.dispose if i.even? && s && !s.disposed? }
      @battler_frame_sprites.each_with_index { |s, i| s.dispose if i.even? && s && !s.disposed? }
      @side_size0 = side_size(0)
      @side_size0.times do |i|
        next if user_index != i * 2 && !target_indices.include?(i * 2)
        @battler_sprites[i * 2] = Sprite.new(self.viewport)
        frame_sprite = Sprite.new(viewport)
        frame_sprite.bitmap = @frame_bitmap
        frame_sprite.z = 99998
        frame_sprite.ox = @frame_bitmap.width / 2
        frame_sprite.oy = @frame_bitmap.height / 2
        @battler_frame_sprites[i * 2] = frame_sprite
      end
    end
    if should_ensure || !@side_size1 || @side_size1 != side_size(1)
      @battler_sprites.each_with_index { |s, i| s.dispose if i.odd? && s && !s.disposed? }
      @battler_frame_sprites.each_with_index { |s, i| s.dispose if i.odd? && s && !s.disposed? }
      @side_size1 = side_size(1)
      @side_size1.times do |i|
        next if user_index != (i * 2) + 1 && !target_indices.include?((i * 2) + 1)
        @battler_sprites[(i * 2) + 1] = Sprite.new(self.viewport)
        frame_sprite = Sprite.new(viewport)
        frame_sprite.bitmap = @frame_bitmap
        frame_sprite.z = 99998
        frame_sprite.ox = @frame_bitmap.width / 2
        frame_sprite.oy = @frame_bitmap.height / 2
        @battler_frame_sprites[(i * 2) + 1] = frame_sprite
      end
    end
    if should_ensure
      @sides_swapped = sides_swapped?
      @settings_user_index = @settings[:user_index]
      @settings_target_indices = @settings[:target_indices].clone
    end
  end

  def refresh_battler_graphics
    if !@user_sprite_name || !@user_sprite_name || @user_sprite_name != @settings[:user_sprite_name]
      @user_sprite_name = @settings[:user_sprite_name]
      @user_bitmap_front_name = GameData::Species.front_sprite_filename(@user_sprite_name)
      @user_bitmap_back_name = GameData::Species.back_sprite_filename(@user_sprite_name)
      @user_bitmap_front&.dispose
      @user_bitmap_back&.dispose
      @user_bitmap_front = RPG::Cache.load_bitmap("", @user_bitmap_front_name)
      @user_bitmap_back = RPG::Cache.load_bitmap("", @user_bitmap_back_name)
    end
    if !@target_bitmap_front || !@target_sprite_name || @target_sprite_name != @settings[:target_sprite_name]
      @target_sprite_name = @settings[:target_sprite_name]
      @target_bitmap_front_name = GameData::Species.front_sprite_filename(@target_sprite_name)
      @target_bitmap_back_name = GameData::Species.back_sprite_filename(@target_sprite_name)
      @target_bitmap_front&.dispose
      @target_bitmap_back&.dispose
      @target_bitmap_front = RPG::Cache.load_bitmap("", @target_bitmap_front_name)
      @target_bitmap_back = RPG::Cache.load_bitmap("", @target_bitmap_back_name)
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
      create_frame_sprite(index, target_idx)
    else
      if @particle_sprites[index].is_a?(Array)
        @particle_sprites[index].each { |s| s.dispose if s && !s.disposed? }
        @particle_sprites[index] = nil
      else
        return if @particle_sprites[index] && !@particle_sprites[index].disposed?
      end
      @particle_sprites[index] = Sprite.new(self.viewport)
      create_frame_sprite(index)
    end
  end

  def get_sprite_and_frame(index, target_idx = -1)
    return if !show_particle_sprite?(index)
    spr = nil
    frame = nil
    particle = @anim[:particles][index]
    case particle[:name]
    when "User"
      spr = @battler_sprites[user_index]
      raise _INTL("Sprite for particle {1} not found somehow (battler index {2}).",
                  particle[:name], user_index) if !spr
      frame = @battler_frame_sprites[user_index]
    when "Target"
      spr = @battler_sprites[target_idx]
      raise _INTL("Sprite for particle {1} not found somehow (battler index {2}).",
                  particle[:name], target_idx) if !spr
      frame = @battler_frame_sprites[target_idx]
    else
      create_particle_sprite(index, target_idx)
      if target_idx >= 0
        spr = @particle_sprites[index][target_idx]
        frame = @frame_sprites[index][target_idx]
      else
        spr = @particle_sprites[index]
        frame = @frame_sprites[index]
      end
    end
    return spr, frame
  end

  def refresh_sprite(index, target_idx = -1)
    particle = @anim[:particles][index]
    return if !show_particle_sprite?(index)
    relative_to_index = -1
    if particle[:focus] != :user_and_target
      if GameData::Animation::FOCUS_TYPES_WITH_USER.include?(particle[:focus])
        relative_to_index = user_index
      elsif GameData::Animation::FOCUS_TYPES_WITH_TARGET.include?(particle[:focus])
        relative_to_index = target_idx
      end
    end
    # Get sprite
    spr, frame = get_sprite_and_frame(index, target_idx)
    # Calculate all values of particle at the current keyframe
    values = AnimationEditor::ParticleDataHelper.get_all_keyframe_particle_values(particle, @display_keyframe)
    values.each_pair do |property, val|
      values[property] = val[0]
    end
    # Set visibility
    spr.visible = values[:visible]
    frame.visible = spr.visible
    return if !spr.visible
    # Set opacity
    spr.opacity = values[:opacity]
    # Set coordinates
    base_x = values[:x]
    base_y = values[:y]
    if relative_to_index >= 0 && relative_to_index.odd?
      base_x *= -1 if particle[:foe_invert_x]
      base_y *= -1 if particle[:foe_invert_y]
    end
    focus_xy = AnimationPlayer::Helper.get_xy_focus(particle, user_index, target_idx,
                                                    @user_coords, @target_coords[target_idx])
    AnimationPlayer::Helper.apply_xy_focus_to_sprite(spr, :x, base_x, focus_xy)
    AnimationPlayer::Helper.apply_xy_focus_to_sprite(spr, :y, base_y, focus_xy)
    # Set graphic and ox/oy (may also alter y coordinate)
    AnimationPlayer::Helper.set_bitmap_and_origin(particle, spr, user_index, target_idx,
                                                  [@user_bitmap_front_name, @user_bitmap_back_name],
                                                  [@target_bitmap_front_name, @target_bitmap_back_name])
    offset_xy = AnimationPlayer::Helper.get_xy_offset(particle, spr)
    spr.x += offset_xy[0]
    spr.y += offset_xy[1]
    # Set frame
    spr.src_rect.x = values[:frame].floor * spr.src_rect.width
    # Set z (priority)
    focus_z = AnimationPlayer::Helper.get_z_focus(particle, user_index, target_idx)
    AnimationPlayer::Helper.apply_z_focus_to_sprite(spr, values[:z], focus_z)
    # Set various other properties
    spr.zoom_x = values[:zoom_x] / 100.0
    spr.zoom_y = values[:zoom_y] / 100.0
    case particle[:angle_override]
    when :initial_angle_to_focus
      target_x = (focus_xy.length == 2) ? focus_xy[1][0] : focus_xy[0][0]
      target_x += offset_xy[0]
      target_y = (focus_xy.length == 2) ? focus_xy[1][1] : focus_xy[0][1]
      target_y += offset_xy[1]
      spr.angle = AnimationPlayer::Helper.initial_angle_between(particle, focus_xy, offset_xy)
    when :always_point_at_focus
      target_x = (focus_xy.length == 2) ? focus_xy[1][0] : focus_xy[0][0]
      target_x += offset_xy[0]
      target_y = (focus_xy.length == 2) ? focus_xy[1][1] : focus_xy[0][1]
      target_y += offset_xy[1]
      spr.angle = AnimationPlayer::Helper.angle_between(spr.x, spr.y, target_x, target_y)
    else
      spr.angle = 0
    end
    spr.angle += values[:angle]
    spr.mirror = values[:flip]
    spr.mirror = !spr.mirror if relative_to_index >= 0 && relative_to_index.odd? && particle[:foe_flip]
    spr.blend_type = values[:blending]
    # Set color and tone
    spr.color.set(values[:color_red], values[:color_green], values[:color_blue], values[:color_alpha])
    spr.tone.set(values[:tone_red], values[:tone_green], values[:tone_blue], values[:tone_gray])
    # Position frame over spr
    frame.x = spr.x
    frame.y = spr.y
    case particle[:graphic]
    when "USER", "USER_OPP", "USER_FRONT", "USER_BACK",
         "TARGET", "TARGET_OPP", "TARGET_FRONT", "TARGET_BACK"
      # Offset battler frames because they aren't around the battler's position
      frame.y -= spr.bitmap.height / 2
    end
  end

  def refresh_particle(index)
    one_per_side = [:target_side_foreground, :target_side_background].include?(@anim[:particles][index][:focus])
    sides_covered = []
    target_indices.each do |target_idx|
      next if one_per_side && sides_covered.include?(target_idx % 2)
      refresh_sprite(index, target_idx)
      sides_covered.push(target_idx % 2)
    end
  end

  def refresh_particle_frame
    return if !show_particle_sprite?(@selected_particle)
    frame_color = focus_color(@anim[:particles][@selected_particle][:focus])
    @sel_frame_bitmap.outline_rect(1, 1, @sel_frame_bitmap.width - 2, @sel_frame_bitmap.height - 2, frame_color)
    update_selected_particle_frame
  end

  def hide_all_sprites
    [@battler_sprites, @battler_frame_sprites].each do |sprites|
      sprites.each { |s| s.visible = false if s && !s.disposed? }
    end
    [@particle_sprites, @frame_sprites].each do |sprites|
      sprites.each do |s|
        if s.is_a?(Array)
          s.each { |s2| s2.visible = false if s2 && !s2.disposed? }
        else
          s.visible = false if s && !s.disposed?
        end
      end
    end
  end

  def refresh
    refresh_bg_graphics
    ensure_battler_sprites
    refresh_battler_graphics
    refresh_battler_positions
    hide_all_sprites
    @anim[:particles].each_with_index do |particle, i|
      if GameData::Animation::FOCUS_TYPES_WITH_TARGET.include?(particle[:focus])
        refresh_particle(i)   # Because there can be multiple targets
      else
        refresh_sprite(i) if show_particle_sprite?(i)
      end
    end
    refresh_particle_frame   # Intentionally after refreshing particles
  end

  #-----------------------------------------------------------------------------

  def on_mouse_press
    mouse_x, mouse_y = mouse_pos
    return if !mouse_x || !mouse_y
    # Check if mouse is over particle frame
    if @sel_frame_sprite.visible &&
       mouse_x >= @sel_frame_sprite.x - @sel_frame_sprite.ox &&
       mouse_x < @sel_frame_sprite.x - @sel_frame_sprite.ox + @sel_frame_sprite.width &&
       mouse_y >= @sel_frame_sprite.y - @sel_frame_sprite.oy &&
       mouse_y < @sel_frame_sprite.y - @sel_frame_sprite.oy + @sel_frame_sprite.height
      if @keyframe >= 0
        @captured = [@sel_frame_sprite.x, @sel_frame_sprite.y,
                     @sel_frame_sprite.x - mouse_x, @sel_frame_sprite.y - mouse_y]
      end
      return
    end
    # Find closest particle to mouse
    nearest_index = -1
    nearest_distance = -1
    @battler_frame_sprites.each_with_index do |sprite, index|
      next if !sprite || !sprite.visible
      next if !mouse_in_sprite?(sprite, mouse_x, mouse_y)
      dist = (sprite.x - mouse_x) ** 2 + (sprite.y - mouse_y) ** 2
      next if nearest_distance >= 0 && nearest_distance < dist
      if index == user_index
        nearest_index = @anim[:particles].index { |particle| particle[:name] == "User" }
      else
        nearest_index = @anim[:particles].index { |particle| particle[:name] == "Target" }
      end
      nearest_distance = dist
    end
    @frame_sprites.each_with_index do |sprite, index|
      sprites = (sprite.is_a?(Array)) ? sprite : [sprite]
      sprites.each do |spr|
        next if !spr || !spr.visible
        next if !mouse_in_sprite?(spr, mouse_x, mouse_y)
        dist = (spr.x - mouse_x) ** 2 + (spr.y - mouse_y) ** 2
        next if nearest_distance >= 0 && nearest_distance < dist
        nearest_index = index
        nearest_distance = dist
      end
    end
    return if nearest_index < 0
    @values = { :particle_index => nearest_index }
  end

  def on_mouse_release
    @captured = nil
  end

  def update_input
    if Input.trigger?(Input::MOUSELEFT)
      on_mouse_press
    elsif busy? && Input.release?(Input::MOUSELEFT)
      on_mouse_release
    end
  end

  def update_particle_moved
    return if !busy?
    mouse_x, mouse_y = mouse_pos
    return if !mouse_x || !mouse_y
    new_canvas_x = mouse_x + @captured[2]
    new_canvas_y = mouse_y + @captured[3]
    return if @captured[0] == new_canvas_x && @captured[1] == new_canvas_y
    particle = @anim[:particles][@selected_particle]
    if GameData::Animation::FOCUS_TYPES_WITH_TARGET.include?(particle[:focus])
      sprite, frame = get_sprite_and_frame(@selected_particle, first_target_index)
    else
      sprite, frame = get_sprite_and_frame(@selected_particle)
    end
    # Check if moved horizontally
    if @captured[0] != new_canvas_x
      new_canvas_pos = mouse_x + @captured[2]
      new_pos = new_canvas_x
      case particle[:focus]
      when :foreground, :midground, :background
      when :user
        new_pos -= @user_coords[0]
      when :target
        new_pos -= @target_coords[first_target_index][0]
      when :user_and_target
        user_pos = @user_coords
        target_pos = @target_coords[first_target_index]
        distance = GameData::Animation::USER_AND_TARGET_SEPARATION
        new_pos -= user_pos[0]
        new_pos *= distance[0]
        new_pos /= target_pos[0] - user_pos[0]
      when :user_side_foreground, :user_side_background
        base_coords = Battle::Scene.pbBattlerPosition(user_index)
        new_pos -= base_coords[0]
      when :target_side_foreground, :target_side_background
        base_coords = Battle::Scene.pbBattlerPosition(first_target_index)
        new_pos -= base_coords[0]
      end
      relative_to_index = -1
      if particle[:focus] != :user_and_target
        if GameData::Animation::FOCUS_TYPES_WITH_USER.include?(particle[:focus])
          relative_to_index = user_index
        elsif GameData::Animation::FOCUS_TYPES_WITH_TARGET.include?(particle[:focus])
          relative_to_index = first_target_index
        end
      end
      new_pos *= -1 if relative_to_index >= 0 && relative_to_index.odd? && particle[:foe_invert_x]
      @values ||= {}
      @values[:x] = new_pos
      @captured[0] = new_canvas_x
      sprite.x = new_canvas_x
    end
    # Check if moved vertically
    if @captured[1] != new_canvas_y
      new_pos = new_canvas_y
      case particle[:focus]
      when :foreground, :midground, :background
      when :user
        new_pos -= @user_coords[1]
      when :target
        new_pos -= @target_coords[first_target_index][1]
      when :user_and_target
        user_pos = @user_coords
        target_pos = @target_coords[first_target_index]
        distance = GameData::Animation::USER_AND_TARGET_SEPARATION
        new_pos -= user_pos[1]
        new_pos *= distance[1]
        new_pos /= target_pos[1] - user_pos[1]
      when :user_side_foreground, :user_side_background
        base_coords = Battle::Scene.pbBattlerPosition(user_index)
        new_pos -= base_coords[1]
      when :target_side_foreground, :target_side_background
        base_coords = Battle::Scene.pbBattlerPosition(first_target_index)
        new_pos -= base_coords[1]
      end
      relative_to_index = -1
      if particle[:focus] != :user_and_target
        if GameData::Animation::FOCUS_TYPES_WITH_USER.include?(particle[:focus])
          relative_to_index = user_index
        elsif GameData::Animation::FOCUS_TYPES_WITH_TARGET.include?(particle[:focus])
          relative_to_index = first_target_index
        end
      end
      new_pos *= -1 if relative_to_index >= 0 && relative_to_index.odd? && particle[:foe_invert_y]
      @values ||= {}
      @values[:y] = new_pos
      @captured[1] = new_canvas_y
      sprite.y = new_canvas_y
    end
  end

  def update_selected_particle_frame
    if !show_particle_sprite?(@selected_particle)
      @sel_frame_sprite.visible = false
      return
    end
    case @anim[:particles][@selected_particle][:name]
    when "User"
      target = @battler_sprites[user_index]
      raise _INTL("Sprite for particle \"{1}\" not found somehow.",
                  @anim[:particles][@selected_particle][:name]) if !target
    when "Target"
      target = @battler_sprites[target_indices[0]]
      raise _INTL("Sprite for particle \"{1}\" not found somehow.",
                  @anim[:particles][@selected_particle][:name]) if !target
    else
      target = @particle_sprites[@selected_particle]
      target = target[first_target_index] if target&.is_a?(Array)
    end
    if !target || !target.visible
      @sel_frame_sprite.visible = false
      return
    end
    @sel_frame_sprite.visible = true
    @sel_frame_sprite.x = target.x
    @sel_frame_sprite.y = target.y
    case @anim[:particles][@selected_particle][:graphic]
    when "USER", "USER_OPP", "USER_FRONT", "USER_BACK",
         "TARGET", "TARGET_OPP", "TARGET_FRONT", "TARGET_BACK"
      # Offset battler frames because they aren't around the battler's position
      @sel_frame_sprite.y -= target.bitmap.height / 2
    end
  end

  def update
    update_input
    update_particle_moved
    update_selected_particle_frame
  end
end
