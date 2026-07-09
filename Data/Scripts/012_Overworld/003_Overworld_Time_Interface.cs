using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for day and night system functions.
    /// </summary>
    //public interface ITimeHelper
    public interface IMainOverworldTime : IMain
    {
        /// <summary>
        /// Gets the current time.
        /// </summary>
        /// <returns>The current DateTime</returns>
        DateTime GetTimeNow();
    //}

    /// <summary>
    /// Interface for day and night tinting functions.
    /// </summary>
    //public interface IDayNightTint
    //{
        /// <summary>
        /// Applies day/night tint to an object based on current time.
        /// </summary>
        /// <param name="obj">The object to tint</param>
        void DayNightTint(object obj);
    //}

    /// <summary>
    /// Interface for weekday-related functions.
    /// </summary>
    //public interface IWeekdayHelper
    //{
        /// <summary>
        /// Checks if the current day is one of the specified weekdays.
        /// </summary>
        /// <param name="wdayVariable">Variable to store the weekday name</param>
        /// <param name="weekdays">Array of weekday numbers to check (0=Sunday, 6=Saturday)</param>
        /// <returns>True if current day matches any of the specified weekdays</returns>
        bool IsWeekday(int wdayVariable, params int[] weekdays);
    //}

    /// <summary>
    /// Interface for month-related functions.
    /// </summary>
    //public interface IMonthHelper
    //{
        /// <summary>
        /// Checks if the current month is one of the specified months.
        /// </summary>
        /// <param name="monVariable">Variable to store the month name</param>
        /// <param name="months">Array of month numbers to check (1=January, 12=December)</param>
        /// <returns>True if current month matches any of the specified months</returns>
        bool IsMonth(int monVariable, params int[] months);

        /// <summary>
        /// Gets the full name of the specified month.
        /// </summary>
        /// <param name="month">Month number (1-12)</param>
        /// <returns>The full month name</returns>
        string GetMonthName(int month);

        /// <summary>
        /// Gets the abbreviated name of the specified month.
        /// </summary>
        /// <param name="month">Month number (1-12)</param>
        /// <returns>The abbreviated month name</returns>
        string GetAbbrevMonthName(int month);
    //}

    /// <summary>
    /// Interface for season-related functions.
    /// </summary>
    //public interface ISeasonHelper
    //{
        /// <summary>
        /// Gets the current season (0=Spring, 1=Summer, 2=Autumn, 3=Winter).
        /// </summary>
        /// <returns>Current season number</returns>
        int GetSeason();

        /// <summary>
        /// Checks if the current season is one of the specified seasons.
        /// </summary>
        /// <param name="seasonVariable">Variable to store the season name</param>
        /// <param name="seasons">Array of season numbers to check</param>
        /// <returns>True if current season matches any of the specified seasons</returns>
        bool IsSeason(int seasonVariable, params int[] seasons);

        /// <summary>
        /// Returns true if it's currently spring.
        /// </summary>
        /// <returns>True if spring (January, May, September)</returns>
        bool IsSpring();

        /// <summary>
        /// Returns true if it's currently summer.
        /// </summary>
        /// <returns>True if summer (February, June, October)</returns>
        bool IsSummer();

        /// <summary>
        /// Returns true if it's currently autumn.
        /// </summary>
        /// <returns>True if autumn (March, July, November)</returns>
        bool IsAutumn();

        /// <summary>
        /// Returns true if it's currently fall (alias for autumn).
        /// </summary>
        /// <returns>True if fall/autumn</returns>
        bool IsFall();

        /// <summary>
        /// Returns true if it's currently winter.
        /// </summary>
        /// <returns>True if winter (April, August, December)</returns>
        bool IsWinter();

        /// <summary>
        /// Gets the name of the specified season.
        /// </summary>
        /// <param name="season">Season number (0-3)</param>
        /// <returns>The season name</returns>
        string GetSeasonName(int season);
    //}

    /// <summary>
    /// Interface for moon phase and zodiac calculations.
    /// </summary>
    //public interface IAstronomyHelper
    //{
        /// <summary>
        /// Calculates the phase of the moon.
        /// </summary>
        /// <param name="time">Optional time to check; uses current time if null</param>
        /// <returns>Moon phase (0=New Moon, 1=Waxing Crescent, 2=First Quarter, 3=Waxing Gibbous, 4=Full Moon, 5=Waning Gibbous, 6=Last Quarter, 7=Waning Crescent)</returns>
        int moonphase(DateTime? time = null);

        /// <summary>
        /// Calculates the zodiac sign based on the given month and day.
        /// </summary>
        /// <param name="month">Month (1=January, 12=December)</param>
        /// <param name="day">Day of the month</param>
        /// <returns>Zodiac sign (0=Aries, 11=Pisces)</returns>
        int zodiac(int month, int day);

        /// <summary>
        /// Returns the opposite of the given zodiac sign.
        /// </summary>
        /// <param name="sign">Zodiac sign (0=Aries, 11=Pisces)</param>
        /// <returns>The opposite zodiac sign</returns>
        int zodiacOpposite(int sign);

        /// <summary>
        /// Gets the partner zodiac signs for the given sign.
        /// </summary>
        /// <param name="sign">Zodiac sign (0=Aries, 11=Pisces)</param>
        /// <returns>Array of two partner zodiac signs</returns>
        int[] zodiacPartners(int sign);

        /// <summary>
        /// Gets the complementary zodiac signs for the given sign.
        /// </summary>
        /// <param name="sign">Zodiac sign (0=Aries, 11=Pisces)</param>
        /// <returns>Array of two complementary zodiac signs</returns>
        int[] zodiacComplements(int sign);
    }

    /// <summary>
    /// Interface for the day and night system module that handles time-based visual and game effects.
    /// </summary>
    public interface IPBDayNight
    {
        /// <summary>
        /// Array of tones for each hour of the day (0-23).
        /// </summary>
        ITone[] HOURLY_TONES { get; }

        /// <summary>
        /// Cached tone lifetime in seconds.
        /// </summary>
        int CACHED_TONE_LIFETIME { get; }

        /// <summary>
        /// Returns true if it's day time.
        /// </summary>
        /// <param name="time">Optional time to check; uses current time if null</param>
        /// <returns>True if between 5 AM and 8 PM</returns>
        bool isDay(DateTime? time = null);

        /// <summary>
        /// Returns true if it's night time.
        /// </summary>
        /// <param name="time">Optional time to check; uses current time if null</param>
        /// <returns>True if between 8 PM and 5 AM</returns>
        bool isNight(DateTime? time = null);

        /// <summary>
        /// Returns true if it's morning.
        /// </summary>
        /// <param name="time">Optional time to check; uses current time if null</param>
        /// <returns>True if between 5 AM and 10 AM</returns>
        bool isMorning(DateTime? time = null);

        /// <summary>
        /// Returns true if it's afternoon.
        /// </summary>
        /// <param name="time">Optional time to check; uses current time if null</param>
        /// <returns>True if between 2 PM and 5 PM</returns>
        bool isAfternoon(DateTime? time = null);

        /// <summary>
        /// Returns true if it's evening.
        /// </summary>
        /// <param name="time">Optional time to check; uses current time if null</param>
        /// <returns>True if between 5 PM and 8 PM</returns>
        bool isEvening(DateTime? time = null);

        /// <summary>
        /// Gets a number representing the amount of daylight (0=full night, 255=full day).
        /// </summary>
        /// <returns>Shade value from 0 to 255</returns>
        int getShade();

        /// <summary>
        /// Gets a Tone object representing a suggested shading tone for the current time of day.
        /// </summary>
        /// <returns>The current tone for time-based shading</returns>
        ITone getTone();

        /// <summary>
        /// Gets the current time in minutes since midnight.
        /// </summary>
        /// <returns>Minutes since midnight (0-1439)</returns>
        int GetDayNightMinutes();
    }
}