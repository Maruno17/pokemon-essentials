using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Extension interface for kernel-level validation functionality.
    /// Provides methods to validate method arguments against expected types or capabilities.
    /// </summary>
    public interface IKernelValidation
    {
        /// <summary>
        /// Validates method arguments against specified conditions.
        /// Used to check whether method arguments are of a given class or respond to a method.
        /// </summary>
        /// <param name="value_pairs">
        /// A dictionary of value-condition pairs to validate.
        /// Conditions can be:
        /// - A single Type to check class inheritance
        /// - An array of Types to check against multiple possible classes
        /// - A string representing a method name to check if the value responds to that method
        /// </param>
        /// <exception cref="ArgumentException">
        /// Thrown when validation fails or when a non-dictionary argument is passed.
        /// </exception>
        /// <example>
        /// Example usage for validating a class or method:
        /// <code>
        /// validate(new Dictionary&lt;object, object&gt;
        /// {
        ///     { foo, typeof(int) },
        ///     { baz, "to_s" }
        /// });
        /// // Raises an error if foo is not an Integer or if baz doesn't implement to_s method
        /// </code>
        /// </example>
        /// <example>
        /// Example usage for validating against multiple possible classes:
        /// <code>
        /// validate(new Dictionary&lt;object, object&gt;
        /// {
        ///     { foo, new Type[] { typeof(ISprite), typeof(IBitmap), typeof(IViewport) } }
        /// });
        /// // Raises an error if foo isn't a Sprite, Bitmap or Viewport
        /// </code>
        /// </example>
        void validate(IDictionary<object, object> value_pairs);
    }
}