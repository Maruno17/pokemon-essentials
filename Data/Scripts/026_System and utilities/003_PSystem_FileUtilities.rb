#===============================================================================
# Load Pokémon sprites
#===============================================================================
def pbLoadPokemonBitmap(pokemon,back=false)
  return pbLoadPokemonBitmapSpecies(pokemon,pokemon.species,back)
end

# NOTE: Returns an AnimatedBitmap, not a Bitmap
def pbLoadPokemonBitmapSpecies(pokemon,species,back=false)
  ret = nil
  if pokemon.egg?
    bitmapFileName = sprintf("Graphics/Battlers/%segg_%d",getConstantName(PBSpecies,species),pokemon.form) rescue nil
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName = sprintf("Graphics/Battlers/%03degg_%d",species,pokemon.form)
      if !pbResolveBitmap(bitmapFileName)
        bitmapFileName = sprintf("Graphics/Battlers/%segg",getConstantName(PBSpecies,species)) rescue nil
        if !pbResolveBitmap(bitmapFileName)
          bitmapFileName = sprintf("Graphics/Battlers/%03degg",species)
          if !pbResolveBitmap(bitmapFileName)
            bitmapFileName = sprintf("Graphics/Battlers/egg")
          end
        end
      end
    end
    bitmapFileName = pbResolveBitmap(bitmapFileName)
  else
    bitmapFileName = pbCheckPokemonBitmapFiles([species,back,(pokemon.female?),
       pokemon.shiny?,(pokemon.form rescue 0),pokemon.shadowPokemon?])
    # Alter bitmap if supported
    alterBitmap = (MultipleForms.getFunction(species,"alterBitmap") rescue nil)
  end
  if bitmapFileName && alterBitmap
    animatedBitmap = AnimatedBitmap.new(bitmapFileName)
    copiedBitmap = animatedBitmap.copy
    animatedBitmap.dispose
    copiedBitmap.each { |bitmap| alterBitmap.call(pokemon,bitmap) }
    ret = copiedBitmap
  elsif bitmapFileName
    ret = AnimatedBitmap.new(bitmapFileName)
  end
  return ret
end

# NOTE: Returns an AnimatedBitmap, not a Bitmap
def pbLoadSpeciesBitmap(species,female=false,form=0,shiny=false,shadow=false,back=false,egg=false)
  ret = nil
  if egg
    bitmapFileName = sprintf("Graphics/Battlers/%segg_%d",getConstantName(PBSpecies,species),form) rescue nil
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName = sprintf("Graphics/Battlers/%03degg_%d",species,form)
      if !pbResolveBitmap(bitmapFileName)
        bitmapFileName = sprintf("Graphics/Battlers/%segg",getConstantName(PBSpecies,species)) rescue nil
        if !pbResolveBitmap(bitmapFileName)
          bitmapFileName = sprintf("Graphics/Battlers/%03degg",species)
          if !pbResolveBitmap(bitmapFileName)
            bitmapFileName = sprintf("Graphics/Battlers/egg")
          end
        end
      end
    end
    bitmapFileName = pbResolveBitmap(bitmapFileName)
  else
    bitmapFileName = pbCheckPokemonBitmapFiles([species,back,female,shiny,form,shadow])
  end
  if bitmapFileName
    ret = AnimatedBitmap.new(bitmapFileName)
  end
  return ret
end

