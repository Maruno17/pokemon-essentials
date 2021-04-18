#===============================================================================
# Starts rainy weather. (Rain Dance)
#===============================================================================
class PokeBattle_Move_100 < PokeBattle_WeatherMove
  def initialize(battle,move)
    super
    @weatherType = :Rain
  end
end



#===============================================================================
# Starts sandstorm weather. (Sandstorm)
#===============================================================================
class PokeBattle_Move_101 < PokeBattle_WeatherMove
  def initialize(battle,move)
    super
    @weatherType = :Sandstorm
  end
end



#===============================================================================
# Starts hail weather. (Hail)
#===============================================================================
class PokeBattle_Move_102 < PokeBattle_WeatherMove
  def initialize(battle,move)
    super
    @weatherType = :Hail
  end
end



#===============================================================================
# Entry hazard. Lays spikes on the opposing side (max. 3 layers). (Spikes)
#===============================================================================
class PokeBattle_Move_103 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if user.pbOpposingSide.effects[PBEffects::Spikes]>=3
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
class PokeBattle_Move_104 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if user.pbOpposingSide.effects[PBEffects::ToxicSpikes]>=2
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
class PokeBattle_Move_105 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
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
# Combos with another Pledge move used by the ally. (Grass Pledge)
# If the move is a combo, power is doubled and causes either a sea of fire or a
# swamp on the opposing side.
#===============================================================================
class PokeBattle_Move_106 < PokeBattle_PledgeMove
  def initialize(battle,move)
    super
    # [Function code to combo with, effect, override type, override animation]
    @combos = [["107", :SeaOfFire, :FIRE, :FIREPLEDGE],
               ["108", :Swamp,     nil,   nil]]
  end
end



#===============================================================================
# Combos with another Pledge move used by the ally. (Fire Pledge)
# If the move is a combo, power is doubled and causes either a rainbow on the
# user's side or a sea of fire on the opposing side.
#===============================================================================
class PokeBattle_Move_107 < PokeBattle_PledgeMove
  def initialize(battle,move)
    super
    # [Function code to combo with, effect, override type, override animation]
    @combos = [["108", :Rainbow,   :WATER, :WATERPLEDGE],
               ["106", :SeaOfFire, nil,    nil]]
  end
end



#===============================================================================
# Combos with another Pledge move used by the ally. (Water Pledge)
# If the move is a combo, power is doubled and causes either a swamp on the
# opposing side or a rainbow on the user's side.
#===============================================================================
class PokeBattle_Move_108 < PokeBattle_PledgeMove
  def initialize(battle,move)
    super
    # [Function code to combo with, effect, override type, override animation]
    @combos = [["106", :Swamp,   :GRASS, :GRASSPLEDGE],
               ["107", :Rainbow, nil,    nil]]
  end
end



#===============================================================================
# Scatters coins that the player picks up after winning the battle. (Pay Day)
# NOTE: In Gen 6+, if the user levels up after this move is used, the amount of
#       money picked up depends on the user's new level rather than its level
#       when it used the move. I think this is silly, so I haven't coded this
#       effect.
#===============================================================================
class PokeBattle_Move_109 < PokeBattle_Move
  def pbEffectGeneral(user)
    if user.pbOwnedByPlayer?
      @battle.field.effects[PBEffects::PayDay] += 5*user.level
    end
    @battle.pbDisplay(_INTL("Coins were scattered everywhere!"))
  end
end



#===============================================================================
# Ends the opposing side's Light Screen, Reflect and Aurora Break. (Brick Break,
# Psychic Fangs)
#===============================================================================
class PokeBattle_Move_10A < PokeBattle_Move
  def ignoresReflect?; return true; end

  def pbEffectGeneral(user)
    if user.pbOpposingSide.effects[PBEffects::LightScreen]>0
      user.pbOpposingSide.effects[PBEffects::LightScreen] = 0
      @battle.pbDisplay(_INTL("{1}'s Light Screen wore off!",user.pbOpposingTeam))
    end
    if user.pbOpposingSide.effects[PBEffects::Reflect]>0
      user.pbOpposingSide.effects[PBEffects::Reflect] = 0
      @battle.pbDisplay(_INTL("{1}'s Reflect wore off!",user.pbOpposingTeam))
    end
    if user.pbOpposingSide.effects[PBEffects::AuroraVeil]>0
      user.pbOpposingSide.effects[PBEffects::AuroraVeil] = 0
      @battle.pbDisplay(_INTL("{1}'s Aurora Veil wore off!",user.pbOpposingTeam))
    end
  end

  def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
    if user.pbOpposingSide.effects[PBEffects::LightScreen]>0 ||
       user.pbOpposingSide.effects[PBEffects::Reflect]>0 ||
       user.pbOpposingSide.effects[PBEffects::AuroraVeil]>0
      hitNum = 1   # Wall-breaking anim
    end
    super
  end
end



#===============================================================================
# If attack misses, user takes crash damage of 1/2 of max HP.
# (High Jump Kick, Jump Kick)
#===============================================================================
class PokeBattle_Move_10B < PokeBattle_Move
  def recoilMove?;        return true; end
  def unusableInGravity?; return true; end

  def pbCrashDamage(user)
    return if !user.takesIndirectDamage?
    @battle.pbDisplay(_INTL("{1} kept going and crashed!",user.pbThis))
    @battle.scene.pbDamageAnimation(user)
    user.pbReduceHP(user.totalhp/2,false)
    user.pbItemHPHealCheck
    user.pbFaint if user.fainted?
  end
end



#===============================================================================
# User turns 1/4 of max HP into a substitute. (Substitute)
#===============================================================================
class PokeBattle_Move_10C < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if user.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("{1} already has a substitute!",user.pbThis))
      return true
    end
    @subLife = user.totalhp/4
    @subLife = 1 if @subLife<1
    if user.hp<=@subLife
      @battle.pbDisplay(_INTL("But it does not have enough HP left to make a substitute!"))
      return true
    end
    return false
  end

  def pbOnStartUse(user,targets)
    user.pbReduceHP(@subLife,false,false)
    user.pbItemHPHealCheck
  end

  def pbEffectGeneral(user)
    user.effects[PBEffects::Trapping]     = 0
    user.effects[PBEffects::TrappingMove] = nil
    user.effects[PBEffects::Substitute]   = @subLife
    @battle.pbDisplay(_INTL("{1} put in a substitute!",user.pbThis))
  end
end



#===============================================================================
# User is Ghost: User loses 1/2 of max HP, and curses the target.
# Cursed Pokémon lose 1/4 of their max HP at the end of each round.
# User is not Ghost: Decreases the user's Speed by 1 stage, and increases the
# user's Attack and Defense by 1 stage each. (Curse)
#===============================================================================
class PokeBattle_Move_10D < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end

  def pbTarget(user)
    return GameData::Target.get(:NearFoe) if user.pbHasType?(:GHOST)
    return super
  end

  def pbMoveFailed?(user,targets)
    return false if user.pbHasType?(:GHOST)
    if !user.pbCanLowerStatStage?(:SPEED,user,self) &&
       !user.pbCanRaiseStatStage?(:ATTACK,user,self) &&
       !user.pbCanRaiseStatStage?(:DEFENSE,user,self)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user,target)
    if user.pbHasType?(:GHOST) && target.effects[PBEffects::Curse]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    return if user.pbHasType?(:GHOST)
    # Non-Ghost effect
    if user.pbCanLowerStatStage?(:SPEED,user,self)
      user.pbLowerStatStage(:SPEED,1,user)
    end
    showAnim = true
    if user.pbCanRaiseStatStage?(:ATTACK,user,self)
      if user.pbRaiseStatStage(:ATTACK,1,user,showAnim)
        showAnim = false
      end
    end
    if user.pbCanRaiseStatStage?(:DEFENSE,user,self)
      user.pbRaiseStatStage(:DEFENSE,1,user,showAnim)
    end
  end

  def pbEffectAgainstTarget(user,target)
    return if !user.pbHasType?(:GHOST)
    # Ghost effect
    @battle.pbDisplay(_INTL("{1} cut its own HP and laid a curse on {2}!",user.pbThis,target.pbThis(true)))
    target.effects[PBEffects::Curse] = true
    user.pbReduceHP(user.totalhp/2,false)
    user.pbItemHPHealCheck
  end

  def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
    hitNum = 1 if !user.pbHasType?(:GHOST)   # Non-Ghost anim
    super
  end
end



#===============================================================================
# Target's last move used loses 4 PP. (Spite)
#===============================================================================
class PokeBattle_Move_10E < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end

  def pbFailsAgainstTarget?(user,target)
    failed = true
    if target.lastRegularMoveUsed
      target.eachMove do |m|
        next if m.id!=target.lastRegularMoveUsed || m.pp==0 || m.total_pp<=0
        failed = false; break
      end
    end
    if failed
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    target.eachMove do |m|
      next if m.id!=target.lastRegularMoveUsed
      reduction = [4,m.pp].min
      target.pbSetPP(m,m.pp-reduction)
      @battle.pbDisplay(_INTL("It reduced the PP of {1}'s {2} by {3}!",
         target.pbThis(true),m.name,reduction))
      break
    end
  end
