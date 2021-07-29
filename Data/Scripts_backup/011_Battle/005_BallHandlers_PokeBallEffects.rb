$BallTypes = {
  0  => :POKEBALL,
  1  => :GREATBALL,
  2  => :SAFARIBALL,
  3  => :ULTRABALL,
  4  => :MASTERBALL,
  5  => :NETBALL,
  6  => :DIVEBALL,
  7  => :NESTBALL,
  8  => :REPEATBALL,
  9  => :TIMERBALL,
  10 => :LUXURYBALL,
  11 => :PREMIERBALL,
  12 => :DUSKBALL,
  13 => :HEALBALL,
  14 => :QUICKBALL,
  15 => :CHERISHBALL,
  16 => :FASTBALL,
  17 => :LEVELBALL,
  18 => :LUREBALL,
  19 => :HEAVYBALL,
  20 => :LOVEBALL,
  21 => :FRIENDBALL,
  22 => :MOONBALL,
  23 => :SPORTBALL,
  24 => :DREAMBALL,
  25 => :BEASTBALL
}

def pbBallTypeToItem(ball_type)
  ret = GameData::Item.try_get($BallTypes[ball_type])
  return ret if ret
  ret = GameData::Item.try_get($BallTypes[0])
  return ret if ret
  return GameData::Item.get(:POKEBALL)
end

def pbGetBallType(ball)
  ball = GameData::Item.try_get(ball)
  $BallTypes.keys.each do |key|
    return key if ball == $BallTypes[key]
  end
  return 0
end



#===============================================================================
#
#===============================================================================
module BallHandlers
  IsUnconditional = ItemHandlerHash.new
  ModifyCatchRate = ItemHandlerHash.new
  OnCatch         = ItemHandlerHash.new
  OnFailCatch     = ItemHandlerHash.new

  def self.isUnconditional?(ball,battle,battler)
    ret = IsUnconditional.trigger(ball,battle,battler)
    return (ret!=nil) ? ret : false
  end

  def self.modifyCatchRate(ball,catchRate,battle,battler,ultraBeast)
    ret = ModifyCatchRate.trigger(ball,catchRate,battle,battler,ultraBeast)
    return (ret!=nil) ? ret : catchRate
  end

  def self.onCatch(ball,battle,pkmn)
    OnCatch.trigger(ball,battle,pkmn)
  end

  def self.onFailCatch(ball,battle,battler)
    OnFailCatch.trigger(ball,battle,battler)
  end
end



#===============================================================================
# IsUnconditional
#===============================================================================
BallHandlers::IsUnconditional.add(:MASTERBALL,proc { |ball,battle,battler|
  next true
})

#===============================================================================
# ModifyCatchRate
# NOTE: This code is not called if the battler is an Ultra Beast (except if the
#       Ball is a Beast Ball). In this case, all Balls' catch rates are set
#       elsewhere to 0.1x.
#===============================================================================
BallHandlers::ModifyCatchRate.add(:GREATBALL,proc { |ball,catchRate,battle,battler,ultraBeast|
  next catchRate*1.5
})

BallHandlers::ModifyCatchRate.add(:ULTRABALL,proc { |ball,catchRate,battle,battler,ultraBeast|
  next catchRate*2
})

BallHandlers::ModifyCatchRate.add(:SAFARIBALL,proc { |ball,catchRate,battle,battler,ultraBeast|
  next catchRate*1.5
})

BallHandlers::ModifyCatchRate.add(:NETBALL,proc { |ball,catchRate,battle,battler,ultraBeast|
  multiplier = (Settings::NEW_POKE_BALL_CATCH_RATES) ? 3.5 : 3
  catchRate *= multiplier if battler.pbHasType?(:BUG) || battler.pbHasType?(:WATER)
  next catchRate
})

BallHandlers::ModifyCatchRate.add(:DIVEBALL,proc { |ball,catchRate,battle,battler,ultraBeast|
  catchRate *= 3.5 if battle.environment == :Underwater
  next catchRate
})

BallHandlers::ModifyCatchRate.add(:NESTBALL,proc { |ball,catchRate,battle,battler,ultraBeast|
  if battler.level <= 30
    catchRate *= [(41 - battler.level) / 10.0, 1].max
  end
  next catchRate
})

BallHandlers::ModifyCatchRate.add(:REPEATBALL,proc { |ball,catchRate,battle,battler,ultraBeast|
  multiplier = (Settings::NEW_POKE_BALL_CATCH_RATES) ? 3.5 : 3
  catchRate *= multiplier if battle.pbPlayer.owned?(battler.species)
  next catchRate
})

