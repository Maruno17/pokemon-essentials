# TODO:
# Remove Minimize double damage from base damage calculator
# as it is already factored into tramplesMinimize? in the score handlers

=begin
Console.setup_console

Events.onTrainerPartyLoad += proc do |sender, e|
  if e[0]   # Trainer data should exist to be loaded, but may not exist somehow
    trainer = e[0][0] # A PokeBattle_Trainer object of the loaded trainer
    items = e[0][1]   # An array of the trainer's items they can use
    e[0][2] = []

    p1 = pbGenPoke(:RAICHU, 55, trainer)
    p1.moves = [
#      PBMove.new(getConst(PBMoves,:SWORDSDANCE)),
      PBMove.new(getConst(PBMoves,:CHARGEBEAM)),
      PBMove.new(getConst(PBMoves,:CRUNCH)),
      PBMove.new(getConst(PBMoves,:DEFENSECURL)),
      PBMove.new(getConst(PBMoves,:SLASH)),
    ]
    p1.abilityflag = 1
#    p1.item = getConst(PBItems,:POWERHERB)
#    p1.status = PBStatuses::FROZEN
#    p1.hp = p.totalhp.to_f / 10 * 3
    p1.hp = 1
    e[0][2] << p1

#    p2 = pbGenPoke(:GOLEM, 55, trainer)
#    p2.moves = p1.moves.map { |m| m.clone }
#    p2.moves = [
#      PBMove.new(getConst(PBMoves,:TACKLE)),
#      PBMove.new(getConst(PBMoves,:HEALPULSE))
#    ]
#    e[0][2] << p2

    e[0][2] << pbGenPoke(:LEAVANNY, 50, trainer)
#    e[0][2] << pbGenPoke(:MISMAGIUS, 50, trainer)
#    e[0][2] << pbGenPoke(:WALREIN, 53, trainer)
#    e[0][2] << pbGenPoke(:TYPHLOSION, 50, trainer)
#    e[0][2] << pbGenPoke(:GOLEM, 51, trainer)
#    e[0][2] << pbGenPoke(:RAICHU, 52, trainer)

    items << PBItems::FULLRESTORE
  end
end
=end

