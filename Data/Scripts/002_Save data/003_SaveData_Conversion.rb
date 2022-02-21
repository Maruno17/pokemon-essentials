module SaveData
  # Contains Conversion objects for each defined conversion:
  # {
  #   :essentials => {
  #     '19'    => [<Conversion>, ...],
  #     '19.1'  => [<Conversion>, ...],
  #     ...
  #   },
  #   :game => {
  #     '1.1.0' => [<Conversion>, ...],
  #     '1.2.0' => [<Conversion>, ...],
  #     ...
  #   }
  # }
  # Populated during runtime by SaveData.register_conversion calls.
  @conversions = {
    essentials: {},
    game: {}
  }

  #=============================================================================
  # Represents a conversion made to save data.
  # New conversions are added using {SaveData.register_conversion}.
  class Conversion
    # @return [Symbol] conversion ID
    attr_reader :id
    # @return [String] conversion title
    attr_reader :title
    # @return [Symbol] trigger type of the conversion (+:essentials+ or +:game+)
    attr_reader :trigger_type
    # @return [String] trigger version of the conversion
    attr_reader :version

    # @param id [String] conversion ID
    def initialize(id, &block)
      @id = id
      @value_procs = {}
      @all_proc = nil
      @title = "Running conversion #{@id}"
      @trigger_type = nil
      @version = nil
      instance_eval(&block)
      if @trigger_type.nil? || @version.nil?
        raise "Conversion #{@id} is missing a condition"
      end
    end

    # Returns whether the conversion should be run with the given version.
    # @param version [String] version to check
    # @return [Boolean] whether the conversion should be run
    def should_run?(version)
      return PluginManager.compare_versions(version, @version) < 0
    end

    # Runs the conversion on the given save data.
    # @param save_data [Hash]
    def run(save_data)
      @value_procs.each do |value_id, proc|
        unless save_data.has_key?(value_id)
          raise "Save data does not have value #{value_id.inspect}"
        end
        proc.call(save_data[value_id])
      end
      @all_proc.call(save_data) if @all_proc.is_a?(Proc)
    end

    # Runs the conversion on the given object.
    # @param object
    # @param key [Symbol]
    def run_single(object, key)
      @value_procs[key].call(object) if @value_procs[key].is_a?(Proc)
    end

    private

    # @!group Configuration

    # Sets the conversion's title.
    # @param new_title [String] conversion title
    # @note Since conversions are run before loading the player's chosen language,
    #   conversion titles can not be localized.
    # @see SaveData.register_conversion
    def display_title(new_title)
      validate new_title => String
      @title = new_title
    end

    # Sets the conversion to trigger for save files created below
    # the given Essentials version.
    # @param version [Numeric, String]
    # @see SaveData.register_conversion
    def essentials_version(version)
      validate version => [Numeric, String]
      raise "Multiple conditions in conversion #{@id}" unless @version.nil?
      @trigger_type = :essentials
      @version = version.to_s
    end

    # Sets the conversion to trigger for save files created below
    # the given game version.
    # @param version [Numeric, String]
    # @see SaveData.register_conversion
    def game_version(version)
      validate version => [Numeric, String]
      raise "Multiple conditions in conversion #{@id}" unless @version.nil?
      @trigger_type = :game
      @version = version.to_s
    end

    # Defines a conversion to the given save value.
    # @param value_id [Symbol] save value ID
    # @see SaveData.register_conversion
    def to_value(value_id, &block)
      validate value_id => Symbol
      raise ArgumentError, "No block given to to_value" unless block_given?
      if @value_procs[value_id].is_a?(Proc)
        raise "Multiple to_value definitions in conversion #{@id} for #{value_id}"
      end
      @value_procs[value_id] = block
    end

    # Defines a conversion to the entire save data.
    # @see SaveData.register_conversion
    def to_all(&block)
      raise ArgumentError, "No block given to to_all" unless block_given?
      if @all_proc.is_a?(Proc)
        raise "Multiple to_all definitions in conversion #{@id}"
      end
      @all_proc = block
    end

    # @!endgroup
  end

  #=============================================================================
  # Registers a {Conversion} to occur for save data that meets the given criteria.
  # Two types of criteria can be defined: {Conversion#essentials_version} and
  # {Conversion#game_version}. The conversion is automatically run on save data
  # that contains an older version number.
  #
  # A single value can be modified with {Conversion#to_value}. The entire save data
  # is accessed with {Conversion#to_all}, and a conversion title can be specified
  # with {Conversion#display_title}.
  # @example Registering a new conversion
  #   SaveData.register_conversion(:my_conversion) do
  #     game_version '1.1.0'
  #     display_title 'Converting some stuff'
  #     to_value :player do |player|
  #       # code that modifies the :player value
  #     end
  #     to_all do |save_data|
  #       save_data[:new_value] = Foo.new
  #     end
  #   end
  # @yield the block of code to be saved as a Conversion
  def self.register_conversion(id, &block)
    validate id => Symbol
    unless block_given?
      raise ArgumentError, "No block given to SaveData.register_conversion"
    end
    conversion = Conversion.new(id, &block)
    @conversions[conversion.trigger_type][conversion.version] ||= []
    @conversions[conversion.trigger_type][conversion.version] << conversion
  end

  # @param save_data [Hash] save data to get conversions for
  # @return [Array<Conversion>] all conversions that should be run on the data
  def self.get_conversions(save_data)
    conversions_to_run = []
    versions = {
      essentials: save_data[:essentials_version] || "18.1",
      game: save_data[:game_version] || "0.0.0"
    }
    [:essentials, :game].each do |trigger_type|
      # Ensure the versions are sorted from lowest to highest
      sorted_versions = @conversions[trigger_type].keys.sort do |v1, v2|
        PluginManager.compare_versions(v1, v2)
      end
      sorted_versions.each do |version|
        @conversions[trigger_type][version].each do |conversion|
          next unless conversion.should_run?(versions[trigger_type])
          conversions_to_run << conversion
        end
      end
    end
    return conversions_to_run
  end

  # Runs all possible conversions on the given save data.
  # Saves a backup before running conversions.
  # @param save_data [Hash] save data to run conversions on
  # @return [Boolean] whether conversions were run
  def self.run_conversions(save_data)
    validate save_data => Hash
    conversions_to_run = self.get_conversions(save_data)
    return false if conversions_to_run.none?
    File.open(SaveData::FILE_PATH + ".bak", "wb") { |f| Marshal.dump(save_data, f) }
    Console.echo_h1 "Running #{conversions_to_run.length} save file conversions"
    conversions_to_run.each do |conversion|
      Console.echo_li "#{conversion.title}..."
      conversion.run(save_data)
      Console.echo_done(true)
    end
    echoln "" if conversions_to_run.length > 0
    Console.echo_h2("All save file conversions applied successfully", text: :green)
    save_data[:essentials_version] = Essentials::VERSION
    save_data[:game_version] = Settings::GAME_VERSION
    return true
  end

  # Runs all possible conversions on the given object.
  # @param object [Hash] object to run conversions on
  # @param key [Hash] object's key in save data
  # @param save_data [Hash] save data to run conversions on
  def self.run_single_conversions(object, key, save_data)
    validate key => Symbol
    conversions_to_run = self.get_conversions(save_data)
    conversions_to_run.each do |conversion|
      conversion.run_single(object, key)
    end
  end
end
