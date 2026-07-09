using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	public interface IAnimatedBitmap : IBitmap, IHaveUpdate, ICloneable, IDisposable
	{
		IAnimatedBitmap initialize(string file, int hue= 0); //{
		//	if (file==null) raise "filename is null";
		//	if (file[/^\[(\d+)\]/]  ) {		// Starts with 1 or more digits in brackets
		//	  @bitmap=new PngAnimatedBitmap(file,hue);
		//	} else {
		//	  @bitmap=new GifBitmap(file,hue);
		//	}
		//}

		IBitmap this[int index] { get; } //{ @bitmap[index]; }
		int width { get; } //{ @bitmap.bitmap.width; }
		int height { get; } //{ @bitmap.bitmap.height; }
		int length { get; } //{ @bitmap.Length; }
		IEnumerable<IBitmap> each(); //{ @bitmap.each {|item| yield item }; }
		IBitmap bitmap(); //{ @bitmap.bitmap; }
		int currentIndex { get; } //{ @bitmap.currentIndex; }
		int frameDelay { get; } //{ @bitmap.frameDelay; }
		int totalFrames { get; } //{ @bitmap.totalFrames; }
		//bool disposed { get; } //{ @bitmap.disposed(); }
		void update(); //{ @bitmap.update(); }
		//void dispose(); //{ @bitmap.dispose(); }
		IBitmap deanimate(); //{ @bitmap.deanimate; }
		IAnimatedBitmap copy(); //{ @bitmap.copy; }
	}

	public interface IPngAnimatedBitmap : IHaveUpdate, ICloneable, IDisposable { // :nodoc:
		/// <summary>
		/// Creates an animated bitmap from a PNG file.
		/// </summary>
		/// <param name="file"></param>
		/// <param name="hue"></param>
		/// <returns></returns>
		IPngAnimatedBitmap initialize(string file, int hue = 0);

		IBitmap this[int index] { get; } //return @frames[index];

		int width { get; } //() { this.bitmap.width; }

		int height { get; } //() { this.bitmap.height; }

		IBitmap deanimate();

		IBitmap bitmap { get; }

		int currentIndex { get; }

		int frameDelay(int index);

		int length { get; }

		IEnumerable<IBitmap> each();

		int totalFrames { get; }

		//bool disposed { get; }

		void update();

		//void dispose();

		int frames				{ get; } // internal

		IPngAnimatedBitmap copy();
	}

	public interface IMainAnimatedBitmap : IMain
	{
		IBitmap GetTileBitmap(string filename, int tile_id, int hue);

		IBitmap[] GetTileset(string name, int hue = 0);

		IBitmap[] GetAutotile(string name, int hue = 0);

		IBitmap[] GetAnimation(string name, int hue = 0);
	}

	/// <summary>
	/// Represents a bitmap that can be animated.
	/// </summary>
	/// <remarks>
	/// This interface defines the functionality for managing animated bitmaps,
	/// including frame management, animation control, and rendering.
	/// </remarks>
	//public interface IAnimatedBitmap : IBitmap
	//{
	//	/// <summary>
	//	/// Gets or sets the number of frames in the animation.
	//	/// </summary>
	//	int FrameCount { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the current frame of the animation.
	//	/// </summary>
	//	int CurrentFrame { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the animation speed.
	//	/// </summary>
	//	float Speed { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets whether the animation is playing.
	//	/// </summary>
	//	bool IsPlaying { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets whether the animation loops.
	//	/// </summary>
	//	bool Loop { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the animation's frame width.
	//	/// </summary>
	//	int FrameWidth { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the animation's frame height.
	//	/// </summary>
	//	int FrameHeight { get; set; }
	//
	//	/// <summary>
	//	/// Initializes the animated bitmap with a source bitmap and frame dimensions.
	//	/// </summary>
	//	/// <param name="source">The source bitmap.</param>
	//	/// <param name="frameWidth">The width of each frame.</param>
	//	/// <param name="frameHeight">The height of each frame.</param>
	//	void Initialize(IBitmap source, int frameWidth, int frameHeight);
	//
	//	/// <summary>
	//	/// Disposes of the animated bitmap and its resources.
	//	/// </summary>
	//	void Dispose();
	//
	//	/// <summary>
	//	/// Checks if the animated bitmap has been disposed.
	//	/// </summary>
	//	/// <returns>True if the animated bitmap has been disposed, false otherwise.</returns>
	//	bool IsDisposed();
	//
	//	/// <summary>
	//	/// Updates the animated bitmap's state.
	//	/// </summary>
	//	void Update();
	//
	//	/// <summary>
	//	/// Plays the animation.
	//	/// </summary>
	//	void Play();
	//
	//	/// <summary>
	//	/// Stops the animation.
	//	/// </summary>
	//	void Stop();
	//
	//	/// <summary>
	//	/// Pauses the animation.
	//	/// </summary>
	//	void Pause();
	//
	//	/// <summary>
	//	/// Resumes the animation.
	//	/// </summary>
	//	void Resume();
	//
	//	/// <summary>
	//	/// Resets the animation to the first frame.
	//	/// </summary>
	//	void Reset();
	//
	//	/// <summary>
	//	/// Gets the bitmap for the current frame.
	//	/// </summary>
	//	/// <returns>The bitmap for the current frame.</returns>
	//	IBitmap GetCurrentFrame();
	//
	//	/// <summary>
	//	/// Gets the bitmap for a specific frame.
	//	/// </summary>
	//	/// <param name="frame">The frame number.</param>
	//	/// <returns>The bitmap for the specified frame.</returns>
	//	IBitmap GetFrame(int frame);
	//
	//	/// <summary>
	//	/// Sets the animation's frame count.
	//	/// </summary>
	//	/// <param name="count">The number of frames.</param>
	//	void SetFrameCount(int count);
	//
	//	/// <summary>
	//	/// Sets the animation's current frame.
	//	/// </summary>
	//	/// <param name="frame">The frame number.</param>
	//	void SetCurrentFrame(int frame);
	//
	//	/// <summary>
	//	/// Sets the animation's speed.
	//	/// </summary>
	//	/// <param name="speed">The animation speed.</param>
	//	void SetSpeed(float speed);
	//
	//	/// <summary>
	//	/// Sets whether the animation loops.
	//	/// </summary>
	//	/// <param name="loop">Whether the animation should loop.</param>
	//	void SetLoop(bool loop);
	//
	//	/// <summary>
	//	/// Sets the animation's frame dimensions.
	//	/// </summary>
	//	/// <param name="width">The width of each frame.</param>
	//	/// <param name="height">The height of each frame.</param>
	//	void SetFrameDimensions(int width, int height);
	//}
}