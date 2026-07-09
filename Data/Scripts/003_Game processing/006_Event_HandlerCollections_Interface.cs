using System;
using System.Collections;
using System.Collections.Generic;
using PokemonEssentials.RPGMaker;
using PokemonEssentials.RPGMaker.Kernel;
using PokemonEssentials.EventArg;

namespace PokemonEssentials
{
	/// <summary>
	/// This module stores events that can happen during the game. A procedure can
	/// subscribe to an event by adding itself to the event. It will then be called
	/// whenever the event occurs.
	/// </summary>
	/// <remarks>
	/// Uses Action<object, IEventArgs> instead of EventHandler<T> for backward compatibility
	/// with .NET versions before 4.5, as interfaces cannot inherit from EventArgs.
	/// </remarks>
	/// <seealso href="https://stackoverflow.com/a/47323956/3681384">Stack Overflow</seealso>
	public interface IEvents //ToDo: Rename to `IEventHandler`?
	{
		#region EventHandlers
		//===============================================================================
		/// <summary>
		/// Fires whenever a map is created. Event handler receives two parameters: the
		/// map (RPG.Map) and the tileset (RPG.Tileset)
		/// </summary>
		/// <remarks>
		/// When a <see cref="IGameMap"/> is set up. Typically changes map data.
		/// </remarks>
		//event Action<object, IOnMapSetupEventArgs> OnGameMapSetup;
		event EventHandler OnMapCreate; //ToDo: Change to Action<object, IOnMapSetupEventArgs> OnGameMapSetup; and implement IOnMapSetupEventArgs
		/// <summary>
		/// Fires whenever a spriteset is created.
		/// </summary>
		/// <remarks>
		/// When a <see cref="ISpritesetMap"/> is created. Adds more things to
		/// show in the overworld.
		/// </remarks>
		//event Action<object, IOnSpritesetCreateEventArgs> OnNewSpritesetMap;
		//event EventHandler<IOnSpritesetCreateEventArgs> OnSpritesetCreate;
		event Action<object, IOnSpritesetCreateEventArgs> OnSpritesetCreate;
		/// <summary>
		/// Once per frame. Various frame/time counters.
		/// </summary>
		event EventHandler OnFrameUpdate;
		/// <summary>
		/// When leaving a map. End weather/expired effects.
		/// </summary>
		//event Action<object, IOnMapEventArgs> OnLeaveMap;
		event Action<object, IOnMapChangingEventArgs> OnLeaveMap;
		/// <summary>
		/// Upon entering a new map. Set up new effects, end expired
		/// effects.
		/// </summary>
		//event Action<object, IOnMapEventArgs> OnEnterMap;
		event Action<object, IOnMapChangingEventArgs> OnEnterMap;
		/// <summary>
		/// Upon entering a new map or when spriteset was
		/// made. Show things on-screen.
		/// </summary>
		/// <seealso cref="OnMapSceneChange"/>
		//event Action<object, IMapOrSpritesetChangeEventArgs> OnMapOrSpritesetChange;
		event Action<object, IOnMapSceneChangeEventArgs> OnMapOrSpritesetChange;
		//-------------------------------------------------------------------------------
		/// <summary>
		/// When the player turns in a different direction.
		/// </summary>
		/// <seealso cref="OnStepTaken"/>
		//event Action<object, IPlayerDirectionEventArgs> OnPlayerChangeDirection;
		event Action<object, IOnStepTakenFieldMovementEventArgs> OnPlayerChangeDirection;
		/// <summary>
		/// When any event or the player starts to move from a tile.
		/// </summary>
		/// <remarks>
		/// Fires whenever the player or another event leaves a tile.
		/// </remarks>
		//event EventHandler<IOnLeaveTileEventArgs> OnLeaveTile;
		//event Action<object, ILeaveTileEventArgs> OnLeaveTile;
		event Action<object, IOnLeaveTileEventArgs> OnLeaveTile;
		/// <summary>
		/// Fires whenever the player takes a step.
		/// </summary>
		/// <remarks>
		/// When any event or the player finishes a step.
		/// </remarks>
		//event EventHandler OnStepTaken;
		//event Action<object, IOnStepTakenEventArgs> OnStepTaken;
		event Action<object, IOnStepTakenFieldMovementEventArgs> OnStepTaken;
		/// <summary>
		/// When the player finishes a step/ends surfing, except
		/// as part of a move route. Step-based counters.
		/// </summary>
		/// <seealso cref="OnStepTaken"/>
		//event Action<object, IOnStepTakenEventArgs> OnPlayerStepTaken;
		event Action<object, IOnStepTakenFieldMovementEventArgs> OnPlayerStepTaken;
		/// <summary>
		/// When the player finishes a step/ends
		/// surfing, except as part of a move route. Step-based effects that can
		/// transfer the player elsewhere.
		/// </summary>
		event Action<object, IOnStepTakenTransferPossibleEventArgs> OnPlayerStepTakenCanTransfer;
		/// <summary>
		/// Triggers when the player presses the Action button on the map.
		/// </summary>
		/// <remarks>
		/// When the player presses the Use button in the
		/// overworld.
		/// </remarks>
		//event Action<object, IOnPlayerInteractEventArgs> OnPlayerInteract;
		event EventHandler OnAction;
		//-------------------------------------------------------------------------------
		/// <summary>
		/// When an <see cref="INPCTrainer"/> is generated (to battle against or as
		/// a registered partner). Various modifications to that trainer and their
		/// Pokémon.
		/// </summary>
		//event Action<object, IOnTrainerLoadEventArgs> OnTrainerLoad;
		event Action<object, IOnTrainerPartyLoadEventArgs> OnTrainerLoad;
		/// <summary>
		/// When a species/level have been chosen for a wild
		/// encounter. Changes the species/level (e.g. roamer, Poké Radar chain).
		/// </summary>
		/// <seealso cref="OnWildPokemonCreate"/>
		//event Action<object, IOnWildSpeciesChosenEventArgs> OnWildSpeciesChosen;
		event Action<object, IOnWildPokemonCreateEventArgs> OnWildSpeciesChosen;
		/// <summary>
		/// When a Pokemon object has been created for a wild
		/// encounter. Various modifications to that Pokémon.
		/// </summary>
		/// <seealso cref="OnWildPokemonCreate"/>
		event Action<object, IOnWildPokemonCreateEventArgs> OnWildPokemonCreated;
		/// <summary>
		/// When a wild battle is called. Prevents that wild
		/// battle and instead starts a different kind of battle (e.g. Safari Zone).
		/// </summary>
		event Action<object, IOnWildBattleOverrideEventArgs> OnCallingWildBattle;
		/// <summary>
		/// Just before a battle starts. Memorize/reset information
		/// about party Pokémon, which is used after battle for evolution checks.
		/// </summary>
		//event Action<object, IBattleStartEventArgs> OnStartBattle;
		event EventHandler OnStartBattle;
		/// <summary>
		/// Just after a battle ends. Evolution checks, Pickup/Honey
		/// Gather, blacking out.
		/// </summary>
		//event EventHandler OnEndBattle;
		//event Action<object, IEndBattleEventArgs> OnEndBattle;
		event Action<object, IOnEndBattleEventArgs> OnEndBattle;
		/// <summary>
		/// Triggers whenever a wild Pokémon battle ends
		/// </summary>
		/// <remarks>
		/// After a wild battle. Updates Poké Radar chain info.
		/// </remarks>
		//event EventHandler<IOnWildBattleEndEventArgs> OnWildBattleEnd;
		//event Action<object, IWildBattleEndEventArgs> OnWildBattleEnd;
		event Action<object, IOnWildBattleEndEventArgs> OnWildBattleEnd;
		//===============================================================================
		/// <summary>
		/// Fires whenever the player moves to a new map. Event handler receives the old
		/// map ID or 0 if none.  Also fires when the first map of the game is loaded
		/// </summary>
		/// <seealso cref="OnMapChanging"/>
		event EventHandler OnMapChange; //ToDo: Remove this event and use OnMapChanging instead
		/// <summary>
		/// Fires whenever the map scene is regenerated and soon after the player moves
		/// to a new map.
		/// </summary>
		//event EventHandler<IOnMapSceneChangeEventArgs> OnMapSceneChange;
		event Action<object, IOnMapSceneChangeEventArgs> OnMapSceneChange;
		/// <summary>
		/// Fires each frame during a map update.
		/// </summary>
		event EventHandler OnMapUpdate;
		/// <summary>
		/// Fires whenever one map is about to change to a different one. Event handler
		/// receives the new map ID and the <see cref="IGameMap"/> object representing the new map.
		/// When the event handler is called, <see cref="Game.GameData.GameMap"/> still refers to the old map.
		/// </summary>
		event Action<object, IOnMapChangingEventArgs> OnMapChanging;
		/// <summary>
		/// Fires whenever the player takes a step. The event handler may possibly move
		/// the player elsewhere.
		/// </summary>
		//event EventHandler<IOnStepTakenTransferPossibleEventArgs> OnStepTakenTransferPossible;
		event Action<object, IOnStepTakenTransferPossibleEventArgs> OnStepTakenTransferPossible;
		/// <summary>
		/// Fires whenever the player or another event enters a tile.
		/// </summary>
		//event EventHandler<IOnStepTakenFieldMovementEventArgs> OnStepTakenFieldMovement;
		event Action<object, IOnStepTakenFieldMovementEventArgs> OnStepTakenFieldMovement;
		/// <summary>
		/// Triggers at the start of a wild battle. Event handlers can provide their own
		/// wild battle routines to override the default behavior.
		/// </summary>
		//event EventHandler<IOnWildBattleOverrideEventArgs> OnWildBattleOverride;
		event Action<object, IOnWildBattleOverrideEventArgs> OnWildBattleOverride;
		/// <summary>
		/// Triggers whenever a wild Pokémon is created
		/// </summary>
		/// <seealso cref="IEncounters.OnWildPokemonCreate"/>
		//event EventHandler<IOnWildPokemonCreateEventArgs> OnWildPokemonCreate;
		event Action<object, IOnWildPokemonCreateEventArgs> OnWildPokemonCreate;
		/// <summary>
		/// Triggers whenever an NPC trainer's Pokémon party is loaded
		/// </summary>
		/// <seealso cref="OnTrainerLoad"/>
		/// <seealso cref="IEncounters.OnTrainerPartyLoad"/>
		//event EventHandler<IOnTrainerPartyLoadEventArgs> OnTrainerPartyLoad;
		event Action<object, IOnTrainerPartyLoadEventArgs> OnTrainerPartyLoad;
		#endregion

