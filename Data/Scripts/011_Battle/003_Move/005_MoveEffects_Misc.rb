#===============================================================================
# No additional effect.
#===============================================================================
class Battle::Move::None < Battle::Move
end

#===============================================================================
# Does absolutely nothing. Shows a special message. (Celebrate)
#===============================================================================
class Battle::Move::DoesNothingCongratulations < Battle::Move
  def pbEffectGeneral(user)
    if user.wild?
      @battle.pbDisplay(_INTL("Congratulations from {1}!", user.pbThis(true)))
    else
      @battle.pbDisplay(_INTL("Congratulations, {1}!", @battle.pbGetOwnerName(user.index)))
    end
  end
end

#===============================================================================
# Does absolutely nothing. (Hold Hands)
#===============================================================================
class Battle::Move::DoesNothingFailsIfNoAlly < Battle::Move
  def ignoresSubstitute?(user); return true; end

  def pbMoveFailed?(user, targets)
    if user.allAllies.length == 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
end

#===============================================================================
# Does absolutely nothing. (Splash)
#===============================================================================
class Battle::Move::DoesNothingUnusableInGravity < Battle::Move
  def unusableInGravity?; return true; end

  def pbEffectGeneral(user)
    @battle.pbDisplay(_INTL("But nothing happened!"))
  end
end

#===============================================================================
# Scatters coins that the player picks up after winning the battle. (Pay Day)
# NOTE: In Gen 6+, if the user levels up after this move is used, the amount of
#       money picked up depends on the user's new level rather than its level
#       when it used the move. I think this is silly, so I haven't coded this
#       effect.
#===============================================================================
class Battle::Move::AddMoneyGainedFromBattle < Battle::Move
  def pbEffectGeneral(user)
    if user.pbOwnedByPlayer?
      @battle.field.effects[PBEffects::PayDay] += 5 * user.level
    end
    @battle.pbDisplay(_INTL("Coins were scattered everywhere!"))
  end
end

#===============================================================================
# Doubles the prize money the player gets after winning the battle. (Happy Hour)
#===============================================================================
class Battle::Move::DoubleMoneyGainedFromBattle < Battle::Move
  def pbEffectGeneral(user)
    @battle.field.effects[PBEffects::HappyHour] = true if !user.opposes?
    @battle.pbDisplay(_INTL("Everyone is caught up in the happy atmosphere!"))
  end
end

#===============================================================================
# Fails if this isn't the user's first turn. (First Impression)
#===============================================================================
class Battle::Move::FailsIfNotUserFirstTurn < Battle::Move
  def pbMoveFailed?(user, targets)
    if user.turnCount > 1
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
end

#===============================================================================
# Fails unless user has already used all other moves it knows. (Last Resort)
#===============================================================================
class Battle::Move::FailsIfUserHasUnusedMove < Battle::Move
  def pbFailsAgainstTarget?(user, target, show_message)
    hasThisMove = false
    hasOtherMoves = false
    hasUnusedMoves = false
    user.eachMove do |m|
      hasThisMove    = true if m.id == @id
      hasOtherMoves  = true if m.id != @id
      hasUnusedMoves = true if m.id != @id && !user.movesUsed.include?(m.id)
    end
    if !hasThisMove || !hasOtherMoves || hasUnusedMoves
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end
end

#===============================================================================
# Fails unless user has consumed a berry at some point. (Belch)
#===============================================================================
class Battle::Move::FailsIfUserNotConsumedBerry < Battle::Move
  def pbCanChooseMove?(user, commandPhase, showMessages)
    if !user.belched?
      if showMessages
        msg = _INTL("{1} hasn't eaten any held berry, so it can't possibly belch!", user.pbThis)
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false
    end
    return true
  end

  def pbMoveFailed?(user, targets)
    if !user.belched?
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
end

#===============================================================================
# Fails if the target is not holding an item, or if the target is affected by
# Magic Room/Klutz. (Poltergeist)
#===============================================================================
class Battle::Move::FailsIfTargetHasNoItem < Battle::Move
  def pbFailsAgainstTarget?(user, target, show_message)
    if !target.item || !target.itemActive?
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    @battle.pbDisplay(_INTL("{1} is about to be attacked by its {2}!", target.pbThis, target.itemName))
    return false
  end
