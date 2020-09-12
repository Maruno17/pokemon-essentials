#===============================================================================
# Compile metadata
#===============================================================================
class PBTrainers; end



def pbCompileMetadata
  sections = []
  currentmap = -1
  pbCompilerEachCommentedLine("PBS/metadata.txt") { |line,lineno|
    if line[/^\s*\[\s*(\d+)\s*\]\s*$/]
      sectionname = $~[1]
      if currentmap==0
        if sections[currentmap][MetadataHome]==nil
          raise _INTL("The entry Home is required in metadata.txt section [{1}]",sectionname)
        end
        if sections[currentmap][MetadataPlayerA]==nil
          raise _INTL("The entry PlayerA is required in metadata.txt section [{1}]",sectionname)
        end
      end
      currentmap = sectionname.to_i
      sections[currentmap] = []
    else
      if currentmap<0
        raise _INTL("Expected a section at the beginning of the file\r\n{1}",FileLineData.linereport)
      end
      if !line[/^\s*(\w+)\s*=\s*(.*)$/]
        raise _INTL("Bad line syntax (expected syntax like XXX=YYY)\r\n{1}",FileLineData.linereport)
      end
      matchData = $~
      schema = nil
      FileLineData.setSection(currentmap,matchData[1],matchData[2])
      if currentmap==0
        schema = PokemonMetadata::GlobalTypes[matchData[1]]
      else
        schema = PokemonMetadata::NonGlobalTypes[matchData[1]]
      end
      if schema
        record = pbGetCsvRecord(matchData[2],lineno,schema)
        sections[currentmap][schema[0]] = record
      end
    end
  }
  save_data(sections,"Data/metadata.dat")
end

#===============================================================================
# Compile town map points
#===============================================================================
def pbCompileTownMap
  nonglobaltypes = {
    "Name"     => [0, "s"],
    "Filename" => [1, "s"],
    "Point"    => [2, "uussUUUU"]
  }
  currentmap = -1
  rgnnames   = []
  placenames = []
  placedescs = []
  sections   = []
  pbCompilerEachCommentedLine("PBS/townmap.txt") { |line,lineno|
    if line[/^\s*\[\s*(\d+)\s*\]\s*$/]
      currentmap = $~[1].to_i
      sections[currentmap] = []
    else
      if currentmap<0
        raise _INTL("Expected a section at the beginning of the file\r\n{1}",FileLineData.linereport)
      end
      if !line[/^\s*(\w+)\s*=\s*(.*)$/]
        raise _INTL("Bad line syntax (expected syntax like XXX=YYY)\r\n{1}",FileLineData.linereport)
      end
      settingname = $~[1]
      schema = nonglobaltypes[settingname]
      if schema
        record = pbGetCsvRecord($~[2],lineno,schema)
        if settingname=="Name"
          rgnnames[currentmap] = record
        elsif settingname=="Point"
          placenames.push(record[2])
          placedescs.push(record[3])
          sections[currentmap][schema[0]] = [] if !sections[currentmap][schema[0]]
          sections[currentmap][schema[0]].push(record)
        else   # Filename
          sections[currentmap][schema[0]] = record
        end
      end
    end
  }
  save_data(sections,"Data/town_map.dat")
  MessageTypes.setMessages(MessageTypes::RegionNames,rgnnames)
  MessageTypes.setMessagesAsHash(MessageTypes::PlaceNames,placenames)
  MessageTypes.setMessagesAsHash(MessageTypes::PlaceDescriptions,placedescs)
end

#===============================================================================
# Compile map connections
#===============================================================================
def pbCompileConnections
  records   = []
  pbCompilerEachPreppedLine("PBS/connections.txt") { |line,lineno|
    hashenum = {
      "N" => "N","North" => "N",
      "E" => "E","East"  => "E",
      "S" => "S","South" => "S",
      "W" => "W","West"  => "W"
    }
    record = []
    thisline = line.dup
    record.push(csvInt!(thisline,lineno))
    record.push(csvEnumFieldOrInt!(thisline,hashenum,"",sprintf("(line %d)",lineno)))
    record.push(csvInt!(thisline,lineno))
    record.push(csvInt!(thisline,lineno))
    record.push(csvEnumFieldOrInt!(thisline,hashenum,"",sprintf("(line %d)",lineno)))
    record.push(csvInt!(thisline,lineno))
    if !pbRgssExists?(sprintf("Data/Map%03d.rxdata",record[0])) &&
       !pbRgssExists?(sprintf("Data/Map%03d.rvdata",record[0]))
      print _INTL("Warning: Map {1}, as mentioned in the map connection data, was not found.\r\n{2}",record[0],FileLineData.linereport)
    end
    if !pbRgssExists?(sprintf("Data/Map%03d.rxdata",record[3])) &&
       !pbRgssExists?(sprintf("Data/Map%03d.rvdata",record[3]))
      print _INTL("Warning: Map {1}, as mentioned in the map connection data, was not found.\r\n{2}",record[3],FileLineData.linereport)
    end
    case record[1]
    when "N"; raise _INTL("North side of first map must connect with south side of second map\r\n{1}",FileLineData.linereport) if record[4]!="S"
    when "S"; raise _INTL("South side of first map must connect with north side of second map\r\n{1}",FileLineData.linereport) if record[4]!="N"
    when "E"; raise _INTL("East side of first map must connect with west side of second map\r\n{1}",FileLineData.linereport) if record[4]!="W"
    when "W"; raise _INTL("West side of first map must connect with east side of second map\r\n{1}",FileLineData.linereport) if record[4]!="E"
    end
    records.push(record)
  }
  save_data(records,"Data/map_connections.dat")
  Graphics.update
end

#===============================================================================
# Compile berry plants
#===============================================================================
def pbCompileBerryPlants
  sections = []
  if File.exists?("PBS/berryplants.txt")
    pbCompilerEachCommentedLine("PBS/berryplants.txt") { |line,_lineno|
      if line[ /^\s*(\w+)\s*=\s*(.*)$/ ]
        key   = $1
        value = $2
        value = value.split(",")
        for i in 0...value.length
          value[i].sub!(/^\s*/,"")
          value[i].sub!(/\s*$/,"")
          value[i] = value[i].to_i
        end
        item = parseItem(key)
        sections[item] = value
      end
    }
  end
  save_data(sections,"Data/berry_plants.dat")
end

#===============================================================================
# Compile phone messages
#===============================================================================
def pbCompilePhoneData
  return if !safeExists?("PBS/phone.txt")
  database = PhoneDatabase.new
  sections = []
  File.open("PBS/phone.txt","rb") { |f|
    pbEachSection(f) { |section,name|
      case name
      when "<Generics>"
        database.generics=section
        sections.concat(section)
      when "<BattleRequests>"
        database.battleRequests=section
        sections.concat(section)
      when "<GreetingsMorning>"
        database.greetingsMorning=section
        sections.concat(section)
      when "<GreetingsEvening>"
        database.greetingsEvening=section
        sections.concat(section)
      when "<Greetings>"
        database.greetings=section
        sections.concat(section)
      when "<Bodies1>"
        database.bodies1=section
        sections.concat(section)
      when "<Bodies2>"
        database.bodies2=section
        sections.concat(section)
      end
    }
  }
  MessageTypes.setMessagesAsHash(MessageTypes::PhoneMessages,sections)
  save_data(database,"Data/phone.dat")
end

