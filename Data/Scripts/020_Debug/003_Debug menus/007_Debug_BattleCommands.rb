=begin
# TODO:

Positions (Battle::ActivePosition)
  PBEffects::HealingWish
  PBEffects::LunarDance
turnCount
items (of foe trainers)
initialItems       - Array of two arrays, each with one value per party index
recycleItems       - Array of two arrays, each with one value per party index
belch              - Array of two arrays, each with one value per party index
corrosiveGas       - Array of two arrays, each with one value per party index
first_poke_ball    - both for Ball Fetch
poke_ball_failed   - both for Ball Fetch

View party screen for each trainer's team, be able to edit properties of Pokémon
that aren't in battle.

Choose each battler's next action.

=end

#===============================================================================
#
#===============================================================================
module BattleDebugMenuCommands
  @@commands = HandlerHashBasic.new

  def self.register(option, hash)
    @@commands.add(option, hash)
  end

  def self.registerIf(condition, hash)
    @@commands.addIf(condition, hash)
  end

  def self.copy(option, *new_options)
    @@commands.copy(option, *new_options)
  end

  def self.each
    @@commands.each { |key, hash| yield key, hash }
  end

  def self.hasFunction?(option, function)
    option_hash = @@commands[option]
    return option_hash && option_hash.keys.include?(function)
  end

  def self.getFunction(option, function)
    option_hash = @@commands[option]
    return (option_hash && option_hash[function]) ? option_hash[function] : nil
  end

  def self.call(function, option, *args)
    option_hash = @@commands[option]
    return nil if !option_hash || !option_hash[function]
    return (option_hash[function].call(*args) == true)
  end
end

#===============================================================================
# Battler Options
#===============================================================================
BattleDebugMenuCommands.register("battlers", {
  "parent"      => "main",
  "name"        => _INTL("Battlers..."),
  "description" => _INTL("Look at Pokémon in battle and change their properties."),
  "always_show" => true
})

BattleDebugMenuCommands.register("list_player_battlers", {
  "parent"      => "battlers",
  "name"        => _INTL("Player-Side Battlers"),
  "description" => _INTL("Edit Pokémon on the player's side of battle."),
  "always_show" => true,
  "effect"      => proc { |battle|
    battlers = []
    cmds = []
    battle.allSameSideBattlers.each do |b|
      battlers.push(b)
      text = "[#{b.index}] #{b.name} "
      if b.pbOwnedByPlayer?
        text += " (yours)"
      else
        text += " (ally's)"
      end
      cmds.push(text)
    end
    cmd = 0
    loop do
      cmd = pbMessage("\\ts[]" + _INTL("Choose a Pokémon."), cmds, -1, nil, cmd)
      break if cmd < 0
      battle.pbBattlePokemonDebug(battlers[cmd].pokemon, battlers[cmd])
    end
  }
})

BattleDebugMenuCommands.register("list_foe_battlers", {
  "parent"      => "battlers",
  "name"        => _INTL("Foe-Side Battlers"),
  "description" => _INTL("Edit Pokémon on the opposing side of battle."),
  "always_show" => true,
  "effect"      => proc { |battle|
    battlers = []
    cmds = []
    battle.allOtherSideBattlers.each do |b|
      battlers.push(b)
      cmds.push("[#{b.index}] #{b.name} ")
    end
    cmd = 0
    loop do
      cmd = pbMessage("\\ts[]" + _INTL("Choose a Pokémon."), cmds, -1, nil, cmd)
      break if cmd < 0
      battle.pbBattlePokemonDebug(battlers[cmd].pokemon, battlers[cmd])
    end
  }
})

#===============================================================================
# Field Options
#===============================================================================
BattleDebugMenuCommands.register("field", {
  "parent"      => "main",
  "name"        => _INTL("Field Effects..."),
  "description" => _INTL("Effects that apply to the whole battlefield."),
  "always_show" => true
})

