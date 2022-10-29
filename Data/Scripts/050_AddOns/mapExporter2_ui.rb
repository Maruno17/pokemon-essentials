#
# DebugMenuCommands.register("exportmap", {
#   "parent"      => "fieldmenu",
#   "name"        => _INTL("Export Map Image"),
#   "description" => _INTL("Select a map and save its image as a png."),
#   "effect"      => proc {
#     pbExportMapSelection
#   }
# })
#
# def pbExportMapSelection
#   loop do
#     map_id = pbListScreen(_INTL("Export Map"), MapLister.new(pbDefaultMap))
#     break if map_id <= 0
#     commands = ["Events", "Player", "Dependent Events", "Fog", "Panorama", "Map Name", "Game Name"]
#     if $game_map.map_id != map_id
#       commands.delete("Player")
#       commands.delete("Dependent Events")
#     end
#     options = pbShowMapExportOptions(commands)
#     if !options.include?(:Cancel)
#       ret = MapExporter.export(map_id, options)
#       mapname = pbGetMapNameFromId(map_id)
#       pbMessage(_INTL("Sucessfully exported map image of Map {1} ({2}) to the Exported Maps folder in the games's root.", map_id, mapname))
#       return
#     end
#   end
# end
#
# def pbShowMapExportOptions(commands)
#   sel_commands = []
#   sym_commands = [:MapName, :GameName]
#   cmdwindow = Window_CommandPokemonEx.new([])
#   cmdwindow.z = 99999
#   cmdwindow.visible = true
#   cmdwindow.index = 0
#   need_refresh = true
#   loop do
#     if need_refresh
#       sel_commands = []
#       commands.each_with_index do |s, i|
#         cmd_sym = s.gsub(/\s+/, "").to_sym
#         x = sym_commands.include?(cmd_sym) ? "[x]" : "[  ]"
#         sel_commands.push(_INTL("{1} {2}",x, s))
#       end
#       sel_commands.push("Export Map...")
#       cmdwindow.commands = sel_commands
#       cmdwindow.resizeToFit(cmdwindow.commands)
#       need_refresh = false
#     end
#     Graphics.update
#     Input.update
#     cmdwindow.update
#     yield if block_given?
#     if Input.trigger?(Input::USE)
#       break if cmdwindow.index == sel_commands.length - 1
#       cmd_sym = commands[cmdwindow.index].gsub(/\s+/, "").to_sym
#       if sym_commands.include?(cmd_sym)
#         sym_commands.delete(cmd_sym)
#       else
#         sym_commands.push(cmd_sym)
#       end
#       sym_commands.uniq!
#       need_refresh = true
#     elsif Input.trigger?(Input::BACK)
#       sym_commands = [:Cancel]
#       break
#     end
#     pbUpdateSceneMap
#   end
#   cmdwindow.dispose
#   Input.update
#   return sym_commands
# end
