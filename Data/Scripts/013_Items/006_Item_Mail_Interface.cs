using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Interface representing mail that Pokémon can hold.
	/// Contains message text, sender information, and up to three Pokémon icon data.
	/// </summary>
	public interface IMail
	{
		/// <summary>
		/// The item that represents this mail.
		/// </summary>
		int item { get; set; }

		/// <summary>
		/// The message text content of the mail.
		/// </summary>
		string message { get; set; }

		/// <summary>
		/// The name of the person who sent this mail.
		/// </summary>
		string sender { get; set; }

		/// <summary>
		/// First Pokémon data for icon display: [species, gender, shininess, form, shadowness, is_egg].
		/// </summary>
		IMailPokemon poke1 { get; set; }

		/// <summary>
		/// Second Pokémon data for icon display: [species, gender, shininess, form, shadowness, is_egg].
		/// </summary>
		IMailPokemon poke2 { get; set; }

		/// <summary>
		/// Third Pokémon data for icon display: [species, gender, shininess, form, shadowness, is_egg].
		/// </summary>
		IMailPokemon poke3 { get; set; }

		/// <summary>
		/// Initializes a new mail object.
		/// </summary>
		/// <param name="item">The mail item identifier</param>
		/// <param name="message">The message text</param>
		/// <param name="sender">The sender's name</param>
		/// <param name="poke1">First Pokémon data (optional)</param>
		/// <param name="poke2">Second Pokémon data (optional)</param>
		/// <param name="poke3">Third Pokémon data (optional)</param>
		void initialize(int item, string message, string sender, IMailPokemon poke1 = null, IMailPokemon poke2 = null, IMailPokemon poke3 = null);
	}

	/// <summary>
	/// Interface for mail management functions including mailbox operations and mail display.
	/// </summary>
	public interface IMainItemMailManager : IMain
	{
		/// <summary>
		/// Moves mail from a Pokémon to the mailbox.
		/// </summary>
		/// <param name="pokemon">The Pokémon holding the mail</param>
		/// <returns>True if the mail was successfully moved to the mailbox</returns>
		bool MoveToMailbox(IPokemon pokemon);

		/// <summary>
		/// Stores new mail on a Pokémon.
		/// </summary>
		/// <param name="pkmn">The Pokémon to give the mail to</param>
		/// <param name="item">The mail item</param>
		/// <param name="message">The message text</param>
		/// <param name="poke1">First Pokémon data (optional)</param>
		/// <param name="poke2">Second Pokémon data (optional)</param>
		/// <param name="poke3">Third Pokémon data (optional)</param>
		void StoreMail(IPokemon pkmn, int item, string message, IMailPokemon poke1 = null, IMailPokemon poke2 = null, IMailPokemon poke3 = null);

		/// <summary>
		/// Displays mail in a graphical interface.
		/// </summary>
		/// <param name="mail">The mail to display</param>
		/// <param name="bearer">Optional bearer information</param>
		void DisplayMail(IMail mail, string bearer = null);

		/// <summary>
		/// Allows the player to write mail for a Pokémon.
		/// </summary>
		/// <param name="item">The mail item being used</param>
		/// <param name="pkmn">The Pokémon that will hold the mail</param>
		/// <param name="pkmnid">The index of the Pokémon in the party</param>
		/// <param name="scene">The scene object for updates</param>
		/// <returns>True if mail was successfully written and stored</returns>
		bool WriteMail(object item, IPokemon pkmn, int pkmnid, object scene);
	}

	public interface IMailPokemon
	{
		int species { get; set; }
		int gender { get; set; }
		int shininess { get; set; }
		int form { get; set; }
		int shadowness { get; set; }
		bool is_egg { get; set; }
	}
	/*
	/// <summary>
	/// Interface for mail-related utility functions and helper methods.
	/// </summary>
	public interface IMailUtilities
	{
		/// <summary>
		/// Checks if a given item is a mail item.
		/// </summary>
		/// <param name="item">The item to check</param>
		/// <returns>True if the item is a mail item</returns>
		bool is_mail_item(object item);

		/// <summary>
		/// Gets the filename for a mail item's background graphic.
		/// </summary>
		/// <param name="item">The mail item</param>
		/// <returns>The filename for the mail's graphic</returns>
		string get_mail_filename(object item);

		/// <summary>
		/// Checks if a mail item displays Pokémon icons.
		/// </summary>
		/// <param name="item">The mail item</param>
		/// <returns>True if the mail displays Pokémon icons</returns>
		bool is_icon_mail(object item);

		/// <summary>
		/// Determines if a background is dark for text color selection.
		/// </summary>
		/// <param name="bitmap">The background bitmap</param>
		/// <param name="rect">The area to check</param>
		/// <returns>True if the background is dark</returns>
		bool is_dark_background(object bitmap, object rect);

		/// <summary>
		/// Formats Pokémon data for mail icon display.
		/// </summary>
		/// <param name="pokemon">The Pokémon to get data from</param>
		/// <returns>Array containing species, gender, shiny, form, shadow, and egg status</returns>
		IMailPokemon format_pokemon_data(IPokemon pokemon);

		/// <summary>
		/// Validates mail message length and content.
		/// </summary>
		/// <param name="message">The message to validate</param>
		/// <param name="maxLength">Maximum allowed length</param>
		/// <returns>True if the message is valid</returns>
		bool validate_mail_message(string message, int maxLength = 250);
	}

	/// <summary>
	/// Interface for mail display and rendering functionality.
	/// </summary>
	public interface IMailDisplay
	{
		/// <summary>
		/// Renders the mail background.
		/// </summary>
		/// <param name="mail">The mail to render</param>
		/// <param name="viewport">The viewport to render in</param>
		void render_mail_background(IMail mail, IViewport viewport);

		/// <summary>
		/// Renders Pokémon icons on the mail.
		/// </summary>
		/// <param name="mail">The mail containing Pokémon data</param>
		/// <param name="viewport">The viewport to render in</param>
		void render_pokemon_icons(IMail mail, IViewport viewport);

		/// <summary>
		/// Renders the mail message text.
		/// </summary>
		/// <param name="mail">The mail containing the message</param>
		/// <param name="overlay">The overlay bitmap to draw on</param>
		void render_mail_message(IMail mail, object overlay);

		/// <summary>
		/// Renders the sender name on the mail.
		/// </summary>
		/// <param name="mail">The mail containing sender information</param>
		/// <param name="overlay">The overlay bitmap to draw on</param>
		void render_sender_name(IMail mail, object overlay);

		/// <summary>
		/// Handles input for mail display.
		/// </summary>
		/// <returns>True if the display should close</returns>
		bool handle_mail_input();

		/// <summary>
		/// Cleans up mail display resources.
		/// </summary>
		/// <param name="sprites">The sprite hash to dispose</param>
		/// <param name="viewport">The viewport to dispose</param>
		void cleanup_mail_display(object sprites, IViewport viewport);
	}
	*/
}