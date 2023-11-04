module GameData
  class Animation
    attr_reader :type         # :move, :opp_move, :common, :opp_common
    attr_reader :move         # Either the move's ID or the common animation's name (both are strings)
    attr_reader :version      # Hit number
    attr_reader :name         # Shown in the sublist; cosmetic only
    attr_reader :no_target    # Whether there is no "Target" particle (false by default)
    attr_reader :flags
    attr_reader :pbs_path     # Whole path minus "PBS/Animations/" at start and ".txt" at end
    attr_reader :particles

    DATA = {}
    DATA_FILENAME = "animations.dat"
    OPTIONAL = true

    INTERPOLATION_TYPES = {
      "None"     => :none,
      "Linear"   => :linear,
      "EaseIn"   => :ease_in,
      "EaseOut"  => :ease_out,
      "EaseBoth" => :ease_both
    }

    # Properties that apply to the animation in general, not to individual
    # particles. They don't change during the animation.
    SCHEMA = {
      # TODO: Add support for overworld animations.
      "SectionName" => [:id,        "esU", {"Move" => :move, "OppMove" => :opp_move,
                                            "Common" => :common, "OppCommon" => :opp_common}],
      "Name"        => [:name,      "s"],
      "NoTarget"    => [:no_target, "b"],
      # TODO: Boolean for whether the animation will be played if the target is
      #       on the same side as the user.
      # TODO: DamageFrame (keyframe at which the battle continues, i.e. damage
      #       animations start playing).
      "Flags"       => [:flags,     "*s"],
      # TODO: If this is changed to be more than just a string, edit the
      #       compiler's current_particle definition accordingly.
      "Particle"    => [:particles, "s"]   # Is a subheader line like <text>
    }
    # For individual particles. Any property whose schema begins with "^" can
    # change during the animation.
    # TODO: If more "SetXYZ"/"MoveXYZ" properties are added, ensure the "SetXYZ"
    #       ones are given a duration of 0 in def validate_compiled_animation.
    #       Also add display names to def property_display_name.
    SUB_SCHEMA = {
      # These properties cannot be changed partway through the animation.
      # NOTE: "Name" isn't a property here, because the particle's name comes
      #       from the "Particle" property above.
      # TODO: If more focus types are added, add ones that involve a target to
      #       the Compiler's check relating to "NoTarget".
      "Graphic"        => [:graphic,     "s"],
      "Focus"          => [:focus,       "e", {"User" => :user, "Target" => :target,
                                               "UserAndTarget" => :user_and_target,
                                               "Screen" => :screen}],
      # TODO: FlipIfFoe, RotateIfFoe kinds of thing.

      # All properties below are "SetXYZ" or "MoveXYZ". "SetXYZ" has the
      # keyframe and the value, and "MoveXYZ" has the keyframe, duration and the
      # value. All are "^". "SetXYZ" is turned into "MoveXYZ" when compiling by
      # inserting a duration (second value) of 0.
      "SetFrame"       => [:frame,       "^uu"],   # Frame within the graphic if it's a spritesheet
      "MoveFrame"      => [:frame,       "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetBlending"    => [:blending,    "^uu"],   # 0, 1 or 2
      "SetFlip"        => [:flip,        "^ub"],
      "SetX"           => [:x,           "^ui"],
      "MoveX"          => [:x,           "^uuiE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetY"           => [:y,           "^ui"],
      "MoveY"          => [:y,           "^uuiE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetZoomX"       => [:zoom_x,      "^uu"],
      "MoveZoomX"      => [:zoom_x,      "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetZoomY"       => [:zoom_y,      "^uu"],
      "MoveZoomY"      => [:zoom_y,      "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetAngle"       => [:angle,       "^ui"],
      "MoveAngle"      => [:angle,       "^uuiE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetVisible"     => [:visible,     "^ub"],
      "SetOpacity"     => [:opacity,     "^uu"],
      "MoveOpacity"    => [:opacity,     "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetColorRed"    => [:color_red,   "^ui"],
      "MoveColorRed"   => [:color_red,   "^uuiE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetColorGreen"  => [:color_green, "^ui"],
      "MoveColorGreen" => [:color_green, "^uuiE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetColorBlue"   => [:color_blue,  "^ui"],
      "MoveColorBlue"  => [:color_blue,  "^uuiE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetColorAlpha"  => [:color_alpha, "^ui"],
      "MoveColorAlpha" => [:color_alpha, "^uuiE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetToneRed"     => [:tone_red,    "^ui"],
      "MoveToneRed"    => [:tone_red,    "^uuiE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetToneGreen"   => [:tone_green,  "^ui"],
      "MoveToneGreen"  => [:tone_green,  "^uuiE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetToneBlue"    => [:tone_blue,   "^ui"],
      "MoveToneBlue"   => [:tone_blue,   "^uuiE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetToneGray"    => [:tone_gray,   "^ui"],
      "MoveToneGray"   => [:tone_gray,   "^uuiE", nil, nil, nil, INTERPOLATION_TYPES],
      # TODO: SetPriority should be an enum (above all, above user, etc.). There
      #       should also be a property (set and move) for the sub-priority
      #       within that priority bracket.
      # TODO: Add "SetColor"/"SetTone" as shorthand for the above? They'd be
      #       converted in the Compiler.
      # TODO: Bitmap masking.

      # These properties are specifically for the "SE" particle.
      "Play"           => [:se,          "^usUU"],   # Filename, volume, pitch
      "PlayUserCry"    => [:user_cry,    "^uUU"],   # Volume, pitch
      "PlayTargetCry"  => [:target_cry,  "^uUU"]   # Volume, pitch

      # TODO: ScreenShake? Not sure how to work this yet. Edit def
      #       validate_compiled_animation like the "SE" particle does with the
      #       "Play"-type commands.
    }
    PARTICLE_DEFAULT_VALUES = {
      :name    => "",
      :graphic => "",
      :focus   => :screen
    }
    # NOTE: Particles are invisible until their first command, and automatically
    #       become visible then. "User" and "Target" are visible from the start,
    #       though.
    PARTICLE_KEYFRAME_DEFAULT_VALUES = {
      :frame       => 0,
      :blending    => 0,
      :flip        => false,
      :x           => 0,
      :y           => 0,
      :zoom_x      => 100,
      :zoom_y      => 100,
      :angle       => 0,
      :visible     => false,
      :opacity     => 255,
      :color_red   => 255,
      :color_green => 255,
      :color_blue  => 255,
      :color_alpha => 0,
      :tone_red    => 0,
      :tone_green  => 0,
      :tone_blue   => 0,
      :tone_gray   => 0,
      :se          => nil,
      :user_cry    => nil,
      :target_cry  => nil
    }

    @@cmd_to_pbs_name = nil   # USed for writing animation PBS files

    extend ClassMethodsIDNumbers
    include InstanceMethods

    singleton_class.alias_method(:__new_anim__load, :load) unless singleton_class.method_defined?(:__new_anim__load)
    def self.load
      __new_anim__load if FileTest.exist?("Data/#{self::DATA_FILENAME}")
    end

    def self.sub_schema
      return SUB_SCHEMA
    end

    def self.register(hash, id_num = -1)
      DATA[(id_num >= 0) ? id_num : DATA.keys.length] = self.new(hash)
    end

    # TODO: Rewrite this to query animations from other criteria. Remember that
    #       multiple animations could have the same move/version. Odds are this
    #       method won't be used much at all.
    # TODO: Separate exists? methods for move and common animations?
#    def exists?(other)
#    end

    # TODO: Rewrite this to get animations from other criteria. Remember that
    #       multiple animations could have the same move/version. Odds are this
    #       method won't be used much at all.
    # TODO: Separate get methods for move and common animations?
#    def get(other)
#    end

    # TODO: Rewrite this to get animations from other criteria. Remember that
    #       multiple animations could have the same move/version. Odds are this
    #       method won't be used much at all.
    # TODO: Separate try_get methods for move and common animations?
#    def try_get(other)
#    end

    def initialize(hash)
      # NOTE: hash has an :id entry, but it's unused here.
      @type       = hash[:type]
      @move       = hash[:move]
      @version    = hash[:version]   || 0
      @name       = hash[:name]
      @no_target  = hash[:no_target] || false
      @particles  = hash[:particles] || []
      @flags      = hash[:flags]     || []
      @pbs_path   = hash[:pbs_path]  || @move
    end

    # Returns a clone of the animation in a hash format, the same as created by
    # the Compiler. This hash can be passed into self.register.
    def clone_as_hash
      ret = {}
      ret[:type] = @type
      ret[:move] = @move
      ret[:version] = @version
      ret[:name] = @name
      ret[:particles] = []   # Clone the @particles array, which is nested hashes and arrays
      @particles.each do |particle|
        new_p = {}
        particle.each_pair do |key, val|
          if val.is_a?(Array)
            new_p[key] = []
            val.each { |cmd| new_p[key].push(cmd.clone) }
          else
            new_p[key] = val
          end
        end
        ret[:particles].push(new_p)
      end
      ret[:flags] = @flags.clone
      ret[:pbs_path] = @pbs_path
      return ret
    end

    def move_animation?
      return [:move, :opp_move].include?(@type)
    end

    def common_animation?
      return [:common, :opp_common].include?(@type)
    end

    alias __new_anim__get_property_for_PBS get_property_for_PBS unless method_defined?(:__new_anim__get_property_for_PBS)
    def get_property_for_PBS(key)
      ret = __new_anim__get_property_for_PBS(key)
      case key
      when "SectionName"
        ret = [@type, @move]
        ret.push(@version) if @version > 0
      end
      return ret
    end

    def get_particle_property_for_PBS(key, index = 0)
      ret = nil
      ret = @particles[index][SUB_SCHEMA[key][0]] if SUB_SCHEMA[key]
      ret = nil if ret == false || (ret.is_a?(Array) && ret.length == 0) || ret == ""
      case key
      when "Focus"
        # The User and Target particles are hardcoded to only have their
        # corresponding foci, so they don't need writing to PBS
        if ["User", "Target"].include?(@particles[index][:name])
          ret = nil
        elsif ret
          ret = SUB_SCHEMA[key][2].key(ret)
        end
      when "AllCommands"
        # Get translations of all properties to their names as seen in PBS
        # animation files
        if !@@cmd_to_pbs_name
          @@cmd_to_pbs_name = {}
          SUB_SCHEMA.each_pair do |key, val|
            @@cmd_to_pbs_name[val[0]] ||= []
            @@cmd_to_pbs_name[val[0]].push([key, val[1].length])
          end
          # For each property translation, put "SetXYZ" before "MoveXYZ"
          @@cmd_to_pbs_name.each_value do |val|
            val.sort! { |a, b| a[1] <=> b[1] }
            val.map! { |a| a[0] }
          end
        end
        # Gather all commands into a single array
        ret = []
        @particles[index].each_pair do |key, val|
          next if !val.is_a?(Array)
          val.each do |cmd|
            new_cmd = cmd.clone
            if @particles[index][:name] != "SE" && new_cmd[1] > 0
              new_cmd.pop if new_cmd.last == :linear   # This is the default
              ret.push([@@cmd_to_pbs_name[key][1]] + new_cmd)   # ["MoveXYZ", keyframe, duration, value]
            else
              ret.push([@@cmd_to_pbs_name[key][0]] + new_cmd)   # ["SetXYZ", keyframe, duration, value]
            end
          end
        end
        # Sort the array of commands by keyframe order, then by duration, then
        # by the order they're defined in SUB_SCHEMA
        ret.sort! do |a, b|
          if a[1] == b[1]
            if a[2] == b[2]
              next SUB_SCHEMA.keys.index(a[0]) <=> SUB_SCHEMA.keys.index(b[0])
            else
              next a[2] <=> b[2]   # Sort by duration
            end
          else
            next a[1] <=> b[1]   # Sort by keyframe
          end
        end
      end
      return ret
    end
  end
end
