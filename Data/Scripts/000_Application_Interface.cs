using System;
using System.Collections;
using System.Collections.Generic;
using PokemonEssentials.RPGMaker;
using PokemonEssentials.RPGMaker.Kernel;

namespace PokemonEssentials
{
	//==============================================================================#
	//                              Pokémon Essentials                              #
	//                                 Version 21.1                                 #
	//                https://github.com/Maruno17/pokemon-essentials                #
	//==============================================================================#

	public interface IGameManager
	{
		Framework.ITempMetadata		game_temp			{ get; set; } //						game_temp { get; set; }
		IGameSwitches				game_switches		{ get; set; } //						game_switches { get; set; }
		IGameSelfSwitches			game_self_switches	{ get; set; } //						game_self_switches { get; set; }
		IGameSystem					game_system			{ get; set; } //						game_system { get; set; }
		IGameScreen					game_screen			{ get; set; } //						game_screen { get; set; }
		IDictionary<int,IAnimation>	data_animations		{ get; set; } //						data_animations { get; set; }
		IList<ITileset>				data_tilesets		{ get; set; } //						data_tilesets { get; set; }
		IList<ICommonEvent>			data_common_events	{ get; set; } //						data_common_events { get; set; }
		ISystem						data_system			{ get; set; } //						data_system { get; set; }
		IGameSystemOption			pokemonSystem		{ get; set; } //						pokemonSystem { get; set; }
		IGameMap					game_map			{ get; set; } //						game_map { get; set; }
		IPokemonEncounters			pokemonEncounters	{ get; set; } //						pokemonEncounters { get; set; }
		IGlobalMetadata				pokemonGlobal		{ get; set; } //						pokemonGlobal { get; set; }
		IMapMetadata				pokemonMap			{ get; set; } //						pokemonMap { get; set; }
		IGameStats					stats				{ get; set; } //						stats { get; set; }
		IMapFactory					map_factory			{ get; set; } //						map_factory { get; set; }
		IGamePlayer					game_player			{ get; set; } //						game_player { get; set; }
		IPlayer						game_actors			{ get; set; } //						game_actors { get; set; }
		IGameVariable				game_variables		{ get; set; } //						game_variables { get; set; }
		IPlayer						player				{ get; set; } //						player { get; set; }
		ISceneMap					scene				{ get; set; } //						scene { get; set; }
	}

	/// <summary>
	/// Common UI functions used in both the Bag and item storage screens.
	/// Allows the user to choose a number.
	/// </summary>
	/// <remarks>
	/// The window _helpwindow_ will display the _helptext_.
	/// </remarks>
	public interface IUIHelper //: ICanDisplayMessage
	{
		int ChooseNumber(IWindow helpwindow, string helptext, int maximum);

		void DisplayStatic(IWindow msgwindow, string message);

		/// <summary>
		/// Letter by letter display of the message <paramref name="msg"/> by the window <paramref name="helpwindow"/>.
		/// </summary>
		/// <param name="helpwindow"></param>
		/// <param name="msg"></param>
		/// <param name="brief"></param>
		/// <returns></returns>
		IEnumerator Display(IWindow helpwindow, string msg, bool brief);

		/// <summary>
		/// Letter by letter display of the message <paramref name="msg"/> by the window <paramref name="helpwindow"/>,
		/// used to ask questions.
		/// </summary>
		/// <param name="helpwindow"></param>
		/// <param name="msg"></param>
		/// <returns>Returns true if the user chose yes, false if no.</returns>
		bool Confirm(IWindow helpwindow, string msg);

		int ShowCommands(IWindow helpwindow, string helptext, string[] commands);
	}

	public interface IEntity
	{
	}

	public interface ICanDisplayMessage : IHaveRefresh
	{
		void Refresh();

