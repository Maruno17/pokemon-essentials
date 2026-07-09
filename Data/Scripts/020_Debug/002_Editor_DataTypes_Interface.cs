using System;
using System.Linq;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials//.Debug.Editor.DataTypes
{
	/// <summary>
	/// Base interface for all property types used in the editor.
	/// Provides core functionality for setting and formatting values.
	/// </summary>
	public interface IProperty
	{
		/// <summary>
		/// Sets a property value with user input.
		/// </summary>
		/// <param name="settingname">The name of the setting being modified</param>
		/// <param name="oldsetting">The current value of the setting</param>
		/// <returns>The new value for the setting</returns>
		object set(string settingname, object oldsetting);

		/// <summary>
		/// Formats a value for display in the editor.
		/// </summary>
		/// <param name="value">The value to format</param>
		/// <returns>A formatted string representation</returns>
		string format(object value);
	}

	/// <summary>
	/// Generic property interface with type-specific functionality.
	/// </summary>
	/// <typeparam name="TValue">The type of value this property handles</typeparam>
	public interface IProperty<TValue> : IProperty
	{
		/// <summary>
		/// Sets a property value with type-specific handling.
		/// </summary>
		/// <param name="settingname">The name of the setting</param>
		/// <param name="oldsetting">The current value</param>
		/// <returns>The new value</returns>
		TValue set(string settingname, TValue oldsetting);

		/// <summary>
		/// Formats a value for display.
		/// </summary>
		/// <param name="value">The value to format</param>
		/// <returns>Formatted string</returns>
		string format(TValue value);
	}

	/// <summary>
	/// Property interface that provides default values.
	/// </summary>
	/// <typeparam name="TValue">The type of value this property handles</typeparam>
	public interface IHasDefaultProperty<TValue> : IProperty<TValue>
	{
		/// <summary>
		/// Gets the default value for this property type.
		/// </summary>
		TValue defaultValue { get; }
	}

	/// <summary>
	/// Property type for undefined or unsupported properties.
	/// Displays a message indicating the property cannot be edited.
	/// </summary>
	public interface IUndefinedProperty : IProperty
	{
		/// <summary>
		/// Attempts to set an undefined property (always returns original value).
		/// </summary>
		/// <param name="settingname">The setting name</param>
		/// <param name="oldsetting">The current value</param>
		/// <returns>The unchanged original value</returns>
		object set(string settingname, object oldsetting);

		/// <summary>
		/// Formats the value using inspect representation.
		/// </summary>
		/// <param name="value">The value to format</param>
		/// <returns>Inspected string representation</returns>
		string format(object value);
	}

	/// <summary>
	/// Property type for read-only properties that cannot be modified.
	/// </summary>
	public interface IReadOnlyProperty : IProperty
	{
		/// <summary>
		/// Attempts to set a read-only property (always returns original value).
		/// </summary>
		/// <param name="settingname">The setting name</param>
		/// <param name="oldsetting">The current value</param>
		/// <returns>The unchanged original value</returns>
		object set(string settingname, object oldsetting);

		/// <summary>
		/// Formats the value using inspect representation.
		/// </summary>
		/// <param name="value">The value to format</param>
		/// <returns>Inspected string representation</returns>
		string format(object value);
	}

	/// <summary>
	/// Property type for unsigned integer values with digit limits.
	/// </summary>
	public interface IUIntProperty : IHasDefaultProperty<uint>
	{
		/// <summary>
		/// Initializes the property with maximum digit constraint.
		/// </summary>
		/// <param name="maxdigits">Maximum number of digits allowed</param>
		void initialize(uint maxdigits);

		/// <summary>
		/// Sets the unsigned integer value through user input.
		/// </summary>
		/// <param name="settingname">The setting name</param>
		/// <param name="oldsetting">The current value</param>
		/// <returns>The new unsigned integer value</returns>
		uint set(string settingname, uint oldsetting);

		/// <summary>
		/// Gets the default value (0).
		/// </summary>
		uint defaultValue { get; }

		/// <summary>
		/// Formats the value as string representation.
		/// </summary>
		/// <param name="value">The value to format</param>
		/// <returns>String representation of the value</returns>
		string format(uint value);
	}

	/// <summary>
	/// Property type for integer values with upper limit constraints.
	/// </summary>
	public interface ILimitProperty : IHasDefaultProperty<int>
	{
		/// <summary>
		/// Initializes the property with maximum value constraint.
		/// </summary>
		/// <param name="maxvalue">Maximum allowed value</param>
		void initialize(int maxvalue);

		/// <summary>
		/// Sets the integer value within the specified range (0 to max).
		/// </summary>
		/// <param name="settingname">The setting name</param>
		/// <param name="oldsetting">The current value</param>
		/// <returns>The new integer value</returns>
		int set(string settingname, int oldsetting);

		/// <summary>
		/// Gets the default value (0).
		/// </summary>
		int defaultValue { get; }

		/// <summary>
		/// Formats the value as string representation.
		/// </summary>
		/// <param name="value">The value to format</param>
		/// <returns>String representation of the value</returns>
		string format(int value);
	}

	/// <summary>
	/// Property type for nullable integer values with upper limit constraints.
	/// Allows cancellation to return null.
	/// </summary>
	public interface ILimitProperty2 : IHasDefaultProperty<int?>
	{
		/// <summary>
		/// Initializes the property with maximum value constraint.
		/// </summary>
		/// <param name="maxvalue">Maximum allowed value</param>
		void initialize(int maxvalue);

		/// <summary>
		/// Sets the nullable integer value within the specified range (0 to max).
		/// </summary>
		/// <param name="settingname">The setting name</param>
		/// <param name="oldsetting">The current value</param>
		/// <returns>The new integer value or null if cancelled</returns>
		int? set(string settingname, int? oldsetting);

		/// <summary>
		/// Gets the default value (null).
		/// </summary>
		int? defaultValue { get; }

		/// <summary>
		/// Formats the value as string representation or "-" for null.
		/// </summary>
		/// <param name="value">The value to format</param>
		/// <returns>String representation of the value or "-"</returns>
		string format(int? value);
	}

	/// <summary>
	/// Property type for non-zero integer values with upper limit constraints.
	/// Values must be between 1 and the maximum value.
	/// </summary>
	public interface INonzeroLimitProperty : IHasDefaultProperty<int>
	{
		/// <summary>
		/// Initializes the property with maximum value constraint.
		/// </summary>
		/// <param name="maxvalue">Maximum allowed value</param>
		void initialize(int maxvalue);

		/// <summary>
		/// Sets the non-zero integer value within the specified range (1 to max).
		/// </summary>
		/// <param name="settingname">The setting name</param>
		/// <param name="oldsetting">The current value</param>
		/// <returns>The new non-zero integer value</returns>
		int set(string settingname, int oldsetting);

		/// <summary>
		/// Gets the default value (1).
		/// </summary>
		int defaultValue { get; }

		/// <summary>
		/// Formats the value as string representation.
		/// </summary>
		/// <param name="value">The value to format</param>
		/// <returns>String representation of the value</returns>
		string format(int value);
	}

	/// <summary>
	/// Property type for boolean values using confirmation dialogs.
	/// </summary>
	public interface IBooleanProperty : IProperty<bool>
	{
		/// <summary>
		/// Sets the boolean value through confirmation dialog.
		/// </summary>
		/// <param name="settingname">The setting name</param>
		/// <param name="oldsetting">The current value</param>
		/// <returns>True if confirmed, false otherwise</returns>
		bool set(string settingname, bool oldsetting);

		/// <summary>
		/// Formats the boolean value as string representation.
		/// </summary>
		/// <param name="value">The value to format</param>
		/// <returns>String representation of the boolean</returns>
		string format(bool value);
	}

	/// <summary>
	/// Property type for nullable boolean values using command selection.
	/// </summary>
	public interface IBooleanProperty2 : IHasDefaultProperty<bool?>
	{
		/// <summary>
		/// Sets the nullable boolean value through command selection.
		/// </summary>
		/// <param name="settingname">The setting name</param>
		/// <param name="oldsetting">The current value</param>
		/// <returns>True, false, or null if cancelled</returns>
		bool? set(string settingname, bool? oldsetting);

		/// <summary>
		/// Gets the default value (null).
		/// </summary>
		bool? defaultValue { get; }

		/// <summary>
		/// Formats the nullable boolean value ("True", "False", or "-").
		/// </summary>
		/// <param name="value">The value to format</param>
		/// <returns>Formatted boolean representation</returns>
		string format(bool? value);
	}

	/// <summary>
	/// Property type for string values with free text input.
	/// </summary>
	public interface IStringProperty : IProperty<string>
	{
		/// <summary>
		/// Sets the string value through free text input.
		/// </summary>
		/// <param name="settingname">The setting name</param>
		/// <param name="oldsetting">The current value</param>
		/// <returns>The new string value</returns>
		string set(string settingname, string oldsetting);

		/// <summary>
		/// Formats the string value (returns as-is).
		/// </summary>
		/// <param name="value">The value to format</param>
		/// <returns>The string value unchanged</returns>
		string format(string value);
	}

	/// <summary>
	/// Property type for string values with character limit constraints.
	/// </summary>
	public interface ILimitStringProperty : IProperty<string>
	{
		/// <summary>
		/// Initializes the property with character limit.
		/// </summary>
		/// <param name="limit">Maximum number of characters allowed</param>
		void initialize(int limit);

		/// <summary>
		/// Sets the string value with length constraint.
		/// </summary>
		/// <param name="settingname">The setting name</param>
		/// <param name="oldsetting">The current value</param>
		/// <returns>The new string value</returns>
		string set(string settingname, string oldsetting);

		/// <summary>
		/// Formats the string value (returns as-is).
		/// </summary>
		/// <param name="value">The value to format</param>
		/// <returns>The string value unchanged</returns>
		string format(string value);
	}

	/// <summary>
	/// Property type for enumeration values with predefined options.
	/// </summary>
	public interface IEnumProperty : IHasDefaultProperty<int>
	{
		/// <summary>
		/// Initializes the property with enumeration values.
		/// </summary>
		/// <param name="values">Array of possible enumeration values</param>
		void initialize(IList<string> values);

		/// <summary>
		/// Sets the enumeration index through command selection.
		/// </summary>
		/// <param name="settingname">The setting name</param>
		/// <param name="oldsetting">The current index</param>
		/// <returns>The new enumeration index</returns>
		int set(string settingname, int oldsetting);

		/// <summary>
		/// Gets the default value (0).
		/// </summary>
		int defaultValue { get; }

		/// <summary>
		/// Formats the enumeration value by name or index.
		/// </summary>
		/// <param name="value">The enumeration index</param>
		/// <returns>The enumeration name or index representation</returns>
		string format(int value);
	}

	/// <summary>
	/// Property type for module-based enumeration values (unused).
	/// </summary>
	public interface IEnumProperty2 : IHasDefaultProperty<object>
	{
		/// <summary>
		/// Initializes the property with module reference.
		/// </summary>
		/// <param name="value">The module containing enumeration constants</param>
		void initialize(object value);

		/// <summary>
		/// Sets the enumeration value through module constant selection.
		/// </summary>
		/// <param name="settingname">The setting name</param>
		/// <param name="oldsetting">The current value</param>
		/// <returns>The new enumeration value</returns>
		object set(string settingname, object oldsetting);

		/// <summary>
		/// Gets the default value (null).
		/// </summary>
		object defaultValue { get; }

		/// <summary>
		/// Formats the enumeration value by constant name.
		/// </summary>
		/// <param name="value">The enumeration value</param>
		/// <returns>The constant name or "-" for null</returns>
		string format(object value);
	}

	/*
	/// <summary>
	/// Data type properties.
	/// </summary>
	public static partial class UndefinedProperty {
		public static void set(string _settingname, string oldsetting) {
			Message(_INTL("This property can't be edited here at this time."));
			return oldsetting;
		}

		public static void format(value) {
			return value.inspect;
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public static partial class ReadOnlyProperty {
		public static void set(string _settingname, string oldsetting) {
			Message(_INTL("This property cannot be edited."));
			return oldsetting;
		}

		public static void format(value) {
			return value.inspect;
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public partial class UIntProperty {
		public void initialize(uint maxdigits) {
			@maxdigits = maxdigits;
		}

		public void set(string settingname, string oldsetting) {
			ChooseNumberParams param = new ChooseNumberParams();
			param.setMaxDigits(@maxdigits);
			param.setDefaultValue(oldsetting || 0);
			return MessageChooseNumber(_INTL("Set the value for {1}.", settingname), param);
		}

		public uint defaultValue() {
			return 0;
		}

		public void format(value) {
			return value.inspect;
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public partial class LimitProperty {
		public void initialize(maxvalue) {
			@maxvalue = maxvalue;
		}

		public void set(string settingname, string oldsetting) {
			if (!oldsetting) oldsetting = 1;
			ChooseNumberParams param = new ChooseNumberParams();
			param.setRange(0, @maxvalue);
			param.setDefaultValue(oldsetting);
			return MessageChooseNumber(_INTL("Set the value for {1} (0-{2}).", settingname, @maxvalue), param);
		}

		public int defaultValue() {
			return 0;
		}

		public void format(value) {
			return value.inspect;
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public partial class LimitProperty2 {
		public void initialize(maxvalue) {
			@maxvalue = maxvalue;
		}

		public int set(string settingname, int? oldsetting) {
			if (oldsetting == null) oldsetting = 0;
			ChooseNumberParams param = new ChooseNumberParams();
			param.setRange(0, @maxvalue);
			param.setDefaultValue(oldsetting);
			param.setCancelValue(-1);
			int ret = MessageChooseNumber(_INTL("Set the value for {1} (0-{2}).", settingname, @maxvalue), param);
			return (ret >= 0) ? ret : null;
		}

		public int? defaultValue() {
			return null;
		}

		public string format(value) {
			return (value != null) ? value.inspect : "-";
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public partial class NonzeroLimitProperty {
		public void initialize(maxvalue) {
			@maxvalue = maxvalue;
		}

		public void set(string settingname, int? oldsetting) {
			if (oldsetting == null) oldsetting = 1;
			ChooseNumberParams param = new ChooseNumberParams();
			param.setRange(1, @maxvalue);
			param.setDefaultValue(oldsetting.Value);
			return MessageChooseNumber(_INTL("Set the value for {1}.", settingname), param);
		}

		public int defaultValue() {
			return 1;
		}

		public void format(value) {
			return value.inspect;
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public static partial class BooleanProperty {
		public static void set(string settingname, string _oldsetting) {
			return ConfirmMessage(_INTL("Enable the setting {1}?", settingname)) ? true : false;
		}

		public static void format(value) {
			return value.inspect;
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public static partial class BooleanProperty2 {
		public static bool? set(string _settingname, string _oldsetting) {
			int ret = ShowCommands(null, new {_INTL("True"), _INTL("False")}, -1);
			return (ret >= 0) ? (ret == 0) : (bool?)null;
		}

		public static bool? defaultValue() {
			return null;
		}

		public static void format(value) {
			if (value) return _INTL("True");
			return (value == null) ? "-" : _INTL("False");
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public static partial class StringProperty {
		public static void set(string settingname, string oldsetting) {
			return MessageFreeText(_INTL("Set the value for {1}.", settingname),
				(oldsetting != null) ? oldsetting : "", false, 250, Graphics.width);
		}

		public static void format(value) {
			return value;
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public partial class LimitStringProperty {
		public void initialize(limit) {
			@limit = limit;
		}

		public void format(value) {
			return value;
		}

		public void set(string settingname, string oldsetting) {
			return MessageFreeText(_INTL("Set the value for {1}.", settingname),
				(oldsetting != null) ? oldsetting : "", false, @limit);
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public partial class EnumProperty {
		public void initialize(values) {
			@values = values;
		}

		public int set(string settingname, int oldsetting) {
			IList<string> commands = new List<string>();
			foreach (var value in @values) { //.each do |value|
				commands.Add(value);
			}
			int cmd = Message(_INTL("Choose a value for {1}.", settingname), commands, -1);
			if (cmd < 0) return oldsetting;
			return cmd;
		}

		public int defaultValue() {
			return 0;
		}

		public void format(value) {
			return (value) ? @values[value] : value.inspect;
		}
	}

	//===============================================================================
	// Unused
	//===============================================================================
	public partial class EnumProperty2 {
		public void initialize(value) {
			@module = value;
		}

		public void set(string settingname, oldsetting) {
			commands = new List<string>();
			(0..@module.maxValue).each do |i|
				commands.Add(getConstantName(@module, i));
			}
			cmd = Message(_INTL("Choose a value for {1}.", settingname), commands, -1, null, oldsetting);
			if (cmd < 0) return oldsetting;
			return cmd;
		}

		public void defaultValue() {
			return null;
		}

		public void format(value) {
			return (value) ? getConstantName(@module, value) : "-";
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public partial class StringListProperty {
		public static void set(_setting_name, old_setting) {
			if (!old_setting) old_setting = new List<string>();
			real_cmds = new List<string>();
			real_cmds.Add(new {_INTL("[ADD VALUE]"), -1});
			for (int i = old_setting.length; i < old_setting.length; i++) { //for 'old_setting.length' times do => |i|
				real_cmds.Add(new {old_setting[i], 0});
			}
			// Edit list
			cmdwin = ListWindow(new List<string>(), 200);
			oldsel = null;
			ret = old_setting;
			cmd = 0;
			commands = new List<string>();
			do_refresh = true;
			do { //loop;
				if (do_refresh) {
					commands = new List<string>();
					for (int i = 0; i < real_cmds; i++) { //.each_with_index do |entry, i|
						commands.Add(entry[0]);
						if (oldsel && entry[0] == oldsel) cmd = i;
					}
				}
				do_refresh = false;
				oldsel = null;
				cmd = Commands2(cmdwin, commands, -1, cmd, true);
				if (cmd >= 0) {   // Chose a value
					entry = real_cmds[cmd];
					if (entry[1] == -1) {   // Add new value
						new_value = MessageFreeText(_INTL("Enter the new value."),
																					"", false, 250, Graphics.width);
						if (!string.IsNullOrEmpty(new_value)) {
							if (real_cmds.any(e => e[0] == new_value)) {
								oldsel = new_value;   // Already have value; just move cursor to it
							} else {
								real_cmds.Add(new {new_value, 0});
							}
							do_refresh = true;
						}
					} else {   // Edit value
						switch (Message("\\ts[]" + _INTL("Do what with this value?"),) {
													new {_INTL("Edit"), _INTL("Delete"), _INTL("Cancel")}, 3);
							case 0:   // Edit
								new_value = MessageFreeText(_INTL("Enter the new value."),
																							entry[0], false, 250, Graphics.width);
								if (!string.IsNullOrEmpty(new_value)) {
									if (real_cmds.any(e => e[0] == new_value)) {   // Already have value; delete this one
										real_cmds.delete_at(cmd);
										cmd = (int)Math.Min(cmd, real_cmds.length - 1);
									} else {   // Change value
										entry[0] = new_value;
									}
									oldsel = new_value;
									do_refresh = true;
								}
								break;
							case 1:   // Delete
								real_cmds.delete_at(cmd);
								cmd = (int)Math.Min(cmd, real_cmds.length - 1);
								do_refresh = true;
								break;
						}
					}
				} else {   // Cancel/quit
					switch (Message(_INTL("Keep changes?"), new {_INTL("Yes"), _INTL("No"), _INTL("Cancel")}, 3)) {
						case 0:
							for (int i = real_cmds.length; i < real_cmds.length; i++) { //for 'real_cmds.length' times do => |i|
								real_cmds[i] = (real_cmds[i][1] == -1) ? null : real_cmds[i][0];
							}
							real_cmds.compact!;
							ret = real_cmds;
							//break //break out of loop
							break;
						case 1:
							//break //break out of loop
							break;
					}
				}
			} while (true);
			cmdwin.dispose();
			return ret;
		}

		public static void defaultValue() {
			return [];
		}

		public static void format(value) {
			return (value) ? value.join(",") : "";
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public partial class GameDataProperty {
		public void initialize(value) {
			if (!GameData.const_defined(value.to_sym)) raise _INTL("Couldn't find class {1} in module GameData.", value.ToString());
			@module = GameData.const_get(value.to_sym);
		}

		public void set(string settingname, oldsetting) {
			commands = new List<string>();
			i = 0;
			foreach (var data in @module) { //.each do |data|
				if (data.respond_to("id_number")) {
					commands.Add(new {data.id_number, data.name, data.id});
				} else {
					commands.Add(new {i, data.name, data.id});
				}
				i += 1;
			}
			return ChooseList(commands, oldsetting, oldsetting, -1);
		}

		public void defaultValue() {
			return null;
		}

		public void format(value) {
			return (value != null && @module.exists(value)) ? @module.get(value).real_name : "-";
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public static partial class BGMProperty {
		public static void set(string settingname, oldsetting) {
			chosenmap = ListScreen(settingname, new MusicFileLister(true, oldsetting));
			return (chosenmap && chosenmap != "") ? File.basename(chosenmap, ".*") : oldsetting;
		}

		public static void format(value) {
			return value;
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public static partial class MEProperty {
		public static void set(string settingname, oldsetting) {
			chosenmap = ListScreen(settingname, new MusicFileLister(false, oldsetting));
			return (chosenmap && chosenmap != "") ? File.basename(chosenmap, ".*") : oldsetting;
		}

		public static void format(value) {
			return value;
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public static partial class WindowskinProperty {
		public static void set(string settingname, oldsetting) {
			chosenmap = ListScreen(settingname, new GraphicsLister("Graphics/Windowskins/", oldsetting));
			return (chosenmap && chosenmap != "") ? File.basename(chosenmap, ".*") : oldsetting;
		}

		public static void format(value) {
			return value;
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public static partial class TrainerTypeProperty {
		public static void set(string settingname, oldsetting) {
			chosenmap = ListScreen(settingname, new TrainerTypeLister(0, false));
			return chosenmap || oldsetting;
		}

		public static void format(value) {
			return (value != null && GameData.TrainerType.exists(value)) ? GameData.TrainerType.get(value).real_name : "-";
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public static partial class SpeciesProperty {
		public static void set(_settingname, oldsetting) {
			ret = ChooseSpeciesList(oldsetting || null);
			return ret || oldsetting;
		}

		public static void defaultValue() {
			return null;
		}

		public static void format(value) {
			return (value != null && GameData.Species.exists(value)) ? GameData.Species.get(value).real_name : "-";
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public partial class SpeciesFormProperty {
		public void initialize(default_value) {
			@default_value = default_value;
		}

		public void set(_settingname, oldsetting) {
			ret = ChooseSpeciesFormList(oldsetting || null);
			return ret || oldsetting;
		}

		public void defaultValue() {
			return @default_value;
		}

		public void format(value) {
			if (value != null && GameData.Species.exists(value)) {
				species_data = GameData.Species.get(value);
				if (species_data.form > 0) {
					return string.Format("{0}_{0}", species_data.real_name, species_data.form);
				} else {
					return species_data.real_name;
				}
			}
			return "-";
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public static partial class TypeProperty {
		public static void set(_settingname, oldsetting) {
			ret = ChooseTypeList(oldsetting || null);
			return ret || oldsetting;
		}

		public static void defaultValue() {
			return null;
		}

		public static void format(value) {
			return (value != null && GameData.Type.exists(value)) ? GameData.Type.get(value).real_name : "-";
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public static partial class TypesProperty {
		public static void set(_settingname, oldsetting) {
			ret = oldsetting.Clone();
			index = 0;
			do { //loop;
				cmds = new List<string>();
				2.times { |i| cmds.Add(_INTL("Type {1} : {2}", i, ret[i] || "-")) };
				index = Message(_INTL("Set the type(s) for this species."), cmds, -1);
				if (index < 0) break;
				new_type = ChooseTypeList(ret[index]);
				if (new_type) ret[index] = new_type;
				ret.uniq!;
				ret.compact!;
			} while (true);
			if (ret != oldsetting.compact && ConfirmMessage(_INTL("Apply changes?"))) return ret;
			return oldsetting;
		}

		public static void defaultValue() {
			return [:NORMAL];
		}

		public static void format(value) {
			types = value.compact;
			types.each_with_index((type, i) => types[i] = GameData.Type.try_get(types[i]).real_name || "-");
			return types.join(",");
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public static partial class MoveProperty {
		public static void set(_settingname, oldsetting) {
			ret = ChooseMoveList(oldsetting || null);
			return ret || oldsetting;
		}

		public static void defaultValue() {
			return null;
		}

		public static void format(value) {
			return (value != null && GameData.Move.exists(value)) ? GameData.Move.get(value).real_name : "-";
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public partial class MovePropertyForSpecies {
		public void initialize(pokemondata) {
			@pokemondata = pokemondata;
		}

		public void set(_settingname, oldsetting) {
			ret = ChooseMoveListForSpecies(@pokemondata[0], oldsetting || null);
			return ret || oldsetting;
		}

		public void defaultValue() {
			return null;
		}

		public void format(value) {
			return (value != null && GameData.Move.exists(value)) ? GameData.Move.get(value).real_name : "-";
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public static partial class GenderProperty {
		public static void set(_settingname, _oldsetting) {
			ret = ShowCommands(null, new {_INTL("Male"), _INTL("Female")}, -1);
			return (ret >= 0) ? ret : null;
		}

		public static void defaultValue() {
			return null;
		}

		public static void format(value) {
			if (!value) return "-";
			if (value == 0) return _INTL("Male");
			if (value == 1) return _INTL("Female");
			return "-";
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public static partial class ItemProperty {
		public static void set(_settingname, oldsetting) {
			ret = ChooseItemList((oldsetting) ? oldsetting : null);
			return ret || oldsetting;
		}

		public static void defaultValue() {
			return null;
		}

		public static void format(value) {
			return (value != null && GameData.Item.exists(value)) ? GameData.Item.get(value).real_name : "-";
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public partial class IVsProperty {
		public void initialize(limit) {
			@limit = limit;
		}

		public void set(string settingname, oldsetting) {
			if (!oldsetting) oldsetting = new List<string>();
			properties = new List<string>();
			data = new List<string>();
			stat_ids = new List<string>();
			foreach (var s in GameData.Stat) { //GameData.Stat.each_main do => |s|
				if (!oldsetting[s.s_order]) oldsetting[s.s_order] = 0;
				properties[s.s_order] = new {s.name, new LimitProperty2(@limit),
					_INTL("Individual values for the Pokémon's {1} stat (0-{2}).", s.name, @limit)};
				data[s.s_order] = oldsetting[s.id];
				stat_ids[s.s_order] = s.id;
			}
			PropertyList(settingname, data, properties, false);
			ret = new List<string>();
			stat_ids.each_with_index((s, i) => ret[s] = data[i] || 0);
			return ret;
		}

		public void defaultValue() {
			return null;
		}

		public void format(value) {
			if (!value) return "-";
			array = new List<string>();
			foreach (var s in GameData.Stat) { //GameData.Stat.each_main do => |s|
				if (s.s_order < 0) continue;
				array[s.s_order] = value[s.id] || 0;
			}
			return array.join(",");
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public partial class EVsProperty {
		public void initialize(limit) {
			@limit = limit;
		}

		public void set(string settingname, oldsetting) {
			if (!oldsetting) oldsetting = new List<string>();
			properties = new List<string>();
			data = new List<string>();
			stat_ids = new List<string>();
			foreach (var s in GameData.Stat) { //GameData.Stat.each_main do => |s|
				if (!oldsetting[s.s_order]) oldsetting[s.s_order] = 0;
				properties[s.s_order] = new {s.name, new LimitProperty2(@limit),
																	_INTL("Effort values for the Pokémon's {1} stat (0-{2}).", s.name, @limit)};
				data[s.s_order] = oldsetting[s.id];
				stat_ids[s.s_order] = s.id;
			}
			do { //loop;
				PropertyList(settingname, data, properties, false);
				evtotal = 0;
				data.each(value => { if (value) evtotal += value; });
				if (evtotal <= Pokemon.EV_LIMIT) break;
				Message(_INTL("Total EVs ({1}) are greater than allowed ({2}). Please reduce them.", evtotal, Pokemon.EV_LIMIT));
			}while (true);
			ret = new List<string>();
			stat_ids.each_with_index((s, i) => ret[s] = data[i] || 0);
			return ret;
		}

		public void defaultValue() {
			return null;
		}

		public void format(value) {
			if (!value) return "-";
			array = new List<string>();
			foreach (var s in GameData.Stat) { //GameData.Stat.each_main do => |s|
				if (s.s_order < 0) continue;
				array[s.s_order] = value[s.id] || 0;
			}
			return array.join(",");
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public partial class BallProperty {
		public void initialize(pokemondata) {
			@pokemondata = pokemondata;
		}

		public void set(_settingname, oldsetting) {
			return ChooseBallList(oldsetting);
		}

		public void defaultValue() {
			return null;
		}

		public void format(value) {
			return (value) ? GameData.Item.get(value).name : "-";
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public static partial class CharacterProperty {
		public static void set(string settingname, oldsetting) {
			chosenmap = ListScreen(settingname, new GraphicsLister("Graphics/Characters/", oldsetting));
			return (chosenmap && chosenmap != "") ? File.basename(chosenmap, ".*") : oldsetting;
		}

		public static void format(value) {
			return value;
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public static partial class MapSizeProperty {
		public static void set(string settingname, oldsetting) {
			if (!oldsetting) oldsetting = new {0, ""};
			properties = new {
				new {_INTL("Width"),         new NonzeroLimitProperty(30), _INTL("The width of this map in Region Map squares.")},
				new {_INTL("Valid Squares"), StringProperty,               _INTL("A series of 1s and 0s marking which squares are part of this map (1=part, 0=not part).")}
			};
			PropertyList(settingname, oldsetting, properties, false);
			return oldsetting;
		}

		public static void format(value) {
			return value.inspect;
		}
	}

	/// <summary>
	/// Property type for string list collections with editing capabilities.
	/// </summary>
	public interface IStringListProperty : IHasDefaultProperty<IList<string>>
	{
		/// <summary>
		/// Sets the string list through interactive editing interface.
		/// </summary>
		/// <param name="settingname">The setting name</param>
		/// <param name="oldsetting">The current string list</param>
		/// <returns>The modified string list</returns>
		IList<string> set(string settingname, IList<string> oldsetting);

		/// <summary>
		/// Gets the default value (empty list).
		/// </summary>
		IList<string> defaultValue { get; }

		/// <summary>
		/// Formats the string list as comma-separated values.
		/// </summary>
		/// <param name="value">The string list to format</param>
		/// <returns>Comma-separated string representation</returns>
		string format(IList<string> value);
	}

	/// <summary>
	/// Property type for GameData-based selections.
	/// </summary>
	public interface IGameDataProperty : IHasDefaultProperty<object>
	{
		/// <summary>
		/// Initializes the property with GameData module reference.
		/// </summary>
		/// <param name="value">The GameData module name</param>
		void initialize(string value);

		/// <summary>
		/// Sets the GameData item through selection interface.
		/// </summary>
		/// <param name="settingname">The setting name</param>
		/// <param name="oldsetting">The current GameData item ID</param>
		/// <returns>The selected GameData item ID</returns>
		object set(string settingname, object oldsetting);

		/// <summary>
		/// Gets the default value (null).
		/// </summary>
		object defaultValue { get; }

		/// <summary>
		/// Formats the GameData item by name or "-" for null.
		/// </summary>
		/// <param name="value">The GameData item ID</param>
		/// <returns>The item's real name or "-"</returns>
		string format(object value);
	}

	/// <summary>
	/// Property type for BGM (Background Music) file selection.
	/// </summary>
	public interface IBGMProperty : IProperty<string>
	{
		/// <summary>
		/// Sets the BGM file through file browser interface.
		/// </summary>
		/// <param name="settingname">The setting name</param>
		/// <param name="oldsetting">The current BGM filename</param>
		/// <returns>The selected BGM filename</returns>
		string set(string settingname, string oldsetting);

		/// <summary>
		/// Formats the BGM filename (returns as-is).
		/// </summary>
		/// <param name="value">The filename to format</param>
		/// <returns>The filename unchanged</returns>
		string format(string value);
	}

	/// <summary>
	/// Property type for ME (Music Effect) file selection.
	/// </summary>
	public interface IMEProperty : IProperty<string>
	{
		/// <summary>
		/// Sets the ME file through file browser interface.
		/// </summary>
		/// <param name="settingname">The setting name</param>
		/// <param name="oldsetting">The current ME filename</param>
		/// <returns>The selected ME filename</returns>
		string set(string settingname, string oldsetting);

		/// <summary>
		/// Formats the ME filename (returns as-is).
		/// </summary>
		/// <param name="value">The filename to format</param>
		/// <returns>The filename unchanged</returns>
		string format(string value);
	}

	/// <summary>
	/// Property type for windowskin graphics file selection.
	/// </summary>
	public interface IWindowskinProperty : IProperty<string>
	{
		/// <summary>
		/// Sets the windowskin file through graphics browser interface.
		/// </summary>
		/// <param name="settingname">The setting name</param>
		/// <param name="oldsetting">The current windowskin filename</param>
		/// <returns>The selected windowskin filename</returns>
		string set(string settingname, string oldsetting);

		/// <summary>
		/// Formats the windowskin filename (returns as-is).
		/// </summary>
		/// <param name="value">The filename to format</param>
		/// <returns>The filename unchanged</returns>
		string format(string value);
	}

	/// <summary>
	/// Property type for trainer type selection.
	/// </summary>
	public interface ITrainerTypeProperty : IProperty<object>
	{
		/// <summary>
		/// Sets the trainer type through selection interface.
		/// </summary>
		/// <param name="settingname">The setting name</param>
		/// <param name="oldsetting">The current trainer type ID</param>
		/// <returns>The selected trainer type ID</returns>
		object set(string settingname, object oldsetting);

		/// <summary>
		/// Formats the trainer type by name or "-" for null.
		/// </summary>
		/// <param name="value">The trainer type ID</param>
		/// <returns>The trainer type's real name or "-"</returns>
		string format(object value);
	}

	/// <summary>
	/// Property type for Pokemon species selection.
	/// </summary>
	public interface ISpeciesProperty : IHasDefaultProperty<object>
	{
		/// <summary>
		/// Sets the species through selection interface.
		/// </summary>
		/// <param name="settingname">The setting name</param>
		/// <param name="oldsetting">The current species ID</param>
		/// <returns>The selected species ID</returns>
		object set(string settingname, object oldsetting);

		/// <summary>
		/// Gets the default value (null).
		/// </summary>
		object defaultValue { get; }

		/// <summary>
		/// Formats the species by name or "-" for null.
		/// </summary>
		/// <param name="value">The species ID</param>
		/// <returns>The species' real name or "-"</returns>
		string format(object value);
	}

	/// <summary>
	/// Property type for Pokemon species with form selection.
	/// </summary>
	public interface ISpeciesFormProperty : IHasDefaultProperty<object>
	{
		/// <summary>
		/// Initializes the property with default species.
		/// </summary>
		/// <param name="defaultValue">The default species to use</param>
		void initialize(object defaultValue);

		/// <summary>
		/// Sets the species/form through selection interface.
		/// </summary>
		/// <param name="settingname">The setting name</param>
		/// <param name="oldsetting">The current species/form ID</param>
		/// <returns>The selected species/form ID</returns>
		object set(string settingname, object oldsetting);

		/// <summary>
		/// Gets the default species value.
		/// </summary>
		object defaultValue { get; }

		/// <summary>
		/// Formats the species/form with form suffix if applicable.
		/// </summary>
		/// <param name="value">The species/form ID</param>
		/// <returns>The species name with form suffix or "-"</returns>
		string format(object value);
	}

	public void chooseMapPoint(object map, bool rgnmap = false) {
		viewport = new Viewport(0, 0, Graphics.width, Graphics.height);
		viewport.z = 99999;
		title = Window_UnformattedTextPokemon.newWithSize(
			_INTL("Click a point on the map."), 0, Graphics.height - 64, Graphics.width, 64, viewport
		);
		title.z = 2;
		if (rgnmap) {
			sprite = new RegionMapSprite(map, viewport);
		} else {
			sprite = new MapSprite(map, viewport);
		}
		sprite.z = 2;
		ret = null;
		do { //loop;
			Graphics.update();
			Input.update();
			xy = sprite.getXY;
			if (xy) {
				ret = xy;
				break;
			}
			if (Input.trigger(Input.BACK)) {
				ret = null;
				break;
			}
		} while (true);
		sprite.dispose();
		title.dispose();
		return ret;
	}

	//===============================================================================
	//
	//===============================================================================
	public static partial class MapCoordsProperty {
		public static void set(string settingname, oldsetting) {
			chosenmap = ListScreen(settingname, new MapLister((oldsetting) ? oldsetting[0] : 0));
			if (chosenmap >= 0) {
				mappoint = chooseMapPoint(chosenmap);
				return (mappoint) ? new {chosenmap, mappoint[0], mappoint[1]} : oldsetting;
			} else {
				return oldsetting;
			}
		}

		public static void format(value) {
			return value.inspect;
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public static partial class MapCoordsFacingProperty {
		public static void set(string settingname, oldsetting) {
			chosenmap = ListScreen(settingname, new MapLister((oldsetting) ? oldsetting[0] : 0));
			if (chosenmap >= 0) {
				mappoint = chooseMapPoint(chosenmap);
				if (mappoint) {
					facing = Message(_INTL("Choose the direction to face in."),
														new {_INTL("Down"), _INTL("Left"), _INTL("Right"), _INTL("Up")}, -1);
					return (facing >= 0) ? new {chosenmap, mappoint[0], mappoint[1], new {2, 4, 6, 8}[facing]} : oldsetting;
				} else {
					return oldsetting;
				}
			} else {
				return oldsetting;
			}
		}

		public static void format(value) {
			return value.inspect;
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public static partial class RegionMapCoordsProperty {
		public static void set(_settingname, oldsetting) {
			regions = this.getMapNameList;
			selregion = -1;
			switch (regions.length) {
				case 0:
					Message(_INTL("No region maps are defined."));
					return oldsetting;
					break;
				case 1:
					selregion = regions[0][0];
					break;
				default:
					cmds = new List<string>();
					regions.each(region => cmds.Add(region[1]));
					selcmd = Message(_INTL("Choose a region map."), cmds, -1);
					if (selcmd < 0) return oldsetting;
					selregion = regions[selcmd][0];
					break;
			}
			mappoint = chooseMapPoint(selregion, true);
			return (mappoint) ? new {selregion, mappoint[0], mappoint[1]} : oldsetting;
		}

		public static void format(value) {
			return value.inspect;
		}

		public static void getMapNameList() {
			ret = new List<string>();
			GameData.TownMap.each { |town_map| ret.Add(new {town_map.id, town_map.name}) };
			return ret;
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public static partial class WeatherEffectProperty {
		public static void set(_settingname, oldsetting) {
			if (!oldsetting) oldsetting = new {:None, 100};
			options = new List<string>();
			ids = new List<string>();
			default = 0;
			foreach (var w in GameData.Weather) { //'GameData.Weather.each' do => |w|
				if (w.id == oldsetting[0]) default = ids.length;
				options.Add(w.real_name);
				ids.Add(w.id);
			}
			cmd = Message(_INTL("Choose a weather effect."), options, -1, null, default);
			if (cmd < 0 || ids[cmd] == :None) return null;
			param = new ChooseNumberParams();
			param.setRange(0, 100);
			param.setDefaultValue(oldsetting[1]);
			number = MessageChooseNumber(_INTL("Set the probability of the weather."), param);
			return new {ids[cmd], number};
		}

		public static void format(value) {
			return (value) ? GameData.Weather.get(value[0]).real_name + $",{value[1]}" : "-";
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public static partial class MapProperty {
		public static void set(string settingname, oldsetting) {
			chosenmap = ListScreen(settingname, new MapLister(oldsetting || 0));
			return (chosenmap > 0) ? chosenmap : oldsetting;
		}

		public static void defaultValue() {
			return null;
		}

		public static void format(value) {
			return value.inspect;
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public static partial class ItemNameProperty {
		public static void set(string settingname, oldsetting) {
			return MessageFreeText(_INTL("Set the value for {1}.", settingname),
															(oldsetting) ? oldsetting : "", false, 30)
		}

		public static void defaultValue() {
			return "???";
		}

		public static void format(value) {
			return value;
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public static partial class PocketProperty {
		public static void set(_settingname, oldsetting) {
			commands = Settings.bag_pocket_names.Clone();
			cmd = Message(_INTL("Choose a pocket for this item."), commands, -1);
			return (cmd >= 0) ? cmd + 1 : oldsetting;
		}

		public static void defaultValue() {
			return 1;
		}

		public static void format(value) {
			if (value == 0) return _INTL("No Pocket");
			return (value) ? Settings.bag_pocket_names[value - 1] : value.inspect;
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public static partial class BaseStatsProperty {
		public static void set(string settingname, oldsetting) {
			if (!oldsetting) return oldsetting;
			properties = new List<string>();
			data = new List<string>();
			stat_ids = new List<string>();
			foreach (var s in GameData.Stat) { //GameData.Stat.each_main do => |s|
				if (s.s_order < 0) continue;
				properties[s.s_order] = new {_INTL("Base {1}", s.name), new NonzeroLimitProperty(255),
																	_INTL("Base {1} stat of the Pokémon.", s.name)};
				data[s.s_order] = oldsetting[s.s_order] || 10;
				stat_ids[s.s_order] = s.id;
			}
			if (PropertyList(settingname, data, properties, true)) {
				ret = new List<string>();
				stat_ids.each_with_index((s, i) => ret[i] = data[i] || 10);
				oldsetting = ret;
			}
			return oldsetting;
		}

		public static void defaultValue() {
			ret = new List<string>();
			GameData.Stat.each_main(s => { if (s.s_order >= 0) ret[s.s_order] = 10; });
			return ret;
		}

		public static void format(value) {
			return value.join(",");
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public static partial class EffortValuesProperty {
		public static void set(string settingname, oldsetting) {
			if (!oldsetting) return oldsetting;
			properties = new List<string>();
			data = new List<string>();
			stat_ids = new List<string>();
			foreach (var s in GameData.Stat) { //GameData.Stat.each_main do => |s|
				if (s.s_order < 0) continue;
				properties[s.s_order] = new {_INTL("{1} EVs", s.name), new LimitProperty(255),
																	_INTL("Number of {1} Effort Value points gained from the Pokémon.", s.name)};
				data[s.s_order] = 0;
				oldsetting.each(ev => { if (ev[0] == s.id) data[s.s_order] = ev[1]; });
				stat_ids[s.s_order] = s.id;
			}
			if (PropertyList(settingname, data, properties, true)) {
				ret = new List<string>();
				for (int i = 0; i < stat_ids; i++) { //.each_with_index do |s, i|
					index = GameData.Stat.get(s).s_order;
					if (data[index] > 0) ret.Add(new {s, data[index]});
				}
				oldsetting = ret;
			}
			return oldsetting;
		}

		public static void defaultValue() {
			return [];
		}

		public static void format(value) {
			if (!value) return "";
			ret = "";
			for (int i = 0; i < value; i++) { //.each_with_index do |val, i|
				if (i > 0) ret += ",";
				ret += GameData.Stat.get(val[0]).real_name_brief + "," + val[1].ToString();
			}
			return ret;
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public static partial class AbilityProperty {
		public static void set(_settingname, oldsetting) {
			ret = ChooseAbilityList((oldsetting) ? oldsetting : null);
			return ret || oldsetting;
		}

		public static void defaultValue() {
			return null;
		}

		public static void format(value) {
			return (value != null && GameData.Ability.exists(value)) ? GameData.Ability.get(value).real_name : "-";
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public partial class GameDataPoolProperty {
		public void initialize(game_data, allow_multiple = true, auto_sort = false) {
			if (!GameData.const_defined(game_data.to_sym)) {
				Debug.LogError(_INTL("Couldn't find class {1} in module GameData.", game_data.ToString()));
				//throw new ArgumentException(_INTL("Couldn't find class {1} in module GameData.", game_data.ToString()));
			}
			@game_data = game_data;
			@game_data_module = GameData.const_get(game_data.to_sym);
			@allow_multiple = allow_multiple;
			@auto_sort = auto_sort;   // Alphabetically
		}

		public void set(setting_name, old_setting) {
			ret = old_setting;
			if (!@allow_multiple) old_setting.uniq!;
			if (@auto_sort) old_setting.sort!;
			// Get all values already in the pool
			values = new List<string>();
			values.Add(new {null, _INTL("[ADD VALUE]")});   // Value ID, name
			foreach (var value in old_setting) { //'old_setting.each' do => |value|
				values.Add(new {value, @game_data_module.get(value).real_name});
			}
			// Set things up
			command_window = ListWindow(new List<string>(), 200);
			cmd = new {0, 0};   // new {input type, list index} (input type: 0=select, 1=swap up, 2=swap down)
			commands = new List<string>();
			need_refresh = true;
			// Edit value pool
			do { //loop;
				if (need_refresh) {
					if (@auto_sort) {
						values.sort! { |a, b| (a[0] == null) ? -1 : b[0].null() ? 1 : a[1] <=> b[1] };
					}
					commands = values.map(entry => entry[1]);
					need_refresh = false;
				}
				// Choose a value
				cmd = Commands3(command_window, commands, -1, cmd[1], true);
				switch (cmd[0]) {   // 0=selected/cancelled, 1=pressed Action+Up, 2=pressed Action+Down
					case 1:   // Swap value up
						if (cmd[1] > 0 && cmd[1] < values.length - 1) {
							values[cmd[1] + 1], values[cmd[1]] = values[cmd[1]], values[cmd[1] + 1];
							need_refresh = true;
						}
						break;
					case 2:   // Swap value down
						if (cmd[1] > 1) {
							values[cmd[1] - 1], values[cmd[1]] = values[cmd[1]], values[cmd[1] - 1];
							need_refresh = true;
						}
						break;
					case 0:
						if (cmd[1] >= 0) {   // Chose an entry
							entry = values[cmd[1]];
							if (entry[0] == null) {   // Add new value
								new_value = ChooseFromGameDataList(@game_data);
								if (new_value) {
									if (!@allow_multiple && values.any(val => val[0] == new_value)) {
										cmd[1] = values.index(val => val[0] == new_value);
										continue;
									}
									values.Add(new {new_value, @game_data_module.get(new_value).real_name});
									need_refresh = true;
								}
							} else {   // Edit existing value
								switch (Message("\\ts[]" + _INTL("Do what with this value?"),) {
															new {_INTL("Change value"), _INTL("Delete"), _INTL("Cancel")}, 3);
									case 0:   // Change value
										new_value = ChooseFromGameDataList(@game_data, entry[0]);
										if (new_value != null && new_value != entry[0]) {
											if (!@allow_multiple && values.any(val => val[0] == new_value)) {
												values.delete_at(cmd[1]);
												cmd[1] = values.index(val => val[0] == new_value);
												need_refresh = true;
												continue;
											}
											entry[0] = new_value;
											entry[1] = @game_data_module.get(new_value).real_name;
											if (@auto_sort) {
												values.sort! { |a, b| a[1] <=> b[1] };
												cmd[1] = values.index(val => val[0] == new_value);
											}
											need_refresh = true;
										}
										break;
									case 1:   // Delete
										values.delete_at(cmd[1]);
										cmd[1] = (int)Math.Min(cmd[1], values.length - 1);
										need_refresh = true;
										break;
								}
							}
						} else {   // Cancel/quit
							switch (Message(_INTL("Apply changes?"),) {
														new {_INTL("Yes"), _INTL("No"), _INTL("Cancel")}, 3);
								case 0:
									values.shift();   // Remove the "add value" option
									for (int i = values.length; i < values.length; i++) { //for 'values.length' times do => |i|
										values[i] = values[i][0];
									}
									values.compact!;
									ret = values;
									//break
									break;
								case 1:
									//break
									break;
							}
						}
						break;
				}
			} while (true);
			command_window.dispose();
			return ret;
		}

		public void defaultValue() {
			return [];
		}

		public void format(value) {
			return value.map(val => @game_data_module.get(val).real_name).join(",");
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public partial class EggMovesProperty : GameDataPoolProperty {
		public override void initialize() {
			base.initialize(:Move, false, true);
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public partial class EggGroupsProperty : GameDataPoolProperty {
		public override void initialize() {
			base.initialize(:EggGroup, false, false);
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public partial class AbilitiesProperty : GameDataPoolProperty {
		public override void initialize() {
			base.initialize(:Ability, false, false);
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public static partial class LevelUpMovesProperty {
		public static void set(_settingname, oldsetting) {
			// Get all moves in move pool
			realcmds = new List<string>();
			realcmds.Add(new {-1, null, -1, "-"});   // Level, move ID, index in this list, name
			for (int i = oldsetting.length; i < oldsetting.length; i++) { //for 'oldsetting.length' times do => |i|
				realcmds.Add(new {oldsetting[i][0], oldsetting[i][1], i, GameData.Move.get(oldsetting[i][1]).real_name});
			}
			// Edit move pool
			cmdwin = ListWindow(new List<string>(), 200);
			oldsel = -1;
			ret = oldsetting;
			cmd = new {0, 0};
			commands = new List<string>();
			refreshlist = true;
			do { //loop;
				if (refreshlist) {
					realcmds.sort! { |a, b| (a[0] == b[0]) ? a[2] <=> b[2] : a[0] <=> b[0] };
					commands = new List<string>();
					for (int i = 0; i < realcmds; i++) { //.each_with_index do |entry, i|
						if (entry[0] == -1) {
							commands.Add(_INTL("[ADD MOVE]"));
						} else {
							commands.Add(_INTL("{1}: {2}", entry[0], entry[3]));
						}
						if (oldsel >= 0 && entry[2] == oldsel) cmd[1] = i;
					}
				}
				refreshlist = false;
				oldsel = -1;
				cmd = Commands3(cmdwin, commands, -1, cmd[1], true);
				switch (cmd[0]) {
					case 1:   // Swap move up (if both moves have the same level)
						if (cmd[1] < realcmds.length - 1 && realcmds[cmd[1]][0] == realcmds[cmd[1] + 1][0]) {
							realcmds[cmd[1] + 1][2], realcmds[cmd[1]][2] = realcmds[cmd[1]][2], realcmds[cmd[1] + 1][2];
							refreshlist = true;
						}
						break;
					case 2:   // Swap move down (if both moves have the same level)
						if (cmd[1] > 0 && realcmds[cmd[1]][0] == realcmds[cmd[1] - 1][0]) {
							realcmds[cmd[1] - 1][2], realcmds[cmd[1]][2] = realcmds[cmd[1]][2], realcmds[cmd[1] - 1][2];
							refreshlist = true;
						}
						break;
					case 0:
						if (cmd[1] >= 0) {   // Chose an entry
							entry = realcmds[cmd[1]];
							if (entry[0] == -1) {   // Add new move
								param = new ChooseNumberParams();
								param.setRange(0, GameData.GrowthRate.max_level);
								param.setDefaultValue(1);
								param.setCancelValue(-1);
								newlevel = MessageChooseNumber(_INTL("Choose a level."), param);
								if (newlevel >= 0) {
									newmove = ChooseMoveList;
									if (newmove) {
										havemove = -1;
										foreach (var e in realcmds) { //'realcmds.each' do => |e|
											if (e[0] == newlevel && e[1] == newmove) havemove = e[2];
										}
										if (havemove >= 0) {
											oldsel = havemove;
										} else {
											maxid = -1;
											realcmds.each(e => maxid = (int)Math.Max(maxid, e[2]));
											realcmds.Add(new {newlevel, newmove, maxid + 1, GameData.Move.get(newmove).real_name});
										}
										refreshlist = true;
									}
								}
							} else {   // Edit existing move
								switch (Message("\\ts[]" + _INTL("Do what with this move?"),) {
															new {_INTL("Change level"), _INTL("Change move"), _INTL("Delete"), _INTL("Cancel")}, 4);
									case 0:   // Change level
										param = new ChooseNumberParams();
										param.setRange(0, GameData.GrowthRate.max_level);
										param.setDefaultValue(entry[0]);
										newlevel = MessageChooseNumber(_INTL("Choose a new level."), param);
										if (newlevel >= 0 && newlevel != entry[0]) {
											havemove = -1;
											foreach (var e in realcmds) { //'realcmds.each' do => |e|
												if (e[0] == newlevel && e[1] == entry[1]) havemove = e[2];
											}
											if (havemove >= 0) {   // Move already known at new level; delete this move
												realcmds.delete_at(cmd[1]);
												oldsel = havemove;
											} else {   // Apply the new level
												entry[0] = newlevel;
												oldsel = entry[2];
											}
											refreshlist = true;
										}
										break;
									case 1:   // Change move
										newmove = ChooseMoveList(entry[1]);
										if (newmove && newmove != entry[1]) {
											havemove = -1;
											foreach (var e in realcmds) { //'realcmds.each' do => |e|
												if (e[0] == entry[0] && e[1] == newmove) havemove = e[2];
											}
											if (havemove >= 0) {   // New move already known at level; delete this move
												realcmds.delete_at(cmd[1]);
												cmd[1] = (int)Math.Min(cmd[1], realcmds.length - 1);
												oldsel = havemove;
											} else {   // Apply the new move
												entry[1] = newmove;
												entry[3] = GameData.Move.get(newmove).real_name;
												oldsel = entry[2];
											}
											refreshlist = true;
										}
										break;
									case 2:   // Delete
										realcmds.delete_at(cmd[1]);
										cmd[1] = (int)Math.Min(cmd[1], realcmds.length - 1);
										refreshlist = true;
										break;
								}
							}
						} else {   // Cancel/quit
							switch (Message(_INTL("Save changes?"),) {
														new {_INTL("Yes"), _INTL("No"), _INTL("Cancel")}, 3);
								case 0:
									realcmds.shift();
									for (int i = realcmds.length; i < realcmds.length; i++) { //for 'realcmds.length' times do => |i|
										realcmds[i].pop;   // Remove name
										realcmds[i].pop;   // Remove index in this list
									}
									realcmds.compact!;
									ret = realcmds;
									//break
									break;
								case 1:
									//break
									break;
							}
						}
						break;
				}
			} while (true);
			cmdwin.dispose();
			return ret;
		}

		public static void defaultValue() {
			return [];
		}

		public static void format(value) {
			ret = "";
			for (int i = value.length; i < value.length; i++) { //for 'value.length' times do => |i|
				if (i > 0) ret << ",";
				ret << string.Format("{0},{0}", value[i][0], GameData.Move.get(value[i][1]).real_name);
			}
			return ret;
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public partial class EvolutionsProperty {
		public void initialize() {
			@methods = new List<string>();
			@evo_ids = new List<string>();
			foreach (var e in GameData.Evolution) { //GameData.Evolution.each_alphabetically do => |e|
				@methods.Add(e.real_name);
				@evo_ids.Add(e.id);
			}
		}

		public void edit_parameter(evo_method, value = null) {
			param_type = GameData.Evolution.get(evo_method).parameter;
			if (param_type == null) return null;
			ret = value;
			switch (param_type) {
				case :Item:
					ret = ChooseItemList(value);
					break;
				case :Move:
					ret = ChooseMoveList(value);
					break;
				case :Species:
					ret = ChooseSpeciesList(value);
					break;
				case :Type:
					ret = ChooseTypeList(value);
					break;
				case :Ability:
					ret = ChooseAbilityList(value);
					break;
				case String:
					ret = MessageFreeText(_INTL("Enter a value."), ret || "", false, 250, Graphics.width);
					ret.strip!;
					if (ret.empty()) ret = null;
					break;
				default:
					param = new ChooseNumberParams();
					param.setRange(0, 65_535);
					if (value) param.setDefaultValue(value.ToInt());
					param.setCancelValue(-1);
					ret = MessageChooseNumber(_INTL("Choose a parameter."), param);
					if (ret < 0) ret = null;
					break;
			}
			return (ret) ? ret.ToString() : null;
		}

		public void set(_settingname, oldsetting) {
			ret = oldsetting;
			cmdwin = ListWindow(new List<string>());
			commands = new List<string>();
			realcmds = new List<string>();
			realcmds.Add(new {-1, 0, 0, -1});
			for (int i = oldsetting.length; i < oldsetting.length; i++) { //for 'oldsetting.length' times do => |i|
				realcmds.Add(new {oldsetting[i][0], oldsetting[i][1], oldsetting[i][2], i});
			}
			refreshlist = true;
			oldsel = -1;
			cmd = new {0, 0};
			do { //loop;
				if (refreshlist) {
					realcmds.sort! { |a, b| a[3] <=> b[3] };
					commands = new List<string>();
					for (int i = realcmds.length; i < realcmds.length; i++) { //for 'realcmds.length' times do => |i|
						if (realcmds[i][3] < 0) {
							commands.Add(_INTL("[ADD EVOLUTION]"));
						} else {
							level = realcmds[i][2];
							evo_method_data = GameData.Evolution.get(realcmds[i][1]);
							param_type = evo_method_data.parameter;
							if (param_type == null) {
								commands.Add(_INTL("{1}: {2}",
																		GameData.Species.get(realcmds[i][0]).name, evo_method_data.real_name));
							} else {
								if ((param_type is Symbol) && !GameData.const_defined(param_type)) {
									level = getConstantName(param_type, level);
								}
								if (!level || ((level is String) && level.empty())) level = "???";
								commands.Add(_INTL("{1}: {2}, {3}",
																		GameData.Species.get(realcmds[i][0]).name, evo_method_data.real_name, level.ToString()));
							}
						}
						if (oldsel >= 0 && realcmds[i][3] == oldsel) cmd[1] = i;
					}
				}
				refreshlist = false;
				oldsel = -1;
				cmd = Commands3(cmdwin, commands, -1, cmd[1], true);
				switch (cmd[0]) {
					case 1:   // Swap evolution up
						if (cmd[1] > 0 && cmd[1] < realcmds.length - 1) {
							realcmds[cmd[1] + 1][3], realcmds[cmd[1]][3] = realcmds[cmd[1]][3], realcmds[cmd[1] + 1][3];
							refreshlist = true;
						}
						break;
					case 2:   // Swap evolution down
						if (cmd[1] > 1) {
							realcmds[cmd[1] - 1][3], realcmds[cmd[1]][3] = realcmds[cmd[1]][3], realcmds[cmd[1] - 1][3];
							refreshlist = true;
						}
						break;
					case 0:
						if (cmd[1] >= 0) {
							entry = realcmds[cmd[1]];
							if (entry[3] == -1) {   // Add new evolution path
								Message(_INTL("Choose an evolved form, method and parameter."));
								newspecies = ChooseSpeciesList;
								if (newspecies) {
									newmethodindex = Message(_INTL("Choose an evolution method."), @methods, -1);
									if (newmethodindex >= 0) {
										newmethod = @evo_ids[newmethodindex];
										newparam = edit_parameter(newmethod);
										if (newparam || GameData.Evolution.get(newmethod).parameter == null) {
											existing_evo = -1;
											for (int i = realcmds.length; i < realcmds.length; i++) { //for 'realcmds.length' times do => |i|
												if (realcmds[i][0] == newspecies &&
																												realcmds[i][1] == newmethod &&
																												realcmds[i][2] == newparam) existing_evo = realcmds[i][3];
											}
											if (existing_evo >= 0) {
												oldsel = existing_evo;
											} else {
												maxid = -1;
												realcmds.each(i => maxid = (int)Math.Max(maxid, i[3]));
												realcmds.Add(new {newspecies, newmethod, newparam, maxid + 1});
												oldsel = maxid + 1;
											}
											refreshlist = true;
										}
									}
								}
							} else {   // Edit evolution
								switch (Message("\\ts[]" + _INTL("Do what with this evolution?"),) {
															new {_INTL("Change species"), _INTL("Change method"),
																_INTL("Change parameter"), _INTL("Delete"), _INTL("Cancel")}, 5);
									case 0:   // Change species
										newspecies = ChooseSpeciesList(entry[0]);
										if (newspecies) {
											existing_evo = -1;
											for (int i = realcmds.length; i < realcmds.length; i++) { //for 'realcmds.length' times do => |i|
												if (realcmds[i][0] == newspecies &&
																												realcmds[i][1] == entry[1] &&
																												realcmds[i][2] == entry[2]) existing_evo = realcmds[i][3];
											}
											if (existing_evo >= 0) {
												realcmds.delete_at(cmd[1]);
												oldsel = existing_evo;
											} else {
												entry[0] = newspecies;
												oldsel = entry[3];
											}
											refreshlist = true;
										}
										break;
									case 1:   // Change method
										default_index = 0;
										@evo_ids.each_with_index((evo, i) => { if (evo == entry[1]) default_index = i; });
										newmethodindex = Message(_INTL("Choose an evolution method."), @methods, -1, null, default_index);
										if (newmethodindex >= 0) {
											newmethod = @evo_ids[newmethodindex];
											existing_evo = -1;
											for (int i = realcmds.length; i < realcmds.length; i++) { //for 'realcmds.length' times do => |i|
												if (realcmds[i][0] == entry[0] &&
																												realcmds[i][1] == newmethod &&
																												realcmds[i][2] == entry[2]) existing_evo = realcmds[i][3];
											}
											if (existing_evo >= 0) {
												realcmds.delete_at(cmd[1]);
												oldsel = existing_evo;
											} else if (newmethod != entry[1]) {
												entry[1] = newmethod;
												entry[2] = 0;
												oldsel = entry[3];
											}
											refreshlist = true;
										}
										break;
									case 2:   // Change parameter
										if (GameData.Evolution.get(entry[1]).parameter == null) {
											Message(_INTL("This evolution method doesn't use a parameter."));
										} else {
											newparam = edit_parameter(entry[1], entry[2]);
											if (newparam) {
												existing_evo = -1;
												for (int i = realcmds.length; i < realcmds.length; i++) { //for 'realcmds.length' times do => |i|
													if (realcmds[i][0] == entry[0] &&
																													realcmds[i][1] == entry[1] &&
																													realcmds[i][2] == newparam) existing_evo = realcmds[i][3];
												}
												if (existing_evo >= 0) {
													realcmds.delete_at(cmd[1]);
													oldsel = existing_evo;
												} else {
													entry[2] = newparam;
													oldsel = entry[3];
												}
												refreshlist = true;
											}
										}
										break;
									case 3:   // Delete
										realcmds.delete_at(cmd[1]);
										cmd[1] = (int)Math.Min(cmd[1], realcmds.length - 1);
										refreshlist = true;
									}
									break;
							}
						} else {
							cmd2 = Message(_INTL("Save changes?"),
															new {_INTL("Yes"), _INTL("No"), _INTL("Cancel")}, 3);
							if (new []{0, 1}.Contains(cmd2)) {
								if (cmd2 == 0) {
									for (int i = realcmds.length; i < realcmds.length; i++) { //for 'realcmds.length' times do => |i|
										realcmds[i].pop;
										if (realcmds[i][0] == -1) realcmds[i] = null;
									}
									realcmds.compact!;
									ret = realcmds;
								}
								break;
							}
						}
						break;
				}
			} while (true);
			cmdwin.dispose();
			return ret;
		}

		public void defaultValue() {
			return [];
		}

		public void format(value) {
			if (!value) return "";
			ret = "";
			for (int i = value.length; i < value.length; i++) { //for 'value.length' times do => |i|
				if (i > 0) ret << ",";
				ret << (value[i][0].ToString() + ",");
				ret << (value[i][1].ToString() + ",");
				if (value[i][2]) ret << value[i][2].ToString();
			}
			return ret;
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public static partial class EncounterSlotProperty {
		public static void set(setting_name, data) {
			max_level = GameData.GrowthRate.max_level;
			if (!data) {
				data = new {20, null, 5, 5};
				foreach (var species_data in GameData.Species) { //'GameData.Species.each' do => |species_data|
					data[1] = species_data.species;
					break;
				}
			}
			if (!data[3]) data[3] = data[2];
			properties = new {
				new {_INTL("Probability"),   new NonzeroLimitProperty(999),       _INTL("Relative probability of choosing this slot.")},
				new {_INTL("Species"),       new SpeciesFormProperty(data[1]),    _INTL("A Pokémon species/form.")},
				new {_INTL("Minimum level"), new NonzeroLimitProperty(max_level), _INTL("Minimum level of this species (1-{1}).", max_level)},
				new {_INTL("Maximum level"), new NonzeroLimitProperty(max_level), _INTL("Maximum level of this species (1-{1}).", max_level)}
			}
			PropertyList(setting_name, data, properties, false);
			if (data[2] > data[3]) {
				data[3], data[2] = data[2], data[3];
			}
			return data;
		}

		public static void defaultValue() {
			return null;
		}

		public static void format(value) {
			if (!value) return "-";
			species_data = GameData.Species.get(value[1]);
			if (species_data.form > 0) {
				if (value[2] == value[3]) {
					return string.Format("{0}, {0}_{0} (Lv.{0})", value[0],
												species_data.real_name, species_data.form, value[2]);
				}
				return string.Format("{0}, {0}_{0} (Lv.{0}-{0})", value[0],
											species_data.real_name, species_data.form, value[2], value[3]);
			}
			if (value[2] == value[3]) {
				return string.Format("{0}, {0} (Lv.{0})", value[0], species_data.real_name, value[2]);
			}
			return string.Format("{0}, {0} (Lv.{0}-{0})", value[0], species_data.real_name, value[2], value[3]);
		}
	}

	//===============================================================================
	// Core property editor script.
	//===============================================================================
	public void PropertyList(title, data, properties, saveprompt = false) {
		viewport = new Viewport(0, 0, Graphics.width, Graphics.height);
		viewport.z = 99999;
		list = ListWindow(new List<string>(), Graphics.width / 2);
		list.viewport = viewport;
		list.z        = 2;
		title = Window_UnformattedTextPokemon.newWithSize(
			title, list.width, 0, Graphics.width / 2, 64, viewport
		);
		title.z = 2;
		desc = Window_UnformattedTextPokemon.newWithSize(
			"", list.width, title.height, Graphics.width / 2, Graphics.height - title.height, viewport
		);
		desc.z = 2;
		selectedmap = -1;
		retval = null;
		commands = new List<string>();
		for (int i = properties.length; i < properties.length; i++) { //for 'properties.length' times do => |i|
			propobj = properties[i][1];
			commands.Add(string.Format("{0}={0}", properties[i][0], propobj.format(data[i])));
		}
		list.commands = commands;
		list.index    = 0;
		do { //loop;
			do { //loop;
				Graphics.update();
				Input.update();
				list.update();
				desc.update();
				if (list.index != selectedmap) {
					desc.text = properties[list.index][2];
					selectedmap = list.index;
				}
				if (Input.trigger(Input.ACTION)) {
					propobj = properties[selectedmap][1];
					if (propobj != ReadOnlyProperty && !(propobj is ReadOnlyProperty) &&
						ConfirmMessage(_INTL("Reset the setting {1}?", properties[selectedmap][0]))) {
						if (propobj.respond_to("defaultValue")) {
							data[selectedmap] = propobj.defaultValue;
						} else {
							data[selectedmap] = null;
						}
					}
					commands.clear();
					for (int i = properties.length; i < properties.length; i++) { //for 'properties.length' times do => |i|
						propobj = properties[i][1];
						commands.Add(string.Format("{0}={0}", properties[i][0], propobj.format(data[i])));
					}
					list.commands = commands;
				} else if (Input.trigger(Input.BACK)) {
					selectedmap = -1;
					break;
				} else if (Input.trigger(Input.USE)) {
					propobj = properties[selectedmap][1];
					oldsetting = data[selectedmap];
					newsetting = propobj.set(properties[selectedmap][0], oldsetting);
					data[selectedmap] = newsetting;
					commands.clear();
					for (int i = properties.length; i < properties.length; i++) { //for 'properties.length' times do => |i|
						propobj = properties[i][1];
						commands.Add(string.Format("{0}={0}", properties[i][0], propobj.format(data[i])));
					}
					list.commands = commands;
					break;
				}
			} while (true);
			if (selectedmap == -1 && saveprompt) {
				cmd = Message(_INTL("Save changes?"),
												new {_INTL("Yes"), _INTL("No"), _INTL("Cancel")}, 3);
				if (cmd == 2) {
					selectedmap = list.index;
				} else {
					retval = (cmd == 0);
				}
			}
			unless (selectedmap != -1) break;
		} while (true);
		title.dispose();
		list.dispose();
		desc.dispose();
		Input.update();
		return retval;
	/// <summary>
	/// Core property editor functionality for interactive property lists.
	/// </summary>
	public interface IPropertyList
	{
		/// <summary>
		/// Displays an interactive property list editor.
		/// </summary>
		/// <param name="title">The title of the property editor</param>
		/// <param name="data">The array of property values</param>
		/// <param name="properties">The array of property definitions</param>
		/// <param name="saveprompt">Whether to show save confirmation</param>
		/// <returns>True if changes were saved, false otherwise</returns>
		bool PropertyList(string title, object[] data, object[] properties, bool saveprompt = false);
	}

	/// <summary>
	/// Utility interface for map point selection.
	/// </summary>
	public interface IMapPointChooser
	{
		/// <summary>
		/// Allows user to choose a point on a map through click interface.
		/// </summary>
		/// <param name="map">The map to display</param>
		/// <param name="rgnmap">Whether this is a region map</param>
		/// <returns>The selected coordinates or null if cancelled</returns>
		object chooseMapPoint(object map, bool rgnmap = false);
	}

	/// <summary>
	/// Property type for map coordinates selection.
	/// </summary>
	public interface IMapCoordsProperty : IProperty<object>
	{
		/// <summary>
		/// Sets map coordinates through map and point selection.
		/// </summary>
		/// <param name="settingname">The setting name</param>
		/// <param name="oldsetting">The current coordinates array</param>
		/// <returns>The selected coordinates [map, x, y]</returns>
		object set(string settingname, object oldsetting);

		/// <summary>
		/// Formats the coordinates as inspected representation.
		/// </summary>
		/// <param name="value">The coordinates to format</param>
		/// <returns>String representation of coordinates</returns>
		string format(object value);
	}

	/// <summary>
	/// Property type for map coordinates with facing direction.
	/// </summary>
	public interface IMapCoordsFacingProperty : IProperty<object>
	{
		/// <summary>
		/// Sets map coordinates and facing direction.
		/// </summary>
		/// <param name="settingname">The setting name</param>
		/// <param name="oldsetting">The current coordinates with facing</param>
		/// <returns>The selected coordinates [map, x, y, facing]</returns>
		object set(string settingname, object oldsetting);

		/// <summary>
		/// Formats the coordinates with facing as inspected representation.
		/// </summary>
		/// <param name="value">The coordinates with facing to format</param>
		/// <returns>String representation of coordinates and facing</returns>
		string format(object value);
	}

	/// <summary>
	/// Property type for region map coordinates selection.
	/// </summary>
	public interface IRegionMapCoordsProperty : IProperty<object>
	{
		/// <summary>
		/// Sets region map coordinates through region and point selection.
		/// </summary>
		/// <param name="settingname">The setting name</param>
		/// <param name="oldsetting">The current region coordinates</param>
		/// <returns>The selected coordinates [region, x, y]</returns>
		object set(string settingname, object oldsetting);

		/// <summary>
		/// Formats the region coordinates as inspected representation.
		/// </summary>
		/// <param name="value">The region coordinates to format</param>
		/// <returns>String representation of region coordinates</returns>
		string format(object value);

		/// <summary>
		/// Gets the list of available region maps.
		/// </summary>
		/// <returns>Array of [id, name] pairs for region maps</returns>
		object getMapNameList();
	}

	/// <summary>
	/// Property type for weather effect selection with probability.
	/// </summary>
	public interface IWeatherEffectProperty : IProperty<object>
	{
		/// <summary>
		/// Sets weather effect and probability through selection interface.
		/// </summary>
		/// <param name="settingname">The setting name</param>
		/// <param name="oldsetting">The current weather effect and probability</param>
		/// <returns>The selected weather [effect_id, probability] or null</returns>
		object set(string settingname, object oldsetting);

		/// <summary>
		/// Formats the weather effect with probability or "-" for none.
		/// </summary>
		/// <param name="value">The weather effect and probability to format</param>
		/// <returns>Formatted weather description</returns>
		string format(object value);
	}

	/// <summary>
	/// Property type for encounter slot data with species and levels.
	/// </summary>
	public interface IEncounterSlotProperty : IHasDefaultProperty<object>
	{
		/// <summary>
		/// Sets encounter slot data through property editor.
		/// </summary>
		/// <param name="settingName">The setting name</param>
		/// <param name="data">The current encounter slot data</param>
		/// <returns>The modified encounter slot data [probability, species, min_level, max_level]</returns>
		object set(string settingName, object data);

		/// <summary>
		/// Gets the default value (null).
		/// </summary>
		object defaultValue { get; }

		/// <summary>
		/// Formats the encounter slot as species with levels and probability.
		/// </summary>
		/// <param name="value">The encounter slot data to format</param>
		/// <returns>Formatted encounter description or "-"</returns>
		string format(object value);
	}

	/*
	/// <summary>
	/// Data type properties.
	/// </summary>
	public static partial class UndefinedProperty {
		public static void set(string _settingname, string oldsetting) {
			Message(_INTL("This property can't be edited here at this time."));
			return oldsetting;
		}

		public static void format(value) {
			return value.inspect;
		}
	}

	//===============================================================================
	//
	//===============================================================================
	public static partial class ReadOnlyProperty {
		public static void set(string _settingname, string oldsetting) {
			Message(_INTL("This property cannot be edited."));
			return oldsetting;
		}

		public static void format(value) {
			return value.inspect;
		}
	}
	*/
}