using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Base interface for battle rules that modify battle behavior
    /// </summary>
    public interface IBattleRule
    {
        /// <summary>
        /// Applies this rule to a battle instance
        /// </summary>
        /// <param name="battle">Battle to apply rule to</param>
        void setRule(IBattle battle);
    }

    /// <summary>
    /// Interface for double battle rule
    /// </summary>
    public interface IDoubleBattle : IBattleRule
    {
        /// <summary>
        /// Sets battle mode to double battles
        /// </summary>
        /// <param name="battle">Battle to modify</param>
        void setRule(IBattle battle);
    }

    /// <summary>
    /// Interface for single battle rule
    /// </summary>
    public interface ISingleBattle : IBattleRule
    {
        /// <summary>
        /// Sets battle mode to single battles
        /// </summary>
        /// <param name="battle">Battle to modify</param>
        void setRule(IBattle battle);
    }

    /// <summary>
    /// Interface for Soul Dew battle clause
    /// </summary>
    public interface ISoulDewBattleClause : IBattleRule
    {
        /// <summary>
        /// Applies Soul Dew restrictions during battle
        /// </summary>
        /// <param name="battle">Battle to modify</param>
        void setRule(IBattle battle);
    }

    /// <summary>
    /// Interface for sleep clause (limits number of sleeping Pokemon)
    /// </summary>
    public interface ISleepClause : IBattleRule
    {
        /// <summary>
        /// Applies sleep clause restrictions
        /// </summary>
        /// <param name="battle">Battle to modify</param>
        void setRule(IBattle battle);
    }

    /// <summary>
    /// Interface for freeze clause (limits number of frozen Pokemon)
    /// </summary>
    public interface IFreezeClause : IBattleRule
    {
        /// <summary>
        /// Applies freeze clause restrictions
        /// </summary>
        /// <param name="battle">Battle to modify</param>
        void setRule(IBattle battle);
    }

    /// <summary>
    /// Interface for evasion clause (restricts evasion-boosting moves)
    /// </summary>
    public interface IEvasionClause : IBattleRule
    {
        /// <summary>
        /// Applies evasion clause restrictions
        /// </summary>
        /// <param name="battle">Battle to modify</param>
        void setRule(IBattle battle);
    }

    /// <summary>
    /// Interface for OHKO clause (restricts one-hit KO moves)
    /// </summary>
    public interface IOHKOClause : IBattleRule
    {
        /// <summary>
        /// Applies OHKO clause restrictions
        /// </summary>
        /// <param name="battle">Battle to modify</param>
        void setRule(IBattle battle);
    }

    /// <summary>
    /// Interface for Perish Song clause (restricts Perish Song usage)
    /// </summary>
    public interface IPerishSongClause : IBattleRule
    {
        /// <summary>
        /// Applies Perish Song clause restrictions
        /// </summary>
        /// <param name="battle">Battle to modify</param>
        void setRule(IBattle battle);
    }

    /// <summary>
    /// Interface for Self-KO clause (restricts self-knockout moves)
    /// </summary>
    public interface ISelfKOClause : IBattleRule
    {
        /// <summary>
        /// Applies Self-KO clause restrictions
        /// </summary>
        /// <param name="battle">Battle to modify</param>
        void setRule(IBattle battle);
    }

    /// <summary>
    /// Interface for Selfdestruct clause (restricts Explosion/Self-Destruct)
    /// </summary>
    public interface ISelfdestructClause : IBattleRule
    {
        /// <summary>
        /// Applies Selfdestruct clause restrictions
        /// </summary>
        /// <param name="battle">Battle to modify</param>
        void setRule(IBattle battle);
    }

    /// <summary>
    /// Interface for Sonic Boom clause (restricts Sonic Boom move)
    /// </summary>
    public interface ISonicBoomClause : IBattleRule
    {
        /// <summary>
        /// Applies Sonic Boom clause restrictions
        /// </summary>
        /// <param name="battle">Battle to modify</param>
        void setRule(IBattle battle);
    }

    /// <summary>
    /// Interface for modified sleep clause (alternative sleep restrictions)
    /// </summary>
    public interface IModifiedSleepClause : IBattleRule
    {
        /// <summary>
        /// Applies modified sleep clause restrictions
        /// </summary>
        /// <param name="battle">Battle to modify</param>
        void setRule(IBattle battle);
    }

    /// <summary>
    /// Interface for Skill Swap clause (restricts Skill Swap move)
    /// </summary>
    public interface ISkillSwapClause : IBattleRule
    {
        /// <summary>
        /// Applies Skill Swap clause restrictions
        /// </summary>
        /// <param name="battle">Battle to modify</param>
        void setRule(IBattle battle);
    }
}