class MKAI
  class Side
    attr_reader :ai
    attr_reader :index
    attr_reader :battlers
    attr_reader :party
    attr_reader :trainers
    attr_reader :flags

    def initialize(ai, index, wild_pokemon = false)
      @ai = ai
      @index = index
      @battle = @ai.battle
      @wild_pokemon = wild_pokemon
      @battlers = []
      @party = []
      @flags = {}
    end

    def effects
      return @battle.sides[@index].effects
    end

    def set_party(party)
      @party = party.map { |pokemon| BattlerProjection.new(self, pokemon, @wild_pokemon) }
    end

    def set_trainers(trainers)
      @trainers = trainers
    end

    def opposing_side
      return @ai.sides[1 - @index]
    end

    def recall(battlerIndex)
      index = MKAI.battler_to_proj_index(battlerIndex)
      proj = @battlers[index]
      if proj.nil?
        raise "Battler to be recalled was not found in the active battlers list."
      end
      if !proj.active?
        raise "Battler to be recalled was not active."
      end
      @battlers[index] = nil
      proj.battler = nil
    end

    def send_out(battlerIndex, battler)
      proj = @party.find { |proj| proj && proj.pokemon == battler.pokemon }
      if proj.nil?
        raise "Battler to be sent-out was not found in the party list."
      end
      if proj.active?
        raise "Battler to be sent-out was already sent out before."
      end
      index = MKAI.battler_to_proj_index(battlerIndex)
      @battlers[index] = proj
      proj.ai_index = index
      proj.battler = battler
    end

    def end_of_round
      @battlers.each { |proj| proj.end_of_round if proj }
      @flags = {}
    end
  end
end