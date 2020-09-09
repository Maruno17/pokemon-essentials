#===============================================================================
# Exceptions and critical code
#===============================================================================
class Reset < Exception
end



def pbGetExceptionMessage(e,_script="")
  emessage = e.message
  if e.is_a?(Hangup)
    emessage = "The script is taking too long. The game will restart."
  elsif e.is_a?(Errno::ENOENT)
    filename = emessage.sub("No such file or directory - ", "")
    emessage = "File #{filename} not found."
  end
  if emessage && !safeExists?("Game.rgssad") && !safeExists?("Game.rgss2a")
    emessage = emessage.gsub(/uninitialized constant PBItems\:\:(\S+)/) {
       "The item '#{$1}' is not valid. Please add the item\r\nto the list of items in the editor. See the wiki for more information." }
    emessage = emessage.gsub(/undefined method `(\S+?)' for PBItems\:Module/) {
       "The item '#{$1}' is not valid. Please add the item\r\nto the list of items in the editor. See the wiki for more information." }
    emessage = emessage.gsub(/uninitialized constant PBTypes\:\:(\S+)/) {
       "The type '#{$1}' is not valid. Please add the type\r\nto the PBS/types.txt file." }
    emessage = emessage.gsub(/undefined method `(\S+?)' for PBTypes\:Module/) {
       "The type '#{$1}' is not valid. Please add the type\r\nto the PBS/types.txt file." }
    emessage = emessage.gsub(/uninitialized constant PBTrainers\:\:(\S+)$/) {
       "The trainer type '#{$1}' is not valid. Please add the trainer\r\nto the list of trainer types in the Editor. See the wiki for\r\nmore information." }
    emessage = emessage.gsub(/undefined method `(\S+?)' for PBTrainers\:Module/) {
       "The trainer type '#{$1}' is not valid. Please add the trainer\r\nto the list of trainer types in the Editor. See the wiki for\r\nmore information." }
    emessage = emessage.gsub(/uninitialized constant PBSpecies\:\:(\S+)$/) {
       "The Pokemon species '#{$1}' is not valid. Please\r\nadd the species to the PBS/pokemon.txt file.\r\nSee the wiki for more information." }
    emessage = emessage.gsub(/undefined method `(\S+?)' for PBSpecies\:Module/) {
       "The Pokemon species '#{$1}' is not valid. Please\r\nadd the species to the PBS/pokemon.txt file.\r\nSee the wiki for more information." }
  end
  emessage.gsub!(/Section(\d+)/) { $RGSS_SCRIPTS[$1.to_i][1] }
  return emessage
end

def pbPrintException(e)
  premessage = "\r\n=================\r\n\r\n[#{Time.now}]\r\n"
  emessage = ""
  if $EVENTHANGUPMSG && $EVENTHANGUPMSG!=""
    emessage = $EVENTHANGUPMSG   # Message with map/event ID generated elsewhere
    $EVENTHANGUPMSG = nil
  else
    emessage = pbGetExceptionMessage(e)
  end
  btrace = ""
  if e.backtrace
    maxlength = ($INTERNAL) ? 25 : 10
    e.backtrace[0,maxlength].each { |i| btrace += "#{i}\r\n" }
  end
  btrace.gsub!(/Section(\d+)/) { $RGSS_SCRIPTS[$1.to_i][1] }
  message = "[Pokémon Essentials version #{ESSENTIALS_VERSION}]\r\n"
  message += "#{ERROR_TEXT}"   # For third party scripts to add to
  message += "Exception: #{e.class}\r\n"
  message += "Message: #{emessage}\r\n"
  message += "\r\nBacktrace:\r\n#{btrace}"
  errorlog = "errorlog.txt"
  if (Object.const_defined?(:RTP) rescue false)
    errorlog = RTP.getSaveFileName("errorlog.txt")
  end
  File.open(errorlog,"ab") { |f| f.write(premessage); f.write(message) }
  errorlogline = errorlog.sub("/", "\\")
  errorlogline.sub!(Dir.pwd + "\\", "")
  errorlogline.sub!(pbGetUserName, "USERNAME")
  errorlogline = "\r\n" + errorlogline if errorlogline.length > 20
  errorlogline.gsub!("/", "\\")
  print("#{message}\r\nThis exception was logged in #{errorlogline}.\r\nPress Ctrl+C to copy this message to the clipboard.")
end

def pbCriticalCode
  ret = 0
  begin
    yield
    ret = 1
  rescue Exception
    e = $!
    if e.is_a?(Reset) || e.is_a?(SystemExit)
      raise
    else
      pbPrintException(e)
      if e.is_a?(Hangup)
        ret = 2
        raise Reset.new
      end
    end
  end
  return ret
end



