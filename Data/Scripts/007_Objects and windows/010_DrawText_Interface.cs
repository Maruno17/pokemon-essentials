using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Text drawing and formatting system with support for rich markup, color tags, alignment, and icons.
	/// Provides comprehensive text rendering capabilities including outline text, shadows, and formatted character drawing.
	/// </summary>
	public interface IMainDrawText : IMain
	{
		/// <summary>
		/// Creates a color tag for use in formatted text markup.
		/// Generates string format "&lt;c=RRGGBB&gt;" for text coloring.
		/// </summary>
		/// <param name="color">Color to convert to RGB string format</param>
		/// <returns>Formatted color tag string for markup</returns>
		[System.Obsolete("Unused")]
		string ctag(IColor color);

		/// <summary>
		/// Creates a dual-color shadow tag for base and shadow color specification.
		/// Combines base and shadow colors into a single markup tag for text rendering.
		/// </summary>
		/// <param name="baseColor">Primary text color</param>
		/// <param name="shadowColor">Shadow/outline color</param>
		/// <returns>Formatted shadow color tag string</returns>
		[System.Obsolete("Unused")]
		string shadowctag(IColor baseColor, IColor shadowColor);

		/// <summary>
		/// Creates an advanced shadow color tag supporting RGB arrays and Color objects.
		/// Handles both Color instances and RGB(A) integer arrays for flexible color specification.
		/// </summary>
		/// <param name="baseColor">Base color as Color object or RGB array</param>
		/// <param name="shadowColor">Shadow color as Color object or RGB array</param>
		/// <returns>Formatted color tag with base and shadow colors</returns>
		string shadowc3tag(IColorValue baseColor, IColorValue shadowColor);

		/// <summary>
		/// Generates shadow color tag using automatic contrast color calculation.
		/// Determines optimal shadow color based on base color's contrast requirements.
		/// </summary>
		/// <param name="color">Base color to generate contrast shadow for</param>
		/// <returns>Shadow color tag with calculated contrast color</returns>
		[System.Obsolete("Unused")]
		string shadowctagFromColor(IColor color);

		/// <summary>
		/// Creates shadow color tag from RGB parameter value.
		/// Converts RGB numeric value to Color object and generates contrast-based shadow tag.
		/// </summary>
		/// <param name="rgbParam">RGB numeric value to convert</param>
		/// <returns>Shadow color tag string</returns>
		[System.Obsolete("Unused")]
		string shadowctagFromRgb(int rgbParam);

		/// <summary>
		/// Escapes special markup characters in text for safe rendering.
		/// Converts &amp;, &lt;, &gt; characters to HTML entity equivalents to prevent markup conflicts.
		/// </summary>
		/// <param name="text">Text to escape</param>
		/// <returns>Text with escaped markup characters</returns>
		string fmtEscape(string text);

		/// <summary>
		/// Replaces escaped HTML entities with their actual characters.
		/// Converts entity codes back to displayable characters including gender symbols.
		/// </summary>
		/// <param name="text">Text with HTML entities to decode</param>
		void fmtReplaceEscapes(string text);

		/// <summary>
		/// Strips all formatting markup from text to get plain text content.
		/// Removes all rich text tags while preserving the actual text content.
		/// </summary>
		/// <param name="text">Formatted text to convert</param>
		/// <returns>Plain text without any markup</returns>
		string toUnformattedText(string text);

		/// <summary>
		/// Calculates the character length of text after removing all formatting.
		/// Provides accurate character count excluding markup tags for text measurement.
		/// </summary>
		/// <param name="text">Formatted text to measure</param>
		/// <returns>Number of actual display characters</returns>
		int unformattedTextLength(string text);

		/// <summary>
		/// Generates icon markup tag for item display in text.
		/// Creates appropriate icon reference based on item's icon properties.
		/// </summary>
		/// <param name="item">Item object to generate icon tag for</param>
		/// <returns>Icon markup tag string</returns>
		string itemIconTag(int item);

		/// <summary>
		/// Creates formatted text dimensions without color/style markup for measurement.
		/// Strips visual formatting while preserving layout-affecting tags like line breaks.
		/// </summary>
		/// <param name="bitmap">Source bitmap for font measurements</param>
		/// <param name="xDst">X coordinate for text positioning</param>
		/// <param name="yDst">Y coordinate for text positioning</param>
		/// <param name="widthDst">Maximum width for text wrapping</param>
		/// <param name="heightDst">Maximum height constraint</param>
		/// <param name="text">Text to format</param>
		/// <param name="lineheight">Height of each text line in pixels</param>
		/// <param name="newlineBreaks">Whether to treat newlines as line breaks</param>
		/// <param name="explicitBreaksOnly">If true, only break at explicit markup</param>
		/// <returns>Array of formatted character data for rendering</returns>
		IList<IFormattedChar> getFormattedTextForDims(IBitmap bitmap, int xDst, int yDst, int widthDst, int heightDst, string text, int lineheight, bool newlineBreaks = true, bool explicitBreaksOnly = false);

		/// <summary>
		/// Fast text formatting for simple text without complex markup.
		/// Optimized path for text that doesn't require full markup processing.
		/// </summary>
		/// <param name="bitmap">Source bitmap for font measurements</param>
		/// <param name="xDst">X coordinate for text positioning</param>
		/// <param name="yDst">Y coordinate for text positioning</param>
		/// <param name="widthDst">Maximum width for text wrapping</param>
		/// <param name="heightDst">Maximum height constraint</param>
		/// <param name="text">Text to format</param>
		/// <param name="lineheight">Height of each text line in pixels</param>
		/// <param name="newlineBreaks">Whether to treat newlines as line breaks</param>
		/// <param name="explicitBreaksOnly">If true, only break at explicit markup</param>
		/// <returns>Array of formatted character data for rendering</returns>
		IList<IFormattedChar> getFormattedTextFast(IBitmap bitmap, int xDst, int yDst, int widthDst, int heightDst, string text, int lineheight, bool newlineBreaks = true, bool explicitBreaksOnly = false);

		/// <summary>
		/// Checks if character is a special wait/pause character in text streams.
		/// Identifies control characters that affect text display timing.
		/// </summary>
		/// <param name="character">Character to check</param>
		/// <returns>True if character is a wait character</returns>
		bool isWaitChar(string character);

		/// <summary>
		/// Gets the last non-null parameter from a stack array.
		/// Used for retrieving current formatting state from stacked values.
		/// </summary>
		/// <param name="paramArray">Array of stacked parameters</param>
		/// <param name="defaultValue">Default value if no parameters found</param>
		/// <returns>Last valid parameter or default value</returns>
		T getLastParam<T>(IList<T> paramArray, T defaultValue);

		/// <summary>
		/// Retrieves current color settings with opacity applied from formatting stacks.
		/// Combines base color stack and opacity stack to get final render colors.
		/// </summary>
		/// <param name="colorstack">Stack of color settings</param>
		/// <param name="opacitystack">Stack of opacity values</param>
		/// <param name="defaultcolors">Default colors if stacks are empty</param>
		/// <returns>Color pair with opacity applied</returns>
		IColorPair getLastColors(IList<IColorPair> colorstack, IList<int> opacitystack, IColorPair defaultcolors);

		/// <summary>
		/// Main text formatting function that processes rich markup into renderable characters.
		/// Handles comprehensive markup including colors, fonts, alignment, icons, and formatting.
		/// Supports: &lt;b&gt;, &lt;i&gt;, &lt;u&gt;, &lt;s&gt;, &lt;c=color&gt;, &lt;icon&gt;, &lt;br&gt;, alignment tags, and more.
		/// </summary>
		/// <param name="bitmap">Source bitmap for font and size calculations</param>
		/// <param name="xDst">X coordinate of text area top-left</param>
		/// <param name="yDst">Y coordinate of text area top-left</param>
		/// <param name="widthDst">Maximum width for automatic line wrapping</param>
		/// <param name="heightDst">Maximum height (-1 for unlimited)</param>
		/// <param name="text">Rich markup text to format and layout</param>
		/// <param name="lineheight">Pixel height of each text line</param>
		/// <param name="newlineBreaks">Whether \n characters create line breaks</param>
		/// <param name="explicitBreaksOnly">Only break lines at explicit &lt;br&gt; tags</param>
		/// <param name="collapseAlignments">Optimize alignment calculations</param>
		/// <returns>Array of formatted characters ready for rendering. Returns an empty array if <paramref name="bitmap"/> is null
		/// or disposed, or if <paramref name="widthDst"/> is 0 or less or <paramref name="heightDst"/> is 0.</returns>
		/// <remarks>
		/// Formatting Specification:
		/// This function uses the following syntax when formatting the text.
		/// <code>
		///   <b> ... </b>       - Formats the text in bold.
		///   <i> ... </i>       - Formats the text in italics.
		///   <u> ... </u>       - Underlines the text.
		///   <s> ... </s>       - Draws a strikeout line over the text.
		///   <al> ... </al>     - Left-aligns the text. Causes line breaks before and
		///                        after the text.
		///   <r>                - Right-aligns the text until the next line break.
		///   <ar> ... </ar>     - Right-aligns the text. Causes line breaks before and
		///                        after the text.
		///   <ac> ... </ac>     - Centers the text. Causes line breaks before and after
		///                        the text.
		///   <br>               - Causes a line break.
		///   <c=X> ... </c>     - Color specification. A total of four formats are
		///                        supported: RRGGBBAA, RRGGBB, 16-bit RGB, and
		///                        Window_Base color numbers.
		///   <c2=X> ... </c2>   - Color specification where the first half is the base
		///                        color and the second half is the shadow color. 16-bit
		///                        RGB is supported.
		///
		/// Added 2009-10-20
		///
		///   <c3=B,S> ... </c3> - Color specification where B is the base color and S is
		///                        the shadow color. B and/or S can be omitted. A total of
		///                        four formats are supported: RRGGBBAA, RRGGBB, 16-bit
		///                        RGB, and Window_Base color numbers.
		///
		/// Added 2009-9-12
		///
		///   <o=X>              - Displays the text in the given opacity (0-255)
		///
		/// Added 2009-10-19
		///
		///   <outln>            - Displays the text in outline format.
		///
		/// Added 2010-05-12
		///
		///   <outln2>           - Displays the text in outline format (outlines more
		///                        exaggerated.
		///   <fn=X> ... </fn>   - Formats the text in the specified font, or Arial if the
		///                        font doesn't exist.
		///   <fs=X> ... </fs>   - Changes the font size to X.
		///   <icon=X>           - Displays the icon X (in Graphics/Icons/).
		/// </code>
		///
		/// In addition, the syntax supports the following:
		///   &apos; - Converted to "'".
		///   &lt;   - Converted to "<".
		///   &gt;   - Converted to ">".
		///   &amp;  - Converted to "&".
		///   &quot; - Converted to double quotation mark.
		///
		/// To draw the characters, pass the returned array to the
		/// <see cref="drawFormattedChars(IBitmap, IList{IFormattedChar})"/> function.
		/// </remarks>
		IList<IFormattedChar> getFormattedText(IBitmap bitmap, int xDst, int yDst, int widthDst, int heightDst, string text, int lineheight = 32, bool newlineBreaks = true, bool explicitBreaksOnly = false, bool collapseAlignments = false);

		/// <summary>
		/// Breaks text into lines based on bitmap width constraints without formatting.
		/// Creates line-broken text layout for simple text rendering scenarios.
		/// </summary>
		/// <param name="bitmap">Bitmap to measure text dimensions against</param>
		/// <param name="text">Text to break into lines</param>
		/// <param name="width">Maximum width per line</param>
		/// <param name="dimensions">Output dimensions of formatted text</param>
		/// <returns>Array of line-broken text segments</returns>
		IList<ITextSegment> getLineBrokenText(IBitmap bitmap, string text, int width, IDimensions dimensions);

		/// <summary>
		/// Breaks text into colored chunks with basic color markup support.
		/// Handles simple color tags while breaking text to fit width constraints.
		/// </summary>
		/// <param name="bitmap">Bitmap for text measurement</param>
		/// <param name="text">Text with color markup to process</param>
		/// <param name="width">Maximum width per line</param>
		/// <param name="dimensions">Output dimensions of formatted text</param>
		/// <param name="plain">If true, ignore all markup tags</param>
		/// <returns>Array of colored text chunks</returns>
		IList<IColoredTextChunk> getLineBrokenChunks(IBitmap bitmap, string text, int width, IDimensions dimensions, bool plain = false);

		/// <summary>
		/// Renders line-broken text chunks onto a bitmap.
		/// Draws pre-processed text chunks with their associated colors and positions.
		/// </summary>
		/// <param name="bitmap">Target bitmap to draw on</param>
		/// <param name="xDst">X offset for drawing</param>
		/// <param name="yDst">Y offset for drawing</param>
		/// <param name="textChunks">Pre-processed text chunks to render</param>
		/// <param name="maxheight">Maximum height to draw (0 for unlimited)</param>
		void renderLineBrokenChunks(IBitmap bitmap, int xDst, int yDst, IList<IColoredTextChunk> textChunks, int maxheight = 0);

		/// <summary>
		/// Renders line-broken text chunks with shadow effects.
		/// Draws text with shadow offset for enhanced readability.
		/// </summary>
		/// <param name="bitmap">Target bitmap to draw on</param>
		/// <param name="xDst">X offset for drawing</param>
		/// <param name="yDst">Y offset for drawing</param>
		/// <param name="textChunks">Pre-processed text chunks to render</param>
		/// <param name="maxheight">Maximum height to draw</param>
		/// <param name="baseColor">Primary text color</param>
		/// <param name="shadowColor">Shadow color</param>
		void renderLineBrokenChunksWithShadow(IBitmap bitmap, int xDst, int yDst, IList<IColoredTextChunk> textChunks, int maxheight, IColor baseColor, IColor shadowColor);

		/// <summary>
		/// Creates a bitmap buffer containing rendered formatted characters.
		/// Generates a bitmap sized to fit all characters for caching or compositing.
		/// </summary>
		/// <param name="formattedChars">Array of formatted characters to render</param>
		/// <returns>Bitmap containing rendered text</returns>
		IBitmap drawBitmapBuffer(IList<IFormattedChar> formattedChars);

		/// <summary>
		/// Renders a single formatted character with all its styling properties.
		/// Handles fonts, colors, shadows, outlines, underlines, and graphics.
		/// </summary>
		/// <param name="bitmap">Target bitmap to draw on</param>
		/// <param name="formattedChar">Character data with formatting information</param>
		void drawSingleFormattedChar(IBitmap bitmap, IFormattedChar formattedChar);

		/// <summary>
		/// Renders an array of formatted characters onto a bitmap.
		/// Processes all characters while preserving original font settings.
		/// </summary>
		/// <param name="bitmap">Target bitmap to draw on</param>
		/// <param name="formattedChars">Array of formatted characters to render</param>
		void drawFormattedChars(IBitmap bitmap, IList<IFormattedChar> formattedChars);

		/// <summary>
		/// Draws a table of text with specified column widths and row heights.
		/// Formats each cell's text within the calculated cell boundaries.
		/// </summary>
		/// <param name="bitmap">Target bitmap to draw on</param>
		/// <param name="x">X coordinate of table top-left</param>
		/// <param name="y">Y coordinate of table top-left</param>
		/// <param name="totalWidth">Total table width</param>
		/// <param name="rowHeight">Height of each table row</param>
		/// <param name="columnWidthPercents">Array of column width percentages</param>
		/// <param name="tableData">2D array of cell text content</param>
		[System.Obsolete("Unused")]
		void drawTextTable(IBitmap bitmap, int x, int y, int totalWidth, int rowHeight, IList<int> columnWidthPercents, IList<IList<string>> tableData);

		/// <summary>
		/// Draws simple text with shadow using line-broken chunk rendering.
		/// Provides convenient method for basic shadowed text display.
		/// </summary>
		/// <param name="bitmap">Target bitmap to draw on</param>
		/// <param name="x">X coordinate for text</param>
		/// <param name="y">Y coordinate for text</param>
		/// <param name="width">Maximum text width</param>
		/// <param name="numlines">Number of lines to display</param>
		/// <param name="text">Text content to draw</param>
		/// <param name="baseColor">Primary text color</param>
		/// <param name="shadowColor">Shadow color</param>
		void drawTextEx(IBitmap bitmap, int x, int y, int width, int numlines, string text, IColor baseColor, IColor shadowColor);

		/// <summary>
		/// Renders formatted text with markup processing and automatic color application.
		/// Applies base and shadow colors to text and processes all formatting markup.
		/// </summary>
		/// <param name="bitmap">Target bitmap to draw on</param>
		/// <param name="x">X coordinate for text</param>
		/// <param name="y">Y coordinate for text</param>
		/// <param name="width">Maximum text width</param>
		/// <param name="text">Rich markup text to render</param>
		/// <param name="baseColor">Primary text color (default: gray)</param>
		/// <param name="shadowColor">Shadow color (default: light gray)</param>
		/// <param name="lineheight">Height of each line in pixels</param>
		void drawFormattedTextEx(IBitmap bitmap, int x, int y, int width, string text, IColor baseColor = null, IColor shadowColor = null, int lineheight = 32);

		/// <summary>
		/// Draws text with shadow effect using offset shadow rendering.
		/// Creates drop shadow by drawing text multiple times with color offset.
		/// </summary>
		/// <param name="bitmap">Target bitmap to draw on</param>
		/// <param name="x">X coordinate for text</param>
		/// <param name="y">Y coordinate for text</param>
		/// <param name="width">Text area width (-1 for auto-size)</param>
		/// <param name="height">Text area height (-1 for auto-size)</param>
		/// <param name="text">Text to draw</param>
		[System.Obsolete("Unused")]
		void DrawShadow(IBitmap bitmap, int x, int y, int width, int height, string text);

		/// <summary>
		/// Draws plain text without any shadow or outline effects.
		/// Simple text rendering with color and alignment support.
		/// </summary>
		/// <param name="bitmap">Target bitmap to draw on</param>
		/// <param name="x">X coordinate for text</param>
		/// <param name="y">Y coordinate for text</param>
		/// <param name="width">Text area width (-1 for auto-size)</param>
		/// <param name="height">Text area height (-1 for auto-size)</param>
		/// <param name="text">Text to draw</param>
		/// <param name="baseColor">Text color</param>
		/// <param name="align">Text alignment (0=left, 1=right, 2=center)</param>
		void DrawPlainText(IBitmap bitmap, int x, int y, int width, int height, string text, IColor baseColor, int align = 0);

		/// <summary>
		/// Draws text with shadow effect using offset shadow rendering.
		/// Creates drop shadow by drawing text multiple times with color offset.
		/// </summary>
		/// <param name="bitmap">Target bitmap to draw on</param>
		/// <param name="x">X coordinate for text</param>
		/// <param name="y">Y coordinate for text</param>
		/// <param name="width">Text area width (-1 for auto-size)</param>
		/// <param name="height">Text area height (-1 for auto-size)</param>
		/// <param name="text">Text to draw</param>
		/// <param name="baseColor">Primary text color</param>
		/// <param name="shadowColor">Shadow color</param>
		/// <param name="align">Text alignment (0=left, 1=right, 2=center)</param>
		void DrawShadowText(IBitmap bitmap, int x, int y, int width, int height, string text, IColor baseColor, IColor shadowColor = null, int align = 0);

		/// <summary>
		/// Draws text with full outline border for maximum readability.
		/// Renders text with 8-directional outline for high contrast situations.
		/// </summary>
		/// <param name="bitmap">Target bitmap to draw on</param>
		/// <param name="x">X coordinate for text</param>
		/// <param name="y">Y coordinate for text</param>
		/// <param name="width">Text area width (-1 for auto-size)</param>
		/// <param name="height">Text area height (-1 for auto-size)</param>
		/// <param name="text">Text to draw</param>
		/// <param name="baseColor">Primary text color</param>
		/// <param name="shadowColor">Outline color</param>
		/// <param name="align">Text alignment (0=left, 1=right, 2=center)</param>
		void DrawOutlineText(IBitmap bitmap, int x, int y, int width, int height, string text, IColor baseColor, IColor shadowColor = null, int align = 0);

		/// <summary>
		/// Draws multiple text elements from position array with individual styling.
		/// Processes array of text commands with position, color, and alignment data.
		/// Each element: [text, x, y, alignment, baseColor, shadowColor, shadowType]
		/// </summary>
		/// <param name="bitmap">Target bitmap to draw on</param>
		/// <param name="textPositions">Array of text drawing commands</param>
		void DrawTextPositions(IBitmap bitmap, IList<ITextPosition> textPositions);

		/// <summary>
		/// Copies bitmap content with transparency support.
		/// Blits source bitmap onto destination with opacity control.
		/// </summary>
		/// <param name="destBitmap">Destination bitmap</param>
		/// <param name="sourceBitmap">Source bitmap to copy</param>
		/// <param name="x">X coordinate on destination</param>
		/// <param name="y">Y coordinate on destination</param>
		/// <param name="opacity">Transparency level (0-255)</param>
		void CopyBitmap(IBitmap destBitmap, IBitmap sourceBitmap, int x, int y, int opacity = 255);

		/// <summary>
		/// Draws multiple images from position array with source rectangle support.
		/// Processes array of image commands with position and clipping data.
		/// Each element: [imagePath, x, y, srcX, srcY, width, height]
		/// </summary>
		/// <param name="bitmap">Target bitmap to draw on</param>
		/// <param name="textpos">Array of image drawing commands</param>
		//void DrawImagePositions(IBitmap bitmap, IList<IImageDrawCommand> imagePositions);
		void DrawImagePositions(IBitmap bitmap, ITextPosition textpos);
	}

	/// <summary>
	/// Represents a formatted character with all styling and positioning information.
	/// Contains character data, fonts, colors, effects, and positioning for rendering.
	/// </summary>
	public interface IFormattedChar
	{
		string Character { get; }
		int X { get; }
		int Y { get; }
		int Width { get; }
		int Height { get; }
		bool IsGraphic { get; }
		bool IsBold { get; }
		bool IsItalic { get; }
		IColor BaseColor { get; }
		IColor ShadowColor { get; }
		bool IsUnderlined { get; }
		bool IsStrikeout { get; }
		string FontName { get; }
		int FontSize { get; }
		int Position { get; }
		IRect GraphicRect { get; }
		int OutlineType { get; }
	}

	/// <summary>
	/// Represents a text segment with line and position information.
	/// Used for text layout and line breaking calculations.
	/// </summary>
	public interface ITextSegment
	{
		string Text { get; }
		int X { get; }
		int Y { get; }
		int Width { get; }
		int Height { get; }
		int Line { get; }
		int Position { get; }
		int Column { get; }
		int Length { get; }
	}

	/// <summary>
	/// Represents a colored text chunk for rendering.
	/// Contains text content with associated color and positioning.
	/// </summary>
	public interface IColoredTextChunk
	{
		string Text { get; }
		int X { get; }
		int Y { get; }
		int Width { get; }
		int Height { get; }
		IColor Color { get; }
	}

	/// <summary>
	/// Represents a text drawing command with full styling options.
	/// Used for batch text rendering operations.
	/// </summary>
	public interface ITextDrawCommand
	{
		string Text { get; }
		int X { get; }
		int Y { get; }
		int Alignment { get; }
		IColor BaseColor { get; }
		IColor ShadowColor { get; }
		TextShadowType ShadowType { get; }
	}

	/// <summary>
	/// Represents an image drawing command with source rectangle.
	/// Used for batch image rendering operations.
	/// </summary>
	public interface IImageDrawCommand
	{
		string ImagePath { get; }
		int X { get; }
		int Y { get; }
		int SourceX { get; }
		int SourceY { get; }
		int Width { get; }
		int Height { get; }
	}

	/// <summary>
	/// Represents color value that can be either Color object or RGB array.
	/// Flexible color specification for formatting functions.
	/// </summary>
	public interface IColorValue
	{
		bool IsColorObject { get; }
		IColor AsColor { get; }
		int[] AsRgbArray { get; }
	}

	/// <summary>
	/// Represents a pair of colors for base and shadow text rendering.
	/// </summary>
	public interface IColorPair
	{
		IColor BaseColor { get; }
		IColor ShadowColor { get; }
	}

	/// <summary>
	/// Represents 2D dimensions with width and height.
	/// </summary>
	public interface IDimensions
	{
		int Width { get; set; }
		int Height { get; set; }
	}

	/// <summary>
	/// Text shadow rendering types.
	/// </summary>
	public enum TextShadowType
	{
		None,
		Shadow,
		Outline
	}
}