using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Provides core animation editing functions and utilities.
    /// Contains the main animation manipulation methods including frame management, timing controls, and animation playback functionality.
    /// </summary>
    public interface IAnimEditorFunctions : IBattleAnimationEditor
    {

        /// <summary>
        /// Animation file selection and management interface.
        /// Handles browsing and selecting animation graphics.
        /// </summary>
        /// <param name="canvas">The animation canvas</param>
        /// <param name="animwin">The animation window</param>
        /// <returns>The selected animation file or null if cancelled</returns>
        string selectAnim(object canvas, object animwin);

        /// <summary>
        /// Changes the maximum frame count for the current animation.
        /// Allows extending or truncating animation length.
        /// </summary>
        /// <param name="canvas">The animation canvas</param>
        void changeMaximum(object canvas);

        /// <summary>
        /// Edits the name of the specified animation.
        /// Provides text input interface for animation naming.
        /// </summary>
        /// <param name="animation">The animation to rename</param>
        /// <param name="cmdwin">The command window context</param>
        void animName(object animation, object cmdwin);

        /// <summary>
        /// Displays and manages the animation list interface.
        /// Provides selection and management of multiple animations.
        /// </summary>
        /// <param name="animations">The collection of animations</param>
        /// <param name="canvas">The animation canvas</param>
        /// <param name="animwin">The animation window</param>
        void animList(object animations, object canvas, object animwin);

        /// <summary>
        /// Number selection interface for cell/frame properties.
        /// Provides numeric input with validation.
        /// </summary>
        /// <param name="cel">The animation cell to modify</param>
        /// <returns>The selected number or original value if cancelled</returns>
        int chooseNum(object cel);

        /// <summary>
        /// Sets tone properties for animation sprites.
        /// Provides color adjustment interface for sprite tinting.
        /// </summary>
        /// <param name="cel">The animation cell to modify</param>
        /// <param name="previewsprite">The preview sprite for immediate feedback</param>
        void setTone(object cel, object previewsprite);

        /// <summary>
        /// Sets flash properties for animation effects.
        /// Provides interface for configuring sprite flash effects.
        /// </summary>
        /// <param name="cel">The animation cell to modify</param>
        /// <param name="previewsprite">The preview sprite for immediate feedback</param>
        void setFlash(object cel, object previewsprite);

        /// <summary>
        /// Cell properties editor interface.
        /// Comprehensive property editor for animation cell attributes.
        /// </summary>
        /// <param name="canvas">The animation canvas</param>
        void cellProperties(object canvas);

        /// <summary>
        /// Timing list editor for animation events.
        /// Manages sound effects, background changes, and other timed events.
        /// </summary>
        /// <param name="canvas">The animation canvas</param>
        void timingList(object canvas);

        /// <summary>
        /// Sound effect selection interface.
        /// Provides browsing and selection of audio files for animations.
        /// </summary>
        /// <param name="canvas">The animation canvas</param>
        /// <param name="audio">The audio object to configure</param>
        void selectSE(object canvas, object audio);

        /// <summary>
        /// Background selection interface for timing events.
        /// Provides background image/effect selection for animation timing.
        /// </summary>
        /// <param name="canvas">The animation canvas</param>
        /// <param name="timing">The timing object to configure</param>
        void selectBG(object canvas, object timing);

        /// <summary>
        /// Background effects editor interface.
        /// Comprehensive editor for background animation effects.
        /// </summary>
        /// <param name="canvas">The animation canvas</param>
        /// <param name="timing">The timing object to configure</param>
        void editBG(object canvas, object timing);

        /// <summary>
        /// Frame copying functionality.
        /// Provides copy/paste operations for animation frames.
        /// </summary>
        /// <param name="canvas">The animation canvas</param>
        void copyFrames(object canvas);

        /// <summary>
        /// Frame clearing functionality.
        /// Removes all sprites from selected frames.
        /// </summary>
        /// <param name="canvas">The animation canvas</param>
        void clearFrames(object canvas);

        /// <summary>
        /// Tweening/interpolation functionality.
        /// Creates smooth transitions between animation keyframes.
        /// </summary>
        /// <param name="canvas">The animation canvas</param>
        void tweening(object canvas);

        /// <summary>
        /// Batch operations on animation cells.
        /// Applies changes to multiple cells simultaneously.
        /// </summary>
        /// <param name="canvas">The animation canvas</param>
        void cellBatch(object canvas);

        /// <summary>
        /// Entire animation slide functionality.
        /// Moves all animation elements by specified offset.
        /// </summary>
        /// <param name="canvas">The animation canvas</param>
        void entireSlide(object canvas);

        /// <summary>
        /// Displays the animation editor help window.
        /// Provides user assistance and keyboard shortcuts reference.
        /// </summary>
        void animEditorHelpWindow();

        /// <summary>
        /// Main animation editor entry point.
        /// Initializes and runs the complete animation editing interface.
        /// </summary>
        /// <param name="animation">The animation to edit</param>
        void animationEditorMain(object animation);
    }

    /// <summary>
    /// Mini battler representation for animation preview.
    /// Lightweight battler object used in animation testing.
    /// </summary>
    public interface IMiniBattler
    {
        /// <summary>
        /// The battler's index position (0-3).
        /// </summary>
        int index { get; set; }

        /// <summary>
        /// The Pokemon associated with this battler.
        /// </summary>
        IPokemon pokemon { get; set; }

        /// <summary>
        /// Initializes the mini battler with the specified index.
        /// </summary>
        /// <param name="index">The battler position index</param>
        IMiniBattler initialize(int index);
    }

    /// <summary>
    /// Mini battle scene for animation preview and testing.
    /// Simplified battle environment for animation development.
    /// </summary>
    public interface IMiniBattle
    {
        /// <summary>
        /// Array of battlers in the mini battle scene.
        /// </summary>
        IList<IMiniBattler> battlers { get; set; }

        /// <summary>
        /// Initializes the mini battle with 4 battler positions.
        /// </summary>
        IMiniBattle initialize();
    }

    /// <summary>
    /// Advanced animation property management.
    /// </summary>
    public interface IAnimationPropertyManager
    {
        /// <summary>
        /// Gets the list of editable properties for an animation cell.
        /// </summary>
        /// <param name="cell">The animation cell</param>
        /// <returns>Dictionary of property names and values</returns>
        IDictionary<string, object> getCellProperties(object cell);

        /// <summary>
        /// Sets a property value for an animation cell.
        /// </summary>
        /// <param name="cell">The animation cell</param>
        /// <param name="propertyName">The property to modify</param>
        /// <param name="value">The new property value</param>
        void setCellProperty(object cell, string propertyName, object value);

        /// <summary>
        /// Validates property values for animation cells.
        /// </summary>
        /// <param name="propertyName">The property name</param>
        /// <param name="value">The proposed value</param>
        /// <returns>True if the value is valid for the property</returns>
        bool validatePropertyValue(string propertyName, object value);
    }

    /// <summary>
    /// Animation timing and synchronization management.
    /// </summary>
    public interface IAnimationTimingManager
    {
        /// <summary>
        /// Gets timing events for the specified frame.
        /// </summary>
        /// <param name="frameIndex">The frame index</param>
        /// <returns>List of timing events for the frame</returns>
        IList<object> getFrameTimings(int frameIndex);

        /// <summary>
        /// Adds a timing event to the specified frame.
        /// </summary>
        /// <param name="frameIndex">The frame index</param>
        /// <param name="timingEvent">The timing event to add</param>
        void addFrameTiming(int frameIndex, object timingEvent);

        /// <summary>
        /// Removes a timing event from the specified frame.
        /// </summary>
        /// <param name="frameIndex">The frame index</param>
        /// <param name="timingEvent">The timing event to remove</param>
        void removeFrameTiming(int frameIndex, object timingEvent);

        /// <summary>
        /// Updates timing event properties.
        /// </summary>
        /// <param name="timingEvent">The timing event to modify</param>
        /// <param name="properties">The properties to update</param>
        void updateTimingEvent(object timingEvent, IDictionary<string, object> properties);
    }

    /// <summary>
    /// Animation canvas manipulation and rendering.
    /// </summary>
    public interface IAnimationCanvasManager
    {
        /// <summary>
        /// Refreshes the animation canvas display.
        /// </summary>
        /// <param name="canvas">The canvas to refresh</param>
        void refreshCanvas(object canvas);

        /// <summary>
        /// Sets the current frame being edited.
        /// </summary>
        /// <param name="canvas">The canvas</param>
        /// <param name="frameIndex">The frame index to edit</param>
        void setCurrentFrame(object canvas, int frameIndex);

        /// <summary>
        /// Gets the currently selected animation cells.
        /// </summary>
        /// <param name="canvas">The canvas</param>
        /// <returns>List of selected cell objects</returns>
        IList<object> getSelectedCells(object canvas);

        /// <summary>
        /// Sets the selection state of animation cells.
        /// </summary>
        /// <param name="canvas">The canvas</param>
        /// <param name="cells">The cells to select</param>
        /// <param name="selected">Whether to select or deselect</param>
        void setSelectedCells(object canvas, IList<object> cells, bool selected);
    }
}