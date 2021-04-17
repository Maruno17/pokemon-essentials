#===============================================================================
# Move objects known by Pokémon.
#===============================================================================
class Pokemon
  class Move
    # This move's ID.
    attr_reader :id
    # The amount of PP remaining for this move.
    attr_reader :pp
    # The number of PP Ups used on this move (each one adds 20% to the total PP).
    attr_reader :ppup

    # Creates a new Move object.
    # @param move_id [Symbol, String, Integer] move ID
    def initialize(move_id)
      @id   = GameData::Move.get(move_id).id
      @ppup = 0
      @pp   = total_pp
    end

    # Sets this move's ID, and caps the PP amount if it is now greater than this
    # move's total PP.
    # @param value [Symbol, String, Integer] the new move ID
    def id=(value)
      @id = GameData::Move.get(value).id
      @pp = @pp.clamp(0, total_pp)
    end

    # Sets this move's PP, capping it at this move's total PP.
    # @param value [Integer] the new PP amount
    def pp=(value)
      @pp = value.clamp(0, total_pp)
    end

    # Sets this move's PP Up count, and caps the PP if necessary.
    # @param value [Integer] the new PP Up value
    def ppup=(value)
      @ppup = value
      @pp = @pp.clamp(0, total_pp)
    end

    # Returns the total PP of this move, taking PP Ups into account.
    # @return [Integer] total PP
    def total_pp
      max_pp = GameData::Move.get(@id).total_pp
      return max_pp + max_pp * @ppup / 5
    end
    alias totalpp total_pp

    def function_code; return GameData::Move.get(@id).function_code; end
    def base_damage;   return GameData::Move.get(@id).base_damage;   end
    def type;          return GameData::Move.get(@id).type;          end
    def category;      return GameData::Move.get(@id).category;      end
    def accuracy;      return GameData::Move.get(@id).accuracy;      end
    def effect_chance; return GameData::Move.get(@id).effect_chance; end
    def target;        return GameData::Move.get(@id).target;        end
    def priority;      return GameData::Move.get(@id).priority;      end
    def flags;         return GameData::Move.get(@id).flags;         end
    def name;          return GameData::Move.get(@id).name;          end
    def description;   return GameData::Move.get(@id).description;   end
    def hidden_move?;  return GameData::Move.get(@id).hidden_move?;  end
  end
end

#===============================================================================
# Legacy move object known by Pokémon.
#===============================================================================
# @deprecated Use {Pokemon#Move} instead. PBMove is slated to be removed in v20.
class PBMove
  attr_reader :id, :pp, :ppup

  def self.convert(move)
    ret = Pokemon::Move.new(move.id)
    ret.ppup = move.ppup
    ret.pp = move.pp
    return ret
  end
end
