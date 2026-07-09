using System;
using System.Collections.Generic;

namespace PokemonEssentials.Data
{
    /// <summary>
    /// Interface for Species file management, handling graphics, audio, and other media files for Pokemon species.
    /// Provides methods for checking, loading, and managing species-related assets.
    /// </summary>
    public interface ISpeciesFiles
    {
        /// <summary>
        /// Checks for the existence of a graphic file for a species with various parameters.
        /// </summary>
        /// <param name="path">The base path to search in</param>
        /// <param name="species">The species identifier</param>
        /// <param name="form">The form number</param>
        /// <param name="gender">The gender (0 = male/genderless, 1 = female)</param>
        /// <param name="shiny">Whether to check for shiny variants</param>
        /// <param name="shadow">Whether to check for shadow variants</param>
        /// <param name="subfolder">The subfolder to search in</param>
        /// <returns>The resolved filename, or null if not found</returns>
        string check_graphic_file(string path, int species, int form = 0, int gender = 0, bool shiny = false, bool shadow = false, string subfolder = "");

        /// <summary>
        /// Checks for the existence of an egg graphic file for a species.
        /// </summary>
        /// <param name="path">The base path to search in</param>
        /// <param name="species">The species identifier</param>
        /// <param name="form">The form number</param>
        /// <param name="suffix">Additional suffix for the filename</param>
        /// <returns>The resolved filename, or null if not found</returns>
        string check_egg_graphic_file(string path, int species, int form, string suffix = "");

        /// <summary>
        /// Gets the filename for a front sprite of a species.
        /// </summary>
        /// <param name="species">The species identifier</param>
        /// <param name="form">The form number</param>
        /// <param name="gender">The gender</param>
        /// <param name="shiny">Whether this is a shiny variant</param>
        /// <param name="shadow">Whether this is a shadow variant</param>
        /// <returns>The front sprite filename</returns>
        string front_sprite_filename(int species, int form = 0, int gender = 0, bool shiny = false, bool shadow = false);

        /// <summary>
        /// Gets the filename for a back sprite of a species.
        /// </summary>
        /// <param name="species">The species identifier</param>
        /// <param name="form">The form number</param>
        /// <param name="gender">The gender</param>
        /// <param name="shiny">Whether this is a shiny variant</param>
        /// <param name="shadow">Whether this is a shadow variant</param>
        /// <returns>The back sprite filename</returns>
        string back_sprite_filename(int species, int form = 0, int gender = 0, bool shiny = false, bool shadow = false);

        /// <summary>
        /// Gets the filename for an egg sprite of a species.
        /// </summary>
        /// <param name="species">The species identifier</param>
        /// <param name="form">The form number</param>
        /// <returns>The egg sprite filename</returns>
        string egg_sprite_filename(int species, int form);

        /// <summary>
        /// Gets the filename for an egg cracks sprite of a species.
        /// </summary>
        /// <param name="species">The species identifier</param>
        /// <param name="form">The form number</param>
        /// <returns>The egg cracks sprite filename</returns>
        string egg_cracks_sprite_filename(int species, int form);

        /// <summary>
        /// Gets the sprite filename for a species with various options.
        /// </summary>
        /// <param name="species">The species identifier</param>
        /// <param name="form">The form number</param>
        /// <param name="gender">The gender</param>
        /// <param name="shiny">Whether this is a shiny variant</param>
        /// <param name="shadow">Whether this is a shadow variant</param>
        /// <param name="back">Whether to get the back sprite</param>
        /// <param name="egg">Whether to get the egg sprite</param>
        /// <returns>The sprite filename</returns>
        string sprite_filename(int species, int form = 0, int gender = 0, bool shiny = false, bool shadow = false, bool back = false, bool egg = false);

        /// <summary>
        /// Gets a front sprite bitmap for a species.
        /// </summary>
        /// <param name="species">The species identifier</param>
        /// <param name="form">The form number</param>
        /// <param name="gender">The gender</param>
        /// <param name="shiny">Whether this is a shiny variant</param>
        /// <param name="shadow">Whether this is a shadow variant</param>
        /// <returns>The animated bitmap, or null if not found</returns>
        IAnimatedBitmap front_sprite_bitmap(int species, int form = 0, int gender = 0, bool shiny = false, bool shadow = false);

