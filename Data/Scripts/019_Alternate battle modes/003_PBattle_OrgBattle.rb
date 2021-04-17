#===============================================================================
# Pokémon Organized Battle
#===============================================================================
def pbHasEligible?(*arg)
  return pbBattleChallenge.rules.ruleset.hasValidTeam?($Trainer.party)
end



class PBPokemon
  attr_accessor :species
  attr_accessor :item
  attr_accessor :nature
  attr_accessor :move1
  attr_accessor :move2
  attr_accessor :move3
  attr_accessor :move4
  attr_accessor :ev

  def initialize(species,item,nature,move1,move2,move3,move4,ev)
    @species = species
    itm = GameData::Item.try_get(item)
    @item = itm ? itm.id : nil
    @nature = nature
    @move1 = move1 ? move1 : 0
    @move2 = move2 ? move2 : 0
    @move3 = move3 ? move3 : 0
    @move4 = move4 ? move4 : 0
    @ev = ev
  end

  # This method is how each Pokémon is compiled from the PBS files listing
  # Battle Tower/Cup Pokémon.
  def self.fromInspected(str)
    insp=str.gsub(/^\s+/,"").gsub(/\s+$/,"")
    pieces=insp.split(/\s*;\s*/)
    species = (GameData::Species.exists?(pieces[0])) ? GameData::Species.get(pieces[0]).id : nil
    item = (GameData::Item.exists?(pieces[1])) ? GameData::Item.get(pieces[1]).id : nil
    nature = (GameData::Nature.exists?(pieces[2])) ? GameData::Nature.get(pieces[2]).id : nil
    ev = pieces[3].split(/\s*,\s*/)
    ev_array = []
    ev.each do |stat|
      case stat.upcase
      when "HP"          then ev_array.push(:HP)
      when "ATK"         then ev_array.push(:ATTACK)
      when "DEF"         then ev_array.push(:DEFENSE)
      when "SA", "SPATK" then ev_array.push(:SPECIAL_ATTACK)
      when "SD", "SPDEF" then ev_array.push(:SPECIAL_DEFENSE)
      when "SPD"         then ev_array.push(:SPEED)
      end
    end
    moves=pieces[4].split(/\s*,\s*/)
    moveid=[]
    for i in 0...Pokemon::MAX_MOVES
      move_data = GameData::Move.try_get(moves[i])
      moveid.push(move_data.id) if move_data
    end
    moveid=[GameData::Move.get(1)] if moveid.length==0
    return self.new(species, item, nature, moveid[0], moveid[1], moveid[2], moveid[3], ev_array)
  end

  def self.fromPokemon(pokemon)
    mov1 = (pokemon.moves[0]) ? pokemon.moves[0].id : nil
    mov2 = (pokemon.moves[1]) ? pokemon.moves[1].id : nil
    mov3 = (pokemon.moves[2]) ? pokemon.moves[2].id : nil
    mov4 = (pokemon.moves[3]) ? pokemon.moves[3].id : nil
    ev_array = []
    GameData::Stat.each_main do |s|
      ev_array.push(s.id) if pokemon.ev[s.id] > 60
    end
    return self.new(pokemon.species,pokemon.item_id,pokemon.nature,
       mov1,mov2,mov3,mov4,ev_array)
  end

  # Unused.
  def self.constFromStr(mod,str)
    maxconst=0
    for constant in mod.constants
      maxconst=[maxconst,mod.const_get(constant.to_sym)].max
    end
    for i in 1..maxconst
      val=mod.getName(i)
      next if !val || val==""
      return i if val==str
    end
    return 0
  end

  # Unused.
  def self.fromString(str)
    return self.fromstring(str)
  end

  # Unused.
  def self.fromstring(str)
    s=str.split(/\s*,\s*/)
    species=GameData::Species.get(s[1]).id
    item=s[2].to_sym
    nature=GameData::Nature.get(s[3]).id
    move1=GameData::Move.get(s[4]).id
    move2=(s.length>=12) ? GameData::Move.get(s[5]).id : nil
    move3=(s.length>=13) ? GameData::Move.get(s[6]).id : nil
    move4=(s.length>=14) ? GameData::Move.get(s[7]).id : nil
    slen = s.length - 6
    ev_array = []
    GameData::Stat.each_main do |s|
      ev_array.push(s.id) if s[slen + s.pbs_order].to_i > 0
    end
    return self.new(species,item,nature,move1,move2,move3,move4,ev_array)
  end

