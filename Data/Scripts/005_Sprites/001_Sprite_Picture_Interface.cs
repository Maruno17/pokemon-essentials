using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Represents a sprite that displays a picture on the screen.
	/// </summary>
	/// <remarks>
	/// This interface defines the basic functionality for displaying and managing picture sprites
	/// in the game. Picture sprites are used to display images on the screen, such as event
	/// pictures, backgrounds, or UI elements.
	/// </remarks>
	public interface ISpritePicture : IHaveUpdate, IDisposable {
		/// <summary>
		/// Initializes the picture sprite with a viewport and picture data.
		/// </summary>
		/// <param name="viewport">The viewport where the picture will be displayed.</param>
		/// <param name="picture">The picture data to display.</param>
		/// <remarks>
		/// This method should be called when creating a new picture sprite. It sets up the
		/// sprite with the specified viewport and picture data, preparing it for display.
		/// </remarks>
		/// <exception cref="System.ArgumentNullException">Thrown when viewport or picture is null.</exception>
		void initialize(IViewport viewport, ISprite picture);
		//ISpritePicture initialize(IViewport viewport, IPicture picture);

		/// <summary>
		/// Disposes of the picture sprite and its resources.
		/// </summary>
		/// <remarks>
		/// This method should be called when the picture sprite is no longer needed. It
		/// releases any resources held by the sprite, such as textures or memory.
		/// </remarks>
		void dispose();

		/// <summary>
		/// Updates the picture sprite's state and appearance.
		/// </summary>
		/// <remarks>
		/// This method should be called each frame to update the picture sprite's state,
		/// such as animations, transitions, or other visual effects.
		/// </remarks>
		void update();
	}
}