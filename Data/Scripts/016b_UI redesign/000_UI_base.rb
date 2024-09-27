module UI
  #=============================================================================
  # The visuals class.
  #=============================================================================
  module SpriteContainerMixin
    UI_FOLDER         = "Graphics/UI/"
    GRAPHICS_FOLDER   = ""   # Subfolder in UI_FOLDER
    TEXT_COLOR_THEMES = {   # These color themes are added to @sprites[:overlay]
      :default => [Color.new(72, 72, 72), Color.new(160, 160, 160)]   # Base and shadow colour
    }

    def add_overlay(overlay, overlay_width = -1, overlay_height = -1)
      overlay_width = Graphics.width if overlay_width < 0
      overlay_height = Graphics.height if overlay_height < 0
      @sprites[overlay] = BitmapSprite.new(overlay_width, overlay_height, @viewport)
      @sprites[overlay].z = 1000
      self.class::TEXT_COLOR_THEMES.each_pair { |key, values| @sprites[overlay].add_text_theme(key, *values) }
      pbSetSystemFont(@sprites[overlay].bitmap)
    end

    def add_icon_sprite(key, x, y, filename = nil)
      @sprites[key] = IconSprite.new(x, y, @viewport)
      @sprites[key].setBitmap(filename) if filename
    end

    def add_animated_arrow(key, x, y, direction)
      case direction
      when :up
        @sprites[key] = AnimatedSprite.new(UI_FOLDER + "up_arrow", 8, 28, 40, 2, @viewport)
      when :down
        @sprites[key] = AnimatedSprite.new(UI_FOLDER + "down_arrow", 8, 28, 40, 2, @viewport)
      when :left
        @sprites[key] = AnimatedSprite.new(UI_FOLDER + "left_arrow", 8, 40, 28, 2, @viewport)
      when :right
        @sprites[key] = AnimatedSprite.new(UI_FOLDER + "right_arrow", 8, 40, 28, 2, @viewport)
      end
      @sprites[key].x = x
      @sprites[key].y = y
      @sprites[key].visible = false
      @sprites[key].play
    end

    #---------------------------------------------------------------------------

    def dispose
      @sprites.each_value { |s| s.dispose if s && !s.disposed? }
      @sprites.clear
      @bitmaps.each_value { |b| b.dispose if b && !b.disposed? }
      @bitmaps.clear
      @disposed = true
    end

    def disposed?
      return !!@disposed
    end

    #---------------------------------------------------------------------------

    def graphics_folder
      return UI_FOLDER + self.class::GRAPHICS_FOLDER
    end

    def background_filename
      return gendered_filename(self.class::BACKGROUND_FILENAME)
    end

    def gendered_filename(base_filename)
      return filename_with_appendix(base_filename, "_f") if $player.female?
      return base_filename
    end

    def filename_with_appendix(base_filename, appendix)
      if appendix && appendix != ""
        trial_filename = base_filename + appendix
        return trial_filename if pbResolveBitmap(graphics_folder + trial_filename)
      end
      return base_filename
    end

    #---------------------------------------------------------------------------

    # NOTE: max_width should include the width of the text shadow at the end of
    #       the string (because characters in the font have a blank 2 pixels
    #       after them for the shadow to occupy).
    def crop_text(string, max_width, continue_string = "…", overlay: :overlay)
      return string if max_width <= 0
      return string if @sprites[overlay].bitmap.text_size(string).width <= max_width
      ret = string
      continue_width = @sprites[overlay].bitmap.text_size(continue_string).width
      loop do
        ret = ret[0...-1]
        break if @sprites[overlay].bitmap.text_size(ret).width <= max_width - continue_width
      end
      ret += continue_string
      return ret
    end

    #---------------------------------------------------------------------------

    def draw_text(string, text_x, text_y, align: :left, theme: :default, outline: :shadow, overlay: :overlay)
      @sprites[overlay].draw_themed_text(string.to_s, text_x, text_y, align, theme, outline)
    end

    def draw_paragraph_text(string, text_x, text_y, text_width, num_lines, theme: :default, overlay: :overlay)
      drawTextEx(@sprites[overlay].bitmap, text_x, text_y, text_width, num_lines,
                string, *self.class::TEXT_COLOR_THEMES[theme])
    end

    # NOTE: This also draws string in a paragraph, but with no limit on the
    #       number of lines.
    def draw_formatted_text(string, text_x, text_y, text_width, theme: :default, overlay: :overlay)
      drawFormattedTextEx(@sprites[overlay].bitmap, text_x, text_y, text_width,
                          string, *self.class::TEXT_COLOR_THEMES[theme])
    end

    def draw_image(filename, image_x, image_y, src_x = 0, src_y = 0, src_width = -1, src_height = -1, overlay: :overlay)
      @sprites[overlay].draw_image(filename, image_x, image_y, src_x, src_y, src_width, src_height)
    end

    # The image is assumed to be the digits 0-9 and then a "/", all the same
    # width, in a horizontal row.
    def draw_number_from_image(bitmap, string, text_x, text_y, align: :left, overlay: :overlay)
      string = string.to_s
      raise _INTL("Can't draw {1} as a number.", string) if !string.scan(/[^\d\/]/).empty?
      char_width  = bitmap.width / 11
      char_height = bitmap.height
      chars = string.split(//)
      chars.reverse! if align == :right
      chars.length.times do |i|
        char = chars[i]
        index = (char == "/") ? 10 : char.to_i
        char_x = (align == :right) ? text_x - ((i + 1) * char_width) : text_x + (i * char_width)
        draw_image(bitmap, char_x, text_y,
                  index * char_width, 0, char_width, char_height, overlay: overlay)
      end
    end

    SLIDER_COORDS = {   # Size of elements in slider graphic
      :arrow_size  => [24, 28],
      :box_heights => [4, 8, 18]   # Heights of top, middle and bottom segments of slider box
    }

    # slider_height includes the heights of the arrows at either end.
    def draw_slider(bitmap, slider_x, slider_y, slider_height, visible_top, visible_height, total_height, hide_if_inactive: :false, overlay: :overlay)
      coords = self.class::SLIDER_COORDS
      bar_y = slider_y + coords[:arrow_size][1]
      bar_height = slider_height - (2 * coords[:arrow_size][1])
      bar_segment_height = coords[:box_heights].sum   # Also minimum height of slider box
      show_up_arrow = (visible_top > 0)
      show_down_arrow = (visible_top + visible_height < total_height)
      return if hide_if_inactive && !show_up_arrow && !show_down_arrow
      # Draw up arrow
      x_offset = (show_up_arrow) ? coords[:arrow_size][0] : 0
      draw_image(bitmap, slider_x, slider_y,
                 x_offset, 0, *coords[:arrow_size], overlay: overlay)
      # Draw down arrow
      x_offset = (show_down_arrow) ? coords[:arrow_size][0] : 0
      draw_image(bitmap, slider_x, slider_y + slider_height - coords[:arrow_size][1],
                 x_offset, coords[:arrow_size][1] + bar_segment_height, *coords[:arrow_size], overlay: overlay)
      # Draw bar background
      iterations = (bar_height / bar_segment_height.to_f).ceil
      iterations.times do |i|
        segment_y = bar_y + (i * bar_segment_height)
        iteration_height = bar_segment_height
        iteration_height = bar_height - (i * bar_segment_height) if i == iterations - 1   # Last part
        draw_image(bitmap, slider_x, segment_y,
                   0, coords[:arrow_size][1], coords[:arrow_size][0], iteration_height, overlay: overlay)
      end
      # Draw slider box
      if show_up_arrow || show_down_arrow
        box_height = (bar_height * visible_height / total_height).floor
        box_height += [(bar_height - box_height) / 2, bar_height / 6].min   # Make it bigger than expected
        box_height = [box_height.floor, bar_segment_height].max
        box_y = bar_y
        box_y += ((bar_height - box_height) * visible_top / (total_height - visible_height)).floor
        # Draw slider box top
        draw_image(bitmap, slider_x, box_y,
                   coords[:arrow_size][0], coords[:arrow_size][1],
                   coords[:arrow_size][0], coords[:box_heights][0], overlay: overlay)
        # Draw slider box middle
        middle_height = box_height - coords[:box_heights][0] - coords[:box_heights][2]
        iterations = (middle_height / coords[:box_heights][1].to_f).ceil
        iterations.times do |i|
          segment_y = box_y + coords[:box_heights][0] + (i * coords[:box_heights][1])
          iteration_height = coords[:box_heights][1]
          iteration_height = middle_height - (i * coords[:box_heights][1]) if i == iterations - 1   # Last part
          draw_image(bitmap, slider_x, segment_y,
                     coords[:arrow_size][0], coords[:arrow_size][1] + coords[:box_heights][0],
                     coords[:arrow_size][0], iteration_height, overlay: overlay)
        end
        # Draw slider box bottom
        draw_image(bitmap, slider_x, box_y + box_height - coords[:box_heights][2],
                   coords[:arrow_size][0], coords[:arrow_size][1] + coords[:box_heights][0] + coords[:box_heights][1],
                   coords[:arrow_size][0], coords[:box_heights][2], overlay: overlay)
      end
    end

    #---------------------------------------------------------------------------

    # Redraw everything on the screen.
    def refresh
      refresh_overlay
    end

    def refresh_overlay
      @sprites[:overlay].bitmap.clear if @sprites[:overlay]
    end

    #---------------------------------------------------------------------------

    def update_visuals
      pbUpdateSpriteHash(@sprites)
    end

    def update
      update_visuals
    end
  end

  #=============================================================================
  # The visuals class.
  #=============================================================================
  class SpriteContainer
    attr_reader :x, :y, :z, :visible, :color

    include SpriteContainerMixin

    def initialize(viewport)
      @viewport = viewport
      @x ||= 0
      @y ||= 0
      @z ||= 0
      @visible = true
      @color = Color.new(0, 0, 0, 0)
      @bitmaps = {}
      @sprites = {}
      @sprites_values = {}
      initialize_bitmaps
      initialize_sprites
      refresh_sprites_values
    end

    def initialize_bitmaps
    end

    def initialize_sprites
    end

    #---------------------------------------------------------------------------

    # x, y, z, visible, opacity, color
    def x=(value)
      @x = value
      @sprites.each_pair do |key, sprite|
        sprite.x = @x + @sprites_values[key][:x]
      end
    end

    def y=(value)
      @y = value
      @sprites.each_pair do |key, sprite|
        sprite.y = @y + @sprites_values[key][:y]
      end
    end

    def z=(value)
      @z = value
      @sprites.each_pair do |key, sprite|
        sprite.z = @z + @sprites_values[key][:z]
      end
    end

    def visible=(value)
      @visible = value
      @sprites.each_pair do |key, sprite|
        sprite.visible = @visible && @sprites_values[key][:visible]
      end
    end

    def color=(value)
      @color = value
      @sprites.each_pair do |key, sprite|
        sprite.color = @color
      end
    end

    #---------------------------------------------------------------------------

    def record_values(key)
      @sprites_values[key] ||= {}
      @sprites_values[key][:x] = @sprites[key].x
      @sprites_values[key][:y] = @sprites[key].y
      @sprites_values[key][:z] = @sprites[key].z
      @sprites_values[key][:visible] = @sprites[key].visible
    end

    def refresh_sprites_values
      self.x = @x
      self.y = @y
      self.z = @z
      self.visible = @visible
    end
  end

  #=============================================================================
  # The visuals class.
  #=============================================================================
  class BaseVisuals
    BACKGROUND_FILENAME = "bg"

    include SpriteContainerMixin

    def initialize
      @bitmaps = {}
      @sprites = {}
      initialize_viewport
      initialize_bitmaps
      initialize_background
      initialize_overlay
      initialize_message_box
      initialize_sprites
      refresh
    end

    def initialize_viewport
      @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport.z = 99999
    end

    def initialize_bitmaps
    end

    def initialize_background
      addBackgroundPlane(@sprites, :background, self.class::GRAPHICS_FOLDER + background_filename, @viewport)
      @sprites[:background].z = -1000
    end

    def initialize_overlay
      add_overlay(:overlay)
    end

    def initialize_message_box
      @sprites[:message_box] = Window_AdvancedTextPokemon.new("")
      @sprites[:message_box].viewport       = @viewport
      @sprites[:message_box].z              = 2000
      @sprites[:message_box].visible        = false
      @sprites[:message_box].letterbyletter = true
      pbBottomLeftLines(@sprites[:message_box], 2)
      @sprites[:speech_box] = Window_AdvancedTextPokemon.new("")
      @sprites[:speech_box].viewport       = @viewport
      @sprites[:speech_box].z              = 2001
      @sprites[:speech_box].visible        = false
      @sprites[:speech_box].letterbyletter = true
      @sprites[:speech_box].setSkin(MessageConfig.pbGetSpeechFrame)
      pbBottomLeftLines(@sprites[:speech_box], 2)
    end

    def initialize_sprites
    end

    #---------------------------------------------------------------------------

    def fade_in
      pbFadeInAndShow(@sprites)# { update_visuals }
    end

    def fade_out
      pbFadeOutAndHide(@sprites)# { update_visuals }
    end

    def dispose
      super
      @viewport.dispose
    end

    #---------------------------------------------------------------------------

    def index
      return 0
    end

    #---------------------------------------------------------------------------

    def show_message(text)
      @sprites[:speech_box].visible = true
      @sprites[:speech_box].text = text
      pbBottomLeftLines(@sprites[:speech_box], 2)
      yielded = false
      loop do
        Graphics.update
        Input.update
        update_visuals
        if @sprites[:speech_box].busy?
          if Input.trigger?(Input::USE)
            pbPlayDecisionSE if @sprites[:speech_box].pausing?
            @sprites[:speech_box].resume
          end
        else
          yield if !yielded && block_given?
          yielded = true
          if Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
            break
          end
        end
      end
      @sprites[:speech_box].visible = false
    end

    def show_confirm_message(text)
      ret = false
      @sprites[:speech_box].visible = true
      @sprites[:speech_box].text    = text
      pbBottomLeftLines(@sprites[:speech_box], 2)
      using(cmd_window = Window_CommandPokemon.new([_INTL("Yes"), _INTL("No")])) do
        cmd_window.z       = @viewport.z + 1
        cmd_window.visible = false
        pbBottomRight(cmd_window)
        cmd_window.y -= @sprites[:speech_box].height
        cmd_window.visible = true if !@sprites[:speech_box].busy?
        loop do
          Graphics.update
          Input.update
          update_visuals
          cmd_window.visible = true if !@sprites[:speech_box].busy?
          cmd_window.update
          if !@sprites[:speech_box].busy?
            if Input.trigger?(Input::BACK)
              pbPlayCancelSE
              ret = false
              break
            elsif Input.trigger?(Input::USE) && @sprites[:speech_box].resume
              pbPlayDecisionSE
              ret = (cmd_window.index == 0)
              break
            end
          end
        end
      end
      @sprites[:speech_box].visible = false
      return ret
    end

    # Used for dialogue.
    # align: Where the command window is in relation to the message window.
    #        :horizontal is side by side, :vertical is command window above.
    def show_choice_message(text, options, index = 0, align: :vertical, cmd_side: :right)
      ret = -1
      commands = options
      commands = options.values if options.is_a?(Hash)
      @sprites[:speech_box].visible = true
      @sprites[:speech_box].text    = text
      using(cmd_window = Window_AdvancedCommandPokemon.new(commands)) do
        if align == :vertical
          @sprites[:speech_box].resizeHeightToFit(text, Graphics.width)
        else
          @sprites[:speech_box].resizeHeightToFit(text, Graphics.width - cmd_window.width)
        end
        cmd_window.z       = @viewport.z + 1
        cmd_window.visible = false
        cmd_window.index   = index
        if cmd_side == :right
          pbBottomLeft(@sprites[:speech_box])
          pbBottomRight(cmd_window)
        else
          pbBottomRight(@sprites[:speech_box])
          pbBottomLeft(cmd_window)
        end
        if align == :vertical
          cmd_window.height = [cmd_window.height, Graphics.height - @sprites[:speech_box].height].min
          cmd_window.y = Graphics.height - @sprites[:speech_box].height - cmd_window.height
        end
        cmd_window.visible = true if !@sprites[:speech_box].busy?
        loop do
          Graphics.update
          Input.update
          update_visuals
          cmd_window.visible = true if !@sprites[:speech_box].busy?
          cmd_window.update
          if !@sprites[:speech_box].busy?
            if Input.trigger?(Input::BACK)
              pbPlayCancelSE
              ret = -1
              break
            elsif Input.trigger?(Input::USE) && @sprites[:speech_box].resume
              pbPlayDecisionSE
              ret = cmd_window.index
              break
            end
          end
        end
      end
      @sprites[:speech_box].visible = false
      ret = options.keys[ret] if options.is_a?(Hash)
      return ret
    end

    def show_menu(text, options, index = 0, cmd_side: :right)
      old_letter_by_letter = @sprites[:speech_box].letterbyletter
      @sprites[:speech_box].letterbyletter = false
      ret = show_choice_message(text, options, index, align: :horizontal, cmd_side: cmd_side)
      @sprites[:speech_box].letterbyletter = old_letter_by_letter
      return ret
    end

    def show_choice(options, index = 0)
      ret = -1
      commands = options
      commands = options.values if options.is_a?(Hash)
      using(cmd_window = Window_AdvancedCommandPokemon.new(commands)) do
        cmd_window.z     = @viewport.z + 1
        cmd_window.index = index
        pbBottomRight(cmd_window)
        loop do
          Graphics.update
          Input.update
          update_visuals
          cmd_window.update
          if Input.trigger?(Input::BACK)
            pbPlayCancelSE
            ret = -1
            break
          elsif Input.trigger?(Input::USE)
            pbPlayDecisionSE
            ret = cmd_window.index
            break
          end
        end
      end
      ret = options.keys[ret] if options.is_a?(Hash)
      return ret
    end

    # TODO: Rewrite this.
    def choose_number(help_text, maximum, init_value = 1)
      if maximum.is_a?(ChooseNumberParams)
        return pbMessageChooseNumber(help_text, maximum) { update_visuals }
      end
      return UIHelper.pbChooseNumber(@sprites[:speech_box], help_text, maximum, init_value) { update_visuals }
    end

    def choose_number_as_money_multiplier(help_text, money_per_unit, maximum, init_value = 1)
      @sprites[:speech_box].visible = true
      @sprites[:speech_box].text = help_text
      pbBottomLeftLines(@sprites[:speech_box], 2)
      # Show the help text
      loop do
        Graphics.update
        Input.update
        update_visuals
        if @sprites[:speech_box].busy?
          if Input.trigger?(Input::USE)
            pbPlayDecisionSE if @sprites[:speech_box].pausing?
            @sprites[:speech_box].resume
          end
        else
          break
        end
      end
      # Choose a quantity
      item_price = money_per_unit
      quantity = init_value
      using(num_window = Window_AdvancedTextPokemon.newWithSize(
            _INTL("×{1}<r>${2}", quantity, (quantity * item_price).to_s_formatted),
            0, 0, 224, 64, @viewport)) do
        num_window.z              = 2000
        num_window.visible        = true
        num_window.letterbyletter = false
        pbBottomRight(num_window)
        num_window.y -= @sprites[:speech_box].height
        loop do
          Graphics.update
          Input.update
          update
          num_window.update
          # Change quantity
          old_quantity = quantity
          if Input.repeat?(Input::LEFT)
            quantity = [quantity - 10, 1].max
          elsif Input.repeat?(Input::RIGHT)
            quantity = [quantity + 10, maximum].min
          elsif Input.repeat?(Input::UP)
            quantity += 1
            quantity = 1 if quantity > maximum
          elsif Input.repeat?(Input::DOWN)
            quantity -= 1
            quantity = maximum if quantity < 1
          end
          if quantity != old_quantity
            num_window.text = _INTL("×{1}<r>${2}", quantity, (quantity * item_price).to_s_formatted)
            pbPlayCursorSE
          end
          # Finish choosing a quantity
          if Input.trigger?(Input::USE)
            pbPlayDecisionSE
            break
          elsif Input.trigger?(Input::BACK)
            pbPlayCancelSE
            quantity = 0
            break
          end
        end
      end
      @sprites[:speech_box].visible = false
      return quantity
    end

    #---------------------------------------------------------------------------

    def refresh_on_index_changed(old_index)
    end

    #---------------------------------------------------------------------------

    def update_input
      if Input.trigger?(Input::BACK)
        return :quit
      end
      return nil
    end

    #---------------------------------------------------------------------------

    def navigate
      ret = nil
      loop do
        Graphics.update
        Input.update
        old_index = index
        update_visuals
        refresh_on_index_changed(old_index) if index != old_index
        old_index = index
        ret = update_input
        refresh_on_index_changed(old_index) if index != old_index
        break if ret
      end
      return ret
    end
  end

  #=============================================================================
  # The logic class.
  #=============================================================================
  class BaseScreen
    attr_reader   :visuals
    attr_accessor :result

    def initialize
      @disposed = false
      initialize_visuals
    end

    def initialize_visuals
      @visuals = UI::BaseVisuals.new
    end

    def start_screen
      @visuals.fade_in
    end

    def end_screen
      return if @disposed
      @visuals.fade_out
      @visuals.dispose
      @disposed = true
    end

    # Same as def end_screen but without fading out.
    def silent_end_screen
      return if @disposed
      @visuals.dispose
      @disposed = true
    end

    #-----------------------------------------------------------------------------

    def sprites
      return @visuals.sprites
    end

    def index
      return @visuals.index
    end

    #-----------------------------------------------------------------------------

    def show_message(text, &block)
      @visuals.show_message(text, &block)
    end

    alias pbDisplay show_message

    def show_confirm_message(text)
      return @visuals.show_confirm_message(text)
    end

    alias pbConfirm show_confirm_message

    def show_choice_message(text, options, initial_index = 0)
      return @visuals.show_choice_message(text, options, initial_index)
    end

    alias pbShowCommands show_choice_message

    def show_menu(text, options, initial_index = 0, cmd_side: :right)
      return @visuals.show_menu(text, options, initial_index, cmd_side: cmd_side)
    end

    def show_choice(options, initial_index = 0)
      return @visuals.show_choice(options, initial_index)
    end

    def show_choice_from_menu_handler(menu_handler_id, message = nil)
      commands = {}
      MenuHandlers.each_available(menu_handler_id, self) do |option, _hash, name|
        commands[option] = name
      end
      return show_menu(message, commands) if message
      return show_choice(commands)
    end

    def choose_number(help_text, maximum, init_value = 1)
      return @visuals.choose_number(help_text, maximum, init_value)
    end

    alias pbChooseNumber choose_number

    def choose_number_as_money_multiplier(help_text, money_per_unit, maximum, init_value = 1)
      return @visuals.choose_number_as_money_multiplier(help_text, money_per_unit, maximum, init_value)
    end

    #-----------------------------------------------------------------------------

    def refresh
      @visuals.refresh
    end

    alias pbRefresh refresh

    def update
      @visuals.update
    end

    alias pbUpdate update

    #-----------------------------------------------------------------------------

    def show_and_hide
      start_screen
      yield if block_given?
      end_screen
    end

    def main
      start_screen
      loop do
        on_start_main_loop
        command = @visuals.navigate
        break if command == :quit
        command = perform_action(command)
        break if command == :quit
        break if @disposed
      end
      end_screen
    end

    def on_start_main_loop
    end

    def perform_action(command)
      return nil if !self.class::SCREEN_ID
      action_hash = UIActionHandlers.get(self.class::SCREEN_ID, command)
      return nil if !action_hash
      return nil if action_hash[:condition] && !action_hash[:condition].call(self)
      if action_hash[:menu]
        choice = show_choice_from_menu_handler(action_hash[:menu], action_hash[:menu_message]&.call(self))
        return perform_action(choice) if choice
      elsif action_hash[:effect]
        return perform_action_effect(action_hash)
      end
      return nil
    end

    def perform_action_effect(action_hash)
      ret = action_hash[:effect].call(self)
      return ret if action_hash[:returns_value]
      return nil
    end
  end
end
