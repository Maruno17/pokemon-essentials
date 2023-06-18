#===============================================================================
# General purpose utilities
#===============================================================================
def _pbNextComb(comb, length)
  i = comb.length - 1
  loop do
    valid = true
    (i...comb.length).each do |j|
      if j == i
        comb[j] += 1
      else
        comb[j] = comb[i] + (j - i)
      end
      if comb[j] >= length
        valid = false
        break
      end
    end
    return true if valid
    i -= 1
    break unless i >= 0
  end
  return false
end

# Iterates through the array and yields each combination of _num_ elements in
# the array.
def pbEachCombination(array, num)
  return if array.length < num || num <= 0
  if array.length == num
    yield array
    return
  elsif num == 1
    array.each do |x|
      yield [x]
    end
    return
  end
  currentComb = []
  arr = []
  num.times { |i| currentComb[i] = i }
  loop do
    num.times { |i| arr[i] = array[currentComb[i]] }
    yield arr
    break unless _pbNextComb(currentComb, array.length)
  end
end

# Returns a language ID
def pbGetLanguage
  case System.user_language[0..1]
  when "ja" then return 1   # Japanese
  when "en" then return 2   # English
  when "fr" then return 3   # French
  when "it" then return 4   # Italian
  when "de" then return 5   # German
  when "es" then return 7   # Spanish
  when "ko" then return 8   # Korean
  end
  return 2 # Use 'English' by default
end

# Converts a Celsius temperature to Fahrenheit.
def toFahrenheit(celsius)
  return (celsius * 9.0 / 5.0).round + 32
end

# Converts a Fahrenheit temperature to Celsius.
def toCelsius(fahrenheit)
  return ((fahrenheit - 32) * 5.0 / 9.0).round
end

#===============================================================================
# This class is designed to favor different values more than a uniform
# random generator does.
#===============================================================================
class AntiRandom
  def initialize(size)
    @old = []
    @new = Array.new(size) { |i| i }
  end

  def get
    if @new.length == 0   # No new values
      @new = @old.clone
      @old.clear
    end
    if @old.length > 0 && rand(7) == 0   # Get old value
      return @old[rand(@old.length)]
    end
    if @new.length > 0   # Get new value
      ret = @new.delete_at(rand(@new.length))
      @old.push(ret)
      return ret
    end
    return @old[rand(@old.length)]   # Get old value
  end
end

#===============================================================================
# Constants utilities
#===============================================================================
# Unused
def isConst?(val, mod, constant)
  begin
    return false if !mod.const_defined?(constant.to_sym)
  rescue
    return false
  end
  return (val == mod.const_get(constant.to_sym))
end

# Unused
def hasConst?(mod, constant)
  return false if !mod || constant.nil?
  return mod.const_defined?(constant.to_sym) rescue false
end

# Unused
def getConst(mod, constant)
  return nil if !mod || constant.nil?
  return mod.const_get(constant.to_sym) rescue nil
end

# Unused
def getID(mod, constant)
  return nil if !mod || constant.nil?
  if constant.is_a?(Symbol) || constant.is_a?(String)
    if (mod.const_defined?(constant.to_sym) rescue false)
      return mod.const_get(constant.to_sym) rescue 0
    end
    return 0
  end
  return constant
end

def getConstantName(mod, value, raise_if_none = true)
  mod = Object.const_get(mod) if mod.is_a?(Symbol)
  mod.constants.each do |c|
    return c.to_s if mod.const_get(c.to_sym) == value
  end
  raise _INTL("Value {1} not defined by a constant in {2}", value, mod.name) if raise_if_none
  return nil
end

def getConstantNameOrValue(mod, value)
  mod = Object.const_get(mod) if mod.is_a?(Symbol)
  mod.constants.each do |c|
    return c.to_s if mod.const_get(c.to_sym) == value
  end
  return value.inspect
end

#===============================================================================
# Event utilities
#===============================================================================
def pbTimeEvent(variableNumber, secs = 86_400)
  return if !$game_variables
  return if !variableNumber || variableNumber < 0
  secs = 0 if secs < 0
  timenow = pbGetTimeNow
  $game_variables[variableNumber] = [timenow.to_f, secs]
  $game_map&.refresh
