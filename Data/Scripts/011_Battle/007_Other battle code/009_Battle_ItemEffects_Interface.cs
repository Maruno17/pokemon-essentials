using System;
using PokemonEssentials.Data;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for battle item effects module that manages all item-based triggers and handlers.
    /// Provides a comprehensive system for handling held items during battle including
    /// stat calculations, status effects, damage calculations, healing effects, and event responses.
    /// Contains organized handler collections for different item trigger types and timing.
    /// </summary>
    public interface IItemEffects
    {
        /// <summary>Handler collection for Speed calculation modifications.</summary>
        IItemHandlerHash SpeedCalc { get; }

        /// <summary>Handler collection for weight calculation modifications (e.g., Float Stone).</summary>
        IItemHandlerHash WeightCalc { get; }

        /// <summary>Handler collection for HP healing effects.</summary>
        IItemHandlerHash HPHeal { get; }

        /// <summary>Handler collection for stat loss responses.</summary>
        IItemHandlerHash OnStatLoss { get; }

        /// <summary>Handler collection for status condition curing effects.</summary>
        IItemHandlerHash StatusCure { get; }

        /// <summary>Handler collection for stat loss immunity effects.</summary>
        IItemHandlerHash StatLossImmunity { get; }

        /// <summary>Handler collection for priority bracket modifications.</summary>
        IItemHandlerHash PriorityBracketChange { get; }

        /// <summary>Handler collection for priority bracket usage responses.</summary>
        IItemHandlerHash PriorityBracketUse { get; }

        /// <summary>Handler collection for missing target responses (e.g., Blunder Policy).</summary>
        IItemHandlerHash OnMissingTarget { get; }

        /// <summary>Handler collection for accuracy calculations from the user's items.</summary>
        IItemHandlerHash AccuracyCalcFromUser { get; }

        /// <summary>Handler collection for accuracy calculations from the target's items.</summary>
        IItemHandlerHash AccuracyCalcFromTarget { get; }

        /// <summary>Handler collection for damage calculations from the user's items.</summary>
        IItemHandlerHash DamageCalcFromUser { get; }

        /// <summary>Handler collection for damage calculations from the target's items.</summary>
        IItemHandlerHash DamageCalcFromTarget { get; }

        /// <summary>Handler collection for critical hit calculations from the user's items.</summary>
        IItemHandlerHash CriticalCalcFromUser { get; }

        /// <summary>Handler collection for critical hit calculations from the target's items.</summary>
        IItemHandlerHash CriticalCalcFromTarget { get; }

        /// <summary>Handler collection for being hit responses.</summary>
        IItemHandlerHash OnBeingHit { get; }

        /// <summary>Handler collection for positive berry effects when being hit.</summary>
        IItemHandlerHash OnBeingHitPositiveBerry { get; }

        /// <summary>Handler collection for post-move responses from targets.</summary>
        IItemHandlerHash AfterMoveUseFromTarget { get; }

        /// <summary>Handler collection for post-move responses from users.</summary>
        IItemHandlerHash AfterMoveUseFromUser { get; }

        /// <summary>Handler collection for end of move usage effects (e.g., Leppa Berry).</summary>
        IItemHandlerHash OnEndOfUsingMove { get; }

        /// <summary>Handler collection for stat restoration after move usage (e.g., White Herb).</summary>
        IItemHandlerHash OnEndOfUsingMoveStatRestore { get; }

        /// <summary>Handler collection for experience gain modifications (e.g., Lucky Egg).</summary>
        IItemHandlerHash ExpGainModifier { get; }

        /// <summary>Handler collection for EV gain modifications.</summary>
        IItemHandlerHash EVGainModifier { get; }

        /// <summary>Handler collection for weather duration extensions.</summary>
        IItemHandlerHash WeatherExtender { get; }

        /// <summary>Handler collection for terrain duration extensions (e.g., Terrain Extender).</summary>
        IItemHandlerHash TerrainExtender { get; }

        /// <summary>Handler collection for terrain-based stat boosts.</summary>
        IItemHandlerHash TerrainStatBoost { get; }

        /// <summary>Handler collection for end of round healing effects.</summary>
        IItemHandlerHash EndOfRoundHealing { get; }

        /// <summary>Handler collection for end of round general effects.</summary>
        IItemHandlerHash EndOfRoundEffect { get; }

        /// <summary>Handler collection for certain switching items (e.g., Shed Shell).</summary>
        IItemHandlerHash CertainSwitching { get; }

        /// <summary>Handler collection for trapping by target items.</summary>
        IItemHandlerHash TrappingByTarget { get; }

        /// <summary>Handler collection for switch in effects (e.g., Air Balloon).</summary>
        IItemHandlerHash OnSwitchIn { get; }

        /// <summary>Handler collection for intimidation responses (e.g., Adrenaline Orb).</summary>
        IItemHandlerHash OnIntimidated { get; }

        /// <summary>Handler collection for certain escape items (e.g., Smoke Ball).</summary>
        IItemHandlerHash CertainEscapeFromBattle { get; }

        /// <summary>
        /// Generic trigger method for item handler execution with optional return value.
        /// Executes the appropriate handler and returns the result or default value.
        /// </summary>
        /// <param name="hash">Handler collection to trigger</param>
        /// <param name="args">Arguments to pass to the handler</param>
        /// <param name="ret">Default return value if handler returns null</param>
        /// <returns>Handler result or default value</returns>
        object trigger(IItemHandlerHash hash, object[] args, object ret = null);

        /// <summary>
        /// Triggers Speed calculation modification items.
        /// Allows items to modify a battler's Speed stat for turn order calculations.
        /// </summary>
        /// <param name="item">Item being triggered</param>
        /// <param name="battler">Battler with the item</param>
        /// <param name="mult">Current Speed multiplier</param>
        /// <returns>Modified Speed multiplier</returns>
        double triggerSpeedCalc(IItem item, IBattler battler, double mult);

        /// <summary>
        /// Triggers weight calculation modification items like Float Stone.
        /// Allows items to modify a battler's weight for move effects and calculations.
        /// </summary>
        /// <param name="item">Item being triggered</param>
        /// <param name="battler">Battler with the item</param>
        /// <param name="w">Current weight value</param>
        /// <returns>Modified weight value</returns>
        double triggerWeightCalc(IItem item, IBattler battler, double w);

        /// <summary>
        /// Triggers HP healing items.
        /// Handles items that restore HP under various conditions.
        /// </summary>
        /// <param name="item">Item being triggered</param>
        /// <param name="battler">Battler with the item</param>
        /// <param name="battle">Current battle context</param>
        /// <param name="forced">Whether the healing is forced</param>
        /// <returns>Whether healing occurred</returns>
        bool triggerHPHeal(IItem item, IBattler battler, IBattle battle, bool forced);

        /// <summary>
        /// Triggers items that respond to stat losses.
        /// Activates when the battler's stat stages decrease.
        /// </summary>
        /// <param name="item">Item being triggered</param>
        /// <param name="user">Battler whose stats were lowered</param>
        /// <param name="move_user">Battler who caused the stat loss</param>
        /// <param name="battle">Current battle context</param>
        /// <returns>Whether the item activated</returns>
        bool triggerOnStatLoss(IItem item, IBattler user, IBattler move_user, IBattle battle);

        /// <summary>
        /// Triggers status curing items.
        /// Handles items that automatically cure status conditions.
        /// </summary>
        /// <param name="item">Item being triggered</param>
        /// <param name="battler">Battler with the item</param>
        /// <param name="battle">Current battle context</param>
        /// <param name="forced">Whether the curing is forced</param>
        /// <returns>Whether status was cured</returns>
        bool triggerStatusCure(IItem item, IBattler battler, IBattle battle, bool forced);

        /// <summary>
        /// Triggers stat loss immunity items.
        /// Prevents specific stat stage reductions.
        /// </summary>
        /// <param name="item">Item being triggered</param>
        /// <param name="battler">Battler with the item</param>
        /// <param name="stat">Stat being protected</param>
        /// <param name="battle">Current battle context</param>
        /// <param name="show_messages">Whether to display immunity messages</param>
        /// <returns>Whether the stat loss is prevented</returns>
        bool triggerStatLossImmunity(IItem item, IBattler battler, IStat stat, IBattle battle, bool show_messages);

        /// <summary>
        /// Triggers priority bracket modification items.
        /// Changes the battler's position within the same priority bracket.
        /// </summary>
        /// <param name="item">Item being triggered</param>
        /// <param name="battler">Battler with the item</param>
        /// <param name="battle">Current battle context</param>
        /// <returns>Priority bracket modifier</returns>
        int triggerPriorityBracketChange(IItem item, IBattler battler, IBattle battle);

        /// <summary>
        /// Triggers items that respond to priority bracket usage.
        /// Activates when priority mechanics are utilized.
        /// </summary>
        /// <param name="item">Item being triggered</param>
        /// <param name="battler">Battler with the item</param>
        /// <param name="battle">Current battle context</param>
        void triggerPriorityBracketUse(IItem item, IBattler battler, IBattle battle);

        /// <summary>
        /// Triggers items that respond to missing a target like Blunder Policy.
        /// Activates when the battler's move misses its intended target.
        /// </summary>
        /// <param name="item">Item being triggered</param>
        /// <param name="battler">Battler who missed</param>
        /// <param name="battle">Current battle context</param>
        void triggerOnMissingTarget(IItem item, IBattler battler, IBattle battle);

        /// <summary>
        /// Triggers accuracy calculation modifications from the user's items.
        /// Modifies accuracy calculation multipliers from the attacking side.
        /// </summary>
        /// <param name="item">Item being triggered</param>
        /// <param name="mods">Accuracy modification array</param>
        /// <param name="user">Battler using the move</param>
        /// <param name="target">Target of the move</param>
        /// <param name="move">Move being used</param>
        /// <param name="type">Type of the move</param>
        void triggerAccuracyCalcFromUser(IItem item, double[] mods, IBattler user, IBattler target, IMove move, IType type);

        /// <summary>
        /// Triggers accuracy calculation modifications from the target's items.
        /// Modifies accuracy calculation from the defending side.
        /// </summary>
        /// <param name="item">Item being triggered</param>
        /// <param name="mods">Accuracy modification array</param>
        /// <param name="user">Battler using the move</param>
        /// <param name="target">Target of the move</param>
        /// <param name="move">Move being used</param>
        /// <param name="type">Type of the move</param>
        void triggerAccuracyCalcFromTarget(IItem item, double[] mods, IBattler user, IBattler target, IMove move, IType type);

        /// <summary>
        /// Triggers damage calculation modifications from the user's items.
        /// Modifies damage multipliers from the attacking side.
        /// </summary>
        /// <param name="item">Item being triggered</param>
        /// <param name="user">Battler using the move</param>
        /// <param name="target">Target of the move</param>
        /// <param name="move">Move being used</param>
        /// <param name="mults">Damage multiplication array</param>
        /// <param name="power">Base power of the move</param>
        /// <param name="type">Type of the move</param>
        void triggerDamageCalcFromUser(IItem item, IBattler user, IBattler target, IMove move, double[] mults, int power, IType type);

        /// <summary>
        /// Triggers damage calculation modifications from the target's items.
        /// Modifies damage multipliers from the defending side.
        /// </summary>
        /// <param name="item">Item being triggered</param>
        /// <param name="user">Battler using the move</param>
        /// <param name="target">Target of the move</param>
        /// <param name="move">Move being used</param>
        /// <param name="mults">Damage multiplication array</param>
        /// <param name="power">Base power of the move</param>
        /// <param name="type">Type of the move</param>
        void triggerDamageCalcFromTarget(IItem item, IBattler user, IBattler target, IMove move, double[] mults, int power, IType type);

        /// <summary>
        /// Triggers critical hit calculation modifications from the user's items.
        /// Modifies critical hit chance from the attacking side.
        /// </summary>
        /// <param name="item">Item being triggered</param>
        /// <param name="user">Battler using the move</param>
        /// <param name="target">Target of the move</param>
        /// <param name="move">Move being used</param>
        /// <param name="crit_stage">Current critical hit stage</param>
        /// <returns>Modified critical hit stage</returns>
        int triggerCriticalCalcFromUser(IItem item, IBattler user, IBattler target, IMove move, int crit_stage);

        /// <summary>
        /// Triggers critical hit calculation modifications from the target's items.
        /// Modifies critical hit chance from the defending side.
        /// </summary>
        /// <param name="item">Item being triggered</param>
        /// <param name="user">Battler using the move</param>
        /// <param name="target">Target of the move</param>
        /// <param name="move">Move being used</param>
        /// <param name="crit_stage">Current critical hit stage</param>
        /// <returns>Modified critical hit stage</returns>
        int triggerCriticalCalcFromTarget(IItem item, IBattler user, IBattler target, IMove move, int crit_stage);

        /// <summary>
        /// Triggers items that activate when being hit by an attack.
        /// Responds to taking damage or being targeted by moves.
        /// </summary>
        /// <param name="item">Item being triggered</param>
        /// <param name="user">Battler who used the move</param>
        /// <param name="target">Battler who was hit</param>
        /// <param name="move">Move that hit</param>
        /// <param name="battle">Current battle context</param>
        void triggerOnBeingHit(IItem item, IBattler user, IBattler target, IMove move, IBattle battle);

        /// <summary>
        /// Triggers positive berry effects when being hit.
        /// Handles beneficial berries that activate when taking damage.
        /// </summary>
        /// <param name="item">Item being triggered</param>
        /// <param name="battler">Battler with the berry</param>
        /// <param name="battle">Current battle context</param>
        /// <param name="forced">Whether the berry activation is forced</param>
        void triggerOnBeingHitPositiveBerry(IItem item, IBattler battler, IBattle battle, bool forced);

        /// <summary>
        /// Triggers items that activate after being targeted by a move.
        /// Responds from the target's perspective after move resolution.
        /// </summary>
        /// <param name="item">Item being triggered</param>
        /// <param name="target">Battler who was targeted</param>
        /// <param name="user">Battler who used the move</param>
        /// <param name="move">Move that was used</param>
        /// <param name="switched_battlers">Array of battlers that switched</param>
        /// <param name="battle">Current battle context</param>
        void triggerAfterMoveUseFromTarget(IItem item, IBattler target, IBattler user, IMove move, IBattler[] switched_battlers, IBattle battle);

        /// <summary>
        /// Triggers items that activate after using a move.
        /// Responds from the user's perspective after move execution.
        /// </summary>
        /// <param name="item">Item being triggered</param>
        /// <param name="user">Battler who used the move</param>
        /// <param name="targets">Targets of the move</param>
        /// <param name="move">Move that was used</param>
        /// <param name="battle">Current battle context</param>
        void triggerAfterMoveUseFromUser(IItem item, IBattler user, IBattler[] targets, IMove move, IBattle battle);

        /// <summary>
        /// Triggers items that activate at the end of using a move like Leppa Berry.
        /// Handles items that respond after a move has been completely executed.
        /// </summary>
        /// <param name="item">Item being triggered</param>
        /// <param name="user">Battler who used the move</param>
        /// <param name="targets">Targets of the move</param>
        /// <param name="move">Move that was used</param>
        /// <param name="battle">Current battle context</param>
        void triggerOnEndOfUsingMove(IItem item, IBattler user, IBattler[] targets, IMove move, IBattle battle);

        /// <summary>
        /// Triggers stat restoration items after move usage like White Herb.
        /// Handles items that restore lowered stats after move execution.
        /// </summary>
        /// <param name="item">Item being triggered</param>
        /// <param name="battler">Battler with the item</param>
        /// <param name="battle">Current battle context</param>
        void triggerOnEndOfUsingMoveStatRestore(IItem item, IBattler battler, IBattle battle);

        /// <summary>
        /// Triggers experience gain modification items like Lucky Egg.
        /// Modifies the amount of experience gained from battle.
        /// </summary>
        /// <param name="item">Item being triggered</param>
        /// <param name="battler">Battler with the item</param>
        /// <param name="exp">Base experience amount</param>
        /// <returns>Modified experience amount</returns>
        int triggerExpGainModifier(IItem item, IBattler battler, int exp);

        /// <summary>
        /// Triggers EV gain modification items.
        /// Modifies the amount of effort values gained from battle.
        /// </summary>
        /// <param name="item">Item being triggered</param>
        /// <param name="battler">Battler with the item</param>
        /// <param name="evs">Array of EV gains for each stat</param>
        void triggerEVGainModifier(IItem item, IBattler battler, int[] evs);

        /// <summary>
        /// Triggers weather duration extension items.
        /// Extends the duration of weather effects when they are set up.
        /// </summary>
        /// <param name="item">Item being triggered</param>
        /// <param name="weather">Weather being extended</param>
        /// <param name="duration">Current duration</param>
        /// <param name="battler">Battler with the item</param>
        /// <param name="battle">Current battle context</param>
        /// <returns>Modified duration</returns>
        int triggerWeatherExtender(IItem item, IWeather weather, int duration, IBattler battler, IBattle battle);

        /// <summary>
        /// Triggers terrain duration extension items like Terrain Extender.
        /// Extends the duration of terrain effects when they are set up.
        /// </summary>
        /// <param name="item">Item being triggered</param>
        /// <param name="terrain">Terrain being extended</param>
        /// <param name="duration">Current duration</param>
        /// <param name="battler">Battler with the item</param>
        /// <param name="battle">Current battle context</param>
        /// <returns>Modified duration</returns>
        int triggerTerrainExtender(IItem item, int terrain, int duration, IBattler battler, IBattle battle);

        /// <summary>
        /// Triggers terrain-based stat boost items.
        /// Provides stat boosts when specific terrain is active.
        /// </summary>
        /// <param name="item">Item being triggered</param>
        /// <param name="battler">Battler with the item</param>
        /// <param name="stat">Stat being boosted</param>
        /// <param name="mult">Current stat multiplier</param>
        /// <returns>Modified stat multiplier</returns>
        double triggerTerrainStatBoost(IItem item, IBattler battler, IStat stat, double mult);

        /// <summary>
        /// Triggers end of round healing items.
        /// Provides HP recovery at the end of each round.
        /// </summary>
        /// <param name="item">Item being triggered</param>
        /// <param name="battler">Battler with the item</param>
        /// <param name="battle">Current battle context</param>
        void triggerEndOfRoundHealing(IItem item, IBattler battler, IBattle battle);

        /// <summary>
        /// Triggers general end of round items.
        /// Handles various items that activate at round conclusion.
        /// </summary>
        /// <param name="item">Item being triggered</param>
        /// <param name="battler">Battler with the item</param>
        /// <param name="battle">Current battle context</param>
        void triggerEndOfRoundEffect(IItem item, IBattler battler, IBattle battle);

        /// <summary>
        /// Triggers items that guarantee successful switching like Shed Shell.
        /// Ensures switching cannot be prevented by trapping effects.
        /// </summary>
        /// <param name="item">Item being triggered</param>
        /// <param name="battler">Battler attempting to switch</param>
        /// <param name="battle">Current battle context</param>
        /// <returns>Whether switching is guaranteed</returns>
        bool triggerCertainSwitching(IItem item, IBattler battler, IBattle battle);

        /// <summary>
        /// Triggers items that trap opposing battlers.
        /// Prevents the target from switching or fleeing.
        /// </summary>
        /// <param name="item">Item being triggered</param>
        /// <param name="switcher">Battler attempting to switch</param>
        /// <param name="bearer">Battler with the trapping item</param>
        /// <param name="battle">Current battle context</param>
        /// <returns>Whether the target is trapped</returns>
        bool triggerTrappingByTarget(IItem item, IBattler switcher, IBattler bearer, IBattle battle);

        /// <summary>
        /// Triggers items that activate when switching into battle like Air Balloon.
        /// Handles entrance items and field setup effects.
        /// </summary>
        /// <param name="item">Item being triggered</param>
        /// <param name="battler">Battler switching in</param>
        /// <param name="battle">Current battle context</param>
        void triggerOnSwitchIn(IItem item, IBattler battler, IBattle battle);

        /// <summary>
        /// Triggers items that respond to intimidation like Adrenaline Orb.
        /// Activates when the battler is targeted by Intimidate or similar effects.
        /// </summary>
        /// <param name="item">Item being triggered</param>
        /// <param name="battler">Battler who was intimidated</param>
        /// <param name="battle">Current battle context</param>
        void triggerOnIntimidated(IItem item, IBattler battler, IBattle battle);

        /// <summary>
        /// Triggers items that guarantee escape from battle like Smoke Ball.
        /// Ensures the battler can flee even when normally trapped.
        /// </summary>
        /// <param name="item">Item being triggered</param>
        /// <param name="battler">Battler attempting to escape</param>
        /// <returns>Whether escape is guaranteed</returns>
        bool triggerCertainEscapeFromBattle(IItem item, IBattler battler);
    }
}