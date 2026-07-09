using System;

namespace PokemonEssentials
{
    /// <summary>
    /// Location signpost
    /// </summary>
    /// <remarks>
    /// Interface for location signpost window that displays area names.
    /// Shows location names when entering new areas with smooth slide animations
    /// and automatic timing for appearance, lingering, and disappearance.
    /// </remarks>
    public interface ILocationWindow : IHaveUpdate, IDisposable
    {
        /// <summary>Appearance/disappearance animation duration in seconds.</summary>
        double APPEAR_TIME { get; }

        /// <summary>Duration window stays fully visible in seconds.</summary>
        double LINGER_TIME { get; }

        /// <summary>
        /// Initializes location window with area name.
        /// Creates window with location text and sets up slide animation timing.
        /// </summary>
        /// <param name="name">Location name to display</param>
        ILocationWindow initialize(string name);

        /// <summary>
        /// Checks if the location window has been disposed.
        /// </summary>
        /// <returns>True if window is disposed</returns>
        bool disposed();

        /// <summary>
        /// Disposes of location window resources.
        /// Cleans up window and viewport to prevent memory leaks.
        /// </summary>
        void dispose();

        /// <summary>
        /// Updates location window animation and timing.
        /// Handles slide-in, lingering, and slide-out animations with proper timing.
        /// Auto-disposes when animation completes or player changes maps.
        /// </summary>
        void update();
    }

    /// <summary>
    /// Visibility circle in dark maps
    /// </summary>
    /// <remarks>
    /// Interface for darkness overlay sprite used in dark maps.
    /// Creates circular visibility area with graduated darkness falloff
    /// for Flash move effects and cave exploration visibility.
    /// </remarks>
    public interface IDarknessSprite : ISprite, IHaveRefresh
    {
        /// <summary>Current radius of the visible area in pixels.</summary>
        int radius { get; set; }

        /// <summary>
        /// Initializes darkness sprite with viewport.
        /// Creates full-screen darkness overlay with circular visibility area.
        /// </summary>
        /// <param name="viewport">Viewport for rendering (optional)</param>
        IDarknessSprite initialize(IViewport viewport = null);

        /// <summary>
        /// Gets minimum visibility radius before using Flash.
        /// </summary>
        /// <returns>Minimum radius in pixels (typically 64)</returns>
        int radiusMin { get; }

        /// <summary>
        /// Gets maximum visibility radius after using Flash.
        /// </summary>
        /// <returns>Maximum radius in pixels (typically 176)</returns>
        int radiusMax { get; }

        /// <summary>
        /// Refreshes the darkness overlay bitmap.
        /// Redraws circular visibility area with graduated opacity falloff.
        /// Creates smooth transition from transparent center to opaque edges.
        /// </summary>
        void refresh();
    }

    /// <summary>
    /// Light effects
    /// </summary>
    /// <remarks>
    /// Interface for base light effect class for map lighting.
    /// Provides foundation for various light effects attached to map events
    /// including basic lighting, day/night lighting, and specialized effects.
    /// </remarks>
    public interface ILightEffect : IHaveUpdate, IDisposable
    {
        /// <summary>
        /// Initializes light effect for specified event.
        /// Sets up light sprite with appropriate graphics and positioning.
        /// </summary>
        /// <param name="event">Map event to attach light to</param>
        /// <param name="viewport">Viewport for rendering (optional)</param>
        /// <param name="map">Map containing the event (optional, defaults to current)</param>
        /// <param name="filename">Custom light graphic filename (optional)</param>
        ILightEffect initialize(IGameEvent @event, IViewport viewport = null, IGameMap map = null, string filename = null);

        /// <summary>
        /// Checks if the light effect has been disposed.
        /// </summary>
        /// <returns>True if light effect is disposed</returns>
        bool disposed();

        /// <summary>
        /// Disposes of light effect resources.
        /// Cleans up sprites and references to prevent memory leaks.
        /// </summary>
        void dispose();

        /// <summary>
        /// Updates light effect for one frame.
        /// Base update method for light animation and positioning.
        /// </summary>
        void update();
    }

    /// <summary>
    /// Interface for lamp-style light effect.
    /// Creates extended lamp lighting with custom bitmap composition
    /// for street lamps and similar wide-area lighting effects.
    /// </summary>
    public interface ILightEffectLamp : ILightEffect
    {
        /// <summary>
        /// Initializes lamp light effect for specified event.
        /// Creates custom bitmap with extended lamp lighting pattern.
        /// </summary>
        /// <param name="event">Map event to attach lamp light to</param>
        /// <param name="viewport">Viewport for rendering (optional)</param>
        /// <param name="map">Map containing the event (optional)</param>
        ILightEffectLamp initialize(IGameEvent @event, IViewport viewport = null, IGameMap map = null);
    }

