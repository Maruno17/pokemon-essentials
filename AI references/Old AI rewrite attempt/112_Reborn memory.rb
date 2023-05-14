class PokeBattle_Battle
  attr_accessor :aiMoveMemory

  alias __ai__initialize initialize
  def initialize(scene,p1,p2,player,opponent)
    __ai__initialize(scene,p1,p2,player,opponent)
    @aiMoveMemory = [[],
                     [],
                     [[], [], [], [], [], [], [], [], [], [], [], []]   # One array for each party index
                    ]
  end

  ################################################################################
  # AI Memory utility functions
  ################################################################################
  def getAIMemory(skill,index=0)
    if skill>=PBTrainerAI.bestSkill
      return @aiMoveMemory[2][index]
    elsif skill>=PBTrainerAI.highSkill
      return @aiMoveMemory[1]
    elsif skill>=PBTrainerAI.mediumSkill
      return @aiMoveMemory[0]
    else
      return []
    end
  end

  def checkAImoves(moveID,memory)
    #basic "does the other mon have x"
    return false if memory.length == 0
    for i in moveID
      for j in memory
        j = pbChangeMove(j,nil)#doesn't matter that i'm passing nil, won't get used
        return true if i == j.id #i should already be an ID here
      end
    end
    return false
  end

  def checkAIhealing(memory)
    #less basic "can the other mon heal"
    return false if memory.length == 0
    for j in memory
      return true if j.isHealingMove?
    end
    return false
  end

  def checkAIpriority(memory)
    #"does the other mon have priority"
    return false if memory.length == 0
    for j in memory
      return true if j.priority>0
    end
    return false
  end

  def checkAIaccuracy(memory)
    #"does the other mon have moves that don't miss"
    return false if memory.length == 0
    for j in memory
      j = pbChangeMove(j,nil)
      return true if j.accuracy==0
    end
    return false
  end

  def checkAIdamage(memory,attacker,opponent,skill)
    #returns how much damage the AI expects to take
    return -1 if memory.length == 0
    maxdam=0
    for j in memory
      tempdam = pbRoughDamage(j,opponent,attacker,skill,j.basedamage)
      maxdam=tempdam if tempdam>maxdam
    end
    return maxdam
  end

  def checkAIbest(memory,modifier,type=[],usepower=true,attacker=nil,opponent=nil,skill=nil)
    return false if memory.length == 0
    #had to split this because switching ai uses power
    bestmove = 0
    if usepower
      biggestpower = 0
      for j in memory
        if j.basedamage>biggestpower
          biggestpower=j.basedamage
          bestmove=j
        end
      end
    else #maxdam
      maxdam=0
      for j in memory
        tempdam = pbRoughDamage(j,opponent,attacker,skill,j.basedamage)
        if tempdam>maxdam
          maxdam=tempdam
          bestmove=j
        end
      end
    end
    return false if bestmove==0
    #i don't want to make multiple functions for rare cases
    #we're doing it in one and you're gonna like it
    case modifier
    when 1 #type mod. checks types from a list.
      return true if type.include?(bestmove.type)
    when 2 #physical mod.
      return true if bestmove.pbIsPhysical?(bestmove.type)
    when 3 #special mod.
      return true if bestmove.pbIsSpecial?(bestmove.type)
    when 4 #contact mod.
      return true if bestmove.isContactMove?
    when 5 #sound mod.
      return true if bestmove.isSoundBased?
    when 6 #why.
      return true if (PBStuff::BULLETMOVE).include?(bestmove.id)
    end
    return false #you're still here? it's over! go home.
  end

end
