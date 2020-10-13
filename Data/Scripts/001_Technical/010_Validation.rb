# The Kernel module is extended to include the validate method.
module Kernel
  # Validates the given values. Takes a hash as its argument, e.g.:
  # +value1 => Integer, value2 => String, value3 => [Rect,Viewport]+
  # @param value_pairs [Hash] value pairs to validate
  # @raise [TypeError] raised if validation fails
  def validate(value_pairs)
    unless value_pairs.instance_of?(Hash)
      raise TypeError, _INTL("Non-hash argument #{value_pairs.inspect} passed into validate")
    end
    value_pairs.each do |value, type|
      if type.is_a?(Array)
        match = false
        type.each { |c| match = true if value.is_a?(c) }
        next if match
      elsif value.is_a?(type)
        next
      end
      raise TypeError, _INTL("#{value.class} value does not implement #{type.inspect}")
    end
  end
end