    /// <summary>
    /// Interface for basic light effect implementation.
    /// Provides standard light effects that follow event positioning
    /// with screen tone matching and consistent visual properties.
    /// </summary>
    public interface ILightEffectBasic : ILightEffect, IHaveUpdate
    {
        /// <summary>
        /// Initializes basic light effect for specified event.
        /// Sets up centered light with standard opacity and positioning.
        /// </summary>
        /// <param name="event">Map event to attach light to</param>
        /// <param name="viewport">Viewport for rendering (optional)</param>
        /// <param name="map">Map containing the event (optional)</param>
        /// <param name="filename">Custom light graphic filename (optional)</param>
        ILightEffectBasic initialize(IGameEvent @event, IViewport viewport = null, IGameMap map = null, string filename = null);

        /// <summary>
        /// Updates basic light positioning and tone matching.
        /// Follows event screen position and matches current screen tone.
        /// Supports both ScreenPosHelper and standard positioning systems.
        /// </summary>
        void update();
    }

    /// <summary>
    /// Interface for day/night sensitive light effect.
    /// Adjusts light opacity based on time of day, making lights more visible
    /// during darker periods and dimmer during daylight hours.
    /// </summary>
    public interface ILightEffectDayNight : ILightEffect, IHaveUpdate
    {
        /// <summary>
        /// Initializes day/night light effect for specified event.
        /// Sets up light with time-sensitive opacity calculations.
        /// </summary>
        /// <param name="event">Map event to attach light to</param>
        /// <param name="viewport">Viewport for rendering (optional)</param>
        /// <param name="map">Map containing the event (optional)</param>
        /// <param name="filename">Custom light graphic filename (optional)</param>
        ILightEffectDayNight initialize(IGameEvent @event, IViewport viewport = null, IGameMap map = null, string filename = null);

        /// <summary>
        /// Updates day/night light with time-based opacity.
        /// Calculates appropriate opacity based on current shade level,
        /// making lights brightest at night and invisible during full daylight.
        /// </summary>
        void update();
    }

