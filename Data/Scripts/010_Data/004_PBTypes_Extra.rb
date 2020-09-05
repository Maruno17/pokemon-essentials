module PBTypeEffectiveness
  INEFFECTIVE          = 0
  NOT_EFFECTIVE_ONE    = 1
  NORMAL_EFFECTIVE_ONE = 2
  SUPER_EFFECTIVE_ONE  = 4
  NORMAL_EFFECTIVE     = NORMAL_EFFECTIVE_ONE ** 3
end



class PBTypes
  @@TypeData = nil

  def PBTypes.loadTypeData
    if !@@TypeData
      @@TypeData = load_data("Data/types.dat")
      @@TypeData[0].freeze
      @@TypeData[1].freeze
      @@TypeData[2].freeze
      @@TypeData.freeze
    end
    return @@TypeData
  end

  def PBTypes.regularTypesCount
    ret = 0
    for i in 0..PBTypes.maxValue
      next if PBTypes.isPseudoType?(i) || isConst?(i,PBTypes,:SHADOW)
      ret += 1
    end
    return ret
  end

  def PBTypes.isPseudoType?(type)
    return PBTypes.loadTypeData[0].include?(type)
  end

  def PBTypes.isSpecialType?(type)
    return PBTypes.loadTypeData[1].include?(type)
  end

  def PBTypes.getEffectiveness(attackType,targetType)
    return PBTypeEffectiveness::NORMAL_EFFECTIVE_ONE if !targetType || targetType<0
    return PBTypes.loadTypeData[2][attackType*(PBTypes.maxValue+1)+targetType]
  end

  def PBTypes.getCombinedEffectiveness(attackType,targetType1,targetType2=nil,targetType3=nil)
    mod1 = PBTypes.getEffectiveness(attackType,targetType1)
    mod2 = PBTypeEffectiveness::NORMAL_EFFECTIVE_ONE
    mod3 = PBTypeEffectiveness::NORMAL_EFFECTIVE_ONE
    if targetType2!=nil && targetType2>=0 && targetType1!=targetType2
      mod2 = PBTypes.getEffectiveness(attackType,targetType2)
    end
    if targetType3!=nil && targetType3>=0 &&
       targetType1!=targetType3 && targetType2!=targetType3
      mod3 = PBTypes.getEffectiveness(attackType,targetType3)
    end
    return mod1*mod2*mod3
  end

  def PBTypes.ineffective?(attackType,targetType1=nil,targetType2=nil,targetType3=nil)
    return attackType==PBTypeEffectiveness::INEFFECTIVE if !targetType1
    e = PBTypes.getCombinedEffectiveness(attackType,targetType1,targetType2,targetType3)
    return e==PBTypeEffectiveness::INEFFECTIVE
  end

  def PBTypes.notVeryEffective?(attackType,targetType1=nil,targetType2=nil,targetType3=nil)
    return attackType>PBTypeEffectiveness::INEFFECTIVE && attackType<PBTypeEffectiveness::NORMAL_EFFECTIVE if !targetType1
    e = PBTypes.getCombinedEffectiveness(attackType,targetType1,targetType2,targetType3)
    return e>PBTypeEffectiveness::INEFFECTIVE && e<PBTypeEffectiveness::NORMAL_EFFECTIVE
  end

  def PBTypes.resistant?(attackType,targetType1=nil,targetType2=nil,targetType3=nil)
    return attackType<PBTypeEffectiveness::NORMAL_EFFECTIVE if !targetType1
    e = PBTypes.getCombinedEffectiveness(attackType,targetType1,targetType2,targetType3)
    return e<PBTypeEffectiveness::NORMAL_EFFECTIVE
  end

  def PBTypes.normalEffective?(attackType,targetType1=nil,targetType2=nil,targetType3=nil)
    return attackType==PBTypeEffectiveness::NORMAL_EFFECTIVE if !targetType1
    e = PBTypes.getCombinedEffectiveness(attackType,targetType1,targetType2,targetType3)
    return e==PBTypeEffectiveness::NORMAL_EFFECTIVE
  end

  def PBTypes.superEffective?(attackType,targetType1=nil,targetType2=nil,targetType3=nil)
    return attackType>PBTypeEffectiveness::NORMAL_EFFECTIVE if !targetType1
    e = PBTypes.getCombinedEffectiveness(attackType,targetType1,targetType2,targetType3)
    return e>PBTypeEffectiveness::NORMAL_EFFECTIVE
  end
end
