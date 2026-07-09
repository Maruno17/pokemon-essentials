using System;
using System.Collections.Generic;

namespace PokemonEssentials.Framework
{
    /// <summary>
    /// Interface for AI handlers related to switching, fleeing, trapping, and action order manipulation.
    /// Manages scoring and evaluation for moves that affect Pokemon positioning and turn order.
    /// </summary>
    public interface IAIMoveEffectsSwitchingActing
    {
        /// <summary>
        /// Checks if moves that flee from battle will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkFleeFromBattleFailure(object move, object user, object ai, object battle);

        /// <summary>
        /// Scores moves that cause the user to flee from battle.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the fleeing move.</returns>
        int scoreFleeFromBattleEffect(int score, object move, object user, object ai, object battle);

        /// <summary>
        /// Checks if moves that switch out the user (status version) will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkSwitchOutUserStatusMoveFailure(object move, object user, object ai, object battle);

        /// <summary>
        /// Scores status moves that switch out the user.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the user switching status move.</returns>
        int scoreSwitchOutUserStatusMoveEffect(int score, object move, object user, object ai, object battle);

        /// <summary>
        /// Scores damaging moves that switch out the user.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the user switching damaging move.</returns>
        int scoreSwitchOutUserDamagingMoveEffect(int score, object move, object user, object ai, object battle);

        /// <summary>
        /// Checks if moves that lower target stats and switch out user will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being checked against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkLowerTargetAtkSpAtk1SwitchOutUserFailure(object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that lower target's Attack and Special Attack then switch out user.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the stat-lowering switch move.</returns>
        int scoreLowerTargetAtkSpAtk1SwitchOutUserEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Checks if moves that switch out user and pass effects will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkSwitchOutUserPassOnEffectsFailure(object move, object user, object ai, object battle);

        /// <summary>
        /// Scores moves that switch out user and pass on effects (like Baton Pass).
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the effect-passing switch move.</returns>
        int scoreSwitchOutUserPassOnEffectsEffect(int score, object move, object user, object ai, object battle);

