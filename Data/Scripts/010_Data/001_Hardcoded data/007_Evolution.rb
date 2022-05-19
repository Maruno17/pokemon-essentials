module GameData
  class Evolution
    attr_reader :id
    attr_reader :real_name
    attr_reader :parameter
    attr_reader :minimum_level   # 0 means parameter is the minimum level
    attr_reader :level_up_proc
    attr_reader :use_item_proc
    attr_reader :on_trade_proc
    attr_reader :after_battle_proc
    attr_reader :event_proc
    attr_reader :after_evolution_proc

    DATA = {}

    extend ClassMethodsSymbols
    include InstanceMethods

    def self.load; end
    def self.save; end

    def initialize(hash)
      @id                   = hash[:id]
      @real_name            = hash[:id].to_s       || "Unnamed"
      @parameter            = hash[:parameter]
      @minimum_level        = hash[:minimum_level] || 0
      @level_up_proc        = hash[:level_up_proc]
      @use_item_proc        = hash[:use_item_proc]
      @on_trade_proc        = hash[:on_trade_proc]
      @after_battle_proc    = hash[:after_battle_proc]
      @event_proc           = hash[:event_proc]
      @after_evolution_proc = hash[:after_evolution_proc]
    end

    def call_level_up(*args)
      return (@level_up_proc) ? @level_up_proc.call(*args) : nil
    end

    def call_use_item(*args)
      return (@use_item_proc) ? @use_item_proc.call(*args) : nil
    end

    def call_on_trade(*args)
      return (@on_trade_proc) ? @on_trade_proc.call(*args) : nil
    end

    def call_after_battle(*args)
      return (@after_battle_proc) ? @after_battle_proc.call(*args) : nil
    end

    def call_event(*args)
      return (@event_proc) ? @event_proc.call(*args) : nil
    end

    def call_after_evolution(*args)
      @after_evolution_proc&.call(*args)
    end
  end
end

#===============================================================================

GameData::Evolution.register({
  :id => :None
})

GameData::Evolution.register({
  :id            => :Level,
  :parameter     => Integer,
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.level >= parameter
  }
})

GameData::Evolution.register({
  :id            => :LevelMale,
  :parameter     => Integer,
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.level >= parameter && pkmn.male?
  }
})

GameData::Evolution.register({
  :id            => :LevelFemale,
  :parameter     => Integer,
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.level >= parameter && pkmn.female?
  }
})

GameData::Evolution.register({
  :id            => :LevelDay,
  :parameter     => Integer,
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.level >= parameter && PBDayNight.isDay?
  }
})

GameData::Evolution.register({
  :id            => :LevelNight,
  :parameter     => Integer,
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.level >= parameter && PBDayNight.isNight?
  }
})

GameData::Evolution.register({
  :id            => :LevelMorning,
  :parameter     => Integer,
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.level >= parameter && PBDayNight.isMorning?
  }
})

GameData::Evolution.register({
  :id            => :LevelAfternoon,
  :parameter     => Integer,
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.level >= parameter && PBDayNight.isAfternoon?
  }
})

GameData::Evolution.register({
  :id            => :LevelEvening,
  :parameter     => Integer,
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.level >= parameter && PBDayNight.isEvening?
  }
})

GameData::Evolution.register({
  :id            => :LevelNoWeather,
  :parameter     => Integer,
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.level >= parameter && $game_screen && $game_screen.weather_type == :None
  }
})

GameData::Evolution.register({
  :id            => :LevelSun,
  :parameter     => Integer,
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.level >= parameter && $game_screen &&
         GameData::Weather.get($game_screen.weather_type).category == :Sun
  }
})

GameData::Evolution.register({
  :id            => :LevelRain,
  :parameter     => Integer,
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.level >= parameter && $game_screen &&
         [:Rain, :Fog].include?(GameData::Weather.get($game_screen.weather_type).category)
  }
})

