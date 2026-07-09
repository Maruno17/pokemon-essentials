using System;
using System.Collections.Generic;
using PokemonEssentials.Data;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the Battler stat stage logic (raising, lowering, checking, etc.).
    /// </summary>
    public interface IBattlerStatStages : IBattler
    {
        /// <summary>
        /// Checks if the stat stage is at its maximum for the given stat.
        /// </summary>
        /// <param name="stat">The stat to check.</param>
        /// <returns>True if the stat stage is at maximum, otherwise false.</returns>
        bool statStageAtMax(int stat);

        /// <summary>
        /// Checks if the battler can raise the given stat stage.
        /// </summary>
        /// <param name="stat">The stat to raise.</param>
        /// <param name="user">The user raising the stat (optional).</param>
        /// <param name="move">The move causing the raise (optional).</param>
        /// <param name="showFailMsg">Whether to show a failure message.</param>
        /// <param name="ignoreContrary">Whether to ignore the Contrary ability.</param>
        /// <returns>True if the stat can be raised, otherwise false.</returns>
        bool CanRaiseStatStage(int stat, IBattler user = null, IMove move = null, bool showFailMsg = false, bool ignoreContrary = false);

        /// <summary>
        /// Raises the stat stage for the given stat by the specified increment.
        /// </summary>
        /// <param name="stat">The stat to raise.</param>
        /// <param name="increment">The amount to raise the stat stage by.</param>
        /// <param name="ignoreContrary">Whether to ignore the Contrary ability.</param>
        /// <returns>The actual increment applied.</returns>
        int RaiseStatStageBasic(int stat, int increment, bool ignoreContrary = false);

        /// <summary>
        /// Raises the stat stage for the given stat, with animation and ability triggers.
        /// </summary>
        /// <param name="stat">The stat to raise.</param>
        /// <param name="increment">The amount to raise the stat stage by.</param>
        /// <param name="user">The user raising the stat.</param>
        /// <param name="showAnim">Whether to show the stat up animation.</param>
        /// <param name="ignoreContrary">Whether to ignore the Contrary ability.</param>
        /// <returns>True if the stat was raised, otherwise false.</returns>
        bool RaiseStatStage(int stat, int increment, IBattler user, bool showAnim = true, bool ignoreContrary = false);

        /// <summary>
        /// Raises the stat stage for the given stat by a specific cause.
        /// </summary>
        /// <param name="stat">The stat to raise.</param>
        /// <param name="increment">The amount to raise the stat stage by.</param>
        /// <param name="user">The user raising the stat.</param>
        /// <param name="cause">The cause of the stat raise.</param>
        /// <param name="showAnim">Whether to show the stat up animation.</param>
        /// <param name="ignoreContrary">Whether to ignore the Contrary ability.</param>
        /// <returns>True if the stat was raised, otherwise false.</returns>
        bool RaiseStatStageByCause(int stat, int increment, IBattler user, string cause, bool showAnim = true, bool ignoreContrary = false);

        /// <summary>
        /// Raises the stat stage for the given stat by an ability.
        /// </summary>
        /// <param name="stat">The stat to raise.</param>
        /// <param name="increment">The amount to raise the stat stage by.</param>
        /// <param name="user">The user raising the stat.</param>
        /// <param name="splashAnim">Whether to show the ability splash animation.</param>
        /// <returns>True if the stat was raised, otherwise false.</returns>
        bool RaiseStatStageByAbility(int stat, int increment, IBattler user, bool splashAnim = true);

        /// <summary>
        /// Checks if the stat stage is at its minimum for the given stat.
        /// </summary>
        /// <param name="stat">The stat to check.</param>
        /// <returns>True if the stat stage is at minimum, otherwise false.</returns>
        bool statStageAtMin(int stat);

        /// <summary>
        /// Checks if the battler can lower the given stat stage.
        /// </summary>
        /// <param name="stat">The stat to lower.</param>
        /// <param name="user">The user lowering the stat (optional).</param>
        /// <param name="move">The move causing the lower (optional).</param>
        /// <param name="showFailMsg">Whether to show a failure message.</param>
        /// <param name="ignoreContrary">Whether to ignore the Contrary ability.</param>
        /// <param name="ignoreMirrorArmor">Whether to ignore the Mirror Armor ability.</param>
        /// <returns>True if the stat can be lowered, otherwise false.</returns>
        bool CanLowerStatStage(int stat, IBattler user = null, IMove move = null, bool showFailMsg = false, bool ignoreContrary = false, bool ignoreMirrorArmor = false);

        /// <summary>
        /// Lowers the stat stage for the given stat by the specified increment.
        /// </summary>
        /// <param name="stat">The stat to lower.</param>
        /// <param name="increment">The amount to lower the stat stage by.</param>
        /// <param name="ignoreContrary">Whether to ignore the Contrary ability.</param>
        /// <returns>The actual increment applied.</returns>
        int LowerStatStageBasic(int stat, int increment, bool ignoreContrary = false);

        /// <summary>
        /// Lowers the stat stage for the given stat, with animation and ability triggers.
        /// </summary>
        /// <param name="stat">The stat to lower.</param>
        /// <param name="increment">The amount to lower the stat stage by.</param>
        /// <param name="user">The user lowering the stat.</param>
        /// <param name="showAnim">Whether to show the stat down animation.</param>
        /// <param name="ignoreContrary">Whether to ignore the Contrary ability.</param>
        /// <param name="mirrorArmorSplash">The splash animation to show if the stat is lowered by Mirror Armor.</param>
        /// <param name="ignoreMirrorArmor">Whether to ignore the Mirror Armor ability.</param>
        /// <returns>True if the stat was lowered, otherwise false.</returns>
        bool LowerStatStage(int stat, int increment, IBattler user, bool showAnim = true, bool ignoreContrary = false, int mirrorArmorSplash = 0, bool ignoreMirrorArmor = false);

        /// <summary>
        /// Lowers the stat stage for the given stat by a specific cause.
        /// </summary>
        /// <param name="stat">The stat to lower.</param>
        /// <param name="increment">The amount to lower the stat stage by.</param>
        /// <param name="user">The user lowering the stat.</param>
        /// <param name="cause">The cause of the stat lower.</param>
        /// <param name="showAnim">Whether to show the stat down animation.</param>
        /// <param name="ignoreContrary">Whether to ignore the Contrary ability.</param>
        /// <param name="ignoreMirrorArmor">Whether to ignore the Mirror Armor ability.</param>
        /// <returns>True if the stat was lowered, otherwise false.</returns>
        bool LowerStatStageByCause(int stat, int increment, IBattler user, string cause, bool showAnim = true, bool ignoreContrary = false, bool ignoreMirrorArmor = false);

        /// <summary>
        /// Lowers the stat stage for the given stat by an ability.
        /// </summary>
        /// <param name="stat">The stat to lower.</param>
        /// <param name="increment">The amount to lower the stat stage by.</param>
        /// <param name="user">The user lowering the stat.</param>
        /// <param name="splashAnim">Whether to show the ability splash animation.</param>
        /// <param name="checkContact">Whether to check for contact with the user.</param>
        /// <returns>True if the stat was lowered, otherwise false.</returns>
        bool LowerStatStageByAbility(int stat, int increment, IBattler user, bool splashAnim = true, bool checkContact = false);

        /// <summary>
        /// Checks if the battler can lower the attack stat stage due to Intimidate ability.
        /// </summary>
        /// <param name="user">The user to check.</param>
        /// <returns>True if the attack stat stage can be lowered, otherwise false.</returns>
        bool LowerAttackStatStageIntimidate(IBattler user);

        /// <summary>
        /// Checks if the battler has altered any stat stages.
        /// </summary>
        /// <returns>True if the battler has altered any stat stages, otherwise false.</returns>
        bool hasAlteredStatStages();

        /// <summary>
        /// Checks if the battler has raised any stat stages.
        /// </summary>
        /// <returns>True if the battler has raised any stat stages, otherwise false.</returns>
        bool hasRaisedStatStages();

        /// <summary>
        /// Checks if the battler has lowered any stat stages.
        /// </summary>
        /// <returns>True if the battler has lowered any stat stages, otherwise false.</returns>
        bool hasLoweredStatStages();

        /// <summary>
        /// Resets all stat stages for the battler.
        /// </summary>
        void ResetStatStages();
    }
}