BallHandlers::ModifyCatchRate.add(:TIMERBALL,proc { |ball,catchRate,battle,battler,ultraBeast|
  multiplier = [1+(0.3*battle.turnCount),4].min
  catchRate *= multiplier
  next catchRate
})

BallHandlers::ModifyCatchRate.add(:DUSKBALL,proc { |ball,catchRate,battle,battler,ultraBeast|
  multiplier = (Settings::NEW_POKE_BALL_CATCH_RATES) ? 3 : 3.5
  catchRate *= multiplier if battle.time==2
  next catchRate
})

BallHandlers::ModifyCatchRate.add(:QUICKBALL,proc { |ball,catchRate,battle,battler,ultraBeast|
  catchRate *= 5 if battle.turnCount==0
  next catchRate
})

BallHandlers::ModifyCatchRate.add(:FASTBALL,proc { |ball,catchRate,battle,battler,ultraBeast|
  baseStats = battler.pokemon.baseStats
  baseSpeed = baseStats[:SPEED]
  catchRate *= 4 if baseSpeed >= 100
  next [catchRate, 255].min
})

BallHandlers::ModifyCatchRate.add(:LEVELBALL,proc { |ball,catchRate,battle,battler,ultraBeast|
  maxlevel = 0
  battle.eachSameSideBattler do |b|
    maxlevel = b.level if b.level>maxlevel
  end
  if maxlevel>=battler.level*4;    catchRate *= 8
  elsif maxlevel>=battler.level*2; catchRate *= 4
  elsif maxlevel>battler.level;    catchRate *= 2
  end
  next [catchRate,255].min
})

BallHandlers::ModifyCatchRate.add(:LUREBALL,proc { |ball,catchRate,battle,battler,ultraBeast|
  multiplier = (Settings::NEW_POKE_BALL_CATCH_RATES) ? 5 : 3
  catchRate *= multiplier if GameData::EncounterType.get($PokemonTemp.encounterType).type == :fishing
  next [catchRate,255].min
})

BallHandlers::ModifyCatchRate.add(:HEAVYBALL,proc { |ball,catchRate,battle,battler,ultraBeast|
  next 0 if catchRate==0
  weight = battler.pbWeight
  if Settings::NEW_POKE_BALL_CATCH_RATES
    if weight>=3000;    catchRate += 30
    elsif weight>=2000; catchRate += 20
    elsif weight<1000;  catchRate -= 20
    end
  else
    if weight>=4096;    catchRate += 40
    elsif weight>=3072; catchRate += 30
    elsif weight>=2048; catchRate += 20
    else;               catchRate -= 20
    end
  end
  catchRate = [catchRate,1].max
  next [catchRate,255].min
})

BallHandlers::ModifyCatchRate.add(:LOVEBALL,proc { |ball,catchRate,battle,battler,ultraBeast|
  battle.eachSameSideBattler do |b|
    next if b.species!=battler.species
    next if b.gender==battler.gender || b.gender==2 || battler.gender==2
    catchRate *= 8
    break
  end
  next [catchRate,255].min
})

BallHandlers::ModifyCatchRate.add(:MOONBALL,proc { |ball,catchRate,battle,battler,ultraBeast|
  # NOTE: Moon Ball cares about whether any species in the target's evolutionary
  #       family can evolve with the Moon Stone, not whether the target itself
  #       can immediately evolve with the Moon Stone.
  moon_stone = GameData::Item.try_get(:MOONSTONE)
  if moon_stone && battler.pokemon.species_data.family_item_evolutions_use_item?(moon_stone.id)
    catchRate *= 4
  end
  next [catchRate, 255].min
})

BallHandlers::ModifyCatchRate.add(:SPORTBALL,proc { |ball,catchRate,battle,battler,ultraBeast|
  next catchRate*1.5
})

BallHandlers::ModifyCatchRate.add(:DREAMBALL,proc { |ball,catchRate,battle,battler,ultraBeast|
  catchRate *= 4 if battler.status == :SLEEP
  next catchRate
})

BallHandlers::ModifyCatchRate.add(:BEASTBALL,proc { |ball,catchRate,battle,battler,ultraBeast|
  if ultraBeast
    catchRate *= 5
  else
    catchRate /= 10
  end
  next catchRate
})

#===============================================================================
# OnCatch
#===============================================================================
BallHandlers::OnCatch.add(:HEALBALL,proc { |ball,battle,pkmn|
  pkmn.heal
})

BallHandlers::OnCatch.add(:FRIENDBALL,proc { |ball,battle,pkmn|
  pkmn.happiness = 200
})
