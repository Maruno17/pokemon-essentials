module SaveData
  # An error raised if an invalid save value is saved or loaded.
  class InvalidValueError < RuntimeError; end

  # Contains the data of a single value in save data.
  class Value
    # @return [Symbol] the value id
    attr_reader :id

    # @param id [Symbol] value id
    def initialize(id, &block)
      validate id => Symbol, block => Proc
      @id = id
      @loaded = false
      instance_eval(&block)
      raise "No save_value defined for save value #{id.inspect}" if @save_proc.nil?
      raise "No load_value defined for save value #{id.inspect}" if @load_proc.nil?
    end

    # Calls the value's save proc and returns its value.
    # @return [Object] save proc value
    # @raise [InvalidValueError] if an invalid value is being saved
    def save
      data = @save_proc.call

      if @ensured_class_names && !@ensured_class_names.include?(data.class.name)
        raise InvalidValueError, "Save value #{@id.inspect} is not a #{@ensured_class} (#{data.class.name} given)"
      end

      return data
    end

    # Calls the value's load proc with the given argument passed into it.
    # @param value [Object] load proc argument
    # @raise [RuntimeError] if no load proc is defined
    # @raise [InvalidValueError] if an invalid value is being loaded
    def load(value)
      if @ensured_class_names && !@ensured_class_names.include?(value.class.name)
        raise InvalidValueError, "Save value #{@id.inspect} is not a #{@ensured_class} (#{value.class.name} given)"
      end

      @load_proc.call(value)
      @loaded = true
    end

    # Calls the save value's load proc with the value fetched
    # from the defined reset proc.
    # @raise (see #load)
    def reset
      raise "Save value #{@id.inspect} has no reset proc defined" if @reset_proc.nil?

      self.load(@reset_proc.call)
    end

    # @return [Boolean] whether the value has a reset proc defined
    def has_reset_proc?
      return @reset_proc.is_a?(Block)
    end

    # @return [Boolean] whether the value has been loaded
    def loaded?
      return @loaded
    end

    # Uses the +from_old_format+ proc to select the correct data from
    # +old_format+ and return it.
    # Returns nil if the proc is undefined.
    # @param old_format [Array] old format to load value from
    # @return [Object] data from the old format
    def get_from_old_format(old_format)
      return nil if @old_format_get_proc.nil?
      return @old_format_get_proc.call(old_format)
    end

    private

    def save_value(&block)
      raise ArgumentError, 'No block given for save_value proc' unless block_given?
      @save_proc = block
    end

    # @yieldparam value [Object]
    def load_value(&block)
      raise ArgumentError, 'No block given for load_value proc' unless block_given?
      @load_proc = block
    end

    def reset_value(&block)
      raise ArgumentError, 'No block given for reset_value proc' unless block_given?
      @reset_proc = block
    end

    # @param class_names [Symbol] class names for the accepted value
    # @note This method accepts multiple class names to ensure compatibility with renamed classes.
    def ensure_class(*class_names)
      raise ArgumentError, 'No class names given for ensure_class' if class_names.empty?
      @ensured_class_names = class_names.map { |name| name.to_s }
    end

    # @yieldparam old_format [Array]
    def from_old_format(&block)
      raise ArgumentError, 'No block given for get_from_old_format proc' unless block_given?
      @old_format_get_proc = block
    end
  end
end
