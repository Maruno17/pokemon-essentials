#===============================================================================
# String formatting, conversion of value to string
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
# Enum const manipulators and parsers
#===============================================================================
def getConstantName(mod,value)
  mod = Object.const_get(mod) if mod.is_a?(Symbol)
  for c in mod.constants
    return c if mod.const_get(c.to_sym)==value
  end
  raise _INTL("Value {1} not defined by a constant in {2}",value,mod.name)
end

def getConstantNameOrValue(mod,value)
  mod = Object.const_get(mod) if mod.is_a?(Symbol)
  for c in mod.constants
    return c if mod.const_get(c.to_sym)==value
  end
  return value.inspect
end

def setConstantName(mod,value,name)
  mod = Object.const_get(mod) if mod.is_a?(Symbol)
  for c in mod.constants
    mod.send(:remove_const,c.to_sym) if mod.const_get(c.to_sym)==value
  end
  mod.const_set(name,value)
end

def removeConstantValue(mod,value)
  mod = Object.const_get(mod) if mod.is_a?(Symbol)
  for c in mod.constants
    mod.send(:remove_const,c.to_sym) if mod.const_get(c.to_sym)==value
  end
end
