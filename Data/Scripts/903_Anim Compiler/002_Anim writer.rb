module Compiler
  module_function

  def write_all_battle_animations
    # Delete all existing .txt files in the PBS/Animations/ folder
    files_to_delete = get_animation_pbs_files_to_compile
    files_to_delete.each { |path| File.delete(path) }
    # Get all files that need writing
    paths = []
    GameData::Animation.each { |anim| paths.push(anim.pbs_path) if !paths.include?(anim.pbs_path) }
    idx = 0
    # Write each file in turn
    paths.each do |path|
      Graphics.update if idx % 500 == 0
      idx += 1
      write_battle_animation_file(path)
    end
  end

  def write_battle_animation_file(path)
    schema = GameData::Animation.schema
    sub_schema = GameData::Animation.sub_schema
    write_pbs_file_message_start(path)
    # Create all subfolders needed
    dirs = ("PBS/Animations/" + path).split("/")
    dirs.pop   # Remove the filename
    dirs.length.times do |i|
      dir_string = dirs[0..i].join("/")
      if !FileTest.directory?(dir_string)
        Dir.mkdir(dir_string) rescue nil
      end
    end
    # Write file
    File.open("PBS/Animations/" + path + ".txt", "wb") do |f|
      add_PBS_header_to_file(f)
      # Write each element in turn
      GameData::Animation.each do |element|
        next if element.pbs_path != path
        f.write("\#-------------------------------\r\n")
        if schema["SectionName"]
          f.write("[")
          pbWriteCsvRecord(element.get_property_for_PBS("SectionName"), f, schema["SectionName"])
          f.write("]\r\n")
        else
          f.write("[#{element.id}]\r\n")
        end
        # Write each animation property
        schema.each_key do |key|
          next if ["SectionName", "Particle"].include?(key)
          val = element.get_property_for_PBS(key)
          next if val.nil?
          f.write(sprintf("%s = ", key))
          pbWriteCsvRecord(val, f, schema[key])
          f.write("\r\n")
        end
        # Write each particle in turn
        element.particles.each_with_index do |particle, i|
          # Write header
          f.write("<" + particle[:name] + ">")
          f.write("\r\n")
          # Write one-off particle properties
          sub_schema.each_pair do |key, val|
            next if val[1][0] == "^"
            val = element.get_particle_property_for_PBS(key, i)
            next if val.nil?
            f.write(sprintf("    %s = ", key))
            pbWriteCsvRecord(val, f, sub_schema[key])
            f.write("\r\n")
          end
          # Write particle commands (in keyframe order)
          cmds = element.get_particle_property_for_PBS("AllCommands", i)
          cmds.each do |cmd|
            if cmd[2] == 0   # Duration of 0
              f.write(sprintf("    %s = ", cmd[0]))
              new_cmd = cmd[1..-1]
              new_cmd.delete_at(1)
              pbWriteCsvRecord(new_cmd, f, sub_schema[cmd[0]])
              f.write("\r\n")
            else   # Has a duration
              f.write(sprintf("    %s = ", cmd[0]))
              pbWriteCsvRecord(cmd[1..-1], f, sub_schema[cmd[0]])
              f.write("\r\n")
            end
          end
        end
      end
    end
    process_pbs_file_message_end
  end
end

#===============================================================================
# Hook into the regular Compiler to also write all animation PBS files.
#===============================================================================
module Compiler
  module_function

  class << self
    if !method_defined?(:__new_anims__write_all)
      alias_method :__new_anims__write_all, :write_all
    end
  end

  def write_all
    __new_anims__write_all
    Console.echo_h1(_INTL("Writing all animation PBS files"))
    write_all_battle_animations
    echoln ""
    Console.echo_h2(_INTL("Successfully rewrote all animation PBS files"), text: :green)
  end
end

#===============================================================================
# Debug menu function for writing all animation PBS files. Shouldn't need to be
# used, but it's here if you want it.
#===============================================================================
MenuHandlers.add(:debug_menu, :create_animation_pbs_files, {
  "name"        => _INTL("Write all animation PBS files"),
  "parent"      => :files_menu,
  "description" => _INTL("Write all animation PBS files."),
  "effect"      => proc {
    Compiler.write_all_battle_animations
  }
})