class MKAI
  # If true, the AI will always know the enemy's held item, even if it has not
  # been revealed in normal gameplay.
  AI_KNOWS_HELD_ITEMS = true

  # If true, the AI wil always know the enemy's ability, even if it has not
  # been revealed in normal gameplay.
  AI_KNOWS_UNSEEN_ABILITIES = true

  # If true, the AI will know the enemy's moves, even if they have not been
  # revealed in normal gameplay.
  AI_KNOWS_ENEMY_MOVES = true

  class BattlerProjection
    attr_accessor :ai_index
    attr_accessor :battler
    attr_reader :pokemon
    attr_reader :side
    attr_reader :damage_taken
    attr_reader :damage_dealt
    attr_accessor :revealed_ability
    attr_accessor :revealed_item
    attr_accessor :used_moves
    attr_reader :flags

    def initialize(side, pokemon, wild_pokemon = false)
      @side = side
      @pokemon = pokemon
      @battler = nil
      @ai = @side.ai
      @battle = @ai.battle
      @damage_taken = []
      @damage_dealt = []
      @ai_index = nil
      @used_moves = []
      @revealed_ability = false
      @revealed_item = false
      @skill = wild_pokemon ? 0 : 200
      @flags = {}
    end

    alias original_missing method_missing
    def method_missing(name, *args, &block)
      if @battler.respond_to?(name)
        MKAI.log("WARNING: Deferring method `#{name}` to @battler.")
        return @battler.send(name, *args, &block)
      else
        return original_missing(name, *args, &block)
      end
    end

    def opposing_side
      return @side.opposing_side
    end

    def index
      return @side.index == 0 ? @ai_index * 2 : @ai_index * 2 + 1
    end

    def hp
      return @battler.hp
    end

    def fainted?
      return @pokemon.fainted?
    end

    def totalhp
      return @battler.totalhp
    end

    def status
      return @battler.status
    end

    def statusCount
      return @battler.statusCount
    end

    def burned?
      return @battler.burned?
    end

    def poisoned?
      return @battler.poisoned?
    end

    def paralyzed?
      return @battler.paralyzed?
    end

    def frozen?
      return @battler.frozen?
    end

    def asleep?
      return @battler.asleep?
    end

    def confused?
      return @battler.effects[PBEffects::Confusion] > 0
    end

    def level
      return @battler.level
    end

    def active?
      return !@battler.nil?
    end

    def effective_attack
      stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
      stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
      stage = @battler.stages[PBStats::ATTACK] + 6
      return (@battler.attack.to_f * stageMul[stage] / stageDiv[stage]).floor
    end

    def effective_defense
      stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
      stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
      stage = @battler.stages[PBStats::DEFENSE] + 6
      return (@battler.defense.to_f * stageMul[stage] / stageDiv[stage]).floor
    end

    def effective_spatk
      stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
      stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
      stage = @battler.stages[PBStats::SPATK] + 6
      return (@battler.spatk.to_f * stageMul[stage] / stageDiv[stage]).floor
    end

    def effective_spdef
      stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
      stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
      stage = @battler.stages[PBStats::SPDEF] + 6
      return (@battler.spdef.to_f * stageMul[stage] / stageDiv[stage]).floor
    end

    def effective_speed
      stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
      stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
      stage = @battler.stages[PBStats::SPEED] + 6
      return (@battler.speed.to_f * stageMul[stage] / stageDiv[stage]).floor
    end

    def faster_than?(target)
      return self.effective_speed >= target.effective_speed
    end

    def has_non_volatile_status?
      return burned? || poisoned? || paralyzed? || frozen? || asleep?
    end

    # If this is true, this Pokémon will be treated as being a physical attacker.
    # This means that the Pokémon will be more likely to try to use attack-boosting and
    # defense-lowering status moves, and will be even more likely to use strong physical moves
    # if any of these status boosts are active.
    def is_physical_attacker?
      stats = [effective_attack, effective_spatk]
      avg = stats.sum / stats.size.to_f
      min = (avg + (stats.max - avg) / 4 * 3).floor
      avg = avg.floor
      # min is the value the base attack must be above (3/4th avg) in order to for
      # attack to be seen as a "high" value.
      # Count the number of physical moves
      physcount = 0
      attackBoosters = 0
      self.moves.each do |move|
        next if move.pp == 0
        physcount += 1 if move.physicalMove?
        if move.statUp
          for i in 0...move.statUp.size / 2
            attackBoosters += move.statUp[i * 2 + 1] if move.statUp[i * 2] == PBStats::ATTACK
          end
        end
      end
      # If the user doesn't have any physical moves, the Pokémon can never be 
      # a physical attacker.
      return false if physcount == 0
      if effective_attack >= min
        # Has high attack stat
        # All physical moves would be a solid bet since we have a high attack stat.
        return true
      elsif effective_attack >= avg
        # Attack stat is not high, but still above average
        # If this Pokémon has any attack-boosting moves, or more than 1 physical move,
        # we consider this Pokémon capable of being a physical attacker.
        return true if physcount > 1
        return true if attackBoosters >= 1
      end
      return false
    end

    # If this is true, this Pokémon will be treated as being a special attacker.
    # This means that the Pokémon will be more likely to try to use spatk-boosting and
    # spdef-lowering status moves, and will be even more likely to use strong special moves
    # if any of these status boosts are active.
    def is_special_attacker?
      stats = [effective_attack, effective_spatk]
      avg = stats.sum / stats.size.to_f
      min = (avg + (stats.max - avg) / 4 * 3).floor
      avg = avg.floor
      # min is the value the base attack must be above (3/4th avg) in order to for
      # attack to be seen as a "high" value.
      # Count the number of physical moves
      speccount = 0
      spatkBoosters = 0
      self.moves.each do |move|
        next if move.pp == 0
        speccount += 1 if move.specialMove?
        if move.statUp
          for i in 0...move.statUp.size / 2
            spatkBoosters += move.statUp[i * 2 + 1] if move.statUp[i * 2] == PBStats::SPATK
          end
        end
      end
      # If the user doesn't have any physical moves, the Pokémon can never be 
      # a physical attacker.
      return false if speccount == 0
      if effective_spatk >= min
        # Has high spatk stat
        # All special moves would be a solid bet since we have a high spatk stat.
        return true
      elsif effective_spatk >= avg
        # Spatk stat is not high, but still above average
        # If this Pokémon has any spatk-boosting moves, or more than 1 special move,
        # we consider this Pokémon capable of being a special attacker.
        return true if speccount > 1
        return true if spatkBoosters >= 1
      end
      return false
    end

    # Whether the pokemon should mega-evolve
    def should_mega_evolve?(idx)
      # Always mega evolve if the pokemon is able to
      return @battle.pbCanMegaEvolve?(@battler.index)
    end

    def choose_move
      # An array of scores in the format of [move_index, score, target]
      scores = []

      # Calculates whether to use an item
      item_score = get_item_score()
      # Yields [score, item, target&]
      scores << [:ITEM, *item_score]

      # Calculates whether to switch
      switch_score = get_switch_score()
      # Yields [score, pokemon_index]
      scores << [:SWITCH, *switch_score]

      MKAI.log("=" * 10 + " Turn #{@battle.turnCount + 1} " + "=" * 10)
      # Gets the battler projections of the opposing side
      # Calculate a score for each possible target

      targets = opposing_side.battlers.clone
      @side.battlers.each do |proj|
        next if proj == self || proj.nil?
        targets << proj
      end
      targets.each do |target|
        next if target.nil?
        MKAI.log("Moves for #{@battler.pokemon.name} against #{target.pokemon.name}")
        # Calculate a score for all the user's moves
        for i in 0...4
          move = @battler.moves[i]
          if !move.nil?
            next if move.pp <= 0
            target_type = move.pbTarget(@battler)
            target_index = target.index
            if PBTargets.noTargets?(target_type)
              # If move has no targets, affects the user, a side or the whole field
              target_index = -1
            else
              next if !@battle.pbMoveCanTarget?(@battler.index, target.index, target_type)
            end
            # Get the move score given a user and a target
            score = get_move_score(target, move)
            next if score.nil?
            score = 1 if score < 1
            scores << [i, score.round, target_index, target.pokemon.name]
          end
        end
      end

      # If absolutely no good options exist
      if scores.size == 0
        # Then just try to use the very first move with pp
        for i in 0...4
          move = @battler.moves[i]
          next if move.nil?
          if move.pp > 0
            next if @battler.effects[PBEffects::DisableMove] == move.id
            scores << [i, 1, 0, "internal"]
          end
        end
      end

      # If we still don't have any options, that means we have no non-disabled moves with pp left, so we use Struggle.
      if scores.size == 0
        # Struggle
        #scores << [-1, 1000, 0, "internal"]
      end

      # Map the numeric skill factor to a -4..1 range (not hard bounds)
      skill = @skill / -50.0 + 1
      # Generate a random choice based on the skill factor and the score weights
      idx = MKAI.weighted_factored_rand(skill, scores.map { |e| e[1] })
      str = "=" * 30 + "\nSkill: #{@skill}\n"
      weights = MKAI.get_weights(skill, scores.map { |e| e[1] })
      total = weights.sum
      scores.each_with_index do |e, i|
        finalPerc = total == 0 ? 0 : (weights[i] / total.to_f * 100).round
        if i == 0
          # Item
          name = PBItems.getName(e[2])
          score = e[1]
          if score > 0
            str += "ITEM #{name}: #{score} (=> #{finalPerc}%)"
            str += " << CHOSEN" if idx == 0
            str += "\n"
          end
        elsif i == 1
          # Switch
          name = @battle.pbParty(@battler.index)[e[2]].name
          score = e[1]
          if score > 0
            str += "SWITCH #{name}: #{score} (=> #{finalPerc}%)"
            str += " << CHOSEN" if idx == 1
            str += "\n"
          end
        #elsif i == -1
        #  str += "STRUGGLE: 100%"
        else
          move_index, score, target, target_name = e
          name = @battler.moves[move_index].name
          str += "MOVE(#{target_name}) #{name}: #{score} (=> #{finalPerc}%)"
          str += " << CHOSEN" if i == idx
          str += "\n"
        end
      end
      str += "=" * 30
      MKAI.log(str)
      if idx == 0
        # Index 0 means an item was chosen
        ret = [:ITEM, scores[0][2]]
        ret << scores[0][3] if scores[0][3] # Optional target
        # TODO: Set to-be-healed flag so Heal Pulse doesn't also heal after healing by item
        healing_item = scores[0][4]
        if healing_item
          self.flags[:will_be_healed]
        end
        return ret
      elsif idx == 1
        # Index 1 means switching was chosen
        return [:SWITCH, scores[1][2]]
      end
      # Return [move_index, move_target]
      if idx
        choice = scores[idx]
        move = @battler.moves[choice[0]]
        if ["15B", "0D5", "0D6", "0D7", "0D8", "0D9"].include?(move.function)
          self.flags[:will_be_healed] = true
        elsif move.function == "0DF"
          target.flags[:will_be_healed] = true
        elsif move.function == "0A1"
          @side.flags[:will_luckychant] = true
        elsif move.function == "0A2"
          @side.flags[:will_reflect] = true
        elsif move.function == "0A3"
          @side.flags[:will_lightscreen] = true
        elsif move.function == "051"
          @side.flags[:will_haze] = true
        end
        return [choice[0], choice[2]]
      end
      # No choice could be made
      # Caller will make sure Struggle is used
    end

    def end_of_round
      @flags = {}
    end

    # Calculates the score of the move against a specific target
    def get_move_score(target, move)
      # The target variable is a projection of a battler. We know its species and HP,
      # but its item, ability, moves and other properties are not known unless they are
      # explicitly shown or mentioned. Knowing these properties can change what our AI
      # chooses; if we know the item of our target projection, and it's an Air Balloon,
      # we won't choose a Ground move, for instance.
      if target.side == @side
        # The target is an ally
        return nil if move.function != "0DF" # Heal Pulse
        # Move score calculation will only continue if the target is not an ally,
        # or if it is an ally, then the move must be Heal Pulse (0DF).
      end
      if move.statusMove?
        # Start status moves off with a score of 30.
        # Since this makes status moves unlikely to be chosen when the other moves
        # have a high base power, all status moves should ideally be addressed individually
        # in this method, and used in the optimal scenario for each individual move.
        score = 30
        MKAI.log("Test move #{move.name} (#{score})...")
        # Trigger general score modifier code
        score = MKAI::ScoreHandler.trigger_general(score, @ai, self, target, move)
        # Trigger status-move score modifier code
        score = MKAI::ScoreHandler.trigger_status_moves(score, @ai, self, target, move)
      else
        # Set the move score to the base power of the move
        score = get_move_base_damage(move, target)
        MKAI.log("Test move #{move.name} (#{score})...")
        # Trigger general score modifier code
        score = MKAI::ScoreHandler.trigger_general(score, @ai, self, target, move)
        # Trigger damaging-move score modifier code
        score = MKAI::ScoreHandler.trigger_damaging_moves(score, @ai, self, target, move)
      end
      # Trigger move-specific score modifier code
      score = MKAI::ScoreHandler.trigger_move(move, score, @ai, self, target)
      # Prefer a different move if this move would also hit the user's ally and it is super effective against the ally
      # The target is not an ally to begin with (to exclude Heal Pulse and any other good ally-targeting moves)
      if target.side != @side
        # If the move is a status move, we can assume it has a positive effect and thus would be good for our ally too.
        if !move.statusMove?
          target_type = move.pbTarget(@battler)
          # If the move also targets our ally
          if target_type == PBTargets::AllNearOthers || target_type == PBTargets::AllBattlers || target_type == PBTargets::BothSides
            # See if we have an ally
            if ally = @side.battlers.find { |proj| proj && proj != self && !proj.fainted? }
              matchup = ally.calculate_move_matchup(move.id)
              # The move would be super effective on our ally
              if matchup > 1
                decr = (matchup / 2.0 * 75.0).round
                score -= decr
                MKAI.log("- #{decr} for super effectiveness on ally battler")
              end
            end
          end
        end
      end
      # Take 10% of the final score if the target is immune to this move.
      if !move.statusMove? && target_is_immune?(move, target)
        score *= 0.1
        MKAI.log("* 0.1 for the target being immune")
      end
      # Take 10% of the final score if the move is disabled and thus unusable
      if @battler.effects[PBEffects::DisableMove] == move.id
        score *= 0.1
        MKAI.log("* 0.1 for the move being disabled")
      end
      MKAI.log("= #{score}")
      return score
    end

    # Calculates the best item to use and its score
    def get_item_score
      # Yields [score, item, optional_target, healing_item]
      items = @battle.pbGetOwnerItems(@battler.index)
      # Item categories
      hpItems = {
          PBItems::POTION       => 20,
          PBItems::SUPERPOTION  => 50,
          PBItems::HYPERPOTION  => 200,
          PBItems::MAXPOTION    => -1,
          PBItems::BERRYJUICE   => 20,
          PBItems::SWEETHEART   => 20,
          PBItems::FRESHWATER   => 50,
          PBItems::SODAPOP      => 60,
          PBItems::LEMONADE     => 80,
          PBItems::MOOMOOMILK   => 100,
          PBItems::ORANBERRY    => 10,
          PBItems::SITRUSBERRY  => self.totalhp / 4,
          PBItems::ENERGYPOWDER => 50,
          PBItems::ENERGYROOT   => 200,
          PBItems::FULLRESTORE  => -1,
      }
      hpItems[PBItems::RAGECANDYBAR] = 20 if !NEWEST_BATTLE_MECHANICS
      singleStatusCuringItems = {
          PBItems::AWAKENING    => PBStatuses::SLEEP,
          PBItems::CHESTOBERRY  => PBStatuses::SLEEP,
          PBItems::BLUEFLUTE    => PBStatuses::SLEEP,
          PBItems::ANTIDOTE     => PBStatuses::POISON,
          PBItems::PECHABERRY   => PBStatuses::POISON,
          PBItems::BURNHEAL     => PBStatuses::BURN,
          PBItems::RAWSTBERRY   => PBStatuses::BURN,
          PBItems::PARALYZEHEAL => PBStatuses::PARALYSIS,
          PBItems::CHERIBERRY   => PBStatuses::PARALYSIS,
          PBItems::ICEHEAL      => PBStatuses::FROZEN,
          PBItems::ASPEARBERRY  => PBStatuses::FROZEN
      }
      allStatusCuringItems = [
          PBItems::FULLRESTORE,
          PBItems::FULLHEAL,
          PBItems::LAVACOOKIE,
          PBItems::OLDGATEAU,
          PBItems::CASTELIACONE,
          PBItems::LUMIOSEGALETTE,
          PBItems::SHALOURSABLE,
          PBItems::BIGMALASADA,
          PBItems::LUMBERRY,
          PBItems::HEALPOWDER
      ]
      xItems = {
          PBItems::XATTACK    => [PBStats::ATTACK, (NEWEST_BATTLE_MECHANICS) ? 2 : 1],
          PBItems::XATTACK2   => [PBStats::ATTACK, 2],
          PBItems::XATTACK3   => [PBStats::ATTACK, 3],
          PBItems::XATTACK6   => [PBStats::ATTACK, 6],
          PBItems::XDEFENSE   => [PBStats::DEFENSE, (NEWEST_BATTLE_MECHANICS) ? 2 : 1],
          PBItems::XDEFENSE2  => [PBStats::DEFENSE, 2],
          PBItems::XDEFENSE3  => [PBStats::DEFENSE, 3],
          PBItems::XDEFENSE6  => [PBStats::DEFENSE, 6],
          PBItems::XSPATK     => [PBStats::SPATK, (NEWEST_BATTLE_MECHANICS) ? 2 : 1],
          PBItems::XSPATK2    => [PBStats::SPATK, 2],
          PBItems::XSPATK3    => [PBStats::SPATK, 3],
          PBItems::XSPATK6    => [PBStats::SPATK, 6],
          PBItems::XSPDEF     => [PBStats::SPDEF, (NEWEST_BATTLE_MECHANICS) ? 2 : 1],
          PBItems::XSPDEF2    => [PBStats::SPDEF, 2],
          PBItems::XSPDEF3    => [PBStats::SPDEF, 3],
          PBItems::XSPDEF6    => [PBStats::SPDEF, 6],
          PBItems::XSPEED     => [PBStats::SPEED, (NEWEST_BATTLE_MECHANICS) ? 2 : 1],
          PBItems::XSPEED2    => [PBStats::SPEED, 2],
          PBItems::XSPEED3    => [PBStats::SPEED, 3],
          PBItems::XSPEED6    => [PBStats::SPEED, 6],
          PBItems::XACCURACY  => [PBStats::ACCURACY, (NEWEST_BATTLE_MECHANICS) ? 2 : 1],
          PBItems::XACCURACY2 => [PBStats::ACCURACY, 2],
          PBItems::XACCURACY3 => [PBStats::ACCURACY, 3],
          PBItems::XACCURACY6 => [PBStats::ACCURACY, 6]
      }
      scores = items.map do |item|
        if item != PBItems::REVIVE && item != PBItems::MAXREVIVE
          # Don't try to use the item if we can't use it on this Pokémon (e.g. due to Embargo)
          next [0, item] if !@battle.pbCanUseItemOnPokemon?(item, @battler.pokemon, @battler, nil, false)
          # Don't try to use the item if it doesn't have any effect, or some other condition that is not met
          next [0, item] if !ItemHandlers.triggerCanUseInBattle(item, @battler.pokemon, @battler, nil, false, @battle, nil, false)
        end

        score = 0
        # The item is a healing item
        if hpToGain = hpItems[item]
          hpLost = self.totalhp - self.hp
          hpToGain = hpLost if hpToGain == -1 || hpToGain > hpLost
          hpFraction = hpToGain / self.totalhp.to_f
          # If hpFraction is high, then this item will heal almost all our HP.
          # If it is low, then this item will heal very little of our total HP.
          # We now factor the effectiveness of using this item into this fraction.
          # Because using HP items at full health should not be an option, whereas
          # using it at 1 HP should always be preferred.
          itemEff = hpToGain / hpLost.to_f
          itemEff = 0 if hpLost == 0
          delayEff = 1.0
          if !may_die_next_round?
            # If we are likely to survive another hit of the last-used move,
            # then we should discourage using healing items this turn because
            # we can heal more if we use it later.
            delayEff = 0.3
          else
            # If we are likely to die next round, we have a choice to make.
            # It can occur that the target is also a one-shot from this point,
            # which will make move scores skyrocket which can mean we won't use our item.
            # So, if we are slower than our opponent, we will likely die first without using
            # our item and without using our move. So if this is the case, we dramatically increase
            # the score of using our item.
            last_dmg = last_damage_taken
            if last_dmg && !self.faster_than?(last_dmg[0])
              delayEff = 2.5
            end
          end
          finalFrac = hpFraction * itemEff * delayEff
          score = (finalFrac * 200).round
        end

        # Single-status-curing items
        if statusToCure = singleStatusCuringItems[item]
          if self.status == statusToCure
            factor = 1.0
            factor = 0.5 if statusToCure == PBStatuses::PARALYSIS # Paralysis is not that serious
            factor = 1.5 if statusToCure == PBStatuses::BURN && self.is_physical_attacker? # Burned while physical attacking
            factor = 2.0 if statusToCure == PBStatuses::POISON && self.statusCount > 0 # Toxic
            score += (140 * factor).round
          end
        end

        # All-status-curing items
        if allStatusCuringItems.include?(item)
          if self.status != PBStatuses::NONE
            factor = 1.0
            factor = 0.5 if self.status == PBStatuses::PARALYSIS # Paralysis is not that serious
            factor = 1.5 if self.status == PBStatuses::BURN && self.is_physical_attacker? # Burned while physical attacking
            factor = 2.0 if self.status == PBStatuses::POISON && self.statusCount > 0 # Toxic
            score += (120 * factor).round
          end
        end

        # X-Items
        if xStatus = xItems[item]
          stat, increase = xStatus
          # Only use X-Items on the battler's first turn
          if @battler.turnCount == 0
            factor = 1.0
            factor = 2.0 if stat == PBStats::ATTACK && self.is_physical_attacker? ||
                            stat == PBStats::SPATK && self.is_special_attacker?
            score = (80 * factor * increase).round
          end
        end

        # Revive
        if item == PBItems::REVIVE || item == PBItems::MAXREVIVE
          party = @battle.pbParty(@battler.index)
          candidate = nil
          party.each do |pkmn|
            if pkmn.fainted?
              if candidate
                if pkmn.level > candidate.level
                  candidate = pkmn
                end
              else
                candidate = pkmn
              end
            end
          end
          if candidate
            if items.include?(PBItems::MAXREVIVE) && item == PBItems::REVIVE
              score = 200
            else
              score = 400
            end
            index = party.index(candidate)
            next [score, item, index]
          end
        end

        next [score, item]
      end
      max_score = 0
      chosen_item = 0
      chosen_target = nil
      scores.each do |score, item, target|
        if score >= max_score
          max_score = score
          chosen_item = item
          chosen_target = target
        end
      end
      if chosen_item != 0
        return [max_score, chosen_item, chosen_target, !hpItems[chosen_item].nil?] if chosen_target
        return [max_score, chosen_item, nil, !hpItems[chosen_item].nil?]
      end
      return [0, 0]
    end

    # Calculates the best pokemon to switch to and its score
    def get_switch_score
      # Yields [score, pokemon_index]
      switch = false
      # Used to render Future Sight useless
      switch_to_dark_type = false
      # The AI's party
      party = @battle.pbParty(@battler.index)

      # If the pokemon is struggling
      if !@battle.pbCanChooseAnyMove?(@battler.index)
        switch = true
      end
      # If the pokemon is perish songed and will die next turn
      if self.effects[PBEffects::PerishSong] == 1
        switch = true
      end
      # Encored into bad move
      if self.effects[PBEffects::Encore] > 0
        encored_move_index = @battler.pbEncoredMoveIndex
        if encored_move_index >= 0
          encored_move = @battler.moves[encored_move_index]
          if encored_move.statusMove?
            switch = true
          else
            dmgs = @damage_dealt.select { |e| e[1] == encored_move.id }
            if dmgs.size > 0
              last_dmg = dmgs[-1]
              # Bad move if it did less than 35% damage
              if last_dmg[3] < 0.35
                switch = true
              end
            else
              # No record of dealing damage with this move,
              # which probably means the target is immune somehow,
              # or the user happened to miss. Don't risk being stuck in
              # a bad move in any case, and switch.
              switch = true
            end
          end
        end
      end
      pos = @battle.positions[@battler.index]
      # If Future Sight will hit at the end of the round
      if pos.effects[PBEffects::FutureSightCounter] == 1
        # And if we have a dark type in our party
        if party.any? { |pkmn| pkmn.types.include?(PBTypes::DARK) }
          # We should switch to a dark type,
          # but not if we're already close to dying anyway.
          if !self.may_die_next_round?
            switch = true
            switch_to_dark_type = true
          end
        end
      end

      # Get the optimal switch choice by type
      scores = get_optimal_switch_choice
      # If we should switch due to effects in battle
      if switch
        availscores = scores.select { |e| !e[2].fainted? }
        # Switch to a dark type instead of the best type matchup
        if switch_to_dark_type
          availscores = availscores.select { |e| e[2].pokemon.types.include?(PBTypes::DARK) }
        end
        while availscores.size > 0
          hi_off_score, hi_def_score, proj = availscores[0]
          eligible = true
          eligible = false if proj.battler != nil # Already active
          eligible = false if proj.pokemon.egg? # Egg
          if eligible
            score = (150 * hi_off_score * (switch_to_dark_type ? 2.0 : 1.0)).round
            index = party.index(proj.pokemon)
            return [score, index]
          end
          availscores.delete_at(0)
        end
      end

      curr_score = scores.find { |e| e[2] == self }[0]
      # If the current battler is not very effective offensively in any of its types,
      # then we see if there is a battler that is super effective in at least one of its types.
      if curr_score < 1.0
        availscores = scores.select { |e| !e[2].fainted? }
        while availscores.size > 0
          hi_off_score, hi_def_score, proj = availscores[0]
          eligible = true
          eligible = false if proj.battler != nil # Already active
          eligible = false if proj.pokemon.egg? # Egg
          if eligible && hi_off_score >= 1.0
            # Better choice than the current battler, so let's switch to this pokemon
            score = (150 * hi_off_score).round
            index = party.index(proj.pokemon)
            return [score, index]
          end
          availscores.delete_at(0)
        end
      end
      return [0, 0]
    end

    def get_optimal_switch_choice
      party = @battle.pbParty(self.index)
      scores = party.map do |pkmn|
        proj = @ai.pokemon_to_projection(pkmn)
        if !proj
          raise "No projection found for party member #{pkmn.name}"
        end
        offensive_score = 1.0
        defensive_score = 1.0
        self.opposing_side.battlers.each do |target|
          next if target.nil?
          offensive_score *= proj.get_offense_score(target)
          defensive_score *= target.get_offense_score(proj)
        end
        next [offensive_score, defensive_score, proj]
      end
      scores.sort! do |a,b|
        ret = (b[0] <=> a[0])
        next ret if ret != 0
        # Tie-breaker for pokemon with identical offensive effectiveness
        # Prefer the one with the best defense against the targets
        # Lower is better, so a <=> b instead of b <=> a to get ascending order
        ret = (a[1] <=> b[1])
        next ret if ret != 0
        # Tie-breaker for pokemon with identical defensive effectiveness
        next b[2].pokemon.level <=> a[2].pokemon.level
      end
      #MKAI.log(scores.map { |e| e[2].pokemon.name + ": (#{e[0]}, #{e[1]})" }.join("\n"))
      return scores
    end

    # Calculates adjusted base power of a move.
    # Used as a starting point for a particular move's score against a target.
    # Copied from Essentials.
    def get_move_base_damage(move, target)
      baseDmg = move.baseDamage
      baseDmg = 60 if baseDmg == 1
      # Covers all function codes which have their own def pbBaseDamage
      case move.function
      when "010"   # Stomp
        baseDmg *= 2 if target.effects[PBEffects::Minimize]
      # Sonic Boom, Dragon Rage, Super Fang, Night Shade, Endeavor
      when "06A", "06B", "06C", "06D", "06E"
        # Multiplied by 2 to favor the idea of guaranteed x damage to the target
        baseDmg = move.pbFixedDamage(self,target) * 2
      when "06F"   # Psywave
        baseDmg = @battler.level
      when "070"   # OHKO
        baseDmg = 200
      when "071", "072", "073"   # Counter, Mirror Coat, Metal Burst
        baseDmg = 60
      when "075", "076", "0D0", "12D"   # Surf, Earthquake, Whirlpool, Shadow Storm
        baseDmg = move.pbModifyDamage(baseDmg,@battler,target)
      # Gust, Twister, Venoshock, Smelling Salts, Wake-Up Slap, Facade, Hex, Brine,
      # Retaliate, Weather Ball, Return, Frustration, Eruption, Crush Grip,
      # Stored Power, Punishment, Hidden Power, Fury Cutter, Echoed Voice,
      # Trump Card, Flail, Electro Ball, Low Kick, Fling, Spit Up
      when "077", "078", "07B", "07C", "07D", "07E", "07F", "080", "085", "087",
           "089", "08A", "08B", "08C", "08E", "08F", "090", "091", "092", "097",
           "098", "099", "09A", "0F7", "113"
        baseDmg = move.pbBaseDamage(baseDmg,@battler,target)
      when "086"   # Acrobatics
        baseDmg *= 2 if @battler.item == 0 || @battler.hasActiveItem?(:FLYINGGEM)
      when "08D"   # Gyro Ball
        targetSpeed = target.effective_speed
        userSpeed = self.effective_speed
        baseDmg = [[(25 * targetSpeed / userSpeed).floor, 150].min,1].max
      when "094"   # Present
        baseDmg = 50
      when "095"   # Magnitude
        baseDmg = 71
        baseDmg *= 2 if target.inTwoTurnAttack?("0CA")   # Dig
      when "096"   # Natural Gift
        baseDmg = move.pbNaturalGiftBaseDamage(@battler.item)
      when "09B"   # Heavy Slam
        baseDmg = move.pbBaseDamage(baseDmg,@battler,target)
        baseDmg *= 2 if NEWEST_BATTLE_MECHANICS &&
                        target.effects[PBEffects::Minimize]
      when "0A0", "0BD", "0BE"   # Frost Breath, Double Kick, Twineedle
        baseDmg *= 2
      when "0BF"   # Triple Kick
        baseDmg *= 6   # Hits do x1, x2, x3 baseDmg in turn, for x6 in total
      when "0C0"   # Fury Attack
        if @battler.hasActiveAbility?(:SKILLLINK)
          baseDmg *= 5
        else
          baseDmg = (baseDmg * 19 / 6).floor   # Average damage dealt
        end
      when "0C1"   # Beat Up
        mult = 0
        @battle.eachInTeamFromBattlerIndex(@battler.index) do |pkmn,_i|
          mult += 1 if pkmn && pkmn.able? && pkmn.status == PBStatuses::NONE
        end
        baseDmg *= mult
      when "0C4"   # Solar Beam
        baseDmg = move.pbBaseDamageMultiplier(baseDmg, @battler, target)
      when "0D3"   # Rollout
        baseDmg *= 2 if @battler.effects[PBEffects::DefenseCurl]
      when "0D4"   # Bide
        baseDmg = 40
      when "0E1"   # Final Gambit
        baseDmg = @battler.hp
      when "144"   # Flying Press
        # Flying type is handled separately in the move effectiveness score multiplier
        baseDmg *= 2 if target.effects[PBEffects::Minimize]
      when "166"   # Stomping Tantrum
        baseDmg *= 2 if @battler.lastRoundMoveFailed
      when "175"   # Double Iron Bash
        baseDmg *= 2
        baseDmg *= 2 if target.effects[PBEffects::Minimize]
      end
      return baseDmg
    end

    # Determines if the target is immune to a move.
    # Copied from Essentials.
    def target_is_immune?(move, target)
      type = move.pbCalcType(@battler)
      typeMod = move.pbCalcTypeMod(type,@battler,target)
      # Type effectiveness
      return true if PBTypes.ineffective?(typeMod)
      # Immunity due to ability/item/other effects
      if isConst?(move.type, PBTypes,:GROUND)
        return true if target.airborne? && !move.hitsFlyingTargets?
      elsif isConst?(move.type, PBTypes,:FIRE)
        return true if target.hasActiveAbility?(:FLASHFIRE)
      elsif isConst?(move.type, PBTypes,:WATER)
        return true if target.hasActiveAbility?([:DRYSKIN,:STORMDRAIN,:WATERABSORB])
      elsif isConst?(move.type, PBTypes,:GRASS)
        return true if target.hasActiveAbility?(:SAPSIPPER)
      elsif isConst?(move.type, PBTypes,:ELECTRIC)
        return true if target.hasActiveAbility?([:LIGHTNINGROD,:MOTORDRIVE,:VOLTABSORB])
      end
      return true if PBTypes.notVeryEffective?(typeMod) &&
                     target.hasActiveAbility?(:WONDERGUARD)
      return true if move.damagingMove? && @battler.index != target.index && !target.opposes?(@battler) &&
                     target.hasActiveAbility?(:TELEPATHY)
      return true if move.canMagicCoat? && target.hasActiveAbility?(:MAGICBOUNCE) &&
                     target.opposes?(@battler)
      return true if move.soundMove? && target.hasActiveAbility?(:SOUNDPROOF)
      return true if move.bombMove? && target.hasActiveAbility?(:BULLETPROOF)
      if move.powderMove?
        return true if target.pbHasType?(:GRASS)
        return true if target.hasActiveAbility?(:OVERCOAT)
        return true if target.hasActiveItem?(:SAFETYGOGGLES)
      end
      return true if target.effects[PBEffects::Substitute]>0 && move.statusMove? &&
                     !move.ignoresSubstitute?(@battler) && @battler.index != target.index
      return true if NEWEST_BATTLE_MECHANICS && @battler.hasActiveAbility?(:PRANKSTER) &&
                     target.pbHasType?(:DARK) && target.opposes?(@battler)
      return true if move.priority > 0 && @battle.field.terrain == PBBattleTerrains::Psychic &&
                     target.affected_by_terrain? && target.opposes?(@battler)
      return false
    end

    def get_move_accuracy(move, target)
      return 100 if target.effects[PBEffects::Minimize] && move.tramplesMinimize?(1)
      return 100 if target.effects[PBEffects::Telekinesis] > 0
      baseAcc = move.pbBaseAccuracy(@battler, target)
      return 100 if baseAcc == 0
      return baseAcc
    end

    def types(type3 = true)
      return @battler.pbTypes(type3) if @battler
      return @pokemon.types
    end
    alias pbTypes types

    def effects
      return @battler.effects
    end

    def stages
      return @battler.stages
    end

    def is_species?(species)
      return @battler.isSpecies?(species)
    end
    alias isSpecies? is_species?

    def has_type?(type)
      return @battler.pbHasType?(type)
    end
    alias pbHasType? has_type?

    def ability
      return @battler.ability
    end

    def has_ability?(ability)
      return @battler.hasActiveAbility?(ability) && (AI_KNOWS_UNSEEN_ABILITIES || @revealed_ability)
    end
    alias hasActiveAbility? has_ability?

    def has_item?(item)
      return @battler.hasActiveItem?(item) && (AI_KNOWS_HELD_ITEMS || @revealed_item)
    end
    alias hasActiveItem? has_item?

    def moves
      if @battler.nil?
        return @pokemon.moves
      elsif AI_KNOWS_ENEMY_MOVES || @side.index == 0
        return @battler.moves
      else
        return @used_moves
      end
    end

    def opposes?(projection)
      if projection.is_a?(BattlerProjection)
        return @side.index != projection.side.move_index
      else
        return @battler.index % 2 != projection.index % 2
      end
    end

    def own_side
      return @side
    end
    alias pbOwnSide own_side

    def affected_by_terrain?
      return @battler.affectedByTerrain?
    end
    alias affectedByTerrain? affected_by_terrain?

    def airborne?
      return @battler.airborne?
    end

    def semi_invulnerable?
      return @battler.semiInvulnerable?
    end
    alias semiInvulnerable? semi_invulnerable?

    def in_two_turn_attack?(*args)
      return @battler.inTwoTurnAttack?(*args)
    end
    alias inTwoTurnAttack? in_two_turn_attack?

    def can_attract?(target)
      return @battler.pbCanAttract?(target)
    end
    alias pbCanAttract? can_attract?

    def takes_indirect_damage?
      return @battler.takesIndirectDamage?
    end
    alias takesIndirectDamage? takes_indirect_damage?

    def weight
      return @battler.pbWeight
    end
    alias pbWeight weight

    def can_sleep?(inflictor, move, ignore_status = false)
      return @battler.pbCanSleep?(inflictor, false, move, ignore_status)
    end

    def can_poison?(inflictor, move)
      return @battler.pbCanPoison?(inflictor, false, move)
    end

    def can_burn?(inflictor, move)
      return @battler.pbCanBurn?(inflictor, false, move)
    end

    def can_paralyze?(inflictor, move)
      return @battler.pbCanParalyze?(inflictor, false, move)
    end

    def can_freeze?(inflictor, move)
      return @battler.pbCanFreeze?(inflictor, false, move)
    end

    def register_damage_dealt(move, target, damage)
      move = move.id if move.is_a?(PokeBattle_Move)
      @damage_dealt << [target, move, damage, damage / target.totalhp.to_f]
    end

    def register_damage_taken(move, user, damage)
      user.used_moves << move if !user.used_moves.any? { |m| m.id == move.id }
      move = move.id
      @damage_taken << [user, move, damage, damage / @battler.totalhp.to_f]
    end

    def get_damage_by_user(user)
      return @damage_taken.select { |e| e[0] == user }
    end

    def get_damage_by_user_and_move(user, move)
      move = move.id if move.is_a?(PokeBattle_Move)
      return @damage_taken.select { |e| e[0] == user && e[1] == move }
    end

    def get_damage_by_move(move)
      move = move.id if move.is_a?(PokeBattle_Move)
      return @damage_taken.select { |e| e[1] == move }
    end

    def last_damage_taken
      return @damage_taken[-1]
    end

    def last_damage_dealt
      return @damage_dealt[-1]
    end

    # Estimates how much HP the battler will lose from end-of-round effects,
    # such as status conditions or trapping moves
    def estimate_hp_difference_at_end_of_round
      lost = 0
      # Future Sight
      @battle.positions.each_with_index do |pos, idxPos|
        next if !pos
        # Ignore unless future sight hits at the end of the round
        next if pos.effects[PBEffects::FutureSightCounter] != 1
        # And only if its target is this battler
        next if @battle.battlers[idxPos] != @battler
        # Find the user of the move
        moveUser = nil
        @battle.eachBattler do |b|
          next if b.opposes?(pos.effects[PBEffects::FutureSightUserIndex])
          next if b.pokemonIndex != pos.effects[PBEffects::FutureSightUserPartyIndex]
          moveUser = b
          break
        end
        if !moveUser # User isn't in battle, get it from the party
          party = @battle.pbParty(pos.effects[PBEffects::FutureSightUserIndex])
          pkmn = party[pos.effects[PBEffects::FutureSightUserPartyIndex]]
          if pkmn && pkmn.able?
            moveUser = PokeBattle_Battler.new(@battle, pos.effects[PBEffects::FutureSightUserIndex])
            moveUser.pbInitDummyPokemon(pkmn, pos.effects[PBEffects::FutureSightUserPartyIndex])
          end
        end
        if moveUser && moveUser.pokemon != @battler.pokemon
          # We have our move user, and it's not targeting itself
          move_id = pos.effects[PBEffects::FutureSightMove]
          move = PokeBattle_Move.pbFromPBMove(@battle, PBMove.new(move_id))
          # Calculate how much damage a Future Sight hit will do
          calcType = move.pbCalcType(moveUser)
          @battler.damageState.typeMod = move.pbCalcTypeMod(calcType, moveUser, @battler)
          move.pbCalcDamage(moveUser, @battler)
          dmg = @battler.damageState.calcDamage
          lost += dmg
        end
      end
      if takes_indirect_damage?
        # Sea of Fire (Fire Pledge + Grass Pledge)
        weather = @battle.pbWeather
        if side.effects[PBEffects::SeaOfFire] != 0
          unless weather == PBWeather::Rain || weather == PBWeather::HeavyRain ||
                 has_type?(:FIRE)
            lost += @battler.totalhp / 8.0
          end
        end
        # Leech Seed
        if self.effects[PBEffects::LeechSeed] >= 0
          lost += @battler.totalhp / 8.0
        end
        # Poison
        if poisoned? && !has_ability?(:POISONHEAL)
          dmg = statusCount == 0 ? @battler.totalhp / 8.0 : @battler.totalhp * self.effects[PBEffects::Toxic] / 16.0
          lost += dmg
        end
        # Burn
        if burned?
          lost += (NEWEST_BATTLE_MECHANICS ? @battler.totalhp / 16.0 : @battler.totalhp / 8.0)
        end
        # Sleep + Nightmare
        if asleep? && self.effects[PBEffects::Nightmare]
          lost += @battler.totalhp / 4.0
        end
        # Curse
        if self.effects[PBEffects::Curse]
          lost += @battler.totalhp / 4.0
        end
        # Trapping Effects
        if self.effects[PBEffects::Trapping] != 0
          dmg = (NEWEST_BATTLE_MECHANICS ? b.totalhp / 8.0 : b.totalhp / 16.0)
          if @battle.battlers[self.effects[PBEffects::TrappingUser]].hasActiveItem?(:BINDINGBAND)
            dmg = (NEWEST_BATTLE_MECHANICS ? b.totalhp / 6.0 : b.totalhp / 8.0)
          end
          lost += dmg
        end
      end
      return lost
    end

    def may_die_next_round?
      dmg = last_damage_taken
      return false if dmg.nil?
      # Returns true if the damage from the last move is more than the remaining hp
      # This is used in determining if there is a point in using healing moves or items
      hplost = dmg[2]
      # We will also lose damage from status conditions and end-of-round effects like wrap,
      # so we make a rough estimate with those included.
      hplost += estimate_hp_difference_at_end_of_round
      return hplost >= self.hp
    end

    def took_more_than_x_damage?(x)
      dmg = last_damage_taken
      return false if dmg.nil?
      # Returns true if the damage from the last move did more than (x*100)% of the total hp damage
      return dmg[3] >= x
    end

    # If the battler can survive another hit from the same move the target used last,
    # but the battler will die if it does not heal, then healing is considered necessary.
    def is_healing_necessary?(x)
      return may_die_next_round? && !took_more_than_x_damage?(x)
    end

    # Healing is pointless if the target did more damage last round than we can heal
    def is_healing_pointless?(x)
      return took_more_than_x_damage?(x)
    end

    def discourage_making_contact_with?(target)
      return false if has_ability?(:LONGREACH)
      bad_abilities = [:WEAKARMOR, :STAMINA, :IRONBARBS, :ROUGHSKIN, :PERISHBODY]
      return true if bad_abilities.any? { |a| target.has_ability?(a) }
      return true if target.has_ability?(:CUTECHARM) && target.can_attract?(self)
      return true if (target.has_ability?(:GOOEY) || target.has_ability?(:TANGLINGHAIR)) && faster_than?(target)
      return true if target.has_item?(:ROCKYHELMET)
      return true if target.has_ability?(:EFFECTSPORE) && !has_type?(:GRASS) && !has_ability?(:OVERCOAT) && !has_item?(:OVERCOAT)
      return true if (target.has_ability?(:STATIC) || target.has_ability?(:POISONPOINT) || target.has_ability?(:FLAMEBODY)) && !has_non_volatile_status?
    end

    def get_move_damage(target, move)
      calcType = move.pbCalcType(@battler)
      target.battler.damageState.typeMod = move.pbCalcTypeMod(calcType, @battler, target.battler)
      move.pbCalcDamage(@battler, target.battler)
      return target.battler.damageState.calcDamage
    end

    # Calculates the combined type effectiveness of all user and target types
    def calculate_type_matchup(target)
      user_types = self.pbTypes(true)
      target_types = target.pbTypes(true)
      mod = 1.0
      user_types.each do |user_type|
        target_types.each do |target_type|
          user_eff = PBTypes.getEffectiveness(user_type, target_type)
          mod *= user_eff / 2.0
          target_eff = PBTypes.getEffectiveness(target_type, user_type)
          mod *= 2.0 / target_eff
        end
      end
      return mod
    end

    # Calculates the type effectiveness of a particular move against this user
    def calculate_move_matchup(move_id)
      move = PokeBattle_Move.pbFromPBMove(@ai.battle, PBMove.new(move_id))
      # Calculate the type this move would be if used by us
      types = move.pbCalcType(@battler)
      types = [types] if !types.is_a?(Array)
      user_types = types
      target_types = self.pbTypes(true)
      mod = 1.0
      user_types.each do |user_type|
        target_types.each do |target_type|
          user_eff = PBTypes.getEffectiveness(user_type, target_type)
          mod *= user_eff / 2.0
        end
      end
      return mod
    end

    # Whether the type matchup between the user and target is favorable
    def bad_against?(target)
      return calculate_type_matchup(target) < 1.0
    end

    # Whether the user would be considered an underdog to the target.
    # Considers type matchup and level
    def underdog?(target)
      return true if bad_against?(target)
      return true if target.level >= self.level + 5
      return false
    end

    def has_usable_move_type?(type)
      return self.moves.any? { |m| m.type == type && m.pp > 0 }
    end

    def get_offense_score(target)
      # Note: self does not have a @battler value as it is a party member, i.e. only a PokeBattle_Pokemon object
      # Return 1.0+ value if self is good against the target
      user_types = self.pbTypes(true)
      target_types = target.pbTypes(true)
      max = 0
      user_types.each do |user_type|
        next unless self.has_usable_move_type?(user_type)
        mod = 1.0
        target_types.each do |target_type|
          eff = PBTypes.getEffectiveness(user_type, target_type) / 2.0
          if eff >= 2.0
            mod *= eff 
          else
            mod *= eff
          end
        end
        max = mod if mod > max
      end
      return max
    end
  end
end