#===============================================================================
# Compile types
#===============================================================================
def pbWriteDefaultTypes
  if !safeExists?("PBS/types.txt")
    File.open("PBS/types.txt","w") { |f|
      f.write(0xEF.chr)
      f.write(0xBB.chr)
      f.write(0xBF.chr)
fx=<<END
[0]
Name=Normal
InternalName=NORMAL
Weaknesses=FIGHTING
Immunities=GHOST

[1]
Name=Fighting
InternalName=FIGHTING
Weaknesses=FLYING,PSYCHIC
Resistances=ROCK,BUG,DARK

[2]
Name=Flying
InternalName=FLYING
Weaknesses=ROCK,ELECTRIC,ICE
Resistances=FIGHTING,BUG,GRASS
Immunities=GROUND

[3]
Name=Poison
InternalName=POISON
Weaknesses=GROUND,PSYCHIC
Resistances=FIGHTING,POISON,BUG,GRASS

[4]
Name=Ground
InternalName=GROUND
Weaknesses=WATER,GRASS,ICE
Resistances=POISON,ROCK
Immunities=ELECTRIC

[5]
Name=Rock
InternalName=ROCK
Weaknesses=FIGHTING,GROUND,STEEL,WATER,GRASS
Resistances=NORMAL,FLYING,POISON,FIRE

[6]
Name=Bug
InternalName=BUG
Weaknesses=FLYING,ROCK,FIRE
Resistances=FIGHTING,GROUND,GRASS

[7]
Name=Ghost
InternalName=GHOST
Weaknesses=GHOST,DARK
Resistances=POISON,BUG
Immunities=NORMAL,FIGHTING

[8]
Name=Steel
InternalName=STEEL
Weaknesses=FIGHTING,GROUND,FIRE
Resistances=NORMAL,FLYING,ROCK,BUG,GHOST,STEEL,GRASS,PSYCHIC,ICE,DRAGON,DARK
Immunities=POISON

[9]
Name=???
InternalName=QMARKS
IsPseudoType=true

[10]
Name=Fire
InternalName=FIRE
IsSpecialType=true
Weaknesses=GROUND,ROCK,WATER
Resistances=BUG,STEEL,FIRE,GRASS,ICE

[11]
Name=Water
InternalName=WATER
IsSpecialType=true
Weaknesses=GRASS,ELECTRIC
Resistances=STEEL,FIRE,WATER,ICE

[12]
Name=Grass
InternalName=GRASS
IsSpecialType=true
Weaknesses=FLYING,POISON,BUG,FIRE,ICE
Resistances=GROUND,WATER,GRASS,ELECTRIC

[13]
Name=Electric
InternalName=ELECTRIC
IsSpecialType=true
Weaknesses=GROUND
Resistances=FLYING,STEEL,ELECTRIC

[14]
Name=Psychic
InternalName=PSYCHIC
IsSpecialType=true
Weaknesses=BUG,GHOST,DARK
Resistances=FIGHTING,PSYCHIC

[15]
Name=Ice
InternalName=ICE
IsSpecialType=true
Weaknesses=FIGHTING,ROCK,STEEL,FIRE
Resistances=ICE

[16]
Name=Dragon
InternalName=DRAGON
IsSpecialType=true
Weaknesses=ICE,DRAGON
Resistances=FIRE,WATER,GRASS,ELECTRIC

[17]
Name=Dark
InternalName=DARK
IsSpecialType=true
Weaknesses=FIGHTING,BUG
Resistances=GHOST,DARK
Immunities=PSYCHIC

END
      f.write(fx)
    }
  end
end

def pbCompileTypes
  pbWriteDefaultTypes
  typechart  = []
  types      = []
  requiredtypes = {
    "Name"          => [1, "s"],
    "InternalName"  => [2, "s"],
  }
  optionaltypes = {
    "IsPseudoType"  => [3, "b"],
    "IsSpecialType" => [4, "b"],
    "Weaknesses"    => [5, "*s"],
    "Resistances"   => [6, "*s"],
    "Immunities"    => [7, "*s"]
  }
  currentmap = -1
  foundtypes = []
  pbCompilerEachCommentedLine("PBS/types.txt") { |line,lineno|
    if line[/^\s*\[\s*(\d+)\s*\]\s*$/]
      sectionname = $~[1]
      if currentmap>=0
        for reqtype in requiredtypes.keys
          if !foundtypes.include?(reqtype)
            raise _INTL("Required value '{1}' not given in section '{2}'\r\n{3}",reqtype,currentmap,FileLineData.linereport)
          end
        end
        foundtypes.clear
      end
      currentmap = sectionname.to_i
      types[currentmap] = [currentmap,nil,nil,false,false,[],[],[]]
    else
      if currentmap<0
        raise _INTL("Expected a section at the beginning of the file\r\n{1}",FileLineData.linereport)
      end
      if !line[/^\s*(\w+)\s*=\s*(.*)$/]
        raise _INTL("Bad line syntax (expected syntax like XXX=YYY)\r\n{1}",FileLineData.linereport)
      end
      matchData = $~
      schema = nil
      FileLineData.setSection(currentmap,matchData[1],matchData[2])
      if requiredtypes.keys.include?(matchData[1])
        schema = requiredtypes[matchData[1]]
        foundtypes.push(matchData[1])
      else
        schema = optionaltypes[matchData[1]]
      end
      if schema
        record = pbGetCsvRecord(matchData[2],lineno,schema)
        types[currentmap][schema[0]] = record
      end
    end
  }
  types.compact!
  maxValue = 0
  for type in types; maxValue = [maxValue,type[0]].max; end
  pseudotypes  = []
  specialtypes = []
  typenames    = []
  typeinames   = []
  typehash     = {}
  for type in types
    pseudotypes.push(type[0]) if type[3]
    typenames[type[0]]  = type[1]
    typeinames[type[0]] = type[2]
    typehash[type[0]]   = type
  end
  for type in types
    n = type[1]
    for w in type[5]
      if !typeinames.include?(w)
        raise _INTL("'{1}' is not a defined type (PBS/types.txt, {2}, Weaknesses)",w,n)
      end
    end
    for w in type[6]
      if !typeinames.include?(w)
        raise _INTL("'{1}' is not a defined type (PBS/types.txt, {2}, Resistances)",w,n)
      end
    end
    for w in type[7]
      if !typeinames.include?(w)
        raise _INTL("'{1}' is not a defined type (PBS/types.txt, {2}, Immunities)",w,n)
      end
    end
  end
  for i in 0..maxValue
    pseudotypes.push(i) if !typehash[i]
  end
  pseudotypes.sort!
  types.each { |type| specialtypes.push(type[0]) if type[4] }
  specialtypes.sort!
  count = maxValue+1
  for i in 0...count
    type = typehash[i]
    j = 0; k = i
    while j<count
      typechart[k] = PBTypeEffectiveness::NORMAL_EFFECTIVE_ONE
      atype = typehash[j]
      if type && atype
        typechart[k] = PBTypeEffectiveness::SUPER_EFFECTIVE_ONE if type[5].include?(atype[2])   # weakness
        typechart[k] = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if type[6].include?(atype[2])     # resistance
        typechart[k] = PBTypeEffectiveness::INEFFECTIVE if type[7].include?(atype[2])           # immune
      end
      j += 1; k += count
    end
  end
  MessageTypes.setMessages(MessageTypes::Types,typenames)
  code = "class PBTypes\r\n"
  for type in types
    code += "#{type[2]}=#{type[0]}\r\n"
  end
  code += "def self.getName(id)\r\n"
  code += "id=getID(PBTypes,id)\r\n"
  code += "return pbGetMessage(MessageTypes::Types,id); end\r\n"
  code += "def self.getCount; return #{types.length}; end\r\n"
  code += "def self.maxValue; return #{maxValue}; end\r\n"
  code += "end\r\n"
  eval(code)
  save_data([pseudotypes,specialtypes,typechart],"Data/types.dat")
  pbAddScript(code,"PBTypes")
  Graphics.update
end

#===============================================================================
# Compile abilities
#===============================================================================
def pbCompileAbilities
  records   = []
  movenames = []
  movedescs = []
  maxValue = 0
  pbCompilerEachPreppedLine("PBS/abilities.txt") { |line,lineno|
    record = pbGetCsvRecord(line,lineno,[0,"vnss"])
    movenames[record[0]] = record[2]
    movedescs[record[0]] = record[3]
    maxValue = [maxValue,record[0]].max
    records.push(record)
  }
  MessageTypes.setMessages(MessageTypes::Abilities,movenames)
  MessageTypes.setMessages(MessageTypes::AbilityDescs,movedescs)
  code = "class PBAbilities\r\n"
  for rec in records
    code += "#{rec[1]}=#{rec[0]}\r\n"
  end
  code += "def self.getName(id)\r\n"
  code += "id=getID(PBAbilities,id)\r\n"
  code += "return pbGetMessage(MessageTypes::Abilities,id); end\r\n"
  code += "def self.getCount; return #{records.length}; end\r\n"
  code += "def self.maxValue; return #{maxValue}; end\r\n"
  code += "end\r\n"
  eval(code)
  pbAddScript(code,"PBAbilities")
end

