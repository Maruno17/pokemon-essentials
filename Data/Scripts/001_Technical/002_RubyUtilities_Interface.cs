using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Global utility methods and extensions (IMain interface).
    /// </summary>
    public interface IMainUtilities : IMain
    {
        /// <summary>
        /// Generates a random number.
        /// </summary>
        int rand(object a = null, object b = null);

        /// <summary>
        /// Checks if a string is null or empty.
        /// </summary>
        bool nil_or_empty(string str);

        /// <summary>
        /// Performs linear interpolation between two values.
        /// </summary>
        double lerp(double start_val, double end_val, double duration, double delta, double? now = null);
    }

    /// <summary>
    /// Color manipulation and conversion utilities.
    /// </summary>
    public interface IColorExtensions
    {
        /// <summary>
        /// Creates a color from RGB values.
        /// </summary>
        IColor new_from_rgb(object param);

        /// <summary>
        /// Converts the color to RGB15 format.
        /// </summary>
        int to_rgb15();

        /// <summary>
        /// Converts the color to RGB24 format.
        /// </summary>
        string to_rgb24();

        /// <summary>
        /// Converts the color to RGB32 format.
        /// </summary>
        string to_rgb32(bool always_include_alpha = false);

        /// <summary>
        /// Converts the color to hex format.
        /// </summary>
        string to_hex();

        /// <summary>
        /// Converts the color to integer.
        /// </summary>
        int to_i();

        /// <summary>
        /// Gets a contrasting color.
        /// </summary>
        IColor get_contrast_color();

        /// <summary>
        /// Converts hex color to RGB values.
        /// </summary>
        IColorRGB hex_to_rgb(string hex);

        /// <summary>
        /// Parses a color from various formats.
        /// </summary>
        IColor parse(object color);

        // Predefined colors
        IColor red { get; }
        IColor green { get; }
        IColor blue { get; }
        IColor yellow { get; }
        IColor magenta { get; }
        IColor cyan { get; }
        IColor white { get; }
        IColor gray { get; }
        IColor black { get; }
        IColor pink { get; }
        IColor orange { get; }
        IColor purple { get; }
        IColor brown { get; }
    }

    /// <summary>
    /// Interface for CallbackWrapper.
    /// </summary>
    public interface ICallbackWrapper
    {
        /// <summary>
        /// Executes the wrapped code block with optional parameters.
        /// </summary>
        void execute(Action<IDictionary<string, object>> given_block = null, IDictionary<string, object> args = null);

        /// <summary>
        /// Sets the parameters for the wrapped code block.
        /// </summary>
        void set(IDictionary<string, object> parameters);
    }

    /// <summary>
    /// Interface for Object extensions.
    /// </summary>
    public interface IObjectExtensions
    {
        /// <summary>
        /// Returns a short inspection string of the object.
        /// </summary>
        string inspect(object self);
    }

    /// <summary>
    /// Interface for Class extensions.
    /// </summary>
    public interface IClassExtensions
    {
        /// <summary>
        /// Converts the class name to a symbol.
        /// </summary>
        string to_sym(Type self);
    }

    /// <summary>
    /// Interface for String extensions.
    /// </summary>
    public interface IStringExtensions
    {
        /// <summary>
        /// Checks if the string starts with a vowel.
        /// </summary>
        bool starts_with_vowel(string self);

        /// <summary>
        /// Returns the first N characters of the string.
        /// </summary>
        string first(string self, int n = 1);

        /// <summary>
        /// Returns the last N characters of the string.
        /// </summary>
        string last(string self, int n = 1);

        /// <summary>
        /// Checks if the string is blank (empty or only whitespace).
        /// </summary>
        bool blank(string self);

        /// <summary>
        /// Cuts the string to fit within a specified width on a bitmap.
        /// </summary>
        string cut(string self, IBitmap bitmap, int width);

        /// <summary>
        /// Checks if the string represents a numeric value.
        /// </summary>
        bool numeric(string self);
    }

    /// <summary>
    /// Interface for Numeric extensions.
    /// </summary>
    public interface INumericExtensions
    {
        /// <summary>
        /// Turns a number into a string formatted like 12,345,678.
        /// </summary>
        string to_s_formatted(double self);

        /// <summary>
        /// Converts a number to its word representation.
        /// </summary>
        string to_word(double self);
    }

    /// <summary>
    /// Interface for Array extensions.
    /// </summary>
    public interface IArrayExtensions<T>
    {
        /// <summary>
        /// Performs a symmetric difference (XOR) between two arrays.
        /// </summary>
        IList<T> xor(IList<T> self, IList<T> other);

        /// <summary>
        /// Swaps the positions of two values in the array.
        /// </summary>
        void swap(IList<T> self, T val1, T val2);
    }

    /// <summary>
    /// Interface for Hash extensions.
    /// </summary>
    public interface IHashExtensions<TKey, TValue>
    {
        /// <summary>
        /// Performs a deep merge of another hash into this hash, returning a new merged hash.
        /// </summary>
        IDictionary<TKey, TValue> deep_merge(IDictionary<TKey, TValue> self, IDictionary<TKey, TValue> hash);

        /// <summary>
        /// Performs a deep merge of another hash into this hash, modifying this hash in place.
        /// </summary>
        void deep_merge_bang(IDictionary<TKey, TValue> self, IDictionary<TKey, TValue> hash);
    }

    /// <summary>
    /// Interface for Enumerable extensions.
    /// </summary>
    public interface IEnumerableExtensions<T>
    {
        /// <summary>
        /// Transforms each item in the enumerable using a provided function.
        /// </summary>
        IList<TResult> transform<TResult>(IEnumerable<T> self, Func<T, TResult> transformFunc);
    }

    /// <summary>
    /// Extensions for rectangle operations.
    /// </summary>
    public interface IRectExtensions
    {
        /// <summary>
        /// Checks if a point is contained within the rectangle.
        /// </summary>
        bool contains(int cx, int cy);
    }

    /// <summary>
    /// Extensions for file operations.
    /// </summary>
    public interface IFileExtensions
    {
        /// <summary>
        /// Copies a file from source to destination.
        /// </summary>
        void copy(string source, string destination);

        /// <summary>
        /// Moves a file from source to destination.
        /// </summary>
        void move(string source, string destination);
    }

    /// <summary>
    /// Interface for a range object, used by rand.
    /// </summary>
    public interface IRange
    {
        /// <summary>
        /// Gets the minimum value of the range.
        /// </summary>
        object min { get; }

        /// <summary>
        /// Gets the maximum value of the range.
        /// </summary>
        object max { get; }
    }
}
