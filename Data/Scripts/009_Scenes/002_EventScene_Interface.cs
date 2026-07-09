using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Picture sprite component for animated cutscenes and event presentations.
	/// Manages bitmap loading, hue shifting, custom bitmap assignment, and picture state synchronization.
	/// Integrates with PictureEx objects for advanced animation and positioning control.
	/// </summary>
	public interface IPictureSprite : ISprite, IHaveUpdate
	{
		/// <summary>
		/// Associated picture object controlling sprite behavior and properties.
		/// Contains animation state, positioning data, and visual effects.
		/// </summary>
		IPictureEx picture { get; }

		/// <summary>
		/// Currently loaded animated bitmap for automatic file-based display.
		/// Handles file loading, hue shifting, and frame animation.
		/// </summary>
		IAnimatedBitmap pictureBitmap { get; }

		/// <summary>
		/// Custom bitmap assigned directly for manual display control.
		/// Bypasses file loading when custom content is provided.
		/// </summary>
		IBitmap customBitmap { get; }

		/// <summary>
		/// Whether custom bitmap is a direct Bitmap object or wrapper.
		/// Determines bitmap access method for rendering.
		/// </summary>
		bool customBitmapIsBitmap { get; }

		/// <summary>
		/// Current hue shift value applied to loaded picture file.
		/// Used to detect hue changes requiring bitmap reload.
		/// </summary>
		int hue { get; }

		/// <summary>
		/// Initializes picture sprite with viewport and associated picture object.
		/// Sets up bitmap management and triggers initial update.
		/// </summary>
		/// <param name="viewport">Rendering viewport for sprite display</param>
		/// <param name="picture">Picture object to synchronize with</param>
		IPictureSprite Initialize(IViewport viewport, IPictureEx picture);

		/// <summary>
		/// Assigns custom bitmap for direct display without file loading.
		/// Overrides picture filename when custom bitmap is active.
		/// </summary>
		/// <param name="bitmap">Custom bitmap to display</param>
		void setCustomBitmap(IBitmap bitmap);

		/// <summary>
		/// Synchronizes sprite state with picture object properties.
		/// Handles file loading, hue changes, visibility, and positioning updates.
		/// </summary>
		void update();
	}

	/// <summary>
	/// Event scene manager for cutscenes, animations, and interactive presentations.
	/// Manages pictures, sprites, input handling, and scene timing with event callbacks.
	/// Provides comprehensive scene control for visual storytelling and user interaction.
	/// </summary>
	public interface IEventScene : IScene, IHaveUpdate, IDisposable
	{
		/// <summary>
		/// Event triggered when C button (confirm/action) is pressed.
		/// Allows scene to respond to player confirmation input.
		/// </summary>
		//IEvent onCTrigger { get; set; }
		IEvent onATrigger { get; set; }
		event EventHandler OnATriggerEvent;

		/// <summary>
		/// Event triggered when B button (cancel/back) is pressed.
		/// Allows scene to handle cancellation or back navigation.
		/// </summary>
		IEvent onBTrigger { get; set; }
		event EventHandler OnBTriggerEvent;

		/// <summary>
		/// Event triggered during each frame update cycle.
		/// Enables custom per-frame processing and state management.
		/// </summary>
		/// <remarks>
		/// Update has been triggered, and a new frame is called
		/// </remarks>
		IEvent onUpdate { get; set; }
		event EventHandler OnUpdateEvent;

		/// <summary>
		/// Rendering viewport for all scene elements.
		/// Defines clipping region and rendering context.
		/// </summary>
		IViewport viewport { get; }

		/// <summary>
		/// Collection of picture objects managing animated elements.
		/// Contains positioning, timing, and visual effect data.
		/// </summary>
		IList<IPictureEx> pictures { get; }

		/// <summary>
		/// Collection of picture sprites rendering the picture objects.
		/// Handles bitmap display and visual presentation.
		/// </summary>
		IList<IPictureSprite> picturesprites { get; }

		/// <summary>
		/// Collection of additional user-defined sprites for custom elements.
		/// Allows integration of custom graphics and animations.
		/// </summary>
		IList<ISprite> usersprites { get; }

		/// <summary>
		/// Whether this event scene has been disposed and is no longer usable.
		/// </summary>
		bool disposed { get; }

		/// <summary>
		/// Initializes event scene with optional custom viewport.
		/// Sets up event handlers, sprite collections, and input management.
		/// </summary>
		/// <param name="viewport">Custom viewport for scene rendering (null for default)</param>
		IEventScene Initialize(IViewport viewport = null);

		/// <summary>
		/// Checks if event scene has been disposed and resources released.
		/// </summary>
		/// <returns>True if disposed, false if still active</returns>
		//bool disposed();

		/// <summary>
		/// Adds bitmap element to scene at specified coordinates.
		/// Creates picture object and sprite for bitmap display.
		/// Bitmap can be static Bitmap or animated AnimatedBitmap.
		/// </summary>
		/// <param name="x">X coordinate for bitmap placement</param>
		/// <param name="y">Y coordinate for bitmap placement</param>
		/// <param name="bitmap">Bitmap or AnimatedBitmap to display</param>
		/// <returns>Picture object controlling the bitmap display</returns>
		IPictureEx addBitmap(int x, int y, IBitmap bitmap);

		/// <summary>
		/// Adds text label to scene at specified position with maximum width.
		/// Automatically renders text to bitmap and adds as scene element.
		/// </summary>
		/// <param name="x">X coordinate for label placement</param>
		/// <param name="y">Y coordinate for label placement</param>
		/// <param name="width">Maximum width for text rendering</param>
		/// <param name="text">Text content to display</param>
		/// <returns>Picture object controlling the text display</returns>
		IPictureEx addLabel(int x, int y, int width, string text);

		/// <summary>
		/// Adds image file to scene at specified coordinates.
		/// Loads image from file and creates managed picture sprite.
		/// </summary>
		/// <param name="x">X coordinate for image placement</param>
		/// <param name="y">Y coordinate for image placement</param>
		/// <param name="imageName">Filename of image to load and display</param>
		/// <returns>Picture object controlling the image display</returns>
		IPictureEx addImage(int x, int y, string imageName);

		/// <summary>
		/// Registers user-defined sprite with scene management.
		/// Sprite will be updated and disposed with scene lifecycle.
		/// </summary>
		/// <param name="sprite">Custom sprite to manage</param>
		void addUserSprite(ISprite sprite);

		/// <summary>
		/// Retrieves picture object at specified index.
		/// Provides access to picture properties and animation control.
		/// </summary>
		/// <param name="index">Index of picture to retrieve</param>
		/// <returns>Picture object at specified index</returns>
		IPictureEx getPicture(int index);

		/// <summary>
		/// Pauses scene execution for specified duration in 1/20th second units.
		/// Continues updating scene elements during wait period.
		/// </summary>
		/// <param name="ticks">Wait duration in 1/20th second increments</param>
		void wait(int ticks);

		/// <summary>
		/// Waits for all picture animations to complete plus optional extra time.
		/// Monitors picture running state and continues until all animations finish.
		/// </summary>
		/// <param name="extraTicks">Additional wait time after animations complete (1/20th seconds)</param>
		void pictureWait(int extraTicks = 0);

		/// <summary>
		/// Updates scene state including graphics, input, pictures, and sprites.
		/// Processes input events, animation frames, and user sprite management.
		/// Must be called each frame for proper scene operation.
		/// </summary>
		void update();

		/// <summary>
		/// Main scene execution loop continuing until scene disposal.
		/// Handles continuous updating and scene lifecycle management.
		/// </summary>
		/// <remarks>
		/// Beginning starting point that runs and operates the entire game application.
		/// Enumerates through each frame tick and calls <see cref="IHaveUpdate.update"/> across entire game assembly.
		/// This is supposed to mimic behavior of Unity's Monobehavior `OnUpdate`.
		/// </remarks>
		/// <seealso cref="IEvents.OnFrameUpdate"/>
		/// <seealso cref="OnUpdateEvent"/>
		/// <seealso cref="onUpdate"/>
		void main();
	}

	/// <summary>
	/// Event screen execution helper for scene management.
	/// Provides standardized scene initialization and execution pattern.
	/// </summary>
	//public interface IEventScreenRunner
	public interface IMainEventScene : IMain
	{
		/// <summary>
		/// Executes event scene class with fade transition and viewport management.
		/// Creates viewport, instantiates scene class, handles errors, and cleanup.
		/// </summary>
		/// <param name="sceneClass">Scene class type to instantiate and execute</param>
		void EventScreen(IScene sceneClass);
	//}

	/// <summary>
	/// Creates formatted text bitmap with system font and default colors.
	/// Provides convenient text rendering for event scene labels and messages.
	/// </summary>
	//public interface ITextBitmapRenderer
	//{
		/// <summary>
		/// Generates bitmap containing formatted text with automatic sizing.
		/// Uses system font with standard colors for consistent appearance.
		/// </summary>
		/// <param name="text">Text content to render</param>
		/// <param name="maxwidth">Maximum bitmap width (default: screen width)</param>
		/// <returns>Bitmap containing rendered text</returns>
		IBitmap TextBitmap(string text, int maxwidth);
	}
	/*
	/// <summary>
	/// Enhanced picture object with advanced animation and control capabilities.
	/// Extends basic picture functionality with complex animation sequences.
	/// </summary>
	public interface IPictureEx
	{
		/// <summary>
		/// Picture identification number for reference and management.
		/// </summary>
		int number { get; }

		/// <summary>
		/// Filename of image to display (empty for custom bitmap mode).
		/// </summary>
		string name { get; set; }

		/// <summary>
		/// Hue shift value for color modification.
		/// </summary>
		int hue { get; }

		/// <summary>
		/// Whether picture animation is currently running.
		/// </summary>
		/// <returns>True if animation is active</returns>
		bool running();

		/// <summary>
		/// Sets picture position coordinates.
		/// </summary>
		/// <param name="duration">Animation duration (0 for immediate)</param>
		/// <param name="x">Target X coordinate</param>
		/// <param name="y">Target Y coordinate</param>
		void setXY(int duration, int x, int y);

		/// <summary>
		/// Sets picture visibility state.
		/// </summary>
		/// <param name="duration">Animation duration (0 for immediate)</param>
		/// <param name="visible">Target visibility state</param>
		void setVisible(int duration, bool visible);

		/// <summary>
		/// Updates picture animation state and properties.
		/// </summary>
		void update();
	}

	/// <summary>
	/// Event handler interface for scene callbacks.
	/// Provides callback registration and triggering mechanism.
	/// </summary>
	public interface IEvent
	{
		/// <summary>
		/// Registers event handler callback.
		/// </summary>
		/// <param name="handler">Callback method to register</param>
		void AddHandler(EventHandler handler);

		/// <summary>
		/// Removes event handler callback.
		/// </summary>
		/// <param name="handler">Callback method to remove</param>
		void RemoveHandler(EventHandler handler);

		/// <summary>
		/// Triggers event and calls all registered handlers.
		/// </summary>
		/// <param name="sender">Object triggering the event</param>
		void trigger(object sender);

		/// <summary>
		/// Clears all registered event handlers.
		/// </summary>
		void clear();
	}

	/// <summary>
	/// System interface for debug logging and error handling.
	/// Provides error logging capabilities for scene debugging.
	/// </summary>
	public interface IPBDebug
	{
		/// <summary>
		/// Executes code block with error logging on exceptions.
		/// Catches and logs errors while allowing execution to continue.
		/// </summary>
		/// <param name="action">Code block to execute with error protection</param>
		void logonerr(Action action);
	}

	/// <summary>
	/// Sprite interface for visual scene elements.
	/// Provides basic sprite functionality for scene components.
	/// </summary>
	public interface ISprite : IDisposable
	{
		/// <summary>
		/// Whether sprite has been disposed.
		/// </summary>
		bool disposed { get; }

		/// <summary>
		/// Whether sprite is currently visible.
		/// </summary>
		bool visible { get; set; }

		/// <summary>
		/// Sprite bitmap content.
		/// </summary>
		IBitmap bitmap { get; set; }

		/// <summary>
		/// Updates sprite state and animation.
		/// </summary>
		void update();
	}

	/// <summary>
	/// Animated bitmap interface for dynamic image content.
	/// Handles frame animation and timing.
	/// </summary>
	public interface IAnimatedBitmap : IDisposable
	{
		/// <summary>
		/// Current frame bitmap for display.
		/// </summary>
		IBitmap bitmap { get; }

		/// <summary>
		/// Width of bitmap in pixels.
		/// </summary>
		int width { get; }

		/// <summary>
		/// Height of bitmap in pixels.
		/// </summary>
		int height { get; }

		/// <summary>
		/// Updates animation frame timing.
		/// </summary>
		void update();
	}

	/// <summary>
	/// Viewport interface for rendering region management.
	/// Defines clipping and coordinate systems for scene rendering.
	/// </summary>
	public interface IViewport : IDisposable
	{
		/// <summary>
		/// X coordinate of viewport.
		/// </summary>
		int x { get; set; }

		/// <summary>
		/// Y coordinate of viewport.
		/// </summary>
		int y { get; set; }

		/// <summary>
		/// Width of viewport.
		/// </summary>
		int width { get; set; }

		/// <summary>
		/// Height of viewport.
		/// </summary>
		int height { get; set; }

		/// <summary>
		/// Z-order depth for layering.
		/// </summary>
		int z { get; set; }
	}*/
}