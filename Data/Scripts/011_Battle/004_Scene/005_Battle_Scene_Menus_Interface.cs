using System;
using System.Collections.Generic;
using PokemonEssentials.Data;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for menu base functionality in the battle scene.
    /// </summary>
    //ToDo: Rename to `IBattleSceneMenuBase`?
    public interface IMenuBase : IHaveUpdate, IHaveRefresh, IDisposable
    {
        /// <summary>Gets or sets the X coordinate.</summary>
        int X { get; }
        /// <summary>Gets or sets the Y coordinate.</summary>
        int Y { get; }
        /// <summary>Gets the Z coordinate.</summary>
        int Z { get; set; }
        /// <summary>Gets the visibility state.</summary>
        bool Visible { get; set; }
        /// <summary>Gets the color of the menu.</summary>
        IColor Color { get; set; }
        /// <summary>Gets the current index.</summary>
        int Index { get; set; }
        /// <summary>Gets the current mode.</summary>
        int Mode { get; set; }
        /// <summary>Initializes the menu with an optional viewport.</summary>
        IMenuBase Initialize(IViewport viewport = null);
        /// <summary>Disposes the menu and its resources.</summary>
        void Dispose();
        /// <summary>Returns whether the menu is disposed.</summary>
        bool Disposed();
        /// <summary>Sets the Z coordinate.</summary>
        //void SetZ(int value);
        /// <summary>Sets the visibility state.</summary>
        //void SetVisible(bool value);
        /// <summary>Sets the color of the menu.</summary>
        //void SetColor(IColor value);
        /// <summary>Sets the current index.</summary>
        //void SetIndex(int value);
        /// <summary>Sets the current mode.</summary>
        //void SetMode(int value);
        /// <summary>Adds a sprite to the menu.</summary>
        void AddSprite(string key, ISprite sprite);
        /// <summary>Sets the index and mode simultaneously.</summary>
        void SetIndexAndMode(int index, int mode);
        /// <summary>Refreshes the menu display.</summary>
        void Refresh();
        /// <summary>Updates the menu state.</summary>
        void Update();
    }

    /// <summary>
    /// Interface for the command menu (Fight/Pokémon/Bag/Run).
    /// </summary>
    public interface ICommandMenu : IMenuBase, IHaveRefresh, IDisposable
    {
        /// <summary>
        /// Use graphics for the command menu instead of just text.
        /// </summary>
        /// <remarks>
        /// If true, displays graphics from Graphics/UI/Battle/overlay_command.png
        ///     and Graphics/UI/Battle/cursor_command.png.
        /// If false, just displays text and the command window over the graphic
        ///     Graphics/UI/Battle/overlay_message.png. You will need to edit def
        ///     pbShowWindow to make the graphic appear while the command menu is being
        ///     displayed.
        /// </remarks>
        bool USE_GRAPHICS { get; }
        /// <summary>
        /// Lists of which button graphics to use in different situations/types of battle.
        /// </summary>
        /// <example>
        /// <code>
        /// MODES = [
        ///   [0, 2, 1, 3],   # 0 = Regular battle
        ///   [0, 2, 1, 9],   # 1 = Regular battle with "Cancel" instead of "Run"
        ///   [0, 2, 1, 4],   # 2 = Regular battle with "Call" instead of "Run"
        ///   [5, 7, 6, 3],   # 3 = Safari Zone
        ///   [0, 8, 1, 3]    # 4 = Bug-Catching Contest
        /// ]
        /// </code>
        /// </example>
        int[][] MODES { get; }
        ICommandMenu Initialize(IViewport viewport, int z);
        /// <summary>Sets the texts for the command menu.</summary>
        void SetTexts(IList<string> value);
        /// <summary>Refreshes the button display.</summary>
        void RefreshButtons();
        void Refresh();
    }

    /// <summary>
    /// Interface for the fight menu (choose a move).
    /// </summary>
    public interface IFightMenu : IMenuBase, IHaveRefresh, IDisposable
    {
        /// <summary>
        /// Use graphics for the fight menu instead of just text.
        /// </summary>
        /// <remarks>
        /// If true, displays graphics from Graphics/UI/Battle/overlay_fight.png
        ///     and Graphics/UI/Battle/cursor_fight.png.
        /// If false, just displays text and the command window over the graphic
        ///     Graphics/UI/Battle/overlay_message.png. You will need to edit def
        ///     pbShowWindow to make the graphic appear while the command menu is being
        ///     displayed.
        /// </remarks>
        bool USE_GRAPHICS { get; }
        /// <summary>
        /// Text colours of PP of selected move
        /// </summary>
        /// <example>
        /// <code>
        /// PP_COLORS = [
        ///   Color.new(248, 72, 72), Color.new(136, 48, 48),    # Red, zero PP
        ///   Color.new(248, 136, 32), Color.new(144, 72, 24),   # Orange, 1/4 of total PP or less
        ///   Color.new(248, 192, 0), Color.new(144, 104, 0),    # Yellow, 1/2 of total PP or less
        ///   TEXT_BASE_COLOR, TEXT_SHADOW_COLOR                 # Black, more than 1/2 of total PP
        /// ]
        /// </code>
        /// </example>
        int[][] PP_COLORS { get; }
        /// <summary>Gets the battler associated with the menu.</summary>
        IBattler Battler { get; set; }
        /// <summary>Gets the shift mode state.</summary>
        int ShiftMode { get; set; }
        int z { set; }
        IFightMenu Initialize(IViewport viewport, int z);
        /// <summary>Refreshes the button names.</summary>
        void RefreshButtonNames();
        /// <summary>Refreshes the selection display.</summary>
        void RefreshSelection();
        /// <summary>Refreshes the move data display.</summary>
        void RefreshMoveData(IMove move);
        /// <summary>Refreshes the Mega Evolution button.</summary>
        void RefreshMegaEvolutionButton();
        /// <summary>Refreshes the Shift button.</summary>
        void RefreshShiftButton();
        void Refresh();
    }

    /// <summary>
    /// Target menu (choose a move's target).
    /// </summary>
    /// <remarks>
    /// Interface for the target menu (choose a move's target).
    /// NOTE: Unlike the command and fight menus, this one doesn't have a textbox-only
    ///       version.
    /// </remarks>
    public interface ITargetMenu : IMenuBase, IHaveRefresh, IDisposable
    {
        /// <summary>
        /// Lists of which button graphics to use in different situations/types of battle.
        /// </summary>
        /// <example>
        /// <code>
        /// MODES = [
        ///   [0, 2, 1, 3],   # 0 = Regular battle
        ///   [0, 2, 1, 9],   # 1 = Regular battle with "Cancel" instead of "Run"
        ///   [0, 2, 1, 4],   # 2 = Regular battle with "Call" instead of "Run"
        ///   [5, 7, 6, 3],   # 3 = Safari Zone
        ///   [0, 8, 1, 3]    # 4 = Bug-Catching Contest
        /// ]
        /// </code>
        /// </example>
        int[][] MODES { get; }
        /// <summary>Gets or sets the mode for the target menu.</summary>
        int Mode { get; set; }
        int z { set; }
        ITargetMenu Initialize(IViewport viewport, int z, IList<int> sideSizes);
        /// <summary>Sets the details for the target menu.</summary>
        void SetDetails(IList<string> texts, int mode);
        /// <summary>Refreshes the button display.</summary>
        void RefreshButtons();
        void Refresh();
    }
}