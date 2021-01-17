#===============================================================================
# Wild encounters editor
#===============================================================================
def pbEncounterEditorTypes(enc,enccmd)
  commands = []
  indexes = []
  haveblank = false
  if enc
    commands.push(_INTL("Density: {1},{2},{3}",
       enc[0][EncounterTypes::Land],
       enc[0][EncounterTypes::Cave],
       enc[0][EncounterTypes::Water]))
    indexes.push(-2)
    for i in 0...EncounterTypes::EnctypeChances.length
      if enc[1][i]
        commands.push(EncounterTypes::Names[i])
        indexes.push(i)
      else
        haveblank = true
      end
    end
  else
    commands.push(_INTL("Density: Not Defined Yet"))
    indexes.push(-2)
    haveblank = true
  end
  if haveblank
    commands.push(_INTL("[New Encounter Type]"))
    indexes.push(-3)
  end
  enccmd.x        = 0
  enccmd.y        = 0
  enccmd.height   = Graphics.height if enccmd.height>Graphics.height
  enccmd.z        = 99999
  enccmd.commands = commands
  enccmd.active   = true
  enccmd.index    = 0
  enccmd.visible  = true
  command = 0
  loop do
    Graphics.update
    Input.update
    enccmd.update
    if Input.trigger?(Input::A) && indexes[enccmd.index]>=0
      if pbConfirmMessage(_INTL("Delete the encounter type {1}?",commands[enccmd.index]))
        enc[1][indexes[enccmd.index]] = nil
        commands.delete_at(enccmd.index)
        indexes.delete_at(enccmd.index)
        enccmd.commands = commands
        if enccmd.index>=enccmd.commands.length
          enccmd.index = enccmd.commands.length
        end
      end
    elsif Input.trigger?(Input::B)
      command = -1
      break
    elsif Input.trigger?(Input::C) || (enccmd.doubleclick? rescue false)
      command = enccmd.index
      break
    end
  end
  ret = command
  enccmd.active = false
  return (ret<0) ? -1 : indexes[ret]
end

def pbNewEncounterType(enc)
  cmdwin = pbListWindow([])
  commands  =[]
  indexes = []
  for i in 0...EncounterTypes::EnctypeChances.length
    dogen = false
    if !enc[1][i]
      if i==0
        dogen = true unless enc[1][EncounterTypes::Cave]
      elsif i==1
        dogen = true unless enc[1][EncounterTypes::Land] ||
                            enc[1][EncounterTypes::LandMorning] ||
                            enc[1][EncounterTypes::LandDay] ||
                            enc[1][EncounterTypes::LandNight] ||
                            enc[1][EncounterTypes::BugContest]
      else
        dogen = true
      end
    end
    if dogen
      commands.push(EncounterTypes::Names[i])
      indexes.push(i)
    end
  end
  ret = pbCommands2(cmdwin,commands,-1)
  ret = (ret<0) ? -1 : indexes[ret]
  if ret>=0
    chances = EncounterTypes::EnctypeChances[ret]
    enc[1][ret] = []
    chances.length.times do
      enc[1][ret].push([1,5,5])
    end
  end
  cmdwin.dispose
  return ret
end

def pbEditEncounterType(enc,etype)
  commands = []
  cmdwin = pbListWindow([])
  chances = EncounterTypes::EnctypeChances[etype]
  chancetotal = 0
  chances.each { |a| chancetotal += a }
  enctype = enc[1][etype]
  for i in 0...chances.length
    enctype[i] = [1,5,5] if !enctype[i]
  end
  ret = 0
  loop do
    commands.clear
    for i in 0...enctype.length
      ch = chances[i]
      ch = sprintf("%.1f",100.0*chances[i]/chancetotal) if chancetotal!=100
      if enctype[i][1]==enctype[i][2]
        commands.push(_INTL("{1}% {2} (Lv.{3})", ch,
           GameData::Species.get(enctype[i][0]).real_name, enctype[i][1]))
      else
        commands.push(_INTL("{1}% {2} (Lv.{3}-Lv.{4})", ch,
           GameData::Species.get(enctype[i][0]).real_name, enctype[i][1], enctype[i][2]))
      end
    end
    ret = pbCommands2(cmdwin,commands,-1,ret)
    break if ret<0
    species = pbChooseSpeciesList(enctype[ret][0])
    next if !species
    enctype[ret][0] = species
    mLevel = PBExperience.maxLevel
    params = ChooseNumberParams.new
    params.setRange(1,mLevel)
    params.setDefaultValue(enctype[ret][1])
    minlevel = pbMessageChooseNumber(_INTL("Set the minimum level."),params)
    params = ChooseNumberParams.new
    params.setRange(minlevel,mLevel)
    params.setDefaultValue(minlevel)
    maxlevel = pbMessageChooseNumber(_INTL("Set the maximum level."),params)
    enctype[ret][1] = minlevel
    enctype[ret][2] = maxlevel
  end
  cmdwin.dispose
end

def pbEncounterEditorDensity(enc)
  params = ChooseNumberParams.new
  params.setRange(0,100)
  params.setDefaultValue(enc[0][EncounterTypes::Land])
  enc[0][EncounterTypes::Land] = pbMessageChooseNumber(
     _INTL("Set the density of Pokémon on land (default {1}).",
     EncounterTypes::EnctypeDensities[EncounterTypes::Land]),params)
  params = ChooseNumberParams.new
  params.setRange(0,100)
  params.setDefaultValue(enc[0][EncounterTypes::Cave])
  enc[0][EncounterTypes::Cave] = pbMessageChooseNumber(
     _INTL("Set the density of Pokémon in caves (default {1}).",
     EncounterTypes::EnctypeDensities[EncounterTypes::Cave]),params)
  params = ChooseNumberParams.new
  params.setRange(0,100)
  params.setDefaultValue(enc[0][EncounterTypes::Water])
  enc[0][EncounterTypes::Water] = pbMessageChooseNumber(
      _INTL("Set the density of Pokémon on water (default {1}).",
      EncounterTypes::EnctypeDensities[EncounterTypes::Water]),params)
  for i in 0...EncounterTypes::EnctypeCompileDens.length
    t = EncounterTypes::EnctypeCompileDens[i]
    next if !t || t==0
    enc[0][i] = enc[0][EncounterTypes::Land] if t==1
    enc[0][i] = enc[0][EncounterTypes::Cave] if t==2
    enc[0][i] = enc[0][EncounterTypes::Water] if t==3
  end
end

