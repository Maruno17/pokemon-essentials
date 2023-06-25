#===============================================================================
# Phone list of contacts
#===============================================================================
class Window_PhoneList < Window_CommandPokemon
  attr_accessor :switching

  def drawCursor(index, rect)
    if self.index == index
      selarrow = AnimatedBitmap.new("Graphics/UI/Phone/cursor")
      pbCopyBitmap(self.contents, selarrow.bitmap, rect.x, rect.y + 2)
    end
    return Rect.new(rect.x + 28, rect.y + 8, rect.width - 16, rect.height)
  end

  def drawItem(index, count, rect)
    return if index >= self.top_row + self.page_item_max
    if self.index == index && @switching
      rect = drawCursor(index, rect)
      pbDrawShadowText(self.contents, rect.x, rect.y + (self.contents.text_offset_y || 0),
                       rect.width, rect.height, @commands[index], Color.new(224, 0, 0), Color.new(224, 144, 144))
    else
      super
    end
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
    if @sprites["list"].top_row > @sprites["list"].itemCount - @sprites["list"].page_item_max
      @sprites["list"].top_row = @sprites["list"].itemCount - @sprites["list"].page_item_max
    end
    # Set info text
    infotext = _INTL("Registered") + "<br>"
    infotext += "<r>" + @sprites["list"].commands.length.to_s + "<br>"
    infotext += _INTL("Waiting for a rematch") + "<r>" + rematch_count.to_s
    @sprites["info"].text = infotext
    pbRefreshScreen
  end

  def pbRefreshScreen
    @sprites["list"].refresh
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
    pbActivateWindow(@sprites, "list") do
      index = -1
      switch_index = -1
      loop do
        Graphics.update
        Input.update
        pbUpdateSpriteHash(@sprites)
        # Cursor moved, update display
        if @sprites["list"].index != index
          if switch_index >= 0
            real_contacts = $PokemonGlobal.phone.contacts
            real_contacts.insert(@sprites["list"].index, real_contacts.delete_at(index))
            pbRefreshList
          else
            pbRefreshScreen
          end
        end
        index = @sprites["list"].index
        # Get inputs
        if switch_index >= 0
          if Input.trigger?(Input::ACTION) ||
             Input.trigger?(Input::USE)
            pbPlayDecisionSE
            @sprites["list"].switching = false
            switch_index = -1
            pbRefreshScreen
          elsif Input.trigger?(Input::BACK)
            pbPlayCancelSE
            real_contacts = $PokemonGlobal.phone.contacts
            real_contacts.insert(switch_index, real_contacts.delete_at(@sprites["list"].index))
            @sprites["list"].index = switch_index
            @sprites["list"].switching = false
            switch_index = -1
            pbRefreshList
          end
        else
          if Input.trigger?(Input::ACTION)
            switch_index = @sprites["list"].index
            @sprites["list"].switching = true
            pbRefreshScreen
          elsif Input.trigger?(Input::BACK)
            pbPlayCloseMenuSE
            return nil
          elsif Input.trigger?(Input::USE)
            return @contacts[index] if index >= 0
          end
        end
      end
    end
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
      commands.push(_INTL("Sort Contacts"))
      commands.push(_INTL("Cancel"))
      cmd = pbShowCommands(nil, commands, -1)
      cmd += 1 if cmd >= 1 && !contact.can_hide?
      case cmd
      when 0   # Call
        Phone::Call.make_outgoing(contact)
      when 1   # Delete
        name = contact.display_name
        if pbConfirmMessage(_INTL("Are you sure you want to delete {1} from your phone?", name))
          contact.visible = false
          $PokemonGlobal.phone.sort_contacts
          @scene.pbRefreshList
          pbMessage(_INTL("{1} was deleted from your phone contacts.", name))
          if $PokemonGlobal.phone.contacts.none? { |con| con.visible? }
            pbMessage(_INTL("There are no phone numbers stored."))
            break
          end
        end
      when 2   # Sort Contacts
        case pbMessage(_INTL("How do you want to sort the contacts?"),
                       [_INTL("By name"),
                        _INTL("By Trainer type"),
                        _INTL("Special contacts first"),
                        _INTL("Cancel")], -1, nil, 0)
        when 0   # By name
          $PokemonGlobal.phone.contacts.sort! { |a, b| a.name <=> b.name }
          $PokemonGlobal.phone.sort_contacts
          @scene.pbRefreshList
        when 1   # By trainer type
          $PokemonGlobal.phone.contacts.sort! { |a, b| a.display_name <=> b.display_name }
          $PokemonGlobal.phone.sort_contacts
          @scene.pbRefreshList
        when 2   # Special contacts first
          new_contacts = []
          2.times do |i|
            $PokemonGlobal.phone.contacts.each do |con|
              next if (i == 0 && con.trainer?) || (i == 1 && !con.trainer?)
              new_contacts.push(con)
            end
          end
          $PokemonGlobal.phone.contacts = new_contacts
          $PokemonGlobal.phone.sort_contacts
          @scene.pbRefreshList
        end
      end
    end
    @scene.pbEndScene
  end
end
