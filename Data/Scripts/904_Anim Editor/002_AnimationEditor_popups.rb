#===============================================================================
#
#===============================================================================
class AnimationEditor
  def create_pop_up_window(width, height, ret = nil)
    if !ret
      ret = BitmapSprite.new(width + (BORDER_THICKNESS * 2),
                             height + (BORDER_THICKNESS * 2), @pop_up_viewport)
      ret.x = (WINDOW_WIDTH - ret.width) / 2
      ret.y = (WINDOW_HEIGHT - ret.height) / 2
      ret.z = -1
    end
    ret.bitmap.clear
    ret.bitmap.font.color = text_color
    ret.bitmap.font.size = text_size
    # Draw pop-up box border
    ret.bitmap.border_rect(BORDER_THICKNESS, BORDER_THICKNESS, width, height,
                           BORDER_THICKNESS, background_color, line_color)
    # Fill pop-up box with white
    ret.bitmap.fill_rect(BORDER_THICKNESS, BORDER_THICKNESS, width, height, background_color)
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
      btn.color_scheme = @color_scheme
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
      ret = :cancel if Input.triggerex?(:ESCAPE)
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

  def edit_animation_properties
    # Show pop-up window
    @pop_up_bg_bitmap.visible = true
    bg_bitmap = create_pop_up_window(ANIM_PROPERTIES_WIDTH, ANIM_PROPERTIES_HEIGHT)
    anim_properties = @components[:animation_properties]
    anim_properties.visible = true
    # Set control values
    case @anim[:type]
    when :move, :opp_move
      anim_properties.get_control(:type).value = :move
    when :common, :opp_common
      anim_properties.get_control(:type).value = :common
    end
    anim_properties.get_control(:opp_variant).value = ([:opp_move, :opp_common].include?(@anim[:type]))
    anim_properties.get_control(:version).value = @anim[:version] || 0
    anim_properties.get_control(:name).value = @anim[:name] || ""
    anim_properties.get_control(:pbs_path).value = (@anim[:pbs_path] || "unsorted") + ".txt"
    anim_properties.get_control(:has_user).value = !@anim[:no_user]
    anim_properties.get_control(:has_target).value = !@anim[:no_target]
    anim_properties.get_control(:usable).value = !(@anim[:ignore] || false)
    refresh_component(:animation_properties)   # This sets the :move control's value
    # Interaction loop
    ret = nil
    loop do
      Graphics.update
      Input.update
      anim_properties.update
      if anim_properties.changed?
        break if anim_properties.values.keys.include?(:close)
        anim_properties.values.each_pair do |property, value|
          apply_changed_value(:animation_properties, property, value)
        end
        anim_properties.clear_changed
      end
      break if !anim_properties.busy? && Input.triggerex?(:ESCAPE)
      anim_properties.repaint
    end
    # Dispose and return
    bg_bitmap.dispose
    @pop_up_bg_bitmap.visible = false
    anim_properties.clear_changed
    anim_properties.visible = false
  end

  #-----------------------------------------------------------------------------

  def edit_editor_settings
    # Show pop-up window
    @pop_up_bg_bitmap.visible = true
    bg_bitmap = create_pop_up_window(ANIM_PROPERTIES_WIDTH, ANIM_PROPERTIES_HEIGHT)
    editor_settings = @components[:editor_settings]
    editor_settings.visible = true
    # Set control values
    refresh_component(:editor_settings)
    editor_settings.get_control(:color_scheme).value = @settings[:color_scheme] || :light
    editor_settings.get_control(:side_size_1).value = @settings[:side_sizes][0]
    editor_settings.get_control(:side_size_2).value = @settings[:side_sizes][1]
    editor_settings.get_control(:user_index).value = @settings[:user_index]
    editor_settings.get_control(:target_indices).value = @settings[:target_indices].join(",")
    editor_settings.get_control(:user_opposes).value = @settings[:user_opposes]
    editor_settings.get_control(:canvas_bg).value = @settings[:canvas_bg]
    editor_settings.get_control(:user_sprite_name).value = @settings[:user_sprite_name]
    editor_settings.get_control(:target_sprite_name).value = @settings[:target_sprite_name]
    # Interaction loop
    ret = nil
    loop do
      Graphics.update
      Input.update
      editor_settings.update
      if editor_settings.changed?
        break if editor_settings.values.keys.include?(:close)
        editor_settings.values.each_pair do |property, value|
          apply_changed_value(:editor_settings, property, value)
          create_pop_up_window(ANIM_PROPERTIES_WIDTH, ANIM_PROPERTIES_HEIGHT, bg_bitmap)
        end
        editor_settings.clear_changed
      end
      break if !editor_settings.busy? && Input.triggerex?(:ESCAPE)
      editor_settings.repaint
    end
    # Dispose and return
    bg_bitmap.dispose
    @pop_up_bg_bitmap.visible = false
    editor_settings.clear_changed
    editor_settings.visible = false
  end

  #-----------------------------------------------------------------------------

  # Generates a list of all files in the given folder and its subfolders which
  # have a file extension that matches one in exts. Removes any files from the
  # list whose filename is the same as one in blacklist (case insensitive).
  def get_all_files_in_folder(folder, exts, blacklist = [])
    ret = []
    Dir.all(folder).each do |f|
      next if !exts.include?(File.extname(f))
      file = f.sub(folder + "/", "")
      ret.push([file.sub(File.extname(file), ""), file])
    end
    ret.delete_if { |f| blacklist.any? { |add| add.upcase == f[0].upcase } }
    ret.sort! { |a, b| a[0].downcase <=> b[0].downcase }
    return ret
  end

  def choose_graphic_file(selected)
    selected ||= ""
    sprite_folder = "Graphics/Battle animations"
    # Show pop-up window
    @pop_up_bg_bitmap.visible = true
    bg_bitmap = create_pop_up_window(GRAPHIC_CHOOSER_WINDOW_WIDTH, GRAPHIC_CHOOSER_WINDOW_HEIGHT)
    graphic_chooser = @components[:graphic_chooser]
    graphic_chooser.visible = true
    # Draw box around list control
    list = graphic_chooser.get_control(:list)
    # Get a list of files
    files = get_all_files_in_folder(
      sprite_folder, [".png", ".jpg", ".jpeg"],
      ["USER", "USER_OPP", "USER_FRONT", "USER_BACK", "TARGET", "TARGET_OPP", "TARGET_FRONT", "TARGET_BACK"]
    )
    if !@anim[:no_target]
      files.prepend(
        ["TARGET",       _INTL("[[Target's sprite]]")],
        ["TARGET_OPP",   _INTL("[[Target's other side sprite]]")],
        ["TARGET_FRONT", _INTL("[[Target's front sprite]]")],
        ["TARGET_BACK",  _INTL("[[Target's back sprite]]")]
      )
    end
    if !@anim[:no_user]
      files.prepend(
        ["USER",         _INTL("[[User's sprite]]")],
        ["USER_OPP",     _INTL("[[User's other side sprite]]")],
        ["USER_FRONT",   _INTL("[[User's front sprite]]")],
        ["USER_BACK",    _INTL("[[User's back sprite]]")]
      )
    end
    idx = 0
    files.each_with_index do |f, i|
      next if f[0] != selected
      idx = i
      break
    end
    # Set control values
    list.values = files
    list.selected = idx
    # Create sprite preview
    bg_bitmap.bitmap.outline_rect(BORDER_THICKNESS + list.x + list.width + 6,
                                  BORDER_THICKNESS + list.y,
                                  GRAPHIC_CHOOSER_PREVIEW_SIZE + 4, GRAPHIC_CHOOSER_PREVIEW_SIZE + 4,
                                  line_color)
    preview_sprite = Sprite.new(@pop_up_viewport)
    preview_sprite.x = graphic_chooser.x + list.x + list.width + 8 + (GRAPHIC_CHOOSER_PREVIEW_SIZE / 2)
    preview_sprite.y = graphic_chooser.y + list.y + 2 + (GRAPHIC_CHOOSER_PREVIEW_SIZE / 2)
    preview_bitmap = nil
    set_preview_graphic = lambda do |sprite, filename|
      preview_bitmap&.dispose
      folder = sprite_folder + "/"
      fname = filename
      if ["USER", "USER_BACK", "USER_FRONT", "USER_OPP",
          "TARGET", "TARGET_FRONT", "TARGET_BACK", "TARGET_OPP"].include?(filename)
        chunks = filename.split("_")
        fname = (chunks[0] == "USER") ? @settings[:user_sprite_name].to_s : @settings[:target_sprite_name].to_s
        case chunks[1] || ""
        when "", "OPP"
          if (chunks[0] == "USER") ^ (chunks[1] == "OPP")   # xor
            folder = (@settings[:user_opposes]) ? "Graphics/Pokemon/Front/" : "Graphics/Pokemon/Back/"
          else
            folder = (@settings[:user_opposes]) ? "Graphics/Pokemon/Back/" : "Graphics/Pokemon/Front/"
          end
        when "FRONT"
          folder = "Graphics/Pokemon/Front/"
        when "BACK"
          folder = "Graphics/Pokemon/Back/"
        end
      end
      preview_bitmap = AnimatedBitmap.new(folder + fname)
      bg_bitmap.bitmap.fill_rect(BORDER_THICKNESS + list.x + list.width + 8, BORDER_THICKNESS + list.y + 2,
                                 GRAPHIC_CHOOSER_PREVIEW_SIZE, GRAPHIC_CHOOSER_PREVIEW_SIZE,
                                 background_color)
      next if !preview_bitmap
      sprite.bitmap = preview_bitmap.bitmap
      zoom = [[GRAPHIC_CHOOSER_PREVIEW_SIZE.to_f / preview_bitmap.width,
              GRAPHIC_CHOOSER_PREVIEW_SIZE.to_f / preview_bitmap.height].min, 1.0].min
      sprite.zoom_x = sprite.zoom_y = zoom
      sprite.ox = sprite.width / 2
      sprite.oy = sprite.height / 2
      bg_bitmap.bitmap.fill_rect(BORDER_THICKNESS + sprite.x - graphic_chooser.x - (sprite.width * sprite.zoom_x / 2).round,
                                 BORDER_THICKNESS + sprite.y - graphic_chooser.y - (sprite.height * sprite.zoom_y / 2).round,
                                 sprite.width * sprite.zoom_x, sprite.height * sprite.zoom_y,
                                 Color.magenta)
    end
    set_preview_graphic.call(preview_sprite, list.value)
    # Interaction loop
    ret = nil
    loop do
      Graphics.update
      Input.update
      graphic_chooser.update
      if graphic_chooser.changed?
        graphic_chooser.values.each_pair do |ctrl, value|
          case ctrl
          when :ok
            ret = list.value
          when :cancel
            ret = selected
          when :list
            set_preview_graphic.call(preview_sprite, list.value)
          end
          graphic_chooser.clear_changed
        end
        break if ret
        graphic_chooser.repaint
      end
      if !graphic_chooser.busy? && Input.triggerex?(:ESCAPE)
        ret = selected
        break
      end
    end
    # Dispose and return
    bg_bitmap.dispose
    preview_sprite.dispose
    preview_bitmap&.dispose
    @pop_up_bg_bitmap.visible = false
    graphic_chooser.clear_changed
    graphic_chooser.visible = false
    return ret
  end

  #-----------------------------------------------------------------------------

  def choose_audio_file(selected, volume = 100, pitch = 100)
    selected ||= ""
    audio_folder = "Audio/SE/Anim"
    # Show pop-up window
    @pop_up_bg_bitmap.visible = true
    bg_bitmap = create_pop_up_window(AUDIO_CHOOSER_WINDOW_WIDTH, AUDIO_CHOOSER_WINDOW_HEIGHT)
    audio_chooser = @components[:audio_chooser]
    audio_chooser.visible = true
    # Draw box around list control
    list = audio_chooser.get_control(:list)
    # Get a list of files
    files = get_all_files_in_folder(audio_folder, [".wav", ".ogg", ".mp3", ".wma"], ["USER", "TARGET"])
    files.prepend(["TARGET", _INTL("[[Target's cry]]")]) if !@anim[:no_target]
    files.prepend(["USER",  _INTL("[[User's cry]]")]) if !@anim[:no_user]
    idx = 0
    files.each_with_index do |f, i|
      next if f[0] != selected
      idx = i
      break
    end
    # Set control values
    list.values = files
    list.selected = idx
    audio_chooser.get_control(:volume).value = volume
    audio_chooser.get_control(:pitch).value = pitch
    # Interaction loop
    ret = nil
    cancel = false
    loop do
      Graphics.update
      Input.update
      audio_chooser.update
      if audio_chooser.changed?
        audio_chooser.values.each_pair do |ctrl, value|
          case ctrl
          when :ok
            ret = list.value
          when :cancel
            ret = selected
            cancel = true
          when :play
            vol = audio_chooser.get_control(:volume).value
            ptch = audio_chooser.get_control(:pitch).value
            case list.value
            when "USER"
              Pokemon.play_cry(@settings[:user_sprite_name])
            when "TARGET"
              Pokemon.play_cry(@settings[:target_sprite_name])
            else
              pbSEPlay(RPG::AudioFile.new("Anim/" + list.value, vol, ptch))
            end
          when :stop
            pbSEStop
          end
          audio_chooser.clear_changed
        end
        break if ret
        audio_chooser.repaint
      end
      if !audio_chooser.busy? && Input.triggerex?(:ESCAPE)
        ret = selected
        cancel = true
        break
      end
    end
    vol = (cancel) ? volume : audio_chooser.get_control(:volume).value
    ptch = (cancel) ? pitch : audio_chooser.get_control(:pitch).value
    # Dispose and return
    bg_bitmap.dispose
    @pop_up_bg_bitmap.visible = false
    audio_chooser.clear_changed
    audio_chooser.visible = false
    return [ret, vol, ptch]
  end
end