def pbEncounterEditorMap(encdata,map)
  enccmd = pbListWindow([])
  # This window displays the help text
  enchelp = Window_UnformattedTextPokemon.new("")
  enchelp.x      = Graphics.width/2
  enchelp.y      = 0
  enchelp.width  = Graphics.width/2 - 32
  enchelp.height = 96
  enchelp.z      = 99999
  mapinfos = load_data("Data/MapInfos.rxdata")
  mapname = mapinfos[map].name
  loop do
    enc = encdata[map]
    enchelp.text = _ISPRINTF("{1:03d}: {2:s}\r\nChoose a method",map,mapname)
    choice = pbEncounterEditorTypes(enc,enccmd)
    if !enc
      enc = [EncounterTypes::EnctypeDensities.clone,[]]
      encdata[map] = enc
    end
    if choice==-2
      pbEncounterEditorDensity(enc)
    elsif choice==-1
      break
    elsif choice==-3
      ret = pbNewEncounterType(enc)
      if ret>=0
        enchelp.text = _ISPRINTF("{1:03d}: {2:s}\r\n{3:s}",map,mapname,EncounterTypes::Names[ret])
        pbEditEncounterType(enc,ret)
      end
    else
      enchelp.text = _ISPRINTF("{1:03d}: {2:s}\r\n{3:s}",map,mapname,EncounterTypes::Names[choice])
      pbEditEncounterType(enc,choice)
    end
  end
  if encdata[map][1].length==0
    encdata[map] = nil
  end
  enccmd.dispose
  enchelp.dispose
  Input.update
end



#===============================================================================
# Trainer type editor
#===============================================================================
def pbTrainerTypeEditor
  trainer_type_properties = [
    [_INTL("Internal Name"),   ReadOnlyProperty,        _INTL("Internal name that is used as a symbol like :XXX.")],
    [_INTL("Trainer Name"),    StringProperty,          _INTL("Name of the trainer type as displayed by the game.")],
    [_INTL("Base Money"),      LimitProperty.new(9999), _INTL("Player earns this much money times the highest level among the trainer's Pokémon.")],
    [_INTL("Battle BGM"),      BGMProperty,             _INTL("BGM played in battles against trainers of this type.")],
    [_INTL("Battle End ME"),   MEProperty,              _INTL("ME played when player wins battles against trainers of this type.")],
    [_INTL("Battle Intro ME"), MEProperty,              _INTL("ME played before battles against trainers of this type.")],
    [_INTL("Gender"),          EnumProperty.new([
       _INTL("Male"), _INTL("Female"), _INTL("Undefined")]),
                                                        _INTL("Gender of this Trainer type.")],
    [_INTL("Skill Level"),     LimitProperty.new(9999), _INTL("Skill level of this Trainer type.")],
    [_INTL("Skill Code"),      StringProperty,          _INTL("Letters/phrases representing AI modifications of trainers of this type.")],
  ]
  pbListScreenBlock(_INTL("Trainer Types"), TrainerTypeLister.new(0, true)) { |button, tr_type|
    if tr_type
      if button == Input::A
        if tr_type.is_a?(Symbol)
          if pbConfirmMessageSerious("Delete this trainer type?")
            id_number = GameData::TrainerType.get(tr_type).id_number
            GameData::TrainerType::DATA.delete(tr_type)
            GameData::TrainerType::DATA.delete(id_number)
            GameData::TrainerType.save
            pbConvertTrainerData
            pbMessage(_INTL("The Trainer type was deleted."))
          end
        end
      elsif button == Input::C
        if tr_type.is_a?(Symbol)
          t_data = GameData::TrainerType.get(tr_type)
          data = [
            t_data.id.to_s,
            t_data.real_name,
            t_data.base_money,
            t_data.battle_BGM,
            t_data.victory_ME,
            t_data.intro_ME,
            t_data.gender,
            t_data.skill_level,
            t_data.skill_code
          ]
          if pbPropertyList(t_data.id.to_s, data, trainer_type_properties, true)
            # Construct trainer type hash
            type_hash = {
              :id_number   => t_data.id_number,
              :id          => t_data.id,
              :name        => line[1],
              :base_money  => line[2],
              :battle_BGM  => line[3],
              :victory_ME  => line[4],
              :intro_ME    => line[5],
              :gender      => line[6],
              :skill_level => line[7],
              :skill_code  => line[8]
            }
            # Add trainer type's data to records
            GameData::TrainerType::DATA[t_data.id_number] = GameData::TrainerType::DATA[t_data.id] = GameData::TrainerType.new(type_hash)
            GameData::TrainerType.save
            pbConvertTrainerData
          end
        else   # Add a new trainer type
          pbTrainerTypeEditorNew(nil)
        end
      end
    end
  }
end

def pbTrainerTypeEditorNew(default_name)
  # Get an unused ID number for the new item
  max_id = 0
  GameData::TrainerType.each { |t| max_id = t.id_number if max_id < t.id_number }
  id_number = max_id + 1
  # Choose a name
  name = pbMessageFreeText(_INTL("Please enter the trainer type's name."),
     (default_name) ? default_name.gsub(/_+/, " ") : "", false, 30)
  if name == ""
    return nil if !default_name
    name = default_name
  end
  # Generate an ID based on the item name
  id = name.gsub(/é/, "e")
  id = id.gsub(/[^A-Za-z0-9_]/, "")
  id = id.upcase
  if id.length == 0
    id = sprintf("T_%03d", id_number)
  elsif !id[0, 1][/[A-Z]/]
    id = "T_" + id
  end
  if GameData::TrainerType.exists?(id)
    for i in 1..100
      trial_id = sprintf("%s_%d", id, i)
      next if GameData::TrainerType.exists?(trial_id)
      id = trial_id
      break
    end
  end
  if GameData::TrainerType.exists?(id)
    pbMessage(_INTL("Failed to create the trainer type. Choose a different name."))
    return nil
  end
  # Choose a gender
  gender = pbMessage(_INTL("Is the Trainer male, female or undefined?"), [
     _INTL("Male"), _INTL("Female"), _INTL("Undefined")], 0)
  # Choose a base money value
  params = ChooseNumberParams.new
  params.setRange(0, 255)
  params.setDefaultValue(30)
  base_money = pbMessageChooseNumber(_INTL("Set the money per level won for defeating the Trainer."), params)
  # Construct trainer type hash
  tr_type_hash = {
    :id_number   => id_number,
    :id          => id.to_sym,
    :name        => name,
    :base_money  => base_money,
    :gender      => gender
  }
  # Add trainer type's data to records
  GameData::TrainerType::DATA[id_number] = GameData::TrainerType::DATA[id.to_sym] = GameData::TrainerType.new(tr_type_hash)
  GameData::TrainerType.save
  pbConvertTrainerData
  pbMessage(_INTL("The trainer type {1} was created (ID: {2}).", name, id.to_s))
  pbMessage(_ISPRINTF("Put the Trainer's graphic (trainer{1:s}.png or trainer{2:03d}.png) in Graphics/Trainers, or it will be blank.",
     id, id_number))
  return id.to_sym
end



