using System;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for battle damage state tracking all damage calculation and mitigation information.
    /// Manages type effectiveness, accuracy checks, critical hits, damage mitigation effects,
    /// and various protection states during battle damage resolution.
    /// </summary>
    public interface IDamageState
    {
        /// <summary>
        /// Type effectiveness multiplier for the move against the target.
        /// Determines how effective the move type is against the target's type(s).
        /// </summary>
        double typeMod { get; set; }

        /// <summary>
        /// Whether the target is unaffected by the move (e.g., Ghost vs Normal).
        /// Indicates complete immunity to the move's effects.
        /// </summary>
        bool unaffected { get; set; }

        /// <summary>
        /// Whether the target is protected from the move (e.g., Protect, Detect).
        /// Indicates the move was blocked by a protection move.
        /// </summary>
        bool @protected { get; set; }

        /// <summary>
        /// Whether Magic Coat reflected the move back to the user.
        /// Used for moves that can be reflected by Magic Coat.
        /// </summary>
        bool magicCoat { get; set; }

        /// <summary>
        /// Whether Magic Bounce reflected the move back to the user.
        /// Used for status moves that can be bounced by Magic Bounce ability.
        /// </summary>
        bool magicBounce { get; set; }

        /// <summary>
        /// Total HP lost cumulative over all hits in multi-hit moves.
        /// Tracks the sum of all damage dealt across multiple strikes.
        /// </summary>
        int totalHPLost { get; set; }

        /// <summary>
        /// Whether the battler was knocked out by the move.
        /// Indicates if the damage caused the target to faint.
        /// </summary>
        bool fainted { get; set; }

        /// <summary>
        /// Whether the move failed the accuracy check and missed.
        /// Standard accuracy-based miss condition.
        /// </summary>
        bool missed { get; set; }

        /// <summary>
        /// Whether the move missed due to affection mechanics.
        /// Pokemon-Amie/Refresh affection can cause moves to miss.
        /// </summary>
        bool affection_missed { get; set; }

        /// <summary>
        /// Whether the move missed due to target being invulnerable.
        /// Caused by moves like Fly, Dig, or other two-turn invulnerability moves.
        /// </summary>
        bool invulnerable { get; set; }

        /// <summary>
        /// The calculated damage amount before applying HP loss.
        /// Raw damage calculation before considering current HP limits.
        /// </summary>
        int calcDamage { get; set; }

        /// <summary>
        /// Actual HP lost by the target including substitute damage.
        /// The final HP reduction after all calculations and limits.
        /// </summary>
        int hpLost { get; set; }

        /// <summary>
        /// Whether the attack was a critical hit.
        /// Indicates increased damage from critical hit mechanics.
        /// </summary>
        bool critical { get; set; }

        /// <summary>
        /// Whether the critical hit was caused by affection mechanics.
        /// Pokemon-Amie/Refresh affection can cause critical hits.
        /// </summary>
        bool affection_critical { get; set; }

        /// <summary>
        /// Whether a substitute took the damage instead of the battler.
        /// Indicates damage was absorbed by a Substitute.
        /// </summary>
        bool substitute { get; set; }

        /// <summary>
        /// Whether Focus Band activated to prevent fainting.
        /// Focus Band item can prevent KO with 10% chance.
        /// </summary>
        bool focusBand { get; set; }

        /// <summary>
        /// Whether Focus Sash activated to prevent fainting.
        /// Focus Sash item prevents KO from full HP.
        /// </summary>
        bool focusSash { get; set; }

        /// <summary>
        /// Whether Sturdy ability activated to prevent fainting.
        /// Sturdy ability prevents OHKO from full HP.
        /// </summary>
        bool sturdy { get; set; }

        /// <summary>
        /// Whether Disguise ability activated to absorb damage.
        /// Mimikyu's Disguise ability negates the first damaging move.
        /// </summary>
        bool disguise { get; set; }

        /// <summary>
        /// Whether Ice Face ability activated to absorb damage.
        /// Eiscue's Ice Face ability negates the first physical move.
        /// </summary>
        bool iceFace { get; set; }

        /// <summary>
        /// Whether the damage was endured using Endure move.
        /// Endure move prevents fainting for one turn.
        /// </summary>
        bool endured { get; set; }

        /// <summary>
        /// Whether enduring was caused by affection mechanics.
        /// Pokemon-Amie/Refresh affection can cause enduring.
        /// </summary>
        bool affection_endured { get; set; }

        /// <summary>
        /// Whether a type-resisting berry was consumed to reduce damage.
        /// Berries like Occa Berry can reduce super effective damage.
        /// </summary>
        bool berryWeakened { get; set; }

        /// <summary>
        /// Initializes the damage state with default values.
        /// Sets up initial state for damage calculation tracking.
        /// </summary>
        void initialize();

        /// <summary>
        /// Resets all damage state values to defaults.
        /// Clears all flags and counters for a new damage calculation.
        /// </summary>
        void reset();

        /// <summary>
        /// Resets per-hit damage state values while preserving cumulative data.
        /// Used between hits in multi-hit moves to reset hit-specific tracking.
        /// </summary>
        void resetPerHit();
    }
}