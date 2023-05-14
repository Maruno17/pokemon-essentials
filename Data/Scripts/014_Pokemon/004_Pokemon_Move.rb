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
    # @param move_id [Symbol, String, GameData::Move] move ID
    def initialize(move_id)
      @id   = GameData::Move.get(move_id).id
      @ppup = 0
      @pp   = total_pp
    end

    # Sets this move's ID, and caps the PP amount if it is now greater than this
    # move's total PP.
    # @param value [Symbol, String, GameData::Move] the new move ID
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
      return max_pp + (max_pp * @ppup / 5)
    end
    alias totalpp total_pp

    def function_code;  return GameData::Move.get(@id).function_code; end
    def power;          return GameData::Move.get(@id).power;         end
    def type;           return GameData::Move.get(@id).type;          end
    def category;       return GameData::Move.get(@id).category;      end
    def physical_move?; return GameData::Move.get(@id).physical?;     end
    def special_move?;  return GameData::Move.get(@id).special?;      end
    def status_move?;   return GameData::Move.get(@id).status?;       end
    def accuracy;       return GameData::Move.get(@id).accuracy;      end
    def effect_chance;  return GameData::Move.get(@id).effect_chance; end
    def target;         return GameData::Move.get(@id).target;        end
    def priority;       return GameData::Move.get(@id).priority;      end
    def flags;          return GameData::Move.get(@id).flags;         end
    def name;           return GameData::Move.get(@id).name;          end
    def description;    return GameData::Move.get(@id).description;   end
    def hidden_move?;   return GameData::Move.get(@id).hidden_move?;  end

    # @deprecated This method is slated to be removed in v22.
    def base_damage
      Deprecation.warn_method("base_damage", "v22", "power")
      return @power
    end

    def display_type(pkmn);     return GameData::Move.get(@id).display_type(pkmn, self);     end
    def display_category(pkmn); return GameData::Move.get(@id).display_category(pkmn, self); end
    def display_damage(pkmn);   return GameData::Move.get(@id).display_damage(pkmn, self);   end
    def display_accuracy(pkmn); return GameData::Move.get(@id).display_accuracy(pkmn, self); end
  end
end