=begin
  def _dump(depth)
    return [@species,@item,@nature,@move1,@move2,
       @move3,@move4,@ev].pack("vvCvvvvC")
  end

  def self._load(str)
    data=str.unpack("vvCvvvvC")
    return self.new(
       data[0],data[1],data[2],data[3],
       data[4],data[5],data[6],data[7]
    )
  end
=end

  def inspect
    c1=GameData::Species.get(@species).id.to_s
    c2=(@item) ? GameData::Item.get(@item).id.to_s : ""
    c3=(@nature) ? GameData::Nature.get(@nature).id.to_s : ""
    evlist = ""
    @ev.each do |stat|
      evlist += "," if evlist != ""
      evlist += stat.real_name_brief
    end
    c4=(@move1) ? GameData::Move.get(@move1).id_to_s : ""
    c5=(@move2) ? GameData::Move.get(@move2).id_to_s : ""
    c6=(@move3) ? GameData::Move.get(@move3).id_to_s : ""
    c7=(@move4) ? GameData::Move.get(@move4).id_to_s : ""
    return "#{c1};#{c2};#{c3};#{evlist};#{c4},#{c5},#{c6},#{c7}"
  end

  # Unused.
  def tocompact
    return "#{species},#{item},#{nature},#{move1},#{move2},#{move3},#{move4},#{ev}"
  end

  def convertMove(move)
    move = :FRUSTRATION if move == :RETURN && GameData::Move.exists?(:FRUSTRATION)
    return move
  end

  def createPokemon(level,iv,trainer)
    pokemon=Pokemon.new(@species,level,trainer,false)
    pokemon.item = @item
    pokemon.personalID = rand(2**16) | rand(2**16) << 16
    pokemon.personalID -= pokemon.personalID % 25
    pokemon.personalID += nature
    pokemon.personalID &= 0xFFFFFFFF
    pokemon.happiness=0
    pokemon.moves[0] = Pokemon::Move.new(self.convertMove(@move1))
    pokemon.moves[1] = Pokemon::Move.new(self.convertMove(@move2))
    pokemon.moves[2] = Pokemon::Move.new(self.convertMove(@move3))
    pokemon.moves[3] = Pokemon::Move.new(self.convertMove(@move4))
    if ev.length > 0
      ev.each { |stat| pokemon.ev[stat] = Pokemon::EV_LIMIT / ev.length }
    end
    GameData::Stat.each_main { |s| pokemon.iv[s.id] = iv }
    pokemon.calc_stats
    return pokemon
  end
end



def pbGetBTTrainers(challengeID)
  trlists=(load_data("Data/trainer_lists.dat") rescue [])
  for i in 0...trlists.length
    tr=trlists[i]
    if !tr[5] && tr[2].include?(challengeID)
      return tr[0]
    end
  end
  for i in 0...trlists.length
    tr=trlists[i]
    if tr[5] # is default list
      return tr[0]
    end
  end
  return []
end

def pbGetBTPokemon(challengeID)
  trlists=(load_data("Data/trainer_lists.dat") rescue [])
  for tr in trlists
    if !tr[5] && tr[2].include?(challengeID)
      return tr[1]
    end
  end
  for tr in trlists
    if tr[5] # is default list
      return tr[1]
    end
  end
  return []
end



class Game_Player < Game_Character
  attr_accessor :direction

  def moveto2(x, y)
    @x = x
    @y = y
    @real_x = @x * 128
    @real_y = @y * 128
    @prelock_direction = 0
  end
end



class BattleChallengeType
  attr_accessor :currentWins
  attr_accessor :previousWins
  attr_accessor :maxWins
  attr_accessor :currentSwaps
  attr_accessor :previousSwaps
  attr_accessor :maxSwaps
  attr_reader :doublebattle
  attr_reader :numPokemon
  attr_reader :battletype
  attr_reader :mode

  def initialize
    @previousWins=0
    @maxWins=0
    @currentWins=0
    @currentSwaps=0
    @previousSwaps=0
    @maxSwaps=0
  end

  def saveWins(challenge)
    if challenge.decision==0     # if undecided
      @currentWins=0
      @currentSwaps=0
    else
      if challenge.decision==1   # if won
        @currentWins=challenge.wins
        @currentSwaps=challenge.swaps
      else                       # if lost
        @currentWins=0
        @currentSwaps=0
      end
      @maxWins=[@maxWins,challenge.wins].max
      @previousWins=challenge.wins
      @maxSwaps=[@maxSwaps,challenge.swaps].max
      @previousSwaps=challenge.swaps
    end
  end
