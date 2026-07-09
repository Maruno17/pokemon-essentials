using System;
using System.Collections;
using System.Collections.Generic;
using PokemonEssentials.RPGMaker;
using PokemonEssentials.RPGMaker.Kernel;

namespace PokemonEssentials
{
	#region Audio
	public interface IAudioObject : IAudioFile
	{
		//string name { get; set; }
		//int volume { get; set; }
		//float pitch { get; set; }
	}
	public interface IAudioBGM : IAudioObject, ICloneable
	{
		/// <summary>
		/// Returns BGM (<seealso cref="IAudioBGM"/>) that playing now. If no playing BGM, returns null.
		/// </summary>
		/// <returns></returns>
		IAudioBGM last();
		/// <summary>
		/// Stops BGM playback.
		/// </summary>
		void stop();
		/// <summary>
		/// Starts BGM fadeout.
		/// </summary>
		/// <param name="time">time is the length of the fadeout in milliseconds.</param>
		void fade(int time);
		/// <summary>
		/// Starts the BGM playback.
		/// </summary>
		void play();
		//IAudioBGM Clone();
	}
	public interface IAudioBGS : IAudioObject, ICloneable
	{
		/// <summary>
		/// Returns BGS (<seealso cref="IAudioBGS"/>) that playing now. If no playing BGS, returns null.
		/// </summary>
		/// <returns></returns>
		IAudioBGS last();
		/// <summary>
		/// Stops BGS playback.
		/// </summary>
		void stop();
		/// <summary>
		/// Starts BGS fadeout.
		/// </summary>
		/// <param name="time">time is the length of the fadeout in milliseconds.</param>
		void fade(int time);
		/// <summary>
		/// Starts the BGS playback.
		/// </summary>
		void play();
		//IAudioBGS Clone();
	}
	public interface IAudioME : IAudioObject, ICloneable
	{
		/// <summary>
		/// Stops ME playback.
		/// </summary>
		void stop();
		/// <summary>
		/// Starts ME fadeout.
		/// </summary>
		/// <param name="time">time is the length of the fadeout in milliseconds.</param>
		void fade(int time);
		/// <summary>
		/// Starts the ME playback.
		/// </summary>
		void play();
		//IAudioME Clone();
	}
	public interface IAudioSE : IAudioObject, ICloneable
	{
		/// <summary>
		/// Stops SE playback.
		/// </summary>
		void stop();
		/// <summary>
		/// Starts the SE playback.
		/// </summary>
		void play();
		//IAudioSE Clone();
	}
	public interface IWaveData
	{
		/// <summary>
		/// Average loudness or power of the sound data.
		/// </summary>
		byte intensity { get; }
		/// <summary>
		/// </summary>
		int time { get; }
		/// <summary>
		/// Play the recorded audio
		/// </summary>
		void play();
	}
	#endregion

	public interface IFont
	{
		IColor DefaultColor { get; }
		bool exist(string text);
	}

	#region RPGMaker Wrapper
	/// <summary>
	/// The bitmap class. Bitmaps are expressions of so-called graphics.
	/// </summary>
	/// <remarks>
	/// Sprites (Sprite) and other objects must be used to display bitmaps on the screen.
	/// </remarks>
	//public interface IBitmap : PokemonEssentials.RPGMaker.Kernel.IBitmap { }
	/// <summary>
	/// The RGB color class. Each component is handled with a floating point value (Float).
	/// </summary>
	public interface IColorRGB : PokemonEssentials.RPGMaker.Kernel.IColorRGB { }
	/// <summary>
	/// The RGBA color class. Each component is handled with a floating point value (Float).
	/// </summary>
	public interface IColor : PokemonEssentials.RPGMaker.Kernel.IColor, IColorRGB { }
	/// <summary>
	/// The Plane class. Planes are special sprites that tile bitmap patterns across the entire screen, and are used to display panoramas and fog.
	/// </summary>
	//public interface IPlane : PokemonEssentials.RPGMaker.Kernel.IPlane { }
	/// <summary>
	/// Interface for rectangle bounds used in bitmap operations.
	/// </summary>
	public interface IRect : PokemonEssentials.RPGMaker.Kernel.IRect { }
	/// <summary>
	/// The sprite class. Sprites are the basic concept used to display characters, etc. on the game screen.
	/// </summary>
	public interface ISprite : PokemonEssentials.RPGMaker.Kernel.ISprite { }
	/// <summary>
	/// The color tone class. Each component is handled with a floating point value (Float).
	/// </summary>
	public interface ITone : PokemonEssentials.RPGMaker.Kernel.ITone { }
	/// <summary>
	/// The viewport class.
	/// Used when displaying sprites in one portion of the screen,
	/// with no overflow into other regions.
	/// </summary>
	public interface IViewport : PokemonEssentials.RPGMaker.Kernel.IViewport { }
	/// <summary>
	/// The game window class. Created internally from multiple sprites.
	/// </summary>
	//public interface IWindow : PokemonEssentials.RPGMaker.Kernel.IWindow { }
	#endregion

	namespace EventArg
	{
		/// <summary>
		/// Event argument interface for custom events. This interface is used to define the structure of event arguments passed to event handlers.
		/// </summary>
		/// <remarks>
		/// Uses <see cref="Action{object, IEventArgs}"/> instead of <see cref="EventHandler{TEventArgs}"/> for backward compatibility
		/// with .NET versions before 4.5, as interfaces cannot inherit from <see cref="EventArgs"/>.
		/// </remarks>
		/// <seealso href="https://stackoverflow.com/a/47323956/3681384">Stack Overflow</seealso>
		public interface IEventArgs
		{
			/// <summary>
			/// Event ID for identifying the type of event. This property is used to distinguish between different events when handling them.
			/// </summary>
			/// ToDo: Make a static class for EventId constants, or use an Enum. Use for tracking and maintaining map EventId to EventArgs Type.
			int Id { get; }
		}

		#region Application EventArgs
		public interface IButtonEventArgs : IEventArgs
		{
			//ButtonEventArgs(int button, bool isDown) { Button = button; IsDown = isDown; }
			int Button { get; } // readonly
			bool IsDown { get; } // readonly
		}
		public interface IOnLoadLevelEventArgs : IEventArgs
		{
			//readonly int EventId = typeof(OnMapCreateEventArgs).GetHashCode();

