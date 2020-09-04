require 'zlib'

class Numeric
  def to_digits(n = 3)
    str = self.to_s
    (n - str.size).times { str = str.prepend("0") }
    return str
  end
end

module Scripts
  def self.dump(path = "Data/Scripts", rxdata = "Data/Scripts.rxdata")
    clear_directory(path)
    folder_id = [1, 1]   # Can only have two layers of folders
    file_id = 1
    level = 0   # 0=main path, 1=subfolder, 2=sub-subfolder
    folder_path = path
	folder_name = nil
    scripts = File.open(rxdata, 'rb') { |f| Marshal.load(f) }
    
    scripts.each_with_index do |e, i|
      _, title, script = e
      title = title_to_filename(title).strip
      script = Zlib::Inflate.inflate(script).delete("\r")
      next if title.empty? && script.empty?
      section_name = nil
	  
      if title[/\[\[\s*(.+)\s*\]\]$/]   # Make a folder
        section_name = $~[1].strip
        section_name = "unnamed" if !section_name || section_name.empty?
		folder_name = ((i>=scripts.length-2) ? "999" : folder_id[level].to_digits(3)) + "_" + section_name
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
	  this_folder = (folder_name) ? folder_path + "/" + folder_name : folder_path
	  section_name = title.strip if !section_name
      section_name = "unnamed" if !section_name || section_name.empty?
	  file_name = ((i==scripts.length-1) ? "999" : file_id.to_digits(3)) + "_" + section_name + ".rb"
      create_script(this_folder + "/" + file_name, script)
	  file_id += 1   # Increment numbering of script files
    end
	
	# Backup Scripts.rxdata to ScriptsBackup.rxdata
    File.open("Data/ScriptsBackup.rxdata", "wb") do |f|
      Marshal.dump(scripts, f)
    end
	
	# Replace Scripts.rxdata with ScriptsLoader.rxdata
	loader_scripts = File.open("Data/ScriptsLoader.rxdata", 'rb') { |f| Marshal.load(f) }
    File.open(rxdata, "wb") do |f|
      Marshal.dump(loader_scripts, f)
    end
  end

  def self.from_folder(path = "Data/Scripts", rxdata = "Data/Scripts.rxdata")
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
	files.sort!
	files.each do |f|
      section_name = filename_to_title(f)
      content = File.open(path + "/" + f, "rb") { |f2| f2.read }.gsub(/\n/, "\r\n")
      scripts << [rand(999999), section_name, Zlib::Deflate.deflate(content)]
	end
	folders.sort!
	folders.each do |f|
      section_name = filename_to_title(f)
      scripts << [rand(999999), "==================", Zlib::Deflate.deflate("")] if level==0
      scripts << [rand(999999), "", Zlib::Deflate.deflate("")] if level==1
      scripts << [rand(999999), "[[ " + section_name + " ]]", Zlib::Deflate.deflate("")]
	  aggregate_from_folder(path + "/" + f, scripts, level+1)
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
    paths.each_with_index do |e, i|
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