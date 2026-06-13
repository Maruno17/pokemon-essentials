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
  attr_writer :anim
  attr_reader :sprites    # Only used while playing the animation
  attr_reader :changed_controls

  FRAME_SIZE           = 48
  PARTICLE_FRAME_COLOR = Color.new(0, 0, 0, 64)
  # NOTE: This doesn't include :visible, which is set separately before these.
  SPRITE_PROPERTIES_TO_SET = [
    :x, :x2,
    :y, :y2,
    :r,
    :theta,
    :opacity, :opacity2,
    :frame, :frame2,
    :z, :z2,
    :zoom_x, :zoom_x2,
    :zoom_y, :zoom_y2,
    :angle, :angle2,   # Should be after x/y
    :flip, :flip2,
    :blending, :blending2,
    :color, :color2,
    :tone, :tone2,
    :invert_color, :invert_color2,
    :mask_blending,
    :mask_opacity,
    :mask_x,
    :mask_y,
    :mask_zoom_x,
    :mask_zoom_y
  ]

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
    initialize_bitmaps
    initialize_background
    initialize_battlers
    initialize_particle_sprites
    initialize_particle_frames
    refresh
  end

  def initialize_bitmaps
    # Emitter bitmap
    btmp_size = 16
    btmp_graphic = %w(
      . . . . . . . . . . . . . . . ~
      . . . . . . . . . . . . . . ~ X
      . . . . . . . . . . . . . . ~ X
      . . . . . . . . . . . . . . ~ X
      . . . . . ~ ~ . . . . . . . ~ X
      . . . . ~ X X ~ . . . . . . ~ X
      . . . . ~ X X X ~ . . . . . ~ X
      . . . . . ~ X X X ~ . . . . ~ X
      . . . . . . ~ X X X ~ . . . ~ X
      . . . . . . . ~ X X X ~ . . ~ X
      . . . . . . . . ~ X X X ~ . . ~
      . . . . . . . . . ~ X X ~ . . .
      . . . . . . . . . . ~ ~ . . ~ ~
      . . . . . . . . . . . . . ~ X X
      . ~ ~ ~ ~ ~ ~ ~ ~ ~ . . ~ X ~ ~
      ~ X X X X X X X X X ~ . ~ X ~ X
    )
    btmp = Bitmap.new(btmp_size * 2, btmp_size * 2)
    red_color = Color.red
    white_color = Color.white
    btmp_graphic.length.times do |i|
      next if btmp_graphic[i] == "."
      pixel_x = i % btmp_size
      pixel_y = i / btmp_size
      col = (btmp_graphic[i] == "X") ? red_color : white_color
      btmp.fill_rect(pixel_x, pixel_y, 1, 1, col)
      btmp.fill_rect(btmp.width - 1 - pixel_x, pixel_y, 1, 1, col)
      btmp.fill_rect(pixel_x, btmp.height - 1 - pixel_y, 1, 1, col)
      btmp.fill_rect(btmp.width - 1 - pixel_x, btmp.height - 1 - pixel_y, 1, 1, col)
    end
    @emitter_bitmap = btmp
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
    @particle_tiled_sprites = []
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
    @emitter_bitmap&.dispose
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
      next if !s
      s.each do |s2|
        next if !s2
        s2.each { |s3| s3.dispose if s3 && !s3.disposed? }
      end
    end
    @particle_sprites.clear
    @particle_tiled_sprites.each do |sprites|
      next if sprites.nil? || sprites.empty?
      sprites.each do |s|
        if s.is_a?(Array)
          s.each { |s2| s2.dispose if s2 && !s2.disposed? }
        else
          s.dispose if s && !s.disposed?
        end
      end
      sprites.clear
    end
    @particle_tiled_sprites.clear
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
    return true
  end

  def color_scheme=(value)
    return if @color_scheme == value
    @color_scheme = value
    self.bitmap.font.color = get_color_of(:text)
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

  def moving_particle?
    return busy? && @captured.length == 4
  end

  def rotating_particle?
    return busy? && @captured.length == 3
  end

  def changed?
    return !@changed_controls.nil?
  end

  def clear_changed
    @changed_controls = nil
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
      @battler_sprites[idx].x = @user_coords[0] - (@battler_sprites[idx].bitmap.width / 2) + @battler_sprites[idx].ox
      @battler_sprites[idx].y = @user_coords[1] - (@battler_sprites[idx].bitmap.height / 2) + @battler_sprites[idx].oy
      focus_z = AnimationPlayer::Helper.get_z_focus(@anim[:particles][particle_idx], idx, idx)
      AnimationPlayer::Helper.apply_z_focus_to_sprite(@battler_sprites[idx], 0, focus_z)
    end
    particle_idx = @anim[:particles].index { |particle| particle[:name] == "Target" }
    if particle_idx
      target_indices.each do |idx|
        @sprites["pokemon_#{idx}"] = @battler_sprites[idx]
        @battler_sprites[idx].x = @target_coords[idx][0] - (@battler_sprites[idx].bitmap.width / 2) + @battler_sprites[idx].ox
        @battler_sprites[idx].y = @target_coords[idx][1] - (@battler_sprites[idx].bitmap.height / 2) + @battler_sprites[idx].oy
        if particle_idx
          focus_z = AnimationPlayer::Helper.get_z_focus(@anim[:particles][particle_idx], idx, idx)
        else
          focus_z = 1000 + ((100 * ((idx / 2) + 1)) * (idx.even? ? 1 : -1))
        end
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

  # Determines the coordinates of the centers of every battler sprite. This is
  # the exact geometric middle of the graphic, not where the sprites' ox/oy are.
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

  # Returns the coordinates of the center of the battler sprite at index.
  def recalculate_battler_position(index, size, sprite_name, btmp)
    spr = Sprite.new(self.viewport)
    spr.x, spr.y = Battle::Scene.pbBattlerPosition(index, size)
    species = sprite_name.gsub("_female", "").gsub("_shadow", "")
    form = 0
    if species[/^(\w+)_(\d+)$/]
      species = $~[1]
      form = $~[2].to_i
    end
    data = GameData::SpeciesMetrics.get_species_form(species, form)
    data.apply_metrics_to_sprite(spr, index) if data
    ret = [spr.x - spr.ox, spr.y - spr.oy - (btmp.height / 2)]
    spr.dispose
    return ret
  end

  def create_particle_sprite(index, target_idx = -1)
    @particle_sprites[index] ||= []
    this_index = (target_idx >= 0) ? target_idx : 0
    @particle_sprites[index][this_index] ||= [Sprite.new(self.viewport), Sprite.new(self.viewport)]
    # Make tiled sprites
    if target_idx < 0 && @anim[:particles][index][:tiled_graphic]
      # NOTE: Tiled sprites shouldn't be used with foci featuring multiple
      #       targets (they're meant for scrolling backgrounds), so I'm not
      #       bothering to support them here.
      @particle_tiled_sprites[index] ||= []
      if !@particle_tiled_sprites[index][0] || @particle_tiled_sprites[index][0].disposed?
        3.times { |i| @particle_tiled_sprites[index].push(Sprite.new(self.viewport)) }
      end
    elsif @particle_tiled_sprites[index]
      @particle_tiled_sprites[index].each { |s| s.dispose if s && !s.disposed? }
      @particle_tiled_sprites[index] = nil
    end
    create_frame_sprite(index, target_idx)
  end

  def get_sprite_and_frame(index, target_idx = -1)
    return nil, nil if !show_particle_sprite?(index)
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
        spr = @particle_sprites[index][target_idx][0]
        frame = @frame_sprites[index][target_idx]
      else
        spr = @particle_sprites[index][0][0]
        frame = @frame_sprites[index]
      end
    end
    return spr, frame
  end

  def get_second_sprite(index, target_idx = -1)
    return nil if !show_particle_sprite?(index)
    return nil if ["User", "Target"].include?(@anim[:particles][index][:name])
    if target_idx >= 0
      return nil if !@particle_sprites[index][target_idx]
      return @particle_sprites[index][target_idx][1]
    end
    return nil if !@particle_sprites[index][0]
    return @particle_sprites[index][0][1]
  end

  def refresh_sprite(index, target_idx = -1)
    particle = @anim[:particles][index]
    return if !show_particle_sprite?(index)
    # Get sprites
    spr, frame = get_sprite_and_frame(index, target_idx)
    spr2 = get_second_sprite(index, target_idx)
    # Calculate all values of particle at the current keyframe
    values = AnimationEditor::ParticleDataHelper.get_all_keyframe_particle_values(particle, @display_keyframe)
    values.each_pair { |property, val| values[property] = val[0] }
    # Set visible
    apply_sprite_property(particle, index, :visible, values[:visible], target_idx, spr, spr2)
    frame.visible = spr.visible
    return if !spr.visible
    # Set position, graphic and ox/oy for emitter
    if (particle[:emitter_type] || :none) != :none
      SPRITE_PROPERTIES_TO_SET.each do |property|
        val = ([:x, :y, :r, :theta].include?(property)) ? values[property] : GameData::Animation::PARTICLE_KEYFRAME_DEFAULT_VALUES[property]
        apply_sprite_property(particle, index, property, val, target_idx, spr, spr2)
      end
      # Emitter
      spr.z = 99997
      spr.bitmap = @emitter_bitmap
      spr.opacity = 255
      spr.ox = spr.bitmap.width / 2
      spr.oy = spr.bitmap.height / 2
      frame.x = spr.x
      frame.y = spr.y
      return
    end
    # Set graphic and ox/oy
    AnimationPlayer::Helper.set_bitmap_and_origin(
      particle, spr, user_index, target_idx,
      [@user_bitmap_front_name, @user_bitmap_back_name], [@target_bitmap_front_name, @target_bitmap_back_name]
    )
    if spr && (particle[:mask_graphic] || "") != ""
      spr.pattern = RPG::Cache.load_bitmap("Graphics/Battle animations/", particle[:mask_graphic] || "")
    end
    AnimationPlayer::Helper.set_bitmap_and_origin(
      particle, spr2, user_index, target_idx,
      [@user_bitmap_front_name, @user_bitmap_back_name], [@target_bitmap_front_name, @target_bitmap_back_name]
    )
    if @particle_tiled_sprites[index]
      @particle_tiled_sprites[index].each do |ts|
        AnimationPlayer::Helper.set_bitmap_and_origin(
          particle, ts, user_index, target_idx,
          [@user_bitmap_front_name, @user_bitmap_back_name], [@target_bitmap_front_name, @target_bitmap_back_name]
        )
      end
    end
    # Set properties of sprites
    SPRITE_PROPERTIES_TO_SET.each do |property|
      apply_sprite_property(particle, index, property, values[property], target_idx, spr, spr2)
    end
    # Adjust ox/oy for sprites that use a battler graphic (intentionally after
    # calling apply_sprite_property for SPRITE_PROPERTIES_TO_SET because this
    # also changes a sprite's x/y) - this keeps the sprite in the same part of
    # the screen, but gives the sprite its proper ox/oy
    case particle[:graphic]
    when "USER", "USER_OPP", "USER_FRONT", "USER_BACK"
      AnimationPlayer::Helper.adjust_origin_by_battler_metrics(particle, spr, user_index, @user_sprite_name)
      AnimationPlayer::Helper.adjust_origin_by_battler_metrics(particle, spr2, user_index, @user_sprite_name) if spr2
    when "TARGET", "TARGET_OPP", "TARGET_FRONT", "TARGET_BACK"
      AnimationPlayer::Helper.adjust_origin_by_battler_metrics(particle, spr, target_idx, @target_sprite_name)
      AnimationPlayer::Helper.adjust_origin_by_battler_metrics(particle, spr2, target_idx, @target_sprite_name) if spr2
    end
    # Position frame over sprite
    frame.x = spr.x
    frame.y = spr.y
    case particle[:graphic]
    when "USER", "USER_OPP", "USER_FRONT", "USER_BACK",
         "TARGET", "TARGET_OPP", "TARGET_FRONT", "TARGET_BACK"
      # Offset battler frames because their x/y is where their feet are rather
      # than the middle of their graphic
      frame.x += (spr.bitmap.width / 2) - spr.ox
      frame.y += (spr.bitmap.height / 2) - spr.oy
    end
  end

  def apply_sprite_property(particle, index, property, value, target_idx, sprite1, sprite2 = nil)
    case property
    when :frame
      sprite1.src_rect.x = value.floor * sprite1.src_rect.width
    when :frame2
      sprite2.src_rect.x = value.floor * sprite2.src_rect.width if sprite2
    when :blending
      sprite1.blend_type = value
      if @particle_tiled_sprites[index]
        @particle_tiled_sprites[index].each { |ts| ts.blend_type = sprite1.blend_type }
      end
    when :blending2
      sprite2.blend_type = value if sprite2
    when :flip
      sprite1.mirror = value
      relative_to_index = -1
      if !GameData::Animation::FOCUS_TYPES_WITH_USER_AND_TARGET.include?(particle[:focus])
        if GameData::Animation::FOCUS_TYPES_WITH_USER.include?(particle[:focus])
          relative_to_index = user_index
        elsif GameData::Animation::FOCUS_TYPES_WITH_TARGET.include?(particle[:focus])
          relative_to_index = target_idx
        end
      end
      sprite1.mirror = !sprite1.mirror if relative_to_index >= 0 && relative_to_index.odd? && particle[:foe_flip]
      if @particle_tiled_sprites[index]
        @particle_tiled_sprites[index].each { |ts| ts.mirror = sprite1.mirror }
      end
    when :flip2
      if sprite2
        sprite2.mirror = sprite1.mirror
        sprite2.mirror = !sprite2.mirror if value
      end
    when :x
      polar = ((particle[:emitter_type] || :none) == :none) ? particle[:polar_coordinates] : particle[:emitter_polar_coordinates]
      return if polar
      relative_to_index = -1
      if !GameData::Animation::FOCUS_TYPES_WITH_USER_AND_TARGET.include?(particle[:focus])
        if GameData::Animation::FOCUS_TYPES_WITH_USER.include?(particle[:focus])
          relative_to_index = user_index
        elsif GameData::Animation::FOCUS_TYPES_WITH_TARGET.include?(particle[:focus])
          relative_to_index = target_idx
        end
      end
      x_property = ((particle[:emitter_type] || :none) == :none) ? :x : :emit_x
      base_x = AnimationEditor::ParticleDataHelper.get_keyframe_particle_value(particle, x_property, @display_keyframe)[0]
      if relative_to_index >= 0 && relative_to_index.odd?
        base_x *= -1 if particle[:foe_invert_x]
      end
      focus_xy = AnimationPlayer::Helper.get_xy_focus(particle, user_index, target_idx,
                                                      @user_coords, @target_coords[target_idx],
                                                      [side_size(0), side_size(1)])
      AnimationPlayer::Helper.apply_xy_focus_to_sprite(sprite1, :x, base_x, focus_xy)
      offset_xy = AnimationPlayer::Helper.get_xy_offset(particle, sprite1)
      sprite1.x += offset_xy[0]
      if @particle_tiled_sprites[index]
        while sprite1.x < 0
          sprite1.x += sprite1.src_rect.width
        end
        while sprite1.x >= sprite1.src_rect.width
          sprite1.x -= sprite1.src_rect.width
        end
        @particle_tiled_sprites[index].each_with_index do |ts, i|
          ts.x = sprite1.x
          ts.x -= sprite1.src_rect.width if i.even?
        end
      end
    when :x2
      sprite2.x = sprite1.x + value if sprite2
    when :y
      polar = ((particle[:emitter_type] || :none) == :none) ? particle[:polar_coordinates] : particle[:emitter_polar_coordinates]
      return if polar
      relative_to_index = -1
      if !GameData::Animation::FOCUS_TYPES_WITH_USER_AND_TARGET.include?(particle[:focus])
        if GameData::Animation::FOCUS_TYPES_WITH_USER.include?(particle[:focus])
          relative_to_index = user_index
        elsif GameData::Animation::FOCUS_TYPES_WITH_TARGET.include?(particle[:focus])
          relative_to_index = target_idx
        end
      end
      y_property = ((particle[:emitter_type] || :none) == :none) ? :y : :emit_y
      base_y = AnimationEditor::ParticleDataHelper.get_keyframe_particle_value(particle, y_property, @display_keyframe)[0]
      if relative_to_index >= 0 && relative_to_index.odd?
        base_y *= -1 if particle[:foe_invert_y]
      end
      focus_xy = AnimationPlayer::Helper.get_xy_focus(particle, user_index, target_idx,
                                                      @user_coords, @target_coords[target_idx],
                                                      [side_size(0), side_size(1)])
      AnimationPlayer::Helper.apply_xy_focus_to_sprite(sprite1, :y, base_y, focus_xy)
      offset_xy = AnimationPlayer::Helper.get_xy_offset(particle, sprite1)
      sprite1.y += offset_xy[1]
      if @particle_tiled_sprites[index]
        while sprite1.y < 0
          sprite1.y += sprite1.src_rect.height
        end
        while sprite1.y >= sprite1.src_rect.height
          sprite1.y -= sprite1.src_rect.height
        end
        @particle_tiled_sprites[index].each_with_index do |ts, i|
          ts.y = sprite1.y
          ts.y -= sprite1.src_rect.height if i > 0
        end
      end
    when :y2
      sprite2.y = sprite1.y + value if sprite2
    when :r, :theta
      polar = ((particle[:emitter_type] || :none) == :none) ? particle[:polar_coordinates] : particle[:emitter_polar_coordinates]
      return if !polar
      relative_to_index = -1
      if !GameData::Animation::FOCUS_TYPES_WITH_USER_AND_TARGET.include?(particle[:focus])
        if GameData::Animation::FOCUS_TYPES_WITH_USER.include?(particle[:focus])
          relative_to_index = user_index
        elsif GameData::Animation::FOCUS_TYPES_WITH_TARGET.include?(particle[:focus])
          relative_to_index = target_idx
        end
      end
      dist_property = ((particle[:emitter_type] || :none) == :none) ? :r : :emit_r
      dir_property = ((particle[:emitter_type] || :none) == :none) ? :theta : :emit_theta
      dist = AnimationEditor::ParticleDataHelper.get_keyframe_particle_value(particle, dist_property, @display_keyframe)[0]
      dir = AnimationEditor::ParticleDataHelper.get_keyframe_particle_value(particle, dir_property, @display_keyframe)[0]
      base_x = (dist * Math.cos(dir * Math::PI / 180)).round
      base_y = (-dist * Math.sin(dir * Math::PI / 180)).round
      if relative_to_index >= 0 && relative_to_index.odd?
        base_x *= -1 if particle[:foe_invert_x]
        base_y *= -1 if particle[:foe_invert_y]
      end
      focus_xy = AnimationPlayer::Helper.get_xy_focus(particle, user_index, target_idx,
                                                      @user_coords, @target_coords[target_idx],
                                                      [side_size(0), side_size(1)])
      AnimationPlayer::Helper.apply_xy_focus_to_sprite(sprite1, :x, base_x, focus_xy)
      AnimationPlayer::Helper.apply_xy_focus_to_sprite(sprite1, :y, base_y, focus_xy)
      offset_xy = AnimationPlayer::Helper.get_xy_offset(particle, sprite1)
      sprite1.x += offset_xy[0]
      sprite1.y += offset_xy[1]
      if @particle_tiled_sprites[index]
        while sprite1.x < 0
          sprite1.x += sprite1.src_rect.width
        end
        while sprite1.x >= sprite1.src_rect.width
          sprite1.x -= sprite1.src_rect.width
        end
        @particle_tiled_sprites[index].each_with_index do |ts, i|
          ts.x = sprite1.x
          ts.x -= sprite1.src_rect.width if i.even?
        end
        while sprite1.y < 0
          sprite1.y += sprite1.src_rect.height
        end
        while sprite1.y >= sprite1.src_rect.height
          sprite1.y -= sprite1.src_rect.height
        end
        @particle_tiled_sprites[index].each_with_index do |ts, i|
          ts.y = sprite1.y
          ts.y -= sprite1.src_rect.height if i > 0
        end
      end
    when :z
      focus_z = AnimationPlayer::Helper.get_z_focus(particle, user_index, target_idx)
      AnimationPlayer::Helper.apply_z_focus_to_sprite(sprite1, value, focus_z)
      if @particle_tiled_sprites[index]
        @particle_tiled_sprites[index].each { |ts| ts.z = sprite1.z }
      end
    when :z2
      sprite2.z = sprite1.z + value if sprite2
    when :zoom_x
      sprite1.zoom_x = value / 100.0
    when :zoom_x2
      sprite2.zoom_x = sprite1.zoom_x * value / 100.0 if sprite2
    when :zoom_y
      sprite1.zoom_y = value / 100.0
    when :zoom_y2
      sprite2.zoom_y = sprite1.zoom_y * value / 100.0 if sprite2
    when :angle
      case particle[:angle_override]
      when :initial_angle_to_focus
        focus_xy = AnimationPlayer::Helper.get_xy_focus(
          particle, user_index, target_idx,
          @user_coords, @target_coords[target_idx], [side_size(0), side_size(1)]
        )
        offset_xy = AnimationPlayer::Helper.get_xy_offset(particle, sprite1)
        target_x = (focus_xy.length == 2) ? focus_xy[1][0] : focus_xy[0][0]
        target_x += offset_xy[0]
        target_y = (focus_xy.length == 2) ? focus_xy[1][1] : focus_xy[0][1]
        target_y += offset_xy[1]
        sprite1.angle = AnimationPlayer::Helper.initial_angle_between(particle, focus_xy, offset_xy)
      when :always_point_at_focus
        focus_xy = AnimationPlayer::Helper.get_xy_focus(
          particle, user_index, target_idx,
          @user_coords, @target_coords[target_idx], [side_size(0), side_size(1)]
        )
        offset_xy = AnimationPlayer::Helper.get_xy_offset(particle, sprite1)
        target_x = (focus_xy.length == 2) ? focus_xy[1][0] : focus_xy[0][0]
        target_x += offset_xy[0]
        target_y = (focus_xy.length == 2) ? focus_xy[1][1] : focus_xy[0][1]
        target_y += offset_xy[1]
        sprite1.angle = AnimationPlayer::Helper.angle_between(sprite1.x, sprite1.y, target_x, target_y)
      else
        sprite1.angle = 0
      end
      sprite1.angle += value
    when :angle2
      sprite2.angle = sprite1.angle + value if sprite2
    when :visible
      visible_property = ((particle[:emitter_type] || :none) == :none) ? property : :emitting
      vis = AnimationEditor::ParticleDataHelper.get_keyframe_particle_value(particle, visible_property, @display_keyframe)[0]
      last_frame_visible = false
      if !vis && @display_keyframe > 0
        last_frame_visible = AnimationEditor::ParticleDataHelper.get_keyframe_particle_value(particle, visible_property, @display_keyframe - 1)[0]
      end
      sprite1.visible = vis || last_frame_visible
      if sprite2
        sprite2.visible = sprite1.visible && particle[:second_layer] && (particle[:emitter_type] || :none) == :none
      end
      if @particle_tiled_sprites[index]
        @particle_tiled_sprites[index].each { |ts| ts.visible = sprite1.visible }
      end
    when :opacity
      vis = AnimationEditor::ParticleDataHelper.get_keyframe_particle_value(particle, :visible, @display_keyframe)[0]
      sprite1.opacity = (vis) ? value : 0
      if @particle_tiled_sprites[index]
        @particle_tiled_sprites[index].each { |ts| ts.opacity = sprite1.opacity }
      end
    when :opacity2
      sprite2.opacity = sprite1.opacity + value if sprite2
    when :color
      col = Color.new_from_rgb(value)
      sprite1.color.set(col.red, col.green, col.blue, col.alpha)
      if @particle_tiled_sprites[index]
        @particle_tiled_sprites[index].each { |ts| ts.color.set(col.red, col.green, col.blue, col.alpha) }
      end
    when :color2
      if sprite2
        col = Color.new_from_rgb(value)
        sprite2.color.set(col.red, col.green, col.blue, col.alpha)
      end
    when :tone
      ton = Tone.new_from_rgbg(value)
      sprite1.tone.set(ton.red, ton.green, ton.blue, ton.gray)
      if @particle_tiled_sprites[index]
        @particle_tiled_sprites[index].each { |ts| ts.tone.set(ton.red, ton.green, ton.blue, ton.gray) }
      end
    when :tone2
      if sprite2
        ton = Tone.new_from_rgbg(value)
        sprite2.tone.set(ton.red, ton.green, ton.blue, ton.gray)
      end
    when :invert_color
      sprite1.invert = value
      if @particle_tiled_sprites[index]
        @particle_tiled_sprites[index].each { |ts| ts.invert = sprite1.invert }
      end
    when :invert_color2
      if sprite2
        sprite2.invert = sprite1.invert
        sprite2.invert = !sprite2.invert if value
      end
    when :mask_blending
      sprite1.pattern_blend_type = value
    when :mask_opacity
      sprite1.pattern_opacity = value
    when :mask_x
      sprite1.pattern_scroll_x = value
    when :mask_y
      sprite1.pattern_scroll_y = value
    when :mask_zoom_x
      sprite1.pattern_zoom_x = value / 100.0
    when :mask_zoom_y
      sprite1.pattern_zoom_y = value / 100.0
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
          s.each do |s2|
            if s2.is_a?(Array)
              s2.each { |s3| s3.visible = false if s3 && !s3.disposed? }
            else
              s2.visible = false if s2 && !s2.disposed?
            end
          end
        else
          s.visible = false if s && !s.disposed?
        end
      end
    end
    @particle_tiled_sprites.each do |sprites|
      next if sprites.nil? || sprites.empty?
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

  def update_input
    particle = (@selected_particle) ? @anim[:particles][@selected_particle] : nil
    particle = nil if particle && particle[:name] == "SE"
    update_input_move_particle(particle) if particle
    update_input_mouse_wheel_particle(particle) if particle
    # Mouse clicks
    if !busy?
      if Input.trigger?(Input::MOUSELEFT)
        on_mouse_press
      elsif Input.trigger?(Input::MOUSERIGHT)
        on_mouse_right_press
      end
    elsif particle
      if Input.release?(Input::MOUSELEFT) || Input.release?(Input::MOUSERIGHT)
        on_mouse_release
      end
    end
  end

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
      next if !sprite || sprite.disposed? || !sprite.visible
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
        next if !spr || spr.disposed? || !spr.visible
        next if !mouse_in_sprite?(spr, mouse_x, mouse_y)
        dist = (spr.x - mouse_x) ** 2 + (spr.y - mouse_y) ** 2
        next if nearest_distance >= 0 && nearest_distance < dist
        nearest_index = index
        nearest_distance = dist
      end
    end
    return if nearest_index < 0
    @changed_controls = {:particle_index => nearest_index}
  end

  def on_mouse_right_press
    mouse_x, mouse_y = mouse_pos
    return if !mouse_x || !mouse_y
    particle = (@selected_particle) ? @anim[:particles][@selected_particle] : nil
    particle = nil if particle[:name] == "SE"
    return if !particle
    if GameData::Animation::FOCUS_TYPES_WITH_TARGET.include?(particle[:focus])
      sprite, _frame = get_sprite_and_frame(@selected_particle, first_target_index)
    else
      sprite, _frame = get_sprite_and_frame(@selected_particle)
    end
    @captured = [mouse_x, mouse_y, sprite.angle]
  end

  def on_mouse_release
    # NOTE: We set this value now for the sake of recording a snapshot in the
    #       undo history.
    @changed_controls ||= {}
    @changed_controls[:on_mouse_release] = true
    @captured = nil
  end

  def update_input_move_particle(particle)
    increment = (Input.pressex?(:LCTRL) || Input.pressex?(:RCTRL)) ? 10 : 1
    # Move selected particle left/right
    x_move = 0
    if Input.triggerex?(:A) || Input.repeatex?(:A)
      x_move = -increment
    elsif Input.triggerex?(:D) || Input.repeatex?(:D)
      x_move = increment
    end
    if x_move != 0
      if GameData::Animation::FOCUS_TYPES_WITH_TARGET.include?(particle[:focus])
        sprite, frame = get_sprite_and_frame(@selected_particle, first_target_index)
      else
        sprite, frame = get_sprite_and_frame(@selected_particle)
      end
      x_move *= -1 if particle[:polar_coordinates]
      if (particle[:emitter_type] || :none) == :none
        property = (particle[:polar_coordinates]) ? :theta : :x
      else
        property = (particle[:emitter_polar_coordinates]) ? :emit_theta : :emit_x
      end
      new_pos = AnimationEditor::ParticleDataHelper.get_keyframe_particle_value(particle, property, @display_keyframe)[0] + x_move
      @changed_controls ||= {}
      @changed_controls[property] = new_pos
    end
    # Move selected particle up/down
    y_move = 0
    if Input.triggerex?(:W) || Input.repeatex?(:W)
      y_move = -increment
    elsif Input.triggerex?(:S) || Input.repeatex?(:S)
      y_move = increment
    end
    if y_move != 0
      if GameData::Animation::FOCUS_TYPES_WITH_TARGET.include?(particle[:focus])
        sprite, frame = get_sprite_and_frame(@selected_particle, first_target_index)
      else
        sprite, frame = get_sprite_and_frame(@selected_particle)
      end
      y_move *= -1 if particle[:polar_coordinates]
      if (particle[:emitter_type] || :none) == :none
        property = (particle[:polar_coordinates]) ? :r : :y
      else
        property = (particle[:emitter_polar_coordinates]) ? :emit_r : :emit_y
      end
      new_pos = AnimationEditor::ParticleDataHelper.get_keyframe_particle_value(particle, property, @display_keyframe)[0] + y_move
      @changed_controls ||= {}
      @changed_controls[property] = new_pos
    end
    if Input.releaseex?(:W) || Input.releaseex?(:A) || Input.releaseex?(:S) || Input.releaseex?(:D)
      if !Input.pressex?(:W) && !Input.pressex?(:A) && !Input.pressex?(:S) && !Input.pressex?(:D)
        @changed_controls ||= {}
        @changed_controls[:on_dir_keys_release] = true
      end
    end
  end

  def update_input_mouse_wheel_particle(particle)
    mouse_x, mouse_y = mouse_pos
    wheel_v = Input.scroll_v
    if mouse_x && mouse_y && wheel_v != 0
      # TODO: mkxp-z has a bug whereby holding Ctrl stops the scroll wheel from
      #       being updated. Await the implementation of its fix.
      increment = (Input.pressex?(:LCTRL) || Input.pressex?(:RCTRL)) ? 20 : 5
      @changed_controls ||= {}
      @changed_controls[:zoom] = (wheel_v > 0) ? increment : -increment
      @scrolling = true
      @time_last_scrolled = System.uptime   # Coyote time
    elsif @scrolling && System.uptime - @time_last_scrolled > 0.4
      # NOTE: We set this value now for the sake of recording a snapshot in the
      #       undo history.
      @changed_controls ||= {}
      @changed_controls[:on_mouse_wheel_stopped] = true
      @scrolling = false
      @time_last_scrolled = nil
    end
  end

  def update_particle_moved
    return if !moving_particle?
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
    spr2 = get_second_sprite(@selected_particle, first_target_index)
    # Check if moved at all (in polar coordinates)
    if (particle[:polar_coordinates] && (particle[:emitter_type] || :none) == :none) ||
       (particle[:emitter_polar_coordinates] && (particle[:emitter_type] || :none) != :none)
      new_pos_x = new_canvas_x
      new_pos_y = new_canvas_y
      case particle[:focus]
      when :foreground, :midground, :background
      when :user
        new_pos_x -= @user_coords[0]
        new_pos_y -= @user_coords[1]
      when :user_position
        new_pos_x -= @user_coords[0]
        base_coords = Battle::Scene.pbBattlerPosition(user_index, side_size(user_index))
        new_pos_y -= base_coords[1]
      when :target
        new_pos_x -= @target_coords[first_target_index][0]
        new_pos_y -= @target_coords[first_target_index][1]
      when :target_position
        new_pos_x -= @target_coords[first_target_index][0]
        base_coords = Battle::Scene.pbBattlerPosition(first_target_index, side_size(first_target_index))
        new_pos_y -= base_coords[1]
      when :user_and_target, :user_position_and_target, :user_and_target_position,
           :user_position_and_target_position
        user_pos = @user_coords
        if [:user_position_and_target, :user_position_and_target_position].include?(particle[:focus])
          user_pos = [user_pos[0], Battle::Scene.pbBattlerPosition(user_index, side_size(user_index))[1]]
        end
        target_pos = @target_coords[first_target_index]
        if [:user_and_target_position, :user_position_and_target_position].include?(particle[:focus])
          target_pos = [target_pos[0], Battle::Scene.pbBattlerPosition(first_target_index, side_size(first_target_index))[1]]
        end
        distance = GameData::Animation::USER_AND_TARGET_SEPARATION
        new_pos_x -= user_pos[0]
        new_pos_x *= distance[0]
        new_pos_x /= target_pos[0] - user_pos[0]
        new_pos_y -= user_pos[1]
        new_pos_y *= distance[1]
        new_pos_y /= target_pos[1] - user_pos[1]
      when :user_side_foreground, :user_side_background
        base_coords = Battle::Scene.pbBattlerPosition(user_index)
        new_pos_x -= base_coords[0]
        new_pos_y -= base_coords[1]
      when :target_side_foreground, :target_side_background
        base_coords = Battle::Scene.pbBattlerPosition(first_target_index)
        new_pos_x -= base_coords[0]
        new_pos_y -= base_coords[1]
      end
      relative_to_index = -1
      if !GameData::Animation::FOCUS_TYPES_WITH_USER_AND_TARGET.include?(particle[:focus])
        if GameData::Animation::FOCUS_TYPES_WITH_USER.include?(particle[:focus])
          relative_to_index = user_index
        elsif GameData::Animation::FOCUS_TYPES_WITH_TARGET.include?(particle[:focus])
          relative_to_index = first_target_index
        end
      end
      new_pos_x *= -1 if relative_to_index >= 0 && relative_to_index.odd? && particle[:foe_invert_x]
      new_pos_y *= -1 if relative_to_index >= 0 && relative_to_index.odd? && particle[:foe_invert_y]
      @changed_controls ||= {}
      property_r = ((particle[:emitter_type] || :none) == :none) ? :r : :emit_r
      property_theta = ((particle[:emitter_type] || :none) == :none) ? :theta : :emit_theta
      if new_pos_x == 0
        new_r = new_pos_y.abs
        new_theta = (new_pos_y > 0) ? 270 : 90
      else
        new_r = Math.sqrt((new_pos_x ** 2) + (new_pos_y ** 2)).round
        new_theta = (Math.atan(-new_pos_y / new_pos_x.to_f) * 180 / Math::PI).round
        new_theta += 180 if new_pos_x < 0
        new_theta += 360 if new_theta < 0
      end
      @changed_controls[property_r] = new_r
      @changed_controls[property_theta] = new_theta
      @captured[0] = new_canvas_x
      @captured[1] = new_canvas_y
      sprite.x = new_canvas_x
      sprite.y = new_canvas_y
      if spr2
        value_x = AnimationEditor::ParticleDataHelper.get_keyframe_particle_value(particle, :x2, @display_keyframe)
        value_y = AnimationEditor::ParticleDataHelper.get_keyframe_particle_value(particle, :y2, @display_keyframe)
        spr2.x = sprite.x + value_x[0]
        spr2.y = sprite.y + value_y[0]
      end
      return
    end
    # Check if moved horizontally
    if @captured[0] != new_canvas_x
      new_pos_x = new_canvas_x
      case particle[:focus]
      when :foreground, :midground, :background
      when :user, :user_position
        new_pos_x -= @user_coords[0]
      when :target, :target_position
        new_pos_x -= @target_coords[first_target_index][0]
      when :user_and_target, :user_position_and_target, :user_and_target_position,
           :user_position_and_target_position
        user_pos = @user_coords
        target_pos = @target_coords[first_target_index]
        distance = GameData::Animation::USER_AND_TARGET_SEPARATION
        new_pos_x -= user_pos[0]
        new_pos_x *= distance[0]
        new_pos_x /= target_pos[0] - user_pos[0]
      when :user_side_foreground, :user_side_background
        base_coords = Battle::Scene.pbBattlerPosition(user_index)
        new_pos_x -= base_coords[0]
      when :target_side_foreground, :target_side_background
        base_coords = Battle::Scene.pbBattlerPosition(first_target_index)
        new_pos_x -= base_coords[0]
      end
      relative_to_index = -1
      if !GameData::Animation::FOCUS_TYPES_WITH_USER_AND_TARGET.include?(particle[:focus])
        if GameData::Animation::FOCUS_TYPES_WITH_USER.include?(particle[:focus])
          relative_to_index = user_index
        elsif GameData::Animation::FOCUS_TYPES_WITH_TARGET.include?(particle[:focus])
          relative_to_index = first_target_index
        end
      end
      new_pos_x *= -1 if relative_to_index >= 0 && relative_to_index.odd? && particle[:foe_invert_x]
      @changed_controls ||= {}
      property = ((particle[:emitter_type] || :none) == :none) ? :x : :emit_x
      @changed_controls[property] = new_pos_x
      @captured[0] = new_canvas_x
      sprite.x = new_canvas_x
      if spr2
        value = AnimationEditor::ParticleDataHelper.get_keyframe_particle_value(particle, :x2, @display_keyframe)
        spr2.x = sprite.x + value[0]
      end
    end
    # Check if moved vertically
    if @captured[1] != new_canvas_y
      new_pos_y = new_canvas_y
      case particle[:focus]
      when :foreground, :midground, :background
      when :user
        new_pos_y -= @user_coords[1]
      when :user_position
        base_coords = Battle::Scene.pbBattlerPosition(user_index, side_size(user_index))
        new_pos_y -= base_coords[1]
      when :target
        new_pos_y -= @target_coords[first_target_index][1]
      when :target_position
        base_coords = Battle::Scene.pbBattlerPosition(first_target_index, side_size(first_target_index))
        new_pos_y -= base_coords[1]
      when :user_and_target, :user_position_and_target, :user_and_target_position,
           :user_position_and_target_position
        user_pos = @user_coords
        if [:user_position_and_target, :user_position_and_target_position].include?(particle[:focus])
          user_pos = [0, Battle::Scene.pbBattlerPosition(user_index, side_size(user_index))[1]]
        end
        target_pos = @target_coords[first_target_index]
        if [:user_and_target_position, :user_position_and_target_position].include?(particle[:focus])
          target_pos = [0, Battle::Scene.pbBattlerPosition(first_target_index, side_size(first_target_index))[1]]
        end
        distance = GameData::Animation::USER_AND_TARGET_SEPARATION
        new_pos_y -= user_pos[1]
        new_pos_y *= distance[1]
        new_pos_y /= target_pos[1] - user_pos[1]
      when :user_side_foreground, :user_side_background
        base_coords = Battle::Scene.pbBattlerPosition(user_index)
        new_pos_y -= base_coords[1]
      when :target_side_foreground, :target_side_background
        base_coords = Battle::Scene.pbBattlerPosition(first_target_index)
        new_pos_y -= base_coords[1]
      end
      relative_to_index = -1
      if !GameData::Animation::FOCUS_TYPES_WITH_USER_AND_TARGET.include?(particle[:focus])
        if GameData::Animation::FOCUS_TYPES_WITH_USER.include?(particle[:focus])
          relative_to_index = user_index
        elsif GameData::Animation::FOCUS_TYPES_WITH_TARGET.include?(particle[:focus])
          relative_to_index = first_target_index
        end
      end
      new_pos_y *= -1 if relative_to_index >= 0 && relative_to_index.odd? && particle[:foe_invert_y]
      @changed_controls ||= {}
      property = ((particle[:emitter_type] || :none) == :none) ? :y : :emit_y
      @changed_controls[property] = new_pos_y
      @captured[1] = new_canvas_y
      sprite.y = new_canvas_y
      if spr2
        value = AnimationEditor::ParticleDataHelper.get_keyframe_particle_value(particle, :y2, @display_keyframe)
        spr2.y = sprite.y + value[0]
      end
    end
  end

  def update_particle_rotated
    return if !rotating_particle?
    mouse_x, mouse_y = mouse_pos
    return if !mouse_x || !mouse_y
    return if @captured[0] == mouse_x && @captured[1] == mouse_y
    particle = @anim[:particles][@selected_particle]
    if GameData::Animation::FOCUS_TYPES_WITH_TARGET.include?(particle[:focus])
      sprite, frame = get_sprite_and_frame(@selected_particle, first_target_index)
    else
      sprite, frame = get_sprite_and_frame(@selected_particle)
    end
    spr2 = get_second_sprite(@selected_particle, first_target_index)
    # Calculate angle between mouse's original position and its current position
    init_x = @captured[0] - frame.x
    init_y = @captured[1] - frame.y
    now_x = mouse_x - frame.x
    now_y = mouse_y - frame.y
    init_angle = Math.atan2(init_y, init_x)
    now_angle = Math.atan2(now_y, now_x)
    # Apply new angle
    angle = @captured[2] + ((init_angle - now_angle) * 180 / Math::PI)
    @changed_controls ||= {}
    @changed_controls[:angle] = angle
    sprite.angle = angle
    if spr2
      value = AnimationEditor::ParticleDataHelper.get_keyframe_particle_value(particle, :angle2, @display_keyframe)
      spr2.angle = sprite.angle + value[0]
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
      if target && target.compact.length > 1
        target = target[first_target_index][0]
      elsif target
        target = target.compact[0][0]
      end
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
      # Offset battler frames because their x/y is where their feet are rather
      # than the middle of their graphic
      @sel_frame_sprite.x += (target.bitmap.width / 2) - target.ox
      @sel_frame_sprite.y += (target.bitmap.height / 2) - target.oy
    end
  end

  def update
    update_input
    update_particle_moved
    update_particle_rotated
    update_selected_particle_frame
  end
end
