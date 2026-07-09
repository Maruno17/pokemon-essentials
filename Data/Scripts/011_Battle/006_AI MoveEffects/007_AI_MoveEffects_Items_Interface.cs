using System;
using System.Collections.Generic;

namespace PokemonEssentials.Framework
{
    /// <summary>
    /// Interface for AI handlers related to item manipulation moves and effects.
    /// Manages scoring and evaluation for moves that steal, swap, destroy, or otherwise interact with held items.
    /// </summary>
    public interface IAIMoveEffectsItems
    {
        /// <summary>
        /// Scores moves that allow the user to take the target's item.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the item-stealing move.</returns>
        int scoreUserTakesTargetItemEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Checks if moves that give the user's item to the target will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being checked against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkTargetTakesUserItemFailure(object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that give the user's item to the target.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the item-giving move.</returns>
        int scoreTargetTakesUserItemEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Checks if moves that swap items between user and target will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being checked against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkUserTargetSwapItemsFailure(object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that swap items between user and target.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the item-swapping move.</returns>
        int scoreUserTargetSwapItemsEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Checks if moves that restore the user's consumed item will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkRestoreUserConsumedItemFailure(object move, object user, object ai, object battle);

        /// <summary>
        /// Scores moves that restore the user's consumed item (like Recycle).
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the item restoration move.</returns>
        int scoreRestoreUserConsumedItemEffect(int score, object move, object user, object ai, object battle);

        /// <summary>
        /// Calculates power for moves that remove the target's item.
        /// </summary>
        /// <param name="power">The original power of the move.</param>
        /// <param name="move">The move being used.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target of the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The calculated base power for the item-removing move.</returns>
        int calculateRemoveTargetItemPower(int power, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that remove the target's item (like Knock Off).
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the item-removing move.</returns>
        int scoreRemoveTargetItemEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that destroy target's berries or gems.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the berry/gem destroying move.</returns>
        int scoreDestroyTargetBerryOrGemEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Checks if moves that corrode the target's item will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being checked against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkCorrodeTargetItemFailure(object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that corrode the target's item (like Corrosive Gas).
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the item-corroding move.</returns>
        int scoreCorrodeTargetItemEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Checks if moves that prevent target from using items will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being checked against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkStartTargetCannotUseItemFailure(object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that prevent the target from using items (like Embargo).
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the item-disabling move.</returns>
        int scoreStartTargetCannotUseItemEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that negate all held items (like Magic Room).
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the item-negating field move.</returns>
        int scoreStartNegateHeldItemsEffect(int score, object move, object user, object ai, object battle);

        /// <summary>
        /// Checks if moves that consume the user's berry and raise Defense will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkUserConsumeBerryRaiseDefense2Failure(object move, object user, object ai, object battle);

        /// <summary>
        /// Scores moves that consume the user's berry and raise Defense by 2.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the berry-consuming stat-raising move.</returns>
        int scoreUserConsumeBerryRaiseDefense2Effect(int score, object move, object user, object ai, object battle);

        /// <summary>
        /// Checks if moves that force all battlers to consume berries will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being checked against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkAllBattlersConsumeBerryFailure(object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that force all battlers to consume their berries.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the mass berry consumption move.</returns>
        int scoreAllBattlersConsumeBerryEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that allow user to consume the target's berry.
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the berry-consuming move.</returns>
        int scoreUserConsumeTargetBerryEffect(int score, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Checks if moves that throw the user's item at the target will fail.
        /// </summary>
        /// <param name="move">The move being checked.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>True if the move will fail, false otherwise.</returns>
        bool checkThrowUserItemAtTargetFailure(object move, object user, object ai, object battle);

        /// <summary>
        /// Calculates power for moves that throw the user's item at the target.
        /// </summary>
        /// <param name="power">The original power of the move.</param>
        /// <param name="move">The move being used.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target of the move.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The calculated base power based on the thrown item.</returns>
        int calculateThrowUserItemAtTargetPower(int power, object move, object user, object target, object ai, object battle);

        /// <summary>
        /// Scores moves that throw the user's item at the target (like Fling).
        /// </summary>
        /// <param name="score">The base score for the move.</param>
        /// <param name="move">The move being evaluated.</param>
        /// <param name="user">The Pokemon using the move.</param>
        /// <param name="target">The target being evaluated against.</param>
        /// <param name="ai">The AI battle object.</param>
        /// <param name="battle">The battle instance.</param>
        /// <returns>The adjusted score for the item-throwing move.</returns>
        int scoreThrowUserItemAtTargetEffect(int score, object move, object user, object target, object ai, object battle);
    }

    /// <summary>
    /// Interface for AI item preference evaluation and management.
    /// Provides methods for determining how much a Pokemon values different items.
    /// </summary>
    public interface IAIItemPreferences
    {
        /// <summary>
        /// Evaluates how much a Pokemon wants to have a specific item.
        /// </summary>
        /// <param name="pokemon">The Pokemon being evaluated.</param>
        /// <param name="item">The item being considered.</param>
        /// <param name="battleContext">The current battle context.</param>
        /// <returns>A preference score where higher values indicate stronger desire for the item.</returns>
        int evaluateItemDesire(object pokemon, object item, object battleContext);

        /// <summary>
        /// Determines if a Pokemon would benefit from not having an item.
        /// </summary>
        /// <param name="pokemon">The Pokemon being evaluated.</param>
        /// <param name="currentItem">The Pokemon's current item (if any).</param>
        /// <returns>True if the Pokemon would benefit from being itemless, false otherwise.</returns>
        bool prefersNoItem(object pokemon, object currentItem);

        /// <summary>
        /// Calculates the impact of losing an item for a Pokemon.
        /// </summary>
        /// <param name="pokemon">The Pokemon that would lose the item.</param>
        /// <param name="item">The item that would be lost.</param>
        /// <param name="permanent">Whether the loss is permanent or temporary.</param>
        /// <returns>A negative score representing the impact of losing the item.</returns>
        int calculateItemLossImpact(object pokemon, object item, bool permanent);

        /// <summary>
        /// Evaluates the value of swapping items between two Pokemon.
        /// </summary>
        /// <param name="pokemon1">The first Pokemon involved in the swap.</param>
        /// <param name="pokemon2">The second Pokemon involved in the swap.</param>
        /// <param name="item1">The first Pokemon's current item.</param>
        /// <param name="item2">The second Pokemon's current item.</param>
        /// <returns>A score representing the net benefit of the swap for pokemon1.</returns>
        int evaluateItemSwapValue(object pokemon1, object pokemon2, object item1, object item2);

        /// <summary>
        /// Determines if an item interaction move should be prioritized.
        /// </summary>
        /// <param name="move">The item interaction move being considered.</param>
        /// <param name="user">The Pokemon that would use the move.</param>
        /// <param name="target">The target of the move.</param>
        /// <param name="alternativeMoves">Other moves the user could use instead.</param>
        /// <returns>True if the item interaction should be prioritized, false otherwise.</returns>
        bool shouldPrioritizeItemInteraction(object move, object user, object target, IList<object> alternativeMoves);
    }

    /// <summary>
    /// Interface for AI berry and consumable item evaluation.
    /// Specialized for handling berry consumption strategies and timing.
    /// </summary>
    public interface IAIBerryManagement
    {
        /// <summary>
        /// Evaluates the optimal timing for consuming a berry.
        /// </summary>
        /// <param name="pokemon">The Pokemon considering berry consumption.</param>
        /// <param name="berry">The berry being considered.</param>
        /// <param name="battleState">The current battle state.</param>
        /// <returns>A timing score where higher values indicate better timing.</returns>
        int evaluateBerryConsumptionTiming(object pokemon, object berry, object battleState);

        /// <summary>
        /// Calculates the net benefit of forcing berry consumption on opponents.
        /// </summary>
        /// <param name="user">The Pokemon forcing berry consumption.</param>
        /// <param name="targets">The targets that would have berries consumed.</param>
        /// <param name="affectedBerries">The berries that would be consumed.</param>
        /// <returns>A net benefit score for forcing berry consumption.</returns>
        int calculateForcedBerryConsumptionBenefit(object user, IList<object> targets, IList<object> affectedBerries);

        /// <summary>
        /// Determines if a Pokemon should use a move to consume its own berry.
        /// </summary>
        /// <param name="pokemon">The Pokemon with the berry.</param>
        /// <param name="berry">The berry being considered for consumption.</param>
        /// <param name="consumptionMove">The move that would consume the berry.</param>
        /// <returns>True if the Pokemon should consume its berry via the move, false otherwise.</returns>
        bool shouldUseMoveTConsumeBerry(object pokemon, object berry, object consumptionMove);

        /// <summary>
        /// Evaluates the strategic value of stealing and consuming an opponent's berry.
        /// </summary>
        /// <param name="user">The Pokemon that would steal and consume the berry.</param>
        /// <param name="target">The Pokemon whose berry would be stolen.</param>
        /// <param name="berry">The berry that would be stolen and consumed.</param>
        /// <returns>A strategic value score for the berry theft and consumption.</returns>
        int evaluateBerryTheftValue(object user, object target, object berry);

        /// <summary>
        /// Assesses the impact of abilities that interact with berry consumption.
        /// </summary>
        /// <param name="pokemon">The Pokemon with the berry-related ability.</param>
        /// <param name="ability">The ability that affects berry consumption.</param>
        /// <param name="berryAction">The type of berry action being considered.</param>
        /// <returns>A modifier score for the ability's impact on berry strategy.</returns>
        int assessBerryAbilityImpact(object pokemon, object ability, string berryAction);
    }
}