end



#===============================================================================
# Target will lose 1/4 of max HP at end of each round, while asleep. (Nightmare)
#===============================================================================
class PokeBattle_Move_10F < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    if !target.asleep? || target.effects[PBEffects::Nightmare]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    target.effects[PBEffects::Nightmare] = true
    @battle.pbDisplay(_INTL("{1} began having a nightmare!",target.pbThis))
  end
end



#===============================================================================
# Removes trapping moves, entry hazards and Leech Seed on user/user's side.
# (Rapid Spin)
#===============================================================================
class PokeBattle_Move_110 < PokeBattle_Move
  def pbEffectAfterAllHits(user,target)
    return if user.fainted? || target.damageState.unaffected
    if user.effects[PBEffects::Trapping]>0
      trapMove = GameData::Move.get(user.effects[PBEffects::TrappingMove]).name
      trapUser = @battle.battlers[user.effects[PBEffects::TrappingUser]]
      @battle.pbDisplay(_INTL("{1} got free of {2}'s {3}!",user.pbThis,trapUser.pbThis(true),trapMove))
      user.effects[PBEffects::Trapping]     = 0
      user.effects[PBEffects::TrappingMove] = nil
      user.effects[PBEffects::TrappingUser] = -1
    end
    if user.effects[PBEffects::LeechSeed]>=0
      user.effects[PBEffects::LeechSeed] = -1
      @battle.pbDisplay(_INTL("{1} shed Leech Seed!",user.pbThis))
    end
    if user.pbOwnSide.effects[PBEffects::StealthRock]
      user.pbOwnSide.effects[PBEffects::StealthRock] = false
      @battle.pbDisplay(_INTL("{1} blew away stealth rocks!",user.pbThis))
    end
    if user.pbOwnSide.effects[PBEffects::Spikes]>0
      user.pbOwnSide.effects[PBEffects::Spikes] = 0
      @battle.pbDisplay(_INTL("{1} blew away spikes!",user.pbThis))
    end
    if user.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
      user.pbOwnSide.effects[PBEffects::ToxicSpikes] = 0
      @battle.pbDisplay(_INTL("{1} blew away poison spikes!",user.pbThis))
    end
    if user.pbOwnSide.effects[PBEffects::StickyWeb]
      user.pbOwnSide.effects[PBEffects::StickyWeb] = false
      @battle.pbDisplay(_INTL("{1} blew away sticky webs!",user.pbThis))
    end
  end
end



#===============================================================================
# Attacks 2 rounds in the future. (Doom Desire, Future Sight)
#===============================================================================
class PokeBattle_Move_111 < PokeBattle_Move
  def cannotRedirect?; return true; end

  def pbDamagingMove?   # Stops damage being dealt in the setting-up turn
    return false if !@battle.futureSight
    return super
  end

  def pbAccuracyCheck(user,target)
    return true if !@battle.futureSight
    return super
  end

  def pbDisplayUseMessage(user)
    super if !@battle.futureSight
  end

  def pbFailsAgainstTarget?(user,target)
    if !@battle.futureSight &&
       @battle.positions[target.index].effects[PBEffects::FutureSightCounter]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    return if @battle.futureSight   # Attack is hitting
    effects = @battle.positions[target.index].effects
    effects[PBEffects::FutureSightCounter]        = 3
    effects[PBEffects::FutureSightMove]           = @id
    effects[PBEffects::FutureSightUserIndex]      = user.index
    effects[PBEffects::FutureSightUserPartyIndex] = user.pokemonIndex
    if @id == :DOOMDESIRE
      @battle.pbDisplay(_INTL("{1} chose Doom Desire as its destiny!",user.pbThis))
    else
      @battle.pbDisplay(_INTL("{1} foresaw an attack!",user.pbThis))
    end
  end

  def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
    hitNum = 1 if !@battle.futureSight   # Charging anim
    super
  end
end



#===============================================================================
# Increases the user's Defense and Special Defense by 1 stage each. Ups the
# user's stockpile by 1 (max. 3). (Stockpile)
#===============================================================================
class PokeBattle_Move_112 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if user.effects[PBEffects::Stockpile]>=3
      @battle.pbDisplay(_INTL("{1} can't stockpile any more!",user.pbThis))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.effects[PBEffects::Stockpile] += 1
    @battle.pbDisplay(_INTL("{1} stockpiled {2}!",
        user.pbThis,user.effects[PBEffects::Stockpile]))
    showAnim = true
    if user.pbCanRaiseStatStage?(:DEFENSE,user,self)
      if user.pbRaiseStatStage(:DEFENSE,1,user,showAnim)
        user.effects[PBEffects::StockpileDef] += 1
        showAnim = false
      end
    end
    if user.pbCanRaiseStatStage?(:SPECIAL_DEFENSE,user,self)
      if user.pbRaiseStatStage(:SPECIAL_DEFENSE,1,user,showAnim)
        user.effects[PBEffects::StockpileSpDef] += 1
      end
    end
  end
end



#===============================================================================
# Power is 100 multiplied by the user's stockpile (X). Resets the stockpile to
# 0. Decreases the user's Defense and Special Defense by X stages each. (Spit Up)
#===============================================================================
class PokeBattle_Move_113 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if user.effects[PBEffects::Stockpile]==0
      @battle.pbDisplay(_INTL("But it failed to spit up a thing!"))
      return true
    end
    return false
  end

  def pbBaseDamage(baseDmg,user,target)
    return 100*user.effects[PBEffects::Stockpile]
  end

  def pbEffectAfterAllHits(user,target)
    return if user.fainted? || user.effects[PBEffects::Stockpile]==0
    return if target.damageState.unaffected
    @battle.pbDisplay(_INTL("{1}'s stockpiled effect wore off!",user.pbThis))
    return if @battle.pbAllFainted?(target.idxOwnSide)
    showAnim = true
    if user.effects[PBEffects::StockpileDef]>0 &&
       user.pbCanLowerStatStage?(:DEFENSE,user,self)
      if user.pbLowerStatStage(:DEFENSE,user.effects[PBEffects::StockpileDef],user,showAnim)
        showAnim = false
      end
    end
    if user.effects[PBEffects::StockpileSpDef]>0 &&
       user.pbCanLowerStatStage?(:SPECIAL_DEFENSE,user,self)
      user.pbLowerStatStage(:SPECIAL_DEFENSE,user.effects[PBEffects::StockpileSpDef],user,showAnim)
    end
    user.effects[PBEffects::Stockpile]      = 0
    user.effects[PBEffects::StockpileDef]   = 0
    user.effects[PBEffects::StockpileSpDef] = 0
  end
end



#===============================================================================
# Heals user depending on the user's stockpile (X). Resets the stockpile to 0.
# Decreases the user's Defense and Special Defense by X stages each. (Swallow)
#===============================================================================
class PokeBattle_Move_114 < PokeBattle_Move
  def healingMove?; return true; end

  def pbMoveFailed?(user,targets)
    if user.effects[PBEffects::Stockpile]==0
      @battle.pbDisplay(_INTL("But it failed to swallow a thing!"))
      return true
    end
    if !user.canHeal? &&
       user.effects[PBEffects::StockpileDef]==0 &&
       user.effects[PBEffects::StockpileSpDef]==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    hpGain = 0
    case [user.effects[PBEffects::Stockpile],1].max
    when 1 then hpGain = user.totalhp/4
    when 2 then hpGain = user.totalhp/2
    when 3 then hpGain = user.totalhp
    end
    if user.pbRecoverHP(hpGain)>0
      @battle.pbDisplay(_INTL("{1}'s HP was restored.",user.pbThis))
    end
    @battle.pbDisplay(_INTL("{1}'s stockpiled effect wore off!",user.pbThis))
    showAnim = true
    if user.effects[PBEffects::StockpileDef]>0 &&
       user.pbCanLowerStatStage?(:DEFENSE,user,self)
      if user.pbLowerStatStage(:DEFENSE,user.effects[PBEffects::StockpileDef],user,showAnim)
        showAnim = false
      end
    end
    if user.effects[PBEffects::StockpileSpDef]>0 &&
       user.pbCanLowerStatStage?(:SPECIAL_DEFENSE,user,self)
      user.pbLowerStatStage(:SPECIAL_DEFENSE,user.effects[PBEffects::StockpileSpDef],user,showAnim)
    end
    user.effects[PBEffects::Stockpile]      = 0
    user.effects[PBEffects::StockpileDef]   = 0
    user.effects[PBEffects::StockpileSpDef] = 0
  end
end