end



class BattleChallengeData
  attr_reader :resting
  attr_reader :wins
  attr_reader :swaps
  attr_reader :inProgress
  attr_reader :battleNumber
  attr_reader :numRounds
  attr_accessor :decision
  attr_reader :party
  attr_reader :extraData

  def setExtraData(value)
    @extraData=value
  end

  def pbAddWin
    if @inProgress
      @battleNumber+=1
      @wins+=1
    end
  end

  def pbAddSwap
    if @inProgress
      @swaps+=1
    end
  end

  def pbMatchOver?
    return true if !@inProgress
    return true if @decision!=0
    return (@battleNumber>@numRounds)
  end

  def initialize
    reset
  end

  def nextTrainer
    return @trainers[@battleNumber-1]
  end

  def pbGoToStart
    if $scene.is_a?(Scene_Map)
      $game_temp.player_transferring = true
      $game_temp.player_new_map_id = @start[0]
      $game_temp.player_new_x = @start[1]
      $game_temp.player_new_y = @start[2]
      $game_temp.player_new_direction = 8
      $scene.transfer_player
    end
  end

  def setParty(value)
    if @inProgress
      $Trainer.party=value
      @party=value
    else
      @party=value
    end
  end

  def pbStart(t,numRounds)
    @inProgress=true
    @resting=false
    @decision=0
    @swaps=t.currentSwaps
    @wins=t.currentWins
    @battleNumber=1
    @trainers=[]
    raise _INTL("Number of rounds is 0 or less.") if numRounds<=0
    @numRounds=numRounds
    btTrainers=pbGetBTTrainers(pbBattleChallenge.currentChallenge)
    while @trainers.length<@numRounds
      newtrainer=pbBattleChallengeTrainer(@wins+@trainers.length,btTrainers)
      found=false
      for tr in @trainers
        found=true if tr==newtrainer
      end
      @trainers.push(newtrainer) if !found
    end
    @start=[$game_map.map_id,$game_player.x,$game_player.y]
    @oldParty=$Trainer.party
    $Trainer.party=@party if @party
    Game.save(safe: true)
  end

  def pbCancel
    $Trainer.party=@oldParty if @oldParty
    reset
  end

  def pbEnd
    $Trainer.party=@oldParty
    return if !@inProgress
    save=(@decision!=0)
    reset
    $game_map.need_refresh=true
    Game.save(safe: true) if save
  end

  def pbGoOn
    return if !@inProgress
    @resting=false
    pbSaveInProgress
  end

  def pbRest
    return if !@inProgress
    @resting=true
    pbSaveInProgress
  end

  private

  def reset
    @inProgress=false
    @resting=false
    @start=nil
    @decision=0
    @wins=0
    @swaps=0
    @battleNumber=0
    @trainers=[]
    @oldParty=nil
    @party=nil
    @extraData=nil
  end

  def pbSaveInProgress
    oldmapid=$game_map.map_id
    oldx=$game_player.x
    oldy=$game_player.y
    olddirection=$game_player.direction
    $game_map.map_id=@start[0]
    $game_player.moveto2(@start[1],@start[2])
    $game_player.direction=8 # facing up
    Game.save(safe: true)
    $game_map.map_id=oldmapid
    $game_player.moveto2(oldx,oldy)
    $game_player.direction=olddirection
  end
end



