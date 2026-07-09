using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for kernel-level console output methods (Kernel module).
    /// </summary>
    public interface IKernel
    {
        /// <summary>
        /// Outputs a string or object description to the console if debug mode is enabled.
        /// </summary>
        /// <param name="string">The string or object to print.</param>
        void echo(object @string);

        /// <summary>
        /// Outputs a string or object description to the console followed by a newline.
        /// </summary>
        /// <param name="string">The string or object to print.</param>
        void echoln(object @string);
    }

    /// <summary>
    /// Interface for console debugging and output formatting (Console module).
    /// </summary>
    public interface IConsole
    {
        /// <summary>
        /// Sets up the debug console if debug mode is enabled.
        /// </summary>
        void setup_console();

        /// <summary>
        /// Reads a line of input from the console and strips whitespace.
        /// </summary>
        /// <returns>The stripped input string.</returns>
        string readInput();

        /// <summary>
        /// Alternative method for reading input from the console.
        /// </summary>
        /// <returns>The input string.</returns>
        string readInput2();

        /// <summary>
        /// Gets input from the console and echoes it.
        /// </summary>
        /// <returns>The input string echoed.</returns>
        string get_input();

        /// <summary>
        /// Outputs a heading 1 style message to the console.
        /// </summary>
        /// <param name="msg">The message to display.</param>
        void echo_h1(string msg);

        /// <summary>
        /// Outputs a heading 2 style message to the console with optional formatting.
        /// </summary>
        /// <param name="msg">The message to display.</param>
        /// <param name="options">Additional formatting options.</param>
        void echo_h2(string msg, IDictionary<string, object> options = null);

        /// <summary>
        /// Outputs a heading 3 style message to the console.
        /// </summary>
        /// <param name="msg">The message to display.</param>
        void echo_h3(string msg);

        /// <summary>
        /// Outputs a list item with optional padding and color.
        /// </summary>
        /// <param name="msg">The list item message.</param>
        /// <param name="pad">The padding length. Defaults to 0.</param>
        /// <param name="color">The color to print with. Defaults to brown.</param>
        void echo_li(string msg, int pad = 0, ConsoleColors color = ConsoleColors.brown);

        /// <summary>
        /// Outputs a list item with a line break after.
        /// </summary>
        /// <param name="msg">The list item message.</param>
        /// <param name="pad">The padding length. Defaults to 0.</param>
        /// <param name="color">The color to print with. Defaults to brown.</param>
        void echoln_li(string msg, int pad = 0, ConsoleColors color = ConsoleColors.brown);

        /// <summary>
        /// Outputs a completed list item in green.
        /// </summary>
        /// <param name="msg">The message to display.</param>
        void echoln_li_done(string msg);

        /// <summary>
        /// Outputs a paragraph with markup.
        /// </summary>
        /// <param name="msg">The paragraph message.</param>
        void echo_p(string msg);

        /// <summary>
        /// Outputs a warning message in yellow.
        /// </summary>
        /// <param name="msg">The warning message.</param>
        void echo_warn(string msg);

        /// <summary>
        /// Outputs an error message in light red.
        /// </summary>
        /// <param name="msg">The error message.</param>
        void echo_error(string msg);

        /// <summary>
        /// Outputs status (OK in green, FAIL in red).
        /// </summary>
        /// <param name="status">The status flag.</param>
        void echo_status(bool status);

        /// <summary>
        /// Outputs completion status (done in green, error in red).
        /// </summary>
        /// <param name="status">The completion status flag.</param>
        void echo_done(bool status);

        /// <summary>
        /// Gets mapping of string names to ANSI color codes.
        /// </summary>
        IDictionary<string, string> string_colors();

        /// <summary>
        /// Gets mapping of background names to ANSI background codes.
        /// </summary>
        IDictionary<string, string> background_colors();

        /// <summary>
        /// Gets font options to ANSI codes.
        /// </summary>
        IDictionary<string, string> font_options();

        /// <summary>
        /// Gets text markup colors.
        /// </summary>
        IDictionary<string, ConsoleColors> markup_colors();

        /// <summary>
        /// Gets text markup options (e.g. underline, bold, italic).
        /// </summary>
        IDictionary<string, string> markup_options();

        /// <summary>
        /// Formats a string with ANSI styling.
        /// </summary>
        /// <param name="string">The string to format.</param>
        /// <param name="text">The text color. Defaults to default.</param>
        /// <param name="bg">The background color. Defaults to default.</param>
        /// <param name="options">Font formatting flags.</param>
        string markup_style(string @string, ConsoleColors text = ConsoleColors.default_color, ConsoleColors bg = ConsoleColors.default_color, IDictionary<string, bool> options = null);

        /// <summary>
        /// Combines markup colors and options.
        /// </summary>
        IDictionary<string, object> markup_all_options();

        /// <summary>
        /// Trims inner markup content and merges markup options.
        /// </summary>
        KeyValuePair<string, IDictionary<string, object>> markup_component(string @string, string component, string key, IDictionary<string, object> options);

        /// <summary>
        /// Breaks down text into markup components and options.
        /// </summary>
        KeyValuePair<string, IDictionary<string, object>> markup_breakdown(string @string, IDictionary<string, object> options = null);

        /// <summary>
        /// Processes a string with markup formatting.
        /// </summary>
        string markup(string @string);
    }

    /// <summary>
    /// Console coloring representation.
    /// </summary>
    public enum ConsoleColors
    {
        default_color,
        black,
        red,
        green,
        brown,
        blue,
        purple,
        cyan,
        gray,
        dark_gray,
        light_red,
        light_green,
        yellow,
        light_blue,
        light_purple,
        light_cyan,
        white
    }
}