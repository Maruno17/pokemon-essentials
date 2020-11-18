module SaveData
  # Contains the data of a single value in save data.
  class Value
    # @return [Symbol] the value id
    attr_reader :id

    # @param id [Symbol] value id
    def initialize(id, &block)
      validate id => Symbol, block => Proc
      @id = id
      instance_eval(&block)
      raise "No save_value defined for save value #{id.inspect}" if @save_proc.nil?
      raise "No load_value defined for save value #{id.inspect}" if @load_proc.nil?
    end

    # Calls the value's save proc and returns its value.
    # @return [Object] save proc value
    def save
      data = @save_proc.call
      if @ensured_class && data.class.name == @ensured_class.to_s
        raise TypeError, "Save value #{@id.inspect} is not a #{@ensured_class}"
      end
      return data
    end

    # Calls the value's load proc with the given argument passed into it.
    # @param value [Object] load proc argument
    def load(value)
      if @ensured_class && data.class.name == @ensured_class.to_s
        raise TypeError, "Save value #{@id.inspect} is not a #{@ensured_class}"
      end
      @load_proc.call(value)
    end

    private

    def save_value(&block)
      raise ArgumentError, "No block given for save_value proc" unless block_given?
      validate block => Proc
      @save_proc = block
    end

    def load_value(&block)
      raise ArgumentError, "No block given for load_value proc" unless block_given?
      validate block => Proc
      @load_proc = block
    end

    # @param class_name [Symbol]
    def ensure_class(class_name)
      @ensured_class = class_name
    end
  end
end