GameData::Evolution.register({
  :id            => :LevelSnow,
  :parameter     => Integer,
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.level >= parameter && $game_screen &&
         GameData::Weather.get($game_screen.weather_type).category == :Hail
  }
})

GameData::Evolution.register({
  :id            => :LevelSandstorm,
  :parameter     => Integer,
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.level >= parameter && $game_screen &&
         GameData::Weather.get($game_screen.weather_type).category == :Sandstorm
  }
})

GameData::Evolution.register({
  :id            => :LevelCycling,
  :parameter     => Integer,
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.level >= parameter && $PokemonGlobal && $PokemonGlobal.bicycle
  }
})

GameData::Evolution.register({
  :id            => :LevelSurfing,
  :parameter     => Integer,
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.level >= parameter && $PokemonGlobal && $PokemonGlobal.surfing
  }
})

GameData::Evolution.register({
  :id            => :LevelDiving,
  :parameter     => Integer,
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.level >= parameter && $PokemonGlobal && $PokemonGlobal.diving
  }
})

GameData::Evolution.register({
  :id            => :LevelDarkness,
  :parameter     => Integer,
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.level >= parameter && $game_map.metadata&.dark_map
  }
})

GameData::Evolution.register({
  :id            => :LevelDarkInParty,
  :parameter     => Integer,
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.level >= parameter && $player.has_pokemon_of_type?(:DARK)
  }
})

GameData::Evolution.register({
  :id            => :AttackGreater,   # Hitmonlee
  :parameter     => Integer,
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.level >= parameter && pkmn.attack > pkmn.defense
  }
})

GameData::Evolution.register({
  :id            => :AtkDefEqual,   # Hitmontop
  :parameter     => Integer,
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.level >= parameter && pkmn.attack == pkmn.defense
  }
})

GameData::Evolution.register({
  :id            => :DefenseGreater,   # Hitmonchan
  :parameter     => Integer,
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.level >= parameter && pkmn.attack < pkmn.defense
  }
})

GameData::Evolution.register({
  :id            => :Silcoon,
  :parameter     => Integer,
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.level >= parameter && (((pkmn.personalID >> 16) & 0xFFFF) % 10) < 5
  }
})

GameData::Evolution.register({
  :id            => :Cascoon,
  :parameter     => Integer,
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.level >= parameter && (((pkmn.personalID >> 16) & 0xFFFF) % 10) >= 5
  }
})

GameData::Evolution.register({
  :id            => :Ninjask,
  :parameter     => Integer,
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.level >= parameter
  }
})

GameData::Evolution.register({
  :id                   => :Shedinja,
  :parameter            => Integer,
  :after_evolution_proc => proc { |pkmn, new_species, parameter, evo_species|
    next false if $player.party_full?
    next false if !$bag.has?(:POKEBALL)
    PokemonEvolutionScene.pbDuplicatePokemon(pkmn, new_species)
    $bag.remove(:POKEBALL)
    next true
  }
})

GameData::Evolution.register({
  :id            => :Happiness,
  :minimum_level => 1,   # Needs any level up
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.happiness >= (Settings::APPLY_HAPPINESS_SOFT_CAP ? 160 : 220)
  }
})

GameData::Evolution.register({
  :id            => :HappinessMale,
  :minimum_level => 1,   # Needs any level up
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.happiness >= (Settings::APPLY_HAPPINESS_SOFT_CAP ? 160 : 220) && pkmn.male?
  }
})

GameData::Evolution.register({
  :id            => :HappinessFemale,
  :minimum_level => 1,   # Needs any level up
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.happiness >= (Settings::APPLY_HAPPINESS_SOFT_CAP ? 160 : 220) && pkmn.female?
  }
})

GameData::Evolution.register({
  :id            => :HappinessDay,
  :minimum_level => 1,   # Needs any level up
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.happiness >= (Settings::APPLY_HAPPINESS_SOFT_CAP ? 160 : 220) && PBDayNight.isDay?
  }
})

