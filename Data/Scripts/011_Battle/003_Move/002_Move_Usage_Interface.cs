using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for move usage logic, encapsulating all effect methods, usage checks, targeting, damage processing, and failure conditions for a battle move.
    /// <para>This interface provides all hooks and checks for move usage, including targeting, animation, damage calculation, and move-specific failure logic.</para>
    /// </summary>
    public interface IBattleMoveUsage : IBattleMove
    {
        /// <summary>
        /// Checks if the move can be chosen by the user in the current context (e.g., for Belch).
        /// </summary>
        /// <remarks>
        /// For Belch
        /// </remarks>
        /// <param name="user">The battler attempting to use the move.</param>
        /// <param name="commandPhase">Whether this is the command phase.</param>
        /// <param name="showMessages">Whether to show failure messages.</param>
        /// <returns>True if the move can be chosen, otherwise false.</returns>
        bool CanChooseMove(IBattler user, bool commandPhase, bool showMessages);

        /// <summary>
        /// Displays a charge message for moves that require charging (e.g., Focus Punch).
        /// </summary>
        /// <remarks>
        /// For Focus Punch/shell Trap/Beak Blast
        /// </remarks>
        /// <param name="user">The user of the move.</param>
        void DisplayChargeMessage(IBattler user);

        /// <summary>
        /// Called at the start of using a move, before any effects are applied.
        /// </summary>
        /// <param name="user">The user of the move.</param>
        /// <param name="targets">The targets of the move.</param>
        void OnStartUse(IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Adds a target to the move's target list (e.g., for Counter, Bide).
        /// </summary>
        /// <remarks>
        /// For Counter, etc. and Bide
        /// </remarks>
        /// <param name="targets">The current list of targets.</param>
        /// <param name="user">The user of the move.</param>
        void AddTarget(IList<IBattler> targets, IBattler user);

        /// <summary>
        /// Modifies the move's targets (e.g., for Dragon Darts).
        /// </summary>
        /// <remarks>
        /// For Dragon Darts
        /// </remarks>
        /// <param name="targets">The current list of targets.</param>
        /// <param name="user">The user of the move.</param>
        void ModifyTargets(IList<IBattler> targets, IBattler user);

        /// <summary>
        /// Resets or changes move usage counters (e.g., for Fury Cutter, Parental Bond).
        /// </summary>
        /// <remarks>
        /// Reset move usage counters (child classes can increment them).
        /// </remarks>
        /// <param name="user">The user of the move.</param>
        /// <param name="specialUsage">Whether this is a special usage context.</param>
        void ChangeUsageCounters(IBattler user, bool specialUsage);

        /// <summary>
        /// Displays the "used move" message for the user.
        /// </summary>
        /// <param name="user">The user of the move.</param>
        void DisplayUseMessage(IBattler user);

        /// <summary>
        /// Returns true if fail messages should be shown for the given targets.
        /// </summary>
        /// <param name="targets">The targets of the move.</param>
        /// <returns>True if fail messages should be shown, otherwise false.</returns>
        bool ShowFailMessages(IList<IBattler> targets);

        /// <summary>
        /// Handles the miss message for the user and target.
        /// </summary>
        /// <param name="user">The user of the move.</param>
        /// <param name="target">The target of the move.</param>
        /// <returns>True if a miss message was shown, otherwise false.</returns>
        bool MissMessage(IBattler user, IBattler target);

        /// <summary>
        /// Returns true if the move is currently in the charging turn (for two-turn moves).
        /// </summary>
        /// <remarks>
        /// Whether the move is currently in the "charging" turn of a two-turn move.
        /// Is false if Power Herb or another effect lets a two-turn move charge and
        /// attack in the same turn.
        /// user.effects[PBEffects::TwoTurnAttack] is set to the move's ID during the
        /// charging turn, and is nil during the attack turn.
        /// </remarks>
        /// <param name="user">The user of the move.</param>
        /// <returns>True if charging, otherwise false.</returns>
        bool IsChargingTurn(IBattler user);

        /// <summary>
        /// Returns true if the move is damaging (not a status move).
        /// </summary>
        /// <returns>True if damaging, otherwise false.</returns>
        bool IsDamagingMove();

        /// <summary>
        /// Returns true if the move is a contact move for the given user (considering abilities/items).
        /// </summary>
        /// <param name="user">The user of the move.</param>
        /// <returns>True if contact, otherwise false.</returns>
        bool IsContactMove(IBattler user);

        /// <summary>
        /// Returns the number of hits this move will perform for the user and targets (e.g., Parental Bond).
        /// </summary>
        /// <remarks>
        /// The maximum number of hits in a round this move will actually perform. This
        /// can be 1 for Beat Up, and can be 2 for any moves affected by Parental Bond.
        /// </remarks>
        /// <param name="user">The user of the move.</param>
        /// <param name="targets">The targets of the move.</param>
        /// <returns>The number of hits.</returns>
        int NumHits(IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Handles quick charging for two-turn moves that charge and attack in the same turn.
        /// </summary>
        /// <remarks>
        /// For two-turn moves when they charge and attack in the same turn.
        /// </remarks>
        /// <param name="user">The user of the move.</param>
        /// <param name="targets">The targets of the move.</param>
        void QuickChargingMove(IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Returns true if the move overrides the per-hit success check for the user and target.
        /// </summary>
        /// <param name="user">The user of the move.</param>
        /// <param name="target">The target of the move.</param>
        /// <returns>True if overridden, otherwise false.</returns>
        bool OverrideSuccessCheckPerHit(IBattler user, IBattler target);

        /// <summary>
        /// Handles crash damage for the user (e.g., High Jump Kick).
        /// </summary>
        /// <param name="user">The user of the move.</param>
        void CrashDamage(IBattler user);

        /// <summary>
        /// Handles the initial effect for a move hit (e.g., multi-hit moves).
        /// </summary>
        /// <param name="user">The user of the move.</param>
        /// <param name="targets">The targets of the move.</param>
        /// <param name="hitNum">The hit number.</param>
        void InitialEffect(IBattler user, IList<IBattler> targets, int hitNum);

        /// <summary>
        /// Designates the targets for a specific hit (e.g., Dragon Darts).
        /// </summary>
        /// <remarks>
        /// For Dragon Darts
        /// </remarks>
        /// <param name="targets">The current list of targets.</param>
        /// <param name="hitNum">The hit number.</param>
        /// <returns>The modified list of targets.</returns>
        IList<IBattler> DesignateTargetsForHit(IList<IBattler> targets, int hitNum);

        /// <summary>
        /// Returns true if the move repeats for multiple hits (e.g., Dragon Darts).
        /// </summary>
        /// <remarks>
        /// For Dragon Darts
        /// </remarks>
        /// <returns>True if repeat hit, otherwise false.</returns>
        bool RepeatHit();

        /// <summary>
        /// Handles the move's animation for a given hit.
        /// </summary>
        /// <param name="id">The move's animation ID.</param>
        /// <param name="user">The user of the move.</param>
        /// <param name="targets">The targets of the move.</param>
        /// <param name="hitNum">The hit number.</param>
        /// <param name="showAnimation">Whether to show the animation.</param>
        void ShowAnimation(object id, IBattler user, IList<IBattler> targets, int hitNum = 0, bool showAnimation = true);

        /// <summary>
        /// Handles self-KO effects for the user (e.g., Explosion).
        /// </summary>
        /// <param name="user">The user of the move.</param>
        void SelfKO(IBattler user);

        /// <summary>
        /// Handles effects when dealing damage to a target (e.g., secondary effects).
        /// </summary>
        /// <param name="user">The user of the move.</param>
        /// <param name="target">The target of the move.</param>
        void EffectWhenDealingDamage(IBattler user, IBattler target);

        /// <summary>
        /// Handles effects against a target (e.g., status infliction).
        /// </summary>
        /// <param name="user">The user of the move.</param>
        /// <param name="target">The target of the move.</param>
        void EffectAgainstTarget(IBattler user, IBattler target);

        /// <summary>
        /// Handles general effects for the user (e.g., stat boosts).
        /// </summary>
        /// <param name="user">The user of the move.</param>
        void EffectGeneral(IBattler user);

        /// <summary>
        /// Handles additional effects for the user and target (e.g., secondary status).
        /// </summary>
        /// <param name="user">The user of the move.</param>
        /// <param name="target">The target of the move.</param>
        void AdditionalEffect(IBattler user, IBattler target);

        /// <summary>
        /// Handles effects that occur after all hits (e.g., multi-hit moves).
        /// </summary>
        /// <remarks>
        /// Move effects that occur after all hits
        /// </remarks>
        /// <param name="user">The user of the move.</param>
        /// <param name="target">The target of the move.</param>
        void EffectAfterAllHits(IBattler user, IBattler target);

        /// <summary>
        /// Handles effects when a target is switched out (e.g., U-turn).
        /// </summary>
        /// <param name="user">The user of the move.</param>
        /// <param name="targets">The targets of the move.</param>
        /// <param name="numHits">The number of hits.</param>
        /// <param name="switchedBattlers">The battlers that switched out.</param>
        void SwitchOutTargetEffect(IBattler user, IList<IBattler> targets, int numHits, IList<IBattler> switchedBattlers);

        /// <summary>
        /// Handles effects at the end of move usage (e.g., after all hits and switches).
        /// </summary>
        /// <param name="user">The user of the move.</param>
        /// <param name="targets">The targets of the move.</param>
        /// <param name="numHits">The number of hits.</param>
        /// <param name="switchedBattlers">The battlers that switched out.</param>
        void EndOfMoveUsageEffect(IBattler user, IList<IBattler> targets, int numHits, IList<IBattler> switchedBattlers);

        /// <summary>
        /// Checks if the target is immune to the move because of its ability.
        /// </summary>
        /// <param name="user">The user of the move.</param>
        /// <param name="target">The target of the move.</param>
        /// <param name="showMessage">Whether to show an immunity message.</param>
        /// <returns>True if immune, otherwise false.</returns>
        bool ImmunityByAbility(IBattler user, IBattler target, bool showMessage);

        /// <summary>
        /// Checks whether the move fails completely due to move-specific requirements.
        /// </summary>
        /// <param name="user">The user of the move.</param>
        /// <param name="targets">The targets of the move.</param>
        /// <returns>True if the move fails, otherwise false.</returns>
        bool MoveFailed(IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Checks whether the move will be ineffective against the target.
        /// </summary>
        /// <param name="user">The user of the move.</param>
        /// <param name="target">The target of the move.</param>
        /// <param name="showMessage">Whether to show a failure message.</param>
        /// <returns>True if the move fails against the target, otherwise false.</returns>
        bool FailsAgainstTarget(IBattler user, IBattler target, bool showMessage);

        /// <summary>
        /// Checks whether the move fails if the user is last in the round.
        /// </summary>
        /// <param name="user">The user of the move.</param>
        /// <param name="showMessage">Whether to show a failure message.</param>
        /// <returns>True if the move fails, otherwise false.</returns>
        bool MoveFailedLastInRound(IBattler user, bool showMessage = true);

        /// <summary>
        /// Checks whether the move fails if the target already moved.
        /// </summary>
        /// <param name="target">The target of the move.</param>
        /// <param name="showMessage">Whether to show a failure message.</param>
        /// <returns>True if the move fails, otherwise false.</returns>
        bool MoveFailedTargetAlreadyMoved(IBattler target, bool showMessage = true);

        /// <summary>
        /// Checks whether the move fails due to Aroma Veil.
        /// </summary>
        /// <param name="user">The user of the move.</param>
        /// <param name="target">The target of the move.</param>
        /// <param name="showMessage">Whether to show a failure message.</param>
        /// <returns>True if the move fails, otherwise false.</returns>
        bool MoveFailedAromaVeil(IBattler user, IBattler target, bool showMessage = true);

        /// <summary>
        /// Checks for damage absorption effects (e.g., Substitute, Disguise, Ice Face).
        /// </summary>
        /// <param name="user">The user of the move.</param>
        /// <param name="target">The target of the move.</param>
        void CheckDamageAbsorption(IBattler user, IBattler target);

        /// <summary>
        /// Reduces the calculated damage for the target, considering effects like Endure, Sturdy, Focus Sash, and affection.
        /// </summary>
        /// <param name="user">The user of the move.</param>
        /// <param name="target">The target of the move.</param>
        void ReduceDamage(IBattler user, IBattler target);

        /// <summary>
        /// Inflicts HP damage to the target, applying all reductions and effects.
        /// </summary>
        /// <param name="target">The target of the move.</param>
        void InflictHPDamage(IBattler target);

        /// <summary>
        /// Animates the hit and HP loss for the user and targets.
        /// </summary>
        /// <remarks>
        /// Animate being damaged and losing HP (by a move)
        /// </remarks>
        /// <param name="user">The user of the move.</param>
        /// <param name="targets">The targets of the move.</param>
        void AnimateHitAndHPLost(IBattler user, IList<IBattler> targets);

        /// <summary>
        /// Displays the effectiveness message for a hit (e.g., "It's super effective!").
        /// </summary>
        /// <param name="user">The user of the move.</param>
        /// <param name="target">The target of the move.</param>
        /// <param name="numTargets">The number of targets.</param>
        void EffectivenessMessage(IBattler user, IBattler target, int numTargets = 1);

        /// <summary>
        /// Displays the hit effectiveness messages, including critical hits and substitute messages.
        /// </summary>
        /// <param name="user">The user of the move.</param>
        /// <param name="target">The target of the move.</param>
        /// <param name="numTargets">The number of targets.</param>
        void HitEffectivenessMessages(IBattler user, IBattler target, int numTargets = 1);

        /// <summary>
        /// Displays the endure/KO message for the target (e.g., Sturdy, Focus Sash, Disguise).
        /// </summary>
        /// <param name="target">The target of the move.</param>
        void EndureKOMessage(IBattler target);

        /// <summary>
        /// Records the damage lost for the user and target (e.g., for Counter, Mirror Coat, Metal Burst).
        /// </summary>
        /// <remarks>
        /// Used by Counter/Mirror Coat/Metal Burst/Revenge/Focus Punch/Bide/Assurance.
        /// </remarks>
        /// <param name="user">The user of the move.</param>
        /// <param name="target">The target of the move.</param>
        void RecordDamageLost(IBattler user, IBattler target);
    }
}