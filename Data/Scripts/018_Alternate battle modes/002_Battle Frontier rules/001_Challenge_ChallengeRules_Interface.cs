using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for comprehensive Pokemon challenge rules system
    /// </summary>
    public interface IPokemonChallengeRules
    {
        /// <summary>
        /// Gets the ruleset for Pokemon and team validation
        /// </summary>
        IPokemonRuleSet ruleset { get; }

        /// <summary>
        /// Gets the battle type (Tower, Palace, Arena, etc.)
        /// </summary>
        IBattleType battletype { get; }

        /// <summary>
        /// Gets the level adjustment rules
        /// </summary>
        ILevelAdjustment levelAdjustment { get; }

        /// <summary>
        /// Initializes challenge rules with optional ruleset
        /// </summary>
        /// <param name="ruleset">Optional initial ruleset</param>
        void initialize(IPokemonRuleSet ruleset = null);

        /// <summary>
        /// Creates a copy of the challenge rules
        /// </summary>
        /// <returns>Copied challenge rules</returns>
        IPokemonChallengeRules copy();

        /// <summary>
        /// Sets the base ruleset for Pokemon validation
        /// </summary>
        /// <param name="rule">Ruleset to use</param>
        /// <returns>This instance for chaining</returns>
        IPokemonChallengeRules setRuleset(IPokemonRuleSet rule);

        /// <summary>
        /// Sets the battle type for this challenge
        /// </summary>
        /// <param name="rule">Battle type to use</param>
        /// <returns>This instance for chaining</returns>
        IPokemonChallengeRules setBattleType(IBattleType rule);

        /// <summary>
        /// Sets the level adjustment rules
        /// </summary>
        /// <param name="rule">Level adjustment to use</param>
        /// <returns>This instance for chaining</returns>
        IPokemonChallengeRules setLevelAdjustment(ILevelAdjustment rule);

        /// <summary>
        /// Gets the number of Pokemon required
        /// </summary>
        /// <returns>Number of Pokemon</returns>
        int number();

        /// <summary>
        /// Sets the number of Pokemon required
        /// </summary>
        /// <param name="number">Number of Pokemon</param>
        /// <returns>This instance for chaining</returns>
        IPokemonChallengeRules setNumber(int number);

        /// <summary>
        /// Sets whether this is a double battle format
        /// </summary>
        /// <param name="value">True for double battles, false for single</param>
        /// <returns>This instance for chaining</returns>
        IPokemonChallengeRules setDoubleBattle(bool value);

        /// <summary>
        /// Adjusts levels of both parties before battle
        /// </summary>
        /// <param name="party1">First party (player)</param>
        /// <param name="party2">Second party (opponent)</param>
        /// <returns>Original level data for restoration</returns>
        int?[][] adjustLevels(IList<IPokemon> party1, IList<IPokemon> party2);

        /// <summary>
        /// Restores original levels after battle
        /// </summary>
        /// <param name="party1">First party (player)</param>
        /// <param name="party2">Second party (opponent)</param>
        /// <param name="adjusts">Original level data</param>
        void unadjustLevels(IList<IPokemon> party1, IList<IPokemon> party2, object adjusts);

        /// <summary>
        /// Adjusts levels for both teams if bilateral adjustment is configured
        /// </summary>
        /// <param name="party1">First party</param>
        /// <param name="party2">Second party</param>
        /// <returns>Original level data for restoration</returns>
        int?[][] adjustLevelsBilateral(IList<IPokemon> party1, IList<IPokemon> party2);

        /// <summary>
        /// Restores original levels for bilateral adjustments
        /// </summary>
        /// <param name="party1">First party</param>
        /// <param name="party2">Second party</param>
        /// <param name="adjusts">Original level data</param>
        void unadjustLevelsBilateral(IList<IPokemon> party1, IList<IPokemon> party2, object adjusts);

        /// <summary>
        /// Adds a rule that applies to individual Pokemon
        /// </summary>
        /// <param name="rule">Pokemon rule to add</param>
        /// <returns>This instance for chaining</returns>
        IPokemonChallengeRules addPokemonRule(IBattleRestriction rule);

        /// <summary>
        /// Adds level-based restrictions
        /// </summary>
        /// <param name="minLevel">Minimum level allowed</param>
        /// <param name="maxLevel">Maximum level allowed</param>
        /// <param name="totalLevel">Total level limit for team</param>
        /// <returns>This instance for chaining</returns>
        IPokemonChallengeRules addLevelRule(int minLevel, int maxLevel, int totalLevel);

        /// <summary>
        /// Adds a rule that applies to subsets of the team
        /// </summary>
        /// <param name="rule">Subset rule to add</param>
        /// <returns>This instance for chaining</returns>
        IPokemonChallengeRules addSubsetRule(IBattleTeamRestriction rule);

        /// <summary>
        /// Adds a rule that applies to the entire team
        /// </summary>
        /// <param name="rule">Team rule to add</param>
        /// <returns>This instance for chaining</returns>
        IPokemonChallengeRules addTeamRule(IBattleTeamRestriction rule);

        /// <summary>
        /// Adds a rule that applies during battle
        /// </summary>
        /// <param name="rule">Battle rule to add</param>
        /// <returns>This instance for chaining</returns>
        IPokemonChallengeRules addBattleRule(IBattleRule rule);

        /// <summary>
        /// Creates a battle instance with these rules applied
        /// </summary>
        /// <param name="scene">Battle scene</param>
        /// <param name="trainer1">First trainer</param>
        /// <param name="trainer2">Second trainer</param>
        /// <returns>Configured battle instance</returns>
        IBattle createBattle(IBattleScene scene, ITrainer trainer1, ITrainer trainer2);
    }

    /// <summary>
    /// Interface for Pika Cup rules (Level 15-20, total 50)
    /// </summary>
    public interface IMainCupRulesProvider : IMain
    //public interface IPikaCupRulesProvider
    {
        /// <summary>
        /// Creates Pika Cup rules
        /// </summary>
        /// <param name="double">Whether to use double battles</param>
        /// <returns>Configured Pika Cup rules</returns>
        IPokemonChallengeRules pbPikaCupRules(bool @double);
    //}

    /// <summary>
    /// Interface for Poke Cup rules (Level 50-55, total 155)
    /// </summary>
    //public interface IPokeCupRulesProvider
    //{
        /// <summary>
        /// Creates Poke Cup rules
        /// </summary>
        /// <param name="double">Whether to use double battles</param>
        /// <returns>Configured Poke Cup rules</returns>
        IPokemonChallengeRules pbPokeCupRules(bool @double);
    //}

    /// <summary>
    /// Interface for Prime Cup rules (Open level)
    /// </summary>
    //public interface IPrimeCupRulesProvider
    //{
        /// <summary>
        /// Creates Prime Cup rules
        /// </summary>
        /// <param name="double">Whether to use double battles</param>
        /// <returns>Configured Prime Cup rules</returns>
        IPokemonChallengeRules pbPrimeCupRules(bool @double);
    //}

    /// <summary>
    /// Interface for Fancy Cup rules (Level 25-30, height/weight restrictions)
    /// </summary>
    //public interface IFancyCupRulesProvider
    //{
        /// <summary>
        /// Creates Fancy Cup rules
        /// </summary>
        /// <param name="double">Whether to use double battles</param>
        /// <returns>Configured Fancy Cup rules</returns>
        IPokemonChallengeRules pbFancyCupRules(bool @double);
    //}

    /// <summary>
    /// Interface for Little Cup rules (Level 5, unevolved only)
    /// </summary>
    //public interface ILittleCupRulesProvider
    //{
        /// <summary>
        /// Creates Little Cup rules
        /// </summary>
        /// <param name="double">Whether to use double battles</param>
        /// <returns>Configured Little Cup rules</returns>
        IPokemonChallengeRules pbLittleCupRules(bool @double);

        /// <summary>
        /// Creates Strict Little Cup rules (stricter restrictions)
        /// </summary>
        /// <param name="double">Whether to use double battles</param>
        /// <returns>Configured Strict Little Cup rules</returns>
        IPokemonChallengeRules pbStrictLittleCupRules(bool @double);
    //}

    /// <summary>
    /// Interface for Battle Tower rules
    /// </summary>
    //public interface IBattleTowerRulesProvider
    //{
        /// <summary>
        /// Creates Battle Tower rules
        /// </summary>
        /// <param name="double">Whether to use double battles</param>
        /// <param name="openlevel">Whether to use open level format</param>
        /// <returns>Configured Battle Tower rules</returns>
        IPokemonChallengeRules pbBattleTowerRules(bool @double, bool openlevel);
    //}

    /// <summary>
    /// Interface for Battle Palace rules
    /// </summary>
    //public interface IBattlePalaceRulesProvider
    //{
        /// <summary>
        /// Creates Battle Palace rules
        /// </summary>
        /// <param name="double">Whether to use double battles</param>
        /// <param name="openlevel">Whether to use open level format</param>
        /// <returns>Configured Battle Palace rules</returns>
        IPokemonChallengeRules pbBattlePalaceRules(bool @double, bool openlevel);
    //}

    /// <summary>
    /// Interface for Battle Arena rules
    /// </summary>
    //public interface IBattleArenaRulesProvider
    //{
        /// <summary>
        /// Creates Battle Arena rules (always single battles)
        /// </summary>
        /// <param name="openlevel">Whether to use open level format</param>
        /// <returns>Configured Battle Arena rules</returns>
        IPokemonChallengeRules pbBattleArenaRules(bool openlevel);
    //}

    /// <summary>
    /// Interface for Battle Factory rules
    /// </summary>
    //public interface IBattleFactoryRulesProvider
    //{
        /// <summary>
        /// Creates Battle Factory rules
        /// </summary>
        /// <param name="double">Whether to use double battles</param>
        /// <param name="openlevel">Whether to use open level format</param>
        /// <returns>Configured Battle Factory rules</returns>
        IPokemonChallengeRules pbBattleFactoryRules(bool @double, bool openlevel);
    }
}