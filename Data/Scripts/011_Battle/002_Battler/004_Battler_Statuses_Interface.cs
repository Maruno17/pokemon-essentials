using System;
using System.Collections.Generic;
using PokemonEssentials.Data;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the Battler status logic (infliction, curing, checks, etc.).
    /// </summary>
    public interface IBattlerStatuses : IBattler
    {
        /// <summary>
        /// Checks if the battler has the specified status, including Comatose.
        /// </summary>
        /// <param name="checkStatus">The status to check for.</param>
        /// <returns>True if the battler has the status, otherwise false.</returns>
        bool HasStatus(int checkStatus);

        /// <summary>
        /// Checks if the battler has any status condition.
        /// </summary>
        /// <returns>True if the battler has any status, otherwise false.</returns>
        bool HasAnyStatus();

        /// <summary>
        /// Checks if the battler can be inflicted with the given status.
        /// </summary>
        /// <param name="newStatus">The status to inflict.</param>
        /// <param name="user">The user inflicting the status.</param>
        /// <param name="showMessages">Whether to show messages for failure.</param>
        /// <param name="move">The move causing the status (optional).</param>
        /// <param name="ignoreStatus">Whether to ignore current status.</param>
        /// <returns>True if the status can be inflicted, otherwise false.</returns>
        bool CanInflictStatus(int newStatus, IBattler user, bool showMessages, IMove move = null, bool ignoreStatus = false);

        /// <summary>
        /// Checks if the battler can be inflicted with the given status via Synchronize.
        /// </summary>
        /// <param name="newStatus">The status to inflict.</param>
        /// <param name="user">The user inflicting the status.</param>
        /// <returns>True if the status can be inflicted via Synchronize, otherwise false.</returns>
        bool CanSynchronizeStatus(int newStatus, IBattler user);

        /// <summary>
        /// Inflicts the given status on the battler.
        /// </summary>
        /// <param name="newStatus">The status to inflict.</param>
        /// <param name="newStatusCount">The count of the new status.</param>
        /// <param name="msg">The message to display when the status is inflicted.</param>
        /// <param name="user">The user inflicting the status.</param>
        void InflictStatus(int newStatus, int newStatusCount = 0, string msg = null, IBattler user = null);

        /// <summary>
        /// Checks if the battler is asleep.
        /// </summary>
        /// <returns>True if the battler is asleep, otherwise false.</returns>
        //bool asleep();
        bool asleep { get; }

        /// <summary>
        /// Checks if the battler can sleep.
        /// </summary>
        /// <param name="user">The user checking the sleep condition.</param>
        /// <param name="showMessages">Whether to show messages for failure.</param>
        /// <param name="move">The move causing the sleep condition (optional).</param>
        /// <param name="ignoreStatus">Whether to ignore current status.</param>
        /// <returns>True if the battler can sleep, otherwise false.</returns>
        bool CanSleep(IBattler user, bool showMessages, IMove move = null, bool ignoreStatus = false);

        /// <summary>
        /// Checks if the battler can sleep due to a yawn.
        /// </summary>
        /// <returns>True if the battler can sleep due to a yawn, otherwise false.</returns>
        bool CanSleepYawn();

        /// <summary>
        /// Puts the battler to sleep.
        /// </summary>
        /// <param name="user">The user putting the battler to sleep.</param>
        /// <param name="msg">The message to display when the battler is put to sleep.</param>
        void Sleep(IBattler user = null, string msg = null);

        /// <summary>
        /// Puts the battler to sleep by itself.
        /// </summary>
        /// <param name="msg">The message to display when the battler is put to sleep.</param>
        /// <param name="duration">The duration of the sleep.</param>
        void SleepSelf(string msg = null, int duration = -1);

        /// <summary>
        /// Gets the duration of the battler's sleep.
        /// </summary>
        /// <param name="duration">The duration to get.</param>
        /// <returns>The duration of the battler's sleep.</returns>
        int SleepDuration(int duration = -1);

        /// <summary>
        /// Checks if the battler is poisoned.
        /// </summary>
        /// <returns>True if the battler is poisoned, otherwise false.</returns>
        //bool poisoned();
        bool poisoned { get; }

        /// <summary>
        /// Checks if the battler can be poisoned.
        /// </summary>
        /// <param name="user">The user checking the poison condition.</param>
        /// <param name="showMessages">Whether to show messages for failure.</param>
        /// <param name="move">The move causing the poison condition (optional).</param>
        /// <returns>True if the battler can be poisoned, otherwise false.</returns>
        bool CanPoison(IBattler user, bool showMessages, IMove move = null);

        /// <summary>
        /// Checks if the battler can be poisoned via Synchronize.
        /// </summary>
        /// <param name="target">The target battler.</param>
        /// <returns>True if the battler can be poisoned via Synchronize, otherwise false.</returns>
        bool CanPoisonSynchronize(IBattler target);

        /// <summary>
        /// Poisons the battler.
        /// </summary>
        /// <param name="user">The user poisoning the battler.</param>
        /// <param name="msg">The message to display when the battler is poisoned.</param>
        /// <param name="toxic">Whether the poison is toxic.</param>
        void Poison(IBattler user = null, string msg = null, bool toxic = false);

        /// <summary>
        /// Checks if the battler is burned.
        /// </summary>
        /// <returns>True if the battler is burned, otherwise false.</returns>
        //bool burned();
        bool burned { get; }

        /// <summary>
        /// Checks if the battler can be burned.
        /// </summary>
        /// <param name="user">The user checking the burn condition.</param>
        /// <param name="showMessages">Whether to show messages for failure.</param>
        /// <param name="move">The move causing the burn condition (optional).</param>
        /// <returns>True if the battler can be burned, otherwise false.</returns>
        bool CanBurn(IBattler user, bool showMessages, IMove move = null);

        /// <summary>
        /// Checks if the battler can be burned via Synchronize.
        /// </summary>
        /// <param name="target">The target battler.</param>
        /// <returns>True if the battler can be burned via Synchronize, otherwise false.</returns>
        bool CanBurnSynchronize(IBattler target);

        /// <summary>
        /// Burns the battler.
        /// </summary>
        /// <param name="user">The user burning the battler.</param>
        /// <param name="msg">The message to display when the battler is burned.</param>
        void Burn(IBattler user = null, string msg = null);

        /// <summary>
        /// Checks if the battler is paralyzed.
        /// </summary>
        /// <returns>True if the battler is paralyzed, otherwise false.</returns>
        //bool paralyzed();
        bool paralyzed { get; }

        /// <summary>
        /// Checks if the battler can be paralyzed.
        /// </summary>
        /// <param name="user">The user checking the paralysis condition.</param>
        /// <param name="showMessages">Whether to show messages for failure.</param>
        /// <param name="move">The move causing the paralysis condition (optional).</param>
        /// <returns>True if the battler can be paralyzed, otherwise false.</returns>
        bool CanParalyze(IBattler user, bool showMessages, IMove move = null);

        /// <summary>
        /// Checks if the battler can be paralyzed via Synchronize.
        /// </summary>
        /// <param name="target">The target battler.</param>
        /// <returns>True if the battler can be paralyzed via Synchronize, otherwise false.</returns>
        bool CanParalyzeSynchronize(IBattler target);

        /// <summary>
        /// Paralyzes the battler.
        /// </summary>
        /// <param name="user">The user paralyzing the battler.</param>
        /// <param name="msg">The message to display when the battler is paralyzed.</param>
        void Paralyze(IBattler user = null, string msg = null);

        /// <summary>
        /// Checks if the battler is frozen.
        /// </summary>
        /// <returns>True if the battler is frozen, otherwise false.</returns>
        //bool frozen();
        bool frozen { get; }

        /// <summary>
        /// Checks if the battler can be frozen.
        /// </summary>
        /// <param name="user">The user checking the freeze condition.</param>
        /// <param name="showMessages">Whether to show messages for failure.</param>
        /// <param name="move">The move causing the freeze condition (optional).</param>
        /// <returns>True if the battler can be frozen, otherwise false.</returns>
        bool CanFreeze(IBattler user, bool showMessages, IMove move = null);

        /// <summary>
        /// Freezes the battler.
        /// </summary>
        /// <param name="user">The user freezing the battler.</param>
        /// <param name="msg">The message to display when the battler is frozen.</param>
        void Freeze(IBattler user = null, string msg = null);

        /// <summary>
        /// Continues the battler's current status.
        /// </summary>
        void ContinueStatus();

        /// <summary>
        /// Cures the battler's status.
        /// </summary>
        /// <param name="showMessages">Whether to show messages for failure.</param>
        void CureStatus(bool showMessages = true);

        /// <summary>
        /// Checks if the battler can be confused.
        /// </summary>
        /// <param name="user">The user checking the confusion condition.</param>
        /// <param name="showMessages">Whether to show messages for failure.</param>
        /// <param name="move">The move causing the confusion condition (optional).</param>
        /// <param name="selfInflicted">Whether the confusion is self-inflicted.</param>
        /// <returns>True if the battler can be confused, otherwise false.</returns>
        bool CanConfuse(IBattler user = null, bool showMessages = true, IMove move = null, bool selfInflicted = false);

        /// <summary>
        /// Checks if the battler can be confused by itself.
        /// </summary>
        /// <param name="showMessages">Whether to show messages for failure.</param>
        /// <returns>True if the battler can be confused by itself, otherwise false.</returns>
        bool CanConfuseSelf(bool showMessages);

        /// <summary>
        /// Confuses the battler.
        /// </summary>
        /// <param name="msg">The message to display when the battler is confused.</param>
        void Confuse(string msg = null);

        /// <summary>
        /// Gets the duration of the battler's confusion.
        /// </summary>
        /// <param name="duration">The duration to get.</param>
        /// <returns>The duration of the battler's confusion.</returns>
        int ConfusionDuration(int duration = -1);

        /// <summary>
        /// Cures the battler's confusion.
        /// </summary>
        void CureConfusion();

        /// <summary>
        /// Checks if the battler can be attracted.
        /// </summary>
        /// <param name="user">The user checking the attraction condition.</param>
        /// <param name="showMessages">Whether to show messages for failure.</param>
        /// <returns>True if the battler can be attracted, otherwise false.</returns>
        bool CanAttract(IBattler user, bool showMessages = true);

        /// <summary>
        /// Attracts the battler.
        /// </summary>
        /// <param name="user">The user attracting the battler.</param>
        /// <param name="msg">The message to display when the battler is attracted.</param>
        void Attract(IBattler user, string msg = null);

        /// <summary>
        /// Cures the battler's attraction.
        /// </summary>
        void CureAttract();

        /// <summary>
        /// Flinches the battler.
        /// </summary>
        /// <param name="user">The user flinching the battler.</param>
        void Flinch(IBattler user = null);
    }
}