#===============================================================================
# Move objects known by Pokémon.
#===============================================================================
class PBMove
  attr_reader   :id     # This move's ID
  attr_accessor :pp     # The amount of PP remaining for this move
  attr_accessor :ppup   # The number of PP Ups used on this move

  # Initializes this object to the specified move ID.
  def initialize(move_id)
    @id = GameData::Move.get(move_id).id
    @ppup = 0
    @pp   = total_pp
  end

  # Changes this move's ID, and caps the PP amount if it is now greater than the
  # new move's total PP.
  def id=(value)
    old_id = @id
    @id = GameData::Move.get(value).id
    @pp = [@pp, total_pp].min
  end

  # Gets the maximum PP for this move.
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