#===============================================================================
# Individual trainer editor
#===============================================================================
module TrainerBattleProperty
  NUM_ITEMS = 8

  def self.set(settingname, oldsetting)
    return nil if !oldsetting
    properties = [
       [_INTL("Trainer Type"), TrainerTypeProperty,     _INTL("Name of the trainer type for this Trainer.")],
       [_INTL("Trainer Name"), StringProperty,          _INTL("Name of the Trainer.")],
       [_INTL("Version"),      LimitProperty.new(9999), _INTL("Number used to distinguish Trainers with the same name and trainer type.")],
       [_INTL("Lose Text"),    StringProperty,          _INTL("Message shown in battle when the Trainer is defeated.")]
    ]
    MAX_PARTY_SIZE.times do |i|
      properties.push([_INTL("Pokémon {1}", i + 1), TrainerPokemonProperty, _INTL("A Pokémon owned by the Trainer.")])
    end
    NUM_ITEMS.times do |i|
      properties.push([_INTL("Item {1}", i + 1), ItemProperty, _INTL("An item used by the Trainer during battle.")])
    end
    return nil if !pbPropertyList(settingname, oldsetting, properties, true)
    oldsetting = nil if !oldsetting[0]
    return oldsetting
  end

  def self.format(value)
    return value.inspect
  end
end



def pbTrainerBattleEditor
  modified = false
  pbListScreenBlock(_INTL("Trainer Battles"), TrainerBattleLister.new(0, true)) { |button, trainer_id|
    if trainer_id
      if button == Input::A
        if trainer_id.is_a?(Array)
          if pbConfirmMessageSerious("Delete this trainer battle?")
            tr_data = GameData::Trainer::DATA[trainer_id]
            GameData::Trainer::DATA.delete(trainer_id)
            GameData::Trainer::DATA.delete(tr_data.id_number)
            modified = true
            pbMessage(_INTL("The Trainer battle was deleted."))
          end
        end
      elsif button == Input::C
        if trainer_id.is_a?(Array)   # Edit existing trainer
          tr_data = GameData::Trainer::DATA[trainer_id]
          old_type = tr_data.trainer_type
          old_name = tr_data.real_name
          old_version = tr_data.version
          data = [
            tr_data.trainer_type,
            tr_data.real_name,
            tr_data.version,
            tr_data.real_lose_text
          ]
          for i in 0...MAX_PARTY_SIZE
            data.push(tr_data.pokemon[i])
          end
          for i in 0...TrainerBattleProperty::NUM_ITEMS
            data.push(tr_data.items[i])
          end
          loop do
            data = TrainerBattleProperty.set(tr_data.real_name, data)
            break if !data
            party = []
            items = []
            for i in 0...MAX_PARTY_SIZE
              party.push(data[4 + i]) if data[4 + i] && data[4 + i][:species]
            end
            for i in 0...TrainerBattleProperty::NUM_ITEMS
              items.push(data[4 + MAX_PARTY_SIZE + i]) if data[4 + MAX_PARTY_SIZE + i]
            end
            if !data[0]
              pbMessage(_INTL("Can't save. No trainer type was chosen."))
            elsif !data[1] || data[1].empty?
              pbMessage(_INTL("Can't save. No name was entered."))
            elsif party.length == 0
              pbMessage(_INTL("Can't save. The Pokémon list is empty."))
            else
              trainer_hash = {
                :id           => tr_data.id_number,
                :trainer_type => data[0],
                :name         => data[1],
                :version      => data[2],
                :lose_text    => data[3],
                :pokemon      => party,
                :items        => items
              }
              # Add trainer type's data to records
              key = [data[0], data[1], data[2]]
              GameData::Trainer::DATA[tr_data.id_number] = GameData::Trainer::DATA[key] = GameData::Trainer.new(trainer_hash)
              if data[0] != old_type || data[1] != old_name || data[2] != old_version
                GameData::Trainer::DATA.delete([old_type, old_name, old_version])
              end
              modified = true
              break
            end
          end
        else   # New trainer
          tr_type = nil
          ret = pbMessage(_INTL("First, define the new trainer's type."), [
             _INTL("Use existing type"),
             _INTL("Create new type"),
             _INTL("Cancel")], 3)
          case ret
          when 0
            tr_type = pbListScreen(_INTL("TRAINER TYPE"), TrainerTypeLister.new(0, false))
          when 1
            tr_type = pbTrainerTypeEditorNew(nil)
          else
            next
          end
          next if !tr_type
          tr_name = pbMessageFreeText(_INTL("Now enter the trainer's name."), "", false, 30)
          next if tr_name == ""
          tr_version = pbGetFreeTrainerParty(tr_type, tr_name)
          if tr_version < 0
            pbMessage(_INTL("There is no room to create a trainer of that type and name."))
            next
          end
          t = pbNewTrainer(tr_type, tr_name, tr_version, false)
          if t
            trainer_hash = {
              :id           => GameData::Trainer::HASH.keys.length / 2,
              :trainer_type => tr_type,
              :name         => tr_name,
              :version      => tr_version,
              :pokemon      => []
            }
            t[3].each do |pkmn|
              trainer_hash[:pokemon].push({
                :species => pkmn[0],
                :level   => pkmn[1]
              })
            end
            # Add trainer's data to records
            key = [tr_type, tr_name, tr_version]
            GameData::Trainer::DATA[trainer_hash[:id]] = GameData::Trainer::DATA[key] = GameData::Trainer.new(trainer_hash)
            pbMessage(_INTL("The Trainer battle was added."))
            modified = true
          end
        end
      end
    end
  }
  if modified && pbConfirmMessage(_INTL("Save changes?"))
    GameData::Trainer.save
    pbConvertTrainerData
  else
    GameData::Trainer.load
  end
end



