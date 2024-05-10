module GameData
  class Animation
    attr_reader :type         # :move, :opp_move, :common, :opp_common
    attr_reader :move         # Either the move's ID or the common animation's name (both are strings)
    attr_reader :version      # Hit number
    attr_reader :name         # Shown in the sublist; cosmetic only
    attr_reader :no_user      # Whether there is no "User" particle (false by default)
    attr_reader :no_target    # Whether there is no "Target" particle (false by default)
    attr_reader :ignore       # Whether the animation can't be played in battle
    attr_reader :flags
    attr_reader :pbs_path     # Whole path minus "PBS/Animations/" at start and ".txt" at end
    attr_reader :particles

    DATA = {}
    DATA_FILENAME = "animations.dat"
    OPTIONAL = true

    # NOTE: All mentions of focus types can be found by searching for
    #       :user_and_target, plus there's :foreground in PARTICLE_DEFAULT_VALUES
    #       below.
    FOCUS_TYPES = {
      "Foreground"           => :foreground,
      "Midground"            => :midground,
      "Background"           => :background,
      "User"                 => :user,
      "Target"               => :target,
      "UserAndTarget"        => :user_and_target,
      "UserSideForeground"   => :user_side_foreground,
      "UserSideBackground"   => :user_side_background,
      "TargetSideForeground" => :target_side_foreground,
      "TargetSideBackground" => :target_side_background
    }
    FOCUS_TYPES_WITH_USER = [
      :user, :user_and_target, :user_side_foreground, :user_side_background
    ]
    FOCUS_TYPES_WITH_TARGET = [
      :target, :user_and_target, :target_side_foreground, :target_side_background
    ]
    INTERPOLATION_TYPES = {
      "None"     => :none,
      "Linear"   => :linear,
      "EaseIn"   => :ease_in,
      "EaseBoth" => :ease_both,
      "EaseOut"  => :ease_out
    }
    USER_AND_TARGET_SEPARATION = [200, -200, -100]   # x, y, z (from user to target)
    SPAWNER_TYPES = {
      "None"                     => :none,
      "RandomDirection"          => :random_direction,
      "RandomDirectionGravity"   => :random_direction_gravity,
      "RandomUpDirectionGravity" => :random_up_direction_gravity
    }
    ANGLE_OVERRIDES = {
      "None"                => :none,
      "InitialAngleToFocus" => :initial_angle_to_focus,
      "AlwaysPointAtFocus"  => :always_point_at_focus
    }

    # Properties that apply to the animation in general, not to individual
    # particles. They don't change during the animation.
    SCHEMA = {
      "SectionName" => [:id,        "esU", {"Move" => :move, "OppMove" => :opp_move,
                                            "Common" => :common, "OppCommon" => :opp_common}],
      "Name"        => [:name,      "s"],
      "NoUser"      => [:no_user,   "b"],
      "NoTarget"    => [:no_target, "b"],
      "Ignore"      => [:ignore,    "b"],
      "Particle"    => [:particles, "s"]   # Is a subheader line like <text>
    }
    # For individual particles. Any property whose schema begins with "^" can
    # change during the animation.
    SUB_SCHEMA = {
      # These properties cannot be changed partway through the animation.
      # NOTE: "Name" isn't a property here, because the particle's name comes
      #       from the "Particle" property above.
      "Graphic"        => [:graphic,          "s"],
      "Focus"          => [:focus,            "e", FOCUS_TYPES],
      "FoeInvertX"     => [:foe_invert_x,     "b"],
      "FoeInvertY"     => [:foe_invert_y,     "b"],
      "FoeFlip"        => [:foe_flip,         "b"],
      "Spawner"        => [:spawner,          "e", SPAWNER_TYPES],
      "SpawnQuantity"  => [:spawn_quantity,   "v"],
      "RandomFrameMax" => [:random_frame_max, "u"],
      "AngleOverride"  => [:angle_override,   "e", ANGLE_OVERRIDES],
      # All properties below are "SetXYZ" or "MoveXYZ". "SetXYZ" has the
      # keyframe and the value, and "MoveXYZ" has the keyframe, duration and the
      # value. All have "^" in their schema. "SetXYZ" is turned into "MoveXYZ"
      # when compiling by inserting a duration (second value) of 0.
      "SetFrame"       => [:frame,            "^uu"],   # Frame within the graphic if it's a spritesheet
      "MoveFrame"      => [:frame,            "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetBlending"    => [:blending,         "^uu"],   # 0, 1 or 2
      "SetFlip"        => [:flip,             "^ub"],
      "SetX"           => [:x,                "^ui"],
      "MoveX"          => [:x,                "^uuiE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetY"           => [:y,                "^ui"],
      "MoveY"          => [:y,                "^uuiE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetZ"           => [:z,                "^ui"],
      "MoveZ"          => [:z,                "^uuiE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetZoomX"       => [:zoom_x,           "^uu"],
      "MoveZoomX"      => [:zoom_x,           "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetZoomY"       => [:zoom_y,           "^uu"],
      "MoveZoomY"      => [:zoom_y,           "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetAngle"       => [:angle,            "^ui"],
      "MoveAngle"      => [:angle,            "^uuiE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetVisible"     => [:visible,          "^ub"],
      "SetOpacity"     => [:opacity,          "^uu"],
      "MoveOpacity"    => [:opacity,          "^uuuE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetColorRed"    => [:color_red,        "^ui"],
      "MoveColorRed"   => [:color_red,        "^uuiE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetColorGreen"  => [:color_green,      "^ui"],
      "MoveColorGreen" => [:color_green,      "^uuiE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetColorBlue"   => [:color_blue,       "^ui"],
      "MoveColorBlue"  => [:color_blue,       "^uuiE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetColorAlpha"  => [:color_alpha,      "^ui"],
      "MoveColorAlpha" => [:color_alpha,      "^uuiE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetToneRed"     => [:tone_red,         "^ui"],
      "MoveToneRed"    => [:tone_red,         "^uuiE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetToneGreen"   => [:tone_green,       "^ui"],
      "MoveToneGreen"  => [:tone_green,       "^uuiE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetToneBlue"    => [:tone_blue,        "^ui"],
      "MoveToneBlue"   => [:tone_blue,        "^uuiE", nil, nil, nil, INTERPOLATION_TYPES],
      "SetToneGray"    => [:tone_gray,        "^ui"],
      "MoveToneGray"   => [:tone_gray,        "^uuiE", nil, nil, nil, INTERPOLATION_TYPES],
      # These properties are specifically for the "SE" particle.
      "Play"           => [:se,               "^usUU"],   # Filename, volume, pitch
      "PlayUserCry"    => [:user_cry,         "^uUU"],   # Volume, pitch
      "PlayTargetCry"  => [:target_cry,       "^uUU"]   # Volume, pitch
    }
    PARTICLE_DEFAULT_VALUES = {
      :name             => "",
      :graphic          => "",
      :focus            => :foreground,
      :foe_invert_x     => false,
      :foe_invert_y     => false,
      :foe_flip         => false,
      :spawner          => :none,
      :spawn_quantity   => 1,
      :random_frame_max => 0,
      :angle_override   => :none

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
      :z           => 0,
      :zoom_x      => 100,
      :zoom_y      => 100,
      :angle       => 0,
      :visible     => false,
      :opacity     => 255,
      :color_red   => 0,
      :color_green => 0,
      :color_blue  => 0,
      :color_alpha => 0,
      :tone_red    => 0,
      :tone_green  => 0,
      :tone_blue   => 0,
      :tone_gray   => 0,
      :se          => nil,
      :user_cry    => nil,
      :target_cry  => nil
    }

    def self.property_display_name(property)
      return {
        :frame       => _INTL("Frame"),
        :blending    => _INTL("Blending"),
        :flip        => _INTL("Flip"),
        :x           => _INTL("X"),
        :y           => _INTL("Y"),
        :z           => _INTL("Priority"),
        :zoom_x      => _INTL("Zoom X"),
        :zoom_y      => _INTL("Zoom Y"),
        :angle       => _INTL("Angle"),
        :visible     => _INTL("Visible"),
        :opacity     => _INTL("Opacity"),
        :color_red   => _INTL("Color Red"),
        :color_green => _INTL("Color Green"),
        :color_blue  => _INTL("Color Blue"),
        :color_alpha => _INTL("Color Alpha"),
        :tone_red    => _INTL("Tone Red"),
        :tone_green  => _INTL("Tone Green"),
        :tone_blue   => _INTL("Tone Blue"),
        :tone_gray   => _INTL("Tone Gray")
      }[property] || property.to_s.capitalize
    end

    def self.property_can_interpolate?(property)
      return false if !property
      SUB_SCHEMA.each_value do |prop|
        return true if prop[0] == property && prop[5] && prop[5] == INTERPOLATION_TYPES
      end
      return false
    end

    @@cmd_to_pbs_name = nil   # Used for writing animation PBS files

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

    def self.new_hash(anim_type = 0, move = nil)
      ret = {}
      ret[:type]      = (anim_type == 0) ? :move : :common
      ret[:move]      = (anim_type == 0) ? "STRUGGLE" : "Shiny"
      ret[:move]      = move if !move.nil?
      ret[:version]   = 0
      ret[:name]      = _INTL("New animation")
      ret[:no_user]   = false
      ret[:no_target] = false
      ret[:ignore]    = false
      ret[:particles] = [
        {:name => "User", :focus => :user, :graphic => "USER"},
        {:name => "Target", :focus => :target, :graphic => "TARGET"},
        {:name => "SE"}
      ]
      ret[:flags]     = []
      ret[:pbs_path]  = "New animation"
      return ret
    end

    def initialize(hash)
      # NOTE: hash has an :id entry, but it's unused here.
      @type       = hash[:type]
      @move       = hash[:move]
      @version    = hash[:version]   || 0
      @name       = hash[:name]
      @no_user    = hash[:no_user]   || false
      @no_target  = hash[:no_target] || false
      @ignore     = hash[:ignore]    || false
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
      ret[:no_user] = @no_user
      ret[:no_target] = @no_target
      ret[:ignore] = @ignore
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

    def inspect
      ret = super.chop + ": "
      case @type
      when :move       then ret += _INTL("[Move]")
      when :opp_move   then ret += _INTL("[Foe Move]")
      when :common     then ret += _INTL("[Common]")
      when :opp_common then ret += _INTL("[Foe Common]")
      else
        raise _INTL("Unknown animation type.")
      end
      case @type
      when :move, :opp_move
        move_data = GameData::Move.try_get(@move)
        move_name = (move_data) ? move_data.name : @move
        ret += " " + move_name
      when :common, :opp_common
        ret += " " + @move
      end
      ret += " (" + @version.to_s + ")" if @version > 0
      ret += " - " + @name if @name
      return ret
    end

    def move_animation?
      return [:move, :opp_move].include?(@type)
    end

    def common_animation?
      return [:common, :opp_common].include?(@type)
    end

    def opposing_animation?
      return [:opp_move, :opp_common].include?(@type)
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
      when "Graphic", "Focus"
        # The User and Target particles have hardcoded graphics/foci, so they
        # don't need writing to PBS
        ret = nil if ["User", "Target"].include?(@particles[index][:name])
      when "Spawner"
        ret = nil if ret == :none
      when "SpawnQuantity"
        ret = nil if @particles[index][:spawner].nil? || @particles[index][:spawner] == :none
        ret = nil if ret && ret <= 1
      when "RandomFrameMax"
        ret = nil if ret == 0
      when "AngleOverride"
        ret = nil if ret == :none
        ret = nil if !FOCUS_TYPES_WITH_USER.include?(@particles[index][:focus]) &&
                     !FOCUS_TYPES_WITH_TARGET.include?(@particles[index][:focus])
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
              ret.push([@@cmd_to_pbs_name[key][1]] + new_cmd)   # ["MoveXYZ", keyframe, duration, value, interpolation]
            else
              case key
              when :se
                new_cmd[4] = nil if new_cmd[4] == 100   # Pitch
                new_cmd[3] = nil if new_cmd[4].nil? && new_cmd[3] == 100   # Volume
              when :user_cry, :target_cry
                new_cmd[3] = nil if new_cmd[3] == 100   # Pitch
                new_cmd[2] = nil if new_cmd[3].nil? && new_cmd[2] == 100   # Volume
              end
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