			//int Id { get { return EventId; } }
			//int Id { get { return Pokemon.GetHashCode(); } } //EventId;
			IScene Scene { get; set; }
			//ToDo: Make an Enum for Transition Animation Type?
		}
		#endregion
	}

	namespace RPGMaker
	{
		namespace Kernel
		{
			/// <summary>
			/// The bitmap class. Bitmaps are expressions of so-called graphics.
			/// </summary>
			/// <remarks>
			/// Sprites (Sprite) and other objects must be used to display bitmaps on the screen.
			/// </remarks>
			public interface IBitmap : IDisposable
			{
				float width { get; }
				float height { get; }
				IRect rect { get; }
				/// <summary>
				/// Creates a bitmap object with the specified size.
				/// </summary>
				/// <param name="width"></param>
				/// <param name="height"></param>
				/// <returns></returns>
				IBitmap initialize(int width,int height);
				/// <summary>
				/// Loads the graphic file specified in filename and creates a bitmap object.
				/// </summary>
				/// <param name="filename"></param>
				/// <returns></returns>
				IBitmap initialize(string filename);
				/// <summary>
				/// Performs a block transfer from the <paramref name="src_bitmap"/> box <paramref name="src_rect"/> (<see cref="IRect"/>) to the specified bitmap coordinates (x, y).
				/// </summary>
				/// <param name="x"></param>
				/// <param name="y"></param>
				/// <param name="src_bitmap"></param>
				/// <param name="src_rect"></param>
				/// <param name="opacity">can be set from 0 to 255.</param>
				void blt(int x, int y, IBitmap src_bitmap, IRect src_rect, byte? opacity = null);

				/// <summary>
				/// Performs a block transfer from the src_bitmap box src_rect (Rect) to the specified bitmap box dest_rect (Rect).
				/// </summary>
				/// <param name="dest_rect"></param>
				/// <param name="src_bitmap"></param>
				/// <param name="src_rect"></param>
				/// <param name="opacity">can be set from 0 to 255.</param>
				void stretch_blt(IRect dest_rect, IBitmap src_bitmap, IRect src_rect, byte? opacity = null);

				/// <summary>
				/// Fills the bitmap box(x, y, width, height) or rect(Rect) with color(Color).
				/// </summary>
				/// <param name="x"></param>
				/// <param name="y"></param>
				/// <param name="width"></param>
				/// <param name="height"></param>
				/// <param name="color"></param>
				void fill_rect(float x, float y, float width, float height, IColor color);

				/// <summary>
				/// Fills the bitmap box(x, y, width, height) or rect(Rect) with color(Color).
				/// </summary>
				/// <param name="rect"></param>
				/// <param name="color"></param>
				void fill_rect(IRect rect, IColor color);

				/// <summary>
				/// Clears the entire bitmap.
				/// </summary>
				void clear();

				/// <summary>
				/// Gets the color(Color) at the specified pixel(x, y).
				/// </summary>
				/// <param name="x"></param>
				/// <param name="y"></param>
				/// <returns></returns>
				IColor get_pixel(int x, int y);

				/// <summary>
				/// Sets the specified pixel(x, y) to color(Color).
				/// </summary>
				/// <param name="x"></param>
				/// <param name="y"></param>
				/// <param name="color"></param>
				void set_pixel(int x, int y, IColor color);

				/// <summary>
				/// Changes the bitmap's hue within 360 degrees of displacement.
				/// </summary>
				/// <param name="hue"></param>
				/// This process is time-consuming.Furthermore, due to conversion errors, repeated hue changes may result in color loss.
				void hue_change(ITone hue);

				/// <summary>
				/// Draws a string str in the bitmap box(x, y, width, height) or rect(Rect).
				/// </summary>
				/// <param name="x"></param>
				/// <param name="y"></param>
				/// <param name="width"></param>
				/// <param name="height"></param>
				/// <param name="str">
				/// If the text length exceeds the box's width, the text width will automatically be reduced by up to 60 percent.
				/// </param>
				/// <param name="align">
				/// Horizontal text is left-aligned by default; set align to 1 to center the text and to 2 to right-align it.Vertical text is always centered.
				/// </param>
				/// <remarks>
				/// As this process is time-consuming, redrawing the text with every frame is not recommended.
				/// </remarks>
				void draw_text(float x, float y, float width, float height, string str, int align = 0);

				/// <summary>
				/// Draws a string str in the bitmap box(x, y, width, height) or rect(Rect).
				/// </summary>
				/// <param name="rect"></param>
				/// <param name="str">If the text length exceeds the box's width, the text width will automatically be reduced by up to 60 percent.</param>
				/// <param name="align">Horizontal text is left-aligned by default; set align to 1 to center the text and to 2 to right-align it.Vertical text is always centered.</param>
				/// <remarks>
				/// As this process is time-consuming, redrawing the text with every frame is not recommended.
				/// </remarks>
				void draw_text(IRect rect, string str, int align = 0);

