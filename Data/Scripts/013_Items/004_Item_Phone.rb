#===============================================================================
# Register contacts
#===============================================================================
def pbPhoneRegisterNPC(ident, name, mapid, showmessage = true)
  $PokemonGlobal.phoneNumbers = [] if !$PokemonGlobal.phoneNumbers
  exists = pbFindPhoneTrainer(ident, name)
  if exists
    return if exists[0]   # Already visible
    exists[0] = true   # Make visible
  else
    phonenum = [true, ident, name, mapid]
    $PokemonGlobal.phoneNumbers.push(phonenum)
  end
  pbMessage(_INTL("\\me[Register phone]Registered {1} in the Pokégear.", name)) if showmessage
end

def pbPhoneRegister(event, trainertype, trainername)
  $PokemonGlobal.phoneNumbers = [] if !$PokemonGlobal.phoneNumbers
  return if pbFindPhoneTrainer(trainertype, trainername)
  phonenum = []
  phonenum.push(true)
  phonenum.push(trainertype)
  phonenum.push(trainername)
  phonenum.push(0)   # time to next battle
  phonenum.push(0)   # can battle
  phonenum.push(0)   # battle count
  if event
    phonenum.push(event.map.map_id)
    phonenum.push(event.id)
  end
  $PokemonGlobal.phoneNumbers.push(phonenum)
end

def pbPhoneDeleteContact(index)
  $PokemonGlobal.phoneNumbers[index][0] = false       # Remove from contact list
  if $PokemonGlobal.phoneNumbers[index].length == 8
    $PokemonGlobal.phoneNumbers[index][3] = 0                  # Reset countdown
    $PokemonGlobal.phoneNumbers[index][4] = 0                  # Reset countdown
  end
end

def pbPhoneRegisterBattle(message, event, trainertype, trainername, maxbattles)
  return if !$player.has_pokegear           # Can't register without a Pokégear
  return false if !GameData::TrainerType.exists?(trainertype)
  trainertype = GameData::TrainerType.get(trainertype).id
  contact = pbFindPhoneTrainer(trainertype, trainername)
  return if contact && contact[0]              # Existing contact and is visible
  message = _INTL("Let me register you.") if !message
  return if !pbConfirmMessage(message)
  displayname = _INTL("{1} {2}", GameData::TrainerType.get(trainertype).name,
                      pbGetMessageFromHash(MessageTypes::TrainerNames, trainername))
  if contact                          # Previously registered, just make visible
    contact[0] = true
  else                                                         # Add new contact
    pbPhoneRegister(event, trainertype, trainername)
    pbPhoneIncrement(trainertype, trainername, maxbattles)
  end
  pbMessage(_INTL("\\me[Register phone]Registered {1} in the Pokégear.", displayname))
end

#===============================================================================
# Contact information
#===============================================================================
def pbRandomPhoneTrainer
  $PokemonGlobal.phoneNumbers = [] if !$PokemonGlobal.phoneNumbers
  temparray = []
  this_map_metadata = $game_map.metadata
  return nil if !this_map_metadata || !this_map_metadata.town_map_position
  currentRegion = this_map_metadata.town_map_position[0]
  $PokemonGlobal.phoneNumbers.each do |num|
    next if !num[0] || num.length != 8   # if not visible or not a trainer
    next if $game_map.map_id == num[6]   # Can't call if on same map
    caller_map_metadata = GameData::MapMetadata.try_get(num[6])
    next if !caller_map_metadata || !caller_map_metadata.town_map_position
    # Can't call if in different region
    next if caller_map_metadata.town_map_position[0] != currentRegion
    temparray.push(num)
  end
  return nil if temparray.length == 0
  return temparray[rand(temparray.length)]
end

def pbFindPhoneTrainer(tr_type, tr_name)        # Ignores whether visible or not
  return nil if !$PokemonGlobal.phoneNumbers
  $PokemonGlobal.phoneNumbers.each do |num|
    return num if num[1] == tr_type && num[2] == tr_name   # If a match
  end
  return nil
end

def pbHasPhoneTrainer?(tr_type, tr_name)
  return pbFindPhoneTrainer(tr_type, tr_name) != nil
