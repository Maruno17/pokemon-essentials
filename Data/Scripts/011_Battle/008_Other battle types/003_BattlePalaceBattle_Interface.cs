using System;
using System.Collections.Generic;
using PokemonEssentials.Data;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for Battle Palace battle class that implements nature-based AI behavior.
    /// Extends normal battles with Battle Palace rules where Pokemon act autonomously
    /// based on their nature, using predetermined action percentages for attack, defense, and support moves.
    /// Includes pinch state mechanics that alter behavior when Pokemon reach low HP.
    /// </summary>
    public interface IBattlePalaceBattle : IBattle
    {
        /// <summary>Usual behavior table mapping natures to action percentages [attack, defense, support].</summary>
        Dictionary<INature, int[]> BattlePalaceUsualTable { get; }

        /// <summary>Pinch behavior table mapping natures to action percentages when HP is low.</summary>
        Dictionary<INature, int[]> BattlePalacePinchTable { get; }

        /// <summary>Array tracking if each battler just switched (affects switching probability).</summary>
        bool[] justswitched { get; set; }

        /// <summary>
        /// Initializes a Battle Palace battle with nature-based AI behavior.
        /// Sets up pinch state tracking and configures AI for autonomous Pokemon actions.
        /// </summary>
        // <param name="args">Standard battle initialization arguments</param>
        IBattlePalaceBattle initialize(IScene scene, IList<IPokemon> p1, IList<IPokemon> p2, IList<ITrainer> player, IList<ITrainer> opponent);

        /// <summary>
        /// Categorizes a move for Battle Palace AI decision making.
        /// Classifies moves into attack (0), defense/status (1), or support (2) categories
        /// based on target and effect type for nature-based action selection.
        /// </summary>
        /// <param name="move">Move to categorize</param>
        /// <returns>Move category (0=attack, 1=defense/status, 2=support)</returns>
        int MoveCategory(IMove move);

        /// <summary>
        /// Simplified move availability check for Battle Palace battles.
        /// Ignores certain move restrictions like Imprison, Torment, Taunt, Disable, and Encore
        /// to allow more autonomous Pokemon behavior based on nature preferences.
        /// </summary>
        /// <remarks>
        /// Different implementation of <see cref="pbCanChooseMove"/>, ignores Imprison/Torment/Taunt/Disable/Encore
        /// </remarks>
        /// <param name="idxPokemon">Pokemon index to check</param>
        /// <param name="idxMove">Move index to check</param>
        /// <returns>True if move can be used under Palace rules</returns>
        bool CanChooseMovePartial(int idxPokemon, int idxMove);

        /// <summary>
        /// Registers a move choice for a battler in Battle Palace format.
        /// Simplified move registration that sets move choice without full validation.
        /// Handles struggle move registration when no valid moves are available.
        /// </summary>
        /// <param name="idxBattler">Battler index making the choice</param>
        /// <param name="idxMove">Move index to register (-2 for struggle)</param>
        /// <param name="_showMessages">Whether to show messages (unused)</param>
        void RegisterMove(int idxBattler, int idxMove, bool _showMessages = true);

        /// <summary>
        /// Automatic fight menu selection based on Pokemon nature and state.
        /// Uses nature-based probability tables to determine action category,
        /// then randomly selects an available move within that category.
        /// Accounts for pinch state when Pokemon HP is below 50%.
        /// </summary>
        /// <param name="idxBattler">Battler index making autonomous choice</param>
        /// <returns>True if move was successfully selected</returns>
        bool AutoFightMenu(int idxBattler);

        /// <summary>
        /// Handles transition to pinch state when Pokemon reaches low HP.
        /// Activates when Pokemon HP drops below 50% and they're not already in pinch state.
        /// Changes behavior probabilities and displays nature-specific pinch messages.
        /// Different natures show different behavioral changes in pinch state.
        /// </summary>
        /// <param name="battler">Battler to check for pinch state transition</param>
        void PinchChange(IBattler battler);

        /// <summary>
        /// Handles end of round effects for Battle Palace battles.
        /// Extends base end-of-round processing to check all battlers for pinch state activation.
        /// Ensures pinch behavior changes trigger at appropriate HP thresholds.
        /// </summary>
        void EndOfRoundPhase();
    }

    /// <summary>
    /// Interface for Battle Palace AI extensions that handle autonomous Pokemon behavior.
    /// Implements nature-based decision making for switching and move selection
    /// with consideration for pinch states and Battle Palace specific rules.
    /// </summary>
    public interface IBattleAIBattlePalace : IBattleAI
    {
        /// <summary>Whether this AI is operating under Battle Palace rules.</summary>
        bool battlePalace { get; set; }

        /// <summary>Array tracking recent switch status for each battler position.</summary>
        bool[] justswitched { get; set; }

        /// <summary>
        /// Initializes Battle Palace AI with autonomous behavior tracking.
        /// Sets up switch tracking and configures AI for nature-based decisions.
        /// </summary>
        /// <param name="args">AI initialization arguments</param>
        IBattleAIBattlePalace initialize(IBattle battle);

        /// <summary>
        /// Determines if Pokemon should switch out based on Battle Palace AI logic.
        /// Uses probability calculations based on HP percentage, status conditions,
        /// available party Pokemon, and recent switching history.
        /// Factors in Perish Song countdown and move availability for switching decisions.
        /// </summary>
        /// <param name="force_switch">Whether switch is mandatory</param>
        /// <returns>True if Pokemon should switch out</returns>
        bool ChooseToSwitchOut(bool force_switch = false);
    }
    /*
    /// <summary>
    /// Interface for Battle Palace nature behavior tables.
    /// Provides access to the predetermined action percentages for each nature
    /// in both normal and pinch states for autonomous Pokemon behavior.
    /// </summary>
    public interface IBattlePalaceNatureTables
    {
        /// <summary>
        /// Gets the usual behavior percentages for a specific nature.
        /// Returns array of [attack%, defense%, support%] for normal state.
        /// </summary>
        /// <param name="nature">Nature to get behavior for</param>
        /// <returns>Array of action percentages [attack, defense, support]</returns>
        int[] getUsualBehavior(INature nature);

        /// <summary>
        /// Gets the pinch behavior percentages for a specific nature.
        /// Returns array of [attack%, defense%, support%] for low HP state.
        /// </summary>
        /// <param name="nature">Nature to get pinch behavior for</param>
        /// <returns>Array of action percentages [attack, defense, support]</returns>
        int[] getPinchBehavior(INature nature);

        /// <summary>
        /// Validates that behavior percentages sum to 100 for all natures.
        /// Ensures data integrity of the behavior tables.
        /// </summary>
        /// <returns>True if all behavior tables are valid</returns>
        bool validateBehaviorTables();

        /// <summary>
        /// Gets the pinch message for a specific nature.
        /// Returns the appropriate message text displayed when Pokemon enters pinch state.
        /// </summary>
        /// <param name="nature">Nature to get message for</param>
        /// <returns>Pinch state message text</returns>
        string getPinchMessage(INature nature);
    }

    /// <summary>
    /// Interface for Battle Palace move categorization system.
    /// Handles classification of moves into the three categories used by Battle Palace AI
    /// for nature-based action selection.
    /// </summary>
    public interface IBattlePalaceMoveCategories
    {
        /// <summary>Attack category - offensive moves targeting opponents.</summary>
        int ATTACK_CATEGORY { get; }

        /// <summary>Defense category - defensive moves and status effects targeting self.</summary>
        int DEFENSE_CATEGORY { get; }

        /// <summary>Support category - support moves and battlefield effects.</summary>
        int SUPPORT_CATEGORY { get; }

        /// <summary>
        /// Categorizes a move for Battle Palace decision making.
        /// </summary>
        /// <param name="move">Move to categorize</param>
        /// <returns>Category constant (0=attack, 1=defense, 2=support)</returns>
        int categorizeMove(IMove move);

        /// <summary>
        /// Gets all moves of a specific category for a battler.
        /// </summary>
        /// <param name="battler">Battler to get moves for</param>
        /// <param name="category">Category to filter by</param>
        /// <returns>Array of move indices in the specified category</returns>
        int[] getMovesInCategory(IBattler battler, int category);

        /// <summary>
        /// Checks if a move belongs to a specific category.
        /// </summary>
        /// <param name="move">Move to check</param>
        /// <param name="category">Category to check against</param>
        /// <returns>True if move belongs to category</returns>
        bool isMoveInCategory(IMove move, int category);
    }

    /// <summary>
    /// Interface for Battle Palace pinch state management.
    /// Handles the low HP behavioral changes that occur when Pokemon reach critical health.
    /// </summary>
    public interface IBattlePalacePinchState
    {
        /// <summary>HP threshold percentage for pinch state activation (50%).</summary>
        int PINCH_HP_THRESHOLD { get; }

        /// <summary>
        /// Checks if a battler should enter pinch state.
        /// </summary>
        /// <param name="battler">Battler to check</param>
        /// <returns>True if battler should enter pinch state</returns>
        bool shouldEnterPinchState(IBattler battler);

        /// <summary>
        /// Activates pinch state for a battler.
        /// </summary>
        /// <param name="battler">Battler to activate pinch state for</param>
        void activatePinchState(IBattler battler);

        /// <summary>
        /// Checks if a battler is currently in pinch state.
        /// </summary>
        /// <param name="battler">Battler to check</param>
        /// <returns>True if battler is in pinch state</returns>
        bool isInPinchState(IBattler battler);

        /// <summary>
        /// Gets the appropriate pinch message for a battler's nature.
        /// </summary>
        /// <param name="battler">Battler entering pinch state</param>
        /// <returns>Formatted pinch message text</returns>
        string getPinchMessageForBattler(IBattler battler);

        /// <summary>
        /// Resets pinch state for a battler.
        /// </summary>
        /// <param name="battler">Battler to reset pinch state for</param>
        void resetPinchState(IBattler battler);
    }
    */
}