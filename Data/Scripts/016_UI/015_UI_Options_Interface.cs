using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Stores game options
	/// </summary>
	public interface IGameSystemOption {
		int textspeed				{ get; set; }
		int battlescene				{ get; set; }
		int battlestyle				{ get; set; }
		int sendtoboxes				{ get; set; }
		int givenicknames			{ get; set; }
		int frame					{ get; set; }
		int textskin				{ get; }
		//int font					{ get; set; }
		int screensize				{ get; set; }
		int language				{ get; set; }
		//int border					{ get; }
		int runstyle				{ get; }
		int bgmvolume				{ get; }
		int sevolume				{ get; }

		//int tilemap					{ get; }
		int textinput				{ get; }

		IGameSystemOption initialize();
	}

	public interface IPropertyMixin<T> {
		Func<int, T> get();

		void set(Action<int> value);
	}

	public interface IEnumOption : IOptionValue, IPropertyMixin<string>, IEnumOption<string>
	{
		//string values			{ get; }
		//string name			{ get; }

		//IEnumOption initialize(string name, string options, Func<int,string> getProc, Action<int> setProc);

		//int next(int current);

		//int prev(int current);
	}

	public interface IEnumOption<T> : IOptionValue, IPropertyMixin<T>
	{
		T values				{ get; }
		//string name				{ get; }

		IEnumOption<T> initialize(string name, T options, Func<int,T> getProc, Action<int> setProc);

		//int next(int current);

		//int prev(int current);
	}

	public interface INumberOption : IOptionValue, IPropertyMixin<int>
	{
		//string name				{ get; }
		int optstart			{ get; }
		int optend				{ get; }

		INumberOption initialize(string name, int optstart, int optend, Func<int,int> getProc, Action<int> setProc);

		//int next(int current);

		//int prev(int current);
	}

	public interface ISliderOption : IOptionValue, IPropertyMixin<int>
	{
		//string name				{ get; }
		int optstart			{ get; }
		int optend				{ get; }

		ISliderOption initialize(string name, int optstart, int optend, int optinterval, Func<int,int> getProc, Action<int> setProc);

		//int next(int current);

		//int prev(int current);
	}

	/// <summary>
	/// Interface for the options scene that manages game settings and preferences.
	/// Handles display and modification of various game configuration options.
	/// </summary>
	//public interface IScenePokemonOption : IUIScene
	public interface ISceneGameOption : IUIScene, IHaveUpdate
	{
		/// <summary>
		/// Starts the options scene with available settings categories.
		/// Initializes options list, value displays, and configuration interface.
		/// </summary>
		/// <param name="options">List of available options and their current values.</param>
		void StartScene(IList<object> options);

		/// <summary>
		/// Handles the main scene interaction loop for options modification.
		/// Processes navigation through options and handles value changes.
		/// </summary>
		/// <returns>Result code indicating action taken or exit condition.</returns>
		int Scene();

		/// <summary>
		/// Ends the options scene and cleans up resources.
		/// Handles fade out transition and disposes of sprites and viewports.
		/// </summary>
		void EndScene();

		/// <summary>
		/// Updates all sprites in the options scene.
		/// Called during the main loop to refresh sprite states and animations.
		/// </summary>
		void Update();

		/// <summary>
		/// Refreshes the options list display with current values.
		/// Updates option names, current settings, and available choices.
		/// </summary>
		void RefreshOptions();

		/// <summary>
		/// Updates the information display for the currently selected option.
		/// Shows option description, current value, and available alternatives.
		/// </summary>
		void UpdateOptionInfo();

		/// <summary>
		/// Handles navigation between options in the settings list.
		/// Updates selection and refreshes option information display.
		/// </summary>
		/// <param name="direction">Direction of navigation (up/down).</param>
		void NavigateOptions(int direction);

		/// <summary>
		/// Modifies the value of the currently selected option.
		/// Changes option setting and updates display accordingly.
		/// </summary>
		/// <param name="direction">Direction of value change (increase/decrease).</param>
		void ChangeOptionValue(int direction);

		/// <summary>
		/// Resets the currently selected option to its default value.
		/// Restores option to original setting and updates display.
		/// </summary>
		void ResetOption();

		/// <summary>
		/// Resets all options to their default values.
		/// Restores all settings to original configuration with confirmation.
		/// </summary>
		void ResetAllOptions();

		/// <summary>
		/// Saves current option changes to the configuration file.
		/// Persists all modified settings for future game sessions.
		/// </summary>
		void SaveOptions();

		/// <summary>
		/// Validates option values and handles any conflicts or issues.
		/// Checks option compatibility and resolves any setting conflicts.
		/// </summary>
		/// <returns>True if all options are valid and compatible.</returns>
		bool ValidateOptions();

		/// <summary>
		/// Formats option values for display in the options list.
		/// Converts option settings into readable format for user interface.
		/// </summary>
		/// <param name="option">Option data to format for display.</param>
		/// <returns>Formatted option value string.</returns>
		string formatOptionValue(object option);
	}
	public interface IWindow_PokemonOption : IWindow_DrawableCommand
	{
		bool mustUpdateOptions				{ get; set; }

		IWindow_PokemonOption initialize(IOptionValue[] options, float x, float y, float width, float height);

		IOptionValue this[int i] { get; set; }

		void setValueNoRefresh(int index, IOptionValue value);

		int itemCount();

		void drawItem(int index, int count, IRect rect);

		void update();
	}

	/// <summary>
	/// Interface for the options screen that orchestrates game settings management.
	/// Coordinates between scenes and manages overall options configuration experience.
	/// </summary>
	//public interface IPokemonOptionScreen

	public interface IScreenGameOption : IScreen
	{
		/// <summary>
		/// Initializes the options screen with the specified scene.
		/// Sets up the scene instance for managing the options interface.
		/// </summary>
		/// <param name="scene">The options scene to use.</param>
		IScreenGameOption initialize(ISceneGameOption scene);

		/// <summary>
		/// Starts the options screen for settings management.
		/// Displays available options and manages configuration functionality.
		/// </summary>
		void StartScreen();
	}

	public interface IOptionValue
	{
		string name { get; }
		int next(int current);
		int prev(int current);
	}
}