#===============================================================================
# Compile items
#===============================================================================
class ItemList
  include Enumerable

  def initialize; @list = []; end
  def length; @list.length; end
  def []=(x,v); @list[x] = v; end

  def [](x)
    if !@list[x]
      defrecord = SerialRecord.new
      defrecord.push(0)
      defrecord.push("????????")
      defrecord.push(0)
      defrecord.push(0)
      defrecord.push("????????")
      @list[x] = defrecord
      return defrecord
    end
    return @list[x]
  end

  def each
    for i in 0...self.length
      yield self[i]
    end
  end
end



def readItemList(filename)
  ret = ItemList.new
  return ret if !pbRgssExists?(filename)
  pbRgssOpen(filename,"rb") { |file|
    numrec = file.fgetdw>>3
    curpos = 0
    numrec.times do
      file.pos = curpos
      offset = file.fgetdw
      length = file.fgetdw
      record = SerialRecord.decode(file,offset,length)
      ret[record[0]] = record
      curpos += 8
    end
  }
  return ret
end

def pbCompileItems
  records         = []
  constants       = ""
  itemnames       = []
  itempluralnames = []
  itemdescs       = []
  maxValue = 0
  pbCompilerEachCommentedLine("PBS/items.txt") { |line,lineno|
    linerecord = pbGetCsvRecord(line,lineno,[0,"vnssuusuuUN"])
    id = linerecord[0]
    record = []
    record[ITEM_ID]          = id
    constant                 = linerecord[1]
    constants                += "#{constant}=#{id}\r\n"
    record[ITEM_NAME]        = linerecord[2]
    itemnames[id]            = linerecord[2]
    record[ITEM_PLURAL]      = linerecord[3]
    itempluralnames[id]      = linerecord[3]
    record[ITEM_POCKET]      = linerecord[4]
    record[ITEM_PRICE]       = linerecord[5]
    record[ITEM_DESCRIPTION] = linerecord[6]
    itemdescs[id]            = linerecord[6]
    record[ITEM_FIELD_USE]   = linerecord[7]
    record[ITEM_BATTLE_USE]  = linerecord[8]
    record[ITEM_TYPE]        = linerecord[9]
    if record[ITEM_TYPE]!="" && linerecord[10]
      record[ITEM_MACHINE]   = parseMove(linerecord[10])
    else
      record[ITEM_MACHINE]   = 0
    end
    maxValue = [maxValue,id].max
    records[id] = record
  }
  MessageTypes.setMessages(MessageTypes::Items,itemnames)
  MessageTypes.setMessages(MessageTypes::ItemPlurals,itempluralnames)
  MessageTypes.setMessages(MessageTypes::ItemDescriptions,itemdescs)
  save_data(records,"Data/items.dat")
  code = "class PBItems\r\n"
  code += constants
  code += "def self.getName(id)\r\n"
  code += "id=getID(PBItems,id)\r\n"
  code += "return pbGetMessage(MessageTypes::Items,id); end\r\n"
  code += "def self.getNamePlural(id)\r\n"
  code += "id=getID(PBItems,id)\r\n"
  code += "return pbGetMessage(MessageTypes::ItemPlurals,id); end\r\n"
  code += "def self.getCount; return #{records.length}; end\r\n"
  code += "def self.maxValue; return #{maxValue}; end\r\n"
  code += "end\r\n"
  eval(code)
  pbAddScript(code,"PBItems")
  Graphics.update
end

#===============================================================================
# Compile move data
#===============================================================================
def pbCompileMoves
  records   = []
  moveNames = []
  moveDescs = []
  maxValue = 0
  count = 0
  pbCompilerEachPreppedLine("PBS/moves.txt") { |line,lineno|
    record = []
    lineRecord = pbGetCsvRecord(line,lineno,[0,"vnssueeuuuyiss",
       nil,nil,nil,nil,nil,PBTypes,["Physical","Special","Status"],
       nil,nil,nil,PBTargets,nil,nil,nil
    ])
    if lineRecord[6]==2 && lineRecord[4]!=0
      raise _INTL("Status moves must have a base damage of 0, use either Physical or Special\r\n{1}",FileLineData.linereport)
    end
    if lineRecord[6]!=2 && lineRecord[4]==0
      print _INTL("Warning: Physical and special moves can't have a base damage of 0, changing to a Status move\r\n{1}",FileLineData.linereport)
      lineRecord[6] = 2
    end
    record[MOVE_ID]            = lineRecord[0]
    record[MOVE_INTERNAL_NAME] = lineRecord[1]
    record[MOVE_NAME]          = lineRecord[2]
    record[MOVE_FUNCTION_CODE] = lineRecord[3]
    record[MOVE_BASE_DAMAGE]   = lineRecord[4]
    record[MOVE_TYPE]          = lineRecord[5]
    record[MOVE_CATEGORY]      = lineRecord[6]
    record[MOVE_ACCURACY]      = lineRecord[7]
    record[MOVE_TOTAL_PP]      = lineRecord[8]
    record[MOVE_EFFECT_CHANCE] = lineRecord[9]
    record[MOVE_TARGET]        = lineRecord[10]
    record[MOVE_PRIORITY]      = lineRecord[11]
    record[MOVE_FLAGS]         = lineRecord[12]
    record[MOVE_DESCRIPTION]   = lineRecord[13]
    maxValue = [maxValue,lineRecord[0]].max
    count += 1
    moveNames[lineRecord[0]] = lineRecord[2]    # Name
    moveDescs[lineRecord[0]] = lineRecord[13]   # Description
    records[lineRecord[0]]   = record
  }
  save_data(records,"Data/moves.dat")
  MessageTypes.setMessages(MessageTypes::Moves,moveNames)
  MessageTypes.setMessages(MessageTypes::MoveDescriptions,moveDescs)
  code = "class PBMoves\r\n"
  for rec in records
    code += "#{rec[MOVE_INTERNAL_NAME]}=#{rec[MOVE_ID]}\r\n" if rec
  end
  code += "def self.getName(id)\r\n"
  code += "id=getID(PBMoves,id)\r\n"
  code += "return pbGetMessage(MessageTypes::Moves,id); end\r\n"
  code += "def self.getCount; return #{count}; end\r\n"
  code += "def self.maxValue; return #{maxValue}; end\r\n"
  code += "end\r\n"
  eval(code)
  pbAddScript(code,"PBMoves")
end

#===============================================================================
# Compile battle animations
#===============================================================================
def pbCompileAnimations
  begin
    if $RPGVX
      pbanims = load_data("Data/PkmnAnimations.rvdata")
    else
      pbanims = load_data("Data/PkmnAnimations.rxdata")
    end
  rescue
    pbanims = PBAnimations.new
  end
  move2anim = [[],[]]
=begin
  if $RPGVX
    anims = load_data("Data/Animations.rvdata")
  else
    anims = load_data("Data/Animations.rxdata")
  end
  for anim in anims
    next if !anim || anim.frames.length==1
    found = false
    for i in 0...pbanims.length
      if pbanims[i] && pbanims[i].id==anim.id
        found = true if pbanims[i].array.length>1
        break
      end
    end
    pbanims[anim.id] = pbConvertRPGAnimation(anim) if !found
  end
=end
  for i in 0...pbanims.length
    next if !pbanims[i]
    if pbanims[i].name[/^OppMove\:\s*(.*)$/]
      if hasConst?(PBMoves,$~[1])
        moveid = PBMoves.const_get($~[1])
        move2anim[1][moveid] = i
      end
    elsif pbanims[i].name[/^Move\:\s*(.*)$/]
      if hasConst?(PBMoves,$~[1])
        moveid = PBMoves.const_get($~[1])
        move2anim[0][moveid] = i
      end
    end
  end
  save_data(move2anim,"Data/move2anim.dat")
  save_data(pbanims,"Data/PkmnAnimations.rxdata")
end