#===============================================================================
# Trainer Pokémon editor
#===============================================================================
module TrainerPokemonProperty
  def self.set(settingname,initsetting)
    initsetting = {:species => nil, :level => 10} if !initsetting
    oldsetting = [
      initsetting[:species],
      initsetting[:level],
      initsetting[:name],
      initsetting[:form],
      initsetting[:gender],
      initsetting[:shininess],
      initsetting[:shadowness]
    ]
    Pokemon::MAX_MOVES.times do |i|
      oldsetting.push((initsetting[:moves]) ? initsetting[:moves][i] : nil)
    end
    oldsetting.concat([
      initsetting[:ability_flag],
      initsetting[:item],
      initsetting[:nature],
      initsetting[:iv],
      initsetting[:ev],
      initsetting[:happiness],
      initsetting[:poke_ball]
    ])
    max_level = PBExperience.maxLevel
    pkmn_properties = [
       [_INTL("Species"),   SpeciesProperty,                         _INTL("Species of the Pokémon.")],
       [_INTL("Level"),     NonzeroLimitProperty.new(max_level),     _INTL("Level of the Pokémon (1-{1}).", max_level)],
       [_INTL("Name"),      StringProperty,                          _INTL("Name of the Pokémon.")],
       [_INTL("Form"),      LimitProperty2.new(999),                 _INTL("Form of the Pokémon.")],
       [_INTL("Gender"),    GenderProperty.new,                      _INTL("Gender of the Pokémon.")],
       [_INTL("Shiny"),     BooleanProperty2,                        _INTL("If set to true, the Pokémon is a different-colored Pokémon.")],
       [_INTL("Shadow"),    BooleanProperty2,                        _INTL("If set to true, the Pokémon is a Shadow Pokémon.")]
    ]
    Pokemon::MAX_MOVES.times do |i|
      pkmn_properties.push([_INTL("Move {1}", i + 1), MovePropertyForSpecies.new(oldsetting), _INTL("A move known by the Pokémon. Leave all moves blank (use Z key to delete) for a wild moveset.")])
    end
    pkmn_properties.concat([
       [_INTL("Ability"),   LimitProperty2.new(99),                  _INTL("Ability flag. 0=first ability, 1=second ability, 2-5=hidden ability.")],
       [_INTL("Held item"), ItemProperty,                            _INTL("Item held by the Pokémon.")],
       [_INTL("Nature"),    NatureProperty,                          _INTL("Nature of the Pokémon.")],
       [_INTL("IVs"),       IVsProperty.new(Pokemon::IV_STAT_LIMIT), _INTL("Individual values for each of the Pokémon's stats.")],
       [_INTL("EVs"),       EVsProperty.new(Pokemon::EV_STAT_LIMIT), _INTL("Effort values for each of the Pokémon's stats.")],
       [_INTL("Happiness"), LimitProperty2.new(255),                 _INTL("Happiness of the Pokémon (0-255).")],
       [_INTL("Poké Ball"), BallProperty.new(oldsetting),            _INTL("The kind of Poké Ball the Pokémon is kept in.")]
    ])
    pbPropertyList(settingname, oldsetting, pkmn_properties, false)
    return nil if !oldsetting[0]   # Species is nil
    ret = {
      :species      => oldsetting[0],
      :level        => oldsetting[1],
      :name         => oldsetting[2],
      :form         => oldsetting[3],
      :gender       => oldsetting[4],
      :shininess    => oldsetting[5],
      :shadowness   => oldsetting[6],
      :ability_flag => oldsetting[7 + Pokemon::MAX_MOVES],
      :item         => oldsetting[8 + Pokemon::MAX_MOVES],
      :nature       => oldsetting[9 + Pokemon::MAX_MOVES],
      :iv           => oldsetting[10 + Pokemon::MAX_MOVES],
      :ev           => oldsetting[11 + Pokemon::MAX_MOVES],
      :happiness    => oldsetting[12 + Pokemon::MAX_MOVES],
      :poke_ball    => oldsetting[13 + Pokemon::MAX_MOVES],
    }
    moves = []
    Pokemon::MAX_MOVES.times do |i|
      moves.push(oldsetting[7 + i])
    end
    moves.uniq!
    moves.compact!
    ret[:moves] = moves
    return ret
  end

  def self.format(value)
    return "-" if !value || !value[:species]
    return sprintf("%s,%d", GameData::Species.get(value[:species]).name, value[:level])
  end
end



#===============================================================================
# Metadata editor
#===============================================================================
def pbMetadataScreen(map_id = 0)
  loop do
    map_id = pbListScreen(_INTL("SET METADATA"), MapLister.new(map_id, true))
    break if map_id < 0
    pbEditMetadata(map_id)
  end
end

def pbEditMetadata(map_id = 0)
  mapinfos = pbLoadRxData("Data/MapInfos")
  data = []
  if map_id == 0   # Global metadata
    map_name = _INTL("Global Metadata")
    metadata = GameData::Metadata.get
    properties = GameData::Metadata.editor_properties
  else   # Map metadata
    map_name = mapinfos[map_id].name
    metadata = GameData::MapMetadata.get(map_id)
    properties = GameData::MapMetadata.editor_properties
  end
  properties.each do |property|
    data.push(metadata.property_from_string(property[0]))
  end
  if pbPropertyList(map_name, data, properties, true)
    if map_id == 0   # Global metadata
      # Construct metadata hash
      metadata_hash = {
        :id                 => map_id,
        :home               => data[0],
        :wild_battle_BGM    => data[1],
        :trainer_battle_BGM => data[2],
        :wild_victory_ME    => data[3],
        :trainer_victory_ME => data[4],
        :wild_capture_ME    => data[5],
        :surf_BGM           => data[6],
        :bicycle_BGM        => data[7],
        :player_A           => data[8],
        :player_B           => data[9],
        :player_C           => data[10],
        :player_D           => data[11],
        :player_E           => data[12],
        :player_F           => data[13],
        :player_G           => data[14],
        :player_H           => data[15]
      }
      # Add metadata's data to records
      GameData::Metadata::DATA[map_id] = GameData::Metadata.new(metadata_hash)
      GameData::Metadata.save
    else   # Map metadata
      # Construct metadata hash
      metadata_hash = {
        :id                   => map_id,
        :outdoor_map          => data[0],
        :announce_location    => data[1],
        :can_bicycle          => data[2],
        :always_bicycle       => data[3],
        :teleport_destination => data[4],
        :weather              => data[5],
        :town_map_position    => data[6],
        :dive_map_id          => data[7],
        :dark_map             => data[8],
        :safari_map           => data[9],
        :snap_edges           => data[10],
        :random_dungeon       => data[11],
        :battle_background    => data[12],
        :wild_battle_BGM      => data[13],
        :trainer_battle_BGM   => data[14],
        :wild_victory_ME      => data[15],
        :trainer_victory_ME   => data[16],
        :wild_capture_ME      => data[17],
        :town_map_size        => data[18],
        :battle_environment   => data[19]
      }
      # Add metadata's data to records
      GameData::MapMetadata::DATA[map_id] = GameData::MapMetadata.new(metadata_hash)
      GameData::MapMetadata.save
    end
    Compiler.write_metadata
  end
end



