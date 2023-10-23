class Bitmap
  def outline_rect(x, y, width, height, color, thickness = 1)
    fill_rect(x, y, width, thickness, color)
    fill_rect(x, y, thickness, height, color)
    fill_rect(x, y + height - thickness, width, thickness, color)
    fill_rect(x + width - thickness, y, thickness, height, color)
  end

  def fill_diamond(x, y, radius, color)
    ((radius * 2) + 1).times do |i|
      height = (i <= radius) ? (i * 2) + 1 : (((radius * 2) - i) * 2) + 1
      fill_rect(x - radius + i, y - ((height - 1) / 2), 1, height, color)
    end
  end

  # TODO: Add more curve types once it's decided which ones they are.
  def draw_interpolation_line(x, y, width, height, gradient, type, color)
    case type
    when :linear
      # NOTE: https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm
      start_x = x
      end_x = x + width - 1
      start_y = (gradient) ? y + height - 1 : y
      end_y = (gradient) ? y : y + height - 1
      dx = end_x - start_x
      dy = -((end_y - start_y).abs)
      error = dx + dy
      draw_x = start_x
      draw_y = start_y
      loop do
        fill_rect(draw_x, draw_y, 1, 1, color)
        break if draw_x == end_x && draw_y == end_y
        e2 = 2 * error
        if e2 >= dy
          break if draw_x == end_x
          error += dy
          draw_x += 1
        end
        if e2 <= dx
          break if draw_y == end_y
          error += dx
          draw_y += (gradient) ? -1 : 1
        end
      end
    end
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
