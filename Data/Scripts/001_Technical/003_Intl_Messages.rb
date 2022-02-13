def pbAddScriptTexts(items, script)
  script.scan(/(?:_I)\s*\(\s*\"((?:[^\\\"]*\\\"?)*[^\"]*)\"/) { |s|
    string = s[0]
    string.gsub!(/\\\"/, "\"")
    string.gsub!(/\\\\/, "\\")
    items.push(string)
  }
end

def pbAddRgssScriptTexts(items, script)
  script.scan(/(?:_INTL|_ISPRINTF)\s*\(\s*\"((?:[^\\\"]*\\\"?)*[^\"]*)\"/) { |s|
    string = s[0]
    string.gsub!(/\\r/, "\r")
    string.gsub!(/\\n/, "\n")
    string.gsub!(/\\1/, "\1")
    string.gsub!(/\\\"/, "\"")
    string.gsub!(/\\\\/, "\\")
    items.push(string)
  }
end

def pbSetTextMessages
  Graphics.update
  begin
    t = Time.now.to_i
    texts = []
    $RGSS_SCRIPTS.each do |script|
      if Time.now.to_i - t >= 5
        t = Time.now.to_i
        Graphics.update
      end
      scr = Zlib::Inflate.inflate(script[2])
      pbAddRgssScriptTexts(texts, scr)
    end
    if safeExists?("Data/PluginScripts.rxdata")
      plugin_scripts = load_data("Data/PluginScripts.rxdata")
      plugin_scripts.each do |plugin|
        plugin[2].each do |script|
          if Time.now.to_i - t >= 5
            t = Time.now.to_i
            Graphics.update
          end
          scr = Zlib::Inflate.inflate(script[1]).force_encoding(Encoding::UTF_8)
          pbAddRgssScriptTexts(texts, scr)
        end
      end
    end
    # Must add messages because this code is used by both game system and Editor
    MessageTypes.addMessagesAsHash(MessageTypes::ScriptTexts, texts)
    commonevents = load_data("Data/CommonEvents.rxdata")
    items = []
    choices = []
    commonevents.compact.each do |event|
      if Time.now.to_i - t >= 5
        t = Time.now.to_i
        Graphics.update
      end
      begin
        neednewline = false
        lastitem = ""
        event.list.size.times do |j|
          list = event.list[j]
          if neednewline && list.code != 401
            if lastitem != ""
              lastitem.gsub!(/([^\.\!\?])\s\s+/) { |m| $1 + " " }
              items.push(lastitem)
              lastitem = ""
            end
            neednewline = false
          end
          if list.code == 101
            lastitem += list.parameters[0].to_s
            neednewline = true
          elsif list.code == 102
            list.parameters[0].length.times do |k|
              choices.push(list.parameters[0][k])
            end
            neednewline = false
          elsif list.code == 401
            lastitem += " " if lastitem != ""
            lastitem += list.parameters[0].to_s
            neednewline = true
          elsif list.code == 355 || list.code == 655
            pbAddScriptTexts(items, list.parameters[0])
          elsif list.code == 111 && list.parameters[0] == 12
            pbAddScriptTexts(items, list.parameters[1])
          elsif list.code == 209
            route = list.parameters[1]
            route.list.size.times do |k|
              if route.list[k].code == 45
                pbAddScriptTexts(items, route.list[k].parameters[0])
              end
            end
          end
        end
        if neednewline && lastitem != ""
          items.push(lastitem)
          lastitem = ""
        end
      end
    end
    if Time.now.to_i - t >= 5
      t = Time.now.to_i
      Graphics.update
    end
    items |= []
    choices |= []
    items.concat(choices)
    MessageTypes.setMapMessagesAsHash(0, items)
    mapinfos = pbLoadMapInfos
    mapinfos.each_key do |id|
      if Time.now.to_i - t >= 5
        t = Time.now.to_i
        Graphics.update
      end
      filename = sprintf("Data/Map%03d.rxdata", id)
      next if !pbRgssExists?(filename)
      map = load_data(filename)
      items = []
      choices = []
      map.events.each_value do |event|
        if Time.now.to_i - t >= 5
          t = Time.now.to_i
          Graphics.update
        end
        begin
          event.pages.size.times do |i|
            neednewline = false
            lastitem = ""
            event.pages[i].list.size.times do |j|
              list = event.pages[i].list[j]
              if neednewline && list.code != 401
                if lastitem != ""
                  lastitem.gsub!(/([^\.\!\?])\s\s+/) { |m| $1 + " " }
                  items.push(lastitem)
                  lastitem = ""
                end
                neednewline = false
              end
              if list.code == 101
                lastitem += list.parameters[0].to_s
                neednewline = true
              elsif list.code == 102
                list.parameters[0].length.times do |k|
                  choices.push(list.parameters[0][k])
                end
                neednewline = false
              elsif list.code == 401
                lastitem += " " if lastitem != ""
                lastitem += list.parameters[0].to_s
                neednewline = true
              elsif list.code == 355 || list.code == 655
                pbAddScriptTexts(items, list.parameters[0])
              elsif list.code == 111 && list.parameters[0] == 12
                pbAddScriptTexts(items, list.parameters[1])
              elsif list.code == 209
                route = list.parameters[1]
                route.list.size.times do |k|
                  if route.list[k].code == 45
                    pbAddScriptTexts(items, route.list[k].parameters[0])
                  end
                end
              end
            end
            if neednewline && lastitem != ""
              items.push(lastitem)
              lastitem = ""
            end
          end
        end
      end
      if Time.now.to_i - t >= 5
        t = Time.now.to_i
        Graphics.update
      end
      items |= []
      choices |= []
      items.concat(choices)
      MessageTypes.setMapMessagesAsHash(id, items)
      if Time.now.to_i - t >= 5
        t = Time.now.to_i
        Graphics.update
      end
    end
  rescue Hangup
  end
  Graphics.update
end

def pbEachIntlSection(file)
  lineno = 1
  re = /^\s*\[\s*([^\]]+)\s*\]\s*$/
  havesection = false
  sectionname = nil
  lastsection = []
  file.each_line { |line|
    if lineno == 1 && line[0].ord == 0xEF && line[1].ord == 0xBB && line[2].ord == 0xBF
      line = line[3, line.length - 3]
    end
    if !line[/^\#/] && !line[/^\s*$/]
      if line[re]
        if havesection
          yield lastsection, sectionname
        end
        lastsection.clear
        sectionname = $~[1]
        havesection = true
      else
        if sectionname.nil?
          raise _INTL("Expected a section at the beginning of the file (line {1})", lineno)
        end
        lastsection.push(line.gsub(/\s+$/, ""))
      end
    end
    lineno += 1
    if lineno % 500 == 0
      Graphics.update
    end
  }
  if havesection
    yield lastsection, sectionname
  end
end

def pbGetText(infile)
  begin
    file = File.open(infile, "rb")
  rescue
    raise _INTL("Can't find {1}", infile)
  end
  intldat = []
  begin
    pbEachIntlSection(file) { |section, name|
      next if section.length == 0
      if !name[/^([Mm][Aa][Pp])?(\d+)$/]
        raise _INTL("Invalid section name {1}", name)
      end
      ismap = $~[1] && $~[1] != ""
      id = $~[2].to_i
      itemlength = 0
      if section[0][/^\d+$/]
        intlhash = []
        itemlength = 3
        if ismap
          raise _INTL("Section {1} can't be an ordered list (section was recognized as an ordered list because its first line is a number)", name)
        end
        if section.length % 3 != 0
          raise _INTL("Section {1}'s line count is not divisible by 3 (section was recognized as an ordered list because its first line is a number)", name)
        end
      else
        intlhash = OrderedHash.new
        itemlength = 2
        if section.length.odd?
          raise _INTL("Section {1} has an odd number of entries (section was recognized as a hash because its first line is not a number)", name)
        end
      end
      i = 0
      loop do
        break unless i < section.length
        if itemlength == 3
          if !section[i][/^\d+$/]
            raise _INTL("Expected a number in section {1}, got {2} instead", name, section[i])
          end
          key = section[i].to_i
          i += 1
        else
          key = MessageTypes.denormalizeValue(section[i])
        end
        intlhash[key] = MessageTypes.denormalizeValue(section[i + 1])
        i += 2
      end
      if ismap
        intldat[0] = [] if !intldat[0]
        intldat[0][id] = intlhash
      else
        intldat[id] = intlhash
      end
    }
  ensure
    file.close
  end
  return intldat
end

def pbCompileText
  outfile = File.open("intl.dat", "wb")
  begin
    intldat = pbGetText("intl.txt")
    Marshal.dump(intldat, outfile)
  rescue
    raise
  ensure
    outfile.close
  end
end



class OrderedHash < Hash
  def initialize
    @keys = []
    super
  end

  def keys
    return @keys.clone
  end

  def inspect
    str = "{"
    @keys.length.times do |i|
      str += ", " if i > 0
      str += @keys[i].inspect + "=>" + self[@keys[i]].inspect
    end
    str += "}"
    return str
  end

  alias to_s inspect

  def []=(key, value)
    oldvalue = self[key]
    if !oldvalue && value
      @keys.push(key)
    elsif !value
      @keys |= []
      @keys -= [key]
    end
    super(key, value)
  end

  def self._load(string)
    ret = self.new
    keysvalues = Marshal.load(string)
    keys = keysvalues[0]
    values = keysvalues[1]
    keys.length.times do |i|
      ret[keys[i]] = values[i]
    end
    return ret
  end

  def _dump(_depth = 100)
    values = []
    @keys.each do |key|
      values.push(self[key])
    end
    return Marshal.dump([@keys, values])
  end
end



class Messages
  def initialize(filename = nil, delayLoad = false)
    @messages = nil
    @filename = filename
    if @filename && !delayLoad
      loadMessageFile(@filename)
    end
  end

  def delayedLoad
    if @filename && !@messages
      loadMessageFile(@filename)
      @filename = nil
    end
  end

  def self.stringToKey(str)
    if str && str[/[\r\n\t\1]|^\s+|\s+$|\s{2,}/]
      key = str.clone
      key.gsub!(/^\s+/, "")
      key.gsub!(/\s+$/, "")
      key.gsub!(/\s{2,}/, " ")
      return key
    end
    return str
  end

  def self.normalizeValue(value)
    if value[/[\r\n\t\x01]|^[\[\]]/]
      ret = value.clone
      ret.gsub!(/\r/, "<<r>>")
      ret.gsub!(/\n/, "<<n>>")
      ret.gsub!(/\t/, "<<t>>")
      ret.gsub!(/\[/, "<<[>>")
      ret.gsub!(/\]/, "<<]>>")
      ret.gsub!(/\x01/, "<<1>>")
      return ret
    end
    return value
  end

  def self.denormalizeValue(value)
    if value[/<<[rnt1\[\]]>>/]
      ret = value.clone
      ret.gsub!(/<<1>>/, "\1")
      ret.gsub!(/<<r>>/, "\r")
      ret.gsub!(/<<n>>/, "\n")
      ret.gsub!(/<<\[>>/, "[")
      ret.gsub!(/<<\]>>/, "]")
      ret.gsub!(/<<t>>/, "\t")
      return ret
    end
    return value
  end

  def self.writeObject(f, msgs, secname, origMessages = nil)
    return if !msgs
    case msgs
    when Array
      f.write("[#{secname}]\r\n")
      msgs.length.times do |j|
        next if nil_or_empty?(msgs[j])
        value = Messages.normalizeValue(msgs[j])
        origValue = ""
        if origMessages
          origValue = Messages.normalizeValue(origMessages.get(secname, j))
        else
          origValue = Messages.normalizeValue(MessageTypes.get(secname, j))
        end
        f.write("#{j}\r\n")
        f.write(origValue + "\r\n")
        f.write(value + "\r\n")
      end
    when OrderedHash
      f.write("[#{secname}]\r\n")
      keys = msgs.keys
      keys.each do |key|
        next if nil_or_empty?(msgs[key])
        value = Messages.normalizeValue(msgs[key])
        valkey = Messages.normalizeValue(key)
        # key is already serialized
        f.write(valkey + "\r\n")
        f.write(value + "\r\n")
      end
    end
  end

  def messages
    return @messages || []
  end

  def extract(outfile)
#    return if !@messages
    origMessages = Messages.new("Data/messages.dat")
    File.open(outfile, "wb") { |f|
      f.write(0xef.chr)
      f.write(0xbb.chr)
      f.write(0xbf.chr)
      f.write("# To localize this text for a particular language, please\r\n")
      f.write("# translate every second line of this file.\r\n")
      if origMessages.messages[0]
        origMessages.messages[0].length.times do |i|
          msgs = origMessages.messages[0][i]
          Messages.writeObject(f, msgs, "Map#{i}", origMessages)
        end
      end
      (1...origMessages.messages.length).each do |i|
        msgs = origMessages.messages[i]
        Messages.writeObject(f, msgs, i, origMessages)
      end
    }
  end

  def setMessages(type, array)
    @messages = [] if !@messages
    arr = []
    array.length.times do |i|
      arr[i] = (array[i]) ? array[i] : ""
    end
    @messages[type] = arr
  end

  def addMessages(type, array)
    @messages = [] if !@messages
    arr = (@messages[type]) ? @messages[type] : []
    array.length.times do |i|
      arr[i] = (array[i]) ? array[i] : (arr[i]) ? arr[i] : ""
    end
    @messages[type] = arr
  end

  def self.createHash(_type, array)
    arr = OrderedHash.new
    array.length.times do |i|
      if array[i]
        key = Messages.stringToKey(array[i])
        arr[key] = array[i]
      end
    end
    return arr
  end

  def self.addToHash(_type, array, hash)
    hash = OrderedHash.new if !hash
    array.length.times do |i|
      if array[i]
        key = Messages.stringToKey(array[i])
        hash[key] = array[i]
      end
    end
    return hash
  end

  def setMapMessagesAsHash(type, array)
    @messages = [] if !@messages
    @messages[0] = [] if !@messages[0]
    @messages[0][type] = Messages.createHash(type, array)
  end

  def addMapMessagesAsHash(type, array)
    @messages = [] if !@messages
    @messages[0] = [] if !@messages[0]
    @messages[0][type] = Messages.addToHash(type, array, @messages[0][type])
  end

  def setMessagesAsHash(type, array)
    @messages = [] if !@messages
    @messages[type] = Messages.createHash(type, array)
  end

  def addMessagesAsHash(type, array)
    @messages = [] if !@messages
    @messages[type] = Messages.addToHash(type, array, @messages[type])
  end

  def saveMessages(filename = nil)
    filename = "Data/messages.dat" if !filename
    File.open(filename, "wb") { |f| Marshal.dump(@messages, f) }
  end

  def loadMessageFile(filename)
    begin
      pbRgssOpen(filename, "rb") { |f| @messages = Marshal.load(f) }
      if !@messages.is_a?(Array)
        @messages = nil
        raise "Corrupted data"
      end
      return @messages
    rescue
      @messages = nil
      return nil
    end
  end

  def set(type, id, value)
    delayedLoad
    return if !@messages
    return if !@messages[type]
    @messages[type][id] = value
  end

  def getCount(type)
    delayedLoad
    return 0 if !@messages
    return 0 if !@messages[type]
    return @messages[type].length
  end

  def get(type, id)
    delayedLoad
    return "" if !@messages
    return "" if !@messages[type]
    return "" if !@messages[type][id]
    return @messages[type][id]
  end

  def getFromHash(type, key)
    delayedLoad
    return key if !@messages || !@messages[type] || !key
    id = Messages.stringToKey(key)
    return key if !@messages[type][id]
    return @messages[type][id]
  end

  def getFromMapHash(type, key)
    delayedLoad
    return key if !@messages
    return key if !@messages[0]
    return key if !@messages[0][type] && !@messages[0][0]
    id = Messages.stringToKey(key)
    if @messages[0][type] && @messages[0][type][id]
      return @messages[0][type][id]
    elsif @messages[0][0] && @messages[0][0][id]
      return @messages[0][0][id]
    end
    return key
  end
end



module MessageTypes
  # Value 0 is used for common event and map event text
  Species            = 1
  Kinds              = 2
  Entries            = 3
  FormNames          = 4
  Moves              = 5
  MoveDescriptions   = 6
  Items              = 7
  ItemPlurals        = 8
  ItemDescriptions   = 9
  Abilities          = 10
  AbilityDescs       = 11
  Types              = 12
  TrainerTypes       = 13
  TrainerNames       = 14
  BeginSpeech        = 15
  EndSpeechWin       = 16
  EndSpeechLose      = 17
  RegionNames        = 18
  PlaceNames         = 19
  PlaceDescriptions  = 20
  MapNames           = 21
  PhoneMessages      = 22
  TrainerLoseText    = 23
  ScriptTexts        = 24
  RibbonNames        = 25
  RibbonDescriptions = 26
  StorageCreator     = 27
  @@messages         = Messages.new
  @@messagesFallback = Messages.new("Data/messages.dat", true)

  def self.stringToKey(str)
    return Messages.stringToKey(str)
  end

  def self.normalizeValue(value)
    return Messages.normalizeValue(value)
  end

  def self.denormalizeValue(value)
    Messages.denormalizeValue(value)
  end

  def self.writeObject(f, msgs, secname)
    Messages.denormalizeValue(str)
  end

  def self.extract(outfile)
    @@messages.extract(outfile)
  end

  def self.setMessages(type, array)
    @@messages.setMessages(type, array)
  end

  def self.addMessages(type, array)
    @@messages.addMessages(type, array)
  end

  def self.createHash(type, array)
    Messages.createHash(type, array)
  end

  def self.addMapMessagesAsHash(type, array)
    @@messages.addMapMessagesAsHash(type, array)
  end

  def self.setMapMessagesAsHash(type, array)
    @@messages.setMapMessagesAsHash(type, array)
  end

  def self.addMessagesAsHash(type, array)
    @@messages.addMessagesAsHash(type, array)
  end

  def self.setMessagesAsHash(type, array)
    @@messages.setMessagesAsHash(type, array)
  end

  def self.saveMessages(filename = nil)
    @@messages.saveMessages(filename)
  end

  def self.loadMessageFile(filename)
    @@messages.loadMessageFile(filename)
  end

  def self.get(type, id)
    ret = @@messages.get(type, id)
    if ret == ""
      ret = @@messagesFallback.get(type, id)
    end
    return ret
  end

  def self.getCount(type)
    c1 = @@messages.getCount(type)
    c2 = @@messagesFallback.getCount(type)
    return c1 > c2 ? c1 : c2
  end

  def self.getOriginal(type, id)
    return @@messagesFallback.get(type, id)
  end

  def self.getFromHash(type, key)
    @@messages.getFromHash(type, key)
  end

  def self.getFromMapHash(type, key)
    @@messages.getFromMapHash(type, key)
  end
end



def pbLoadMessages(file)
  return MessageTypes.loadMessageFile(file)
end

def pbGetMessageCount(type)
  return MessageTypes.getCount(type)
end

def pbGetMessage(type, id)
  return MessageTypes.get(type, id)
end

def pbGetMessageFromHash(type, id)
  return MessageTypes.getFromHash(type, id)
end

# Replaces first argument with a localized version and formats the other
# parameters by replacing {1}, {2}, etc. with those placeholders.
def _INTL(*arg)
  begin
    string = MessageTypes.getFromHash(MessageTypes::ScriptTexts, arg[0])
  rescue
    string = arg[0]
  end
  string = string.clone
  (1...arg.length).each do |i|
    string.gsub!(/\{#{i}\}/, arg[i].to_s)
  end
  return string
end

# Replaces first argument with a localized version and formats the other
# parameters by replacing {1}, {2}, etc. with those placeholders.
# This version acts more like sprintf, supports e.g. {1:d} or {2:s}
def _ISPRINTF(*arg)
  begin
    string = MessageTypes.getFromHash(MessageTypes::ScriptTexts, arg[0])
  rescue
    string = arg[0]
  end
  string = string.clone
  (1...arg.length).each do |i|
    string.gsub!(/\{#{i}\:([^\}]+?)\}/) { |m|
      next sprintf("%" + $1, arg[i])
    }
  end
  return string
end

def _I(str, *arg)
  return _MAPINTL($game_map.map_id, str, *arg)
end

def _MAPINTL(mapid, *arg)
  string = MessageTypes.getFromMapHash(mapid, arg[0])
  string = string.clone
  (1...arg.length).each do |i|
    string.gsub!(/\{#{i}\}/, arg[i].to_s)
  end
  return string
end

def _MAPISPRINTF(mapid, *arg)
  string = MessageTypes.getFromMapHash(mapid, arg[0])
  string = string.clone
  (1...arg.length).each do |i|
    string.gsub!(/\{#{i}\:([^\}]+?)\}/) { |m|
      next sprintf("%" + $1, arg[i])
    }
  end
  return string
end