#===============================================================================
# Item editor
#===============================================================================
def pbItemEditor
  item_properties = [
     [_INTL("Internal Name"),     ReadOnlyProperty,          _INTL("Internal name that is used as a symbol like :XXX.")],
     [_INTL("Item Name"),         ItemNameProperty,          _INTL("Name of the item as displayed by the game.")],
     [_INTL("Item Name Plural"),  ItemNameProperty,          _INTL("Plural name of the item as displayed by the game.")],
     [_INTL("Pocket"),            PocketProperty,            _INTL("Pocket in the bag where the item is stored.")],
     [_INTL("Purchase price"),    LimitProperty.new(999999), _INTL("Purchase price of the item.")],
     [_INTL("Description"),       StringProperty,            _INTL("Description of the item")],
     [_INTL("Use Out of Battle"), EnumProperty.new([
        _INTL("Can't Use"), _INTL("On a Pokémon"), _INTL("Use directly"),
        _INTL("TM"), _INTL("HM"), _INTL("On a Pokémon reusable"),
       _INTL("TR")]),                                        _INTL("Specifies how this item can be used outside of battle.")],
     [_INTL("Use In Battle"),     EnumProperty.new([
        _INTL("Can't Use"), _INTL("On a Pokémon"), _INTL("On Pokémon's move"),
        _INTL("On battler"), _INTL("On foe battler"), _INTL("Use directly"),
        _INTL("On a Pokémon reusable"), _INTL("On Pokémon's move reusable"),
        _INTL("On battler reusable"), _INTL("On foe battler reusable"),
        _INTL("Use directly reusable")]),                    _INTL("Specifies how this item can be used within a battle.")],
     [_INTL("Special Items"),     EnumProperty.new([
        _INTL("None of below"), _INTL("Mail"), _INTL("Mail with Pictures"),
        _INTL("Snag Ball"), _INTL("Poké Ball"), _INTL("Plantable Berry"),
        _INTL("Key Item"), _INTL("Evolution Stone"), _INTL("Fossil"),
        _INTL("Apricorn"), _INTL("Type-boosting Gem"), _INTL("Mulch"),
        _INTL("Mega Stone")]),                               _INTL("For special kinds of items.")],
     [_INTL("Machine"),           MoveProperty,              _INTL("Move taught by this TM or HM.")]
  ]
  pbListScreenBlock(_INTL("Items"), ItemLister.new(0, true)) { |button, item|
    if item
      if button == Input::A
        if item.is_a?(Symbol)
          if pbConfirmMessageSerious("Delete this item?")
            id_number = GameData::Item.get(item).id_number
            GameData::Item::DATA.delete(item)
            GameData::Item::DATA.delete(id_number)
            GameData::Item.save
            Compiler.write_items
            pbMessage(_INTL("The item was deleted."))
          end
        end
      elsif button == Input::C
        if item.is_a?(Symbol)
          itm = GameData::Item.get(item)
          data = [
            itm.id.to_s,
            itm.real_name,
            itm.real_name_plural,
            itm.pocket,
            itm.price,
            itm.real_description,
            itm.field_use,
            itm.battle_use,
            itm.type,
            itm.move
          ]
          if pbPropertyList(itm.id.to_s, data, item_properties, true)
            # Construct item hash
            item_hash = {
              :id_number   => itm.id_number,
              :id          => itm.id,
              :name        => data[1],
              :name_plural => data[2],
              :pocket      => data[3],
              :price       => data[4],
              :description => data[5],
              :field_use   => data[6],
              :battle_use  => data[7],
              :type        => data[8],
              :move        => data[9]
            }
            # Add item's data to records
            GameData::Item::DATA[itm.id_number] = GameData::Item::DATA[itm.id] = GameData::Item.new(item_hash)
            GameData::Item.save
            Compiler.write_items
          end
        else   # Add a new item
          pbItemEditorNew(nil)
        end
      end
    end
  }
end

def pbItemEditorNew(default_name)
  # Get an unused ID number for the new item
  max_id = 0
  GameData::Item.each { |i| max_id = i.id_number if max_id < i.id_number }
  id_number = max_id + 1
  # Choose a name
  name = pbMessageFreeText(_INTL("Please enter the item's name."),
     (default_name) ? default_name.gsub(/_+/, " ") : "", false, 30)
  if name == ""
    return if !default_name
    name = default_name
  end
  # Generate an ID based on the item name
  id = name.gsub(/é/, "e")
  id = id.gsub(/[^A-Za-z0-9_]/, "")
  id = id.upcase
  if id.length == 0
    id = sprintf("ITEM_%03d", id_number)
  elsif !id[0, 1][/[A-Z]/]
    id = "ITEM_" + id
  end
  if GameData::Item.exists?(id)
    for i in 1..100
      trial_id = sprintf("%s_%d", id, i)
      next if GameData::Item.exists?(trial_id)
      id = trial_id
      break
    end
  end
  if GameData::Item.exists?(id)
    pbMessage(_INTL("Failed to create the item. Choose a different name."))
    return
  end
  # Choose a pocket
  pocket = PocketProperty.set("", 0)
  return if pocket == 0
  # Choose a price
  price = LimitProperty.new(999999).set(_INTL("Purchase price"), -1)
  return if price == -1
  # Choose a description
  description = StringProperty.set(_INTL("Description"), "")
  # Construct item hash
  item_hash = {
    :id_number   => id_number,
    :id          => id.to_sym,
    :name        => name,
    :name_plural => name + "s",
    :pocket      => pocket,
    :price       => price,
    :description => description
  }
  # Add item's data to records
  GameData::Item::DATA[id_number] = GameData::Item::DATA[id.to_sym] = GameData::Item.new(item_hash)
  GameData::Item.save
  Compiler.write_items
  pbMessage(_INTL("The item {1} was created (ID: {2}).", name, id.to_s))
  pbMessage(_ISPRINTF("Put the item's graphic (item{1:s}.png or item{2:03d}.png) in Graphics/Icons, or it will be blank.",
     id, id_number))
end



