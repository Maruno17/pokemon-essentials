namespace PokemonEssentials
{
    /// <summary>
    /// Interface for managing Safari Zone state and game mechanics
    /// </summary>
    public interface ISafariState
    {
        /// <summary>
        /// Gets or sets the number of Safari Balls remaining
        /// </summary>
        int ballcount { get; set; }

        /// <summary>
        /// Gets or sets the number of Pokemon captured in this Safari game
        /// </summary>
        int captures { get; set; }

        /// <summary>
        /// Gets or sets the decision status for ending the Safari game
        /// </summary>
        int decision { get; set; }

        /// <summary>
        /// Gets or sets the number of steps remaining in the Safari game
        /// </summary>
        int steps { get; set; }

        /// <summary>
        /// Initializes the Safari state with default values
        /// </summary>
        void initialize();

        /// <summary>
        /// Gets the map ID of the Safari Zone reception area
        /// </summary>
        /// <returns>Map ID of the reception area, or 0 if not in progress</returns>
        int ReceptionMap();

        /// <summary>
        /// Checks if a Safari game is currently in progress
        /// </summary>
        /// <returns>True if Safari game is active, false otherwise</returns>
        bool inProgress();

        /// <summary>
        /// Transfers the player to the Safari Zone start location
        /// </summary>
        void GoToStart();

        /// <summary>
        /// Starts a new Safari game with the specified number of balls
        /// </summary>
        /// <param name="ballcount">Number of Safari Balls to start with</param>
        void Start(int ballcount);

        /// <summary>
        /// Ends the current Safari game and resets all state
        /// </summary>
        void End();
    }

    /// <summary>
    /// </summary>
    /// <seealso cref="IMain"/>
    public interface IMainSafariZone : IMain
    {
        bool InSafari { get; }

        ISafariState SafariState { get; }

        BattleResults SafariBattle(int species, int level);

        /// <summary>
        /// Fires whenever the player moves to a new map. Event handler receives the old
        /// map ID or 0 if none.  Also fires when the first map of the game is loaded
        /// </summary>
        /// <example>
        /// <code>
        /// EventHandlers.add(:on_enter_map, :end_safari_game,
        ///   proc { |_old_map_id|
        ///     pbSafariState.pbEnd if !pbInSafari?
        ///   }
        /// )
        /// </code>
        /// </example>
        //event System.EventHandler OnMapChange;
        void on_enter_mapTrigger_end_safari_game(int old_map_id);

        /// <summary>
        /// Fires whenever the player takes a step. The event handler may possibly move
        /// the player elsewhere.
        /// </summary>
        /// <example>
        /// <code>
        /// EventHandlers.add(:on_player_step_taken_can_transfer, :safari_game_counter,
        ///   proc { |handled|
        ///     # handled is an array: [nil]. If [true], a transfer has happened because of
        ///     # this event, so don't do anything that might cause another one
        ///     next if handled[0]
        ///     next if Settings::SAFARI_STEPS == 0 || !pbInSafari? || pbSafariState.decision != 0
        ///     pbSafariState.steps -= 1
        ///     next if pbSafariState.steps > 0
        ///     pbMessage("\\se[Safari Zone end]" + _INTL("PA: Ding-dong!") + "\1")
        ///     pbMessage(_INTL("PA: Your safari game is over!"))
        ///     pbSafariState.decision = 1
        ///     pbSafariState.pbGoToStart
        ///     handled[0] = true
        ///   }
        /// )
        /// </code>
        /// </example>
        //event System.Action<object, EventArg.IOnStepTakenTransferPossibleEventArgs> OnStepTakenTransferPossible;
        void on_player_step_taken_can_transferTrigger_safari_game_counter(bool? handled);

        /// <summary>
        /// Triggers at the start of a wild battle.  Event handlers can provide their own
        /// wild battle routines to override the default behavior.
        /// </summary>
        /// <example>
        /// <code>
        /// EventHandlers.add(:on_calling_wild_battle, :safari_battle,
        ///   proc { |pkmn, handled|
        ///     # handled is an array: [nil]. If [true] or [false], the battle has already
        ///     # been overridden (the boolean is its outcome), so don't do anything that
        ///     # would override it again
        ///     next if !handled[0].nil?
        ///     next if !pbInSafari?
        ///     handled[0] = pbSafariBattle(pkmn)
        ///   }
        /// )
        /// </code>
        /// </example>
        //event System.Action<object, EventArg.IOnWildBattleOverrideEventArgs> OnWildBattleOverride;
        void on_calling_wild_battleTrigger_safari_battle(IPokemon pkmn, bool? handled);
    }

    /// <summary>
    /// Interface for extended pause menu functionality in Safari Zone
    /// </summary>
    public interface IPokemonPauseMenuSafariExtensions
    {
        /// <summary>
        /// Shows Safari Zone specific information (balls and steps remaining)
        /// </summary>
        void ShowInfo();
    }
}