def pbCheckPokemonBitmapFiles(params)
  factors = []
  factors.push([5,params[5],false]) if params[5] && params[5]!=false   # shadow
  factors.push([2,params[2],false]) if params[2] && params[2]!=false   # gender
  factors.push([3,params[3],false]) if params[3] && params[3]!=false   # shiny
  factors.push([4,params[4],0]) if params[4] && params[4]!=0           # form
  factors.push([0,params[0],0])                                        # species
  trySpecies = 0
  tryGender = false
  tryShiny  = false
  tryBack   = params[1]
  tryForm   = 0
  tryShadow = false
  for i in 0...2**factors.length
    factors.each_with_index do |factor,index|
      newVal = ((i/(2**index))%2==0) ? factor[1] : factor[2]
      case factor[0]
      when 0; trySpecies = newVal
      when 2; tryGender  = newVal
      when 3; tryShiny   = newVal
      when 4; tryForm    = newVal
      when 5; tryShadow  = newVal
      end
    end
    for j in 0...2   # Try using the species' internal name and then its ID number
      next if trySpecies==0 && j==0
      trySpeciesText = (j==0) ? getConstantName(PBSpecies,trySpecies) : sprintf("%03d",trySpecies)
      bitmapFileName = sprintf("Graphics/Battlers/%s%s%s%s%s%s",
         trySpeciesText,
         (tryGender) ? "f" : "",
         (tryShiny) ? "s" : "",
         (tryBack) ? "b" : "",
         (tryForm!=0) ? "_"+tryForm.to_s : "",
         (tryShadow) ? "_shadow" : "") rescue nil
      ret = pbResolveBitmap(bitmapFileName)
      return ret if ret
    end
  end
  return nil
end

def pbLoadPokemonShadowBitmap(pokemon)
  bitmapFileName = pbCheckPokemonShadowBitmapFiles(pokemon.species,pokemon.form)
  return AnimatedBitmap.new(pbResolveBitmap(bitmapFileName)) if bitmapFileName
  return nil
end

def pbLoadPokemonShadowBitmapSpecies(pokemon,species)
  bitmapFileName = pbCheckPokemonShadowBitmapFiles(species,pokemon.form)
  return AnimatedBitmap.new(pbResolveBitmap(bitmapFileName)) if bitmapFileName
  return nil
end

def pbCheckPokemonShadowBitmapFiles(species,form,fullmetrics=nil)
  if form>0
    bitmapFileName = sprintf("Graphics/Battlers/%s_%d_battleshadow",getConstantName(PBSpecies,species),form) rescue nil
    ret = pbResolveBitmap(bitmapFileName)
    return bitmapFileName if ret
    bitmapFileName = sprintf("Graphics/Battlers/%03d_%d_battleshadow",species,form)
    ret = pbResolveBitmap(bitmapFileName)
    return bitmapFileName if ret
  end
  bitmapFileName = sprintf("Graphics/Battlers/%s_battleshadow",getConstantName(PBSpecies,species)) rescue nil
  ret = pbResolveBitmap(bitmapFileName)
  return bitmapFileName if ret
  bitmapFileName = sprintf("Graphics/Battlers/%03d_battleshadow",species)
  ret = pbResolveBitmap(bitmapFileName)
  return bitmapFileName if ret
  # Load metrics and use that graphic
  fullmetrics = pbLoadSpeciesMetrics if !fullmetrics
  size = (fullmetrics[MetricBattlerShadowSize][pbGetFSpeciesFromForm(species,form)] || 2)
  bitmapFileName = sprintf("Graphics/Pictures/Battle/battler_shadow_%d",size)
  return bitmapFileName if pbResolveBitmap(bitmapFileName)
  return nil
end



#===============================================================================
# Load Pokémon icons
#===============================================================================
def pbLoadPokemonIcon(pokemon)
  return AnimatedBitmap.new(pbPokemonIconFile(pokemon)).deanimate
end

def pbPokemonIconFile(pokemon)
  return pbCheckPokemonIconFiles([pokemon.species,pokemon.female?,
     pokemon.shiny?,(pokemon.form rescue 0),pokemon.shadowPokemon?],
     pokemon.egg?)
end