#===============================================================================
# Pokémon species editor
#===============================================================================
def pbPokemonEditor
  species_properties = [
     [_INTL("InternalName"),      ReadOnlyProperty,               _INTL("Internal name of the Pokémon.")],
     [_INTL("Name"),              LimitStringProperty.new(Pokemon::MAX_NAME_SIZE), _INTL("Name of the Pokémon.")],
     [_INTL("FormName"),          StringProperty,                 _INTL("Name of this form of the Pokémon.")],
     [_INTL("Kind"),              StringProperty,                 _INTL("Kind of Pokémon species.")],
     [_INTL("Pokédex"),           StringProperty,                 _INTL("Description of the Pokémon as displayed in the Pokédex.")],
     [_INTL("Type1"),             TypeProperty,                   _INTL("Pokémon's type. If same as Type2, this Pokémon has a single type.")],
     [_INTL("Type2"),             TypeProperty,                   _INTL("Pokémon's type. If same as Type1, this Pokémon has a single type.")],
     [_INTL("BaseStats"),         BaseStatsProperty,              _INTL("Base stats of the Pokémon.")],
     [_INTL("EffortPoints"),      EffortValuesProperty,           _INTL("Effort Value points earned when this species is defeated.")],
     [_INTL("BaseEXP"),           LimitProperty.new(9999),        _INTL("Base experience earned when this species is defeated.")],
     [_INTL("GrowthRate"),        EnumProperty.new([
         _INTL("Medium"), _INTL("Erratic"), _INTL("Fluctuating"),
         _INTL("Parabolic"), _INTL("Fast"), _INTL("Slow")]),      _INTL("Pokémon's growth rate.")],
     [_INTL("GenderRate"),        EnumProperty.new([
         _INTL("Genderless"), _INTL("AlwaysMale"), _INTL("FemaleOneEighth"),
         _INTL("Female25Percent"), _INTL("Female50Percent"), _INTL("Female75Percent"),
         _INTL("FemaleSevenEighths"), _INTL("AlwaysFemale")]),    _INTL("Proportion of males to females for this species.")],
     [_INTL("Rareness"),          LimitProperty.new(255),         _INTL("Catch rate of this species (0-255).")],
     [_INTL("Happiness"),         LimitProperty.new(255),         _INTL("Base happiness of this species (0-255).")],
     [_INTL("Moves"),             MovePoolProperty,               _INTL("Moves which the Pokémon learns while levelling up.")],
     [_INTL("TutorMoves"),        EggMovesProperty,               _INTL("Moves which the Pokémon can be taught by TM/HM/Move Tutor.")],
     [_INTL("EggMoves"),          EggMovesProperty,               _INTL("Moves which the Pokémon can learn via breeding.")],
     [_INTL("Ability1"),          AbilityProperty,                _INTL("One ability which the Pokémon can have.")],
     [_INTL("Ability2"),          AbilityProperty,                _INTL("Another ability which the Pokémon can have.")],
     [_INTL("HiddenAbility 1"),   AbilityProperty,                _INTL("A secret ability which the Pokémon can have.")],
     [_INTL("HiddenAbility 2"),   AbilityProperty,                _INTL("A secret ability which the Pokémon can have.")],
     [_INTL("HiddenAbility 3"),   AbilityProperty,                _INTL("A secret ability which the Pokémon can have.")],
     [_INTL("HiddenAbility 4"),   AbilityProperty,                _INTL("A secret ability which the Pokémon can have.")],
     [_INTL("WildItemCommon"),    ItemProperty,                   _INTL("Item commonly held by wild Pokémon of this species.")],
     [_INTL("WildItemUncommon"),  ItemProperty,                   _INTL("Item uncommonly held by wild Pokémon of this species.")],
     [_INTL("WildItemRare"),      ItemProperty,                   _INTL("Item rarely held by wild Pokémon of this species.")],
     [_INTL("Compat1"),           EnumProperty.new([
         "Undiscovered", "Monster", "Water 1", "Bug", "Flying",
         "Field", "Fairy", "Grass", "Human-like", "Water 3",
         "Mineral", "Amorphous", "Water 2", "Ditto", "Dragon"]),  _INTL("Compatibility group (egg group) for breeding purposes.")],
     [_INTL("Compat2"),           EnumProperty.new([
         "Undiscovered", "Monster", "Water 1", "Bug", "Flying",
         "Field", "Fairy", "Grass", "Human-like", "Water 3",
         "Mineral", "Amorphous", "Water 2", "Ditto", "Dragon"]),  _INTL("Compatibility group (egg group) for breeding purposes.")],
     [_INTL("StepsToHatch"),      LimitProperty.new(99999),       _INTL("Number of steps until an egg of this species hatches.")],
     [_INTL("Incense"),           ItemProperty,                   _INTL("Item needed to be held by a parent to produce an egg of this species.")],
     [_INTL("Evolutions"),        EvolutionsProperty.new,         _INTL("Evolution paths of this species.")],
     [_INTL("Height"),            NonzeroLimitProperty.new(999),  _INTL("Height of the Pokémon in 0.1 metres (e.g. 42 = 4.2m).")],
     [_INTL("Weight"),            NonzeroLimitProperty.new(9999), _INTL("Weight of the Pokémon in 0.1 kilograms (e.g. 42 = 4.2kg).")],
     [_INTL("Color"),             EnumProperty.new([
        _INTL("Red"), _INTL("Blue"), _INTL("Yellow"), _INTL("Green"),
        _INTL("Black"), _INTL("Brown"), _INTL("Purple"), _INTL("Gray"),
        _INTL("White"), _INTL("Pink")]),                          _INTL("Pokémon's body color.")],
     [_INTL("Shape"),             LimitProperty.new(14),          _INTL("Body shape of this species (0-14).")],
     [_INTL("Habitat"),           EnumProperty.new([
        _INTL("None"), _INTL("Grassland"), _INTL("Forest"), _INTL("WatersEdge"),
        _INTL("Sea"), _INTL("Cave"), _INTL("Mountain"), _INTL("RoughTerrain"),
        _INTL("Urban"), _INTL("Rare")]),                          _INTL("The habitat of this species.")],
     [_INTL("Generation"),        LimitProperty.new(99999),       _INTL("The number of the generation the Pokémon debuted in.")],
     [_INTL("BattlerPlayerX"),    ReadOnlyProperty,               _INTL("Affects positioning of the Pokémon in battle. This is edited elsewhere.")],
     [_INTL("BattlerPlayerY"),    ReadOnlyProperty,               _INTL("Affects positioning of the Pokémon in battle. This is edited elsewhere.")],
     [_INTL("BattlerEnemyX"),     ReadOnlyProperty,               _INTL("Affects positioning of the Pokémon in battle. This is edited elsewhere.")],
     [_INTL("BattlerEnemyY"),     ReadOnlyProperty,               _INTL("Affects positioning of the Pokémon in battle. This is edited elsewhere.")],
     [_INTL("BattlerAltitude"),   ReadOnlyProperty,               _INTL("Affects positioning of the Pokémon in battle. This is edited elsewhere.")],
     [_INTL("BattlerShadowX"),    ReadOnlyProperty,               _INTL("Affects positioning of the Pokémon in battle. This is edited elsewhere.")],
     [_INTL("BattlerShadowSize"), ReadOnlyProperty,               _INTL("Affects positioning of the Pokémon in battle. This is edited elsewhere.")],
  ]
  pbListScreenBlock(_INTL("Pokémon species"), SpeciesLister.new(0, false)) { |button, species|
    if species
      if button == Input::A
        if species.is_a?(Symbol)
          if pbConfirmMessageSerious("Delete this species?")
            id_number = GameData::Species.get(species).id_number
            GameData::Species::DATA.delete(species)
            GameData::Species::DATA.delete(id_number)
            GameData::Species.save
            Compiler.write_pokemon
            pbMessage(_INTL("The species was deleted."))
          end
        end
      elsif button == Input::C
        if species.is_a?(Symbol)
          spec = GameData::Species.get(species)
          moves = []
          spec.moves.each_with_index { |m, i| moves.push(m.clone.push(i)) }
          moves.sort! { |a, b| (a[0] == b[0]) ? a[2] <=> b[2] : a[0] <=> b[0] }
          moves.each { |m| m.pop }
          evolutions = []
          spec.evolutions.each { |e| evolutions.push(e.clone) if !e[3] }
          data = [
            spec.id.to_s,
            spec.real_name,
            spec.real_form_name,
            spec.real_category,
            spec.real_pokedex_entry,
            spec.type1,
            (spec.type2 == spec.type1) ? nil : spec.type2,
            spec.base_stats.clone,
            spec.evs.clone,
            spec.base_exp,
            spec.growth_rate,
            spec.gender_rate,
            spec.catch_rate,
            spec.happiness,
            moves,
            spec.tutor_moves.clone,
            spec.egg_moves.clone,
            spec.abilities[0],
            spec.abilities[1],
            spec.hidden_abilities[0],
            spec.hidden_abilities[1],
            spec.hidden_abilities[2],
            spec.hidden_abilities[3],
            spec.wild_item_common,
            spec.wild_item_uncommon,
            spec.wild_item_rare,
            spec.egg_groups[0],
            spec.egg_groups[1],
            spec.hatch_steps,
            spec.incense,
            evolutions,
            spec.height,
            spec.weight,
            spec.color,
            spec.shape,
            spec.habitat,
            spec.generation,
            spec.back_sprite_x,
            spec.back_sprite_y,
            spec.front_sprite_x,
            spec.front_sprite_y,
            spec.front_sprite_altitude,
            spec.shadow_x,
            spec.shadow_size
          ]
          # Edit the properties
          if pbPropertyList(spec.id.to_s, data, species_properties, true)
            # Sanitise data
            data[5] = data[6] if !data[5]                    # Type1
            data[6] = data[5] if !data[6]                    # Type2
            egg_groups = [data[26], data[27]].uniq.compact   # Egg groups
            egg_groups.push(PBEggGroups::Undiscovered) if egg_groups.length == 0
            abilities = [data[17], data[18]].uniq.compact    # Abilities
            hidden_abilities = [data[19], data[20], data[21], data[22]].uniq.compact   # Hidden abilities
            # Construct species hash
            species_hash = {
              :id                    => spec.id,
              :id_number             => spec.id_number,
              :name                  => data[1],
              :form_name             => data[2],
              :category              => data[3],
              :pokedex_entry         => data[4],
              :type1                 => data[5],
              :type2                 => data[6],
              :base_stats            => data[7],
              :evs                   => data[8],
              :base_exp              => data[9],
              :growth_rate           => data[10],
              :gender_rate           => data[11],
              :catch_rate            => data[12],
              :happiness             => data[13],
              :moves                 => data[14],
              :tutor_moves           => data[15],
              :egg_moves             => data[16],
              :abilities             => abilities,          # 17, 18
              :hidden_abilities      => hidden_abilities,   # 19, 20, 21, 22
              :wild_item_common      => data[23],
              :wild_item_uncommon    => data[24],
              :wild_item_rare        => data[25],
              :egg_groups            => egg_groups,         # 26, 27
              :hatch_steps           => data[28],
              :incense               => data[29],
              :evolutions            => data[30],
              :height                => data[31],
              :weight                => data[32],
              :color                 => data[33],
              :shape                 => data[34],
              :habitat               => data[35],
              :generation            => data[36],
              :back_sprite_x         => data[37],
              :back_sprite_y         => data[38],
              :front_sprite_x        => data[39],
              :front_sprite_y        => data[40],
              :front_sprite_altitude => data[41],
              :shadow_x              => data[42],
              :shadow_size           => data[43]
            }
            # Add species' data to records
            GameData::Species::DATA[spec.id_number] = GameData::Species::DATA[spec.id] = GameData::Species.new(species_hash)
            GameData::Species.save
            Compiler.write_pokemon
            pbMessage(_INTL("Data saved."))
          end
        else
          pbMessage(_INTL("Can't add a new species."))
        end
      end
    end
  }
