using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Global methods for internationalization and message handling (IMain interface).
    /// </summary>
    public interface IMainIntlMessages : IMain
    {
        /// <summary>
        /// Gets a message by type and ID.
        /// </summary>
        string pbGetMessage(int type, object id);

        /// <summary>
        /// Gets a message from a hash by type and ID.
        /// </summary>
        string pbGetMessageFromHash(int type, string id);

        /// <summary>
        /// Formats a message with the provided arguments.
        /// </summary>
        string _INTL(string format, params object[] args);

        /// <summary>
        /// Formats a message with printf-style formatting.
        /// </summary>
        string _ISPRINTF(string format, params object[] args);

        /// <summary>
        /// Formats a map-specific message with the provided arguments.
        /// </summary>
        string _I(string str, params object[] args);

        /// <summary>
        /// Formats a map-specific message with the provided arguments.
        /// </summary>
        string _MAPINTL(int mapid, params object[] args);

        /// <summary>
        /// Formats a map-specific message with printf-style formatting.
        /// </summary>
        string _MAPISPRINTF(int mapid, params object[] args);
    }

    /// <summary>
    /// Provides utility functions for translating and managing game text (Translator module).
    /// </summary>
    public interface ITranslator
    {
        /// <summary>
        /// Gathers translatable text from scripts and event data.
        /// </summary>
        void gather_script_and_event_texts();

        /// <summary>
        /// Finds translatable text from scripts.
        /// </summary>
        void find_translatable_text_from_RGSS_script(IList<string> items, string script);

        /// <summary>
        /// Finds translatable text from event scripts.
        /// </summary>
        void find_translatable_text_from_event_script(IList<string> items, string script);

        /// <summary>
        /// Normalizes text values for storage.
        /// </summary>
        string normalize_value(string value);

        /// <summary>
        /// Denormalizes stored text values for display.
        /// </summary>
        string denormalize_value(string value);

        /// <summary>
        /// Extracts text for translation.
        /// </summary>
        void extract_text(string language_name = "default", bool core_text = false, bool separate_map_files = false);

        /// <summary>
        /// Writes section texts to a file.
        /// </summary>
        void write_section_texts_to_file(object f, string section_name, object language_msgs, object original_msgs = null);

        /// <summary>
        /// Compiles text from translation files.
        /// </summary>
        void compile_text(string dir_name, string dat_filename);

        /// <summary>
        /// Compiles text from a file.
        /// </summary>
        void compile_text_from_file(string text_file, object all_text);
    }

    /// <summary>
    /// Manages game text translations and message handling (Translation class).
    /// </summary>
    public interface ITranslation
    {
        /// <summary>
        /// Gets the default core messages.
        /// </summary>
        object default_core_messages { get; }

        /// <summary>
        /// Gets the default game messages.
        /// </summary>
        object default_game_messages { get; }

        /// <summary>
        /// Loads message files from the specified path.
        /// </summary>
        void load_message_files(string filename);

        /// <summary>
        /// Loads the default messages.
        /// </summary>
        void load_default_messages();

        /// <summary>
        /// Saves the default messages.
        /// </summary>
        void save_default_messages();

        /// <summary>
        /// Sets messages for a specific type.
        /// </summary>
        void setMessages(int type, IList<string> array);

        /// <summary>
        /// Adds messages to a specific type.
        /// </summary>
        void addMessages(int type, IList<string> array);

        /// <summary>
        /// Sets messages as a hash for a specific type.
        /// </summary>
        void setMessagesAsHash(int type, IList<string> array);

        /// <summary>
        /// Adds messages as a hash for a specific type.
        /// </summary>
        void addMessagesAsHash(int type, IList<string> array);

        /// <summary>
        /// Sets map-specific messages as a hash.
        /// </summary>
        void setMapMessagesAsHash(int map_id, IList<string> array);

        /// <summary>
        /// Adds map messages as a hash for a specific map ID.
        /// </summary>
        void addMapMessagesAsHash(int map_id, IList<string> array);

        /// <summary>
        /// Gets a message by type and ID.
        /// </summary>
        string get(int type, object id);

        /// <summary>
        /// Gets a message from a hash by type and text.
        /// </summary>
        string getFromHash(int type, string text);

        /// <summary>
        /// Gets a map-specific message from a hash.
        /// </summary>
        string getFromMapHash(int map_id, string text);
    }

    /// <summary>
    /// Provides message type constants and helper methods for internationalization (MessageTypes module).
    /// </summary>
    public interface IMessageTypes
    {
        int EVENT_TEXTS { get; }
        int SPECIES_NAMES { get; }
        int SPECIES_CATEGORIES { get; }
        int POKEDEX_ENTRIES { get; }
        int SPECIES_FORM_NAMES { get; }
        int MOVE_NAMES { get; }
        int MOVE_DESCRIPTIONS { get; }
        int ITEM_NAMES { get; }
        int ITEM_NAME_PLURALS { get; }
        int ITEM_DESCRIPTIONS { get; }
        int ABILITY_NAMES { get; }
        int ABILITY_DESCRIPTIONS { get; }
        int TYPE_NAMES { get; }
        int TRAINER_TYPE_NAMES { get; }
        int TRAINER_NAMES { get; }
        int FRONTIER_INTRO_SPEECHES { get; }
        int FRONTIER_END_SPEECHES_WIN { get; }
        int FRONTIER_END_SPEECHES_LOSE { get; }
        int REGION_NAMES { get; }
        int REGION_LOCATION_NAMES { get; }
        int REGION_LOCATION_DESCRIPTIONS { get; }
        int MAP_NAMES { get; }
        int PHONE_MESSAGES { get; }
        int TRAINER_SPEECHES_LOSE { get; }
        int SCRIPT_TEXTS { get; }
        int RIBBON_NAMES { get; }
        int RIBBON_DESCRIPTIONS { get; }
        int STORAGE_CREATOR_NAME { get; }
        int ITEM_PORTION_NAMES { get; }
        int ITEM_PORTION_NAME_PLURALS { get; }
        int POKEMON_NICKNAMES { get; }

        void load_default_messages();
        void load_message_files(string filename);
        void save_default_messages();
        void setMessages(int type, IList<string> array);
        void addMessages(int type, IList<string> array);
        void setMessagesAsHash(int type, IList<string> array);
        void addMessagesAsHash(int type, IList<string> array);
        void setMapMessagesAsHash(int type, IList<string> array);
        void addMapMessagesAsHash(int type, IList<string> array);
        string get(int type, object id);
        string getFromHash(int type, string key);
        string getFromMapHash(int type, string key);
    }
}