end

#===============================================================================
# Only damages Pokémon that share a type with the user. (Synchronoise)
#===============================================================================
class Battle::Move::FailsUnlessTargetSharesTypeWithUser < Battle::Move
  def pbFailsAgainstTarget?(user, target, show_message)
    userTypes = user.pbTypes(true)
    targetTypes = target.pbTypes(true)
    sharesType = false
    userTypes.each do |t|
      next if !targetTypes.include?(t)
      sharesType = true
      break
    end
    if !sharesType
      @battle.pbDisplay(_INTL("{1} is unaffected!", target.pbThis)) if show_message
      return true
    end
    return false
  end
end

#===============================================================================
# Fails if user was hit by a damaging move this round. (Focus Punch)
#===============================================================================
class Battle::Move::FailsIfUserDamagedThisTurn < Battle::Move
  def pbDisplayChargeMessage(user)
    user.effects[PBEffects::FocusPunch] = true
    @battle.pbCommonAnimation("FocusPunch", user)
    @battle.pbDisplay(_INTL("{1} is tightening its focus!", user.pbThis))
  end

  def pbDisplayUseMessage(user)
    super if !user.effects[PBEffects::FocusPunch] || !user.tookMoveDamageThisRound
  end

  def pbMoveFailed?(user, targets)
    if user.effects[PBEffects::FocusPunch] && user.tookMoveDamageThisRound
      @battle.pbDisplay(_INTL("{1} lost its focus and couldn't move!", user.pbThis))
      return true
    end
    return false
  end
end

#===============================================================================
# Fails if the target didn't choose a damaging move to use this round, or has
# already moved. (Sucker Punch)
#===============================================================================
class Battle::Move::FailsIfTargetActed < Battle::Move
  def pbFailsAgainstTarget?(user, target, show_message)
    if @battle.choices[target.index][0] != :UseMove
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    oppMove = @battle.choices[target.index][2]
    if !oppMove ||
       (oppMove.function_code != "UseMoveTargetIsAboutToUse" &&
       (target.movedThisRound? || oppMove.statusMove?))
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end
end

#===============================================================================
# If attack misses, user takes crash damage of 1/2 of max HP.
# (High Jump Kick, Jump Kick)
#===============================================================================
class Battle::Move::CrashDamageIfFailsUnusableInGravity < Battle::Move
  def recoilMove?;        return true; end
  def unusableInGravity?; return true; end

  def pbCrashDamage(user)
    return if !user.takesIndirectDamage?
    @battle.pbDisplay(_INTL("{1} kept going and crashed!", user.pbThis))
    @battle.scene.pbDamageAnimation(user)
    user.pbReduceHP(user.totalhp / 2, false)
    user.pbItemHPHealCheck
    user.pbFaint if user.fainted?
  end
end

#===============================================================================
# Starts sunny weather. (Sunny Day)
#===============================================================================
class Battle::Move::StartSunWeather < Battle::Move::WeatherMove
  def initialize(battle, move)
    super
    @weatherType = :Sun
  end
end

#===============================================================================
# Starts rainy weather. (Rain Dance)
#===============================================================================
class Battle::Move::StartRainWeather < Battle::Move::WeatherMove
  def initialize(battle, move)
    super
    @weatherType = :Rain
  end
end

#===============================================================================
# Starts sandstorm weather. (Sandstorm)
#===============================================================================
class Battle::Move::StartSandstormWeather < Battle::Move::WeatherMove
  def initialize(battle, move)
    super
    @weatherType = :Sandstorm
  end
end

#===============================================================================
# Starts hail weather. (Hail)
#===============================================================================
class Battle::Move::StartHailWeather < Battle::Move::WeatherMove
  def initialize(battle, move)
    super
    @weatherType = :Hail
  end
end

#===============================================================================
# For 5 rounds, creates an electric terrain which boosts Electric-type moves and
# prevents Pokémon from falling asleep. Affects non-airborne Pokémon only.
# (Electric Terrain)
#===============================================================================
class Battle::Move::StartElectricTerrain < Battle::Move
  def pbMoveFailed?(user, targets)
    if @battle.field.terrain == :Electric
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.pbStartTerrain(user, :Electric)
  end