end



#===============================================================================
# Regional Dexes editor
#===============================================================================
def pbRegionalDexEditor(dex)
  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 99999
  cmd_window = pbListWindow([])
  info = Window_AdvancedTextPokemon.newWithSize(
     _INTL("Z+Up/Down: Rearrange entries\nZ+Right: Insert new entry\nZ+Left: Delete entry\nF: Clear entry"),
     Graphics.width / 2, 64, Graphics.width / 2, Graphics.height - 64, viewport)
  info.z = 2
  dex.compact!
  ret = dex.clone
  commands = []
  refresh_list = true
  cmd = [0, 0]   # [action, index in list]
  loop do
    # Populate commands
    if refresh_list
      loop do
        break if dex.length == 0 || dex[-1]
        dex.slice!(-1)
      end
      commands = []
      dex.each_with_index do |species, i|
        text = (species) ? GameData::Species.get(species).real_name : "----------"
        commands.push(sprintf("%03d: %s", i + 1, text))
      end
      commands.push(sprintf("%03d: ----------", commands.length + 1))
      cmd[1] = [cmd[1], commands.length - 1].min
      refresh_list = false
    end
    # Choose to do something
    cmd = pbCommands3(cmd_window, commands, -1, cmd[1], true)
    case cmd[0]
    when 1   # Swap entry up
      if cmd[1] < dex.length - 1
        dex[cmd[1] + 1], dex[cmd[1]] = dex[cmd[1]], dex[cmd[1] + 1]
        refresh_list = true
      end
     when 2   # Swap entry down
      if cmd[1] > 0
        dex[cmd[1] - 1], dex[cmd[1]] = dex[cmd[1]], dex[cmd[1] - 1]
        refresh_list = true
      end
    when 3   # Delete spot
      if cmd[1] < dex.length
        dex.delete_at(cmd[1])
        refresh_list = true
      end
    when 4   # Insert spot
      if cmd[1] < dex.length
        dex.insert(cmd[1], nil)
        refresh_list = true
      end
    when 5   # Clear spot
      if dex[cmd[1]]
        dex[cmd[1]] = nil
        refresh_list = true
      end
    when 0
      if cmd[1] >= 0   # Edit entry
        case pbMessage(_INTL("\\ts[]Do what with this entry?"),
           [_INTL("Change species"), _INTL("Clear"), _INTL("Insert entry"), _INTL("Delete entry"), _INTL("Cancel")], 5)
        when 0   # Change species
          species = pbChooseSpeciesList(dex[cmd[1]])
          if species
            dex[cmd[1]] = species
            dex.each_with_index { |s, i| dex[i] = nil if i != cmd[1] && s == species }
            refresh_list = true
          end
        when 1   # Clear spot
          if dex[cmd[1]]
            dex[cmd[1]] = nil
            refresh_list = true
          end
        when 2   # Insert spot
          if cmd[1] < dex.length
            dex.insert(cmd[1], nil)
            refresh_list = true
          end
        when 3   # Delete spot
          if cmd[1] < dex.length
            dex.delete_at(cmd[1])
            refresh_list = true
          end
        end
      else   # Cancel
        case pbMessage(_INTL("Save changes?"),
           [_INTL("Yes"),_INTL("No"),_INTL("Cancel")],3)
        when 0   # Save all changes to Dex
          dex.slice!(-1) while !dex[-1]
          ret = dex
          break
        when 1   # Just quit
          break
        end
      end
    end
  end
  info.dispose
  cmd_window.dispose
  viewport.dispose
  ret.compact!
  return ret
end

