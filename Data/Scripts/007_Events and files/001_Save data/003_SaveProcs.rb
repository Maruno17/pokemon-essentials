# Contains the save values defined by default in Essentials.

# TODO: Do additional work (like setting up the map interpreter or initializing $PokemonEncounters)
#   inside the load_value procs

# TODO: Figure out how to handle the magic number and safesave stuff (what does the magic number even do?)

SaveData.register(:player) do
  ensure_class :PokeBattle_Trainer
  save_value { $Trainer }
  load_value { |value| $Trainer = value }
  from_old_format { |old_format| old_format[0] }
end

SaveData.register(:frame_count) do
  ensure_class :Fixnum
  save_value { Graphics.frame_count }
  load_value { |value| Graphics.frame_count = value }
  new_game_value { 0 }
  from_old_format { |old_format| old_format[1] }
end

SaveData.register(:game_system) do
  ensure_class :Game_System
  save_value { $game_system }
  load_value { |value| $game_system = value }
  new_game_value { Game_System.new }
  from_old_format { |old_format| old_format[2] }
end

SaveData.register(:pokemon_system) do
  ensure_class :PokemonSystem
  save_value { $PokemonSystem }
  load_value { |value| $PokemonSystem = value }
  from_old_format { |old_format| old_format[3] }
end

SaveData.register(:switches) do
  ensure_class :Game_Switches
  save_value { $game_switches }
  load_value { |value| $game_switches = value }
  new_game_value { Game_Switches.new }
  from_old_format { |old_format| old_format[5] }
end

SaveData.register(:variables) do
  ensure_class :Game_Variables
  save_value { $game_variables }
  load_value { |value| $game_variables = value }
  new_game_value { Game_Variables.new }
  from_old_format { |old_format| old_format[6] }
end

SaveData.register(:self_switches) do
  ensure_class :Game_SelfSwitches
  save_value { $game_self_switches }
  load_value { |value| $game_self_switches = value }
  new_game_value { Game_SelfSwitches.new }
  from_old_format { |old_format| old_format[7] }
end

SaveData.register(:game_screen) do
  ensure_class :Game_Screen
  save_value { $game_screen }
  load_value { |value| $game_screen = value }
  new_game_value { Game_Screen.new }
  from_old_format { |old_format| old_format[8] }
end

SaveData.register(:map_factory) do
  ensure_class :PokemonMapFactory
  save_value { $MapFactory }
  load_value do |value|
    $MapFactory = value
    $game_map = $MapFactory.map
    $PokemonEncounters = PokemonEncounters.new
    $PokemonEncounters.setup($game_map.map_id)
    next unless loading_new_game_value?
    if $data_system.respond_to?(:magic_number)
      magic_number_matches = ($game_system.magic_number == $data_system.magic_number)
    else
      magic_number_matches = ($game_system.magic_number == $data_system.version_id)
    end
    if !magic_number_matches || $PokemonGlobal.safesave
      if pbMapInterpreterRunning?
        pbMapInterpreter.setup(nil, 0)
      end
      begin
        $MapFactory.setup($game_map.map_id)
      rescue Errno::ENOENT
        if $DEBUG
          pbMessage(_INTL('Map {1} was not found.', $game_map.map_id))
          map = pbWarpToMap
          exit unless map
          $MapFactory.setup(map[0])
          $game_player.moveto(map[1], map[2])
        else
          raise _INTL('The map was not found. The game cannot continue.')
        end
      end
      $game_player.center($game_player.x, $game_player.y)
    else
      $MapFactory.setMapChanged($game_map.map_id)
    end
    if $game_map.events.nil?
      raise _INTL('The map is corrupt. The game cannot continue.')
    end
  end
  new_game_value { PokemonMapFactory.new($data_system.start_map_id) }
  from_old_format { |old_format| old_format[9] }
end

SaveData.register(:game_player) do
  ensure_class :Game_Player
  save_value { $game_player }
  load_value { |value| $game_player = value }
  new_game_value { Game_Player.new }
  from_old_format { |old_format| old_format[10] }
end

SaveData.register(:global_metadata) do
  ensure_class :PokemonGlobalMetadata
  save_value { $PokemonGlobal }
  load_value { |value| $PokemonGlobal = value }
  new_game_value { PokemonGlobalMetadata.new }
  from_old_format { |old_format| old_format[11] }
end

SaveData.register(:map_metadata) do
  ensure_class :PokemonMapMetadata
  save_value { $PokemonMap }
  load_value { |value| $PokemonMap = value }
  new_game_value { PokemonMapMetadata.new }
  from_old_format { |old_format| old_format[12] }
end

SaveData.register(:bag) do
  ensure_class :PokemonBag
  save_value { $PokemonBag }
  load_value { |value| $PokemonBag = value }
  from_old_format { |old_format| old_format[13] }
end

SaveData.register(:storage_system) do
  ensure_class :PokemonStorage
  save_value { $PokemonStorage }
  load_value { |value| $PokemonStorage = value }
  new_game_value { PokemonStorage.new }
  from_old_format { |old_format| old_format[14] }
end

SaveData.register(:essentials_version) do
  ensure_class :String
  save_value { $SaveVersion }
  load_value { |value| $SaveVersion = value }
  from_old_format { |old_format| old_format[15] }
end
