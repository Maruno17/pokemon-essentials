class MKAI
  attr_reader :battle
  attr_reader :sides

  def initialize(battle, wild_battle)
    @battle = battle
    @sides = [Side.new(self, 0), Side.new(self, 1, wild_battle)]
    MKAI.log("AI initialized")
  end

  def self.battler_to_proj_index(battlerIndex)
    if battlerIndex % 2 == 0 # Player side: 0, 2, 4 -> 0, 1, 2
      return battlerIndex / 2
    else # Opponent side: 1, 3, 5 -> 0, 1, 2
      return (battlerIndex - 1) / 2
    end
  end

  def self.weighted_rand(weights)
    num = rand(weights.sum)
    for i in 0...weights.size
      if num < weights[i]
        return i
      else
        num -= weights[i]
      end
    end
    return nil
  end

  def self.get_weights(factor, weights)
    avg = weights.sum / weights.size.to_f
    newweights = weights.map do |e|
      diff = e - avg
      next [0, ((e - diff * factor) * 100).round].max
    end
    return newweights
  end

  def self.weighted_factored_rand(factor, weights)
    avg = weights.sum / weights.size.to_f
    newweights = weights.map do |e|
      diff = e - avg
      next [0, ((e - diff * factor) * 100).round].max
    end
    return weighted_rand(newweights)
  end

  def self.log(msg)
    echoln msg
  end

  def battler_to_projection(battler)
    @sides.each do |side|
      side.battlers.each do |projection|
        if projection && projection.pokemon == battler.pokemon
          return projection
        end
      end
      side.party.each do |projection|
        if projection && projection.pokemon == battler.pokemon
          return projection
        end
      end
    end
    return nil
  end

  def pokemon_to_projection(pokemon)
    @sides.each do |side|
      side.battlers.each do |projection|
        if projection && projection.pokemon == pokemon
          return projection
        end
      end
      side.party.each do |projection|
        if projection && projection.pokemon == pokemon
          return projection
        end
      end
    end
    return nil
  end

  def register_damage(move, user, target, damage)
    user = battler_to_projection(user)
    target = battler_to_projection(target)
    user.register_damage_dealt(move, target, damage)
    target.register_damage_taken(move, user, damage)
  end

  def faint_battler(battler)
    # Remove the battler from the AI's list of the active battlers
    @sides.each do |side|
      side.battlers.each_with_index do |proj, index|
        if proj && proj.battler == battler
          # Decouple the projection from the battler
          side.recall(battler.index)
          side.battlers[index] = nil
          break
        end
      end
    end
  end

  def end_of_round
    @sides.each { |side| side.end_of_round }
  end

  def reveal_ability(battler)
    @sides.each do |side|
      side.battlers.each do |proj|
        if proj && proj.battler == battler && !proj.revealed_ability
          proj.revealed_ability = true
          MKAI.log("#{proj.pokemon.name}'s ability was revealed.")
          break
        end
      end
    end
  end

  def reveal_item(battler)
    @sides.each do |side|
      side.battlers.each do |proj|
        if proj.battler == battler && !proj.revealed_item
          proj.revealed_item = true
          MKAI.log("#{proj.pokemon.name}'s item was revealed.")
          break
        end
      end
    end
  end
end