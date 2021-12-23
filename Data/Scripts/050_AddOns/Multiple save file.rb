# # Store save file after load save file
# $storenamefilesave = nil
# # Some method for checking save file
# module FileSave
#   # Set name of folder
#   #DIR_SAVE_GAME = System.data_directory
#   DIR_SAVE_GAME = "Save Game"
#   # Set name of file for saving:
#   # Ex: Game1,Game2,etc
#   FILENAME_SAVE_GAME = "Game"
#   # Create dir
#   def self.createDir(dir = DIR_SAVE_GAME)
#     Dir.mkdir(dir) if !safeExists?(dir)
#   end
#
#   # Return location
#   def self.location(dir = DIR_SAVE_GAME)
#     self.createDir
#     return "#{dir}"
#   end
#
#   # Array file
#   def self.count(arr = false, dir = DIR_SAVE_GAME, file = FILENAME_SAVE_GAME, type = "rxdata")
#     self.createDir(dir)
#     File.rename("#{dir}/#{file}.#{type}", "#{dir}/#{file}1.#{type}") if File.file?("#{dir}/#{file}.#{type}")
#     return arr ? Dir.glob("#{dir}/#{file}*.#{type}") : Dir.glob("#{dir}/#{file}*.#{type}").size
#   end
#
#   # Rename
#   def self.rename(dir = DIR_SAVE_GAME, file = FILENAME_SAVE_GAME, type = "rxdata")
#     arr = self.count(true)
#     return if arr.size <= 0
#     name = []
#     arr.each { |f| name << (File.basename(f, ".#{type}").gsub(/[^0-9]/, "")) }
#     needtorewrite = false
#     (0...arr.size).each { |i|
#       needtorewrite = true if arr[i] != "#{dir}/#{file}#{name[i]}.#{type}"
#     }
#     if needtorewrite
#       numbername = []
#       name.each { |n| numbername << n.to_i }
#       (0...numbername.size).each { |i|
#         loop do
#           break if i == 0
#           diff = numbername.index(numbername[i])
#           break if diff == i
#           numbername[i] += 1
#         end
#         Dir.mkdir("#{dir}/#{numbername[i]}")
#         File.rename("#{arr[i]}", "#{dir}/#{numbername[i]}/#{file}#{numbername[i]}.#{type}")
#       }
#       (0...name.size).each { |i|
#         name2 = "#{dir}/#{numbername[i]}/#{file}#{numbername[i]}.#{type}"
#         File.rename(name2, "#{dir}/#{file}#{numbername[i]}.#{type}")
#         Dir.delete("#{dir}/#{numbername[i]}")
#       }
#     end
#     arr.size.times { |i|
#       num = 0
#       namef = sprintf("%d", i + 1)
#       loop do
#         break if File.file?("#{dir}/#{file}#{namef}.#{type}")
#         num += 1
#         namef2 = sprintf("%d", i + 1 + num)
#         File.rename("#{dir}/#{file}#{namef2}.#{type}", "#{dir}/#{file}#{namef}.#{type}") if File.file?("#{dir}/#{file}#{namef2}.#{type}")
#       end
#     }
#   end
#
#   # Save
#   def self.name(n = nil, re = true, dir = DIR_SAVE_GAME, file = FILENAME_SAVE_GAME, type = "rxdata")
#     self.rename if re
#     return "#{dir}/#{file}1.rxdata" if n.nil?
#     if !n.is_a?(Numeric)
#       p "Set number for file save"
#       return
#     end
#     return "#{dir}/#{file}#{n}.rxdata"
#   end
#
#   # Old file save
#   def self.title
#     return System.game_title.gsub(/[^\w ]/, '_')
#   end
#
#   # Version 19
#   def self.dirv19(dir = DIR_SAVE_GAME, file = FILENAME_SAVE_GAME, type = "rxdata")
#     game_title = self.title
#     return if !File.directory?(System.data_directory)
#     old_file = System.data_directory + '/Game.rxdata'
#     return if !File.file?(old_file)
#     self.rename
#     size = self.count
#     File.move(old_file, "#{dir}/#{file}#{size + 1}.#{type}")
#   end
#
#   # Version 18
#   def self.dirv18(dir = DIR_SAVE_GAME, file = FILENAME_SAVE_GAME, type = "rxdata")
#     game_title = self.title
#     home = ENV['HOME'] || ENV['HOMEPATH']
#     return if home.nil?
#     old_location = File.join(home, 'Saved Games', game_title)
#     return if !File.directory?(old_location)
#     old_file = File.join(old_location, 'Game.rxdata')
#     return if !File.file?(old_file)
#     self.rename
#     size = self.count
#     File.move(old_file, "#{dir}/#{file}#{size + 1}.#{type}")
#   end
# end
# #-------------------------#
# # Set for module SaveData #
# #-------------------------#
# module SaveData
#   def self.delete_file(file = FILE_PATH)
#     File.delete(file)
#     File.delete(file + '.bak') if File.file?(file + '.bak')
#   end
#
#   def self.move_old_windows_save
#     FileSave.dirv19
#     FileSave.dirv18
#   end
#
#   def self.changeFILEPATH(new = nil)
#     return if new.nil?
#     const_set(:FILE_PATH, new)
#   end
# end
# #---------------------#
# # Set 'set_up_system' #
# #---------------------#
# module Game
#   def self.set_up_system
#     SaveData.changeFILEPATH($storenamefilesave.nil? ? FileSave.name : $storenamefilesave)
#     SaveData.move_old_windows_save if System.platform[/Windows/]
#     save_data = (SaveData.exists?) ? SaveData.read_from_file(SaveData::FILE_PATH) : {}
#     if save_data.empty?
#       SaveData.initialize_bootup_values
#     else
#       SaveData.load_bootup_values(save_data)
#     end
#     # Set resize factor
#     pbSetResizeFactor([$PokemonSystem.screensize, 4].min)
#     # Set language (and choose language if there is no save file)
#     if Settings::LANGUAGES.length >= 2
#       $PokemonSystem.language = pbChooseLanguage if save_data.empty?
#       pbLoadMessages('Data/' + Settings::LANGUAGES[$PokemonSystem.language][1])
#     end
#   end
# end
# #--------------------#
# # Set emergency save #
# #--------------------#
# def pbEmergencySave
#   oldscene = $scene
#   $scene = nil
#   pbMessage(_INTL("The script is taking too long. The game will restart."))
#   return if !$Trainer
#   # It will store the last save file when you dont file save
#   count = FileSave.count
#   SaveData.changeFILEPATH($storenamefilesave.nil? ? FileSave.name : $storenamefilesave)
#   if SaveData.exists?
#     File.open(SaveData::FILE_PATH, 'rb') do |r|
#       File.open(SaveData::FILE_PATH + '.bak', 'wb') do |w|
#         while s = r.read(4096)
#           w.write s
#         end
#       end
#     end
#   end
#   if Game.save
#     pbMessage(_INTL("\\se[]The game was saved.\\me[GUI save game] The previous save file has been backed up.\\wtnp[30]"))
#   else
#     pbMessage(_INTL("\\se[]Save failed.\\wtnp[30]"))
#   end
#   $scene = oldscene
# end
#
# #------------------------------------------------------------------------------#
# #------------------------------------------------------------------------------#
# #------------------------------------------------------------------------------#
# #------------------------------------------------------------------------------#
# # Save                                                                         #
# #------------------------------------------------------------------------------#
# # Custom message
# def pbCustomMessageForSave(message, commands, index, &block)
#   return pbMessage(message, commands, index, &block)
# end
#
# # Save screen
# class PokemonSaveScreen
#   def pbSaveScreen
#     ret = false
#     # Check for renaming
#     FileSave.rename
#     # Count save file
#     count = FileSave.count
#     # Start
#     @scene.pbStartScreen
#     msg = _INTL("What do you want to do?")
#     cmds = [_INTL("Save"),
#             _INTL("Save to new file"),
#             _INTL("Overwrite another save"),
#             _INTL("Cancel")
#     ]
#     cmd2 = pbCustomMessageForSave(msg, cmds, 3)
#
#     # New save file
#     case cmd2
#     when 1
#       ret = writeToNewSaveFile(count)
#       # Overwrite
#     when 2
#       ret = overwriteSaveFile(count)
#     when 0
#       ret = overwriteCurrentFile(count)
#     end
#
#     @scene.pbEndScreen
#     return ret
#   end
#
#   def overwriteCurrentFile(count)
#     if !$storenamefilesave.nil? && count > 0
#       SaveData.changeFILEPATH($storenamefilesave)
#       if Game.save
#         pbMessage(_INTL("\\se[]{1} saved the game.\\me[GUI save game]\\wtnp[30]", $Trainer.name))
#         ret = true
#       else
#         pbMessage(_INTL("\\se[]Save failed.\\wtnp[30]"))
#         ret = false
#       end
#
#       SaveData.changeFILEPATH(!$storenamefilesave.nil? ? $storenamefilesave : FileSave.name)
#       return ret
#     else
#       return writeToNewSaveFile(count)
#     end
#   end
#
#   def overwriteSaveFile(count)
#     if count <= 0
#       pbMessage(_INTL("No save file was found."))
#     else
#       pbFadeOutIn {
#         file = ScreenChooseFileSave.new(count)
#         file.movePanel
#         file.endScene
#         return file.staymenu
#       }
#     end
#   end
#
#   def writeToNewSaveFile(count)
#     SaveData.changeFILEPATH(FileSave.name(count + 1))
#     ret = false
#     if Game.save
#       pbMessage(_INTL("\\se[]{1} saved the game.\\me[GUI save game]\\wtnp[30]", $Trainer.name))
#       ret = true
#     else
#       pbMessage(_INTL("\\se[]Save failed.\\wtnp[30]"))
#     end
#     SaveData.changeFILEPATH(!$storenamefilesave.nil? ? $storenamefilesave : FileSave.name)
#     return ret
#   end
# end
#
# #------------------------------------------------------------------------------#
# #------------------------------------------------------------------------------#
# #------------------------------------------------------------------------------#
# #------------------------------------------------------------------------------#
# # Load                                                                         #
# #------------------------------------------------------------------------------#
# class PokemonLoadScreen
#   def initialize(scene)
#     @scene = scene
#   end
#
#   def pbStartLoadScreen
#     commands = []
#     cmd_continue = -1
#     cmd_new_game = -1
#     cmd_options = -1
#     cmd_debug = -1
#     cmd_quit = -1
#     show_continue = FileSave.count > 0
#     commands[cmd_continue = commands.length] = _INTL('Continue') if show_continue
#     commands[cmd_new_game = commands.length] = _INTL('New Game')
#     commands[cmd_options = commands.length] = _INTL('Options')
#     commands[cmd_delete = commands.length] = _INTL('Delete Save') if show_continue
#     commands[cmd_debug = commands.length] = _INTL('Debug') if $DEBUG
#     commands[cmd_quit = commands.length] = _INTL('Quit Game')
#     @scene.pbStartScene(commands, false, nil, 0, 0)
#     @scene.pbStartScene2
#     loop do
#       command = @scene.pbChoose(commands)
#       pbPlayDecisionSE if command != cmd_quit
#       case command
#       when cmd_continue
#         pbFadeOutIn {
#           file = ScreenChooseFileSave.new(FileSave.count)
#           file.movePanel(1)
#           @scene.pbEndScene if !file.staymenu
#           file.endScene
#           return if !file.staymenu
#         }
#       when cmd_new_game
#         @scene.pbEndScene
#         Game.start_new
#         return
#       when cmd_options
#         pbFadeOutIn do
#           scene = PokemonOption_Scene.new
#           screen = PokemonOptionScreen.new(scene)
#           screen.pbStartScreen(true)
#         end
#       when cmd_debug
#         pbFadeOutIn { pbDebugMenu(false) }
#       when cmd_quit
#         pbPlayCloseMenuSE
#         @scene.pbEndScene
#         $scene = nil
#         return
#       when cmd_delete
#         #pbStartDeleteScreen
#         deleteFileMenu(FileSave.count)
#       else
#         pbPlayBuzzerSE
#       end
#     end
#   end
#
#   def deleteFileMenu(count)
#     if count <= 0
#       pbMessage(_INTL("No save file was found."))
#     else
#       pbFadeOutIn {
#         file = ScreenChooseFileSave.new(count)
#         file.movePanel(2)
#         file.endScene
#         Graphics.frame_reset if file.deletefile
#       }
#       # Return menu
#       return false
#     end
#   end
#
#   def pbStartDeleteScreen
#     @scene.pbStartDeleteScene
#     @scene.pbStartScene2
#     count = FileSave.count
#     if count < 0
#       pbMessage(_INTL("No save file was found."))
#     else
#       msg = _INTL("What do you want to do?")
#       cmds = [_INTL("Delete All File Save"), _INTL("Delete Only One File Save"), _INTL("Cancel")]
#       cmd = pbCustomMessageForSave(msg, cmds, 3)
#       case cmd
#       when 0
#         if pbConfirmMessageSerious(_INTL("Delete all saves?"))
#           pbMessage(_INTL("Once data has been deleted, there is no way to recover it.\1"))
#           if pbConfirmMessageSerious(_INTL("Delete the saved data anyway?"))
#             pbMessage(_INTL("Deleting all data. Don't turn off the power.\\wtnp[0]"))
#             haserrorwhendelete = false
#             count.times { |i|
#               name = FileSave.name(i + 1, false)
#               begin
#                 SaveData.delete_file(name)
#               rescue
#                 haserrorwhendelete = true
#               end
#             }
#             pbMessage(_INTL("You have at least one file that cant delete and have error")) if haserrorwhendelete
#             Graphics.frame_reset
#             pbMessage(_INTL("The save file was deleted."))
#           end
#         end
#       when 1
#         pbFadeOutIn {
#           file = ScreenChooseFileSave.new(count)
#           file.movePanel(2)
#           file.endScene
#           Graphics.frame_reset if file.deletefile
#         }
#       end
#     end
#     @scene.pbEndScene
#     $scene = pbCallTitle
#   end
# end
#
# #------------------------------------------------------------------------------#
# #------------------------------------------------------------------------------#
# #------------------------------------------------------------------------------#
# #------------------------------------------------------------------------------#
# # Scene for save menu, load menu and delete menu                               #
# #------------------------------------------------------------------------------#
# class ScreenChooseFileSave
#   attr_reader :staymenu
#   attr_reader :deletefile
#
#   def initialize(count)
#     @sprites = {}
#     @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
#     @viewport.z = 99999
#     # Set value
#     # Check quantity
#     @count = count
#     if @count <= 0
#       pbMessage("No save file was found.")
#       return
#     end
#     # Check still menu
#     @staymenu = false
#     @deletefile = false
#     # Check position
#     @position = 0
#     # Check position if count > 7
#     @choose = 0
#     # Set position of panel 'information'
#     @posinfor = 0
#     # Quantity of panel in information page
#     @qinfor = 0
#     # Check mystery gift
#     @mysgif = false
#   end
#
#   # Set background (used "loadbg")
#   def drawBg
#     color = Color.new(248, 248, 248)
#     addBackgroundOrColoredPlane(@sprites, "background", "loadbg", color, @viewport)
#   end
#
#   #-------------------------------------------------------------------------------
#   # Set Panel
#   #-------------------------------------------------------------------------------
#   # Draw panel
#   def startPanel
#     # Check and rename
#     FileSave.rename
#     # Start
#     drawBg
#     # Set bar
#     num = (@count > 7) ? 7 : @count
#     (0...num).each { |i|
#       create_sprite("panel #{i}", "loadPanels", @viewport)
#       w = 384; h = 46
#       set_src_wh_sprite("panel #{i}", w, h)
#       x = 16; y = 444
#       set_src_xy_sprite("panel #{i}", x, y)
#       x = 24 * 2; y = 16 * 2 + 48 * i
#       set_xy_sprite("panel #{i}", x, y)
#     }
#     # Set choose bar
#     create_sprite("choose panel", "loadPanels", @viewport)
#     w = 384; h = 46
#     set_src_wh_sprite("choose panel", w, h)
#     x = 16; y = 444 + 46
#     set_src_xy_sprite("choose panel", x, y)
#     choosePanel(@choose)
#     # Set text
#     create_sprite_2("text", @viewport)
#     textPanel
#     pbFadeInAndShow(@sprites) { update }
#   end
#
#   def choosePanel(pos = 0)
#     x = 24 * 2; y = 16 * 2 + 48 * pos
#     set_xy_sprite("choose panel", x, y)
#   end
#
#   # Draw text panel
#   BaseColor = Color.new(252, 252, 252)
#   ShadowColor = Color.new(0, 0, 0)
#
#   def textPanel(font = nil)
#     return if @count <= 0
#     bitmap = @sprites["text"].bitmap
#     bitmap.clear
#     if @count > 0 && @count < 7
#       namesave = 0; endnum = @count
#     else
#       namesave = (@position > @count - 7) ? @count - 7 : @position
#       endnum = 7
#     end
#     textpos = []
#     (0...endnum).each { |i|
#       string = _INTL("Save File #{namesave + 1 + i}")
#       if i + 1 == getCurrentSaveFileNumber()
#         string += " (Current)"
#       end
#       x = 24 * 2 + 36; y = 16 * 2 + 5 + 48 * i
#       textpos << [string, x, y, 0, BaseColor, ShadowColor]
#     }
#     (font.nil?) ? pbSetSystemFont(bitmap) : bitmap.font.name = font
#     pbDrawTextPositions(bitmap, textpos)
#   end
#
#   def getCurrentSaveFileNumber()
#     saveFilePath = $storenamefilesave
#     return nil if saveFilePath == nil
#     begin
#       filename = saveFilePath.split(".")[0]
#       return filename[-1].to_i
#     rescue nil
#     end
#   end
#
#   # Move panel
#   # Type: 0: Save; 1: Load; 2: Delete
#   def movePanel(type = 0)
#     infor = false; draw = true; loadmenu = false
#     @type = type
#     loop do
#       # Panel Page
#       if !loadmenu
#         if !infor
#           if draw;
#             startPanel; draw = false
#           else
#             # Update
#             update_ingame
#             if checkInput(Input::UP)
#               @position -= 1
#               @choose -= 1
#               if @choose < 0
#                 if @position < 0
#                   @choose = (@count < 7) ? @count - 1 : 6
#                 else
#                   @choose = 0
#                 end
#               end
#               @position = @count - 1 if @position < 0
#               # Move choose panel
#               choosePanel(@choose)
#               # Draw text
#               textPanel
#             end
#             if checkInput(Input::DOWN)
#               @position += 1
#               @choose += 1 if @position > @count - 7
#               (@choose = 0; @position = 0) if @position >= @count
#               # Move choose panel
#               choosePanel(@choose)
#               # Draw text
#               textPanel
#             end
#             if checkInput(Input::USE)
#               dispose
#               draw = true
#               if self.fileLoad.empty?
#                 @choose = 0; @position = 0
#                 if FileSave.count == 0
#                   pbMessage(_INTL('You dont have any save file. Restart game now.'))
#                   @staymenu = false
#                   $scene = pbCallTitle if @type == 1
#                   break
#                 end
#               else
#                 infor = true
#               end
#             end
#             if checkInput(Input::BACK)
#               @staymenu = true if @type == 1
#               break
#             end
#           end
#           # Information page
#         elsif infor
#           if draw;
#             startPanelInfor(@type); draw = false
#           else
#             # Update
#             update_ingame
#             # Load file
#             loadmenu = true if @type == 1
#             if checkInput(Input::USE)
#               # Save file
#               case @type
#               when 0
#                 SaveData.changeFILEPATH(FileSave.name(@position + 1))
#                 if Game.save
#                   pbMessage(_INTL("\\se[]{1} saved the game.\\me[GUI save game]\\wtnp[30]", $Trainer.name))
#                   ret = true
#                 else
#                   pbMessage(_INTL("\\se[]Save failed.\\wtnp[30]"))
#                   ret = false
#                 end
#                 SaveData.changeFILEPATH($storenamefilesave.nil? ? FileSave.name : $storenamefilesave)
#                 break
#                 # Delete file
#               when 2
#                 if pbConfirmMessageSerious(_INTL("Delete all saved data?"))
#                   pbMessage(_INTL("Once data has been deleted, there is no way to recover it.\1"))
#                   if pbConfirmMessageSerious(_INTL("Delete the saved data anyway?"))
#                     pbMessage(_INTL("Deleting all data. Don't turn off the power.\\wtnp[0]"))
#                     # Delete
#                     self.deleteFile
#                     @deletefile = true
#                   end
#                 end
#                 break
#               end
#             end
#             (dispose; draw = true; infor = false) if checkInput(Input::BACK)
#           end
#         end
#       else
#         # Update
#         update_ingame
#         # Start
#         if @qinfor > 0
#           if checkInput(Input::UP)
#             @posinfor -= 1
#             @posinfor = @qinfor if @posinfor < 0
#             choosePanelInfor
#           end
#           if checkInput(Input::DOWN)
#             @posinfor += 1
#             @posinfor = 0 if @posinfor > @qinfor
#             choosePanelInfor
#           end
#         end
#         if checkInput(Input::USE)
#           # Set up system again
#           $storenamefilesave = FileSave.name(@position + 1)
#           Game.set_up_system
#           if @posinfor == 0
#             Game.load(self.fileLoad)
#             @staymenu = false
#             break
#             # Mystery Gift
#           elsif @posinfor == 1 && @mysgif
#             pbFadeOutIn {
#               pbDownloadMysteryGift(self.fileLoad[:player])
#               @posinfor = 0; @qinfor = 0; @mysgif = false
#               dispose; draw = true; loadmenu = false; infor = false
#             }
#             # Language
#           elsif Settings::LANGUAGES.length >= 2 && (@posinfor == 2 || (@posinfor == 1 && !@mysgif))
#             $PokemonSystem.language = pbChooseLanguage
#             pbLoadMessages('Data/' + Settings::LANGUAGES[$PokemonSystem.language][1])
#             self.fileLoad[:pokemon_system] = $PokemonSystem
#             File.open(FileSave.name(@position + 1), 'wb') { |file| Marshal.dump(self.fileLoad, file) }
#             @posinfor = 0; @qinfor = 0; @mysgif = false
#             dispose; draw = true; loadmenu = false; infor = false
#           end
#         end
#         if checkInput(Input::BACK)
#           @posinfor = 0; @qinfor = 0; @mysgif = false
#           dispose; draw = true; loadmenu = false; infor = false
#         end
#       end
#     end
#   end
#
#   #-------------------------------------------------------------------------------
#   # Set information
#   #-------------------------------------------------------------------------------
#   def startPanelInfor(type)
#     # Draw background
#     drawBg
#     create_sprite("infor panel 0", "loadPanels", @viewport)
#     w = 408; h = 222
#     set_src_wh_sprite("infor panel 0", w, h)
#     x = 0; y = 0
#     set_src_xy_sprite("infor panel 0", x, y)
#     x = 24 * 2; y = 16 * 2
#     set_xy_sprite("infor panel 0", x, y)
#     drawInfor(type)
#   end
#
#   # Color
#   TEXTCOLOR = Color.new(232, 232, 232)
#   TEXTSHADOWCOLOR = Color.new(136, 136, 136)
#   MALETEXTCOLOR = Color.new(56, 160, 248)
#   MALETEXTSHADOWCOLOR = Color.new(56, 104, 168)
#   FEMALETEXTCOLOR = Color.new(240, 72, 88)
#   FEMALETEXTSHADOWCOLOR = Color.new(160, 64, 64)
#
#   # Draw information (text)
#   def drawInfor(type, font = nil)
#     # Set trainer
#     trainer = self.fileLoad[:player]
#     # Set mystery gift and language
#     if type == 1
#       mystery = self.fileLoad[:player].mystery_gift_unlocked
#       @mysgif = mystery
#       @qinfor += 1 if mystery
#       @qinfor += 1 if Settings::LANGUAGES.length >= 2
#       (0...@qinfor).each { |i|
#         create_sprite("panel load #{i}", "loadPanels", @viewport)
#         w = 384; h = 46
#         set_src_wh_sprite("panel load #{i}", w, h)
#         x = 16; y = 444
#         set_src_xy_sprite("panel load #{i}", x, y)
#         x = 24 * 2 + 8; y = 16 * 2 + 48 * i + 112 * 2
#         set_xy_sprite("panel load #{i}", x, y)
#       } if @qinfor > 0
#     end
#     # Move panel (information)
#     create_sprite("infor panel 1", "loadPanels", @viewport)
#     w = 408; h = 222
#     set_src_wh_sprite("infor panel 1", w, h)
#     x = 0; y = 222
#     set_src_xy_sprite("infor panel 1", x, y)
#     x = 24 * 2; y = 16 * 2
#     set_xy_sprite("infor panel 1", x, y)
#     # Set
#     create_sprite_2("text", @viewport)
#     framecount = self.fileLoad[:frame_count]
#     totalsec = (framecount || 0) / Graphics.frame_rate
#     bitmap = @sprites["text"].bitmap
#     textpos = []
#     # Text of trainer
#     x = 24 * 2; y = 16 * 2
#     title = (type == 0) ? "Save" : (type == 1) ? "Load" : "Delete"
#     textpos << [_INTL("#{title}"), 16 * 2 + x, 5 * 2 + y, 0, TEXTCOLOR, TEXTSHADOWCOLOR]
#     textpos << [_INTL("Badges:"), 16 * 2 + x, 56 * 2 + y, 0, TEXTCOLOR, TEXTSHADOWCOLOR]
#     textpos << [trainer.badge_count.to_s, 103 * 2 + x, 56 * 2 + y, 1, TEXTCOLOR, TEXTSHADOWCOLOR]
#     textpos << [_INTL("Pokédex:"), 16 * 2 + x, 72 * 2 + y, 0, TEXTCOLOR, TEXTSHADOWCOLOR]
#     textpos << [trainer.pokedex.seen_count.to_s, 103 * 2 + x, 72 * 2 + y, 1, TEXTCOLOR, TEXTSHADOWCOLOR]
#     textpos << [_INTL("Time:"), 16 * 2 + x, 88 * 2 + y, 0, TEXTCOLOR, TEXTSHADOWCOLOR]
#     hour = totalsec / 60 / 60
#     min = totalsec / 60 % 60
#     if hour > 0
#       textpos << [_INTL("{1}h {2}m", hour, min), 103 * 2 + x, 88 * 2 + y, 1, TEXTCOLOR, TEXTSHADOWCOLOR]
#     else
#       textpos << [_INTL("{1}m", min), 103 * 2 + x, 88 * 2 + y, 1, TEXTCOLOR, TEXTSHADOWCOLOR]
#     end
#     if trainer.male?
#       textpos << [trainer.name, 56 * 2 + x, 32 * 2 + y, 0, MALETEXTCOLOR, MALETEXTSHADOWCOLOR]
#     elsif textpos << [trainer.name, 56 * 2 + x, 32 * 2 + y, 0, FEMALETEXTCOLOR, FEMALETEXTSHADOWCOLOR]
#     else
#       textpos << [trainer.name, 56 * 2 + x, 32 * 2 + y, 0, TEXTCOLOR, TEXTSHADOWCOLOR]
#     end
#     mapid = self.fileLoad[:map_factory].map.map_id
#     mapname = pbGetMapNameFromId(mapid)
#     mapname.gsub!(/\\PN/, trainer.name)
#     textpos << [mapname, 193 * 2 + x, 5 * 2 + y, 1, TEXTCOLOR, TEXTSHADOWCOLOR]
#     # Load menu
#     if type == 1
#       # Mystery gift / Language
#       string = []
#       string << _INTL("Mystery Gift") if mystery
#       string << _INTL("Language") if Settings::LANGUAGES.length >= 2
#       if @qinfor > 0
#         (0...@qinfor).each { |i|
#           str = string[i]
#           x1 = x + 36 + 8
#           y1 = y + 5 + 112 * 2 + 48 * i
#           textpos << [str, x1, y1, 0, TEXTCOLOR, TEXTSHADOWCOLOR]
#         }
#       end
#     end
#     # Set text
#     (font.nil?) ? pbSetSystemFont(bitmap) : bitmap.font.name = font
#     pbDrawTextPositions(bitmap, textpos)
#
#     # Set trainer (draw)
#     if !trainer || !trainer.party
#       # Fade
#       pbFadeInAndShow(@sprites) { update }
#       return
#     else
#       meta = GameData::Metadata.get_player(trainer.character_ID)
#       if meta
#         filename = pbGetPlayerCharset(meta, 1, trainer, true)
#         @sprites["player"] = TrainerWalkingCharSprite.new(filename, @viewport)
#         charwidth = @sprites["player"].bitmap.width
#         charheight = @sprites["player"].bitmap.height
#         @sprites["player"].x = 56 * 2 - charwidth / 8
#         @sprites["player"].y = 56 * 2 - charheight / 8
#         @sprites["player"].src_rect = Rect.new(0, 0, charwidth / 4, charheight / 4)
#       end
#       for i in 0...trainer.party.length
#         @sprites["party#{i}"] = PokemonIconSprite.new(trainer.party[i], @viewport)
#         @sprites["party#{i}"].setOffset(PictureOrigin::Center)
#         @sprites["party#{i}"].x = (167 + 33 * (i % 2)) * 2
#         @sprites["party#{i}"].y = (56 + 25 * (i / 2)) * 2
#         @sprites["party#{i}"].z = 99999
#       end
#       # Fade
#       pbFadeInAndShow(@sprites) { update }
#     end
#   end
#
#   def choosePanelInfor
#     if @posinfor == 0
#       w = 408; h = 222
#       set_src_wh_sprite("infor panel 1", w, h)
#       x = 0; y = 222
#       set_src_xy_sprite("infor panel 1", x, y)
#       x = 24 * 2; y = 16 * 2
#       set_xy_sprite("infor panel 1", x, y)
#     else
#       w = 384; h = 46
#       set_src_wh_sprite("infor panel 1", w, h)
#       x = 16; y = 490
#       set_src_xy_sprite("infor panel 1", x, y)
#       x = 24 * 2 + 8
#       y = 16 * 2 + 48 * (@posinfor - 1) + 112 * 2
#       set_xy_sprite("infor panel 1", x, y)
#     end
#   end
#
#   #-------------------------------------------------------------------------------
#   # Delete
#   #-------------------------------------------------------------------------------
#   def deleteFile
#     savefile = FileSave.name(@position + 1, false)
#     begin
#       SaveData.delete_file(savefile)
#       pbMessage(_INTL('The saved data was deleted.'))
#     rescue SystemCallError
#       pbMessage(_INTL('All saved data could not be deleted.'))
#     end
#   end
#
#   #-------------------------------------------------------------------------------
#   #  Load File
#   #-------------------------------------------------------------------------------
#   def load_save_file(file_path)
#     save_data = SaveData.read_from_file(file_path)
#     unless SaveData.valid?(save_data)
#       if File.file?(file_path + '.bak')
#         pbMessage(_INTL('The save file is corrupt. A backup will be loaded.'))
#         save_data = load_save_file(file_path + '.bak')
#       else
#         self.prompt_save_deletion
#         return {}
#       end
#     end
#     return save_data
#   end
#
#   # Called if all save data is invalid.
#   # Prompts the player to delete the save files.
#   def prompt_save_deletion
#     pbMessage(_INTL('Cant load this save file'))
#     pbMessage(_INTL('The save file is corrupt, or is incompatible with this game.'))
#     exit unless pbConfirmMessageSerious(_INTL('Do you want to delete this save file?'))
#     self.deleteFile
#     $game_system = Game_System.new
#     $PokemonSystem = PokemonSystem.new
#   end
#
#   def fileLoad
#     return load_save_file(FileSave.name(@position + 1))
#   end
#
#   #-------------------------------------------------------------------------------
#   # Set SE for input
#   #-------------------------------------------------------------------------------
#   def checkInput(name)
#     if Input.trigger?(name)
#       (name == Input::BACK) ? pbPlayCloseMenuSE : pbPlayDecisionSE
#       return true
#     end
#     return false
#   end
#
#   #-------------------------------------------------------------------------------
#   # Set bitmap
#   #-------------------------------------------------------------------------------
#   # Image
#   def create_sprite(spritename, filename, vp, dir = "Pictures")
#     @sprites["#{spritename}"] = Sprite.new(vp)
#     @sprites["#{spritename}"].bitmap = Bitmap.new("Graphics/#{dir}/#{filename}")
#   end
#
#   # Set x, y
#   def set_xy_sprite(spritename, x, y)
#     @sprites["#{spritename}"].x = x
#     @sprites["#{spritename}"].y = y
#   end
#
#   # Set src
#   def set_src_wh_sprite(spritename, w, h)
#     @sprites["#{spritename}"].src_rect.width = w
#     @sprites["#{spritename}"].src_rect.height = h
#   end
#
#   def set_src_xy_sprite(spritename, x, y)
#     @sprites["#{spritename}"].src_rect.x = x
#     @sprites["#{spritename}"].src_rect.y = y
#   end
#
#   #-------------------------------------------------------------------------------
#   # Text
#   #-------------------------------------------------------------------------------
#   # Draw
#   def create_sprite_2(spritename, vp)
#     @sprites["#{spritename}"] = Sprite.new(vp)
#     @sprites["#{spritename}"].bitmap = Bitmap.new(Graphics.width, Graphics.height)
#     @sprites["#{spritename}"].bitmap.clear
#   end
#
#   #-------------------------------------------------------------------------------
#   def dispose
#     pbDisposeSpriteHash(@sprites)
#   end
#
#   def update
#     pbUpdateSpriteHash(@sprites)
#   end
#
#   def update_ingame
#     Graphics.update
#     Input.update
#     pbUpdateSpriteHash(@sprites)
#   end
#
#   def endScene
#     dispose
#     @viewport.dispose
#   end
# end