#===============================================================================
# Fails if user was hit by a damaging move this round. (Focus Punch)
#===============================================================================
class PokeBattle_Move_115 < PokeBattle_Move
  def pbDisplayChargeMessage(user)
    user.effects[PBEffects::FocusPunch] = true
    @battle.pbCommonAnimation("FocusPunch",user)
    @battle.pbDisplay(_INTL("{1} is tightening its focus!",user.pbThis))
  end

  def pbDisplayUseMessage(user)
    super if !user.effects[PBEffects::FocusPunch] || user.lastHPLost==0
  end

  def pbMoveFailed?(user,targets)
    if user.effects[PBEffects::FocusPunch] && user.lastHPLost>0
      @battle.pbDisplay(_INTL("{1} lost its focus and couldn't move!",user.pbThis))
      return true
    end
    return false
  end
end



#===============================================================================
# Fails if the target didn't chose a damaging move to use this round, or has
# already moved. (Sucker Punch)
#===============================================================================
class PokeBattle_Move_116 < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    if @battle.choices[target.index][0]!=:UseMove
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    oppMove = @battle.choices[target.index][2]
    if !oppMove ||
       (oppMove.function!="0B0" &&   # Me First
       (target.movedThisRound? || oppMove.statusMove?))
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
end



#===============================================================================
# This round, user becomes the target of attacks that have single targets.
# (Follow Me, Rage Powder)
#===============================================================================
class PokeBattle_Move_117 < PokeBattle_Move
  def pbEffectGeneral(user)
    user.effects[PBEffects::FollowMe] = 1
    user.eachAlly do |b|
      next if b.effects[PBEffects::FollowMe]<user.effects[PBEffects::FollowMe]
      user.effects[PBEffects::FollowMe] = b.effects[PBEffects::FollowMe]+1
    end
    user.effects[PBEffects::RagePowder] = true if @id == :RAGEPOWDER
    @battle.pbDisplay(_INTL("{1} became the center of attention!",user.pbThis))
  end
end



#===============================================================================
# For 5 rounds, increases gravity on the field. Pokémon cannot become airborne.
# (Gravity)
#===============================================================================
class PokeBattle_Move_118 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if @battle.field.effects[PBEffects::Gravity]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.field.effects[PBEffects::Gravity] = 5
    @battle.pbDisplay(_INTL("Gravity intensified!"))
    @battle.eachBattler do |b|
      showMessage = false
      if b.inTwoTurnAttack?("0C9","0CC","0CE")   # Fly/Bounce/Sky Drop
        b.effects[PBEffects::TwoTurnAttack] = nil
        @battle.pbClearChoice(b.index) if !b.movedThisRound?
        showMessage = true
      end
      if b.effects[PBEffects::MagnetRise]>0 ||
         b.effects[PBEffects::Telekinesis]>0 ||
         b.effects[PBEffects::SkyDrop]>=0
        b.effects[PBEffects::MagnetRise]  = 0
        b.effects[PBEffects::Telekinesis] = 0
        b.effects[PBEffects::SkyDrop]     = -1
        showMessage = true
      end
      @battle.pbDisplay(_INTL("{1} couldn't stay airborne because of gravity!",
         b.pbThis)) if showMessage
    end
  end
end



#===============================================================================
# For 5 rounds, user becomes airborne. (Magnet Rise)
#===============================================================================
class PokeBattle_Move_119 < PokeBattle_Move
  def unusableInGravity?; return true; end

  def pbMoveFailed?(user,targets)
    if user.effects[PBEffects::Ingrain] ||
       user.effects[PBEffects::SmackDown] ||
       user.effects[PBEffects::MagnetRise]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.effects[PBEffects::MagnetRise] = 5
    @battle.pbDisplay(_INTL("{1} levitated with electromagnetism!",user.pbThis))
  end
end



#===============================================================================
# For 3 rounds, target becomes airborne and can always be hit. (Telekinesis)
#===============================================================================
class PokeBattle_Move_11A < PokeBattle_Move
  def unusableInGravity?; return true; end

  def pbFailsAgainstTarget?(user,target)
    if target.effects[PBEffects::Ingrain] ||
       target.effects[PBEffects::SmackDown] ||
       target.effects[PBEffects::Telekinesis]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    if target.isSpecies?(:DIGLETT) ||
       target.isSpecies?(:DUGTRIO) ||
       target.isSpecies?(:SANDYGAST) ||
       target.isSpecies?(:PALOSSAND) ||
       (target.isSpecies?(:GENGAR) && target.mega?)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    target.effects[PBEffects::Telekinesis] = 3
    @battle.pbDisplay(_INTL("{1} was hurled into the air!",target.pbThis))
  end
end



#===============================================================================
# Hits airborne semi-invulnerable targets. (Sky Uppercut)
#===============================================================================
class PokeBattle_Move_11B < PokeBattle_Move
  def hitsFlyingTargets?; return true; end
end



#===============================================================================
# Grounds the target while it remains active. Hits some semi-invulnerable
# targets. (Smack Down, Thousand Arrows)
#===============================================================================
class PokeBattle_Move_11C < PokeBattle_Move
  def hitsFlyingTargets?; return true; end

  def pbCalcTypeModSingle(moveType,defType,user,target)
    return Effectiveness::NORMAL_EFFECTIVE_ONE if moveType == :GROUND && defType == :FLYING
    return super
  end

  def pbEffectAfterAllHits(user,target)
    return if target.fainted?
    return if target.damageState.unaffected || target.damageState.substitute
    return if target.inTwoTurnAttack?("0CE") || target.effects[PBEffects::SkyDrop]>=0   # Sky Drop
    return if !target.airborne? && !target.inTwoTurnAttack?("0C9","0CC")   # Fly/Bounce
    target.effects[PBEffects::SmackDown]   = true
    if target.inTwoTurnAttack?("0C9","0CC")   # Fly/Bounce. NOTE: Not Sky Drop.
      target.effects[PBEffects::TwoTurnAttack] = nil
      @battle.pbClearChoice(target.index) if !target.movedThisRound?
    end
    target.effects[PBEffects::MagnetRise]  = 0
    target.effects[PBEffects::Telekinesis] = 0
    @battle.pbDisplay(_INTL("{1} fell straight down!",target.pbThis))
  end
end



#===============================================================================
# Target moves immediately after the user, ignoring priority/speed. (After You)
#===============================================================================
class PokeBattle_Move_11D < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end

  def pbFailsAgainstTarget?(user,target)
    # Target has already moved this round
    return true if pbMoveFailedTargetAlreadyMoved?(target)
    # Target was going to move next anyway (somehow)
    if target.effects[PBEffects::MoveNext]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    # Target didn't choose to use a move this round
    oppMove = @battle.choices[target.index][2]
    if !oppMove
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    target.effects[PBEffects::MoveNext] = true
    target.effects[PBEffects::Quash]    = 0
    @battle.pbDisplay(_INTL("{1} took the kind offer!",target.pbThis))
  end
end



#===============================================================================
# Target moves last this round, ignoring priority/speed. (Quash)
#===============================================================================
class PokeBattle_Move_11E < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    return true if pbMoveFailedTargetAlreadyMoved?(target)
    # Target isn't going to use a move
    oppMove = @battle.choices[target.index][2]
    if !oppMove
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    # Target is already maximally Quashed and will move last anyway
    highestQuash = 0
    @battle.battlers.each do |b|
      next if b.effects[PBEffects::Quash]<=highestQuash
      highestQuash = b.effects[PBEffects::Quash]
    end
    if highestQuash>0 && target.effects[PBEffects::Quash]==highestQuash
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    # Target was already going to move last
    if highestQuash==0 && @battle.pbPriority.last.index==target.index
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    highestQuash = 0
    @battle.battlers.each do |b|
      next if b.effects[PBEffects::Quash]<=highestQuash
      highestQuash = b.effects[PBEffects::Quash]
    end
    target.effects[PBEffects::Quash]    = highestQuash+1
    target.effects[PBEffects::MoveNext] = false
    @battle.pbDisplay(_INTL("{1}'s move was postponed!",target.pbThis))
  end
end



#===============================================================================
# For 5 rounds, for each priority bracket, slow Pokémon move before fast ones.
# (Trick Room)
#===============================================================================
class PokeBattle_Move_11F < PokeBattle_Move
  def pbEffectGeneral(user)
    if @battle.field.effects[PBEffects::TrickRoom]>0
      @battle.field.effects[PBEffects::TrickRoom] = 0
      @battle.pbDisplay(_INTL("{1} reverted the dimensions!",user.pbThis))
    else
      @battle.field.effects[PBEffects::TrickRoom] = 5
      @battle.pbDisplay(_INTL("{1} twisted the dimensions!",user.pbThis))
    end
  end

  def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
    return if @battle.field.effects[PBEffects::TrickRoom]>0   # No animation
    super
  end
end