end

def pbTimeEventDays(variableNumber, days = 0)
  return if !$game_variables
  return if !variableNumber || variableNumber < 0
  days = 0 if days < 0
  timenow = pbGetTimeNow
  time = timenow.to_f
  expiry = (time % 86_400.0) + (days * 86_400.0)
  $game_variables[variableNumber] = [time, expiry - time]
  $game_map&.refresh
end

def pbTimeEventValid(variableNumber)
  return false if !$game_variables
  return false if !variableNumber || variableNumber < 0
  ret = false
  value = $game_variables[variableNumber]
  if value.is_a?(Array)
    timenow = pbGetTimeNow
    ret = (timenow.to_f - value[0] > value[1])   # value[1] is age in seconds
    ret = false if value[1] <= 0   # zero age
  end
  if !ret
    $game_variables[variableNumber] = 0
    $game_map&.refresh
  end
  return ret
end

def pbExclaim(event, id = Settings::EXCLAMATION_ANIMATION_ID, tinting = false)
  if event.is_a?(Array)
    sprite = nil
    done = []
    event.each do |i|
      next if done.include?(i.id)
      spriteset = $scene.spriteset(i.map_id)
      sprite ||= spriteset&.addUserAnimation(id, i.x, i.y, tinting, 2)
      done.push(i.id)
    end
  else
    spriteset = $scene.spriteset(event.map_id)
    sprite = spriteset&.addUserAnimation(id, event.x, event.y, tinting, 2)
  end
  until sprite.disposed?
    Graphics.update
    Input.update
    pbUpdateSceneMap
  end
end

def pbNoticePlayer(event, always_show_exclaim = false)
  if always_show_exclaim || !pbFacingEachOther(event, $game_player)
    pbExclaim(event)
  end
  pbTurnTowardEvent($game_player, event)
  pbMoveTowardPlayer(event)
end

#===============================================================================
# Player-related utilities, random name generator
#===============================================================================
# Unused
def pbGetPlayerGraphic
  id = $player.character_ID
  return "" if id < 1
  meta = GameData::PlayerMetadata.get(id)
  return "" if !meta
  return GameData::TrainerType.player_front_sprite_filename(meta.trainer_type)
end

def pbGetTrainerTypeGender(trainer_type)
  return GameData::TrainerType.get(trainer_type).gender
end

def pbChangePlayer(id)
  return false if id < 1
  meta = GameData::PlayerMetadata.get(id)
  return false if !meta
  $player.character_ID = id
  return true
end

def pbTrainerName(name = nil, outfit = 0)
  pbChangePlayer(1) if $player.character_ID < 1
  if name.nil?
    name = pbEnterPlayerName(_INTL("Your name?"), 0, Settings::MAX_PLAYER_NAME_SIZE)
    if name.nil? || name.empty?
      player_metadata = GameData::PlayerMetadata.get($player.character_ID)
      trainer_type = (player_metadata) ? player_metadata.trainer_type : nil
      gender = pbGetTrainerTypeGender(trainer_type)
      name = pbSuggestTrainerName(gender)
    end
  end
  $player.name   = name
  $player.outfit = outfit
end

def pbSuggestTrainerName(gender)
  userName = pbGetUserName
  userName = userName.gsub(/\s+.*$/, "")
  if userName.length > 0 && userName.length < Settings::MAX_PLAYER_NAME_SIZE
    userName[0, 1] = userName[0, 1].upcase
    return userName
  end
  userName = userName.gsub(/\d+$/, "")
  if userName.length > 0 && userName.length < Settings::MAX_PLAYER_NAME_SIZE
    userName[0, 1] = userName[0, 1].upcase
    return userName
  end
  userName = System.user_name.capitalize
  userName = userName[0, Settings::MAX_PLAYER_NAME_SIZE]
  return userName
  # Unreachable
#  return getRandomNameEx(gender, nil, 1, Settings::MAX_PLAYER_NAME_SIZE)
end

def pbGetUserName
  return System.user_name
end

