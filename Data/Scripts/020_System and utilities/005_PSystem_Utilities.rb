#===============================================================================
# General purpose utilities
#===============================================================================
def _pbNextComb(comb,length)
  i = comb.length-1
  begin
    valid = true
    for j in i...comb.length
      if j==i
        comb[j] += 1
      else
        comb[j] = comb[i]+(j-i)
      end
      if comb[j]>=length
        valid = false
        break
      end
    end
    return true if valid
    i -= 1
  end while i>=0
  return false
end

# Iterates through the array and yields each combination of _num_ elements in
# the array.
def pbEachCombination(array,num)
  return if array.length<num || num<=0
  if array.length==num
    yield array
    return
  elsif num==1
    for x in array
      yield [x]
    end
    return
  end
  currentComb = []
  arr = []
  for i in 0...num
    currentComb[i] = i
  end
  begin
    for i in 0...num
      arr[i] = array[currentComb[i]]
    end
    yield arr
  end while _pbNextComb(currentComb,array.length)
end

def pbGetCDID()
  sendString = proc { |x|
    mciSendString = Win32API.new('winmm','mciSendString','%w(p,p,l,l)','l')
    next "" if !mciSendString
    buffer = "\0"*2000
    x = mciSendString.call(x,buffer,2000,0)
    next (x==0) ? buffer.gsub(/\0/,"") : ""
  }
  sendString.call("open cdaudio shareable")
  ret = ""
  if sendString.call("status cdaudio media present")=="true"
    ret = sendString.call("info cdaudio identity")
    if ret==""
      ret = sendString.call("info cdaudio info identity")
    end
  end
  sendString.call("close cdaudio")
  return ret
end

# Gets the path of the user's "My Documents" folder.
def pbGetMyDocumentsFolder()
  csidl_personal = 0x0005
  shGetSpecialFolderLocation = Win32API.new("shell32.dll","SHGetSpecialFolderLocation","llp","i")
  shGetPathFromIDList        = Win32API.new("shell32.dll","SHGetPathFromIDList","lp","i")
  return "." if !shGetSpecialFolderLocation || !shGetPathFromIDList
  idl = [0].pack("V")
  ret = shGetSpecialFolderLocation.call(0,csidl_personal,idl)
  return "." if ret!=0
  path = "\0"*512
  ret = shGetPathFromIDList.call(idl.unpack("V")[0],path)
  return "." if ret==0
  return path.gsub(/\0/,"")
end

# Returns a country ID
# http://msdn.microsoft.com/en-us/library/dd374073%28VS.85%29.aspx?
def pbGetCountry()
  getUserGeoID = Win32API.new("kernel32","GetUserGeoID","l","i") rescue nil
  return getUserGeoID.call(16) if getUserGeoID
  return 0
end

# Returns a language ID
def pbGetLanguage()
  getUserDefaultLangID = Win32API.new("kernel32","GetUserDefaultLangID","","i") rescue nil
  ret = 0
  ret = getUserDefaultLangID.call()&0x3FF if getUserDefaultLangID
  if ret==0 # Unknown
    ret = MiniRegistry.get(MiniRegistry::HKEY_CURRENT_USER,
       "Control Panel\\Desktop\\ResourceLocale","",0)
    ret = MiniRegistry.get(MiniRegistry::HKEY_CURRENT_USER,
       "Control Panel\\International","Locale","0").to_i(16) if ret==0
    ret = ret&0x3FF
    return 0 if ret==0  # Unknown
  end
  case ret
  when 0x11; return 1 # Japanese
  when 0x09; return 2 # English
  when 0x0C; return 3 # French
  when 0x10; return 4 # Italian
  when 0x07; return 5 # German
  when 0x0A; return 7 # Spanish
  when 0x12; return 8 # Korean
  end
  return 2 # Use 'English' by default
end

# Converts a Celsius temperature to Fahrenheit.
def toFahrenheit(celsius)
  return (celsius*9.0/5.0).round+32
end

# Converts a Fahrenheit temperature to Celsius.
def toCelsius(fahrenheit)
  return ((fahrenheit-32)*5.0/9.0).round
end



#===============================================================================
# General-purpose utilities with dependencies
#===============================================================================
# Similar to pbFadeOutIn, but pauses the music as it fades out.
# Requires scripts "Audio" (for bgm_pause) and "SpriteWindow" (for pbFadeOutIn).
def pbFadeOutInWithMusic(zViewport=99999)
  playingBGS = $game_system.getPlayingBGS
  playingBGM = $game_system.getPlayingBGM
  $game_system.bgm_pause(1.0)
  $game_system.bgs_pause(1.0)
  pos = $game_system.bgm_position
  pbFadeOutIn(zViewport) {
     yield
     $game_system.bgm_position = pos
     $game_system.bgm_resume(playingBGM)
     $game_system.bgs_resume(playingBGS)
  }
end

