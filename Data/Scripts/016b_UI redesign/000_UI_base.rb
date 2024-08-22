module UI
  #=============================================================================
  # The visuals class.
  #=============================================================================
  class BaseVisuals
    UI_FOLDER             = "Graphics/UI/"
    @@graphics_folder     = ""   # Subfolder in UI_FOLDER
    @@background_filename = "bg"
    @@text_colors = {   # These color themes are added to @sprites[:overlay]
      :default => [Color.new(72, 72, 72), Color.new(160, 160, 160)]   # Base and shadow colour
    }

    def initialize
      @bitmaps = {}
      @sprites = {}
      initialize_viewport
      initialize_bitmaps
      initialize_background
      initialize_overlay
      # TODO: Initialize message box (and dialogue box?) for messages to use.
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
      addBackgroundPlane(@sprites, :background, @@graphics_folder + background_filename, @viewport)
      @sprites[:background].z = -1000
    end

    def background_filename
      return gendered_filename(@@background_filename)
    end

    def initialize_overlay
      @sprites[:overlay] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
      @sprites[:overlay].z = 1000
      @@text_colors.each_pair { |key, values| @sprites[:overlay].add_text_theme(key, *values) }
      pbSetSystemFont(@sprites[:overlay].bitmap)
    end

    def initialize_sprites
    end

    #---------------------------------------------------------------------------

    def add_icon_sprite(key, x, y, filename = nil)
      @sprites[key] = IconSprite.new(x, y, @viewport)
      @sprites[key].setBitmap(filename) if filename
    end

    #---------------------------------------------------------------------------

    def fade_in
      pbFadeInAndShow(@sprites) { update_visuals }
    end

    def fade_out
      pbFadeOutAndHide(@sprites) { update_visuals }
    end

    def dispose
      @sprites.each_value { |s| s.dispose if s && !s.disposed? }
      @sprites.clear
      @bitmaps.each_value { |b| b.dispose if b && !b.disposed? }
      @bitmaps.clear
      @viewport.dispose
    end

    #---------------------------------------------------------------------------

    def graphics_folder
      return UI_FOLDER + @@graphics_folder
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

    def show_message(text)
      pbMessage(text) { update_visuals }
    end

    def show_confirm_message(text)
      return pbConfirmMessage(text) { update_visuals }
    end

    def show_choice_message(text, options, cancel_index)
      return pbMessage(text, options, cancel_index) { update_visuals }
    end

    #---------------------------------------------------------------------------

    def draw_text(string, text_x, text_y, align: :left, theme: :default, outline: :shadow, overlay: :overlay)
      @sprites[overlay].draw_themed_text(string, text_x, text_y, align, theme, outline)
    end

    def draw_image(filename, image_x, image_y, src_x = 0, src_y = 0, src_width = -1, src_height = -1, overlay: :overlay)
      @sprites[overlay].draw_image(filename, image_x, image_y, src_x, src_y, src_width, src_height)
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

    def update_input
      if Input.trigger?(Input::BACK)
        return :quit
      end
      return nil
    end

    def update
      update_visuals
      return update_input
    end

    #---------------------------------------------------------------------------

    def navigate
      ret = nil
      loop do
        Graphics.update
        Input.update
        ret = update
        break if ret
      end
      return ret
    end
  end

  #=============================================================================
  # The logic class.
  #=============================================================================
  class BaseScreen
    def initialize
      @disposed = false
      initialize_visuals
      main
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

    def show_message(text)
      @visuals.show_message(text)
    end

    def show_confirm_message(text)
      return @visuals.show_confirm_message(text)
    end

    def show_choice_message(text, options, cancel_index)
      return @visuals.show_choice_message(text, options, cancel_index)
    end

    #-----------------------------------------------------------------------------

    def refresh
      @visuals.refresh
    end

    def main
      start_screen
      loop do
        command = @visuals.navigate
        break if command == :quit
        command = perform_action(command)
        break if command == :quit
      end
      end_screen
    end

    def perform_action(command)
      return nil
    end
  end
end