end

#===============================================================================
# For 5 rounds, creates a grassy terrain which boosts Grass-type moves and heals
# Pokémon at the end of each round. Affects non-airborne Pokémon only.
# (Grassy Terrain)
#===============================================================================
class Battle::Move::StartGrassyTerrain < Battle::Move
  def pbMoveFailed?(user, targets)
    if @battle.field.terrain == :Grassy
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.pbStartTerrain(user, :Grassy)
  end
end

#===============================================================================
# For 5 rounds, creates a misty terrain which weakens Dragon-type moves and
# protects Pokémon from status problems. Affects non-airborne Pokémon only.
# (Misty Terrain)
#===============================================================================
class Battle::Move::StartMistyTerrain < Battle::Move
  def pbMoveFailed?(user, targets)
    if @battle.field.terrain == :Misty
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.pbStartTerrain(user, :Misty)
  end
end

#===============================================================================
# For 5 rounds, creates a psychic terrain which boosts Psychic-type moves and
# prevents Pokémon from being hit by >0 priority moves. Affects non-airborne
# Pokémon only. (Psychic Terrain)
#===============================================================================
class Battle::Move::StartPsychicTerrain < Battle::Move
  def pbMoveFailed?(user, targets)
    if @battle.field.terrain == :Psychic
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.pbStartTerrain(user, :Psychic)
  end
end

#===============================================================================
# Removes the current terrain. Fails if there is no terrain in effect.
# (Steel Roller)
#===============================================================================
class Battle::Move::RemoveTerrain < Battle::Move
  def pbMoveFailed?(user, targets)
    if @battle.field.terrain == :None
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    case @battle.field.terrain
    when :Electric
      @battle.pbDisplay(_INTL("The electricity disappeared from the battlefield."))
    when :Grassy
      @battle.pbDisplay(_INTL("The grass disappeared from the battlefield."))
    when :Misty
      @battle.pbDisplay(_INTL("The mist disappeared from the battlefield."))
    when :Psychic
      @battle.pbDisplay(_INTL("The weirdness disappeared from the battlefield."))
    end
    @battle.field.terrain = :None
  end
end

#===============================================================================
# Entry hazard. Lays spikes on the opposing side (max. 3 layers). (Spikes)
#===============================================================================
class Battle::Move::AddSpikesToFoeSide < Battle::Move
  def canMagicCoat?; return true; end

  def pbMoveFailed?(user, targets)
    if user.pbOpposingSide.effects[PBEffects::Spikes] >= 3
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.pbOpposingSide.effects[PBEffects::Spikes] += 1
    @battle.pbDisplay(_INTL("Spikes were scattered all around {1}'s feet!",
                            user.pbOpposingTeam(true)))
  end
end

#===============================================================================
# Entry hazard. Lays poison spikes on the opposing side (max. 2 layers).
# (Toxic Spikes)
#===============================================================================
class Battle::Move::AddToxicSpikesToFoeSide < Battle::Move
  def canMagicCoat?; return true; end

  def pbMoveFailed?(user, targets)
    if user.pbOpposingSide.effects[PBEffects::ToxicSpikes] >= 2
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.pbOpposingSide.effects[PBEffects::ToxicSpikes] += 1
    @battle.pbDisplay(_INTL("Poison spikes were scattered all around {1}'s feet!",
                            user.pbOpposingTeam(true)))
  end
end

#===============================================================================
# Entry hazard. Lays stealth rocks on the opposing side. (Stealth Rock)
#===============================================================================
class Battle::Move::AddStealthRocksToFoeSide < Battle::Move
  def canMagicCoat?; return true; end

  def pbMoveFailed?(user, targets)
    if user.pbOpposingSide.effects[PBEffects::StealthRock]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.pbOpposingSide.effects[PBEffects::StealthRock] = true
    @battle.pbDisplay(_INTL("Pointed stones float in the air around {1}!",
                            user.pbOpposingTeam(true)))
  end
end

