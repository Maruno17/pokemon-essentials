# The Kernel module is extended to include the validate method.
module Kernel
  private

  # Used to check whether method arguments are of a given class or respond to a method.
  # @param value_pairs [Hash{Object => Class, Array<Class>, Symbol}] value pairs to validate
  # @example Validate a class or method
  #   validate foo => Integer, baz => :to_s # raises an error if foo is not an Integer or if baz doesn't implement #to_s
  # @example Validate a class from an array
  #   validate foo => [Sprite, Bitmap, Viewport] # raises an error if foo isn't a Sprite, Bitmap or Viewport
  # @raise [ArgumentError] if validation fails
  def validate(value_pairs)
    unless value_pairs.is_a?(Hash)
      raise ArgumentError, "Non-hash argument #{value_pairs.inspect} passed into validate."
    end
    errors = value_pairs.map do |value, condition|
      if condition.is_a?(Array)
        unless condition.any? { |klass| value.is_a?(klass) }
          next "Expected #{value.inspect} to be one of #{condition.inspect}, but got #{value.class.name}."
        end
      elsif condition.is_a?(Symbol)
        next "Expected #{value.inspect} to respond to #{condition}." unless value.respond_to?(condition)
      elsif !value.is_a?(condition)
        next "Expected #{value.inspect} to be a #{condition.name}, but got #{value.class.name}."
      end
    end
    errors.compact!
    return if errors.empty?
    raise ArgumentError, "Invalid argument passed to method.\r\n" + errors.join("\r\n")
  end
end