				/// <summary>
				/// Gets the box (Rect) used when drawing a string str with the draw_text method. Does not include the angled portions of italicized text.
				/// </summary>
				/// <param name="str"></param>
				void text_size(string str);
			}
			/// <summary>
			/// The RGB color class. Each component is handled with a floating point value (Float).
			/// </summary>
			public interface IColorRGB : ICloneable
			{
				float red { get; }
				float green { get; }
				float blue { get; }
			}
			/// <summary>
			/// The RGBA color class. Each component is handled with a floating point value (Float).
			/// </summary>
			public interface IColor : IColorRGB //ICloneable
			{
				//float red { get; }
				//float green { get; }
				//float blue { get; }
				float alpha { get; set; }
				/// <summary>
				/// The RGBAA color class. Each component is handled with a floating point value. (0<>255)
				/// </summary>
				/// <param name="red"></param>
				/// <param name="green"></param>
				/// <param name="blue"></param>
				/// <param name="alpha"></param>
				void set(float red, float green, float blue, float alpha = 0);
			}
			/// <summary>
			/// The Plane class. Planes are special sprites that tile bitmap patterns across the entire screen, and are used to display panoramas and fog.
			/// </summary>
			public interface IPlane : IDisposable
			{
				/// <summary>
				/// Refers to the bitmap (Bitmap) used in the plane.
				/// </summary>
				IBitmap windowskin { get; set; }
				/// <summary>
				/// Whether the plane can be seen. If TRUE, the plane is visible.
				/// </summary>
				bool visible { get; set; }
				/// <summary>
				/// The plane's Z-coordinate. The larger this value, the closer to the player the plane will be displayed.
				/// If multiple objects share the same Z-coordinate, the more recently created object will be displayed closest to the player.
				/// </summary>
				float z { get; set; }
				/// <summary>
				/// The X-coordinate of the plane's starting point. Change this value to scroll the plane.
				/// </summary>
				float ox { get; set; }
				/// <summary>
				/// The Y-coordinate of the plane's starting point. Change this value to scroll the plane.
				/// </summary>
				float oy { get; set; }
				/// <summary>
				/// The plane's X-axis zoom level. 1.0 denotes actual pixel size.
				/// </summary>
				float zoom_x { get; set; }
				/// <summary>
				/// The plane's Y-axis zoom level. 1.0 denotes actual pixel size.
				/// </summary>
				float zoom_y { get; set; }
				/// <summary>
				/// The plane's opacity (0-255). Values out of range are automatically corrected.
				/// </summary>
				byte opacity { get; set; }
				/// <summary>
				/// The plane's blending mode (0: normal, 1: addition, 2: subtraction).
				/// </summary>
				byte blend_type { get; set; }
				/// <summary>
				/// The color (Color) to be blended with the plane. Alpha values are used in the blending ratio.
				/// </summary>
				IColor color { get; set; }
				/// <summary>
				/// The plane's color tone (Tone).
				/// </summary>
				ITone tone { get; set; }
				/// <summary>
				/// Retrieves the Viewport (Viewport) specified when the plane was created.
				/// </summary>
				IViewport viewport { get; }
				//void dispose();
				//bool disposed { get; }
				/// <summary>
				/// Creates a Plane object. Specifies a Viewport (Viewport) when necessary.
				/// </summary>
				/// <param name="viewport"></param>
				IPlane initialize(IViewport viewport);
			}
			/// <summary>
			/// Interface for rectangle bounds used in bitmap operations.
			/// </summary>
			public interface IRect
			{
				/// <summary>
				/// The X-coordinate of the rectangle's upper left corner.
				/// </summary>
				float x { get; set; }
				/// <summary>
				/// The Y-coordinate of the rectangle's upper left corner.
				/// </summary>
				float y { get; set; }
				/// <summary>
				/// The rectangle's width.
				/// </summary>
				int width { get; set; }
				/// <summary>
				/// The rectangle's height.
				/// </summary>
				int height { get; set; }
				/// <summary>
				/// Sets all parameters at once.
				/// </summary>
				void set(float x, float y, float width, float height);
			}
			/// <summary>
			/// The sprite class. Sprites are the basic concept used to display characters, etc. on the game screen.
			/// </summary>
			public interface ISprite : IDisposable
			{
				/// <summary>
				/// The sprite's angle of rotation. Specifies up to 360 degrees of counterclockwise rotation.
				/// </summary>
				float angle { get; set; }
				/// <summary>
				/// Refers to the bitmap (Bitmap) used for the sprite's starting point.
				/// </summary>
				IBitmap bitmap { get; set; }
				/// <summary>
				/// The sprite's blending mode (0: normal, 1: addition, 2: subtraction).
				/// </summary>
				int blend_type { get; set; }
				/// <summary>
				/// This can be used to represent something like characters' legs being hidden by bushes.
				/// For bush_depth, the number of pixels for the bush section is specified.The default value is 0.
				/// </summary>
				int bush_depth { get; set; }
				/// <summary>
				/// The color (Color) to be blended with the sprite. Alpha values are used in the blending ratio.
				/// </summary>
				IColor color { get; set; }
				/// <summary>
				/// Returns TRUE if the sprite has been freed.
				/// </summary>
				bool disposed { get; }
				/// <summary>
				/// Flag denoting the sprite has been flipped horizontally. If TRUE, the sprite will be drawn flipped.
				/// </summary>
				bool mirror { get; set; }
				/// <summary>
				/// The sprite's opacity (0-255). Values out of range are automatically corrected.
				/// </summary>
				float opacity { get; set; }
				/// <summary>
				/// The X-coordinate of the sprite's starting point.
				/// </summary>
				float ox { get; set; }
				/// <summary>
				/// The Y-coordinate of the sprite's starting point.
				/// </summary>
				float oy { get; set; }
				IRect src_rect { get; set; }
				ITone tone { get; set; }
				/// <summary>
				/// Refers to the viewport (Viewport) associated with the sprite.
				/// </summary>
				IViewport viewport { get; }
				/// <summary>
				/// The sprite's visibility. If TRUE, the sprite is visible.
				/// </summary>
				bool visible { get; set; }
				/// <summary>
				/// The sprite's X-coordinate.
				/// </summary>
				float x { get; set; }
				/// <summary>
				/// The sprite's Y-coordinate.
				/// </summary>
				float y { get; set; }
				/// <summary>
				/// The sprite's Z-coordinate. The larger this value, the closer to the player the sprite will be displayed.
				/// </summary>
				float z { get; set; }
				/// <summary>
				/// The sprite's X-axis zoom level. 1.0 denotes actual pixel size.
				/// </summary>
				float zoom_x { get; set; }
				/// <summary>
				/// The sprite's Y-axis zoom level. 1.0 denotes actual pixel size.
				/// </summary>
				float zoom_y { get; set; }
				/// <summary>
				/// Gets the width of the sprite. Equivalent to src_rect.width.
				/// </summary>
				float width { get; set; }
				/// <summary>
				/// Gets the height of the sprite. Equivalent to src_rect.height.
				/// </summary>
				float height { get; set; }
				/// <summary>
				/// If a flash or wave is not needed, it is not necessary to call this.
				/// </summary>
				/// <returns></returns>
				void update();
				/// <summary>
				/// Frees the sprite. If the sprite has already been freed, does nothing.
				/// </summary>
				//void Dispose();
				/// <summary>
				/// Begins flashing the sprite. duration specifies the number of frames the flash will last.
				/// If color is set to nil, the sprite will disappear while flashing.
				/// </summary>
				/// <param name="color"></param>
				/// <param name="duration"></param>
				void flash(IColor color, int duration);
				ISprite initialize(IViewport viewport = null);
			}
			/// <summary>
			/// The color tone class. Each component is handled with a floating point value (Float).
			/// </summary>
			public interface ITone : ICloneable
			{
				float red { get; set; }
				float green { get; set; }
				float blue { get; set; }
				float gray { get; set; }
				/// <summary>
				/// The color tone class. Each component is handled with a floating point value. (-255<>255)
				/// </summary>
				/// <param name="red"></param>
				/// <param name="green"></param>
				/// <param name="blue"></param>
				/// <param name="gray">only 0-255</param>
				void set(float red, float green, float blue, float gray = 0);
				//ITone Clone();
			}
			/// <summary>
			/// The viewport class.
			/// Used when displaying sprites in one portion of the screen,
			/// with no overflow into other regions.
			/// </summary>
			public interface IViewport : IDisposable
			{
				int z { get; set; }
				IViewport initialize(float x, float y, float height, float width);
				/// <summary>
				/// The viewport's visibility. If TRUE, the viewport is visible.
				/// </summary>
				bool visible { get; set; }
				/// <summary>
				/// The X-coordinate of the viewport's starting point. Change this value to shake the screen, etc.
				/// </summary>
				float ox { get; }
				/// <summary>
				/// The Y-coordinate of the viewport's starting point. Change this value to shake the screen, etc.
				/// </summary>
				float oy { get; }
				/// <summary>
				/// The color (Color) to be blended with the viewport. Alpha values are used in the blending ratio.
				/// Handled separately from the color blended into a flash effect.
				/// </summary>
				IColor color { get; set; }
				IRect rect { get; set; }
				/// <summary>
				/// Returns TRUE if the viewport has been freed.
				/// </summary>
				bool disposed { get; }
				/// <summary>
				/// Frees the viewport. If the viewport has already been freed, does nothing.
				/// </summary>
				//void dispose();
				/// <summary>
				/// Begins flashing the viewport. duration specifies the number of frames the flash will last.
				/// If color is set to nil, the viewport will disappear while flashing.
				/// </summary>
				/// <param name="color"></param>
				/// <param name="duration"></param>
				void flash(IColor color, int duration);
				/// <summary>
				/// Refreshes the viewport flash. As a rule, this method is called once per frame.
				/// It is not necessary to call this method if no flash effect is needed.
				/// </summary>
				/// <returns></returns>
				void update();
			}
			/// <summary>
			/// The game window class. Created internally from multiple sprites.
			/// </summary>
			public interface IWindow : IDisposable
			{
				/// <summary>
				/// Refers to the bitmap (Bitmap) used as a windowskin.
				/// </summary>
				bool windowskin { get; set; }
				/// <summary>
				/// Refers to the (Viewport) associated with the window.
				/// </summary>
				IViewport viewport { get; set; }
				/// <summary>
				/// The cursor box (Rect). Sets the window's upper left corner using relative coordinates (-16, -16).
				/// </summary>
				//IRect cursor_rect { get; set; }
				/// <summary>
				/// Cursor blink status. If TRUE, the cursor is blinking.
				/// </summary>
				bool active { get; set; }
				/// <summary>
				/// The viewport's visibility. If TRUE, the viewport is visible.
				/// </summary>
				bool visible { get; set; }
				/// <summary>
				/// The pause graphic's visibility. This is a symbol that appears in the message window when waiting for the player to press a button. If TRUE, the graphic is visible.
				/// </summary>
				bool pause { get; set; }
				/// <summary>
				/// The window's X-coordinate.
				/// </summary>
				float x { get; set; }
				/// <summary>
				/// The window's Y-coordinate.
				/// </summary>
				float y { get; set; }
				/// <summary>
				/// The window's width.
				/// </summary>
				float width { get; set; }
				/// <summary>
				/// The window's height.
				/// </summary>
				float height { get; set; }
				/// <summary>
				/// The window's Z-coordinate. The larger this value, the closer to the player the plane will be displayed.
				/// </summary>
				float z { get; set; }
				/// <summary>
				/// The X-coordinate of the viewport's starting point. Change this value to shake the screen, etc.
				/// </summary>
				float ox { get; set; }
				/// <summary>
				/// The Y-coordinate of the viewport's starting point. Change this value to shake the screen, etc.
				/// </summary>
				float oy { get; set; }
				/// <summary>
				/// The window's opacity (0-255).
				/// </summary>
				byte opacity { get; set; }
				/// <summary>
				/// The window background's opacity (0-255).
				/// </summary>
				byte back_opacity { get; set; }
				/// <summary>
				/// The opacity of the window's contents (0-255).
				/// </summary>
				byte contents_opacity { get; set; }
				/// <summary>
				/// By changing this value from 0 (completely closed) to 255 (completely open),
				/// it is possible to create an animation of the window opening and closing.
				/// If the openness is less than 255, the contents of the window will not be displayed.
				/// The default value is 255.
				/// </summary>
				byte openness { get; set; }
				/// <summary>
				/// The color (Color) to be blended with the viewport. Alpha values are used in the blending ratio.
				/// Handled separately from the color blended into a flash effect.
				/// </summary>
				IColor color { get; set; }
				IEnumerator update();
				//void dispose();
				bool disposed { get; }
				/// <summary>
				/// Creates a Window object. Specifies a Viewport (Viewport) when necessary.
				/// </summary>
				/// <param name="viewport"></param>
				IWindow initialize(IViewport viewport);
			}

