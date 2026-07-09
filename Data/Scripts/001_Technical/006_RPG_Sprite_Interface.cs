using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    namespace RPG
    {
        /// <summary>
        /// Extensions to Sprite class for animation handling.
        /// </summary>
        public interface ISprite : global::PokemonEssentials.RPGMaker.Kernel.ISprite, IHaveUpdate
        {
            ISprite initialize(IViewport viewport = null);

            /// <summary>
            /// Disposes of all animations.
            /// </summary>
            void dispose();

            /// <summary>
            /// Disposes of regular animations.
            /// </summary>
            void dispose_animation();

            /// <summary>
            /// Disposes of loop animations.
            /// </summary>
            void dispose_loop_animation();

            /// <summary>
            /// Pushes an animation to the specified array.
            /// </summary>
            void pushAnimation(IList<ISpriteAnimation> array, ISpriteAnimation anim);

            /// <summary>
            /// Plays an animation.
            /// </summary>
            void animation(object animation, bool hit, int height = 3, bool no_tone = false);

            /// <summary>
            /// Plays a looping animation.
            /// </summary>
            void loop_animation(object animation);

            /// <summary>
            /// Checks if any animation is currently playing.
            /// </summary>
            bool effect();

            /// <summary>
            /// Updates regular animations.
            /// </summary>
            void update_animation();

            /// <summary>
            /// Updates loop animations.
            /// </summary>
            void update_loop_animation();

            /// <summary>
            /// Updates all animations.
            /// </summary>
            void update();
        }
    }

    /// <summary>
    /// Sprite with floating-point coordinates.
    /// </summary>
    public interface IFloatSprite : RPG.ISprite
    {
        /// <summary>
        /// Gets or sets the X coordinate as a float.
        /// </summary>
        new float x { get; set; }

        /// <summary>
        /// Gets or sets the Y coordinate as a float.
        /// </summary>
        new float y { get; set; }
    }
}