GameData::Evolution.register({
  :id            => :HappinessNight,
  :minimum_level => 1,   # Needs any level up
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.happiness >= (Settings::APPLY_HAPPINESS_SOFT_CAP ? 160 : 220) && PBDayNight.isNight?
  }
})

GameData::Evolution.register({
  :id            => :HappinessMove,
  :parameter     => :Move,
  :minimum_level => 1,   # Needs any level up
  :level_up_proc => proc { |pkmn, parameter|
    if pkmn.happiness >= (Settings::APPLY_HAPPINESS_SOFT_CAP ? 160 : 220)
      next pkmn.moves.any? { |m| m && m.id == parameter }
    end
  }
})

GameData::Evolution.register({
  :id            => :HappinessMoveType,
  :parameter     => :Type,
  :minimum_level => 1,   # Needs any level up
  :level_up_proc => proc { |pkmn, parameter|
    if pkmn.happiness >= (Settings::APPLY_HAPPINESS_SOFT_CAP ? 160 : 220)
      next pkmn.moves.any? { |m| m && m.type == parameter }
    end
  }
})

GameData::Evolution.register({
  :id                   => :HappinessHoldItem,
  :parameter            => :Item,
  :minimum_level        => 1,   # Needs any level up
  :level_up_proc        => proc { |pkmn, parameter|
    next pkmn.item == parameter && pkmn.happiness >= (Settings::APPLY_HAPPINESS_SOFT_CAP ? 160 : 220)
  },
  :after_evolution_proc => proc { |pkmn, new_species, parameter, evo_species|
    next false if evo_species != new_species || !pkmn.hasItem?(parameter)
    pkmn.item = nil   # Item is now consumed
    next true
  }
})

GameData::Evolution.register({
  :id            => :MaxHappiness,
  :minimum_level => 1,   # Needs any level up
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.happiness == 255
  }
})

GameData::Evolution.register({
  :id            => :Beauty,   # Feebas
  :parameter     => Integer,
  :minimum_level => 1,   # Needs any level up
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.beauty >= parameter
  }
})

GameData::Evolution.register({
  :id                   => :HoldItem,
  :parameter            => :Item,
  :minimum_level        => 1,   # Needs any level up
  :level_up_proc        => proc { |pkmn, parameter|
    next pkmn.item == parameter
  },
  :after_evolution_proc => proc { |pkmn, new_species, parameter, evo_species|
    next false if evo_species != new_species || !pkmn.hasItem?(parameter)
    pkmn.item = nil   # Item is now consumed
    next true
  }
})

GameData::Evolution.register({
  :id                   => :HoldItemMale,
  :parameter            => :Item,
  :minimum_level        => 1,   # Needs any level up
  :level_up_proc        => proc { |pkmn, parameter|
    next pkmn.item == parameter && pkmn.male?
  },
  :after_evolution_proc => proc { |pkmn, new_species, parameter, evo_species|
    next false if evo_species != new_species || !pkmn.hasItem?(parameter)
    pkmn.item = nil   # Item is now consumed
    next true
  }
})

GameData::Evolution.register({
  :id                   => :HoldItemFemale,
  :parameter            => :Item,
  :minimum_level        => 1,   # Needs any level up
  :level_up_proc        => proc { |pkmn, parameter|
    next pkmn.item == parameter && pkmn.female?
  },
  :after_evolution_proc => proc { |pkmn, new_species, parameter, evo_species|
    next false if evo_species != new_species || !pkmn.hasItem?(parameter)
    pkmn.item = nil   # Item is now consumed
    next true
  }
})

GameData::Evolution.register({
  :id                   => :DayHoldItem,
  :parameter            => :Item,
  :minimum_level        => 1,   # Needs any level up
  :level_up_proc        => proc { |pkmn, parameter|
    next pkmn.item == parameter && PBDayNight.isDay?
  },
  :after_evolution_proc => proc { |pkmn, new_species, parameter, evo_species|
    next false if evo_species != new_species || !pkmn.hasItem?(parameter)
    pkmn.item = nil   # Item is now consumed
    next true
  }
})