class BattleChallenge
  attr_reader :currentChallenge
  BattleTowerID   = 0
  BattlePalaceID  = 1
  BattleArenaID   = 2
  BattleFactoryID = 3

  def initialize
    @bc=BattleChallengeData.new
    @currentChallenge=-1
    @types={}
  end

  def rules
    if !@rules
      @rules=modeToRules(self.data.doublebattle,
         self.data.numPokemon,
         self.data.battletype,self.data.mode)
    end
    return @rules
  end

  def modeToRules(doublebattle,numPokemon,battletype,mode)
    rules=PokemonChallengeRules.new
    if battletype==BattlePalaceID
      rules.setBattleType(BattlePalace.new)
    elsif battletype==BattleArenaID
      rules.setBattleType(BattleArena.new)
      doublebattle=false
    else
      rules.setBattleType(BattleTower.new)
    end
    if mode==1      # Open Level
      rules.setRuleset(StandardRules(numPokemon,GameData::GrowthRate.max_level))
      rules.setLevelAdjustment(OpenLevelAdjustment.new(30))
    elsif mode==2   # Battle Tent
      rules.setRuleset(StandardRules(numPokemon,GameData::GrowthRate.max_level))
      rules.setLevelAdjustment(OpenLevelAdjustment.new(60))
    else
      rules.setRuleset(StandardRules(numPokemon,50))
      rules.setLevelAdjustment(OpenLevelAdjustment.new(50))
    end
    if doublebattle
      rules.addBattleRule(DoubleBattle.new)
    else
      rules.addBattleRule(SingleBattle.new)
    end
    return rules
  end

  def set(id,numrounds,rules)
    @id=id
    @numRounds=numrounds
    @rules=rules
    pbWriteCup(id,rules)
  end

  def start(*args)
    ensureType(@id)
    @currentChallenge=@id   # must appear before pbStart
    @bc.pbStart(t,@numRounds)
  end

  def register(id,doublebattle,numrounds,numPokemon,battletype,mode=1)
    ensureType(id)
    if battletype==BattleFactoryID
      @bc.setExtraData(BattleFactoryData.new(@bc))
      numPokemon=3
      battletype=BattleTowerID
    end
    @numRounds=numrounds
    @rules=modeToRules(doublebattle,numPokemon,battletype,mode)
  end

  def pbInChallenge?
    return pbInProgress?
  end

  def data
    return nil if !pbInProgress? || @currentChallenge<0
    return ensureType(@currentChallenge).clone
  end

  def getCurrentWins(challenge)
    return ensureType(challenge).currentWins
  end

  def getPreviousWins(challenge)
    return ensureType(challenge).previousWins
  end

  def getMaxWins(challenge)
    return ensureType(challenge).maxWins
  end

  def getCurrentSwaps(challenge)
    return ensureType(challenge).currentSwaps
  end

  def getPreviousSwaps(challenge)
    return ensureType(challenge).previousSwaps
  end

  def getMaxSwaps(challenge)
    return ensureType(challenge).maxSwaps
  end

  def pbStart(challenge)
  end

  def pbEnd
    if @currentChallenge!=-1
      ensureType(@currentChallenge).saveWins(@bc)
      @currentChallenge=-1
    end
    @bc.pbEnd
  end

  def pbBattle
    return @bc.extraData.pbBattle(self) if @bc.extraData
    opponent=pbGenerateBattleTrainer(self.nextTrainer,self.rules)
    bttrainers=pbGetBTTrainers(@id)
    trainerdata=bttrainers[self.nextTrainer]
    ret=pbOrganizedBattleEx(opponent,self.rules,
       pbGetMessageFromHash(MessageTypes::EndSpeechLose,trainerdata[4]),
       pbGetMessageFromHash(MessageTypes::EndSpeechWin,trainerdata[3]))
    return ret
  end

  def pbInProgress?
    return @bc.inProgress
  end

  def pbResting?
    return @bc.resting
  end

  def setDecision(value)
    @bc.decision=value
  end

  def setParty(value)
    @bc.setParty(value)
  end

  def extra; @bc.extraData; end
  def decision; @bc.decision; end
  def wins; @bc.wins; end
  def swaps; @bc.swaps; end
  def battleNumber; @bc.battleNumber; end
  def nextTrainer; @bc.nextTrainer; end
  def pbGoOn; @bc.pbGoOn; end
  def pbAddWin; @bc.pbAddWin; end
  def pbCancel; @bc.pbCancel; end
  def pbRest; @bc.pbRest; end
  def pbMatchOver?; @bc.pbMatchOver?; end
  def pbGoToStart; @bc.pbGoToStart; end

  private

  def ensureType(id)
    if @types.is_a?(Array)
      oldtypes=@types
      @types={}
      for i in 0...oldtypes.length
        @types[i]=oldtypes[i] if oldtypes[i]
      end
    end
    @types[id]=BattleChallengeType.new if !@types[id]
    return @types[id]
  end
end



def pbRecordLastBattle
  $PokemonGlobal.lastbattle = $PokemonTemp.lastbattle
  $PokemonTemp.lastbattle   = nil
end