#===============================================================================
# User switches places with its ally. (Ally Switch)
#===============================================================================
class PokeBattle_Move_120 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    numTargets = 0
    @idxAlly = -1
    idxUserOwner = @battle.pbGetOwnerIndexFromBattlerIndex(user.index)
    user.eachAlly do |b|
      next if @battle.pbGetOwnerIndexFromBattlerIndex(b.index)!=idxUserOwner
      next if !b.near?(user)
      numTargets += 1
      @idxAlly = b.index
    end
    if numTargets!=1
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    idxA = user.index
    idxB = @idxAlly
    if @battle.pbSwapBattlers(idxA,idxB)
      @battle.pbDisplay(_INTL("{1} and {2} switched places!",
         @battle.battlers[idxB].pbThis,@battle.battlers[idxA].pbThis(true)))
    end
  end
end



#===============================================================================
# Target's Attack is used instead of user's Attack for this move's calculations.
# (Foul Play)
#===============================================================================
class PokeBattle_Move_121 < PokeBattle_Move
  def pbGetAttackStats(user,target)
    if specialMove?
      return target.spatk, target.stages[:SPECIAL_ATTACK]+6
    end
    return target.attack, target.stages[:ATTACK]+6
  end
end



#===============================================================================
# Target's Defense is used instead of its Special Defense for this move's
# calculations. (Psyshock, Psystrike, Secret Sword)
#===============================================================================
class PokeBattle_Move_122 < PokeBattle_Move
  def pbGetDefenseStats(user,target)
    return target.defense, target.stages[:DEFENSE]+6
  end
end



#===============================================================================
# Only damages Pokémon that share a type with the user. (Synchronoise)
#===============================================================================
class PokeBattle_Move_123 < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    userTypes = user.pbTypes(true)
    targetTypes = target.pbTypes(true)
    sharesType = false
    userTypes.each do |t|
      next if !targetTypes.include?(t)
      sharesType = true
      break
    end
    if !sharesType
      @battle.pbDisplay(_INTL("{1} is unaffected!",target.pbThis))
      return true
    end
    return false
  end
end



#===============================================================================
# For 5 rounds, swaps all battlers' base Defense with base Special Defense.
# (Wonder Room)
#===============================================================================
class PokeBattle_Move_124 < PokeBattle_Move
  def pbEffectGeneral(user)
    if @battle.field.effects[PBEffects::WonderRoom]>0
      @battle.field.effects[PBEffects::WonderRoom] = 0
      @battle.pbDisplay(_INTL("Wonder Room wore off, and the Defense and Sp. Def stats returned to normal!"))
    else
      @battle.field.effects[PBEffects::WonderRoom] = 5
      @battle.pbDisplay(_INTL("It created a bizarre area in which the Defense and Sp. Def stats are swapped!"))
    end
  end

  def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
    return if @battle.field.effects[PBEffects::WonderRoom]>0   # No animation
    super
  end
end



#===============================================================================
# Fails unless user has already used all other moves it knows. (Last Resort)
#===============================================================================
class PokeBattle_Move_125 < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    hasThisMove = false; hasOtherMoves = false; hasUnusedMoves = false
    user.eachMove do |m|
      hasThisMove    = true if m.id==@id
      hasOtherMoves  = true if m.id!=@id
      hasUnusedMoves = true if m.id!=@id && !user.movesUsed.include?(m.id)
    end
    if !hasThisMove || !hasOtherMoves || hasUnusedMoves
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
end



#===============================================================================
# NOTE: Shadow moves use function codes 126-132 inclusive.
#===============================================================================



#===============================================================================
# Does absolutely nothing. (Hold Hands)
#===============================================================================
class PokeBattle_Move_133 < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end

  def pbMoveFailed?(user,targets)
    hasAlly = false
    user.eachAlly do |_b|
      hasAlly = true
      break
    end
    if !hasAlly
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
end



#===============================================================================
# Does absolutely nothing. Shows a special message. (Celebrate)
#===============================================================================
class PokeBattle_Move_134 < PokeBattle_Move
  def pbEffectGeneral(user)
    if @battle.wildBattle? && user.opposes?
      @battle.pbDisplay(_INTL("Congratulations from {1}!",user.pbThis(true)))
    else
      @battle.pbDisplay(_INTL("Congratulations, {1}!",@battle.pbGetOwnerName(user.index)))
    end
  end
end



#===============================================================================
# Freezes the target. Effectiveness against Water-type is 2x. (Freeze-Dry)
#===============================================================================
class PokeBattle_Move_135 < PokeBattle_FreezeMove
  def pbCalcTypeModSingle(moveType,defType,user,target)
    return Effectiveness::SUPER_EFFECTIVE_ONE if defType == :WATER
    return super
  end
end



#===============================================================================
# Increases the user's Defense by 2 stages. (Diamond Storm)
#===============================================================================
class PokeBattle_Move_136 < PokeBattle_Move_02F
  # NOTE: In Gen 6, this move increased the user's Defense by 1 stage for each
  #       target it hit. This effect changed in Gen 7 and is now identical to
  #       function code 02F.
end



#===============================================================================
# Increases the user's and its ally's Defense and Special Defense by 1 stage
# each, if they have Plus or Minus. (Magnetic Flux)
#===============================================================================
# NOTE: In Gen 5, this move should have a target of UserSide, while in Gen 6+ it
#       should have a target of UserAndAllies. This is because, in Gen 5, this
#       move shouldn't call def pbSuccessCheckAgainstTarget for each Pokémon
#       currently in battle that will be affected by this move (i.e. allies
#       aren't protected by their substitute/ability/etc., but they are in Gen
#       6+). We achieve this by not targeting any battlers in Gen 5, since
#       pbSuccessCheckAgainstTarget is only called for targeted battlers.
class PokeBattle_Move_137 < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end

  def pbMoveFailed?(user,targets)
    @validTargets = []
    @battle.eachSameSideBattler(user) do |b|
      next if !b.hasActiveAbility?([:MINUS,:PLUS])
      next if !b.pbCanRaiseStatStage?(:DEFENSE,user,self) &&
              !b.pbCanRaiseStatStage?(:SPECIAL_DEFENSE,user,self)
      @validTargets.push(b)
    end
    if @validTargets.length==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user,target)
    return false if @validTargets.any? { |b| b.index==target.index }
    return true if !target.hasActiveAbility?([:MINUS,:PLUS])
    @battle.pbDisplay(_INTL("{1}'s stats can't be raised further!",target.pbThis))
    return true
  end


  def pbEffectAgainstTarget(user,target)
    showAnim = true
    if target.pbCanRaiseStatStage?(:DEFENSE,user,self)
      if target.pbRaiseStatStage(:DEFENSE,1,user,showAnim)
        showAnim = false
      end
    end
    if target.pbCanRaiseStatStage?(:SPECIAL_DEFENSE,user,self)
      target.pbRaiseStatStage(:SPECIAL_DEFENSE,1,user,showAnim)
    end
  end

  def pbEffectGeneral(user)
    return if pbTarget(user) != :UserSide
    @validTargets.each { |b| pbEffectAgainstTarget(user,b) }
  end
end



#===============================================================================
# Increases target's Special Defense by 1 stage. (Aromatic Mist)
#===============================================================================
class PokeBattle_Move_138 < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end

  def pbFailsAgainstTarget?(user,target)
    return true if !target.pbCanRaiseStatStage?(:SPECIAL_DEFENSE,user,self,true)
    return false
  end

  def pbEffectAgainstTarget(user,target)
    target.pbRaiseStatStage(:SPECIAL_DEFENSE,1,user)
  end
end



#===============================================================================
# Decreases the target's Attack by 1 stage. Always hits. (Play Nice)
#===============================================================================
class PokeBattle_Move_139 < PokeBattle_TargetStatDownMove
  def ignoresSubstitute?(user); return true; end

  def initialize(battle,move)
    super
    @statDown = [:ATTACK,1]
  end

  def pbAccuracyCheck(user,target); return true; end
end



#===============================================================================
# Decreases the target's Attack and Special Attack by 1 stage each. Always hits.
# (Noble Roar)
#===============================================================================
class PokeBattle_Move_13A < PokeBattle_TargetMultiStatDownMove
  def ignoresSubstitute?(user); return true; end

  def initialize(battle,move)
    super
    @statDown = [:ATTACK,1,:SPECIAL_ATTACK,1]
  end

  def pbAccuracyCheck(user,target); return true; end
end



#===============================================================================
# Decreases the user's Defense by 1 stage. Always hits. Ends target's
# protections immediately. (Hyperspace Fury)
#===============================================================================
class PokeBattle_Move_13B < PokeBattle_StatDownMove
  def ignoresSubstitute?(user); return true; end

  def initialize(battle,move)
    super
    @statDown = [:DEFENSE,1]
  end

  def pbMoveFailed?(user,targets)
    if !user.isSpecies?(:HOOPA)
      @battle.pbDisplay(_INTL("But {1} can't use the move!",user.pbThis(true)))
      return true
    elsif user.form!=1
      @battle.pbDisplay(_INTL("But {1} can't use it the way it is now!",user.pbThis(true)))
      return true
    end
    return false
  end

  def pbAccuracyCheck(user,target); return true; end

  def pbEffectAgainstTarget(user,target)
    target.effects[PBEffects::BanefulBunker]          = false
    target.effects[PBEffects::KingsShield]            = false
    target.effects[PBEffects::Protect]                = false
    target.effects[PBEffects::SpikyShield]            = false
    target.pbOwnSide.effects[PBEffects::CraftyShield] = false
    target.pbOwnSide.effects[PBEffects::MatBlock]     = false
    target.pbOwnSide.effects[PBEffects::QuickGuard]   = false
    target.pbOwnSide.effects[PBEffects::WideGuard]    = false
  end
