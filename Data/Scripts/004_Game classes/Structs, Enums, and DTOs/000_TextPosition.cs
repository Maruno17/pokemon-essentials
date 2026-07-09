using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	public interface ITextPosition
	{
		/// <summary>
		/// Text to draw
		/// </summary>
		string Text { get; set; }
		/// <summary>
		/// X coordinate
		/// </summary>
		float X { get; set; }
		/// <summary>
		/// Y coordinate
		/// </summary>
		float Y { get; set; }
		/// <summary>
		/// If true or 1, the text is right aligned. If 2, the text is centered.
		/// Otherwise, the text is left aligned.
		/// </summary>
		/// <remarks>
		/// Is one of :left (or false or 0), :right (or true or 1) or
		/// :center (or 2). If anything else, the text is left aligned.
		/// </remarks>
		bool? LeftAligned { get; set; }
		/// <summary>
		/// Base color
		/// </summary>
		IColor Base { get; set; }
		/// <summary>
		/// Shadow color. If null, there is no shadow.
		/// </summary>
		/// <remarks>
		/// If :outline (or true or 1), the text has a full outline. If :none (or the
		/// shadow color is null), there is no shadow. Otherwise, the text has a shadow.
		/// </remarks>
		IColor Shadow { get; set; }
	}

	public struct TextPosition : ITextPosition
	{
		/// <summary>
		/// Text to draw
		/// </summary>
		public string Text { get; set; }
		/// <summary>
		/// X coordinate
		/// </summary>
		public float X { get; set; }
		/// <summary>
		/// Y coordinate
		/// </summary>
		public float Y { get; set; }
		/// <summary>
		/// If false, the text is right aligned. If null, the text is centered.
		/// Otherwise, the text is left aligned.
		/// </summary>
		/// <remarks>
		/// Is one of :left (or false or 0), :right (or true or 1) or
		/// :center (or 2). If anything else, the text is left aligned.
		/// </remarks>
		public bool? LeftAligned { get; set; }
		/// <summary>
		/// Base color
		/// </summary>
		public IColor Base { get; set; }
		/// <summary>
		/// Shadow color. If null, there is no shadow.
		/// </summary>
		/// <remarks>
		/// If :outline (or true or 1), the text has a full outline. If :none (or the
		/// shadow color is null), there is no shadow. Otherwise, the text has a shadow.
		/// </remarks>
		public IColor Shadow { get; set; }

		/// <summary>
		/// </summary>
		/// <param name="text">Text to draw</param>
		/// <param name="x"></param>
		/// <param name="y"></param>
		/// <param name="leftAligned">
		/// If 1, the text is right aligned. If 2, the text is centered.
		/// Otherwise, the text is left aligned.
		/// </param>
		/// <param name="base_"></param>
		/// <param name="shadow"></param>
		public TextPosition(string text, float x, float y, int leftAligned, IColor base_, IColor shadow)
		{
			Text = text;
			X = x;
			Y = y;
			LeftAligned = leftAligned == 1 ? false : (leftAligned == 2 ? (bool?)null : true);
			Base = base_;
			Shadow = shadow;
		}

		/// <summary>
		/// </summary>
		/// <param name="text">Text to draw</param>
		/// <param name="x"></param>
		/// <param name="y"></param>
		/// <param name="leftAligned">
		/// If false, the text is right aligned. If null, the text is centered.
		/// Otherwise, the text is left aligned.
		/// </param>
		/// <param name="base_"></param>
		/// <param name="shadow"></param>
		public TextPosition(string text, float x, float y, bool? leftAligned, IColor base_, IColor shadow)
		{
			Text = text;
			X = x;
			Y = y;
			LeftAligned = leftAligned;
			Base = base_;
			Shadow = shadow;
		}

		public TextPosition(string name, float x, float y, float srcx, float srcy, float width, float height)
		{
			Text = name;
			X = x;
			Y = y;
			LeftAligned = null;
			Base = null;
			Shadow = null;
		}
	}
}