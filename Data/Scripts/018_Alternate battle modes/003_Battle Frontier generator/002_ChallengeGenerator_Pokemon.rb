$baseStatTotal   = {}
$babySpecies     = {}
$minimumLevel    = {}
$evolutions      = {}
$legalMoves      = {}    # For each species, all the moves they have access to
$legalMovesLevel = 0     # Level for which $legalMoves were calculated
$tmMoves         = nil   # Array of all moves teachable by a HM/TM/TR

def pbBaseStatTotal(species)
  baseStats = GameData::Species.get(species).base_stats
  ret = 0
  baseStats.each_value { |s| ret += s }
  return ret
end

def baseStatTotal(species)
  $baseStatTotal[species] = pbBaseStatTotal(species) if !$baseStatTotal[species]
  return $baseStatTotal[species]
end

def babySpecies(species)
  $babySpecies[species] = GameData::Species.get(species).get_baby_species if !$babySpecies[species]
  return $babySpecies[species]
end

def minimumLevel(species)
  $minimumLevel[species] = GameData::Species.get(species).minimum_level if !$minimumLevel[species]
  return $minimumLevel[species]
end

def evolutions(species)
  $evolutions[species] = GameData::Species.get(species).get_evolutions(true) if !$evolutions[species]
  return $evolutions[species]
end

#===============================================================================
#
#===============================================================================
# Used to replace Sketch with any other move.
def pbRandomMove
  keys = GameData::Move.keys
  loop do
    move_id = keys.sample
    move = GameData::Move.get(move_id)
    next if ["Struggle", "ReplaceMoveWithTargetLastMoveUsed"].include?(move.function_code)
    return move.id
  end
end

def pbGetLegalMoves2(species, maxlevel)
  species_data = GameData::Species.get(species)
  moves = []
  return moves if !species_data
  # Populate available moves array (moves)
  species_data.moves.each { |m| addMove(moves, m[1], 2) if m[0] <= maxlevel }
  if !$tmMoves
    $tmMoves = []
    GameData::Item.each { |i| $tmMoves.push(i.move) if i.is_machine? }
  end
  species_data.tutor_moves.each { |m| addMove(moves, m, 0) if $tmMoves.include?(m) }
  babyspecies = babySpecies(species)
  GameData::Species.get(babyspecies).egg_moves.each { |m| addMove(moves, m, 2) }
  movedatas = []
  moves.each do |move|
    movedatas.push([move, GameData::Move.get(move)])
  end
  # Delete less powerful moves
  deleteAll = proc { |a, item|
    while a.include?(item)
      a.delete(item)
    end
  }
  moves.each do |move|
    md = GameData::Move.get(move)
    movedatas.each do |move2|
      # If we have a move that always hits, remove all other moves with no
      # effect of the same type and <= base power
      if md.accuracy == 0 && move2[1].function_code == "None" &&
         md.type == move2[1].type && md.power >= move2[1].power
        deleteAll.call(moves, move2[0])
      # If we have two status moves that have the same function code, delete the
      # one with lower accuracy (Supersonic vs. Confuse Ray, etc.)
      elsif md.function_code == move2[1].function_code && md.power == 0 &&
            move2[1].power == 0 && md.accuracy > move2[1].accuracy
        deleteAll.call(moves, move2[0])
      # Delete poison-causing moves if we have a move that causes toxic
      elsif md.function_code == "BadPoisonTarget" && move2[1].function_code == "PoisonTarget"
        deleteAll.call(moves, move2[0])
      # If we have two moves with the same function code and type, and one of
      # them is damaging and has 10/15/the same PP as the other move and EITHER
      # does more damage than the other move OR does the same damage but is more
      # accurate, delete the other move (Surf, Flamethrower, Thunderbolt, etc.)
      elsif md.function_code == move2[1].function_code && md.power != 0 &&
            md.type == move2[1].type &&
            (md.total_pp == 15 || md.total_pp == 10 || md.total_pp == move2[1].total_pp) &&
            (md.power > move2[1].power ||
            (md.power == move2[1].power && md.accuracy > move2[1].accuracy))
        deleteAll.call(moves, move2[0])
      end
    end
  end
  return moves
end

def addMove(moves, move, base)
  data = GameData::Move.get(move)
  return if moves.include?(data.id)
  return if [:BUBBLE, :BUBBLEBEAM].include?(data.id)   # Never add these moves
  count = base + 1   # Number of times to add move to moves
  count = base if data.function_code == "None" && data.power <= 40
  if data.power <= 30 || [:GROWL, :TAILWHIP, :LEER].include?(data.id)
    count = base
  end
  if data.power >= 60 ||
     [:REFLECT, :LIGHTSCREEN, :SAFEGUARD, :SUBSTITUTE, :FAKEOUT].include?(data.id)
    count = base + 2
  end
  count = base + 3 if data.power >= 80 && data.type == :NORMAL
  if [:PROTECT, :DETECT, :TOXIC, :AERIALACE, :WILLOWISP, :SPORE, :THUNDERWAVE,
      :HYPNOSIS, :CONFUSERAY, :ENDURE, :SWORDSDANCE].include?(data.id)
    count = base + 3
  end
  count.times { moves.push(data.id) }