end



#===============================================================================
# Decreases the target's Special Attack by 1 stage. Always hits. (Confide)
#===============================================================================
class PokeBattle_Move_13C < PokeBattle_TargetStatDownMove
  def ignoresSubstitute?(user); return true; end

  def initialize(battle,move)
    super
    @statDown = [:SPECIAL_ATTACK,1]
  end

  def pbAccuracyCheck(user,target); return true; end
end



#===============================================================================
# Decreases the target's Special Attack by 2 stages. (Eerie Impulse)
#===============================================================================
class PokeBattle_Move_13D < PokeBattle_TargetStatDownMove
  def initialize(battle,move)
    super
    @statDown = [:SPECIAL_ATTACK,2]
  end
end



#===============================================================================
# Increases the Attack and Special Attack of all Grass-type Pokémon in battle by
# 1 stage each. Doesn't affect airborne Pokémon. (Rototiller)
#===============================================================================
class PokeBattle_Move_13E < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    @validTargets = []
    @battle.eachBattler do |b|
      next if !b.pbHasType?(:GRASS)
      next if b.airborne? || b.semiInvulnerable?
      next if !b.pbCanRaiseStatStage?(:ATTACK,user,self) &&
              !b.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self)
      @validTargets.push(b.index)
    end
    if @validTargets.length==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user,target)
    return false if @validTargets.include?(target.index)
    return true if !target.pbHasType?(:GRASS)
    return true if target.airborne? || target.semiInvulnerable?
    @battle.pbDisplay(_INTL("{1}'s stats can't be raised further!",target.pbThis))
    return true
  end

  def pbEffectAgainstTarget(user,target)
    showAnim = true
    if target.pbCanRaiseStatStage?(:ATTACK,user,self)
      if target.pbRaiseStatStage(:ATTACK,1,user,showAnim)
        showAnim = false
      end
    end
    if target.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self)
      target.pbRaiseStatStage(:SPECIAL_ATTACK,1,user,showAnim)
    end
  end
end



#===============================================================================
# Increases the Defense of all Grass-type Pokémon on the field by 1 stage each.
# (Flower Shield)
#===============================================================================
class PokeBattle_Move_13F < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    @validTargets = []
    @battle.eachBattler do |b|
      next if !b.pbHasType?(:GRASS)
      next if b.semiInvulnerable?
      next if !b.pbCanRaiseStatStage?(:DEFENSE,user,self)
      @validTargets.push(b.index)
    end
    if @validTargets.length==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user,target)
    return false if @validTargets.include?(target.index)
    return true if !target.pbHasType?(:GRASS) || target.semiInvulnerable?
    return !target.pbCanRaiseStatStage?(:DEFENSE,user,self,true)
  end

  def pbEffectAgainstTarget(user,target)
    target.pbRaiseStatStage(:DEFENSE,1,user)
  end
end



#===============================================================================
# Decreases the Attack, Special Attack and Speed of all poisoned targets by 1
# stage each. (Venom Drench)
#===============================================================================
class PokeBattle_Move_140 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    @validTargets = []
    targets.each do |b|
      next if !b || b.fainted?
      next if !b.poisoned?
      next if !b.pbCanLowerStatStage?(:ATTACK,user,self) &&
              !b.pbCanLowerStatStage?(:SPECIAL_ATTACK,user,self) &&
              !b.pbCanLowerStatStage?(:SPEED,user,self)
      @validTargets.push(b.index)
    end
    if @validTargets.length==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    return if !@validTargets.include?(target.index)
    showAnim = true
    [:ATTACK,:SPECIAL_ATTACK,:SPEED].each do |s|
      next if !target.pbCanLowerStatStage?(s,user,self)
      if target.pbLowerStatStage(s,1,user,showAnim)
        showAnim = false
      end
    end
  end
end



#===============================================================================
# Reverses all stat changes of the target. (Topsy-Turvy)
#===============================================================================
class PokeBattle_Move_141 < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    failed = true
    GameData::Stat.each_battle do |s|
      next if target.stages[s.id] == 0
      failed = false
      break
    end
    if failed
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    GameData::Stat.each_battle { |s| target.stages[s.id] *= -1 }
    @battle.pbDisplay(_INTL("{1}'s stats were reversed!",target.pbThis))
  end
end



#===============================================================================
# Gives target the Ghost type. (Trick-or-Treat)
#===============================================================================
class PokeBattle_Move_142 < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    if !GameData::Type.exists?(:GHOST) || target.pbHasType?(:GHOST) || !target.canChangeType?
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    target.effects[PBEffects::Type3] = :GHOST
    typeName = GameData::Type.get(:GHOST).name
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",target.pbThis,typeName))
  end
end



#===============================================================================
# Gives target the Grass type. (Forest's Curse)
#===============================================================================
class PokeBattle_Move_143 < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    if !GameData::Type.exists?(:GRASS) || target.pbHasType?(:GRASS) || !target.canChangeType?
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    target.effects[PBEffects::Type3] = :GRASS
    typeName = GameData::Type.get(:GRASS).name
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",target.pbThis,typeName))
  end
end



#===============================================================================
# Type effectiveness is multiplied by the Flying-type's effectiveness against
# the target. Does double damage and has perfect accuracy if the target is
# Minimized. (Flying Press)
#===============================================================================
class PokeBattle_Move_144 < PokeBattle_Move
  def tramplesMinimize?(param=1)
    return true if param==1 && Settings::MECHANICS_GENERATION >= 6   # Perfect accuracy
    return true if param==2   # Double damage
    return super
  end

  def pbCalcTypeModSingle(moveType,defType,user,target)
    ret = super
    if GameData::Type.exists?(:FLYING)
      flyingEff = Effectiveness.calculate_one(:FLYING, defType)
      ret *= flyingEff.to_f / Effectiveness::NORMAL_EFFECTIVE_ONE
    end
    return ret
  end
end



#===============================================================================
# Target's moves become Electric-type for the rest of the round. (Electrify)
#===============================================================================
class PokeBattle_Move_145 < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    if target.effects[PBEffects::Electrify]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return true if pbMoveFailedTargetAlreadyMoved?(target)
    return false
  end

  def pbEffectAgainstTarget(user,target)
    target.effects[PBEffects::Electrify] = true
    @battle.pbDisplay(_INTL("{1}'s moves have been electrified!",target.pbThis))
  end
end



#===============================================================================
# All Normal-type moves become Electric-type for the rest of the round.
# (Ion Deluge, Plasma Fists)
#===============================================================================
class PokeBattle_Move_146 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    return false if damagingMove?
    if @battle.field.effects[PBEffects::IonDeluge]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return true if pbMoveFailedLastInRound?(user)
    return false
  end

  def pbEffectGeneral(user)
    return if @battle.field.effects[PBEffects::IonDeluge]
    @battle.field.effects[PBEffects::IonDeluge] = true
    @battle.pbDisplay(_INTL("A deluge of ions showers the battlefield!"))
  end
end



#===============================================================================
# Always hits. Ends target's protections immediately. (Hyperspace Hole)
#===============================================================================
class PokeBattle_Move_147 < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end
  def pbAccuracyCheck(user,target); return true; end

  def pbEffectAgainstTarget(user,target)
    target.effects[PBEffects::BanefulBunker]          = false
    target.effects[PBEffects::KingsShield]            = false
    target.effects[PBEffects::Protect]                = false
    target.effects[PBEffects::SpikyShield]            = false
    target.pbOwnSide.effects[PBEffects::CraftyShield] = false
    target.pbOwnSide.effects[PBEffects::MatBlock]     = false
    target.pbOwnSide.effects[PBEffects::QuickGuard]   = false
    target.pbOwnSide.effects[PBEffects::WideGuard]    = false
  end
end



#===============================================================================
# Powders the foe. This round, if it uses a Fire move, it loses 1/4 of its max
# HP instead. (Powder)
#===============================================================================
class PokeBattle_Move_148 < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end

  def pbFailsAgainstTarget?(user,target)
    if target.effects[PBEffects::Powder]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    target.effects[PBEffects::Powder] = true
    @battle.pbDisplay(_INTL("{1} is covered in powder!",user.pbThis))
  end
end



#===============================================================================
# This round, the user's side is unaffected by damaging moves. (Mat Block)
#===============================================================================
class PokeBattle_Move_149 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if user.turnCount > 1
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return true if pbMoveFailedLastInRound?(user)
    return false
  end

  def pbEffectGeneral(user)
    user.pbOwnSide.effects[PBEffects::MatBlock] = true
    @battle.pbDisplay(_INTL("{1} intends to flip up a mat and block incoming attacks!",user.pbThis))
  end
