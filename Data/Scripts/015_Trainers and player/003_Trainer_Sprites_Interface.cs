using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Walking charset, for use in text entry screens and load game screen
	/// </summary>
	public interface ITrainerWalkingCharSprite : ISprite, IHaveUpdate, IDisposable {
		int anim_duration { get; set; }

		/// <summary>
		/// Default time in seconds for one animation cycle of a charset. The icon for a
		/// storage box is 0.4 instead (set manually).
		/// </summary>
		//public const float ANIMATION_DURATION = 0.5f;
		float ANIMATION_DURATION { get; }

		ITrainerWalkingCharSprite initialize(string charset, IViewport viewport = null);

		void dispose();

		string charset { set; }

		/// <summary>
		/// Used for the box icon in the naming screen.
		/// </summary>
		string altcharset { set; }

		void update_frame();

		void update();
	}
}