def pbCheckPokemonIconFiles(params,egg=false)
  species = params[0]
  if egg
    bitmapFileName = sprintf("Graphics/Icons/icon%segg_%d",getConstantName(PBSpecies,species),params[3]) rescue nil
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName = sprintf("Graphics/Icons/icon%03degg_%d",species,params[3])
      if !pbResolveBitmap(bitmapFileName)
        bitmapFileName = sprintf("Graphics/Icons/icon%segg",getConstantName(PBSpecies,species)) rescue nil
        if !pbResolveBitmap(bitmapFileName)
          bitmapFileName = sprintf("Graphics/Icons/icon%03degg",species)
          if !pbResolveBitmap(bitmapFileName)
            bitmapFileName = sprintf("Graphics/Icons/iconEgg")
          end
        end
      end
    end
    return pbResolveBitmap(bitmapFileName)
  end
  factors = []
  factors.push([4,params[4],false]) if params[4] && params[4]!=false   # shadow
  factors.push([1,params[1],false]) if params[1] && params[1]!=false   # gender
  factors.push([2,params[2],false]) if params[2] && params[2]!=false   # shiny
  factors.push([3,params[3],0]) if params[3] && params[3]!=0           # form
  factors.push([0,params[0],0])                                        # species
  trySpecies = 0
  tryGender  = false
  tryShiny   = false
  tryForm    = 0
  tryShadow  = false
  for i in 0...2**factors.length
    factors.each_with_index do |factor,index|
      newVal = ((i/(2**index))%2==0) ? factor[1] : factor[2]
      case factor[0]
      when 0; trySpecies = newVal
      when 1; tryGender  = newVal
      when 2; tryShiny   = newVal
      when 3; tryForm    = newVal
      when 4; tryShadow  = newVal
      end
    end
    for j in 0...2   # Try using the species' internal name and then its ID number
      next if trySpecies==0 && j==0
      trySpeciesText = (j==0) ? getConstantName(PBSpecies,trySpecies) : sprintf("%03d",trySpecies)
      bitmapFileName = sprintf("Graphics/Icons/icon%s%s%s%s%s",
         trySpeciesText,
         (tryGender) ? "f" : "",
         (tryShiny) ? "s" : "",
         (tryForm!=0) ? "_"+tryForm.to_s : "",
         (tryShadow) ? "_shadow" : "") rescue nil
      ret = pbResolveBitmap(bitmapFileName)
      return ret if ret
    end
  end
  return nil
end



#===============================================================================
# Load Pokémon footprint graphics
#===============================================================================
def pbPokemonFootprintFile(pokemon,form=0)   # Used by the Pokédex
  return nil if !pokemon
  if pokemon.is_a?(Numeric)
    bitmapFileName = sprintf("Graphics/Icons/Footprints/footprint%s_%d",
       getConstantName(PBSpecies,pokemon),form) rescue nil
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName = sprintf("Graphics/Icons/Footprints/footprint%03d_%d",
         pokemon,form) rescue nil
      if !pbResolveBitmap(bitmapFileName)
        bitmapFileName = sprintf("Graphics/Icons/Footprints/footprint%s",
           getConstantName(PBSpecies,pokemon)) rescue nil
        if !pbResolveBitmap(bitmapFileName)
          bitmapFileName = sprintf("Graphics/Icons/Footprints/footprint%03d",pokemon)
        end
      end
    end
  else
    bitmapFileName = sprintf("Graphics/Icons/Footprints/footprint%s_%d",
       getConstantName(PBSpecies,pokemon.species),(pokemon.form rescue 0)) rescue nil
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName = sprintf("Graphics/Icons/Footprints/footprint%03d_%d",
         pokemon.species,(pokemon.form rescue 0)) rescue nil
      if !pbResolveBitmap(bitmapFileName)
        bitmapFileName = sprintf("Graphics/Icons/Footprints/footprint%s",
           getConstantName(PBSpecies,pokemon.species)) rescue nil
        if !pbResolveBitmap(bitmapFileName)
          bitmapFileName = sprintf("Graphics/Icons/Footprints/footprint%03d",
             pokemon.species)
        end
      end
    end
  end
  return pbResolveBitmap(bitmapFileName)
