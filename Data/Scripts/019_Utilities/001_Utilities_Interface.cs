using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for general utility functions used throughout Pokemon Essentials.
    /// Provides common helper methods for various game operations.
    /// </summary>
    public interface IUtilities
    {
        /// <summary>
        /// Generates a random number within the specified range.
        /// </summary>
        /// <param name="max">The maximum value (exclusive).</param>
        /// <returns>A random number from 0 to max-1.</returns>
        int rand(int max);

        /// <summary>
        /// Generates a random number within the specified range.
        /// </summary>
        /// <param name="min">The minimum value (inclusive).</param>
        /// <param name="max">The maximum value (exclusive).</param>
        /// <returns>A random number from min to max-1.</returns>
        int rand(int min, int max);

        /// <summary>
        /// Converts a value to a boolean, handling various input types.
        /// </summary>
        /// <param name="value">The value to convert.</param>
        /// <returns>The boolean representation of the value.</returns>
        bool toBool(object value);

        /// <summary>
        /// Converts a value to an integer, handling various input types.
        /// </summary>
        /// <param name="value">The value to convert.</param>
        /// <returns>The integer representation of the value.</returns>
        int toInt(object value);

        /// <summary>
        /// Converts a value to a string, handling null values safely.
        /// </summary>
        /// <param name="value">The value to convert.</param>
        /// <returns>The string representation of the value.</returns>
        string toString(object value);

        /// <summary>
        /// Clamps a value between a minimum and maximum.
        /// </summary>
        /// <param name="value">The value to clamp.</param>
        /// <param name="min">The minimum allowed value.</param>
        /// <param name="max">The maximum allowed value.</param>
        /// <returns>The clamped value.</returns>
        int clamp(int value, int min, int max);

        /// <summary>
        /// Clamps a floating-point value between a minimum and maximum.
        /// </summary>
        /// <param name="value">The value to clamp.</param>
        /// <param name="min">The minimum allowed value.</param>
        /// <param name="max">The maximum allowed value.</param>
        /// <returns>The clamped value.</returns>
        float clamp(float value, float min, float max);

        /// <summary>
        /// Performs linear interpolation between two values.
        /// </summary>
        /// <param name="a">The start value.</param>
        /// <param name="b">The end value.</param>
        /// <param name="t">The interpolation factor (0.0 to 1.0).</param>
        /// <returns>The interpolated value.</returns>
        float lerp(float a, float b, float t);

        /// <summary>
        /// Checks if a value is within a specified range.
        /// </summary>
        /// <param name="value">The value to check.</param>
        /// <param name="min">The minimum value (inclusive).</param>
        /// <param name="max">The maximum value (inclusive).</param>
        /// <returns>True if the value is within range, false otherwise.</returns>
        bool isInRange(int value, int min, int max);

        /// <summary>
        /// Gets the sign of a number (-1, 0, or 1).
        /// </summary>
        /// <param name="value">The value to get the sign of.</param>
        /// <returns>-1 if negative, 0 if zero, 1 if positive.</returns>
        int sign(int value);

        /// <summary>
        /// Gets the sign of a floating-point number (-1, 0, or 1).
        /// </summary>
        /// <param name="value">The value to get the sign of.</param>
        /// <returns>-1 if negative, 0 if zero, 1 if positive.</returns>
        int sign(float value);
    }

    /// <summary>
    /// Interface for string manipulation and formatting utilities.
    /// </summary>
    public interface IStringUtilities
    {
        /// <summary>
        /// Capitalizes the first letter of a string.
        /// </summary>
        /// <param name="text">The text to capitalize.</param>
        /// <returns>The text with the first letter capitalized.</returns>
        string capitalize(string text);

        /// <summary>
        /// Converts text to title case (first letter of each word capitalized).
        /// </summary>
        /// <param name="text">The text to convert.</param>
        /// <returns>The text in title case.</returns>
        string titleCase(string text);

        /// <summary>
        /// Pluralizes a word based on a count.
        /// </summary>
        /// <param name="word">The word to pluralize.</param>
        /// <param name="count">The count to base pluralization on.</param>
        /// <returns>The singular or plural form of the word.</returns>
        string pluralize(string word, int count);

        /// <summary>
        /// Formats a number with appropriate suffixes (1st, 2nd, 3rd, etc.).
        /// </summary>
        /// <param name="number">The number to format.</param>
        /// <returns>The number with ordinal suffix.</returns>
        string ordinal(int number);

        /// <summary>
        /// Truncates text to a maximum length, adding ellipsis if necessary.
        /// </summary>
        /// <param name="text">The text to truncate.</param>
        /// <param name="maxLength">The maximum length allowed.</param>
        /// <returns>The truncated text.</returns>
        string truncate(string text, int maxLength);

        /// <summary>
        /// Removes special characters from text, keeping only letters and numbers.
        /// </summary>
        /// <param name="text">The text to sanitize.</param>
        /// <returns>The sanitized text.</returns>
        string sanitize(string text);

        /// <summary>
        /// Formats text for display with word wrapping.
        /// </summary>
        /// <param name="text">The text to format.</param>
        /// <param name="maxWidth">The maximum width per line.</param>
        /// <returns>The formatted text with line breaks.</returns>
        string wordWrap(string text, int maxWidth);
    }

    /// <summary>
    /// Interface for mathematical utility functions.
    /// </summary>
    public interface IMathUtilities
    {
        /// <summary>
        /// Calculates the distance between two points.
        /// </summary>
        /// <param name="x1">X coordinate of first point.</param>
        /// <param name="y1">Y coordinate of first point.</param>
        /// <param name="x2">X coordinate of second point.</param>
        /// <param name="y2">Y coordinate of second point.</param>
        /// <returns>The distance between the points.</returns>
        float distance(float x1, float y1, float x2, float y2);

        /// <summary>
        /// Calculates the squared distance between two points (faster than distance).
        /// </summary>
        /// <param name="x1">X coordinate of first point.</param>
        /// <param name="y1">Y coordinate of first point.</param>
        /// <param name="x2">X coordinate of second point.</param>
        /// <param name="y2">Y coordinate of second point.</param>
        /// <returns>The squared distance between the points.</returns>
        float distanceSquared(float x1, float y1, float x2, float y2);

        /// <summary>
        /// Converts degrees to radians.
        /// </summary>
        /// <param name="degrees">The angle in degrees.</param>
        /// <returns>The angle in radians.</returns>
        float degreesToRadians(float degrees);

        /// <summary>
        /// Converts radians to degrees.
        /// </summary>
        /// <param name="radians">The angle in radians.</param>
        /// <returns>The angle in degrees.</returns>
        float radiansToDegrees(float radians);

        /// <summary>
        /// Calculates the factorial of a number.
        /// </summary>
        /// <param name="n">The number to calculate factorial for.</param>
        /// <returns>The factorial of n.</returns>
        long factorial(int n);

        /// <summary>
        /// Checks if a number is prime.
        /// </summary>
        /// <param name="number">The number to check.</param>
        /// <returns>True if the number is prime, false otherwise.</returns>
        bool isPrime(int number);

        /// <summary>
        /// Calculates the greatest common divisor of two numbers.
        /// </summary>
        /// <param name="a">The first number.</param>
        /// <param name="b">The second number.</param>
        /// <returns>The greatest common divisor.</returns>
        int gcd(int a, int b);

        /// <summary>
        /// Calculates the least common multiple of two numbers.
        /// </summary>
        /// <param name="a">The first number.</param>
        /// <param name="b">The second number.</param>
        /// <returns>The least common multiple.</returns>
        int lcm(int a, int b);
    }

    /// <summary>
    /// Interface for array and collection utility functions.
    /// </summary>
    public interface ICollectionUtilities
    {
        /// <summary>
        /// Shuffles the elements of an array randomly.
        /// </summary>
        /// <typeparam name="T">The type of elements in the array.</typeparam>
        /// <param name="array">The array to shuffle.</param>
        /// <returns>The shuffled array.</returns>
        T[] shuffle<T>(T[] array);

        /// <summary>
        /// Shuffles the elements of a list randomly.
        /// </summary>
        /// <typeparam name="T">The type of elements in the list.</typeparam>
        /// <param name="list">The list to shuffle.</param>
        /// <returns>The shuffled list.</returns>
        IList<T> shuffle<T>(IList<T> list);

        /// <summary>
        /// Selects a random element from an array.
        /// </summary>
        /// <typeparam name="T">The type of elements in the array.</typeparam>
        /// <param name="array">The array to select from.</param>
        /// <returns>A randomly selected element.</returns>
        T randomElement<T>(T[] array);

        /// <summary>
        /// Selects a random element from a list.
        /// </summary>
        /// <typeparam name="T">The type of elements in the list.</typeparam>
        /// <param name="list">The list to select from.</param>
        /// <returns>A randomly selected element.</returns>
        T randomElement<T>(IList<T> list);

        /// <summary>
        /// Removes duplicate elements from an array.
        /// </summary>
        /// <typeparam name="T">The type of elements in the array.</typeparam>
        /// <param name="array">The array to remove duplicates from.</param>
        /// <returns>An array with unique elements only.</returns>
        T[] removeDuplicates<T>(T[] array);

        /// <summary>
        /// Removes duplicate elements from a list.
        /// </summary>
        /// <typeparam name="T">The type of elements in the list.</typeparam>
        /// <param name="list">The list to remove duplicates from.</param>
        /// <returns>A list with unique elements only.</returns>
        IList<T> removeDuplicates<T>(IList<T> list);

        /// <summary>
        /// Chunks an array into smaller arrays of specified size.
        /// </summary>
        /// <typeparam name="T">The type of elements in the array.</typeparam>
        /// <param name="array">The array to chunk.</param>
        /// <param name="chunkSize">The size of each chunk.</param>
        /// <returns>An array of chunks.</returns>
        T[][] chunk<T>(T[] array, int chunkSize);

        /// <summary>
        /// Flattens a nested array structure into a single-level array.
        /// </summary>
        /// <typeparam name="T">The type of elements in the array.</typeparam>
        /// <param name="nestedArray">The nested array to flatten.</param>
        /// <returns>A flattened array.</returns>
        T[] flatten<T>(T[][] nestedArray);
    }

    /// <summary>
    /// Interface for file and data utility functions.
    /// </summary>
    public interface IFileUtilities
    {
        /// <summary>
        /// Checks if a file exists at the specified path.
        /// </summary>
        /// <param name="filePath">The path to check.</param>
        /// <returns>True if the file exists, false otherwise.</returns>
        bool fileExists(string filePath);

        /// <summary>
        /// Reads all text from a file.
        /// </summary>
        /// <param name="filePath">The path of the file to read.</param>
        /// <returns>The contents of the file as a string.</returns>
        string readTextFile(string filePath);

        /// <summary>
        /// Writes text to a file.
        /// </summary>
        /// <param name="filePath">The path of the file to write to.</param>
        /// <param name="content">The text content to write.</param>
        void writeTextFile(string filePath, string content);

        /// <summary>
        /// Gets the file extension from a file path.
        /// </summary>
        /// <param name="filePath">The file path.</param>
        /// <returns>The file extension (including the dot).</returns>
        string getFileExtension(string filePath);

        /// <summary>
        /// Gets the filename without extension from a file path.
        /// </summary>
        /// <param name="filePath">The file path.</param>
        /// <returns>The filename without extension.</returns>
        string getFileNameWithoutExtension(string filePath);

        /// <summary>
        /// Combines multiple path segments into a single path.
        /// </summary>
        /// <param name="paths">The path segments to combine.</param>
        /// <returns>The combined path.</returns>
        string combinePaths(params string[] paths);

        /// <summary>
        /// Creates a directory if it doesn't already exist.
        /// </summary>
        /// <param name="directoryPath">The path of the directory to create.</param>
        void createDirectory(string directoryPath);

        /// <summary>
        /// Gets all files in a directory matching a pattern.
        /// </summary>
        /// <param name="directoryPath">The directory to search in.</param>
        /// <param name="pattern">The file pattern to match (e.g., "*.txt").</param>
        /// <returns>Array of matching file paths.</returns>
        string[] getFiles(string directoryPath, string pattern = "*");
    }

    /// <summary>
    /// Interface for time and date utility functions.
    /// </summary>
    public interface ITimeUtilities
    {
        /// <summary>
        /// Gets the current system time.
        /// </summary>
        /// <returns>The current time.</returns>
        DateTime getCurrentTime();

        /// <summary>
        /// Formats a time span as a human-readable string.
        /// </summary>
        /// <param name="timeSpan">The time span to format.</param>
        /// <returns>The formatted time string.</returns>
        string formatTimeSpan(TimeSpan timeSpan);

        /// <summary>
        /// Converts seconds to a formatted time string (MM:SS or HH:MM:SS).
        /// </summary>
        /// <param name="seconds">The number of seconds.</param>
        /// <returns>The formatted time string.</returns>
        string secondsToTimeString(int seconds);

        /// <summary>
        /// Gets the number of seconds that have elapsed since a specific time.
        /// </summary>
        /// <param name="startTime">The start time.</param>
        /// <returns>The number of seconds elapsed.</returns>
        int getElapsedSeconds(DateTime startTime);

        /// <summary>
        /// Checks if enough time has passed since a specific time.
        /// </summary>
        /// <param name="lastTime">The last recorded time.</param>
        /// <param name="requiredSeconds">The minimum seconds required.</param>
        /// <returns>True if enough time has passed, false otherwise.</returns>
        bool hasTimeElapsed(DateTime lastTime, int requiredSeconds);

        /// <summary>
        /// Gets the current day of the week.
        /// </summary>
        /// <returns>The current day of the week.</returns>
        DayOfWeek getCurrentDayOfWeek();

        /// <summary>
        /// Checks if the current time is within a specific hour range.
        /// </summary>
        /// <param name="startHour">The start hour (0-23).</param>
        /// <param name="endHour">The end hour (0-23).</param>
        /// <returns>True if the current time is within the range, false otherwise.</returns>
        bool isCurrentTimeInRange(int startHour, int endHour);
    }
}