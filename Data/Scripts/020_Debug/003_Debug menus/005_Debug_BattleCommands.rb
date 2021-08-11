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
  "parent" => "main",
  "name" => _INTL("Battler Options"),
  "description" => _INTL("Change things about a battler."),
  "always_show" => true,
})

#===============================================================================
# Field Options
#===============================================================================
BattleDebugMenuCommands.register("battlefield", {
  "parent" => "main",
  "name" => _INTL("Field Options"),
  "description" => _INTL("Options that affect the whole battle field."),
  "always_show" => true
})

BattleDebugMenuCommands.register("weather", {
  "parent" => "battlefield",
  "name" => _INTL("Weather"),
  "description" => _INTL("Set weather and duration."),
  "always_show" => true
})

BattleDebugMenuCommands.register("setweather", {
  "parent" => "weather",
  "name" => _INTL("Set Weather"),
  "description" => _INTL("Will start a weather indefinitely. Make it run out by setting a duration."),
  "always_show" => true,
  "effect" => proc { |battle, sprites|
    weatherCommands = []
    currentWeather = battle.field.weather
    weatherIdxMap = []
    counter = 0
    GameData::BattleWeather.each { |weather|
      weatherCommands.push([counter, _INTL("{1}",weather.name)])
      weatherIdxMap[counter] = weather.id
      counter += 1
    }
    currentWeather = battle.field.weather
    currentWeatherIdx = weatherIdxMap.index(currentWeather)
    
    newWeatherIdx = pbChooseList(weatherCommands, currentWeatherIdx, currentWeatherIdx, 1)
    newWeather = weatherIdxMap[newWeatherIdx]
    weatherChanged = newWeather != currentWeather

    if !weatherChanged
      next;
    end
    
    if newWeather == :None
      battle.field.weather = :None
      battle.field.weatherDuration = 0
      next
    end
    
    visibleSprites = pbFadeOutAndHide(sprites) 
    battle.pbStartWeather(nil, newWeather)
    pbFadeInAndShow(sprites,visibleSprites) 
  }
})

BattleDebugMenuCommands.register("setweatherduration", {
  "parent" => "weather",
  "name" => _INTL("Set Duration"),
  "description" => _INTL("Set the duration of weather."),
  "always_show" => true,
  "effect" => proc { |battle|
    weatherduration = battle.field.weatherDuration
    battle.field.weatherDuration = getNumericValue("Set weather duration. -1 makes it so that it never run out.", weatherduration)
  }
})

BattleDebugMenuCommands.register("terrain",
  {
    "parent" => "battlefield",
    "name" => _INTL("Terrain"),
    "description" => _INTL("Set terrain and duration."),
    "always_show" => true,
  })

BattleDebugMenuCommands.register("setterrain",
  {
    "parent" => "terrain",
    "name" => _INTL("Set Terrain"),
    "description" => _INTL("Will start a terrain indefinitely. Make it run out by setting a duration."),
    "always_show" => true,
    "effect" => proc { |battle, sprites|
    terrainCommands = []
    terrainIdxMap = []
    currentTerrain = battle.field.terrain
    counter = 0
      GameData::BattleTerrain.each { |terrain|
      terrainCommands.push([counter, _INTL("{1}",terrain.name)])
      terrainIdxMap[counter] = terrain.id
      counter += 1
    }

    currentTerrain = battle.field.terrain
    currentTerrainIdx = terrainIdxMap.index(currentTerrain)

    newTerrainIdx = pbChooseList(terrainCommands, currentTerrainIdx, currentTerrainIdx, 1)
    newTerrain = terrainIdxMap[newTerrainIdx];
    terrainChanged = newTerrain != currentTerrain

    if !terrainChanged
      next;
    end
    
    if newTerrain == :None
      battle.field.terrain = :None
      battle.field.terrainDuration = 0
      next
    end
    
    visibleSprites = pbFadeOutAndHide(sprites) 
    battle.pbStartTerrain(nil, newTerrain, false)
    pbFadeInAndShow(sprites,visibleSprites)
    }
  })

BattleDebugMenuCommands.register("setterrainduration",
{
  "parent" => "terrain",
  "name" => _INTL("Set Duration"),
  "description" => _INTL("Set the duration of the terrain."),
  "always_show" => true,
  "effect" => proc { |battle|
    terrainDuration = battle.field.terrainDuration
    battle.field.terrainDuration = getNumericValue("Set duration. -1 makes it so that it never run out.", terrainDuration)
  }
})

BattleDebugMenuCommands.register("setfieldeffect",
  {
    "parent" => "battlefield",
    "name" => _INTL("Set Field Effects"),
    "description" => _INTL("Effects that apply to the whole field."),
    "always_show" => true,
    "effect" => proc { |battle|
      viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      viewport.z = 99999
      sprites = {}
      sprites["right_window"] = SpriteWindow_DebugBattleEffects.new(viewport, battle.field, FIELD_EFFECTS)
      right_window = sprites["right_window"]
      right_window.active = true
      loopHandler = DebugBattle_LoopHandler.new(sprites, right_window, battle.effects, @battlers)
      loopHandler.startLoop
      viewport.dispose
    }
  })

BattleDebugMenuCommands.register("playerside",
  {
    "parent" => "main",
    "name" => _INTL("Player Side"),
    "description" => _INTL("Effects that apply to the side the player is on."),
    "always_show" => true,
    "effect" => proc { |battle|
      sides = battle.sides
      battlers = battle.battlers
      setSideEffects(0, sides, battlers)
    }
  })

BattleDebugMenuCommands.register("opposingside",
  {
    "parent" => "main",
    "name" => _INTL("Opposing Side"),
    "description" => _INTL("Effects that apply to the opposing side."),
    "always_show" => true,
    "effect" => proc { |battle|
      sides = battle.sides
      battlers = battle.battlers
      setSideEffects(1, sides, battlers)
    }
  })

BattleDebugMenuCommands.register("battlemeta",
  {
    "parent" => "main",
    "name" => _INTL("Battle Metadata"),
    "description" => _INTL("Change things about the battle itself (turn counter, etc.)"),
    "always_show" => true,
    "effect" => proc { |battle|
      viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      viewport.z = 99999
      sprites = {}
      sprites["right_window"] = SpriteWindow_DebugBattleMetaData.new(viewport, self, BATTLE_METADATA)
      right_window = sprites["right_window"]
      right_window.active = true
      loopHandler = DebugBattleMeta_LoopHandler.new(sprites, right_window, self, @battlers)
      loopHandler.startLoop
      viewport.dispose
    }
  })