end



#===============================================================================
# Load item icons
#===============================================================================
def pbItemIconFile(item)
  return nil if !item
  bitmapFileName = nil
  if item==0
    bitmapFileName = sprintf("Graphics/Icons/itemBack")
  else
    bitmapFileName = sprintf("Graphics/Icons/item%s",getConstantName(PBItems,item)) rescue nil
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName = sprintf("Graphics/Icons/item%03d",item)
      if !pbResolveBitmap(bitmapFileName) && pbIsTechnicalRecord?(item)
        move = pbGetMachine(item)
        type = pbGetMoveData(move,MOVE_TYPE)
        bitmapFileName = sprintf("Graphics/Icons/itemRecord%s",getConstantName(PBTypes,type)) rescue nil
        if !pbResolveBitmap(bitmapFileName)
          bitmapFileName = sprintf("Graphics/Icons/itemRecord%03d",type)
        end
      end
      if !pbResolveBitmap(bitmapFileName) && pbIsMachine?(item)
        move = pbGetMachine(item)
        type = pbGetMoveData(move,MOVE_TYPE)
        bitmapFileName = sprintf("Graphics/Icons/itemMachine%s",getConstantName(PBTypes,type)) rescue nil
        if !pbResolveBitmap(bitmapFileName)
          bitmapFileName = sprintf("Graphics/Icons/itemMachine%03d",type)
        end
      end
      bitmapFileName = "Graphics/Icons/item000" if !pbResolveBitmap(bitmapFileName)
    end
  end
  return bitmapFileName
end

def pbHeldItemIconFile(item)   # Used in the party screen
  return nil if !item || item==0
  namebase = (pbIsMail?(item)) ? "mail" : "item"
  bitmapFileName = sprintf("Graphics/Pictures/Party/icon_%s_%s",namebase,getConstantName(PBItems,item)) rescue nil
  if !pbResolveBitmap(bitmapFileName)
    bitmapFileName = sprintf("Graphics/Pictures/Party/icon_%s_%03d",namebase,item)
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName = sprintf("Graphics/Pictures/Party/icon_%s",namebase)
    end
  end
  return bitmapFileName
end



#===============================================================================
# Load mail background graphics
#===============================================================================
def pbMailBackFile(item)
  return nil if !item
  bitmapFileName = sprintf("Graphics/Pictures/Mail/mail_%s",getConstantName(PBItems,item)) rescue nil
  if !pbResolveBitmap(bitmapFileName)
    bitmapFileName = sprintf("Graphics/Pictures/Mail/mail_%03d",item)
  end
  return bitmapFileName
end



#===============================================================================
# Load NPC charsets
#===============================================================================
def pbTrainerCharFile(type)   # Used by the phone
  return nil if !type
  bitmapFileName = sprintf("Graphics/Characters/trchar%s",getConstantName(PBTrainers,type)) rescue nil
  if !pbResolveBitmap(bitmapFileName)
    bitmapFileName = sprintf("Graphics/Characters/trchar%03d",type)
  end
  return bitmapFileName
end

def pbTrainerCharNameFile(type)   # Used by Battle Frontier and compiler
  return nil if !type
  bitmapFileName = sprintf("trchar%s",getConstantName(PBTrainers,type)) rescue nil
  if !pbResolveBitmap(sprintf("Graphics/Characters/"+bitmapFileName))
    bitmapFileName = sprintf("trchar%03d",type)
  end
  return bitmapFileName
end



#===============================================================================
# Load trainer sprites
#===============================================================================
def pbTrainerSpriteFile(type)
  return nil if !type
  bitmapFileName = sprintf("Graphics/Trainers/trainer%s",
     getConstantName(PBTrainers,type)) rescue nil
  if !pbResolveBitmap(bitmapFileName)
    bitmapFileName = sprintf("Graphics/Trainers/trainer%03d",type)
  end
  return bitmapFileName
end

