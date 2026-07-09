using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface representing a phone system for managing trainer contacts and phone calls.
    /// Manages contact lists, rematch functionality, and phone call dialogue systems.
    /// </summary>
    public interface IPhone
    {
        /// <summary>
        /// List of phone contacts, both trainers and non-trainers.
        /// </summary>
        IList<IPhoneContact> contacts { get; set; }

        /// <summary>
        /// Current rematch variant level for trainer battles.
        /// Original battle is 0, first rematch is 1, etc.
        /// </summary>
        int rematch_variant { get; set; }

        /// <summary>
        /// Whether rematches are enabled in the phone system.
        /// </summary>
        bool rematches_enabled { get; set; }

        /// <summary>
        /// Time in seconds until the next incoming phone call.
        /// </summary>
        double time_to_next_call { get; set; }

        /// <summary>
        /// Last time the ready trainers were refreshed (in seconds).
        /// </summary>
        int last_refresh_time { get; set; }

        /// <summary>
        /// Initializes the phone system with default values.
        /// </summary>
        IPhone initialize();

        /// <summary>
        /// Returns a visible contact matching the specified criteria.
        /// </summary>
        /// <param name="trainer">True for trainer contacts, false for non-trainer contacts</param>
        /// <param name="args">For trainers: trainer_type, name, start_version. For non-trainers: name</param>
        /// <returns>The matching contact or null if not found</returns>
        IPhoneContact get(bool trainer, params object[] args);

        /// <summary>
        /// Gets the version number of a trainer contact.
        /// </summary>
        /// <param name="trainer_type">The trainer type identifier</param>
        /// <param name="name">The trainer's name</param>
        /// <param name="start_version">The starting version (default 0)</param>
        /// <returns>The trainer's current version or 0 if not found</returns>
        int get_version(object trainer_type, string name, int start_version = 0);

        /// <summary>
        /// Checks if a contact can be added to the phone.
        /// </summary>
        /// <param name="args">Contact parameters to check</param>
        /// <returns>True if the contact can be added</returns>
        bool can_add(params object[] args);

        /// <summary>
        /// Adds a new contact to the phone.
        /// </summary>
        /// <param name="args">Contact parameters for creation</param>
        /// <returns>True if the contact was successfully added</returns>
        bool add(params object[] args);

        /// <summary>
        /// Rearranges the contact list to put visible contacts first.
        /// </summary>
        /// <remarks>
        /// Rearranges the list of phone contacts to put all visible contacts first,
        /// followed by all invisible contacts.
        /// </remarks>
        void sort_contacts();

        /// <summary>
        /// Refreshes ready trainers for rematches. Checks once every second.
        /// </summary>
        void refresh_ready_trainers();

        /// <summary>
        /// Resets a trainer contact after winning a battle against them.
        /// </summary>
        /// <param name="trainer_type">The trainer type identifier</param>
        /// <param name="name">The trainer's name</param>
        /// <param name="start_version">The starting version (default 0)</param>
        void reset_after_win(object trainer_type, string name, int start_version = 0);

        /// <summary>
        /// Static getter for the global rematch variant.
        /// </summary>
        /// <returns>Current rematch variant</returns>
        //static int rematch_variant_get();

        /// <summary>
        /// Static setter for the global rematch variant.
        /// </summary>
        /// <param name="value">New rematch variant value</param>
        //static void rematch_variant_set(int value);

        /// <summary>
        /// Static getter for whether rematches are enabled.
        /// </summary>
        /// <returns>True if rematches are enabled</returns>
        //static bool rematches_enabled_get();

        /// <summary>
        /// Static setter for rematch enabled status.
        /// </summary>
        /// <param name="value">New rematch enabled status</param>
        //static void rematches_enabled_set(bool value);

        /// <summary>
        /// Gets a trainer contact using static access.
        /// </summary>
        /// <param name="args">Trainer parameters</param>
        /// <returns>The matching trainer contact</returns>
        //static IPhoneContact get_trainer(params object[] args);

        /// <summary>
        /// Checks if a contact can be added using static access.
        /// </summary>
        /// <param name="args">Contact parameters</param>
        /// <returns>True if contact can be added</returns>
        //static bool can_add_static(params object[] args);

        /// <summary>
        /// Adds a contact using static access with message display.
        /// </summary>
        /// <param name="args">Contact parameters</param>
        /// <returns>True if contact was added successfully</returns>
        //static bool add_static(params object[] args);

        /// <summary>
        /// Adds a contact silently without displaying a message.
        /// </summary>
        /// <param name="args">Contact parameters</param>
        /// <returns>True if contact was added successfully</returns>
        //static bool add_silent(params object[] args);

        /// <summary>
        /// Gets the variant number for a trainer.
        /// </summary>
        /// <param name="trainer_type">The trainer type identifier</param>
        /// <param name="name">The trainer's name</param>
        /// <param name="start_version">The starting version (default 0)</param>
        /// <returns>The trainer's variant number</returns>
        //static int variant(object trainer_type, string name, int start_version = 0);

        /// <summary>
        /// Increments the version of a trainer contact.
        /// </summary>
        /// <param name="trainer_type">The trainer type identifier</param>
        /// <param name="name">The trainer's name</param>
        /// <param name="start_version">The starting version (default 0)</param>
        //static void increment_version(object trainer_type, string name, int start_version = 0);

        /// <summary>
        /// Initiates a battle with a trainer contact.
        /// </summary>
        /// <param name="trainer_type">The trainer type identifier</param>
        /// <param name="name">The trainer's name</param>
        /// <param name="start_version">The starting version (default 0)</param>
        /// <returns>True if the battle was started successfully</returns>
        //static bool battle(object trainer_type, string name, int start_version = 0);

        /// <summary>
        /// Resets a trainer contact after winning using static access.
        /// </summary>
        /// <param name="trainer_type">The trainer type identifier</param>
        /// <param name="name">The trainer's name</param>
        /// <param name="start_version">The starting version (default 0)</param>
        //static void reset_after_win_static(object trainer_type, string name, int start_version = 0);
    }

    /// <summary>
    /// Interface representing a single phone contact, either trainer or non-trainer.
    /// </summary>
    public interface IPhoneContact
    {
        /// <summary>
        /// The map ID where this contact can be found.
        /// </summary>
        int map_id { get; set; }

        /// <summary>
        /// The event ID for this contact on their map.
        /// </summary>
        int event_id { get; set; }

        /// <summary>
        /// The name of this contact.
        /// </summary>
        string name { get; set; }

        /// <summary>
        /// The trainer type identifier (for trainer contacts only).
        /// </summary>
        int trainer_type { get; set; }

        /// <summary>
        /// The starting version number for this trainer.
        /// </summary>
        int start_version { get; set; }

        /// <summary>
        /// The total number of versions (battle variants) for this trainer.
        /// </summary>
        int versions_count { get; set; }

        /// <summary>
        /// The last trainer version that was beaten.
        /// </summary>
        int version { get; set; }

        /// <summary>
        /// Time remaining until this trainer is ready for a rematch.
        /// </summary>
        int time_to_ready { get; set; }

        /// <summary>
        /// Rematch flag: 0=counting down, 1=ready for rematch, 2=ready and told player.
        /// </summary>
        int rematch_flag { get; set; }

        /// <summary>
        /// Common event ID to call when contacting this person.
        /// </summary>
        int common_event_id { get; set; }

        /// <summary>
        /// Whether this contact is visible in the phone list.
        /// </summary>
        bool visible { get; set; }

        /// <summary>
        /// Initializes a new phone contact.
        /// </summary>
        /// <param name="trainer">True if this is a trainer contact</param>
        /// <param name="args">Contact initialization parameters</param>
        IPhoneContact initialize(bool trainer, params object[] args);

        /// <summary>
        /// Checks if this is a trainer contact.
        /// </summary>
        /// <returns>True if this is a trainer contact</returns>
        bool trainer();

        /// <summary>
        /// Checks if this contact is visible in the phone list.
        /// </summary>
        /// <returns>True if the contact is visible</returns>
        //bool visible();

        /// <summary>
        /// Checks if this contact can be hidden from the phone list.
        /// </summary>
        /// <returns>True if the contact can be hidden</returns>
        bool can_hide();

        /// <summary>
        /// Checks if this contact uses a common event for calls.
        /// </summary>
        /// <returns>True if the contact uses a common event</returns>
        bool common_event_call();

        /// <summary>
        /// Checks if this trainer can be rematched.
        /// </summary>
        /// <returns>True if the trainer is ready for rematch</returns>
        bool can_rematch();

        /// <summary>
        /// Gets the display name for this contact.
        /// </summary>
        /// <returns>The formatted display name</returns>
        string display_name();

        /// <summary>
        /// Gets the variant number for this trainer (0 for original, 1 for first rematch, etc.).
        /// </summary>
        /// <returns>The variant number</returns>
        int variant();

        /// <summary>
        /// Gets the version of this trainer to be battled next.
        /// </summary>
        /// <returns>The next version number</returns>
        int next_version();

        /// <summary>
        /// Increments the version of this trainer contact.
        /// </summary>
        void increment_version();

        /// <summary>
        /// Sets the trainer event to be ready for rematch.
        /// </summary>
        void set_trainer_event_ready_for_rematch();
    }

    /// <summary>
    /// Interface for phone call functionality including incoming and outgoing calls.
    /// </summary>
    public interface IPhoneCall
    {
        /// <summary>
        /// Checks if a phone call can be made from the current location.
        /// </summary>
        /// <returns>True if phone calls are possible</returns>
        bool can_make();

        /// <summary>
        /// Checks if a specific contact can be called.
        /// </summary>
        /// <param name="contact">The contact to check</param>
        /// <returns>True if the contact can be called</returns>
        bool can_call_contact(IPhoneContact contact);

        /// <summary>
        /// Gets a random trainer contact for an incoming call.
        /// </summary>
        /// <remarks>
        /// Get a random trainer contact from the region the player is currently in,
        /// but is not in the same map as the player.
        /// </remarks>
        /// <returns>A random valid trainer contact or null</returns>
        IPhoneContact get_random_trainer_for_incoming_call();

        /// <summary>
        /// Generates an incoming phone call.
        /// </summary>
        void make_incoming();

        /// <summary>
        /// Makes an outgoing phone call to a contact.
        /// </summary>
        /// <remarks>
        /// Phone::Contact
        /// Trainer type, name[, start_version]
        /// Name (for non-trainers)
        /// </remarks>
        /// <param name="args">Contact parameters or contact object</param>
        void make_outgoing(params object[] args);

        /// <summary>
        /// Displays the start message for a phone call.
        /// </summary>
        /// <param name="contact">The contact being called (optional)</param>
        void start_message(IPhoneContact contact = null);

        /// <summary>
        /// Plays the phone call dialogue with a contact.
        /// </summary>
        /// <param name="dialogue">The dialogue text to display</param>
        /// <param name="contact">The contact being called</param>
        void play(string dialogue, IPhoneContact contact);

        /// <summary>
        /// Displays the end message for a phone call.
        /// </summary>
        /// <param name="contact">The contact that was called (optional)</param>
        void end_message(IPhoneContact contact = null);

        /// <summary>
        /// Generates dialogue text for a trainer contact.
        /// </summary>
        /// <param name="contact">The trainer contact</param>
        /// <returns>The generated dialogue string</returns>
        string generate_trainer_dialogue(IPhoneContact contact);

        /// <summary>
        /// Gets a random Pokémon species name from the contact's trainer data.
        /// </summary>
        /// <param name="contact">The trainer contact</param>
        /// <returns>A random Pokémon species name from the trainer's team</returns>
        string get_random_contact_pokemon_species(IPhoneContact contact);

        /// <summary>
        /// Gets a random encounter species from the contact's map.
        /// </summary>
        /// <param name="contact">The trainer contact</param>
        /// <returns>A random wild Pokémon species name from the contact's area</returns>
        string get_random_encounter_species(IPhoneContact contact);

        /// <summary>
        /// Gets the map name where the contact is located.
        /// </summary>
        /// <param name="contact">The contact</param>
        /// <returns>The name of the contact's map</returns>
        string get_map_name(IPhoneContact contact);
    }

    public interface IMainItemPhone : IMain
    {
        /// <summary>
        /// </summary>
        /// <example>
        /// <code>
        /// EventHandlers.add(:on_frame_update, :phone_call_counter,
        ///   proc {
        ///     next if !$player&.has_pokegear
        ///     # Don't count down various phone times if other things are happening
        ///     next if $game_temp.in_menu || $game_temp.in_battle || $game_temp.message_window_showing
        ///     next if $game_player.move_route_forcing || pbMapInterpreterRunning?
        ///     # Count down time to next can-battle for each trainer contact
        ///     $PokemonGlobal.phone.refresh_ready_trainers
        ///     # Count down time to next phone call
        ///     if $PokemonGlobal.phone.time_to_next_call <= 0
        ///       $PokemonGlobal.phone.time_to_next_call = rand(20...40) * 60.0   # 20-40 minutes
        ///     end
        ///     $PokemonGlobal.phone.time_to_next_call -= Graphics.delta
        ///     next if $PokemonGlobal.phone.time_to_next_call > 0
        ///     # Time for a random phone call; generate one
        ///     Phone::Call.make_incoming
        ///   }
        /// )
        /// </code>
        /// </example>
        /// <seealso cref="IEvents.OnFrameUpdate"/>
        void OnFrameUpdateTrigger_phone_call_counter();
    }
}