#===============================================================================
#
#===============================================================================
module Translator
  module_function

  def gather_script_and_event_texts
    Graphics.update
    begin
      t = System.uptime
      texts = []
      # Get script texts from Scripts.rxdata
      $RGSS_SCRIPTS.each do |script|
        if System.uptime - t >= 5
          t += 5
          Graphics.update
        end
        scr = Zlib::Inflate.inflate(script[2])
        find_translatable_text_from_RGSS_script(texts, scr)
      end
      # If Scripts.rxdata only has 1 section, scripts have been extracted. Get
      # script texts from .rb files in Data/Scripts
      if $RGSS_SCRIPTS.length == 1
        Dir.all("Data/Scripts").each do |script_file|
          if System.uptime - t >= 5
            t += 5
            Graphics.update
          end
          File.open(script_file, "rb") do |f|
            find_translatable_text_from_RGSS_script(texts, f.read)
          end
        end
      end
      # Get script texts from plugin script files
      if FileTest.exist?("Data/PluginScripts.rxdata")
        plugin_scripts = load_data("Data/PluginScripts.rxdata")
        plugin_scripts.each do |plugin|
          plugin[2].each do |script|
            if System.uptime - t >= 5
              t += 5
              Graphics.update
            end
            scr = Zlib::Inflate.inflate(script[1]).force_encoding(Encoding::UTF_8)
            find_translatable_text_from_RGSS_script(texts, scr)
          end
        end
      end
      MessageTypes.addMessagesAsHash(MessageTypes::SCRIPT_TEXTS, texts)
      # Find all text in common events and add them to messages
      commonevents = load_data("Data/CommonEvents.rxdata")
      items = []
      choices = []
      commonevents.compact.each do |event|
        if System.uptime - t >= 5
          t += 5
          Graphics.update
        end
        begin
          neednewline = false
          lastitem = ""
          event.list.size.times do |j|
            list = event.list[j]
            if neednewline && list.code != 401   # Continuation of 101 Show Text
              if lastitem != ""
                lastitem.gsub!(/([^\.\!\?])\s\s+/) { |m| $1 + " " }
                items.push(lastitem)
                lastitem = ""
              end
              neednewline = false
            end
            if list.code == 101   # Show Text
              lastitem += list.parameters[0].to_s
              neednewline = true
            elsif list.code == 102   # Show Choices
              list.parameters[0].length.times do |k|
                choices.push(list.parameters[0][k])
              end
              neednewline = false
            elsif list.code == 401   # Continuation of 101 Show Text
              lastitem += " " if lastitem != ""
              lastitem += list.parameters[0].to_s
              neednewline = true
            elsif list.code == 355 || list.code == 655   # Script or script continuation line
              find_translatable_text_from_event_script(items, list.parameters[0])
            elsif list.code == 111 && list.parameters[0] == 12   # Conditional Branch
              find_translatable_text_from_event_script(items, list.parameters[1])
            elsif list.code == 209   # Set Move Route
              route = list.parameters[1]
              route.list.size.times do |k|
                if route.list[k].code == PBMoveRoute::SCRIPT
                  find_translatable_text_from_event_script(items, route.list[k].parameters[0])
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
      if System.uptime - t >= 5
        t += 5
        Graphics.update
      end
      items |= []
      choices |= []
      items.concat(choices)
      MessageTypes.setMapMessagesAsHash(0, items)
      # Find all text in map events and add them to messages
      mapinfos = pbLoadMapInfos
      mapinfos.each_key do |id|
        if System.uptime - t >= 5
          t += 5
          Graphics.update
        end
        filename = sprintf("Data/Map%03d.rxdata", id)
        next if !pbRgssExists?(filename)
        map = load_data(filename)
        items = []
        choices = []
        map.events.each_value do |event|
          if System.uptime - t >= 5
            t += 5
            Graphics.update
          end
          begin
            event.pages.size.times do |i|
              neednewline = false
              lastitem = ""
              event.pages[i].list.size.times do |j|
                list = event.pages[i].list[j]
                if neednewline && list.code != 401   # Continuation of 101 Show Text
                  if lastitem != ""
                    lastitem.gsub!(/([^\.\!\?])\s\s+/) { |m| $1 + " " }
                    items.push(lastitem)
                    lastitem = ""
                  end
                  neednewline = false
                end
                if list.code == 101   # Show Text
                  lastitem += list.parameters[0].to_s
                  neednewline = true
                elsif list.code == 102   # Show Choices
                  list.parameters[0].length.times do |k|
                    choices.push(list.parameters[0][k])
                  end
                  neednewline = false
                elsif list.code == 401   # Continuation of 101 Show Text
                  lastitem += " " if lastitem != ""
                  lastitem += list.parameters[0].to_s
                  neednewline = true
                elsif list.code == 355 || list.code == 655   # Script or script continuation line
                  find_translatable_text_from_event_script(items, list.parameters[0])
                elsif list.code == 111 && list.parameters[0] == 12   # Conditional Branch
                  find_translatable_text_from_event_script(items, list.parameters[1])
                elsif list.code == 209   # Set Move Route
                  route = list.parameters[1]
                  route.list.size.times do |k|
                    if route.list[k].code == PBMoveRoute::SCRIPT
                      find_translatable_text_from_event_script(items, route.list[k].parameters[0])
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
        if System.uptime - t >= 5
          t += 5
          Graphics.update
        end
        items |= []
        choices |= []
        items.concat(choices)
        MessageTypes.setMapMessagesAsHash(id, items) if items.length > 0
        if System.uptime - t >= 5
          t += 5
          Graphics.update
        end
      end
    rescue Hangup
    end
    Graphics.update
  end

  def find_translatable_text_from_RGSS_script(items, script)
    script.force_encoding(Encoding::UTF_8)
    script.scan(/(?:_INTL|_ISPRINTF)\s*\(\s*\"((?:[^\\\"]*\\\"?)*[^\"]*)\"/) do |s|
      string = s[0]
      string.gsub!(/\\r/, "\r")
      string.gsub!(/\\n/, "\n")
      string.gsub!(/\\1/, "\1")
      string.gsub!(/\\\"/, "\"")
      string.gsub!(/\\\\/, "\\")
      items.push(string)
    end
  end

  def find_translatable_text_from_event_script(items, script)
    script.force_encoding(Encoding::UTF_8)
    script.scan(/(?:_I)\s*\(\s*\"((?:[^\\\"]*\\\"?)*[^\"]*)\"/) do |s|
      string = s[0]
      string.gsub!(/\\\"/, "\"")
      string.gsub!(/\\\\/, "\\")
      items.push(string)
    end
  end

  def normalize_value(value)
    if value[/[\r\n\t\x01]|^[\[\]]/]
      ret = value.dup
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

  def denormalize_value(value)
    if value[/<<[rnt1\[\]]>>/]
      ret = value.dup
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

  #-----------------------------------------------------------------------------

  def extract_text(language_name = "default", core_text = false, separate_map_files = false)
    dir_name = sprintf("Text_%s_%s", language_name, (core_text) ? "core" : "game")
    msg_window = pbCreateMessageWindow
    # Get text for extraction
    orig_messages = Translation.new(language_name)
    if core_text
      language_messages = orig_messages.core_messages
      default_messages = orig_messages.default_core_messages
      if !default_messages || default_messages.length == 0
        pbMessageDisplay(msg_window, _INTL("The default core messages file \"messages_core.dat\" was not found."))
        pbDisposeMessageWindow(msg_window)
        return
      end
    else
      language_messages = orig_messages.game_messages
      default_messages = orig_messages.default_game_messages
      if !default_messages || default_messages.length == 0
        pbMessageDisplay(msg_window, _INTL("The default game messages file \"messages_game.dat\" was not found."))
        pbDisposeMessageWindow(msg_window)
        return
      end
    end
    # Create folder for extracted text files, or delete existing text files from
    # existing destination folder
    if Dir.safe?(dir_name)
      has_files = false
      Dir.all(dir_name).each do |f|
        has_files = true
        break
      end
      if has_files && !pbConfirmMessageSerious(_INTL("Replace all text files in folder '{1}'?", dir_name))
        pbDisposeMessageWindow(msg_window)
        return
      end
      Dir.all(dir_name).each { |f| File.delete(f) }
    else
      Dir.create(dir_name)
    end
    # Create a lambda function that helps to write text files
    write_header = lambda do |f, with_line|
      f.write(0xEF.chr)
      f.write(0xBB.chr)
      f.write(0xBF.chr)
      f.write("# To localize this text for a particular language, please" + "\r\n")
      f.write("# translate every second line of this file." + "\r\n")
      f.write("\#-------------------------------\r\n") if with_line
    end
    # Extract the text
    pbMessageDisplay(msg_window, "\\ts[]" + _INTL("Extracting text, please wait.") + "\\wtnp[0]")
    # Get all the section IDs to cycle through
    max_section_id = default_messages.length
    max_section_id = language_messages.length if language_messages && language_messages.length > max_section_id
    max_section_id.times do |i|
      section_name = getConstantName(MessageTypes, i, false)
      next if !section_name
      if i == MessageTypes::EVENT_TEXTS
        if separate_map_files
          map_infos = pbLoadMapInfos
          default_messages[i].each_with_index do |map_msgs, map_id|
            next if !map_msgs || map_msgs.length == 0
            filename = sprintf("Map%03d", map_id)
            filename += " " + map_infos[map_id].name if map_infos[map_id]
            File.open(dir_name + "/" + filename + ".txt", "wb") do |f|
              write_header.call(f, true)
              translated_msgs = language_messages[i][map_id] if language_messages && language_messages[i]
              write_section_texts_to_file(f, sprintf("Map%03d", map_id), translated_msgs, map_msgs)
            end
          end
        else
          next if !default_messages[i] || default_messages[i].length == 0
          no_difference = true
          default_messages[i].each do |map_msgs|
            no_difference = false if map_msgs && map_msgs.length > 0
            break if !map_msgs
          end
          next if no_difference
          File.open(dir_name + "/" + section_name + ".txt", "wb") do |f|
            write_header.call(f, false)
            default_messages[i].each_with_index do |map_msgs, map_id|
              next if !map_msgs || map_msgs.length == 0
              f.write("\#-------------------------------\r\n")
              translated_msgs = (language_messages && language_messages[i]) ? language_messages[i][map_id] : nil
              write_section_texts_to_file(f, sprintf("Map%03d", map_id), translated_msgs, map_msgs)
            end
          end
        end
      else   # MessageTypes sections
        next if !default_messages[i] || default_messages[i].length == 0
        File.open(dir_name + "/" + section_name + ".txt", "wb") do |f|
          write_header.call(f, true)
          translated_msgs = (language_messages) ? language_messages[i] : nil
          write_section_texts_to_file(f, section_name, translated_msgs, default_messages[i])
        end
      end
    end
    msg_window.textspeed = MessageConfig.pbSettingToTextSpeed($PokemonSystem.textspeed)
    if core_text
      pbMessageDisplay(msg_window, _INTL("All core text was extracted to files in the folder \"{1}\".", dir_name) + "\1")
    else
      pbMessageDisplay(msg_window, _INTL("All game text was extracted to files in the folder \"{1}\".", dir_name) + "\1")
    end
    pbMessageDisplay(msg_window, _INTL("To localize this text, translate every second line in those files.") + "\1")
    pbMessageDisplay(msg_window, _INTL("After translating, choose \"Compile Translated Text\" in the Debug menu."))
    pbDisposeMessageWindow(msg_window)
  end

  def write_section_texts_to_file(f, section_name, language_msgs, original_msgs = nil)
    return if !original_msgs
    case original_msgs
    when Array
      f.write("[#{section_name}]\r\n")
      original_msgs.length.times do |j|
        next if nil_or_empty?(original_msgs[j])
        f.write("#{j}\r\n")
        f.write(normalize_value(original_msgs[j]) + "\r\n")
        text = (language_msgs && language_msgs[j]) ? language_msgs[j] : original_msgs[j]
        f.write(normalize_value(text) + "\r\n")
      end
    when Hash
      f.write("[#{section_name}]\r\n")
      keys = original_msgs.keys
      keys.each do |key|
        next if nil_or_empty?(original_msgs[key])
        f.write(normalize_value(key) + "\r\n")
        text = (language_msgs && language_msgs[key]) ? language_msgs[key] : original_msgs[key]
        f.write(normalize_value(text) + "\r\n")
      end
    end
  end

  #-----------------------------------------------------------------------------

  def compile_text(dir_name, dat_filename)
    msg_window = pbCreateMessageWindow
    pbMessageDisplay(msg_window, "\\ts[]" + _INTL("Compiling text, please wait.") + "\\wtnp[0]")
    outfile = File.open("Data/messages_" + dat_filename + ".dat", "wb")
    all_text = []
    begin
      text_files = Dir.get("Text_" + dir_name, "*.txt")
      text_files.each { |file| compile_text_from_file(file, all_text) }
      Marshal.dump(all_text, outfile)
    rescue
      raise
    ensure
      outfile.close
    end
    msg_window.textspeed = MessageConfig.pbSettingToTextSpeed($PokemonSystem.textspeed)
    pbMessageDisplay(msg_window,
       _INTL("Text files in the folder \"Text_{1}\" were successfully compiled into file \"Data/messages_{2}.dat\".", dir_name, dat_filename))
    pbMessageDisplay(msg_window, _INTL("You may need to close the game to see any changes to messages."))
    pbDisposeMessageWindow(msg_window)
  end

  def compile_text_from_file(text_file, all_text)
    begin
      file = File.open(text_file, "rb")
    rescue
      raise _INTL("Can't find or open '{1}'.", text_file)
    end
    begin
      Compiler.pbEachSection(file) do |contents, section_name|
        next if contents.length == 0
        # Get the section number and whether the section contains a map's event text
        section_id = -1
        is_map = false
        if section_name.to_i != 0   # Section name is a number
          section_id = section_name.to_i
        elsif hasConst?(MessageTypes, section_name)   # Section name is a constant from MessageTypes
          section_id = getConst(MessageTypes, section_name)
        elsif section_name[/^Map(\d+)$/i]   # Section name is a map number (event text)
          is_map = true
          section_id = $~[1].to_i
        end
        raise _INTL("Invalid section name {1}", section_name) if section_id < 0
        # Decide whether the section contains text stored in an ordered list (an
        # array) or an ordered hash
        item_length = 0
        if contents[0][/^\d+$/]   # If first line is a number, text is stored in an array
          text_hash = []
          item_length = 3
          if is_map
            raise _INTL("Section {1} can't be an ordered list (section was recognized as an ordered list because its first line is a number).", section_name)
          end
          if contents.length % 3 != 0
            raise _INTL("Section {1}'s line count is not divisible by 3 (section was recognized as an ordered list because its first line is a number).", section_name)
          end
        else   # Text is stored in a hash
          text_hash = {}
          item_length = 2
          if contents.length.odd?
            raise _INTL("Section {1} has an odd number of entries (section was recognized as a hash because its first line is not a number).", section_name)
          end
        end
        # Add text in section to ordered list/hash
        i = 0
        loop do
          if item_length == 3
            if !contents[i][/^\d+$/]
              raise _INTL("Expected a number in section {1}, got {2} instead", section_name, contents[i])
            end
            key = contents[i].to_i
            i += 1
          else
            key = denormalize_value(contents[i])
            key = Translation.stringToKey(key)
          end
          text_hash[key] = denormalize_value(contents[i + 1])
          i += 2
          break if i >= contents.length
        end
        # Add ordered list/hash (text_hash) to array of all text (all_text)
        all_text[MessageTypes::EVENT_TEXTS] = [] if is_map && !all_text[MessageTypes::EVENT_TEXTS]
        target_section = (is_map) ? all_text[MessageTypes::EVENT_TEXTS][section_id] : all_text[section_id]
        if target_section
          if text_hash.is_a?(Hash)
            text_hash.each_key { |key| target_section[key] = text_hash[key] if text_hash[key] }
          else   # text_hash is an array
            text_hash.each_with_index { |line, j| target_section[j] = line if line }
          end
        elsif is_map
          all_text[MessageTypes::EVENT_TEXTS][section_id] = text_hash
        else
          all_text[section_id] = text_hash
        end
      end
    ensure
      file.close
    end
  end
end

#===============================================================================
#
#===============================================================================
class Translation
  attr_reader :core_messages, :game_messages

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

  def initialize(filename = nil, delay_load = false)
    @default_core_messages = nil
    @default_game_messages = nil
    @core_messages = nil   # A translation file
    @game_messages = nil   # A translation file
    @filename = filename
    load_message_files(@filename) if @filename && !delay_load
  end

  def default_core_messages
    load_default_messages
    return @default_core_messages
  end

  def default_game_messages
    load_default_messages
    return @default_game_messages
  end

  def load_message_files(filename)
    begin
      core_filename = sprintf("Data/messages_%s_core.dat", filename)
      if FileTest.exist?(core_filename)
        pbRgssOpen(core_filename, "rb") { |f| @core_messages = Marshal.load(f) }
      end
      @core_messages = nil if !@core_messages.is_a?(Array)
      game_filename = sprintf("Data/messages_%s_game.dat", filename)
      if FileTest.exist?(game_filename)
        pbRgssOpen(game_filename, "rb") { |f| @game_messages = Marshal.load(f) }
      end
      @game_messages = nil if !@game_messages.is_a?(Array)
    rescue
      @core_messages = nil
      @game_messages = nil
    end
  end

  def load_default_messages
    return if @default_core_messages
    begin
      if FileTest.exist?("Data/messages_core.dat")
        pbRgssOpen("Data/messages_core.dat", "rb") { |f| @default_core_messages = Marshal.load(f) }
      end
      @default_core_messages = [] if !@default_core_messages.is_a?(Array)
      if FileTest.exist?("Data/messages_game.dat")
        pbRgssOpen("Data/messages_game.dat", "rb") { |f| @default_game_messages = Marshal.load(f) }
      end
      @default_game_messages = [] if !@default_game_messages.is_a?(Array)
    rescue
      @default_core_messages = []
      @default_game_messages = []
    end
  end

  def save_default_messages
    File.open("Data/messages_core.dat", "wb") { |f| Marshal.dump(@default_core_messages, f) }
    File.open("Data/messages_game.dat", "wb") { |f| Marshal.dump(@default_game_messages, f) }
  end

  def setMessages(type, array)
    load_default_messages
    @default_game_messages[type] = priv_add_to_array(type, array, nil)
  end

  def addMessages(type, array)
    load_default_messages
    @default_game_messages[type] = priv_add_to_array(type, array, @default_game_messages[type])
  end

  def setMessagesAsHash(type, array)
    load_default_messages
    @default_game_messages[type] = priv_add_to_hash(type, array, nil)
  end

  def addMessagesAsHash(type, array)
    load_default_messages
    @default_game_messages[type] = priv_add_to_hash(type, array, @default_game_messages[type])
  end

  def setMapMessagesAsHash(map_id, array)
    load_default_messages
    @default_game_messages[MessageTypes::EVENT_TEXTS] ||= []
    @default_game_messages[MessageTypes::EVENT_TEXTS][map_id] = priv_add_to_hash(
      MessageTypes::EVENT_TEXTS, array, nil, map_id
    )
  end

  def addMapMessagesAsHash(map_id, array)
    load_default_messages
    @default_game_messages[MessageTypes::EVENT_TEXTS] ||= []
    @default_game_messages[MessageTypes::EVENT_TEXTS][map_id] = priv_add_to_hash(
      MessageTypes::EVENT_TEXTS, array, @default_game_messages[MessageTypes::EVENT_TEXTS][map_id], map_id
    )
  end

  def get(type, id)
    delayed_load_message_files
    if @game_messages && @game_messages[type] && @game_messages[type][id]
      return @game_messages[type][id]
    end
    if @core_messages && @core_messages[type] && @core_messages[type][id]
      return @core_messages[type][id]
    end
    return ""
  end

  def getFromHash(type, text)
    delayed_load_message_files
    key = Translation.stringToKey(text)
    return text if nil_or_empty?(key)
    if @game_messages && @game_messages[type] && @game_messages[type][key]
      return @game_messages[type][key]
    end
    if @core_messages && @core_messages[type] && @core_messages[type][key]
      return @core_messages[type][key]
    end
    return text
  end

  def getFromMapHash(map_id, text)
    delayed_load_message_files
    key = Translation.stringToKey(text)
    return text if nil_or_empty?(key)
    if @game_messages && @game_messages[MessageTypes::EVENT_TEXTS]
      if @game_messages[MessageTypes::EVENT_TEXTS][map_id] && @game_messages[MessageTypes::EVENT_TEXTS][map_id][key]
        return @game_messages[MessageTypes::EVENT_TEXTS][map_id][key]
      elsif @game_messages[MessageTypes::EVENT_TEXTS][0] && @game_messages[MessageTypes::EVENT_TEXTS][0][key]
        return @game_messages[MessageTypes::EVENT_TEXTS][0][key]
      end
    end
    if @core_messages && @core_messages[MessageTypes::EVENT_TEXTS]
      if @core_messages[MessageTypes::EVENT_TEXTS][map_id] && @core_messages[MessageTypes::EVENT_TEXTS][map_id][key]
        return @core_messages[MessageTypes::EVENT_TEXTS][map_id][key]
      elsif @core_messages[MessageTypes::EVENT_TEXTS][0] && @core_messages[MessageTypes::EVENT_TEXTS][0][key]
        return @core_messages[MessageTypes::EVENT_TEXTS][0][key]
      end
    end
    return text
  end

  #-----------------------------------------------------------------------------

  private

  def delayed_load_message_files
    return if !@filename || @core_messages
    load_message_files(@filename)
    @filename = nil
  end

  def priv_add_to_array(type, array, ret)
    @default_core_messages[type] ||= []
    ret = [] if !ret
    array.each_with_index do |text, i|
      ret[i] = text if !nil_or_empty?(text) && @default_core_messages[type][i] != text
    end
    return ret
  end

  def priv_add_to_hash(type, array, ret, map_id = 0)
    if type == MessageTypes::EVENT_TEXTS
      @default_core_messages[type] ||= []
      @default_core_messages[type][map_id] ||= {}
      default_keys = @default_core_messages[type][map_id].keys
    else
      @default_core_messages[type] ||= {}
      default_keys = @default_core_messages[type].keys
    end
    ret = {} if !ret
    array.each do |text|
      next if !text
      key = Translation.stringToKey(text)
      ret[key] = text if !default_keys.include?(key)
    end
    return ret
  end
end

#===============================================================================
#
#===============================================================================
module MessageTypes
  # NOTE: These constants aren't numbered in any particular order, but these
  #       numbers are retained for backwards compatibility with older extracted
  #       text files.
  EVENT_TEXTS                  = 0   # Used for text in both common events and map events
  SPECIES_NAMES                = 1
  SPECIES_CATEGORIES           = 2
  POKEDEX_ENTRIES              = 3
  SPECIES_FORM_NAMES           = 4
  MOVE_NAMES                   = 5
  MOVE_DESCRIPTIONS            = 6
  ITEM_NAMES                   = 7
  ITEM_NAME_PLURALS            = 8
  ITEM_DESCRIPTIONS            = 9
  ABILITY_NAMES                = 10
  ABILITY_DESCRIPTIONS         = 11
  TYPE_NAMES                   = 12
  TRAINER_TYPE_NAMES           = 13
  TRAINER_NAMES                = 14
  FRONTIER_INTRO_SPEECHES      = 15
  FRONTIER_END_SPEECHES_WIN    = 16
  FRONTIER_END_SPEECHES_LOSE   = 17
  REGION_NAMES                 = 18
  REGION_LOCATION_NAMES        = 19
  REGION_LOCATION_DESCRIPTIONS = 20
  MAP_NAMES                    = 21
  PHONE_MESSAGES               = 22
  TRAINER_SPEECHES_LOSE        = 23
  SCRIPT_TEXTS                 = 24
  RIBBON_NAMES                 = 25
  RIBBON_DESCRIPTIONS          = 26
  STORAGE_CREATOR_NAME         = 27
  ITEM_PORTION_NAMES           = 28
  ITEM_PORTION_NAME_PLURALS    = 29
  POKEMON_NICKNAMES            = 30
  @@messages = Translation.new

  def self.load_default_messages
    @@messages.load_default_messages
  end

  def self.load_message_files(filename)
    @@messages.load_message_files(filename)
  end

  def self.save_default_messages
    @@messages.save_default_messages
  end

  def self.setMessages(type, array)
    @@messages.setMessages(type, array)
  end

  def self.addMessages(type, array)
    @@messages.addMessages(type, array)
  end

  def self.setMessagesAsHash(type, array)
    @@messages.setMessagesAsHash(type, array)
  end

  def self.addMessagesAsHash(type, array)
    @@messages.addMessagesAsHash(type, array)
  end

  def self.setMapMessagesAsHash(type, array)
    @@messages.setMapMessagesAsHash(type, array)
  end

  def self.addMapMessagesAsHash(type, array)
    @@messages.addMapMessagesAsHash(type, array)
  end

  def self.get(type, id)
    return @@messages.get(type, id)
  end

  def self.getFromHash(type, key)
    return @@messages.getFromHash(type, key)
  end

  def self.getFromMapHash(type, key)
    return @@messages.getFromMapHash(type, key)
  end
end

#===============================================================================
#
#===============================================================================
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
    string = MessageTypes.getFromHash(MessageTypes::SCRIPT_TEXTS, arg[0])
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
    string = MessageTypes.getFromHash(MessageTypes::SCRIPT_TEXTS, arg[0])
  rescue
    string = arg[0]
  end
  string = string.clone
  (1...arg.length).each do |i|
    string.gsub!(/\{#{i}\:([^\}]+?)\}/) { |m| next sprintf("%" + $1, arg[i]) }
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
    string.gsub!(/\{#{i}\:([^\}]+?)\}/) { |m| next sprintf("%" + $1, arg[i]) }
  end
  return string
end