def getRandomNameEx(type, variable, upper, maxLength = 100)
  return "" if maxLength <= 0
  name = ""
  50.times do
    name = ""
    formats = []
    case type
    when 0 then formats = ["F5", "BvE", "FE", "FE5", "FEvE"]                    # Names for males
    when 1 then formats = ["vE6", "vEvE6", "BvE6", "B4", "v3", "vEv3", "Bv3"]   # Names for females
    when 2 then formats = ["WE", "WEU", "WEvE", "BvE", "BvEU", "BvEvE"]         # Neutral gender names
    else        return ""
    end
    format = formats.sample
    format.scan(/./) do |c|
      case c
      when "c"   # consonant
        set = ["b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "r",
               "s", "t", "v", "w", "x", "z"]
        name += set.sample
      when "v"   # vowel
        set = ["a", "a", "a", "e", "e", "e", "i", "i", "i", "o", "o", "o", "u", "u", "u"]
        name += set.sample
      when "W"   # beginning vowel
        set = ["a", "a", "a", "e", "e", "e", "i", "i", "i", "o", "o", "o", "u",
               "u", "u", "au", "au", "ay", "ay", "ea", "ea", "ee", "ee", "oo",
               "oo", "ou", "ou"]
        name += set.sample
      when "U"   # ending vowel
        set = ["a", "a", "a", "a", "a", "e", "e", "e", "i", "i", "i", "o", "o",
               "o", "o", "o", "u", "u", "ay", "ay", "ie", "ie", "ee", "ue", "oo"]
        name += set.sample
      when "B"   # beginning consonant
        set1 = ["b", "c", "d", "f", "g", "h", "j", "k", "l", "l", "m", "n", "n",
                "p", "r", "r", "s", "s", "t", "t", "v", "w", "y", "z"]
        set2 = ["bl", "br", "ch", "cl", "cr", "dr", "fr", "fl", "gl", "gr", "kh",
                "kl", "kr", "ph", "pl", "pr", "sc", "sk", "sl", "sm", "sn", "sp",
                "st", "sw", "th", "tr", "tw", "vl", "zh"]
        name += (rand(3) > 0) ? set1.sample : set2.sample
      when "E"   # ending consonant
        set1 = ["b", "c", "d", "f", "g", "h", "j", "k", "k", "l", "l", "m", "n",
                "n", "p", "r", "r", "s", "s", "t", "t", "v", "z"]
        set2 = ["bb", "bs", "ch", "cs", "ds", "fs", "ft", "gs", "gg", "ld", "ls",
                "nd", "ng", "nk", "rn", "kt", "ks", "ms", "ns", "ph", "pt", "ps",
                "sk", "sh", "sp", "ss", "st", "rd", "rn", "rp", "rm", "rt", "rk",
                "ns", "th", "zh"]
        name += (rand(3) > 0) ? set1.sample : set2.sample
      when "f"   # consonant and vowel
        set = ["iz", "us", "or"]
        name += set.sample
      when "F"   # consonant and vowel
        set = ["bo", "ba", "be", "bu", "re", "ro", "si", "mi", "zho", "se", "nya",
               "gru", "gruu", "glee", "gra", "glo", "ra", "do", "zo", "ri", "di",
               "ze", "go", "ga", "pree", "pro", "po", "pa", "ka", "ki", "ku",
               "de", "da", "ma", "mo", "le", "la", "li"]
        name += set.sample
      when "2"
        set = ["c", "f", "g", "k", "l", "p", "r", "s", "t"]
        name += set.sample
      when "3"
        set = ["nka", "nda", "la", "li", "ndra", "sta", "cha", "chie"]
        name += set.sample
      when "4"
        set = ["una", "ona", "ina", "ita", "ila", "ala", "ana", "ia", "iana"]
        name += set.sample
      when "5"
        set = ["e", "e", "o", "o", "ius", "io", "u", "u", "ito", "io", "ius", "us"]
        name += set.sample
      when "6"
        set = ["a", "a", "a", "elle", "ine", "ika", "ina", "ita", "ila", "ala", "ana"]
        name += set.sample
      end
    end
    break if name.length <= maxLength
  end
  name = name[0, maxLength]
  case upper
  when 0 then name = name.upcase
  when 1 then name[0, 1] = name[0, 1].upcase
  end
  if $game_variables && variable
    $game_variables[variable] = name
    $game_map.need_refresh = true if $game_map
  end
  return name
