module PokeBattle_BattleCommon
  #=============================================================================
  # Store caught Pokémon
  #=============================================================================
  def pbStorePokemon(pkmn)
    # Nickname the Pokémon (unless it's a Shadow Pokémon)
    if !pkmn.shadowPokemon?
      if pbDisplayConfirm(_INTL("Would you like to give a nickname to {1}?",pkmn.name))
        nickname = @scene.pbNameEntry(_INTL("{1}'s nickname?",pkmn.speciesName),pkmn)
        pkmn.name = nickname if nickname!=""
      end
    end
    # Store the Pokémon
    currentBox = @peer.pbCurrentBox
    storedBox  = @peer.pbStorePokemon(pbPlayer,pkmn)
    if storedBox<0
      pbDisplayPaused(_INTL("{1} has been added to your party.",pkmn.name))
      @initialItems[0][pbPlayer.party.length-1] = pkmn.item if @initialItems
      return
    end
    # Messages saying the Pokémon was stored in a PC box
    creator    = @peer.pbGetStorageCreatorName
    curBoxName = @peer.pbBoxName(currentBox)
    boxName    = @peer.pbBoxName(storedBox)
    if storedBox!=currentBox
      if creator
        pbDisplayPaused(_INTL("Box \"{1}\" on {2}'s PC was full.",curBoxName,creator))
      else
        pbDisplayPaused(_INTL("Box \"{1}\" on someone's PC was full.",curBoxName))
      end
      pbDisplayPaused(_INTL("{1} was transferred to box \"{2}\".",pkmn.name,boxName))
    else
      if creator
        pbDisplayPaused(_INTL("{1} was transferred to {2}'s PC.",pkmn.name,creator))
      else
        pbDisplayPaused(_INTL("{1} was transferred to someone's PC.",pkmn.name))
      end
      pbDisplayPaused(_INTL("It was stored in box \"{1}\".",boxName))
    end
  end

  # Register all caught Pokémon in the Pokédex, and store them.
  def pbRecordAndStoreCaughtPokemon
    @caughtPokemon.each do |pkmn|
      pbSeenForm(pkmn)   # In case the form changed upon leaving battle
      # Record the Pokémon's species as owned in the Pokédex
      if !pbPlayer.hasOwned?(pkmn.species)
        pbPlayer.setOwned(pkmn.species)
        if $Trainer.pokedex
          pbDisplayPaused(_INTL("{1}'s data was added to the Pokédex.",pkmn.name))
          @scene.pbShowPokedex(pkmn.species)
        end
      end
      # Record a Shadow Pokémon's species as having been caught
      if pkmn.shadowPokemon?
        pbPlayer.shadowcaught = [] if !pbPlayer.shadowcaught
        pbPlayer.shadowcaught[pkmn.species] = true
      end
      # Store caught Pokémon
      pbStorePokemon(pkmn)
    end
    @caughtPokemon.clear
  end

  # Ball Fetch	
  def pbBallFetch(ball)
    if $BallRetrieved == 0
      $BallRetrieved=ball if ball != 268
    end
  end
	
  #=============================================================================
  # Throw a Poké Ball
  #=============================================================================
  def pbThrowPokeBall(idxBattler,ball,rareness=nil,showPlayer=false)
    # Determine which Pokémon you're throwing the Poké Ball at
    battler = nil
    if opposes?(idxBattler)
      battler = @battlers[idxBattler]
    else
      battler = @battlers[idxBattler].pbDirectOpposing(true)
    end
    if battler.fainted?
      battler.eachAlly do |b|
        battler = b
        break
      end
    end
    # Messages
    itemName = PBItems.getName(ball)
    if battler.fainted?
      if itemName.starts_with_vowel?
        pbDisplay(_INTL("{1} threw an {2}!",pbPlayer.name,itemName))
      else
        pbDisplay(_INTL("{1} threw a {2}!",pbPlayer.name,itemName))
      end
      pbDisplay(_INTL("But there was no target..."))
      return
    end
    if itemName.starts_with_vowel?
      pbDisplayBrief(_INTL("{1} threw an {2}!",pbPlayer.name,itemName))
    else
      pbDisplayBrief(_INTL("{1} threw a {2}!",pbPlayer.name,itemName))
    end
    # Animation of opposing trainer blocking Poké Balls (unless it's a Snag Ball
    # at a Shadow Pokémon)
    if trainerBattle? && !(pbIsSnagBall?(ball) && battler.shadowPokemon?)
      @scene.pbThrowAndDeflect(ball,1)
      pbDisplay(_INTL("The Trainer blocked your Poké Ball! Don't be a thief!"))
      return
    end
    # Calculate the number of shakes (4=capture)
    pkmn = battler.pokemon
    @criticalCapture = false
    numShakes = pbCaptureCalc(pkmn,battler,rareness,ball)
    PBDebug.log("[Threw Poké Ball] #{itemName}, #{numShakes} shakes (4=capture)")
    # Animation of Ball throw, absorb, shake and capture/burst out
    @scene.pbThrow(ball,numShakes,@criticalCapture,battler.index,showPlayer)
    # Outcome message
    case numShakes
    when 0
      pbDisplay(_INTL("Oh no! The Pokémon broke free!"))
      BallHandlers.onFailCatch(ball,self,battler)
	  pbBallFetch(ball)
    when 1
      pbDisplay(_INTL("Aww! It appeared to be caught!"))
      BallHandlers.onFailCatch(ball,self,battler)
	  pbBallFetch(ball)
    when 2
      pbDisplay(_INTL("Aargh! Almost had it!"))
      BallHandlers.onFailCatch(ball,self,battler)
	  pbBallFetch(ball)
    when 3
      pbDisplay(_INTL("Gah! It was so close, too!"))
      BallHandlers.onFailCatch(ball,self,battler)
	  pbBallFetch(ball)
    when 4
      pbDisplayBrief(_INTL("Gotcha! {1} was caught!",pkmn.name))
      @scene.pbThrowSuccess   # Play capture success jingle
      pbRemoveFromParty(battler.index,battler.pokemonIndex)
      # Gain Exp
      if GAIN_EXP_FOR_CAPTURE
        battler.captured = true
        pbGainExp
        battler.captured = false
      end
      battler.pbReset
      if trainerBattle?
        @decision = 1 if pbAllFainted?(battler.index)
      else
        @decision = 4 if pbAllFainted?(battler.index)   # Battle ended by capture
      end
      # Modify the Pokémon's properties because of the capture
      if pbIsSnagBall?(ball)
        pkmn.ot        = pbPlayer.name
        pkmn.trainerID = pbPlayer.id
      end
      BallHandlers.onCatch(ball,self,pkmn)
      pkmn.ballused = pbGetBallType(ball)
      pkmn.makeUnmega if pkmn.mega?
      pkmn.makeUnprimal
      pkmn.pbUpdateShadowMoves if pkmn.shadowPokemon?
      pkmn.pbRecordFirstMoves
      # Morpeko
      if pkmn.species == isConst?(pkmn.species,PBSpecies,:MORPEKO) || pkmn.form!=0
        pkmn.form = 0
      end
      # Reset form
      pkmn.forcedForm = nil if MultipleForms.hasFunction?(pkmn.species,"getForm")
      @peer.pbOnLeavingBattle(self,pkmn,true,true)
      # Make the Poké Ball and data box disappear
      @scene.pbHideCaptureBall(idxBattler)
      # Save the Pokémon for storage at the end of battle
      @caughtPokemon.push(pkmn)
    end
  end

  #=============================================================================
  # Calculate how many shakes a thrown Poké Ball will make (4 = capture)
  #=============================================================================
  def pbCaptureCalc(pkmn,battler,rareness,ball)
    return 4 if $DEBUG && Input.press?(Input::CTRL)
    # Get a rareness if one wasn't provided
    if !rareness
      rareness = pbGetSpeciesData(pkmn.species,pkmn.form,SpeciesRareness)
    end
    # Modify rareness depending on the Poké Ball's effect
    ultraBeast = (battler.isSpecies?(:NIHILEGO) ||
       battler.isSpecies?(:BUZZWOLE) ||
       battler.isSpecies?(:PHEROMOSA) ||
       battler.isSpecies?(:XURKITREE) ||
       battler.isSpecies?(:CELESTEELA) ||
       battler.isSpecies?(:KARTANA) ||
       battler.isSpecies?(:GUZZLORD) ||
       battler.isSpecies?(:POIPOLE) ||
       battler.isSpecies?(:NAGANADEL) ||
       battler.isSpecies?(:STAKATAKA) ||
       battler.isSpecies?(:BLACEPHALON))
    if !ultraBeast || isConst?(ball,PBItems,:BEASTBALL)
      rareness = BallHandlers.modifyCatchRate(ball,rareness,self,battler,ultraBeast)
    else
      rareness /= 10
    end
    # First half of the shakes calculation
    a = battler.totalhp
    b = battler.hp
    x = ((3*a-2*b)*rareness.to_f)/(3*a)
    # Calculation modifiers
    if battler.status==PBStatuses::SLEEP || battler.status==PBStatuses::FROZEN
      x *= 2.5
    elsif battler.status!=PBStatuses::NONE
      x *= 1.5
    end
    x = x.floor
    x = 1 if x<1
    # Definite capture, no need to perform randomness checks
    return 4 if x>=255 || BallHandlers.isUnconditional?(ball,self,battler)
    # Second half of the shakes calculation
    y = ( 65536 / ((255.0/x)**0.1875) ).floor
    # Critical capture check
    if ENABLE_CRITICAL_CAPTURES
      c = 0
      numOwned = $Trainer.pokedexOwned
      if numOwned>600;    c = x*5/12
      elsif numOwned>450; c = x*4/12
      elsif numOwned>300; c = x*3/12
      elsif numOwned>150; c = x*2/12
      elsif numOwned>30;  c = x/12
      end
      # Calculate the number of shakes
      if c>0 && pbRandom(256)<c
        @criticalCapture = true
        return 4 if pbRandom(65536)<y
        return 0
      end
    end
    # Calculate the number of shakes
    numShakes = 0
    for i in 0...4
      break if numShakes<i
      numShakes += 1 if pbRandom(65536)<y
    end
    return numShakes
  end
end