        /// <summary>
        /// Gets a back sprite bitmap for a species.
        /// </summary>
        /// <param name="species">The species identifier</param>
        /// <param name="form">The form number</param>
        /// <param name="gender">The gender</param>
        /// <param name="shiny">Whether this is a shiny variant</param>
        /// <param name="shadow">Whether this is a shadow variant</param>
        /// <returns>The animated bitmap, or null if not found</returns>
        IAnimatedBitmap back_sprite_bitmap(int species, int form = 0, int gender = 0, bool shiny = false, bool shadow = false);

        /// <summary>
        /// Gets an egg sprite bitmap for a species.
        /// </summary>
        /// <param name="species">The species identifier</param>
        /// <param name="form">The form number</param>
        /// <returns>The animated bitmap, or null if not found</returns>
        IAnimatedBitmap egg_sprite_bitmap(int species, int form = 0);

        /// <summary>
        /// Gets a sprite bitmap for a species with various options.
        /// </summary>
        /// <param name="species">The species identifier</param>
        /// <param name="form">The form number</param>
        /// <param name="gender">The gender</param>
        /// <param name="shiny">Whether this is a shiny variant</param>
        /// <param name="shadow">Whether this is a shadow variant</param>
        /// <param name="back">Whether to get the back sprite</param>
        /// <param name="egg">Whether to get the egg sprite</param>
        /// <returns>The animated bitmap, or null if not found</returns>
        IAnimatedBitmap sprite_bitmap(int species, int form = 0, int gender = 0, bool shiny = false, bool shadow = false, bool back = false, bool egg = false);

        /// <summary>
        /// Gets a sprite bitmap from a Pokemon object.
        /// </summary>
        /// <param name="pkmn">The Pokemon to get the sprite for</param>
        /// <param name="back">Whether to get the back sprite</param>
        /// <param name="species">Override species (optional)</param>
        /// <returns>The animated bitmap, or null if not found</returns>
        IAnimatedBitmap sprite_bitmap_from_pokemon(IPokemon pkmn, bool back = false, int? species = null);

        /// <summary>
        /// Gets the filename for an egg icon of a species.
        /// </summary>
        /// <param name="species">The species identifier</param>
        /// <param name="form">The form number</param>
        /// <returns>The egg icon filename</returns>
        string egg_icon_filename(int species, int form);

        /// <summary>
        /// Gets the icon filename for a species.
        /// </summary>
        /// <param name="species">The species identifier</param>
        /// <param name="form">The form number</param>
        /// <param name="gender">The gender</param>
        /// <param name="shiny">Whether this is a shiny variant</param>
        /// <param name="shadow">Whether this is a shadow variant</param>
        /// <param name="egg">Whether to get the egg icon</param>
        /// <returns>The icon filename</returns>
        string icon_filename(int species, int form = 0, int gender = 0, bool shiny = false, bool shadow = false, bool egg = false);

        /// <summary>
        /// Gets the icon filename from a Pokemon object.
        /// </summary>
        /// <param name="pkmn">The Pokemon to get the icon for</param>
        /// <returns>The icon filename</returns>
        string icon_filename_from_pokemon(IPokemon pkmn);

        /// <summary>
        /// Gets an egg icon bitmap for a species.
        /// </summary>
        /// <param name="species">The species identifier</param>
        /// <param name="form">The form number</param>
        /// <returns>The bitmap, or null if not found</returns>
        IBitmap egg_icon_bitmap(int species, int form);

        /// <summary>
        /// Gets an icon bitmap for a species.
        /// </summary>
        /// <param name="species">The species identifier</param>
        /// <param name="form">The form number</param>
        /// <param name="gender">The gender</param>
        /// <param name="shiny">Whether this is a shiny variant</param>
        /// <param name="shadow">Whether this is a shadow variant</param>
        /// <param name="egg">Whether to get the egg icon</param>
        /// <returns>The bitmap, or null if not found</returns>
        IBitmap icon_bitmap(int species, int form = 0, int gender = 0, bool shiny = false, bool shadow = false, bool egg = false);

