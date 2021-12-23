#===============================================================================
#
#===============================================================================
def pbLoadTrainer(tr_type, tr_name, tr_version = 0)
  tr_type_data = GameData::TrainerType.try_get(tr_type)
  raise _INTL("Trainer type {1} does not exist.", tr_type) if !tr_type_data
  tr_type = tr_type_data.id
  trainer_data = GameData::Trainer.try_get(tr_type, tr_name, tr_version)
  return (trainer_data) ? trainer_data.to_trainer : nil
end

def pbNewTrainer(tr_type, tr_name, tr_version, save_changes = true)
  party = []
  Settings::MAX_PARTY_SIZE.times do |i|
    if i == 0
      pbMessage(_INTL("Please enter the first Pokémon.", i))
    elsif !pbConfirmMessage(_INTL("Add another Pokémon?"))
      break
    end
    loop do
      species = pbChooseSpeciesList
      if species
        params = ChooseNumberParams.new
        params.setRange(1, GameData::GrowthRate.max_level)
        params.setDefaultValue(10)
        level = pbMessageChooseNumber(_INTL("Set the level for {1} (max. #{params.maxNumber}).",
                                            GameData::Species.get(species).name), params)
        party.push([species, level])
        break
      else
        break if i > 0
        pbMessage(_INTL("This trainer must have at least 1 Pokémon!"))
      end
    end
  end
  trainer = [tr_type, tr_name, [], party, tr_version]
  if save_changes
    trainer_hash = {
      :trainer_type => tr_type,
      :name         => tr_name,
      :version      => tr_version,
      :pokemon      => []
    }
    party.each do |pkmn|
      trainer_hash[:pokemon].push(
        {
          :species => pkmn[0],
          :level   => pkmn[1]
        }
      )
    end
    # Add trainer's data to records
    trainer_hash[:id] = [trainer_hash[:trainer_type], trainer_hash[:name], trainer_hash[:version]]
    GameData::Trainer.register(trainer_hash)
    GameData::Trainer.save
    pbConvertTrainerData
    pbMessage(_INTL("The Trainer's data was added to the list of battles and in PBS/trainers.txt."))
  end
  return trainer
end

def pbConvertTrainerData
  tr_type_names = []
  GameData::TrainerType.each { |t| tr_type_names.push(t.real_name) }
  MessageTypes.setMessagesAsHash(MessageTypes::TrainerTypes, tr_type_names)
  Compiler.write_trainer_types
  Compiler.write_trainers
end

def pbTrainerTypeCheck(trainer_type)
  return true if !$DEBUG
  return true if GameData::TrainerType.exists?(trainer_type)
  if pbConfirmMessage(_INTL("Add new trainer type {1}?", trainer_type.to_s))
    pbTrainerTypeEditorNew(trainer_type.to_s)
  end
  pbMapInterpreter&.command_end
  return false
end

# Called from trainer events to ensure the trainer exists
def pbTrainerCheck(tr_type, tr_name, max_battles, tr_version = 0)
  return true if !$DEBUG
  # Check for existence of trainer type
  pbTrainerTypeCheck(tr_type)
  tr_type_data = GameData::TrainerType.try_get(tr_type)
  return false if !tr_type_data
  tr_type = tr_type_data.id
  # Check for existence of trainer with given ID number
  return true if GameData::Trainer.exists?(tr_type, tr_name, tr_version)
  # Add new trainer
  if pbConfirmMessage(_INTL("Add new trainer variant {1} (of {2}) for {3} {4}?",
                            tr_version, max_battles, tr_type.to_s, tr_name))
    pbNewTrainer(tr_type, tr_name, tr_version)
  end
  return true
end

def pbGetFreeTrainerParty(tr_type, tr_name)
  tr_type_data = GameData::TrainerType.try_get(tr_type)
  raise _INTL("Trainer type {1} does not exist.", tr_type) if !tr_type_data
  tr_type = tr_type_data.id
  256.times do |i|
    return i if !GameData::Trainer.try_get(tr_type, tr_name, i)
  end
  return -1
end

def pbMissingTrainer(tr_type, tr_name, tr_version)
  tr_type_data = GameData::TrainerType.try_get(tr_type)
  raise _INTL("Trainer type {1} does not exist.", tr_type) if !tr_type_data
  tr_type = tr_type_data.id
  if !$DEBUG
    raise _INTL("Can't find trainer ({1}, {2}, ID {3})", tr_type.to_s, tr_name, tr_version)
  end
  message = ""
  if tr_version == 0
    message = _INTL("Add new trainer ({1}, {2})?", tr_type.to_s, tr_name)
  else
    message = _INTL("Add new trainer ({1}, {2}, ID {3})?", tr_type.to_s, tr_name, tr_version)
  end
  cmd = pbMessage(message, [_INTL("Yes"), _INTL("No")], 2)
  pbNewTrainer(tr_type, tr_name, tr_version) if cmd == 0
  return cmd
end
