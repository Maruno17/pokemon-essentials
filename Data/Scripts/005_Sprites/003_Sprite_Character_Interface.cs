using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Represents a sprite for displaying a game character on the screen.
    /// </summary>
    /// <remarks>
    /// This interface defines the basic functionality for displaying and managing character sprites
    /// in the game. Character sprites are used to display players, NPCs, and events, including
    /// their animations, bush depth effects, reflections, and other visual aspects.
    /// </remarks>
    public interface ISpriteCharacter : PokemonEssentials.RPGMaker.Kernel.ISprite, IHaveUpdate, IDisposable //ToDo: Remove disposable?
    {
        ISpriteCharacter initialize(IViewport viewport, IGameCharacter character = null);

        /// <summary>
        /// Gets or sets the game character to display.
        /// </summary>
        /// <remarks>
        /// The character to display on the sprite.
        /// </remarks>
        IGameCharacter character { get; set; }

        /// <summary>
        /// Gets the Y-coordinate of the character's ground position.
        /// </summary>
        /// <returns>The Y-coordinate of the character's ground position.</returns>
        /// <remarks>
        /// Returns the Y-coordinate where the character is standing on the ground,
        /// taking into account any height adjustments.
        /// </remarks>
        float groundY();

        /// <summary>
        /// Gets or sets the visibility of the character sprite.
        /// </summary>
        /// <remarks>
        /// When setting visibility, also updates the visibility of the reflection sprite
        /// if one exists.
        /// </remarks>
        bool visible { get; set; }

        /*
        /// <summary>
        /// Gets or sets the x-coordinate of the character sprite.
        /// </summary>
        float x { get; set; }

        /// <summary>
        /// Gets or sets the y-coordinate of the character sprite.
        /// </summary>
        float y { get; set; }

        /// <summary>
        /// Gets or sets the z-order of the character sprite.
        /// </summary>
        int z { get; set; }

        /// <summary>
        /// Gets or sets the opacity of the character sprite.
        /// </summary>
        int opacity { get; set; }

        /// <summary>
        /// Gets or sets the bitmap used by the character sprite.
        /// </summary>
        IBitmap bitmap { get; set; }

        /// <summary>
        /// Gets or sets the source rectangle of the character sprite.
        /// </summary>
        IRect src_rect { get; set; }

        /// <summary>
        /// Gets or sets the tone of the character sprite.
        /// </summary>
        ITone tone { get; set; }

        /// <summary>
        /// Gets or sets the color of the character sprite.
        /// </summary>
        IColor color { get; set; }

        /// <summary>
        /// Gets or sets the blend type of the character sprite.
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
        /// Gets or sets the rotation angle of the character sprite.
        /// </summary>
        float angle { get; set; }

        /// <summary>
        /// Gets or sets whether the character sprite is mirrored.
        /// </summary>
        bool mirror { get; set; }

        /// <summary>
        /// Gets or sets the origin x-coordinate of the character sprite.
        /// </summary>
        float ox { get; set; }

        /// <summary>
        /// Gets or sets the origin y-coordinate of the character sprite.
        /// </summary>
        float oy { get; set; }
        */

        /// <summary>
        /// Refreshes the character's graphic based on its current state.
        /// </summary>
        /// <remarks>
        /// Updates the character's visual representation based on its tile ID, character name,
        /// hue, and bush depth. This method handles both tile-based and character-based sprites,
        /// and manages the appropriate bitmap resources.
        /// </remarks>
        void refresh_graphic();

        /// <summary>
        /// Updates the character sprite's state.
        /// </summary>
        /// <remarks>
        /// This method is called each frame to update the character's visual state, including:
        /// - Refreshing the character's graphic
        /// - Updating animations
        /// - Applying bush depth effects
        /// - Updating position and visibility
        /// - Handling reflections and surf base effects
        /// - Applying day/night tinting
        /// </remarks>
        void update();
    }
}