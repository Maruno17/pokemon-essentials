using System;
using System.Collections.Generic;

namespace PokemonEssentials.Data
{
    /// <summary>
    /// Interface for Type data, representing Pokemon types and their interactions.
    /// Provides read-only access to type information including effectiveness relationships, flags, and display properties.
    /// </summary>
    public interface IType
    {
        /// <summary>
        /// Gets the unique identifier for this type.
        /// </summary>
        int id { get; }

        /// <summary>
        /// Gets the real name of the type as stored in the data files.
        /// </summary>
        string real_name { get; }

        /// <summary>
        /// Gets the icon position within the types.png file.
        /// Specifies where this type's icon is located in the type icon sheet.
        /// </summary>
        int icon_position { get; }

        /// <summary>
        /// Gets whether this is a special type.
        /// Special types typically use the Special Attack and Special Defense stats.
        /// </summary>
        bool special_type { get; }

        /// <summary>
        /// Gets whether this is a pseudo type.
        /// Pseudo types are special categories that don't follow normal type rules.
        /// </summary>
        bool pseudo_type { get; }

        /// <summary>
        /// Gets the collection of types that this type is weak against.
        /// Attacks from these types deal super effective damage to this type.
        /// </summary>
        IList<int> weaknesses { get; }

        /// <summary>
        /// Gets the collection of types that this type resists.
        /// Attacks from these types deal not very effective damage to this type.
        /// </summary>
        IList<int> resistances { get; }

        /// <summary>
        /// Gets the collection of types that this type is immune to.
        /// Attacks from these types deal no damage to this type.
        /// </summary>
        IList<int> immunities { get; }

        /// <summary>
        /// Gets the collection of flags associated with this type.
        /// Flags provide additional metadata and special behaviors.
        /// </summary>
        IList<string> flags { get; }

        /// <summary>
        /// Gets the PBS file suffix for this type entry.
        /// Used for organizing and loading related data files.
        /// </summary>
        string pbs_file_suffix { get; }

        /// <summary>
        /// Gets the translated name of this type for display to players.
        /// This method retrieves the localized name from the message system.
        /// </summary>
        /// <returns>The translated type name</returns>
        string name { get; }

        /// <summary>
        /// Checks if this type is physical.
        /// Physical types typically use the Attack and Defense stats.
        /// </summary>
        /// <returns>True if this is a physical type, false otherwise</returns>
        bool physical();

        /// <summary>
        /// Checks if this type is special.
        /// Special types typically use the Special Attack and Special Defense stats.
        /// </summary>
        /// <returns>True if this is a special type, false otherwise</returns>
        bool special();

        /// <summary>
        /// Checks if this type has a specific flag.
        /// </summary>
        /// <param name="flag">The flag to check for (case-insensitive)</param>
        /// <returns>True if the type has the specified flag, false otherwise</returns>
        bool has_flag(string flag);

        /// <summary>
        /// Calculates the effectiveness of this type against another type.
        /// Returns a multiplier indicating damage effectiveness.
        /// </summary>
        /// <param name="other_type">The defending type to calculate effectiveness against</param>
        /// <returns>Effectiveness multiplier (0 = ineffective, 1 = not very effective, 2 = normal, 4 = super effective)</returns>
        float effectiveness(IType other_type);
    }

    /// <summary>
    /// Interface for type effectiveness calculations and utilities.
    /// Provides methods for determining damage multipliers and type interaction analysis.
    /// </summary>
    public interface IEffectiveness
    {
        /// <summary>
        /// Checks if the given effectiveness value represents ineffective damage.
        /// </summary>
        /// <param name="value">The effectiveness multiplier to check</param>
        /// <returns>True if the value represents ineffective damage</returns>
        bool ineffective(float value);

        /// <summary>
        /// Checks if the given effectiveness value represents not very effective damage.
        /// </summary>
        /// <param name="value">The effectiveness multiplier to check</param>
        /// <returns>True if the value represents not very effective damage</returns>
        bool not_very_effective(float value);

        /// <summary>
        /// Checks if the given effectiveness value represents resistant damage.
        /// </summary>
        /// <param name="value">The effectiveness multiplier to check</param>
        /// <returns>True if the value represents resistant damage</returns>
        bool resistant(float value);

        /// <summary>
        /// Checks if the given effectiveness value represents normal damage.
        /// </summary>
        /// <param name="value">The effectiveness multiplier to check</param>
        /// <returns>True if the value represents normal effectiveness</returns>
        bool normal(float value);

        /// <summary>
        /// Checks if the given effectiveness value represents super effective damage.
        /// </summary>
        /// <param name="value">The effectiveness multiplier to check</param>
        /// <returns>True if the value represents super effective damage</returns>
        bool super_effective(float value);

        /// <summary>
        /// Checks if an attack type is ineffective against defending types.
        /// </summary>
        /// <param name="attack_type">The attacking type</param>
        /// <param name="defend_types">The defending types</param>
        /// <returns>True if the attack is ineffective</returns>
        bool ineffective_type(IType attack_type, IList<IType> defend_types);

        /// <summary>
        /// Checks if an attack type is not very effective against defending types.
        /// </summary>
        /// <param name="attack_type">The attacking type</param>
        /// <param name="defend_types">The defending types</param>
        /// <returns>True if the attack is not very effective</returns>
        bool not_very_effective_type(IType attack_type, IList<IType> defend_types);

        /// <summary>
        /// Checks if defending types resist an attack type.
        /// </summary>
        /// <param name="attack_type">The attacking type</param>
        /// <param name="defend_types">The defending types</param>
        /// <returns>True if the defending types resist the attack</returns>
        bool resistant_type(IType attack_type, IList<IType> defend_types);

        /// <summary>
        /// Checks if an attack type has normal effectiveness against defending types.
        /// </summary>
        /// <param name="attack_type">The attacking type</param>
        /// <param name="defend_types">The defending types</param>
        /// <returns>True if the attack has normal effectiveness</returns>
        bool normal_type(IType attack_type, IList<IType> defend_types);

        /// <summary>
        /// Checks if an attack type is super effective against defending types.
        /// </summary>
        /// <param name="attack_type">The attacking type</param>
        /// <param name="defend_types">The defending types</param>
        /// <returns>True if the attack is super effective</returns>
        bool super_effective_type(IType attack_type, IList<IType> defend_types);

        /// <summary>
        /// Gets the type effectiveness of an attack type against a defend type.
        /// </summary>
        /// <param name="attack_type">The attacking type</param>
        /// <param name="defend_type">The defending type</param>
        /// <returns>The effectiveness multiplier</returns>
        float get_type_effectiveness(IType attack_type, IType defend_type);

        /// <summary>
        /// Calculates the overall effectiveness of an attack type against multiple defending types.
        /// </summary>
        /// <param name="attack_type">The attacking type</param>
        /// <param name="defend_types">The defending types</param>
        /// <returns>The combined effectiveness multiplier</returns>
        float calculate(IType attack_type, IList<IType> defend_types);
    }
}