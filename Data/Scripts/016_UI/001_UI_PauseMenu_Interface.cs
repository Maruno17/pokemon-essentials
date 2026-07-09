using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Interface for the pause menu scene that displays the main game menu.
	/// Provides access to various game functions like Pokemon, Bag, Save, etc.
	/// </summary>
	public interface IScenePokemonPauseMenu : IScene, IMenuScene
	{
		/// <summary>
		/// Shows the pause menu with all available options.
		/// </summary>
		/// <returns>The selected menu option index, or -1 if cancelled.</returns>
		int ShowMenu();

		/// <summary>
		/// Shows specific commands in the menu.
		/// </summary>
		/// <param name="commands">The list of command options to display.</param>
		/// <returns>The index of the selected command, or -1 if cancelled.</returns>
		int ShowCommands(IList<string> commands);
	}

	/// <summary>
	/// Interface for the pause menu screen that manages the pause menu scene.
	/// </summary>
	public interface IScreenPokemonPauseMenu : IScreen, IUIScreen
	{
		IScreenPokemonPauseMenu initialize(IScenePokemonPauseMenu scene);

		/// <summary>
		/// Starts the pause menu screen and handles user interaction.
		/// </summary>
		/// <returns>The selected menu option or result code.</returns>
		int StartPauseMenu();

		/// <summary>
		/// Shows the pause menu and returns the selected command.
		/// </summary>
		/// <returns>The command selected by the user.</returns>
		int ShowPauseMenu();
	}

	/// <summary>
	/// Interface for pause menu utilities and helper functions.
	/// </summary>
	//public interface IMainPauseMenuUtilities
	//{
	//	/// <summary>
	//	/// Opens the pause menu and handles the selected option.
	//	/// </summary>
	//	/// <returns>The result of the menu interaction.</returns>
	//	int ShowPauseMenu();
	//
	//	/// <summary>
	//	/// Checks if the pause menu can be opened in the current context.
	//	/// </summary>
	//	/// <returns>True if the pause menu can be opened, false otherwise.</returns>
	//	bool canOpenPauseMenu();
	//
	//	/// <summary>
	//	/// Gets the available menu commands based on current game state.
	//	/// </summary>
	//	/// <returns>List of available menu command names.</returns>
	//	IList<string> getAvailableMenuCommands();
	//
	//	/// <summary>
	//	/// Executes the action for a selected menu command.
	//	/// </summary>
	//	/// <param name="commandIndex">The index of the selected command.</param>
	//	/// <returns>The result of the command execution.</returns>
	//	int executeMenuCommand(int commandIndex);
	//}
}