end

# Returns whether moves contains any move with the same type as thismove but
# with a higher base damage than it.
def hasMorePowerfulMove(moves, thismove)
  thisdata = GameData::Move.get(thismove)
  return false if thisdata.power == 0
  moves.each do |move|
    next if !move
    moveData = GameData::Move.get(move)
    if moveData.type == thisdata.type && moveData.power > thisdata.power
      return true
    end
  end
  return false
end

#===============================================================================
# Generate a random Pokémon that adheres to the given rules.
#===============================================================================
def pbRandomPokemonFromRule(rules, trainer)
  pkmn = nil
  iteration = -1
  loop do
    iteration += 1
    species = nil
    level = rules.ruleset.suggestedLevel
    keys = GameData::Species.keys
    loop do
      loop do
        species = keys.sample
        break if GameData::Species.get(species).form == 0
      end
      r = rand(20)
      bst = baseStatTotal(species)
      next if level < minimumLevel(species)
      if iteration.even?
        next if r < 16 && bst < 400
        next if r < 13 && bst < 500
      else
        next if bst > 400
        next if r < 10 && babySpecies(species) != species
      end
      next if r < 10 && babySpecies(species) == species
      next if r < 7 && evolutions(species).length > 0
      break
    end
    ev = []
    GameData::Stat.each_main { |s| ev.push(s.id) if rand(100) < 50 }
    nature = nil
    keys = GameData::Nature.keys
    loop do
      nature = keys.sample
      nature_data = GameData::Nature.get(nature)
      if [:LAX, :GENTLE].include?(nature_data.id) || nature_data.stat_changes.length == 0
        next if rand(20) < 19
      else
        raised_emphasis = false
        lowered_emphasis = false
        nature_data.stat_changes.each do |change|
          next if !ev.include?(change[0])
          raised_emphasis = true if change[1] > 0
          lowered_emphasis = true if change[1] < 0
        end
        next if rand(10) < 6 && !raised_emphasis
        next if rand(10) < 9 && lowered_emphasis
      end
      break
    end
    $legalMoves = {} if level != $legalMovesLevel
    $legalMovesLevel = level
    $legalMoves[species] = pbGetLegalMoves2(species, level) if !$legalMoves[species]
    itemlist = [
      :ORANBERRY, :SITRUSBERRY, :ADAMANTORB, :BABIRIBERRY,
      :BLACKSLUDGE, :BRIGHTPOWDER, :CHESTOBERRY, :CHOICEBAND,
      :CHOICESCARF, :CHOICESPECS, :CHOPLEBERRY, :DAMPROCK,
      :DEEPSEATOOTH, :EXPERTBELT, :FLAMEORB, :FOCUSSASH,
      :FOCUSBAND, :HEATROCK, :LEFTOVERS, :LIFEORB, :LIGHTBALL,
      :LIGHTCLAY, :LUMBERRY, :OCCABERRY, :PETAYABERRY, :SALACBERRY,
      :SCOPELENS, :SHEDSHELL, :SHELLBELL, :SHUCABERRY, :LIECHIBERRY,
      :SILKSCARF, :THICKCLUB, :TOXICORB, :WIDELENS, :YACHEBERRY,
      :HABANBERRY, :SOULDEW, :PASSHOBERRY, :QUICKCLAW, :WHITEHERB
    ]
    # Most used: Leftovers, Life Orb, Choice Band, Choice Scarf, Focus Sash
    item = nil
    loop do
      if rand(40) == 0
        item = :LEFTOVERS
        break
      end
      item = itemlist[rand(itemlist.length)]
      next if !item
      case item
      when :LIGHTBALL
        next if species != :PIKACHU
      when :SHEDSHELL
        next if species != :FORRETRESS && species != :SKARMORY
      when :SOULDEW
        next if species != :LATIOS && species != :LATIAS
      when :FOCUSSASH
        next if baseStatTotal(species) > 450 && rand(10) < 8
      when :ADAMANTORB
        next if species != :DIALGA
      when :PASSHOBERRY
        next if species != :STEELIX
      when :BABIRIBERRY
        next if species != :TYRANITAR
      when :HABANBERRY
        next if species != :GARCHOMP
      when :OCCABERRY
        next if species != :METAGROSS
      when :CHOPLEBERRY
        next if species != :UMBREON
      when :YACHEBERRY
        next if ![:TORTERRA, :GLISCOR, :DRAGONAIR].include?(species)
      when :SHUCABERRY
        next if species != :HEATRAN
      when :DEEPSEATOOTH
        next if species != :CLAMPERL
      when :THICKCLUB
        next if ![:CUBONE, :MAROWAK].include?(species)
      when :LIECHIBERRY
        ev.push(:ATTACK) if !ev.include?(:ATTACK) && rand(100) < 50
      when :SALACBERRY
        ev.push(:SPEED) if !ev.include?(:SPEED) && rand(100) < 50
      when :PETAYABERRY
        ev.push(:SPECIAL_ATTACK) if !ev.include?(:SPECIAL_ATTACK) && rand(100) < 50
      end
      break
    end
    if level < 10 && GameData::Item.exists?(:ORANBERRY)
      item = :ORANBERRY if rand(40) == 0 || item == :SITRUSBERRY
    elsif level > 20 && GameData::Item.exists?(:SITRUSBERRY)
      item = :SITRUSBERRY if rand(40) == 0 || item == :ORANBERRY
    end
    moves = $legalMoves[species]
    sketch = false
    if moves[0] == :SKETCH
      sketch = true
      Pokemon::MAX_MOVES.times { |m| moves[m] = pbRandomMove }
    end
    next if moves.length == 0
    if (moves | []).length < Pokemon::MAX_MOVES
      moves = [:TACKLE] if moves.length == 0
      moves |= []
    else
      newmoves = []
      rest = GameData::Move.exists?(:REST) ? :REST : nil
      spitup = GameData::Move.exists?(:SPITUP) ? :SPITUP : nil
      swallow = GameData::Move.exists?(:SWALLOW) ? :SWALLOW : nil
      stockpile = GameData::Move.exists?(:STOCKPILE) ? :STOCKPILE : nil
      snore = GameData::Move.exists?(:SNORE) ? :SNORE : nil
      sleeptalk = GameData::Move.exists?(:SLEEPTALK) ? :SLEEPTALK : nil
      loop do
        newmoves.clear
        while newmoves.length < [moves.length, Pokemon::MAX_MOVES].min
          m = moves[rand(moves.length)]
          next if rand(100) < 50 && hasMorePowerfulMove(moves, m)
          newmoves.push(m) if m && !newmoves.include?(m)
        end
        if (newmoves.include?(spitup) || newmoves.include?(swallow)) &&
           !newmoves.include?(stockpile) && !sketch
          next
        end
        if (!newmoves.include?(spitup) && !newmoves.include?(swallow)) &&
           newmoves.include?(stockpile) && !sketch
          next
        end
        if newmoves.include?(sleeptalk) && !newmoves.include?(rest) &&
           !((sketch || !moves.include?(rest)) && rand(100) < 20)
          next
        end
        if newmoves.include?(snore) && !newmoves.include?(rest) &&
           !((sketch || !moves.include?(rest)) && rand(100) < 20)
          next
        end
        total_power = 0
        hasPhysical = false
        hasSpecial = false
        hasNormal = false
        newmoves.each do |move|
          d = GameData::Move.get(move)
          next if d.power == 0
          total_power += d.power
          hasNormal = true if d.type == :NORMAL
          hasPhysical = true if d.category == 0
          hasSpecial = true if d.category == 1
        end
        if !hasPhysical && ev.include?(:ATTACK) && rand(100) < 80
          # No physical attack, but emphasizes Attack
          next
        end
        if !hasSpecial && ev.include?(:SPECIAL_ATTACK) && rand(100) < 80
          # No special attack, but emphasizes Special Attack
          next
        end
        r = rand(10)
        next if r > 6 && total_power > 180
        next if r > 8 && total_power > 140
        next if total_power == 0 && rand(100) < 95
        ############
        # Moves accepted
        if hasPhysical && !hasSpecial
          ev.push(:ATTACK) if rand(100) < 80
          ev.delete(:SPECIAL_ATTACK) if rand(100) < 80
        end
        if !hasPhysical && hasSpecial
          ev.delete(:ATTACK) if rand(100) < 80
          ev.push(:SPECIAL_ATTACK) if rand(100) < 80
        end
        item = :LEFTOVERS if !hasNormal && item == :SILKSCARF
        moves = newmoves
        break
      end
    end
    if item == :LIGHTCLAY && moves.none? { |m| [:LIGHTSCREEN, :REFLECT].include?(m) }
      item = :LEFTOVERS
    end
    if item == :BLACKSLUDGE
      types = GameData::Species.get(species).types
      item = :LEFTOVERS if !types.include?(:POISON)
    end
    item = :LEFTOVERS if item == :HEATROCK && moves.none? { |m| m == :SUNNYDAY }
    if item == :DAMPROCK && moves.none? { |m| m == :RAINDANCE }
      item = :LEFTOVERS
    end
    if moves.any? { |m| m == :REST }
      item = :LUMBERRY if rand(100) < 33
      item = :CHESTOBERRY if rand(100) < 25
    end
    pk = PBPokemon.new(species, item, nature, moves[0], moves[1], moves[2], moves[3], ev)
    pkmn = pk.createPokemon(level, 31, trainer)
    break if rules.ruleset.isPokemonValid?(pkmn)
  end
  return pkmn
end
