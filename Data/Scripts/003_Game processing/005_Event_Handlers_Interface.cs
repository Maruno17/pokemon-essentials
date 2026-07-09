using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Defines an event that procedures can subscribe to.
	/// This interface provides methods for managing event handlers and triggering events.
	/// </summary>
	public interface IEvent
	{
		IEvent initialize();

		/// <summary>
		/// Sets an event handler for this event and removes all other event handlers.
		/// </summary>
		/// <param name="method">The event handler method to set.</param>
		void set(Delegate method);

		/// <summary>
		/// Removes an event handler procedure from the event.
		/// </summary>
		/// <param name="other">The event handler to remove.</param>
		/// <returns>The current event instance.</returns>
		IEvent Remove(Delegate other);

		/// <summary>
		/// Adds an event handler procedure to the event.
		/// </summary>
		/// <param name="other">The event handler to add.</param>
		/// <returns>The current event instance.</returns>
		IEvent Add(Delegate other);

		/// <summary>
		/// Clears the event of all event handlers.
		/// </summary>
		void clear();

		/// <summary>
		/// Triggers the event and calls all its event handlers.
		/// </summary>
		/// <param name="args">The arguments to pass to the event handlers.</param>
		void trigger(params object[] args);

		/// <summary>
		/// Triggers the event and calls all its event handlers with direct argument passing.
		/// </summary>
		/// <param name="args">The arguments to pass to the event handlers.</param>
		void trigger2(params object[] args);
	}

	/// <summary>
	/// Defines an event where each registered handler has a name (symbol) for individual reference.
	/// </summary>
	public interface INamedEvent
	{
		INamedEvent initialize();

		/// <summary>
		/// Adds an event handler procedure to the event with a specific key.
		/// </summary>
		/// <param name="key">The key to associate with the handler.</param>
		/// <param name="proc">The event handler procedure.</param>
		void add(string key, Delegate proc);

		/// <summary>
		/// Removes an event handler procedure from the event by its key.
		/// </summary>
		/// <param name="key">The key of the handler to remove.</param>
		void remove(string key);

		/// <summary>
		/// Clears the event of all event handlers.
		/// </summary>
		void clear();

		/// <summary>
		/// Triggers the event and calls all its event handlers.
		/// </summary>
		/// <param name="args">The arguments to pass to the event handlers.</param>
		void trigger(params object[] args);
	}

	/// <summary>
	/// A class that stores code that can be triggered, with each piece of code having an associated ID.
	/// </summary>
	public interface IHandlerHash
	{
		IHandlerHash initialize();

		/// <summary>
		/// Gets the handler associated with the specified ID.
		/// </summary>
		/// <param name="id">The ID to look up.</param>
		/// <returns>The handler associated with the ID, or null if not found.</returns>
		Delegate this[int id] { get; }

		/// <summary>
		/// Adds a handler for the specified ID.
		/// </summary>
		/// <param name="id">The ID to associate with the handler.</param>
		/// <param name="handler">The handler to add.</param>
		//void add(object id, Delegate handler = null);
		void add(int id, object handler = null);

		/// <summary>
		/// Copies a handler from one ID to multiple destination IDs.
		/// </summary>
		/// <param name="src">The source ID.</param>
		/// <param name="dests">The destination IDs.</param>
		void copy(int src, params object[] dests);

		/// <summary>
		/// Removes the handler associated with the specified key.
		/// </summary>
		/// <param name="key">The key of the handler to remove.</param>
		void remove(int key);

		/// <summary>
		/// Clears all handlers.
		/// </summary>
		void clear();

		/// <summary>
		/// Gets all keys in the handler hash.
		/// </summary>
		/// <returns>A collection of all keys.</returns>
		IEnumerable<int> keys();

		/// <summary>
		/// Triggers the handler associated with the specified ID.
		/// </summary>
		/// <param name="id">The ID of the handler to trigger.</param>
		/// <param name="args">The arguments to pass to the handler.</param>
		/// <returns>The result of the handler execution.</returns>
		object trigger(int id, params object[] args);
	}

	/// <summary>
	/// A specialized version of HandlerHash that only deals with symbol IDs.
	/// </summary>
	public interface IHandlerHashSymbol : IHandlerHash
	{
		/// <summary>
		/// Adds a handler with a condition for when it should be used.
		/// </summary>
		/// <param name="sym">The symbol to associate with the handler.</param>
		/// <param name="conditionProc">The condition that determines when the handler should be used.</param>
		/// <param name="handler">The handler to add.</param>
		void addIf(int sym, Func<string, bool> conditionProc, Delegate handler = null);
	}

	/// <summary>
	/// A specialized version of HandlerHash that deals with enum values.
	/// </summary>
	public interface IHandlerHashEnum : IHandlerHash
	{
		/// <summary>
		/// Converts a symbol to its corresponding enum value.
		/// </summary>
		/// <param name="sym">The symbol to convert.</param>
		/// <returns>The corresponding enum value.</returns>
		Enum fromSymbol(int sym);

		/// <summary>
		/// Converts an enum value to its corresponding symbol.
		/// </summary>
		/// <param name="sym">The enum value to convert.</param>
		/// <returns>The corresponding symbol.</returns>
		int toSymbol(Enum sym);
	}

	/// <summary>
	/// A specialized handler hash for Pokemon species.
	/// </summary>
	public interface ISpeciesHandlerHash : IHandlerHashSymbol { }

	/// <summary>
	/// A specialized handler hash for Pokemon abilities.
	/// </summary>
	public interface IAbilityHandlerHash : IHandlerHashSymbol { }

	/// <summary>
	/// A specialized handler hash for items.
	/// </summary>
	public interface IItemHandlerHash : IHandlerHashSymbol { }

	/// <summary>
	/// A specialized handler hash for moves.
	/// </summary>
	public interface IMoveHandlerHash : IHandlerHashSymbol { }
}