		/// <summary>
		/// Displays a message in the battle scene.
		/// </summary>
		/// <remarks>
		/// NOTE: A regular message is displayed for 1 second after it fully appears (or
		///       less if <see cref="IInput.USE"/>/<see cref="IInput.BACK"/> is pressed).
		///       Disappears automatically after that time.
		/// </remarks>
		/// <param name="msg">The message text.</param>
		void Display(string msg);
		/// <summary>
		/// Displays a confirmation message and returns the result.
		/// </summary>
		/// <param name="msg">The message text.</param>
		/// <returns>True if confirmed, false otherwise.</returns>
		//bool Confirm(string v);
		//ToDo: rename to "DisplayConfirmMessage"?
		bool DisplayConfirm(string msg);
	}
	public interface ICanDisplayMessageIE : ICanDisplayMessage
	{
		new IEnumerator Display(string v);
		IEnumerator DisplayConfirm(string v, System.Action<bool> result);
	}
	/// <summary>
	/// A scene basically represents unity (or any frontend) where code pauses
	/// for user interaction (animation, and user key inputs).
	/// </summary>
	/// <remarks>
	/// When code has a scene variable calling a method in middle of script
	/// everything essentially comes to a halt as the frontend takes over
	/// and the code awaits a result or response to begin again.
	/// </remarks>
	public interface IScene : ICanDisplayMessage
	{
		/// <summary>
		/// Represents the unique id for given scene.
		/// Used for loading scenes in unity.
		/// </summary>
		int Id { get; }

		//void Refresh();

		/// <summary>
		/// Shows the player's Poké Ball being thrown to capture a Pokémon.
		/// </summary>
		//void pokeballThrow(Items ball, int shakes,bool critical,IBattler targetBattler,IScene scene,IBattler battler, int burst = -1, bool showplayer = false);
		//void Display(string v);
		//bool Confirm(string v);
	}

	/// <summary>
	/// </summary>
	/// Screen should be renamed to `State`, as it's more in line with FSM
	public interface IScreen
	{
		//IEnumerator update();
	}

	/// <summary>
	/// Common interface for updatable objects.
	/// </summary>
	public interface IHaveUpdate //ToDo: Rename to IUpdatable or IShouldUpdate
	{
		/// <summary>
		/// Updates the object.
		/// </summary>
		void update();
	}

	public interface IHaveRefresh
	{
		void refresh();
	}

	public interface IThrowException { }

	public interface IMain { }

	public interface IApplication : IMain {
		string game_title { get; set; }
		string user_language { get; set; }
		string user_name { get; set; }
		int uptime { get; set; }
		int power_state { get; set; }

		void set_window_title(string text);

		/// <summary>
		/// Reload system cache
		/// </summary>
		/// <remarks>
		/// Refreshes the system's file cache. Use if you change a file while playing.
		/// </remarks>
		void reload_cache();
	}

	namespace Framework
	{
		public interface IGameSettings : global::PokemonEssentials.ISettings
			,IBattleSettings
		{
		}

		public interface IMain : global::PokemonEssentials.IMain
			,IApplication
			,IMainFileTests
			,IMainUtilitiesPokemon
			,IMainUtilitiesBattleAudio
			,IMainBattleIntroAnimation
			,IMainBattleStarting
			//,IMainFollower
			//,IMainGameStats
			//,IMainMiscData
			//,IMainRoaming
			,IMainShadowPokemon
			,IMainChallengeExtensions
			,IMainChallengeOpponentGenerator
			,IMainAnimationGeometry
			,IMainOverworld
			,IMainOverworldOverlay
			,IMainOverworldMapTransitionAnimation
			,IMainOverworldWildEncounters
			,IMainOverworldEncounterModifiers
			,IMainOverworldRoamingPokemon
			,IMainOverworldTime
			,IMainOverworldHiddenMoveUtils
			,IMainOverworldFishing
			,IMainOverworldBerryPlants
			,IMainOverworldDayCare
			,IMainOverworldRandomDungeon
			,IMainItemPhone
			,IMainItemPokeRadar
			,IMainItemMailManager
			,IMainPokemonFormDrawing
			,IMainPokemonStorageUtilities
			,IMainTrainerLoadNew
			,IMainEventScene
			,IMainEggHatchingUtility
			,IMainHallOfFame
			,IMainChallengeGeneratorTrainers
			,IMainChallengeGeneratorBattleGenerator
			,IMainSafariZone
		{
		}