#===============================================================================
# Compile Pokémon
#===============================================================================
def pbCompilePokemonData
  # Get schemas.
  requiredValues = PokemonSpeciesData.requiredValues
  optionalValues = PokemonSpeciesData.optionalValues
  # Prepare arrays for compiled data.
  speciesData    = []
  movesets       = []
  eggMoves       = []
  regionalDexes  = []
  spriteMetrics  = []
  evolutions     = []
  speciesNames   = []
  formNames      = []
  pokedexKinds   = []
  pokedexEntries = []
  # Prepare variables used to record scripted constants.
  constants = ""
  maxValue = 0   # Highest species ID
  # Read from PBS file.
  File.open("PBS/pokemon.txt","rb") { |f|
    FileLineData.file = "PBS/pokemon.txt"   # For error reporting
    # Read a whole section's lines at once, then run through this code.
    # contents is a hash containing all the XXX=YYY lines in that section, where
    # the keys are the XXX and the values are the YYY (as unprocessed strings).
    pbEachFileSection(f) { |contents,speciesID|
      # Create array to store compiled data in.
      speciesData[speciesID] = []
      # Copy Type1 into Type2 if Type2 is undefined. (All species must have two
      # defined types; if both are the same, it is treated as single typed.)
      if !contents["Type2"] || contents["Type2"]==""
        if !contents["Type1"] || contents["Type1"]==""
          raise _INTL("No Pokémon type is defined in section {1} (PBS/pokemon.txt)",speciesID.to_s)
        end
        contents["Type2"] = contents["Type1"].clone
      end
      # Go through hashes of compilable data and compile this section.
      [requiredValues,optionalValues].each do |hash|
        for key in hash.keys
          FileLineData.setSection(speciesID,key,contents[key])   # For error reporting
          maxValue = [maxValue,speciesID].max   # Set highest species ID
          next if hash[key][0]<0   # Property is not to be compiled; skip it
          # Raise an error if the species ID is 0.
          if speciesID==0
            raise _INTL("A Pokémon species can't be numbered 0 (PBS/pokemon.txt)")
          end
          # Skip empty optional properties, or raise an error if a required
          # property is empty.
          if !contents[key] || contents[key]==""
            raise _INTL("Required entry {1} is missing or empty in section {2} (PBS/pokemon.txt)",
               key,speciesID.to_s) if hash==requiredValues
            next
          end
          # Compile value for key.
          schema = hash[key]
          value = pbGetCsvRecord(contents[key],key,schema)
          # Modify value as required.
          case key
          when "Height", "Weight"
            # Convert height/weight to 1 decimal place and multiply by 10.
            value = (value*10).round
            if value<=0
              raise _INTL("Value for '{1}' can't be less than or close to 0 (section {2}, PBS/pokemon.txt)",key,speciesID)
            end
          end
          # Add value to appropriate array for saving.
          case key
          when "Moves"
            speciesMoves = []
            for i in 0...value.length/2
              speciesMoves.push([value[i*2],value[i*2+1],i])
            end
            speciesMoves.sort! { |a,b| (a[0]==b[0]) ? a[2]<=>b[2] : a[0]<=>b[0] }
            for i in speciesMoves; i.pop; end
            movesets[speciesID] = speciesMoves
          when "EggMoves"
            if value.is_a?(Array); eggMoves[speciesID] = value
            else;                  eggMoves[speciesID] = [value]
            end
          when "RegionalNumbers"
            if value.is_a?(Array)
              value.each_with_index do |num,dexID|
                regionalDexes[dexID] = [] if !regionalDexes[dexID]
                regionalDexes[dexID][speciesID] = num
              end
            else
              regionalDexes[0] = [] if !regionalDexes[0]
              regionalDexes[0][speciesID] = value
            end
          when "BattlerPlayerX", "BattlerPlayerY",
               "BattlerEnemyX", "BattlerEnemyY",
               "BattlerAltitude", "BattlerShadowX", "BattlerShadowSize"
            spriteMetrics[schema[0]] = [] if !spriteMetrics[schema[0]]
            spriteMetrics[schema[0]][speciesID] = value
          when "Evolutions"
            speciesEvolutions  = []
            for i in 0...value.length/3
              speciesEvolutions.push([value[i*3],value[i*3+1],value[i*3+2],false])
            end
            evolutions[speciesID] = speciesEvolutions
          when "Name"
            speciesNames[speciesID] = value
          when "FormName"
            formNames[speciesID] = value
          when "Kind"
            pokedexKinds[speciesID] = value
          when "Pokedex"
            pokedexEntries[speciesID] = value
          when "InternalName"
            constants += "#{value}=#{speciesID}\r\n"
          else   # All other data
            speciesData[speciesID][schema[0]] = value
          end
        end
      end
    }
  }
  # All data is compiled now, just need to save it.
  raise _INTL("No Pokémon species are defined (PBS/pokemon.txt)") if speciesData.length==0
  # Write all constants and some helpful code for PBSpecies.
  count = speciesData.compact.length
  code = "module PBSpecies\r\n#{constants}"
  code += "def PBSpecies.getName(id)\r\n"
  code += "id=getID(PBSpecies,id)\r\n"
  code += "return pbGetMessage(MessageTypes::Species,id); end\r\n"
  code += "def PBSpecies.getCount; return #{count}; end\r\n"
  code += "def PBSpecies.maxValue; return #{maxValue}; end\r\n"
  code += "end\r\n"
  eval(code)
  pbAddScript(code,"PBSpecies")
  # Save main species data.
  save_data(speciesData,"Data/species.dat")
  # Save movesets data.
  save_data(movesets,"Data/species_movesets.dat")
  # Save egg moves data.
  save_data(eggMoves,"Data/species_eggmoves.dat")
  # Save regional dexes data.
  save_data(regionalDexes,"Data/regional_dexes.dat")
  # Save metrics data.
  for i in 0...7
    defaultValue = (i==MetricBattlerShadowSize) ? 2 : 0   # Shadow size 2, other metrics 0
    for j in 0..maxValue
      spriteMetrics[i] = [] if !spriteMetrics[i]
      spriteMetrics[i][j] ||= defaultValue
    end
  end
  save_data(spriteMetrics,"Data/species_metrics.dat")
  # Evaluate evolution data (has to be done after all species are read).
  for e in 0...evolutions.length
    next if !evolutions[e]
    evolutions[e].each_with_index do |evo,i|
      FileLineData.setSection(i,"Evolutions","")
      evo[0] = csvEnumField!(evo[0],PBSpecies,"Evolutions",i)   # Species
      param_type = PBEvolution.getFunction(evo[1], "parameterType")
      if param_type
        evo[2] = csvEnumField!(evo[2], param_type, "Evolutions", i)
      else
        evo[2] = csvInt!(evo[2]) if evo[2] && evo[2] != ""
      end
    end
  end
  # Add prevolution data to all species as the first "evolution method".
  for sp in 1..maxValue
    next if !evolutions[sp]
    preSpecies = -1
    evoData = nil
    # Check for another species that evolves into sp.
    for f in 0...evolutions.length
      next if !evolutions[f] || f==sp
      evolutions[f].each do |evo|
        next if evo[0]!=sp || evo[3]   # Evolved species isn't sp or is a prevolution
        preSpecies = f   # f evolves into sp
        evoData = evo
        break
      end
      break if evoData
    end
    next if !evoData   # evoData[1]=method, evoData[2]=level - both are unused
    # Found a species that evolves into e, record it as a prevolution.
    evolutions[sp] = [[preSpecies,evoData[1],evoData[2],true]].concat(evolutions[sp])
  end
  # Save evolutions data.
  save_data(evolutions,"Data/species_evolutions.dat")
  # Save all messages.
  speciesNames.map! { |name| name || "????????" }
  MessageTypes.setMessages(MessageTypes::Species,speciesNames)
  MessageTypes.setMessages(MessageTypes::FormNames,formNames)
  MessageTypes.setMessages(MessageTypes::Kinds,pokedexKinds)
  MessageTypes.setMessages(MessageTypes::Entries,pokedexEntries)
end