			namespace Static
			{
				/// <summary>
				/// The module that carries out music and sound processing.
				/// </summary>
				public interface IAudio //: IAudioObject
				{
					int bgm_position { get; set; }
					/// <summary>
					/// Starts BGM playback. Sets the file name, volume, and pitch in turn.
					/// </summary>
					/// <param name="filename"></param>
					/// <param name="volume"></param>
					/// <param name="pitch"></param>
					void bgm_play(string filename, float volume, float pitch, int position = 0);
					/// <summary>
					/// Stops BGM playback.
					/// </summary>
					void bgm_stop();
					/// <summary>
					/// Starts BGM fadeout.
					/// </summary>
					/// <param name="time">time is the length of the fadeout in milliseconds.</param>
					void bgm_fade(float time);
					/// <summary>
					/// Starts BGS playback. Sets the file name, volume, and pitch in turn.
					/// </summary>
					/// <param name="filename"></param>
					/// <param name="volume"></param>
					/// <param name="pitch"></param>
					void bgs_play(string filename, float volume, float pitch);
					/// <summary>
					/// Stops BGS playback.
					/// </summary>
					void bgs_stop();
					/// <summary>
					/// Starts BGS fadeout.
					/// </summary>
					/// <param name="time">time is the length of the fadeout in milliseconds.</param>
					void bgs_fade(float time);
					/// <summary>
					/// Starts ME playback. Sets the file name, volume, and pitch in turn.
					/// When ME is playing, the BGM will temporarily stop.
					/// </summary>
					/// <param name="filename"></param>
					/// <param name="volume"></param>
					/// <param name="pitch"></param>
					void me_play(string filename, float volume, float pitch);
					/// <summary>
					/// Stops ME playback.
					/// </summary>
					void me_stop();
					/// <summary>
					/// Starts ME fadeout.
					/// </summary>
					/// <param name="time">time is the length of the fadeout in milliseconds.</param>
					void me_fade(float time);
					/// <summary>
					/// Starts SE playback. Sets the file name, volume, and pitch in turn.
					/// When attempting to play the same SE more than once in a very short period, they will automatically be filtered to prevent choppy playback.
					/// </summary>
					/// <param name="filename"></param>
					/// <param name="volume"></param>
					/// <param name="pitch"></param>
					void se_play(string filename, float volume, float pitch);
					/// <summary>
					/// Stops ME playback.
					/// </summary>
					void se_stop();
				}
				/// <summary>
				/// The module that carries out graphics processing.
				/// </summary>
				public interface IGraphics
				{
					/// <summary>
					/// The number of times the screen is refreshed per second. The larger the value, the more CPU power is required. Normally set at 60.
					/// Changing this property is not recommended; however, it can be set anywhere from 10 to 120.
					/// </summary>
					int frame_rate { get; set; }
					/// <summary>
					/// The screen's refresh rate count. Set this property to 0 at game start and the game play time (in seconds)
					/// can be calculated by dividing this value by the frame_rate property value.
					/// </summary>
					int frame_count { get; set; }
					/// <summary>
					/// Refreshes the game screen and advances time by 1 frame. This method must be called at set intervals.
					/// </summary>
					/// <returns></returns>
					IEnumerator update();
					/// <summary>
					/// Fixes the current screen in preparation for transitions.
					/// Screen rewrites are prohibited until the transition method is called.
					/// </summary>
					void freeze();
					/// <summary>
					/// Resets the screen refresh timing. After a time-consuming process, call this method to prevent extreme frame skips.
					/// </summary>
					void frame_reset();
				}
				/// <summary>
				/// A module that handles input data from a gamepad or keyboard.
				/// </summary>
				public interface IInput
				{
					#region Variables
					int DOWN				{ get; }	//= 2;
					int LEFT				{ get; }	//= 4;
					int RIGHT				{ get; }	//= 6;
					int UP					{ get; }	//= 8;
					int A					{ get; }	//= 11;
					int B					{ get; }	//= 12;
					int C					{ get; }	//= 13;
					int X					{ get; }	//= 14;
					int Y					{ get; }	//= 15;
					int Z					{ get; }	//= 16;
					int L					{ get; }	//= 17;
					int R					{ get; }	//= 18;
					int SHIFT				{ get; }	//= 21; //SELECT
					int CTRL				{ get; }	//= 22; //START
					int ALT					{ get; }	//= 23;
					int ESC					{ get; }	//= 24;
					int F5					{ get; }	//= 25;
					int F6					{ get; }	//= 26;
					int F7					{ get; }	//= 27;
					int F8					{ get; }	//= 28;
					int F9					{ get; }	//= 29;
					int LeftMouseKey		{ get; }	//= 0;
					int RightMouseKey		{ get; }	//= 1;
					//bool mouse_in_window	{ get; }	//;
					//int mouse_x				{ get; }	//= 0;
					//int mouse_y				{ get; }	//= 0;
					#endregion

