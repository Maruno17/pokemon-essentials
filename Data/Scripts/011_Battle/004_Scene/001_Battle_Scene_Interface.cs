using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Interface for global methods and properties related to the main battle scene.
	/// </summary>
	public interface IBattleScene : IScene, ICanDisplayMessage, IHaveUpdate, IHaveRefresh, IDisposable
	{
		bool USE_ABILITY_SPLASH  { get; }
		float MESSAGE_PAUSE_TIME { get; }

		IColor MESSAGE_BASE_COLOR   { get; }
		IColor MESSAGE_SHADOW_COLOR { get; }

		int NUM_BALLS            { get; }

		int PLAYER_BASE_X        { get; }
		int PLAYER_BASE_Y        { get; }

		int FOE_BASE_X           { get; }
		int FOE_BASE_Y           { get; }

		int FOCUSUSER_X          { get; }
		int FOCUSUSER_Y          { get; }
		int FOCUSTARGET_X        { get; }
		int FOCUSTARGET_Y        { get; }

		int BLANK                { get; }
		int MESSAGE_BOX          { get; }
		int COMMAND_BOX          { get; }
		int FIGHT_BOX            { get; }
		int TARGET_BOX           { get; }

		/// <summary>
		/// Gets or sets whether the battle can be aborted immediately (for non-interactive battles).
		/// </summary>
		bool Abortable { get; set; }

		/// <summary>
		/// Gets the viewport used for rendering the battle scene.
		/// </summary>
		IViewport Viewport { get; }

		/// <summary>
		/// Gets the dictionary of named sprites used in the battle scene.
		/// </summary>
		IDictionary<string, ISprite> Sprites { get; }

		/// <summary>
		/// Returns the position for a battler's sprite, given its index and side size.
		/// </summary>
		/// <param name="index">The battler's index.</param>
		/// <param name="sideSize">The number of battlers on the side.</param>
		/// <returns>An array with X and Y coordinates.</returns>
		int[] BattlerPosition(int index, int sideSize = 1);

		/// <summary>
		/// Returns the position for a trainer's sprite, given side, index, and side size.
		/// </summary>
		/// <param name="side">0 for player, 1 for foe.</param>
		/// <param name="index">Trainer index.</param>
		/// <param name="sideSize">Number of trainers on the side.</param>
		/// <returns>An array with X and Y coordinates.</returns>
		int[] TrainerPosition(int side, int index = 0, int sideSize = 1);

		/// <summary>
		/// Updates the battle scene and optionally a command window.
		/// </summary>
		/// <param name="cw">The command window to update, if any.</param>
		void Update(IWindow_CommandPokemon cw = null);

		/// <summary>
		/// Updates the graphics for the battle scene.
		/// </summary>
		void GraphicsUpdate();

		/// <summary>
		/// Updates input for the battle scene.
		/// </summary>
		void InputUpdate();

		/// <summary>
		/// Updates the frame for the battle scene and optionally a command window.
		/// </summary>
		/// <param name="cw">The command window to update, if any.</param>
		void FrameUpdate(IWindow_CommandPokemon cw = null);

		/// <summary>
		/// Refreshes all battler data boxes in the scene.
		/// </summary>
		void Refresh();

		/// <summary>
		/// Refreshes a single battler's data box.
		/// </summary>
		/// <param name="idxBattler">The battler index.</param>
		void RefreshOne(int idxBattler);

		/// <summary>
		/// Refreshes all elements in the scene, including background and all battlers.
		/// </summary>
		void RefreshEverything();

		/// <summary>
		/// Returns whether the party line-ups are currently animating on-screen.
		/// </summary>
		/// <returns>True if party animation is in progress.</returns>
		bool InPartyAnimation();

		/// <summary>
		/// Shows a specific window type in the battle scene.
		/// </summary>
		/// <param name="windowType">The window type constant.</param>
		void ShowWindow(int windowType);

		/// <summary>
		/// Waits for a message to finish displaying.
		/// </summary>
		/// <remarks>
		/// This is for the end of brief messages, which have been lingering on-screen
		/// while other things happened. This is only called when another message wants
		/// to be shown, and makes the brief message linger for one more second first.
		/// Some animations skip this extra second by setting <see cref="briefMessage"/> to false
		/// despite not having any other messages to show.
		/// </remarks>
		void WaitMessage();

		/// <summary>
		/// Displays a message in the battle scene.
		/// </summary>
		/// <remarks>
		/// NOTE: A regular message is displayed for 1 second after it fully appears (or
		///       less if <see cref="IInput.USE"/>/<see cref="IInput.BACK"/> is pressed).
		///       Disappears automatically after that time.
		/// </remarks>
		/// <param name="msg">The message text.</param>
		/// <param name="brief">Whether the message is brief.</param>
		void DisplayMessage(string msg, bool brief = false);

		/// <summary>
		/// Displays a paused message in the battle scene.
		/// </summary>
		/// <remarks>
		/// NOTE: A paused message has the arrow in the bottom corner indicating there
		///       is another message immediately afterward. It is displayed for 3
		///       seconds after it fully appears (or less if <see cref="IInput.USE"/>/<see cref="IInput.BACK"/> is pressed) and
		///       disappears automatically after that time, except at the end of battle.
		/// </remarks>
		/// <param name="msg">The message text.</param>
		void DisplayPausedMessage(string msg);

		/// <summary>
		/// Displays a confirmation message and returns the result.
		/// </summary>
		/// <param name="msg">The message text.</param>
		/// <returns>True if confirmed, false otherwise.</returns>
		bool DisplayConfirmMessage(string msg);

		/// <summary>
		/// Shows a command selection window and returns the selected index.
		/// </summary>
		/// <param name="msg">The prompt message.</param>
		/// <param name="commands">The list of command options.</param>
		/// <param name="defaultValue">The default selected index.</param>
		/// <returns>The selected command index.</returns>
		int ShowCommands(string msg, IList<string> commands, int defaultValue);

		/// <summary>
		/// Adds a sprite to the scene.
		/// </summary>
		/// <param name="id">The sprite's identifier.</param>
		/// <param name="x">X coordinate.</param>
		/// <param name="y">Y coordinate.</param>
		/// <param name="filename">The sprite's image file.</param>
		/// <param name="viewport">The viewport to use.</param>
		/// <returns>The created sprite.</returns>
		ISprite AddSprite(string id, int x, int y, string filename, IViewport viewport);

		/// <summary>
		/// Adds a plane (tiled background) to the scene.
		/// </summary>
		/// <param name="id">The plane's identifier.</param>
		/// <param name="filename">The plane's image file.</param>
		/// <param name="viewport">The viewport to use.</param>
		/// <returns>The created plane sprite.</returns>
		IAnimatedPlane AddPlane(string id, string filename, IViewport viewport);

		/// <summary>
		/// Disposes all sprites in the scene.
		/// </summary>
		void DisposeSprites();

		/// <summary>
		/// Swaps the sprites and data for two battlers (used by Ally Switch).
		/// </summary>
		/// <param name="idxA">First battler index.</param>
		/// <param name="idxB">Second battler index.</param>
		void SwapBattlerSprites(int idxA, int idxB);

		/// <summary>
		/// Begins the command phase of the battle.
		/// </summary>
		void BeginCommandPhase();

		/// <summary>
		/// Begins the attack phase of the battle.
		/// </summary>
		void BeginAttackPhase();

		/// <summary>
		/// Begins the end-of-round phase of the battle.
		/// </summary>
		void BeginEndOfRoundPhase();

		/// <summary>
		/// Ends the battle and performs cleanup.
		/// </summary>
		/// <param name="result">The result of the battle.</param>
		void EndBattle(int result);

		/// <summary>
		/// Selects a battler or group of battlers for highlighting.
		/// </summary>
		/// <param name="idxBattler">The battler index or array of indices.</param>
		/// <param name="selectMode">The selection mode.</param>
		void SelectBattler(int idxBattler, int selectMode = 1);

		/// <summary>
		/// Changes the Pokémon displayed for a battler.
		/// </summary>
		/// <param name="idxBattler">The battler index.</param>
		/// <param name="pkmn">The Pokémon to display.</param>
		void ChangePokemon(int idxBattler, IPokemon pkmn);

		/// <summary>
		/// Resets the command and move index for a battler.
		/// </summary>
		/// <param name="idxBattler">The battler index.</param>
		void ResetCommandsIndex(int idxBattler);

		/// <summary>
		/// Called when the player wins a wild Pokémon battle.
		/// </summary>
		/// <remarks>
		/// This method can change the battle's music for example.
		/// </remarks>
		void WildBattleSuccess();

		/// <summary>
		/// Called when the player wins a trainer battle.
		/// </summary>
		/// <remarks>
		/// This method can change the battle's music for example.
		/// </remarks>
		void TrainerBattleSuccess();
	}
}