end



#===============================================================================
# User's side is protected against status moves this round. (Crafty Shield)
#===============================================================================
class PokeBattle_Move_14A < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if user.pbOwnSide.effects[PBEffects::CraftyShield]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return true if pbMoveFailedLastInRound?(user)
    return false
  end

  def pbEffectGeneral(user)
    user.pbOwnSide.effects[PBEffects::CraftyShield] = true
    @battle.pbDisplay(_INTL("Crafty Shield protected {1}!",user.pbTeam(true)))
  end
end



#===============================================================================
# User is protected against damaging moves this round. Decreases the Attack of
# the user of a stopped contact move by 2 stages. (King's Shield)
#===============================================================================
class PokeBattle_Move_14B < PokeBattle_ProtectMove
  def initialize(battle,move)
    super
    @effect = PBEffects::KingsShield
  end
end



#===============================================================================
# User is protected against moves that target it this round. Damages the user of
# a stopped contact move by 1/8 of its max HP. (Spiky Shield)
#===============================================================================
class PokeBattle_Move_14C < PokeBattle_ProtectMove
  def initialize(battle,move)
    super
    @effect = PBEffects::SpikyShield
  end
end



#===============================================================================
# Two turn attack. Skips first turn, attacks second turn. (Phantom Force)
# Is invulnerable during use. Ends target's protections upon hit.
#===============================================================================
class PokeBattle_Move_14D < PokeBattle_Move_0CD
  # NOTE: This move is identical to function code 0CD (Shadow Force).
end



#===============================================================================
# Two turn attack. Skips first turn, and increases the user's Special Attack,
# Special Defense and Speed by 2 stages each in the second turn. (Geomancy)
#===============================================================================
class PokeBattle_Move_14E < PokeBattle_TwoTurnMove
  def pbMoveFailed?(user,targets)
    return false if user.effects[PBEffects::TwoTurnAttack]   # Charging turn
    if !user.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self) &&
       !user.pbCanRaiseStatStage?(:SPECIAL_DEFENSE,user,self) &&
       !user.pbCanRaiseStatStage?(:SPEED,user,self)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",user.pbThis))
      return true
    end
    return false
  end

  def pbChargingTurnMessage(user,targets)
    @battle.pbDisplay(_INTL("{1} is absorbing power!",user.pbThis))
  end

  def pbEffectGeneral(user)
    return if !@damagingTurn
    showAnim = true
    [:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED].each do |s|
      next if !user.pbCanRaiseStatStage?(s,user,self)
      if user.pbRaiseStatStage(s,2,user,showAnim)
        showAnim = false
      end
    end
  end
end



#===============================================================================
# User gains 3/4 the HP it inflicts as damage. (Draining Kiss, Oblivion Wing)
#===============================================================================
class PokeBattle_Move_14F < PokeBattle_Move
  def healingMove?; return Settings::MECHANICS_GENERATION >= 6; end

  def pbEffectAgainstTarget(user,target)
    return if target.damageState.hpLost<=0
    hpGain = (target.damageState.hpLost*0.75).round
    user.pbRecoverHPFromDrain(hpGain,target)
  end
end



#===============================================================================
# If this move KO's the target, increases the user's Attack by 3 stages.
# (Fell Stinger)
#===============================================================================
class PokeBattle_Move_150 < PokeBattle_Move
  def pbEffectAfterAllHits(user,target)
    return if !target.damageState.fainted
    return if !user.pbCanRaiseStatStage?(:ATTACK,user,self)
    user.pbRaiseStatStage(:ATTACK,3,user)
  end
end



#===============================================================================
# Decreases the target's Attack and Special Attack by 1 stage each. Then, user
# switches out. Ignores trapping moves. (Parting Shot)
#===============================================================================
class PokeBattle_Move_151 < PokeBattle_TargetMultiStatDownMove
  def initialize(battle,move)
    super
    @statDown = [:ATTACK,1,:SPECIAL_ATTACK,1]
  end

  def pbEndOfMoveUsageEffect(user,targets,numHits,switchedBattlers)
    switcher = user
    targets.each do |b|
      next if switchedBattlers.include?(b.index)
      switcher = b if b.effects[PBEffects::MagicCoat] || b.effects[PBEffects::MagicBounce]
    end
    return if switcher.fainted? || numHits==0
    return if !@battle.pbCanChooseNonActive?(switcher.index)
    @battle.pbDisplay(_INTL("{1} went back to {2}!",switcher.pbThis,
       @battle.pbGetOwnerName(switcher.index)))
    @battle.pbPursuit(switcher.index)
    return if switcher.fainted?
    newPkmn = @battle.pbGetReplacementPokemonIndex(switcher.index)   # Owner chooses
    return if newPkmn<0
    @battle.pbRecallAndReplace(switcher.index,newPkmn)
    @battle.pbClearChoice(switcher.index)   # Replacement Pokémon does nothing this round
    @battle.moldBreaker = false if switcher.index==user.index
    switchedBattlers.push(switcher.index)
    switcher.pbEffectsOnSwitchIn(true)
  end
end



#===============================================================================
# No Pokémon can switch out or flee until the end of the next round, as long as
# the user remains active. (Fairy Lock)
#===============================================================================
class PokeBattle_Move_152 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if @battle.field.effects[PBEffects::FairyLock]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.field.effects[PBEffects::FairyLock] = 2
    @battle.pbDisplay(_INTL("No one will be able to run away during the next turn!"))
  end
end



#===============================================================================
# Entry hazard. Lays stealth rocks on the opposing side. (Sticky Web)
#===============================================================================
class PokeBattle_Move_153 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
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
# For 5 rounds, creates an electric terrain which boosts Electric-type moves and
# prevents Pokémon from falling asleep. Affects non-airborne Pokémon only.
# (Electric Terrain)
#===============================================================================
class PokeBattle_Move_154 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
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
class PokeBattle_Move_155 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
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
class PokeBattle_Move_156 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
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
# Doubles the prize money the player gets after winning the battle. (Happy Hour)
#===============================================================================
class PokeBattle_Move_157 < PokeBattle_Move
  def pbEffectGeneral(user)
    @battle.field.effects[PBEffects::HappyHour] = true if !user.opposes?
    @battle.pbDisplay(_INTL("Everyone is caught up in the happy atmosphere!"))
  end
end



#===============================================================================
# Fails unless user has consumed a berry at some point. (Belch)
#===============================================================================
class PokeBattle_Move_158 < PokeBattle_Move
  def pbCanChooseMove?(user,commandPhase,showMessages)
    if !user.belched?
      if showMessages
        msg = _INTL("{1} hasn't eaten any held berry, so it can't possibly belch!",user.pbThis)
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false
    end
    return true
  end

  def pbMoveFailed?(user,targets)
    if !user.belched?
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
end



#===============================================================================
# Poisons the target and decreases its Speed by 1 stage. (Toxic Thread)
#===============================================================================
class PokeBattle_Move_159 < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    if !target.pbCanPoison?(user,false,self) &&
       !target.pbCanLowerStatStage?(:SPEED,user,self)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    target.pbPoison(user) if target.pbCanPoison?(user,false,self)
    if target.pbCanLowerStatStage?(:SPEED,user,self)
      target.pbLowerStatStage(:SPEED,1,user)
    end
  end
end



#===============================================================================
# Cures the target's burn. (Sparkling Aria)
#===============================================================================
class PokeBattle_Move_15A < PokeBattle_Move
  def pbAdditionalEffect(user,target)
    return if target.fainted? || target.damageState.substitute
    return if target.status != :BURN
    target.pbCureStatus
  end
end



#===============================================================================
# Cures the target's permanent status problems. Heals user by 1/2 of its max HP.
# (Purify)
#===============================================================================
class PokeBattle_Move_15B < PokeBattle_HealingMove
  def pbFailsAgainstTarget?(user,target)
    if target.status == :NONE
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbHealAmount(user)
    return (user.totalhp/2.0).round
  end

  def pbEffectAgainstTarget(user,target)
    target.pbCureStatus
    super
  end
end