end

def pbPhoneBattleCount(tr_type, tr_name)
  trainer = pbFindPhoneTrainer(tr_type, tr_name)
  return (trainer) ? trainer[5] : 0
end

def pbPhoneReadyToBattle?(tr_type, tr_name)
  trainer = pbFindPhoneTrainer(tr_type, tr_name)
  return (trainer && trainer[4] >= 2)
end

#===============================================================================
# Contact rematch data modifications
#===============================================================================
def pbPhoneIncrement(tr_type, tr_name, maxbattles)
  trainer = pbFindPhoneTrainer(tr_type, tr_name)
  return if !trainer
  trainer[5] += 1 if trainer[5] < maxbattles   # Increment battle count
  trainer[3] = 0   # reset time to can-battle
  trainer[4] = 0   # reset can-battle flag
end

def pbPhoneReset(tr_type, tr_name)
  trainer = pbFindPhoneTrainer(tr_type, tr_name)
  return false if !trainer
  trainer[3] = 0   # reset time to can-battle
  trainer[4] = 0   # reset can-battle flag
  return true
end

def pbSetReadyToBattle(num)
  return if !num[6] || !num[7]
  $game_self_switches[[num[6], num[7], "A"]] = false
  $game_self_switches[[num[6], num[7], "B"]] = true
  $game_map.need_refresh = true
end

#===============================================================================
# Phone-related counters
#===============================================================================
EventHandlers.add(:on_frame_update, :phone_call_counter,
  proc {
    next if !$player&.has_pokegear
    # Reset time to next phone call if necessary
    if !$PokemonGlobal.phoneTime || $PokemonGlobal.phoneTime <= 0
      $PokemonGlobal.phoneTime = rand(20...40) * 60 * Graphics.frame_rate
    end
    # Don't count down various phone times if other things are happening
    $PokemonGlobal.phoneNumbers = [] if !$PokemonGlobal.phoneNumbers
    next if $game_temp.in_menu || $game_temp.in_battle || $game_temp.message_window_showing
    next if $game_player.move_route_forcing || pbMapInterpreterRunning?
    # Count down time to next phone call
    $PokemonGlobal.phoneTime -= 1
    # Count down time to next can-battle for each trainer contact
    if $PokemonGlobal.phoneTime % Graphics.frame_rate == 0   # Every second
      $PokemonGlobal.phoneNumbers.each do |num|
        next if !num[0] || num.length != 8   # if not visible or not a trainer
        # Reset time to next can-battle if necessary
        if num[4] == 0
          num[3] = rand(20...40) * 60   # 20-40 minutes
          num[4] = 1
        end
        # Count down time to next can-battle
        num[3] -= 1
        # Ready to battle
        if num[3] <= 0 && num[4] == 1
          num[4] = 2   # set ready-to-battle flag
          pbSetReadyToBattle(num)
        end
      end
    end
    # Time for a random phone call; generate one
    if $PokemonGlobal.phoneTime <= 0
      # find all trainer phone numbers
      phonenum = pbRandomPhoneTrainer
      if phonenum
        call = pbPhoneGenerateCall(phonenum)
        pbPhoneCall(call, phonenum)
      end
    end
  }
)

#===============================================================================
# Player calls a contact
#===============================================================================
def pbCallTrainer(trtype, trname)
  trainer = pbFindPhoneTrainer(trtype, trname)
  return if !trainer
  # Special NPC contacts
  if trainer.length != 8
    if !pbCommonEvent(trtype)
      pbMessage(_INTL("{1}'s messages not defined.\nCouldn't call common event {2}.", trainer[2], trtype))
    end
    return
  end
  # Trainer contacts
  if $game_map.map_id == trainer[6]
    pbMessage(_INTL("The Trainer is close by.\nTalk to the Trainer in person!"))
    return
  end
  caller_map_metadata = GameData::MapMetadata.try_get(trainer[6])
  this_map_metadata = $game_map.metadata
  if !caller_map_metadata || !caller_map_metadata.town_map_position ||
     !this_map_metadata || !this_map_metadata.town_map_position ||
     caller_map_metadata.town_map_position[0] != this_map_metadata.town_map_position[0]
    pbMessage(_INTL("The Trainer is out of range."))
    return   # Can't call if in different region
  end
  call = pbPhoneGenerateCall(trainer)
  pbPhoneCall(call, trainer)