		#region Event Sender / Raise Events
		void OnMapCreateTrigger();
		void OnMapChangeTrigger();
		void OnMapChangingTrigger();
		/// <summary>
		/// Parameters:
		/// e[0] - Event that just left the tile.
		/// e[1] - Map ID where the tile is located (not necessarily
		///  the current map). Use "Game.GameData.MapFactory.getMap(e[1])" to
		///  get the Game_Map object corresponding to that map.
		/// e[2] - X-coordinate of the tile
		/// e[3] - Y-coordinate of the tile
		/// </summary>
		//void OnLeaveTileTrigger(object @event, int mapId, IVector tile);
		void OnLeaveTileTrigger(IGameCharacter @event, int mapId, float x, float y, float z);
		/// <summary>
		/// Parameters:
		/// e[0] - Event that just entered a tile.
		/// </summary>
		void OnStepTakenFieldMovementTrigger();
		/// <summary>
		/// Parameters:
		/// e[0] = Array that contains a single boolean value.
		/// If an event handler moves the player to a new map, it should set this value
		/// to true. Other event handlers should check this parameter's value.
		/// </summary>
		void OnStepTakenTransferPossibleTrigger();
		/// <summary>
		/// Parameters:
		/// e[0] - Pokémon species
		/// e[1] - Pokémon level
		/// e[2] - Battle result (1-win, 2-loss, 3-escaped, 4-caught, 5-draw)
		/// </summary>
		void OnWildBattleOverrideTrigger(int species,int level,int handled); //object @event,
		/// <summary>
		/// Parameters:
		/// e[0] - Pokémon species
		/// e[1] - Pokémon level
		/// e[2] - Battle result (1-win, 2-loss, 3-escaped, 4-caught, 5-draw)
		/// </summary>
		void OnWildBattleEndTrigger();
		/// <summary>
		/// Parameters:
		/// e[0] - Pokémon being created
		/// </summary>
		/// <remarks><seealso cref="OnWildPokemonCreate"/></remarks>
		void OnWildPokemonCreateTrigger();
		/// <summary>
		/// Parameters:
		/// e[0] - Trainer
		/// e[1] - Items possessed by the trainer
		/// e[2] - Party
		/// </summary>
		/// <remarks><seealso cref="OnTrainerPartyLoad"/></remarks>
		void OnTrainerPartyLoadTrigger();
		/// <summary>
		/// Parameters:
		/// e[0] = Scene_Map object.
		/// e[1] = Whether the player just moved to a new map (either true or false). If
		///   false, some other code had called <see cref="Game.GameData.Scene.createSpritesets"/>
		///   to regenerate the map scene without transferring the player elsewhere
		/// </summary>
		void OnMapSceneChangeTrigger();
		/// <summary>
		/// Parameters:
		/// e[0] = Spriteset being created
		/// e[1] = Viewport used for tilemap and characters
		/// e[0].map = Map associated with the spriteset (not necessarily the current map).
		/// </summary>
		void OnSpritesetCreateTrigger();
		#endregion
	}

