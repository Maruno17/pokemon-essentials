using System;
using PokemonEssentials.Data;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for battle ability effects module that manages all ability-based triggers and handlers.
    /// Provides a comprehensive system for handling Pokemon abilities during battle including
    /// stat calculations, status effects, damage calculations, move modifications, and event responses.
    /// Contains organized handler collections for different ability trigger types and timing.
    /// </summary>
    public interface IAbilityEffects
    {
        /// <summary>Handler collection for Speed calculation modifications.</summary>
        IAbilityHandlerHash SpeedCalc { get; }

        /// <summary>Handler collection for weight calculation modifications.</summary>
        IAbilityHandlerHash WeightCalc { get; }

        /// <summary>Handler collection for HP dropping below half triggers.</summary>
        IAbilityHandlerHash OnHPDroppedBelowHalf { get; }

        /// <summary>Handler collection for non-ignorable status checks (e.g., Comatose).</summary>
        IAbilityHandlerHash StatusCheckNonIgnorable { get; }

        /// <summary>Handler collection for status immunity effects.</summary>
        IAbilityHandlerHash StatusImmunity { get; }

        /// <summary>Handler collection for non-ignorable status immunity effects.</summary>
        IAbilityHandlerHash StatusImmunityNonIgnorable { get; }

        /// <summary>Handler collection for status immunity from ally abilities.</summary>
        IAbilityHandlerHash StatusImmunityFromAlly { get; }

        /// <summary>Handler collection for status infliction responses (e.g., Synchronize).</summary>
        IAbilityHandlerHash OnStatusInflicted { get; }

        /// <summary>Handler collection for status curing effects.</summary>
        IAbilityHandlerHash StatusCure { get; }

        /// <summary>Handler collection for stat loss immunity effects.</summary>
        IAbilityHandlerHash StatLossImmunity { get; }

        /// <summary>Handler collection for non-ignorable stat loss immunity (e.g., Full Metal Body).</summary>
        IAbilityHandlerHash StatLossImmunityNonIgnorable { get; }

        /// <summary>Handler collection for stat loss immunity from ally abilities (e.g., Flower Veil).</summary>
        IAbilityHandlerHash StatLossImmunityFromAlly { get; }

        /// <summary>Handler collection for stat gain responses.</summary>
        IAbilityHandlerHash OnStatGain { get; }

        /// <summary>Handler collection for stat loss responses.</summary>
        IAbilityHandlerHash OnStatLoss { get; }

        /// <summary>Handler collection for move priority modifications.</summary>
        IAbilityHandlerHash PriorityChange { get; }

        /// <summary>Handler collection for priority bracket changes (e.g., Stall).</summary>
        IAbilityHandlerHash PriorityBracketChange { get; }

        /// <summary>Handler collection for priority bracket usage responses.</summary>
        IAbilityHandlerHash PriorityBracketUse { get; }

        /// <summary>Handler collection for flinch responses (e.g., Steadfast).</summary>
        IAbilityHandlerHash OnFlinch { get; }

        /// <summary>Handler collection for move blocking effects.</summary>
        IAbilityHandlerHash MoveBlocking { get; }

        /// <summary>Handler collection for move immunity effects.</summary>
        IAbilityHandlerHash MoveImmunity { get; }

        /// <summary>Handler collection for move base type modifications.</summary>
        IAbilityHandlerHash ModifyMoveBaseType { get; }

        /// <summary>Handler collection for accuracy calculations from the user's abilities.</summary>
        IAbilityHandlerHash AccuracyCalcFromUser { get; }

        /// <summary>Handler collection for accuracy calculations from ally abilities (e.g., Victory Star).</summary>
        IAbilityHandlerHash AccuracyCalcFromAlly { get; }

        /// <summary>Handler collection for accuracy calculations from target's abilities.</summary>
        IAbilityHandlerHash AccuracyCalcFromTarget { get; }

        /// <summary>Handler collection for damage calculations from the user's abilities.</summary>
        IAbilityHandlerHash DamageCalcFromUser { get; }

        /// <summary>Handler collection for damage calculations from ally abilities.</summary>
        IAbilityHandlerHash DamageCalcFromAlly { get; }

        /// <summary>Handler collection for damage calculations from target's abilities.</summary>
        IAbilityHandlerHash DamageCalcFromTarget { get; }

        /// <summary>Handler collection for non-ignorable damage calculations from target's abilities.</summary>
        IAbilityHandlerHash DamageCalcFromTargetNonIgnorable { get; }

        /// <summary>Handler collection for damage calculations from target's ally abilities.</summary>
        IAbilityHandlerHash DamageCalcFromTargetAlly { get; }

        /// <summary>Handler collection for critical hit calculations from the user's abilities.</summary>
        IAbilityHandlerHash CriticalCalcFromUser { get; }

        /// <summary>Handler collection for critical hit calculations from target's abilities.</summary>
        IAbilityHandlerHash CriticalCalcFromTarget { get; }

        /// <summary>Handler collection for being hit responses.</summary>
        IAbilityHandlerHash OnBeingHit { get; }

        /// <summary>Handler collection for dealing hit responses (e.g., Poison Touch).</summary>
        IAbilityHandlerHash OnDealingHit { get; }

        /// <summary>Handler collection for end of move usage responses.</summary>
        IAbilityHandlerHash OnEndOfUsingMove { get; }

        /// <summary>Handler collection for post-move responses from targets.</summary>
        IAbilityHandlerHash AfterMoveUseFromTarget { get; }

        /// <summary>Handler collection for end of round weather effects.</summary>
        IAbilityHandlerHash EndOfRoundWeather { get; }

        /// <summary>Handler collection for end of round healing effects.</summary>
        IAbilityHandlerHash EndOfRoundHealing { get; }

        /// <summary>Handler collection for end of round general effects.</summary>
        IAbilityHandlerHash EndOfRoundEffect { get; }

        /// <summary>Handler collection for end of round item gaining effects.</summary>
        IAbilityHandlerHash EndOfRoundGainItem { get; }

        /// <summary>Handler collection for certain switching abilities.</summary>
        IAbilityHandlerHash CertainSwitching { get; }

        /// <summary>Handler collection for trapping by target abilities.</summary>
        IAbilityHandlerHash TrappingByTarget { get; }

        /// <summary>Handler collection for switch in responses.</summary>
        IAbilityHandlerHash OnSwitchIn { get; }

        /// <summary>Handler collection for switch out responses.</summary>
        IAbilityHandlerHash OnSwitchOut { get; }

        /// <summary>Handler collection for changes triggered by battler fainting.</summary>
        IAbilityHandlerHash ChangeOnBattlerFainting { get; }

        /// <summary>Handler collection for responses to battler fainting (e.g., Soul-Heart).</summary>
        IAbilityHandlerHash OnBattlerFainting { get; }

        /// <summary>Handler collection for terrain change responses (e.g., Mimicry).</summary>
        IAbilityHandlerHash OnTerrainChange { get; }

        /// <summary>Handler collection for intimidation responses (e.g., Rattled in Gen 8).</summary>
        IAbilityHandlerHash OnIntimidated { get; }

        /// <summary>Handler collection for certain escape from battle abilities (e.g., Run Away).</summary>
        IAbilityHandlerHash CertainEscapeFromBattle { get; }

        /// <summary>
        /// Generic trigger method for ability handler execution with optional return value.
        /// Executes the appropriate handler and returns the result or default value.
        /// </summary>
        /// <param name="hash">Handler collection to trigger</param>
        /// <param name="args">Arguments to pass to the handler</param>
        /// <param name="ret">Default return value if handler returns null</param>
        /// <returns>Handler result or default value</returns>
        object trigger(IAbilityHandlerHash hash, object[] args, object ret = null);

        /// <summary>
        /// Triggers Speed calculation modification abilities.
        /// Allows abilities to modify a battler's Speed stat for turn order and move calculations.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="battler">Battler with the ability</param>
        /// <param name="mult">Current Speed multiplier</param>
        /// <returns>Modified Speed multiplier</returns>
        double triggerSpeedCalc(IAbility ability, IBattler battler, double mult);

        /// <summary>
        /// Triggers weight calculation modification abilities.
        /// Allows abilities to modify a battler's weight for move effects and calculations.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="battler">Battler with the ability</param>
        /// <param name="weight">Current weight value</param>
        /// <returns>Modified weight value</returns>
        double triggerWeightCalc(IAbility ability, IBattler battler, double weight);

        /// <summary>
        /// Triggers abilities that activate when HP drops below half.
        /// Handles abilities that respond to reaching low health thresholds.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="user">Battler whose HP dropped</param>
        /// <param name="move_user">Battler who caused the HP loss</param>
        /// <param name="battle">Current battle context</param>
        /// <returns>Whether the ability activated</returns>
        bool triggerOnHPDroppedBelowHalf(IAbility ability, IBattler user, IBattler move_user, IBattle battle);

        /// <summary>
        /// Triggers non-ignorable status condition checks like Comatose.
        /// Handles abilities that override normal status condition rules.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="battler">Battler with the ability</param>
        /// <param name="status">Status condition being checked</param>
        /// <returns>Whether the ability affects the status check</returns>
        bool triggerStatusCheckNonIgnorable(IAbility ability, IBattler battler, int status);

        /// <summary>
        /// Triggers status immunity abilities.
        /// Prevents specific status conditions from being inflicted.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="battler">Battler with the ability</param>
        /// <param name="status">Status condition being prevented</param>
        /// <returns>Whether the status is prevented</returns>
        bool triggerStatusImmunity(IAbility ability, IBattler battler, int status);

        /// <summary>
        /// Triggers non-ignorable status immunity abilities.
        /// Prevents status conditions even from moves that typically bypass immunity.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="battler">Battler with the ability</param>
        /// <param name="status">Status condition being prevented</param>
        /// <returns>Whether the status is prevented</returns>
        bool triggerStatusImmunityNonIgnorable(IAbility ability, IBattler battler, int status);

        /// <summary>
        /// Triggers status immunity from ally abilities.
        /// Provides status protection to allies on the same side.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="battler">Battler being protected</param>
        /// <param name="status">Status condition being prevented</param>
        /// <returns>Whether the status is prevented</returns>
        bool triggerStatusImmunityFromAlly(IAbility ability, IBattler battler, int status);

        /// <summary>
        /// Triggers abilities that respond to status infliction like Synchronize.
        /// Activates when the battler receives a status condition.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="battler">Battler who received the status</param>
        /// <param name="user">Battler who inflicted the status</param>
        /// <param name="status">Status condition that was inflicted</param>
        void triggerOnStatusInflicted(IAbility ability, IBattler battler, IBattler user, int status);

        /// <summary>
        /// Triggers status curing abilities.
        /// Allows abilities to automatically cure certain status conditions.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="battler">Battler with the ability</param>
        /// <returns>Whether a status was cured</returns>
        bool triggerStatusCure(IAbility ability, IBattler battler);

        /// <summary>
        /// Triggers stat loss immunity abilities.
        /// Prevents specific stat stage reductions.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="battler">Battler with the ability</param>
        /// <param name="stat">Stat being protected</param>
        /// <param name="battle">Current battle context</param>
        /// <param name="show_messages">Whether to display immunity messages</param>
        /// <returns>Whether the stat loss is prevented</returns>
        bool triggerStatLossImmunity(IAbility ability, IBattler battler, IStat stat, IBattle battle, bool show_messages);

        /// <summary>
        /// Triggers non-ignorable stat loss immunity abilities like Full Metal Body.
        /// Prevents stat reductions even from moves that typically bypass immunity.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="battler">Battler with the ability</param>
        /// <param name="stat">Stat being protected</param>
        /// <param name="battle">Current battle context</param>
        /// <param name="show_messages">Whether to display immunity messages</param>
        /// <returns>Whether the stat loss is prevented</returns>
        bool triggerStatLossImmunityNonIgnorable(IAbility ability, IBattler battler, IStat stat, IBattle battle, bool show_messages);

        /// <summary>
        /// Triggers stat loss immunity from ally abilities like Flower Veil.
        /// Provides stat protection to allies on the same side.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="bearer">Battler with the protective ability</param>
        /// <param name="battler">Battler being protected</param>
        /// <param name="stat">Stat being protected</param>
        /// <param name="battle">Current battle context</param>
        /// <param name="show_messages">Whether to display immunity messages</param>
        /// <returns>Whether the stat loss is prevented</returns>
        bool triggerStatLossImmunityFromAlly(IAbility ability, IBattler bearer, IBattler battler, IStat stat, IBattle battle, bool show_messages);

        /// <summary>
        /// Triggers abilities that respond to stat gains.
        /// Activates when the battler's stat stages increase.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="battler">Battler whose stats increased</param>
        /// <param name="stat">Stat that was increased</param>
        /// <param name="user">Battler who caused the stat increase</param>
        void triggerOnStatGain(IAbility ability, IBattler battler, IStat stat, IBattler user);

        /// <summary>
        /// Triggers abilities that respond to stat losses.
        /// Activates when the battler's stat stages decrease.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="battler">Battler whose stats decreased</param>
        /// <param name="stat">Stat that was decreased</param>
        /// <param name="user">Battler who caused the stat decrease</param>
        void triggerOnStatLoss(IAbility ability, IBattler battler, IStat stat, IBattler user);

        /// <summary>
        /// Triggers move priority modification abilities.
        /// Allows abilities to change the priority of moves.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="battler">Battler with the ability</param>
        /// <param name="move">Move whose priority is being modified</param>
        /// <param name="priority">Current move priority</param>
        /// <returns>Modified move priority</returns>
        int triggerPriorityChange(IAbility ability, IBattler battler, IMove move, int priority);

        /// <summary>
        /// Triggers priority bracket modification abilities like Stall.
        /// Changes the battler's position within the same priority bracket.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="battler">Battler with the ability</param>
        /// <param name="battle">Current battle context</param>
        /// <returns>Priority bracket modifier</returns>
        int triggerPriorityBracketChange(IAbility ability, IBattler battler, IBattle battle);

        /// <summary>
        /// Triggers abilities that respond to priority bracket usage.
        /// Activates when priority mechanics are utilized.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="battler">Battler with the ability</param>
        /// <param name="battle">Current battle context</param>
        void triggerPriorityBracketUse(IAbility ability, IBattler battler, IBattle battle);

        /// <summary>
        /// Triggers abilities that respond to flinching like Steadfast.
        /// Activates when the battler flinches from an attack.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="battler">Battler who flinched</param>
        /// <param name="battle">Current battle context</param>
        void triggerOnFlinch(IAbility ability, IBattler battler, IBattle battle);

        /// <summary>
        /// Triggers move blocking abilities.
        /// Prevents moves from being executed under certain conditions.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="bearer">Battler with the blocking ability</param>
        /// <param name="user">Battler using the move</param>
        /// <param name="targets">Targets of the move</param>
        /// <param name="move">Move being blocked</param>
        /// <param name="battle">Current battle context</param>
        /// <returns>Whether the move is blocked</returns>
        bool triggerMoveBlocking(IAbility ability, IBattler bearer, IBattler user, IBattler[] targets, IMove move, IBattle battle);

        /// <summary>
        /// Triggers move immunity abilities.
        /// Makes the battler immune to specific types of moves.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="user">Battler using the move</param>
        /// <param name="target">Target of the move</param>
        /// <param name="move">Move being used</param>
        /// <param name="type">Type of the move</param>
        /// <param name="battle">Current battle context</param>
        /// <param name="show_message">Whether to display immunity message</param>
        /// <returns>Whether the target is immune</returns>
        bool triggerMoveImmunity(IAbility ability, IBattler user, IBattler target, IMove move, IType type, IBattle battle, bool show_message);

        /// <summary>
        /// Triggers move base type modification abilities.
        /// Allows abilities to change the type of moves.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="user">Battler using the move</param>
        /// <param name="move">Move whose type is being modified</param>
        /// <param name="type">Current move type</param>
        /// <returns>Modified move type</returns>
        IType triggerModifyMoveBaseType(IAbility ability, IBattler user, IMove move, IType type);

        /// <summary>
        /// Triggers accuracy calculation modifications from the user's abilities.
        /// Modifies accuracy calculation multipliers from the attacking side.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="mods">Accuracy modification array</param>
        /// <param name="user">Battler using the move</param>
        /// <param name="target">Target of the move</param>
        /// <param name="move">Move being used</param>
        /// <param name="type">Type of the move</param>
        void triggerAccuracyCalcFromUser(IAbility ability, double[] mods, IBattler user, IBattler target, IMove move, IType type);

        /// <summary>
        /// Triggers accuracy calculation modifications from ally abilities like Victory Star.
        /// Modifies accuracy from abilities of allies on the same side.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="mods">Accuracy modification array</param>
        /// <param name="user">Battler using the move</param>
        /// <param name="target">Target of the move</param>
        /// <param name="move">Move being used</param>
        /// <param name="type">Type of the move</param>
        void triggerAccuracyCalcFromAlly(IAbility ability, double[] mods, IBattler user, IBattler target, IMove move, IType type);

        /// <summary>
        /// Triggers accuracy calculation modifications from the target's abilities.
        /// Modifies accuracy calculation from the defending side.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="mods">Accuracy modification array</param>
        /// <param name="user">Battler using the move</param>
        /// <param name="target">Target of the move</param>
        /// <param name="move">Move being used</param>
        /// <param name="type">Type of the move</param>
        void triggerAccuracyCalcFromTarget(IAbility ability, double[] mods, IBattler user, IBattler target, IMove move, IType type);

        /// <summary>
        /// Triggers damage calculation modifications from the user's abilities.
        /// Modifies damage multipliers from the attacking side.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="user">Battler using the move</param>
        /// <param name="target">Target of the move</param>
        /// <param name="move">Move being used</param>
        /// <param name="mults">Damage multiplication array</param>
        /// <param name="power">Base power of the move</param>
        /// <param name="type">Type of the move</param>
        void triggerDamageCalcFromUser(IAbility ability, IBattler user, IBattler target, IMove move, double[] mults, int power, IType type);

        /// <summary>
        /// Triggers damage calculation modifications from ally abilities.
        /// Modifies damage from abilities of allies on the same side.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="user">Battler using the move</param>
        /// <param name="target">Target of the move</param>
        /// <param name="move">Move being used</param>
        /// <param name="mults">Damage multiplication array</param>
        /// <param name="power">Base power of the move</param>
        /// <param name="type">Type of the move</param>
        void triggerDamageCalcFromAlly(IAbility ability, IBattler user, IBattler target, IMove move, double[] mults, int power, IType type);

        /// <summary>
        /// Triggers damage calculation modifications from the target's abilities.
        /// Modifies damage multipliers from the defending side.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="user">Battler using the move</param>
        /// <param name="target">Target of the move</param>
        /// <param name="move">Move being used</param>
        /// <param name="mults">Damage multiplication array</param>
        /// <param name="power">Base power of the move</param>
        /// <param name="type">Type of the move</param>
        void triggerDamageCalcFromTarget(IAbility ability, IBattler user, IBattler target, IMove move, double[] mults, int power, IType type);

        /// <summary>
        /// Triggers non-ignorable damage calculation modifications from the target's abilities.
        /// Modifies damage even when abilities would normally be ignored.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="user">Battler using the move</param>
        /// <param name="target">Target of the move</param>
        /// <param name="move">Move being used</param>
        /// <param name="mults">Damage multiplication array</param>
        /// <param name="power">Base power of the move</param>
        /// <param name="type">Type of the move</param>
        void triggerDamageCalcFromTargetNonIgnorable(IAbility ability, IBattler user, IBattler target, IMove move, double[] mults, int power, IType type);

        /// <summary>
        /// Triggers damage calculation modifications from the target's ally abilities.
        /// Modifies damage from abilities of the target's allies.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="user">Battler using the move</param>
        /// <param name="target">Target of the move</param>
        /// <param name="move">Move being used</param>
        /// <param name="mults">Damage multiplication array</param>
        /// <param name="power">Base power of the move</param>
        /// <param name="type">Type of the move</param>
        void triggerDamageCalcFromTargetAlly(IAbility ability, IBattler user, IBattler target, IMove move, double[] mults, int power, IType type);

        /// <summary>
        /// Triggers critical hit calculation modifications from the user's abilities.
        /// Modifies critical hit chance from the attacking side.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="user">Battler using the move</param>
        /// <param name="target">Target of the move</param>
        /// <param name="move">Move being used</param>
        /// <param name="crit_stage">Current critical hit stage</param>
        /// <returns>Modified critical hit stage</returns>
        int triggerCriticalCalcFromUser(IAbility ability, IBattler user, IBattler target, IMove move, int crit_stage);

        /// <summary>
        /// Triggers critical hit calculation modifications from the target's abilities.
        /// Modifies critical hit chance from the defending side.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="user">Battler using the move</param>
        /// <param name="target">Target of the move</param>
        /// <param name="move">Move being used</param>
        /// <param name="crit_stage">Current critical hit stage</param>
        /// <returns>Modified critical hit stage</returns>
        int triggerCriticalCalcFromTarget(IAbility ability, IBattler user, IBattler target, IMove move, int crit_stage);

        /// <summary>
        /// Triggers abilities that activate when being hit by an attack.
        /// Responds to taking damage or being targeted by moves.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="user">Battler who used the move</param>
        /// <param name="target">Battler who was hit</param>
        /// <param name="move">Move that hit</param>
        /// <param name="battle">Current battle context</param>
        void triggerOnBeingHit(IAbility ability, IBattler user, IBattler target, IMove move, IBattle battle);

        /// <summary>
        /// Triggers abilities that activate when dealing a hit like Poison Touch.
        /// Responds to successfully hitting a target with an attack.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="user">Battler who dealt the hit</param>
        /// <param name="target">Battler who was hit</param>
        /// <param name="move">Move that hit</param>
        /// <param name="battle">Current battle context</param>
        void triggerOnDealingHit(IAbility ability, IBattler user, IBattler target, IMove move, IBattle battle);

        /// <summary>
        /// Triggers abilities that activate at the end of using a move.
        /// Responds after a move has been completely executed.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="user">Battler who used the move</param>
        /// <param name="targets">Targets of the move</param>
        /// <param name="move">Move that was used</param>
        /// <param name="battle">Current battle context</param>
        void triggerOnEndOfUsingMove(IAbility ability, IBattler user, IBattler[] targets, IMove move, IBattle battle);

        /// <summary>
        /// Triggers abilities that activate after being targeted by a move.
        /// Responds from the target's perspective after move resolution.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="target">Battler who was targeted</param>
        /// <param name="user">Battler who used the move</param>
        /// <param name="move">Move that was used</param>
        /// <param name="switched_battlers">Array of battlers that switched</param>
        /// <param name="battle">Current battle context</param>
        void triggerAfterMoveUseFromTarget(IAbility ability, IBattler target, IBattler user, IMove move, IBattler[] switched_battlers, IBattle battle);

        /// <summary>
        /// Triggers weather-related abilities at the end of each round.
        /// Handles abilities that respond to or modify weather conditions.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="weather">Current weather condition</param>
        /// <param name="battler">Battler with the ability</param>
        /// <param name="battle">Current battle context</param>
        void triggerEndOfRoundWeather(IAbility ability, IWeather weather, IBattler battler, IBattle battle);

        /// <summary>
        /// Triggers healing abilities at the end of each round.
        /// Handles abilities that provide HP recovery over time.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="battler">Battler with the ability</param>
        /// <param name="battle">Current battle context</param>
        void triggerEndOfRoundHealing(IAbility ability, IBattler battler, IBattle battle);

        /// <summary>
        /// Triggers general end-of-round abilities.
        /// Handles various abilities that activate at round conclusion.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="battler">Battler with the ability</param>
        /// <param name="battle">Current battle context</param>
        void triggerEndOfRoundEffect(IAbility ability, IBattler battler, IBattle battle);

        /// <summary>
        /// Triggers item-gaining abilities at the end of each round.
        /// Handles abilities that provide or create items over time.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="battler">Battler with the ability</param>
        /// <param name="battle">Current battle context</param>
        void triggerEndOfRoundGainItem(IAbility ability, IBattler battler, IBattle battle);

        /// <summary>
        /// Triggers abilities that guarantee successful switching.
        /// Handles abilities that ensure switching cannot be prevented.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="battler">Battler attempting to switch</param>
        /// <param name="battle">Current battle context</param>
        /// <returns>Whether switching is guaranteed</returns>
        bool triggerCertainSwitching(IAbility ability, IBattler battler, IBattle battle);

        /// <summary>
        /// Triggers abilities that trap opposing battlers.
        /// Prevents the target from switching or fleeing.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="switcher">Battler attempting to switch</param>
        /// <param name="bearer">Battler with the trapping ability</param>
        /// <param name="battle">Current battle context</param>
        /// <returns>Whether the target is trapped</returns>
        bool triggerTrappingByTarget(IAbility ability, IBattler switcher, IBattler bearer, IBattle battle);

        /// <summary>
        /// Triggers abilities that activate when switching into battle.
        /// Handles entrance abilities and field setup effects.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="battler">Battler switching in</param>
        /// <param name="battle">Current battle context</param>
        /// <param name="switch_in">Whether this is a switch-in (vs initial entry)</param>
        void triggerOnSwitchIn(IAbility ability, IBattler battler, IBattle battle, bool switch_in = true);

        /// <summary>
        /// Triggers abilities that activate when switching out of battle.
        /// Handles exit abilities and cleanup effects.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="battler">Battler switching out</param>
        /// <param name="endBattle">Whether the battle is ending</param>
        /// <param name="battle">Current battle context</param>
        void triggerOnSwitchOut(IAbility ability, IBattler battler, bool endBattle, IBattle battle);

        /// <summary>
        /// Triggers abilities that change when another battler faints.
        /// Handles form changes and ability modifications triggered by fainting.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="battler">Battler with the ability</param>
        /// <param name="fainted">Battler who fainted</param>
        /// <param name="battle">Current battle context</param>
        void triggerChangeOnBattlerFainting(IAbility ability, IBattler battler, IBattler fainted, IBattle battle);

        /// <summary>
        /// Triggers abilities that respond to any battler fainting like Soul-Heart.
        /// Activates when witnessing another Pokemon's defeat.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="battler">Battler with the ability</param>
        /// <param name="fainted">Battler who fainted</param>
        /// <param name="battle">Current battle context</param>
        void triggerOnBattlerFainting(IAbility ability, IBattler battler, IBattler fainted, IBattle battle);

        /// <summary>
        /// Triggers abilities that respond to terrain changes like Mimicry.
        /// Activates when battle terrain is modified.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="battler">Battler with the ability</param>
        /// <param name="battle">Current battle context</param>
        /// <param name="ability_changed"></param>
        void triggerOnTerrainChange(IAbility ability, IBattler battler, IBattle battle, bool ability_changed);

        /// <summary>
        /// Triggers abilities that respond to intimidation like Rattled in Gen 8.
        /// Activates when the battler is targeted by Intimidate or similar effects.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="battler">Battler who was intimidated</param>
        /// <param name="battle">Current battle context</param>
        void triggerOnIntimidated(IAbility ability, IBattler battler, IBattle battle);

        /// <summary>
        /// Triggers abilities that guarantee escape from battle like Run Away.
        /// Ensures the battler can flee even when normally trapped.
        /// </summary>
        /// <param name="ability">Ability being triggered</param>
        /// <param name="battler">Battler attempting to escape</param>
        /// <returns>Whether escape is guaranteed</returns>
        bool triggerCertainEscapeFromBattle(IAbility ability, IBattler battler);
    }
}