GameData::Evolution.register({
  :id                   => :NightHoldItem,
  :parameter            => :Item,
  :minimum_level        => 1,   # Needs any level up
  :level_up_proc        => proc { |pkmn, parameter|
    next pkmn.item == parameter && PBDayNight.isNight?
  },
  :after_evolution_proc => proc { |pkmn, new_species, parameter, evo_species|
    next false if evo_species != new_species || !pkmn.hasItem?(parameter)
    pkmn.item = nil   # Item is now consumed
    next true
  }
})

GameData::Evolution.register({
  :id                   => :HoldItemHappiness,
  :parameter            => :Item,
  :minimum_level        => 1,   # Needs any level up
  :level_up_proc        => proc { |pkmn, parameter|
    next pkmn.item == parameter && pkmn.happiness >= (Settings::APPLY_HAPPINESS_SOFT_CAP ? 160 : 220)
  },
  :after_evolution_proc => proc { |pkmn, new_species, parameter, evo_species|
    next false if evo_species != new_species || !pkmn.hasItem?(parameter)
    pkmn.item = nil   # Item is now consumed
    next true
  }
})

GameData::Evolution.register({
  :id            => :HasMove,
  :parameter     => :Move,
  :minimum_level => 1,   # Needs any level up
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.moves.any? { |m| m && m.id == parameter }
  }
})

GameData::Evolution.register({
  :id            => :HasMoveType,
  :parameter     => :Type,
  :minimum_level => 1,   # Needs any level up
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.moves.any? { |m| m && m.type == parameter }
  }
})

GameData::Evolution.register({
  :id            => :HasInParty,
  :parameter     => :Species,
  :minimum_level => 1,   # Needs any level up
  :level_up_proc => proc { |pkmn, parameter|
    next $player.has_species?(parameter)
  }
})

GameData::Evolution.register({
  :id            => :Location,
  :parameter     => Integer,
  :minimum_level => 1,   # Needs any level up
  :level_up_proc => proc { |pkmn, parameter|
    next $game_map.map_id == parameter
  }
})

GameData::Evolution.register({
  :id            => :LocationFlag,
  :parameter     => String,
  :minimum_level => 1,   # Needs any level up
  :level_up_proc => proc { |pkmn, parameter|
    next $game_map.metadata&.has_flag?(parameter)
  }
})

GameData::Evolution.register({
  :id            => :Region,
  :parameter     => Integer,
  :minimum_level => 1,   # Needs any level up
  :level_up_proc => proc { |pkmn, parameter|
    map_metadata = $game_map.metadata
    next map_metadata&.town_map_position && map_metadata.town_map_position[0] == parameter
  }
})

#===============================================================================
# Evolution methods that trigger when using an item on the Pokémon
#===============================================================================
GameData::Evolution.register({
  :id            => :Item,
  :parameter     => :Item,
  :use_item_proc => proc { |pkmn, parameter, item|
    next item == parameter
  }
})

GameData::Evolution.register({
  :id            => :ItemMale,
  :parameter     => :Item,
  :use_item_proc => proc { |pkmn, parameter, item|
    next item == parameter && pkmn.male?
  }
})

GameData::Evolution.register({
  :id            => :ItemFemale,
  :parameter     => :Item,
  :use_item_proc => proc { |pkmn, parameter, item|
    next item == parameter && pkmn.female?
  }
})

GameData::Evolution.register({
  :id            => :ItemDay,
  :parameter     => :Item,
  :use_item_proc => proc { |pkmn, parameter, item|
    next item == parameter && PBDayNight.isDay?
  }
})

GameData::Evolution.register({
  :id            => :ItemNight,
  :parameter     => :Item,
  :use_item_proc => proc { |pkmn, parameter, item|
    next item == parameter && PBDayNight.isNight?
  }
})

GameData::Evolution.register({
  :id            => :ItemHappiness,
  :parameter     => :Item,
  :use_item_proc => proc { |pkmn, parameter, item|
    next item == parameter && pkmn.happiness >= (Settings::APPLY_HAPPINESS_SOFT_CAP ? 160 : 220)
  }
})