def pbPlayBattle(battledata)
  return if !battledata
  scene = pbNewBattleScene
  scene.abortable = true
  lastbattle = Marshal.restore(StringInput.new(battledata))
  case lastbattle[0]
  when BattleChallenge::BattleTowerID
    battleplayer = PokeBattle_BattlePlayer.new(scene,lastbattle)
  when BattleChallenge::BattlePalaceID
    battleplayer = PokeBattle_BattlePalacePlayer.new(scene,lastbattle)
  when BattleChallenge::BattleArenaID
    battleplayer = PokeBattle_BattleArenaPlayer.new(scene,lastbattle)
  end
  bgm = BattlePlayerHelper.pbGetBattleBGM(lastbattle)
  pbBattleAnimation(bgm) {
    pbSceneStandby {
      battleplayer.pbStartBattle
    }
  }
end

def pbDebugPlayBattle
  params = ChooseNumberParams.new
  params.setRange(0,500)
  params.setInitialValue(0)
  params.setCancelValue(-1)
  num = pbMessageChooseNumber(_INTL("Choose a battle."),params)
  if num>=0
    pbPlayBattleFromFile(sprintf("Battles/Battle%03d.dat",num))
  end
end

def pbPlayLastBattle
  pbPlayBattle($PokemonGlobal.lastbattle)
end

def pbPlayBattleFromFile(filename)
  pbRgssOpen(filename,"rb") { |f| pbPlayBattle(f.read) }
end



class Game_Event
  def pbInChallenge?
    return pbBattleChallenge.pbInChallenge?
  end
end



def pbBattleChallenge
  if !$PokemonGlobal.challenge
    $PokemonGlobal.challenge=BattleChallenge.new
  end
  return $PokemonGlobal.challenge
end

def pbBattleChallengeTrainer(numwins,bttrainers)
  table=[
     0,5,0,100,
     6,6,80,40,
     7,12,80,40,
     13,13,120,20,
     14,19,100,40,
     20,20,140,20,
     21,26,120,40,
     27,27,160,20,
     28,33,140,40,
     34,34,180,20,
     35,40,160,40,
     41,41,200,20,
     42,47,180,40,
     48,48,220,40,
     49,-1,200,100
  ]
  for i in 0...table.length/4
    if table[i*4]<=numwins
      if (table[i*4+1]<0 || table[i*4+1]>=numwins)
        offset=((table[i*4+2]*bttrainers.length).floor/300).floor
        length=((table[i*4+3]*bttrainers.length).floor/300).floor
        return (offset+rand(length)).floor
      end
    end
  end
  return 0
end

def pbBattleChallengeGraphic(event)
  nextTrainer=pbBattleChallenge.nextTrainer
  bttrainers=pbGetBTTrainers(pbBattleChallenge.currentChallenge)
  filename=GameData::TrainerType.charset_filename_brief((bttrainers[nextTrainer][0] rescue 0))
  begin
    bitmap=AnimatedBitmap.new("Graphics/Characters/"+filename)
    bitmap.dispose
    event.character_name=filename
  rescue
    event.character_name="NPC 01"
  end
end

def pbBattleChallengeBeginSpeech
  if !pbBattleChallenge.pbInProgress?
    return "..."
  else
    bttrainers=pbGetBTTrainers(pbBattleChallenge.currentChallenge)
    tr=bttrainers[pbBattleChallenge.nextTrainer]
    return tr ? pbGetMessageFromHash(MessageTypes::BeginSpeech,tr[2]) : "..."
  end
end

def pbEntryScreen(*arg)
  retval = false
  pbFadeOutIn {
    scene = PokemonParty_Scene.new
    screen = PokemonPartyScreen.new(scene,$Trainer.party)
    ret = screen.pbPokemonMultipleEntryScreenEx(pbBattleChallenge.rules.ruleset)
    # Set party
    pbBattleChallenge.setParty(ret) if ret
    # Continue (return true) if Pokémon were chosen
    retval = (ret!=nil && ret.length>0)
  }
  return retval
end

def pbBattleChallengeBattle
  return pbBattleChallenge.pbBattle
end