def pbTrainerSpriteBackFile(type)
  return nil if !type
  bitmapFileName = sprintf("Graphics/Trainers/trback%s",
     getConstantName(PBTrainers,type)) rescue nil
  if !pbResolveBitmap(bitmapFileName)
    bitmapFileName = sprintf("Graphics/Trainers/trback%03d",type)
  end
  return bitmapFileName
end

def pbPlayerSpriteFile(type)
  return nil if !type
  outfit = ($Trainer) ? $Trainer.outfit : 0
  bitmapFileName = sprintf("Graphics/Trainers/trainer%s_%d",
     getConstantName(PBTrainers,type),outfit) rescue nil
  if !pbResolveBitmap(bitmapFileName)
    bitmapFileName = sprintf("Graphics/Trainers/trainer%03d_%d",type,outfit)
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName = pbTrainerSpriteFile(type)
    end
  end
  return bitmapFileName
end

def pbPlayerSpriteBackFile(type)
  return nil if !type
  outfit = ($Trainer) ? $Trainer.outfit : 0
  bitmapFileName = sprintf("Graphics/Trainers/trback%s_%d",
     getConstantName(PBTrainers,type),outfit) rescue nil
  if !pbResolveBitmap(bitmapFileName)
    bitmapFileName = sprintf("Graphics/Trainers/trback%03d_%d",type,outfit)
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName = pbTrainerSpriteBackFile(type)
    end
  end
  return bitmapFileName
end



#===============================================================================
# Load player's head icons (used in the Town Map)
#===============================================================================
def pbTrainerHeadFile(type)
  return nil if !type
  bitmapFileName = sprintf("Graphics/Pictures/mapPlayer%s",getConstantName(PBTrainers,type)) rescue nil
  if !pbResolveBitmap(bitmapFileName)
    bitmapFileName = sprintf("Graphics/Pictures/mapPlayer%03d",type)
  end
  return bitmapFileName
end

def pbPlayerHeadFile(type)
  return nil if !type
  outfit = ($Trainer) ? $Trainer.outfit : 0
  bitmapFileName = sprintf("Graphics/Pictures/mapPlayer%s_%d",
     getConstantName(PBTrainers,type),outfit) rescue nil
  if !pbResolveBitmap(bitmapFileName)
    bitmapFileName = sprintf("Graphics/Pictures/mapPlayer%03d_%d",type,outfit)
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName = pbTrainerHeadFile(type)
    end
  end
  return bitmapFileName
end



#===============================================================================
# Analyse audio files
#===============================================================================
def pbResolveAudioSE(file)
  return nil if !file
  if RTP.exists?("Audio/SE/"+file,["",".wav",".mp3",".ogg"])
    return RTP.getPath("Audio/SE/"+file,["",".wav",".mp3",".ogg"])
  end
  return nil
end

def pbCryFrameLength(pokemon,form=0,pitch=nil)
  return 0 if !pokemon
  pitch = 100 if !pitch
  pitch = pitch.to_f/100
  return 0 if pitch<=0
  playtime = 0.0
  if pokemon.is_a?(Numeric)
    pkmnwav = pbResolveAudioSE(pbCryFile(pokemon,form))
    playtime = getPlayTime(pkmnwav) if pkmnwav
  elsif !pokemon.egg?
    if pokemon.respond_to?("chatter") && pokemon.chatter
      playtime = pokemon.chatter.time
      pitch = 1.0
    else
      pkmnwav = pbResolveAudioSE(pbCryFile(pokemon))
      playtime = getPlayTime(pkmnwav) if pkmnwav
    end
  end
  playtime /= pitch   # sound is lengthened the lower the pitch
  # 4 is added to provide a buffer between sounds
  return (playtime*Graphics.frame_rate).ceil+4
end



