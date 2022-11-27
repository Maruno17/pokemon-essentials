require 'zlib'

class Numeric
  def to_digits(num = 3)
    str = to_s
    (num - str.size).times { str = str.prepend("0") }
    return str
  end
end

module Scripts
  def self.dump(path = "Data/Scripts", rxdata = "Data/Scripts.rxdata")
    scripts = File.open(rxdata, 'rb') { |f| Marshal.load(f) }
    if scripts.length < 10
      p "Scripts look like they're already extracted. Not doing so again."
      return
    end
	
    create_directory(path)
    clear_directory(path)
	
    folder_id = [1, 1]   # Can only have two layers of folders
    file_id = 1
    level = 0   # 0=main path, 1=subfolder, 2=sub-subfolder
    folder_path = path
    folder_name = nil
    scripts.each_with_index do |e, i|
      _, title, script = e
      title = title_to_filename(title).strip
      script = Zlib::Inflate.inflate(script).delete("\r")
      next if title.empty? && script.empty?

      section_name = nil
      if title[/\[\[\s*(.+)\s*\]\]$/]   # Make a folder
        section_name = $~[1].strip
        section_name = "unnamed" if !section_name || section_name.empty?
        folder_num =  (i < scripts.length - 2) ? folder_id[level].to_digits(3) : "999"
        folder_name = folder_num + "_" + section_name
        create_directory(folder_path + "/" + folder_name)
        folder_id[level] += 1
        if level < folder_id.length-1
          level += 1   # Go one level deeper
          folder_id[level] = 1   # Reset numbering of subfolders
          folder_path += "/" + folder_name
          folder_name = nil
        end
        file_id = 1   # Reset numbering of script files
      elsif title.start_with?("=====")   # Return to top level directory
        level = 0
        folder_path = path
        folder_name = nil
      end
      # Create script file
      next if script.empty?
      this_folder = folder_path
      this_folder += "/" + folder_name if folder_name
      section_name ||= title.strip
      section_name = "unnamed" if !section_name || section_name.empty?
      file_num =  (i < scripts.length - 1) ? file_id.to_digits(3) : "999"
      file_name = file_num + "_" + section_name + ".rb"
      create_script(this_folder + "/" + file_name, script)
      file_id += 1   # Increment numbering of script files
    end
    # Backup Scripts.rxdata to ScriptsBackup.rxdata
    File.open("Data/ScriptsBackup.rxdata", "wb") do |f|
      Marshal.dump(scripts, f)
    end
    # Replace Scripts.rxdata with ScriptsLoader.rxdata
    createLoaderScripts(rxdata)
  end

  def self.createLoaderScripts(rxdata)