					//event ButtonEventArgs OnKeyPress;
					event Action<object, global::PokemonEssentials.EventArg.IButtonEventArgs> OnKeyPress;

					/// <summary>
					/// Updates input data. As a rule, this method is called once per frame.
					/// </summary>
					/// <remarks>
					/// Checks the status of all keys and records the input as key state
					/// until the next update. So all key states are stored for the life of each update.
					/// </remarks>
					/// <returns></returns>
					void update();
					/// <summary>
					/// Determines whether the button number is currently being pressed.
					/// </summary>
					/// <remarks>
					/// The method checks if a specific button (identified by the <paramref name="num"/>) is currently being pressed down at the moment the method is called.
					/// It doesn't consider whether the key was pressed before; it only checks the current state.
					/// This is typically used for actions that should occur continuously while a key is held down.
					/// </remarks>
					/// <param name="num"></param>
					/// <returns>If the button is being pressed, returns TRUE.If not, returns FALSE.</returns>
					//bool press(PokemonUnity.Interface.InputKeys num);
					bool press(int num);
					/// <summary>
					/// Determines whether the button number is being pressed again.
					/// </summary>
					/// <param name="num"></param>
					/// <returns>If the button is being pressed, returns TRUE. If not, returns FALSE.</returns>
					/// <remarks>
					/// The method checks if a specific button has been pressed down in the current frame/update but wasn't pressed in the previous frame.
					/// This is useful for actions that should only happen once when a button is initially pressed.
					/// </remarks>
					/// "Pressed again" is seen as time having passed between the button being not pressed and being pressed.
					//bool trigger(PokemonUnity.Interface.InputKeys num);
					bool trigger(int num);
					/// <summary>
					/// Determines whether the button number is being pressed again.
					/// </summary>
					/// <param name="num"></param>
					/// <returns>If the button is being pressed, returns TRUE. If not, returns FALSE.</returns>
					/// <remarks>
					/// The function is similar to <seealso cref="trigger(int)"/> but with additional logic to allow for repeated action after the button is held down for a certain duration.
					/// This often involves checking the button state over several frames and implementing a delay or timer to allow for initial press and subsequent repeated actions if the button remains pressed.
					/// </remarks>
					/// Unlike <see cref="trigger"/>, takes into account the repeat input of a button being held down continuously.
					//bool repeat(PokemonUnity.Interface.InputKeys num);
					bool repeat(int num);
					/// <summary>
					/// Checks the status of the directional buttons, translates the data into a specialized 4-direction input format, and returns the number pad equivalent (2, 4, 6, 8).
					/// </summary>
					/// <returns>If no directional buttons are being pressed (or the equivalent), returns 0.</returns>
					int dir4();
					/// <summary>
					/// Checks the status of the directional buttons, translates the data into a specialized 8-direction input format, and returns the number pad equivalent (1, 2, 3, 4, 6, 7, 8, 9).
					/// </summary>
					/// <returns>If no directional buttons are being pressed (or the equivalent), returns 0.</returns>
					int dir8();

