module PBTypeEffectiveness
  INEFFECTIVE          = 0
  NOT_EFFECTIVE_ONE    = 1
  NORMAL_EFFECTIVE_ONE = 2
  SUPER_EFFECTIVE_ONE  = 4
  NORMAL_EFFECTIVE     = NORMAL_EFFECTIVE_ONE ** 3

  def self.ineffective?(value)
    return value == INEFFECTIVE
  end

  def self.notVeryEffective?(value)
    return value > INEFFECTIVE && value < NORMAL_EFFECTIVE
  end

  def self.resistant?(value)
    return value < NORMAL_EFFECTIVE
  end

  def self.normalEffective?(value)
    return value == NORMAL_EFFECTIVE
  end

  def self.superEffective?(value)
    return value > NORMAL_EFFECTIVE
  end
end



module PBTypes
  def self.regularTypesCount
    ret = 0
    GameData::Type.each { |t| ret += 1 if !t.pseudo_type && t.id != :SHADOW }
    return ret
  end

  def self.isPhysicalType?(type); return GameData::Type.get(type).physical?;   end
  def self.isSpecialType?(type);  return GameData::Type.get(type).special?;    end
  def self.isPseudoType?(type);   return GameData::Type.get(type).pseudo_type; end

  def self.getEffectiveness(attack_type, target_type)
    return GameData::Type.get(target_type).effectiveness(attack_type)
  end

  def self.getCombinedEffectiveness(attack_type, target_type1, target_type2 = nil, target_type3 = nil)
    mod1 = self.getEffectiveness(attack_type, target_type1)
    mod2 = PBTypeEffectiveness::NORMAL_EFFECTIVE_ONE
    mod3 = PBTypeEffectiveness::NORMAL_EFFECTIVE_ONE
    if target_type2 && target_type1 != target_type2
      mod2 = self.getEffectiveness(attack_type, target_type2)
    end
    if target_type3 && target_type1 != target_type3 && target_type2 != target_type3
      mod3 = self.getEffectiveness(attack_type, target_type3)
    end
    return mod1 * mod2 * mod3
  end

  def self.ineffective?(attack_type, target_type1, target_type2 = nil, target_type3 = nil)
    value = self.getCombinedEffectiveness(attack_type, target_type1, target_type2, target_type3)
    return PBTypeEffectiveness.ineffective?(value)
  end

  def self.notVeryEffective?(attack_type, target_type1, target_type2 = nil, target_type3 = nil)
    value = self.getCombinedEffectiveness(attack_type, target_type1, target_type2, target_type3)
    return PBTypeEffectiveness.notVeryEffective?(value)
  end

  def self.resistant?(attack_type, target_type1, target_type2 = nil, target_type3 = nil)
    value = self.getCombinedEffectiveness(attack_type, target_type1, target_type2, target_type3)
    return PBTypeEffectiveness.resistant?(value)
  end

  def self.normalEffective?(attack_type, target_type1, target_type2 = nil, target_type3 = nil)
    value = self.getCombinedEffectiveness(attack_type, target_type1, target_type2, target_type3)
    return PBTypeEffectiveness.normalEffective?(value)
  end

  def self.superEffective?(attack_type, target_type1, target_type2 = nil, target_type3 = nil)
    value = self.getCombinedEffectiveness(attack_type, target_type1, target_type2, target_type3)
    return PBTypeEffectiveness.superEffective?(value)
  end
end
