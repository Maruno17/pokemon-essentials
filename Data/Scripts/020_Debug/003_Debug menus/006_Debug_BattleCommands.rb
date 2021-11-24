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
  "always_show" => true
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
  "always_show" => true
})

GameData::BattleWeather.each { |weather|
  inGameName = weather.name
  BattleDebugMenuCommands.register(_INTL("weather{1}",weather.name),
  {
    "parent" => "setweather",
    "name" => _INTL("{1}",weather.name),
    "description" => _INTL("Set weather to {1}.", inGameName),
    "always_show" => true,
    "effect" => proc { |battle, sprites|
      if weather.id == :None
        battle.field.weather = :None
        battle.field.weatherDuration = 0
        pbMessage("Weather removed.")
        next
      end
      
      visibleSprites = pbFadeOutAndHide(sprites) 
      battle.pbStartWeather(nil, weather.id)
      pbFadeInAndShow(sprites,visibleSprites)
    }
  })
}

BattleDebugMenuCommands.register("setweatherduration", {
  "parent" => "weather",
  "name" => _INTL("Set Duration"),
  "description" => _INTL("Set the duration of weather."),
  "always_show" => true,
  "effect" => proc { |battle|
    weatherduration = battle.field.weatherDuration
    battle.field.weatherDuration = getNumericValue("Set weather duration. -1 makes it so that it never run out.", weatherduration,-1,99)
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
  })

GameData::BattleTerrain.each { |terrain|
  inGameName = terrain.name
  if terrain.id != :None
    inGameName = _INTL("{1} Terrain",terrain.name)
  end
  BattleDebugMenuCommands.register(_INTL("terrain{1}",terrain.name),
  {
    "parent" => "setterrain",
    "name" => _INTL("{1}",terrain.name),
    "description" => _INTL("Set terrain to {1}.", inGameName),
    "always_show" => true,
    "effect" => proc { |battle, sprites|
      if terrain.id == :None
        battle.field.terrain = :None
        battle.field.terrainDuration = 0
        next
      end
      visibleSprites = pbFadeOutAndHide(sprites) 
      battle.pbStartTerrain(nil, terrain.id, false)
      pbFadeInAndShow(sprites,visibleSprites)
    }
  })
}

BattleDebugMenuCommands.register("setterrainduration",
{
  "parent" => "terrain",
  "name" => _INTL("Set Duration"),
  "description" => _INTL("Set the duration of the terrain."),
  "always_show" => true,
  "effect" => proc { |battle|
    terrainDuration = battle.field.terrainDuration
    battle.field.terrainDuration = getNumericValue("Set duration. -1 makes it so that it never run out.", terrainDuration,-1,99)
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
      sprites["right_window"] = SpriteWindow_DebugBattleEffects.new(viewport, battle.field.effects, FIELD_EFFECTS)
      right_window = sprites["right_window"]
      right_window.active = true
      loopHandler = DebugBattle_LoopHandler.new(sprites, right_window, battle.field.effects, @battlers)
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
      sprites["right_window"] = SpriteWindow_DebugBattleMetaData.new(viewport, battle, BATTLE_METADATA)
      right_window = sprites["right_window"]
      right_window.active = true
      loopHandler = DebugBattleMeta_LoopHandler.new(sprites, right_window, battle, @battlers)
      loopHandler.setBattle = battle
      loopHandler.startLoop
      viewport.dispose
    }
  })

def registerBattlerCommands(battle)
  battlers = battle.battlers
  battlers.each_with_index{|battler, index|
    BattleDebugMenuCommands.register(_INTL("battler{1}",index), {
      "parent" => "battlers",
      "name" => _INTL("[{1}] {2}", index, battler.name),
      "description" => _INTL("Change things about {1}.", battler.name),
      "always_show" => true,
    })
    BattleDebugMenuCommands.register(_INTL("hpStatus{1}",index), {
      "parent" => _INTL("battler{1}",index),
      "name" => _INTL("HP & Status"),
      "description" => _INTL("Set HP and Status of {1}.", battler.name),
      "always_show" => true,
    })
    BattleDebugMenuCommands.register(_INTL("setHP{1}",index), {
      "parent" => _INTL("hpStatus{1}",index),
      "name" => _INTL("Set HP"),
      "description" => _INTL("Set HP of {1}.", battler.name),
      "always_show" => true,
      "effect" => proc {
        newHP = getNumericValue("Set HP.",battler.hp,0, battler.totalhp)
        battler.hp = newHP
        battle.scene.pbRefreshOne(battler.index)
      }
    })
    BattleDebugMenuCommands.register(_INTL("setTotalHP{1}",index), {
      "parent" => _INTL("hpStatus{1}",index),
      "name" => _INTL("Set Total HP"),
      "description" => _INTL("Set total HP of {1}.", battler.name),
      "always_show" => true,
      "effect" => proc {
        newHP = getNumericValue("Set total HP.",battler.totalhp,1,999)
        battler.totalhp = newHP
        if battler.hp > battler.totalhp
          battler.hp = battler.totalhp
        end
        battle.scene.pbRefreshOne(battler.index)
      }
    })
    BattleDebugMenuCommands.register(_INTL("setStatus{1}",index), {
      "parent" => _INTL("hpStatus{1}",index),
      "name" => _INTL("Set Status"),
      "description" => _INTL("Set Status of {1}.", battler.name),
      "always_show" => true
    })

    GameData::Status.each{ |status|
      BattleDebugMenuCommands.register(_INTL("{1}{2}",status.name,index), {
        "parent" => _INTL("setStatus{1}",index),
        "name" => _INTL("{1}",status.name),
        "description" => _INTL("Set status condition to {1}.", status.name),
        "always_show" => true,
        "effect" => proc { |battle, sprites|
          if status.id == :None
            battler.pbCureStatus
            pbMessage("Status condition removed.")
            next
          end
          newStatusCount = 0
          if status.id == :SLEEP
            newStatusCount = getNumericValue("Set the Pokémon's sleep count.",3,0,99)
          end
          visibleSprites = pbFadeOutAndHide(sprites)
          battler.pbInflictStatus(status.id,newStatusCount)
          pbFadeInAndShow(sprites,visibleSprites)
        }
      })
      if status.id == :POISON
        BattleDebugMenuCommands.register(_INTL("Toxic{1}", index), {
        "parent" => _INTL("setStatus{1}",index),
        "name" => _INTL("Toxic"),
        "description" => _INTL("Set status condition to Toxic.", status.name),
        "always_show" => true,
        "effect" => proc {|battle, sprites|
          toxicCount = 1
          toxicCount = getNumericValue("Set the Pokémon's toxic count.",1,1,99)
          visibleSprites = pbFadeOutAndHide(sprites)
          battler.pbInflictStatus(:POISON,toxicCount)
          battler.effects[PBEffects::Toxic] = toxicCount
          pbFadeInAndShow(sprites,visibleSprites)
        }
      })
      end
    }

    BattleDebugMenuCommands.register(_INTL("heal{1}",index), {
      "parent" => _INTL("hpStatus{1}",index),
      "name" => _INTL("Fully Heal"),
      "description" => _INTL("Fully heal HP and Status of {1}.", battler.name),
      "always_show" => true,
      "effect" => proc { |battle, sprites|
        visibleSprites = pbFadeOutAndHide(sprites) 
        battler.pbCureStatus(false)
        pokemon = battler.pokemon
        pbBattleHPItem(pokemon,battler,battler.totalhp,@scene)
        battle.pbDisplay(_INTL("{1} was fully healed!", battler.name))
        pbFadeInAndShow(sprites,visibleSprites)
      }
    })
    BattleDebugMenuCommands.register(_INTL("level{1}",index), {
      "parent" => _INTL("battler{1}",index),
      "name" => _INTL("Level"),
      "description" => _INTL("Change the level of {1} permanently.", battler.name),
      "always_show" => true,
      "effect" => proc { |battle, sprites|
        visibleSprites = pbFadeOutAndHide(sprites) 
        newLevel = getNumericValue("Set Level",battler.level,1,Settings::MAXIMUM_LEVEL)
        if newLevel == battler.level
          pbFadeInAndShow(sprites,visibleSprites)
          next
        end
        battler.pokemon.level = newLevel
        battler.pbUpdate(false)
        battle.scene.pbRefreshOne(battler.index)
       
        pkmn = battler.pokemon
        party = self.pbParty(battler)
        idxParty = party.index(battler.pokemon)
        curLevel = battler.level
        moveList = pkmn.getMoveList
        moveList.each { |m| pbLearnMove(idxParty,m[1]) if m[0]==curLevel }
        pbFadeInAndShow(sprites,visibleSprites)
      }
    })
    BattleDebugMenuCommands.register(_INTL("abillity{1}",index), {
      "parent" => _INTL("battler{1}",index),
      "name" => _INTL("Abillity"),
      "description" => _INTL("Change the abillity of {1} and trigger it.", battler.name),
      "always_show" => true,
    })

    BattleDebugMenuCommands.register(_INTL("setAbillity{1}",index), {
      "parent" => _INTL("abillity{1}",index),
      "name" => _INTL("Set Abillity"),
      "description" => _INTL("Set any abillity for {1}.", battler.name),
      "always_show" => true,
      "effect" => proc {
        newAbility = pbChooseAbilityList(battler.ability_id)
        battler.ability = newAbility
      }
    })
    BattleDebugMenuCommands.register(_INTL("triggerAbillity{1}",index), {
      "parent" => _INTL("abillity{1}",index),
      "name" => _INTL("Trigger Abillity"),
      "description" => _INTL("Trigger abillity of {1}, if possible.", battler.name),
      "always_show" => true,
      "effect" => proc { |battle, sprites|
        visibleSprites = pbFadeOutAndHide(sprites)
        ability = battler.ability
        BattleHandlers.triggerAbilityOnSwitchIn(ability,battler,battle)
        BattleHandlers.triggerStatusCureAbility(ability,battler)
        BattleHandlers.triggerAbilityOnFlinch(ability,battler,battle)
        BattleHandlers.triggerEORHealingAbility(ability,battler,battle)
        BattleHandlers.triggerEOREffectAbility(ability,battler,battle)
        pbFadeInAndShow(sprites,visibleSprites)
      }
    })

    BattleDebugMenuCommands.register(_INTL("moves{1}",index), {
      "parent" => _INTL("battler{1}",index),
      "name" => _INTL("Moves"),
      "description" => _INTL("Set {1}'s moves.", battler.name),
      "always_show" => true,
      "effect" => proc {
        moveIdx = 0
        moveAction = 0
        loop do
          moveCommands = generateMoveCommands(battler)
          moveIdx = pbChooseList(moveCommands,moveIdx,-1,0)
          break if moveIdx < 0
          if moveIdx == 4 
            battler.moves.each{ |move| 
              move.pp = 0
            }
            next
          end
          
          if moveIdx == 5
            battler.moves.each{ |move| 
              move.pp = move.total_pp
            }
            next
          end
          
          moveAction = pbChooseList(generateMoveActionCommands,moveAction,-1,0)
          next if moveAction < 0
          move = battler.moves[moveIdx]
          case moveAction
            when 0
              newMove = pbChooseMoveList
              next if !newMove
              battler.moves[moveIdx] = PokeBattle_Move.from_pokemon_move(battle,Pokemon::Move.new(newMove))
            when 1
              newPP = getNumericValue("Set PP",move.pp,0,move.total_pp, false)
              move.pp = newPP
            when 2
              battler.moves[moveIdx] = nil
              battler.moves.compact!
              
          
          end
        end
      }
    })
    BattleDebugMenuCommands.register(_INTL("item{1}",index), {
      "parent" => _INTL("battler{1}",index),
      "name" => _INTL("Item"),
      "description" => _INTL("Modify {1}'s held item", battler.name),
      "always_show" => true,
     
    })
    BattleDebugMenuCommands.register(_INTL("giveItem{1}",index), {
      "parent" => _INTL("item{1}",index),
      "name" => _INTL("Give Item"),
      "description" => _INTL("Set {1}'s held item", battler.name),
      "always_show" => true,
       "effect" => proc { |battle, sprites|
        pbListScreenBlock(_INTL("GIVE ITEM"),ItemLister.new(0)){|button,item|
        if button==Input::USE && item
          battler.item = item
          pbMessage(_INTL("{1} is now holding {2}!",battler.name,GameData::Item.get(item).name))
        end
        }
      }
    })
    BattleDebugMenuCommands.register(_INTL("removeItem{1}",index), {
      "parent" => _INTL("item{1}",index),
      "name" => _INTL("Remove Item"),
      "description" => _INTL("Remove {1}'s held item", battler.name),
      "always_show" => true,
       "effect" => proc { 
        oldItem = battler.item
        battler.item = 0
        pbMessage(_INTL("{1} was removed!",GameData::Item.get(oldItem).name))
      }
    })
    BattleDebugMenuCommands.register(_INTL("type{1}",index), {
      "parent" => _INTL("battler{1}",index),
      "name" => _INTL("Type"),
      "description" => _INTL("Change the typing of {1}.", battler.name),
      "always_show" => true,
      "effect" => proc {
        typeToChange = 0
        loop do
          typeCommands = generateTypeCommands(battler)
          typeToChange = pbChooseList(typeCommands,typeToChange,-1,0)
          break if typeToChange <= 0
          newType = pbChooseTypeList
          next if !newType
          
          case typeToChange
            when 1
              battler.type1 = newType
            when 2
              battler.type2 = newType
            when 3
              battler.effects[PBEffects::Type3] = newType
          end
        end
      }
    })
    BattleDebugMenuCommands.register(_INTL("stats{1}",index), {
      "parent" => _INTL("battler{1}",index),
      "name" => _INTL("Stat Changes"),
      "description" => _INTL("Set Stat Changes of {1}.", battler.name),
      "always_show" => true,
      "effect" => proc {
        viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
        viewport.z = 99999
        sprites = {}
        sprites["right_window"] = SpriteWindow_DebugStatChanges.new(viewport,battler,BATTLE_STATS)
        right_window = sprites["right_window"]
        right_window.toggleSortMode
        right_window.active   = true
        loopHandler = DebugBattle_LoopHandler.new(sprites,right_window,battler.stages,@battlers,nil,-6,6,false)
        loopHandler.startLoop
        viewport.dispose
      }
    })
    BattleDebugMenuCommands.register(_INTL("effects{1}",index), {
      "parent" => _INTL("battler{1}",index),
      "name" => _INTL("Battler Effects"),
      "description" => _INTL("Set effects that apply to {1}.", battler.name),
      "always_show" => true,
      "effect" => proc {
        viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
        viewport.z = 99999
        sprites = {}
        sprites["right_window"] = SpriteWindow_DebugBattleEffects.new(viewport,battler.effects,BATTLER_EFFECTS,battlers)
        right_window = sprites["right_window"]
        right_window.active   = true
        loopHandler = DebugBattle_LoopHandler.new(sprites,right_window,battler.effects,@battlers,battler)
        loopHandler.startLoop
        viewport.dispose
      }
    })
    BattleDebugMenuCommands.register(_INTL("summary{1}",index), {
      "parent" => _INTL("battler{1}",index),
      "name" => _INTL("Summary"),
      "description" => _INTL("View summary of {1}.", battler.name),
      "always_show" => true,
      "effect" => proc {
        pokemon = fakePokemonForSummary(battler)
        party = self.pbParty(battler)
        partyIdx  = party.index(battler.pokemon)
        party[partyIdx] = pokemon
        scene = PokemonSummary_Scene.new
        screen = PokemonSummaryScreen.new(scene,true)
        screen.pbStartScreen(party,partyIdx)
        party[partyIdx] = battler.pokemon
      }
    })
  }
end
