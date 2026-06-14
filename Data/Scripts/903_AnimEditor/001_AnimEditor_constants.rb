#===============================================================================
#
#===============================================================================
class AnimationEditor
  CONTAINER_BORDER = 3
  WINDOW_WIDTH     = Settings::SCREEN_WIDTH + (256 * 2) + (CONTAINER_BORDER * 6)   # 256 is MENU_BAR_WIDTH and BATCH_EDITS_WIDTH
  WINDOW_HEIGHT    = Settings::SCREEN_HEIGHT + 540 + (CONTAINER_BORDER * 4)   # 540 is arbitrary but large
  WINDOW_HEIGHT    = [WINDOW_HEIGHT, Graphics.display_height - 100].min   # 100 is ~ height of window title bar and taskbar
  WINDOW_HEIGHT    = [WINDOW_HEIGHT, Settings::SCREEN_HEIGHT + 150 + (CONTAINER_BORDER * 4)].max   # 150 is arbitrary; shows 4 particle rows

  # Minimum and maximum values the editor allows for certain properties. Only
  # properties that can be interpolated are here, and not :color or :tone
  # because those have string values.
  PROPERTY_RANGES = {   # Min, max
    :x                    => [-99999, 99999],
    :y                    => [-99999, 99999],
    :r                    => [     0, 99999],
    :theta                => [-99999, 99999],
    :z                    => [   -50,    50],
    :zoom_x               => [     0,  1000],
    :zoom_y               => [     0,  1000],
    :angle                => [-99999, 99999],
    :opacity              => [     0,   255],
    :frame                => [     0,    99],
    # These properties are for the bitmap mask of a particle.
    :mask_opacity         => [     0,   255],
    :mask_x               => [-99999, 99999],
    :mask_y               => [-99999, 99999],
    :mask_zoom_x          => [     0,  1000],
    :mask_zoom_y          => [     0,  1000],
    # These properties are for the second layer of a particle.
    :x2                   => [-99999, 99999],
    :y2                   => [-99999, 99999],
    :z2                   => [   -50,    50],
    :zoom_x2              => [     0,  1000],
    :zoom_y2              => [     0,  1000],
    :angle2               => [-99999, 99999],
    :opacity2             => [  -255,   255],
    :frame2               => [     0,    99],
    # These properties are specifically for emitter particles.
    :emit_x               => [-99999, 99999],
    :emit_x_range         => [     0, 99999],
    :emit_y               => [-99999, 99999],
    :emit_y_range         => [     0, 99999],
    :emit_r               => [     0, 99999],
    :emit_r_range         => [     0, 99999],
    :emit_theta           => [-99999, 99999],
    :emit_theta_range     => [     0,   180],
    :emit_speed           => [-99999, 99999],
    :emit_speed_range     => [     0,  9999],
    :emit_direction       => [-99999, 99999],
    :emit_direction_range => [     0,   180],
    :emit_gravity         => [-99999, 99999],
    :emit_gravity_range   => [     0,  9999],
    :emit_period_x        => [     0,  9999],
    :emit_period_x_range  => [     0,  9999],
    :emit_period_y        => [     0,  9999],
    :emit_period_y_range  => [     0,  9999],
    :emit_period_z        => [     0,  9999],
    :emit_period_z_range  => [     0,  9999],
    :emit_radius_x_range  => [     0,  9999],
    :emit_radius_y_range  => [     0,  9999],
    :emit_radius_z_range  => [     0,    50],
    :emit_zoom_multiplier => [     0,  9999],
    :emit_zoom_range      => [     0,  9999],
    :emit_zoom_x_range    => [     0,  9999],
    :emit_zoom_y_range    => [     0,  9999],
    :emit_opacity_multiplier => [     0,  9999],
    :radius_x             => [     0,  9999],
    :radius_y             => [     0,  9999],
    :radius_z             => [     0,    50]
  }

  #-----------------------------------------------------------------------------

  # This list of animations was gathered manually by looking at all instances of
  # pbCommonAnimation.
  COMMON_ANIMATIONS = [
    # Weather
    "Hail", "Rain", "Sandstorm", "ShadowSky", "Snowstorm", "Sun",
    "HarshSun", "HeavyRain", "StrongWinds",
    # Terrain
    "ElectricTerrain", "GrassyTerrain", "MistyTerrain", "PsychicTerrain",
    # HP and stats
    "HealthDown", "HealthUp",
    "CriticalHitRateUp", "StatDown", "StatUp",
    # Status conditions
    "Burn", "Frozen", "Paralysis", "Poison", "Sleep", "Toxic",
    "Attract", "Confusion",
    # Upon entering battle
    "HealingWish", "LunarDance", "Shadow", "Shiny", "SuperShiny",
    # Transformation
    "MegaEvolution", "MegaEvolution2",
    "PrimalGroudon", "PrimalGroudon2", "PrimalKyogre", "PrimalKyogre2",
    # Readying an attack
    "BeakBlast", "FocusPunch", "ShellTrap",
    # Protections
    "BanefulBunker", "BurningBulwark", "CraftyShield", "KingsShield",
    "Obstruct", "Protect", "QuickGuard", "SilkTrap", "SpikyShield", "WideGuard",
    # Pledge moves
    "Rainbow", "RainbowOpp", "SeaOfFire", "SeaOfFireOpp", "Swamp", "SwampOpp",
    # EOR
    "AquaRing", "Curse", "Ingrain", "LeechSeed", "Nightmare", "SaltCure",
    "Octolock", "SyrupBomb",
    # EOR trapping
    "Bind", "Clamp", "FireSpin", "Infestation", "MagmaStorm", "SandTomb", "Wrap",
    # Items
    "EatBerry", "UseItem",
    # Misc.
    "Commander",
    "LevelUp",
    "ParentalBond",
    "Powder"
  ]
end
