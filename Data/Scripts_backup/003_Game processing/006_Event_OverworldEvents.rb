#===============================================================================
# This module stores events that can happen during the game. A procedure can
# subscribe to an event by adding itself to the event. It will then be called
# whenever the event occurs.
#===============================================================================
module Events
  @@OnMapCreate                 = Event.new
  @@OnMapUpdate                 = Event.new
  @@OnMapChange                 = Event.new
  @@OnMapChanging               = Event.new
  @@OnMapSceneChange            = Event.new
  @@OnSpritesetCreate           = Event.new
  @@OnAction                    = Event.new
  @@OnStepTaken                 = Event.new
  @@OnLeaveTile                 = Event.new
  @@OnStepTakenFieldMovement    = Event.new
  @@OnStepTakenTransferPossible = Event.new
  @@OnStartBattle               = Event.new
  @@OnEndBattle                 = Event.new
  @@OnWildPokemonCreate         = Event.new
  @@OnWildBattleOverride        = Event.new
  @@OnWildBattleEnd             = Event.new
  @@OnTrainerPartyLoad          = Event.new
  @@OnChangeDirection           = Event.new

  # Fires whenever a map is created. Event handler receives two parameters: the
  # map (RPG::Map) and the tileset (RPG::Tileset)
  def self.onMapCreate;     @@OnMapCreate;     end
  def self.onMapCreate=(v); @@OnMapCreate = v; end

  # Fires each frame during a map update.
  def self.onMapUpdate;     @@OnMapUpdate;     end
  def self.onMapUpdate=(v); @@OnMapUpdate = v; end

  # Fires whenever one map is about to change to a different one. Event handler
  # receives the new map ID and the Game_Map object representing the new map.
  # When the event handler is called, $game_map still refers to the old map.
  def self.onMapChanging;     @@OnMapChanging;     end
  def self.onMapChanging=(v); @@OnMapChanging = v; end

  # Fires whenever the player moves to a new map. Event handler receives the old
  # map ID or 0 if none. Also fires when the first map of the game is loaded
  def self.onMapChange;     @@OnMapChange;     end
  def self.onMapChange=(v); @@OnMapChange = v; end

  # Fires whenever the map scene is regenerated and soon after the player moves
  # to a new map.
  # Parameters:
  # e[0] - Scene_Map object.
  # e[1] - Whether the player just moved to a new map (either true or false). If
  #        false, some other code had called $scene.createSpritesets to
  #        regenerate the map scene without transferring the player elsewhere
  def self.onMapSceneChange;     @@OnMapSceneChange;     end
  def self.onMapSceneChange=(v); @@OnMapSceneChange = v; end

  # Fires whenever a spriteset is created.
  # Parameters:
  # e[0] - Spriteset being created. e[0].map is the map associated with the
  #        spriteset (not necessarily the current map).
  # e[1] - Viewport used for tilemap and characters
  def self.onSpritesetCreate;     @@OnSpritesetCreate;     end
  def self.onSpritesetCreate=(v); @@OnSpritesetCreate = v; end

  # Triggers when the player presses the Action button on the map.
  def self.onAction;     @@OnAction;     end
  def self.onAction=(v); @@OnAction = v; end

  # Fires whenever the player takes a step.
  def self.onStepTaken;     @@OnStepTaken;     end
  def self.onStepTaken=(v); @@OnStepTaken = v; end

  # Fires whenever the player or another event leaves a tile.
  # Parameters:
  # e[0] - Event that just left the tile.
  # e[1] - Map ID where the tile is located (not necessarily
  #        the current map). Use "$MapFactory.getMap(e[1])" to
  #        get the Game_Map object corresponding to that map.
  # e[2] - X-coordinate of the tile
  # e[3] - Y-coordinate of the tile
  def self.onLeaveTile;     @@OnLeaveTile;     end
  def self.onLeaveTile=(v); @@OnLeaveTile = v; end

  # Fires whenever the player or another event enters a tile.
  # Parameters:
  # e[0] - Event that just entered a tile.
  def self.onStepTakenFieldMovement;     @@OnStepTakenFieldMovement;     end
  def self.onStepTakenFieldMovement=(v); @@OnStepTakenFieldMovement = v; end

  # Fires whenever the player takes a step. The event handler may possibly move
  # the player elsewhere.
  # Parameters:
  # e[0] - Array that contains a single boolean value. If an event handler moves
  #        the player to a new map, it should set this value to true. Other
  #        event handlers should check this parameter's value.
  def self.onStepTakenTransferPossible;     @@OnStepTakenTransferPossible;     end
  def self.onStepTakenTransferPossible=(v); @@OnStepTakenTransferPossible = v; end

  def self.onStartBattle;     @@OnStartBattle;     end
  def self.onStartBattle=(v); @@OnStartBattle = v; end

  def self.onEndBattle;     @@OnEndBattle;     end
  def self.onEndBattle=(v); @@OnEndBattle = v; end

  # Triggers whenever a wild Pokémon is created
  # Parameters:
  # e[0] - Pokémon being created
  def self.onWildPokemonCreate;     @@OnWildPokemonCreate;     end
  def self.onWildPokemonCreate=(v); @@OnWildPokemonCreate = v; end

  # Triggers at the start of a wild battle.  Event handlers can provide their
  # own wild battle routines to override the default behavior.
  def self.onWildBattleOverride;     @@OnWildBattleOverride;     end
  def self.onWildBattleOverride=(v); @@OnWildBattleOverride = v; end

  # Triggers whenever a wild Pokémon battle ends
  # Parameters:
  # e[0] - Pokémon species
  # e[1] - Pokémon level
  # e[2] - Battle result (1-win, 2-loss, 3-escaped, 4-caught, 5-draw)
  def self.onWildBattleEnd;     @@OnWildBattleEnd;     end
  def self.onWildBattleEnd=(v); @@OnWildBattleEnd = v; end

  # Triggers whenever an NPC trainer's Pokémon party is loaded
  # Parameters:
  # e[0] - Trainer
  # e[1] - Items possessed by the trainer
  # e[2] - Party
  def self.onTrainerPartyLoad;     @@OnTrainerPartyLoad;     end
  def self.onTrainerPartyLoad=(v); @@OnTrainerPartyLoad = v; end

  # Fires whenever the player changes direction.
  def self.onChangeDirection;     @@OnChangeDirection;     end
  def self.onChangeDirection=(v); @@OnChangeDirection = v; end
end

#===============================================================================
#
#===============================================================================
def pbOnSpritesetCreate(spriteset,viewport)
  Events.onSpritesetCreate.trigger(nil,spriteset,viewport)
end

#===============================================================================
# This module stores encounter-modifying events that can happen during the game.
# A procedure can subscribe to an event by adding itself to the event. It will
# then be called whenever the event occurs.
#===============================================================================
module EncounterModifier
  @@procs    = []
  @@procsEnd = []

  def self.register(p)
    @@procs.push(p)
  end

  def self.registerEncounterEnd(p)
    @@procsEnd.push(p)
  end

  def self.trigger(encounter)
    for prc in @@procs
      encounter = prc.call(encounter)
    end
    return encounter
  end

  def self.triggerEncounterEnd()
    for prc in @@procsEnd
      prc.call()
    end
  end
end