					//bool KeyPressed(int i_Key); //System.Windows.Forms.Keys
					//void ChangeState(int key, bool state); //System.Windows.Forms.Keys
				}
			}
		}

		[System.Obsolete]
		public interface IAnimation
		{
			int id { get; set; }
			string name { get; set; }
			string animation_name { get; set; }
			int animation_hue { get; set; }
			int position { get; set; }
			int frame_max { get; set; }
			IAnimationFrame[] frames { get; set; }
			IAnimationTiming timings { get; set; }
		}

		[System.Obsolete]
		public interface IAnimationFrame
		{
			int cell_max { get; set; }

			/// <summary>
			/// Generally takes the form cell_data[cell_index, data_index].
			/// </summary>
			/// <remarks>
			/// data_index ranges from 0 to 7 and denotes various information about a cell
			/// (0: pattern,
			/// 1: X-coordinate,
			/// 2: Y-coordinate,
			/// 3: zoom level,
			/// 4: angle of rotation,
			/// 5: horizontal flip,
			/// 6: opacity,
			/// 7: blending mode).
			/// Patterns are 1 less than the number displayed in RPGXP; -1 indicates that that cell is not in use.
			/// </remarks>
			int[,] cell_data { get; set; }
		}

		/// <summary>
		/// Data class for the timing of an animation's SE and flash effects.
		/// </summary>
		[System.Obsolete]
		public interface IAnimationTiming
		{
			/// <summary>
			/// Frame number. 1 less than the number displayed in RPGXP.
			/// </summary>
			int frame { get; set; }
			IAudioSE se { get; set; }
			/// <summary>
			/// Flash area (0: none, 1: target, 2: screen; 3: delete target).
			/// </summary>
			int flash_scope { get; set; }
			IColor flash_color { get; set; }
			int flash_duration { get; set; }
			/// <summary>
			/// Condition of the effect (0: none, 1: hit, 2: miss).
			/// </summary>
			int condition { get; set; }
		}

		public interface IMap
		{
			int tileset_id { get; set; }
			/// <summary>
			/// The map width.
			/// </summary>
			int width { get; set; }
			/// <summary>
			/// The map height.
			/// </summary>
			int height { get; set; }
			/// <summary>
			/// Scroll type (0: No Loop, 1: Vertical Loop, 2: Horizontal Loop, 3: Both Loop).
			/// </summary>
			int scroll_type { get; set; }
			/// <summary>
			/// Truth-value of whether BGM autoswitching is enabled.
			/// </summary>
			bool autoplay_bgm { get; set; }
			/// <summary>
			/// If BGM autoswitching is enabled, the name of that BGM (<see cref="IAudioObject"/>)
			/// </summary>
			IAudioBGM bgm { get; set; }
			/// <summary>
			/// Truth-value of whether BGS autoswitching is enabled.
			/// </summary>
			bool autoplay_bgs { get; set; }
			/// <summary>
			/// If BGS autoswitching is enabled, the name of that BGS (<see cref="IAudioObject"/>)
			/// </summary>
			IAudioBGS bgs { get; set; }
			/// <summary>
			/// Encounter list. A pokemon ID array.
			/// </summary>
			object[] encounter_list { get; set; }
			/// <summary>
			/// Number of steps between encounters.
			/// </summary>
			int encounter_step { get; set; }
			/// <summary>
			/// The map data. A 3-dimensional tile ID array
			/// </summary>
			int[,,] data { get; set; }
			/// <summary>
			/// Map events. A hash that represents <see cref="IMapEvent"/> instances as values, using event IDs as the keys.
			/// </summary>
			IDictionary<int,IMapEvent> events { get; set; }
		}

		public interface IMapInfo
		{
			/// <summary>
			/// The map name.
			/// </summary>
			string name { get; set; }
			/// <summary>
			/// The parent map ID.
			/// </summary>
			int parent_id { get; set; }
			/// <summary>
			/// The map tree display order, used internally.
			/// </summary>
			int order { get; set; }
			/// <summary>
			/// The map tree expansion flag, used internally.
			/// </summary>
			bool expanded { get; set; }
			/// <summary>
			/// The X-axis scroll position, used internally.
			/// </summary>
			int scroll_x { get; set; }
			/// <summary>
			/// The Y-axis scroll position, used internally.
			/// </summary>
			int scroll_y { get; set; }
		}

		public interface IMapEvent
		{
			int id { get; set; }
			string name { get; set; }
			int x { get; set; }
			int y { get; set; }
			IList<IEventPage> pages { get; set; }
		}

		public interface IEventPage
		{
			/// <summary>
			/// The event condition
			/// </summary>
			IEventPageCondition condition { get; set; }
			/// <summary>
			/// The event graphic
			/// </summary>
			IEventPageGraphic graphic { get; set; }
			/// <summary>
			/// Type of movement (0: fixed, 1: random, 2: approach, 3: custom).
			/// </summary>
			int move_type { get; set; }
			/// <summary>
			/// Movement speed (1: x8 slower, 2: x4 slower, 3: x2 slower, 4: normal, 5: x2 faster, 6: x4 faster).
			/// </summary>
			int move_speed { get; set; }
			/// <summary>
			/// Movement frequency (1: lowest, 2: lower, 3: normal, 4: higher, 5: highest).
			/// </summary>
			int move_frequency { get; set; }
			/// <summary>
			/// Movement route. Referenced only when the movement type is set to Custom. <seealso cref="move_type"/>
			/// </summary>
			IMoveRoute move_route { get; set; }
			/// <summary>
			/// Truth value of the [Walking Anim.] option.
			/// </summary>
			bool walk_anime { get; set; }
			bool step_anime { get; set; }
			bool direction_fix { get; set; }
			bool through { get; set; }
			/// <summary>
			/// Priority type (0: below characters, 1: same as characters, 2: above characters).
			/// </summary>
			int priority_type { get; set; }
			bool always_on_top { get; set; }
			/// <summary>
			/// Event trigger (0: action button, 1: player touch, 2: event touch, 3: autorun, 4: parallel process).
			/// </summary>
			int trigger { get; set; }
			/// <summary>
			/// List of event commands.
			/// </summary>
			IList<IEventCommand> list { get; set; }
		}