#===============================================================================
# Compile Pokémon forms
#===============================================================================
def pbCompilePokemonForms
  # Get schemas.
  requiredValues = PokemonSpeciesData.requiredValues(true)
  optionalValues = PokemonSpeciesData.optionalValues(true)
  # Prepare arrays for compiled data.
  speciesData    = pbLoadSpeciesData
  movesets       = []
  eggMoves       = []
  spriteMetrics  = []
  evolutions     = []
  formNames      = []
  pokedexKinds   = []
  pokedexEntries = []
  formToSpecies  = []   # Saved
  speciesToForm  = []   # Only used in this method
  for i in 1..PBSpecies.maxValue
    formToSpecies[i] = [i]
    speciesToForm[i] = i
  end
  # Prepare variables used to record scripted constants.
  constants = ""
  maxValue = PBSpecies.maxValue   # Highest species ID
  # Read from PBS file.
  File.open("PBS/pokemonforms.txt","rb") { |f|
    FileLineData.file = "PBS/pokemonforms.txt"   # For error reporting
    # Read a whole section's lines at once, then run through this code.
    # contents is a hash containing all the XXX=YYY lines in that section, where
    # the keys are the XXX and the values are the YYY (as unprocessed strings).
    pbEachFileSection2(f) { |contents,sectionName|
      # Split sectionName into a species number and form number.
      splitSectionName = sectionName.split(/[-,\s]/)
      if splitSectionName.length!=2
        raise _INTL("Section name {1} is invalid (PBS/pokemonforms.txt). Expected syntax like [XXX,Y] (XXX=internal name, Y=form number).",sectionName)
      end
      baseSpeciesID = parseSpecies(splitSectionName[0])
      form          = csvInt!(splitSectionName[1])
      # Ensure this is a valid form and not a duplicate.
      if form==0
        raise _INTL("Form {1} is invalid (PBS/pokemonforms.txt). Form 0 data should be defined in \"PBS/pokemon.txt\".",sectionName)
      end
      if formToSpecies[baseSpeciesID] && formToSpecies[baseSpeciesID][form]
        raise _INTL("Form {1} is defined at least twice (PBS/pokemonforms.txt). It should only be defined once.",sectionName)
      end
      # Record new species number in formToSpecies.
      speciesID = baseSpeciesID
      if form>0
        maxValue += 1
        speciesID = maxValue
        formToSpecies[baseSpeciesID] = [] if !formToSpecies[baseSpeciesID]
        formToSpecies[baseSpeciesID][form] = speciesID
        speciesToForm[speciesID] = baseSpeciesID
      end
      # Generate internal name for this form.
      cName = getConstantName(PBSpecies,baseSpeciesID).to_s+"_"+form.to_s
      constants += "#{cName}=#{speciesID}\r\n"
      # Create array to store compiled data in.
      speciesData[speciesID] = []
      # Clone data from base form as a starting point.
      speciesData[baseSpeciesID].each_with_index do |val,i|
        speciesData[speciesID][i] = (val.is_a?(Array)) ? val.clone : val
      end
      # Copy Type1 into Type2 if if Type1 is defined but Type2 isn't. (Shouldn't
      # inherit either of the base form's types if Type1 is defined for a form.)
      if contents["Type1"] && contents["Type1"]!=""
        if !contents["Type2"] || contents["Type2"]==""
          contents["Type2"] = contents["Type1"].clone
        end
      end
      # If any held item is defined for this form, clear default data for all
      # three held items.
      if (contents["WildItemCommon"] && contents["WildItemCommon"]!="") ||
         (contents["WildItemUncommon"] && contents["WildItemUncommon"]!="") ||
         (contents["WildItemRare"] && contents["WildItemRare"]!="")
        speciesData[speciesID][SpeciesWildItemCommon]   = nil
        speciesData[speciesID][SpeciesWildItemUncommon] = nil
        speciesData[speciesID][SpeciesWildItemRare]     = nil
      end
      # Go through hashes of compilable data and compile this section.
      [requiredValues,optionalValues].each do |hash|
        for key in hash.keys
          FileLineData.setSection(speciesID,key,contents[key])   # For error reporting
          next if hash[key][0]<0   # Property is not to be compiled; skip it
          # Skip empty properties (none are required).
          next if !contents[key] || contents[key]==""
          # Compile value for key.
          schema = hash[key]
          value = pbGetCsvRecord(contents[key],key,schema)
          # Modify value as required.
          case key
          when "Height", "Weight"
            # Convert height/weight to 1 decimal place and multiply by 10.
            value = (value*10).round
            if value<=0
              raise _INTL("Value for '{1}' can't be less than or close to 0 (section {2}, PBS/pokemonforms.txt)",key,speciesID)
            end
          end
          # Add value to appropriate array for saving.
          case key
          when "Moves"
            speciesMoves = []
            for i in 0...value.length/2
              speciesMoves.push([value[i*2],value[i*2+1],i])
            end
            speciesMoves.sort! { |a,b| (a[0]==b[0]) ? a[2]<=>b[2] : a[0]<=>b[0] }
            for i in speciesMoves; i.pop; end
            movesets[speciesID] = speciesMoves
          when "EggMoves"
            if value.is_a?(Array); eggMoves[speciesID] = value
            else;                  eggMoves[speciesID] = [value]
            end
          when "BattlerPlayerX", "BattlerPlayerY",
               "BattlerEnemyX", "BattlerEnemyY",
               "BattlerAltitude", "BattlerShadowX", "BattlerShadowSize"
            spriteMetrics[schema[0]] = [] if !spriteMetrics[schema[0]]
            spriteMetrics[schema[0]][speciesID] = value
          when "Evolutions"
            speciesEvolutions  = []
            for i in 0...value.length/3
              speciesEvolutions.push([value[i*3],value[i*3+1],value[i*3+2],false])
            end
            evolutions[speciesID] = speciesEvolutions
          when "FormName"
            formNames[speciesID] = value
          when "Kind"
            pokedexKinds[speciesID] = value
          when "Pokedex"
            pokedexEntries[speciesID] = value
          else   # All other data
            speciesData[speciesID][schema[0]] = value
          end
        end
      end
    }
  }
  # All data is compiled now, just need to save it.
  # Write all constants and some helpful code for PBSpecies.
  code = "module PBSpecies\r\n#{constants}"
  code += "def PBSpecies.maxValueF; return #{maxValue}; end\r\n"
  code += "end\r\n"
  eval(code)
  pbAddScript(code,"PBSpecies")
  # Save main species data.
  save_data(speciesData,"Data/species.dat")
  # Save conversions of form to species data.
  save_data(formToSpecies,"Data/form2species.dat")
  # Inherit base form moveset.
  newMovesets = pbLoadMovesetsData
  pbAppendToBaseFormData(PBSpecies.maxValue+1,maxValue,newMovesets,movesets,speciesToForm,true)
  save_data(newMovesets,"Data/species_movesets.dat")
  $PokemonTemp.speciesMovesets = nil if $PokemonTemp
  # Inherit base form egg moves.
  newEggMoves = pbLoadEggMovesData
  pbAppendToBaseFormData(PBSpecies.maxValue+1,maxValue,newEggMoves,eggMoves,speciesToForm,false)
  save_data(newEggMoves,"Data/species_eggmoves.dat")
  $PokemonTemp.speciesEggMoves = nil if $PokemonTemp
  # Inherit base form metrics data.
  newSpriteMetrics = pbLoadSpeciesMetrics
  for i in 0...7
    defaultValue = (i==MetricBattlerShadowSize) ? 2 : 0   # Shadow size 2, other metrics 0
    pbAppendToBaseFormData(PBSpecies.maxValue+1,maxValue,newSpriteMetrics[i],
       spriteMetrics[i] || [],speciesToForm,false,defaultValue)
  end
  save_data(newSpriteMetrics,"Data/species_metrics.dat")
  # Evaluate evolution data (has to be done after all species are read).
  for e in 0...evolutions.length
    next if !evolutions[e]
    evolutions[e].each_with_index do |evo,i|
      FileLineData.setSection(i,"Evolutions","")
      evo[0] = csvEnumField!(evo[0],PBSpecies,"Evolutions",i)   # Species
      param_type = PBEvolution.getFunction(evo[1], "parameterType")
      if param_type
        evo[2] = csvEnumField!(evo[2], param_type, "Evolutions", i)
      else
        evo[2] = csvPosInt!(evo[2]) if evo[2] && evo[2] != ""
      end
    end
  end
  # Inherit base form evolution methods.
  newEvolutions = pbLoadEvolutionsData
  pbAppendToBaseFormData(PBSpecies.maxValue+1,maxValue,newEvolutions,evolutions,speciesToForm,true)
  # Add prevolution data to all species as the first "evolution method".
  for i in (PBSpecies.maxValue+1)..maxValue
    baseSpecies = speciesToForm[i]
    preSpecies = -1
    evoData = nil
    # Check for another species that evolves into baseSpecies.
    for f in 0...newEvolutions.length
      next if !newEvolutions[f] || speciesToForm[f]==baseSpecies
      newEvolutions[f].each do |evo|
        next if evo[0]!=baseSpecies || evo[3]   # Evolved species isn't baseSpecies or is a prevolution
        preSpecies = speciesToForm[f]   # f evolves into baseSpecies
        evoData = evo
        break
      end
      break if evoData
    end
    next if !evoData   # evoData[1]=method, evoData[2]=level - both are unused
    # Found a species that evolves into e, record it as a prevolution.
    if newEvolutions[i]
      newEvolutions[i] = [[preSpecies,evoData[1],evoData[2],true]].concat(newEvolutions[i])
    else
      newEvolutions[i] = [[preSpecies,evoData[1],evoData[2],true]]
    end
  end
  # Save evolutions data.
  save_data(newEvolutions,"Data/species_evolutions.dat")
  $PokemonTemp.evolutionsData = nil if $PokemonTemp
  # Save all messages.
  MessageTypes.addMessages(MessageTypes::FormNames,formNames)
  MessageTypes.addMessages(MessageTypes::Kinds,pokedexKinds)
  MessageTypes.addMessages(MessageTypes::Entries,pokedexEntries)