#===============================================================================
# Increases the user's and its ally's Attack and Special Attack by 1 stage each,
# if they have Plus or Minus. (Gear Up)
#===============================================================================
# NOTE: In Gen 5, this move should have a target of UserSide, while in Gen 6+ it
#       should have a target of UserAndAllies. This is because, in Gen 5, this
#       move shouldn't call def pbSuccessCheckAgainstTarget for each Pokémon
#       currently in battle that will be affected by this move (i.e. allies
#       aren't protected by their substitute/ability/etc., but they are in Gen
#       6+). We achieve this by not targeting any battlers in Gen 5, since
#       pbSuccessCheckAgainstTarget is only called for targeted battlers.
class PokeBattle_Move_15C < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end

  def pbMoveFailed?(user,targets)
    @validTargets = []
    @battle.eachSameSideBattler(user) do |b|
      next if !b.hasActiveAbility?([:MINUS,:PLUS])
      next if !b.pbCanRaiseStatStage?(:ATTACK,user,self) &&
              !b.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self)
      @validTargets.push(b)
    end
    if @validTargets.length==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user,target)
    return false if @validTargets.any? { |b| b.index==target.index }
    return true if !target.hasActiveAbility?([:MINUS,:PLUS])
    @battle.pbDisplay(_INTL("{1}'s stats can't be raised further!",target.pbThis))
    return true
  end

  def pbEffectAgainstTarget(user,target)
    showAnim = true
    if target.pbCanRaiseStatStage?(:ATTACK,user,self)
      if target.pbRaiseStatStage(:ATTACK,1,user,showAnim)
        showAnim = false
      end
    end
    if target.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self)
      target.pbRaiseStatStage(:SPECIAL_ATTACK,1,user,showAnim)
    end
  end

  def pbEffectGeneral(user)
    return if pbTarget(user) != :UserSide
    @validTargets.each { |b| pbEffectAgainstTarget(user,b) }
  end
end



#===============================================================================
# User gains stat stages equal to each of the target's positive stat stages,
# and target's positive stat stages become 0, before damage calculation.
# (Spectral Thief)
#===============================================================================
class PokeBattle_Move_15D < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end

  def pbCalcDamage(user,target,numTargets=1)
    if target.hasRaisedStatStages?
      pbShowAnimation(@id,user,target,1)   # Stat stage-draining animation
      @battle.pbDisplay(_INTL("{1} stole the target's boosted stats!",user.pbThis))
      showAnim = true
      GameData::Stat.each_battle do |s|
        next if target.stages[s.id] <= 0
        if user.pbCanRaiseStatStage?(s.id,user,self)
          if user.pbRaiseStatStage(s.id,target.stages[s.id],user,showAnim)
            showAnim = false
          end
        end
        target.stages[s.id] = 0
      end
    end
    super
  end
end



#===============================================================================
# Until the end of the next round, the user's moves will always be critical hits.
# (Laser Focus)
#===============================================================================
class PokeBattle_Move_15E < PokeBattle_Move
  def pbEffectGeneral(user)
    user.effects[PBEffects::LaserFocus] = 2
    @battle.pbDisplay(_INTL("{1} concentrated intensely!",user.pbThis))
  end
end



#===============================================================================
# Decreases the user's Defense by 1 stage. (Clanging Scales)
#===============================================================================
class PokeBattle_Move_15F < PokeBattle_StatDownMove
  def initialize(battle,move)
    super
    @statDown = [:DEFENSE,1]
  end
end



#===============================================================================
# Decreases the target's Attack by 1 stage. Heals user by an amount equal to the
# target's Attack stat (after applying stat stages, before this move decreases
# it). (Strength Sap)
#===============================================================================
class PokeBattle_Move_160 < PokeBattle_Move
  def healingMove?; return true; end

  def pbFailsAgainstTarget?(user,target)
    # NOTE: The official games appear to just check whether the target's Attack
    #       stat stage is -6 and fail if so, but I've added the "fail if target
    #       has Contrary and is at +6" check too for symmetry. This move still
    #       works even if the stat stage cannot be changed due to an ability or
    #       other effect.
    if !@battle.moldBreaker && target.hasActiveAbility?(:CONTRARY) &&
       target.statStageAtMax?(:ATTACK)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    elsif target.statStageAtMin?(:ATTACK)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    # Calculate target's effective attack value
    stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
    stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
    atk      = target.attack
    atkStage = target.stages[:ATTACK]+6
    healAmt = (atk.to_f*stageMul[atkStage]/stageDiv[atkStage]).floor
    # Reduce target's Attack stat
    if target.pbCanLowerStatStage?(:ATTACK,user,self)
      target.pbLowerStatStage(:ATTACK,1,user)
    end
    # Heal user
    if target.hasActiveAbility?(:LIQUIDOOZE)
      @battle.pbShowAbilitySplash(target)
      user.pbReduceHP(healAmt)
      @battle.pbDisplay(_INTL("{1} sucked up the liquid ooze!",user.pbThis))
      @battle.pbHideAbilitySplash(target)
      user.pbItemHPHealCheck
    elsif user.canHeal?
      healAmt = (healAmt*1.3).floor if user.hasActiveItem?(:BIGROOT)
      user.pbRecoverHP(healAmt)
      @battle.pbDisplay(_INTL("{1}'s HP was restored.",user.pbThis))
    end
  end
end



#===============================================================================
# User and target swap their Speed stats (not their stat stages). (Speed Swap)
#===============================================================================
class PokeBattle_Move_161 < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end

  def pbEffectAgainstTarget(user,target)
    user.speed, target.speed = target.speed, user.speed
    @battle.pbDisplay(_INTL("{1} switched Speed with its target!",user.pbThis))
  end
end



#===============================================================================
# User loses their Fire type. Fails if user is not Fire-type. (Burn Up)
#===============================================================================
class PokeBattle_Move_162 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if !user.pbHasType?(:FIRE)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAfterAllHits(user,target)
    if !user.effects[PBEffects::BurnUp]
      user.effects[PBEffects::BurnUp] = true
      @battle.pbDisplay(_INTL("{1} burned itself out!",user.pbThis))
    end
  end
end



#===============================================================================
# Ignores all abilities that alter this move's success or damage.
# (Moongeist Beam, Sunsteel Strike)
#===============================================================================
class PokeBattle_Move_163 < PokeBattle_Move
  def pbChangeUsageCounters(user,specialUsage)
    super
    @battle.moldBreaker = true if !specialUsage
  end
end



#===============================================================================
# Ignores all abilities that alter this move's success or damage. This move is
# physical if user's Attack is higher than its Special Attack (after applying
# stat stages), and special otherwise. (Photon Geyser)
#===============================================================================
class PokeBattle_Move_164 < PokeBattle_Move_163
  def initialize(battle,move)
    super
    @calcCategory = 1
  end

  def physicalMove?(thisType=nil); return (@calcCategory==0); end
  def specialMove?(thisType=nil);  return (@calcCategory==1); end

  def pbOnStartUse(user,targets)
    # Calculate user's effective attacking value
    stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
    stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
    atk        = user.attack
    atkStage   = user.stages[:ATTACK]+6
    realAtk    = (atk.to_f*stageMul[atkStage]/stageDiv[atkStage]).floor
    spAtk      = user.spatk
    spAtkStage = user.stages[:SPECIAL_ATTACK]+6
    realSpAtk  = (spAtk.to_f*stageMul[spAtkStage]/stageDiv[spAtkStage]).floor
    # Determine move's category
    @calcCategory = (realAtk>realSpAtk) ? 0 : 1
  end
end



#===============================================================================
# Negates the target's ability while it remains on the field, if it has already
# performed its action this round. (Core Enforcer)
#===============================================================================
class PokeBattle_Move_165 < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    return if target.damageState.substitute || target.effects[PBEffects::GastroAcid]
    return if target.unstoppableAbility?
    return if @battle.choices[target.index][0]!=:UseItem &&
              !((@battle.choices[target.index][0]==:UseMove ||
              @battle.choices[target.index][0]==:Shift) && target.movedThisRound?)
    target.effects[PBEffects::GastroAcid] = true
    target.effects[PBEffects::Truant]     = false
    @battle.pbDisplay(_INTL("{1}'s Ability was suppressed!",target.pbThis))
    target.pbOnAbilityChanged(target.ability)
  end
end



#===============================================================================
# Power is doubled if the user's last move failed. (Stomping Tantrum)
#===============================================================================
class PokeBattle_Move_166 < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    baseDmg *= 2 if user.lastRoundMoveFailed
    return baseDmg
  end
end



#===============================================================================
# For 5 rounds, lowers power of attacks against the user's side. Fails if
# weather is not hail. (Aurora Veil)
#===============================================================================
class PokeBattle_Move_167 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if @battle.pbWeather != :Hail
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    if user.pbOwnSide.effects[PBEffects::AuroraVeil]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.pbOwnSide.effects[PBEffects::AuroraVeil] = 5
    user.pbOwnSide.effects[PBEffects::AuroraVeil] = 8 if user.hasActiveItem?(:LIGHTCLAY)
    @battle.pbDisplay(_INTL("{1} made {2} stronger against physical and special moves!",
       @name,user.pbTeam(true)))
  end
end



#===============================================================================
# User is protected against moves with the "B" flag this round. If a Pokémon
# makes contact with the user while this effect applies, that Pokémon is
# poisoned. (Baneful Bunker)
#===============================================================================
class PokeBattle_Move_168 < PokeBattle_ProtectMove
  def initialize(battle,move)
    super
    @effect = PBEffects::BanefulBunker
  end
end



#===============================================================================
# This move's type is the same as the user's first type. (Revelation Dance)
#===============================================================================
class PokeBattle_Move_169 < PokeBattle_Move
  def pbBaseType(user)
    userTypes = user.pbTypes(true)
    return userTypes[0]
  end