		public interface IGlobalMetadata : global::PokemonEssentials.IGlobalMetadata
			//,IGlobalMetadataBattleIntroAnimation
			,IGlobalMetadataBattleStarting
			,IGlobalMetadataFollower
			//,IGlobalMetadataGameStats
			//,IGlobalMetadataMiscData
			//,IGlobalMetadataOverworld
			,IGlobalMetadataPokeRadar
			,IGlobalMetadataRoaming
			//,IGlobalMetadataShadowPokemon
			,IGlobalMetadataRandomDungeon
		{
		}

		public interface ITempMetadata : global::PokemonEssentials.ITempMetadata
			,ITempMetadataBattleIntroAnimation
			,ITempMetadataBattleStarting
			,ITempMetadataFollower
			,ITempMetadataGameStats
			,ITempMetadataMiscData
			,ITempMetadataOverworld
			,ITempMetadataPokeRadar
			,ITempMetadataRoaming
			,ITempMetadataShadowPokemon
		{
		}

		public interface ITrainer : global::PokemonEssentials.ITrainer
			//,ITrainerBattleIntroAnimation
			//,ITrainerBattleStarting
			//,ITrainerFollower
			//,ITrainerGameStats
			//,ITrainerMiscData
			//,ITrainerOverworld
			//,ITrainerPokeRadar
			//,ITrainerRoaming
			//,ITrainerShadowPokemon
		{
		}

		/// <summary>
		/// Interface for individual Pokemon instances.
		/// Represents a single Pokemon with all its data including stats, moves,
		/// status conditions, ownership information, and battle capabilities.
		/// The player's party Pokemon are stored in the array $player.party.
		/// </summary>
		public interface IPokemon : global::PokemonEssentials.IPokemon, ICloneable
			,IPokemonMegaEvolution
			//,IPokemonExperience
			,IPokemonShadowPokemon
		{
		}

		/// <summary>
		/// Interface for the Battle::Battler class, representing a battler in a Pokémon battle.
		/// </summary>
		public interface IBattler : global::PokemonEssentials.IBattler
			,IBattlerInitialize
			,IBattlerChangeSelf
			,IBattlerStatuses
			,IBattlerStatStages
			,IBattlerAbilityAndItem
			,IBattlerUseMove
			,IBattlerUseMoveTargeting
			,IBattlerUseMoveSuccessChecks
			,IBattlerUseMoveTriggerEffects
			,IBattlerShadowPokemon
		{
		}

		public interface IBattle : global::PokemonEssentials.IBattle
			,IBattleStartAndEnd
			,IBattleExpAndMoveLearning
			,IBattleActionAttacksPriority
			,IBattleActionSwitching
			,IBattleActionUseItem
			,IBattleActionRunning
			,IBattleActionOther
			,IBattleCommandPhase
			,IBattleAttackPhase
			,IBattleEndOfRoundPhase
			,IBattleCatchAndStoreMixin
			,IBattleClauses
			,IBattleBugContest
			,IBattleShadowPokemon
		{
		}

		public interface IBattleMove : global::PokemonEssentials.IBattleMove
			,IBattleMoveUsage
			,IBattleMoveUsageCalculations
			,IBattleMoveEffectsMisc
			,IBattleMoveEffectsBattlerStats
			,IBattleMoveEffectsBattlerOther
			,IBattleMoveEffectsMultiHit
			,IBattleMoveEffectsHealing
			,IBattleMoveEffectsItems
			,IBattleMoveEffectsChangeMoveEffect
			,IBattleMoveEffectsSwitchingActing
		{
		}

		public interface IBattleScene : global::PokemonEssentials.IBattleScene
			,IBattleSceneInitialize
			,IBattleSceneChooseCommands
			,IBattleScenePlayAnimations
			,IBattleSceneSafari
			,IBattleSceneBugContest
			,IBattleSceneBattleArena
		{
		}

		public interface IBattleAI : global::PokemonEssentials.IBattleAI
			,IBattleAISwitchLogic
			,IBattleAIGenericMoveEffectScoring
			,IBattleAIUtilities
			,IBattleAIBattlePalace
			,IBattleAIBattleArena
		{
		}
	}
}