	//===============================================================================
	//===============================================================================
	/// <summary>
	/// This module stores the contents of various menus. Each command in a menu is a
	/// hash of data (containing its name, relative order, code to run when chosen,
	/// etc.).
	/// </summary>
	/// <remarks>
	/// <list type="bullet">
	/// <term>
	/// Menus that use this module are:
	/// </term>
	///-------------------------------------------------------------------------------
	/// <item>
	/// <term>
	/// Pause menu
	/// </term>
	/// <description/>
	/// </item>
	/// </list>
	/// Party screen main interact menu
	/// Pokégear main menu
	/// Options screen
	/// PC main menu
	/// Various debug menus (main, Pokémon, battle, battle Pokémon)
	/// </remarks>
	public interface IMenuContent
	{
		/// <summary>
		/// Gets the display name of the menu content.
		/// </summary>
		string Name { get; }
		/// <summary>
		/// Gets the display order of the menu content.
		/// </summary>
		int Order { get; }
		//Predicate<> Condition { get; }

		/// <summary>
		/// Determines whether this menu content should be displayed.
		/// </summary>
		/// <returns>True if the menu content should be displayed; otherwise, false.</returns>
		bool Condition();
		/// <summary>
		/// Executes the effect of this menu content when selected.
		/// </summary>
		/// <returns>True if the effect was executed successfully; otherwise, false.</returns>
		bool Effect();
	}

