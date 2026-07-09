using System;
using PokemonEssentials.Data;

namespace PokemonEssentials
{
    /*
    /// <summary>
    /// Interface for item battle effect handler system.
    /// Manages item usage validation and effects specifically during battle,
    /// including usage restrictions, targeting, and battle-specific behaviors.
    /// </summary>
    public interface IItemBattleEffectHandlers
    {
        /// <summary>Can use in battle handlers for usage validation.</summary>
        ICanUseInBattleHandlers canUseInBattleHandlers { get; }

        /// <summary>Use in battle handlers for item effects.</summary>
        IUseInBattleHandlers useInBattleHandlers { get; }

        /// <summary>Battle use text handlers for display messages.</summary>
        IBattleUseTextHandlers battleUseTextHandlers { get; }

        /// <summary>Item uses all actions handlers for action consumption.</summary>
        IItemUsesAllActionsHandlers itemUsesAllActionsHandlers { get; }

        /// <summary>
        /// Initializes item battle effect handler system.
        /// Sets up all battle-specific item handlers and validation.
        /// </summary>
        void initialize();

        /// <summary>
        /// Checks if item can be used in current battle context.
        /// Validates usage restrictions and battle conditions.
        /// </summary>
        /// <param name="item">Item to check</param>
        /// <param name="battle">Current battle instance</param>
        /// <param name="battler">Battler using item</param>
        /// <returns>True if item can be used</returns>
        bool canUseInBattle(IItem item, IBattle battle, IBattler battler);

        /// <summary>
        /// Executes item effect in battle.
        /// Applies item's battle-specific effects and consequences.
        /// </summary>
        /// <param name="item">Item being used</param>
        /// <param name="battle">Current battle instance</param>
        /// <param name="battler">Battler using item</param>
        /// <returns>True if item was successfully used</returns>
        bool useInBattle(IItem item, IBattle battle, IBattler battler);
    }

    /// <summary>
    /// Interface for can use in battle handler system.
    /// Validates whether specific items can be used in current battle situations,
    /// checking conditions, restrictions, and battle state requirements.
    /// </summary>
    public interface ICanUseInBattleHandlers
    {
        /// <summary>
        /// Validates Guard Spec usage in battle.
        /// Checks if Mist effect is already active on battler's side.
        /// </summary>
        /// <param name="item">Guard Spec item</param>
        /// <param name="pokemon">Target Pokemon</param>
        /// <param name="battler">Target battler</param>
        /// <param name="move">Associated move (if any)</param>
        /// <param name="firstAction">Whether this is first action this turn</param>
        /// <param name="battle">Current battle instance</param>
        /// <param name="scene">Battle scene for messages</param>
        /// <param name="showMessages">Whether to display error messages</param>
        /// <returns>True if Guard Spec can be used</returns>
        bool canUseGuardSpec(IItem item, IPokemon pokemon, IBattler battler, IMove move, bool firstAction, IBattle battle, IBattleScene scene, bool showMessages);

        /// <summary>
        /// Validates Poke Doll usage in battle.
        /// Checks if battle is wild battle and escape is allowed.
        /// </summary>
        /// <param name="item">Poke Doll item</param>
        /// <param name="pokemon">Target Pokemon</param>
        /// <param name="battler">Target battler</param>
        /// <param name="move">Associated move (if any)</param>
        /// <param name="firstAction">Whether this is first action this turn</param>
        /// <param name="battle">Current battle instance</param>
        /// <param name="scene">Battle scene for messages</param>
        /// <param name="showMessages">Whether to display error messages</param>
        /// <returns>True if Poke Doll can be used</returns>
        bool canUsePokeDoll(IItem item, IPokemon pokemon, IBattler battler, IMove move, bool firstAction, IBattle battle, IBattleScene scene, bool showMessages);

        /// <summary>
        /// Validates Poke Ball usage in battle.
        /// Checks storage space, ball restrictions, targeting, and timing requirements.
        /// </summary>
        /// <param name="item">Poke Ball item</param>
        /// <param name="pokemon">Target Pokemon</param>
        /// <param name="battler">Target battler</param>
        /// <param name="move">Associated move (if any)</param>
        /// <param name="firstAction">Whether this is first action this turn</param>
        /// <param name="battle">Current battle instance</param>
        /// <param name="scene">Battle scene for messages</param>
        /// <param name="showMessages">Whether to display error messages</param>
        /// <returns>True if Poke Ball can be used</returns>
        bool canUsePokeBall(IItem item, IPokemon pokemon, IBattler battler, IMove move, bool firstAction, IBattle battle, IBattleScene scene, bool showMessages);

        /// <summary>
        /// Validates healing item usage in battle.
        /// Checks if Pokemon needs healing and can be healed.
        /// </summary>
        /// <param name="item">Healing item</param>
        /// <param name="pokemon">Target Pokemon</param>
        /// <param name="battler">Target battler</param>
        /// <param name="move">Associated move (if any)</param>
        /// <param name="firstAction">Whether this is first action this turn</param>
        /// <param name="battle">Current battle instance</param>
        /// <param name="scene">Battle scene for messages</param>
        /// <param name="showMessages">Whether to display error messages</param>
        /// <returns>True if healing item can be used</returns>
        bool canUseHealingItem(IItem item, IPokemon pokemon, IBattler battler, IMove move, bool firstAction, IBattle battle, IBattleScene scene, bool showMessages);

        /// <summary>
        /// Validates X item (stat boost) usage in battle.
        /// Checks if stat can be boosted further.
        /// </summary>
        /// <param name="item">X stat item</param>
        /// <param name="pokemon">Target Pokemon</param>
        /// <param name="battler">Target battler</param>
        /// <param name="move">Associated move (if any)</param>
        /// <param name="firstAction">Whether this is first action this turn</param>
        /// <param name="battle">Current battle instance</param>
        /// <param name="scene">Battle scene for messages</param>
        /// <param name="showMessages">Whether to display error messages</param>
        /// <returns>True if X item can be used</returns>
        bool canUseXItem(IItem item, IPokemon pokemon, IBattler battler, IMove move, bool firstAction, IBattle battle, IBattleScene scene, bool showMessages);

        /// <summary>
        /// Registers can use in battle handler for item.
        /// Associates validation logic with specific item type.
        /// </summary>
        /// <param name="item">Item to register handler for</param>
        /// <param name="handler">Validation function</param>
        void registerCanUseHandler(IItem item, System.Func<IItem, IPokemon, IBattler, IMove, bool, IBattle, IBattleScene, bool, bool> handler);
    }

    /// <summary>
    /// Interface for use in battle handler system.
    /// Executes item effects when used during battle,
    /// handling stat changes, healing, escape, and other battle outcomes.
    /// </summary>
    public interface IUseInBattleHandlers
    {
        /// <summary>
        /// Executes Guard Spec effect in battle.
        /// Applies Mist effect to prevent stat reduction.
        /// </summary>
        /// <param name="item">Guard Spec item</param>
        /// <param name="battler">Battler using item</param>
        /// <param name="battle">Current battle instance</param>
        /// <param name="scene">Battle scene for effects</param>
        /// <returns>True if effect was applied</returns>
        bool useGuardSpec(IItem item, IBattler battler, IBattle battle, IBattleScene scene);

        /// <summary>
        /// Executes Poke Doll effect in battle.
        /// Forces successful escape from wild battle.
        /// </summary>
        /// <param name="item">Poke Doll item</param>
        /// <param name="battler">Battler using item</param>
        /// <param name="battle">Current battle instance</param>
        /// <param name="scene">Battle scene for effects</param>
        /// <returns>True if escape was successful</returns>
        bool usePokeDoll(IItem item, IBattler battler, IBattle battle, IBattleScene scene);

        /// <summary>
        /// Executes Poke Ball effect in battle.
        /// Attempts to capture target Pokemon.
        /// </summary>
        /// <param name="item">Poke Ball item</param>
        /// <param name="battler">Battler using item</param>
        /// <param name="targetBattler">Target battler to capture</param>
        /// <param name="battle">Current battle instance</param>
        /// <param name="scene">Battle scene for effects</param>
        /// <returns>True if capture attempt was made</returns>
        bool usePokeBall(IItem item, IBattler battler, IBattler targetBattler, IBattle battle, IBattleScene scene);

        /// <summary>
        /// Executes healing item effect in battle.
        /// Restores HP to target Pokemon.
        /// </summary>
        /// <param name="item">Healing item</param>
        /// <param name="battler">Battler using item</param>
        /// <param name="targetPokemon">Target Pokemon to heal</param>
        /// <param name="battle">Current battle instance</param>
        /// <param name="scene">Battle scene for effects</param>
        /// <returns>True if healing was applied</returns>
        bool useHealingItem(IItem item, IBattler battler, IPokemon targetPokemon, IBattle battle, IBattleScene scene);

        /// <summary>
        /// Executes X item effect in battle.
        /// Raises target battler's stat by specified amount.
        /// </summary>
        /// <param name="item">X stat item</param>
        /// <param name="battler">Target battler</param>
        /// <param name="battle">Current battle instance</param>
        /// <param name="scene">Battle scene for effects</param>
        /// <returns>True if stat was boosted</returns>
        bool useXItem(IItem item, IBattler battler, IBattle battle, IBattleScene scene);

        /// <summary>
        /// Registers use in battle handler for item.
        /// Associates battle effect logic with specific item type.
        /// </summary>
        /// <param name="item">Item to register handler for</param>
        /// <param name="handler">Battle effect function</param>
        void registerUseHandler(IItem item, System.Func<IItem, IBattler, IBattle, IBattleScene, bool> handler);
    }

    /// <summary>
    /// Interface for battle use text handler system.
    /// Manages display messages when items are used during battle,
    /// providing appropriate text for different item types and situations.
    /// </summary>
    public interface IBattleUseTextHandlers
    {
        /// <summary>
        /// Gets use text for Poke Ball in battle.
        /// Returns appropriate throwing message for ball type.
        /// </summary>
        /// <param name="item">Poke Ball item</param>
        /// <param name="battler">Battler using ball</param>
        /// <returns>Battle use text</returns>
        string getPokeBallUseText(IItem item, IBattler battler);

        /// <summary>
        /// Gets use text for healing item in battle.
        /// Returns appropriate healing message for item type.
        /// </summary>
        /// <param name="item">Healing item</param>
        /// <param name="pokemon">Pokemon being healed</param>
        /// <returns>Battle use text</returns>
        string getHealingItemUseText(IItem item, IPokemon pokemon);

        /// <summary>
        /// Gets use text for X item in battle.
        /// Returns appropriate stat boost message for item type.
        /// </summary>
        /// <param name="item">X stat item</param>
        /// <param name="battler">Battler receiving boost</param>
        /// <returns>Battle use text</returns>
        string getXItemUseText(IItem item, IBattler battler);

        /// <summary>
        /// Gets use text for escape item in battle.
        /// Returns appropriate escape message for item type.
        /// </summary>
        /// <param name="item">Escape item</param>
        /// <param name="battler">Battler escaping</param>
        /// <returns>Battle use text</returns>
        string getEscapeItemUseText(IItem item, IBattler battler);

        /// <summary>
        /// Registers battle use text handler for item.
        /// Associates custom text with specific item usage in battle.
        /// </summary>
        /// <param name="item">Item to register text for</param>
        /// <param name="handler">Text generation function</param>
        void registerBattleUseTextHandler(IItem item, System.Func<IItem, object, string> handler);
    }

    /// <summary>
    /// Interface for item uses all actions handler system.
    /// Determines which items consume all remaining actions for the battle turn,
    /// preventing additional actions after certain item usage.
    /// </summary>
    public interface IItemUsesAllActionsHandlers
    {
        /// <summary>
        /// Checks if Poke Ball usage consumes all actions.
        /// Poke Balls typically end the turn when thrown.
        /// </summary>
        /// <param name="item">Poke Ball item</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if all actions are consumed</returns>
        bool pokeBallUsesAllActions(IItem item, IBattle battle);

        /// <summary>
        /// Checks if escape item usage consumes all actions.
        /// Escape items typically end the turn when used.
        /// </summary>
        /// <param name="item">Escape item</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if all actions are consumed</returns>
        bool escapeItemUsesAllActions(IItem item, IBattle battle);

        /// <summary>
        /// Checks if healing item usage consumes remaining actions.
        /// Most healing items allow continued actions after use.
        /// </summary>
        /// <param name="item">Healing item</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if all actions are consumed</returns>
        bool healingItemUsesAllActions(IItem item, IBattle battle);

        /// <summary>
        /// Default check for action consumption.
        /// Returns false unless item has specific action consumption rules.
        /// </summary>
        /// <param name="item">Item to check</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if all actions are consumed</returns>
        bool defaultUsesAllActions(IItem item, IBattle battle);

        /// <summary>
        /// Registers uses all actions handler for item.
        /// Associates action consumption logic with specific item type.
        /// </summary>
        /// <param name="item">Item to register handler for</param>
        /// <param name="handler">Action consumption function</param>
        void registerUsesAllActionsHandler(IItem item, System.Func<IItem, IBattle, bool> handler);
    }

    /// <summary>
    /// Interface for battle item validation context.
    /// Provides context information for validating item usage in battle situations.
    /// </summary>
    public interface IBattleItemValidationContext
    {
        /// <summary>Item being validated.</summary>
        IItem item { get; }

        /// <summary>Pokemon associated with item usage.</summary>
        IPokemon pokemon { get; }

        /// <summary>Battler using or targeting item.</summary>
        IBattler battler { get; }

        /// <summary>Move associated with item usage (if any).</summary>
        IMove move { get; }

        /// <summary>Whether this is the first action of the turn.</summary>
        bool firstAction { get; }

        /// <summary>Current battle instance.</summary>
        IBattle battle { get; }

        /// <summary>Battle scene for displaying messages.</summary>
        IBattleScene scene { get; }

        /// <summary>Whether error messages should be shown.</summary>
        bool showMessages { get; }

        /// <summary>
        /// Creates validation context from battle parameters.
        /// </summary>
        /// <param name="item">Item being used</param>
        /// <param name="pokemon">Target Pokemon</param>
        /// <param name="battler">Using battler</param>
        /// <param name="move">Associated move</param>
        /// <param name="firstAction">First action flag</param>
        /// <param name="battle">Battle instance</param>
        /// <param name="scene">Battle scene</param>
        /// <param name="showMessages">Show messages flag</param>
        void initialize(IItem item, IPokemon pokemon, IBattler battler, IMove move, bool firstAction, IBattle battle, IBattleScene scene, bool showMessages);

        /// <summary>
        /// Validates basic usage requirements.
        /// Checks common restrictions that apply to most battle items.
        /// </summary>
        /// <returns>True if basic requirements are met</returns>
        bool validateBasicRequirements();
    }
    */
}