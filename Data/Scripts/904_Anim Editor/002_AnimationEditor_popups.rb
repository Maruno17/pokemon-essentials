#===============================================================================
#
#===============================================================================
class AnimationEditor
  MESSAGE_BOX_WIDTH         = WINDOW_WIDTH * 3 / 4
  MESSAGE_BOX_HEIGHT        = 160
  MESSAGE_BOX_BUTTON_WIDTH  = 150
  MESSAGE_BOX_BUTTON_HEIGHT = 32
  MESSAGE_BOX_SPACING       = 16

  GRAPHIC_CHOOSER_BUTTON_WIDTH     = 150
  GRAPHIC_CHOOSER_BUTTON_HEIGHT    = MESSAGE_BOX_BUTTON_HEIGHT
  GRAPHIC_CHOOSER_FILE_LIST_WIDTH  = GRAPHIC_CHOOSER_BUTTON_WIDTH * 2
  GRAPHIC_CHOOSER_FILE_LIST_HEIGHT = 15 * UIControls::List::ROW_HEIGHT
  GRAPHIC_CHOOSER_PREVIEW_SIZE     = 320
  GRAPHIC_CHOOSER_WINDOW_WIDTH     = GRAPHIC_CHOOSER_FILE_LIST_WIDTH + GRAPHIC_CHOOSER_PREVIEW_SIZE + (MESSAGE_BOX_SPACING * 2) + 8
  GRAPHIC_CHOOSER_WINDOW_HEIGHT    = GRAPHIC_CHOOSER_FILE_LIST_HEIGHT + GRAPHIC_CHOOSER_BUTTON_HEIGHT + 24 + (MESSAGE_BOX_SPACING * 2) + 2

  def create_pop_up_window(width, height)
    ret = BitmapSprite.new(width, height, @pop_up_viewport)
    ret.x = (WINDOW_WIDTH - width) / 2
    ret.y = (WINDOW_HEIGHT - height) / 2
    ret.z = -1
    ret.bitmap.font.color = Color.black
    ret.bitmap.font.size = 18
    # Draw message box border
    BORDER_THICKNESS.times do |i|
      col = (i.even?) ? Color.black : Color.white
      ret.bitmap.outline_rect(i, i, ret.width - (i * 2), ret.height - (i * 2), col)
    end
    # Fill message box with white
    ret.bitmap.fill_rect(BORDER_THICKNESS, BORDER_THICKNESS,
                         ret.width - (BORDER_THICKNESS * 2),
                         ret.height - (BORDER_THICKNESS * 2),
                         Color.white)
    return ret
  end

  #-----------------------------------------------------------------------------

  def message(text, *options)
    @pop_up_bg_bitmap.visible = true
    msg_bitmap = create_pop_up_window(MESSAGE_BOX_WIDTH, MESSAGE_BOX_HEIGHT)
    # Draw text
    text_size = msg_bitmap.bitmap.text_size(text)
    msg_bitmap.bitmap.draw_text(0, (msg_bitmap.height / 2) - MESSAGE_BOX_BUTTON_HEIGHT,
                                msg_bitmap.width, text_size.height, text, 1)
    # Create buttons
    buttons = []
    options.each_with_index do |option, i|
      btn = UIControls::Button.new(MESSAGE_BOX_BUTTON_WIDTH, MESSAGE_BOX_BUTTON_HEIGHT, @pop_up_viewport, option[1])
      btn.x = msg_bitmap.x + (msg_bitmap.width - (MESSAGE_BOX_BUTTON_WIDTH * options.length)) / 2
      btn.x += MESSAGE_BOX_BUTTON_WIDTH * i
      btn.y = msg_bitmap.y + msg_bitmap.height - MESSAGE_BOX_BUTTON_HEIGHT - MESSAGE_BOX_SPACING
      btn.set_fixed_size
      btn.set_interactive_rects
      buttons.push([option[0], btn])
    end
    # Interaction loop
    ret = nil
    captured = nil
    loop do
      Graphics.update
      Input.update
      if captured
        captured.update
        captured = nil if !captured.busy?
      else
        buttons.each do |btn|
          btn[1].update
          captured = btn[1] if btn[1].busy?
        end
      end
      buttons.each do |btn|
        next if !btn[1].changed?
        ret = btn[0]
        break
      end
      ret = :cancel if Input.trigger?(Input::BACK)
      break if ret
      buttons.each { |btn| btn[1].repaint }
    end
    # Dispose and return
    buttons.each { |btn| btn[1].dispose }
    buttons.clear
    msg_bitmap.dispose
    @pop_up_bg_bitmap.visible = false
    return ret
  end

  def confirm_message(text)
    return message(text, [:yes, _INTL("Yes")], [:no, _INTL("No")]) == :yes
  end

  #-----------------------------------------------------------------------------

  def choose_graphic_file(selected)
    selected ||= ""
    sprite_folder = "Graphics/Battle animations/"
    # Get a list of files
    files = []
    Dir.chdir(sprite_folder) do
      Dir.glob("*.png") { |f| files.push([File.basename(f, ".*"), f]) }
      Dir.glob("*.jpg") { |f| files.push([File.basename(f, ".*"), f]) }
      Dir.glob("*.jpeg") { |f| files.push([File.basename(f, ".*"), f]) }
    end
    files.delete_if { |f| ["USER", "USER_OPP", "USER_FRONT", "USER_BACK",
                           "TARGET", "TARGET_OPP", "TARGET_FRONT",
                           "TARGET_BACK"].include?(f[0].upcase) }
    files.sort! { |a, b| a[0].downcase <=> b[0].downcase }
    files.prepend(["USER",         _INTL("[[User's sprite]]")],
                  ["USER_OPP",     _INTL("[[User's other side sprite]]")],
                  ["USER_FRONT",   _INTL("[[User's front sprite]]")],
                  ["USER_BACK",    _INTL("[[User's back sprite]]")],
                  ["TARGET",       _INTL("[[Target's sprite]]")],
                  ["TARGET_OPP",   _INTL("[[Target's other side sprite]]")],
                  ["TARGET_FRONT", _INTL("[[Target's front sprite]]")],
                  ["TARGET_BACK",  _INTL("[[Target's back sprite]]")])
    idx = 0
    files.each_with_index do |f, i|
      next if f[0] != selected
      idx = i
      break
    end
    # Show pop-up window
    @pop_up_bg_bitmap.visible = true
    bg_bitmap = create_pop_up_window(GRAPHIC_CHOOSER_WINDOW_WIDTH, GRAPHIC_CHOOSER_WINDOW_HEIGHT)
    text = _INTL("Choose a file...")
    text_size = bg_bitmap.bitmap.text_size(text)
    bg_bitmap.bitmap.draw_text(MESSAGE_BOX_SPACING, 11, bg_bitmap.width, text_size.height, text, 0)
    # Create list of files
    list = UIControls::List.new(GRAPHIC_CHOOSER_FILE_LIST_WIDTH, GRAPHIC_CHOOSER_FILE_LIST_HEIGHT, @pop_up_viewport, files)
    list.x = bg_bitmap.x + MESSAGE_BOX_SPACING
    list.y = bg_bitmap.y + MESSAGE_BOX_SPACING + 24
    list.selected = idx
    list.set_interactive_rects
    list.repaint
    bg_bitmap.bitmap.outline_rect(MESSAGE_BOX_SPACING - 2, MESSAGE_BOX_SPACING + 24 - 2,
                                  GRAPHIC_CHOOSER_FILE_LIST_WIDTH + 4, GRAPHIC_CHOOSER_FILE_LIST_HEIGHT + 4, Color.black)
    # Create buttons
    buttons = []
    [[:ok, _INTL("OK")], [:cancel, _INTL("Cancel")]].each_with_index do |option, i|
      btn = UIControls::Button.new(GRAPHIC_CHOOSER_BUTTON_WIDTH, MESSAGE_BOX_BUTTON_HEIGHT, @pop_up_viewport, option[1])
      btn.x = list.x + (GRAPHIC_CHOOSER_BUTTON_WIDTH * i)
      btn.y = list.y + list.height + 2
      btn.set_fixed_size
      btn.set_interactive_rects
      buttons.push([option[0], btn])
    end
    # Create sprite preview
    bg_bitmap.bitmap.outline_rect(MESSAGE_BOX_SPACING + list.width + 6, MESSAGE_BOX_SPACING + 24 - 2,
                                  GRAPHIC_CHOOSER_PREVIEW_SIZE + 4, GRAPHIC_CHOOSER_PREVIEW_SIZE + 4,
                                  Color.black)
    preview_sprite = Sprite.new(@pop_up_viewport)
    preview_sprite.x = list.x + list.width + 8 + (GRAPHIC_CHOOSER_PREVIEW_SIZE / 2)
    preview_sprite.y = list.y + (GRAPHIC_CHOOSER_PREVIEW_SIZE / 2)
    preview_bitmap = nil
    set_preview_graphic = lambda do |sprite, filename|
      preview_bitmap&.dispose
      # TODO: When the canvas works, use the proper user's/target's sprite here.
      case filename
      when "USER", "USER_BACK", "TARGET_BACK", "TARGET_OPP"
        preview_bitmap = AnimatedBitmap.new("Graphics/Pokemon/Back/" + "000")
      when "TARGET", "TARGET_FRONT", "USER_FRONT", "USER_OPP"
        preview_bitmap = AnimatedBitmap.new("Graphics/Pokemon/Front/" + "000")
      else
        preview_bitmap = AnimatedBitmap.new(sprite_folder + filename)
      end
      bg_bitmap.bitmap.fill_rect(MESSAGE_BOX_SPACING + list.width + 8, MESSAGE_BOX_SPACING + 24,
                                 GRAPHIC_CHOOSER_PREVIEW_SIZE, GRAPHIC_CHOOSER_PREVIEW_SIZE,
                                 Color.white)
      next if !preview_bitmap
      sprite.bitmap = preview_bitmap.bitmap
      zoom = [[GRAPHIC_CHOOSER_PREVIEW_SIZE.to_f / preview_bitmap.width,
              GRAPHIC_CHOOSER_PREVIEW_SIZE.to_f / preview_bitmap.height].min, 1.0].min
      sprite.zoom_x = sprite.zoom_y = zoom
      sprite.ox = sprite.width / 2
      sprite.oy = sprite.height / 2
      bg_bitmap.bitmap.fill_rect(MESSAGE_BOX_SPACING + list.width + 8 + (GRAPHIC_CHOOSER_PREVIEW_SIZE / 2) - (sprite.width * sprite.zoom_x / 2),
                                 MESSAGE_BOX_SPACING + 24 + (GRAPHIC_CHOOSER_PREVIEW_SIZE / 2) - (sprite.height * sprite.zoom_y / 2),
                                 sprite.width * sprite.zoom_x, sprite.height * sprite.zoom_y,
                                 Color.magenta)
    end
    set_preview_graphic.call(preview_sprite, list.value)
    # Interaction loop
    ret = nil
    captured = nil
    loop do
      Graphics.update
      Input.update
      if captured
        captured.update
        captured = nil if !captured.busy?
      else
        list.update
        captured = list if list.busy?
        buttons.each do |btn|
          btn[1].update
          captured = btn[1] if btn[1].busy?
        end
      end
      if list.changed?
        set_preview_graphic.call(preview_sprite, list.value)
        list.clear_changed
      end
      buttons.each do |btn|
        next if !btn[1].changed?
        ret = list.value if btn[0] == :ok
        ret = selected if btn[0] == :cancel
        break
      end
      ret = selected if Input.trigger?(Input::BACK)
      break if ret
      list.repaint
      buttons.each { |btn| btn[1].repaint }
    end
    # Dispose and return
    list.dispose
    buttons.each { |btn| btn[1].dispose }
    buttons.clear
    bg_bitmap.dispose
    preview_sprite.dispose
    preview_bitmap&.dispose
    @pop_up_bg_bitmap.visible = false
    return ret
  end

  #-----------------------------------------------------------------------------

  def choose_audio_file(selected, volume = 100, pitch = 100)
    selected ||= ""
    sprite_folder = "Audio/SE/Anim/"
    # Get a list of files
    files = []
    Dir.chdir(sprite_folder) do
      Dir.glob("*.wav") { |f| files.push([File.basename(f, ".*"), f]) }
      Dir.glob("*.ogg") { |f| files.push([File.basename(f, ".*"), f]) }
      Dir.glob("*.mp3") { |f| files.push([File.basename(f, ".*"), f]) }
      Dir.glob("*.wma") { |f| files.push([File.basename(f, ".*"), f]) }
    end
    files.delete_if { |f| ["USER", "TARGET"].include?(f[0].upcase) }
    files.sort! { |a, b| a[0].downcase <=> b[0].downcase }
    files.prepend(["USER",   _INTL("[[User's cry]]")],
                  ["TARGET", _INTL("[[Target's cry]]")])
    idx = 0
    files.each_with_index do |f, i|
      next if f[0] != selected
      idx = i
      break
    end
    # Show pop-up window
    @pop_up_bg_bitmap.visible = true
    bg_bitmap = create_pop_up_window(GRAPHIC_CHOOSER_WINDOW_WIDTH - 24, GRAPHIC_CHOOSER_WINDOW_HEIGHT)
    text = _INTL("Choose a file...")
    text_size = bg_bitmap.bitmap.text_size(text)
    bg_bitmap.bitmap.draw_text(MESSAGE_BOX_SPACING, 11, bg_bitmap.width, text_size.height, text, 0)
    # Create list of files
    list = UIControls::List.new(GRAPHIC_CHOOSER_FILE_LIST_WIDTH, GRAPHIC_CHOOSER_FILE_LIST_HEIGHT, @pop_up_viewport, files)
    list.x = bg_bitmap.x + MESSAGE_BOX_SPACING
    list.y = bg_bitmap.y + MESSAGE_BOX_SPACING + 24
    list.selected = idx
    list.set_interactive_rects
    list.repaint
    bg_bitmap.bitmap.outline_rect(MESSAGE_BOX_SPACING - 2, MESSAGE_BOX_SPACING + 24 - 2,
                                  GRAPHIC_CHOOSER_FILE_LIST_WIDTH + 4, GRAPHIC_CHOOSER_FILE_LIST_HEIGHT + 4, Color.black)
    # Create buttons
    buttons = []
    [[:ok, _INTL("OK")], [:cancel, _INTL("Cancel")]].each_with_index do |option, i|
      btn = UIControls::Button.new(GRAPHIC_CHOOSER_BUTTON_WIDTH, MESSAGE_BOX_BUTTON_HEIGHT, @pop_up_viewport, option[1])
      btn.x = list.x + (GRAPHIC_CHOOSER_BUTTON_WIDTH * i)
      btn.y = list.y + list.height + 2
      btn.set_fixed_size
      btn.set_interactive_rects
      buttons.push([option[0], btn])
    end
    # Create audio player controls
    [[:volume, _INTL("Volume"), 0, 100], [:pitch, _INTL("Pitch"), 0, 200]].each_with_index do |option, i|
      label = UIControls::Label.new(90, 28, @pop_up_viewport, option[1])
      label.x = list.x + list.width + 8
      label.y = list.y + (28 * i)
      label.set_interactive_rects
      buttons.push([(option[0].to_s + "_label").to_sym, label])
      slider = UIControls::NumberSlider.new(250, 28, @pop_up_viewport, option[2], option[3], (i == 0 ? volume : pitch))
      slider.x = list.x + list.width + 8 + label.width
      slider.y = list.y + (28 * i)
      slider.set_interactive_rects
      buttons.push([option[0], slider])
    end
    [[:play, _INTL("Play")], [:stop, _INTL("Stop")]].each_with_index do |option, i|
      btn = UIControls::Button.new(GRAPHIC_CHOOSER_BUTTON_WIDTH, MESSAGE_BOX_BUTTON_HEIGHT, @pop_up_viewport, option[1])
      btn.x = list.x + list.width + 8 + (GRAPHIC_CHOOSER_BUTTON_WIDTH * i)
      btn.y = list.y + (28 * 2)
      btn.set_fixed_size
      btn.set_interactive_rects
      buttons.push([option[0], btn])
    end
    # Interaction loop
    ret = nil
    captured = nil
    loop do
      Graphics.update
      Input.update
      if captured
        captured.update
        captured = nil if !captured.busy?
      else
        list.update
        captured = list if list.busy?
        buttons.each do |btn|
          btn[1].update
          captured = btn[1] if btn[1].busy?
        end
      end
      buttons.each do |btn|
        next if !btn[1].changed?
        case btn[0]
        when :ok
          ret = list.value
        when :cancel
          ret = selected
        when :play
          vol = buttons.select { |b| b[0] == :volume }[0][1].value
          ptch = buttons.select { |b| b[0] == :pitch }[0][1].value
          # TODO: Play appropriate things if a cry is selected.
          pbSEPlay(RPG::AudioFile.new("Anim/" + list.value, vol, ptch))
        when :stop
          pbSEStop
        end
        btn[1].clear_changed
        break
      end
      ret = selected if Input.trigger?(Input::BACK)
      break if ret
      list.repaint
      buttons.each { |btn| btn[1].repaint }
    end
    vol = buttons.select { |b| b[0] == :volume }[0][1].value
    ptch = buttons.select { |b| b[0] == :pitch }[0][1].value
    # Dispose and return
    list.dispose
    buttons.each { |btn| btn[1].dispose }
    buttons.clear
    bg_bitmap.dispose
    @pop_up_bg_bitmap.visible = false
    return [ret, vol, ptch]
  end
end
