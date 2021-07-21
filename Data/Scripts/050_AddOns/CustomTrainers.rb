# # ------------------------------------------------------------------------------
# # Written by Stochastic, except for customTrainerBattle method which is a
# # modified version of pbTrainerBattle method.
# # ------------------------------------------------------------------------------
#
# BR_DRAW = 5
# BR_LOSS = 2
# BR_WIN = 1
#
# # ------------------------------------------------------------------------------
# # species - Name of the species, e.g. "PIKACHU"
# # level - Level
# # moveset - Optional. Array of moves, e.g. [:MUDSLAP, :THUNDERBOLT, :VINEWHIP]
# # If not specified, pokemon will be created with moves learned by leveling.
# # The pokemon doesn't need to be able to learn the given moves, they can be
# # arbitary.
# # ------------------------------------------------------------------------------
# def createPokemon(species, level, helditem=nil, moveset=nil, ability=nil, form=nil, nature=nil, hpev=nil, atkev=nil, defev=nil, speev=nil, spaev=nil, spdev=nil)
#   begin
#     poke = Pokemon.new(species, level)
#     poke.item=(helditem) if helditem
#     poke.moves = convertMoves(moveset) if moveset
#     poke.ability=(ability) if ability
#     poke.form = form if form
#     poke.shiny  = false
#     poke.nature =(nature) if nature
#     poke.happiness=0
#     poke.iv[0]=hpev
#     poke.iv[1]=atkev
#     poke.iv[2]=defev
#     poke.iv[3]=speev
#     poke.iv[4]=spaev
#     poke.iv[5]=spdev
#
#     poke.calc_stats
#     return poke
#   end
# end
#
# def convertMoves(moves)
#   moves.map! {|m| PBMove.new(getMoveID(m))}
#   return moves
# end
#
# # provide move like this; :TACKLE
# def getMoveID(move)
#   return getConst(PBMoves,move)
# end
#
# # ------------------------------------------------------------------------------
# # Creates a trainer with specified id, name, party, and optionally, items.
# # Does not depend on defined trainers, only on trainer types
# # ------------------------------------------------------------------------------
# def createTrainer(trainerid,trainername,party,items=[])
#
#   name = pbGetMessageFromHash(MessageTypes::TrainerNames, trainername)
#
#   trainer_hash = {
#     :id_number    => 999,
#     :trainer_type => trainerid,
#     :name         => name,
#     :version      => 0,
#     :pokemon      => party,
#     :items        => items
#   }
#   opponent = GameData::Trainer.new(trainer_hash)
#   #opponent.setForeignID($Trainer) if $Trainer
#   # opponent.party = party
#   return [opponent.to_trainer,items,party]
# end
#
# def init_trainer(trainer_data)
#     return (trainer_data) ? trainer_data.to_trainer : nil
# end
#
# # ------------------------------------------------------------------------------
# # Initiates trainer battle. This is a modified pbTrainerBattle method.
# #
# # trainer - custom PokeBattle_Trainer provided by the user
# # endspeech - what the trainer says in-battle when defeated
# # doublebattle - Optional. Set it to true if you want a double battle
# # canlose - Optional. Set it to true if you want your party to be healed after battle,and if you don't want to be sent to a pokemon center if you lose
# # ------------------------------------------------------------------------------
#
# def customTrainerBattle(trainer,endSpeech,doubleBattle=false,canLose=false,outcomeVar=1)
#   # If there is another NPC trainer who spotted the player at the same time, and
#   # it is possible to have a double battle (the player has 2+ able Pokémon or
#   # has a partner trainer), then record this first NPC trainer into
#   # $PokemonTemp.waitingTrainer and end this method. That second NPC event will
#   # then trigger and cause the battle to happen against this first trainer and
#   # themselves.
#   if !$PokemonTemp.waitingTrainer && pbMapInterpreterRunning? &&
#     ($Trainer.able_pokemon_count > 1 ||
#       ($Trainer.able_pokemon_count > 0 && $PokemonGlobal.partner))
#     thisEvent = pbMapInterpreter.get_character(0)
#     # Find all other triggered trainer events
#     triggeredEvents = $game_player.pbTriggeredTrainerEvents([2],false)
#     otherEvent = []
#     for i in triggeredEvents
#       next if i.id==thisEvent.id
#       next if $game_self_switches[[$game_map.map_id,i.id,"A"]]
#       otherEvent.push(i)
#     end
#     return false if !trainer
#     Events.onTrainerPartyLoad.trigger(nil,trainer)
#     # If there is exactly 1 other triggered trainer event, and this trainer has
#     # 6 or fewer Pokémon, record this trainer for a double battle caused by the
#     # other triggered trainer event
#     if otherEvent.length == 1 && trainer.party.length <= Settings::MAX_PARTY_SIZE
#       trainer.lose_text = endSpeech if endSpeech && !endSpeech.empty?
#       $PokemonTemp.waitingTrainer = [trainer, thisEvent.id]
#       return false
#     end
#   end
#   # Set some battle rules
#   setBattleRule("outcomeVar",outcomeVar) if outcomeVar!=1
#   setBattleRule("canLose") if canLose
#   setBattleRule("double") if doubleBattle || $PokemonTemp.waitingTrainer
#   # Perform the battle
#   if $PokemonTemp.waitingTrainer
#     decision = pbTrainerBattleCore($PokemonTemp.waitingTrainer[0],
#                                    [trainer[0].trainer_type,trainer[0].name,endSpeech]
#     )
#   else
#     decision = pbTrainerCustomBattleCore(trainer,[trainer[0].trainer_type,trainer[0].name,endSpeech])  #trainerPartyID
#   end
#   # Finish off the recorded waiting trainer, because they have now been battled
#   if decision==1 && $PokemonTemp.waitingTrainer   # Win
#     pbMapInterpreter.pbSetSelfSwitch($PokemonTemp.waitingTrainer[1], "A", true)
#   end
#   $PokemonTemp.waitingTrainer = nil
#   # Return true if the player won the battle, and false if any other result
#   return (decision==1)
# end
#
#
# def pbTrainerCustomBattleCore(trainer,*args)
#   outcomeVar = $PokemonTemp.battleRules["outcomeVar"] || 1
#   canLose    = $PokemonTemp.battleRules["canLose"] || false
#   # Skip battle if the player has no able Pokémon, or if holding Ctrl in Debug mode
#   if $Trainer.able_pokemon_count == 0 || ($DEBUG && Input.press?(Input::CTRL))
#     pbMessage(_INTL("SKIPPING BATTLE...")) if $DEBUG
#     pbMessage(_INTL("AFTER WINNING...")) if $DEBUG && $Trainer.able_pokemon_count > 0
#     pbSet(outcomeVar,($Trainer.able_pokemon_count == 0) ? 0 : 1)   # Treat it as undecided/a win
#     $PokemonTemp.clearBattleRules
#     $PokemonGlobal.nextBattleBGM       = nil
#     $PokemonGlobal.nextBattleME        = nil
#     $PokemonGlobal.nextBattleCaptureME = nil
#     $PokemonGlobal.nextBattleBack      = nil
#     pbMEStop
#     return ($Trainer.able_pokemon_count == 0) ? 0 : 1   # Treat it as undecided/a win
#   end
#   # Record information about party Pokémon to be used at the end of battle (e.g.
#   # comparing levels for an evolution check)
#   Events.onStartBattle.trigger(nil)
#   # Generate trainers and their parties based on the arguments given
#   foeTrainers    = []
#   foeItems       = []
#   foeEndSpeeches = []
#   foeParty       = []
#   foePartyStarts = []
#   for arg in args
#     if arg.is_a?(NPCTrainer)
#       foeTrainers.push(arg)
#       foePartyStarts.push(foeParty.length)
#       arg.party.each { |pkmn| foeParty.push(pkmn) }
#       foeEndSpeeches.push(arg.lose_text)
#       foeItems.push(arg.items)
#     elsif arg.is_a?(Array)   # [trainer type, trainer name, ID, speech (optional)]
#       pbMissingTrainer(arg[0],arg[1],arg[2]) if !trainer
#       return 0 if !trainer
#       Events.onTrainerPartyLoad.trigger(nil,trainer)
#       foeTrainers.push(trainer)
#       foePartyStarts.push(foeParty.length)
#       trainer.party.each { |pkmn| foeParty.push(pkmn) }
#       foeEndSpeeches.push(arg[3] || trainer.lose_text)
#       foeItems.push(trainer.items)
#     else
#       raise _INTL("Expected NPCTrainer or array of trainer data, got {1}.", arg)
#     end
#   end
#   # Calculate who the player trainer(s) and their party are
#   playerTrainers    = [$Trainer]
#   playerParty       = $Trainer.party
#   playerPartyStarts = [0]
#   room_for_partner = (foeParty.length > 1)
#   if !room_for_partner && $PokemonTemp.battleRules["size"] &&
#     !["single", "1v1", "1v2", "1v3"].include?($PokemonTemp.battleRules["size"])
#     room_for_partner = true
#   end
#   if $PokemonGlobal.partner && !$PokemonTemp.battleRules["noPartner"] && room_for_partner
#     ally = NPCTrainer.new($PokemonGlobal.partner[1], $PokemonGlobal.partner[0])
#     ally.id    = $PokemonGlobal.partner[2]
#     ally.party = $PokemonGlobal.partner[3]
#     playerTrainers.push(ally)
#     playerParty = []
#     $Trainer.party.each { |pkmn| playerParty.push(pkmn) }
#     playerPartyStarts.push(playerParty.length)
#     ally.party.each { |pkmn| playerParty.push(pkmn) }
#     setBattleRule("double") if !$PokemonTemp.battleRules["size"]
#   end
#   # Create the battle scene (the visual side of it)
#   scene = pbNewBattleScene
#   # Create the battle class (the mechanics side of it)
#   battle = PokeBattle_Battle.new(scene,playerParty,foeParty,playerTrainers,foeTrainers)
#   battle.party1starts = playerPartyStarts
#   battle.party2starts = foePartyStarts
#   battle.items        = foeItems
#   battle.endSpeeches  = foeEndSpeeches
#   # Set various other properties in the battle class
#   pbPrepareBattle(battle)
#   $PokemonTemp.clearBattleRules
#   # End the trainer intro music
#   Audio.me_stop
#   # Perform the battle itself
#   decision = 0
#   pbBattleAnimation(pbGetTrainerBattleBGM(foeTrainers),(battle.singleBattle?) ? 1 : 3,foeTrainers) {
#     pbSceneStandby {
#       decision = battle.pbStartBattle
#     }
#     pbAfterBattle(decision,canLose)
#   }
#   Input.update
#   # Save the result of the battle in a Game Variable (1 by default)
#   #    0 - Undecided or aborted
#   #    1 - Player won
#   #    2 - Player lost
#   #    3 - Player or wild Pokémon ran from battle, or player forfeited the match
#   #    5 - Draw
#   pbSet(outcomeVar,decision)
#   return decision
# end