end



#===============================================================================
# This round, target becomes the target of attacks that have single targets.
# (Spotlight)
#===============================================================================
class PokeBattle_Move_16A < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    target.effects[PBEffects::Spotlight] = 1
    target.eachAlly do |b|
      next if b.effects[PBEffects::Spotlight]<target.effects[PBEffects::Spotlight]
      target.effects[PBEffects::Spotlight] = b.effects[PBEffects::Spotlight]+1
    end
    @battle.pbDisplay(_INTL("{1} became the center of attention!",target.pbThis))
  end
end



#===============================================================================
# The target uses its most recent move again. (Instruct)
#===============================================================================
class PokeBattle_Move_16B < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end

  def initialize(battle,move)
    super
    @moveBlacklist = [
       "0D4",   # Bide
       "14B",   # King's Shield
       "16B",   # Instruct (this move)
       # Struggle
       "002",   # Struggle
       # Moves that affect the moveset
       "05C",   # Mimic
       "05D",   # Sketch
       "069",   # Transform
       # Moves that call other moves
       "0AE",   # Mirror Move
       "0AF",   # Copycat
       "0B0",   # Me First
       "0B3",   # Nature Power
       "0B4",   # Sleep Talk
       "0B5",   # Assist
       "0B6",   # Metronome
       # Moves that require a recharge turn
       "0C2",   # Hyper Beam
       # Two-turn attacks
       "0C3",   # Razor Wind
       "0C4",   # Solar Beam, Solar Blade
       "0C5",   # Freeze Shock
       "0C6",   # Ice Burn
       "0C7",   # Sky Attack
       "0C8",   # Skull Bash
       "0C9",   # Fly
       "0CA",   # Dig
       "0CB",   # Dive
       "0CC",   # Bounce
       "0CD",   # Shadow Force
       "0CE",   # Sky Drop
       "12E",   # Shadow Half
       "14D",   # Phantom Force
       "14E",   # Geomancy
       # Moves that start focussing at the start of the round
       "115",   # Focus Punch
       "171",   # Shell Trap
       "172"    # Beak Blast
    ]
  end

  def pbFailsAgainstTarget?(user,target)
    if !target.lastRegularMoveUsed || !target.pbHasMove?(target.lastRegularMoveUsed)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    if target.usingMultiTurnAttack?
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    targetMove = @battle.choices[target.index][2]
    if targetMove && (targetMove.function=="115" ||   # Focus Punch
                      targetMove.function=="171" ||   # Shell Trap
                      targetMove.function=="172")     # Beak Blast
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    if @moveBlacklist.include?(GameData::Move.get(target.lastRegularMoveUsed).function_code)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    idxMove = -1
    target.eachMoveWithIndex do |m,i|
      idxMove = i if m.id==target.lastRegularMoveUsed
    end
    if target.moves[idxMove].pp==0 && target.moves[idxMove].total_pp>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    target.effects[PBEffects::Instruct] = true
  end
end



#===============================================================================
# Target cannot use sound-based moves for 2 more rounds. (Throat Chop)
#===============================================================================
class PokeBattle_Move_16C < PokeBattle_Move
  def pbAdditionalEffect(user,target)
    return if target.fainted? || target.damageState.substitute
    @battle.pbDisplay(_INTL("The effects of {1} prevent {2} from using certain moves!",
       @name,target.pbThis(true))) if target.effects[PBEffects::ThroatChop]==0
    target.effects[PBEffects::ThroatChop] = 3
  end
end



#===============================================================================
# Heals user by 1/2 of its max HP, or 2/3 of its max HP in a sandstorm. (Shore Up)
#===============================================================================
class PokeBattle_Move_16D < PokeBattle_HealingMove
  def pbHealAmount(user)
    return (user.totalhp*2/3.0).round if @battle.pbWeather == :Sandstorm
    return (user.totalhp/2.0).round
  end
end



#===============================================================================
# Heals target by 1/2 of its max HP, or 2/3 of its max HP in Grassy Terrain.
# (Floral Healing)
#===============================================================================
class PokeBattle_Move_16E < PokeBattle_Move
  def healingMove?; return true; end

  def pbFailsAgainstTarget?(user,target)
    if target.hp==target.totalhp
      @battle.pbDisplay(_INTL("{1}'s HP is full!",target.pbThis))
      return true
    elsif !target.canHeal?
      @battle.pbDisplay(_INTL("{1} is unaffected!",target.pbThis))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    hpGain = (target.totalhp/2.0).round
    hpGain = (target.totalhp*2/3.0).round if @battle.field.terrain == :Grassy
    target.pbRecoverHP(hpGain)
    @battle.pbDisplay(_INTL("{1}'s HP was restored.",target.pbThis))
  end
end



#===============================================================================
# Damages target if target is a foe, or heals target by 1/2 of its max HP if
# target is an ally. (Pollen Puff)
#===============================================================================
class PokeBattle_Move_16F < PokeBattle_Move
  def pbTarget(user)
    return GameData::Target.get(:NearFoe) if user.effects[PBEffects::HealBlock]>0
    return super
  end

  def pbOnStartUse(user,targets)
    @healing = false
    @healing = !user.opposes?(targets[0]) if targets.length>0
  end

  def pbFailsAgainstTarget?(user,target)
    return false if !@healing
    if target.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(user)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    if !target.canHeal?
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbDamagingMove?
    return false if @healing
    return super
  end

  def pbEffectAgainstTarget(user,target)
    return if !@healing
    target.pbRecoverHP(target.totalhp/2)
    @battle.pbDisplay(_INTL("{1}'s HP was restored.",target.pbThis))
  end

  def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
    hitNum = 1 if @healing   # Healing anim
    super
  end
end



#===============================================================================
# Damages user by 1/2 of its max HP, even if this move misses. (Mind Blown)
#===============================================================================
class PokeBattle_Move_170 < PokeBattle_Move
  def worksWithNoTargets?; return true; end

  def pbMoveFailed?(user,targets)
    if !@battle.moldBreaker
      bearer = @battle.pbCheckGlobalAbility(:DAMP)
      if bearer!=nil
        @battle.pbShowAbilitySplash(bearer)
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("{1} cannot use {2}!",user.pbThis,@name))
        else
          @battle.pbDisplay(_INTL("{1} cannot use {2} because of {3}'s {4}!",
             user.pbThis,@name,bearer.pbThis(true),bearer.abilityName))
        end
        @battle.pbHideAbilitySplash(bearer)
        return true
      end
    end
    return false
  end

  def pbSelfKO(user)
    return if !user.takesIndirectDamage?
    user.pbReduceHP((user.totalhp/2.0).round,false)
    user.pbItemHPHealCheck
  end
end



#===============================================================================
# Fails if user has not been hit by an opponent's physical move this round.
# (Shell Trap)
#===============================================================================
class PokeBattle_Move_171 < PokeBattle_Move
  def pbDisplayChargeMessage(user)
    user.effects[PBEffects::ShellTrap] = true
    @battle.pbCommonAnimation("ShellTrap",user)
    @battle.pbDisplay(_INTL("{1} set a shell trap!",user.pbThis))
  end

  def pbDisplayUseMessage(user)
    super if user.tookPhysicalHit
  end

  def pbMoveFailed?(user,targets)
    if !user.effects[PBEffects::ShellTrap]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    if !user.tookPhysicalHit
      @battle.pbDisplay(_INTL("{1}'s shell trap didn't work!",user.pbThis))
      return true
    end
    return false
  end
end



#===============================================================================
# If a Pokémon makes contact with the user before it uses this move, the
# attacker is burned. (Beak Blast)
#===============================================================================
class PokeBattle_Move_172 < PokeBattle_Move
  def pbDisplayChargeMessage(user)
    user.effects[PBEffects::BeakBlast] = true
    @battle.pbCommonAnimation("BeakBlast",user)
    @battle.pbDisplay(_INTL("{1} started heating up its beak!",user.pbThis))
  end
end



#===============================================================================
# For 5 rounds, creates a psychic terrain which boosts Psychic-type moves and
# prevents Pokémon from being hit by >0 priority moves. Affects non-airborne
# Pokémon only. (Psychic Terrain)
#===============================================================================
class PokeBattle_Move_173 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
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
# Fails if this isn't the user's first turn. (First Impression)
#===============================================================================
class PokeBattle_Move_174 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if user.turnCount > 1
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
end



#===============================================================================
# Hits twice. Causes the target to flinch. Does double damage and has perfect
# accuracy if the target is Minimized. (Double Iron Bash)
#===============================================================================
class PokeBattle_Move_175 < PokeBattle_FlinchMove
  def multiHitMove?;              return true; end
  def pbNumHits(user,targets);    return 2;    end
  def tramplesMinimize?(param=1); return true; end
end



# NOTE: If you're inventing new move effects, use function code 176 and onwards.
#       Actually, you might as well use high numbers like 500+ (up to FFFF),
#       just to make sure later additions to Essentials don't clash with your
#       new effects.
