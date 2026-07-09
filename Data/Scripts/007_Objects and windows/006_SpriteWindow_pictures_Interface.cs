using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Displays an icon bitmap in a window. Supports animated images.
	/// </summary>
	public interface IIconWindow : ISpriteWindow_Base, IHaveUpdate, IDisposable {
		/// <summary>
		/// Sets the icon's filename.  Alias for setBitmap.
		/// </summary>
		string name				{ get; set; }
		//void name=(value) {
		//	setBitmap(value);
		//}

		IIconWindow initialize(float x, float y, int width, int height, IViewport viewport= null);

		//void dispose();

		void update();

		void clearBitmaps();

		/// <summary>
		/// Sets the icon's filename.
		/// </summary>
		/// <param name="file"></param>
		/// <param name="hue"></param>
		void setBitmap(string file, int hue= 0);
	}

	/// <summary>
	/// Displays an icon bitmap in a window. Supports animated images.
	/// Accepts bitmaps and paths to bitmap files in its constructor
	/// </summary>
	public interface IPictureWindow : ISpriteWindow_Base, IHaveUpdate, IDisposable {
		IPictureWindow initialize(string pathOrBitmap);

		//void dispose();

		void update();

		void clearBitmaps();

		/// <summary>
		/// Sets the icon's bitmap or filename.
		/// </summary>
		/// <param name="pathOrBitmap"></param>
		/// <param name="hue">is ignored unless pathOrBitmap is a filename</param>
		void setBitmap(string pathOrBitmap, int hue= 0);
	}

	/// <summary>
	/// Represents a window that can display pictures.
	/// </summary>
	/// <remarks>
	/// This interface defines the functionality for managing windows that can display pictures,
	/// including picture management, animation, and rendering.
	/// </remarks>
	//public interface ISpriteWindowPictures : ISpriteWindow
	//{
	//	/// <summary>
	//	/// Gets or sets the window's picture.
	//	/// </summary>
	//	ISprite Picture { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the window's bitmap.
	//	/// </summary>
	//	IBitmap Bitmap { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the window's viewport.
	//	/// </summary>
	//	IViewport Viewport { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets whether the window is visible.
	//	/// </summary>
	//	bool Visible { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the window's x-coordinate.
	//	/// </summary>
	//	int X { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the window's y-coordinate.
	//	/// </summary>
	//	int Y { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the window's z-coordinate.
	//	/// </summary>
	//	int Z { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the window's width.
	//	/// </summary>
	//	int Width { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the window's height.
	//	/// </summary>
	//	int Height { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the window's opacity.
	//	/// </summary>
	//	int Opacity { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the window's blend type.
	//	/// </summary>
	//	int BlendType { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the window's tone.
	//	/// </summary>
	//	ITone Tone { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the window's color.
	//	/// </summary>
	//	IColor Color { get; set; }
	//
	//	/// <summary>
	//	/// Initializes the picture sprite window with an optional viewport.
	//	/// </summary>
	//	/// <param name="viewport">The viewport to use, or null for the default.</param>
	//	void Initialize(IViewport viewport = null);
	//
	//	/// <summary>
	//	/// Disposes of the picture sprite window and its resources.
	//	/// </summary>
	//	void Dispose();
	//
	//	/// <summary>
	//	/// Checks if the picture sprite window has been disposed.
	//	/// </summary>
	//	/// <returns>True if the picture sprite window has been disposed, false otherwise.</returns>
	//	bool IsDisposed();
	//
	//	/// <summary>
	//	/// Updates the picture sprite window's state.
	//	/// </summary>
	//	void Update();
	//
	//	/// <summary>
	//	/// Refreshes the picture sprite window's appearance.
	//	/// </summary>
	//	/// <param name="force_refresh">Whether to force a complete refresh.</param>
	//	void Refresh(bool force_refresh = false);
	//
	//	/// <summary>
	//	/// Sets the window's bitmap.
	//	/// </summary>
	//	/// <param name="bitmap">The bitmap to set.</param>
	//	void SetBitmap(IBitmap bitmap);
	//
	//	/// <summary>
	//	/// Sets the window's picture.
	//	/// </summary>
	//	/// <param name="picture">The picture to set.</param>
	//	void SetPicture(ISprite picture);
	//
	//	/// <summary>
	//	/// Sets the window's viewport.
	//	/// </summary>
	//	/// <param name="viewport">The viewport to set.</param>
	//	void SetViewport(IViewport viewport);
	//}
}