class BattleFactoryData
  def initialize(bcdata)
    @bcdata=bcdata
  end

  def pbPrepareRentals
    @rentals=pbBattleFactoryPokemon(1,@bcdata.wins,@bcdata.swaps,[])
    @trainerid=@bcdata.nextTrainer
    bttrainers=pbGetBTTrainers(@bcdata.currentChallenge)
    trainerdata=bttrainers[@trainerid]
    @opponent=NPCTrainer.new(
       pbGetMessageFromHash(MessageTypes::TrainerNames,trainerdata[1]),
       trainerdata[0])
    opponentPkmn=pbBattleFactoryPokemon(1,@bcdata.wins,@bcdata.swaps,@rentals)
    @opponent.party=opponentPkmn.shuffle[0,3]
  end

  def pbChooseRentals
    pbFadeOutIn {
      scene = BattleSwapScene.new
      screen = BattleSwapScreen.new(scene)
      @rentals = screen.pbStartRent(@rentals)
      @bcdata.pbAddSwap
      pbBattleChallenge.setParty(@rentals)
    }
  end

  def pbBattle(challenge)
    bttrainers=pbGetBTTrainers(@bcdata.currentChallenge)
    trainerdata=bttrainers[@trainerid]
    return pbOrganizedBattleEx(@opponent,challenge.rules,
       pbGetMessageFromHash(MessageTypes::EndSpeechLose,trainerdata[4]),
       pbGetMessageFromHash(MessageTypes::EndSpeechWin,trainerdata[3]))
  end

  def pbPrepareSwaps
    @oldopponent=@opponent.party
    trainerid=@bcdata.nextTrainer
    bttrainers=pbGetBTTrainers(@bcdata.currentChallenge)
    trainerdata=bttrainers[trainerid]
    @opponent=NPCTrainer.new(
       pbGetMessageFromHash(MessageTypes::TrainerNames,trainerdata[1]),
       trainerdata[0])
    opponentPkmn=pbBattleFactoryPokemon(
       challenge.rules,@bcdata.wins,@bcdata.swaps,
       [].concat(@rentals).concat(@oldopponent))
    @opponent.party=opponentPkmn.shuffle[0,3]
  end

  def pbChooseSwaps
    swapMade = true
    pbFadeOutIn {
      scene = BattleSwapScene.new
      screen = BattleSwapScreen.new(scene)
      swapMade = screen.pbStartSwap(@rentals,@oldopponent)
      if swapMade
        @bcdata.pbAddSwap
      end
      @bcdata.setParty(@rentals)
    }
    return swapMade
  end
end



def pbBattleFactoryPokemon(rule,numwins,numswaps,_rentals)
  table=nil
  btpokemon=pbGetBTPokemon(pbBattleChallenge.currentChallenge)
  ivtable=[
     0,6,3,6,
     7,13,6,9,
     14,20,9,12,
     21,27,12,15,
     28,34,15,21,
     35,41,21,31,
     42,-1,31,31
  ]
  groups=[
     1,14,6,0,
     15,21,5,1,
     22,28,4,2,
     29,35,3,3,
     36,42,2,4,
     43,-1,1,5
  ]
  if rule.ruleset.suggestedLevel!=100
    table=[
       0,6,110,199,
       7,13,162,266,
       14,20,267,371,
       21,27,372,467,
       28,34,468,563,
       35,41,564,659,
       42,48,660,755,
       49,-1,372,849
    ]
  else # Open Level (Level 100)
    table=[
       0,6,372,467,
       7,13,468,563,
       14,20,564,659,
       21,27,660,755,
       28,34,372,881,
       35,41,372,881,
       42,48,372,881,
       49,-1,372,881
    ]
  end
  pokemonNumbers=[0,0]
  ivs=[0,0]
  ivgroups=[6,0]
  for i in 0...table.length/4
    if table[i*4]<=numwins
      if (table[i*4+1]<0 || table[i*4+1]>=numwins)
        pokemonNumbers=[
           table[i*4+2]*btpokemon.length/882,
	         table[i*4+3]*btpokemon.length/882
	      ]
      end
    end
  end
  for i in 0...ivtable.length/4
    if ivtable[i*4]<=numwins
      if (ivtable[i*4+1]<0 || ivtable[i*4+1]>=numwins)
        ivs=[ivtable[i*4+2],ivtable[i*4+3]]
      end
    end
  end
  for i in 0...groups.length/4
    if groups[i*4]<=numswaps
      if (groups[i*4+1]<0 || groups[i*4+1]>=numswaps)
        ivgroups=[groups[i*4+2],groups[i*4+3]]
      end
    end
  end
  party=[]
  loop do
    party.clear
    while party.length < Settings::MAX_PARTY_SIZE
      rnd=pokemonNumbers[0]+rand(pokemonNumbers[1]-pokemonNumbers[0]+1)
      rndpoke=btpokemon[rnd]
      indvalue=(party.length<ivgroups[0]) ? ivs[0] : ivs[1]
      party.push(rndpoke.createPokemon(rule.ruleset.suggestedLevel,indvalue,nil))
    end
    break if rule.ruleset.isValid?(party)
  end
  return party
