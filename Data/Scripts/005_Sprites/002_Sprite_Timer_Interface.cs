using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Represents a sprite that displays a timer on the screen.
	/// </summary>
	/// <remarks>
	/// This interface defines the basic functionality for displaying and managing timer sprites
	/// in the game. Timer sprites are used to display countdown timers, stopwatches, or other
	/// time-based visual elements on the screen.
	/// </remarks>
	public interface ISpriteTimer : IHaveUpdate, IDisposable {
		/// <summary>
		/// Initializes the timer sprite with an optional viewport.
		/// </summary>
		/// <param name="viewport">The viewport where the timer will be displayed. Can be null to use the default viewport.</param>
		/// <remarks>
		/// This method should be called when creating a new timer sprite. It sets up the
		/// sprite with the specified viewport, preparing it for display. If no viewport is
		/// provided, the sprite will use the default game viewport.
		/// </remarks>
		ISpriteTimer initialize(IViewport viewport = null);

		/*
		/// <summary>
		/// Gets or sets the visibility of the timer sprite.
		/// </summary>
		/// <remarks>
		/// When setting visibility, also updates the visibility of any associated sprites
		/// or visual elements.
		/// </remarks>
		bool visible { get; set; }

		/// <summary>
		/// Gets or sets the x-coordinate of the timer sprite.
		/// </summary>
		float x { get; set; }

		/// <summary>
		/// Gets or sets the y-coordinate of the timer sprite.
		/// </summary>
		float y { get; set; }

		/// <summary>
		/// Gets or sets the z-order of the timer sprite.
		/// </summary>
		int z { get; set; }

		/// <summary>
		/// Gets or sets the opacity of the timer sprite.
		/// </summary>
		int opacity { get; set; }

		/// <summary>
		/// Gets or sets the bitmap used by the timer sprite.
		/// </summary>
		IBitmap bitmap { get; set; }

		/// <summary>
		/// Gets or sets the source rectangle of the timer sprite.
		/// </summary>
		IRect src_rect { get; set; }

		/// <summary>
		/// Gets or sets the tone of the timer sprite.
		/// </summary>
		ITone tone { get; set; }

		/// <summary>
		/// Gets or sets the color of the timer sprite.
		/// </summary>
		IColor color { get; set; }

		/// <summary>
		/// Gets or sets the blend type of the timer sprite.
		/// </summary>
		int blend_type { get; set; }

		/// <summary>
		/// Gets or sets the zoom factor in the x-direction.
		/// </summary>
		float zoom_x { get; set; }

		/// <summary>
		/// Gets or sets the zoom factor in the y-direction.
		/// </summary>
		float zoom_y { get; set; }

		/// <summary>
		/// Gets or sets the rotation angle of the timer sprite.
		/// </summary>
		float angle { get; set; }

		/// <summary>
		/// Gets or sets whether the timer sprite is mirrored.
		/// </summary>
		bool mirror { get; set; }

		/// <summary>
		/// Gets or sets the origin x-coordinate of the timer sprite.
		/// </summary>
		float ox { get; set; }

		/// <summary>
		/// Gets or sets the origin y-coordinate of the timer sprite.
		/// </summary>
		float oy { get; set; }
		*/

		/// <summary>
		/// Updates the timer sprite's state.
		/// </summary>
		/// <remarks>
		/// This method should be called each frame to update the timer sprite's state,
		/// such as the displayed time, animations, or other visual effects.
		/// </remarks>
		void update();
	}
}