BattleDebugMenuCommands.register("weather", {
  "parent"      => "field",
  "name"        => _INTL("Weather"),
  "description" => _INTL("Set weather and duration."),
  "always_show" => true,
  "effect"      => proc { |battle|
    weather_types = []
    weather_cmds = []
    GameData::BattleWeather.each do |weather|
      next if weather.id == :None
      weather_types.push(weather.id)
      weather_cmds.push(weather.name)
    end
    cmd = 0
    loop do
      weather_data = GameData::BattleWeather.try_get(battle.field.weather)
      msg = _INTL("Current weather: {1}", weather_data.name || _INTL("Unknown"))
      if weather_data.id != :None
        if battle.field.weatherDuration > 0
          msg += "\r\n"
          msg += _INTL("Duration : {1} more round(s)", battle.field.weatherDuration)
        elsif battle.field.weatherDuration < 0
          msg += "\r\n"
          msg += _INTL("Duration : Infinite")
        end
      end
      cmd = pbMessage("\\ts[]" + msg, [_INTL("Change type"),
                                       _INTL("Change duration"),
                                       _INTL("Clear weather")], -1, nil, cmd)
      break if cmd < 0
      case cmd
      when 0   # Change type
        weather_cmd = weather_types.index(battle.field.weather) || 0
        new_weather = pbMessage(
          "\\ts[]" + _INTL("Choose the new weather type."), weather_cmds, -1, nil, weather_cmd
        )
        if new_weather >= 0
          battle.field.weather = weather_types[new_weather]
          battle.field.weatherDuration = 5 if battle.field.weatherDuration == 0
        end
      when 1   # Change duration
        if battle.field.weather == :None
          pbMessage("\\ts[]" + _INTL("There is no weather."))
          next
        end
        params = ChooseNumberParams.new
        params.setRange(0, 99)
        params.setInitialValue([battle.field.weatherDuration, 0].max)
        params.setCancelValue([battle.field.weatherDuration, 0].max)
        new_duration = pbMessageChooseNumber(
          "\\ts[]" + _INTL("Choose the new weather duration (0=infinite)."), params
        )
        if new_duration != [battle.field.weatherDuration, 0].max
          battle.field.weatherDuration = (new_duration == 0) ? -1 : new_duration
        end
      when 2   # Clear weather
        battle.field.weather = :None
        battle.field.weatherDuration = 0
      end
    end
  }
})

BattleDebugMenuCommands.register("terrain", {
  "parent"      => "field",
  "name"        => _INTL("Terrain"),
  "description" => _INTL("Set terrain and duration."),
  "always_show" => true,
  "effect"      => proc { |battle|
    terrain_types = []
    terrain_cmds = []
    GameData::BattleTerrain.each do |terrain|
      next if terrain.id == :None
      terrain_types.push(terrain.id)
      terrain_cmds.push(terrain.name)
    end
    cmd = 0
    loop do
      terrain_data = GameData::BattleTerrain.try_get(battle.field.terrain)
      msg = _INTL("Current terrain: {1}", terrain_data.name || _INTL("Unknown"))
      if terrain_data.id != :None
        if battle.field.terrainDuration > 0
          msg += "\r\n"
          msg += _INTL("Duration : {1} more round(s)", battle.field.terrainDuration)
        elsif battle.field.terrainDuration < 0
          msg += "\r\n"
          msg += _INTL("Duration : Infinite")
        end
      end
      cmd = pbMessage("\\ts[]" + msg, [_INTL("Change type"),
                                       _INTL("Change duration"),
                                       _INTL("Clear terrain")], -1, nil, cmd)
      break if cmd < 0
      case cmd
      when 0   # Change type
        terrain_cmd = terrain_types.index(battle.field.terrain) || 0
        new_terrain = pbMessage(
          "\\ts[]" + _INTL("Choose the new terrain type."), terrain_cmds, -1, nil, terrain_cmd
        )
        if new_terrain >= 0
          battle.field.terrain = terrain_types[new_terrain]
          battle.field.terrainDuration = 5 if battle.field.terrainDuration == 0
        end
      when 1   # Change duration
        if battle.field.terrain == :None
          pbMessage("\\ts[]" + _INTL("There is no terrain."))
          next
        end
        params = ChooseNumberParams.new
        params.setRange(0, 99)
        params.setInitialValue([battle.field.terrainDuration, 0].max)
        params.setCancelValue([battle.field.terrainDuration, 0].max)
        new_duration = pbMessageChooseNumber(
          "\\ts[]" + _INTL("Choose the new terrain duration (0=infinite)."), params
        )
        if new_duration != [battle.field.terrainDuration, 0].max
          battle.field.terrainDuration = (new_duration == 0) ? -1 : new_duration
        end
      when 2   # Clear terrain
        battle.field.terrain = :None
        battle.field.terrainDuration = 0
      end
    end
  }
})

BattleDebugMenuCommands.register("environment", {
  "parent"      => "field",
  "name"        => _INTL("Environment/Time"),
  "description" => _INTL("Set the battle's environment and time of day."),
  "always_show" => true,
  "effect"      => proc { |battle|
    environment_types = []
    environment_cmds = []
    GameData::Environment.each do |environment|
      environment_types.push(environment.id)
      environment_cmds.push(environment.name)
    end
    cmd = 0
    loop do
      environment_data = GameData::Environment.try_get(battle.environment)
      msg = _INTL("Environment: {1}", environment_data.name || _INTL("Unknown"))
      msg += "\r\n"
      msg += _INTL("Time of day: {1}", [_INTL("Day"), _INTL("Evening"), _INTL("Night")][battle.time])
      cmd = pbMessage("\\ts[]" + msg, [_INTL("Change environment"),
                                       _INTL("Change time of day")], -1, nil, cmd)
      break if cmd < 0
      case cmd
      when 0   # Change environment
        environment_cmd = environment_types.index(battle.environment) || 0
        new_environment = pbMessage(
          "\\ts[]" + _INTL("Choose the new environment."), environment_cmds, -1, nil, environment_cmd
        )
        if new_environment >= 0
          battle.environment = environment_types[new_environment]
        end
      when 1   # Change time of day
        new_time = pbMessage("\\ts[]" + _INTL("Choose the new time."),
                             [_INTL("Day"), _INTL("Evening"), _INTL("Night")], -1, nil, battle.time)
        battle.time = new_time if new_time >= 0 && new_time != battle.time
      end
    end
  }
})

