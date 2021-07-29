class File
  # Copies the source file to the destination path.
  def self.copy(source, destination)
    data = ""
    t = Time.now
    File.open(source, 'rb') do |f|
      while r = f.read(4096)
        if Time.now - t > 1
          Graphics.update
          t = Time.now
        end
        data += r
      end
    end
    File.delete(destination) if File.file?(destination)
    f = File.new(destination, 'wb')
    f.write data
    f.close
  end

  # Copies the source to the destination and deletes the source.
  def self.move(source, destination)
    File.copy(source, destination)
    File.delete(source)
  end
end

#===============================================================================
#
#===============================================================================
module SpriteRenamer
  module_function

  def readDirectoryFiles(directory, formats)
    files = []
    Dir.chdir(directory) {
      for i in 0...formats.length
        Dir.glob(formats[i]) { |f| files.push(f) }
      end
    }
    return files
  end

  def convert_pokemon_filename(full_name, default_prefix = "")
    name = full_name
    extension = ".png"
    if full_name[/^(.+)\.([^\.]+)$/]   # Of the format something.abc
      name = $~[1]
      extension = "." + $~[2]
    end
    prefix = default_prefix
    form = female = shadow = crack = ""
    if default_prefix == ""
      if name[/s/] && !name[/shadow/]
        prefix = (name[/b/]) ? "Back shiny/" : "Front shiny/"
      else
        prefix = (name[/b/]) ? "Back/" : "Front/"
      end
    elsif default_prefix == "Icons/"
      prefix = "Icons shiny/" if name[/s/] && !name[/shadow/]
    end
    if name[/000/]
      species = "000"
    elsif name[/^(\d+)$/] || name[/^(\d+)\D/]
      species_number = $~[1].to_i
      species_data = GameData::Species.try_get(species_number)
      raise _INTL("Species {1} is not defined (trying to rename Pokémon graphic {2}).", species_number, full_name) if !species_data
      species = species_data.id.to_s
      form = "_" + $~[1].to_s if name[/_(\d+)$/] || name[/_(\d+)\D/]
      female = "_female" if name[/f/]
      shadow = "_shadow" if name[/_shadow/]
      if name[/egg/]
        prefix = "Eggs/"
        crack = "_icon" if default_prefix == "Icons/"
        crack = "_cracks" if name[/eggCracks/]
      end
    end
    return prefix + species + form + female + shadow + crack + extension
  end

  def convert_pokemon_sprites(src_dir, dest_dir)
    return if !FileTest.directory?(src_dir)
    # generates a list of all graphic files
    files = readDirectoryFiles(src_dir, ["*.png"])
    # starts automatic renaming
    files.each_with_index do |file, i|
      Graphics.update if i % 100 == 0
      pbSetWindowText(_INTL("Converting Pokémon sprites {1}/{2}...", i, files.length)) if i % 50 == 0
      case file
      when "battlers.png"
        File.delete(src_dir + file)
      when "egg.png"
        File.move(src_dir + file, dest_dir + "Eggs/000.png")
      when "eggCracks.png"
        File.move(src_dir + file, dest_dir + "Eggs/000_cracks.png")
      else
        next if !file[/^\d+[^\.]*\.[^\.]*$/]
        new_filename = convert_pokemon_filename(file)
        # moves the files into their appropriate folders
        File.move(src_dir + file, dest_dir + new_filename)
      end
    end
    Dir.delete(src_dir) rescue nil
  end

  def convert_pokemon_icons(src_dir, dest_dir)
    return if !FileTest.directory?(src_dir)
    # generates a list of all graphic files
    files = readDirectoryFiles(src_dir, ["*.png"])
    # starts automatic renaming
    files.each_with_index do |file, i|
      Graphics.update if i % 100 == 0
      pbSetWindowText(_INTL("Converting Pokémon icons {1}/{2}...", i, files.length)) if i % 50 == 0
      case file
      when "iconEgg.png"
        File.move(src_dir + file, dest_dir + "Eggs/000_egg.png")
      else
        next if !file[/^icon\d+[^\.]*\.[^\.]*$/]
        new_filename = convert_pokemon_filename(file.sub(/^icon/, ''), "Icons/")
        # moves the files into their appropriate folders
        File.move(src_dir + file, dest_dir + new_filename)
      end
    end
  end

  def convert_pokemon_footprints(src_dir, dest_dir)
    return if !FileTest.directory?(src_dir)
    # generates a list of all graphic files
    files = readDirectoryFiles(src_dir, ["*.png"])
    # starts automatic renaming
    files.each_with_index do |file, i|
      Graphics.update if i % 100 == 0
      pbSetWindowText(_INTL("Converting footprints {1}/{2}...", i, files.length)) if i % 50 == 0
      next if !file[/^footprint\d+[^\.]*\.[^\.]*$/]
      new_filename = convert_pokemon_filename(file.sub(/^footprint/, ''), "Footprints/")
      # moves the files into their appropriate folders
      File.move(src_dir + file, dest_dir + new_filename)
    end
    Dir.delete(src_dir) rescue nil
  end

  def convert_item_icons(src_dir, dest_dir)
    return if !FileTest.directory?(src_dir)
    # generates a list of all graphic files
    files = readDirectoryFiles(src_dir, ["*.png"])
    # starts automatic renaming
    files.each_with_index do |file, i|
      Graphics.update if i % 100 == 0
      pbSetWindowText(_INTL("Converting item icons {1}/{2}...", i, files.length)) if i % 50 == 0
      case file
      when "item000.png"
        File.move(src_dir + file, dest_dir + "000.png")
      when "itemBack.png"
        File.move(src_dir + file, dest_dir + "back.png")
      else
        if file[/^itemMachine(.+)\.([^\.]*)$/]
          type = $~[1]
          extension = $~[2]
          File.move(src_dir + file, dest_dir + "machine_" + type + "." + extension)
        elsif file[/^item(\d+)\.([^\.]*)$/]
          item_number = $~[1].to_i
          extension = $~[2]
          item_data = GameData::Item.try_get(item_number)
          raise _INTL("Item {1} is not defined (trying to rename item icon {2}).", item_number, file) if !item_data
          item = item_data.id.to_s
          # moves the files into their appropriate folders
          File.move(src_dir + file, dest_dir + item + "." + extension)
        end
      end
    end
  end

  def convert_pokemon_cries(src_dir)
    return if !FileTest.directory?(src_dir)
    # generates a list of all audio files
    files = readDirectoryFiles(src_dir, ["*.wav", "*.mp3", "*.ogg"])
    # starts automatic renaming
    files.each_with_index do |file, i|
      Graphics.update if i % 100 == 0
      pbSetWindowText(_INTL("Converting Pokémon cries {1}/{2}...", i, files.length)) if i % 50 == 0
      if file[/^(\d+)Cry[^\.]*\.([^\.]*)$/]
        species_number = $~[1].to_i
        extension = $~[2]
        form = (file[/Cry_(\d+)\./]) ? sprintf("_%s", $~[1]) : ""
        species_data = GameData::Species.try_get(species_number)
        raise _INTL("Species {1} is not defined (trying to rename species cry {2}).", species_number, file) if !species_data
        species = species_data.id.to_s
        File.move(src_dir + file, src_dir + species + form + "." + extension)
      end
    end
  end

  def convert_trainer_sprites(src_dir)
    return if !FileTest.directory?(src_dir)
    # generates a list of all graphic files
    if src_dir == "Graphics/Characters/"
      files = readDirectoryFiles(src_dir, ["trchar*.png"])
    else
      files = readDirectoryFiles(src_dir, ["*.png"])
    end
    # starts automatic renaming
    files.each_with_index do |file, i|
      Graphics.update if i % 100 == 0
      pbSetWindowText(_INTL("Converting trainer sprites {1}/{2}...", i, files.length)) if i % 50 == 0
      if src_dir == "Graphics/Characters/"
        if file[/^trchar(\d+)\.([^\.]*)$/]
          tr_type_number = $~[1].to_i
          extension = $~[2]
          tr_type_data = GameData::TrainerType.try_get(tr_type_number)
          raise _INTL("Trainer type {1} is not defined (trying to rename trainer charset {2}).", tr_type_number, file) if !tr_type_data
          tr_type = tr_type_data.id.to_s
          File.move(src_dir + file, src_dir + "trainer_" + tr_type + "." + extension)
        end
      else
        if file[/^trainer(\d+)\.([^\.]*)$/]
          tr_type_number = $~[1].to_i
          extension = $~[2]
          tr_type_data = GameData::TrainerType.try_get(tr_type_number)
          raise _INTL("Trainer type {1} is not defined (trying to rename trainer sprite {2}).", tr_type_number, file) if !tr_type_data
          tr_type = tr_type_data.id.to_s
          File.move(src_dir + file, src_dir + tr_type + "." + extension)
        elsif file[/^trback(\d+)\.([^\.]*)$/]
          tr_type_number = $~[1].to_i
          extension = $~[2]
          tr_type_data = GameData::TrainerType.try_get(tr_type_number)
          raise _INTL("Trainer type {1} is not defined (trying to rename trainer sprite {2}).", tr_type_number, file) if !tr_type_data
          tr_type = tr_type_data.id.to_s
          File.move(src_dir + file, src_dir + tr_type + "_back." + extension)
        end
      end
    end
  end

  def convert_player_metadata_charsets
    changed = false
    for i in 0...8
      metadata = GameData::Metadata.get_player(i)
      next if !metadata
      if metadata[1][/^trchar(\d+)$/]
        tr_type_number = $~[1].to_i
        tr_type_data = GameData::TrainerType.try_get(tr_type_number)
        raise _INTL("Trainer type {1} is not defined (trying to rename player metadata filename {2}).", tr_type_number, metadata[1]) if !tr_type_data
        metadata[1] = "trainer_" + tr_type_data.id.to_s
        changed = true
      end
    end
    return if !changed
    # Save changes to metadata and rewrite PBS file
    GameData::Metadata.save
    Compiler.write_metadata
  end

  def convert_files
    return if !pbConfirmMessage("Check for Pokémon/item/trainer files in their old folders that need renaming and moving?")
    any_changed = false
    # Rename and move Pokémon sprites/icons
    dest_dir = "Graphics/Pokemon/"
    Dir.mkdir(dest_dir) if !FileTest.directory?(dest_dir)
    for ext in ["Front/", "Back/", "Icons/", "Front shiny/", "Back shiny/", "Icons shiny/",
                "Eggs/", "Footprints/", "Shadow/"]
      Dir.mkdir(dest_dir + ext) if !FileTest.directory?(dest_dir + ext)
    end
    convert_pokemon_sprites("Graphics/Battlers/", dest_dir)
    convert_pokemon_icons("Graphics/Icons/", dest_dir)
    convert_pokemon_footprints("Graphics/Icons/Footprints/", dest_dir)
    # Rename and move item icons
    dest_dir = "Graphics/Items/"
    Dir.mkdir(dest_dir) if !FileTest.directory?(dest_dir)
    convert_item_icons("Graphics/Icons/", dest_dir)
    # Rename Pokémon cries
    convert_pokemon_cries("Audio/SE/Cries/")
    # Rename trainer sprites
    convert_trainer_sprites("Graphics/Trainers/")
    pbSetWindowText(nil)
    if pbConfirmMessage("Rename all trainer charsets? This will also edit map data to change events' charsets accordingly.")
      convert_trainer_sprites("Graphics/Characters/")
      convert_player_metadata_charsets
      pbSetWindowText(nil)
      # Edit all maps to replace used charsets
      mapData = Compiler::MapData.new
      t = Time.now.to_i
      Graphics.update
      for id in mapData.mapinfos.keys.sort
        map = mapData.getMap(id)
        next if !map || !mapData.mapinfos[id]
        changed = false
        for key in map.events.keys
          if Time.now.to_i - t >= 5
            Graphics.update
            t = Time.now.to_i
          end
          map.events[key].pages.each do |page|
            next if nil_or_empty?(page.graphic.character_name)
            next if !page.graphic.character_name[/^trchar(.+)$/]
            tr_type = $~[1]
            tr_type = tr_type.to_i if tr_type[/^\d+$/]
            tr_type_data = GameData::TrainerType.try_get(tr_type)
            raise _INTL("Trainer type {1} is not defined (trying to rename event's charset {2}).", tr_type, file) if !tr_type_data
            page.graphic.character_name = "trainer_" + tr_type_data.id.to_s
            changed = true
          end
        end
        mapData.saveMap(id) if changed
        any_changed = true if changed
      end
    end
    pbMessage(_INTL("All found sprites and icons were renamed and moved."))
    pbMessage(_INTL("Some map data was edited. Close and reopen RPG Maker XP to see the changes.")) if any_changed
    pbUpdateVehicle if $game_player
  end
end