end

def getRandomName(maxLength = 100)
  return getRandomNameEx(2, nil, nil, maxLength)
end

#===============================================================================
# Regional and National Pokédexes utilities
#===============================================================================
# Returns the ID number of the region containing the player's current location,
# as determined by the current map's metadata.
def pbGetCurrentRegion(default = -1)
  return default if !$game_map
  map_pos = $game_map.metadata&.town_map_position
  return (map_pos) ? map_pos[0] : default
end

# Returns the Regional Pokédex number of the given species in the given Regional
# Dex. The parameter "region" is zero-based. For example, if two regions are
# defined, they would each be specified as 0 and 1.
def pbGetRegionalNumber(region, species)
  dex_list = pbLoadRegionalDexes[region]
  return 0 if !dex_list || dex_list.length == 0
  species_data = GameData::Species.try_get(species)
  return 0 if !species_data
  dex_list.each_with_index do |s, index|
    return index + 1 if s == species_data.species
  end
  return 0
end

# Returns an array of all species in the given Regional Dex in that Dex's order.
def pbAllRegionalSpecies(region_dex)
  return nil if region_dex < 0
  dex_list = pbLoadRegionalDexes[region_dex]
  return nil if !dex_list || dex_list.length == 0
  return dex_list.clone
end

# Returns the number of species in the given Regional Dex. Returns 0 if that
# Regional Dex doesn't exist. If region_dex is a negative number, returns the
# number of species in the National Dex (i.e. all species).
def pbGetRegionalDexLength(region_dex)
  if region_dex < 0
    ret = 0
    GameData::Species.each_species { |s| ret += 1 }
    return ret
  end
  dex_list = pbLoadRegionalDexes[region_dex]
  return (dex_list) ? dex_list.length : 0
end

#===============================================================================
# Other utilities
#===============================================================================
def pbTextEntry(helptext, minlength, maxlength, variableNumber)
  $game_variables[variableNumber] = pbEnterText(helptext, minlength, maxlength)
  $game_map.need_refresh = true if $game_map
end

def pbMoveTutorAnnotations(move, movelist = nil)
  ret = []
  $player.party.each_with_index do |pkmn, i|
    if pkmn.egg?
      ret[i] = _INTL("NOT ABLE")
    elsif pkmn.hasMove?(move)
      ret[i] = _INTL("LEARNED")
    else
      species = pkmn.species
      if movelist&.any? { |j| j == species }
        # Checked data from movelist given in parameter
        ret[i] = _INTL("ABLE")
      elsif pkmn.compatible_with_move?(move)
        # Checked data from Pokémon's tutor moves in pokemon.txt
        ret[i] = _INTL("ABLE")
      else
        ret[i] = _INTL("NOT ABLE")
      end
    end
  end
  return ret
end

def pbMoveTutorChoose(move, movelist = nil, bymachine = false, oneusemachine = false)
  ret = false
  move = GameData::Move.get(move).id
  if movelist.is_a?(Array)
    movelist.map! { |m| GameData::Move.get(m).id }
  end
  pbFadeOutIn do
    movename = GameData::Move.get(move).name
    annot = pbMoveTutorAnnotations(move, movelist)
    scene = PokemonParty_Scene.new
    screen = PokemonPartyScreen.new(scene, $player.party)
    screen.pbStartScene(_INTL("Teach which Pokémon?"), false, annot)
    loop do
      chosen = screen.pbChoosePokemon
      break if chosen < 0
      pokemon = $player.party[chosen]
      if pokemon.egg?
        pbMessage(_INTL("Eggs can't be taught any moves.")) { screen.pbUpdate }
      elsif pokemon.shadowPokemon?
        pbMessage(_INTL("Shadow Pokémon can't be taught any moves.")) { screen.pbUpdate }
      elsif movelist && movelist.none? { |j| j == pokemon.species }
        pbMessage(_INTL("{1} can't learn {2}.", pokemon.name, movename)) { screen.pbUpdate }
      elsif !pokemon.compatible_with_move?(move)
        pbMessage(_INTL("{1} can't learn {2}.", pokemon.name, movename)) { screen.pbUpdate }
      elsif pbLearnMove(pokemon, move, false, bymachine) { screen.pbUpdate }
        $stats.moves_taught_by_item += 1 if bymachine
        $stats.moves_taught_by_tutor += 1 if !bymachine
        pokemon.add_first_move(move) if oneusemachine
        ret = true
        break
      end
    end
    screen.pbEndScene
  end
  return ret   # Returns whether the move was learned by a Pokemon