def pbRegionalDexEditorMain
  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 99999
  cmd_window = pbListWindow([])
  cmd_window.viewport = viewport
  cmd_window.z        = 2
  title = Window_UnformattedTextPokemon.newWithSize(_INTL("Regional Dexes Editor"),
     Graphics.width / 2, 0, Graphics.width / 2, 64, viewport)
  title.z = 2
  info = Window_AdvancedTextPokemon.newWithSize(_INTL("Z+Up/Down: Rearrange Dexes"),
     Graphics.width / 2, 64, Graphics.width / 2, Graphics.height - 64, viewport)
  info.z = 2
  dex_lists = []
  pbLoadRegionalDexes.each_with_index { |d, index| dex_lists[index] = d.clone }
  commands = []
  refresh_list = true
  oldsel = -1
  cmd = [0, 0]   # [action, index in list]
  loop do
    # Populate commands
    if refresh_list
      commands = [_INTL("[ADD DEX]")]
      dex_lists.each_with_index do |list, i|
        commands.push(_INTL("Dex {1} (size {2})", i + 1, list.length))
      end
      refresh_list = false
    end
    # Choose to do something
    oldsel = -1
    cmd = pbCommands3(cmd_window, commands, -1, cmd[1], true)
    case cmd[0]
    when 1   # Swap Dex up
      if cmd[1] > 0 && cmd[1] < commands.length - 1
        dex_lists[cmd[1] - 1], dex_lists[cmd[1]] = dex_lists[cmd[1]], dex_lists[cmd[1] - 1]
        refresh_list = true
      end
    when 2   # Swap Dex down
      if cmd[1] > 1
        dex_lists[cmd[1] - 2], dex_lists[cmd[1] - 1] = dex_lists[cmd[1] - 1], dex_lists[cmd[1] - 2]
        refresh_list = true
      end
    when 0   # Clicked on a command/Dex
      if cmd[1] == 0   # Add new Dex
        case pbMessage(_INTL("Fill in this new Dex?"),
           [_INTL("Leave blank"), _INTL("National Dex"), _INTL("Nat. Dex grouped families"), _INTL("Cancel")], 4)
        when 0   # Leave blank
          dex_lists.push([])
          refresh_list = true
        when 1   # Fill with National Dex
          new_dex = []
          GameData::Species.each { |s| new_dex.push(s.species) if s.form == 0 }
          dex_lists.push(new_dex)
          refresh_list = true
        when 2   # Fill with National Dex
          new_dex = []
          seen = []
          GameData::Species.each do |s|
            next if s.form != 0 || seen.include?(s.species)
            family = EvolutionHelper.all_related_species(s.species)
            new_dex.concat(family)
            seen.concat(family)
          end
          dex_lists.push(new_dex)
          refresh_list = true
        end
      elsif cmd[1] > 0   # Edit a Dex
        case pbMessage(_INTL("\\ts[]Do what with this Dex?"),
            [_INTL("Edit"), _INTL("Copy"), _INTL("Delete"), _INTL("Cancel")], 4)
        when 0   # Edit
          dex_lists[cmd[1] - 1] = pbRegionalDexEditor(dex_lists[cmd[1] - 1])
          refresh_list = true
        when 1   # Copy
          dex_lists[dex_lists.length] = dex_lists[cmd[1] - 1].clone
          cmd[1] = dex_lists.length
          refresh_list = true
        when 2   # Delete
          dex_lists[cmd[1] - 1] = nil
          dex_lists.compact!
          cmd[1] = [cmd[1], dex_lists.length].min
          refresh_list = true
        end
      else   # Cancel
        case pbMessage(_INTL("Save changes?"),
           [_INTL("Yes"), _INTL("No"), _INTL("Cancel")], 3)
        when 0   # Save all changes to Dexes
          save_data(dex_lists, "Data/regional_dexes.dat")
          $PokemonTemp.regionalDexes = nil
          Compiler.write_regional_dexes
          pbMessage(_INTL("Data saved."))
          break
        when 1   # Just quit
          break
        end
      end
    end
  end
  title.dispose
  info.dispose
  cmd_window.dispose
  viewport.dispose
end

def pbAppendEvoToFamilyArray(species, array, seenarray)
  return if seenarray[species]
  array.push(species)
  seenarray[species] = true
  evos = EvolutionHelper.evolutions(species)
  if evos.length > 0
    evos.sort! { |a, b| a[2] <=> b[2] }
    subarray = []
    for i in evos
      pbAppendEvoToFamilyArray(i[2], subarray, seenarray)
    end
    array.push(subarray) if subarray.length > 0
  end
end

def pbGetEvoFamilies
  seen = []
  ret = []
  GameData::Species.each do |sp|
    next if sp.form > 0
    species = EvolutionHelper.baby_species(sp.species)
    next if seen[species]
    subret = []
    pbAppendEvoToFamilyArray(species, subret, seen)
    ret.push(subret.flatten) if subret.length > 0
  end
  return ret
end

def pbEvoFamiliesToStrings
  ret = []
  families = pbGetEvoFamilies
  for fam in 0...families.length
    string = ""
    for p in 0...families[fam].length
      if p>=3
        string += " + #{families[fam].length - 3} more"
        break
      end
      string += "/" if p > 0
      string += GameData::Species.get(families[fam][p]).name
    end
    ret[fam] = string
  end
  return ret
end



#===============================================================================
# Battle animations rearranger
#===============================================================================
def pbAnimationsOrganiser
  list = pbLoadBattleAnimations
  if !list || !list[0]
    pbMessage(_INTL("No animations exist."))
    return
  end
  viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z = 99999
  cmdwin = pbListWindow([])
  cmdwin.viewport = viewport
  cmdwin.z        = 2
  title = Window_UnformattedTextPokemon.new(_INTL("Animations Organiser"))
  title.x        = Graphics.width/2
  title.y        = 0
  title.width    = Graphics.width/2
  title.height   = 64
  title.viewport = viewport
  title.z        = 2
  info = Window_AdvancedTextPokemon.new(_INTL("Z+Up/Down: Swap\nZ+Left: Delete\nZ+Right: Insert"))
  info.x        = Graphics.width/2
  info.y        = 64
  info.width    = Graphics.width/2
  info.height   = Graphics.height-64
  info.viewport = viewport
  info.z        = 2
  commands = []
  refreshlist = true; oldsel = -1
  cmd = [0,0]
  loop do
    if refreshlist
      commands = []
      for i in 0...list.length
        commands.push(sprintf("%d: %s",i,(list[i]) ? list[i].name : "???"))
      end
    end
    refreshlist = false; oldsel = -1
    cmd = pbCommands3(cmdwin,commands,-1,cmd[1],true)
    if cmd[0]==1   # Swap animation up
      if cmd[1]>=0 && cmd[1]<commands.length-1
        list[cmd[1]+1],list[cmd[1]] = list[cmd[1]],list[cmd[1]+1]
        refreshlist = true
      end
    elsif cmd[0]==2   # Swap animation down
      if cmd[1]>0
        list[cmd[1]-1],list[cmd[1]] = list[cmd[1]],list[cmd[1]-1]
        refreshlist = true
      end
    elsif cmd[0]==3   # Delete spot
      list.delete_at(cmd[1])
      cmd[1] = [cmd[1],list.length-1].min
      refreshlist = true
      pbWait(Graphics.frame_rate*2/10)
    elsif cmd[0]==4   # Insert spot
      list.insert(cmd[1],PBAnimation.new)
      refreshlist = true
      pbWait(Graphics.frame_rate*2/10)
    elsif cmd[0]==0
      cmd2 = pbMessage(_INTL("Save changes?"),
          [_INTL("Yes"),_INTL("No"),_INTL("Cancel")],3)
      if cmd2==0 || cmd2==1
        if cmd2==0
          # Save animations here
          save_data(list,"Data/PkmnAnimations.rxdata")
          $PokemonTemp.battleAnims = nil
          pbMessage(_INTL("Data saved."))
        end
        break
      end
    end
  end
  title.dispose
  info.dispose
  cmdwin.dispose
  viewport.dispose
end