BattleDebugMenuCommands.register("backdrop", {
  "parent"      => "field",
  "name"        => _INTL("Backdrop Names"),
  "description" => _INTL("Set the names of the backdrop and base graphics."),
  "always_show" => true,
  "effect"      => proc { |battle|
    loop do
      cmd = pbMessage("\\ts[]" + _INTL("Set which backdrop name?"),
                      [_INTL("Backdrop"),
                       _INTL("Base modifier")], -1)
      break if cmd < 0
      case cmd
      when 0   # Backdrop
        text = pbMessageFreeText("\\ts[]" + _INTL("Set the backdrop's name."),
                                 battle.backdrop, false, 100, Graphics.width)
        battle.backdrop = (nil_or_empty?(text)) ? "Indoor1" : text
      when 1   # Base modifier
        text = pbMessageFreeText("\\ts[]" + _INTL("Set the base modifier text."),
                                 battle.backdropBase, false, 100, Graphics.width)
        battle.backdropBase = (nil_or_empty?(text)) ? nil : text
      end
    end
  }
})

BattleDebugMenuCommands.register("set_field_effects", {
  "parent"      => "field",
  "name"        => _INTL("Other Field Effects..."),
  "description" => _INTL("View/set other effects that apply to the whole battlefield."),
  "always_show" => true,
  "effect"      => proc { |battle|
    editor = Battle::DebugSetEffects.new(battle, :field)
    editor.update
    editor.dispose
  }
})

BattleDebugMenuCommands.register("player_side", {
  "parent"      => "field",
  "name"        => _INTL("Player's Side Effects..."),
  "description" => _INTL("Effects that apply to the side the player is on."),
  "always_show" => true,
  "effect"      => proc { |battle|
    editor = Battle::DebugSetEffects.new(battle, :side, 0)
    editor.update
    editor.dispose
  }
})

BattleDebugMenuCommands.register("opposing_side", {
  "parent"      => "field",
  "name"        => _INTL("Foe's Side Effects..."),
  "description" => _INTL("Effects that apply to the opposing side."),
  "always_show" => true,
  "effect"      => proc { |battle|
    editor = Battle::DebugSetEffects.new(battle, :side, 1)
    editor.update
    editor.dispose
  }
})

#===============================================================================
# Trainer Options
#===============================================================================
BattleDebugMenuCommands.register("trainers", {
  "parent"      => "main",
  "name"        => _INTL("Trainer Options..."),
  "description" => _INTL("Variables that apply to trainers."),
  "always_show" => true
})

BattleDebugMenuCommands.register("mega_evolution", {
  "parent"      => "trainers",
  "name"        => _INTL("Mega Evolution"),
  "description" => _INTL("Whether each trainer is allowed to Mega Evolve."),
  "always_show" => true,
  "effect"      => proc { |battle|
    cmd = 0
    loop do
      commands = []
      cmds = []
      battle.megaEvolution.each_with_index do |side_values, side|
        trainers = (side == 0) ? battle.player : battle.opponent
        next if !trainers
        side_values.each_with_index do |value, i|
          next if !trainers[i]
          text = (side == 0) ? "Your side:" : "Foe side:"
          text += sprintf(" %d: %s", i, trainers[i].name)
          text += sprintf(" [ABLE]") if value == -1
          text += sprintf(" [UNABLE]") if value == -2
          commands.push(text)
          cmds.push([side, i])
        end
      end
      cmd = pbMessage("\\ts[]" + _INTL("Choose trainer to toggle whether they can Mega Evolve."),
                      commands, -1, nil, cmd)
      break if cmd < 0
      real_cmd = cmds[cmd]
      if battle.megaEvolution[real_cmd[0]][real_cmd[1]] == -1
        battle.megaEvolution[real_cmd[0]][real_cmd[1]] = -2   # Make unable
      else
        battle.megaEvolution[real_cmd[0]][real_cmd[1]] = -1   # Make able
      end
    end
  }
})

BattleDebugMenuCommands.register("speed_order", {
  "parent"      => "main",
  "name"        => _INTL("Battler Speed Order"),
  "description" => _INTL("Show all battlers in order from fastest to slowest."),
  "always_show" => true,
  "effect"      => proc { |battle|
    battlers = battle.allBattlers.map { |b| [b, b.pbSpeed] }
    battlers.sort! { |a, b| b[1] <=> a[1] }
    commands = []
    battlers.each do |value|
      b = value[0]
      commands.push(sprintf("[%d] %s (speed: %d)", b.index, b.pbThis, value[1]))
    end
    pbMessage("\\ts[]" + _INTL("Battlers are listed from fastest to slowest. Speeds include modifiers."),
              commands, -1)
  }
})
