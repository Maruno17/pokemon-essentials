#===============================================================================
# Load various wild battle music
#===============================================================================
def pbGetWildBattleBGM(_wildParty)   # wildParty is an array of Pokémon objects
  if $PokemonGlobal.nextBattleBGM
    return $PokemonGlobal.nextBattleBGM.clone
  end
  ret = nil
  if !ret
    # Check map metadata
    map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
    music = (map_metadata) ? map_metadata.wild_battle_BGM : nil
    ret = pbStringToAudioFile(music) if music && music != ""
  end
  if !ret
    # Check global metadata
    music = GameData::Metadata.get.wild_battle_BGM
    ret = pbStringToAudioFile(music) if music && music!=""
  end
  ret = pbStringToAudioFile("Battle wild") if !ret
  return ret
end

def pbGetWildVictoryME
  if $PokemonGlobal.nextBattleME
    return $PokemonGlobal.nextBattleME.clone
  end
  ret = pbStringToAudioFile(Settings::WILD_VICTORY_MUSIC)
  ret.name = "../../Audio/ME/"+ret.name
  return ret
end

def pbGetWildCaptureME
  if $PokemonGlobal.nextBattleCaptureME
    return $PokemonGlobal.nextBattleCaptureME.clone
  end
  ret = nil
  if !ret
    # Check map metadata
    map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
    music = (map_metadata) ? map_metadata.wild_capture_ME : nil
    ret = pbStringToAudioFile(music) if music && music != ""
  end
  if !ret
    # Check global metadata
    music = GameData::Metadata.get.wild_capture_ME
    ret = pbStringToAudioFile(music) if music && music!=""
  end
  ret = pbStringToAudioFile("Battle capture success") if !ret
  ret.name = "../../Audio/ME/"+ret.name
  return ret
end

#===============================================================================
# Load/play various trainer battle music
#===============================================================================
def pbPlayTrainerIntroME(trainer_type)
  trainer_type_data = GameData::TrainerType.get(trainer_type)
  return if nil_or_empty?(trainer_type_data.intro_ME)
  bgm = pbStringToAudioFile(trainer_type_data.intro_ME)
  pbMEPlay(bgm)
end

def pbGetTrainerBattleBGM(trainer)   # can be a Player, NPCTrainer or an array of them
  if $PokemonGlobal.nextBattleBGM
    return $PokemonGlobal.nextBattleBGM.clone
  end
  ret = nil
  music = nil
  trainerarray = (trainer.is_a?(Array)) ? trainer : [trainer]
  trainerarray.each do |t|
    trainer_type_data = GameData::TrainerType.get(t.trainer_type)
    music = trainer_type_data.battle_BGM if trainer_type_data.battle_BGM
  end
  ret = pbStringToAudioFile(music) if music && music!=""
  if !ret
    # Check map metadata
    map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
    music = (map_metadata) ? map_metadata.trainer_battle_BGM : nil
    ret = pbStringToAudioFile(music) if music && music != ""
  end
  if !ret
    # Check global metadata
    music = GameData::Metadata.get.trainer_battle_BGM
    if music && music!=""
      ret = pbStringToAudioFile(music)
    end
  end
  ret = pbStringToAudioFile("Battle trainer") if !ret
  return ret
end

def pbGetTrainerBattleBGMFromType(trainertype)
  if $PokemonGlobal.nextBattleBGM
    return $PokemonGlobal.nextBattleBGM.clone
  end
  trainer_type_data = GameData::TrainerType.get(trainertype)
  ret = trainer_type_data.battle_BGM if trainer_type_data.battle_BGM
  if !ret
    # Check map metadata
    map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
    music = (map_metadata) ? map_metadata.trainer_battle_BGM : nil
    ret = pbStringToAudioFile(music) if music && music != ""
  end
  if !ret
    # Check global metadata
    music = GameData::Metadata.get.trainer_battle_BGM
    ret = pbStringToAudioFile(music) if music && music!=""
  end
  ret = pbStringToAudioFile("Battle trainer") if !ret
  return ret
end

def pbGetTrainerVictoryME(trainer)   # can be a Player, NPCTrainer or an array of them
begin
  if $PokemonGlobal.nextBattleME
    return $PokemonGlobal.nextBattleME.clone
  end
  if trainer.is_a?(Array)
    npcTrainer=trainer[0]
  else
    npcTrainer=trainer
  end

  if is_gym_leader(npcTrainer)
    ret = pbStringToAudioFile(Settings::LEADER_VICTORY_MUSIC)
  else
    ret = pbStringToAudioFile(Settings::TRAINER_VICTORY_MUSIC)
  end
  ret.name = "../../Audio/ME/"+ret.name
  return ret
rescue
  ret = pbStringToAudioFile(Settings::TRAINER_VICTORY_MUSIC)
  ret.name = "../../Audio/ME/"+ret.name
  return ret
end

end

GYM_LEADERS=[:LEADER_Brock,:LEADER_Misty, :LEADER_Surge, :LEADER_Erika, :LEADER_Koga, :LEADER_Sabrina, :LEADER_Blaine,
             :LEADER_Giovanni, :ELITEFOUR_Lorelei, :ELITEFOUR_Bruno, :ELITEFOUR_Agatha, :ELITEFOUR_Lance, :CHAMPION,
             :LEADER_Whitney, :LEADER_Kurt, :LEADER_Falkner, :LEADER_Clair, :LEADER_Morty, :LEADER_Pryce, :LEADER_Chuck,
             :LEADER_Jasmine, :CHAMPION_Sinnoh]
def is_gym_leader(trainer)
  return GYM_LEADERS.include?(trainer.trainer_type)
end
