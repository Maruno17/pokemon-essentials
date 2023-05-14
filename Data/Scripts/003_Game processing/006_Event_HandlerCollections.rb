#===============================================================================
# This module stores events that can happen during the game. A procedure can
# subscribe to an event by adding itself to the event. It will then be called
# whenever the event occurs. Existing events are:
#-------------------------------------------------------------------------------
#   :on_game_map_setup - When a Game_Map is set up. Typically changes map data.
#   :on_new_spriteset_map - When a Spriteset_Map is created. Adds more things to
#     show in the overworld.
#   :on_frame_update - Once per frame. Various frame/time counters.
#   :on_leave_map - When leaving a map. End weather/expired effects.
#   :on_enter_map - Upon entering a new map. Set up new effects, end expired
#     effects.
#   :on_map_or_spriteset_change - Upon entering a new map or when spriteset was
#     made. Show things on-screen.
#-------------------------------------------------------------------------------
#   :on_player_change_direction - When the player turns in a different direction.
#   :on_leave_tile - When any event or the player starts to move from a tile.
#   :on_step_taken - When any event or the player finishes a step.
#   :on_player_step_taken - When the player finishes a step/ends surfing, except
#     as part of a move route. Step-based counters.
#   :on_player_step_taken_can_transfer - When the player finishes a step/ends
#     surfing, except as part of a move route. Step-based effects that can
#     transfer the player elsewhere.
#   :on_player_interact - When the player presses the Use button in the
#     overworld.
#-------------------------------------------------------------------------------
#   :on_trainer_load - When an NPCTrainer is generated (to battle against or as
#     a registered partner). Various modifications to that trainer and their
#     Pokémon.
#   :on_wild_species_chosen - When a species/level have been chosen for a wild
#     encounter. Changes the species/level (e.g. roamer, Poké Radar chain).
#   :on_wild_pokemon_created - When a Pokemon object has been created for a wild
#     encounter. Various modifications to that Pokémon.
#   :on_calling_wild_battle - When a wild battle is called. Prevents that wild
#     battle and instead starts a different kind of battle (e.g. Safari Zone).
#   :on_start_battle - Just before a battle starts. Memorize/reset information
#     about party Pokémon, which is used after battle for evolution checks.
#   :on_end_battle - Just after a battle ends. Evolution checks, Pickup/Honey
#     Gather, blacking out.
#   :on_wild_battle_end - After a wild battle. Updates Poké Radar chain info.
#===============================================================================
module EventHandlers
  @@events = {}

  # Add a named callback for the given event.
  def self.add(event, key, proc)
    @@events[event] = NamedEvent.new if !@@events.has_key?(event)
    @@events[event].add(key, proc)
  end

  # Remove a named callback from the given event.
  def self.remove(event, key)
    @@events[event]&.remove(key)
  end

  # Clear all callbacks for the given event.
  def self.clear(key)
    @@events[key]&.clear
  end

  # Trigger all callbacks from an Event if it has been defined.
  def self.trigger(event, *args)
    return @@events[event]&.trigger(*args)
  end
end

#===============================================================================
# This module stores the contents of various menus. Each command in a menu is a
# hash of data (containing its name, relative order, code to run when chosen,
# etc.).
# Menus that use this module are:
#-------------------------------------------------------------------------------
# Pause menu
# Party screen main interact menu
# Pokégear main menu
# Options screen
# PC main menu
# Various debug menus (main, Pokémon, battle, battle Pokémon)
#===============================================================================
module MenuHandlers
  @@handlers = {}

  def self.add(menu, option, hash)
    @@handlers[menu] = HandlerHash.new if !@@handlers.has_key?(menu)
    @@handlers[menu].add(option, hash)
  end

  def self.remove(menu, option)
    @@handlers[menu]&.remove(option)
  end

  def self.clear(menu)
    @@handlers[menu]&.clear
  end

  def self.each(menu)
    return if !@@handlers.has_key?(menu)
    @@handlers[menu].each { |option, hash| yield option, hash }
  end

  def self.each_available(menu, *args)
    return if !@@handlers.has_key?(menu)
    options = @@handlers[menu]
    keys = options.keys
    sorted_keys = keys.sort_by { |option| options[option]["order"] || keys.index(option) }
    sorted_keys.each do |option|
      hash = options[option]
      next if hash["condition"] && !hash["condition"].call(*args)
      if hash["name"].is_a?(Proc)
        name = hash["name"].call
      else
        name = _INTL(hash["name"])
      end
      yield option, hash, name
    end
  end

  def self.call(menu, option, function, *args)
    option_hash = @@handlers[menu][option]
    return nil if !option_hash || !option_hash[function]
    return option_hash[function].call(*args)
  end
end
