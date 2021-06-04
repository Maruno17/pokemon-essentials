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
  HEART_GAUGE_SIZE = 3840

  alias :__shadow_expeq :exp=
  def exp=(value)
    if shadowPokemon?
      @saved_exp += value - @exp
    else
      __shadow_expeq(value)
    end
  end

  alias :__shadow_hpeq :hp=
  def hp=(value)
    __shadow_hpeq(value)
    @hyper_mode = false if @hp <= 0
  end

  def heart_gauge
    return @heart_gauge || 0
  end

  def adjustHeart(value)
    return if !shadowPokemon?
    @heart_gauge = (self.heart_gauge + value).clamp(0, HEART_GAUGE_SIZE)
  end

  def heartStage
    return 0 if !shadowPokemon?
    stage_size = HEART_GAUGE_SIZE / 5.0
    return ([self.heart_gauge, HEART_GAUGE_SIZE].min / stage_size).ceil
  end

  def shadowPokemon?
    return @shadow && @heart_gauge && @heart_gauge >= 0
  end
  alias isShadow? shadowPokemon?

  def hyper_mode
    return (self.heart_gauge == 0 || @hp == 0) ? false : @hyper_mode
  end

  def makeShadow
    @shadow       = true
    @heart_gauge  = HEART_GAUGE_SIZE
    @hyper_mode   = false
    @saved_exp    = 0
    @saved_ev     = {}
    GameData::Stat.each_main { |s| @saved_ev[s.id] = 0 }
    @shadow_moves = []
    # Retrieve Shadow moveset for this Pokémon
    shadow_moveset = pbLoadShadowMovesets[species_data.id]
    shadow_moveset = pbLoadShadowMovesets[@species] if !shadow_moveset || shadow_moveset.length == 0
    # Record this Pokémon's Shadow moves
    if shadow_moveset && shadow_moveset.length > 0
      for i in 0...[shadow_moveset.length, MAX_MOVES].min
        @shadow_moves[i] = shadow_moveset[i]
      end
    elsif GameData::Move.exists?(:SHADOWRUSH)
      # No Shadow moveset defined; just use Shadow Rush
      @shadow_moves[0] = :SHADOWRUSH
    else
      raise _INTL("Expected Shadow moves or Shadow Rush to be defined, but they weren't.")
    end
    # Record this Pokémon's original moves
    @moves.each_with_index { |m, i| @shadow_moves[MAX_MOVES + i] = m.id }
    # Update moves
    update_shadow_moves
  end

  def update_shadow_moves(relearn_all_moves = false)
    return if !@shadow_moves
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

  alias :__shadow_clone :clone
  def clone
    ret = __shadow_clone
    if @saved_ev
      GameData::Stat.each_main { |s| ret.saved_ev[s.id] = @saved_ev[s.id] }
    end
    ret.shadow_moves = @shadow_moves.clone if @shadow_moves
    return ret
  end
end