#===============================================================================
# Load/play Pokémon cry files
#===============================================================================
def pbPlayCry(pokemon,volume=90,pitch=nil)
  return if !pokemon
  if pokemon.is_a?(Numeric) || pokemon.is_a?(String) || pokemon.is_a?(Symbol)
    pbPlayCrySpecies(pokemon,0,volume,pitch)
  elsif pokemon.is_a?(PokeBattle_Pokemon)
    pbPlayCryPokemon(pokemon,volume,pitch)
  end
end

def pbPlayCrySpecies(pokemon,form=0,volume=90,pitch=nil)
  return if !pokemon
  pokemon = getID(PBSpecies,pokemon)
  return if !pokemon.is_a?(Numeric)
  pkmnwav = pbCryFile(pokemon,form)
  if pkmnwav
    pitch ||= 100
    pbSEPlay(RPG::AudioFile.new(pkmnwav,volume,pitch)) rescue nil
  end
end

def pbPlayCryPokemon(pokemon,volume=90,pitch=nil)
  return if !pokemon || pokemon.egg?
  if pokemon.respond_to?("chatter") && pokemon.chatter
    pokemon.chatter.play
    return
  end
  pkmnwav = pbCryFile(pokemon)
  if pkmnwav
    pitch ||= (pokemon.hp*25/pokemon.totalhp)+75
    pbSEPlay(RPG::AudioFile.new(pkmnwav,volume,pitch)) rescue nil
  end
end

def pbCryFile(pokemon,form=0)
  return nil if !pokemon
  pokemon = getID(PBSpecies,pokemon)
  if pokemon.is_a?(Numeric)
    filename = sprintf("Cries/%sCry_%d",getConstantName(PBSpecies,pokemon),form) rescue nil
    if !pbResolveAudioSE(filename)
      filename = sprintf("Cries/%03dCry_%d",pokemon,form)
      if !pbResolveAudioSE(filename)
        filename = sprintf("Cries/%sCry",getConstantName(PBSpecies,pokemon)) rescue nil
        if !pbResolveAudioSE(filename)
          filename = sprintf("Cries/%03dCry",pokemon)
        end
      end
    end
    return filename if pbResolveAudioSE(filename)
  elsif !pokemon.egg?
    form = (pokemon.form rescue 0)
    filename = sprintf("Cries/%sCry_%d",getConstantName(PBSpecies,pokemon.species),form) rescue nil
    if !pbResolveAudioSE(filename)
      filename = sprintf("Cries/%03dCry_%d",pokemon.species,form)
      if !pbResolveAudioSE(filename)
        filename = sprintf("Cries/%sCry",getConstantName(PBSpecies,pokemon.species)) rescue nil
        if !pbResolveAudioSE(filename)
          filename = sprintf("Cries/%03dCry",pokemon.species)
        end
      end
    end
    return filename if pbResolveAudioSE(filename)
  end
  return nil
end



#===============================================================================
# Load various wild battle music
#===============================================================================
def pbGetWildBattleBGM(_wildParty)   # wildParty is an array of Pokémon objects
  if $PokemonGlobal.nextBattleBGM
    return $PokemonGlobal.nextBattleBGM.clone
  end
  ret = nil
  if !ret
    # Check map-specific metadata
    music = pbGetMetadata($game_map.map_id,MetadataMapWildBattleBGM)
    ret = pbStringToAudioFile(music) if music && music!=""
  end
  if !ret
    # Check global metadata
    music = pbGetMetadata(0,MetadataWildBattleBGM)
    ret = pbStringToAudioFile(music) if music && music!=""
  end
  ret = pbStringToAudioFile("Battle wild") if !ret
  return ret
end

def pbGetWildVictoryME
  if $PokemonGlobal.nextBattleME
    return $PokemonGlobal.nextBattleME.clone
  end
  ret = nil
  if !ret
    # Check map-specific metadata
    music = pbGetMetadata($game_map.map_id,MetadataMapWildVictoryME)
    ret = pbStringToAudioFile(music) if music && music!=""
  end
  if !ret
    # Check global metadata
    music = pbGetMetadata(0,MetadataWildVictoryME)
    ret = pbStringToAudioFile(music) if music && music!=""
  end
  ret = pbStringToAudioFile("Battle victory") if !ret
  ret.name = "../../Audio/ME/"+ret.name
  return ret