	namespace EventArg
	{
		public interface IEventCanFail : IEventArgs
		{
			bool IsSuccess { get; }
		}

		#region Global Overworld EventArgs
		public interface IOnMapCreateEventArgs : IEventArgs
		{
			//readonly int EventId = typeof(OnMapCreateEventArgs).GetHashCode();

			//int Id { get { return EventId; } }
			//int Id { get { return Pokemon.GetHashCode(); } } //EventId;
			int Map { get; set; }
			ITileset Tileset { get; set; }
		}
		public interface IOnMapChangeEventArgs : IEventArgs
		{
			//readonly int EventId = typeof(OnMapChangeEventArgs).GetHashCode();

			//int Id { get { return EventId; } }
			//int Id { get { return MapId.GetHashCode(); } } //EventId;
			int MapId { get; set; }
		}
		public interface IOnMapChangingEventArgs : IEventArgs
		{
			//readonly int EventId = typeof(OnMapChangingEventArgs).GetHashCode();

			//int Id { get { return EventId; } }
			//int Id { get { return MapId.GetHashCode(); } } //EventId;
			int MapId { get; set; }
			IGameMap GameMap { get; set; }
		}
		/// <summary>
		/// Parameters:
		/// e[0] - Event that just left the tile.
		/// e[1] - Map ID where the tile is located (not necessarily the current map).
		///  Use <see cref="IMapFactory.getMap(int)"/> with <see cref="IGame.MapFactory"/>
		///  to get the <see cref="IGameMap"/> corresponding to that map.
		/// e[2] - X-coordinate of the tile
		/// e[3] - Y-coordinate of the tile
		/// </summary>
		/// <remarks>
		/// Use "Game.GameData.MapFactory.getMap(e[1])" to
		/// get the Game_Map object corresponding to that map.
		/// </remarks>
		public interface IOnLeaveTileEventArgs : IEventArgs
		{
			//readonly int EventId = typeof(OnLeaveTileEventArgs).GetHashCode();