    public interface IMainOverworldOverlay : IMain
    {
		/// <summary>
		/// Processes map events for automatic light effect creation.
		/// Scans event names for light effect patterns and creates appropriate effects.
		/// </summary>
		/// <remarks>
		/// Automatically creates light effects for events with names matching
		/// </remarks>
		/// <param name="spriteset">Map spriteset to add light effects to</param>
		/// <param name="viewport">Viewport for light effect rendering</param>
		/// <example>
		/// <code>
		/// EventHandlers.add(:on_new_spriteset_map, :add_light_effects,
		///   proc { |spriteset, viewport|
		///     map = spriteset.map   # Map associated with the spriteset (not necessarily the current map)
		///     map.events.each_key do |i|
		///       if map.events[i].name[/^outdoorlight\((\w+)\)$/i]
		///         filename = $~[1].to_s
		///         spriteset.addUserSprite(LightEffect_DayNight.new(map.events[i], viewport, map, filename))
		///       elsif map.events[i].name[/^outdoorlight$/i]
		///         spriteset.addUserSprite(LightEffect_DayNight.new(map.events[i], viewport, map))
		///       elsif map.events[i].name[/^light\((\w+)\)$/i]
		///         filename = $~[1].to_s
		///         spriteset.addUserSprite(LightEffect_Basic.new(map.events[i], viewport, map, filename))
		///       elsif map.events[i].name[/^light$/i]
		///         spriteset.addUserSprite(LightEffect_Basic.new(map.events[i], viewport, map))
		///       end
		///     end
		///   }</code>
		/// )
		/// </example>
		/// <seealso cref="IEvents.OnSpritesetCreate"/>
		/// <seealso cref="EventArg.IOnSpritesetCreateEventArgs"/>
		//void on_new_spriteset_mapTrigger(ISpritesetMap spriteset, IViewport viewport);
		void OnNewSpritesetMapTrigger(ISpritesetMap spriteset, IViewport viewport);
    }
    /*
    /// <summary>
    /// Interface for light effect event handler registration.
    /// Manages automatic creation of light effects for map events
    /// based on event naming conventions and spriteset integration.
    /// </summary>
    public interface ILightEffectEventHandler
    {
        /// <summary>
        /// Processes map events for automatic light effect creation.
        /// Scans event names for light effect patterns and creates appropriate effects.
        /// </summary>
        /// <remarks>
        /// Automatically creates light effects for events with names matching
        /// </remarks>
        /// <param name="spriteset">Map spriteset to add light effects to</param>
        /// <param name="viewport">Viewport for light effect rendering</param>
        //void on_new_spriteset_mapTrigger(ISpritesetMap spriteset, IViewport viewport);
        void addLightEffects(ISpritesetMap spriteset, IViewport viewport);

        /// <summary>
        /// Parses event name for outdoor light effect pattern.
        /// Recognizes "outdoorlight" and "outdoorlight(filename)" patterns.
        /// </summary>
        /// <param name="event_name">Event name to parse</param>
        /// <returns>Light effect configuration or null if no match</returns>
        ILightEffectConfig parseOutdoorLight(string event_name);

        /// <summary>
        /// Parses event name for basic light effect pattern.
        /// Recognizes "light" and "light(filename)" patterns.
        /// </summary>
        /// <param name="event_name">Event name to parse</param>
        /// <returns>Light effect configuration or null if no match</returns>
        ILightEffectConfig parseBasicLight(string event_name);

        /// <summary>
        /// Creates appropriate light effect based on configuration.
        /// Instantiates correct light effect type with proper parameters.
        /// </summary>
        /// <param name="config">Light effect configuration</param>
        /// <param name="event">Map event to attach to</param>
        /// <param name="viewport">Viewport for rendering</param>
        /// <param name="map">Map containing the event</param>
        /// <returns>Created light effect instance</returns>
        ILightEffect createLightEffect(ILightEffectConfig config, IGameEvent @event, IViewport viewport, IGameMap map);
    }

    /// <summary>
    /// Interface for light effect configuration data.
    /// Contains parameters for creating light effects including type,
    /// graphics filename, and effect-specific properties.
    /// </summary>
    public interface ILightEffectConfig
    {
        /// <summary>Type of light effect to create.</summary>
        LightEffectType effectType { get; }

        /// <summary>Custom graphics filename (if specified).</summary>
        string filename { get; }

        /// <summary>Whether this configuration is valid.</summary>
        bool isValid { get; }

        /// <summary>Additional effect-specific properties.</summary>
        System.Collections.Generic.Dictionary<string, object> properties { get; }

        /// <summary>
        /// Creates light effect configuration from parsed event name.
        /// </summary>
        /// <param name="effectType">Type of light effect</param>
        /// <param name="filename">Graphics filename (optional)</param>
        /// <param name="properties">Additional properties (optional)</param>
        ILightEffectConfig initialize(LightEffectType effectType, string filename = null, System.Collections.Generic.Dictionary<string, object> properties = null);
    }

    /// <summary>
    /// Enumeration for light effect types.
    /// Defines the different categories of light effects available
    /// for automatic creation from map event names.
    /// </summary>
    public enum LightEffectType
    {
        /// <summary>Basic light effect with standard properties.</summary>
        Basic,

        /// <summary>Day/night sensitive light effect.</summary>
        DayNight,

        /// <summary>Lamp-style light with extended area.</summary>
        Lamp,

        /// <summary>Custom light effect with special properties.</summary>
        Custom
    }

    /// <summary>
    /// Interface for overlay management system.
    /// Coordinates multiple overlay effects including location windows,
    /// darkness effects, and light systems for comprehensive visual enhancement.
    /// </summary>
    public interface IOverlayManager : IHaveUpdate, IDisposable
    {
        /// <summary>Current location window (if active).</summary>
        ILocationWindow locationWindow { get; }

        /// <summary>Current darkness sprite (if active).</summary>
        IDarknessSprite darknessSprite { get; }

        /// <summary>Collection of active light effects.</summary>
        System.Collections.Generic.List<ILightEffect> lightEffects { get; }

        /// <summary>
        /// Initializes overlay manager with viewport.
        /// Sets up management for all overlay effect types.
        /// </summary>
        /// <param name="viewport">Main viewport for overlay rendering</param>
        IOverlayManager initialize(IViewport viewport);

        /// <summary>
        /// Shows location window with area name.
        /// Creates and displays location signpost with automatic timing.
        /// </summary>
        /// <param name="locationName">Name of location to display</param>
        void showLocationWindow(string locationName);

        /// <summary>
        /// Activates darkness overlay for dark maps.
        /// Creates circular visibility area for cave/dark area exploration.
        /// </summary>
        /// <param name="initial_radius">Starting visibility radius</param>
        void activateDarkness(int initial_radius);

        /// <summary>
        /// Deactivates darkness overlay.
        /// Removes darkness effect when leaving dark areas.
        /// </summary>
        void deactivateDarkness();

        /// <summary>
        /// Updates Flash effect radius.
        /// Adjusts visibility area when Flash move is used.
        /// </summary>
        /// <param name="new_radius">New visibility radius</param>
        void updateFlashRadius(int new_radius);

        /// <summary>
        /// Adds light effect to management.
        /// Registers light effect for update and disposal coordination.
        /// </summary>
        /// <param name="light_effect">Light effect to add</param>
        void addLightEffect(ILightEffect light_effect);

        /// <summary>
        /// Removes light effect from management.
        /// Unregisters and disposes light effect safely.
        /// </summary>
        /// <param name="light_effect">Light effect to remove</param>
        void removeLightEffect(ILightEffect light_effect);

        /// <summary>
        /// Updates all overlay effects for one frame.
        /// Coordinates updates for location window, darkness, and light effects.
        /// </summary>
        void update();

        /// <summary>
        /// Disposes of all overlay resources.
        /// Cleans up all active overlays and prevents memory leaks.
        /// </summary>
        void dispose();
    }
    */
}