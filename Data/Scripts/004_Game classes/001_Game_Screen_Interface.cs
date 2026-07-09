using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Contains globally accessible functions related to the screen.
	/// </summary>
	public interface IMainGameScreen : IMain
	{
		/// <summary>
		/// Changes the color tone of the main screen and all active pictures.
		/// </summary>
		/// <param name="tone">The target <see cref="ITone"/> to transition to.</param>
		/// <param name="duration">The duration of the tone change, in frames (or a similar time unit).</param>
		void ToneChangeAll(ITone tone, int duration);

		/// <summary>
		/// Flashes the screen with a given color for a specified number of frames.
		/// Affects the global game screen.
		/// </summary>
		/// <param name="color">The <see cref="IColor"/> to use for the flash.</param>
		/// <param name="frames">The duration of the flash in frames.</param>
		void Flash(IColor color, int frames);

		/// <summary>
		/// Shakes the screen with a given power and speed for a specified number of frames.
		/// Affects the global game screen.
		/// </summary>
		/// <param name="power">The intensity of the shake.</param>
		/// <param name="speed">The speed of the shake.</param>
		/// <param name="frames">The duration of the shake in frames.</param>
		void Shake(float power, float speed, int frames);
	}

	/// <summary>
	/// Handles screen maintenance data, such as changes in color tone, screen flashes, etc.
	/// </summary>
	/// <remarks>
	/// An instance of this interface is typically accessed globally.
	/// </remarks>
	public interface IGameScreen : IHaveUpdate
	{
		/// <summary>
		/// Gets the screen brightness.
		/// </summary>
		/// <value>The brightness level, typically ranging from 0 to 255.</value>
		int brightness { get; }

		/// <summary>
		/// Gets the screen's current color tone.
		/// </summary>
		/// <value>An <see cref="ITone"/> object representing the color tone.</value>
		ITone tone { get; }

		/// <summary>
		/// Gets the color used for screen flashing.
		/// </summary>
		/// <value>An <see cref="IColor"/> object representing the flash color.</value>
		IColor flash_color { get; }

		/// <summary>
		/// Gets the current screen shake displacement value.
		/// </summary>
		/// <value>An integer representing the shake offset in pixels. Typically initialized to 0.</value>
		int shake { get; }

		/// <summary>
		/// Gets the list of pictures currently displayed on the screen.
		/// </summary>
		/// <value>An <see cref="IList{T}"/> of <see cref="IGamePicture"/> objects.</value>
		/// <remarks>
		/// This collection is often indexed, with a common size accommodating a large number of pictures (e.g., 101 elements).
		/// </remarks>
		IList<IGamePicture> pictures { get; }

		/// <summary>
		/// Gets the current weather type active on the screen.
		/// </summary>
		/// <value>
		/// A <see cref="GameData.IWeather"/> type object representing the weather.
		/// </value>
		/// <remarks>Typically initialized to a 'None' or default state.</remarks>
		int weather_type { get; }

		/// <summary>
		/// Gets the maximum number of weather sprites, indicating intensity.
		/// </summary>
		/// <value>A float representing the maximum number of weather sprites. Typically initialized to 0.0f.</value>
		float weather_max { get; }

		/// <summary>
		/// Gets or sets the duration in frames for the weather effect to fade in.
		/// </summary>
		/// <value>An integer representing the fade-in duration. Typically initialized to 0.</value>
		int weather_duration { get; set; }

		/// <summary>
		/// Initializes the screen's state.
		/// </summary>
		IGameScreen initialize();

		/// <summary>
		/// Starts changing the screen color tone over a specified duration.
		/// </summary>
		/// <param name="tone">The target <see cref="ITone"/> to transition to.</param>
		/// <param name="duration">The duration of the tone change, in frames (or a similar time unit).</param>
		void start_tone_change(ITone tone, int duration);

		/// <summary>
		/// Starts flashing the screen with a specific color for a specified duration.
		/// </summary>
		/// <param name="color">The <see cref="IColor"/> to use for the flash.</param>
		/// <param name="duration">The duration of the flash, in frames (or a similar time unit).</param>
		void start_flash(IColor color, int duration);

		/// <summary>
		/// Starts shaking the screen with a given power, speed, and duration.
		/// </summary>
		/// <param name="power">The intensity of the shake.</param>
		/// <param name="speed">The speed of the shake.</param>
		/// <param name="duration">The duration of the shake, in frames (or a similar time unit).</param>
		void start_shake(float power, float speed, int duration);

		/// <summary>
		/// Sets the weather effect on the screen.
		/// </summary>
		/// <param name="type">The <see cref="IWeather"/> type to apply.</param>
		/// <param name="power">The intensity of the weather effect.</param>
		/// <param name="duration">The duration for the weather effect or its transition, in frames.</param>
		void weather(int type, float power, int duration);
		//void SetWeather(int type, float power, int duration);

		/// <summary>
		/// Updates the screen's visual effects, such as tone, flash, shake, and pictures.
		/// This is typically called each frame.
		/// </summary>
		void update();
	}
}