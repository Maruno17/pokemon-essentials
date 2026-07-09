using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the credits scene that displays scrolling game credits.
    /// Manages background cycling, text scrolling, and user input during credit display.
    /// </summary>
    /// <remarks>
    /// Scrolls the credits you make below. Original Author unknown.
    ///
    /// - Edited by MiDas Mike so it doesn't play over the Title, but runs by calling
    /// the following:
    ///    $scene = Scene_Credits.new
    ///
    /// - New Edit 3/6/2007 11:14 PM by AvatarMonkeyKirby.
    /// Ok, what I've done is changed the part of the script that was supposed to make
    /// the credits automatically end so that way they actually end! Yes, they will
    /// actually end when the credits are finished! So, that will make the people you
    /// should give credit to now is: Unknown, MiDas Mike, and AvatarMonkeyKirby.
    ///                                             -sincerly yours,
    ///                                               Your Beloved
    /// Oh yea, and I also added a line of code that fades out the BGM so it fades
    /// sooner and smoother.
    ///
    /// - New Edit 24/1/2012 by Maruno.
    /// Added the ability to split a line into two halves with <s>, with each half
    /// aligned towards the centre. Please also credit me if used.
    ///
    /// - New Edit 22/2/2012 by Maruno.
    /// Credits now scroll properly when played with a zoom factor of 0.5. Music can
    /// now be defined. Credits can't be skipped during their first play.
    ///
    /// - New Edit 25/3/2020 by Maruno.
    /// Scroll speed is now independent of frame rate. Now supports non-integer values
    /// for SCROLL_SPEED.
    ///
    /// - New Edit 21/8/2020 by Marin.
    /// Now automatically inserts the credits from the plugins that have been
    /// registered through the PluginManager module.
    /// </remarks>
    public interface ISceneCredits : IScene, IHaveUpdate
    {
        /// <summary>
        /// Adds a collection of names to the credits list with formatting options.
        /// Handles automatic dual-column layout for lists with many names.
        /// </summary>
        /// <param name="credits">The credits list to add names to.</param>
        /// <param name="names">The collection of names to add.</param>
        /// <param name="with_final_new_line">Whether to add a blank line after names (default: true).</param>
        void add_names_to_credits(IList<string> credits, IList<string> names, bool with_final_new_line = true);

        /// <summary>
        /// Generates the complete credits text including game, plugin, and engine credits.
        /// Combines custom game credits with automatically generated framework credits.
        /// </summary>
        /// <returns>List of strings representing all credit lines.</returns>
        IList<string> get_text();

        /// <summary>
        /// Main execution method for the credits scene.
        /// Handles setup, animation loop, music management, and cleanup.
        /// </summary>
        void main();

        /// <summary>
        /// Checks if the credits should be cancelled based on user input.
        /// Allows skipping credits if they have been played before.
        /// </summary>
        /// <returns>True if credits should be cancelled, false otherwise.</returns>
        bool cancel();

        /// <summary>
        /// Checks if the credits have reached their natural ending point.
        /// Determines when all credit text has finished scrolling.
        /// </summary>
        /// <returns>True if credits have finished, false otherwise.</returns>
        bool last();

        /// <summary>
        /// Updates the credits scene each frame.
        /// Handles background cycling, text scrolling, and termination conditions.
        /// </summary>
        void update();
    }
}