        /// <summary>
        /// Gets an icon bitmap from a Pokemon object.
        /// </summary>
        /// <param name="pkmn">The Pokemon to get the icon for</param>
        /// <returns>The bitmap, or null if not found</returns>
        IBitmap icon_bitmap_from_pokemon(IPokemon pkmn);

        /// <summary>
        /// Gets the footprint filename for a species.
        /// </summary>
        /// <param name="species">The species identifier</param>
        /// <param name="form">The form number</param>
        /// <returns>The footprint filename, or null if not found</returns>
        string footprint_filename(int species, int form = 0);

        /// <summary>
        /// Gets the shadow filename for a species.
        /// </summary>
        /// <param name="species">The species identifier</param>
        /// <param name="form">The form number</param>
        /// <returns>The shadow filename, or null if not found</returns>
        string shadow_filename(int species, int form = 0);

        /// <summary>
        /// Gets a shadow bitmap for a species.
        /// </summary>
        /// <param name="species">The species identifier</param>
        /// <param name="form">The form number</param>
        /// <returns>The animated bitmap, or null if not found</returns>
        IAnimatedBitmap shadow_bitmap(int species, int form = 0);

        /// <summary>
        /// Gets a shadow bitmap from a Pokemon object.
        /// </summary>
        /// <param name="pkmn">The Pokemon to get the shadow for</param>
        /// <returns>The animated bitmap, or null if not found</returns>
        IAnimatedBitmap shadow_bitmap_from_pokemon(IPokemon pkmn);

        /// <summary>
        /// Checks for the existence of a cry file for a species.
        /// </summary>
        /// <param name="species">The species identifier</param>
        /// <param name="form">The form number</param>
        /// <param name="suffix">Additional suffix for the filename</param>
        /// <returns>The cry filename, or null if not found</returns>
        string check_cry_file(int species, int form, string suffix = "");

        /// <summary>
        /// Gets the cry filename for a species.
        /// </summary>
        /// <param name="species">The species identifier</param>
        /// <param name="form">The form number</param>
        /// <param name="suffix">Additional suffix for the filename</param>
        /// <returns>The cry filename, or null if not found</returns>
        string cry_filename(int species, int form = 0, string suffix = "");

        /// <summary>
        /// Gets the cry filename from a Pokemon object.
        /// </summary>
        /// <param name="pkmn">The Pokemon to get the cry for</param>
        /// <param name="suffix">Additional suffix for the filename</param>
        /// <returns>The cry filename, or null if not found</returns>
        string cry_filename_from_pokemon(IPokemon pkmn, string suffix = "");

        /// <summary>
        /// Plays the cry sound for a species.
        /// </summary>
        /// <param name="species">The species identifier</param>
        /// <param name="form">The form number</param>
        /// <param name="volume">The volume level (0-100)</param>
        /// <param name="pitch">The pitch modifier (100 = normal)</param>
        void play_cry_from_species(int species, int form = 0, int volume = 90, int pitch = 100);

        /// <summary>
        /// Plays the cry sound from a Pokemon object.
        /// </summary>
        /// <param name="pkmn">The Pokemon to play the cry for</param>
        /// <param name="volume">The volume level (0-100)</param>
        /// <param name="pitch">The pitch modifier (100 = normal)</param>
        void play_cry_from_pokemon(IPokemon pkmn, int volume = 90, int pitch = 100);

        /// <summary>
        /// Plays the cry sound for a Pokemon or species.
        /// </summary>
        /// <param name="pkmn">The Pokemon object or species identifier</param>
        /// <param name="volume">The volume level (0-100)</param>
        /// <param name="pitch">The pitch modifier (100 = normal)</param>
        void play_cry(object pkmn, int volume = 90, int pitch = 100);

        /// <summary>
        /// Gets the length of a cry sound in seconds.
        /// </summary>
        /// <param name="species">The species identifier or Pokemon object</param>
        /// <param name="form">The form number</param>
        /// <param name="pitch">The pitch modifier (100 = normal)</param>
        /// <param name="suffix">Additional suffix for the filename</param>
        /// <returns>The cry length in seconds</returns>
        float cry_length(object species, int form = 0, int pitch = 100, string suffix = "");
    }
}