# Gets the wave data from a file and displays an message if an error occurs.
# Can optionally delete the wave file (this is useful if the file was a
# temporary file created by a recording).
# Requires the script AudioUtilities
# Requires the script "PokemonMessages"
def getWaveDataUI(filename,deleteFile=false)
  error = getWaveData(filename)
  if deleteFile
    begin
      File.delete(filename)
    rescue Errno::EINVAL, Errno::EACCES, Errno::ENOENT
    end
  end
  case error
  when 1
    pbMessage(_INTL("The recorded data could not be found or saved."))
  when 2
    pbMessage(_INTL("The recorded data was in an invalid format."))
  when 3
    pbMessage(_INTL("The recorded data's format is not supported."))
  when 4
    pbMessage(_INTL("There was no sound in the recording. Please ensure that a microphone is attached to the computer and is ready."))
  else
    return error
  end
  return nil
end

# Starts recording, and displays a message if the recording failed to start.
# Returns true if successful, false otherwise
# Requires the script AudioUtilities
# Requires the script "PokemonMessages"
def beginRecordUI
  code = beginRecord
  case code
  when 0; return true
  when 256+66
    pbMessage(_INTL("All recording devices are in use. Recording is not possible now."))
    return false
  when 256+72
    pbMessage(_INTL("No supported recording device was found. Recording is not possible."))
    return false
  else
    buffer = "\0"*256
    MciErrorString.call(code,buffer,256)
    pbMessage(_INTL("Recording failed: {1}",buffer.gsub(/\x00/,"")))
    return false
  end
end



#===============================================================================
# Constants utilities
#===============================================================================
def isConst?(val,mod,constant)
  begin
    return false if !mod.const_defined?(constant.to_sym)
  rescue
    return false
  end
  return (val==mod.const_get(constant.to_sym))
end

def hasConst?(mod,constant)
  return false if !mod || !constant || constant==""
  return mod.const_defined?(constant.to_sym) rescue false
end

def getConst(mod,constant)
  return nil if !mod || !constant || constant==""
  return mod.const_get(constant.to_sym) rescue nil
end

def getID(mod,constant)
  return nil if !mod || !constant || constant==""
  if constant.is_a?(Symbol) || constant.is_a?(String)
    if (mod.const_defined?(constant.to_sym) rescue false)
      return mod.const_get(constant.to_sym) rescue 0
    end
    return 0
  end
  return constant
end



#===============================================================================
# Linear congruential random number generator
#===============================================================================
class LinearCongRandom
  def initialize(mul, add, seed=nil)
    @s1 = mul
    @s2 = add
    @seed = seed
    @seed = (Time.now.to_i&0xffffffff) if !@seed
    @seed = (@seed+0xFFFFFFFF)+1 if @seed<0
  end

  def self.dsSeed
    t = Time.now
    seed = (((t.mon*t.mday+t.min+t.sec)&0xFF)<<24) | (t.hour << 16) | (t.year-2000)
    seed = (seed+0xFFFFFFFF)+1 if seed<0
    return seed
  end

  def self.pokemonRNG
    self.new(0x41c64e6d,0x6073,self.dsSeed)
  end

  def self.pokemonRNGInverse
    self.new(0xeeb9eb65,0xa3561a1,self.dsSeed)
  end

  def self.pokemonARNG
    self.new(0x6C078965,0x01,self.dsSeed)
  end

  def getNext16 # calculates @seed * @s1 + @s2
    @seed = ((((@seed&0x0000ffff)*(@s1&0x0000ffff))&0x0000ffff) |
       (((((((@seed&0x0000ffff)*(@s1&0x0000ffff))&0xffff0000)>>16) +
       ((((@seed&0xffff0000)>>16)*(@s1&0x0000ffff))&0x0000ffff) +
       (((@seed&0x0000ffff)*((@s1&0xffff0000)>>16))&0x0000ffff)) &
       0x0000ffff)<<16)) + @s2
    r = (@seed>>16)
    r = (r+0xFFFFFFFF)+1 if r<0
    return r
  end

  def getNext
    r = (getNext16()<<16) | (getNext16())
    r = (r+0xFFFFFFFF)+1 if r<0
    return r
  end
end



