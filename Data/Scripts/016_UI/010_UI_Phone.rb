#===============================================================================
# Phone screen
#===============================================================================
class Window_PhoneList < Window_CommandPokemon
  def drawCursor(index, rect)
    selarrow = AnimatedBitmap.new("Graphics/UI/Phone/cursor")
    if self.index == index
      pbCopyBitmap(self.contents, selarrow.bitmap, rect.x, rect.y + 2)
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
    # Get list of contacts
    @contacts = []
    $PokemonGlobal.phone.contacts.each do |contact|
      @contacts.push(contact) if contact.visible?
    end
    if @contacts.length == 0
      pbMessage(_INTL("There are no phone numbers stored."))
      return
    end
    # Create list of commands (display names of contacts) and count rematches
    commands = []
    rematch_count = 0
    @contacts.each do |contact|
      commands.push(contact.display_name)
      rematch_count += 1 if contact.can_rematch?
    end
    # Create viewport and sprites
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    addBackgroundPlane(@sprites, "bg", "Phone/bg", @viewport)
    @sprites["list"] = Window_PhoneList.newEmpty(152, 32, Graphics.width - 142, Graphics.height - 80, @viewport)
    @sprites["list"].windowskin = nil
    @sprites["list"].commands = commands
    @sprites["list"].page_item_max.times do |i|
      @sprites["rematch[#{i}]"] = IconSprite.new(468, 62 + (i * 32), @viewport)
      j = i + @sprites["list"].top_item
      if j < @contacts.length && @contacts[j].can_rematch?
        @sprites["rematch[#{i}]"].setBitmap("Graphics/UI/Phone/icon_rematch")
      end
    end
    @sprites["header"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Phone"), 2, -18, 128, 64, @viewport
    )
    @sprites["header"].baseColor   = Color.new(248, 248, 248)
    @sprites["header"].shadowColor = Color.black
    @sprites["header"].windowskin = nil
    @sprites["bottom"] = Window_AdvancedTextPokemon.newWithSize(
      "", 162, Graphics.height - 64, Graphics.width - 158, 64, @viewport
    )
    @sprites["bottom"].windowskin = nil
    map_name = (@contacts[0].map_id > 0) ? pbGetMapNameFromId(@contacts[0].map_id) : ""
    @sprites["bottom"].text = "<ac>" + map_name
    @sprites["info"] = Window_AdvancedTextPokemon.newWithSize("", -8, 224, 180, 160, @viewport)
    @sprites["info"].windowskin = nil
    infotext = _INTL("Registered<br>")
    infotext += _INTL(" <r>{1}<br>", @sprites["list"].commands.length)
    infotext += _INTL("Waiting for a rematch<r>{1}", rematch_count)
    @sprites["info"].text = infotext
    @sprites["icon"] = IconSprite.new(70, 102, @viewport)
    if @contacts[0].trainer?
      filename = GameData::TrainerType.charset_filename(@contacts[0].trainer_type)
    else
      filename = sprintf("Graphics/Characters/phone%03d", @contacts[0].common_event_id)
    end
    @sprites["icon"].setBitmap(filename)
    charwidth  = @sprites["icon"].bitmap.width
    charheight = @sprites["icon"].bitmap.height
    @sprites["icon"].x = 86 - (charwidth / 8)
    @sprites["icon"].y = 134 - (charheight / 8)
    @sprites["icon"].src_rect = Rect.new(0, 0, charwidth / 4, charheight / 4)
    # Start scene
    pbFadeInAndShow(@sprites)
    pbActivateWindow(@sprites, "list") {
      oldindex = -1
      loop do
        Graphics.update
        Input.update
        pbUpdateSpriteHash(@sprites)
        # Cursor moved, update display
        if @sprites["list"].index != oldindex
          contact = @contacts[@sprites["list"].index]
          if contact.trainer?
            filename = GameData::TrainerType.charset_filename(contact.trainer_type)
          else
            filename = sprintf("Graphics/Characters/phone%03d", contact.common_event_id)
          end
          @sprites["icon"].setBitmap(filename)
          charwidth  = @sprites["icon"].bitmap.width
          charheight = @sprites["icon"].bitmap.height
          @sprites["icon"].x        = 86 - (charwidth / 8)
          @sprites["icon"].y        = 134 - (charheight / 8)
          @sprites["icon"].src_rect = Rect.new(0, 0, charwidth / 4, charheight / 4)
          map_name = (contact.map_id > 0) ? pbGetMapNameFromId(contact.map_id) : ""
          @sprites["bottom"].text = "<ac>" + map_name
          @sprites["list"].page_item_max.times do |i|
            @sprites["rematch[#{i}]"].clearBitmaps
            j = i + @sprites["list"].top_item
            if j < @contacts.length && @contacts[j].can_rematch?
              @sprites["rematch[#{i}]"].setBitmap("Graphics/UI/Phone/icon_rematch")
            end
          end
        end
        # Get inputs
        if Input.trigger?(Input::BACK)
          pbPlayCloseMenuSE
          break
        elsif Input.trigger?(Input::USE)
          index = @sprites["list"].index
          Phone::Call.make_outgoing(@contacts[index]) if index >= 0
        end
      end
    }
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end
