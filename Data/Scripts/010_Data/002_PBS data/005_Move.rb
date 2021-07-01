module GameData
  class Move
    attr_reader :id
    attr_reader :real_name
    attr_reader :type
    attr_reader :category
    attr_reader :base_damage
    attr_reader :accuracy
    attr_reader :total_pp
    attr_reader :target
    attr_reader :priority
    attr_reader :function_code
    attr_reader :flags
    attr_reader :effect_chance
    attr_reader :real_description

    DATA = {}
    DATA_FILENAME = "moves.dat"

    SCHEMA = {
      "Name"         => [:name,          "s"],
      "Type"         => [:type,          "e", :Type],
      "Category"     => [:category,      "e", ["Physical", "Special", "Status"]],
      "BaseDamage"   => [:base_damage,   "u"],
      "Accuracy"     => [:accuracy,      "u"],
      "TotalPP"      => [:total_pp,      "u"],
      "Target"       => [:target,        "e", :Target],
      "Priority"     => [:priority,      "i"],
      "FunctionCode" => [:function_code, "s"],
      "Flags"        => [:flags,         "*s"],
      "EffectChance" => [:effect_chance, "u"],
      "Description"  => [:description,   "q"]
    }

    extend ClassMethodsSymbols
    include InstanceMethods

    def initialize(hash)
      @id               = hash[:id]
      @real_name        = hash[:name]          || "Unnamed"
      @type             = hash[:type]          || :NONE
      @category         = hash[:category]      || 2
      @base_damage      = hash[:base_damage]   || 0
      @accuracy         = hash[:accuracy]      || 100
      @total_pp         = hash[:total_pp]      || 5
      @target           = hash[:target]        || :None
      @priority         = hash[:priority]      || 0
      @function_code    = hash[:function_code] || "000"
      @flags            = hash[:flags]         || []
      @flags            = [@flags] if !@flags.is_a?(Array)
      @effect_chance    = hash[:effect_chance] || 0
      @real_description = hash[:description]   || "???"
    end

    # @return [String] the translated name of this move
    def name
      return pbGetMessage(MessageTypes::Moves, @real_name)
    end

    # @return [String] the translated description of this move
    def description
      return pbGetMessage(MessageTypes::MoveDescriptions, @real_description)
    end

    def physical?
      return false if @base_damage == 0
      return @category == 0 if Settings::MOVE_CATEGORY_PER_MOVE
      return GameData::Type.get(@type).physical?
    end

    def special?
      return false if @base_damage == 0
      return @category == 1 if Settings::MOVE_CATEGORY_PER_MOVE
      return GameData::Type.get(@type).special?
    end

    def hidden_move?
      GameData::Item.each do |i|
        return true if i.is_HM? && i.move == @id
      end
      return false
    end
  end
end