#===============================================================================
# Json-related utilities
#===============================================================================
# Returns true if the given string represents a valid object in JavaScript
# Object Notation, and false otherwise.
def pbIsJsonString(str)
  return false if !str || str[/^[\s]*$/]
  d              = /(?:^|:|,)(?: ?\[)+/
  charEscapes    = /\\[\"\\\/nrtubf]/ #"
  stringLiterals = /"[^"\\\n\r\x00-\x1f\x7f-\x9f]*"/ #"
  whiteSpace     = /[\s]+/
  str = str.gsub(charEscapes,"@").gsub(stringLiterals,"true").gsub(whiteSpace," ")
  # prevent cases like "truetrue" or "true true" or "true[true]" or "5-2" or "5true"
  otherLiterals = /(true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?)(?! ?[0-9a-z\-\[\{\"])/ #"
  str = str.gsub(otherLiterals,"]").gsub(d,"") #"
  return str[/^[\],:{} ]*$/] ? true : false
end

# Returns a Ruby object that corresponds to the given string, which is encoded in
# JavaScript Object Notation (JSON). Returns nil if the string is not valid JSON.
def pbParseJson(str)
  return nil if !pbIsJsonString(str)
  stringRE = /(\"(\\[\"\'\\rntbf]|\\u[0-9A-Fa-f]{4,4}|[^\\\"])*\")/ #"
  strings = []
  str = str.gsub(stringRE) {
    sl = strings.length
    ss = $1
    if ss.include?("\\u")
      ss.gsub!(/\\u([0-9A-Fa-f]{4,4})/) {
        codepoint = $1.to_i(16)
        if codepoint<=0x7F
          next sprintf("\\x%02X",codepoint)
        elsif codepoint<=0x7FF
          next sprintf("%s%s",
             (0xC0|((codepoint>>6)&0x1F)).chr,
             (0x80|(codepoint&0x3F)).chr)
        else
          next sprintf("%s%s%s",
             (0xE0|((codepoint>>12)&0x0F)).chr,
             (0x80|((codepoint>>6)&0x3F)).chr,
             (0x80|(codepoint&0x3F)).chr)
        end
      }
    end
    strings.push(eval(ss))
    next sprintf("strings[%d]",sl)
  }
  str = str.gsub(/\:/,"=>")
  str = str.gsub(/null/,"nil")
  return eval("("+str+")")
end



#===============================================================================
# XML-related utilities
#===============================================================================
# Represents XML content.
class MiniXmlContent
  attr_reader :value

  def initialize(value)
    @value = value
  end
end



# Represents an XML element.
class MiniXmlElement
  attr_accessor :name,:attributes,:children

  def initialize(name)
    @name = name
    @attributes = {}
    @children = []
  end

#  Gets the value of the attribute with the given name, or nil if it doesn't
#  exist.
  def a(name)
    self.attributes[name]
  end

#  Gets the entire text of this element.
  def value
    ret = ""
    for c in @children
      ret += c.value
    end
    return ret
  end

#  Gets the first child of this element with the given name, or nil if it
# doesn't exist.
  def e(name)
    for c in @children
      return c if c.is_a?(MiniXmlElement) && c.name==name
    end
    return nil
  end

  def eachElementNamed(name)
    for c in @children
      yield c if c.is_a?(MiniXmlElement) && c.name==name
    end
  end
end



# A small class for reading simple XML documents. Such documents must
# meet the following restrictions:
#  They may contain comments and processing instructions, but they are
#    ignored.
#  They can't contain any entity references other than 'gt', 'lt',
#    'amp', 'apos', or 'quot'.
#  They can't contain a DOCTYPE declaration or DTDs.
class MiniXmlReader
  def initialize(data)
    @root = nil
    @elements = []
    @done = false
    @data = data
    @content = ""
  end

  def createUtf8(codepoint) #:nodoc:
    raise ArgumentError.new("Illegal character") if codepoint<9 ||
       codepoint==11 || codepoint==12 || (codepoint>=14 && codepoint<32) ||
       codepoint==0xFFFE || codepoint==0xFFFF || (codepoint>=0xD800 && codepoint<0xE000)
    return codepoint.chr if codepoint<=0x7F
    if codepoint<=0x7FF
      str = (0xC0|((codepoint>>6)&0x1F)).chr
      str += (0x80|(codepoint   &0x3F)).chr
      return str
    elsif codepoint<=0xFFFF
      str = (0xE0|((codepoint>>12)&0x0F)).chr
      str += (0x80|((codepoint>>6)&0x3F)).chr
      str += (0x80|(codepoint   &0x3F)).chr
      return str
    elsif codepoint<=0x10FFFF
      str = (0xF0|((codepoint>>18)&0x07)).chr
      str += (0x80|((codepoint>>12)&0x3F)).chr
      str += (0x80|((codepoint>>6)&0x3F)).chr
      str += (0x80|(codepoint   &0x3F)).chr
      return str
    else
      raise ArgumentError.new("Illegal character")
    end
  end

  def unescape(attr) #:nodoc:
    attr = attr.gsub(/\r(\n|$|(?=[^\n]))/,"\n")
    raise ArgumentError.new("Attribute value contains '<'") if attr.include?("<")
    attr = attr.gsub(/&(lt|gt|apos|quot|amp|\#([0-9]+)|\#x([0-9a-fA-F]+));|([\n\r\t])/) {
      next " " if $4=="\n"||$4=="\r"||$4=="\t"
      next "<" if $1=="lt"
      next ">" if $1=="gt"
      next "'" if $1=="apos"
      next "\"" if $1=="quot"
      next "&" if $1=="amp"
      next createUtf8($2.to_i) if $2
      next createUtf8($3.to_i(16)) if $3
    }
    return attr
  end

  def readAttributes(attribs) #:nodoc:
    ret = {}
    while attribs.length>0
      if attribs[/(\s+([\w\-]+)\s*\=\s*\"([^\"]*)\")/]
        attribs = attribs[$1.length,attribs.length]
        name = $2; value = $3
        raise ArgumentError.new("Attribute already exists") if ret[name]!=nil
        ret[name] = unescape(value)
      elsif attribs[/(\s+([\w\-]+)\s*\=\s*\'([^\']*)\')/]
        attribs = attribs[$1.length,attribs.length]
        name = $2; value = $3
        raise ArgumentError.new("Attribute already exists") if ret[name]!=nil
        ret[name] = unescape(value)
      else
        raise ArgumentError.new("Can't parse attributes")
      end
    end
    return ret
  end

# Reads the entire contents of an XML document. Returns the root element of
# the document or raises an ArgumentError if an error occurs.
  def read
    if @data[/\A((\xef\xbb\xbf)?<\?xml\s+version\s*=\s*(\"1\.[0-9]\"|\'1\.[0-9]\')(\s+encoding\s*=\s*(\"[^\"]*\"|\'[^\']*\'))?(\s+standalone\s*=\s*(\"(yes|no)\"|\'(yes|no)\'))?\s*\?>)/]
      # Ignore XML declaration
      @data = @data[$1.length,@data.length]
    end
    while readOneElement(); end
    return @root
  end

  def readOneElement #:nodoc:
    if @data[/\A\s*\z/]
      @data = ""
      if !@root
        raise ArgumentError.new("Not an XML document.")
      elsif !@done
        raise ArgumentError.new("Unexpected end of document.")
      end
      return false
    end
    if @data[/\A(\s*<([\w\-]+)((?:\s+[\w\-]+\s*\=\s*(?:\"[^\"]*\"|\'[^\']*\'))*)\s*(\/>|>))/]
      @data = @data[$1.length,@data.length]
      elementName = $2
      attributes  = $3
      endtag      = $4
      raise ArgumentError.new("Element tag at end of document") if @done
      if @content.length>0 && @elements.length>0
        @elements[@elements.length-1].children.push(MiniXmlContent.new(@content))
        @content = ""
      end
      element = MiniXmlElement.new(elementName)
      element.attributes = readAttributes(attributes)
      if !@root
        @root = element
      else
        @elements[@elements.length-1].children.push(element)
      end
      if endtag==">"
        @elements.push(element)
      else
        @done = true if @elements.length==0
      end
    elsif @data[/\A(<!--([\s\S]*?)-->)/]
      # ignore comments
      raise ArgumentError.new("Incorrect comment") if $2.include?("--")
      @data = @data[$1.length,@data.length]
    elsif @data[/\A(<\?([\w\-]+)\s+[\s\S]*?\?>)/]
      # ignore processing instructions
      @data = @data[$1.length,@data.length]
      if $2.downcase=="xml"
        raise ArgumentError.new("'xml' processing instruction not allowed")
      end
    elsif @data[/\A(<\?([\w\-]+)\?>)/]
      # ignore processing instructions
      @data = @data[$1.length,@data.length]
      if $2.downcase=="xml"
        raise ArgumentError.new("'xml' processing instruction not allowed")
      end
    elsif @data[/\A(\s*<\/([\w\-]+)>)/]
      @data = @data[$1.length,@data.length]
      elementName = $2
      raise ArgumentError.new("End tag at end of document") if @done
      if @elements.length==0
        raise ArgumentError.new("Unexpected end tag")
      elsif @elements[@elements.length-1].name!=elementName
        raise ArgumentError.new("Incorrect end tag")
      else
        if @content.length>0
          @elements[@elements.length-1].children.push(MiniXmlContent.new(@content))
          @content = ""
        end
        @elements.pop()
        @done = true if @elements.length==0
      end
    else
      if @elements.length>0
        # Parse content
        if @data[/\A([^<&]+)/]
          content = $1
          @data = @data[content.length,@data.length]
          raise ArgumentError.new("Incorrect content") if content.include?("]]>")
          content.gsub!(/\r(\n|\z|(?=[^\n]))/,"\n")
          @content += content
        elsif @data[/\A(<\!\[CDATA\[([\s\S]*?)\]\]>)/]
          content = $2
          @data = @data[$1.length,@data.length]
          content.gsub!(/\r(\n|\z|(?=[^\n]))/,"\n")
          @content += content
        elsif @data[/\A(&(lt|gt|apos|quot|amp|\#([0-9]+)|\#x([0-9a-fA-F]+));)/]
          @data = @data[$1.length,@data.length]
          content = ""
          if $2=="lt"; content = "<"
          elsif $2=="gt"; content = ">"
          elsif $2=="apos"; content = "'"
          elsif $2=="quot"; content = "\""
          elsif $2=="amp"; content = "&"
          elsif $3; content = createUtf8($2.to_i)
          elsif $4; content = createUtf8($3.to_i(16))
          end
          @content += content
        elsif !@data[/\A</]
          raise ArgumentError.new("Can't read XML content")
        end
      else
        raise ArgumentError.new("Can't parse XML")
      end
    end
    return true
  end
end



#===============================================================================
# Event utilities
#===============================================================================
def pbTimeEvent(variableNumber,secs=86400)
  if variableNumber && variableNumber>=0
    if $game_variables
      secs = 0 if secs<0
      timenow = pbGetTimeNow
      $game_variables[variableNumber] = [timenow.to_f,secs]
      $game_map.refresh if $game_map
    end
  end
end

def pbTimeEventDays(variableNumber,days=0)
  if variableNumber && variableNumber>=0
    if $game_variables
      days = 0 if days<0
      timenow = pbGetTimeNow
      time = timenow.to_f
      expiry = (time%86400.0)+(days*86400.0)
      $game_variables[variableNumber] = [time,expiry-time]
      $game_map.refresh if $game_map
    end
  end
end

def pbTimeEventValid(variableNumber)
  retval = false
  if variableNumber && variableNumber>=0 && $game_variables
    value = $game_variables[variableNumber]
    if value.is_a?(Array)
      timenow = pbGetTimeNow
      retval = (timenow.to_f - value[0] > value[1]) # value[1] is age in seconds
      retval = false if value[1]<=0 # zero age
    end
    if !retval
      $game_variables[variableNumber] = 0
      $game_map.refresh if $game_map
    end
  end
  return retval
end

def pbExclaim(event,id=EXCLAMATION_ANIMATION_ID,tinting=false)
  if event.is_a?(Array)
    sprite = nil
    done = []
    for i in event
      if !done.include?(i.id)
        sprite = $scene.spriteset.addUserAnimation(id,i.x,i.y,tinting,2)
        done.push(i.id)
      end
    end
  else
    sprite = $scene.spriteset.addUserAnimation(id,event.x,event.y,tinting,2)
  end
  while !sprite.disposed?
    Graphics.update
    Input.update
    pbUpdateSceneMap
  end
end

def pbNoticePlayer(event)
  if !pbFacingEachOther(event,$game_player)
    pbExclaim(event)
  end
  pbTurnTowardEvent($game_player,event)
  pbMoveTowardPlayer(event)
end



#===============================================================================
# Player-related utilities, random name generator
#===============================================================================
def pbChangePlayer(id)
  return false if id<0 || id>=8
  meta = pbGetMetadata(0,MetadataPlayerA+id)
  return false if !meta
  $Trainer.trainertype = meta[0] if $Trainer
  $game_player.character_name = meta[1]
  $game_player.character_hue = 0
  $PokemonGlobal.playerID = id
  $Trainer.metaID = id if $Trainer
end

def pbGetPlayerGraphic
  id = $PokemonGlobal.playerID
  return "" if id<0 || id>=8
  meta = pbGetMetadata(0,MetadataPlayerA+id)
  return "" if !meta
  return pbPlayerSpriteFile(meta[0])
end

def pbGetPlayerTrainerType
  id = $PokemonGlobal.playerID
  return 0 if id<0 || id>=8
  meta = pbGetMetadata(0,MetadataPlayerA+id)
  return 0 if !meta
  return meta[0]
end

def pbGetTrainerTypeGender(trainertype)
  data = pbGetTrainerTypeData(trainertype)
  return data[7] if data && data[7]
  return 2   # Gender unknown
end

def pbTrainerName(name=nil,outfit=0)
  pbChangePlayer(0) if $PokemonGlobal.playerID<0
  trainertype = pbGetPlayerTrainerType
  trname = name
  $Trainer = PokeBattle_Trainer.new(trname,trainertype)
  $Trainer.outfit = outfit
  if trname==nil
    trname = pbEnterPlayerName(_INTL("Your name?"),0,MAX_PLAYER_NAME_SIZE)
    if trname==""
      gender = pbGetTrainerTypeGender(trainertype)
      trname = pbSuggestTrainerName(gender)
    end
  end
  $Trainer.name = trname
  $PokemonBag = PokemonBag.new
  $PokemonTemp.begunNewGame = true
end

def pbSuggestTrainerName(gender)
  userName = pbGetUserName()
  userName = userName.gsub(/\s+.*$/,"")
  if userName.length>0 && userName.length<7
    userName[0,1] = userName[0,1].upcase
    return userName
  end
  userName = userName.gsub(/\d+$/,"")
  if userName.length>0 && userName.length<7
    userName[0,1] = userName[0,1].upcase
    return userName
  end
  owner = MiniRegistry.get(MiniRegistry::HKEY_LOCAL_MACHINE,
     "SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion","RegisteredOwner","")
  owner = owner.gsub(/\s+.*$/,"")
  if owner.length>0 && owner.length<7
    owner[0,1] = owner[0,1].upcase
    return owner
  end
  return getRandomNameEx(gender,nil,1,MAX_PLAYER_NAME_SIZE)
end

def pbGetUserName
  buffersize = 100
  getUserName=Win32API.new('advapi32.dll','GetUserName','pp','i')
  10.times do
    size = [buffersize].pack("V")
    buffer = "\0"*buffersize
    if getUserName.call(buffer,size)!=0
      return buffer.gsub(/\0/,"")
    end
    buffersize += 200
  end
  return ""
end

def getRandomNameEx(type,variable,upper,maxLength=100)
  return "" if maxLength<=0
  name = ""
  50.times {
    name = ""
    formats = []
    case type
    when 0; formats = %w( F5 BvE FE FE5 FEvE )            # Names for males
    when 1; formats = %w( vE6 vEvE6 BvE6 B4 v3 vEv3 Bv3 ) # Names for females
    when 2; formats = %w( WE WEU WEvE BvE BvEU BvEvE )    # Neutral gender names
    else; return ""
    end
    format = formats[rand(formats.length)]
    format.scan(/./) { |c|
      case c
      when "c" # consonant
        set = %w( b c d f g h j k l m n p r s t v w x z )
        name += set[rand(set.length)]
      when "v" # vowel
        set = %w( a a a e e e i i i o o o u u u )
        name += set[rand(set.length)]
      when "W" # beginning vowel
        set = %w( a a a e e e i i i o o o u u u au au ay ay ea ea ee ee oo oo ou ou )
        name += set[rand(set.length)]
      when "U" # ending vowel
        set = %w( a a a a a e e e i i i o o o o o u u ay ay ie ie ee ue oo )
        name += set[rand(set.length)]
      when "B" # beginning consonant
        set1 = %w( b c d f g h j k l l m n n p r r s s t t v w y z )
        set2 = %w( bl br ch cl cr dr fr fl gl gr kh kl kr ph pl pr sc sk sl
           sm sn sp st sw th tr tw vl zh )
        name += (rand(3)>0) ? set1[rand(set1.length)] : set2[rand(set2.length)]
      when "E" # ending consonant
        set1 = %w( b c d f g h j k k l l m n n p r r s s t t v z )
        set2 = %w( bb bs ch cs ds fs ft gs gg ld ls nd ng nk rn kt ks
           ms ns ph pt ps sk sh sp ss st rd rn rp rm rt rk ns th zh)
        name += (rand(3)>0) ? set1[rand(set1.length)] : set2[rand(set2.length)]
      when "f" # consonant and vowel
        set = %w( iz us or )
        name += set[rand(set.length)]
      when "F" # consonant and vowel
        set = %w( bo ba be bu re ro si mi zho se nya gru gruu glee gra glo ra do zo ri
           di ze go ga pree pro po pa ka ki ku de da ma mo le la li )
        name += set[rand(set.length)]
      when "2"
        set = %w( c f g k l p r s t )
        name += set[rand(set.length)]
      when "3"
        set = %w( nka nda la li ndra sta cha chie )
        name += set[rand(set.length)]
      when "4"
        set = %w( una ona ina ita ila ala ana ia iana )
        name += set[rand(set.length)]
      when "5"
        set = %w( e e o o ius io u u ito io ius us )
        name += set[rand(set.length)]
      when "6"
        set = %w( a a a elle ine ika ina ita ila ala ana )
        name += set[rand(set.length)]
      end
    }
    break if name.length<=maxLength
  }
  name = name[0,maxLength]
  case upper
  when 0; name = name.upcase
  when 1; name[0,1] = name[0,1].upcase
  end
  if $game_variables && variable
    $game_variables[variable] = name
    $game_map.need_refresh = true if $game_map
  end
  return name
end

def getRandomName(maxLength=100)
  return getRandomNameEx(2,nil,nil,maxLength)
end



#===============================================================================
# fSpecies utilities
#===============================================================================
def pbGetFSpeciesFromForm(species,form=0)
  return species if form==0
  ret = species
  species = pbGetSpeciesFromFSpecies(species)[0] if species>PBSpecies.maxValue
  formData = pbLoadFormToSpecies
  if formData[species] && formData[species][form] && formData[species][form]>0
    ret = formData[species][form]
  end
  return ret
end

def pbGetSpeciesFromFSpecies(species)
  return [species,0] if species<=PBSpecies.maxValue
  formdata = pbLoadFormToSpecies
  for i in 1...formdata.length
    next if !formdata[i]
    for j in 0...formdata[i].length
      return [i,j] if formdata[i][j]==species
    end
  end
  return [species,0]
end



#===============================================================================
# Regional and National Pokédexes utilities
#===============================================================================
# Gets the ID number for the current region based on the player's current
# position. Returns the value of "defaultRegion" (optional, default is -1) if
# no region was defined in the game's metadata. The ID numbers returned by
# this function depend on the current map's position metadata.
def pbGetCurrentRegion(defaultRegion=-1)
  mappos = ($game_map) ? pbGetMetadata($game_map.map_id,MetadataMapPosition) : nil
  return (mappos) ? mappos[0] : defaultRegion
end

# Gets the Regional Pokédex number of the national species for the specified
# Regional Dex. The parameter "region" is zero-based. For example, if two
# regions are defined, they would each be specified as 0 and 1.
def pbGetRegionalNumber(region,nationalSpecies)
  if nationalSpecies<=0 || nationalSpecies>PBSpecies.maxValue
    # Return 0 if national species is outside range
    return 0
  end
  dexList = pbLoadRegionalDexes[region]
  return 0 if !dexList || dexList.length==0
  return dexList[nationalSpecies] || 0
end

# Gets the National Pokédex number of the specified species and region.  The
# parameter "region" is zero-based.  For example, if two regions are defined,
# they would each be specified as 0 and 1.
def pbGetNationalNumber(region,regionalSpecies)
  dexList = pbLoadRegionalDexes[region]
  return 0 if !dexList || dexList.length==0
  for i in 0...dexList.length
    return i if dexList[i]==regionalSpecies
  end
  return 0
end

# Gets an array of all national species within the given Regional Dex, sorted by
# Regional Dex number. The number of items in the array should be the
# number of species in the Regional Dex plus 1, since index 0 is considered
# to be empty. The parameter "region" is zero-based. For example, if two
# regions are defined, they would each be specified as 0 and 1.
def pbAllRegionalSpecies(region)
  ret = [0]
  return ret if region<0
  dexList = pbLoadRegionalDexes[region]
  return ret if !dexList || dexList.length==0
  for i in 0...dexList.length
    ret[dexList[i]] = i if dexList[i]
  end
  ret.map! { |e| e ? e : 0 }   # Replace nils with 0s
  return ret
end

def pbGetRegionalDexLength(region)
  return PBSpecies.maxValue if region<0
  ret = 0
  dexList = pbLoadRegionalDexes[region]
  return ret if !dexList || dexList.length==0
  for i in 0...dexList.length
    ret = dexList[i] if dexList[i] && dexList[i]>ret
  end
  return ret
end

# Decides which Dex lists are able to be viewed (i.e. they are unlocked and have
# at least 1 seen species in them), and saves all viable dex region numbers
# (National Dex comes after regional dexes).
# If the Dex list shown depends on the player's location, this just decides if
# a species in the current region has been seen - doesn't look at other regions.
# Here, just used to decide whether to show the Pokédex in the Pause menu.
def pbSetViableDexes
  $PokemonGlobal.pokedexViable = []
  if USE_CURRENT_REGION_DEX
    region = pbGetCurrentRegion
    region = -1 if region>=$PokemonGlobal.pokedexUnlocked.length-1
    $PokemonGlobal.pokedexViable[0] = region if $Trainer.pokedexSeen(region)>0
  else
    numDexes = $PokemonGlobal.pokedexUnlocked.length
    if numDexes==1 # National Dex only
      if $PokemonGlobal.pokedexUnlocked[0]
        $PokemonGlobal.pokedexViable.push(0) if $Trainer.pokedexSeen>0
      end
    else           # Regional dexes + National Dex
      for i in 0...numDexes
        regionToCheck = (i==numDexes-1) ? -1 : i
        if $PokemonGlobal.pokedexUnlocked[i]
          $PokemonGlobal.pokedexViable.push(i) if $Trainer.pokedexSeen(regionToCheck)>0
        end
      end
    end
  end
end

# Unlocks a Dex list. The National Dex is -1 here (or nil argument).
def pbUnlockDex(dex=-1)
  index = dex
  if index<0 || index>$PokemonGlobal.pokedexUnlocked.length-1
    index = $PokemonGlobal.pokedexUnlocked.length-1
  end
  $PokemonGlobal.pokedexUnlocked[index] = true
end

# Locks a Dex list. The National Dex is -1 here (or nil argument).
def pbLockDex(dex=-1)
  index = dex
  if index<0 || index>$PokemonGlobal.pokedexUnlocked.length-1
    index = $PokemonGlobal.pokedexUnlocked.length-1
  end
  $PokemonGlobal.pokedexUnlocked[index] = false
end



#===============================================================================
# Other utilities
#===============================================================================
def pbTextEntry(helptext,minlength,maxlength,variableNumber)
  $game_variables[variableNumber] = pbEnterText(helptext,minlength,maxlength)
  $game_map.need_refresh = true if $game_map
end

def pbMoveTutorAnnotations(move,movelist=nil)
  ret = []
  for i in 0...6
    ret[i] = nil
    next if i>=$Trainer.party.length
    found = false
    for j in 0...4
      if !$Trainer.party[i].egg? && $Trainer.party[i].moves[j].id==move
        ret[i] = _INTL("LEARNED")
        found = true
      end
    end
    next if found
    species = $Trainer.party[i].species
    if !$Trainer.party[i].egg? && movelist && movelist.any? { |j| j==species }
      # Checked data from movelist
      ret[i] = _INTL("ABLE")
    elsif !$Trainer.party[i].egg? && $Trainer.party[i].compatibleWithMove?(move)
      # Checked data from PBS/tm.txt
      ret[i] = _INTL("ABLE")
    else
      ret[i] = _INTL("NOT ABLE")
    end
  end
  return ret
end

def pbMoveTutorChoose(move,movelist=nil,bymachine=false)
  ret = false
  move = getID(PBMoves,move)
  if movelist!=nil && movelist.is_a?(Array)
    for i in 0...movelist.length
      movelist[i] = getID(PBSpecies,movelist[i])
    end
  end
  pbFadeOutIn {
    movename = PBMoves.getName(move)
    annot = pbMoveTutorAnnotations(move,movelist)
    scene = PokemonParty_Scene.new
    screen = PokemonPartyScreen.new(scene,$Trainer.party)
    screen.pbStartScene(_INTL("Teach which Pokémon?"),false,annot)
    loop do
      chosen = screen.pbChoosePokemon
      break if chosen<0
      pokemon = $Trainer.party[chosen]
      if pokemon.egg?
        pbMessage(_INTL("Eggs can't be taught any moves.")) { screen.pbUpdate }
      elsif pokemon.shadowPokemon?
        pbMessage(_INTL("Shadow Pokémon can't be taught any moves.")) { screen.pbUpdate }
      elsif movelist && !movelist.any? { |j| j==pokemon.species }
        pbMessage(_INTL("{1} can't learn {2}.",pokemon.name,movename)) { screen.pbUpdate }
      elsif !pokemon.compatibleWithMove?(move)
        pbMessage(_INTL("{1} can't learn {2}.",pokemon.name,movename)) { screen.pbUpdate }
      else
        if pbLearnMove(pokemon,move,false,bymachine) { screen.pbUpdate }
          ret = true
          break
        end
      end
    end
    screen.pbEndScene
  }
  return ret   # Returns whether the move was learned by a Pokemon
end

def pbChooseMove(pokemon,variableNumber,nameVarNumber)
  return if !pokemon
  ret = -1
  pbFadeOutIn {
    scene = PokemonSummary_Scene.new
    screen = PokemonSummaryScreen.new(scene)
    ret = screen.pbStartForgetScreen([pokemon],0,0)
  }
  $game_variables[variableNumber] = ret
  if ret>=0
    $game_variables[nameVarNumber] = PBMoves.getName(pokemon.moves[ret].id)
  else
    $game_variables[nameVarNumber] = ""
  end
  $game_map.need_refresh = true if $game_map
end

def pbConvertItemToItem(variable,array)
  item = pbGet(variable)
  pbSet(variable,0)
  for i in 0...(array.length/2)
    if isConst?(item,PBItems,array[2*i])
      pbSet(variable,getID(PBItems,array[2*i+1]))
      return
    end
  end
end

def pbConvertItemToPokemon(variable,array)
  item = pbGet(variable)
  pbSet(variable,0)
  for i in 0...(array.length/2)
    next if !isConst?(item,PBItems,array[2*i])
    pbSet(variable,getID(PBSpecies,array[2*i+1]))
    return
  end
end

# Gets the value of a variable.
def pbGet(id)
  return 0 if !id || !$game_variables
  return $game_variables[id]
end

# Sets the value of a variable.
def pbSet(id,value)
  return if !id || id<0
  $game_variables[id] = value if $game_variables
  $game_map.need_refresh = true if $game_map
end

# Runs a common event and waits until the common event is finished.
# Requires the script "Messages"
def pbCommonEvent(id)
  return false if id<0
  ce = $data_common_events[id]
  return false if !ce
  celist = ce.list
  interp = Interpreter.new
  interp.setup(celist,0)
  begin
    Graphics.update
    Input.update
    interp.update
    pbUpdateSceneMap
  end while interp.running?
  return true
end

def pbHideVisibleObjects
  visibleObjects = []
  ObjectSpace.each_object(Sprite) { |o|
    if !o.disposed? && o.visible
      visibleObjects.push(o)
      o.visible = false
    end
  }
  ObjectSpace.each_object(Viewport) { |o|
    if !pbDisposed?(o) && o.visible
      visibleObjects.push(o)
      o.visible = false
    end
  }
  ObjectSpace.each_object(Plane) { |o|
    if !o.disposed? && o.visible
      visibleObjects.push(o)
      o.visible = false
    end
  }
  ObjectSpace.each_object(Tilemap) { |o|
    if !o.disposed? && o.visible
      visibleObjects.push(o)
      o.visible = false
    end
  }
  ObjectSpace.each_object(Window) { |o|
    if !o.disposed? && o.visible
      visibleObjects.push(o)
      o.visible = false
    end
  }
  return visibleObjects
end

def pbShowObjects(visibleObjects)
  for o in visibleObjects
    next if pbDisposed?(o)
    o.visible = true
  end
end

def pbLoadRpgxpScene(scene)
  return if !$scene.is_a?(Scene_Map)
  oldscene = $scene
  $scene = scene
  Graphics.freeze
  oldscene.disposeSpritesets
  visibleObjects = pbHideVisibleObjects
  Graphics.transition(20)
  Graphics.freeze
  while $scene && !$scene.is_a?(Scene_Map)
    $scene.main
  end
  Graphics.transition(20)
  Graphics.freeze
  $scene = oldscene
  $scene.createSpritesets
  pbShowObjects(visibleObjects)
  Graphics.transition(20)
end




class PokemonGlobalMetadata
  attr_accessor :trainerRecording
end



def pbRecordTrainer
  wave = pbRecord(nil,10)
  if wave
    $PokemonGlobal.trainerRecording = wave
    return true
  end
  return false
end