end

#===============================================================================
# Generate phone message
#===============================================================================
def pbPhoneGenerateCall(phonenum)
  phoneData = pbLoadPhoneData
  # Choose random greeting depending on time of day
  call = pbRandomPhoneItem(phoneData.greetings)
  time = pbGetTimeNow
  if PBDayNight.isMorning?(time)
    modcall = pbRandomPhoneItem(phoneData.greetingsMorning)
    call = modcall if modcall && modcall != ""
  elsif PBDayNight.isEvening?(time)
    modcall = pbRandomPhoneItem(phoneData.greetingsEvening)
    call = modcall if modcall && modcall != ""
  end
  call += "\\m"
  if phonenum[4] == 2 || (rand(2) == 0 && phonenum[4] == 3)
    # If "can battle" is set, make ready to battle
    call += pbRandomPhoneItem(phoneData.battleRequests)
    pbSetReadyToBattle(phonenum)
    phonenum[4] = 3
  elsif rand(4) < 3
    # Choose random body
    call += pbRandomPhoneItem(phoneData.bodies1)
    call += "\\m"
    call += pbRandomPhoneItem(phoneData.bodies2)
  else
    # Choose random generic
    call += pbRandomPhoneItem(phoneData.generics)
  end
  return call
end

def pbRandomPhoneItem(array)
  ret = array[rand(array.length)]
  ret = "" if !ret
  return pbGetMessageFromHash(MessageTypes::PhoneMessages, ret)
end

def pbRandomEncounterSpecies(enc_table)
  return nil if !enc_table || enc_table.length == 0
  len = [enc_table.length, 4].min
  return enc_table[rand(len)][1]
end

def pbEncounterSpecies(phonenum)
  return "" if !phonenum[6] || phonenum[6] == 0
  encounter_data = GameData::Encounter.get(phonenum[6], $PokemonGlobal.encounter_version)
  return "" if !encounter_data
  enc_tables = encounter_data.types
  species = pbRandomEncounterSpecies(enc_tables[:Land])
  if !species
    species = pbRandomEncounterSpecies(enc_tables[:Cave])
    if !species
      species = pbRandomEncounterSpecies(enc_tables[:Water])
    end
  end
  return "" if !species
  return GameData::Species.get(species).name
end

def pbTrainerSpecies(phonenum)
  return "" if !phonenum[0]
  partyid = [0, phonenum[5] - 1].max
  trainer_data = GameData::Trainer.try_get(phonenum[1], phonenum[2], partyid)
  return "" if !trainer_data
  if trainer_data.pokemon.length == 1
    pkmn = trainer_data.pokemon[0][:species]
  else
    pkmn = trainer_data.pokemon[rand(trainer_data.pokemon.length)][:species]
  end
  return GameData::Species.get(pkmn).name
end

def pbTrainerMapName(phonenum)
  return "" if !phonenum[6] || phonenum[6] == 0
  return pbGetMapNameFromId(phonenum[6])
end

#===============================================================================
# The phone call itself
#===============================================================================
def pbPhoneCall(call, phonenum)
  pbMessage(_INTL("......\\wt[5] ......\\1"))
  encspecies     = pbEncounterSpecies(phonenum)
  trainerspecies = pbTrainerSpecies(phonenum)
  trainermap     = pbTrainerMapName(phonenum)
  messages = call.split("\\m")
  messages.length.times do |i|
    messages[i].gsub!(/\\TN/, phonenum[2])
    messages[i].gsub!(/\\TP/, trainerspecies)
    messages[i].gsub!(/\\TE/, encspecies)
    messages[i].gsub!(/\\TM/, trainermap)
    messages[i] += "\\1" if i < messages.length - 1
    pbMessage(messages[i])
  end
  pbMessage(_INTL("Click!\\wt[10]\n......\\wt[5] ......\\1"))
end
