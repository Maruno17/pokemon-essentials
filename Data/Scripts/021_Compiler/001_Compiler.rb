#===============================================================================
# Records which file, section and line are currently being read.
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
# Compiler.
#===============================================================================
module Compiler
  @@categories = {}

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

  #-----------------------------------------------------------------------------
  # PBS file readers.
  #-----------------------------------------------------------------------------

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
            raise _INTL("Expected a section at the beginning of the file.\nThis error may also occur if the file was not saved in UTF-8.") + "\n" + FileLineData.linereport
          end
          if !line[/^\s*(\w+)\s*=\s*(.*)$/]
            FileLineData.setSection(sectionname, nil, line)
            raise _INTL("Bad line syntax (expected syntax like XXX=YYY).") + "\n" + FileLineData.linereport
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

  # Used for most PBS files.
  def pbEachFileSection(f, schema = nil)
    pbEachFileSectionEx(f, schema) do |section, name|
      yield section, name if block_given? && name[/^.+$/]
    end
  end

  # Unused.
  def pbEachFileSectionNumbered(f, schema = nil)
    pbEachFileSectionEx(f, schema) do |section, name|
      yield section, name.to_i if block_given? && name[/^\d+$/]
    end
  end

  # Used by translated text compiler.
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

  # Unused.
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

  # Used for Battle Tower Pokémon PBS files.
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

  # Unused.
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

  # Used for map_connections.txt, regional_dexes.txt, encounters.txt,
  # trainers.txt and plugin meta.txt files.
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

  #-----------------------------------------------------------------------------
  # Splits a string containing comma-separated values into an array of those
  # values.
  #-----------------------------------------------------------------------------

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

  #-----------------------------------------------------------------------------
  # Convert a string to certain kinds of values.
  #-----------------------------------------------------------------------------

  # Turns a value (a string) into another data type as determined by the given
  # schema.
  # @param value [String]
  # @param schema [String]
  def cast_csv_value(value, schema, enumer = nil)
    case schema.downcase
    when "i"   # Integer
      if !value || !value[/^\-?\d+$/]
        raise _INTL("Field '{1}' is not an integer.", value) + "\n" + FileLineData.linereport
      end
      return value.to_i
    when "u"   # Positive integer or zero
      if !value || !value[/^\d+$/]
        raise _INTL("Field '{1}' is not a positive integer or 0.", value) + "\n" + FileLineData.linereport
      end
      return value.to_i
    when "v"   # Positive integer
      if !value || !value[/^\d+$/]
        raise _INTL("Field '{1}' is not a positive integer.", value) + "\n" + FileLineData.linereport
      end
      if value.to_i == 0
        raise _INTL("Field '{1}' must be greater than 0.", value) + "\n" + FileLineData.linereport
      end
      return value.to_i
    when "x"   # Hexadecimal number
      if !value || !value[/^[A-F0-9]+$/i]
        raise _INTL("Field '{1}' is not a hexadecimal number.", value) + "\n" + FileLineData.linereport
      end
      return value.hex
    when "f"   # Floating point number
      if !value || !value[/^\-?^\d*\.?\d*$/]
        raise _INTL("Field '{1}' is not a number.", value) + "\n" + FileLineData.linereport
      end
      return value.to_f
    when "b"   # Boolean
      return true if value && value[/^(?:1|TRUE|YES|Y)$/i]
      return false if value && value[/^(?:0|FALSE|NO|N)$/i]
      raise _INTL("Field '{1}' is not a Boolean value (true, false, 1, 0).", value) + "\n" + FileLineData.linereport
    when "n"   # Name
      if !value || !value[/^(?![0-9])\w+$/]
        raise _INTL("Field '{1}' must contain only letters, digits, and\nunderscores and can't begin with a number.", value) + "\n" + FileLineData.linereport
      end
    when "s"   # String
    when "q"   # Unformatted text
    when "m"   # Symbol
      if !value || !value[/^(?![0-9])\w+$/]
        raise _INTL("Field '{1}' must contain only letters, digits, and\nunderscores and can't begin with a number.", value) + "\n" + FileLineData.linereport
      end
      return value.to_sym
    when "e"   # Enumerable
      return checkEnumField(value, enumer)
    when "y"   # Enumerable or integer
      return value.to_i if value && value[/^\-?\d+$/]
      return checkEnumField(value, enumer)
    end
    return value
  end

  def checkEnumField(ret, enumer)
    case enumer
    when Module
      begin
        if nil_or_empty?(ret) || !enumer.const_defined?(ret)
          raise _INTL("Undefined value {1} in {2}.", ret, enumer.name) + "\n" + FileLineData.linereport
        end
      rescue NameError
        raise _INTL("Incorrect value {1} in {2}.", ret, enumer.name) + "\n" + FileLineData.linereport
      end
      return enumer.const_get(ret.to_sym)
    when Symbol, String
      if !Kernel.const_defined?(enumer.to_sym) && GameData.const_defined?(enumer.to_sym)
        enumer = GameData.const_get(enumer.to_sym)
        begin
          if nil_or_empty?(ret) || !enumer.exists?(ret.to_sym)
            raise _INTL("Undefined value {1} in {2}.", ret, enumer.name) + "\n" + FileLineData.linereport
          end
        rescue NameError
          raise _INTL("Incorrect value {1} in {2}.", ret, enumer.name) + "\n" + FileLineData.linereport
        end
        return ret.to_sym
      end
      enumer = Object.const_get(enumer.to_sym)
      begin
        if nil_or_empty?(ret) || !enumer.const_defined?(ret)
          raise _INTL("Undefined value {1} in {2}.", ret, enumer.name) + "\n" + FileLineData.linereport
        end
      rescue NameError
        raise _INTL("Incorrect value {1} in {2}.", ret, enumer.name) + "\n" + FileLineData.linereport
      end
      return enumer.const_get(ret.to_sym)
    when Array
      idx = (nil_or_empty?(ret)) ? -1 : findIndex(enumer) { |item| ret == item }
      if idx < 0
        raise _INTL("Undefined value {1} (expected one of: {2}).", ret, enumer.inspect) + "\n" + FileLineData.linereport
      end
      return idx
    when Hash
      value = (nil_or_empty?(ret)) ? nil : enumer[ret]
      if value.nil?
        raise _INTL("Undefined value {1} (expected one of: {2}).", ret, enumer.keys.inspect) + "\n" + FileLineData.linereport
      end
      return value
    end
    raise _INTL("Enumeration not defined.") + "\n" + FileLineData.linereport
  end

  #-----------------------------------------------------------------------------

  # Convert a string to values using a schema.
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

  #-----------------------------------------------------------------------------

  # Write values to a file using a schema.
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
        next if value.nil?
        case schema[1][i, 1]
        when "e", "E"   # Enumerable
          enumer = schema[2 + i - start]
          case enumer
          when Array
            file.write((value.is_a?(Integer) && !enumer[value].nil?) ? enumer[value] : value)
          when Symbol, String
            if GameData.const_defined?(enumer.to_sym)
              mod = GameData.const_get(enumer.to_sym)
              file.write(mod.get(value).id.to_s)
            else
              mod = Object.const_get(enumer.to_sym)
              file.write(getConstantName(mod, value))
            end
          when Module
            file.write(getConstantName(enumer, value))
          when Hash
            if value.is_a?(String)
              file.write(value)
            else
              enumer.each_key do |key|
                next if enumer[key] != value
                file.write(key)
                break
              end
            end
          end
        when "y", "Y"   # Enumerable or integer
          enumer = schema[2 + i - start]
          case enumer
          when Array
            file.write((value.is_a?(Integer) && !enumer[value].nil?) ? enumer[value] : value)
          when Symbol, String
            if !Kernel.const_defined?(enumer.to_sym) && GameData.const_defined?(enumer.to_sym)
              mod = GameData.const_get(enumer.to_sym)
              if mod.exists?(value)
                file.write(mod.get(value).id.to_s)
              else
                file.write(value.to_s)
              end
            else
              mod = Object.const_get(enumer.to_sym)
              file.write(getConstantNameOrValue(mod, value))
            end
          when Module
            file.write(getConstantNameOrValue(enumer, value))
          when Hash
            if value.is_a?(String)
              file.write(value)
            else
              has_enum = false
              enumer.each_key do |key|
                next if enumer[key] != value
                file.write(key)
                has_enum = true
                break
              end
              file.write(value) if !has_enum
            end
          end
        else
          if value.is_a?(String)
            file.write((schema[1][i, 1].downcase == "q") ? value : csvQuote(value))
          elsif value.is_a?(Symbol)
            file.write(csvQuote(value.to_s))
          elsif value == true
            file.write("true")
          elsif value == false
            file.write("false")
          else
            file.write(value.inspect)
          end
        end
      end
      break if start > 0 && index >= rec.length - 1
      break if start <= 0
    end
    return record
  end

  #-----------------------------------------------------------------------------
  # Parse string into a likely constant name and return its ID number (if any).
  # Last ditch attempt to figure out whether a constant is defined.
  #-----------------------------------------------------------------------------

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
      raise _INTL("Undefined item constant name: {1}.\nMake sure the item is defined in PBS/items.txt.", item) + "\n" + FileLineData.linereport
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
      raise _INTL("Undefined species constant name: {1}.\nMake sure the species is defined in PBS/pokemon.txt.", species) + "\n" + FileLineData.linereport
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
      raise _INTL("Undefined move constant name: {1}.\nMake sure the move is defined in PBS/moves.txt.", move) + "\n" + FileLineData.linereport
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
      raise _INTL("Undefined nature constant name: {1}.\nMake sure the nature is defined in the scripts.", nature) + "\n" + FileLineData.linereport
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
      raise _INTL("Undefined trainer type constant name: {1}.\nMake sure the trainer type is defined in PBS/trainer_types.txt.", type) + "\n" + FileLineData.linereport
    end
    return typ.id
  end

  #-----------------------------------------------------------------------------
  # Replace text in PBS files before compiling them.
  #-----------------------------------------------------------------------------

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

  #-----------------------------------------------------------------------------
  # Compile all data.
  #-----------------------------------------------------------------------------

  def categories_to_compile(all_categories = false)
    ret = []
    Input.update
    if all_categories || $full_compile || Input.press?(Input::CTRL)
      ret = @@categories.keys.clone
      return ret
    end
    @@categories.each_pair do |category, procs|
      ret.push(category) if procs[:should_compile]&.call(ret)
    end
    return ret
  end

  def compile_all(all_categories = false)
    FileLineData.clear
    to_compile = categories_to_compile(all_categories)
    @@categories.each_pair do |category, procs|
      Console.echo_h1(procs[:header_text]&.call || _INTL("Compiling {1}", category))
      if to_compile.include?(category)
        @@categories[category][:compile].call
      else
        Console.echoln_li(procs[:skipped_text]&.call || _INTL("Not compiled"))
      end
      echoln ""
    end
  end

  def main
    return if !$DEBUG
    begin
      compile_all
    rescue Exception
      e = $!
      raise e if e.class.to_s == "Reset" || e.is_a?(Reset) || e.is_a?(SystemExit)
      pbPrintException(e)
      get_all_pbs_data_filenames_to_compile.each do |filename|
        begin
          File.delete("Data/#{filename[0]}") if FileTest.exist?("Data/#{filename[0]}")
        rescue SystemCallError
        end
      end
      raise Reset.new if e.is_a?(Hangup)
      raise SystemExit.new if e.is_a?(RuntimeError)
      raise "Unknown exception when compiling."
    end
  end
end
