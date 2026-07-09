using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Represents a plane in the game.
	/// </summary>
	public interface IPlane : IHaveUpdate, IHaveRefresh
	{
		/// <summary>
		/// Updates the plane's state.
		/// </summary>
		void Update();

		/// <summary>
		/// Refreshes the plane's appearance.
		/// </summary>
		void Refresh();
	}

	/// <summary>
	/// A plane class that displays a single color.
	/// </summary>
	public interface IColoredPlane : IPlane, IDisposable
	{
		/// <summary>
		/// </summary>
		IColoredPlane initialize(IColor color, IViewport viewport = null);

		/// <summary>
		/// </summary>
		/// Disposes of all planes and their resources.
		//void Dispose();

		void set_plane_color(IColor color);
	}

	/// <summary>
	/// A plane class that supports animated images.
	/// </summary>
	public interface IAnimatedPlane : IPlane, IHaveUpdate, IDisposable
	{
		IAnimatedPlane initialize(IViewport viewport);

		/// <summary>
		/// Updates the plane's state.
		/// </summary>
		void Update();

		/// <summary>
		/// Sets the plane's bitmap.
		/// </summary>
		/// <param name="file">The bitmap to set.</param>
		/// <param name="hue">The hue adjustment for the bitmap.</param>
		void SetBitmap(IBitmap file, int hue = 0);

		/// <summary>
		/// Sets the plane's bitmap for the panorama.
		/// </summary>
		/// <param name="file">The bitmap to set.</param>
		/// <param name="hue">The hue adjustment for the bitmap.</param>
		void set_panorama(IBitmap file, int hue = 0);

		/// <summary>
		/// Sets the plane's bitmap for the fog.
		/// </summary>
		/// <param name="file">The bitmap to set.</param>
		/// <param name="hue">The hue adjustment for the bitmap.</param>
		void set_fog(IBitmap file, int hue = 0);
	}
}