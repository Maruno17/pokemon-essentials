PluginManager.register({
  :name => "Marin's Compiler",
  :version => "1.2",
  :credits => "Marin",
  :link => "https://reliccastle.com/resources/182/"
})

class MarinCompilerError < Exception; end

module MarinCompiler
  Files = []
    
  @error_mode = :comma
  def self.error_mode; @error_mode; end
  def self.error_mode=(v); @error_mode = v; end
  
  def self.register(pbsfile, datafile, compile, load, decompile = nil)
    Files << [pbsfile, datafile, compile, load, decompile]
  end
  
  def self.compile_where_necessary
    Input.update
    Files.each do |f|
      compile = false
      if !File.file?("PBS/#{f[0]}")
        MarinCompiler.decompile(f[0].split('.')[0..-2])
      end
      if !File.file?("PBS/#{f[0]}")
        if !File.file?("Data/#{f[1]}")
          p_err MarinCompilerError, "PBS file '#{f[0]}' couldn't be found, and no data file could be loaded or decompiled."
        else
          next
        end
      end
      pt = File.mtime("PBS/#{f[0]}").to_i
      if File.file?("Data/#{f[1]}")
        dt = File.mtime("Data/#{f[1]}").to_i
        compile = true if pt > dt
      else
        compile = true
      end
      compile = true if Input.press?(Input::SHIFT)
      MarinCompiler.compile(f[0].split('.')[0..-2]) if compile
    end
  end
  
  def self.error(str, section = nil, line = nil, format = nil)
    error = "#{str}\n\nIn: #{@active_file[4..-1]}\n"
    if section.is_a?(Numeric)
      error << "Section: #{section}\n"
    elsif section.is_a?(Array)
      if section[0]
        error << "Section: #{section[0]} (#{section[1].empty? ? "nil" : section[1]})\n"
      else
        error << "Section: #{section[1]}\n"
      end
    end
    if format
      error << "Format: #{format}\n"
    end
    if line.is_a?(Numeric)
      error << "Line: #{line}\n"
    elsif line.is_a?(Array)
      error << "Line: #{line[0]} (#{line[1].empty? ? "nil" : line[1]})\n"
    end
    p_err MarinCompilerError, error
  end
  
  def self.compile(file = nil)
    file ||= @active_file.split('/')[1].split('.')[0..-2].join('.') if @active_file
    ret = nil
    Files.each do |f|
      next unless file.nil? || f[0].split('.')[0..-2].join('.') == file.to_s
      old_active_file = @active_file
      old_active_data_file = @active_data_file
      @active_file = "PBS/#{f[0]}"
      @active_data_file = "Data/#{f[1]}"
      ret = self.instance_eval &f[2]
      @active_file = old_active_file
      @active_data_file = old_active_data_file
    end
    return ret
  end
  
  def self.load(file = nil)
    file ||= @active_file.split('/')[1].split('.')[0..-2].join('.') if @active_file
    ret = nil
    Files.each do |f|
      next unless file.nil? || f[0].split('.')[0..-2].join('.') == file.to_s
      old_active_file = @active_file
      old_active_data_file = @active_data_file
      @active_file = "PBS/#{f[0]}"
      @active_data_file = "Data/#{f[1]}"
      ret = self.instance_eval &f[3]
      @active_file = old_active_file
      @active_data_file = old_active_data_file
    end
    return ret
  end
  
  def self.decompile(file = nil)
    file ||= @active_file.split('/')[1].split('.')[0..-2].join('.') if @active_file
    ret = nil
    Files.each do |f|
      next unless file.nil? || f[0].split('.')[0..-2].join('.') == file.to_s
      next if f[4].nil?
      old_active_file = @active_file
      old_active_data_file = @active_data_file
      @active_file = "PBS/#{f[0]}"
      @active_data_file = "Data/#{f[1]}"
      ret = self.instance_eval &f[4]
      @active_file = old_active_file
      @active_data_file = old_active_data_file
    end
    return ret
  end
  
  def self.window_text(text)
    Win32API.SetWindowText(text)
  end
  
  def self.comma_based(format, *options)
    MarinCompiler.error_mode = :comma
    filename = @active_file.split('/')[-1]
    MarinCompiler.window_text("Compiling #{filename}")
    start = Time.now
    data = ""
    File.open(@active_file, "rb") do |f|
      while chunk = f.read(4096)
        data << chunk
        if Time.now - start > 3
          Graphics.update
          start = Time.now
        end
      end
    end
    data = data.split("\n")
    if format == "*"
      MarinCompiler.error("Compiler format cannot contain an asterisk without a type before it", nil, nil, format)
    elsif format.include?('*')
      asterisk = true
      if format.split("")[-1] != '*'
        MarinCompiler.error("Compiler format can only contain an asterisk at the very end", nil, nil, format)
      elsif format.scan(/\*/).size > 1
        MarinCompiler.error("Compiler format can only contain one asterisk", nil, nil, format)
      end
    end
    format = format.split("")
    optional = false
    for i in 0...format.size
      if format[i][/[A-Z*]/]
        optional = i
      elsif optional
        MarinCompiler.error("Cannot have mandatory fields after optional fields in compiler format!", nil, nil, format)
      end
      if optional == 0
        MarinCompiler.error("Compiler format must contain at least 1 mandatory field", nil, nil, format)
      end
    end
    compile = proc do |l, lIdx|
      MarinCompiler.window_text("Compiling #{filename} line #{lIdx}")
      l = l.chomp
      l = l.split("")
      l = l[1..-1] if l[0][0] == 239
      l = l.join("")
      next if l.gsub(/ /,"").starts_with?('#') ||
              l.gsub(/[ \r]/,"").starts_with?("\n")
      sections = []
      instring = false
      commaIdx = 0
      l = l.split("")
      for i in 0...l.size
        c = l[i]
        if c == '"'
          if i > 0
            if l[i - 1] != "\\"
              instring = !instring
            end
          else
            instring = !instring
          end
        end
        if c == ',' && !instring
          sections << l[commaIdx...i].join("")
          commaIdx = i + 1
        end
      end
      l = l.join("")
      sections << l[commaIdx..-1]
      lErr = [lIdx + 1, l]
      reqformat = format.join("").gsub(/[A-Z*]/,"")
      if !asterisk && sections.size > format.size
        extra = sections.size - format.size
        if extra == 1 && sections[-1] == ""
          sections.delete_at(-1)
        else
          MarinCompiler.error("Line has #{extra} section#{extra > 1 ? "s" : ""} too many!", nil, lErr, format)
        end
      elsif sections.size < reqformat.size
        missing = reqformat.size - sections.size
        MarinCompiler.error("Line is missing #{missing} section#{missing > 1 ? "s" : ""}!", nil, lErr, format)
      end
      for i in 0...sections.size
        if Time.now - start > 3
          Graphics.update
          start = Time.now
        end
        s = sections[i]
        o = options[i]
        f = format[i]
        if f == '*' || f.nil? && asterisk
          f = format[-2]
          o = options[format.size - 2]
        end
        sErr = [i + 1, s]
        if f
          s = MarinCompiler.check_field(s, f, o, sErr, lErr, format)
        end
        sections[i] = s
      end
      next sections
    end
    begin
      data.each_with_index do |l,lIdx|
        v = compile.call(l, lIdx)
        yield v if v
      end
    rescue
      p_err
    end
  end
  
  def self.check_field(s, f, o = nil, sErr = nil, lErr = nil, format = nil)
    errors = !(sErr.nil? && lErr.nil?)
    case f
    when "s", "S" # String
      s = s[1..-2] if s.split("")[0] == '"' && s.split("")[-1] == '"'
      if o.is_a?(Range)
        if !o.include?(s.size)
          if s.size < o.begin && errors
            MarinCompiler.error("String is too short (#{s.size} characters, Range #{o})", sErr, lErr, format)
          elsif errors
            MarinCompiler.error("String is too long (#{s.size} characters, Range #{o})", sErr, lErr, format)
          else
            return nil
          end
        end
      end
    when "i", "I" # Integer
      if s.numeric?
        s = s.to_i
        if (o.is_a?(Range) || o.is_a?(Array)) && !o.include?(s)
          MarinCompiler.error("Integer falls out of range (#{o.inspect})", sErr, lErr, format)
        end
      elsif o && errors
        MarinCompiler.error("Invalid Integer (#{o})", sErr, lErr, format)
      elsif errors
        MarinCompiler.error("Invalid Integer", sErr, lErr, format)
      else
        return nil
      end
    when "e", "E" # Enumerable
      unless s.nil? || s.empty?
        s = s[1..-2] if s.split("")[0] == '"' && s.split("")[-1] == '"'
        if o.nil?
          MarinCompiler.error("Compile format specifies an Enumerable but is missing possible values for that Enumerable.", nil, nil, format)
        elsif o.is_a?(Array)
          if !o.include?(s)
            if s.numeric?
              if !o.include?(s.to_i)
                if errors
                  MarinCompiler.error("Invalid value for Enumerable (#{o.inspect})", sErr, lErr, format)
                else
                  return nil
                end
              end
            else
              MarinCompiler.error("Invalid value for Enumerable (#{o.inspect})", sErr, lErr, format)
            end
          end
        elsif o.is_a?(Module) || o.is_a?(Class)
          const = o.constants
          if const.include?(s)
            s = o.const_get(s)
          elsif const.include?(s.to_sym)
            s = o.const_get(s.to_sym)
          else
            values = const.map { |e| o.const_get(e) }
            if values.include?(s)
            elsif s.numeric? && values.include?(s.to_i)
              s = s.to_i
            elsif errors
              MarinCompiler.error("Invalid value for Module/Class #{o}", sErr, lErr, format)
            else
              return nil
            end
          end
        elsif o.is_a?(Hash)
          if o[s]
            s = o[s]
          elsif o[s.to_sym]
            s = o[s.to_sym]
          else
            values = o.keys.map { |e| o[e] }
            if values.include?(s)
            elsif values.include?(s.to_i)
              s = s.to_i
            elsif errors
              MarinCompiler.error("Invalid value for Enumerable (#{o.keys.sort.inspect})", sErr, lErr, format)
            else
              return nil
            end
          end
        end
      end
    when "b", "B" # Boolean
      s = s[1..-2] if s.split("")[0] == '"' && s.split("")[-1] == '"'
      case s
      when "true","TRUE","Y","Yes","y","yes","YES","1"
        s = true
      when "false","FALSE","N","No","n","no","NO","0"
        s = false
      else
        if errors
          MarinCompiler.error("Value is not a boolean (true/false)", sErr, lErr, format)
        else
          return nil
        end
      end
    when "c", "C" # Internal Name/Constant
      if !s.split("")[0][/[A-Z]/]
        if errors
          MarinCompiler.error("Constants must start with an uppercase letter", sErr, lErr, format)
        else
          return nil
        end
      end
      if "-=+[]{}()!@\#$%^&*~`'\":;/?.,<>\\ ".split("").any? { |e| s.include?(e) }
        if errors
          MarinCompiler.error("Invalid Constant", sErr, lErr, format)
        else
          return nil
        end
      end
      s = s.to_sym
    when "h", "H" # Hexadecimal
      s = s[2..-1] if s[0..1] == "0x"
      s.split("").each do |e|
        if !"0123456789ABCDEF".include?(e)
          if errors
            MarinCompiler.error("Invalid Hexadecimal", sErr, lErr, format)
          else
            return nil
          end
        end
      end
      s = s.to_i(16)
      if o.is_a?(Array)
        if !o.include?(s)
          if errors
            MarinCompiler.error("Hexadecimal falls out of range (#{o.inspect})", sErr, lErr, format)
          else
            return nil
          end
        end
      end
    when "f", "F" # Float
      s = s.gsub(/ /,"")
      if s.include?('.')
        if s.scan(/\./).size > 1
          MarinCompiler.error("Invalid Float or Integer", sErr, lErr, format)
        else
          l, r = s.split('.')
          if l.numeric? && r.numeric?
            s = eval("#{l}.#{r}")
          else
            MarinCompiler.error("Invalid Float or Integer", sErr, lErr, format)
          end
        end
      elsif s.numeric?
        s = s.to_f
      elsif errors
        MarinCompiler.error("Invalid Float or Integer", sErr, lErr, format)
      end
    end
    return s
  end
  
  def self.save_file(data)
    save_data(data, @active_data_file)
  end
  
  def self.load_file
    return load_data(@active_data_file)
  end
  
  def self.section_based(*args)
    MarinCompiler.error_mode = :section
    header = args[0]
    hoptions = args[1..-2]
    fields = args[-1]
    fkeys = []
    fields.keys.each do |key|
      fkeys << key if key.is_a?(String)
      key.each { |e| fkeys << e } if key.is_a?(Array)
    end
    reqkeys = []
    fkeys.each do |key|
      if fields[key].is_a?(String)
        if fields[key][/[a-z]/]
          reqkeys << key
        end
      elsif fields[key].is_a?(Array)
        if fields[key][0][/[a-z]/]
          reqkeys << key
        end
      end
    end
    fkeys.map { |e| e.split("") }.each do |e|
      if e[0] == ' ' || e[-1] == ' '
        MarinCompiler.error("Section field keys cannot start or end with spaces (#{e})")
      end
    end
    fkeys.each do |e|
      if e.include?('=')
        MarinCompiler.error("Section field keys cannot include equal signs (#{e})")
      end
    end
    filename = @active_file.split('/')[-1]
    MarinCompiler.window_text("Compiling #{filename}")
    start = Time.now
    data = ""
    File.open(@active_file, "rb") do |f|
      while chunk = f.read(4096)
        data << chunk
        if Time.now - start > 3
          Graphics.update
          start = Time.now
        end
      end
    end
    data = data.split("\n")
    if header == "*"
      MarinCompiler.error("Header compiler format cannot contain an asterisk without a type before it", nil, nil, header)
    elsif header.include?('*')
      asterisk = true
      if header.split("")[-1] != '*'
        MarinCompiler.error("Header compiler format can only contain an asterisk at the very end", nil, nil, header)
      elsif header.scan(/\*/).size > 1
        MarinCompiler.error("Header compiler format can only contain one asterisk", nil, nil, header)
      end
    end
    header = header.split("")
    optional = false
    for i in 0...header.size
      if header[i][/[A-Z*]/]
        optional = i
      elsif optional
        MarinCompiler.error("Cannot have mandatory fields after optional fields in header compiler format!", nil, nil, header)
      end
      if optional == 0
        MarinCompiler.error("Header compiler format must contain at least 1 mandatory field", nil, nil, header)
      end
    end
    sections = {}
    last_section = nil
    last_raw_section = nil
    last_section_line = nil
    
    compile = proc do |l, lIdx|
      if lIdx % 20 == 0
        perc = (lIdx / data.size.to_f * 100.0).round
        MarinCompiler.window_text("Compiling #{filename} line #{lIdx} (#{perc}%)")
      end
      l = l.chomp
      l = l.split("")
      l = l[1..-1] if l && l[0] && l[0][0] == 239
      l = l.join("")
      next nil if l.empty? ||
                  l.gsub(/ /,"").starts_with?('#') ||
                  l.gsub(/[ \r]/,"").starts_with?("\n")
      
      lErr = [lIdx + 1, l]
      
      if l[/\[.*?(\])/] == l # If this line is a valid header
        if sections.size > 0
          skeys = sections[last_section].keys
          reqkeys.each do |e|
            unless skeys.include?(e)
              MarinCompiler.error("Section is missing a mandatory field (#{e})",
                  [nil, '[' + last_raw_section + ']'], last_section_line + 1)
            end
          end
          yield [last_section,sections[last_section]]
        end
        hsections = []
        instring = false
        commaIdx = 0
        l = l[1..-2].split("")
        for i in 0...l.size
          c = l[i]
          if c == '"'
            if i > 0
              if l[i - 1] != "\\"
                instring = !instring
              end
            else
              instring = !instring
            end
          end
          if c == ',' && !instring
            hsections << l[commaIdx...i].join("")
            commaIdx = i + 1
          end
        end
        l = l.join("")
        hsections << l[commaIdx..-1]
        asterisk = header.include?('*')
        reqheader = header.join("").gsub(/[A-Z*]/,"")
        if !asterisk && hsections.size > header.size
          extra = hsections.size - header.size
          if extra == 1 && hsections[-1] == ""
            hsections.delete_at(-1)
          else
            MarinCompiler.error("Section header contains #{extra} section#{extra > 1 ? "s" : ""} too many!", nil, lErr, header)
          end
        elsif hsections.size < reqheader.size
          missing = reqheader.size - hsections.size
          MarinCompiler.error("Section header is missing #{missing} section#{missing > 1 ? "s" : ""}!", nil, lErr, header)
        end
        hsections.each_with_index do |s,i|
          s = hsections[i]
          f = header[i]
          o = hoptions[i]
          if f == '*' || f.nil? && header[-1] == '*'
            f = header[-2]
            o = hoptions[-2]
          end
          sErr = [i + 1, s]
          s = MarinCompiler.check_field(s, f, o, sErr, lErr, header)
          hsections[i] = s
        end
        last_raw_section = l
        if hsections.size > 1
          sections[hsections] = {}
          last_section = hsections
        elsif hsections.size == 1
          sections[hsections[0]] = {}
          last_section = hsections[0]
        end
        last_section_line = lIdx
      elsif sections.size == 0
        MarinCompiler.error("First section does not contain a header")
      elsif !l.empty? && !l.gsub(/ /,"").starts_with?("#")
        lErr = [lIdx + 1, l]
        sErr = [nil, '[' + last_raw_section + ']']
        lsplit = l.split('=')
        key = lsplit[0].split("")
        key.delete_at(0) while key[0] == ' ' || key[0] == "\t"
        key.delete_at(-1) while key[-1] == ' ' || key[-1] == "\t"
        key = key.join("")
        unless fkeys.include?(key)
          MarinCompiler.error("Invalid key (#{key})", sErr, lErr)
        end
        value = lsplit[1..-1].join('=').split("")
        value.delete_at(0) while value[0] == ' '
        realkey = nil
        format = nil
        foptions = []
        fields.each do |e,v|
          if e == key || e.is_a?(Array) && e.include?(key)
            realkey = e
            if v.is_a?(Array)
              format = v[0]
              foptions = v[1..-1]
            else
              format = v
            end
          end
        end
        format = format.split("")
        fsections = []
        instr = false
        commaIdx = 0
        for i in 0...value.size
          c = value[i]
          if c == '"'
            if i > 0
              if l[i - 1] != "\\"
                instr = !instr
              end
            else
              instr = !instr
            end
          end
          if c == ',' && !instr
            fsections << value[commaIdx...i].join("")
            commaIdx = i + 1
          end
        end
        value = value.join("")
        fsections << value[commaIdx..-1]
        reqformat = format.join("").gsub(/[A-Z*]/,"")
        asterisk = format.include?('*')
        if !asterisk && fsections.size > format.size
          extra = fsections.size - format.size
          if extra == 1 && fsections[-1] == ""
            hsections.delete_at(-1)
          else
            MarinCompiler.error("Field contains #{extra} section#{extra > 1 ? "s" : ""} too many!", sErr, lErr, format)
          end
        elsif fsections.size < reqformat.size
          missing = reqformat.size - fsections.size
          MarinCompiler.error("Field is missing #{missing} section#{missing > 1 ? "s" : ""}!", sErr, lErr, format)
        end
        fsections.each_with_index do |s,i|
          s = fsections[i]
          f = format[i]
          o = foptions[i]
          if f == '*' || f.nil? && format[-1] == '*'
            f = format[-2]
            if foptions.size == 1
              o = foptions[-1]
            else
              o = foptions[-2]
            end
          end
          sErr = [i + 1, s]
          s = MarinCompiler.check_field(s, f, o, sErr, lErr)
          fsections[i] = s
        end
        fsections = fsections[0] if fsections.size == 1
        if sections[last_section][realkey]
          sErr = [nil, '[' + last_raw_section + ']']
          MarinCompiler.error("Section already contains a field with this key!", sErr, lErr)
        else
          sections[last_section][realkey] = fsections
        end
      end
      next nil
    end
    begin
      data.each_with_index { |l,lIdx| v = compile.call(l, lIdx); yield *v if v }
      yield [last_section,sections[last_section]] if sections[last_section]
    rescue
      p_err
    end
  end
end

alias marin_compiler_pbCompiler pbCompiler
def pbCompiler
  marin_compiler_pbCompiler
  MarinCompiler.compile_where_necessary
  MarinCompiler.load
end