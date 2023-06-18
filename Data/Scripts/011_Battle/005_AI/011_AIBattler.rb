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
    @party_index = battler.pokemonIndex
  end

  def pokemon;     return battler.pokemon;     end
  def level;       return battler.level;       end
  def hp;          return battler.hp;          end
  def totalhp;     return battler.totalhp;     end
  def fainted?;    return battler.fainted?;    end
  def status;      return battler.status;      end
  def statusCount; return battler.statusCount; end
  def gender;      return battler.gender;      end
  def turnCount;   return battler.turnCount;   end
  def effects;     return battler.effects;     end
  def stages;      return battler.stages;      end
  def statStageAtMax?(stat); return battler.statStageAtMax?(stat); end
  def statStageAtMin?(stat); return battler.statStageAtMin?(stat); end
  def moves;       return battler.moves;       end

  def wild?
    return @ai.battle.wildBattle? && opposes?
  end

  def name
    return sprintf("%s (%d)", battler.name, @index)
  end

  def opposes?(other = nil)
    return @side == 1 if other.nil?
    return other.side != @side
  end

  def idxOwnSide;      return battler.idxOwnSide;      end
  def pbOwnSide;       return battler.pbOwnSide;       end
  def idxOpposingSide; return battler.idxOpposingSide; end
  def pbOpposingSide;  return battler.pbOpposingSide;  end

  #-----------------------------------------------------------------------------

  # Returns how much damage this battler will take at the end of this round.
  def rough_end_of_round_damage
    ret = 0
    # Weather
    weather = battler.effectiveWeather
    if @ai.battle.field.weatherDuration == 1
      weather = @ai.battle.field.defaultWeather
      weather = :None if @ai.battle.allBattlers.any? { |b| b.hasActiveAbility?([:CLOUDNINE, :AIRLOCK]) }
      weather = :None if [:Sun, :Rain, :HarshSun, :HeavyRain].include?(weather) && has_active_item?(:UTILITYUMBRELLA)
    end
    case weather
    when :Sandstorm
      ret += [self.totalhp / 16, 1].max if battler.takesSandstormDamage?
    when :Hail
      ret += [self.totalhp / 16, 1].max if battler.takesHailDamage?
    when :ShadowSky
      ret += [self.totalhp / 16, 1].max if battler.takesShadowSkyDamage?
    end
    case ability_id
    when :DRYSKIN
      ret += [self.totalhp / 8, 1].max if [:Sun, :HarshSun].include?(weather) && battler.takesIndirectDamage?
      ret -= [self.totalhp / 8, 1].max if [:Rain, :HeavyRain].include?(weather) && battler.canHeal?
    when :ICEBODY
      ret -= [self.totalhp / 16, 1].max if weather == :Hail && battler.canHeal?
    when :RAINDISH
      ret -= [self.totalhp / 16, 1].max if [:Rain, :HeavyRain].include?(weather) && battler.canHeal?
    when :SOLARPOWER
      ret += [self.totalhp / 8, 1].max if [:Sun, :HarshSun].include?(weather) && battler.takesIndirectDamage?
    end
    # Future Sight/Doom Desire
    # NOTE: Not worth estimating the damage from this.
    # Wish
    if @ai.battle.positions[@index].effects[PBEffects::Wish] == 1 && battler.canHeal?
      ret -= @ai.battle.positions[@index].effects[PBEffects::WishAmount]
    end
    # Sea of Fire
    if @ai.battle.sides[@side].effects[PBEffects::SeaOfFire] > 1 &&
       battler.takesIndirectDamage? && !has_type?(:FIRE)
      ret += [self.totalhp / 8, 1].max
    end
    # Grassy Terrain (healing)
    if @ai.battle.field.terrain == :Grassy && battler.affectedByTerrain? && battler.canHeal?
      ret -= [self.totalhp / 16, 1].max
    end
    # Leftovers/Black Sludge
    if has_active_item?(:BLACKSLUDGE)
      if has_type?(:POISON)
        ret -= [self.totalhp / 16, 1].max if battler.canHeal?
      else
        ret += [self.totalhp / 8, 1].max if battler.takesIndirectDamage?
      end
    elsif has_active_item?(:LEFTOVERS)
      ret -= [self.totalhp / 16, 1].max if battler.canHeal?
    end
    # Aqua Ring
    if self.effects[PBEffects::AquaRing] && battler.canHeal?
      amt = self.totalhp / 16
      amt = (amt * 1.3).floor if has_active_item?(:BIGROOT)
      ret -= [amt, 1].max
    end
    # Ingrain
    if self.effects[PBEffects::Ingrain] && battler.canHeal?
      amt = self.totalhp / 16
      amt = (amt * 1.3).floor if has_active_item?(:BIGROOT)
      ret -= [amt, 1].max
    end
    # Leech Seed
    if self.effects[PBEffects::LeechSeed] >= 0
      if battler.takesIndirectDamage?
        ret += [self.totalhp / 8, 1].max if battler.takesIndirectDamage?
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
    if battler.inHyperMode?
      ret += [self.totalhp / 24, 1].max
    end
    # Poison/burn/Nightmare
    if self.status == :POISON
      if has_active_ability?(:POISONHEAL)
        ret -= [self.totalhp / 8, 1].max if battler.canHeal?
      elsif battler.takesIndirectDamage?
        mult = 2
        mult = [self.effects[PBEffects::Toxic] + 1, 16].min if self.statusCount > 0   # Toxic
        ret += [mult * self.totalhp / 16, 1].max
      end
    elsif self.status == :BURN
      if battler.takesIndirectDamage?
        amt = (Settings::MECHANICS_GENERATION >= 7) ? self.totalhp / 16 : self.totalhp / 8
        amt = (amt / 2.0).round if has_active_ability?(:HEATPROOF)
        ret += [amt, 1].max
      end
    elsif battler.asleep? && self.statusCount > 1 && self.effects[PBEffects::Nightmare]
      ret += [self.totalhp / 4, 1].max if battler.takesIndirectDamage?
    end
    # Curse
    if self.effects[PBEffects::Curse]
      ret += [self.totalhp / 4, 1].max if battler.takesIndirectDamage?
    end
    # Trapping damage
    if self.effects[PBEffects::Trapping] > 1 && battler.takesIndirectDamage?
      amt = (Settings::MECHANICS_GENERATION >= 6) ? self.totalhp / 8 : self.totalhp / 16
      if @ai.battlers[self.effects[PBEffects::TrappingUser]].has_active_item?(:BINDINGBAND)
        amt = (Settings::MECHANICS_GENERATION >= 6) ? self.totalhp / 6 : self.totalhp / 8
      end
      ret += [amt, 1].max
    end
    # Perish Song
    return 999_999 if self.effects[PBEffects::PerishSong] == 1
    # Bad Dreams
    if battler.asleep? && self.statusCount > 1 && battler.takesIndirectDamage?
      @ai.each_battler do |b, i|
        next if i == @index || !b.battler.near?(battler) || !b.has_active_ability?(:BADDREAMS)
        ret += [self.totalhp / 8, 1].max
      end
    end
    # Sticky Barb
    if has_active_item?(:STICKYBARB) && battler.takesIndirectDamage?
      ret += [self.totalhp / 8, 1].max
    end
    return ret
  end

  #-----------------------------------------------------------------------------

  def base_stat(stat)
    ret = 0
    case stat
    when :ATTACK          then ret = battler.attack
    when :DEFENSE         then ret = battler.defense
    when :SPECIAL_ATTACK  then ret = battler.spatk
    when :SPECIAL_DEFENSE then ret = battler.spdef
    when :SPEED           then ret = battler.speed
    end
    return ret
  end

  def rough_stat(stat)
    return battler.pbSpeed if stat == :SPEED && @ai.trainer.high_skill?
    stage_mul = Battle::Battler::STAT_STAGE_MULTIPLIERS
    stage_div = Battle::Battler::STAT_STAGE_DIVISORS
    if [:ACCURACY, :EVASION].include?(stat)
      stage_mul = Battle::Battler::ACC_EVA_STAGE_MULTIPLIERS
      stage_div = Battle::Battler::ACC_EVA_STAGE_DIVISORS
    end
    stage = battler.stages[stat] + Battle::Battler::STAT_STAGE_MAXIMUM
    value = base_stat(stat)
    return (value.to_f * stage_mul[stage] / stage_div[stage]).floor
  end

  def faster_than?(other)
    return false if other.nil?
    this_speed  = rough_stat(:SPEED)
    other_speed = other.rough_stat(:SPEED)
    return (this_speed > other_speed) ^ (@ai.battle.field.effects[PBEffects::TrickRoom] > 0)
  end

  #-----------------------------------------------------------------------------

  def types; return battler.types; end
  def pbTypes(withExtraType = false); return battler.pbTypes(withExtraType); end

  def has_type?(type)
    return false if !type
    active_types = pbTypes(true)
    return active_types.include?(GameData::Type.get(type).id)
  end
  alias pbHasType? has_type?

  def effectiveness_of_type_against_battler(type, user = nil, move = nil)
    ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
    return ret if !type
    return ret if type == :GROUND && has_type?(:FLYING) && has_active_item?(:IRONBALL)
    # Get effectivenesses
    if type == :SHADOW
      if battler.shadowPokemon?
        ret = Effectiveness::NOT_VERY_EFFECTIVE_MULTIPLIER
      else
        ret = Effectiveness::SUPER_EFFECTIVE_MULTIPLIER
      end
    else
      battler.pbTypes(true).each do |defend_type|
        mult = effectiveness_of_type_against_single_battler_type(type, defend_type, user)
        if move
          case move.function_code
          when "HitsTargetInSkyGroundsTarget"
            mult = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER if type == :GROUND && defend_type == :FLYING
          when "FreezeTargetSuperEffectiveAgainstWater"
            mult = Effectiveness::SUPER_EFFECTIVE_MULTIPLIER if defend_type == :WATER
          end
        end
        ret *= mult
      end
      ret *= 2 if self.effects[PBEffects::TarShot] && type == :FIRE
    end
    return ret
  end

  #-----------------------------------------------------------------------------

  def ability_id; return battler.ability_id; end
  def ability;    return battler.ability;    end

  def ability_active?
    return battler.abilityActive?
  end

  def has_active_ability?(ability, ignore_fainted = false)
    return battler.hasActiveAbility?(ability, ignore_fainted)
  end

  def has_mold_breaker?
    return battler.hasMoldBreaker?
  end

  #-----------------------------------------------------------------------------

  def item_id; return battler.item_id; end
  def item;    return battler.item;    end

  def item_active?
    return battler.itemActive?
  end

  def has_active_item?(item)
    return battler.hasActiveItem?(item)
  end

  #-----------------------------------------------------------------------------

  def check_for_move
    ret = false
    battler.eachMove do |move|
      next if move.pp == 0 && move.total_pp > 0
      next unless yield move
      ret = true
      break
    end
    return ret
  end

  def has_damaging_move_of_type?(*types)
    check_for_move do |m|
      return true if m.damagingMove? && types.include?(m.pbCalcType(battler))
    end
    return false
  end

  def has_move_with_function?(*functions)
    check_for_move { |m| return true if functions.include?(m.function_code) }
    return false
  end

  #-----------------------------------------------------------------------------

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
    if ability_active? && Battle::AbilityEffects.triggerCertainSwitching(ability, battler, @ai.battle)
      return false
    end
    if item_active? && Battle::ItemEffects.triggerCertainSwitching(item, battler, @ai.battle)
      return false
    end
    # Other certain switching effects
    return false if Settings::MORE_TYPE_EFFECTS && has_type?(:GHOST)
    # Other certain trapping effects
    return false if battler.trappedInBattle?
    # Trapping abilities/items
    @ai.each_foe_battler(side) do |b, i|
      if b.ability_active? &&
         Battle::AbilityEffects.triggerTrappingByTarget(b.ability, battler, b.battler, @ai.battle)
        return false
      end
      if b.item_active? &&
         Battle::ItemEffects.triggerTrappingByTarget(b.item, battler, b.battler, @ai.battle)
        return false
      end
    end
    return true
  end

  #-----------------------------------------------------------------------------

  def wants_status_problem?(new_status)
    return true if new_status == :NONE
    if ability_active?
      case ability_id
      when :GUTS
        return true if ![:SLEEP, :FROZEN].include?(new_status) &&
                       @ai.stat_raise_worthwhile?(self, :ATTACK, true)
      when :MARVELSCALE
        return true if @ai.stat_raise_worthwhile?(self, :DEFENSE, true)
      when :QUICKFEET
        return true if ![:SLEEP, :FROZEN].include?(new_status) &&
                       @ai.stat_raise_worthwhile?(self, :SPEED, true)
      when :FLAREBOOST
        return true if new_status == :BURN && @ai.stat_raise_worthwhile?(self, :SPECIAL_ATTACK, true)
      when :TOXICBOOST
        return true if new_status == :POISON && @ai.stat_raise_worthwhile?(self, :ATTACK, true)
      when :POISONHEAL
        return true if new_status == :POISON
      when :MAGICGUARD   # Want a harmless status problem to prevent getting a harmful one
        return true if new_status == :POISON ||
                       (new_status == :BURN && !@ai.stat_raise_worthwhile?(self, :ATTACK, true))
      end
    end
    return true if new_status == :SLEEP && check_for_move { |m| m.usableWhenAsleep? }
    if has_move_with_function?("DoublePowerIfUserPoisonedBurnedParalyzed")
      return true if [:POISON, :BURN, :PARALYSIS].include?(new_status)
    end
    return false
  end

  #-----------------------------------------------------------------------------

  # Returns a value indicating how beneficial the given ability will be to this
  # battler if it has it.
  # Return values are typically between -10 and +10. 0 is indifferent, positive
  # values mean this battler benefits, negative values mean this battler suffers.
  # NOTE: This method assumes the ability isn't being negated. The calculations
  #       that call this method separately check for it being negated, because
  #       they need to do something special in that case.
  def wants_ability?(ability = :NONE)
    ability = ability.id if !ability.is_a?(Symbol) && ability.respond_to?("id")
    # Get the base ability rating
    ret = 0
    Battle::AI::BASE_ABILITY_RATINGS.each_pair do |val, abilities|
      next if !abilities.include?(ability)
      ret = val
      break
    end
    # Modify the rating based on ability-specific contexts
    if @ai.trainer.medium_skill?
      ret = Battle::AI::Handlers.modify_ability_ranking(ability, ret, self, @ai)
    end
    return ret
  end

  #-----------------------------------------------------------------------------

  # Returns a value indicating how beneficial the given item will be to this
  # battler if it is holding it.
  # Return values are typically between -10 and +10. 0 is indifferent, positive
  # values mean this battler benefits, negative values mean this battler suffers.
  # NOTE: This method assumes the item isn't being negated. The calculations
  #       that call this method separately check for it being negated, because
  #       they need to do something special in that case.
  def wants_item?(item)
    item = :NONE if !item
    item = item.id if !item.is_a?(Symbol) && item.respond_to?("id")
    # Get the base item rating
    ret = 0
    Battle::AI::BASE_ITEM_RATINGS.each_pair do |val, items|
      next if !items.include?(item)
      ret = val
      break
    end
    # Modify the rating based on item-specific contexts
    if @ai.trainer.medium_skill?
      ret = Battle::AI::Handlers.modify_item_ranking(item, ret, self, @ai)
    end
    # Prefer if this battler knows Fling and it will do a lot of damage/have an
    # additional (negative) effect when flung
    if item != :NONE && has_move_with_function?("ThrowUserItemAtTarget")
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

  #-----------------------------------------------------------------------------

  # Items can be consumed by Stuff Cheeks, Teatime, Bug Bite/Pluck and Fling.
  def get_score_change_for_consuming_item(item, try_preserving_item = false)
    ret = 0
    case item
    when :ORANBERRY, :BERRYJUICE, :ENIGMABERRY, :SITRUSBERRY
      # Healing
      ret += (hp > totalhp * 0.75) ? -6 : 6
      ret = ret * 3 / 2 if GameData::Item.get(item).is_berry? && has_active_ability?(:RIPEN)
    when :AGUAVBERRY, :FIGYBERRY, :IAPAPABERRY, :MAGOBERRY, :WIKIBERRY
      # Healing with confusion
      fraction_to_heal = 8   # Gens 6 and lower
      if Settings::MECHANICS_GENERATION == 7
        fraction_to_heal = 2
      elsif Settings::MECHANICS_GENERATION >= 8
        fraction_to_heal = 3
      end
      ret += (hp > totalhp * (1 - (1.0 / fraction_to_heal))) ? -6 : 6
      ret = ret * 3 / 2 if GameData::Item.get(item).is_berry? && has_active_ability?(:RIPEN)
      if @ai.trainer.high_skill?
        flavor_stat = {
          :AGUAVBERRY  => :SPECIAL_DEFENSE,
          :FIGYBERRY   => :ATTACK,
          :IAPAPABERRY => :DEFENSE,
          :MAGOBERRY   => :SPEED,
          :WIKIBERRY   => :SPECIAL_ATTACK
        }[item]
        if @battler.nature.stat_changes.any? { |val| val[0] == flavor_stat && val[1] < 0 }
          ret -= 3 if @battler.pbCanConfuseSelf?(false)
        end
      end
    when :ASPEARBERRY, :CHERIBERRY, :CHESTOBERRY, :PECHABERRY, :RAWSTBERRY
      # Status cure
      cured_status = {
        :ASPEAR      => :FROZEN,
        :CHERIBERRY  => :PARALYSIS,
        :CHESTOBERRY => :SLEEP,
        :PECHABERRY  => :POISON,
        :RAWSTBERRY  => :BURN
      }[item]
      ret += (cured_status && status == cured_status) ? 6 : -6
    when :PERSIMBERRY
      # Confusion cure
      ret += (self.effects[PBEffects::Confusion] > 1) ? 6 : -6
    when :LUMBERRY
      # Any status/confusion cure
      ret += (status != :NONE || self.effects[PBEffects::Confusion] > 1) ? 6 : -6
    when :MENTALHERB
      # Cure mental effects
      if self.effects[PBEffects::Attract] >= 0 ||
         self.effects[PBEffects::Taunt] > 1 ||
         self.effects[PBEffects::Encore] > 1 ||
         self.effects[PBEffects::Torment] ||
         self.effects[PBEffects::Disable] > 1 ||
         self.effects[PBEffects::HealBlock] > 1
        ret += 6
      else
        ret -= 6
      end
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
      ret += (stat && @ai.stat_raise_worthwhile?(self, stat)) ? 8 : -8
      ret = ret * 3 / 2 if GameData::Item.get(item).is_berry? && has_active_ability?(:RIPEN)
    when :STARFBERRY
      # Random stat raise
      ret += 8
      ret = ret * 3 / 2 if GameData::Item.get(item).is_berry? && has_active_ability?(:RIPEN)
    when :WHITEHERB
      # Resets lowered stats
      ret += (battler.hasLoweredStatStages?) ? 8 : -8
    when :MICLEBERRY
      # Raises accuracy of next move
      ret += (@ai.stat_raise_worthwhile?(self, :ACCURACY, true)) ? 6 : -6
    when :LANSATBERRY
      # Focus energy
      ret += (self.effects[PBEffects::FocusEnergy] < 2) ? 6 : -6
    when :LEPPABERRY
      # Restore PP
      ret += 6
      ret = ret * 3 / 2 if GameData::Item.get(item).is_berry? && has_active_ability?(:RIPEN)
    end
    ret = 0 if ret < 0 && !try_preserving_item
    return ret
  end

  #-----------------------------------------------------------------------------

  private

  def effectiveness_of_type_against_single_battler_type(type, defend_type, user = nil)
    ret = Effectiveness.calculate(type, defend_type)
    if Effectiveness.ineffective_type?(type, defend_type)
      # Ring Target
      if has_active_item?(:RINGTARGET)
        ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
      end
      # Foresight
      if (user&.has_active_ability?(:SCRAPPY) || self.effects[PBEffects::Foresight]) &&
         defend_type == :GHOST
        ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
      end
      # Miracle Eye
      if self.effects[PBEffects::MiracleEye] && defend_type == :DARK
        ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
      end
    elsif Effectiveness.super_effective_type?(type, defend_type)
      # Delta Stream's weather
      if battler.effectiveWeather == :StrongWinds && defend_type == :FLYING
        ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
      end
    end
    # Grounded Flying-type Pokémon become susceptible to Ground moves
    if !battler.airborne? && defend_type == :FLYING && type == :GROUND
      ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
    end
    return ret
  end
end