			//int Id { get { return EventId; } }
			/// <summary>
			/// Event that just left the tile.
			/// </summary>
			IGameEvent Event { get; set; }
			/// <summary>
			/// Map ID where the tile is located (not necessarily
			///  the current map). Use "Game.GameData.MapFactory.getMap(e[1])" to
			///  get the <see cref="IGameMap"/> object corresponding to that map.
			/// </summary>
			int MapId { get; set; }
			/// <summary>
			/// X-coordinate of the tile
			/// </summary>
			int X { get; set; }
			/// <summary>
			/// Y-coordinate of the tile
			/// </summary>
			int Y { get; set; }
		}
		/// <summary>
		/// Parameters:
		/// e[0] - Event that just entered a tile.
		/// </summary>
		public interface IOnStepTakenFieldMovementEventArgs : IEventArgs
		{
			//readonly int EventId = typeof(OnStepTakenFieldMovementEventArgs).GetHashCode();

			//int Id { get { return EventId; } }
			/// <summary>
			/// Event that just entered a tile.
			/// </summary>
			//int Index { get; set; }
			IGamePlayer Index { get; set; }
		}
		/// <summary>
		/// Parameters:
		/// e[0] = Array that contains a single boolean value.
		/// If an event handler moves the player to a new map, it should set this value
		/// to true. Other event handlers should check this parameter's value.
		/// </summary>
		public interface IOnStepTakenTransferPossibleEventArgs : IEventArgs
		{
			//readonly int EventId = typeof(OnStepTakenTransferPossibleEventArgs).GetHashCode();

			//int Id { get { return EventId; } }
			/// <summary>
			/// Array that contains a single boolean value.
			/// </summary>
			bool Index { get; set; }
		}
		/// <summary>
		/// Parameters:
		/// e[0] - Pokémon species
		/// e[1] - Pokémon level
		/// e[2] - Battle result (1-win, 2-loss, 3-escaped, 4-caught, 5-draw)
		/// </summary>
		public interface IOnWildBattleOverrideEventArgs : IEventArgs
		{
			//static readonly int EventId = typeof(OnWildBattleOverrideEventArgs).GetHashCode();

			//int Id { get { return EventId; } }
			//Pokemons Species { get; set; }
			int Species { get; set; }
			int Level { get; set; }
			/// <summary>
			/// Battle result (1-win, 2-loss, 3-escaped, 4-caught, 5-draw)
			/// </summary>
			//BattleResults? Result { get; set; }
			int? Result { get; set; }
		}
		/// <summary>
		/// Parameters:
		/// e[0] - Pokémon species
		/// e[1] - Pokémon level
		/// e[2] - Battle result (1-win, 2-loss, 3-escaped, 4-caught, 5-draw)
		/// </summary>
		public interface IOnWildBattleEndEventArgs : IEventArgs
		{
			//readonly int EventId = typeof(OnWildBattleEndEventArgs).GetHashCode();

