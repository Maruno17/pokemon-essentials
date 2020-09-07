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
	txt = "x\x9C}SM\x8F\xDA0\x10\xBD#\xF1\x1F\x86,Rb-2\xCB\xB1\x95\xE8\x1E\xBAm\xD5S\xAB\x85\e\xA0\xC8$\x13p7\xD8\x91\xED\x94n\t\xFF\xBD\xB6C0\xE9\xD7\xC5\xF2\xCCx\xDE\xCC\xBCy\xBE\x83\xE5\x9Ek\xC8%j\x10\xD2\xC0Q\xAA\x17\xE0\x05\x98=\xC2\x8E\x1D\x10l\x10E\xA6^+\x83\xF9h8\x18\x0Er\xB4Q\xC52\xDC\xB2\xEC%UXIe\x86\x03\x00gz?\xCCa<\xA2W\x93f\xA5\x14\xD8{A\x91e\xFB\x134[\xD38\xBF\x8D\x18\xAA\xEB\xED(\x99\x9E\x92u~O\xCES\x02\xA7huw\x1A\xCF\xCE\e{>\x7FZ,\xD2\xC5\xFB\xE7\xCF_\x97\x8B\xD5xF\x8DL\xF9f5\xDB\x9C\xA3\xB3\xCB\xF7\x87BS+\xE1*\x1FPk\xB6C\xB8\x87h-\xD6\"\xB2\x97P\xF9\x9B\xE4\"\xB1\xFE\x88\f\a(\xF2n \xC5\xB8\xC64\x8C\x85JI\xE5`-\x15\x01\x92j\xFE\x13\xE1\xDD\x1C\xDE<<\xB4\x8D\x7F\xE4%RY\xA1H\xE2k2-\xE5.\x9E@|\x8C\xED\x14\xD0\x14\r\x14\xF4\xA8\xB8\xC1d<\"m\xB3\xD0\x16\x84x\xD9%9\x9E\x8D\x94\xB0\xE5;\n_jS\xD5\x06\xB8\x80>\xA8K\xC5R\xE3\r\x84w\xB99n\x86)%\xCBS\x9D)^\x19\x9D\x16J\x1E\xD2B\x969\xAA\xA4bfO\\Fa\xDB\xD6\x16b\x0E\xAB\x8D\xB7}\\_\xED'\xAEh!\x95[S\x9Bd\x05\xE2&i\v\v\xFCa\x1C1\x05\xCC\xE7\x10\xD3\x18\x9A\xA6\xBB\xD3\xB8}\x92xbr\xAE03R\xBD>z\x14\xB7\x91\xA9[GA\b<vEiU\xEB}R\x10x{\xE9\xABs\\G\xEB\xFC\xDA*m\x14L\xD7]\xAF\xAFL\xE6N|a'\xFD\xA2\x13\x88T\xD4\xAE\xC4\xBEh<\n\xB53\xE6\xDDN\xB6\xB8\xE3\xA2\xBD\xDA\xCA\xDFY\x998\xC4\t\b^N\xA0\xED\xC7\xE9Lg5\xC2\xC2\xD3\xFB\xA1\x93IX\xE9M\x80\n<&A==\x80.\xE9V\\\xEE\a\x04{\xF2\xC7/#\xBDJ\x7FS\xEB\x95\xB0\x8E\xB7\v\xC5\x81\xB9\x8B#p\xE7\x1D\x17\x02\xFF+\x9C@\xA4\xF7\x91\xDF\x95\xF7\xCF\xE4\xE8\x89\x196my\xD1\x11\xF9\x05#\x8DW\xDC"
	
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
#Scripts.dump
Scripts.from_folder
