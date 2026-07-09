using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Sprite class that maintains a bitmap of its own.
	/// </summary>
	/// <remarks>
	/// This bitmap can't be changed to a different one.
	/// </remarks>
	public interface IBitmapSprite : ISprite, IDisposable {
		IBitmapSprite initialize(int width,int height,IViewport viewport=null);

		IBitmap bitmap { set; }

		//void Dispose();
	}

	public interface IAnimatedSprite : ISprite, IHaveUpdate, IDisposable {
		int frame						{ get; set; }
		int framewidth					{ get; set; }
		int frameheight					{ get; set; }
		int framecount					{ get; set; }
		int animname					{ get; set; }

		void initializeLong(string animname, int framecount, int framewidth, int frameheight, int frameskip);

		/// <summary>
		/// </summary>
		/// Shorter version of AnimationSprite.  All frames are placed on a single row
		/// of the bitmap, so that the width and height need not be defined beforehand
		/// frameskip is in 1/20ths of a second, and is the time between frame changes.
		/// <param name="animname"></param>
		/// <param name="framecount"></param>
		/// <param name="frameskip"></param>
		void initializeShort(string animname, int framecount, int frameskip);

		IAnimatedSprite initialize(IViewport viewport = null);

		IAnimatedSprite create(string animname, int framecount, int frameskip, IViewport viewport = null);

		//void dispose();

		bool playing { get; }

		//void frame=(value) {
		//	@frame=value;
		//	@realframes=0;
		//	this.src_rect.x=@frame%@framesperrow*@framewidth;
		//	this.src_rect.y=@frame/@framesperrow*@frameheight;
		//}

		void start();

		//alias play start;

		void stop();

		void update();
	}

	/// <summary>
	/// Displays an icon bitmap in a sprite. Supports animated images.
	/// </summary>
	public interface IIconSprite : ISprite, IHaveUpdate, IDisposable {
		/// <summary>
		/// Sets the icon's filename.  Alias for <seealso cref="setBitmap"/>.
		/// </summary>
		string name				{ get; set; }
		//void name=(value) {
		//	setBitmap(value);
		//}

		//IIconSprite initialize(*args);
		IIconSprite initialize(float x, float y, IViewport viewport);

		//void dispose();

		/// <summary>
		/// Sets the icon's filename.
		/// </summary>
		/// <param name="file"></param>
		/// <param name="hue"></param>
		void setBitmap(string file, int hue= 0);

		void clearBitmaps();

		void update();
	}

	/// <summary>
	/// Sprite class that stores multiple bitmaps, and displays only one at once.
	/// </summary>
	public interface IChangelingSprite : ISprite, IHaveUpdate, IDisposable {
		IChangelingSprite initialize(float x = 0, float y = 0, IViewport viewport = null);

		void addBitmap(int key, string path);

		void changeBitmap(int key);

		//void dispose();

		void update();
	}

	/// <summary>
	/// Represents a sprite that uses a bitmap for rendering.
	/// </summary>
	/// <remarks>
	/// This interface defines the functionality for managing sprites that use bitmaps,
	/// including bitmap management, animation, and rendering.
	/// </remarks>
	//public interface IBitmapSprite : ISprite
	//{
	//	/// <summary>
	//	/// Gets or sets the sprite's bitmap.
	//	/// </summary>
	//	IBitmap Bitmap { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the sprite's viewport.
	//	/// </summary>
	//	IViewport Viewport { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets whether the sprite is visible.
	//	/// </summary>
	//	bool Visible { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the sprite's x-coordinate.
	//	/// </summary>
	//	int X { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the sprite's y-coordinate.
	//	/// </summary>
	//	int Y { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the sprite's z-coordinate.
	//	/// </summary>
	//	int Z { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the sprite's width.
	//	/// </summary>
	//	int Width { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the sprite's height.
	//	/// </summary>
	//	int Height { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the sprite's opacity.
	//	/// </summary>
	//	int Opacity { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the sprite's blend type.
	//	/// </summary>
	//	int BlendType { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the sprite's tone.
	//	/// </summary>
	//	ITone Tone { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the sprite's color.
	//	/// </summary>
	//	IColor Color { get; set; }
	//
	//	/// <summary>
	//	/// Initializes the bitmap sprite with an optional viewport.
	//	/// </summary>
	//	/// <param name="viewport">The viewport to use, or null for the default.</param>
	//	void Initialize(IViewport viewport = null);
	//
	//	/// <summary>
	//	/// Disposes of the bitmap sprite and its resources.
	//	/// </summary>
	//	void Dispose();
	//
	//	/// <summary>
	//	/// Checks if the bitmap sprite has been disposed.
	//	/// </summary>
	//	/// <returns>True if the bitmap sprite has been disposed, false otherwise.</returns>
	//	bool IsDisposed();
	//
	//	/// <summary>
	//	/// Updates the bitmap sprite's state.
	//	/// </summary>
	//	void Update();
	//
	//	/// <summary>
	//	/// Refreshes the bitmap sprite's appearance.
	//	/// </summary>
	//	/// <param name="force_refresh">Whether to force a complete refresh.</param>
	//	void Refresh(bool force_refresh = false);
	//
	//	/// <summary>
	//	/// Sets the sprite's bitmap.
	//	/// </summary>
	//	/// <param name="bitmap">The bitmap to set.</param>
	//	void SetBitmap(IBitmap bitmap);
	//
	//	/// <summary>
	//	/// Sets the sprite's viewport.
	//	/// </summary>
	//	/// <param name="viewport">The viewport to set.</param>
	//	void SetViewport(IViewport viewport);
	//}
}