        /// <summary>
        /// Checks if status moves that switch out target will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being checked against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkSwitchOutTargetStatusMoveFailure(object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores status moves that switch out the target.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the target switching status move.</returns>
        int scoreSwitchOutTargetStatusMoveEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores damaging moves that switch out the target.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the target switching damaging move.</returns>
        int scoreSwitchOutTargetDamagingMoveEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that bind the target (like Wrap, Fire Spin).
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the binding move.</returns>
        int scoreBindTargetEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Calculates power for binding moves that double power if target is underwater.
        /// </summary>
        /// <param name="power">The original power of the move.</param>
        /// <param name="move">The move being used.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target of the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The calculated power based on target's state.</returns>
        int calculateBindTargetDoublePowerIfTargetUnderwaterPower(int power, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Checks if moves that trap target in battle will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being checked against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkTrapTargetInBattleFailure(object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that trap the target in battle (like Mean Look).
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the trapping move.</returns>
        int scoreTrapTargetInBattleEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Checks if moves that trap target and lower stats each turn will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being checked against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkTrapTargetInBattleLowerTargetDefSpDef1EachTurnFailure(object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that trap target and lower their Defense and Special Defense each turn.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the stat-lowering trapping move.</returns>
        int scoreTrapTargetInBattleLowerTargetDefSpDef1EachTurnEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that trap both user and target in battle.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the mutual trapping move.</returns>
        int scoreTrapUserAndTargetInBattleEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Checks if moves that trap all battlers for one turn will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkTrapAllBattlersInBattleForOneTurnFailure(object move, object user, object ai, object battle);

        /// <summary>
        /// Scores moves that trap all battlers for one turn (like Fairy Lock).
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the field trapping move.</returns>
        int scoreTrapAllBattlersInBattleForOneTurnEffect(int score, object move, object user, object ai, object battle);

        /// <summary>
        /// Checks if moves that activate after taking physical damage will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkUsedAfterUserTakesPhysicalDamageFailure(object move, object user, object ai, object battle);

        /// <summary>
        /// Scores moves that are used after the user takes physical damage.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the reactive move.</returns>
        int scoreUsedAfterUserTakesPhysicalDamageEffect(int score, object move, object user, object ai, object battle);

        /// <summary>
        /// Scores moves that are used after ally uses Round (doubles power).
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the Round synergy move.</returns>
        int scoreUsedAfterAllyRoundWithDoublePowerEffect(int score, object move, object user, object ai, object battle);

        /// <summary>
        /// Scores moves that make the target act next.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the speed manipulation move.</returns>
        int scoreTargetActsNextEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that make the target act last.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the speed manipulation move.</returns>
        int scoreTargetActsLastEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Checks if moves that make target use its last move again will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being checked against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkTargetUsesItsLastUsedMoveAgainFailure(object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that force the target to use its last move again.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the move repetition effect.</returns>
        int scoreTargetUsesItsLastUsedMoveAgainEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that make slower battlers act first (like Trick Room).
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the speed reversal move.</returns>
        int scoreStartSlowerBattlersActFirstEffect(int score, object move, object user, object ai, object battle);

        /// <summary>
        /// Scores moves that lower PP of target's last move by 3.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the PP reduction move.</returns>
        int scoreLowerPPOfTargetLastMoveBy3Effect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Checks if moves that lower PP of target's last move by 4 will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being checked against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkLowerPPOfTargetLastMoveBy4Failure(object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that lower PP of target's last move by 4.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the PP reduction move.</returns>
        int scoreLowerPPOfTargetLastMoveBy4Effect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Checks if moves that disable target's last move will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being checked against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkDisableTargetLastMoveUsedFailure(object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that disable the target's last move used.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the move disabling effect.</returns>
        int scoreDisableTargetLastMoveUsedEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Checks if moves that prevent using same move consecutively will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being checked against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkDisableTargetUsingSameMoveConsecutivelyFailure(object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that prevent target from using the same move consecutively.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the move repetition prevention.</returns>
        int scoreDisableTargetUsingSameMoveConsecutivelyEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Checks if moves that force target to use only one move will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being checked against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkDisableTargetUsingDifferentMoveFailure(object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that force target to use only one move (like Encore).
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the move locking effect.</returns>
        int scoreDisableTargetUsingDifferentMoveEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Checks if moves that disable target's status moves will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being checked against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkDisableTargetStatusMovesFailure(object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that disable the target's status moves (like Taunt).
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the status move disabling effect.</returns>
        int scoreDisableTargetStatusMovesEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Checks if moves that disable target's healing moves will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being checked against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkDisableTargetHealingMovesFailure(object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that disable the target's healing moves (like Heal Block).
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the healing disabling effect.</returns>
        int scoreDisableTargetHealingMovesEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that disable the target's sound moves.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the sound move disabling effect.</returns>
        int scoreDisableTargetSoundMovesEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Checks if moves that disable target moves known by user will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkDisableTargetMovesKnownByUserFailure(object move, object user, object ai, object battle);

        /// <summary>
        /// Scores moves that disable target moves that the user also knows (like Imprison).
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the move imprisonment effect.</returns>
        int scoreDisableTargetMovesKnownByUserEffect(int score, object move, object user, object target, object ai, object battle);
    }

    /// <summary>
    /// Interface for AI evaluation of switching strategies and positioning.
    /// Provides specialized methods for determining optimal switching decisions.
    /// </summary>
    public interface IAISwitchingStrategies
    {
        /// <summary>
        /// Evaluates whether a Pokemon should switch out based on current conditions.
        /// </summary>
        /// <param name="pokemon">The Pokemon considering switching out.</param>
        /// <param name="currentSituation">The current battle situation.</param>
        /// <param name="availableReplacements">Pokemon available to switch in.</param>
        /// <returns>True if switching is recommended, false otherwise.</returns>
        bool shouldSwitchOut(object pokemon, object currentSituation, IList<object> availableReplacements);

        /// <summary>
        /// Calculates the value of passing specific effects to a replacement Pokemon.
        /// </summary>
        /// <param name="currentPokemon">The Pokemon that would pass effects.</param>
        /// <param name="effects">The effects that would be passed.</param>
        /// <param name="replacement">The Pokemon that would receive the effects.</param>
        /// <returns>A value score for the effect passing strategy.</returns>
        int evaluateEffectPassingValue(object currentPokemon, IList<object> effects, object replacement);

        /// <summary>
        /// Determines the optimal replacement when switching out.
        /// </summary>
        /// <param name="switchingOut">The Pokemon that is switching out.</param>
        /// <param name="availableReplacements">The Pokemon available to switch in.</param>
        /// <param name="battleState">The current battle state.</param>
        /// <returns>The optimal replacement Pokemon, or null if none suitable.</returns>
        object selectOptimalReplacement(object switchingOut, IList<object> availableReplacements, object battleState);

        /// <summary>
        /// Assesses the risk of entry hazards when switching.
        /// </summary>
        /// <param name="incomingPokemon">The Pokemon that would switch in.</param>
        /// <param name="hazards">The entry hazards present on the field.</param>
        /// <returns>A risk assessment score for switching in.</returns>
        float assessEntryHazardRisk(object incomingPokemon, IList<object> hazards);

        /// <summary>
        /// Evaluates whether to use a switching move versus a regular switch.
        /// </summary>
        /// <param name="pokemon">The Pokemon considering the switch.</param>
        /// <param name="switchingMoves">Available moves that cause switching.</param>
        /// <param name="regularSwitch">The option to switch normally.</param>
        /// <returns>True if a switching move should be used, false for regular switch.</returns>
        bool preferSwitchingMoveOverRegularSwitch(object pokemon, IList<object> switchingMoves, object regularSwitch);
    }

    /// <summary>
    /// Interface for AI evaluation of trapping and positioning control moves.
    /// Handles assessment of moves that restrict opponent movement and positioning.
    /// </summary>
    public interface IAITrappingStrategies
    {
        /// <summary>
        /// Evaluates the strategic value of trapping a specific opponent.
        /// </summary>
        /// <param name="user">The Pokemon performing the trapping.</param>
        /// <param name="target">The Pokemon being trapped.</param>
        /// <param name="trappingMethod">The move or effect causing the trap.</param>
        /// <param name="expectedDuration">How long the trap is expected to last.</param>
        /// <returns>A strategic value score for the trapping action.</returns>
        float evaluateTrappingValue(object user, object target, object trappingMethod, int expectedDuration);

        /// <summary>
        /// Determines if a Pokemon is a high-priority target for trapping.
        /// </summary>
        /// <param name="target">The potential target for trapping.</param>
        /// <param name="battleContext">The current battle context.</param>
        /// <param name="userCapabilities">The trapping user's capabilities.</param>
        /// <returns>True if the target should be prioritized for trapping, false otherwise.</returns>
        bool isHighPriorityTrappingTarget(object target, object battleContext, object userCapabilities);

        /// <summary>
        /// Calculates the optimal timing for using trapping moves.
        /// </summary>
        /// <param name="user">The Pokemon considering the trapping move.</param>
        /// <param name="targets">Potential targets for trapping.</param>
        /// <param name="battleFlow">The current battle flow and momentum.</param>
        /// <returns>A timing score where higher values indicate better timing.</returns>
        int calculateTrappingTiming(object user, IList<object> targets, object battleFlow);

        /// <summary>
        /// Assesses whether binding moves are worth using over direct damage.
        /// </summary>
        /// <param name="bindingMove">The binding move being considered.</param>
        /// <param name="directDamageMoves">Alternative direct damage moves.</param>
        /// <param name="target">The target of the moves.</param>
        /// <param name="battleLength">Expected remaining battle length.</param>
        /// <returns>True if binding moves are preferred, false for direct damage.</returns>
        bool preferBindingOverDirectDamage(object bindingMove, IList<object> directDamageMoves, object target, int battleLength);

        /// <summary>
        /// Evaluates the value of preventing opponent switching.
        /// </summary>
        /// <param name="opponent">The opponent whose switching would be prevented.</param>
        /// <param name="opponentTeam">The opponent's available team members.</param>
        /// <param name="preventionMethod">The method used to prevent switching.</param>
        /// <returns>A value score for preventing the opponent from switching.</returns>
        int evaluateSwitchPreventionValue(object opponent, IList<object> opponentTeam, object preventionMethod);
    }
}