end

def pbConvertItemToItem(variable, array)
  item = GameData::Item.get(pbGet(variable))
  pbSet(variable, nil)
  (array.length / 2).times do |i|
    next if item != array[2 * i]
    pbSet(variable, array[(2 * i) + 1])
    return
  end
end

def pbConvertItemToPokemon(variable, array)
  item = GameData::Item.get(pbGet(variable))
  pbSet(variable, nil)
  (array.length / 2).times do |i|
    next if item != array[2 * i]
    pbSet(variable, GameData::Species.get(array[(2 * i) + 1]).id)
    return
  end
end

# Gets the value of a variable.
def pbGet(id)
  return 0 if !id || !$game_variables
  return $game_variables[id]
end

# Sets the value of a variable.
def pbSet(id, value)
  return if !id || id < 0
  $game_variables[id] = value if $game_variables
  $game_map.need_refresh = true if $game_map
end

# Runs a common event and waits until the common event is finished.
# Requires the script "Messages"
def pbCommonEvent(id)
  return false if id < 0
  ce = $data_common_events[id]
  return false if !ce
  celist = ce.list
  interp = Interpreter.new
  interp.setup(celist, 0)
  loop do
    Graphics.update
    Input.update
    interp.update
    pbUpdateSceneMap
    break unless interp.running?
  end
  return true
end

def pbHideVisibleObjects
  visibleObjects = []
  ObjectSpace.each_object(Sprite) do |o|
    if !o.disposed? && o.visible
      visibleObjects.push(o)
      o.visible = false
    end
  end
  ObjectSpace.each_object(Viewport) do |o|
    if !pbDisposed?(o) && o.visible
      visibleObjects.push(o)
      o.visible = false
    end
  end
  ObjectSpace.each_object(Plane) do |o|
    if !o.disposed? && o.visible
      visibleObjects.push(o)
      o.visible = false
    end
  end
  ObjectSpace.each_object(Tilemap) do |o|
    if !o.disposed? && o.visible
      visibleObjects.push(o)
      o.visible = false
    end
  end
  ObjectSpace.each_object(Window) do |o|
    if !o.disposed? && o.visible
      visibleObjects.push(o)
      o.visible = false
    end
  end
  return visibleObjects
end

def pbShowObjects(visibleObjects)
  visibleObjects.each do |o|
    next if pbDisposed?(o)
    o.visible = true
  end
end

def pbLoadRpgxpScene(scene)
  return if !$scene.is_a?(Scene_Map)
  oldscene = $scene
  $scene = scene
  Graphics.freeze
  oldscene.dispose
  visibleObjects = pbHideVisibleObjects
  Graphics.transition
  Graphics.freeze
  while $scene && !$scene.is_a?(Scene_Map)
    $scene.main
  end
  Graphics.transition
  Graphics.freeze
  $scene = oldscene
  $scene.createSpritesets
  pbShowObjects(visibleObjects)
  Graphics.transition
end

def pbChooseLanguage
  commands = []
  Settings::LANGUAGES.each do |lang|
    commands.push(lang[0])
  end
  return pbShowCommands(nil, commands)
end

def pbScreenCapture
  t = Time.now
  filestart = t.strftime("[%Y-%m-%d] %H_%M_%S.%L")
  capturefile = RTP.getSaveFileName(sprintf("%s.png", filestart))
  Graphics.screenshot(capturefile)
  pbSEPlay("Pkmn exp full") if FileTest.audio_exist?("Audio/SE/Pkmn exp full")
end
