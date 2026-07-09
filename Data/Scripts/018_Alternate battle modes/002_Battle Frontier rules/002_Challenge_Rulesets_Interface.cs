using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for Pokemon rule set validation and team management
    /// </summary>
    public interface IPokemonRuleSet
    {
        /// <summary>
        /// Initializes the rule set with optional number of Pokemon
        /// </summary>
        /// <param name="number">Number of Pokemon allowed (optional, defaults to 0)</param>
        void initialize(int number = 0);

        /// <summary>
        /// Creates a copy of this rule set
        /// </summary>
        /// <returns>Copied rule set</returns>
        IPokemonRuleSet copy();

        /// <summary>
        /// Gets the minimum number of Pokemon required
        /// </summary>
        /// <returns>Minimum Pokemon count</returns>
        int minLength();

        /// <summary>
        /// Gets the maximum number of Pokemon allowed
        /// </summary>
        /// <returns>Maximum Pokemon count</returns>
        int maxLength();

        /// <summary>
        /// Gets the maximum number of Pokemon allowed (alias for maxLength)
        /// </summary>
        /// <returns>Maximum Pokemon count</returns>
        int number();

        /// <summary>
        /// Gets the minimum team length for validation
        /// </summary>
        /// <returns>Minimum team length</returns>
        int minTeamLength();

        /// <summary>
        /// Gets the maximum team length for validation
        /// </summary>
        /// <returns>Maximum team length</returns>
        int maxTeamLength();

        /// <summary>
        /// Returns the suggested number of Pokemon for a valid team
        /// </summary>
        /// <returns>Suggested Pokemon count</returns>
        int suggestedNumber();

        /// <summary>
        /// Returns a suggested level for team members
        /// </summary>
        /// <returns>Suggested level</returns>
        int suggestedLevel();

        /// <summary>
        /// Sets the number range for Pokemon count
        /// </summary>
        /// <param name="minValue">Minimum Pokemon count</param>
        /// <param name="maxValue">Maximum Pokemon count</param>
        /// <returns>This instance for chaining</returns>
        IPokemonRuleSet setNumberRange(int minValue, int maxValue);

        /// <summary>
        /// Sets the exact number of Pokemon required
        /// </summary>
        /// <param name="value">Number of Pokemon</param>
        /// <returns>This instance for chaining</returns>
        IPokemonRuleSet setNumber(int value);

        /// <summary>
        /// Adds a rule that applies to the entire team
        /// </summary>
        /// <remarks>
        /// This rule checks either<para>
        /// - the entire team to determine whether a subset of the team meets the rule, or </para>
        /// - whether the entire team meets the rule. If the condition holds for the
        ///   entire team, the condition must also hold for any possible subset of the
        ///   team with the suggested number.
        /// </remarks>
        /// <example>
        /// Examples of team rules:
        /// - No two Pokemon can be the same species.
        /// - No two Pokemon can hold the same items.
        /// </example>
        /// <param name="rule">Team rule to add</param>
        /// <returns>This instance for chaining</returns>
        IPokemonRuleSet addTeamRule(IBattleTeamRestriction rule);

        /// <summary>
        /// Adds a rule that applies to subsets of the team
        /// </summary>
        /// <remarks>
        /// This rule checks either<para>
        /// - the entire team to determine whether a subset of the team meets the rule, or
        /// - a list of Pokemon whose length is equal to the suggested number. For an
        ///   entire team, the condition must hold for at least one possible subset of
        ///   the team, but not necessarily for the entire team.
        /// A subset rule is "number-dependent", that is, whether the condition is likely
        /// to hold depends on the number of Pokemon in the subset.
        /// </remarks>
        /// <example>
        /// Example of a subset rule:
        /// - The combined level of X Pokemon can't exceed Y.
        /// </example>
        /// <param name="rule">Subset rule to add</param>
        /// <returns>This instance for chaining</returns>
        IPokemonRuleSet addSubsetRule(IBattleTeamRestriction rule);

        /// <summary>
        /// Adds a rule that applies to individual Pokemon
        /// </summary>
        /// <param name="rule">Pokemon rule to add</param>
        /// <returns>This instance for chaining</returns>
        IPokemonRuleSet addPokemonRule(IBattleRestriction rule);

        /// <summary>
        /// Clears all team rules
        /// </summary>
        /// <returns>This instance for chaining</returns>
        IPokemonRuleSet clearTeamRules();

        /// <summary>
        /// Clears all subset rules
        /// </summary>
        /// <returns>This instance for chaining</returns>
        IPokemonRuleSet clearSubsetRules();

        /// <summary>
        /// Clears all Pokemon rules
        /// </summary>
        /// <returns>This instance for chaining</returns>
        IPokemonRuleSet clearPokemonRules();

        /// <summary>
        /// Checks if a Pokemon is valid according to Pokemon rules
        /// </summary>
        /// <param name="pkmn">Pokemon to validate</param>
        /// <returns>True if valid, false otherwise</returns>
        bool isPokemonValid(IPokemon pkmn);

        /// <summary>
        /// Checks if a team has a registrable subset
        /// </summary>
        /// <param name="list">List of Pokemon</param>
        /// <returns>True if team has registrable subset, false otherwise</returns>
        bool hasRegistrableTeam(IList<IPokemon> list);

        /// <summary>
        /// Checks if a team can be registered for competition
        /// </summary>
        /// <param name="team">Team to validate</param>
        /// <returns>True if team can be registered, false otherwise</returns>
        bool canRegisterTeam(IList<IPokemon> team);

        /// <summary>
        /// Checks if a team has a valid subset for battle
        /// </summary>
        /// <param name="team">Team to validate</param>
        /// <returns>True if team has valid subset, false otherwise</returns>
        bool hasValidTeam(IList<IPokemon> team);

        /// <summary>
        /// Validates a team according to all rules
        /// </summary>
        /// <param name="team">Team to validate</param>
        /// <param name="error">Optional error list to populate</param>
        /// <returns>True if team is valid, false otherwise</returns>
        bool isValid(IList<IPokemon> team, IList<string> error = null);
    }

    /// <summary>
    /// Interface for standard rules with species and item clauses
    /// </summary>
    public interface IStandardRules : IPokemonRuleSet
    {
        /// <summary>
        /// Gets the number of Pokemon for this rule set
        /// </summary>
        new int number { get; }

        /// <summary>
        /// Initializes standard rules
        /// </summary>
        /// <param name="number">Number of Pokemon</param>
        /// <param name="level">Maximum level (optional)</param>
        IStandardRules initialize(int number, int? level = null);
    }

    /// <summary>
    /// Interface for Standard Cup (3 Pokemon, Level 50)
    /// </summary>
    public interface IStandardCup : IStandardRules
    {
        /// <summary>
        /// Initializes Standard Cup rules
        /// </summary>
        IStandardCup initialize();

        /// <summary>
        /// Gets the name of this cup
        /// </summary>
        /// <returns>Cup name</returns>
        string name();
    }

    /// <summary>
    /// Interface for Double Cup (4 Pokemon, Level 50)
    /// </summary>
    public interface IDoubleCup : IStandardRules
    {
        /// <summary>
        /// Initializes Double Cup rules
        /// </summary>
        IDoubleCup initialize();

        /// <summary>
        /// Gets the name of this cup
        /// </summary>
        /// <returns>Cup name</returns>
        string name();
    }

    /// <summary>
    /// Interface for Fancy Cup (height/weight restrictions)
    /// </summary>
    public interface IFancyCup : IPokemonRuleSet
    {
        /// <summary>
        /// Initializes Fancy Cup rules
        /// </summary>
        IFancyCup initialize();

        /// <summary>
        /// Gets the name of this cup
        /// </summary>
        /// <returns>Cup name</returns>
        string name();
    }

    /// <summary>
    /// Interface for Little Cup (Level 5, baby Pokemon)
    /// </summary>
    public interface ILittleCup : IPokemonRuleSet
    {
        /// <summary>
        /// Initializes Little Cup rules
        /// </summary>
        ILittleCup initialize();

        /// <summary>
        /// Gets the name of this cup
        /// </summary>
        /// <returns>Cup name</returns>
        string name();
    }

    /// <summary>
    /// Interface for Light Cup (weight restrictions)
    /// </summary>
    public interface ILightCup : IPokemonRuleSet
    {
        /// <summary>
        /// Initializes Light Cup rules
        /// </summary>
        ILightCup initialize();

        /// <summary>
        /// Gets the name of this cup
        /// </summary>
        /// <returns>Cup name</returns>
        string name();
    }
}