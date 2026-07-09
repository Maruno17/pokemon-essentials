using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Provides enhanced UI controls and button functionality for the battle animation editor.
    /// Contains specialized controls for interactive animation editing including shadow text rendering and base UI control functionality.
    /// </summary>
    //public interface IAnimEditorControlsButtons : IBattleAnimationEditor
    //{
    //}

    /// <summary>
    /// Enhanced shadow text rendering functionality with alignment options.
    /// Used throughout the animation editor UI for readable text display.
    /// </summary>
    public interface IShadowTextRenderer
    {
        /// <summary>
        /// Draws text with shadow effect and proper alignment.
        /// </summary>
        /// <param name="bitmap">The bitmap to draw on</param>
        /// <param name="x">X coordinate for text</param>
        /// <param name="y">Y coordinate for text</param>
        /// <param name="w">Width of text area</param>
        /// <param name="h">Height of text area</param>
        /// <param name="t">Text to draw</param>
        /// <param name="disabled">Whether text appears disabled</param>
        /// <param name="align">Text alignment (0=left, 1=center, 2=right)</param>
        void shadowtext(object bitmap, int x, int y, int w, int h, string t, bool disabled = false, int align = 0);
    }

    /// <summary>
    /// Provides the base class for all UI controls in the animation editor.
    /// Contains common properties and methods shared by all editor UI elements.
    /// </summary>
    public interface IUIControl : IHaveUpdate, IHaveRefresh
    {
        /// <summary>
        /// The bitmap used for rendering the control.
        /// </summary>
        object bitmap { get; set; }

        /// <summary>
        /// The text label displayed by the control.
        /// </summary>
        string label { get; set; }

        /// <summary>
        /// The X coordinate of the control.
        /// </summary>
        int x { get; set; }

        /// <summary>
        /// The Y coordinate of the control.
        /// </summary>
        int y { get; set; }

        /// <summary>
        /// The width of the control.
        /// </summary>
        int width { get; set; }

        /// <summary>
        /// The height of the control.
        /// </summary>
        int height { get; set; }

        /// <summary>
        /// Whether the control's value has been changed.
        /// </summary>
        bool changed { get; set; }

        /// <summary>
        /// The parent container of this control.
        /// </summary>
        object parent { get; set; }

        /// <summary>
        /// Whether the control is disabled and cannot be interacted with.
        /// </summary>
        bool disabled { get; set; }

        /// <summary>
        /// Gets or sets the text content of the control.
        /// </summary>
        string text { get; set; }

        /// <summary>
        /// Initializes the control with the specified label.
        /// </summary>
        /// <param name="label">The text label for the control.</param>
        IUIControl initialize(string label);

        /// <summary>
        /// Converts a relative rectangle to absolute screen coordinates.
        /// </summary>
        /// <param name="rc">The relative rectangle to convert.</param>
        /// <returns>The rectangle in absolute coordinates.</returns>
        object toAbsoluteRect(object rc);

        /// <summary>
        /// Gets the absolute X coordinate of the parent container.
        /// </summary>
        /// <returns>The parent's X coordinate with appropriate offsets.</returns>
        int parentX { get; }

        /// <summary>
        /// Gets the absolute Y coordinate of the parent container.
        /// </summary>
        /// <returns>The parent's Y coordinate with appropriate offsets.</returns>
        int parentY { get; }

        /// <summary>
        /// Redraws the control's visual representation.
        /// </summary>
        void refresh();

        /// <summary>
        /// Updates the control's logic, potentially invalidating it.
        /// </summary>
        void update();
    }

    /// <summary>
    /// Enhanced UI control base with comprehensive state management.
    /// Extends the base UIControl with additional functionality for animation editor needs.
    /// </summary>
    public interface IEnhancedUIControl : IUIControl, IHaveUpdate, IHaveRefresh
    {
        /// <summary>
        /// Whether the control is currently invalid and needs redrawing.
        /// </summary>
        bool invalid { get; }

        /// <summary>
        /// Marks the control as needing to be redrawn.
        /// </summary>
        void invalidate();

        /// <summary>
        /// Updates the control's logic, potentially invalidating it.
        /// </summary>
        void update();

        /// <summary>
        /// Redraws the control's visual representation.
        /// </summary>
        void refresh();

        /// <summary>
        /// Marks the control as no longer needing to be redrawn.
        /// </summary>
        void validate();

        /// <summary>
        /// Redraws the control only if it is currently invalid.
        /// </summary>
        void repaint();
    }

    /// <summary>
    /// Label control for displaying read-only text in the animation editor.
    /// Provides automatic text sizing and shadow text rendering.
    /// </summary>
    public interface ILabel : IEnhancedUIControl, IHaveRefresh
    {
        /// <summary>
        /// Gets or sets the text content of the label.
        /// Setting this automatically refreshes the display.
        /// </summary>
        string text { get; set; }

        /// <summary>
        /// Refreshes the label's visual appearance with proper text sizing.
        /// Automatically calculates text width and applies shadow rendering.
        /// </summary>
        void refresh();
    }

    /// <summary>
    /// Interactive button control with mouse click detection.
    /// Provides visual feedback for pressed/released states.
    /// </summary>
    public interface IButton : IEnhancedUIControl, IHaveUpdate, IHaveRefresh
    {
        /// <summary>
        /// Gets or sets the button's text label.
        /// </summary>
        string label { get; set; }

        /// <summary>
        /// Whether the button is currently being pressed (captured).
        /// </summary>
        bool captured { get; }

        /// <summary>
        /// Initializes the button with the specified label text.
        /// </summary>
        /// <param name="label">The text to display on the button</param>
        IButton initialize(string label);

        /// <summary>
        /// Updates button state based on mouse interaction.
        /// Handles mouse press/release detection and visual feedback.
        /// </summary>
        void update();

        /// <summary>
        /// Refreshes the button's visual appearance including background and outline.
        /// Draws pressed state when captured, normal state otherwise.
        /// </summary>
        /// <returns>The clickable area rectangle for the button</returns>
        object refresh();
    }

    /// <summary>
    /// Checkbox control for boolean value selection.
    /// Extends button functionality with checked/unchecked state.
    /// </summary>
    public interface ICheckbox : IButton, IHaveUpdate, IHaveRefresh
    {
        /// <summary>
        /// Gets whether the checkbox is currently checked.
        /// </summary>
        bool @checked { get; }

        /// <summary>
        /// Gets or sets the current value of the checkbox.
        /// </summary>
        bool curvalue { get; set; }

        /// <summary>
        /// Sets the checked state of the checkbox.
        /// </summary>
        /// <param name="value">The new checked state</param>
        void setChecked(bool value);

        /// <summary>
        /// Initializes the checkbox with the specified label.
        /// </summary>
        /// <param name="label">The text label for the checkbox</param>
        ICheckbox initialize(string label);

        /// <summary>
        /// Updates checkbox state, toggling checked status on click.
        /// </summary>
        void update();

        /// <summary>
        /// Refreshes the checkbox visual appearance with check mark and label.
        /// Displays "X" when checked, empty box when unchecked.
        /// </summary>
        /// <returns>The clickable area rectangle for the checkbox</returns>
        object refresh();
    }

    /// <summary>
    /// Text input field with cursor management and editing capabilities.
    /// Provides full text editing functionality including insertion and deletion.
    /// </summary>
    public interface ITextField : IEnhancedUIControl, IHaveUpdate, IHaveRefresh
    {
        /// <summary>
        /// Gets or sets the field's text label.
        /// </summary>
        string label { get; set; }

        /// <summary>
        /// Gets the current text content of the field.
        /// </summary>
        string text { get; }

        /// <summary>
        /// Sets the text content and resets cursor position.
        /// </summary>
        /// <param name="value">The new text content</param>
        void setText(string value);

        /// <summary>
        /// Gets the current cursor position in the text.
        /// </summary>
        int cursor { get; }

        /// <summary>
        /// Whether the cursor is currently visible (for blinking effect).
        /// </summary>
        bool cursor_shown { get; }

        /// <summary>
        /// Initializes the text field with label and initial text.
        /// </summary>
        /// <param name="label">The field's label text</param>
        /// <param name="text">The initial text content</param>
        ITextField initialize(string label, string text);

        /// <summary>
        /// Inserts a character at the current cursor position.
        /// Advances cursor and marks field as changed.
        /// </summary>
        /// <param name="ch">The character to insert</param>
        void insert(string ch);

        /// <summary>
        /// Deletes the character before the cursor position.
        /// Moves cursor back and marks field as changed.
        /// </summary>
        void delete();

        /// <summary>
        /// Updates the text field state including cursor blinking and navigation.
        /// Handles left/right arrow keys for cursor movement.
        /// </summary>
        void update();

        /// <summary>
        /// Refreshes the text field visual appearance with text and cursor.
        /// Displays blinking cursor at current position when focused.
        /// </summary>
        /// <returns>The clickable area rectangle for the text field</returns>
        object refresh();
    }

    /// <summary>
    /// Numeric input field with increment/decrement button functionality.
    /// Specialized text field for entering and adjusting numeric values.
    /// </summary>
    public interface INumberBox : ITextField, IHaveUpdate, IHaveRefresh
    {
        /// <summary>
        /// Gets or sets the numeric value of the field.
        /// </summary>
        int value { get; set; }

        /// <summary>
        /// The minimum allowed value for the field.
        /// </summary>
        int minimum { get; set; }

        /// <summary>
        /// The maximum allowed value for the field.
        /// </summary>
        int maximum { get; set; }

        /// <summary>
        /// The increment/decrement step size.
        /// </summary>
        int step { get; set; }

        /// <summary>
        /// Initializes the number box with label, value, and constraints.
        /// </summary>
        /// <param name="label">The field's label text</param>
        /// <param name="value">The initial numeric value</param>
        /// <param name="minimum">The minimum allowed value</param>
        /// <param name="maximum">The maximum allowed value</param>
        INumberBox initialize(string label, int value, int minimum, int maximum);

        /// <summary>
        /// Increments the value by the step amount.
        /// Respects maximum value constraint.
        /// </summary>
        void increment();

        /// <summary>
        /// Decrements the value by the step amount.
        /// Respects minimum value constraint.
        /// </summary>
        void decrement();

        /// <summary>
        /// Updates the number box including increment/decrement button handling.
        /// Processes numeric input and validates value ranges.
        /// </summary>
        void update();

        /// <summary>
        /// Refreshes the number box with value display and increment/decrement buttons.
        /// Shows current numeric value and interactive adjustment controls.
        /// </summary>
        /// <returns>The clickable area rectangle for the number box</returns>
        object refresh();
    }

    /// <summary>
    /// Dropdown/combo box control for selecting from a list of options.
    /// Provides expandable list selection with search functionality.
    /// </summary>
    public interface IComboBox : IEnhancedUIControl, IHaveUpdate, IHaveRefresh
    {
        /// <summary>
        /// Gets or sets the list of available options.
        /// </summary>
        IList<string> items { get; set; }

        /// <summary>
        /// Gets or sets the currently selected index.
        /// </summary>
        int selectedIndex { get; set; }

        /// <summary>
        /// Gets the currently selected item text.
        /// </summary>
        string selectedItem { get; }

        /// <summary>
        /// Whether the dropdown list is currently expanded.
        /// </summary>
        bool expanded { get; }

        /// <summary>
        /// Initializes the combo box with label and item list.
        /// </summary>
        /// <param name="label">The field's label text</param>
        /// <param name="items">The list of selectable items</param>
        IComboBox initialize(string label, IList<string> items);

        /// <summary>
        /// Expands or collapses the dropdown list.
        /// </summary>
        /// <param name="expand">Whether to expand (true) or collapse (false)</param>
        void setExpanded(bool expand);

        /// <summary>
        /// Updates the combo box state including dropdown interaction.
        /// Handles list expansion/collapse and item selection.
        /// </summary>
        void update();

        /// <summary>
        /// Refreshes the combo box visual appearance with current selection.
        /// Shows selected item and dropdown arrow, with expanded list if open.
        /// </summary>
        /// <returns>The clickable area rectangle for the combo box</returns>
        object refresh();
    }
}