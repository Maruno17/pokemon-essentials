begin
  module PBStats
    # NOTE: You can change the order that the compiler expects Pokémon base
    #       stats/EV yields (effort points) to be in, by simply renumbering the
    #       stats here. The "main" stats (i.e. not accuracy/evasion) must still
    #       use up numbers 0 to 5 inclusive, though. It's up to you to write the
    #       base stats/EV yields in pokemon.txt and pokemonforms.txt in the
    #       order expected.
    HP       = 0
    ATTACK   = 1
    DEFENSE  = 2
    SPEED    = 3
    SPATK    = 4
    SPDEF    = 5
    ACCURACY = 6
    EVASION  = 7

    def self.getName(id)
      id = getID(PBStats,id)
      names = []
      names[HP]       = _INTL("HP")
      names[ATTACK]   = _INTL("Attack")
      names[DEFENSE]  = _INTL("Defense")
      names[SPEED]    = _INTL("Speed")
      names[SPATK]    = _INTL("Special Attack")
      names[SPDEF]    = _INTL("Special Defense")
      names[ACCURACY] = _INTL("accuracy")
      names[EVASION]  = _INTL("evasiveness")
      return names[id]
    end

    def self.getNameBrief(id)
      id = getID(PBStats,id)
      names = []
      names[HP]       = _INTL("HP")
      names[ATTACK]   = _INTL("Atk")
      names[DEFENSE]  = _INTL("Def")
      names[SPEED]    = _INTL("Spd")
      names[SPATK]    = _INTL("SpAtk")
      names[SPDEF]    = _INTL("SpDef")
      names[ACCURACY] = _INTL("acc")
      names[EVASION]  = _INTL("eva")
      return names[id]
    end

    def self.eachStat
      [HP,ATTACK,DEFENSE,SPATK,SPDEF,SPEED].each { |s| yield s }
    end

    def self.eachMainBattleStat
      [ATTACK,DEFENSE,SPATK,SPDEF,SPEED].each { |s| yield s }
    end

    def self.eachBattleStat
      [ATTACK,DEFENSE,SPATK,SPDEF,SPEED,ACCURACY,EVASION].each { |s| yield s }
    end

    def self.validBattleStat?(stat)
      self.eachBattleStat { |s| return true if s==stat }
      return false
    end
  end

rescue Exception
  if $!.is_a?(SystemExit) || "#{$!.class}"=="Reset"
    raise $!
  end
end
