using System;
using System.Collections;
using System.Collections.Generic;
using PokemonEssentials.RPGMaker.Kernel;

namespace PokemonEssentials
{
	/// <summary>
	/// Provides additional debug menu functionality and extended development tools.
	/// Contains supplementary debug commands that extend the core debug menu system with specialized development utilities.
	/// </summary>
	public interface IMainDebugMenuExtraCode : IMain
	{
		/// <summary>
		/// Gets the default map ID for warp operations.
		/// Returns current map, edit map, or 0 as fallback.
		/// </summary>
		/// <returns>The default map ID to use for warping</returns>
		int DefaultMap();

		/// <summary>
		/// Provides map selection and safe warping functionality.
		/// Finds safe landing coordinates and handles map transitions.
		/// </summary>
		/// <returns>Array containing [mapId, x, y] coordinates or null if cancelled</returns>
		ITilePosition WarpToMap();

		void DebugSetVariable(int id, int diff);

		void DebugVariableScreen(int id);

		void DebugVariables(int mode);

		/// <summary>
		/// Debug Day Care screen.
		/// </summary>
		void DebugDayCare();

		void DebugRoamers();

		#region Battle animations import/export.
		void ExportAllAnimations();

		void ImportAllAnimations();

		void DebugFixInvalidTiles();

		void CheckTileValidity(int tile_id, int map, int tilesets, IDictionary<int,bool> passages);
		#endregion
	}

	/// <summary>
	/// Debug variables management screen for switches and variables.
	/// Provides comprehensive interface for editing game state values.
	/// </summary>
	public interface IDebugVariablesWindow : IWindow_DrawableCommand, IHaveRefresh
	{
		/// <summary>
		/// The current editing mode (switches or variables).
		/// </summary>
		int mode { get; }

		/// <summary>
		/// The currently selected index in the variables list.
		/// </summary>
		int index { get; set; }

		/// <summary>
		/// Initializes the debug variables window.
		/// </summary>
		/// <param name="viewport">The viewport for the window</param>
		IDebugVariablesWindow initialize(IViewport viewport);

		/// <summary>
		/// Sets the editing mode for the window.
		/// </summary>
		/// <param name="mode">0 for switches, 1 for variables</param>
		void setMode(int mode);

		/// <summary>
		/// Gets the display text for the specified item index.
		/// </summary>
		/// <param name="index">The item index</param>
		/// <returns>Formatted display text for the item</returns>
		string getItemText(int index);

		/// <summary>
		/// Toggles or edits the value at the specified index.
		/// </summary>
		/// <param name="index">The item index to modify</param>
		void editValue(int index);

		/// <summary>
		/// Refreshes the window display with current values.
		/// </summary>
		void refresh();
	}

	/// <summary>
	/// Debug roaming Pokémon screen.
	/// </summary>
	public interface IDebugRoamersWindow : IWindow_DrawableCommand
	{
		/// <summary>
		/// Initializes the debug variables window.
		/// </summary>
		/// <param name="viewport">The viewport for the window</param>
		IDebugRoamersWindow initialize(IViewport viewport);

		int roamerCount();

		int itemCount();

		void shadowtext(string t, float x, float y, float w, float h, int align = 0, int colors = 0);

		void drawItem(int index, int _count, IRect rect);
	}

	/// <summary>
	/// Pseudo-party screen for editing Pokémon being set up for a wild battle.
	/// </summary>
	public interface IPokemonDebugPartyScreen : IScreen, IHaveUpdate
	{
		IPokemonDebugPartyScreen initialize(); //Maybe not needed, since startscreen is called after this
		void EndScreen();
		void Display(string text);
		void Confirm(string text);
		void ShowCommands(string text, IList<string> commands, int index = 0);
		void ChooseMove(IPokemon pkmn, string text, int index = 0);
		void RefreshSingle(int index);
		void Update();
	}

	/// <summary>
	/// Game state debugging utilities.
	/// Provides access to switches, variables, and other state information.
	/// </summary>
	public interface IGameStateDebugger
	{
		/// <summary>
		/// Gets the current state of a game switch.
		/// </summary>
		/// <param name="switchId">The switch ID to check</param>
		/// <returns>True if the switch is on</returns>
		bool getSwitchState(int switchId);

		/// <summary>
		/// Sets the state of a game switch.
		/// </summary>
		/// <param name="switchId">The switch ID to modify</param>
		/// <param name="state">The new switch state</param>
		void setSwitchState(int switchId, bool state);

		/// <summary>
		/// Gets the value of a game variable.
		/// </summary>
		/// <param name="variableId">The variable ID to check</param>
		/// <returns>The current variable value</returns>
		int getVariableValue(int variableId);

		/// <summary>
		/// Sets the value of a game variable.
		/// </summary>
		/// <param name="variableId">The variable ID to modify</param>
		/// <param name="value">The new variable value</param>
		void setVariableValue(int variableId, int value);
	}
}