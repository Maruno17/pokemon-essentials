#===============================================================================
# Stored in $stats
#===============================================================================
class GameStats
  # Travel
  attr_accessor :distance_walked, :distance_cycled, :distance_surfed   # surfed includes diving
  attr_accessor :distance_slid_on_ice   # Also counted in distance_walked
  attr_accessor :bump_count   # Times the player walked into something
  attr_accessor :cycle_count, :surf_count, :dive_count
  # Field actions
  attr_accessor :fly_count, :cut_count, :flash_count
  attr_accessor :rock_smash_count, :rock_smash_battles
  attr_accessor :headbutt_count, :headbutt_battles
  attr_accessor :strength_push_count   # Number of shoves, not the times Strength was used
  attr_accessor :waterfall_count, :waterfalls_descended
  # Items
  attr_accessor :repel_count
  attr_accessor :itemfinder_count
  attr_accessor :fishing_count, :fishing_battles
  attr_accessor :poke_radar_count, :poke_radar_longest_chain
  attr_accessor :berry_plants_picked, :max_yield_berry_plants
  attr_accessor :berries_planted
  # NPCs
  attr_accessor :poke_center_count
  attr_accessor :revived_fossil_count
  attr_accessor :lottery_prize_count   # Times won any prize at all
  # Pokémon
  attr_accessor :eggs_hatched
  attr_accessor :evolution_count, :evolutions_cancelled
  attr_accessor :trade_count
  attr_accessor :moves_taught_by_item, :moves_taught_by_tutor, :moves_taught_by_reminder
  attr_accessor :day_care_deposits, :day_care_levels_gained
  attr_accessor :pokerus_infections
  attr_accessor :shadow_pokemon_purified
  # Battles
  attr_accessor :wild_battles_won, :wild_battles_lost   # Lost includes fled from
  attr_accessor :trainer_battles_won, :trainer_battles_lost
  attr_accessor :total_exp_gained
  attr_accessor :battle_money_gained, :battle_money_lost
  attr_accessor :blacked_out_count
  attr_accessor :mega_evolution_count
  attr_accessor :failed_poke_ball_count
  # Currency
  attr_accessor :money_spent_at_marts
  attr_accessor :money_earned_at_marts
  attr_accessor :mart_items_bought, :premier_balls_earned
  attr_accessor :drinks_bought, :drinks_won   # From vending machines
  attr_accessor :coins_won, :coins_lost   # Not bought, not spent
  attr_accessor :battle_points_won, :battle_points_spent
  attr_accessor :soot_collected
  # Special stats
  attr_accessor :gym_leader_attempts   # An array of integers
  attr_accessor :times_to_get_badges   # An array of times in seconds
  attr_accessor :elite_four_attempts
  attr_accessor :hall_of_fame_entry_count   # See also Game Variable 13
  attr_accessor :time_to_enter_hall_of_fame   # In seconds
  attr_accessor :safari_pokemon_caught, :most_captures_per_safari_game
  attr_accessor :bug_contest_count, :bug_contest_wins
  # Play
  attr_writer   :play_time   # In seconds; the reader also updates the value
  attr_accessor :play_sessions
  attr_accessor :time_last_saved   # In seconds

  def initialize
    # Travel
    @distance_walked               = 0
    @distance_cycled               = 0
    @distance_surfed               = 0
    @distance_slid_on_ice          = 0
    @bump_count                    = 0
    @cycle_count                   = 0
    @surf_count                    = 0
    @dive_count                    = 0
    # Field actions
    @fly_count                     = 0
    @cut_count                     = 0
    @flash_count                   = 0
    @rock_smash_count              = 0
    @rock_smash_battles            = 0
    @headbutt_count                = 0
    @headbutt_battles              = 0
    @strength_push_count           = 0
    @waterfall_count               = 0
    @waterfalls_descended          = 0
    # Items
    @repel_count                   = 0
    @itemfinder_count              = 0
    @fishing_count                 = 0
    @fishing_battles               = 0
    @poke_radar_count              = 0
    @poke_radar_longest_chain      = 0
    @berry_plants_picked           = 0
    @max_yield_berry_plants        = 0
    @berries_planted               = 0
    # NPCs
    @poke_center_count             = 0   # Incremented in Poké Center nurse events
    @revived_fossil_count          = 0   # Incremented in fossil reviver events
    @lottery_prize_count           = 0   # Incremented in lottery NPC events
    # Pokémon
    @eggs_hatched                  = 0
    @evolution_count               = 0
    @evolutions_cancelled          = 0
    @trade_count                   = 0
    @moves_taught_by_item          = 0
    @moves_taught_by_tutor         = 0
    @moves_taught_by_reminder      = 0
    @day_care_deposits             = 0
    @day_care_levels_gained        = 0
    @pokerus_infections            = 0
    @shadow_pokemon_purified       = 0
    # Battles
    @wild_battles_won              = 0
    @wild_battles_lost             = 0
    @trainer_battles_won           = 0
    @trainer_battles_lost          = 0
    @total_exp_gained              = 0
    @battle_money_gained           = 0
    @battle_money_lost             = 0
    @blacked_out_count             = 0
    @mega_evolution_count          = 0
    @failed_poke_ball_count        = 0
    # Currency
    @money_spent_at_marts          = 0
    @money_earned_at_marts         = 0
    @mart_items_bought             = 0
    @premier_balls_earned          = 0
    @drinks_bought                 = 0   # Incremented in vending machine events
    @drinks_won                    = 0   # Incremented in vending machine events
    @coins_won                     = 0
    @coins_lost                    = 0
    @battle_points_won             = 0
    @battle_points_spent           = 0
    @soot_collected                = 0
    # Special stats
    @gym_leader_attempts           = [0] * 50   # Incremented in Gym Leader events (50 is arbitrary but suitably large)
    @times_to_get_badges           = []   # Set with set_time_to_badge(number) in Gym Leader events
    @elite_four_attempts           = 0   # Incremented in door event leading to the first E4 member
    @hall_of_fame_entry_count      = 0   # Incremented in Hall of Fame event
    @time_to_enter_hall_of_fame    = 0   # Set with set_time_to_hall_of_fame in Hall of Fame event
    @safari_pokemon_caught         = 0
    @most_captures_per_safari_game = 0
    @bug_contest_count             = 0
    @bug_contest_wins              = 0
    # Play
    @play_time                     = 0
    @play_sessions                 = 0
    @time_last_saved               = 0
  end

  def distance_moved
    return @distance_walked + @distance_cycled + @distance_surfed
  end

  def caught_pokemon_count
    return 0 if !$player
    ret = 0
    GameData::Species.each_species { |sp| ret += $player.pokedex.caught_count(sp) }
    return ret
  end

  def save_count
    return $game_system&.save_count || 0
  end

  def set_time_to_badge(number)
    @times_to_get_badges[number] = play_time
  end

  def set_time_to_hall_of_fame
    @time_to_enter_hall_of_fame = play_time if @time_to_enter_hall_of_fame == 0
  end

  def play_time
    if $game_temp&.last_uptime_refreshed_play_time
      now = System.uptime
      @play_time += now - $game_temp.last_uptime_refreshed_play_time
      $game_temp.last_uptime_refreshed_play_time = now
    end
    return @play_time
  end

  def play_time_per_session
    return play_time / @play_sessions
  end

  def set_time_last_saved
    @time_last_saved = play_time
  end

  def time_since_last_save
    return play_time - @time_last_saved
  end
end

#===============================================================================
#
#===============================================================================
class Game_Temp
  attr_accessor :last_uptime_refreshed_play_time
end