#===============================================================================
# Evolution methods that trigger when the Pokémon is obtained in a trade
#===============================================================================
GameData::Evolution.register({
  :id            => :Trade,
  :on_trade_proc => proc { |pkmn, parameter, other_pkmn|
    next true
  }
})

GameData::Evolution.register({
  :id            => :TradeMale,
  :on_trade_proc => proc { |pkmn, parameter, other_pkmn|
    next pkmn.male?
  }
})

GameData::Evolution.register({
  :id            => :TradeFemale,
  :on_trade_proc => proc { |pkmn, parameter, other_pkmn|
    next pkmn.female?
  }
})

GameData::Evolution.register({
  :id            => :TradeDay,
  :on_trade_proc => proc { |pkmn, parameter, other_pkmn|
    next PBDayNight.isDay?
  }
})

GameData::Evolution.register({
  :id            => :TradeNight,
  :on_trade_proc => proc { |pkmn, parameter, other_pkmn|
    next PBDayNight.isNight?
  }
})

GameData::Evolution.register({
  :id                   => :TradeItem,
  :parameter            => :Item,
  :on_trade_proc        => proc { |pkmn, parameter, other_pkmn|
    next pkmn.item == parameter
  },
  :after_evolution_proc => proc { |pkmn, new_species, parameter, evo_species|
    next false if evo_species != new_species || !pkmn.hasItem?(parameter)
    pkmn.item = nil   # Item is now consumed
    next true
  }
})

GameData::Evolution.register({
  :id            => :TradeSpecies,
  :parameter     => :Species,
  :on_trade_proc => proc { |pkmn, parameter, other_pkmn|
    next pkmn.species == parameter && !other_pkmn.hasItem?(:EVERSTONE)
  }
})

#===============================================================================
# Evolution methods that are triggered after any battle
#===============================================================================
GameData::Evolution.register({
  :id                => :BattleDealCriticalHit,
  :parameter         => Integer,
  :after_battle_proc => proc { |pkmn, party_index, parameter|
    next $game_temp.party_critical_hits_dealt &&
         $game_temp.party_critical_hits_dealt[party_index] &&
         $game_temp.party_critical_hits_dealt[party_index] >= parameter
  }
})

#===============================================================================
# Evolution methods that are triggered by an event
# Each event has its own number, which is the value of the parameter as defined
# in pokemon.txt/pokemon_forms.txt. It is also 'number' in def pbEvolutionEvent,
# which triggers evolution checks for a particular event number. 'value' in an
# event_proc is the number of the evolution event currently being triggered.
# Evolutions caused by different events should have different numbers. Used
# event numbers are:
#   1: Kubfu -> Urshifu
#   2: Galarian Yamask -> Runerigus
# These used event numbers are only used in pokemon.txt/pokemon_forms.txt and in
# map events that call pbEvolutionEvent, so they are relatively easy to change
# if you need to (no script changes are required). However, you could just
# ignore them instead if you don't want to use them.
#===============================================================================
def pbEvolutionEvent(number)
  return if !$player
  $player.able_party.each do |pkmn|
    pkmn.trigger_event_evolution(number)
  end
end

GameData::Evolution.register({
  :id         => :Event,
  :parameter  => Integer,
  :event_proc => proc { |pkmn, parameter, value|
    next value == parameter
  }
})

GameData::Evolution.register({
  :id                => :EventAfterDamageTaken,
  :parameter         => Integer,
  :after_battle_proc => proc { |pkmn, party_index, parameter|
    if $game_temp.party_direct_damage_taken &&
       $game_temp.party_direct_damage_taken[party_index] &&
       $game_temp.party_direct_damage_taken[party_index] >= 49
      pkmn.ready_to_evolve = true
    end
    next false
  },
  :event_proc        => proc { |pkmn, parameter, value|
    next value == parameter && pkmn.ready_to_evolve
  }
})