		public interface IEventPageCondition
		{
			/// <summary>
			/// value for whether the first [Switch] condition is valid.
			/// </summary>
			bool switch1_valid { get; set; }
			/// <summary>
			/// value for whether the second [Switch] condition is valid.
			/// </summary>
			bool switch2_valid { get; set; }
			/// <summary>
			/// value for whether the [Variable] condition is valid.
			/// </summary>
			bool variable_valid { get; set; }
			/// <summary>
			/// value for whether the [Self Switch] condition is valid.
			/// </summary>
			bool self_switch_valid { get; set; }
			/// <summary>
			/// value for whether the [Item] condition is valid.
			/// </summary>
			//bool item_valid { get; set; }
			//bool actor_valid { get; set; }
			/// <summary>
			/// If the first [Switch] condition is valid, the ID of that switch.
			/// </summary>
			int switch1_id { get; set; }
			/// <summary>
			/// If the second [Switch] condition is valid, the ID of that switch.
			/// </summary>
			int switch2_id { get; set; }
			/// <summary>
			/// If the [Variable] condition is valid, the ID of that variable.
			/// </summary>
			int variable_id { get; set; }
			/// <summary>
			/// If the [Variable] condition is valid, the standard value of that variable (x and greater).
			/// </summary>
			int variable_value { get; set; }
			/// <summary>
			/// If the [Self Switch] condition is valid, the letter of that self switch ("A".."D").
			/// </summary>
			char self_switch_ch { get; set; }
		}

		public interface IEventPageGraphic
		{
			/// <summary>
			/// The tile ID. If the specified graphic is not a tile, this value is 0.
			/// </summary>
			int tile_id { get; set; }
			/// <summary>
			/// The character's graphic file name.
			/// </summary>
			string character_name { get; set; }
			int character_hue { get; set; }
			/// <summary>
			/// The character's index of the graphic file (0..7).
			/// </summary>
			int character_index { get; set; }
			/// <summary>
			/// The direction in which the character is facing (2: down, 4: left, 6: right, 8: up).
			/// </summary>
			int direction { get; set; }
			/// <summary>
			/// The character's pattern (0..2).
			/// </summary>
			int pattern { get; set; }
			int opacity { get; set; }
			int blend_type { get; set; }
		}

		public interface IEventCommand
		{
			/// <summary>
			/// The event code.
			/// </summary>
			int code { get; set; }
			/// <summary>
			/// The indent depth. Usually 0; the [Conditional Branch] command, among others, adds 1 with every step deeper.
			/// </summary>
			int indent { get; set; }
			/// <summary>
			/// Array containing the Move command arguments. The contents vary for each command.
			/// </summary>
			//IMoveCommand command { get; set; }
			//IList<IMoveCommand> parameters { get; set; }
			IList<object> parameters { get; set; }
		}

		public interface IMoveRoute
		{
			/// <summary>
			/// value of the [Repeat Action] option.
			/// </summary>
			bool repeat { get; set; }
			/// <summary>
			/// value of the [Skip If Cannot Move] option.
			/// </summary>
			bool skippable { get; set; }
			/// <summary>
			/// value of the [Wait for Completion] option.
			/// </summary>
			bool wait { get; set; }
			/// <summary>
			/// Program contents.
			/// </summary>
			IList<IMoveCommand> list { get; set; }
		}

		public interface IMoveCommand
		{
			/// <summary>
			/// Move command code.
			/// </summary>
			int code { get; set; }
			/// <summary>
			/// Array containing the Move command arguments. The contents vary for each command.
			/// </summary>
			//IList<IMoveParameters> parameters { get; set; }
			IMoveParameters parameters { get; set; }
		}

		public interface IMoveParameters {
			object this[int index] { get; }
		}

		public interface ITileset
		{
			int id { get; set; }
			string name { get; set; }
			string tileset_name { get; set; }
			string[] autotile_names { get; set; }
			string panorama_name { get; set; }
			int panorama_hue { get; set; }
			string fog_name { get; set; }
			int fog_hue { get; set; }
			int fog_opacity { get; set; }
			int fog_blend_type { get; set; }
			int fog_zoom { get; set; }
			int fog_sx { get; set; }
			int fog_sy { get; set; }
			string battleback_name { get; set; }
			/// <summary>
			/// Passage table. A 1-dimensional array (Table) containing passage flags, Bush flags, and counter flags.
			/// </summary>
			/// <remarks>
			/// The tile ID is used as a subscript. Each bit is handled as follows:
			/// 0x01: Cannot move down.
			/// 0x02: Cannot move left.
			/// 0x04: Cannot move right.
			/// 0x08: Cannot move up.
			/// 0x40: Bush flag.
			/// 0x80: Counter flag.
			/// </remarks>
			int[] passages { get; set; }
			int[] priorities { get; set; }
			/// <summary>
			/// Terrain tag table A 1-dimensional array (Table) containing terrain tag data.
			/// </summary>
			/// <remarks>
			/// The tile ID is used as a subscript.
			/// </remarks>
			//global::PokemonEssentials.GameData.Terrains[] terrain_tags { get; set; }
			int[] terrain_tags { get; set; }
		}

		public interface ICommonEvent
		{
			/// <summary>
			/// The event ID.
			/// </summary>
			int id { get; set; }
			/// <summary>
			/// The event name.
			/// </summary>
			string name { get; set; }
			/// <summary>
			/// The event trigger (0: none, 1: autorun; 2: parallel).
			/// </summary>
			int trigger { get; set; }
			/// <summary>
			/// The condition switch ID.
			/// </summary>
			int switch_id { get; set; }
			/// <summary>
			/// List of event commands.
			/// </summary>
			IList<IEventCommand> list { get; set; }
		}

