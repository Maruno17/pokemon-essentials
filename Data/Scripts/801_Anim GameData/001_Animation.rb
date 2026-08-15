module GameData
  class Animation
    attr_reader :type         # :move, :opp_move, :common, :opp_common
    attr_reader :move         # Either the move's ID or the common animation's name (both are strings)
    attr_reader :version      # Hit number
    attr_reader :name         # Shown in the sublist; cosmetic only
    attr_reader :no_user      # Whether there is no "User" particle (false by default)
    attr_reader :no_target    # Whether there is no "Target" particle (false by default)
    attr_reader :ignore       # Whether the animation can't be played in battle
    attr_reader :hides_data_boxes
    attr_reader :fps          # Frames per second, 20 by default
    attr_reader :scripts
    attr_reader :credit
    attr_reader :flags
    attr_reader :pbs_path     # Whole path minus "PBS/Animations/" at start and ".txt" at end
    attr_reader :particles

    DATA = {}
    DATA_FILENAME = "animations.dat"
    OPTIONAL = true

    # NOTE: All mentions of focus types can be found by searching for
    #       :user_and_target, plus there's :foreground in PARTICLE_DEFAULT_VALUES
    #       below.
    FOCUS_TYPES = {
      "Foreground"                    => :foreground,
      "Midground"                     => :midground,
      "Background"                    => :background,
      "User"                          => :user,
      "UserPosition"                  => :user_position,
      "Target"                        => :target,
      "TargetPosition"                => :target_position,
      "UserAndTarget"                 => :user_and_target,
      "UserPositionAndTarget"         => :user_position_and_target,
      "UserAndTargetPosition"         => :user_and_target_position,
      "UserPositionAndTargetPosition" => :user_position_and_target_position,
      "UserSideForeground"            => :user_side_foreground,
      "UserSideBackground"            => :user_side_background,
      "TargetSideForeground"          => :target_side_foreground,
      "TargetSideBackground"          => :target_side_background
    }
    FOCUS_TYPES_WITH_USER = [
      :user, :user_position, :user_and_target, :user_position_and_target,
      :user_and_target_position, :user_position_and_target_position,
      :user_side_foreground, :user_side_background
    ]
    FOCUS_TYPES_WITH_TARGET = [
      :target, :target_position, :user_and_target, :user_position_and_target,
      :user_and_target_position, :user_position_and_target_position,
      :target_side_foreground, :target_side_background
    ]
    FOCUS_TYPES_WITH_USER_AND_TARGET = [
      :user_and_target, :user_position_and_target, :user_and_target_position,
      :user_position_and_target_position
    ]
    INTERPOLATION_TYPES = {
      "None"     => :none,
      "Linear"   => :linear,
      "EaseIn"   => :ease_in,
      "EaseOut"  => :ease_out,
      "EaseBoth" => :ease_both
    }
    USER_AND_TARGET_SEPARATION = [200, -200, -100]   # x, y, z (from user to target)
    EMITTER_TYPES = {
      "None"       => :none,          # Isn't an emitter
      "NoMovement" => :no_movement,   # Doesn't move once spawned
      "Straight"   => :straight,      # Moves in a straight line
      "Projectile" => :projectile,    # Moved under gravity
      "Helix"      => :helix,         # Sine movement in x, straight movement in y
      "Polar"      => :polar          # Sine movement in x/y
    }
    ANGLE_OVERRIDES = {
      "None"                       => :none,
      "InitialAngleToFocus"        => :initial_angle_to_focus,
      "InitialEmitterAngleToFocus" => :initial_emitter_angle_to_focus,
      "AlwaysPointAtFocus"         => :always_point_at_focus,
      "EmittedDirection"           => :emitted_direction
    }
    # NOTE: These are all the same properties as the base layer, minus :visible.
    #       * :frame2, :blending2, :color2 and :tone2 are standalone and are not
    #         affected by changes to the base layer.
    #       * :x2, :y2, :z2, :zoom_x2, :zoom_y2, :angle2, :opacity2 are all
    #         offsets relative to those properties of the base layer.
    SECOND_LAYER_PROPERTIES = [:x2, :y2, :z2, :zoom_x2, :zoom_y2, :angle2,
                               :flip2, :opacity2, :color2, :tone2,
                               :invert_color2, :frame2, :blending2]

    # Properties that apply to the animation in general, not to individual
    # particles. They don't change during the animation.
    SCHEMA = {
      "SectionName"    => [:id,               "esU", {"Move" => :move, "OppMove" => :opp_move,
                                                      "Common" => :common, "OppCommon" => :opp_common}],
      "Name"           => [:name,             "s"],
      "NoUser"         => [:no_user,          "b"],
      "NoTarget"       => [:no_target,        "b"],
      "Ignore"         => [:ignore,           "b"],
      "HidesDataBoxes" => [:hides_data_boxes, "b"],
      "FPS"            => [:fps,              "v"],
      "Scripts"        => [:scripts,          "*s"],
      "Credit"         => [:credit,           "s"],
      "Particle"       => [:particles,        "s"]   # Is a subheader line like <text>
    }
    # For individual particles. Any property whose schema begins with "^" can
    # change during the animation.
    SUB_SCHEMA = {
      # These properties cannot be changed partway through the animation.
      # NOTE: "Name" isn't a property here, because the particle's name comes
      #       from the "Particle" property above.
      "Focus"                           => [:focus,                              "e", FOCUS_TYPES],
      "PolarCoordinates"                => [:polar_coordinates,                  "b"],
      "Graphic"                         => [:graphic,                            "s"],
      "MaskGraphic"                     => [:mask_graphic,                       "s"],
      "TiledGraphic"                    => [:tiled_graphic,                      "b"],
      "SecondLayer"                     => [:second_layer,                       "b"],
      "FoeInvertX"                      => [:foe_invert_x,                       "b"],
      "FoeInvertY"                      => [:foe_invert_y,                       "b"],
      "FoeInvertZ"                      => [:foe_invert_z,                       "b"],
      "FoeFlip"                         => [:foe_flip,                           "b"],
      "AngleOverride"                   => [:angle_override,                     "e", ANGLE_OVERRIDES],
      "RandomAngleRange"                => [:random_angle_range,                 "u"],
      "RandomInvertAngle"               => [:random_invert_angle,                "b"],
      "RandomInvertFlip"                => [:random_invert_flip,                 "b"],
      "RandomFrameMax"                  => [:random_frame_max,                   "u"],
      "Emitter"                         => [:emitter_type,                       "e", EMITTER_TYPES],
      "EmitterRate"                     => [:emitter_rate,                       "v"],   # Emissions/second
      "EmitterIntensity"                => [:emitter_intensity,                  "v"],   # Sprites/emission
      "EmitterPositionPolarCoordinates" => [:emitter_position_polar_coordinates, "b"],
      "EmitterSpawnPolarCoordinates"    => [:emitter_spawn_polar_coordinates,    "b"],
      # All properties below are "SetXYZ" or "MoveXYZ". "SetXYZ" has the
      # keyframe and the value, and "MoveXYZ" has the keyframe, duration and the
      # value. All have "^" in their schema. "SetXYZ" is turned into "MoveXYZ"
      # when compiling by inserting a duration (second value) of 0.
      "SetX"           => [:x,            "^ui"],
      "MoveX"          => [:x,            "^uuiE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetY"           => [:y,            "^ui"],
      "MoveY"          => [:y,            "^uuiE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetR"           => [:r,            "^uu"],
      "MoveR"          => [:r,            "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetTheta"       => [:theta,        "^ui"],
      "MoveTheta"      => [:theta,        "^uuiE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetZ"           => [:z,            "^ui"],
      "MoveZ"          => [:z,            "^uuiE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetZoomX"       => [:zoom_x,       "^uu"],
      "MoveZoomX"      => [:zoom_x,       "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetZoomY"       => [:zoom_y,       "^uu"],
      "MoveZoomY"      => [:zoom_y,       "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetAngle"       => [:angle,        "^ui"],
      "MoveAngle"      => [:angle,        "^uuiE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetFlip"        => [:flip,         "^ub"],
      "SetVisible"     => [:visible,      "^ub"],
      "SetOpacity"     => [:opacity,      "^uu"],
      "MoveOpacity"    => [:opacity,      "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetColor"       => [:color,        "^us"],
      "MoveColor"      => [:color,        "^uusE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetTone"        => [:tone,         "^us"],
      "MoveTone"       => [:tone,         "^uusE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetInvertColor" => [:invert_color, "^ub"],
      "SetFrame"       => [:frame,        "^uu"],   # Frame within the graphic if it's a spritesheet
      "MoveFrame"      => [:frame,        "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetBlending"    => [:blending,     "^uu"],   # 0, 1 or 2
      # These properties are for the bitmap mask of a particle.
      "SetMaskOpacity"  => [:mask_opacity,  "^uu"],
      "MoveMaskOpacity" => [:mask_opacity,  "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetMaskX"        => [:mask_x,        "^ui"],
      "MoveMaskX"       => [:mask_x,        "^uuiE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetMaskY"        => [:mask_y,        "^ui"],
      "MoveMaskY"       => [:mask_y,        "^uuiE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetMaskZoomX"    => [:mask_zoom_x,   "^uu"],
      "MoveMaskZoomX"   => [:mask_zoom_x,   "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetMaskZoomY"    => [:mask_zoom_y,   "^uu"],
      "MoveMaskZoomY"   => [:mask_zoom_y,   "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetMaskBlending" => [:mask_blending, "^uu"],   # 0, 1 or 2
      # These properties are for the second layer of a particle. It has all the
      # same properties as the base layer, except for :visible.
      "SetX2"           => [:x2,            "^ui"],
      "MoveX2"          => [:x2,            "^uuiE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetY2"           => [:y2,            "^ui"],
      "MoveY2"          => [:y2,            "^uuiE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetZ2"           => [:z2,            "^ui"],
      "MoveZ2"          => [:z2,            "^uuiE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetZoomX2"       => [:zoom_x2,       "^uu"],
      "MoveZoomX2"      => [:zoom_x2,       "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetZoomY2"       => [:zoom_y2,       "^uu"],
      "MoveZoomY2"      => [:zoom_y2,       "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetAngle2"       => [:angle2,        "^ui"],
      "MoveAngle2"      => [:angle2,        "^uuiE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetFlip2"        => [:flip2,         "^ub"],
      "SetOpacity2"     => [:opacity2,      "^ui"],
      "MoveOpacity2"    => [:opacity2,      "^uuiE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetColor2"       => [:color2,        "^us"],
      "MoveColor2"      => [:color2,        "^uusE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetTone2"        => [:tone2,         "^us"],
      "MoveTone2"       => [:tone2,         "^uusE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetInvertColor2" => [:invert_color2, "^ub"],
      "SetFrame2"       => [:frame2,        "^uu"],   # Frame within the graphic if it's a spritesheet
      "MoveFrame2"      => [:frame2,        "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetBlending2"    => [:blending2,     "^uu"],   # 0, 1 or 2
      # These properties are specifically for emitter particles.
      # Location of emitter and whether it is emitting.
      "SetEmitterX"      => [:emitter_x,     "^ui"],
      "MoveEmitterX"     => [:emitter_x,     "^uuiE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetEmitterY"      => [:emitter_y,     "^ui"],
      "MoveEmitterY"     => [:emitter_y,     "^uuiE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetEmitterR"      => [:emitter_r,     "^uu"],
      "MoveEmitterR"     => [:emitter_r,     "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetEmitterTheta"  => [:emitter_theta, "^ui"],
      "MoveEmitterTheta" => [:emitter_theta, "^uuiE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetEmitting"      => [:emitting,      "^ub"],
      # Spawn area of emitted particles.
      "SetSpawnX"           => [:spawn_x,           "^uu"],
      "MoveSpawnX"          => [:spawn_x,           "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetSpawnXRange"      => [:spawn_x_range,     "^uu"],
      "MoveSpawnXRange"     => [:spawn_x_range,     "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetSpawnY"           => [:spawn_y,           "^uu"],
      "MoveSpawnY"          => [:spawn_y,           "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetSpawnYRange"      => [:spawn_y_range,     "^uu"],
      "MoveSpawnYRange"     => [:spawn_y_range,     "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetSpawnR"           => [:spawn_r,           "^uu"],
      "MoveSpawnR"          => [:spawn_r,           "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetSpawnRRange"      => [:spawn_r_range,     "^uu"],
      "MoveSpawnRRange"     => [:spawn_r_range,     "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetSpawnTheta"       => [:spawn_theta,       "^uu"],
      "MoveSpawnTheta"      => [:spawn_theta,       "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetSpawnThetaRange"  => [:spawn_theta_range, "^uu"],
      "MoveSpawnThetaRange" => [:spawn_theta_range, "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      # Automated movement of emitted particles.
      "SetEmitSpeed"           => [:emit_speed,           "^ui"],
      "MoveEmitSpeed"          => [:emit_speed,           "^uuiE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetEmitSpeedRange"      => [:emit_speed_range,     "^uu"],
      "MoveEmitSpeedRange"     => [:emit_speed_range,     "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetEmitDirection"       => [:emit_direction,       "^ui"],
      "MoveEmitDirection"      => [:emit_direction,       "^uuiE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetEmitDirectionRange"  => [:emit_direction_range, "^uu"],
      "MoveEmitDirectionRange" => [:emit_direction_range, "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetEmitGravity"         => [:emit_gravity,         "^ui"],
      "MoveEmitGravity"        => [:emit_gravity,         "^uuiE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetEmitGravityRange"    => [:emit_gravity_range,   "^uu"],
      "MoveEmitGravityRange"   => [:emit_gravity_range,   "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetEmitPeriodX"         => [:emit_period_x,        "^uu"],   # NOTE: Actually time for 100 periods.
      "MoveEmitPeriodX"        => [:emit_period_x,        "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetEmitPeriodXRange"    => [:emit_period_x_range,  "^uu"],
      "MoveEmitPeriodXRange"   => [:emit_period_x_range,  "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetEmitPeriodY"         => [:emit_period_y,        "^uu"],   # NOTE: Actually time for 100 periods.
      "MoveEmitPeriodY"        => [:emit_period_y,        "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetEmitPeriodYRange"    => [:emit_period_y_range,  "^uu"],
      "MoveEmitPeriodYRange"   => [:emit_period_y_range,  "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetEmitPeriodZ"         => [:emit_period_z,        "^uv"],   # NOTE: Actually time for 100 periods.
      "MoveEmitPeriodZ"        => [:emit_period_z,        "^uuvE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetEmitPeriodZRange"    => [:emit_period_z_range,  "^uu"],
      "MoveEmitPeriodZRange"   => [:emit_period_z_range,  "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetEmitClockwise"       => [:emit_clockwise,       "^ub"],
      # Property modifiers for emitted particles.
      "SetEmitXMultiplier"        => [:emit_x_multiplier,       "^uu"],
      "MoveEmitXMultiplier"       => [:emit_x_multiplier,       "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetEmitYMultiplier"        => [:emit_y_multiplier,       "^uu"],
      "MoveEmitYMultiplier"       => [:emit_y_multiplier,       "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetEmitRadiusXRange"       => [:emit_radius_x_range,     "^uu"],
      "MoveEmitRadiusXRange"      => [:emit_radius_x_range,     "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetEmitRadiusYRange"       => [:emit_radius_y_range,     "^uu"],
      "MoveEmitRadiusYRange"      => [:emit_radius_y_range,     "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetEmitRadiusZRange"       => [:emit_radius_z_range,     "^uu"],
      "MoveEmitRadiusZRange"      => [:emit_radius_z_range,     "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetEmitZoomRange"          => [:emit_zoom_range,         "^uu"],
      "MoveEmitZoomRange"         => [:emit_zoom_range,         "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetEmitZoomMultiplier"     => [:emit_zoom_multiplier,    "^uu"],
      "MoveEmitZoomMultiplier"    => [:emit_zoom_multiplier,    "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetEmitZoomXRange"         => [:emit_zoom_x_range,       "^uu"],
      "MoveEmitZoomXRange"        => [:emit_zoom_x_range,       "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetEmitZoomYRange"         => [:emit_zoom_y_range,       "^uu"],
      "MoveEmitZoomYRange"        => [:emit_zoom_y_range,       "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetEmitOpacityMultiplier"  => [:emit_opacity_multiplier, "^uu"],
      "MoveEmitOpacityMultiplier" => [:emit_opacity_multiplier, "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      # Extra particle properties for emitted particles. (Radii used by :helix/
      # :polar emitter types.)
      "SetSpawnXOffset"      => [:spawn_x_offset,     "^uu"],
      "MoveSpawnXOffset"     => [:spawn_x_offset,     "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetSpawnXMultiplier"  => [:spawn_x_multiplier, "^uu"],
      "MoveSpawnXMultiplier" => [:spawn_x_multiplier, "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetSpawnYOffset"      => [:spawn_y_offset,     "^uu"],
      "MoveSpawnYOffset"     => [:spawn_y_offset,     "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetSpawnYMultiplier"  => [:spawn_y_multiplier, "^uu"],
      "MoveSpawnYMultiplier" => [:spawn_y_multiplier, "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetSpawnROffset"      => [:spawn_r_offset,     "^uu"],
      "MoveSpawnROffset"     => [:spawn_r_offset,     "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetSpawnRMultiplier"  => [:spawn_r_multiplier, "^uu"],
      "MoveSpawnRMultiplier" => [:spawn_r_multiplier, "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetSpawnThetaOffset"  => [:spawn_theta_offset, "^uu"],
      "MoveSpawnThetaOffset" => [:spawn_theta_offset, "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetRadiusX"           => [:radius_x,           "^uu"],
      "MoveRadiusX"          => [:radius_x,           "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetRadiusY"           => [:radius_y,           "^uu"],
      "MoveRadiusY"          => [:radius_y,           "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetRadiusZ"           => [:radius_z,           "^uu"],
      "MoveRadiusZ"          => [:radius_z,           "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      # These properties are specifically for the "SE" particle.
      "Play"          => [:se,         "^usUU"],   # Filename, volume, pitch
      "PlayUserCry"   => [:user_cry,   "^uUU"],   # Volume, pitch
      "PlayTargetCry" => [:target_cry, "^uUU"]   # Volume, pitch
    }
    PARTICLE_DEFAULT_VALUES = {
      :name                               => "",
      :focus                              => :foreground,
      :polar_coordinates                  => false,
      :graphic                            => "",
      :mask_graphic                       => "",
      :tiled_graphic                      => false,
      :second_layer                       => false,
      :foe_invert_x                       => false,
      :foe_invert_y                       => false,
      :foe_invert_z                       => false,
      :foe_flip                           => false,
      :angle_override                     => :none,
      :random_angle_range                 => 0,
      :random_invert_angle                => false,
      :random_invert_flip                 => false,
      :random_frame_max                   => 0,
      :emitter_type                       => :none,
      :emitter_rate                       => 1,
      :emitter_intensity                  => 1,
      :emitter_position_polar_coordinates => false,
      :emitter_spawn_polar_coordinates    => false
    }
    # NOTE: Particles are invisible until their first command, and automatically
    #       become visible then. "User" and "Target" are visible from the start,
    #       though.
    PARTICLE_KEYFRAME_DEFAULT_VALUES = {
      :x                       => 0,
      :y                       => 0,
      :r                       => 0,
      :theta                   => 0,
      :z                       => 0,
      :zoom_x                  => 100,
      :zoom_y                  => 100,
      :angle                   => 0,
      :flip                    => false,
      :visible                 => false,
      :opacity                 => 255,
      :color                   => "00000000",
      :tone                    => "+00+00+00+00",
      :invert_color            => false,
      :frame                   => 0,
      :blending                => 0,
      # These properties are for the bitmap mask of a particle.
      :mask_opacity            => 0,
      :mask_x                  => 0,
      :mask_y                  => 0,
      :mask_zoom_x             => 100,
      :mask_zoom_y             => 100,
      :mask_blending           => 0,
      # These properties are for the second layer of a particle. It has all the
      # same properties as the base layer, except for :visible.
      :x2                      => 0,
      :y2                      => 0,
      :z2                      => 0,
      :zoom_x2                 => 100,
      :zoom_y2                 => 100,
      :angle2                  => 0,
      :flip2                   => false,
      :opacity2                => 0,
      :color2                  => "00000000",
      :tone2                   => "+00+00+00+00",
      :invert_color2           => false,
      :frame2                  => 0,
      :blending2               => 0,
      # These properties are specifically for emitter particles.
      # Location of emitter and whether it is emitting.
      :emitter_x               => 0,
      :emitter_y               => 0,
      :emitter_r               => 0,
      :emitter_theta           => 0,
      :emitting                => false,
      # Spawn area of emitted particles.
      :spawn_x                 => 0,
      :spawn_x_range           => 0,
      :spawn_y                 => 0,
      :spawn_y_range           => 0,
      :spawn_r                 => 0,
      :spawn_r_range           => 0,
      :spawn_theta             => 0,
      :spawn_theta_range       => 0,
      # Automated movement of emitted particles.
      :emit_speed              => 0,
      :emit_speed_range        => 0,
      :emit_direction          => 0,
      :emit_direction_range    => 0,
      :emit_gravity            => 0,
      :emit_gravity_range      => 0,
      :emit_period_x           => 100,
      :emit_period_x_range     => 0,
      :emit_period_y           => 100,
      :emit_period_y_range     => 0,
      :emit_period_z           => 100,
      :emit_period_z_range     => 0,
      :emit_clockwise          => false,
      # Property modifiers for emitted particles.
      :emit_x_multiplier       => 100,
      :emit_y_multiplier       => 100,
      :emit_radius_x_range     => 0,
      :emit_radius_y_range     => 0,
      :emit_radius_z_range     => 0,
      :emit_zoom_range         => 0,
      :emit_zoom_multiplier    => 100,
      :emit_zoom_x_range       => 0,
      :emit_zoom_y_range       => 0,
      :emit_opacity_multiplier => 100,
      # Extra particle properties for emitted particles. (Used by :helix/:polar
      # emitter types.)
      :spawn_x_offset          => 0,
      :spawn_x_multiplier      => 100,
      :spawn_y_offset          => 0,
      :spawn_y_multiplier      => 100,
      :spawn_r_offset          => 0,
      :spawn_r_multiplier      => 100,
      :spawn_theta_offset      => 0,
      :radius_x                => 0,
      :radius_y                => 0,
      :radius_z                => 0,
      # These properties are specifically for the "SE" particle.
      :se                      => nil,
      :user_cry                => nil,
      :target_cry              => nil
    }

    def self.property_display_name(property)
      return {
        :x                       => _INTL("X"),
        :y                       => _INTL("Y"),
        :r                       => _INTL("R"),
        :theta                   => _INTL("θ"),
        :z                       => _INTL("Priority"),
        :zoom_x                  => _INTL("Zoom X"),
        :zoom_y                  => _INTL("Zoom Y"),
        :angle                   => _INTL("Angle"),
        :flip                    => _INTL("Flip"),
        :visible                 => _INTL("Visible"),
        :opacity                 => _INTL("Opacity"),
        :color                   => _INTL("Color"),
        :tone                    => _INTL("Tone"),
        :invert_color            => _INTL("Invert color"),
        :frame                   => _INTL("Frame"),
        :blending                => _INTL("Blending"),
        # These properties are for the bitmap mask of a particle.
        :mask_opacity            => _INTL("Opacity"),
        :mask_x                  => _INTL("X"),
        :mask_y                  => _INTL("Y"),
        :mask_zoom_x             => _INTL("Zoom X"),
        :mask_zoom_y             => _INTL("Zoom Y"),
        :mask_blending           => _INTL("Blending"),
        # These properties are for the second layer of a particle. It has all
        # the same properties as the base layer, except for :visible.
        :x2                      => _INTL("X ±"),
        :y2                      => _INTL("Y ±"),
        :z2                      => _INTL("Priority ±"),
        :zoom_x2                 => _INTL("Zoom X ×%"),
        :zoom_y2                 => _INTL("Zoom Y ×%"),
        :angle2                  => _INTL("Angle ±"),
        :flip2                   => _INTL("Flip"),
        :opacity2                => _INTL("Opacity ±"),
        :color2                  => _INTL("Color"),
        :tone2                   => _INTL("Tone"),
        :invert_color2           => _INTL("Invert color"),
        :frame2                  => _INTL("Frame"),
        :blending2               => _INTL("Blending"),
        # These properties are specifically for emitter particles
        # Location of emitter and whether it is emitting.
        :emitter_x               => _INTL("Emitter X"),
        :emitter_y               => _INTL("Emitter Y"),
        :emitter_r               => _INTL("Emitter R"),
        :emitter_theta           => _INTL("Emitter θ"),
        :emitting                => _INTL("Emitting"),
        # Spawn area of emitted particles.
        :spawn_x                 => _INTL("Spawn X"),
        :spawn_x_range           => _INTL("Spawn X ±"),
        :spawn_y                 => _INTL("Spawn Y"),
        :spawn_y_range           => _INTL("Spawn Y ±"),
        :spawn_r                 => _INTL("Spawn R"),
        :spawn_r_range           => _INTL("Spawn R ±"),
        :spawn_theta             => _INTL("Spawn θ"),
        :spawn_theta_range       => _INTL("Spawn θ ±"),
        # Automated movement of emitted particles.
        :emit_speed              => _INTL("Speed"),
        :emit_speed_range        => _INTL("Speed ±"),
        :emit_direction          => _INTL("Direction"),
        :emit_direction_range    => _INTL("Direction ±"),
        :emit_gravity            => _INTL("Gravity"),
        :emit_gravity_range      => _INTL("Gravity ±"),
        :emit_period_x           => _INTL("Period X"),
        :emit_period_x_range     => _INTL("Period X ±"),
        :emit_period_y           => _INTL("Period Y"),
        :emit_period_y_range     => _INTL("Period Y ±"),
        :emit_period_z           => _INTL("Period Z"),
        :emit_period_z_range     => _INTL("Period Z ±"),
        :emit_clockwise          => _INTL("Clockwise"),
        # Property modifiers for emitted particles.
        :emit_x_multiplier       => _INTL("X ×%"),
        :emit_y_multiplier       => _INTL("Y ×%"),
        :emit_radius_x_range     => _INTL("Rad. X ±%"),
        :emit_radius_y_range     => _INTL("Rad. Y ±%"),
        :emit_radius_z_range     => _INTL("Rad. Z ±%"),
        :emit_zoom_range         => _INTL("Zoom ±%"),
        :emit_zoom_multiplier    => _INTL("Zoom ×%"),
        :emit_zoom_x_range       => _INTL("Zoom X ±%"),
        :emit_zoom_y_range       => _INTL("Zoom Y ±%"),
        :emit_opacity_multiplier => _INTL("Opacity ×%"),
        # Extra particle properties for emitted particles. (Used by :helix/:polar
        # emitter types.)
        :spawn_x_offset          => _INTL("Spawn X ±"),
        :spawn_x_multiplier      => _INTL("Spawn X ×%"),
        :spawn_y_offset          => _INTL("Spawn Y ±"),
        :spawn_y_multiplier      => _INTL("Spawn Y ×%"),
        :spawn_r_offset          => _INTL("Spawn R ±"),
        :spawn_r_multiplier      => _INTL("Spawn R ×%"),
        :spawn_theta_offset      => _INTL("Spawn θ ±"),
        :radius_x                => _INTL("Radius X"),
        :radius_y                => _INTL("Radius Y"),
        :radius_z                => _INTL("Radius Z")
      }[property] || property.to_s.capitalize
    end

    def self.property_can_interpolate?(property)
      return false if !property
      SUB_SCHEMA.each_value do |prop|
        return true if prop[0] == property && prop[5] && prop[5] == INTERPOLATION_TYPES
      end
      return false
    end

    @@cmd_to_pbs_name = nil   # Used for writing animation PBS files

    extend ClassMethodsIDNumbers
    include InstanceMethods

    singleton_class.alias_method(:__new_anim__load, :load) unless singleton_class.method_defined?(:__new_anim__load)
    def self.load
      __new_anim__load if FileTest.exist?("Data/#{self::DATA_FILENAME}")
    end

    def self.sub_schema
      return SUB_SCHEMA
    end

    def self.register(hash, id_num = -1)
      DATA[(id_num >= 0) ? id_num : DATA.keys.length] = self.new(hash)
    end

    def self.new_hash(anim_type = 0, move = nil)
      ret = {}
      ret[:type]             = (anim_type == 0) ? :move : :common
      ret[:move]             = (anim_type == 0) ? "STRUGGLE" : "Shiny"
      ret[:move]             = move if !move.nil?
      ret[:version]          = 0
      ret[:name]             = _INTL("New animation")
      ret[:no_user]          = false
      ret[:no_target]        = false
      ret[:ignore]           = false
      ret[:hides_data_boxes] = false
      ret[:fps]              = 20
      ret[:scripts]          = []
      ret[:credit]           = "Anon"
      ret[:particles]        = [
        {:name => "User", :focus => :user, :graphic => "USER"},
        {:name => "Target", :focus => :target, :graphic => "TARGET"},
        {:name => "SE"}
      ]
      ret[:flags]            = []
      ret[:pbs_path]         = "New animation"
      return ret
    end

    def initialize(hash)
      # NOTE: hash has an :id entry, but it's unused here.
      @type             = hash[:type]
      @move             = hash[:move]
      @version          = hash[:version]          || 0
      @name             = hash[:name]
      @no_user          = hash[:no_user]          || false
      @no_target        = hash[:no_target]        || false
      @ignore           = hash[:ignore]           || false
      @hides_data_boxes = hash[:hides_data_boxes] || false
      @fps              = hash[:fps]              || 20
      @scripts          = hash[:scripts]          || []
      @credit           = hash[:credit]           || "Anon"
      @particles        = hash[:particles]        || []
      @flags            = hash[:flags]            || []
      @pbs_path         = hash[:pbs_path]         || @move
    end

    # Returns a clone of the animation in a hash format, the same as created by
    # the Compiler. This hash can be passed into self.register.
    def clone_as_hash
      ret = {}
      ret[:type] = @type
      ret[:move] = @move
      ret[:version] = @version
      ret[:name] = @name
      ret[:no_user] = @no_user
      ret[:no_target] = @no_target
      ret[:ignore] = @ignore
      ret[:hides_data_boxes] = @hides_data_boxes
      ret[:fps] = @fps
      ret[:scripts] = @scripts.clone
      ret[:credit] = @credit
      ret[:particles] = []   # Clone the @particles array, which is nested hashes and arrays
      @particles.each do |particle|
        new_p = {}
        particle.each_pair do |key, val|
          if val.is_a?(Array)
            new_p[key] = []
            val.each { |cmd| new_p[key].push(cmd.clone) }
          else
            new_p[key] = val
          end
        end
        ret[:particles].push(new_p)
      end
      ret[:flags] = @flags.clone
      ret[:pbs_path] = @pbs_path
      return ret
    end

    def inspect
      ret = super.chop + ": "
      case @type
      when :move       then ret += _INTL("[Move]")
      when :opp_move   then ret += _INTL("[Foe Move]")
      when :common     then ret += _INTL("[Common]")
      when :opp_common then ret += _INTL("[Foe Common]")
      else
        raise _INTL("Unknown animation type.")
      end
      case @type
      when :move, :opp_move
        move_data = GameData::Move.try_get(@move)
        move_name = (move_data) ? move_data.name : @move
        ret += " " + move_name
      when :common, :opp_common
        ret += " " + @move
      end
      ret += " (" + @version.to_s + ")" if @version > 0
      ret += " - " + @name if @name
      return ret
    end

    def move_animation?
      return [:move, :opp_move].include?(@type)
    end

    def common_animation?
      return [:common, :opp_common].include?(@type)
    end

    def opposing_animation?
      return [:opp_move, :opp_common].include?(@type)
    end

    alias __new_anim__get_property_for_PBS get_property_for_PBS unless method_defined?(:__new_anim__get_property_for_PBS)
    def get_property_for_PBS(key)
      ret = __new_anim__get_property_for_PBS(key)
      case key
      when "SectionName"
        ret = [@type, @move]
        ret.push(@version) if @version > 0
      when "FPS"
        ret = nil if ret == 20
      when "Credit"
        ret = "Anon" if !ret || ret == ""
      end
      return ret
    end

    def get_particle_property_for_PBS(key, index = 0)
      ret = nil
      ret = @particles[index][SUB_SCHEMA[key][0]] if SUB_SCHEMA[key]
      ret = nil if ret == false || (ret.is_a?(Array) && ret.length == 0) || ret == ""
      case key
      when "Focus", "Graphic", "SecondLayer"
        # The User and Target particles have hardcoded graphics/foci and can't
        # have a second layer, so they don't need writing to PBS
        ret = nil if ["User", "Target"].include?(@particles[index][:name])
      when "TiledGraphic"
        ret = nil if @particles[index][:second_layer]
        ret = nil if (@particles[index][:emitter_type] || :none) != :none
        ret = nil if FOCUS_TYPES_WITH_USER.include?(@particles[index][:focus]) ||
                     FOCUS_TYPES_WITH_TARGET.include?(@particles[index][:focus])
      when "AngleOverride"
        ret = nil if ret == :none
        if ret && ![:emitted_direction].include?(ret)
          ret = nil if !FOCUS_TYPES_WITH_USER.include?(@particles[index][:focus]) &&
                       !FOCUS_TYPES_WITH_TARGET.include?(@particles[index][:focus])
        end
      when "RandomAngleRange", "RandomFrameMax", "Emitter"
        ret = nil if ret == PARTICLE_DEFAULT_VALUES[SUB_SCHEMA[key][0]]
      when "EmitterRate", "EmitterIntensity"
        ret = nil if @particles[index][:emitter_type].nil? || @particles[index][:emitter_type] == :none
        ret = nil if ret == PARTICLE_DEFAULT_VALUES[SUB_SCHEMA[key][0]]
      when "AllCommands"
        # Get translations of all properties to their names as seen in PBS
        # animation files
        if !@@cmd_to_pbs_name
          @@cmd_to_pbs_name = {}
          SUB_SCHEMA.each_pair do |key, val|
            @@cmd_to_pbs_name[val[0]] ||= []
            @@cmd_to_pbs_name[val[0]].push([key, val[1].length])
          end
          # For each property translation, put "SetXYZ" before "MoveXYZ"
          @@cmd_to_pbs_name.each_value do |val|
            val.sort! { |a, b| a[1] <=> b[1] }
            val.map! { |a| a[0] }
          end
        end
        # Gather all commands into a single array
        ret = []
        @particles[index].each_pair do |key, val|
          next if !val.is_a?(Array)
          next if key.to_s[0, 4] == "mask" && (@particles[index][:mask_graphic] || "") == ""
          if (@particles[index][:emitter_type] || :none) == :none
            next if key.to_s[0, 4] == "emit"
            next if key.to_s[0, 5] == "spawn"
            next if key.to_s[0, 6] == "radius"
          end
          next if SECOND_LAYER_PROPERTIES.include?(key) && !@particles[index][:second_layer]
          next if @particles[index][:polar_coordinates] && [:x, :y].include?(key)
          next if !@particles[index][:polar_coordinates] && [:r, :theta].include?(key)
          next if @particles[index][:emitter_position_polar_coordinates] &&
                  [:emitter_x, :emitter_y].include?(key)
          next if !@particles[index][:emitter_position_polar_coordinates] &&
                  [:emitter_r, :emitter_theta].include?(key)
          next if @particles[index][:emitter_spawn_polar_coordinates] &&
                  [:spawn_x, :spawn_x_range, :spawn_y, :spawn_y_range,
                   :spawn_x_offset, :spawn_x_multiplier, :spawn_y_offset, :spawn_y_multiplier].include?(key)
          next if !@particles[index][:emitter_spawn_polar_coordinates] &&
                  [:spawn_r, :spawn_r_range, :spawn_theta, :spawn_theta_range,
                   :spawn_r_offset, :spawn_r_multiplier, :spawn_theta_offset].include?(key)
          val.each do |cmd|
            new_cmd = cmd.clone
            if @particles[index][:name] != "SE" && new_cmd[1] > 0
              new_cmd.pop if new_cmd.last == :linear   # This is the default
              ret.push([@@cmd_to_pbs_name[key][1]] + new_cmd)   # ["MoveXYZ", keyframe, duration, value, interpolation]
            else
              case key
              when :se
                new_cmd[4] = nil if new_cmd[4] == 100   # Pitch
                new_cmd[3] = nil if new_cmd[4].nil? && new_cmd[3] == 100   # Volume
              when :user_cry, :target_cry
                new_cmd[3] = nil if new_cmd[3] == 100   # Pitch
                new_cmd[2] = nil if new_cmd[3].nil? && new_cmd[2] == 100   # Volume
              end
              ret.push([@@cmd_to_pbs_name[key][0]] + new_cmd)   # ["SetXYZ", keyframe, duration, value]
            end
          end
        end
        # Sort the array of commands by keyframe order, then by duration, then
        # by the order they're defined in SUB_SCHEMA
        ret.sort! do |a, b|
          if a[1] == b[1]
            if a[2] == b[2]
              next SUB_SCHEMA.keys.index(a[0]) <=> SUB_SCHEMA.keys.index(b[0])
            else
              next a[2] <=> b[2]   # Sort by duration
            end
          else
            next a[1] <=> b[1]   # Sort by keyframe
          end
        end
      end
      return ret
    end
  end
end
