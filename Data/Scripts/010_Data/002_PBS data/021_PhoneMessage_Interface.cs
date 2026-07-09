using System;
using System.Collections.Generic;

namespace PokemonEssentials.Data
{
    /// <summary>
    /// Interface for PhoneMessage data, representing phone call messages from trainers.
    /// Provides read-only access to phone message content including greetings, body text, and battle requests.
    /// </summary>
    public interface IPhoneMessage
    {
        /// <summary>
        /// Gets the unique identifier for this phone message set.
        /// </summary>
        string id { get; }

        /// <summary>
        /// Gets the trainer type for this phone message.
        /// </summary>
        ITrainerType trainer_type { get; }

        /// <summary>
        /// Gets the real name of the trainer as stored in the data files.
        /// </summary>
        string real_name { get; }

        /// <summary>
        /// Gets the version number for this phone message set.
        /// Allows multiple message sets for the same trainer.
        /// </summary>
        int version { get; }

        /// <summary>
        /// Gets the general introduction text.
        /// Used when time-specific intros are not available.
        /// </summary>
        string intro { get; }

        /// <summary>
        /// Gets the morning-specific introduction text.
        /// Used during morning hours.
        /// </summary>
        string intro_morning { get; }

        /// <summary>
        /// Gets the afternoon-specific introduction text.
        /// Used during afternoon hours.
        /// </summary>
        string intro_afternoon { get; }

        /// <summary>
        /// Gets the evening-specific introduction text.
        /// Used during evening hours.
        /// </summary>
        string intro_evening { get; }

        /// <summary>
        /// Gets the main body text of the phone message.
        /// Used when specific body variants are not available.
        /// </summary>
        string body { get; }

        /// <summary>
        /// Gets the first variant of body text.
        /// Provides variety in phone conversations.
        /// </summary>
        string body1 { get; }

        /// <summary>
        /// Gets the second variant of body text.
        /// Provides additional variety in phone conversations.
        /// </summary>
        string body2 { get; }

        /// <summary>
        /// Gets the battle request text.
        /// Used when the trainer wants to challenge the player to a battle.
        /// </summary>
        string battle_request { get; }

        /// <summary>
        /// Gets the battle reminder text.
        /// Used to remind the player about an upcoming or arranged battle.
        /// </summary>
        string battle_remind { get; }

        /// <summary>
        /// Gets the ending text for the phone call.
        /// Used to conclude the conversation.
        /// </summary>
        string end { get; }

        /// <summary>
        /// Gets the PBS file suffix for this phone message entry.
        /// Used for organizing and loading related data files.
        /// </summary>
        string pbs_file_suffix { get; }

        /// <summary>
        /// Gets the translated name of the trainer for display to players.
        /// This method retrieves the localized name from the message system.
        /// </summary>
        /// <returns>The translated trainer name</returns>
        string name { get; }

        /// <summary>
        /// Gets the appropriate introduction text based on the current time of day.
        /// </summary>
        /// <returns>The time-appropriate introduction text</returns>
        //string get_intro();

        /// <summary>
        /// Gets a random body text variant.
        /// </summary>
        /// <returns>A randomly selected body text</returns>
        //string get_body();

        /// <summary>
        /// Gets the battle-related text based on context.
        /// </summary>
        /// <param name="is_request">Whether this is a battle request or reminder</param>
        /// <returns>The appropriate battle text</returns>
        string get_battle_text(bool is_request = true);
    }
}