end

def pbGenerateBattleTrainer(trainerid,rule)
  bttrainers=pbGetBTTrainers(pbBattleChallenge.currentChallenge)
  trainerdata=bttrainers[trainerid]
  opponent=NPCTrainer.new(
     pbGetMessageFromHash(MessageTypes::TrainerNames,trainerdata[1]),
     trainerdata[0])
  btpokemon=pbGetBTPokemon(pbBattleChallenge.currentChallenge)
  # Individual Values
  indvalues=31
  indvalues=21 if trainerid<220
  indvalues=18 if trainerid<200
  indvalues=15 if trainerid<180
  indvalues=12 if trainerid<160
  indvalues=9 if trainerid<140
  indvalues=6 if trainerid<120
  indvalues=3 if trainerid<100
  pokemonnumbers=trainerdata[5]
  #p trainerdata
  if pokemonnumbers.length<rule.ruleset.suggestedNumber
    for n in pokemonnumbers
      rndpoke=btpokemon[n]
      pkmn=rndpoke.createPokemon(rule.ruleset.suggestedLevel,indvalues,opponent)
      opponent.party.push(pkmn)
    end
    return opponent
  end
  loop do
    opponent.party.clear
    while opponent.party.length<rule.ruleset.suggestedNumber
      rnd=pokemonnumbers[rand(pokemonnumbers.length)]
      rndpoke=btpokemon[rnd]
      pkmn=rndpoke.createPokemon(
         rule.ruleset.suggestedLevel,indvalues,opponent)
      opponent.party.push(pkmn)
    end
    break if rule.ruleset.isValid?(opponent.party)
  end
  return opponent
end

def pbOrganizedBattleEx(opponent,challengedata,endspeech,endspeechwin)
  # Skip battle if holding Ctrl in Debug mode
  if Input.press?(Input::CTRL) && $DEBUG
    pbMessage(_INTL("SKIPPING BATTLE..."))
    pbMessage(_INTL("AFTER WINNING..."))
    endspeech.each { |msg| pbMessage(msg || "...") }
    $PokemonTemp.lastbattle = nil
    return true
  end
  $Trainer.heal_party
  # Remember original data, to be restored after battle
  challengedata = PokemonChallengeRules.new if !challengedata
  oldlevels = challengedata.adjustLevels($Trainer.party,opponent.party)
  olditems  = $Trainer.party.transform { |p| p.item_id }
  olditems2 = opponent.party.transform { |p| p.item_id }
  # Create the battle scene (the visual side of it)
  scene = pbNewBattleScene
  # Create the battle class (the mechanics side of it)
  battle = challengedata.createBattle(scene,$Trainer,opponent)
  battle.internalBattle = false
  battle.endSpeeches    = [endspeech]
  battle.endSpeechesWin = [endspeechwin]
  # Set various other properties in the battle class
  pbPrepareBattle(battle)
  # Perform the battle itself
  decision = 0
  pbBattleAnimation(pbGetTrainerBattleBGM(opponent)) {
    pbSceneStandby{
      decision = battle.pbStartBattle
    }
  }
  Input.update
  # Restore both parties to their original levels
  challengedata.unadjustLevels($Trainer.party,opponent.party,oldlevels)
  # Heal both parties and restore their original items
  $Trainer.party.each_with_index do |pkmn,i|
    pkmn.heal
    pkmn.makeUnmega
    pkmn.makeUnprimal
    pkmn.item = olditems[i]
  end
  opponent.party.each_with_index do |pkmn,i|
    pkmn.heal
    pkmn.makeUnmega
    pkmn.makeUnprimal
    pkmn.item = olditems2[i]
  end
  # Save the record of the battle
  $PokemonTemp.lastbattle = nil
  if decision==1 || decision==2 || decision==5   # if win, loss or draw
    $PokemonTemp.lastbattle = battle.pbDumpRecord
  end
  # Return true if the player won the battle, and false if any other result
  return (decision==1)
end

def pbIsBanned?(pokemon)
  return StandardSpeciesRestriction.new.isValid?(pokemon)
end