end

def pbAppendToBaseFormData(idxStart,idxEnd,baseData,extraData,speciesToForm,clone=false,defaultValue=nil)
  for i in idxStart..idxEnd
    if extraData[i]
      baseData[i] = extraData[i]
    else
      species = speciesToForm[i]
      if baseData[species]
        if clone
          baseData[i] = []
          baseData[species].each { |datum| baseData[i].push(datum.clone) }
        elsif baseData[species].is_a?(Array)
          baseData[i] = baseData[species].clone
        else
          baseData[i] = baseData[species]
        end
      else
        baseData[i] = defaultValue
      end
    end
  end
end

#===============================================================================
# Compile TM/TM/Move Tutor compatibilities
#===============================================================================
def pbTMRS   # Backup Gen 3 TM list
  rstm = [
        # TMs
        :FOCUSPUNCH,:DRAGONCLAW,:WATERPULSE,:CALMMIND,:ROAR,
        :TOXIC,:HAIL,:BULKUP,:BULLETSEED,:HIDDENPOWER,
        :SUNNYDAY,:TAUNT,:ICEBEAM,:BLIZZARD,:HYPERBEAM,
        :LIGHTSCREEN,:PROTECT,:RAINDANCE,:GIGADRAIN,:SAFEGUARD,
        :FRUSTRATION,:SOLARBEAM,:IRONTAIL,:THUNDERBOLT,:THUNDER,
        :EARTHQUAKE,:RETURN,:DIG,:PSYCHIC,:SHADOWBALL,
        :BRICKBREAK,:DOUBLETEAM,:REFLECT,:SHOCKWAVE,:FLAMETHROWER,
        :SLUDGEBOMB,:SANDSTORM,:FIREBLAST,:ROCKTOMB,:AERIALACE,
        :TORMENT,:FACADE,:SECRETPOWER,:REST,:ATTRACT,
        :THIEF,:STEELWING,:SKILLSWAP,:SNATCH,:OVERHEAT,
        # HMs
        :CUT,:FLY,:SURF,:STRENGTH,:FLASH,:ROCKSMASH,:WATERFALL,:DIVE
  ]
  ret = []
  rstm.length.times do
    ret.push((parseMove(rstm.to_s) rescue 0))
  end
  return ret
end

