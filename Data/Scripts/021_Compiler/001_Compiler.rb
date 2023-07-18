#===============================================================================
# Records which file, section and line are currently being read
#===============================================================================
module FileLineData
  @file     = ""
  @linedata = ""
  @lineno   = 0
  @section  = nil
  @key      = nil
  @value    = nil

  def self.file; return @file; end
  def self.file=(value); @file = value; end

  def self.clear
    @file     = ""
    @linedata = ""
    @lineno   = ""
    @section  = nil
    @key      = nil
    @value    = nil
  end

  def self.setSection(section, key, value)
    @section = section
    @key     = key
    if value && value.length > 200
      @value = value[0, 200].to_s + "..."
    else
      @value = (value) ? value.clone : ""
    end
  end

  def self.setLine(line, lineno)
    @section  = nil
    @linedata = (line && line.length > 200) ? sprintf("%s...", line[0, 200]) : line.clone
    @lineno   = lineno
  end

  def self.linereport
    if @section
      if @key.nil?
        return _INTL("File {1}, section {2}\n{3}", @file, @section, @value) + "\n\n"
      else
        return _INTL("File {1}, section {2}, key {3}\n{4}", @file, @section, @key, @value) + "\n\n"
      end
    else
      return _INTL("File {1}, line {2}\n{3}", @file, @lineno, @linedata) + "\n\n"
    end
  end
end

