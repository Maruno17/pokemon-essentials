#===============================================================================
#
#===============================================================================
class UI::TrainerCardVisuals < UI::BaseUIVisuals
  GRAPHICS_FOLDER = "Graphics/UI/Trainer Card/"
  BADGE_SIZE      = [32, 32]   # [width, height] of a Gym Badge
  BADGE_SPACING   = 16         # Size of gap between adjacent Gym Badges
  FIRST_BADGE_X   = 72         # Left edge of the first Gym Badge
  FIRST_BADGE_Y   = 310        # Top edge of the first Gym Badge
  BADGE_COUNT     = 8          # Number of Gym Badges to show

  def initialize_sprites
    # Trainer card
    add_icon_sprite(:card, 0, 0, GRAPHICS_FOLDER + gendered_filename(_INTL("trainer_card")))
    # Player sprite (coordinates are the bottom middle of the sprite)
    add_icon_sprite(:player, 400, 240, GameData::TrainerType.player_front_sprite_filename($player.trainer_type))
    if !@sprites[:player].bitmap
      raise _INTL("No trainer front sprite exists for the player character, expected a file at {1}.",
                  "Graphics/Trainers/" + $player.trainer_type.to_s + ".png")
    end
    @sprites[:player].x -= @sprites[:player].bitmap.width / 2
    @sprites[:player].y -= @sprites[:player].bitmap.height
    @sprites[:player].z = 10
  end

  #-----------------------------------------------------------------------------

  def refresh_overlay
    super
    overlay = @sprites[:overlay].bitmap
    draw_ID(overlay)
    draw_stats(overlay)
    draw_badges(overlay)
  end

  # Draws the player's name and ID number onto the overlay.
  def draw_ID(overlay)
    pbDrawTextPositions(overlay, [
      [_INTL("Name"),                      34,  70, :left,  BLACK_TEXT_COLOR, BLACK_TEXT_SHADOW_COLOR],
      [$player.name,                       302, 70, :right, BLACK_TEXT_COLOR, BLACK_TEXT_SHADOW_COLOR],
      [_INTL("ID No."),                    332, 70, :left,  BLACK_TEXT_COLOR, BLACK_TEXT_SHADOW_COLOR],
      [sprintf("%05d", $player.public_ID), 468, 70, :right, BLACK_TEXT_COLOR, BLACK_TEXT_SHADOW_COLOR]
    ])
  end

  # Draws the player's money, Pokédex numbers, play time and start date onto the
  # overlay.
  def draw_stats(overlay)
    # Create money text
    money_text = _INTL("${1}", $player.money.to_s_formatted)
    # Create Pokédex stats text
    pokedex_text = sprintf("%d/%d", $player.pokedex.owned_count, $player.pokedex.seen_count)
    # Create play time text
    total_secs = $stats.play_time.to_i
    hour = (total_secs / 60) / 60
    min = (total_secs / 60) % 60
    play_time = (hour > 0) ? _INTL("{1}h {2}m", hour, min) : _INTL("{1}m", min)
    # Create start date text
    $PokemonGlobal.startTime = Time.now if !$PokemonGlobal.startTime
    # TODO: Put this date the proper way round for non-United States of Americans.
    start_date = _INTL("{1} {2}, {3}",
                       pbGetAbbrevMonthName($PokemonGlobal.startTime.mon),
                       $PokemonGlobal.startTime.day,
                       $PokemonGlobal.startTime.year)
    # Draw text
    pbDrawTextPositions(overlay, [
      [_INTL("Money"),   34,  118, :left,  BLACK_TEXT_COLOR, BLACK_TEXT_SHADOW_COLOR],
      [money_text,       302, 118, :right, BLACK_TEXT_COLOR, BLACK_TEXT_SHADOW_COLOR],
      [_INTL("Pokédex"), 34,  166, :left,  BLACK_TEXT_COLOR, BLACK_TEXT_SHADOW_COLOR],
      [pokedex_text,     302, 166, :right, BLACK_TEXT_COLOR, BLACK_TEXT_SHADOW_COLOR],
      [_INTL("Time"),    34,  214, :left,  BLACK_TEXT_COLOR, BLACK_TEXT_SHADOW_COLOR],
      [play_time,        302, 214, :right, BLACK_TEXT_COLOR, BLACK_TEXT_SHADOW_COLOR],
      [_INTL("Started"), 34,  262, :left,  BLACK_TEXT_COLOR, BLACK_TEXT_SHADOW_COLOR],
      [start_date,       302, 262, :right, BLACK_TEXT_COLOR, BLACK_TEXT_SHADOW_COLOR]
    ])
  end

  # Draws the player's owned Gym Badges onto the overlay.
  def draw_badges(overlay)
    x = FIRST_BADGE_X
    region = pbGetCurrentRegion(0)   # Get the current region
    BADGE_COUNT.times do |i|
      if $player.badges[i + (region * BADGE_COUNT)]
        pbDrawImagePositions(overlay, [
          [GRAPHICS_FOLDER + "icon_badges", x, FIRST_BADGE_Y, i * BADGE_SIZE[0], region * BADGE_SIZE[1], *BADGE_SIZE]
        ])
      end
      x += BADGE_SIZE[0] + BADGE_SPACING
    end
  end
end

#===============================================================================
#
#===============================================================================
class UI::TrainerCardScreen < UI::BaseUIScreen
  def initialize_visuals
    @visuals = UI::TrainerCardVisuals.new
  end

  def start_screen
    super
    pbSEPlay("GUI trainer card open")
  end

  def end_screen
    pbPlayCloseMenuSE
    super
  end
end

#===============================================================================
#
#===============================================================================
MenuHandlers.add(:pause_menu, :new_trainer_card, {
  "name"      => proc { next "New Trainer Card" },
  "order"     => 55,
  "effect"    => proc { |menu|
    pbPlayDecisionSE
    pbFadeOutIn do
      UI::TrainerCardScreen.new
      menu.pbRefresh
    end
    next false
  }
})
