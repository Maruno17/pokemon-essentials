using System;
using System.Collections.Generic;

namespace PokemonEssentials.Data
{
    /// <summary>
    /// Interface for Item data, representing Pokemon items and their properties.
    /// Provides read-only access to item information including usage, pricing, flags, and categorization.
    /// </summary>
    public interface IItem
    {
        /// <summary>
        /// Gets the unique identifier for this item.
        /// </summary>
        int id { get; }

        /// <summary>
        /// Gets the real name of the item as stored in the data files.
        /// </summary>
        string real_name { get; }

        /// <summary>
        /// Gets the real plural name of the item as stored in the data files.
        /// </summary>
        string real_name_plural { get; }

        /// <summary>
        /// Gets the real portion name of the item as stored in the data files.
        /// Used for items that can be consumed in portions.
        /// </summary>
        string real_portion_name { get; }

        /// <summary>
        /// Gets the real plural portion name of the item as stored in the data files.
        /// </summary>
        string real_portion_name_plural { get; }

        /// <summary>
        /// Gets the pocket in the Bag where this item is stored.
        /// </summary>
        int pocket { get; }

        /// <summary>
        /// Gets the purchase price of this item.
        /// </summary>
        int price { get; }

        /// <summary>
        /// Gets the sell price of this item.
        /// </summary>
        int sell_price { get; }

        /// <summary>
        /// Gets the Battle Points (BP) price of this item.
        /// </summary>
        int bp_price { get; }

        /// <summary>
        /// Gets how this item can be used outside of battle.
        /// 0 = Can't use, 1 = On Pokemon, 2 = Direct, 3 = TM, 4 = HM, 5 = TR
        /// </summary>
        int field_use { get; }

        /// <summary>
        /// Gets how this item can be used within a battle.
        /// 0 = Can't use, 1 = On Pokemon, 2 = On Move, 3 = On Battler, 4 = On Foe, 5 = Direct
        /// </summary>
        int battle_use { get; }

        /// <summary>
        /// Gets the collection of flags associated with this item.
        /// Flags define special properties and categorization.
        /// </summary>
        IList<string> flags { get; }

        /// <summary>
        /// Gets whether this item is consumed after use.
        /// </summary>
        bool consumable { get; }

		/// <summary>
		/// Gets whether the Bag shows how many of this item are in there.
		/// </summary>
		/// <remarks>
		/// Checks if the quantity of this item should be shown in the Bag.
		/// </remarks>
		bool show_quantity { get; }

        /// <summary>
        /// Gets the move taught by this HM, TM or TR.
        /// </summary>
        IMove move { get; }

        /// <summary>
        /// Gets the real description of the item as stored in the data files.
        /// </summary>
        string real_description { get; }

        /// <summary>
        /// Gets the PBS file suffix for this item entry.
        /// Used for organizing and loading related data files.
        /// </summary>
        string pbs_file_suffix { get; }

        /// <summary>
        /// Gets the translated name of this item for display to players.
        /// This method retrieves the localized name from the message system.
        /// </summary>
        /// <returns>The translated item name</returns>
        string name { get; }

        /// <summary>
        /// Gets the translated plural name of this item for display to players.
        /// </summary>
        /// <returns>The translated plural item name</returns>
        string name_plural { get; }

        /// <summary>
        /// Gets the translated portion name of this item for display to players.
        /// </summary>
        /// <returns>The translated portion name</returns>
        string portion_name { get; }

        /// <summary>
        /// Gets the translated plural portion name of this item for display to players.
        /// </summary>
        /// <returns>The translated plural portion name</returns>
        string portion_name_plural { get; }

        /// <summary>
        /// Gets the translated description of this item for display to players.
        /// This method retrieves the localized description from the message system.
        /// </summary>
        /// <returns>The translated item description</returns>
        string description { get; }

        /// <summary>
        /// Checks if this item has a specific flag.
        /// </summary>
        /// <param name="flag">The flag to check for (case-insensitive)</param>
        /// <returns>True if the item has the specified flag, false otherwise</returns>
        bool has_flag(string flag);

        /// <summary>
        /// Checks if this item is a TM (Technical Machine).
        /// </summary>
        /// <returns>True if this is a TM, false otherwise</returns>
        bool is_TM();

        /// <summary>
        /// Checks if this item is an HM (Hidden Machine).
        /// </summary>
        /// <returns>True if this is an HM, false otherwise</returns>
        bool is_HM();

        /// <summary>
        /// Checks if this item is a TR (Technical Record).
        /// </summary>
        /// <returns>True if this is a TR, false otherwise</returns>
        bool is_TR();

