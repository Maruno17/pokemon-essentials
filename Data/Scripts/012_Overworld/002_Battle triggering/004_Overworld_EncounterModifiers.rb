#===============================================================================
# This section was created solely for you to put various bits of code that
# modify various wild Pokémon and trainers immediately prior to battling them.
# Be sure that any code you use here ONLY applies to the Pokémon/trainers you
# want it to apply to!
#===============================================================================

# Make all wild Pokémon shiny while a certain Switch is ON (see Settings).
EventHandlers.add(:on_wild_pokemon_created, :make_shiny_switch,
  proc { |pkmn|
    pkmn.shiny = true if $game_switches[Settings::SHINY_WILD_POKEMON_SWITCH]
  }
)

# Used in the random dungeon map. Makes the levels of all wild Pokémon in that
# map depend on the levels of Pokémon in the player's party.
# This is a simple method, and can/should be modified to account for evolutions
# and other such details.  Of course, you don't HAVE to use this code.
EventHandlers.add(:on_wild_pokemon_created, :level_depends_on_party,
  proc { |pkmn|
    next if !$game_map.metadata&.has_flag?("ScaleWildEncounterLevels")
    new_level = pbBalancedLevel($player.party) - 4 + rand(5)   # For variety
    new_level = new_level.clamp(1, GameData::GrowthRate.max_level)
    pkmn.level = new_level
    pkmn.calc_stats
    pkmn.reset_moves
  }
)

# This is the basis of a trainer modifier. It works both for trainers loaded
# when you battle them, and for partner trainers when they are registered.
# Note that you can only modify a partner trainer's Pokémon, and not the trainer
# themselves nor their items this way, as those are generated from scratch
# before each battle.
# EventHandlers.add(:on_trainer_load, :put_a_name_here,
#   proc { |trainer|
#     if trainer   # An NPCTrainer object containing party/items/lose text, etc.
#       YOUR CODE HERE
#     end
#   }
# )
