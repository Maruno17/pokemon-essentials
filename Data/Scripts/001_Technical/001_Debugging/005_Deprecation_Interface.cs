using System;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for deprecation warning functionality.
    /// Used to warn game and plugin creators of deprecated methods and provide guidance on alternatives.
    /// </summary>
    public interface IDeprecation
    {
        /// <summary>
        /// Sends a warning of a deprecated method to the debug console.
        /// Displays information about the deprecated method, removal timeline, and suggested alternatives.
        /// </summary>
        /// <param name="method_name">The name of the deprecated method being used.</param>
        /// <param name="removal_version">
        /// Optional version when the method will be removed.
        /// If null, no removal timeline will be displayed.
        /// </param>
        /// <param name="alternative">
        /// Optional preferred alternative method name.
        /// If null, no alternative suggestion will be displayed.
        /// </param>
        /// <example>
        /// <code>
        /// warn_method("old_method", "v21", "new_method");
        /// // Outputs: Usage of deprecated method "old_method" or its alias.
        /// //          The method is slated to be removed in Essentials v21.
        /// //          Use "new_method" instead.
        /// </code>
        /// </example>
        void warn_method(string method_name, string removal_version = null, string alternative = null);
    }

    /*
    /// <summary>
    /// Interface for module-level deprecation functionality.
    /// Provides methods to create deprecated aliases for both instance and class methods.
    /// </summary>
    public interface IModuleDeprecation
    {
        /// <summary>
        /// Creates a deprecated alias for a method that warns when used.
        /// The alias will function identically to the original method but will send a warning to the debug console.
        /// </summary>
        /// <param name="name">The name of the new deprecated alias to create.</param>
        /// <param name="aliased_method">The name of the existing method to create an alias for.</param>
        /// <param name="removal_in">
        /// Optional version when the alias will be removed.
        /// If null, no removal timeline will be mentioned in the warning.
        /// </param>
        /// <param name="class_method">
        /// Whether the method being aliased is a class method (true) or instance method (false).
        /// Defaults to false for instance methods.
        /// </param>
        /// <exception cref="ArgumentException">
        /// Thrown when the aliased_method does not exist in the target class/module.
        /// </exception>
        /// <example>
        /// <code>
        /// // Create a deprecated alias for an instance method
        /// deprecated_method_alias("old_name", "new_name", removal_in: "v21", class_method: false);
        ///
        /// // Create a deprecated alias for a class method
        /// deprecated_method_alias("OldClassMethod", "NewClassMethod", removal_in: "v21", class_method: true);
        /// </code>
        /// </example>
        void deprecated_method_alias(string name, string aliased_method, string removal_in = null, bool class_method = false);

        /// <summary>
        /// Gets the name of the module/class for deprecation warnings.
        /// </summary>
        string ClassName { get; }

        /// <summary>
        /// Checks if a method is defined in the target (class or instance context).
        /// </summary>
        /// <param name="methodName">The name of the method to check.</param>
        /// <param name="isClassMethod">Whether to check for class method (true) or instance method (false).</param>
        /// <returns>True if the method is defined, false otherwise.</returns>
        bool IsMethodDefined(string methodName, bool isClassMethod);

        /// <summary>
        /// Defines a new method in the target context.
        /// </summary>
        /// <param name="name">The name of the method to define.</param>
        /// <param name="implementation">The method implementation.</param>
        /// <param name="isClassMethod">Whether to define as class method (true) or instance method (false).</param>
        void DefineMethod(string name, Delegate implementation, bool isClassMethod);
    }

    /// <summary>
    /// Interface for deprecated method call tracking and execution.
    /// Handles the actual invocation of deprecated methods with warning functionality.
    /// </summary>
    public interface IDeprecatedMethodCall
    {
        /// <summary>
        /// Executes a deprecated method call with warning and argument forwarding.
        /// </summary>
        /// <param name="originalMethodName">The name of the original method being called.</param>
        /// <param name="deprecatedName">The name of the deprecated alias being used.</param>
        /// <param name="className">The class/module name containing the method.</param>
        /// <param name="isClassMethod">Whether this is a class method call.</param>
        /// <param name="removalVersion">Optional version when the alias will be removed.</param>
        /// <param name="args">Arguments to pass to the original method.</param>
        /// <returns>The result of calling the original method.</returns>
        object ExecuteDeprecatedCall(string originalMethodName, string deprecatedName, string className, bool isClassMethod, string removalVersion, params object[] args);

        /// <summary>
        /// Formats the method signature for deprecation warnings.
        /// </summary>
        /// <param name="className">The class/module name.</param>
        /// <param name="methodName">The method name.</param>
        /// <param name="isClassMethod">Whether this is a class method.</param>
        /// <returns>A formatted method signature (e.g., "ClassName.method" or "ClassName#method").</returns>
        string FormatMethodSignature(string className, string methodName, bool isClassMethod);
    }*/
}