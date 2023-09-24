class Bitmap
  def outline_rect(x, y, width, height, color, thickness = 1)
    fill_rect(x, y, width, thickness, color)
    fill_rect(x, y, thickness, height, color)
    fill_rect(x, y + height - thickness, width, thickness, color)
    fill_rect(x + width - thickness, y, thickness, height, color)
  end
end

#===============================================================================
# Fixed Compiler.pbWriteCsvRecord to make it detect enums first, allowing enum
# values to be turned into symbols/booleans/whatever instead of just numbers.
#===============================================================================
module Compiler
  module_function

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
              next if enumer[key] != value
              file.write(key)
              break
            end
          end
        when "y", "Y"   # Enumerable or integer
          enumer = schema[2 + i]
          case enumer
          when Array
            file.write((enumer[value].nil?) ? value : enumer[value])
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
end