#===============================================================================
# Compiler
#===============================================================================
module Compiler
  module_function

  def findIndex(a)
    index = -1
    count = 0
    a.each do |i|
      if yield i
        index = count
        break
      end
      count += 1
    end
    return index
  end

  def prepline(line)
    line.sub!(/\s*\#.*$/, "")
    line.sub!(/^\s+/, "")
    line.sub!(/\s+$/, "")
    return line
  end

  def csvQuote(str, always = false)
    return "" if nil_or_empty?(str)
    if always || str[/[,\"]/]   # || str[/^\s/] || str[/\s$/] || str[/^#/]
      str = str.gsub(/\"/, "\\\"")
      str = "\"#{str}\""
    end
    return str
  end

  def csvQuoteAlways(str)
    return csvQuote(str, true)
  end

  #=============================================================================
  # PBS file readers
  #=============================================================================
  def pbEachFileSectionEx(f, schema = nil)
    lineno      = 1
    havesection = false
    sectionname = nil
    lastsection = {}
    f.each_line do |line|
      if lineno == 1 && line[0].ord == 0xEF && line[1].ord == 0xBB && line[2].ord == 0xBF
        line = line[3, line.length - 3]
      end
      line.force_encoding(Encoding::UTF_8)
      if !line[/^\#/] && !line[/^\s*$/]
        line = prepline(line)
        if line[/^\s*\[\s*(.*)\s*\]\s*$/]   # Of the format: [something]
          yield lastsection, sectionname if havesection
          sectionname = $~[1]
          havesection = true
          lastsection = {}
        else
          if sectionname.nil?
            FileLineData.setLine(line, lineno)
            raise _INTL("Expected a section at the beginning of the file. This error may also occur if the file was not saved in UTF-8.\n{1}", FileLineData.linereport)
          end
          if !line[/^\s*(\w+)\s*=\s*(.*)$/]
            FileLineData.setSection(sectionname, nil, line)
            raise _INTL("Bad line syntax (expected syntax like XXX=YYY)\n{1}", FileLineData.linereport)
          end
          r1 = $~[1]
          r2 = $~[2]
          if schema && schema[r1] && schema[r1][1][0] == "^"
            lastsection[r1] ||= []
            lastsection[r1].push(r2.gsub(/\s+$/, ""))
          else
            lastsection[r1] = r2.gsub(/\s+$/, "")
          end
        end
      end
      lineno += 1
      Graphics.update if lineno % 1000 == 0
    end
    yield lastsection, sectionname if havesection
  end

  # Used for types.txt, abilities.txt, moves.txt, items.txt, berry_plants.txt,
  # pokemon.txt, pokemon_forms.txt, pokemon_metrics.txt, shadow_pokemon.txt,
  # ribbons.txt, trainer_types.txt, battle_facility_lists.txt, Battle Tower
  # trainers PBS files and dungeon_parameters.txt
  def pbEachFileSection(f, schema = nil)
    pbEachFileSectionEx(f, schema) do |section, name|
      yield section, name if block_given? && name[/^.+$/]
    end
  end

  # Used for metadata.txt and map_metadata.txt
  def pbEachFileSectionNumbered(f, schema = nil)
    pbEachFileSectionEx(f, schema) do |section, name|
      yield section, name.to_i if block_given? && name[/^\d+$/]
    end
  end

  # Used by translated text compiler
  def pbEachSection(f)
    lineno      = 1
    havesection = false
    sectionname = nil
    lastsection = []
    f.each_line do |line|
      if lineno == 1 && line[0].ord == 0xEF && line[1].ord == 0xBB && line[2].ord == 0xBF
        line = line[3, line.length - 3]
      end
      line.force_encoding(Encoding::UTF_8)
      if !line[/^\#/] && !line[/^\s*$/]
        if line[/^\s*\[\s*(.+?)\s*\]\s*$/]
          yield lastsection, sectionname if havesection
          lastsection.clear
          sectionname = $~[1]
          havesection = true
        else
          if sectionname.nil?
            raise _INTL("Expected a section at the beginning of the file (line {1}). Sections begin with '[name of section]'.", lineno)
          end
          lastsection.push(line.strip)
        end
      end
      lineno += 1
      Graphics.update if lineno % 500 == 0
    end
    yield lastsection, sectionname if havesection
  end

  # Unused
  def pbEachCommentedLine(f)
    lineno = 1
    f.each_line do |line|
      if lineno == 1 && line[0].ord == 0xEF && line[1].ord == 0xBB && line[2].ord == 0xBF
        line = line[3, line.length - 3]
      end
      line.force_encoding(Encoding::UTF_8)
      yield line, lineno if !line[/^\#/] && !line[/^\s*$/]
      lineno += 1
    end
  end

  # Used for town_map.txt and Battle Tower Pokémon PBS files
  def pbCompilerEachCommentedLine(filename)
    File.open(filename, "rb") do |f|
      FileLineData.file = filename
      lineno = 1
      f.each_line do |line|
        if lineno == 1 && line[0].ord == 0xEF && line[1].ord == 0xBB && line[2].ord == 0xBF
          line = line[3, line.length - 3]
        end
        line.force_encoding(Encoding::UTF_8)
        if !line[/^\#/] && !line[/^\s*$/]
          FileLineData.setLine(line, lineno)
          yield line, lineno
        end
        lineno += 1
      end
    end
  end

  # Unused
  def pbEachPreppedLine(f)
    lineno = 1
    f.each_line do |line|
      if lineno == 1 && line[0].ord == 0xEF && line[1].ord == 0xBB && line[2].ord == 0xBF
        line = line[3, line.length - 3]
      end
      line.force_encoding(Encoding::UTF_8)
      line = prepline(line)
      yield line, lineno if !line[/^\#/] && !line[/^\s*$/]
      lineno += 1
    end
  end

  # Used for map_connections.txt, phone.txt, regional_dexes.txt, encounters.txt,
  # trainers.txt and dungeon_tilesets.txt
  def pbCompilerEachPreppedLine(filename)
    File.open(filename, "rb") do |f|
      FileLineData.file = filename
      lineno = 1
      f.each_line do |line|
        if lineno == 1 && line[0].ord == 0xEF && line[1].ord == 0xBB && line[2].ord == 0xBF
          line = line[3, line.length - 3]
        end
        line.force_encoding(Encoding::UTF_8)
        line = prepline(line)
        if !line[/^\#/] && !line[/^\s*$/]
          FileLineData.setLine(line, lineno)
          yield line, lineno
        end
        lineno += 1
      end
    end
  end

  #=============================================================================
  # Splits a string containing comma-separated values into an array of those
  # values.
  #=============================================================================
  def split_csv_line(string)
    # Split the string into an array of values, using a comma as the separator
    values = string.split(",")
    # Check for quote marks in each value, as we may need to recombine some values
    # to make proper results
    (0...values.length).each do |i|
      value = values[i]
      next if !value || value.empty?
      quote_count = value.count('"')
      if quote_count != 0
        # Quote marks found in value
        (i...(values.length - 1)).each do |j|
          quote_count = values[i].count('"')
          if quote_count == 2 && value.start_with?('\\"') && values[i].end_with?('\\"')
            # Two quote marks around the whole value; remove them
            values[i] = values[i][2..-3]
            break
          elsif quote_count.even?
            break
          end
          # Odd number of quote marks in value; concatenate the next value to it and
          # see if that's any better
          values[i] += "," + values[j + 1]
          values[j + 1] = nil
        end
        # Recheck for enclosing quote marks to remove
        if quote_count != 2
          if value.count('"') == 2 && value.start_with?('\\"') && value.end_with?('\\"')
            values[i] = values[i][2..-3]
          end
        end
      end
      # Remove leading and trailing whitespace from value
      values[i].strip!
    end
    # Remove nil values caused by concatenating values above
    values.compact!
    return values
  end

  #=============================================================================
  # Convert a string to certain kinds of values
  #=============================================================================
  # Unused
  # NOTE: This method is about 10 times slower than split_csv_line.
  def csvfield!(str)
    ret = ""
    str.sub!(/^\s*/, "")
    if str[0, 1] == "\""
      str[0, 1] = ""
      escaped = false
      fieldbytes = 0
      str.scan(/./) do |s|
        fieldbytes += s.length
        break if s == "\"" && !escaped
        if s == "\\" && !escaped
          escaped = true
        else
          ret += s
          escaped = false
        end
      end
      str[0, fieldbytes] = ""
      if !str[/^\s*,/] && !str[/^\s*$/]
        raise _INTL("Invalid quoted field (in: {1})\n{2}", str, FileLineData.linereport)
      end
      str[0, str.length] = $~.post_match
    else
      if str[/,/]
        str[0, str.length] = $~.post_match
        ret = $~.pre_match
      else
        ret = str.clone
        str[0, str.length] = ""
      end
      ret.gsub!(/\s+$/, "")
    end
    return ret
  end

  # Unused
  def csvBoolean!(str, _line = -1)
    field = csvfield!(str)
    return true if field[/^(?:1|TRUE|YES|Y)$/i]
    return false if field[/^(?:0|FALSE|NO|N)$/i]
    raise _INTL("Field {1} is not a Boolean value (true, false, 1, 0)\n{2}", field, FileLineData.linereport)
  end

  # Unused
  def csvInt!(str, _line = -1)
    ret = csvfield!(str)
    if !ret[/^\-?\d+$/]
      raise _INTL("Field {1} is not an integer\n{2}", ret, FileLineData.linereport)
    end
    return ret.to_i
  end

  # Unused
  def csvPosInt!(str, _line = -1)
    ret = csvfield!(str)
    if !ret[/^\d+$/]
      raise _INTL("Field {1} is not a positive integer\n{2}", ret, FileLineData.linereport)
    end
    return ret.to_i
  end

  # Unused
  def csvFloat!(str, _line = -1)
    ret = csvfield!(str)
    return Float(ret) rescue raise _INTL("Field {1} is not a number\n{2}", ret, FileLineData.linereport)
  end

  # Unused
  def csvEnumField!(value, enumer, _key, _section)
    ret = csvfield!(value)
    return checkEnumField(ret, enumer)
  end

  # Unused
  def csvEnumFieldOrInt!(value, enumer, _key, _section)
    ret = csvfield!(value)
    return ret.to_i if ret[/\-?\d+/]
    return checkEnumField(ret, enumer)
  end

  # Turns a value (a string) into another data type as determined by the given
  # schema.
  # @param value [String]
  # @param schema [String]
  def cast_csv_value(value, schema, enumer = nil)
    case schema.downcase
    when "i"   # Integer
      if !value[/^\-?\d+$/]
        raise _INTL("Field {1} is not an integer\n{2}", value, FileLineData.linereport)
      end
      return value.to_i
    when "u"   # Positive integer or zero
      if !value[/^\d+$/]
        raise _INTL("Field {1} is not a positive integer or 0\n{2}", value, FileLineData.linereport)
      end
      return value.to_i
    when "v"   # Positive integer
      if !value[/^\d+$/]
        raise _INTL("Field {1} is not a positive integer\n{2}", value, FileLineData.linereport)
      end
      if value.to_i == 0
        raise _INTL("Field '{1}' must be greater than 0\n{2}", value, FileLineData.linereport)
      end
      return value.to_i
    when "x"   # Hexadecimal number
      if !value[/^[A-F0-9]+$/i]
        raise _INTL("Field '{1}' is not a hexadecimal number\n{2}", value, FileLineData.linereport)
      end
      return value.hex
    when "f"   # Floating point number
      if !value[/^\-?^\d*\.?\d*$/]
        raise _INTL("Field {1} is not a number\n{2}", value, FileLineData.linereport)
      end
      return value.to_f
    when "b"   # Boolean
      return true if value[/^(?:1|TRUE|YES|Y)$/i]
      return false if value[/^(?:0|FALSE|NO|N)$/i]
      raise _INTL("Field {1} is not a Boolean value (true, false, 1, 0)\n{2}", value, FileLineData.linereport)
    when "n"   # Name
      if !value[/^(?![0-9])\w+$/]
        raise _INTL("Field '{1}' must contain only letters, digits, and\nunderscores and can't begin with a number.\n{2}", value, FileLineData.linereport)
      end
    when "s"   # String
    when "q"   # Unformatted text
    when "m"   # Symbol
      if !value[/^(?![0-9])\w+$/]
        raise _INTL("Field '{1}' must contain only letters, digits, and\nunderscores and can't begin with a number.\n{2}", value, FileLineData.linereport)
      end
      return value.to_sym
    when "e"   # Enumerable
      return checkEnumField(value, enumer)
    when "y"   # Enumerable or integer
      return value.to_i if value[/^\-?\d+$/]
      return checkEnumField(value, enumer)
    end
    return value
  end

  def checkEnumField(ret, enumer)
    case enumer
    when Module
      begin
        if nil_or_empty?(ret) || !enumer.const_defined?(ret)
          raise _INTL("Undefined value {1} in {2}\n{3}", ret, enumer.name, FileLineData.linereport)
        end
      rescue NameError
        raise _INTL("Incorrect value {1} in {2}\n{3}", ret, enumer.name, FileLineData.linereport)
      end
      return enumer.const_get(ret.to_sym)
    when Symbol, String
      if !Kernel.const_defined?(enumer.to_sym) && GameData.const_defined?(enumer.to_sym)
        enumer = GameData.const_get(enumer.to_sym)
        begin
          if nil_or_empty?(ret) || !enumer.exists?(ret.to_sym)
            raise _INTL("Undefined value {1} in {2}\n{3}", ret, enumer.name, FileLineData.linereport)
          end
        rescue NameError
          raise _INTL("Incorrect value {1} in {2}\n{3}", ret, enumer.name, FileLineData.linereport)
        end
        return ret.to_sym
      end
      enumer = Object.const_get(enumer.to_sym)
      begin
        if nil_or_empty?(ret) || !enumer.const_defined?(ret)
          raise _INTL("Undefined value {1} in {2}\n{3}", ret, enumer.name, FileLineData.linereport)
        end
      rescue NameError
        raise _INTL("Incorrect value {1} in {2}\n{3}", ret, enumer.name, FileLineData.linereport)
      end
      return enumer.const_get(ret.to_sym)
    when Array
      idx = findIndex(enumer) { |item| ret == item }
      if idx < 0
        raise _INTL("Undefined value {1} (expected one of: {2})\n{3}", ret, enumer.inspect, FileLineData.linereport)
      end
      return idx
    when Hash
      value = enumer[ret]
      if value.nil?
        raise _INTL("Undefined value {1} (expected one of: {2})\n{3}", ret, enumer.keys.inspect, FileLineData.linereport)
      end
      return value
    end
    raise _INTL("Enumeration not defined\n{1}", FileLineData.linereport)
  end

  # Unused
  def checkEnumFieldOrNil(ret, enumer)
    case enumer
    when Module
      return nil if nil_or_empty?(ret) || !(enumer.const_defined?(ret) rescue false)
      return enumer.const_get(ret.to_sym)
    when Symbol, String
      if GameData.const_defined?(enumer.to_sym)
        enumer = GameData.const_get(enumer.to_sym)
        return nil if nil_or_empty?(ret) || !enumer.exists?(ret.to_sym)
        return ret.to_sym
      end
      enumer = Object.const_get(enumer.to_sym)
      return nil if nil_or_empty?(ret) || !(enumer.const_defined?(ret) rescue false)
      return enumer.const_get(ret.to_sym)
    when Array
      idx = findIndex(enumer) { |item| ret == item }
      return nil if idx < 0
      return idx
    when Hash
      return enumer[ret]
    end
    return nil
  end

  #=============================================================================
  # Convert a string to values using a schema
  #=============================================================================
  # Unused
  # @deprecated This method is slated to be removed in v22.
  def pbGetCsvRecord(rec, lineno, schema)
    Deprecation.warn_method("pbGetCsvRecord", "v22", "get_csv_record")
    record = []
    repeat = false
    schema_length = schema[1].length
    start = 0
    case schema[1][0, 1]
    when "*"
      repeat = true
      start = 1
    when "^"
      start = 1
      schema_length -= 1
    end
    subarrays = repeat && schema[1].length > 2
    loop do
      subrecord = []
      (start...schema[1].length).each do |i|
        chr = schema[1][i, 1]
        case chr
        when "i"   # Integer
          subrecord.push(csvInt!(rec, lineno))
        when "I"   # Optional integer
          field = csvfield!(rec)
          if nil_or_empty?(field)
            subrecord.push(nil)
          elsif !field[/^\-?\d+$/]
            raise _INTL("Field {1} is not an integer\n{2}", field, FileLineData.linereport)
          else
            subrecord.push(field.to_i)
          end
        when "u"   # Positive integer or zero
          subrecord.push(csvPosInt!(rec, lineno))
        when "U"   # Optional positive integer or zero
          field = csvfield!(rec)
          if nil_or_empty?(field)
            subrecord.push(nil)
          elsif !field[/^\d+$/]
            raise _INTL("Field '{1}' must be 0 or greater\n{2}", field, FileLineData.linereport)
          else
            subrecord.push(field.to_i)
          end
        when "v"   # Positive integer
          field = csvPosInt!(rec, lineno)
          raise _INTL("Field '{1}' must be greater than 0\n{2}", field, FileLineData.linereport) if field == 0
          subrecord.push(field)
        when "V"   # Optional positive integer
          field = csvfield!(rec)
          if nil_or_empty?(field)
            subrecord.push(nil)
          elsif !field[/^\d+$/]
            raise _INTL("Field '{1}' must be greater than 0\n{2}", field, FileLineData.linereport)
          elsif field.to_i == 0
            raise _INTL("Field '{1}' must be greater than 0\n{2}", field, FileLineData.linereport)
          else
            subrecord.push(field.to_i)
          end
        when "x"   # Hexadecimal number
          field = csvfield!(rec)
          if !field[/^[A-Fa-f0-9]+$/]
            raise _INTL("Field '{1}' is not a hexadecimal number\n{2}", field, FileLineData.linereport)
          end
          subrecord.push(field.hex)
        when "X"   # Optional hexadecimal number
          field = csvfield!(rec)
          if nil_or_empty?(field)
            subrecord.push(nil)
          elsif !field[/^[A-Fa-f0-9]+$/]
            raise _INTL("Field '{1}' is not a hexadecimal number\n{2}", field, FileLineData.linereport)
          else
            subrecord.push(field.hex)
          end
        when "f"   # Floating point number
          subrecord.push(csvFloat!(rec, lineno))
        when "F"   # Optional floating point number
          field = csvfield!(rec)
          if nil_or_empty?(field)
            subrecord.push(nil)
          elsif !field[/^\-?^\d*\.?\d*$/]
            raise _INTL("Field {1} is not a floating point number\n{2}", field, FileLineData.linereport)
          else
            subrecord.push(field.to_f)
          end
        when "b"   # Boolean
          subrecord.push(csvBoolean!(rec, lineno))
        when "B"   # Optional Boolean
          field = csvfield!(rec)
          if nil_or_empty?(field)
            subrecord.push(nil)
          elsif field[/^1|[Tt][Rr][Uu][Ee]|[Yy][Ee][Ss]|[Tt]|[Yy]$/]
            subrecord.push(true)
          else
            subrecord.push(false)
          end
        when "n"   # Name
          field = csvfield!(rec)
          if !field[/^(?![0-9])\w+$/]
            raise _INTL("Field '{1}' must contain only letters, digits, and\nunderscores and can't begin with a number.\n{2}", field, FileLineData.linereport)
          end
          subrecord.push(field)
        when "N"   # Optional name
          field = csvfield!(rec)
          if nil_or_empty?(field)
            subrecord.push(nil)
          elsif !field[/^(?![0-9])\w+$/]
            raise _INTL("Field '{1}' must contain only letters, digits, and\nunderscores and can't begin with a number.\n{2}", field, FileLineData.linereport)
          else
            subrecord.push(field)
          end
        when "s"   # String
          subrecord.push(csvfield!(rec))
        when "S"   # Optional string
          field = csvfield!(rec)
          subrecord.push((nil_or_empty?(field)) ? nil : field)
        when "q"   # Unformatted text
          subrecord.push(rec)
          rec = ""
        when "Q"   # Optional unformatted text
          if nil_or_empty?(rec)
            subrecord.push(nil)
          else
            subrecord.push(rec)
            rec = ""
          end
        when "m"   # Symbol
          field = csvfield!(rec)
          if !field[/^(?![0-9])\w+$/]
            raise _INTL("Field '{1}' must contain only letters, digits, and\nunderscores and can't begin with a number.\n{2}", field, FileLineData.linereport)
          end
          subrecord.push(field.to_sym)
        when "M"   # Optional symbol
          field = csvfield!(rec)
          if nil_or_empty?(field)
            subrecord.push(nil)
          elsif !field[/^(?![0-9])\w+$/]
            raise _INTL("Field '{1}' must contain only letters, digits, and\nunderscores and can't begin with a number.\n{2}", field, FileLineData.linereport)
          else
            subrecord.push(field.to_sym)
          end
        when "e"   # Enumerable
          subrecord.push(csvEnumField!(rec, schema[2 + i - start], "", FileLineData.linereport))
        when "E"   # Optional enumerable
          field = csvfield!(rec)
          subrecord.push(checkEnumFieldOrNil(field, schema[2 + i - start]))
        when "y"   # Enumerable or integer
          field = csvfield!(rec)
          subrecord.push(csvEnumFieldOrInt!(field, schema[2 + i - start], "", FileLineData.linereport))
        when "Y"   # Optional enumerable or integer
          field = csvfield!(rec)
          if nil_or_empty?(field)
            subrecord.push(nil)
          elsif field[/^\-?\d+$/]
            subrecord.push(field.to_i)
          else
            subrecord.push(checkEnumFieldOrNil(field, schema[2 + i - start]))
          end
        end
      end
      if !subrecord.empty?
        if subarrays
          record.push(subrecord)
        else
          record.concat(subrecord)
        end
      end
      break if repeat && nil_or_empty?(rec)
      break unless repeat
    end
    return (!repeat && schema_length == 1) ? record[0] : record
  end

  #=============================================================================
  # Convert a string to values using a schema
  #=============================================================================
  def get_csv_record(rec, schema)
    ret = []
    repeat = false
    start = 0
    schema_length = schema[1].length
    case schema[1][0, 1]   # First character in schema
    when "*"
      repeat = true
      start = 1
    when "^"
      start = 1
      schema_length -= 1
    end
    subarrays = repeat && schema[1].length - start > 1   # Whether ret is an array of arrays
    # Split the string on commas into an array of values to apply the schema to
    values = split_csv_line(rec)
    # Apply the schema to each value in the line
    idx = -1   # Index of value to look at in values
    loop do
      record = []
      (start...schema[1].length).each do |i|
        idx += 1
        sche = schema[1][i, 1]
        if sche[/[A-Z]/]   # Upper case = optional
          if nil_or_empty?(values[idx])
            record.push(nil)
            next
          end
        end
        if sche.downcase == "q"   # Unformatted text
          record.push(rec)
          idx = values.length
          break
        else
          record.push(cast_csv_value(values[idx], sche, schema[2 + i - start]))
        end
      end
      if !record.empty?
        if subarrays
          ret.push(record)
        else
          ret.concat(record)
        end
      end
      break if !repeat || idx >= values.length - 1
    end
    return (!repeat && schema_length == 1) ? ret[0] : ret
  end

  #=============================================================================
  # Write values to a file using a schema
  #=============================================================================
  def pbWriteCsvRecord(record, file, schema)
    rec = (record.is_a?(Array)) ? record.flatten : [record]
    start = (["*", "^"].include?(schema[1][0, 1])) ? 1 : 0
    index = -1
    loop do
      (start...schema[1].length).each do |i|
        index += 1
        value = rec[index]
        if schema[1][i, 1][/[A-Z]/]   # Optional
          # Check the rest of the values for non-nil things
          later_value_found = false
          (index...rec.length).each do |j|
            later_value_found = true if !rec[j].nil?
            break if later_value_found
          end
          if !later_value_found
            start = -1
            break
          end
        end
        file.write(",") if index > 0
        if value.nil?
          # do nothing
        elsif value.is_a?(String)
          if schema[1][i, 1].downcase == "q"
            file.write(value)
          else
            file.write(csvQuote(value))
          end
        elsif value.is_a?(Symbol)
          file.write(csvQuote(value.to_s))
        elsif value == true
          file.write("true")
        elsif value == false
          file.write("false")
        elsif value.is_a?(Numeric)
          case schema[1][i, 1]
          when "e", "E"   # Enumerable
            enumer = schema[2 + i]
            case enumer
            when Array
              file.write(enumer[value])
            when Symbol, String
              mod = Object.const_get(enumer.to_sym)
              file.write(getConstantName(mod, value))
            when Module
              file.write(getConstantName(enumer, value))
            when Hash
              enumer.each_key do |key|
                if enumer[key] == value
                  file.write(key)
                  break
                end
              end
            end
          when "y", "Y"   # Enumerable or integer
            enumer = schema[2 + i]
            case enumer
            when Array
              if enumer[value].nil?
                file.write(value)
              else
                file.write(enumer[value])
              end
            when Symbol, String
              mod = Object.const_get(enumer.to_sym)
              file.write(getConstantNameOrValue(mod, value))
            when Module
              file.write(getConstantNameOrValue(enumer, value))
            when Hash
              hasenum = false
              enumer.each_key do |key|
                next if enumer[key] != value
                file.write(key)
                hasenum = true
                break
              end
              file.write(value) unless hasenum
            end
          else   # Any other record type
            file.write(value.inspect)
          end
        else
          file.write(value.inspect)
        end
      end
      break if start > 0 && index >= rec.length - 1
      break if start <= 0
    end
    return record
  end

  #=============================================================================
  # Parse string into a likely constant name and return its ID number (if any).
  # Last ditch attempt to figure out whether a constant is defined.
  #=============================================================================
  # Unused
  def pbGetConst(mod, item, err)
    isDef = false
    begin
      mod = Object.const_get(mod) if mod.is_a?(Symbol)
      isDef = mod.const_defined?(item.to_sym)
    rescue
      raise sprintf(err, item)
    end
    raise sprintf(err, item) if !isDef
    return mod.const_get(item.to_sym)
  end

  def parseItem(item)
    clonitem = item.upcase
    clonitem.sub!(/^\s*/, "")
    clonitem.sub!(/\s*$/, "")
    itm = GameData::Item.try_get(clonitem)
    if !itm
      raise _INTL("Undefined item constant name: {1}\nMake sure the item is defined in PBS/items.txt.\n{2}", item, FileLineData.linereport)
    end
    return itm.id
  end

  def parseSpecies(species)
    clonspecies = species.upcase
    clonspecies.gsub!(/^\s*/, "")
    clonspecies.gsub!(/\s*$/, "")
    clonspecies = "NIDORANmA" if clonspecies == "NIDORANMA"
    clonspecies = "NIDORANfE" if clonspecies == "NIDORANFE"
    spec = GameData::Species.try_get(clonspecies)
    if !spec
      raise _INTL("Undefined species constant name: {1}\nMake sure the species is defined in PBS/pokemon.txt.\n{2}", species, FileLineData.linereport)
    end
    return spec.id
  end

  def parseMove(move, skip_unknown = false)
    clonmove = move.upcase
    clonmove.sub!(/^\s*/, "")
    clonmove.sub!(/\s*$/, "")
    mov = GameData::Move.try_get(clonmove)
    if !mov
      return nil if skip_unknown
      raise _INTL("Undefined move constant name: {1}\nMake sure the move is defined in PBS/moves.txt.\n{2}", move, FileLineData.linereport)
    end
    return mov.id
  end

  # Unused
  def parseNature(nature)
    clonnature = nature.upcase
    clonnature.sub!(/^\s*/, "")
    clonnature.sub!(/\s*$/, "")
    nat = GameData::Nature.try_get(clonnature)
    if !nat
      raise _INTL("Undefined nature constant name: {1}\nMake sure the nature is defined in the scripts.\n{2}", nature, FileLineData.linereport)
    end
    return nat.id
  end

  # Unused
  def parseTrainer(type)
    clontype = type.clone
    clontype.sub!(/^\s*/, "")
    clontype.sub!(/\s*$/, "")
    typ = GameData::TrainerType.try_get(clontype)
    if !typ
      raise _INTL("Undefined Trainer type constant name: {1}\nMake sure the trainer type is defined in PBS/trainer_types.txt.\n{2}", type, FileLineData.linereport)
    end
    return typ.id
  end

  #=============================================================================
  # Replace text in PBS files before compiling them
  #=============================================================================
  def edit_and_rewrite_pbs_file_text(filename)
    return if !block_given?
    lines = []
    File.open(filename, "rb") do |f|
      f.each_line { |line| lines.push(line) }
    end
    changed = false
    lines.each { |line| changed = true if yield line }
    if changed
      Console.markup_style("Changes made to file #{filename}.", text: :yellow)
      File.open(filename, "wb") do |f|
        lines.each { |line| f.write(line) }
      end
    end
  end

  def modify_pbs_file_contents_before_compiling
    edit_and_rewrite_pbs_file_text("PBS/trainer_types.txt") do |line|
      next line.gsub!(/^\s*VictoryME\s*=/, "VictoryBGM =")
    end
    edit_and_rewrite_pbs_file_text("PBS/moves.txt") do |line|
      next line.gsub!(/^\s*BaseDamage\s*=/, "Power =")
    end
  end

  #=============================================================================
  # Compile all data
  #=============================================================================
  def compile_pbs_file_message_start(filename)
    # The `` around the file's name turns it cyan
    Console.echo_li(_INTL("Compiling PBS file `{1}`...", filename.split("/").last))
  end

  def write_pbs_file_message_start(filename)
    # The `` around the file's name turns it cyan
    Console.echo_li(_INTL("Writing PBS file `{1}`...", filename.split("/").last))
  end

  def process_pbs_file_message_end
    Console.echo_done(true)
    Graphics.update
  end

  def get_all_pbs_files_to_compile
    # Get the GameData classes and their respective base PBS filenames
    ret = GameData.get_all_pbs_base_filenames
    ret.merge!({
      :BattleFacility => "battle_facility_lists",
      :Connection     => "map_connections",
      :RegionalDex    => "regional_dexes"
    })
    ret.each { |key, val| ret[key] = [val] }   # [base_filename, ["PBS/file.txt", etc.]]
    # Look through all PBS files and match them to a GameData class based on
    # their base filenames
    text_files_keys = ret.keys.sort! { |a, b| ret[b][0].length <=> ret[a][0].length }
    Dir.chdir("PBS/") do
      Dir.glob("*.txt") do |f|
        base_name = File.basename(f, ".txt")
        text_files_keys.each do |key|
          next if base_name != ret[key][0] && !f.start_with?(ret[key][0] + "_")
          ret[key][1] ||= []
          ret[key][1].push("PBS/" + f)
          break
        end
      end
    end
    return ret
  end

  def compile_pbs_files
    text_files = get_all_pbs_files_to_compile
    modify_pbs_file_contents_before_compiling
    compile_town_map(*text_files[:TownMap][1])
    compile_connections(*text_files[:Connection][1])
    compile_types(*text_files[:Type][1])
    compile_abilities(*text_files[:Ability][1])
    compile_moves(*text_files[:Move][1])                       # Depends on Type
    compile_items(*text_files[:Item][1])                       # Depends on Move
    compile_berry_plants(*text_files[:BerryPlant][1])          # Depends on Item
    compile_pokemon(*text_files[:Species][1])                  # Depends on Move, Item, Type, Ability
    compile_pokemon_forms(*text_files[:Species1][1])           # Depends on Species, Move, Item, Type, Ability
    compile_pokemon_metrics(*text_files[:SpeciesMetrics][1])   # Depends on Species
    compile_shadow_pokemon(*text_files[:ShadowPokemon][1])     # Depends on Species
    compile_regional_dexes(*text_files[:RegionalDex][1])       # Depends on Species
    compile_ribbons(*text_files[:Ribbon][1])
    compile_encounters(*text_files[:Encounter][1])             # Depends on Species
    compile_trainer_types(*text_files[:TrainerType][1])
    compile_trainers(*text_files[:Trainer][1])                 # Depends on Species, Item, Move
    compile_trainer_lists                                      # Depends on TrainerType
    compile_metadata(*text_files[:Metadata][1])                # Depends on TrainerType
    compile_map_metadata(*text_files[:MapMetadata][1])
    compile_dungeon_tilesets(*text_files[:DungeonTileset][1])
    compile_dungeon_parameters(*text_files[:DungeonParameters][1])
    compile_phone(*text_files[:PhoneMessage][1])               # Depends on TrainerType
  end

  def compile_all(mustCompile)
    Console.echo_h1(_INTL("Checking game data"))
    if !mustCompile
      Console.echoln_li(_INTL("Game data was not compiled"))
      echoln ""
      return
    end
    FileLineData.clear
    compile_pbs_files
    compile_animations
    compile_trainer_events(mustCompile)
    Console.echo_li(_INTL("Saving messages..."))
    Translator.gather_script_and_event_texts
    MessageTypes.save_default_messages
    MessageTypes.load_default_messages if FileTest.exist?("Data/messages_core.dat")
    Console.echo_done(true)
    Console.echoln_li_done(_INTL("Successfully compiled all game data"))
  end

  def main
    return if !$DEBUG
    begin
      mustCompile = false
      # If no PBS file, create one and fill it, then recompile
      if !FileTest.directory?("PBS")
        Dir.mkdir("PBS") rescue nil
        GameData.load_all
        write_all
        mustCompile = true
      end
      # Get all data files and PBS files to be checked for their last modified times
      data_files = GameData.get_all_data_filenames
      data_files += [   # Extra .dat files for data that isn't a GameData class
        ["map_connections.dat", true],
        ["regional_dexes.dat", true],
        ["trainer_lists.dat", true]
      ]
      text_files = get_all_pbs_files_to_compile
      latestDataTime = 0
      latestTextTime = 0
      # Should recompile if new maps were imported
      mustCompile |= import_new_maps
      # Check data files for their latest modify time
      data_files.each do |filename|   # filename = [string, boolean (whether mandatory)]
        if FileTest.exist?("Data/" + filename[0])
          begin
            File.open("Data/#{filename[0]}") do |file|
              latestDataTime = [latestDataTime, file.mtime.to_i].max
            end
          rescue SystemCallError
            mustCompile = true
          end
        elsif filename[1]
          mustCompile = true
          break
        end
      end
      # Check PBS files for their latest modify time
      text_files.each do |key, value|
        next if !value || !value[1].is_a?(Array)
        value[1].each do |filepath|
          begin
            File.open(filepath) { |file| latestTextTime = [latestTextTime, file.mtime.to_i].max }
          rescue SystemCallError
          end
        end
      end
      # Decide to compile if a PBS file was edited more recently than any .dat files
      mustCompile |= (latestTextTime >= latestDataTime)
      # Should recompile if holding Ctrl
      Input.update
      mustCompile = true if Input.press?(Input::CTRL)
      # Delete old data files in preparation for recompiling
      if mustCompile
        data_files.each do |filename|
          begin
            File.delete("Data/#{filename[0]}") if FileTest.exist?("Data/#{filename[0]}")
          rescue SystemCallError
          end
        end
      end
      # Recompile all data
      compile_all(mustCompile)
    rescue Exception
      e = $!
      raise e if e.class.to_s == "Reset" || e.is_a?(Reset) || e.is_a?(SystemExit)
      pbPrintException(e)
      data_files.each do |filename|
        begin
          File.delete("Data/#{filename[0]}") if FileTest.exist?("Data/#{filename[0]}")
        rescue SystemCallError
        end
      end
      raise Reset.new if e.is_a?(Hangup)
      raise "Unknown exception when compiling."
    end
  end
end