			//int Id { get { return EventId; } }
			//Pokemons Species { get; set; }
			int Species { get; set; }
			int Level { get; set; }
			/// <summary>
			/// Battle result (1-win, 2-loss, 3-escaped, 4-caught, 5-draw)
			/// </summary>
			//BattleResults Result { get; set; }
			int Result { get; set; }
		}
		/// <summary>
		/// Parameters:
		/// e[0] - Pokémon being created
		/// </summary>
		public interface IOnWildPokemonCreateEventArgs : IEventArgs
		{
			//readonly int EventId = typeof(OnWildPokemonCreateEventArgs).GetHashCode();

			//int Id { get; }
			/// <summary>
			/// Pokémon being created
			/// </summary>
			IPokemon Pokemon { get; set; }
		}
		/// <summary>
		/// Parameters: int decision
		/// e[0] - Battle result (1-win, 2-loss, 3-escaped, 4-caught, 5-draw)
		/// e[1] - If allowed to be defeated, or is stuck in a battle loop until Win
		/// </summary>
		public interface IOnEndBattleEventArgs : IEventArgs
		{
			//readonly int EventId = typeof(OnWildBattleEndEventArgs).GetHashCode();

			//int Id { get { return EventId; } }
			bool CanLose { get; set; }
			/// <summary>
			/// Battle result (1-win, 2-loss, 3-escaped, 4-caught, 5-draw)
			/// </summary>
			//BattleResults Decision { get; set; }
			int Decision { get; set; }
		}
		/// <summary>
		/// Parameters:
		/// e[0] - Trainer
		/// e[1] - Items possessed by the trainer
		/// e[2] - Party
		/// </summary>
		public interface IOnTrainerPartyLoadEventArgs : IEventArgs
		{
			//readonly int EventId = typeof(OnTrainerPartyLoadEventArgs).GetHashCode();

			//int Id { get; }
			ITrainer Trainer { get; set; }
			/// <summary>
			/// Items possessed by the trainer
			/// </summary>
			//IList<Items> Items { get; set; }
			IList<int> Items { get; set; }
			IList<IPokemon> Party { get; set; }
		}
		/// <summary>
		/// Parameters:
		/// e[0] = <see cref="ISceneMap"/> object.
		/// e[1] = Whether the player just moved to a new map (either true or false). If false,
		///   some other code had called <see cref="ISceneMap.createSpritesets"/> with <see cref="IGame.Scene"/>
		///   to regenerate the map scene without transferring the player elsewhere
		/// </summary>
		public interface IOnMapSceneChangeEventArgs : IEventArgs
		{
			//readonly int EventId = typeof(OnMapSceneChangeEventArgs).GetHashCode();

			//int Id { get; }
			/// <summary>
			/// Scene_Map object.
			/// </summary>
			ISceneMap Object { get; set; }
			/// <summary>
			/// Whether the player just moved to a new map (either true or false).
			/// </summary>
			bool NewMap { get; set; }
		}
		/// <summary>
		/// Parameters:
		/// e[0] = Spriteset being created
		/// e[1] = Viewport used for tilemap and characters
		/// e[0].map = Map associated with the spriteset (not necessarily the current map).
		/// </summary>
		public interface IOnSpritesetCreateEventArgs : IEventArgs
		{
			//readonly int EventId = typeof(OnSpritesetCreateEventArgs).GetHashCode();

			//int Id { get; }
			/// <summary>
			/// Spriteset being created
			/// </summary>
			ISpritesetMap SpritesetId { get; set; }
			/// <summary>
			/// Viewport used for tilemap and characters
			/// </summary>
			IViewport Viewport { get; set; }
			/// <summary>
			/// Map associated with the spriteset (not necessarily the current map).
			/// </summary>
			int MapId { get; set; }
			//ISpritesetMap Map { get; set; }
		}
		#endregion
	}
}