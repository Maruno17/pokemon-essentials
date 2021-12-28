#===============================================================================
# Pokémon class.
#===============================================================================
class Pokemon
  attr_accessor :shadow
  attr_writer   :heart_gauge
  attr_writer   :hyper_mode
  attr_accessor :saved_exp
  attr_accessor :saved_ev
  attr_accessor :shadow_moves
  attr_accessor :heart_gauge_step_counter

  alias __shadow_expeq exp= unless method_defined?(:__shadow_expeq)
  def exp=(value)
    if shadowPokemon?
      @saved_exp += value - @exp
    else
      __shadow_expeq(value)
    end
  end

  alias __shadow_hpeq hp= unless method_defined?(:__shadow_hpeq)
  def hp=(value)
    __shadow_hpeq(value)
    @hyper_mode = false if @hp <= 0
  end

  def heart_gauge
    return @heart_gauge || 0
  end

  def shadow_data
    ret = GameData::ShadowPokemon.try_get(species_data.id)
    ret = GameData::ShadowPokemon.try_get(@species) if !ret
    return ret
  end

  def max_gauge_size
    data = shadow_data
    return (data) ? data.gauge_size : GameData::ShadowPokemon::HEART_GAUGE_SIZE
  end

  def adjustHeart(value)
    return if !shadowPokemon?
    @heart_gauge = (self.heart_gauge + value).clamp(0, max_gauge_size)
  end

  def change_heart_gauge(method, multiplier = 1)
    return if !shadowPokemon?
    heart_amounts = {
      # [sending into battle, call to, walking 256 steps, using scent]
      :HARDY   => [110, 300, 100,  90],
      :LONELY  => [ 70, 330, 100, 130],
      :BRAVE   => [130, 270,  90,  80],
      :ADAMANT => [110, 270, 110,  80],
      :NAUGHTY => [120, 270, 110,  70],
      :BOLD    => [110, 270,  90, 100],
      :DOCILE  => [100, 360,  80, 120],
      :RELAXED => [ 90, 270, 110, 100],
      :IMPISH  => [120, 300, 100,  80],
      :LAX     => [100, 270,  90, 110],
      :TIMID   => [ 70, 330, 110, 120],
      :HASTY   => [130, 300,  70, 100],
      :SERIOUS => [100, 330, 110,  90],
      :JOLLY   => [120, 300,  90,  90],
      :NAIVE   => [100, 300, 120,  80],
      :MODEST  => [ 70, 300, 120, 110],
      :MILD    => [ 80, 270, 100, 120],
      :QUIET   => [100, 300, 100, 100],
      :BASHFUL => [ 80, 300,  90, 130],
      :RASH    => [ 90, 300,  90, 120],
      :CALM    => [ 80, 300, 110, 110],
      :GENTLE  => [ 70, 300, 130, 100],
      :SASSY   => [130, 240, 100,  70],
      :CAREFUL => [ 90, 300, 100, 110],
      :QUIRKY  => [130, 270,  80,  90]
    }
    amt = 100
    case method
    when "battle"
      amt = (heart_amounts[@nature]) ? heart_amounts[@nature][0] : 100
    when "call"
      amt = (heart_amounts[@nature]) ? heart_amounts[@nature][1] : 300
    when "walking"
      amt = (heart_amounts[@nature]) ? heart_amounts[@nature][2] : 100
    when "scent"
      amt = (heart_amounts[@nature]) ? heart_amounts[@nature][3] : 100
      amt *= multiplier
    else
      raise _INTL("Unknown heart gauge-changing method: {1}", method.to_s)
    end
    adjustHeart(-amt)
  end

  def heartStage
    return 0 if !shadowPokemon?
    max_size = max_gauge_size
    stage_size = max_size / 5.0
    return ([self.heart_gauge, max_size].min / stage_size).ceil
  end

  def shadowPokemon?
    return @shadow && @heart_gauge && @heart_gauge >= 0
  end

  def hyper_mode
    return (self.heart_gauge == 0 || @hp == 0) ? false : @hyper_mode
  end

  alias __shadow__changeHappiness changeHappiness unless method_defined?(:__shadow__changeHappiness)
  def changeHappiness(method)
    return if shadowPokemon? && heartStage >= 4
    __shadow__changeHappiness(method)
  end

  def makeShadow
    @shadow       = true
    @hyper_mode   = false
    @saved_exp    = 0
    @saved_ev     = {}
    GameData::Stat.each_main { |s| @saved_ev[s.id] = 0 }
    @heart_gauge  = max_gauge_size
    @heart_gauge_step_counter = 0
    @shadow_moves = []
    # Retrieve Shadow moveset for this Pokémon
    data = shadow_data
    # Record this Pokémon's Shadow moves
    if data
      data.moves.each do |m|
        @shadow_moves.push(m.to_sym) if GameData::Move.exists?(m.to_sym)
        break if @shadow_moves.length >= MAX_MOVES
      end
    end
    if @shadow_moves.empty? && GameData::Move.exists?(:SHADOWRUSH)
      @shadow_moves.push(:SHADOWRUSH)
    end
    # Record this Pokémon's original moves
    if !@shadow_moves.empty?
      @moves.each_with_index { |m, i| @shadow_moves[MAX_MOVES + i] = m.id }
      update_shadow_moves
    end
  end

  def update_shadow_moves(relearn_all_moves = false)
    return if !@shadow_moves || @shadow_moves.empty?
    # Not a Shadow Pokémon (any more); relearn all its original moves
    if !shadowPokemon?
      if @shadow_moves.length > MAX_MOVES
        new_moves = []
        @shadow_moves.each_with_index { |m, i| new_moves.push(m) if m && i >= MAX_MOVES }
        replace_moves(new_moves)
      end
      @shadow_moves = nil
      return
    end
    # Is a Shadow Pokémon; ensure it knows the appropriate moves depending on its heart stage
    # Start with all Shadow moves
    new_moves = []
    @shadow_moves.each_with_index { |m, i| new_moves.push(m) if m && i < MAX_MOVES }
    num_shadow_moves = new_moves.length
    # Add some original moves (skipping ones in the same slot as a Shadow Move)
    num_original_moves = (relearn_all_moves) ? 3 : [3, 3, 2, 1, 1, 0][self.heartStage]
    if num_original_moves > 0
      relearned_count = 0
      @shadow_moves.each_with_index do |m, i|
        next if !m || i < MAX_MOVES + num_shadow_moves
        new_moves.push(m)
        relearned_count += 1
        break if relearned_count >= num_original_moves
      end
    end
    # Relearn Shadow moves plus some original moves (may not change anything)
    replace_moves(new_moves)
  end

  def replace_moves(new_moves)
    new_moves.each do |move|
      next if !move || !GameData::Move.exists?(move) || hasMove?(move)
      if numMoves < Pokemon::MAX_MOVES   # Has an empty slot; just learn move
        learn_move(move)
        next
      end
      @moves.each do |m|
        next if new_moves.include?(m.id)
        m.id = GameData::Move.get(move).id
        break
      end
    end
  end

  def purifiable?
    return false if !shadowPokemon? || self.heart_gauge > 0
    return false if isSpecies?(:LUGIA)
    return true
  end

  def check_ready_to_purify
    return if !shadowPokemon?
    update_shadow_moves
    pbMessage(_INTL("{1} can now be purified!", self.name)) if self.heart_gauge == 0
  end

  def add_evs(added_evs)
    total = 0
    @ev.each_value { |e| total += e }
    GameData::Stat.each_main do |s|
      addition = added_evs[s.id].clamp(0, Pokemon::EV_STAT_LIMIT - @ev[s.id])
      addition = addition.clamp(0, Pokemon::EV_LIMIT - total)
      next if addition == 0
      @ev[s.id] += addition
      total += addition
    end
  end

  alias __shadow_clone clone unless method_defined?(:__shadow_clone)
  def clone
    ret = __shadow_clone
    if @saved_ev
      GameData::Stat.each_main { |s| ret.saved_ev[s.id] = @saved_ev[s.id] }
    end
    ret.shadow_moves = @shadow_moves.clone if @shadow_moves
    return ret
  end
end
