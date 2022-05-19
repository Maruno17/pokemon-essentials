# The Deprecation module is used to warn game & plugin creators of deprecated
# methods.
module Deprecation
  module_function

  # Sends a warning of a deprecated method into the debug console.
  # @param method_name [String] name of the deprecated method
  # @param removal_version [String] version the method is removed in
  # @param alternative [String] preferred alternative method
  def warn_method(method_name, removal_version = nil, alternative = nil)
    text = _INTL('Usage of deprecated method "{1}" or its alias.', method_name)
    unless removal_version.nil?
      text += "\r\n" + _INTL("The method is slated to be removed in Essentials {1}.", removal_version)
    end
    unless alternative.nil?
      text += "\r\n" + _INTL("Use \"{1}\" instead.", alternative)
    end
    Console.echo_warn text
  end
end

# The Module class is extended to allow easy deprecation of instance and class methods.
class Module
  private

  # Creates a deprecated alias for a method.
  # Using it sends a warning to the debug console.
  # @param name [Symbol] name of the new alias
  # @param aliased_method [Symbol] name of the aliased method
  # @param removal_in [String] version the alias is removed in
  # @param class_method [Boolean] whether the method is a class method
  def deprecated_method_alias(name, aliased_method, removal_in: nil, class_method: false)
    validate name => Symbol, aliased_method => Symbol, removal_in => [NilClass, String],
             class_method => [TrueClass, FalseClass]

    target = class_method ? self.class : self
    class_name = self.name

    unless target.method_defined?(aliased_method)
      raise ArgumentError, "#{class_name} does not have method #{aliased_method} defined"
    end

    delimiter = class_method ? "." : "#"

    target.define_method(name) do |*args, **kvargs|
      alias_name = sprintf("%s%s%s", class_name, delimiter, name)
      aliased_method_name = sprintf("%s%s%s", class_name, delimiter, aliased_method)
      Deprecation.warn_method(alias_name, removal_in, aliased_method_name)
      method(aliased_method).call(*args, **kvargs)
    end
  end
end