		public interface ISystem
		{
			int magic_number { get; set; }
			/// <summary>
			/// The initial party. An array of actor IDs.
			/// </summary>
			int[] party_members { get; set; }
			/// <summary>
			/// Element list. Text array using element IDs as subscripts, with the element in the 0 position being null.
			/// </summary>
			IDictionary<int, string> elements { get; set; }
			/// <summary>
			/// Switch list. Text array using switch IDs as subscripts, with the element in the 0 position being null.
			/// </summary>
			IDictionary<int, string> switches { get; set; }
			/// <summary>
			/// Variable list. Text array using variable IDs as subscripts, with the element in the 0 position being null.
			/// </summary>
			IDictionary<int, string> variables { get; set; }
			string windowskin_name { get; set; }
			/// <summary>
			/// The game title.
			/// </summary>
			string title_name { get; set; }
			string gameover_name { get; set; }
			string battle_transition { get; set; }
			IAudioBGM title_bgm { get; set; }
			IAudioBGM battle_bgm { get; set; }
			IAudioME battle_end_me { get; set; }
			IAudioME gameover_me { get; set; }
			IAudioSE cursor_se { get; set; }
			IAudioSE decision_se { get; set; }
			IAudioSE cancel_se { get; set; }
			IAudioSE buzzer_se { get; set; }
			IAudioSE equip_se { get; set; }
			IAudioSE shop_se { get; set; }
			IAudioSE save_se { get; set; }
			IAudioSE load_se { get; set; }
			IAudioSE battle_start_se { get; set; }
			IAudioSE escape_se { get; set; }
			IAudioSE actor_collapse_se { get; set; }
			IAudioSE enemy_collapse_se { get; set; }
			/// <summary>
			/// Terms
			/// </summary>
			[System.Obsolete]
			ISystemWords words { get; set; }
			/// <summary>
			/// Party settings for battle tests.
			/// </summary>
			[System.Obsolete]
			ISystemTestBattler[] test_battlers { get; set; }
			/// <summary>
			/// The troop ID for battle tests.
			/// </summary>
			[System.Obsolete]
			int test_troop_id { get; set; }
			/// <summary>
			/// The map ID of the player's initial position.
			/// </summary>
			int start_map_id { get; set; }
			/// <summary>
			/// The map X-coordinate of the player's initial position.
			/// </summary>
			int start_x { get; set; }
			/// <summary>
			/// The map Y-coordinate of the player's initial position.
			/// </summary>
			int start_y { get; set; }
			string battleback_name { get; set; }
			/// <summary>
			/// The battler graphic file name, for internal use.
			/// </summary>
			string battler_name { get; set; }
			/// <summary>
			/// The adjustment value for the battler graphic's hue (0..360), for internal use.
			/// </summary>
			int battler_hue { get; set; }
			/// <summary>
			/// The ID of the map currently being edited, for internal use.
			/// </summary>
			int edit_map_id { get; set; }
		}

		[System.Obsolete]
		public interface ISystemWords
		{
			string gold { get; set; }
			string hp { get; set; }
			string sp { get; set; }
			string str { get; set; }
			string dex { get; set; }
			string agi { get; set; }
			string @int { get; set; }
			string atk { get; set; }
			string pdef { get; set; }
			string mdef { get; set; }
			string weapon { get; set; }
			string armor1 { get; set; }
			string armor2 { get; set; }
			string armor3 { get; set; }
			string armor4 { get; set; }
			string attack { get; set; }
			string skill { get; set; }
			string guard { get; set; }
			string item { get; set; }
			string equip { get; set; }
		}

		[System.Obsolete]
		public interface ISystemTestBattler
		{
			int actor_id { get; set; }
			int level { get; set; }
			int weapon_id { get; set; }
			int armor1_id { get; set; }
			int armor2_id { get; set; }
			int armor3_id { get; set; }
			int armor4_id { get; set; }
		}

		/// <summary>
		/// Data class for audio files. Common to all formats (BGM, BGS, ME, SE).
		/// </summary>
		public interface IAudioFile
		{
			/// <summary>
			/// The sound file name.
			/// </summary>
			string name { get; set; }
			/// <summary>
			/// The sound's volume (0..100). The default values are 100 for BGM and ME and 80 for BGS and SE.
			/// </summary>
			int volume { get; set; }
			/// <summary>
			/// The sound's pitch (50..150). The default value is 100.
			/// </summary>
			int pitch { get; set; }
		}
	}

	namespace Framework
	{
		public interface IFont
		{
			IColor DefaultColor { get; }
			bool exist(string text);
		}
		/// <summary>
		/// The bitmap class. Bitmaps are expressions of so-called graphics.
		/// </summary>
		/// <remarks>
		/// Sprites (Sprite) and other objects must be used to display bitmaps on the screen.
		/// </remarks>
		//public interface IBitmap : global::PokemonEssentials.RPGMaker.Kernel.IBitmap { }
		/// <summary>
		/// The RGB color class. Each component is handled with a floating point value (Float).
		/// </summary>
		public interface IColorRGB : global::PokemonEssentials.RPGMaker.Kernel.IColorRGB { }
		/// <summary>
		/// The RGBA color class. Each component is handled with a floating point value (Float).
		/// </summary>
		public interface IColor : global::PokemonEssentials.RPGMaker.Kernel.IColor, IColorRGB, IColorExtensions {
			IColor default_color { get; }
			new IColor red		{ get; }
			new IColor green	{ get; }
			new IColor blue		{ get; }
			IColor yellow	{ get; }
			IColor magenta	{ get; }
			IColor cyan		{ get; }
			IColor white	{ get; }
			IColor gray		{ get; }
			IColor black	{ get; }
			IColor pink		{ get; }
			IColor orange	{ get; }
			IColor purple	{ get; }
			IColor brown	{ get; }
		}
		/// <summary>
		/// The Plane class. Planes are special sprites that tile bitmap patterns across the entire screen, and are used to display panoramas and fog.
		/// </summary>
		public interface IPlane : global::PokemonEssentials.RPGMaker.Kernel.IPlane { }
		/// <summary>
		/// Interface for rectangle bounds used in bitmap operations.
		/// </summary>
		public interface IRect : global::PokemonEssentials.RPGMaker.Kernel.IRect { }
		/// <summary>
		/// The sprite class. Sprites are the basic concept used to display characters, etc. on the game screen.
		/// </summary>
		public interface ISprite : global::PokemonEssentials.RPGMaker.Kernel.ISprite { }
		/// <summary>
		/// The color tone class. Each component is handled with a floating point value (Float).
		/// </summary>
		public interface ITone : global::PokemonEssentials.RPGMaker.Kernel.ITone { }
		/// <summary>
		/// The viewport class.
		/// Used when displaying sprites in one portion of the screen,
		/// with no overflow into other regions.
		/// </summary>
		public interface IViewport : global::PokemonEssentials.RPGMaker.Kernel.IViewport { }
		/// <summary>
		/// The game window class. Created internally from multiple sprites.
		/// </summary>
		public interface IWindow : global::PokemonEssentials.RPGMaker.Kernel.IWindow { }
	}
}