#===============================================================================
#
#===============================================================================
class Battle::AI::AIBattler
  attr_reader :index, :side, :party_index
  attr_reader :battler

  def initialize(ai, index)
    @ai = ai
    @index = index
    @side = (@ai.battle.opposes?(@index)) ? 1 : 0
    refresh_battler
  end

  def refresh_battler
    old_party_index = @party_index
    @battler = @ai.battle.battlers[@index]
    @party_index = @battler.pokemonIndex
    if @party_index != old_party_index
      # TODO: Start of battle or Pokémon switched/shifted; recalculate roles,
      #       etc.
    end
  end

  def pokemon;     return @battler.pokemon;     end
  def level;       return @battler.level;       end
  def hp;          return @battler.hp;          end
  def totalhp;     return @battler.totalhp;     end
  def fainted?;    return @battler.fainted?;    end
  def status;      return @battler.status;      end
  def statusCount; return @battler.statusCount; end
  def gender;      return @battler.gender;      end
  def turnCount;   return @battler.turnCount;   end
  def effects;     return @battler.effects;     end
  def stages;      return @battler.stages;      end
  def statStageAtMax?(stat); return @battler.statStageAtMax?(stat); end
  def statStageAtMin?(stat); return @battler.statStageAtMin?(stat); end
  def moves;       return @battler.moves;       end

  def wild?
    return @ai.battle.wildBattle? && opposes?
  end

  def name
    return sprintf("%s (%d)", @battler.name, @index)
  end

  def opposes?(other = nil)
    return @side == 1 if other.nil?
    return other.side != @side
  end

  def idxOwnSide;      return @battler.idxOwnSide;      end
  def pbOwnSide;       return @battler.pbOwnSide;       end
  def idxOpposingSide; return @battler.idxOpposingSide; end
  def pbOpposingSide;  return @battler.pbOpposingSide;  end

  def faster_than?(other)
    return false if other.nil?
    this_speed  = rough_stat(:SPEED)
    other_speed = other.rough_stat(:SPEED)
    return (this_speed > other_speed) ^ (@ai.battle.field.effects[PBEffects::TrickRoom] > 0)
  end

  #=============================================================================

  # Returns how much damage this battler will take at the end of this round.
  def rough_end_of_round_damage
    ret = 0
    # Future Sight/Doom Desire
    # TODO
    # Wish
    if @ai.battle.positions[@index].effects[PBEffects::Wish] == 1 && @battler.canHeal?
      ret -= @ai.battle.positions[@index].effects[PBEffects::WishAmount]
    end
    # Sea of Fire
    if @ai.battle.sides[@side].effects[PBEffects::SeaOfFire] > 1 &&
       @battler.takesIndirectDamage? && !has_type?(:FIRE)
      ret += self.totalhp / 8
    end
    # Grassy Terrain (healing)
    if @ai.battle.field.terrain == :Grassy && @battler.affectedByTerrain? && @battler.canHeal?
      ret -= [battler.totalhp / 16, 1].max
    end
    # Leftovers/Black Sludge
    if has_active_item?(:BLACKSLUDGE)
      if has_type?(:POISON)
        ret -= [battler.totalhp / 16, 1].max if @battler.canHeal?
      else
        ret += [battler.totalhp / 8, 1].max if @battler.takesIndirectDamage?
      end
    elsif has_active_item?(:LEFTOVERS)
      ret -= [battler.totalhp / 16, 1].max if @battler.canHeal?
    end
    # Aqua Ring
    if self.effects[PBEffects::AquaRing] && @battler.canHeal?
      amt = battler.totalhp / 16
      amt = (amt * 1.3).floor if has_active_item?(:BIGROOT)
      ret -= [amt, 1].max
    end
    # Ingrain
    if self.effects[PBEffects::Ingrain] && @battler.canHeal?
      amt = battler.totalhp / 16
      amt = (amt * 1.3).floor if has_active_item?(:BIGROOT)
      ret -= [amt, 1].max
    end
    # Leech Seed
    if self.effects[PBEffects::LeechSeed] >= 0
      if @battler.takesIndirectDamage?
        ret += [battler.totalhp / 8, 1].max if @battler.takesIndirectDamage?
      end
    else
      @ai.each_battler do |b, i|
        next if i == @index || b.effects[PBEffects::LeechSeed] != @index
        amt = [[b.totalhp / 8, b.hp].min, 1].max
        amt = (amt * 1.3).floor if has_active_item?(:BIGROOT)
        ret -= [amt, 1].max
      end
    end
    # Hyper Mode (Shadow Pokémon)
    # TODO
    # Poison/burn/Nightmare
    if self.status == :POISON
      if has_active_ability?(:POISONHEAL)
        ret -= [battler.totalhp / 8, 1].max if @battler.canHeal?
      elsif @battler.takesIndirectDamage?
        mult = 2
        mult = [self.effects[PBEffects::Toxic] + 1, 16].min if self.statusCount > 0   # Toxic
        ret += [mult * battler.totalhp / 16, 1].max
      end
    elsif self.status == :BURN
      if @battler.takesIndirectDamage?
        amt = (Settings::MECHANICS_GENERATION >= 7) ? self.totalhp / 16 : self.totalhp / 8
        amt = (amt / 2.0).round if has_active_ability?(:HEATPROOF)
        ret += [amt, 1].max
      end
    elsif @battler.asleep? && self.statusCount > 1 && self.effects[PBEffects::Nightmare]
      ret += [battler.totalhp / 4, 1].max if @battler.takesIndirectDamage?
    end
    # Curse
    if self.effects[PBEffects::Curse]
      ret += [battler.totalhp / 4, 1].max if @battler.takesIndirectDamage?
    end
    # Trapping damage
    if self.effects[PBEffects::Trapping] > 1 && @battler.takesIndirectDamage?
      amt = (Settings::MECHANICS_GENERATION >= 6) ? self.totalhp / 8 : self.totalhp / 16
      if @ai.battlers[self.effects[PBEffects::TrappingUser]].has_active_item?(:BINDINGBAND)
        amt = (Settings::MECHANICS_GENERATION >= 6) ? self.totalhp / 6 : self.totalhp / 8
      end
      ret += [amt, 1].max
    end
    # Perish Song
    # TODO
    # Bad Dreams
    if @battler.asleep? && self.statusCount > 1 && @battler.takesIndirectDamage?
      @ai.each_battler do |b, i|
        next if i == @index || !b.battler.near?(@battler) || !b.has_active_ability?(:BADDREAMS)
        ret += [battler.totalhp / 8, 1].max
      end
    end
    # Sticky Barb
    if has_active_item?(:STICKYBARB) && @battler.takesIndirectDamage?
      ret += [battler.totalhp / 8, 1].max
    end
    return ret
  end

  #=============================================================================

  def speed; return @battler.speed; end

  def base_stat(stat)
    ret = 0
    case stat
    when :ATTACK          then ret = @battler.attack
    when :DEFENSE         then ret = @battler.defense
    when :SPECIAL_ATTACK  then ret = @battler.spatk
    when :SPECIAL_DEFENSE then ret = @battler.spdef
    when :SPEED           then ret = @battler.speed
    end
    return ret
  end

  def rough_stat(stat)
    return @battler.pbSpeed if stat == :SPEED && @ai.trainer.high_skill?
    stageMul = [2, 2, 2, 2, 2, 2, 2, 3, 4, 5, 6, 7, 8]
    stageDiv = [8, 7, 6, 5, 4, 3, 2, 2, 2, 2, 2, 2, 2]
    stage = @battler.stages[stat] + 6
    value = base_stat(stat)
    return (value.to_f * stageMul[stage] / stageDiv[stage]).floor
  end

  #=============================================================================

  def types; return @battler.types; end
  def pbTypes(withExtraType = false); return @battler.pbTypes(withExtraType); end

  def has_type?(type)
    return false if !type
    active_types = pbTypes(true)
    return active_types.include?(GameData::Type.get(type).id)
  end

  # TODO: Also make a def effectiveness_of_move_against_battler which calls
  #       pbCalcTypeModSingle instead of effectiveness_of_type_against_single_battler_type.
  def effectiveness_of_type_against_battler(type, user = nil)
    ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
    return ret if !type
    return ret if type == :GROUND && has_type?(:FLYING) && has_active_item?(:IRONBALL)
    # Get effectivenesses
    if type == :SHADOW
      if @battler.shadowPokemon?
        ret = Effectiveness::NOT_VERY_EFFECTIVE_MULTIPLIER
      else
        ret = Effectiveness::SUPER_EFFECTIVE_MULTIPLIER
      end
    else
      @battler.pbTypes(true).each do |defend_type|
        ret *= effectiveness_of_type_against_single_battler_type(type, defend_type, user)
      end
      ret *= 2 if self.effects[PBEffects::TarShot] && type == :FIRE
    end
    return ret
  end

  #=============================================================================

  def ability_id; return @battler.ability_id; end
  def ability;    return @battler.ability;    end

  def ability_active?
    return @battler.abilityActive?
  end

  def has_active_ability?(ability, ignore_fainted = false)
    return @battler.hasActiveAbility?(ability, ignore_fainted)
  end

  def has_mold_breaker?
    return @ai.move.function == "IgnoreTargetAbility" || @battler.hasMoldBreaker?
  end

  #=============================================================================

  def item_id; return @battler.item_id; end
  def item;    return @battler.item;    end

  def item_active?
    return @battler.itemActive?
  end

  def has_active_item?(item)
    return @battler.hasActiveItem?(item)
  end

  #=============================================================================

  def check_for_move
    ret = false
    @battler.eachMove do |move|
      next if move.pp == 0 && move.total_pp > 0
      next unless yield move
      ret = true
      break
    end
    return ret
  end

  def has_damaging_move_of_type?(*types)
    check_for_move do |m|
      return true if m.damagingMove? && types.include?(m.pbCalcType(@battler))
    end
    return false
  end

  def has_move_with_function?(*functions)
    check_for_move { |m| return true if functions.include?(m.function) }
    return false
  end

  #=============================================================================

  def can_attack?
    return false if self.effects[PBEffects::HyperBeam] > 0
    return false if status == :SLEEP && statusCount > 1
    return false if status == :FROZEN   # Only 20% chance of unthawing; assune it won't
    return false if self.effects[PBEffects::Truant] && has_active_ability?(:TRUANT)
    return false if self.effects[PBEffects::Flinch]
    # NOTE: Confusion/infatuation/paralysis have higher chances of allowing the
    #       attack, so the battler is treated as able to attack in those cases.
    return true
  end

  def can_switch_lax?
    return false if wild?
    @ai.battle.eachInTeamFromBattlerIndex(@index) do |pkmn, i|
      return true if @ai.battle.pbCanSwitchIn?(@index, i)
    end
    return false
  end

  # NOTE: This specifically means "is not currently trapped but can become
  #       trapped by an effect". Similar to def pbCanSwitchOut? but this returns
  #       false if any certain switching OR certain trapping applies.
  def can_become_trapped?
    return false if fainted?
    # Ability/item effects that allow switching no matter what
    if ability_active? && Battle::AbilityEffects.triggerCertainSwitching(ability, @battler, @ai.battle)
      return false
    end
    if item_active? && Battle::ItemEffects.triggerCertainSwitching(item, @battler, @ai.battle)
      return false
    end
    # Other certain switching effects
    return false if Settings::MORE_TYPE_EFFECTS && has_type?(:GHOST)
    # Other certain trapping effects
    return false if @battler.trappedInBattle?
    # Trapping abilities/items
    ai.each_foe_battler(side) do |b, i|
      if b.ability_active? &&
         Battle::AbilityEffects.triggerTrappingByTarget(b.ability, @battler, b.battler, @ai.battle)
        return false
      end
      if b.item_active? &&
         Battle::ItemEffects.triggerTrappingByTarget(b.item, @battler, b.battler, @ai.battle)
        return false
      end
    end
    return true
  end

  #=============================================================================

  def wants_status_problem?(new_status)
    return true if new_status == :NONE
    return false if new_status == :FREEZE		#This shouldn't ever come up, but Freeze is always bad.
    if ability_active?
      case ability_id
      when :GUTS
        return true if stat_raise_worthwhile?(self, :ATTACK, true)
      when :MARVELSCALE
        return true if stat_raise_worthwhile?(self, :DEFENSE, true)
      when :QUICKFEET
        return true if stat_raise_worthwhile?(self, :SPEED, true)
      when :FLAREBOOST
        return true if new_status == :BURN && stat_raise_worthwhile?(self, :SPECIAL_ATTACK, true)
      when :TOXICBOOST
        return true if new_status == :POISON && stat_raise_worthwhile?(self, :ATTACK, true)
      when :POISONHEAL
        return true if new_status == :POISON
      when :MAGICGUARD		#Magic Guard Pokemon want to be burned or poisoned so that they can't be paralyzed, frozen, or put to sleep.
        return true if new_status == :POISON || (new_status == :BURN && !stat_raise_worthwhile?(self, :ATTACK, true) )
      end
    end
    return true if new_status == :SLEEP && check_for_move { |m| m.usableWhenAsleep? }
    if has_move_with_function?("DoublePowerIfUserPoisonedBurnedParalyzed")
      return true if [:POISON, :BURN, :PARALYSIS].include?(new_status)
    end
    return false
  end

  #=============================================================================

  # TODO: Add more items.
  BASE_ITEM_RATINGS = {
    :ADAMANTORB   => 3,
    :BLACKBELT    => 2,
    :BLACKGLASSES => 2,
    :BLACKSLUDGE  => -4,
    :CHARCOAL     => 2,
    :CHOICEBAND   => 4,
    :CHOICESCARF  => 4,
    :CHOICESPECS  => 4,
    :DEEPSEATOOTH => 4,
    :DRACOPLATE   => 2,
    :DRAGONFANG   => 2,
    :DREADPLATE   => 2,
    :EARTHPLATE   => 2,
    :FISTPLATE    => 2,
    :FLAMEORB     => -4,
    :FLAMEPLATE   => 2,
    :GRISEOUSORB  => 3,
    :HARDSTONE    => 2,
    :ICICLEPLATE  => 2,
    :INSECTPLATE  => 2,
    :IRONBALL     => -4,
    :IRONPLATE    => 2,
    :LAGGINGTAIL  => -2,
    :LEFTOVERS    => 4,
    :LIFEORB      => 3,
    :LIGHTBALL    => 4,
    :LUSTROUSORB  => 3,
    :MAGNET       => 2,
    :MEADOWPLATE  => 2,
    :METALCOAT    => 2,
    :METRONOME    => 1,
    :MINDPLATE    => 2,
    :MIRACLESEED  => 2,
    :MUSCLEBAND   => 2,
    :MYSTICWATER  => 2,
    :NEVERMELTICE => 2,
    :ODDINCENSE   => 2,
    :PIXIEPLATE   => 2,
    :POISONBARB   => 2,
    :ROCKINCENSE  => 2,
    :ROSEINCENSE  => 2,
    :SEAINCENSE   => 2,
    :SHARPBEAK    => 2,
    :SILKSCARF    => 2,
    :SILVERPOWDER => 2,
    :SKYPLATE     => 2,
    :SOFTSAND     => 2,
    :SOULDEW      => 3,
    :SPELLTAG     => 2,
    :SPLASHPLATE  => 2,
    :SPOOKYPLATE  => 2,
    :STICKYBARB   => -2,
    :STONEPLATE   => 2,
    :THICKCLUB    => 4,
    :TOXICORB     => -4,
    :TOXICPLATE   => 2,
    :TWISTEDSPOON => 2,
    :WAVEINCENSE  => 2,
    :WISEGLASSES  => 2,
    :ZAPPLATE     => 2
  }

  # Returns a value indicating how beneficial the given item will be to this
  # battler if it is holding it.
  # Return values are typically between -10 and +10. 0 is indifferent, positive
  # values mean this battler benefits, negative values mean this battler suffers.
  def wants_item?(item)
    item = item.id if !item.is_a?(Symbol) && item.respond_to?("id")
    return 0 if has_active_ability?(:KLUTZ)
    # TODO: Unnerve, other item-negating effects.
    ret = BASE_ITEM_RATINGS[item] || 0
    case item
    when :ADAMANTORB
      ret = 0 if !@battler.isSpecies?(:DIALGA) || !has_damaging_move_of_type?(:DRAGON, :STEEL)
    when :BLACKBELT, :BLACKGLASSES, :CHARCOAL, :DRAGONFANG, :HARDSTONE, :MAGNET,
         :METALCOAT, :MIRACLESEED, :MYSTICWATER, :NEVERMELTICE, :POISONBARB,
         :SHARPBEAK, :SILKSCARF, :SILVERPOWDER, :SOFTSAND, :SPELLTAG,
         :TWISTEDSPOON,
         :DRACOPLATE, :DREADPLATE, :EARTHPLATE, :FISTPLATE, :FLAMEPLATE,
         :ICICLEPLATE, :INSECTPLATE, :IRONPLATE, :MEADOWPLATE, :MINDPLATE,
         :PIXIEPLATE, :SKYPLATE, :SPLASHPLATE, :SPOOKYPLATE, :STONEPLATE,
         :TOXICPLATE, :ZAPPLATE,
         :ODDINCENSE, :ROCKINCENSE, :ROSEINCENSE, :SEAINCENSE, :WAVEINCENSE
      boosted_type = {
        :BLACKBELT    => :FIGHTING,
        :BLACKGLASSES => :DARK,
        :CHARCOAL     => :FIRE,
        :DRAGONFANG   => :DRAGON,
        :HARDSTONE    => :ROCK,
        :MAGNET       => :ELECTRIC,
        :METALCOAT    => :STEEL,
        :MIRACLESEED  => :GRASS,
        :MYSTICWATER  => :WATER,
        :NEVERMELTICE => :ICE,
        :POISONBARB   => :POISON,
        :SHARPBEAK    => :FLYING,
        :SILKSCARF    => :NORMAL,
        :SILVERPOWDER => :BUG,
        :SOFTSAND     => :GROUND,
        :SPELLTAG     => :GHOST,
        :TWISTEDSPOON => :PSYCHIC,
        :DRACOPLATE   => :DRAGON,
        :DREADPLATE   => :DARK,
        :EARTHPLATE   => :GROUND,
        :FISTPLATE    => :FIGHTING,
        :FLAMEPLATE   => :FIRE,
        :ICICLEPLATE  => :ICE,
        :INSECTPLATE  => :BUG,
        :IRONPLATE    => :STEEL,
        :MEADOWPLATE  => :GRASS,
        :MINDPLATE    => :PSYCHIC,
        :PIXIEPLATE   => :FAIRY,
        :SKYPLATE     => :FLYING,
        :SPLASHPLATE  => :WATER,
        :SPOOKYPLATE  => :GHOST,
        :STONEPLATE   => :ROCK,
        :TOXICPLATE   => :POISON,
        :ZAPPLATE     => :ELECTRIC,
        :ODDINCENSE   => :PSYCHIC,
        :ROCKINCENSE  => :ROCK,
        :ROSEINCENSE  => :GRASS,
        :SEAINCENSE   => :WATER,
        :WAVEINCENSE  => :WATER
      }[item]
      ret = 0 if !has_damaging_move_of_type?(boosted_type)
    when :BLACKSLUDGE
      ret = 4 if has_type?(:POISON)
    when :CHOICEBAND, :MUSCLEBAND
      ret = 0 if !check_for_move { |m| m.physicalMove?(m.type) }
    when :CHOICESPECS, :WISEGLASSES
      ret = 0 if !check_for_move { |m| m.specialMove?(m.type) }
    when :DEEPSEATOOTH
      ret = 0 if !@battler.isSpecies?(:CLAMPERL) || !check_for_move { |m| m.specialMove?(m.type) }
    when :GRISEOUSORB
      ret = 0 if !@battler.isSpecies?(:GIRATINA) || !has_damaging_move_of_type?(:DRAGON, :GHOST)
    when :IRONBALL
      ret = 0 if has_move_with_function?("ThrowUserItemAtTarget")
    when :LIGHTBALL
      ret = 0 if !@battler.isSpecies?(:PIKACHU) || !check_for_move { |m| m.damagingMove? }
    when :LUSTROUSORB
      ret = 0 if !@battler.isSpecies?(:PALKIA) || !has_damaging_move_of_type?(:DRAGON, :WATER)
    when :SOULDEW
      if !@battler.isSpecies?(:LATIAS) && !@battler.isSpecies?(:LATIOS)
        ret = 0
      elsif Settings::SOUL_DEW_POWERS_UP_TYPES
        ret = 0 if !has_damaging_move_of_type?(:PSYCHIC, :DRAGON)
      else
        ret -= 2 if !check_for_move { |m| m.specialMove?(m.type) }   # Also boosts SpDef
      end
    when :THICKCLUB
      ret = 0 if (!@battler.isSpecies?(:CUBONE) && !@battler.isSpecies?(:MAROWAK)) ||
                 !check_for_move { |m| m.physicalMove?(m.type) }
    end
    # Prefer if this battler knows Fling and it will do a lot of damage/have an
    # additional (negative) effect when flung
    if has_move_with_function?("ThrowUserItemAtTarget")
      GameData::Item.get(item).flags.each do |flag|
        next if !flag[/^Fling_(\d+)$/i]
        amt = $~[1].to_i
        ret += 1 if amt >= 80
        ret += 1 if amt >= 100
        break
      end
      if [:FLAMEORB, :KINGSROCK, :LIGHTBALL, :POISONBARB, :RAZORFANG, :TOXICORB].include?(item)
        ret += 1
      end
    end
    # Don't prefer if this battler knows Acrobatics
    if has_move_with_function?("DoublePowerIfUserHasNoItem")
      ret += (item == :NONE) ? 1 : -1
    end
    return ret
  end

  #=============================================================================

  # Items can be consumed by Stuff Cheeks, Teatime, Bug Bite/Pluck and Fling.
  def get_score_change_for_consuming_item(item)
    ret = 0
    case item
    when :ORANBERRY, :BERRYJUICE, :ENIGMABERRY, :SITRUSBERRY
      # Healing
      ret += (hp > totalhp * 3 / 4) ? -8 : 8
      ret = ret * 3 / 2 if GameData::Item.get(item).is_berry? && has_active_ability?(:RIPEN)
    when :AGUAVBERRY, :FIGYBERRY, :IAPAPABERRY, :MAGOBERRY, :WIKIBERRY
      # Healing with confusion
      fraction_to_heal = 8   # Gens 6 and lower
      if Settings::MECHANICS_GENERATION == 7
        fraction_to_heal = 2
      elsif Settings::MECHANICS_GENERATION >= 8
        fraction_to_heal = 3
      end
      ret += (hp > totalhp * (1 - (1 / fraction_to_heal))) ? -8 : 8
      ret = ret * 3 / 2 if GameData::Item.get(item).is_berry? && has_active_ability?(:RIPEN)
      # TODO: Check whether the item will cause confusion?
    when :ASPEARBERRY, :CHERIBERRY, :CHESTOBERRY, :PECHABERRY, :RAWSTBERRY
      # Status cure
      cured_status = {
        :ASPEAR      => :FROZEN,
        :CHERIBERRY  => :PARALYSIS,
        :CHESTOBERRY => :SLEEP,
        :PECHABERRY  => :POISON,
        :RAWSTBERRY  => :BURN
      }[item]
      ret += (cured_status && status == cured_status) ? 8 : -8
    when :PERSIMBERRY
      # Confusion cure
      ret += (effects[PBEffects::Confusion] > 1) ? 8 : -8
    when :LUMBERRY
      # Any status/confusion cure
      ret += (status != :NONE || effects[PBEffects::Confusion] > 1) ? 8 : -8
    when :MENTALHERB
      # Cure mental effects
      ret += 8 if effects[PBEffects::Attract] >= 0 ||
                  effects[PBEffects::Taunt] > 1 ||
                  effects[PBEffects::Encore] > 1 ||
                  effects[PBEffects::Torment] ||
                  effects[PBEffects::Disable] > 1 ||
                  effects[PBEffects::HealBlock] > 1
    when :APICOTBERRY, :GANLONBERRY, :LIECHIBERRY, :PETAYABERRY, :SALACBERRY,
         :KEEBERRY, :MARANGABERRY
      # Stat raise
      stat = {
        :APICOTBERRY  => :SPECIAL_DEFENSE,
        :GANLONBERRY  => :DEFENSE,
        :LIECHIBERRY  => :ATTACK,
        :PETAYABERRY  => :SPECIAL_ATTACK,
        :SALACBERRY   => :SPEED,
        :KEEBERRY     => :DEFENSE,
        :MARANGABERRY => :SPECIAL_DEFENSE
      }[item]
      ret += 8 if stat && @ai.stat_raise_worthwhile?(self, stat)
      ret = ret * 3 / 2 if GameData::Item.get(item).is_berry? && has_active_ability?(:RIPEN)
    when :STARFBERRY
      # Random stat raise
      ret += 8
      ret = ret * 3 / 2 if GameData::Item.get(item).is_berry? && has_active_ability?(:RIPEN)
    when :WHITEHERB
      # Resets lowered stats
      reduced_stats = false
      GameData::Stat.each_battle do |s|
        next if stages[s.id] >= 0
        reduced_stats = true
        break
      end
      ret += 8 if reduced_stats
    when :MICLEBERRY
      # Raises accuracy of next move
      ret += 8
    when :LANSATBERRY
      # Focus energy
      ret += 8 if effects[PBEffects::FocusEnergy] < 2
    when :LEPPABERRY
      # Restore PP
      ret += 8
      ret = ret * 3 / 2 if GameData::Item.get(item).is_berry? && has_active_ability?(:RIPEN)
    end
    return ret
  end

  #=============================================================================

  # These values are taken from the Complete-Fire-Red-Upgrade decomp here:
  # https://github.com/Skeli789/Complete-Fire-Red-Upgrade/blob/f7f35becbd111c7e936b126f6328fc52d9af68c8/src/ability_battle_effects.c#L41
  BASE_ABILITY_RATINGS = {
    :ADAPTABILITY       => 8,
    :AERILATE           => 8,
    :AFTERMATH          => 5,
    :AIRLOCK            => 5,
    :ANALYTIC           => 5,
    :ANGERPOINT         => 4,
    :ANTICIPATION       => 0,
    :ARENATRAP          => 9,
    :AROMAVEIL          => 3,
#    :ASONECHILLINGNEIGH => 0,
#    :ASONEGRIMNEIGH     => 0,
    :AURABREAK          => 3,
    :BADDREAMS          => 4,
#    :BALLFETCH          => 0,
#    :BATTERY            => 0,
    :BATTLEARMOR        => 2,
    :BATTLEBOND         => 6,
    :BEASTBOOST         => 7,
    :BERSERK            => 5,
    :BIGPECKS           => 1,
    :BLAZE              => 5,
    :BULLETPROOF        => 7,
    :CHEEKPOUCH         => 4,
#    :CHILLINGNEIGH      => 0,
    :CHLOROPHYLL        => 6,
    :CLEARBODY          => 4,
    :CLOUDNINE          => 5,
    :COLORCHANGE        => 2,
    :COMATOSE           => 6,
    :COMPETITIVE        => 5,
    :COMPOUNDEYES       => 7,
    :CONTRARY           => 8,
    :CORROSION          => 5,
    :COTTONDOWN         => 3,
#    :CURIOUSMEDICINE    => 0,
    :CURSEDBODY         => 4,
    :CUTECHARM          => 2,
    :DAMP               => 2,
    :DANCER             => 5,
    :DARKAURA           => 6,
    :DAUNTLESSSHIELD    => 3,
    :DAZZLING           => 5,
    :DEFEATIST          => -1,
    :DEFIANT            => 5,
    :DELTASTREAM        => 10,
    :DESOLATELAND       => 10,
    :DISGUISE           => 8,
    :DOWNLOAD           => 7,
    :DRAGONSMAW         => 8,
    :DRIZZLE            => 9,
    :DROUGHT            => 9,
    :DRYSKIN            => 6,
    :EARLYBIRD          => 4,
    :EFFECTSPORE        => 4,
    :ELECTRICSURGE      => 8,
    :EMERGENCYEXIT      => 3,
    :FAIRYAURA          => 6,
    :FILTER             => 6,
    :FLAMEBODY          => 4,
    :FLAREBOOST         => 5,
    :FLASHFIRE          => 6,
    :FLOWERGIFT         => 4,
#    :FLOWERVEIL         => 0,
    :FLUFFY             => 5,
    :FORECAST           => 6,
    :FOREWARN           => 0,
#    :FRIENDGUARD        => 0,
    :FRISK              => 0,
    :FULLMETALBODY      => 4,
    :FURCOAT            => 7,
    :GALEWINGS          => 6,
    :GALVANIZE          => 8,
    :GLUTTONY           => 3,
    :GOOEY              => 5,
    :GORILLATACTICS     => 4,
    :GRASSPELT          => 2,
    :GRASSYSURGE        => 8,
#    :GRIMNEIGH          => 0,
    :GULPMISSLE         => 3,
    :GUTS               => 6,
    :HARVEST            => 5,
#    :HEALER             => 0,
    :HEATPROOF          => 5,
    :HEAVYMETAL         => -1,
#    :HONEYGATHER        => 0,
    :HUGEPOWER          => 10,
    :HUNGERSWITCH       => 2,
    :HUSTLE             => 7,
    :HYDRATION          => 4,
    :HYPERCUTTER        => 3,
    :ICEBODY            => 3,
    :ICEFACE            => 4,
    :ICESCALES          => 7,
#    :ILLUMINATE         => 0,
    :ILLUSION           => 8,
    :IMMUNITY           => 4,
    :IMPOSTER           => 9,
    :INFILTRATOR        => 6,
    :INNARDSOUT         => 5,
    :INNERFOCUS         => 2,
    :INSOMNIA           => 4,
    :INTIMIDATE         => 7,
    :INTREPIDSWORD      => 3,
    :IRONBARBS          => 6,
    :IRONFIST           => 6,
    :JUSTIFIED          => 4,
    :KEENEYE            => 1,
    :KLUTZ              => -1,
    :LEAFGUARD          => 2,
    :LEVITATE           => 7,
    :LIBERO             => 8,
    :LIGHTMETAL         => 2,
    :LIGHTNINGROD       => 7,
    :LIMBER             => 3,
    :LIQUIDOOZE         => 3,
    :LIQUIDVOICE        => 5,
    :LONGREACH          => 3,
    :MAGICBOUNCE        => 9,
    :MAGICGUARD         => 9,
    :MAGICIAN           => 3,
    :MAGMAARMOR         => 1,
    :MAGNETPULL         => 9,
    :MARVELSCALE        => 5,
    :MEGALAUNCHER       => 7,
    :MERCILESS          => 4,
    :MIMICRY            => 2,
#    :MINUS              => 0,
    :MIRRORARMOR        => 6,
    :MISTYSURGE         => 8,
    :MOLDBREAKER        => 7,
    :MOODY              => 10,
    :MOTORDRIVE         => 6,
    :MOXIE              => 7,
    :MULTISCALE         => 8,
    :MULTITYPE          => 8,
    :MUMMY              => 5,
    :NATURALCURE        => 7,
    :NEUROFORCE         => 6,
    :NEUTRALIZINGGAS    => 5,
    :NOGUARD            => 8,
    :NORMALIZE          => -1,
    :OBLIVIOUS          => 2,
    :OVERCOAT           => 5,
    :OVERGROW           => 5,
    :OWNTEMPO           => 3,
    :PARENTALBOND       => 10,
    :PASTELVEIL         => 4,
    :PERISHBODY         => -1,
    :PICKPOCKET         => 3,
    :PICKUP             => 1,
    :PIXILATE           => 8,
#    :PLUS               => 0,
    :POISONHEAL         => 8,
    :POISONPOINT        => 4,
    :POISONTOUCH        => 4,
    :POWERCONSTRUCT     => 10,
#    :POWEROFALCHEMY     => 0,
    :POWERSPOT          => 2,
    :PRANKSTER          => 8,
    :PRESSURE           => 5,
    :PRIMORDIALSEA      => 10,
    :PRISMARMOR         => 6,
    :PROPELLORTAIL      => 2,
    :PROTEAN            => 8,
    :PSYCHICSURGE       => 8,
    :PUNKROCK           => 2,
    :PUREPOWER          => 10,
    :QUEENLYMAJESTY     => 6,
#    :QUICKDRAW          => 0,
    :QUICKFEET          => 5,
    :RAINDISH           => 3,
    :RATTLED            => 3,
#    :RECEIVER           => 0,
    :RECKLESS           => 6,
    :REFRIGERATE        => 8,
    :REGENERATOR        => 8,
    :RIPEN              => 4,
    :RIVALRY            => 1,
    :RKSSYSTEM          => 8,
    :ROCKHEAD           => 5,
    :ROUGHSKIN          => 6,
#    :RUNAWAY            => 0,
    :SANDFORCE          => 4,
    :SANDRUSH           => 6,
    :SANDSPIT           => 5,
    :SANDSTREAM         => 9,
    :SANDVEIL           => 3,
    :SAPSIPPER          => 7,
    :SCHOOLING          => 6,
    :SCRAPPY            => 6,
    :SCREENCLEANER      => 3,
    :SERENEGRACE        => 8,
    :SHADOWSHIELD       => 8,
    :SHADOWTAG          => 10,
    :SHEDSKIN           => 7,
    :SHEERFORCE         => 8,
    :SHELLARMOR         => 2,
    :SHIELDDUST         => 5,
    :SHIELDSDOWN        => 6,
    :SIMPLE             => 8,
    :SKILLLINK          => 7,
    :SLOWSTART          => -2,
    :SLUSHRUSH          => 5,
    :SNIPER             => 3,
    :SNOWCLOAK          => 3,
    :SNOWWARNING        => 8,
    :SOLARPOWER         => 3,
    :SOLIDROCK          => 6,
    :SOULHEART          => 7,
    :SOUNDPROOF         => 4,
    :SPEEDBOOST         => 9,
    :STAKEOUT           => 6,
    :STALL              => -1,
    :STALWART           => 2,
    :STAMINA            => 6,
    :STANCECHANGE       => 10,
    :STATIC             => 4,
    :STEADFAST          => 2,
    :STEAMENGINE        => 3,
    :STEELWORKER        => 6,
    :STEELYSPIRIT       => 2,
    :STENCH             => 1,
    :STICKYHOLD         => 3,
    :STORMDRAIN         => 7,
    :STRONGJAW          => 6,
    :STURDY             => 6,
    :SUCTIONCUPS        => 2,
    :SUPERLUCK          => 3,
    :SURGESURFER        => 4,
    :SWARM              => 5,
    :SWEETVEIL          => 4,
    :SWIFTSWIM          => 6,
#    :SYMBIOSIS          => 0,
    :SYNCHRONIZE        => 4,
    :TANGLEDFEET        => 2,
    :TANGLINGHAIR       => 5,
    :TECHNICIAN         => 8,
#    :TELEPATHY          => 0,
    :TERAVOLT           => 7,
    :THICKFAT           => 7,
    :TINTEDLENS         => 7,
    :TORRENT            => 5,
    :TOUGHCLAWS         => 7,
    :TOXICBOOST         => 6,
    :TRACE              => 6,
    :TRANSISTOR         => 8,
    :TRIAGE             => 7,
    :TRUANT             => -2,
    :TURBOBLAZE         => 7,
    :UNAWARE            => 6,
    :UNBURDEN           => 7,
    :UNNERVE            => 3,
#    :UNSEENFIST         => 0,
    :VICTORYSTAR        => 6,
    :VITALSPIRIT        => 4,
    :VOLTABSORB         => 7,
    :WANDERINGSPIRIT    => 2,
    :WATERABSORB        => 7,
    :WATERBUBBLE        => 8,
    :WATERCOMPACTION    => 4,
    :WATERVEIL          => 4,
    :WEAKARMOR          => 2,
    :WHITESMOKE         => 4,
    :WIMPOUT            => 3,
    :WONDERGUARD        => 10,
    :WONDERSKIN         => 4,
    :ZENMODE            => -1
  }

  # Returns a value indicating how beneficial the given ability will be to this
  # battler if it has it.
  # Return values are typically between -10 and +10. 0 is indifferent, positive
  # values mean this battler benefits, negative values mean this battler suffers.
  # NOTE: This method assumes the ability isn't being negated. The calculations
  #       that call this method separately check for it being negated, because
  #       they need to do something special in that case.
  def wants_ability?(ability = :NONE)
    ability = ability.id if !ability.is_a?(Symbol) && ability.respond_to?("id")
    # TODO: Ideally replace the above list of ratings with context-sensitive
    #       calculations. Should they all go in this method, or should there be
    #       more handlers for each ability?
    case ability
    when :BLAZE
      return 0 if !has_damaging_move_of_type?(:FIRE)
    when :CUTECHARM, :RIVALRY
      return 0 if gender == 2
    when :FRIENDGUARD, :HEALER, :SYMBOISIS, :TELEPATHY
      has_ally = false
      each_ally(@side) { |b, i| has_ally = true }
      return 0 if !has_ally
    when :GALEWINGS
      return 0 if !check_for_move { |m| m.type == :FLYING }
    when :HUGEPOWER, :PUREPOWER
      return 0 if !ai.stat_raise_worthwhile?(self, :ATTACK, true)
    when :IRONFIST
      return 0 if !check_for_move { |m| m.punchingMove? }
    when :LIQUIDVOICE
      return 0 if !check_for_move { |m| m.soundMove? }
    when :MEGALAUNCHER
      return 0 if !check_for_move { |m| m.pulseMove? }
    when :OVERGROW
      return 0 if !has_damaging_move_of_type?(:GRASS)
    when :PRANKSTER
      return 0 if !check_for_move { |m| m.statusMove? }
    when :PUNKROCK
      return 1 if !check_for_move { |m| m.damagingMove? && m.soundMove? }
    when :RECKLESS
      return 0 if !check_for_move { |m| m.recoilMove? }
    when :ROCKHEAD
      return 0 if !check_for_move { |m| m.recoilMove? && !m.is_a?(Battle::Move::CrashDamageIfFailsUnusableInGravity) }
    when :RUNAWAY
      return 0 if wild?
    when :SANDFORCE
      return 2 if !has_damaging_move_of_type?(:GROUND, :ROCK, :STEEL)
    when :SKILLLINK
      return 0 if !check_for_move { |m| m.is_a?(Battle::Move::HitTwoToFiveTimes) }
    when :STEELWORKER
      return 0 if !has_damaging_move_of_type?(:GRASS)
    when :SWARM
      return 0 if !has_damaging_move_of_type?(:BUG)
    when :TORRENT
      return 0 if !has_damaging_move_of_type?(:WATER)
    when :TRIAGE
      return 0 if !check_for_move { |m| m.healingMove? }
    end
    ret = BASE_ABILITY_RATINGS[ability] || 0
    return ret
  end

  #=============================================================================

  private

  def effectiveness_of_type_against_single_battler_type(type, defend_type, user = nil)
    ret = Effectiveness.calculate(type, defend_type)
    if Effectiveness.ineffective_type?(type, defend_type)
      # Ring Target
      if has_active_item?(:RINGTARGET)
        ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
      end
      # Foresight
      if (user&.has_active_ability?(:SCRAPPY) || @battler.effects[PBEffects::Foresight]) &&
         defend_type == :GHOST
        ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
      end
      # Miracle Eye
      if @battler.effects[PBEffects::MiracleEye] && defend_type == :DARK
        ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
      end
    elsif Effectiveness.super_effective_type?(type, defend_type)
      # Delta Stream's weather
      if @battler.effectiveWeather == :StrongWinds && defend_type == :FLYING
        ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
      end
    end
    # Grounded Flying-type Pokémon become susceptible to Ground moves
    if !@battler.airborne? && defend_type == :FLYING && type == :GROUND
      ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
    end
    return ret
  end
end
