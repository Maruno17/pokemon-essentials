using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Shows the battle scene fading in while elements slide around into place.
    /// </summary>
    /// <remarks>
    /// Interface for all hardcoded and dynamic battle animations in the scene.
    /// </remarks>
    public interface ISceneAnimationIntro : IAnimation
    {
        /// <summary>Initializes the animation with sprites, viewport, and any additional parameters.</summary>
        ISceneAnimationIntro Initialize(IList<ISprite> sprites, IViewport viewport, IBattle battle);
        /// <summary>Creates the animation processes.</summary>
        void CreateProcesses();
        /// <summary></summary>
        /// <param name="spriteName"></param>
        /// <param name="deltaMult"></param>
        /// <param name="appearTime"></param>
        /// <param name="origin"></param>
        void makeSlideSprite(string spriteName, int deltaMult, float appearTime, int? origin = null);
    }

    /// <summary>
    /// Shows wild Pokémon fading back to their normal color, and triggers their intro
    /// animations.
    /// </summary>
    public interface ISceneAnimationIntro2 : IAnimation
    {
        /// <summary>Initializes the animation with sprites, viewport, and any additional parameters.</summary>
        ISceneAnimationIntro2 Initialize(IList<ISprite> sprites, IViewport viewport, IBattle battle);
        /// <summary>Creates the animation processes.</summary>
        void CreateProcesses();
    }
}