end

def pbGetWildCaptureME
  if $PokemonGlobal.nextBattleCaptureME
    return $PokemonGlobal.nextBattleCaptureME.clone
  end
  ret = nil
  if !ret
    # Check map-specific metadata
    music = pbGetMetadata($game_map.map_id,MetadataMapWildCaptureME)
    ret = pbStringToAudioFile(music) if music && music!=""
  end
  if !ret
    # Check global metadata
    music = pbGetMetadata(0,MetadataWildCaptureME)
    ret = pbStringToAudioFile(music) if music && music!=""
  end
  ret = pbStringToAudioFile("Battle capture success") if !ret
  ret.name = "../../Audio/ME/"+ret.name
  return ret
end



#===============================================================================
# Load/play various trainer battle music
#===============================================================================
def pbPlayTrainerIntroME(trainerType)
  data = pbGetTrainerTypeData(trainerType)
  if data && data[6] && data[6]!=""
    bgm = pbStringToAudioFile(data[6])
    pbMEPlay(bgm)
  end
end

def pbGetTrainerBattleBGM(trainer)   # can be a PokeBattle_Trainer or an array of them
  if $PokemonGlobal.nextBattleBGM
    return $PokemonGlobal.nextBattleBGM.clone
  end
  ret = nil
  music = nil
  trainerarray = (trainer.is_a?(Array)) ? trainer : [trainer]
  trainerarray.each do |t|
    data = pbGetTrainerTypeData(t.trainertype)
    music = data[4] if data && data[4]
  end
  ret = pbStringToAudioFile(music) if music && music!=""
  if !ret
    # Check map-specific metadata
    music = pbGetMetadata($game_map.map_id,MetadataMapTrainerBattleBGM)
    if music && music!=""
      ret = pbStringToAudioFile(music)
    end
  end
  if !ret
    # Check global metadata
    music = pbGetMetadata(0,MetadataTrainerBattleBGM)
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
  data = pbGetTrainerTypeData(trainertype)
  ret = pbStringToAudioFile(data[4]) if data && data[4]
  if !ret
    # Check map-specific metadata
    music = pbGetMetadata($game_map.map_id,MetadataMapTrainerBattleBGM)
    ret = pbStringToAudioFile(music) if music && music!=""
  end
  if !ret
    # Check global metadata
    music = pbGetMetadata(0,MetadataTrainerBattleBGM)
    ret = pbStringToAudioFile(music) if music && music!=""
  end
  ret = pbStringToAudioFile("Battle trainer") if !ret
  return ret
end

def pbGetTrainerVictoryME(trainer)   # can be a PokeBattle_Trainer or an array of them
  if $PokemonGlobal.nextBattleME
    return $PokemonGlobal.nextBattleME.clone
  end
  music = nil
  trainerarray = (trainer.is_a?(Array)) ? trainer : [trainer]
  trainerarray.each do |t|
    data = pbGetTrainerTypeData(t.trainertype)
    music = data[5] if data && data[5]
  end
  ret = nil
  if music && music!=""
    ret = pbStringToAudioFile(music)
  end
  if !ret
    # Check map-specific metadata
    music = pbGetMetadata($game_map.map_id,MetadataMapTrainerVictoryME)
    if music && music!=""
      ret = pbStringToAudioFile(music)
    end
  end
  if !ret
    # Check global metadata
    music = pbGetMetadata(0,MetadataTrainerVictoryME)
    if music && music!=""
      ret = pbStringToAudioFile(music)
    end
  end
  ret = pbStringToAudioFile("Battle victory") if !ret
  ret.name = "../../Audio/ME/"+ret.name
  return ret
end
