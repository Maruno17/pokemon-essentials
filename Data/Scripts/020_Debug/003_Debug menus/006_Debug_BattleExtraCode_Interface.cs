using System;

namespace PokemonEssentials
{
	/// <summary>
	/// Provides extended battle debugging functionality and specialized testing tools.
	/// Contains advanced debug commands for complex battle scenarios, edge case testing, and comprehensive battle system debugging.
	/// </summary>
	public interface IDebugBattleExtraCode
	{
		// This interface would contain extended battle debugging functionality
		// including advanced testing scenarios, edge case debugging,
		// and specialized battle system analysis tools.

		//public BATTLER_EFFECTS
	}

	public interface ISpriteWindow_DebugBattleFieldEffects : IWindow_DrawableCommand
	{
		//void initialize(viewport, battle, variables, variables_data);

		IRect drawCursor(int index, IRect rect);

		//void dispose();

		// to be implemented by derived classes
		int itemCount();

		void shadowtext(float x, float y, float width, float height, string text, int align = 0, int colors = 0);

		// to be implemented by derived classes
		void drawItem(int index, int count, IRect rect);
	}

	//public interface IBattleDebugSetEffects : IDisposable
	//{
	//	IBattleDebugSetEffects initialize(IBattle battle, int mode, int side = 0);
	//
	//	//void dispose();
	//
	//	void choose_number(int @default, int min, int max);
	//
	//	void choose_battler(IPokemon @default);
	//
	//	void update_input_for_boolean(effect, variable_data);
	//
	//	void update_input_for_integer(effect, @default, variable_data);
	//
	//	void update_input_for_battler_index(effect, variable_data);
	//
	//	void update_input_for_move(effect, variable_data);
	//
	//	void update_input_for_item(effect, variable_data);
	//
	//	void update();
	//}
}