#===============================================================================
# Entry hazard. Lays stealth rocks on the opposing side. (Sticky Web)
#===============================================================================
class Battle::Move::AddStickyWebToFoeSide < Battle::Move
  def canMagicCoat?; return true; end

  def pbMoveFailed?(user, targets)
    if user.pbOpposingSide.effects[PBEffects::StickyWeb]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.pbOpposingSide.effects[PBEffects::StickyWeb] = true
    @battle.pbDisplay(_INTL("A sticky web has been laid out beneath {1}'s feet!",
                            user.pbOpposingTeam(true)))
  end
end

#===============================================================================
# All effects that apply to one side of the field are swapped to the opposite
# side. (Court Change)
#===============================================================================
class Battle::Move::SwapSideEffects < Battle::Move
  attr_reader :number_effects, :boolean_effects

  def initialize(battle, move)
    super
    @number_effects = [
      PBEffects::AuroraVeil,
      PBEffects::LightScreen,
      PBEffects::Mist,
      PBEffects::Rainbow,
      PBEffects::Reflect,
      PBEffects::Safeguard,
      PBEffects::SeaOfFire,
      PBEffects::Spikes,
      PBEffects::Swamp,
      PBEffects::Tailwind,
      PBEffects::ToxicSpikes
    ]
    @boolean_effects = [
      PBEffects::StealthRock,
      PBEffects::StickyWeb
    ]
  end

  def pbMoveFailed?(user, targets)
    has_effect = false
    2.times do |side|
      effects = @battle.sides[side].effects
      @number_effects.each do |e|
        next if effects[e] == 0
        has_effect = true
        break
      end
      break if has_effect
      @boolean_effects.each do |e|
        next if !effects[e]
        has_effect = true
        break
      end
      break if has_effect
    end
    if !has_effect
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    side0 = @battle.sides[0]
    side1 = @battle.sides[1]
    @number_effects.each do |e|
      side0.effects[e], side1.effects[e] = side1.effects[e], side0.effects[e]
    end
    @boolean_effects.each do |e|
      side0.effects[e], side1.effects[e] = side1.effects[e], side0.effects[e]
    end
    @battle.pbDisplay(_INTL("{1} swapped the battle effects affecting each side of the field!", user.pbThis))
  end
end

#===============================================================================
# User turns 1/4 of max HP into a substitute. (Substitute)
#===============================================================================
class Battle::Move::UserMakeSubstitute < Battle::Move
  def canSnatch?; return true; end

  def pbMoveFailed?(user, targets)
    if user.effects[PBEffects::Substitute] > 0
      @battle.pbDisplay(_INTL("{1} already has a substitute!", user.pbThis))
      return true
    end
    @subLife = [user.totalhp / 4, 1].max
    if user.hp <= @subLife
      @battle.pbDisplay(_INTL("But it does not have enough HP left to make a substitute!"))
      return true
    end
    return false
  end

  def pbOnStartUse(user, targets)
    user.pbReduceHP(@subLife, false, false)
    user.pbItemHPHealCheck
  end

  def pbEffectGeneral(user)
    user.effects[PBEffects::Trapping]     = 0
    user.effects[PBEffects::TrappingMove] = nil
    user.effects[PBEffects::Substitute]   = @subLife
    @battle.pbDisplay(_INTL("{1} put in a substitute!", user.pbThis))
  end
end