def pbCompileMachines
  lineno = 1
  havesection = false
  sectionname = nil
  sections    = []
  if safeExists?("PBS/tm.txt")
    f = File.open("PBS/tm.txt","rb")
    FileLineData.file="PBS/tm.txt"
    f.each_line { |line|
      if lineno==1 && line[0]==0xEF && line[1]==0xBB && line[2]==0xBF
        line = line[3,line.length-3]
      end
      FileLineData.setLine(line,lineno)
      if !line[/^\#/] && !line[/^\s*$/]
        if line[/^\s*\[\s*(.*)\s*\]\s*$/]
          sectionname = parseMove($~[1])
          sections[sectionname] = WordArray.new
          havesection = true
        else
          if sectionname==nil
            raise _INTL("Expected a section at the beginning of the file. This error may also occur if the file was not saved in UTF-8.\r\n{1}",
               FileLineData.linereport)
          end
          specieslist = line.sub(/\s+$/,"").split(",")
          for species in specieslist
            next if !species || species==""
            sec = sections[sectionname]
            sec[sec.length] = parseSpecies(species)
          end
        end
      end
      lineno += 1
      Graphics.update if lineno%50==0
      Win32API.SetWindowText(_INTL("Processing {1} line {2}",FileLineData.file,lineno)) if lineno%50==0
    }
    f.close
  elsif safeExists?("Data/tmRS.dat")
    tmrs = pbTMRS()
    for i in 0...tmrs.length
      next if !tmrs[i] || tmrs[i]==0
      sections[tmrs[i]] = []
    end
    File.open("Data/tmRS.dat","rb") { |f|
      species = 1
      while !f.eof?
        data = f.read(8)+"\0\0\0\0\0\0\0\0"
        for i in 0...58
          next if !tmrs[i] || tmrs[i]==0
          if (data[i>>3]&(1<<(i&7)))!=0
            sections[tmrs[i]].push(species)
          end
        end
        species += 1
      end
    }
  end
  save_data(sections,"Data/tm.dat")
end

#===============================================================================
# Compile Shadow moves
#===============================================================================
def pbCompileShadowMoves
  sections = []
  if File.exists?("PBS/shadowmoves.txt")
    pbCompilerEachCommentedLine("PBS/shadowmoves.txt") { |line,_lineno|
      if line[ /^\s*(\w+)\s*=\s*(.*)$/ ]
        key   = $1
        value = $2
        value = value.split(",")
        species = parseSpecies(key)
        moves = []
        for i in 0...[4,value.length].min
          moves.push((parseMove(value[i]) rescue nil))
        end
        moves.compact!
        sections[species] = moves if moves.length>0
      end
    }
  end
  save_data(sections,"Data/shadow_movesets.dat")
end

#===============================================================================
# Compile wild encounters
#===============================================================================
def pbCompileEncounters
  lines   = []
  linenos = []
  FileLineData.file = "PBS/encounters.txt"
  File.open("PBS/encounters.txt","rb") { |f|
    lineno = 1
    f.each_line { |line|
      if lineno==1 && line[0]==0xEF && line[1]==0xBB && line[2]==0xBF
        line = line[3,line.length-3]
      end
      line = prepline(line)
      if line.length!=0
        lines[lines.length] = line
        linenos[linenos.length] = lineno
      end
      lineno += 1
    }
  }
  encounters  = {}
  thisenc     = nil
  needdensity = false
  lastmapid   = -1
  i = 0
  while i<lines.length
    line = lines[i]
    FileLineData.setLine(line,linenos[i])
    mapid = line[/^\d+$/]
    if mapid
      lastmapid = mapid
      if thisenc && (thisenc[1][EncounterTypes::Land] ||
                     thisenc[1][EncounterTypes::LandMorning] ||
                     thisenc[1][EncounterTypes::LandDay] ||
                     thisenc[1][EncounterTypes::LandNight] ||
                     thisenc[1][EncounterTypes::BugContest]) &&
                     thisenc[1][EncounterTypes::Cave]
        raise _INTL("Can't define both Land and Cave encounters in the same area (map ID {1})",mapid)
      end
      thisenc = [EncounterTypes::EnctypeDensities.clone,[]]
      encounters[mapid.to_i] = thisenc
      needdensity = true
      i += 1
      next
    end
    enc = findIndex(EncounterTypes::Names) { |val| val==line }
    if enc>=0
      needdensity = false
      enclines = EncounterTypes::EnctypeChances[enc].length
      encarray = []
      j = i+1; k = 0
      while j<lines.length && k<enclines
        line = lines[j]
        FileLineData.setLine(lines[j],linenos[j])
        splitarr = strsplit(line,/\s*,\s*/)
        if !splitarr || splitarr.length<2
          raise _INTL("Expected a species entry line, got \"{1}\" instead. Check the number of species lines in the previous section (number {2}).\r\n{3}",
             line,lastmapid,FileLineData.linereport)
        end
        splitarr[2] = splitarr[1] if splitarr.length==2
        splitarr[1] = splitarr[1].to_i
        splitarr[2] = splitarr[2].to_i
        maxlevel = PBExperience.maxLevel
        if splitarr[1]<=0 || splitarr[1]>maxlevel
          raise _INTL("Level number is not valid: {1}\r\n{2}",splitarr[1],FileLineData.linereport)
        end
        if splitarr[2]<=0 || splitarr[2]>maxlevel
          raise _INTL("Level number is not valid: {1}\r\n{2}",splitarr[2],FileLineData.linereport)
        end
        if splitarr[1]>splitarr[2]
          raise _INTL("Minimum level is greater than maximum level: {1}\r\n{2}",line,FileLineData.linereport)
        end
        splitarr[0] = parseSpecies(splitarr[0])
        encarray.push(splitarr)
        thisenc[1][enc] = encarray
        j += 1; k += 1
      end
      if j==lines.length && k<enclines
        raise _INTL("Reached end of file unexpectedly. There were too few species entry lines in the last section (number {1}), expected {2} entries.\r\n{3}",
           lastmapid,enclines,FileLineData.linereport)
      end
      i = j
    elsif needdensity
      needdensity = false
      nums = strsplit(line,/,/)
      if nums && nums.length>=3
        for j in 0...EncounterTypes::EnctypeChances.length
          next if !EncounterTypes::EnctypeChances[j] ||
                  EncounterTypes::EnctypeChances[j].length==0
          next if EncounterTypes::EnctypeCompileDens[j]==0
          thisenc[0][j] = nums[EncounterTypes::EnctypeCompileDens[j]-1].to_i
        end
      else
        raise _INTL("Wrong syntax for densities in encounters.txt; got \"{1}\"\r\n{2}",line,FileLineData.linereport)
      end
      i += 1
    else
      raise _INTL("Undefined encounter type {1}, expected one of the following:\r\n{2}\r\n{3}",line,EncounterTypes::Names.inspect,FileLineData.linereport)
    end
  end
  save_data(encounters,"Data/encounters.dat")
end

#===============================================================================
# Compile trainer types
#===============================================================================
def pbCompileTrainerTypes
  # Trainer types
  records = []
  trainernames = []
  maxValue = 0
  pbCompilerEachPreppedLine("PBS/trainertypes.txt") { |line,lineno|
    record=pbGetCsvRecord(line,lineno,[0,"unsUSSSeUS",   # ID can be 0
       nil,nil,nil,nil,nil,nil,nil,{
       "" => 2,
       "Male" => 0,"M" => 0,"0" => 0,
       "Female" => 1,"F" => 1,"1" => 1,
       "Mixed" => 2,"X" => 2,"2" => 2
       },nil,nil]
    )
    if records[record[0]]
      raise _INTL("Two trainer types ({1} and {2}) have the same ID ({3}), which is not allowed.\r\n{4}",
         records[record[0]][1],record[1],record[0],FileLineData.linereport)
    end
    trainernames[record[0]] = record[2]
    records[record[0]]      = record
    maxValue = [maxValue,record[0]].max
  }
  count = records.compact.length
  MessageTypes.setMessages(MessageTypes::TrainerTypes,trainernames)
  code = "class PBTrainers\r\n"
  for rec in records
    next if !rec
    code += "#{rec[1]}=#{rec[0]}\r\n"
  end
  code += "def self.getName(id)\r\n"
  code += "id=getID(PBTrainers,id)\r\n"
  code += "return pbGetMessage(MessageTypes::TrainerTypes,id); end\r\n"
  code += "def self.getCount; return #{count}; end\r\n"
  code += "def self.maxValue; return #{maxValue}; end\r\n"
  code += "end\r\n"
  eval(code)
  pbAddScript(code,"PBTrainers")
  save_data(records,"Data/trainer_types.dat")
end

#===============================================================================
# Compile individual trainers
#===============================================================================
def pbCompileTrainers
  trainer_info_types = TrainersMetadata::InfoTypes
  mLevel = PBExperience.maxLevel
  trainerindex    = -1
  trainers        = []
  trainernames    = []
  trainerlosetext = []
  pokemonindex    = -2
  oldcompilerline   = 0
  oldcompilerlength = 0
  pbCompilerEachCommentedLine("PBS/trainers.txt") { |line,lineno|
    if line[/^\s*\[\s*(.+)\s*\]\s*$/]
      # Section [trainertype,trainername] or [trainertype,trainername,partyid]
      if oldcompilerline>0
        raise _INTL("Previous trainer not defined with as many Pokémon as expected\r\n{1}",FileLineData.linereport)
      end
      if pokemonindex==-1
        raise _INTL("Started new trainer while previous trainer has no Pokémon\r\n{1}",FileLineData.linereport)
      end
      section = pbGetCsvRecord($~[1],lineno,[0,"esU",PBTrainers])
      trainerindex += 1
      trainertype = section[0]
      trainername = section[1]
      partyid     = section[2] || 0
      trainers[trainerindex] = [trainertype,trainername,[],[],partyid,nil]
      trainernames[trainerindex] = trainername
      pokemonindex = -1
    elsif line[/^\s*(\w+)\s*=\s*(.*)$/]
      # XXX=YYY lines
      if trainerindex<0
        raise _INTL("Expected a section at the beginning of the file\r\n{1}",FileLineData.linereport)
      end
      if oldcompilerline>0
        raise _INTL("Previous trainer not defined with as many Pokémon as expected\r\n{1}",FileLineData.linereport)
      end
      settingname = $~[1]
      schema = trainer_info_types[settingname]
      next if !schema
      record = pbGetCsvRecord($~[2],lineno,schema)
      # Error checking in XXX=YYY lines
      case settingname
      when "Pokemon"
        if record[1]>mLevel
          raise _INTL("Bad level: {1} (must be 1-{2})\r\n{3}",record[1],mLevel,FileLineData.linereport)
        end
      when "Moves"
        record = [record] if record.is_a?(Integer)
        record.compact!
      when "Ability"
        if record>5
          raise _INTL("Bad ability flag: {1} (must be 0 or 1 or 2-5)\r\n{2}",record,FileLineData.linereport)
        end
      when "IV"
        record = [record] if record.is_a?(Integer)
        record.compact!
        for i in record
          next if i<=PokeBattle_Pokemon::IV_STAT_LIMIT
          raise _INTL("Bad IV: {1} (must be 0-{2})\r\n{3}",i,PokeBattle_Pokemon::IV_STAT_LIMIT,FileLineData.linereport)
        end
      when "EV"
        record = [record] if record.is_a?(Integer)
        record.compact!
        for i in record
          next if i<=PokeBattle_Pokemon::EV_STAT_LIMIT
          raise _INTL("Bad EV: {1} (must be 0-{2})\r\n{3}",i,PokeBattle_Pokemon::EV_STAT_LIMIT,FileLineData.linereport)
        end
        evtotal = 0
        for i in 0...6
          evtotal += (i<record.length) ? record[i] : record[0]
        end
        if evtotal>PokeBattle_Pokemon::EV_LIMIT
          raise _INTL("Total EVs are greater than allowed ({1})\r\n{2}",PokeBattle_Pokemon::EV_LIMIT,FileLineData.linereport)
        end
      when "Happiness"
        if record>255
          raise _INTL("Bad happiness: {1} (must be 0-255)\r\n{2}",record,FileLineData.linereport)
        end
      when "Name"
        if record.length>PokeBattle_Pokemon::MAX_POKEMON_NAME_SIZE
          raise _INTL("Bad nickname: {1} (must be 1-{2} characters)\r\n{3}",record,PokeBattle_Pokemon::MAX_POKEMON_NAME_SIZE,FileLineData.linereport)
        end
      end
      # Record XXX=YYY setting
      case settingname
      when "Items"   # Items in the trainer's Bag, not the held item
        record = [record] if record.is_a?(Integer)
        record.compact!
        trainers[trainerindex][2] = record
      when "LoseText"
        trainerlosetext[trainerindex] = record
        trainers[trainerindex][5] = record
      when "Pokemon"
        pokemonindex += 1
        trainers[trainerindex][3][pokemonindex] = []
        trainers[trainerindex][3][pokemonindex][TPSPECIES] = record[0]
        trainers[trainerindex][3][pokemonindex][TPLEVEL]   = record[1]
      else
        if pokemonindex<0
          raise _INTL("Pokémon hasn't been defined yet!\r\n{1}",FileLineData.linereport)
        end
        trainers[trainerindex][3][pokemonindex][schema[0]] = record
      end
    else
      # Old compiler - backwards compatibility is SUCH fun!
      if pokemonindex==-1 && oldcompilerline==0
        raise _INTL("Unexpected line format, started new trainer while previous trainer has no Pokémon\r\n{1}",FileLineData.linereport)
      end
      if oldcompilerline==0   # Started an old trainer section
        oldcompilerlength = 3
        oldcompilerline   = 0
        trainerindex += 1
        trainers[trainerindex] = [0,"",[],[],0]
        pokemonindex = -1
      end
      oldcompilerline += 1
      case oldcompilerline
      when 1   # Trainer type
        record = pbGetCsvRecord(line,lineno,[0,"e",PBTrainers])
        trainers[trainerindex][0] = record
      when 2   # Trainer name, version number
        record = pbGetCsvRecord(line,lineno,[0,"sU"])
        record = [record] if record.is_a?(Integer)
        trainers[trainerindex][1] = record[0]
        trainernames[trainerindex] = record[0]
        trainers[trainerindex][4] = record[1] if record[1]
      when 3   # Number of Pokémon, items
        record = pbGetCsvRecord(line,lineno,[0,"vEEEEEEEE",nil,PBItems,PBItems,
                                PBItems,PBItems,PBItems,PBItems,PBItems,PBItems])
        record = [record] if record.is_a?(Integer)
        record.compact!
        oldcompilerlength += record[0]
        record.shift
        trainers[trainerindex][2] = record if record
      else   # Pokémon lines
        pokemonindex += 1
        trainers[trainerindex][3][pokemonindex] = []
        record = pbGetCsvRecord(line,lineno,
           [0,"evEEEEEUEUBEUUSBU",PBSpecies,nil, PBItems,PBMoves,PBMoves,PBMoves,
                                  PBMoves,nil,{"M"=>0,"m"=>0,"Male"=>0,"male"=>0,
                                  "0"=>0,"F"=>1,"f"=>1,"Female"=>1,"female"=>1,
                                  "1"=>1},nil,nil,PBNatures,nil,nil,nil,nil,nil])
        # Error checking (the +3 is for properties after the four moves)
        for i in 0...record.length
          next if record[i]==nil
          case i
          when TPLEVEL
            if record[i]>mLevel
              raise _INTL("Bad level: {1} (must be 1-{2})\r\n{3}",record[i],mLevel,FileLineData.linereport)
            end
          when TPABILITY+3
            if record[i]>5
              raise _INTL("Bad ability flag: {1} (must be 0 or 1 or 2-5)\r\n{2}",record[i],FileLineData.linereport)
            end
          when TPIV+3
            if record[i]>31
              raise _INTL("Bad IV: {1} (must be 0-31)\r\n{2}",record[i],FileLineData.linereport)
            end
            record[i] = [record[i]]
          when TPEV+3
            if record[i]>PokeBattle_Pokemon::EV_STAT_LIMIT
              raise _INTL("Bad EV: {1} (must be 0-{2})\r\n{3}",record[i],PokeBattle_Pokemon::EV_STAT_LIMIT,FileLineData.linereport)
            end
            record[i] = [record[i]]
          when TPHAPPINESS+3
            if record[i]>255
              raise _INTL("Bad happiness: {1} (must be 0-255)\r\n{2}",record[i],FileLineData.linereport)
            end
          when TPNAME+3
            if record[i].length>PokeBattle_Pokemon::MAX_POKEMON_NAME_SIZE
              raise _INTL("Bad nickname: {1} (must be 1-{2} characters)\r\n{3}",record[i],PokeBattle_Pokemon::MAX_POKEMON_NAME_SIZE,FileLineData.linereport)
            end
          end
        end
        # Write data to trainer array
        for i in 0...record.length
          next if record[i]==nil
          if i>=TPMOVES && i<TPMOVES+4
            if !trainers[trainerindex][3][pokemonindex][TPMOVES]
              trainers[trainerindex][3][pokemonindex][TPMOVES] = []
            end
            trainers[trainerindex][3][pokemonindex][TPMOVES].push(record[i])
          else
            d = (i>=TPMOVES+4) ? i-3 : i
            trainers[trainerindex][3][pokemonindex][d] = record[i]
          end
        end
      end
      oldcompilerline = 0 if oldcompilerline>=oldcompilerlength
    end
  }
  save_data(trainers,"Data/trainers.dat")
  MessageTypes.setMessagesAsHash(MessageTypes::TrainerNames,trainernames)
  MessageTypes.setMessagesAsHash(MessageTypes::TrainerLoseText,trainerlosetext)
end

#===============================================================================
# Compile Battle Tower and other Cups trainers/Pokémon
#===============================================================================
def pbCompileBTTrainers(filename)
  sections = []
  requiredtypes = {
     "Type"          => [0, "e",PBTrainers],
     "Name"          => [1, "s"],
     "BeginSpeech"   => [2, "s"],
     "EndSpeechWin"  => [3, "s"],
     "EndSpeechLose" => [4, "s"],
     "PokemonNos"    => [5, "*u"]
  }
  trainernames  = []
  beginspeech   = []
  endspeechwin  = []
  endspeechlose = []
  if safeExists?(filename)
    File.open(filename,"rb") { |f|
      FileLineData.file = filename
      pbEachFileSectionEx(f) { |section,name|
        rsection = []
        for key in section.keys
          FileLineData.setSection(name,key,section[key])
          schema = requiredtypes[key]
          next if !schema
          record = pbGetCsvRecord(section[key],0,schema)
          rsection[schema[0]] = record
        end
        trainernames.push(rsection[1])
        beginspeech.push(rsection[2])
        endspeechwin.push(rsection[3])
        endspeechlose.push(rsection[4])
        sections.push(rsection)
      }
    }
  end
  MessageTypes.addMessagesAsHash(MessageTypes::TrainerNames,trainernames)
  MessageTypes.addMessagesAsHash(MessageTypes::BeginSpeech,beginspeech)
  MessageTypes.addMessagesAsHash(MessageTypes::EndSpeechWin,endspeechwin)
  MessageTypes.addMessagesAsHash(MessageTypes::EndSpeechLose,endspeechlose)
  return sections
end

def pbCompileTrainerLists
  btTrainersRequiredTypes = {
     "Trainers"   => [0, "s"],
     "Pokemon"    => [1, "s"],
     "Challenges" => [2, "*s"]
  }
  if !safeExists?("PBS/trainerlists.txt")
    File.open("PBS/trainerlists.txt","wb") { |f|
      f.write(0xEF.chr)
      f.write(0xBB.chr)
      f.write(0xBF.chr)
      f.write("[DefaultTrainerList]\r\n")
      f.write("Trainers = bttrainers.txt\r\n")
      f.write("Pokemon = btpokemon.txt\r\n")
    }
  end
  sections = []
  MessageTypes.setMessagesAsHash(MessageTypes::BeginSpeech,[])
  MessageTypes.setMessagesAsHash(MessageTypes::EndSpeechWin,[])
  MessageTypes.setMessagesAsHash(MessageTypes::EndSpeechLose,[])
  File.open("PBS/trainerlists.txt","rb") { |f|
    FileLineData.file = "PBS/trainerlists.txt"
    pbEachFileSectionEx(f) { |section,name|
      next if name!="DefaultTrainerList" && name!="TrainerList"
      rsection = []
      for key in section.keys
        FileLineData.setSection(name,key,section[key])
        schema = btTrainersRequiredTypes[key]
        next if key=="Challenges" && name=="DefaultTrainerList"
        next if !schema
        record = pbGetCsvRecord(section[key],0,schema)
        rsection[schema[0]] = record
      end
      if !rsection[0]
        raise _INTL("No trainer data file given in section {1}\r\n{2}",name,FileLineData.linereport)
      end
      if !rsection[1]
        raise _INTL("No trainer data file given in section {1}\r\n{2}",name,FileLineData.linereport)
      end
      rsection[3] = rsection[0]
      rsection[4] = rsection[1]
      rsection[5] = (name=="DefaultTrainerList")
      if safeExists?("PBS/"+rsection[0])
        rsection[0] = pbCompileBTTrainers("PBS/"+rsection[0])
      else
        rsection[0] = []
      end
      if safeExists?("PBS/"+rsection[1])
        filename = "PBS/"+rsection[1]
        rsection[1] = []
        pbCompilerEachCommentedLine(filename) { |line,_lineno|
          rsection[1].push(PBPokemon.fromInspected(line))
        }
      else
        rsection[1] = []
      end
      rsection[2] = [] if !rsection[2]
      while rsection[2].include?("")
        rsection[2].delete("")
      end
      rsection[2].compact!
      sections.push(rsection)
    }
  }
  save_data(sections,"Data/trainer_lists.dat")
end
