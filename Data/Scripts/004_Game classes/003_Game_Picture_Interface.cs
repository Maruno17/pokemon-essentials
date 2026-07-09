using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Handles the picture data and animations. Used within the <see cref="IGameScreen"/> class.
	/// </summary>
	/// <remarks>
	/// This class handles the picture data and animations. It includes movement and
	/// tone change functions. It's used within the <see cref="IGameScreen"/> class
	/// (<see cref="IGameManager.game_screen"/>).
	/// Refer to "Game.GameData.game_screen.pictures" for the instance of this class.
	/// </remarks>
	public interface IGamePicture : IHaveUpdate {
		/// <summary>
		/// Gets the picture number.
		/// </summary>
		int number { get; }

		/// <summary>
		/// Gets the file name of the picture.
		/// </summary>
		string name { get; }

		/// <summary>
		/// Gets the starting point of the picture.
		/// </summary>
		int origin { get; }

		/// <summary>
		/// Gets the x-coordinate of the picture.
		/// </summary>
		float x { get; }

		/// <summary>
		/// Gets the y-coordinate of the picture.
		/// </summary>
		float y { get; }

		/// <summary>
		/// Gets the x-directional zoom rate.
		/// </summary>
		float zoom_x { get; }

		/// <summary>
		/// Gets the y-directional zoom rate.
		/// </summary>
		float zoom_y { get; }

		/// <summary>
		/// Gets the opacity level of the picture.
		/// </summary>
		float opacity { get; }

		/// <summary>
		/// Gets the blend method of the picture.
		/// </summary>
		int blend_type { get; }

		/// <summary>
		/// Gets the color tone of the picture.
		/// </summary>
		ITone tone { get; }

		/// <summary>
		/// Gets the rotation angle of the picture.
		/// </summary>
		float angle { get; }

		//Game_Picture(int number) { initialize(number); }

		IGamePicture initialize(int number);

		/// <summary>
		/// Shows a picture with the specified parameters.
		/// </summary>
		/// <param name="name">The file name of the picture.</param>
		/// <param name="origin">The starting point.</param>
		/// <param name="x">The x-coordinate.</param>
		/// <param name="y">The y-coordinate.</param>
		/// <param name="zoomX">The x-directional zoom rate.</param>
		/// <param name="zoomY">The y-directional zoom rate.</param>
		/// <param name="opacity">The opacity level.</param>
		/// <param name="blendType">The blend method.</param>
		void show(string name, int origin, float x, float y, float zoomX, float zoomY, float opacity, int blendType);

		/// <summary>
		/// Moves the picture with animation.
		/// </summary>
		/// <param name="duration">Time in 1/20ths of a second.</param>
		/// <param name="origin">The starting point.</param>
		/// <param name="x">The target x-coordinate.</param>
		/// <param name="y">The target y-coordinate.</param>
		/// <param name="zoomX">The target x-directional zoom rate.</param>
		/// <param name="zoomY">The target y-directional zoom rate.</param>
		/// <param name="opacity">The target opacity level.</param>
		/// <param name="blendType">The blend method.</param>
		void move(float duration, int origin, float x, float y, float zoomX, float zoomY, float opacity, int blendType);

		/// <summary>
		/// Changes the rotation speed of the picture.
		/// </summary>
		/// <param name="speed">Rotation speed in degrees per 1/20th of a second.</param>
		void rotate(float speed);

		/// <summary>
		/// Starts a color tone change animation.
		/// </summary>
		/// <param name="tone">The target color tone.</param>
		/// <param name="duration">Time in 1/20ths of a second.</param>
		void start_tone_change(ITone tone, float duration);

		/// <summary>
		/// Erases the picture.
		/// </summary>
		void erase();

		/// <summary>
		/// Updates the picture's state, including movement, tone changes, and rotation.
		/// </summary>
		void update();
	}
}