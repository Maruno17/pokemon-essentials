# The Deprecation module is used to warn game & plugin creators of deprecated
# methods.
module Deprecation
  module_function

  # Sends a warning of a deprecated method into the debug console.
  # @param method_name [String] name of the deprecated method
  # @param removal_version [String] name of the version the method is removed in (optional)
  # @param alternative [String] preferred alternative method (optional)
  def warn_method(method_name, removal_version = nil, alternative = nil)
    text = _INTL('WARN: usage of deprecated method "{1}" or its alias.', method_name)
    unless removal_version.nil?
      text += _INTL("\nThe method is slated to be"\
                    " removed in Essentials {1}.", removal_version)
    end
    unless alternative.nil?
      text += _INTL("\nUse \"{1}\" instead.", alternative)
    end
    echoln text
  end
end

# The Module class is extended to allow easy deprecation of instance and class methods.
class Module
  private

  # Creates a deprecated alias for an instance method.
  # Using it sends a warning to the debug console.
  # @param alias_name [Symbol] the name of the new alias
  # @param aliased_method_name [Symbol] the name of the aliased method
  # @param removal_version [String] name of the version the alias is removed in (optional)
  def deprecated_instance_method_alias(alias_name, aliased_method_name, removal_version = nil)
    define_method(alias_name) do |*args|
      alias_full_name = format('%s#%s', self.class.name, alias_name.to_s)
      aliased_method_full_name = format('%s#%s', self.class.name, aliased_method_name.to_s)
      Deprecation.warn_method(alias_full_name, removal_version, aliased_method_full_name)
      method(aliased_method_name).call(*args)
    end
  end

  # Creates a deprecated alias for a class method.
  # Using it sends a warning to the debug console.
  # @param (see #deprecated_instance_method_alias)
  def deprecated_class_method_alias(alias_name, aliased_method_name, removal_version = nil)
    self.class.send(:define_method, alias_name) do |*args|
      alias_full_name = format('%s::%s', self.name, alias_name.to_s)
      aliased_method_full_name = format('%s::%s', self.name, aliased_method_name.to_s)
      Deprecation.warn_method(alias_full_name, removal_version, aliased_method_full_name)
      method(aliased_method_name).call(*args)
    end
  end
end
