module GameData
  class Move
    attr_reader :id
    attr_reader :id_number
    attr_reader :real_name
    attr_reader :function_code
    attr_reader :base_damage
    attr_reader :type
    attr_reader :category
    attr_reader :accuracy
    attr_reader :total_pp
    attr_reader :effect_chance
    attr_reader :target
    attr_reader :priority
    attr_reader :flags
    attr_reader :real_description

    DATA = {}
    DATA_FILENAME = "moves.dat"

    extend ClassMethods
    include InstanceMethods

    def initialize(hash)
      @id               = hash[:id]
      @id_number        = hash[:id_number]   || -1
      @real_name        = hash[:name]        || "Unnamed"
      @function_code    = hash[:function_code]
      @base_damage      = hash[:base_damage]
      @type             = hash[:type]
      @category         = hash[:category]
      @accuracy         = hash[:accuracy]
      @total_pp         = hash[:total_pp]
      @effect_chance    = hash[:effect_chance]
      @target           = hash[:target]
      @priority         = hash[:priority]
      @flags            = hash[:flags]
      @real_description = hash[:description] || "???"
    end

    # @return [String] the translated name of this move
    def name
      return pbGetMessage(MessageTypes::Moves, @id_number)
    end

    # @return [String] the translated description of this move
    def description
      return pbGetMessage(MessageTypes::MoveDescriptions, @id_number)
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

#===============================================================================
# Deprecated methods
#===============================================================================
# @deprecated This alias is slated to be removed in v20.
def pbGetMoveData(move_id, move_data_type = -1)
  Deprecation.warn_method('pbGetMoveData', 'v20', 'GameData::Move.get(move_id)')
  return GameData::Move.get(move_id)
end

# @deprecated This alias is slated to be removed in v20.
def pbIsHiddenMove?(move)
  Deprecation.warn_method('pbIsHiddenMove?', 'v20', 'GameData::Move.get(move).hidden_move?')
  return GameData::Move.get(move).hidden_move?
end
