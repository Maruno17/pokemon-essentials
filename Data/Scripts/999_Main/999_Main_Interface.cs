using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// A simple scene used during debug starts to bypass the title screen and load directly into the game.
	/// </summary>
	public interface ISceneDebugIntro : IScene
	{
		/// <summary>
		/// Execution logic for the debug intro scene.
		/// </summary>
		void main();
	}

	/// <summary>
	/// Interface for the main Pokemon Essentials application entry point.
	/// </summary>
	/// <remarks>
    /// Global methods and properties originally defined in 999_Main.rb.
	/// </remarks>
	public interface IMainApplication : IMain
	{
		/// <summary>
		/// Determines the initial scene to load upon starting the game.
		/// </summary>
		/// <returns>A new title scene instance.</returns>
		IScene CallTitle();

		/// <summary>
		/// The primary entry point loop logic.
		/// </summary>
		/// <returns>An integer result code (1 for success, 0 for failure).</returns>
		int mainFunction();

		/// <summary>
		/// Detailed debug/initialization logic called by <see cref="mainFunction"/>.
		/// Handles message loading, plugin execution, compiler checks, and game system setup.
		/// </summary>
		void mainFunctionDebug();
	}
	/*
	/// <summary>
	/// Handles application initialization, main game loop, and shutdown procedures.
	/// </summary>
	public interface IApplicationMain
	{
		/// <summary>
		/// Initializes the Pokemon Essentials application.
		/// </summary>
		/// <param name="args">Command line arguments passed to the application.</param>
		/// <returns>True if initialization was successful, false otherwise.</returns>
		bool initialize(string[] args);

		/// <summary>
		/// Starts the main application and enters the game loop.
		/// </summary>
		void run();

		/// <summary>
		/// Shuts down the application gracefully.
		/// </summary>
		void shutdown();

		/// <summary>
		/// Gets the current application state.
		/// </summary>
		/// <returns>The current state of the application.</returns>
		string getApplicationState();

		/// <summary>
		/// Checks if the application is currently running.
		/// </summary>
		/// <returns>True if the application is running, false otherwise.</returns>
		bool isRunning();

		/// <summary>
		/// Pauses the application execution.
		/// </summary>
		void pause();

		/// <summary>
		/// Resumes the application execution.
		/// </summary>
		void resume();

		/// <summary>
		/// Checks if the application is currently paused.
		/// </summary>
		/// <returns>True if the application is paused, false otherwise.</returns>
		bool isPaused();

		/// <summary>
		/// Forces the application to exit immediately.
		/// </summary>
		/// <param name="exitCode">The exit code to return to the operating system.</param>
		void forceExit(int exitCode = 0);
	}

	/// <summary>
	/// Interface for application lifecycle management.
	/// </summary>
	public interface IApplicationLifecycle
	{
		/// <summary>
		/// Called when the application starts up.
		/// </summary>
		void onStartup();

		/// <summary>
		/// Called when the application is shutting down.
		/// </summary>
		void onShutdown();

		/// <summary>
		/// Called when the application is paused.
		/// </summary>
		void onPause();

		/// <summary>
		/// Called when the application is resumed.
		/// </summary>
		void onResume();

		/// <summary>
		/// Called when the application window gains focus.
		/// </summary>
		void onFocusGained();

		/// <summary>
		/// Called when the application window loses focus.
		/// </summary>
		void onFocusLost();

		/// <summary>
		/// Called when the application window is resized.
		/// </summary>
		/// <param name="width">The new window width.</param>
		/// <param name="height">The new window height.</param>
		void onWindowResize(int width, int height);

		/// <summary>
		/// Called when an unhandled exception occurs.
		/// </summary>
		/// <param name="exception">The exception that occurred.</param>
		/// <returns>True if the exception was handled, false to allow default handling.</returns>
		bool onUnhandledException(Exception exception);
	}

	/// <summary>
	/// Interface for the main game loop and update cycle.
	/// </summary>
	public interface IGameLoop
	{
		/// <summary>
		/// Executes one frame of the main game loop.
		/// </summary>
		void updateFrame();

		/// <summary>
		/// Updates the game logic.
		/// </summary>
		/// <param name="deltaTime">The time elapsed since the last update.</param>
		void updateLogic(float deltaTime);

		/// <summary>
		/// Renders the current frame.
		/// </summary>
		void render();

		/// <summary>
		/// Processes input for the current frame.
		/// </summary>
		void processInput();

		/// <summary>
		/// Gets the target frames per second for the game loop.
		/// </summary>
		/// <returns>The target FPS.</returns>
		int getTargetFPS();

		/// <summary>
		/// Sets the target frames per second for the game loop.
		/// </summary>
		/// <param name="fps">The target FPS to set.</param>
		void setTargetFPS(int fps);

		/// <summary>
		/// Gets the current actual frames per second.
		/// </summary>
		/// <returns>The current FPS.</returns>
		float getCurrentFPS();

		/// <summary>
		/// Enables or disables VSync.
		/// </summary>
		/// <param name="enabled">Whether to enable VSync.</param>
		void setVSyncEnabled(bool enabled);

		/// <summary>
		/// Checks if VSync is currently enabled.
		/// </summary>
		/// <returns>True if VSync is enabled, false otherwise.</returns>
		bool isVSyncEnabled();
	}

	/// <summary>
	/// Interface for application configuration and settings.
	/// </summary>
	public interface IApplicationConfig
	{
		/// <summary>
		/// Loads the application configuration from files.
		/// </summary>
		/// <returns>True if configuration was loaded successfully, false otherwise.</returns>
		bool loadConfig();

		/// <summary>
		/// Saves the current configuration to files.
		/// </summary>
		/// <returns>True if configuration was saved successfully, false otherwise.</returns>
		bool saveConfig();

		/// <summary>
		/// Gets a configuration value.
		/// </summary>
		/// <param name="key">The configuration key.</param>
		/// <param name="defaultValue">The default value if the key doesn't exist.</param>
		/// <returns>The configuration value.</returns>
		T getConfigValue<T>(string key, T defaultValue = default(T));

		/// <summary>
		/// Sets a configuration value.
		/// </summary>
		/// <param name="key">The configuration key.</param>
		/// <param name="value">The value to set.</param>
		void setConfigValue(string key, object value);

		/// <summary>
		/// Resets all configuration to default values.
		/// </summary>
		void resetToDefaults();

		/// <summary>
		/// Validates the current configuration.
		/// </summary>
		/// <returns>True if configuration is valid, false otherwise.</returns>
		bool validateConfig();

		/// <summary>
		/// Gets all configuration keys and values.
		/// </summary>
		/// <returns>Dictionary of all configuration settings.</returns>
		IDictionary<string, object> getAllConfig();

		/// <summary>
		/// Imports configuration from a file.
		/// </summary>
		/// <param name="filename">The file to import from.</param>
		/// <returns>True if import was successful, false otherwise.</returns>
		bool importConfig(string filename);

		/// <summary>
		/// Exports configuration to a file.
		/// </summary>
		/// <param name="filename">The file to export to.</param>
		/// <returns>True if export was successful, false otherwise.</returns>
		bool exportConfig(string filename);
	}

	/// <summary>
	/// Interface for application resource management.
	/// </summary>
	public interface IResourceManager
	{
		/// <summary>
		/// Loads all required resources for the application.
		/// </summary>
		/// <returns>True if resources were loaded successfully, false otherwise.</returns>
		bool loadResources();

		/// <summary>
		/// Unloads all resources and frees memory.
		/// </summary>
		void unloadResources();

		/// <summary>
		/// Loads a specific resource by name.
		/// </summary>
		/// <param name="resourceName">The name of the resource to load.</param>
		/// <returns>The loaded resource, or null if loading failed.</returns>
		object loadResource(string resourceName);

		/// <summary>
		/// Unloads a specific resource by name.
		/// </summary>
		/// <param name="resourceName">The name of the resource to unload.</param>
		void unloadResource(string resourceName);

		/// <summary>
		/// Checks if a resource is currently loaded.
		/// </summary>
		/// <param name="resourceName">The name of the resource to check.</param>
		/// <returns>True if the resource is loaded, false otherwise.</returns>
		bool isResourceLoaded(string resourceName);

		/// <summary>
		/// Gets the memory usage of all loaded resources.
		/// </summary>
		/// <returns>The total memory usage in bytes.</returns>
		long getResourceMemoryUsage();

		/// <summary>
		/// Performs garbage collection on unused resources.
		/// </summary>
		void collectGarbageResources();

		/// <summary>
		/// Preloads resources that will be needed soon.
		/// </summary>
		/// <param name="resourceNames">List of resource names to preload.</param>
		void preloadResources(IList<string> resourceNames);
	}

	/// <summary>
	/// Interface for application event system.
	/// </summary>
	public interface IApplicationEvents
	{
		/// <summary>
		/// Subscribes to an application event.
		/// </summary>
		/// <param name="eventName">The name of the event to subscribe to.</param>
		/// <param name="handler">The event handler function.</param>
		void subscribe(string eventName, Action<object> handler);

		/// <summary>
		/// Unsubscribes from an application event.
		/// </summary>
		/// <param name="eventName">The name of the event to unsubscribe from.</param>
		/// <param name="handler">The event handler function to remove.</param>
		void unsubscribe(string eventName, Action<object> handler);

		/// <summary>
		/// Fires an application event.
		/// </summary>
		/// <param name="eventName">The name of the event to fire.</param>
		/// <param name="eventData">Data associated with the event.</param>
		void fireEvent(string eventName, object eventData = null);

		/// <summary>
		/// Gets a list of all available event names.
		/// </summary>
		/// <returns>List of event names that can be subscribed to.</returns>
		IList<string> getAvailableEvents();

		/// <summary>
		/// Clears all event subscriptions.
		/// </summary>
		void clearAllSubscriptions();

		/// <summary>
		/// Clears subscriptions for a specific event.
		/// </summary>
		/// <param name="eventName">The name of the event to clear subscriptions for.</param>
		void clearSubscriptions(string eventName);
	}*/
}