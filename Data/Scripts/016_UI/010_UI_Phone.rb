#===============================================================================
# Phone screen
#===============================================================================
class Window_PhoneList < Window_CommandPokemon
  def drawCursor(index, rect)
    selarrow = AnimatedBitmap.new("Graphics/Pictures/phoneSel")
    if self.index == index
      pbCopyBitmap(self.contents, selarrow.bitmap, rect.x, rect.y)
    end
    return Rect.new(rect.x + 28, rect.y + 8, rect.width - 16, rect.height)
  end

  def drawItem(index, count, rect)
    return if index >= self.top_row + self.page_item_max
    super
    drawCursor(index - 1, itemRect(index - 1))
  end
end

#===============================================================================
#
#===============================================================================
class PokemonPhoneScene
  def start
    commands = []
    @trainers = []
    if $PokemonGlobal.phoneNumbers
      $PokemonGlobal.phoneNumbers.each do |num|
        if num[0]   # if visible
          if num.length == 8   # if trainer
            @trainers.push([num[1], num[2], num[6], (num[4] >= 2)])
          else               # if NPC
            @trainers.push([num[1], num[2], num[3]])
          end
        end
      end
    end
    if @trainers.length == 0
      pbMessage(_INTL("There are no phone numbers stored."))
      return
    end
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites["list"] = Window_PhoneList.newEmpty(152, 32, Graphics.width - 142, Graphics.height - 80, @viewport)
    @sprites["header"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Phone"), 2, -18, 128, 64, @viewport
    )
    @sprites["header"].baseColor   = Color.new(248, 248, 248)
    @sprites["header"].shadowColor = Color.new(0, 0, 0)
    mapname = (@trainers[0][2]) ? pbGetMapNameFromId(@trainers[0][2]) : ""
    @sprites["bottom"] = Window_AdvancedTextPokemon.newWithSize(
      "", 162, Graphics.height - 64, Graphics.width - 158, 64, @viewport
    )
    @sprites["bottom"].text = "<ac>" + mapname
    @sprites["info"] = Window_AdvancedTextPokemon.newWithSize("", -8, 224, 180, 160, @viewport)
    addBackgroundPlane(@sprites, "bg", "phonebg", @viewport)
    @sprites["icon"] = IconSprite.new(70, 102, @viewport)
    if @trainers[0].length == 4
      filename = GameData::TrainerType.charset_filename(@trainers[0][0])
    else
      filename = sprintf("Graphics/Characters/phone%03d", @trainers[0][0])
    end
    @sprites["icon"].setBitmap(filename)
    charwidth  = @sprites["icon"].bitmap.width
    charheight = @sprites["icon"].bitmap.height
    @sprites["icon"].x = 86 - (charwidth / 8)
    @sprites["icon"].y = 134 - (charheight / 8)
    @sprites["icon"].src_rect = Rect.new(0, 0, charwidth / 4, charheight / 4)
    @trainers.each do |trainer|
      if trainer.length == 4
        displayname = _INTL("{1} {2}", GameData::TrainerType.get(trainer[0]).name,
                            pbGetMessageFromHash(MessageTypes::TrainerNames, trainer[1]))
        commands.push(displayname) # trainer's display name
      else
        commands.push(trainer[1]) # NPC's display name
      end
    end
    @sprites["list"].commands = commands
    @sprites["list"].page_item_max.times do |i|
      @sprites["rematch[#{i}]"] = IconSprite.new(468, 62 + (i * 32), @viewport)
      j = i + @sprites["list"].top_item
      next if j >= commands.length
      trainer = @trainers[j]
      if trainer.length == 4 && trainer[3]
        @sprites["rematch[#{i}]"].setBitmap("Graphics/Pictures/phoneRematch")
      end
    end
    rematchcount = 0
    @trainers.each do |trainer|
      rematchcount += 1 if trainer.length == 4 && trainer[3]
    end
    infotext = _INTL("Registered<br>")
    infotext += _INTL(" <r>{1}<br>", @sprites["list"].commands.length)
    infotext += _INTL("Waiting for a rematch<r>{1}", rematchcount)
    @sprites["info"].text = infotext
    pbFadeInAndShow(@sprites)
    pbActivateWindow(@sprites, "list") {
      oldindex = -1
      loop do
        Graphics.update
        Input.update
        pbUpdateSpriteHash(@sprites)
        if @sprites["list"].index != oldindex
          trainer = @trainers[@sprites["list"].index]
          if trainer.length == 4
            filename = GameData::TrainerType.charset_filename(trainer[0])
          else
            filename = sprintf("Graphics/Characters/phone%03d", trainer[0])
          end
          @sprites["icon"].setBitmap(filename)
          charwidth  = @sprites["icon"].bitmap.width
          charheight = @sprites["icon"].bitmap.height
          @sprites["icon"].x        = 86 - (charwidth / 8)
          @sprites["icon"].y        = 134 - (charheight / 8)
          @sprites["icon"].src_rect = Rect.new(0, 0, charwidth / 4, charheight / 4)
          mapname = (trainer[2]) ? pbGetMapNameFromId(trainer[2]) : ""
          @sprites["bottom"].text = "<ac>" + mapname
          @sprites["list"].page_item_max.times do |i|
            @sprites["rematch[#{i}]"].clearBitmaps
            j = i + @sprites["list"].top_item
            next if j >= commands.length
            trainer = @trainers[j]
            if trainer.length == 4 && trainer[3]
              @sprites["rematch[#{i}]"].setBitmap("Graphics/Pictures/phoneRematch")
            end
          end
        end
        if Input.trigger?(Input::BACK)
          pbPlayCloseMenuSE
          break
        elsif Input.trigger?(Input::USE)
          index = @sprites["list"].index
          pbCallTrainer(@trainers[index][0], @trainers[index][1]) if index >= 0
        end
      end
    }
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end