#    loader_scripts = File.open("Data/ScriptsLoader.rxdata", 'rb') { |f| Marshal.load(f) }
#    p loader_scripts
	txt = "x\x9C}SM\x8F\xDA0\x10\xBD#\xF1\x1F\x86,Rb-2\xCB\xB1\x95\xE8\x1E\xBAm\xD5S\xAB\x85\e\xA0\xC8$\x13p7\xD8\x91\xED\x94n\t\xFF\xBD\xB6C0\xE9\xD7\xC5\xF2\xCCx\xDE\xCC\xBCy\xBE\x83\xE5\x9Ek\xC8%j\x10\xD2\xC0Q\xAA\x17\xE0\x05\x98=\xC2\x8E\x1D\x10l\x10E\xA6^+\x83\xF9h8\x18\x0Er\xB4Q\xC52\xDC\xB2\xEC%UXIe\x86\x03\x00gz?\xCCa<\xA2W\x93f\xA5\x14\xD8{A\x91e\xFB\x134[\xD38\xBF\x8D\x18\xAA\xEB\xED(\x99\xAEO\xC9:\xBF'\xEB\xF3\x94\xC0)Z\xDD\x9D\xC6\xB3\xF3\xC6\x9E\xCF\x9F\x16\x8Bt\xF1\xFE\xF9\xF3\xD7\xE5b5\x9EQ#S\xBEY\xCD6\xE7\xE8\xEC\x10\xFC\xA1\xD0\xD4J\xB8\xDA\a\xD4\x9A\xED\x10\xEE!Z\x8B\xB5\x88\xEC%\xD4\xFE&\xB9H\xAC?\"\xC3\x01\x8A\xBC\eI1\xAE1\r\x83\xA1RR9XKF\x80\xA4\x9A\xFFDx7\x877\x0F\x0Fm\xEB\x1Fy\x89TV(\x92\xF8\x9ALK\xB9\x8B'\x10\x1Fc;\x054E\x03\x05=*n0\x19\x8FH\xDB,\xB4\x05!^vI\x8Ei#%l\xF9\x8E\xC2\x97\xDAT\xB5\x01.\xA0\x0F\xEAR\xB1\xD4x\x03\xE1]n\x8E\x9BaJ\xC9\xF2Tg\x8AWF\xA7\x85\x92\x87\xB4\x90e\x8E*\xA9\x98\xD9\x13\x97Q\xD8\xB6\xB5\x85\x98\xC3j\xE3m\x1F\xD7W\xFB\x89+ZH\xE5\x16\xD5&Y\x89\xB8I\xDA\xC2\x02\x7F\x18GL\x01\xF39\xC44\x86\xA6\xE9\xEE4n\x9F$\x9E\x98\x9C+\xCC\x8CT\xAF\x8F\x1E\xC5md\xEA\xD6Q\x10\x02\x8F]QZ\xD5z\x9F\x14\x04\xDE^\xFA\xEA\x1C\xD7\xD1:\xBF\xB6Z\e\x05\xD3u\xD7\xEB+\x93\xB9\x93_\xD8I\xBF\xE8\x04\"\x15\xB5+\xB1/\x1A\x8FB\xED\x8Cy\xB7\x93-\xEE\xB8h\xAF\xB6\xF2wV&\x0Eq\x02\x82\x97\x13h\xFBq:\xD3Y\x8D\xB0\xF0\xF4~\xE8d\x12Vz\x13\xA0\x02\x8FIPO\x0F\xA0K\xBA\x15\x97\xFB\x03\xC1\x9E\xFC\xF1\xCFH\xAF\xD2\xDF\xD4z%\xAC\xE3\xEDBq`\xEE\xE2\b\xDCy\xC7\x85\xC0\xFF\n'\x10\xE9}\xE4w\xE5\xFD39zb\x86M[^tD~\x01LYX\x94"
	
    File.open(rxdata, "wb") do |f|
      Marshal.dump([[62054200, "Main", txt]], f)
    end
  end

  def self.from_folder(path = "Data/Scripts", rxdata = "Data/Scripts.rxdata")
    scripts = File.open(rxdata, 'rb') { |f| Marshal.load(f) }
    if scripts.length > 10
      p "Scripts.rxdata already has a bunch of scripts in it. Won't consolidate script files."
      return
    end

    scripts = []
    aggregate_from_folder(path, scripts)
    # Save scripts to file
    File.open(rxdata, "wb") do |f|
      Marshal.dump(scripts, f)
    end
  end

  def self.aggregate_from_folder(path, scripts, level = 0)
    files = []
    folders = []
    Dir.foreach(path) do |f|
      next if f == '.' || f == '..'

      if File.directory?(path + "/" + f)
        folders.push(f)
      else
        files.push(f)
      end
    end
    # Aggregate individual script files into Scripts.rxdata
    files.sort!
    files.each do |f|
      section_name = filename_to_title(f)
      content = File.open(path + "/" + f, "rb") { |f2| f2.read }#.gsub(/\n/, "\r\n")
      scripts << [rand(999_999), section_name, Zlib::Deflate.deflate(content)]
    end
    # Check each subfolder for scripts to aggregate
    folders.sort!
    folders.each do |f|
      section_name = filename_to_title(f)
      scripts << [rand(999_999), "==================", Zlib::Deflate.deflate("")] if level == 0
      scripts << [rand(999_999), "", Zlib::Deflate.deflate("")] if level == 1
      scripts << [rand(999_999), "[[ " + section_name + " ]]", Zlib::Deflate.deflate("")]
      aggregate_from_folder(path + "/" + f, scripts, level + 1)
    end
  end

  def self.filename_to_title(filename)
    filename = filename.bytes.pack('U*')
    title = ""
    if filename[/^[^_]*_(.+)$/]
      title = $~[1]
      title = title[0..-4] if title.end_with?(".rb")
      title = title.strip
    end
    title = "unnamed" if !title || title.empty?
    title.gsub!(/&bs;/, "\\")
    title.gsub!(/&fs;/, "/")
    title.gsub!(/&cn;/, ":")
    title.gsub!(/&as;/, "*")
    title.gsub!(/&qm;/, "?")
    title.gsub!(/&dq;/, "\"")
    title.gsub!(/&lt;/, "<")
    title.gsub!(/&gt;/, ">")
    title.gsub!(/&po;/, "|")
    return title
  end

  def self.title_to_filename(title)
    filename = title.clone
    filename.gsub!(/\\/, "&bs;")
    filename.gsub!(/\//, "&fs;")
    filename.gsub!(/:/, "&cn;")
    filename.gsub!(/\*/, "&as;")
    filename.gsub!(/\?/, "&qm;")
    filename.gsub!(/"/, "&dq;")
    filename.gsub!(/</, "&lt;")
    filename.gsub!(/>/, "&gt;")
    filename.gsub!(/\|/, "&po;")
    return filename
  end

  def self.create_script(title, content)
    f = File.new(title, "wb")
    f.write content
    f.close
  end

  def self.clear_directory(path, delete_current = false)
    Dir.foreach(path) do |f|
      next if f == '.' || f == '..'
      if File.directory?(path + "/" + f)
        clear_directory(path + "/" + f, true)
      else
        File.delete(path + "/" + f)
      end
    end
    Dir.delete(path) if delete_current
  end

  def self.create_directory(path)
    paths = path.split('/')
    paths.each_with_index do |_e, i|
      if !File.directory?(paths[0..i].join('/'))
        Dir.mkdir(paths[0..i].join('/'))
      end
    end
  end
end

#Scripts.dump("D:/Desktop/Scripts", "D:/Desktop/Main Essentials/Data/Scripts.rxdata")
#Scripts.from_folder("D:/Desktop/Scripts", "D:/Desktop/Main Essentials/Data/Scripts.rxdata")
Scripts.dump
#Scripts.from_folder
