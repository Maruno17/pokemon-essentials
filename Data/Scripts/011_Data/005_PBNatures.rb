module PBNatures
  HARDY   = 0
  LONELY  = 1
  BRAVE   = 2
  ADAMANT = 3
  NAUGHTY = 4
  BOLD    = 5
  DOCILE  = 6
  RELAXED = 7
  IMPISH  = 8
  LAX     = 9
  TIMID   = 10
  HASTY   = 11
  SERIOUS = 12
  JOLLY   = 13
  NAIVE   = 14
  MODEST  = 15
  MILD    = 16
  QUIET   = 17
  BASHFUL = 18
  RASH    = 19
  CALM    = 20
  GENTLE  = 21
  SASSY   = 22
  CAREFUL = 23
  QUIRKY  = 24

  def self.maxValue; 24; end
  def self.getCount; 25; end

  def self.getName(id)
    id = getID(PBNatures,id)
    names = [
       _INTL("Hardy"),
       _INTL("Lonely"),
       _INTL("Brave"),
       _INTL("Adamant"),
       _INTL("Naughty"),
       _INTL("Bold"),
       _INTL("Docile"),
       _INTL("Relaxed"),
       _INTL("Impish"),
       _INTL("Lax"),
       _INTL("Timid"),
       _INTL("Hasty"),
       _INTL("Serious"),
       _INTL("Jolly"),
       _INTL("Naive"),
       _INTL("Modest"),
       _INTL("Mild"),
       _INTL("Quiet"),
       _INTL("Bashful"),
       _INTL("Rash"),
       _INTL("Calm"),
       _INTL("Gentle"),
       _INTL("Sassy"),
       _INTL("Careful"),
       _INTL("Quirky")
    ]
    return names[id]
  end

  def self.getStatRaised(id)
    m = (id%25)/5   # 25 here is (number of stats)**2, not PBNatures.getCount
    return [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
            PBStats::SPATK,PBStats::SPDEF][m]
  end

  def self.getStatLowered(id)
    m = id%5   # Don't need to %25 here because 25 is a multiple of 5
    return [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
            PBStats::SPATK,PBStats::SPDEF][m]
  end

  def self.getStatChanges(id)
    id = getID(PBNatures,id)
    up = PBNatures.getStatRaised(id)
    dn = PBNatures.getStatLowered(id)
    ret = []
    PBStats.eachStat do |s|
      ret[s] = 100
      ret[s] += 10 if s==up
      ret[s] -= 10 if s==dn
    end
    return ret
  end
end
