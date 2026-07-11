#===============================================================================
#
#===============================================================================
class AnimationEditor
  def create_pop_up_window(width, height, ret = nil)
    if !ret
      ret = BitmapSprite.new(width + (CONTAINER_BORDER * 2),
                             height + (CONTAINER_BORDER * 2), @pop_up_viewport)
      ret.x = (WINDOW_WIDTH - ret.width) / 2
      ret.y = (WINDOW_HEIGHT - ret.height) / 2
      ret.z = -1
    end
    ret.bitmap.clear
    ret.bitmap.font.color = get_color_of(:text)
    ret.bitmap.font.size = text_size
    # Draw pop-up box border
    ret.bitmap.border_rect(CONTAINER_BORDER, CONTAINER_BORDER, width, height,
                           CONTAINER_BORDER, get_color_of(:background), get_color_of(:line))
    # Fill pop-up box with white
    ret.bitmap.fill_rect(CONTAINER_BORDER, CONTAINER_BORDER, width, height, get_color_of(:background))
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
    button_spacing = 2
    buttons = []
    options.each_with_index do |option, i|
      btn = UIControls::Button.new(MESSAGE_BOX_BUTTON_WIDTH, MESSAGE_BOX_BUTTON_HEIGHT, @pop_up_viewport, option[1])
      btn.x = msg_bitmap.x + ((msg_bitmap.width - ((MESSAGE_BOX_BUTTON_WIDTH + button_spacing) * options.length)) / 2) + (button_spacing / 2)
      btn.x += (MESSAGE_BOX_BUTTON_WIDTH + button_spacing) * i
      btn.y = msg_bitmap.y + msg_bitmap.height - MESSAGE_BOX_BUTTON_HEIGHT - MESSAGE_BOX_SPACING
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

  def help_window
    # Show pop-up window
    help_window = @components[:help]
    help_window.visible = true
    @pop_up_bg_bitmap.visible = true
    bg_bitmap = create_pop_up_window(HELP_WIDTH, HELP_HEIGHT)
    # Interaction loop
    ret = nil
    loop do
      Graphics.update
      Input.update
      help_window.update
      break if help_window.changed? && help_window.changed_controls.has_key?(:close)
      help_window.clear_changed
      break if !help_window.busy? && Input.triggerex?(:ESCAPE)
      help_window.repaint
    end
    # Dispose and return
    bg_bitmap.dispose
    @pop_up_bg_bitmap.visible = false
    help_window.clear_changed
    help_window.visible = false
  end

  #-----------------------------------------------------------------------------

  def edit_editor_settings
    # Show pop-up window
    editor_settings = @components[:editor_settings]
    editor_settings.visible = true
    @pop_up_bg_bitmap.visible = true
    bg_bitmap = create_pop_up_window(EDITOR_SETTINGS_WIDTH, EDITOR_SETTINGS_HEIGHT)
    # Set control values
    refresh_component(:editor_settings)
    # Interaction loop
    loop do
      Graphics.update
      Input.update
      editor_settings.update
      if editor_settings.changed?
        break if editor_settings.changed_controls.has_key?(:close)
        editor_settings.changed_controls.each_pair do |property, value|
          apply_changed_value(:editor_settings, property, value)
          create_pop_up_window(EDITOR_SETTINGS_WIDTH, EDITOR_SETTINGS_HEIGHT, bg_bitmap)
          @pop_up_bg_bitmap.visible = true
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
    add_to_change_history
  end

  #-----------------------------------------------------------------------------

  def edit_animation_properties
    # Show pop-up window
    anim_properties = @components[:animation_properties]
    anim_properties.visible = true
    @pop_up_bg_bitmap.visible = true
    bg_bitmap = create_pop_up_window(ANIM_PROPERTIES_WIDTH, ANIM_PROPERTIES_HEIGHT)
    # Set control values
    refresh_component(:animation_properties)
    # Interaction loop
    loop do
      Graphics.update
      Input.update
      anim_properties.update
      if anim_properties.changed?
        break if anim_properties.changed_controls.has_key?(:close)
        anim_properties.changed_controls.each_pair do |property, value|
          apply_changed_value(:animation_properties, property, value)
          @pop_up_bg_bitmap.visible = true
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
    add_to_change_history
  end

  #-----------------------------------------------------------------------------

  def edit_particle_properties(idx_particle = -1)
    idx_particle = particle_index if idx_particle < 0
    this_particle = @anim[:particles][idx_particle]
    # Show pop-up window
    part_properties = @components[:particle_properties]
    part_properties.visible = true
    @pop_up_bg_bitmap.visible = true
    bg_bitmap = create_pop_up_window(PARTICLE_PROPERTIES_WIDTH, PARTICLE_PROPERTIES_HEIGHT)
    # Set control values
    refresh_component(:particle_properties, idx_particle)
    # Interaction loop
    loop do
      Graphics.update
      Input.update
      part_properties.update
      if part_properties.changed?
        break if part_properties.changed_controls.has_key?(:close)
        break if part_properties.changed_controls.has_key?(:delete)
        part_properties.changed_controls.each_pair do |property, value|
          apply_changed_value(:particle_properties, property, [idx_particle, value])
          idx_particle += 1 if property == :duplicate
          @pop_up_bg_bitmap.visible = true
        end
        part_properties.clear_changed
      end
      break if !part_properties.busy? && Input.triggerex?(:ESCAPE)
      part_properties.repaint
    end
    # Dispose
    bg_bitmap.dispose
    @pop_up_bg_bitmap.visible = false
    part_properties.visible = false
    # Delete particle
    if part_properties.changed_controls&.has_key?(:delete)
      apply_changed_value(:particle_properties, :delete, [idx_particle, true])
    end
    part_properties.clear_changed
    add_to_change_history
  end

  #-----------------------------------------------------------------------------

  def batch_edit_commands
    # Show pop-up window
    batch_editor = @components[:command_batch_editor]
    batch_editor.visible = true
    @pop_up_bg_bitmap.visible = true
    bg_bitmap = create_pop_up_window(BATCH_EDITOR_WINDOW_WIDTH, BATCH_EDITOR_WINDOW_HEIGHT)
    # Set control values
    refresh_component(:command_batch_editor)
    # Interaction loop
    loop do
      Graphics.update
      Input.update
      batch_editor.update
      if batch_editor.changed?
        break if batch_editor.changed_controls.has_key?(:close)
        break if batch_editor.changed_controls.has_key?(:apply)
        batch_editor.changed_controls.each_pair do |property, value|
          apply_changed_value(:command_batch_editor, property, value)
          @pop_up_bg_bitmap.visible = true
        end
        batch_editor.clear_changed
      end
      break if !batch_editor.busy? && Input.triggerex?(:ESCAPE)
      batch_editor.repaint
    end
    # Dispose and return
    bg_bitmap.dispose
    @pop_up_bg_bitmap.visible = false
    batch_editor.visible = false
    # Apply changes
    if batch_editor.changed_controls&.has_key?(:apply)
      apply_changed_value(:command_batch_editor, :apply, true)
    end
    batch_editor.clear_changed
    add_to_change_history
  end

  #-----------------------------------------------------------------------------

  def choose_graphic_file(selected, choosing_mask = false)
    selected ||= ""
    sprite_folder = "Graphics/Battle animations"
    # Show pop-up window
    graphic_chooser = @components[:graphic_chooser]
    graphic_chooser.visible = true
    @pop_up_bg_bitmap.visible = true
    bg_bitmap = create_pop_up_window(GRAPHIC_CHOOSER_WINDOW_WIDTH, GRAPHIC_CHOOSER_WINDOW_HEIGHT)
    bg_bitmap.z += graphic_chooser.z
    # Get a list of files
    list = graphic_chooser.get_control(:list)
    all_files = get_all_files_in_folder(
      sprite_folder, [".png", ".jpg", ".jpeg"],
      ["USER", "USER_OPP", "USER_FRONT", "USER_BACK", "TARGET", "TARGET_OPP", "TARGET_FRONT", "TARGET_BACK"]
    )
    if choosing_mask
      all_files.prepend(["", _INTL("[[None]]")])
    else
      if !@anim[:no_target]
        all_files.prepend(
          ["TARGET",       _INTL("[[Target's sprite]]")],
          ["TARGET_OPP",   _INTL("[[Target's other side sprite]]")],
          ["TARGET_FRONT", _INTL("[[Target's front sprite]]")],
          ["TARGET_BACK",  _INTL("[[Target's back sprite]]")]
        )
      end
      if !@anim[:no_user]
        all_files.prepend(
          ["USER",         _INTL("[[User's sprite]]")],
          ["USER_OPP",     _INTL("[[User's other side sprite]]")],
          ["USER_FRONT",   _INTL("[[User's front sprite]]")],
          ["USER_BACK",    _INTL("[[User's back sprite]]")]
        )
      end
    end
    idx = 0
    all_files.each_with_index do |f, i|
      next if f[0] != selected
      idx = i
      break
    end
    # Set control values
    list.options = all_files
    list.selected = idx
    graphic_chooser.get_control(:filter).value = ""
    graphic_chooser.get_control(:ok).enable
    # Create sprite preview
    bg_bitmap.bitmap.outline_rect(CONTAINER_BORDER - graphic_chooser.x + list.x + list.width + 4,
                                  CONTAINER_BORDER - graphic_chooser.y + list.y,
                                  GRAPHIC_CHOOSER_PREVIEW_SIZE + (GRAPHIC_CHOOSER_PREVIEW_BORDER * 2),
                                  GRAPHIC_CHOOSER_PREVIEW_SIZE + (GRAPHIC_CHOOSER_PREVIEW_BORDER * 2),
                                  get_color_of(:line))
    preview_sprite = Sprite.new(@pop_up_viewport)
    preview_sprite.x = list.x + list.width + 4 + GRAPHIC_CHOOSER_PREVIEW_BORDER + (GRAPHIC_CHOOSER_PREVIEW_SIZE / 2)
    preview_sprite.y = list.y + GRAPHIC_CHOOSER_PREVIEW_BORDER + (GRAPHIC_CHOOSER_PREVIEW_SIZE / 2)
    preview_sprite.z = graphic_chooser.z
    preview_bitmap = nil
    set_preview_graphic = lambda do |sprite, filename|
      preview_bitmap&.dispose
      sprite.visible = false
      bg_bitmap.bitmap.fill_rect(CONTAINER_BORDER - graphic_chooser.x + list.x + list.width + 4 + GRAPHIC_CHOOSER_PREVIEW_BORDER,
                                 CONTAINER_BORDER - graphic_chooser.y + list.y + GRAPHIC_CHOOSER_PREVIEW_BORDER,
                                 GRAPHIC_CHOOSER_PREVIEW_SIZE, GRAPHIC_CHOOSER_PREVIEW_SIZE,
                                 get_color_of(:background))
      next if filename.nil? || filename == ""
      folder = sprite_folder + "/"
      fname = filename
      if ["USER", "USER_BACK", "USER_FRONT", "USER_OPP",
          "TARGET", "TARGET_FRONT", "TARGET_BACK", "TARGET_OPP"].include?(filename)
        chunks = filename.split("_")
        fname = (chunks[0] == "USER") ? @settings[:anim_editor][:user_sprite_name].to_s : @settings[:anim_editor][:target_sprite_name].to_s
        case chunks[1] || ""
        when "", "OPP"
          if (chunks[0] == "USER") ^ (chunks[1] == "OPP")   # xor
            folder = (@settings[:anim_editor][:user_opposes]) ? "Graphics/Pokemon/Front/" : "Graphics/Pokemon/Back/"
          else
            folder = (@settings[:anim_editor][:user_opposes]) ? "Graphics/Pokemon/Back/" : "Graphics/Pokemon/Front/"
          end
        when "FRONT"
          folder = "Graphics/Pokemon/Front/"
        when "BACK"
          folder = "Graphics/Pokemon/Back/"
        end
      end
      preview_bitmap = AnimatedBitmap.new(folder + fname)
      next if !preview_bitmap
      sprite.visible = true
      sprite.bitmap = preview_bitmap.bitmap
      zoom = [[GRAPHIC_CHOOSER_PREVIEW_SIZE.to_f / preview_bitmap.width,
              GRAPHIC_CHOOSER_PREVIEW_SIZE.to_f / preview_bitmap.height].min, 1.0].min
      sprite.zoom_x = sprite.zoom_y = zoom
      sprite.ox = sprite.width / 2
      sprite.oy = sprite.height / 2
      bg_bitmap.bitmap.fill_rect(CONTAINER_BORDER + sprite.x - graphic_chooser.x - (sprite.width * sprite.zoom_x / 2).round,
                                 CONTAINER_BORDER + sprite.y - graphic_chooser.y - (sprite.height * sprite.zoom_y / 2).round,
                                 sprite.width * sprite.zoom_x, sprite.height * sprite.zoom_y,
                                 Color.magenta)
    end
    set_preview_graphic.call(preview_sprite, list.value)
    # Interaction loop
    filter_text = ""
    ret = nil
    loop do
      Graphics.update
      Input.update
      graphic_chooser.update
      if graphic_chooser.get_control(:filter).value != filter_text
        filter_text = graphic_chooser.get_control(:filter).value
        old_val = list.value
        if filter_text == ""
          list.options = all_files
        else
          files = all_files.filter { |val| val[0].downcase.include?(filter_text.downcase) }
          list.options = files
        end
        list.selected = list.options.index { |val| val && val[0] == old_val } || -1
        set_preview_graphic.call(preview_sprite, list.value)
      end
      if graphic_chooser.changed?
        graphic_chooser.changed_controls.each_pair do |ctrl, value|
          case ctrl
          when :ok
            ret = list.value
          when :cancel
            ret = selected
          when :list
            set_preview_graphic.call(preview_sprite, list.value)
          when :filter_clear
            old_val = list.value
            filter_text = ""
            graphic_chooser.get_control(:filter).value = ""
            list.options = all_files
            list.selected = list.options.index { |val| val && val[0] == old_val } || -1
            set_preview_graphic.call(preview_sprite, list.value)
          end
          graphic_chooser.clear_changed
        end
        break if ret
        graphic_chooser.repaint
      end
      graphic_chooser.get_control(:ok).enabled = !list.value.nil?
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
    audio_chooser = @components[:audio_chooser]
    audio_chooser.visible = true
    @pop_up_bg_bitmap.visible = true
    bg_bitmap = create_pop_up_window(AUDIO_CHOOSER_WINDOW_WIDTH, AUDIO_CHOOSER_WINDOW_HEIGHT)
    bg_bitmap.z += audio_chooser.z
    # Get a list of files
    list = audio_chooser.get_control(:list)
    all_files = get_all_files_in_folder(audio_folder, [".wav", ".ogg", ".mp3", ".wma"], ["USER", "TARGET"])
    all_files.prepend(["TARGET", _INTL("[[Target's cry]]")]) if !@anim[:no_target]
    all_files.prepend(["USER",  _INTL("[[User's cry]]")]) if !@anim[:no_user]
    idx = 0
    all_files.each_with_index do |f, i|
      next if f[0] != selected
      idx = i
      break
    end
    # Set control values
    list.options = all_files
    list.selected = idx
    audio_chooser.get_control(:filter).value = ""
    audio_chooser.get_control(:volume).value = volume
    audio_chooser.get_control(:pitch).value = pitch
    audio_chooser.get_control(:play).enable
    audio_chooser.get_control(:ok).enable
    # Interaction loop
    filter_text = ""
    ret = nil
    cancel = false
    loop do
      Graphics.update
      Input.update
      audio_chooser.update
      if audio_chooser.get_control(:filter).value != filter_text
        filter_text = audio_chooser.get_control(:filter).value
        old_val = list.value
        if filter_text == ""
          list.options = all_files
        else
          files = all_files.filter { |val| val[0].downcase.include?(filter_text.downcase) }
          list.options = files
        end
        list.selected = list.options.index { |val| val && val[0] == old_val } || -1
      end
      if audio_chooser.changed?
        audio_chooser.changed_controls.each_pair do |ctrl, value|
          case ctrl
          when :ok
            ret = list.value
          when :cancel
            ret = selected
            cancel = true
          when :filter_clear
            old_val = list.value
            filter_text = ""
            audio_chooser.get_control(:filter).value = ""
            list.options = all_files
            list.selected = list.options.index { |val| val && val[0] == old_val } || -1
          when :play
            vol = audio_chooser.get_control(:volume).value
            ptch = audio_chooser.get_control(:pitch).value
            case list.value
            when "USER"
              Pokemon.play_cry(@settings[:anim_editor][:user_sprite_name])
            when "TARGET"
              Pokemon.play_cry(@settings[:anim_editor][:target_sprite_name])
            else
              pbSEPlay(RPG::AudioFile.new("Anim/" + list.value, vol, ptch)) if list.value
            end
          when :stop
            pbSEStop
          end
          audio_chooser.clear_changed
        end
        break if ret
        audio_chooser.repaint
      end
      [:play, :ok].each { |ctrl| audio_chooser.get_control(ctrl).enabled = !list.value.nil? }
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
