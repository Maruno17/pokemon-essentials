# TODO: Choosable icons/marks for each contact?
# TODO: Allow rearranging contacts.
#===============================================================================
# Phone list of contacts
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
class PokemonPhone_Scene
  def pbStartScene
    @sprites = {}
    # Create viewport
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    # Background
    addBackgroundPlane(@sprites, "bg", "Phone/bg", @viewport)
    # List of contacts
    @sprites["list"] = Window_PhoneList.newEmpty(152, 32, Graphics.width - 142, Graphics.height - 80, @viewport)
    @sprites["list"].windowskin = nil
    # Rematch readiness icons
    if Phone.rematches_enabled
      @sprites["list"].page_item_max.times do |i|
        @sprites["rematch_#{i}"] = IconSprite.new(468, 62 + (i * 32), @viewport)
      end
    end
    # Phone signal icon
    @sprites["signal"] = IconSprite.new(Graphics.width - 32, 0, @viewport)
    if Phone::Call.can_make?
      @sprites["signal"].setBitmap("Graphics/UI/Phone/icon_signal")
    else
      @sprites["signal"].setBitmap("Graphics/UI/Phone/icon_nosignal")
    end
    # Title text
    @sprites["header"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Phone"), 2, -18, 128, 64, @viewport
    )
    @sprites["header"].baseColor   = Color.new(248, 248, 248)
    @sprites["header"].shadowColor = Color.black
    @sprites["header"].windowskin = nil
    # Info text about all contacts
    @sprites["info"] = Window_AdvancedTextPokemon.newWithSize("", -8, 224, 180, 160, @viewport)
    @sprites["info"].windowskin = nil
    # Portrait of contact
    @sprites["icon"] = IconSprite.new(70, 102, @viewport)
    # Contact's location text
    @sprites["bottom"] = Window_AdvancedTextPokemon.newWithSize(
      "", 162, Graphics.height - 64, Graphics.width - 158, 64, @viewport
    )
    @sprites["bottom"].windowskin = nil
    # Start scene
    pbRefreshList
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbRefreshList
    @contacts = []
    $PokemonGlobal.phone.contacts.each do |contact|
      @contacts.push(contact) if contact.visible?
    end
    # Create list of commands (display names of contacts) and count rematches
    commands = []
    rematch_count = 0
    @contacts.each do |contact|
      commands.push(contact.display_name)
      rematch_count += 1 if contact.can_rematch?
    end
    # Set list's commands
    @sprites["list"].commands = commands
    @sprites["list"].index = commands.length - 1 if @sprites["list"].index >= commands.length
    if @sprites["list"].top_row > @sprites["list"].itemCount - @sprites["list"].page_item_max - 1
      @sprites["list"].top_row = @sprites["list"].itemCount - @sprites["list"].page_item_max - 1
    end
    # Set info text
    infotext = _INTL("Registered<br>")
    infotext += _INTL(" <r>{1}<br>", @sprites["list"].commands.length)
    infotext += _INTL("Waiting for a rematch<r>{1}", rematch_count)
    @sprites["info"].text = infotext
    pbRefreshScreen
  end

  def pbRefreshScreen
    # Redraw rematch readiness icons
    if @sprites["rematch_0"]
      @sprites["list"].page_item_max.times do |i|
        @sprites["rematch_#{i}"].clearBitmaps
        j = i + @sprites["list"].top_item
        if j < @contacts.length && @contacts[j].can_rematch?
          @sprites["rematch_#{i}"].setBitmap("Graphics/UI/Phone/icon_rematch")
        end
      end
    end
    # Get the selected contact
    contact = @contacts[@sprites["list"].index]
    if contact
      # Redraw contact's portrait
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
      # Redraw contact's location text
      map_name = (contact.map_id > 0) ? pbGetMapNameFromId(contact.map_id) : ""
      @sprites["bottom"].text = "<ac>" + map_name
    else
      @sprites["icon"].setBitmap(nil)
      @sprites["bottom"].text = ""
    end
  end

  def pbChooseContact
    pbActivateWindow(@sprites, "list") {
      index = -1
      loop do
        Graphics.update
        Input.update
        pbUpdateSpriteHash(@sprites)
        # Cursor moved, update display
        pbRefreshScreen if @sprites["list"].index != index
        index = @sprites["list"].index
        # Get inputs
        if Input.trigger?(Input::BACK)
          pbPlayCloseMenuSE
          return nil
        elsif Input.trigger?(Input::USE)
          return @contacts[index] if index >= 0
        end
      end
    }
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end
end

#===============================================================================
#
#===============================================================================
class PokemonPhoneScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    if $PokemonGlobal.phone.contacts.none? { |con| con.visible? }
      pbMessage(_INTL("There are no phone numbers stored."))
      return
    end
    @scene.pbStartScene
    loop do
      contact = @scene.pbChooseContact
      break if !contact
      commands = []
      commands.push(_INTL("Call"))
      commands.push(_INTL("Delete")) if contact.can_hide?
      commands.push(_INTL("Cancel"))
      cmd = pbShowCommands(nil, commands, -1)
      cmd -= 1 if cmd >=1 && !contact.can_hide?
      case cmd
      when 0   # Call
        Phone::Call.make_outgoing(contact)
      when 1   # Delete
        name = contact.display_name
        if pbConfirmMessage(_INTL("Are you sure you want to delete {1} from your phone?", name))
          contact.visible = false
          @scene.pbRefreshList
          pbMessage(_INTL("{1} was deleted from your phone contacts.", name))
          if $PokemonGlobal.phone.contacts.none? { |con| con.visible? }
            pbMessage(_INTL("There are no phone numbers stored."))
            break
          end
        end
      end
    end
    @scene.pbEndScene
  end
end