#===============================================================================
# Removes trapping moves, entry hazards and Leech Seed on user/user's side.
# Raises user's Speed by 1 stage (Gen 8+). (Rapid Spin)
#===============================================================================
class Battle::Move::RemoveUserBindingAndEntryHazards < Battle::Move::StatUpMove
  def initialize(battle, move)
    super
    @statUp = [:SPEED, 1]
  end

  def pbEffectAfterAllHits(user, target)
    return if user.fainted? || target.damageState.unaffected
    if user.effects[PBEffects::Trapping] > 0
      trapMove = GameData::Move.get(user.effects[PBEffects::TrappingMove]).name
      trapUser = @battle.battlers[user.effects[PBEffects::TrappingUser]]
      @battle.pbDisplay(_INTL("{1} got free of {2}'s {3}!", user.pbThis, trapUser.pbThis(true), trapMove))
      user.effects[PBEffects::Trapping]     = 0
      user.effects[PBEffects::TrappingMove] = nil
      user.effects[PBEffects::TrappingUser] = -1
    end
    if user.effects[PBEffects::LeechSeed] >= 0
      user.effects[PBEffects::LeechSeed] = -1
      @battle.pbDisplay(_INTL("{1} shed Leech Seed!", user.pbThis))
    end
    if user.pbOwnSide.effects[PBEffects::StealthRock]
      user.pbOwnSide.effects[PBEffects::StealthRock] = false
      @battle.pbDisplay(_INTL("{1} blew away stealth rocks!", user.pbThis))
    end
    if user.pbOwnSide.effects[PBEffects::Spikes] > 0
      user.pbOwnSide.effects[PBEffects::Spikes] = 0
      @battle.pbDisplay(_INTL("{1} blew away spikes!", user.pbThis))
    end
    if user.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0
      user.pbOwnSide.effects[PBEffects::ToxicSpikes] = 0
      @battle.pbDisplay(_INTL("{1} blew away poison spikes!", user.pbThis))
    end
    if user.pbOwnSide.effects[PBEffects::StickyWeb]
      user.pbOwnSide.effects[PBEffects::StickyWeb] = false
      @battle.pbDisplay(_INTL("{1} blew away sticky webs!", user.pbThis))
    end
  end

  def pbAdditionalEffect(user, target)
    super if Settings::MECHANICS_GENERATION >= 8
  end
end

#===============================================================================
# Attacks 2 rounds in the future. (Doom Desire, Future Sight)
#===============================================================================
class Battle::Move::AttackTwoTurnsLater < Battle::Move
  def targetsPosition?; return true; end

  # Stops damage being dealt in the setting-up turn.
  def pbDamagingMove?
    return false if !@battle.futureSight
    return super
  end

  def pbAccuracyCheck(user, target)
    return true if !@battle.futureSight
    return super
  end

  def pbDisplayUseMessage(user)
    super if !@battle.futureSight
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    if !@battle.futureSight &&
       @battle.positions[target.index].effects[PBEffects::FutureSightCounter] > 0
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    return if @battle.futureSight   # Attack is hitting
    effects = @battle.positions[target.index].effects
    effects[PBEffects::FutureSightCounter]        = 3
    effects[PBEffects::FutureSightMove]           = @id
    effects[PBEffects::FutureSightUserIndex]      = user.index
    effects[PBEffects::FutureSightUserPartyIndex] = user.pokemonIndex
    if @id == :DOOMDESIRE
      @battle.pbDisplay(_INTL("{1} chose Doom Desire as its destiny!", user.pbThis))
    else
      @battle.pbDisplay(_INTL("{1} foresaw an attack!", user.pbThis))
    end
  end

  def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    hitNum = 1 if !@battle.futureSight   # Charging anim
    super
  end
end

#===============================================================================
# User switches places with its ally. (Ally Switch)
#===============================================================================
class Battle::Move::UserSwapsPositionsWithAlly < Battle::Move
  def pbMoveFailed?(user, targets)
    numTargets = 0
    @idxAlly = -1
    idxUserOwner = @battle.pbGetOwnerIndexFromBattlerIndex(user.index)
    user.allAllies.each do |b|
      next if @battle.pbGetOwnerIndexFromBattlerIndex(b.index) != idxUserOwner
      next if !b.near?(user)
      numTargets += 1
      @idxAlly = b.index
    end
    if numTargets != 1
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    idxA = user.index
    idxB = @idxAlly
    if @battle.pbSwapBattlers(idxA, idxB)
      @battle.pbDisplay(_INTL("{1} and {2} switched places!",
                              @battle.battlers[idxB].pbThis, @battle.battlers[idxA].pbThis(true)))
      [idxA, idxB].each { |idx| @battle.pbEffectsOnBattlerEnteringPosition(@battle.battlers[idx]) }
    end
  end
end

#===============================================================================
# If a Pokémon makes contact with the user before it uses this move, the
# attacker is burned. (Beak Blast)
#===============================================================================
class Battle::Move::BurnAttackerBeforeUserActs < Battle::Move
  def pbDisplayChargeMessage(user)
    user.effects[PBEffects::BeakBlast] = true
    @battle.pbCommonAnimation("BeakBlast", user)
    @battle.pbDisplay(_INTL("{1} started heating up its beak!", user.pbThis))
  end
end
