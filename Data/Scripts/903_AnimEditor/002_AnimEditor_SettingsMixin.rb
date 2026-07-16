#===============================================================================
#
#===============================================================================
class AnimationEditor
  module AnimationEditor::SettingsMixin
    def load_settings
      @settings = Debug.load_settings
      if !@settings[:anim_editor]
        @settings[:anim_editor] = {
          :side_sizes            => [1, 1],   # Player's side, opposing side
          :user_index            => 0,        # 0, 2, 4
          :target_indices        => [1],      # There must be at least one valid target
          :user_opposes          => false,
          :canvas_bg             => "indoor1",
          # NOTE: These sprite names are also used in Pokemon.play_cry and so
          #       should be a species ID (being a string is fine).
          :user_sprite_name      => "DRAGONITE",
          :target_sprite_name    => "CHARIZARD",
          :default_interpolation => :linear
        }
      end
    end

    def save_settings
      Debug.save_settings(@settings)
    end
  end
end