#===============================================================================
# File reading
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

  def self.linereport
    if @section
      if @key!=nil
        return _INTL("File {1}, section {2}, key {3}\r\n{4}\r\n\r\n",@file,@section,@key,@value)
      else
        return _INTL("File {1}, section {2}\r\n{3}\r\n\r\n",@file,@section,@value)
      end
    else
      return _INTL("File {1}, line {2}\r\n{3}\r\n\r\n",@file,@lineno,@linedata)
    end
  end

  def self.setSection(section,key,value)
    @section = section
    @key     = key
    if value && value.length>200
      @value = _INTL("{1}...",value[0,200])
    else
      @value = (value) ? value.clone : ""
    end
  end

  def self.setLine(line,lineno)
    @section  = nil
    @linedata = (line && line.length>200) ? sprintf("%s...",line[0,200]) : line.clone
    @lineno   = lineno
  end
end



def findIndex(a)
  index = -1
  count = 0
  a.each { |i|
    if yield i
      index = count
      break
    end
    count += 1
  }
  return index
end

def prepline(line)
  line.sub!(/\s*\#.*$/,"")
  line.sub!(/^\s+/,"")
  line.sub!(/\s+$/,"")
  return line
end

def pbEachFileSectionEx(f)
  lineno      = 1
  havesection = false
  sectionname = nil
  lastsection = {}
  f.each_line { |line|
    if lineno==1 && line[0]==0xEF && line[1]==0xBB && line[2]==0xBF
      line = line[3,line.length-3]
    end
    if !line[/^\#/] && !line[/^\s*$/]
      if line[/^\s*\[\s*(.*)\s*\]\s*$/]   # Of the format: [something]
        yield lastsection,sectionname if havesection
        sectionname = $~[1]
        havesection = true
        lastsection = {}
      else
        if sectionname==nil
          FileLineData.setLine(line,lineno)
          raise _INTL("Expected a section at the beginning of the file. This error may also occur if the file was not saved in UTF-8.\r\n{1}",FileLineData.linereport)
        end
        if !line[/^\s*(\w+)\s*=\s*(.*)$/]
          FileLineData.setSection(sectionname,nil,line)
          raise _INTL("Bad line syntax (expected syntax like XXX=YYY)\r\n{1}",FileLineData.linereport)
        end
        r1 = $~[1]
        r2 = $~[2]
        lastsection[r1] = r2.gsub(/\s+$/,"")
      end
    end
    lineno += 1
    Graphics.update if lineno%500==0
    Win32API.SetWindowText(_INTL("Processing line {1}",lineno)) if lineno%50==0
  }
  yield lastsection,sectionname  if havesection
end

def pbEachFileSection(f)
  pbEachFileSectionEx(f) { |section,name|
    yield section,name.to_i if block_given? && name[/^\d+$/]
  }
end

def pbEachFileSection2(f)
  pbEachFileSectionEx(f) { |section,name|
    yield section,name if block_given? && name[/^\w+[-,\s]{1}\d+$/]
  }
end

def pbEachSection(f)
  lineno      = 1
  havesection = false
  sectionname = nil
  lastsection = []
  f.each_line { |line|
    if lineno==1 && line[0]==0xEF && line[1]==0xBB && line[2]==0xBF
      line = line[3,line.length-3]
    end
    if !line[/^\#/] && !line[/^\s*$/]
      if line[/^\s*\[\s*(.+?)\s*\]\s*$/]
        yield lastsection,sectionname  if havesection
        sectionname = $~[1]
        lastsection = []
        havesection = true
      else
        if sectionname==nil
          raise _INTL("Expected a section at the beginning of the file (line {1}). Sections begin with '[name of section]'",lineno)
        end
        lastsection.push(line.gsub(/^\s+/,"").gsub(/\s+$/,""))
      end
    end
    lineno += 1
    Graphics.update if lineno%500==0
  }
  yield lastsection,sectionname  if havesection
end

def pbEachCommentedLine(f)
  lineno = 1
  f.each_line { |line|
    if lineno==1 && line[0]==0xEF && line[1]==0xBB && line[2]==0xBF
      line = line[3,line.length-3]
    end
    yield line, lineno if !line[/^\#/] && !line[/^\s*$/]
    lineno += 1
  }
end

def pbCompilerEachCommentedLine(filename)
  File.open(filename,"rb") { |f|
    FileLineData.file = filename
    lineno = 1
    f.each_line { |line|
      if lineno==1 && line[0]==0xEF && line[1]==0xBB && line[2]==0xBF
        line = line[3,line.length-3]
      end
      if !line[/^\#/] && !line[/^\s*$/]
        FileLineData.setLine(line,lineno)
        yield line, lineno
      end
      lineno += 1
    }
  }
end

def pbEachPreppedLine(f)
  lineno = 1
  f.each_line { |line|
    if lineno==1 && line[0]==0xEF && line[1]==0xBB && line[2]==0xBF
      line = line[3,line.length-3]
    end
    line = prepline(line)
    yield line, lineno if !line[/^\#/] && !line[/^\s*$/]
    lineno += 1
  }
end

def pbCompilerEachPreppedLine(filename)
  File.open(filename,"rb") { |f|
    FileLineData.file = filename
    lineno = 1
    f.each_line { |line|
      if lineno==1 && line[0]==0xEF && line[1]==0xBB && line[2]==0xBF
        line = line[3,line.length-3]
      end
      line = prepline(line)
      if !line[/^\#/] && !line[/^\s*$/]
        FileLineData.setLine(line,lineno)
        yield line, lineno
      end
      lineno += 1
    }
  }
end

#===============================================================================
# Valid value checks
#===============================================================================
def pbCheckByte(x,valuename)
  if x<0 || x>255
    raise _INTL("The value \"{1}\" must be from 0 through 255 (00-FF in hex), got a value of {2}\r\n{3}",valuename,x,FileLineData.linereport)
  end
end

def pbCheckSignedByte(x,valuename)
  if x<-128 || x>127
    raise _INTL("The value \"{1}\" must be from -128 through 127, got a value of {2}\r\n{3}",valuename,x,FileLineData.linereport)
  end
end

def pbCheckWord(x,valuename)
  if x<0 || x>65535
    raise _INTL("The value \"{1}\" must be from 0 through 65535 (0000-FFFF in hex), got a value of {2}\r\n{3}",valuename,x,FileLineData.linereport)
  end
end

def pbCheckSignedWord(x,valuename)
  if x<-32768 || x>32767
    raise _INTL("The value \"{1}\" must be from -32768 through 32767, got a value of {2}\r\n{3}",valuename,x,FileLineData.linereport)
  end
end

#===============================================================================
# Csv parsing
#===============================================================================
def csvfield!(str)
  ret = ""
  str.sub!(/^\s*/,"")
  if str[0,1]=="\""
    str[0,1] = ""
    escaped = false
    fieldbytes = 0
    str.scan(/./) do |s|
      fieldbytes += s.length
      break if s=="\"" && !escaped
      if s=="\\" && !escaped
        escaped = true
      else
        ret += s
        escaped = false
      end
    end
    str[0,fieldbytes] = ""
    if !str[/^\s*,/] && !str[/^\s*$/]
      raise _INTL("Invalid quoted field (in: {1})\r\n{2}",str,FileLineData.linereport)
    end
    str[0,str.length] = $~.post_match
  else
    if str[/,/]
      str[0,str.length] = $~.post_match
      ret = $~.pre_match
    else
      ret = str.clone
      str[0,str.length] = ""
    end
    ret.gsub!(/\s+$/,"")
  end
  return ret
end

def csvBoolean!(str,_line=-1)
  field = csvfield!(str)
  if field[/^1|[Tt][Rr][Uu][Ee]|[Yy][Ee][Ss]|[Yy]$/]
    return true
  elsif field[/^0|[Ff][Aa][Ll][Ss][Ee]|[Nn][Oo]|[Nn]$/]
    return false
  end
  raise _INTL("Field {1} is not a Boolean value (true, false, 1, 0)\r\n{2}",field,FileLineData.linereport)
end

def csvInt!(str,_line=-1)
  ret = csvfield!(str)
  if !ret[/^\-?\d+$/]
    raise _INTL("Field {1} is not an integer\r\n{2}",ret,FileLineData.linereport)
  end
  return ret.to_i
end

def csvPosInt!(str,_line=-1)
  ret = csvfield!(str)
  if !ret[/^\d+$/]
    raise _INTL("Field {1} is not a positive integer\r\n{2}",ret,FileLineData.linereport)
  end
  return ret.to_i
end

def csvFloat!(str,_line=-1)
  ret = csvfield!(str)
  return Float(ret) rescue raise _INTL("Field {1} is not a number\r\n{2}",ret,FileLineData.linereport)
end

def csvEnumField!(value,enumer,_key,_section)
  ret = csvfield!(value)
  return checkEnumField(ret,enumer)
end

def csvEnumFieldOrInt!(value,enumer,_key,_section)
  ret = csvfield!(value)
  return ret.to_i if ret[/\-?\d+/]
  return checkEnumField(ret,enumer)
end

def checkEnumField(ret,enumer)
  if enumer.is_a?(Module)
    begin
      if ret=="" || !enumer.const_defined?(ret)
        raise _INTL("Undefined value {1} in {2}\r\n{3}",ret,enumer.name,FileLineData.linereport)
      end
    rescue NameError
      raise _INTL("Incorrect value {1} in {2}\r\n{3}",ret,enumer.name,FileLineData.linereport)
    end
    return enumer.const_get(ret.to_sym)
  elsif enumer.is_a?(Symbol) || enumer.is_a?(String)
    enumer = Object.const_get(enumer.to_sym)
    begin
      if ret=="" || !enumer.const_defined?(ret)
        raise _INTL("Undefined value {1} in {2}\r\n{3}",ret,enumer.name,FileLineData.linereport)
      end
    rescue NameError
      raise _INTL("Incorrect value {1} in {2}\r\n{3}",ret,enumer.name,FileLineData.linereport)
    end
    return enumer.const_get(ret.to_sym)
  elsif enumer.is_a?(Array)
    idx = findIndex(enumer) { |item| ret==item }
    if idx<0
      raise _INTL("Undefined value {1} (expected one of: {2})\r\n{3}",ret,enumer.inspect,FileLineData.linereport)
    end
    return idx
  elsif enumer.is_a?(Hash)
    value = enumer[ret]
    if value==nil
      raise _INTL("Undefined value {1} (expected one of: {2})\r\n{3}",ret,enumer.keys.inspect,FileLineData.linereport)
    end
    return value
  end
  raise _INTL("Enumeration not defined\r\n{1}",FileLineData.linereport)
end

def checkEnumFieldOrNil(ret,enumer)
  if enumer.is_a?(Module)
    return nil if ret=="" || !(enumer.const_defined?(ret) rescue false)
    return enumer.const_get(ret.to_sym)
  elsif enumer.is_a?(Symbol) || enumer.is_a?(String)
    enumer = Object.const_get(enumer.to_sym)
    return nil if ret=="" || !(enumer.const_defined?(ret) rescue false)
    return enumer.const_get(ret.to_sym)
  elsif enumer.is_a?(Array)
    idx = findIndex(enumer) { |item| ret==item }
    return nil if idx<0
    return idx
  elsif enumer.is_a?(Hash)
    return enumer[ret]
  end
  return nil
end

#===============================================================================
# Csv record readin
#===============================================================================
def pbGetCsvRecord(rec,lineno,schema)
  record = []
  repeat = false
  start = 0
  if schema[1][0,1]=="*"
    repeat = true
    start = 1
  end
  begin
    for i in start...schema[1].length
      chr = schema[1][i,1]
      case chr
      when "i"   # Integer
        record.push(csvInt!(rec,lineno))
      when "I"   # Optional integer
        field = csvfield!(rec)
        if field==""
          record.push(nil)
        elsif !field[/^\-?\d+$/]
          raise _INTL("Field {1} is not an integer\r\n{2}",field,FileLineData.linereport)
        else
          record.push(field.to_i)
        end
      when "u"   # Positive integer or zero
        record.push(csvPosInt!(rec,lineno))
      when "U"   # Optional positive integer or zero
        field = csvfield!(rec)
        if field==""
          record.push(nil)
        elsif !field[/^\d+$/]
          raise _INTL("Field '{1}' must be 0 or greater\r\n{2}",field,FileLineData.linereport)
        else
          record.push(field.to_i)
        end
      when "v"   # Positive integer
        field = csvPosInt!(rec,lineno)
        raise _INTL("Field '{1}' must be greater than 0\r\n{2}",field,FileLineData.linereport) if field==0
        record.push(field)
      when "V"   # Optional positive integer
        field = csvfield!(rec)
        if field==""
          record.push(nil)
        elsif !field[/^\d+$/]
          raise _INTL("Field '{1}' must be greater than 0\r\n{2}",field,FileLineData.linereport)
        elsif field.to_i==0
          raise _INTL("Field '{1}' must be greater than 0\r\n{2}",field,FileLineData.linereport)
        else
          record.push(field.to_i)
        end
      when "x"   # Hexadecimal number
        field = csvfield!(rec)
        if !field[/^[A-Fa-f0-9]+$/]
          raise _INTL("Field '{1}' is not a hexadecimal number\r\n{2}",field,FileLineData.linereport)
        end
        record.push(field.hex)
      when "X"   # Optional hexadecimal number
        field = csvfield!(rec)
        if field==""
          record.push(nil)
        elsif !field[/^[A-Fa-f0-9]+$/]
          raise _INTL("Field '{1}' is not a hexadecimal number\r\n{2}",field,FileLineData.linereport)
        else
          record.push(field.hex)
        end
      when "f"   # Floating point number
        record.push(csvFloat!(rec,lineno))
      when "F"   # Optional floating point number
        field = csvfield!(rec)
        if field==""
          record.push(nil)
        elsif !field[/^\-?^\d*\.?\d*$/]
          raise _INTL("Field {1} is not a floating point number\r\n{2}",field,FileLineData.linereport)
        else
          record.push(field.to_f)
        end
      when "b"   # Boolean
        record.push(csvBoolean!(rec,lineno))
      when "B"   # Optional Boolean
        field = csvfield!(rec)
        if field==""
          record.push(nil)
        elsif field[/^1|[Tt][Rr][Uu][Ee]|[Yy][Ee][Ss]|[Tt]|[Yy]$/]
          record.push(true)
        else
          record.push(false)
        end
      when "n"   # Name
        field = csvfield!(rec)
        if !field[/^(?![0-9])\w+$/]
          raise _INTL("Field '{1}' must contain only letters, digits, and\r\nunderscores and can't begin with a number.\r\n{2}",field,FileLineData.linereport)
        end
        record.push(field)
      when "N"   # Optional name
        field = csvfield!(rec)
        if field==""
          record.push(nil)
        elsif !field[/^(?![0-9])\w+$/]
          raise _INTL("Field '{1}' must contain only letters, digits, and\r\nunderscores and can't begin with a number.\r\n{2}",field,FileLineData.linereport)
        else
          record.push(field)
        end
      when "s"   # String
        record.push(csvfield!(rec))
      when "S"   # Optional string
        field = csvfield!(rec)
        record.push((field=="") ? nil : field)
      when "q"   # Unformatted text
        record.push(rec)
        rec = ""
      when "Q"   # Optional unformatted text
        if !rec || rec==""
          record.push(nil)
        else
          record.push(rec)
          rec = ""
        end
      when "e"   # Enumerable
        record.push(csvEnumField!(rec,schema[2+i-start],"",FileLineData.linereport))
      when "E"   # Optional enumerable
        field = csvfield!(rec)
        record.push(checkEnumFieldOrNil(field,schema[2+i-start]))
      when "y"   # Enumerable or integer
        field = csvfield!(rec)
        record.push(csvEnumFieldOrInt!(field,schema[2+i-start],"",FileLineData.linereport))
      when "Y"   # Optional enumerable or integer
        field = csvfield!(rec)
        if field==""
          record.push(nil)
        elsif field[/^\-?\d+$/]
          record.push(field.to_i)
        else
          record.push(checkEnumFieldOrNil(field,schema[2+i-start]))
        end
      end
    end
    break if repeat && rec==""
  end while repeat
  return (schema[1].length==1) ? record[0] : record
end

#===============================================================================
# Csv record writing
#===============================================================================
def csvQuote(str,always=false)
  return "" if !str || str==""
  if always || str[/[,\"]/]   # || str[/^\s/] || str[/\s$/] || str[/^#/]
    str = str.gsub(/[\"]/,"\\\"")
    str = "\"#{str}\""
  end
  return str
end

def csvQuoteAlways(str)
  return csvQuote(str,true)
end

def pbWriteCsvRecord(record,file,schema)
  rec = (record.is_a?(Array)) ? record.clone : [record]
  for i in 0...schema[1].length
    chr = schema[1][i,1]
    file.write(",") if i>0
    if rec[i].nil?
      # do nothing
    elsif rec[i].is_a?(String)
      file.write(csvQuote(rec[i]))
    elsif rec[i]==true
      file.write("true")
    elsif rec[i]==false
      file.write("false")
    elsif rec[i].is_a?(Numeric)
      case chr
      when "e", "E"   # Enumerable
        enumer = schema[2+i]
        if enumer.is_a?(Array)
          file.write(enumer[rec[i]])
        elsif enumer.is_a?(Symbol) || enumer.is_a?(String)
          mod = Object.const_get(enumer.to_sym)
          if enumer.to_s=="PBTrainers" && !mod.respond_to?("getCount")
            file.write((getConstantName(mod,rec[i]) rescue pbGetTrainerConst(rec[i])))
          else
            file.write(getConstantName(mod,rec[i]))
          end
        elsif enumer.is_a?(Module)
          file.write(getConstantName(enumer,rec[i]))
        elsif enumer.is_a?(Hash)
          for key in enumer.keys
            if enumer[key]==rec[i]
              file.write(key)
              break
            end
          end
        end
      when "y", "Y"   # Enumerable or integer
        enumer = schema[2+i]
        if enumer.is_a?(Array)
          if enumer[rec[i]]!=nil
            file.write(enumer[rec[i]])
          else
            file.write(rec[i])
          end
        elsif enumer.is_a?(Symbol) || enumer.is_a?(String)
          mod = Object.const_get(enumer.to_sym)
          if enumer.to_s=="PBTrainers" && !mod.respond_to?("getCount")
            file.write((getConstantNameOrValue(mod,rec[i]) rescue pbGetTrainerConst(rec[i])))
          else
            file.write(getConstantNameOrValue(mod,rec[i]))
          end
        elsif enumer.is_a?(Module)
          file.write(getConstantNameOrValue(enumer,rec[i]))
        elsif enumer.is_a?(Hash)
          hasenum = false
          for key in enumer.keys
            if enumer[key]==rec[i]
              file.write(key)
              hasenum = true; break
            end
          end
          file.write(rec[i]) unless hasenum
        end
      else   # Any other record type
        file.write(rec[i].inspect)
      end
    else
      file.write(rec[i].inspect)
    end
  end
  return record
end

#===============================================================================
# Encoding and decoding
#===============================================================================
def intSize(value)
  return 1 if value<0x80
  return 2 if value<0x4000
  return 3 if value<0x200000
  return 4 if value<0x10000000
  return 5
end

def encodeInt(strm,value)
  num = 0
  loop do
    if value<0x80
      strm.fputb(value)
      return num+1
    end
    strm.fputb(0x80|(value&0x7F))
    value >>= 7
    num += 1
  end
end

def decodeInt(strm)
  bits    = 0
  curbyte = 0
  ret = 0
  begin
    curbyte = strm.fgetb
    ret += (curbyte&0x7F)<<bits
    bits += 7
  end while ((curbyte&0x80)>0)&&bits<0x1d
  return ret
end

def strSize(str)
  return str.length+intSize(str.length)
end

def encodeString(strm,str)
  encodeInt(strm,str.length)
  strm.write(str)
end

def decodeString(strm)
  len = decodeInt(strm)
  return strm.read(len)
end

def strsplit(str,re)
  ret = []
  tstr = str
  while re=~tstr
    ret[ret.length] = $~.pre_match
    tstr = $~.post_match
  end
  ret[ret.length] = tstr if ret.length
  return ret
end

def canonicalize(c)
  csplit = strsplit(c,/[\/\\]/)
  pos = -1
  ret = []
  retstr = ""
  for x in csplit
    if x=="."
    elsif x==".."
      ret.delete_at(pos) if pos>=0
      pos -= 1
    else
      ret.push(x)
      pos += 1
    end
  end
  for i in 0...ret.length
    retstr += "/" if i>0
    retstr += ret[i]
  end
  return retstr
end

def frozenArrayValue(arr)
  typestring = ""
  for i in 0...arr.length
    if i>0
      typestring += ((i%20)==0) ? ",\r\n" : ","
    end
    typestring += arr[i].to_s
  end
  return "["+typestring+"].freeze"
end

#===============================================================================
# Enum const manipulators and parsers
#===============================================================================
def pbGetConst(mod,item,err)
  isDef = false
  begin
    isDef = mod.const_defined?(item.to_sym)
  rescue
    raise sprintf(err,item)
  end
  raise sprintf(err,item) if !isDef
  return mod.const_get(item.to_sym)
end

def getConstantName(mod,value)
  for c in mod.constants
    return c if mod.const_get(c.to_sym)==value
  end
  raise _INTL("Value {1} not defined by a constant in {2}",value,mod.name)
end

def getConstantNameOrValue(mod,value)
  for c in mod.constants
    return c if mod.const_get(c.to_sym)==value
  end
  return value.inspect
end

def setConstantName(mod,value,name)
  for c in mod.constants
    mod.send(:remove_const,c.to_sym) if mod.const_get(c.to_sym)==value
  end
  mod.const_set(name,value)
end

def removeConstantValue(mod,value)
  for c in mod.constants
    mod.send(:remove_const,c.to_sym) if mod.const_get(c.to_sym)==value
  end
end

def parseItem(item)
  clonitem = item.upcase
  clonitem.sub!(/^\s*/,"")
  clonitem.sub!(/\s*$/,"")
  return pbGetConst(PBItems,clonitem,_INTL("Undefined item constant name: %s\r\nName must consist only of letters, numbers, and\r\nunderscores and can't begin with a number.\r\nMake sure the item is defined in\r\nPBS/items.txt.\r\n{1}",FileLineData.linereport))
end

def parseSpecies(item)
  clonitem = item.upcase
  clonitem.gsub!(/^[\s\n]*/,"")
  clonitem.gsub!(/[\s\n]*$/,"")
  clonitem = "NIDORANmA" if clonitem=="NIDORANMA"
  clonitem = "NIDORANfE" if clonitem=="NIDORANFE"
  return pbGetConst(PBSpecies,clonitem,_INTL("Undefined species constant name: [%s]\r\nName must consist only of letters, numbers, and\r\nunderscores and can't begin with a number.\r\nMake sure the name is defined in\r\nPBS/pokemon.txt.\r\n{1}",FileLineData.linereport))
end

def parseMove(item)
  clonitem = item.upcase
  clonitem.sub!(/^\s*/,"")
  clonitem.sub!(/\s*$/,"")
  return pbGetConst(PBMoves,clonitem,_INTL("Undefined move constant name: %s\r\nName must consist only of letters, numbers, and\r\nunderscores and can't begin with a number.\r\nMake sure the name is defined in\r\nPBS/moves.txt.\r\n{1}",FileLineData.linereport))
end

def parseNature(item)
  clonitem = item.upcase
  clonitem.sub!(/^\s*/,"")
  clonitem.sub!(/\s*$/,"")
  return pbGetConst(PBNatures,clonitem,_INTL("Undefined nature constant name: %s\r\nName must consist only of letters, numbers, and\r\nunderscores and can't begin with a number.\r\nMake sure the name is defined in\r\nthe script section PBNatures.\r\n{1}",FileLineData.linereport))
end

def parseTrainer(item)
  clonitem = item.clone
  clonitem.sub!(/^\s*/,"")
  clonitem.sub!(/\s*$/,"")
  return pbGetConst(PBTrainers,clonitem,_INTL("Undefined Trainer constant name: %s\r\nName must consist only of letters, numbers, and\r\nunderscores and can't begin with a number.\r\nIn addition, the name must be defined\r\nin trainertypes.txt.\r\n{1}",FileLineData.linereport))
end

#===============================================================================
# Scripted constants
#===============================================================================
def pbFindScript(a,name)
  a.each { |i|
    next if !i
    return i if i[1]==name
  }
  return nil
end

def pbAddScript(script,sectionname)
  begin
    scripts = load_data("Data/Constants.rxdata")
    scripts = [] if !scripts
  rescue
    scripts = []
  end
  if false   # s
    s = pbFindScript(scripts,sectionname)
    s[2]+=Zlib::Deflate.deflate("#{script}\r\n")
  else
    scripts.push([rand(100000000),sectionname,Zlib::Deflate.deflate("#{script}\r\n")])
  end
  save_data(scripts,"Data/Constants.rxdata")
end



#===============================================================================
# Serial record
#===============================================================================
class SerialRecord < Array
  def bytesize
    return SerialRecord.bytesize(self)
  end

  def encode(strm)
    return SerialRecord.encode(self,strm)
  end

  def self.bytesize(arr)
    ret = 0
    return 0 if !arr
    for field in arr
      if field==nil || field==true || field==false
        ret += 1
      elsif field.is_a?(String)
        ret += strSize(field)+1
      elsif field.is_a?(Numeric)
        ret += intSize(field)+1
      end
    end
    return ret
  end

  def self.encode(arr,strm)
    return if !arr
    for field in arr
      if field==nil
        strm.write("0")
      elsif field==true
        strm.write("T")
      elsif field==false
        strm.write("F")
      elsif field.is_a?(String)
        strm.write("\"")
        encodeString(strm,field)
      elsif field.is_a?(Numeric)
        strm.write("i")
        encodeInt(strm,field)
      end
    end
  end

  def self.decode(strm,offset,length)
    ret = SerialRecord.new
    strm.pos = offset
    while strm.pos<offset+length
      datatype = strm.read(1)
      case datatype
      when "0"; ret.push(nil)
      when "T"; ret.push(true)
      when "F"; ret.push(false)
      when "\""; ret.push(decodeString(strm))
      when "i"; ret.push(decodeInt(strm))
      end
    end
    return ret
  end
end



def readSerialRecords(filename)
  ret = []
  return ret if !pbRgssExists?(filename)
  pbRgssOpen(filename,"rb") { |file|
    numrec = file.fgetdw>>3
    curpos = 0
    numrec.times do
      file.pos = curpos
      offset = file.fgetdw
      length = file.fgetdw
      record = SerialRecord.decode(file,offset,length)
      ret.push(record)
      curpos += 8
    end
  }
  return ret
end

def writeSerialRecords(filename,records)
  File.open(filename,"wb") { |file|
    totalsize = records.length*8
    for record in records
      file.fputdw(totalsize)
      bytesize = record.bytesize
      file.fputdw(bytesize)
      totalsize += bytesize
    end
    for record in records
      record.encode(file)
    end
  }
end



#===============================================================================
# Data structures
#===============================================================================
class ByteArray
  include Enumerable

  def initialize(data=nil)
    @a = (data) ? data.unpack("C*") : []
  end

  def [](i); return @a[i]; end
  def []=(i,value); @a[i] = value; end

  def length; @a.length; end
  def size; @a.size; end

  def fillNils(length,value)
    for i in 0...length
      @a[i] = value if !@a[i]
    end
  end

  def each
    @a.each { |i| yield i}
  end

  def self._load(str)
    return self.new(str)
  end

  def _dump(_depth=100)
    return @a.pack("C*")
  end
end



class WordArray
  include Enumerable

  def initialize(data=nil)
    @a = (data) ? data.unpack("v*") : []
  end

  def [](i); return @a[i]; end
  def []=(i,value); @a[i] = value; end

  def length; @a.length; end
  def size; @a.size; end

  def fillNils(length,value)
    for i in 0...length
      @a[i] = value if !@a[i]
    end
  end

  def each
    @a.each { |i| yield i}
  end

  def self._load(str)
    return self.new(str)
  end

  def _dump(_depth=100)
    return @a.pack("v*")
  end
end



class SignedWordArray
  include Enumerable

  def initialize(data=nil)
    @a = (data) ? data.unpack("v*") : []
  end

  def []=(i,value)
    @a[i] = value
  end

  def [](i)
    v = @a[i]
    return 0 if !v
    return (v<0x8000) ? v : -((~v)&0xFFFF)-1
  end

  def length; @a.length; end
  def size; @a.size; end

  def fillNils(length,value)
    for i in 0...length
      @a[i] = value if !@a[i]
    end
  end

  def each
    @a.each { |i| yield i}
  end

  def self._load(str)
    return self.new(str)
  end

  def _dump(_depth=100)
    return @a.pack("v*")
  end
end



#===============================================================================
# Compile all data
#===============================================================================
def pbCompileAllData(mustCompile)
  FileLineData.clear
  if mustCompile
    if (!$INEDITOR || LANGUAGES.length<2) && pbRgssExists?("Data/messages.dat")
      MessageTypes.loadMessageFile("Data/messages.dat")
    end
    # No dependencies
    yield(_INTL("Compiling type data"))
    pbCompileTypes
    # No dependencies
    yield(_INTL("Compiling town map data"))
    pbCompileTownMap
    # No dependencies
    yield(_INTL("Compiling map connection data"))
    pbCompileConnections
    # No dependencies
    yield(_INTL("Compiling ability data"))
    pbCompileAbilities
    # Depends on PBTypes
    yield(_INTL("Compiling move data"))
    pbCompileMoves
    # Depends on PBMoves
    yield(_INTL("Compiling item data"))
    pbCompileItems
    # Depends on PBItems
    yield(_INTL("Compiling berry plant data"))
    pbCompileBerryPlants
    # Depends on PBMoves, PBItems, PBTypes, PBAbilities
    yield(_INTL("Compiling Pokémon data"))
    pbCompilePokemonData
    # Depends on PBSpecies, PBMoves
    yield(_INTL("Compiling Pokémon forms data"))
    pbCompilePokemonForms
    # Depends on PBSpecies, PBMoves
    yield(_INTL("Compiling machine data"))
    pbCompileMachines
    # No dependencies
    yield(_INTL("Compiling Trainer type data"))
    pbCompileTrainerTypes
    # Depends on PBSpecies, PBItems, PBMoves
    yield(_INTL("Compiling Trainer data"))
    pbCompileTrainers
    # Depends on PBTrainers
    yield(_INTL("Compiling phone data"))
    pbCompilePhoneData
    # Depends on PBTrainers
    yield(_INTL("Compiling metadata"))
    pbCompileMetadata
    # Depends on PBTrainers
    yield(_INTL("Compiling battle Trainer data"))
    pbCompileTrainerLists
    # Depends on PBSpecies
    yield(_INTL("Compiling encounter data"))
    pbCompileEncounters
    # Depends on PBSpecies, PBMoves
    yield(_INTL("Compiling shadow move data"))
    pbCompileShadowMoves
    yield(_INTL("Compiling messages"))
    pbCompileAnimations
    pbCompileTrainerEvents(mustCompile)
    pbSetTextMessages
    MessageTypes.saveMessages
  else
    if (!$INEDITOR || LANGUAGES.length<2) && safeExists?("Data/messages.dat")
      MessageTypes.loadMessageFile("Data/messages.dat")
    end
  end
  if !$INEDITOR && LANGUAGES.length>=2
    pbLoadMessages("Data/"+LANGUAGES[$PokemonSystem.language][1])
  end
end

def pbCompiler
  return if !$DEBUG
  begin
    dataFiles = [
       "berry_plants.dat",
       "encounters.dat",
       "form2species.dat",
       "items.dat",
       "map_connections.dat",
       "metadata.dat",
       "moves.dat",
       "phone.dat",
       "regional_dexes.dat",
       "shadow_movesets.dat",
       "species.dat",
       "species_eggmoves.dat",
       "species_evolutions.dat",
       "species_metrics.dat",
       "species_movesets.dat",
       "tm.dat",
       "town_map.dat",
       "trainer_lists.dat",
       "trainer_types.dat",
       "trainers.dat",
       "types.dat",
       "Constants.rxdata"
    ]
    textFiles = [
       "abilities.txt",
       "berryplants.txt",
       "connections.txt",
       "encounters.txt",
       "items.txt",
       "metadata.txt",
       "moves.txt",
       "phone.txt",
       "pokemon.txt",
       "pokemonforms.txt",
       "shadowmoves.txt",
       "tm.txt",
       "townmap.txt",
       "trainerlists.txt",
       "trainers.txt",
       "trainertypes.txt",
       "types.txt"
    ]
    latestDataTime = 0
    latestTextTime = 0
    mustCompile = false
    # Should recompile if new maps were imported
    mustCompile |= pbImportNewMaps
    # Should recompile if no existing data is found
    mustCompile |= !(PBSpecies.respond_to?("maxValue") rescue false)
    # If no PBS file, create one and fill it, then recompile
    if !safeIsDirectory?("PBS")
      Dir.mkdir("PBS") rescue nil
      pbSaveAllData
      mustCompile = true
    end
    # Check data files and PBS files, and recompile if any PBS file was edited
    # more recently than the data files were last created
    for i in 0...dataFiles.length
      begin
        File.open("Data/#{dataFiles[i]}") { |file|
          latestDataTime = [latestDataTime,file.mtime.to_i].max
        }
      rescue SystemCallError
        mustCompile = true
      end
    end
    for i in 0...textFiles.length
      begin
        File.open("PBS/#{textFiles[i]}") { |file|
          latestTextTime = [latestTextTime,file.mtime.to_i].max
        }
      rescue SystemCallError
      end
    end
    mustCompile |= (latestTextTime>=latestDataTime)
    # Should recompile if holding Ctrl
    Input.update
    mustCompile = true if Input.press?(Input::CTRL)
    # Delete old data files in preparation for recompiling
    if mustCompile
      for i in 0...dataFiles.length
        begin
          File.delete("Data/#{dataFiles[i]}")
        rescue SystemCallError
        end
      end
    end
    # Recompile all data
    pbCompileAllData(mustCompile) { |msg| Win32API.SetWindowText(msg) }
  rescue Exception
    e = $!
    raise e if "#{e.class}"=="Reset" || e.is_a?(Reset) || e.is_a?(SystemExit)
    pbPrintException(e)
    for i in 0...dataFiles.length
      begin
        File.delete("Data/#{dataFiles[i]}")
      rescue SystemCallError
      end
    end
    raise Reset.new if e.is_a?(Hangup)
    loop do
      Graphics.update
    end
  end
end