        /// <summary>
        /// Checks if this item is any type of machine (TM, HM, or TR).
        /// </summary>
        /// <returns>True if this is a machine, false otherwise</returns>
        bool is_machine();

        /// <summary>
        /// Checks if this item is mail.
        /// </summary>
        /// <returns>True if this is mail, false otherwise</returns>
        bool is_mail();

        /// <summary>
        /// Checks if this item is icon mail.
        /// </summary>
        /// <returns>True if this is icon mail, false otherwise</returns>
        bool is_icon_mail();

        /// <summary>
        /// Checks if this item is a Poke Ball.
        /// </summary>
        /// <returns>True if this is a Poke Ball, false otherwise</returns>
        bool is_poke_ball();

        /// <summary>
        /// Checks if this item is a Snag Ball.
        /// </summary>
        /// <returns>True if this is a Snag Ball, false otherwise</returns>
        bool is_snag_ball();

        /// <summary>
        /// Checks if this item is a berry.
        /// </summary>
        /// <returns>True if this is a berry, false otherwise</returns>
        bool is_berry();

        /// <summary>
        /// Checks if this item is a key item.
        /// </summary>
        /// <returns>True if this is a key item, false otherwise</returns>
        bool is_key_item();

        /// <summary>
        /// Checks if this item is an evolution stone.
        /// </summary>
        /// <returns>True if this is an evolution stone, false otherwise</returns>
        bool is_evolution_stone();

        /// <summary>
        /// Checks if this item is a fossil.
        /// </summary>
        /// <returns>True if this is a fossil, false otherwise</returns>
        bool is_fossil();

        /// <summary>
        /// Checks if this item is an apricorn.
        /// </summary>
        /// <returns>True if this is an apricorn, false otherwise</returns>
        bool is_apricorn();

        /// <summary>
        /// Checks if this item is a type gem.
        /// </summary>
        /// <returns>True if this is a type gem, false otherwise</returns>
        bool is_gem();

        /// <summary>
        /// Checks if this item is mulch.
        /// </summary>
        /// <returns>True if this is mulch, false otherwise</returns>
        bool is_mulch();

        /// <summary>
        /// Checks if this item is a Mega Stone.
        /// Does NOT include Red Orb/Blue Orb.
        /// </summary>
        /// <returns>True if this is a Mega Stone, false otherwise</returns>
        bool is_mega_stone();

        /// <summary>
        /// Checks if this item is a scent.
        /// </summary>
        /// <returns>True if this is a scent, false otherwise</returns>
        bool is_scent();

        /// <summary>
        /// Checks if this item is important (key item, HM, or TM).
        /// Important items cannot be thrown away or sold.
        /// </summary>
        /// <returns>True if this is an important item, false otherwise</returns>
        bool is_important();

        /// <summary>
        /// Checks if this item can be held by a Pokemon.
        /// </summary>
        /// <returns>True if this item can be held, false otherwise</returns>
        bool can_hold();

        /// <summary>
        /// Checks if this item is consumed after use.
        /// </summary>
        /// <returns>True if the item is consumed after use, false otherwise</returns>
        bool consumed_after_use();

        /// <summary>
        /// Checks if the quantity of this item should be shown in the Bag.
        /// </summary>
        /// <returns>True if quantity should be shown, false otherwise</returns>
        //bool show_quantity();

        /// <summary>
        /// Checks if this item cannot be lost by a specific Pokemon species with a specific ability.
        /// Some items are essential for certain Pokemon forms.
        /// </summary>
        /// <param name="species">The Pokemon species</param>
        /// <param name="ability">The Pokemon's ability</param>
        /// <returns>True if the item is unlosable for this Pokemon, false otherwise</returns>
        bool unlosable(ISpecies species, IAbility ability);

        /// <summary>
        /// Gets a property value for PBS data export.
        /// </summary>
        /// <param name="key">The property key to retrieve</param>
        /// <returns>The property value, or null if the value should be omitted</returns>
        object get_property_for_PBS(string key);

        /// <summary>
        /// Gets the icon filename for this item.
        /// </summary>
        /// <param name="item">The item to get the icon for</param>
        /// <returns>The path to the item's icon file</returns>
        string icon_filename(IItem item);

        /// <summary>
        /// Gets the held icon filename for this item when held by a Pokemon.
        /// </summary>
        /// <param name="item">The item to get the held icon for</param>
        /// <returns>The path to the item's held icon file, or null if none</returns>
        string held_icon_filename(IItem item);

        /// <summary>
        /// Gets the mail filename for this item if it's mail.
        /// </summary>
        /// <param name="item">The item to get the mail filename for</param>
        /// <returns>The path to the mail file, or null if not mail or file doesn't exist</returns>
        string mail_filename(IItem item);
    }
}